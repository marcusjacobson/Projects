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

> **💡 GUI Path**: `entra.microsoft.com` > **Users** | **Groups** | **Settings**

## 📋 Prerequisites

- Completion of **Lab 00**.
- **Entra ID P2 License** (recommended for Group-Based Licensing).

## ⏱️ Estimated Duration

- **20 Minutes**

## 📝 Lab Steps

### Step 1: Deploy Identity Hierarchy

This script creates the users and groups that form the "company" structure.

**Context**: We use a standardized naming convention (`USR-`, `GRP-`) to make automation and filtering easier. A structured hierarchy allows us to test RBAC and segregation of duties effectively.

1. Run `Deploy-IdentityHierarchy.ps1`.
2. This will create ~20 users (e.g., `USR-CEO`, `USR-IT-Admin`) and departmental groups (e.g., `GRP-SEC-IT`).
3. **Note**: Passwords will be generated and output to the console.

### Step 2: Configure Tenant Hardening

We will restrict default user permissions to reduce the attack surface.

**Context**: Default Entra ID settings are designed for collaboration, not security. We restrict the admin portal and guest invitations to prevent reconnaissance and unauthorized data sharing.

1. Run `Configure-TenantHardening.ps1`.
2. This disables "Restrict access to Entra administration portal" and "Users can invite guests".

### Step 3: Deploy Break Glass Accounts

Create two highly privileged accounts that are *excluded* from standard policies (to be configured in Lab 06).

**Context**: Before we lock down the tenant with Conditional Access (Lab 06), we must ensure we have a "backdoor" that is monitored but never blocked. These accounts prevent us from accidentally locking ourselves out.

1. Run `Deploy-BreakGlassAccounts.ps1`.
2. These accounts will be assigned the **Global Administrator** role permanently.

### Step 4: Configure Group-Based Licensing

Automate the assignment of licenses to ensure all simulated users have the necessary features.

**Context**: Assigning licenses manually is error-prone. Group-based licensing ensures that as soon as a user is added to the "Employees" group, they automatically get the licenses they need to be productive and secure.

1. Run `Configure-GroupBasedLicensing.ps1`.
2. You will need to provide the **SkuId** of your license (e.g., Entra ID P2). The script will help you find it.

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

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
