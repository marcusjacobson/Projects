<#
.SYNOPSIS
    Creates standard retention labels in Microsoft Purview for data lifecycle management.

.DESCRIPTION
    This script creates a set of standard retention labels in Microsoft Purview with various
    retention periods and disposition actions. Retention labels enable automated data lifecycle
    management by applying retention policies to content based on business and regulatory requirements.
    
    The script creates four standard retention labels with different retention periods:
    - Financial Records: 7-year retention with automatic deletion
    - HR Documents: 5-year retention requiring disposition review
    - General Business: 3-year retention with automatic deletion
    - Temporary Documents: 1-year retention with automatic deletion
    
    Each label includes proper retention settings, disposition actions, and scope configuration
    to ensure compliance with data retention policies. The script includes comprehensive validation
    to verify successful label creation and provides detailed feedback throughout the process.

.PARAMETER LabelPrefix
    Optional prefix to add to retention label names for organizational categorization.
    Default is "LAB3" to clearly identify labels created during this lab exercise.
    
    Example: With prefix "LAB3", labels will be named "LAB3-Financial-7yr", "LAB3-HR-5yr", etc.

.PARAMETER PublishImmediately
    Switch parameter to automatically publish retention labels after creation, making them
    immediately available for manual application by users. If not specified, labels are created
    but remain unpublished until explicitly published through a retention label policy.
    
    Note: Auto-apply policies (configured in Create-AutoApplyPolicies.ps1) will work with
    unpublished labels. This parameter only affects manual user application availability.

.PARAMETER SkipConnectionTest
    Skip the initial Microsoft 365 connection test. Use this parameter when running multiple
    scripts in sequence where connection has already been established.

.EXAMPLE
    .\Create-RetentionLabels.ps1
    
    Creates retention labels with default "LAB3" prefix. Labels remain unpublished and are only
    available for auto-apply policies, not for manual user application.

.EXAMPLE
    .\Create-RetentionLabels.ps1 -PublishImmediately
    
    Creates retention labels and immediately publishes them, making labels available for both
    auto-apply policies and manual application by users in Microsoft 365 applications.

.EXAMPLE
    .\Create-RetentionLabels.ps1 -LabelPrefix "CONTOSO" -PublishImmediately
    
    Creates retention labels with custom "CONTOSO" prefix and publishes them immediately.
    Useful for production deployments with organizational naming conventions.

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
    - Azure Active Directory account with retention label creation rights
    
    Script development orchestrated using GitHub Copilot.

.RETENTION LABELS
    Financial Records (7-year retention):
    - Retention Period: 7 years from content creation date
    - Disposition Action: Automatic deletion after retention period
    - Use Case: Financial documents, invoices, purchase orders requiring 7-year retention
    
    HR Documents (5-year retention):
    - Retention Period: 5 years from content creation date
    - Disposition Action: Disposition review required (manual approval for deletion)
    - Use Case: Employee records, performance reviews requiring 5-year retention with review
    
    General Business (3-year retention):
    - Retention Period: 3 years from content creation date
    - Disposition Action: Automatic deletion after retention period
    - Use Case: General business documents, project files with standard 3-year retention
    
    Temporary Documents (1-year retention):
    - Retention Period: 1 year from content creation date
    - Disposition Action: Automatic deletion after retention period
    - Use Case: Temporary files, drafts, working documents with short-term retention needs

.LINK
    https://learn.microsoft.com/en-us/purview/retention
    https://learn.microsoft.com/en-us/purview/create-retention-labels-information-governance
    https://learn.microsoft.com/en-us/powershell/module/exchange/new-compliancetag
#>

#Requires -Modules ExchangeOnlineManagement

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$LabelPrefix = "LAB3",
    
    [Parameter(Mandatory = $false)]
    [switch]$PublishImmediately,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipConnectionTest
)

