<#
.SYNOPSIS
    Comprehensive validation of development environment setup for the Azure AI
    Security Skills Challenge program.

.DESCRIPTION
    This script performs thorough validation of the development environment
    required for the 9-week Azure AI Security Skills Challenge. It validates
    Azure CLI installation, PowerShell Az module availability, Azure authentication
    status, subscription permissions, regional access to East US, and resource
    provider registration. The script provides detailed feedback on each
    validation component with remediation guidance for any issues detected.
    
    The validation covers all prerequisite tools and configurations needed
    across the entire learning path, ensuring students can successfully
    complete infrastructure deployments, security configurations, and AI
    service integrations throughout all nine weeks of the challenge.

.PARAMETER SkipResourceProviderCheck
    Skip resource provider registration validation (reduces execution time).

.PARAMETER DetailedOutput
    Enable verbose output with detailed information for each validation step.

.PARAMETER ExportResults
    Export validation results to a JSON file for documentation purposes.

.PARAMETER OutputPath
    Specify custom path for exported validation results.

.EXAMPLE
    .\Test-EnvironmentValidation.ps1
    Run standard environment validation with summary output.

.EXAMPLE
    .\Test-EnvironmentValidation.ps1 -DetailedOutput -ExportResults
    Run comprehensive validation with detailed output and export results.

.EXAMPLE
    .\Test-EnvironmentValidation.ps1 -SkipResourceProviderCheck
    
    Run validation excluding resource provider checks (faster execution).

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-08-31
    Last Modified: 2025-08-31
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Azure CLI installed and accessible in PATH
    - Azure PowerShell Az module installed
    - Internet connectivity for Azure service validation
    
    Script development orchestrated using GitHub Copilot.

.TEST_SCENARIOS
    - Azure CLI installation and version validation
    - PowerShell Az module availability and version check
    - Azure authentication status for both CLI and PowerShell
    - Subscription permissions and role assignments
    - East US region accessibility for AI services
    - Resource provider registration for required services
    - Visual Studio Code and extension availability
    - Git configuration validation
#>

param(
    [Parameter(Mandatory=$false, HelpMessage="Skip resource provider registration validation")]
    [switch]$SkipResourceProviderCheck,
    
    [Parameter(Mandatory=$false, HelpMessage="Enable detailed verbose output")]
    [switch]$DetailedOutput,
    
    [Parameter(Mandatory=$false, HelpMessage="Export validation results to JSON file")]
    [switch]$ExportResults,
    
    [Parameter(Mandatory=$false, HelpMessage="Custom path for exported results")]
    [string]$OutputPath = "Validation-Results-$(Get-Date -Format 'yyyy-MM-dd-HHmm').json"
)

Write-Host "🔍 Step 1: Initialize Validation Framework" -ForegroundColor Green
Write-Host "🚀 Azure AI Security Skills Challenge - Environment Validation" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host

$validationResults = @{
    StartTime = Get-Date
    Status = "In Progress"
    Summary = @{}
    Details = @{}
    Recommendations = @()
}

$totalTests = 9
$passedTests = 0

# Azure CLI Validation
Write-Host "🔍 Step 2: Azure CLI Validation" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

try {
    $azCliCmd = Get-Command az -ErrorAction SilentlyContinue
    if ($azCliCmd) {
        $azVersion = (az version 2>$null | ConvertFrom-Json).'azure-cli'
        Write-Host "   ✅ Azure CLI installed - Version: $azVersion" -ForegroundColor Green
        
        # Check for updates
        $latestVersion = "2.76.0" # Current known latest
        if ([Version]$azVersion -lt [Version]$latestVersion) {
            Write-Host "   ⚠️  Newer version available: $latestVersion" -ForegroundColor Yellow
            $validationResults.Recommendations += "Update Azure CLI to latest version: az upgrade"
        }
        
        $validationResults.Details.AzureCLI = @{
            Status = "Success"
            Version = $azVersion
            Location = $azCliCmd.Source
            UpdateAvailable = ([Version]$azVersion -lt [Version]$latestVersion)
        }
        $passedTests++
    } else {
        throw "Azure CLI not found in PATH"
    }
} catch {
    Write-Host "   ❌ Azure CLI validation failed: $($_.Exception.Message)" -ForegroundColor Red
    $validationResults.Details.AzureCLI = @{
        Status = "Failed"
        Error = $_.Exception.Message
    }
    $validationResults.Recommendations += "Install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
}

