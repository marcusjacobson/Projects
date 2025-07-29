# =============================================================================
# Microsoft Sentinel Infrastructure Validation Script
# =============================================================================
# This script validates Microsoft Sentinel onboarding and tenant-based data 
# connector configuration for the Microsoft Defender for Cloud integration.
# Data flow validation is performed separately using KQL queries after alert generation.
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Name for the environment (matching previous deployment steps)")]
    [string]$EnvironmentName = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory=$false, HelpMessage="Generate detailed validation report")]
    [switch]$DetailedReport
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
            return $null
        }
        
        return ($response | ConvertFrom-Json)
    }
    catch {
        return $null
    }
}

Write-Host "🛡️ Microsoft Sentinel Validation Script" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
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
# Resource Name Construction
# =============================================================================

Write-Host "🏗️ Constructing resource names..." -ForegroundColor Cyan

# Use parameters from file if available, otherwise construct from EnvironmentName
if ($UseParametersFile -and $ResourceGroupName -and $ResourceToken) {
    $resourceGroupName = $ResourceGroupName
    $workspaceName = "log-aisec-defender-$EnvironmentName-$ResourceToken"
} else {
    $resourceGroupName = "rg-aisec-defender-$EnvironmentName"
    $workspaceName = "law-aisec-defender-$EnvironmentName"
}

Write-Host "📋 Target Configuration:" -ForegroundColor Cyan
Write-Host "   Resource Group: $resourceGroupName" -ForegroundColor White
Write-Host "   Log Analytics Workspace: $workspaceName" -ForegroundColor White
Write-Host "   Subscription: $subscriptionId" -ForegroundColor White

# =============================================================================
# Validation Tracking
# =============================================================================

$validationResults = @{
    "LogAnalyticsWorkspace" = @{ "Status" = "Pending"; "Details" = "" }
    "SentinelOnboarding" = @{ "Status" = "Pending"; "Details" = "" }
    "DataConnectorHealth" = @{ "Status" = "Pending"; "Details" = "" }
    "OverallScore" = 0
}

# =============================================================================
# 1. Log Analytics Workspace Validation
# =============================================================================

Write-Host "🔍 Step 1: Validating Log Analytics Workspace..." -ForegroundColor Cyan
try {
    $workspaceUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName" + "?api-version=2021-06-01"
    $workspace = Invoke-AzureRestApi -Method "GET" -Uri $workspaceUri
    
    if ($workspace -and $workspace.properties.provisioningState -eq "Succeeded") {
        Write-Host "✅ Log Analytics Workspace validated successfully" -ForegroundColor Green
        Write-Host "   Location: $($workspace.location)" -ForegroundColor White
        Write-Host "   Provisioning State: $($workspace.properties.provisioningState)" -ForegroundColor White
        $validationResults["LogAnalyticsWorkspace"]["Status"] = "Passed"
        $validationResults["LogAnalyticsWorkspace"]["Details"] = "Workspace operational in $($workspace.location)"
    }
    else {
        Write-Warning "⚠️ Log Analytics Workspace validation failed"
        $validationResults["LogAnalyticsWorkspace"]["Status"] = "Failed"
        $validationResults["LogAnalyticsWorkspace"]["Details"] = "Workspace not found or not in succeeded state"
    }
}
catch {
    Write-Warning "⚠️ Log Analytics Workspace validation error: $($_.Exception.Message)"
    $validationResults["LogAnalyticsWorkspace"]["Status"] = "Failed"
    $validationResults["LogAnalyticsWorkspace"]["Details"] = $_.Exception.Message
}

# =============================================================================
# 2. Microsoft Sentinel Onboarding Validation
# =============================================================================

Write-Host "🔍 Step 2: Validating Microsoft Sentinel onboarding..." -ForegroundColor Cyan
$sentinelUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/onboardingStates/default" + "?api-version=2023-02-01"

try {
    $sentinelState = Invoke-AzureRestApi -Method "GET" -Uri $sentinelUri
    
    if ($sentinelState) {
        Write-Host "✅ Microsoft Sentinel onboarding validated successfully" -ForegroundColor Green
        Write-Host "   Workspace ID: $($sentinelState.properties.workspaceId)" -ForegroundColor White
        Write-Host "   Customer Managed Key: $($sentinelState.properties.customerManagedKey)" -ForegroundColor White
        $validationResults["SentinelOnboarding"]["Status"] = "Passed"
        $validationResults["SentinelOnboarding"]["Details"] = "Sentinel onboarded with workspace ID: $($sentinelState.properties.workspaceId)"
    }
    else {
        Write-Warning "⚠️ Microsoft Sentinel onboarding validation failed"
        $validationResults["SentinelOnboarding"]["Status"] = "Failed"
        $validationResults["SentinelOnboarding"]["Details"] = "Sentinel onboarding state not found"
    }
}
catch {
    Write-Warning "⚠️ Microsoft Sentinel onboarding validation error: $($_.Exception.Message)"
    $validationResults["SentinelOnboarding"]["Status"] = "Failed"
    $validationResults["SentinelOnboarding"]["Details"] = $_.Exception.Message
}

