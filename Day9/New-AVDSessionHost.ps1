<#
.SYNOPSIS
    Creates and registers a Windows 11 AVD session host VM joined to Microsoft Entra ID only.

.DESCRIPTION
    1. Creates a Standard_B2ms Windows 11 24H2 AVD VM with Trusted Launch (Secure Boot + vTPM).
    2. Entra ID joins it via the AADLoginForWindows extension.
     3. Verifies the VM is genuinely joined to Entra ID.
     4. Generates a host pool registration token and installs the AVD agent in Entra mode.
     5. Assigns Desktop Virtualization User and Virtual Machine User Login roles to the target user.

.PARAMETER SubnetId
    Full resource ID of the target subnet.

.PARAMETER UserPrincipalName
    UPN of the M365 user to assign AVD roles to.

.NOTES
    Requires: az CLI with desktopvirtualization extension, Owner/Contributor + User Access Administrator on the RG.
    No on-premises Active Directory is required or expected in this environment.

.EXAMPLE
    .\New-AVDSessionHost.ps1 -AdminPassword (Read-Host -AsSecureString "Admin password")
#>
param(
    [Parameter(Mandatory)]
    [SecureString]$AdminPassword,

    [string]$SubscriptionId    = "7ee5e618-6d68-45e4-8ded-436fb4b9cae2",
    [string]$ResourceGroup     = "dwp-lab-rg",
    [string]$Location          = "centralus",
    [string]$VmName            = "fin-sh-02",
    [string]$VmSize            = "Standard_B2ms",
    [string]$AdminUsername     = "avdadmin",
    [string]$HostPoolName      = "POOL-FIN-01",
    [string]$AppGroupName      = "POOL-FIN-01-DAG",
    [string]$SubnetId          = "/subscriptions/7ee5e618-6d68-45e4-8ded-436fb4b9cae2/resourceGroups/dwp-lab-rg/providers/Microsoft.Network/virtualNetworks/dwp-pUser110894-winVNET/subnets/dwp-pUser110894-winSubnet",
    [string]$UserPrincipalName = "traininguser31@zippyops.in",
    [string]$DscVersion        = "2.83",
    [int]$TokenValidityHours   = 4
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPassword))

# ── 1. Create VM ─────────────────────────────────────────────────────────────
Write-Host "==> [1/5] Creating session host VM: $VmName"
az vm create `
    --resource-group $ResourceGroup `
    --name $VmName `
    --location $Location `
    --image "MicrosoftWindowsDesktop:windows-11:win11-24h2-avd:latest" `
    --size $VmSize `
    --subnet $SubnetId `
    --security-type TrustedLaunch `
    --enable-secure-boot true `
    --enable-vtpm true `
    --assign-identity `
    --admin-username $AdminUsername `
    --admin-password $plainPassword `
    --nsg-rule None `
    --public-ip-address '""' `
    --license-type Windows_Client `
    -o json | ConvertFrom-Json | Select-Object name, privateIpAddress, powerState

# ── 2. Entra ID Join ──────────────────────────────────────────────────────────
Write-Host "==> [2/5] Installing AADLoginForWindows extension (Entra ID join)"
az vm extension set `
    --resource-group $ResourceGroup `
    --vm-name $VmName `
    --name AADLoginForWindows `
    --publisher Microsoft.Azure.ActiveDirectory `
    -o json | ConvertFrom-Json | Select-Object name, provisioningState, typeHandlerVersion

# ── 3. Verify Entra ID Join ───────────────────────────────────────────────────
Write-Host "==> [3/5] Verifying Microsoft Entra ID join"

$joinStatus = az vm run-command invoke `
    --resource-group $ResourceGroup `
    --name $VmName `
    --command-id RunPowerShellScript `
    --scripts "dsregcmd /status" `
    --query "value[0].message" -o tsv

if ($joinStatus -notmatch "AzureAdJoined\s*:\s*YES" -or
    $joinStatus -notmatch "DeviceAuthStatus\s*:\s*SUCCESS") {
    throw "The VM is not successfully joined to Microsoft Entra ID. AVD registration was not attempted."
}

# ── 4. Install AVD Agent via DSC ──────────────────────────────────────────────
Write-Host "==> [4/5] Installing AVD agent in Entra mode (DSC extension)"

$expiry  = [System.DateTime]::UtcNow.AddHours($TokenValidityHours).ToString("yyyy-MM-ddTHH:mm:ssZ")
$regToken = az desktopvirtualization hostpool update `
    --resource-group $ResourceGroup `
    --name $HostPoolName `
    --registration-info "expiration-time=$expiry" "registration-token-operation=Update" `
    --query "registrationInfo.token" -o tsv

if (-not $regToken -or $regToken.Length -lt 100) {
    throw "Failed to retrieve a valid registration token."
}

$settingsFile  = "$env:TEMP\avd-dsc-settings.json"
$protectedFile = "$env:TEMP\avd-dsc-protected.json"

@{
    modulesUrl = "https://raw.githubusercontent.com/Azure/RDS-Templates/master/ARM-wvd-templates/DSC/Configuration.zip"
    configurationFunction = "Configuration.ps1\AddSessionHost"
    properties = @{
        HostPoolName = $HostPoolName
        AadJoin = $true
    }
} | ConvertTo-Json -Depth 4 | Out-File $settingsFile -Encoding ascii -NoNewline

("{`"properties`":{`"registrationInfoToken`":`"$regToken`"}}") |
    Out-File $protectedFile -Encoding ascii -NoNewline

az vm extension set `
    --resource-group $ResourceGroup `
    --vm-name $VmName `
    --name DSC `
    --publisher Microsoft.Powershell `
    --version $DscVersion `
    --settings $settingsFile `
    --protected-settings $protectedFile `
    -o json | ConvertFrom-Json | Select-Object name, provisioningState

# ── 5. Role Assignments ────────────────────────────────────────────────────────
Write-Host "==> [5/5] Assigning roles to $UserPrincipalName"

$userId    = az ad user show --id $UserPrincipalName --query id -o tsv
$vmId      = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Compute/virtualMachines/$VmName"
$appGrpId  = "/subscriptions/$SubscriptionId/resourcegroups/$ResourceGroup/providers/Microsoft.DesktopVirtualization/applicationgroups/$AppGroupName"

az role assignment create --assignee $userId --role "Desktop Virtualization User" --scope $appGrpId -o json |
    ConvertFrom-Json | Select-Object roleDefinitionName, principalName

az role assignment create --assignee $userId --role "Virtual Machine User Login" --scope $vmId -o json |
    ConvertFrom-Json | Select-Object roleDefinitionName, principalName

Write-Host ""
Write-Host "Session host provisioning complete."
Write-Host "  VM              : $VmName"
Write-Host "  Entra ID Join   : Verified"
Write-Host "  AVD Agent       : DSC extension v$DscVersion"
Write-Host "  Roles assigned  : Desktop Virtualization User + Virtual Machine User Login"
Write-Host ""
Write-Host "Check session host health:"
Write-Host "  az rest --method get --url `"https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.DesktopVirtualization/hostPools/$HostPoolName/sessionHosts/${VmName}?api-version=2024-04-03`" --query `"{status:properties.status, lastHeartBeat:properties.lastHeartBeat}`" -o json"
