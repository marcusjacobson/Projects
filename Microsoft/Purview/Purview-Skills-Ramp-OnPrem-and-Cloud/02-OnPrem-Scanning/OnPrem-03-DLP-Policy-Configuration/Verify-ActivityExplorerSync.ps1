<#
.SYNOPSIS
    Validates Activity Explorer readiness and DLP event visibility after policy sync.

.DESCRIPTION
    This verification script provides guidance for checking Microsoft Purview Activity Explorer
    to confirm that DLP policy synchronization has completed and DLP events from on-premises
    scanner are visible. Since Activity Explorer can only be checked through the portal, this
    script provides detailed instructions and validation criteria for manual verification.

.EXAMPLE
    .\Verify-ActivityExplorerSync.ps1
    
    Displays instructions for verifying DLP event visibility in Activity Explorer.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-10
    Last Modified: 2025-11-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - DLP scan completed with Start-DLPScanWithReset.ps1
    - 1-2 hours wait time after scan completion
    - Access to Microsoft Purview compliance portal
    - Microsoft 365 auditing enabled (prerequisite for Activity Explorer)
    
    Script development orchestrated using GitHub Copilot.

.ACTIVITY EXPLORER
    - Portal-based only: No PowerShell cmdlets available for Activity Explorer
    - Manual verification: User must check portal for DLP events
    - Expected timeline: 1-2 hours after scan completion
    - Success indicator: DLP events with sensitive info types visible
#>

[CmdletBinding()]
param()

# =============================================================================
# Verification: Activity Explorer Sync Status
# =============================================================================

Write-Host "`n📊 Activity Explorer Sync Verification Guide" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Step 1: Check local prerequisites
Write-Host "`n📋 Step 1: Verifying local prerequisites..." -ForegroundColor Cyan