# =============================================================================
# 3. Data Connector Health Validation
# =============================================================================

Write-Host "🔍 Step 3: Validating Defender for Cloud solution and connector status..." -ForegroundColor Cyan
try {
    # First check if the Microsoft Defender for Cloud solution is installed
    $solutionUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/contentPackages" + "?api-version=2023-04-01-preview"
    $solutions = Invoke-AzureRestApi -Method "GET" -Uri $solutionUri
    
    $defenderSolution = $null
    if ($solutions -and $solutions.value) {
        $defenderSolution = $solutions.value | Where-Object { $_.properties.contentId -eq "azuresentinel.azure-sentinel-solution-microsoftdefenderforcloud" }
    }
    
    if ($defenderSolution) {
        Write-Host "✅ Microsoft Defender for Cloud solution installed successfully" -ForegroundColor Green
        Write-Host "   Solution Version: $($defenderSolution.properties.version)" -ForegroundColor White
        
        # Check available data connector templates
        $templatesUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/contentTemplates" + "?api-version=2023-04-01-preview"
        $templates = Invoke-AzureRestApi -Method "GET" -Uri $templatesUri
        
        $tenantBasedTemplate = $null
        $legacyTemplate = $null
        
        if ($templates -and $templates.value) {
            $tenantBasedTemplate = $templates.value | Where-Object { $_.properties.contentId -eq "MicrosoftDefenderForCloudTenantBased" }
            $legacyTemplate = $templates.value | Where-Object { $_.properties.contentId -eq "AzureSecurityCenter" }
        }
        
        if ($tenantBasedTemplate) {
            Write-Host "✅ Tenant-based connector template available" -ForegroundColor Green
            Write-Host "   Template: $($tenantBasedTemplate.properties.displayName)" -ForegroundColor White
        }
        
        if ($legacyTemplate) {
            Write-Host "✅ Legacy connector template available" -ForegroundColor Green
            Write-Host "   Template: $($legacyTemplate.properties.displayName)" -ForegroundColor White
        }
        
        # Now check for active connector instances
        $dataConnectorUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$workspaceName/providers/Microsoft.SecurityInsights/dataConnectors" + "?api-version=2023-04-01-preview"
        $dataConnectors = Invoke-AzureRestApi -Method "GET" -Uri $dataConnectorUri
        
        $hasActiveConnector = $false
        $connectorDetails = @()
        
        if ($dataConnectors -and $dataConnectors.value -and $dataConnectors.value.Count -gt 0) {
            # Look for the modern tenant-based connector
            $tenantBasedConnector = $dataConnectors.value | Where-Object { 
                $_.name -eq "MicrosoftDefenderForCloudTenantBased" -and 
                $_.kind -eq "GenericUI"
            }
            
            # Look for the legacy subscription-based connector  
            $legacyConnector = $dataConnectors.value | Where-Object { 
                $_.name -eq "AzureSecurityCenter" -and 
                $_.kind -eq "StaticUI"
            }
            
            # Look for XDR connector (which may handle MDC alerts too)
            $xdrConnector = $dataConnectors.value | Where-Object { 
                $_.kind -eq "MicrosoftThreatProtection" -and 
                $_.properties.dataTypes.alerts.state -eq "enabled"
            }
            
            if ($tenantBasedConnector) {
                $hasActiveConnector = $true
                Write-Host "✅ Tenant-based Microsoft Defender for Cloud connector found" -ForegroundColor Green
                Write-Host "   Connector Kind: $($tenantBasedConnector.kind)" -ForegroundColor White
                Write-Host "   Configuration: Modern tenant-based solution with XDR integration" -ForegroundColor White
                $connectorDetails += "Tenant-based MDC connector (GenericUI)"
            }
            
            if ($legacyConnector) {
                Write-Host "✅ Legacy subscription-based connector also available" -ForegroundColor Green
                Write-Host "   Connector Kind: $($legacyConnector.kind)" -ForegroundColor White
                $connectorDetails += "Legacy subscription-based connector (StaticUI)"
            }
            
            if ($xdrConnector) {
                Write-Host "✅ Microsoft Defender XDR connector active" -ForegroundColor Green
                Write-Host "   Alerts State: $($xdrConnector.properties.dataTypes.alerts.state)" -ForegroundColor White
                Write-Host "   Incidents State: $($xdrConnector.properties.dataTypes.incidents.state)" -ForegroundColor White
                $connectorDetails += "XDR connector with alert/incident integration"
            }
            
            if (-not $hasActiveConnector -and -not $xdrConnector) {
                # Check for any other Defender for Cloud related connectors
                $anyDefenderConnector = $dataConnectors.value | Where-Object { 
                    $_.name -like "*Defender*" -or 
                    $_.name -like "*SecurityCenter*" -or
                    $_.properties.connectorUiConfig.id -like "*Azure*Security*"
                }
                
                if ($anyDefenderConnector) {
                    Write-Warning "⚠️ Found potential Defender connector but configuration unclear"
                    foreach ($connector in $anyDefenderConnector) {
                        Write-Host "   Found: $($connector.name) (Kind: $($connector.kind))" -ForegroundColor Yellow
                    }
                }
            }
        }
        
        if ($hasActiveConnector -or $xdrConnector) {
            $validationResults["DataConnectorHealth"]["Status"] = "Passed"
            $connectorSummary = $connectorDetails -join ", "
            $validationResults["DataConnectorHealth"]["Details"] = "Defender for Cloud solution installed with active connectors: $connectorSummary"
        }
        else {
            Write-Warning "⚠️ Solution installed but no active data connectors found"
            Write-Host "💡 Next steps:" -ForegroundColor Yellow
            Write-Host "   1. Navigate to: Sentinel → Data connectors" -ForegroundColor White
            Write-Host "   2. Find: 'Tenant-based Microsoft Defender for Cloud'" -ForegroundColor White
            Write-Host "   3. Verify connector shows as 'Connected'" -ForegroundColor White
            $validationResults["DataConnectorHealth"]["Status"] = "Warning"
            $validationResults["DataConnectorHealth"]["Details"] = "Solution installed, templates available, but connector status unclear"
        }
    }
    else {
        Write-Warning "⚠️ Microsoft Defender for Cloud solution not found"
        Write-Host "💡 Install the solution: Sentinel → Content Hub → Search 'Microsoft Defender for Cloud' → Install" -ForegroundColor Yellow
        $validationResults["DataConnectorHealth"]["Status"] = "Warning"
        $validationResults["DataConnectorHealth"]["Details"] = "Solution not installed - install from Content Hub first"
    }
}
catch {
    Write-Warning "⚠️ Data connector validation error: $($_.Exception.Message)"
    $validationResults["DataConnectorHealth"]["Status"] = "Warning"
    $validationResults["DataConnectorHealth"]["Details"] = "Manual portal validation required for solution and connector status"
}

