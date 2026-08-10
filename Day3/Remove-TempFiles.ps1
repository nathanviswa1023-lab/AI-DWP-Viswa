<#
.SYNOPSIS
    Safely cleans up temporary files on a Windows endpoint (DWP triage tool).

.DESCRIPTION
    Scans one or more target folders (default: user %TEMP% and %WINDIR%\Temp)
    for files older than a configurable age and removes them by moving them
    into a dated quarantine folder (a "soft delete"). A manifest of every
    moved file is recorded so the operation can be rolled back later.

    Key safety features:
      - Dry run mode (-DryRun) reports what WOULD be removed, no changes made.
      - Locked/in-use files are skipped, logged, and do not stop the script.
      - Every file operation is wrapped in its own try/catch.
      - Every action is written to a date/time-stamped log file.
      - A summary is printed/logged at the end of every run.
      - Rollback mode (-Rollback) restores files from the quarantine manifest.
      - Re-running the script (dry run, cleanup, or rollback) is idempotent -
        files that were already removed/restored are simply skipped, not
        treated as errors.

.PARAMETER Path
    One or more folders to clean. Defaults to %TEMP% and %WINDIR%\Temp.

.PARAMETER DaysOld
    Only files whose LastWriteTime is older than this many days are targeted.
    Default is 0 (i.e. all files, regardless of age, are eligible).

.PARAMETER DryRun
    When specified, only reports the files that would be removed. No files
    are moved or deleted and no manifest is created.

.PARAMETER Rollback
    When specified, restores files from a prior quarantine run instead of
    cleaning up. Use with -RollbackManifest to pick a specific run, otherwise
    the most recent manifest is used.

.PARAMETER RollbackManifest
    Path to a specific manifest CSV (created by a previous cleanup run) to
    restore from. Only used when -Rollback is specified.

.PARAMETER LogRoot
    Folder where date/time-stamped log files are written. Created if missing.

.PARAMETER QuarantineRoot
    Folder where removed files are moved to (instead of being permanently
    deleted), grouped into per-run subfolders. Created if missing.

.EXAMPLE
    .\Remove-TempFiles.ps1 -DryRun
    Shows what would be cleaned up from the default temp locations.

.EXAMPLE
    .\Remove-TempFiles.ps1 -DaysOld 7
    Removes (quarantines) files older than 7 days from the default locations.

.EXAMPLE
    .\Remove-TempFiles.ps1 -Rollback
    Restores files from the most recent quarantine run.

.NOTES
    PowerShell 5.1 compatible.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string[]] $Path = @($env:TEMP, (Join-Path $env:WINDIR 'Temp')),

    [Parameter()]
    [ValidateRange(0, 3650)]
    [int] $DaysOld = 0,

    [Parameter()]
    [switch] $DryRun,

    [Parameter()]
    [switch] $Rollback,

    [Parameter()]
    [string] $RollbackManifest,

    [Parameter()]
    [string] $LogRoot = (Join-Path $PSScriptRoot 'Logs'),

    [Parameter()]
    [string] $QuarantineRoot = (Join-Path $PSScriptRoot 'Quarantine')
)

#region 1. Initialization
# Sets up a unique run ID, ensures the log/quarantine folders exist, and
# builds the date/time-stamped log file path used for the rest of the run.
$runId = Get-Date -Format 'yyyyMMdd_HHmmss'

if (-not (Test-Path -LiteralPath $LogRoot)) {
    New-Item -Path $LogRoot -ItemType Directory -Force | Out-Null
}
if (-not (Test-Path -LiteralPath $QuarantineRoot)) {
    New-Item -Path $QuarantineRoot -ItemType Directory -Force | Out-Null
}

$script:LogFile = Join-Path $LogRoot ("TempCleanup_{0}.log" -f $runId)
New-Item -Path $script:LogFile -ItemType File -Force | Out-Null

# Running totals used to build the end-of-run summary report.
$script:Summary = [ordered]@{
    Mode           = if ($Rollback) { 'Rollback' } elseif ($DryRun) { 'DryRun' } else { 'Cleanup' }
    Candidates     = 0
    Succeeded      = 0
    SkippedLocked  = 0
    SkippedOther   = 0
    Failed         = 0
    BytesProcessed = 0
}
#endregion

