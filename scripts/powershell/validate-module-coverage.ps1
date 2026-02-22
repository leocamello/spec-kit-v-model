<#
.SYNOPSIS
    Deterministic coverage validation for module-level V-Model artifacts.

.DESCRIPTION
    Parses architecture-design.md, module-design.md, and unit-test.md
    using regex to extract ARCH-NNN, MOD-NNN, UTP-NNN-X, and UTS-NNN-X# IDs.
    Cross-references them to verify:
      - Forward coverage: every ARCH has at least one MOD
      - Backward coverage: every non-[EXTERNAL] MOD has at least one UTP
      - UTP->UTS coverage: every UTP has at least one UTS
      - No orphaned MOD (MOD referencing non-existent ARCH)
      - No orphaned UTP (UTP referencing non-existent MOD)
      - [EXTERNAL] modules are bypassed for UTP requirement
      - [CROSS-CUTTING] parent ARCHs are tested normally

.PARAMETER VModelDir
    Path to the v-model directory containing architecture-design.md,
    module-design.md, and optionally unit-test.md.

.PARAMETER Json
    Output in JSON format (for AI consumption).

.EXAMPLE
    ./validate-module-coverage.ps1 ./specs/001-feature/v-model
    ./validate-module-coverage.ps1 -Json ./specs/001-feature/v-model

.NOTES
    Exit code 0 = full coverage, 1 = gaps found.
#>

[CmdletBinding()]
param(
    [switch]$Json,
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$VModelDir
)

$ErrorActionPreference = 'Stop'

$ArchDesign = Join-Path $VModelDir 'architecture-design.md'
$ModuleDesign = Join-Path $VModelDir 'module-design.md'
$UnitTest = Join-Path $VModelDir 'unit-test.md'

if (-not (Test-Path $ArchDesign)) {
    Write-Error "ERROR: architecture-design.md not found in $VModelDir"
    exit 1
}

if (-not (Test-Path $ModuleDesign)) {
    Write-Error "ERROR: module-design.md not found in $VModelDir"
    exit 1
}

$PartialMode = -not (Test-Path $UnitTest)

# ---- Pass 1: Extract IDs ----

# ARCH IDs from architecture-design.md Logical View (section-scoped)
$archLines = Get-Content $ArchDesign
$archIds = @()
$inLogical = $false
foreach ($line in $archLines) {
    if ($line -match '(?i)^##\s+Logical') {
        $inLogical = $true
        continue
    }
    if ($inLogical -and $line -match '^##\s') {
        break
    }
    if ($inLogical -and $line -match '^\|\s*(ARCH-[0-9]{3})\s*\|') {
        $archIds += $Matches[1]
    }
}
$archIds = @($archIds | Sort-Object -Unique)

# MOD IDs from module-design.md (heading lines + metadata)
$modLines = Get-Content $ModuleDesign
$modIds = @()
$modParents = @{}
$modExternal = @{}
$currentMod = ''
$inMetadata = $false
foreach ($line in $modLines) {
    if ($line -match '^###\s+Module:\s*(MOD-[0-9]{3})') {
        $currentMod = $Matches[1]
        $modIds += $currentMod
        $inMetadata = $true
        if ($line -match '\[EXTERNAL\]') {
            $modExternal[$currentMod] = $true
        }
        continue
    }
    if ($line -match '^####' -or $line -match '^---$') {
        $inMetadata = $false
    }
    if ($line -match '^###\s' -and $line -notmatch 'Module:') {
        $currentMod = ''
        $inMetadata = $false
    }
    if ($currentMod -and $inMetadata) {
        if ($line -match '^\*\*Parent Architecture Modules\*\*:') {
            $parents = @([regex]::Matches($line, 'ARCH-[0-9]{3}') |
                ForEach-Object { $_.Value })
            $modParents[$currentMod] = $parents
        }
        if ($line -match '\[EXTERNAL\]') {
            $modExternal[$currentMod] = $true
        }
    }
}
$modIds = @($modIds | Sort-Object -Unique)

# External module list
$externalModules = @()
foreach ($mod in $modIds) {
    if ($modExternal.Contains($mod)) {
        $externalModules += $mod
    }
}

