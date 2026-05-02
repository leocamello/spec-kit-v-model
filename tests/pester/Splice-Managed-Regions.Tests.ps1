#Requires -Modules Pester
#
# Implements: REQ-NF-006, REQ-NF-005, REQ-022, REQ-CN-003,
#             SYS-007, SYS-015, ARCH-010, MOD-014,
#             UTP-014-A, UTP-014-B, HAZ-008, HAZ-014, HAZ-025,
#             D-009, D-005, D-015, D-016.

BeforeAll {
    $script:ScriptsDir    = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $script:SplicerScript = Join-Path $ScriptsDir 'splice-managed-regions.ps1'

    function Initialize-Splice {
        param([string]$Root)
        # Per-call unique subdir — Pester 5 $TestDrive is shared across It blocks.
        $base = Join-Path $Root ([System.IO.Path]::GetRandomFileName())
        New-Item -ItemType Directory -Force -Path $base | Out-Null
        $target    = Join-Path $base 'widget.sh'
        $generated = Join-Path $base 'generated.txt'
        return @{ Target = $target; Generated = $generated }
    }

    function Write-Envelope {
        param([string]$Path)
        @"
#!/bin/sh
# user header — must survive splice (ATP-018-A)
echo "user prologue"

# BEGIN MANAGED id="MOD-005"
echo "OLD GENERATED CONTENT"
# END MANAGED id="MOD-005"

echo "user epilogue"
"@ | Set-Content -LiteralPath $Path
    }

    function Write-Generated {
        param([string]$Path)
        @"
echo "FRESH GENERATED CONTENT"
"@ | Set-Content -LiteralPath $Path
    }
}

Describe 'Splice-Managed-Regions (PowerShell mirror — D-009)' {

    It 'managed region replaced; user prologue + epilogue preserved (UTP-014-A, ATP-018-A)' {
        $f = Initialize-Splice $TestDrive
        Write-Envelope $f.Target
        Write-Generated $f.Generated
        $output = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>&1
        $LASTEXITCODE | Should -Be 0
        $text = $output | Out-String
        $text | Should -Match 'user prologue'
        $text | Should -Match 'user epilogue'
        $text | Should -Match 'FRESH GENERATED CONTENT'
        $text | Should -Not -Match 'OLD GENERATED CONTENT'
    }

    It 'sentinels themselves preserved verbatim (D-015)' {
        $f = Initialize-Splice $TestDrive
        Write-Envelope $f.Target
        Write-Generated $f.Generated
        $output = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>&1
        $LASTEXITCODE | Should -Be 0
        $text = $output | Out-String
        $text | Should -Match 'BEGIN MANAGED id="MOD-005"'
        $text | Should -Match 'END MANAGED id="MOD-005"'
    }

    It 'idempotent re-run: second splice with same input is byte-identical (REQ-022)' {
        $f = Initialize-Splice $TestDrive
        Write-Envelope $f.Target
        Write-Generated $f.Generated
        $first = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>&1
        $LASTEXITCODE | Should -Be 0
        $firstText = ($first | ForEach-Object { $_.ToString() }) -join "`n"
        # Apply the first splice result to the target then splice again with the
        # same generated content; result must be unchanged.
        Set-Content -LiteralPath $f.Target -Value $firstText
        $second = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>&1
        $LASTEXITCODE | Should -Be 0
        $secondText = ($second | ForEach-Object { $_.ToString() }) -join "`n"
        $secondText | Should -BeExactly $firstText
    }

    It 'unbalanced markers (BEGIN without END) → exit non-zero, original untouched (HAZ-014, UTP-014-B)' {
        $f = Initialize-Splice $TestDrive
        @"
#!/bin/sh
# BEGIN MANAGED id="MOD-005"
echo "dangling"
"@ | Set-Content -LiteralPath $f.Target
        Write-Generated $f.Generated
        $pre = Get-Content -Raw -LiteralPath $f.Target
        & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>&1 | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
        $post = Get-Content -Raw -LiteralPath $f.Target
        $post | Should -BeExactly $pre
    }

    It 'overlapping markers (BEGIN inside BEGIN) → exit non-zero (HAZ-008, ARCH-010 error paths)' {
        $f = Initialize-Splice $TestDrive
        @"
#!/bin/sh
# BEGIN MANAGED id="MOD-005"
# BEGIN MANAGED id="MOD-006"
echo "nested"
# END MANAGED id="MOD-006"
# END MANAGED id="MOD-005"
"@ | Set-Content -LiteralPath $f.Target
        Write-Generated $f.Generated
        & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>&1 | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
    }

    It 'atomic-rename idiom (D-016): same-dir temp + Move-Item leaves no leftovers (SYS-015, REQ-NF-005)' {
        $f = Initialize-Splice $TestDrive
        Write-Envelope $f.Target
        Write-Generated $f.Generated
        $targetDir = Split-Path -Parent $f.Target
        # Caller-side idiom from ARCH-010 §Side-effects, PowerShell variant
        # that keeps the temp file in the SAME directory as the target (avoids
        # $env:TEMP per repo policy and matches mktemp -p $(dirname …) from D-016).
        $tmp = Join-Path $targetDir ([System.IO.Path]::GetRandomFileName())
        $spliced = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>&1
        $LASTEXITCODE | Should -Be 0
        ($spliced | ForEach-Object { $_.ToString() }) -join "`n" | Set-Content -LiteralPath $tmp
        Move-Item -LiteralPath $tmp -Destination $f.Target -Force
        # No temp leftovers: enumerate the target dir flat (depth-1) and assert
        # nothing matches `tmp.*` or `<basename>.*` (mirrors the BATS find
        # precedence fix from c9488ea).
        $base = Split-Path -Leaf $f.Target
        $leftovers = Get-ChildItem -LiteralPath $targetDir -File -Force |
            Where-Object { $_.Name -like 'tmp.*' -or ($_.Name -like "$base.*") }
        @($leftovers).Count | Should -Be 0
        (Get-Content -Raw -LiteralPath $f.Target) | Should -Match 'FRESH GENERATED CONTENT'
    }

    It 'sentinel-free target: splicer treats input as no-op envelope (HAZ-025, REQ-CN-003)' {
        $f = Initialize-Splice $TestDrive
        @"
#!/bin/sh
echo "no envelope here"
"@ | Set-Content -LiteralPath $f.Target
        Write-Generated $f.Generated
        $output = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>&1
        # Per D-005 the splicer MUST NOT silently overwrite user content. Either
        # exit 0 with the original on stdout, or refuse with non-zero exit.
        if ($LASTEXITCODE -eq 0) {
            $text = $output | Out-String
            $text | Should -Match 'no envelope here'
            $text | Should -Not -Match 'FRESH GENERATED CONTENT'
        }
    }

    It "language=python uses '# BEGIN MANAGED' marker syntax (D-015, MOD-014)" {
        $f = Initialize-Splice $TestDrive
        @"
#!/usr/bin/env python3
# user prologue
# BEGIN MANAGED id="MOD-005"
print("old")
# END MANAGED id="MOD-005"
# user epilogue
"@ | Set-Content -LiteralPath $f.Target
        Write-Generated $f.Generated
        $output = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'python' 2>&1
        $LASTEXITCODE | Should -Be 0
        $text = $output | Out-String
        $text | Should -Match 'user prologue'
        $text | Should -Match 'user epilogue'
        $text | Should -Match 'FRESH GENERATED CONTENT'
    }
}