#region 2. Logging helper
# Writes a single timestamped line to both the console and the log file.
# Centralizing logging here means every other section only needs one call.
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message,

        [ValidateSet('INFO', 'WARN', 'ERROR', 'SUCCESS')]
        [string] $Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$timestamp] [$Level] $Message"

    Add-Content -Path $script:LogFile -Value $line -Encoding UTF8

    switch ($Level) {
        'ERROR'   { Write-Host $line -ForegroundColor Red }
        'WARN'    { Write-Host $line -ForegroundColor Yellow }
        'SUCCESS' { Write-Host $line -ForegroundColor Green }
        default   { Write-Host $line }
    }
}
#endregion

#region 3. Summary report helper
# Prints/logs the running totals in a consistent format. Called once at the
# end of every mode (dry run, cleanup, rollback).
function Write-SummaryReport {
    Write-Log '----- Summary Report -----'
    foreach ($key in $script:Summary.Keys) {
        $value = $script:Summary[$key]
        if ($key -eq 'BytesProcessed') {
            $value = '{0:N2} MB' -f ($value / 1MB)
        }
        Write-Log ("{0}: {1}" -f $key, $value)
    }
    Write-Log '---------------------------'
}
#endregion

#region 4. Rollback mode
# Restores files from a previous quarantine run using its manifest CSV.
# Idempotent: if a file was already restored (or the quarantine copy is
# missing) it is logged and skipped rather than treated as a fatal error.
function Invoke-Rollback {
    param([string] $ManifestPath)

    if (-not $ManifestPath) {
        # No manifest specified - pick the most recently created one.
        $latest = Get-ChildItem -Path $QuarantineRoot -Filter 'manifest_*.csv' -File -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if (-not $latest) {
            Write-Log "No manifest files found under '$QuarantineRoot'. Nothing to roll back." -Level WARN
            return
        }
        $ManifestPath = $latest.FullName
    }

    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        Write-Log "Manifest file not found: $ManifestPath" -Level ERROR
        return
    }

    Write-Log "Rolling back using manifest: $ManifestPath"
    # Force an array so a single-row CSV doesn't collapse into a scalar object.
    $entries = @(Import-Csv -Path $ManifestPath)
    $script:Summary.Candidates = $entries.Count

    foreach ($entry in $entries) {
        try {
            if (-not (Test-Path -LiteralPath $entry.QuarantinePath)) {
                # Already restored (or purged) on a previous run - safe to skip.
                Write-Log "Skip (no quarantine copy, already restored?): $($entry.OriginalPath)" -Level WARN
                $script:Summary.SkippedOther++
                continue
            }

            if (Test-Path -LiteralPath $entry.OriginalPath) {
                # Original path already has a file again - do not overwrite.
                Write-Log "Skip (original path already exists): $($entry.OriginalPath)" -Level WARN
                $script:Summary.SkippedOther++
                continue
            }

            $originalFolder = Split-Path -Path $entry.OriginalPath -Parent
            if (-not (Test-Path -LiteralPath $originalFolder)) {
                New-Item -Path $originalFolder -ItemType Directory -Force | Out-Null
            }

            Move-Item -LiteralPath $entry.QuarantinePath -Destination $entry.OriginalPath -Force -ErrorAction Stop
            Write-Log "Restored: $($entry.OriginalPath)" -Level SUCCESS
            $script:Summary.Succeeded++
            $script:Summary.BytesProcessed += [int64]$entry.SizeBytes
        }
        catch {
            Write-Log "Failed to restore '$($entry.OriginalPath)': $($_.Exception.Message)" -Level ERROR
            $script:Summary.Failed++
        }
    }

    Write-SummaryReport
}

if ($Rollback) {
    Invoke-Rollback -ManifestPath $RollbackManifest
    return
}
#endregion

#region 5. Candidate file discovery
# Builds the list of files eligible for cleanup: must exist under one of the
# target -Path folders, be older than -DaysOld, and not live inside our own
# Log/Quarantine folders (so the script never targets its own artifacts).
$cutoffDate = (Get-Date).AddDays(-$DaysOld)
Write-Log "Starting run '$runId' (Mode: $($script:Summary.Mode), DaysOld: $DaysOld, Cutoff: $cutoffDate)"

$candidateFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]

