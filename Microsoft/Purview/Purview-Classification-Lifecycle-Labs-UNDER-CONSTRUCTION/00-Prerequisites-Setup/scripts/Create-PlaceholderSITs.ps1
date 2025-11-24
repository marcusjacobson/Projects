<#
.SYNOPSIS
    Creates placeholder custom Sensitive Information Types for Purview Classification Labs.

.DESCRIPTION
    This script creates simple regex-based custom SITs that serve as placeholders
    for Lab 1 enhancement activities. By creating these early, you trigger background
    replication (5-15 minutes) and have working SITs to test against sample data.
    
    Creates 3 placeholder custom SITs:
    1. Contoso Employee ID (Pattern: EMP-\d{4}-\d{4})
    2. Contoso Customer Number (Pattern: CUST-\d{6})
    3. Contoso Project Code (Pattern: PROJ-\d{4}-\d{4})
    
    These placeholder SITs use low confidence (65%) and basic patterns.
    In Lab 1, you'll enhance them with:
    - Advanced regex patterns with validation
    - Keyword dictionaries for context-aware detection
    - Multi-level confidence scoring (High/Medium/Low)

.PARAMETER Verbose
    Show detailed progress during execution.

.EXAMPLE
    .\Create-PlaceholderSITs.ps1 -Verbose
    
    Creates 3 placeholder custom SITs with basic regex patterns and triggers
    background replication for global availability.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-13
    Last Modified: 2025-11-13
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - ExchangeOnlineManagement module v3.0+ installed
    - Security & Compliance PowerShell access
    - Compliance Administrator or Global Administrator role
    - Microsoft 365 E5 or E5 Compliance license
    
    Script development orchestrated using GitHub Copilot.

.PLACEHOLDER SITS
    1. Contoso Employee ID
       - Pattern: EMP-\d{4}-\d{4}
       - Confidence: Low (65%)
       - Lab 1 Enhancement: Checksum validation, context keywords
    
    2. Contoso Customer Number
       - Pattern: CUST-\d{6}
       - Confidence: Low (65%)
       - Lab 1 Enhancement: Range validation, corroborating evidence
    
    3. Contoso Project Code
       - Pattern: PROJ-\d{4}-\d{4}
       - Confidence: Low (65%)
       - Lab 1 Enhancement: Format validation, project keywords
#>

# =============================================================================
# Placeholder Custom SIT Creation for Purview Classification Labs
# =============================================================================

Write-Host "🔐 Placeholder Custom SIT Creation" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Security & Compliance PowerShell Authentication
# =============================================================================

Write-Host "📋 Step 1: Security & Compliance Authentication" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

Write-Host "🔐 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
Write-Host "   (Using modern authentication - browser window will open)" -ForegroundColor Yellow
Write-Host ""

