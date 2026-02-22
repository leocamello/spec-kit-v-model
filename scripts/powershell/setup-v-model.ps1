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

.PARAMETER RequireSystemDesign
    Require system-design.md to exist.

.PARAMETER RequireSystemTest
    Require system-test.md to exist.

.PARAMETER RequireArchitectureDesign
    Require architecture-design.md to exist.

.PARAMETER RequireIntegrationTest
    Require integration-test.md to exist.

.PARAMETER RequireModuleDesign
    Require module-design.md to exist.

.PARAMETER RequireUnitTest
    Require unit-test.md to exist.

.EXAMPLE
    ./setup-v-model.ps1 -Json
#>

[CmdletBinding()]
param(
    [switch]$Json,
    [switch]$RequireReqs,
    [switch]$RequireAcceptance,
    [switch]$RequireSystemDesign,
    [switch]$RequireSystemTest,
    [switch]$RequireArchitectureDesign,
    [switch]$RequireIntegrationTest,
    [switch]$RequireModuleDesign,
    [switch]$RequireUnitTest
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
$SystemDesign = Join-Path $VModelDir 'system-design.md'
$SystemTest = Join-Path $VModelDir 'system-test.md'
$ArchDesign = Join-Path $VModelDir 'architecture-design.md'
$IntegrationTest = Join-Path $VModelDir 'integration-test.md'
$ModuleDesign = Join-Path $VModelDir 'module-design.md'
$UnitTestDoc = Join-Path $VModelDir 'unit-test.md'
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

if ($RequireSystemDesign -and -not (Test-Path $SystemDesign)) {
    Write-Error "ERROR: system-design.md not found in $VModelDir`nRun /speckit.v-model.system-design first."
    exit 1
}

if ($RequireSystemTest -and -not (Test-Path $SystemTest)) {
    Write-Error "ERROR: system-test.md not found in $VModelDir`nRun /speckit.v-model.system-test first."
    exit 1
}

if ($RequireArchitectureDesign -and -not (Test-Path $ArchDesign)) {
    Write-Error "ERROR: architecture-design.md not found in $VModelDir`nRun /speckit.v-model.architecture-design first."
    exit 1
}

if ($RequireIntegrationTest -and -not (Test-Path $IntegrationTest)) {
    Write-Error "ERROR: integration-test.md not found in $VModelDir`nRun /speckit.v-model.integration-test first."
    exit 1
}

if ($RequireModuleDesign -and -not (Test-Path $ModuleDesign)) {
    Write-Error "ERROR: module-design.md not found in $VModelDir`nRun /speckit.v-model.module-design first."
    exit 1
}

if ($RequireUnitTest -and -not (Test-Path $UnitTestDoc)) {
    Write-Error "ERROR: unit-test.md not found in $VModelDir`nRun /speckit.v-model.unit-test first."
    exit 1
}

# Build available docs list
$docs = @()
if (Test-Path $Spec)        { $docs += 'spec.md' }
if (Test-Path $Requirements) { $docs += 'requirements.md' }
if (Test-Path $Acceptance)   { $docs += 'acceptance-plan.md' }
if (Test-Path $TraceMatrix)  { $docs += 'traceability-matrix.md' }
if (Test-Path $SystemDesign) { $docs += 'system-design.md' }
if (Test-Path $SystemTest)   { $docs += 'system-test.md' }
if (Test-Path $ArchDesign)   { $docs += 'architecture-design.md' }
if (Test-Path $IntegrationTest) { $docs += 'integration-test.md' }
if (Test-Path $ModuleDesign) { $docs += 'module-design.md' }
if (Test-Path $UnitTestDoc)  { $docs += 'unit-test.md' }

if ($Json) {
    $output = [ordered]@{
        REPO_ROOT        = $RepoRoot
        BRANCH           = $Branch
        FEATURE_DIR      = $FeatureDir
        VMODEL_DIR       = $VModelDir
        SPEC             = $Spec
        REQUIREMENTS     = $Requirements
        ACCEPTANCE       = $Acceptance
        TRACE_MATRIX     = $TraceMatrix
        SYSTEM_DESIGN    = $SystemDesign
        SYSTEM_TEST      = $SystemTest
        ARCH_DESIGN      = $ArchDesign
        INTEGRATION_TEST = $IntegrationTest
        MODULE_DESIGN    = $ModuleDesign
        UNIT_TEST        = $UnitTestDoc
        AVAILABLE_DOCS   = $docs
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
    $checkMark = if (Test-Path $SystemDesign) { '✓' } else { '✗' }; Write-Output "  $checkMark system-design.md"
    $checkMark = if (Test-Path $SystemTest)   { '✓' } else { '✗' }; Write-Output "  $checkMark system-test.md"
    $checkMark = if (Test-Path $ArchDesign)   { '✓' } else { '✗' }; Write-Output "  $checkMark architecture-design.md"
    $checkMark = if (Test-Path $IntegrationTest) { '✓' } else { '✗' }; Write-Output "  $checkMark integration-test.md"
    $checkMark = if (Test-Path $ModuleDesign) { '✓' } else { '✗' }; Write-Output "  $checkMark module-design.md"
    $checkMark = if (Test-Path $UnitTestDoc)  { '✓' } else { '✗' }; Write-Output "  $checkMark unit-test.md"
}