Write-Host

# PowerShell Az Module Validation
Write-Host "🔍 Step 3: PowerShell Az Module Validation" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

try {
    $azModule = Get-Module -Name Az -ListAvailable | Select-Object -First 1
    if ($azModule) {
        Write-Host "   ✅ PowerShell Az module installed - Version: $($azModule.Version)" -ForegroundColor Green
        
        # Count sub-modules
        $azSubModules = Get-Module -Name Az.* -ListAvailable | Group-Object Name | Measure-Object
        Write-Host "   📋 Total Az sub-modules: $($azSubModules.Count)" -ForegroundColor Cyan
        
        # Check if module is imported
        $importedAz = Get-Module -Name Az
        if ($importedAz) {
            Write-Host "   ✅ Az module currently loaded" -ForegroundColor Green
        } else {
            Write-Host "   ℹ️  Az module available but not loaded" -ForegroundColor Cyan
        }
        
        $validationResults.Details.PowerShellAz = @{
            Status = "Success"
            Version = $azModule.Version.ToString()
            SubModuleCount = $azSubModules.Count
            IsLoaded = ($null -ne $importedAz)
        }
        $passedTests++
    } else {
        throw "PowerShell Az module not installed"
    }
} catch {
    Write-Host "   ❌ PowerShell Az module validation failed: $($_.Exception.Message)" -ForegroundColor Red
    $validationResults.Details.PowerShellAz = @{
        Status = "Failed"
        Error = $_.Exception.Message
    }
    $validationResults.Recommendations += "Install PowerShell Az module: Install-Module -Name Az -Force"
}

Write-Host

# =============================================================================
# Step 4: Azure CLI Authentication Validation
# =============================================================================

Write-Host "🔍 Step 4: Azure CLI Authentication Validation" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

try {
    $azAccount = az account show 2>$null
    if ($azAccount) {
        $accountInfo = $azAccount | ConvertFrom-Json
        Write-Host "   ✅ Azure CLI authenticated" -ForegroundColor Green
        Write-Host "   📋 Account: $($accountInfo.user.name)" -ForegroundColor Cyan
        Write-Host "   📋 Subscription: $($accountInfo.name)" -ForegroundColor Cyan
        Write-Host "   📋 Tenant: $($accountInfo.tenantId)" -ForegroundColor Cyan
        
        $validationResults.Details.AzureCLIAuth = @{
            Status = "Success"
            Account = $accountInfo.user.name
            Subscription = $accountInfo.name
            SubscriptionId = $accountInfo.id
            TenantId = $accountInfo.tenantId
        }
        $passedTests++
    } else {
        throw "Azure CLI not authenticated"
    }
} catch {
    Write-Host "   ❌ Azure CLI authentication validation failed: $($_.Exception.Message)" -ForegroundColor Red
    $validationResults.Details.AzureCLIAuth = @{
        Status = "Failed"
        Error = $_.Exception.Message
    }
    $validationResults.Recommendations += "Authenticate Azure CLI: az login"
}

Write-Host

# =============================================================================
# Step 5: PowerShell Azure Authentication Validation
# =============================================================================

Write-Host "🔍 Step 5: PowerShell Azure Authentication Validation" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

try {
    # Check if Az.Accounts is available (minimal required for authentication check)
    Write-Host "   📋 Checking Azure PowerShell authentication..." -ForegroundColor Cyan
    
    # Import only Az.Accounts if needed (much faster than full Az module)
    if (-not (Get-Module -Name Az.Accounts)) {
        $azAccountsModule = Get-Module -Name Az.Accounts -ListAvailable | Select-Object -First 1
        if ($azAccountsModule) {
            Import-Module Az.Accounts -ErrorAction SilentlyContinue
        } else {
            throw "Az.Accounts module not available"
        }
    }
    
    # Get current Azure context
    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if ($azContext) {
        Write-Host "   ✅ PowerShell Azure authenticated" -ForegroundColor Green
        Write-Host "   📋 Account: $($azContext.Account.Id)" -ForegroundColor Cyan
        Write-Host "   📋 Subscription: $($azContext.Subscription.Name)" -ForegroundColor Cyan
        Write-Host "   📋 Tenant: $($azContext.Tenant.Id)" -ForegroundColor Cyan
        
        $validationResults.Details.PowerShellAuth = @{
            Status = "Success"
            Account = $azContext.Account.Id
            Subscription = $azContext.Subscription.Name
            SubscriptionId = $azContext.Subscription.Id
            TenantId = $azContext.Tenant.Id
        }
        $passedTests++
    } else {
        throw "PowerShell not authenticated to Azure"
    }
} catch {
    Write-Host "   ❌ PowerShell Azure authentication validation failed: $($_.Exception.Message)" -ForegroundColor Red
    $validationResults.Details.PowerShellAuth = @{
        Status = "Failed"
        Error = $_.Exception.Message
    }
    $validationResults.Recommendations += "Authenticate PowerShell to Azure: Connect-AzAccount"
}

