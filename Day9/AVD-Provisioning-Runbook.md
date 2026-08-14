# Azure Virtual Desktop – End-to-End Provisioning Runbook
## DWP Win11 Workplace Migration – FinBridge Environment

**Date:** 2026-08-13  
**Engineer:** traininguser31@zippyops.in  
**Subscription:** 7ee5e618-6d68-45e4-8ded-436fb4b9cae2 (labs31)  
**Resource Group:** dwp-lab-rg  
**Region:** Central US  
**M365 Tenant:** zippyops.in

---

## 1. Pre-flight Checks

### 1.1 Verify CLI Authentication

```powershell
az account show --query "{subscriptionId:id, name:name, tenantId:tenantId, user:user}" -o json
```

**Result:** Authenticated as `traininguser31@zippyops.in`, subscription `labs31`.

### 1.2 Confirm Role Permissions

```powershell
az role assignment list `
  --assignee traininguser31@zippyops.in `
  --subscription 7ee5e618-6d68-45e4-8ded-436fb4b9cae2 `
  --include-inherited `
  --query "[].{role:roleDefinitionName, scope:scope}" -o table
```

**Result:** `Owner` at subscription scope — full permissions including role assignments.

### 1.3 Confirm Existing Network

```powershell
az network vnet list --resource-group dwp-lab-rg `
  --query "[].{name:name, subnets:subnets[].{name:name, prefix:addressPrefix}}" -o json
```

**Result:** Existing VNet `dwp-pUser110894-winVNET` (10.0.0.0/16) with subnet `dwp-pUser110894-winSubnet` (10.0.0.0/24) reused — no new VNet required.

---

## 2. AVD Control Plane

### 2.1 Install the CLI Extension (first run only)

The `desktopvirtualization` CLI extension is installed on first use:

```powershell
az config set extension.use_dynamic_install=yes_without_prompt
```

### 2.2 Create Host Pool

```powershell
az desktopvirtualization hostpool create `
  --resource-group dwp-lab-rg `
  --name POOL-FIN-01 `
  --location centralus `
  --host-pool-type Pooled `
  --load-balancer-type BreadthFirst `
  --max-session-limit 5 `
  --preferred-app-group-type Desktop `
  -o json
```

| Setting | Value |
|---|---|
| Name | POOL-FIN-01 |
| Type | Pooled |
| Load Balancing | BreadthFirst |
| Max Sessions/Host | 5 |
| Object ID | 56ad43b4-e99c-4b68-8e9a-05941f89e948 |

### 2.3 Create Desktop Application Group

```powershell
az desktopvirtualization applicationgroup create `
  --resource-group dwp-lab-rg `
  --name POOL-FIN-01-DAG `
  --location centralus `
  --application-group-type Desktop `
  --host-pool-arm-path "/subscriptions/7ee5e618-6d68-45e4-8ded-436fb4b9cae2/resourcegroups/dwp-lab-rg/providers/Microsoft.DesktopVirtualization/hostpools/POOL-FIN-01" `
  -o json
```

### 2.4 Create Workspace and Register App Group

```powershell
az desktopvirtualization workspace create `
  --resource-group dwp-lab-rg `
  --name FinBridge-Workspace `
  --location centralus `
  --application-group-references "/subscriptions/7ee5e618-6d68-45e4-8ded-436fb4b9cae2/resourcegroups/dwp-lab-rg/providers/Microsoft.DesktopVirtualization/applicationgroups/POOL-FIN-01-DAG" `
  -o json
```

**Result:** `FinBridge-Workspace` created with `POOL-FIN-01-DAG` registered.

---

## 3. Session Host VM

### 3.1 Image Selection

Windows 11 24H2 AVD multi-session (AVD-optimised image):

```
Publisher : MicrosoftWindowsDesktop
Offer     : windows-11
SKU       : win11-24h2-avd
Version   : latest (26100.9168.260809 at time of deployment)
```

### 3.2 Create VM

```powershell
az vm create `
  --resource-group dwp-lab-rg `
  --name fin-sh-02 `
  --location centralus `
  --image MicrosoftWindowsDesktop:windows-11:win11-24h2-avd:latest `
  --size Standard_B2ms `
  --subnet /subscriptions/7ee5e618-6d68-45e4-8ded-436fb4b9cae2/resourceGroups/dwp-lab-rg/providers/Microsoft.Network/virtualNetworks/dwp-pUser110894-winVNET/subnets/dwp-pUser110894-winSubnet `
  --security-type TrustedLaunch `
  --enable-secure-boot true `
  --enable-vtpm true `
  --assign-identity `
  --admin-username avdadmin `
  --admin-password "<SecurePassword>" `
  --nsg-rule None `
  --public-ip-address '""' `
  --license-type Windows_Client `
  -o json
```

| Setting | Value |
|---|---|
| Name | fin-sh-02 (validated replacement) |
| Size | Standard_B2ms |
| OS | Windows 11 24H2 AVD multi-session |
| Security | Trusted Launch (Secure Boot + vTPM) |
| Network | Private IP 10.0.0.8, no public IP |
| License | Windows_Client (Hybrid Benefit) |

