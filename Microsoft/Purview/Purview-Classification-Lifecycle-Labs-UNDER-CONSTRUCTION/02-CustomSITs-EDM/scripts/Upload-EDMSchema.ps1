<#
.SYNOPSIS
    Uploads an EDM (Exact Data Match) schema to Microsoft Purview.

.DESCRIPTION
    This script uploads an EDM schema XML file to Microsoft Purview Security & Compliance
    PowerShell, registering the data store and field definitions for subsequent EDM data
    upload and classification operations.

.PARAMETER SchemaPath
    Path to the EDM schema XML file to upload.

.PARAMETER Validate
    If specified, validates schema structure before upload.

.EXAMPLE
    .\Upload-EDMSchema.ps1 -SchemaPath "C:\PurviewLabs\Lab2-EDM-Testing\configs\EmployeeDatabase_Schema.xml"
    
    Uploads the specified EDM schema to Purview.

.EXAMPLE
    .\Upload-EDMSchema.ps1 -SchemaPath "C:\PurviewLabs\Lab2-EDM-Testing\configs\EmployeeDatabase_Schema.xml" -Validate
    
    Validates schema structure before uploading to Purview.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-14
    Last Modified: 2025-11-14
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 7.0 or later
    - ExchangeOnlineManagement module (3.0+)
    - Security & Compliance PowerShell permissions
    - Compliance Administrator or Organization Management role
    
    Script development orchestrated using GitHub Copilot.

.UPLOAD PROCESS
    - Schema Validation (verifies XML structure and required fields)
    - Authentication (connects to Security & Compliance PowerShell)
    - Schema Upload (uses New-DlpEdmSchema cmdlet)
    - Status Verification (confirms data store activation)
#>

#Requires -Version 7.0
#Requires -Modules ExchangeOnlineManagement

# =============================================================================
# Upload EDM schema to Microsoft Purview.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Path to the EDM schema XML file")]
    [ValidateScript({
        if (-not (Test-Path $_)) {
            throw "Schema file not found: $_"
        }
        if ([System.IO.Path]::GetExtension($_) -ne '.xml') {
            throw "Schema file must be an XML file"
        }
        return $true
    })]
    [string]$SchemaPath,

    [Parameter(Mandatory = $false, HelpMessage = "Validate schema structure before upload")]
    [switch]$Validate
)

# Import Shared Utilities Module
$sharedUtilitiesPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "Shared-Utilities\PurviewUtilities.psm1"
if (Test-Path $sharedUtilitiesPath) {
    Import-Module $sharedUtilitiesPath -Force
} else {
    Write-Error "Shared Utilities module not found at: $sharedUtilitiesPath"
    exit 1
}

# =============================================================================
# Step 1: Validate Schema File
# =============================================================================

Write-Host "🔍 Step 1: Schema Validation" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

