# Decommission Microsoft Defender for Cloud - Lab Reset Guide (2025 Edition)

## 🎯 Purpose and Scope

This comprehensive decommissioning guide provides a systematic approach to safely remove Microsoft Defender for Cloud from your Azure environment and restore your lab to a clean slate. This guide supports **two different decommissioning approaches** based on how you originally deployed Microsoft Defender for Cloud.

## 🚀 Choose Your Decommissioning Method

### **Method 1: Automated Script Decommissioning** ⚡ (Recommended)

**Use this method if you deployed using:**

- **Modular Infrastructure-as-Code Guide** (`deploy-defender-for-cloud-modular-iac.md`)
- **Complete Automation Guide** (`deploy-defender-for-cloud-complete-automation.md`)

**✅ Advantages:**

- **Fast**: Complete decommissioning in ~2-3 minutes
- **Comprehensive**: 100% validation with 11 verification checks
- **Safe**: Automated resource discovery and validation
- **Cost-effective**: Immediate termination of all charges
- **Reliable**: Handles complex dependencies automatically

**🚀 Quick Start:**

```powershell
# Navigate to the scripts directory
cd "scripts"

# Run the automated decommission script
.\Remove-DefenderInfrastructure.ps1 -UseParametersFile -DisableDefenderPlans -Force
```

### **Method 2: Manual Portal Decommissioning** 🖱️

**Use this method if you deployed using:**

- **Azure Portal Manual Guide** (`deploy-defender-for-cloud-azure-portal.md`)
- **Manual configuration through Azure Portal**
- **Step-by-step manual deployment**

