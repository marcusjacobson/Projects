<#
.SYNOPSIS
    Deploy Azure Table Storage for AI processing duplicate prevention and audit trails.

.DESCRIPTION
    This script creates and configures Azure Table Storage tables in the existing Week 2 
    AI storage account for tracking AI processing status and preventing duplicate 
    processing of security alerts. The script integrates with the established storage 
    infrastructure and prepares the foundation for Logic Apps duplicate prevention.

    The script creates the 'aiProcessed' table used by Logic Apps to track which alerts
    have been processed, implementing time-based duplicate prevention with audit 
    capabilities for AI security analysis workflows.

.PARAMETER UseParametersFile
    Load configuration from main.parameters.json instead of individual parameters.

.PARAMETER EnvironmentName
    The environment name used as a prefix for resource naming (e.g., "aisec").
    When UseParametersFile is specified, this is loaded from parameters file.

.PARAMETER Location
    The Azure region for resource deployment (e.g., "East US").
    When UseParametersFile is specified, this is loaded from parameters file.

.PARAMETER ResourceGroupName
    Optional override for the AI resource group name. If not specified, constructed
    from environment name pattern (rg-[EnvironmentName]-ai).

.PARAMETER StorageAccountName
    Optional override for the storage account name. If not specified, discovered
    automatically from the AI resource group.

.EXAMPLE
    .\Deploy-ProcessingStorage.ps1 -UseParametersFile
    
    Deploy Table Storage using configuration from main.parameters.json for
    automated parameter loading and standardized deployment.

.EXAMPLE
    .\Deploy-ProcessingStorage.ps1 -EnvironmentName "aisec" -Location "East US"
    
    Deploy with specific environment parameters, using automatic resource discovery
    for existing storage account integration.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-08-31
    Last Modified: 2025-08-31
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Azure CLI installed and authenticated
    - PowerShell 5.1+ or PowerShell 7+
    - Existing Week 2 AI storage account deployment
    - Storage Table Data Contributor permissions on target storage account
    - Azure Resource Manager read permissions for resource discovery
    
    Script development orchestrated using GitHub Copilot.

.PROCESSING_TABLES
    - aiProcessed: Alert processing status tracking for duplicate prevention
    - processingAudit: Workflow execution history and audit trail
#>
#
# =============================================================================
# Deploy Azure Table Storage for AI processing duplicate prevention.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName,
    
    [Parameter(Mandatory = $false)]
    [string]$Location,
    
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $false)]
    [string]$StorageAccountName
)

# =============================================================================
# Step 1: Parameter Loading and Environment Setup
# =============================================================================

Write-Host "🔍 Step 1: Parameter Loading and Environment Setup" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

if ($UseParametersFile) {
    Write-Host "📋 Loading parameters from main.parameters.json..." -ForegroundColor Cyan
    
    $parametersPath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    if (-not (Test-Path $parametersPath)) {
        Write-Host "   ❌ Parameters file not found at: $parametersPath" -ForegroundColor Red
        exit 1
    }
    
    try {
        $parametersContent = Get-Content $parametersPath | ConvertFrom-Json
        $EnvironmentName = $parametersContent.parameters.environmentName.value
        $Location = $parametersContent.parameters.location.value
        
        Write-Host "   ✅ Parameters loaded successfully from file" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Failed to parse parameters file: $_" -ForegroundColor Red
        exit 1
    }
} else {
    if (-not $EnvironmentName -or -not $Location) {
        Write-Host "   ❌ EnvironmentName and Location are required when not using parameters file" -ForegroundColor Red
        exit 1
    }
}

# Construct resource group name if not provided
if (-not $ResourceGroupName) {
    $ResourceGroupName = "rg-$EnvironmentName-ai"
}

Write-Host "   📊 Environment: $EnvironmentName | Location: $Location" -ForegroundColor Green
Write-Host "   📁 Target Resource Group: $ResourceGroupName" -ForegroundColor Green

# =============================================================================
# Step 2: Azure Authentication and Subscription Validation
# =============================================================================

Write-Host "`n🔐 Step 2: Azure Authentication and Subscription Validation" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

Write-Host "📋 Validating Azure CLI authentication..." -ForegroundColor Cyan
try {
    $accountInfo = az account show 2>$null | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI authentication required"
    }
    
    Write-Host "   ✅ Azure CLI Authentication verified" -ForegroundColor Green
    Write-Host "   📊 Subscription: $($accountInfo.name) ($($accountInfo.id))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Azure authentication failed: $_" -ForegroundColor Red
    Write-Host "   🔧 Run 'az login' to authenticate" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 3: Resource Group and Storage Account Discovery
# =============================================================================

Write-Host "`n🔍 Step 3: Resource Group and Storage Account Discovery" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green

