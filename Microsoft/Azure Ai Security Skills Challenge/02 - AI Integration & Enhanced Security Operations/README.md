# Week 2 – AI Integration & Enhanced Security Operations

This week focuses on implementing cost-effective AI-driven capabilities within the Defender for Cloud infrastructure established in Week 1. The goal is to explore practical AI integration patterns that enhance security operations while maintaining strict budget controls and automated cost management.

## 🌍 Regional Deployment Requirement

**⚠️ IMPORTANT**: All deployments continue to use **East US** region for complete AI service availability and cost optimization.

**Why East US Remains Critical:**

- **Azure OpenAI Availability**: Most cost-effective models available in East US region.
- **Integrated AI Features**: UEBA, Fusion, and Anomaly Detection have optimal performance in East US.
- **Cost Management**: Azure OpenAI pricing and quota management optimized for East US.
- **Week 1 Integration**: Seamless integration with existing Defender infrastructure.

## 🎯 Objectives

- Deploy Azure OpenAI with cost-effective models (GPT-4o-mini) and automated budget controls.
- Implement Azure OpenAI + Sentinel integration using Logic Apps for AI-driven alert analysis through Defender XDR unified portal.
- Enable built-in AI features (UEBA, Fusion, Anomaly Detection) within existing deployments via unified security operations.
- Configure comprehensive cost monitoring, alerts, and automated service shutdown capabilities.
- Create foundational prompt templates for security scenarios with cost-optimized token usage.
- Simulate threat scenarios to observe AI-driven insights and validate cost controls within unified portal workflows.
- Document AI integration patterns with detailed cost optimization strategies for modern unified security operations.

## 📁 Deliverables

- **AI Foundation Infrastructure**: Azure OpenAI service with budget controls + storage account for logic app data processing.
- **Azure OpenAI + Defender XDR Integration**: Logic Apps-based automation for AI-driven alert analysis through Defender XDR unified portal with comprehensive Infrastructure-as-Code automation including Key Vault secrets management, Entra ID App Registration, API connections, duplicate prevention, and enterprise-grade security controls.
- **Built-in AI Features**: UEBA, Fusion, and Anomaly Detection enabled and validated within unified security operations.
- **Cost Management System**: Comprehensive monitoring, alerts, and automated shutdown capabilities.
- **AI Prompt Library**: Basic templates optimized for cost-effective token usage:
  - Threat detection and alert triage via unified portal workflows
  - Security incident summarization for unified incident management
  - AI-assisted remediation guidance integrated with Defender XDR operations
- **Validation Scenarios**: Simulated threat scenarios with AI analysis and cost tracking within unified portal.
- **Integration Documentation**: Complete guides with cost optimization strategies for modern unified security operations.

## ✅ Checklist

- [x] **AI integration strategic planning research completed** (foundational research from Week 1, updated for modern unified portal operations).
- [x] **[Storage Account Deployment](./02.02%20Storage%20Account%20Deployment/deploy-ai-storage-foundation.md)** - Deploy storage accounts for Defender XDR Integration state management and duplicate prevention:
  - [x] **[Azure Portal Guide](./02.02%20Storage%20Account%20Deployment/Azure%20Portal/deploy-ai-storage-foundation-azure-portal.md)** - Step-by-step portal deployment (Recommended for learning)
  - [x] **[Infrastructure-as-Code Guide](./02.02%20Storage%20Account%20Deployment/Infrastructure%20as%20Code/deploy-ai-storage-foundation-iac.md)** - Automated Bicep deployment (Recommended for quick deployment)
- [x] **[Azure OpenAI Service Deployment](./02.03%20Azure%20OpenAI%20Service%20Deployment/deploy-azure-openai-service.md)** - Deploy cost-effective OpenAI service with enhanced automation and soft-delete handling:
  - [x] **[Azure Portal Guide](./02.03%20Azure%20OpenAI%20Service%20Deployment/Azure%20Portal/deploy-azure-openai-service-azure-portal.md)** - Step-by-step portal deployment (Recommended for learning)
  - [x] **[Infrastructure-as-Code Guide](./02.03%20Azure%20OpenAI%20Service%20Deployment/Infrastructure%20as%20Code/deploy-azure-openai-service-iac.md)** - Automated Bicep deployment (Recommended for quick deployment)
