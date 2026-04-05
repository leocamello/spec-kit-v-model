<#
.SYNOPSIS
    Deterministic CI gate for peer-review reports.

.DESCRIPTION
    Parses a peer-review-{artifact}.md file and returns exit codes based on
    the severity of findings detected:

      Exit 0 = clean (zero findings, or observations only)
      Exit 1 = Critical or Major findings detected (blocks PR)
      Exit 2 = Minor findings only, no Critical/Major (warning)

.PARAMETER ReviewFile
    Path to the peer-review report file.

.PARAMETER Json
    Output in JSON format (for AI consumption).

.EXAMPLE
    ./Peer-Review-Check.ps1 specs/005c/v-model/peer-review-requirements.md
    ./Peer-Review-Check.ps1 -Json specs/005c/v-model/peer-review-requirements.md
#>

param(
    [Parameter(Position = 0)]
    [string]$ReviewFile,

    [switch]$Json,

    [Alias('h')]
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Help) {
    Write-Output "Usage: Peer-Review-Check.ps1 [-Json] <review-file>"
    Write-Output ""
    Write-Output "Parse a peer-review report and return CI exit codes."
    Write-Output ""
    Write-Output "EXIT CODES:"
    Write-Output "  0 = clean (no findings or observations only)"
    Write-Output "  1 = Critical or Major findings (blocks PR)"
    Write-Output "  2 = Minor findings only (warning)"
    exit 0
}

if (-not $ReviewFile) {
    Write-Error "ERROR: review-file argument required`nUsage: Peer-Review-Check.ps1 [-Json] <review-file>"
    exit 1
}

if (-not (Test-Path $ReviewFile)) {
    Write-Error "ERROR: file not found: $ReviewFile"
    exit 1
}

# ---- Parse Summary Table ----

$critical = 0
$major = 0
$minor = 0
$observation = 0

$lines = Get-Content $ReviewFile

foreach ($line in $lines) {
    if ($line -match '^\|\s*Critical\s*\|\s*(\d+)\s*\|') {
        $critical = [int]$Matches[1]
    }
    elseif ($line -match '^\|\s*Major\s*\|\s*(\d+)\s*\|') {
        $major = [int]$Matches[1]
    }
    elseif ($line -match '^\|\s*Minor\s*\|\s*(\d+)\s*\|') {
        $minor = [int]$Matches[1]
    }
    elseif ($line -match '^\|\s*Observation\s*\|\s*(\d+)\s*\|') {
        $observation = [int]$Matches[1]
    }
}

$total = $critical + $major + $minor + $observation

# ---- Cross-Validate Against Actual Findings ----

$prfCount = @($lines | Where-Object { $_ -match '^###\s+PRF-[A-Z]+-\d{3}' }).Count
$prfCritical = @($lines | Where-Object { $_ -match '^\|\s*\*\*Severity\*\*\s*\|\s*Critical\s*\|' }).Count
$prfMajor = @($lines | Where-Object { $_ -match '^\|\s*\*\*Severity\*\*\s*\|\s*Major\s*\|' }).Count
$prfMinor = @($lines | Where-Object { $_ -match '^\|\s*\*\*Severity\*\*\s*\|\s*Minor\s*\|' }).Count
$prfObservation = @($lines | Where-Object { $_ -match '^\|\s*\*\*Severity\*\*\s*\|\s*Observation\s*\|' }).Count

$prfTotal = $prfCritical + $prfMajor + $prfMinor + $prfObservation

$summaryMatch = ($total -eq $prfCount) -and ($total -eq $prfTotal)

# ---- Extract Metadata ----

$artifact = ""
$standard = ""

foreach ($line in $lines) {
    if ($line -match '^\*\*Artifact\*\*:\s*(.*)') {
        $artifact = $Matches[1]
    }
    elseif ($line -match '^\*\*Standard\*\*:\s*(.*)') {
        $standard = $Matches[1]
    }
}

# ---- Determine Exit Code ----

if ($critical -gt 0 -or $major -gt 0) {
    $exitCode = 1
}
elseif ($minor -gt 0) {
    $exitCode = 2
}
else {
    $exitCode = 0
}

# ---- Output ----

if ($Json) {
    $result = [ordered]@{
        review_file     = $ReviewFile
        artifact        = $artifact
        standard        = $standard
        critical        = $critical
        major           = $major
        minor           = $minor
        observation     = $observation
        total           = $total
        prf_headings    = $prfCount
        prf_critical    = $prfCritical
        prf_major       = $prfMajor
        prf_minor       = $prfMinor
        prf_observation = $prfObservation
        summary_match   = $summaryMatch
        exit_code       = $exitCode
    }
    $result | ConvertTo-Json
}
else {
    Write-Output "=== Peer Review Check ==="
    Write-Output ""
    Write-Output "File: $ReviewFile"
    if ($artifact) {
        Write-Output "Artifact: $artifact"
    }
    if ($standard) {
        Write-Output "Standard: $standard"
    }
    Write-Output ""

    Write-Output "── Summary Table ──"
    Write-Output "  Critical:    $critical"
    Write-Output "  Major:       $major"
    Write-Output "  Minor:       $minor"
    Write-Output "  Observation: $observation"
    Write-Output "  Total:       $total"
    Write-Output ""

    Write-Output "── Finding Validation ──"
    Write-Output "  PRF headings found: $prfCount"
    Write-Output "  Severity tags found: $prfTotal"
    if ($summaryMatch) {
        Write-Output "  ✅ Summary table matches findings"
    }
    else {
        Write-Output "  ⚠️  Summary table ($total) does not match findings ($prfCount headings, $prfTotal severity tags)"
    }
    Write-Output ""

    Write-Output "── CI Gate ──"
    if ($exitCode -eq 0) {
        Write-Output "  ✅ PASS — no blocking findings"
    }
    elseif ($exitCode -eq 1) {
        Write-Output "  ❌ FAIL — $critical Critical + $major Major findings (blocks PR)"
    }
    elseif ($exitCode -eq 2) {
        Write-Output "  ⚠️  WARNING — $minor Minor findings only (non-blocking)"
    }
}

exit $exitCode
