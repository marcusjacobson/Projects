# Lab 00: Prerequisites and Monitoring

This lab establishes the foundational monitoring and connectivity required for the entire simulation. Before creating any identity resources, we must ensure that all actions are logged and auditable.

## 🎯 Lab Objectives

- **Validate Connectivity**: Ensure the Microsoft Graph PowerShell SDK is installed and can connect to the tenant.
- **Deploy Monitoring Infrastructure**: Create a Log Analytics Workspace to store audit logs.
- **Configure Diagnostic Settings**: Route Entra ID Audit and Sign-in logs to the workspace.
- **Set Retention Policy**: Enforce a 90-day retention period for security compliance.

## 📚 Microsoft Learn & GUI Reference

- **Connect to Microsoft Graph PowerShell**: [Get started with the Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/get-started)
- **Integrate Entra ID with Azure Monitor**: [Stream logs to an event hub or external storage](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/howto-stream-logs-to-event-hub)
- **Diagnostic Settings**: [Diagnostic settings in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings)

> **💡 GUI Path**: `entra.microsoft.com` > **Monitoring & health** > **Diagnostic settings**

## 📋 Prerequisites & Least Privilege Roles

While a **Global Administrator** account ensures the smoothest experience, this project can be completed using a Least Privilege approach. Below are the specific roles required for each module.

### Required for Lab 00 (This Lab)

- **Azure Subscription**: **Contributor** or **Owner** (to create Resource Group & Log Analytics Workspace).
- **Entra ID**: **Security Administrator** (to configure Diagnostic Settings).

### Role Requirements by Module

| Lab | Focus | Least Privilege Role(s) |
| :--- | :--- | :--- |
| **00** | Monitoring Setup | **Security Administrator** + **Azure Contributor** |
| **01** | Identity Foundation | **User Admin** + **Groups Admin** (GA required for Tenant Hardening) |
| **02** | Delegated Admin | **Privileged Role Administrator** |
| **03** | App Integration | **Cloud Application Administrator** |
| **04** | RBAC & PIM | **Privileged Role Administrator** |
| **05** | Entitlement Mgmt | **Identity Governance Administrator** |
| **06** | Identity Security | **Conditional Access Admin** + **Auth Policy Admin** |
| **07** | Lifecycle Gov | **Lifecycle Workflows Administrator** |

> **💡 Recommendation**: For a simulation environment, using a **Global Administrator** account avoids permission friction, especially for Lab 01 (Tenant Hardening) and Lab 09 (Cleanup).

- **PowerShell 7+** recommended.

## ⏱️ Estimated Duration

- **15 Minutes**

## 📝 Lab Steps

### Step 1: Connect to Microsoft Graph

We will use a reusable connection script that requests the necessary scopes for the entire project.

**Context**: The Microsoft Graph PowerShell SDK uses OAuth 2.0. This script handles the authentication flow and ensures you have the correct permissions (Scopes) like `User.ReadWrite.All` and `Policy.Read.All` before proceeding.

1. Open a PowerShell terminal.
2. Navigate to the `scripts` directory.
3. Run the following command:

```powershell
 .\Connect-EntraGraph.ps1
```

### Step 2: Configure Parameters File

Before deploying resources, you must configure the environment parameters.

**Context**: This project uses a centralized JSON configuration file to manage deployment settings like Subscription ID, Resource Group names, and locations. This ensures consistency across all scripts.

1. Navigate to the `infra` directory.
2. Open `module.parameters.json`.
3. Update the `subscriptionId` with your Azure Subscription ID.
4. (Optional) Customize `resourceGroupName`, `location`, or `workspaceName` if desired.
5. Save the file.

### Step 3: Deploy Log Analytics Workspace

This script creates a Resource Group and a Log Analytics Workspace in your Azure subscription.

**Context**: Entra ID stores audit logs for only 30 days (P2 license). To maintain a long-term security audit trail (e.g., for forensic analysis of a breach that happened 3 months ago), we must export these logs to an external storage solution like Log Analytics.

1. Run the following command:

```powershell
.\Deploy-LogAnalytics.ps1 -UseParametersFile
```

2. The script will automatically load your configuration from `module.parameters.json`.
3. Note the **Workspace ID** output for the next step.

### Step 4: Configure Diagnostic Settings

Now we will tell Entra ID to send its logs to the workspace we just created.

**Context**: This creates the "pipeline" between Entra ID and Azure Monitor. We are specifically targeting `AuditLogs` (who did what) and `SignInLogs` (who logged in where) to ensure full visibility into identity operations.

1. Run `Configure-DiagnosticSettings.ps1` with the parameters file switch:

```powershell
.\Configure-DiagnosticSettings.ps1 -UseParametersFile
```

2. The script will **automatically resolve** the Workspace ID using the configuration in `module.parameters.json`.
   - *Note: If you are not using the parameters file, you must manually provide the ID using the `-WorkspaceId` parameter.*
3. This will enable streaming for `AuditLogs`, `SignInLogs`, `NonInteractiveUserSignInLogs`, and `ServicePrincipalSignInLogs`.

### Step 5: Verify Configuration in Portal

Verify the integration using the modern Microsoft Entra admin center.

**Context**: It is critical to visually confirm that the diagnostic settings are active and routing the correct log categories.

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com/).
2. Navigate to **Identity** > **Monitoring & health** > **Diagnostic settings**.
3. Locate the setting named `Entra-Simulation-Diagnostics`.
4. Click **Edit setting** and verify that:
   - **AuditLogs** and **SignInLogs** are selected.
   - The **Destination details** point to your Log Analytics workspace.

### Step 6: Validate Prerequisites

Run the validation script to ensure everything is set up correctly before moving to Lab 01.

**Context**: This script performs a "readiness check" to prevent failures in later labs. It verifies that the SDK is loaded, the workspace is reachable, and the diagnostic settings are active.

Run the following script:

```powershell
.\Validate-Prerequisites.ps1 -UseParametersFile
```

## ✅ Validation

- **Log Analytics**: Verify the workspace exists in the Azure Portal.
- **Diagnostic Settings**: In Entra Admin Center, check **Monitoring & health** > **Diagnostic settings** to see the new configuration.
- **Retention**: Confirm the workspace retention is set to 90 days.

## 🚧 Troubleshooting

- **"Subscription not found"**: Ensure your account has Owner/Contributor permissions on the Azure Subscription.
- **"Diagnostic Settings failed"**: This requires the `Monitor.Config` permission. Ensure you have the **Security Administrator** role.

## 🎓 Learning Objectives Achieved

- **Audit Readiness**: You have ensured that every subsequent action in this project (user creation, role assignment) will be captured in a queryable log store.
- **Infrastructure as Code**: You deployed Azure monitoring resources using PowerShell.

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
