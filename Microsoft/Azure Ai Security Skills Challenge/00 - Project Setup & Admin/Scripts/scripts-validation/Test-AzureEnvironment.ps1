<#
.SYNOPSIS
    Validates Azure development environment installation.

.DESCRIPTION
    Comprehensive validation script for Azure development tools including Azure CLI,
    PowerShell 7+, Azure PowerShell modules, Visual Studio Code, Bicep CLI, and
    Azure authentication status. Provides clear output for troubleshooting and
    verification of proper installation.

.PARAMETER DetailedReport
    Shows additional details about installed components and versions.

.PARAMETER QuietMode
    Suppresses colored output for use in automation or logging scenarios.

.EXAMPLE
    .\Test-AzureEnvironment.ps1
    
    Run basic environment validation with standard output.

.EXAMPLE
    .\Test-AzureEnvironment.ps1 -DetailedReport
    
    Run comprehensive validation with additional details about each component.

.EXAMPLE
    .\Test-AzureEnvironment.ps1 -QuietMode
    
    Run validation without colored output for logging or automation.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-09-05
    Last Modified: 2025-09-05
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 7+ for optimal functionality
    - Azure development tools installed
    - Appropriate permissions for Azure CLI and PowerShell commands
    
    Script development orchestrated using GitHub Copilot.

.VALIDATION_COMPONENTS
    - PowerShell version and compatibility
    - Azure CLI installation and version
    - Azure PowerShell modules availability
    - Visual Studio Code installation and PATH
    - Bicep CLI functionality
    - Azure authentication status for both CLI and PowerShell
#>

#
# =============================================================================
# Azure development environment validation and testing script.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$DetailedReport,
    
    [Parameter(Mandatory = $false)]
    [switch]$QuietMode
)

# =============================================================================
# Step 1: Initialize Validation
# =============================================================================

if (-not $QuietMode) {
    Write-Host "=== Azure Development Environment Validation ===" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host ""
}

$validationResults = @()

# =============================================================================
# Step 2: PowerShell Version Validation
# =============================================================================

if (-not $QuietMode) {
    Write-Host "PowerShell Version:" -ForegroundColor Cyan
}

try {
    $psVersion = $PSVersionTable.PSVersion
    if (-not $QuietMode) {
        Write-Host "   $psVersion" -ForegroundColor White
    }
    
    if ($psVersion.Major -ge 7) {
        $validationResults += [PSCustomObject]@{
            Component = "PowerShell"
            Status = "✅ PASS"
            Version = $psVersion.ToString()
            Details = "PowerShell 7+ detected"
        }
    } else {
        $validationResults += [PSCustomObject]@{
            Component = "PowerShell"
            Status = "⚠️ WARNING"
            Version = $psVersion.ToString()
            Details = "PowerShell 5.1 detected - PowerShell 7+ recommended"
        }
    }
} catch {
    $validationResults += [PSCustomObject]@{
        Component = "PowerShell"
        Status = "❌ FAIL"
        Version = "Unknown"
        Details = "PowerShell version check failed: $_"
    }
}

# =============================================================================
# Step 3: Azure CLI Validation
# =============================================================================

if (-not $QuietMode) {
    Write-Host "`nAzure CLI Version:" -ForegroundColor Cyan
}

try {
    $azVersion = az --version 2>$null | Select-String "azure-cli"
    if ($azVersion -and $LASTEXITCODE -eq 0) {
        $versionString = $azVersion.ToString().Trim()
        if (-not $QuietMode) {
            Write-Host "   $versionString" -ForegroundColor White
        }
        
        $validationResults += [PSCustomObject]@{
            Component = "Azure CLI"
            Status = "✅ PASS"
            Version = $versionString.Split()[1]
            Details = "Azure CLI available and functional"
        }
    } else {
        throw "Azure CLI not available or not responding"
    }
} catch {
    if (-not $QuietMode) {
        Write-Host "   ❌ Azure CLI not available" -ForegroundColor Red
    }
    
    $validationResults += [PSCustomObject]@{
        Component = "Azure CLI"
        Status = "❌ FAIL"
        Version = "Not installed"
        Details = "Azure CLI not found or not responding"
    }
}

# =============================================================================
# Step 4: Azure PowerShell Modules Validation
# =============================================================================

if (-not $QuietMode) {
    Write-Host "`nAzure PowerShell Modules:" -ForegroundColor Cyan
}

