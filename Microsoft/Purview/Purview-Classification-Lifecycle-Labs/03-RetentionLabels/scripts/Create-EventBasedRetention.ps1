<#
.SYNOPSIS
    Creates event-based retention labels that start retention periods from business milestone triggers.

.DESCRIPTION
    This script creates event-based retention labels in Microsoft Purview that calculate retention
    periods starting from specific business events rather than content creation dates. Event-based
    retention is ideal for scenarios where retention requirements are tied to business milestones
    such as employee termination, contract expiration, or project completion.
    
    Unlike time-based retention labels that start retention from content creation or modification
    dates, event-based retention labels remain dormant until a triggering event occurs. Once the
    event is triggered, the retention period begins, ensuring compliance with regulations that
    require retention based on business activities rather than document dates.
    
    The script creates:
    - Event types representing business milestones (Employee Termination, Contract Expiration)
    - Event-based retention labels linked to these event types
    - Configuration for triggering retention periods through events
    
    This is an optional advanced feature suitable for organizations with complex regulatory
    requirements that mandate event-driven retention policies.

.PARAMETER LabelPrefix
    Optional prefix to add to retention label names for organizational categorization.
    Default is "LAB3" to clearly identify labels created during this lab exercise.
    
    Example: With prefix "LAB3", labels will be named "LAB3-EmployeeExit-EventBased", etc.

.PARAMETER EventTypes
    Optional array of event type names to create. If not specified, the script creates default
    event types: "Employee Termination" and "Contract Expiration". Custom event types allow
    organizations to define their own business milestone categories.

.PARAMETER PublishImmediately
    Switch parameter to automatically publish event-based retention labels after creation, making
    them immediately available for manual application by users. If not specified, labels are
    created but remain unpublished until explicitly published through a retention label policy.

.PARAMETER SkipConnectionTest
    Skip the initial Microsoft 365 connection test. Use this parameter when running multiple
    scripts in sequence where connection has already been established.

.EXAMPLE
    .\Create-EventBasedRetention.ps1
    
    Creates default event types (Employee Termination, Contract Expiration) and corresponding
    event-based retention labels. Labels remain unpublished for review before deployment.

.EXAMPLE
    .\Create-EventBasedRetention.ps1 -PublishImmediately
    
    Creates event-based retention labels and immediately publishes them, making labels available
    for both manual application and event triggering.

.EXAMPLE
    .\Create-EventBasedRetention.ps1 -EventTypes @("Employee Termination", "Vendor Departure", "Project Closure")
    
    Creates custom event types for organization-specific business milestones. Useful for
    specialized compliance requirements or industry-specific regulations.

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
    - Records Management role assignment for event-based retention configuration
    
    Script development orchestrated using GitHub Copilot.

.EVENT-BASED RETENTION
    Employee Termination Event:
    - Retention Period: 7 years from employee termination date
    - Event Trigger: HR system reports employee departure
    - Use Case: Employee records requiring retention after employment ends
    - Compliance: EEOC, FLSA, state employment law requirements
    
    Contract Expiration Event:
    - Retention Period: 5 years from contract expiration date
    - Event Trigger: Contract management system reports contract end
    - Use Case: Contract documents requiring retention after agreement expires
    - Compliance: SOX, UCC, general business record requirements

.EVENT TRIGGERING
    Manual Event Triggering:
    - Compliance administrators manually create events through Purview portal
    - Provide event date and related asset IDs (employee ID, contract number)
    - System automatically calculates retention periods for associated content
    
    Automated Event Triggering (Advanced):
    - Integrate with HR/Contract management systems via Power Automate or Logic Apps
    - Systems POST events to Microsoft Graph API when business milestones occur
    - Fully automated retention period calculation without manual intervention

.LINK
    https://learn.microsoft.com/en-us/purview/event-driven-retention
    https://learn.microsoft.com/en-us/purview/create-event-driven-retention-labels
    https://learn.microsoft.com/en-us/powershell/module/exchange/new-compliancetag
#>

