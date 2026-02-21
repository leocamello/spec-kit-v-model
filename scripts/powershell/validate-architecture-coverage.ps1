<#
.SYNOPSIS
    Deterministic coverage validation for architecture-level V-Model artifacts.

.DESCRIPTION
    Parses system-design.md, architecture-design.md, and integration-test.md
    using regex to extract SYS-NNN, ARCH-NNN, ITP-NNN-X, and ITS-NNN-X# IDs.
    Cross-references them to verify:
      - Forward coverage: every SYS has at least one ARCH
      - Backward coverage: every ARCH has at least one ITP
      - ITP->ITS coverage: every ITP has at least one ITS
      - No orphaned ARCH (ARCH referencing non-existent SYS)
      - No orphaned ITP (ITP referencing non-existent ARCH)
      - CROSS-CUTTING modules are valid without SYS parent

.PARAMETER VModelDir
    Path to the v-model directory containing system-design.md,
    architecture-design.md, and optionally integration-test.md.

.PARAMETER Json
    Output in JSON format (for AI consumption).

.EXAMPLE
    ./validate-architecture-coverage.ps1 ./specs/001-feature/v-model
    ./validate-architecture-coverage.ps1 -Json ./specs/001-feature/v-model

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

$SystemDesign = Join-Path $VModelDir 'system-design.md'
$ArchDesign = Join-Path $VModelDir 'architecture-design.md'
$IntegrationTest = Join-Path $VModelDir 'integration-test.md'

if (-not (Test-Path $SystemDesign)) {
    Write-Error "ERROR: system-design.md not found in $VModelDir"
    exit 1
}

if (-not (Test-Path $ArchDesign)) {
    Write-Error "ERROR: architecture-design.md not found in $VModelDir"
    exit 1
}

$PartialMode = -not (Test-Path $IntegrationTest)

# ---- Pass 1: Extract IDs ----

# SYS IDs from system-design.md Decomposition View (section-scoped)
$designLines = Get-Content $SystemDesign
$sysIds = @()
$inDecomposition = $false
foreach ($line in $designLines) {
    if ($line -match '(?i)^##\s+Decomposition') {
        $inDecomposition = $true
        continue
    }
    if ($inDecomposition -and $line -match '^##\s') {
        break
    }
    if ($inDecomposition) {
        $sysIds += @([regex]::Matches($line, 'SYS-[0-9]{3}') |
            ForEach-Object { $_.Value })
    }
}
$sysIds = @($sysIds | Sort-Object -Unique)

# ARCH IDs from architecture-design.md Logical View (section-scoped)
$archLines = Get-Content $ArchDesign
$archIds = @()
$archParents = @{}
$archCrossCutting = @{}
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
        $archId = $Matches[1]
        $archIds += $archId
        # Parent System Components is column 4 (0-indexed from split on |)
        $cols = $line -split '\|'
        if ($cols.Count -ge 5) {
            $parentCell = $cols[4]
            if ($parentCell -match '\[CROSS-CUTTING\]') {
                $archCrossCutting[$archId] = $true
            }
            $parents = @([regex]::Matches($parentCell, 'SYS-[0-9]{3}') |
                ForEach-Object { $_.Value })
            $archParents[$archId] = $parents
        }
    }
}
$archIds = @($archIds | Sort-Object -Unique)

# Cross-cutting module list
$crossCuttingModules = @()
foreach ($arch in $archIds) {
    if ($archCrossCutting.Contains($arch)) {
        $crossCuttingModules += $arch
    }
}

# Mark SYS covered by ARCH parents
$sysCovered = @{}
foreach ($arch in $archIds) {
    if ($archParents.Contains($arch)) {
        foreach ($p in $archParents[$arch]) {
            $sysCovered[$p] = $true
        }
    }
}

