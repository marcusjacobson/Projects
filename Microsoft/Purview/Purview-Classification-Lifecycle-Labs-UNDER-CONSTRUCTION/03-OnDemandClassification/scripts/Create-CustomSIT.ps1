<#
.SYNOPSIS
    Creates a custom Sensitive Information Type (SIT) in Microsoft Purview for Employee ID pattern detection.

.DESCRIPTION
    This script connects to Security & Compliance PowerShell and creates a custom SIT named
    "Contoso Employee ID" that detects the pattern EMP-XXXX-XXXX (where X represents digits).
    
    The custom SIT uses:
    - Regex pattern for Employee ID format validation
    - Keywords for context-based confidence scoring
    - Multiple confidence levels (High: 85%, Medium: 75%, Low: 65%)
    - Primary and supporting elements for enhanced detection accuracy
    
    This custom SIT is designed for Lab 1 (On-Demand Classification) but is reused throughout
    Labs 2-4 for testing custom classification rules, retention policies, and automation workflows.

.PARAMETER RetryCount
    Number of retry attempts if initial connection or creation fails (default: 3).

.EXAMPLE
    .\Create-CustomSIT.ps1
    
    Creates the "Contoso Employee ID" custom SIT with default retry settings.

.EXAMPLE
    .\Create-CustomSIT.ps1 -RetryCount 5
    
    Creates the custom SIT with up to 5 retry attempts if failures occur.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-11
    Last Modified: 2025-11-11
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - ExchangeOnlineManagement module v3.0.0 or later
    - Security & Compliance PowerShell access
    - Microsoft 365 E5 or Compliance add-on license
    - Appropriate permissions: Compliance Administrator or Organization Management role
    
    Custom SIT Configuration:
    - Name: Contoso Employee ID
    - Pattern: EMP-XXXX-XXXX (4 digits, hyphen, 4 digits)
    - Confidence Levels: High (85%), Medium (75%), Low (65%)
    - Keywords: employee, ID, identifier, EMP, personnel, staff
    - Character proximity: 300 characters for keyword matching
    
    Script development orchestrated using GitHub Copilot.

.INTEGRATION POINTS
    - Security & Compliance PowerShell: Custom SIT creation and management
    - Microsoft Purview Information Protection: Classification engine integration
    - SharePoint Online & OneDrive: Content scanning and labeling
    - Content Explorer: Classification result validation
#>
#
# =============================================================================
# Create custom Sensitive Information Type for Employee ID pattern detection
# in Microsoft Purview Information Protection
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [int]$RetryCount = 3
)

# =============================================================================
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔍 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

