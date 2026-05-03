<#
.SYNOPSIS
    Sentinel-bounded MANAGED-region splicer (PowerShell mirror of
    splice-managed-regions.sh).

.DESCRIPTION
    Replaces `BEGIN MANAGED id="…"` / `END MANAGED id="…"` regions in
    <Target> with caller-supplied content, writing the result to STDOUT.
    The caller is responsible for the atomic mktemp + Move-Item write idiom
    (D-016, SYS-015) — this script never writes the target file directly.

    Two invocation modes (MF-5):

      1. Legacy single-payload (back-compat — byte-identical stdout vs. v0.7.0):
           splice-managed-regions.ps1 <Target> <Generated> <Language>

      2. Per-region payload:
           splice-managed-regions.ps1 -RegionFrom <RegionsFile> <Target> <Language>
         <RegionsFile> uses sentinels distinct from MANAGED:
             <<<REGION id="X">>>
             ...
             <<<END>>>

    Sentinels themselves are preserved verbatim (D-015).

    Exit codes (HAZ-025 grammar):
      0 — clean splice (or sentinel-free no-op pass-through).
      1 — file-not-found, unbalanced/orphan/nested MANAGED markers, bad CLI.
      2 — hardening violations (MF-5): id-mismatch, duplicate-id, missing
          payload, malformed regions file. Distinguishes "splicer caught
          corruption" (HAZ-007 / HAZ-014) from "could not parse the inputs".

    On every successful run that produces a non-empty diff against the
    target, a unified-diff summary is emitted on STDERR for audit-trail
    purposes. Per the bash/PowerShell parity precedent (D-009, C.2/C.3),
    STDOUT remains byte-identical between the two implementations; the
    STDERR diff format may differ across implementations.

.NOTES
    Implements: REQ-NF-006, REQ-NF-005, REQ-022,
                SYS-007, SYS-015, ARCH-010, MOD-014,
                UTP-014-A, UTP-014-B,
                HAZ-007, HAZ-008, HAZ-014, HAZ-025,
                D-009, D-005, D-015, D-016.
#>

[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AllArgs
)

$ErrorActionPreference = 'Stop'

if ($null -eq $AllArgs) { $AllArgs = @() }
$Arg0 = if ($AllArgs.Count -gt 0) { $AllArgs[0] } else { '' }
$Arg1 = if ($AllArgs.Count -gt 1) { $AllArgs[1] } else { '' }
$Arg2 = if ($AllArgs.Count -gt 2) { $AllArgs[2] } else { '' }
$Arg3 = if ($AllArgs.Count -gt 3) { $AllArgs[3] } else { '' }

if ($Arg0 -in @('--help', '-h', '-Help')) {
    Write-Output 'Usage: splice-managed-regions.ps1 <target> <generated> <language>'
    Write-Output '       splice-managed-regions.ps1 --region-from <regions> <target> <language>'
    exit 0
}

# Parse invocation mode (MF-5: --region-from is mode-2).
$RegionMode    = $false
$RegionsFile   = ''
$Target        = ''
$Generated     = ''
$Language      = ''

if ($Arg0 -eq '--region-from') {
    $RegionMode = $true
    if ([string]::IsNullOrEmpty($Arg1) -or [string]::IsNullOrEmpty($Arg2) -or [string]::IsNullOrEmpty($Arg3)) {
        [Console]::Error.WriteLine('ERROR: usage: splice-managed-regions.ps1 --region-from <regions> <target> <language>')
        exit 1
    }
    $RegionsFile = $Arg1
    $Target      = $Arg2
    $Language    = $Arg3
}
else {
    if ([string]::IsNullOrEmpty($Arg0) -or [string]::IsNullOrEmpty($Arg1) -or [string]::IsNullOrEmpty($Arg2)) {
        [Console]::Error.WriteLine('ERROR: usage: splice-managed-regions.ps1 <target> <generated> <language>')
        exit 1
    }
    $Target    = $Arg0
    $Generated = $Arg1
    $Language  = $Arg2
}

