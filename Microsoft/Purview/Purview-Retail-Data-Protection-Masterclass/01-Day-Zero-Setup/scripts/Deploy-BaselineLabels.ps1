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
# Step 1: Define Label Taxonomy
# =============================================================================

Write-Host "📋 Step 1: Defining Label Taxonomy" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

$labels = @(
    @{
        Name = "General"
        DisplayName = "General"
        ToolTip = "Use for internal business data."
        Comment = "Business data that is not intended for public consumption."
        Priority = 10
    },
    @{
        Name = "Confidential"
        DisplayName = "Confidential"
        ToolTip = "Use for sensitive internal data."
        Comment = "Sensitive business data that could cause damage if leaked."
        Priority = 20
    }
)

# =============================================================================
# Step 2: Connect to Security & Compliance PowerShell
# =============================================================================

Write-Host "🔐 Step 2: Connecting to Security & Compliance PowerShell" -ForegroundColor Green
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

# 2. Connect to Security & Compliance PowerShell using helper script
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
# Step 3: Deploy Labels via PowerShell
# =============================================================================

Write-Host "🚀 Step 3: Deploying Labels" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

# Pre-fetch all labels to avoid repeated calls and handle DisplayName matching reliably
try {
    $allLabels = Get-Label -ErrorAction SilentlyContinue
} catch {
    $allLabels = @()
}

foreach ($label in $labels) {
    $labelName = $label.Name
    $displayName = $label.DisplayName
    Write-Host "   ⏳ Processing label: $displayName" -ForegroundColor Cyan

    try {
        # Check if label exists by Name OR DisplayName
        $existingLabel = $allLabels | Where-Object { $_.Name -eq $labelName -or $_.DisplayName -eq $displayName }

        if ($existingLabel) {
            Write-Host "   ✅ Label '$displayName' already exists (ID: $($existingLabel.Name)). Skipping creation." -ForegroundColor Green
        } else {
            # New-Label does not support -Rank or -Priority directly during creation. 
            # Priority is assigned automatically (appended to end). We can set it later if needed.
            New-Label -Name $label.Name -DisplayName $label.DisplayName -ToolTip $label.ToolTip -Comment $label.Comment -ErrorAction Stop
            Write-Host "   ✅ Label '$displayName' created successfully." -ForegroundColor Green
        }
    } catch {
        # Check for duplicate/conflict errors
        if ($_.Exception.Message -like "*Duplicate display name*" -or $_.Exception.Message -like "*already used by label*") {
             Write-Host "   ✅ Label '$displayName' already exists (detected via conflict). Skipping creation." -ForegroundColor Green
        } else {
            Write-Host "   ❌ Failed to process label '$displayName'." -ForegroundColor Red
            Write-Host "      Error: $_" -ForegroundColor Red
        }
    }
}

Write-Host "   ℹ️ Note: Policy publication is required to make these labels visible to users." -ForegroundColor Cyan
Write-Host "   ℹ️ Please create a Label Policy in the Purview Portal or via script to publish these." -ForegroundColor Cyan
