# Lab 16: Audit Logs & Diagnostic Settings

**Skill:** Monitor and troubleshoot directory changes
**Estimated Time:** 30 Minutes

---

## 📋 Lab Overview

**Scenario:** A user was deleted, and nobody knows who did it. Or a group membership changed unexpectedly. You need to use the **Audit Logs** to find the "Actor" (Who), the "Target" (What), and the "Activity" (Action).

You will also configure **Diagnostic Settings** to send logs to a Log Analytics Workspace (simulated).

### 🎯 Objectives

-   Search Audit Logs for specific activities (User creation, Group modification).
-   Identify the "Actor" and "Target".
-   Configure Diagnostic Settings (Concept).

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P1** (Required for Log Analytics export) |
| **Role** | **Reports Reader**, **Security Reader**, or **Global Administrator** |

> **💡 Exam Tip:**
> **Sign-in Logs** = *Who signed in?*
> **Audit Logs** = *Who changed what?* (Create, Update, Delete).
> **Provisioning Logs** = *What did the SCIM service do?* (Syncing users to SaaS apps).

---

## 📝 Lab Steps

### Task 1: Search Audit Logs

1.  Navigate to **Identity** > **Monitoring & health** > **Audit logs**.
2.  **Filter**:
    *   **Service**: User Management (Core Directory).
    *   **Activity**: Add user.
    *   **Date**: Last 24 hours.
3.  Click **Apply**.
4.  Find the event where you created "Alex Wilber" (or the bulk users).
5.  Click the entry.
6.  **Activity**: "Add user".
7.  **Initiated by (Actor)**: Your admin account (or "Microsoft.Azure.ActiveDirectory" if done via script/system).
8.  **Target(s)**: Alex Wilber (Object ID).
9.  **Modified Properties**: Shows the initial values set (UPN, Display Name).

### Task 2: Investigate a PIM Activation

1.  Clear the filters.
2.  **Service**: PIM.
3.  Find an event like "Add member to role completed (PIM activation)".
4.  Click it.
5.  Verify that **Alex Wilber** activated the **User Administrator** role.
6.  This is critical for compliance auditing.

### Task 3: Configure Diagnostic Settings (Simulation)

*Note: This requires an Azure Subscription with a Log Analytics Workspace. If you don't have one, just review the steps.*

1.  Navigate to **Identity** > **Monitoring & health** > **Diagnostic settings**.
2.  Click **+ Add diagnostic setting**.
3.  **Name**: `Send-to-LogAnalytics`.
4.  **Logs**:
    *   Check **AuditLogs**.
    *   Check **SignInLogs**.
    *   Check **NonInteractiveUserSignInLogs**.
    *   Check **RiskyUsers**.
    *   Check **UserRiskEvents**.
5.  **Destination details**:
    *   Check **Send to Log Analytics workspace**.
    *   Select Subscription and Workspace.
6.  Click **Save**.

---

## 🔍 Troubleshooting

*   **"No subscription found"**: You need an active Azure Subscription linked to the tenant to create a Log Analytics Workspace. The Developer Program includes one, but you might need to set it up in the Azure Portal (`portal.azure.com`) first.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, ensuring alignment with the SC-300 exam objectives and Microsoft Entra best practices.

*AI tools were used to enhance productivity and ensure comprehensive coverage of audit logging and diagnostic settings topics while maintaining technical accuracy and reflecting current Azure portal interfaces.*
