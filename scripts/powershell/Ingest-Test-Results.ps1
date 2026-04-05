<#
.SYNOPSIS
    Ingest JUnit XML test results into the traceability matrix.

.DESCRIPTION
    Parses JUnit XML test results (and optional Cobertura XML code coverage)
    via the Python helper script, then updates the traceability-matrix.md
    in-place: replaces Status columns, adds Date + Commit columns, and
    optionally adds a Coverage column to Matrix D.

.PARAMETER InputFile
    Path to JUnit XML file (required).

.PARAMETER Coverage
    Path to Cobertura XML coverage file.

.PARAMETER Matrix
    Path to traceability-matrix.md (default: auto-detect from V-Model directory).

.PARAMETER CoverageMap
    Path to coverage-map.yml override for MOD-to-file mapping.

.PARAMETER CommitSha
    Explicit commit SHA. Defaults to git rev-parse --short=7 HEAD.

.PARAMETER Json
    Output JSON to stdout instead of human-readable summary.

.PARAMETER VModelDir
    V-Model directory path. If not provided, auto-detects via setup-v-model.ps1.

.PARAMETER Help
    Show usage information.

.EXAMPLE
    ./Ingest-Test-Results.ps1 -InputFile results.xml -VModelDir specs/005d/v-model
.EXAMPLE
    ./Ingest-Test-Results.ps1 -InputFile results.xml -Coverage coverage.xml -Json -VModelDir specs/005d/v-model
#>

param(
    [string]$InputFile = "",
    [string]$Coverage = "",
    [string]$Matrix = "",
    [string]$CoverageMap = "",
    [string]$CommitSha = "",
    [switch]$Json,
    [switch]$Help,
    [string]$VModelDir = ""
)

$ErrorActionPreference = "Stop"

# ---- Help ----
if ($Help) {
    Write-Host @"
Usage: Ingest-Test-Results.ps1 -InputFile <junit.xml> [OPTIONS] [-VModelDir <path>]

Ingest JUnit XML test results into the traceability matrix.

REQUIRED:
  -InputFile <path>         Path to JUnit XML file

OPTIONS:
  -Coverage <path>      Path to Cobertura XML coverage file
  -Matrix <path>        Path to traceability-matrix.md
  -CoverageMap <path>   Path to coverage-map.yml override
  -CommitSha <sha>      Explicit commit SHA (default: auto-detect from HEAD)
  -Json                 Output JSON to stdout
  -Help                 Show this help message
  -VModelDir <path>     V-Model directory (default: auto-detect)

EXIT CODES:
  0 = all matched tests passed
  1 = at least one failure detected
  2 = no V-Model scenario IDs matched
"@
    exit 0
}

# ---- Locate scripts ----
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$PythonHelper = Join-Path $RepoRoot "scripts" "python" "parse_test_results.py"

# ---- Validate required arguments ----
if ([string]::IsNullOrWhiteSpace($InputFile)) {
    Write-Error "ERROR: -InputFile argument is required"
    exit 1
}

if (-not (Test-Path $InputFile)) {
    Write-Error "ERROR: JUnit XML file not found: $InputFile"
    exit 1
}

if (-not [string]::IsNullOrWhiteSpace($Coverage) -and -not (Test-Path $Coverage)) {
    Write-Error "ERROR: Cobertura XML file not found: $Coverage"
    exit 1
}

if (-not [string]::IsNullOrWhiteSpace($CoverageMap) -and -not (Test-Path $CoverageMap)) {
    Write-Error "ERROR: Coverage map file not found: $CoverageMap"
    exit 1
}

# ---- Resolve matrix path ----
if ([string]::IsNullOrWhiteSpace($Matrix)) {
    if (-not [string]::IsNullOrWhiteSpace($VModelDir)) {
        $Matrix = Join-Path $VModelDir "traceability-matrix.md"
    } else {
        # Auto-detect via setup-v-model.ps1
        try {
            $setupScript = Join-Path $RepoRoot "scripts" "powershell" "setup-v-model.ps1"
            $setupOutput = & pwsh -File $setupScript -Json 2>$null
            $setupJson = $setupOutput | Where-Object { $_ -is [string] } | ConvertFrom-Json
            $VModelDir = $setupJson.VMODEL_DIR
            $Matrix = Join-Path $VModelDir "traceability-matrix.md"
        } catch {
            Write-Error "ERROR: Could not auto-detect V-Model directory. Use -Matrix or -VModelDir."
            exit 1
        }
    }
}

if (-not (Test-Path $Matrix)) {
    Write-Error "ERROR: Traceability matrix not found: $Matrix"
    exit 1
}

