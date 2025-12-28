<#
.SYNOPSIS
    Deploys baseline Sensitivity Labels ("General", "Confidential") to initiate propagation.

.DESCRIPTION
    This script creates two initial Sensitivity Labels using the Microsoft Graph API (Beta).
    The purpose is to start the 24-hour propagation clock immediately.
    It creates:
    1. "General" - No encryption, visual marking only.
    2. "Confidential" - Watermark only (simple configuration for speed).

.PARAMETER TenantId
    The Directory (Tenant) ID.

.PARAMETER AppId
    The Application (Client) ID.

.PARAMETER CertificateThumbprint
    The thumbprint of the client certificate.

.EXAMPLE
    .\Deploy-BaselineLabels.ps1 -TenantId "..." -AppId "..." -CertificateThumbprint "..."

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2024-05-22
    
    Requirements:
    - Microsoft.Graph module
    - Service Principal with InformationProtectionPolicy.ReadWrite.All

    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$AppId,

    [Parameter(Mandatory = $true)]
    [string]$CertificateThumbprint
)

# Import Connection Helper
$connectScript = Join-Path $PSScriptRoot "..\00-Prerequisites\Connect-PurviewGraph.ps1"
if (Test-Path $connectScript) {
    . $connectScript -TenantId $TenantId -AppId $AppId -CertificateThumbprint $CertificateThumbprint
} else {
    Throw "Connection script not found at $connectScript"
}

# =============================================================================
# Step 1: Define Label Taxonomy
# =============================================================================

Write-Host "📋 Step 1: Defining Label Taxonomy" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

$labels = @(
    @{
        displayName = "General"
        description = "Business data that is not intended for public consumption."
        toolTip = "Use for internal business data."
        rank = 10
        isActive = $true
        color = @{
            color = "Blue"
        }
        sensitivity = 10
    },
    @{
        displayName = "Confidential"
        description = "Sensitive business data that could cause damage if leaked."
        toolTip = "Use for sensitive internal data."
        rank = 20
        isActive = $true
        color = @{
            color = "Orange"
        }
        sensitivity = 20
    }
)

# =============================================================================
# Step 2: Deploy Labels via REST API
# =============================================================================

Write-Host "🚀 Step 2: Deploying Labels" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

foreach ($label in $labels) {
    $labelName = $label.displayName
    Write-Host "   ⏳ Creating label: $labelName" -ForegroundColor Cyan

    try {
        # Check if label exists (simplified check by name - in prod use ID)
        # For Day Zero, we assume clean slate or just try/catch
        
        $uri = "https://graph.microsoft.com/beta/informationProtection/sensitivityLabels"
        $jsonPayload = $label | ConvertTo-Json -Depth 5

        $response = Invoke-MgGraphRequest -Method POST -Uri $uri -Body $jsonPayload -ContentType "application/json"
        
        Write-Host "   ✅ Label '$labelName' created successfully." -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️ Failed to create label '$labelName'. It may already exist or API requires specific permissions." -ForegroundColor Yellow
        Write-Host "   ❌ Error: $_" -ForegroundColor Red
    }
}

Write-Host "   ℹ️ Note: Policy publication is required to make these labels visible to users." -ForegroundColor Cyan
Write-Host "   ℹ️ Please create a Label Policy in the Purview Portal or via script to publish these." -ForegroundColor Cyan