# ITP/ITS IDs from integration-test.md (if exists)
$itpIds = @()
$itsIds = @()
if (-not $PartialMode) {
    $testContent = Get-Content -Raw $IntegrationTest
    $itpIds = @([regex]::Matches($testContent, 'ITP-[0-9]{3}-[A-Z]') |
        ForEach-Object { $_.Value } | Sort-Object -Unique)
    $itsIds = @([regex]::Matches($testContent, 'ITS-[0-9]{3}-[A-Z][0-9]+') |
        ForEach-Object { $_.Value } | Sort-Object -Unique)
}

$totalSys = $sysIds.Count
$totalArch = $archIds.Count
$totalCrossCutting = $crossCuttingModules.Count
$totalItps = $itpIds.Count
$totalItss = $itsIds.Count

# ---- Pass 2: Cross-reference ----

function Get-ArchBaseKey($id) { $id -replace '^ARCH-', '' }
function Get-ItpBaseKey($id) { ($id -replace '^ITP-', '') -replace '-[A-Z]$', '' }
function Get-ItpFullKey($id) { $id -replace '^ITP-', '' }
function Get-ItsFullKey($id) { $id -replace '^ITS-', '' }

# Forward coverage: every SYS has at least one ARCH
$sysWithoutArch = @()
foreach ($sys in $sysIds) {
    if (-not $sysCovered.Contains($sys)) {
        $sysWithoutArch += $sys
    }
}

# Backward coverage: every ARCH has at least one ITP (skip if partial)
$archWithoutItp = @()
if (-not $PartialMode) {
    foreach ($arch in $archIds) {
        $archKey = Get-ArchBaseKey $arch
        $hasItp = $false
        foreach ($itp in $itpIds) {
            $itpKey = Get-ItpBaseKey $itp
            if ($archKey -eq $itpKey) {
                $hasItp = $true
                break
            }
        }
        if (-not $hasItp) {
            $archWithoutItp += $arch
        }
    }
}

# ITP->ITS coverage (skip if partial)
$itpsWithoutIts = @()
if (-not $PartialMode) {
    foreach ($itp in $itpIds) {
        $itpKey = Get-ItpFullKey $itp
        $hasIts = $false
        foreach ($its in $itsIds) {
            $itsKey = Get-ItsFullKey $its
            if ($itsKey.StartsWith($itpKey)) {
                $hasIts = $true
                break
            }
        }
        if (-not $hasIts) {
            $itpsWithoutIts += $itp
        }
    }
}

# Orphaned ARCH: referencing non-existent SYS (skip cross-cutting)
$orphanedArch = @()
foreach ($arch in $archIds) {
    if ($archCrossCutting.Contains($arch)) { continue }
    if ($archParents.Contains($arch)) {
        foreach ($parent in $archParents[$arch]) {
            if ($parent -notin $sysIds) {
                $orphanedArch += "$arch references unknown $parent"
                break
            }
        }
    }
}

# Orphaned ITP: referencing non-existent ARCH (skip if partial)
$orphanedItps = @()
if (-not $PartialMode) {
    foreach ($itp in $itpIds) {
        $itpKey = Get-ItpBaseKey $itp
        $hasArch = $false
        foreach ($arch in $archIds) {
            $archKey = Get-ArchBaseKey $arch
            if ($itpKey -eq $archKey) {
                $hasArch = $true
                break
            }
        }
        if (-not $hasArch) {
            $orphanedItps += $itp
        }
    }
}

# ---- Calculate coverage ----

$sysCoveredCount = $totalSys - $sysWithoutArch.Count
$archCoveredCount = $totalArch - $archWithoutItp.Count
$itpsCoveredCount = $totalItps - $itpsWithoutIts.Count

if ($totalSys -gt 0) { $sysToArchCoveragePct = [math]::Floor($sysCoveredCount * 100 / $totalSys) }
else { $sysToArchCoveragePct = 0 }

if (-not $PartialMode -and $totalArch -gt 0) { $archToItpCoveragePct = [math]::Floor($archCoveredCount * 100 / $totalArch) }
else { $archToItpCoveragePct = 0 }

