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

if ($missing -gt 0) {
    Write-Output 'SCHEMA: FAIL'
    exit 1
}
Write-Output ("SCHEMA: PASS (pinned_version={0})" -f $PinnedVersion)
exit 0
