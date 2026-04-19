<#
.SYNOPSIS
    Deterministic coverage validation for hazard analysis V-Model artifacts.

.DESCRIPTION
    Parses system-design.md and hazard-analysis.md using regex to validate
    three independent coverage dimensions:
      1. Forward coverage: every SYS-NNN has at least one HAZ-NNN entry
      2. Backward coverage: every HAZ mitigation references a valid REQ/SYS
      3. State consistency: every operational state in HAZ exists in system-design

    Supports partial validation when not all artifacts exist.

.PARAMETER VModelDir
    Path to the v-model directory containing system-design.md and hazard-analysis.md.

.PARAMETER Json
    Output in JSON format (for AI consumption).

.PARAMETER Partial
    Skip backward checks if requirements.md is absent.

.EXAMPLE
    ./validate-hazard-coverage.ps1 ./specs/005a/v-model
    ./validate-hazard-coverage.ps1 -Json ./specs/005a/v-model
    ./validate-hazard-coverage.ps1 -Json -Partial ./specs/005a/v-model

.NOTES
    Exit code 0 = all applicable checks pass, 1 = gaps found.
#>

[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$Partial,
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$VModelDir
)

$ErrorActionPreference = 'Stop'

$systemDesignPath = Join-Path $VModelDir 'system-design.md'
$hazardAnalysisPath = Join-Path $VModelDir 'hazard-analysis.md'
$requirementsPath = Join-Path $VModelDir 'requirements.md'

if (-not (Test-Path $systemDesignPath)) {
    Write-Error "ERROR: system-design.md not found in $VModelDir"
    exit 1
}

if (-not (Test-Path $hazardAnalysisPath)) {
    Write-Error "ERROR: hazard-analysis.md not found in $VModelDir"
    exit 1
}

$systemDesign = Get-Content -Path $systemDesignPath -Raw
$hazardAnalysis = Get-Content -Path $hazardAnalysisPath -Raw

# ---- Pass 1: Extract IDs ----

$sysIds = @([regex]::Matches($systemDesign, 'SYS-[0-9]{3}') | ForEach-Object { $_.Value } | Sort-Object -Unique)
$hazIds = @([regex]::Matches($hazardAnalysis, 'HAZ-[0-9]{3}') | ForEach-Object { $_.Value } | Sort-Object -Unique)

$totalSys = $sysIds.Count
$totalHaz = $hazIds.Count

# ---- Pass 2: Forward Coverage (SYS -> HAZ) ----

$hazSysRefs = @([regex]::Matches($hazardAnalysis, 'SYS-[0-9]{3}') | ForEach-Object { $_.Value } | Sort-Object -Unique)

$forwardGaps = @()
$forwardCovered = 0
foreach ($sys in $sysIds) {
    if ($hazSysRefs -contains $sys) {
        $forwardCovered++
    } else {
        $forwardGaps += $sys
    }
}

$forwardPct = if ($totalSys -gt 0) { [math]::Floor($forwardCovered * 100 / $totalSys) } else { 0 }

# ---- Pass 3: Backward Coverage (HAZ mitigation -> REQ/SYS) ----

$backwardGaps = @()
$backwardCovered = 0
$backwardTotal = 0
$backwardMode = 'full'

$hasRequirements = Test-Path $requirementsPath
if ($hasRequirements -or (-not $Partial)) {
    # Collect valid IDs
    $validIds = @{}
    foreach ($sys in $sysIds) { $validIds[$sys] = $true }
    if ($hasRequirements) {
        $requirements = Get-Content -Path $requirementsPath -Raw
        # Exclude deprecated requirements (lines where [DEPRECATED starts a table cell)
        $activeReqContent = ($requirements -split "`n" | Where-Object { $_ -notmatch '\| \[DEPRECATED' }) -join "`n"
        $reqIds = @([regex]::Matches($activeReqContent, 'REQ-(?:[A-Z]+-)?[0-9]{3}') | ForEach-Object { $_.Value } | Sort-Object -Unique)
        foreach ($req in $reqIds) { $validIds[$req] = $true }
    }

    # Parse FMEA table rows
    $hazardLines = $hazardAnalysis -split "`n"
    foreach ($haz in $hazIds) {
        $backwardTotal++
        $escapedHaz = [regex]::Escape($haz)
        $row = $hazardLines | Where-Object { $_ -match "^\|\s*$escapedHaz\s*\|" } | Select-Object -First 1
        if ($row) {
            $cols = $row -split '\|'
            # Mitigation is column 10 (index 10 in split result since leading | creates empty [0])
            $mitCell = if ($cols.Count -ge 10) { $cols[9] } else { '' }
            $mitRefs = @([regex]::Matches($mitCell, '(REQ-(?:[A-Z]+-)?[0-9]{3}|SYS-[0-9]{3})') | ForEach-Object { $_.Value })
            if ($mitRefs.Count -eq 0) {
                $backwardGaps += "$haz`: no mitigation references found"
            } else {
                $hasValid = $false
                foreach ($ref in $mitRefs) {
                    if ($validIds.ContainsKey($ref)) {
                        $hasValid = $true
                        break
                    }
                }
                if ($hasValid) {
                    $backwardCovered++
                } else {
                    $backwardGaps += "$haz`: mitigation references do not exist in source documents"
                }
            }
        }
    }
} else {
    $backwardMode = 'skipped'
}

$backwardPct = if ($backwardTotal -gt 0) { [math]::Floor($backwardCovered * 100 / $backwardTotal) } else { 0 }

