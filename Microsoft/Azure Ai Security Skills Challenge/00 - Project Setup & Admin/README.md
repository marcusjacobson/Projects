# Week 00 – Project Setup & Lab Environment Preparation

This foundational setup guide ensures you have all prerequisites configured for the **9-week Azure AI Security Skills Challenge**. Complete this comprehensive setup before starting Week 1 to ensure optimal deployment capabilities and learning outcomes throughout the entire program.

## 🎯 Setup Objectives

Upon completion of this setup guide, you will have:

- **Authenticated Azure development environment** with CLI and PowerShell integration.
- **Visual Studio Code** optimized for Azure Infrastructure-as-Code development.
- **Validated subscription permissions** for security service deployments across all weeks.
- **Regional deployment readiness** for East US (mandatory for complete AI service availability).
- **Infrastructure deployment validation** through comprehensive testing scripts.

## 🚨 Critical Prerequisites

### Azure Subscription Requirements

#### Before Beginning Any Week

Verify your Azure subscription meets these mandatory requirements:

- **Active Azure Subscription** with sufficient credits/budget for 9-week learning path.
- **Subscription-level permissions**: **Owner** or **Contributor** role (required for Microsoft Defender deployments, AI services, and security configurations).
- **East US regional access**: Confirmed availability for unified security operations and complete AI service ecosystem.
- **Service quotas**: Standard quotas for compute, storage, and Cognitive Services (validated through provided scripts).

> **💰 Cost Management**: Each individual week includes specific cost analysis, optimization strategies, and budget guidance tailored to that week's deployments.

### Development Environment Foundation

## 🛠️ Installation Guide

### Step 1: Azure CLI Installation and Configuration

**Install Azure CLI** (version 2.76.0 or later required for all project deployments):

#### Windows Installation

```powershell
# Download and install Azure CLI
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -ArgumentList '/I', 'AzureCLI.msi', '/quiet'
```

#### Verify Installation

```powershell
az version
az --help
```

#### Initial Authentication

```powershell
# Authenticate to Azure (opens browser for interactive login)
az login

# Set default subscription (replace with your subscription ID)
az account set --subscription "your-subscription-id"

# Verify current context
az account show --output table
```

### Step 2: PowerShell Module Configuration

#### Install Azure PowerShell Module

```powershell
# Install Az module (required for all PowerShell deployment scripts)
Install-Module -Name Az -Repository PSGallery -Force -AllowClobber

# Import the module
Import-Module Az

# Authenticate PowerShell to Azure
Connect-AzAccount

# Verify PowerShell authentication
Get-AzContext
Get-AzSubscription
```

### Step 3: Visual Studio Code Setup for Azure Development

**Install Visual Studio Code** with Azure-optimized extensions:

#### Required Extensions for Infrastructure-as-Code

- **Azure Resource Manager Tools** - ARM/Bicep template support.
- **Bicep** - Azure Bicep language support and validation.
- **Azure CLI Tools** - Integrated Azure CLI commands.
- **PowerShell** - Enhanced PowerShell development experience.
- **Azure Account** - Azure subscription management.
- **GitLens** - Enhanced Git integration for repository management.

#### Install Extensions via Command Line

```powershell
code --install-extension ms-vscode.azure-account
code --install-extension ms-azuretools.vscode-azureresourcemanager
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-vscode.azurecli
code --install-extension ms-vscode.powershell
code --install-extension eamodio.gitlens
```

#### Configure VS Code Settings for Azure Development

Create or update VS Code settings (`Ctrl+,` → Open Settings JSON):

```json
{
    "bicep.lint.rules": {
        "no-unused-params": "off",
        "secure-parameter-default": "off"
    },
    "powershell.codeFormatting.autoCorrectAliases": true,
    "powershell.codeFormatting.useCorrectCasing": true,
    "azure.resourceGroups.enableGroupBySubscription": true,
    "azure.cloudEnvironment": "AzureCloud"
}
```

### Step 4: Git Configuration and Repository Setup

#### Configure Git for Project Management

```powershell
# Set global Git configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@domain.com"

# Verify configuration
git config --list
```

## ✅ Environment Validation

### Automated PowerShell Scripts

This setup guide includes comprehensive PowerShell scripts for automated installation and validation. All scripts follow the project's PowerShell style guide and provide detailed feedback and error handling.

#### Available Scripts

- **`Install-DevelopmentEnvironment.ps1`** - Automated installation of Azure CLI, PowerShell modules, and VS Code extensions.
- **`Test-EnvironmentValidation.ps1`** - Comprehensive environment validation with detailed reporting.

### Environment Validation

#### Run the Comprehensive Validation Script

