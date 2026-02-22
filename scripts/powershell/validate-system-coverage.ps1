<#
.SYNOPSIS
    Deterministic coverage validation for system-level V-Model artifacts.

.DESCRIPTION
    Parses requirements.md, system-design.md, and system-test.md using regex
    to extract REQ-NNN, SYS-NNN, STP-NNN-X, and STS-NNN-X# IDs.
    Cross-references them to verify bidirectional coverage.

    Supports partial validation: when system-test.md is absent, validates
    forward coverage (REQ->SYS) only and gracefully skips SYS->STP->STS checks.

.PARAMETER VModelDir
    Path to the v-model directory containing requirements.md, system-design.md,
    and system-test.md.

.PARAMETER Json
    Output in JSON format (for AI consumption).

.EXAMPLE
    ./validate-system-coverage.ps1 ./specs/001-feature/v-model
    ./validate-system-coverage.ps1 -Json ./specs/001-feature/v-model

.NOTES
    Exit code 0 = full coverage (or forward-only coverage in partial mode), 1 = gaps found.
#>

[CmdletBinding()]
param(
    [switch]$Json,
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$VModelDir
)

$ErrorActionPreference = 'Stop'

$Requirements = Join-Path $VModelDir 'requirements.md'
$SystemDesign = Join-Path $VModelDir 'system-design.md'
$SystemTest = Join-Path $VModelDir 'system-test.md'

if (-not (Test-Path $Requirements)) {
    Write-Error "ERROR: requirements.md not found in $VModelDir"
    exit 1
}

if (-not (Test-Path $SystemDesign)) {
    Write-Error "ERROR: system-design.md not found in $VModelDir"
    exit 1
}

$PartialMode = $false
if (-not (Test-Path $SystemTest)) {
    $PartialMode = $true
}

# ---- Pass 1: Extract IDs ----

$reqContent = (Get-Content -Raw $Requirements) ?? ''
$designContent = (Get-Content -Raw $SystemDesign) ?? ''

$reqIds = @([regex]::Matches($reqContent, 'REQ-([A-Z]+-)?[0-9]{3}') |
    ForEach-Object { $_.Value } | Sort-Object -Unique)
$sysIds = @([regex]::Matches($designContent, 'SYS-[0-9]{3}') |
    ForEach-Object { $_.Value } | Sort-Object -Unique)

# STP and STS IDs from system-test.md (only if not in partial mode)
$stpIds = @()
$stsIds = @()
if (-not $PartialMode) {
    $testContent = Get-Content -Raw $SystemTest
    $stpIds = @([regex]::Matches($testContent, 'STP-[0-9]{3}-[A-Z]') |
        ForEach-Object { $_.Value } | Sort-Object -Unique)
    $stsIds = @([regex]::Matches($testContent, 'STS-[0-9]{3}-[A-Z][0-9]+') |
        ForEach-Object { $_.Value } | Sort-Object -Unique)
}

$totalReqs = $reqIds.Count
$totalSys = $sysIds.Count
$totalStps = $stpIds.Count
$totalStss = $stsIds.Count

# ---- Pass 2: Build parent REQ mapping from Decomposition View ----

$sysParents = @{}
$reqCovered = @{}

foreach ($sys in $sysIds) {
    $sysEscaped = [regex]::Escape($sys)
    $rows = $designContent -split "`n" | Where-Object { $_ -match "^\|.*$sysEscaped" }
    foreach ($row in $rows) {
        $cols = $row -split '\|'
        if ($cols.Count -ge 5) {
            $parentCell = $cols[4]
            $parents = @([regex]::Matches($parentCell, 'REQ-([A-Z]+-)?[0-9]{3}') |
                ForEach-Object { $_.Value })
            $sysParents[$sys] = $parents
            foreach ($p in $parents) {
                $reqCovered[$p] = $true
            }
        }
    }
}

# ---- Pass 3: Cross-reference ----

# Forward: every REQ has at least one SYS
$reqsWithoutSys = @()
foreach ($req in $reqIds) {
    if (-not $reqCovered.Contains($req)) {
        $reqsWithoutSys += $req
    }
}

# Backward: every SYS has at least one STP (skip in partial mode)
function Get-SysBaseKey($id) { $id -replace '^SYS-', '' }
function Get-StpBaseKey($id) { ($id -replace '^STP-', '') -replace '-[A-Z]$', '' }
function Get-StpFullKey($id) { $id -replace '^STP-', '' }
function Get-StsFullKey($id) { $id -replace '^STS-', '' }

$sysWithoutStp = @()
$stpsWithoutSts = @()
$orphanedStps = @()

