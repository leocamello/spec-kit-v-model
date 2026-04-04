<#
.SYNOPSIS
    Deterministic impact analysis for V-Model artifacts.

.DESCRIPTION
    Scans all markdown files in a V-Model directory, builds an ID dependency
    graph, and traverses it from one or more changed IDs to identify all
    suspect (potentially affected) artifacts.

    Supports three traversal modes:
      -Downward  (default) Traces downstream: what depends on the changed IDs?
      -Upward    Traces upstream: what do the changed IDs depend on?
      -Full      Both directions combined

.PARAMETER Downward
    Trace downstream dependents (default).

.PARAMETER Upward
    Trace upstream parents.

.PARAMETER Full
    Trace both directions.

.PARAMETER Json
    Output JSON to stdout instead of markdown file.

.PARAMETER Output
    Write markdown report to specified path instead of <vmodel-dir>/impact-report.md.

.PARAMETER Ids
    One or more V-Model IDs to analyze.

.PARAMETER VModelDir
    Path to the V-Model directory containing markdown artifacts.

.EXAMPLE
    ./impact-analysis.ps1 -Downward -Json -Ids REQ-001 -VModelDir ./v-model
#>

param(
    [switch]$Downward,
    [switch]$Upward,
    [switch]$Full,
    [switch]$Json,
    [string]$Output = "",
    [Parameter(Mandatory=$true)]
    [string[]]$Ids,
    [Parameter(Mandatory=$true)]
    [string]$VModelDir
)

$ErrorActionPreference = "Stop"

# Normalize -Ids: when called via `pwsh -File`, comma-separated values arrive as a single string
$Ids = @($Ids | ForEach-Object { $_ -split ',' } | Where-Object { $_ -ne '' })

# V-Model level ordering
$LevelsTopDown = @("REQ","ATP","SCN","HAZ","SYS","STP","STS","ARCH","ITP","ITS","MOD","UTP","UTS")
$LevelsBottomUp = @("UTS","UTP","MOD","ITS","ITP","ARCH","STS","STP","SYS","HAZ","SCN","ATP","REQ")

$IdPattern = '(REQ|ATP|SCN|SYS|STP|STS|ARCH|ITP|ITS|MOD|UTP|UTS|HAZ)(-[A-Z]+)?-[0-9]{3}(-[A-Z][0-9]?)?'

# ================================================================
# Direction validation
# ================================================================
$dirCount = 0
if ($Downward) { $dirCount++ }
if ($Upward)   { $dirCount++ }
if ($Full)     { $dirCount++ }

if ($dirCount -gt 1) {
    Write-Error "ERROR: -Downward, -Upward, and -Full are mutually exclusive"
    exit 1
}

$Direction = "downward"
if ($Upward) { $Direction = "upward" }
if ($Full)   { $Direction = "full" }

# ================================================================
# Validate inputs
# ================================================================
if (-not (Test-Path $VModelDir -PathType Container)) {
    Write-Error "ERROR: Directory not found: $VModelDir"
    exit 1
}

$mdFiles = Get-ChildItem -Path $VModelDir -Recurse -Filter "*.md" -File | Sort-Object FullName
if ($mdFiles.Count -eq 0) {
    Write-Error "ERROR: No V-Model artifacts found in $VModelDir"
    exit 1
}

if ([string]::IsNullOrEmpty($Output)) {
    $Output = Join-Path $VModelDir "impact-report.md"
}

# ================================================================
# Classify ID to V-Model level
# ================================================================
function Get-IdLevel {
    param([string]$Id)
    if ($Id -match '^(REQ|ATP|SCN|SYS|STP|STS|ARCH|ITP|ITS|MOD|UTP|UTS|HAZ)(-[A-Z]+)?') {
        $prefix = $Matches[0]
        switch -Regex ($prefix) {
            '^REQ'  { return "REQ" }
            '^ATP'  { return "ATP" }
            '^SCN'  { return "SCN" }
            '^SYS'  { return "SYS" }
            '^STP'  { return "STP" }
            '^STS'  { return "STS" }
            '^ARCH' { return "ARCH" }
            '^ITP'  { return "ITP" }
            '^ITS'  { return "ITS" }
            '^MOD'  { return "MOD" }
            '^UTP'  { return "UTP" }
            '^UTS'  { return "UTS" }
            '^HAZ'  { return "HAZ" }
            default { return $Matches[1] }
        }
    }
    return ""
}

