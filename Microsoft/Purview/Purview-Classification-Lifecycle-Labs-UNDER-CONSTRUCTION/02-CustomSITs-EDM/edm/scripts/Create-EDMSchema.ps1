<#
.SYNOPSIS
    Creates an EDM schema XML definition for Microsoft Purview Exact Data Match configuration.

.DESCRIPTION
    This script generates the EDM (Exact Data Match) schema XML file required for uploading
    employee data to Microsoft Purview. The schema defines:
    
    - Data store name: EmployeeDataStore
    - Searchable fields: EmployeeID, Email, SSN (fields that can be used for matching)
    - Classification fields: FirstName, LastName, Phone, Department, HireDate
    - Field attributes: caseInsensitive, ignoredDelimiters for flexible matching
    
    The EDM schema must be uploaded to Purview before hashing and uploading the actual
    employee data. This schema defines how Purview will match document content against
    the secure hash database.

.PARAMETER OutputPath
    Path to save the generated EDM schema XML. Defaults to current script directory.

.PARAMETER DataStoreName
    Name of the EDM data store. Defaults to "EmployeeDataStore".

.EXAMPLE
    .\Create-EDMSchema.ps1
    
    Generates EDM schema XML with default settings in current directory.

.EXAMPLE
    .\Create-EDMSchema.ps1 -DataStoreName "ContosoEmployees" -OutputPath "C:\PurviewLabs\EDM-Configs\"
    
    Generates schema with custom data store name in specified directory.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-11
    Last Modified: 2025-11-11
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Employee source database CSV created (Create-EDMSourceDatabase.ps1)
    - Write access to output directory
    
    EDM Workflow Context:
    - Step 1: Generate source database (Create-EDMSourceDatabase.ps1) ✅
    - Step 2: Create EDM schema XML (this script)
    - Step 3: Upload schema to Purview via Security & Compliance PowerShell
    - Step 4: Hash and upload employee data (Upload-EDMData.ps1)
    - Step 5: Create EDM-based SIT (Create-EDM-SIT.ps1)
    - Step 6: Validate EDM classification (Validate-EDMClassification.ps1)
    
    Searchable Fields:
    - EmployeeID: Primary identifier (EMP-XXXX-XXXX format)
    - Email: Corporate email address (case-insensitive matching)
    - SSN: Social Security Number (XXX-XX-XXXX format)
    
    Field Matching Attributes:
    - caseInsensitive="true": Email matching ignores case (John.Doe = john.doe)
    - ignoredDelimiters=".-": Ignore delimiters in matching (SSN: 123-45-6789 = 123456789)
    
    Schema Upload:
    - After creating schema, upload to Purview using New-DlpEdmSchema cmdlet
    - Wait 5-10 minutes for schema replication across Microsoft 365
    - Verify schema in Purview Compliance Portal before data upload
    
    Script development orchestrated using GitHub Copilot.

.EDM SCHEMA STRUCTURE
    - DataStore: Container for hashed employee data in Purview
    - Searchable Fields: Fields that trigger EDM SIT detection in documents
    - Classification Fields: Additional context fields included in hash database
    - Field Types: Text fields with case sensitivity and delimiter handling
#>
#
# =============================================================================
# Create EDM schema XML for Microsoft Purview Exact Data Match configuration
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = (Join-Path $PSScriptRoot "EDMSchema.xml"),
    
    [Parameter(Mandatory = $false)]
    [string]$DataStoreName = "EmployeeDataStore"
)

# =============================================================================
# Step 1: Define Schema Configuration
# =============================================================================

Write-Host "📋 Step 1: Define Schema Configuration" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$schemaConfig = @{
    DataStoreName = $DataStoreName
    Description = "Employee data store for Contoso Corporation EDM classification"
    SearchableFields = @(
        @{
            Name = "EmployeeID"
            Type = "String"
            Searchable = $true
            CaseInsensitive = $false
            IgnoredDelimiters = "-"
            Description = "Employee identifier in format EMP-XXXX-XXXX"
        },
        @{
            Name = "Email"
            Type = "String"
            Searchable = $true
            CaseInsensitive = $true
            IgnoredDelimiters = ".-"
            Description = "Corporate email address (case-insensitive)"
        },
        @{
            Name = "SSN"
            Type = "String"
            Searchable = $true
            CaseInsensitive = $false
            IgnoredDelimiters = "-"
            Description = "Social Security Number in format XXX-XX-XXXX"
        }
    )
    ClassificationFields = @(
        @{
            Name = "FirstName"
            Type = "String"
            Description = "Employee first name"
        },
        @{
            Name = "LastName"
            Type = "String"
            Description = "Employee last name"
        },
        @{
            Name = "Phone"
            Type = "String"
            Description = "Contact phone number"
        },
        @{
            Name = "Department"
            Type = "String"
            Description = "Employee department"
        },
        @{
            Name = "HireDate"
            Type = "String"
            Description = "Employment start date (YYYY-MM-DD)"
        }
    )
}

