<#
.SYNOPSIS
    Creates the "Contoso Project Identifier" custom Sensitive Information Type in Microsoft Purview.

.DESCRIPTION
    This script creates a custom SIT for detecting organization-specific project identifiers
    following the pattern PROJ-YYYY-#### (e.g., PROJ-2025-1001).
    
    The custom SIT includes:
    - Regex pattern matching: \bPROJ-\d{4}-\d{4}\b
    - Context keywords: project, identifier, PROJ, development, initiative, engineering
    - Three confidence levels:
      * High (85%): Pattern + multiple keywords within 300 characters
      * Medium (75%): Pattern + single keyword within 300 characters
      * Low (65%): Pattern match only
    
    This SIT is designed for Lab 2 (Custom SITs) to demonstrate regex-based pattern
    detection with keyword-enhanced confidence scoring.

.PARAMETER Confirm
    If specified, prompts for confirmation before creating the custom SIT.

.EXAMPLE
    .\Create-ProjectIDSIT.ps1
    
    Creates the "Contoso Project Identifier" custom SIT with default settings.

.EXAMPLE
    .\Create-ProjectIDSIT.ps1 -Confirm
    
    Creates the custom SIT after confirming the operation with the user.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-11
    Last Modified: 2025-11-11
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - ExchangeOnlineManagement module v3.4.0+
    - Microsoft Purview E3/E5 or Information Protection P1/P2 license
    - Compliance Administrator or Information Protection Administrator role
    - Security & Compliance PowerShell connectivity
    
    Pattern Design:
    - Format: PROJ-YYYY-#### (4-digit year, 4-digit sequence)
    - Word boundaries (\b) prevent partial matches
    - Case-insensitive matching for flexibility
    - Minimum 3-digit requirement prevents false positives
    
    Confidence Levels:
    - High (85%): Multiple keywords provide strong context
    - Medium (75%): Single keyword indicates project context
    - Low (65%): Pattern-only detection for basic identification
    
    Script development orchestrated using GitHub Copilot.

.SIT CONFIGURATION
    - Name: Contoso Project Identifier
    - Pattern: PROJ-YYYY-#### (e.g., PROJ-2025-1001, PROJ-2024-5000)
    - Keywords: project, identifier, PROJ, development, initiative, engineering, program
    - Character Proximity: 300 characters (for keyword matching)
    - Instance Count: 1 minimum (single occurrence detection)
#>
#
# =============================================================================
# Create "Contoso Project Identifier" custom SIT for Microsoft Purview
# =============================================================================

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $false)]
    [switch]$Confirm
)

# =============================================================================
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔍 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

