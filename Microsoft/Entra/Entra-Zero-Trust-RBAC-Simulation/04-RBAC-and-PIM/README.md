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

### Step 1: Deploy Custom Roles

We will create a role definition that is strictly scoped.

**Context**: Built-in roles like "User Administrator" are often too broad (e.g., they can manage Groups too). Custom roles allow us to follow the "Least Privilege" principle precisely—giving Helpdesk staff exactly the permissions they need to reset passwords, and nothing else.

1. Run `Deploy-CustomRoles.ps1`.
2. Creates `ROLE-Tier1-Helpdesk`.
3. Permissions: `microsoft.directory/users/password/update`, `microsoft.directory/users/invalidateAllRefreshTokens`.

### Step 2: Configure PIM for Roles

We will protect the **Global Administrator** role.

**Context**: "Standing Access" (permanent admin rights) is a major vulnerability. If an admin is phished, the attacker owns the tenant. PIM reduces this window of exposure to zero. Admins must "activate" their role only when needed, and we can enforce MFA or approval for that activation.

1. Run `Configure-PIM-Roles.ps1`.
2. Sets the PIM policy for Global Admin:
    - **Activation Max Duration**: 4 Hours.
    - **Require MFA**: Yes.
    - **Require Justification**: Yes.
    - **Require Approval**: Yes (Assigns `USR-CISO` as approver).

### Step 3: Configure PIM for Groups

We will use a PIM-enabled group to manage Exchange access.

**Context**: Managing PIM assignments user-by-user is tedious. "PIM for Groups" allows us to assign a role to a group. When a user activates the group membership, they inherit all roles assigned to that group. This scales much better for large teams.

1. Run `Configure-PIM-Groups.ps1`.
2. Onboards `GRP-SEC-IT` to PIM.
3. Assigns the **Exchange Administrator** role to this group.
4. Now, `USR-IT-Admin` (a member of the group) is *eligible* to become an Exchange Admin by activating the group membership.

## ✅ Validation

- **Custom Role**: Check **Roles & admins** for `ROLE-Tier1-Helpdesk`.
- **PIM**: Go to **PIM** > **Entra roles** > **Settings** > **Global Administrator** to see the new policy.
- **Group PIM**: Go to **PIM** > **Groups** and verify `GRP-SEC-IT` is managed.

## 🚧 Troubleshooting

- **"PIM not enabled"**: You might need to "Consent to PIM" in the portal first if this is a brand new tenant (though usually automatic now).
- **"License required"**: Ensure you have P2 licenses.

## 🎓 Learning Objectives Achieved

- **JIT Access**: You replaced "always on" admin rights with "on demand" access.
- **Granular Control**: You created a role that fits a specific job function, avoiding over-provisioning.

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