Write-Host "   📊 Schema Configuration:" -ForegroundColor Cyan
Write-Host "      • Data Store Name: $($schemaConfig.DataStoreName)" -ForegroundColor White
Write-Host "      • Searchable Fields: $($schemaConfig.SearchableFields.Count)" -ForegroundColor White
Write-Host "      • Classification Fields: $($schemaConfig.ClassificationFields.Count)" -ForegroundColor White
Write-Host ""

Write-Host "   🔍 Searchable Fields (trigger EDM detection):" -ForegroundColor Cyan
foreach ($field in $schemaConfig.SearchableFields) {
    Write-Host "      • $($field.Name): $($field.Description)" -ForegroundColor White
    Write-Host "        - Case Sensitive: $(if ($field.CaseInsensitive) { 'No' } else { 'Yes' })" -ForegroundColor Cyan
    Write-Host "        - Ignored Delimiters: $($field.IgnoredDelimiters)" -ForegroundColor Cyan
}
Write-Host ""

Write-Host "   📋 Classification Fields (additional context):" -ForegroundColor Cyan
foreach ($field in $schemaConfig.ClassificationFields) {
    Write-Host "      • $($field.Name): $($field.Description)" -ForegroundColor White
}
Write-Host ""

Write-Host "   ✅ Schema configuration defined" -ForegroundColor Green

Write-Host ""

# =============================================================================
# Step 2: Generate EDM Schema XML
# =============================================================================

Write-Host "📋 Step 2: Generate EDM Schema XML" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