#Requires -Modules ExchangeOnlineManagement

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$LabelPrefix = "LAB3",
    
    [Parameter(Mandatory = $false)]
    [string[]]$EventTypes = @(
        "Employee Termination",
        "Contract Expiration"
    ),
    
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
Write-Host "  Event-Based Retention Creation" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "⚠️  ADVANCED FEATURE: Event-Based Retention" -ForegroundColor Yellow
Write-Host "   Event-based retention calculates retention periods from business events" -ForegroundColor Yellow
Write-Host "   rather than content creation dates. This is an optional advanced feature" -ForegroundColor Yellow
Write-Host "   for organizations with complex regulatory requirements." -ForegroundColor Yellow
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
# Step 2: Event Type Configuration
# =============================================================================

Write-Host "🔍 Step 2: Event Type Configuration" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Defining event types for business milestone triggers..." -ForegroundColor Cyan
Write-Host ""

# Define event type configurations
$eventTypeConfigs = @()
foreach ($eventTypeName in $EventTypes) {
    $eventTypeConfigs += @{
        Name = $eventTypeName
        Description = "Event trigger for $eventTypeName milestone"
    }
}

Write-Host "   Configured event types:" -ForegroundColor Cyan
foreach ($eventType in $eventTypeConfigs) {
    Write-Host "   • $($eventType.Name)" -ForegroundColor White
    Write-Host "     $($eventType.Description)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ Step 2 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 3: Event Type Creation
# =============================================================================

Write-Host "🔍 Step 3: Event Type Creation" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

$createdEventTypes = @()
$skippedEventTypes = @()
$failedEventTypes = @()

foreach ($eventTypeConfig in $eventTypeConfigs) {
    Write-Host "📋 Processing event type: $($eventTypeConfig.Name)" -ForegroundColor Cyan
    
    try {
        # Check if event type already exists
        $existingEventType = Get-ComplianceRetentionEventType -Identity $eventTypeConfig.Name -ErrorAction SilentlyContinue
        
        if ($existingEventType) {
            Write-Host "   ⚠️  Event type already exists: $($eventTypeConfig.Name)" -ForegroundColor Yellow
            Write-Host "      Skipping creation..." -ForegroundColor Yellow
            $skippedEventTypes += $eventTypeConfig
            Write-Host ""
            continue
        }
        
        # Create event type with retry logic
        $maxRetries = 3
        $retryCount = 0
        $eventTypeCreated = $false
        
        while (-not $eventTypeCreated -and $retryCount -lt $maxRetries) {
            try {
                Write-Host "   🚀 Creating event type (attempt $($retryCount + 1) of $maxRetries)..." -ForegroundColor Cyan
                
                # Create the event type
                $newEventType = New-ComplianceRetentionEventType `
                    -Name $eventTypeConfig.Name `
                    -Comment $eventTypeConfig.Description `
                    -ErrorAction Stop
                
                $eventTypeCreated = $true
                Write-Host "   ✅ Event type created successfully" -ForegroundColor Green
                Write-Host "      Name: $($newEventType.Name)" -ForegroundColor Gray
                
                $createdEventTypes += $newEventType
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
        
        # Verify event type creation
        Write-Host "   🔍 Verifying event type creation..." -ForegroundColor Cyan
        Start-Sleep -Seconds 2  # Allow time for replication
        
        $verifyEventType = Get-ComplianceRetentionEventType -Identity $eventTypeConfig.Name -ErrorAction Stop
        if ($verifyEventType) {
            Write-Host "   ✅ Event type verification successful" -ForegroundColor Green
        }
        else {
            Write-Host "   ❌ Event type verification failed - event type not found after creation" -ForegroundColor Red
            $failedEventTypes += $eventTypeConfig
        }
    }
    catch {
        Write-Host "   ❌ Failed to create event type: $($eventTypeConfig.Name)" -ForegroundColor Red
        Write-Host "      Error: $_" -ForegroundColor Red
        $failedEventTypes += $eventTypeConfig
    }
    
    Write-Host ""
}

Write-Host "✅ Step 3 completed" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 4: Event-Based Retention Label Configuration
# =============================================================================

Write-Host "🔍 Step 4: Event-Based Retention Label Configuration" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Defining event-based retention label configurations..." -ForegroundColor Cyan
Write-Host ""

# Define event-based retention labels
$eventBasedLabels = @(
    @{
        Name               = "$LabelPrefix-EmployeeExit-EventBased"
        DisplayName        = "$LabelPrefix Employee Records (Event-Based 7-year)"
        Comment            = "Employee records with 7-year retention starting from employee termination event"
        RetentionDuration  = 2555  # 7 years in days
        RetentionAction    = "Delete"  # Automatic deletion after retention period
        RetentionType      = "EventAgeInDays"  # Event-based retention
        EventTypeName      = "Employee Termination"
        IsRecordLabel      = $false
        UseCase            = "Employee records retention after employment ends"
    },
    @{
        Name               = "$LabelPrefix-ContractEnd-EventBased"
        DisplayName        = "$LabelPrefix Contract Records (Event-Based 5-year)"
        Comment            = "Contract documents with 5-year retention starting from contract expiration event"
        RetentionDuration  = 1825  # 5 years in days
        RetentionAction    = "Delete"  # Automatic deletion after retention period
        RetentionType      = "EventAgeInDays"  # Event-based retention
        EventTypeName      = "Contract Expiration"
        IsRecordLabel      = $false
        UseCase            = "Contract documents retention after agreement expires"
    }
)

# Filter labels based on available event types
$availableLabels = $eventBasedLabels | Where-Object { 
    $_.EventTypeName -in $EventTypes -and 
    $_.EventTypeName -in ($createdEventTypes + $skippedEventTypes).Name 
}

Write-Host "   Configured event-based retention labels:" -ForegroundColor Cyan
foreach ($label in $availableLabels) {
    $years = [Math]::Round($label.RetentionDuration / 365, 1)
    Write-Host "   • $($label.DisplayName)" -ForegroundColor White
    Write-Host "     Event Trigger: $($label.EventTypeName)" -ForegroundColor Gray
    Write-Host "     Retention: $years years from event date" -ForegroundColor Gray
    Write-Host "     Use Case: $($label.UseCase)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ Step 4 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 5: Event-Based Retention Label Creation
# =============================================================================

Write-Host "🔍 Step 5: Event-Based Retention Label Creation" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

$createdLabels = @()
$skippedLabels = @()
$failedLabels = @()

foreach ($labelConfig in $availableLabels) {
    Write-Host "📋 Processing event-based retention label: $($labelConfig.DisplayName)" -ForegroundColor Cyan
    
    try {
        # Check if label already exists
        $existingLabel = Get-ComplianceTag -Identity $labelConfig.Name -ErrorAction SilentlyContinue
        
        if ($existingLabel) {
            Write-Host "   ⚠️  Retention label already exists: $($labelConfig.Name)" -ForegroundColor Yellow
            Write-Host "      Skipping creation..." -ForegroundColor Yellow
            $skippedLabels += $labelConfig
            Write-Host ""
            continue
        }
        
        # Get event type for label association
        $eventType = Get-ComplianceRetentionEventType -Identity $labelConfig.EventTypeName -ErrorAction Stop
        
        # Create event-based retention label with retry logic
        $maxRetries = 3
        $retryCount = 0
        $labelCreated = $false
        
        while (-not $labelCreated -and $retryCount -lt $maxRetries) {
            try {
                Write-Host "   🚀 Creating event-based retention label (attempt $($retryCount + 1) of $maxRetries)..." -ForegroundColor Cyan
                
                # Prepare parameters for New-ComplianceTag
                $tagParams = @{
                    Name              = $labelConfig.Name
                    Comment           = $labelConfig.Comment
                    RetentionDuration = $labelConfig.RetentionDuration
                    RetentionAction   = $labelConfig.RetentionAction
                    RetentionType     = $labelConfig.RetentionType
                    EventType         = $eventType.Name
                    IsRecordLabel     = $labelConfig.IsRecordLabel
                }
                
                # Create the retention label
                $newLabel = New-ComplianceTag @tagParams -ErrorAction Stop
                
                $labelCreated = $true
                Write-Host "   ✅ Event-based retention label created successfully" -ForegroundColor Green
                Write-Host "      Name: $($newLabel.Name)" -ForegroundColor Gray
                Write-Host "      Event Type: $($eventType.Name)" -ForegroundColor Gray
                Write-Host "      Retention: $([Math]::Round($newLabel.RetentionDuration / 365, 1)) years from event" -ForegroundColor Gray
                
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
        Write-Host "   ❌ Failed to create event-based retention label: $($labelConfig.Name)" -ForegroundColor Red
        Write-Host "      Error: $_" -ForegroundColor Red
        $failedLabels += $labelConfig
    }
    
    Write-Host ""
}

Write-Host "✅ Step 5 completed" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 6: Event-Based Label Publishing (Optional)
# =============================================================================

if ($PublishImmediately) {
    Write-Host "🔍 Step 6: Event-Based Label Publishing" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    if ($createdLabels.Count -eq 0) {
        Write-Host "   ⚠️  No new event-based labels to publish" -ForegroundColor Yellow
        Write-Host "      All labels already existed or creation failed" -ForegroundColor Yellow
    }
    else {
        Write-Host "📋 Publishing event-based retention labels for user application..." -ForegroundColor Cyan
        Write-Host ""
        
        try {
            # Create retention label policy name
            $policyName = "$LabelPrefix-EventBasedLabels-Policy"
            
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
                $newPolicy = New-RetentionCompliancePolicy -Name $policyName -Comment "Lab 3 event-based retention labels for manual user application" -ErrorAction Stop
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
                
                Write-Host "   ✅ Event-based retention labels published successfully" -ForegroundColor Green
            }
            
            Write-Host ""
            Write-Host "   Published event-based labels:" -ForegroundColor Cyan
            foreach ($label in $createdLabels) {
                Write-Host "   • $($label.Name)" -ForegroundColor White
            }
        }
        catch {
            Write-Host "   ❌ Failed to publish event-based retention labels" -ForegroundColor Red
            Write-Host "      Error: $_" -ForegroundColor Red
            Write-Host "      Labels are created but not published for manual user application" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "✅ Step 6 completed" -ForegroundColor Green
    Write-Host ""
}

# =============================================================================
# Step 7: Summary and Next Steps
# =============================================================================

Write-Host "🔍 Step 7: Summary and Next Steps" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Event-Based Retention Creation Summary:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Event Types:" -ForegroundColor White
Write-Host "   • Created: $($createdEventTypes.Count)" -ForegroundColor Green
Write-Host "   • Skipped: $($skippedEventTypes.Count)" -ForegroundColor Yellow
Write-Host "   • Failed: $($failedEventTypes.Count)" -ForegroundColor $(if ($failedEventTypes.Count -gt 0) { "Red" } else { "Green" })
Write-Host ""
Write-Host "   Event-Based Labels:" -ForegroundColor White
Write-Host "   • Created: $($createdLabels.Count)" -ForegroundColor Green
Write-Host "   • Skipped: $($skippedLabels.Count)" -ForegroundColor Yellow
Write-Host "   • Failed: $($failedLabels.Count)" -ForegroundColor $(if ($failedLabels.Count -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($createdEventTypes.Count -gt 0) {
    Write-Host "✅ Successfully created event types:" -ForegroundColor Green
    foreach ($eventType in $createdEventTypes) {
        Write-Host "   • $($eventType.Name)" -ForegroundColor White
    }
    Write-Host ""
}

if ($createdLabels.Count -gt 0) {
    Write-Host "✅ Successfully created event-based retention labels:" -ForegroundColor Green
    foreach ($label in $createdLabels) {
        $years = [Math]::Round($label.RetentionDuration / 365, 1)
        Write-Host "   • $($label.Name) ($years years from event)" -ForegroundColor White
    }
    Write-Host ""
}

Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host ""

Write-Host "   1. Verify event types and labels in Microsoft Purview compliance portal:" -ForegroundColor White
Write-Host "      https://compliance.microsoft.com/informationgovernance?viewid=retention" -ForegroundColor Gray
Write-Host ""

Write-Host "   2. Apply event-based retention labels to relevant content:" -ForegroundColor White
Write-Host "      Manually apply labels to content that should use event-based retention" -ForegroundColor Gray
Write-Host ""

Write-Host "   3. Trigger events when business milestones occur:" -ForegroundColor White
Write-Host "      Compliance portal → Records Management → Events → Create Event" -ForegroundColor Gray
Write-Host "      Provide event date and asset IDs (employee ID, contract number)" -ForegroundColor Gray
Write-Host ""

Write-Host "   4. Consider automation for event triggering (advanced):" -ForegroundColor White
Write-Host "      Integrate with HR/Contract systems via Power Automate or Logic Apps" -ForegroundColor Gray
Write-Host "      POST events to Microsoft Graph API for fully automated retention" -ForegroundColor Gray
Write-Host ""

Write-Host "   5. Monitor event-based retention effectiveness:" -ForegroundColor White
Write-Host "      Review Content Explorer to validate retention periods after events" -ForegroundColor Gray
Write-Host ""

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Event-Based Retention Creation Complete" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