if (-not $PartialMode -and $totalItps -gt 0) { $itpToItsCoveragePct = [math]::Floor($itpsCoveredCount * 100 / $totalItps) }
else { $itpToItsCoveragePct = 0 }

$hasGaps = ($sysWithoutArch.Count -gt 0) -or ($archWithoutItp.Count -gt 0) -or
           ($itpsWithoutIts.Count -gt 0) -or ($orphanedArch.Count -gt 0) -or
           ($orphanedItps.Count -gt 0)

# ---- Output ----

if ($Json) {
    $output = [ordered]@{
        total_sys                = $totalSys
        total_arch               = $totalArch
        total_cross_cutting      = $totalCrossCutting
        total_itps               = $totalItps
        total_itss               = $totalItss
        sys_covered              = $sysCoveredCount
        arch_covered             = $archCoveredCount
        itps_covered             = $itpsCoveredCount
        sys_to_arch_coverage_pct = $sysToArchCoveragePct
        arch_to_itp_coverage_pct = $archToItpCoveragePct
        itp_to_its_coverage_pct  = $itpToItsCoveragePct
        has_gaps                 = $hasGaps
        partial_mode             = $PartialMode
        sys_without_arch         = $sysWithoutArch
        arch_without_itp         = $archWithoutItp
        itps_without_its         = $itpsWithoutIts
        orphaned_arch            = $orphanedArch
        orphaned_itps            = $orphanedItps
        cross_cutting_modules    = $crossCuttingModules
    }
    $output | ConvertTo-Json -Compress
} else {
    Write-Output '=== Architecture-Level Coverage Validation ==='
    Write-Output ''
    Write-Output "Totals: $totalSys SYS | $totalArch ARCH ($totalCrossCutting cross-cutting) | $totalItps ITPs | $totalItss ITSs"
    Write-Output "SYS -> ARCH coverage: $sysCoveredCount/$totalSys ($sysToArchCoveragePct%)"
    if ($PartialMode) {
        Write-Output 'ARCH -> ITP coverage: SKIPPED (integration-test.md not found)'
        Write-Output 'ITP -> ITS coverage: SKIPPED'
    } else {
        Write-Output "ARCH -> ITP coverage: $archCoveredCount/$totalArch ($archToItpCoveragePct%)"
        Write-Output "ITP -> ITS coverage: $itpsCoveredCount/$totalItps ($itpToItsCoveragePct%)"
    }
    Write-Output ''

    if ($sysWithoutArch.Count -gt 0) {
        Write-Output 'System components WITHOUT architecture modules:'
        foreach ($sys in $sysWithoutArch) { Write-Output "   - $sys" }
    }

    if ($archWithoutItp.Count -gt 0) {
        Write-Output 'Architecture modules WITHOUT integration tests:'
        foreach ($arch in $archWithoutItp) { Write-Output "   - $arch" }
    }

    if ($itpsWithoutIts.Count -gt 0) {
        Write-Output 'Integration test procedures WITHOUT scenarios:'
        foreach ($itp in $itpsWithoutIts) { Write-Output "   - $itp" }
    }

    if ($orphanedArch.Count -gt 0) {
        Write-Output 'Orphaned architecture modules (referencing non-existent SYS):'
        foreach ($msg in $orphanedArch) { Write-Output "   - $msg" }
    }

    if ($orphanedItps.Count -gt 0) {
        Write-Output 'Orphaned integration tests (referencing non-existent ARCH):'
        foreach ($itp in $orphanedItps) { Write-Output "   - $itp" }
    }

    if ($crossCuttingModules.Count -gt 0) {
        Write-Output 'Cross-cutting modules (no SYS parent required):'
        foreach ($arch in $crossCuttingModules) { Write-Output "   - $arch [CROSS-CUTTING]" }
    }

    if (-not $hasGaps) {
        Write-Output 'Full architecture-level coverage — all system components decomposed, all modules tested.'
    }
}

if ($hasGaps) { exit 1 } else { exit 0 }