# ================================================================
# Build dependency graph
# ================================================================
$References = @{}
$ReferencedBy = @{}
$AllIds = @{}

function Add-Edge {
    param([string]$Owner, [string]$Ref)
    # Owner references Ref
    if (-not $References.ContainsKey($Owner)) {
        $References[$Owner] = [System.Collections.Generic.HashSet[string]]::new()
    }
    [void]$References[$Owner].Add($Ref)

    # Ref is referenced by Owner
    if (-not $ReferencedBy.ContainsKey($Ref)) {
        $ReferencedBy[$Ref] = [System.Collections.Generic.HashSet[string]]::new()
    }
    [void]$ReferencedBy[$Ref].Add($Owner)
}

foreach ($file in $mdFiles) {
    $owner = ""
    foreach ($line in (Get-Content $file.FullName)) {
        $lineIds = @([regex]::Matches($line, $IdPattern) | ForEach-Object { $_.Value })
        if ($lineIds.Count -eq 0) { continue }

        foreach ($lid in $lineIds) {
            $AllIds[$lid] = $true
        }

        # Heading or table row → first ID is owner
        if ($line -match '^#' -or $line -match '^\s*\|') {
            $owner = $lineIds[0]
        }

        if ($owner -ne "") {
            foreach ($lid in $lineIds) {
                if ($lid -ne $owner) {
                    Add-Edge -Owner $owner -Ref $lid
                }
            }
        } elseif ($lineIds.Count -ge 2) {
            $owner = $lineIds[0]
            for ($i = 1; $i -lt $lineIds.Count; $i++) {
                Add-Edge -Owner $owner -Ref $lineIds[$i]
            }
        }

        # Reset on section boundaries
        if ($line -match '^---$' -or $line -match '^$') {
            $owner = ""
        }
    }
}

# ================================================================
# Warn about unknown IDs
# ================================================================
$validIds = @()
foreach ($id in $Ids) {
    if (-not $AllIds.ContainsKey($id) -and -not $References.ContainsKey($id) -and -not $ReferencedBy.ContainsKey($id)) {
        Write-Warning "ID '$id' not found in any V-Model artifact"
    } else {
        $validIds += $id
    }
}

if ($validIds.Count -eq 0) {
    Write-Error "ERROR: None of the specified IDs were found in V-Model artifacts"
    exit 1
}

# ================================================================
# Traversal functions
# ================================================================
function Invoke-Traversal {
    param(
        [string[]]$ChangedIds,
        [string]$TraversalDirection  # "downward" or "upward"
    )

    $visited = @{}
    $queue = [System.Collections.Generic.Queue[string]]::new()
    $suspects = @{}
    $blast = @{}

    foreach ($id in $ChangedIds) {
        $visited[$id] = $true
        $queue.Enqueue($id)
    }

    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()

        $neighbors = @()
        if ($TraversalDirection -eq "downward") {
            if ($ReferencedBy.ContainsKey($current)) {
                $neighbors = @($ReferencedBy[$current])
            }
        } else {
            if ($References.ContainsKey($current)) {
                $neighbors = @($References[$current])
            }
        }

        foreach ($dep in $neighbors) {
            if ($visited.ContainsKey($dep)) { continue }
            $visited[$dep] = $true

            $level = Get-IdLevel $dep
            if ([string]::IsNullOrEmpty($level)) { continue }

            if (-not $suspects.ContainsKey($level)) {
                $suspects[$level] = @()
                $blast[$level] = 0
            }
            $suspects[$level] += $dep
            $blast[$level]++

            $queue.Enqueue($dep)
        }
    }

    # Build re-validation order
    $levelOrder = if ($TraversalDirection -eq "downward") { $LevelsBottomUp } else { $LevelsTopDown }
    $order = @()
    foreach ($level in $levelOrder) {
        if ($suspects.ContainsKey($level)) {
            $order += ($suspects[$level] | Sort-Object)
        }
    }

    return @{
        Suspects = $suspects
        Blast = $blast
        Order = $order
    }
}

