# Deploy Azure OpenAI + Defender XDR Integration - Infrastructure-as-Code Guide

This comprehensive guide provides a modular Infrastructure-as-Code approach to deploying the Azure OpenAI + Defender XDR integration workflow. This automation builds upon the Week 2 AI foundation and creates Logic Apps that analyze security incidents with AI-powered insights.

## 🎯 What You'll Deploy

This IaC deployment creates an enterprise-grade automated security workflow:

- **Logic Apps Workflow** for Defender XDR incident processing with AI analysis.
- **API Connections** for Azure OpenAI, Table Storage, and Microsoft Graph integration.
- **App Registration** with proper Microsoft Graph Security API permissions.
- **Key Vault** for secure credential storage and OpenAI secrets management.
- **Table Storage** for intelligent duplicate prevention and processing audit trails.
- **Testing and validation** framework for complete integration verification.
- **Role-based access controls** following security best practices.

### Key Integration Architecture

| Component | Purpose | Technology | Cost Impact |
|-----------|---------|------------|-------------|
| **Logic Apps Workflow** | Automated incident processing with AI analysis | Consumption plan | ~$1-3/month |
| **API Connections** | Service integration endpoints | Azure OpenAI, Table Storage, Microsoft Graph | Included |
| **AI Analysis Engine** | Structured security intelligence | Azure OpenAI (GPT-4o-mini from Week 2) | ~$5-15/month |
| **Duplicate Prevention** | Cost control and processing efficiency | Azure Table Storage (Week 2 storage account) | ~$0.05/month |
| **Security Management** | Credential protection and secrets storage | Azure Key Vault | ~$1-2/month |
| **Processing Storage** | Audit trails and workflow tracking | Table Storage (aiProcessed, processingAudit) | ~$0.10/month |

## 📋 Prerequisites and Dependencies

### Week 2 Foundation Requirements

This deployment requires successful completion of Week 2 AI foundation:

- ✅ **Azure OpenAI Service** deployed with GPT-4o-mini model in `rg-{environmentName}-ai` resource group.
- ✅ **Storage Account** with Table Storage capability for processing tracking.
- ✅ **Resource Group** `rg-{environmentName}-defender-{environmentName}` with proper permissions (from Week 1 Defender deployment).
- ✅ **Log Analytics Workspace** in the Defender resource group for monitoring integration.

### Verify Foundation Deployment

```powershell
# Verify Week 2 foundation components
cd "scripts\scripts-validation"
.\Test-AIFoundationReadiness.ps1 -UseParametersFile
```

### Required Permissions

- **Application Developer** role in Entra ID (for app registration creation).
- **Contributor** role on target subscription (for resource deployment).
- **Security Administrator** role (for Microsoft Graph permissions).

---

## 🏗️ Infrastructure-as-Code Architecture

### Deployment Structure

```text
scripts/
├── scripts-orchestration/
│   └── Deploy-DefenderXDRIntegration.ps1      # Master deployment orchestrator
├── scripts-deployment/
│   ├── Deploy-KeyVault.ps1                    # Key Vault and OpenAI secrets
│   ├── Deploy-AppRegistration.ps1             # App registration and permissions
│   ├── Deploy-APIConnections.ps1              # API connections deployment
│   ├── Deploy-LogicAppWorkflow.ps1            # Logic Apps workflow deployment
│   └── Deploy-ProcessingStorage.ps1           # Table Storage for duplicate prevention
├── scripts-validation/
│   └── Test-DefenderXDRIntegrationValidation.ps1 # Comprehensive validation testing
├── scripts-decommission/
│   └── Remove-DefenderXDRIntegration.ps1      # Clean decommission
└── templates/
    ├── logic-app-arm-template.json        # Main Logic App ARM template
    ├── logic-app-initial.json             # Initial Logic App configuration
    ├── openai-connection.json             # OpenAI API connection template
    ├── table-connection.json              # Table Storage connection template
    ├── graph-connection.json              # Microsoft Graph connection template
    └── [Additional JSON templates]        # Service-specific configurations

infra/ (Week 2 AI Foundation - Referenced Only)
├── main.bicep                             # Week 2 AI foundation (not used in XDR)
├── main.parameters.json                   # Shared parameter configuration
└── modules/                               # Week 2 modules (not used in XDR)
    ├── openai/                           # Referenced for service discovery
    └── storage/                          # Referenced for Table Storage integration
```

### Deployment Dependencies

```text
Week 2 AI Foundation → Key Vault → App Registration → API Connections → Logic App Workflow
       ↓                  ↓             ↓              ↓                    ↓
OpenAI + Storage → Credential Store → Graph Security → Service Integration → Automated Processing
```

### Implementation Approach

This deployment uses a **PowerShell script-based approach with JSON ARM templates** (not Bicep):

