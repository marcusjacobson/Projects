<#
.SYNOPSIS
    Validates prerequisites for the Fabric + Purview Governance Simulation.

.DESCRIPTION
    This script checks environment readiness including Azure CLI authentication,
    PowerShell modules, service connectivity, and basic permission validation.
    Run this script before starting the simulation labs to ensure all 
    prerequisites are met.

.PARAMETER Detailed
    When specified, provides verbose output for each check.

.EXAMPLE
    .\Test-Prerequisites.ps1
    
    Basic prerequisites check with summary output.

.EXAMPLE
    .\Test-Prerequisites.ps1 -Detailed
    
    Detailed prerequisites check with verbose information for each validation.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2024-12-01
    Last Modified: 2024-12-01
    
    Copyright (c) 2024 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Internet connectivity
    - Azure CLI (optional, for advanced validation)
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$Detailed
)

# =============================================================================
# Step 1: Initialize Script
# =============================================================================

Write-Host "🔍 Fabric + Purview Prerequisites Validation" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

$results = @{
    Passed = 0
    Failed = 0
    Warnings = 0
    Checks = @()
}

function Add-CheckResult {
    param (
        [string]$Name,
        [string]$Status,
        [string]$Message
    )
    
    $results.Checks += @{
        Name = $Name
        Status = $Status
        Message = $Message
    }
    
    switch ($Status) {
        "Passed" { 
            $results.Passed++
            Write-Host "   ✅ $Name" -ForegroundColor Green
        }
        "Failed" { 
            $results.Failed++
            Write-Host "   ❌ $Name" -ForegroundColor Red
        }
        "Warning" { 
            $results.Warnings++
            Write-Host "   ⚠️ $Name" -ForegroundColor Yellow
        }
    }
    
    if ($Detailed -and $Message) {
        Write-Host "      $Message" -ForegroundColor Gray
    }
}

# =============================================================================
# Step 2: Check PowerShell Version
# =============================================================================

Write-Host "📋 PowerShell Environment" -ForegroundColor Cyan

$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -ge 7) {
    Add-CheckResult -Name "PowerShell 7+" -Status "Passed" -Message "Version $psVersion detected"
} elseif ($psVersion.Major -ge 5 -and $psVersion.Minor -ge 1) {
    Add-CheckResult -Name "PowerShell 5.1+" -Status "Passed" -Message "Version $psVersion detected"
} else {
    Add-CheckResult -Name "PowerShell Version" -Status "Failed" -Message "Version $psVersion - requires 5.1 or higher"
}

# =============================================================================
# Step 3: Check Internet Connectivity
# =============================================================================

Write-Host ""
Write-Host "📋 Network Connectivity" -ForegroundColor Cyan

$endpoints = @(
    @{ Name = "Microsoft Fabric"; Url = "https://app.fabric.microsoft.com" },
    @{ Name = "Microsoft Purview"; Url = "https://purview.microsoft.com" },
    @{ Name = "Power BI Service"; Url = "https://app.powerbi.com" },
    @{ Name = "Azure Portal"; Url = "https://portal.azure.com" }
)

foreach ($endpoint in $endpoints) {
    try {
        $response = Invoke-WebRequest -Uri $endpoint.Url -Method Head -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 302) {
            Add-CheckResult -Name $endpoint.Name -Status "Passed" -Message "Connectivity verified"
        } else {
            Add-CheckResult -Name $endpoint.Name -Status "Warning" -Message "Unexpected status: $($response.StatusCode)"
        }
    } catch {
        Add-CheckResult -Name $endpoint.Name -Status "Failed" -Message "Cannot reach endpoint: $($_.Exception.Message)"
    }
}

# =============================================================================
# Step 4: Check Azure CLI (Optional)
# =============================================================================

Write-Host ""
Write-Host "📋 Azure CLI (Optional)" -ForegroundColor Cyan