- [x] **[OpenAI Model Customization](./02.04%20OpenAI%20Model%20Customization/customize-openai-model.md)** - Configure GPT-4o-mini with cybersecurity analyst persona, optimized parameters (Temperature 0.2, 450 tokens), and industry compliance frameworks (NIST AI RMF, OWASP LLM Top 10).
- [x] **[AI Prompt Templates Creation](./02.05%20AI%20Prompt%20Templates%20Creation/ai-prompt-templates.md)** - Identified GPT-4o-mini optimized prompt templates for Defender for Cloud security scenarios with cost optimization and industry compliance.
- [X] **[Azure OpenAI + Defender XDR Integration](./02.06%20Azure%20OpenAI%20+%20Defender%20XDR%20Integration/deploy-openai-defender-xdr-integration.md)** - Implement Logic Apps-based AI automation for intelligent incident analysis through Defender XDR unified portal:
  - [X] **[Azure Portal Guide](./02.06%20Azure%20OpenAI%20+%20Defender%20XDR%20Integration/Azure%20Portal/deploy-openai-defender-xdr-integration-azure-portal.md)** - Step-by-step Logic Apps designer configuration using manual secret assignment for simplicity and learning experience (Recommended for learning Azure AI security workflows)
  - [X] **[Infrastructure-as-Code Guide](./02.06%20Azure%20OpenAI%20+%20Defender%20XDR%20Integration/Infrastructure%20as%20Code/deploy-openai-defender-xdr-integration-iac.md)** - Comprehensive PowerShell automation with Key Vault integration, App Registration management, and complete workflow orchestration including API connections, duplicate prevention, and enterprise-grade security controls (Recommended for production deployments and advanced automation scenarios)
- [ ] **[Threat Scenario Simulation](./simulate-threat-scenarios.md)** - Execute benign threat scenarios with AI analysis.
- [ ] **[Built-in AI Features Enablement](./deploy-builtin-ai-features.md)** - Enable UEBA, Fusion, and Anomaly Detection after data flows are established.
- [ ] **[Azure Cost Management Setup](./deploy-ai-cost-management.md)** - Configure budget alerts and automated shutdown capabilities.
- [ ] **[Cost Optimization Documentation](./ai-cost-optimization-guide.md)** - Document cost optimization strategies and automated controls.
- [ ] **Week 2 Validation** - Confirm AI integration effectiveness and cost compliance.
- [ ] **Week 3 Foundation Preparation** - Prepare infrastructure for XDR integration.

> **✅ Infrastructure Status**: Storage accounts for AI workloads are now **COMPLETED** with full cost optimization. Both Azure Portal and Infrastructure-as-Code guides achieve 100% compliance with cost-optimized configurations (soft delete disabled, versioning disabled, Standard_LRS replication). Ready for next AI service deployments.

## 📂 Project Files

This week's project follows Week 1's proven structure with AI-focused enhancements and comprehensive cost management:

### 🔬 Research & Strategy

- **[AI Integration Strategic Planning Guide](../reports/ai-integration-strategic-planning-guide.md)** - Comprehensive strategic reference covering cost-effective AI security implementation with detailed Security Copilot deployment strategies (SCU cost management, on-demand provisioning, automated lifecycle management), Azure OpenAI integration through Defender XDR unified portal, and comparative analysis for optimizing AI-driven security operations within organizational budget frameworks (updated for 2025 unified security operations terminology)

### 🏗️ Infrastructure-as-Code

