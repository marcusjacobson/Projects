# AI-Driven Security Operations Automation Scripts

This directory contains PowerShell automation scripts for implementing comprehensive AI-driven security operations through Azure OpenAI and Defender XDR integration.

## 📁 Script Organization

### 🎯 scripts-orchestration/

- **Deploy-DefenderXDRIntegration.ps1** - Master orchestration script for complete XDR integration deployment

### 🔧 scripts-deployment/

- **Deploy-KeyVault.ps1** - Secure credential storage and OpenAI secrets management
- **Deploy-AppRegistration.ps1** - Entra ID app setup with Microsoft Graph Security API permissions  
- **Deploy-APIConnections.ps1** - API connections for OpenAI, Table Storage, and Microsoft Graph
- **Deploy-LogicAppWorkflow.ps1** - Complete Logic Apps workflow with ARM template deployment
- **Deploy-ProcessingStorage.ps1** - Table Storage for duplicate prevention and audit trails

### 🔍 scripts-validation/

- **Test-DefenderXDRIntegrationValidation.ps1** - Comprehensive validation with detailed reporting

### 🗑️ scripts-decommission/

- **Remove-DefenderXDRIntegration.ps1** - Complete decommission script with intelligent cleanup

### 📄 templates/

- **logic-app-arm-template.json** - Primary Logic App ARM template for XDR integration
- **logic-app-initial.json** - Initial Logic App configuration
- **logic-app-diagnostics.json** - Logic App diagnostics configuration

## 🚀 Usage

### Quick Start - Full Integration

```powershell
.\scripts-orchestration\Deploy-DefenderXDRIntegration.ps1 -UseParametersFile
```

### Individual Component Deployment

```powershell
.\scripts-deployment\Deploy-KeyVault.ps1 -UseParametersFile
.\scripts-deployment\Deploy-AppRegistration.ps1 -UseParametersFile
.\scripts-deployment\Deploy-LogicAppWorkflow.ps1 -UseParametersFile
```

### Validation

```powershell
.\scripts-validation\Test-DefenderXDRIntegrationValidation.ps1 -UseParametersFile -DetailedReport
```

### Cleanup

```powershell
.\scripts-decommission\Remove-DefenderXDRIntegration.ps1 -UseParametersFile -Force
```

## 📋 Prerequisites

- Completed Week 2: AI Foundation & Secure Model Deployment
- Azure OpenAI service deployed with GPT-4o-mini model
- Storage foundation established for AI workloads
- AI prompt templates tested and validated

## 🔗 Dependencies

This week builds on Week 2 foundations:

- Azure OpenAI service and model customization
- Storage accounts for state management  
- AI prompt templates for security analysis
- Cost management and budget controls

---

## 🤖 AI-Assisted Content Generation

This AI-driven security operations automation script collection was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The scripts, templates, and automation patterns were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Azure Logic Apps best practices, Defender XDR integration patterns, and enterprise-grade security automation standards.

*AI tools were used to enhance productivity and ensure comprehensive coverage of security automation functionality while maintaining technical accuracy and reflecting current Azure security operations best practices.*
