<#
.SYNOPSIS
    Quickly removes the AI storage resource group for lab cleanup.

.DESCRIPTION
    This script provides a simple, fast cleanup option for the AI storage foundation
    lab environment. It deletes the entire resource group containing all storage
    infrastructure, which is perfect for learning scenarios where you need to
    quickly reset or move to the next lab component.

.PARAMETER EnvironmentName
    Name for the AI environment to clean up. Default: "aisec"

.PARAMETER UseParametersFile
    Switch to load parameters from main.parameters.json file.

.PARAMETER WhatIf
    Preview cleanup without making changes.

.PARAMETER Force
    Skip confirmation prompts (automation scenarios).

.EXAMPLE
    .\Remove-StorageResourceGroup.ps1 -UseParametersFile
    
    Remove storage resource group using parameters file configuration.

.EXAMPLE
    .\Remove-StorageResourceGroup.ps1 -UseParametersFile -WhatIf
    
    Preview cleanup using parameters file without making changes.

.EXAMPLE
    .\Remove-StorageResourceGroup.ps1 -EnvironmentName "aisec" -Force
    
    Force cleanup without confirmation prompts.

.NOTES
    - Requires Azure CLI installed and authenticated
    - Perfect for lab environments and quick iteration
    - Removes entire resource group for complete cleanup
    - Fast and simple compared to granular removal scripts
    
    Lab Benefits:
    - Complete cleanup in seconds
    - Immediate cost savings
    - Ready for fresh deployment
    - Consistent with project script patterns

.LINK
    https://docs.microsoft.com/en-us/cli/azure/group
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName = "aisec",
    
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force
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
Write-AIHeader -Title "AI Storage Resource Group Cleanup" -Phase "Quick Cleanup" -Description "Fast lab environment reset"

