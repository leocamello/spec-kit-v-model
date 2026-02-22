#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures')

    function Initialize-GitRepo {
        param([string]$Path)
        Push-Location $Path
        git init --quiet
        git config user.email 'test@example.com'
        git config user.name 'Test'
        New-Item -ItemType File -Path (Join-Path $Path '.gitkeep') -Force | Out-Null
        git add .
        git commit --quiet -m 'Initial commit'
        Pop-Location
    }
}

Describe 'Setup-VModel' {
    Context 'Directory creation' {
        It 'creates v-model directory' {
            $tempDir = Join-Path $TestDrive 'creates-vmodel'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            Push-Location $tempDir
            git checkout -b 001-test --quiet
            $output = & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" 2>&1
            $LASTEXITCODE | Should -Be 0
            Join-Path $tempDir 'specs/001-test/v-model' | Should -Exist
            Pop-Location
        }
    }

    Context 'Document detection' {
        It 'detects existing requirements.md' {
            $tempDir = Join-Path $TestDrive 'detects-reqs'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            Push-Location $tempDir
            git checkout -b 001-test --quiet
            $vmodelDir = Join-Path $tempDir 'specs/001-test/v-model'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $vmodelDir 'requirements.md') -Force | Out-Null
            $output = & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" -Json 2>&1
            $LASTEXITCODE | Should -Be 0
            $output | Should -Match 'requirements\.md'
            Pop-Location
        }
    }

    Context 'Prerequisite checks' {
        It '--require-reqs fails when requirements.md is missing' {
            $tempDir = Join-Path $TestDrive 'require-reqs'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            Push-Location $tempDir
            git checkout -b 001-test --quiet
            $vmodelDir = Join-Path $tempDir 'specs/001-test/v-model'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" -RequireReqs 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
            Pop-Location
        }

        It '--require-acceptance fails when acceptance-plan.md is missing' {
            $tempDir = Join-Path $TestDrive 'require-acceptance'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            Push-Location $tempDir
            git checkout -b 001-test --quiet
            $vmodelDir = Join-Path $tempDir 'specs/001-test/v-model'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $vmodelDir 'requirements.md') -Force | Out-Null
            & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" -RequireAcceptance 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
            Pop-Location
        }

        It '--require-system-test fails when system-test.md is missing' {
            $tempDir = Join-Path $TestDrive 'require-system-test'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            Push-Location $tempDir
            git checkout -b 001-test --quiet
            $vmodelDir = Join-Path $tempDir 'specs/001-test/v-model'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" -RequireSystemTest 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
            Pop-Location
        }

        It '--require-architecture-design fails when architecture-design.md is missing' {
            $tempDir = Join-Path $TestDrive 'require-arch-design'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            Push-Location $tempDir
            git checkout -b 001-test --quiet
            $vmodelDir = Join-Path $tempDir 'specs/001-test/v-model'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" -RequireArchitectureDesign 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
            Pop-Location
        }

        It '--require-integration-test fails when integration-test.md is missing' {
            $tempDir = Join-Path $TestDrive 'require-integ-test'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            Push-Location $tempDir
            git checkout -b 001-test --quiet
            $vmodelDir = Join-Path $tempDir 'specs/001-test/v-model'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" -RequireIntegrationTest 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
            Pop-Location
        }

        It '--require-module-design fails when module-design.md is missing' {
            $tempDir = Join-Path $TestDrive 'require-mod-design'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            Push-Location $tempDir
            git checkout -b 001-test --quiet
            $vmodelDir = Join-Path $tempDir 'specs/001-test/v-model'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" -RequireModuleDesign 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
            Pop-Location
        }

        It '--require-unit-test fails when unit-test.md is missing' {
            $tempDir = Join-Path $TestDrive 'require-unit-test'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            Push-Location $tempDir
            git checkout -b 001-test --quiet
            $vmodelDir = Join-Path $tempDir 'specs/001-test/v-model'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" -RequireUnitTest 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
            Pop-Location
        }
    }

    Context 'Module-level document detection' {
        It 'detects existing module-design.md' {
            $tempDir = Join-Path $TestDrive 'detects-mod-design'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            Push-Location $tempDir
            git checkout -b 001-test --quiet
            $vmodelDir = Join-Path $tempDir 'specs/001-test/v-model'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $vmodelDir 'module-design.md') -Force | Out-Null
            $output = & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" -Json 2>&1
            $LASTEXITCODE | Should -Be 0
            $output | Should -Match 'module-design\.md'
            Pop-Location
        }

        It 'detects existing unit-test.md' {
            $tempDir = Join-Path $TestDrive 'detects-unit-test'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            Push-Location $tempDir
            git checkout -b 001-test --quiet
            $vmodelDir = Join-Path $tempDir 'specs/001-test/v-model'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $vmodelDir 'unit-test.md') -Force | Out-Null
            $output = & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" -Json 2>&1
            $LASTEXITCODE | Should -Be 0
            $output | Should -Match 'unit-test\.md'
            Pop-Location
        }
    }

    Context 'JSON output' {
        It '--json outputs valid JSON' {
            $tempDir = Join-Path $TestDrive 'json-output'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            Push-Location $tempDir
            git checkout -b 001-test --quiet
            $output = & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" -Json 2>&1
            $LASTEXITCODE | Should -Be 0
            { $output | ConvertFrom-Json } | Should -Not -Throw
            Pop-Location
        }
    }

    Context 'Edge cases' {
        It 'works outside git repo' {
            $tempDir = Join-Path $TestDrive 'no-git'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Push-Location $tempDir
            $output = & pwsh -NoProfile -File "$ScriptsDir/setup-v-model.ps1" 2>&1
            $LASTEXITCODE | Should -Be 0
            Pop-Location
        }

        It '--help shows usage' {
            $output = & pwsh -NoProfile -Command "Get-Help '$ScriptsDir/setup-v-model.ps1'" 2>&1
            $output | Out-String | Should -Match '(?i)synopsis|description|setup'
        }
    }
}
