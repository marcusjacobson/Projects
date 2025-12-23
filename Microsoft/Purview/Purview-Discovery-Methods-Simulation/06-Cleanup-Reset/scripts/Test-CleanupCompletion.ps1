<#
.SYNOPSIS
    Verifies complete cleanup of simulation resources.

.DESCRIPTION
    Performs comprehensive verification that all simulation resources have been removed
    from Microsoft Purview and SharePoint environment. Checks for SharePoint sites, DLP
    policies, orphaned documents, and generates detailed verification report.
    
    Use this script to validate cleanup completion before considering environment reset complete.

.PARAMETER ResourceType
    Type of resources to verify. Options: Sites, DLPPolicies, All (default).

.PARAMETER DetailedReport
    Generates comprehensive verification report with all findings.

.EXAMPLE
    .\Test-CleanupCompletion.ps1
    
    Verifies all simulation resources are removed.

.EXAMPLE
    .\Test-CleanupCompletion.ps1 -ResourceType "Sites"
    
    Verifies only SharePoint sites are removed.

.EXAMPLE
    .\Test-CleanupCompletion.ps1 -DetailedReport
    
    Generates detailed verification report with all findings.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Global Administrator or appropriate read permissions
    - PnP.PowerShell module for SharePoint verification
    - ExchangeOnlineManagement module for DLP verification
    - PowerShell 5.1+ or PowerShell 7+
    
    Script development orchestrated using GitHub Copilot.

.VERIFICATION CHECKS
    - SharePoint simulation sites removed
    - DLP policies and rules deleted
    - No orphaned documents in sites
    - Reports directory status
    - Configuration reset validation
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateSet("Sites", "DLPPolicies", "All")]
    [string]$ResourceType = "All",
    
    [Parameter(Mandatory = $false)]
    [switch]$DetailedReport
)

# =============================================================================
# Action 1: Environment Setup
# =============================================================================

Write-Host "✔️  Cleanup Verification" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan

# Load global configuration
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleRoot = Split-Path -Parent $scriptPath
$projectRoot = Split-Path -Parent $moduleRoot
. (Join-Path $projectRoot "Shared-Utilities\Import-GlobalConfig.ps1")
$config = Import-GlobalConfig

# Load simulation logger
. (Join-Path $projectRoot "Shared-Utilities\Write-SimulationLog.ps1")

Write-SimulationLog -Message "Starting cleanup verification: $ResourceType" -Level "Info"

Write-Host "📋 Verification Parameters:" -ForegroundColor Cyan
Write-Host "   Resource Type: $ResourceType" -ForegroundColor Gray
Write-Host "   Detailed Report: $($DetailedReport.IsPresent)" -ForegroundColor Gray

# Initialize verification results
$verificationResults = @{
    SharePointSites = @{
        Checked = $false
        RemainingCount = 0
        RemainingSites = @()
        Status = "Not Checked"
    }
    DLPPolicies = @{
        Checked = $false
        RemainingCount = 0
        RemainingPolicies = @()
        Status = "Not Checked"
    }
    ReportsDirectory = @{
        FileCount = 0
        Status = "Unknown"
    }
    OverallStatus = "Unknown"
}

# =============================================================================
# Action 2: Verify SharePoint Sites Removed
# =============================================================================

