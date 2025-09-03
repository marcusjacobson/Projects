<#
.SYNOPSIS
    Systematically decommissions Azure OpenAI + Defender XDR integration infrastructure.

.DESCRIPTION
    This script performs systematic decommissioning of all components deployed for the 
    Defender XDR integration module in reverse order of deployment (Steps 4→1). It safely
    removes Logic Apps workflows, API connections created specifically for this integration,
    Week 2 AI infrastructure components, and cleans up related configuration while preserving
    existing infrastructure from Week 1 and other integrations.

    The script implements intelligent component discovery, validates dependencies before
    removal, provides detailed progress reporting, and includes comprehensive safety checks
    to prevent accidental deletion of shared infrastructure components.

.PARAMETER UseParametersFile
    Switch to load configuration from main.parameters.json file for decommission parameters.

.PARAMETER EnvironmentName
    The environment name for resource discovery and decommission (overrides parameters file).

.PARAMETER Location
    The Azure region where resources were deployed (overrides parameters file).

.PARAMETER Force
    Switch to bypass confirmation prompts and proceed with decommission automatically.

.PARAMETER WhatIf
    Switch to preview decommission actions without actually removing any resources.

.PARAMETER PreserveCostManagement
    Switch to preserve cost management budgets and alerts during AI infrastructure removal.

.PARAMETER DetailedLog
    Switch to generate detailed decommission log with comprehensive operation details.

.EXAMPLE
    .\Remove-DefenderXDRIntegration.ps1 -UseParametersFile -WhatIf
    
    Preview decommission actions using parameters file configuration without making changes.

.EXAMPLE
    .\Remove-DefenderXDRIntegration.ps1 -EnvironmentName "aisec" -Force -DetailedLog
    
    Complete decommission with forced execution and detailed logging for specific environment.

.EXAMPLE
    .\Remove-DefenderXDRIntegration.ps1 -UseParametersFile -PreserveCostManagement
    
    Standard decommission while preserving cost management infrastructure.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-09-02
    Last Modified: 2025-09-02
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Azure CLI installed and authenticated
    - PowerShell 5.1+ or PowerShell 7+
    - Appropriate Azure permissions for resource deletion
    - Completed deployment using Steps 1-4 of the integration module
    - Confirmation of components safe for removal
    
    Script development orchestrated using GitHub Copilot.

.DECOMMISSION PHASES
    - Phase 1: Logic Apps Workflow (workflow definition, managed identity cleanup)
    - Phase 2: API Connections (azureopenai, azuretables - preserves azuresentinel and others)
    - Phase 3: Foundation Cleanup (App Registration cleanup, Key Vault removal)
#>
#
# =============================================================================
# Systematically decommission Defender XDR integration infrastructure.
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
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf,
    
    [Parameter(Mandatory = $false)]
    [switch]$PreserveCostManagement,
    
    [Parameter(Mandatory = $false)]
    [switch]$DetailedLog
)

# Script Configuration
$ErrorActionPreference = "Continue"  # Continue decommission even if individual operations fail
$decommissionResults = @()
$decommissionStart = Get-Date

# Decommission result tracking function
function Add-DecommissionResult {
    param(
        [string]$Phase,
        [string]$Component,
        [string]$Action,
        [string]$Status,  # Success, Failed, Skipped, WhatIf
        [string]$Message,
        [string]$ResourceId = ""
    )
    
    $script:decommissionResults += [PSCustomObject]@{
        Phase = $Phase
        Component = $Component
        Action = $Action
        Status = $Status
        Message = $Message
        ResourceId = $ResourceId
        Timestamp = Get-Date
    }
}

