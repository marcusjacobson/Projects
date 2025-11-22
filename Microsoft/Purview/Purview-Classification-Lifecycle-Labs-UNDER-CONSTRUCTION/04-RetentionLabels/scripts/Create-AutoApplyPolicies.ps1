<#
.SYNOPSIS
    Creates auto-apply retention label policies that automatically apply labels based on custom SITs.

.DESCRIPTION
    This script creates auto-apply retention label policies in Microsoft Purview that automatically
    apply retention labels to content when specific custom Sensitive Information Types (SITs) are
    detected. This enables automated data lifecycle management without requiring manual user
    intervention to apply retention labels.
    
    The script integrates with Lab 2's custom SITs to create intelligent auto-apply policies:
    - Financial Records: Auto-applies to content containing Purchase Order SIT patterns
    - Employee Records: Auto-applies to content containing Employee EDM data
    - Customer Data: Auto-applies to content containing Customer Number SIT patterns
    
    Auto-apply policies can operate in simulation mode for testing before full deployment,
    allowing administrators to validate detection accuracy and policy effectiveness before
    automatically applying retention labels to production content.
    
    The script includes comprehensive validation to verify successful policy creation and
    provides detailed feedback throughout the process, including policy priority configuration
    and conflict resolution strategies.

.PARAMETER SimulationMode
    Switch parameter to create auto-apply policies in simulation mode. In simulation mode,
    policies identify content that matches SIT patterns but do NOT automatically apply retention
    labels. This allows testing and validation of policy effectiveness before production deployment.
    
    Simulation mode is recommended for initial testing to ensure policies detect the correct
    content before enabling automatic label application.

.PARAMETER SITNames
    Optional array of custom SIT names to use for auto-apply policy creation. If not specified,
    the script uses default Lab 2 SIT names (Purchase Order, Employee EDM, Customer Number).
    
    Use this parameter to customize policies for different SIT patterns or organizational
    naming conventions.

.PARAMETER Scope
    Optional scope for auto-apply policies. Valid values are "All" (entire organization) or
    "Specific" (requires additional location specification). Default is "All" to apply policies
    organization-wide.

.PARAMETER SkipConnectionTest
    Skip the initial Microsoft 365 connection test. Use this parameter when running multiple
    scripts in sequence where connection has already been established.

.EXAMPLE
    .\Create-AutoApplyPolicies.ps1 -SimulationMode
    
    Creates auto-apply policies in simulation mode using default Lab 2 custom SIT names.
    Policies will identify matching content but not automatically apply retention labels.
    Recommended for initial testing and validation.

.EXAMPLE
    .\Create-AutoApplyPolicies.ps1
    
    Creates auto-apply policies in production mode with automatic label application enabled.
    Policies will automatically apply retention labels when custom SITs are detected.
    Use after validating policy effectiveness in simulation mode.

.EXAMPLE
    .\Create-AutoApplyPolicies.ps1 -SITNames @("Custom-ProjectID", "Custom-EmployeeID") -SimulationMode
    
    Creates auto-apply policies for custom SIT names in simulation mode. Useful for
    organizations with custom naming conventions or additional SIT patterns.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-01-22
    Last Modified: 2025-01-22
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - ExchangeOnlineManagement module version 3.4.0 or higher
    - Microsoft.Purview module version 2.1.0 or higher
    - Security & Compliance PowerShell connection established
    - Appropriate Microsoft Purview permissions (Compliance Administrator or higher)
    - Lab 2 custom SITs must be created before running this script
    - Retention labels must be created (use Create-RetentionLabels.ps1)
    
    Script development orchestrated using GitHub Copilot.