- **[AI Storage Foundation - COMPLETED](./infra/)** - Production-ready Bicep templates with full cost optimization compliance
- **[AI Integration Scripts - READY](./scripts/)** - PowerShell scripts for AI service deployment, configuration, and automated management
  - **Deploy-StorageFoundation.ps1** - Fully functional with UPN auto-resolution and cost optimization
  - **Deploy-OpenAIService.ps1** - Enhanced with automated soft-delete detection and purge capabilities
  - **Deploy-DefenderXDRIntegration.ps1** - Complete XDR integration orchestrator with Key Vault, App Registration, and Logic Apps deployment
  - **Deploy-KeyVault.ps1** - Secure credential storage and OpenAI secrets management
  - **Deploy-AppRegistration.ps1** - Entra ID app setup with Microsoft Graph Security API permissions  
  - **Deploy-APIConnections.ps1** - API connections for OpenAI, Table Storage, and Microsoft Graph
  - **Deploy-LogicAppWorkflow.ps1** - Complete Logic Apps workflow with ARM template deployment
  - **Deploy-ProcessingStorage.ps1** - Table Storage for duplicate prevention and audit trails
  - **Test-DefenderXDRIntegrationValidation.ps1** - Comprehensive validation with detailed reporting
  - **Remove-DefenderXDRIntegration.ps1** - Complete decommission script with intelligent cleanup
  - **Remove-OpenAIInfrastructure.ps1** - Comprehensive decommission script with phase-based cleanup
  - **Test-StorageFoundation.ps1** - Comprehensive validation with 100% test coverage
  - **Remove-StorageResourceGroup.ps1** - Reliable cleanup with verification and wait logic

### 📚 Learning Resources

- **[AI Integration Learning Guide](./02.01%20AI-driven%20security%20recommendations%20research/learning-resources.md)** - Curated Azure OpenAI and AI security integration resources
- **[Cost Management Best Practices](./configure-ai-cost-management-budgets.md)** - Detailed cost control strategies and automation patterns

## 📁 Project Organization

Week 2 follows the proven Week 1 structure optimized for AI services and cost management:

```text
02 - AI Integration & Enhanced Security Operations/
├── 📋 Deployment Guides/
│   ├── README.md                                    # Project overview and AI deployment comparison
│   ├── deploy-ai-storage-foundation.md             # AI storage infrastructure deployment
│   ├── deploy-ai-cost-management.md                # Budget controls and automated shutdown
│   ├── deploy-azure-openai-service.md              # Cost-effective OpenAI service deployment
│   ├── customize-openai-model.md                   # Security-focused model configuration
│   ├── deploy-openai-defender-xdr-integration.md   # Logic Apps + Sentinel automation via Defender XDR unified portal
│   ├── deploy-builtin-ai-features.md               # UEBA, Fusion, Anomaly Detection enablement through unified operations
│   └── simulate-threat-scenarios.md                # AI-driven threat simulation and validation within unified portal
├── 🏗️ Infrastructure-as-Code/
│   └── infra/                                       # AI-focused Bicep templates
│       ├── main.bicep                               # Main AI infrastructure orchestration
│       ├── main.parameters.json                     # AI service configuration parameters
│       ├── foundation.parameters.json               # AI foundation parameters
│       └── modules/                                 # Modular AI service components
│           ├── storage/                             # AI storage accounts and containers
│           ├── openai/                              # Azure OpenAI service deployment
│           ├── logicapps/                           # Sentinel integration automation via unified portal
│           └── monitoring/                          # AI cost monitoring and alerting
├── 📊 PowerShell Scripts/
│   └── scripts/                                     # AI deployment and cost management automation
│       ├── README.md                                # AI script usage documentation
│       ├── Deploy-AIFoundation.ps1                 # Complete AI foundation deployment
│       ├── Deploy-StorageFoundation.ps1            # AI storage infrastructure
│       ├── Deploy-CostManagement.ps1               # Budget alerts and automated controls
│       ├── Deploy-OpenAIService.ps1                # Azure OpenAI service deployment
│       ├── Deploy-DefenderXDRIntegration.ps1       # Complete XDR integration orchestrator
│       ├── Deploy-KeyVault.ps1                     # Secure credential storage and secrets management
│       ├── Deploy-AppRegistration.ps1              # Entra ID app setup with Graph permissions
│       ├── Deploy-APIConnections.ps1               # API connections deployment for Logic Apps
│       ├── Deploy-LogicAppWorkflow.ps1             # Logic Apps workflow with ARM template deployment
│       ├── Deploy-ProcessingStorage.ps1            # Table Storage for duplicate prevention
│       ├── Test-DefenderXDRIntegrationValidation.ps1 # Comprehensive XDR integration validation
│       ├── Remove-DefenderXDRIntegration.ps1       # Complete XDR integration cleanup
│       ├── Deploy-SentinelIntegration.ps1          # Legacy - now consolidated in DefenderXDR scripts
│       ├── Deploy-BuiltinAIFeatures.ps1            # Enable AI security features through unified operations
│       ├── Test-AIIntegration.ps1                  # AI integration validation
│       ├── Remove-AIInfrastructure.ps1             # AI service cleanup and cost control
│       └── templates/                               # AI configuration templates
│           ├── logic-app-arm-template.json          # Primary Logic App ARM template for XDR integration
│           ├── logic-app-initial.json               # Initial Logic App configuration
│           ├── openai-connection.json               # OpenAI API connection template
│           ├── graph-connection.json                # Microsoft Graph API connection template
│           ├── table-connection.json                # Table Storage API connection template
│           ├── openai-deployment.json               # OpenAI model deployment configuration
│           ├── logic-app-sentinel.json              # Legacy - now uses comprehensive ARM templates
│           └── cost-alert-rules.json                # Budget monitoring templates
└── 🤖 AI Templates & Resources/
    ├── customize-openai-model.md                    # Security-focused model configuration guide
    ├── ai-prompt-templates.md                       # Cost-optimized security prompt library
    ├── ai-cost-optimization-guide.md                # Comprehensive cost management strategies
    ├── cost-management-best-practices.md            # Automated cost control patterns
    └── learning-resources-ai.md                     # Curated AI security learning materials
```

