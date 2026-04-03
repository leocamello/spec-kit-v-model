#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures')
    $ImpactDir = Join-Path $FixturesDir 'impact'
    $GoldenDir = Join-Path $FixturesDir 'golden-impact'
}

Describe 'Impact-Analysis' {
    Context 'Minimal fixture — downward traversal' {
        It 'exits 0 for downward REQ-001' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Downward -Json -Ids REQ-001 -VModelDir "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
        }

        It 'JSON matches golden downward-REQ-001' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Downward -Json -Ids REQ-001 -VModelDir "$FixturesDir/minimal" 2>&1
            $actual = $output | ConvertFrom-Json
            $golden = Get-Content "$GoldenDir/minimal/downward-REQ-001.json" | ConvertFrom-Json
            $actual.blast_radius.total | Should -Be $golden.blast_radius.total
            $actual.direction | Should -Be $golden.direction
        }

        It 'has SYS-level suspects' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Downward -Json -Ids REQ-001 -VModelDir "$FixturesDir/minimal" 2>&1
            $json = $output | ConvertFrom-Json
            $json.suspect_artifacts.SYS.Count | Should -BeGreaterThan 0
        }
    }

    Context 'Minimal fixture — upward traversal' {
        It 'exits 0 for upward MOD-001' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Upward -Json -Ids MOD-001 -VModelDir "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
        }

        It 'JSON matches golden upward-MOD-001 total' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Upward -Json -Ids MOD-001 -VModelDir "$FixturesDir/minimal" 2>&1
            $actual = $output | ConvertFrom-Json
            $golden = Get-Content "$GoldenDir/minimal/upward-MOD-001.json" | ConvertFrom-Json
            $actual.blast_radius.total | Should -Be $golden.blast_radius.total
        }
    }

    Context 'Minimal fixture — full traversal' {
        It 'exits 0 for full SYS-001' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Full -Json -Ids SYS-001 -VModelDir "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
        }

        It 'has upstream and downstream keys' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Full -Json -Ids SYS-001 -VModelDir "$FixturesDir/minimal" 2>&1
            $json = $output | ConvertFrom-Json
            $json.direction | Should -Be 'full'
            $json.suspect_artifacts.PSObject.Properties.Name | Should -Contain 'downstream'
            $json.suspect_artifacts.PSObject.Properties.Name | Should -Contain 'upstream'
        }
    }

    Context 'Disconnected fixture — subgraph isolation' {
        It 'REQ-001 only finds subgraph A' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Downward -Json -Ids REQ-001 -VModelDir "$ImpactDir/disconnected" 2>&1
            $json = $output | ConvertFrom-Json
            $json.blast_radius.total | Should -Be 4
            $json.suspect_artifacts.SYS | Should -Contain 'SYS-001'
            $json.suspect_artifacts.SYS | Should -Not -Contain 'SYS-002'
        }

        It 'REQ-002 only finds subgraph B' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Downward -Json -Ids REQ-002 -VModelDir "$ImpactDir/disconnected" 2>&1
            $json = $output | ConvertFrom-Json
            $json.blast_radius.total | Should -Be 4
            $json.suspect_artifacts.SYS | Should -Contain 'SYS-002'
            $json.suspect_artifacts.SYS | Should -Not -Contain 'SYS-001'
        }
    }

    Context 'Diamond fixture' {
        It 'downward REQ-001 matches golden total' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Downward -Json -Ids REQ-001 -VModelDir "$ImpactDir/diamond" 2>&1
            $json = $output | ConvertFrom-Json
            $golden = Get-Content "$GoldenDir/diamond/downward-REQ-001.json" | ConvertFrom-Json
            $json.blast_radius.total | Should -Be $golden.blast_radius.total
        }
    }

    Context 'Error handling' {
        It 'exits 1 with no arguments' {
            & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'exits 1 for unknown ID' {
            & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Downward -Json -Ids FAKE-999 -VModelDir "$FixturesDir/minimal" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'exits 1 for nonexistent directory' {
            & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Downward -Json -Ids REQ-001 -VModelDir "/nonexistent/dir" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }
    }

    Context 'Multiple changed IDs' {
        It 'accepts multiple IDs' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" -Downward -Json -Ids REQ-001,REQ-002 -VModelDir "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.changed_ids.Count | Should -Be 2
        }
    }
}