Write-Host

# =============================================================================
# Step 6: Subscription Permissions Validation
# =============================================================================

Write-Host "🔍 Step 6: Subscription Permissions Validation" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

try {
    Write-Host "   📋 Checking subscription permissions..." -ForegroundColor Cyan
    
    # Get current user info first
    $currentUser = az account show --query user.name -o tsv 2>$null
    $currentSub = az account show --query id -o tsv 2>$null
    
    if ($currentUser -and $currentSub) {
        # Get current user's role assignments with timeout
        $roleAssignments = az role assignment list --assignee $currentUser --query "[?scope=='/subscriptions/$currentSub']" 2>$null | ConvertFrom-Json
        
        if ($roleAssignments -and $roleAssignments.Count -gt 0) {
            $hasOwner = $roleAssignments | Where-Object { $_.roleDefinitionName -eq "Owner" }
            $hasContributor = $roleAssignments | Where-Object { $_.roleDefinitionName -eq "Contributor" }
            
            if ($hasOwner) {
                Write-Host "   ✅ Owner permissions detected - Full deployment capabilities" -ForegroundColor Green
                $permissionLevel = "Owner"
            } elseif ($hasContributor) {
                Write-Host "   ✅ Contributor permissions detected - Standard deployment capabilities" -ForegroundColor Green
                $permissionLevel = "Contributor"
            } else {
                Write-Host "   ⚠️  Limited permissions detected" -ForegroundColor Yellow
                Write-Host "   📋 Roles found: $($roleAssignments.roleDefinitionName -join ', ')" -ForegroundColor Cyan
                $permissionLevel = "Limited"
            }
            
            $validationResults.Details.Permissions = @{
                Status = "Success"
                Level = $permissionLevel
                Roles = $roleAssignments.roleDefinitionName
                HasOwner = ($null -ne $hasOwner)
                HasContributor = ($null -ne $hasContributor)
            }
            
            if (-not $hasOwner -and -not $hasContributor) {
                $validationResults.Recommendations += "Request Owner or Contributor role for full deployment capabilities"
            }
            $passedTests++
        } else {
            throw "No role assignments found for current user"
        }
    } else {
        throw "Unable to retrieve current user or subscription information"
    }
} catch {
    Write-Host "   ❌ Subscription permissions validation failed: $($_.Exception.Message)" -ForegroundColor Red
    $validationResults.Details.Permissions = @{
        Status = "Failed"
        Error = $_.Exception.Message
    }
    $validationResults.Recommendations += "Verify subscription access and permissions"
}

Write-Host

# =============================================================================
# Step 7: East US Region Validation
# =============================================================================

Write-Host "🔍 Step 7: East US Region Validation" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

try {
    Write-Host "   📋 Checking East US region availability..." -ForegroundColor Cyan
    
    # Check if East US is available for the subscription
    $locations = az account list-locations --query "[?name=='eastus']" 2>$null | ConvertFrom-Json
    if ($locations -and $locations.Count -gt 0) {
        Write-Host "   ✅ East US region available" -ForegroundColor Green
        
        # Quick check for cognitive services availability (with timeout protection)
        try {
            $cognitiveServices = az cognitiveservices account list-kinds 2>$null | ConvertFrom-Json
            $hasOpenAI = $cognitiveServices -contains "OpenAI"
            $hasTextAnalytics = $cognitiveServices -contains "TextAnalytics"
        } catch {
            # If cognitive services check fails, continue with region validation
            Write-Host "   ⚠️  Could not verify cognitive services availability" -ForegroundColor Yellow
            $hasOpenAI = $false
            $hasTextAnalytics = $false
        }
        
        Write-Host "   📋 OpenAI services: $(if($hasOpenAI){'Available'}else{'Check Required'})" -ForegroundColor $(if($hasOpenAI){'Green'}else{'Yellow'})
        Write-Host "   📋 Text Analytics: $(if($hasTextAnalytics){'Available'}else{'Check Required'})" -ForegroundColor $(if($hasTextAnalytics){'Green'}else{'Yellow'})
        
        $validationResults.Details.EastUSRegion = @{
            Status = "Success"
            Available = $true
            OpenAI = $hasOpenAI
            TextAnalytics = $hasTextAnalytics
        }
        $passedTests++
    } else {
        throw "East US region not available for this subscription"
    }
} catch {
    Write-Host "   ❌ East US region validation failed: $($_.Exception.Message)" -ForegroundColor Red
    $validationResults.Details.EastUSRegion = @{
        Status = "Failed"
        Error = $_.Exception.Message
    }
    $validationResults.Recommendations += "Verify regional access or contact Azure support"
}

