#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot '../..')
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures')
    $ImpactDir = Join-Path $FixturesDir 'commands/impact-analysis/inputs'
    $GoldenDir = Join-Path $FixturesDir 'commands/impact-analysis/expected'

    function Invoke-Impact {
        param([string[]]$Params)
        $result = & pwsh -NoProfile -File "$ScriptsDir/impact-analysis.ps1" @Params 2>&1
        return $result
    }

    function Assert-MatchesGolden {
        param([string]$ActualJson, [string]$GoldenPath)
        $actual = $ActualJson | ConvertFrom-Json
        $golden = Get-Content $GoldenPath -Raw | ConvertFrom-Json

        $actual.direction | Should -Be $golden.direction
        $actual.blast_radius.total | Should -Be $golden.blast_radius.total

        ($actual.changed_ids | Sort-Object) -join ',' |
            Should -Be (($golden.changed_ids | Sort-Object) -join ',')

        @($actual.revalidation_order).Count | Should -Be @($golden.revalidation_order).Count

        $goldenLevels = $golden.blast_radius.by_level.PSObject.Properties
        foreach ($prop in $goldenLevels) {
            $actual.blast_radius.by_level.($prop.Name) | Should -Be $prop.Value
        }
    }

    function Assert-StructurallyValid {
        param([string]$JsonText)
        $json = $JsonText | ConvertFrom-Json

        # Required top-level keys
        $json.PSObject.Properties.Name | Should -Contain 'changed_ids'
        $json.PSObject.Properties.Name | Should -Contain 'direction'
        $json.PSObject.Properties.Name | Should -Contain 'suspect_artifacts'
        $json.PSObject.Properties.Name | Should -Contain 'blast_radius'
        $json.PSObject.Properties.Name | Should -Contain 'revalidation_order'

        # Direction is valid
        $json.direction | Should -BeIn @('downward', 'upward', 'full')

        # blast_radius.total matches sum of by_level
        $sumByLevel = 0
        foreach ($prop in $json.blast_radius.by_level.PSObject.Properties) {
            $sumByLevel += $prop.Value
        }
        $json.blast_radius.total | Should -Be $sumByLevel

        # revalidation_order count matches total
        @($json.revalidation_order).Count | Should -Be $json.blast_radius.total

        # changed_ids not in suspects
        $allSuspects = @()
        if ($json.direction -eq 'full') {
            foreach ($prop in $json.suspect_artifacts.downstream.PSObject.Properties) {
                $allSuspects += @($prop.Value)
            }
            foreach ($prop in $json.suspect_artifacts.upstream.PSObject.Properties) {
                $allSuspects += @($prop.Value)
            }
        } else {
            foreach ($prop in $json.suspect_artifacts.PSObject.Properties) {
                $allSuspects += @($prop.Value)
            }
        }
        foreach ($cid in $json.changed_ids) {
            $allSuspects | Should -Not -Contain $cid
        }
    }
}

