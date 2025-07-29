# Security Configuration Scripts

This folder contains PowerShell scripts for automating security feature configuration and management tasks.

## 🔐 Available Scripts

### `Configure-JitAccess.ps1`

Automates the configuration of Just-in-Time (JIT) VM Access policies for Windows and Linux virtual machines.

**Purpose**:

- Discovers VMs in a resource group automatically
- Applies JIT policies using reusable JSON templates
- Provides verification and status reporting

**Usage**:

```powershell
# Basic usage
.\scripts\Configure-JitAccess.ps1 -ResourceGroupName "rg-aisec-defender-test" -SubscriptionId "your-subscription-id"

# With custom location
.\scripts\Configure-JitAccess.ps1 -ResourceGroupName "rg-aisec-defender-test" -SubscriptionId "your-subscription-id" -Location "eastus"
```

**Parameters**:

- `ResourceGroupName` (Required) - Name of the resource group containing VMs
- `SubscriptionId` (Required) - Azure subscription ID
- `Location` (Optional) - Azure region for JIT policies (default: "westus")

**Features**:

- ✅ Automatic VM discovery
- ✅ Template-based configuration
- ✅ Error handling and validation
- ✅ Status reporting and verification
- ✅ Colorized output for better readability

### `Remove-DefenderInfrastructure.ps1`

Comprehensive decommission script that safely removes all resources created by the Defender for Cloud Infrastructure-as-Code deployment in the correct logical order.

**Purpose**:

- Safely removes all deployment resources in logical order
- Handles security configuration cleanup
- Provides validation and verification of removal
- Preserves subscription-level configurations that may be shared

**Usage**:

```powershell
# Preview what will be deleted (recommended first step)
# Microsoft Defender for Cloud - Deployment Scripts

This folder contains a comprehensive suite of modular PowerShell scripts for deploying and managing Microsoft Defender for Cloud infrastructure. The scripts follow a modular approach that allows for step-by-step deployment with comprehensive validation at each phase.

## 🚀 Quick Start

### Complete Automated Deployment

For a full end-to-end deployment, use the orchestrator script:

```powershell
# Complete deployment with preview
.\Deploy-Complete.ps1 -EnvironmentName "securitylab" -SecurityContactEmail "admin@company.com" -WhatIf

# Execute complete deployment
.\Deploy-Complete.ps1 -EnvironmentName "securitylab" -SecurityContactEmail "admin@company.com"
```

### Manual Phase-by-Phase Deployment

Deploy each phase individually for better control:

```powershell
# Phase 1: Infrastructure Foundation
.\Deploy-InfrastructureFoundation.ps1 -EnvironmentName "securitylab"

# Phase 2: Virtual Machines
.\Deploy-VirtualMachines.ps1 -EnvironmentName "securitylab"

# Phase 3: Defender Plans
.\Deploy-DefenderPlans.ps1 -SecurityContactEmail "admin@company.com"

# Phase 4: Security Features
.\Deploy-SecurityFeatures.ps1 -EnvironmentName "securitylab"

# Phase 5: Validation
.\Test-DeploymentValidation.ps1 -EnvironmentName "securitylab" -DetailedReport -ExportResults
```

## 📁 Script Overview

### 🎬 Orchestration Script

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Deploy-Complete.ps1** | Complete deployment orchestrator | Multi-phase execution, error handling, progress tracking |

### 🏗️ Deployment Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Deploy-InfrastructureFoundation.ps1** | Deploy base infrastructure | Resource group, Log Analytics, VNet, Storage |
| **Deploy-VirtualMachines.ps1** | Deploy and configure VMs | Windows/Linux VMs, security extensions, validation |
| **Deploy-DefenderPlans.ps1** | Configure Defender plans | Enable plans, security contacts, pricing validation |
| **Deploy-SecurityFeatures.ps1** | Configure security features | JIT access, extensions validation, portal guidance |

### ✅ Validation & Management Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Test-DeploymentValidation.ps1** | Comprehensive deployment validation | Multi-component validation, scoring, detailed reporting |
| **Configure-JitAccess.ps1** | JIT VM Access configuration | Policy creation, port configuration, access management |
| **Remove-DefenderInfrastructure.ps1** | Clean deployment (decommission) | Safe resource removal, validation, confirmation |

## 🔧 Script Features

All deployment scripts include:

- ✅ **What-If Mode**: Preview changes before execution (`-WhatIf`)
- ✅ **Force Mode**: Skip confirmation prompts (`-Force`)
- ✅ **Validation Framework**: Multi-phase validation (pre-deployment, template, post-deployment)
- ✅ **Error Handling**: Comprehensive error detection and user-friendly messaging
- ✅ **Status Reporting**: Detailed progress reporting and status verification
- ✅ **Parameter Management**: Flexible parameter handling with sensible defaults

## 📋 Detailed Script Documentation

### Deploy-Complete.ps1 (Orchestrator)

**Purpose**: Orchestrates the complete deployment of Microsoft Defender for Cloud using all modular scripts in sequence.

**Parameters**:
- `-EnvironmentName`: Environment identifier (default: "securitylab")
- `-Location`: Azure region (default: "East US")
- `-SecurityContactEmail`: Email for security alerts
- `-AdminUsername`: VM admin username (default: "azureadmin")
- `-WhatIf`: Preview mode without execution
- `-Force`: Skip confirmations
- `-Phases`: Deploy specific phases (1-5)

**Example Usage**:
```powershell
# Deploy only infrastructure and VMs
.\Deploy-Complete.ps1 -EnvironmentName "mylab" -Phases @(1,2)