# Check latest scan completion
try {
    $reportsPath = "C:\Users\scanner-svc\AppData\Local\Microsoft\MSIP\Scanner\Reports"
    $latestReport = Get-ChildItem $reportsPath -Filter "DetailedReport_*.csv" -ErrorAction SilentlyContinue | 
                    Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    if ($latestReport) {
        $reportAge = (Get-Date) - $latestReport.LastWriteTime
        $hoursSinceScan = [math]::Floor($reportAge.TotalHours)
        $minutesSinceScan = $reportAge.Minutes
        
        Write-Host "   Latest DLP scan report:" -ForegroundColor Green
        Write-Host "      Report: $($latestReport.Name)" -ForegroundColor Gray
        Write-Host "      Created: $($latestReport.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
        Write-Host "      Age: $hoursSinceScan hours, $minutesSinceScan minutes" -ForegroundColor Gray
        
        if ($reportAge.TotalHours -lt 1) {
            Write-Host "`n   ⚠️  Recent scan completed less than 1 hour ago" -ForegroundColor Yellow
            Write-Host "   Activity Explorer sync typically requires 1-2 hours" -ForegroundColor Gray
            Write-Host "   Recommended: Wait until scan is at least 1 hour old" -ForegroundColor Gray
        } elseif ($reportAge.TotalHours -lt 2) {
            Write-Host "`n   📋 Scan completed 1-2 hours ago" -ForegroundColor Cyan
            Write-Host "   This is the expected sync window - proceed to portal verification" -ForegroundColor Gray
        } else {
            Write-Host "`n   ✅ Scan completed over 2 hours ago" -ForegroundColor Green
            Write-Host "   Activity Explorer sync should be complete" -ForegroundColor Gray
        }
        
    } else {
        Write-Host "   ⚠️  No DetailedReport found" -ForegroundColor Yellow
        Write-Host "   Run Start-DLPScanWithReset.ps1 first" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "   ⚠️  Could not check scan status: $_" -ForegroundColor Yellow
}

# Check DLP configuration
try {
    $scannerConfig = Get-ScannerContentScan -ErrorAction Stop
    
    Write-Host "`n   DLP configuration:" -ForegroundColor Green
    Write-Host "      EnableDLP: $($scannerConfig.EnableDlp)" -ForegroundColor Gray
    Write-Host "      Enforce: $($scannerConfig.Enforce)" -ForegroundColor Gray
    
    if ($scannerConfig.EnableDlp -ne 'On') {
        Write-Host "`n   ❌ EnableDLP is not On" -ForegroundColor Red
        Write-Host "   Run Enable-ScannerDLP.ps1 first" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "   ⚠️  Could not check DLP configuration" -ForegroundColor Yellow
}

# Step 2: Activity Explorer verification instructions
Write-Host "`n📋 Step 2: Verifying Activity Explorer sync..." -ForegroundColor Cyan

Write-Host "`n   🌐 Manual Portal Verification Required:" -ForegroundColor Yellow
Write-Host "   =======================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Activity Explorer can only be checked through the web portal." -ForegroundColor Gray
Write-Host "   Follow these steps to verify DLP event visibility:" -ForegroundColor Gray

Write-Host "`n   1. Navigate to Microsoft Purview compliance portal:" -ForegroundColor Cyan
Write-Host "      https://purview.microsoft.com" -ForegroundColor White

Write-Host "`n   2. Go to Activity Explorer:" -ForegroundColor Cyan
Write-Host "      Solutions > Data loss prevention > Activity explorer" -ForegroundColor White

Write-Host "`n   3. Configure filter for on-premises events:" -ForegroundColor Cyan
Write-Host "      • Click 'Activities' filter" -ForegroundColor White
Write-Host "      • Search: 'on-premises'" -ForegroundColor White
Write-Host "      • Select: 'File accessed from on-premises repository'" -ForegroundColor White
Write-Host "      • Click 'Apply'" -ForegroundColor White

Write-Host "`n   4. Check for DLP events:" -ForegroundColor Cyan
Write-Host "      Look for events from your repositories:" -ForegroundColor White
Write-Host "      • Finance (\\vm-purview-scan\Finance)" -ForegroundColor Gray
Write-Host "      • HR (\\vm-purview-scan\HR)" -ForegroundColor Gray
Write-Host "      • Projects (\\vm-purview-scan\Projects)" -ForegroundColor Gray

Write-Host "`n   5. Verify event details:" -ForegroundColor Cyan
Write-Host "      Click on an event to view details" -ForegroundColor White
Write-Host "      Check for populated fields:" -ForegroundColor White
Write-Host "      • Sensitive info types detected (Credit Card Number, SSN)" -ForegroundColor Gray
Write-Host "      • File name and location" -ForegroundColor Gray
Write-Host "      • Activity timestamp" -ForegroundColor Gray

# Step 3: Success criteria
Write-Host "`n📊 Success Criteria:" -ForegroundColor Yellow
Write-Host "   =================" -ForegroundColor Yellow

Write-Host "`n   ✅ Policy Sync Complete If:" -ForegroundColor Green
Write-Host "      • Activity Explorer shows DLP events" -ForegroundColor Gray
Write-Host "      • Events filtered to 'File accessed from on-premises repository'" -ForegroundColor Gray
Write-Host "      • Events show your repositories (Finance, HR, Projects)" -ForegroundColor Gray
Write-Host "      • Sensitive information types are populated (Credit Card Number, SSN)" -ForegroundColor Gray
Write-Host "      • Event timestamps match your scan completion time" -ForegroundColor Gray

Write-Host "`n   ⚠️  Incomplete Sync If:" -ForegroundColor Yellow
Write-Host "      • No events appear in Activity Explorer" -ForegroundColor Gray
Write-Host "      • Events show but sensitive info types are missing" -ForegroundColor Gray
Write-Host "      • Only some repositories appear (not all three)" -ForegroundColor Gray

Write-Host "`n   💡 Expected Limitations (Normal):" -ForegroundColor Cyan
Write-Host "      • DLP Rule Name may be empty (expected for on-premises)" -ForegroundColor Gray
Write-Host "      • Detailed enforcement status may not appear" -ForegroundColor Gray
Write-Host "      • Focus on: Sensitive info types populated = success" -ForegroundColor Gray

# Step 4: Troubleshooting guidance
Write-Host "`n📋 Troubleshooting:" -ForegroundColor Yellow
Write-Host "   ===============" -ForegroundColor Yellow

Write-Host "`n   If no Activity Explorer events appear after 2+ hours:" -ForegroundColor Gray

Write-Host "`n   1. Verify Microsoft 365 auditing is enabled:" -ForegroundColor Cyan
Write-Host "      • Purview portal > Solutions > Audit" -ForegroundColor White
Write-Host "      • Ensure no 'Turn on auditing' banner appears" -ForegroundColor White
Write-Host "      • If just enabled, wait 2-4 hours for activation" -ForegroundColor White

Write-Host "`n   2. Check DLP policy status:" -ForegroundColor Cyan
Write-Host "      • Purview portal > Data loss prevention > Policies" -ForegroundColor White
Write-Host "      • Verify 'Lab-OnPrem-Sensitive-Data-Protection' status = 'On'" -ForegroundColor White
Write-Host "      • Check 'Synced to devices' column shows scanner computer" -ForegroundColor White

Write-Host "`n   3. Verify scanner service is running:" -ForegroundColor Cyan
$serviceStatus = Get-Service -Name "MIPScanner" -ErrorAction SilentlyContinue
if ($serviceStatus) {
    Write-Host "      Scanner service: $($serviceStatus.Status)" -ForegroundColor White
    if ($serviceStatus.Status -ne 'Running') {
        Write-Host "      ⚠️  Service not running - start with: Start-Service MIPScanner" -ForegroundColor Yellow
    }
} else {
    Write-Host "      ⚠️  Could not check service status" -ForegroundColor Yellow
}

Write-Host "`n   4. Re-run DLP scan:" -ForegroundColor Cyan
Write-Host "      • Run: Start-DLPScanWithReset.ps1" -ForegroundColor White
Write-Host "      • Wait 1-2 hours after completion" -ForegroundColor White
Write-Host "      • Re-check Activity Explorer" -ForegroundColor White

Write-Host "`n   5. Check network connectivity:" -ForegroundColor Cyan
Write-Host "      • Run: Test-NetConnection -ComputerName purview.microsoft.com -Port 443" -ForegroundColor White
Write-Host "      • Expected: TcpTestSucceeded: True" -ForegroundColor White

# Step 5: Next steps
Write-Host "`n⏭️  Next Steps:" -ForegroundColor Yellow
Write-Host "   ===========" -ForegroundColor Yellow

Write-Host "`n   After confirming Activity Explorer sync:" -ForegroundColor Gray
Write-Host "   1. Document DLP events visible in Activity Explorer" -ForegroundColor Gray
Write-Host "   2. Verify sensitive information types are populated" -ForegroundColor Gray
Write-Host "   3. Take screenshots for validation records" -ForegroundColor Gray
Write-Host "   4. Proceed to OnPrem-04-DLP-Enforcement for enforcement mode testing" -ForegroundColor Gray

Write-Host "`n   If sync not complete after 2-3 hours:" -ForegroundColor Gray
Write-Host "   1. Review troubleshooting steps above" -ForegroundColor Gray
Write-Host "   2. Verify all prerequisites (auditing, DLP policy, scanner service)" -ForegroundColor Gray
Write-Host "   3. Consider re-running scan if needed" -ForegroundColor Gray
Write-Host "   4. Wait additional time (some environments require 3-4 hours)" -ForegroundColor Gray

Write-Host "`n💡 Important Notes:" -ForegroundColor Cyan
Write-Host "   • Activity Explorer is portal-only (no PowerShell cmdlets)" -ForegroundColor Gray
Write-Host "   • Manual verification is required" -ForegroundColor Gray
Write-Host "   • Sync timing varies by environment (1-4 hours typical)" -ForegroundColor Gray
Write-Host "   • Empty DLP Rule Name is expected for on-premises scanners" -ForegroundColor Gray

Write-Host "`n📊 Timeline Reference:" -ForegroundColor Cyan
Write-Host "   ==================" -ForegroundColor Cyan
Write-Host "   • DLP scan completion: Immediate (Start-DLPScanWithReset.ps1)" -ForegroundColor Gray
Write-Host "   • DetailedReport.csv generation: Immediate after scan" -ForegroundColor Gray
Write-Host "   • Activity Explorer sync start: Automatic after scan" -ForegroundColor Gray
Write-Host "   • Typical sync completion: 1-2 hours" -ForegroundColor Gray
Write-Host "   • Maximum expected: 2-4 hours" -ForegroundColor Gray
Write-Host "   • Troubleshooting threshold: Check issues if > 4 hours" -ForegroundColor Gray

Write-Host "`n✅ Activity Explorer Verification Guide Complete" -ForegroundColor Green
Write-Host "`nUse the instructions above to manually verify DLP event visibility in the portal." -ForegroundColor Gray
