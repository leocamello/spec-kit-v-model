#Requires -Modules Pester
#
# Implements: REQ-NF-006, REQ-NF-002, REQ-023, REQ-NF-004,
#             SYS-006, ARCH-009, MOD-013, MOD-025,
#             UTP-013-A, UTP-025-A, HAZ-007, HAZ-023,
#             D-009, D-004, D-008.

BeforeAll {
    $script:ScriptsDir   = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $script:FixturesDir  = Resolve-Path (Join-Path $PSScriptRoot '../fixtures')
    $script:GuardScript  = Join-Path $ScriptsDir 'validate-implements-ids.ps1'

    function Initialize-Feature {
        param([string]$Root)
        # Per-call unique subdir — Pester 5 $TestDrive is shared across `It`s
        # in a Describe; isolating each test keeps stale fixtures from leaking.
        $base = Join-Path $Root ([System.IO.Path]::GetRandomFileName())
        $feature = Join-Path $base 'feature'
        $vmodel  = Join-Path $feature 'v-model'
        $src     = Join-Path $feature 'src'
        New-Item -ItemType Directory -Force -Path $vmodel | Out-Null
        New-Item -ItemType Directory -Force -Path $src    | Out-Null
        Copy-Item (Join-Path $script:FixturesDir 'v-model/complete/*.md') $vmodel
        return @{ Feature = $feature; Src = $src }
    }
}

Describe 'Validate-Implements-Ids (PowerShell mirror — D-009)' {

    It 'positive: every Implements <ID> resolves → exit 0, GUARD: PASS (UTP-013-A)' {
        $f = Initialize-Feature $TestDrive
        @"
#!/bin/sh
# Implements REQ-001
# Implements SYS-001
echo ok
"@ | Set-Content -LiteralPath (Join-Path $f.Src 'widget.sh')
        $output = & pwsh -NoProfile -File $script:GuardScript $f.Feature 2>&1
        $LASTEXITCODE | Should -Be 0
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -BeExactly 'GUARD: PASS'
    }

    It 'negative: one fabricated ID → exit 1 with <file>:<line>: unknown id <X> (HAZ-007)' {
        $f = Initialize-Feature $TestDrive
        # Build fabricated ID at runtime so this source contains no canonical
        # literal that would trip the project-level hallucination guard.
        $fab = 'REQ-' + (((1..5 | ForEach-Object { 9 }) -join ''))
        @"
#!/bin/sh
# Implements REQ-001
# Implements $fab
echo nope
"@ | Set-Content -LiteralPath (Join-Path $f.Src 'bad.sh')
        $output = & pwsh -NoProfile -File $script:GuardScript $f.Feature 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        $text = $output | Out-String
        $text | Should -Match 'bad\.sh:3'
        $text | Should -Match ([regex]::Escape($fab))
        $text | Should -Match 'unknown id'
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -BeExactly 'GUARD: FAIL'
    }

    It 'empty input: no Implements comments → exit 0 (ARCH-009)' {
        $f = Initialize-Feature $TestDrive
        @"
#!/bin/sh
echo nothing-here
"@ | Set-Content -LiteralPath (Join-Path $f.Src 'quiet.sh')
        $output = & pwsh -NoProfile -File $script:GuardScript $f.Feature 2>&1
        $LASTEXITCODE | Should -Be 0
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -BeExactly 'GUARD: PASS'
    }

    It 'cross-doc canonical extraction matches v-model/*.md (D-008, MOD-025, UTP-025-A)' {
        $f = Initialize-Feature $TestDrive
        $fab = 'ARCH-' + (((1..4 | ForEach-Object { 9 }) -join ''))
        @"
#!/bin/sh
# Implements $fab
echo cross-doc
"@ | Set-Content -LiteralPath (Join-Path $f.Src 'cross.sh')
        $output = & pwsh -NoProfile -File $script:GuardScript $f.Feature 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output | Out-String) | Should -Match ([regex]::Escape($fab))
    }

    It 'category-prefixed IDs (REQ-NF-NNN) resolve correctly (REQ-NF-002, MOD-013)' {
        $f = Initialize-Feature $TestDrive
        @"
#!/bin/sh
# Implements REQ-NF-001
echo nf
"@ | Set-Content -LiteralPath (Join-Path $f.Src 'nf.sh')
        & pwsh -NoProfile -File $script:GuardScript $f.Feature 2>&1 | Out-Null
        $LASTEXITCODE | Should -Be 0
    }

    It 'missing feature dir → exit 1 with stderr diagnostic (ARCH-009 error paths)' {
        & pwsh -NoProfile -File $script:GuardScript (Join-Path $TestDrive 'does-not-exist') 2>&1 | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
    }

    It 'stale-snapshot mitigation: re-run after fixture mutation reflects new canonical set (HAZ-023, REQ-NF-004)' {
        $f = Initialize-Feature $TestDrive
        @"
#!/bin/sh
# Implements REQ-001
echo ok
"@ | Set-Content -LiteralPath (Join-Path $f.Src 'widget.sh')
        & pwsh -NoProfile -File $script:GuardScript $f.Feature 2>&1 | Out-Null
        $LASTEXITCODE | Should -Be 0
        # Mutate fixture so REQ-001 disappears, then re-run; guard must now fail
        # (re-extracts canonical set on every invocation per D-004).
        '' | Set-Content -LiteralPath (Join-Path $f.Feature 'v-model/requirements.md')
        & pwsh -NoProfile -File $script:GuardScript $f.Feature 2>&1 | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
    }
}
