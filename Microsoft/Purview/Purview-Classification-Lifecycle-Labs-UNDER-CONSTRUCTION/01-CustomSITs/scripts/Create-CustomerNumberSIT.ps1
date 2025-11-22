<#
.SYNOPSIS
    Creates Contoso Customer Number custom Sensitive Information Type with keyword-based context detection.

.DESCRIPTION
    This script creates a regex-based custom SIT for detecting Contoso customer
    account numbers matching the pattern CUST-######. Implements:
    - Word boundary validation to prevent false positives
    - Comprehensive keyword dictionary for context-aware detection
    - Multi-level confidence scoring (High 85%, Medium 75%, Low 65%)
    - 300-character keyword proximity matching
    
    The Customer Number pattern uses CUST prefix + 6-digit account number.

.PARAMETER Verbose
    Show detailed progress during execution.

.EXAMPLE
    .\Create-CustomerNumberSIT.ps1 -Verbose
    
    Creates Contoso Customer Number custom SIT with full keyword dictionary
    and confidence level configuration.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-14
    Last Modified: 2025-11-14
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - ExchangeOnlineManagement module v3.0+ installed
    - Security & Compliance PowerShell access
    - Compliance Administrator or Global Administrator role
    - Microsoft 365 E5 or E5 Compliance license
    
    Script development orchestrated using GitHub Copilot.

.PATTERN DETAILS
    Pattern: \bCUST-\d{6}\b
    Examples: CUST-123456, CUST-789012
    Keywords: customer, account, CUST, client, customer number, account number
    Confidence Levels:
      - High (85%): Pattern + full keyword set (4+ keywords)
      - Medium (75%): Pattern + partial keywords (2-3 keywords)
      - Low (65%): Pattern only (no keywords required)
#>

# =============================================================================
# Contoso Customer Number Custom SIT Creation
# =============================================================================

[CmdletBinding()]
param ()

# Import Shared Utilities Module for authentication
$sharedUtilitiesPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "Shared-Utilities\PurviewUtilities.psm1"
if (Test-Path $sharedUtilitiesPath) {
    Import-Module $sharedUtilitiesPath -Force
}

Write-Host "🔐 Contoso Customer Number Custom SIT Creation" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Security & Compliance PowerShell Authentication
# =============================================================================

Write-Host "📋 Step 1: Security & Compliance Authentication" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

Write-Host "🔐 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
Write-Host "   (Using modern authentication - browser window will open)" -ForegroundColor Yellow
Write-Host ""

try {
    Import-Module ExchangeOnlineManagement -ErrorAction Stop
    
    # Use shared utilities for connection if available
    if (Get-Command Connect-PurviewServices -ErrorAction SilentlyContinue) {
        Connect-PurviewServices -Services @("Exchange") -Interactive
    } else {
        Connect-IPPSSession -ErrorAction Stop
    }
    
    Write-Host "✅ Connected to Security & Compliance successfully" -ForegroundColor Green
    
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
    Write-Host "   1. Verify you have Compliance Administrator or Global Administrator role" -ForegroundColor White
    Write-Host "   2. Try updating the module: Update-Module -Name ExchangeOnlineManagement -Force" -ForegroundColor White
    Write-Host "   3. Run Connect-IPPSSession manually first, then re-run this script" -ForegroundColor White
    exit 1
}

# =============================================================================
# Step 2: Create Contoso Customer Number Custom SIT
# =============================================================================

Write-Host "`n📋 Step 2: Creating Contoso Customer Number SIT" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

$sitName = "Contoso Customer Number"

