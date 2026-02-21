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

Describe 'Diff-Requirements' {
    Context 'No git history' {
        It 'treats all requirements as new when no git history' {
            $vmodelDir = Join-Path $TestDrive 'no-history/vmodel'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            Copy-Item (Join-Path $FixturesDir 'minimal/requirements.md') $vmodelDir
            Push-Location (Split-Path $vmodelDir)
            $output = & pwsh -NoProfile -File "$ScriptsDir/diff-requirements.ps1" -Json $vmodelDir 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.added | Should -Contain 'REQ-001'
            $json.added | Should -Contain 'REQ-002'
            $json.added | Should -Contain 'REQ-003'
            Pop-Location
        }
    }

    Context 'Detecting changes' {
        It 'detects added REQ' {
            $tempDir = Join-Path $TestDrive 'added-req'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            $vmodelDir = Join-Path $tempDir 'vmodel'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            Copy-Item (Join-Path $FixturesDir 'minimal/requirements.md') $vmodelDir
            Push-Location $tempDir
            git add .
            git commit --quiet -m 'Add requirements'
            Add-Content -Path (Join-Path $vmodelDir 'requirements.md') -Value '| REQ-004 | New requirement | P1 |'
            $output = & pwsh -NoProfile -File "$ScriptsDir/diff-requirements.ps1" -Json $vmodelDir 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.added | Should -Contain 'REQ-004'
            Pop-Location
        }

        It 'detects removed REQ' {
            $tempDir = Join-Path $TestDrive 'removed-req'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            $vmodelDir = Join-Path $tempDir 'vmodel'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            Copy-Item (Join-Path $FixturesDir 'minimal/requirements.md') $vmodelDir
            Push-Location $tempDir
            git add .
            git commit --quiet -m 'Add requirements'
            $reqFile = Join-Path $vmodelDir 'requirements.md'
            $content = Get-Content $reqFile | Where-Object { $_ -notmatch 'REQ-002' }
            $content | Set-Content $reqFile
            $output = & pwsh -NoProfile -File "$ScriptsDir/diff-requirements.ps1" -Json $vmodelDir 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.removed | Should -Contain 'REQ-002'
            Pop-Location
        }

        It 'detects modified REQ' {
            $tempDir = Join-Path $TestDrive 'modified-req'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            $vmodelDir = Join-Path $tempDir 'vmodel'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            Copy-Item (Join-Path $FixturesDir 'minimal/requirements.md') $vmodelDir
            Push-Location $tempDir
            git add .
            git commit --quiet -m 'Add requirements'
            $reqFile = Join-Path $vmodelDir 'requirements.md'
            $content = (Get-Content $reqFile -Raw) -replace '\| REQ-001 \| The system SHALL process sensor data \|', '| REQ-001 | The system SHALL capture sensor data |'
            $content | Set-Content $reqFile -NoNewline
            $output = & pwsh -NoProfile -File "$ScriptsDir/diff-requirements.ps1" -Json $vmodelDir 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.modified | Should -Contain 'REQ-001'
            Pop-Location
        }
    }

    Context 'JSON output' {
        It '--json outputs valid JSON' {
            $vmodelDir = Join-Path $TestDrive 'json-valid/vmodel'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            Copy-Item (Join-Path $FixturesDir 'minimal/requirements.md') $vmodelDir
            Push-Location (Split-Path $vmodelDir)
            $output = & pwsh -NoProfile -File "$ScriptsDir/diff-requirements.ps1" -Json $vmodelDir 2>&1
            $LASTEXITCODE | Should -Be 0
            { $output | ConvertFrom-Json } | Should -Not -Throw
            Pop-Location
        }
    }

    Context 'No changes' {
        It 'reports zero changes when file is unchanged' {
            $tempDir = Join-Path $TestDrive 'no-changes'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Initialize-GitRepo -Path $tempDir
            $vmodelDir = Join-Path $tempDir 'vmodel'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            Copy-Item (Join-Path $FixturesDir 'minimal/requirements.md') $vmodelDir
            Push-Location $tempDir
            git add .
            git commit --quiet -m 'Add requirements'
            $output = & pwsh -NoProfile -File "$ScriptsDir/diff-requirements.ps1" -Json $vmodelDir 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.total_changed | Should -Be 0
            Pop-Location
        }
    }
}