# =============================================================================
# Script Initialization
# =============================================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Retention Labels Creation" -ForegroundColor Cyan
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
        
        # Test connection by retrieving existing compliance tags (limit to 1 for speed)
        $testConnection = Get-ComplianceTag -ResultSize 1 -ErrorAction Stop
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
# Step 2: Retention Label Configuration
# =============================================================================

Write-Host "🔍 Step 2: Retention Label Configuration" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Defining retention label configurations..." -ForegroundColor Cyan
Write-Host ""

# Define retention label configurations
$retentionLabels = @(
    @{
        Name               = "$LabelPrefix-Financial-7yr"
        DisplayName        = "$LabelPrefix Financial Records (7-year)"
        Comment            = "Financial documents requiring 7-year retention with automatic deletion"
        RetentionDuration  = 2555  # 7 years in days (7 * 365)
        RetentionAction    = "Delete"  # Automatic deletion after retention period
        RetentionType      = "CreationAgeInDays"  # Retention based on content creation date
        ReviewerEmail      = $null  # No reviewer needed for automatic deletion
        IsRecordLabel      = $false  # Standard retention label (not a record)
    },
    @{
        Name               = "$LabelPrefix-HR-5yr"
        DisplayName        = "$LabelPrefix HR Documents (5-year)"
        Comment            = "HR documents requiring 5-year retention with disposition review"
        RetentionDuration  = 1825  # 5 years in days (5 * 365)
        RetentionAction    = "KeepAndDelete"  # Keep for period then require review for deletion
        RetentionType      = "CreationAgeInDays"  # Retention based on content creation date
        ReviewerEmail      = $null  # Will use default reviewers from retention policy
        IsRecordLabel      = $false  # Standard retention label (not a record)
    },
    @{
        Name               = "$LabelPrefix-General-3yr"
        DisplayName        = "$LabelPrefix General Business (3-year)"
        Comment            = "General business documents with 3-year retention and automatic deletion"
        RetentionDuration  = 1095  # 3 years in days (3 * 365)
        RetentionAction    = "Delete"  # Automatic deletion after retention period
        RetentionType      = "CreationAgeInDays"  # Retention based on content creation date
        ReviewerEmail      = $null  # No reviewer needed for automatic deletion
        IsRecordLabel      = $false  # Standard retention label (not a record)
    },
    @{
        Name               = "$LabelPrefix-Temporary-1yr"
        DisplayName        = "$LabelPrefix Temporary Documents (1-year)"
        Comment            = "Temporary documents with 1-year retention and automatic deletion"
        RetentionDuration  = 365  # 1 year in days
        RetentionAction    = "Delete"  # Automatic deletion after retention period
        RetentionType      = "CreationAgeInDays"  # Retention based on content creation date
        ReviewerEmail      = $null  # No reviewer needed for automatic deletion
        IsRecordLabel      = $false  # Standard retention label (not a record)
    }
)

