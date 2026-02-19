<#
.SYNOPSIS
    Deterministic traceability matrix builder for V-Model artifacts.

.DESCRIPTION
    Parses requirements.md and acceptance-plan.md using regex to build
    a complete traceability matrix in markdown format.

.PARAMETER VModelDir
    Path to the v-model directory containing requirements.md and acceptance-plan.md.

.PARAMETER Output
    Optional output file path. If not specified, prints to stdout.

.EXAMPLE
    ./build-matrix.ps1 ./specs/001-feature/v-model
    ./build-matrix.ps1 ./specs/001-feature/v-model -Output matrix.md
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$VModelDir,
    [string]$Output
)

$ErrorActionPreference = 'Stop'

$Requirements = Join-Path $VModelDir 'requirements.md'
$Acceptance = Join-Path $VModelDir 'acceptance-plan.md'

if (-not (Test-Path $Requirements)) {
    Write-Error "ERROR: requirements.md not found in $VModelDir"
    exit 1
}

if (-not (Test-Path $Acceptance)) {
    Write-Error "ERROR: acceptance-plan.md not found in $VModelDir"
    exit 1
}

$reqContent = Get-Content $Requirements
$accContent = Get-Content $Acceptance
$accRaw = Get-Content -Raw $Acceptance

# Extract REQ IDs and descriptions from requirement table rows
$reqDescriptions = [ordered]@{}
foreach ($line in $reqContent) {
    if ($line -match '\|\s*(REQ-([A-Z]+-)?[0-9]{3})\s*\|\s*([^|]+)') {
        $reqId = $Matches[1]
        $reqDesc = $Matches[3].Trim()
        $reqDescriptions[$reqId] = $reqDesc
    }
}

# Extract ATP sections: "#### Test Case: ATP-{CAT?-}NNN-X (Description)"
$atpDescriptions = [ordered]@{}
foreach ($line in $accContent) {
    if ($line -match 'Test Case:\s*(ATP-([A-Z]+-)?[0-9]{3}-[A-Z])\s*\(([^)]+)\)') {
        $atpId = $Matches[1]
        $atpDesc = $Matches[3]
        $atpDescriptions[$atpId] = $atpDesc
    }
}

# Extract SCN IDs (with optional category prefix)
$scnIds = @([regex]::Matches($accRaw, 'SCN-([A-Z]+-)?[0-9]{3}-[A-Z][0-9]+') |
    ForEach-Object { $_.Value } | Sort-Object -Unique)

# Get sorted unique IDs
$reqIds = @($reqDescriptions.Keys | Sort-Object)
$atpIds = @($atpDescriptions.Keys | Sort-Object)

$totalReqs = $reqIds.Count
$totalAtps = $atpIds.Count
$totalScns = $scnIds.Count

# Helper: extract base key for matching
function Get-ReqBaseKey($id) { $id -replace '^REQ-', '' }
function Get-AtpBaseKey($id) { ($id -replace '^ATP-', '') -replace '-[A-Z]$', '' }
function Get-AtpFullKey($id) { $id -replace '^ATP-', '' }
function Get-ScnFullKey($id) { $id -replace '^SCN-', '' }

# Build the matrix
$reqsWithAtp = 0
$atpsWithScn = 0

$matrixLines = @()
$matrixLines += '| Requirement ID | Requirement Description | Test Case ID (ATP) | Validation Condition | Scenario ID (SCN) | Status |'
$matrixLines += '|----------------|------------------------|--------------------|----------------------|--------------------|--------|'

