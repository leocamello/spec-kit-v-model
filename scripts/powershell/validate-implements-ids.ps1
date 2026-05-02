<#
.SYNOPSIS
    Deterministic hallucination guard — PowerShell mirror of
    validate-implements-ids.sh.

.DESCRIPTION
    Extracts the canonical V-Model ID set from <feature-dir>/v-model/*.md
    using per-category source-of-truth extraction (D-008), then verifies
    every `Implements <ID>` comment under <feature-dir> (excluding v-model/)
    cites a canonical ID. Re-extracts on every invocation so fixture mutation
    is immediately reflected (HAZ-023, D-004).

    Emits `<file>:<line>: unknown id <X>` per offending citation and a final
    `GUARD: PASS` (exit 0) or `GUARD: FAIL` (exit 1). Stdout framing is
    byte-equivalent to the bash sibling per D-009.

.PARAMETER FeatureDir
    Feature directory; must contain a v-model/ subdirectory.

.EXAMPLE
    pwsh -File ./validate-implements-ids.ps1 ./specs/007-bridge-commands

.NOTES
    Implements: REQ-NF-006, REQ-NF-002, REQ-023, REQ-NF-004,
                SYS-006, ARCH-009, MOD-013, MOD-025,
                UTP-013-A, UTP-025-A, D-009, D-004, D-008.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$FeatureDir
)

$ErrorActionPreference = 'Stop'

if ($FeatureDir -in @('--help', '-h', '-Help')) {
    Write-Output 'Usage: validate-implements-ids.ps1 <feature-dir>'
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
if (-not (Test-Path -LiteralPath $VModelDir -PathType Container)) {
    [Console]::Error.WriteLine("ERROR: v-model dir not found: $VModelDir")
    exit 1
}

# Per-category source-of-truth extraction (D-008): each ID family is canonical
# only if it appears in its owning artifact. Sensitive to fixture mutation
# (HAZ-023 stale-snapshot mitigation).
$canonical = [System.Collections.Generic.HashSet[string]]::new()

function Add-CanonicalIds {
    param([string]$File, [string]$PrefixPattern)
    if (-not (Test-Path -LiteralPath $File -PathType Leaf)) { return }
    $content = Get-Content -Raw -LiteralPath $File
    if ($null -eq $content) { return }
    $regex = "\b(?:$PrefixPattern)-[0-9]+(?:-[A-Z][0-9]*)?\b"
    foreach ($m in [regex]::Matches($content, $regex)) {
        [void]$script:canonical.Add($m.Value)
    }
}

Add-CanonicalIds (Join-Path $VModelDir 'requirements.md')        'REQ|REQ-NF|REQ-CN|REQ-IF'
Add-CanonicalIds (Join-Path $VModelDir 'system-design.md')       'SYS'
Add-CanonicalIds (Join-Path $VModelDir 'architecture-design.md') 'ARCH'
Add-CanonicalIds (Join-Path $VModelDir 'module-design.md')       'MOD'
Add-CanonicalIds (Join-Path $VModelDir 'hazard-analysis.md')     'HAZ'
Add-CanonicalIds (Join-Path $VModelDir 'acceptance-plan.md')     'ATP|SCN'
Add-CanonicalIds (Join-Path $VModelDir 'integration-test.md')    'ITP|ITS'
Add-CanonicalIds (Join-Path $VModelDir 'unit-test.md')           'UTP|UTS'
Add-CanonicalIds (Join-Path $VModelDir 'system-test.md')         'STP|STS'

# Candidate-token regex matches the bash form: uppercase prefix (≥2 letters),
# dash, then a run of [A-Z0-9-] containing at least one digit. Loose on
# purpose — fabricated multi-token glued IDs are rejected by the canonical
# membership check that follows (HAZ-007).
$tokenRe = '[A-Z]{2,}-[A-Z0-9-]*[0-9][A-Z0-9-]*'
$keywordRe = '[Ii]mplements[: ]'

# Walk the feature tree, skipping v-model/, .git/, node_modules/, .session-tmp/.
$excludeDirs = @('v-model', '.git', 'node_modules', '.session-tmp')
$featureRoot = (Resolve-Path -LiteralPath $FeatureDir).Path

$files = Get-ChildItem -LiteralPath $featureRoot -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object {
        $rel = $_.FullName.Substring($featureRoot.Length).TrimStart([char]'/', [char]'\')
        $segments = $rel -split '[\\/]'
        $isExcluded = $false
        foreach ($seg in $segments) {
            if ($excludeDirs -contains $seg) { $isExcluded = $true; break }
        }
        -not $isExcluded
    }

$unknown = 0
foreach ($file in $files) {
    $lineNo = 0
    $lines = $null
    try { $lines = Get-Content -LiteralPath $file.FullName -ErrorAction Stop }
    catch { continue }
    if ($null -eq $lines) { continue }
    foreach ($line in $lines) {
        $lineNo++
        if ($line -notmatch $keywordRe) { continue }
        $tail = [regex]::Replace($line, '^.*[Ii]mplements[: ]+', '')
        $matches = [regex]::Matches($tail, $tokenRe)
        foreach ($m in $matches) {
            $id = $m.Value
            if (-not $canonical.Contains($id)) {
                Write-Output ("{0}:{1}: unknown id {2}" -f $file.FullName, $lineNo, $id)
                $unknown++
            }
        }
    }
}

if ($unknown -gt 0) {
    Write-Output 'GUARD: FAIL'
    exit 1
}
Write-Output 'GUARD: PASS'
exit 0