try {
    Write-Host "   Generating EDM schema XML structure..." -ForegroundColor Cyan
    
    # Build XML structure for EDM schema
    $xmlBuilder = New-Object System.Text.StringBuilder
    
    # XML header
    [void]$xmlBuilder.AppendLine('<?xml version="1.0" encoding="utf-8"?>')
    [void]$xmlBuilder.AppendLine('<EdmSchema xmlns="http://schemas.microsoft.com/office/2018/edm">')
    
    # DataStore definition
    [void]$xmlBuilder.AppendLine("  <DataStore name=`"$($schemaConfig.DataStoreName)`" description=`"$($schemaConfig.Description)`">")
    
    # Add searchable fields
    [void]$xmlBuilder.AppendLine('    <!-- Searchable Fields: Fields that trigger EDM detection in documents -->')
    foreach ($field in $schemaConfig.SearchableFields) {
        $fieldXml = "    <Field name=`"$($field.Name)`" searchable=`"true`""
        
        if ($field.CaseInsensitive) {
            $fieldXml += " caseInsensitive=`"true`""
        }
        
        if ($field.IgnoredDelimiters) {
            $fieldXml += " ignoredDelimiters=`"$($field.IgnoredDelimiters)`""
        }
        
        $fieldXml += " />"
        [void]$xmlBuilder.AppendLine($fieldXml)
    }
    
    [void]$xmlBuilder.AppendLine('')
    
    # Add classification fields
    [void]$xmlBuilder.AppendLine('    <!-- Classification Fields: Additional context for EDM matches -->')
    foreach ($field in $schemaConfig.ClassificationFields) {
        $fieldXml = "    <Field name=`"$($field.Name)`" />"
        [void]$xmlBuilder.AppendLine($fieldXml)
    }
    
    # Close DataStore and EdmSchema
    [void]$xmlBuilder.AppendLine('  </DataStore>')
    [void]$xmlBuilder.AppendLine('</EdmSchema>')
    
    $schemaXml = $xmlBuilder.ToString()
    
    Write-Host "   ✅ XML structure generated successfully" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ Failed to generate XML structure: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 3: Validate XML Structure
# =============================================================================

Write-Host "📋 Step 3: Validate XML Structure" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

try {
    Write-Host "   Validating XML syntax..." -ForegroundColor Cyan
    
    # Parse XML to validate structure
    $xmlDoc = New-Object System.Xml.XmlDocument
    $xmlDoc.LoadXml($schemaXml)
    
    # Verify DataStore node exists
    $dataStoreNode = $xmlDoc.SelectSingleNode("//DataStore")
    if (-not $dataStoreNode) {
        throw "DataStore node not found in XML"
    }
    
    # Count field nodes
    $fieldNodes = $xmlDoc.SelectNodes("//Field")
    $totalFields = $schemaConfig.SearchableFields.Count + $schemaConfig.ClassificationFields.Count
    
    if ($fieldNodes.Count -ne $totalFields) {
        Write-Host "   ⚠️  Field count mismatch: Expected $totalFields, found $($fieldNodes.Count)" -ForegroundColor Yellow
    }
    
    Write-Host "   ✅ XML validation successful" -ForegroundColor Green
    Write-Host "      • DataStore: $($dataStoreNode.GetAttribute('name'))" -ForegroundColor Cyan
    Write-Host "      • Total Fields: $($fieldNodes.Count)" -ForegroundColor Cyan
    Write-Host "      • Searchable Fields: $($schemaConfig.SearchableFields.Count)" -ForegroundColor Cyan
    Write-Host "      • Classification Fields: $($schemaConfig.ClassificationFields.Count)" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ XML validation failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 4: Export Schema to File
# =============================================================================

Write-Host "📋 Step 4: Export Schema to File" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

try {
    # Ensure output directory exists
    $outputDir = Split-Path -Path $OutputPath -Parent
    if ($outputDir -and -not (Test-Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
        Write-Host "   Created output directory: $outputDir" -ForegroundColor Cyan
    }
    
    # Write XML to file with UTF-8 encoding
    Write-Host "   Writing EDM schema to file..." -ForegroundColor Cyan
    $schemaXml | Out-File -FilePath $OutputPath -Encoding utf8 -Force
    
    # Get file info
    $fileInfo = Get-Item -Path $OutputPath
    $fileSizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
    
    Write-Host ""
    Write-Host "   ✅ Schema file exported successfully" -ForegroundColor Green
    Write-Host "      • File Path: $OutputPath" -ForegroundColor Cyan
    Write-Host "      • File Size: $fileSizeKB KB" -ForegroundColor Cyan
    Write-Host "      • Encoding: UTF-8" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ Failed to export schema file: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 5: Display Schema Content
# =============================================================================

Write-Host "📋 Step 5: Display Schema Content" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

Write-Host ""
Write-Host "   📄 EDM Schema XML Content:" -ForegroundColor Cyan
Write-Host "   ───────────────────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host ""

# Display formatted XML with syntax highlighting
$xmlLines = $schemaXml -split "`n"
foreach ($line in $xmlLines) {
    if ($line.Trim() -match '^<\?xml') {
        Write-Host "   $line" -ForegroundColor Gray
    }
    elseif ($line.Trim() -match '^<!--') {
        Write-Host "   $line" -ForegroundColor Green
    }
    elseif ($line.Trim() -match '^<EdmSchema' -or $line.Trim() -match '^</EdmSchema>') {
        Write-Host "   $line" -ForegroundColor Magenta
    }
    elseif ($line.Trim() -match '^<DataStore' -or $line.Trim() -match '^</DataStore>') {
        Write-Host "   $line" -ForegroundColor Yellow
    }
    elseif ($line.Trim() -match '^<Field') {
        Write-Host "   $line" -ForegroundColor Cyan
    }
    else {
        Write-Host "   $line" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "   ───────────────────────────────────────────────────────────" -ForegroundColor Cyan

Write-Host ""

# =============================================================================
# Step 6: Summary and Next Steps
# =============================================================================

Write-Host "📋 Step 6: Summary and Next Steps" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ EDM schema creation completed successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Schema Summary:" -ForegroundColor Cyan
Write-Host "   • Data Store Name: $($schemaConfig.DataStoreName)" -ForegroundColor White
Write-Host "   • Schema File: $OutputPath" -ForegroundColor White
Write-Host "   • Total Fields: $(($schemaConfig.SearchableFields.Count + $schemaConfig.ClassificationFields.Count))" -ForegroundColor White
Write-Host "   • Searchable Fields: $($schemaConfig.SearchableFields.Count) (EmployeeID, Email, SSN)" -ForegroundColor White
Write-Host "   • Classification Fields: $($schemaConfig.ClassificationFields.Count)" -ForegroundColor White
Write-Host ""

Write-Host "⏭️  Next Steps - Upload Schema to Purview:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. Connect to Security & Compliance PowerShell:" -ForegroundColor White
Write-Host "      Connect-IPPSSession" -ForegroundColor Cyan
Write-Host ""
Write-Host "   2. Upload EDM schema to Purview:" -ForegroundColor White
Write-Host "      New-DlpEdmSchema -FileData ([System.IO.File]::ReadAllBytes('$OutputPath'))" -ForegroundColor Cyan
Write-Host ""
Write-Host "   3. Verify schema upload:" -ForegroundColor White
Write-Host "      Get-DlpEdmSchema -Identity '$($schemaConfig.DataStoreName)'" -ForegroundColor Cyan
Write-Host ""
Write-Host "   4. Wait for schema replication (5-10 minutes)" -ForegroundColor White
Write-Host "      - Schema must replicate across Microsoft 365 services" -ForegroundColor White
Write-Host "      - Check Purview Compliance Portal > Data classification > EDM" -ForegroundColor White
Write-Host ""
Write-Host "   5. Hash and upload employee data:" -ForegroundColor White
Write-Host "      - Run .\Upload-EDMData.ps1" -ForegroundColor White
Write-Host "      - Requires EDMUploadAgent.exe installed" -ForegroundColor White
Write-Host "      - Uses schema to validate data structure" -ForegroundColor White
Write-Host "      - Hashes data with SHA-256 and uploads to Purview" -ForegroundColor White
Write-Host ""
Write-Host "   6. Create EDM-based custom SIT:" -ForegroundColor White
Write-Host "      - Run .\Create-EDM-SIT.ps1" -ForegroundColor White
Write-Host "      - Links SIT to $($schemaConfig.DataStoreName)" -ForegroundColor White
Write-Host "      - Enables exact match classification" -ForegroundColor White
Write-Host ""

Write-Host "💡 EDM Schema Field Types:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Searchable Fields (searchable=`"true`"):" -ForegroundColor Cyan
Write-Host "   - These fields trigger EDM SIT detection when found in documents" -ForegroundColor White
Write-Host "   - EmployeeID: Primary identifier for employee records" -ForegroundColor White
Write-Host "   - Email: Secondary identifier (case-insensitive matching)" -ForegroundColor White
Write-Host "   - SSN: Tertiary identifier (high sensitivity)" -ForegroundColor White
Write-Host ""
Write-Host "   Classification Fields:" -ForegroundColor Cyan
Write-Host "   - Additional context fields included in hash database" -ForegroundColor White
Write-Host "   - Not used for document matching, but enriched in classification metadata" -ForegroundColor White
Write-Host "   - FirstName, LastName, Phone, Department, HireDate" -ForegroundColor White
Write-Host ""

Write-Host "🔍 Field Matching Attributes:" -ForegroundColor Yellow
Write-Host "   • caseInsensitive=`"true`": Email matching ignores case" -ForegroundColor White
Write-Host "     Example: john.doe@contoso.com = JOHN.DOE@CONTOSO.COM" -ForegroundColor Cyan
Write-Host ""
Write-Host "   • ignoredDelimiters=`"-`": Ignore hyphens in matching" -ForegroundColor White
Write-Host "     Example: EMP-1234-5678 = EMP12345678" -ForegroundColor Cyan
Write-Host "     Example: 123-45-6789 = 123456789" -ForegroundColor Cyan
Write-Host ""

Write-Host "⚠️  Important Notes:" -ForegroundColor Yellow
Write-Host "   - Schema must be uploaded BEFORE hashing/uploading employee data" -ForegroundColor White
Write-Host "   - Schema field names must exactly match CSV column headers" -ForegroundColor White
Write-Host "   - Schema changes require re-upload of hashed employee data" -ForegroundColor White
Write-Host "   - Wait 5-10 minutes after schema upload before proceeding" -ForegroundColor White
Write-Host ""

Write-Host "✅ Script execution completed successfully" -ForegroundColor Green
