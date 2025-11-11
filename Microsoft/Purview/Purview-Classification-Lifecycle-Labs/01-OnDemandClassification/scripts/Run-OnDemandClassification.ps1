<#
.SYNOPSIS
    Initiates On-Demand Classification scan for SharePoint sites and OneDrive locations in Microsoft Purview.

.DESCRIPTION
    This script connects to Security & Compliance PowerShell and triggers immediate re-indexing
    and classification of SharePoint Online sites or OneDrive for Business locations using the
    Start-RetentionAutoLabelSimulation cmdlet.
    
    On-Demand Classification forces Purview's classification engine to immediately scan specified
    locations instead of waiting for the default 7-day indexing cycle. This is useful for:
    - Lab testing and validation of custom SITs
    - Immediate classification after uploading new sensitive content
    - Troubleshooting classification rules and retention policies
    - Enterprise migrations requiring immediate sensitivity detection
    
    The script supports multiple target types (SharePoint sites, OneDrive accounts) and provides
    detailed progress tracking and validation reporting.

.PARAMETER TargetType
    Type of location to classify: "SharePoint" or "OneDrive" (default: SharePoint).

.PARAMETER SiteUrl
    Full URL of SharePoint site to classify (required if TargetType is SharePoint).
    Example: https://contoso.sharepoint.com/sites/PurviewLab

.PARAMETER OneDriveUrl
    Full URL of OneDrive for Business location (required if TargetType is OneDrive).
    Example: https://contoso-my.sharepoint.com/personal/user_contoso_com

.PARAMETER WaitForCompletion
    Wait and monitor the classification job until completion (default: $false).

.EXAMPLE
    .\Run-OnDemandClassification.ps1 -TargetType SharePoint -SiteUrl "https://contoso.sharepoint.com/sites/PurviewLab"
    
    Initiates On-Demand Classification for specified SharePoint site.

.EXAMPLE
    .\Run-OnDemandClassification.ps1 -TargetType SharePoint -SiteUrl "https://contoso.sharepoint.com/sites/PurviewLab" -WaitForCompletion
    
    Initiates classification and monitors progress until completion (may take 15-60 minutes).

.EXAMPLE
    .\Run-OnDemandClassification.ps1 -TargetType OneDrive -OneDriveUrl "https://contoso-my.sharepoint.com/personal/jsmith_contoso_com"
    
    Initiates On-Demand Classification for specified OneDrive location.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-11
    Last Modified: 2025-11-11
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - ExchangeOnlineManagement module v3.0.0 or later
    - Security & Compliance PowerShell access
    - Microsoft 365 E5 or Compliance add-on license
    - Appropriate permissions: Compliance Administrator or Information Protection Administrator role
    
    Processing Timeline:
    - Job Submission: Immediate (< 1 minute)
    - Indexing Start: 5-15 minutes after submission
    - Classification Processing: 15-60 minutes (depends on content volume)
    - Content Explorer Update: Additional 15-30 minutes after classification
    
    Script development orchestrated using GitHub Copilot.

.INTEGRATION POINTS
    - Security & Compliance PowerShell: Classification job management
    - SharePoint Online: Site and library scanning
    - OneDrive for Business: Personal storage classification
    - Content Explorer: Classification result validation
    - Activity Explorer: Classification activity monitoring
#>
#
# =============================================================================
# Initiate On-Demand Classification for SharePoint and OneDrive locations
# using Microsoft Purview Information Protection engine
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateSet("SharePoint", "OneDrive")]
    [string]$TargetType = "SharePoint",
    
    [Parameter(Mandatory = $false)]
    [string]$SiteUrl = "",
    
    [Parameter(Mandatory = $false)]
    [string]$OneDriveUrl = "",
    
    [Parameter(Mandatory = $false)]
    [switch]$WaitForCompletion
)

# =============================================================================
# Step 1: Parameter Validation
# =============================================================================

Write-Host "🔍 Step 1: Parameter Validation" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

Write-Host "📋 Validating input parameters..." -ForegroundColor Cyan

