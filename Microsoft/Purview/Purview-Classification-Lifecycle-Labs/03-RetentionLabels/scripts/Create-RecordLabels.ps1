<#
.SYNOPSIS
    Creates record labels with immutability in Microsoft Purview for regulatory compliance.

.DESCRIPTION
    This script creates record labels in Microsoft Purview that declare content as regulatory
    or organizational records with strict immutability and deletion prevention controls. Record
    labels provide the highest level of protection for critical business content that must be
    preserved for legal, regulatory, or business continuity purposes.
    
    The script creates two types of record labels:
    - Legal Hold Records: Permanent retention with no deletion allowed (regulatory record)
    - Regulatory Records: 10-year retention with regulatory record protection
    
    Record labels differ from standard retention labels by preventing content modification or
    deletion once the label is applied. Regulatory records provide an additional layer of
    protection where even administrators cannot remove the record label without a specific
    unlock process.
    
    The script includes comprehensive validation to verify successful label creation and
    provides detailed feedback throughout the process, including warnings about the permanent
    nature of record label application.

.PARAMETER LabelPrefix
    Optional prefix to add to record label names for organizational categorization.
    Default is "LAB3" to clearly identify labels created during this lab exercise.
    
    Example: With prefix "LAB3", labels will be named "LAB3-LegalHold-Record", "LAB3-Regulatory-10yr", etc.

.PARAMETER EnableRegulatoryRecords
    Switch parameter to enable regulatory record functionality for applicable record labels.
    Regulatory records provide the strictest protection level, preventing even administrators
    from removing the label without going through a formal unlock process.
    
    When enabled, the 10-year regulatory record label will have enhanced protection that
    requires a specific unlock action before the label can be removed, even by administrators.

.PARAMETER PublishImmediately
    Switch parameter to automatically publish record labels after creation, making them
    immediately available for manual application by users. If not specified, labels are created
    but remain unpublished until explicitly published through a retention label policy.
    
    Note: Auto-apply policies can work with unpublished labels. This parameter only affects
    manual user application availability.

.PARAMETER SkipConnectionTest
    Skip the initial Microsoft 365 connection test. Use this parameter when running multiple
    scripts in sequence where connection has already been established.

.EXAMPLE
    .\Create-RecordLabels.ps1
    
    Creates record labels with default "LAB3" prefix. Labels remain unpublished and regulatory
    record protection is not enabled. Suitable for testing and lab environments.

.EXAMPLE
    .\Create-RecordLabels.ps1 -EnableRegulatoryRecords -PublishImmediately
    
    Creates record labels with regulatory record protection enabled and publishes them
    immediately. Suitable for production environments requiring maximum protection.

.EXAMPLE
    .\Create-RecordLabels.ps1 -LabelPrefix "CONTOSO" -EnableRegulatoryRecords
    
    Creates record labels with custom "CONTOSO" prefix and regulatory record protection.
    Labels remain unpublished for review before deployment.

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
    - Records Management role assignment for record label creation
    
    Script development orchestrated using GitHub Copilot.

.RECORD LABELS
    Legal Hold Records (Permanent retention):
    - Retention Period: Permanent (no automatic deletion)
    - Record Type: Regulatory record (if EnableRegulatoryRecords specified)
    - Deletion Prevention: Content cannot be deleted once labeled
    - Use Case: Content under legal hold, litigation support, permanent archives
    - Protection: Highest level - prevents all modifications and deletions
    
    Regulatory Records (10-year retention):
    - Retention Period: 10 years from content creation date
    - Record Type: Regulatory record (if EnableRegulatoryRecords specified)
    - Deletion Prevention: Content cannot be deleted during retention period
    - Use Case: Regulatory compliance documents, audit records, compliance archives
    - Protection: Enhanced protection requiring admin unlock for label removal

.LINK
    https://learn.microsoft.com/en-us/purview/records-management
    https://learn.microsoft.com/en-us/purview/declare-records
    https://learn.microsoft.com/en-us/powershell/module/exchange/new-compliancetag
#>

#Requires -Modules ExchangeOnlineManagement

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$LabelPrefix = "LAB3",
    
    [Parameter(Mandatory = $false)]
    [switch]$EnableRegulatoryRecords,
    
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
Write-Host "  Record Labels Creation" -ForegroundColor Cyan
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
# Step 2: Record Label Configuration
# =============================================================================

