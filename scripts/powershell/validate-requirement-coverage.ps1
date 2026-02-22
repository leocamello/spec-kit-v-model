<#
.SYNOPSIS
    Deterministic coverage validation for V-Model artifacts.

.DESCRIPTION
    Parses requirements.md and acceptance-plan.md using regex to extract
    REQ-NNN, ATP-NNN-X, and SCN-NNN-X# IDs. Cross-references them to
    verify 100% coverage at each tier.

.PARAMETER VModelDir
    Path to the v-model directory containing requirements.md and acceptance-plan.md.

.PARAMETER Json
    Output in JSON format (for AI consumption).

.EXAMPLE
    ./validate-requirement-coverage.ps1 ./specs/001-feature/v-model
    ./validate-requirement-coverage.ps1 -Json ./specs/001-feature/v-model

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

# Extract all IDs using regex
$reqContent = Get-Content -Raw $Requirements
$accContent = Get-Content -Raw $Acceptance

# REQ IDs: REQ-NNN, REQ-NF-NNN, REQ-IF-NNN, REQ-CN-NNN
$reqIds = [regex]::Matches($reqContent, 'REQ-([A-Z]+-)?[0-9]{3}') |
    ForEach-Object { $_.Value } | Sort-Object -Unique

# ATP IDs: ATP-{CAT?-}NNN-X (with optional category prefix)
$atpIds = [regex]::Matches($accContent, 'ATP-([A-Z]+-)?[0-9]{3}-[A-Z]') |
    ForEach-Object { $_.Value } | Sort-Object -Unique

# SCN IDs: SCN-{CAT?-}NNN-X# (with optional category prefix)
$scnIds = [regex]::Matches($accContent, 'SCN-([A-Z]+-)?[0-9]{3}-[A-Z][0-9]+') |
    ForEach-Object { $_.Value } | Sort-Object -Unique

# Ensure arrays
$reqIds = @($reqIds)
$atpIds = @($atpIds)
$scnIds = @($scnIds)

$totalReqs = $reqIds.Count
$totalAtps = $atpIds.Count
$totalScns = $scnIds.Count

# Helper: extract base key for matching
# REQ-001 -> 001, REQ-NF-001 -> NF-001
function Get-ReqBaseKey($id) { $id -replace '^REQ-', '' }
# ATP-001-A -> 001, ATP-NF-001-A -> NF-001
function Get-AtpBaseKey($id) { ($id -replace '^ATP-', '') -replace '-[A-Z]$', '' }

# Check Tier 1: Every REQ has at least one ATP
$reqsWithoutAtp = @()
foreach ($req in $reqIds) {
    $reqKey = Get-ReqBaseKey $req
    $hasAtp = $false
    foreach ($atp in $atpIds) {
        $atpKey = Get-AtpBaseKey $atp
        if ($reqKey -eq $atpKey) {
            $hasAtp = $true
            break
        }
    }
    if (-not $hasAtp) {
        $reqsWithoutAtp += $req
    }
}

# Check Tier 2: Every ATP has at least one SCN
$atpsWithoutScn = @()
foreach ($atp in $atpIds) {
    $atpSuffix = $atp -replace '^ATP-', ''  # 001-A
    $hasScn = $false
    foreach ($scn in $scnIds) {
        $scnSuffix = $scn -replace '^SCN-', ''  # 001-A1
        if ($scnSuffix.StartsWith($atpSuffix)) {
            $hasScn = $true
            break
        }
    }
    if (-not $hasScn) {
        $atpsWithoutScn += $atp
    }
}

# Check for orphaned ATPs (ATP referencing non-existent REQ)
$orphanedAtps = @()
foreach ($atp in $atpIds) {
    $atpKey = Get-AtpBaseKey $atp
    $hasReq = $false
    foreach ($req in $reqIds) {
        $reqKey = Get-ReqBaseKey $req
        if ($atpKey -eq $reqKey) {
            $hasReq = $true
            break
        }
    }
    if (-not $hasReq) {
        $orphanedAtps += $atp
    }
}

# Calculate coverage
$reqsCovered = $totalReqs - $reqsWithoutAtp.Count
$atpsCovered = $totalAtps - $atpsWithoutScn.Count

if ($totalReqs -gt 0) {
    $reqCoverage = [math]::Floor($reqsCovered * 100 / $totalReqs)
} else {
    $reqCoverage = 0
}

if ($totalAtps -gt 0) {
    $atpCoverage = [math]::Floor($atpsCovered * 100 / $totalAtps)
} else {
    $atpCoverage = 0
}

$hasGaps = ($reqsWithoutAtp.Count -gt 0) -or ($atpsWithoutScn.Count -gt 0)

# Output results
if ($Json) {
    $output = [ordered]@{
        total_reqs       = $totalReqs
        total_atps       = $totalAtps
        total_scns       = $totalScns
        reqs_covered     = $reqsCovered
        atps_covered     = $atpsCovered
        req_coverage_pct = $reqCoverage
        atp_coverage_pct = $atpCoverage
        has_gaps         = $hasGaps
        reqs_without_atp = $reqsWithoutAtp
        atps_without_scn = $atpsWithoutScn
        orphaned_atps    = $orphanedAtps
    }
    $output | ConvertTo-Json -Compress
} else {
    Write-Output '=== V-Model Coverage Validation ==='
    Write-Output ''
    Write-Output "Totals: $totalReqs REQs | $totalAtps ATPs | $totalScns SCNs"
    Write-Output "REQ → ATP coverage: $reqsCovered/$totalReqs ($reqCoverage%)"
    Write-Output "ATP → SCN coverage: $atpsCovered/$totalAtps ($atpCoverage%)"
    Write-Output ''

    if ($reqsWithoutAtp.Count -gt 0) {
        Write-Output '❌ Requirements WITHOUT test cases:'
        foreach ($req in $reqsWithoutAtp) {
            Write-Output "   - $req"
        }
    }

    if ($atpsWithoutScn.Count -gt 0) {
        Write-Output '❌ Test cases WITHOUT scenarios:'
        foreach ($atp in $atpsWithoutScn) {
            Write-Output "   - $atp"
        }
    }

    if ($orphanedAtps.Count -gt 0) {
        Write-Output '⚠️  Orphaned test cases (no matching requirement):'
        foreach ($atp in $orphanedAtps) {
            Write-Output "   - $atp"
        }
    }

    if (-not $hasGaps) {
        Write-Output '✅ Full coverage — all requirements have test cases and scenarios.'
    }
}

# Exit with non-zero if gaps exist
if ($hasGaps) { exit 1 } else { exit 0 }
