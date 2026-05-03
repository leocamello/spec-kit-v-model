<#
.SYNOPSIS
    Domain-overlay configuration sub-validator (PowerShell mirror of validate-domain-profile.sh).

.DESCRIPTION
    Non-fatal warning when v-model-config.yml is absent (DOMAIN: SKIP, exit 0).
    Fatal when present-and-invalid: unsupported `domain:` value, missing
    `domain:` key, or overlay directory not found. Pure-shell YAML extraction
    (regex over the file contents) — no yq or Python (D-001).

.PARAMETER RepoRoot
    Repository root. Defaults to `git rev-parse --show-toplevel` then '.'.

.NOTES
    Implements: REQ-024, SYS-008, ARCH-011, MOD-015, HAZ-015, HAZ-024, D-003.
#>

[CmdletBinding()]
param([Parameter(Position = 0)][string]$RepoRoot)

$ErrorActionPreference = 'Stop'

if ($RepoRoot -in @('--help', '-h', '-Help')) {
    Write-Output 'Usage: validate-domain-profile.ps1 [<repo-root>]'
    exit 0
}

if ([string]::IsNullOrEmpty($RepoRoot)) {
    try {
        $RepoRoot = (& git rev-parse --show-toplevel 2>$null).Trim()
        if ([string]::IsNullOrEmpty($RepoRoot)) { $RepoRoot = '.' }
    } catch { $RepoRoot = '.' }
}
if (-not (Test-Path -LiteralPath $RepoRoot -PathType Container)) {
    [Console]::Error.WriteLine("ERROR: repo-root not found: $RepoRoot")
    exit 1
}

$cfg = Join-Path $RepoRoot 'v-model-config.yml'
if (-not (Test-Path -LiteralPath $cfg -PathType Leaf)) {
    Write-Output 'DOMAIN: SKIP (no v-model-config.yml)'
    exit 0
}

$domainValue = $null
foreach ($line in (Get-Content -LiteralPath $cfg)) {
    if ($line -match '^domain:\s*(.*)$') {
        $raw = $Matches[1]
        # Strip inline comments and surrounding quotes/whitespace.
        $raw = ($raw -replace '\s+#.*$', '').Trim()
        $raw = $raw -replace '^["'']', '' -replace '["'']$', ''
        $domainValue = $raw.Trim()
        break
    }
}

if ([string]::IsNullOrEmpty($domainValue)) {
    [Console]::Error.WriteLine("DOMAIN: missing key 'domain:' in v-model-config.yml")
    exit 1
}

$valid = @('iso_26262', 'do_178c', 'iec_62304')
if ($valid -notcontains $domainValue) {
    [Console]::Error.WriteLine("DOMAIN: invalid domain `"$domainValue`"")
    exit 1
}

$overlay = Join-Path (Join-Path $RepoRoot 'commands/overlays') $domainValue
if (-not (Test-Path -LiteralPath $overlay -PathType Container)) {
    [Console]::Error.WriteLine("DOMAIN: overlay directory not found: commands/overlays/$domainValue")
    exit 1
}

Write-Output "DOMAIN: PASS (domain=$domainValue)"