# Preview complete deployment
.\Deploy-Complete.ps1 -EnvironmentName "prod" -WhatIf
```

### Deploy-InfrastructureFoundation.ps1

**Purpose**: Deploys foundational infrastructure including resource group, Log Analytics workspace, virtual network, and storage account.

**Deployment Phases**:
1. **Pre-deployment Validation**: Resource naming, parameter validation
2. **Template Validation**: Bicep template syntax and parameter checking
3. **What-If Analysis**: Preview resource changes
4. **Resource Deployment**: Execute Bicep template deployment
5. **Post-deployment Verification**: Validate deployed resources

**Key Resources Created**:
- Resource Group: `rg-aisec-defender-{EnvironmentName}`
- Log Analytics Workspace: `log-aisec-defender-{uniqueId}`
- Virtual Network: `vnet-aisec-defender-{uniqueId}`
- Storage Account: `staisecdefender{uniqueId}`

**Example Usage**:
```powershell
# Preview infrastructure deployment
.\Deploy-InfrastructureFoundation.ps1 -EnvironmentName "mylab" -Location "West US 2" -WhatIf

# Deploy infrastructure
.\Deploy-InfrastructureFoundation.ps1 -EnvironmentName "mylab" -Location "West US 2"
```

### Deploy-VirtualMachines.ps1

**Purpose**: Deploys Windows and Linux virtual machines with security extensions and proper configuration.

**Deployment Phases**:
1. **Foundation Dependency Check**: Verify infrastructure exists
2. **VM Parameter Generation**: Create admin passwords and VM configurations
3. **Template Validation**: Validate VM deployment templates
4. **VM Deployment**: Deploy Windows and Linux VMs
5. **Extension and Validation**: Install security extensions and verify status

**Key Resources Created**:
- Windows VM: `vm-win-{uniqueId}` with Azure Monitor Agent
- Linux VM: `vm-linux-{uniqueId}` with Azure Monitor Agent
- Network Security Groups with appropriate rules
- VM extensions for monitoring and security

**Example Usage**:
```powershell
# Deploy VMs with custom admin username
.\Deploy-VirtualMachines.ps1 -EnvironmentName "mylab" -AdminUsername "labadmin"

# Preview VM deployment
.\Deploy-VirtualMachines.ps1 -EnvironmentName "mylab" -WhatIf
```

### Deploy-DefenderPlans.ps1

**Purpose**: Configures Microsoft Defender for Cloud pricing plans and security contacts.

**Configuration Phases**:
1. **Current State Assessment**: Check existing Defender plans
2. **Plan Configuration**: Enable Defender for Servers and other plans
3. **Security Contact Setup**: Configure notification email and preferences
4. **Validation**: Verify plan enablement and contact configuration

**Key Configurations**:
- Defender for Servers Plan 2 (full feature set)
- Security contact with email notifications
- Alert notification preferences
- Plan validation and cost estimation

**Example Usage**:
```powershell
# Configure Defender plans with security contact
.\Deploy-DefenderPlans.ps1 -SecurityContactEmail "security@company.com"

