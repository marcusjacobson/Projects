<#
.SYNOPSIS
    Automated development environment installation for Az#
# =============================================================================
# Advanced PowerShell automation for Azure development environment setup.
# Assumes PowerShell familiarity and administrative access.
# =============================================================================AI Security Skills Challenge.

.DESCRIPTION
    Advanced PowerShell automation script for installing and configuring Azure development tools.
    This script assumes PowerShell familiarity and administrative access. It provides modular
    installation options with comprehensive error handling and validation.
    
    PREREQUISITES:
    - PowerShell 7+ (must be installed manually first)
    - Administrative privileges recommended
    - Familiarity with PowerShell scripting and Azure tools
    - Understanding of Windows software installation processes

.PARAMETER SkipAzureCLI
    Skip Azure CLI installation if already present.

.PARAMETER SkipVSCode
    Skip Visual Studio Code installation if already present.

.PARAMETER SkipPowerShellModules
    Skip Azure PowerShell modules installation if already present.

.PARAMETER SkipVSCodeExtensions
    Skip VS Code extensions installation if already present.

.PARAMETER SkipBicep
    Skip Bicep CLI installation if already present.

.PARAMETER SkipAuthentication
    Skip Azure authentication steps for unattended execution.

.PARAMETER ValidateOnly
    Perform validation only without installing components.

.EXAMPLE
    .\Install-DevelopmentEnvironment.ps1
    
    Complete automated installation with all components.

.EXAMPLE
    .\Install-DevelopmentEnvironment.ps1 -SkipAzureCLI -SkipAuthentication
    
    Install all components except Azure CLI, skip authentication.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-01-21
    Last Modified: 2025-09-05
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    ADVANCED USER REQUIREMENTS:
    - PowerShell 7+ installed manually first
    - Understanding of Windows software installation
    - Familiarity with Azure CLI and PowerShell modules
    - Administrative access for software installations
    - Basic troubleshooting skills for installation issues
    
    Script development orchestrated using GitHub Copilot.

.AUTOMATION_COMPONENTS
    - Azure CLI with East US configuration
    - Visual Studio Code with Azure extensions
    - Azure PowerShell modules (Az, Security, CognitiveServices)
    - Bicep CLI for Infrastructure-as-Code
    - Automated authentication setup for Azure services
#>

#
# =============================================================================
# Automated development environment installation for Azure AI Security Skills Challenge.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$SkipAzureCLI,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipVSCode,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipPowerShellModules,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipVSCodeExtensions,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipBicep,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipAuthentication,
    
    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly
)

# =============================================================================
# Step 1: Environment Validation and Setup
# =============================================================================

Write-Host "� Step 1: Advanced User Environment Validation" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

Write-Host "📋 Validating PowerShell and administrative access..." -ForegroundColor Cyan
Write-Host "💡 This script assumes PowerShell familiarity and may require admin privileges" -ForegroundColor Yellow

try {
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Host "   ❌ PowerShell 7+ is required. Current version: $($PSVersionTable.PSVersion)" -ForegroundColor Red
        Write-Host "   📚 Please install PowerShell 7+ manually first: https://github.com/PowerShell/PowerShell/releases" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "   ✅ PowerShell version validated: $($PSVersionTable.PSVersion)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ PowerShell validation failed: $_" -ForegroundColor Red
    exit 1
}

# Check administrative privileges for installations
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin -and -not $ValidateOnly) {
    Write-Host "   ⚠️ Administrative privileges recommended for installations" -ForegroundColor Yellow
    Write-Host "   💡 Consider running as Administrator for best results" -ForegroundColor Cyan
}

# =============================================================================
# Step 2: Azure CLI Installation
# =============================================================================

