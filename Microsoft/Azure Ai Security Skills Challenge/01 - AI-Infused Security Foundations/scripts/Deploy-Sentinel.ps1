# =============================================================================
# Microsoft Defender for Cloud - Microsoft Sentinel Integration Script
# =============================================================================
# This script enables Microsoft Sentinel on the Log Analytics Workspace created
# in Step 1, preparing the environment for enhanced SIEM capabilities.
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Name for the environment (matching previous deployment steps)")]
    [string]$EnvironmentName = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory=$false, HelpMessage="Preview changes without executing")]
    [switch]$WhatIf,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip confirmation prompts")]
    [switch]$Force
)

# Script Configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Initialize parameter variables
$ResourceGroupName = ""
$ResourceToken = ""

# =============================================================================
# Helper Functions
# =============================================================================

function Invoke-AzureRestApi {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Method,
        
        [Parameter(Mandatory = $true)]
        [string]$Uri,
        
        [Parameter(Mandatory = $false)]
        [string]$Body,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Headers = @{'Content-Type' = 'application/json'}
    )

    try {
        $restArgs = @('--method', $Method, '--uri', $Uri)
        
        if ($Body) {
            $tempFile = [System.IO.Path]::GetTempFileName()
            $Body | Out-File -FilePath $tempFile -Encoding UTF8 -Force
            $restArgs += '--body', "@$tempFile"
        }
        
        if ($Headers.Count -gt 0) {
            $headerFile = [System.IO.Path]::GetTempFileName()
            ($Headers | ConvertTo-Json -Compress) | Out-File -FilePath $headerFile -Encoding UTF8 -Force
            $restArgs += '--headers', "@$headerFile"
        }
        
        $response = az rest @restArgs --output json 2>&1
        
        # Clean up temp files
        if ($tempFile -and (Test-Path $tempFile)) { Remove-Item $tempFile -Force }
        if ($headerFile -and (Test-Path $headerFile)) { Remove-Item $headerFile -Force }
        
        if ($LASTEXITCODE -ne 0) {
            throw "Azure REST API call failed: $response"
        }
        
        return ($response | ConvertFrom-Json)
    }
    catch {
        throw "REST API call failed: $($_.Exception.Message)"
    }
}

Write-Host "🛡️ Microsoft Defender for Cloud - Sentinel Integration" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""

# =============================================================================
# 💰 COST AWARENESS WARNING - Microsoft Sentinel
# =============================================================================
Write-Host "💰 COST AWARENESS: Microsoft Sentinel Pricing" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host "📊 Microsoft Sentinel pricing is based on data ingestion and retention:" -ForegroundColor Yellow
Write-Host "   • Data Ingestion: ~`$2.30/GB for first 100GB per day, then tiered pricing" -ForegroundColor Yellow
Write-Host "   • Data Retention: First 90 days included, then ~`$0.10/GB/month" -ForegroundColor Yellow
Write-Host "   • Estimated Lab Cost: ~`$5-15/month for typical security lab data volumes" -ForegroundColor Yellow
Write-Host "   • Free Tier: 31-day trial with up to 10GB/day included" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Cost Management Tips:" -ForegroundColor Cyan
Write-Host "   • Configure data retention policies to optimize storage costs" -ForegroundColor Cyan
Write-Host "   • Use log filtering to reduce unnecessary data ingestion" -ForegroundColor Cyan
Write-Host "   • Monitor usage with Azure Cost Management + Billing" -ForegroundColor Cyan
Write-Host "   • Take advantage of the 31-day free trial for initial testing" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Parameter File Integration
# =============================================================================

if ($UseParametersFile) {
    Write-Host "📄 Loading parameters from main.parameters.json..." -ForegroundColor Cyan
    $parametersFilePath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    
    if (Test-Path $parametersFilePath) {
        try {
            $mainParameters = Get-Content $parametersFilePath -Raw | ConvertFrom-Json
            $EnvironmentName = $mainParameters.parameters.environmentName.value
            $ResourceGroupName = $mainParameters.parameters.resourceGroupName.value
            $ResourceToken = $mainParameters.parameters.resourceToken.value
            Write-Host "✅ Parameters loaded successfully" -ForegroundColor Green
            Write-Host "   Environment Name: $EnvironmentName" -ForegroundColor White
            Write-Host "   Resource Group: $ResourceGroupName" -ForegroundColor White
            Write-Host "   Resource Token: $ResourceToken" -ForegroundColor White
        }
        catch {
            Write-Error "❌ Failed to parse main.parameters.json: $($_.Exception.Message)"
            exit 1
        }
    }
    else {
        Write-Error "❌ Parameters file not found: $parametersFilePath"
        Write-Host "💡 Run Step 1 (Deploy-InfrastructureFoundation.ps1) first to create the infrastructure" -ForegroundColor Yellow
        exit 1
    }
}

