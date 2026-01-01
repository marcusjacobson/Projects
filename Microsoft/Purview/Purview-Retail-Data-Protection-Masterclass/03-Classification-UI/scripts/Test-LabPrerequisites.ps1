<#
.SYNOPSIS
    Validates prerequisites for 03-Classification-UI lab.

.DESCRIPTION
    This script performs comprehensive validation of all prerequisites required
    for the Classification UI Configuration lab, including:
    - Audit log enablement
    - Required PowerShell modules
    - User permissions
    - Test data availability

.EXAMPLE
    .\Test-LabPrerequisites.ps1
    
    Runs all prerequisite checks and reports status.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-30
    Last Modified: 2025-12-30
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - ExchangeOnlineManagement module (for DLP cmdlets)
    - PnP.PowerShell module (for SharePoint validation)
    - Compliance Administrator role
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Prerequisite validation for 03-Classification-UI lab.
# =============================================================================

#Requires -Version 5.1

[CmdletBinding()]
param()

# =============================================================================
# Script Configuration
# =============================================================================

$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"

$script:AllChecksPassed = $true
$script:Warnings = @()

# =============================================================================
# Configuration Loading
# =============================================================================

# Load configuration from global-config.json
$configPath = Join-Path $PSScriptRoot "..\..\templates\global-config.json"
$TenantId = $null
$AppId = $null
$CertificateThumbprint = $null
$Organization = $null
$TenantPrefix = $null

if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    
    # Resolve Tenant ID
    if ($config.tenantId) {
        $TenantId = $config.tenantId
    }
    
    # Resolve Certificate - check CurrentUser store first, then load from Certificates folder
    if ($config.servicePrincipal.certificateName) {
        $certName = $config.servicePrincipal.certificateName
        $cert = Get-ChildItem "Cert:\CurrentUser\My" | Where-Object { $_.Subject -eq "CN=$certName" } | Sort-Object NotAfter -Descending | Select-Object -First 1
        
        if ($cert) { 
            $CertificateThumbprint = $cert.Thumbprint 
        } else {
            # Certificate not in store - try to load from Certificates folder
            $certFolder = Join-Path $PSScriptRoot "..\..\Certificates"
            $pfxPath = Join-Path $certFolder "$certName.pfx"
            
            if (Test-Path $pfxPath) {
                try {
                    # Import certificate to CurrentUser store (no password required for self-signed)
                    $importedCert = Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation "Cert:\CurrentUser\My" -Exportable -ErrorAction Stop
                    $CertificateThumbprint = $importedCert.Thumbprint
                } catch {
                    # Ignore error - will fall back to interactive auth
                }
            }
        }
    }
    
    # Resolve App ID from ServicePrincipal-Details.txt
    $detailsPath = Join-Path $PSScriptRoot "..\..\scripts\ServicePrincipal-Details.txt"
    if (Test-Path $detailsPath) {
        $detailsContent = Get-Content $detailsPath
        foreach ($line in $detailsContent) {
            if ($line -match "App ID:\s+([a-f0-9-]{36})") {
                $AppId = $matches[1]
                break
            }
        }
    }
    
    # Resolve Organization domain and TenantPrefix from sharePointRootUrl
    if ($config.sharePointRootUrl -match "https://([^.]+)\.sharepoint\.com") {
        $TenantPrefix = $matches[1]
        $Organization = "$TenantPrefix.onmicrosoft.com"
    }
}

# =============================================================================
# Helper Functions
# =============================================================================

