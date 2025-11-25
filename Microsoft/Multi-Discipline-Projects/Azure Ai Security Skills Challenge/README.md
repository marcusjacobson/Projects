# Azure AI Security Skills Challenge

**A comprehensive 10-week journey to master secure AI deployment, Microsoft Security tools, and Copilot integration.**

This project aligns with Microsoft's AI Transformation strategy and provides a hands-on roadmap for building enterprise-grade AI security skills. It covers the full spectrum of AI security, from foundational infrastructure to advanced generative AI governance.

## 🎯 Strategic Value

The **Azure AI Security Skills Challenge** is designed to bridge the gap between traditional security operations and the emerging world of AI engineering. By completing this roadmap, you will build:

- **Enterprise-Ready AI Security**: Practical experience deploying and securing Azure OpenAI, Copilot, and custom AI models.
- **Unified Security Operations**: Deep integration of Defender XDR, Sentinel, and Security Copilot for modern SOC capabilities.
- **Governance & Compliance**: Implementation of Purview and Priva for responsible AI and data protection.
- **Reusable Assets**: A library of deployment scripts, Bicep templates, and prompt engineering guides for customer delivery.

---

## 🏗️ Architecture Overview

This project builds a complete **AI Security Ecosystem** integrating core Microsoft technologies:

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                       Unified Security Operations                       │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────┐  │
│  │ Defender XDR │↔│   Sentinel   │↔│ Security     │↔│ Copilot  │  │
│  └──────────────┘   └──────────────┘   │ Copilot      │   │ Studio   │  │
│         ▲                  ▲           └──────────────┘   └──────────┘  │
└─────────┼──────────────────┼──────────────────▲─────────────────────────┘
          │                  │                  │
┌─────────▼──────────────────▼──────────────────▼─────────────────────────┐
│                     Secure AI Infrastructure                            │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐                 │
│  │ Azure OpenAI │   │ AI Foundry   │   │   Fabric     │                 │
│  └──────────────┘   └──────────────┘   └──────────────┘                 │
└─────────────────────────────────────────────────────────────────────────┘
          ▲                  ▲                  ▲
┌─────────┴──────────────────┴──────────────────┴─────────────────────────┐
│                    Governance & Compliance                              │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐                 │
│  │   Purview    │   │    Priva     │   │   Entra ID   │                 │
│  └──────────────┘   └──────────────┘   └──────────────┘                 │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🌍 **Important: Regional Deployment Guidance**

**⚠️ CRITICAL**: This project deploys infrastructure to **East US** region for complete AI security coverage and curriculum compliance.

**Why East US is Required:**

- **Unified Security Operations**: Required for Week 2 modern security operations platform integration with complete regional feature availability.
- **Complete AI Coverage**: Ensures all advanced security features are available for hands-on learning and enterprise deployment scenarios.
- **Curriculum Alignment**: Week 2 explicitly requires modern unified security operations integration and validation.
- **Future-Proofing**: Optimal foundation for Weeks 3-9 advanced AI security scenarios.

**Regional Impact**: Deploying in regions with limited modern security operations features would create a curriculum compliance gap and prevent completion of required Week 2 deliverables.