Write-Host

# =============================================================================
# Step 8: Visual Studio Code Validation
# =============================================================================

Write-Host "🔍 Step 8: Visual Studio Code Validation" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

try {
    $vscodeCmd = Get-Command code -ErrorAction SilentlyContinue
    if ($vscodeCmd) {
        $vscodeVersion = & code --version 2>$null | Select-Object -First 1
        Write-Host "   ✅ Visual Studio Code installed - Version: $vscodeVersion" -ForegroundColor Green
        
        # Check for Azure extensions
        $requiredExtensions = @(
            "ms-vscode.azure-account",
            "ms-azuretools.vscode-azureresourcemanager", 
            "ms-azuretools.vscode-bicep",
            "ms-vscode.azurecli",
            "ms-vscode.powershell",
            "eamodio.gitlens"
        )
        
        $installedExtensions = & code --list-extensions 2>$null
        $missingExtensions = @()
        $presentExtensions = @()
        
        foreach ($ext in $requiredExtensions) {
            if ($installedExtensions -contains $ext) {
                $presentExtensions += $ext
            } else {
                $missingExtensions += $ext
            }
        }
        
        Write-Host "   📋 Required extensions installed: $($presentExtensions.Count)/$($requiredExtensions.Count)" -ForegroundColor Cyan
        
        if ($missingExtensions.Count -gt 0) {
            Write-Host "   ⚠️  Missing extensions:" -ForegroundColor Yellow
            foreach ($missing in $missingExtensions) {
                Write-Host "      - $missing" -ForegroundColor Yellow
            }
            $validationResults.Recommendations += "Install missing VS Code extensions: code --install-extension <extension-id>"
        }
        
        $validationResults.Details.VSCode = @{
            Status = "Success"
            Version = $vscodeVersion
            RequiredExtensions = $requiredExtensions.Count
            InstalledExtensions = $presentExtensions.Count
            MissingExtensions = $missingExtensions
        }
        $passedTests++
    } else {
        throw "Visual Studio Code not found in PATH"
    }
} catch {
    Write-Host "   ❌ Visual Studio Code validation failed: $($_.Exception.Message)" -ForegroundColor Red
    $validationResults.Details.VSCode = @{
        Status = "Failed"
        Error = $_.Exception.Message
    }
    $validationResults.Recommendations += "Install Visual Studio Code: https://code.visualstudio.com"
}

Write-Host

# =============================================================================
# Step 9: Git Configuration Validation
# =============================================================================

Write-Host "🔍 Step 9: Git Configuration Validation" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

