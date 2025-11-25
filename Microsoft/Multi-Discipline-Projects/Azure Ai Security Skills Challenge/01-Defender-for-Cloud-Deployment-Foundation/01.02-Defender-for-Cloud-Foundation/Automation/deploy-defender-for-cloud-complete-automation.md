# Deploy Microsoft Defender for Cloud - Complete Automation Guide

This guide provides a streamlined approach to deploying Microsoft Defender for Cloud using a single orchestration script that executes all deployment phases automatically. Choose between **Interactive Mode** (with user prompts) or **Fully Automated Mode** (no user interaction required).

## 🎯 Overview

This guide focuses on **speed and simplicity** - deploy a complete Microsoft Defender for Cloud environment using one script that orchestrates all deployment phases, with optional portal-only configurations for advanced features.

### What You'll Deploy

- **Phase 1: Infrastructure Foundation** - Resource groups, Log Analytics workspace, virtual networks, and storage.
- **Phase 2: Virtual Machines** - Windows Server 2022 and Ubuntu Linux VMs with security extensions.
- **Phase 3: Defender Plans** - Servers, Storage, Key Vault, and Containers protection with security contacts.
- **Phase 4: Security Features** - Just-in-Time VM Access, agentless scanning, and advanced threat protection.
- **Phase 5: Microsoft Sentinel Integration** - SIEM capabilities and data connector configuration.
- **Phase 6: Compliance Analysis** - Security posture assessment and governance reporting.
- **Phase 7: Deployment Validation** - Comprehensive deployment verification and health checks.
- **Phase 8: Cost Analysis** - Cost optimization recommendations and monitoring setup.
- **Phase 9: Auto-Shutdown Configuration** - Optional VM power management for cost optimization.
- **Phase 10: Portal Configuration Guide** - Manual tasks and configuration instructions.

### Deployment Options

- **🔄 Interactive Mode**: Script prompts for confirmation and parameters throughout deployment.
- **⚡ Fully Automated**: Uses `main.parameters.json` for zero-interaction deployment.
- **🎯 Selective Phases**: Deploy only specific phases (1-10) as needed.

### Timeline

- **Complete Deployment**: 25-45 minutes (all phases).
- **Portal Configuration**: 5-10 minutes (manual tasks in Phase 10).
- **Total Time**: 30-55 minutes.

---

## 📋 Prerequisites

Before starting, ensure you have:

- **Azure Subscription**: Active subscription with Owner or Contributor permissions.
- **Azure CLI**: Installed and authenticated to your Azure subscription.
- **PowerShell Environment**: Windows PowerShell 5.1+ or PowerShell 7+.
- **Repository Access**: Clone or download this repository with all scripts and Infrastructure-as-Code files.
- **Basic Azure Knowledge**: Understanding of Azure security concepts.

### Quick Environment Setup

```powershell
# Verify Azure CLI and authentication
az --version
az account show

# Set your subscription (if you have multiple)
az account set --subscription "Your-Subscription-Name-or-ID"

# Verify permissions
az role assignment list --assignee $(az account show --query user.name --output tsv) --scope "/subscriptions/$(az account show --query id --output tsv)" --output table
```

**Required Permissions**: Owner, Contributor, or Security Admin roles at subscription level.

### Parameter Configuration

Configure your deployment parameters in `infra/main.parameters.json`:

```json
{
  "parameters": {
    "environmentName": { "value": "securitylab" },
    "location": { "value": "East US" },
    "securityContactEmail": { "value": "your-email@company.com" },
    "adminUsername": { "value": "azureuser" },
    "adminPassword": { "value": "YourSecurePassword123!" },
    "enableDefenderForServers": { "value": true },
    "enableDefenderForStorage": { "value": true },
    "enableDefenderForKeyVault": { "value": true },
    "enableDefenderForContainers": { "value": true },
    "costAlertThreshold": { "value": 100 },
    "autoShutdownTime": { "value": "1800" }
  }
}
```

---

## 🚀 Complete Automated Deployment

### Option 1: Fully Automated Deployment (Recommended)

Deploy using the parameters file with no user interaction:

```powershell
# Navigate to the scripts directory
cd "01 - Defender for Cloud Deployment Foundation\scripts"

# Deploy everything using parameters file (no prompts)
.\Deploy-Complete.ps1 -UseParametersFile -Force
```

### Option 2: Interactive Deployment

Deploy with user prompts and confirmations:

```powershell
# Navigate to the scripts directory  
cd "01 - Defender for Cloud Deployment Foundation\scripts"

# Deploy with interactive prompts using parameters file
.\Deploy-Complete.ps1 -UseParametersFile
```