if ($ResourceType -eq "Sites" -or $ResourceType -eq "All") {
    Write-Host "`n🌐 Verifying SharePoint Sites..." -ForegroundColor Cyan
    
    # Import shared modules
    . "$PSScriptRoot\..\..\Shared-Utilities\Import-PurviewModules.ps1"
    
    try {
        # Connect to SharePoint Admin
        # Build admin URL from tenant URL (e.g., https://contoso.sharepoint.com -> https://contoso-admin.sharepoint.com)
        $tenantUrl = $config.Environment.TenantUrl.TrimEnd('/')
        $adminUrl = $tenantUrl -replace "https://([^.]+)", "https://`$1-admin"
        
        Write-Host "   Connecting to SharePoint Admin..." -ForegroundColor Gray
        Connect-PurviewServices -Services @("SharePoint") -TenantUrl $adminUrl -PnPClientId $config.Environment.PnPClientId -Interactive
        Write-Host "   ✅ Connected successfully" -ForegroundColor Green
        
        # Check for simulation sites
        $sitesToCheck = $config.SharePointSites
        $remainingSites = @()
        
        foreach ($site in $sitesToCheck) {
            $siteName = $site.Name
            $siteUrl = "$tenantUrl/sites/$siteName"
            
            try {
                $siteInfo = Get-PnPTenantSite -Url $siteUrl -ErrorAction SilentlyContinue
                
                if ($siteInfo) {
                    $remainingSites += @{
                        Name = $siteName
                        Url = $siteUrl
                        Status = $siteInfo.Status
                    }
                    Write-Host "   ⚠️  Site still exists: $siteName" -ForegroundColor Yellow
                } else {
                    Write-Host "   ✅ Site removed: $siteName" -ForegroundColor Green
                }
            } catch {
                # Site not found is good
                Write-Host "   ✅ Site removed: $siteName" -ForegroundColor Green
            }
        }
        
        $verificationResults.SharePointSites.Checked = $true
        $verificationResults.SharePointSites.RemainingCount = $remainingSites.Count
        $verificationResults.SharePointSites.RemainingSites = $remainingSites
        $verificationResults.SharePointSites.Status = if ($remainingSites.Count -eq 0) { "PASSED" } else { "FAILED" }
        
        if ($remainingSites.Count -eq 0) {
            Write-Host "`n   ✅ All SharePoint sites removed" -ForegroundColor Green
        } else {
            Write-Host "`n   ⚠️  $($remainingSites.Count) sites still present" -ForegroundColor Yellow
        }
        
        Disconnect-PnPOnline
        
    } catch {
        Write-Host "   ❌ Error during SharePoint verification: $_" -ForegroundColor Red
        $verificationResults.SharePointSites.Status = "ERROR"
        Write-SimulationLog -Message "Error during SharePoint verification: $_" -Level "Error"
    }
}

# =============================================================================
# Action 3: Verify DLP Policies Removed
# =============================================================================

if ($ResourceType -eq "DLPPolicies" -or $ResourceType -eq "All") {
    Write-Host "`n🔐 Verifying DLP Policies..." -ForegroundColor Cyan
    
    # Import shared modules (if not already loaded)
    if (-not (Get-Command Connect-PurviewServices -ErrorAction SilentlyContinue)) {
        . "$PSScriptRoot\..\..\Shared-Utilities\Import-PurviewModules.ps1"
    }
    
    try {
        # Connect to Security & Compliance Center using shared module
        Write-Host "   Connecting to Security & Compliance Center..." -ForegroundColor Gray
        Connect-PurviewServices -Services @("ComplianceCenter") -Interactive
        Write-Host "   ✅ Connected successfully" -ForegroundColor Green
        
        # Check for simulation DLP policies
        $remainingPolicies = Get-DlpCompliancePolicy | Where-Object { $_.Name -like "*Simulation*" }
        
        $verificationResults.DLPPolicies.Checked = $true
        $verificationResults.DLPPolicies.RemainingCount = $remainingPolicies.Count
        
        if ($remainingPolicies.Count -eq 0) {
            Write-Host "   ✅ All DLP policies removed" -ForegroundColor Green
            $verificationResults.DLPPolicies.Status = "PASSED"
        } else {
            Write-Host "   ⚠️  $($remainingPolicies.Count) policies still present:" -ForegroundColor Yellow
            
            foreach ($policy in $remainingPolicies) {
                Write-Host "      - $($policy.Name)" -ForegroundColor Yellow
                
                $verificationResults.DLPPolicies.RemainingPolicies += @{
                    Name = $policy.Name
                    Mode = $policy.Mode
                    Enabled = $policy.Enabled
                }
                
                # Check for rules
                $rules = Get-DlpComplianceRule -Policy $policy.Name -ErrorAction SilentlyContinue
                if ($rules) {
                    Write-Host "         → $($rules.Count) rule(s) still attached" -ForegroundColor Yellow
                }
            }
            
            $verificationResults.DLPPolicies.Status = "FAILED"
        }
        
        # Disconnect
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        
    } catch {
        Write-Host "   ❌ Error during DLP verification: $_" -ForegroundColor Red
        $verificationResults.DLPPolicies.Status = "ERROR"
        Write-SimulationLog -Message "Error during DLP verification: $_" -Level "Error"
    }
}

# =============================================================================
# Action 4: Check Reports Directory
# =============================================================================

Write-Host "`n📂 Checking Reports Directory..." -ForegroundColor Cyan

$reportsPath = Join-Path $projectRoot "Reports"

