<#
.SYNOPSIS
    Approval-status sub-validator for the V-Model gate (PowerShell mirror of validate-artifact-status.sh).

.DESCRIPTION
    Greps `^**Status**:` from each canonical V-Model artifact in -VModelDir
    and fails fast if any value is not in the allowed set (default
    {Approved}). Only the FIRST `**Status**:` line per file is consulted.
    Files that don't exist are skipped silently. Stdout PASS line is
    byte-equivalent to the bash sibling per D-009.

.PARAMETER VModelDir
    Path to a v-model directory containing canonical artifacts.

.PARAMETER RequiredStatus
    Allowed status values. Default = @('Approved').

.NOTES
    Implements: REQ-016, SYS-004, ARCH-007, ARCH-016, MOD-010, MOD-021,
                HAZ-009, HAZ-010, D-003.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$VModelDir,
    [string[]]$RequiredStatus = @('Approved')
)

$ErrorActionPreference = 'Stop'

# `pwsh -File ... -RequiredStatus Draft,Approved` arrives here as a single
# string `"Draft,Approved"` (the CLI binder does not auto-split). Normalize.
if ($RequiredStatus.Count -eq 1 -and $RequiredStatus[0] -match '[,;]') {
    $RequiredStatus = @($RequiredStatus[0] -split '[,;]' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

if ($VModelDir -in @('--help', '-h', '-Help')) {
    Write-Output 'Usage: validate-artifact-status.ps1 <vmodel-dir> [-RequiredStatus <s>...]'
    exit 0
}

if ([string]::IsNullOrEmpty($VModelDir)) {
    [Console]::Error.WriteLine('ERROR: vmodel-dir argument required')
    exit 1
}
if (-not (Test-Path -LiteralPath $VModelDir -PathType Container)) {
    [Console]::Error.WriteLine("ERROR: vmodel-dir not found: $VModelDir")
    exit 1
}

$artifacts = @(
    'requirements.md',
    'system-design.md',
    'architecture-design.md',
    'module-design.md',
    'hazard-analysis.md',
    'unit-test.md',
    'integration-test.md',
    'system-test.md',
    'acceptance-plan.md'
)

$fail = 0
foreach ($art in $artifacts) {
    $f = Join-Path $VModelDir $art
    if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { continue }
    $line = $null
    foreach ($candidate in (Get-Content -LiteralPath $f)) {
        if ($candidate -match '^\*\*Status\*\*:') { $line = $candidate; break }
    }
    if ([string]::IsNullOrEmpty($line)) {
        [Console]::Error.WriteLine("STATUS: ${art}: <missing>")
        $fail = 1; continue
    }
    $value = ($line -replace '^\*\*Status\*\*:', '').Trim()
    if ([string]::IsNullOrEmpty($value)) {
        [Console]::Error.WriteLine("STATUS: ${art}: <missing>")
        $fail = 1; continue
    }
    if ($RequiredStatus -notcontains $value) {
        [Console]::Error.WriteLine("STATUS: ${art}: $value")
        $fail = 1
    }
}

if ($fail -ne 0) { exit 1 }
Write-Output 'STATUS: PASS'