# Mark ARCH covered by MOD parents
$archCovered = @{}
foreach ($mod in $modIds) {
    if ($modParents.Contains($mod)) {
        foreach ($p in $modParents[$mod]) {
            $archCovered[$p] = $true
        }
    }
}

# UTP/UTS IDs from unit-test.md (if exists)
$utpIds = @()
$utsIds = @()
if (-not $PartialMode) {
    $testContent = Get-Content -Raw $UnitTest
    $utpIds = @([regex]::Matches($testContent, 'UTP-[0-9]{3}-[A-Z]') |
        ForEach-Object { $_.Value } | Sort-Object -Unique)
    $utsIds = @([regex]::Matches($testContent, 'UTS-[0-9]{3}-[A-Z][0-9]+') |
        ForEach-Object { $_.Value } | Sort-Object -Unique)
}

$totalArch = $archIds.Count
$totalMod = $modIds.Count
$totalExternal = $externalModules.Count
$totalTestable = $totalMod - $totalExternal
$totalUtps = $utpIds.Count
$totalUtss = $utsIds.Count

# ---- Pass 2: Cross-reference ----

function Get-ModBaseKey($id) { $id -replace '^MOD-', '' }
function Get-UtpBaseKey($id) { ($id -replace '^UTP-', '') -replace '-[A-Z]$', '' }
function Get-UtpFullKey($id) { $id -replace '^UTP-', '' }
function Get-UtsFullKey($id) { $id -replace '^UTS-', '' }

# Forward coverage: every ARCH has at least one MOD
$archWithoutMod = @()
foreach ($arch in $archIds) {
    if (-not $archCovered.Contains($arch)) {
        $archWithoutMod += $arch
    }
}

# Backward coverage: every non-[EXTERNAL] MOD has at least one UTP (skip if partial)
$modWithoutUtp = @()
if (-not $PartialMode) {
    foreach ($mod in $modIds) {
        if ($modExternal.Contains($mod)) { continue }
        $modKey = Get-ModBaseKey $mod
        $hasUtp = $false
        foreach ($utp in $utpIds) {
            $utpKey = Get-UtpBaseKey $utp
            if ($modKey -eq $utpKey) {
                $hasUtp = $true
                break
            }
        }
        if (-not $hasUtp) {
            $modWithoutUtp += $mod
        }
    }
}

# UTP->UTS coverage (skip if partial)
$utpsWithoutUts = @()
if (-not $PartialMode) {
    foreach ($utp in $utpIds) {
        $utpKey = Get-UtpFullKey $utp
        $hasUts = $false
        foreach ($uts in $utsIds) {
            $utsKey = Get-UtsFullKey $uts
            if ($utsKey.StartsWith($utpKey)) {
                $hasUts = $true
                break
            }
        }
        if (-not $hasUts) {
            $utpsWithoutUts += $utp
        }
    }
}

# Orphaned MOD: referencing non-existent ARCH
$orphanedMods = @()
foreach ($mod in $modIds) {
    if ($modParents.Contains($mod)) {
        foreach ($parent in $modParents[$mod]) {
            if ($parent -notin $archIds) {
                $orphanedMods += "$mod references unknown $parent"
                break
            }
        }
    }
}

# Orphaned UTP: referencing non-existent MOD (skip if partial)
$orphanedUtps = @()
if (-not $PartialMode) {
    foreach ($utp in $utpIds) {
        $utpKey = Get-UtpBaseKey $utp
        $hasMod = $false
        foreach ($mod in $modIds) {
            $modKey = Get-ModBaseKey $mod
            if ($utpKey -eq $modKey) {
                $hasMod = $true
                break
            }
        }
        if (-not $hasMod) {
            $orphanedUtps += $utp
        }
    }
}

# ---- Calculate coverage ----

$archCoveredCount = $totalArch - $archWithoutMod.Count
$modCoveredCount = $totalTestable - $modWithoutUtp.Count
$utpsCoveredCount = $totalUtps - $utpsWithoutUts.Count

if ($totalArch -gt 0) { $archToModCoveragePct = [math]::Floor($archCoveredCount * 100 / $totalArch) }
else { $archToModCoveragePct = 0 }

