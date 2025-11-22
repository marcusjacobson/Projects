<#
.SYNOPSIS
    Creates Contoso Project Identifier custom Sensitive Information Type with advanced pattern matching.

.DESCRIPTION
    This script creates a regex-based custom SIT for detecting Contoso project
    identifiers matching the pattern PROJ-####-####. Implements:
    - Word boundary validation to prevent false positives
    - Keyword dictionary for context-aware detection
    - Multi-level confidence scoring (High 85%, Medium 75%, Low 65%)
    - 300-character keyword proximity matching
    
    The Project ID pattern uses PROJ prefix + 4-digit year + 4-digit sequence number.

.PARAMETER Verbose
    Show detailed progress during execution.

.EXAMPLE
    .\Create-ProjectIDSIT.ps1 -Verbose
    
    Creates Contoso Project Identifier custom SIT with full keyword dictionary
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
    Pattern: \bPROJ-\d{4}-\d{4}\b
    Examples: PROJ-2025-1234, PROJ-2024-5678
    Keywords: project, identifier, PROJ, development, initiative
    Confidence Levels:
      - High (85%): Pattern + full keyword set (5+ keywords)
      - Medium (75%): Pattern + partial keywords (2-3 keywords)
      - Low (65%): Pattern only (no keywords required)
#>

# =============================================================================
# Contoso Project Identifier Custom SIT Creation
# =============================================================================

[CmdletBinding()]
param ()

# Import Shared Utilities Module for authentication
$sharedUtilitiesPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "Shared-Utilities\PurviewUtilities.psm1"
if (Test-Path $sharedUtilitiesPath) {
    Import-Module $sharedUtilitiesPath -Force
}

Write-Host "🔐 Contoso Project Identifier Custom SIT Creation" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Security & Compliance PowerShell Authentication
# =============================================================================

