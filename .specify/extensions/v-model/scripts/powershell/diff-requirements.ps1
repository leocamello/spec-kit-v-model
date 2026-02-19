<#
.SYNOPSIS
    Detect changed/added requirements for incremental acceptance plan updates.

.DESCRIPTION
    Compares current requirements.md against its last committed version
    and outputs a list of changed/added REQ IDs.

.PARAMETER VModelDir
    Path to the v-model directory containing requirements.md.

.PARAMETER Json
    Output in JSON format.

.EXAMPLE
    ./diff-requirements.ps1 ./specs/001-feature/v-model
    ./diff-requirements.ps1 -Json ./specs/001-feature/v-model

.NOTES
    Requires git. Falls back to "all requirements changed" if no git history.
#>

[CmdletBinding()]
param(
    [switch]$Json,
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$VModelDir
)

$ErrorActionPreference = 'Stop'

$Requirements = Join-Path $VModelDir 'requirements.md'

if (-not (Test-Path $Requirements)) {
    Write-Error "ERROR: requirements.md not found in $VModelDir"
    exit 1
}

function Extract-ReqIds {
    param([string]$Content)
    $ids = [regex]::Matches($Content, 'REQ-([A-Z]+-)?[0-9]{3}') |
        ForEach-Object { $_.Value } | Sort-Object -Unique
    return @($ids)
}

function Extract-ReqLines {
    param([string[]]$Lines)
    $result = @()
    foreach ($line in $Lines) {
        if ($line -match '\|\s*REQ-([A-Z]+-)?[0-9]{3}') {
            $result += $line.Trim()
        }
    }
    return $result | Sort-Object
}

$currentContent = Get-Content -Raw $Requirements
$currentLines = Get-Content $Requirements

# Try to get the committed version of the file
$committedContent = $null
try {
    $repoRoot = (git rev-parse --show-toplevel 2>$null)
    if ($LASTEXITCODE -eq 0 -and $repoRoot) {
        $repoRoot = $repoRoot.Trim()
        $fullPath = (Resolve-Path $Requirements).Path
        $relPath = $fullPath.Substring($repoRoot.Length + 1) -replace '\\', '/'
        $committedContent = git show "HEAD:$relPath" 2>$null
        if ($LASTEXITCODE -ne 0) {
            $committedContent = $null
        }
    }
} catch {
    $committedContent = $null
}

if (-not $committedContent) {
    # No git history — treat all requirements as new
    $allReqs = Extract-ReqIds -Content $currentContent
    $changedReqs = $allReqs
    $addedReqs = $allReqs
    $removedReqs = @()
    $modifiedReqs = @()
} else {
    $oldContent = $committedContent -join "`n"
    $currentReqs = Extract-ReqIds -Content $currentContent
    $oldReqs = Extract-ReqIds -Content $oldContent

    # Find added REQs (in current but not in old)
    $addedReqs = @()
    foreach ($req in $currentReqs) {
        if ($oldReqs -notcontains $req) {
            $addedReqs += $req
        }
    }

    # Find removed REQs (in old but not in current)
    $removedReqs = @()
    foreach ($old in $oldReqs) {
        if ($currentReqs -notcontains $old) {
            $removedReqs += $old
        }
    }

    # Find modified REQs (same ID but different content)
    $modifiedReqs = @()
    $currentReqLines = Extract-ReqLines -Lines $currentLines
    $oldReqLines = Extract-ReqLines -Lines $committedContent

    foreach ($req in $currentReqs) {
        # Skip if it's a new req
        if ($addedReqs -contains $req) { continue }

        $currentLine = $currentReqLines | Where-Object { $_ -match [regex]::Escape($req) } | Select-Object -First 1
        $oldLine = $oldReqLines | Where-Object { $_ -match [regex]::Escape($req) } | Select-Object -First 1
        if ($currentLine -ne $oldLine) {
            $modifiedReqs += $req
        }
    }

    # Changed = added + modified
    $changedReqs = @($addedReqs) + @($modifiedReqs)
}

# Output
if ($Json) {
    $output = [ordered]@{
        changed       = $changedReqs
        added         = $addedReqs
        modified      = $modifiedReqs
        removed       = $removedReqs
        total_changed = $changedReqs.Count
    }
    $output | ConvertTo-Json -Compress
} else {
    Write-Output '=== Requirements Diff ==='
    Write-Output "Added: $($addedReqs.Count)"
    Write-Output "Modified: $($modifiedReqs.Count)"
    Write-Output "Removed: $($removedReqs.Count)"
    Write-Output ''
    if ($changedReqs.Count -eq 0) {
        Write-Output 'No changes detected.'
    } else {
        Write-Output 'Changed REQs (need acceptance plan update):'
        foreach ($req in $changedReqs) {
            Write-Output "  - $req"
        }
    }
    if ($removedReqs.Count -gt 0) {
        Write-Output ''
        Write-Output 'Removed REQs (orphaned ATPs may exist):'
        foreach ($req in $removedReqs) {
            Write-Output "  - $req"
        }
    }
}