if (-not $SkipAzureCLI -and -not $ValidateOnly) {
    Write-Host "🚀 Step 2: Azure CLI Installation" -ForegroundColor Green
    Write-Host "=================================" -ForegroundColor Green
    
    Write-Host "📋 Installing Azure CLI..." -ForegroundColor Cyan
    
    try {
        # Check if Azure CLI is already installed
        $existingAzCLI = Get-Command az -ErrorAction SilentlyContinue
        if ($existingAzCLI) {
            Write-Host "   💡 Azure CLI already installed. Checking version..." -ForegroundColor Cyan
            $currentVersion = az --version | Select-String "azure-cli" | ForEach-Object { $_.ToString().Split()[1] }
            Write-Host "   ✅ Current Azure CLI version: $currentVersion" -ForegroundColor Green
        } else {
            # Download and install Azure CLI
            Write-Host "   🔄 Downloading Azure CLI installer..." -ForegroundColor Cyan
            $azCliUrl = "https://aka.ms/installazurecliwindows"
            $azCliInstaller = "$env:TEMP\AzureCLI.msi"
            
            Invoke-WebRequest -Uri $azCliUrl -OutFile $azCliInstaller
            
            Write-Host "   🔄 Installing Azure CLI (this may take several minutes)..." -ForegroundColor Cyan
            Start-Process msiexec.exe -ArgumentList "/i", $azCliInstaller, "/quiet", "/norestart" -Wait
            
            # Clean up installer
            Remove-Item $azCliInstaller -Force
            
            # Verify installation
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            $azCommand = Get-Command az -ErrorAction SilentlyContinue
            
            if ($azCommand) {
                Write-Host "   ✅ Azure CLI installation completed successfully" -ForegroundColor Green
            } else {
                throw "Azure CLI installation verification failed"
            }
        }
        
        # Configure Azure CLI defaults
        Write-Host "   🔧 Configuring Azure CLI defaults..." -ForegroundColor Cyan
        az config set defaults.location=eastus
        az config set core.output=table
        az config set auto-upgrade.enable=yes
        
        Write-Host "   ✅ Azure CLI configuration completed" -ForegroundColor Green
        
    } catch {
        Write-Host "   ❌ Azure CLI installation failed: $_" -ForegroundColor Red
        throw
    }
}

# =============================================================================
# Step 3: Visual Studio Code Installation
# =============================================================================

if (-not $SkipVSCode -and -not $ValidateOnly) {
    Write-Host "💻 Step 3: Visual Studio Code Installation" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    
    Write-Host "📋 Installing Visual Studio Code..." -ForegroundColor Cyan
    
    try {
        # Check if VS Code is already installed
        $existingVSCode = Get-Command code -ErrorAction SilentlyContinue
        if ($existingVSCode) {
            Write-Host "   💡 Visual Studio Code already installed" -ForegroundColor Cyan
            $vscodeVersion = code --version | Select-Object -First 1
            Write-Host "   ✅ Current VS Code version: $vscodeVersion" -ForegroundColor Green
        } else {
            # Download and install VS Code
            Write-Host "   🔄 Downloading VS Code installer..." -ForegroundColor Cyan
            $vscodeUrl = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
            $vscodeInstaller = "$env:TEMP\VSCode.exe"
            
            Invoke-WebRequest -Uri $vscodeUrl -OutFile $vscodeInstaller
            
            Write-Host "   🔄 Installing Visual Studio Code..." -ForegroundColor Cyan
            Start-Process $vscodeInstaller -ArgumentList '/VERYSILENT', '/NORESTART', '/MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath' -Wait
            
            # Clean up installer
            Remove-Item $vscodeInstaller -Force
            
            # Refresh PATH for current session
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            # Verify installation
            Start-Sleep -Seconds 5  # Allow time for installation to complete
            $codeCommand = Get-Command code -ErrorAction SilentlyContinue
            
            if ($codeCommand) {
                Write-Host "   ✅ Visual Studio Code installation completed successfully" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️ VS Code installed but 'code' command not immediately available" -ForegroundColor Yellow
                Write-Host "   💡 Restart your shell to access 'code' command" -ForegroundColor Cyan
            }
        }
        
    } catch {
        Write-Host "   ❌ Visual Studio Code installation failed: $_" -ForegroundColor Red
        throw
    }
}