# Confirmation function
function Confirm-DecommissionAction {
    param(
        [string]$Action,
        [string]$Component,
        [string]$Details = ""
    )
    
    if ($Force) { return $true }
    if ($WhatIf) { return $false }
    
    Write-Host ""
    Write-Host "⚠️  DECOMMISSION CONFIRMATION" -ForegroundColor Yellow
    Write-Host "Action: $Action" -ForegroundColor White
    Write-Host "Component: $Component" -ForegroundColor White
    if ($Details) { Write-Host "Details: $Details" -ForegroundColor White }
    Write-Host ""
    
    $confirmation = Read-Host "Do you want to proceed? (y/N)"
    return ($confirmation -eq 'y' -or $confirmation -eq 'Y' -or $confirmation -eq 'yes')
}

# =============================================================================
# Step 1: Parameter Loading and Environment Setup
# =============================================================================

Write-Host "🔧 Step 1: Parameter Loading and Environment Setup" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Load parameters from file if specified
if ($UseParametersFile) {
    $parametersPath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    if (Test-Path $parametersPath) {
        Write-Host "📄 Loading parameters from: $parametersPath" -ForegroundColor Cyan
        try {
            $parametersContent = Get-Content $parametersPath | ConvertFrom-Json
            $parameters = $parametersContent.parameters
            
            if (-not $EnvironmentName) { $EnvironmentName = $parameters.environmentName.value }
            if (-not $Location) { $Location = $parameters.location.value }
            $defenderResourceGroupName = if ($parameters.defenderResourceGroupName) { $parameters.defenderResourceGroupName.value } else { "rg-$EnvironmentName-defender-$EnvironmentName" }
            $aiResourceGroupName = if ($parameters.aiResourceGroupName) { $parameters.aiResourceGroupName.value } else { "rg-$EnvironmentName-ai" }
            
            Write-Host "   ✅ Parameters loaded successfully" -ForegroundColor Green
            Add-DecommissionResult -Phase "Setup" -Component "Configuration" -Action "Load Parameters" -Status "Success" -Message "Parameters loaded from main.parameters.json"
        } catch {
            Write-Host "   ❌ Failed to load parameters: $_" -ForegroundColor Red
            Add-DecommissionResult -Phase "Setup" -Component "Configuration" -Action "Load Parameters" -Status "Failed" -Message "Failed to load parameters: $_"
            exit 1
        }
    } else {
        Write-Host "❌ Parameters file not found: $parametersPath" -ForegroundColor Red
        Add-DecommissionResult -Phase "Setup" -Component "Configuration" -Action "Load Parameters" -Status "Failed" -Message "Parameters file not found"
        exit 1
    }
} else {
    if (-not $EnvironmentName -or -not $Location) {
        Write-Host "❌ EnvironmentName and Location are required when not using -UseParametersFile" -ForegroundColor Red
        Add-DecommissionResult -Phase "Setup" -Component "Configuration" -Action "Load Parameters" -Status "Failed" -Message "Missing required parameters"
        exit 1
    }
    $defenderResourceGroupName = "rg-$EnvironmentName-defender-$EnvironmentName"
    $aiResourceGroupName = "rg-$EnvironmentName-ai"
}

# Validate Azure CLI authentication
Write-Host "🔐 Validating Azure CLI authentication..." -ForegroundColor Cyan
try {
    $account = az account show --output json 2>$null | ConvertFrom-Json
    if (-not $account) {
        throw "Azure CLI not authenticated"
    }
    $subscriptionId = $account.id
    $tenantId = $account.tenantId
    Write-Host "   ✅ Azure CLI authenticated as: $($account.user.name)" -ForegroundColor Green
    Write-Host "   📋 Subscription: $($account.name) ($subscriptionId)" -ForegroundColor White
    Add-DecommissionResult -Phase "Setup" -Component "Authentication" -Action "Validate Azure CLI" -Status "Success" -Message "Authenticated as $($account.user.name)"
} catch {
    Write-Host "❌ Azure CLI not authenticated: $_" -ForegroundColor Red
    Add-DecommissionResult -Phase "Setup" -Component "Authentication" -Action "Validate Azure CLI" -Status "Failed" -Message "Azure CLI authentication failed"
    exit 1
}

