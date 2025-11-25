<#
.SYNOPSIS
    Deploys a Log Analytics Workspace for Entra ID monitoring.

.DESCRIPTION
    Creates a Resource Group and a Log Analytics Workspace in the specified Azure Subscription.
    Sets the data retention to 90 days to meet security baselines.
    Requires the 'Az' PowerShell module.

.PARAMETER SubscriptionId
    The ID of the Azure Subscription where resources will be deployed.

.PARAMETER ResourceGroupName
    Name of the Resource Group to create. Default: 'rg-entra-simulation-monitor'

.PARAMETER WorkspaceName
    Name of the Log Analytics Workspace. Default: 'law-entra-simulation'

.PARAMETER Location
    Azure region for deployment. Default: 'EastUS'

.EXAMPLE
    .\Deploy-LogAnalytics.ps1 -SubscriptionId "00000000-0000-0000-0000-000000000000"

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 00-Prerequisites-and-Monitoring
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [string]$ResourceGroupName = "rg-entra-simulation-monitor",
    [string]$WorkspaceName = "law-entra-simulation",
    [string]$Location = "EastUS"
)

process {
    # Check for Az module
    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        Throw "The 'Az.Accounts' module is required for this script. Please run 'Install-Module Az -Scope CurrentUser'."
    }

    Write-Host "🚀 Starting Log Analytics Deployment..." -ForegroundColor Cyan

    # Connect to Azure if not connected
    try {
        $azContext = Get-AzContext -ErrorAction SilentlyContinue
        if ($null -eq $azContext) {
            Write-Verbose "Connecting to Azure..."
            Connect-AzAccount -Subscription $SubscriptionId
        }
        else {
            Write-Verbose "Setting active subscription to $SubscriptionId..."
            Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
        }
    }
    catch {
        Throw "Failed to connect to Azure Subscription: $_"
    }

    # Create Resource Group
    Write-Host "Creating Resource Group '$ResourceGroupName' in '$Location'..." -ForegroundColor Cyan
    try {
        $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
        if ($null -eq $rg) {
            New-AzResourceGroup -Name $ResourceGroupName -Location $Location | Out-Null
            Write-Host "✅ Resource Group created." -ForegroundColor Green
        }
        else {
            Write-Host "✅ Resource Group already exists." -ForegroundColor Green
        }
    }
    catch {
        Throw "Failed to create Resource Group: $_"
    }

    # Create Log Analytics Workspace
    Write-Host "Creating Log Analytics Workspace '$WorkspaceName'..." -ForegroundColor Cyan
    try {
        $law = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -ErrorAction SilentlyContinue
        if ($null -eq $law) {
            $law = New-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -Location $Location -Sku "PerGB2018" -RetentionInDays 90
            Write-Host "✅ Workspace created with 90-day retention." -ForegroundColor Green
        }
        else {
            Write-Host "✅ Workspace already exists." -ForegroundColor Green
            # Enforce retention if it exists but is wrong
            if ($law.RetentionInDays -ne 90) {
                Write-Host "Updating retention to 90 days..." -ForegroundColor Yellow
                Set-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -RetentionInDays 90 | Out-Null
                Write-Host "✅ Retention updated." -ForegroundColor Green
            }
        }
    }
    catch {
        Throw "Failed to create Log Analytics Workspace: $_"
    }

    # Output details for next steps
    Write-Host "`n📋 Deployment Summary:" -ForegroundColor Cyan
    Write-Host "   Resource Group: $ResourceGroupName"
    Write-Host "   Workspace Name: $WorkspaceName"
    Write-Host "   Workspace ID:   $($law.ResourceId)" -ForegroundColor Yellow
    Write-Host "`n⚠️  Keep the Workspace ID handy for the Diagnostic Settings configuration!" -ForegroundColor Cyan
}