📖 **Learn More**: [Microsoft Defender XDR unified security operations platform](https://learn.microsoft.com/en-us/defender-xdr/)

---

## 🎓 Skills & Certification Alignment

This roadmap is mapped to key Microsoft certifications and job roles, ensuring that your practical work translates directly to professional growth.

| Phase | Weeks | Focus Area | Aligned Certifications | Key Skills |
|-------|-------|------------|------------------------|------------|
| **1** | 00-01 | **Security Foundations** | **AZ-500**, **SC-200** | Azure Security, Defender for Cloud, IaC (Bicep/PowerShell) |
| **2** | 02-03 | **AI Engineering & Ops** | **AI-102**, **AZ-400** | Azure OpenAI, Prompt Engineering, Logic Apps Automation, Cost Mgmt |
| **3** | 04-06 | **Advanced SecOps & Gov** | **SC-100**, **DP-600** | Security Copilot, Purview, Priva, Data Governance |
| **4** | 07-10 | **Applied AI & Delivery** | **AI-102**, **PL-200** | Fabric, AI Foundry, Copilot Studio, Secure Delivery |

---

## 📅 Implementation Roadmap

This roadmap has been optimized for working professionals with a logical progression through **4 distinct phases**:

### **Phase 1: Security Infrastructure Foundations (Weeks 1-4)**

- **Week 1**: Defender for Cloud deployment foundation with modern unified security operations foundation
- **Week 2**: Implement AI foundation and secure model deployment with cost optimization
- **Week 3**: Deploy AI-driven security operations automation through Defender XDR integration
- **Week 4**: Advanced XDR + Security Copilot integration with enterprise-grade security operations

### **Phase 2: Data Governance & Analytics (Weeks 5-6)**

- **Week 5**: Microsoft Purview for comprehensive data governance
- **Week 6**: Microsoft Priva and responsible AI governance frameworks

### **Phase 3: Advanced Analytics & AI Development (Weeks 7-8)**

- **Week 7**: Microsoft Fabric for secure analytics and data pipelines
- **Week 8**: Azure AI Foundry and secure AI workload deployment

### **Phase 4: Applied AI & Enterprise Delivery (Weeks 9-10)**

- **Week 9**: Copilot Studio for security agents and AI automation
- **Week 10**: Secure Copilot deployment and comprehensive delivery practices

---

## ⚡ **Key Benefits of This Structure**

- **Realistic Time Investment**: Each week designed for 8-12 hours total (manageable with full-time work)
- **Logical Learning Flow**: Each phase builds methodically on previous knowledge
- **Balanced Workload**: Complex deployment work separated from AI integration
- **Practical Outcomes**: Every week delivers deployable solutions and reusable assets
- **Enterprise Ready**: Progresses from foundational skills to customer-facing delivery capability

---

## 🗂️ Repository Structure

Each week is organized as a separate folder to support modular development and publishing.

## 📊 Module Breakdown & Status

As project weeks are completed, the **Completed** checkbox will be marked.

**Status Legend:**

- [x] = Completed
- [🔄] = In Progress (core deliverables complete, final items pending)
- [ ] = Not Started

| Week | Focus Area | Status | Key Deliverables |
|------|------------|--------|------------------|
| 0 | [Project Setup & Admin](./00-Project-Setup-&-Admin/README.md) | [x] | Environment Validation Script, Dev Setup |
| 1 | [Defender for Cloud Deployment Foundation](./01-Defender-for-Cloud-Deployment-Foundation/README.md) | [x] | MDC Deployment, Unified SecOps Integration |
| 2 | [AI Foundation & Secure Model Deployment](./02-AI-Foundation-&-Secure-Model-Deployment/README.md) | [🔄] | Azure OpenAI, Cost Mgmt, Prompt Library |
| 3 | [AI-Driven Security Operations Automation](./03-AI-SecOps/README.md) | [🔄] | Logic Apps Automation, Incident Enrichment |
| 4 | [Advanced XDR + Security Copilot Integration](./04-Defender-XDR-+-Security-Copilot-Integration/README.md) | [ ] | Security Copilot Plugin, Advanced Hunting |
| 5 | [Microsoft Purview for Data Governance](./05-Microsoft-Purview-for-Data-Governance/README.md) | [ ] | Data Map, Classification, Sensitivity Labels |
| 6 | [Microsoft Priva and Responsible AI](./06-Microsoft-Priva-and-Responsible-AI/README.md) | [ ] | Privacy Risk Mgmt, Subject Rights Requests |
| 7 | [Microsoft Fabric for Secure Analytics](./07-Microsoft-Fabric-for-Secure-Analytics/README.md) | [ ] | Fabric Capacity, OneLake Security |
| 8 | [Azure AI Foundry & Secure AI Workloads](./08-Azure-AI-Foundry-&-Secure-AI-Workloads/README.md) | [ ] | AI Studio, Content Safety, Model Catalog |
| 9 | [Copilot Studio for Security Agents](./09-Copilot-Studio-for-Security-Agents/README.md) | [ ] | Custom Copilots, Plugin Development |
| 10 | [Secure Copilot Deployment & Delivery Practices](./10-Secure-Copilot-Deployment-&-Delivery-Practices/README.md) | [ ] | Production Readiness, Adoption Framework |

## 📊 Comprehensive AI Security Capability Coverage

### Coverage Matrix: 10-Week Roadmap

This matrix shows which module covers each AI Security capability, with specific week references.

#### ✅ Cloud Security Posture & Workload Protection

| Capability | Complexity | Module Coverage | Status |
|------------|------------|-----------------|--------|
| **Environment Validation** | BASIC | ✅ Week 0 (9-step validation script) | ✅ COMPREHENSIVE |
| **Defender for Cloud (CSPM)** | INTERMEDIATE | ✅ Week 1 (MDC deployment, policy) | ✅ EXTENSIVE |
| **Workload Protection (CWP)** | INTERMEDIATE | ✅ Week 1 (Server, Storage, App Service plans) | ✅ EXTENSIVE |
| **Infrastructure as Code (Bicep)** | INTERMEDIATE | ✅ Weeks 1-2 (Modular Bicep templates) | ✅ COMPREHENSIVE |
| **PowerShell Automation** | INTERMEDIATE | ✅ All Weeks (Orchestrator scripts) | ✅ EXTENSIVE |
| **Unified SecOps Integration** | ADVANCED | ✅ Week 1 (Defender XDR connector) | ✅ DETAILED |

#### ✅ AI Engineering & Secure Infrastructure

| Capability | Complexity | Module Coverage | Status |
|------------|------------|-----------------|--------|
| **Azure OpenAI Deployment** | INTERMEDIATE | ✅ Week 2 (GPT-4o-mini, secure endpoints) | ✅ COMPREHENSIVE |
| **AI Cost Management** | INTERMEDIATE | ✅ Week 2 (Budget alerts, token optimization) | ✅ EXTENSIVE |
| **Prompt Engineering** | INTERMEDIATE | ✅ Week 2 (Security-optimized templates) | ✅ DETAILED |
| **Azure AI Foundry** | ADVANCED | ✅ Week 8 (AI Studio, Model Catalog) | ✅ PLANNED |
| **Content Safety Filters** | INTERMEDIATE | ✅ Week 8 (RAI policies, jailbreak detection) | ✅ PLANNED |
| **Private Networking for AI** | ADVANCED | ✅ Week 2 (Private Endpoints foundation) | ✅ DETAILED |

#### ✅ Security Operations & Automation

| Capability | Complexity | Module Coverage | Status |
|------------|------------|-----------------|--------|
| **Defender XDR Integration** | INTERMEDIATE | ✅ Week 3 (Incident enrichment) | ✅ PLANNED |
| **Logic Apps Automation** | INTERMEDIATE | ✅ Week 3 (Automated response playbooks) | ✅ PLANNED |
| **Microsoft Sentinel** | ADVANCED | ✅ Week 3 (Connector setup, analytics rules) | ✅ PLANNED |
| **Security Copilot** | ADVANCED | ✅ Week 4 (Plugin integration, promptbooks) | ✅ PLANNED |
| **Advanced Hunting (KQL)** | ADVANCED | ✅ Week 4 (AI-assisted query generation) | ✅ PLANNED |

#### ✅ Data Governance & Privacy

| Capability | Complexity | Module Coverage | Status |
|------------|------------|-----------------|--------|
| **Purview Data Map** | INTERMEDIATE | ✅ Week 5 (Scanning, classification) | ✅ PLANNED |
| **Sensitivity Labels** | INTERMEDIATE | ✅ Week 5 (AI-labeling, auto-labeling) | ✅ PLANNED |
| **Data Loss Prevention (DLP)** | INTERMEDIATE | ✅ Week 5 (AI endpoint DLP) | ✅ PLANNED |
| **Microsoft Priva** | ADVANCED | ✅ Week 6 (Privacy Risk Management) | ✅ PLANNED |
| **Subject Rights Requests** | ADVANCED | ✅ Week 6 (Automated discovery) | ✅ PLANNED |

#### ✅ Secure Analytics & Applied AI

| Capability | Complexity | Module Coverage | Status |
|------------|------------|-----------------|--------|
| **Microsoft Fabric Security** | ADVANCED | ✅ Week 7 (OneLake security, workspace gov) | ✅ PLANNED |
| **Copilot Studio** | ADVANCED | ✅ Week 9 (Custom security agents) | ✅ PLANNED |
| **Secure Copilot Delivery** | EXPERT | ✅ Week 10 (Adoption framework, readiness) | ✅ PLANNED |
| **Custom Plugin Dev** | EXPERT | ✅ Week 9 (API connectors, auth) | ✅ PLANNED |

### ❌ Capabilities NOT Covered

The following capabilities require **enterprise-scale deployments** or **specialized licensing** beyond the scope of this challenge:

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Physical Security** | BASIC | Out of scope for cloud/AI focus |
| **Hardware Security Modules (HSM)** | ADVANCED | Requires dedicated hardware provisioning |
| **Legacy On-Premises Integration** | ADVANCED | Focus is on cloud-native AI security |
| **Third-Party AI Model Training** | EXPERT | Focus is on Microsoft Azure AI ecosystem |

## 🛠️ Automation & Tooling

The project includes comprehensive automation and validation tools to ensure reliable setup and deployment success:

### Week 00 - Automated Environment Setup

#### Comprehensive Environment Validation

- **[Test-EnvironmentValidation.ps1](./00-Project-Setup-&-Admin/scripts/Test-EnvironmentValidation.ps1)** - Advanced 9-step environment validation script that checks:
  - Azure CLI installation and authentication
  - PowerShell Az module configuration
  - Subscription permissions (Owner/Contributor validation)
  - East US region access and AI service availability
  - Visual Studio Code and required extensions
  - Git configuration and development tools
  - Comprehensive JSON export capabilities for detailed analysis

#### Automated Development Environment Installation

- **[Install-DevelopmentEnvironment.ps1](./00-Project-Setup-&-Admin/scripts/Install-DevelopmentEnvironment.ps1)** - Complete 7-step automated installation covering:
  - Azure CLI latest version installation
  - PowerShell Az module setup
  - Visual Studio Code with Azure extensions
  - Git configuration and authentication
  - Development tools optimization

### Week 01 - Security Infrastructure Mastery

#### Complete Deployment Portfolio

- **Azure Portal Deployment** - Comprehensive step-by-step learning path with detailed screenshots and validation
- **Modular Infrastructure-as-Code** - Professional PowerShell + Bicep automation with parameter-driven configuration
- **Enterprise Complete Automation** - Production-ready deployment with advanced error handling and validation
- **Professional Decommission Tools** - Safe cleanup scripts with confirmation workflows and cost optimization

#### Bridge Validation to Week 2

- **Unified Security Operations Readiness** - Validates modern security operations platform capabilities required for AI integration

### Week 02 - AI Integration & Cost Management

#### Cost-Effective AI Foundation

- **Azure OpenAI Service** with GPT-4o-mini deployment optimized for cost control and budget management
- **Storage Account Foundation** for AI workload data processing and Defender XDR integration state management
- **Comprehensive Cost Monitoring** with automated alerts and budget controls

#### Professional AI-Security Integration

- **Azure OpenAI + Defender XDR Integration** - Logic Apps-based automation for intelligent incident analysis through unified portal
- **AI Prompt Template Library** - Security-optimized prompts with cost-effective token usage patterns
- **Built-in AI Features Enablement** - UEBA, Fusion, and Anomaly Detection validation within unified security operations

### Enterprise-Ready Features Across All Weeks

#### Professional PowerShell Standards

- **Industry-Standard Preambles** - Complete comment-based help with SYNOPSIS, DESCRIPTION, EXAMPLES, and NOTES
- **Consistent Terminology** - "Phase" for orchestrators, "Step" for components, "Action" for pipeline scripts
- **Professional Color Schemes** - Magenta for phases, Green for steps, Blue for notifications, Red for errors
- **Comprehensive Error Handling** - Try-catch blocks with detailed logging and recovery guidance

#### Advanced Validation and Testing

- **Multi-Scenario Testing** - Simulation capabilities for various failure conditions and partial setup scenarios
- **JSON Export Capabilities** - Detailed validation results with success rates and targeted recommendations
- **Performance Optimization** - Scripts optimized to avoid timeouts and provide clear progress indicators

#### Documentation Excellence

- **[Markdown Style Guide](../../Style-Guides/markdown-style-guide.md)** compliance across all documentation
- **[PowerShell Style Guide](../../Style-Guides/powershell-style-guide.md)** implementation in all automation scripts
- **[Parameters File Style Guide](../../Style-Guides/parameters-file-style-guide.md)** standardization for Infrastructure-as-Code configuration
- **Comprehensive AI-Assisted Content Attribution** - Transparency in AI tool usage for content generation

This enhanced tooling ensures reliable setup, deployment success, and professional-grade automation throughout the 10-week learning journey.

## 📈 Change Log & Achievements

### Comprehensive Environment Foundation (August 2025)

- **Advanced Validation Framework**: 9-step environment validation with comprehensive error handling and JSON export capabilities
- **Optimized Performance**: Resolved script performance issues including PowerShell module loading optimization and Azure CLI timeout protection
- **Professional Automation**: Enhanced PowerShell scripts following industry-standard preambles and consistent terminology
- **Multi-Scenario Testing**: Comprehensive simulation capabilities for various setup and failure conditions
- **Cost Management Integration**: Advanced cost monitoring and budget controls throughout AI integration workflows

### Technical Excellence Standards

- **Style Guide Compliance**: All documentation follows centralized [Markdown](../../Style-Guides/markdown-style-guide.md), [PowerShell](../../Style-Guides/powershell-style-guide.md), and [Parameters File](../../Style-Guides/parameters-file-style-guide.md) style guides
- **AI-Assisted Development**: Transparent acknowledgment of GitHub Copilot usage in content generation and script development
- **Enterprise Deployment Readiness**: Production-ready automation with comprehensive error handling and validation
- **Modern Security Integration**: Complete unified security operations platform foundation for Weeks 1-2

## 📚 Documentation Standards

This project follows established style guides to ensure consistency and professionalism across all documentation and code:

- **[Markdown Style Guide](../../Style-Guides/markdown-style-guide.md)** - Formatting, punctuation, and tone standards for all markdown documentation
- **[PowerShell Style Guide](../../Style-Guides/powershell-style-guide.md)** - Consistent visual and organizational patterns for PowerShell scripts
- **[Parameters File Style Guide](../../Style-Guides/parameters-file-style-guide.md)** - Configuration standards for Azure parameters files

These guides define comprehensive standards for headers, lists, code blocks, interface elements, professional documentation practices, and Infrastructure-as-Code configuration patterns.

## 📬 Contributions & Feedback

This is a personal skilling initiative, but collaboration and feedback are welcome! If you’re working on similar goals or want to reuse parts of this roadmap, feel free to fork or adapt.

