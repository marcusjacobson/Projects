<#
.SYNOPSIS
    Connects to Microsoft Purview services using browser-based authentication.

.DESCRIPTION
    This utility script establishes connections to SharePoint Online and Security &
    Compliance PowerShell using browser-based authentication. It provides a consistent
    authentication pattern across all simulation scripts and implements session reuse
    to minimize authentication prompts.
    
    No secrets, credentials, or app registrations are required - all authentication
    uses interactive browser flows with delegated permissions.

.PARAMETER TenantUrl
    SharePoint tenant URL (e.g., https://contoso.sharepoint.com).
    Typically loaded from global-config.json Environment.TenantUrl.

.PARAMETER SkipSharePoint
    Skip SharePoint connection (connect to Security & Compliance only).

.PARAMETER SkipCompliance
    Skip Security & Compliance connection (connect to SharePoint only).

.EXAMPLE
    $config = .\Shared-Utilities\Import-GlobalConfig.ps1
    .\Shared-Utilities\Connect-PurviewServices.ps1 -TenantUrl $config.Environment.TenantUrl
    
    Connects to both SharePoint and Security & Compliance using config values.

.EXAMPLE
    .\Shared-Utilities\Connect-PurviewServices.ps1 -TenantUrl "https://contoso.sharepoint.com" -SkipCompliance
    
    Connects to SharePoint only (useful for site creation scripts).

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - PnP.PowerShell module v2.x
    - ExchangeOnlineManagement module v3.x
    - Internet connectivity for browser authentication
    - Global Admin and Compliance Admin roles
    
    Script development orchestrated using GitHub Copilot.

.SHARED UTILITY OPERATIONS
    - PnP PowerShell Authentication (SharePoint Online)
    - Exchange Online Authentication (Compliance Center)
    - Microsoft Graph Authentication (Entra ID)
    - Session Management and Token Refresh
#>
#
# =============================================================================
# Connect to Purview services with browser-based authentication.
# =============================================================================

function Connect-PurviewServices {
    [CmdletBinding()]
    param (
    [Parameter(Mandatory = $true)]
    [string]$TenantUrl,
    
    [Parameter(Mandatory = $false)]
    [string]$ClientId,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipSharePoint,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipCompliance
)

# =============================================================================
# Step 1: Validate Required Modules
# =============================================================================

Write-Host "🔍 Step 1: Validating Required PowerShell Modules" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

$requiredModules = @()

if (-not $SkipSharePoint) {
    $requiredModules += @{Name = "PnP.PowerShell"; MinVersion = "2.0.0"}
}

if (-not $SkipCompliance) {
    $requiredModules += @{Name = "ExchangeOnlineManagement"; MinVersion = "3.0.0"}
}

foreach ($module in $requiredModules) {
    $installedModule = Get-Module -Name $module.Name -ListAvailable | 
        Where-Object { $_.Version -ge [version]$module.MinVersion } | 
        Select-Object -First 1
    
    if ($null -eq $installedModule) {
        Write-Host "   ❌ Module not found: $($module.Name) v$($module.MinVersion)+" -ForegroundColor Red
        throw "Required module $($module.Name) v$($module.MinVersion) or later is not installed. Run: Install-Module -Name $($module.Name) -Scope CurrentUser"
    } else {
        Write-Host "   ✅ Module found: $($module.Name) v$($installedModule.Version)" -ForegroundColor Green
    }
}

# =============================================================================
# Step 2: Connect to SharePoint Online
# =============================================================================

if (-not $SkipSharePoint) {
    Write-Host "`n🔗 Step 2: Connecting to SharePoint Online" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "   Tenant URL: $TenantUrl" -ForegroundColor Cyan
    
    try {
        # CRITICAL: Always disconnect before connecting to ensure fresh OAuth token
        # This is essential when uploading to multiple sites - each site needs its own
        # properly-scoped OAuth token. Reusing connections can cause "Access denied" errors.
        try {
            $existingConnection = Get-PnPConnection -ErrorAction SilentlyContinue
            if ($null -ne $existingConnection) {
                Write-Host "   ⚠️  Disconnecting existing connection to ensure fresh token..." -ForegroundColor Yellow
                Disconnect-PnPOnline -ErrorAction SilentlyContinue
            }
        } catch {
            # No connection exists - this is expected on first run
        }
        
        Write-Host "   🌐 Launching browser for authentication..." -ForegroundColor Cyan
        Write-Host "   ℹ️  Please complete authentication in your browser" -ForegroundColor Cyan
        
        # Connect with browser-based authentication using custom app registration from global-config.json
        # PnP.PowerShell v3.x requires ClientId for Interactive authentication
        if ($ClientId) {
            Connect-PnPOnline -Url $TenantUrl -Interactive -ClientId $ClientId -ErrorAction Stop
        } else {
            # Fallback if ClientId not provided (not recommended for production)
            Connect-PnPOnline -Url $TenantUrl -Interactive -ErrorAction Stop
        }
        
        Write-Host "   ✅ Successfully connected to SharePoint Online" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Failed to connect to SharePoint Online: $_" -ForegroundColor Red
        throw "SharePoint connection failed. Ensure you have SharePoint Administrator permissions and valid browser authentication."
    }
} else {
    Write-Host "`n⏭️  Step 2: Skipping SharePoint Online Connection" -ForegroundColor Yellow
}

# =============================================================================
# Step 3: Connect to Security & Compliance PowerShell
# =============================================================================

if (-not $SkipCompliance) {
    Write-Host "`n🔗 Step 3: Connecting to Security & Compliance PowerShell" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
    
    try {
        # Check for existing connection
        $existingSession = Get-PSSession | Where-Object { 
            $_.ComputerName -like "*compliance.protection.outlook.com*" -and 
            $_.State -eq "Opened" 
        } | Select-Object -First 1
        
        if ($null -ne $existingSession) {
            Write-Host "   ℹ️  Existing Security & Compliance session found - reusing" -ForegroundColor Cyan
            Write-Host "   ✅ Connected to Security & Compliance PowerShell" -ForegroundColor Green
        } else {
            Write-Host "   🌐 Launching browser for authentication..." -ForegroundColor Cyan
            Write-Host "   ℹ️  Please complete authentication in your browser" -ForegroundColor Cyan
            
            # Connect with browser-based authentication (no credentials)
            Connect-IPPSSession -ErrorAction Stop
            
            Write-Host "   ✅ Successfully connected to Security & Compliance PowerShell" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ Failed to connect to Security & Compliance PowerShell: $_" -ForegroundColor Red
        throw "Security & Compliance connection failed. Ensure you have Compliance Administrator permissions and valid browser authentication."
    }
} else {
    Write-Host "`n⏭️  Step 3: Skipping Security & Compliance Connection" -ForegroundColor Yellow
}

# =============================================================================
# Step 4: Connection Summary
# =============================================================================

Write-Host "`n✅ Connection Summary" -ForegroundColor Magenta
Write-Host "=====================" -ForegroundColor Magenta

if (-not $SkipSharePoint) {
    $spConnection = Get-PnPConnection -ErrorAction SilentlyContinue
    if ($null -ne $spConnection) {
        Write-Host "✅ SharePoint Online: Connected to $($spConnection.Url)" -ForegroundColor Green
    } else {
        Write-Host "❌ SharePoint Online: Not connected" -ForegroundColor Red
    }
}

if (-not $SkipCompliance) {
    $complianceSession = Get-PSSession | Where-Object { 
        $_.ComputerName -like "*compliance.protection.outlook.com*" -and 
        $_.State -eq "Opened" 
    } | Select-Object -First 1
    
    if ($null -ne $complianceSession) {
        Write-Host "✅ Security & Compliance: Connected (Session ID: $($complianceSession.InstanceId))" -ForegroundColor Green
    } else {
        Write-Host "❌ Security & Compliance: Not connected" -ForegroundColor Red
    }
}

Write-Host "`n✅ Authentication complete - ready for simulation operations" -ForegroundColor Green
}
