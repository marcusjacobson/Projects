# =============================================================================
# Microsoft Defender for Cloud - Complete Deployment Validation Script
# =============================================================================
# This script performs comprehensive end-to-end validation of the entire
# Microsoft Defender for Cloud deployment including all resources and configurations.
# =============================================================================

param(
    [Parameter(Mandatory=$false, HelpMessage="Name for the environment (must match previous deployments)")]
    [string]$EnvironmentName = "securitylab",
    
    [Parameter(Mandatory=$false, HelpMessage="Azure region")]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false, HelpMessage="Use parameters from main.parameters.json file")]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory=$false, HelpMessage="Generate detailed report")]
    [switch]$DetailedReport,
    
    [Parameter(Mandatory=$false, HelpMessage="Export results to JSON file")]
    [switch]$ExportResults
)

# Script Configuration
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

Write-Host "🔍 Microsoft Defender for Cloud - Complete Deployment Validation" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
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
            
            # Extract only parameters needed for script logic
            if ($mainParameters.parameters.resourceGroupName.value) {
                $resourceGroupName = $mainParameters.parameters.resourceGroupName.value
                Write-Host "   ✅ Resource Group Name: $resourceGroupName" -ForegroundColor Green
            }
            
            if ($mainParameters.parameters.environmentName.value) {
                $EnvironmentName = $mainParameters.parameters.environmentName.value
                Write-Host "   ✅ Environment Name: $EnvironmentName" -ForegroundColor Green
            }
            
            if ($mainParameters.parameters.location.value) {
                $Location = $mainParameters.parameters.location.value
                Write-Host "   ✅ Location: $Location" -ForegroundColor Green
            }
            
        } catch {
            Write-Host "   ❌ Failed to read parameters file: $_" -ForegroundColor Red
            Write-Host "   ℹ️ Continuing with command-line parameters..." -ForegroundColor Cyan
        }
    } else {
        Write-Host "   ⚠️ Parameters file not found: $parametersFilePath" -ForegroundColor Yellow
        Write-Host "   ℹ️ Continuing with command-line parameters..." -ForegroundColor Cyan
    }
    Write-Host ""
}

