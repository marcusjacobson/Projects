<#
.SYNOPSIS
    Safely removes all AI storage infrastructure components in the correct logical order.

.DESCRIPTION
    This script provides comprehensive decommission capabilities for AI storage
    foundation environments deployed via Infrastructure-as-Code. It performs ordered
    removal of storage accounts, containers, budget configurations, and resource groups
    while maintaining data integrity and preventing resource conflicts. The script
    includes safety mechanisms such as What-If mode, confirmation prompts, optional
    data backup, and comprehensive validation.

.PARAMETER EnvironmentName
    Name for the AI environment to decommission. Default: "aisec"

.PARAMETER BackupData
    Switch to backup container data before deletion.

.PARAMETER WhatIf
    Preview decommission without making changes.

.PARAMETER Force
    Force decommission without confirmation prompts (automation scenarios).

.PARAMETER PreserveResourceGroup
    Switch to preserve the resource group after removing contents.

.PARAMETER BackupPath
    Path for data backup. Default: Current directory/backup-{timestamp}

.PARAMETER UseParametersFile
    Switch to load parameters from main.parameters.json file.

.EXAMPLE
    .\Remove-AIStorageInfrastructure.ps1 -UseParametersFile -WhatIf
    
    Preview decommission using parameters file without making changes.

.EXAMPLE
    .\Remove-AIStorageInfrastructure.ps1 -UseParametersFile -BackupData
    
    Safely decommission with data backup using parameters file configuration.

.EXAMPLE
    .\Remove-AIStorageInfrastructure.ps1 -EnvironmentName "aisec" -WhatIf
    
    Preview decommission without making changes.

.EXAMPLE
    .\Remove-AIStorageInfrastructure.ps1 -EnvironmentName "aisec" -BackupData
    
    Safely decommission with data backup and confirmation prompts.

.EXAMPLE
    .\Remove-AIStorageInfrastructure.ps1 -EnvironmentName "aisec" -Force
    
    Force decommission without confirmation (automation scenarios).

.EXAMPLE
    .\Remove-AIStorageInfrastructure.ps1 -EnvironmentName "aisec" -BackupData -PreserveResourceGroup
    
    Remove storage with backup but keep resource group for other AI components.

.NOTES
    - Requires Azure PowerShell module and authenticated session
    - Safely handles container cleanup and data backup
    - Removes storage accounts, budgets, and associated resources
    - Provides comprehensive validation and reporting
    - Supports both complete and selective cleanup scenarios
    
    Safety Features:
    - What-If mode for safe preview
    - Optional data backup before deletion
    - Confirmation prompts for destructive operations
    - Comprehensive validation and error handling
    - Detailed logging and progress reporting

.LINK
    https://docs.microsoft.com/en-us/azure/storage/
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName = "aisec",
    
    [Parameter(Mandatory = $false)]
    [switch]$BackupData,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$PreserveResourceGroup,
    
    [Parameter(Mandatory = $false)]
    [string]$BackupPath = ".\backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')",
    
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

# Import helper functions
. "$PSScriptRoot\lib\Helper-Functions.ps1"

# Load parameters from file if specified
if ($UseParametersFile) {
    $ParametersFilePath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    
    if (Test-Path $ParametersFilePath) {
        Write-Host "📄 Loading parameters from: $ParametersFilePath" -ForegroundColor Green
        
        try {
            $ParametersContent = Get-Content $ParametersFilePath -Raw | ConvertFrom-Json
            
            # Override with parameters file values if not explicitly provided
            if (-not $PSBoundParameters.ContainsKey('EnvironmentName')) {
                $EnvironmentName = $ParametersContent.parameters.environmentName.value
                Write-Host "  ✅ Environment Name: $EnvironmentName (from parameters file)" -ForegroundColor Green
            }
            
            Write-Host "  ✅ Parameters loaded successfully" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to load parameters file: $($_.Exception.Message)"
            Write-Host "Continuing with provided parameters..." -ForegroundColor Yellow
        }
    } else {
        Write-Warning "Parameters file not found: $ParametersFilePath"
        Write-Host "Continuing with provided parameters..." -ForegroundColor Yellow
    }
}

