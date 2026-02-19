<#
.SYNOPSIS
    V-Model directory setup and prerequisite checking script.

.DESCRIPTION
    Locates the repository root and feature directory, creates the v-model
    directory if needed, and checks for prerequisite documents.

.PARAMETER Json
    Output in JSON format.

.PARAMETER RequireReqs
    Require requirements.md to exist.

.PARAMETER RequireAcceptance
    Require acceptance-plan.md to exist.

.EXAMPLE
    ./setup-v-model.ps1 -Json
#>

[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$RequireReqs,
    [switch]$RequireAcceptance
)

$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    try {
        $root = git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $root) {
            return $root.Trim()
        }
    } catch {}

    $scriptDir = Split-Path -Parent $PSCommandPath
    return (Resolve-Path (Join-Path $scriptDir '../../../../..')).Path
}

function Get-CurrentBranch {
    if ($env:SPECIFY_FEATURE) {
        return $env:SPECIFY_FEATURE
    }

    try {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -eq 0 -and $branch) {
            return $branch.Trim()
        }
    } catch {}

    $repoRoot = Get-RepoRoot
    $specsDir = Join-Path $repoRoot 'specs'
    if (Test-Path $specsDir -PathType Container) {
        $latestFeature = ''
        $highest = 0
        foreach ($dir in Get-ChildItem -Path $specsDir -Directory) {
            if ($dir.Name -match '^(\d{3})-') {
                $number = [int]$Matches[1]
                if ($number -gt $highest) {
                    $highest = $number
                    $latestFeature = $dir.Name
                }
            }
        }
        if ($latestFeature) {
            return $latestFeature
        }
    }

    return 'main'
}

function Find-FeatureDir {
    param([string]$RepoRoot, [string]$Branch)

    $specsDir = Join-Path $RepoRoot 'specs'
    if ($Branch -match '^(\d{3})-') {
        $prefix = $Matches[1]
        $candidates = Get-ChildItem -Path $specsDir -Directory -Filter "$prefix-*" -ErrorAction SilentlyContinue
        if ($candidates) {
            return $candidates[0].FullName
        }
    }
    return Join-Path $specsDir $Branch
}

$RepoRoot = Get-RepoRoot
$Branch = Get-CurrentBranch
$FeatureDir = Find-FeatureDir -RepoRoot $RepoRoot -Branch $Branch
$VModelDir = Join-Path $FeatureDir 'v-model'

# Create v-model directory if it doesn't exist
if (-not (Test-Path $VModelDir)) {
    New-Item -ItemType Directory -Path $VModelDir -Force | Out-Null
}

$Requirements = Join-Path $VModelDir 'requirements.md'
$Acceptance = Join-Path $VModelDir 'acceptance-plan.md'
$TraceMatrix = Join-Path $VModelDir 'traceability-matrix.md'
$Spec = Join-Path $FeatureDir 'spec.md'

# Prerequisite checks
if ($RequireReqs -and -not (Test-Path $Requirements)) {
    Write-Error "ERROR: requirements.md not found in $VModelDir`nRun /speckit.v-model.requirements first."
    exit 1
}

if ($RequireAcceptance -and -not (Test-Path $Acceptance)) {
    Write-Error "ERROR: acceptance-plan.md not found in $VModelDir`nRun /speckit.v-model.acceptance first."
    exit 1
}

# Build available docs list
$docs = @()
if (Test-Path $Spec)        { $docs += 'spec.md' }
if (Test-Path $Requirements) { $docs += 'requirements.md' }
if (Test-Path $Acceptance)   { $docs += 'acceptance-plan.md' }
if (Test-Path $TraceMatrix)  { $docs += 'traceability-matrix.md' }

if ($Json) {
    $output = [ordered]@{
        REPO_ROOT      = $RepoRoot
        BRANCH         = $Branch
        FEATURE_DIR    = $FeatureDir
        VMODEL_DIR     = $VModelDir
        SPEC           = $Spec
        REQUIREMENTS   = $Requirements
        ACCEPTANCE     = $Acceptance
        TRACE_MATRIX   = $TraceMatrix
        AVAILABLE_DOCS = $docs
    }
    $output | ConvertTo-Json -Compress
} else {
    Write-Output "REPO_ROOT: $RepoRoot"
    Write-Output "BRANCH: $Branch"
    Write-Output "FEATURE_DIR: $FeatureDir"
    Write-Output "VMODEL_DIR: $VModelDir"
    Write-Output "AVAILABLE_DOCS:"
    $checkMark = if (Test-Path $Spec)        { '✓' } else { '✗' }; Write-Output "  $checkMark spec.md"
    $checkMark = if (Test-Path $Requirements) { '✓' } else { '✗' }; Write-Output "  $checkMark requirements.md"
    $checkMark = if (Test-Path $Acceptance)   { '✓' } else { '✗' }; Write-Output "  $checkMark acceptance-plan.md"
    $checkMark = if (Test-Path $TraceMatrix)  { '✓' } else { '✗' }; Write-Output "  $checkMark traceability-matrix.md"
}
