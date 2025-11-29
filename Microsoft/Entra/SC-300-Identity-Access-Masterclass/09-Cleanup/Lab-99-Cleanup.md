# Lab 99: Environment Cleanup

**Skill:** Manage environment lifecycle
**Estimated Time:** 15 Minutes

---

## 📋 Lab Overview

**Scenario:** You have completed the SC-300 Masterclass. To avoid cluttering your tenant (or to prepare for a fresh run), you need to remove the resources created during these labs.

### 🎯 Objectives

-   Remove test users (Alex, Bianca, etc.).
-   Remove test groups (Dynamic-Sales-Team, etc.).
-   Remove Administrative Units.
-   Disable PIM assignments (Optional).

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **Role** | **Global Administrator** |

---

## 📝 Lab Steps

### Task 1: Run the Cleanup Script

We have provided a PowerShell script to automate the removal of the core objects.

1.  Open PowerShell as Administrator.
2.  Navigate to the `scripts` folder of this project.
3.  Run the cleanup script:
    ```powershell
    .\Cleanup-LabEnvironment.ps1
    ```
4.  The script will:
    *   Connect to Microsoft Graph.
    *   Delete users: Alex Wilber, Bianca Pisani, Christie Cline, David So.
    *   Delete groups: Dynamic-Sales-Team, Dynamic-Marketing-Team, Project-Alpha.
    *   Delete Admin Unit: Paris Branch.

### Task 2: Manual Cleanup (Portal)

Some items are safer to remove manually or cannot be easily removed via script without complex dependencies.

1.  **App Registrations**:
    *   Go to **Identity** > **Applications** > **App registrations**.
    *   Delete **Contoso HR Portal**.
2.  **Enterprise Applications**:
    *   Go to **Identity** > **Applications** > **Enterprise applications**.
    *   Delete **Contoso SAML App**.
3.  **Conditional Access Policies**:
    *   Go to **Protection** > **Conditional Access**.
    *   Delete `CA001`, `CA002`, `CA003`.
4.  **Identity Governance**:
    *   **Access Packages**: Delete **Marketing Starter Pack**.
    *   **Catalogs**: Delete **Marketing Resources**.
    *   **Access Reviews**: Delete **Review-Project-Alpha**.

---

## 🔍 Troubleshooting

*   **"User not found"**: If you already deleted them manually, the script will skip them (Yellow warning).
*   **"Cannot delete Access Package"**: You must delete the **Assignments** (requests) inside the package before you can delete the package itself.

## 🤖 AI-Assisted Content Generation

This cleanup guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, ensuring safe and effective removal of test resources.

*AI tools were used to enhance productivity and ensure comprehensive coverage of environment cleanup procedures while maintaining technical accuracy and reflecting current Azure portal interfaces.*
