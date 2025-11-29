# Lab 04: Hybrid Identity Simulation

**Skill:** Implement and manage hybrid identity
**Estimated Time:** 30 Minutes

---

## 📋 Lab Overview

**Scenario:** Contoso Corp is migrating from on-premises Active Directory to the cloud. They need to synchronize their existing users to Entra ID.

**Note**: Since this is a cloud-only simulation environment, we cannot install the actual Entra Connect Sync agent (which requires a Windows Server). Instead, we will explore the configuration options in the portal and understand the concepts required for the exam.

### 📚 Exam Context: On-Premises Agent Configuration

The SC-300 exam **does** expect you to understand the installation and configuration process of the Entra Connect agent on a Windows Server, even though we cannot simulate it here.

**Key On-Premises Configuration Topics:**

1. **Express vs. Custom Installation**:
    - **Express**: Used for single-forest topologies. Automatically configures Password Hash Sync (PHS).
    - **Custom**: Required for multi-forest, specific attribute filtering, or alternative auth methods (PTA, ADFS).
2. **Filtering Options**:
    - **Domain-based**: Select specific domains to sync.
    - **OU-based**: Select specific Organizational Units (e.g., sync "Users" but not "Admin Accounts").
    - **Attribute-based**: Sync only objects where `cloudFiltered != True`.
3. **Staging Mode**:
    - A critical exam concept. The server imports data from AD and Entra ID but **does not export** changes.
    - Used for: High Availability (Standby server) and testing configuration changes safely.

### 🛠️ Options for Hands-On Practice

If you want to practice the actual installation, you have two options:

1. **Azure VM Method**: Deploy a Windows Server VM in Azure, promote it to a Domain Controller (install AD DS), and then install Entra Connect on it.
2. **Home Lab**: Use a local Hyper-V or VMware setup with a Windows Server ISO.

*For this Masterclass, we focus on the **Cloud Side** configuration which is the primary focus of the "Identity & Access Administrator" role.*

### 🎯 Objectives

- Understand the difference between **Entra Connect Sync** and **Cloud Sync**.
- Explore the **Microsoft Entra Connect** blade in the portal.
- Review **Password Hash Sync (PHS)** vs **Pass-Through Auth (PTA)**.

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Free** (Sync is a core feature) |
| **Role** | **Hybrid Identity Administrator** or **Global Administrator** |

> **💡 Exam Tip:**:
>
> - **Entra Connect Sync**: The robust, legacy tool. Installed on-prem. Supports complex filtering (OUs, Attributes) and device writeback.
> - **Cloud Sync**: The modern, lightweight agent. Managed from the cloud portal. Supports multi-forest sync easily. **Cannot** sync device objects (yet).
> - **PHS**: Syncs a hash of the password hash. Users can sign in even if on-prem AD is down. (Recommended for Disaster Recovery).
> - **PTA**: Validates passwords against on-prem AD in real-time. No password data stored in cloud. Requires highly available agents.

---

## 📝 Lab Steps

### Task 1: Explore Cloud Sync Configuration

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com).
2. Navigate to **Entra ID** > **Entra Connect**.
3. Click **Cloud sync**.
4. Notice the **Agents** tab. In a real scenario, you would download the agent here and install it on a Windows Server.
5. **Exam Concept**: Once an agent is installed, you would create a **Configuration**:
    - **Scope**: Which OUs to sync.
    - **Mapping**: How attributes map (e.g., `mail` -> `EmailAddress`).
    - **Schedule**: How often to sync (default is every 2 minutes for Cloud Sync, 30 mins for Connect Sync).

### Task 2: Review Connect Sync Status

1. Go back to **Entra Connect**.
2. Click **Connect Sync**.
3. Observe the **Health** status. In a cloud-only tenant, this will say "Sync status: Not enabled" or "Last sync: Never".
4. **Exam Concept**: If sync were enabled, this dashboard is where you would check for **Sync Errors** (e.g., Duplicate Attribute errors).

### Task 3: Enable ImmutableID Handling (Optional PowerShell)

One common exam topic is "Hard Matching" users (matching a cloud user to an on-prem user). This relies on the `ImmutableId`.

1. Open PowerShell.
2. Connect to Microsoft Graph.
3. Select a user (e.g., Alex Wilber).

    ```powershell
    Get-MgUser -UserId "alex.wilber@<YOUR_TENANT>.onmicrosoft.com" | Select-Object UserPrincipalName, OnPremisesImmutableId
    ```

4. Notice `OnPremisesImmutableId` is null. If this user were synced from AD, this field would contain the Base64 encoded GUID of the on-prem user.

---

## 🔍 Troubleshooting

- **Why can't I enable sync?**: You need an actual server to install the agent.
- **What is "Staging Mode"?**: A setting in Connect Sync where the server imports data but does **not** export changes to Entra ID. Used for high availability or testing configuration changes before going live.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for SC-300 certification preparation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exam objectives while maintaining technical accuracy.*