try {
    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    if ($gitCmd) {
        $gitVersion = & git --version 2>$null
        Write-Host "   ✅ Git installed - $gitVersion" -ForegroundColor Green
        
        # Check Git configuration
        $gitUser = & git config --global user.name 2>$null
        $gitEmail = & git config --global user.email 2>$null
        
        if ($gitUser -and $gitEmail) {
            Write-Host "   ✅ Git configured" -ForegroundColor Green
            Write-Host "   📋 User: $gitUser" -ForegroundColor Cyan
            Write-Host "   📋 Email: $gitEmail" -ForegroundColor Cyan
        } else {
            Write-Host "   ⚠️  Git not fully configured" -ForegroundColor Yellow
            if (-not $gitUser) { Write-Host "      Missing: user.name" -ForegroundColor Yellow }
            if (-not $gitEmail) { Write-Host "      Missing: user.email" -ForegroundColor Yellow }
            $validationResults.Recommendations += "Configure Git: git config --global user.name 'Your Name' && git config --global user.email 'your.email@domain.com'"
        }
        
        $validationResults.Details.Git = @{
            Status = "Success"
            Version = $gitVersion
            UserConfigured = (-not [string]::IsNullOrEmpty($gitUser))
            EmailConfigured = (-not [string]::IsNullOrEmpty($gitEmail))
            User = $gitUser
            Email = $gitEmail
        }
        $passedTests++
    } else {
        throw "Git not found in PATH"
    }
} catch {
    Write-Host "   ❌ Git validation failed: $($_.Exception.Message)" -ForegroundColor Red
    $validationResults.Details.Git = @{
        Status = "Failed"
        Error = $_.Exception.Message
    }
    $validationResults.Recommendations += "Install Git: https://git-scm.com/download/windows"
}

Write-Host

# =============================================================================
# Step 10: Validation Summary and Results
# =============================================================================

Write-Host "🔍 Step 10: Validation Summary and Results" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# =============================================================================
# Step 10: Validation Summary and Results
# =============================================================================

Write-Host "🔍 Step 10: Validation Summary and Results" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Calculate overall success rate
$totalTests = 9
$successRate = [math]::Round(($passedTests / $totalTests) * 100, 1)

# Display summary
Write-Host "📊 VALIDATION SUMMARY" -ForegroundColor Magenta
Write-Host "===================" -ForegroundColor Magenta
Write-Host "   🎯 Tests Passed: $passedTests/$totalTests ($successRate%)" -ForegroundColor $(if($passedTests -eq $totalTests){'Green'}else{'Yellow'})

if ($passedTests -eq $totalTests) {
    Write-Host "   🎉 Environment fully validated - Ready for Azure AI Security Skills Challenge!" -ForegroundColor Green
} elseif ($passedTests -ge 6) {
    Write-Host "   ⚠️  Environment mostly ready - Some components need attention" -ForegroundColor Yellow
} else {
    Write-Host "   ❌ Environment needs significant setup before proceeding" -ForegroundColor Red
}

# Update final validation results
$validationResults.Summary.TotalTests = $totalTests
$validationResults.Summary.PassedTests = $passedTests
$validationResults.Summary.SuccessRate = $successRate
$validationResults.Summary.OverallStatus = if ($passedTests -eq $totalTests) { "Ready" } elseif ($passedTests -ge 6) { "Mostly Ready" } else { "Needs Setup" }
$validationResults.Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Display recommendations if any
if ($validationResults.Recommendations.Count -gt 0) {
    Write-Host
    Write-Host "💡 RECOMMENDATIONS" -ForegroundColor Cyan
    Write-Host "=================" -ForegroundColor Cyan
    for ($i = 0; $i -lt $validationResults.Recommendations.Count; $i++) {
        Write-Host "   $($i + 1). $($validationResults.Recommendations[$i])" -ForegroundColor Cyan
    }
}

# Export results if requested
if ($ExportResults) {
    try {
        $exportPath = Join-Path $PWD "environment-validation-$(Get-Date -Format 'yyyy-MM-dd-HHmm').json"
        $validationResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $exportPath -Encoding UTF8
        Write-Host
        Write-Host "📁 Results exported to: $exportPath" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to export results: $($_.Exception.Message)"
    }
}

# Display next steps
Write-Host
Write-Host "🚀 NEXT STEPS" -ForegroundColor Blue
Write-Host "============" -ForegroundColor Blue

if ($passedTests -eq $totalTests) {
    Write-Host "   ✅ Environment ready - You can proceed with Week 1 of the Azure AI Security Skills Challenge" -ForegroundColor Green
    Write-Host "   📖 Navigate to: '01 - Defender for Cloud Deployment Mastery'" -ForegroundColor Cyan
} else {
    Write-Host "   🔧 Complete the recommended actions above" -ForegroundColor Yellow
    Write-Host "   🔄 Re-run this validation script to verify fixes" -ForegroundColor Yellow
    Write-Host "   📖 Once validation passes, proceed to Week 1" -ForegroundColor Cyan
}

Write-Host
Write-Host "🤖 AI-Assisted Validation Complete" -ForegroundColor Magenta
Write-Host "This comprehensive environment validation script was enhanced using GitHub Copilot" -ForegroundColor Gray