### Option 3: Preview Mode (What-If)

Preview all changes without executing them:

```powershell
# Preview deployment without executing
.\Deploy-Complete.ps1 -UseParametersFile -WhatIf

# Alternative: Preview with minimal output
.\Deploy-Complete.ps1 -UseParametersFile -WhatIf -Verbose
```

### Option 4: Selective Phase Deployment

Deploy only specific phases:

```powershell
# Deploy only infrastructure and VMs (phases 1-2)
.\Deploy-Complete.ps1 -UseParametersFile -Phases @(1,2) -Force

# Deploy only Defender plans and security features (phases 3-4)  
.\Deploy-Complete.ps1 -UseParametersFile -Phases @(3,4) -Force

# Deploy only automation phases (phases 5-9)
.\Deploy-Complete.ps1 -UseParametersFile -Phases @(5,6,7,8,9) -Force
```

### Script Parameters

#### Primary Parameter

- `-UseParametersFile`: Use values from `main.parameters.json` (recommended for all deployments).

#### Optional Parameters

- `-Force`: Skip confirmation prompts for fully automated deployment.
- `-WhatIf`: Preview all changes without executing deployment.
- `-Phases`: Array of phases to deploy (1-10), default is all phases.
- `-Verbose`: Enable detailed logging output for troubleshooting.

#### Legacy Parameters (for manual override only)

- `-EnvironmentName`: Unique identifier for your lab environment (overrides parameter file).
- `-Location`: Azure region for deployment (overrides parameter file).
- `-SecurityContactEmail`: Email address for security notifications (overrides parameter file).
- `-AdminUsername`: VM administrator username (overrides parameter file).

### What This Deploys (10-Phase Approach)

The complete script automatically deploys and configures all components across 10 phases:

#### **Phase 1: Infrastructure Foundation**

- ✅ Resource Group with proper naming convention and tagging.
- ✅ Log Analytics Workspace for security monitoring and data collection.
- ✅ Virtual Network with appropriate subnets and security groups.
- ✅ Network Security Groups with baseline security rules.

#### **Phase 2: Virtual Machine Deployment**

- ✅ Windows Server 2022 VM with latest security updates.
- ✅ Ubuntu Linux VM with security hardening.
- ✅ Azure Monitor Agent installation and configuration.
- ✅ VM extensions for monitoring and security compliance.

#### **Phase 3: Defender Plans Configuration**

- ✅ Defender for Servers Plan 2 (agentless scanning and advanced features).
- ✅ Defender for Storage with malware scanning and sensitive data discovery.
- ✅ Defender for Key Vault protection and threat detection.
- ✅ Defender for Containers security and vulnerability assessment.
- ✅ Security contact email configuration for alert notifications.

#### **Phase 4: Security Features Configuration**

- ✅ Just-in-Time VM Access policies configuration.
- ✅ Security recommendations and secure score initialization.
- ✅ Compliance standards assignment (Microsoft Cloud Security Benchmark).
- ✅ Advanced threat protection settings and alert rules.

#### **Phase 5: Microsoft Sentinel Integration**

- ✅ Sentinel workspace enablement on Log Analytics workspace.
- ✅ SIEM capabilities and threat detection rules.

#### **Phase 6: Compliance Analysis**

- ✅ Security posture assessment and reporting.
- ✅ Compliance standards evaluation and scoring.
- ✅ Governance recommendations and policy assignments.
- ✅ Regulatory compliance dashboard configuration.

#### **Phase 7: Deployment Validation**

- ✅ Comprehensive deployment verification across all phases
- ✅ Health checks for all deployed components
- ✅ Architecture validation and configuration verification
- ✅ Security feature functionality testing

#### **Phase 8: Cost Analysis**

- ✅ Cost optimization recommendations and monitoring setup
- ✅ Budget threshold configuration and alerting
- ✅ Resource utilization analysis and reporting
- ✅ Cost management insights and spending analysis

#### **Phase 9: Auto-Shutdown Configuration (Optional)**

- ✅ VM auto-shutdown schedule configuration
- ✅ Cost optimization through automated power management
- ✅ Notification setup for shutdown events
- ✅ Potential 60-70% reduction in VM compute costs

#### **Phase 10: Portal Configuration Guide**

- ✅ Step-by-step instructions for remaining manual tasks
- ✅ Defender for Cloud workbooks configuration guidance
- ✅ Sentinel data connector setup instructions
- ✅ File Integrity Monitoring enablement steps
- ✅ Sample alert generation and validation procedures

### Expected Deployment Timeline