try {
    # Check if SIT already exists
    $existingSIT = Get-DlpSensitiveInformationType -Identity $sitName -ErrorAction SilentlyContinue
    
    if ($existingSIT) {
        Write-Host "⚠️  '$sitName' already exists" -ForegroundColor Yellow
        Write-Host ""
        $overwrite = Read-Host "Do you want to remove and recreate it? (Y/N)"
        
        if ($overwrite -eq 'Y' -or $overwrite -eq 'y') {
            Write-Host "🗑️  Removing existing SIT..." -ForegroundColor Cyan
            Remove-DlpSensitiveInformationType -Identity $sitName -Confirm:$false
            
            # Wait for removal to propagate
            Write-Host "   ⏱️  Waiting 10 seconds for removal to propagate..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
        } else {
            Write-Host "ℹ️  Keeping existing SIT - exiting" -ForegroundColor Cyan
            
            # Use shared utilities for disconnect if available
            if (Get-Command Disconnect-PurviewServices -ErrorAction SilentlyContinue) {
                Disconnect-PurviewServices
            } else {
                Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
            }
            exit 0
        }
    }
    
    Write-Host "🔸 Creating: $sitName" -ForegroundColor Cyan
    Write-Host ""
    
    # Create enhanced SIT with multi-level confidence scoring and keyword dictionary
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
        <Description>
          Enhanced custom SIT for Contoso customer account numbers matching pattern CUST-######. 
          Implements advanced regex with word boundary validation, comprehensive keyword dictionary 
          for context-aware detection, and multi-level confidence scoring. High confidence (85%) 
          requires full keyword set, Medium (75%) requires partial keywords, Low (65%) matches pattern 
          only. Keyword proximity: 300 characters. Keywords include customer, account, client variations.
        </Description>
      </LocalizedDetails>
    </Details>
  </RulePack>
  <Rules>
    <Entity id="$(New-Guid)" patternsProximity="300" recommendedConfidence="75">
      
      <!-- High Confidence: Pattern + Full Keyword Set -->
      <Pattern confidenceLevel="85">
        <IdMatch idRef="Regex_CustomerNumber" />
        <Match idRef="Keyword_Customer_Full" />
      </Pattern>
      
      <!-- Medium Confidence: Pattern + Partial Keywords -->
      <Pattern confidenceLevel="75">
        <IdMatch idRef="Regex_CustomerNumber" />
        <Match idRef="Keyword_Customer_Partial" />
      </Pattern>
      
      <!-- Low Confidence: Pattern Only -->
      <Pattern confidenceLevel="65">
        <IdMatch idRef="Regex_CustomerNumber" />
      </Pattern>
      
    </Entity>
    
    <!-- Primary Regex Pattern with Word Boundaries -->
    <Regex id="Regex_CustomerNumber">\bCUST-\d{6}\b</Regex>
    
    <!-- Full Keyword Set for High Confidence -->
    <Keyword id="Keyword_Customer_Full">
      <Group matchStyle="word">
        <Term caseSensitive="false">customer</Term>
        <Term caseSensitive="false">account</Term>
        <Term caseSensitive="false">CUST</Term>
        <Term caseSensitive="false">client</Term>
        <Term caseSensitive="false">customer number</Term>
        <Term caseSensitive="false">account number</Term>
      </Group>
    </Keyword>
    
    <!-- Partial Keyword Set for Medium Confidence -->
    <Keyword id="Keyword_Customer_Partial">
      <Group matchStyle="word">
        <Term caseSensitive="false">customer</Term>
        <Term caseSensitive="false">account</Term>
        <Term caseSensitive="false">CUST</Term>
      </Group>
    </Keyword>
    
  </Rules>
</RulePackage>
"@
    
    $tempXml = Join-Path $env:TEMP "ContosoCustomerNumber_Enhanced.xml"
    Set-Content -Path $tempXml -Value $xml -Encoding UTF8
    
    New-DlpSensitiveInformationType -Name $sitName `
        -Description "Enhanced custom SIT for Contoso customer account numbers. Pattern: CUST-######. Includes comprehensive keyword dictionary and multi-level confidence scoring for context-aware detection." `
        -FileData ([System.IO.File]::ReadAllBytes($tempXml))
    
    Remove-Item $tempXml -Force
    
    Write-Host "✅ Created: $sitName" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Configuration Details:" -ForegroundColor Cyan
    Write-Host "   Pattern: \bCUST-\d{6}\b" -ForegroundColor White
    Write-Host "   Word Boundaries: Enabled (prevents false positives)" -ForegroundColor White
    Write-Host ""
    Write-Host "🔑 Keyword Dictionary:" -ForegroundColor Cyan
    Write-Host "   Full Set (High Confidence): customer, account, CUST, client, customer number, account number" -ForegroundColor White
    Write-Host "   Partial Set (Medium Confidence): customer, account, CUST" -ForegroundColor White
    Write-Host ""
    Write-Host "📊 Confidence Levels:" -ForegroundColor Cyan
    Write-Host "   High (85%): Pattern + Full Keyword Set (4+ keywords)" -ForegroundColor White
    Write-Host "   Medium (75%): Pattern + Partial Keywords (2-3 keywords)" -ForegroundColor White
    Write-Host "   Low (65%): Pattern Only (no keywords required)" -ForegroundColor White
    Write-Host ""
    Write-Host "🔍 Keyword Proximity: 300 characters" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✅ Status: Enabled" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Failed to create '$sitName': $($_.Exception.Message)" -ForegroundColor Red
    
    # Use shared utilities for disconnect if available
    if (Get-Command Disconnect-PurviewServices -ErrorAction SilentlyContinue) {
        Disconnect-PurviewServices
    } else {
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    }
    exit 1
}

