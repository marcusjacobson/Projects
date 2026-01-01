<#
.SYNOPSIS
    Deploys the Global Sensitivity Label Policy to publish baseline labels to users.

.DESCRIPTION
    This script creates a Label Policy that publishes the "General" and "Confidential" 
    sensitivity labels to all users in the tenant. It configures:
    - Policy scope: All users
    - Default label: General
    - Mandatory labeling: Required
    - Justification: Required for downgrade/removal
    
    Policy propagation takes up to 24 hours for full availability in desktop apps.

.PARAMETER TenantId
    The Directory (Tenant) ID.

.PARAMETER AppId
    The Application (Client) ID.

.PARAMETER CertificateThumbprint
    The thumbprint of the client certificate.

.EXAMPLE
    .\Deploy-LabelPolicy.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-29
    
    Requirements:
    - ExchangeOnlineManagement module
    - Service Principal with Compliance Administrator role
    - Baseline labels (General, Confidential) must already exist
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$TenantId,

    [Parameter(Mandatory = $false)]
    [string]$AppId,

    [Parameter(Mandatory = $false)]
    [string]$CertificateThumbprint
)

# =============================================================================
# Step 0: Authentication
# =============================================================================

$connectScript = Join-Path $PSScriptRoot "..\..\scripts\Connect-PurviewGraph.ps1"
if (Test-Path $connectScript) {
    Write-Host "🔌 Connecting to Microsoft Graph..." -ForegroundColor Cyan
    . $connectScript -TenantId $TenantId -AppId $AppId -CertificateThumbprint $CertificateThumbprint
} else {
    Write-Host "❌ Connection script not found at $connectScript" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 1: Connect to Security & Compliance PowerShell
# =============================================================================

Write-Host "🔐 Step 1: Connecting to Security & Compliance PowerShell" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green

# Get Tenant Domain from Graph
try {
    Write-Host "   🔍 Retrieving default domain from Microsoft Graph..." -ForegroundColor Cyan
    $allDomains = Get-MgDomain -All
    $defaultDomain = $allDomains | Where-Object { $_.IsDefault } | Select-Object -First 1
    
    if (-not $defaultDomain) {
        throw "Could not determine default domain from Microsoft Graph."
    }
    $Organization = $defaultDomain.Id
    Write-Host "   ✅ Organization Domain: $Organization" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Failed to retrieve domain: $_" -ForegroundColor Red
    exit 1
}

# Connect to Security & Compliance PowerShell using helper script
try {
    Write-Host "   🚀 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
    
    # Check if already connected
    try {
        Get-DlpEdmSchema -ErrorAction Stop | Out-Null
        Write-Host "   ✅ Already connected to Security & Compliance PowerShell" -ForegroundColor Green
    } catch {
        # Use helper script for connection
        $helperScriptPath = Join-Path (Split-Path $PSScriptRoot -Parent) "scripts\Connect-PurviewIPPS.ps1"
        if (Test-Path $helperScriptPath) {
            . $helperScriptPath
            Write-Host "   ✅ Connected to Security & Compliance PowerShell" -ForegroundColor Green
        } else {
            throw "Helper script not found at: $helperScriptPath"
        }
    }
} catch {
    Write-Host "   ❌ Failed to connect to Security & Compliance PowerShell: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Verify Labels Exist
# =============================================================================

Write-Host "🔍 Step 2: Verifying Baseline Labels Exist" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

try {
    $allLabels = Get-Label -ErrorAction Stop
    $generalLabel = $allLabels | Where-Object { $_.DisplayName -eq "General" }
    $confidentialLabel = $allLabels | Where-Object { $_.DisplayName -eq "Confidential" }
    
    if (-not $generalLabel) {
        Write-Host "   ❌ Label 'General' not found. Please run Deploy-BaselineLabels.ps1 first." -ForegroundColor Red
        exit 1
    }
    if (-not $confidentialLabel) {
        Write-Host "   ❌ Label 'Confidential' not found. Please run Deploy-BaselineLabels.ps1 first." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "   ✅ Found label: General (ID: $($generalLabel.Name))" -ForegroundColor Green
    Write-Host "   ✅ Found label: Confidential (ID: $($confidentialLabel.Name))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to retrieve labels: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Create or Update Label Policy
# =============================================================================

Write-Host "🚀 Step 3: Deploying Label Policy" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

$policyName = "Global Sensitivity Policy"

try {
    # Check if policy already exists
    $existingPolicy = Get-LabelPolicy -Identity $policyName -ErrorAction SilentlyContinue
    
    if ($existingPolicy) {
        Write-Host "   ✅ Label Policy '$policyName' already exists. Skipping creation." -ForegroundColor Green
        Write-Host "   ℹ️ To modify the policy, use Set-LabelPolicy cmdlet or the Purview Portal." -ForegroundColor Cyan
    } else {
        Write-Host "   ⏳ Creating Label Policy: $policyName" -ForegroundColor Cyan
        
        # Create the policy with all baseline labels
        $labelNames = @($generalLabel.Name, $confidentialLabel.Name)
        
        New-LabelPolicy `
            -Name $policyName `
            -Labels $labelNames `
            -ExchangeLocation "All" `
            -Comment "Baseline sensitivity label policy for all users" `
            -ErrorAction Stop
        
        Write-Host "   ✅ Label Policy created successfully." -ForegroundColor Green
        
        # Configure advanced settings
        Write-Host "   ⏳ Configuring policy settings..." -ForegroundColor Cyan
        
        Set-LabelPolicy -Identity $policyName `
            -Settings @{
                "mandatory" = "true"
                "requiredowngradejustification" = "true"
                "defaultlabelid" = $generalLabel.Name
            } `
            -ErrorAction Stop
        
        Write-Host "   ✅ Policy settings configured:" -ForegroundColor Green
        Write-Host "      • Default label: General" -ForegroundColor White
        Write-Host "      • Mandatory labeling: Enabled" -ForegroundColor White
        Write-Host "      • Downgrade justification: Required" -ForegroundColor White
        Write-Host "      • Scope: All users in tenant" -ForegroundColor White
    }
} catch {
    Write-Host "   ❌ Failed to create/update label policy: $_" -ForegroundColor Red
    Write-Host "   ℹ️ Common issues:" -ForegroundColor Yellow
    Write-Host "      - Service Principal lacks 'Compliance Administrator' role" -ForegroundColor Yellow
    Write-Host "      - Labels do not exist (run Deploy-BaselineLabels.ps1 first)" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 4: Summary
# =============================================================================

Write-Host ""
Write-Host "📋 Summary & Next Steps:" -ForegroundColor Cyan
Write-Host "   ✅ Label Policy '$policyName' is deployed." -ForegroundColor Green
Write-Host "   ✅ Policy will propagate to M365 apps within 24 hours." -ForegroundColor Green
Write-Host ""
Write-Host "   ℹ️ The policy publishes these labels to all users:" -ForegroundColor Cyan
Write-Host "      • General (default)" -ForegroundColor White
Write-Host "      • Confidential" -ForegroundColor White
Write-Host ""
Write-Host "   ℹ️ After 24 hours, verify labels appear in Word/Excel:" -ForegroundColor Cyan
Write-Host "      1. Open Word or Excel (desktop or web)" -ForegroundColor White
Write-Host "      2. Look for the 'Sensitivity' button on the ribbon" -ForegroundColor White
Write-Host "      3. Click it and verify labels are visible" -ForegroundColor White
Write-Host "      4. Create a new document - you should be prompted to select a label" -ForegroundColor White

Write-Host ""
Write-Host "✅ Label Policy deployment completed" -ForegroundColor Green
Write-Host "   🔍 Verify policy in Purview Portal > Information Protection > Label policies" -ForegroundColor Cyan
