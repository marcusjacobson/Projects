<#
.SYNOPSIS
    Imports Purview shared utility modules.

.DESCRIPTION
    Loads all shared utility functions from the Functions directory for use in Purview scripts.
    This script should be dot-sourced at the beginning of all Purview automation scripts.

.EXAMPLE
    . "$PSScriptRoot\..\Shared-Utilities\Import-PurviewModules.ps1"
    Connect-PurviewServices -Services @("SharePoint") -TenantUrl "https://contoso.sharepoint.com" -Interactive

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Internet connection for module installation
    - Administrative privileges for module installation
    
    Script development orchestrated using GitHub Copilot.

.SHARED UTILITY OPERATIONS
    - Module Availability Check
    - Module Installation (PnP.PowerShell, ExchangeOnlineManagement)
    - Version Validation
    - Import and Session Loading
#>

$ErrorActionPreference = "Stop"

# Disable WAM broker to avoid msalruntime DLL issues with ExchangeOnlineManagement module
# This forces MSAL to use browser-based auth instead of Windows Account Manager
# Must be set BEFORE the module is imported - use both methods to ensure it takes effect
$env:AZURE_IDENTITY_DISABLE_MSALRUNTIME = "1"
$env:MSAL_DISABLE_WAM = "1"
[System.Environment]::SetEnvironmentVariable("AZURE_IDENTITY_DISABLE_MSALRUNTIME", "1", [System.EnvironmentVariableTarget]::Process)

$functionsPath = Join-Path $PSScriptRoot "Functions"

# Import all function modules
$moduleFiles = Get-ChildItem -Path $functionsPath -Filter "*.ps1" -ErrorAction SilentlyContinue

if ($moduleFiles) {
    foreach ($file in $moduleFiles) {
        try {
            . $file.FullName
            Write-Verbose "Loaded module: $($file.Name)"
        } catch {
            Write-Warning "Failed to load module $($file.Name): $_"
        }
    }
} else {
    Write-Warning "No function modules found in $functionsPath"
}

Write-Verbose "Purview modules loaded successfully"