try {
    $azModule = Get-Module Az -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    if ($azModule) {
        if (-not $QuietMode) {
            Write-Host "   Az Module: $($azModule.Version)" -ForegroundColor White
        }
        
        $validationResults += [PSCustomObject]@{
            Component = "Az PowerShell Module"
            Status = "✅ PASS"
            Version = $azModule.Version.ToString()
            Details = "Az module available"
        }
        
        # Check for security modules if detailed report requested
        if ($DetailedReport) {
            $securityModules = @('Az.Security', 'Az.SecurityInsights', 'Az.CognitiveServices', 'Az.OperationalInsights')
            foreach ($module in $securityModules) {
                $moduleInfo = Get-Module $module -ListAvailable | Select-Object -First 1
                if ($moduleInfo) {
                    if (-not $QuietMode) {
                        Write-Host "   ${module}: $($moduleInfo.Version)" -ForegroundColor White
                    }
                    
                    $validationResults += [PSCustomObject]@{
                        Component = $module
                        Status = "✅ PASS"
                        Version = $moduleInfo.Version.ToString()
                        Details = "Security module available"
                    }
                } else {
                    if (-not $QuietMode) {
                        Write-Host "   ${module}: Not installed" -ForegroundColor Yellow
                    }
                    
                    $validationResults += [PSCustomObject]@{
                        Component = $module
                        Status = "⚠️ OPTIONAL"
                        Version = "Not installed"
                        Details = "Optional security module not found"
                    }
                }
            }
        }
    } else {
        throw "Az module not found"
    }
} catch {
    if (-not $QuietMode) {
        Write-Host "   ❌ Az PowerShell modules not available" -ForegroundColor Red
    }
    
    $validationResults += [PSCustomObject]@{
        Component = "Az PowerShell Module"
        Status = "❌ FAIL"
        Version = "Not installed"
        Details = "Az PowerShell module not found"
    }
}

# =============================================================================
# Step 5: Visual Studio Code Validation
# =============================================================================

if (-not $QuietMode) {
    Write-Host "`nVS Code Version:" -ForegroundColor Cyan
}

try {
    $vscodeVersion = code --version 2>$null | Select-Object -First 1
    if ($vscodeVersion -and $LASTEXITCODE -eq 0) {
        if (-not $QuietMode) {
            Write-Host "   $vscodeVersion" -ForegroundColor White
        }
        
        $validationResults += [PSCustomObject]@{
            Component = "Visual Studio Code"
            Status = "✅ PASS"
            Version = $vscodeVersion
            Details = "VS Code available in PATH"
        }
        
        # Check for Azure extensions if detailed report requested
        if ($DetailedReport) {
            $azureExtensions = @(
                'ms-vscode.azure-account',
                'ms-azuretools.azure-cli-tools',
                'ms-azuretools.vscode-azureresourcegroups',
                'ms-azuretools.vscode-bicep',
                'ms-vscode.powershell',
                'redhat.vscode-yaml'
            )
            
            $installedExtensions = code --list-extensions 2>$null
            if ($installedExtensions) {
                foreach ($ext in $azureExtensions) {
                    if ($installedExtensions -contains $ext) {
                        if (-not $QuietMode) {
                            Write-Host "   Extension ${ext}: Installed" -ForegroundColor White
                        }
                        
                        $validationResults += [PSCustomObject]@{
                            Component = "VS Code Extension: $ext"
                            Status = "✅ PASS"
                            Version = "Installed"
                            Details = "Azure extension available"
                        }
                    } else {
                        if (-not $QuietMode) {
                            Write-Host "   Extension ${ext}: Not installed" -ForegroundColor Yellow
                        }
                        
                        $validationResults += [PSCustomObject]@{
                            Component = "VS Code Extension: $ext"
                            Status = "⚠️ MISSING"
                            Version = "Not installed"
                            Details = "Recommended Azure extension not found"
                        }
                    }
                }
            }
        }
    } else {
        throw "VS Code not available in PATH"
    }
} catch {
    if (-not $QuietMode) {
        Write-Host "   ❌ VS Code not available in PATH" -ForegroundColor Red
    }
    
    $validationResults += [PSCustomObject]@{
        Component = "Visual Studio Code"
        Status = "❌ FAIL"
        Version = "Not in PATH"
        Details = "VS Code not found or not in PATH"
    }
}

# =============================================================================
# Step 6: Bicep CLI Validation
# =============================================================================

if (-not $QuietMode) {
    Write-Host "`nBicep CLI Version:" -ForegroundColor Cyan
}

try {
    $bicepVersion = az bicep version 2>$null
    if ($bicepVersion -and $LASTEXITCODE -eq 0) {
        if (-not $QuietMode) {
            Write-Host "   $bicepVersion" -ForegroundColor White
        }
        
        $validationResults += [PSCustomObject]@{
            Component = "Bicep CLI"
            Status = "✅ PASS"
            Version = $bicepVersion.Trim()
            Details = "Bicep CLI available via Azure CLI"
        }
    } else {
        throw "Bicep CLI not available"
    }
} catch {
    if (-not $QuietMode) {
        Write-Host "   ❌ Bicep CLI not available" -ForegroundColor Red
    }
    
    $validationResults += [PSCustomObject]@{
        Component = "Bicep CLI"
        Status = "❌ FAIL"
        Version = "Not installed"
        Details = "Bicep CLI not found - install via 'az bicep install'"
    }
}