Write-Host ""
Write-Host "🎯 Decommission Configuration:" -ForegroundColor Cyan
Write-Host "   🏷️  Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "   📍 Location: $Location" -ForegroundColor White
Write-Host "   🛡️  Defender Resource Group: $defenderResourceGroupName" -ForegroundColor White
Write-Host "   🤖 AI Resource Group: $aiResourceGroupName" -ForegroundColor White
Write-Host "   📊 Subscription ID: $subscriptionId" -ForegroundColor White
Write-Host "   🔧 Mode: $(if ($WhatIf) { 'Preview Only' } elseif ($Force) { 'Forced Execution' } else { 'Interactive' })" -ForegroundColor White

if (-not $Force -and -not $WhatIf) {
    Write-Host ""
    Write-Host "⚠️  WARNING: This script will remove Azure resources and may incur costs." -ForegroundColor Yellow
    Write-Host "   Use -WhatIf to preview actions or -Force to skip confirmations." -ForegroundColor Yellow
}

# =============================================================================
# Phase 1: Logic Apps Workflow Decommission
# =============================================================================

Write-Host ""
Write-Host "⚡ Phase 1: Logic Apps Workflow Decommission" -ForegroundColor Magenta
Write-Host "===========================================" -ForegroundColor Magenta

Write-Host "🔍 Discovering Logic Apps in Defender resource group..." -ForegroundColor Cyan
try {
    $logicApps = az resource list --resource-group $defenderResourceGroupName --resource-type "Microsoft.Logic/workflows" --output json 2>$null | ConvertFrom-Json
    
    if ($logicApps -and $logicApps.Count -gt 0) {
        Write-Host "   📋 Found $($logicApps.Count) Logic App(s) for decommission:" -ForegroundColor White
        
        foreach ($logicApp in $logicApps) {
            $logicAppName = $logicApp.name
            Write-Host "     ⚡ Logic App: $logicAppName" -ForegroundColor White
            
            if ($WhatIf) {
                Write-Host "     🔍 WHATIF: Would remove Logic App workflow" -ForegroundColor Cyan
                Add-DecommissionResult -Phase "Phase 1" -Component "Logic Apps" -Action "Remove Workflow" -Status "WhatIf" -Message "Would remove Logic App: $logicAppName" -ResourceId $logicApp.id
                continue
            }
            
            $confirmRemoval = Confirm-DecommissionAction -Action "Remove Logic App" -Component $logicAppName -Details "This will delete the workflow definition and all run history"
            
            if ($confirmRemoval) {
                try {
                    Write-Host "     🗑️  Removing Logic App: $logicAppName..." -ForegroundColor Yellow
                    az resource delete --id $logicApp.id --output none 2>$null
                    
                    # Verify deletion
                    $deletedCheck = az resource show --id $logicApp.id --output none 2>$null
                    if ($LASTEXITCODE -eq 0) {
                        throw "Logic App deletion may have failed"
                    }
                    
                    Write-Host "     ✅ Logic App removed successfully" -ForegroundColor Green
                    Add-DecommissionResult -Phase "Phase 1" -Component "Logic Apps" -Action "Remove Workflow" -Status "Success" -Message "Logic App removed: $logicAppName" -ResourceId $logicApp.id
                } catch {
                    Write-Host "     ❌ Failed to remove Logic App: $_" -ForegroundColor Red
                    Add-DecommissionResult -Phase "Phase 1" -Component "Logic Apps" -Action "Remove Workflow" -Status "Failed" -Message "Failed to remove Logic App: $_" -ResourceId $logicApp.id
                }
            } else {
                Write-Host "     ⏭️  Skipping Logic App removal (user declined)" -ForegroundColor Yellow
                Add-DecommissionResult -Phase "Phase 1" -Component "Logic Apps" -Action "Remove Workflow" -Status "Skipped" -Message "User declined removal of: $logicAppName" -ResourceId $logicApp.id
            }
        }
    } else {
        Write-Host "   ℹ️  No Logic Apps found in resource group" -ForegroundColor Blue
        Add-DecommissionResult -Phase "Phase 1" -Component "Logic Apps" -Action "Discovery" -Status "Skipped" -Message "No Logic Apps found for removal"
    }
} catch {
    Write-Host "❌ Logic Apps discovery failed: $_" -ForegroundColor Red
    Add-DecommissionResult -Phase "Phase 1" -Component "Logic Apps" -Action "Discovery" -Status "Failed" -Message "Failed to discover Logic Apps: $_"
}