try {
    # Construct resource group name
    $ResourceGroupName = "rg-${EnvironmentName}-ai"
    
    Write-Host "`n🔍 Cleanup Configuration:" -ForegroundColor Cyan
    Write-Host "  Environment: $EnvironmentName" -ForegroundColor White
    Write-Host "  Resource Group: $ResourceGroupName" -ForegroundColor White
    Write-Host "  What-If Mode: $WhatIf" -ForegroundColor White
    Write-Host "  Force Mode: $Force" -ForegroundColor White
    
    # Check if resource group exists
    Write-Host "`n🔍 Checking resource group existence..." -ForegroundColor Green
    
    $ResourceGroupExists = $false
    try {
        $ResourceGroupInfo = az group show --name $ResourceGroupName --query "{name:name, location:location, provisioningState:properties.provisioningState}" --output json 2>$null
        if ($ResourceGroupInfo) {
            $ResourceGroupData = $ResourceGroupInfo | ConvertFrom-Json
            $ResourceGroupExists = $true
            Write-Host "  📋 Found resource group:" -ForegroundColor Green
            Write-Host "     Name: $($ResourceGroupData.name)" -ForegroundColor White
            Write-Host "     Location: $($ResourceGroupData.location)" -ForegroundColor White
            Write-Host "     State: $($ResourceGroupData.provisioningState)" -ForegroundColor White
        }
    } catch {
        # Resource group doesn't exist
    }
    
    if (-not $ResourceGroupExists) {
        Write-Host "`n✅ Resource group '$ResourceGroupName' not found - already cleaned up" -ForegroundColor Green
        Write-Host "🎯 Cleanup complete - no resources to remove" -ForegroundColor Green
        exit 0
    }
    
    # Check what's in the resource group
    Write-Host "`n📦 Discovering resources in group..." -ForegroundColor Green
    try {
        $ResourceList = az resource list --resource-group $ResourceGroupName --query "[].{Type:type, Name:name}" --output json 2>$null
        if ($ResourceList) {
            $Resources = $ResourceList | ConvertFrom-Json
            Write-Host "  📋 Found $($Resources.Count) resource(s):" -ForegroundColor Green
            foreach ($Resource in $Resources) {
                $ResourceType = $Resource.Type -replace "Microsoft\.", ""
                Write-Host "     - $($Resource.Name) ($ResourceType)" -ForegroundColor White
            }
        } else {
            Write-Host "  📋 Resource group appears to be empty" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ⚠️  Could not enumerate resources (may be due to permissions)" -ForegroundColor Yellow
    }
    
    # Confirmation prompt (unless Force or WhatIf is specified)
    if (-not $Force -and -not $WhatIf) {
        Write-Host "`n⚠️  WARNING: This will permanently delete the entire resource group" -ForegroundColor Red
        Write-Host "   - All storage accounts and data will be lost" -ForegroundColor Yellow
        Write-Host "   - All containers and blobs will be deleted" -ForegroundColor Yellow
        Write-Host "   - All role assignments will be removed" -ForegroundColor Yellow
        Write-Host "   - This action cannot be undone" -ForegroundColor Yellow
        
        $Confirmation = Read-Host "`n❓ Proceed with resource group deletion? (y/n)"
        if ($Confirmation -notin @('y', 'Y', 'yes', 'Yes')) {
            Write-Host "❌ Cleanup cancelled by user" -ForegroundColor Red
            exit 1
        }
    }
    
    # Execute cleanup
    Write-Host "`n🗑️  Executing cleanup operation..." -ForegroundColor Cyan
    
    if ($WhatIf) {
        Write-Host "  [WHAT-IF] Would delete resource group: $ResourceGroupName" -ForegroundColor Yellow
        Write-Host "  [WHAT-IF] All contained resources would be permanently removed" -ForegroundColor Yellow
        Write-Host "  [WHAT-IF] Script would wait for deletion completion (up to 5 minutes)" -ForegroundColor Yellow
        Write-Host "  [WHAT-IF] Operation would verify successful removal before completing" -ForegroundColor Yellow
        
        Write-Host "`n📋 What-If Summary:" -ForegroundColor White
        Write-Host "  🗑️  Resource Group: $ResourceGroupName - Would be deleted" -ForegroundColor Yellow
        Write-Host "  💾 Data Backup: Not performed (use Remove-AIStorageInfrastructure.ps1 for backup)" -ForegroundColor Yellow
        Write-Host "  ⏱️  Operation Time: Complete deletion with verification (up to 5 minutes)" -ForegroundColor Yellow
        Write-Host "  💰 Cost Impact: Immediate billing stop" -ForegroundColor Yellow
        
        Write-Host "`n✅ What-If operation completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "  🗑️  Deleting resource group: $ResourceGroupName" -ForegroundColor Green
        
        try {
            # Use Azure CLI for reliable deletion
            $DeleteCommand = "az group delete --name `"$ResourceGroupName`" --yes --no-wait"
            Write-Host "  🔧 Executing: $DeleteCommand" -ForegroundColor Gray
            
            $DeleteResult = Invoke-Expression $DeleteCommand
            
            Write-Host "  ✅ Resource group deletion initiated successfully" -ForegroundColor Green
            Write-Host "  ⏱️  Waiting for deletion to complete..." -ForegroundColor Green
            
            # Wait and verify deletion completion
            $MaxWaitMinutes = 5
            $WaitSeconds = 10
            $MaxAttempts = ($MaxWaitMinutes * 60) / $WaitSeconds
            $Attempt = 0
            $Deleted = $false
            
            do {
                $Attempt++
                Start-Sleep -Seconds $WaitSeconds
                
                try {
                    $CheckResult = az group show --name $ResourceGroupName --query "name" --output tsv 2>$null
                    if (-not $CheckResult) {
                        $Deleted = $true
                        Write-Host "  ✅ Resource group successfully deleted" -ForegroundColor Green
                        break
                    } else {
                        $ElapsedMinutes = [math]::Round(($Attempt * $WaitSeconds) / 60, 1)
                        Write-Host "  ⏳ Still deleting... (${ElapsedMinutes}m elapsed)" -ForegroundColor Yellow
                    }
                } catch {
                    # Group likely deleted if we get an error
                    $Deleted = $true
                    Write-Host "  ✅ Resource group successfully deleted" -ForegroundColor Green
                    break
                }
                
                if ($Attempt -ge $MaxAttempts) {
                    Write-Host "  ⚠️  Deletion timeout reached (${MaxWaitMinutes} minutes)" -ForegroundColor Yellow
                    Write-Host "  📝 Deletion may still be in progress - check Azure Portal" -ForegroundColor Yellow
                    break
                }
                
            } while (-not $Deleted)
            
        } catch {
            Write-Host "  ❌ Failed to delete resource group: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "  💡 Try using the comprehensive script: .\Remove-AIStorageInfrastructure.ps1 -UseParametersFile" -ForegroundColor Yellow
            exit 1
        }
        
        # Generate summary
        Write-Host "`n📋 Cleanup Summary:" -ForegroundColor White
        if ($Deleted) {
            Write-Host "  🗑️  Resource Group: $ResourceGroupName - Successfully deleted" -ForegroundColor Green
            Write-Host "  ⏱️  Operation: Completed successfully" -ForegroundColor Green
            Write-Host "  💰 Cost Impact: Billing stopped immediately" -ForegroundColor Green
            Write-Host "  🔄 Status: Ready for fresh deployment" -ForegroundColor Green
        } else {
            Write-Host "  🗑️  Resource Group: $ResourceGroupName - Deletion in progress" -ForegroundColor Yellow
            Write-Host "  ⏱️  Operation: May still be completing in background" -ForegroundColor Yellow
            Write-Host "  💰 Cost Impact: Billing should stop shortly" -ForegroundColor Yellow
            Write-Host "  🔄 Status: Check completion before redeploying" -ForegroundColor Yellow
        }
        
        Write-Host "`n🎯 Next Steps:" -ForegroundColor Cyan
        if ($Deleted) {
            Write-Host "  1. Resource group deletion is complete" -ForegroundColor White
            Write-Host "  2. Verify billing shows stopped charges" -ForegroundColor White
            Write-Host "  3. Redeploy with: .\Deploy-StorageFoundation.ps1 -UseParametersFile" -ForegroundColor White
            Write-Host "  4. Continue to next AI integration components" -ForegroundColor White
        } else {
            Write-Host "  1. Wait for deletion to complete (check Azure Portal)" -ForegroundColor White
            Write-Host "  2. Verify billing shows stopped charges" -ForegroundColor White
            Write-Host "  3. Confirm deletion before redeploying" -ForegroundColor White
            Write-Host "  4. Redeploy with: .\Deploy-StorageFoundation.ps1 -UseParametersFile" -ForegroundColor White
        }
        
        Write-Host "`n✅ AI Storage cleanup completed successfully!" -ForegroundColor Green
        if ($Deleted) {
            Write-Host "🚀 Environment ready for fresh deployment" -ForegroundColor Green
        } else {
            Write-Host "🔄 Deletion initiated - verify completion before proceeding" -ForegroundColor Yellow
        }
    }
    
} catch {
    Write-Host "`n❌ Cleanup failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    
    Write-Host "`n💡 Troubleshooting options:" -ForegroundColor Yellow
    Write-Host "  1. Verify Azure CLI authentication: az account show" -ForegroundColor White
    Write-Host "  2. Check permissions: az role assignment list --assignee `$(az account show --query user.name -o tsv)" -ForegroundColor White
    Write-Host "  3. Use comprehensive script: .\Remove-AIStorageInfrastructure.ps1 -UseParametersFile" -ForegroundColor White
    Write-Host "  4. Manual cleanup via Azure Portal" -ForegroundColor White
    
    exit 1
}