- **Phase 1 - Infrastructure**: 5-8 minutes (Resource provisioning and networking).
- **Phase 2 - Virtual Machines**: 8-12 minutes (VM deployment and agent installation).
- **Phase 3 - Defender Plans**: 2-3 minutes (Security plan enablement).
- **Phase 4 - Security Features**: 3-5 minutes (JIT access and security policies).
- **Phase 5 - Sentinel Integration**: 2-4 minutes (SIEM workspace enablement).
- **Phase 6 - Compliance Analysis**: 2-3 minutes (Governance and compliance assessment).
- **Phase 7 - Deployment Validation**: 2-3 minutes (Comprehensive verification).
- **Phase 8 - Cost Analysis**: 1-2 minutes (Cost optimization recommendations).
- **Phase 9 - Auto-Shutdown**: 1-2 minutes (Optional cost optimization configuration).
- **Phase 10 - Portal Guide**: <1 minute (Instruction display).
- **Total Deployment Time**: 25-45 minutes.

### Real-Time Progress Monitoring

The script provides detailed progress updates throughout deployment:

```powershell
🚀 Microsoft Defender for Cloud - Complete Deployment Orchestrator
==================================================================

📄 Loading parameters from main.parameters.json...
   ✅ Environment Name: securitylab
   ✅ Location: West US
   ✅ Security Contact Email: marcus.jacobson@gmail.com
   ✅ Admin Username: azureuser

🔍 Validating deployment scripts...
   ✅ Found: Deploy-InfrastructureFoundation.ps1
   ✅ Found: Deploy-VirtualMachines.ps1
   ✅ Found: Deploy-DefenderPlans.ps1
   ✅ Found: Deploy-SecurityFeatures.ps1
   ✅ Found: Deploy-Sentinel.ps1
   ✅ Found: Deploy-ComplianceAnalysis.ps1
   ✅ Found: Test-DeploymentValidation.ps1
   ✅ Found: Deploy-CostAnalysis.ps1
   ✅ Found: Deploy-AutoShutdown.ps1

📋 Phase 1: Infrastructure Foundation (5-8 minutes)
   ⏳ Deploying core infrastructure...
   ✅ Resource Group created successfully
   ✅ Log Analytics Workspace deployed
   ✅ Virtual Network configuration complete

📋 Phase 2: Virtual Machine Deployment (8-12 minutes)
   ⏳ Deploying Windows Server 2022 VM...
   ⏳ Deploying Ubuntu Linux VM...
   ✅ VM deployment and configuration complete

📋 Phase 3: Defender Plans Configuration (2-3 minutes)
   ⏳ Enabling Defender for Cloud plans...
   ✅ All Defender plans enabled successfully

📋 Phase 4: Security Features Configuration (3-5 minutes)
   ⏳ Configuring Just-in-Time VM Access...
   ✅ Security features configured successfully

📋 Phase 5: Microsoft Sentinel Integration (2-4 minutes)
   ⏳ Enabling Sentinel workspace...
   ✅ SIEM integration completed successfully

📋 Phase 6: Compliance Analysis (2-3 minutes)
   ⏳ Running governance and compliance assessment...
   ✅ Compliance analysis completed successfully

📋 Phase 7: Deployment Validation (2-3 minutes)
   ⏳ Running comprehensive validation...
   ✅ All validation checks passed (100%)

📋 Phase 8: Cost Analysis (1-2 minutes)
   ⏳ Analyzing costs and optimization opportunities...
   ✅ Cost analysis completed successfully

📋 Phase 9: Auto-Shutdown Configuration (1-2 minutes)
   ⏳ Configuring VM auto-shutdown schedules...
   ✅ Auto-shutdown configuration completed

📋 Phase 10: Portal Configuration Guide (<1 minute)
   ⏳ Displaying remaining manual configuration steps...
   ✅ Portal configuration guide completed

🎯 Deployment Complete! Total time: 33 minutes
```

---

## 🌐 Portal-Only Configurations

After the automated deployment completes, Phase 10 will display detailed instructions for the following manual configurations that require Azure Portal interaction. These should be completed in the following order:

### Important Sequence

1. **Configure Defender for Cloud Workbooks** (Optional) - Visualization and monitoring setup.
2. **Enable Defender for Cloud Connector in Sentinel** - Must be done before generating sample alerts.
3. **Enable File Integrity Monitoring** - Advanced security monitoring capabilities.
4. **Generate Sample Alerts** - Ensures alerts flow into Defender for Cloud.
5. **Confirm Sample Alerts are Synced to Defender XDR** - Verify cross-platform integration.
6. **Confirm Sample Alerts are Synced to Sentinel** - Verify SIEM integration after propagation time.

