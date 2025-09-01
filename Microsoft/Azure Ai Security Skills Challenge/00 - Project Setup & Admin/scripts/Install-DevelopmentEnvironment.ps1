<#
.SYNOPSIS
    Automated installation and configuration of Azure development tools for
    the Azure AI Security Skills Challenge program.

.DESCRIPTION
    This script automates the installation and initial configuration of all
    development tools for the 9-week Azure AI Security Skills Challenge.
    It installs Azure CLI, PowerShell Az modules, Visual Studio Code extensions,
    and performs initial authentication setup. The script includes comprehensive
    error handling, progress reporting, and validation of each installation step.
    
    The script is designed to be run on Windows systems and will configure
    the development environment to support Infrastructure-as-Code deployments,
    Azure security service management, and AI service integrations across
    all nine weeks of the learning program.

.PARAMETER SkipAzureCLI
    Skip Azure CLI installation (useful if already installed).

.PARAMETER SkipPowerShellModules
    Skip PowerShell Az module installation (useful for updates only).

.PARAMETER SkipVSCodeExtensions
    Skip Visual Studio Code extension installation.

.PARAMETER SkipAuthentication
    Skip automated Azure authentication process.

.PARAMETER InstallPath
    Custom installation path for portable tools. Default uses system defaults.

.EXAMPLE
    .\Install-DevelopmentEnvironment.ps1
    
    Complete installation of all development tools with default settings.

.EXAMPLE
    .\Install-DevelopmentEnvironment.ps1 -SkipAuthentication
    
    Install tools but skip the automated authentication process.

.EXAMPLE
    .\Install-DevelopmentEnvironment.ps1 -SkipAzureCLI -SkipPowerShellModules
    
    Install only VS Code extensions (assuming CLI and PowerShell already configured).

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-08-31
    Last Modified: 2025-08-31
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows 10/11 or Windows Server 2016+
    - PowerShell 5.1+ (PowerShell 7+ recommended)
    - Administrator privileges for system-wide installations
    - Internet connectivity for downloads and authentication
    
    Script development orchestrated using GitHub Copilot.

.INSTALLATION_COMPONENTS
    - Azure CLI: Latest version with extensions support
    - PowerShell Az Modules: Complete Azure PowerShell module set
    - Visual Studio Code Extensions: Azure development extension pack
    - Git Configuration: Basic Git setup for repository management
    - Authentication Setup: Azure CLI and PowerShell authentication
#>

param(
    [Parameter(Mandatory=$false, HelpMessage="Skip Azure CLI installation")]
    [switch]$SkipAzureCLI,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip PowerShell Az module installation")]
    [switch]$SkipPowerShellModules,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip VS Code extension installation")]
    [switch]$SkipVSCodeExtensions,
    
    [Parameter(Mandatory=$false, HelpMessage="Skip automated Azure authentication")]
    [switch]$SkipAuthentication,
    
    [Parameter(Mandatory=$false, HelpMessage="Custom installation path for portable tools")]
    [string]$InstallPath = $null
)

# =============================================================================
# Step 1: Initialize Installation Framework
# =============================================================================

Write-Host "🔍 Step 1: Initialize Installation Framework" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

Write-Host "🚀 Azure AI Security Skills Challenge - Development Environment Setup" -ForegroundColor Green
Write-Host "====================================================================" -ForegroundColor Green
Write-Host

$installationResults = @{
    StartTime = Get-Date
    Status = "In Progress"
    Components = @{}
}

# Check if running with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "⚠️  Warning: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "   📋 Some installations may require elevated privileges" -ForegroundColor Cyan
    Write-Host "   📋 If installations fail, try running as Administrator" -ForegroundColor Cyan
    Write-Host
}

# =============================================================================
# Step 2: Azure CLI Installation
# =============================================================================

Write-Host "🔍 Step 2: Azure CLI Installation" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