Write-Host "   Configured retention labels:" -ForegroundColor Cyan
foreach ($label in $retentionLabels) {
    $years = [Math]::Round($label.RetentionDuration / 365, 1)
    $actionText = if ($label.RetentionAction -eq "Delete") { "Automatic deletion" } else { "Disposition review required" }
    Write-Host "   • $($label.DisplayName)" -ForegroundColor White
    Write-Host "     Retention: $years years | Action: $actionText" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ Step 2 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 3: Retention Label Creation
# =============================================================================

Write-Host "🔍 Step 3: Retention Label Creation" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

$createdLabels = @()
$skippedLabels = @()
$failedLabels = @()

foreach ($labelConfig in $retentionLabels) {
    Write-Host "📋 Processing retention label: $($labelConfig.DisplayName)" -ForegroundColor Cyan
    
    try {
        # Check if label already exists
        $existingLabel = Get-ComplianceTag -Identity $labelConfig.Name -ErrorAction SilentlyContinue
        
        if ($existingLabel) {
            Write-Host "   ⚠️  Retention label already exists: $($labelConfig.Name)" -ForegroundColor Yellow
            Write-Host "      Current retention: $([Math]::Round($existingLabel.RetentionDuration / 365, 1)) years" -ForegroundColor Gray
            Write-Host "      Skipping creation..." -ForegroundColor Yellow
            $skippedLabels += $labelConfig
            Write-Host ""
            continue
        }
        
        # Create retention label with retry logic
        $maxRetries = 3
        $retryCount = 0
        $labelCreated = $false
        
        while (-not $labelCreated -and $retryCount -lt $maxRetries) {
            try {
                Write-Host "   🚀 Creating retention label (attempt $($retryCount + 1) of $maxRetries)..." -ForegroundColor Cyan
                
                # Prepare parameters for New-ComplianceTag
                $tagParams = @{
                    Name              = $labelConfig.Name
                    Comment           = $labelConfig.Comment
                    RetentionDuration = $labelConfig.RetentionDuration
                    RetentionAction   = $labelConfig.RetentionAction
                    RetentionType     = $labelConfig.RetentionType
                    IsRecordLabel     = $labelConfig.IsRecordLabel
                }
                
                # Create the retention label
                $newLabel = New-ComplianceTag @tagParams -ErrorAction Stop
                
                $labelCreated = $true
                Write-Host "   ✅ Retention label created successfully" -ForegroundColor Green
                Write-Host "      Name: $($newLabel.Name)" -ForegroundColor Gray
                Write-Host "      Retention: $([Math]::Round($newLabel.RetentionDuration / 365, 1)) years" -ForegroundColor Gray
                Write-Host "      Action: $($newLabel.RetentionAction)" -ForegroundColor Gray
                
                $createdLabels += $newLabel
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
        
        # Verify label creation
        Write-Host "   🔍 Verifying label creation..." -ForegroundColor Cyan
        Start-Sleep -Seconds 2  # Allow time for replication
        
        $verifyLabel = Get-ComplianceTag -Identity $labelConfig.Name -ErrorAction Stop
        if ($verifyLabel) {
            Write-Host "   ✅ Label verification successful" -ForegroundColor Green
        }
        else {
            Write-Host "   ❌ Label verification failed - label not found after creation" -ForegroundColor Red
            $failedLabels += $labelConfig
        }
    }
    catch {
        Write-Host "   ❌ Failed to create retention label: $($labelConfig.Name)" -ForegroundColor Red
        Write-Host "      Error: $_" -ForegroundColor Red
        $failedLabels += $labelConfig
    }
    
    Write-Host ""
}

Write-Host "✅ Step 3 completed" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 4: Retention Label Publishing (Optional)
# =============================================================================

if ($PublishImmediately) {
    Write-Host "🔍 Step 4: Retention Label Publishing" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    
    if ($createdLabels.Count -eq 0) {
        Write-Host "   ⚠️  No new retention labels to publish" -ForegroundColor Yellow
        Write-Host "      All labels already existed or creation failed" -ForegroundColor Yellow
    }
    else {
        Write-Host "📋 Publishing retention labels for user application..." -ForegroundColor Cyan
        Write-Host ""
        
        try {
            # Create retention label policy name
            $policyName = "$LabelPrefix-RetentionLabels-Policy"
            
            # Check if policy already exists
            $existingPolicy = Get-RetentionCompliancePolicy -Identity $policyName -ErrorAction SilentlyContinue
            
            if ($existingPolicy) {
                Write-Host "   ⚠️  Retention label policy already exists: $policyName" -ForegroundColor Yellow
                Write-Host "      Updating policy with new labels..." -ForegroundColor Cyan
                
                # Get current published labels
                $currentLabels = (Get-RetentionComplianceRule -Policy $policyName).PublishComplianceTag
                $allLabels = $currentLabels + $createdLabels.Name | Select-Object -Unique
                
                # Update policy
                Set-RetentionComplianceRule -Identity "$policyName-Rule" -PublishComplianceTag $allLabels -ErrorAction Stop
                Write-Host "   ✅ Retention label policy updated successfully" -ForegroundColor Green
            }
            else {
                Write-Host "   🚀 Creating new retention label policy..." -ForegroundColor Cyan
                
                # Create policy
                $newPolicy = New-RetentionCompliancePolicy -Name $policyName -Comment "Lab 3 retention labels for manual user application" -ErrorAction Stop
                Write-Host "   ✅ Retention label policy created: $policyName" -ForegroundColor Green
                
                # Wait for policy creation to replicate
                Start-Sleep -Seconds 5
                
                # Create policy rule to publish labels
                Write-Host "   🚀 Publishing labels to all locations..." -ForegroundColor Cyan
                $newRule = New-RetentionComplianceRule `
                    -Policy $policyName `
                    -Name "$policyName-Rule" `
                    -PublishComplianceTag ($createdLabels.Name -join ",") `
                    -ErrorAction Stop
                
                Write-Host "   ✅ Retention labels published successfully" -ForegroundColor Green
            }
            
            Write-Host ""
            Write-Host "   Published labels:" -ForegroundColor Cyan
            foreach ($label in $createdLabels) {
                Write-Host "   • $($label.Name)" -ForegroundColor White
            }
        }
        catch {
            Write-Host "   ❌ Failed to publish retention labels" -ForegroundColor Red
            Write-Host "      Error: $_" -ForegroundColor Red
            Write-Host "      Labels are created but not published for manual user application" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "✅ Step 4 completed" -ForegroundColor Green
    Write-Host ""
}

# =============================================================================
# Step 5: Summary and Next Steps
# =============================================================================

Write-Host "🔍 Step 5: Summary and Next Steps" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Retention Label Creation Summary:" -ForegroundColor Cyan
Write-Host "   • Created: $($createdLabels.Count) labels" -ForegroundColor Green
Write-Host "   • Skipped (already exist): $($skippedLabels.Count) labels" -ForegroundColor Yellow
Write-Host "   • Failed: $($failedLabels.Count) labels" -ForegroundColor $(if ($failedLabels.Count -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($createdLabels.Count -gt 0) {
    Write-Host "✅ Successfully created retention labels:" -ForegroundColor Green
    foreach ($label in $createdLabels) {
        $years = [Math]::Round($label.RetentionDuration / 365, 1)
        Write-Host "   • $($label.Name) ($years years)" -ForegroundColor White
    }
    Write-Host ""
}

if ($skippedLabels.Count -gt 0) {
    Write-Host "⚠️  Skipped retention labels (already exist):" -ForegroundColor Yellow
    foreach ($label in $skippedLabels) {
        Write-Host "   • $($label.Name)" -ForegroundColor White
    }
    Write-Host ""
}

if ($failedLabels.Count -gt 0) {
    Write-Host "❌ Failed retention labels:" -ForegroundColor Red
    foreach ($label in $failedLabels) {
        Write-Host "   • $($label.Name)" -ForegroundColor White
    }
    Write-Host ""
}

Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host ""

if ($PublishImmediately) {
    Write-Host "   1. Verify labels in Microsoft Purview compliance portal:" -ForegroundColor White
    Write-Host "      https://compliance.microsoft.com/informationgovernance?viewid=retention" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   2. Labels are now available for manual application by users" -ForegroundColor White
    Write-Host ""
}
else {
    Write-Host "   1. Verify labels in Microsoft Purview compliance portal:" -ForegroundColor White
    Write-Host "      https://compliance.microsoft.com/informationgovernance?viewid=retention" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   2. Labels are created but NOT published for manual user application" -ForegroundColor Yellow
    Write-Host "      Run with -PublishImmediately to make labels available to users" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "   3. Create record labels with immutability:" -ForegroundColor White
Write-Host "      .\Create-RecordLabels.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "   4. Configure auto-apply policies to link labels with custom SITs:" -ForegroundColor White
Write-Host "      .\Create-AutoApplyPolicies.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "   5. Validate retention label application:" -ForegroundColor White
Write-Host "      .\Validate-RetentionLabels.ps1 -SharePointSiteUrl <your-site-url>" -ForegroundColor Gray
Write-Host ""

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Retention Labels Creation Complete" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
