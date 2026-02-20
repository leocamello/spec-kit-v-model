#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures')
}

Describe 'Validate-System-Coverage' {
    Context 'Full coverage (system-design-minimal fixture)' {
        It 'exits 0 for full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" "$FixturesDir/system-design-minimal" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'JSON shows has_gaps false' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" -Json "$FixturesDir/system-design-minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.has_gaps | Should -Be $false
        }

        It '--json outputs valid JSON' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" -Json "$FixturesDir/system-design-minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            { $output | ConvertFrom-Json } | Should -Not -Throw
        }

        It 'reports correct totals' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" -Json "$FixturesDir/system-design-minimal" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total_reqs | Should -Be 3
            $json.total_sys | Should -Be 3
            $json.total_stps | Should -Be 3
            $json.total_stss | Should -Be 3
        }
    }

    Context 'Complex fixture (many-to-many)' {
        It 'exits 0 for full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" "$FixturesDir/system-design-complex" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'handles many-to-many REQ-SYS mapping' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" -Json "$FixturesDir/system-design-complex" 2>&1
            $json = $output | ConvertFrom-Json
            $json.req_to_sys_coverage_pct | Should -Be 100
        }
    }

    Context 'Gaps fixture' {
        It 'exits 1 when gaps exist' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" "$FixturesDir/system-design-gaps" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
        }

        It 'identifies REQ-003 as uncovered' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" -Json "$FixturesDir/system-design-gaps" 2>&1
            $json = $output | ConvertFrom-Json
            $json.reqs_without_sys | Should -Contain 'REQ-003'
        }

        It 'identifies orphaned STP' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" -Json "$FixturesDir/system-design-gaps" 2>&1
            $json = $output | ConvertFrom-Json
            $json.orphaned_stps | Should -Contain 'STP-099-A'
        }
    }

    Context 'Empty fixture' {
        It 'exits 0 for empty but valid files' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" "$FixturesDir/system-design-empty" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }
    }

    Context 'Error handling' {
        It 'exits 1 when directory is missing' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-system-coverage.ps1" '/nonexistent' 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
        }
    }
}

Describe 'Build-Matrix - Matrix B' {
    Context 'Dual-matrix output' {
        It 'includes Matrix B when system artifacts exist' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/system-design-minimal" 2>&1
            $output | Should -Contain '## Matrix B — Verification (Architectural View)'
        }

        It 'Matrix B contains SYS components' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/system-design-minimal" 2>&1
            ($output -join "`n") | Should -Match 'SYS-001'
            ($output -join "`n") | Should -Match 'STP-001-A'
        }

        It 'shows Matrix B coverage metrics' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/system-design-minimal" 2>&1
            ($output -join "`n") | Should -Match 'REQ -> SYS Coverage'
        }
    }

    Context 'Backward compatibility' {
        It 'no Matrix B when system artifacts absent' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            ($output -join "`n") | Should -Not -Match 'Matrix B'
        }

        It 'Matrix A present regardless' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/system-design-minimal" 2>&1
            $output | Should -Contain '## Matrix A — Validation (User View)'
        }
    }
}