.AUTO-APPLY POLICIES
    Financial Records Policy:
    - Trigger: Purchase Order SIT pattern (PO-####-####-XXXX)
    - Label Applied: LAB3-Financial-7yr (7-year retention)
    - Priority: High (priority 1)
    - Use Case: Automatically retain financial documents for regulatory compliance
    
    Employee Records Policy:
    - Trigger: Employee EDM data store (EmployeeFirstName, EmployeeLastName, SSN)
    - Label Applied: LAB3-HR-5yr (5-year retention with disposition review)
    - Priority: High (priority 2)
    - Use Case: Automatically retain employee data for HR compliance requirements
    
    Customer Data Policy:
    - Trigger: Customer Number SIT pattern (CUST-######)
    - Label Applied: LAB3-General-3yr (3-year retention)
    - Priority: Medium (priority 3)
    - Use Case: Automatically retain customer-related documents

.LINK
    https://learn.microsoft.com/en-us/purview/apply-retention-labels-automatically
    https://learn.microsoft.com/en-us/purview/retention-policies-sharepoint
    https://learn.microsoft.com/en-us/powershell/module/exchange/new-retentioncompliancepolicy
#>

#Requires -Modules ExchangeOnlineManagement

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$SimulationMode,
    
    [Parameter(Mandatory = $false)]
    [string[]]$SITNames = @(
        "LAB2-PurchaseOrder-PO",
        "LAB2-EmployeeData-EDM",
        "LAB2-CustomerNumber-CUST"
    ),
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("All", "Specific")]
    [string]$Scope = "All",
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipConnectionTest
)

# =============================================================================
# Script Initialization
# =============================================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Auto-Apply Policies Creation" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔍 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

# Check required modules
Write-Host "📋 Checking required PowerShell modules..." -ForegroundColor Cyan
$requiredModules = @(
    @{ Name = "ExchangeOnlineManagement"; MinVersion = "3.4.0" }
)

