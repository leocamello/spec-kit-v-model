<#
.SYNOPSIS
    Deterministic traceability matrix builder for V-Model artifacts.

.DESCRIPTION
    Parses requirements.md and acceptance-plan.md using regex to build
    Matrix A (Validation). If system-design.md and system-test.md exist,
    also builds Matrix B (Verification).

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
$SystemDesign = Join-Path $VModelDir 'system-design.md'
$SystemTest = Join-Path $VModelDir 'system-test.md'

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
$fullOutput += '## Matrix A — Validation (User View)'
$fullOutput += ''
$fullOutput += $matrixLines
$fullOutput += ''
$fullOutput += '### Matrix A Coverage'
$fullOutput += ''
$fullOutput += '| Metric | Value |'
$fullOutput += '|--------|-------|'
$fullOutput += "| **Total Requirements** | $totalReqs |"
$fullOutput += "| **Total Test Cases (ATP)** | $totalAtps |"
$fullOutput += "| **Total Scenarios (SCN)** | $totalScns |"
$fullOutput += "| **REQ -> ATP Coverage** | $reqsWithAtp/$totalReqs ($reqPct%) |"
$fullOutput += "| **ATP -> SCN Coverage** | $atpsWithScn/$totalAtps ($atpPct%) |"
$fullOutput += ''

# ---- Matrix B: Verification (if system-level artifacts exist) ----
$hasSystemLevel = (Test-Path $SystemDesign) -and (Test-Path $SystemTest)

if ($hasSystemLevel) {
    $designContent = Get-Content $SystemDesign
    $testContentLines = Get-Content $SystemTest
    $testRaw = Get-Content -Raw $SystemTest

    # Extract SYS from Decomposition View table rows
    $sysDescriptions = [ordered]@{}
    $sysNames = [ordered]@{}
    $sysParentReqs = [ordered]@{}
    foreach ($line in $designContent) {
        if ($line -match '\|\s*(SYS-[0-9]{3})\s*\|\s*([^|]+)\|\s*([^|]+)\|\s*([^|]+)') {
            $sid = $Matches[1]
            $sname = $Matches[2].Trim()
            $sdesc = $Matches[3].Trim()
            $sparents = $Matches[4].Trim()
            $sysDescriptions[$sid] = $sdesc
            $sysNames[$sid] = $sname
            $sysParentReqs[$sid] = $sparents
        }
    }

    # Extract STP sections
    $stpDescriptions = [ordered]@{}
    foreach ($line in $testContentLines) {
        if ($line -match 'Test Case:\s*(STP-[0-9]{3}-[A-Z])\s*\(([^)]+)\)') {
            $stpDescriptions[$Matches[1]] = $Matches[2]
        }
    }

    # Extract STP techniques
    $stpTechniques = @{}
    $currentStp = ''
    foreach ($line in $testContentLines) {
        if ($line -match 'Test Case:\s*(STP-[0-9]{3}-[A-Z])') {
            $currentStp = $Matches[1]
        } elseif ($currentStp -and $line -match '^\*\*Technique\*\*:\s*(.+)') {
            $stpTechniques[$currentStp] = $Matches[1].Trim()
            $currentStp = ''
        }
    }

    # Extract STS IDs
    $stsSystemIds = @([regex]::Matches($testRaw, 'STS-[0-9]{3}-[A-Z][0-9]+') |
        ForEach-Object { $_.Value } | Sort-Object -Unique)

    $sortedSys = @($sysDescriptions.Keys | Sort-Object)
    $sortedStp = @($stpDescriptions.Keys | Sort-Object)
    $totalSysCount = $sortedSys.Count
    $totalStpCount = $sortedStp.Count
    $totalStsCount = $stsSystemIds.Count

    function Get-SysBaseKeyB($id) { $id -replace '^SYS-', '' }
    function Get-StpBaseKeyB($id) { ($id -replace '^STP-', '') -replace '-[A-Z]$', '' }
    function Get-StpFullKeyB($id) { $id -replace '^STP-', '' }
    function Get-StsFullKeyB($id) { $id -replace '^STS-', '' }

    $reqsWithSys = 0

    $matrixBLines = @()
    $matrixBLines += '| Requirement ID | System Component (SYS) | Component Name | Test Case ID (STP) | Technique | Scenario ID (STS) | Status |'
    $matrixBLines += '|----------------|------------------------|----------------|--------------------|-----------|--------------------|--------|'

    foreach ($req in $reqIds) {
        $firstReqRow = $true
        $hasSys = $false

        foreach ($sys in $sortedSys) {
            $parents = $sysParentReqs[$sys]
            if ($parents -match "(^|,)\s*$([regex]::Escape($req))\s*(,|$)") {
                $hasSys = $true
                $sysKey = Get-SysBaseKeyB $sys
                $sname = $sysNames[$sys]
                $hasStp = $false

                foreach ($stp in $sortedStp) {
                    $stpKey = Get-StpBaseKeyB $stp
                    if ($stpKey -eq $sysKey) {
                        $hasStp = $true
                        $technique = if ($stpTechniques.ContainsKey($stp)) { $stpTechniques[$stp] } else { '—' }
                        $stpFKey = Get-StpFullKeyB $stp
                        $firstStpSts = $true

                        foreach ($sts in $stsSystemIds) {
                            $stsFKey = Get-StsFullKeyB $sts
                            if ($stsFKey.StartsWith($stpFKey)) {
                                if ($firstReqRow) {
                                    $matrixBLines += "| **$req** | $sys | $sname | $stp | $technique | $sts | ⬜ Untested |"
                                    $firstReqRow = $false
                                } else {
                                    $matrixBLines += "| | $sys | $sname | $stp | $technique | $sts | ⬜ Untested |"
                                }
                                $firstStpSts = $false
                            }
                        }

                        if ($firstStpSts) {
                            if ($firstReqRow) {
                                $matrixBLines += "| **$req** | $sys | $sname | $stp | $technique | ❌ MISSING | ⬜ Untested |"
                                $firstReqRow = $false
                            } else {
                                $matrixBLines += "| | $sys | $sname | $stp | $technique | ❌ MISSING | ⬜ Untested |"
                            }
                        }
                    }
                }
            }
        }

        if ($hasSys) {
            $reqsWithSys++
        } else {
            if ($firstReqRow) {
                $matrixBLines += "| **$req** | ❌ MISSING | — | — | — | — | ⬜ Untested |"
            }
        }
    }

    # Matrix B coverage metrics
    if ($totalReqs -gt 0) { $reqSysPct = [math]::Floor($reqsWithSys * 100 / $totalReqs) }
    else { $reqSysPct = 0 }

    $sysCovered = 0
    foreach ($sys in $sortedSys) {
        $sysKey = Get-SysBaseKeyB $sys
        foreach ($stp in $sortedStp) {
            $stpKey = Get-StpBaseKeyB $stp
            if ($stpKey -eq $sysKey) { $sysCovered++; break }
        }
    }

    if ($totalSysCount -gt 0) { $sysStpPct = [math]::Floor($sysCovered * 100 / $totalSysCount) }
    else { $sysStpPct = 0 }

    $fullOutput += '## Matrix B — Verification (Architectural View)'
    $fullOutput += ''
    $fullOutput += $matrixBLines
    $fullOutput += ''
    $fullOutput += '### Matrix B Coverage'
    $fullOutput += ''
    $fullOutput += '| Metric | Value |'
    $fullOutput += '|--------|-------|'
    $fullOutput += "| **Total System Components (SYS)** | $totalSysCount |"
    $fullOutput += "| **Total System Test Cases (STP)** | $totalStpCount |"
    $fullOutput += "| **Total System Scenarios (STS)** | $totalStsCount |"
    $fullOutput += "| **REQ -> SYS Coverage** | $reqsWithSys/$totalReqs ($reqSysPct%) |"
    $fullOutput += "| **SYS -> STP Coverage** | $sysCovered/$totalSysCount ($sysStpPct%) |"
    $fullOutput += ''
}

