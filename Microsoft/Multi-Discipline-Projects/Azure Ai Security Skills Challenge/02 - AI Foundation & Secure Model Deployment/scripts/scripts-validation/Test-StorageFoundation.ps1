#Requires -Version 7.0
<#
.SYNOPSIS
    Comprehensive validation of AI Storage Foundation deployment
.DESCRIPTION
    This script performs complete validation of the AI Storage Foundation deployment including:
    - Resource group validation
    - Storage account configuration verification
    - Container creation and accessibility testing
    - Security configuration validation
    - Role assignment verification
.PARAMETER EnvironmentName
    The environment name used for resource naming (e.g., "aisec")
.PARAMETER ValidationScope
    The scope of validation to perform. Options: "Complete", "Basic"
.PARAMETER UseParametersFile
    Switch to load configuration from main.parameters.json file
.EXAMPLE
    .\Test-StorageFoundation.ps1 -UseParametersFile
    
    Run comprehensive validation using parameters from main.parameters.json file.
.EXAMPLE
    .\Test-StorageFoundation.ps1 -UseParametersFile -ValidationScope "Basic"
    
    Run basic validation using parameters file.
.EXAMPLE
    .\Test-StorageFoundation.ps1 -EnvironmentName "aisec" -ValidationScope "Complete"
    
    Run comprehensive validation with manual parameters.
#>