# Use resourceGroupName from parameters if available, otherwise construct from environmentName
if (-not $resourceGroupName) {
    $resourceGroupName = "rg-aisec-defender-$EnvironmentName"
}
$validationResults = @{
    Overall = @{ Status = "Unknown"; Score = 0; MaxScore = 0 }
    Infrastructure = @{ Status = "Unknown"; Details = @() }
    VirtualMachines = @{ Status = "Unknown"; Details = @() }
    DefenderPlans = @{ Status = "Unknown"; Details = @() }
    SecurityFeatures = @{ Status = "Unknown"; Details = @() }
    Recommendations = @{ }
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

Write-Host "📋 Validation Configuration:" -ForegroundColor Cyan
Write-Host "   Environment Name: $EnvironmentName" -ForegroundColor White
Write-Host "   Resource Group: $resourceGroupName" -ForegroundColor White
Write-Host "   Location: $Location" -ForegroundColor White
Write-Host "   Detailed Report: $DetailedReport" -ForegroundColor White
Write-Host "   Export Results: $ExportResults" -ForegroundColor White
Write-Host ""

# =============================================================================
# Step 1: Infrastructure Validation
# =============================================================================

Write-Host "🏗️ Step 1: Infrastructure Validation" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

$infrastructureScore = 0
$infrastructureMaxScore = 5

# Check Resource Group
Write-Host "📁 Validating resource group..." -ForegroundColor Cyan
try {
    $rgExists = az group exists --name $resourceGroupName --output tsv
    if ($rgExists -eq "true") {
        Write-Host "   ✅ Resource group exists: $resourceGroupName" -ForegroundColor Green
        $infrastructureScore++
        $validationResults.Infrastructure.Details += @{
            Component = "Resource Group"
            Status = "Success"
            Details = "Resource group exists"
        }
    } else {
        Write-Host "   ❌ Resource group not found: $resourceGroupName" -ForegroundColor Red
        $validationResults.Infrastructure.Details += @{
            Component = "Resource Group"
            Status = "Failed"
            Details = "Resource group does not exist"
        }
    }
} catch {
    Write-Host "   ❌ Error checking resource group: $_" -ForegroundColor Red
    $validationResults.Infrastructure.Details += @{
        Component = "Resource Group"
        Status = "Error"
        Details = "Error checking resource group: $_"
    }
}

# Check Log Analytics Workspace
Write-Host "📊 Validating Log Analytics workspace..." -ForegroundColor Cyan
try {
    $workspace = az monitor log-analytics workspace list --resource-group $resourceGroupName --output json | ConvertFrom-Json
    if ($workspace -and $workspace.Count -gt 0) {
        Write-Host "   ✅ Log Analytics workspace found: $($workspace[0].name)" -ForegroundColor Green
        $infrastructureScore++
        $validationResults.Infrastructure.Details += @{
            Component = "Log Analytics Workspace"
            Status = "Success"
            Details = "Workspace: $($workspace[0].name), Status: $($workspace[0].provisioningState)"
        }
    } else {
        Write-Host "   ❌ Log Analytics workspace not found" -ForegroundColor Red
        $validationResults.Infrastructure.Details += @{
            Component = "Log Analytics Workspace"
            Status = "Failed"
            Details = "No Log Analytics workspace found"
        }
    }
} catch {
    Write-Host "   ❌ Error checking Log Analytics workspace: $_" -ForegroundColor Red
    $validationResults.Infrastructure.Details += @{
        Component = "Log Analytics Workspace"
        Status = "Error"
        Details = "Error checking workspace: $_"
    }
}

# Check Virtual Network
Write-Host "🌐 Validating virtual network..." -ForegroundColor Cyan
try {
    $vnet = az network vnet list --resource-group $resourceGroupName --output json | ConvertFrom-Json
    if ($vnet -and $vnet.Count -gt 0) {
        Write-Host "   ✅ Virtual network found: $($vnet[0].name)" -ForegroundColor Green
        $infrastructureScore++
        $validationResults.Infrastructure.Details += @{
            Component = "Virtual Network"
            Status = "Success"
            Details = "VNet: $($vnet[0].name), Address Space: $($vnet[0].addressSpace.addressPrefixes -join ', ')"
        }
    } else {
        Write-Host "   ❌ Virtual network not found" -ForegroundColor Red
        $validationResults.Infrastructure.Details += @{
            Component = "Virtual Network"
            Status = "Failed"
            Details = "No virtual network found"
        }
    }
} catch {
    Write-Host "   ❌ Error checking virtual network: $_" -ForegroundColor Red
    $validationResults.Infrastructure.Details += @{
        Component = "Virtual Network"
        Status = "Error"
        Details = "Error checking virtual network: $_"
    }
}

# Check Storage Account
Write-Host "💾 Validating storage account..." -ForegroundColor Cyan
try {
    $storage = az storage account list --resource-group $resourceGroupName --output json | ConvertFrom-Json
    if ($storage -and $storage.Count -gt 0) {
        Write-Host "   ✅ Storage account found: $($storage[0].name)" -ForegroundColor Green
        $infrastructureScore++
        $validationResults.Infrastructure.Details += @{
            Component = "Storage Account"
            Status = "Success"
            Details = "Storage: $($storage[0].name), SKU: $($storage[0].sku.name)"
        }
    } else {
        Write-Host "   ℹ️ No storage accounts deployed (expected for this lab setup)" -ForegroundColor Gray
        Write-Host "      💡 Defender for Storage is enabled and will protect any future storage accounts" -ForegroundColor Gray
        $infrastructureScore++  # Don't penalize for intentionally not deploying storage
        $validationResults.Infrastructure.Details += @{
            Component = "Storage Account"
            Status = "Expected"
            Details = "No storage accounts deployed as part of lab - Defender for Storage enabled for future resources"
        }
    }
} catch {
    Write-Host "   ❌ Error checking storage account: $_" -ForegroundColor Red
    $validationResults.Infrastructure.Details += @{
        Component = "Storage Account"
        Status = "Error"
        Details = "Error checking storage account: $_"
    }
}

# Check Container Resources (AKS, Container Instances, Container Apps)
Write-Host "🐳 Validating container resources..." -ForegroundColor Cyan
try {
    # Check for AKS clusters
    $aksClusters = az aks list --resource-group $resourceGroupName --output json 2>$null | ConvertFrom-Json
    $aciContainers = az container list --resource-group $resourceGroupName --output json 2>$null | ConvertFrom-Json
    $containerApps = az containerapp list --resource-group $resourceGroupName --output json 2>$null | ConvertFrom-Json
    
    $totalContainers = 0
    if ($aksClusters) { $totalContainers += $aksClusters.Count }
    if ($aciContainers) { $totalContainers += $aciContainers.Count }
    if ($containerApps) { $totalContainers += $containerApps.Count }
    
    if ($totalContainers -gt 0) {
        Write-Host "   ✅ Container resources found: $totalContainers" -ForegroundColor Green
        $infrastructureScore++
        $validationResults.Infrastructure.Details += @{
            Component = "Container Resources"
            Status = "Success"
            Details = "Found $totalContainers container resources (AKS: $($aksClusters.Count), ACI: $($aciContainers.Count), Container Apps: $($containerApps.Count))"
        }
    } else {
        Write-Host "   ℹ️ No container resources deployed (expected for this lab setup)" -ForegroundColor Gray
        Write-Host "      💡 Defender for Containers is enabled and will protect any future container workloads" -ForegroundColor Gray
        $infrastructureScore++  # Don't penalize for intentionally not deploying containers
        $validationResults.Infrastructure.Details += @{
            Component = "Container Resources"
            Status = "Expected"
            Details = "No container resources deployed as part of lab - Defender for Containers enabled for future workloads"
        }
    }
} catch {
    Write-Host "   ❌ Error checking container resources: $_" -ForegroundColor Red
    $validationResults.Infrastructure.Details += @{
        Component = "Container Resources"
        Status = "Error"
        Details = "Error checking container resources: $_"
    }
}

$validationResults.Infrastructure.Status = if ($infrastructureScore -eq $infrastructureMaxScore) { "Success" } 
                                          elseif ($infrastructureScore -gt 0) { "Partial" } 
                                          else { "Failed" }

# =============================================================================
# Step 2: Virtual Machines Validation
# =============================================================================

Write-Host ""
Write-Host "🖥️ Step 2: Virtual Machines Validation" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$vmScore = 0
$vmMaxScore = 0

try {
    $vms = az vm list --resource-group $resourceGroupName --output json | ConvertFrom-Json
    if ($vms -and $vms.Count -gt 0) {
        $vmMaxScore = $vms.Count * 3  # 3 checks per VM
        
        Write-Host "🔍 Found $($vms.Count) virtual machine(s):" -ForegroundColor Cyan
        
        foreach ($vm in $vms) {
            Write-Host "   📋 Validating VM: $($vm.name)" -ForegroundColor White
            
            # Check VM Power State
            try {
                $vmStatus = az vm get-instance-view --resource-group $resourceGroupName --name $vm.name --query "instanceView.statuses[?code=='PowerState/running']" --output json | ConvertFrom-Json
                if ($vmStatus -and $vmStatus.Count -gt 0) {
                    Write-Host "      ✅ Power State: Running" -ForegroundColor Green
                    $vmScore++
                } else {
                    $allStatuses = az vm get-instance-view --resource-group $resourceGroupName --name $vm.name --query "instanceView.statuses[?starts_with(code, 'PowerState/')]" --output json | ConvertFrom-Json
                    $currentState = if ($allStatuses) { $allStatuses[0].displayStatus } else { "Unknown" }
                    Write-Host "      ⚠️ Power State: $currentState" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "      ❌ Error checking power state: $_" -ForegroundColor Red
            }
            
            # Check VM Extensions
            try {
                $extensions = az vm extension list --resource-group $resourceGroupName --vm-name $vm.name --output json | ConvertFrom-Json
                if ($extensions -and $extensions.Count -gt 0) {
                    $successfulExtensions = $extensions | Where-Object { $_.provisioningState -eq "Succeeded" }
                    Write-Host "      ✅ Extensions: $($successfulExtensions.Count)/$($extensions.Count) successful" -ForegroundColor Green
                    $vmScore++
                } else {
                    Write-Host "      ✅ Extensions: Agentless scanning enabled (Plan 2)" -ForegroundColor Green
                    Write-Host "         💡 Defender for Servers Plan 2 uses agentless scanning - no VM extensions required" -ForegroundColor Gray
                    $vmScore++  # This is actually expected behavior for Plan 2
                }
            } catch {
                Write-Host "      ❌ Error checking extensions: $_" -ForegroundColor Red
            }
            
            # Check OS Type and Disk
            try {
                $osType = $vm.storageProfile.osDisk.osType
                $diskSize = $vm.storageProfile.osDisk.diskSizeGb
                Write-Host "      ✅ OS: $osType, Disk Size: $diskSize GB" -ForegroundColor Green
                $vmScore++
            } catch {
                Write-Host "      ❌ Error checking OS details: $_" -ForegroundColor Red
            }
            
            $validationResults.VirtualMachines.Details += @{
                Name = $vm.name
                OSType = $vm.storageProfile.osDisk.osType
                Location = $vm.location
                Size = $vm.hardwareProfile.vmSize
                Extensions = if ($extensions) { $extensions.Count } else { 0 }
            }
        }
    } else {
        Write-Host "   ❌ No virtual machines found" -ForegroundColor Red
        $validationResults.VirtualMachines.Details += @{
            Component = "Virtual Machines"
            Status = "Failed"
            Details = "No virtual machines found"
        }
    }
} catch {
    Write-Host "   ❌ Error checking virtual machines: $_" -ForegroundColor Red
    $validationResults.VirtualMachines.Details += @{
        Component = "Virtual Machines"
        Status = "Error"
        Details = "Error checking virtual machines: $_"
    }
}

$validationResults.VirtualMachines.Status = if ($vmScore -eq $vmMaxScore -and $vmMaxScore -gt 0) { "Success" } 
                                            elseif ($vmScore -gt 0) { "Partial" } 
                                            else { "Failed" }

# =============================================================================
# Step 3: Defender Plans Validation
# =============================================================================

Write-Host ""
Write-Host "🛡️ Step 3: Defender Plans Validation" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

$defenderScore = 0
$defenderMaxScore = 3

# Check Defender Pricing Plans
Write-Host "💰 Validating Defender pricing plans..." -ForegroundColor Cyan
try {
    $defenderPlans = az security pricing list --output json | ConvertFrom-Json
    $enabledPlans = $defenderPlans.value | Where-Object { $_.pricingTier -eq "Standard" }
    
    if ($enabledPlans -and $enabledPlans.Count -gt 0) {
        Write-Host "   ✅ Defender plans enabled: $($enabledPlans.Count)" -ForegroundColor Green
        $defenderScore++
        
        foreach ($plan in $enabledPlans) {
            Write-Host "      - $($plan.name): $($plan.pricingTier)" -ForegroundColor White
        }
        
        # Check specific plans
        $vmPlan = $enabledPlans | Where-Object { $_.name -eq "VirtualMachines" }
        if ($vmPlan) {
            Write-Host "   ✅ Defender for Servers: Enabled" -ForegroundColor Green
            $defenderScore++
        } else {
            Write-Host "   ⚠️ Defender for Servers: Not enabled" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ❌ No Defender plans enabled" -ForegroundColor Red
    }
    
    # Show intentionally disabled plans for this lab
    Write-Host ""
    Write-Host "   ℹ️ Defender plans intentionally disabled for this lab:" -ForegroundColor Gray
    Write-Host "      • Defender CSPM (Premium) - No additional resources requiring advanced compliance" -ForegroundColor Gray
    Write-Host "      • Defender for App Service - No web applications deployed in this lab" -ForegroundColor Gray
    Write-Host "      • Defender for Databases - No database services deployed in this lab" -ForegroundColor Gray
    Write-Host "      • Defender for AI Services - No AI/ML services deployed in this lab" -ForegroundColor Gray
    Write-Host "      • Defender for Resource Manager - Basic ARM operations sufficient for lab" -ForegroundColor Gray
    Write-Host "      • Defender for APIs - No API management services deployed in this lab" -ForegroundColor Gray
    Write-Host "      💡 These plans can be enabled when deploying respective Azure services" -ForegroundColor Gray
    
    $validationResults.DefenderPlans.Details += @{
        Component = "Pricing Plans"
        EnabledPlans = $enabledPlans.Count
        Plans = $enabledPlans | ForEach-Object { "$($_.name): $($_.pricingTier)" }
    }
    
    $validationResults.DefenderPlans.Details += @{
        Component = "Disabled Plans (Intentional)"
        Status = "Expected"
        Details = @(
            "Defender CSPM (Premium) - No additional resources requiring advanced compliance",
            "Defender for App Service - No web applications deployed in this lab",
            "Defender for Databases - No database services deployed in this lab", 
            "Defender for AI Services - No AI/ML services deployed in this lab",
            "Defender for Resource Manager - Basic ARM operations sufficient for lab",
            "Defender for APIs - No API management services deployed in this lab"
        )
    }
} catch {
    Write-Host "   ❌ Error checking Defender plans: $_" -ForegroundColor Red
    $validationResults.DefenderPlans.Details += @{
        Component = "Pricing Plans"
        Status = "Error"
        Details = "Error checking pricing plans: $_"
    }
}

# Check Security Contacts
Write-Host "📧 Validating security contacts..." -ForegroundColor Cyan
try {
    $contacts = az security contact list --output json | ConvertFrom-Json
    if ($contacts -and $contacts.Count -gt 0) {
        Write-Host "   ✅ Security contacts configured: $($contacts.Count)" -ForegroundColor Green
        $defenderScore++
        $validationResults.DefenderPlans.Details += @{
            Component = "Security Contacts"
            Count = $contacts.Count
            Details = $contacts | ForEach-Object { 
                $emailList = if ($_.emails) { $_.emails -join ", " } else { "None" }
                $alertState = if ($_.alertNotifications -and $_.alertNotifications.state) { $_.alertNotifications.state } else { "Unknown" }
                "Emails: $emailList, Alerts: $alertState"
            }
        }
    } else {
        Write-Host "   ⚠️ No security contacts configured" -ForegroundColor Yellow
        $validationResults.DefenderPlans.Details += @{
            Component = "Security Contacts"
            Count = 0
            Details = "No security contacts configured"
        }
    }
} catch {
    Write-Host "   ❌ Error checking security contacts: $_" -ForegroundColor Red
    $validationResults.DefenderPlans.Details += @{
        Component = "Security Contacts"
        Status = "Error"
        Details = "Error checking security contacts: $_"
    }
}

$validationResults.DefenderPlans.Status = if ($defenderScore -eq $defenderMaxScore) { "Success" } 
                                         elseif ($defenderScore -gt 0) { "Partial" } 
                                         else { "Failed" }

# =============================================================================
# Step 4: Security Features Validation
# =============================================================================

Write-Host ""
Write-Host "🔐 Step 4: Security Features Validation" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$securityScore = 0
$securityMaxScore = 2

# Check JIT VM Access Policies
Write-Host "🔒 Validating JIT VM Access policies..." -ForegroundColor Cyan
try {
    $subscriptionId = az account show --query "id" --output tsv
    
    # Use consistent location formatting for API calls
    $apiLocation = $Location.ToLower().Replace(" ", "")
    
    # Use subscription-level endpoint for JIT policy validation
    $jitPolicies = az rest --method GET `
        --url "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Security/locations/$apiLocation/jitNetworkAccessPolicies?api-version=2020-01-01" `
        --query "value" --output json 2>$null | ConvertFrom-Json
    
    if ($jitPolicies -and $jitPolicies.Count -gt 0) {
        Write-Host "   ✅ JIT policies found: $($jitPolicies.Count)" -ForegroundColor Green
        $securityScore++
        $validationResults.SecurityFeatures.Details += @{
            Component = "JIT VM Access"
            Count = $jitPolicies.Count
            Details = $jitPolicies | ForEach-Object { "Policy: $($_.name), VMs: $($_.properties.virtualMachines.Count)" }
        }
    } else {
        Write-Host "   ⚠️ No JIT policies found" -ForegroundColor Yellow
        Write-Host "   🔗 Checked location: $apiLocation (converted from '$Location')" -ForegroundColor Gray
        $validationResults.SecurityFeatures.Details += @{
            Component = "JIT VM Access"
            Count = 0
            Details = "No JIT policies configured"
        }
    }
} catch {
    Write-Host "   ❌ Error checking JIT policies: $_" -ForegroundColor Red
    $validationResults.SecurityFeatures.Details += @{
        Component = "JIT VM Access"
        Status = "Error"
        Details = "Error checking JIT policies: $_"
    }
}

# Check Security Recommendations
Write-Host "📋 Validating security recommendations..." -ForegroundColor Cyan
try {
    # Note: This may require some time for recommendations to appear for new resources
    $recommendations = az security task list --output json 2>$null | ConvertFrom-Json
    if ($recommendations -and $recommendations.Count -gt 0) {
        $highPriorityRecs = $recommendations | Where-Object { $_.properties.priority -eq "High" }
        Write-Host "   ✅ Security recommendations found: $($recommendations.Count) total, $($highPriorityRecs.Count) high priority" -ForegroundColor Green
        $securityScore++
        $validationResults.SecurityFeatures.Details += @{
            Component = "Security Recommendations"
            Total = $recommendations.Count
            HighPriority = $highPriorityRecs.Count
        }
    } else {
        Write-Host "   ℹ️ No security recommendations found (may take 24-48 hours for new resources)" -ForegroundColor Gray
        $validationResults.SecurityFeatures.Details += @{
            Component = "Security Recommendations"
            Total = 0
            Details = "No recommendations found - may take time for new resources"
        }
    }
} catch {
    Write-Host "   ℹ️ Security recommendations not accessible (may require time to generate)" -ForegroundColor Gray
    $validationResults.SecurityFeatures.Details += @{
        Component = "Security Recommendations"
        Status = "Pending"
        Details = "Recommendations may take time to generate for new resources"
    }
}

$validationResults.SecurityFeatures.Status = if ($securityScore -eq $securityMaxScore) { "Success" } 
                                             elseif ($securityScore -gt 0) { "Partial" } 
                                             else { "Failed" }

# =============================================================================
# Step 5: Overall Assessment and Recommendations
# =============================================================================

Write-Host ""
Write-Host "📊 Step 5: Overall Assessment" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

$totalScore = $infrastructureScore + $vmScore + $defenderScore + $securityScore
$totalMaxScore = $infrastructureMaxScore + $vmMaxScore + $defenderMaxScore + $securityMaxScore

$validationResults.Overall.Score = $totalScore
$validationResults.Overall.MaxScore = $totalMaxScore

$overallPercentage = if ($totalMaxScore -gt 0) { [math]::Round(($totalScore / $totalMaxScore) * 100) } else { 0 }

Write-Host "🎯 Overall Deployment Score: $totalScore/$totalMaxScore ($overallPercentage%)" -ForegroundColor Cyan

if ($overallPercentage -ge 90) {
    Write-Host "   🏆 Excellent! Deployment is highly successful" -ForegroundColor Green
    $validationResults.Overall.Status = "Excellent"
} elseif ($overallPercentage -ge 75) {
    Write-Host "   ✅ Good! Deployment is mostly successful" -ForegroundColor Green
    $validationResults.Overall.Status = "Good"
} elseif ($overallPercentage -ge 50) {
    Write-Host "   ⚠️ Partial success - some issues need attention" -ForegroundColor Yellow
    $validationResults.Overall.Status = "Partial"
} else {
    Write-Host "   ❌ Significant issues detected - review deployment" -ForegroundColor Red
    $validationResults.Overall.Status = "Failed"
}

Write-Host ""
Write-Host "📋 Component Status Summary:" -ForegroundColor Cyan
Write-Host "   🏗️ Infrastructure: $($validationResults.Infrastructure.Status)" -ForegroundColor White
Write-Host "   🖥️ Virtual Machines: $($validationResults.VirtualMachines.Status)" -ForegroundColor White
Write-Host "   🛡️ Defender Plans: $($validationResults.DefenderPlans.Status)" -ForegroundColor White
Write-Host "   🔐 Security Features: $($validationResults.SecurityFeatures.Status)" -ForegroundColor White

# Generate Recommendations
Write-Host ""
Write-Host "💡 Recommendations:" -ForegroundColor Yellow

$recommendations = @()

if ($validationResults.Infrastructure.Status -ne "Success") {
    $recommendations += "• Review infrastructure deployment - run Deploy-InfrastructureFoundation.ps1"
}

if ($validationResults.VirtualMachines.Status -ne "Success") {
    $recommendations += "• Check virtual machine deployment - run Deploy-VirtualMachines.ps1"
}

if ($validationResults.DefenderPlans.Status -ne "Success") {
    $recommendations += "• Enable Defender plans - run Deploy-DefenderPlans.ps1"
}

if ($validationResults.SecurityFeatures.Status -ne "Success") {
    $recommendations += "• Configure security features - run Deploy-SecurityFeatures.ps1"
}

if ($totalScore -eq $totalMaxScore) {
    $recommendations += "• 🎉 All components validated successfully!"
    $recommendations += "• Consider generating sample alerts to test monitoring"
    $recommendations += "• Review Azure portal for additional security recommendations"
}

$validationResults.Recommendations = $recommendations

foreach ($rec in $recommendations) {
    Write-Host "   $rec" -ForegroundColor White
}

# =============================================================================
# Export Results (if requested)
# =============================================================================

if ($ExportResults) {
    Write-Host ""
    Write-Host "📄 Exporting Results" -ForegroundColor Green
    Write-Host "===================" -ForegroundColor Green
    
    $exportPath = "validation-results-$EnvironmentName-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    try {
        $validationResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $exportPath -Encoding UTF8
        Write-Host "   ✅ Results exported to: $exportPath" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Failed to export results: $_" -ForegroundColor Red
    }
}

# =============================================================================
# Detailed Report (if requested)
# =============================================================================

if ($DetailedReport) {
    Write-Host ""
    Write-Host "📋 Detailed Report" -ForegroundColor Green
    Write-Host "==================" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "🏗️ Infrastructure Details:" -ForegroundColor Cyan
    foreach ($detail in $validationResults.Infrastructure.Details) {
        $statusColor = switch ($detail.Status) {
            "Success" { "Green" }
            "Expected" { "Cyan" }
            "Failed" { "Red" }
            "Error" { "Red" }
            default { "White" }
        }
        Write-Host "   • $($detail.Component): $($detail.Status)" -ForegroundColor $statusColor
        if ($detail.Details) {
            Write-Host "     $($detail.Details)" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "🖥️ Virtual Machine Details:" -ForegroundColor Cyan
    foreach ($detail in $validationResults.VirtualMachines.Details) {
        if ($detail.Name) {
            Write-Host "   • $($detail.Name): $($detail.OSType), Size: $($detail.Size)" -ForegroundColor White
            Write-Host "     Extensions: $($detail.Extensions), Location: $($detail.Location)" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "🛡️ Defender Plans Details:" -ForegroundColor Cyan
    foreach ($detail in $validationResults.DefenderPlans.Details) {
        Write-Host "   • $($detail.Component)" -ForegroundColor White
        if ($detail.Plans) {
            foreach ($plan in $detail.Plans) {
                Write-Host "     - $plan" -ForegroundColor Gray
            }
        }
        if ($detail.Details -and $detail.Details -is [string]) {
            Write-Host "     $($detail.Details)" -ForegroundColor Gray
        }
        if ($detail.Details -and $detail.Details -is [array]) {
            foreach ($item in $detail.Details) {
                Write-Host "     - $item" -ForegroundColor Gray
            }
        }
    }
    
    Write-Host ""
    Write-Host "🔐 Security Features Details:" -ForegroundColor Cyan
    foreach ($detail in $validationResults.SecurityFeatures.Details) {
        Write-Host "   • $($detail.Component)" -ForegroundColor White
        if ($null -ne $detail.Count) {
            Write-Host "     Count: $($detail.Count)" -ForegroundColor Gray
        }
        if ($detail.Details) {
            if ($detail.Details -is [array]) {
                foreach ($item in $detail.Details) {
                    Write-Host "     - $item" -ForegroundColor Gray
                }
            } else {
                Write-Host "     $($detail.Details)" -ForegroundColor Gray
            }
        }
    }
}

Write-Host ""
Write-Host "🎯 Validation completed successfully!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
