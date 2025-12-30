<#
.SYNOPSIS
    Deploys comprehensive baseline DLP Policies for M365 workloads.

.DESCRIPTION
    This script creates all core Data Loss Prevention (DLP) policies targeting M365 workloads:
    - Exchange Online
    - SharePoint Online
    - OneDrive for Business
    - Teams Chat and Channel Messages

    Policies Created:
    1. "PCI-DSS Protection (Retail)" - Detects Credit Cards and ABA Routing Numbers.
    2. "PII Data Protection (Retail)" - Detects U.S. SSNs.
    3. "Loyalty Card Protection (Retail)" - Detects custom Retail Loyalty ID pattern.
    4. "External Sharing Control (Retail)" - Restricts external sharing of sensitive files.

    The policies are created in "Test with Notifications" mode and propagate to M365
    workloads within 1-2 hours.

.PARAMETER TenantId
    The Directory (Tenant) ID.

.PARAMETER AppId
    The Application (Client) ID.

.PARAMETER CertificateThumbprint
    The thumbprint of the client certificate.

.EXAMPLE
    .\Deploy-BaselineDlpPolicies.ps1 -TenantId "..." -AppId "..." -CertificateThumbprint "..."

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-28
    
    Requirements:
    - ExchangeOnlineManagement module
    - Service Principal with Compliance Administrator role

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
    # Dot-source the script to ensure variables ($AppId, $CertificateThumbprint) are available in this scope
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

# 1. Get Tenant Domain (Organization) from Graph
try {
    Write-Host "   🔍 Retrieving default domain from Microsoft Graph..." -ForegroundColor Cyan
    # Filter is not supported on this endpoint, so we filter client-side
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

# 2. Check for ExchangeOnlineManagement module
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "   📦 Installing ExchangeOnlineManagement module..." -ForegroundColor Cyan
    Install-Module -Name ExchangeOnlineManagement -Force -Scope CurrentUser -AllowClobber
}

# 3. Connect to IPPSSession
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
# Step 2: Deploy Baseline DLP Policies
# =============================================================================

Write-Host "🚀 Step 2: Deploying Baseline DLP Policies" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

$policies = @(
    @{
        Name = "PCI-DSS Protection (Retail)"
        Description = "Protects credit card and banking data across all workloads"
        Rules = @(
            @{ Name = "Credit Card Data"; SIT = "Credit Card Number" },
            @{ Name = "Banking Data"; SIT = "ABA Routing Number" }
        )
    },
    @{
        Name = "PII Data Protection (Retail)"
        Description = "Protects Social Security Numbers and personal identifiable information"
        Rules = @(
            @{ Name = "U.S. PII Data"; SIT = "U.S. Social Security Number (SSN)" }
        )
    },
    @{
        Name = "Loyalty Card Protection (Retail)"
        Description = "Protects proprietary Retail Loyalty ID data (placeholder rule will be replaced in Lab 04)"
        Rules = @(
            @{ 
                Name = "Loyalty ID Detection (Placeholder)"; 
                SIT = "Credit Card Number";
                IsPlaceholder = $true
            }
        )
    },
    @{
        Name = "External Sharing Control (Retail)"
        Description = "Restricts external sharing of confidential documents"
        Rules = @(
            @{ 
                Name = "Block External Sharing"; 
                SIT = "Credit Card Number"; 
                ExternalOnly = $true 
            }
        )
    }
)

foreach ($policy in $policies) {
    $policyName = $policy.Name
    $policyDescription = $policy.Description
    Write-Host "   ⏳ Processing Policy: $policyName" -ForegroundColor Cyan

    try {
        $existingPolicy = Get-DlpCompliancePolicy -Identity $policyName -ErrorAction SilentlyContinue
        
        if ($existingPolicy) {
            Write-Host "   ✅ DLP Policy '$policyName' already exists. Skipping creation." -ForegroundColor Green
        } else {
            # Create Policy Container with M365 Locations
            New-DlpCompliancePolicy -Name $policyName `
                -Comment $policyDescription `
                -ExchangeLocation All `
                -SharePointLocation All `
                -OneDriveLocation All `
                -TeamsLocation All `
                -Mode TestWithNotifications `
                -ErrorAction Stop
                
            Write-Host "   ✅ DLP Policy created with M365 locations (Exchange, SharePoint, OneDrive, Teams)." -ForegroundColor Green

            # Create Rules
            foreach ($rule in $policy.Rules) {
                $ruleName = "$($policyName) - $($rule.Name)"
                Write-Host "      ⏳ Creating Rule '$ruleName'..." -ForegroundColor Cyan
                
                # Add note for placeholder rules
                if ($rule.IsPlaceholder) {
                    Write-Host "      ℹ️ Using placeholder SIT - will be replaced with custom SIT in Lab 04" -ForegroundColor Yellow
                }
                
                # Base parameters for rule creation
                $ruleParams = @{
                    Name = $ruleName
                    Policy = $policyName
                    ContentContainsSensitiveInformation = @(@{Name=$rule.SIT; MinCount=1})
                    BlockAccess = $false
                    NotifyUser = "Owner"
                    ErrorAction = "Stop"
                }
                
                # Add external-only condition if specified
                if ($rule.ExternalOnly) {
                    $ruleParams['ContentIsShared'] = 'FromOutside'
                }
                
                New-DlpComplianceRule @ruleParams
                    
                Write-Host "      ✅ Rule created." -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "   ❌ Failed to deploy DLP Policy '$policyName'." -ForegroundColor Red
        Write-Host "      Error: $_" -ForegroundColor Red
        # Continue to next policy instead of exiting
    }
}

Write-Host ""
Write-Host "📋 Summary & Next Steps:" -ForegroundColor Cyan
Write-Host "   ✅ Baseline policies created for M365 workloads (Exchange, SharePoint, OneDrive, Teams)." -ForegroundColor Green
Write-Host "   ✅ Policies will propagate to all locations within 1-2 hours." -ForegroundColor Green
Write-Host ""
Write-Host "   ℹ️ The 'Loyalty Card Protection' policy uses a placeholder rule (Credit Card)." -ForegroundColor Cyan
Write-Host "   ℹ️ You will edit this policy in Lab 04 to replace with the custom 'Retail Loyalty ID' SIT." -ForegroundColor Cyan
Write-Host "   ℹ️ EDM-based policies will be created in Lab 03 after EDM schema is indexed." -ForegroundColor Cyan

# =============================================================================
# Script Completion
# =============================================================================

Write-Host ""
Write-Host "✅ Baseline DLP Policy deployment completed" -ForegroundColor Green
Write-Host "   🔍 Verify policies in Purview Portal > Data Loss Prevention > Policies" -ForegroundColor Cyan
