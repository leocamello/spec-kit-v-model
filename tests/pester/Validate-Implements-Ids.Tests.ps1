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

# ---------------------------------------------------------------------------
# Step C.4 (MF-2): scope-aware flags -Canonical / -Scan / -ChangedOnly.
# Per-test isolation via $TestDrive sub-dirs (Pester 5).
# ---------------------------------------------------------------------------

Describe 'Validate-Implements-Ids — C.4 scope-aware flags' {

    BeforeAll {
        function New-RepoLayout {
            $base = Join-Path $TestDrive ([System.IO.Path]::GetRandomFileName())
            $repo = Join-Path $base 'repo'
            $vmodel = Join-Path $repo 'specs/feat/v-model'
            $src = Join-Path $repo 'src'
            New-Item -ItemType Directory -Force -Path $vmodel | Out-Null
            New-Item -ItemType Directory -Force -Path $src    | Out-Null
            Copy-Item (Join-Path $script:FixturesDir 'v-model/complete/*.md') $vmodel
            return @{ Repo = $repo; VModel = $vmodel; Src = $src }
        }
        $script:GitAvailable = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
    }

    It 'C.4 -Scan flag scans the supplied directory tree (canonical IDs accepted)' {
        $L = New-RepoLayout
        @"
# Implements: REQ-001
print("ok")
"@ | Set-Content -LiteralPath (Join-Path $L.Src 'foo.py')
        $output = & pwsh -NoProfile -File $script:GuardScript -Canonical $L.VModel -Scan $L.Repo 2>&1
        $LASTEXITCODE | Should -Be 0
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -BeExactly 'GUARD: PASS'
    }

    It 'C.4 -Scan rejects an unknown ID injected into src/' {
        $L = New-RepoLayout
        $fab = 'REQ-' + (((1..3 | ForEach-Object { 9 }) -join ''))
        @"
# Implements: $fab
print("nope")
"@ | Set-Content -LiteralPath (Join-Path $L.Src 'foo.py')
        $output = & pwsh -NoProfile -File $script:GuardScript -Canonical $L.VModel -Scan $L.Repo 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output | Out-String) | Should -Match ("unknown id " + [regex]::Escape($fab))
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -BeExactly 'GUARD: FAIL'
    }

    It 'C.4 -ChangedOnly restricts to git diff + untracked (committed baseline ignored)' {
        if (-not $script:GitAvailable) { Set-ItResult -Skipped -Because 'git not available' }
        $L = New-RepoLayout
        & git -C $L.Repo init --quiet 2>$null
        & git -C $L.Repo config user.email t@t 2>$null
        & git -C $L.Repo config user.name t 2>$null
        $fab = 'REQ-' + (((1..5 | ForEach-Object { 9 }) -join ''))
        @"
# Implements: $fab
print("old")
"@ | Set-Content -LiteralPath (Join-Path $L.Src 'old.py')
        @"
# Implements: REQ-001
print("baseline")
"@ | Set-Content -LiteralPath (Join-Path $L.Src 'changed.py')
        & git -C $L.Repo add . 2>$null | Out-Null
        & git -C $L.Repo commit --quiet -m baseline 2>$null | Out-Null
        @"
# Implements: REQ-001
# Implements: SYS-001
print("changed-modified")
"@ | Set-Content -LiteralPath (Join-Path $L.Src 'changed.py')
        @"
# Implements: REQ-001
print("new")
"@ | Set-Content -LiteralPath (Join-Path $L.Src 'new.py')

        $output = & pwsh -NoProfile -File $script:GuardScript -Canonical $L.VModel -Scan $L.Repo -ChangedOnly 2>&1
        $LASTEXITCODE | Should -Be 0
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -BeExactly 'GUARD: PASS'

        # Without -ChangedOnly, the bad committed file IS scanned and fails.
        $output2 = & pwsh -NoProfile -File $script:GuardScript -Canonical $L.VModel -Scan $L.Repo 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output2 | Out-String) | Should -Match ("unknown id " + [regex]::Escape($fab))
    }

    It 'C.4 -ChangedOnly outside git falls back gracefully' {
        $L = New-RepoLayout
        @"
# Implements: REQ-001
print("ok")
"@ | Set-Content -LiteralPath (Join-Path $L.Src 'foo.py')
        $output = & pwsh -NoProfile -File $script:GuardScript -Canonical $L.VModel -Scan $L.Repo -ChangedOnly 2>&1
        $LASTEXITCODE | Should -Be 0
        ($output | Out-String) | Should -Match 'not a git working tree'
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -BeExactly 'GUARD: PASS'
    }

    It 'C.4 legacy positional invocation matches -Canonical/-Scan equivalents' {
        $L = New-RepoLayout
        $feature = Split-Path -Parent $L.VModel
        $featureSrc = Join-Path $feature 'src'
        New-Item -ItemType Directory -Force -Path $featureSrc | Out-Null
        @"
#!/bin/sh
# Implements REQ-001
# Implements SYS-001
echo ok
"@ | Set-Content -LiteralPath (Join-Path $featureSrc 'widget.sh')
        $legacyOut = (& pwsh -NoProfile -File $script:GuardScript $feature 2>&1) | Out-String
        $legacyRc  = $LASTEXITCODE
        $flagOut   = (& pwsh -NoProfile -File $script:GuardScript -Canonical (Join-Path $feature 'v-model') -Scan $feature 2>&1) | Out-String
        $flagRc    = $LASTEXITCODE
        $legacyRc | Should -Be $flagRc
        $legacyOut | Should -BeExactly $flagOut
    }

    It 'C.4 -Canonical without -Scan or feature-dir fails with clear error' {
        $L = New-RepoLayout
        $output = & pwsh -NoProfile -File $script:GuardScript -Canonical $L.VModel 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output | Out-String) | Should -Match '-Scan is required'
    }
}
