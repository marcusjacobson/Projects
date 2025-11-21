<#
.SYNOPSIS
    Creates an EDM (Exact Data Match) schema XML file for Microsoft Purview.

.DESCRIPTION
    This script generates an EDM schema definition file that defines the structure
    of the employee database for EDM-based classification. The schema specifies
    searchable fields (used for matching) and non-searchable fields (supporting data).

.PARAMETER OutputPath
    Directory where the EDM schema XML will be created.
    Default: C:\PurviewLabs\Lab2-EDM-Testing\configs

.PARAMETER DataStoreName
    Name of the EDM data store (must be unique in tenant).
    Default: EmployeeDataStore

.PARAMETER SchemaVersion
    Version of the schema being created.
    Default: 1.0

.EXAMPLE
    .\Create-EDMSchema.ps1
    
    Creates EmployeeDatabase_Schema.xml in default location with default data store name.

.EXAMPLE
    .\Create-EDMSchema.ps1 -DataStoreName "EmployeeDataStore_US" -SchemaVersion "2.0"
    
    Creates schema with custom data store name and version.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-14
    Last Modified: 2025-11-14
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 7.0 or later
    - Write permissions to output directory
    
    Script development orchestrated using GitHub Copilot.

.SCHEMA CONFIGURATION
    - Searchable Fields (3): EmployeeID, Email, SSN
    - Non-Searchable Fields (5): FirstName, LastName, Phone, Department, HireDate
    - Case-Insensitive Fields: Email (allows flexible matching)
    - DataStore: Logical container for EDM data (EmployeeDataStore)
#>

#Requires -Version 7.0

# =============================================================================
# Create EDM schema XML definition for employee database.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, HelpMessage = "Directory for EDM schema XML output")]
    [string]$OutputPath = "C:\PurviewLabs\Lab2-EDM-Testing\configs",

    [Parameter(Mandatory = $false, HelpMessage = "Name of the EDM data store")]
    [ValidateNotNullOrEmpty()]
    [string]$DataStoreName = "EmployeeDataStore",

    [Parameter(Mandatory = $false, HelpMessage = "Schema version")]
    [ValidateRange(1, 99)]
    [int]$SchemaVersion = 1
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
# Step 1: Environment Setup
# =============================================================================

Write-Host "🔍 Step 1: Environment Setup" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

