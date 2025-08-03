# Week 1 – AI-Infused Security Foundations

This week focuses on establishing a foundational understanding of Microsoft Defender for Cloud and Security Copilot. The goal is to explore how AI enhances security operations and to begin building a prompt library that supports real-world security scenarios.

## 🎯 Objectives

- Review Microsoft Security Copilot documentation and use cases.
- Deploy Microsoft Defender for Cloud using both the Azure Portal and Infrastructure-as-Code (Bicep/Terraform).
- Enable AI-driven recommendations and alerts.
- Simulate a benign threat scenario to observe AI insights.
- Begin documenting prompt examples for Defender for Cloud and Copilot.
- Publish findings and prompt examples to the GitHub Pages site.

## 📁 Deliverables

- Defender for Cloud deployed via Azure Portal and Bicep/Terraform.
- AI-driven recommendations and alerts enabled and validated.
- Simulated threat scenario executed and insights captured.
- Initial prompt entries created for:
  - Threat detection.
  - Alert summarization.
  - AI-assisted remediation.
- Findings and prompt examples published to the Hugo site.

## ✅ Checklist

- [ ] Reviewed Microsoft Security Copilot documentation.
- [x] Defender for Cloud deployed via Azure Portal.
- [x] Defender for Cloud deployed via Modular Infrastructure-as-Code (PowerShell + Bicep).
- [x] Defender for Cloud deployed via Complete Automation (PowerShell + Bicep).
- [x] Decommission script created for lab cleanup.
- [ ] AI-driven recommendations and alerts enabled.
- [ ] Benign threat scenario simulated.
- [ ] Prompt entries created for Defender for Cloud and Copilot.
- [ ] Findings published to GitHub Pages.

## 📂 Project Files

This week's project includes the following key files and resources:

### 📋 Deployment Guides

- **[Deploy Microsoft Defender for Cloud via Azure Portal](./deploy-defender-for-cloud-azure-portal.md)** - Comprehensive step-by-step guide for deploying Defender for Cloud through the Azure Portal interface. Best for learning and understanding each component.

- **[Deploy Microsoft Defender for Cloud via Modular Infrastructure-as-Code](./deploy-defender-for-cloud-modular-iac.md)** - Structured Infrastructure-as-Code approach using Azure CLI, PowerShell, and modular Bicep templates for controlled, step-by-step automated deployment.

- **[Deploy Microsoft Defender for Cloud via Complete Automation](./deploy-defender-for-cloud-complete-automation.md)** - Fully automated Infrastructure-as-Code deployment using single-command PowerShell script with comprehensive Bicep templates for enterprise environments.

- **[Decommission Microsoft Defender for Cloud](./decommission-defender-for-cloud.md)** - Complete lab reset guide with automated PowerShell script for safely removing Defender for Cloud and restoring the environment to a clean state.

### 📚 Learning Resources

- **[Learning Resources](./learning-resources.md)** - Curated collection of Microsoft documentation, tutorials, and best practices for AI-infused security foundations.

### 🛠️ Infrastructure-as-Code

- **[Bicep Templates](./infra/)** - Modular Azure Bicep templates for infrastructure deployment organized by function (security, monitoring, compute).
- **[PowerShell Scripts](./scripts/)** - Comprehensive automated deployment and management scripts including complete automation and decommission capabilities.
- **[Configuration Templates](./scripts/templates/)** - JSON templates for advanced security feature configuration including JIT access policies.

## 📁 Project Organization

The project follows a well-organized folder structure to separate concerns and maintain modularity:

