$ErrorActionPreference = 'Stop'

Stop-Service -Name RDAgentBootLoader, RdAgent -Force -ErrorAction SilentlyContinue

$uninstallRoots = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

$avdProducts = Get-ItemProperty $uninstallRoots -ErrorAction SilentlyContinue |
    Where-Object DisplayName -Match 'Remote Desktop (Agent Boot Loader|Services Infrastructure)'

foreach ($product in $avdProducts) {
    if ($product.PSChildName -match '^\{[0-9A-F-]+\}$') {
        $process = Start-Process msiexec.exe -ArgumentList '/x', $product.PSChildName, '/quiet', '/norestart' -Wait -PassThru
        if ($process.ExitCode -notin 0, 1605, 1614, 3010) {
            throw "Failed to uninstall $($product.DisplayName): exit code $($process.ExitCode)"
        }
    }
}

Remove-Item 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item 'C:\ProgramData\Microsoft\RDInfraAgent' -Recurse -Force -ErrorAction SilentlyContinue

$remaining = Get-ItemProperty $uninstallRoots -ErrorAction SilentlyContinue |
    Where-Object DisplayName -Match 'Remote Desktop (Agent Boot Loader|Services Infrastructure)' |
    Select-Object DisplayName, DisplayVersion

[pscustomobject]@{
    RegistryPresent = Test-Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent'
    RemainingProducts = @($remaining).Count
    RebootRequired = $true
} | ConvertTo-Json
