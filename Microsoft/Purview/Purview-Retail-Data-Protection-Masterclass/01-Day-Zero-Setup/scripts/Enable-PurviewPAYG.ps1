<#
.SYNOPSIS
    Enables Pay-As-You-Go billing for Microsoft Purview by creating a Purview Account.

.DESCRIPTION
    This script automates the setup of Pay-As-You-Go billing for Microsoft Purview.
    It creates an Azure Resource Group and a Microsoft Purview Account, which enables
    Data Map and other advanced features that require an Azure Subscription.

.PARAMETER ResourceGroupName
    The name of the Azure Resource Group to create or use.
    Default: rg-purview-payg

.PARAMETER Location
    The Azure region for the resources.
    Default: East US

.PARAMETER PurviewAccountName
    The name of the Purview Account to create.
    Default: pview-payg-<random-suffix>

.PARAMETER DryRun
    Simulates the execution without creating any resources.
    Useful for verifying if PAYG is already enabled.

.EXAMPLE
    .\Enable-PurviewPAYG.ps1
    
    Creates resources with default names in East US.

.EXAMPLE
    .\Enable-PurviewPAYG.ps1 -DryRun
    
    Checks for existing accounts and reports what would happen, without making changes.

.NOTES
    Author: GitHub Copilot
    Version: 1.1.0
    Requirements:
    - Az PowerShell module
    - Owner/Contributor permissions on the Azure Subscription
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "rg-purview-payg",

    [Parameter(Mandatory = $false)]
    [string]$Location = "East US",

    [Parameter(Mandatory = $false)]
    [string]$PurviewAccountName,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun,

    [Parameter(Mandatory = $false)]
    [switch]$IgnoreExisting
)

# =============================================================================
# Step 1: Azure Authentication
# =============================================================================
Write-Host "🔐 Step 1: Azure Authentication" -ForegroundColor Cyan

# Check if Az module is available
if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
    Write-Error "❌ Az.Accounts module is not installed. Please run 'Install-Module Az -Scope CurrentUser'."
    exit 1
}

# Check if Az.Purview module is available
if (-not (Get-Module -ListAvailable -Name Az.Purview)) {
    Write-Host "   ⚠️ Az.Purview module is not installed. Attempting to install..." -ForegroundColor Yellow
    try {
        Install-Module -Name Az.Purview -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        Import-Module Az.Purview
        Write-Host "   ✅ Az.Purview module installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Failed to install Az.Purview module. Please run 'Install-Module Az.Purview' manually."
        exit 1
    }
}

# Connect to Azure if not already connected
try {
    $context = Get-AzContext -ErrorAction SilentlyContinue
    if ($null -eq $context) {
        Write-Host "   Connecting to Azure..." -ForegroundColor Gray
        Connect-AzAccount | Out-Null
    }
    $context = Get-AzContext
    Write-Host "   ✅ Connected to subscription: $($context.Subscription.Name) ($($context.Subscription.Id))" -ForegroundColor Green
}
catch {
    Write-Error "❌ Failed to connect to Azure: $_"
    exit 1
}

# =============================================================================
# Step 2: Pre-flight Checks
# =============================================================================
Write-Host "`n🔍 Step 2: Pre-flight Checks" -ForegroundColor Cyan

# Check for ANY existing Purview accounts in the subscription
try {
    $existingAccounts = Get-AzPurviewAccount -ErrorAction SilentlyContinue
    if ($existingAccounts) {
        Write-Host "   ⚠️  Found existing Purview Account(s) in this subscription:" -ForegroundColor Yellow
        foreach ($acc in $existingAccounts) {
            Write-Host "      - Name: $($acc.Name) | ResourceGroup: $($acc.ResourceGroupName) | Location: $($acc.Location)" -ForegroundColor Yellow
        }
        
        if ($IgnoreExisting) {
            Write-Host "   [IgnoreExisting] Proceeding despite existing accounts..." -ForegroundColor Cyan
        } else {
            Write-Host "`n   ✅ Purview Pay-As-You-Go is ALREADY enabled." -ForegroundColor Green
            Write-Host "   Aborting script to prevent duplicate account creation." -ForegroundColor Gray
            exit 0
        }
    } else {
        Write-Host "   ✅ No existing Purview accounts found. Proceeding..." -ForegroundColor Green
    }
}
catch {
    # Ignore errors here, just proceed to creation attempt
}

