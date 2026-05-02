<#
.SYNOPSIS
    Deterministic hallucination guard — PowerShell mirror of
    validate-implements-ids.sh.

.DESCRIPTION
    Extracts the canonical V-Model ID set from <canonical>/*.md (default
    <feature-dir>/v-model) using per-category source-of-truth extraction
    (D-008), then verifies every `Implements <ID>` comment under the scan
    root cites a canonical ID. Re-extracts on every invocation so fixture
    mutation is immediately reflected (HAZ-023, D-004).

    Emits `<file>:<line>: unknown id <X>` per offending citation and a final
    `GUARD: PASS` (exit 0) or `GUARD: FAIL` (exit 1). Stdout framing is
    byte-equivalent to the bash sibling per D-009.

.PARAMETER FeatureDir
    Legacy positional feature directory; implies -Canonical
    <FeatureDir>/v-model and -Scan <FeatureDir>.

.PARAMETER Canonical
    Override the canonical V-Model artifact directory.

.PARAMETER Scan
    Override the scan root.

.PARAMETER ChangedOnly
    Restrict the scan to files reported by `git diff` (HEAD ∪ staged) plus
    untracked-new, intersected with -Scan, excluding paths under -Canonical.
    Falls back to a full -Scan when not in a git working tree.

.EXAMPLE
    pwsh -File ./validate-implements-ids.ps1 ./specs/007-bridge-commands

.EXAMPLE
    pwsh -File ./validate-implements-ids.ps1 -Canonical specs/feat/v-model -Scan . -ChangedOnly

.NOTES
    Implements: REQ-NF-006, REQ-NF-002, REQ-023, REQ-NF-004,
                SYS-006, ARCH-009, MOD-013, MOD-025,
                UTP-013-A, UTP-025-A, D-009, D-004, D-008.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$FeatureDir,
    [string]$Canonical,
    [string]$Scan,
    [switch]$ChangedOnly
)

$ErrorActionPreference = 'Stop'

if ($FeatureDir -in @('--help', '-h', '-Help')) {
    Write-Output 'Usage: validate-implements-ids.ps1 [<feature-dir>] [-Canonical <path>] [-Scan <path>] [-ChangedOnly]'
    exit 0
}

# Resolution rules mirror the bash sibling:
#  1. Positional <feature-dir> alone → defaults derived from it.
#  2. Explicit flags override defaults.
#  3. Both Canonical and Scan must end up resolved to existing directories.
if (-not [string]::IsNullOrEmpty($FeatureDir)) {
    if (-not (Test-Path -LiteralPath $FeatureDir -PathType Container)) {
        [Console]::Error.WriteLine("ERROR: feature dir not found: $FeatureDir")
        exit 1
    }
    if ([string]::IsNullOrEmpty($Canonical)) { $Canonical = Join-Path $FeatureDir 'v-model' }
    if ([string]::IsNullOrEmpty($Scan))      { $Scan      = $FeatureDir }
}
else {
    if ([string]::IsNullOrEmpty($Canonical) -and [string]::IsNullOrEmpty($Scan)) {
        [Console]::Error.WriteLine('ERROR: feature-dir argument required (or pass -Canonical and -Scan)')
        exit 1
    }
    if ([string]::IsNullOrEmpty($Canonical)) {
        [Console]::Error.WriteLine('ERROR: -Canonical is required when -Scan is used without a feature-dir')
        exit 1
    }
    if ([string]::IsNullOrEmpty($Scan)) {
        [Console]::Error.WriteLine('ERROR: -Scan is required when -Canonical is used without a feature-dir')
        exit 1
    }
}

if (-not (Test-Path -LiteralPath $Canonical -PathType Container)) {
    [Console]::Error.WriteLine("ERROR: canonical dir not found: $Canonical")
    exit 1
}
if (-not (Test-Path -LiteralPath $Scan -PathType Container)) {
    [Console]::Error.WriteLine("ERROR: scan dir not found: $Scan")
    exit 1
}

$VModelDir = $Canonical

# Per-category source-of-truth extraction (D-008): each ID family is canonical
# only if it appears in its owning artifact. Sensitive to fixture mutation
# (HAZ-023 stale-snapshot mitigation).
$canonicalSet = [System.Collections.Generic.HashSet[string]]::new()

function Add-CanonicalIds {
    param([string]$File, [string]$PrefixPattern)
    if (-not (Test-Path -LiteralPath $File -PathType Leaf)) { return }
    $content = Get-Content -Raw -LiteralPath $File
    if ($null -eq $content) { return }
    $regex = "\b(?:$PrefixPattern)-[0-9]+(?:-[A-Z][0-9]*)?\b"
    foreach ($m in [regex]::Matches($content, $regex)) {
        [void]$script:canonicalSet.Add($m.Value)
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
$tokenRe   = '[A-Z]{2,}-[A-Z0-9-]*[0-9][A-Z0-9-]*'
$keywordRe = '[Ii]mplements[: ]'

$scanRoot      = (Resolve-Path -LiteralPath $Scan).Path
$canonicalRoot = (Resolve-Path -LiteralPath $Canonical).Path
$canonicalBase = Split-Path -Leaf $canonicalRoot

# Determine candidate file set.
$useChangedOnly = $ChangedOnly.IsPresent
$files = @()

if ($useChangedOnly) {
    $gitCheck = & git -C $scanRoot rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($gitCheck)) {
        [Console]::Error.WriteLine("WARN: --changed-only: not a git working tree; falling back to full scan of $Scan")
        $useChangedOnly = $false
    }
    else {
        $tracked   = & git -C $scanRoot diff --name-only HEAD -- . 2>$null
        $staged    = & git -C $scanRoot diff --name-only --cached -- . 2>$null
        $untracked = & git -C $scanRoot ls-files --others --exclude-standard -- . 2>$null
        $rels = @(@($tracked) + @($staged) + @($untracked) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
        $candidates = New-Object System.Collections.Generic.List[System.IO.FileInfo]
        foreach ($rel in $rels) {
            $abs = Join-Path $scanRoot $rel
            if (-not (Test-Path -LiteralPath $abs -PathType Leaf)) { continue }
            $absFull = (Resolve-Path -LiteralPath $abs).Path
            if ($absFull -eq $canonicalRoot -or $absFull.StartsWith($canonicalRoot + [System.IO.Path]::DirectorySeparatorChar) -or $absFull.StartsWith($canonicalRoot + '/')) {
                continue
            }
            $candidates.Add((Get-Item -LiteralPath $absFull))
        }
        if ($candidates.Count -eq 0) {
            Write-Output 'GUARD: PASS (no changed files)'
            exit 0
        }
        $files = $candidates
    }
}

if (-not $useChangedOnly) {
    # Full recursive scan, skipping .git/, node_modules/, .session-tmp/, plus
    # the canonical-dir basename when canonical lives under scan.
    $excludeDirs = @('.git', 'node_modules', '.session-tmp')
    $canonicalUnderScan = ($canonicalRoot -eq $scanRoot) -or `
        $canonicalRoot.StartsWith($scanRoot + [System.IO.Path]::DirectorySeparatorChar) -or `
        $canonicalRoot.StartsWith($scanRoot + '/')
    if ($canonicalUnderScan -and -not [string]::IsNullOrEmpty($canonicalBase)) {
        $excludeDirs += $canonicalBase
    }
    $files = Get-ChildItem -LiteralPath $scanRoot -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $rel = $_.FullName.Substring($scanRoot.Length).TrimStart([char]'/', [char]'\')
            $segments = $rel -split '[\\/]'
            $isExcluded = $false
            foreach ($seg in $segments) {
                if ($excludeDirs -contains $seg) { $isExcluded = $true; break }
            }
            -not $isExcluded
        }
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
            if (-not $canonicalSet.Contains($id)) {
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