# =============================================================================
# Step 4: Azure PowerShell Modules Installation
# =============================================================================

if (-not $SkipPowerShellModules -and -not $ValidateOnly) {
    Write-Host "⚡ Step 4: Azure PowerShell Modules Installation" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    
    Write-Host "📋 Installing Azure PowerShell modules..." -ForegroundColor Cyan
    
    try {
        # Modules to install
        $azureModules = @(
            "Az",
            "Az.Security",
            "Az.SecurityInsights",
            "Az.CognitiveServices",
            "Az.OperationalInsights"
        )
        
        foreach ($module in $azureModules) {
            Write-Host "   🔄 Installing module: $module..." -ForegroundColor Cyan
            
            # Check if module is already installed
            $existingModule = Get-Module -Name $module -ListAvailable -ErrorAction SilentlyContinue
            if ($existingModule) {
                Write-Host "      💡 Module $module already installed (version: $($existingModule[0].Version))" -ForegroundColor Yellow
            } else {
                Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
                Write-Host "      ✅ Module $module installed successfully" -ForegroundColor Green
            }
        }
        
        # Import the main Az module
        Write-Host "   🔄 Importing Az module..." -ForegroundColor Cyan
        Import-Module Az -Force -ErrorAction SilentlyContinue
        
        Write-Host "   ✅ Azure PowerShell modules installation completed" -ForegroundColor Green
        
    } catch {
        Write-Host "   ❌ Azure PowerShell modules installation failed: $_" -ForegroundColor Red
        throw
    }
}

# =============================================================================
# Step 5: VS Code Extensions Installation
# =============================================================================

if (-not $SkipVSCodeExtensions -and -not $ValidateOnly) {
    Write-Host "🔧 Step 5: VS Code Extensions Installation" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    
    Write-Host "📋 Installing VS Code extensions..." -ForegroundColor Cyan
    
    try {
        # Check if code command is available
        $codeCommand = Get-Command code -ErrorAction SilentlyContinue
        if (-not $codeCommand) {
            Write-Host "   ⚠️ 'code' command not available. Extensions will be skipped." -ForegroundColor Yellow
            Write-Host "   💡 Install VS Code first or restart your shell" -ForegroundColor Cyan
        } else {
            # Extensions to install
            $extensions = @(
                "ms-vscode.azure-account",
                "ms-azuretools.azure-cli-tools",
                "ms-azuretools.vscode-azureresourcegroups",
                "ms-azuretools.vscode-bicep",
                "ms-vscode.powershell",
                "redhat.vscode-yaml",
                "ms-vscode.json",
                "yzhang.markdown-all-in-one"
            )
            
            foreach ($extension in $extensions) {
                Write-Host "   🔄 Installing extension: $extension..." -ForegroundColor Cyan
                
                try {
                    & code --install-extension $extension --force 2>$null
                    Write-Host "      ✅ Extension $extension installed successfully" -ForegroundColor Green
                } catch {
                    Write-Host "      ⚠️ Extension $extension installation may have failed" -ForegroundColor Yellow
                }
            }
            
            Write-Host "   ✅ VS Code extensions installation completed" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "   ❌ VS Code extensions installation failed: $_" -ForegroundColor Red
        Write-Host "   💡 Extensions can be installed manually through VS Code interface" -ForegroundColor Cyan
    }
}

# =============================================================================
# Step 6: Bicep CLI Installation
# =============================================================================

if (-not $SkipBicep -and -not $ValidateOnly) {
    Write-Host "🏗️ Step 6: Bicep CLI Installation" -ForegroundColor Green
    Write-Host "=================================" -ForegroundColor Green
    
    Write-Host "📋 Installing Bicep CLI..." -ForegroundColor Cyan
    
    try {
        # Check if Azure CLI is available for Bicep installation
        $azCommand = Get-Command az -ErrorAction SilentlyContinue
        if (-not $azCommand) {
            Write-Host "   ⚠️ Azure CLI not available. Bicep CLI installation skipped." -ForegroundColor Yellow
            Write-Host "   💡 Install Azure CLI first to enable Bicep CLI installation" -ForegroundColor Cyan
        } else {
            # Install Bicep CLI
            Write-Host "   🔄 Installing Bicep CLI via Azure CLI..." -ForegroundColor Cyan
            az bicep install
            
            # Verify installation
            $bicepVersion = az bicep version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   ✅ Bicep CLI installation completed: $bicepVersion" -ForegroundColor Green
            } else {
                throw "Bicep CLI installation verification failed"
            }
        }
        
    } catch {
        Write-Host "   ❌ Bicep CLI installation failed: $_" -ForegroundColor Red
        Write-Host "   💡 You can install Bicep CLI manually later using 'az bicep install'" -ForegroundColor Cyan
    }
}