### 1. Configure Defender for Cloud Workbooks (Optional)

**Why Portal-Only:** Interactive workbook configuration and customization requires portal interface.

#### Workbook Configuration Steps

1. Navigate to **Defender for Cloud** → **General** → **Workbooks**.
2. **Security Operations Efficiency** workbook.
   - Click **View template** → **Save**.
   - Select your Log Analytics workspace (log-aisec-defender-securitylab-testlab001).
   - Click **Apply** to save workbook.
3. **Azure Security Benchmark Assessment** workbook.
   - Click **View template** → **Save**.
   - Configure for your subscription and resource groups.
   - Click **Apply** to save workbook.
4. **Threat Protection Status** workbook.
   - Click **View template** → **Save**.
   - Select subscription and configure dashboard tiles.
   - Click **Apply** to save workbook.

**Expected Result**: Custom security dashboards providing visual insights into security posture, coverage metrics, and threat protection status.

### 2. Enable Defender for Cloud Connector in Sentinel

**Why Configure First:** Data connector must be active before generating sample alerts to ensure they flow into Sentinel.

#### Sentinel Connector Configuration Steps

1. Navigate to **Microsoft Sentinel** → Select your workspace (log-aisec-defender-securitylab-testlab001).
2. Go to **Content management** → **Content hub**.
3. Search for "**Microsoft Defender for Cloud**" solution.
4. Click **Install** on the Microsoft Defender for Cloud solution package.
5. After installation, go to **Data connectors** → **Microsoft Defender for Cloud**.
6. Click **Open connector page** → **Connect**.
7. Verify connector status shows **Connected**.
8. **Advanced Configuration** (Optional).
   - Toggle **Create incidents** to automatically generate Sentinel incidents from alerts.
   - Configure **Alert severity** filtering if desired.
   - Set **Incident creation** preferences.

**Expected Result**: Defender for Cloud data connector is active and ready to receive security alerts from all enabled Defender plans.

### 3. Enable File Integrity Monitoring

**Why Portal-Only:** Complex workspace integration requires interactive validation.

#### File Integrity Monitoring Configuration Steps

1. Navigate to **Defender for Cloud** → **Environment settings** → Your subscription.
2. Click **Defender plans** → **Servers** → **Settings**.
3. Toggle **File Integrity Monitoring** to **On**.
4. **Configuration panel automatically appears**.
5. **Workspace Configuration**: Select the Log Analytics workspace (log-aisec-defender-securitylab-testlab001).
6. **Use default recommendations**: ✅ **Recommended** - provides comprehensive coverage.
7. **Custom Rules** (Optional).
   - Add specific file paths or registry keys to monitor.
   - Configure exclusions for noisy system files.
   - Set change detection sensitivity.
8. Click **Continue** to save configuration.

**Expected Result**: FIM monitors system files, registry keys, and configuration changes using modern agentless scanning across both Windows and Linux VMs.

### 4. Generate Sample Alerts

**Why Portal-Only:** Interactive plan selection and validation required.

#### Sample Alert Generation Steps

1. Navigate to **Defender for Cloud** → **Security alerts**.
2. Click **Sample alerts** in the toolbar.
3. Select your subscription from dropdown.
4. Select relevant Defender plans to test.
   - **Defender for Servers**: VM threat detection and behavioral analysis.
   - **Defender for Storage**: Storage threat detection and malware scanning.
   - **Defender for Key Vault**: Key vault access and usage anomalies.
   - **Defender for Containers**: Container security alerts (if containers deployed).
5. Click **Create sample alerts**.

**Expected Result**: Sample alerts appear within 2-5 minutes in Defender for Cloud and trigger email notifications.

### 5. Confirm Sample Alerts are Synced to Defender XDR

**Why Verify:** Ensures cross-platform security operations and unified incident response.

#### Defender XDR Verification Steps

1. Wait **2-5 minutes** after generating sample alerts.
2. Navigate to **Microsoft Defender XDR** portal (security.microsoft.com).
3. Go to **Incidents & alerts** → **Alerts**.
4. Filter by **Detection source**: "Defender for Cloud".
5. Verify sample alerts appear with proper metadata.
   - Alert severity and classification.
   - Affected resources (VMs, storage accounts, etc.).
   - MITRE ATT&CK framework mapping.
   - Investigation timeline and evidence.

**Expected Result**: Defender for Cloud alerts appear in Defender XDR with full context and cross-platform correlation capabilities.

#### Defender XDR Timeline