```text
01 - AI-Infused Security Foundations/
├── 📋 Deployment Guides/
│   ├── README.md                                      # Project overview and guide comparison
│   ├── deploy-defender-for-cloud-azure-portal.md     # Azure Portal deployment guide
│   ├── deploy-defender-for-cloud-modular-iac.md      # Modular Infrastructure-as-Code guide
│   ├── deploy-defender-for-cloud-complete-automation.md # Complete automation guide
│   ├── decommission-defender-for-cloud.md            # Environment cleanup guide
│   └── learning-resources.md                         # Curated learning materials
├── 🏗️ Infrastructure-as-Code/
│   └── infra/                                         # Bicep templates and parameters
│       ├── main.bicep                                 # Main orchestration template
│       ├── main.parameters.json                       # Environment configuration
│       ├── foundation.parameters.json                 # Foundation infrastructure parameters
│       └── modules/                                   # Modular Bicep components
│           ├── security/                              # Security-focused modules
│           ├── monitoring/                            # Monitoring and logging modules
│           └── compute/                               # Virtual machine deployment modules
└── 📊 PowerShell Scripts/
    └── scripts/                                       # Automated deployment and management
        ├── README.md                                  # Script usage documentation
        ├── Deploy-Complete.ps1                       # Complete automation deployment
        ├── Deploy-InfrastructureFoundation.ps1       # Foundation infrastructure
        ├── Deploy-DefenderPlans.ps1                  # Defender plan configuration
        ├── Deploy-SecurityFeatures.ps1               # Security feature enablement
        ├── Deploy-VirtualMachines.ps1                # Test VM deployment
        ├── Deploy-Sentinel.ps1                       # Sentinel integration
        ├── Remove-DefenderInfrastructure.ps1         # Decommission script
        ├── Test-DeploymentValidation.ps1             # Deployment validation
        ├── Test-FinalLabValidation.ps1               # Final lab validation
        └── templates/                                 # Configuration templates
            ├── jit-policy-windows.json               # Windows JIT access policy
            └── jit-policy-linux.json                 # Linux JIT access policy
```

### 🎯 Design Principles

- **📦 Modularity**: Bicep templates are organized by function (security, monitoring, compute).
- **🔄 Reusability**: JSON templates use placeholders for easy customization across environments.
- **📚 Documentation**: Each major component includes dedicated documentation.
- **🧹 Separation of Concerns**: Infrastructure code, configuration templates, and documentation are clearly separated.
- **🔧 Maintainability**: Clear naming conventions and folder structure for easy navigation.

## 🔄 Deployment Guide Comparison

All three deployment guides achieve the same security outcomes while catering to different preferences, skill levels, and organizational requirements. Here's a comparison to help you choose the right approach:

### **🎯 Choose Your Deployment Approach**

#### **🖱️ Azure Portal Guide** - *Best for Learning*

- **Target Audience**: Security professionals new to Defender for Cloud
- **Key Benefits**: Visual interface, step-by-step learning, detailed explanations
- **Time Investment**: 45-60 minutes (guided learning experience)
- **Best For**: Understanding concepts, one-time deployments, educational purposes

#### **🔧 Modular Infrastructure-as-Code** - *Best for Controlled Automation*

- **Target Audience**: DevOps engineers, infrastructure specialists
- **Key Benefits**: Step-by-step automation, modular approach, full control
- **Time Investment**: 15-20 minutes (structured automation)
- **Best For**: Production environments, learning automation, controlled deployments

#### **⚡ Complete Automation** - *Best for Enterprise Deployment*

- **Target Audience**: Enterprise architects, automation specialists
- **Key Benefits**: Single-command deployment, fully automated, enterprise-ready
- **Time Investment**: 5-10 minutes (fully automated)
- **Best For**: Large-scale deployments, CI/CD pipelines, enterprise environments

### **🔍 Feature Comparison Matrix**

| Feature | Portal Guide | Modular IaC | Complete Automation |
|---------|--------------|-------------|-------------------|
| **Learning Value** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Deployment Speed** | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Repeatability** | ⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Customization** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Enterprise Ready** | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

## 🧹 Lab Cleanup

After completing the security testing workflows, use the automated decommission script to safely remove all Defender for Cloud resources and return your environment to a clean state.

---

## 🔗 Quick Navigation

- [Project Root](/Microsoft/Azure%20Ai%20Security%20Skills%20Challenge/README.md)

---
