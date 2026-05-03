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
    function Invoke-SplicerStderr {
        # Run the splicer and return stderr text (stdout discarded). Uses a
        # same-dir temp file because PowerShell's `2>&1 1>$null` merges then
        # discards everything; redirecting to a file is the only reliable way
        # to isolate stderr from a child pwsh process.
        param([string[]]$ScriptArgs)
        $errFile = Join-Path $TestDrive ([System.IO.Path]::GetRandomFileName())
        & pwsh -NoProfile -File $script:SplicerScript @ScriptArgs 2>$errFile 1>$null
        $rc = $LASTEXITCODE
        $text = if (Test-Path -LiteralPath $errFile) { Get-Content -Raw -LiteralPath $errFile } else { '' }
        if ($null -eq $text) { $text = '' }
        return @{ ExitCode = $rc; Stderr = $text }
    }
}

Describe 'Splice-Managed-Regions (PowerShell mirror — D-009)' {

    It 'managed region replaced; user prologue + epilogue preserved (UTP-014-A, ATP-018-A)' {
        $f = Initialize-Splice $TestDrive
        Write-Envelope $f.Target
        Write-Generated $f.Generated
        $output = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>$null
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
        $output = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>$null
        $LASTEXITCODE | Should -Be 0
        $text = $output | Out-String
        $text | Should -Match 'BEGIN MANAGED id="MOD-005"'
        $text | Should -Match 'END MANAGED id="MOD-005"'
    }

    It 'idempotent re-run: second splice with same input is byte-identical (REQ-022)' {
        $f = Initialize-Splice $TestDrive
        Write-Envelope $f.Target
        Write-Generated $f.Generated
        $first = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>$null
        $LASTEXITCODE | Should -Be 0
        $firstText = ($first | ForEach-Object { $_.ToString() }) -join "`n"
        # Apply the first splice result to the target then splice again with the
        # same generated content; result must be unchanged.
        Set-Content -LiteralPath $f.Target -Value $firstText
        $second = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>$null
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
        & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>$null | Out-Null
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
        & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>$null | Out-Null
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
        $spliced = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>$null
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
        $output = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'bash' 2>$null
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
        $output = & pwsh -NoProfile -File $script:SplicerScript $f.Target $f.Generated 'python' 2>$null
        $LASTEXITCODE | Should -Be 0
        $text = $output | Out-String
        $text | Should -Match 'user prologue'
        $text | Should -Match 'user epilogue'
        $text | Should -Match 'FRESH GENERATED CONTENT'
    }

    # -----------------------------------------------------------------------
    # MF-5 hardening: id-match, duplicate-id, --region-from, diff-on-stderr.
    # -----------------------------------------------------------------------

    It 'MF-5: BEGIN/END id-mismatch → exit 2 with diagnostic; original untouched (HAZ-014)' {
        $f = Initialize-Splice $TestDrive
        @"
#!/bin/sh
# BEGIN MANAGED id="A"
echo "old"
# END MANAGED id="B"
"@ | Set-Content -LiteralPath $f.Target
        Write-Generated $f.Generated
        $pre = Get-Content -Raw -LiteralPath $f.Target
        $res = Invoke-SplicerStderr -ScriptArgs @($f.Target, $f.Generated, 'bash')
        $stderr = $res.Stderr
        $res.ExitCode | Should -Be 2
        $stderr | Should -Match 'id mismatch at line 4'
        $stderr | Should -Match 'BEGIN id="A"'
        $stderr | Should -Match 'END id="B"'
        (Get-Content -Raw -LiteralPath $f.Target) | Should -BeExactly $pre
    }

    It 'MF-5: duplicate region id in target → exit 2 with diagnostic; original untouched (HAZ-007)' {
        $f = Initialize-Splice $TestDrive
        @"
#!/bin/sh
# BEGIN MANAGED id="DUP"
echo "first"
# END MANAGED id="DUP"

# BEGIN MANAGED id="DUP"
echo "second"
# END MANAGED id="DUP"
"@ | Set-Content -LiteralPath $f.Target
        Write-Generated $f.Generated
        $pre = Get-Content -Raw -LiteralPath $f.Target
        $res = Invoke-SplicerStderr -ScriptArgs @($f.Target, $f.Generated, 'bash')
        $stderr = $res.Stderr
        $res.ExitCode | Should -Be 2
        $stderr | Should -Match 'duplicate region id "DUP"'
        $stderr | Should -Match 'first seen at line 2'
        (Get-Content -Raw -LiteralPath $f.Target) | Should -BeExactly $pre
    }

    It 'MF-5: --region-from happy path: per-id payload splicing (REQ-022)' {
        $f = Initialize-Splice $TestDrive
        @"
#!/bin/sh
echo "prologue"
# BEGIN MANAGED id="A"
OLD_A
# END MANAGED id="A"

echo "middle"
# BEGIN MANAGED id="B"
OLD_B
# END MANAGED id="B"
echo "epilogue"
"@ | Set-Content -LiteralPath $f.Target
        $regions = Join-Path (Split-Path -Parent $f.Target) 'regions.txt'
        @"
<<<REGION id="A">>>
echo "fresh A line 1"
echo "fresh A line 2"
<<<END>>>
<<<REGION id="B">>>
echo "fresh B"
<<<END>>>
"@ | Set-Content -LiteralPath $regions
        $output = & pwsh -NoProfile -File $script:SplicerScript '--region-from' $regions $f.Target 'bash' 2>$null
        $LASTEXITCODE | Should -Be 0
        $text = $output | Out-String
        $text | Should -Match 'prologue'
        $text | Should -Match 'middle'
        $text | Should -Match 'epilogue'
        $text | Should -Match 'fresh A line 1'
        $text | Should -Match 'fresh A line 2'
        $text | Should -Match 'fresh B'
        $text | Should -Not -Match 'OLD_A'
        $text | Should -Not -Match 'OLD_B'
        $text | Should -Match 'BEGIN MANAGED id="A"'
        $text | Should -Match 'END MANAGED id="B"'
    }

    It 'MF-5: --region-from missing payload → exit 2 (HAZ-007)' {
        $f = Initialize-Splice $TestDrive
        @"
#!/bin/sh
# BEGIN MANAGED id="C"
OLD_C
# END MANAGED id="C"
"@ | Set-Content -LiteralPath $f.Target
        $regions = Join-Path (Split-Path -Parent $f.Target) 'regions.txt'
        @"
<<<REGION id="A">>>
echo "fresh A"
<<<END>>>
"@ | Set-Content -LiteralPath $regions
        $pre = Get-Content -Raw -LiteralPath $f.Target
        $res = Invoke-SplicerStderr -ScriptArgs @('--region-from', $regions, $f.Target, 'bash')
        $stderr = $res.Stderr
        $res.ExitCode | Should -Be 2
        $stderr | Should -Match 'no payload provided for region id "C"'
        (Get-Content -Raw -LiteralPath $f.Target) | Should -BeExactly $pre
    }

    It 'MF-5: --region-from regions file with unbalanced markers → exit 2' {
        $f = Initialize-Splice $TestDrive
        @"
#!/bin/sh
echo "no envelope"
"@ | Set-Content -LiteralPath $f.Target
        $regions = Join-Path (Split-Path -Parent $f.Target) 'regions.txt'
        @"
<<<REGION id="A">>>
echo "dangling"
"@ | Set-Content -LiteralPath $regions
        $res = Invoke-SplicerStderr -ScriptArgs @('--region-from', $regions, $f.Target, 'bash')
        $stderr = $res.Stderr
        $res.ExitCode | Should -Be 2
        $stderr | Should -Match 'regions file: unbalanced REGION/END'
    }

    It 'MF-5: --region-from regions file with duplicate id → exit 2' {
        $f = Initialize-Splice $TestDrive
        @"
#!/bin/sh
echo "no envelope"
"@ | Set-Content -LiteralPath $f.Target
        $regions = Join-Path (Split-Path -Parent $f.Target) 'regions.txt'
        @"
<<<REGION id="A">>>
one
<<<END>>>
<<<REGION id="A">>>
two
<<<END>>>
"@ | Set-Content -LiteralPath $regions
        $res = Invoke-SplicerStderr -ScriptArgs @('--region-from', $regions, $f.Target, 'bash')
        $stderr = $res.Stderr
        $res.ExitCode | Should -Be 2
        $stderr | Should -Match 'regions file: duplicate id "A"'
    }

    It 'MF-5: --region-from rejects path-traversal id (D.5 hardening)' {
        $f = Initialize-Splice $TestDrive
        @"
#!/bin/sh
echo "no envelope"
"@ | Set-Content -LiteralPath $f.Target
        $regions = Join-Path (Split-Path -Parent $f.Target) 'regions.txt'
        @"
<<<REGION id="../../etc/passwd">>>
malicious
<<<END>>>
"@ | Set-Content -LiteralPath $regions
        $res = Invoke-SplicerStderr -ScriptArgs @('--region-from', $regions, $f.Target, 'bash')
        $stderr = $res.Stderr
        $res.ExitCode | Should -Be 2
        $stderr | Should -Match 'unsafe id'
    }

    It 'MF-5: target with path-traversal BEGIN id → exit 2 (D.5 hardening)' {
        $f = Initialize-Splice $TestDrive
        @"
#!/bin/sh
# BEGIN MANAGED id="../../tmp/x"
old
# END MANAGED id="../../tmp/x"
"@ | Set-Content -LiteralPath $f.Target
        Write-Generated $f.Generated
        $res = Invoke-SplicerStderr -ScriptArgs @($f.Target, $f.Generated, 'bash')
        $stderr = $res.Stderr
        $res.ExitCode | Should -Be 2
        $stderr | Should -Match 'unsafe region id'
    }

    It 'MF-5: diff summary on stderr for non-empty splice (legacy mode)' {
        $f = Initialize-Splice $TestDrive
        Write-Envelope $f.Target
        Write-Generated $f.Generated
        $res = Invoke-SplicerStderr -ScriptArgs @($f.Target, $f.Generated, 'bash')
        $stderr = $res.Stderr
        $res.ExitCode | Should -Be 0
        $stderrText = $stderr
        # Per D-009 / C.2-C.3 precedent, the STDERR diff format may differ
        # between bash and PowerShell — assert presence of the unified-diff
        # headers and the new content line.
        $stderrText | Should -Match '--- a/'
        $stderrText | Should -Match '\+\+\+ b/'
        $stderrText | Should -Match 'FRESH GENERATED CONTENT'
    }

    It 'MF-5: diff stderr is empty for sentinel-free no-op (HAZ-025)' {
        $f = Initialize-Splice $TestDrive
        @"
#!/bin/sh
echo "no envelope here"
"@ | Set-Content -LiteralPath $f.Target
        Write-Generated $f.Generated
        $res = Invoke-SplicerStderr -ScriptArgs @($f.Target, $f.Generated, 'bash')
        $stderr = $res.Stderr
        $res.ExitCode | Should -Be 0
        # No diff means stderr is empty (or only whitespace).
        $stderr.Trim() | Should -BeExactly ''
    }
}