# =============================================================================
# Validation Results Summary
# =============================================================================

Write-Host ""
Write-Host "📊 Validation Results Summary" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

$passedCount = 0
$totalTests = 0

foreach ($test in $validationResults.Keys) {
    if ($test -eq "OverallScore") { continue }
    $totalTests++
    $status = $validationResults[$test]["Status"]
    $details = $validationResults[$test]["Details"]
    
    switch ($status) {
        "Passed" {
            Write-Host "✅ $test`: PASSED" -ForegroundColor Green
            $passedCount++
        }
        "Warning" {
            Write-Host "⚠️ $test`: WARNING" -ForegroundColor Yellow
        }
        "Failed" {
            Write-Host "❌ $test`: FAILED" -ForegroundColor Red
        }
        "Skipped" {
            Write-Host "⏭️ $test`: SKIPPED" -ForegroundColor Gray
        }
    }
    
    if ($DetailedReport) {
        Write-Host "   Details: $details" -ForegroundColor White
    }
}

$validationResults["OverallScore"] = [math]::Round(($passedCount / $totalTests) * 100, 0)

Write-Host ""
Write-Host "🎯 Overall Validation Score: $($validationResults['OverallScore'])%" -ForegroundColor Cyan

if ($validationResults["OverallScore"] -ge 75) {
    Write-Host "✅ Microsoft Sentinel integration is operational!" -ForegroundColor Green
}
elseif ($validationResults["OverallScore"] -ge 50) {
    Write-Host "⚠️ Microsoft Sentinel integration partially operational - review warnings" -ForegroundColor Yellow
}
else {
    Write-Host "❌ Microsoft Sentinel integration requires attention - review failed tests" -ForegroundColor Red
}

# =============================================================================
# Next Steps Guidance
# =============================================================================

Write-Host ""
Write-Host "🔧 Next Steps:" -ForegroundColor Cyan

if ($validationResults["DataConnectorHealth"]["Status"] -ne "Passed") {
    Write-Host "   1. Install Microsoft Defender for Cloud solution from Content Hub" -ForegroundColor White
    Write-Host "      Navigate to: Sentinel → Content management → Content hub → Search 'Microsoft Defender for Cloud'" -ForegroundColor White
    Write-Host "   2. Configure the tenant-based data connector in Azure Portal" -ForegroundColor White
    Write-Host "      Navigate to: Sentinel → Data connectors → Tenant-based Microsoft Defender for Cloud" -ForegroundColor White
}

if ($validationResults["OverallScore"] -ge 67) {
    Write-Host "   ✅ Infrastructure ready - Proceed to Step 7: Generate and Monitor Security Alerts" -ForegroundColor Green
    Write-Host "   📊 Data flow validation will be performed using KQL queries after alert generation" -ForegroundColor White
}
else {
    Write-Host "   ⚠️ Address infrastructure issues before proceeding to alert generation" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Sentinel infrastructure validation completed!" -ForegroundColor Green
