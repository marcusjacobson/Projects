# Lab 07: Lifecycle Governance

This lab automates the "Joiner, Mover, Leaver" (JML) process and ensures access rights are recertified regularly. We will use Access Reviews to prevent "privilege creep" and Lifecycle Workflows to handle employee offboarding securely.

## 🎯 Lab Objectives

- **Access Reviews**: Automate the recertification of Guest users and High-Privilege roles.
- **Lifecycle Workflows**: Create a "Leaver" workflow to automatically disable accounts and remove licenses when an employee leaves.
- **Governance**: Ensure that access is not permanent and is reviewed by the right people.

## 📚 Microsoft Learn & GUI Reference

- **Access Reviews**: [What are access reviews?](https://learn.microsoft.com/en-us/entra/id-governance/access-reviews-overview)
- **Lifecycle Workflows**: [What are lifecycle workflows?](https://learn.microsoft.com/en-us/entra/id-governance/what-are-lifecycle-workflows)

> **💡 GUI Path**: `entra.microsoft.com` > **Identity Governance** > **Access Reviews** | **Lifecycle Workflows**

## 📋 Prerequisites

- Completion of **Lab 01**.
- **Entra ID P2 License** (Required for Access Reviews).
- **Entra ID Governance License** (Required for Lifecycle Workflows).

## ⏱️ Estimated Duration

- **15 Minutes**

## 📝 Lab Steps

### Step 1: Configure Parameters File

Before deploying resources, you must configure the environment parameters.

**Context**: This project uses a centralized JSON configuration file to manage deployment settings. This ensures consistency across all scripts.

1. Navigate to the `infra` directory.
2. Open `module.parameters.json`.
3. Review the default settings.
4. Save the file.

### Step 2: Deploy Access Reviews

We will create two critical reviews: one for external guests and one for Global Administrators.

**Context**:

- **Guest Review**: Guests often finish their project but keep their account. This review asks them (or their sponsor) "Do you still need this?" every 90 days.
- **Admin Review**: "Privilege Creep" happens when admins accumulate rights they no longer need. This review forces a quarterly justification for holding the "Global Admin" role.

1. Open a PowerShell terminal.
2. Navigate to the `scripts` directory.
3. Run the following command:

   ```powershell
   .\Deploy-AccessReviews.ps1 -UseParametersFile
   ```

4. Creates:
    - `AR-Quarterly-Guests`: Quarterly review of all guests.
    - `AR-Global-Admins`: Quarterly review of the Global Admin role.

5. **Verify in Portal**:
   - Navigate to **Identity Governance** > **Access Reviews**.
   - Confirm `AR-Quarterly-Guests` is listed.
   - Verify the status is **Active** or **Scheduled**.

   > **💡 Note**: It may take a few minutes for the Access Review status to change from **NotStarted** or **Initializing** to **Active**. Refresh the page periodically.

### Step 3: Configure Lifecycle Workflows

We will automate the "Leaver" process to ensure immediate security upon termination.

> **⚠️ License Requirement**: This step requires an active **Entra ID Governance** license. If you do not have this license (or a trial), the script will detect this and skip the configuration automatically. You can proceed to the next step.

**Context**: Manual offboarding is slow and risky. If HR terminates an employee on Friday, but IT doesn't disable the account until Monday, that's a 3-day window for data theft.

**Trigger Mechanism**: This workflow is configured to trigger based on the `employeeLeaveDateTime` property of a user account.

- **Production**: This date is usually synced from an HR system.
- **Simulation**: You can manually set this property on a user, or use the **Run on demand** feature to test the workflow immediately without waiting for the date to arrive.

1. Run the following command:

   ```powershell
   .\Configure-LifecycleWorkflows.ps1 -UseParametersFile
   ```

2. Creates a workflow `LCW-RealTime-Leaver` that triggers when a user's `employeeLeaveDateTime` is reached.
3. **Actions**:
    - Disable User Account.
    - Remove from all Groups.
    - Remove all Licenses.

   > **💡 Note**: While account deletion is a common requirement, it typically happens after a retention period (e.g., 30 days). To implement this, you would create a separate workflow triggered X days after the employee leave date.

4. **Verify in Portal**:
   - Navigate to **Identity Governance** > **Lifecycle Workflows** > **Workflows**.
   - Confirm `WF-Leaver-Standard` is listed.
   - Click on the workflow to verify the **Tasks** (Disable account, Remove from groups, Remove licenses).

## ✅ Validation

- **Access Reviews**: Go to **Identity Governance** > **Access Reviews** and verify the two reviews are "Active" or "Scheduled".
- **Lifecycle Workflows**:
  1. Go to **Identity Governance** > **Lifecycle Workflows** > **Workflows**.
  2. Verify `WF-Leaver-Standard` is listed.
  3. **Test the Trigger**: Select the workflow and click **Run on demand**. Select a test user to simulate the offboarding process immediately.

## 🧹 Cleanup

To remove the configurations created in this lab, run the cleanup script. This will delete the Access Reviews and Lifecycle Workflows.

1. Run the following command:

   ```powershell
   .\Remove-LifecycleGovernance.ps1 -UseParametersFile
   ```

## 🚧 Troubleshooting

- **"Workflow creation failed"**: Ensure you have the `LifecycleWorkflows.ReadWrite.All` permission.
- **"Attribute not found"**: The `employeeLeaveDateTime` attribute must be populated on the user object for the workflow to trigger automatically.

## 🎓 Learning Objectives Achieved

- **Automated Hygiene**: You replaced manual "cleanup scripts" with native, audit-ready governance tools.
- **Risk Reduction**: You ensured that high-risk access (Admins, Guests) is temporary and monitored.

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