# ---- Resolve module-design.md ----
$ModuleDesign = ""
if (-not [string]::IsNullOrWhiteSpace($Coverage)) {
    if (-not [string]::IsNullOrWhiteSpace($VModelDir)) {
        $mdPath = Join-Path $VModelDir "module-design.md"
        if (Test-Path $mdPath) { $ModuleDesign = $mdPath }
    } else {
        $mdPath = Join-Path (Split-Path -Parent $Matrix) "module-design.md"
        if (Test-Path $mdPath) { $ModuleDesign = $mdPath }
    }
}

# ---- Resolve commit SHA ----
if ([string]::IsNullOrWhiteSpace($CommitSha)) {
    try {
        $CommitSha = (git rev-parse --short=7 HEAD 2>$null).Trim()
    } catch {
        $CommitSha = "unknown"
    }
    if ([string]::IsNullOrWhiteSpace($CommitSha)) { $CommitSha = "unknown" }
}

# ---- Resolve date ----
$IngestDate = (Get-Date -Format "yyyy-MM-dd")

# ---- Read coverage threshold from extension.yml ----
$CoverageThreshold = 100
$extYml = Join-Path $RepoRoot "extension.yml"
if (Test-Path $extYml) {
    $threshLine = Get-Content $extYml | Where-Object { $_ -match "coverage_threshold:" } | Select-Object -First 1
    if ($threshLine -match "coverage_threshold:\s*(\d+)") {
        $CoverageThreshold = [int]$Matches[1]
    }
}

# ---- Call Python helper ----
$pythonArgs = @("--junit", $InputFile)
if (-not [string]::IsNullOrWhiteSpace($Coverage)) {
    $pythonArgs += @("--cobertura", $Coverage)
}
if (-not [string]::IsNullOrWhiteSpace($CoverageMap)) {
    $pythonArgs += @("--coverage-map", $CoverageMap)
}
if (-not [string]::IsNullOrWhiteSpace($ModuleDesign)) {
    $pythonArgs += @("--module-design", $ModuleDesign)
}
$pythonArgs += @("--coverage-threshold", "$CoverageThreshold")

$pythonOutput = & python3 $PythonHelper @pythonArgs 2>$null
$pythonRaw = $pythonOutput -join "`n"
$data = $pythonRaw | ConvertFrom-Json

if ($data.PSObject.Properties.Name -contains "error") {
    Write-Error "ERROR: $($data.error)"
    exit 1
}

# ---- Build lookup tables ----
$idStatus = @{}
$idMatrix = @{}
foreach ($r in @($data.test_results)) {
    $emoji = switch ($r.status) {
        "passed"  { "✅ Passed" }
        "failed"  { "❌ Failed" }
        "skipped" { "⏭️ Skipped" }
        default   { "⬜ Untested" }
    }
    $idStatus[$r.id] = $emoji
    $idMatrix[$r.id] = $r.matrix
}

$modCoverage = @{}
$modBelow = @{}
$hasCoverage = -not [string]::IsNullOrWhiteSpace($Coverage)
if ($hasCoverage -and $data.PSObject.Properties.Name -contains "coverage") {
    foreach ($prop in $data.coverage.PSObject.Properties) {
        $modCoverage[$prop.Name] = $prop.Value.formatted
        $modBelow[$prop.Name] = $prop.Value.below_threshold
    }
}

# ---- Update matrix in-place ----
$matrixLines = @(Get-Content $Matrix -Encoding UTF8)
$outputLines = [System.Collections.Generic.List[string]]::new()

$currentMatrix = ""
$inTable = $false
$headerProcessed = $false
$separatorProcessed = $false