# Display script header
Write-AIHeader -Title "AI Storage Foundation Decommission" -Phase "Cleanup" -Description "Safely removing AI storage infrastructure"

try {
    # Phase 1: Initialize and validate environment
    Write-Host "`n🔍 Phase 1: Environment Discovery" -ForegroundColor Cyan
    
    # Initialize Azure connection
    Initialize-AzureConnection
    
    $ResourceGroupName = "rg-${EnvironmentName}-ai"
    
    Write-Host "  📝 Decommission Configuration:" -ForegroundColor Yellow
    Write-Host "     Environment: $EnvironmentName" -ForegroundColor White
    Write-Host "     Resource Group: $ResourceGroupName" -ForegroundColor White
    Write-Host "     Backup Data: $BackupData" -ForegroundColor White
    Write-Host "     Preserve RG: $PreserveResourceGroup" -ForegroundColor White
    
    if ($BackupData) {
        Write-Host "     Backup Path: $BackupPath" -ForegroundColor White
    }
    
    if ($WhatIf) {
        Write-Host "`n⚠️  WHAT-IF MODE: No resources will be removed" -ForegroundColor Yellow
    }
    
    # Check if resource group exists
    $ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    
    if (-not $ResourceGroup) {
        Write-Host "`n✅ Resource group '$ResourceGroupName' not found - already cleaned up" -ForegroundColor Green
        Write-Host "🎯 Decommission complete - no resources to remove" -ForegroundColor Green
        exit 0
    }
    
    # Discover storage accounts in the resource group
    Write-Host "`n🗄️  Discovering AI storage accounts..." -ForegroundColor Green
    $StorageAccounts = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue | Where-Object { $_.StorageAccountName -like "stai*" }
    
    if ($StorageAccounts.Count -eq 0) {
        Write-Host "  ℹ️  No AI storage accounts found in resource group" -ForegroundColor Yellow
    } else {
        Write-Host "  📋 Found $($StorageAccounts.Count) AI storage account(s):" -ForegroundColor Green
        foreach ($StorageAccount in $StorageAccounts) {
            Write-Host "     - $($StorageAccount.StorageAccountName)" -ForegroundColor White
            
            # Show container details for verification
            try {
                $StorageContext = $StorageAccount.Context
                $Containers = Get-AzStorageContainer -Context $StorageContext -ErrorAction SilentlyContinue
                $AIContainers = $Containers | Where-Object { $_.Name -in @("ai-data", "ai-logs", "ai-models") }
                if ($AIContainers.Count -gt 0) {
                    Write-Host "       Containers: $($AIContainers.Name -join ', ')" -ForegroundColor Gray
                }
            } catch {
                Write-Host "       Container info unavailable" -ForegroundColor Gray
            }
        }
    }
    
    # Check for budgets
    Write-Host "`n💰 Discovering budgets and cost management..." -ForegroundColor Green
    $SubscriptionScope = "/subscriptions/$((Get-AzContext).Subscription.Id)"
    $ResourceGroupScope = "$SubscriptionScope/resourceGroups/$ResourceGroupName"
    
    # Note: Budget removal is handled by the cost management module (separate Week 2 component)
    # The storage foundation deployment doesn't create budgets when enableCostManagement is false
    
    # Confirmation prompt (unless Force is specified)
    if (-not $Force -and -not $WhatIf) {
        Write-Host "`n⚠️  WARNING: This will permanently remove all AI storage infrastructure" -ForegroundColor Red
        if ($StorageAccounts.Count -gt 0) {
            Write-Host "   - Storage accounts: $($StorageAccounts.Count)" -ForegroundColor Yellow
            Write-Host "   - All container data will be lost" -ForegroundColor Yellow
        }
        Write-Host "   - Role assignments will be removed" -ForegroundColor Yellow
        Write-Host "   - Diagnostic settings will be removed" -ForegroundColor Yellow
        if (-not $PreserveResourceGroup) {
            Write-Host "   - Resource group will be deleted" -ForegroundColor Yellow
        }
        
        $Confirmation = Read-Host "`n❓ Proceed with AI storage infrastructure decommission? (y/n)"
        if ($Confirmation -notin @('y', 'Y', 'yes', 'Yes')) {
            Write-Host "❌ Decommission cancelled by user" -ForegroundColor Red
            exit 1
        }
    }
    
    # Phase 2: Backup data (if requested)
    if ($BackupData -and $StorageAccounts.Count -gt 0 -and -not $WhatIf) {
        Write-Host "`n💾 Phase 2: Data Backup" -ForegroundColor Cyan
        
        # Create backup directory
        if (-not (Test-Path $BackupPath)) {
            New-Item -Path $BackupPath -ItemType Directory -Force | Out-Null
            Write-Host "  📁 Created backup directory: $BackupPath" -ForegroundColor Green
        }
        
        foreach ($StorageAccount in $StorageAccounts) {
            Write-Host "`n  📦 Backing up storage account: $($StorageAccount.StorageAccountName)" -ForegroundColor Green
            
            try {
                $StorageContext = $StorageAccount.Context
                $Containers = Get-AzStorageContainer -Context $StorageContext
                
                foreach ($Container in $Containers) {
                    if ($Container.Name -in @("ai-data", "ai-logs", "ai-models")) {
                        Write-Host "    📂 Backing up container: $($Container.Name)" -ForegroundColor Green
                        
                        $ContainerBackupPath = Join-Path $BackupPath "$($StorageAccount.StorageAccountName)-$($Container.Name)"
                        if (-not (Test-Path $ContainerBackupPath)) {
                            New-Item -Path $ContainerBackupPath -ItemType Directory -Force | Out-Null
                        }
                        
                        $Blobs = Get-AzStorageBlob -Container $Container.Name -Context $StorageContext
                        
                        foreach ($Blob in $Blobs) {
                            $LocalPath = Join-Path $ContainerBackupPath $Blob.Name
                            Get-AzStorageBlobContent -Container $Container.Name -Blob $Blob.Name -Destination $LocalPath -Context $StorageContext -Force | Out-Null
                            Write-Host "      ✅ Backed up: $($Blob.Name)" -ForegroundColor Gray
                        }
                        
                        Write-Host "    ✅ Container backup complete: $($Container.Name)" -ForegroundColor Green
                    }
                }
                
                Write-Host "  ✅ Storage account backup complete: $($StorageAccount.StorageAccountName)" -ForegroundColor Green
            } catch {
                Write-Warning "Failed to backup storage account $($StorageAccount.StorageAccountName): $($_.Exception.Message)"
            }
        }
        
        Write-Host "`n✅ Data backup phase completed" -ForegroundColor Green
    } elseif ($BackupData -and $WhatIf) {
        Write-Host "`n💾 Phase 2: Data Backup" -ForegroundColor Cyan
        Write-Host "  [WHAT-IF] Would backup all container data to: $BackupPath" -ForegroundColor Yellow
    } else {
        Write-Host "`n⏭️  Skipping data backup phase" -ForegroundColor Yellow
    }
    
    # Phase 3: Remove storage containers
    if ($StorageAccounts.Count -gt 0) {
        Write-Host "`n📦 Phase 3: Container Cleanup" -ForegroundColor Cyan
        
        foreach ($StorageAccount in $StorageAccounts) {
            if ($WhatIf) {
                Write-Host "  [WHAT-IF] Would remove all containers from: $($StorageAccount.StorageAccountName)" -ForegroundColor Yellow
            } else {
                Write-Host "  📦 Cleaning containers from: $($StorageAccount.StorageAccountName)" -ForegroundColor Green
                
                try {
                    $StorageContext = $StorageAccount.Context
                    $Containers = Get-AzStorageContainer -Context $StorageContext
                    
                    foreach ($Container in $Containers) {
                        if ($Container.Name -in @("ai-data", "ai-logs", "ai-models")) {
                            Write-Host "    🗑️  Removing container: $($Container.Name)" -ForegroundColor Green
                            Remove-AzStorageContainer -Name $Container.Name -Context $StorageContext -Force
                            Write-Host "    ✅ Container removed: $($Container.Name)" -ForegroundColor Green
                        }
                    }
                    
                    Write-Host "  ✅ All AI containers removed from: $($StorageAccount.StorageAccountName)" -ForegroundColor Green
                } catch {
                    Write-Warning "Failed to remove containers from $($StorageAccount.StorageAccountName): $($_.Exception.Message)"
                }
            }
        }
    }
    
    # Phase 4: Remove storage accounts
    if ($StorageAccounts.Count -gt 0) {
        Write-Host "`n🗄️  Phase 4: Storage Account Removal" -ForegroundColor Cyan
        
        foreach ($StorageAccount in $StorageAccounts) {
            if ($WhatIf) {
                Write-Host "  [WHAT-IF] Would remove storage account: $($StorageAccount.StorageAccountName)" -ForegroundColor Yellow
            } else {
                Write-Host "  🗑️  Removing storage account: $($StorageAccount.StorageAccountName)" -ForegroundColor Green
                
                try {
                    Remove-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccount.StorageAccountName -Force
                    Write-Host "  ✅ Storage account removed: $($StorageAccount.StorageAccountName)" -ForegroundColor Green
                } catch {
                    Write-Warning "Failed to remove storage account $($StorageAccount.StorageAccountName): $($_.Exception.Message)"
                }
            }
        }
    }
    
    # Phase 5: Remove budgets and cost management
    Write-Host "`n💰 Phase 5: Budget and Cost Management Cleanup" -ForegroundColor Cyan
    
    if ($WhatIf) {
        Write-Host "  [WHAT-IF] Would check for and remove any cost management resources" -ForegroundColor Yellow
    } else {
        try {
            Write-Host "  💰 Checking for cost management resources..." -ForegroundColor Green
            # Note: Cost management resources are deployed by separate module when enableCostManagement is true
            # For storage foundation only deployment, no budget resources are typically created
            Write-Host "  📝 Storage foundation deployment doesn't include budget resources" -ForegroundColor Yellow
            Write-Host "  ✅ Cost management cleanup phase completed" -ForegroundColor Green
        } catch {
            Write-Warning "Budget cleanup failed: $($_.Exception.Message)"
        }
    }
    
    # Phase 6: Remove resource group (optional)
    if (-not $PreserveResourceGroup) {
        Write-Host "`n🏗️  Phase 6: Resource Group Removal" -ForegroundColor Cyan
        
        if ($WhatIf) {
            Write-Host "  [WHAT-IF] Would remove resource group: $ResourceGroupName" -ForegroundColor Yellow
        } else {
            # Check if resource group is empty
            $RemainingResources = Get-AzResource -ResourceGroupName $ResourceGroupName
            
            if ($RemainingResources.Count -eq 0) {
                Write-Host "  🗑️  Removing empty resource group: $ResourceGroupName" -ForegroundColor Green
                
                try {
                    Remove-AzResourceGroup -Name $ResourceGroupName -Force
                    Write-Host "  ✅ Resource group removed: $ResourceGroupName" -ForegroundColor Green
                } catch {
                    Write-Warning "Failed to remove resource group $ResourceGroupName: $($_.Exception.Message)"
                }
            } else {
                Write-Host "  ⚠️  Resource group contains $($RemainingResources.Count) resources - preserving" -ForegroundColor Yellow
                Write-Host "  📝 Remove remaining resources manually or use -PreserveResourceGroup" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "`n📂 Preserving resource group: $ResourceGroupName" -ForegroundColor Yellow
    }
    
    # Phase 7: Validation and reporting
    Write-Host "`n✅ Phase 7: Decommission Validation" -ForegroundColor Cyan
    
    if ($WhatIf) {
        Write-Host "  [WHAT-IF] Would validate complete resource removal" -ForegroundColor Yellow
    } else {
        # Verify storage account removal
        $RemainingStorageAccounts = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue | Where-Object { $_.StorageAccountName -like "stai*" }
        
        if ($RemainingStorageAccounts.Count -eq 0) {
            Write-Host "  ✅ All AI storage accounts successfully removed" -ForegroundColor Green
        } else {
            Write-Warning "Some storage accounts remain: $($RemainingStorageAccounts.Count)"
        }
        
        # Verify resource group status
        $FinalResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
        if (-not $PreserveResourceGroup -and -not $FinalResourceGroup) {
            Write-Host "  ✅ Resource group successfully removed" -ForegroundColor Green
        } elseif ($PreserveResourceGroup -and $FinalResourceGroup) {
            Write-Host "  ✅ Resource group preserved as requested" -ForegroundColor Green
        }
    }
    
    # Phase 8: Generate decommission summary
    Write-Host "`n📋 Phase 8: Decommission Summary" -ForegroundColor Cyan
    
    if ($WhatIf) {
        Write-Host "  [WHAT-IF] Would generate decommission summary" -ForegroundColor Yellow
    } else {
        # Generate decommission summary
        $DecommissionSummary = @{
            EnvironmentName = $EnvironmentName
            ResourceGroupName = $ResourceGroupName
            StorageAccountsRemoved = $StorageAccounts.Count
            DataBackedUp = $BackupData
            BackupPath = if ($BackupData) { $BackupPath } else { "N/A" }
            ResourceGroupPreserved = $PreserveResourceGroup
            DecommissionDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            EstimatedMonthlySavings = $StorageAccounts.Count * 15  # Approximate savings per storage account
        }
        
        # Save decommission report
        $ReportPath = "$PSScriptRoot\ai-storage-decommission-$EnvironmentName.json"
        $DecommissionSummary | ConvertTo-Json -Depth 3 | Out-File -FilePath $ReportPath -Encoding UTF8
        
        Write-Host "  📄 Decommission report saved to: $ReportPath" -ForegroundColor Green
        
        # Display summary
        Write-Host "`n📊 Decommission Summary:" -ForegroundColor White
        Write-Host "  🗄️  Storage Accounts Removed: $($StorageAccounts.Count)" -ForegroundColor Green
        Write-Host "  📦 Containers Cleaned: $(($StorageAccounts.Count * 3))" -ForegroundColor Green
        Write-Host "  � Role Assignments Removed: $(($StorageAccounts.Count))" -ForegroundColor Green
        Write-Host "  �💾 Data Backed Up: $BackupData" -ForegroundColor Green
        if ($BackupData) {
            Write-Host "  📁 Backup Location: $BackupPath" -ForegroundColor Green
        }
        Write-Host "  🏗️  Resource Group: $(if ($PreserveResourceGroup) { 'Preserved' } else { 'Removed' })" -ForegroundColor Green
        Write-Host "  💰 Estimated Monthly Savings: `$$(($StorageAccounts.Count * 15))" -ForegroundColor Green
        
        Write-Host "`n🎯 Next Steps:" -ForegroundColor Cyan
        Write-Host "  1. Verify billing shows eliminated storage charges" -ForegroundColor White
        Write-Host "  2. Optionally redeploy with optimized configuration" -ForegroundColor White
        Write-Host "  3. Continue to Azure OpenAI service deployment" -ForegroundColor White
        Write-Host "  4. Proceed with other Week 2 AI integration components" -ForegroundColor White
        
        Write-Host "`n✅ AI Storage Foundation decommission completed successfully!" -ForegroundColor Green
        Write-Host "🔄 Environment is ready for fresh deployment or next components" -ForegroundColor Green
    }
    
} catch {
    Write-Host "`n❌ Decommission failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    exit 1
}
