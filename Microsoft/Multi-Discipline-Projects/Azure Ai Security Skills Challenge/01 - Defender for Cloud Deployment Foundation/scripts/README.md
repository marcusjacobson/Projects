# Microsoft Defender for Cloud Deployment Scripts

This folder contains a comprehensive suite of PowerShell scripts for deploying, configuring, and managing Microsoft Defender for Cloud infrastructure with automated validation and decommission capabilities.

## 🚀 Quick Start

### Complete Automated Deployment

For a full end-to-end deployment, use the orchestrator script:

```powershell
# Complete deployment with preview
.\Deploy-Complete.ps1 -EnvironmentName "securitylab" -SecurityContactEmail "admin@company.com" -WhatIf

# Execute complete deployment
.\Deploy-Complete.ps1 -EnvironmentName "securitylab" -SecurityContactEmail "admin@company.com"
```

## 📁 Available Scripts

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
| **Deploy-Sentinel.ps1** | Deploy Microsoft Sentinel | SIEM capabilities and data connector configuration |
| **Deploy-AutoShutdown.ps1** | Configure VM auto-shutdown | Power management for cost optimization |
| **Deploy-ComplianceAnalysis.ps1** | Deploy compliance monitoring | Security posture assessment and governance |
| **Deploy-CostAnalysis.ps1** | Configure cost monitoring | Cost optimization recommendations and alerts |

### ✅ Validation & Testing Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Test-DeploymentValidation.ps1** | Comprehensive deployment validation | Multi-component validation, scoring, detailed reporting |
| **Test-FinalLabValidation.ps1** | Complete lab validation | End-to-end validation and readiness assessment |
| **Test-SentinelValidation.ps1** | Sentinel-specific validation | SIEM configuration and data connector validation |
| **Test-UnifiedSecurityReadiness.ps1** | Week 2 readiness validation | Unified security operations bridge validation |

### 🧹 Management Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| **Remove-DefenderInfrastructure.ps1** | Clean deployment (decommission) | Safe resource removal, validation, confirmation |

## 🔧 Script Features

All deployment scripts include:

- ✅ **What-If Mode**: Preview changes before execution (`-WhatIf`).
- ✅ **Force Mode**: Skip confirmation prompts (`-Force`).
- ✅ **Validation Framework**: Multi-phase validation (pre-deployment, template, post-deployment).
- ✅ **Error Handling**: Comprehensive error detection and user-friendly messaging.
- ✅ **Status Reporting**: Detailed progress reporting and status verification.
- ✅ **Parameter Management**: Flexible parameter handling with sensible defaults.

## 🎯 Script Execution Best Practices

### Recommended Deployment Order

1. **Deploy infrastructure**: `Deploy-InfrastructureFoundation.ps1`.
2. **Deploy virtual machines**: `Deploy-VirtualMachines.ps1`.
3. **Enable Defender plans**: `Deploy-DefenderPlans.ps1`.
4. **Configure security features**: `Deploy-SecurityFeatures.ps1`.
5. **Deploy Sentinel (optional)**: `Deploy-Sentinel.ps1`.
6. **Validate deployment**: `Test-DeploymentValidation.ps1`.

### Parameter Management Guidelines

- Use consistent `EnvironmentName` across all scripts.
- Specify `Location` for regional compliance requirements.
- Provide `SecurityContactEmail` for proper security alerting.
- Use `-WhatIf` parameter for preview before execution.
- Use `-Force` parameter for automated deployments without prompts.

### Error Handling Guidelines

- Review error messages carefully - scripts provide detailed diagnostics.
- Use validation scripts to identify configuration issues.
- Check Azure Portal for partial deployment status.
- Retry individual deployment phases as needed.
- Monitor Azure activity logs for detailed error information.

## 🔧 Configuration Templates

The `templates/` folder contains JSON configuration templates:

| Template | Purpose | Usage |
|----------|---------|-------|
| **jit-policy-windows.json** | Windows JIT VM Access policy | RDP port 3389 configuration |
| **jit-policy-linux.json** | Linux JIT VM Access policy | SSH port 22 configuration |

### Template Features

- Reusable JSON configuration templates.
- Placeholder replacement for dynamic values.
- Environment-specific customization support.
- Consistent security policy application.

## 📊 Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure Owner/Contributor access at subscription level.
2. **Resource Conflicts**: Check for existing resources with identical names.
3. **Region Availability**: Verify all services are available in target region.
4. **Quota Limits**: Check subscription quotas for VMs and storage resources.

### Diagnostic Commands

```powershell
# Check Azure login status
az account show

# Verify resource group existence
az group show --name "rg-aisec-defender-securitylab"

# Check Defender plan status
az security pricing list

# Validate virtual machine status
az vm list --resource-group "rg-aisec-defender-securitylab"
```

## 🔗 Integration Capabilities

These scripts integrate with:

- **Azure Portal**: Manual configuration steps and validation.
- **Microsoft Sentinel**: SIEM data connector configuration.
- **Azure Resource Manager**: Bicep template integration.
- **Azure CLI**: Command-line automation capabilities.
- **PowerShell**: Native Windows automation environment.

## 📋 Prerequisites

All scripts require:

- **Azure CLI** installed and authenticated.
- **PowerShell 5.1** or higher.
- **Azure permissions** (Owner, Contributor, or Security Admin).
- **Template files** available in `templates/` folder.

## 📖 Additional Resources

- [Main Deployment Guide](../01.02%20Defender%20for%20Cloud%20Foundation/Azure%20Portal/deploy-defender-for-cloud-azure-portal.md)
- [Microsoft Defender for Cloud Documentation](https://docs.microsoft.com/en-us/azure/defender-for-cloud/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
- [PowerShell Azure Module](https://docs.microsoft.com/en-us/powershell/azure/)

---

## 🤖 AI-Assisted Content Generation

This PowerShell automation script collection for Microsoft Defender for Cloud was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The scripts, validation logic, deployment workflows, and documentation were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of automated Microsoft Defender for Cloud deployment procedures while maintaining technical accuracy and reflecting modern PowerShell automation best practices.*