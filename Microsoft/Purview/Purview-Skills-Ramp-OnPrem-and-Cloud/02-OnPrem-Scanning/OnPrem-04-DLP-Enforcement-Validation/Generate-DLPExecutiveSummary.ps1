<#
.SYNOPSIS
    Generates executive summary report from Activity Explorer DLP data for on-premises file repositories.

.DESCRIPTION
    This script analyzes exported Activity Explorer CSV data to create executive and detailed reports
    for DLP compliance monitoring. It filters for on-premises scanner activity (Endpoint devices),
    groups sensitive data detections by type, and generates stakeholder-ready reports showing
    unique files detected and sample file locations.
    
    The script automatically finds the most recent Activity Explorer export in your Downloads folder,
    processes the data to identify sensitive information types (Credit Card Numbers, SSNs, etc.),
    and outputs two comprehensive reports:
    
    1. Executive Summary CSV: High-level overview with detection counts by sensitive data type
    2. Detailed Report CSV: File-level breakdown with repository paths and data classifications
    
    Both reports are timestamped and saved to C:\Reports for stakeholder distribution and
    compliance documentation.

.PARAMETER None
    This script uses embedded configuration variables that can be customized by editing the
    script file directly. The $downloadsDir variable defaults to the current user's Downloads
    folder but can be modified to match your environment.

.EXAMPLE
    .\Generate-DLPExecutiveSummary.ps1
    
    Finds the most recent Activity Explorer export in Downloads folder and generates
    executive summary and detailed reports in C:\Reports directory.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-01-10
    Last Modified: 2025-01-10
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Activity Explorer CSV export with "Sensitive info type" column enabled
    - CSV saved in Downloads folder (or custom path specified in $downloadsDir variable)
    - PowerShell 5.1+ or PowerShell 7+
    - Write permissions to C:\Reports directory (auto-created if missing)
    
    Script development orchestrated using GitHub Copilot.

.INPUTS
    CSV file from Activity Explorer export (automatically located in Downloads folder)
    Expected filename pattern: "Activity explorer _ Microsoft Purview*.csv"

.OUTPUTS
    Two CSV files in C:\Reports directory:
    - OnPrem-DLP-Executive-Summary-YYYY-MM-DD.csv
    - OnPrem-DLP-Detailed-Report-YYYY-MM-DD.csv
    
    Console output includes formatted summary tables and file counts.
#>
#
# =============================================================================
# Generate executive summary report from Activity Explorer DLP data for
# on-premises compliance monitoring and stakeholder reporting.
# =============================================================================

# ============================================================
# CONFIGURATION: Update this directory to your Downloads folder location
# ============================================================
$downloadsDir = "C:\Users\$env:USERNAME\Downloads"
# Example alternative paths:
# $downloadsDir = "C:\Downloads"
# $downloadsDir = "$env:USERPROFILE\Downloads"

# ============================================================
# FIND LATEST EXPORT: Automatically selects most recent Activity Explorer export
# ============================================================
# Find all Activity Explorer exports (handles ActivityExplorerExport.csv and ActivityExplorerExport (1).csv patterns)
$exportFiles = Get-ChildItem -Path $downloadsDir -Filter "Activity explorer _ Microsoft Purview*.csv" -ErrorAction SilentlyContinue |
               Sort-Object LastWriteTime -Descending

if ($exportFiles.Count -eq 0) {
    Write-Host "❌ ERROR: No Activity Explorer export files found in:" -ForegroundColor Red
    Write-Host "   $downloadsDir`n" -ForegroundColor Yellow
    Write-Host "Please ensure you have exported Activity Explorer data to CSV and saved it in your Downloads folder." -ForegroundColor Yellow
    Write-Host "Expected filename pattern: ActivityExplorerExport.csv (or with (1), (2), etc. suffix)" -ForegroundColor Gray
    exit
}

# Use the most recent export file
$csvPath = $exportFiles[0].FullName
Write-Host "✅ Found Activity Explorer export: $($exportFiles[0].Name)" -ForegroundColor Green
Write-Host "   Last Modified: $($exportFiles[0].LastWriteTime)" -ForegroundColor Gray
if ($exportFiles.Count -gt 1) {
    Write-Host "   Note: $($exportFiles.Count) export files found, using most recent`n" -ForegroundColor Cyan
} else {
    Write-Host ""
}

# ============================================================
# SETUP: Create output directory if it doesn't exist
# ============================================================
$reportDir = "C:\Reports"
if (-not (Test-Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    Write-Host "✅ Created output directory: $reportDir`n" -ForegroundColor Green
}

# Import exported Activity Explorer CSV (with Sensitive info type column)
$activityData = Import-Csv $csvPath

# Filter for on-premises scanner activity only
$onPremActivity = $activityData | 
    Where-Object { $_.'Location' -eq 'Endpoint devices' }

# Generate executive summary by sensitive info type
$summary = $onPremActivity | 
    Group-Object 'Sensitive info type' | 
    ForEach-Object {
        # Get unique files for this sensitive info type
        $uniqueFiles = $_.Group | Select-Object -Property File -Unique
        
        [PSCustomObject]@{
            'Sensitive Data Type' = $_.Name
            'Unique Files Detected' = $uniqueFiles.Count
            'Total Detection Events' = $_.Count
            'Sample Files' = ($uniqueFiles | Select-Object -First 3 -ExpandProperty File) -join '; '
        }
    }

# Display executive summary
Write-Host "`n========== ON-PREMISES DLP EXECUTIVE SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Report Date: $(Get-Date -Format 'yyyy-MM-dd')" -ForegroundColor Yellow
Write-Host "Scope: On-Premises File Repositories (Endpoint Devices)`n" -ForegroundColor Yellow

$summary | Format-Table -AutoSize -Wrap

# Generate detailed file-level report
$detailedReport = $onPremActivity | 
    Select-Object File, 'Sensitive info type' -Unique |
    ForEach-Object {
        [PSCustomObject]@{
            'File Name' = Split-Path $_.File -Leaf
            'Repository' = ($_.File -split '\\')[3]  # Extracts repository from UNC path
            'Full Path' = $_.File
            'Sensitive Data Type' = $_.'Sensitive info type'
        }
    } | Sort-Object 'Sensitive Data Type', 'Repository'

Write-Host "`n========== DETAILED FILE-LEVEL REPORT ==========" -ForegroundColor Cyan
$detailedReport | Format-Table -AutoSize

# Export reports for stakeholder distribution
$summary | Export-Csv "C:\Reports\OnPrem-DLP-Executive-Summary-$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation
$detailedReport | Export-Csv "C:\Reports\OnPrem-DLP-Detailed-Report-$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation

Write-Host "`n✅ Reports exported:" -ForegroundColor Green
Write-Host "   Executive Summary: C:\Reports\OnPrem-DLP-Executive-Summary-$(Get-Date -Format 'yyyy-MM-dd').csv" -ForegroundColor White
Write-Host "   Detailed Report: C:\Reports\OnPrem-DLP-Detailed-Report-$(Get-Date -Format 'yyyy-MM-dd').csv" -ForegroundColor White
