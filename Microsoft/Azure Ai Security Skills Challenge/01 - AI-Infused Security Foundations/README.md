# Week 1 – AI-Infused Security Foundations

This fo- **[Configuration Templates](./templates/)** - JSON templates for advanced security feature configuration including JIT access and File Integrity Monitoring.
- **Terraform Configurations** - *(Coming Soon)* Terraform configurations for Infrastructure-as-Code deployment approach.

## 📁 Project Organization

The project follows a well-organized folder structure to separate concerns and maintain modularity:

```
01 - AI-Infused Security Foundations/
├── 📋 Documentation/
│   ├── README.md                                    # Project overview and guide comparison
│   ├── deploy-defender-for-cloud-azure-portal.md   # Azure Portal deployment guide
│   ├── deploy-defender-for-cloud-cli-iac.md        # CLI & Infrastructure-as-Code guide
│   ├── decommission-defender-for-cloud.md          # Environment cleanup guide
│   └── learning-resources.md                       # Curated learning materials
├── 🏗️ Infrastructure-as-Code/
│   └── infra/                                       # Bicep templates and parameters
│       ├── main.bicep                               # Main orchestration template
│       ├── main.parameters.json                     # Environment configuration
│       └── modules/                                 # Modular Bicep components
│           ├── security/                            # Security-focused modules
│           │   ├── defender-pricing.bicep           # Defender plan configuration
│           │   └── security-contacts.bicep          # Security notification setup
│           ├── monitoring/                          # Monitoring and logging
│           │   └── log-analytics.bicep              # Log Analytics workspace
│           └── compute/                             # Virtual machine deployment
│               └── virtual-machines.bicep           # Test VM infrastructure
├── 🔧 Configuration Templates/
│   └── templates/                                   # JSON configuration templates
│       ├── README.md                                # Template usage documentation
│       ├── jit/                                     # Just-in-Time VM Access
│       │   ├── jit-windows-template.json            # Windows JIT policy template
│       │   ├── jit-linux-template.json             # Linux JIT policy template
│       │   └── jit-access-request-template.json    # JIT access request template
│       └── security/                                # Advanced security configurations
│           └── fim-configuration-template.json     # File Integrity Monitoring setup
└── 📊 Scripts/ (Future)
    └── Automation scripts for deployment and management
```

### 🎯 Design Principles

- **📦 Modularity**: Bicep templates are organized by function (security, monitoring, compute)
- **🔄 Reusability**: JSON templates use placeholders for easy customization across environments
- **📚 Documentation**: Each major component includes dedicated documentation
- **🧹 Separation of Concerns**: Infrastructure code, configuration templates, and documentation are clearly separated
- **🔧 Maintainability**: Clear naming conventions and folder structure for easy navigation

## 🔄 Deployment Guide Comparison focuses on establishing a foundational understanding of Microsoft Security Copilot and Defender for Cloud. The goal is to explore how AI enhances security operations and to begin building a prompt library that supports real-world security scenarios.

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

- [x] Reviewed Microsoft Security Copilot documentation  
- [x] Defender for Cloud deployed via Azure Portal  
- [ ] Defender for Cloud deployed via Bicep and PowerShell
- [ ] AI-driven recommendations and alerts enabled  
- [ ] Benign threat scenario simulated  
- [ ] Prompt entries created for Defender for Cloud and Copilot  
- [ ] Findings published to GitHub Pages  

## 📂 Project Files

This week's project includes the following key files and resources:

### 📋 Deployment Guides

- **[Deploy Microsoft Defender for Cloud via Azure Portal](./deploy-defender-for-cloud-azure-portal.md)** - Comprehensive step-by-step guide for deploying Defender for Cloud through the Azure Portal interface.
- **[Decommission Microsoft Defender for Cloud](./decommission-defender-for-cloud.md)** - Complete lab reset guide for safely removing Defender for Cloud and restoring the environment to a clean state.

### 📚 Learning Resources

- **[Learning Resources](./learning-resources.md)** - Curated collection of Microsoft documentation, tutorials, and best practices for AI-infused security foundations.

### 🛠️ Infrastructure-as-Code

- **[Deploy Microsoft Defender for Cloud using Azure CLI & Infrastructure-as-Code](./deploy-defender-for-cloud-cli-iac.md)** - Comprehensive Infrastructure-as-Code approach using Azure CLI, PowerShell, and Azure Bicep templates for automated and repeatable Defender for Cloud deployment.
- **[Bicep Templates](./infra/)** - Modular Azure Bicep templates for infrastructure deployment organized by function (security, monitoring, compute).
- **[Configuration Templates](./templates/)** - JSON templates for advanced security feature configuration including JIT access and File Integrity Monitoring.
- **Terraform Configurations** - *(Coming Soon)* Terraform configurations for Infrastructure-as-Code deployment approach.

## � Deployment Guide Comparison

