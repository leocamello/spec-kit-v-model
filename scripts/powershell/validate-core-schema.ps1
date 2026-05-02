<#
.SYNOPSIS
    Pinned-schema validator for plan.md / tasks.md (PowerShell mirror of
    validate-core-schema.sh).

.DESCRIPTION
    Extracts the H2 heading set from the spec-kit-core template (pinned at
    v0.7.0) and verifies the target file contains every required heading.
    Tolerates additive content (extra headings, prose, HTML-comment
    enrichment such as `<!-- v-model: … -->`). Fails closed on any missing
    required heading with a `<heading>: MISSING` diagnostic per gap and a
    final `SCHEMA: FAIL` line.

    SCHEMA CHECKS (3 passes, mirror of validate-core-schema.sh):
      1. Existence — every canonical H2 from the pinned template is
         present in the target as an exact-match line.
      2. Order     — canonical H2s in the target appear in the same
         relative order as in the template. Mismatch → "ORDER: FAIL"
         on stderr.
      3. Wedge     — between the first and last canonical H2 in the
         target, every H2 must itself be canonical. Non-canonical H2s
         wedged between canonical ones are rejected with
         "WEDGE: FAIL — non-canonical H2 between canonical H2s: <h>".
         Extras before the first / after the last canonical H2 are
         tolerated (preamble / trailing).

.PARAMETER Target
    The plan.md or tasks.md file to validate.

.PARAMETER Plan
    Validate against .specify/templates/plan-template.md.

.PARAMETER Tasks
    Validate against .specify/templates/tasks-template.md.

.EXAMPLE
    pwsh -File ./validate-core-schema.ps1 ./specs/007/plan.md -Plan
    pwsh -File ./validate-core-schema.ps1 ./specs/007/tasks.md -Tasks

.NOTES
    Implements: REQ-NF-006, REQ-IF-001, REQ-IF-002, REQ-029,
                SYS-010, ARCH-013, MOD-017, MOD-018,
                UTP-017-A, UTP-018-A, D-009.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Target,
    [switch]$Plan,
    [switch]$Tasks
)

$ErrorActionPreference = 'Stop'

$PinnedVersion = 'v0.7.0'

if ($Target -in @('--help', '-h', '-Help')) {
    Write-Output "Usage: validate-core-schema.ps1 <target-file> -Plan|-Tasks"
    exit 0
}

if ($Plan -and $Tasks) {
    [Console]::Error.WriteLine('ERROR: only one of -Plan or -Tasks may be supplied')
    exit 1
}
if (-not $Plan -and -not $Tasks) {
    [Console]::Error.WriteLine('ERROR: mode flag required (-Plan or -Tasks)')
    exit 1
}
if ([string]::IsNullOrEmpty($Target)) {
    [Console]::Error.WriteLine('ERROR: target file required')
    exit 1
}
if (-not (Test-Path -LiteralPath $Target -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: target file not found: $Target")
    exit 1
}

$ScriptDir = Split-Path -Parent $PSCommandPath
$ProjectRoot = Resolve-Path (Join-Path $ScriptDir '../..')

if ($Plan) {
    $template = Join-Path $ProjectRoot '.specify/templates/plan-template.md'
} else {
    $template = Join-Path $ProjectRoot '.specify/templates/tasks-template.md'
}

if (-not (Test-Path -LiteralPath $template -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: pinned template not found: $template")
    exit 1
}

# Required H2 headings — every line beginning with `## ` in the pinned template.
$required = Get-Content -LiteralPath $template | Where-Object { $_ -match '^## ' }

# Build a hash-set of target lines for O(1) exact-match lookups (mirrors
# `grep -Fxq`).
$targetLines = Get-Content -LiteralPath $Target
$targetSet = [System.Collections.Generic.HashSet[string]]::new()
if ($null -ne $targetLines) {
    foreach ($line in $targetLines) { [void]$targetSet.Add($line) }
}

$missing = 0
foreach ($heading in $required) {
    if ([string]::IsNullOrEmpty($heading)) { continue }
    if (-not $targetSet.Contains($heading)) {
        Write-Output ("{0}: MISSING" -f $heading)
        $missing++
    }
}

$fail = $false
if ($missing -gt 0) { $fail = $true }

# Pass 2: ordering — canonical H2s in target follow template order.
# Pass 3: wedge   — between first and last canonical H2 in target, every
# H2 must be canonical. Preamble / trailing extras tolerated.
$expected = @($required | Where-Object { -not [string]::IsNullOrEmpty($_) })
$expectedSet = [System.Collections.Generic.HashSet[string]]::new()
foreach ($e in $expected) { [void]$expectedSet.Add($e) }

$targetH2All = @($targetLines | Where-Object { $_ -match '^## ' })
$targetCanonicalInOrder = @($targetH2All | Where-Object { $expectedSet.Contains($_) })

$orderMatches = $true
if ($expected.Count -ne $targetCanonicalInOrder.Count) {
    $orderMatches = $false
} else {
    for ($i = 0; $i -lt $expected.Count; $i++) {
        if ($expected[$i] -ne $targetCanonicalInOrder[$i]) { $orderMatches = $false; break }
    }
}
if (-not $orderMatches) {
    [Console]::Error.WriteLine('ORDER: FAIL')
    $expectedJoined = ($expected -join "`n")
    $actualJoined   = ($targetCanonicalInOrder -join "`n")
    [Console]::Error.WriteLine("--- expected (template order)`n$expectedJoined")
    [Console]::Error.WriteLine("+++ actual (target order)`n$actualJoined")
    $fail = $true
}

# Find first/last canonical H2 line indices (0-based) in target.
$firstIdx = -1
$lastIdx  = -1
$targetArr = @($targetLines)
for ($i = 0; $i -lt $targetArr.Count; $i++) {
    if ($expectedSet.Contains($targetArr[$i])) {
        if ($firstIdx -eq -1) { $firstIdx = $i }
        $lastIdx = $i
    }
}
if ($firstIdx -ge 0 -and $lastIdx -gt $firstIdx) {
    for ($j = $firstIdx; $j -le $lastIdx; $j++) {
        $line = $targetArr[$j]
        if ($line -match '^## ' -and -not $expectedSet.Contains($line)) {
            [Console]::Error.WriteLine("WEDGE: FAIL — non-canonical H2 between canonical H2s: $line")
            $fail = $true
        }
    }
}

if ($fail) {
    Write-Output 'SCHEMA: FAIL'
    exit 1
}
Write-Output ("SCHEMA: PASS (pinned_version={0})" -f $PinnedVersion)
exit 0