# ---- Pass 4: State Consistency ----

# Extract defined states from system-design.md
$definedStates = @()
$stateSection = ''
$inStateSection = $false
foreach ($line in ($systemDesign -split "`n")) {
    if ($line -match '[Oo]perational\s+[Ss]tates|[Oo]perating\s+[Mm]odes|[Ss]ystem\s+[Ss]tates') {
        $inStateSection = $true
        continue
    }
    if ($inStateSection -and $line -match '^## ') {
        break
    }
    if ($inStateSection) {
        if ($line -match '^\|\s*([A-Z][A-Z_]+)\s*\|') {
            $state = $Matches[1]
            if ($state -ne 'STATE' -and $state -ne 'STATE_NAME' -and $state -ne 'NAME') {
                $definedStates += $state
            }
        }
    }
}

$implicitNormal = $false
if ($definedStates.Count -eq 0) {
    $definedStates = @('NORMAL')
    $implicitNormal = $true
}
$definedStates += 'ALL'

# Extract operational states from HAZ FMEA table (column 5 in split)
$hazStates = @()
$stateWarnings = @()
foreach ($line in ($hazardAnalysis -split "`n")) {
    if ($line -match '^\|\s*HAZ-[0-9]{3}\s*\|') {
        $cols = $line -split '\|'
        if ($cols.Count -ge 6) {
            $state = $cols[4].Trim()
            if ($state) { $hazStates += $state }
        }
    }
}

foreach ($hs in ($hazStates | Sort-Object -Unique)) {
    if ($definedStates -notcontains $hs) {
        $stateWarnings += $hs
    }
}

$stateConsistent = $stateWarnings.Count -eq 0

# ---- Determine overall result ----

$hasGaps = $false
if ($forwardGaps.Count -gt 0) { $hasGaps = $true }
if ($backwardGaps.Count -gt 0) { $hasGaps = $true }
if (-not $stateConsistent) { $hasGaps = $true }

# ---- Output ----

function Format-JsonArray($arr) {
    if ($arr.Count -eq 0) { return '[]' }
    $items = ($arr | ForEach-Object { "`"$_`"" }) -join ', '
    return "[$items]"
}

if ($Json) {
    $output = @"
{
  "total_sys": $totalSys,
  "total_haz": $totalHaz,
  "forward_covered": $forwardCovered,
  "forward_coverage_pct": $forwardPct,
  "backward_covered": $backwardCovered,
  "backward_total": $backwardTotal,
  "backward_coverage_pct": $backwardPct,
  "backward_mode": "$backwardMode",
  "state_consistent": $($stateConsistent.ToString().ToLower()),
  "implicit_normal": $($implicitNormal.ToString().ToLower()),
  "has_gaps": $($hasGaps.ToString().ToLower()),
  "partial_mode": $($Partial.IsPresent.ToString().ToLower()),
  "forward_gaps": $(Format-JsonArray $forwardGaps),
  "backward_gaps": $(Format-JsonArray $backwardGaps),
  "state_warnings": $(Format-JsonArray $stateWarnings),
  "defined_states": $(Format-JsonArray $definedStates)
}
"@
    Write-Output $output
} else {
    Write-Output '=== Hazard Coverage Validation ==='
    if ($Partial) { Write-Output '(Partial mode — some checks may be skipped)' }
    Write-Output ''
    Write-Output "Totals: $totalSys SYS | $totalHaz HAZ"
    Write-Output ''

    Write-Output '── Forward Coverage (SYS → HAZ) ──'
    Write-Output "  Coverage: $forwardCovered/$totalSys ($forwardPct%)"
    if ($forwardGaps.Count -gt 0) {
        Write-Output '  ❌ System components WITHOUT hazard analysis:'
        foreach ($gap in $forwardGaps) {
            Write-Output "     - ${gap}: no hazard analysis mapping found"
        }
    } else {
        Write-Output '  ✅ All system components have hazard entries'
    }
    Write-Output ''

    if ($Partial -and (-not $hasRequirements)) {
        Write-Output '── Backward Coverage (HAZ → REQ/SYS) ──'
        Write-Output '  ⏩ Skipped (requirements.md not found, --partial mode)'
    } else {
        Write-Output '── Backward Coverage (HAZ → REQ/SYS) ──'
        Write-Output "  Coverage: $backwardCovered/$backwardTotal ($backwardPct%)"
        if ($backwardGaps.Count -gt 0) {
            Write-Output '  ❌ Hazards with broken mitigation references:'
            foreach ($gap in $backwardGaps) {
                Write-Output "     - $gap"
            }
        } else {
            Write-Output '  ✅ All hazard mitigations reference valid IDs'
        }
    }
    Write-Output ''

    Write-Output '── State Consistency ──'
    if ($implicitNormal) {
        Write-Output '  ⚠️  No operational states defined in system-design.md — using implicit NORMAL state'
    }
    if ($stateConsistent) {
        Write-Output '  ✅ All operational states in hazard entries are defined'
    } else {
        Write-Output '  ❌ Undefined operational states found in hazard entries:'
        foreach ($w in $stateWarnings) {
            Write-Output "     - $w"
        }
    }
    Write-Output ''

    if (-not $hasGaps) {
        Write-Output '✅ All hazard coverage checks passed.'
    } else {
        Write-Output '❌ Hazard coverage gaps detected — see details above.'
    }
}

if ($hasGaps) { exit 1 } else { exit 0 }
