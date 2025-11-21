<#
.SYNOPSIS
    Creates an EDM-based custom Sensitive Information Type (SIT) in Microsoft Purview.

.DESCRIPTION
    This script creates a custom SIT that uses Exact Data Match (EDM) for classification,
    linking to an existing EDM data store. The SIT is configured with multiple confidence
    levels based on the number of searchable fields that match the uploaded database.

.PARAMETER DataStoreName
    Name of the EDM data store to link to (must already be uploaded).

.PARAMETER SchemaVersion
    Version of the EDM schema to use.
    Default: 1.0

.PARAMETER SITName
    Name for the custom EDM SIT.
    Default: Contoso Employee Record (EDM)

.PARAMETER Description
    Description for the custom SIT.
    Default: Detects Contoso employee records using Exact Data Match (EDM) for zero false positives

.EXAMPLE
    .\Create-EDM-SIT.ps1 -DataStoreName "EmployeeDataStore" -SchemaVersion "1.0"
    
    Creates EDM-based custom SIT with default name and description.

.EXAMPLE
    .\Create-EDM-SIT.ps1 -DataStoreName "EmployeeDataStore_US" -SITName "US Employee Record (EDM)" -Description "US employee database EDM classification"
    
    Creates custom EDM SIT with custom name and description.

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
    - Compliance Administrator role or higher
    - EDM schema and data already uploaded to Purview
    
    Script development orchestrated using GitHub Copilot.

.CONFIDENCE LEVELS
    - High (95%): EmployeeID + SSN + Email match
    - Medium (85%): EmployeeID + any 1 additional field match
    - Low (75%): EmployeeID match only
#>

#Requires -Version 7.0
#Requires -Modules ExchangeOnlineManagement

# =============================================================================
# Create EDM-based custom Sensitive Information Type.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Name of the EDM data store")]
    [ValidateNotNullOrEmpty()]
    [string]$DataStoreName,

    [Parameter(Mandatory = $false, HelpMessage = "EDM schema version")]
    [ValidatePattern('^\d+\.\d+$')]
    [string]$SchemaVersion = "1.0",

    [Parameter(Mandatory = $false, HelpMessage = "Name for the custom SIT")]
    [string]$SITName = "Contoso Employee Record (EDM)",

    [Parameter(Mandatory = $false, HelpMessage = "Description for the custom SIT")]
    [string]$Description = "Detects Contoso employee records using Exact Data Match (EDM) for zero false positives"
)

# =============================================================================
# Step 1: Connect to Security & Compliance PowerShell
# =============================================================================

Write-Host "🔐 Step 1: Authentication" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