# Connect to Security & Compliance PowerShell using modern authentication
# This bypasses the WAM issue by not using -UseRPSSession
try {
    # Use Connect-ExchangeOnline instead, which connects to both Exchange and Security & Compliance
    # It has better modern auth support and works around the WAM issue
    Write-Host "🔄 Initiating connection..." -ForegroundColor Cyan
    
    # Import the module explicitly to ensure cmdlets are available
    Import-Module ExchangeOnlineManagement -ErrorAction Stop
    
    # Connect using modern authentication (no UseRPSSession, no credentials)
    # This should open browser for interactive authentication
    Connect-IPPSSession -ErrorAction Stop
    
    Write-Host "✅ Connected to Security & Compliance successfully" -ForegroundColor Green
    
    # Verify connection and show details
    $connectionCheck = Get-ConnectionInformation -ErrorAction SilentlyContinue
    if ($connectionCheck) {
        Write-Host "   User: $($connectionCheck.UserPrincipalName)" -ForegroundColor Cyan
        Write-Host "   Organization: $($connectionCheck.TenantId)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Security & Compliance authentication failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Error details: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Troubleshooting Steps:" -ForegroundColor Cyan
    Write-Host "   1. If you see 'msalruntime' error, this is a known WAM issue" -ForegroundColor White
    Write-Host "   2. Try running: Connect-IPPSSession directly in PowerShell" -ForegroundColor White
    Write-Host "   3. Check if browser pop-ups are blocked" -ForegroundColor White
    Write-Host "   4. Verify you have Compliance Administrator or Global Administrator role" -ForegroundColor White
    Write-Host "   5. Try updating the module: Update-Module -Name ExchangeOnlineManagement -Force" -ForegroundColor White
    Write-Host ""
    Write-Host "⚠️  If the connection hangs, press Ctrl+C and try the workaround:" -ForegroundColor Yellow
    Write-Host "   Run 'Connect-IPPSSession' manually first, then re-run this script" -ForegroundColor White
    exit 1
}

# =============================================================================
# Step 2: Create Placeholder Custom SITs
# =============================================================================

Write-Host "`n📋 Step 2: Creating Placeholder Custom SITs" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

$createdSITs = @()

# SIT 1: Contoso Employee ID
Write-Host "`n🔸 Creating: Contoso Employee ID" -ForegroundColor Cyan

try {
    # Check if SIT already exists
    $existingSIT = Get-DlpSensitiveInformationType -Identity "Contoso Employee ID" -ErrorAction SilentlyContinue
    
    if ($existingSIT) {
        Write-Host "   ⚠️  'Contoso Employee ID' already exists - skipping" -ForegroundColor Yellow
    } else {
        # Create Employee ID SIT with inline XML
        $xml = @"
<?xml version="1.0" encoding="utf-8"?>
<RulePackage xmlns="http://schemas.microsoft.com/office/2011/mce">
  <RulePack id="$(New-Guid)">
    <Version major="1" minor="0" build="0" revision="0" />
    <Publisher id="$(New-Guid)" />
    <Details defaultLangCode="en-us">
      <LocalizedDetails langcode="en-us">
        <PublisherName>Contoso Corporation</PublisherName>
        <Name>Contoso Employee ID Pattern</Name>
        <Description>Placeholder SIT for Contoso employee identification numbers matching pattern EMP-####-####. This basic pattern will be enhanced in Lab 1 with checksum validation, context keywords, and multi-level confidence scoring for production deployment.</Description>
      </LocalizedDetails>
    </Details>
  </RulePack>
  <Rules>
    <Entity id="$(New-Guid)" patternsProximity="300" recommendedConfidence="65">
      <Pattern confidenceLevel="65">
        <IdMatch idRef="Regex_EmployeeID" />
      </Pattern>
    </Entity>
    <Regex id="Regex_EmployeeID">EMP-\d{4}-\d{4}</Regex>
  </Rules>
</RulePackage>
"@
        
        $tempXml = Join-Path $env:TEMP "ContosoEmployeeID.xml"
        Set-Content -Path $tempXml -Value $xml -Encoding UTF8
        
        New-DlpSensitiveInformationType -Name "Contoso Employee ID" `
            -Description "Placeholder SIT for Contoso employee identification numbers. Pattern: EMP-####-####. Enhanced in Lab 1 with checksum validation and context keywords." `
            -FileData ([System.IO.File]::ReadAllBytes($tempXml))
        
        Remove-Item $tempXml -Force
        
        Write-Host "   ✅ Created: Contoso Employee ID" -ForegroundColor Green
        Write-Host "      Pattern: EMP-\d{4}-\d{4}" -ForegroundColor White
        Write-Host "      Confidence: Low (65%)" -ForegroundColor White
        Write-Host "      Status: Enabled" -ForegroundColor White
        
        $createdSITs += "Contoso Employee ID"
    }
} catch {
    Write-Host "   ❌ Failed to create 'Contoso Employee ID': $($_.Exception.Message)" -ForegroundColor Red
}

# SIT 2: Contoso Customer Number
Write-Host "`n🔸 Creating: Contoso Customer Number" -ForegroundColor Cyan

try {
    # Check if SIT already exists
    $existingSIT = Get-DlpSensitiveInformationType -Identity "Contoso Customer Number" -ErrorAction SilentlyContinue
    
    if ($existingSIT) {
        Write-Host "   ⚠️  'Contoso Customer Number' already exists - skipping" -ForegroundColor Yellow
    } else {
        # Create using proper XML with sufficient content length
        $xml = @"
<?xml version="1.0" encoding="utf-8"?>
<RulePackage xmlns="http://schemas.microsoft.com/office/2011/mce">
  <RulePack id="$(New-Guid)">
    <Version major="1" minor="0" build="0" revision="0" />
    <Publisher id="$(New-Guid)" />
    <Details defaultLangCode="en-us">
      <LocalizedDetails langcode="en-us">
        <PublisherName>Contoso Corporation</PublisherName>
        <Name>Contoso Customer Number Pattern</Name>
        <Description>Placeholder SIT for Contoso customer account numbers matching pattern CUST-######. This basic pattern provides initial detection capability and will be enhanced in Lab 1 with range validation, corroborating evidence, and advanced confidence scoring for production use.</Description>
      </LocalizedDetails>
    </Details>
  </RulePack>
  <Rules>
    <Entity id="$(New-Guid)" patternsProximity="300" recommendedConfidence="65">
      <Pattern confidenceLevel="65">
        <IdMatch idRef="Regex_CustomerNumber" />
      </Pattern>
    </Entity>
    <Regex id="Regex_CustomerNumber">CUST-\d{6}</Regex>
  </Rules>
</RulePackage>
"@
        
        $tempXml = Join-Path $env:TEMP "ContosoCustomerNumber.xml"
        Set-Content -Path $tempXml -Value $xml -Encoding UTF8
        
        New-DlpSensitiveInformationType -Name "Contoso Customer Number" `
            -Description "Placeholder SIT for Contoso customer account numbers. Pattern: CUST-######. Enhanced in Lab 1 with range validation and corroborating evidence." `
            -FileData ([System.IO.File]::ReadAllBytes($tempXml))
        
        Remove-Item $tempXml -Force
        
        Write-Host "   ✅ Created: Contoso Customer Number" -ForegroundColor Green
        Write-Host "      Pattern: CUST-\d{6}" -ForegroundColor White
        Write-Host "      Confidence: Low (65%)" -ForegroundColor White
        Write-Host "      Status: Enabled" -ForegroundColor White
        
        $createdSITs += "Contoso Customer Number"
    }
} catch {
    Write-Host "   ❌ Failed to create 'Contoso Customer Number': $($_.Exception.Message)" -ForegroundColor Red
}

# SIT 3: Contoso Project Code
Write-Host "`n🔸 Creating: Contoso Project Code" -ForegroundColor Cyan

try {
    # Check if SIT already exists
    $existingSIT = Get-DlpSensitiveInformationType -Identity "Contoso Project Code" -ErrorAction SilentlyContinue
    
    if ($existingSIT) {
        Write-Host "   ⚠️  'Contoso Project Code' already exists - skipping" -ForegroundColor Yellow
    } else {
        # Create using proper XML with sufficient content length
        $xml = @"
<?xml version="1.0" encoding="utf-8"?>
<RulePackage xmlns="http://schemas.microsoft.com/office/2011/mce">
  <RulePack id="$(New-Guid)">
    <Version major="1" minor="0" build="0" revision="0" />
    <Publisher id="$(New-Guid)" />
    <Details defaultLangCode="en-us">
      <LocalizedDetails langcode="en-us">
        <PublisherName>Contoso Corporation</PublisherName>
        <Name>Contoso Project Code Pattern</Name>
        <Description>Placeholder SIT for Contoso project identification codes matching pattern PROJ-####-####. This foundational pattern enables initial project tracking and will be enhanced in Lab 1 with format validation, project keywords, and sophisticated confidence tuning for enterprise deployment.</Description>
      </LocalizedDetails>
    </Details>
  </RulePack>
  <Rules>
    <Entity id="$(New-Guid)" patternsProximity="300" recommendedConfidence="65">
      <Pattern confidenceLevel="65">
        <IdMatch idRef="Regex_ProjectCode" />
      </Pattern>
    </Entity>
    <Regex id="Regex_ProjectCode">PROJ-\d{4}-\d{4}</Regex>
  </Rules>
</RulePackage>
"@
        
        $tempXml = Join-Path $env:TEMP "ContosoProjectCode.xml"
        Set-Content -Path $tempXml -Value $xml -Encoding UTF8
        
        New-DlpSensitiveInformationType -Name "Contoso Project Code" `
            -Description "Placeholder SIT for Contoso project identification codes. Pattern: PROJ-####-####. Enhanced in Lab 1 with format validation and project keywords." `
            -FileData ([System.IO.File]::ReadAllBytes($tempXml))
        
        Remove-Item $tempXml -Force
        
        Write-Host "   ✅ Created: Contoso Project Code" -ForegroundColor Green
        Write-Host "      Pattern: PROJ-\d{4}-\d{4}" -ForegroundColor White
        Write-Host "      Confidence: Low (65%)" -ForegroundColor White
        Write-Host "      Status: Enabled" -ForegroundColor White
        
        $createdSITs += "Contoso Project Code"
    }
} catch {
    Write-Host "   ❌ Failed to create 'Contoso Project Code': $($_.Exception.Message)" -ForegroundColor Red
}

# =============================================================================
# Step 3: Validation and Summary
# =============================================================================

Write-Host "`n📋 Step 3: Validation and Summary" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# List all custom SITs to verify creation
Write-Host "`n🔍 Verifying custom SITs..." -ForegroundColor Cyan

try {
    $allCustomSITs = Get-DlpSensitiveInformationType | Where-Object { 
        $_.Publisher -ne "Microsoft Corporation" -and 
        ($_.Name -like "*Contoso*")
    }
    
    if ($allCustomSITs) {
        Write-Host "`n✅ Custom SITs in Microsoft Purview:" -ForegroundColor Green
        foreach ($sit in $allCustomSITs) {
            Write-Host "   • $($sit.Name)" -ForegroundColor White
        }
    } else {
        Write-Host "⚠️  No custom SITs found - verification may require replication time" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Could not verify SITs: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Disconnect from Security & Compliance
Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue

Write-Host "`n🎉 Placeholder Custom SIT Creation Complete!" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""

if ($createdSITs.Count -gt 0) {
    Write-Host "✅ Successfully created $($createdSITs.Count) placeholder SIT(s):" -ForegroundColor Green
    foreach ($sitName in $createdSITs) {
        Write-Host "   • $sitName" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "⏱️  Background Replication Started:" -ForegroundColor Cyan
    Write-Host "   Custom SITs will be available globally in 5-15 minutes." -ForegroundColor White
    Write-Host "   Continue to Exercise 4 immediately - no need to wait!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Lab 1 Enhancement:" -ForegroundColor Cyan
    Write-Host "   In Lab 1, you'll enhance these SITs with:" -ForegroundColor White
    Write-Host "   • Advanced regex patterns with validation logic" -ForegroundColor White
    Write-Host "   • Keyword dictionaries for context-aware detection" -ForegroundColor White
    Write-Host "   • Multi-level confidence scoring (High/Medium/Low)" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "⚠️  No new SITs were created (may already exist)" -ForegroundColor Yellow
    Write-Host "   Run Remove-PlaceholderSITs.ps1 if you need to recreate them" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "✅ Ready for Exercise 4: Initial Retention Label Configuration" -ForegroundColor Green