try {
    Write-Host "📋 Loading schema file..." -ForegroundColor Cyan
    
    # Load XML content
    [xml]$schemaXml = Get-Content -Path $SchemaPath -Raw
    
    # Validate XML structure
    if (-not $schemaXml.EdmSchema) {
        throw "Invalid schema: Missing EdmSchema root element"
    }
    
    if (-not $schemaXml.EdmSchema.DataStore) {
        throw "Invalid schema: Missing DataStore element"
    }
    
    $dataStoreName = $schemaXml.EdmSchema.DataStore.name
    $dataStoreDescription = $schemaXml.EdmSchema.DataStore.description
    
    if ([string]::IsNullOrWhiteSpace($dataStoreName)) {
        throw "Invalid schema: DataStore name is missing or empty"
    }
    
    Write-Host "   ✅ Schema file loaded successfully" -ForegroundColor Green
    Write-Host "      Data Store: $dataStoreName" -ForegroundColor White
    Write-Host "      Description: $dataStoreDescription" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host "   ❌ Schema validation failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Analyze Schema Fields
# =============================================================================

Write-Host "📊 Step 2: Schema Field Analysis" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

try {
    Write-Host "📋 Analyzing field configuration..." -ForegroundColor Cyan
    
    $fields = $schemaXml.EdmSchema.DataStore.Field
    
    if (-not $fields -or $fields.Count -eq 0) {
        throw "Schema contains no fields"
    }
    
    $searchableFields = $fields | Where-Object { $_.searchable -eq "true" }
    $nonSearchableFields = $fields | Where-Object { $_.searchable -eq "false" }
    $caseInsensitiveFields = $fields | Where-Object { $_.caseInsensitive -eq "true" }
    
    Write-Host "   ✅ Field analysis complete" -ForegroundColor Green
    Write-Host "      Total Fields: $($fields.Count)" -ForegroundColor White
    Write-Host "      Searchable: $($searchableFields.Count)" -ForegroundColor White
    Write-Host "      Non-Searchable: $($nonSearchableFields.Count)" -ForegroundColor White
    Write-Host "      Case-Insensitive: $($caseInsensitiveFields.Count)" -ForegroundColor White
    Write-Host ""
    
    if ($searchableFields.Count -gt 5) {
        Write-Host "   ⚠️  Warning: More than 5 searchable fields may impact performance" -ForegroundColor Yellow
        Write-Host ""
    }
    
    if ($Validate) {
        Write-Host "📋 Searchable Fields:" -ForegroundColor Cyan
        foreach ($field in $searchableFields) {
            $caseInfo = if ($field.caseInsensitive -eq "true") { " (case-insensitive)" } else { "" }
            Write-Host "   ✓ $($field.name)$caseInfo" -ForegroundColor White
        }
        Write-Host ""
    }

} catch {
    Write-Host "   ❌ Field analysis failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Connect to Security & Compliance PowerShell
# =============================================================================

Write-Host "🔐 Step 3: Authentication" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

try {
    Write-Host "📋 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
    Write-Host "   ℹ️  You will be prompted to sign in via browser" -ForegroundColor Yellow
    
    # Use Connect-IPPSSession without credentials for interactive browser-based auth
    Connect-IPPSSession -WarningAction SilentlyContinue | Out-Null
    
    Write-Host "   ✅ Connected to Security & Compliance PowerShell" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host "   ❌ Authentication failed: $_" -ForegroundColor Red
    Write-Host "   ℹ️  Ensure you have appropriate permissions (Compliance Administrator or higher)" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 4: Check for Existing Schema
# =============================================================================

Write-Host "🔍 Step 4: Existing Schema Check" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

try {
    Write-Host "📋 Checking for existing EDM schemas..." -ForegroundColor Cyan
    
    $existingSchemas = Get-DlpEdmSchema -ErrorAction SilentlyContinue
    
    if ($existingSchemas) {
        $matchingSchema = $existingSchemas | Where-Object { $_.DataStoreName -eq $dataStoreName }
        
        if ($matchingSchema) {
            Write-Host "   ⚠️  Warning: Data store '$dataStoreName' already exists" -ForegroundColor Yellow
            Write-Host "      Status: $($matchingSchema.Status)" -ForegroundColor Yellow
            Write-Host "      Version: $($matchingSchema.SchemaVersion)" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "   ❌ Cannot upload schema - data store name already in use" -ForegroundColor Red
            Write-Host "   💡 Options:" -ForegroundColor Cyan
            Write-Host "      1. Use a different data store name in your schema" -ForegroundColor White
            Write-Host "      2. Remove existing schema: Remove-DlpEdmSchema -DataStoreName '$dataStoreName'" -ForegroundColor White
            Write-Host "      3. Create a new schema version instead of replacing" -ForegroundColor White
            exit 1
        } else {
            Write-Host "   ✅ No conflicting schemas found (found $($existingSchemas.Count) other schema(s))" -ForegroundColor Green
        }
    } else {
        Write-Host "   ✅ No existing EDM schemas found" -ForegroundColor Green
    }
    
    Write-Host ""

} catch {
    Write-Host "   ⚠️  Warning: Could not check existing schemas: $_" -ForegroundColor Yellow
    Write-Host "   Continuing with upload attempt..." -ForegroundColor Cyan
    Write-Host ""
}

# =============================================================================
# Step 5: Upload EDM Schema
# =============================================================================

Write-Host "📤 Step 5: Upload EDM Schema" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

try {
    Write-Host "📋 Reading schema file content..." -ForegroundColor Cyan
    
    # Read schema file as byte array
    $schemaBytes = [System.IO.File]::ReadAllBytes($SchemaPath)
    
    Write-Host "📋 Uploading schema to Microsoft Purview..." -ForegroundColor Cyan
    Write-Host "   ℹ️  This may take 1-2 minutes..." -ForegroundColor Yellow
    
    # Upload schema using New-DlpEdmSchema cmdlet
    New-DlpEdmSchema -FileData $schemaBytes -Confirm:$false -ErrorAction Stop | Out-Null
    
    Write-Host "   ✅ Schema uploaded successfully" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host "   ❌ Schema upload failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Common Issues:" -ForegroundColor Cyan
    Write-Host "   • Data store name already exists (use different name)" -ForegroundColor White
    Write-Host "   • Insufficient permissions (requires Compliance Administrator)" -ForegroundColor White
    Write-Host "   • Invalid XML structure (validate schema file)" -ForegroundColor White
    Write-Host "   • Field name conflicts with reserved keywords" -ForegroundColor White
    exit 1
}

# =============================================================================
# Step 6: Verify Schema Upload
# =============================================================================

Write-Host "✅ Step 6: Verification" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green

try {
    Write-Host "📋 Retrieving uploaded schema information..." -ForegroundColor Cyan
    
    # Wait a moment for schema to be indexed
    Start-Sleep -Seconds 3
    
    $uploadedSchema = Get-DlpEdmSchema | Where-Object {$_.DataStoreName -eq $dataStoreName} -ErrorAction Stop
    
    if ($uploadedSchema) {
        Write-Host "   ✅ Schema verification successful" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "📊 Uploaded Schema Details:" -ForegroundColor Cyan
        Write-Host "   Data Store Name: $($uploadedSchema.DataStoreName)" -ForegroundColor White
        Write-Host "   Status: $($uploadedSchema.Status)" -ForegroundColor White
        Write-Host "   Schema Version: $($uploadedSchema.SchemaVersion)" -ForegroundColor White
        Write-Host "   Created: $(Get-Date)" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "   ⚠️  Schema uploaded but verification failed" -ForegroundColor Yellow
        Write-Host "   Schema may still be processing..." -ForegroundColor Yellow
        Write-Host ""
    }

} catch {
    Write-Host "   ⚠️  Schema verification failed: $_" -ForegroundColor Yellow
    Write-Host "   Schema may still be processing in Purview..." -ForegroundColor Yellow
    Write-Host ""
}

# =============================================================================
# Step 7: Next Steps
# =============================================================================

Write-Host "🎯 Step 7: Next Steps" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green

Write-Host "📋 Recommended Actions:" -ForegroundColor Cyan
Write-Host "   1. Verify schema in Microsoft Purview compliance portal" -ForegroundColor White
Write-Host "   2. Ensure employee database CSV columns match schema fields exactly" -ForegroundColor White
Write-Host "   3. Run Upload-EDMData.ps1 to hash and upload employee data" -ForegroundColor White
Write-Host "   4. Wait 30-90 minutes for EDM data indexing after upload" -ForegroundColor White
Write-Host ""

Write-Host "📋 Verification Command:" -ForegroundColor Cyan
Write-Host "   Get-DlpEdmSchema | Where-Object {\$_.DataStoreName -eq '$dataStoreName'}" -ForegroundColor White
Write-Host ""

Write-Host "📋 Next Upload Command:" -ForegroundColor Cyan
Write-Host "   .\Upload-EDMData.ps1 -DatabasePath `"C:\PurviewLabs\Lab2-EDM-Testing\EmployeeDatabase.csv`" -DataStoreName `"$dataStoreName`"" -ForegroundColor White
Write-Host ""

Write-Host "⚠️  Important Notes:" -ForegroundColor Yellow
Write-Host "   • Schema is now active and ready for data upload" -ForegroundColor Yellow
Write-Host "   • CSV column names must exactly match schema field names (case-sensitive)" -ForegroundColor Yellow
Write-Host "   • Schema cannot be modified after upload (create new version if needed)" -ForegroundColor Yellow
Write-Host "   • Requires EDM_DataUploaders group membership for data upload" -ForegroundColor Yellow
Write-Host ""

Write-Host "✅ EDM schema upload completed successfully" -ForegroundColor Green
exit 0