foreach ($req in $reqIds) {
    $reqKey = Get-ReqBaseKey $req
    $reqDesc = $reqDescriptions[$req]
    $firstRow = $true
    $hasAtp = $false

    foreach ($atp in $atpIds) {
        $atpKey = Get-AtpBaseKey $atp
        if ($atpKey -eq $reqKey) {
            $hasAtp = $true
            $atpDesc = $atpDescriptions[$atp]
            $atpFKey = Get-AtpFullKey $atp
            $atpHasScn = $false

            foreach ($scn in $scnIds) {
                $scnFKey = Get-ScnFullKey $scn
                if ($scnFKey.StartsWith($atpFKey)) {
                    $atpHasScn = $true
                    if ($firstRow) {
                        $matrixLines += "| **$req** | $reqDesc | $atp | $atpDesc | $scn | ⬜ Untested |"
                        $firstRow = $false
                    } else {
                        $matrixLines += "| | | $atp | $atpDesc | $scn | ⬜ Untested |"
                    }
                }
            }

            if (-not $atpHasScn) {
                if ($firstRow) {
                    $matrixLines += "| **$req** | $reqDesc | $atp | $atpDesc | ❌ MISSING | ⬜ Untested |"
                    $firstRow = $false
                } else {
                    $matrixLines += "| | | $atp | $atpDesc | ❌ MISSING | ⬜ Untested |"
                }
            } else {
                $atpsWithScn++
            }
        }
    }

    if ($hasAtp) {
        $reqsWithAtp++
    } else {
        if ($firstRow) {
            $matrixLines += "| **$req** | $reqDesc | ❌ MISSING | — | — | ⬜ Untested |"
        }
    }
}

# Calculate coverage percentages
if ($totalReqs -gt 0) {
    $reqPct = [math]::Floor($reqsWithAtp * 100 / $totalReqs)
} else {
    $reqPct = 0
}
if ($totalAtps -gt 0) {
    $atpPct = [math]::Floor($atpsWithScn * 100 / $totalAtps)
} else {
    $atpPct = 0
}

# Find gaps
$reqsWithoutAtp = @()
foreach ($req in $reqIds) {
    $reqKey = Get-ReqBaseKey $req
    $hasAtp = $false
    foreach ($atp in $atpIds) {
        $atpKey = Get-AtpBaseKey $atp
        if ($atpKey -eq $reqKey) { $hasAtp = $true; break }
    }
    if (-not $hasAtp) { $reqsWithoutAtp += $req }
}

$orphanedAtps = @()
foreach ($atp in $atpIds) {
    $atpKey = Get-AtpBaseKey $atp
    $hasReq = $false
    foreach ($req in $reqIds) {
        $reqKey = Get-ReqBaseKey $req
        if ($atpKey -eq $reqKey) { $hasReq = $true; break }
    }
    if (-not $hasReq) { $orphanedAtps += $atp }
}

# Compose full output
$date = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')

$fullOutput = @()
$fullOutput += '# Traceability Matrix'
$fullOutput += ''
$fullOutput += "**Generated**: $date"
$fullOutput += "**Source**: ``$VModelDir/``"
$fullOutput += ''
$fullOutput += '## Matrix'
$fullOutput += ''
$fullOutput += $matrixLines
$fullOutput += ''
$fullOutput += '## Coverage Metrics'
$fullOutput += ''
$fullOutput += '| Metric | Value |'
$fullOutput += '|--------|-------|'
$fullOutput += "| **Total Requirements** | $totalReqs |"
$fullOutput += "| **Total Test Cases** | $totalAtps |"
$fullOutput += "| **Total Scenarios** | $totalScns |"
$fullOutput += "| **REQ → ATP Coverage** | $reqsWithAtp/$totalReqs ($reqPct%) |"
$fullOutput += "| **ATP → SCN Coverage** | $atpsWithScn/$totalAtps ($atpPct%) |"
$fullOutput += ''
$fullOutput += '## Gap Analysis'
$fullOutput += ''
$fullOutput += '### Uncovered Requirements'
$fullOutput += ''
if ($reqsWithoutAtp.Count -eq 0) {
    $fullOutput += 'None — full coverage.'
} else {
    foreach ($req in $reqsWithoutAtp) { $fullOutput += "- $req" }
}
$fullOutput += ''
$fullOutput += '### Orphaned Test Cases'
$fullOutput += ''
if ($orphanedAtps.Count -eq 0) {
    $fullOutput += 'None — all tests trace to requirements.'
} else {
    foreach ($atp in $orphanedAtps) { $fullOutput += "- $atp" }
}
$fullOutput += ''
$fullOutput += '## Audit Notes'
$fullOutput += ''
$fullOutput += '- **Matrix generated by**: `build-matrix.ps1` (deterministic regex parser)'
$fullOutput += '- **Source documents**: `requirements.md`, `acceptance-plan.md`'
$fullOutput += "- **Last validated**: $date"

if ($Output) {
    $fullOutput | Out-File -FilePath $Output -Encoding utf8
    Write-Output "Traceability matrix written to $Output"
} else {
    $fullOutput | ForEach-Object { Write-Output $_ }
}