- **Alert Propagation**: 2-5 minutes from Defender for Cloud.
- **Cross-Platform Correlation**: Available immediately upon alert arrival.
- **Advanced Hunting**: KQL queries available for deeper investigation.

### 6. Confirm Sample Alerts are Synced to Sentinel

**Why Verify:** Ensures SIEM integration and custom analytical rule processing.

#### Sentinel Verification Steps

1. Wait **5-15 minutes** after alerts appear in Defender for Cloud (allows for data connector propagation).
2. Navigate to **Microsoft Sentinel** → Your workspace (log-aisec-defender-securitylab-testlab001).
3. Go to **Incidents** to check for auto-generated incidents.
4. Go to **Logs** and run KQL query to verify alert ingestion.

   ```kusto
   SecurityAlert
   | where TimeGenerated > ago(1h)
   | where ProductName == "Azure Security Center"
   | project TimeGenerated, AlertName, AlertSeverity, Entities, Description
   | order by TimeGenerated desc
   ```

5. Verify alert data includes.
   - Complete alert metadata and context.
   - Affected entities and resources.
   - Investigation graphs and related events.
   - Custom enrichment data (if configured).

**Expected Result**: Defender for Cloud alerts appear in Microsoft Sentinel with full SIEM context, analytical rule processing, and incident correlation.

#### Sentinel Alert Timeline

- **Data Connector Ingestion**: 5-15 minutes from Defender for Cloud.
- **Incident Creation**: Immediate upon alert ingestion (if enabled).
- **Analytical Rules**: Process alerts based on configured rules and logic.
- **Investigation Graphs**: Available immediately for incident correlation.

---

## ✅ Deployment Validation

### Automated Validation (Built-in)

The deployment script includes comprehensive validation as Phase 5, but you can run additional validation independently to confirm the complete lab setup:

```powershell
# Run comprehensive validation with detailed reporting
.\Test-DeploymentValidation.ps1 -UseParametersFile -DetailedReport -ExportResults

# Run standard validation using parameters file
.\Test-DeploymentValidation.ps1 -UseParametersFile
```

### Manual Verification (Azure Portal)

#### Quick Portal Verification

1. **Defender for Cloud Overview** - Verify all plans show **Standard** tier enabled.
2. **Asset Inventory** - Check VMs appear with protection status **Protected**.
3. **Security Recommendations** - Review active security findings and compliance status.
4. **Microsoft Cloud Security Benchmark** - Monitor compliance percentage.

#### Expected Portal Results

- **Coverage Percentage**: ~85-90% (all enabled plans contributing).
- **Protected Resources**: 2 VMs + storage + key vault showing active monitoring.
- **Security Score**: Initial baseline calculation with improvement recommendations.
- **Active Recommendations**: 15-25 security findings available for remediation.

### CLI Verification Commands

```powershell
# Load parameters to get resource names
$parametersFile = Get-Content "..\infra\main.parameters.json" | ConvertFrom-Json
$resourceGroupName = $parametersFile.parameters.resourceGroupName.value
$environmentName = $parametersFile.parameters.environmentName.value

# Verify all Defender plans are enabled (should show "Standard")
az security pricing list --query "value[?pricingTier=='Standard'].{Name:name, Tier:pricingTier}" --output table

# Check security contacts configuration
az security contact list --query "[].{Email:email, Phone:phone, Alerts:alertNotifications.state}" --output table

# Verify VM protection status and agent health
az vm list --resource-group $resourceGroupName --query "[].{Name:name, PowerState:powerState, Location:location}" --output table

# Check Log Analytics workspace data ingestion
az monitor log-analytics workspace show --resource-group $resourceGroupName --workspace-name "law-aisec-defender-$environmentName" --query "{Name:name, RetentionDays:retentionInDays, Sku:sku.name}" --output table
```

### Validation Report Example

Successful deployment validation will show:

