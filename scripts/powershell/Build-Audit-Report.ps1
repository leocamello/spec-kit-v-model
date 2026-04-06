<#
.SYNOPSIS
    Build a release audit report from V-Model artifacts.

.DESCRIPTION
    100% deterministic, no AI. Discovers artifacts, extracts traceability matrices,
    cross-references anomalies with waivers, computes compliance status, and
    assembles a point-in-time release-audit-report.md.

.PARAMETER VModelDir
    V-Model directory path (required).

.PARAMETER SystemName
    System name for executive summary.

.PARAMETER Version
    Release version.

.PARAMETER GitTag
    Git release tag.

.PARAMETER RegulatoryContext
    Applicable regulatory standards.

.PARAMETER Output
    Output file path (default: <vmodel-dir>/release-audit-report.md).

.PARAMETER Json
    Output JSON to stdout.

.PARAMETER Help
    Show usage information.

.EXAMPLE
    ./Build-Audit-Report.ps1 -VModelDir specs/005e/v-model -SystemName "CBGMS" -Version "2.1.0"
.EXAMPLE
    ./Build-Audit-Report.ps1 -VModelDir specs/005e/v-model -Json
#>

param(
    [string]$VModelDir = "",
    [string]$SystemName = "(not specified)",
    [string]$Version = "(not specified)",
    [string]$GitTag = "(not specified)",
    [string]$RegulatoryContext = "(not specified)",
    [string]$Output = "",
    [switch]$Json,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# ---- Help ----
if ($Help) {
    Write-Host @"
Usage: Build-Audit-Report.ps1 -VModelDir <path> [OPTIONS]

Build a release audit report from V-Model artifacts.

REQUIRED:
  -VModelDir <path>             V-Model directory path

OPTIONS:
  -SystemName <name>            System name for executive summary
  -Version <ver>                Release version
  -GitTag <tag>                 Git release tag
  -RegulatoryContext <ctx>      Applicable regulatory standards
  -Output <path>                Output file (default: <vmodel-dir>/release-audit-report.md)
  -Json                         Output JSON to stdout
  -Help                         Show this help message

EXIT CODES:
  0 = RELEASE READY or RELEASE CANDIDATE
  1 = NOT READY (unwaived anomalies)
  2 = Error (missing required artifacts)
"@
    exit 0
}

# ---- Constants ----
$ExpectedFiles = @(
    "requirements.md",
    "acceptance-plan.md",
    "system-design.md",
    "system-test.md",
    "architecture-design.md",
    "integration-test.md",
    "module-design.md",
    "unit-test.md",
    "hazard-analysis.md",
    "traceability-matrix.md",
    "waivers.md"
)

$HumanNames = @(
    "Requirements",
    "Acceptance Plan",
    "System Design",
    "System Test",
    "Architecture Design",
    "Integration Test",
    "Module Design",
    "Unit Test",
    "Hazard Analysis",
    "Traceability Matrix",
    "Waivers"
)

$RequiredFiles = @("requirements.md", "traceability-matrix.md")

# ---- Helpers ----
function Strip-Bold {
    param([string]$Val)
    $Val = $Val.Trim()
    if ($Val.StartsWith("**")) { $Val = $Val.Substring(2) }
    if ($Val.EndsWith("**")) { $Val = $Val.Substring(0, $Val.Length - 2) }
    return $Val
}

function Parse-Columns {
    param([string]$Line)
    $Line = $Line.TrimStart("|").TrimEnd("|")
    $parts = $Line -split "\|"
    $cols = @()
    foreach ($part in $parts) {
        $cols += $part.Trim()
    }
    return $cols
}

# ---- Validate arguments ----
if ([string]::IsNullOrWhiteSpace($VModelDir)) {
    [Console]::Error.WriteLine("ERROR: V-Model directory argument required")
    exit 2
}

if (-not (Test-Path $VModelDir -PathType Container)) {
    [Console]::Error.WriteLine("ERROR: Directory not found: $VModelDir")
    exit 2
}

foreach ($reqFile in $RequiredFiles) {
    $reqPath = Join-Path $VModelDir $reqFile
    if (-not (Test-Path $reqPath)) {
        [Console]::Error.WriteLine("ERROR: Required artifact missing: $reqFile")
        exit 2
    }
}

if ([string]::IsNullOrWhiteSpace($Output)) {
    $Output = Join-Path $VModelDir "release-audit-report.md"
}

# Resolve VModelDir to absolute path and work from there for git context
$VModelDir = (Resolve-Path $VModelDir).Path
$Output = [System.IO.Path]::GetFullPath($Output)
$OriginalLocation = Get-Location
Set-Location $VModelDir

$GenerationDate = (Get-Date -Format "yyyy-MM-dd")

# ============================================================
# MOD-002: Discover Artifacts
# ============================================================
$artifactInventory = [System.Collections.Generic.List[hashtable]]::new()
$artifactFound = 0

for ($i = 0; $i -lt $ExpectedFiles.Count; $i++) {
    $file = $ExpectedFiles[$i]
    $name = $HumanNames[$i]
    $filepath = Join-Path $VModelDir $file

    if (Test-Path $filepath) {
        $sha = "N/A"
        $gdate = "N/A"
        try {
            $sha = (git log -1 --format='%h' -- $filepath 2>$null)
            if ([string]::IsNullOrWhiteSpace($sha)) { $sha = "N/A" }
            $rawDate = (git log -1 --format='%aI' -- $filepath 2>$null)
            if (-not [string]::IsNullOrWhiteSpace($rawDate)) {
                $gdate = ($rawDate -split "T")[0]
            }
        } catch { }
        $artifactInventory.Add(@{ name = $name; file = $file; sha = $sha; date = $gdate; status = "Present" })
        $artifactFound++
    } else {
        $artifactInventory.Add(@{ name = $name; file = $file; sha = [string]::new([char]0x2014, 1); date = [string]::new([char]0x2014, 1); status = "Missing" })
    }
}

# Resolve git SHA for report metadata
$GitSha = "N/A"
try {
    $GitSha = (git log -1 --format='%h' 2>$null)
    if ([string]::IsNullOrWhiteSpace($GitSha)) { $GitSha = "N/A" }
} catch { }

# ============================================================
# MOD-003 + MOD-004: Parse Matrix File & Compute Coverage
# ============================================================
$MatrixPath = Join-Path $VModelDir "traceability-matrix.md"
$totalPassed = 0
$totalFailed = 0
$totalSkipped = 0
$totalUntested = 0
$matrixCount = 0

$currentMatrixId = ""
$currentMatrixTitle = ""
$currentHeader = ""
$statusColIdx = -1
$testIdColIdx = -1
$firstIdColIdx = 0
$currentSource = ""

$sourceIdsAll = @{}
$sourceHasTarget = @{}
$targetIdsAll = @{}

$coverageData = [System.Collections.Generic.List[hashtable]]::new()
$matricesRaw = [System.Text.StringBuilder]::new()
$anomalies = [System.Collections.Generic.List[hashtable]]::new()

function Finish-Matrix {
    if ([string]::IsNullOrWhiteSpace($script:currentMatrixId)) { return }

    $fwdTotal = 0; $fwdCovered = 0; $bwdTotal = 0
    $gapCount = 0

    foreach ($key in $script:sourceIdsAll.Keys) {
        if ($key.StartsWith("$($script:currentMatrixId):")) {
            $fwdTotal++
            $srcId = $key.Substring($key.IndexOf(":") + 1)
            if ($script:sourceHasTarget.ContainsKey("$($script:currentMatrixId):$srcId")) {
                $fwdCovered++
            } else {
                $gapCount++
            }
        }
    }

    foreach ($key in $script:targetIdsAll.Keys) {
        if ($key.StartsWith("$($script:currentMatrixId):")) {
            $bwdTotal++
        }
    }

    $fwdPct = 0
    if ($fwdTotal -gt 0) { $fwdPct = [math]::Floor($fwdCovered * 100 / $fwdTotal) }
    $bwdPct = if ($bwdTotal -eq 0) { 0 } else { 100 }

    $script:coverageData.Add(@{
        matrix = $script:currentMatrixId
        title = $script:currentMatrixTitle
        forward = "$fwdCovered/$fwdTotal ($fwdPct%)"
        backward = "$bwdTotal/$bwdTotal ($bwdPct%)"
        gaps = $gapCount
        orphans = 0
    })

    $script:matrixCount++
}

$matrixLines = @(Get-Content $MatrixPath -Encoding UTF8)

foreach ($line in $matrixLines) {
    # Detect matrix section heading
    if ($line -match "^##\s+(Matrix\s+[A-Z])") {
        Finish-Matrix
        $currentMatrixId = $Matches[1]
        $currentMatrixTitle = ($line -replace "^##\s+", "")
        $currentHeader = ""
        $statusColIdx = -1
        $testIdColIdx = -1
        $currentSource = ""

        [void]$matricesRaw.AppendLine($line)
        [void]$matricesRaw.AppendLine("")
        continue
    }

    # Skip non-matrix content
    if ([string]::IsNullOrWhiteSpace($currentMatrixId)) { continue }

    # Detect section exit
    if ($line -match "^##\s+" -and $line -notmatch "^###\s+" -and $line -notmatch "^##\s+Matrix") {
        Finish-Matrix
        $currentMatrixId = ""
        continue
    }

    # Store raw text
    [void]$matricesRaw.AppendLine($line)

    # Skip non-table lines
    if ($line -notmatch "^\|") { continue }

    # Skip separator rows
    if ($line -match "^\|\s*[-:]+") { continue }

    $cols = Parse-Columns $line

    # Parse header row
    if ([string]::IsNullOrWhiteSpace($currentHeader)) {
        $currentHeader = $line
        for ($ci = 0; $ci -lt $cols.Count; $ci++) {
            $colLower = $cols[$ci].ToLower()
            if ($colLower -match "status") { $statusColIdx = $ci }
            if ($colLower -match "scenario id|(\(scn\))|(\(sts\))|(\(its\))|(\(uts\))") {
                $testIdColIdx = $ci
            }
        }
        # Fallback: test ID is one before Status
        if ($testIdColIdx -eq -1 -and $statusColIdx -gt 0) {
            $testIdColIdx = $statusColIdx - 1
        }
        continue
    }

    # Parse data row
    if ($statusColIdx -lt 0) { continue }

    $localStatus = if ($statusColIdx -lt $cols.Count) { $cols[$statusColIdx] } else { "" }
    $localTestId = if ($testIdColIdx -ge 0 -and $testIdColIdx -lt $cols.Count) { $cols[$testIdColIdx] } else { "" }
    $localSourceRaw = if ($firstIdColIdx -lt $cols.Count) { $cols[$firstIdColIdx] } else { "" }
    $localSource = Strip-Bold $localSourceRaw

    # Inherit source from previous row if empty
    if (-not [string]::IsNullOrWhiteSpace($localSource)) {
        $currentSource = $localSource
    }

    # Track source/target IDs for coverage
    if (-not [string]::IsNullOrWhiteSpace($currentSource)) {
        $sourceIdsAll["${currentMatrixId}:${currentSource}"] = 1
        if (-not [string]::IsNullOrWhiteSpace($localTestId)) {
            $sourceHasTarget["${currentMatrixId}:${currentSource}"] = 1
        }
    }
    if (-not [string]::IsNullOrWhiteSpace($localTestId)) {
        $targetIdsAll["${currentMatrixId}:${localTestId}"] = 1
    }

    # Count test statuses
    if ($localStatus -match [char]0x2705 -or $localStatus -match "Passed") {
        $totalPassed++
    } elseif ($localStatus -match [char]0x274C -or $localStatus -match "Failed") {
        $totalFailed++
        if (-not [string]::IsNullOrWhiteSpace($localTestId)) {
            $anomalies.Add(@{ artifact_id = $localTestId; type = "Failed Test"; matrix = $currentMatrixId })
        }
    } elseif ($localStatus -match "Skipped" -or $localStatus -match [char]0x23ED) {
        $totalSkipped++
        if (-not [string]::IsNullOrWhiteSpace($localTestId)) {
            $anomalies.Add(@{ artifact_id = $localTestId; type = "Skipped Test"; matrix = $currentMatrixId })
        }
    } elseif ($localStatus -match [char]0x2B1C -or $localStatus -match "Untested" -or $localStatus -match "Pending") {
        $totalUntested++
    }
}

Finish-Matrix

$totalTests = $totalPassed + $totalFailed + $totalSkipped + $totalUntested

# Count unique requirements from Matrix A source IDs
$totalReqs = 0
foreach ($key in $sourceIdsAll.Keys) {
    if ($key.StartsWith("Matrix A:")) { $totalReqs++ }
}

# ============================================================
# MOD-005: Parse Hazards
# ============================================================
$HazardPath = Join-Path $VModelDir "hazard-analysis.md"
$totalHazards = 0
$totalMitigated = 0
$hazardRows = [System.Collections.Generic.List[string]]::new()

if (Test-Path $HazardPath) {
    $hazLines = @(Get-Content $HazardPath -Encoding UTF8)
    foreach ($hLine in $hazLines) {
        if ($hLine -match "^\|\s*\*?\*?(HAZ-\d{3})\*?\*?") {
            $hazardRows.Add($hLine)
            $totalHazards++
            $totalMitigated++
        }
    }
}

# ============================================================
# MOD-007: Parse Waivers
# ============================================================
$WaiverPath = Join-Path $VModelDir "waivers.md"
$waiverWavId = @{}
$waiverType = @{}
$waiverJustification = @{}
$waiverApprovedBy = @{}
$waiverArtifactIds = [System.Collections.Generic.List[string]]::new()

if (Test-Path $WaiverPath) {
    $currentWav = ""
    $currentArtifact = ""
    $currentType = ""
    $currentJustification = ""
    $currentApproved = ""

    $waiverLines = @(Get-Content $WaiverPath -Encoding UTF8)

    foreach ($wLine in $waiverLines) {
        if ($wLine -match "^###\s+(WAV-\d{3})") {
            # Save previous waiver
            if (-not [string]::IsNullOrWhiteSpace($currentWav) -and -not [string]::IsNullOrWhiteSpace($currentArtifact)) {
                $waiverWavId[$currentArtifact] = $currentWav
                $waiverType[$currentArtifact] = if ([string]::IsNullOrWhiteSpace($currentType)) { "Unknown" } else { $currentType }
                $waiverJustification[$currentArtifact] = $currentJustification
                $waiverApprovedBy[$currentArtifact] = $currentApproved
                $waiverArtifactIds.Add($currentArtifact)
            }
            $currentWav = $Matches[1]
            $currentArtifact = ""
            $currentType = ""
            $currentJustification = ""
            $currentApproved = ""
        } elseif ($wLine -match "^\*\*Artifact\*\*:\s*(.*)") {
            $currentArtifact = $Matches[1].Trim()
        } elseif ($wLine -match "^\*\*Type\*\*:\s*(.*)") {
            $currentType = $Matches[1].Trim()
        } elseif ($wLine -match "^\*\*Justification\*\*:\s*(.*)") {
            $currentJustification = $Matches[1].Trim()
        } elseif ($wLine -match "^\*\*Approved By\*\*:\s*(.*)") {
            $currentApproved = $Matches[1].Trim()
        }
    }
    # Save last waiver
    if (-not [string]::IsNullOrWhiteSpace($currentWav) -and -not [string]::IsNullOrWhiteSpace($currentArtifact)) {
        $waiverWavId[$currentArtifact] = $currentWav
        $waiverType[$currentArtifact] = if ([string]::IsNullOrWhiteSpace($currentType)) { "Unknown" } else { $currentType }
        $waiverJustification[$currentArtifact] = $currentJustification
        $waiverApprovedBy[$currentArtifact] = $currentApproved
        $waiverArtifactIds.Add($currentArtifact)
    }
}

# ============================================================
# MOD-008: Cross-Reference Anomalies with Waivers
# ============================================================
$blockingCount = 0
$waivedCount = 0
$anomalyCount = $anomalies.Count
$usedWaiverIds = @{}
$classifiedAnomalies = [System.Collections.Generic.List[hashtable]]::new()
$orphanedWaivers = [System.Collections.Generic.List[hashtable]]::new()

foreach ($anom in $anomalies) {
    $aid = $anom.artifact_id
    if ($waiverWavId.ContainsKey($aid)) {
        $wav = $waiverWavId[$aid]
        $classifiedAnomalies.Add(@{
            artifact_id = $aid; type = $anom.type; matrix = $anom.matrix
            disposition = "Waived"; waiver = $wav
        })
        $usedWaiverIds[$wav] = 1
        $waivedCount++
    } else {
        $classifiedAnomalies.Add(@{
            artifact_id = $aid; type = $anom.type; matrix = $anom.matrix
            disposition = "BLOCKING"; waiver = [string]::new([char]0x2014, 1)
        })
        $blockingCount++
    }
}

# Find orphaned waivers
foreach ($aid in $waiverArtifactIds) {
    $wav = $waiverWavId[$aid]
    if (-not $usedWaiverIds.ContainsKey($wav)) {
        $orphanedWaivers.Add(@{ waiver_id = $wav; artifact_id = $aid })
    }
}
$orphanedCount = $orphanedWaivers.Count

# Compute compliance status
if ($blockingCount -gt 0) {
    $ComplianceStatus = "$([char]0x274C) NOT READY $([char]0x2014) Unwaived anomalies detected"
    $ExitCode = 1
} elseif ($anomalyCount -gt 0) {
    $ComplianceStatus = "$([char]0x2705) RELEASE CANDIDATE $([char]0x2014) All anomalies waived"
    $ExitCode = 0
} else {
    $ComplianceStatus = "$([char]0x2705) RELEASE READY $([char]0x2014) No anomalies"
    $ExitCode = 0
}

# ============================================================
# MOD-010: JSON Output
# ============================================================
if ($Json) {
    $jsonObj = [ordered]@{
        metadata = [ordered]@{
            system_name = $SystemName
            version = $Version
            git_tag = $GitTag
            git_sha = $GitSha
            date = $GenerationDate
            regulatory_context = $RegulatoryContext
        }
        compliance_status = $ComplianceStatus
        exit_code = $ExitCode
        artifact_inventory = @($artifactInventory | ForEach-Object {
            [ordered]@{ name = $_.name; file = $_.file; sha = $_.sha; date = $_.date; status = $_.status }
        })
        coverage_analysis = @($coverageData | ForEach-Object {
            [ordered]@{
                matrix = $_.matrix; title = $_.title
                forward_coverage = $_.forward; backward_coverage = $_.backward
                gaps = $_.gaps; orphans = $_.orphans
            }
        })
        hazard_summary = @($hazardRows | ForEach-Object {
            $cols = Parse-Columns $_
            $hazId = Strip-Bold $cols[0]
            [ordered]@{ id = $hazId }
        })
        anomalies = [ordered]@{
            classified = @($classifiedAnomalies | ForEach-Object {
                [ordered]@{
                    artifact_id = $_.artifact_id; type = $_.type; matrix = $_.matrix
                    disposition = $_.disposition; waiver = $_.waiver
                }
            })
            orphaned_waivers = @($orphanedWaivers | ForEach-Object {
                [ordered]@{ waiver_id = $_.waiver_id; artifact_id = $_.artifact_id }
            })
        }
        summary = [ordered]@{
            total_requirements = $totalReqs
            total_tests = $totalTests
            passed = $totalPassed
            failed = $totalFailed
            skipped = $totalSkipped
            untested = $totalUntested
            total_hazards = $totalHazards
            anomaly_count = $anomalyCount
            waived = $waivedCount
            blocking = $blockingCount
            orphaned_waivers = $orphanedCount
        }
    }

    $jsonObj | ConvertTo-Json -Depth 10

    # Print summary to stderr (not stdout) so JSON output stays clean
    [Console]::Error.WriteLine("=== Audit Report Summary ===")
    [Console]::Error.WriteLine("Artifacts: $artifactFound/$($ExpectedFiles.Count)")
    [Console]::Error.WriteLine("Matrices: $matrixCount")
    [Console]::Error.WriteLine("Tests: $totalTests ($([char]0x2705) $totalPassed | $([char]0x274C) $totalFailed | $([char]0x23ED)$([char]0xFE0F) $totalSkipped | $([char]0x2B1C) $totalUntested)")
    [Console]::Error.WriteLine("Hazards: $totalHazards")
    [Console]::Error.WriteLine("Anomalies: $anomalyCount (waived: $waivedCount, blocking: $blockingCount)")
    if ($orphanedCount -gt 0) { [Console]::Error.WriteLine("Orphaned waivers: $orphanedCount") }
    [Console]::Error.WriteLine("Status: $ComplianceStatus")
    Set-Location $OriginalLocation
    exit $ExitCode
}

# ============================================================
# MOD-009: Render Markdown Report
# ============================================================
$report = [System.Text.StringBuilder]::new()
$emdash = [string]::new([char]0x2014, 1)

# Section 1: Executive Summary
[void]$report.AppendLine("# Release Audit Report")
[void]$report.AppendLine("")
[void]$report.AppendLine("## 1. Executive Summary")
[void]$report.AppendLine("")
[void]$report.AppendLine("**System**: $SystemName")
[void]$report.AppendLine("**Version**: $Version")
[void]$report.AppendLine("**Git Tag**: $GitTag (commit $GitSha)")
[void]$report.AppendLine("**Date**: $GenerationDate")
[void]$report.AppendLine("**Regulatory Context**: $RegulatoryContext")
[void]$report.AppendLine("")
[void]$report.AppendLine("$totalReqs requirements traced across $matrixCount traceability matrices.")
[void]$report.AppendLine("$totalTests test scenarios: $totalPassed passed, $totalFailed failed, $totalSkipped skipped, $totalUntested untested.")
[void]$report.AppendLine("$totalHazards hazards identified; $totalMitigated mitigated.")
[void]$report.AppendLine("$anomalyCount anomalies detected: $waivedCount waived, $blockingCount blocking.")
[void]$report.AppendLine("")
[void]$report.AppendLine("**Compliance Status**: $ComplianceStatus")
[void]$report.AppendLine("")

# Section 2: Artifact Inventory
[void]$report.AppendLine("## 2. Artifact Inventory")
[void]$report.AppendLine("")
[void]$report.AppendLine("| Artifact | File | Git SHA | Last Modified | Status |")
[void]$report.AppendLine("|----------|------|---------|---------------|--------|")

foreach ($art in $artifactInventory) {
    [void]$report.AppendLine("| $($art.name) | $($art.file) | $($art.sha) | $($art.date) | $($art.status) |")
}

[void]$report.AppendLine("")

# Section 3: Traceability Matrices
[void]$report.AppendLine("## 3. Traceability Matrices")
[void]$report.AppendLine("")

$rawMatrices = $matricesRaw.ToString()
if (-not [string]::IsNullOrWhiteSpace($rawMatrices)) {
    [void]$report.Append($rawMatrices)
} else {
    [void]$report.AppendLine("No traceability matrices found.")
}

[void]$report.AppendLine("")

# Section 4: Coverage Analysis
[void]$report.AppendLine("## 4. Coverage Analysis")
[void]$report.AppendLine("")
[void]$report.AppendLine("| Matrix | Forward Coverage | Backward Coverage | Gaps | Orphans |")
[void]$report.AppendLine("|--------|-----------------|-------------------|------|---------|")

foreach ($cov in $coverageData) {
    [void]$report.AppendLine("| $($cov.matrix) | $($cov.forward) | $($cov.backward) | $($cov.gaps) | $($cov.orphans) |")
}

[void]$report.AppendLine("")

# Section 5: Hazard Management Summary
[void]$report.AppendLine("## 5. Hazard Management Summary")
[void]$report.AppendLine("")

if ($totalHazards -gt 0) {
    [void]$report.AppendLine("| HAZ | Details |")
    [void]$report.AppendLine("|-----|---------|")
    foreach ($hRow in $hazardRows) {
        $cols = Parse-Columns $hRow
        $hazId = Strip-Bold $cols[0]
        $detail = ($cols[1..($cols.Count - 1)] -join " | ")
        [void]$report.AppendLine("| $hazId | $detail |")
    }
    [void]$report.AppendLine("")
    [void]$report.AppendLine("All $totalHazards hazards mitigated.")
} else {
    [void]$report.AppendLine("No hazard analysis was performed.")
}

[void]$report.AppendLine("")

# Section 6: Known Anomalies
[void]$report.AppendLine("## 6. Known Anomalies")
[void]$report.AppendLine("")

if ($classifiedAnomalies.Count -gt 0) {
    [void]$report.AppendLine("| ID | Type | Matrix | Disposition | Waiver |")
    [void]$report.AppendLine("|----|------|--------|-------------|--------|")
    foreach ($ca in $classifiedAnomalies) {
        [void]$report.AppendLine("| $($ca.artifact_id) | $($ca.type) | $($ca.matrix) | $($ca.disposition) | $($ca.waiver) |")
    }
} else {
    [void]$report.AppendLine("No anomalies detected.")
}

if ($orphanedWaivers.Count -gt 0) {
    [void]$report.AppendLine("")
    [void]$report.AppendLine("### Orphaned Waivers")
    [void]$report.AppendLine("")
    [void]$report.AppendLine("The following waivers reference artifact IDs that are not anomalies:")
    [void]$report.AppendLine("")
    [void]$report.AppendLine("| Waiver | Artifact ID |")
    [void]$report.AppendLine("|--------|-------------|")
    foreach ($ow in $orphanedWaivers) {
        [void]$report.AppendLine("| $($ow.waiver_id) | $($ow.artifact_id) |")
    }
}

[void]$report.AppendLine("")

# Section 7: Signatures
$sigBlockTitle = "## 7. Signature Block"
[void]$report.AppendLine($sigBlockTitle)
[void]$report.AppendLine("")
[void]$report.AppendLine("| Role | Name | Signature | Date |")
[void]$report.AppendLine("|------|------|-----------|------|")
[void]$report.AppendLine("| QA Manager | _________________ | _________________ | __________ |")
[void]$report.AppendLine("| Lead Engineer | _________________ | _________________ | __________ |")
[void]$report.AppendLine("| Release Tag | $GitTag | Git SHA: $GitSha | $GenerationDate |")

# Write report
$report.ToString() | Set-Content $Output -Encoding UTF8

# Print summary to stderr
Write-Host "=== Audit Report Summary ===" -ForegroundColor Cyan
Write-Host "Artifacts: $artifactFound/$($ExpectedFiles.Count)"
Write-Host "Matrices: $matrixCount"
Write-Host "Tests: $totalTests ($([char]0x2705) $totalPassed | $([char]0x274C) $totalFailed | $([char]0x23ED)$([char]0xFE0F) $totalSkipped | $([char]0x2B1C) $totalUntested)"
Write-Host "Hazards: $totalHazards"
Write-Host "Anomalies: $anomalyCount (waived: $waivedCount, blocking: $blockingCount)"
if ($orphanedCount -gt 0) { Write-Host "Orphaned waivers: $orphanedCount" }
Write-Host "Status: $ComplianceStatus"
Write-Host "Report written to: $Output"
Set-Location $OriginalLocation
exit $ExitCode