### 3.3 Entra ID Join (Microsoft Entra ID Only — no on-premises AD)

Install the `AADLoginForWindows` extension. This joins the VM to Entra ID and enables Entra ID-based interactive login:

```powershell
az vm extension set `
  --resource-group dwp-lab-rg `
  --vm-name fin-sh-02 `
  --name AADLoginForWindows `
  --publisher Microsoft.Azure.ActiveDirectory `
  -o json
```

**Result:** `provisioningState: Succeeded`, version 2.2

Do not rely on extension status alone. Verify the device registration before installing the AVD agent:

```powershell
az vm run-command invoke --resource-group dwp-lab-rg --name fin-sh-02 `
  --command-id RunPowerShellScript --scripts "dsregcmd /status" `
  --query "value[0].message" -o tsv
```

Required results: `AzureAdJoined : YES` and `DeviceAuthStatus : SUCCESS`.

> **Note:** Do not install `JsonADDomainExtension` in Entra ID-only environments — there is no on-premises domain to join.

### 3.4 Generate Host Pool Registration Token

The token must be generated **before** installing the DSC extension. It is valid for a configurable duration (4 hours used here):

```powershell
$expiry = [System.DateTime]::UtcNow.AddHours(4).ToString("yyyy-MM-ddTHH:mm:ssZ")
$regToken = az desktopvirtualization hostpool update `
  --resource-group dwp-lab-rg `
  --name POOL-FIN-01 `
  --registration-info "expiration-time=$expiry" "registration-token-operation=Update" `
  --query "registrationInfo.token" -o tsv
```

> **Security note:** The token is a JWT bearer token. Store it only in protected settings (never in public extension settings). It expires and cannot be retrieved from the host pool after creation — regenerate if needed.

### 3.5 Prepare DSC Settings Files

The `Microsoft.Powershell/DSC` extension installs the AVD agent (`RDAgent`) and registers the session host with the host pool.

Use the current Microsoft `Azure/RDS-Templates` package. Its `AddSessionHost` configuration supports Entra-only registration through `AadJoin=true`.

**Public settings** (`dsc-settings.json`):

```json
{
  "modulesUrl": "https://raw.githubusercontent.com/Azure/RDS-Templates/master/ARM-wvd-templates/DSC/Configuration.zip",
  "configurationFunction": "Configuration.ps1\\AddSessionHost",
  "properties": {
    "HostPoolName": "POOL-FIN-01",
    "AadJoin": true
  }
}
```

**Protected settings** (`dsc-protected.json`) — token stored encrypted:

```json
{
  "properties": {
    "registrationInfoToken": "<generated token>"
  }
}
```

Write both to temp files:

```powershell
$exp = [System.DateTime]::UtcNow.AddHours(4).ToString("yyyy-MM-ddTHH:mm:ssZ")
$tok = az desktopvirtualization hostpool update --resource-group dwp-lab-rg --name POOL-FIN-01 `
  --registration-info "expiration-time=$exp" "registration-token-operation=Update" `
  --query "registrationInfo.token" -o tsv

@{modulesUrl="https://raw.githubusercontent.com/Azure/RDS-Templates/master/ARM-wvd-templates/DSC/Configuration.zip"; configurationFunction="Configuration.ps1\AddSessionHost"; properties=@{HostPoolName="POOL-FIN-01"; AadJoin=$true}} |
  ConvertTo-Json -Depth 4 | Out-File "$env:TEMP\dsc-settings.json" -Encoding ascii -NoNewline

"{`"properties`":{`"registrationInfoToken`":`"$tok`"}}" |
  Out-File "$env:TEMP\dsc-protected.json" -Encoding ascii -NoNewline
```

### 3.6 Install AVD Agent via DSC Extension

```powershell
az vm extension set `
  --resource-group dwp-lab-rg `
  --vm-name fin-sh-02 `
  --name DSC `
  --publisher Microsoft.Powershell `
  --version 2.83 `
  --settings "$env:TEMP\dsc-settings.json" `
  --protected-settings "$env:TEMP\dsc-protected.json" `
  -o json
```

**Result:** `provisioningState: Succeeded`

### 3.7 Configure Host Pool RDP Properties

For Entra-joined session hosts, preserve the existing RDP properties and include `targetisaadjoined:i:1;`. This allows supported clients that are not joined or registered to the same tenant to connect.

---

## 4. Role Assignments

Both roles are assigned to `traininguser31@zippyops.in` (Object ID: `51a2d234-cf0c-47f8-8aa3-83ef45117fcb`).

### 4.1 Desktop Virtualization User (AVD client access)

Scope: the Desktop Application Group — grants the user the right to connect to the published desktop via the AVD web client or Windows app.

```powershell
az role assignment create `
  --assignee 51a2d234-cf0c-47f8-8aa3-83ef45117fcb `
  --role "Desktop Virtualization User" `
  --scope "/subscriptions/7ee5e618-6d68-45e4-8ded-436fb4b9cae2/resourcegroups/dwp-lab-rg/providers/Microsoft.DesktopVirtualization/applicationgroups/POOL-FIN-01-DAG"
```

