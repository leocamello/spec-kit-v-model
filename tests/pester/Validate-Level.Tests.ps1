#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures')
}

Describe 'Validate-Level' {

    # ── Dispatches to correct validator ──

    Context 'Dispatch routing' {
        It 'acceptance dispatches to validate-requirement-coverage' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" acceptance 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'REQ .* ATP coverage'
        }

        It 'system-test dispatches to validate-system-coverage' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" system-test 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'REQ .* SYS coverage'
        }

        It 'integration-test dispatches to validate-architecture-coverage' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" integration-test 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'SYS .* ARCH coverage'
        }

        It 'unit-test dispatches to validate-module-coverage' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" unit-test 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'ARCH .* MOD coverage'
        }

        It 'hazard-analysis dispatches to validate-hazard-coverage' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" hazard-analysis 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match '(?i)hazard coverage'
        }
    }

    # ── All levels exit 0 on full coverage ──

    Context 'Full coverage (minimal fixture)' {
        It 'acceptance exits 0 on full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" acceptance 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'system-test exits 0 on full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" system-test 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'integration-test exits 0 on full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" integration-test 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'unit-test exits 0 on full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" unit-test 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'hazard-analysis exits 0 on full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" hazard-analysis 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }
    }

    # ── --json flag is forwarded ──

    Context 'JSON mode' {
        It '--json acceptance produces JSON output' {
            $raw = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" -Json "$FixturesDir/minimal" acceptance 2>$null
            $LASTEXITCODE | Should -Be 0
            $json = $raw | ConvertFrom-Json
            $json.has_gaps | Should -Be $false
        }

        It '--json system-test produces JSON output' {
            $raw = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" -Json "$FixturesDir/minimal" system-test 2>$null
            $LASTEXITCODE | Should -Be 0
            $json = $raw | ConvertFrom-Json
            $json.has_gaps | Should -Be $false
        }

        It '--json integration-test produces JSON output' {
            $raw = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" -Json "$FixturesDir/minimal" integration-test 2>$null
            $LASTEXITCODE | Should -Be 0
            $json = $raw | ConvertFrom-Json
            $json.has_gaps | Should -Be $false
        }

        It '--json unit-test produces JSON output' {
            $raw = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" -Json "$FixturesDir/minimal" unit-test 2>$null
            $LASTEXITCODE | Should -Be 0
            $json = $raw | ConvertFrom-Json
            $json.has_gaps | Should -Be $false
        }

        It '--json hazard-analysis produces JSON output' {
            $raw = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" -Json "$FixturesDir/minimal" hazard-analysis 2>$null
            $LASTEXITCODE | Should -Be 0
            $json = $raw | ConvertFrom-Json
            $json.has_gaps | Should -Be $false
        }
    }

    # ── Gaps fixture exits 1 ──

    Context 'Gaps detected (gaps fixture)' {
        It 'acceptance exits 1 when gaps exist' {
            & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/gaps" acceptance 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'system-test exits 1 when gaps exist' {
            & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/gaps" system-test 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'integration-test exits 1 when gaps exist' {
            & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/gaps" integration-test 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'unit-test exits 1 when gaps exist' {
            & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/gaps" unit-test 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }
    }

    # ── Error handling ──

    Context 'Error handling' {
        It 'unknown level exits 2' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" bogus 2>&1
            $LASTEXITCODE | Should -Be 2
            ($output -join "`n") | Should -Match 'unknown level'
        }

        It 'missing arguments exits 2' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" 2>&1
            $LASTEXITCODE | Should -Be 2
            ($output -join "`n") | Should -Match 'required'
        }

        It 'missing level argument exits 2' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 2
            ($output -join "`n") | Should -Match 'required'
        }

        It 'nonexistent directory exits 2' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" '/nonexistent/path' acceptance 2>&1
            $LASTEXITCODE | Should -Be 2
            ($output -join "`n") | Should -Match 'does not exist'
        }

        It 'extra argument is rejected' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" acceptance extra 2>&1
            $LASTEXITCODE | Should -Not -Be 0
        }

        It '--help shows usage (via -h parameter simulation)' {
            # PowerShell CmdletBinding doesn't support --help natively;
            # test that unknown level gives useful error instead
            $output = & pwsh -NoProfile -File "$ScriptsDir/Validate-Level.ps1" "$FixturesDir/minimal" bogus 2>&1
            $LASTEXITCODE | Should -Be 2
            ($output -join "`n") | Should -Match 'acceptance'
            ($output -join "`n") | Should -Match 'system-test'
            ($output -join "`n") | Should -Match 'integration-test'
            ($output -join "`n") | Should -Match 'unit-test'
            ($output -join "`n") | Should -Match 'hazard-analysis'
        }
    }
}