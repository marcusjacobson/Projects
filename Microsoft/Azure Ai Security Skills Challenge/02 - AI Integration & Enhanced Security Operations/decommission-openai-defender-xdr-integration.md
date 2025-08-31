# Decommission Azure OpenAI + Defender XDR Integration

This guide provides step-by-step instructions for safely decommissioning the Azure OpenAI + Defender XDR Logic Apps integration deployed through the Azure Portal. Follow these steps to completely remove all components while ensuring no security vulnerabilities or orphaned resources remain.

## 🎯 What This Guide Covers

This decommission process removes all components created during the deployment:

- **Logic App workflow** and associated execution history.
- **App registration** and service principal with security permissions.
- **Client secrets** and authentication credentials.
- **API connections** to Azure OpenAI and Microsoft Graph.
- **Azure Table Storage connection** for duplicate prevention tracking.
- **AI processing table** (`aiProcessed`) and stored tracking data.
- **Parameters** and configuration data.
- **Log Analytics data** (optional cleanup).

### Components to Decommission

| Component | Resource Type | Security Impact | Data Impact |
|-----------|---------------|-----------------|-------------|
| **Logic App** | `Microsoft.Logic/workflows` | Stops automated incident processing | Retains execution history unless deleted |
| **App Registration** | Azure AD Application | Removes Graph API access permissions | No data stored |
| **Client Secret** | Azure AD Secret | Invalidates authentication | No data stored |
| **OpenAI Connection** | API Connection | Removes AI model access | No data stored |
| **Table Storage Connection** | API Connection | Removes duplicate prevention access | No data stored |
| **AI Processing Table** | Azure Table (`aiProcessed`) | Removes tracking data | Contains processed alert IDs |
| **Parameters** | Logic App Configuration | Contains tenant/client IDs | Metadata only |

---

## 🚨 Pre-Decommission Checklist

Before beginning the decommission process, complete these preparatory steps:

### 1. Document Current Configuration

#### Record the following information for audit purposes

- **Logic App Name**: `la-defender-xdr-ai-{uniqueID}`.
- **Resource Group**: `rg-aisec-defender-{environmentName}`.
- **App Registration Name**: `LogicApp-DefenderXDRIntegration`.
- **Application (Client) ID**: Found in app registration overview.
- **Last Run Date**: Check Logic App run history.
- **Total Executions**: Review Logic App metrics.

### 2. Verify Integration Status

1. **Check Active Runs**:
   - Navigate to your Logic App in the Azure Portal.
   - Go to **Overview** → **Runs history**.
   - Ensure no runs are currently **In progress** or **Waiting**.
   - If active runs exist, wait for completion or cancel manually.

2. **Review Recent Activity**:
   - Check the last 24 hours of execution history.
   - Verify no critical security incidents are being processed.
   - Ensure SOC team is aware of automation removal.

### 3. Backup Configuration (Optional)

#### For potential future redeployment

1. **Export Logic App Definition**:
   - In Logic App designer, click **Export** → **Template**.
   - Save the ARM template and parameters file locally.
   - Record OpenAI connection details for recreation.

2. **Document Custom Settings**:
   - AI prompt configurations and system messages.
   - Recurrence intervals and timing settings.
   - Any custom OData filters or query modifications.

---

## Step 1: Disable Logic App Automation

### Stop Automated Execution

1. **Navigate to Logic App**:
   - In the **Azure Portal**, go to your Logic App resource.
   - Click on **Overview** in the left navigation menu.

2. **Disable the Logic App**:
   - At the top of the Overview page, click **Disable**.
   - Confirm the action when prompted.
   - Verify the status shows **Disabled** in the overview.

> **⚠️ Immediate Effect**: Disabling the Logic App immediately stops all future automated executions. The recurrence trigger will no longer fire, and no new incident processing will occur.

### Monitor Final Execution

1. **Check for Running Instances**:
   - Go to **Runs history** in the left navigation.
   - Look for any runs with **Running** or **Waiting** status.
   - Wait for all active runs to complete (typically 2-5 minutes).

2. **Review Final Status**:
   - Verify the last run completed successfully or with expected status.
   - Note any error conditions for troubleshooting purposes.
   - Document final execution timestamp for audit records.

---

## Step 2: Delete Logic App and Associated Resources

