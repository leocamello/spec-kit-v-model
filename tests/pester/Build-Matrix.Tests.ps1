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
            $text | Should -Match 'REQ-NF-001'
        }

        It 'coverage metrics in output' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            $output | Out-String | Should -Match 'Coverage Metrics'
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
}
