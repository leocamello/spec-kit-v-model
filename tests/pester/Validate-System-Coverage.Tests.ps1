#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures')
}

Describe 'Validate-System-Coverage' {
    Context 'Full coverage (minimal fixture)' {
        It 'exits 0 for full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" "$FixturesDir/minimal" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'shows success message' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'Full system-level coverage'
        }

        It 'JSON shows has_gaps false' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.has_gaps | Should -Be $false
        }

        It 'reports correct totals' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total_reqs | Should -Be 3
            $json.total_sys | Should -Be 3
            $json.total_stps | Should -Be 5
            $json.total_stss | Should -Be 5
        }
    }

    Context 'Complex fixture (many-to-many)' {
        It 'exits 0 for full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" "$FixturesDir/complex" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'REQ to SYS coverage is 100%' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" -Json "$FixturesDir/complex" 2>&1
            $json = $output | ConvertFrom-Json
            $json.req_to_sys_coverage_pct | Should -Be 100
        }

        It 'has 10 REQs and 6 SYS' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" -Json "$FixturesDir/complex" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total_reqs | Should -Be 10
            $json.total_sys | Should -Be 6
        }
    }

    Context 'Gaps fixture' {
        It 'exits 1 when gaps exist' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" "$FixturesDir/gaps" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
        }

        It 'detects uncovered REQ' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" "$FixturesDir/gaps" 2>&1
            ($output -join "`n") | Should -Match 'REQ-003'
        }

        It 'detects SYS without STP' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" "$FixturesDir/gaps" 2>&1
            ($output -join "`n") | Should -Match 'SYS-002'
        }

        It 'detects orphaned STP' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" "$FixturesDir/gaps" 2>&1
            ($output -join "`n") | Should -Match 'STP-099-A'
        }

        It 'JSON shows has_gaps true' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" -Json "$FixturesDir/gaps" 2>&1
            $json = $output | ConvertFrom-Json
            $json.has_gaps | Should -Be $true
        }
    }

    Context 'Empty fixture' {
        It 'exits 0 for empty but valid files' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" "$FixturesDir/empty" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'has zero counts' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" -Json "$FixturesDir/empty" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total_reqs | Should -Be 0
            $json.total_sys | Should -Be 0
        }
    }

    Context 'Error handling' {
        It 'exits 1 when vmodel-dir argument is missing' {
            & pwsh -NoProfile -Command "& '$ScriptsDir/validate-system-coverage.ps1'" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
        }

        It 'exits 1 when requirements.md is missing' {
            $tempDir = Join-Path $TestDrive 'missing-requirements'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $tempDir 'system-design.md') -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $tempDir 'system-test.md') -Force | Out-Null
            & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" $tempDir 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
        }

        It 'exits 1 when system-design.md is missing' {
            $tempDir = Join-Path $TestDrive 'missing-sysdesign'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $tempDir 'requirements.md') -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $tempDir 'system-test.md') -Force | Out-Null
            & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" $tempDir 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
        }

        It 'runs partial mode when system-test.md is missing' {
            $tempDir = Join-Path $TestDrive 'missing-systest'
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $tempDir 'requirements.md') -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $tempDir 'system-design.md') -Force | Out-Null
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" $tempDir 2>&1
            $LASTEXITCODE | Should -Be 0
            $output | Out-String | Should -Match 'Partial mode'
        }

        It '--help exits 0' {
            $output = & pwsh -NoProfile -Command "Get-Help '$ScriptsDir/validate-system-coverage.ps1'" 2>&1
            $LASTEXITCODE | Should -Be 0
            $output | Out-String | Should -Match '(?i)synopsis|description|usage'
        }
    }
}