foreach ($line in $matrixLines) {
    # Detect matrix section header
    if ($line -match "^##\s+Matrix\s+([A-Z])") {
        $currentMatrix = $Matches[1]
        $inTable = $false
        $headerProcessed = $false
        $separatorProcessed = $false
        $outputLines.Add($line)
        continue
    }

    # Detect table header row
    if (-not $inTable -and $line -match "^\|" -and -not $headerProcessed) {
        $inTable = $true
        $headerProcessed = $true
        $trimmed = $line.TrimEnd()
        if ($trimmed.EndsWith("|")) { $trimmed = $trimmed.Substring(0, $trimmed.Length - 1).TrimEnd() }
        if ($currentMatrix -eq "D" -and $hasCoverage) {
            $outputLines.Add("$trimmed | Date | Commit | Coverage |")
        } else {
            $outputLines.Add("$trimmed | Date | Commit |")
        }
        continue
    }

    # Detect separator row
    if ($inTable -and -not $separatorProcessed -and $line -match "^\|\s*-+") {
        $separatorProcessed = $true
        $trimmed = $line.TrimEnd()
        if ($trimmed.EndsWith("|")) { $trimmed = $trimmed.Substring(0, $trimmed.Length - 1).TrimEnd() }
        if ($currentMatrix -eq "D" -and $hasCoverage) {
            $outputLines.Add("$trimmed | --- | --- | --- |")
        } else {
            $outputLines.Add("$trimmed | --- | --- |")
        }
        continue
    }

    # Process data rows
    if ($inTable -and $line -match "^\|") {
        $matchedId = ""
        $matchedStatus = ""
        foreach ($vid in $idStatus.Keys) {
            if ($line.Contains($vid)) {
                $matchedId = $vid
                $matchedStatus = $idStatus[$vid]
                break
            }
        }

        if (-not [string]::IsNullOrWhiteSpace($matchedId)) {
            $updatedLine = $line `
                -replace "⬜ Untested", $matchedStatus `
                -replace "✅ Passed", $matchedStatus `
                -replace "❌ Failed", $matchedStatus `
                -replace "⏭️ Skipped", $matchedStatus

            # Determine coverage value for Matrix D
            $coverageVal = ""
            if ($currentMatrix -eq "D" -and $hasCoverage) {
                $modMatch = [regex]::Match($line, "MOD-\d{3}")
                if ($modMatch.Success -and $modCoverage.ContainsKey($modMatch.Value)) {
                    $coverageVal = $modCoverage[$modMatch.Value]
                    if ($modBelow[$modMatch.Value]) {
                        $coverageVal = "⚠ $coverageVal"
                    }
                } else {
                    $coverageVal = "—"
                }
            }

            $trimmed = $updatedLine.TrimEnd()
            if ($trimmed.EndsWith("|")) { $trimmed = $trimmed.Substring(0, $trimmed.Length - 1).TrimEnd() }
            if ($currentMatrix -eq "D" -and $hasCoverage) {
                $outputLines.Add("$trimmed | $IngestDate | $CommitSha | $coverageVal |")
            } else {
                $outputLines.Add("$trimmed | $IngestDate | $CommitSha |")
            }
        } else {
            # No match — add empty columns
            $trimmed = $line.TrimEnd()
            if ($trimmed.EndsWith("|")) { $trimmed = $trimmed.Substring(0, $trimmed.Length - 1).TrimEnd() }
            if ($currentMatrix -eq "D" -and $hasCoverage) {
                $outputLines.Add("$trimmed | | | |")
            } else {
                $outputLines.Add("$trimmed | | |")
            }
        }
        continue
    }

    # Non-table line resets table state
    if ($inTable -and $line -notmatch "^\|") {
        $inTable = $false
    }

    $outputLines.Add($line)
}

# Write updated matrix
$outputLines | Set-Content $Matrix -Encoding UTF8

# ---- Output ----
if ($Json) {
    # Augment Python output with matrix path, date, commit
    $data | Add-Member -NotePropertyName "matrix_path" -NotePropertyValue $Matrix -Force
    $data | Add-Member -NotePropertyName "date" -NotePropertyValue $IngestDate -Force
    $data | Add-Member -NotePropertyName "commit" -NotePropertyValue $CommitSha -Force
    $data | ConvertTo-Json -Depth 10
} else {
    $summary = $data.summary
    $pm = $summary.per_matrix

    Write-Host ""
    Write-Host "=== Test Results Ingestion ==="
    Write-Host ""

    $matrixNames = @{ A = "Acceptance"; B = "System"; C = "Integration"; D = "Unit" }
    foreach ($label in @("A", "B", "C", "D")) {
        $m = $pm.$label
        if ($m.total -gt 0) {
            Write-Host "Matrix $label ($($matrixNames[$label])): $($m.total) matched | $($m.passed) passed | $($m.failed) failed | $($m.skipped) skipped"
        }
    }

    Write-Host ""
    Write-Host "Total: $($summary.total) matched | $($summary.passed) passed | $($summary.failed) failed | $($summary.skipped) skipped"

    if ($summary.unmatched_count -gt 0) {
        Write-Host "Unmatched JUnit tests: $($summary.unmatched_count)"
    }

    if ($hasCoverage -and $modCoverage.Count -gt 0) {
        Write-Host ""
        Write-Host "Coverage (Matrix D):"
        foreach ($modId in ($modCoverage.Keys | Sort-Object)) {
            $flag = ""
            if ($modBelow[$modId]) { $flag = " ⚠ BELOW THRESHOLD" }
            Write-Host "  ${modId}: $($modCoverage[$modId])$flag"
        }
    }

    Write-Host ""
    Write-Host "Matrix updated: $Matrix"
}

# ---- Exit code ----
if ($summary.total -eq 0) {
    exit 2
} elseif ($summary.failed -gt 0) {
    exit 1
} else {
    exit 0
}