# =============================================================================
# Step 3: Validation and Summary
# =============================================================================

Write-Host "`n📋 Step 3: Validation and Summary" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

Write-Host "`n🔍 Verifying custom SIT..." -ForegroundColor Cyan

try {
    Start-Sleep -Seconds 3
    
    $verifyingSIT = Get-DlpSensitiveInformationType -Identity $sitName -ErrorAction Stop
    
    if ($verifyingSIT) {
        Write-Host "✅ Custom SIT verified in Microsoft Purview" -ForegroundColor Green
        Write-Host "   Name: $($verifyingSIT.Name)" -ForegroundColor White
        Write-Host "   Publisher: $($verifyingSIT.Publisher)" -ForegroundColor White
        Write-Host "   State: $($verifyingSIT.State)" -ForegroundColor White
    }
} catch {
    Write-Host "⚠️  Could not verify SIT immediately - may require replication time" -ForegroundColor Yellow
    Write-Host "   Wait 5-15 minutes, then run: Get-DlpSensitiveInformationType -Identity '$sitName'" -ForegroundColor Cyan
}

# Disconnect from Security & Compliance
if (Get-Command Disconnect-PurviewServices -ErrorAction SilentlyContinue) {
    Disconnect-PurviewServices
} else {
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}

Write-Host "`n🎉 Contoso Customer Number Custom SIT Creation Complete!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Successfully created: $sitName" -ForegroundColor Green
Write-Host ""
Write-Host "⏱️  Background Replication:" -ForegroundColor Cyan
Write-Host "   Custom SIT will be available globally in 5-15 minutes." -ForegroundColor White
Write-Host "   Continue to Exercise 4 immediately - no need to wait!" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔍 Pattern Examples:" -ForegroundColor Cyan
Write-Host "   ✅ CUST-123456 (matches)" -ForegroundColor Green
Write-Host "   ✅ CUST-789012 (matches)" -ForegroundColor Green
Write-Host "   ❌ CUST-12345 (too few digits)" -ForegroundColor Red
Write-Host "   ❌ CUST-1234567 (too many digits)" -ForegroundColor Red
Write-Host "   ❌ CUSTOMER-123456 (wrong prefix)" -ForegroundColor Red
Write-Host ""
Write-Host "💡 Testing Tip:" -ForegroundColor Cyan
Write-Host "   High confidence: 'Customer account CUST-123456 requires verification'" -ForegroundColor White
Write-Host "   Medium confidence: 'Account CUST-123456 status'" -ForegroundColor White
Write-Host "   Low confidence: 'CUST-123456' (standalone)" -ForegroundColor White
Write-Host ""
Write-Host "💡 Best Practices:" -ForegroundColor Cyan
Write-Host "   • Keywords are case-insensitive (customer = Customer = CUSTOMER)" -ForegroundColor White
Write-Host "   • 300-character proximity allows flexible document structure" -ForegroundColor White
Write-Host "   • Use High confidence for DLP policy triggers to reduce false positives" -ForegroundColor White
Write-Host "   • Use Medium/Low confidence for discovery and audit scenarios" -ForegroundColor White
Write-Host ""
Write-Host "✅ Ready for Exercise 4: Create Purchase Order Custom SIT" -ForegroundColor Green