## 🎯 Weekly Focus Areas

### **Phase 1: Foundation & Cost Controls (Monday-Tuesday)**

- Deploy AI storage foundation with cost optimization
- Configure comprehensive budget alerts and automated shutdown capabilities
- Deploy Azure OpenAI service with cost-effective GPT-4o-mini model

### **Phase 2: AI Integration (Wednesday-Thursday)**

- Implement Azure OpenAI + Defender XDR integration using Logic Apps through Defender XDR unified portal
- Create cost-optimized prompt templates for security scenarios within unified operations
- Simulate threat scenarios to establish baseline data for AI features via unified portal workflows

### **Phase 3: Advanced AI & Validation (Friday-Weekend)**

- Enable built-in AI features (UEBA, Fusion, Anomaly Detection) after data flows are established through unified operations
- Validate AI integration effectiveness with cost tracking within unified portal
- Document cost optimization strategies and automated controls for modern unified security operations
- Prepare infrastructure foundation for Week 3 XDR integration and advanced unified operations

## 🔄 Storage Foundation Deployment - COMPLETED ✅

The AI storage foundation has been **successfully implemented** with two production-ready approaches achieving 100% cost optimization compliance:

### 🎯 Choose Your Storage Deployment Approach

#### 🖱️ Azure Portal Guide - *Learning Path COMPLETED* ✅

- **Status**: **Production Ready** - All cost optimization settings validated
- **Target Audience**: Security professionals new to Azure AI storage concepts
- **Key Achievements**: Step-by-step deployment, cost optimization, security configuration
- **Compliance**: 100% match with cost-optimized lab configuration
- **Best For**: Understanding storage concepts, manual validation, educational purposes

#### 🔧 Infrastructure-as-Code Guide - *Automation COMPLETED* ✅

- **Status**: **Enterprise Ready** - Full automation with validation scripts
- **Target Audience**: DevOps engineers implementing automated AI storage solutions
- **Key Achievements**: Single-command deployment, automatic UPN resolution, comprehensive testing
- **Compliance**: 100% portal guide compliance + enhanced automation features
- **Best For**: Production environments, CI/CD pipelines, repeatable deployments

### 🚀 AI Service Deployment Approaches

With storage foundation complete, proceed to AI service deployment:

#### 🖱️ Azure Portal Guide - *Best for Learning AI Services*

- **Target Audience**: Security professionals new to Azure AI services
- **Key Benefits**: Visual interface, step-by-step AI service configuration, cost monitoring setup
- **Time Investment**: 45-60 minutes (guided AI learning experience)
- **Best For**: Understanding AI concepts, cost management learning, educational purposes

