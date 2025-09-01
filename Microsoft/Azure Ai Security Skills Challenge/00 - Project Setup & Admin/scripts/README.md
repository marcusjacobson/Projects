# Week 00 - PowerShell Scripts Documentation

This directory contains PowerShell scripts for automated setup and validation of the Azure AI Security Skills Challenge development environment. These scripts follow the project's PowerShell style guide and provide comprehensive automation for environment preparation.

## 📋 Script Overview

### 🔧 Environment Setup Scripts

| Script | Purpose | Execution Time | Prerequisites |
|--------|---------|----------------|---------------|
| `Install-DevelopmentEnvironment.ps1` | Automated installation of Azure CLI, PowerShell modules, and VS Code extensions | 10-15 minutes | Windows 10/11, PowerShell 5.1+, Internet connectivity |

### 🔍 Validation and Testing Scripts

| Script | Purpose | Execution Time | Prerequisites |
|--------|---------|----------------|---------------|
| `Test-EnvironmentValidation.ps1` | Comprehensive validation of development environment setup | 2-3 minutes | Azure CLI and PowerShell Az modules installed |

## 🚀 Quick Start Guide

### Step 1: Complete Environment Installation

Run the installation script to set up all required tools:

```powershell
# Complete installation with all components
.\Install-DevelopmentEnvironment.ps1

# Install specific components only
.\Install-DevelopmentEnvironment.ps1 -SkipAzureCLI -SkipAuthentication
```

### Step 2: Validate Environment Setup

Verify all components are properly configured:

```powershell
# Complete validation with detailed output
.\Test-EnvironmentValidation.ps1 -DetailedOutput

# Quick validation with results export
.\Test-EnvironmentValidation.ps1 -ExportResults
```

## 📊 Script Details

### Install-DevelopmentEnvironment.ps1

**Purpose**: Automated installation and configuration of all required Azure development tools.

**Key Features**:

- Azure CLI installation with latest version checking
- PowerShell Az module installation and configuration
- Visual Studio Code extension installation (6 required extensions)
- Git configuration for repository management
- Azure authentication setup for both CLI and PowerShell
- Comprehensive error handling and progress reporting

**Parameters**:

- `-SkipAzureCLI`: Skip Azure CLI installation
- `-SkipPowerShellModules`: Skip PowerShell module installation
- `-SkipVSCodeExtensions`: Skip VS Code extension installation
- `-SkipAuthentication`: Skip automated Azure authentication
- `-InstallPath`: Custom installation path for portable tools

**Example Usage**:

```powershell
# Full installation
.\Install-DevelopmentEnvironment.ps1

# Update only PowerShell modules
.\Install-DevelopmentEnvironment.ps1 -SkipAzureCLI -SkipVSCodeExtensions -SkipAuthentication
```

### Test-EnvironmentValidation.ps1

**Purpose**: Comprehensive validation of development environment prerequisites.

**Key Features**:

- Azure CLI installation and authentication validation
- PowerShell Az module version checking
- Azure subscription permissions verification
- East US region access validation
- Resource provider registration status
- Detailed remediation guidance for failed tests

**Parameters**:

- `-SkipResourceProviderCheck`: Skip resource provider validation
- `-DetailedOutput`: Display comprehensive information for each test
- `-ExportResults`: Export validation results to JSON file

**Example Usage**:

```powershell
# Standard validation
.\Test-EnvironmentValidation.ps1

# Detailed validation with export
.\Test-EnvironmentValidation.ps1 -DetailedOutput -ExportResults
```

## 🎯 Execution Workflow

### Recommended Script Execution Order

1. **Initial Setup**: `Install-DevelopmentEnvironment.ps1`
   - Installs all required tools and performs initial authentication
   - Creates foundation for subsequent scripts

2. **Environment Validation**: `Test-EnvironmentValidation.ps1`
   - Verifies all components are properly configured
   - Identifies any setup issues before proceeding

### Validation Workflow

For ongoing environment health checks:

```powershell
# Weekly environment validation
.\Test-EnvironmentValidation.ps1 -DetailedOutput
```

## ⚠️ Common Issues and Solutions

### Azure CLI Authentication Issues

**Problem**: Azure CLI not authenticated or expired tokens.

**Solution**:

```powershell
# Clear authentication cache
az logout
az cache purge

# Re-authenticate
az login
```

### PowerShell Module Import Failures

**Problem**: Az modules not importing properly.

**Solution**:

```powershell
# Force reinstall Az modules
Uninstall-Module -Name Az -AllVersions -Force
Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser
Import-Module Az -Force
```

### Insufficient Permissions

**Problem**: Subscription operations fail due to insufficient permissions.

**Validation**:

```powershell
# Check current role assignments
Get-AzRoleAssignment -SignInName (Get-AzContext).Account.Id
```

**Resolution**: Ensure **Owner** or **Contributor** role at subscription level.

### Regional Access Issues

**Problem**: East US region not accessible.

**Validation**:

```powershell
# Check available regions
az account list-locations --output table

# Verify specific service availability
az provider show --namespace Microsoft.CognitiveServices --query "resourceTypes[?resourceType=='accounts'].locations"
```

## 📈 Success Metrics

### Environment Setup and Validation Success Criteria

**Setup Requirements:**

- [ ] Azure CLI installed and authenticated
- [ ] PowerShell Az modules installed (version 5.1+)
- [ ] Visual Studio Code with 6 required Azure extensions
- [ ] Git configured for repository management
- [ ] East US region access confirmed
- [ ] Required resource providers registered

**Expected Validation Results from Test-EnvironmentValidation.ps1:**

- 6/6 tests passed (100% success rate)
- All components showing "Passed" status
- No critical failures or missing prerequisites
- East US region accessible for all required services

## 🔗 Integration with Project Structure

### Relationship to Other Weeks

These Week 00 scripts prepare the environment for:

- **Week 01**: Defender for Cloud infrastructure deployments
- **Week 02**: AI service provisioning and integration
- **Week 03-09**: Advanced security and AI workload deployments

### Style Guide Compliance

All scripts follow the [PowerShell Style Guide](../../Style%20Guides/powershell-style-guide.md):

- **Individual Script Classification**: Use "Step" terminology
- **Green color scheme** for step headers
- **Comprehensive preambles** with industry-standard documentation
- **Proper error handling** with try-catch blocks
- **Status indicators** with emoji usage
- **Marcus Jacobson authorship** with GitHub Copilot acknowledgment

## 📚 Additional Resources

### Azure Documentation

- **Azure CLI**: [Installation Guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Azure PowerShell**: [Installation Guide](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps)

### Project Integration

- **Style Guides**: [Markdown](../../Style%20Guides/markdown-style-guide.md) and [PowerShell](../../Style%20Guides/powershell-style-guide.md)
- **Week 01 README**: [Defender for Cloud Deployment Mastery](../../01%20-%20Defender%20for%20Cloud%20Deployment%20Mastery/README.md)

---

## 🤖 AI-Assisted Content Generation

This comprehensive PowerShell scripts documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the project's PowerShell style guide standards, Azure deployment automation best practices, and comprehensive environment setup procedures.

*AI tools were used to enhance productivity and ensure comprehensive coverage of PowerShell automation capabilities while maintaining technical accuracy and reflecting enterprise-grade scripting standards for Azure development environments.*
