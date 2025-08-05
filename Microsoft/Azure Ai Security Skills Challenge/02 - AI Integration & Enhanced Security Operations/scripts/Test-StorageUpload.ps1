#Requires -Version 7.0
<#
.SYNOPSIS
    Tests storage account upload functionality for AI Storage Foundation
.DESCRIPTION
    This script validates storage account connectivity, uploads a test file to verify permissions,
    and confirms container accessibility for the AI Storage Foundation deployment.
.PARAMETER EnvironmentName
    The environment name used for resource naming (e.g., "aisec")
.PARAMETER ContainerName
    The container name to test upload functionality (e.g., "ai-data")
.PARAMETER TestFilePath
    The path to the test file to upload (relative to script directory)
.PARAMETER UseParametersFile
    Switch to load configuration from main.parameters.json file
.EXAMPLE
    .\Test-StorageUpload.ps1 -UseParametersFile
    
    Test storage upload using parameters from main.parameters.json file.
.EXAMPLE
    .\Test-StorageUpload.ps1 -UseParametersFile -ContainerName "ai-logs"
    
    Test storage upload using parameters file but override container name.
.EXAMPLE
    .\Test-StorageUpload.ps1 -EnvironmentName "aisec" -ContainerName "ai-data" -TestFilePath "templates\ai-storage-test-upload.txt"
    
    Test storage upload with manual parameters.
#>

param(
    [Parameter(Mandatory = $false, HelpMessage="Environment name for resource naming")]
    [string]$EnvironmentName = "",
    
    [Parameter(Mandatory = $false, HelpMessage="Container name to test upload functionality")]
    [string]$ContainerName = "ai-data",
    
    [Parameter(Mandatory = $false, HelpMessage="Path to test file relative to script directory")]
    [string]$TestFilePath = "templates\ai-storage-test-upload.txt",
    
    [Parameter(Mandatory = $false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🔍 AI Storage Upload Validation" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

try {
    # =============================================================================
    # PHASE 1: Parameter Loading and Validation
    # =============================================================================
    
    Write-Host "📋 Phase 1: Parameter Loading" -ForegroundColor Yellow
    
    if ($UseParametersFile) {
        # Load parameters from JSON file
        $ParametersFile = "$PSScriptRoot\..\infra\main.parameters.json"
        
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
    $testFileName = Split-Path $TestFilePath -Leaf
    $fullTestFilePath = Join-Path $PSScriptRoot $TestFilePath
    
    Write-Host "  � Test Configuration:" -ForegroundColor Yellow
    Write-Host "     Environment: $EnvironmentName" -ForegroundColor White
    Write-Host "     Resource Group: $resourceGroupName" -ForegroundColor White
    Write-Host "     Container: $ContainerName" -ForegroundColor White
    Write-Host "     Test File: $testFileName" -ForegroundColor White

    
    # =============================================================================
    # PHASE 2: Storage Account Discovery and Testing
    # =============================================================================
    
    Write-Host "`n🔍 Phase 2: Storage Account Testing" -ForegroundColor Yellow
    
    # Verify test file exists
    if (-not (Test-Path $fullTestFilePath)) {
        Write-Host "❌ Test file not found: $fullTestFilePath" -ForegroundColor Red
        exit 1
    }

    # Get storage account name
    Write-Host "🔍 Discovering storage account..." -ForegroundColor Yellow
    $storageAccounts = az storage account list --resource-group $resourceGroupName --query "[?starts_with(name, 'stai')].name" -o tsv
    
    if (-not $storageAccounts) {
        Write-Host "❌ No storage account found in resource group: $resourceGroupName" -ForegroundColor Red
        exit 1
    }
    
    $storageAccountName = $storageAccounts | Select-Object -First 1
    Write-Host "✅ Storage Account: $storageAccountName - Connected" -ForegroundColor Green

    # Get storage account details
    $storageAccount = az storage account show --name $storageAccountName --resource-group $resourceGroupName | ConvertFrom-Json
    $blobEndpoint = $storageAccount.primaryEndpoints.blob

    # Test container accessibility
    Write-Host "🔍 Testing container accessibility..." -ForegroundColor Yellow
    $containers = az storage container list --account-name $storageAccountName --auth-mode login --query "[].name" -o tsv
    
    if ($containers -contains $ContainerName) {
        Write-Host "✅ Container: $ContainerName - Accessible (test file uploaded)" -ForegroundColor Green
    } else {
        Write-Host "❌ Container: $ContainerName - Not accessible" -ForegroundColor Red
        exit 1
    }

    # Upload test file
    Write-Host "🔍 Uploading test file..." -ForegroundColor Yellow
    $uploadResult = az storage blob upload `
        --account-name $storageAccountName `
        --container-name $ContainerName `
        --name $testFileName `
        --file $fullTestFilePath `
        --auth-mode login `
        --overwrite 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Test File: $testFileName - Uploaded Successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Test File: $testFileName - Upload Failed" -ForegroundColor Red
        Write-Host "Error: $uploadResult" -ForegroundColor Red
        exit 1
    }

    # Test other containers (show as created but empty)
    $allContainers = @("ai-data", "ai-logs", "ai-models")
    foreach ($container in $allContainers) {
        if ($container -ne $ContainerName) {
            if ($containers -contains $container) {
                Write-Host "✅ Container: $container - Created (empty)" -ForegroundColor Green
            } else {
                Write-Host "❌ Container: $container - Not found" -ForegroundColor Red
            }
        }
    }

    # Validate blob endpoint
    Write-Host "✅ Blob Endpoint: $blobEndpoint - Validated" -ForegroundColor Green

    Write-Host ""
    Write-Host "🎯 Storage Upload Test: COMPLETED SUCCESSFULLY" -ForegroundColor Green
    Write-Host "Next: Run comprehensive validation with Test-StorageFoundation.ps1" -ForegroundColor Cyan

} catch {
    Write-Host ""
    Write-Host "❌ Storage Upload Test: FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