# ================================================================
# Execute traversal
# ================================================================
$downResult = $null
$upResult = $null

switch ($Direction) {
    "downward" {
        $downResult = Invoke-Traversal -ChangedIds $validIds -TraversalDirection "downward"
    }
    "upward" {
        $upResult = Invoke-Traversal -ChangedIds $validIds -TraversalDirection "upward"
    }
    "full" {
        $downResult = Invoke-Traversal -ChangedIds $validIds -TraversalDirection "downward"
        $upResult = Invoke-Traversal -ChangedIds $validIds -TraversalDirection "upward"
    }
}

# ================================================================
# Compute blast total
# ================================================================
function Get-BlastTotal {
    param([hashtable]$Blast)
    $total = 0
    foreach ($v in $Blast.Values) { $total += $v }
    return $total
}

# ================================================================
# JSON output
# ================================================================
if ($Json) {
    $result = @{
        changed_ids = $validIds
        direction = $Direction
    }

    if ($Direction -eq "full") {
        $downSuspects = @{}
        foreach ($level in $LevelsTopDown) {
            if ($downResult.Suspects.ContainsKey($level)) {
                $downSuspects[$level] = @($downResult.Suspects[$level] | Sort-Object)
            }
        }
        $upSuspects = @{}
        foreach ($level in $LevelsTopDown) {
            if ($upResult.Suspects.ContainsKey($level)) {
                $upSuspects[$level] = @($upResult.Suspects[$level] | Sort-Object)
            }
        }
        $result["suspect_artifacts"] = @{
            downstream = $downSuspects
            upstream = $upSuspects
        }

        # Deduplicate: IDs appearing in both downstream and upstream count once
        $orderSeen = @{}
        $combinedOrder = @()
        $uniqueBlast = @{}
        $uniqueTotal = 0
        foreach ($id in $downResult.Order) {
            if ($orderSeen.ContainsKey($id)) { continue }
            $orderSeen[$id] = $true
            $combinedOrder += $id
            $lvl = Get-IdLevel $id
            if (-not $uniqueBlast.ContainsKey($lvl)) { $uniqueBlast[$lvl] = 0 }
            $uniqueBlast[$lvl]++
            $uniqueTotal++
        }
        foreach ($id in $upResult.Order) {
            if ($orderSeen.ContainsKey($id)) { continue }
            $orderSeen[$id] = $true
            $combinedOrder += $id
            $lvl = Get-IdLevel $id
            if (-not $uniqueBlast.ContainsKey($lvl)) { $uniqueBlast[$lvl] = 0 }
            $uniqueBlast[$lvl]++
            $uniqueTotal++
        }

        $byLevel = @{}
        foreach ($level in $LevelsTopDown) {
            if ($uniqueBlast.ContainsKey($level) -and $uniqueBlast[$level] -gt 0) {
                $byLevel[$level] = $uniqueBlast[$level]
            }
        }
        $result["blast_radius"] = @{ total = $uniqueTotal; by_level = $byLevel }
        $result["revalidation_order"] = $combinedOrder

    } else {
        $activeResult = if ($Direction -eq "downward") { $downResult } else { $upResult }

        $suspects = @{}
        foreach ($level in $LevelsTopDown) {
            if ($activeResult.Suspects.ContainsKey($level)) {
                $suspects[$level] = @($activeResult.Suspects[$level] | Sort-Object)
            }
        }
        $result["suspect_artifacts"] = $suspects

        $total = Get-BlastTotal $activeResult.Blast
        $byLevel = @{}
        foreach ($level in $LevelsTopDown) {
            if ($activeResult.Blast.ContainsKey($level)) {
                $byLevel[$level] = $activeResult.Blast[$level]
            }
        }
        $result["blast_radius"] = @{ total = $total; by_level = $byLevel }
        $result["revalidation_order"] = $activeResult.Order
    }

    $result | ConvertTo-Json -Depth 10 -Compress
    exit 0
}

