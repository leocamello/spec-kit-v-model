#Requires -Modules Pester
#
# Implements: REQ-NF-006, REQ-IF-001, REQ-IF-002, REQ-029,
#             SYS-010, ARCH-013, MOD-017, MOD-018,
#             UTP-017-A, UTP-018-A, ATP-002-A, SCN-002-A1,
#             D-009.

BeforeAll {
    $script:ScriptsDir     = Resolve-Path (Join-Path $PSScriptRoot '../../scripts/powershell')
    $script:ProjectRoot    = Resolve-Path (Join-Path $PSScriptRoot '../..')
    $script:SchemaScript   = Join-Path $ScriptsDir 'validate-core-schema.ps1'
    $script:PlanTemplate   = Join-Path $ProjectRoot '.specify/templates/plan-template.md'
    $script:TasksTemplate  = Join-Path $ProjectRoot '.specify/templates/tasks-template.md'
}

Describe 'Validate-Core-Schema (PowerShell mirror — D-009)' {

    It '-Plan: pristine spec-kit-core plan template passes (UTP-017-A, REQ-IF-001)' {
        $output = & pwsh -NoProfile -File $script:SchemaScript $script:PlanTemplate -Plan 2>&1
        $LASTEXITCODE | Should -Be 0
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -Match '^SCHEMA: PASS'
    }

    It '-Tasks: pristine spec-kit-core tasks template passes (UTP-018-A, REQ-IF-002)' {
        $output = & pwsh -NoProfile -File $script:SchemaScript $script:TasksTemplate -Tasks 2>&1
        $LASTEXITCODE | Should -Be 0
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -Match '^SCHEMA: PASS'
    }

    It '-Plan PASS line carries pinned schema version (ARCH-013 stdout schema)' {
        $output = & pwsh -NoProfile -File $script:SchemaScript $script:PlanTemplate -Plan 2>&1
        $LASTEXITCODE | Should -Be 0
        ($output | Out-String) | Should -Match 'pinned_version=v0\.7\.0'
    }

    It '-Plan: missing required section fails closed with MISSING diagnostic (REQ-029, SYS-010)' {
        $plan = Join-Path $TestDrive 'plan.md'
        $stripped = (Get-Content -LiteralPath $script:PlanTemplate) | Where-Object { $_ -ne '## Summary' }
        Set-Content -LiteralPath $plan -Value $stripped
        $output = & pwsh -NoProfile -File $script:SchemaScript $plan -Plan 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        $text = $output | Out-String
        $text | Should -Match 'MISSING'
        $lines = @($output | ForEach-Object { $_.ToString() })
        $lines[-1] | Should -BeExactly 'SCHEMA: FAIL'
    }

    It '-Tasks: missing required section fails closed (REQ-029, MOD-018)' {
        $tasks = Join-Path $TestDrive 'tasks.md'
        Set-Content -LiteralPath $tasks -Value ''
        $output = & pwsh -NoProfile -File $script:SchemaScript $tasks -Tasks 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($output | Out-String) | Should -Match 'MISSING'
    }

    It '-Plan: tolerates additive HTML-comment v-model enrichment (ATP-002-A, SCN-002-A1)' {
        $plan = Join-Path $TestDrive 'plan-enriched.md'
        $enriched = [System.Collections.Generic.List[string]]::new()
        foreach ($line in Get-Content -LiteralPath $script:PlanTemplate) {
            $enriched.Add($line)
            if ($line -match '^## ') {
                $enriched.Add('<!-- v-model: source=specs/007-bridge-commands/v-model/requirements.md -->')
            }
        }
        Set-Content -LiteralPath $plan -Value $enriched
        & pwsh -NoProfile -File $script:SchemaScript $plan -Plan 2>&1 | Out-Null
        $LASTEXITCODE | Should -Be 0
    }

    It '-Tasks: tolerates additive HTML-comment enrichment (ARCH-013, MOD-017)' {
        $tasks = Join-Path $TestDrive 'tasks-enriched.md'
        $enriched = [System.Collections.Generic.List[string]]::new()
        foreach ($line in Get-Content -LiteralPath $script:TasksTemplate) {
            $enriched.Add($line)
            if ($line -match '^## ') {
                $enriched.Add('<!-- v-model: tdd_phase=red -->')
            }
        }
        Set-Content -LiteralPath $tasks -Value $enriched
        & pwsh -NoProfile -File $script:SchemaScript $tasks -Tasks 2>&1 | Out-Null
        $LASTEXITCODE | Should -Be 0
    }

    It 'missing mode flag: exits non-zero (ARCH-013 CLI invocation)' {
        & pwsh -NoProfile -File $script:SchemaScript $script:PlanTemplate 2>&1 | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
    }

    It 'unknown mode flag: exits non-zero (REQ-029)' {
        & pwsh -NoProfile -File $script:SchemaScript $script:PlanTemplate -Bogus 2>&1 | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
    }

    It 'missing target file: exits non-zero with stderr diagnostic' {
        & pwsh -NoProfile -File $script:SchemaScript (Join-Path $TestDrive 'no-such.md') -Plan 2>&1 | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
    }

    # ---- MF-4: H2 ordering + wedge rejection ----

    BeforeAll {
        function script:New-PlanFixture {
            param([string]$Path, [string[]]$Headings)
            $body = [System.Collections.Generic.List[string]]::new()
            foreach ($h in $Headings) {
                $body.Add($h)
                $body.Add('')
                $body.Add("Filler body for $h.")
                $body.Add('')
            }
            Set-Content -LiteralPath $Path -Value $body
        }
    }

    It 'rejects wrong H2 order in plan.md (MF-4 ORDER)' {
        $plan = Join-Path $TestDrive ([System.IO.Path]::GetRandomFileName())
        script:New-PlanFixture -Path $plan -Headings @(
            '## Summary',
            '## Technical Context',
            '## Project Structure',
            '## Constitution Check',
            '## Complexity Tracking'
        )
        $output = & pwsh -NoProfile -File $script:SchemaScript $plan -Plan 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        $text = ($output | Out-String)
        $text | Should -Match 'ORDER: FAIL'
        $text | Should -Match 'SCHEMA: FAIL'
    }

    It 'rejects wedged non-canonical H2 in plan.md (MF-4 WEDGE)' {
        $plan = Join-Path $TestDrive ([System.IO.Path]::GetRandomFileName())
        New-PlanFixture -Path $plan -Headings @(
            '## Summary',
            '## Technical Context',
            '## Random Wedged Heading',
            '## Constitution Check',
            '## Project Structure',
            '## Complexity Tracking'
        )
        $output = & pwsh -NoProfile -File $script:SchemaScript $plan -Plan 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        $text = ($output | Out-String)
        $text | Should -Match 'WEDGE: FAIL'
        $text | Should -Match 'Random Wedged Heading'
        $text | Should -Match 'SCHEMA: FAIL'
    }

    It 'accepts trailing extra H2 after last canonical (MF-4)' {
        $plan = Join-Path $TestDrive ([System.IO.Path]::GetRandomFileName())
        New-PlanFixture -Path $plan -Headings @(
            '## Summary',
            '## Technical Context',
            '## Constitution Check',
            '## Project Structure',
            '## Complexity Tracking',
            '## Appendix Notes'
        )
        $output = & pwsh -NoProfile -File $script:SchemaScript $plan -Plan 2>&1
        $LASTEXITCODE | Should -Be 0
        ($output | Out-String) | Should -Match 'SCHEMA: PASS'
    }

    It 'accepts preamble H2 before first canonical (MF-4)' {
        $plan = Join-Path $TestDrive ([System.IO.Path]::GetRandomFileName())
        New-PlanFixture -Path $plan -Headings @(
            '## Preamble Notes',
            '## Summary',
            '## Technical Context',
            '## Constitution Check',
            '## Project Structure',
            '## Complexity Tracking'
        )
        $output = & pwsh -NoProfile -File $script:SchemaScript $plan -Plan 2>&1
        $LASTEXITCODE | Should -Be 0
        ($output | Out-String) | Should -Match 'SCHEMA: PASS'
    }
}