Write-Host "🔍 Step 2: Record Label Configuration" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Defining record label configurations..." -ForegroundColor Cyan
Write-Host ""

# Display regulatory record protection status
if ($EnableRegulatoryRecords) {
    Write-Host "   ⚠️  REGULATORY RECORD PROTECTION ENABLED" -ForegroundColor Yellow
    Write-Host "      Record labels will have enhanced protection preventing label removal" -ForegroundColor Yellow
    Write-Host "      Even administrators must unlock regulatory records before removal" -ForegroundColor Yellow
    Write-Host ""
}
else {
    Write-Host "   ℹ️  Regulatory record protection disabled" -ForegroundColor Cyan
    Write-Host "      Use -EnableRegulatoryRecords for maximum protection in production" -ForegroundColor Gray
    Write-Host ""
}

# Define record label configurations
$recordLabels = @(
    @{
        Name               = "$LabelPrefix-LegalHold-Record"
        DisplayName        = "$LabelPrefix Legal Hold (Permanent Record)"
        Comment            = "Legal hold content with permanent retention and regulatory record protection"
        RetentionDuration  = 0  # 0 indicates permanent retention
        RetentionAction    = "Keep"  # Keep permanently, no automatic deletion
        RetentionType      = "CreationAgeInDays"  # Retention based on content creation date
        IsRecordLabel      = $true  # Declare as record label
        Regulatory         = $EnableRegulatoryRecords.IsPresent  # Regulatory record protection
        UseCase            = "Legal hold, litigation support, permanent archives"
    },
    @{
        Name               = "$LabelPrefix-Regulatory-10yr"
        DisplayName        = "$LabelPrefix Regulatory Records (10-year)"
        Comment            = "Regulatory compliance documents with 10-year retention and record protection"
        RetentionDuration  = 3650  # 10 years in days (10 * 365)
        RetentionAction    = "Keep"  # Keep for period, then disposition review
        RetentionType      = "CreationAgeInDays"  # Retention based on content creation date
        IsRecordLabel      = $true  # Declare as record label
        Regulatory         = $EnableRegulatoryRecords.IsPresent  # Regulatory record protection
        UseCase            = "Regulatory compliance, audit records, compliance archives"
    }
)