- **PowerShell Orchestration**: Master `Deploy-DefenderXDRIntegration.ps1` coordinates all deployment phases.
- **JSON ARM Templates**: Logic Apps uses JSON ARM templates from `scripts/templates/` directory.
- **Service Discovery**: Scripts automatically discover existing Week 2 AI infrastructure (OpenAI, Storage).
- **Parameter-Driven**: Configuration through `main.parameters.json` with cumulative parameter approach.
- **No Bicep Dependencies**: XDR integration scripts do not use any Bicep files directly.
- **Template-Based Logic Apps**: Complex workflow definitions use `logic-app-arm-template.json`.
- **Validation Framework**: Comprehensive testing through `Test-DefenderXDRIntegrationValidation.ps1`.

> **📋 Important**: The `infra/` Bicep files are from Week 2 AI foundation and are only referenced for service discovery, not deployed by the XDR integration scripts.

### Logic Apps Configuration Architecture

Logic Apps deployment requires a **three-tier parameter flow** to pass configuration from PowerShell scripts to the workflow:

#### Parameter Flow Chain

```text
PowerShell Scripts → ARM Template Parameters → Logic App Workflow → Runtime Execution
```

#### Why This Matters

- **Dynamic Configuration**: AI analysis prompts, frequencies, and limits configured via parameters file.
- **Environment Flexibility**: Same Logic App template works across dev/test/prod environments.  
- **Secure Parameter Flow**: Sensitive values (API keys, connection strings) passed securely through the parameter chain.
- **Deployment Reliability**: Proper parameter structure prevents common Logic App deployment errors.

---

## 🔒 Security Posture and Access Controls

### Enterprise-Grade Security Model

This deployment implements **defense-in-depth security architecture** with three integrated protection layers:

#### Security Architecture Stack

| Layer | Technology | Protection | Validation |
|-------|------------|------------|------------|
| **�️ Deployment** | ARM securestring encryption | Encrypted parameter passing | No secrets in deployment logs |
| **🔐 Storage** | Key Vault centralized secrets | Audit trails + rotation | Access policies enforce permissions |
| **⚡ Runtime** | Managed identity access | No stored credentials | Secure execution-time parameter flow |

#### Access Control & Parameter Visibility

| Azure Role | Designer Access | Parameter Visibility | Security Posture |
|------------|----------------|---------------------|------------------|
| **Logic App Contributor** | ✅ Full management | ✅ All parameters visible | **Secure** - Authorized admin access |
| **Logic App Operator** | ✅ Operations only | ✅ Runtime parameters visible | **Secure** - Operations team access |
| **Reader** | ❌ No designer access | ❌ No parameter access | **Secure** - Audit-only boundary |
| **No Role** | ❌ Complete access denial | ❌ No access | **Secure** - Proper isolation |

> **🔐 Security Confirmation**: Parameter visibility in Logic App Designer is **secure, expected behavior** for authorized users. Grayed-out parameter display indicates proper security implementation, not a vulnerability.

#### Core Security Controls

#### Active Protections

- **RBAC Enforcement** with role-based designer access.
- **Secret Encryption** through ARM template securestring parameters.
- **Centralized Credential Management** via Key Vault with audit trails.
- **Zero Stored Secrets** using managed identity for Azure resource access.
- **Comprehensive Audit Logging** across all system components.

**🎯 Security Validation**: This Logic App implements enterprise-grade security with proper parameter visibility for authorized users, demonstrating correct security implementation rather than a security concern.

#### Production Security Checklist

- [ ] **Access Control**: Limit Logic App Contributor role to essential personnel.
- [ ] **Authentication**: Enable MFA for all Logic App Designer access.
- [ ] **Network Security**: Configure private endpoints for network isolation.
- [ ] **Secret Management**: Implement automated secret rotation (6-12 months).
- [ ] **Monitoring**: Deploy alerts for unusual access patterns and operations.

---

## Step 1: Generate Sample Defender for Cloud Alerts (Manual Prerequisites)

Before deploying the Logic App automation, generate sample security alerts in Microsoft Defender for Cloud to provide test data for AI analysis and integration validation.

### 🚨 Manual Alert Generation Process

> **💡 Modern Approach**: Microsoft Defender for Cloud's current best practice emphasizes manual portal-based sample alert generation as the primary reliable method for creating test data.

**Manual Alert Generation Steps**:

1. **Access Microsoft Defender for Cloud**:
   - In Azure Portal, search for **Microsoft Defender for Cloud**.
   - Go to **Security alerts** in the left navigation.

2. **Generate sample security alerts**:
   - Click **Sample alerts** at the top of the Security alerts page.
   - Select your subscription and resource group (same as your Logic App deployment).
   - Choose alert types from the recommended categories below.
   - Click **Create sample alerts**.
   - Wait 2-5 minutes for alerts to appear in Defender for Cloud.
   - These alerts will be available as test data when your Logic App runs.

    **💡Note:** Adding multiple categories will generate additional alerts, resulting in a longer run for the logic app.