# =============================================================================
# Step 7: Authentication Setup
# =============================================================================

if (-not $SkipAuthentication -and -not $ValidateOnly) {
    Write-Host "🔐 Step 7: Authentication Setup" -ForegroundColor Green
    Write-Host "===============================" -ForegroundColor Green
    
    Write-Host "📋 Setting up Azure authentication..." -ForegroundColor Cyan
    
    try {
        # Azure CLI authentication
        $azCommand = Get-Command az -ErrorAction SilentlyContinue
        if ($azCommand) {
            Write-Host "   🔄 Initiating Azure CLI authentication..." -ForegroundColor Cyan
            Write-Host "   💡 A browser window will open for authentication" -ForegroundColor Cyan
            
            az login
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   ✅ Azure CLI authentication completed" -ForegroundColor Green
                
                # Display current account
                $currentAccount = az account show --query name -o tsv
                Write-Host "   📊 Current Azure subscription: $currentAccount" -ForegroundColor Cyan
            } else {
                Write-Host "   ⚠️ Azure CLI authentication may have failed" -ForegroundColor Yellow
            }
        }
        
        # PowerShell Azure authentication
        Write-Host "   🔄 Initiating PowerShell Azure authentication..." -ForegroundColor Cyan
        
        try {
            Import-Module Az -Force -ErrorAction SilentlyContinue
            Connect-AzAccount -ErrorAction Stop
            
            $context = Get-AzContext
            if ($context) {
                Write-Host "   ✅ PowerShell Azure authentication completed" -ForegroundColor Green
                Write-Host "   📊 Connected as: $($context.Account.Id)" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "   ⚠️ PowerShell Azure authentication failed: $_" -ForegroundColor Yellow
            Write-Host "   💡 You can authenticate later using 'Connect-AzAccount'" -ForegroundColor Cyan
        }
        
    } catch {
        Write-Host "   ❌ Authentication setup failed: $_" -ForegroundColor Red
        Write-Host "   💡 Authentication can be completed manually later" -ForegroundColor Cyan
    }
}

# =============================================================================
# Step 8: Installation Validation
# =============================================================================

Write-Host "✅ Step 8: Installation Validation" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

Write-Host "📋 Validating installed components..." -ForegroundColor Cyan

$validationResults = @()

# Validate Azure CLI
try {
    $azVersion = az --version 2>$null | Select-String "azure-cli" | ForEach-Object { $_.ToString().Split()[1] }
    if ($azVersion) {
        $validationResults += "✅ Azure CLI: $azVersion"
    } else {
        $validationResults += "❌ Azure CLI: Not available"
    }
} catch {
    $validationResults += "❌ Azure CLI: Installation check failed"
}

# Validate PowerShell version
$validationResults += "✅ PowerShell: $($PSVersionTable.PSVersion)"

# Validate Azure PowerShell modules
try {
    $azModule = Get-Module Az -ListAvailable | Select-Object -First 1
    if ($azModule) {
        $validationResults += "✅ Az PowerShell Module: $($azModule.Version)"
    } else {
        $validationResults += "❌ Az PowerShell Module: Not available"
    }
} catch {
    $validationResults += "❌ Az PowerShell Module: Check failed"
}