try {
    if ($TargetType -eq "SharePoint") {
        if ([string]::IsNullOrWhiteSpace($SiteUrl)) {
            Write-Host "   ❌ SiteUrl parameter is required when TargetType is SharePoint" -ForegroundColor Red
            throw "SiteUrl parameter is required for SharePoint classification"
        }
        
        # Validate SharePoint URL format
        if (-not ($SiteUrl -match '^https://[^/]+\.sharepoint\.com/sites/[^/]+/?$')) {
            Write-Host "   ⚠️  Warning: SiteUrl may not be in standard SharePoint format" -ForegroundColor Yellow
            Write-Host "   📋 Expected format: https://tenant.sharepoint.com/sites/sitename" -ForegroundColor Yellow
        }
        
        Write-Host "   ✅ Target Type: SharePoint" -ForegroundColor Green
        Write-Host "   ✅ Site URL: $SiteUrl" -ForegroundColor Green
        
    } elseif ($TargetType -eq "OneDrive") {
        if ([string]::IsNullOrWhiteSpace($OneDriveUrl)) {
            Write-Host "   ❌ OneDriveUrl parameter is required when TargetType is OneDrive" -ForegroundColor Red
            throw "OneDriveUrl parameter is required for OneDrive classification"
        }
        
        # Validate OneDrive URL format
        if (-not ($OneDriveUrl -match '^https://[^/]+-my\.sharepoint\.com/personal/[^/]+/?$')) {
            Write-Host "   ⚠️  Warning: OneDriveUrl may not be in standard OneDrive format" -ForegroundColor Yellow
            Write-Host "   📋 Expected format: https://tenant-my.sharepoint.com/personal/user_tenant_com" -ForegroundColor Yellow
        }
        
        Write-Host "   ✅ Target Type: OneDrive" -ForegroundColor Green
        Write-Host "   ✅ OneDrive URL: $OneDriveUrl" -ForegroundColor Green
    }
    
    if ($WaitForCompletion) {
        Write-Host "   ✅ Wait Mode: Enabled (script will monitor until completion)" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  Wait Mode: Disabled (script will exit after job submission)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "   ❌ Parameter validation failed: $_" -ForegroundColor Red
    throw
}

Write-Host ""

# =============================================================================
# Step 2: Environment Validation
# =============================================================================

Write-Host "🔍 Step 2: Environment Validation" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

Write-Host "📋 Validating PowerShell modules..." -ForegroundColor Cyan
try {
    $moduleName = "ExchangeOnlineManagement"
    $module = Get-Module -ListAvailable -Name $moduleName | Select-Object -First 1
    
    if ($null -eq $module) {
        Write-Host "   ❌ $moduleName module not found" -ForegroundColor Red
        Write-Host "   💡 Install with: Install-Module -Name $moduleName -Scope CurrentUser" -ForegroundColor Yellow
        throw "$moduleName module is required but not installed"
    }
    
    Write-Host "   ✅ $moduleName module found (version $($module.Version))" -ForegroundColor Green
    
    if (-not (Get-Module -Name $moduleName)) {
        Import-Module $moduleName -ErrorAction Stop
        Write-Host "   ✅ $moduleName module imported successfully" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  $moduleName module already loaded" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "   ❌ Module validation failed: $_" -ForegroundColor Red
    throw
}

Write-Host ""

# =============================================================================
# Step 3: Connect to Security & Compliance PowerShell
# =============================================================================

Write-Host "🔐 Step 3: Connecting to Security & Compliance PowerShell" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

try {
    $existingConnection = Get-ConnectionInformation -ErrorAction SilentlyContinue | Where-Object { $_.ConnectionUri -like "*protection.outlook.com*" }
    
    if ($existingConnection) {
        Write-Host "   ℹ️  Already connected to Security & Compliance PowerShell" -ForegroundColor Cyan
        Write-Host "   📧 Connected as: $($existingConnection.UserPrincipalName)" -ForegroundColor Cyan
    } else {
        Write-Host "   🔑 Initiating connection (browser authentication will open)..." -ForegroundColor Cyan
        Connect-IPPSSession -WarningAction SilentlyContinue -ErrorAction Stop
        
        $newConnection = Get-ConnectionInformation -ErrorAction Stop | Where-Object { $_.ConnectionUri -like "*protection.outlook.com*" }
        Write-Host "   ✅ Connected successfully to Security & Compliance PowerShell" -ForegroundColor Green
        Write-Host "   📧 Connected as: $($newConnection.UserPrincipalName)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "   ❌ Connection failed: $_" -ForegroundColor Red
    throw "Unable to connect to Security & Compliance PowerShell"
}

Write-Host ""

# =============================================================================
# Step 4: Initiate On-Demand Classification
# =============================================================================

Write-Host "📋 Step 4: Initiating On-Demand Classification" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

$targetUrl = if ($TargetType -eq "SharePoint") { $SiteUrl } else { $OneDriveUrl }

try {
    Write-Host "📋 Submitting On-Demand Classification job..." -ForegroundColor Cyan
    Write-Host "   🎯 Target: $targetUrl" -ForegroundColor Cyan
    Write-Host "   🔍 Type: $TargetType" -ForegroundColor Cyan
    Write-Host ""
    
    # Initiate classification simulation (forces re-indexing and classification)
    Write-Host "   ⏱️  Starting classification job (this may take a moment)..." -ForegroundColor Cyan
    
    $classificationJob = Start-RetentionAutoLabelSimulation -SharePointLocation $targetUrl -ErrorAction Stop
    
    Write-Host "   ✅ On-Demand Classification job submitted successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "   📊 Job Details:" -ForegroundColor Cyan
    Write-Host "      Job ID: $($classificationJob.Identity)" -ForegroundColor White
    Write-Host "      Target Location: $targetUrl" -ForegroundColor White
    Write-Host "      Job Type: On-Demand Classification" -ForegroundColor White
    Write-Host "      Status: $($classificationJob.Status)" -ForegroundColor White
    Write-Host "      Submission Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
    
} catch {
    Write-Host "   ❌ Failed to initiate On-Demand Classification: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Troubleshooting Tips:" -ForegroundColor Yellow
    Write-Host "      - Verify site URL is correct and accessible" -ForegroundColor White
    Write-Host "      - Ensure you have Compliance Administrator or higher role" -ForegroundColor White
    Write-Host "      - Check that the site is indexed in SharePoint" -ForegroundColor White
    Write-Host "      - Verify Microsoft 365 E5 or Compliance add-on license" -ForegroundColor White
    throw
}

Write-Host ""

# =============================================================================
# Step 5: Monitor Classification Job (Optional)
# =============================================================================

if ($WaitForCompletion) {
    Write-Host "⏱️  Step 5: Monitoring Classification Job Progress" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📋 Starting job monitoring (press Ctrl+C to cancel monitoring)..." -ForegroundColor Cyan
    Write-Host "   ℹ️  Classification typically takes 15-60 minutes depending on content volume" -ForegroundColor Cyan
    Write-Host ""
    
    $jobComplete = $false
    $checkInterval = 60  # Check every 60 seconds
    $maxChecks = 120     # Max 2 hours of monitoring
    $checkCount = 0
    
    try {
        while (-not $jobComplete -and $checkCount -lt $maxChecks) {
            $checkCount++
            Start-Sleep -Seconds $checkInterval
            
            # Query job status
            $jobStatus = Get-RetentionAutoLabelSimulation -Identity $classificationJob.Identity -ErrorAction SilentlyContinue
            
            if ($jobStatus) {
                $elapsed = $checkCount * $checkInterval
                $elapsedMinutes = [math]::Floor($elapsed / 60)
                $elapsedSeconds = $elapsed % 60
                
                Write-Host "   ⏱️  Elapsed: $elapsedMinutes min $elapsedSeconds sec | Status: $($jobStatus.Status)" -ForegroundColor Cyan
                
                # Check for completion
                if ($jobStatus.Status -eq "Completed" -or $jobStatus.Status -eq "CompletedWithErrors") {
                    $jobComplete = $true
                    Write-Host ""
                    Write-Host "   ✅ Classification job completed!" -ForegroundColor Green
                    Write-Host "   📊 Final Status: $($jobStatus.Status)" -ForegroundColor Cyan
                    Write-Host "   📊 Items Processed: $($jobStatus.ItemsProcessed)" -ForegroundColor Cyan
                    Write-Host "   📊 Items Classified: $($jobStatus.ItemsClassified)" -ForegroundColor Cyan
                    
                    if ($jobStatus.Status -eq "CompletedWithErrors") {
                        Write-Host "   ⚠️  Job completed with errors - review logs in Compliance Portal" -ForegroundColor Yellow
                    }
                } elseif ($jobStatus.Status -eq "Failed") {
                    Write-Host ""
                    Write-Host "   ❌ Classification job failed" -ForegroundColor Red
                    Write-Host "   📋 Error: $($jobStatus.Error)" -ForegroundColor Red
                    break
                }
            } else {
                Write-Host "   ⚠️  Unable to retrieve job status (may be transient issue)" -ForegroundColor Yellow
            }
        }
        
        if (-not $jobComplete -and $checkCount -ge $maxChecks) {
            Write-Host ""
            Write-Host "   ⏱️  Monitoring timeout reached (2 hours)" -ForegroundColor Yellow
            Write-Host "   ℹ️  Job is still processing - check Compliance Portal for status" -ForegroundColor Cyan
        }
        
    } catch {
        Write-Host "   ⚠️  Monitoring interrupted: $_" -ForegroundColor Yellow
        Write-Host "   ℹ️  Job continues processing - check Compliance Portal for status" -ForegroundColor Cyan
    }
    
    Write-Host ""
}

# =============================================================================
# Step 6: Display Summary and Next Steps
# =============================================================================

Write-Host "📋 Step 6: Summary and Next Steps" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ On-Demand Classification job submitted successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Processing Timeline:" -ForegroundColor Cyan
Write-Host "   ⏱️  Job Submission: Completed (now)" -ForegroundColor White
Write-Host "   ⏱️  Indexing Start: 5-15 minutes" -ForegroundColor White
Write-Host "   ⏱️  Classification Processing: 15-60 minutes" -ForegroundColor White
Write-Host "   ⏱️  Content Explorer Update: Additional 15-30 minutes" -ForegroundColor White
Write-Host "   ⏱️  Total Expected Time: 35-105 minutes from submission" -ForegroundColor White
Write-Host ""

Write-Host "🔍 Validation Locations:" -ForegroundColor Cyan
Write-Host "   1. Compliance Portal > Data Classification > Content Explorer" -ForegroundColor White
Write-Host "      - View classified documents by Sensitive Information Type" -ForegroundColor White
Write-Host "      - Filter by location: $targetUrl" -ForegroundColor White
Write-Host ""
Write-Host "   2. Compliance Portal > Data Classification > Activity Explorer" -ForegroundColor White
Write-Host "      - View classification activities and timestamps" -ForegroundColor White
Write-Host "      - Filter by Activity: Label applied" -ForegroundColor White
Write-Host ""
Write-Host "   3. SharePoint Site > Document Library > Column: Sensitivity" -ForegroundColor White
Write-Host "      - View sensitivity labels directly in SharePoint UI" -ForegroundColor White
Write-Host ""

Write-Host "⏭️  Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Wait 35-60 minutes for initial classification processing" -ForegroundColor White
Write-Host "   2. Run validation script: .\Validate-ClassificationResults.ps1" -ForegroundColor White
Write-Host "   3. Review classification results in Content Explorer" -ForegroundColor White
Write-Host "   4. Check Activity Explorer for classification activity logs" -ForegroundColor White
Write-Host "   5. Return to Lab 1 README.md Step 4 for detailed validation procedures" -ForegroundColor White
Write-Host ""

Write-Host "💡 Production Tips:" -ForegroundColor Yellow
Write-Host "   - On-Demand Classification bypasses 7-day default indexing cycle" -ForegroundColor White
Write-Host "   - Use for immediate classification after content uploads or SIT changes" -ForegroundColor White
Write-Host "   - Limit usage to specific sites to avoid excessive processing load" -ForegroundColor White
Write-Host "   - Monitor job status in Compliance Portal > Information Protection > Auto-labeling" -ForegroundColor White
Write-Host ""

Write-Host "📚 Additional Resources:" -ForegroundColor Cyan
Write-Host "   - On-Demand Classification: https://learn.microsoft.com/purview/classification-on-demand" -ForegroundColor White
Write-Host "   - Content Explorer: https://learn.microsoft.com/purview/data-classification-content-explorer" -ForegroundColor White
Write-Host "   - Activity Explorer: https://learn.microsoft.com/purview/data-classification-activity-explorer" -ForegroundColor White
Write-Host ""

Write-Host "✅ Script execution completed successfully" -ForegroundColor Green
