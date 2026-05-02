<#
.SYNOPSIS
    Pre-implementation V-Model gate (PowerShell mirror of run-v-model-gate.sh).

.DESCRIPTION
    Composes build-matrix.ps1 plus the five validate-*-coverage.ps1 sibling
    scripts against <feature-dir>/v-model. Aggregates exit codes, emits a
    structured `--- v-model run summary ---` block, and a final `GATE: PASS`
    or `GATE: FAIL` line whose framing is byte-identical to the POSIX shell
    spec per D-009 (script-by-script parity).

.PARAMETER FeatureDir
    Path to the feature directory (must contain a v-model/ subdirectory).

.EXAMPLE
    pwsh -File ./run-v-model-gate.ps1 ./specs/007-bridge-commands

.NOTES
    Implements: REQ-NF-006, REQ-CN-001, REQ-017, REQ-CN-002, REQ-027,
                SYS-004, SYS-012, ARCH-007, ARCH-016, MOD-010, MOD-021,
                UTP-010-A, D-009, D-003.
    Final-line + summary-block framing MUST stay byte-identical to the bash
    sibling — the gate contract (ARCH-007 §stdout schema) is the cross-shell
    parity surface, not the inner-validator chatter (HAZ-010).
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$FeatureDir
)

$ErrorActionPreference = 'Stop'

if ($FeatureDir -in @('--help', '-h', '-Help')) {
    Write-Output 'Usage: run-v-model-gate.ps1 <feature-dir>'
    exit 0
}

if ([string]::IsNullOrEmpty($FeatureDir)) {
    [Console]::Error.WriteLine('ERROR: feature-dir argument required')
    exit 1
}

if (-not (Test-Path -LiteralPath $FeatureDir -PathType Container)) {
    [Console]::Error.WriteLine("ERROR: feature dir not found: $FeatureDir")
    exit 1
}

$VModelDir = Join-Path $FeatureDir 'v-model'
$ScriptDir = Split-Path -Parent $PSCommandPath

# Inner-script set per ARCH-007 §Inner-script set (REUSE of the five sibling
# coverage validators + build-matrix; D-003).
$Inners = @(
    'build-matrix.ps1',
    'validate-requirement-coverage.ps1',
    'validate-system-coverage.ps1',
    'validate-architecture-coverage.ps1',
    'validate-module-coverage.ps1',
    'validate-hazard-coverage.ps1'
)

$names = @()
$rcs   = @()
$overall = 0

# Same-directory temp file (mirrors `mktemp -p "$FEATURE_DIR"` from bash;
# avoids $env:TEMP per repo policy).
$matrixOut = Join-Path $FeatureDir ('matrix.' + [System.IO.Path]::GetRandomFileName())

try {
    foreach ($inner in $Inners) {
        $path = Join-Path $ScriptDir $inner
        $names += $inner
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            [Console]::Error.WriteLine("ERROR: missing inner script: $path")
            $rcs += 'missing'
            $overall = 1
            continue
        }
        Write-Output "=== $inner ==="
        $rc = 0
        if ($inner -eq 'build-matrix.ps1') {
            & pwsh -NoProfile -File $path $VModelDir -Output $matrixOut
        } else {
            & pwsh -NoProfile -File $path $VModelDir
        }
        $rc = $LASTEXITCODE
        $rcs += "$rc"
        if ($rc -ne 0) { $overall = 1 }
    }

    Write-Output '--- v-model run summary ---'
    for ($i = 0; $i -lt $names.Count; $i++) {
        $rc = $rcs[$i]
        switch ($rc) {
            '0'       { Write-Output ("  {0}: PASS (rc=0)" -f $names[$i]) }
            'missing' { Write-Output ("  {0}: FAIL (missing executable)" -f $names[$i]) }
            default   { Write-Output ("  {0}: FAIL (rc={1})" -f $names[$i], $rc) }
        }
    }
    Write-Output '---'

    if ($overall -eq 0) {
        Write-Output 'GATE: PASS'
        exit 0
    } else {
        Write-Output 'GATE: FAIL'
        exit 1
    }
}
finally {
    if (Test-Path -LiteralPath $matrixOut) {
        Remove-Item -LiteralPath $matrixOut -Force -ErrorAction SilentlyContinue
    }
}