**📋 Process:** Follow the detailed [manual decommissioning steps](#step-1-remove-microsoft-sentinel-integration-if-configured) below for systematic portal-based removal.

---

## 💡 Why Use This Guide

This decommissioning process serves multiple purposes:

- **Cost Optimization**: Eliminate all Defender for Cloud charges and related infrastructure costs to avoid unexpected billing.
- **Lab Reset**: Return your Azure environment to a clean state for practicing deployment procedures multiple times.
- **Learning Tool**: Understand the complete lifecycle of Defender for Cloud by experiencing both deployment and decommissioning processes.
- **Resource Management**: Ensure proper cleanup of all Azure resources created during the lab, preventing resource sprawl.
- **Skills Development**: Practice systematic Azure resource management and governance procedures.

## 📋 What This Guide Covers

### **Automated Script Decommissioning** ⚡

The PowerShell script handles all decommissioning tasks automatically:

- **Comprehensive Discovery**: Automatic detection of all lab resources.
- **Security Configuration Removal**: JIT policies, auto-shutdown schedules, Sentinel integration.
- **VM Management**: Proper VM shutdown, deallocation, and deletion with all dependencies.
- **Defender Plan Management**: Automated disabling of all paid Defender plans.
- **Complete Validation**: 11-point verification ensuring 100% cleanup success.

### **Manual Portal Decommissioning** 🖱️

The manual process systematically reverses deployment in this order:

1. **Advanced Configuration Cleanup**: Remove Microsoft Sentinel integration, File Integrity Monitoring, and SIEM connectors.
2. **Workbooks and Dashboards**: Clean up custom security dashboards and monitoring workbooks.
3. **Security Monitoring**: Remove alert generation capabilities and notification configurations.
4. **Threat Protection Features**: Disable advanced threat protection and security recommendations.
5. **Security Policies**: Reset compliance standards and remove custom policy assignments.
6. **Virtual Machine Management**: Properly remove lab VMs with associated resources (disks, NICs, SSH keys).
7. **Agent and Extension Cleanup**: Uninstall monitoring agents and security extensions.
8. **Core Service Deactivation**: Disable Defender for Cloud plans and auto-provisioning settings.
9. **Resource Group Cleanup**: Complete removal of lab infrastructure including network resources.

## ✅ Expected Outcomes

After completing either decommissioning method, your Azure environment will have:

- **Zero Defender for Cloud charges**: All paid plans disabled and billing stopped.
- **Clean resource state**: All lab-specific resources removed with no orphaned components.
- **Restored baseline**: Azure subscription returned to pre-lab configuration.
- **Cost savings**: Elimination of VM compute costs, storage costs, and security monitoring charges.
- **Readiness for redeployment**: Environment prepared for repeating the lab or deploying alternative configurations.

---

## 📋 Prerequisites

### **For Automated Script Decommissioning:**

- Owner or Contributor permissions on the Azure subscription.
- PowerShell execution environment (Windows PowerShell 5.1+ or PowerShell 7+).
- Azure CLI installed and authenticated.
- Access to the scripts directory from your original deployment

### **For Manual Portal Decommissioning:**

- Owner or Contributor permissions on the Azure subscription
- Access to the Azure Portal
- Administrative access to virtual machines (if applicable)
- Understanding of which resources were created during deployment
- Backup of any important data or configurations you want to preserve

## ⚠️ Important Warnings

**READ BEFORE PROCEEDING:**

- This process will remove all security monitoring and protection
- Security alerts and historical data will be lost
- Compliance reports and assessments will be deleted
- VM extensions and agents will be uninstalled
- Log Analytics data may be permanently deleted

**Recommended Actions:**

- Export any required compliance reports before starting
- Document current security configurations
- Backup Log Analytics queries and workbooks
- Notify stakeholders of the decommissioning timeline

---

## 🚀 Automated Script Decommissioning (Recommended)

**Use this section if you deployed using the Modular Infrastructure-as-Code or Complete Automation guides.**

### Quick Automated Decommissioning

The `Remove-DefenderInfrastructure.ps1` script provides a comprehensive, automated approach to decommissioning your entire Microsoft Defender for Cloud lab environment.

**🎯 Script Capabilities:**

- **Comprehensive Resource Discovery**: Automatically identifies all lab resources using parameter files
- **Safe Decommissioning**: 6-phase systematic removal with built-in validation
- **Complete Cleanup**: Handles VMs, security policies, Sentinel integration, and Defender plans
- **Cost Optimization**: Immediate termination of all ongoing charges
- **Validation**: 11-point verification ensuring 100% cleanup success

### Step 1: Navigate to Scripts Directory

```powershell
# Navigate to the scripts directory from your original deployment
cd "c:\path\to\your\deployment\scripts"

# Or if you're already in the project root:
cd "01 - AI-Infused Security Foundations\scripts"
```

### Step 2: Run Complete Decommissioning

```powershell
# Complete decommissioning with Defender plan disabling (recommended)
.\Remove-DefenderInfrastructure.ps1 -UseParametersFile -DisableDefenderPlans -Force

# Alternative: Preview what will be removed first
.\Remove-DefenderInfrastructure.ps1 -UseParametersFile -WhatIf

# Alternative: Interactive confirmation (remove -Force flag)
.\Remove-DefenderInfrastructure.ps1 -UseParametersFile -DisableDefenderPlans
```

### Step 3: Verify Complete Removal

The script automatically performs comprehensive validation, but you can verify:

- **Zero costs**: Check Azure Cost Management for elimination of Defender charges
- **Clean subscription**: Verify no lab resources remain in the Azure Portal
- **Resource groups**: Confirm lab resource groups have been deleted
- **Defender plans**: All paid plans show as "Off" in Defender for Cloud settings

### Script Output Example

```text
✅ Enhanced Decommission Summary
================================
🎯 Validation Score: 100% (11/11 checks passed)
✅ All infrastructure successfully decommissioned and validated!
📊 Total monthly savings: ~$52-92/month
```

**⏱️ Expected Duration**: 2-3 minutes for complete automated decommissioning

---

## 📋 Manual Portal Decommissioning Steps

**Use this section if you deployed manually through the Azure Portal.**

This manual process follows the exact reverse order of deployment steps to ensure systematic and complete cleanup:

### Phase 1: Advanced Features Cleanup (Steps 1-4)

1. Remove Microsoft Sentinel integration and SIEM connectors
2. Clean up workbooks, dashboards, and custom monitoring
3. Remove File Integrity Monitoring configuration
4. Stop alert generation and clear sample alerts

### Phase 2: Core Security Features Cleanup (Steps 5-8)

1. Disable advanced threat protection features
2. Remove email notifications and alert configurations
3. Reset security policies and compliance standards
4. Clear security recommendations and assessments

### Phase 3: Agent and Infrastructure Cleanup (Steps 9-11)

1. Remove monitoring agents and VM extensions
2. Delete virtual machines and associated resources
3. Disable Defender for Servers and auto-provisioning

### Phase 4: Core Service and Resource Cleanup (Steps 12-14)

1. Disable all Defender for Cloud plans.
2. Clean up Log Analytics workspaces and data.
3. Remove resource groups and verify complete cleanup.

### Phase 5: Verification and Cost Optimization (Step 15)

1. Verify complete removal and cost optimization.

---

## Step 1: Remove Microsoft Sentinel Integration (If Configured)

**Note**: This step reverses the Microsoft Sentinel integration configured in the advanced data export section of the deploy guide. Skip this step if you did not configure Microsoft Sentinel.

### Why This Step Comes First

Microsoft Sentinel sits on top of Defender for Cloud data and must be disconnected before removing the underlying data sources to prevent data flow errors and ensure clean disconnection.

1. **Remove Defender for Cloud Data Connector**
   - Navigate to Microsoft Sentinel in Azure Portal.
   - Go to **Configuration** → **Data connectors**.
   - Find **Tenant-based Microsoft Defender for Cloud** connector.
   - Click on the connector and select **Disconnect** (if available).
   - Remove any configured automation rules that use Defender for Cloud data.

2. **Clean Up Sentinel Workbooks and Analytics Rules**
   - Navigate to **Content management** → **Content hub**.
   - Find the **Microsoft Defender for Cloud** solution.
   - Review installed workbooks, analytics rules, and hunting queries.
   - Disable or delete analytics rules that are no longer needed.
   - Remove custom workbooks that rely on Defender for Cloud data.

3. **Disable Microsoft Defender XDR Integration**
   - Navigate to Microsoft Defender Portal (if you have access).
   - Check if Defender for Cloud alerts are still flowing.
   - In Defender for Cloud, review integration settings.
   - Disable any remaining connections to Microsoft 365 Defender.
   - This stops alert forwarding to the unified portal.
   - **Important**: Data from endpoints will be retained for up to 6 months in Microsoft Defender XDR per Microsoft's retention policy.

4. **Option A: Remove Sentinel Completely**
   - If Sentinel was created only for this lab.
     - Navigate to Microsoft Sentinel overview.
     - Click **Settings** → **Workspace settings**.
     - Click **Remove Microsoft Sentinel**.
     - Confirm removal.
     - This preserves the Log Analytics workspace but removes Sentinel functionality.
     - **Note**: Installed solutions and linked services are permanently removed and cannot be recovered.

5. **Option B: Keep Sentinel Active**
   - If you want to continue using Sentinel for other purposes.
     - Disable Defender for Cloud-specific analytics rules.
     - Remove Defender for Cloud workbooks.
     - Keep the workspace and Sentinel instance active.
     - **Best Practice**: Document which analytics rules and workbooks you're removing for potential future reference.

📸 **[View Microsoft Sentinel Management Guide](https://learn.microsoft.com/en-us/azure/sentinel/offboard)**

---

## Step 2: Remove Workbooks and Dashboards

**Note**: This step reverses the workbooks and dashboards configured in Step 12 of the deploy guide.

### Why This Step Comes Second

Custom dashboards and workbooks depend on active data flows from Defender for Cloud. Removing them before disabling the underlying services prevents broken dashboard components.

1. **Remove Custom Dashboards**
   - Navigate to Azure Portal dashboard (portal.azure.com main page).
   - Identify dashboards created for the lab:
     - Security alerts tiles.
     - Recommendations tiles.
     - Pinned workbooks from the lab.
   - For each custom dashboard:
     - Click on the dashboard.
     - Click **Delete** from the dashboard menu.
     - Confirm deletion.

2. **Clean Up Defender for Cloud Workbooks**
   - Navigate to **Microsoft Defender for Cloud** → **Workbooks**.
   - Identify workbooks used during the lab:
     - **Coverage Workbook** (if customized).
     - **Secure Score Over Time**.
     - **Active Alerts**.
     - **Compliance Over Time**.
     - Any custom workbooks created.
   - For each workbook:
     - Open the workbook.
     - If you made customizations, click **Reset to default** or **Delete**.
     - Remove any saved custom versions.

3. **Clear Workbook Customizations**
   - Reset the **Coverage Workbook** to default settings.
   - Remove any custom filters or views you created.
   - Clear any saved workbook queries or visualizations.

📸 **[View Workbooks and Dashboards Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/custom-dashboards-azure-workbooks)**

---

## Step 3: Remove File Integrity Monitoring Configuration

**Note**: This step reverses the File Integrity Monitoring setup from the advanced configuration section of the deploy guide.

### Why This Step Comes Third

File Integrity Monitoring generates ongoing data that should be stopped before removing the underlying monitoring infrastructure to prevent orphaned monitoring processes.

1. **Disable File Integrity Monitoring**
   - Navigate to **Microsoft Defender for Cloud** → **Environment settings**.
   - Select your subscription → **Defender for Servers** → **Settings**.
   - Toggle **File Integrity Monitoring** to **Off**.
   - Confirm the setting change.

2. **Clean Up FIM Data and Configuration**
   - Navigate to the Log Analytics workspace (e.g., **law-sentinel-security-operations**).
   - Go to **General** → **Logs**.
   - Review and clear any custom FIM queries you created.
   - Note: Historical FIM data will be retained based on workspace retention settings.

3. **Remove Custom FIM Rules (If Configured)**
   - If you configured custom file monitoring rules:
     - Navigate to **Environment settings** → **Data collection**.
     - Review FIM configuration settings.
     - Remove any custom file paths or registry keys you added.
     - Reset to default monitoring configuration.
   - **For Modern FIM (Defender for Endpoint)**: Settings are automatically managed and will be disabled when Defender for Endpoint is removed.

4. **Verify FIM Deactivation**
   - Wait 15-30 minutes after disabling FIM.
   - Check that new FIM data is no longer being generated.
   - Verify no FIM processes are running on VMs.
   - **Modern Approach**: FIM via Defender for Endpoint will automatically stop when the agent is removed in later steps.

📸 **[View File Integrity Monitoring Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/file-integrity-monitoring-overview)**

---

## Step 4: Stop Alert Generation and Clear Sample Alerts

**Note**: This step reverses the alert monitoring and sample alert generation from Step 11 of the deploy guide.

### Why This Step Comes Fourth

Active alert generation and sample alerts create ongoing data flows that should be stopped before disabling the core monitoring services to ensure clean shutdown.

1. **Stop Sample Alert Generation**
   - If you have any ongoing sample alert generation processes, stop them.
   - Wait for any pending sample alerts to complete processing.
   - Allow 10-15 minutes for all sample alerts to appear in the system.

2. **Clear Sample Alerts from Defender for Cloud**
   - Navigate to **Microsoft Defender for Cloud** → **Security alerts**.
   - Identify sample alerts (typically marked with **Sample** in the title or description).
   - For each sample alert:
     - Click on the alert.
     - Click **Dismiss** or **Close**.
     - Confirm dismissal.

3. **Clear Sample Alerts from Microsoft Defender XDR (If Configured)**
   - Navigate to Microsoft Defender Portal ([security.microsoft.com](https://security.microsoft.com)).
   - Go to **Incidents & alerts** → **Alerts**.
   - Filter by **Product name: Microsoft Defender for Cloud**.
   - Dismiss sample alerts that were generated during testing.

4. **Clear Sample Incidents from Sentinel (If Configured)**
   - Navigate to Microsoft Sentinel (if still active).
   - Go to **Threat management** → **Incidents**.
   - Find incidents created from sample Defender for Cloud alerts.
   - Close or dismiss test incidents.

5. **Verify Alert Generation Stopped**
   - Monitor for 30 minutes to ensure no new sample alerts are generated.
   - Confirm alert queues are clear before proceeding.

📸 **[View Security Alerts Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/managing-and-responding-alerts)**

---

## Step 5: Disable Advanced Threat Protection Features

**Note**: This step reverses the advanced threat protection features configured in Step 10 of the deploy guide.

### Why This Step Comes Fifth

Advanced threat protection features generate active monitoring and scanning processes that should be disabled before removing the underlying security policies and configurations.

1. **Disable Advanced Threat Protection for Specific Services**
   - Navigate to **Microsoft Defender for Cloud** → **Environment settings**.
   - Select your subscription.
   - Review and disable advanced protection for:
     - **App Service** (if enabled).
     - **Storage** (if enabled).
     - **SQL** (if enabled).
     - **Containers** (if enabled).
     - **Key Vault** (if enabled).
     - **Resource Manager** (if enabled).
     - **DNS** (if enabled).

2. **Disable Real-Time Protection Features**
   - Turn off any real-time scanning capabilities.
   - Disable automatic threat response features.
   - Stop any ongoing security assessments.

3. **Clean Up Threat Intelligence Integration**
   - Remove any custom threat intelligence feeds.
   - Disable threat intelligence correlation features.
   - Clear any threat hunting configurations.

4. **Verify Threat Protection Deactivation**
   - Confirm no active threat protection processes are running.
   - Check that advanced scanning has stopped.
   - Allow 10-15 minutes for deactivation to complete.

📸 **[View Advanced Threat Protection Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/alerts-overview)**

---

## Step 6: Remove Email Notifications and Alert Configurations

**Note**: This step reverses the alert and notification configurations from Step 9 of the deploy guide.

### Why This Step Comes Sixth

Email notifications and alert configurations should be removed before disabling security policies to prevent orphaned notification rules and ensure clean policy removal.

1. **Clear Email Settings**
   - Navigate to **Email notifications** in Environment settings.
   - Remove all email addresses from:
     - Security contact emails.
     - Additional email addresses.
   - Uncheck all notification types:
     - High severity alerts.
     - Alerts to subscription admins.
     - Weekly digest emails.

2. **Remove Workflow Automation**
   - Navigate to **Workflow automation** in Defender for Cloud.
   - Review all configured automation rules.
   - For each automation rule:
     - Click on the rule.
     - Click **Delete**.
     - Confirm deletion.

3. **Clean Up Logic Apps (Optional)**
   - Navigate to Logic Apps in Azure Portal.
   - Review Logic Apps created for Defender for Cloud.
   - Delete Logic Apps that are no longer needed.
   - Remove associated resource groups if empty.

4. **Save Configuration**
   - Click **Save** to apply changes.
   - Verify no notifications are configured.

📸 **[View Email Notifications Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/configure-email-notifications)**

---

## Step 7: Reset Security Policies and Compliance Standards

**Note**: This step reverses the security policy configurations from Step 7 of the deploy guide.

### Why This Step Comes Seventh

Security policies and compliance standards must be reset before removing the underlying assessments and recommendations to ensure proper policy cleanup.

1. **Reset Compliance Standards**
   - Navigate to **Regulatory compliance** in Defender for Cloud.
   - For each compliance standard you added during the lab:
     - **NIST Cybersecurity Framework** (if added).
     - **ISO 27001** (if added).
     - **SOC 2** (if added).
   - Remove custom compliance standards:
     - Click on the standard.
     - Select **Remove assignment**.
     - Confirm removal.

2. **Reset Azure Security Benchmark**
   - Navigate to **Security policy** in Defender for Cloud.
   - Click on **Azure Security Benchmark**.
   - If you made customizations, click **Reset to default**.
   - This restores original policy settings.
   - Click **Save**.

3. **Remove Custom Policy Initiatives**
   - Identify any custom initiatives you created.
   - Click on custom initiatives.
   - Select **Delete assignment**.
   - Confirm deletion.

4. **Remove Policy Assignments (Azure Policy)**
   - Navigate to Azure Policy in Azure Portal.
   - Go to **Assignments**.
   - Look for Defender for Cloud related assignments:
     - **ASC DataCollection**.
     - **Deploy Dependency Agent**.
     - **Deploy Log Analytics Agent**.
   - Delete these assignments.

📸 **[View Security Policy Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/security-policy-concept)**

---

## Step 8: Clear Security Recommendations and Assessments

**Note**: This step reverses the security recommendations review from Step 8 of the deploy guide.

### Why This Step Comes Eighth

Security recommendations and assessments should be cleared before removing the underlying monitoring agents to ensure no orphaned assessment processes remain.

1. **Review and Clear Recommendations**
   - Navigate to **Recommendations** in Defender for Cloud.
   - Note current recommendations for documentation purposes (optional).
   - Clear any custom recommendation filters you created.
   - Reset recommendation views to default settings.

2. **Clear Security Assessments**
   - Navigate to **Secure Score** in Defender for Cloud.
   - Note current secure score for comparison (optional).
   - Clear any custom secure score tracking.
   - Reset secure score calculations to default.

3. **Remove Custom Assessment Configurations**
   - Remove any custom vulnerability assessment configurations.
   - Clear any manual assessment overrides you created.
   - Reset assessment frequency to default settings.

4. **Verify Assessment Cleanup**
   - Confirm no custom assessments are running.
   - Check that recommendation generation will stop when agents are removed.

📸 **[View Security Recommendations Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/review-security-recommendations)**

---

## Step 9: Remove Monitoring Agents and VM Extensions

**Note**: This step reverses the agent verification from Step 6 of the deploy guide and prepares for VM removal.

### Why This Step Comes Ninth

Monitoring agents and extensions must be cleanly removed before deleting VMs to prevent orphaned processes and ensure proper cleanup of monitoring infrastructure.

1. **Identify Protected Virtual Machines**
   - Navigate to **Asset inventory** in Defender for Cloud.
   - Filter by **Virtual machines**.
   - Note VMs with Defender extensions installed:
     - **vm-windows-server**.
     - **vm-linux-db**.
     - **vm-windows-client**.

2. **Remove Extensions from Each VM**
   **For each Virtual Machine:**
   - Navigate to Virtual Machines in Azure Portal.
   - Select the VM → **Extensions + applications**.
   - Remove the following extensions from your modern deployment:
     - **Microsoft Defender for Endpoint** (primary security agent).
     - **Azure Security Center Vulnerability Assessment**.
     - **Guest Configuration Extension**.
     - **Azure Monitor Agent (AMA)** (only if configured for SQL Server monitoring and not needed for other services).

3. **Modern Agent Removal Process**
   - Focus on removing **Microsoft Defender for Endpoint** extension as the primary security component.
   - **Azure Monitor Agent (AMA)** provides agentless scanning benefits and may be retained for other Azure services.
   - All monitoring is primarily handled through agentless scanning in the modern architecture.

4. **Uninstall Process**
   - Click on each extension.
   - Click **Uninstall**.
   - Wait for uninstallation to complete (5-10 minutes per extension).
   - Verify extension removal in the Extensions list.
   - **Important**: Auto-provisioning must be disabled first (Step 11) to prevent automatic reinstallation.

5. **Advanced Removal for Stuck Extensions**
   - If extensions are stuck in **Uninstalling** state:
     - Force restart the VM and retry uninstallation.
     - Use Azure PowerShell/CLI for forced removal if necessary.

6. **Verify Agent Removal**
   - RDP/SSH to your virtual machines.
   - Check that Defender for Endpoint processes are not running:

   **Windows VMs:**

   ```powershell
   Get-Service | Where-Object {$_.Name -like "*Sense*" -or $_.Name -like "*MDE*"}
   Get-Process | Where-Object {$_.Name -like "*MsSense*" -or $_.Name -like "*SenseNdr*"}
   ```

   **Linux VMs:**

   ```bash
   sudo systemctl status mdatp
   ps aux | grep mdatp
   ls /opt/microsoft/mdatp/
   ```

📸 **[View VM Extensions Management Guide](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/overview)**

---

## Step 10: Delete Lab Virtual Machines and Associated Resources

**Note**: This step reverses the VM creation from Step 5 of the deploy guide and ensures complete resource cleanup.

### Why This Step Comes Tenth

Virtual machines should be deleted after removing agents and extensions to ensure clean shutdown and prevent data loss or orphaned processes.

1. **Prepare for VM Deletion**
   - Ensure all agents and extensions have been removed (from Step 9).
   - Backup any important data from VMs (if needed).
   - Document VM configurations for potential future reference.

2. **Delete Lab Virtual Machines**
   - Navigate to Virtual Machines in Azure Portal.
   - Delete the following VMs created during lab deployment:
     - **vm-windows-server**.
     - **vm-linux-db**.
     - **vm-windows-client**.

   **For each VM:**
   - Select the VM.
   - Click **Delete**.
   - **Critical**: Choose to delete associated resources:
     - ✅ **OS disk**.
     - ✅ **Data disks** (if any).
     - ✅ **Network interfaces**.
     - ✅ **Public IP addresses**.
     - ✅ **Network security groups** (if VM-specific).
   - Confirm deletion.
   - Wait for deletion to complete (5-10 minutes per VM).

3. **Clean Up SSH Keys and Secrets**
   - Navigate to **SSH keys** in Azure Portal.
   - Delete SSH key pairs created during lab:
     - **vm-linux-db-key** (if created).
   - Remove any stored credentials or certificates.

4. **Clean Up Orphaned Network Resources**
   - Navigate to **Virtual networks** in Azure Portal.
   - Check for orphaned network resources:
     - Unused public IP addresses.
     - Orphaned network interfaces.
     - Empty network security groups.
     - Unused load balancers.
   - Delete any orphaned resources.

5. **Verify VM Deletion**
   - Confirm all lab VMs are completely removed.
   - Check that no VM-related charges are accumulating.
   - Verify no orphaned disks or network resources remain.

📸 **[View Resource Management Guide](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resources-portal)**

---

## Step 11: Disable Defender for Servers and Auto-Provisioning

**Note**: This step reverses the Defender for Servers configuration from Step 4 and auto-provisioning setup from Step 3 of the deploy guide.

### Why This Step Comes Eleventh

Auto-provisioning and Defender for Servers should be disabled after removing VMs to prevent automatic reinstallation of agents on any remaining or future VMs.

1. **Disable Auto-Provisioning Extensions**
   - Navigate to **Auto provisioning** in Environment settings.
   - Disable the following extensions for modern architecture:
     - **Azure Monitor Agent (AMA)** → Set to **Off** (unless needed for other Azure services).
     - **Vulnerability assessment for machines** → Set to **Off**.
     - **Guest Configuration agent** → Set to **Off**.
   - Click **Save** after each change.

2. **Configure Extension Removal for Future VMs**
   - For each disabled extension, choose removal option:
     - **Remove extensions** (recommended for complete cleanup).
     - This ensures any future VMs won't automatically get agents installed.
   - **Important**: Auto-provisioning must be disabled before removing VM extensions to prevent automatic reinstallation.

3. **Disable Defender for Servers Plan**
   - Navigate to **Environment settings**.
   - Select your subscription.
   - Find **Defender for Servers** plan.
   - Toggle the status to **Off**.
   - Confirm the change.
   - **Cost Impact**: This stops the $15/server/month charges immediately.
   - **Modern Architecture**: This also disables agentless scanning capabilities.

4. **Verify Modern Features Deactivation**
   - Confirm the plan shows **Off** status.
   - Check that **agentless scanning** is disabled.
   - Verify no server protection features are active.
   - **Important**: Agentless scanning provides many security benefits without agents - ensure you understand the security implications of disabling this.

📸 **[View Auto-Provisioning Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/enable-data-collection)**

---

## Step 12: Disable All Remaining Defender for Cloud Plans

**Note**: This step reverses the core Defender for Cloud enablement from Step 2 of the deploy guide.

### Why This Step Comes Twelfth

All Defender for Cloud plans should be disabled after removing VMs and agents to ensure complete service deactivation and stop all billing charges.

1. **Access Environment Settings**
   - In Defender for Cloud, navigate to **Environment settings**.
   - Select your subscription from the hierarchy.
   - Review all currently enabled plans.

2. **Disable All Remaining Defender Plans**
   - For each enabled plan, toggle the status to **Off**:
     - **Foundational CSPM** (if you want to disable free features).
     - **Defender for App Service** (if enabled).
     - **Defender for Storage** (if enabled).
     - **Defender for SQL** (if enabled).
     - **Defender for Containers** (if enabled).
     - **Defender for Key Vault** (if enabled).
     - **Defender for Resource Manager** (if enabled).
     - **Defender for DNS** (if enabled).
   - Click **Save** after disabling each plan.

3. **Verify Complete Plan Deactivation**
   - Confirm all plans show **Off** status.
   - Review the updated monthly cost estimate (should show $0 for paid plans).
   - Allow 5-10 minutes for changes to take effect.

4. **Confirm Cost Optimization**
   - Verify that Defender for Cloud charges will stop.
   - Note the effective date for billing changes.
   - Check that no hidden or legacy plans remain active.

📸 **[View Environment Settings Guide](https://learn.microsoft.com/en-us/azure/defender-for-cloud/enable-enhanced-security)**

---

## Step 13: Clean Up Log Analytics Workspace and Data

**Note**: This step addresses the Log Analytics workspace created for Microsoft Sentinel integration in the advanced configuration section.

### Why This Step Comes Thirteenth

The Log Analytics workspace should be cleaned up after disabling all Defender for Cloud plans to ensure no orphaned data connections and eliminate storage costs.

1. **Identify Associated Workspaces**
   - Navigate to **Environment settings** → **Data collection**.
   - Note the Log Analytics workspace used by Defender for Cloud (e.g., **law-sentinel-security-operations**).
   - Navigate to Log Analytics workspaces in Azure Portal.

2. **Review Workspace Usage**
   - Check if the workspace is used by other services:
     - Azure Monitor.
     - Application Insights.
     - Azure Automation.
     - Other monitoring solutions.

3. **Option A: Delete Workspace (Complete Cleanup)**

   **If workspace is dedicated to Defender for Cloud and Sentinel:**
   - Navigate to Log Analytics workspaces.
   - Select the workspace (e.g., **law-sentinel-security-operations**).
   - Click **Delete**.
   - Confirm deletion.
   - **Important Data Retention Notes**.
     - Workspace enters **soft-delete state** for 14 days, allowing recovery if needed.
     - After 14 days, data is permanently purged and non-recoverable.
     - Workspace name is reserved during soft-delete period.
   - **Cost Impact**: Eliminates all workspace storage and ingestion charges immediately.

4. **Option B: Clean Workspace Data (Selective Cleanup)**

   **If workspace is shared with other services:**
   - Navigate to the workspace → **General** → **Usage and estimated costs**.
   - Go to **Data retention** settings.
   - Reduce retention period to minimum (30 days) to minimize costs.
   - **Advanced Data Cleanup**: For immediate data removal, consider using Azure's data purge APIs for specific tables.
   - **Set Immediate Purge Flag**: For workspaces with 30-day retention, set `immediatePurgeDataOn30Days` to `true` to ensure data is non-recoverable after 30 days.

5. **Best Practice: Data Purging Considerations**
   - **Standard Deletion**: Data remains queryable during retention period but continues to incur storage charges.
   - **Immediate Purge**: For compliance or cost optimization, use PowerShell/CLI to set immediate purge flags.
   - **Table-Specific Cleanup**: Different table types (Azure, Custom, Search results) have different deletion behaviors - plan accordingly.
   - **Backup Important Queries**: Export any important KQL queries or custom analytics before cleanup.

6. **Verify Workspace Cleanup**
   - Confirm workspace deletion or data cleanup is complete.
   - Check that Log Analytics charges are eliminated or reduced.
   - Verify no Defender for Cloud data is being ingested.
   - **Monitor Costs**: Set up cost alerts to track the elimination of Log Analytics charges over the next billing period.

📸 **[View Log Analytics Management Guide](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/manage-cost-storage)**

---

## Step 14: Remove Resource Group and Final Cleanup

**Note**: This step reverses the resource group creation from Step 5 of the deploy guide and ensures complete lab cleanup.

### Why This Step Comes Fourteenth

The resource group cleanup should be performed last to ensure all contained resources are properly removed and no orphaned resources remain in the Azure environment.

1. **Verify Resource Group Contents**
   - Navigate to Resource Groups in Azure Portal.
   - Find **rg-Project-AiSecuritySkillsChallenge** (your lab resource group).
   - Click on the resource group to view contents.
   - Verify the following resources have been removed:
     - All virtual machines.
     - All disks and network interfaces.
     - SSH keys and network security groups.
     - Log Analytics workspace (if deleted in Step 13).

2. **Clean Up Any Remaining Resources**
   - Review any remaining resources in the resource group.
   - For each remaining resource:
     - Determine if it's lab-related.
     - Delete lab-related resources individually.
     - Preserve non-lab resources if needed.

3. **Delete the Resource Group (Complete Cleanup)**

   **If the resource group contains only lab resources:**
   - Click **Delete resource group**.
   - Type the resource group name to confirm: **rg-Project-AiSecuritySkillsChallenge**.
   - Click **Delete**.
   - Wait for deletion to complete (5-15 minutes).
   - **Note**: This removes all contained resources automatically.

4. **Partial Cleanup (If Resource Group Contains Non-Lab Resources)**

   **If the resource group contains other important resources:**
   - Do not delete the entire resource group.
   - Verify all lab-specific resources have been individually removed.
   - Document remaining resources for future reference.

5. **Verify Complete Resource Cleanup**
   - Confirm the resource group is deleted or contains no lab resources.
   - Check Azure billing to ensure no unexpected charges.
   - Verify your subscription is returned to pre-lab state.

📸 **[View Resource Group Management Guide](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)**

---

## Step 15: Verify Complete Removal and Cost Optimization

**Note**: This final step ensures all lab components have been properly removed and costs are optimized.

### Why This Final Verification Is Critical

Complete verification ensures no hidden costs remain and the lab environment is fully reset for future deployments.

1. **Verify Defender for Cloud Deactivation**
   - Navigate to Defender for Cloud overview.
   - Verify secure score shows **Not available** or very low score.
   - Confirm no active recommendations are being generated.
   - Check that no security alerts are being generated.
   - Verify all plans show **Off** status in environment settings.

2. **Verify Resource Cleanup**
   - Navigate to **Resource groups** in Azure Portal.
   - Confirm **rg-Project-AiSecuritySkillsChallenge** is deleted or contains no lab resources.
   - Check **Virtual machines** to ensure all lab VMs are removed.
   - Verify **Log Analytics workspaces** shows **law-sentinel-security-operations** is deleted (if applicable).

3. **Check Current Costs**
   - Navigate to **Cost Management + Billing**.
   - Review current charges for.
     - Microsoft Defender for Cloud (should be $0 for paid plans).
     - Log Analytics data ingestion (should be eliminated or minimal).
     - Virtual machine compute (should be $0).
     - Storage accounts (should be minimal for diagnostic logs only).

4. **Monitor for 24-48 Hours**
   - Defender charges should drop to $0 for paid plans.
   - VM compute charges should drop to $0.
   - Log Analytics ingestion should decrease significantly.
   - Monitor for any unexpected ongoing charges.

5. **Set Up Cost Alerts (Optional)**
   - Create budget alerts for the subscription.
   - Set thresholds to catch any unexpected costs.
   - Configure notifications for cost spikes above expected baseline.

6. **Final Verification Checklist**

   ✅ **Microsoft Sentinel**: Removed or disconnected from Defender for Cloud.

   ✅ **Workbooks and Dashboards**: Custom dashboards deleted, workbooks reset.

   ✅ **File Integrity Monitoring**: Disabled and configuration cleared.

   ✅ **Sample Alerts**: All sample alerts dismissed and generation stopped.

   ✅ **Advanced Threat Protection**: All advanced features disabled.

   ✅ **Email Notifications**: All notification settings cleared.

   ✅ **Security Policies**: All compliance standards reset to default.

   ✅ **Security Recommendations**: Assessment processes stopped.

   ✅ **VM Extensions**: All monitoring agents and extensions removed.

   ✅ **Virtual Machines**: All lab VMs deleted with associated resources.

   ✅ **Auto-Provisioning**: All auto-provisioning disabled.

   ✅ **Defender Plans**: All paid plans disabled.

   ✅ **Log Analytics Workspace**: Deleted or cleaned of Defender for Cloud data.

   ✅ **Resource Group**: Deleted or cleaned of all lab resources.

   ✅ **Cost Optimization**: All unnecessary charges eliminated.

📸 **[View Cost Management Guide](https://learn.microsoft.com/en-us/azure/cost-management-billing/)**

---

## 💡 Enhanced Best Practices for Decommissioning (2025 Edition)

### Understanding Modern Architecture

**Modern Approach (2025)**:

- **Agentless scanning** provides security insights without installing agents.
- **Defender for Endpoint** handles endpoint protection and File Integrity Monitoring.
- **Azure Monitor Agent (AMA)** is used selectively for specific data collection needs.
- **No MMA dependency** - focuses on cloud-native security capabilities.

### Documentation and Tracking

- **Document your architecture**: Note the modern agentless approach being decommissioned.
- **Track deployment method**: Record which steps from the deploy guide you followed.
- **Keep decommissioning records**: Document what was removed for future reference.
- **Note custom configurations**: Maintain inventory of any custom policies, workbooks, or analytics rules.
- **Version control**: Keep track of guide versions used for deployment and decommissioning.

### Gradual vs Complete Decommissioning

**Gradual Approach (Recommended for Production)**:

- Disable plans gradually rather than all at once.
- Monitor for business impact during the process.
- Test critical applications after each phase.
- Allow 24-48 hours between major changes to observe impact.

**Complete Approach (Suitable for Lab Environments)**:

- Follow all 15 steps in sequence for complete removal.
- Suitable when no production workloads depend on Defender for Cloud.
- Provides clean slate for redeployment or alternative approaches.

### Cost Monitoring and Optimization

**Immediate Cost Optimization**:

- Set up budget alerts to track cost reductions in real-time.
- Monitor billing for 30 days to ensure all charges have stopped.
- Set `immediatePurgeDataOn30Days` flag for workspaces to prevent retention charges.
- Use table-specific retention policies to minimize data storage costs.

**Long-term Cost Management**:

- Document cost impact for stakeholders and future planning.
- Consider modern agentless architecture for lower operational overhead.
- Plan for potential redeployment costs if this is temporary decommissioning.

### Security Considerations

**Impact Assessment**:

- Understand that agentless scanning provides significant security value without agents.
- Document security coverage gaps after decommissioning.
- Ensure alternative security measures are in place if needed.
- Plan for redeployment timeline if this is temporary.

**Data Retention and Compliance**:

- Historical security data follows workspace retention policies (14-day soft delete + retention period).
- Exported compliance reports remain available for audit purposes.
- Consider regulatory requirements before purging security logs.
- Microsoft Defender XDR retains endpoint data for up to 6 months.

### Modern Agent Management

**Azure Monitor Agent (AMA) Considerations**:

- AMA may be needed for SQL Server monitoring even after Defender for Cloud decommissioning.
- Check dependencies before removing AMA - it's used by multiple Azure services.
- AMA provides the 500MB free data ingestion benefit for Defender for Servers Plan 2.

## 🚨 Troubleshooting Common Issues

### Agent Removal Problems

**Issue**: VM extensions stuck in **Uninstalling** state.

**Solution**:

- Force restart the VM, then try uninstall again.
- If persistent, use Azure PowerShell/CLI to force removal.
- Focus on Defender for Endpoint and AMA extensions in modern deployments.

**Issue**: Agents automatically reinstall after removal.

**Solution**:

- Ensure auto-provisioning is disabled BEFORE removing agents.
- Check that all Defender plans are disabled.
- Verify no Azure Policy assignments are forcing agent installation.

### Log Analytics Workspace Issues

**Issue**: Cannot delete workspace due to active connections.

**Solution**:

- Check for remaining connected resources (VMs, solutions, automation accounts).
- Remove all connections first before attempting workspace deletion.
- Consider soft-delete approach which allows recovery within 14 days.

**Issue**: Need immediate data purging for compliance.

**Solution**:

- Use PowerShell/CLI with `immediatePurgeDataOn30Days` flag set to `true`.
- Utilize data purge APIs for specific table cleanup.
- Be aware that immediate purge makes data non-recoverable.

### Persistent Billing Issues

**Issue**: Costs continue after disabling plans.

**Solution**:

- Check for remaining enabled plans in child subscriptions or management groups.
- Review billing period timing - charges may appear for 24-48 hours after disabling.
- Verify that agentless scanning is fully disabled (modern feature that continues scanning without agents).

**Issue**: Unexpected Log Analytics charges.

**Solution**:

- Check data retention settings and reduce to minimum (30 days).
- Verify no other Azure services are using the workspace.
- Monitor for residual data ingestion from orphaned connections.

### Modern Architecture Conflicts

**Issue**: Confusion between different agent types.

**Solution**:

- **AMA (Azure Monitor Agent)**: Modern agent for specific data collection - may be needed for other services.
- **Agentless Scanning**: Modern feature that works without agents - managed automatically.
- **Defender for Endpoint**: Modern security agent - different from monitoring agents.

### File Integrity Monitoring Migration

**Issue**: FIM data still being collected after disabling.

**Solution**:

- **AMA-based FIM**: Remove data collection rules (DCR) using PowerShell.
- **Modern FIM**: Automatically managed by Defender for Endpoint - no manual cleanup needed.

---

## 🎯 Lab Reset Complete

**Congratulations!** You have successfully decommissioned Microsoft Defender for Cloud and reset your lab environment to a clean slate. Your Azure environment is now ready for:

- **Redeploying the lab**: Start fresh with any of the deployment guides for additional practice
- **Cost optimization**: No ongoing Defender for Cloud or VM charges
- **Alternative deployments**: Try different approaches (Infrastructure-as-Code vs manual, modular vs complete automation)
- **Advanced scenarios**: Explore more complex Defender for Cloud setups

### Expected Cost Savings

- **Defender for Cloud plans**: $30-45 USD/month → $0
- **Virtual machine compute**: $60-120 USD/month → $0
- **Log Analytics ingestion**: $2.76-5.52 USD/month → Minimal or $0
- **Total monthly savings**: $90-170 USD/month

### Next Steps Based on Your Deployment Method

**If you used Automated Decommissioning:**

- Try the **Manual Azure Portal Guide** (`deploy-defender-for-cloud-azure-portal.md`) for hands-on learning
- Explore the **Complete Automation Guide** for single-command deployment comparison
- Practice with different parameters in the **Modular Infrastructure-as-Code Guide**

**If you used Manual Decommissioning:**

- Try the **Modular Infrastructure-as-Code Guide** (`deploy-defender-for-cloud-modular-iac.md`) for automated approach
- Explore the **Complete Automation Guide** for rapid deployment and learning
- Compare deployment times and complexity between manual vs automated approaches

### Key Features of This Enhanced Guide

This updated decommissioning guide incorporates **dual-method approach** for 2025:

- **Automated Script Method**: Fast, reliable, comprehensive decommissioning for Infrastructure-as-Code deployments
- **Manual Portal Method**: Step-by-step learning approach for manual deployments
- **Method-Specific Guidance**: Clear recommendations based on original deployment approach
- **Modern Architecture Support**: Handles agentless scanning, modern agents, and current Azure features
- **Comprehensive Validation**: Ensures complete cleanup regardless of method used

---

---

## 🔗 Additional Resources

- [Microsoft Defender for Cloud Documentation](https://learn.microsoft.com/en-us/azure/defender-for-cloud/)
- [Azure Policy Management](https://learn.microsoft.com/en-us/azure/governance/policy/)
- [Log Analytics Workspace Management](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/manage-cost-storage)
- [Azure Cost Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/)
- [VM Extension Management](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/overview)

---

## 🤖 AI-Assisted Content Generation

This comprehensive decommissioning guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, leveraging GitHub Copilot's capabilities to ensure accuracy, completeness, and adherence to Microsoft Azure best practices.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Defender for Cloud decommissioning procedures while maintaining technical accuracy and practical applicability.*

---

**Note**: This guide provides a comprehensive foundation for safely decommissioning Microsoft Defender for Cloud. Always verify the latest Microsoft documentation for any changes to the decommissioning process. Consider the security implications carefully before proceeding with a full decommission in production environments.
