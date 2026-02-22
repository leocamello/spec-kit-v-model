#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures')
}

Describe 'Build-Matrix' {
    Context 'Minimal fixture' {
        It 'generates markdown table' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            $output | Out-String | Should -Match 'Requirement ID'
        }

        It 'all REQs appear in output' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            $text = $output | Out-String
            $text | Should -Match 'REQ-001'
            $text | Should -Match 'REQ-002'
            $text | Should -Match 'REQ-003'
        }

        It 'coverage metrics in output' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            $output | Out-String | Should -Match 'Matrix A Coverage'
        }
    }

    Context 'Output to file' {
        It '--output writes to file' {
            $outFile = Join-Path $TestDrive 'matrix.md'
            & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" -Output $outFile 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
            $outFile | Should -Exist
            (Get-Item $outFile).Length | Should -BeGreaterThan 0
        }
    }

    Context 'Error handling' {
        It 'fails when acceptance-plan.md is missing' {
            $vmodelDir = Join-Path $TestDrive 'missing-acceptance'
            New-Item -ItemType Directory -Path $vmodelDir -Force | Out-Null
            Copy-Item (Join-Path $FixturesDir 'minimal/requirements.md') $vmodelDir
            & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" $vmodelDir 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
        }
    }

    Context 'Complex fixture' {
        It 'orphaned ATPs section populated' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/complex" 2>&1
            $LASTEXITCODE | Should -Be 0
            $output | Out-String | Should -Match 'ATP-999-A'
        }
    }

    Context 'Matrix B - system-level tests' {
        It 'includes Matrix B when system artifacts exist' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'Matrix B'
        }

        It 'Matrix B contains SYS components' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'SYS-001'
            ($output -join "`n") | Should -Match 'STP-001-A'
            ($output -join "`n") | Should -Match 'STS-001-A1'
        }

        It 'Matrix B shows coverage metrics' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'REQ .* SYS Coverage'
            ($output -join "`n") | Should -Match 'SYS .* STP Coverage'
        }

        It 'no Matrix B when system artifacts absent' {
            $tempDir = Join-Path $TestDrive 'no-system-vmodel'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Copy-Item (Join-Path $FixturesDir 'minimal/requirements.md') $tempDir
            Copy-Item (Join-Path $FixturesDir 'minimal/acceptance-plan.md') $tempDir
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" $tempDir 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Not -Match 'Matrix B'
        }

        It 'Matrix A present regardless of system artifacts' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'Matrix A'
        }

        It 'system gap analysis present when system artifacts exist' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'Uncovered Requirements'
            ($output -join "`n") | Should -Match 'Orphaned System Test Cases'
        }
    }

    Context 'Matrix D - module-level tests' {
        It 'includes Matrix D when module artifacts exist' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'Matrix D'
        }

        It 'Matrix D contains MOD and UTP identifiers' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'MOD-001'
            ($output -join "`n") | Should -Match 'UTP-001-A'
            ($output -join "`n") | Should -Match 'UTS-001-A1'
        }

        It 'Matrix D shows module coverage metrics' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            $text = ($output -join "`n")
            $text | Should -Match 'ARCH'
            $text | Should -Match 'MOD'
            $text | Should -Match 'UTP'
        }

        It 'no Matrix D when module artifacts absent' {
            $tempDir = Join-Path $TestDrive 'no-module-vmodel'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Copy-Item (Join-Path $FixturesDir 'minimal/requirements.md') $tempDir
            Copy-Item (Join-Path $FixturesDir 'minimal/acceptance-plan.md') $tempDir
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" $tempDir 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Not -Match 'Matrix D'
        }
    }
}