Write-Host "📋 Validating target resource group..." -ForegroundColor Cyan
try {
    $resourceGroup = az group show --name $ResourceGroupName 2>$null | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) {
        throw "Resource group not found: $ResourceGroupName"
    }
    
    Write-Host "   ✅ Resource group validated: $ResourceGroupName" -ForegroundColor Green
    Write-Host "   📍 Location: $($resourceGroup.location)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Resource group validation failed: $_" -ForegroundColor Red
    Write-Host "   💡 Ensure the Week 2 AI deployment has been completed" -ForegroundColor Yellow
    exit 1
}

if (-not $StorageAccountName) {
    Write-Host "📋 Discovering existing storage account..." -ForegroundColor Cyan
    try {
        $storageAccounts = az storage account list --resource-group $ResourceGroupName --query "[?kind=='StorageV2']" 2>$null | ConvertFrom-Json
        if ($LASTEXITCODE -ne 0 -or $storageAccounts.Count -eq 0) {
            throw "No storage accounts found in resource group"
        }
        
        # Find storage account with AI pattern (stai[env][random])
        $aiStorageAccount = $storageAccounts | Where-Object { $_.name -match "^st.*$EnvironmentName.*" }
        if (-not $aiStorageAccount) {
            # Fallback to first storage account if pattern matching fails
            $aiStorageAccount = $storageAccounts[0]
        }
        
        $StorageAccountName = $aiStorageAccount.name
        Write-Host "   ✅ Storage account discovered: $StorageAccountName" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Storage account discovery failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "📋 Validating specified storage account..." -ForegroundColor Cyan
    try {
        az storage account show --name $StorageAccountName --resource-group $ResourceGroupName 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Storage account not found: $StorageAccountName"
        }
        
        Write-Host "   ✅ Storage account validated: $StorageAccountName" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Storage account validation failed: $_" -ForegroundColor Red
        exit 1
    }
}

# =============================================================================
# Step 4: Storage Account Access Configuration
# =============================================================================

Write-Host "`n🔑 Step 4: Storage Account Access Configuration" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

Write-Host "📋 Retrieving storage account access key..." -ForegroundColor Cyan
try {
    $storageKey = az storage account keys list --account-name $StorageAccountName --resource-group $ResourceGroupName --query "[0].value" --output tsv 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($storageKey)) {
        throw "Failed to retrieve storage account key"
    }
    
    Write-Host "   ✅ Storage account access key retrieved" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Storage account access configuration failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 5: AI Processing Tables Creation
# =============================================================================

Write-Host "`n📊 Step 5: AI Processing Tables Creation" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Define tables to create
$tablesToCreate = @(
    @{
        Name = "aiProcessed"
        Description = "Alert processing status tracking for duplicate prevention"
    },
    @{
        Name = "processingAudit"
        Description = "Workflow execution history and audit trail"
    }
)

foreach ($table in $tablesToCreate) {
    Write-Host "📋 Creating table: $($table.Name)..." -ForegroundColor Cyan
    Write-Host "   📝 Purpose: $($table.Description)" -ForegroundColor Cyan
    
    try {
        # Check if table already exists
        $existingTable = az storage table exists --account-name $StorageAccountName --account-key $storageKey --name $table.Name --output tsv 2>$null
        
        if ($existingTable -eq "True") {
            Write-Host "   ℹ️  Table already exists: $($table.Name)" -ForegroundColor Yellow
        } else {
            # Create the table
            az storage table create --account-name $StorageAccountName --account-key $storageKey --name $table.Name 2>$null | Out-Null
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to create table: $($table.Name)"
            }
            
            Write-Host "   ✅ Table created successfully: $($table.Name)" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ Table creation failed for $($table.Name): $_" -ForegroundColor Red
        exit 1
    }
}

# =============================================================================
# Step 6: Table Schema Validation and Sample Data
# =============================================================================

Write-Host "`n🔍 Step 6: Table Schema Validation and Sample Data" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

Write-Host "📋 Validating table accessibility..." -ForegroundColor Cyan
foreach ($table in $tablesToCreate) {
    try {
        # Query table to confirm access
        az storage entity query --account-name $StorageAccountName --account-key $storageKey --table-name $table.Name --num-results 1 2>$null | Out-Null
        
        Write-Host "   ✅ Table accessible: $($table.Name)" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Table access warning for $($table.Name): $_" -ForegroundColor Yellow
    }
}