# Preview Defender plan changes
.\Deploy-DefenderPlans.ps1 -SecurityContactEmail "admin@company.com" -WhatIf
```

### Deploy-SecurityFeatures.ps1

**Purpose**: Configures advanced security features including JIT VM Access and additional security protections.

**Configuration Phases**:
1. **Environment Validation**: Verify prerequisites (VMs, Defender plans)
2. **JIT VM Access Configuration**: Create policies for Windows/Linux VMs
3. **VM Extensions Validation**: Check security extension status
4. **Security Configuration Validation**: Verify applied configurations
5. **Portal Integration Guidance**: Provide manual configuration steps

**Key Features Configured**:
- JIT VM Access policies (RDP/SSH)
- Security extension validation
- Portal integration guidance for FIM and Sentinel
- Advanced threat protection features

**Example Usage**:
```powershell
# Configure security features
.\Deploy-SecurityFeatures.ps1 -EnvironmentName "mylab" -Location "East US"

# Preview security configurations
.\Deploy-SecurityFeatures.ps1 -EnvironmentName "mylab" -WhatIf
```

### Test-DeploymentValidation.ps1

**Purpose**: Performs comprehensive end-to-end validation of the entire Microsoft Defender for Cloud deployment.

**Validation Phases**:
1. **Infrastructure Validation**: Resource group, Log Analytics, VNet, storage
2. **Virtual Machines Validation**: VM status, extensions, configuration
3. **Defender Plans Validation**: Plan enablement, security contacts
4. **Security Features Validation**: JIT policies, recommendations
5. **Overall Assessment**: Scoring, recommendations, reporting

**Validation Features**:
- Percentage-based scoring system
- Detailed component status reporting
- Export capabilities (JSON format)
- Actionable recommendations
- Health status indicators

**Example Usage**:
```powershell
# Complete validation with detailed report
.\Test-DeploymentValidation.ps1 -EnvironmentName "mylab" -DetailedReport -ExportResults

# Quick validation check
.\Test-DeploymentValidation.ps1 -EnvironmentName "mylab"
```

## 🔧 Configuration Management

### Configure-JitAccess.ps1

**Purpose**: Specialized script for configuring Just-in-Time VM Access policies.

**Features**:
- Template-based JIT policy creation
- Windows and Linux VM support
- Port configuration (RDP 3389, SSH 22)
- Access duration management
- Policy validation

### Remove-DefenderInfrastructure.ps1

**Purpose**: Clean decommission of Defender for Cloud infrastructure for testing and cleanup.

**Decommission Process**:
- Safe resource removal with confirmation
- Dependency order management
- Defender plan disabling
- Complete environment cleanup
- Validation of removal

## 🎯 Best Practices

### Script Execution Order

1. **Always start with infrastructure**: `Deploy-InfrastructureFoundation.ps1`
2. **Deploy compute resources**: `Deploy-VirtualMachines.ps1`
3. **Enable security plans**: `Deploy-DefenderPlans.ps1`
4. **Configure security features**: `Deploy-SecurityFeatures.ps1`
5. **Validate deployment**: `Test-DeploymentValidation.ps1`

### Parameter Management

- Use consistent `EnvironmentName` across all scripts
- Specify `Location` for regional compliance
- Provide `SecurityContactEmail` for proper alerting
- Use `-WhatIf` for preview before execution
- Use `-Force` for automated deployments

### Error Handling

- Review error messages carefully - scripts provide detailed diagnostics
- Use validation scripts to identify issues
- Check Azure Portal for partial deployments
- Retry individual phases as needed

### Security Considerations

- Store credentials securely
- Use least privilege access
- Review generated passwords
- Monitor security recommendations
- Regular validation runs

## 📊 Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure Owner/Contributor access
2. **Resource Conflicts**: Check for existing resources with same names
3. **Region Availability**: Verify services available in target region
4. **Quota Limits**: Check subscription quotas for VMs and resources

### Diagnostic Commands

```powershell
# Check Azure login status
az account show

# Verify resource group
az group show --name "rg-aisec-defender-securitylab"

# Check Defender plans
az security pricing list

# Validate VMs
az vm list --resource-group "rg-aisec-defender-securitylab"
```

## 🔗 Integration

These scripts integrate with:

- **Azure Portal**: Manual configuration steps provided
- **Microsoft Sentinel**: Data connector guidance included
- **Azure Resource Manager**: Bicep template integration
- **Azure CLI**: Command-line automation
- **PowerShell**: Native Windows automation

## 📖 Additional Resources

- [Main Deployment Guide](../deploy-defender-for-cloud-azure-portal.md)
- [Microsoft Defender for Cloud Documentation](https://docs.microsoft.com/en-us/azure/defender-for-cloud/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
- [PowerShell Azure Module](https://docs.microsoft.com/en-us/powershell/azure/)

# Interactive decommission with confirmation prompts
.\scripts\Remove-DefenderInfrastructure.ps1 -ResourceGroupName "rg-aisec-defender-test"

# Automated decommission without prompts
.\scripts\Remove-DefenderInfrastructure.ps1 -ResourceGroupName "rg-aisec-defender-test" -Force

# Complete lab teardown including all Defender plans (perfect for lab environments)
.\scripts\Remove-DefenderInfrastructure.ps1 -ResourceGroupName "rg-aisec-defender-test" -DisableDefenderPlans -Force

# Target specific subscription with complete teardown
.\scripts\Remove-DefenderInfrastructure.ps1 -ResourceGroupName "rg-aisec-defender-test" -SubscriptionId "your-subscription-id" -DisableDefenderPlans -Force
```