### Remove Logic App Workflow

1. **Navigate to Logic App Resource**:
   - In the **Azure Portal**, locate your Logic App.
   - Click on the Logic App name to open the resource.

2. **Delete the Logic App**:
   - In the **Overview** section, click **Delete** at the top of the page.
   - **Type the Logic App name** to confirm deletion.
   - Click **Delete** to permanently remove the resource.

> **🔄 Deletion Timeline**: Logic App deletion is immediate, but backend cleanup may take 5-10 minutes. All execution history, triggers, and actions are permanently removed.

### Clean Up API Connections

Logic Apps automatically creates API connections that should be cleaned up:

1. **Navigate to API Connections**:
   - In the **Azure Portal**, search for **API Connections**.
   - Filter by the same resource group as your Logic App.

2. **Identify Related Connections**:
   - Look for connections with names like:
     - `azureopenai-1` or similar OpenAI connections.
     - Any connections created specifically for this Logic App.

3. **Delete OpenAI API Connection**:
   - Click on the OpenAI connection resource.
   - Click **Delete** at the top of the Overview page.
   - Confirm deletion when prompted.

4. **Delete Table Storage Connection**:
   - Look for Azure Table Storage connection (typically named `azuretables` or similar).
   - Click on the Table Storage connection resource.
   - Click **Delete** at the top of the Overview page.
   - Confirm deletion when prompted.

> **💡 Connection Cleanup**: Removing API connections prevents any potential unauthorized access and cleans up orphaned authentication references.

---

## Step 2.1: Clean Up AI Processing Table Data

### Remove Duplicate Prevention Data

The Logic App created an `aiProcessed` table in your Week 2 storage account for duplicate prevention. Clean up this data:

