# Remove-TempFiles.ps1

A safe, DWP-friendly PowerShell 5.1 script for cleaning up temporary files on a Windows endpoint. Instead of permanently deleting files, it moves ("quarantines") them into a dated folder with a manifest, so a run can be rolled back if something was removed by mistake.

## How it works

1. **Discovery** – Recursively scans the target folder(s) for files whose `LastWriteTime` is older than the cutoff (`-DaysOld`).
2. **Dry run (optional)** – Lists every candidate file and exits without changing anything.
3. **Cleanup** – Moves each candidate file into `Quarantine\<runId>\...` (preserving its original path) and records an `OriginalPath` / `QuarantinePath` pair in a manifest CSV.
4. **Rollback (optional)** – Reads a manifest CSV and moves the files back to their original locations.
5. **Logging & summary** – Every action is written to a timestamped log file under `Logs\`, and a summary (candidates, succeeded, skipped-locked, skipped-other, failed, bytes processed) is printed at the end of every run.

Because removed files are quarantined rather than deleted, and every step checks whether a file already exists / was already processed, the script can safely be re-run (idempotent) and undone (rollback).

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `-Path` | `string[]` | `$env:TEMP`, `$env:WINDIR\Temp` | One or more folders to clean up. |
| `-DaysOld` | `int` (0–3650) | `0` | Only files with `LastWriteTime` older than this many days are targeted. `0` means all files regardless of age. |
| `-DryRun` | `switch` | off | Reports the files that would be removed. No files are moved and no manifest is created. |
| `-Rollback` | `switch` | off | Restores files from a prior quarantine run instead of cleaning up. |
| `-RollbackManifest` | `string` | *(most recent manifest)* | Path to a specific `manifest_*.csv` to restore from. Only used with `-Rollback`. |
| `-LogRoot` | `string` | `Day3\Logs` | Folder where date/time-stamped log files are written (created if missing). |
| `-QuarantineRoot` | `string` | `Day3\Quarantine` | Folder where removed files and manifests are stored (created if missing). |

## Examples

```powershell
# Preview what would be cleaned up from the default temp locations
.\Remove-TempFiles.ps1 -DryRun

# Remove (quarantine) files older than 7 days from the default locations
.\Remove-TempFiles.ps1 -DaysOld 7

# Clean up a custom folder
.\Remove-TempFiles.ps1 -Path 'C:\Temp\AppCache' -DaysOld 3

# Undo the most recent cleanup run
.\Remove-TempFiles.ps1 -Rollback

# Undo a specific run using its manifest
.\Remove-TempFiles.ps1 -Rollback -RollbackManifest '.\Quarantine\manifest_20260807_101500.csv'
```

## Safety features

- **Locked files** are caught (`System.IO.IOException`) and skipped/logged, never stop the run.
- **Per-file try/catch** ensures one bad file doesn't abort the whole cleanup.
- **Manifest-based rollback** means files aren't permanently lost until you choose to purge the `Quarantine` folder yourself.
- **Idempotent**: re-running dry run, cleanup, or rollback simply skips files that are missing/already handled instead of erroring out.
- The script never targets its own `Logs` or `Quarantine` folders.

## Output

- **Log files**: `Logs\TempCleanup_<yyyyMMdd_HHmmss>.log` — every action plus the final summary.
- **Manifest files**: `Quarantine\manifest_<runId>.csv` — `OriginalPath`, `QuarantinePath`, `SizeBytes`, `RemovedOn` for each quarantined file, used for rollback.
