#Requires -Modules Pester
#
# Implements: REQ-016, SYS-004, ARCH-007, ARCH-016, MOD-010, MOD-021, HAZ-009, HAZ-010, D-003

BeforeAll {
    $script:ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $script:Script     = Join-Path $script:ScriptsDir 'validate-artifact-status.ps1'
    $script:Artifacts  = @(
        'requirements.md', 'system-design.md', 'architecture-design.md',
        'module-design.md', 'hazard-analysis.md', 'unit-test.md',
        'integration-test.md', 'system-test.md', 'acceptance-plan.md'
    )

    function Initialize-VModel {
        param([string]$Root)
        $base   = Join-Path $Root ([System.IO.Path]::GetRandomFileName())
        $vmodel = Join-Path $base 'v-model'
        New-Item -ItemType Directory -Force -Path $vmodel | Out-Null
        return $vmodel
    }

    function Set-Artifact {
        param([string]$VModelDir, [string]$Name, [string]$Status)
        $f = Join-Path $VModelDir $Name
        $body = "# $Name`n`n"
        if ($Status -ne '<NONE>') { $body += "**Status**: $Status`n`n" }
        $body += "Body content.`n"
        Set-Content -LiteralPath $f -Value $body -NoNewline
    }

    function Set-AllArtifacts {
        param([string]$VModelDir, [string]$Status)
        foreach ($a in $script:Artifacts) { Set-Artifact -VModelDir $VModelDir -Name $a -Status $Status }
    }
}

Describe 'Validate-Artifact-Status (PowerShell — MF-6)' {

    It "all-Approved fixture → exit 0 with 'STATUS: PASS' (REQ-016)" {
        $v = Initialize-VModel $TestDrive
        Set-AllArtifacts -VModelDir $v -Status 'Approved'
        $output = & pwsh -NoProfile -File $script:Script $v 2>&1
        $LASTEXITCODE | Should -Be 0
        ($output | Out-String).Trim() | Should -Be 'STATUS: PASS'
    }

    It 'one-Draft artifact → exit 1 + stderr names file with value Draft (HAZ-009)' {
        $v = Initialize-VModel $TestDrive
        Set-AllArtifacts -VModelDir $v -Status 'Approved'
        Set-Artifact -VModelDir $v -Name 'module-design.md' -Status 'Draft'
        $output = & pwsh -NoProfile -File $script:Script $v 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output | Out-String) | Should -Match 'STATUS: module-design\.md: Draft'
    }

    It 'missing **Status** header → exit 1 with value <missing> (HAZ-010)' {
        $v = Initialize-VModel $TestDrive
        Set-AllArtifacts -VModelDir $v -Status 'Approved'
        Set-Artifact -VModelDir $v -Name 'hazard-analysis.md' -Status '<NONE>'
        $output = & pwsh -NoProfile -File $script:Script $v 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output | Out-String) | Should -Match 'STATUS: hazard-analysis\.md: <missing>'
    }

    It 'unknown status value Frobbed → exit 1 + stderr names value (ARCH-007)' {
        $v = Initialize-VModel $TestDrive
        Set-AllArtifacts -VModelDir $v -Status 'Approved'
        Set-Artifact -VModelDir $v -Name 'system-design.md' -Status 'Frobbed'
        $output = & pwsh -NoProfile -File $script:Script $v 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output | Out-String) | Should -Match 'STATUS: system-design\.md: Frobbed'
    }

    It '-RequiredStatus override admits all-Draft fixture (MOD-010)' {
        $v = Initialize-VModel $TestDrive
        Set-AllArtifacts -VModelDir $v -Status 'Draft'
        $output = & pwsh -NoProfile -File $script:Script $v -RequiredStatus 'Draft,Approved' 2>&1
        $LASTEXITCODE | Should -Be 0
        ($output | Out-String).Trim() | Should -Be 'STATUS: PASS'
    }

    It 'body-occurrence of **Status** ignored — only first match consulted (HAZ-010)' {
        $v = Initialize-VModel $TestDrive
        Set-AllArtifacts -VModelDir $v -Status 'Approved'
        @"
# integration-test.md

**Status**: Approved

Body talks about a deferred row:
**Status**: DROP per drift-diff-plan.md.
"@ | Set-Content -LiteralPath (Join-Path $v 'integration-test.md')
        $output = & pwsh -NoProfile -File $script:Script $v 2>&1
        $LASTEXITCODE | Should -Be 0
        ($output | Out-String).Trim() | Should -Be 'STATUS: PASS'
    }

    It 'missing files are silently skipped (ARCH-016)' {
        $v = Initialize-VModel $TestDrive
        Set-Artifact -VModelDir $v -Name 'requirements.md' -Status 'Approved'
        Set-Artifact -VModelDir $v -Name 'system-design.md' -Status 'Approved'
        $output = & pwsh -NoProfile -File $script:Script $v 2>&1
        $LASTEXITCODE | Should -Be 0
        ($output | Out-String).Trim() | Should -Be 'STATUS: PASS'
    }

    It 'missing vmodel-dir argument → exit 1 (ARCH-007 §Error paths)' {
        & pwsh -NoProfile -File $script:Script 2>&1 | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
    }

    It 'non-existent vmodel-dir → exit 1' {
        & pwsh -NoProfile -File $script:Script (Join-Path $TestDrive 'nope') 2>&1 | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
    }
}
