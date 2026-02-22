#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures')
}

Describe 'Validate-Requirement-Coverage' {
    Context 'Full coverage (minimal fixture)' {
        It 'exits 0 for full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-requirement-coverage.ps1" "$FixturesDir/minimal" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'JSON shows has_gaps false' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-requirement-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.has_gaps | Should -Be $false
        }

        It '--json outputs valid JSON' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-requirement-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            { $output | ConvertFrom-Json } | Should -Not -Throw
        }
    }

    Context 'Gaps fixture' {
        It 'exits 1 when ATP is missing' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-requirement-coverage.ps1" "$FixturesDir/gaps" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Not -Be 0
        }

        It 'identifies REQ-NF-001 as missing ATP' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-requirement-coverage.ps1" -Json "$FixturesDir/gaps" 2>&1
            $json = $output | ConvertFrom-Json
            $json.reqs_without_atp | Should -Contain 'REQ-NF-001'
        }
    }

    Context 'Complex fixture' {
        It 'category-prefixed IDs matched correctly' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-requirement-coverage.ps1" -Json "$FixturesDir/complex" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total_reqs | Should -Be 10
        }

        It 'orphaned ATPs detected' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-requirement-coverage.ps1" -Json "$FixturesDir/complex" 2>&1
            $json = $output | ConvertFrom-Json
            $json.orphaned_atps | Should -Contain 'ATP-999-A'
        }
    }

    Context 'Empty fixture' {
        It 'handles empty files gracefully' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-requirement-coverage.ps1" -Json "$FixturesDir/empty" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.total_reqs | Should -Be 0
        }
    }
}
