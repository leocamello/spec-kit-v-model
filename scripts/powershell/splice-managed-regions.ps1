<#
.SYNOPSIS
    Sentinel-bounded MANAGED-region splicer (PowerShell mirror of
    splice-managed-regions.sh).

.DESCRIPTION
    Replaces `BEGIN MANAGED id="…"` / `END MANAGED id="…"` regions in
    <Target> with the contents of <Generated>, writing the result to STDOUT.
    The caller is responsible for the atomic mktemp + Move-Item write idiom
    (D-016, SYS-015) — this script never writes the target file directly.

    Sentinels themselves are preserved verbatim (D-015). Refuses on nested
    BEGIN, orphan END, or unclosed region with an exit code of 1 and a stderr
    diagnostic; the original target is untouched (HAZ-014).

.PARAMETER Target
    The target file containing managed-region envelopes.

.PARAMETER Generated
    File whose contents replace each managed region.

.PARAMETER Language
    Comment-marker family. `bash`/`sh`/`python`/`py`/`pwsh`/`powershell`/
    `ps1`/`yaml`/`yml`/`ruby`/`rb` use `#`; `js`/`ts`/`javascript`/`typescript`
    /`c`/`cpp`/`java`/`go`/`rust` use `//`; `html`/`md`/`markdown`/`xml` use
    `<!--`.

.EXAMPLE
    pwsh -File ./splice-managed-regions.ps1 widget.sh generated.txt bash

.NOTES
    Implements: REQ-NF-006, REQ-NF-005, REQ-022,
                SYS-007, SYS-015, ARCH-010, MOD-014,
                UTP-014-A, UTP-014-B, D-009, D-005, D-015, D-016.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Target,
    [Parameter(Position = 1)]
    [string]$Generated,
    [Parameter(Position = 2)]
    [string]$Language
)

$ErrorActionPreference = 'Stop'

if ($Target -in @('--help', '-h', '-Help')) {
    Write-Output 'Usage: splice-managed-regions.ps1 <target-file> <generated-content> <language>'
    exit 0
}

if ([string]::IsNullOrEmpty($Target) -or [string]::IsNullOrEmpty($Generated) -or [string]::IsNullOrEmpty($Language)) {
    [Console]::Error.WriteLine('ERROR: usage: splice-managed-regions.ps1 <target> <generated> <language>')
    exit 1
}

if (-not (Test-Path -LiteralPath $Target -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: target file not found: $Target")
    exit 1
}
if (-not (Test-Path -LiteralPath $Generated -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: generated file not found: $Generated")
    exit 1
}

# Marker prefix per language (D-015).
switch -Regex ($Language) {
    '^(bash|sh|python|py|pwsh|powershell|ps1|yaml|yml|ruby|rb)$' { $prefix = '#' }
    '^(js|ts|javascript|typescript|c|cpp|java|go|rust)$'         { $prefix = '//' }
    '^(html|md|markdown|xml)$'                                   { $prefix = '<!--' }
    default {
        [Console]::Error.WriteLine("ERROR: unsupported language: $Language")
        exit 1
    }
}

$escapedPrefix = [regex]::Escape($prefix)
$beginRe = "^[\s]*$escapedPrefix[\s]*BEGIN MANAGED id=`"[^`"]+`""
$endRe   = "^[\s]*$escapedPrefix[\s]*END MANAGED id=`"[^`"]+`""

$generatedLines = Get-Content -LiteralPath $Generated
if ($null -eq $generatedLines) { $generatedLines = @() }
elseif ($generatedLines -isnot [array]) { $generatedLines = @($generatedLines) }

$lines = Get-Content -LiteralPath $Target
if ($null -eq $lines) { $lines = @() }
elseif ($lines -isnot [array]) { $lines = @($lines) }

$depth = 0
$lineNo = 0
$out = [System.Collections.Generic.List[string]]::new()

foreach ($line in $lines) {
    $lineNo++
    $isBegin = ($line -match $beginRe)
    $isEnd   = ($line -match $endRe)

    if ($isBegin) {
        if ($depth -gt 0) {
            [Console]::Error.WriteLine("ERROR: nested BEGIN MANAGED at line ${lineNo}: $line")
            exit 1
        }
        $depth = 1
        $out.Add($line)
        foreach ($g in $generatedLines) { $out.Add($g) }
        continue
    }
    if ($isEnd) {
        if ($depth -eq 0) {
            [Console]::Error.WriteLine("ERROR: END MANAGED without matching BEGIN at line ${lineNo}: $line")
            exit 1
        }
        $depth = 0
        $out.Add($line)
        continue
    }
    if ($depth -eq 0) { $out.Add($line) }
}

if ($depth -ne 0) {
    [Console]::Error.WriteLine('ERROR: unclosed BEGIN MANAGED region at EOF')
    exit 1
}

# Emit each line via Write-Output so the host's default newline (\n on POSIX)
# is appended — matches the bash awk `print` line-terminator behaviour.
foreach ($l in $out) { Write-Output $l }
exit 0
