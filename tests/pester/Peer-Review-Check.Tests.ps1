#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures/commands/peer-review/inputs')
}

Describe 'Peer-Review-Check' {
    Context 'Clean report (0 findings)' {
        It 'exits 0 for clean report' {
            & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" "$FixturesDir/clean-requirements.md" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'shows PASS message' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" "$FixturesDir/clean-requirements.md" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'PASS'
        }

        It 'JSON exit_code=0' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/clean-requirements.md" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.exit_code | Should -Be 0
        }

        It 'JSON total=0' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/clean-requirements.md" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.total | Should -Be 0
        }

        It 'JSON summary_match is true' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/clean-requirements.md" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.summary_match | Should -Be $true
        }

        It 'extracts artifact metadata' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/clean-requirements.md" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.artifact | Should -Match 'requirements\.md'
        }

        It 'extracts INCOSE standard' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/clean-requirements.md" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.standard | Should -Match 'INCOSE'
        }
    }

    Context 'Critical + Major findings (exit 1)' {
        It 'exits 1 for critical-major' {
            & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" "$FixturesDir/critical-major-requirements.md" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'shows FAIL message' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" "$FixturesDir/critical-major-requirements.md" 2>&1
            ($output -join "`n") | Should -Match 'FAIL'
        }

        It 'JSON exit_code=1' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/critical-major-requirements.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.exit_code | Should -Be 1
        }

        It 'counts 1 Critical' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/critical-major-requirements.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.critical | Should -Be 1
        }

        It 'counts 2 Major' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/critical-major-requirements.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.major | Should -Be 2
        }

        It 'total=3' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/critical-major-requirements.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total | Should -Be 3
        }

        It 'PRF headings match total' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/critical-major-requirements.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.prf_headings | Should -Be $json.total
        }

        It 'summary_match is true' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/critical-major-requirements.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.summary_match | Should -Be $true
        }
    }

    Context 'Minor-only findings (exit 2)' {
        It 'exits 2 for minor-only' {
            & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" "$FixturesDir/minor-only-system-design.md" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 2
        }

        It 'shows WARNING message' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" "$FixturesDir/minor-only-system-design.md" 2>&1
            ($output -join "`n") | Should -Match 'WARNING'
        }

        It 'JSON exit_code=2' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/minor-only-system-design.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.exit_code | Should -Be 2
        }

        It 'counts 0 Critical 0 Major' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/minor-only-system-design.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.critical | Should -Be 0
            $json.major | Should -Be 0
        }

        It 'counts 2 Minor' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/minor-only-system-design.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.minor | Should -Be 2
        }

        It 'extracts IEEE 1016 standard' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/minor-only-system-design.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.standard | Should -Match 'IEEE 1016'
        }
    }

    Context 'Mixed severity (all 4 levels, exit 1)' {
        It 'exits 1 for mixed severity' {
            & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" "$FixturesDir/mixed-severity-hazard-analysis.md" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'JSON total=7' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/mixed-severity-hazard-analysis.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total | Should -Be 7
        }

        It 'counts all severities correctly' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/mixed-severity-hazard-analysis.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.critical | Should -Be 1
            $json.major | Should -Be 2
            $json.minor | Should -Be 3
            $json.observation | Should -Be 1
        }

        It 'PRF severity tags match summary' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/mixed-severity-hazard-analysis.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.prf_critical | Should -Be 1
            $json.prf_major | Should -Be 2
            $json.prf_minor | Should -Be 3
            $json.prf_observation | Should -Be 1
        }

        It 'summary_match is true' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/mixed-severity-hazard-analysis.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.summary_match | Should -Be $true
        }

        It 'extracts ISO 14971 standard' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/mixed-severity-hazard-analysis.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.standard | Should -Match 'ISO 14971'
        }
    }

    Context 'Observations only (exit 0)' {
        It 'exits 0 for observations-only' {
            & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" "$FixturesDir/observations-only-module-design.md" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'shows PASS message' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" "$FixturesDir/observations-only-module-design.md" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'PASS'
        }

        It 'JSON exit_code=0' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/observations-only-module-design.md" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.exit_code | Should -Be 0
        }

        It 'counts 2 Observations' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/observations-only-module-design.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.observation | Should -Be 2
        }

        It 'total=2 but exit 0' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/observations-only-module-design.md" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.total | Should -Be 2
        }

        It 'extracts DO-178C standard' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/observations-only-module-design.md" 2>&1
            $json = $output | ConvertFrom-Json
            $json.standard | Should -Match 'DO-178C'
        }
    }

    Context 'Error handling' {
        It 'exits 1 for missing argument' {
            & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'exits 1 for nonexistent file' {
            & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" "/tmp/nonexistent-peer-review.md" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It '-Help exits 0' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Help 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'Usage'
        }
    }

    Context 'JSON output structure' {
        It 'produces valid JSON' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/mixed-severity-hazard-analysis.md" 2>&1
            $strings = $output | Where-Object { $_ -is [string] }
            { $strings | ConvertFrom-Json } | Should -Not -Throw
        }

        It 'has all required fields' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Peer-Review-Check.ps1" -Json "$FixturesDir/clean-requirements.md" 2>&1
            $strings = $output | Where-Object { $_ -is [string] }
            $json = $strings | ConvertFrom-Json
            $json.PSObject.Properties.Name | Should -Contain 'review_file'
            $json.PSObject.Properties.Name | Should -Contain 'artifact'
            $json.PSObject.Properties.Name | Should -Contain 'standard'
            $json.PSObject.Properties.Name | Should -Contain 'exit_code'
        }
    }
}
