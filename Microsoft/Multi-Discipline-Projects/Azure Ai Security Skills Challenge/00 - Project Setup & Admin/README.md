# Week 00 – Project Setup & Administration

This week establishes the foundation for the Azure AI Security Skills Challenge by setting up the development environment, validating prerequisites, and ensuring readiness for advanced security and AI service deployments in subsequent weeks.

## 🌍 Program Overview

**9-Week Azure AI Security Skills Challenge**: Comprehensive learning journey combining Azure security services, AI integration, and enterprise automation patterns through hands-on deployment and configuration experience.

**Foundation Week Focus**: Environment preparation, tool installation, authentication setup, and readiness validation to ensure successful progression through advanced security and AI modules.

## 🎯 Objectives

- Establish comprehensive Azure development environment with required tools and authentication.
- Validate Azure subscription access, permissions, and regional requirements for East US deployments.
- Configure development tools including Azure CLI, PowerShell, Visual Studio Code, and Bicep CLI.
- Execute comprehensive environment validation and readiness testing procedures.
- Document troubleshooting procedures and establish support resources for ongoing technical challenges.
- Prepare foundation infrastructure for Week 1 Microsoft Defender for Cloud deployments.

## 📁 Deliverables

- **Complete Development Environment**: Azure CLI, PowerShell modules, VS Code extensions, and Bicep tooling.
- **Authenticated Azure Access**: Validated connectivity to Azure services with appropriate subscription permissions.
- **Regional Compliance**: East US region access confirmed for optimal AI service availability in later weeks.
- **Environment Validation**: Comprehensive testing results confirming readiness for advanced module deployments.
- **Troubleshooting Resources**: Complete documentation and support escalation procedures.
- **Cost Management Foundation**: Basic budget and monitoring setup for curriculum resource management.

## ✅ Checklist

### Core Setup Modules

- [ ] **[Prerequisites & Environment Validation](./00.01%20Prerequisites%20&%20Environment%20Validation/README.md)** - Verify Azure subscription access, permissions, and regional requirements.
- [ ] **[Development Environment Setup](./00.02%20Development%20Environment%20Setup/README.md)** - Install and configure Azure CLI, PowerShell, Visual Studio Code, and essential extensions.
- [ ] **[Azure Cost Fundamentals & Budget Setup](./00.03%20Azure%20Cost%20Fundamentals%20&%20Budget%20Setup/README.md)** - Configure budget controls, cost monitoring, and resource lifecycle management.
- [ ] **[Troubleshooting & Resources](./00.04%20Troubleshooting%20&%20Resources/README.md)** - Access essential troubleshooting guidance and support resources for foundational setup.
- [ ] **[Week 00 to Week 1 Bridge](./00.05%20Week%2000%20to%20Week%201%20Bridge/README.md)** - Validate environment readiness and prepare for Defender for Cloud deployment.

> **📋 Week 00 Complete**: After completing all modules and passing validation tests, proceed to Week 1 for Microsoft Defender for Cloud deployment mastery.

## 📂 Project Organization

Week 00 follows the established modular structure for consistent learning experience:

```text
00 - Project Setup & Admin/
├── README.md                                          # Navigation and overview
├── Scripts/
│   ├── scripts-deployment/
│   │   └── Install-DevelopmentEnvironment.ps1        # Automated installation script
│   └── scripts-validation/
│       ├── Test-AzureEnvironment.ps1                 # Azure environment validation
│       └── Test-EnvironmentValidation.ps1            # Comprehensive validation script
├── 00.01 Prerequisites & Environment Validation/
│   └── README.md                                      # Azure subscription and service validation
├── 00.02 Development Environment Setup/
│   ├── README.md                                      # Tool installation and configuration
│   └── development-environment-setup.md              # Manual installation guide
├── 00.03 Azure Cost Fundamentals & Budget Setup/
│   ├── README.md                                      # Cost management navigation
│   └── azure-cost-management-setup-guide.md         # Comprehensive cost setup guide
├── 00.04 Troubleshooting & Resources/
│   └── README.md                                      # Essential troubleshooting and support resources
└── 00.05 Week 00 to Week 1 Bridge/
    └── README.md                                      # Environment readiness validation and Week 1 preparation
```

## 🌟 Learning Path Integration

### Week 00 Foundation Preparation

This setup week prepares the environment for:

**Week 01**: [Defender for Cloud Deployment Foundation](../01%20-%20Defender%20for%20Cloud%20Deployment%20Foundation/README.md)

- Security infrastructure foundation
- Baseline monitoring and logging
- Resource group and networking prerequisites

**Week 02**: [AI Foundation & Secure Model Deployment](../02%20-%20AI%20Foundation%20&%20Secure%20Model%20Deployment/README.md)  

- Azure OpenAI service prerequisites
- Storage account foundations for AI workloads
- Cost management for AI services

**Weeks 03-10**: Advanced AI security integration, automation, and enterprise deployment patterns building upon the foundation established in Week 00.

### Regional Requirements

**⚠️ CRITICAL**: East US region is mandatory throughout the curriculum for:

- Complete Azure OpenAI service availability (GPT models, pricing optimization)
- Microsoft Sentinel advanced analytics features (UEBA, Fusion detection)
- Security Copilot integration capabilities (later weeks)
- Optimal cost management with consolidated regional deployment

## 🚀 Quick Start Guide

### Rapid Environment Setup

For experienced Azure administrators seeking quick setup:

1. **Module 00.01**: Validate subscription permissions and East US access
2. **Module 00.02**: Run automated installation script: `.\Scripts\scripts-deployment\Install-DevelopmentEnvironment.ps1`
3. **Module 00.05**: Execute bridge validation: Complete [Week 00 to Week 1 Bridge](./00.05%20Week%2000%20to%20Week%201%20Bridge/README.md)
4. **Proceed to Week 1** upon successful validation

### Comprehensive Learning Path

For thorough understanding and skill development:

1. **Complete each module sequentially** following the checklist
2. **Review all documentation** for comprehensive understanding
3. **Execute manual procedures** alongside automation for learning reinforcement
4. **Document configuration** for troubleshooting reference

## 🎯 Success Metrics

### Environment Readiness Criteria

**Technical Validation**:

- [ ] Azure CLI authenticated with East US default region
- [ ] PowerShell Az modules imported with subscription context
- [ ] Visual Studio Code configured with 6+ Azure extensions
- [ ] Bicep CLI operational with template compilation capability
- [ ] All required resource providers registered and active
- [ ] Comprehensive validation script passes with 100% success rate

**Learning Outcomes**:

- [ ] Understanding of Azure authentication patterns and multi-service integration
- [ ] Proficiency with Infrastructure-as-Code tooling and development workflows
- [ ] Familiarity with Azure security service prerequisites and dependencies
- [ ] Competency in troubleshooting common development environment issues

## 🔄 Next Steps

Upon successful completion of Week 00:

1. **Proceed to Week 1**: [Defender for Cloud Deployment Foundation](../01%20-%20Defender%20for%20Cloud%20Deployment%20Foundation/README.md)
2. **Document Environment**: Save configuration details and validation results
3. **Join Learning Community**: Connect with other participants for support and knowledge sharing
4. **Bookmark Resources**: Save troubleshooting and reference materials for ongoing curriculum

---

## 🤖 AI-Assisted Content Generation

This comprehensive project setup and administration guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating modular learning architecture, Azure development environment best practices, and enterprise-grade preparation procedures for the Azure AI Security Skills Challenge curriculum.

*AI tools were used to enhance productivity and ensure comprehensive coverage of foundation setup requirements while maintaining technical accuracy and reflecting current Azure development standards and educational best practices.*
