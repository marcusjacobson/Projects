# Lab 14: Entitlement Management (Access Packages)

**Skill:** Plan and implement Entitlement Management
**Estimated Time:** 60 Minutes

---

## 📋 Lab Overview

**Scenario:** New employees need access to a bundle of resources (SharePoint sites, Teams, Apps, Groups) on Day 1. Instead of requesting them one by one, Contoso wants to create a "Marketing Onboarding" package.

### 🎯 Objectives

-   Create a Catalog.
-   Create an Access Package containing a Group and an App.
-   Configure an Approval Policy.
-   Request the package (User experience).

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P2** (Required for Entitlement Management) |
| **Role** | **Identity Governance Administrator** or **Global Administrator** |

> **💡 Exam Tip:**
> **Catalogs**: Containers for resources. You can delegate "Catalog Creator" to business users.
> **Access Package**: The bundle of resources + the policy (who can request, who approves, when it expires).
> **External Users**: You can allow users from *other* tenants to request your access packages (B2B).

---

## 📝 Lab Steps

### Task 1: Create a Catalog

1.  Navigate to **Identity Governance** > **Entitlement management** > **Catalogs**.
2.  Click **+ New catalog**.
3.  **Name**: `Marketing Resources`.
4.  **Enabled**: **Yes**.
5.  Click **Create**.

### Task 2: Add Resources to Catalog

1.  Open the **Marketing Resources** catalog.
2.  Click **Resources** > **+ Add resources**.
3.  **Groups and Teams**: Select `Dynamic-Marketing-Team` (or a static group).
4.  **Applications**: Select `Contoso SAML App`.
5.  Click **Add**.

### Task 3: Create Access Package

1.  Click **Access packages** > **+ New access package**.
2.  **Basics**:
    *   **Name**: `Marketing Starter Pack`.
    *   **Description**: `All tools needed for new marketing hires`.
    *   **Catalog**: `Marketing Resources`.
3.  **Resource roles**:
    *   Select the Group -> Role: **Member**.
    *   Select the App -> Role: **User**.
4.  **Requests**:
    *   **Users who can request access**: **For users in your directory**.
    *   **Select users**: **All members** (or specific users).
    *   **Approval**: **Yes**.
    *   **Approver**: **Manager** (if configured) or **Specific user** (Bianca Pisani).
5.  **Lifecycle**:
    *   **Access package assignments expire**: **365 Days**.
6.  Click **Create**.

### Task 4: Request Access (David)

1.  Open a new InPrivate window.
2.  Sign in as **David So**.
3.  Navigate to `https://myaccess.microsoft.com`.
4.  Click **Access packages**.
5.  You should see **Marketing Starter Pack**.
6.  Click **Request**.
7.  Enter justification.
8.  Click **Submit**.

### Task 5: Approve (Bianca)

1.  Sign in as **Bianca Pisani** (Approver).
2.  Go to `https://myaccess.microsoft.com`.
3.  Click **Approvals**.
4.  Approve David's request.

---

## 🔍 Troubleshooting

*   **"No access packages found"**: Ensure the "Requests" policy in Task 3 targets the user you are testing with.
*   **"Manager not found"**: If you selected "Manager as approver", ensure David So has a Manager attribute set in Entra ID. If not, the request will fail or go to a fallback approver.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, ensuring alignment with the SC-300 exam objectives and Microsoft Entra best practices.

*AI tools were used to enhance productivity and ensure comprehensive coverage of entitlement management topics while maintaining technical accuracy and reflecting current Azure portal interfaces.*
