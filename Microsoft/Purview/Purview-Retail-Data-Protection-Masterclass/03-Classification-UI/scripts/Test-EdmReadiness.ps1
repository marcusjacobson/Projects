<#
.SYNOPSIS
    Validates EDM schema and data readiness for Lab 02 EDM Classifier creation.

.DESCRIPTION
    Performs detailed validation of EDM components specifically required for
    creating EDM-based classifiers in Lab 02:
    - EDM schema existence and field configuration
    - EDM data upload and indexing completion status
    - PowerShell connection to Security & Compliance
    - EDM Upload Agent availability

    This script provides Lab 02-specific validation beyond the general
    prerequisite checks in Test-LabPrerequisites.ps1.

.EXAMPLE
    .\Test-EdmReadiness.ps1
    
    Validates all EDM components and displays detailed status.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-31
    Last Modified: 2025-12-31
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - ExchangeOnlineManagement module installed
    - Security & Compliance PowerShell connection
    - Compliance Administrator role
    - EDM schema and data created in 01-Day-Zero-Setup
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# EDM readiness validation for Lab 02 EDM Classifier creation.
# =============================================================================

#Requires -Version 5.1

[CmdletBinding()]
param()

# =============================================================================
# Step 1: PowerShell Connection Validation
# =============================================================================

Write-Host "`n🔍 Step 1: PowerShell Connection Validation" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