```text
🎯 Microsoft Defender for Cloud - Deployment Validation Report
==============================================================

📋 Infrastructure Validation (Phase 1)                     ✅ PASSED
   ✅ Resource Group: rg-aisec-defender-securitylab1
   ✅ Log Analytics Workspace: log-aisec-defender-securitylab  
   ✅ Virtual Network: vnet-aisec-defender-securitylab
   ✅ Network Security Groups: nsg-aisec-defender-securitylab

📋 Virtual Machine Validation (Phase 2)                    ✅ PASSED
   ✅ Windows VM: vm-aisec-defender-securitylab-win
   ✅ Linux VM: vm-aisec-defender-securitylab-linux
   ✅ Extensions: Agentless scanning enabled (Plan 2)
   ✅ Auto-shutdown: Configured for 7:00 PM daily

📋 Defender Plans Validation (Phase 3)                     ✅ PASSED
   ✅ Defender for Servers: Standard (Plan 2)
   ✅ Defender for Storage: Standard  
   ✅ Defender for Key Vault: Standard
   ✅ Defender for Containers: Standard
   ✅ Security Contact: Configured and validated

📋 Security Features Validation (Phase 4)                  ✅ PASSED
   ✅ Just-in-Time VM Access: Configured for both VMs
   ✅ Security Recommendations: 23 active findings
   ✅ Compliance Standards: MCSB assigned and scanning
   ✅ Advanced Threat Protection: Active

📋 Sentinel Integration Validation (Phase 5)               ✅ PASSED
   ✅ Sentinel Workspace: Enabled on Log Analytics
   ✅ Data Connectors: Defender for Cloud connected
   ✅ SIEM Capabilities: Active and monitoring

📋 Compliance Analysis Validation (Phase 6)                ✅ PASSED
   ✅ Security Posture: Assessed and scored
   ✅ Governance Rules: Applied and monitoring
   ✅ Regulatory Compliance: MCSB enabled

📋 Overall Deployment Status                              ✅ PASSED
   🎯 Deployment Score: 100% (16/16 validation checks)
   💰 Estimated Monthly Cost: $89.50 (with auto-shutdown)
   🛡️ Security Coverage: 85% (4/4 plans enabled)
   ⏱️ Total Deployment Time: 28 minutes

🔗 Next Steps:
   1. Configure Defender for Cloud workbooks (optional visualization)
   2. Enable Defender for Cloud connector in Sentinel 
   3. Enable File Integrity Monitoring
   4. Generate sample alerts for testing
   5. Confirm sample alerts sync to Defender XDR
   6. Confirm sample alerts sync to Sentinel after propagation
```

---

## 📊 Cost Management

### Expected Monthly Costs (July 2025 Pricing)

#### Core Security Services

- **Defender for Servers Plan 2**: ~$15 USD/server/month (2 VMs = $30/month).
- **Defender for Storage**: ~$0.02 USD/GB + $0.50/million transactions.
- **Defender for Key Vault**: ~$0.02 USD/operation (typically under $5/month).
- **Defender for Containers**: ~$7 USD/node/month (minimal for test environment).

#### Infrastructure Costs

- **Virtual Machines**: ~$30-40 USD/month each (Standard_B2s size).
- **Log Analytics**: ~$2.76 USD/GB ingested (500MB/day free with Defender for Servers).

**Total Estimated Cost**: $35-50 USD/month for security features + $60-80 USD/month for VMs if running continuously.

### Cost Optimization

#### Immediate Cost Savings

```powershell
# Load parameters to get resource group name
$parametersFile = Get-Content "..\infra\main.parameters.json" | ConvertFrom-Json
$resourceGroupName = $parametersFile.parameters.resourceGroupName.value

# Configure auto-shutdown for VMs (6:00 PM daily)
$windowsVm = az vm list --resource-group $resourceGroupName --query "[?contains(name, 'windows')].name" --output tsv
$linuxVm = az vm list --resource-group $resourceGroupName --query "[?contains(name, 'linux')].name" --output tsv

az vm auto-shutdown --resource-group $resourceGroupName --name $windowsVm --time "1800"
az vm auto-shutdown --resource-group $resourceGroupName --name $linuxVm --time "1800"
```

#### Cost Monitoring

1. Navigate to **Cost Management** → **Cost analysis** in Azure Portal.
2. Filter by your resource group to track lab spending.
3. Set up cost alerts for unexpected increases.

---

## 🔧 Troubleshooting

### Common Issues

#### Deployment Failures

##### Permission Issues

```powershell
# Verify required permissions
az role assignment list --assignee $(az account show --query user.name --output tsv) --scope "/subscriptions/$(az account show --query id --output tsv)"
```

**Solution**: Ensure you have Owner, Contributor, or Security Admin roles.

#### JIT Configuration Issues

##### JIT Policy Not Found in Validation

**Issue**: JIT policy created successfully but validation shows **No JIT policies found**

**Root Cause**: Location formatting inconsistencies between creation and validation APIs

**Solution**: Scripts automatically handle location conversion (**West US** → **westus**) using subscription-level endpoints

##### JIT Policy Propagation Delay

**Issue**: JIT policy creation succeeds but immediate validation fails

**Root Cause**: Azure security policies may take 10-30 seconds to propagate across regions

**Solution**: Scripts include automatic wait periods and retry logic for policy validation

