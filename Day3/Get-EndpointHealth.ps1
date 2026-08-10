<#
.SYNOPSIS
    Endpoint health report for DWP triage (read-only).

.DESCRIPTION
    Collects and displays:
      1. System uptime
      2. Free disk space
      3. Pending reboot status (registry check)
      4. Top 5 processes by memory (working set)
      5. Top 5 processes by CPU
      6. Last 5 System log errors

    This script is STRICTLY READ-ONLY. It only uses Get-/Test- cmdlets and
    Write-Host/Write-Output for reporting. It does not create, modify, delete,
    stop, or start anything on the system.

.NOTES
    PowerShell 5.1 compatible.
    Lines that should be verified/adjusted for your environment before running
    are marked with "# VERIFY:" comments.
#>

# VERIFY: Run in a standard (non-admin) PowerShell 5.1 console unless your org
# requires elevation to read the registry/event log locations used below.

Write-Host "===== Endpoint Health Report =====" -ForegroundColor Cyan
Write-Host "Generated: $(Get-Date)" -ForegroundColor Cyan
Write-Host ""

#region 1. System Uptime
# Reads OS boot time from CIM (WMI) and calculates elapsed time since boot.
# Read-only: Get-CimInstance only queries data, no changes are made.
Write-Host "----- 1. System Uptime -----" -ForegroundColor Yellow
try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
    $lastBoot = $os.LastBootUpTime
    $uptime = (Get-Date) - $lastBoot
    Write-Host "Last Boot Time : $lastBoot"
    Write-Host ("Uptime         : {0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes)
}
catch {
    Write-Warning "Unable to retrieve uptime: $($_.Exception.Message)"
}
Write-Host ""
#endregion

#region 2. Free Disk Space
# Reads free/total space per fixed local drive via CIM (DriveType 3 = local disk).
# Read-only: Get-CimInstance only queries data, no changes are made.
Write-Host "----- 2. Free Disk Space -----" -ForegroundColor Yellow
try {
    $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop
    foreach ($disk in $disks) {
        $freeGB  = [math]::Round($disk.FreeSpace / 1GB, 2)
        $totalGB = [math]::Round($disk.Size / 1GB, 2)
        $pctFree = if ($disk.Size) { [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 1) } else { 0 }
        Write-Host ("Drive {0}  Free: {1} GB / {2} GB  ({3}% free)" -f $disk.DeviceID, $freeGB, $totalGB, $pctFree)
    }
}
catch {
    Write-Warning "Unable to retrieve disk space: $($_.Exception.Message)"
}
Write-Host ""
#endregion

#region 3. Pending Reboot Check (Registry)
# Checks well-known registry locations that Windows/WSUS use to flag a pending
# reboot. This only READS registry values (Test-Path / Get-ItemProperty) and
# makes no changes.
Write-Host "----- 3. Pending Reboot Check -----" -ForegroundColor Yellow

# VERIFY: These are the standard indicators used by Microsoft/WSUS, but some
# third-party patching tools use additional/custom keys — confirm with your
# environment's patching solution if you need full coverage.
$rebootPending = $false
$reasons = @()

# Component-Based Servicing
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") {
    $rebootPending = $true
    $reasons += "Component Based Servicing\RebootPending"
}

# Windows Update - Auto Update
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") {
    $rebootPending = $true
    $reasons += "WindowsUpdate\Auto Update\RebootRequired"
}

# Pending File Rename Operations (in-use file replacement queued for next boot)
$pfroPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager"
$pfro = Get-ItemProperty -Path $pfroPath -Name "PendingFileRenameOperations" -ErrorAction SilentlyContinue
if ($pfro -and $pfro.PendingFileRenameOperations) {
    $rebootPending = $true
    $reasons += "PendingFileRenameOperations"
}

if ($rebootPending) {
    Write-Host "Reboot Pending : YES" -ForegroundColor Red
    Write-Host ("Reason(s)      : {0}" -f ($reasons -join ", "))
}
else {
    Write-Host "Reboot Pending : NO" -ForegroundColor Green
}
Write-Host ""
#endregion

#region 4. Top 5 Processes by Memory (Working Set)
# Reads current process list and sorts by working set (physical memory in use).
# Read-only: Get-Process only queries data, no changes are made.
Write-Host "----- 4. Top 5 Processes by Memory (Working Set) -----" -ForegroundColor Yellow
try {
    Get-Process -ErrorAction Stop |
        Sort-Object WS -Descending |
        Select-Object -First 5 -Property Name, Id, @{N='WS(MB)'; E={[math]::Round($_.WS / 1MB, 2)}} |
        Format-Table -AutoSize | Out-String | Write-Host
}
catch {
    Write-Warning "Unable to retrieve process memory info: $($_.Exception.Message)"
}
#endregion

#region 5. Top 5 Processes by CPU
# Reads current process list and sorts by cumulative CPU time (seconds).
# VERIFY: Get-Process's CPU property is TOTAL processor time consumed since
# the process started (in seconds), not a live/instant CPU percentage. Long-
# running processes will naturally show higher totals. If you need real-time
# CPU %, use Get-Counter with a performance counter sample instead — that is
# NOT what this section does.
Write-Host "----- 5. Top 5 Processes by CPU (total seconds) -----" -ForegroundColor Yellow
try {
    Get-Process -ErrorAction Stop |
        Where-Object { $_.CPU -ne $null } |
        Sort-Object CPU -Descending |
        Select-Object -First 5 -Property Name, Id, @{N='CPU(s)'; E={[math]::Round($_.CPU, 2)}} |
        Format-Table -AutoSize | Out-String | Write-Host
}
catch {
    Write-Warning "Unable to retrieve process CPU info: $($_.Exception.Message)"
}
#endregion

#region 6. Last 5 System Log Errors
# Reads the last 5 Error-level entries from the System event log.
# Read-only: Get-WinEvent only queries the event log, no changes are made.
# VERIFY: Reading the System log usually requires no special rights for
# standard users, but some environments restrict Event Log access via GPO —
# confirm you have permission if this section returns an access-denied error.
Write-Host "----- 6. Last 5 System Log Errors -----" -ForegroundColor Yellow
try {
    $errors = Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 2 } -MaxEvents 5 -ErrorAction Stop
    $errors | Select-Object TimeCreated, Id, ProviderName, Message |
        Format-List | Out-String | Write-Host
}
catch [Exception] {
    if ($_.Exception -is [System.Exception] -and $_.Exception.Message -match 'No events were found') {
        Write-Host "No matching error events found in the System log."
    }
    else {
        Write-Warning "Unable to retrieve System log errors: $($_.Exception.Message)"
    }
}
Write-Host ""
#endregion

Write-Host "===== End of Report =====" -ForegroundColor Cyan