### 4.2 Virtual Machine User Login (direct RDP access)

Scope: the session host VM — grants the user the right to sign into the VM with their Entra ID credentials via RDP.

```powershell
az role assignment create `
  --assignee 51a2d234-cf0c-47f8-8aa3-83ef45117fcb `
  --role "Virtual Machine User Login" `
  --scope "/subscriptions/7ee5e618-6d68-45e4-8ded-436fb4b9cae2/resourceGroups/dwp-lab-rg/providers/Microsoft.Compute/virtualMachines/fin-sh-02"
```

---

## 5. Health Verification

### 5.1 Query Session Host Status

```powershell
az rest --method get `
  --url "https://management.azure.com/subscriptions/7ee5e618-6d68-45e4-8ded-436fb4b9cae2/resourceGroups/dwp-lab-rg/providers/Microsoft.DesktopVirtualization/hostPools/POOL-FIN-01/sessionHosts/fin-sh-02?api-version=2024-04-03" `
  --query "{status:properties.status, lastHeartBeat:properties.lastHeartBeat, agentVersion:properties.agentVersion, updateState:properties.updateState}" -o json
```

### 5.2 Detailed Health Check Results

```powershell
az rest --method get `
  --url "https://management.azure.com/subscriptions/7ee5e618-6d68-45e4-8ded-436fb4b9cae2/resourceGroups/dwp-lab-rg/providers/Microsoft.DesktopVirtualization/hostPools/POOL-FIN-01/sessionHosts/fin-sh-02?api-version=2024-04-03" `
  --query "properties.sessionHostHealthCheckResults[].{check:healthCheckName, result:healthCheckResult, message:additionalFailureDetails.message}" -o table
```

### 5.3 Health Check Observations (Entra ID-Only Environment)

| Health Check | Expected Result | Notes |
|---|---|---|
| `SxSStackListenerCheck` | Succeeded | RDP stack running |
| `UrlsAccessibleCheck` | Succeeded | AVD broker reachable |
| `MetaDataServiceCheck` | Succeeded | IMDS reachable |
| `AppAttachHealthCheck` | Succeeded | MSIX not used, passes by default |
| `TURNRelayAccessHealthCheck` | Succeeded | UDP relay connectivity confirmed |
| `AADJoinedHealthCheck` | Succeeded | Entra ID join confirmed |
| `DomainJoinedCheck` | Succeeded | Agent registered in Entra-only mode |
| `DomainTrustCheck` | Succeeded | Agent registered in Entra-only mode |

**Validated result:** `fin-sh-02` reported `Available` with all broker health checks succeeded, including `AADJoinedHealthCheck`.

---

## 6. Architecture Summary

```
FinBridge-Workspace
  └── POOL-FIN-01-DAG (Desktop App Group)
        └── POOL-FIN-01 (Host Pool — Pooled, BreadthFirst, max 5 sessions)
              └── fin-sh-02 (Validated Session Host)
                    ├── OS: Windows 11 24H2 AVD (26100.9168.260809)
                    ├── Size: Standard_B2ms
                    ├── Security: Trusted Launch (Secure Boot + vTPM)
                    ├── Join: Microsoft Entra ID only
                    └── Network: dwp-pUser110894-winVNET / 10.0.0.8 (no public IP)
```

---

## 7. User Access Summary

| User | Role | Scope | Capability |
|---|---|---|---|
| traininguser31@zippyops.in | Desktop Virtualization User | POOL-FIN-01-DAG | Connect via AVD client / web |
| traininguser31@zippyops.in | Virtual Machine User Login | fin-sh-02 | Direct RDP from a network path that reaches 10.0.0.8 |

**AVD Client URL:** https://client.wvd.microsoft.com/arm/webclient/

---

## 8. Troubleshooting Notes

### DSC `AadJoin` Parameter Not Found
This indicates the legacy gallery package was used. Remove stale AVD agent state with `Reset-AVDAgentRegistration.ps1`, reboot, and register again with the current `Azure/RDS-Templates` package and `AadJoin=true`.

### Run Command Conflict
If `az vm run-command invoke` returns a `Conflict` error, a previous invocation or extension is still occupying the run-command slot. Use `az vm run-command create` (the newer resource-based API) which runs in its own slot:
```powershell
az vm run-command create --resource-group <rg> --vm-name <vm> --run-command-name <uniqueName> --script "..." --async-execution false
```

### Extension Auto-Update Post-Reboot
After a VM reboot, Azure auto-updates extensions. The ARM provisioning state shows `Updating` but the VM-side instance view shows `ProvisioningState/succeeded`. Use the instance view REST API to get the actual status:
```powershell
az rest --method get --url "https://management.azure.com/.../virtualMachines/fin-sh-02/instanceView?api-version=2024-07-01" --query "extensions[].{name:name, status:statuses[0].displayStatus}"
```