# ================================================================
# Markdown output
# ================================================================
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$lines = @()
$lines += "# Impact Analysis Report"
$lines += ""
$lines += "**Generated**: $timestamp"
$lines += "**Direction**: $Direction"
$lines += "**Source**: ``$VModelDir``"
$lines += ""
$lines += "## Changed IDs"
$lines += ""
$lines += "| ID | Type |"
$lines += "|----|------|"
foreach ($id in $validIds) {
    $level = Get-IdLevel $id
    $lines += "| $id | $level |"
}
$lines += ""

if ($Direction -eq "full") {
    $downTotal = Get-BlastTotal $downResult.Blast
    $upTotal = Get-BlastTotal $upResult.Blast

    $lines += "## Downstream Suspects"
    $lines += ""
    if ($downTotal -eq 0) {
        $lines += "No downstream suspects found."
        $lines += ""
    } else {
        foreach ($level in $LevelsTopDown) {
            if ($downResult.Suspects.ContainsKey($level)) {
                $lines += "### $level"
                $lines += ""
                foreach ($id in ($downResult.Suspects[$level] | Sort-Object)) {
                    $lines += "- $id"
                }
                $lines += ""
            }
        }
    }

    $lines += "## Upstream Suspects"
    $lines += ""
    if ($upTotal -eq 0) {
        $lines += "No upstream suspects found."
        $lines += ""
    } else {
        foreach ($level in $LevelsTopDown) {
            if ($upResult.Suspects.ContainsKey($level)) {
                $lines += "### $level"
                $lines += ""
                foreach ($id in ($upResult.Suspects[$level] | Sort-Object)) {
                    $lines += "- $id"
                }
                $lines += ""
            }
        }
    }

    $total = $downTotal + $upTotal
    $lines += "## Blast Radius"
    $lines += ""
    $lines += "| Direction | Level | Count |"
    $lines += "|-----------|-------|-------|"
    foreach ($level in $LevelsTopDown) {
        if ($downResult.Blast.ContainsKey($level)) {
            $lines += "| Downstream | $level | $($downResult.Blast[$level]) |"
        }
    }
    foreach ($level in $LevelsTopDown) {
        if ($upResult.Blast.ContainsKey($level)) {
            $lines += "| Upstream | $level | $($upResult.Blast[$level]) |"
        }
    }
    $lines += "| **Total** | | **$total** |"
    $lines += ""

    $lines += "## Re-validation Order"
    $lines += ""
    $lines += "### Downstream (bottom-up)"
    $lines += ""
    $idx = 1
    foreach ($id in $downResult.Order) {
        $lines += "$idx. $id"
        $idx++
    }
    $lines += ""
    $lines += "### Upstream (top-down)"
    $lines += ""
    $idx = 1
    foreach ($id in $upResult.Order) {
        $lines += "$idx. $id"
        $idx++
    }

} else {
    $activeResult = if ($Direction -eq "downward") { $downResult } else { $upResult }
    $total = Get-BlastTotal $activeResult.Blast

    $lines += "## Suspect Artifacts"
    $lines += ""
    if ($total -eq 0) {
        $lines += "No suspect artifacts found."
        $lines += ""
    } else {
        foreach ($level in $LevelsTopDown) {
            if ($activeResult.Suspects.ContainsKey($level)) {
                $lines += "### $level"
                $lines += ""
                foreach ($id in ($activeResult.Suspects[$level] | Sort-Object)) {
                    $lines += "- $id"
                }
                $lines += ""
            }
        }
    }

    $lines += "## Blast Radius"
    $lines += ""
    $lines += "| Level | Count |"
    $lines += "|-------|-------|"
    foreach ($level in $LevelsTopDown) {
        if ($activeResult.Blast.ContainsKey($level)) {
            $lines += "| $level | $($activeResult.Blast[$level]) |"
        }
    }
    $lines += "| **Total** | **$total** |"
    $lines += ""

    $lines += "## Re-validation Order"
    $lines += ""
    $idx = 1
    foreach ($id in $activeResult.Order) {
        $lines += "$idx. $id"
        $idx++
    }
}

$lines | Out-File -FilePath $Output -Encoding UTF8
Write-Host "Impact report written to $Output"
