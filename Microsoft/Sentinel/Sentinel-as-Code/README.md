# Sentinel-as-Code

> **Automate Microsoft Sentinel deployment and management using Azure DevOps Pipelines**

[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=flat&logo=powershell&logoColor=white)](https://docs.microsoft.com/en-us/powershell/)
[![Bicep](https://img.shields.io/badge/Bicep-0078D4?style=flat&logo=microsoft-azure&logoColor=white)](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
[![Azure DevOps](https://img.shields.io/badge/Azure%20DevOps-0078D4?style=flat&logo=azure-devops&logoColor=white)](https://azure.microsoft.com/en-us/products/devops/)

## 🎯 Overview

The **Sentinel-as-Code** project provides a comprehensive automation framework for deploying and managing Microsoft Sentinel environments using **Azure DevOps Pipelines**. This project enables organizations to implement security operations at scale with consistency, repeatability, and governance.

**Focus**: CI/CD deployment of Microsoft Sentinel artifacts using Azure DevOps and Bicep

**Target Audience**: DevSecOps Engineers, Security Architects, and SOC Engineers implementing automated detection engineering

**Duration**: 8-12 hours active setup & deployment | **Cost**: $5-50 (Log Analytics ingestion)

**Key Capabilities**:

- 🏗️ **Infrastructure Deployment**: Automated deployment of Log Analytics Workspaces and Microsoft Sentinel
- 🔍 **Analytics Rules Management**: Deployment of both NRT (Near Real-Time) and Scheduled analytics rules
- 📋 **Watchlist Automation**: CSV-based watchlist deployment with validation and change management
- 🔒 **Security-First Approach**: Role-based access control and least privilege principles
- 📈 **Scalable Architecture**: Multi-environment support with standardized configurations

**Learning Paths**:

- **Foundation Layer**: Workspace deployment and RBAC configuration
- **Detection Engineering**: Analytics rules and hunting queries as code
- **Enrichment Layer**: Watchlist management and reference data

**Coverage Depth**: ~45% of Sentinel landscape (deployment and engineering focus)

---

## 🏗️ Architecture & Design

### Deployment Architecture

```text
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            AZURE DEVOPS REPOSITORY                              │
└─────────────────────────┬───────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                       SENTINEL-CREATE PIPELINE                                  │
│                         (Foundation Layer)                                      │
└─────────────┬───────────────────┬───────────────────┬───────────────────────────┘
              │                   │                   │
              ▼                   ▼                   ▼
    ┌─────────────────┐   ┌─────────────────┐    ┌──────────────────┐
    │ Resource Group  │──▶│ Log Analytics   │──▶│ Microsoft        │
    │ Creation        │   │ Workspace       │    │ Sentinel         │
    └─────────────────┘   └─────────────────┘    └──────────────────┘
                                                         │
                                                         │
                                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          SECURITY CONTENT LAYER                                 │
├─────────────────────┬─────────────────────┬─────────────────────────────────────┤
│  Analytics Rules    │   Analytics Rules   │       Watchlists                    │
│  Pipeline (NRT)     │   Pipeline (Sched)  │       Pipeline                      │
│                     │                     │                                     │
│ ┌─────────────────┐ │ ┌─────────────────┐ │ ┌─────────────────────────────────┐ │
│ │ Near Real-Time  │ │ │ Scheduled       │ │ │ Security Reference Data         │ │
│ │ Detection Rules │ │ │ Detection Rules │ │ │ (CSV-based Watchlists)          │ │
│ └─────────────────┘ │ └─────────────────┘ │ └─────────────────────────────────┘ │
└─────────────────────┴─────────────────────┴─────────────────────────────────────┘
```

### Architecture Components

**🏗️ Foundation Layer** (Must Deploy First)

- **Resource Group**: Container for all Sentinel resources
- **Log Analytics Workspace**: Data storage and analytics foundation
- **Microsoft Sentinel**: Security orchestration and response platform

**🔒 Security Content Layer** (Deploy After Foundation)

- **NRT Analytics Rules**: Near real-time threat detection
- **Scheduled Analytics Rules**: Time-based threat detection
- **Watchlists**: Security reference data and threat intelligence

### 📁 Repository Structure

```text
Sentinel-as-Code/
├── 📄 README.md                              # This documentation
├── 🏗️ Sentinel-Create/                       # Foundation infrastructure
│   ├── Pipeline/
│   │   ├── pipeline.yml                      # Infrastructure deployment pipeline
│   │   └── pipeline-variables.yml            # Environment configuration
│   ├── Scripts/
│   │   ├── rg-deploy.ps1                     # Resource group deployment
│   │   ├── deploy-log-analytics-sentinel.ps1 # Log Analytics workspace deployment
│   │   └── deploy-sentinel.ps1               # Sentinel enablement
│   └── Template/
│       └── log-analytics-workspace.bicep     # Infrastructure template
├── 📊 Sentinel-Analytics-Rule-NRT-Create/    # Near Real-Time analytics rules
│   ├── Pipeline/
│   │   ├── pipeline.yml                      # NRT rule deployment pipeline
│   │   └── pipeline-variables.yml            # NRT rule configuration
│   ├── Scripts/
│   │   └── analytics-rule-deploy.ps1         # NRT rule deployment logic
│   └── Template/
│       ├── nrt-analytics-rule-payload.json   # Rule definition template
│       ├── nrt-analytics-rule-query.kql      # KQL query file
│       └── Test-KQL-Files/                   # Test and validation queries
├── 📋 Sentinel-Analytics-Rule-Scheduled-Create/ # Scheduled analytics rules
│   ├── Pipeline/
│   │   ├── pipeline.yml                      # Scheduled rule deployment pipeline
│   │   └── pipeline-variables.yml            # Scheduled rule configuration
│   ├── Scripts/
│   │   └── analytics-rule-deploy.ps1         # Scheduled rule deployment logic
│   └── Template/
│       ├── scheduled-analytics-rule-payload.json # Rule definition template
│       ├── scheduled-analytics-rule-query.kql    # KQL query file
│       └── Test-KQL-Files/                   # Test and validation queries
└── 📄 Sentinel-Watchlist-Manual/             # Watchlist management
    ├── Pipeline/
    │   ├── pipeline.yml                      # Watchlist deployment pipeline
    │   └── pipeline-variables.yml            # Watchlist configuration
    ├── Scripts/
    │   └── watchlist-deploy.ps1              # Watchlist deployment and validation
    └── Template/
        ├── watchlist.csv                     # Watchlist data file
        └── Sample-CSVs/                      # Example and test CSV files
```

---

## 🚀 Deployment Guide

### Prerequisites

Before implementing this project in **Azure DevOps**, ensure you have:

- ✅ **Azure Subscription** with appropriate administrative permissions
- ✅ **Azure DevOps Organization** with pipeline creation and management rights  
- ✅ **Service Principal** with required Azure roles (see [Security Requirements](#-security-requirements))
- ✅ **Azure CLI** installed and configured on build agents
- ✅ **PowerShell 5.1+** available on build agents for script execution
- ✅ **Bicep CLI** installed on build agents for infrastructure deployment

### 📥 Importing into Azure DevOps

#### Step 1: Repository Setup

1. **Create a new Azure DevOps repository** or clone this project
2. **Import the project structure** maintaining the folder hierarchy
3. **Verify file integrity** ensuring all pipeline and script files are present

#### Step 2: Service Connection Configuration

Create an Azure Resource Manager service connection in Azure DevOps:

```yaml
Name: SC-AzDO-YourOrg-ServiceConnection
Type: Azure Resource Manager
Authentication: Service Principal (manual)
Scope: Subscription
```

**⚠️ Service Principal Prerequisites**:

Before configuring the service connection, ensure your service principal has:

- **Minimum Reader permissions** on the target Azure subscription
- **Service principal registered** in the target Entra tenant
- **Valid client secret** created and not expired
- **Application permissions granted** by Entra administrator (if required)

**Configuration Steps**:

1. **Navigate to Azure DevOps** → Project Settings → Service connections
2. **Create new service connection** → Azure Resource Manager
3. **Select Authentication method**: Service principal (manual)
4. **Configure the following**:
   - **Subscription ID**: Your target Azure subscription ID
   - **Subscription Name**: Your target Azure subscription name
   - **Service Principal ID**: Application (client) ID from your Entra app registration
   - **Service Principal Key**: Client secret from your Entra app registration
   - **Tenant ID**: Your Azure Active Directory tenant ID
5. **Verify connection** and save with the name specified above

#### Step 3: Variable Configuration

Update pipeline variables in each `pipeline-variables.yml` file:

```yaml
# Required updates for each pipeline
serviceConnection: 'SC-AzDO-YourOrg-ServiceConnection'  # Your service connection name
subscriptionID: 'YOUR-SUBSCRIPTION-ID-HERE'              # Your Azure subscription ID
resourceGroupName: 'rg-sentinel-deployment'             # Your resource group name
location: 'eastus'                                       # Your preferred Azure region
logAnalyticsWorkspaceName: 'law-sentinel-workspace'     # Your workspace name
```

#### Step 4: Pipeline Creation

Import pipelines in the following order:

1. **Sentinel-Create** (Foundation) - `Sentinel-Create/Pipeline/pipeline.yml`
2. **Analytics Rules** - Both NRT and Scheduled rule pipelines
3. **Watchlists** - `Sentinel-Watchlist-Manual/Pipeline/pipeline.yml`

---

## 🔄 Deployment Order & Pipeline Execution

### ⚠️ Critical: Deployment Sequence

The pipelines **must be executed in a specific order** due to dependencies:

```text
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   PHASE 1       │     │   PHASE 2       │     │   PHASE 3       │
│   Foundation    │───▶│   Content       │───▶ │   Extensions    │
│   (Required)    │     │   (Parallel)    │     │   (Future)      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
│                      │                      │
├─ Sentinel-Create     ├─ Analytics Rules     ├─ Hunting Queries
│                      ├─ Watchlists          ├─ Automation Rules
│                      │                      └─ Workbooks
│
└─ MUST RUN FIRST      └─ Run after Phase 1   └─ Future expansion
```

### 1️⃣ Foundation Deployment (Required First)

**Pipeline**: `Sentinel-Create/Pipeline/pipeline.yml`

```bash
# This pipeline must run first and includes:
- Resource Group Creation
- Log Analytics Workspace Deployment  
- Microsoft Sentinel Enablement
```

**What it deploys**:

- ✅ Azure Resource Group (if not exists)
- ✅ Log Analytics Workspace with specified retention and pricing tier
- ✅ Microsoft Sentinel enabled on the workspace
- ✅ Foundation security infrastructure

### 2️⃣ Security Content Deployment (After Foundation)

Once the foundation is deployed, you can deploy content in any order:

#### Analytics Rules

```bash
# Deploy detection rules
- Sentinel-Analytics-Rule-NRT-Create/Pipeline/pipeline.yml      # Near Real-Time rules
- Sentinel-Analytics-Rule-Scheduled-Create/Pipeline/pipeline.yml # Scheduled rules
```

#### Watchlists

```bash
# Deploy reference data
- Sentinel-Watchlist-Manual/Pipeline/pipeline.yml               # CSV-based watchlists
```

---

## 📊 Comprehensive Capability Coverage

### Coverage Matrix: Sentinel-as-Code

This matrix shows which Sentinel capabilities are covered by this automation framework.

#### ✅ Core Architecture & Configuration

| Capability | Complexity | Coverage Status | Implementation |
|------------|------------|-----------------|----------------|
| **Workspace Design** | INTERMEDIATE | ✅ COMPREHENSIVE | Bicep deployment, retention config |
| **Access Control (RBAC)** | INTERMEDIATE | ✅ COMPREHENSIVE | Azure RBAC, Sentinel-specific roles |
| **Data Connectors** | BASIC | ✅ EXTENSIVE | Content Hub solutions, API connectors |
| **Log Analytics** | INTERMEDIATE | ✅ COMPREHENSIVE | Table configuration, basic KQL |

#### ✅ Threat Detection Engineering

| Capability | Complexity | Coverage Status | Implementation |
|------------|------------|-----------------|----------------|
| **Analytics Rules (Scheduled)** | INTERMEDIATE | ✅ COMPREHENSIVE | YAML-defined KQL rules, CI/CD deploy |
| **NRT Rules** | INTERMEDIATE | ✅ COMPREHENSIVE | Near-Real-Time rule pipelines |
| **Watchlists** | INTERMEDIATE | ✅ COMPREHENSIVE | CSV import automation, validation |
| **Custom KQL Functions** | ADVANCED | 📅 Planned | Library deployment via pipeline |

#### ✅ Security Orchestration & Automation (SOAR)

| Capability | Complexity | Coverage Status | Implementation |
|------------|------------|-----------------|----------------|
| **Automation Rules** | BASIC | 📅 Planned | Incident triggers, suppression logic |
| **Logic App Playbooks** | INTERMEDIATE | 📅 Planned | JSON definition, managed identity |
| **Context Enrichment** | INTERMEDIATE | 📅 Planned | External API integration patterns |

---

## 🔒 Security Requirements

### Service Principal Permissions (Least Privilege)

The Azure DevOps service connection requires these **minimum** Azure RBAC roles:

| Resource Scope | Role | Purpose |
|---|---|---|
| **Subscription** | `Reader` | Validate subscription access and resource existence |
| **Subscription** | `Log Analytics Contributor` | Create and manage Log Analytics workspaces |
| **Subscription** | `Microsoft Sentinel Contributor` | Enable Sentinel and manage security content |
| **Resource Group** | `Contributor` | Create and manage resource groups (if needed) |

### Security Best Practices

- 🔐 **Store sensitive values** in Azure DevOps Variable Groups or Azure Key Vault
- 🔍 **Regular access reviews** of service principal permissions
- 📝 **Audit pipeline executions** and maintain deployment logs
- 🏷️ **Use consistent tagging** for resource governance and cost management
- 🔄 **Implement change approval** processes for production environments

---

## 🛠️ Customization Guide

### Customizing Analytics Rules

1. **Modify KQL queries** in the `Template/*.kql` files
2. **Update rule properties** in the `*-payload.json` files
3. **Test error scenarios** using files in `Test-KQL-Files/` directories
4. **Validate rule logic** before pipeline execution

### Customizing Watchlists

1. **Update CSV data** in `Template/watchlist.csv`
2. **Modify watchlist properties** in `pipeline-variables.yml`
3. **Use Sample-CSVs** for testing different data scenarios
4. **Validate CSV format** and data integrity

### Customizing Infrastructure

1. **Customize Bicep templates** in `Sentinel-Create/Template/`
2. **Modify deployment scripts** for specific requirements
3. **Update retention and pricing** settings in pipeline variables
4. **Configure additional workspace features** as needed

---

## 🔮 Future Enhancements & Roadmap

### Planned Components

The project is designed for continuous expansion. Here are recommended areas for automation:

#### 🔍 **Hunting Queries**

```text
Sentinel-Hunting-Queries/
├── Pipeline/
├── Scripts/
└── Template/
    ├── hunting-query-template.json
    └── Queries/
        ├── user-behavior-hunting.kql
        ├── network-anomaly-hunting.kql
        └── threat-intelligence-hunting.kql
```

#### 🤖 **Automation Rules & Playbooks**

```text
Sentinel-Automation-Rules/
├── Pipeline/
├── Scripts/
└── Template/
    ├── automation-rule-template.json
    └── Playbooks/
        ├── incident-enrichment-playbook.json
        ├── response-automation-playbook.json
        └── notification-playbook.json
```

#### 🔗 **Data Connectors via Content Hub**

**Note**: Data connectors are now managed through Microsoft Sentinel Content Hub rather than direct API deployment. After your Sentinel foundation is deployed, you should configure data connectors based on your organization's specific data sources and security requirements.

**Suggested Data Connectors for Azure Environments**:

- **Azure Activity**: Monitor subscription-level operations and resource changes
- **Azure Active Directory**: Capture sign-ins, audit logs, and identity protection events
- **Microsoft 365**: Collect Office 365, Exchange Online, SharePoint, and Teams logs
- **Microsoft Defender for Cloud**: Ingest security alerts and recommendations
- **Windows Security Events**: Gather Windows event logs from Azure VMs
- **Azure Storage**: Monitor storage account access and operations
- **Azure Key Vault**: Track key vault access and secret usage
- **Microsoft Defender for Identity**: Identity-based attack detection and investigation

---

## 💼 Professional Skills Development

### Combined Skills Portfolio

Completing the Sentinel-as-Code project demonstrates proficiency in:

**Core Technical Competencies**:

- **SIEM Architecture**: Workspace design, data collection strategies, and RBAC models
- **Detection Engineering**: Advanced KQL, correlation logic, and false positive tuning
- **DevSecOps**: Git version control, CI/CD pipelines (Azure DevOps), and Bicep IaC
- **Infrastructure-as-Code**: Automated deployment of security resources

**Certification Alignment**:

- **Microsoft Certified: Security Operations Analyst Associate** (SC-200)
- **Microsoft Certified: Azure Security Engineer Associate** (AZ-500)
- **Microsoft Certified: DevOps Engineer Expert** (AZ-400) - Pipeline components

### Career Paths

**Roles supported by this expertise**:

- Security Operations Center (SOC) Analyst
- Threat Detection Engineer
- Security Automation Engineer
- Cloud Security Architect
- DevSecOps Engineer

---

## 📄 License & References

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**References**:

- [Microsoft Sentinel Documentation](https://docs.microsoft.com/en-us/azure/sentinel/)
- [Azure DevOps Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/)
- [KQL Reference](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/)
- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

---

## 🤖 AI-Assisted Content Generation

This Sentinel-as-Code project documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating DevOps best practices, Microsoft Sentinel architecture standards, and Infrastructure-as-Code principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Sentinel automation capabilities while maintaining technical accuracy and reflecting industry best practices for DevSecOps.*

