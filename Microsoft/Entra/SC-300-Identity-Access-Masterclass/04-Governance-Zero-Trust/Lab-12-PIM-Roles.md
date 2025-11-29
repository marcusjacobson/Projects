Lab 12: Privileged Identity Management (PIM)

**Skill:** Plan and implement Privileged Identity Management
**Estimated Time:** 60 Minutes

---

## 📋 Lab Overview

**Scenario:** "Standing Access" (permanent admin rights) is a major security risk. Contoso wants to move to a "Just-In-Time" (JIT) model.

1. **Alex Wilber** should be eligible to be a **User Administrator**, but must request it when needed.
2. **Bianca Pisani** needs to approve the request.

### 🎯 Objectives

- Onboard the tenant to PIM.
- Configure a Role Setting (Require Approval).
- Assign an "Eligible" role.
- Activate the role (User experience).

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P2** (Required for PIM) |
| **Role** | **Privileged Role Administrator** or **Global Administrator** |

> **💡 Exam Tip:**
>
> - **Eligible**: The user *can* become an admin, but isn't one right now.
> - **Active**: The user *is* an admin right now (either permanently or temporarily activated).
> - **JIT**: Just-In-Time access.
> - **MFA**: Usually required to activate a role.

---

## 📝 Lab Steps

### Task 1: Configure Role Settings

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com).
2. Navigate to **ID Governance** > **Privileged Identity Management**.
3. Click **Microsoft Entra roles**.
4. Click **Settings**.
5. Search for **User Administrator** and click it.
6. Click **Edit**.
7. **Activation settings**:
    - **Activation maximum duration**: 2 hours.
    - **On activation, require**: **Azure MFA**.
    - **Require approval to activate**: **Yes**.
    - **Select approvers**: Select **Bianca Pisani**.
8. Click **Update**.

### Task 2: Assign Eligible Role

1. Click **Roles** (in the PIM menu).
2. Search for **User Administrator**.
3. Click **+ Add assignments**.
4. **Select member**: **Alex Wilber**.
5. **Membership type**: **Eligible**.
    - *Note: If you choose "Active", it defeats the purpose of JIT, unless you set an expiry.*
6. Click **Assign**.

### Task 3: Activate Role (Alex)

1. Open a new InPrivate window.
2. Sign in to the [Azure Portal](https://portal.azure.com) as **Alex Wilber**.
    - *Note*: We use the Azure Portal here because the tenant restricts access to the Entra Admin Center for standard users. Alex must activate his admin role via the Azure Portal *before* he can access the Entra Admin Center.
3. Search for **Privileged Identity Management** in the top search bar and select it.
4. Click **My roles**.
5. You should see **User Administrator** under "Eligible assignments".
6. Click **Activate**.
7. **Validation**:
    - You might be prompted to perform MFA if you haven't already.
    - Enter a justification: "Need to reset password for user".
    - Click **Activate**.
8. **Result**: "Your request is pending approval".

### Task 4: Approve Request (Bianca)

1. Open another InPrivate window (or use a different browser).
2. Sign in as **Bianca Pisani**.
3. Navigate to **Identity Governance** > **Privileged Identity Management**.
4. Click **Approve requests**.
5. You should see Alex's request.
6. Click **Approve**.
7. Enter justification: "Approved".
8. Click **Confirm**.

### Task 5: Verify Activation (Alex)

1. Switch back to **Alex's** window.
2. Refresh the page.
3. The role status should change to **Active**.
4. *Note: It may take 1-2 minutes and a sign-out/sign-in for the permissions to fully apply in the portal.*

---

## 🔍 Troubleshooting

- **"Approval required" not showing?**: Ensure you edited the settings for the specific role ("User Administrator") and not a different one. Settings are per-role.
- **MFA Loop?**: If Alex hasn't registered for MFA, PIM will force him to register before he can even request activation.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, ensuring alignment with the SC-300 exam objectives and Microsoft Entra best practices.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Privileged Identity Management topics while maintaining technical accuracy and reflecting current Azure portal interfaces.*