if (-not $PartialMode -and $totalTestable -gt 0) { $modToUtpCoveragePct = [math]::Floor($modCoveredCount * 100 / $totalTestable) }
else { $modToUtpCoveragePct = 0 }

if (-not $PartialMode -and $totalUtps -gt 0) { $utpToUtsCoveragePct = [math]::Floor($utpsCoveredCount * 100 / $totalUtps) }
else { $utpToUtsCoveragePct = 0 }

$hasGaps = ($archWithoutMod.Count -gt 0) -or ($modWithoutUtp.Count -gt 0) -or
           ($utpsWithoutUts.Count -gt 0) -or ($orphanedMods.Count -gt 0) -or
           ($orphanedUtps.Count -gt 0)

# ---- Output ----

if ($Json) {
    $output = [ordered]@{
        total_arch               = $totalArch
        total_mod                = $totalMod
        total_external           = $totalExternal
        total_testable           = $totalTestable
        total_utps               = $totalUtps
        total_utss               = $totalUtss
        arch_covered             = $archCoveredCount
        mod_covered              = $modCoveredCount
        utps_covered             = $utpsCoveredCount
        arch_to_mod_coverage_pct = $archToModCoveragePct
        mod_to_utp_coverage_pct  = $modToUtpCoveragePct
        utp_to_uts_coverage_pct  = $utpToUtsCoveragePct
        has_gaps                 = $hasGaps
        partial_mode             = $PartialMode
        arch_without_mod         = $archWithoutMod
        mod_without_utp          = $modWithoutUtp
        utps_without_uts         = $utpsWithoutUts
        orphaned_mods            = $orphanedMods
        orphaned_utps            = $orphanedUtps
        external_modules         = $externalModules
    }
    $output | ConvertTo-Json -Compress
} else {
    Write-Output '=== Module-Level Coverage Validation ==='
    Write-Output ''
    Write-Output "Totals: $totalArch ARCH | $totalMod MOD ($totalExternal external) | $totalUtps UTPs | $totalUtss UTSs"
    Write-Output "ARCH -> MOD coverage: $archCoveredCount/$totalArch ($archToModCoveragePct%)"
    if ($PartialMode) {
        Write-Output 'MOD -> UTP coverage: SKIPPED (unit-test.md not found)'
        Write-Output 'UTP -> UTS coverage: SKIPPED'
    } else {
        Write-Output "MOD -> UTP coverage: $modCoveredCount/$totalTestable ($modToUtpCoveragePct%) [excluding $totalExternal external]"
        Write-Output "UTP -> UTS coverage: $utpsCoveredCount/$totalUtps ($utpToUtsCoveragePct%)"
    }
    Write-Output ''

    if ($archWithoutMod.Count -gt 0) {
        Write-Output 'Architecture modules WITHOUT module designs:'
        foreach ($arch in $archWithoutMod) { Write-Output "   - $arch" }
    }

    if ($modWithoutUtp.Count -gt 0) {
        Write-Output 'Module designs WITHOUT unit tests:'
        foreach ($mod in $modWithoutUtp) { Write-Output "   - $mod" }
    }

    if ($utpsWithoutUts.Count -gt 0) {
        Write-Output 'Unit test cases WITHOUT scenarios:'
        foreach ($utp in $utpsWithoutUts) { Write-Output "   - $utp" }
    }

    if ($orphanedMods.Count -gt 0) {
        Write-Output 'Orphaned module designs (referencing non-existent ARCH):'
        foreach ($msg in $orphanedMods) { Write-Output "   - $msg" }
    }

    if ($orphanedUtps.Count -gt 0) {
        Write-Output 'Orphaned unit test cases (referencing non-existent MOD):'
        foreach ($utp in $orphanedUtps) { Write-Output "   - $utp" }
    }

    if ($externalModules.Count -gt 0) {
        Write-Output 'External modules (UTP requirement bypassed):'
        foreach ($mod in $externalModules) { Write-Output "   - $mod [EXTERNAL]" }
    }

    if (-not $hasGaps) {
        Write-Output 'Full module-level coverage — all architecture modules decomposed, all testable modules have unit tests.'
    }
}

if ($hasGaps) { exit 1 } else { exit 0 }