Both deployment guides achieve the same security outcomes while catering to different preferences and organizational requirements. Here's a side-by-side comparison to help you choose the right approach:

### **🎯 Azure Portal vs Infrastructure-as-Code Guide Structure**

| Step # | **Azure Portal Guide (12 Steps)** | **Infrastructure-as-Code Guide (10 Steps)** | **Key Differences** |
|--------|-----------------------------------|---------------------------------------------|---------------------|
| **1-2** | 🖱️ Portal navigation & manual setup | 🔧 CLI setup & automated deployment | **IaC deploys everything at once** |
| **3-4** | ⚙️ Manual plan configuration | 🔍 Verification & testing | **Portal requires manual enabling** |
| **5** | 🖥️ Manual VM creation | 🔐 Security policy configuration | **Bicep has pre-deployed infrastructure** |
| **6-10** | ✅ Verification & advanced features | 📋 Security workflow alignment | **✅ Both follow identical security flow** |
| **11-12** | 🚨 Alert investigation & workbooks | 🚨 Enhanced SIEM integration & analytics | **Both include Sentinel/SIEM setup** |
| **Advanced** | 🔧 SIEM integration (after Step 12) | 🔧 SIEM integration (within Step 9) | **Different placement in workflow** |

### **🎯 Choose Azure Portal Guide If:**

- 🎓 **Learning Defender for Cloud** for the first time
- 👥 **Small team or individual** deployment  
- 🔍 **Focus on security operations** and alert investigation
- 🎯 **One-time or infrequent** deployments
- 📊 **Need interactive dashboards** and real-time investigation

### **🎯 Choose Infrastructure-as-Code Guide If:**

- 🏢 **Enterprise environment** with multiple deployments
- 🔄 **DevOps workflow** and automation requirements  
- ⚡ **Speed and consistency** are priorities
- 🔧 **Advanced integration** needs (Sentinel, XDR, etc.)
- 📝 **Version control** and infrastructure documentation required

### **🔍 Key Advantages Comparison**

| **Azure Portal Advantages** | **Infrastructure-as-Code Advantages** |
|----------------------------|---------------------------------------|
| 👆 **Visual interface** - Point-and-click simplicity | 🚀 **Complete automation** - Deploy everything in one command |
| 🎓 **Learning-friendly** - See each step and understand concepts | 🔄 **Repeatability** - Consistent, version-controlled deployments |
| 🔍 **Detailed investigation** - Step-by-step alert analysis | ⚡ **Speed** - Parallel resource creation, no manual clicking |
| 📊 **Interactive dashboards** - Real-time workbook configuration | 🔧 **Advanced integration** - CLI-driven Sentinel setup |
| 🔧 **Manual control** - Fine-grained individual settings | 💻 **DevOps-ready** - CLI-first approach for automation |

### **✅ Intentional Differences**

Both guides are **aligned for Steps 3-10** (security configuration workflow) but differ intentionally in:

- **Setup Method**: Portal navigation vs CLI environment preparation
- **VM Creation**: Manual creation vs pre-deployed infrastructure  
- **SIEM Integration**: Portal uses advanced configuration section vs Bicep integrates within Step 9
- **Alert Procedures**: Portal includes detailed investigation workflows vs Bicep focuses on generation and verification
- **Cost Management**: Portal has dedicated cost optimization section vs Bicep integrates cost controls throughout

**Result**: Choose based on your deployment style - both achieve complete Defender for Cloud security coverage including alert generation, investigation procedures, cost management, and comprehensive SIEM integration.

## **🔒 Portal-Only Configuration Requirements**

Both guides include certain features that **require Azure Portal configuration** due to Azure platform limitations:

| **Feature** | **Portal Guide** | **Bicep Guide** | **Reason for Portal Requirement** |
|-------------|------------------|-----------------|-----------------------------------|
| **Sample Alert Generation** | Step 11 | Step 9 | No CLI equivalent - Portal-only feature |
| **File Integrity Monitoring** | Step 10 (optional) | Step 8 (documented) | Complex workspace integration and validation |
| **Sentinel Data Connectors** | Advanced Config | Step 9 | Content Hub installation cannot be automated |
| **Interactive Workbooks** | Step 12 | Step 10 | Dashboard customization requires visual interface |
| **Just-in-Time VM Access** | Step 10 | Step 8 | Request workflows require Portal interaction |

**Key Insight**: Even in the Infrastructure-as-Code approach, certain security features require Portal access for configuration or operation. Both guides clearly identify these limitations and provide Portal-based instructions where needed.

## 🧹 Lab Cleanup

After completing the security testing workflows, sample alerts generated during testing can be manually dismissed through the Azure Portal interface.

---

## 🔗 Quick Navigation

- [Project Root](/Microsoft/Azure%20Ai%20Security%20Skills%20Challenge/README.md)

---
