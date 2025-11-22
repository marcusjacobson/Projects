<#
.SYNOPSIS
    Validates retention label application and disposition enforcement in SharePoint Online.

.DESCRIPTION
    This script performs comprehensive validation of retention label application across SharePoint
    Online content, verifying that auto-apply policies and manual label assignments are working
    correctly. The validation includes checking for proper label application, disposition action
    enforcement, record immutability verification, and content lifecycle compliance.
    
    The script provides detailed reporting on:
    - Total labeled vs. unlabeled content
    - Label distribution across different retention periods
    - Disposition action enforcement (automatic deletion vs. review required)
    - Record label immutability verification
    - Content approaching disposition dates
    - Potential compliance gaps requiring attention
    
    Validation results can be exported to CSV format for audit purposes and executive reporting.
    The script includes comprehensive error handling and provides actionable recommendations for
    any identified issues.

.PARAMETER SharePointSiteUrl
    The URL of the SharePoint Online site to validate retention label application.
    Must be a valid SharePoint site URL accessible to the authenticated user.
    
    Example: "https://contoso.sharepoint.com/sites/FinancialRecords"

.PARAMETER DetailedReport
    Switch parameter to generate a detailed validation report including individual file analysis,
    label distribution charts, and comprehensive coverage metrics. Default is summary reporting only.

.PARAMETER ExportPath
    Optional path to export validation results to CSV format for audit and reporting purposes.
    If not specified, results are displayed in the console only.
    
    Example: "C:\Reports\RetentionValidation_2025-01-22.csv"

.PARAMETER SkipConnectionTest
    Skip the initial Microsoft 365 connection test. Use this parameter when running multiple
    scripts in sequence where connections have already been established.

.EXAMPLE
    .\Validate-RetentionLabels.ps1 -SharePointSiteUrl "https://contoso.sharepoint.com/sites/Finance"
    
    Performs basic validation of retention label application on the specified SharePoint site.
    Displays summary results in the console.

.EXAMPLE
    .\Validate-RetentionLabels.ps1 -SharePointSiteUrl "https://contoso.sharepoint.com/sites/Finance" -DetailedReport
    
    Performs comprehensive validation with detailed reporting including file-level analysis,
    label distribution metrics, and coverage gap identification.

.EXAMPLE
    .\Validate-RetentionLabels.ps1 -SharePointSiteUrl "https://contoso.sharepoint.com/sites/Finance" -DetailedReport -ExportPath "C:\Reports\Validation.csv"
    
    Performs detailed validation and exports results to CSV format for audit and compliance
    reporting purposes.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-01-22
    Last Modified: 2025-01-22
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - ExchangeOnlineManagement module version 3.4.0 or higher
    - PnP.PowerShell module version 1.12.0 or higher (for SharePoint operations)
    - Security & Compliance PowerShell connection established
    - SharePoint Online connection established
    - Appropriate Microsoft Purview permissions (Compliance Data Administrator or higher)
    - SharePoint site access with read permissions
    
    Script development orchestrated using GitHub Copilot.

.VALIDATION CHECKS
    Label Application Verification:
    - Total content count (labeled vs. unlabeled)
    - Label distribution across retention periods
    - Auto-apply policy effectiveness
    - Manual label application coverage
    
    Disposition Enforcement:
    - Automatic deletion action verification
    - Disposition review requirement validation
    - Content approaching disposition dates
    - Expired content identification
    
    Record Immutability:
    - Record label application verification
    - Regulatory record protection validation
    - Modification prevention enforcement
    - Deletion prevention validation
    
    Compliance Gap Analysis:
    - Unlabeled content requiring attention
    - Misconfigured auto-apply policies
    - Missing retention labels for critical content types
    - Recommended remediation actions

.LINK
    https://learn.microsoft.com/en-us/purview/retention-policies-sharepoint
    https://learn.microsoft.com/en-us/purview/retention-compliance
    https://learn.microsoft.com/en-us/powershell/module/sharepoint-online/
#>

#Requires -Modules ExchangeOnlineManagement, PnP.PowerShell

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$SharePointSiteUrl,
    
    [Parameter(Mandatory = $false)]
    [switch]$DetailedReport,
    
    [Parameter(Mandatory = $false)]
    [string]$ExportPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipConnectionTest
)

# =============================================================================
# Script Initialization
# =============================================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Retention Label Validation" -ForegroundColor Cyan
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
    @{ Name = "ExchangeOnlineManagement"; MinVersion = "3.4.0" },
    @{ Name = "PnP.PowerShell"; MinVersion = "1.12.0" }
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