foreach ($folder in $Path) {
    if (-not (Test-Path -LiteralPath $folder)) {
        Write-Log "Target path does not exist, skipping: $folder" -Level WARN
        continue
    }

    try {
        $files = Get-ChildItem -LiteralPath $folder -Recurse -File -Force -ErrorAction SilentlyContinue |
            Where-Object {
                $_.LastWriteTime -le $cutoffDate -and
                $_.FullName -notlike "$LogRoot*" -and
                $_.FullName -notlike "$QuarantineRoot*"
            }
        foreach ($file in $files) { $candidateFiles.Add($file) }
    }
    catch {
        Write-Log "Failed to enumerate folder '$folder': $($_.Exception.Message)" -Level ERROR
    }
}

$script:Summary.Candidates = $candidateFiles.Count
Write-Log "Found $($candidateFiles.Count) candidate file(s) older than $DaysOld day(s)."
#endregion

#region 6. Dry run reporting
# Dry run makes NO changes - it only lists what would be removed and exits.
if ($DryRun) {
    Write-Log '----- DRY RUN: files that WOULD be removed -----'
    foreach ($file in $candidateFiles) {
        Write-Log ("Would remove: {0} (LastWriteTime: {1}, Size: {2:N0} bytes)" -f $file.FullName, $file.LastWriteTime, $file.Length)
        $script:Summary.BytesProcessed += $file.Length
    }
    $script:Summary.Succeeded = $candidateFiles.Count
    Write-SummaryReport
    Write-Log "Dry run complete. No files were modified."
    return
}
#endregion

#region 7. Cleanup (quarantine + manifest) mode
# Moves each candidate file into a per-run quarantine folder rather than
# permanently deleting it, and records the original/quarantine path pair in
# a manifest CSV so the run can be rolled back later. Each file is handled
# in its own try/catch so one failure (e.g. a locked file) never stops the
# rest of the run.
$runQuarantineFolder = Join-Path $QuarantineRoot $runId
New-Item -Path $runQuarantineFolder -ItemType Directory -Force | Out-Null
$manifestPath = Join-Path $QuarantineRoot ("manifest_{0}.csv" -f $runId)
$manifestRows = New-Object System.Collections.Generic.List[object]

foreach ($file in $candidateFiles) {
    try {
        if (-not (Test-Path -LiteralPath $file.FullName)) {
            # Already removed by a prior/parallel run - idempotent no-op.
            Write-Log "Skip (no longer present): $($file.FullName)" -Level WARN
            $script:Summary.SkippedOther++
            continue
        }

        # Preserve the original folder structure under the quarantine root so
        # restores are unambiguous, e.g. C:\Users\...\Temp\a.tmp ->
        # Quarantine\<runId>\C\Users\...\Temp\a.tmp
        $driveLetter = ($file.PSDrive.Name)
        $relativePath = $file.FullName.Substring($file.PSDrive.Root.Length)
        $destination = Join-Path (Join-Path $runQuarantineFolder $driveLetter) $relativePath
        $destinationFolder = Split-Path -Path $destination -Parent

        if (-not (Test-Path -LiteralPath $destinationFolder)) {
            New-Item -Path $destinationFolder -ItemType Directory -Force | Out-Null
        }

        Move-Item -LiteralPath $file.FullName -Destination $destination -Force -ErrorAction Stop

        $manifestRows.Add([pscustomobject]@{
            OriginalPath   = $file.FullName
            QuarantinePath = $destination
            SizeBytes      = $file.Length
            RemovedOn      = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        })

        Write-Log "Removed: $($file.FullName)" -Level SUCCESS
        $script:Summary.Succeeded++
        $script:Summary.BytesProcessed += $file.Length
    }
    catch [System.IO.IOException] {
        # Covers files locked/in-use by another process - skip, don't stop.
        Write-Log "Skipped (locked/in use): $($file.FullName) - $($_.Exception.Message)" -Level WARN
        $script:Summary.SkippedLocked++
    }
    catch {
        Write-Log "Failed to remove '$($file.FullName)': $($_.Exception.Message)" -Level ERROR
        $script:Summary.Failed++
    }
}

if ($manifestRows.Count -gt 0) {
    $manifestRows | Export-Csv -Path $manifestPath -NoTypeInformation -Encoding UTF8
    Write-Log "Manifest written: $manifestPath (use -Rollback -RollbackManifest '$manifestPath' to undo)"
}
else {
    # Nothing was moved, so remove the empty per-run quarantine folder to
    # keep re-runs idempotent and avoid leaving clutter behind.
    Remove-Item -Path $runQuarantineFolder -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "No files were removed; no manifest created."
}
#endregion

#region 8. Final summary
Write-SummaryReport
Write-Log "Run '$runId' complete."
#endregion