$fullOutput += '## Gap Analysis'
$fullOutput += ''
$fullOutput += '### Uncovered Requirements (REQ without ATP)'
$fullOutput += ''
if ($reqsWithoutAtp.Count -eq 0) {
    $fullOutput += 'None — full coverage.'
} else {
    foreach ($req in $reqsWithoutAtp) { $fullOutput += "- $req" }
}
$fullOutput += ''
$fullOutput += '### Orphaned Test Cases (ATP without valid REQ)'
$fullOutput += ''
if ($orphanedAtps.Count -eq 0) {
    $fullOutput += 'None — all tests trace to requirements.'
} else {
    foreach ($atp in $orphanedAtps) { $fullOutput += "- $atp" }
}

if ($hasSystemLevel) {
    # System-level gaps
    $sysReqsWithoutSys = @()
    foreach ($req in $reqIds) {
        $found = $false
        foreach ($sys in $sortedSys) {
            $parents = $sysParentReqs[$sys]
            if ($parents -match "(^|,)\s*$([regex]::Escape($req))\s*(,|$)") {
                $found = $true
                break
            }
        }
        if (-not $found) { $sysReqsWithoutSys += $req }
    }

    $orphanedStps = @()
    foreach ($stp in $sortedStp) {
        $stpKey = Get-StpBaseKeyB $stp
        $hasSysB = $false
        foreach ($sys in $sortedSys) {
            $sysKey = Get-SysBaseKeyB $sys
            if ($stpKey -eq $sysKey) { $hasSysB = $true; break }
        }
        if (-not $hasSysB) { $orphanedStps += $stp }
    }

    $fullOutput += ''
    $fullOutput += '### Uncovered Requirements — System Level (REQ without SYS)'
    $fullOutput += ''
    if ($sysReqsWithoutSys.Count -eq 0) {
        $fullOutput += 'None — full coverage.'
    } else {
        foreach ($req in $sysReqsWithoutSys) { $fullOutput += "- $req" }
    }
    $fullOutput += ''
    $fullOutput += '### Orphaned System Test Cases (STP without valid SYS)'
    $fullOutput += ''
    if ($orphanedStps.Count -eq 0) {
        $fullOutput += 'None — all system tests trace to components.'
    } else {
        foreach ($stp in $orphanedStps) { $fullOutput += "- $stp" }
    }
}

$fullOutput += ''
$fullOutput += '## Audit Notes'
$fullOutput += ''
$fullOutput += '- **Matrix generated by**: `build-matrix.ps1` (deterministic regex parser)'
$sourceDocs = '`requirements.md`, `acceptance-plan.md`'
if ($hasSystemLevel) { $sourceDocs += ', `system-design.md`, `system-test.md`' }
$fullOutput += "- **Source documents**: $sourceDocs"
$fullOutput += "- **Last validated**: $date"

if ($Output) {
    $fullOutput | Out-File -FilePath $Output -Encoding utf8
    Write-Output "Traceability matrix written to $Output"
} else {
    $fullOutput | ForEach-Object { Write-Output $_ }
}
