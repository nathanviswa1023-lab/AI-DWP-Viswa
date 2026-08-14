<#
.SYNOPSIS
    Provisions the AVD control plane: host pool, desktop app group, and workspace.

.DESCRIPTION
    Creates POOL-FIN-01 (pooled, breadth-first, max 5 sessions), the POOL-FIN-01-DAG
    desktop application group, and registers it to FinBridge-Workspace.
    Requires the 'desktopvirtualization' Azure CLI extension.

.PARAMETER SubscriptionId
    Target Azure subscription ID.

.PARAMETER ResourceGroup
    Resource group name.

.PARAMETER Location
    Azure region (e.g. centralus).

.EXAMPLE
    .\New-AVDControlPlane.ps1 -SubscriptionId "7ee5e618-..." -ResourceGroup "dwp-lab-rg" -Location "centralus"
#>
param(
    [string]$SubscriptionId = "7ee5e618-6d68-45e4-8ded-436fb4b9cae2",
    [string]$ResourceGroup  = "dwp-lab-rg",
    [string]$Location       = "centralus",
    [string]$HostPoolName   = "POOL-FIN-01",
    [string]$AppGroupName   = "POOL-FIN-01-DAG",
    [string]$WorkspaceName  = "FinBridge-Workspace"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$hostPoolId = "/subscriptions/$SubscriptionId/resourcegroups/$ResourceGroup/providers/Microsoft.DesktopVirtualization/hostpools/$HostPoolName"
$appGroupId = "/subscriptions/$SubscriptionId/resourcegroups/$ResourceGroup/providers/Microsoft.DesktopVirtualization/applicationgroups/$AppGroupName"

Write-Host "==> [1/3] Creating host pool: $HostPoolName"
az desktopvirtualization hostpool create `
    --resource-group $ResourceGroup `
    --name $HostPoolName `
    --location $Location `
    --host-pool-type Pooled `
    --load-balancer-type BreadthFirst `
    --max-session-limit 5 `
    --preferred-app-group-type Desktop `
    -o json | ConvertFrom-Json | Select-Object name, hostPoolType, loadBalancerType, maxSessionLimit

Write-Host "==> [2/3] Creating desktop application group: $AppGroupName"
az desktopvirtualization applicationgroup create `
    --resource-group $ResourceGroup `
    --name $AppGroupName `
    --location $Location `
    --application-group-type Desktop `
    --host-pool-arm-path $hostPoolId `
    -o json | ConvertFrom-Json | Select-Object name, applicationGroupType

Write-Host "==> [3/3] Creating workspace '$WorkspaceName' and registering $AppGroupName"
az desktopvirtualization workspace create `
    --resource-group $ResourceGroup `
    --name $WorkspaceName `
    --location $Location `
    --application-group-references $appGroupId `
    -o json | ConvertFrom-Json | Select-Object name, applicationGroupReferences

Write-Host ""
Write-Host "AVD control plane provisioned successfully."
Write-Host "  Host Pool  : $HostPoolName"
Write-Host "  App Group  : $AppGroupName"
Write-Host "  Workspace  : $WorkspaceName"