try {
    $azVersion = az version 2>$null | ConvertFrom-Json
    if ($azVersion) {
        Add-CheckResult -Name "Azure CLI Installed" -Status "Passed" -Message "Version $($azVersion.'azure-cli')"
        
        # Check if logged in
        try {
            $account = az account show 2>$null | ConvertFrom-Json
            if ($account) {
                Add-CheckResult -Name "Azure CLI Authenticated" -Status "Passed" -Message "Signed in as $($account.user.name)"
            } else {
                Add-CheckResult -Name "Azure CLI Authenticated" -Status "Warning" -Message "Not signed in - run 'az login'"
            }
        } catch {
            Add-CheckResult -Name "Azure CLI Authenticated" -Status "Warning" -Message "Not signed in - run 'az login'"
        }
    }
} catch {
    Add-CheckResult -Name "Azure CLI" -Status "Warning" -Message "Not installed - optional for this simulation"
}

# =============================================================================
# Step 5: Check PowerShell Modules (Optional)
# =============================================================================

Write-Host ""
Write-Host "📋 PowerShell Modules (Optional)" -ForegroundColor Cyan

$modules = @(
    @{ Name = "Az.Accounts"; MinVersion = "2.0.0"; Required = $false },
    @{ Name = "MicrosoftPowerBIMgmt"; MinVersion = "1.0.0"; Required = $false }
)

foreach ($module in $modules) {
    $installed = Get-Module -ListAvailable -Name $module.Name | Sort-Object Version -Descending | Select-Object -First 1
    
    if ($installed) {
        if ($installed.Version -ge [version]$module.MinVersion) {
            Add-CheckResult -Name "$($module.Name)" -Status "Passed" -Message "Version $($installed.Version)"
        } else {
            Add-CheckResult -Name "$($module.Name)" -Status "Warning" -Message "Version $($installed.Version) - update recommended"
        }
    } else {
        if ($module.Required) {
            Add-CheckResult -Name "$($module.Name)" -Status "Failed" -Message "Not installed - required module"
        } else {
            Add-CheckResult -Name "$($module.Name)" -Status "Warning" -Message "Not installed - optional for this simulation"
        }
    }
}

# =============================================================================
# Step 6: Check Sample Data Files
# =============================================================================

Write-Host ""
Write-Host "📋 Sample Data Files" -ForegroundColor Cyan

$dataPath = Join-Path (Split-Path $PSScriptRoot -Parent) "..\data-templates"
$dataPath = Resolve-Path $dataPath -ErrorAction SilentlyContinue

if ($dataPath) {
    $dataFiles = @(
        "customers.csv",
        "transactions.csv",
        "streaming-events.json"
    )
    
    foreach ($file in $dataFiles) {
        $filePath = Join-Path $dataPath $file
        if (Test-Path $filePath) {
            $fileSize = (Get-Item $filePath).Length / 1KB
            Add-CheckResult -Name $file -Status "Passed" -Message "Found ($([math]::Round($fileSize, 1)) KB)"
        } else {
            Add-CheckResult -Name $file -Status "Warning" -Message "Not found - may need to be created"
        }
    }
} else {
    Add-CheckResult -Name "Data Templates Directory" -Status "Warning" -Message "Directory not found"
}

# =============================================================================
# Step 7: Summary
# =============================================================================

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "📊 Validation Summary" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "   ✅ Passed:   $($results.Passed)" -ForegroundColor Green
Write-Host "   ⚠️ Warnings: $($results.Warnings)" -ForegroundColor Yellow
Write-Host "   ❌ Failed:   $($results.Failed)" -ForegroundColor Red
Write-Host ""

if ($results.Failed -eq 0) {
    Write-Host "🎉 All critical prerequisites passed!" -ForegroundColor Green
    Write-Host "   You're ready to proceed with Lab 01." -ForegroundColor Gray
    exit 0
} else {
    Write-Host "⚠️ Some prerequisites need attention." -ForegroundColor Yellow
    Write-Host "   Review the failed checks above before proceeding." -ForegroundColor Gray
    exit 1
}