```powershell
# Navigate to the scripts directory
cd "scripts"

# Run complete environment validation
.\Test-EnvironmentValidation.ps1 -DetailedOutput

# Export validation results for documentation
.\Test-EnvironmentValidation.ps1 -ExportResults
```

#### Automated Installation Option for New Environments

For new environment setup, use the installation script:

```powershell
# Complete automated installation
.\Install-DevelopmentEnvironment.ps1

# Selective installation (skip components already installed)
.\Install-DevelopmentEnvironment.ps1 -SkipAzureCLI -SkipAuthentication
```

> **📁 Script Documentation**: See [scripts/README.md](scripts/README.md) for detailed documentation, parameters, and troubleshooting guidance for all PowerShell automation scripts.

## 🎯 Regional Configuration

### East US Region Requirement

#### East US Regional Requirements

All weeks require East US region for:

- **Complete AI service availability** (Azure OpenAI, Cognitive Services).
- **Unified security operations** (Microsoft Defender for Cloud integration).
- **Consistent networking and connectivity** across all deployment phases.

#### Verify Regional Access

```powershell
# Check available regions for your subscription
az account list-locations --output table

# Verify East US specific services
az provider show --namespace Microsoft.CognitiveServices --query "resourceTypes[?resourceType=='accounts'].locations" --output table
```

## 🚀 Quick Start Validation

### Final Readiness Check

#### Before Proceeding to Week 1

Confirm the following requirements:

- [ ] Azure CLI authenticated and latest version installed.
- [ ] PowerShell Az module installed and authenticated.
- [ ] Visual Studio Code with Azure extensions configured.
- [ ] East US region access verified.
- [ ] Subscription permissions validated (Owner/Contributor).
- [ ] Resource providers registered.
- [ ] Environment validation script passes all tests.

### Next Steps

#### Upon Successful Completion

Upon successful completion of this setup:

1. **Proceed to Week 1**: [Defender for Cloud Deployment Mastery](../01%20-%20Defender%20for%20Cloud%20Deployment%20Mastery/README.md).
2. **Join Learning Community**: Engage with other participants for support and knowledge sharing.

## 🔧 Troubleshooting Guide

### Common Issues and Solutions

#### Azure CLI Authentication Problems

```powershell
# Clear cached credentials
az logout
az cache purge

# Re-authenticate
az login --use-device-code
```

#### PowerShell Module Import Issues

```powershell
# Uninstall and reinstall Az module
Uninstall-Module -Name Az -AllVersions -Force
Install-Module -Name Az -Force -AllowClobber
Import-Module Az -Force
```

#### Visual Studio Code Extension Problems

```powershell
# Reset VS Code extensions
code --disable-extensions
code --list-extensions | ForEach-Object { code --uninstall-extension $_ }

# Reinstall Azure extensions
code --install-extension ms-vscode.azure-account
# ... (repeat for all required extensions)
```

#### Regional Access Issues

If East US is not available in your subscription:

1. Contact Azure support to request regional access.
2. Verify subscription type supports required services.
3. Check organizational policies that might restrict regions.

#### Quota and Limits Issues

```powershell
# Check current quotas
az vm list-usage --location "East US" --output table

# Request quota increases if needed
az support tickets create \
    --ticket-name "Quota Increase Request" \
    --description "Increase VM quota for AI Security Skills Challenge"
```

## 📚 Additional Resources

### Microsoft Documentation

- **Azure CLI**: [Installation and Configuration Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Azure PowerShell**: [Installation Guide](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps)
- **Bicep**: [Installation and Setup](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- **Visual Studio Code**: [Azure Extensions](https://marketplace.visualstudio.com/search?target=VSCode&category=Azure)

### Cost Management Resources

- **Azure Cost Management**: [Cost optimization best practices](https://docs.microsoft.com/en-us/azure/cost-management-billing/)
- **Azure Pricing Calculator**: [Estimate costs for planned deployments](https://azure.microsoft.com/en-us/pricing/calculator/)
- **Azure Advisor**: [Cost optimization recommendations](https://docs.microsoft.com/en-us/azure/advisor/)

### Learning Path Integration

- **Microsoft Learn**: [Azure AI fundamentals](https://learn.microsoft.com/en-us/training/paths/get-started-with-artificial-intelligence-on-azure/)
- **Security Documentation**: [Microsoft Defender for Cloud](https://docs.microsoft.com/en-us/azure/defender-for-cloud/)
- **AI Services**: [Azure Cognitive Services](https://docs.microsoft.com/en-us/azure/cognitive-services/)

---

## 🤖 AI-Assisted Content Generation

This comprehensive project setup guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating extensive analysis of the 9-week Azure AI Security Skills Challenge curriculum, Azure deployment best practices, and enterprise-grade environment setup procedures.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Azure development environment setup while maintaining technical accuracy and reflecting industry best practices for cloud security learning paths.*