1. **Navigate to Storage Account**:
   - In the **Azure Portal**, go to your Week 2 storage account.
   - The storage account follows pattern `staiaisec######` (where ###### is your unique identifier).

2. **Access Table Storage**:
   - In the storage account, go to **Data storage** → **Tables**.
   - Locate the `aiProcessed` table.

3. **Delete Table Data** (Option 1 - Recommended):
   - Click on the `aiProcessed` table.
   - Click **Delete table** at the top of the page.
   - Type the table name to confirm deletion.
   - Click **Delete** to permanently remove the table and all tracking data.

4. **Clear Table Data** (Option 2 - Keep Table Structure):
   - Click on the `aiProcessed` table.
   - Select all entries (use **Select all** if available).
   - Click **Delete** to remove entries while keeping the table structure.

> **📊 Data Impact**: The `aiProcessed` table contains only alert IDs and processing timestamps. Deleting this data removes duplicate prevention tracking but has no security impact on your alerts or incidents.

> **💰 Cost Cleanup**: Removing the table eliminates ongoing storage costs (~$0.05/month), though this is negligible for most budgets.

---

## Step 3: Remove App Registration and Permissions

### Delete Client Secret

1. **Navigate to App Registration**:
   - In the **Azure Portal**, go to **Azure Active Directory** → **App registrations**.
   - Search for **`LogicApp-DefenderXDRIntegration`**.
   - Click on the app registration to open it.

2. **Remove Client Secret**:
   - Go to **Certificates & secrets** in the left navigation.
   - Under **Client secrets**, find the secret created for this Logic App.
   - Click the **Delete** icon (trash can) next to the secret.
   - Confirm deletion when prompted.

> **🔒 Security Impact**: Deleting the client secret immediately invalidates authentication for any remaining components.

### Remove API Permissions

1. **Review Current Permissions**:
   - In the app registration, go to **API permissions**.
   - Document the current permissions for audit purposes:
     - `SecurityIncident.ReadWrite.All`.
     - `SecurityAlert.ReadWrite.All`.
     - `SecurityEvents.Read.All`.

2. **Remove Microsoft Graph Permissions**:
   - For each permission listed above, click the **...** menu.
   - Select **Remove permission**.
   - Confirm removal when prompted.

3. **Revoke Admin Consent**:
   - After removing permissions, click **Grant admin consent**.
   - Select **No, remove other granted permissions** if available.
   - Click **Yes** to confirm.
   - This ensures no residual permissions remain active.

### Delete App Registration

1. **Delete the Application**:
   - Still in the app registration overview page.
   - Click **Delete** at the top of the page.
   - Select **I understand the implications of deleting this app registration.**.
   - Click **Delete** at the bottom of the page to permanently remove the app registration.

2. **Verify Removal**:
   - Return to **App registrations** list.
   - Confirm `LogicApp-DefenderXDRIntegration` no longer appears.
   - Check **Deleted applications** tab if you need to recover within 30 days.

> **🚨 Permanent Removal**: App registration deletion is permanent after 30 days. During this period, it can be restored from **Deleted applications** if needed.

---

## Step 4: Verify Complete Decommission

### Final Verification

1. **Check Resource Group**:
   - Navigate to the resource group containing your Logic App.
   - Verify no Logic App resources remain.
   - Confirm API connections are removed.

2. **Validate Access Revocation**:
   - Confirm Defender XDR incidents no longer receive AI comments.
   - Ensure security team is aware of automation removal.

---

## ✅ Decommission Verification Checklist

Complete this checklist to verify successful decommission:

- [ ] **Logic App Status**: Disabled and deleted from Azure Portal
- [ ] **App Registration**: Completely removed from Azure AD
- [ ] **Client Secret**: Deleted and invalidated
- [ ] **API Permissions**: Removed and consent revoked
- [ ] **API Connections**: OpenAI connection deleted
- [ ] **Table Storage Connection**: Azure Table Storage connection deleted
- [ ] **AI Processing Table**: `aiProcessed` table deleted or cleared from storage account
- [ ] **Resource Group**: No orphaned resources remain
- [ ] **SOC Notification**: Security team aware of automation removal
- [ ] **Documentation**: Configuration backed up if needed for future use

---

## 🔄 Redeployment Considerations

### If you need to redeploy this integration in the future

#### Required Recreation Steps

1. **New App Registration**: Create fresh application with required permissions.
2. **Logic App Rebuild**: Deploy new Logic App from template or manual configuration.
3. **Connection Recreation**: Establish new API connections to Azure OpenAI and Table Storage.
4. **Table Setup**: Recreate `aiProcessed` table in storage account for duplicate prevention.

> **💡 Emergency Recovery**: Within 30 days, deleted app registrations can be restored from **Azure AD** → **App registrations** → **Deleted applications**.

### Preserved Components

- **Azure OpenAI Service**: Model deployments and configurations remain unchanged
- **Storage Account**: The Week 2 storage account remains available for other uses (only the `aiProcessed` table is affected)
- **Defender XDR Configuration**: Security policies and settings unaffected
- **Historical AI Comments**: Previous analysis comments remain in alerts
- **Log Analytics Workspace**: Monitoring infrastructure can be reused

---

## 🚨 Security Considerations

### Post-Decommission Security Review

1. **Access Audit**: Verify no other applications use the deleted service principal.
2. **Permission Review**: Ensure no duplicate permissions exist on other app registrations.
3. **Compliance Impact**: Document automation removal for security compliance reporting.

---

## 📞 Support and Troubleshooting

### Common Decommission Issues

| Issue | Cause | Resolution |
|-------|-------|------------|
| **Logic App won't delete** | Active runs in progress | Wait for completion or cancel manually |
| **App registration protected** | Directory-level protection enabled | Remove protection before deletion |
| **API connections remain** | Automatic cleanup failed | Manual deletion of connection resources |
| **Table Storage access denied** | Insufficient permissions | Verify storage account access rights |
| **Permissions still active** | Consent not properly revoked | Re-check API permissions and revoke consent |

### Microsoft Support

#### For assistance with decommission issues

- **Azure Support**: For Logic App and resource deletion problems.
- **Azure AD Support**: For app registration and permission issues.
- **Microsoft Graph Support**: For API access and consent complications.

---

## 📋 Decommission Summary

### Upon completion of this guide, you will have

✅ **Stopped all automated processing** of Defender XDR incidents  
✅ **Removed security permissions** that allowed Graph API access  
✅ **Deleted authentication credentials** preventing unauthorized access  
✅ **Cleaned up Azure resources** to prevent ongoing charges  
✅ **Maintained audit trail** for compliance and governance  
✅ **Preserved historical data** while preventing new automated actions

**The decommission process is complete and secure.** Your Azure environment is clean, and no automated incident processing will occur until new automation is deliberately deployed.
