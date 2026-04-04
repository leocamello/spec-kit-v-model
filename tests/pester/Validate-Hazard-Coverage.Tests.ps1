#Requires -Modules Pester

BeforeAll {
    $ScriptsDir = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures')
}

Describe 'Validate-HazardCoverage' {
    Context 'Full coverage (minimal fixture)' {
        It 'exits 0 for full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" "$FixturesDir/minimal" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'shows success message with Forward Coverage' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'Forward Coverage'
        }

        It 'JSON shows has_gaps false' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.has_gaps | Should -Be $false
        }

        It 'reports correct totals' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total_sys | Should -Be 3
            $json.total_haz | Should -Be 5
        }

        It 'uses implicit NORMAL state' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $json = $output | ConvertFrom-Json
            $json.implicit_normal | Should -Be $true
        }

        It 'forward coverage is 100%' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $json = $output | ConvertFrom-Json
            $json.forward_coverage_pct | Should -Be 100
        }

        It 'backward coverage is 100%' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $json = $output | ConvertFrom-Json
            $json.backward_coverage_pct | Should -Be 100
        }

        It 'state consistency is true' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/minimal" 2>&1
            $json = $output | ConvertFrom-Json
            $json.state_consistent | Should -Be $true
        }
    }

    Context 'Complex fixture (many-to-many)' {
        It 'exits 0 for full coverage' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" "$FixturesDir/complex" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
        }

        It 'has 12 HAZ and 6 SYS' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/complex" 2>&1
            $json = $output | ConvertFrom-Json
            $json.total_sys | Should -Be 6
            $json.total_haz | Should -Be 12
        }

        It 'detects explicit states' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/complex" 2>&1
            $json = $output | ConvertFrom-Json
            $json.implicit_normal | Should -Be $false
        }

        It 'state consistency is true' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/complex" 2>&1
            $json = $output | ConvertFrom-Json
            $json.state_consistent | Should -Be $true
        }
    }

    Context 'Gaps fixture' {
        It 'exits 1 when gaps exist' {
            & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" "$FixturesDir/gaps" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'JSON shows has_gaps true' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/gaps" 2>&1
            $json = $output | ConvertFrom-Json
            $json.has_gaps | Should -Be $true
        }

        It 'forward coverage is 50%' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/gaps" 2>&1
            $json = $output | ConvertFrom-Json
            $json.forward_coverage_pct | Should -Be 50
        }

        It 'backward coverage is 66%' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/gaps" 2>&1
            $json = $output | ConvertFrom-Json
            $json.backward_coverage_pct | Should -Be 66
        }

        It 'detects forward gap SYS-002' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/gaps" 2>&1
            $json = $output | ConvertFrom-Json
            $json.forward_gaps | Should -Contain 'SYS-002'
        }

        It 'detects undefined state EMERGENCY' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Json "$FixturesDir/gaps" 2>&1
            $json = $output | ConvertFrom-Json
            $json.state_warnings | Should -Contain 'EMERGENCY'
        }

        It 'detects backward gap (HAZ-002)' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" "$FixturesDir/gaps" 2>&1
            ($output -join "`n") | Should -Match 'HAZ-002'
        }
    }

    Context 'Partial mode' {
        It '--Partial skips backward when requirements.md absent' {
            $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
            Copy-Item "$FixturesDir/minimal/hazard-analysis.md" "$tempDir/"
            Copy-Item "$FixturesDir/minimal/system-design.md" "$tempDir/"
            & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Partial "$tempDir" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 0
            Remove-Item -Recurse -Force $tempDir
        }

        It '--Partial JSON shows partial_mode true' {
            $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
            Copy-Item "$FixturesDir/minimal/hazard-analysis.md" "$tempDir/"
            Copy-Item "$FixturesDir/minimal/system-design.md" "$tempDir/"
            $output = & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" -Partial -Json "$tempDir" 2>&1
            $LASTEXITCODE | Should -Be 0
            $json = $output | ConvertFrom-Json
            $json.partial_mode | Should -Be $true
            Remove-Item -Recurse -Force $tempDir
        }
    }

    Context 'Error handling' {
        It 'exits 1 when no arguments' {
            & pwsh -NoProfile -NonInteractive -File "$ScriptsDir/validate-hazard-coverage.ps1" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
        }

        It 'exits 1 when system-design.md missing' {
            $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
            New-Item -ItemType File -Path "$tempDir/hazard-analysis.md" | Out-Null
            & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" "$tempDir" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
            Remove-Item -Recurse -Force $tempDir
        }

        It 'exits 1 when hazard-analysis.md missing' {
            $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
            New-Item -ItemType File -Path "$tempDir/system-design.md" | Out-Null
            & pwsh -NoProfile -File "$ScriptsDir/validate-hazard-coverage.ps1" "$tempDir" 2>&1 | Out-Null
            $LASTEXITCODE | Should -Be 1
            Remove-Item -Recurse -Force $tempDir
        }
    }
}

Describe 'Build-Matrix: Matrix H' {
    Context 'Minimal fixture' {
        It 'generates Matrix H section' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/minimal" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'Matrix H'
        }

        It 'Matrix H has 5 HAZ entries' {
            $tempFile = New-TemporaryFile
            & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" -Output $tempFile "$FixturesDir/minimal" 2>&1 | Out-Null
            $content = Get-Content $tempFile -Raw
            $count = ([regex]::Matches($content, '^\| HAZ-', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
            $count | Should -Be 5
            Remove-Item $tempFile
        }

        It 'Matrix H coverage is 100%' {
            $tempFile = New-TemporaryFile
            & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" -Output $tempFile "$FixturesDir/minimal" 2>&1 | Out-Null
            $content = Get-Content $tempFile -Raw
            $content | Should -Match '5/5 \(100%\)'
            Remove-Item $tempFile
        }
    }

    Context 'Complex fixture' {
        It 'Matrix H has 12 HAZ entries' {
            $tempFile = New-TemporaryFile
            & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" -Output $tempFile "$FixturesDir/complex" 2>&1 | Out-Null
            $content = Get-Content $tempFile -Raw
            $count = ([regex]::Matches($content, '^\| HAZ-', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
            $count | Should -Be 12
            Remove-Item $tempFile
        }
    }

    Context 'Backward compatibility' {
        It 'no Matrix H without hazard-analysis.md' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/empty" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Not -Match 'Matrix H'
        }

        It 'gaps fixture still generates Matrix H' {
            $output = & pwsh -NoProfile -File "$ScriptsDir/build-matrix.ps1" "$FixturesDir/gaps" 2>&1
            $LASTEXITCODE | Should -Be 0
            ($output -join "`n") | Should -Match 'Matrix H'
        }
    }
}
