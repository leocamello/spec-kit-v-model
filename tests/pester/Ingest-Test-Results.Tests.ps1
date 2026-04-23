#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $PythonHelper = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/python/parse_test_results.py')
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures/commands/test-results')
    $IngestScript = Join-Path $ScriptsDir 'Ingest-Test-Results.ps1'
}

Describe 'Ingest-Test-Results' {

    BeforeEach {
        $TempDir = Join-Path ([System.IO.Path]::GetTempPath()) "speckit-test-$([guid]::NewGuid().ToString('N').Substring(0,8))"
        New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
        Copy-Item "$FixturesDir/inputs/matrix/traceability-matrix.md" "$TempDir/matrix.md"
    }

    AfterEach {
        if (Test-Path $TempDir) { Remove-Item -Recurse -Force $TempDir }
    }

    # ============================================================
    # Python helper — golden JSON output validation
    # ============================================================

    Context 'Python helper — golden JSON' {
        It 'all-pass matches golden JSON' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" 2>$null
            $LASTEXITCODE | Should -Be 0
            $expected = (Get-Content "$FixturesDir/expected/all-pass.json" -Raw) -replace "`r`n", "`n"
            ($output -join "`n") | Should -Be $expected.TrimEnd()
        }

        It 'mixed-results matches golden JSON' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/mixed-results.xml" 2>$null
            $LASTEXITCODE | Should -Be 1
            $expected = (Get-Content "$FixturesDir/expected/mixed-results.json" -Raw) -replace "`r`n", "`n"
            ($output -join "`n") | Should -Be $expected.TrimEnd()
        }

        It 'all-fail matches golden JSON' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-fail.xml" 2>$null
            $LASTEXITCODE | Should -Be 1
            $expected = (Get-Content "$FixturesDir/expected/all-fail.json" -Raw) -replace "`r`n", "`n"
            ($output -join "`n") | Should -Be $expected.TrimEnd()
        }

        It 'all-skipped matches golden JSON' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-skipped.xml" 2>$null
            $LASTEXITCODE | Should -Be 0
            $expected = (Get-Content "$FixturesDir/expected/all-skipped.json" -Raw) -replace "`r`n", "`n"
            ($output -join "`n") | Should -Be $expected.TrimEnd()
        }

        It 'no-matches exits 2' {
            & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/no-matches.xml" 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 2
        }

        It 'no-matches matches golden JSON' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/no-matches.xml" 2>$null
            $expected = (Get-Content "$FixturesDir/expected/no-matches.json" -Raw) -replace "`r`n", "`n"
            ($output -join "`n") | Should -Be $expected.TrimEnd()
        }

        It 'with-retries matches golden JSON' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/with-retries.xml" 2>$null
            $LASTEXITCODE | Should -Be 0
            $expected = (Get-Content "$FixturesDir/expected/with-retries.json" -Raw) -replace "`r`n", "`n"
            ($output -join "`n") | Should -Be $expected.TrimEnd()
        }

        It 'multi-suite matches golden JSON' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/multi-suite.xml" 2>$null
            $LASTEXITCODE | Should -Be 0
            $expected = (Get-Content "$FixturesDir/expected/multi-suite.json" -Raw) -replace "`r`n", "`n"
            ($output -join "`n") | Should -Be $expected.TrimEnd()
        }

        It 'extra-ids matches golden JSON' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/extra-ids.xml" 2>$null
            $LASTEXITCODE | Should -Be 0
            $expected = (Get-Content "$FixturesDir/expected/extra-ids.json" -Raw) -replace "`r`n", "`n"
            ($output -join "`n") | Should -Be $expected.TrimEnd()
        }

        It 'full-coverage matches golden JSON' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" `
                --cobertura "$FixturesDir/inputs/cobertura/full-coverage.xml" `
                --coverage-map "$FixturesDir/inputs/matrix/coverage-map.yml" `
                --coverage-threshold 100 2>$null
            $LASTEXITCODE | Should -Be 0
            $expected = (Get-Content "$FixturesDir/expected/with-full-coverage.json" -Raw) -replace "`r`n", "`n"
            ($output -join "`n") | Should -Be $expected.TrimEnd()
        }

        It 'partial-coverage matches golden JSON' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" `
                --cobertura "$FixturesDir/inputs/cobertura/partial-coverage.xml" `
                --coverage-map "$FixturesDir/inputs/matrix/coverage-map.yml" `
                --coverage-threshold 100 2>$null
            $LASTEXITCODE | Should -Be 0
            $expected = (Get-Content "$FixturesDir/expected/with-partial-coverage.json" -Raw) -replace "`r`n", "`n"
            ($output -join "`n") | Should -Be $expected.TrimEnd()
        }
    }

    # ============================================================
    # Python helper — exit codes
    # ============================================================

    Context 'Python helper — exit codes' {
        It 'exit 0 when all tests pass' {
            & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'exit 1 when failures detected' {
            & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-fail.xml" 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'exit 2 when no ID matches' {
            & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/no-matches.xml" 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 2
        }

        It 'exit 0 for all-skipped (no failures)' {
            & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-skipped.xml" 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 0
        }
    }

    # ============================================================
    # Python helper — ID matching
    # ============================================================

    Context 'Python helper — ID matching' {
        It 'matches SCN IDs to matrix A' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.test_results[0].matrix | Should -Be 'A'
        }

        It 'matches STS IDs to matrix B' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.test_results[2].matrix | Should -Be 'B'
        }

        It 'matches UTS IDs to matrix D' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.test_results[3].matrix | Should -Be 'D'
        }

        It 'matches ITS IDs to matrix C' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/multi-suite.xml" 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $itsResult = @($json.test_results | Where-Object { $_.id -match '^ITS' })[0]
            $itsResult.matrix | Should -Be 'C'
        }

        It 'unmatched tests reported' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/mixed-results.xml" 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.summary.unmatched_count | Should -Be 0
        }

        It 'no-matches has all tests unmatched' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/no-matches.xml" 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.summary.unmatched_count | Should -Be 3
        }
    }

    # ============================================================
    # Python helper — duplicate/retry handling
    # ============================================================

    Context 'Python helper — duplicate/retry handling' {
        It 'retries use last occurrence (pass after fail)' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/with-retries.xml" 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.test_results[0].status | Should -Be 'passed'
        }

        It 'retries deduplicate IDs' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/with-retries.xml" 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.summary.total | Should -Be 2
        }
    }

    # ============================================================
    # Python helper — summary counts
    # ============================================================

    Context 'Python helper — summary counts' {
        It 'all-pass summary total=4' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.summary.total | Should -Be 4
        }

        It 'mixed summary passed=3 failed=1 skipped=1' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/mixed-results.xml" 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.summary.passed | Should -Be 3
            $json.summary.failed | Should -Be 1
            $json.summary.skipped | Should -Be 1
        }

        It 'per-matrix counts correct for multi-suite' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/multi-suite.xml" 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.summary.per_matrix.A.total | Should -Be 2
            $json.summary.per_matrix.B.total | Should -Be 1
            $json.summary.per_matrix.C.total | Should -Be 1
            $json.summary.per_matrix.D.total | Should -Be 2
        }
    }

    # ============================================================
    # Python helper — coverage mapping
    # ============================================================

    Context 'Python helper — coverage mapping' {
        It 'full-coverage below_threshold=false' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" `
                --cobertura "$FixturesDir/inputs/cobertura/full-coverage.xml" `
                --coverage-map "$FixturesDir/inputs/matrix/coverage-map.yml" `
                --coverage-threshold 100 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.coverage.'MOD-001'.below_threshold | Should -Be $false
        }

        It 'partial-coverage below_threshold=true' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" `
                --cobertura "$FixturesDir/inputs/cobertura/partial-coverage.xml" `
                --coverage-map "$FixturesDir/inputs/matrix/coverage-map.yml" `
                --coverage-threshold 100 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.coverage.'MOD-001'.below_threshold | Should -Be $true
        }

        It 'partial-coverage MOD-001 stmt=95.0' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" `
                --cobertura "$FixturesDir/inputs/cobertura/partial-coverage.xml" `
                --coverage-map "$FixturesDir/inputs/matrix/coverage-map.yml" `
                --coverage-threshold 100 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.coverage.'MOD-001'.stmt | Should -Be 95.0
        }

        It 'coverage formatted string correct' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" `
                --cobertura "$FixturesDir/inputs/cobertura/partial-coverage.xml" `
                --coverage-map "$FixturesDir/inputs/matrix/coverage-map.yml" `
                --coverage-threshold 100 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.coverage.'MOD-001'.formatted | Should -Be '95.0% stmt / 88.0% branch'
        }

        It 'convention-based mapping from module-design.md' {
            $output = & python3 $PythonHelper --junit "$FixturesDir/inputs/junit/all-pass.xml" `
                --cobertura "$FixturesDir/inputs/cobertura/full-coverage.xml" `
                --module-design "$FixturesDir/inputs/matrix/module-design.md" `
                --coverage-threshold 100 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.coverage.PSObject.Properties.Name | Should -Contain 'MOD-001'
        }
    }

    # ============================================================
    # PowerShell wrapper — help flag
    # ============================================================

    Context 'PowerShell wrapper — help flag' {
        It '-Help exits 0' {
            & pwsh -NoProfile -File $IngestScript -Help 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It '-Help shows usage' {
            $output = & pwsh -NoProfile -File $IngestScript -Help 2>&1
            ($output -join "`n") | Should -Match 'Usage:'
            ($output -join "`n") | Should -Match '-InputFile'
        }
    }

    # ============================================================
    # PowerShell wrapper — argument validation
    # ============================================================

    Context 'PowerShell wrapper — argument validation' {
        It 'missing -InputFile exits 1' {
            & pwsh -NoProfile -File $IngestScript 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'nonexistent JUnit file exits 1' {
            & pwsh -NoProfile -File $IngestScript -InputFile '/nonexistent/file.xml' -Matrix "$TempDir/matrix.md" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'nonexistent matrix file exits 1' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" -Matrix '/nonexistent/matrix.md' 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'nonexistent coverage file exits 1' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" -Coverage '/nonexistent/cov.xml' -Matrix "$TempDir/matrix.md" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }
    }

    # ============================================================
    # PowerShell wrapper — exit codes
    # ============================================================

    Context 'PowerShell wrapper — exit codes' {
        It 'exit 0 when all pass' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'exit 1 when failures detected' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-fail.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'exit 2 when no matches' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/no-matches.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 2
        }
    }

    # ============================================================
    # PowerShell wrapper — matrix update
    # ============================================================

    Context 'PowerShell wrapper — matrix update' {
        It 'updates SCN-001-A1 to Passed' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1 | Out-Null
            $content = Get-Content "$TempDir/matrix.md" -Raw
            $content | Should -Match 'SCN-001-A1.*✅ Passed'
        }

        It 'updates SCN-001-A2 to Failed' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/mixed-results.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1 | Out-Null
            $content = Get-Content "$TempDir/matrix.md" -Raw
            $content | Should -Match 'SCN-001-A2.*❌ Failed'
        }

        It 'updates UTS-001-A1 to Skipped' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/mixed-results.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1 | Out-Null
            $content = Get-Content "$TempDir/matrix.md" -Raw
            $content | Should -Match 'UTS-001-A1.*⏭️ Skipped'
        }

        It 'preserves unmatched rows as Untested' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1 | Out-Null
            $content = Get-Content "$TempDir/matrix.md" -Raw
            $content | Should -Match 'SCN-002-A1.*⬜ Untested'
        }

        It 'adds Date column' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1 | Out-Null
            $line = Get-Content "$TempDir/matrix.md" | Where-Object { $_ -match 'SCN-001-A1' }
            $line | Should -Match '\d{4}-\d{2}-\d{2}'
        }

        It 'adds Commit column with specified SHA' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1 | Out-Null
            $line = Get-Content "$TempDir/matrix.md" | Where-Object { $_ -match 'SCN-001-A1' }
            $line | Should -Match 'abc1234'
        }

        It 'adds Date header to table' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1 | Out-Null
            $content = Get-Content "$TempDir/matrix.md" -Raw
            $content | Should -Match '\| Date \|'
        }

        It 'adds Commit header to table' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1 | Out-Null
            $content = Get-Content "$TempDir/matrix.md" -Raw
            $content | Should -Match '\| Commit \|'
        }

        It 'preserves non-table content' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1 | Out-Null
            $content = Get-Content "$TempDir/matrix.md" -Raw
            $content | Should -Match 'Coverage Summary'
        }
    }

    # ============================================================
    # PowerShell wrapper — re-run overwrites previous status
    # ============================================================

    Context 'PowerShell wrapper — re-run overwrites' {
        It 're-run overwrites Failed with Passed' {
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-fail.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'run1111' 2>&1 | Out-Null
            $line = Get-Content "$TempDir/matrix.md" | Where-Object { $_ -match 'SCN-001-A1' }
            $line | Should -Match '❌ Failed'

            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'run2222' 2>&1 | Out-Null
            $line = Get-Content "$TempDir/matrix.md" | Where-Object { $_ -match 'SCN-001-A1' }
            $line | Should -Match '✅ Passed'
            $line | Should -Match 'run2222'
        }
    }

    # ============================================================
    # PowerShell wrapper — summary output
    # ============================================================

    Context 'PowerShell wrapper — summary output' {
        It 'summary shows matrix counts' {
            $output = & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1
            $text = $output -join "`n"
            $text | Should -Match 'Test Results Ingestion'
            $text | Should -Match 'matched'
            $text | Should -Match 'passed'
        }

        It 'summary shows Matrix A' {
            $output = & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1
            ($output -join "`n") | Should -Match 'Matrix A'
        }

        It 'summary shows Matrix updated' {
            $output = & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/extra-ids.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' 2>&1
            ($output -join "`n") | Should -Match 'Matrix updated'
        }
    }

    # ============================================================
    # PowerShell wrapper — JSON output
    # ============================================================

    Context 'PowerShell wrapper — JSON output' {
        It '-Json outputs valid JSON' {
            $output = & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' -Json 2>&1
            $LASTEXITCODE | Should -Be 0
            { ($output -join "`n") | ConvertFrom-Json } | Should -Not -Throw
        }

        It '-Json includes matrix_path' {
            $output = & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' -Json 2>&1
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.matrix_path | Should -Match 'matrix\.md'
        }

        It '-Json includes date' {
            $output = & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' -Json 2>&1
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.date | Should -Match '^\d{4}-\d{2}-\d{2}$'
        }

        It '-Json includes commit' {
            $output = & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' -Json 2>&1
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.commit | Should -Be 'abc1234'
        }
    }

    # ============================================================
    # PowerShell wrapper — coverage column
    # ============================================================

    Context 'PowerShell wrapper — coverage column' {
        It 'coverage adds Coverage header to Matrix D' {
            Copy-Item "$FixturesDir/inputs/matrix/module-design.md" "$TempDir/module-design.md"
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Coverage "$FixturesDir/inputs/cobertura/full-coverage.xml" `
                -CoverageMap "$FixturesDir/inputs/matrix/coverage-map.yml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' `
                -VModelDir $TempDir 2>&1 | Out-Null
            $header = Get-Content "$TempDir/matrix.md" | Select-String '## Matrix D' -Context 0,2
            "$header" | Should -Match '\| Coverage \|'
        }

        It 'coverage shows percentage in Matrix D rows' {
            Copy-Item "$FixturesDir/inputs/matrix/module-design.md" "$TempDir/module-design.md"
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Coverage "$FixturesDir/inputs/cobertura/partial-coverage.xml" `
                -CoverageMap "$FixturesDir/inputs/matrix/coverage-map.yml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' `
                -VModelDir $TempDir 2>&1 | Out-Null
            $line = Get-Content "$TempDir/matrix.md" | Where-Object { $_ -match 'UTS-001-A1' }
            $line | Should -Match '95\.0% stmt'
        }

        It 'coverage below threshold shows warning' {
            Copy-Item "$FixturesDir/inputs/matrix/module-design.md" "$TempDir/module-design.md"
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Coverage "$FixturesDir/inputs/cobertura/partial-coverage.xml" `
                -CoverageMap "$FixturesDir/inputs/matrix/coverage-map.yml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' `
                -VModelDir $TempDir 2>&1 | Out-Null
            $line = Get-Content "$TempDir/matrix.md" | Where-Object { $_ -match 'UTS-001-A1' }
            $line | Should -Match '⚠'
        }

        It 'no Coverage header on Matrix A' {
            Copy-Item "$FixturesDir/inputs/matrix/module-design.md" "$TempDir/module-design.md"
            & pwsh -NoProfile -File $IngestScript -InputFile "$FixturesDir/inputs/junit/all-pass.xml" `
                -Coverage "$FixturesDir/inputs/cobertura/full-coverage.xml" `
                -CoverageMap "$FixturesDir/inputs/matrix/coverage-map.yml" `
                -Matrix "$TempDir/matrix.md" -CommitSha 'abc1234' `
                -VModelDir $TempDir 2>&1 | Out-Null
            $header = Get-Content "$TempDir/matrix.md" | Select-String '## Matrix A' -Context 0,2
            "$header" | Should -Not -Match 'Coverage'
        }
    }
}