Write-Host "📋 Validating PowerShell modules..." -ForegroundColor Cyan
try {
    # Check for ExchangeOnlineManagement module
    $moduleName = "ExchangeOnlineManagement"
    $module = Get-Module -ListAvailable -Name $moduleName | Select-Object -First 1
    
    if ($null -eq $module) {
        Write-Host "   ❌ $moduleName module not found" -ForegroundColor Red
        Write-Host "   💡 Install with: Install-Module -Name $moduleName -Scope CurrentUser" -ForegroundColor Yellow
        throw "$moduleName module is required but not installed"
    }
    
    Write-Host "   ✅ $moduleName module found (version $($module.Version))" -ForegroundColor Green
    
    # Import module if not already loaded
    if (-not (Get-Module -Name $moduleName)) {
        Import-Module $moduleName -ErrorAction Stop
        Write-Host "   ✅ $moduleName module imported successfully" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  $moduleName module already loaded" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "   ❌ Module validation failed: $_" -ForegroundColor Red
    throw
}

Write-Host ""

# =============================================================================
# Step 2: Connect to Security & Compliance PowerShell
# =============================================================================

Write-Host "🔐 Step 2: Connecting to Security & Compliance PowerShell" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

$attempt = 0
$connected = $false

while (-not $connected -and $attempt -lt $RetryCount) {
    $attempt++
    Write-Host "📋 Connection attempt $attempt of $RetryCount..." -ForegroundColor Cyan
    
    try {
        # Test if already connected
        $existingConnection = Get-ConnectionInformation -ErrorAction SilentlyContinue | Where-Object { $_.ConnectionUri -like "*protection.outlook.com*" }
        
        if ($existingConnection) {
            Write-Host "   ℹ️  Already connected to Security & Compliance PowerShell" -ForegroundColor Cyan
            Write-Host "   📧 Connected as: $($existingConnection.UserPrincipalName)" -ForegroundColor Cyan
            $connected = $true
        } else {
            # Connect using modern authentication
            Write-Host "   🔑 Initiating connection (browser authentication will open)..." -ForegroundColor Cyan
            Connect-IPPSSession -WarningAction SilentlyContinue -ErrorAction Stop
            
            # Verify connection
            $newConnection = Get-ConnectionInformation -ErrorAction Stop | Where-Object { $_.ConnectionUri -like "*protection.outlook.com*" }
            if ($newConnection) {
                Write-Host "   ✅ Connected successfully to Security & Compliance PowerShell" -ForegroundColor Green
                Write-Host "   📧 Connected as: $($newConnection.UserPrincipalName)" -ForegroundColor Cyan
                $connected = $true
            }
        }
        
    } catch {
        Write-Host "   ⚠️  Connection attempt $attempt failed: $_" -ForegroundColor Yellow
        if ($attempt -lt $RetryCount) {
            Write-Host "   ⏱️  Waiting 5 seconds before retry..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        } else {
            Write-Host "   ❌ All connection attempts failed" -ForegroundColor Red
            throw "Unable to connect to Security & Compliance PowerShell after $RetryCount attempts"
        }
    }
}

Write-Host ""

# =============================================================================
# Step 3: Check for Existing Custom SIT
# =============================================================================

Write-Host "🔍 Step 3: Checking for Existing Custom SIT" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

$sitName = "Contoso Employee ID"
$existingSIT = $null

try {
    Write-Host "📋 Searching for existing SIT: $sitName..." -ForegroundColor Cyan
    $existingSIT = Get-DlpSensitiveInformationType -Identity $sitName -ErrorAction SilentlyContinue
    
    if ($existingSIT) {
        Write-Host "   ⚠️  Custom SIT already exists: $sitName" -ForegroundColor Yellow
        Write-Host "   📊 SIT ID: $($existingSIT.Id)" -ForegroundColor Cyan
        Write-Host "   📋 Description: $($existingSIT.Description)" -ForegroundColor Cyan
        Write-Host ""
        
        $response = Read-Host "   ❓ Do you want to remove and recreate the SIT? (Y/N)"
        if ($response -eq 'Y' -or $response -eq 'y') {
            Write-Host "   🗑️  Removing existing SIT..." -ForegroundColor Yellow
            Remove-DlpSensitiveInformationType -Identity $existingSIT.Id -Confirm:$false -ErrorAction Stop
            Write-Host "   ✅ Existing SIT removed successfully" -ForegroundColor Green
            $existingSIT = $null
        } else {
            Write-Host "   ℹ️  Keeping existing SIT, script will exit" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "✅ Script execution completed (no changes made)" -ForegroundColor Green
            exit 0
        }
    } else {
        Write-Host "   ✅ No existing SIT found with name: $sitName" -ForegroundColor Green
        Write-Host "   📋 Proceeding with SIT creation..." -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "   ⚠️  Error checking for existing SIT: $_" -ForegroundColor Yellow
    Write-Host "   📋 Proceeding with SIT creation..." -ForegroundColor Cyan
}

Write-Host ""

# =============================================================================
# Step 4: Create Custom SIT Definition
# =============================================================================

Write-Host "📋 Step 4: Creating Custom SIT Definition" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

Write-Host "📋 Defining Employee ID pattern and keywords..." -ForegroundColor Cyan

# Define regex pattern for Employee ID format: EMP-XXXX-XXXX
$regexPattern = '\bEMP-\d{4}-\d{4}\b'

# Define keywords for context-based detection
$keywords = @(
    "employee",
    "employee ID",
    "employee identifier",
    "EMP",
    "personnel",
    "staff",
    "worker",
    "team member"
)

# Define SIT description
$sitDescription = "Detects Contoso Corporation Employee ID format: EMP-XXXX-XXXX (where X represents digits). Used for classification, retention policies, and DLP rules."

Write-Host "   ✅ Regex pattern: $regexPattern" -ForegroundColor Green
Write-Host "   ✅ Keywords: $($keywords.Count) terms defined" -ForegroundColor Green
Write-Host "   ✅ Description: $sitDescription" -ForegroundColor Green

Write-Host ""

# =============================================================================
# Step 5: Create Custom SIT in Microsoft Purview
# =============================================================================

Write-Host "📋 Step 5: Creating Custom SIT in Microsoft Purview" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

try {
    Write-Host "📋 Creating custom SIT: $sitName..." -ForegroundColor Cyan
    
    # Create primary pattern element
    $primaryElement = New-DlpSensitiveInformationTypeRulePackage `
        -Name $sitName `
        -Description $sitDescription `
        -Pattern $regexPattern `
        -Confidence 85 `
        -Keywords $keywords `
        -CharacterProximity 300 `
        -ErrorAction Stop
    
    Write-Host "   ✅ Primary pattern element created (Confidence: 85%)" -ForegroundColor Green
    
    # Create medium confidence pattern (without all keywords)
    $mediumConfidenceKeywords = @("employee", "EMP", "personnel")
    $mediumElement = New-DlpSensitiveInformationTypeRulePackage `
        -Name "$sitName (Medium Confidence)" `
        -Description "$sitDescription Medium confidence level." `
        -Pattern $regexPattern `
        -Confidence 75 `
        -Keywords $mediumConfidenceKeywords `
        -CharacterProximity 300 `
        -ErrorAction Stop
    
    Write-Host "   ✅ Medium confidence element created (Confidence: 75%)" -ForegroundColor Green
    
    # Create low confidence pattern (pattern only, no keywords)
    $lowElement = New-DlpSensitiveInformationTypeRulePackage `
        -Name "$sitName (Low Confidence)" `
        -Description "$sitDescription Low confidence level (pattern only)." `
        -Pattern $regexPattern `
        -Confidence 65 `
        -ErrorAction Stop
    
    Write-Host "   ✅ Low confidence element created (Confidence: 65%)" -ForegroundColor Green
    Write-Host ""
    
    # Combine all elements into final SIT
    Write-Host "📋 Finalizing custom SIT with multiple confidence levels..." -ForegroundColor Cyan
    
    $finalSIT = New-DlpSensitiveInformationType `
        -Name $sitName `
        -Description $sitDescription `
        -RulePackage @($primaryElement, $mediumElement, $lowElement) `
        -ErrorAction Stop
    
    Write-Host "   ✅ Custom SIT created successfully!" -ForegroundColor Green
    Write-Host "   📊 SIT Name: $sitName" -ForegroundColor Cyan
    Write-Host "   📊 SIT ID: $($finalSIT.Id)" -ForegroundColor Cyan
    Write-Host "   📊 Confidence Levels: High (85%), Medium (75%), Low (65%)" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ Failed to create custom SIT: $_" -ForegroundColor Red
    Write-Host "   💡 Tip: Ensure you have Compliance Administrator role" -ForegroundColor Yellow
    throw
}

Write-Host ""

# =============================================================================
# Step 6: Verify Custom SIT Creation
# =============================================================================

Write-Host "🔍 Step 6: Verifying Custom SIT Creation" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

try {
    Write-Host "📋 Retrieving newly created SIT from Purview..." -ForegroundColor Cyan
    Start-Sleep -Seconds 3  # Allow time for replication
    
    $verifiedSIT = Get-DlpSensitiveInformationType -Identity $sitName -ErrorAction Stop
    
    if ($verifiedSIT) {
        Write-Host "   ✅ Custom SIT verified successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "   📊 SIT Details:" -ForegroundColor Cyan
        Write-Host "      Name: $($verifiedSIT.Name)" -ForegroundColor White
        Write-Host "      ID: $($verifiedSIT.Id)" -ForegroundColor White
        Write-Host "      Publisher: $($verifiedSIT.Publisher)" -ForegroundColor White
        Write-Host "      Description: $($verifiedSIT.Description)" -ForegroundColor White
        Write-Host "      Confidence Levels: $($verifiedSIT.ConfidenceLevels -join ', ')" -ForegroundColor White
    } else {
        Write-Host "   ⚠️  SIT created but verification failed" -ForegroundColor Yellow
        Write-Host "   💡 Tip: SIT may take several minutes to replicate globally" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ⚠️  Verification query failed: $_" -ForegroundColor Yellow
    Write-Host "   ℹ️  SIT was created but may need time to replicate (5-15 minutes)" -ForegroundColor Cyan
}

Write-Host ""

# =============================================================================
# Step 7: Display Summary and Next Steps
# =============================================================================

Write-Host "📋 Step 7: Summary and Next Steps" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "✅ Custom SIT creation completed successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Custom SIT Configuration:" -ForegroundColor Cyan
Write-Host "   Name: $sitName" -ForegroundColor White
Write-Host "   Pattern: EMP-####-#### (where # = digit)" -ForegroundColor White
Write-Host "   High Confidence (85%): Pattern + full keyword set (8 terms)" -ForegroundColor White
Write-Host "   Medium Confidence (75%): Pattern + partial keywords (3 terms)" -ForegroundColor White
Write-Host "   Low Confidence (65%): Pattern only (no keywords required)" -ForegroundColor White
Write-Host "   Character Proximity: 300 characters for keyword matching" -ForegroundColor White
Write-Host ""

Write-Host "🔍 Pattern Examples (will be detected):" -ForegroundColor Cyan
Write-Host "   ✅ EMP-1234-5678" -ForegroundColor Green
Write-Host "   ✅ EMP-9876-5432" -ForegroundColor Green
Write-Host "   ✅ employee EMP-2345-6789 assigned" -ForegroundColor Green
Write-Host ""

Write-Host "❌ Invalid Patterns (will NOT be detected):" -ForegroundColor Cyan
Write-Host "   ❌ EMP-123-456 (wrong digit count)" -ForegroundColor Red
Write-Host "   ❌ EMP12345678 (missing hyphens)" -ForegroundColor Red
Write-Host "   ❌ EMPLOYEE-1234-5678 (wrong prefix)" -ForegroundColor Red
Write-Host ""

Write-Host "⏱️  Replication Timeline:" -ForegroundColor Yellow
Write-Host "   - Microsoft 365 Admin Center: Immediate availability" -ForegroundColor White
Write-Host "   - Purview Compliance Portal: 2-5 minutes" -ForegroundColor White
Write-Host "   - SharePoint/OneDrive scanning: 5-15 minutes" -ForegroundColor White
Write-Host "   - Content Explorer: 15-30 minutes for initial classification results" -ForegroundColor White
Write-Host ""

Write-Host "⏭️  Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Wait 5-15 minutes for global replication of custom SIT" -ForegroundColor White
Write-Host "   2. Return to Lab 1 README.md Step 3 to run On-Demand Classification" -ForegroundColor White
Write-Host "   3. Verify classification results in Content Explorer" -ForegroundColor White
Write-Host "   4. Monitor activity in Activity Explorer (Security & Compliance)" -ForegroundColor White
Write-Host ""

Write-Host "💡 Production Tips:" -ForegroundColor Yellow
Write-Host "   - Custom SITs can be used in DLP policies, retention labels, and trainable classifiers" -ForegroundColor White
Write-Host "   - Test SITs in non-production environment before deploying to production" -ForegroundColor White
Write-Host "   - Use multiple confidence levels to reduce false positives while maximizing detection" -ForegroundColor White
Write-Host "   - Export custom SIT definitions for version control and disaster recovery" -ForegroundColor White
Write-Host ""

Write-Host "📚 Additional Resources:" -ForegroundColor Cyan
Write-Host "   - Custom SIT Documentation: https://learn.microsoft.com/purview/sit-create-custom" -ForegroundColor White
Write-Host "   - Regex Pattern Testing: https://regex101.com/" -ForegroundColor White
Write-Host "   - Confidence Level Guidance: https://learn.microsoft.com/purview/sit-confidence-levels" -ForegroundColor White
Write-Host ""

Write-Host "✅ Script execution completed successfully" -ForegroundColor Green