try {
    # Check for ExchangeOnlineManagement module
    Write-Host "📋 Checking for ExchangeOnlineManagement module..." -ForegroundColor Cyan
    
    $moduleCheck = Get-Module -ListAvailable -Name ExchangeOnlineManagement | 
        Select-Object -First 1
    
    if (-not $moduleCheck) {
        Write-Host "   ❌ ExchangeOnlineManagement module not found" -ForegroundColor Red
        Write-Host "   💡 Install with: Install-Module -Name ExchangeOnlineManagement -Force" -ForegroundColor Yellow
        throw "Required module not found"
    }
    
    $moduleVersion = $moduleCheck.Version
    Write-Host "   ✅ ExchangeOnlineManagement v$moduleVersion detected" -ForegroundColor Green
    
    # Check if module version meets minimum requirement (3.4.0)
    $minVersion = [Version]"3.4.0"
    if ($moduleVersion -lt $minVersion) {
        Write-Host "   ⚠️  Module version $moduleVersion is below recommended v3.4.0" -ForegroundColor Yellow
        Write-Host "   💡 Update with: Update-Module -Name ExchangeOnlineManagement -Force" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "   ✅ Environment validation successful" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Environment validation failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# =============================================================================
# Step 2: Connect to Security & Compliance PowerShell
# =============================================================================

Write-Host "🔐 Step 2: Security & Compliance PowerShell Connection" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green

try {
    # Check for existing connection
    Write-Host "📋 Checking for existing Security & Compliance PowerShell session..." -ForegroundColor Cyan
    
    $existingConnection = $null
    try {
        $existingConnection = Get-ConnectionInformation -ErrorAction SilentlyContinue | 
            Where-Object { $_.ConnectionUri -like "*protection.outlook.com*" -and $_.State -eq "Connected" } |
            Select-Object -First 1
    } catch {
        # Silently continue if cmdlet fails
    }
    
    if ($existingConnection) {
        Write-Host "   ✅ Existing connection found:" -ForegroundColor Green
        Write-Host "      User: $($existingConnection.UserPrincipalName)" -ForegroundColor Cyan
        Write-Host "      Organization: $($existingConnection.Organization)" -ForegroundColor Cyan
        Write-Host "      Connection: $($existingConnection.ConnectionUri)" -ForegroundColor Cyan
        Write-Host ""
        
        $reuse = Read-Host "   Reuse existing connection? (Y/N)"
        if ($reuse -ne 'Y' -and $reuse -ne 'y') {
            Write-Host "   📋 Disconnecting existing session..." -ForegroundColor Cyan
            Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
    
    # Connect if no valid connection exists
    if (-not $existingConnection -or ($reuse -ne 'Y' -and $reuse -ne 'y')) {
        Write-Host "   📋 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
        Write-Host "   ℹ️  You will be prompted to sign in with your Microsoft 365 credentials" -ForegroundColor Yellow
        Write-Host ""
        
        Connect-IPPSSession -ErrorAction Stop
        
        Write-Host ""
        Write-Host "   ✅ Successfully connected to Security & Compliance PowerShell" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Failed to connect to Security & Compliance PowerShell: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Troubleshooting Tips:" -ForegroundColor Yellow
    Write-Host "      1. Verify you have Compliance Administrator or Information Protection Admin role" -ForegroundColor White
    Write-Host "      2. Check your internet connectivity" -ForegroundColor White
    Write-Host "      3. Ensure Multi-Factor Authentication is configured correctly" -ForegroundColor White
    Write-Host "      4. Try updating ExchangeOnlineManagement module: Update-Module ExchangeOnlineManagement" -ForegroundColor White
    exit 1
}

Write-Host ""

# =============================================================================
# Step 3: Check for Existing Custom SIT
# =============================================================================

Write-Host "🔍 Step 3: Check for Existing Custom SIT" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

$sitName = "Contoso Project Identifier"

try {
    Write-Host "📋 Checking if '$sitName' already exists..." -ForegroundColor Cyan
    
    # Query for existing custom SIT
    $existingSIT = Get-DlpSensitiveInformationType -Identity $sitName -ErrorAction SilentlyContinue
    
    if ($existingSIT) {
        Write-Host "   ⚠️  Custom SIT '$sitName' already exists" -ForegroundColor Yellow
        Write-Host "      Created: $($existingSIT.WhenCreated)" -ForegroundColor Cyan
        Write-Host "      Modified: $($existingSIT.WhenChanged)" -ForegroundColor Cyan
        Write-Host "      Publisher: $($existingSIT.Publisher)" -ForegroundColor Cyan
        Write-Host ""
        
        if ($PSCmdlet.ShouldProcess($sitName, "Remove existing custom SIT")) {
            $overwrite = Read-Host "   Overwrite existing SIT? This will remove and recreate it. (Y/N)"
            
            if ($overwrite -eq 'Y' -or $overwrite -eq 'y') {
                Write-Host "   📋 Removing existing custom SIT '$sitName'..." -ForegroundColor Cyan
                Remove-DlpSensitiveInformationType -Identity $sitName -Confirm:$false -ErrorAction Stop
                Write-Host "   ✅ Existing SIT removed successfully" -ForegroundColor Green
                
                # Wait for replication
                Write-Host "   ⏳ Waiting 5 seconds for replication..." -ForegroundColor Cyan
                Start-Sleep -Seconds 5
            } else {
                Write-Host "   ℹ️  Operation cancelled by user" -ForegroundColor Yellow
                exit 0
            }
        }
    } else {
        Write-Host "   ✅ No existing SIT found - ready to create new custom SIT" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️  Unable to query existing SIT (this may be expected): $_" -ForegroundColor Yellow
}

Write-Host ""

# =============================================================================
# Step 4: Create Custom SIT Definition
# =============================================================================

Write-Host "📋 Step 4: Creating Custom SIT Definition" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

try {
    Write-Host "📋 Configuring custom SIT parameters..." -ForegroundColor Cyan
    Write-Host ""
    
    # Define regex pattern for Project ID: PROJ-YYYY-####
    $regexPattern = '\bPROJ-\d{4}-\d{4}\b'
    
    # Define keywords for context-aware detection
    $keywords = @(
        "project",
        "identifier",
        "PROJ",
        "development",
        "initiative",
        "engineering",
        "program"
    )
    
    Write-Host "   Pattern Definition:" -ForegroundColor Cyan
    Write-Host "   • Regex: $regexPattern" -ForegroundColor White
    Write-Host "   • Format: PROJ-YYYY-#### (4-digit year, 4-digit sequence)" -ForegroundColor White
    Write-Host "   • Example Matches: PROJ-2025-1001, PROJ-2024-5000, PROJ-2026-0100" -ForegroundColor White
    Write-Host ""
    
    Write-Host "   Keyword Context:" -ForegroundColor Cyan
    Write-Host "   • Keywords: $($keywords -join ', ')" -ForegroundColor White
    Write-Host "   • Proximity: 300 characters" -ForegroundColor White
    Write-Host "   • Purpose: Enhance confidence when project context is present" -ForegroundColor White
    Write-Host ""
    
    Write-Host "   Confidence Levels:" -ForegroundColor Cyan
    Write-Host "   • High (85%): Pattern + multiple keywords within proximity" -ForegroundColor White
    Write-Host "   • Medium (75%): Pattern + single keyword within proximity" -ForegroundColor White
    Write-Host "   • Low (65%): Pattern match only (no keyword required)" -ForegroundColor White
    Write-Host ""
    
    # Create the custom SIT using New-DlpSensitiveInformationType
    Write-Host "📋 Creating custom SIT '$sitName'..." -ForegroundColor Cyan
    
    # Build the classification rule XML for the custom SIT
    $rulePackageXml = @"
<RulePackage xmlns="http://schemas.microsoft.com/office/2018/01/dlp">
  <RulePack id="$(New-Guid)">
    <Version major="1" minor="0" build="0" revision="0"/>
    <Publisher id="$(New-Guid)"/>
    <Details defaultLangCode="en-us">
      <LocalizedDetails langcode="en-us">
        <PublisherName>Contoso Corporation</PublisherName>
        <Name>Contoso Project Identifier SIT</Name>
        <Description>Custom SIT for detecting Contoso project identifiers in format PROJ-YYYY-####</Description>
      </LocalizedDetails>
    </Details>
  </RulePack>
  <Rules>
    <Entity id="$(New-Guid)" patternsProximity="300" recommendedConfidence="75">
      <Pattern confidenceLevel="85">
        <IdMatch idRef="Regex_ProjectID"/>
        <Any minMatches="2">
          <Match idRef="Keyword_ProjectID"/>
        </Any>
      </Pattern>
      <Pattern confidenceLevel="75">
        <IdMatch idRef="Regex_ProjectID"/>
        <Match idRef="Keyword_ProjectID"/>
      </Pattern>
      <Pattern confidenceLevel="65">
        <IdMatch idRef="Regex_ProjectID"/>
      </Pattern>
      <Resource idRef="Regex_ProjectID">
        <Regex id="Regex_ProjectID">$regexPattern</Regex>
      </Resource>
      <Resource idRef="Keyword_ProjectID">
        <Keywords>
          $($keywords | ForEach-Object { "<Keyword>$_</Keyword>" } | Out-String)
        </Keywords>
      </Resource>
    </Entity>
  </Rules>
</RulePackage>
"@
    
    # Create the custom SIT
    New-DlpSensitiveInformationType `
        -Name $sitName `
        -Description "Custom SIT for detecting Contoso project identifiers (PROJ-YYYY-####). Includes context keywords for confidence scoring." `
        -FileData ([System.Text.Encoding]::UTF8.GetBytes($rulePackageXml)) `
        -ErrorAction Stop | Out-Null
    
    Write-Host "   ✅ Custom SIT '$sitName' created successfully" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ Failed to create custom SIT: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Troubleshooting Tips:" -ForegroundColor Yellow
    Write-Host "      1. Verify you have appropriate permissions (Compliance Administrator role)" -ForegroundColor White
    Write-Host "      2. Check if the SIT name is already in use" -ForegroundColor White
    Write-Host "      3. Ensure regex pattern is valid: $regexPattern" -ForegroundColor White
    Write-Host "      4. Try again after a few minutes (replication delay)" -ForegroundColor White
    exit 1
}

Write-Host ""

# =============================================================================
# Step 5: Verify Custom SIT Creation
# =============================================================================

Write-Host "✅ Step 5: Verify Custom SIT Creation" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

try {
    Write-Host "📋 Verifying custom SIT creation..." -ForegroundColor Cyan
    Write-Host "   ⏳ Waiting 3 seconds for replication..." -ForegroundColor Cyan
    Start-Sleep -Seconds 3
    
    $verifiedSIT = Get-DlpSensitiveInformationType -Identity $sitName -ErrorAction Stop
    
    if ($verifiedSIT) {
        Write-Host ""
        Write-Host "   ✅ Custom SIT verified successfully" -ForegroundColor Green
        Write-Host ""
        Write-Host "   📊 SIT Details:" -ForegroundColor Cyan
        Write-Host "      Name: $($verifiedSIT.Name)" -ForegroundColor White
        Write-Host "      Publisher: $($verifiedSIT.Publisher)" -ForegroundColor White
        Write-Host "      Created: $($verifiedSIT.WhenCreated)" -ForegroundColor White
        Write-Host "      Description: $($verifiedSIT.Description)" -ForegroundColor White
        Write-Host "      State: $($verifiedSIT.State)" -ForegroundColor White
    }
} catch {
    Write-Host "   ⚠️  Unable to verify SIT immediately (replication delay expected)" -ForegroundColor Yellow
    Write-Host "      The SIT may have been created successfully but isn't queryable yet" -ForegroundColor Yellow
    Write-Host "      Wait 5-10 minutes and verify in Purview Compliance Portal" -ForegroundColor Yellow
}

Write-Host ""

# =============================================================================
# Step 6: Summary and Next Steps
# =============================================================================

Write-Host "📋 Step 6: Summary and Next Steps" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ Custom SIT creation completed successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Created SIT Configuration:" -ForegroundColor Cyan
Write-Host "   • Name: $sitName" -ForegroundColor White
Write-Host "   • Pattern: $regexPattern" -ForegroundColor White
Write-Host "   • Format: PROJ-YYYY-#### (e.g., PROJ-2025-1001)" -ForegroundColor White
Write-Host "   • Keywords: $($keywords.Count) context terms" -ForegroundColor White
Write-Host "   • Confidence Levels: High (85%), Medium (75%), Low (65%)" -ForegroundColor White
Write-Host ""

Write-Host "⏭️  Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Wait 5-10 minutes for full replication across Microsoft 365" -ForegroundColor White
Write-Host ""
Write-Host "   2. Verify SIT in Purview Compliance Portal:" -ForegroundColor White
Write-Host "      - Navigate to https://compliance.microsoft.com" -ForegroundColor White
Write-Host "      - Go to Data classification > Classifiers" -ForegroundColor White
Write-Host "      - Select 'Sensitive info types' tab" -ForegroundColor White
Write-Host "      - Search for 'Contoso Project Identifier'" -ForegroundColor White
Write-Host ""
Write-Host "   3. Create remaining custom SITs:" -ForegroundColor White
Write-Host "      - Run .\Create-CustomerNumberSIT.ps1" -ForegroundColor White
Write-Host "      - Run .\Create-PurchaseOrderSIT.ps1" -ForegroundColor White
Write-Host ""
Write-Host "   4. Test custom SIT detection:" -ForegroundColor White
Write-Host "      - Upload Lab 2 test files to SharePoint" -ForegroundColor White
Write-Host "      - Run On-Demand Classification scan" -ForegroundColor White
Write-Host "      - Validate detection in Content Explorer" -ForegroundColor White
Write-Host ""
Write-Host "   5. Run validation script:" -ForegroundColor White
Write-Host "      - .\Validate-CustomSITs.ps1 -DetailedReport" -ForegroundColor White
Write-Host ""

Write-Host "💡 Production Tips:" -ForegroundColor Yellow
Write-Host "   - Test SIT accuracy with small file set before production deployment" -ForegroundColor White
Write-Host "   - Monitor false positive rate in Activity Explorer" -ForegroundColor White
Write-Host "   - Adjust confidence levels based on real-world results" -ForegroundColor White
Write-Host "   - Document SIT usage in DLP policies for audit purposes" -ForegroundColor White
Write-Host ""

Write-Host "✅ Script execution completed successfully" -ForegroundColor Green