Write-Host "   Configured record labels:" -ForegroundColor Cyan
foreach ($label in $recordLabels) {
    $retentionText = if ($label.RetentionDuration -eq 0) { "Permanent" } else { "$([Math]::Round($label.RetentionDuration / 365, 1)) years" }
    $protectionText = if ($label.Regulatory) { "Regulatory record" } else { "Standard record" }
    Write-Host "   • $($label.DisplayName)" -ForegroundColor White
    Write-Host "     Retention: $retentionText | Protection: $protectionText" -ForegroundColor Gray
    Write-Host "     Use Case: $($label.UseCase)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ Step 2 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 3: Record Label Creation
# =============================================================================

Write-Host "🔍 Step 3: Record Label Creation" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

$createdLabels = @()
$skippedLabels = @()
$failedLabels = @()

foreach ($labelConfig in $recordLabels) {
    Write-Host "📋 Processing record label: $($labelConfig.DisplayName)" -ForegroundColor Cyan
    
    # Display warning about record label immutability
    if ($labelConfig.IsRecordLabel) {
        Write-Host "   ⚠️  WARNING: Record labels provide immutability protection" -ForegroundColor Yellow
        Write-Host "      Content labeled with this record label cannot be modified or deleted" -ForegroundColor Yellow
        
        if ($labelConfig.Regulatory) {
            Write-Host "      Regulatory record protection requires admin unlock before label removal" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    try {
        # Check if label already exists
        $existingLabel = Get-ComplianceTag -Identity $labelConfig.Name -ErrorAction SilentlyContinue
        
        if ($existingLabel) {
            Write-Host "   ⚠️  Record label already exists: $($labelConfig.Name)" -ForegroundColor Yellow
            
            # Display current label properties
            $currentRetention = if ($existingLabel.RetentionDuration -eq 0) { "Permanent" } else { "$([Math]::Round($existingLabel.RetentionDuration / 365, 1)) years" }
            Write-Host "      Current retention: $currentRetention" -ForegroundColor Gray
            Write-Host "      Is record label: $($existingLabel.IsRecordLabel)" -ForegroundColor Gray
            Write-Host "      Regulatory record: $($existingLabel.Regulatory)" -ForegroundColor Gray
            Write-Host "      Skipping creation..." -ForegroundColor Yellow
            
            $skippedLabels += $labelConfig
            Write-Host ""
            continue
        }
        
        # Create record label with retry logic
        $maxRetries = 3
        $retryCount = 0
        $labelCreated = $false
        
        while (-not $labelCreated -and $retryCount -lt $maxRetries) {
            try {
                Write-Host "   🚀 Creating record label (attempt $($retryCount + 1) of $maxRetries)..." -ForegroundColor Cyan
                
                # Prepare parameters for New-ComplianceTag
                $tagParams = @{
                    Name              = $labelConfig.Name
                    Comment           = $labelConfig.Comment
                    IsRecordLabel     = $labelConfig.IsRecordLabel
                    Regulatory        = $labelConfig.Regulatory
                }
                
                # Add retention settings based on duration
                if ($labelConfig.RetentionDuration -eq 0) {
                    # Permanent retention
                    $tagParams.RetentionAction = "Keep"
                }
                else {
                    # Time-based retention
                    $tagParams.RetentionDuration = $labelConfig.RetentionDuration
                    $tagParams.RetentionAction = $labelConfig.RetentionAction
                    $tagParams.RetentionType = $labelConfig.RetentionType
                }
                
                # Create the record label
                $newLabel = New-ComplianceTag @tagParams -ErrorAction Stop
                
                $labelCreated = $true
                Write-Host "   ✅ Record label created successfully" -ForegroundColor Green
                Write-Host "      Name: $($newLabel.Name)" -ForegroundColor Gray
                
                $retentionDisplay = if ($newLabel.RetentionDuration -eq 0) { "Permanent" } else { "$([Math]::Round($newLabel.RetentionDuration / 365, 1)) years" }
                Write-Host "      Retention: $retentionDisplay" -ForegroundColor Gray
                Write-Host "      Record label: $($newLabel.IsRecordLabel)" -ForegroundColor Gray
                Write-Host "      Regulatory: $($newLabel.Regulatory)" -ForegroundColor Gray
                
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
            
            # Additional verification for record-specific properties
            if ($verifyLabel.IsRecordLabel -ne $labelConfig.IsRecordLabel) {
                Write-Host "   ⚠️  Warning: IsRecordLabel property mismatch" -ForegroundColor Yellow
                Write-Host "      Expected: $($labelConfig.IsRecordLabel), Actual: $($verifyLabel.IsRecordLabel)" -ForegroundColor Yellow
            }
            
            if ($EnableRegulatoryRecords -and $verifyLabel.Regulatory -ne $labelConfig.Regulatory) {
                Write-Host "   ⚠️  Warning: Regulatory property mismatch" -ForegroundColor Yellow
                Write-Host "      Expected: $($labelConfig.Regulatory), Actual: $($verifyLabel.Regulatory)" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "   ❌ Label verification failed - label not found after creation" -ForegroundColor Red
            $failedLabels += $labelConfig
        }
    }
    catch {
        Write-Host "   ❌ Failed to create record label: $($labelConfig.Name)" -ForegroundColor Red
        Write-Host "      Error: $_" -ForegroundColor Red
        $failedLabels += $labelConfig
    }
    
    Write-Host ""
}

Write-Host "✅ Step 3 completed" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 4: Record Label Publishing (Optional)
# =============================================================================

if ($PublishImmediately) {
    Write-Host "🔍 Step 4: Record Label Publishing" -ForegroundColor Green
    Write-Host "===================================" -ForegroundColor Green
    Write-Host ""
    
    if ($createdLabels.Count -eq 0) {
        Write-Host "   ⚠️  No new record labels to publish" -ForegroundColor Yellow
        Write-Host "      All labels already existed or creation failed" -ForegroundColor Yellow
    }
    else {
        Write-Host "📋 Publishing record labels for user application..." -ForegroundColor Cyan
        Write-Host ""
        
        # Warning about record label publishing
        Write-Host "   ⚠️  WARNING: Publishing record labels makes them available to users" -ForegroundColor Yellow
        Write-Host "      Once applied, record labels cannot be removed without proper authorization" -ForegroundColor Yellow
        Write-Host "      Ensure users understand the permanent nature of record label application" -ForegroundColor Yellow
        Write-Host ""
        
        try {
            # Create retention label policy name
            $policyName = "$LabelPrefix-RecordLabels-Policy"
            
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
                $newPolicy = New-RetentionCompliancePolicy -Name $policyName -Comment "Lab 3 record labels for manual user application" -ErrorAction Stop
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
                
                Write-Host "   ✅ Record labels published successfully" -ForegroundColor Green
            }
            
            Write-Host ""
            Write-Host "   Published record labels:" -ForegroundColor Cyan
            foreach ($label in $createdLabels) {
                Write-Host "   • $($label.Name)" -ForegroundColor White
            }
        }
        catch {
            Write-Host "   ❌ Failed to publish record labels" -ForegroundColor Red
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

Write-Host "📊 Record Label Creation Summary:" -ForegroundColor Cyan
Write-Host "   • Created: $($createdLabels.Count) labels" -ForegroundColor Green
Write-Host "   • Skipped (already exist): $($skippedLabels.Count) labels" -ForegroundColor Yellow
Write-Host "   • Failed: $($failedLabels.Count) labels" -ForegroundColor $(if ($failedLabels.Count -gt 0) { "Red" } else { "Green" })
Write-Host "   • Regulatory protection: $(if ($EnableRegulatoryRecords) { 'ENABLED' } else { 'Disabled' })" -ForegroundColor $(if ($EnableRegulatoryRecords) { "Yellow" } else { "Gray" })
Write-Host ""

if ($createdLabels.Count -gt 0) {
    Write-Host "✅ Successfully created record labels:" -ForegroundColor Green
    foreach ($label in $createdLabels) {
        $retentionText = if ($label.RetentionDuration -eq 0) { "Permanent" } else { "$([Math]::Round($label.RetentionDuration / 365, 1)) years" }
        $protectionText = if ($label.Regulatory) { "Regulatory" } else { "Standard" }
        Write-Host "   • $($label.Name) ($retentionText, $protectionText)" -ForegroundColor White
    }
    Write-Host ""
}

if ($skippedLabels.Count -gt 0) {
    Write-Host "⚠️  Skipped record labels (already exist):" -ForegroundColor Yellow
    foreach ($label in $skippedLabels) {
        Write-Host "   • $($label.Name)" -ForegroundColor White
    }
    Write-Host ""
}

if ($failedLabels.Count -gt 0) {
    Write-Host "❌ Failed record labels:" -ForegroundColor Red
    foreach ($label in $failedLabels) {
        Write-Host "   • $($label.Name)" -ForegroundColor White
    }
    Write-Host ""
}

Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host ""

if ($PublishImmediately) {
    Write-Host "   1. Verify record labels in Microsoft Purview compliance portal:" -ForegroundColor White
    Write-Host "      https://compliance.microsoft.com/informationgovernance?viewid=retention" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   2. Record labels are now available for manual application by users" -ForegroundColor White
    Write-Host "      ⚠️  Remind users that record labels cannot be removed once applied" -ForegroundColor Yellow
    Write-Host ""
}
else {
    Write-Host "   1. Verify record labels in Microsoft Purview compliance portal:" -ForegroundColor White
    Write-Host "      https://compliance.microsoft.com/informationgovernance?viewid=retention" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   2. Record labels are created but NOT published for manual user application" -ForegroundColor Yellow
    Write-Host "      Run with -PublishImmediately to make labels available to users" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "   3. Configure auto-apply policies to link labels with custom SITs:" -ForegroundColor White
Write-Host "      .\Create-AutoApplyPolicies.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "   4. Validate retention label application:" -ForegroundColor White
Write-Host "      .\Validate-RetentionLabels.ps1 -SharePointSiteUrl <your-site-url>" -ForegroundColor Gray
Write-Host ""

Write-Host "   5. Monitor retention label adoption and coverage:" -ForegroundColor White
Write-Host "      .\Monitor-RetentionMetrics.ps1 -SharePointSiteUrl <your-site-url>" -ForegroundColor Gray
Write-Host ""

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Record Labels Creation Complete" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