#### 🔧 Infrastructure-as-Code - *Best for Production AI Automation*

- **Target Audience**: DevOps engineers implementing AI security solutions
- **Key Benefits**: Automated AI deployment, integrated cost controls, enterprise scalability
- **Time Investment**: 15-20 minutes (structured AI automation)
- **Best For**: Production AI environments, learning AI automation, controlled AI deployments

#### 🚀 XDR Integration IaC - *Best for Complete Security Automation*

- **Target Audience**: Security architects implementing comprehensive AI-driven security operations
- **Key Benefits**: Complete automation (Key Vault, App Registration, Logic Apps, API connections), enterprise-grade security, comprehensive validation and cleanup
- **Time Investment**: 20-30 minutes (fully automated end-to-end deployment)
- **Best For**: Production security environments, learning advanced automation, enterprise security implementations

### 🤖 OpenAI Model Customization for Security Operations

After deploying your Azure OpenAI service, the next critical step is customizing the GPT-4o-mini model for cybersecurity use cases. This bridges the infrastructure deployment and AI prompt template implementation.

#### 🎯 Security-Focused Model Configuration

**System Instructions & Role Definitions**: Configure your GPT-4o-mini model with comprehensive cybersecurity analyst persona, including threat detection expertise, incident response knowledge, and MITRE ATT&CK framework awareness for enterprise security operations.

**Azure AI Foundry Interface**: Utilize the modern consolidated system message interface with managed identity authentication for streamlined configuration and enhanced security.

**Parameter Tuning**: Research-validated optimization with Temperature 0.2 (down from default 0.7), 450 token limit (down from 4000), Top P 0.9, and strategic penalty settings for cost-effective security operations.

**Model Behavior Configuration**: Ensure consistent security outputs with structured summary report format (replacing inefficient JSON), confidence indicators, and automated human review triggers for high-impact decisions.

#### 🛡️ Security Context Integration

- **Industry Compliance**: NIST AI Risk Management Framework (AI RMF 1.0), OWASP LLM Top 10 (2025), Microsoft Responsible AI principles
- **Threat Intelligence Awareness**: Current APT groups, attack vectors, and priority indicators with MITRE ATT&CK integration
- **Security Vocabulary Optimization**: IOCs, TTPs, IOAs, SOAR, UEBA terminology focus with context-aware analysis
- **Incident Classification Standards**: True positive, false positive, benign positive categorization with business impact assessment

#### 💰 Cost-Optimized Configuration

- **Production Settings**: 450 token limit, Temperature 0.2, research-validated parameters for completeness vs. cost balance
- **Cost Analysis**: $0.15 per 1M input tokens, $0.60 per 1M output tokens (Azure OpenAI GPT-4o-mini pricing, August 2025)
- **Performance Metrics**: ~250 system prompt tokens, ~380 average response tokens optimized for complete analysis within token limits

## 💰 Cost Management Priority

Week 2 implements comprehensive cost management as a core requirement:

- **Budget Alerts**: Automated alerts at 50%, 75%, and 90% of $150 monthly budget
- **Automated Shutdown**: Logic Apps to automatically disable expensive services when not in use  
- **Cost-Effective Models**: GPT-4o-mini preferred for optimal cost/performance ratio with research-validated parameter optimization
- **XDR Integration Costs**: Logic Apps (~$1-3/month), API connections (included), Key Vault (~$1-2/month), Table Storage (~$0.15/month)
- **Usage Monitoring**: Real-time cost tracking and usage analytics through Azure Cost Management
- **Resource Lifecycle**: Automated cleanup scripts and scheduled resource management with comprehensive decommission capabilities

---

## 🔗 Related Resources

- [Week 1: Defender for Cloud Deployment Mastery](../01%20-%20Defender%20for%20Cloud%20Deployment%20Mastery/README.md)
- [Week 3: Defender XDR + Security Copilot Integration](../03%20-%20Defender%20XDR%20+%20Security%20Copilot%20Integration/README.md)
- [Project Root](../README.md)

---

**📋 Week 2 Status**: Storage foundation and Azure OpenAI service deployment **COMPLETED** ✅ - Ready for AI integration phase.
