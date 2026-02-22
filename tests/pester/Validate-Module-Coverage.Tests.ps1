#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures')
}

Describe 'Validate-Module-Coverage' {
    Context 'Full coverage (minimal fixture)' {
        It 'exits 0 for full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" "$FixturesDir/minimal" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'shows success message' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match '(?i)coverage'
        }

        It 'JSON shows has_gaps false' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.has_gaps | Should -Be $false
        }

        It 'reports correct totals' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total_arch | Should -Be 4
            $json.total_mod | Should -Be 4
            $json.total_utps | Should -Be 6
            $json.total_utss | Should -Be 13
        }

        It 'has zero external modules' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total_external | Should -Be 0
        }
    }

    Context 'Complex fixture ([EXTERNAL] + [CROSS-CUTTING] + stateful)' {
        It 'exits 0 for full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" "$FixturesDir/complex" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'JSON shows has_gaps false' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" -Json "$FixturesDir/complex" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.has_gaps | Should -Be $false
        }

        It 'detects external modules' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" -Json "$FixturesDir/complex" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total_external | Should -BeGreaterOrEqual 1
        }
    }

    Context 'Gaps fixture' {
        It 'exits 1 when gaps exist' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" "$FixturesDir/gaps" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
        }

        It 'JSON shows has_gaps true' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" -Json "$FixturesDir/gaps" 2>&1
            $json = $output | ConvertFrom-Json
            $json.has_gaps | Should -Be $true
        }

        It 'reports MOD-002 uncovered' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" -Json "$FixturesDir/gaps" 2>&1
            ($output -join "`n") | Should -Match 'MOD-002'
        }

        It 'reports orphaned MOD-099' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" -Json "$FixturesDir/gaps" 2>&1
            ($output -join "`n") | Should -Match 'MOD-099'
        }
    }

    Context 'Empty fixture' {
        It 'exits 0 for empty but valid files' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" "$FixturesDir/empty" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'has zero counts' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-module-coverage.ps1" -Json "$FixturesDir/empty" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total_arch | Should -Be 0
            $json.total_mod | Should -Be 0
        }
    }

    Context 'Error handling' {
        It 'exits 1 when vmodel-dir argument is missing' {
            & pwsh -NoProfile -Command "& '$ScriptsDir/validate-module-coverage.ps1'" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
        }

        It '--help exits 0' {
            $output = & pwsh -NoProfile -Command "Get-Help '$ScriptsDir/validate-module-coverage.ps1'" 2>&1
            $LASTEXITCODE | Should -Be 0
            $output | Out-String | Should -Match '(?i)synopsis|description|usage'
        }
    }
}
