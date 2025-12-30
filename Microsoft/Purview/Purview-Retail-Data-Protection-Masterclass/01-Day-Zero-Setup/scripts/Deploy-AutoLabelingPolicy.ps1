<#
.SYNOPSIS
    Deploys an Auto-Labeling policy in simulation mode for PII/PCI data detection.

.DESCRIPTION
    This script creates a service-side auto-labeling policy that scans SharePoint 
    and OneDrive for sensitive payment and identity data (Credit Cards and SSNs) 
    and automatically applies the "Confidential" label. The policy runs in simulation 
    mode (24-48 hours) to show what files would be labeled without actually modifying them.
    
    Configuration:
    - Policy Name: "Auto-Label PII (Retail)"
    - Locations: SharePoint Sites, OneDrive Accounts
    - Detection: Credit Card Numbers, U.S. Social Security Numbers (SSN)
    - Label: Confidential
    - Mode: Simulation (safe, no enforcement)

.PARAMETER TenantId
    The Directory (Tenant) ID.

.PARAMETER AppId
    The Application (Client) ID.

.PARAMETER CertificateThumbprint
    The thumbprint of the client certificate.

.EXAMPLE
    .\Deploy-AutoLabelingPolicy.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-29
    
    Requirements:
    - ExchangeOnlineManagement module
    - Service Principal with Compliance Administrator role
    - Baseline labels (General, Confidential) must exist
    - Label Policy must be published
    
    Simulation Timeline:
    - Policy creation: Immediate
    - Simulation analysis: 24-48 hours
    - Results available in Purview Portal after completion
    
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

# Check for ExchangeOnlineManagement module
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "   📦 Installing ExchangeOnlineManagement module..." -ForegroundColor Cyan
    Install-Module -Name ExchangeOnlineManagement -Force -Scope CurrentUser -AllowClobber
}