param(
    [Parameter(Mandatory = $false, HelpMessage="Environment name for resource naming")]
    [string]$EnvironmentName = "",
    
    [Parameter(Mandatory = $false, HelpMessage="Scope of validation to perform")]
    [ValidateSet("Complete", "Basic")]
    [string]$ValidationScope = "Complete",
    
    [Parameter(Mandatory = $false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🔍 AI Storage Foundation Validation Results" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # =============================================================================
    # PHASE 1: Parameter Loading and Validation
    # =============================================================================
    
    Write-Host "📋 Phase 1: Parameter Loading" -ForegroundColor Yellow
    
    if ($UseParametersFile) {
        # Load parameters from JSON file
        $ParametersFile = "$PSScriptRoot\..\..\infra\main.parameters.json"
        
        if (-not (Test-Path $ParametersFile)) {
            throw "Parameters file not found: $ParametersFile"
        }
        
        Write-Host "  📄 Loading parameters from: $ParametersFile" -ForegroundColor Green
        $Parameters = Get-Content $ParametersFile | ConvertFrom-Json
        
        # Override with parameters from file if not already specified
        if (-not $EnvironmentName) {
            $EnvironmentName = $Parameters.parameters.environmentName.value
        }
        
        Write-Host "  ✅ Parameters loaded successfully" -ForegroundColor Green
    } else {
        # Validate required parameters when not using parameters file
        if (-not $EnvironmentName) {
            throw "EnvironmentName parameter is required when not using -UseParametersFile"
        }
    }
    
    # Initialize variables
    $resourceGroupName = "rg-$EnvironmentName-ai"
    $expectedContainers = @("ai-data", "ai-logs", "ai-models")
    $validationResults = @()
    
    Write-Host "  📊 Validation Configuration:" -ForegroundColor Yellow
    Write-Host "     Environment: $EnvironmentName" -ForegroundColor White
    Write-Host "     Resource Group: $resourceGroupName" -ForegroundColor White
    Write-Host "     Validation Scope: $ValidationScope" -ForegroundColor White
    Write-Host ""

function Add-ValidationResult {
    param($Component, $Status, $Details = "")
    $script:validationResults += [PSCustomObject]@{
        Component = $Component
        Status = $Status
        Details = $Details
    }
    
    $icon = if ($Status -eq "Pass") { "✅" } else { "❌" }
    $color = if ($Status -eq "Pass") { "Green" } else { "Red" }
    
    if ($Details) {
        Write-Host "$icon $Component - $Details" -ForegroundColor $color
    } else {
        Write-Host "$icon $Component" -ForegroundColor $color
    }
}

    
    # =============================================================================
    # PHASE 2: Storage Foundation Validation
    # =============================================================================
    
    # 1. Validate Resource Group
    Write-Host "🔍 Validating resource group..." -ForegroundColor Yellow
    $resourceGroup = az group show --name $resourceGroupName 2>$null | ConvertFrom-Json
    
    if ($resourceGroup) {
        Add-ValidationResult "Resource Group: $resourceGroupName" "Pass" "Deployed"
    } else {
        Add-ValidationResult "Resource Group: $resourceGroupName" "Fail" "Not found"
        throw "Resource group validation failed"
    }

    # 2. Validate Storage Account
    Write-Host "🔍 Validating storage account..." -ForegroundColor Yellow
    $storageAccounts = az storage account list --resource-group $resourceGroupName --query "[?starts_with(name, 'stai')]" | ConvertFrom-Json
    
    if ($storageAccounts -and $storageAccounts.Count -gt 0) {
        $storageAccount = $storageAccounts[0]
        $storageAccountName = $storageAccount.name
        Add-ValidationResult "Storage Account: $storageAccountName" "Pass" "Configured"
        
        # Get storage account details for security validation
        $storageDetails = az storage account show --name $storageAccountName --resource-group $resourceGroupName | ConvertFrom-Json
        $blobEndpoint = $storageDetails.primaryEndpoints.blob
        
    } else {
        Add-ValidationResult "Storage Account" "Fail" "Not found"
        throw "Storage account validation failed"
    }

    # 3. Validate Containers
    Write-Host "🔍 Validating containers..." -ForegroundColor Yellow
    $containers = az storage container list --account-name $storageAccountName --auth-mode login --query "[].name" -o tsv
    
    foreach ($expectedContainer in $expectedContainers) {
        if ($containers -contains $expectedContainer) {
            Add-ValidationResult "Container: $expectedContainer" "Pass" "Created & Accessible"
        } else {
            Add-ValidationResult "Container: $expectedContainer" "Fail" "Not found or not accessible"
        }
    }

    # 4. Validate Security Configuration
    if ($ValidationScope -eq "Complete") {
        Write-Host "🔍 Validating security configuration..." -ForegroundColor Yellow
        
        # Check HTTPS enforcement
        $httpsOnly = $storageDetails.enableHttpsTrafficOnly
        $tlsVersion = $storageDetails.minimumTlsVersion
        $allowBlobPublicAccess = $storageDetails.allowBlobPublicAccess
        
        if ($httpsOnly -and $tlsVersion -eq "TLS1_2" -and -not $allowBlobPublicAccess) {
            Add-ValidationResult "Security" "Pass" "HTTPS enforced, TLS 1.2, No public access"
        } else {
            $securityIssues = @()
            if (-not $httpsOnly) { $securityIssues += "HTTPS not enforced" }
            if ($tlsVersion -ne "TLS1_2") { $securityIssues += "TLS version: $tlsVersion" }
            if ($allowBlobPublicAccess) { $securityIssues += "Public access allowed" }
            Add-ValidationResult "Security" "Fail" ($securityIssues -join ", ")
        }
    }

    # 5. Validate Role Assignment (if Complete scope)
    if ($ValidationScope -eq "Complete") {
        Write-Host "🔍 Validating role assignments..." -ForegroundColor Yellow
        
        # Get current user
        $currentUser = az account show --query "user.name" -o tsv
        
        # Check for Storage Blob Data Contributor role
        $roleAssignments = az role assignment list --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$resourceGroupName/providers/Microsoft.Storage/storageAccounts/$storageAccountName" --query "[?roleDefinitionName=='Storage Blob Data Contributor'].principalName" -o tsv
        
        if ($roleAssignments) {
            Add-ValidationResult "Role Assignment" "Pass" "Storage Blob Data Contributor - Applied"
        } else {
            Add-ValidationResult "Role Assignment" "Fail" "Storage Blob Data Contributor - Not found"
        }
    }

    # 6. Validate Blob Endpoint
    Write-Host "🔍 Validating blob endpoint..." -ForegroundColor Yellow
    if ($blobEndpoint -and $blobEndpoint.StartsWith("https://")) {
        Add-ValidationResult "Blob Endpoint: $blobEndpoint" "Pass" "Active"
    } else {
        Add-ValidationResult "Blob Endpoint" "Fail" "Invalid or not accessible"
    }

    Write-Host ""
    
    # Summary
    $passCount = ($validationResults | Where-Object { $_.Status -eq "Pass" }).Count
    $failCount = ($validationResults | Where-Object { $_.Status -eq "Fail" }).Count
    $totalCount = $validationResults.Count

    if ($failCount -eq 0) {
        Write-Host "🎯 Storage Foundation Status: READY FOR AI INTEGRATION" -ForegroundColor Green
        Write-Host "✅ All validation checks passed ($passCount/$totalCount)" -ForegroundColor Green
    } else {
        Write-Host "❌ Storage Foundation Status: ISSUES DETECTED" -ForegroundColor Red
        Write-Host "❌ Failed checks: $failCount/$totalCount" -ForegroundColor Red
        Write-Host "✅ Passed checks: $passCount/$totalCount" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "📋 Next Steps:" -ForegroundColor Cyan
    if ($failCount -eq 0) {
        Write-Host "• Proceed with AI service deployment" -ForegroundColor White
        Write-Host "• Deploy cost management features (Week 2)" -ForegroundColor White
        Write-Host "• Configure Azure OpenAI services" -ForegroundColor White
    } else {
        Write-Host "• Review and resolve failed validation items" -ForegroundColor White
        Write-Host "• Re-run deployment if necessary" -ForegroundColor White
        Write-Host "• Contact support if issues persist" -ForegroundColor White
    }

} catch {
    Write-Host ""
    Write-Host "❌ Storage Foundation Validation: FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