**Parameters**:

- `ResourceGroupName` (Required) - Name of the resource group to decommission
- `SubscriptionId` (Optional) - Azure subscription ID (uses current if not specified)
- `Force` (Optional) - Skip confirmation prompts
- `WhatIf` (Optional) - Preview changes without executing
- `DisableDefenderPlans` (Optional) - **NEW!** Programmatically disable all Defender for Cloud pricing plans for complete lab teardown

**Decommission Phases**:

1. **Discovery and Validation** - Discovers all resources and validates access
2. **Security Configuration Removal** - Removes JIT policies, Sentinel onboarding
3. **VM Component Removal** - Stops and deallocates virtual machines
4. **Resource Group Deletion** - Removes entire resource group and all resources
5. **Enhanced Subscription-Level Management** - **NEW!** Optionally disables all Defender pricing plans programmatically
6. **Enhanced Post-Decommission Validation** - Verifies successful removal with comprehensive checks

**Features**:

- ✅ Logical deletion order to prevent dependency issues
- ✅ Comprehensive resource discovery and validation
- ✅ Safe handling of VM shutdown and deallocation
- ✅ Security configuration cleanup (JIT, Sentinel)
- ✅ Progress monitoring and status reporting
- ✅ **Enhanced Post-Decommission Validation** with 10 comprehensive checks:
  - Resource group deletion verification
  - All resources removal confirmation
  - JIT policies cleanup validation
  - Virtual machines removal verification
  - Network resources cleanup confirmation
  - Log Analytics workspaces removal validation
  - Storage accounts cleanup verification
  - VM extensions removal confirmation
  - Sentinel onboarding cleanup validation
  - **NEW!** Defender pricing plans disabling verification
- ✅ **Programmatic Defender Plan Management** - Complete automation of Defender plan disabling
- ✅ **Complete Lab Teardown Capability** - Perfect for training environments and demo setups
- ✅ **Validation Score Reporting** - Percentage-based score with pass/fail details
- ✅ **Automated Issue Detection** - Identifies remaining resources or configurations
- ✅ Subscription-level configuration preservation
- ✅ Detailed logging and error handling
- ✅ **Re-run Recommendations** - Suggests corrective actions for failed validations## 🔧 Script Development Guidelines

### Adding New Scripts

When adding new automation scripts to this folder:

1. **Follow PowerShell Best Practices**:
   - Use approved verbs (Get, Set, New, Remove, etc.)
   - Include parameter validation
   - Provide meaningful help documentation
   - Use consistent error handling

2. **Template Integration**:
   - Leverage JSON templates from `../templates/` folder
   - Use placeholder replacement for dynamic values
   - Maintain template reusability across environments

3. **Documentation Requirements**:
   - Include script purpose and usage examples
   - Document all parameters and their purposes
   - Provide troubleshooting guidance
   - Update this README with new script information

### Example Script Structure

```powershell
# Script Name and Purpose
# Brief description of what the script does

param(
    [Parameter(Mandatory=$true, HelpMessage="Description")]
    [string]$RequiredParameter,
    
    [Parameter(Mandatory=$false)]
    [string]$OptionalParameter = "DefaultValue"
)

# Script implementation with error handling
try {
    # Main script logic
    Write-Host "Script execution started..." -ForegroundColor Green
    
    # Use templates from ../templates/ folder
    # Provide status updates and validation
    
    Write-Host "Script completed successfully!" -ForegroundColor Green
} catch {
    Write-Error "Script failed: $_"
    exit 1
}
```

## 📋 Prerequisites

All scripts in this folder assume:

- **Azure CLI** installed and authenticated
- **PowerShell 5.1** or higher
- **Appropriate Azure permissions** (Contributor or Security Admin)
- **Template files** available in `../templates/` folder

## 🔗 Related Documentation

- [Main Deployment Guide](../deploy-defender-for-cloud-cli-iac.md)
- [Configuration Templates](../templates/README.md)
- [Project Organization](../README.md#-project-organization)