if (-not $PartialMode) {
    foreach ($sys in $sysIds) {
        $sysKey = Get-SysBaseKey $sys
        $hasStp = $false
        foreach ($stp in $stpIds) {
            $stpKey = Get-StpBaseKey $stp
            if ($sysKey -eq $stpKey) {
                $hasStp = $true
                break
            }
        }
        if (-not $hasStp) {
            $sysWithoutStp += $sys
        }
    }

    # STP→STS coverage
    foreach ($stp in $stpIds) {
        $stpKey = Get-StpFullKey $stp
        $hasSts = $false
        foreach ($sts in $stsIds) {
            $stsKey = Get-StsFullKey $sts
            if ($stsKey.StartsWith($stpKey)) {
                $hasSts = $true
                break
            }
        }
        if (-not $hasSts) {
            $stpsWithoutSts += $stp
        }
    }

    # Orphaned STP (referencing non-existent SYS)
    foreach ($stp in $stpIds) {
        $stpKey = Get-StpBaseKey $stp
        $hasSys = $false
        foreach ($sys in $sysIds) {
            $sysKey = Get-SysBaseKey $sys
            if ($stpKey -eq $sysKey) {
                $hasSys = $true
                break
            }
        }
        if (-not $hasSys) {
            $orphanedStps += $stp
        }
    }
}
# Orphaned SYS (parent REQ not in requirements.md)
$orphanedSys = @()
foreach ($sys in $sysIds) {
    if ($sysParents.Contains($sys)) {
        foreach ($parent in $sysParents[$sys]) {
            if ($parent -notin $reqIds) {
                $orphanedSys += "$sys references unknown $parent"
                break
            }
        }
    }
}

# ---- Calculate coverage ----

$reqsCoveredCount = $totalReqs - $reqsWithoutSys.Count
$sysCoveredCount = $totalSys - $sysWithoutStp.Count
$stpsCoveredCount = $totalStps - $stpsWithoutSts.Count

if ($totalReqs -gt 0) { $reqCoveragePct = [math]::Floor($reqsCoveredCount * 100 / $totalReqs) }
else { $reqCoveragePct = 0 }

if ($totalSys -gt 0) { $sysCoveragePct = [math]::Floor($sysCoveredCount * 100 / $totalSys) }
else { $sysCoveragePct = 0 }

if ($totalStps -gt 0) { $stpCoveragePct = [math]::Floor($stpsCoveredCount * 100 / $totalStps) }
else { $stpCoveragePct = 0 }

$hasGaps = ($reqsWithoutSys.Count -gt 0) -or ($orphanedSys.Count -gt 0)
if (-not $PartialMode) {
    if (($sysWithoutStp.Count -gt 0) -or ($stpsWithoutSts.Count -gt 0) -or
        ($orphanedStps.Count -gt 0)) {
        $hasGaps = $true
    }
}

# ---- Output ----

if ($Json) {
    $output = [ordered]@{
        partial_mode          = $PartialMode
        total_reqs            = $totalReqs
        total_sys             = $totalSys
        total_stps            = $totalStps
        total_stss            = $totalStss
        reqs_covered          = $reqsCoveredCount
        sys_covered           = $sysCoveredCount
        stps_covered          = $stpsCoveredCount
        req_to_sys_coverage_pct = $reqCoveragePct
        sys_to_stp_coverage_pct = $sysCoveragePct
        stp_to_sts_coverage_pct = $stpCoveragePct
        has_gaps              = $hasGaps
        reqs_without_sys      = $reqsWithoutSys
        sys_without_stp       = $sysWithoutStp
        stps_without_sts      = $stpsWithoutSts
        orphaned_sys          = $orphanedSys
        orphaned_stps         = $orphanedStps
    }
    $output | ConvertTo-Json -Compress
} else {
    Write-Output '=== System-Level Coverage Validation ==='
    if ($PartialMode) {
        Write-Output '(Partial mode - system-test.md not found, validating forward coverage only)'
    }
    Write-Output ''
    Write-Output "Totals: $totalReqs REQs | $totalSys SYS | $totalStps STPs | $totalStss STSs"
    Write-Output "REQ -> SYS coverage: $reqsCoveredCount/$totalReqs ($reqCoveragePct%)"
    if (-not $PartialMode) {
        Write-Output "SYS -> STP coverage: $sysCoveredCount/$totalSys ($sysCoveragePct%)"
        Write-Output "STP -> STS coverage: $stpsCoveredCount/$totalStps ($stpCoveragePct%)"
    }
    Write-Output ''

    if ($reqsWithoutSys.Count -gt 0) {
        Write-Output 'Requirements WITHOUT system components:'
        foreach ($req in $reqsWithoutSys) { Write-Output "   - $req" }
    }

    if (-not $PartialMode) {
        if ($sysWithoutStp.Count -gt 0) {
            Write-Output 'System components WITHOUT test cases:'
            foreach ($sys in $sysWithoutStp) { Write-Output "   - $sys" }
        }

        if ($stpsWithoutSts.Count -gt 0) {
            Write-Output 'Test cases WITHOUT scenarios:'
            foreach ($stp in $stpsWithoutSts) { Write-Output "   - $stp" }
        }

        if ($orphanedStps.Count -gt 0) {
            Write-Output 'Orphaned test cases (referencing non-existent SYS):'
            foreach ($stp in $orphanedStps) { Write-Output "   - $stp" }
        }
    }

    if ($orphanedSys.Count -gt 0) {
        Write-Output 'Orphaned system components (referencing non-existent REQ):'
        foreach ($msg in $orphanedSys) { Write-Output "   - $msg" }
    }

    if (-not $hasGaps) {
        if ($PartialMode) {
            Write-Output 'Forward coverage complete - all requirements decomposed into system components.'
            Write-Output '   (SYS->STP->STS validation skipped - generate system-test.md for full validation)'
        } else {
            Write-Output 'Full system-level coverage - all requirements decomposed, all components tested.'
        }
    }
}

if ($hasGaps) { exit 1 } else { exit 0 }