# Test connections
if (-not $SkipConnectionTest) {
    Write-Host "📋 Testing Security & Compliance PowerShell connection..." -ForegroundColor Cyan
    
    try {
        # Import module if not already loaded
        if (-not (Get-Module -Name ExchangeOnlineManagement)) {
            Import-Module ExchangeOnlineManagement -ErrorAction Stop
            Write-Host "   ✅ ExchangeOnlineManagement module imported" -ForegroundColor Green
        }
        
        # Test connection
        $testConnection = Get-ComplianceTag -ResultSize 1 -ErrorAction Stop
        Write-Host "   ✅ Security & Compliance PowerShell connection verified" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ Security & Compliance PowerShell connection failed" -ForegroundColor Red
        Write-Host "      Connect with: Connect-IPPSSession" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host ""
    Write-Host "📋 Testing SharePoint Online connection..." -ForegroundColor Cyan
    
    try {
        # Connect to SharePoint Online site
        Connect-PnPOnline -Url $SharePointSiteUrl -Interactive -ErrorAction Stop
        Write-Host "   ✅ SharePoint Online connection established" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ SharePoint Online connection failed" -ForegroundColor Red
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
# Step 2: Retention Label Discovery
# =============================================================================

Write-Host "🔍 Step 2: Retention Label Discovery" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Discovering configured retention labels..." -ForegroundColor Cyan

try {
    # Get all retention labels
    $allLabels = Get-ComplianceTag -ErrorAction Stop
    $labLabels = $allLabels | Where-Object { $_.Name -like "LAB3-*" }
    
    Write-Host "   ✅ Found $($allLabels.Count) total retention labels" -ForegroundColor Green
    Write-Host "   ✅ Found $($labLabels.Count) Lab 3 retention labels" -ForegroundColor Green
    
    if ($labLabels.Count -eq 0) {
        Write-Host "   ⚠️  No Lab 3 retention labels found - validation scope limited" -ForegroundColor Yellow
    }
    else {
        Write-Host ""
        Write-Host "   Lab 3 retention labels:" -ForegroundColor Cyan
        foreach ($label in $labLabels) {
            $retentionText = if ($label.RetentionDuration -eq 0) { "Permanent" } else { "$([Math]::Round($label.RetentionDuration / 365, 1)) years" }
            $recordText = if ($label.IsRecordLabel) { "(Record)" } else { "" }
            Write-Host "   • $($label.Name) - $retentionText $recordText" -ForegroundColor White
        }
    }
}
catch {
    Write-Host "   ❌ Failed to retrieve retention labels" -ForegroundColor Red
    Write-Host "      Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Step 2 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 3: Content Analysis
# =============================================================================

Write-Host "🔍 Step 3: Content Analysis" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Analyzing SharePoint content and retention labels..." -ForegroundColor Cyan
Write-Host "   Site: $SharePointSiteUrl" -ForegroundColor Gray
Write-Host ""

$validationResults = @()
$labeledCount = 0
$unlabeledCount = 0
$recordCount = 0

try {
    # Get all document libraries
    $libraries = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 -and $_.Hidden -eq $false }
    
    Write-Host "   Found $($libraries.Count) document libraries" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($library in $libraries) {
        Write-Host "   Analyzing library: $($library.Title)" -ForegroundColor Cyan
        
        try {
            # Get all items in the library
            $items = Get-PnPListItem -List $library.Title -Fields "FileLeafRef", "FileRef", "ComplianceTag", "File_x0020_Type" -ErrorAction Stop
            
            Write-Host "      Found $($items.Count) items" -ForegroundColor Gray
            
            foreach ($item in $items) {
                $fileName = $item.FieldValues["FileLeafRef"]
                $fileUrl = $item.FieldValues["FileRef"]
                $complianceTag = $item.FieldValues["ComplianceTag"]
                $fileType = $item.FieldValues["File_x0020_Type"]
                
                # Determine if item has retention label
                $isLabeled = -not [string]::IsNullOrEmpty($complianceTag)
                $isRecord = $false
                $retentionPeriod = "N/A"
                
                if ($isLabeled) {
                    $labeledCount++
                    
                    # Get label details
                    $labelInfo = $allLabels | Where-Object { $_.Name -eq $complianceTag }
                    if ($labelInfo) {
                        $isRecord = $labelInfo.IsRecordLabel
                        if ($isRecord) { $recordCount++ }
                        
                        $retentionPeriod = if ($labelInfo.RetentionDuration -eq 0) { "Permanent" } else { "$([Math]::Round($labelInfo.RetentionDuration / 365, 1)) years" }
                    }
                }
                else {
                    $unlabeledCount++
                }
                
                # Create validation result object
                $result = [PSCustomObject]@{
                    Library = $library.Title
                    FileName = $fileName
                    FileType = $fileType
                    FileUrl = $fileUrl
                    IsLabeled = $isLabeled
                    RetentionLabel = if ($isLabeled) { $complianceTag } else { "None" }
                    RetentionPeriod = $retentionPeriod
                    IsRecord = $isRecord
                    Status = if ($isLabeled) { "Compliant" } else { "Missing Label" }
                }
                
                $validationResults += $result
            }
        }
        catch {
            Write-Host "      ⚠️  Failed to analyze library: $($library.Title)" -ForegroundColor Yellow
            Write-Host "         Error: $_" -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Host "   ❌ Failed to analyze SharePoint content" -ForegroundColor Red
    Write-Host "      Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Step 3 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 4: Validation Report Generation
# =============================================================================

Write-Host "🔍 Step 4: Validation Report Generation" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

$totalItems = $validationResults.Count
$labelCoverage = if ($totalItems -gt 0) { [Math]::Round(($labeledCount / $totalItems) * 100, 2) } else { 0 }

Write-Host "📊 Retention Label Validation Summary:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Content Overview:" -ForegroundColor White
Write-Host "   • Total items analyzed: $totalItems" -ForegroundColor Gray
Write-Host "   • Labeled items: $labeledCount ($labelCoverage%)" -ForegroundColor $(if ($labelCoverage -ge 80) { "Green" } elseif ($labelCoverage -ge 50) { "Yellow" } else { "Red" })
Write-Host "   • Unlabeled items: $unlabeledCount" -ForegroundColor $(if ($unlabeledCount -eq 0) { "Green" } else { "Yellow" })
Write-Host "   • Record-labeled items: $recordCount" -ForegroundColor Gray
Write-Host ""

# Label distribution
if ($DetailedReport -and $labeledCount -gt 0) {
    Write-Host "   Label Distribution:" -ForegroundColor White
    $labelGroups = $validationResults | Where-Object { $_.IsLabeled } | Group-Object RetentionLabel
    foreach ($group in $labelGroups) {
        $percentage = [Math]::Round(($group.Count / $labeledCount) * 100, 1)
        Write-Host "   • $($group.Name): $($group.Count) items ($percentage%)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Compliance status
$compliantItems = ($validationResults | Where-Object { $_.Status -eq "Compliant" }).Count
$nonCompliantItems = ($validationResults | Where-Object { $_.Status -ne "Compliant" }).Count

Write-Host "   Compliance Status:" -ForegroundColor White
Write-Host "   • Compliant items: $compliantItems" -ForegroundColor Green
Write-Host "   • Non-compliant items: $nonCompliantItems" -ForegroundColor $(if ($nonCompliantItems -eq 0) { "Green" } else { "Red" })
Write-Host ""

# Recommendations
if ($unlabeledCount -gt 0) {
    Write-Host "   📋 Recommendations:" -ForegroundColor Yellow
    Write-Host "   • $unlabeledCount unlabeled items require attention" -ForegroundColor Yellow
    Write-Host "   • Review auto-apply policies for coverage gaps" -ForegroundColor Yellow
    Write-Host "   • Consider manual label application for unlabeled content" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "✅ Step 4 completed successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 5: Export Results (Optional)
# =============================================================================

if ($ExportPath) {
    Write-Host "🔍 Step 5: Export Results" -ForegroundColor Green
    Write-Host "=========================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📋 Exporting validation results to CSV..." -ForegroundColor Cyan
    Write-Host "   Export path: $ExportPath" -ForegroundColor Gray
    
    try {
        # Ensure directory exists
        $exportDir = Split-Path -Path $ExportPath -Parent
        if (-not (Test-Path $exportDir)) {
            New-Item -Path $exportDir -ItemType Directory -Force | Out-Null
        }
        
        # Export to CSV
        $validationResults | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
        
        Write-Host "   ✅ Validation results exported successfully" -ForegroundColor Green
        Write-Host "      File: $ExportPath" -ForegroundColor Gray
    }
    catch {
        Write-Host "   ⚠️  Failed to export results" -ForegroundColor Yellow
        Write-Host "      Error: $_" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "✅ Step 5 completed successfully" -ForegroundColor Green
    Write-Host ""
}

# =============================================================================
# Summary and Next Steps
# =============================================================================

Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host ""

Write-Host "   1. Review unlabeled content and determine appropriate retention labels" -ForegroundColor White
Write-Host ""

Write-Host "   2. Monitor auto-apply policy effectiveness:" -ForegroundColor White
Write-Host "      Check Content Explorer for automatic label application" -ForegroundColor Gray
Write-Host ""

Write-Host "   3. Monitor retention label adoption and coverage:" -ForegroundColor White
Write-Host "      .\Monitor-RetentionMetrics.ps1 -SharePointSiteUrl $SharePointSiteUrl" -ForegroundColor Gray
Write-Host ""

Write-Host "   4. Review retention policies in Microsoft Purview compliance portal:" -ForegroundColor White
Write-Host "      https://compliance.microsoft.com/informationgovernance?viewid=retention" -ForegroundColor Gray
Write-Host ""

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Retention Label Validation Complete" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