try {
    Write-Host "📋 Creating output directory..." -ForegroundColor Cyan
    
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        Write-Host "   ✅ Created directory: $OutputPath" -ForegroundColor Green
    } else {
        Write-Host "   ✅ Directory already exists: $OutputPath" -ForegroundColor Green
    }
    
    Write-Host ""

} catch {
    Write-Host "   ❌ Failed to create output directory: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Define Schema Structure
# =============================================================================

Write-Host "📐 Step 2: Define Schema Structure" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

Write-Host "📋 Configuring EDM schema fields..." -ForegroundColor Cyan

# Define searchable fields (maximum 5 recommended)
$searchableFields = @(
    @{
        Name = "EmployeeID"
        Searchable = $true
        CaseInsensitive = $false
        Description = "Primary employee identifier (EMP-####-####)"
    },
    @{
        Name = "Email"
        Searchable = $true
        CaseInsensitive = $true
        Description = "Employee email address (case-insensitive matching)"
    },
    @{
        Name = "SSN"
        Searchable = $true
        CaseInsensitive = $false
        Description = "Social Security Number (###-##-####)"
    }
)

# Define non-searchable fields (supporting data)
$nonSearchableFields = @(
    @{
        Name = "FirstName"
        Description = "Employee first name"
    },
    @{
        Name = "LastName"
        Description = "Employee last name"
    },
    @{
        Name = "Phone"
        Description = "Employee phone number"
    },
    @{
        Name = "Department"
        Description = "Employee department"
    },
    @{
        Name = "HireDate"
        Description = "Employee hire date"
    }
)

Write-Host "   ✅ Schema structure defined" -ForegroundColor Green
Write-Host "      Searchable Fields: $($searchableFields.Count)" -ForegroundColor White
Write-Host "      Non-Searchable Fields: $($nonSearchableFields.Count)" -ForegroundColor White
Write-Host ""

# =============================================================================
# Step 3: Generate EDM Schema XML
# =============================================================================

Write-Host "📝 Step 3: Generate EDM Schema XML" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

Write-Host "📋 Building XML structure..." -ForegroundColor Cyan

# Create XML document
$xmlDoc = New-Object System.Xml.XmlDocument
$declaration = $xmlDoc.CreateXmlDeclaration("1.0", "UTF-8", $null)
$xmlDoc.AppendChild($declaration) | Out-Null

# Define EDM namespace
$edmNamespace = "http://schemas.microsoft.com/office/2018/edm"

# Create root element with namespace
$edmSchema = $xmlDoc.CreateElement("EdmSchema", $edmNamespace)
$xmlDoc.AppendChild($edmSchema) | Out-Null

# Create DataStore element (inherits namespace from parent)
$dataStore = $xmlDoc.CreateElement("DataStore", $edmNamespace)
$dataStore.SetAttribute("name", $DataStoreName)
$dataStore.SetAttribute("description", "Contoso Employee Database for EDM Classification (Schema v$SchemaVersion)")
$dataStore.SetAttribute("version", $SchemaVersion)
$edmSchema.AppendChild($dataStore) | Out-Null

# Add searchable fields
foreach ($field in $searchableFields) {
    $fieldElement = $xmlDoc.CreateElement("Field", $edmNamespace)
    $fieldElement.SetAttribute("name", $field.Name)
    $fieldElement.SetAttribute("searchable", "true")
    
    if ($field.CaseInsensitive) {
        $fieldElement.SetAttribute("caseInsensitive", "true")
    }
    
    $dataStore.AppendChild($fieldElement) | Out-Null
}

# Add non-searchable fields
foreach ($field in $nonSearchableFields) {
    $fieldElement = $xmlDoc.CreateElement("Field", $edmNamespace)
    $fieldElement.SetAttribute("name", $field.Name)
    $fieldElement.SetAttribute("searchable", "false")
    
    $dataStore.AppendChild($fieldElement) | Out-Null
}

Write-Host "   ✅ XML structure created" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 4: Export Schema to XML File
# =============================================================================

Write-Host "💾 Step 4: Export Schema to File" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

try {
    $schemaPath = Join-Path $OutputPath "EmployeeDatabase_Schema.xml"
    
    Write-Host "📋 Saving EDM schema XML..." -ForegroundColor Cyan
    
    # Create XML writer settings for formatting
    $writerSettings = New-Object System.Xml.XmlWriterSettings
    $writerSettings.Indent = $true
    $writerSettings.IndentChars = "  "
    $writerSettings.Encoding = [System.Text.Encoding]::UTF8
    
    # Write XML to file
    $writer = [System.Xml.XmlWriter]::Create($schemaPath, $writerSettings)
    $xmlDoc.Save($writer)
    $writer.Close()
    
    $fileSize = (Get-Item $schemaPath).Length
    $fileSizeKB = [math]::Round($fileSize / 1KB, 2)
    
    Write-Host "   ✅ Schema exported successfully" -ForegroundColor Green
    Write-Host "   📄 File: $schemaPath" -ForegroundColor White
    Write-Host "   💾 Size: $fileSizeKB KB" -ForegroundColor White
    Write-Host ""

} catch {
    Write-Host "   ❌ Failed to export schema: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 5: Display Schema Details
# =============================================================================

Write-Host "📊 Step 5: Schema Configuration" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

Write-Host "📋 EDM Data Store Configuration:" -ForegroundColor Cyan
Write-Host "   Data Store Name: $DataStoreName" -ForegroundColor White
Write-Host "   Schema Version: $SchemaVersion" -ForegroundColor White
Write-Host "   Total Fields: $($searchableFields.Count + $nonSearchableFields.Count)" -ForegroundColor White
Write-Host ""

Write-Host "📋 Searchable Fields (Used for Matching):" -ForegroundColor Cyan
foreach ($field in $searchableFields) {
    $caseInfo = if ($field.CaseInsensitive) { " (case-insensitive)" } else { "" }
    Write-Host "   ✓ $($field.Name)$caseInfo - $($field.Description)" -ForegroundColor White
}
Write-Host ""

Write-Host "📋 Non-Searchable Fields (Supporting Data):" -ForegroundColor Cyan
foreach ($field in $nonSearchableFields) {
    Write-Host "   - $($field.Name) - $($field.Description)" -ForegroundColor White
}
Write-Host ""

Write-Host "💡 Field Configuration Tips:" -ForegroundColor Yellow
Write-Host "   • Searchable fields are matched against document content" -ForegroundColor White
Write-Host "   • Maximum 5 searchable fields recommended for performance" -ForegroundColor White
Write-Host "   • Case-insensitive matching allows flexible email detection" -ForegroundColor White
Write-Host "   • Non-searchable fields enrich results without impacting matching" -ForegroundColor White
Write-Host ""

# =============================================================================
# Step 6: Schema Preview
# =============================================================================

Write-Host "📄 Step 6: Schema XML Preview" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

Write-Host "📋 Generated Schema Content:" -ForegroundColor Cyan
Write-Host ""
Write-Host "<?xml version=`"1.0`" encoding=`"UTF-8`"?>" -ForegroundColor DarkGray
Write-Host "<EdmSchema xmlns=`"http://schemas.microsoft.com/office/2018/edm`">" -ForegroundColor DarkGray
Write-Host "  <DataStore name=`"$DataStoreName`" description=`"Contoso Employee Database...`">" -ForegroundColor DarkGray
Write-Host "    <Field name=`"EmployeeID`" searchable=`"true`" />" -ForegroundColor DarkGray
Write-Host "    <Field name=`"Email`" searchable=`"true`" caseInsensitive=`"true`" />" -ForegroundColor DarkGray
Write-Host "    <Field name=`"SSN`" searchable=`"true`" />" -ForegroundColor DarkGray
Write-Host "    <Field name=`"FirstName`" searchable=`"false`" />" -ForegroundColor DarkGray
Write-Host "    ..." -ForegroundColor DarkGray
Write-Host "  </DataStore>" -ForegroundColor DarkGray
Write-Host "</EdmSchema>" -ForegroundColor DarkGray
Write-Host ""

# =============================================================================
# Step 7: Next Steps
# =============================================================================

Write-Host "🎯 Step 7: Next Steps" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green

Write-Host "📋 Recommended Actions:" -ForegroundColor Cyan
Write-Host "   1. Review EmployeeDatabase_Schema.xml to verify field configuration" -ForegroundColor White
Write-Host "   2. Run Upload-EDMSchema.ps1 to upload schema to Microsoft Purview" -ForegroundColor White
Write-Host "   3. After schema upload, run Upload-EDMData.ps1 to hash and upload employee data" -ForegroundColor White
Write-Host "   4. Wait 30-90 minutes for EDM indexing to complete" -ForegroundColor White
Write-Host ""

Write-Host "📋 Upload Command:" -ForegroundColor Cyan
Write-Host "   .\Upload-EDMSchema.ps1 -SchemaPath `"$schemaPath`"" -ForegroundColor White
Write-Host ""

Write-Host "⚠️  Important Notes:" -ForegroundColor Yellow
Write-Host "   • Data Store name must be unique across your tenant" -ForegroundColor Yellow
Write-Host "   • Schema fields must exactly match CSV column names" -ForegroundColor Yellow
Write-Host "   • Schema cannot be modified after upload (create new version instead)" -ForegroundColor Yellow
Write-Host ""

Write-Host "✅ EDM schema created successfully" -ForegroundColor Green
exit 0