function Write-CheckHeader {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Write-CheckResult {
    param(
        [string]$Check,
        [bool]$Passed,
        [string]$Message = "",
        [string]$Recommendation = ""
    )
    
    if ($Passed) {
        Write-Host "✅ $Check" -ForegroundColor Green
        if ($Message) {
            Write-Host "   $Message" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ $Check" -ForegroundColor Red
        if ($Message) {
            Write-Host "   $Message" -ForegroundColor Yellow
        }
        if ($Recommendation) {
            Write-Host "   💡 Recommendation: $Recommendation" -ForegroundColor Cyan
        }
        $script:AllChecksPassed = $false
    }
}

function Write-WarningCheck {
    param(
        [string]$Check,
        [string]$Message
    )
    
    Write-Host "⚠️  $Check" -ForegroundColor Yellow
    Write-Host "   $Message" -ForegroundColor Gray
    $script:Warnings += $Check
}

# =============================================================================
# Step 1: PowerShell Module Validation
# =============================================================================

Write-CheckHeader "PowerShell Module Validation"

# Check for ExchangeOnlineManagement
try {
    $eomModule = Get-Module -ListAvailable -Name ExchangeOnlineManagement | Select-Object -First 1
    if ($eomModule) {
        Write-CheckResult -Check "ExchangeOnlineManagement Module" -Passed $true -Message "Version $($eomModule.Version) installed"
    } else {
        Write-CheckResult -Check "ExchangeOnlineManagement Module" -Passed $false `
            -Message "Module not found" `
            -Recommendation "Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser"
    }
} catch {
    Write-CheckResult -Check "ExchangeOnlineManagement Module" -Passed $false `
        -Message "Error checking module: $_" `
        -Recommendation "Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser"
}

# Check for PnP.PowerShell
try {
    $pnpModule = Get-Module -ListAvailable -Name PnP.PowerShell | Select-Object -First 1
    if ($pnpModule) {
        Write-CheckResult -Check "PnP.PowerShell Module" -Passed $true -Message "Version $($pnpModule.Version) installed"
    } else {
        Write-CheckResult -Check "PnP.PowerShell Module" -Passed $false `
            -Message "Module not found" `
            -Recommendation "Install-Module -Name PnP.PowerShell -Scope CurrentUser"
    }
} catch {
    Write-CheckResult -Check "PnP.PowerShell Module" -Passed $false `
        -Message "Error checking module: $_" `
        -Recommendation "Install-Module -Name PnP.PowerShell -Scope CurrentUser"
}

# =============================================================================
# Step 2: Security & Compliance PowerShell Connection
# =============================================================================

Write-CheckHeader "Security & Compliance Connection"

# Check if MSAL assemblies are already loaded (indicates we can't disable WAM anymore)
$msalLoaded = [System.AppDomain]::CurrentDomain.GetAssemblies() | 
    Where-Object { $_.FullName -like "*Microsoft.Identity.Client*" } | 
    Select-Object -First 1

if ($msalLoaded) {
    Write-Host "⚠️  MSAL assemblies already loaded in this session (WAM broker may be active)" -ForegroundColor Yellow
    Write-Host "   Attempting connection anyway..." -ForegroundColor Gray
}

# Check if cmdlets are available (indicates connection)
if (Get-Command Get-DlpEdmSchema -ErrorAction SilentlyContinue) {
    Write-CheckResult -Check "Security & Compliance Connection" -Passed $true -Message "Already connected"
} else {
    # Check for existing session
    $existingSession = Get-PSSession | Where-Object { 
        $_.ComputerName -like "*compliance.protection.outlook.com*" -and 
        $_.State -eq "Opened" 
    } | Select-Object -First 1
    
    if ($null -ne $existingSession) {
        Write-CheckResult -Check "Security & Compliance Connection" -Passed $true -Message "Existing session found (reusing)"
    } else {
        # Connect directly with interactive authentication
        Write-Host "📋 Connecting to Security & Compliance PowerShell..." -ForegroundColor Cyan
        Write-Host "   Using browser-based authentication" -ForegroundColor Gray
        
        try {
            # CRITICAL: Disable WAM broker BEFORE loading module (only works if MSAL not already loaded)
            if (-not $msalLoaded) {
                Write-Host "   🔧 Configuring authentication method (disabling WAM broker)..." -ForegroundColor Gray
                Remove-Module ExchangeOnlineManagement -Force -ErrorAction SilentlyContinue
                
                $env:AZURE_IDENTITY_DISABLE_MSALRUNTIME = "1"
                $env:MSAL_DISABLE_WAM = "1"
                [System.Environment]::SetEnvironmentVariable("AZURE_IDENTITY_DISABLE_MSALRUNTIME", "1", [System.EnvironmentVariableTarget]::Process)
                
                Import-Module ExchangeOnlineManagement -ErrorAction Stop
            } else {
                # MSAL already loaded, just ensure module is imported
                if (-not (Get-Module ExchangeOnlineManagement)) {
                    Import-Module ExchangeOnlineManagement -ErrorAction Stop
                }
            }
            
            Connect-IPPSSession -WarningAction SilentlyContinue -ErrorAction Stop
            Write-CheckResult -Check "Security & Compliance Connection" -Passed $true -Message "Connected successfully"
        } catch {
            Write-CheckResult -Check "Security & Compliance Connection" -Passed $false `
                -Message "Connection failed: $($_.Exception.Message)" `
                -Recommendation "Run .\Start-CleanPrerequisiteTest.ps1 instead to ensure fresh PowerShell session"
        }
    }
}

# =============================================================================
# Step 3: Audit Log Validation
# =============================================================================

Write-CheckHeader "Audit Log Validation"

try {
    # Note: Get-AdminAuditLogConfig requires Exchange Online connection
    # Connect-IPPSSession (Security & Compliance) sometimes returns stale data
    # For accurate results, we need Exchange Online connection
    
    # Check if we're connected to Exchange Online (not just IPPS)
    $exoConnection = Get-PSSession | Where-Object { 
        $_.ComputerName -like "*outlook.office365.com*" -and 
        $_.State -eq "Opened" 
    } | Select-Object -First 1
    
    if (-not $exoConnection) {
        Write-Host "   🔧 Audit log check requires Exchange Online connection..." -ForegroundColor Gray
        Write-Host "   🚀 Connecting to Exchange Online for accurate audit log status..." -ForegroundColor Cyan
        
        try {
            # Temporarily connect to Exchange Online (reuses existing auth)
            Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
        } catch {
            Write-WarningCheck -Check "Audit Log Validation" `
                -Message "Could not connect to Exchange Online to verify audit log"
            Write-Host "   💡 Run: 01-Day-Zero-Setup\scripts\Enable-AuditLogging.ps1 to verify manually" -ForegroundColor Yellow
            return
        }
    }
    
    $auditConfig = Get-AdminAuditLogConfig -ErrorAction Stop
    
    if ($auditConfig.UnifiedAuditLogIngestionEnabled -eq $true) {
        Write-CheckResult -Check "Unified Audit Log Enabled" -Passed $true -Message "Audit logging is active"
    } else {
        Write-Host "   🔍 Current status: UnifiedAuditLogIngestionEnabled = $($auditConfig.UnifiedAuditLogIngestionEnabled)" -ForegroundColor Gray
        Write-WarningCheck -Check "Unified Audit Log Enabled" `
            -Message "Audit log shows as disabled via Exchange Online connection"
        Write-Host "   💡 Run: 01-Day-Zero-Setup\scripts\Enable-AuditLogging.ps1 to enable" -ForegroundColor Yellow
        Write-Host "   💡 Note: Labs 03-04 can proceed without this (Custom SITs, EDM, Fingerprinting, Named Entities)" -ForegroundColor Cyan
    }
} catch {
    Write-WarningCheck -Check "Audit Log Validation" `
        -Message "Unable to check audit log status: $_"
}

# =============================================================================
# Step 4: Test Data Validation
# =============================================================================

Write-CheckHeader "Test Data Validation"

# Use the already loaded configuration from the top of the script
if ($configPath -and (Test-Path $configPath)) {
    try {
        # Use the TenantPrefix variable we extracted earlier
        $siteUrl = "https://$TenantPrefix.sharepoint.com/sites/Retail-Operations"
        
        Write-CheckResult -Check "Global Configuration File" -Passed $true -Message "Found at: $configPath"
        Write-Host "   SharePoint Site: $siteUrl" -ForegroundColor Gray
        
        # SharePoint validation using PnP App Registration
        if (Get-Module -ListAvailable -Name PnP.PowerShell) {
            Write-Host "`n🔍 Checking SharePoint site and test data..." -ForegroundColor Cyan
            try {
                # Load PnP Client ID from global config
                $configData = Get-Content $configPath -Raw | ConvertFrom-Json
                $pnpClientId = $configData.pnpClientId
                
                if ($pnpClientId) {
                    # Connect using PnP App Registration
                    Connect-PnPOnline -Url $siteUrl -Interactive -ClientId $pnpClientId -ErrorAction Stop
                    
                    # Get files from Documents library (where Lab 02 uploads test data)
                    $files = Get-PnPListItem -List "Documents" -ErrorAction Stop
                    $fileCount = ($files | Where-Object { $_.FileSystemObjectType -eq "File" }).Count
                    
                    if ($fileCount -ge 13) {
                        Write-CheckResult -Check "SharePoint Test Data" -Passed $true `
                            -Message "Found $fileCount files in Documents library (expected 13+ test files)"
                    } else {
                        Write-WarningCheck -Check "SharePoint Test Data" `
                            -Message "Found $fileCount files (expected at least 13 test files in Documents)"
                    }
                    
                    Disconnect-PnPOnline -ErrorAction SilentlyContinue
                } else {
                    Write-WarningCheck -Check "SharePoint Site Validation" `
                        -Message "pnpClientId not found in global-config.json"
                }
            } catch {
                Write-WarningCheck -Check "SharePoint Site Validation" `
                    -Message "Unable to connect or validate SharePoint site: $_"
            }
        }
    } catch {
        Write-WarningCheck -Check "Global Configuration File" `
            -Message "Error reading configuration: $_"
    }
} else {
    Write-CheckResult -Check "Global Configuration File" -Passed $false `
        -Message "File not found at: $configPath" `
        -Recommendation "Ensure templates\global-config.json exists in the project root"
}

# =============================================================================
# Step 5: Final Summary
# =============================================================================

Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  PREREQUISITE VALIDATION SUMMARY" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

if ($script:AllChecksPassed -and $script:Warnings.Count -eq 0) {
    Write-Host "`n✅ ALL PREREQUISITES MET!" -ForegroundColor Green
    Write-Host "`nYou are ready to proceed with the 03-Classification-UI lab." -ForegroundColor Cyan
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "  1. Review the lab README: 03-Classification-UI\README.md" -ForegroundColor White
    Write-Host "  2. Start with Lab 01: Create Custom SITs" -ForegroundColor White
    Write-Host "  3. Continue to Lab 02: Create EDM Classifiers" -ForegroundColor White
} elseif ($script:AllChecksPassed -and $script:Warnings.Count -gt 0) {
    Write-Host "`n⚠️  PREREQUISITES MET WITH WARNINGS" -ForegroundColor Yellow
    Write-Host "`nCritical checks passed, but the following items need attention:" -ForegroundColor Cyan
    foreach ($warning in $script:Warnings) {
        Write-Host "  • $warning" -ForegroundColor Yellow
    }
    Write-Host "`nYou can proceed with caution. Address warnings for best results." -ForegroundColor Cyan
} else {
    Write-Host "`n❌ PREREQUISITES NOT MET" -ForegroundColor Red
    Write-Host "`nPlease address the failed checks above before proceeding." -ForegroundColor Yellow
    Write-Host "`nRecommended Actions:" -ForegroundColor Cyan
    Write-Host "  1. Complete 00-Prerequisites setup" -ForegroundColor White
    Write-Host "  2. Complete 01-Day-Zero-Setup (audit log enablement)" -ForegroundColor White
    Write-Host "  3. Complete 02-Data-Foundation (test file generation)" -ForegroundColor White
    Write-Host "  4. Re-run this script: .\Test-LabPrerequisites.ps1" -ForegroundColor White
    
    exit 1
}

Write-Host "`n"