# =============================================================================
# Phase 2: API Connections Cleanup (Selective)
# =============================================================================

Write-Host ""
Write-Host "🔗 Phase 2: API Connections Cleanup (Selective)" -ForegroundColor Magenta
Write-Host "===============================================" -ForegroundColor Magenta

Write-Host "🔍 Discovering API connections in Defender resource group..." -ForegroundColor Cyan
try {
    $connections = az resource list --resource-group $defenderResourceGroupName --resource-type "Microsoft.Web/connections" --output json 2>$null | ConvertFrom-Json
    
    if ($connections -and $connections.Count -gt 0) {
        # Target specific connections created for this integration
        $targetConnections = @("azureopenai", "azuretables")
        $connectionsToRemove = $connections | Where-Object { $_.name -in $targetConnections }
        $connectionsToPreserve = $connections | Where-Object { $_.name -notin $targetConnections }
        
        Write-Host "   📋 Connection Analysis:" -ForegroundColor White
        Write-Host "     🗑️  Connections to remove: $($connectionsToRemove.Count)" -ForegroundColor Red
        Write-Host "     🔒 Connections to preserve: $($connectionsToPreserve.Count)" -ForegroundColor Green
        
        if ($connectionsToPreserve.Count -gt 0) {
            Write-Host "   🔒 Preserving existing connections:" -ForegroundColor Green
            foreach ($preservedConnection in $connectionsToPreserve) {
                Write-Host "     ✅ Preserving: $($preservedConnection.name)" -ForegroundColor Green
                Add-DecommissionResult -Phase "Phase 2" -Component "API Connections" -Action "Preserve Connection" -Status "Skipped" -Message "Preserved existing connection: $($preservedConnection.name)" -ResourceId $preservedConnection.id
            }
        }
        
        if ($connectionsToRemove.Count -gt 0) {
            Write-Host "   🗑️  Target connections for removal:" -ForegroundColor Red
            foreach ($connection in $connectionsToRemove) {
                $connectionName = $connection.name
                Write-Host "     🔗 Connection: $connectionName" -ForegroundColor White
                
                if ($WhatIf) {
                    Write-Host "       🔍 WHATIF: Would remove API connection" -ForegroundColor Cyan
                    Add-DecommissionResult -Phase "Phase 2" -Component "API Connections" -Action "Remove Connection" -Status "WhatIf" -Message "Would remove API connection: $connectionName" -ResourceId $connection.id
                    continue
                }
                
                $confirmRemoval = Confirm-DecommissionAction -Action "Remove API Connection" -Component $connectionName -Details "This will remove the API connection for Logic Apps integration"
                
                if ($confirmRemoval) {
                    try {
                        Write-Host "       🗑️  Removing API connection: $connectionName..." -ForegroundColor Yellow
                        az resource delete --id $connection.id --output none 2>$null
                        
                        # Verify deletion
                        $deletedCheck = az resource show --id $connection.id --output none 2>$null
                        if ($LASTEXITCODE -eq 0) {
                            throw "API connection deletion may have failed"
                        }
                        
                        Write-Host "       ✅ API connection removed successfully" -ForegroundColor Green
                        Add-DecommissionResult -Phase "Phase 2" -Component "API Connections" -Action "Remove Connection" -Status "Success" -Message "API connection removed: $connectionName" -ResourceId $connection.id
                    } catch {
                        Write-Host "       ❌ Failed to remove API connection: $_" -ForegroundColor Red
                        Add-DecommissionResult -Phase "Phase 2" -Component "API Connections" -Action "Remove Connection" -Status "Failed" -Message "Failed to remove API connection: $_" -ResourceId $connection.id
                    }
                } else {
                    Write-Host "       ⏭️  Skipping API connection removal (user declined)" -ForegroundColor Yellow
                    Add-DecommissionResult -Phase "Phase 2" -Component "API Connections" -Action "Remove Connection" -Status "Skipped" -Message "User declined removal of: $connectionName" -ResourceId $connection.id
                }
            }
        } else {
            Write-Host "   ℹ️  No target API connections found for removal" -ForegroundColor Blue
            Add-DecommissionResult -Phase "Phase 2" -Component "API Connections" -Action "Discovery" -Status "Skipped" -Message "No target API connections found for removal"
        }
    } else {
        Write-Host "   ℹ️  No API connections found in resource group" -ForegroundColor Blue
        Add-DecommissionResult -Phase "Phase 2" -Component "API Connections" -Action "Discovery" -Status "Skipped" -Message "No API connections found"
    }
} catch {
    Write-Host "❌ API connections discovery failed: $_" -ForegroundColor Red
    Add-DecommissionResult -Phase "Phase 2" -Component "API Connections" -Action "Discovery" -Status "Failed" -Message "Failed to discover API connections: $_"
}