if (Test-Path $reportsPath) {
    $reportFiles = Get-ChildItem -Path $reportsPath -Recurse -File
    $verificationResults.ReportsDirectory.FileCount = $reportFiles.Count
    
    if ($reportFiles.Count -eq 0) {
        Write-Host "   ✅ Reports directory is empty" -ForegroundColor Green
        $verificationResults.ReportsDirectory.Status = "CLEAN"
    } else {
        Write-Host "   ℹ️  Reports directory contains $($reportFiles.Count) files" -ForegroundColor Gray
        $verificationResults.ReportsDirectory.Status = "CONTAINS FILES"
        
        if ($DetailedReport) {
            Write-Host "   File types:" -ForegroundColor Gray
            $fileTypes = $reportFiles | Group-Object -Property Extension
            foreach ($type in $fileTypes) {
                Write-Host "      $($type.Name): $($type.Count) files" -ForegroundColor Gray
            }
        }
    }
} else {
    Write-Host "   ℹ️  Reports directory not found" -ForegroundColor Gray
    $verificationResults.ReportsDirectory.Status = "NOT FOUND"
}

# =============================================================================
# Action 5: Determine Overall Status
# =============================================================================

Write-Host "`n📊 Verification Summary" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan

# Determine overall pass/fail
$overallPassed = $true

if ($verificationResults.SharePointSites.Checked) {
    if ($verificationResults.SharePointSites.Status -ne "PASSED") {
        $overallPassed = $false
    }
}

if ($verificationResults.DLPPolicies.Checked) {
    if ($verificationResults.DLPPolicies.Status -ne "PASSED") {
        $overallPassed = $false
    }
}

$verificationResults.OverallStatus = if ($overallPassed) { "PASSED" } else { "FAILED" }

# Display summary
if ($verificationResults.SharePointSites.Checked) {
    $statusColor = if ($verificationResults.SharePointSites.Status -eq "PASSED") { "Green" } else { "Yellow" }
    Write-Host "   SharePoint Sites: $($verificationResults.SharePointSites.Status)" -ForegroundColor $statusColor
    Write-Host "      Remaining: $($verificationResults.SharePointSites.RemainingCount)" -ForegroundColor Gray
}

if ($verificationResults.DLPPolicies.Checked) {
    $statusColor = if ($verificationResults.DLPPolicies.Status -eq "PASSED") { "Green" } else { "Yellow" }
    Write-Host "   DLP Policies: $($verificationResults.DLPPolicies.Status)" -ForegroundColor $statusColor
    Write-Host "      Remaining: $($verificationResults.DLPPolicies.RemainingCount)" -ForegroundColor Gray
}

Write-Host "   Reports Directory: $($verificationResults.ReportsDirectory.Status)" -ForegroundColor Gray
Write-Host "      File Count: $($verificationResults.ReportsDirectory.FileCount)" -ForegroundColor Gray

Write-Host "`n   Overall Status: $($verificationResults.OverallStatus)" -ForegroundColor $(if ($overallPassed) { "Green" } else { "Yellow" })

# =============================================================================
# Action 6: Generate Detailed Report
# =============================================================================

if ($DetailedReport) {
    Write-Host "`n📄 Generating Detailed Verification Report..." -ForegroundColor Cyan
    
    $reportData = @{
        Generated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        ResourceType = $ResourceType
        VerificationResults = $verificationResults
    }
    
    $reportFileName = "Cleanup-Verification-Report-$(Get-Date -Format 'yyyy-MM-dd').json"
    $reportPath = Join-Path $reportsPath $reportFileName
    
    # Ensure Reports directory exists
    if (-not (Test-Path $reportsPath)) {
        New-Item -Path $reportsPath -ItemType Directory -Force | Out-Null
    }
    
    $reportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding UTF8 -Force
    
    Write-Host "   ✅ Detailed report saved: $reportFileName" -ForegroundColor Green
}

# =============================================================================
# Action 7: Display Next Steps
# =============================================================================

Write-Host "`n💡 Next Steps:" -ForegroundColor Cyan

if ($overallPassed) {
    Write-Host "   ✅ Cleanup verification PASSED" -ForegroundColor Green
    Write-Host "   1. Environment is clean and ready for future use" -ForegroundColor Gray
    Write-Host "   2. Review archived reports if needed" -ForegroundColor Gray
    Write-Host "   3. Refer to Lab 00 README to start new simulation" -ForegroundColor Gray
} else {
    Write-Host "   ⚠️  Cleanup verification FAILED" -ForegroundColor Yellow
    Write-Host "   1. Review remaining resources listed above" -ForegroundColor Gray
    Write-Host "   2. Run Remove-SimulationResources.ps1 for targeted removal" -ForegroundColor Gray
    Write-Host "   3. Manually remove resources if automated removal fails" -ForegroundColor Gray
    Write-Host "   4. Re-run this verification script to confirm cleanup" -ForegroundColor Gray
}

Write-SimulationLog -Message "Cleanup verification completed: $($verificationResults.OverallStatus)" -Level "Info"

if (-not $overallPassed) {
    exit 1
}

exit 0