# Validate VS Code
try {
    $vscodeVersion = code --version 2>$null | Select-Object -First 1
    if ($vscodeVersion -and $LASTEXITCODE -eq 0) {
        $validationResults += "✅ Visual Studio Code: $vscodeVersion"
    } else {
        $validationResults += "❌ Visual Studio Code: Not available or 'code' command not in PATH"
    }
} catch {
    $validationResults += "❌ Visual Studio Code: Check failed"
}

# Validate Bicep CLI
try {
    $bicepVersion = az bicep version 2>$null
    if ($bicepVersion -and $LASTEXITCODE -eq 0) {
        $validationResults += "✅ Bicep CLI: $bicepVersion"
    } else {
        $validationResults += "❌ Bicep CLI: Not available"
    }
} catch {
    $validationResults += "❌ Bicep CLI: Check failed"
}

# Validate Azure authentication
try {
    $azAccount = az account show --query name -o tsv 2>$null
    if ($azAccount -and $LASTEXITCODE -eq 0) {
        $validationResults += "✅ Azure CLI Auth: Connected to '$azAccount'"
    } else {
        $validationResults += "⚠️ Azure CLI Auth: Not authenticated"
    }
} catch {
    $validationResults += "⚠️ Azure CLI Auth: Check failed"
}

try {
    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if ($azContext) {
        $validationResults += "✅ PowerShell Azure Auth: Connected as '$($azContext.Account.Id)'"
    } else {
        $validationResults += "⚠️ PowerShell Azure Auth: Not authenticated"
    }
} catch {
    $validationResults += "⚠️ PowerShell Azure Auth: Check failed"
}

# Display validation results
Write-Host "📊 Validation Results:" -ForegroundColor Cyan
foreach ($result in $validationResults) {
    Write-Host "   $result" -ForegroundColor White
}

# =============================================================================
# Step 9: Installation Summary and Next Steps
# =============================================================================

Write-Host "🎯 Step 9: Installation Summary and Next Steps" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

$successCount = ($validationResults | Where-Object { $_ -match "✅" }).Count
$warningCount = ($validationResults | Where-Object { $_ -match "⚠️" }).Count
$failureCount = ($validationResults | Where-Object { $_ -match "❌" }).Count

Write-Host "📊 Installation Summary:" -ForegroundColor Cyan
Write-Host "   ✅ Successful components: $successCount" -ForegroundColor Green
Write-Host "   ⚠️ Warning components: $warningCount" -ForegroundColor Yellow
Write-Host "   ❌ Failed components: $failureCount" -ForegroundColor Red

if ($failureCount -eq 0 -and $warningCount -eq 0) {
    Write-Host "🎉 All components installed and configured successfully!" -ForegroundColor Green
    Write-Host "🎯 Your development environment is ready for the Azure AI Security Skills Challenge" -ForegroundColor Green
} elseif ($failureCount -eq 0) {
    Write-Host "✅ Installation completed with minor warnings" -ForegroundColor Green
    Write-Host "💡 Review warning components and complete authentication if needed" -ForegroundColor Cyan
} else {
    Write-Host "⚠️ Installation completed with some issues" -ForegroundColor Yellow
    Write-Host "🔧 Review failed components and consider manual installation" -ForegroundColor Cyan
}

Write-Host "🔄 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Restart your terminal/PowerShell session to refresh PATH" -ForegroundColor White
Write-Host "   2. Test all tools using the Quick Environment Test commands" -ForegroundColor White
Write-Host "   3. Complete authentication setup if skipped during installation" -ForegroundColor White
Write-Host "   4. Proceed to Azure Cost Management Setup (Module 00.03)" -ForegroundColor White

Write-Host "📚 Quick Test Commands:" -ForegroundColor Cyan
Write-Host "   az --version" -ForegroundColor White
Write-Host "   `$PSVersionTable.PSVersion" -ForegroundColor White
Write-Host "   Get-AzContext" -ForegroundColor White
Write-Host "   az bicep version" -ForegroundColor White

Write-Host "✅ Development environment setup completed!" -ForegroundColor Green