foreach ($module in $requiredModules) {
    $installedModule = Get-Module -Name $module.Name -ListAvailable | 
        Where-Object { $_.Version -ge [version]$module.MinVersion } | 
        Select-Object -First 1
    
    if ($installedModule) {
        Write-Host "   ✅ $($module.Name) version $($installedModule.Version) installed" -ForegroundColor Green
    }
    else {
        Write-Host "   ❌ $($module.Name) version $($module.MinVersion) or higher not found" -ForegroundColor Red
        Write-Host "      Install with: Install-Module -Name $($module.Name) -MinimumVersion $($module.MinVersion) -Force" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""

# Test Security & Compliance connection
if (-not $SkipConnectionTest) {
    Write-Host "📋 Testing Security & Compliance PowerShell connection..." -ForegroundColor Cyan
    
    try {
        # Import module if not already loaded
        if (-not (Get-Module -Name ExchangeOnlineManagement)) {
            Import-Module ExchangeOnlineManagement -ErrorAction Stop
            Write-Host "   ✅ ExchangeOnlineManagement module imported" -ForegroundColor Green
        }
        
        # Test connection by retrieving existing policies (limit to 1 for speed)
        $testConnection = Get-RetentionCompliancePolicy -ResultSize 1 -ErrorAction Stop
        Write-Host "   ✅ Security & Compliance PowerShell connection verified" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ Security & Compliance PowerShell connection failed" -ForegroundColor Red
        Write-Host "      Connect with: Connect-IPPSSession" -ForegroundColor Yellow
        Write-Host "      Error: $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "   ⏭️  Skipping connection test (SkipConnectionTest parameter specified)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Step 1 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 2: Prerequisite Validation
# =============================================================================

Write-Host "🔍 Step 2: Prerequisite Validation" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""

# Validate retention labels exist
Write-Host "📋 Validating required retention labels..." -ForegroundColor Cyan
$requiredLabels = @(
    "LAB3-Financial-7yr",
    "LAB3-HR-5yr",
    "LAB3-General-3yr"
)

$missingLabels = @()
foreach ($labelName in $requiredLabels) {
    $label = Get-ComplianceTag -Identity $labelName -ErrorAction SilentlyContinue
    if ($label) {
        Write-Host "   ✅ Found retention label: $labelName" -ForegroundColor Green
    }
    else {
        Write-Host "   ❌ Missing retention label: $labelName" -ForegroundColor Red
        $missingLabels += $labelName
    }
}

if ($missingLabels.Count -gt 0) {
    Write-Host ""
    Write-Host "   ❌ Required retention labels not found" -ForegroundColor Red
    Write-Host "      Create retention labels first: .\Create-RetentionLabels.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Validate custom SITs exist
Write-Host "📋 Validating required custom SITs..." -ForegroundColor Cyan
$missingSITs = @()

foreach ($sitName in $SITNames) {
    $sit = Get-DlpSensitiveInformationType -Identity $sitName -ErrorAction SilentlyContinue
    if ($sit) {
        Write-Host "   ✅ Found custom SIT: $sitName" -ForegroundColor Green
    }
    else {
        Write-Host "   ⚠️  Custom SIT not found: $sitName" -ForegroundColor Yellow
        $missingSITs += $sitName
    }
}

if ($missingSITs.Count -eq $SITNames.Count) {
    Write-Host ""
    Write-Host "   ❌ No custom SITs found - cannot create auto-apply policies" -ForegroundColor Red
    Write-Host "      Create custom SITs in Lab 2 first" -ForegroundColor Yellow
    exit 1
}
elseif ($missingSITs.Count -gt 0) {
    Write-Host ""
    Write-Host "   ⚠️  Some custom SITs not found - policies will be created only for available SITs" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Step 2 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 3: Auto-Apply Policy Configuration
# =============================================================================

Write-Host "🔍 Step 3: Auto-Apply Policy Configuration" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Defining auto-apply policy configurations..." -ForegroundColor Cyan
Write-Host ""

# Display simulation mode status
if ($SimulationMode) {
    Write-Host "   ℹ️  SIMULATION MODE ENABLED" -ForegroundColor Yellow
    Write-Host "      Policies will identify content but NOT automatically apply labels" -ForegroundColor Yellow
    Write-Host "      Use this mode to validate policy effectiveness before production deployment" -ForegroundColor Yellow
    Write-Host ""
}
else {
    Write-Host "   ⚠️  PRODUCTION MODE - Automatic label application ENABLED" -ForegroundColor Yellow
    Write-Host "      Policies will automatically apply retention labels when SITs are detected" -ForegroundColor Yellow
    Write-Host "      Ensure policies are validated in simulation mode before enabling production mode" -ForegroundColor Yellow
    Write-Host ""
}

# Define auto-apply policy configurations
$autoApplyPolicies = @(
    @{
        Name               = "LAB3-AutoApply-Financial"
        Comment            = "Auto-apply 7-year retention to financial documents with Purchase Order patterns"
        RetentionLabel     = "LAB3-Financial-7yr"
        SITName            = "LAB2-PurchaseOrder-PO"
        Priority           = 1  # Highest priority
        MatchCondition     = "Any"  # Apply if any SIT instance is found
        UseCase            = "Financial documents requiring 7-year retention"
    },
    @{
        Name               = "LAB3-AutoApply-HR"
        Comment            = "Auto-apply 5-year retention to employee documents with EDM employee data"
        RetentionLabel     = "LAB3-HR-5yr"
        SITName            = "LAB2-EmployeeData-EDM"
        Priority           = 2  # High priority
        MatchCondition     = "Any"  # Apply if any SIT instance is found
        UseCase            = "Employee documents requiring 5-year retention with disposition review"
    },
    @{
        Name               = "LAB3-AutoApply-Customer"
        Comment            = "Auto-apply 3-year retention to customer documents with Customer Number patterns"
        RetentionLabel     = "LAB3-General-3yr"
        SITName            = "LAB2-CustomerNumber-CUST"
        Priority           = 3  # Medium priority
        MatchCondition     = "Any"  # Apply if any SIT instance is found
        UseCase            = "Customer documents requiring 3-year retention"
    }
)

# Filter policies based on available SITs
$availablePolicies = $autoApplyPolicies | Where-Object { $_.SITName -in $SITNames -and $_.SITName -notin $missingSITs }

Write-Host "   Configured auto-apply policies:" -ForegroundColor Cyan
foreach ($policy in $availablePolicies) {
    Write-Host "   • $($policy.Name)" -ForegroundColor White
    Write-Host "     SIT Trigger: $($policy.SITName)" -ForegroundColor Gray
    Write-Host "     Label Applied: $($policy.RetentionLabel)" -ForegroundColor Gray
    Write-Host "     Priority: $($policy.Priority)" -ForegroundColor Gray
    Write-Host "     Use Case: $($policy.UseCase)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ Step 3 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 4: Auto-Apply Policy Creation
# =============================================================================

Write-Host "🔍 Step 4: Auto-Apply Policy Creation" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

$createdPolicies = @()
$skippedPolicies = @()
$failedPolicies = @()

foreach ($policyConfig in $availablePolicies) {
    Write-Host "📋 Processing auto-apply policy: $($policyConfig.Name)" -ForegroundColor Cyan
    
    try {
        # Check if policy already exists
        $existingPolicy = Get-RetentionCompliancePolicy -Identity $policyConfig.Name -ErrorAction SilentlyContinue
        
        if ($existingPolicy) {
            Write-Host "   ⚠️  Auto-apply policy already exists: $($policyConfig.Name)" -ForegroundColor Yellow
            Write-Host "      Current label: $($existingPolicy.PublishComplianceTag)" -ForegroundColor Gray
            Write-Host "      Skipping creation..." -ForegroundColor Yellow
            $skippedPolicies += $policyConfig
            Write-Host ""
            continue
        }
        
        # Create auto-apply policy with retry logic
        $maxRetries = 3
        $retryCount = 0
        $policyCreated = $false
        
        while (-not $policyCreated -and $retryCount -lt $maxRetries) {
            try {
                Write-Host "   🚀 Creating auto-apply policy (attempt $($retryCount + 1) of $maxRetries)..." -ForegroundColor Cyan
                
                # Create retention compliance policy
                $policyParams = @{
                    Name                    = $policyConfig.Name
                    Comment                 = $policyConfig.Comment
                    Enabled                 = $true
                    SharePointLocation      = "All"  # Apply to all SharePoint sites
                    OneDriveLocation        = "All"  # Apply to all OneDrive accounts
                    ExchangeLocation        = "All"  # Apply to all Exchange mailboxes
                }
                
                # Add simulation mode if specified
                if ($SimulationMode) {
                    $policyParams.Add("SimulationMode", $true)
                }
                
                $newPolicy = New-RetentionCompliancePolicy @policyParams -ErrorAction Stop
                Write-Host "   ✅ Auto-apply policy created successfully" -ForegroundColor Green
                
                # Wait for policy creation to replicate
                Start-Sleep -Seconds 5
                
                # Create policy rule with SIT condition
                Write-Host "   🚀 Configuring policy rule with SIT trigger..." -ForegroundColor Cyan
                
                $ruleParams = @{
                    Name                    = "$($policyConfig.Name)-Rule"
                    Policy                  = $policyConfig.Name
                    PublishComplianceTag    = $policyConfig.RetentionLabel
                    ContentContainsSensitiveInformation = @{
                        Name = $policyConfig.SITName
                        MinCount = 1
                    }
                    Priority                = $policyConfig.Priority
                }
                
                $newRule = New-RetentionComplianceRule @ruleParams -ErrorAction Stop
                Write-Host "   ✅ Policy rule configured successfully" -ForegroundColor Green
                Write-Host "      SIT Trigger: $($policyConfig.SITName)" -ForegroundColor Gray
                Write-Host "      Label Applied: $($policyConfig.RetentionLabel)" -ForegroundColor Gray
                Write-Host "      Priority: $($policyConfig.Priority)" -ForegroundColor Gray
                
                $policyCreated = $true
                $createdPolicies += @{
                    Policy = $newPolicy
                    Rule = $newRule
                    Config = $policyConfig
                }
            }
            catch {
                $retryCount++
                if ($retryCount -lt $maxRetries) {
                    Write-Host "   ⚠️  Creation failed, retrying in 5 seconds..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 5
                }
                else {
                    throw $_
                }
            }
        }
        
        # Verify policy creation
        Write-Host "   🔍 Verifying policy creation..." -ForegroundColor Cyan
        Start-Sleep -Seconds 2  # Allow time for replication
        
        $verifyPolicy = Get-RetentionCompliancePolicy -Identity $policyConfig.Name -ErrorAction Stop
        if ($verifyPolicy) {
            Write-Host "   ✅ Policy verification successful" -ForegroundColor Green
            
            if ($SimulationMode) {
                Write-Host "   ℹ️  Policy is in simulation mode - labels will NOT be automatically applied" -ForegroundColor Cyan
            }
        }
        else {
            Write-Host "   ❌ Policy verification failed - policy not found after creation" -ForegroundColor Red
            $failedPolicies += $policyConfig
        }
    }
    catch {
        Write-Host "   ❌ Failed to create auto-apply policy: $($policyConfig.Name)" -ForegroundColor Red
        Write-Host "      Error: $_" -ForegroundColor Red
        $failedPolicies += $policyConfig
    }
    
    Write-Host ""
}

Write-Host "✅ Step 4 completed" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 5: Summary and Next Steps
# =============================================================================

Write-Host "🔍 Step 5: Summary and Next Steps" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Auto-Apply Policy Creation Summary:" -ForegroundColor Cyan
Write-Host "   • Created: $($createdPolicies.Count) policies" -ForegroundColor Green
Write-Host "   • Skipped (already exist): $($skippedPolicies.Count) policies" -ForegroundColor Yellow
Write-Host "   • Failed: $($failedPolicies.Count) policies" -ForegroundColor $(if ($failedPolicies.Count -gt 0) { "Red" } else { "Green" })
Write-Host "   • Simulation mode: $(if ($SimulationMode) { 'ENABLED' } else { 'Disabled' })" -ForegroundColor $(if ($SimulationMode) { "Yellow" } else { "Green" })
Write-Host ""

if ($createdPolicies.Count -gt 0) {
    Write-Host "✅ Successfully created auto-apply policies:" -ForegroundColor Green
    foreach ($item in $createdPolicies) {
        Write-Host "   • $($item.Config.Name)" -ForegroundColor White
        Write-Host "     SIT: $($item.Config.SITName) → Label: $($item.Config.RetentionLabel)" -ForegroundColor Gray
    }
    Write-Host ""
}

if ($skippedPolicies.Count -gt 0) {
    Write-Host "⚠️  Skipped auto-apply policies (already exist):" -ForegroundColor Yellow
    foreach ($policy in $skippedPolicies) {
        Write-Host "   • $($policy.Name)" -ForegroundColor White
    }
    Write-Host ""
}

if ($failedPolicies.Count -gt 0) {
    Write-Host "❌ Failed auto-apply policies:" -ForegroundColor Red
    foreach ($policy in $failedPolicies) {
        Write-Host "   • $($policy.Name)" -ForegroundColor White
    }
    Write-Host ""
}

Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host ""

Write-Host "   1. Verify auto-apply policies in Microsoft Purview compliance portal:" -ForegroundColor White
Write-Host "      https://compliance.microsoft.com/informationgovernance?viewid=retention" -ForegroundColor Gray
Write-Host ""

if ($SimulationMode) {
    Write-Host "   2. Monitor simulation results to validate policy effectiveness:" -ForegroundColor White
    Write-Host "      Review Content Explorer to see what content matches SIT patterns" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   3. Once validated, re-run without -SimulationMode to enable automatic label application:" -ForegroundColor White
    Write-Host "      .\Create-AutoApplyPolicies.ps1" -ForegroundColor Gray
    Write-Host ""
}
else {
    Write-Host "   2. Wait 24-48 hours for auto-apply policies to process existing content" -ForegroundColor White
    Write-Host "      Policies apply labels automatically as content is scanned" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   3. Upload test data to validate automatic label application:" -ForegroundColor White
    Write-Host "      Use Lab 2 test files with custom SIT patterns" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "   4. Validate retention label application:" -ForegroundColor White
Write-Host "      .\Validate-RetentionLabels.ps1 -SharePointSiteUrl <your-site-url>" -ForegroundColor Gray
Write-Host ""

Write-Host "   5. Monitor retention label adoption and coverage:" -ForegroundColor White
Write-Host "      .\Monitor-RetentionMetrics.ps1 -SharePointSiteUrl <your-site-url>" -ForegroundColor Gray
Write-Host ""

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Auto-Apply Policies Creation Complete" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