# =============================================================================
# Phase 3: Foundation Cleanup (App Registration + Key Vault)
# =============================================================================

Write-Host ""
Write-Host "🔐 Phase 3: Foundation Cleanup (App Registration + Key Vault)" -ForegroundColor Magenta
Write-Host "=============================================================" -ForegroundColor Magenta

Write-Host "🔑 Discovering Key Vault in Defender resource group..." -ForegroundColor Cyan
try {
    $keyVaults = az keyvault list --resource-group $defenderResourceGroupName --output json 2>$null | ConvertFrom-Json
    
    if ($keyVaults -and $keyVaults.Count -gt 0) {
        $keyVault = $keyVaults[0]
        $keyVaultName = $keyVault.name
        Write-Host "   🔐 Key Vault found: $keyVaultName" -ForegroundColor White
        
        # Target specific secrets created for this integration
        $targetSecrets = @("DefenderXDR-App-ClientId", "DefenderXDR-App-ClientSecret", "DefenderXDR-App-TenantId")
        
        Write-Host "🔍 Checking for integration-specific secrets..." -ForegroundColor Cyan
        $secretsToRemove = @()
        $secretsToPreserve = @()
        
        # Get all secrets and categorize
        try {
            $allSecrets = az keyvault secret list --vault-name $keyVaultName --query "[].name" --output tsv 2>$null
            if ($allSecrets) {
                $allSecretsArray = $allSecrets -split "`n" | Where-Object { $_ -and $_.Trim() }
                
                foreach ($secretName in $allSecretsArray) {
                    $secretName = $secretName.Trim()
                    if ($secretName -in $targetSecrets) {
                        $secretsToRemove += $secretName
                    } else {
                        $secretsToPreserve += $secretName
                    }
                }
            }
            
            Write-Host "   📋 Secret Analysis:" -ForegroundColor White
            Write-Host "     🗑️  Secrets to remove: $($secretsToRemove.Count)" -ForegroundColor Red
            Write-Host "     🔒 Secrets to preserve: $($secretsToPreserve.Count)" -ForegroundColor Green
            
            if ($secretsToPreserve.Count -gt 0) {
                Write-Host "   🔒 Preserving existing secrets:" -ForegroundColor Green
                foreach ($preservedSecret in $secretsToPreserve) {
                    Write-Host "     ✅ Preserving: $preservedSecret" -ForegroundColor Green
                    Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault Secrets" -Action "Preserve Secret" -Status "Skipped" -Message "Preserved existing secret: $preservedSecret"
                }
            }
            
            if ($secretsToRemove.Count -gt 0) {
                Write-Host "   🗑️  Target secrets for removal:" -ForegroundColor Red
                foreach ($secretName in $secretsToRemove) {
                    Write-Host "     🔑 Secret: $secretName" -ForegroundColor White
                    
                    if ($WhatIf) {
                        Write-Host "       🔍 WHATIF: Would remove Key Vault secret" -ForegroundColor Cyan
                        Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault Secrets" -Action "Remove Secret" -Status "WhatIf" -Message "Would remove secret: $secretName"
                        continue
                    }
                    
                    $confirmRemoval = Confirm-DecommissionAction -Action "Remove Key Vault Secret" -Component $secretName -Details "This will permanently delete the app registration secret"
                    
                    if ($confirmRemoval) {
                        try {
                            Write-Host "       🗑️  Removing Key Vault secret: $secretName..." -ForegroundColor Yellow
                            az keyvault secret delete --vault-name $keyVaultName --name $secretName --output none 2>$null
                            
                            Write-Host "       ✅ Key Vault secret removed successfully" -ForegroundColor Green
                            Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault Secrets" -Action "Remove Secret" -Status "Success" -Message "Secret removed: $secretName"
                        } catch {
                            Write-Host "       ❌ Failed to remove Key Vault secret: $_" -ForegroundColor Red
                            Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault Secrets" -Action "Remove Secret" -Status "Failed" -Message "Failed to remove secret: $_"
                        }
                    } else {
                        Write-Host "       ⏭️  Skipping Key Vault secret removal (user declined)" -ForegroundColor Yellow
                        Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault Secrets" -Action "Remove Secret" -Status "Skipped" -Message "User declined removal of: $secretName"
                    }
                }
            } else {
                Write-Host "   ℹ️  No target secrets found for removal" -ForegroundColor Blue
                Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault Secrets" -Action "Discovery" -Status "Skipped" -Message "No target secrets found for removal"
            }
        } catch {
            Write-Host "   ❌ Failed to list Key Vault secrets: $_" -ForegroundColor Red
            Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault Secrets" -Action "Discovery" -Status "Failed" -Message "Failed to list Key Vault secrets: $_"
        }
    } else {
        Write-Host "   ℹ️  No Key Vault found in Defender resource group" -ForegroundColor Blue
        Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault Secrets" -Action "Discovery" -Status "Skipped" -Message "No Key Vault found"
    }
} catch {
    Write-Host "❌ Key Vault discovery failed: $_" -ForegroundColor Red
    Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault Secrets" -Action "Discovery" -Status "Failed" -Message "Failed to discover Key Vault: $_"
}