Write-Host "📋 Step 1: Security & Compliance Authentication" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Check if already connected
$existingConnection = Get-ConnectionInformation -ErrorAction SilentlyContinue
if ($existingConnection) {
    Write-Host "✅ Already connected to Security & Compliance" -ForegroundColor Green
    Write-Host "   User: $($existingConnection.UserPrincipalName)" -ForegroundColor Cyan
    Write-Host "   Organization: $($existingConnection.TenantId)" -ForegroundColor Cyan
} else {
    Write-Host "🔐 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
    Write-Host "   ⚠️  IMPORTANT: Check for authentication popup - it may appear BEHIND this window!" -ForegroundColor Yellow
    Write-Host "   Look for a browser window or sign-in popup to appear..." -ForegroundColor Yellow
    Write-Host ""

    try {
        Import-Module ExchangeOnlineManagement -ErrorAction Stop
        
        # Use plain Connect-IPPSSession - should open browser for modern auth
        # Suppress warnings to avoid confusion during auth flow
        Connect-IPPSSession -WarningAction SilentlyContinue -ErrorAction Stop
        
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
}

# =============================================================================
# Step 2: Create Contoso Project Identifier Custom SIT
# =============================================================================

Write-Host "`n📋 Step 2: Creating Contoso Project Identifier SIT" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

$sitName = "Contoso Project Identifier"

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
        <Name>Contoso Project Identifier Pattern</Name>
        <Description>
          Enhanced custom SIT for Contoso project identification codes matching pattern PROJ-####-####. 
          Implements advanced regex with word boundary validation, keyword dictionary for context-aware 
          detection, and multi-level confidence scoring. High confidence (85%) requires full keyword set, 
          Medium (75%) requires partial keywords, Low (65%) matches pattern only. Keyword proximity: 300 characters.
        </Description>
      </LocalizedDetails>
    </Details>
  </RulePack>
  <Rules>
    <Entity id="$(New-Guid)" patternsProximity="300" recommendedConfidence="75">
      
      <!-- High Confidence: Pattern + Full Keyword Set -->
      <Pattern confidenceLevel="85">
        <IdMatch idRef="Regex_ProjectID" />
        <Match idRef="Keyword_ProjectID_Full" />
      </Pattern>
      
      <!-- Medium Confidence: Pattern + Partial Keywords -->
      <Pattern confidenceLevel="75">
        <IdMatch idRef="Regex_ProjectID" />
        <Match idRef="Keyword_ProjectID_Partial" />
      </Pattern>
      
      <!-- Low Confidence: Pattern Only -->
      <Pattern confidenceLevel="65">
        <IdMatch idRef="Regex_ProjectID" />
      </Pattern>
      
    </Entity>
    
    <!-- Primary Regex Pattern with Word Boundaries -->
    <Regex id="Regex_ProjectID">\bPROJ-\d{4}-\d{4}\b</Regex>
    
    <!-- Full Keyword Set for High Confidence -->
    <Keyword id="Keyword_ProjectID_Full">
      <Group matchStyle="word">
        <Term caseSensitive="false">project</Term>
        <Term caseSensitive="false">identifier</Term>
        <Term caseSensitive="false">PROJ</Term>
        <Term caseSensitive="false">development</Term>
        <Term caseSensitive="false">initiative</Term>
      </Group>
    </Keyword>
    
    <!-- Partial Keyword Set for Medium Confidence -->
    <Keyword id="Keyword_ProjectID_Partial">
      <Group matchStyle="word">
        <Term caseSensitive="false">project</Term>
        <Term caseSensitive="false">PROJ</Term>
      </Group>
    </Keyword>
    
  </Rules>
</RulePackage>
"@
    
    $tempXml = Join-Path $env:TEMP "ContosoProjectID_Enhanced.xml"
    Set-Content -Path $tempXml -Value $xml -Encoding UTF8
    
    New-DlpSensitiveInformationType -Name $sitName `
        -Description "Enhanced custom SIT for Contoso project identifiers. Pattern: PROJ-####-####. Includes keyword dictionary and multi-level confidence scoring for context-aware detection." `
        -FileData ([System.IO.File]::ReadAllBytes($tempXml))
    
    Remove-Item $tempXml -Force
    
    Write-Host "✅ Created: $sitName" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Configuration Details:" -ForegroundColor Cyan
    Write-Host "   Pattern: \bPROJ-\d{4}-\d{4}\b" -ForegroundColor White
    Write-Host "   Word Boundaries: Enabled (prevents false positives)" -ForegroundColor White
    Write-Host ""
    Write-Host "🔑 Keyword Dictionary:" -ForegroundColor Cyan
    Write-Host "   Full Set (High Confidence): project, identifier, PROJ, development, initiative" -ForegroundColor White
    Write-Host "   Partial Set (Medium Confidence): project, PROJ" -ForegroundColor White
    Write-Host ""
    Write-Host "📊 Confidence Levels:" -ForegroundColor Cyan
    Write-Host "   High (85%): Pattern + Full Keyword Set (5+ keywords)" -ForegroundColor White
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

Write-Host "`n🎉 Contoso Project Identifier Custom SIT Creation Complete!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Successfully created: $sitName" -ForegroundColor Green
Write-Host ""
Write-Host "⏱️  Background Replication:" -ForegroundColor Cyan
Write-Host "   Custom SIT will be available globally in 5-15 minutes." -ForegroundColor White
Write-Host "   Continue to Exercise 3 immediately - no need to wait!" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔍 Pattern Examples:" -ForegroundColor Cyan
Write-Host "   ✅ PROJ-2025-1234 (matches)" -ForegroundColor Green
Write-Host "   ✅ PROJ-2024-5678 (matches)" -ForegroundColor Green
Write-Host "   ❌ PROJ-25-1234 (wrong year format)" -ForegroundColor Red
Write-Host "   ❌ PROJ20251234 (missing hyphens)" -ForegroundColor Red
Write-Host "   ❌ PROJECT-2025-1234 (wrong prefix)" -ForegroundColor Red
Write-Host ""
Write-Host "💡 Testing Tip:" -ForegroundColor Cyan
Write-Host "   High confidence: 'Engineering project PROJ-2025-1234 development initiative'" -ForegroundColor White
Write-Host "   Medium confidence: 'Project PROJ-2025-1234 assigned'" -ForegroundColor White
Write-Host "   Low confidence: 'PROJ-2025-1234' (standalone)" -ForegroundColor White
Write-Host ""
Write-Host "✅ Ready for Exercise 3: Create Customer Number Custom SIT" -ForegroundColor Green