# =============================================================================
# Step 3: Resource Group Management
# =============================================================================
Write-Host "`n📦 Step 3: Resource Group Management" -ForegroundColor Cyan

try {
    $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if ($null -eq $rg) {
        if ($DryRun) {
            Write-Host "   [DryRun] Would create resource group '$ResourceGroupName' in '$Location'." -ForegroundColor Cyan
        } else {
            Write-Host "   Creating resource group '$ResourceGroupName' in '$Location'..." -ForegroundColor Gray
            $rg = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
            Write-Host "   ✅ Resource group created successfully" -ForegroundColor Green
        }
    }
    else {
        Write-Host "   ✅ Resource group '$ResourceGroupName' already exists" -ForegroundColor Green
    }
}
catch {
    Write-Error "❌ Failed to manage resource group: $_"
    exit 1
}

# =============================================================================
# Step 4: Purview Account Creation
# =============================================================================
Write-Host "`n🚀 Step 4: Purview Account Creation" -ForegroundColor Cyan

# Generate random name if not provided
if ([string]::IsNullOrEmpty($PurviewAccountName)) {
    $randomSuffix = Get-Random -Minimum 1000 -Maximum 9999
    $PurviewAccountName = "pview-payg-$randomSuffix"
    Write-Host "   Generated Purview Account name: $PurviewAccountName" -ForegroundColor Gray
}

try {
    # Check if Purview account exists
    $purviewAccount = Get-AzPurviewAccount -Name $PurviewAccountName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    
    if ($null -eq $purviewAccount) {
        if ($DryRun) {
            Write-Host "   [DryRun] Would create Purview Account '$PurviewAccountName' in '$ResourceGroupName'." -ForegroundColor Cyan
            exit 0
        }

        Write-Host "   Creating Purview Account '$PurviewAccountName' (this may take a few minutes)..." -ForegroundColor Gray
        
        # Create the account
        $purviewAccount = New-AzPurviewAccount -Name $PurviewAccountName `
                                             -ResourceGroupName $ResourceGroupName `
                                             -Location $Location `
                                             -SkuCapacity 1 `
                                             -SkuName Standard `
                                             -PublicNetworkAccess Enabled
                                             
        Write-Host "   ✅ Purview Account created successfully" -ForegroundColor Green
    }
    else {
        Write-Host "   ✅ Purview Account '$PurviewAccountName' already exists" -ForegroundColor Green
    }
    
    # Display details
    Write-Host "`n📋 Purview Account Details:" -ForegroundColor Cyan
    Write-Host "   Name: $($purviewAccount.Name)"
    Write-Host "   Resource Group: $($purviewAccount.ResourceGroupName)"
    Write-Host "   Location: $($purviewAccount.Location)"
    Write-Host "   Provisioning State: $($purviewAccount.ProvisioningState)"
    
    Write-Host "`n✅ Pay-As-You-Go billing is now enabled via this Purview Account." -ForegroundColor Green
    Write-Host "   You can now use Data Map and other advanced features." -ForegroundColor Gray
}
catch {
    Write-Error "❌ Failed to create Purview Account: $_"
    Write-Host "`n💡 Troubleshooting:" -ForegroundColor Yellow
    Write-Host "   - Ensure the 'Microsoft.Purview' resource provider is registered in your subscription."
    Write-Host "   - Run: Register-AzResourceProvider -ProviderNamespace Microsoft.Purview"
    exit 1
}