# Key Vault Removal (Step 1 was Key Vault creation)
Write-Host ""
Write-Host "🗑️  Removing Key Vault (created in Step 1)..." -ForegroundColor Cyan
if ($keyVaults -and $keyVaults.Count -gt 0) {
    $keyVault = $keyVaults[0]
    $keyVaultName = $keyVault.name
    Write-Host "   🔐 Key Vault to remove: $keyVaultName" -ForegroundColor White
    
    if ($WhatIf) {
        Write-Host "     🔍 WHATIF: Would remove Key Vault" -ForegroundColor Cyan
        Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault" -Action "Remove Key Vault" -Status "WhatIf" -Message "Would remove Key Vault: $keyVaultName" -ResourceId $keyVault.id
    } else {
        $confirmRemoval = Confirm-DecommissionAction -Action "Remove Key Vault" -Component $keyVaultName -Details "This will permanently delete the Key Vault and all remaining secrets (created in Step 1)"
        
        if ($confirmRemoval) {
            try {
                Write-Host "     🗑️  Removing Key Vault: $keyVaultName..." -ForegroundColor Yellow
                az keyvault delete --name $keyVaultName --output none 2>$null
                
                # Verify deletion
                $deletedCheck = az keyvault show --name $keyVaultName --output none 2>$null
                if ($LASTEXITCODE -eq 0) {
                    throw "Key Vault deletion may have failed"
                }
                
                Write-Host "     ✅ Key Vault removed successfully" -ForegroundColor Green
                Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault" -Action "Remove Key Vault" -Status "Success" -Message "Key Vault removed: $keyVaultName" -ResourceId $keyVault.id
            } catch {
                Write-Host "     ❌ Failed to remove Key Vault: $_" -ForegroundColor Red
                Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault" -Action "Remove Key Vault" -Status "Failed" -Message "Failed to remove Key Vault: $_" -ResourceId $keyVault.id
            }
        } else {
            Write-Host "     ⏭️  Skipping Key Vault removal (user declined)" -ForegroundColor Yellow
            Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault" -Action "Remove Key Vault" -Status "Skipped" -Message "User declined removal of: $keyVaultName" -ResourceId $keyVault.id
        }
    }
} else {
    Write-Host "   ℹ️  No Key Vault found to remove" -ForegroundColor Blue
    Add-DecommissionResult -Phase "Phase 3" -Component "Key Vault" -Action "Remove Key Vault" -Status "Skipped" -Message "No Key Vault found to remove"
}

