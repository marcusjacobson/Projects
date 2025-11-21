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
    
    Script development orchestrated using GitHub Copilot.
#>

$ErrorActionPreference = "Stop"

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