# =============================================================================
# Parameter Validation
# =============================================================================

if (-not $EnvironmentName) {
    Write-Error "❌ EnvironmentName parameter is required"
    Write-Host "💡 Use -UseParametersFile or specify -EnvironmentName" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Azure Authentication Validation
# =============================================================================

Write-Host "🔐 Validating Azure authentication..." -ForegroundColor Cyan
try {
    $azAccount = az account show --output json | ConvertFrom-Json
    $subscriptionId = $azAccount.id
    Write-Host "✅ Authenticated to subscription: $($azAccount.name) ($subscriptionId)" -ForegroundColor Green
}
catch {
    Write-Error "❌ Azure CLI authentication required. Run 'az login' first."
    exit 1
}

# =============================================================================
# Step 1: Environment Validation and Setup
# =============================================================================

Write-Host "🏗️ Step 1: Environment Validation and Setup" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

Write-Host "🏗️ Constructing resource names..." -ForegroundColor Cyan

# Use parameters from file if available, otherwise construct from EnvironmentName
if ($UseParametersFile -and $ResourceGroupName -and $ResourceToken) {
    $resourceGroupName = $ResourceGroupName
    $workspaceName = "log-aisec-defender-$EnvironmentName-$ResourceToken"
    Write-Host "   Using parameters from main.parameters.json" -ForegroundColor Yellow
} else {
    $resourceGroupName = "rg-aisec-defender-$EnvironmentName"
    $workspaceName = "law-aisec-defender-$EnvironmentName"
    Write-Host "   Using constructed names from EnvironmentName" -ForegroundColor Yellow
}

Write-Host "📋 Target Configuration:" -ForegroundColor Cyan
Write-Host "   Resource Group: $resourceGroupName" -ForegroundColor White
Write-Host "   Log Analytics Workspace: $workspaceName" -ForegroundColor White
Write-Host "   Subscription: $subscriptionId" -ForegroundColor White

# =============================================================================
# Step 2: Pre-deployment Validation
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Pre-deployment Validation" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

Write-Host "🔍 Validating Log Analytics Workspace..." -ForegroundColor Cyan
try {
    $workspaceUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName" + "?api-version=2021-06-01"
    $workspace = Invoke-AzureRestApi -Method "GET" -Uri $workspaceUri
    
    if ($workspace.properties.provisioningState -ne "Succeeded") {
        Write-Error "❌ Log Analytics Workspace '$workspaceName' is not in succeeded state: $($workspace.properties.provisioningState)"
        exit 1
    }
    
    Write-Host "✅ Log Analytics Workspace validated successfully" -ForegroundColor Green
    Write-Host "   Location: $($workspace.location)" -ForegroundColor White
    Write-Host "   Resource ID: $($workspace.id)" -ForegroundColor White
}
catch {
    Write-Error "❌ Log Analytics Workspace validation failed: $($_.Exception.Message)"
    Write-Host "💡 Ensure Step 1 (Deploy-InfrastructureFoundation.ps1) completed successfully" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Current State Assessment
# =============================================================================

Write-Host "🔍 Checking current Sentinel status..." -ForegroundColor Cyan
$sentinelUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/onboardingStates/default" + "?api-version=2023-02-01"

try {
    $sentinelState = Invoke-AzureRestApi -Method "GET" -Uri $sentinelUri
    if ($sentinelState) {
        Write-Host "ℹ️ Microsoft Sentinel is already enabled on this workspace" -ForegroundColor Yellow
        Write-Host "   Customer Managed Key: $($sentinelState.properties.customerManagedKey)" -ForegroundColor White
        
        if (-not $WhatIf) {
            Write-Host "✅ Sentinel deployment validation completed - already configured" -ForegroundColor Green
            Write-Host ""
            Write-Host "🔧 Next Steps:" -ForegroundColor Cyan
            Write-Host "   1. Configure Defender for Cloud data connector in Azure Portal" -ForegroundColor White
            Write-Host "   2. Wait 5-10 minutes for initial data ingestion" -ForegroundColor White
            Write-Host "   3. Validate data flow with KQL queries" -ForegroundColor White
            exit 0
        }
    }
}
catch {
    Write-Host "ℹ️ Sentinel not currently enabled - proceeding with enablement" -ForegroundColor Yellow
}

# =============================================================================
# What-If Mode Preview
# =============================================================================

if ($WhatIf) {
    Write-Host "🔍 What-If Mode: Preview of Sentinel enablement" -ForegroundColor Magenta
    Write-Host "===============================================" -ForegroundColor Magenta
    Write-Host "✅ Would enable Microsoft Sentinel with the following configuration:" -ForegroundColor White
    Write-Host "   • Subscription: $subscriptionId" -ForegroundColor White
    Write-Host "   • Resource Group: $resourceGroupName" -ForegroundColor White
    Write-Host "   • Log Analytics Workspace: $workspaceName" -ForegroundColor White
    Write-Host "   • Customer Managed Key: false (using Microsoft-managed encryption)" -ForegroundColor White
    Write-Host "   • Data Retention: 90 days (included)" -ForegroundColor White
    Write-Host "   • Estimated Cost: ~`$5-15/month for typical lab data volumes" -ForegroundColor White
    Write-Host ""
    Write-Host "✅ What-If validation completed successfully" -ForegroundColor Green
    exit 0
}

# =============================================================================
# User Confirmation (if not using -Force)
# =============================================================================

if (-not $Force) {
    Write-Host "⚠️ Confirmation Required" -ForegroundColor Yellow
    Write-Host "========================" -ForegroundColor Yellow
    Write-Host "This script will enable Microsoft Sentinel on workspace: $workspaceName" -ForegroundColor White
    Write-Host "Estimated monthly cost: ~`$5-15 for lab scenarios" -ForegroundColor White
    Write-Host ""
    $confirmation = Read-Host "Do you want to proceed? (y/N)"
    if ($confirmation -ne "y" -and $confirmation -ne "Y") {
        Write-Host "❌ Operation cancelled by user" -ForegroundColor Red
        exit 0
    }
}

# =============================================================================
# Step 3: Microsoft Sentinel Enablement
# =============================================================================

Write-Host ""
Write-Host "🚀 Step 3: Microsoft Sentinel Enablement" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

$sentinelBody = @{
    properties = @{
        customerManagedKey = $false
    }
} | ConvertTo-Json -Depth 10

try {
    Write-Host "   Creating Sentinel onboarding state..." -ForegroundColor White
    $result = Invoke-AzureRestApi -Method "PUT" -Uri $sentinelUri -Body $sentinelBody
    
    if ($result.properties) {
        Write-Host "✅ Microsoft Sentinel enabled successfully!" -ForegroundColor Green
        Write-Host "   Workspace ID: $($result.properties.workspaceId)" -ForegroundColor White
        Write-Host "   Customer Managed Key: $($result.properties.customerManagedKey)" -ForegroundColor White
    }
    else {
        Write-Error "❌ Unexpected response format from Sentinel enablement"
        exit 1
    }
}
catch {
    Write-Error "❌ Failed to enable Microsoft Sentinel: $($_.Exception.Message)"
    exit 1
}

# =============================================================================
# Deployment Success Summary
# =============================================================================

Write-Host ""
Write-Host "🎉 Microsoft Sentinel Deployment Completed Successfully!" -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "� Deployment Summary:" -ForegroundColor Cyan
Write-Host "   ✅ Sentinel Workspace: Enabled and configured" -ForegroundColor Green
Write-Host "   ✅ Data Ingestion: Ready for security data" -ForegroundColor Green
Write-Host "   ✅ Cost Optimization: Using Microsoft-managed encryption" -ForegroundColor Green
Write-Host "   ✅ Integration Ready: Prepared for data connector configuration" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Configure Defender for Cloud data connector in Azure Portal" -ForegroundColor White
Write-Host "   2. Wait 5-10 minutes for initial data ingestion" -ForegroundColor White
Write-Host "   3. Validate data flow with KQL queries" -ForegroundColor White
Write-Host "   4. Proceed to Step 7: Generate and Monitor Security Alerts" -ForegroundColor White
Write-Host ""
Write-Host "📚 Additional Resources:" -ForegroundColor Cyan
Write-Host "   • Microsoft Sentinel Documentation: https://docs.microsoft.com/azure/sentinel/" -ForegroundColor White
Write-Host "   • KQL Query Language: https://docs.microsoft.com/azure/data-explorer/kql-quick-reference" -ForegroundColor White
Write-Host ""
Write-Host "✅ Script execution completed successfully!" -ForegroundColor Green