# =============================================================================
# Step 7: Azure Authentication Status
# =============================================================================

if (-not $QuietMode) {
    Write-Host "`nAzure Authentication Status:" -ForegroundColor Cyan
}

# Check Azure CLI authentication
try {
    $azAccount = az account show --query name -o tsv 2>$null
    if ($azAccount -and $LASTEXITCODE -eq 0) {
        if (-not $QuietMode) {
            Write-Host "   Azure CLI: Connected to '$azAccount'" -ForegroundColor White
        }
        
        $validationResults += [PSCustomObject]@{
            Component = "Azure CLI Authentication"
            Status = "✅ AUTHENTICATED"
            Version = "Connected"
            Details = "Connected to subscription: $azAccount"
        }
    } else {
        throw "Azure CLI not authenticated"
    }
} catch {
    if (-not $QuietMode) {
        Write-Host "   ⚠️ Azure CLI: Not authenticated" -ForegroundColor Yellow
    }
    
    $validationResults += [PSCustomObject]@{
        Component = "Azure CLI Authentication"
        Status = "⚠️ NOT AUTH"
        Version = "Not authenticated"
        Details = "Run 'az login' to authenticate"
    }
}

# Check PowerShell Azure authentication
try {
    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if ($azContext) {
        if (-not $QuietMode) {
            Write-Host "   PowerShell Az: Connected as '$($azContext.Account.Id)'" -ForegroundColor White
        }
        
        $validationResults += [PSCustomObject]@{
            Component = "PowerShell Azure Authentication"
            Status = "✅ AUTHENTICATED"
            Version = "Connected"
            Details = "Connected as: $($azContext.Account.Id)"
        }
    } else {
        throw "PowerShell Azure not authenticated"
    }
} catch {
    if (-not $QuietMode) {
        Write-Host "   ⚠️ PowerShell Az: Not authenticated" -ForegroundColor Yellow
    }
    
    $validationResults += [PSCustomObject]@{
        Component = "PowerShell Azure Authentication"
        Status = "⚠️ NOT AUTH"
        Version = "Not authenticated"
        Details = "Run 'Connect-AzAccount' to authenticate"
    }
}

# =============================================================================
# Step 8: Summary and Results
# =============================================================================

if (-not $QuietMode) {
    Write-Host "`n=== Validation Summary ===" -ForegroundColor Green
}

$passCount = ($validationResults | Where-Object { $_.Status -like "*PASS*" -or $_.Status -like "*AUTHENTICATED*" }).Count
$warnCount = ($validationResults | Where-Object { $_.Status -like "*WARNING*" -or $_.Status -like "*NOT AUTH*" -or $_.Status -like "*MISSING*" -or $_.Status -like "*OPTIONAL*" }).Count
$failCount = ($validationResults | Where-Object { $_.Status -like "*FAIL*" }).Count

if (-not $QuietMode) {
    Write-Host "✅ Passed: $passCount" -ForegroundColor Green
    Write-Host "⚠️ Warnings: $warnCount" -ForegroundColor Yellow
    Write-Host "❌ Failed: $failCount" -ForegroundColor Red
    Write-Host ""
}

# Display detailed results if requested
if ($DetailedReport) {
    if (-not $QuietMode) {
        Write-Host "=== Detailed Results ===" -ForegroundColor Green
        $validationResults | Format-Table -AutoSize
    } else {
        $validationResults | Format-Table -AutoSize
    }
}

# =============================================================================
# Step 9: Recommendations
# =============================================================================

if (-not $QuietMode) {
    Write-Host "=== Recommendations ===" -ForegroundColor Green
    
    if ($failCount -gt 0) {
        Write-Host "🔧 Installation Issues Found:" -ForegroundColor Red
        $failedComponents = $validationResults | Where-Object { $_.Status -like "*FAIL*" }
        foreach ($component in $failedComponents) {
            Write-Host "   • $($component.Component): $($component.Details)" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    if ($warnCount -gt 0) {
        Write-Host "⚠️ Authentication or Optional Components:" -ForegroundColor Yellow
        $warnComponents = $validationResults | Where-Object { $_.Status -like "*WARNING*" -or $_.Status -like "*NOT AUTH*" }
        foreach ($component in $warnComponents) {
            Write-Host "   • $($component.Component): $($component.Details)" -ForegroundColor Cyan
        }
        Write-Host ""
    }
    
    if ($failCount -eq 0 -and $warnCount -le 2) {
        Write-Host "🎉 Your Azure development environment looks great!" -ForegroundColor Green
        Write-Host "Ready for the Azure AI Security Skills Challenge!" -ForegroundColor Green
    }
}

# Exit with appropriate code
if ($failCount -gt 0) {
    exit 1
} elseif ($warnCount -gt 3) {
    exit 2
} else {
    exit 0
}