Describe 'Impact-Analysis' {

    # ============================================================
    # Minimal fixture: downward, upward, full
    # ============================================================

    Context 'Minimal fixture — downward traversal' {
        It 'exits 0 for downward REQ-001' {
            $output = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-001', '-VModelDir', "$FixturesDir/minimal")
            $LASTEXITCODE | Should -Be 0
        }

        It 'matches golden downward-REQ-001' {
            $output = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-001', '-VModelDir', "$FixturesDir/minimal")
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/minimal/downward-REQ-001.json"
        }

        It 'has SYS-level suspects' {
            $output = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-001', '-VModelDir', "$FixturesDir/minimal")
            $json = ($output -join '') | ConvertFrom-Json
            $json.suspect_artifacts.SYS.Count | Should -BeGreaterThan 0
        }
    }

    Context 'Minimal fixture — upward traversal' {
        It 'matches golden upward-MOD-001' {
            $output = Invoke-Impact -Params @('-Upward', '-Json', '-Ids', 'MOD-001', '-VModelDir', "$FixturesDir/minimal")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/minimal/upward-MOD-001.json"
        }
    }

    Context 'Minimal fixture — full traversal' {
        It 'matches golden full-SYS-001' {
            $output = Invoke-Impact -Params @('-Full', '-Json', '-Ids', 'SYS-001', '-VModelDir', "$FixturesDir/minimal")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/minimal/full-SYS-001.json"
        }

        It 'has upstream and downstream keys' {
            $output = Invoke-Impact -Params @('-Full', '-Json', '-Ids', 'SYS-001', '-VModelDir', "$FixturesDir/minimal")
            $json = ($output -join '') | ConvertFrom-Json
            $json.direction | Should -Be 'full'
            $json.suspect_artifacts.PSObject.Properties.Name | Should -Contain 'downstream'
            $json.suspect_artifacts.PSObject.Properties.Name | Should -Contain 'upstream'
        }
    }

    # ============================================================
    # Complex fixture
    # ============================================================

    Context 'Complex fixture' {
        It 'matches golden downward-REQ-001' {
            $output = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-001', '-VModelDir', "$FixturesDir/complex")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/complex/downward-REQ-001.json"
        }

        It 'matches golden upward-MOD-006' {
            $output = Invoke-Impact -Params @('-Upward', '-Json', '-Ids', 'MOD-006', '-VModelDir', "$FixturesDir/complex")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/complex/upward-MOD-006.json"
        }

        It 'matches golden full-SYS-003' {
            $output = Invoke-Impact -Params @('-Full', '-Json', '-Ids', 'SYS-003', '-VModelDir', "$FixturesDir/complex")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/complex/full-SYS-003.json"
        }
    }

    # ============================================================
    # Gaps fixture
    # ============================================================

    Context 'Gaps fixture' {
        It 'matches golden downward-REQ-001' {
            $output = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-001', '-VModelDir', "$FixturesDir/gaps")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/gaps/downward-REQ-001.json"
        }

        It 'matches golden upward-MOD-001' {
            $output = Invoke-Impact -Params @('-Upward', '-Json', '-Ids', 'MOD-001', '-VModelDir', "$FixturesDir/gaps")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/gaps/upward-MOD-001.json"
        }
    }

    # ============================================================
    # Linear fixture
    # ============================================================

    Context 'Linear fixture' {
        It 'matches golden downward-REQ-001' {
            $output = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-001', '-VModelDir', "$ImpactDir/linear")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/linear/downward-REQ-001.json"
        }

        It 'matches golden upward-MOD-001' {
            $output = Invoke-Impact -Params @('-Upward', '-Json', '-Ids', 'MOD-001', '-VModelDir', "$ImpactDir/linear")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/linear/upward-MOD-001.json"
        }

        It 'matches golden full-SYS-001' {
            $output = Invoke-Impact -Params @('-Full', '-Json', '-Ids', 'SYS-001', '-VModelDir', "$ImpactDir/linear")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/linear/full-SYS-001.json"
        }
    }

    # ============================================================
    # Diamond fixture
    # ============================================================

    Context 'Diamond fixture' {
        It 'matches golden downward-REQ-001' {
            $output = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-001', '-VModelDir', "$ImpactDir/diamond")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/diamond/downward-REQ-001.json"
        }

        It 'matches golden upward-MOD-002' {
            $output = Invoke-Impact -Params @('-Upward', '-Json', '-Ids', 'MOD-002', '-VModelDir', "$ImpactDir/diamond")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/diamond/upward-MOD-002.json"
        }

        It 'matches golden full-ARCH-004' {
            $output = Invoke-Impact -Params @('-Full', '-Json', '-Ids', 'ARCH-004', '-VModelDir', "$ImpactDir/diamond")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/diamond/full-ARCH-004.json"
        }
    }

    # ============================================================
    # Disconnected fixture
    # ============================================================

    Context 'Disconnected fixture — subgraph isolation' {
        It 'REQ-001 matches golden (subgraph A)' {
            $output = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-001', '-VModelDir', "$ImpactDir/disconnected")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/disconnected/downward-REQ-001.json"
        }

        It 'REQ-002 matches golden (subgraph B)' {
            $output = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-002', '-VModelDir', "$ImpactDir/disconnected")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/disconnected/downward-REQ-002.json"
        }

        It 'subgraphs have no overlap' {
            $out1 = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-001', '-VModelDir', "$ImpactDir/disconnected")
            $out2 = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-002', '-VModelDir', "$ImpactDir/disconnected")
            $json1 = ($out1 -join '') | ConvertFrom-Json
            $json2 = ($out2 -join '') | ConvertFrom-Json
            $ids1 = @()
            foreach ($prop in $json1.suspect_artifacts.PSObject.Properties) {
                $ids1 += @($prop.Value)
            }
            $ids2 = @()
            foreach ($prop in $json2.suspect_artifacts.PSObject.Properties) {
                $ids2 += @($prop.Value)
            }
            $overlap = $ids1 | Where-Object { $ids2 -contains $_ }
            @($overlap).Count | Should -Be 0
        }

        It 'matches golden upward-MOD-001' {
            $output = Invoke-Impact -Params @('-Upward', '-Json', '-Ids', 'MOD-001', '-VModelDir', "$ImpactDir/disconnected")
            $LASTEXITCODE | Should -Be 0
            Assert-MatchesGolden -ActualJson ($output -join '') -GoldenPath "$GoldenDir/disconnected/upward-MOD-001.json"
        }
    }

    # ============================================================
    # Markdown output
    # ============================================================

    Context 'Markdown output' {
        It 'has expected sections' {
            $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
            $reportPath = Join-Path $tempDir 'report.md'
            $output = Invoke-Impact -Params @('-Downward', '-Output', $reportPath, '-Ids', 'REQ-001', '-VModelDir', "$FixturesDir/minimal")
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'Impact report written to'
            $content = Get-Content $reportPath -Raw
            $content | Should -Match '# Impact Analysis Report'
            $content | Should -Match '## Changed IDs'
            $content | Should -Match '## Suspect Artifacts'
            $content | Should -Match '## Blast Radius'
            $content | Should -Match '## Re-validation Order'
            Remove-Item -Recurse -Force $tempDir
        }

        It 'default output writes to vmodel-dir/impact-report.md' {
            $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
            Copy-Item "$FixturesDir/minimal/*" "$tempDir/" -Recurse
            Invoke-Impact -Params @('-Downward', '-Ids', 'REQ-001', '-VModelDir', $tempDir) | Out-Null
            $LASTEXITCODE | Should -Be 0
            Test-Path (Join-Path $tempDir 'impact-report.md') | Should -Be $true
            Remove-Item -Recurse -Force $tempDir
        }
    }

    # ============================================================
    # Multi-ID input
    # ============================================================

    Context 'Multiple changed IDs' {
        It 'accepts multiple IDs' {
            $output = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-001,REQ-002', '-VModelDir', "$FixturesDir/minimal")
            $LASTEXITCODE | Should -Be 0
            $json = ($output -join '') | ConvertFrom-Json
            $json.changed_ids.Count | Should -Be 2
            $json.changed_ids | Should -Contain 'REQ-001'
            $json.changed_ids | Should -Contain 'REQ-002'
        }
    }

    # ============================================================
    # Error handling
    # ============================================================

    Context 'Error handling' {
        It 'exits 1 with no arguments' {
            & pwsh -NoProfile -NonInteractive -File "$ScriptsDir/impact-analysis.ps1" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'exits 1 for unknown ID' {
            & pwsh -NoProfile -NonInteractive -File "$ScriptsDir/impact-analysis.ps1" -Downward -Json -Ids FAKE-999 -VModelDir "$FixturesDir/minimal" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'exits 1 for nonexistent directory' {
            & pwsh -NoProfile -NonInteractive -File "$ScriptsDir/impact-analysis.ps1" -Downward -Json -Ids REQ-001 -VModelDir "/nonexistent/dir" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'exits 1 for empty fixture (no matching IDs)' {
            & pwsh -NoProfile -NonInteractive -File "$ScriptsDir/impact-analysis.ps1" -Downward -Json -Ids REQ-001 -VModelDir "$FixturesDir/empty" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }
    }

    # ============================================================
    # Structural validation
    # ============================================================

    Context 'Structural validation' {
        It 'downward JSON passes structural validation' {
            $output = Invoke-Impact -Params @('-Downward', '-Json', '-Ids', 'REQ-001', '-VModelDir', "$FixturesDir/minimal")
            Assert-StructurallyValid -JsonText ($output -join '')
        }

        It 'upward JSON passes structural validation' {
            $output = Invoke-Impact -Params @('-Upward', '-Json', '-Ids', 'MOD-001', '-VModelDir', "$FixturesDir/minimal")
            Assert-StructurallyValid -JsonText ($output -join '')
        }

        It 'full JSON passes structural validation' {
            $output = Invoke-Impact -Params @('-Full', '-Json', '-Ids', 'SYS-001', '-VModelDir', "$FixturesDir/minimal")
            Assert-StructurallyValid -JsonText ($output -join '')
        }
    }

    # ============================================================
    # Performance
    # ============================================================

    Context 'Performance' {
        It 'completes within 10 seconds on dogfooding data' {
            $dogfoodDir = Join-Path $ProjectRoot 'specs/005a-hazard-analysis/v-model'
            if (-not (Test-Path $dogfoodDir)) {
                Set-ItResult -Skipped -Because '005a dogfooding data not available'
                return
            }
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            Invoke-Impact -Params @('-Full', '-Json', '-Ids', 'REQ-001', '-VModelDir', $dogfoodDir) | Out-Null
            $sw.Stop()
            $sw.Elapsed.TotalSeconds | Should -BeLessOrEqual 10
        }
    }
}
