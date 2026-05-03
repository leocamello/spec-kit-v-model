#Requires -Modules Pester
#
# Implements: REQ-024, SYS-008, ARCH-011, MOD-015, HAZ-015, HAZ-024, D-003

BeforeAll {
    $script:ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $script:Script     = Join-Path $script:ScriptsDir 'validate-domain-profile.ps1'

    function Initialize-Repo {
        param([string]$Root)
        $base = Join-Path $Root ([System.IO.Path]::GetRandomFileName())
        New-Item -ItemType Directory -Force -Path (Join-Path $base 'commands/overlays/iso_26262') | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $base 'commands/overlays/do_178c')   | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $base 'commands/overlays/iec_62304') | Out-Null
        return $base
    }
}

Describe 'Validate-Domain-Profile (PowerShell — MF-7)' {

    It "absent v-model-config.yml → exit 0 with 'DOMAIN: SKIP' (MOD-015)" {
        $repo = Initialize-Repo $TestDrive
        $output = & pwsh -NoProfile -File $script:Script $repo 2>&1
        $LASTEXITCODE | Should -Be 0
        ($output | Out-String) | Should -Match 'DOMAIN: SKIP'
    }

    It 'valid domain iso_26262 → exit 0 with PASS line (REQ-024, ARCH-011)' {
        $repo = Initialize-Repo $TestDrive
        Set-Content -LiteralPath (Join-Path $repo 'v-model-config.yml') -Value "domain: iso_26262"
        $output = & pwsh -NoProfile -File $script:Script $repo 2>&1
        $LASTEXITCODE | Should -Be 0
        ($output | Out-String).Trim() | Should -Be 'DOMAIN: PASS (domain=iso_26262)'
    }

    It 'valid domain do_178c with inline comment → exit 0' {
        $repo = Initialize-Repo $TestDrive
        Set-Content -LiteralPath (Join-Path $repo 'v-model-config.yml') -Value "domain: do_178c   # trailing comment"
        $output = & pwsh -NoProfile -File $script:Script $repo 2>&1
        $LASTEXITCODE | Should -Be 0
        ($output | Out-String).Trim() | Should -Be 'DOMAIN: PASS (domain=do_178c)'
    }

    It 'invalid domain foo → exit 1 + stderr names invalid value (SYS-008)' {
        $repo = Initialize-Repo $TestDrive
        Set-Content -LiteralPath (Join-Path $repo 'v-model-config.yml') -Value "domain: foo"
        $output = & pwsh -NoProfile -File $script:Script $repo 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output | Out-String) | Should -Match 'invalid domain'
    }

    It "missing 'domain:' key → exit 1 (HAZ-024)" {
        $repo = Initialize-Repo $TestDrive
        Set-Content -LiteralPath (Join-Path $repo 'v-model-config.yml') -Value "# comment only`nother_key: value"
        $output = & pwsh -NoProfile -File $script:Script $repo 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output | Out-String) | Should -Match "missing key 'domain:'"
    }

    It 'valid domain but overlay dir missing → exit 1 (HAZ-015)' {
        $repo = Initialize-Repo $TestDrive
        Remove-Item -Recurse -Force (Join-Path $repo 'commands/overlays/iec_62304')
        Set-Content -LiteralPath (Join-Path $repo 'v-model-config.yml') -Value "domain: iec_62304"
        $output = & pwsh -NoProfile -File $script:Script $repo 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output | Out-String) | Should -Match 'overlay directory not found'
    }
}
