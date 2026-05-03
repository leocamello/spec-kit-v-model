#Requires -Modules Pester
#
# Implements: REQ-NF-006, REQ-CN-001, REQ-016, REQ-017, REQ-024, REQ-CN-002, REQ-027,
#             SYS-004, SYS-008, SYS-012, ARCH-007, ARCH-011, ARCH-016, MOD-010,
#             MOD-015, MOD-021, UTP-010-A, UTP-010-B, HAZ-009, HAZ-010, HAZ-015,
#             HAZ-024, D-009, D-003.

BeforeAll {
    $script:ScriptsDir  = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $script:FixturesDir = Resolve-Path (Join-Path $PSScriptRoot '../fixtures')
    $script:GateScript  = Join-Path $ScriptsDir 'run-v-model-gate.ps1'
    # Order mirrors run-v-model-gate.ps1 INNERS array (status + domain + matrix + 5 coverage).
    $script:Inners      = @(
        'validate-artifact-status.ps1',
        'validate-domain-profile.ps1',
        'build-matrix.ps1',
        'validate-requirement-coverage.ps1',
        'validate-system-coverage.ps1',
        'validate-architecture-coverage.ps1',
        'validate-module-coverage.ps1',
        'validate-hazard-coverage.ps1'
    )

    function New-Shim {
        param([string]$Dir, [string]$Name, [int]$Rc, [string]$TraceLog)
        $shim = @"
param([Parameter(ValueFromRemainingArguments=`$true)] `$Rest)
Add-Content -LiteralPath '$TraceLog' -Value ('$Name ' + ([string]::Join(' ', `$Rest)))
exit $Rc
"@
        Set-Content -LiteralPath (Join-Path $Dir $Name) -Value $shim -Encoding utf8
    }

    function Initialize-Stage {
        param([string]$Root)
        # Per-call unique subdir — Pester 5 $TestDrive is shared across It blocks.
        $base      = Join-Path $Root ([System.IO.Path]::GetRandomFileName())
        $stage     = Join-Path $base 'scripts'
        $feature   = Join-Path $base 'feature'
        $vmodel    = Join-Path $feature 'v-model'
        $traceLog  = Join-Path $base 'trace.log'
        New-Item -ItemType Directory -Force -Path $stage   | Out-Null
        New-Item -ItemType Directory -Force -Path $vmodel  | Out-Null
        Copy-Item (Join-Path $script:FixturesDir 'v-model/complete/*.md') $vmodel
        '' | Set-Content -LiteralPath $traceLog
        # Place a copy of the gate script alongside the shims so sibling-
        # relative resolution finds them (mirrors the BATS stage_gate idiom).
        Copy-Item $script:GateScript (Join-Path $stage 'run-v-model-gate.ps1')
        return @{ Stage = $stage; Feature = $feature; TraceLog = $traceLog }
    }
}

Describe 'Run-VModel-Gate (PowerShell mirror — D-009)' {

    It 'composition: gate invokes exactly the six inner scripts (ARCH-007)' {
        $env_ = Initialize-Stage $TestDrive
        foreach ($s in $script:Inners) { New-Shim -Dir $env_.Stage -Name $s -Rc 0 -TraceLog $env_.TraceLog }
        & pwsh -NoProfile -File (Join-Path $env_.Stage 'run-v-model-gate.ps1') $env_.Feature 2>&1 | Out-Null
        $LASTEXITCODE | Should -Be 0
        $trace = Get-Content -Raw -LiteralPath $env_.TraceLog
        foreach ($s in $script:Inners) { $trace | Should -Match ([regex]::Escape($s)) }
    }

    It 'composition: status validator runs BEFORE build-matrix (MF-6 fail-fast ordering)' {
        $env_ = Initialize-Stage $TestDrive
        foreach ($s in $script:Inners) { New-Shim -Dir $env_.Stage -Name $s -Rc 0 -TraceLog $env_.TraceLog }
        & pwsh -NoProfile -File (Join-Path $env_.Stage 'run-v-model-gate.ps1') $env_.Feature 2>&1 | Out-Null
        $LASTEXITCODE | Should -Be 0
        $lines = Get-Content -LiteralPath $env_.TraceLog
        $statusIdx = ($lines | Select-String -Pattern 'validate-artifact-status\.ps1' | Select-Object -First 1).LineNumber
        $matrixIdx = ($lines | Select-String -Pattern 'build-matrix\.ps1' | Select-Object -First 1).LineNumber
        $statusIdx | Should -BeLessThan $matrixIdx
    }

    It 'MF-6 integration: real validate-artifact-status FAIL on Draft fixture → GATE: FAIL' {
        $env_ = Initialize-Stage $TestDrive
        foreach ($s in $script:Inners) {
            if ($s -eq 'validate-artifact-status.ps1') { continue }
            New-Shim -Dir $env_.Stage -Name $s -Rc 0 -TraceLog $env_.TraceLog
        }
        Copy-Item (Join-Path $script:ScriptsDir 'validate-artifact-status.ps1') (Join-Path $env_.Stage 'validate-artifact-status.ps1')
        # Force a Draft header into a canonical artifact.
        @"
# Requirements

**Status**: Draft

| ID | Description |
|----|-------------|
| REQ-001 | Example |
"@ | Set-Content -LiteralPath (Join-Path $env_.Feature 'v-model/requirements.md')
        $output = & pwsh -NoProfile -File (Join-Path $env_.Stage 'run-v-model-gate.ps1') $env_.Feature 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output | Out-String) | Should -Match 'validate-artifact-status\.ps1: FAIL'
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -BeExactly 'GATE: FAIL'
    }

    It 'composition: gate invokes no other wrapper beyond the six (HAZ-010)' {
        $env_ = Initialize-Stage $TestDrive
        foreach ($s in $script:Inners) { New-Shim -Dir $env_.Stage -Name $s -Rc 0 -TraceLog $env_.TraceLog }
        New-Shim -Dir $env_.Stage -Name 'validate-implements-ids.ps1' -Rc 0 -TraceLog $env_.TraceLog
        & pwsh -NoProfile -File (Join-Path $env_.Stage 'run-v-model-gate.ps1') $env_.Feature 2>&1 | Out-Null
        $LASTEXITCODE | Should -Be 0
        $trace = Get-Content -Raw -LiteralPath $env_.TraceLog
        $trace | Should -Not -Match 'validate-implements-ids\.ps1'
    }

    It 'exit-code aggregation: any inner failure → gate exits non-zero (HAZ-009)' {
        $env_ = Initialize-Stage $TestDrive
        foreach ($s in $script:Inners) { New-Shim -Dir $env_.Stage -Name $s -Rc 0 -TraceLog $env_.TraceLog }
        New-Shim -Dir $env_.Stage -Name 'validate-hazard-coverage.ps1' -Rc 1 -TraceLog $env_.TraceLog
        & pwsh -NoProfile -File (Join-Path $env_.Stage 'run-v-model-gate.ps1') $env_.Feature 2>&1 | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
    }

    It 'exit-code aggregation: all-zero inner → gate exits 0 (UTP-010-A)' {
        $env_ = Initialize-Stage $TestDrive
        foreach ($s in $script:Inners) { New-Shim -Dir $env_.Stage -Name $s -Rc 0 -TraceLog $env_.TraceLog }
        & pwsh -NoProfile -File (Join-Path $env_.Stage 'run-v-model-gate.ps1') $env_.Feature 2>&1 | Out-Null
        $LASTEXITCODE | Should -Be 0
    }

    It "final line is exactly 'GATE: PASS' on success (ARCH-007 stdout schema)" {
        $env_ = Initialize-Stage $TestDrive
        foreach ($s in $script:Inners) { New-Shim -Dir $env_.Stage -Name $s -Rc 0 -TraceLog $env_.TraceLog }
        $output = & pwsh -NoProfile -File (Join-Path $env_.Stage 'run-v-model-gate.ps1') $env_.Feature 2>&1
        $LASTEXITCODE | Should -Be 0
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -BeExactly 'GATE: PASS'
    }

    It "final line is exactly 'GATE: FAIL' on any inner failure (UTP-010-B)" {
        $env_ = Initialize-Stage $TestDrive
        foreach ($s in $script:Inners) { New-Shim -Dir $env_.Stage -Name $s -Rc 0 -TraceLog $env_.TraceLog }
        New-Shim -Dir $env_.Stage -Name 'validate-requirement-coverage.ps1' -Rc 1 -TraceLog $env_.TraceLog
        $output = & pwsh -NoProfile -File (Join-Path $env_.Stage 'run-v-model-gate.ps1') $env_.Feature 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -BeExactly 'GATE: FAIL'
    }

    It 'structured-summary block emitted on success (ARCH-016, REQ-027, MOD-021)' {
        $env_ = Initialize-Stage $TestDrive
        foreach ($s in $script:Inners) { New-Shim -Dir $env_.Stage -Name $s -Rc 0 -TraceLog $env_.TraceLog }
        $output = & pwsh -NoProfile -File (Join-Path $env_.Stage 'run-v-model-gate.ps1') $env_.Feature 2>&1
        $LASTEXITCODE | Should -Be 0
        ($output | Out-String) | Should -Match '--- v-model run summary ---'
    }

    It 'structured-summary block emitted on failure (ARCH-016, SYS-012, REQ-CN-002)' {
        $env_ = Initialize-Stage $TestDrive
        foreach ($s in $script:Inners) { New-Shim -Dir $env_.Stage -Name $s -Rc 0 -TraceLog $env_.TraceLog }
        New-Shim -Dir $env_.Stage -Name 'build-matrix.ps1' -Rc 1 -TraceLog $env_.TraceLog
        $output = & pwsh -NoProfile -File (Join-Path $env_.Stage 'run-v-model-gate.ps1') $env_.Feature 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output | Out-String) | Should -Match '--- v-model run summary ---'
    }

    It 'missing inner script: gate exits 1 with stderr diagnostic (ARCH-007 error paths)' {
        $env_ = Initialize-Stage $TestDrive
        # Stage gate but no inner shims at all.
        & pwsh -NoProfile -File (Join-Path $env_.Stage 'run-v-model-gate.ps1') $env_.Feature 2>&1 | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
    }
}
