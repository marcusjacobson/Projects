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

1. Open PowerShell as Administrator.
2. Navigate to the `scripts` folder of this project.
3. Run the cleanup script:
  
   ```powershell
    .\Cleanup-LabEnvironment.ps1
   ```

4. The script will:
    - Connect to Microsoft Graph.
    - Delete users: Alex Wilber, Bianca Pisani, Christie Cline, David So.
    - Delete groups: Dynamic-Sales-Team, Dynamic-Marketing-Team, Project-Alpha, SAML-App-SelfService-Users.
    - Delete Admin Unit: Paris Branch.
    - Delete CA Policies and Named Locations.
    - Delete App Registrations and Enterprise Apps.
    - Delete Access Packages and Catalogs.

### Task 2: Verify Cleanup (Portal)

Verify that the resources have been removed. If the script encountered errors, manually remove the remaining items.

1. **App Registrations**:
    - Go to **Identity** > **Applications** > **App registrations**.
    - Ensure **Contoso HR Portal** and **Contoso SAML App** are gone.
2. **Enterprise Applications**:
    - Go to **Identity** > **Applications** > **Enterprise applications**.
    - Ensure **Contoso SAML App** is gone.
3. **Conditional Access Policies**:
    - Go to **Protection** > **Conditional Access**.
    - Ensure `CA001`, `CA002`, `CA003`, `CA004`, `CA005` are gone.
4. **Identity Governance**:
    - **Access Packages**: Ensure **Marketing Starter Pack** is gone.
    - **Catalogs**: Ensure **Marketing Resources** is gone.
    - **Access Reviews**: Delete **Review-Project-Alpha** (Manual deletion required).

### Task 3: Tenant-Wide Configuration (Optional Revert)

The following settings were configured at the tenant level. You may choose to keep them for future use or manually revert them if you want a strictly "default" state.

| Lab | Feature | Setting to Revert (If desired) |
| :--- | :--- | :--- |
| **01** | **Company Branding** | Go to **Custom branding** and delete the configuration. |
| **01** | **Tenant Properties** | Go to **User settings** and set "Restrict access to administration portal" to **No**. |
| **01** | **Custom Domain** | Go to **Domain names** and remove `contoso-lab.com` (if added). |
| **05** | **Auth Methods** | Go to **Authentication methods** and disable "Microsoft Authenticator" or "Temporary Access Pass". |
| **08** | **SSPR** | Go to **Password reset** and set "Self service password reset enabled" to **None**. |
| **11** | **App Consent** | Go to **Enterprise applications** > **Consent and permission** and reset to default. |
| **12** | **PIM Settings** | Go to **PIM** > **Microsoft Entra roles** > **Settings** and reset "User Administrator" requirements. |
| **16** | **Diagnostic Settings** | Go to **Diagnostic settings** and delete `Send-to-LogAnalytics`. |

---

## 🔍 Troubleshooting

- **"User not found"**: If you already deleted them manually, the script will skip them (Yellow warning).
- **"Cannot delete Access Package"**: You must delete the **Assignments** (requests) inside the package before you can delete the package itself.

## 🤖 AI-Assisted Content Generation

This cleanup guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, ensuring safe and effective removal of test resources.

*AI tools were used to enhance productivity and ensure comprehensive coverage of environment cleanup procedures while maintaining technical accuracy and reflecting current Azure portal interfaces.*
