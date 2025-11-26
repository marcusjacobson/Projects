# Lab 01: Identity Foundation

This lab builds the core identity data layer for the simulation. We will create a realistic user and group hierarchy, enforce strict naming conventions, and implement critical tenant hardening measures.

## 🎯 Lab Objectives

- **Deploy User Hierarchy**: Create C-Suite, IT, HR, Finance, and Marketing users with varying seniority.
- **Enforce Naming Standards**: Use `USR-` and `GRP-` prefixes for all resources.
- **Tenant Hardening**: Restrict guest invitations, device joining, and admin portal access.
- **Emergency Access**: Create two "Break Glass" accounts for tenant recovery.
- **Group-Based Licensing**: Automate license assignment using dynamic or static groups.

## 📚 Microsoft Learn & GUI Reference

- **User Management**: [Add or delete users](https://learn.microsoft.com/en-us/entra/identity/users/users-add)
- **Group Management**: [Create a basic group and add members](https://learn.microsoft.com/en-us/entra/fundamentals/how-to-manage-groups)
- **Tenant Properties**: [Manage tenant properties](https://learn.microsoft.com/en-us/entra/fundamentals/users-default-permissions)
- **Emergency Access Accounts**: [Manage emergency access accounts in Entra ID](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)

> **💡 GUI Path**: `entra.microsoft.com` > **Identity** > **Users** | **Groups** | **Settings**

## 📋 Prerequisites

- Completion of **Lab 00**.
- **Entra ID P2 License** (recommended for Group-Based Licensing).

## ⏱️ Estimated Duration

- **20 Minutes**

## 📝 Lab Steps

### Step 1: Configure Parameters File

Before deploying resources, you must configure the environment parameters.

**Context**: This project uses a centralized JSON configuration file to manage deployment settings like user prefixes, domain names, and license SKUs. This ensures consistency across all scripts.

1. Navigate to the `infra` directory.
2. Open `module.parameters.json`.
3. Review the default settings.
4. (Optional) Customize `userPrefix` or `groupPrefix` if desired.
5. Save the file.

### Step 2: Deploy Identity Hierarchy

This script creates the users and groups that form the "company" structure.

**Context**: We use a standardized naming convention (`USR-`, `GRP-`) to make automation and filtering easier. A structured hierarchy allows us to test RBAC and segregation of duties effectively.

1. Run the following command:

   ```powershell
   .\Deploy-IdentityHierarchy.ps1 -UseParametersFile
   ```

2. This will create ~20 users (e.g., `USR-CEO`, `USR-IT-Admin`) and departmental groups (e.g., `GRP-SEC-IT`).
3. **Note**: Passwords will be randomly generated. To login to a specific user, first use **Reset password** in the user account in Entra to generate a new temporary password then change it on the first login. Securely record the password in a secure tool such as a password manager.

#### Validate Identity Hierarchy

1. Go to **Entra Admin Center** > **Identity** > **Users** > **All users**.
2. Verify users like `USR-CEO` and `USR-IT-Admin` are present.
3. Go to **Identity** > **Groups** > **All groups**.
4. Verify groups like `GRP-SEC-IT` and `GRP-SEC-HR` are created.
5. Select `GRP-SEC-IT` > **Members** and confirm `USR-IT-Admin` is a member.

### Step 3: Configure Tenant Hardening

We will restrict default user permissions to reduce the attack surface.

**Context**: Default Entra ID settings are designed for collaboration, not security. We restrict the admin portal and guest invitations to prevent reconnaissance and unauthorized data sharing.

1. Run the following command:

   ```powershell
   .\Configure-TenantHardening.ps1 -UseParametersFile
   ```

2. This disables "Restrict access to Entra administration portal" and "Users can invite guests".

#### Validate Tenant Hardening

1. Go to **Entra Admin Center** > **Identity** > **Users** > **User settings**.
2. Verify **Users can register applications** is set to **No**.
3. Verify **Users can create security groups** is set to **No**.
4. Go to **Identity** > **External Identities** > **External collaboration settings**.
5. Verify **Guest invite settings** is set to **Only users assigned to specific admin roles can invite guest users**.

### Step 4: Deploy Break Glass Accounts

Create two highly privileged accounts that are *excluded* from standard policies (to be configured in Lab 06).

**Context**: Before we lock down the tenant with Conditional Access (Lab 06), we must ensure we have a "backdoor" that is monitored but never blocked. These accounts prevent us from accidentally locking ourselves out.

1. Run the following command:

   ```powershell
   .\Deploy-BreakGlassAccounts.ps1 -UseParametersFile
   ```

2. These accounts will be assigned the **Global Administrator** role permanently.
3. **Important**: The script generates **random, complex passwords** for each account and displays them in the terminal.

> **⚠️ Security Warning**:
>
> - **Immediately save these passwords** in a secure location (e.g., a password manager or a physical safe).
> - If you lose these passwords, you must reset them via the Entra Admin Center immediately.
> - As a best practice, verify you can log in with these accounts now, then sign out.

#### Validate Break Glass Accounts

1. Go to **Entra Admin Center** > **Identity** > **Users** > **All users**.
2. Search for `BREAK-GLASS`.
3. Select `USR-BREAK-GLASS-01` > **Assigned roles**.
4. Confirm **Global Administrator** is listed.

### Step 5: Configure Group-Based Licensing

Automate the assignment of licenses to ensure all simulated users have the necessary features.

**Context**: Assigning licenses manually is error-prone. Group-based licensing ensures that as soon as a user is added to the "Employees" group, they automatically get the licenses they need to be productive and secure.

1. Run the following command:

   ```powershell
   .\Configure-GroupBasedLicensing.ps1 -UseParametersFile
   ```

2. The script will use the **SkuId** defined in your parameters file (or prompt if missing).

#### Validate Group-Based Licensing

1. Go to **Entra Admin Center** > **Identity** > **Groups** > **All groups**.
2. Search for `GRP-SEC-All-Licensed-Users`.
3. Select the group > **Licenses**.
4. Verify the **Microsoft Entra ID P2** (or similar) license is assigned and the status is **Active**.

> **💡 Note**: If the status shows as **Queued**, this is normal. Group-based licensing processing can take a few minutes. Refresh the page periodically until the status updates to **Active**.

## ✅ Validation

- **Users**: Verify users like `USR-CEO` exist in the portal.
- **Groups**: Verify groups like `GRP-SEC-IT` exist and have members.
- **Hardening**: Try to access the Entra portal as a standard user (if you can log in as one).
- **Break Glass**: Confirm `ADM-BG-01` exists and is a Global Admin.

## 🚧 Troubleshooting

- **"Domain not found"**: The scripts use your default domain (`.onmicrosoft.com`). Ensure this is valid.
- **"License not found"**: Use `Get-MgSubscribedSku` to find the correct SkuId for your tenant.

## 🎓 Learning Objectives Achieved

- **Structured Identity**: You moved away from ad-hoc user creation to a planned, script-based hierarchy.
- **Security First**: You implemented "Break Glass" accounts *before* applying restrictive policies.
- **Operational Efficiency**: You used group-based licensing to manage entitlements at scale.

## 🧹 Cleanup

To remove the resources created in this lab (Users, Groups, Break Glass Accounts), run the cleanup script:

```powershell
.\Remove-IdentityFoundation.ps1
```

> **⚠️ Important Note**: The cleanup script **does not revert** the Tenant Hardening settings configured in Step 3 (e.g., restricting app creation, group creation, and guest invites). These are considered security best practices and are typically left in place. If you wish to revert them, you must do so manually in the Entra Admin Center.

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