# Connect to IPPSSession
try {
    Write-Host "   🚀 Connecting to IPPSSession (App-Only)..." -ForegroundColor Cyan
    Connect-IPPSSession -AppId $AppId -CertificateThumbprint $CertificateThumbprint -Organization $Organization -ShowBanner:$false
    Write-Host "   ✅ Connected to Security & Compliance PowerShell" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to connect to IPPSSession: $_" -ForegroundColor Red
    Write-Host "   ℹ️ Ensure the Service Principal has the 'Compliance Administrator' directory role." -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 2: Verify Label Exists and Get Sublabels if Parent
# =============================================================================

Write-Host "🔍 Step 2: Verifying 'Confidential' Label Exists" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

try {
    $allLabels = Get-Label -ErrorAction Stop
    $confidentialLabel = $allLabels | Where-Object { $_.DisplayName -eq "Confidential" }
    
    if (-not $confidentialLabel) {
        Write-Host "   ❌ Label 'Confidential' not found." -ForegroundColor Red
        Write-Host "   ℹ️ Please run Deploy-BaselineLabels.ps1 and Deploy-LabelPolicy.ps1 first." -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "   ✅ Found label: Confidential (ID: $($confidentialLabel.Name))" -ForegroundColor Green
    
    # Check if this is a parent label (has sublabels)
    $sublabels = $allLabels | Where-Object { $_.ParentId -eq $confidentialLabel.Name }
    
    if ($sublabels) {
        Write-Host "   ℹ️ 'Confidential' is a parent label with sublabels." -ForegroundColor Cyan
        Write-Host "   📋 Found $($sublabels.Count) sublabel(s):" -ForegroundColor Cyan
        foreach ($sub in $sublabels) {
            Write-Host "      • $($sub.DisplayName) (ID: $($sub.Name))" -ForegroundColor White
        }
        
        # Use the first sublabel for auto-labeling
        $labelToUse = $sublabels[0]
        Write-Host "   ✅ Using sublabel '$($labelToUse.DisplayName)' for auto-labeling policy" -ForegroundColor Green
    } else {
        # Not a parent label, use it directly
        $labelToUse = $confidentialLabel
        Write-Host "   ✅ 'Confidential' is a leaf label (no sublabels), using it directly" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Failed to retrieve labels: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Create Auto-Labeling Policy
# =============================================================================

Write-Host "🚀 Step 3: Deploying Auto-Labeling Policy" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

$policyName = "Auto-Label PII (Retail)"

try {
    # Check if policy already exists
    $existingPolicy = Get-AutoSensitivityLabelPolicy -Identity $policyName -ErrorAction SilentlyContinue
    
    if ($existingPolicy) {
        Write-Host "   ℹ️ Policy '$policyName' already exists." -ForegroundColor Yellow
        Write-Host "   🗑️ Deleting existing policy to recreate with detection rules..." -ForegroundColor Cyan
        
        Remove-AutoSensitivityLabelPolicy -Identity $policyName -Confirm:$false -ErrorAction Stop
        Write-Host "   ✅ Existing policy removed." -ForegroundColor Green
        
        # Wait for deletion to propagate (can take 30-60 seconds)
        Write-Host "   ⏳ Waiting for deletion to propagate (30 seconds)..." -ForegroundColor Cyan
        $maxWait = 60
        $waited = 0
        $interval = 10
        
        while ($waited -lt $maxWait) {
            Start-Sleep -Seconds $interval
            $waited += $interval
            
            $stillExists = Get-AutoSensitivityLabelPolicy -Identity $policyName -ErrorAction SilentlyContinue
            if (-not $stillExists) {
                Write-Host "   ✅ Policy fully deleted after $waited seconds." -ForegroundColor Green
                break
            }
            
            Write-Host "   ⏳ Still propagating... ($waited/$maxWait seconds)" -ForegroundColor Yellow
        }
        
        # Final safety pause
        Start-Sleep -Seconds 5
    }
    
    Write-Host "   ⏳ Creating Auto-Labeling Policy: $policyName" -ForegroundColor Cyan
    
    # Create the policy in simulation mode (TestWithoutNotifications)
    New-AutoSensitivityLabelPolicy `
        -Name $policyName `
        -Comment "Baseline auto-labeling policy for PII detection in simulation mode" `
        -ApplySensitivityLabel $labelToUse.Name `
        -SharePointLocation "All" `
        -OneDriveLocation "All" `
        -Mode TestWithoutNotifications `
        -ErrorAction Stop
    
    Write-Host "   ✅ Auto-labeling policy created successfully in Simulation mode." -ForegroundColor Green
    
    # Add auto-labeling rules for PII/PCI detection
    Write-Host "   ⏳ Adding detection rules for Credit Cards and SSNs..." -ForegroundColor Cyan
    
    Start-Sleep -Seconds 3  # Brief pause to ensure policy is ready
    
    # Rule 1: Credit Card Detection (SharePoint)
    Write-Host "      ⏳ Creating rule: Detect Credit Cards (SharePoint)" -ForegroundColor Cyan
    New-AutoSensitivityLabelRule `
        -Policy $policyName `
        -Name "Detect Credit Cards (SharePoint)" `
        -Workload SharePoint `
        -ContentContainsSensitiveInformation @{name="Credit Card Number"; mincount="1"} `
        -ErrorAction Stop
    Write-Host "      ✅ Credit Card detection rule created for SharePoint" -ForegroundColor Green
    
    # Rule 2: SSN Detection (SharePoint)
    Write-Host "      ⏳ Creating rule: Detect SSN (SharePoint)" -ForegroundColor Cyan
    New-AutoSensitivityLabelRule `
        -Policy $policyName `
        -Name "Detect SSN (SharePoint)" `
        -Workload SharePoint `
        -ContentContainsSensitiveInformation @{name="U.S. Social Security Number (SSN)"; mincount="1"} `
        -ErrorAction Stop
    Write-Host "      ✅ SSN detection rule created for SharePoint" -ForegroundColor Green
    
    # Rule 3: Credit Card Detection (OneDrive)
    Write-Host "      ⏳ Creating rule: Detect Credit Cards (OneDrive)" -ForegroundColor Cyan
    New-AutoSensitivityLabelRule `
        -Policy $policyName `
        -Name "Detect Credit Cards (OneDrive)" `
        -Workload OneDriveForBusiness `
        -ContentContainsSensitiveInformation @{name="Credit Card Number"; mincount="1"} `
        -ErrorAction Stop
    Write-Host "      ✅ Credit Card detection rule created for OneDrive" -ForegroundColor Green
    
    # Rule 4: SSN Detection (OneDrive)
    Write-Host "      ⏳ Creating rule: Detect SSN (OneDrive)" -ForegroundColor Cyan
    New-AutoSensitivityLabelRule `
        -Policy $policyName `
        -Name "Detect SSN (OneDrive)" `
        -Workload OneDriveForBusiness `
        -ContentContainsSensitiveInformation @{name="U.S. Social Security Number (SSN)"; mincount="1"} `
        -ErrorAction Stop
    Write-Host "      ✅ SSN detection rule created for OneDrive" -ForegroundColor Green
    
    Write-Host "   ✅ Auto-labeling rules configured:" -ForegroundColor Green
    Write-Host "      • Detection: Credit Card Numbers, U.S. Social Security Numbers (SSN)" -ForegroundColor White
    Write-Host "      • Label to apply: $($labelToUse.DisplayName)" -ForegroundColor White
    Write-Host "      • Minimum count: 1 per SIT" -ForegroundColor White
    Write-Host "      • Locations: SharePoint (All), OneDrive (All)" -ForegroundColor White
    Write-Host "      • Mode: Simulation (no files will be modified)" -ForegroundColor White
} catch {
    Write-Host "   ❌ Failed to create auto-labeling policy: $_" -ForegroundColor Red
    Write-Host "   ℹ️ Common issues:" -ForegroundColor Yellow
    Write-Host "      - Service Principal lacks 'Compliance Administrator' role" -ForegroundColor Yellow
    Write-Host "      - Label 'Confidential' does not exist" -ForegroundColor Yellow
    Write-Host "      - Label Policy not yet published" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Step 4: Summary
# =============================================================================

Write-Host ""
Write-Host "📋 Summary & Next Steps:" -ForegroundColor Cyan
Write-Host "   ✅ Auto-labeling policy '$policyName' is deployed in Simulation mode." -ForegroundColor Green
Write-Host "   ✅ Policy will begin analyzing SharePoint and OneDrive content." -ForegroundColor Green
Write-Host ""
Write-Host "   ⏳ Simulation Timeline:" -ForegroundColor Cyan
Write-Host "      • Analysis period: 24-48 hours" -ForegroundColor White
Write-Host "      • Mode: Simulation (safe - no files modified)" -ForegroundColor White
Write-Host "      • Detection: U.S. Social Security Numbers" -ForegroundColor White
Write-Host "      • Label: $($labelToUse.DisplayName) (applied in simulation only)" -ForegroundColor White
Write-Host ""
Write-Host "   ℹ️ After 24-48 hours, review simulation results:" -ForegroundColor Cyan
Write-Host "      1. Go to Purview Portal > Information Protection > Auto-labeling" -ForegroundColor White
Write-Host "      2. Click on '$policyName' policy" -ForegroundColor White
Write-Host "      3. Click 'View simulation results'" -ForegroundColor White
Write-Host "      4. Review the list of files that matched SSN patterns" -ForegroundColor White
Write-Host "      5. In Lab 03, decide whether to turn on enforcement" -ForegroundColor White
Write-Host ""
Write-Host "   💡 Why Simulation Mode?" -ForegroundColor Cyan
Write-Host "      • See what would be auto-labeled before enforcing" -ForegroundColor White
Write-Host "      • Validate classifier accuracy with real data" -ForegroundColor White
Write-Host "      • Identify false positives before production" -ForegroundColor White
Write-Host "      • Safe testing with no risk to existing files" -ForegroundColor White

Write-Host ""
Write-Host "✅ Auto-labeling policy deployment completed" -ForegroundColor Green
Write-Host "   🔍 Verify policy in Purview Portal > Information Protection > Auto-labeling" -ForegroundColor Cyan
