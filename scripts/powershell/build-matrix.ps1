<#
.SYNOPSIS
    Deterministic traceability matrix builder for V-Model artifacts.

.DESCRIPTION
    Parses requirements.md and acceptance-plan.md using regex to build
    Matrix A (Validation). If system-design.md and system-test.md exist,
    also builds Matrix B (Verification). If architecture-design.md and
    integration-test.md exist, also builds Matrix C (Integration Verification).

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
$ArchDesign = Join-Path $VModelDir 'architecture-design.md'
$IntegrationTest = Join-Path $VModelDir 'integration-test.md'

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

    # Extract SYS from Decomposition View table rows only
    # (other views also have SYS-NNN in tables — must not overwrite parent reqs)
    $sysDescriptions = [ordered]@{}
    $sysNames = [ordered]@{}
    $sysParentReqs = [ordered]@{}
    $inDecomposition = $false
    foreach ($line in $designContent) {
        if ($line -match '^##\s+Decomposition') {
            $inDecomposition = $true
            continue
        }
        if ($inDecomposition -and $line -match '^##\s') {
            break
        }
        if ($inDecomposition -and $line -match '\|\s*(SYS-[0-9]{3})\s*\|\s*([^|]+)\|\s*([^|]+)\|\s*([^|]+)') {
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
                        $technique = if ($stpTechniques.Contains($stp)) { $stpTechniques[$stp] } else { '—' }
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

# ---- Matrix C: Integration Verification (if architecture-level artifacts exist) ----
$hasArchLevel = (Test-Path $ArchDesign) -and (Test-Path $IntegrationTest)

if ($hasArchLevel) {
    $archDesignContent = Get-Content $ArchDesign
    $itContentLines = Get-Content $IntegrationTest
    $itRaw = Get-Content -Raw $IntegrationTest

    # Extract ARCH IDs from Logical View only (section-scoped)
    $archNames = [ordered]@{}
    $archParentSys = [ordered]@{}
    $archCrossCutting = @{}
    $inLogical = $false
    foreach ($line in $archDesignContent) {
        if ($line -match '(?i)^##\s+Logical') {
            $inLogical = $true
            continue
        }
        if ($inLogical -and $line -match '^##\s') {
            break
        }
        if ($inLogical -and $line -match '\|\s*(ARCH-[0-9]{3})\s*\|\s*([^|]+)\|\s*([^|]+)\|\s*([^|]+)') {
            $archId = $Matches[1]
            $aname = $Matches[2].Trim()
            $aparents = $Matches[4].Trim()
            $archNames[$archId] = $aname
            $archParentSys[$archId] = $aparents
            if ($aparents -match '\[CROSS-CUTTING\]') {
                $archCrossCutting[$archId] = $true
            }
        }
    }

    # Extract ITP sections
    $itpDescriptions = [ordered]@{}
    foreach ($line in $itContentLines) {
        if ($line -match 'Test Case:\s*(ITP-[0-9]{3}-[A-Z])\s*\(([^)]+)\)') {
            $itpDescriptions[$Matches[1]] = $Matches[2]
        }
    }

    # Extract ITP techniques
    $itpTechniques = @{}
    $currentItp = ''
    foreach ($line in $itContentLines) {
        if ($line -match 'Test Case:\s*(ITP-[0-9]{3}-[A-Z])') {
            $currentItp = $Matches[1]
        } elseif ($currentItp -and $line -match '^\*\*Technique\*\*:\s*(.+)') {
            $itpTechniques[$currentItp] = $Matches[1].Trim()
            $currentItp = ''
        }
    }

    # Extract ITS IDs
    $itsIds = @([regex]::Matches($itRaw, 'ITS-[0-9]{3}-[A-Z][0-9]+') |
        ForEach-Object { $_.Value } | Sort-Object -Unique)

    $sortedArch = @($archNames.Keys | Sort-Object)
    $sortedItp = @($itpDescriptions.Keys | Sort-Object)
    $totalArchCount = $sortedArch.Count
    $totalItpCount = $sortedItp.Count
    $totalItsCount = $itsIds.Count

    function Get-ArchBaseKeyC($id) { $id -replace '^ARCH-', '' }
    function Get-ItpBaseKeyC($id) { ($id -replace '^ITP-', '') -replace '-[A-Z]$', '' }
    function Get-ItpFullKeyC($id) { $id -replace '^ITP-', '' }
    function Get-ItsFullKeyC($id) { $id -replace '^ITS-', '' }

    $crossCuttingCount = 0
    foreach ($arch in $sortedArch) {
        if ($archCrossCutting.Contains($arch)) { $crossCuttingCount++ }
    }

    $matrixCLines = @()
    $matrixCLines += '| System Component (SYS) | Parent REQs | Architecture Module (ARCH) | Module Name | Test Case ID (ITP) | Technique | Scenario ID (ITS) | Status |'
    $matrixCLines += '|------------------------|-------------|---------------------------|-------------|--------------------|-----------|--------------------|--------|'

    $sysWithArch = 0

    # Rows for ARCH modules with SYS parents
    if ($hasSystemLevel) {
        foreach ($sys in $sortedSys) {
            $sysKey = Get-SysBaseKeyB $sys
            $hasArch = $false
            $parentReqs = if ($sysParentReqs.Contains($sys)) { $sysParentReqs[$sys] } else { '—' }

            foreach ($arch in $sortedArch) {
                if ($archCrossCutting.Contains($arch)) { continue }
                $parents = $archParentSys[$arch]
                if ($parents -match "(^|,)\s*$([regex]::Escape($sys))\s*(,|$)") {
                    $hasArch = $true
                    $aname = $archNames[$arch]
                    $archKey = Get-ArchBaseKeyC $arch
                    $firstArchItp = $true

                    foreach ($itp in $sortedItp) {
                        $itpKey = Get-ItpBaseKeyC $itp
                        if ($itpKey -eq $archKey) {
                            $technique = if ($itpTechniques.Contains($itp)) { $itpTechniques[$itp] } else { '—' }
                            $itpFKey = Get-ItpFullKeyC $itp

                            foreach ($its in $itsIds) {
                                $itsFKey = Get-ItsFullKeyC $its
                                if ($itsFKey.StartsWith($itpFKey)) {
                                    $matrixCLines += "| $sys ($parentReqs) | $parentReqs | $arch | $aname | $itp | $technique | $its | ⬜ Untested |"
                                    $firstArchItp = $false
                                }
                            }

                            if ($firstArchItp) {
                                $matrixCLines += "| $sys ($parentReqs) | $parentReqs | $arch | $aname | $itp | $technique | ❌ MISSING | ⬜ Untested |"
                                $firstArchItp = $false
                            }
                        }
                    }

                    if ($firstArchItp) {
                        $matrixCLines += "| $sys ($parentReqs) | $parentReqs | $arch | $aname | ❌ MISSING | — | — | ⬜ Untested |"
                    }
                }
            }

            if ($hasArch) {
                $sysWithArch++
            } else {
                $matrixCLines += "| $sys ($parentReqs) | $parentReqs | ❌ MISSING | — | — | — | — | ⬜ Untested |"
            }
        }
    }

    # Cross-cutting modules (pseudo-rows)
    foreach ($arch in $sortedArch) {
        if (-not $archCrossCutting.Contains($arch)) { continue }
        $aname = $archNames[$arch]
        $archKey = Get-ArchBaseKeyC $arch
        $firstCcItp = $true

        foreach ($itp in $sortedItp) {
            $itpKey = Get-ItpBaseKeyC $itp
            if ($itpKey -eq $archKey) {
                $technique = if ($itpTechniques.Contains($itp)) { $itpTechniques[$itp] } else { '—' }
                $itpFKey = Get-ItpFullKeyC $itp

                foreach ($its in $itsIds) {
                    $itsFKey = Get-ItsFullKeyC $its
                    if ($itsFKey.StartsWith($itpFKey)) {
                        $matrixCLines += "| N/A (Cross-Cutting) | — | $arch | $aname | $itp | $technique | $its | ⬜ Untested |"
                        $firstCcItp = $false
                    }
                }

                if ($firstCcItp) {
                    $matrixCLines += "| N/A (Cross-Cutting) | — | $arch | $aname | $itp | $technique | ❌ MISSING | ⬜ Untested |"
                    $firstCcItp = $false
                }
            }
        }

        if ($firstCcItp) {
            $matrixCLines += "| N/A (Cross-Cutting) | — | $arch | $aname | ❌ MISSING | — | — | ⬜ Untested |"
        }
    }

    # Matrix C coverage metrics
    if ($hasSystemLevel) {
        if ($totalSysCount -gt 0) { $sysArchPct = [math]::Floor($sysWithArch * 100 / $totalSysCount) }
        else { $sysArchPct = 0 }
    } else {
        $sysWithArch = 0
        $sysArchPct = 0
    }

    $archCovered = 0
    foreach ($arch in $sortedArch) {
        $archKey = Get-ArchBaseKeyC $arch
        foreach ($itp in $sortedItp) {
            $itpKey = Get-ItpBaseKeyC $itp
            if ($itpKey -eq $archKey) { $archCovered++; break }
        }
    }

    if ($totalArchCount -gt 0) { $archItpPct = [math]::Floor($archCovered * 100 / $totalArchCount) }
    else { $archItpPct = 0 }

    $fullOutput += '## Matrix C — Integration Verification (Module Boundary View)'
    $fullOutput += ''
    $fullOutput += $matrixCLines
    $fullOutput += ''
    $fullOutput += '### Matrix C Coverage'
    $fullOutput += ''
    $fullOutput += '| Metric | Value |'
    $fullOutput += '|--------|-------|'
    $fullOutput += "| **Total Architecture Modules (ARCH)** | $totalArchCount |"
    $fullOutput += "| **Total Cross-Cutting Modules** | $crossCuttingCount |"
    $fullOutput += "| **Total Integration Test Cases (ITP)** | $totalItpCount |"
    $fullOutput += "| **Total Integration Scenarios (ITS)** | $totalItsCount |"
    if ($hasSystemLevel) {
        $fullOutput += "| **SYS → ARCH Coverage** | $sysWithArch/$totalSysCount ($sysArchPct%) |"
    }
    $fullOutput += "| **ARCH → ITP Coverage** | $archCovered/$totalArchCount ($archItpPct%) |"
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

if ($hasArchLevel) {
    # Architecture-level gaps
    $archSysWithoutArch = @()
    if ($hasSystemLevel) {
        foreach ($sys in $sortedSys) {
            $found = $false
            foreach ($arch in $sortedArch) {
                if ($archCrossCutting.Contains($arch)) { continue }
                $parents = $archParentSys[$arch]
                if ($parents -match "(^|,)\s*$([regex]::Escape($sys))\s*(,|$)") {
                    $found = $true
                    break
                }
            }
            if (-not $found) { $archSysWithoutArch += $sys }
        }
    }

    $orphanedItps = @()
    foreach ($itp in $sortedItp) {
        $itpKey = Get-ItpBaseKeyC $itp
        $hasArchG = $false
        foreach ($arch in $sortedArch) {
            $archKey = Get-ArchBaseKeyC $arch
            if ($itpKey -eq $archKey) { $hasArchG = $true; break }
        }
        if (-not $hasArchG) { $orphanedItps += $itp }
    }

    $fullOutput += ''
    $fullOutput += '### Uncovered System Components — Architecture Level (SYS without ARCH)'
    $fullOutput += ''
    if ($archSysWithoutArch.Count -eq 0) {
        $fullOutput += 'None — full coverage.'
    } else {
        foreach ($sys in $archSysWithoutArch) { $fullOutput += "- $sys" }
    }
    $fullOutput += ''
    $fullOutput += '### Orphaned Integration Test Cases (ITP without valid ARCH)'
    $fullOutput += ''
    if ($orphanedItps.Count -eq 0) {
        $fullOutput += 'None — all integration tests trace to modules.'
    } else {
        foreach ($itp in $orphanedItps) { $fullOutput += "- $itp" }
    }
}

# ---- Matrix D: Implementation Verification (if module-level artifacts exist) ----
$ModuleDesignFile = Join-Path $VModelDir 'module-design.md'
$UnitTestFile = Join-Path $VModelDir 'unit-test.md'
$hasModuleLevel = (Test-Path $ModuleDesignFile) -and (Test-Path $ArchDesign)

if ($hasModuleLevel) {
    # Parse architecture-design.md for ARCH→SYS lineage if not already parsed by Matrix C
    if (-not $hasArchLevel) {
        $archDesignContent = Get-Content $ArchDesign
        $archNames = [ordered]@{}
        $archParentSys = [ordered]@{}
        $archCrossCutting = @{}
        $inLogical = $false
        foreach ($line in $archDesignContent) {
            if ($line -match '(?i)^##\s+Logical') {
                $inLogical = $true
                continue
            }
            if ($inLogical -and $line -match '^##\s') {
                break
            }
            if ($inLogical -and $line -match '\|\s*(ARCH-[0-9]{3})\s*\|\s*([^|]+)\|\s*([^|]+)\|\s*([^|]+)') {
                $archId = $Matches[1]
                $aname = $Matches[2].Trim()
                $aparents = $Matches[4].Trim()
                $archNames[$archId] = $aname
                $archParentSys[$archId] = $aparents
                if ($aparents -match '\[CROSS-CUTTING\]') {
                    $archCrossCutting[$archId] = $true
                }
            }
        }
        $sortedArch = @($archNames.Keys | Sort-Object)
        $totalArchCount = $sortedArch.Count
        function Get-ArchBaseKeyC($id) { $id -replace '^ARCH-', '' }
    }

    $modContent = Get-Content $ModuleDesignFile

    # Extract MOD IDs from heading lines + metadata
    $modNames = [ordered]@{}
    $modParentArch = @{}
    $modExternalFlag = @{}
    $currentMod = ''
    $inMeta = $false
    foreach ($line in $modContent) {
        if ($line -match '^###\s+Module:\s*(MOD-[0-9]{3})\s*\(([^)]*)\)') {
            $currentMod = $Matches[1]
            $modNames[$currentMod] = $Matches[2]
            $inMeta = $true
            if ($line -match '\[EXTERNAL\]') {
                $modExternalFlag[$currentMod] = $true
            }
            continue
        }
        if ($line -match '^####' -or $line -match '^---$') {
            $inMeta = $false
        }
        if ($line -match '^###\s' -and $line -notmatch 'Module:') {
            $currentMod = ''
            $inMeta = $false
        }
        if ($currentMod -and $inMeta) {
            if ($line -match '^\*\*Parent Architecture Modules\*\*:') {
                $parents = @([regex]::Matches($line, 'ARCH-[0-9]{3}') |
                    ForEach-Object { $_.Value })
                $modParentArch[$currentMod] = $parents
            }
            if ($line -match '\[EXTERNAL\]') {
                $modExternalFlag[$currentMod] = $true
            }
        }
    }

    $sortedMod = @($modNames.Keys | Sort-Object)
    $totalModCount = $sortedMod.Count

    function Get-ModBaseKeyD($id) { $id -replace '^MOD-', '' }

    # Extract UTP/UTS from unit-test.md (if exists)
    $utpDescriptions = [ordered]@{}
    $utpTechniquesD = @{}
    $modUtpIds = @()
    $modUtsIds = @()
    $hasUnitTest = Test-Path $UnitTestFile

    if ($hasUnitTest) {
        $utContent = Get-Content $UnitTestFile
        $utRaw = Get-Content -Raw $UnitTestFile

        foreach ($line in $utContent) {
            if ($line -match 'Test Case:\s*(UTP-[0-9]{3}-[A-Z])\s*\(([^)]+)\)') {
                $utpDescriptions[$Matches[1]] = $Matches[2]
            }
        }

        $currentUtp = ''
        foreach ($line in $utContent) {
            if ($line -match 'Test Case:\s*(UTP-[0-9]{3}-[A-Z])') {
                $currentUtp = $Matches[1]
            } elseif ($currentUtp -and $line -match '^\*\*Technique\*\*:\s*(.+)') {
                $utpTechniquesD[$currentUtp] = $Matches[1].Trim()
                $currentUtp = ''
            }
        }

        $modUtpIds = @([regex]::Matches($utRaw, 'UTP-[0-9]{3}-[A-Z]') |
            ForEach-Object { $_.Value } | Sort-Object -Unique)
        $modUtsIds = @([regex]::Matches($utRaw, 'UTS-[0-9]{3}-[A-Z][0-9]+') |
            ForEach-Object { $_.Value } | Sort-Object -Unique)
    }

    $sortedUtp = @($utpDescriptions.Keys | Sort-Object)
    $totalUtpCount = $sortedUtp.Count
    $totalUtsCount = $modUtsIds.Count

    function Get-UtpBaseKeyD($id) { ($id -replace '^UTP-', '') -replace '-[A-Z]$', '' }
    function Get-UtpFullKeyD($id) { $id -replace '^UTP-', '' }
    function Get-UtsFullKeyD($id) { $id -replace '^UTS-', '' }

    $externalCount = 0
    foreach ($mod in $sortedMod) {
        if ($modExternalFlag.Contains($mod)) { $externalCount++ }
    }

    $matrixDLines = @()
    $matrixDLines += '| Architecture Module (ARCH) | Parent System | Module Design (MOD) | Module Name | Test Case ID (UTP) | Technique | Scenario ID (UTS) | Status |'
    $matrixDLines += '|---------------------------|---------------|---------------------|-------------|--------------------|-----------|--------------------|--------|'

    if ($hasArchLevel) {
        foreach ($arch in $sortedArch) {
            $archKey = Get-ArchBaseKeyC $arch
            $aname = $archNames[$arch]

            if ($archCrossCutting.Contains($arch)) {
                $parentSysDisplay = '[CROSS-CUTTING]'
            } else {
                $parentSysDisplay = if ($archParentSys.Contains($arch)) { $archParentSys[$arch] } else { '—' }
            }

            $hasMod = $false
            foreach ($mod in $sortedMod) {
                if (-not $modParentArch.Contains($mod)) { continue }
                $modArchParents = $modParentArch[$mod]
                if ($arch -in $modArchParents) {
                    $hasMod = $true
                    $mname = $modNames[$mod]
                    $modKey = Get-ModBaseKeyD $mod

                    if ($modExternalFlag.Contains($mod)) {
                        $matrixDLines += "| $arch ($parentSysDisplay) | $parentSysDisplay | $mod | $mname [EXTERNAL] | — (integration level) | — | — | ⬜ Bypassed |"
                        continue
                    }

                    if ($hasUnitTest) {
                        $firstModUtp = $true
                        foreach ($utp in $sortedUtp) {
                            $utpKey = Get-UtpBaseKeyD $utp
                            if ($utpKey -eq $modKey) {
                                $technique = if ($utpTechniquesD.Contains($utp)) { $utpTechniquesD[$utp] } else { '—' }
                                $utpFKey = Get-UtpFullKeyD $utp

                                foreach ($uts in $modUtsIds) {
                                    $utsFKey = Get-UtsFullKeyD $uts
                                    if ($utsFKey.StartsWith($utpFKey)) {
                                        $matrixDLines += "| $arch ($parentSysDisplay) | $parentSysDisplay | $mod | $mname | $utp | $technique | $uts | ⬜ Untested |"
                                        $firstModUtp = $false
                                    }
                                }

                                if ($firstModUtp) {
                                    $matrixDLines += "| $arch ($parentSysDisplay) | $parentSysDisplay | $mod | $mname | $utp | $technique | ❌ MISSING | ⬜ Untested |"
                                    $firstModUtp = $false
                                }
                            }
                        }

                        if ($firstModUtp) {
                            $matrixDLines += "| $arch ($parentSysDisplay) | $parentSysDisplay | $mod | $mname | ❌ MISSING | — | — | ⬜ Untested |"
                        }
                    } else {
                        $matrixDLines += "| $arch ($parentSysDisplay) | $parentSysDisplay | $mod | $mname | ⏳ Pending | — | — | ⬜ Untested |"
                    }
                }
            }

            if (-not $hasMod) {
                $matrixDLines += "| $arch ($parentSysDisplay) | $parentSysDisplay | ❌ MISSING | — | — | — | — | ⬜ Untested |"
            }
        }
    }

    # Matrix D coverage metrics
    $archWithMod = 0
    foreach ($arch in $sortedArch) {
        foreach ($mod in $sortedMod) {
            if ($modParentArch.Contains($mod)) {
                if ($arch -in $modParentArch[$mod]) {
                    $archWithMod++
                    break
                }
            }
        }
    }

    if ($totalArchCount -gt 0) { $archModPct = [math]::Floor($archWithMod * 100 / $totalArchCount) }
    else { $archModPct = 0 }

    $modWithUtp = 0
    $testableMod = $totalModCount - $externalCount
    if ($hasUnitTest) {
        foreach ($mod in $sortedMod) {
            if ($modExternalFlag.Contains($mod)) { continue }
            $modKey = Get-ModBaseKeyD $mod
            foreach ($utp in $sortedUtp) {
                $utpKey = Get-UtpBaseKeyD $utp
                if ($utpKey -eq $modKey) { $modWithUtp++; break }
            }
        }
    }

    if ($testableMod -gt 0 -and $hasUnitTest) { $modUtpPct = [math]::Floor($modWithUtp * 100 / $testableMod) }
    else { $modUtpPct = 0 }

    $fullOutput += ''
    $fullOutput += '## Matrix D — Implementation Verification (Module View)'
    $fullOutput += ''
    $fullOutput += $matrixDLines
    $fullOutput += ''
    $fullOutput += '### Matrix D Coverage'
    $fullOutput += ''
    $fullOutput += '| Metric | Value |'
    $fullOutput += '|--------|-------|'
    $fullOutput += "| **Total Module Designs (MOD)** | $totalModCount |"
    $fullOutput += "| **External Modules** | $externalCount |"
    $fullOutput += "| **Testable Modules** | $testableMod |"
    if ($hasUnitTest) {
        $fullOutput += "| **Total Unit Test Cases (UTP)** | $totalUtpCount |"
        $fullOutput += "| **Total Unit Scenarios (UTS)** | $totalUtsCount |"
    }
    $fullOutput += "| **ARCH → MOD Coverage** | $archWithMod/$totalArchCount ($archModPct%) |"
    if ($hasUnitTest) {
        $fullOutput += "| **MOD → UTP Coverage** | $modWithUtp/$testableMod ($modUtpPct%) |"
    } else {
        $fullOutput += '| **MOD → UTP Coverage** | ⏳ Pending (unit-test.md not found) |'
    }
    $fullOutput += ''
}

$fullOutput += ''
$fullOutput += '## Audit Notes'
$fullOutput += ''
$fullOutput += '- **Matrix generated by**: `build-matrix.ps1` (deterministic regex parser)'
$sourceDocs = '`requirements.md`, `acceptance-plan.md`'
if ($hasSystemLevel) { $sourceDocs += ', `system-design.md`, `system-test.md`' }
if ($hasArchLevel) { $sourceDocs += ', `architecture-design.md`, `integration-test.md`' }
if ($hasModuleLevel) { $sourceDocs += ', `module-design.md`' }
if ($hasUnitTest) { $sourceDocs += ', `unit-test.md`' }
$fullOutput += "- **Source documents**: $sourceDocs"
$fullOutput += "- **Last validated**: $date"

if ($Output) {
    $fullOutput | Out-File -FilePath $Output -Encoding utf8
    Write-Output "Traceability matrix written to $Output"
} else {
    $fullOutput | ForEach-Object { Write-Output $_ }
}
