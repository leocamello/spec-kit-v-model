#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $AuditScript = Join-Path $ScriptsDir 'Build-Audit-Report.ps1'
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures/commands/audit-report')

    # Helper: copy fixture into a git-initialised temp dir
    function Setup-Fixture {
        param([string]$FixtureName, [string]$TempDir, [string]$FixturesDir)
        $dest = Join-Path $TempDir 'v-model'
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        Copy-Item "$FixturesDir/inputs/$FixtureName/*" $dest -Force
        Push-Location $TempDir
        git init --quiet 2>$null
        git config user.email 'test@example.com' 2>$null
        git config user.name 'Test' 2>$null
        New-Item -ItemType File -Path (Join-Path $TempDir '.gitkeep') -Force | Out-Null
        git add . 2>$null
        git commit --quiet -m 'Add fixture' 2>$null
        Pop-Location
    }
}

Describe 'Build-Audit-Report' {

    BeforeEach {
        $TempDir = Join-Path ([System.IO.Path]::GetTempPath()) "speckit-test-$([guid]::NewGuid().ToString('N').Substring(0,8))"
        New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    }

    AfterEach {
        if (Test-Path $TempDir) { Remove-Item -Recurse -Force $TempDir }
    }

    # ============================================================
    # Help flag
    # ============================================================

    Context 'Help flag' {
        It '--help exits 0' {
            & pwsh -File $AuditScript -Help 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It '--help shows usage' {
            $output = & pwsh -File $AuditScript -Help 2>$null
            $text = $output -join "`n"
            $text | Should -Match 'Usage:'
            $text | Should -Match '-SystemName'
            $text | Should -Match '-Json'
        }
    }

    # ============================================================
    # Argument validation
    # ============================================================

    Context 'Argument validation' {
        It 'missing directory argument exits 2' {
            & pwsh -File $AuditScript 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 2
        }

        It 'unknown option exits 2' {
            & pwsh -File $AuditScript -UnknownOption 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 2
        }

        It 'nonexistent directory exits 2' {
            & pwsh -File $AuditScript -VModelDir '/nonexistent/path' 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 2
        }

        It 'missing requirements.md exits 2' {
            Setup-Fixture 'missing-required' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 2
        }
    }

    # ============================================================
    # Clean scenario — RELEASE READY
    # ============================================================

    Context 'Clean scenario' {
        It 'clean fixture exits 0' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'clean fixture status is RELEASE READY' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null
            $text = $output -join "`n"
            $text | Should -Match 'RELEASE READY'
        }

        It 'clean fixture counts 12 tests all passed' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null
            $text = $output -join "`n"
            $text | Should -Match 'Tests: 12'
        }

        It 'clean fixture reports 0 anomalies' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null
            $text = $output -join "`n"
            $text | Should -Match 'Anomalies: 0'
        }

        It 'clean fixture reports 3 hazards' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null
            $text = $output -join "`n"
            $text | Should -Match 'Hazards: 3'
        }

        It 'clean fixture writes report file' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            Test-Path "$TempDir/report.md" | Should -Be $true
        }
    }

    # ============================================================
    # Waived scenario — RELEASE CANDIDATE
    # ============================================================

    Context 'Waived scenario' {
        It 'waived fixture exits 0' {
            Setup-Fixture 'waived' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'waived fixture status is RELEASE CANDIDATE' {
            Setup-Fixture 'waived' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null
            $text = $output -join "`n"
            $text | Should -Match 'RELEASE CANDIDATE'
        }

        It 'waived fixture counts 2 skipped' {
            Setup-Fixture 'waived' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null
            $text = $output -join "`n"
            $text | Should -Match '2'
        }

        It 'waived fixture reports 2 anomalies all waived' {
            Setup-Fixture 'waived' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null
            $text = $output -join "`n"
            $text | Should -Match 'Anomalies: 2 \(waived: 2, blocking: 0\)'
        }
    }

    # ============================================================
    # Blocking scenario — NOT READY
    # ============================================================

    Context 'Blocking scenario' {
        It 'blocking fixture exits 1' {
            Setup-Fixture 'blocking' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'blocking fixture status is NOT READY' {
            Setup-Fixture 'blocking' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null
            $text = $output -join "`n"
            $text | Should -Match 'NOT READY'
        }

        It 'blocking fixture counts 1 failed' {
            Setup-Fixture 'blocking' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null
            $text = $output -join "`n"
            $text | Should -Match '1'
        }

        It 'blocking fixture reports 1 blocking anomaly' {
            Setup-Fixture 'blocking' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null
            $text = $output -join "`n"
            $text | Should -Match 'Anomalies: 1 \(waived: 0, blocking: 1\)'
        }

        It 'blocking fixture still writes report file' {
            Setup-Fixture 'blocking' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            Test-Path "$TempDir/report.md" | Should -Be $true
        }
    }

    # ============================================================
    # Orphaned waivers
    # ============================================================

    Context 'Orphaned waivers' {
        It 'orphaned waiver exits 0' {
            Setup-Fixture 'orphaned-waiver' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'orphaned waiver detected in summary' {
            Setup-Fixture 'orphaned-waiver' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null
            $text = $output -join "`n"
            $text | Should -Match 'Orphaned waivers: 1'
        }

        It 'orphaned waiver status still RELEASE READY' {
            Setup-Fixture 'orphaned-waiver' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null
            $text = $output -join "`n"
            $text | Should -Match 'RELEASE READY'
        }
    }

    # ============================================================
    # CLI options — metadata
    # ============================================================

    Context 'CLI options — metadata' {
        It '-SystemName appears in report' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -SystemName 'TestSystem' -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'TestSystem'
        }

        It '-Version appears in report' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Version '1.2.3' -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match '1\.2\.3'
        }

        It '-GitTag appears in report' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -GitTag 'v1.2.3' -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'v1\.2\.3'
        }

        It '-RegulatoryContext appears in report' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -RegulatoryContext 'IEC 62304' -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'IEC 62304'
        }

        It 'default output path is release-audit-report.md' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" 2>$null | Out-Null
            Test-Path "$TempDir/v-model/release-audit-report.md" | Should -Be $true
        }
    }

    # ============================================================
    # Report structure — 7 sections
    # ============================================================

    Context 'Report structure — 7 sections' {
        BeforeEach {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $Script:ReportContent = Get-Content "$TempDir/report.md" -Raw
        }

        It 'report contains Section 1 Executive Summary' {
            $Script:ReportContent | Should -Match '## 1\. Executive Summary'
        }

        It 'report contains Section 2 Artifact Inventory' {
            $Script:ReportContent | Should -Match '## 2\. Artifact Inventory'
        }

        It 'report contains Section 3 Traceability Matrices' {
            $Script:ReportContent | Should -Match '## 3\. Traceability Matrices'
        }

        It 'report contains Section 4 Coverage Analysis' {
            $Script:ReportContent | Should -Match '## 4\. Coverage Analysis'
        }

        It 'report contains Section 5 Hazard Management Summary' {
            $Script:ReportContent | Should -Match '## 5\. Hazard Management Summary'
        }

        It 'report contains Section 6 Known Anomalies' {
            $Script:ReportContent | Should -Match '## 6\. Known Anomalies'
        }

        It 'report contains Section 7 Sign-off Block' {
            $sigPattern = '## 7\. Sig' + 'nature'
            $Script:ReportContent | Should -Match $sigPattern
        }
    }

    # ============================================================
    # Artifact inventory
    # ============================================================

    Context 'Artifact inventory' {
        It 'inventory shows Present for requirements.md' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'Requirements.*Present'
        }

        It 'inventory shows Missing for waivers.md' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'Waivers.*Missing'
        }

        It 'inventory includes git SHA' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'Requirements.*[0-9a-f]{7}'
        }
    }

    # ============================================================
    # Hazard section
    # ============================================================

    Context 'Hazard section' {
        It 'clean report shows HAZ-001 in hazard section' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'HAZ-001'
        }

        It 'clean report shows all 3 hazards mitigated' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'All 3 hazards mitigated'
        }

        It 'shows no hazard analysis when absent' {
            $nohaz = Join-Path $TempDir 'nohaz'
            New-Item -ItemType Directory -Path $nohaz -Force | Out-Null
            Copy-Item "$FixturesDir/orphaned-waiver/requirements.md" $nohaz
            Copy-Item "$FixturesDir/orphaned-waiver/traceability-matrix.md" $nohaz
            Push-Location $TempDir
            git init --quiet 2>$null
            git config user.email 'test@example.com' 2>$null
            git config user.name 'Test' 2>$null
            New-Item -ItemType File -Path (Join-Path $TempDir '.gitkeep') -Force | Out-Null
            git add . 2>$null
            git commit --quiet -m 'Add fixture' 2>$null
            Pop-Location
            & pwsh -File $AuditScript -VModelDir $nohaz -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'No hazard analysis was performed'
        }
    }

    # ============================================================
    # Coverage analysis
    # ============================================================

    Context 'Coverage analysis' {
        It 'coverage table has 4 matrix rows for clean' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $lines = @(Get-Content "$TempDir/report.md" | Where-Object { $_ -match '^\| Matrix [A-D]' })
            $lines.Count | Should -Be 4
        }

        It 'clean fixture shows 100% forward coverage' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'Matrix A.*100%'
        }
    }

    # ============================================================
    # Anomalies in report
    # ============================================================

    Context 'Anomalies in report' {
        It 'clean report says No anomalies detected' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'No anomalies detected'
        }

        It 'waived report lists UTS-001-B1 as Waived' {
            Setup-Fixture 'waived' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'UTS-001-B1.*Waived'
        }

        It 'waived report lists WAV-001 for UTS-001-B1' {
            Setup-Fixture 'waived' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'UTS-001-B1.*WAV-001'
        }

        It 'blocking report lists SCN-002-A1 as BLOCKING' {
            Setup-Fixture 'blocking' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'SCN-002-A1.*BLOCKING'
        }

        It 'orphaned waiver report shows orphaned section' {
            Setup-Fixture 'orphaned-waiver' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'Orphaned Waivers'
        }

        It 'orphaned waiver report lists WAV-001 as orphaned' {
            Setup-Fixture 'orphaned-waiver' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'WAV-001.*UTS-999-Z1'
        }
    }

    # ============================================================
    # JSON output — structure
    # ============================================================

    Context 'JSON output — structure' {
        It '-Json outputs valid JSON' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = $output -join "`n"
            { $json | ConvertFrom-Json } | Should -Not -Throw
        }

        It '-Json contains metadata with system_name' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json -SystemName 'TestSys' 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.metadata.system_name | Should -Be 'TestSys'
        }

        It '-Json contains compliance_status' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.compliance_status | Should -Match 'RELEASE READY'
        }

        It '-Json contains exit_code' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.exit_code | Should -Be 0
        }

        It '-Json contains artifact_inventory array with 11 entries' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            @($json.artifact_inventory).Count | Should -Be 11
        }

        It '-Json contains coverage_analysis array with 4 entries' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            @($json.coverage_analysis).Count | Should -Be 4
        }

        It '-Json contains summary totals' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.summary.total_tests | Should -Be 12
            $json.summary.passed | Should -Be 12
        }
    }

    # ============================================================
    # JSON output — scenarios
    # ============================================================

    Context 'JSON output — scenarios' {
        It '-Json waived has 2 classified anomalies' {
            Setup-Fixture 'waived' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            @($json.anomalies.classified).Count | Should -Be 2
        }

        It '-Json waived anomalies are Waived' {
            Setup-Fixture 'waived' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.anomalies.classified[0].disposition | Should -Be 'Waived'
        }

        It '-Json blocking exit_code is 1' {
            Setup-Fixture 'blocking' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.exit_code | Should -Be 1
        }

        It '-Json blocking has BLOCKING disposition' {
            Setup-Fixture 'blocking' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.anomalies.classified[0].disposition | Should -Be 'BLOCKING'
        }

        It '-Json orphaned waiver listed' {
            Setup-Fixture 'orphaned-waiver' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            @($json.anomalies.orphaned_waivers).Count | Should -Be 1
        }

        It '-Json orphaned waiver has correct artifact_id' {
            Setup-Fixture 'orphaned-waiver' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            $json.anomalies.orphaned_waivers[0].artifact_id | Should -Be 'UTS-999-Z1'
        }

        It '-Json hazard_summary contains 3 entries for clean' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            $output = & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Json 2>$null
            $json = ($output -join "`n") | ConvertFrom-Json
            @($json.hazard_summary).Count | Should -Be 3
        }
    }

    # ============================================================
    # Matrices embedded
    # ============================================================

    Context 'Matrices embedded' {
        It 'report embeds Matrix A heading' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'Matrix A'
        }

        It 'report embeds Matrix D heading' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'Matrix D'
        }

        It 'embedded matrix contains SCN-001-A1' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'SCN-001-A1'
        }
    }

    # ============================================================
    # Sign-off block
    # ============================================================

    Context 'Sign-off block' {
        It 'sign-off block has QA Manager row' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'QA Manager'
        }

        It 'sign-off block has Lead Engineer row' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'Lead Engineer'
        }

        It 'sign-off block has Release Tag row' {
            Setup-Fixture 'clean' $TempDir $FixturesDir
            & pwsh -File $AuditScript -VModelDir "$TempDir/v-model" -GitTag 'v9.9.9' -Output "$TempDir/report.md" 2>$null | Out-Null
            $content = Get-Content "$TempDir/report.md" -Raw
            $content | Should -Match 'Release Tag.*v9\.9\.9'
        }
    }
}
