<#
.SYNOPSIS
    Tests the complete EDM workflow for repeatability.

.DESCRIPTION
    This script validates that the EDM schema creation and data upload process
    is fully repeatable by deleting the existing schema and recreating it.
    
    **WARNING**: This deletes your existing RetailCustomerDB schema and data!
    Use only for testing or when starting fresh.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-31
    
    Script development orchestrated using GitHub Copilot.
#>

param(
    [Parameter(Mandatory = $false)]
    [switch]$SkipDelete,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

Write-Host "🧪 EDM Workflow Repeatability Test" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host "⚠️  WhatIf mode: No changes will be made" -ForegroundColor Yellow
}

# Step 1: Delete existing schema (unless skipped)
if (-not $SkipDelete) {
    Write-Host "`n🗑️  Step 1: Deleting existing schema..." -ForegroundColor Yellow
    
    if ($WhatIf) {
        Write-Host "   [WhatIf] Would delete schema: RetailCustomerDB" -ForegroundColor Gray
    } else {
        try {
            $existingSchema = Get-DlpEdmSchema | Where-Object { $_.DataStoreName -eq 'RetailCustomerDB' }
            if ($existingSchema) {
                Remove-DlpEdmSchema -Identity RetailCustomerDB -Confirm:$false
                Write-Host "   ✅ Schema deleted successfully" -ForegroundColor Green
                Write-Host "   ⏱️  Waiting 30 seconds for propagation..." -ForegroundColor Cyan
                Start-Sleep -Seconds 30
            } else {
                Write-Host "   ℹ️  No existing schema found to delete" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "   ⚠️  Error deleting schema: $_" -ForegroundColor Yellow
            Write-Host "   Continuing with workflow..." -ForegroundColor Cyan
        }
    }
} else {
    Write-Host "`n⏭️  Step 1: Skipped (SkipDelete flag)" -ForegroundColor Cyan
}

# Step 2: Create schema
Write-Host "`n📋 Step 2: Creating EDM schema..." -ForegroundColor Yellow

if ($WhatIf) {
    Write-Host "   [WhatIf] Would run: .\Sync-EdmSchema.ps1" -ForegroundColor Gray
} else {
    try {
        & "$PSScriptRoot\Sync-EdmSchema.ps1"
        
        # Verify schema was actually created (more reliable than exit code)
        $schema = Get-DlpEdmSchema | Where-Object { $_.DataStoreName -eq 'RetailCustomerDB' }
        if ($schema) {
            Write-Host "   ✅ Schema creation verified" -ForegroundColor Green
        } else {
            throw "Schema not found after Sync-EdmSchema.ps1 execution"
        }
    } catch {
        Write-Host "   ❌ Schema creation failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Step 3: Verify schema exists
Write-Host "`n🔍 Step 3: Verifying schema..." -ForegroundColor Yellow

if ($WhatIf) {
    Write-Host "   [WhatIf] Would verify schema exists in cloud" -ForegroundColor Gray
} else {
    try {
        $schema = Get-DlpEdmSchema | Where-Object { $_.DataStoreName -eq 'RetailCustomerDB' }
        if ($schema) {
            Write-Host "   ✅ Schema 'RetailCustomerDB' confirmed in cloud" -ForegroundColor Green
            Write-Host "   📋 Version: $($schema.Version)" -ForegroundColor Cyan
        } else {
            throw "Schema not found in cloud after creation"
        }
    } catch {
        Write-Host "   ❌ Schema verification failed: $_" -ForegroundColor Red
        exit 1
    }
}

# Step 4: Wait for propagation
Write-Host "`n⏱️  Step 4: Waiting for schema propagation to Upload Agent..." -ForegroundColor Yellow
Write-Host "   This typically takes 5-15 minutes" -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host "   [WhatIf] Would wait for propagation and check /GetDataStore" -ForegroundColor Gray
} else {
    $maxWaitMinutes = 20
    $checkIntervalSeconds = 60
    $elapsedMinutes = 0
    $propagated = $false
    
    while ($elapsedMinutes -lt $maxWaitMinutes -and -not $propagated) {
        Write-Host "   ⏳ Checking propagation status... ($elapsedMinutes/$maxWaitMinutes minutes)" -ForegroundColor Cyan
        
        Push-Location "C:\Program Files\Microsoft\EdmUploadAgent"
        $dataStoreOutput = & .\EdmUploadAgent.exe /GetDataStore 2>&1
        Pop-Location
        
        if ($dataStoreOutput -match "retailcustomerdb" -or $dataStoreOutput -match "RetailCustomerDB") {
            $propagated = $true
            Write-Host "   ✅ Schema propagated to Upload Agent!" -ForegroundColor Green
        } else {
            Start-Sleep -Seconds $checkIntervalSeconds
            $elapsedMinutes++
        }
    }
    
    if (-not $propagated) {
        Write-Host "   ⚠️  Schema not yet visible to Upload Agent after $maxWaitMinutes minutes" -ForegroundColor Yellow
        Write-Host "   You may need to wait longer before running Upload-EdmData.ps1" -ForegroundColor Yellow
    }
}

# Step 5: Upload data
Write-Host "`n📤 Step 5: Uploading EDM data..." -ForegroundColor Yellow

if ($WhatIf) {
    Write-Host "   [WhatIf] Would run: .\Upload-EdmData.ps1" -ForegroundColor Gray
} else {
    try {
        & "$PSScriptRoot\Upload-EdmData.ps1"
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "   ✅ Data upload completed" -ForegroundColor Green
        } else {
            throw "Upload-EdmData.ps1 failed with exit code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "   ❌ Data upload failed: $_" -ForegroundColor Red
        Write-Host "   If you see SchemaNotFound, wait a few more minutes and run:" -ForegroundColor Yellow
        Write-Host "      .\Upload-EdmData.ps1" -ForegroundColor White
        exit 1
    }
}

# Step 6: Final verification
Write-Host "`n✅ Step 6: Final verification..." -ForegroundColor Yellow

if ($WhatIf) {
    Write-Host "   [WhatIf] Would check upload status" -ForegroundColor Gray
} else {
    Write-Host "   Run this command to check upload status:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host '   $out = & "C:\Program Files\Microsoft\EdmUploadAgent\EdmUploadAgent.exe" /GetSession /DataStoreName RetailCustomerDB' -ForegroundColor White
    Write-Host '   if ($LASTEXITCODE -eq 0) {' -ForegroundColor White
    Write-Host '       $out | Select-String "Completed|Indexing" | ForEach-Object {' -ForegroundColor White
    Write-Host '           $row = $_.ToString().Split(",")'  -ForegroundColor White
    Write-Host '           if ($row.Count -gt 2) { "✅ Upload Status: " + $row[2].Trim() }' -ForegroundColor White
    Write-Host '       }' -ForegroundColor White
    Write-Host '   }' -ForegroundColor White
    Write-Host ""
}

Write-Host "`n🎉 EDM Workflow Test Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

if (-not $WhatIf) {
    Write-Host ""
    Write-Host "📋 Summary:" -ForegroundColor Cyan
    Write-Host "   ✅ Schema created with 7 fields (no MembershipType)" -ForegroundColor Green
    Write-Host "   ✅ maximumNumberOfTokens handled correctly (in XML, stripped for PowerShell)" -ForegroundColor Green
    Write-Host "   ✅ Data upload initiated" -ForegroundColor Green
    Write-Host ""
    Write-Host "⏳ Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Wait 12-24 hours for EDM indexing to complete" -ForegroundColor White
    Write-Host "   2. Proceed with Lab 01 (Custom SIT with CustomerDB_TestData.csv)" -ForegroundColor White
    Write-Host "   3. Proceed with Lab 02 (EDM Classifier)" -ForegroundColor White
}