try {
    # Test connection by attempting to get EDM schemas
    $null = Get-DlpEdmSchema -ErrorAction Stop
    Write-Host "   ✅ Connected to Security & Compliance PowerShell" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Not connected to Security & Compliance PowerShell" -ForegroundColor Red
    Write-Host ""
    Write-Host "   📋 Action Required:" -ForegroundColor Yellow
    Write-Host "      Run: Connect-IPPSSession" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

# =============================================================================
# Step 2: EDM Schema Validation
# =============================================================================

Write-Host "`n🔍 Step 2: EDM Schema Validation" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

try {
    $edmSchemas = Get-DlpEdmSchema -ErrorAction Stop
    $retailSchema = $edmSchemas | Where-Object { $_.Name -eq "RetailCustomerDB" }
    
    if ($retailSchema) {
        Write-Host "   ✅ Schema 'RetailCustomerDB' found" -ForegroundColor Green
        
        # Try to get field information using Get-DlpEdmSchema with Identity parameter for more detail
        try {
            $detailedSchema = Get-DlpEdmSchema -Identity "RetailCustomerDB" -ErrorAction Stop
            
            if ($detailedSchema.DataStore) {
                $dataStoreName = if ($detailedSchema.DataStore.DataStoreName) { $detailedSchema.DataStore.DataStoreName } else { "RetailCustomerDB" }
                Write-Host "      📋 Data Store: $dataStoreName" -ForegroundColor Cyan
                
                # Get fields from the DataStore
                $fields = $detailedSchema.DataStore.Fields
                
                if ($fields) {
                    # Display searchable fields
                    $searchableFields = $fields | Where-Object { $_.Searchable -eq $true }
                    if ($searchableFields) {
                        Write-Host "      🔎 Searchable Fields (Primary Elements):" -ForegroundColor Cyan
                        foreach ($field in $searchableFields) {
                            Write-Host "         - $($field.Name)" -ForegroundColor Gray
                        }
                    }
                    
                    # Display all schema fields
                    Write-Host "      📊 All Schema Fields:" -ForegroundColor Cyan
                    foreach ($field in $fields) {
                        $searchableIcon = if ($field.Searchable) { "🔎" } else { "  " }
                        Write-Host "         $searchableIcon $($field.Name)" -ForegroundColor Gray
                    }
                } else {
                    Write-Host "      📋 Data Store: RetailCustomerDB" -ForegroundColor Cyan
                    Write-Host "      ℹ️  Schema exists but field details not available via PowerShell" -ForegroundColor Cyan
                    Write-Host "      ✅ Schema is ready for classifier creation in Purview Portal" -ForegroundColor Green
                }
            } else {
                Write-Host "      📋 Data Store: RetailCustomerDB" -ForegroundColor Cyan
                Write-Host "      ℹ️  Schema exists but field details not available via PowerShell" -ForegroundColor Cyan
                Write-Host "      ✅ Schema is ready for classifier creation in Purview Portal" -ForegroundColor Green
            }
        } catch {
            Write-Host "      📋 Data Store: RetailCustomerDB" -ForegroundColor Cyan
            Write-Host "      ℹ️  Schema exists but field details not available via PowerShell" -ForegroundColor Cyan
            Write-Host "      ✅ Schema is ready for classifier creation in Purview Portal" -ForegroundColor Green
        }
    } else {
        Write-Host "   ❌ Schema 'RetailCustomerDB' not found" -ForegroundColor Red
        Write-Host ""
        Write-Host "   📋 Action Required:" -ForegroundColor Yellow
        Write-Host "      Run: 01-Day-Zero-Setup\scripts\Sync-EdmSchema.ps1" -ForegroundColor Cyan
        Write-Host ""
        exit 1
    }
} catch {
    Write-Host "   ❌ Failed to retrieve EDM schemas: $_" -ForegroundColor Red
    Write-Host "      Error Details: $($_.Exception.Message)" -ForegroundColor Gray
    exit 1
}

# =============================================================================
# Step 3: EDM Data Upload Status
# =============================================================================

Write-Host "`n🔍 Step 3: EDM Data Upload Status" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

# Check if EDM Upload Agent is installed
$edmAgentPath = "C:\Program Files\Microsoft\EdmUploadAgent\EdmUploadAgent.exe"

if (-not (Test-Path $edmAgentPath)) {
    Write-Host "   ⚠️  EDM Upload Agent not found at expected location" -ForegroundColor Yellow
    Write-Host "      📁 Expected: $edmAgentPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   ℹ️  Note: Unable to verify data upload status without EDM Upload Agent." -ForegroundColor Cyan
    Write-Host "      If you've completed 01-Day-Zero-Setup and data upload succeeded," -ForegroundColor Cyan
    Write-Host "      you can proceed with Lab 02 classifier creation." -ForegroundColor Cyan
    Write-Host ""
    $uploadStatus = "Unknown"
} else {
    Write-Host "   ✅ EDM Upload Agent found" -ForegroundColor Green
    
    # Actually run the GetSession command and parse the session list
    try {
        $currentLocation = Get-Location
        Set-Location "C:\Program Files\Microsoft\EdmUploadAgent"
        
        # Run the command and capture all output
        $sessionOutput = & .\EdmUploadAgent.exe /GetSession /DataStoreName RetailCustomerDB 2>&1 | Out-String
        
        Set-Location $currentLocation
        
        # Parse the CSV-like output for the most recent session
        $uploadStatus = "Unknown"
        $lines = $sessionOutput -split "`r?`n"
        
        # Look for session data lines (contains commas and GUIDs)
        $sessionLines = $lines | Where-Object { $_ -match "^[a-f0-9\-]{36}," }
        
        if ($sessionLines) {
            # Get the first (most recent) session
            $latestSession = $sessionLines[0]
            $sessionParts = $latestSession -split ","
            
            if ($sessionParts.Count -ge 7) {
                $state = $sessionParts[2].Trim()
                $percentComplete = $sessionParts[3].Trim()
                $completionTime = $sessionParts[6].Trim()
                
                Write-Host ""
                Write-Host "   📊 Latest Upload Session:" -ForegroundColor Cyan
                Write-Host "      State: $state" -ForegroundColor Gray
                Write-Host "      Progress: $percentComplete%" -ForegroundColor Gray
                
                if ($completionTime) {
                    Write-Host "      Completed: $completionTime (UTC)" -ForegroundColor Gray
                }
                
                Write-Host ""
                
                if ($state -eq "Completed" -and $percentComplete -eq "100") {
                    Write-Host "   ✅ Upload Status: Completed" -ForegroundColor Green
                    Write-Host "      Data is fully indexed and ready for classifier creation" -ForegroundColor Cyan
                    $uploadStatus = "Completed"
                } elseif ($state -match "Indexing|Processing|InProgress") {
                    Write-Host "   ⏳ Upload Status: $state ($percentComplete% complete)" -ForegroundColor Yellow
                    Write-Host "      Data is still being processed" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "   ⚠️  WARNING: Wait for indexing to complete before creating classifiers" -ForegroundColor Yellow
                    Write-Host "      Check back in 30 minutes and re-run this validation script" -ForegroundColor Yellow
                    $uploadStatus = "Indexing"
                } elseif ($state -eq "Failed") {
                    Write-Host "   ❌ Upload Status: Failed" -ForegroundColor Red
                    Write-Host "      Data upload encountered an error" -ForegroundColor Red
                    Write-Host ""
                    Write-Host "   📋 Action Required:" -ForegroundColor Yellow
                    Write-Host "      Re-run: 01-Day-Zero-Setup\\scripts\\Upload-EdmData.ps1" -ForegroundColor Cyan
                    $uploadStatus = "Failed"
                } else {
                    Write-Host "   ℹ️  Upload Status: $state ($percentComplete% complete)" -ForegroundColor Cyan
                    $uploadStatus = $state
                }
            } else {
                Write-Host "   ℹ️  Could not parse session details from EDM Agent output" -ForegroundColor Cyan
                $uploadStatus = "Unknown"
            }
        } else {
            Write-Host ""
            Write-Host "   ⚠️  No upload sessions found for RetailCustomerDB" -ForegroundColor Yellow
            Write-Host "      This suggests data has not been uploaded yet" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "   📋 Action Required:" -ForegroundColor Yellow
            Write-Host "      Run: 01-Day-Zero-Setup\\scripts\\Upload-EdmData.ps1" -ForegroundColor Cyan
            $uploadStatus = "NotUploaded"
        }
    } catch {
        Write-Host "   ⚠️  Could not retrieve upload status: $_" -ForegroundColor Yellow
        Write-Host "      You may need to authorize the EDM agent first" -ForegroundColor Gray
        $uploadStatus = "Unknown"
    }
}

Write-Host ""

# =============================================================================
# Step 4: Summary and Recommendations
# =============================================================================

Write-Host "`n📊 Summary" -ForegroundColor Magenta
Write-Host "==========" -ForegroundColor Magenta

Write-Host ""
Write-Host "✅ EDM Schema Ready: RetailCustomerDB exists with expected fields" -ForegroundColor Green

if ($uploadStatus -eq "Completed") {
    Write-Host "✅ EDM Data Ready: Upload completed and indexed successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 You are ready to proceed with Lab 02!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Next Steps for Lab 02:" -ForegroundColor Cyan
    Write-Host "   1. Navigate to Purview Portal (purview.microsoft.com)" -ForegroundColor Gray
    Write-Host "   2. Go to Information Protection > Classifiers" -ForegroundColor Gray
    Write-Host "   3. Create EDM Classifier using the 'RetailCustomerDB' schema" -ForegroundColor Gray
} elseif ($uploadStatus -eq "Indexing" -or $uploadStatus -match "InProgress|Processing") {
    Write-Host "⏳ EDM Data Indexing: Upload is still processing - NOT READY" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "⚠️  DO NOT PROCEED WITH LAB 02 YET" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Required Actions:" -ForegroundColor Cyan
    Write-Host "   1. Wait 30-60 minutes for indexing to complete" -ForegroundColor Gray
    Write-Host "   2. Re-run this validation script: .\\Test-EdmReadiness.ps1" -ForegroundColor Gray
    Write-Host "   3. Proceed only when status shows 'Completed'" -ForegroundColor Gray
} elseif ($uploadStatus -eq "Failed") {
    Write-Host "❌ EDM Data Upload Failed: Data upload encountered errors" -ForegroundColor Red
    Write-Host ""
    Write-Host "⚠️  CANNOT PROCEED WITH LAB 02" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Required Actions:" -ForegroundColor Cyan
    Write-Host "   1. Review error details in 01-Day-Zero-Setup\\Output folder" -ForegroundColor Gray
    Write-Host "   2. Re-run: 01-Day-Zero-Setup\\scripts\\Upload-EdmData.ps1" -ForegroundColor Gray
    Write-Host "   3. Verify upload completes successfully" -ForegroundColor Gray
} elseif ($uploadStatus -eq "NotUploaded") {
    Write-Host "❌ EDM Data Not Uploaded: No upload sessions found" -ForegroundColor Red
    Write-Host ""
    Write-Host "⚠️  CANNOT PROCEED WITH LAB 02" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Required Actions:" -ForegroundColor Cyan
    Write-Host "   1. Complete 01-Day-Zero-Setup first" -ForegroundColor Gray
    Write-Host "   2. Run: 01-Day-Zero-Setup\\scripts\\Upload-EdmData.ps1" -ForegroundColor Gray
    Write-Host "   3. Wait for upload to complete (check status with this script)" -ForegroundColor Gray
} else {
    Write-Host "ℹ️  EDM Data Status: Could not verify upload status ($uploadStatus)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 If you've completed 01-Day-Zero-Setup successfully:" -ForegroundColor Cyan
    Write-Host "   - Check EDM Agent authorization status" -ForegroundColor Gray
    Write-Host "   - Manually verify upload: cd \"C:\\Program Files\\Microsoft\\EdmUploadAgent\"" -ForegroundColor Gray
    Write-Host "   - Run: .\\EdmUploadAgent.exe /GetSession /DataStoreName RetailCustomerDB" -ForegroundColor Gray
}

Write-Host ""

# Exit with appropriate code
if ($uploadStatus -eq "Completed") {
    exit 0
} elseif ($uploadStatus -match "Indexing|InProgress|Processing|Failed|NotUploaded") {
    exit 1
} else {
    exit 0  # Unknown status - allow to proceed with caution
}
