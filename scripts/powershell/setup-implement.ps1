<#
.SYNOPSIS
    PowerShell mirror of scripts/bash/setup-implement.sh — bridge wrapper around
    .specify/scripts/powershell/check-prerequisites.ps1 that augments the
    upstream JSON with a top-level VMODEL_DIR field. Distinct file from
    setup-tasks.ps1 so per-command frontmatter wiring stays one-to-one.

.NOTES
    Implements: REQ-015, REQ-027, ARCH-014, MOD-021, D-001, D-014
    Repo root overridable via $env:SPECIFY_REPO_ROOT for test isolation.
    Assumption: upstream PS check-prerequisites uses -Json -RequireTasks
    -IncludeTasks (PascalCase mirror of bash flags).
#>
[CmdletBinding()]
param(
    [switch]$Json,
    [Parameter(ValueFromRemainingArguments = $true)]
    $Rest
)

$ErrorActionPreference = 'Stop'

function Resolve-RepoRoot {
    if ($env:SPECIFY_REPO_ROOT) { return $env:SPECIFY_REPO_ROOT }
    try {
        $r = & git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $r) { return $r.Trim() }
    } catch {}
    return (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
}

$RepoRoot = Resolve-RepoRoot
$Upstream = Join-Path $RepoRoot '.specify/scripts/powershell/check-prerequisites.ps1'

if (-not (Test-Path -LiteralPath $Upstream -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: upstream script not found: $Upstream")
    exit 2
}

$forwardArgs = @()
if ($Json) { $forwardArgs += '-Json' }
if ($Rest) { $forwardArgs += $Rest }

$upstreamOut = & $Upstream @forwardArgs
$rc = $LASTEXITCODE
if ($rc -ne 0) {
    if ($null -ne $upstreamOut) { $upstreamOut | ForEach-Object { Write-Output $_ } }
    exit $rc
}

$joined = ($upstreamOut -join "`n")

if ($Json) {
    try {
        $obj = $joined | ConvertFrom-Json -Depth 10
    } catch {
        [Console]::Error.WriteLine("ERROR: upstream did not emit valid JSON")
        exit 3
    }
    $featureDir = $null
    foreach ($name in @('FEATURE_DIR', 'FeatureDir')) {
        if ($obj.PSObject.Properties.Name -contains $name) {
            $featureDir = [string]$obj.$name
            break
        }
    }
    $vmodelDir = $null
    if ($featureDir -and (Test-Path -LiteralPath (Join-Path $featureDir 'v-model') -PathType Container)) {
        $vmodelDir = (Join-Path $featureDir 'v-model')
    }
    Add-Member -InputObject $obj -NotePropertyName 'VMODEL_DIR' -NotePropertyValue $vmodelDir -Force
    Write-Output ($obj | ConvertTo-Json -Compress -Depth 10)
} else {
    Write-Output $joined
    $featureDir = $null
    foreach ($line in ($joined -split "`n")) {
        if ($line -match '^FEATURE_DIR:\s*(.+)$') { $featureDir = $Matches[1].Trim(); break }
    }
    if ($featureDir -and (Test-Path -LiteralPath (Join-Path $featureDir 'v-model') -PathType Container)) {
        Write-Output "VMODEL_DIR: $(Join-Path $featureDir 'v-model')"
    } else {
        Write-Output 'VMODEL_DIR: (none)'
    }
}
