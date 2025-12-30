<#
.SYNOPSIS
    Resets the global configuration file to its generic template state.

.DESCRIPTION
    This script restores the 'templates\global-config.json' file from the 'templates\global-config.template.json'
    template. This is useful for cleaning up the environment after completing the masterclass or when preparing
    the repository for a new user.

    It overwrites any custom values (Tenant ID, Subscription ID, etc.) in global-config.json with the
    generic placeholders.

.EXAMPLE
    .\Reset-GlobalConfig.ps1
    
    Standard usage.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-28
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param ()

# =============================================================================
# Step 1: Initialization
# =============================================================================

Write-Host "📋 Step 1: Initialization" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

$templatePath = Join-Path $PSScriptRoot "..\templates\global-config.template.json"
$configPath = Join-Path $PSScriptRoot "..\templates\global-config.json"

# =============================================================================
# Step 2: Verify Template Existence
# =============================================================================

Write-Host "`n🔍 Step 2: Verify Template Existence" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

if (-not (Test-Path $templatePath)) {
    Write-Host "❌ Template file not found at: $templatePath" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Template file found." -ForegroundColor Cyan

# =============================================================================
# Step 3: Reset Configuration
# =============================================================================

Write-Host "`n🔄 Step 3: Reset Configuration" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

try {
    Copy-Item -Path $templatePath -Destination $configPath -Force
    Write-Host "   ✅ global-config.json has been reset to generic values." -ForegroundColor Cyan
}
catch {
    Write-Host "   ❌ Failed to reset configuration: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n✨ Cleanup Complete." -ForegroundColor Green