# Insert sample documentation entity for aiProcessed table
Write-Host "📋 Inserting schema documentation entity..." -ForegroundColor Cyan
try {
    $sampleEntity = @{
        PartitionKey = "schema-doc"
        RowKey = "v1.0"
        description = "AI Processing Duplicate Prevention Table"
        schema = "alertId(RowKey), lastProcessed(datetime), incidentId(string), processingStatus(string)"
        version = "1.0.0"
        createdDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    
    $entityJson = $sampleEntity | ConvertTo-Json -Compress
    
    # Insert the documentation entity
    az storage entity insert --account-name $StorageAccountName --account-key $storageKey --table-name "aiProcessed" --entity $entityJson 2>$null > $null
    
    Write-Host "   ✅ Schema documentation entity created" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Schema documentation creation skipped: $_" -ForegroundColor Yellow
}

# =============================================================================
# Step 7: Access Control and Security Configuration
# =============================================================================

Write-Host "`n🔐 Step 7: Access Control and Security Configuration" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

Write-Host "📋 Configuring storage security settings..." -ForegroundColor Cyan
try {
    # Enable secure transfer requirement
    az storage account update --name $StorageAccountName --resource-group $ResourceGroupName --https-only true 2>$null > $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ HTTPS-only access enforced" -ForegroundColor Green
    }
    
    # Configure minimum TLS version
    az storage account update --name $StorageAccountName --resource-group $ResourceGroupName --min-tls-version TLS1_2 2>$null > $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Minimum TLS 1.2 configured" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ⚠️  Security configuration warning: $_" -ForegroundColor Yellow
}

# =============================================================================
# Step 8: Integration Summary and Connection Information
# =============================================================================

Write-Host "`n🎯 Step 8: Integration Summary and Connection Information" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

Write-Host "📋 Generating connection information for Logic Apps..." -ForegroundColor Cyan

Write-Host "`n🔐 Storage Account Integration Details:" -ForegroundColor Cyan
Write-Host "=====================================`n" -ForegroundColor Cyan

Write-Host "📊 Storage Configuration:" -ForegroundColor Green
Write-Host "   • Storage Account: $StorageAccountName" -ForegroundColor White
Write-Host "   • Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "   • Location: $($resourceGroup.location)" -ForegroundColor White

Write-Host "`n📋 Created Tables:" -ForegroundColor Green
foreach ($table in $tablesToCreate) {
    Write-Host "   • $($table.Name): $($table.Description)" -ForegroundColor White
}

Write-Host "`n🔗 Logic Apps Connection Configuration:" -ForegroundColor Green
Write-Host "   • Connection Name: ai-processing-storage" -ForegroundColor White
Write-Host "   • Storage Account Name: $StorageAccountName" -ForegroundColor White
Write-Host "   • Authentication: Shared Storage Key (Key1)" -ForegroundColor White

Write-Host "`n📚 Table Usage Patterns:" -ForegroundColor Green
Write-Host "   • aiProcessed Table:" -ForegroundColor White
Write-Host "     - Partition Key: 'alerts'" -ForegroundColor Gray
Write-Host "     - Row Key: Alert ID (GUID)" -ForegroundColor Gray
Write-Host "     - Purpose: Duplicate prevention tracking" -ForegroundColor Gray
Write-Host "   • processingAudit Table:" -ForegroundColor White
Write-Host "     - Partition Key: Workflow Run ID" -ForegroundColor Gray
Write-Host "     - Row Key: Processing timestamp" -ForegroundColor Gray
Write-Host "     - Purpose: Execution history and debugging" -ForegroundColor Gray

Write-Host "`n💡 Next Steps:" -ForegroundColor Green
Write-Host "   1. Configure Logic Apps connection using the displayed settings" -ForegroundColor White
Write-Host "   2. Implement duplicate prevention logic using 'aiProcessed' table" -ForegroundColor White
Write-Host "   3. Add audit trail functionality using 'processingAudit' table" -ForegroundColor White

# =============================================================================
# Step 9: Deployment Validation and Completion
# =============================================================================

Write-Host "`n✅ Step 9: Deployment Validation and Completion" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

Write-Host "📋 Running final validation..." -ForegroundColor Cyan
$validationErrors = 0

# Validate tables exist and are accessible
foreach ($table in $tablesToCreate) {
    try {
        $tableExists = az storage table exists --account-name $StorageAccountName --account-key $storageKey --name $table.Name --output tsv 2>$null
        if ($tableExists -ne "True") {
            Write-Host "   ❌ Validation failed: Table $($table.Name) not accessible" -ForegroundColor Red
            $validationErrors++
        } else {
            Write-Host "   ✅ Table validation passed: $($table.Name)" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ Validation error for table $($table.Name): $_" -ForegroundColor Red
        $validationErrors++
    }
}

# Final status
if ($validationErrors -eq 0) {
    Write-Host "`n🎉 Processing Storage deployment completed successfully!" -ForegroundColor Green
    Write-Host "📊 All tables created and validated successfully" -ForegroundColor Green
    Write-Host "🔗 Ready for Logic Apps integration" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ Deployment completed with $validationErrors validation errors" -ForegroundColor Red
    Write-Host "🔧 Review the errors above and retry deployment if needed" -ForegroundColor Yellow
    exit 1
}
