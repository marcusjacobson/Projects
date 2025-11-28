# Lab 04: RBAC and Privileged Identity Management (PIM)

This lab moves us away from permanent standing access. We will implement Just-In-Time (JIT) access for high-privilege roles and create custom roles for granular delegation.

## 🎯 Lab Objectives

- **Custom Roles**: Create a "Tier 1 Helpdesk" role that can only reset passwords (least privilege).
- **PIM for Roles**: Configure activation requirements (MFA, Justification, Approval) for Global Admin.
- **PIM for Groups**: Onboard the `GRP-SEC-IT` group to PIM, allowing members to elevate to "Exchange Admin" via group membership.

## 📚 Microsoft Learn & GUI Reference

- **Custom Roles**: [Create and assign a custom role](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/custom-create)
- **PIM**: [What is Privileged Identity Management?](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)

> **💡 GUI Path**: `entra.microsoft.com` > **Identity Governance** > **Privileged Identity Management**

## 📋 Prerequisites

- Completion of **Lab 01** and **Lab 02**.
- **Entra ID P2 License** (Required for PIM).

## ⏱️ Estimated Duration

- **25 Minutes**

## 📝 Lab Steps

### Step 1: Configure Parameters File

Before deploying resources, you must configure the environment parameters.

**Context**: This project uses a centralized JSON configuration file to manage deployment settings. This ensures consistency across all scripts.

1. Navigate to the `infra` directory.
2. Open `module.parameters.json`.
3. Review the default settings.
4. Save the file.

### Step 2: Deploy Custom Roles

We will create a role definition that is strictly scoped.

**Context**: Built-in roles like "User Administrator" are often too broad (e.g., they can manage Groups too). Custom roles allow us to follow the "Least Privilege" principle precisely—giving Helpdesk staff exactly the permissions they need (e.g., viewing BitLocker keys), and nothing else.

1. Run the following command:

   ```powershell
   .\Deploy-CustomRoles.ps1 -UseParametersFile
   ```

2. Creates `ROLE-Tier1-Helpdesk`.
3. Permissions: `microsoft.directory/users/standard/read`, `microsoft.directory/bitlockerKeys/key/read`.

#### Validate Custom Roles

1. Go to **Entra Admin Center** > **Identity** > **Roles & admins** > **Roles & admins**.
2. Search for `ROLE-Tier1-Helpdesk`.
3. Click on the role name to open details.
4. Select **Description** or **Permissions** to verify it includes `microsoft.directory/bitlockerKeys/key/read`.

### Step 3: Configure PIM for Roles

We will protect the **Global Administrator** role.

**Context**: "Standing Access" (permanent admin rights) is a major vulnerability. If an admin is phished, the attacker owns the tenant. PIM reduces this window of exposure to zero. Admins must "activate" their role only when needed, and we can enforce MFA or approval for that activation.

1. Run the following command:

   ```powershell
   .\Configure-PIM-Roles.ps1 -UseParametersFile
   ```

2. Sets the PIM policy for Global Admin:
    - **Activation Max Duration**: 4 Hours.
    - **Require MFA**: Yes.
    - **Require Justification**: Yes.
    - **Require Approval**: Yes (Assigns `USR-CISO` as approver).

#### Validate PIM for Roles

1. Go to **Entra Admin Center** > **Identity Governance** > **Privileged Identity Management**.
2. Select **Entra roles** > **Manage** > **Roles**.
3. Search for **Global Administrator**.
4. Click the role, then select **Settings**.
5. Verify the **Activation maximum duration** is **4 hours** and **On activation, require** includes **MFA** and **Justification**.

### Step 4: Configure PIM for Groups

We will use a PIM-enabled group to manage Exchange access.

**Context**: Managing PIM assignments user-by-user is tedious. "PIM for Groups" allows us to assign a role to a group. When a user activates the group membership, they inherit all roles assigned to that group. This scales much better for large teams.

1. Run the following command:

   ```powershell
   .\Configure-PIM-Groups.ps1 -UseParametersFile
   ```

2. Onboards `GRP-PIM-ExchangeAdmins` to PIM.
3. Assigns the **Exchange Administrator** role to this group.
4. Now, `USR-IT-Admin` (a member of the group) is *eligible* to become an Exchange Admin by activating the group membership.

#### Validate PIM for Groups

1. Go to **Entra Admin Center** > **Identity Governance** > **Privileged Identity Management**.
2. Select **Groups** > **Discover groups**.
3. Search for `GRP-PIM-ExchangeAdmins` and ensure it is managed.
4. Select the group > **Assignments**.
5. Verify `USR-IT-Admin` is listed as an **Eligible** member.

## ✅ Validation

- **Custom Role**: Verify `ROLE-Tier1-Helpdesk` exists with BitLocker permissions.
- **PIM Policy**: Confirm Global Admin requires approval and MFA.
- **Group PIM**: Verify `GRP-PIM-ExchangeAdmins` is onboarded and `USR-IT-Admin` is eligible.

## 🧹 Cleanup

To remove the resources created in this lab (Custom Roles, PIM Settings), run the cleanup script:

```powershell
.\Remove-RBAC-PIM.ps1 -UseParametersFile
```

> **⚠️ Important Cleanup Note**: The cleanup script removes the Custom Role and the PIM Group. However, **PIM Policy settings (MFA, Approval, Duration) for the Global Administrator role are NOT reverted** to their default state. This is a safety measure to avoid disrupting critical tenant configurations. If you wish to revert these settings, you must do so manually in the Entra Portal.

## 🚧 Troubleshooting

- **"PIM not enabled"**: You might need to "Consent to PIM" in the portal first if this is a brand new tenant (though usually automatic now).
- **"License required"**: Ensure you have P2 licenses.

## 🎓 Learning Objectives Achieved

- **JIT Access**: You replaced "always on" admin rights with "on demand" access.
- **Granular Control**: You created a role that fits a specific job function, avoiding over-provisioning.

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