if (-not $SkipAzureCLI) {
    
    try {
        # Check if Azure CLI is already installed
        $existingAzCLI = Get-Command az -ErrorAction SilentlyContinue
        if ($existingAzCLI) {
            Write-Host "   ℹ️  Azure CLI already installed at: $($existingAzCLI.Source)" -ForegroundColor Cyan
            
            # Check version and offer update
            $currentVersion = (az version | ConvertFrom-Json).'azure-cli'
            Write-Host "   📋 Current version: $currentVersion" -ForegroundColor Cyan
            
            $updateChoice = Read-Host "   ❓ Update to latest version? (y/N)"
            if ($updateChoice -eq 'y' -or $updateChoice -eq 'Y') {
                Write-Host "   🔄 Updating Azure CLI..." -ForegroundColor Cyan
                az upgrade --yes
            }
        } else {
            Write-Host "   📥 Downloading Azure CLI installer..." -ForegroundColor Cyan
            
            $msiPath = Join-Path $env:TEMP "AzureCLI.msi"
            Invoke-WebRequest -Uri "https://aka.ms/installazurecliwindows" -OutFile $msiPath -UseBasicParsing
            
            Write-Host "   🔧 Installing Azure CLI (this may take a few minutes)..." -ForegroundColor Cyan
            Start-Process msiexec.exe -ArgumentList "/I", $msiPath, "/quiet", "/norestart" -Wait -NoNewWindow
            
            # Clean up installer
            Remove-Item $msiPath -Force -ErrorAction SilentlyContinue
        }
        
        # Verify installation
        $azPath = Get-Command az -ErrorAction SilentlyContinue
        if ($azPath) {
            $azVersion = (az version | ConvertFrom-Json).'azure-cli'
            Write-Host "   ✅ Azure CLI installed successfully - Version: $azVersion" -ForegroundColor Green
            
            $installationResults.Components.AzureCLI = @{
                Status = "Success"
                Version = $azVersion
                Path = $azPath.Source
            }
        } else {
            throw "Azure CLI installation verification failed"
        }
    } catch {
        Write-Host "   ❌ Azure CLI installation failed: $($_.Exception.Message)" -ForegroundColor Red
        $installationResults.Components.AzureCLI = @{
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
    
    Write-Host
} else {
    Write-Host "⏭️  Skipping Azure CLI installation as requested" -ForegroundColor Cyan
    Write-Host
}

# =============================================================================
# Step 3: PowerShell Az Module Installation
# =============================================================================

Write-Host "🔍 Step 3: PowerShell Az Module Installation" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

if (-not $SkipPowerShellModules) {
    
    try {
        # Check if Az modules are already installed
        $existingAzModule = Get-Module -Name Az -ListAvailable | Select-Object -First 1
        if ($existingAzModule) {
            Write-Host "   ℹ️  PowerShell Az module already installed" -ForegroundColor Cyan
            Write-Host "   📋 Current version: $($existingAzModule.Version)" -ForegroundColor Cyan
            
            $updateChoice = Read-Host "   ❓ Update to latest version? (y/N)"
            if ($updateChoice -eq 'y' -or $updateChoice -eq 'Y') {
                Write-Host "   🔄 Updating Az modules..." -ForegroundColor Cyan
                Update-Module -Name Az -Force -AcceptLicense
            }
        } else {
            Write-Host "   📥 Installing PowerShell Az modules (this may take several minutes)..." -ForegroundColor Cyan
            
            # Set PSGallery as trusted repository
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
            
            # Install Az module
            Install-Module -Name Az -Repository PSGallery -Force -AllowClobber -AcceptLicense -Scope CurrentUser
        }
        
        # Import and verify module
        Write-Host "   🔄 Importing Az modules..." -ForegroundColor Cyan
        Import-Module Az -Force -ErrorAction SilentlyContinue
        
        $azModule = Get-Module -Name Az -ListAvailable | Select-Object -First 1
        if ($azModule) {
            Write-Host "   ✅ PowerShell Az modules installed successfully - Version: $($azModule.Version)" -ForegroundColor Green
            
            # Show installed sub-modules count
            $azSubModules = Get-Module -Name Az.* -ListAvailable | Group-Object Name | Measure-Object
            Write-Host "   📋 Total Az sub-modules available: $($azSubModules.Count)" -ForegroundColor Cyan
            
            $installationResults.Components.PowerShellAzModules = @{
                Status = "Success"
                Version = $azModule.Version.ToString()
                SubModuleCount = $azSubModules.Count
            }
        } else {
            throw "PowerShell Az module installation verification failed"
        }
    } catch {
        Write-Host "   ❌ PowerShell Az module installation failed: $($_.Exception.Message)" -ForegroundColor Red
        $installationResults.Components.PowerShellAzModules = @{
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
    
    Write-Host
} else {
    Write-Host "⏭️  Skipping PowerShell Az module installation as requested" -ForegroundColor Cyan
    Write-Host
}

# =============================================================================
# Step 4: Visual Studio Code Extensions Installation
# =============================================================================

Write-Host "🔍 Step 4: Visual Studio Code Extensions Installation" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

if (-not $SkipVSCodeExtensions) {
    
    try {
        # Check if VS Code is installed
        $vscodeCmd = Get-Command code -ErrorAction SilentlyContinue
        if (-not $vscodeCmd) {
            Write-Host "   ⚠️  Visual Studio Code not found in PATH" -ForegroundColor Yellow
            Write-Host "   📋 Please install VS Code from: https://code.visualstudio.com" -ForegroundColor Cyan
            Write-Host "   📋 After installation, restart this script to install extensions" -ForegroundColor Cyan
            
            $installationResults.Components.VSCodeExtensions = @{
                Status = "Skipped"
                Reason = "VS Code not installed"
            }
        } else {
            Write-Host "   ✅ Visual Studio Code found" -ForegroundColor Green
            
            # Define required extensions
            $requiredExtensions = @(
                @{ Id = "ms-vscode.azure-account"; Name = "Azure Account" },
                @{ Id = "ms-azuretools.vscode-azureresourcemanager"; Name = "Azure Resource Manager Tools" },
                @{ Id = "ms-azuretools.vscode-bicep"; Name = "Bicep" },
                @{ Id = "ms-vscode.azurecli"; Name = "Azure CLI Tools" },
                @{ Id = "ms-vscode.powershell"; Name = "PowerShell" },
                @{ Id = "eamodio.gitlens"; Name = "GitLens" }
            )
            
            $installedCount = 0
            foreach ($extension in $requiredExtensions) {
                try {
                    Write-Host "   🔧 Installing $($extension.Name)..." -ForegroundColor Cyan
                    
                    # Install extension
                    $installResult = & code --install-extension $extension.Id --force 2>&1
                    
                    if ($LASTEXITCODE -eq 0 -or $installResult -match "already installed|successfully installed") {
                        Write-Host "      ✅ $($extension.Name) installed successfully" -ForegroundColor Green
                        $installedCount++
                    } else {
                        Write-Host "      ⚠️  $($extension.Name) installation may have issues" -ForegroundColor Yellow
                        Write-Host "      📋 Output: $installResult" -ForegroundColor Cyan
                    }
                } catch {
                    Write-Host "      ❌ Failed to install $($extension.Name): $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            
            Write-Host "   📊 Extensions processed: $installedCount / $($requiredExtensions.Count)" -ForegroundColor Cyan
            
            $installationResults.Components.VSCodeExtensions = @{
                Status = if ($installedCount -eq $requiredExtensions.Count) { "Success" } else { "Partial" }
                InstalledCount = $installedCount
                TotalCount = $requiredExtensions.Count
                Extensions = $requiredExtensions.Id
            }
        }
    } catch {
        Write-Host "   ❌ VS Code extensions installation failed: $($_.Exception.Message)" -ForegroundColor Red
        $installationResults.Components.VSCodeExtensions = @{
            Status = "Failed"
            Error = $_.Exception.Message
        }
    }
    
    Write-Host
} else {
    Write-Host "⏭️  Skipping VS Code extensions installation as requested" -ForegroundColor Cyan
    Write-Host
}

# =============================================================================
# Step 5: Git Configuration
# =============================================================================

Write-Host "🔍 Step 5: Git Configuration" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

try {
    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    if ($gitCmd) {
        # Check if Git is already configured
        $gitUser = git config --global user.name 2>$null
        $gitEmail = git config --global user.email 2>$null
        
        if (-not $gitUser -or -not $gitEmail) {
            Write-Host "   📋 Git configuration needed for repository management" -ForegroundColor Cyan
            
            if (-not $gitUser) {
                $userName = Read-Host "   📝 Enter your full name for Git commits"
                if ($userName) {
                    git config --global user.name $userName
                    Write-Host "      ✅ Git user name configured" -ForegroundColor Green
                }
            }
            
            if (-not $gitEmail) {
                $userEmail = Read-Host "   📝 Enter your email address for Git commits"
                if ($userEmail) {
                    git config --global user.email $userEmail
                    Write-Host "      ✅ Git user email configured" -ForegroundColor Green
                }
            }
        } else {
            Write-Host "   ✅ Git already configured" -ForegroundColor Green
            Write-Host "   📋 User: $gitUser" -ForegroundColor Cyan
            Write-Host "   📋 Email: $gitEmail" -ForegroundColor Cyan
        }
        
        $installationResults.Components.GitConfiguration = @{
            Status = "Success"
            User = git config --global user.name
            Email = git config --global user.email
        }
    } else {
        Write-Host "   ⚠️  Git not found in PATH" -ForegroundColor Yellow
        Write-Host "   📋 Install Git from: https://git-scm.com/download/windows" -ForegroundColor Cyan
        
        $installationResults.Components.GitConfiguration = @{
            Status = "Skipped"
            Reason = "Git not installed"
        }
    }
} catch {
    Write-Host "   ❌ Git configuration failed: $($_.Exception.Message)" -ForegroundColor Red
    $installationResults.Components.GitConfiguration = @{
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

Write-Host

# =============================================================================
# Step 6: Azure Authentication Setup
# =============================================================================

Write-Host "🔍 Step 6: Azure Authentication Setup" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

if (-not $SkipAuthentication) {
    
    try {
        # Check Azure CLI authentication
        Write-Host "   🔐 Setting up Azure CLI authentication..." -ForegroundColor Cyan
        
        $azureAccount = az account show 2>$null | ConvertFrom-Json
        if ($azureAccount) {
            Write-Host "   ✅ Azure CLI already authenticated" -ForegroundColor Green
            Write-Host "   📋 Account: $($azureAccount.user.name)" -ForegroundColor Cyan
            Write-Host "   📋 Subscription: $($azureAccount.name)" -ForegroundColor Cyan
        } else {
            Write-Host "   🌐 Opening browser for Azure CLI authentication..." -ForegroundColor Cyan
            az login
            
            $azureAccount = az account show | ConvertFrom-Json
            if ($azureAccount) {
                Write-Host "   ✅ Azure CLI authentication successful" -ForegroundColor Green
            } else {
                throw "Azure CLI authentication failed"
            }
        }
        
        # Setup PowerShell authentication
        Write-Host "   🔐 Setting up PowerShell Azure authentication..." -ForegroundColor Cyan
        
        $azContext = Get-AzContext -ErrorAction SilentlyContinue
        if ($azContext) {
            Write-Host "   ✅ PowerShell Az already authenticated" -ForegroundColor Green
            Write-Host "   📋 Account: $($azContext.Account.Id)" -ForegroundColor Cyan
        } else {
            Write-Host "   🌐 Authenticating PowerShell to Azure..." -ForegroundColor Cyan
            Connect-AzAccount -ErrorAction Stop
            
            $azContext = Get-AzContext
            if ($azContext) {
                Write-Host "   ✅ PowerShell Azure authentication successful" -ForegroundColor Green
            } else {
                throw "PowerShell Azure authentication failed"
            }
        }
        
        $installationResults.Components.AzureAuthentication = @{
            Status = "Success"
            CLIAccount = $azureAccount.user.name
            PowerShellAccount = $azContext.Account.Id
            Subscription = $azureAccount.name
        }
    } catch {
        Write-Host "   ❌ Azure authentication setup failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   📋 You can manually authenticate later using:" -ForegroundColor Cyan
        Write-Host "      • Azure CLI: az login" -ForegroundColor Cyan
        Write-Host "      • PowerShell: Connect-AzAccount" -ForegroundColor Cyan
        
        $installationResults.Components.AzureAuthentication = @{
            Status = "Failed"
            Error = $_.Exception.Message
            ManualSteps = @("az login", "Connect-AzAccount")
        }
    }
    
    Write-Host
} else {
    Write-Host "⏭️  Skipping Azure authentication as requested" -ForegroundColor Cyan
    Write-Host "   📋 Remember to authenticate manually:" -ForegroundColor Cyan
    Write-Host "      • Azure CLI: az login" -ForegroundColor Cyan
    Write-Host "      • PowerShell: Connect-AzAccount" -ForegroundColor Cyan
    Write-Host
}

# =============================================================================
# Step 7: Installation Summary and Next Steps
# =============================================================================

Write-Host "🔍 Step 7: Installation Summary and Next Steps" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

$installationResults.EndTime = Get-Date
$installationResults.Duration = ($installationResults.EndTime - $installationResults.StartTime).ToString("mm\:ss")

$successCount = ($installationResults.Components.Values | Where-Object { $_.Status -eq "Success" }).Count
$totalComponents = $installationResults.Components.Count

Write-Host "🎯 Installation Summary" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host "📊 Components processed: $successCount / $totalComponents successful" -ForegroundColor Cyan
Write-Host "⏱️  Total time: $($installationResults.Duration)" -ForegroundColor Cyan
Write-Host

if ($successCount -eq $totalComponents) {
    Write-Host "🎉 All components installed successfully!" -ForegroundColor Green
    $installationResults.Status = "Success"
} elseif ($successCount -gt 0) {
    Write-Host "⚠️  Partial installation completed" -ForegroundColor Yellow
    Write-Host "📋 Review any failed components above" -ForegroundColor Cyan
    $installationResults.Status = "Partial"
} else {
    Write-Host "❌ Installation encountered significant issues" -ForegroundColor Red
    Write-Host "📋 Review error messages above and retry" -ForegroundColor Cyan
    $installationResults.Status = "Failed"
}

Write-Host
Write-Host "🔗 Recommended Next Steps:" -ForegroundColor Cyan
Write-Host "   1. 🔍 Run Test-EnvironmentValidation.ps1 to verify setup" -ForegroundColor Cyan
Write-Host "   2. 📚 Review the Week 00 README for additional requirements" -ForegroundColor Cyan
Write-Host "   3. 💰 Configure cost management and budgets" -ForegroundColor Cyan
Write-Host "   4. 🚀 Begin Week 1: Defender for Cloud Deployment Mastery" -ForegroundColor Cyan
Write-Host

# Export installation results
$resultsPath = "Installation-Results-$(Get-Date -Format 'yyyy-MM-dd-HHmm').json"
$installationResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $resultsPath -Encoding UTF8
Write-Host "📁 Installation results saved to: $resultsPath" -ForegroundColor Cyan

# Exit with appropriate code
exit $(if ($installationResults.Status -eq "Failed") { 1 } else { 0 })