##### Verification Commands

```powershell
# Manual verification of JIT policies
$subscriptionId = az account show --query "id" --output tsv
$location = "westus"  # Replace with your region (lowercase, no spaces)

# Check JIT policies at subscription level
az rest --method GET --url "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Security/locations/$location/jitNetworkAccessPolicies?api-version=2020-01-01" --query "value[].{Name:name, VMs:properties.virtualMachines[].id}" --output table
```

**Solution**: Ensure you have Owner, Contributor, or Security Admin roles.

##### Resource Naming Conflicts

**Error**: `The domain name label is invalid or reserved`

**Solution**: Edit the `environmentName` or `resourceToken` value in `main.parameters.json` to use a more unique identifier (e.g., add your initials or date).

##### Quota Limitations

```powershell
# Check VM quota in your region
az vm list-usage --location "East US" --output table
```

**Solution**: Choose a different region or request quota increase.

#### Configuration Issues

##### No VM Extensions Installed (Expected Behavior)

**Issue**: Validation shows "Extensions: Agentless scanning enabled (Plan 2)" or no VM extensions installed

**Root Cause**: This is **expected and correct** behavior for Defender for Servers Plan 2

**Explanation**:

- **Plan 2 uses agentless scanning** - no VM extensions required for security monitoring
- **JIT VM Access** works at the network level, independent of VM extensions
- **Vulnerability assessment** and **malware detection** work without agents
- **Extensions are optional** - only needed for specific scenarios (custom monitoring, etc.)

**Verification**: This is working correctly - no action needed.

##### No Security Alerts Appearing

1. Verify Defender plans are in Standard tier (not Free).
2. Wait 24-48 hours for initial data collection.
3. Generate sample alerts via Azure Portal.

##### Agentless Scanning Not Active

1. Confirm Defender for Servers Plan 2 is enabled.
2. Check VM status in Asset Inventory.
3. Allow 24-48 hours for initial scan completion.

---

## 🧹 Lab Decommissioning

When you're ready to remove the complete test environment:

### Option 1: Complete Automated Decommission (Recommended)

Remove all resources and Defender plans using parameters file:

```powershell
# Complete automated decommission with no prompts
.\Remove-DefenderInfrastructure.ps1 -UseParametersFile -DisableDefenderPlans -Force
```

### Option 2: Interactive Decommission with Confirmation

Remove resources with user confirmation prompts:

```powershell
# Interactive decommission with confirmations using parameters file
.\Remove-DefenderInfrastructure.ps1 -UseParametersFile -DisableDefenderPlans
```

### Option 3: Decommission Preview Mode

Preview what will be deleted without executing:

```powershell
# Preview decommission without executing
.\Remove-DefenderInfrastructure.ps1 -UseParametersFile -DisableDefenderPlans -WhatIf
```

### Decommission Features

#### What Gets Removed

- ✅ **Complete Resource Cleanup** - All VMs, networking, storage, and Log Analytics workspace.
- ✅ **Security Configuration Cleanup** - JIT policies, security contacts, and compliance assignments.
- ✅ **Defender Plan Management** - Optionally disable all pricing plans to prevent future charges.
- ✅ **Cost Optimization** - Immediate termination of all lab-related Azure charges.
- ✅ **Validation Reporting** - Comprehensive removal verification with detailed success/failure reporting.

#### Decommission Process

1. **Phase 1**: Security Features Cleanup (JIT policies, security configurations).
2. **Phase 2**: Virtual Machine Removal (VMs, disks, network interfaces).
3. **Phase 3**: Infrastructure Cleanup (VNet, storage, Log Analytics).
4. **Phase 4**: Resource Group Removal (complete resource group deletion).
5. **Phase 5**: Defender Plans Cleanup (optional - disable subscription-level plans).
6. **Phase 6**: Validation and Reporting (comprehensive cleanup verification).

#### Important Decommission Notes

- **Use `-DisableDefenderPlans`** for complete lab reset (recommended for isolated lab environments).
- **Omit `-DisableDefenderPlans`** if you have other resources protected by Defender plans.
- **Decommission typically takes 10-15 minutes** for complete cleanup.
- **Validation provides detailed reporting** showing successful cleanup verification.
- **Immediate cost savings** - all lab charges stop immediately upon completion.

---

## 📚 Next Steps

### Immediate Post-Deployment Actions