if (-not (Test-Path -LiteralPath $Target -PathType Leaf)) {
    [Console]::Error.WriteLine("ERROR: target file not found: $Target")
    exit 1
}
if ($RegionMode) {
    if (-not (Test-Path -LiteralPath $RegionsFile -PathType Leaf)) {
        [Console]::Error.WriteLine("ERROR: regions file not found: $RegionsFile")
        exit 1
    }
}
else {
    if (-not (Test-Path -LiteralPath $Generated -PathType Leaf)) {
        [Console]::Error.WriteLine("ERROR: generated file not found: $Generated")
        exit 1
    }
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
$beginRe = "^[\s]*$escapedPrefix[\s]*BEGIN MANAGED id=`"([^`"]+)`""
$endRe   = "^[\s]*$escapedPrefix[\s]*END MANAGED id=`"([^`"]+)`""

# ---------------------------------------------------------------------------
# Step 1 (region mode only): pre-parse regions file. Fail-fast BEFORE
# touching the target so the "original target untouched on error" invariant
# (HAZ-014) holds.
# ---------------------------------------------------------------------------
$regionPayloads = @{}  # id => array of lines

if ($RegionMode) {
    $regionLines = Get-Content -LiteralPath $RegionsFile
    if ($null -eq $regionLines) { $regionLines = @() }
    elseif ($regionLines -isnot [array]) { $regionLines = @($regionLines) }

    $inRegion   = $false
    $currentId  = ''
    $buffer     = [System.Collections.Generic.List[string]]::new()
    $rLine      = 0
    foreach ($line in $regionLines) {
        $rLine++
        if ($line -match '^<<<REGION id="([^"]+)">>>\s*$') {
            if ($inRegion) {
                [Console]::Error.WriteLine("ERROR: regions file: unbalanced REGION/END at line $rLine")
                exit 2
            }
            $currentId = $Matches[1]
            if ($currentId -match '[\\/]' -or $currentId.StartsWith('.')) {
                [Console]::Error.WriteLine("ERROR: regions file: unsafe id `"$currentId`" at line $rLine (must not contain '/' or '\' or start with '.')")
                exit 2
            }
            if ($regionPayloads.ContainsKey($currentId)) {
                [Console]::Error.WriteLine("ERROR: regions file: duplicate id `"$currentId`" at line $rLine")
                exit 2
            }
            $inRegion = $true
            $buffer.Clear()
            continue
        }
        if ($line -match '^<<<END>>>\s*$') {
            if (-not $inRegion) {
                [Console]::Error.WriteLine("ERROR: regions file: unbalanced REGION/END at line $rLine")
                exit 2
            }
            $regionPayloads[$currentId] = $buffer.ToArray()
            $inRegion  = $false
            $currentId = ''
            continue
        }
        if ($inRegion) { $buffer.Add($line) }
    }
    if ($inRegion) {
        [Console]::Error.WriteLine("ERROR: regions file: unbalanced REGION/END at line $rLine")
        exit 2
    }
}
else {
    $generatedLines = Get-Content -LiteralPath $Generated
    if ($null -eq $generatedLines) { $generatedLines = @() }
    elseif ($generatedLines -isnot [array]) { $generatedLines = @($generatedLines) }
}

# ---------------------------------------------------------------------------
# Step 2: splice. Single pass over target.
# ---------------------------------------------------------------------------
$lines = Get-Content -LiteralPath $Target
if ($null -eq $lines) { $lines = @() }
elseif ($lines -isnot [array]) { $lines = @($lines) }

$depth     = 0
$lineNo    = 0
$currentId = ''
$seenBegin = @{}  # id => first-line-number
$out       = [System.Collections.Generic.List[string]]::new()

foreach ($line in $lines) {
    $lineNo++

    if ($line -match $beginRe) {
        $bid = $Matches[1]
        if ($bid -match '[\\/]' -or $bid.StartsWith('.')) {
            [Console]::Error.WriteLine("ERROR: unsafe region id `"$bid`" at line ${lineNo} (must not contain '/' or '\' or start with '.')")
            exit 2
        }
        if ($depth -gt 0) {
            [Console]::Error.WriteLine("ERROR: nested BEGIN MANAGED at line ${lineNo}: $line")
            exit 1
        }
        if ($seenBegin.ContainsKey($bid)) {
            [Console]::Error.WriteLine("ERROR: duplicate region id `"$bid`" at line $lineNo (first seen at line $($seenBegin[$bid]))")
            exit 2
        }
        $seenBegin[$bid] = $lineNo
        $depth     = 1
        $currentId = $bid
        $out.Add($line)
        if ($RegionMode) {
            if (-not $regionPayloads.ContainsKey($bid)) {
                [Console]::Error.WriteLine("ERROR: no payload provided for region id `"$bid`"")
                exit 2
            }
            foreach ($p in $regionPayloads[$bid]) { $out.Add($p) }
        }
        else {
            foreach ($g in $generatedLines) { $out.Add($g) }
        }
        continue
    }

    if ($line -match $endRe) {
        $eid = $Matches[1]
        if ($depth -eq 0) {
            [Console]::Error.WriteLine("ERROR: END MANAGED without matching BEGIN at line ${lineNo}: $line")
            exit 1
        }
        if ($eid -ne $currentId) {
            [Console]::Error.WriteLine("ERROR: id mismatch at line ${lineNo}: BEGIN id=`"$currentId`" closed by END id=`"$eid`"")
            exit 2
        }
        $depth     = 0
        $currentId = ''
        $out.Add($line)
        continue
    }

    if ($depth -eq 0) { $out.Add($line) }
}

if ($depth -ne 0) {
    [Console]::Error.WriteLine('ERROR: unclosed BEGIN MANAGED region at EOF')
    exit 1
}

# ---------------------------------------------------------------------------
# Step 3: emit a unified-style diff summary on stderr (audit trail) when the
# spliced output differs from the target. Pure-PowerShell implementation via
# Compare-Object, formatted as a `--- a/<target>` / `+++ b/<target>` header
# plus a `-` / `+` line stream. Per D-009 + C.2/C.3 precedent, only STDOUT
# byte-equality is contractual across implementations; STDERR diff format
# may differ from the bash `diff -u` output.
# ---------------------------------------------------------------------------
$outArr = $out.ToArray()
$diffPresent = $false
if ($outArr.Length -ne $lines.Length) {
    $diffPresent = $true
}
else {
    for ($i = 0; $i -lt $outArr.Length; $i++) {
        if ($outArr[$i] -ne $lines[$i]) { $diffPresent = $true; break }
    }
}

if ($diffPresent) {
    [Console]::Error.WriteLine("--- a/$Target")
    [Console]::Error.WriteLine("+++ b/$Target")
    $cmp = Compare-Object -ReferenceObject $lines -DifferenceObject $outArr -SyncWindow 0
    foreach ($d in $cmp) {
        if ($d.SideIndicator -eq '<=') {
            [Console]::Error.WriteLine("-$($d.InputObject)")
        }
        elseif ($d.SideIndicator -eq '=>') {
            [Console]::Error.WriteLine("+$($d.InputObject)")
        }
    }
}

foreach ($l in $outArr) { Write-Output $l }
exit 0