3. **Verify alert propagation**:
   - Check that alerts appear in Microsoft Defender for Cloud **Security alerts**.
   - Navigate to [Microsoft Defender XDR portal](https://security.microsoft.com).
   - Go to **Incidents & alerts** → **Incidents** to verify incident creation.
   - Wait 5-10 minutes for full propagation to Defender XDR.

### 🎯 Recommended Alert Categories for AI Analysis

**Optimal Categories for Testing**:

| Recommended Category | Why It's Optimal for AI Analysis | Alert Volume |
|---------------------|----------------------------------|--------------|
| **Virtual Machines** | Rich attack context with process details, file paths, and behavioral indicators | Moderate (2-4 alerts) |
| **Azure SQL Databases** | Clear attack vectors with query patterns and access anomalies | Low (1-2 alerts) |
| **Storage Accounts** | Data exfiltration scenarios with clear impact assessment | Low (1-2 alerts) |
| **Containers** | Modern attack patterns with container-specific threat intelligence | Moderate (2-3 alerts) |

**Additional Categories for Advanced Testing**:

These categories can be used to test different types of alerts and AI analysis.

| Category | Use Case | Alert Volume | Best For |
|----------|----------|--------------|----------|
| **App Services** | Web application attacks and injection scenarios | Moderate | Organizations with significant web presence |
| **Key Vaults** | Credential theft and secret access patterns | Low | High-security environments with sensitive data |
| **DNS** | Domain-based attacks and C2 communication | High | Network security teams |
| **Resource Manager** | Infrastructure manipulation and privilege escalation | Low | Cloud governance teams |
| **API** | API abuse and unauthorized access patterns | Moderate | API-heavy architectures |
| **AI Services** | AI model attacks and data poisoning scenarios | Low | Organizations using AI/ML workloads |

> **💡 Recommended Selection**: Start with **Virtual Machines** and **Azure SQL Databases** for the best balance of rich analysis content and manageable alert volume. These categories provide complex security scenarios that showcase AI analysis capabilities without overwhelming your testing environment.

> **🎯 Why Generate Alerts First**: Having sample alerts ready ensures your Logic App has realistic incident data to process during testing. This approach simulates authentic security scenarios for comprehensive AI analysis validation.

### ⏱️ Alert Processing Timeline

After generating sample alerts manually:

- **0-2 minutes**: Sample alerts appear in Defender for Cloud.
- **2-5 minutes**: Alerts propagate to Microsoft Defender XDR portal.
- **5-10 minutes**: XDR incidents created and available for Logic App processing.
- **10+ minutes**: Logic App workflow can process incidents and generate AI analysis.

> **⚠️ Important Timing**: Wait at least **10 minutes** after generating sample alerts before testing Logic App deployment to ensure full alert propagation and incident creation in Defender XDR.

### 📋 Validation Steps

**Verify Sample Alerts Successfully Created**:

1. **In Defender for Cloud**:
   - Navigate to **Security alerts**.
   - Verify sample alerts appear with **SAMPLE ALERT** prefix.
   - Note alert types and severity levels.

2. **In Defender XDR Portal**:
   - Go to [security.microsoft.com](https://security.microsoft.com).
   - Navigate to **Incidents & alerts** → **Incidents**.
   - Look for incidents containing the sample alerts.
   - Verify incidents show **active** status.

3. **Ready for Logic App Testing**:
   - Sample alerts are visible in both portals.
   - Incidents are created and accessible via Microsoft Graph API.
   - Logic App deployment can proceed with realistic test data.

> **✅ Success Indicator**: You should see multiple sample alerts in Defender for Cloud and corresponding incidents in the Defender XDR portal before proceeding with Logic App deployment.

---

## Step 2: Deploy Key Vault and OpenAI Secrets Storage

Create secure credential storage and store OpenAI service secrets for Logic Apps integration.

### 🔐 Deploy Key Vault Foundation

```powershell
# Create Key Vault and store OpenAI secrets
cd "scripts\scripts-deployment"
.\Deploy-KeyVault.ps1 -UseParametersFile
```

**This script will:**

- ✅ Create Azure Key Vault in Week 1 Defender resource group with globally unique naming.
- ✅ Handle Key Vault soft-delete scenarios automatically (recovery or purge).
- ✅ Discover OpenAI service deployment and credentials from Week 2 AI infrastructure.
- ✅ Store OpenAI endpoint, API key, and service information as Key Vault secrets using REST API.
- ✅ Configure access policies for current user with comprehensive secret management permissions.
- ✅ Assign Key Vault Administrator role for enhanced secret purging capabilities.
- ✅ Prepare secure foundation for app registration credential storage.

### Expected Key Vault Deployment Outputs

```powershell
🔐 Key Vault: kv-{environmentName}-xdr-{MMDD}
📍 Location: {location from parameters}
🏢 Resource Group: rg-{environmentName}-defender-{environmentName}
📋 OpenAI Secrets Stored:
   - OpenAI-Service-Endpoint: https://openai-****-***.openai.azure.com/
   - OpenAI-Service-APIKey: ********************************
   - OpenAI-Service-Name: openai-{environmentName}-{uniqueId}
   - OpenAI-ResourceGroup: rg-{environmentName}-ai
   - OpenAI-Deployment-Names: [JSON array of deployment names]
   - OpenAI-Primary-Deployment: {first deployment name}
✅ Access Policies: Configured for current user with secret management permissions
🔑 Key Vault Administrator: Role assigned for enhanced secret purging capabilities
🛡️ Soft-Delete Handling: Automatic recovery or purge of conflicting Key Vaults
⚡ REST API Implementation: All operations use direct Azure REST API calls
⏱️ Deployment Duration: ~120-180 seconds (includes soft-delete checks and role assignment)
```

## Step 3: Deploy App Registration and Security Foundation

Create the Entra ID app registration with proper Microsoft Graph permissions for Defender XDR access.

### 🚀 Deploy App Registration Foundation

```powershell
# Deploy app registration with Microsoft Graph Security permissions
cd "scripts\scripts-deployment"
.\Deploy-AppRegistration.ps1 -UseParametersFile
```

**This script will:**

- ✅ Create Entra ID app registration with descriptive naming (`LogicApp-DefenderXDRIntegration-{environmentName}`).
- ✅ Configure Microsoft Graph Security API permissions with application scope.
- ✅ Grant admin consent programmatically for all required permissions.
- ✅ Generate secure client secret with 2-year expiration.
- ✅ Auto-discover existing Key Vault from Step 2 deployment.
- ✅ Handle Key Vault soft-delete scenarios and credential conflicts.
- ✅ Store all app registration credentials as Key Vault secrets using REST API.
- ✅ Provide comprehensive validation and deployment summary.

### Microsoft Graph API Permissions

| Permission | Scope | Purpose |
|------------|--------|---------|
| `SecurityIncident.ReadWrite.All` | Application | Read/write Defender XDR incidents |
| `SecurityAlert.ReadWrite.All` | Application | Read/write security alerts |
| `SecurityEvents.Read.All` | Application | Read security events |

> **⚠️ Security Notice**: These permissions provide comprehensive access to security data across your tenant. The deployment follows principle of least privilege by scoping permissions to specific Graph API endpoints.

### Expected Deployment Outputs

```powershell
📱 App Registration Created:
   • Name: LogicApp-DefenderXDRIntegration-{environmentName}
   • Application (Client) ID: [Generated GUID]
   • Directory (Tenant) ID: [Your tenant ID]
   • Service Principal Object ID: [Generated GUID]

🔐 Key Vault Integration:
   • Key Vault Name: kv-{environmentName}-xdr-{MMDD}
   • Secrets Stored: 4 credential secrets
   • Location: Defender resource group

🔑 Key Vault Secret Names:
   • DefenderXDR-App-ClientId
   • DefenderXDR-App-ClientSecret
   • DefenderXDR-App-TenantId
   • DefenderXDR-App-ServicePrincipalId
```

---

## Step 4: Deploy Storage Foundation for Duplicate Prevention

Configure Azure Table Storage for intelligent duplicate prevention and processing audit trails.

### 🚀 Deploy Processing Storage

```powershell
# Deploy Table Storage for duplicate prevention
```powershell
# Deploy processing and archive storage for Defender XDR/AI data
cd "scripts\scripts-deployment"
.\Deploy-ProcessingStorage.ps1 -UseParametersFile
```
```

**This script will:**

- ✅ Auto-discover and integrate with existing Week 2 AI storage account.
- ✅ Create `aiProcessed` table for alert processing tracking and duplicate prevention.
- ✅ Create `processingAudit` table for workflow execution history and audit trails.
- ✅ Configure storage security settings (HTTPS-only, TLS 1.2 minimum).
- ✅ Insert schema documentation entities for reference.
- ✅ Validate table creation and provide Logic Apps connection details.

### Table Storage Overview

| Table Name | Purpose | Estimated Volume |
|------------|---------|------------------|
| `aiProcessed` | Alert processing tracking with 24-hour duplicate prevention | ~100-500 records/month |
| `processingAudit` | Workflow execution history and audit trails | ~200-1000 records/month |

> **💡 Cost Impact**: Table Storage adds approximately **$0.15/month** for typical usage volumes with 24-hour duplicate prevention and comprehensive audit tracking.

---

## Step 5: Deploy Logic Apps Workflow Foundation

Deploy the complete Logic Apps workflow solution with Microsoft Graph integration and Azure OpenAI analysis capabilities. This step involves two separate scripts that work together to create the full integration.

### 🔗 Step 5a: Deploy API Connections

First, deploy the required API connections that the Logic App workflow will use:

```powershell
# Deploy API connections for Logic Apps integration
```powershell
# Create API connections and validate authentication
cd "scripts\scripts-deployment"
.\Deploy-APIConnections.ps1 -UseParametersFile
```
```

This script performs an 8-step deployment process: parameter loading → authentication validation → service discovery → Azure OpenAI connection → Table Storage connection → Microsoft Graph validation → connection validation → deployment summary.

**This script will:**

- ✅ Create Azure OpenAI API connection with proper authentication.
- ✅ Create Azure Table Storage API connection for duplicate prevention.
- ✅ Validate Microsoft Graph app registration credentials in Key Vault.
- ✅ Configure connections in the Week 1 Defender resource group.
- ✅ Auto-discover required services from Week 2 AI infrastructure.
- ✅ Validate all connections are properly configured and ready.
- ✅ Provide comprehensive deployment summary and next steps.

### ⚡ Step 5b: Deploy Logic App Workflow

After API connections are created, deploy the main Logic App workflow:

```powershell
# Deploy Logic Apps workflow using existing API connections
cd "scripts\scripts-deployment"
.\Deploy-LogicAppWorkflow.ps1 -UseParametersFile
```

This script performs an 8-step deployment process starting from Step 2: prerequisite validation → Logic App creation → Log Analytics integration → API connection discovery → ARM template deployment → connection authorization → validation.

**This script will:**

- ✅ Perform comprehensive prerequisite validation.
- ✅ Deploy Logic Apps with optimized consumption plan configuration.
- ✅ Configure Log Analytics integration for monitoring and auditing.
- ✅ Discover and validate existing API connections from Step 5a.
- ✅ Deploy complete workflow definition using ARM template.
- ✅ Configure Key Vault integration for secure credential access.
- ✅ Enable system-assigned managed identity for secure access.
- ✅ Authorize API connections for secure operation.
- ✅ Validate complete deployment and provide integration summary.

### Logic Apps Components

#### Workflow Architecture

```text
Recurrence Trigger (4 hours) → Get Defender XDR Incidents → Parse Incidents
        ↓
For Each Incident → AI Analysis → Get Alert Details → For Each Alert
        ↓
Check Processing Status → Condition: Process Alert? → [Yes/No branches]
        ↓
[Yes] Extract AI Sections → Post Comments → Record Processing Status
        ↓
[No] Skip Processing (already completed within 24 hours)
```

#### API Connections Configuration

| Connection | Created By | Authentication | Purpose | Configuration |
|------------|------------|---------------|---------|---------------|
| **Azure OpenAI** | Deploy-APIConnections.ps1 | API Key | GPT-4o-mini AI analysis | Service API key from Week 2 OpenAI deployment |
| **Azure Table Storage** | Deploy-APIConnections.ps1 | Account Key | Duplicate prevention tracking | Storage account from Week 2 AI foundation |
| **Microsoft Graph** | Logic App HTTP Actions | OAuth 2.0 App Registration | Defender XDR API access | App registration credentials from Key Vault |

### Logic Apps Configuration

The deployment uses parameters from `infra/main.parameters.json` for complete customization. For lab environments, these recommended settings provide optimal learning experience:

> **🔧 Lab Configuration Recommendations**: The following settings work well for lab learning scenarios. To customize these values, modify the corresponding parameters in `infra/main.parameters.json` before deployment.

| Configuration Area | Lab Recommendation | Purpose | Parameters File Location |
|-------------------|-------------------|---------|-------------------------|
| **Processing Frequency** | `4 hours` (default) | Balanced processing load | `recurrenceInterval` |
| **AI Analysis Settings** | 500 tokens, temperature 0.3 | Consistent, concise analysis | `maxTokens`, `temperature` |
| **Incident Processing** | 50 incidents max, all severities | Comprehensive testing | `maxIncidentsPerRun`, `highSeverityOnly` |
| **Duplicate Prevention** | 24 hours tracking | Prevent reprocessing | `duplicatePreventionHours` |
| **OpenAI Model** | `gpt-4o-mini` deployment | Cost-effective AI analysis | `openAIDeploymentName` |

**To customize these settings**: Edit the values in `infra/main.parameters.json` and redeploy using `.\scripts-deployment\Deploy-LogicAppWorkflow.ps1 -UseParametersFile`.

---

## Step 6: Infrastructure Validation

Verify all infrastructure components are properly configured and deployed successfully through automated validation.

### 🔍 Execute Comprehensive Infrastructure Validation

Run the comprehensive validation script to verify successful deployment:

```powershell
# Run comprehensive infrastructure validation with detailed reporting
cd "scripts\scripts-validation"
.\Test-DefenderXDRIntegrationValidation.ps1 -UseParametersFile -DetailedReport
```

**Infrastructure Validation Checks:**

- ✅ **Week 1 Foundation**: Resource groups, Log Analytics workspace, Key Vault with app registration secrets.
- ✅ **Week 2 AI Infrastructure**: Azure OpenAI service, model deployments, storage account with table service.
- ✅ **App Registration Configuration**: Microsoft Graph API permissions, authentication secrets in Key Vault.
- ✅ **API Connections**: Azure OpenAI and Table Storage connections with authorization status.
- ✅ **Logic Apps Workflow**: Deployment status, managed identity, workflow definition, monitoring integration.
- ✅ **Processing Storage**: Table Storage tables for duplicate prevention and audit trails.

### 🎯 Infrastructure Success Criteria

**Expected Validation Results:**

- ✅ **Infrastructure Score**: 95-100% validation success across all components.
- ✅ **API Connections**: All connections show "Connected" or "Ready" status.
- ✅ **Logic Apps Status**: Workflow enabled with valid definition and triggers.
- ✅ **Security Configuration**: Managed identity configured with proper Key Vault access.
- ✅ **Storage Integration**: Processing tables created and accessible.

### 🔧 Common Infrastructure Issues

| Issue | Quick Resolution |
|-------|-----------------|
| **Infrastructure Validation Fails** | Run validation script with `-DetailedReport` for specific component guidance |
| **API Connection Authorization** | Re-authorize connections in Azure portal Logic Apps blade |
| **Key Vault Access Issues** | Verify app registration permissions and Key Vault access policies |
| **Storage Table Missing** | Re-run `Deploy-ProcessingStorage.ps1` script to create required tables |

> **✅ Success Checkpoint**: Infrastructure validation must pass before proceeding to Step 7 workflow testing.

---

## Step 7: Logic App Workflow Validation and Testing

Validate the complete end-to-end workflow functionality through manual testing and visual verification of AI-generated comments.

### 🧪 Workflow Integration Testing

After infrastructure validation passes, perform comprehensive workflow testing:

#### Generate Test Data

Generate sample security alerts in Microsoft Defender for Cloud as described in Step 1:

- Ensure sample alerts are created and propagated to Defender XDR (wait 10+ minutes)
- Verify incidents are visible in [security.microsoft.com](https://security.microsoft.com) → **Incidents & alerts** → **Incidents**

#### Execute Logic App Workflow

The Logic App workflow runs automatically upon deployment based on the recurrence schedule (default: every 4 hours). For immediate testing or manual execution:

**Automatic Execution:**

- Logic App triggers automatically after deployment according to the configured recurrence interval
- Check **Runs history** in the Azure portal to verify automatic execution

**Manual Execution (for testing):**

- Navigate to the Logic Apps workflow in Azure portal
- Go to **Logic app designer** from the left menu
- Click **Run** → **Run** at the top of the designer
- Monitor **Runs history** for successful execution (green checkmarks)
- Expected execution time: 2-5 minutes depending on incident volume

> **💡 Production Tip**: For initial testing, manual execution allows immediate validation without waiting for the recurrence schedule. The workflow will continue running automatically based on the configured interval.

#### Validate AI Comments in Defender XDR

Perform visual verification of AI-generated comments:

- Navigate to [security.microsoft.com](https://security.microsoft.com) and sign in
- Go to **Incidents & alerts** → **Incidents**
- Click on incidents that were processed (look for recent Activity Log entries)
- Navigate to the **Alerts** tab within each incident
- Click on individual alerts and scroll to the **Comments** section

**Expected AI Comment Structure** (4 comments per processed alert):

- **[AI Executive Summary]**: High-level incident overview and context
- **[AI Risk Assessment]**: Risk level analysis and potential business impact
- **[AI Immediate Actions]**: Step-by-step remediation recommendations
- **[AI MITRE ATT&CK]**: Attack technique mapping and tactical analysis

#### Test Duplicate Prevention

Verify the duplicate prevention mechanism works correctly:

- Wait for the first Logic App workflow run to complete processing
- Manually trigger the workflow again using Logic App Designer → **Run** → **Run**
- Monitor the workflow execution to completion
- Check the same alerts in Defender XDR for duplicate comments
- Verify no new comments are added to previously processed alerts (within 24 hours)
- Check Azure Table Storage (`aiProcessed` table) for processing records

### 🎯 Workflow Success Criteria

**Complete Integration Validation Results:**

- ✅ **Logic Apps Execution**: Workflow runs successfully without errors (green checkmarks in run history).
- ✅ **AI Comment Generation**: Structured AI comments appear in Defender XDR alerts with all 4 expected sections.
- ✅ **Duplicate Prevention**: No duplicate comments on repeated workflow runs within 24 hours.
- ✅ **Processing Tracking**: Azure Table Storage shows processing records for each processed alert.
- ✅ **Visual Verification**: Comments are visible and readable in the Defender XDR portal interface.

### 🔧 Common Workflow Issues

| Issue | Symptoms | Quick Resolution |
|-------|----------|-----------------|
| **Logic App Execution Fails** | Red error steps in run history | Check app registration permissions and API connection authorization |
| **No AI Comments Generated** | Workflow succeeds but no comments visible | Verify OpenAI model deployment status and Graph API permissions |
| **Partial Comment Generation** | Some alerts have comments, others don't | Check incident age and processing time window configuration |
| **Duplicate Comments Created** | Multiple identical comments per alert | Verify Azure Table Storage connection and duplicate prevention logic |
| **Missing Security Incidents** | No incidents available for processing | Generate fresh sample alerts and wait for propagation |

> **💡 Troubleshooting Guide**: For detailed troubleshooting of Logic App failures, learn how to examine action outputs and error details in the [Logic Apps troubleshooting documentation](https://learn.microsoft.com/en-us/azure/logic-apps/logic-apps-diagnosing-failures). This guide shows you how to inspect failed actions, view input/output data, and identify specific error messages for faster resolution.

> **💡 Production Tip**: The Logic App processes incidents created within the configured time window (default: 4 hours). For predictable testing, generate sample alerts immediately before triggering the workflow manually.

---

## 🚀 Complete Automated Deployment

This section provides a streamlined approach to deploying the complete Azure OpenAI + Defender XDR integration using a single orchestration script that executes all deployment phases automatically. Choose between **Interactive Mode** (with user prompts) or **Fully Automated Mode** (no user interaction required).

### Pre-Deployment Configuration

> **🚨 Required First**: Before running the automated deployment, you must generate sample Defender for Cloud alerts and verify they are fully propagated to Defender XDR. Follow the detailed instructions in **Step 1: Generate Sample Defender for Cloud Alerts** above. Wait at least **10 minutes** after alert generation to ensure complete consolidation in Defender XDR before proceeding with deployment.

**Before running the automated deployment**, verify and update these key parameters in `infra\main.parameters.json`:

**Required Configuration Updates:**

- **✅ `environmentName`**: **CRITICAL** - Must exactly match your Week 1/Week 2 infrastructure naming. Used to discover Week 2 AI services in `rg-{environmentName}-ai`.
- **✅ `defenderResourceGroupName`**: **CRITICAL** - Must exactly match your Week 1 Defender resource group name where Logic Apps will be deployed.
- **✅ `location`**: Must match your existing Week 1/Week 2 deployment region for consistency.
- **✅ `notificationEmail`**: Update to your actual email address for deployment notifications and alerts.

> **⚠️ Important**: The automated deployment script will use these parameter values directly. Incorrect email addresses, resource group names, or location mismatches will cause deployment failures.
>
> **🔧 Additional Customizations**: Beyond these required parameters, you can customize Logic App behavior (execution frequency, incident processing limits, AI analysis settings, duplicate prevention) by editing additional parameters in `main.parameters.json`. For detailed customization options, see the **Step 5: Logic Apps Configuration** table above.

### Option 1: Fully Automated Deployment (Recommended)

Deploy using the parameters file with no user interaction:

```powershell
# Deploy everything using parameters file (no prompts)
cd "scripts\scripts-orchestration"
.\Deploy-DefenderXDRIntegration.ps1 -UseParametersFile -Force
```

### Option 2: Interactive Deployment

Deploy with user prompts and confirmations:

```powershell
# Deploy with interactive prompts using parameters file
cd "scripts\scripts-orchestration"
.\Deploy-DefenderXDRIntegration.ps1 -UseParametersFile
```

### Additional Options

- **Preview Mode**: Add `-WhatIf` to preview changes without deployment
- **Verbose Output**: Add `-Verbose` for detailed logging
- **Skip Confirmations**: Add `-Force` for automated deployment

### 🚀 Deployment Process

#### What Gets Deployed

The deployment creates:

- **App Registration** - Defender XDR API access.
- **Key Vault** - Secure credential storage.
- **Storage Account** - Duplicate prevention tracking.
- **Logic App** - AI-powered incident analysis workflow.

**Total Deployment Time**: 20-30 minutes

#### Expected Deployment Experience

**Deployment Duration**: 20-30 minutes for complete integration

**Deployment Phases**:

1. **Phase 1**: Key Vault and OpenAI secrets storage (3-5 minutes)
2. **Phase 2**: App Registration and Microsoft Graph permissions (2-3 minutes)
3. **Phase 3**: Processing storage and duplicate prevention setup (1-2 minutes)
4. **Phase 4**: API Connections deployment (5-8 minutes)
5. **Phase 5**: Logic App workflow and validation (8-12 minutes)

> **� Success Indicator**: Deployment completes with "🎉 Deployment completed successfully!" message and all components show successful status.

#### After Deployment Completes

**Next Steps**: After successful automated deployment, refer to **Step 7: Logic App Workflow Validation and Testing** to:

- Validate completion of the Logic App workflow.
- Validate AI comment generation in Defender XDR.
- Test duplicate prevention mechanisms.
- Confirm end-to-end integration success.

---

## � Scripts Overview

### New Scripts for This Integration

The following scripts have been created specifically for the Defender XDR integration:

| Script | Purpose | Dependencies |
|--------|---------|--------------|
| `scripts-orchestration/Deploy-DefenderXDRIntegration.ps1` | **Master orchestrator script** | All component scripts |
| `scripts-deployment/Deploy-KeyVault.ps1` | Key Vault creation and OpenAI secrets storage | Azure CLI, Week 2 OpenAI service |
| `scripts-deployment/Deploy-AppRegistration.ps1` | Entra ID app setup with Graph permissions | Azure CLI, existing Key Vault |
| `scripts-deployment/Deploy-LogicAppWorkflow.ps1` | Complete Logic Apps deployment | Key Vault secrets, app registration |

### Referenced Week 2 Foundation Scripts

These existing scripts provide the AI foundation referenced by this integration:

| Script | Location | Purpose |
|--------|----------|---------|
| `Deploy-Week2Complete.ps1` | Week 2/scripts-orchestration | Complete Week 2 orchestration (modules 02.02 & 02.03) |
| `Deploy-StorageFoundation.ps1` | Week 2/scripts-deployment | Storage account for AI processing (Module 02.02) |
| `Deploy-OpenAIService.ps1` | Week 2/scripts-deployment | Azure OpenAI service deployment (Module 02.03) |

### Infrastructure Templates for XDR Integration

The following ARM/JSON templates are used to deploy the XDR integration components:

| Template | Purpose | Used By |
|----------|---------|---------|
| `logic-app-arm-template.json` | **Primary Logic App deployment** | scripts-deployment/Deploy-LogicAppWorkflow.ps1 |
| `logic-app-initial.json` | Logic App initial configuration | scripts-deployment/Deploy-LogicAppWorkflow.ps1 |
| `logic-app-diagnostics.json` | Logic App monitoring setup | scripts-deployment/Deploy-LogicAppWorkflow.ps1 |
| `openai-connection.json` | Azure OpenAI API connection | scripts-deployment/Deploy-APIConnections.ps1 |
| `graph-connection.json` | Microsoft Graph API connection | scripts-deployment/Deploy-APIConnections.ps1 |
| `table-connection.json` | Table Storage API connection | scripts-deployment/Deploy-APIConnections.ps1 |

### Configuration Templates

Additional JSON templates provide workflow configurations and prompts:

| Template | Purpose |
|----------|---------|
| `logic-app-workflow.json` | Complete workflow definition |
| `executive-summary-prompt.json` | AI prompt templates for analysis |
| `incident-response-automation.json` | Automated response configurations |
| `parse-json-schema.json` | JSON schema for data parsing |

> **💡 Template Architecture**: The integration uses ARM templates for Azure resource deployment and JSON configuration files for Logic App workflow definitions, API connections, and AI prompt configurations.

---

## 🚀 Decommission Infrastructure

> **� Choose Your Preferred Method**: Select automated script decommissioning for speed and safety, or manual portal decommissioning for step-by-step control.

### Method 1: Automated Script Decommissioning ⚡ (Recommended)

**Use this method for fast, comprehensive, and safe decommissioning:**

**Advantages**:

- **Fast**: Complete decommissioning in 2-3 minutes.
- **Safe**: Intelligent preservation of existing Week 1 and shared infrastructure.
- **Selective**: Only removes integration-specific components (preserves azuresentinel API connections).
- **Comprehensive**: Full validation with detailed reporting.
- **Cost-effective**: Immediate termination of all AI integration charges.

**Quick Start**:

**Step 1**: Navigate to Scripts Directory

```powershell
# Navigate to the scripts directory
cd "c:\REPO\GitHub\Projects\Microsoft\Azure Ai Security Skills Challenge\02 - AI Foundation & Secure Model Deployment\scripts"
```

**Step 2** Choose from the following options:

#### Preview Changes

```powershell
# Preview decommission (recommended first step)
cd "scripts\scripts-decommission"
.\Remove-DefenderXDRIntegration.ps1 -UseParametersFile -WhatIf
```

#### Execute Decommission

Choose one of the following based on your needs:

```powershell
# Standard decommission
cd "scripts\scripts-decommission"
.\Remove-DefenderXDRIntegration.ps1 -UseParametersFile -Force
```

```powershell
# Preserve cost management budgets during removal
# Enhanced decommission (preserves cost management and includes detailed logging)
cd "scripts\scripts-decommission"
.\Remove-DefenderXDRIntegration.ps1 -UseParametersFile -PreserveCostManagement -DetailedLog
```

### Method 2: Manual Portal Decommissioning 🖱️

**Use this method for step-by-step control through Azure Portal** - see the dedicated [Decommission Guide](../Decommission/decommission-openai-defender-xdr-integration.md).

> **🚨 Test Alert Cleanup Required**: After decommissioning, manually resolve any test alerts that were created in Microsoft Defender XDR during workflow testing. These alerts remain in the system after infrastructure removal and should be resolved before running the lab again to avoid alert duplication and confusion. Navigate to **Microsoft Defender XDR** → **Incidents & alerts** → **Alerts** to resolve any remaining test alerts.

---

## 🤖 AI-Assisted Content Generation

This comprehensive modular Infrastructure-as-Code deployment guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Azure OpenAI integration, Logic Apps automation, and modern Infrastructure-as-Code practices.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Azure deployment automation while maintaining technical accuracy and reflecting enterprise-grade Infrastructure-as-Code standards for security automation workflows.*