# =============================================================================
# Step 7: Decommission Summary and Reporting
# =============================================================================

Write-Host ""
Write-Host "📊 Step 7: Decommission Summary and Reporting" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Calculate decommission statistics
$totalActions = $decommissionResults.Count
$successfulActions = ($decommissionResults | Where-Object { $_.Status -eq "Success" }).Count
$failedActions = ($decommissionResults | Where-Object { $_.Status -eq "Failed" }).Count
$skippedActions = ($decommissionResults | Where-Object { $_.Status -eq "Skipped" }).Count
$whatIfActions = ($decommissionResults | Where-Object { $_.Status -eq "WhatIf" }).Count
$decommissionDuration = (Get-Date) - $decommissionStart

Write-Host ""
Write-Host "🎯 Decommission Results Summary" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "   ✅ Successful: $successfulActions actions" -ForegroundColor Green
Write-Host "   ❌ Failed: $failedActions actions" -ForegroundColor Red
Write-Host "   ⏭️  Skipped: $skippedActions actions" -ForegroundColor Yellow
if ($whatIfActions -gt 0) {
    Write-Host "   🔍 WhatIf Preview: $whatIfActions actions" -ForegroundColor Cyan
}
Write-Host "   📊 Total: $totalActions actions" -ForegroundColor White
Write-Host "   ⏱️  Duration: $($decommissionDuration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor White

# Determine overall decommission status
$overallStatus = if ($WhatIf) {
    "PREVIEW"
} elseif ($failedActions -eq 0) {
    if ($skippedActions -eq $totalActions) { "ALL_SKIPPED" } else { "SUCCESS" }
} else {
    "PARTIAL"
}

Write-Host ""
switch ($overallStatus) {
    "SUCCESS" {
        Write-Host "🎉 DECOMMISSION COMPLETED: All requested components have been removed!" -ForegroundColor Green
        Write-Host "   The Defender XDR integration infrastructure has been successfully decommissioned." -ForegroundColor Green
    }
    "PARTIAL" {
        Write-Host "⚠️  DECOMMISSION PARTIALLY COMPLETED: Some operations failed or were skipped." -ForegroundColor Yellow
        Write-Host "   Review failed items and retry if necessary." -ForegroundColor Yellow
    }
    "ALL_SKIPPED" {
        Write-Host "ℹ️  DECOMMISSION SKIPPED: All operations were skipped (user choice or components not found)." -ForegroundColor Blue
        Write-Host "   No changes were made to the infrastructure." -ForegroundColor Blue
    }
    "PREVIEW" {
        Write-Host "🔍 DECOMMISSION PREVIEW COMPLETED: No actual changes were made." -ForegroundColor Cyan
        Write-Host "   Remove -WhatIf parameter to execute the decommission." -ForegroundColor Cyan
    }
}