try {
    Write-Host "📋 Checking Security & Compliance PowerShell connection..." -ForegroundColor Cyan
    
    # Check if already connected by testing Get-DlpEdmSchema cmdlet
    $testConnection = $null
    try {
        $testConnection = Get-DlpEdmSchema -ErrorAction SilentlyContinue | Select-Object -First 1
        Write-Host "   ✅ Already connected to Security & Compliance PowerShell" -ForegroundColor Green
    } catch {
        # Not connected, need to connect
        $testConnection = $null
    }
    
    if (-not $testConnection -and $null -eq $testConnection) {
        Write-Host "   📋 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
        Write-Host "   ℹ️  You will be prompted to sign in via browser" -ForegroundColor Yellow
        
        # Use Connect-IPPSSession without credentials for interactive browser-based auth
        Connect-IPPSSession -WarningAction SilentlyContinue | Out-Null
        
        Write-Host "   ✅ Connected to Security & Compliance PowerShell" -ForegroundColor Green
    }
    
    Write-Host ""

} catch {
    Write-Host "   ❌ Authentication failed: $_" -ForegroundColor Red
    Write-Host "   ℹ️  Ensure you have appropriate permissions (Compliance Administrator or higher)" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 2: Verify EDM Schema and Data
# =============================================================================

Write-Host "🔍 Step 2: EDM Schema Verification" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

try {
    Write-Host "📋 Verifying EDM data store..." -ForegroundColor Cyan
    
    $schema = Get-DlpEdmSchema | Where-Object {$_.DataStoreName -eq $DataStoreName} -ErrorAction Stop
    
    if ($schema) {
        Write-Host "   ✅ EDM data store found" -ForegroundColor Green
        Write-Host "      Data Store: $($schema.DataStoreName)" -ForegroundColor White
        Write-Host "      Status: $($schema.Status)" -ForegroundColor White
        Write-Host "      Schema Version: $($schema.SchemaVersion)" -ForegroundColor White
        
        # Check if data has been uploaded (may not be indexed yet)
        if ($schema.Status -eq "Active") {
            Write-Host "      ✅ Data store is active" -ForegroundColor Green
        } else {
            Write-Host "      ⚠️  Data store status: $($schema.Status)" -ForegroundColor Yellow
            Write-Host "      Note: EDM data may still be indexing (30-90 min)" -ForegroundColor Yellow
        }
    } else {
        throw "EDM data store not found: $DataStoreName"
    }
    
    Write-Host ""

} catch {
    Write-Host "   ❌ EDM verification failed: $_" -ForegroundColor Red
    Write-Host "   💡 Ensure EDM schema and data have been uploaded:" -ForegroundColor Cyan
    Write-Host "      1. Run Upload-EDMSchema.ps1 first" -ForegroundColor White
    Write-Host "      2. Run Upload-EDMData.ps1 second" -ForegroundColor White
    exit 1
}

# =============================================================================
# Step 3: Check for Existing SIT
# =============================================================================

Write-Host "🔍 Step 3: Existing SIT Check" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

try {
    Write-Host "📋 Checking for existing custom SITs..." -ForegroundColor Cyan
    
    $existingSITs = Get-DlpSensitiveInformationType -ErrorAction Stop | 
                    Where-Object { $_.Publisher -ne "Microsoft Corporation" }
    
    $matchingSIT = $existingSITs | Where-Object { $_.Name -eq $SITName }
    
    if ($matchingSIT) {
        Write-Host "   ⚠️  Warning: SIT '$SITName' already exists" -ForegroundColor Yellow
        Write-Host "      Publisher: $($matchingSIT.Publisher)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   ❌ Cannot create SIT - name already in use" -ForegroundColor Red
        Write-Host "   💡 Options:" -ForegroundColor Cyan
        Write-Host "      1. Use -SITName parameter with different name" -ForegroundColor White
        Write-Host "      2. Remove existing SIT: Remove-DlpSensitiveInformationType -Identity '$SITName'" -ForegroundColor White
        exit 1
    } else {
        Write-Host "   ✅ SIT name available" -ForegroundColor Green
    }
    
    Write-Host ""

} catch {
    Write-Host "   ⚠️  Warning: Could not check existing SITs: $_" -ForegroundColor Yellow
    Write-Host "   Continuing with SIT creation..." -ForegroundColor Cyan
    Write-Host ""
}

# =============================================================================
# Step 4: Build EDM Rule Package
# =============================================================================

Write-Host "📝 Step 4: Build EDM Rule Package" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

Write-Host "📋 Configuring EDM detection rules..." -ForegroundColor Cyan

# Generate unique GUID for the rule package
$rulePackageId = [System.Guid]::NewGuid().ToString()
$entityId = [System.Guid]::NewGuid().ToString()
$primaryPatternId = [System.Guid]::NewGuid().ToString()

# Build EDM rule package XML
$rulePackageXml = @"
<?xml version="1.0" encoding="utf-8"?>
<RulePackage xmlns="http://schemas.microsoft.com/office/2018/edm">
  <RulePack id="$rulePackageId">
    <Version major="1" minor="0" build="0" revision="0" />
    <Publisher id="Contoso Ltd." />
    <Details defaultLangCode="en-us">
      <LocalizedDetails langcode="en-us">
        <PublisherName>Contoso Ltd.</PublisherName>
        <Name>$SITName</Name>
        <Description>$Description</Description>
      </LocalizedDetails>
    </Details>
  </RulePack>
  <Rules>
    <ExactMatch id="$entityId" patternsProximity="300" dataStore="$DataStoreName" recommendedConfidence="85">
      <Pattern confidenceLevel="95">
        <idMatch matches="EmployeeID" />
        <Any minMatches="2">
          <match matches="Email" />
          <match matches="SSN" />
        </Any>
      </Pattern>
      <Pattern confidenceLevel="85">
        <idMatch matches="EmployeeID" />
        <Any minMatches="1">
          <match matches="Email" />
          <match matches="SSN" />
        </Any>
      </Pattern>
      <Pattern confidenceLevel="75">
        <idMatch matches="EmployeeID" />
      </Pattern>
    </ExactMatch>
    <LocalizedStrings>
      <Resource idRef="$entityId">
        <Name default="true" langcode="en-us">$SITName</Name>
        <Description default="true" langcode="en-us">$Description</Description>
      </Resource>
    </LocalizedStrings>
  </Rules>
</RulePackage>
"@

Write-Host "   ✅ EDM rule package configured" -ForegroundColor Green
Write-Host "      Data Store: $DataStoreName" -ForegroundColor White
Write-Host "      Primary Field: EmployeeID" -ForegroundColor White
Write-Host "      Supporting Fields: Email, SSN" -ForegroundColor White
Write-Host "      Confidence Levels: High (95%), Medium (85%), Low (75%)" -ForegroundColor White
Write-Host ""

# =============================================================================
# Step 5: Create EDM Custom SIT
# =============================================================================

Write-Host "🎯 Step 5: Create EDM Custom SIT" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

try {
    Write-Host "📋 Creating EDM-based custom SIT..." -ForegroundColor Cyan
    Write-Host "   ℹ️  This may take 1-2 minutes..." -ForegroundColor Yellow
    
    # Save XML to temporary file (required for FileData parameter)
    $tempXmlPath = Join-Path $env:TEMP "EDM_RulePackage_$(Get-Date -Format 'yyyyMMddHHmmss').xml"
    $rulePackageXml | Out-File -FilePath $tempXmlPath -Encoding UTF8 -Force
    
    try {
        # Convert XML file to byte array
        $rulePackageBytes = [System.IO.File]::ReadAllBytes($tempXmlPath)
        
        # Create the custom SIT using New-DlpSensitiveInformationType with Name parameter
        New-DlpSensitiveInformationType -Name $SITName -Description $Description -FileData $rulePackageBytes -ErrorAction Stop | Out-Null
        
        Write-Host "   ✅ EDM custom SIT created successfully" -ForegroundColor Green
        Write-Host ""
    }
    finally {
        # Clean up temporary file
        if (Test-Path $tempXmlPath) {
            Remove-Item $tempXmlPath -Force -ErrorAction SilentlyContinue
        }
    }

} catch {
    Write-Host "   ❌ SIT creation failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Common Issues:" -ForegroundColor Cyan
    Write-Host "   • SIT name already exists (use different name)" -ForegroundColor White
    Write-Host "   • EDM data store not found (verify DataStoreName)" -ForegroundColor White
    Write-Host "   • Field names don't match schema (EmployeeID, Email, SSN)" -ForegroundColor White
    Write-Host "   • Insufficient permissions (requires Compliance Administrator)" -ForegroundColor White
    Write-Host "   • XML rule package format incompatible with current cmdlet version" -ForegroundColor White
    exit 1
}

# =============================================================================
# Step 6: Verify SIT Creation
# =============================================================================

Write-Host "✅ Step 6: Verification" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green

try {
    Write-Host "📋 Retrieving created SIT information..." -ForegroundColor Cyan
    
    # Wait a moment for SIT to be indexed
    Start-Sleep -Seconds 3
    
    $createdSIT = Get-DlpSensitiveInformationType | Where-Object { $_.Name -eq $SITName } -ErrorAction Stop
    
    if ($createdSIT) {
        Write-Host "   ✅ SIT verification successful" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "📊 Created SIT Details:" -ForegroundColor Cyan
        Write-Host "   Name: $($createdSIT.Name)" -ForegroundColor White
        Write-Host "   ID: $($createdSIT.Id)" -ForegroundColor White
        Write-Host "   Publisher: $($createdSIT.Publisher)" -ForegroundColor White
        Write-Host "   Description: $($createdSIT.Description)" -ForegroundColor White
        Write-Host "   Type: EDM-based (Exact Data Match)" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "   ⚠️  SIT created but verification failed" -ForegroundColor Yellow
        Write-Host "   SIT may still be processing..." -ForegroundColor Yellow
        Write-Host ""
    }

} catch {
    Write-Host "   ⚠️  SIT verification failed: $_" -ForegroundColor Yellow
    Write-Host "   SIT may still be processing in Purview..." -ForegroundColor Yellow
    Write-Host ""
}

# =============================================================================
# Step 7: Detection Logic Explanation
# =============================================================================

Write-Host "🔍 Step 7: Detection Logic" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

Write-Host "📋 EDM Detection Confidence Levels:" -ForegroundColor Cyan
Write-Host ""

Write-Host "   🔴 High Confidence (95%):" -ForegroundColor Red
Write-Host "      • EmployeeID + SSN + Email all match database" -ForegroundColor White
Write-Host "      • Example: Document contains EMP-1234-5678, 123-45-6789, and emily.rodriguez@contoso.com" -ForegroundColor DarkGray
Write-Host ""

Write-Host "   🟡 Medium Confidence (85%):" -ForegroundColor Yellow
Write-Host "      • EmployeeID + any 1 additional field match" -ForegroundColor White
Write-Host "      • Example: Document contains EMP-1234-5678 and emily.rodriguez@contoso.com" -ForegroundColor DarkGray
Write-Host ""

Write-Host "   🟢 Low Confidence (75%):" -ForegroundColor Green
Write-Host "      • EmployeeID matches database only" -ForegroundColor White
Write-Host "      • Example: Document contains EMP-1234-5678 alone" -ForegroundColor DarkGray
Write-Host ""

Write-Host "💡 EDM Matching Process:" -ForegroundColor Cyan
Write-Host "   1. Purview extracts potential values from document content" -ForegroundColor White
Write-Host "   2. Each value is hashed using SHA-256 locally" -ForegroundColor White
Write-Host "   3. Hashes are compared to EDM data store" -ForegroundColor White
Write-Host "   4. If hash exists in database = MATCH (exact database value)" -ForegroundColor White
Write-Host "   5. Confidence level determined by number of matching fields" -ForegroundColor White
Write-Host ""

# =============================================================================
# Step 8: Next Steps
# =============================================================================

Write-Host "🎯 Step 8: Next Steps" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green

Write-Host "📋 Recommended Actions:" -ForegroundColor Cyan
Write-Host "   1. Wait 30-90 minutes for EDM data indexing to complete (if not already done)" -ForegroundColor White
Write-Host "   2. Create test documents using Create-EDMTestDocuments.ps1" -ForegroundColor White
Write-Host "   3. Validate EDM classification using Validate-EDMClassification.ps1" -ForegroundColor White
Write-Host "   4. Compare EDM accuracy vs regex-based SIT from Lab 1" -ForegroundColor White
Write-Host "   5. Configure DLP policies to use the new EDM SIT" -ForegroundColor White
Write-Host ""

Write-Host "📋 Check EDM Data Status:" -ForegroundColor Cyan
Write-Host "   Get-DlpEdmSchema | Where-Object {\$_.DataStoreName -eq '$DataStoreName'} | Select-Object DataStoreName, RecordCount, Status" -ForegroundColor White
Write-Host ""

Write-Host "📋 Create Test Documents Command:" -ForegroundColor Cyan
Write-Host "   .\Create-EDMTestDocuments.ps1 -OutputPath 'C:\PurviewLabs\Lab2-EDM-Testing\TestDocs'" -ForegroundColor White
Write-Host ""

Write-Host "📋 Validation Command (after EDM indexing complete):" -ForegroundColor Cyan
Write-Host "   .\Validate-EDMClassification.ps1 -TestDataPath 'C:\PurviewLabs\Lab2-EDM-Testing\TestDocs'" -ForegroundColor White
Write-Host ""

Write-Host "⚠️  Important Notes:" -ForegroundColor Yellow
Write-Host "   • EDM classification requires data indexing to complete (30-90 min from upload)" -ForegroundColor Yellow
Write-Host "   • Test with actual database values for accurate validation" -ForegroundColor Yellow
Write-Host "   • EDM provides zero false positives (only exact database matches)" -ForegroundColor Yellow
Write-Host "   • Use in DLP policies for high-accuracy employee data protection" -ForegroundColor Yellow
Write-Host ""

Write-Host "✅ EDM custom SIT created successfully" -ForegroundColor Green
exit 0
