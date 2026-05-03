#Requires -Modules Pester
#
# Implements: REQ-015, REQ-027, ARCH-014, MOD-021, D-001, D-014
# Pester mirror of tests/bats/setup-implement.bats — exercises the
# scripts/powershell/setup-implement.ps1 bridge wrapper with a stub upstream
# injected via $env:SPECIFY_REPO_ROOT.

BeforeAll {
    $script:Wrapper = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell/setup-implement.ps1')

    function New-StubRepo {
        param([string]$Root, [int]$ExitCode = 0, [string]$FeatureDir)
        $upstreamDir = Join-Path $Root '.specify/scripts/powershell'
        New-Item -ItemType Directory -Path $upstreamDir -Force | Out-Null
        New-Item -ItemType Directory -Path $FeatureDir -Force | Out-Null
        $stub = @"
[CmdletBinding()] param([switch]`$Json, [Parameter(ValueFromRemainingArguments=`$true)] `$Rest)
@{ FEATURE_DIR = '$($FeatureDir -replace "'", "''")'; AVAILABLE_DOCS = @('tasks.md') } | ConvertTo-Json -Compress
exit $ExitCode
"@
        Set-Content -LiteralPath (Join-Path $upstreamDir 'check-prerequisites.ps1') -Value $stub -Encoding utf8
    }
}

Describe 'setup-implement.ps1 bridge wrapper' {
    BeforeEach {
        $script:Sandbox = Join-Path $TestDrive ([System.IO.Path]::GetRandomFileName())
        $script:StubRepo = Join-Path $Sandbox 'repo'
        $script:FeatureDir = Join-Path $StubRepo 'specs/007-feature'
        New-Item -ItemType Directory -Path $StubRepo -Force | Out-Null
        $env:SPECIFY_REPO_ROOT = $StubRepo
    }

    AfterEach {
        Remove-Item Env:SPECIFY_REPO_ROOT -ErrorAction SilentlyContinue
    }

    It 'JSON output is well-formed and contains VMODEL_DIR key' {
        New-StubRepo -Root $StubRepo -ExitCode 0 -FeatureDir $FeatureDir
        New-Item -ItemType Directory -Path (Join-Path $FeatureDir 'v-model') -Force | Out-Null
        $out = & pwsh -NoProfile -File $Wrapper -Json -RequireTasks -IncludeTasks 2>&1
        $LASTEXITCODE | Should -Be 0
        $out -join "`n" | Should -Match '"VMODEL_DIR"'
        { ($out -join "`n") | ConvertFrom-Json } | Should -Not -Throw
    }

    It 'VMODEL_DIR is null when v-model directory absent' {
        New-StubRepo -Root $StubRepo -ExitCode 0 -FeatureDir $FeatureDir
        $out = & pwsh -NoProfile -File $Wrapper -Json 2>&1
        $LASTEXITCODE | Should -Be 0
        $obj = ($out -join "`n") | ConvertFrom-Json
        $obj.VMODEL_DIR | Should -BeNullOrEmpty
    }

    It 'VMODEL_DIR points at <feature>/v-model when present' {
        New-StubRepo -Root $StubRepo -ExitCode 0 -FeatureDir $FeatureDir
        New-Item -ItemType Directory -Path (Join-Path $FeatureDir 'v-model') -Force | Out-Null
        $out = & pwsh -NoProfile -File $Wrapper -Json 2>&1
        $LASTEXITCODE | Should -Be 0
        $obj = ($out -join "`n") | ConvertFrom-Json
        $obj.VMODEL_DIR | Should -Be (Join-Path $FeatureDir 'v-model')
    }

    It 'Wrapper exits 2 with stderr message when upstream missing' {
        $out = & pwsh -NoProfile -File $Wrapper -Json 2>&1
        $LASTEXITCODE | Should -Be 2
        ($out -join "`n") | Should -Match 'upstream'
    }

    It 'Non-zero upstream exit code is propagated' {
        New-StubRepo -Root $StubRepo -ExitCode 7 -FeatureDir $FeatureDir
        $null = & pwsh -NoProfile -File $Wrapper -Json 2>&1
        $LASTEXITCODE | Should -Be 7
    }
}
