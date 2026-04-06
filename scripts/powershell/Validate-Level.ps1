<#
.SYNOPSIS
    Dispatch wrapper that invokes the correct coverage validator for a given V-level.

.DESCRIPTION
    After each V-Model level pair is generated, this script selects and runs
    the appropriate validator:

      acceptance       -> validate-requirement-coverage.ps1
      system-test      -> validate-system-coverage.ps1
      integration-test -> validate-architecture-coverage.ps1
      unit-test        -> validate-module-coverage.ps1
      hazard-analysis  -> validate-hazard-coverage.ps1

.PARAMETER VModelDir
    Path to the directory containing V-Model artifacts.

.PARAMETER Level
    The V-level that was just completed.
    Valid values: acceptance, system-test, integration-test, unit-test, hazard-analysis

.PARAMETER Json
    Pass -Json to the underlying validator for JSON output.

.PARAMETER Partial
    Pass -Partial to the underlying validator (hazard-analysis only).

.EXAMPLE
    Validate-Level.ps1 ./my-project acceptance
    Validate-Level.ps1 -Json ./my-project unit-test

.NOTES
    Exit codes: 0 = pass, 1 = gaps found, 2 = invalid arguments
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$VModelDir,

    [Parameter(Position = 1)]
    [string]$Level,

    [switch]$Json,

    [switch]$Partial
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $VModelDir -or -not $Level) {
    [Console]::Error.WriteLine("Error: both <vmodel-dir> and <level> are required")
    [Console]::Error.WriteLine("Usage: Validate-Level.ps1 [-Json] [-Partial] <vmodel-dir> <level>")
    exit 2
}

if (-not (Test-Path -Path $VModelDir -PathType Container)) {
    [Console]::Error.WriteLine("Error: directory '$VModelDir' does not exist")
    exit 2
}

$LevelMap = @{
    "acceptance"       = "validate-requirement-coverage.ps1"
    "system-test"      = "validate-system-coverage.ps1"
    "integration-test" = "validate-architecture-coverage.ps1"
    "unit-test"        = "validate-module-coverage.ps1"
    "hazard-analysis"  = "validate-hazard-coverage.ps1"
}

if (-not $LevelMap.ContainsKey($Level)) {
    [Console]::Error.WriteLine("Error: unknown level '$Level'")
    [Console]::Error.WriteLine("Valid levels: acceptance, system-test, integration-test, unit-test, hazard-analysis")
    exit 2
}

$Validator = $LevelMap[$Level]
$ValidatorPath = Join-Path $ScriptDir $Validator

if (-not (Test-Path -Path $ValidatorPath)) {
    [Console]::Error.WriteLine("Error: validator not found at '$ValidatorPath'")
    exit 2
}

$ArgList = @("-NoProfile", "-File", $ValidatorPath)
if ($Json) { $ArgList += "-Json" }
if ($Partial -and $Level -eq "hazard-analysis") { $ArgList += "-Partial" }
$ArgList += $VModelDir

$proc = Start-Process -FilePath "pwsh" -ArgumentList $ArgList -NoNewWindow -Wait -PassThru
exit $proc.ExitCode