1. **Configure Defender for Cloud Workbooks** - Optional visualization dashboards for security monitoring.
2. **Enable Defender for Cloud Connector in Sentinel** - Essential for SIEM integration before alert testing.
3. **Enable File Integrity Monitoring** - Advanced security monitoring via portal configuration.
4. **Generate Sample Alerts** - Test alert creation and email notifications.
5. **Confirm Alerts Sync to Defender XDR** - Verify cross-platform security operations integration.
6. **Confirm Alerts Sync to Sentinel** - Validate SIEM integration and incident correlation.
7. **Set Up Cost Monitoring** - Configure cost alerts and review auto-shutdown settings.

### Advanced Configuration Options

1. **Microsoft Sentinel Integration** - Deploy SIEM capabilities with `.\Deploy-Sentinel.ps1 -UseParametersFile`.
2. **Compliance Analysis** - Run detailed compliance checks with `.\Deploy-ComplianceAnalysis.ps1 -UseParametersFile`.
3. **Cost Optimization** - Implement advanced cost management with `.\Deploy-CostAnalysis.ps1 -UseParametersFile`.
4. **Auto-Shutdown Configuration** - Set up VM auto-shutdown with `.\Deploy-AutoShutdown.ps1 -UseParametersFile`.
5. **Custom Security Policies** - Create organization-specific security policies and standards.

### Learning and Development Path

1. **Azure Security Center Learning Path** - Complete Microsoft Learn modules for Defender for Cloud.
2. **Hands-On Practice** - Experiment with security recommendations and policy customization.
3. **Multi-Subscription Management** - Scale deployment approach to enterprise environments.
4. **Integration Patterns** - Explore connections with Logic Apps, Event Grid, and third-party tools.

### Production Deployment Considerations

#### Incremental Rollout Strategy

- Start with non-production subscriptions using this automation approach.
- Customize `main.parameters.json` for different environments (dev, test, prod).
- Implement environment-specific security policies and compliance requirements.
- Plan integration with existing security tools and SIEM platforms.

#### Operational Excellence

- Establish monitoring and alerting workflows for security incidents.
- Document change management procedures for security configuration updates.
- Implement automated response patterns using Logic Apps or Azure Functions.
- Create runbooks for common security operations and incident response.

### Learning Resources

- **[Microsoft Defender for Cloud Learning Path](https://learn.microsoft.com/en-us/training/browse/?products=azure-defender)**.
- **[Azure Security Documentation](https://learn.microsoft.com/en-us/azure/security/)**.
- **[Infrastructure-as-Code Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)**.
- **[Security Operations and Incident Response](https://learn.microsoft.com/en-us/security/operations/)**.

---

## 🔗 Related Guides

- **[Deploy via Azure Portal](../Azure-Portal/deploy-defender-for-cloud-azure-portal.md)** - Manual step-by-step deployment for hands-on learning
- **[Modular Infrastructure-as-Code](../Infrastructure-as-Code/deploy-defender-for-cloud-modular-iac.md)** - Phase-by-phase IaC approach with detailed explanations
- **[Decommission Guide](../Decommission/decommission-defender-for-cloud.md)** - Comprehensive teardown procedures and cleanup verification

---

## 🛡️ Security Best Practices

### Lab Environment Security

- **Parameter File Security** - Store sensitive values like passwords in Azure Key Vault for production use.
- **Unique Environment Names** - Use distinct identifiers to prevent conflicts with existing resources.
- **Cost Controls** - Implement auto-shutdown, budget alerts, and resource lifecycle management.
- **Access Management** - Apply least privilege principles and use managed identities where possible.

### Production Considerations

- **Phased Rollout** - Deploy to non-production environments first for validation and testing
- **Policy Customization** - Adapt security policies and compliance standards to organizational requirements
- **Integration Planning** - Consider existing security tools, SIEM platforms, and incident response workflows
- **Change Management** - Document security configuration changes and maintain audit trails

### Automation Excellence

- **Version Control** - Maintain all Infrastructure-as-Code files and scripts in source control
- **CI/CD Integration** - Implement deployment pipelines for consistent and repeatable deployments
- **Testing Strategy** - Validate deployments using automated testing and validation scripts
- **Documentation** - Keep deployment guides and operational procedures current and accessible

This complete automation guide provides the fastest and most reliable path to a production-ready Microsoft Defender for Cloud environment while maintaining security best practices, cost control, and operational excellence.

---

## 🤖 AI-Assisted Content Generation

This comprehensive complete automation guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and deployment orchestration strategies were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating modern DevOps practices and Microsoft Azure security automation best practices.

*AI tools were used to enhance productivity and ensure comprehensive coverage of automated Microsoft Defender for Cloud deployment procedures while maintaining technical accuracy and reflecting the latest automation frameworks and security orchestration patterns.*