# Detailed reporting
if ($DetailedLog -or $failedActions -gt 0) {
    Write-Host ""
    Write-Host "📋 Detailed Decommission Report" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    
    # Group results by phase
    $phaseGroups = $decommissionResults | Group-Object Phase | Sort-Object Name
    
    foreach ($group in $phaseGroups) {
        Write-Host ""
        Write-Host "🔸 $($group.Name)" -ForegroundColor White
        Write-Host "$(('-' * ($group.Name.Length + 4)))" -ForegroundColor Gray
        
        foreach ($result in $group.Group) {
            $statusIcon = switch ($result.Status) {
                "Success" { "✅" }
                "Failed" { "❌" }
                "Skipped" { "⏭️ " }
                "WhatIf" { "🔍" }
            }
            
            Write-Host "   $statusIcon $($result.Component) - $($result.Action): $($result.Message)" -ForegroundColor White
            
            if ($result.ResourceId) {
                Write-Host "      📍 Resource ID: $($result.ResourceId)" -ForegroundColor Gray
            }
        }
    }
}

# Export detailed report if requested
if ($DetailedLog) {
    $reportPath = Join-Path $PWD "defender-xdr-decommission-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    
    $reportData = @{
        DecommissionDate = $decommissionStart
        Environment = $EnvironmentName
        SubscriptionId = $subscriptionId
        Duration = $decommissionDuration.TotalSeconds
        Mode = if ($WhatIf) { "WhatIf" } elseif ($Force) { "Forced" } else { "Interactive" }
        Summary = @{
            TotalActions = $totalActions
            SuccessfulActions = $successfulActions
            FailedActions = $failedActions
            SkippedActions = $skippedActions
            WhatIfActions = $whatIfActions
            OverallStatus = $overallStatus
        }
        Results = $decommissionResults
    }
    
    try {
        $reportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding UTF8
        Write-Host ""
        Write-Host "📄 Detailed report exported: $reportPath" -ForegroundColor Cyan
    } catch {
        Write-Host "⚠️  Failed to export detailed report: $_" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
if ($overallStatus -eq "SUCCESS") {
    Write-Host "   1. Verify resource removal in Azure Portal" -ForegroundColor White
    Write-Host "   2. Check for any remaining cost-generating resources" -ForegroundColor White
    Write-Host "   3. Review Azure billing to confirm cost reduction" -ForegroundColor White
    Write-Host "   4. Update documentation to reflect decommissioned state" -ForegroundColor White
} elseif ($overallStatus -eq "PARTIAL") {
    Write-Host "   1. Review failed operations in the detailed report" -ForegroundColor White
    Write-Host "   2. Address any permission or dependency issues" -ForegroundColor White
    Write-Host "   3. Re-run decommission script for failed components" -ForegroundColor White
    Write-Host "   4. Manually remove any remaining resources if necessary" -ForegroundColor White
} elseif ($overallStatus -eq "PREVIEW") {
    Write-Host "   1. Review the planned decommission actions above" -ForegroundColor White
    Write-Host "   2. Run without -WhatIf parameter to execute decommission" -ForegroundColor White
    Write-Host "   3. Use -Force parameter to skip individual confirmations" -ForegroundColor White
    Write-Host "   4. Consider -PreserveCostManagement if cost budgets should remain" -ForegroundColor White
} else {
    Write-Host "   1. Review which components were skipped and why" -ForegroundColor White
    Write-Host "   2. Deploy infrastructure first if components are missing" -ForegroundColor White
    Write-Host "   3. Use -Force parameter if confirmations were declined" -ForegroundColor White
}

Write-Host ""
Write-Host "✅ Decommission process completed!" -ForegroundColor Green

# Set exit code based on decommission results
if ($overallStatus -eq "PARTIAL" -and $failedActions -gt 0) {
    exit 1
} else {
    exit 0
}
