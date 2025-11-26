# Lab 02: Delegated Administration

This lab implements the "Least Privilege" principle of Zero Trust by segmenting the tenant into administrative boundaries. We will use Administrative Units (AUs) to delegate management of specific departments without granting tenant-wide permissions.

## 🎯 Lab Objectives

- **Create Administrative Units**: Define boundaries for IT, HR, Finance, and Marketing.
- **Populate AUs**: Assign the users and groups created in Lab 01 to their respective AUs.
- **Restricted Management AUs**: Create a highly secure AU for Break Glass accounts that prevents standard Global Admins from modifying them.

## 📚 Microsoft Learn & GUI Reference

- **Administrative Units**: [Administrative units in Entra ID](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/administrative-units)
- **Restricted Management AUs**: [Restricted management administrative units](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/administrative-units-restricted-management)

> **💡 GUI Path**: `entra.microsoft.com` > **Roles & admins** > **Administrative units**

## 📋 Prerequisites

- Completion of **Lab 01**.
- **Entra ID P1 License** (required for AUs).

## ⏱️ Estimated Duration

- **15 Minutes**

## 📝 Lab Steps

### Step 1: Configure Parameters File

Before deploying resources, you must configure the environment parameters.

**Context**: This project uses a centralized JSON configuration file to manage deployment settings. This ensures consistency across all scripts.

1. Navigate to the `infra` directory.
2. Open `module.parameters.json`.
3. Review the default settings.
4. Save the file.

### Step 2: Deploy Administrative Units

This script creates AUs for each department and populates them with the corresponding users and groups.

**Context**: In a flat tenant, giving someone "User Administrator" lets them reset the CEO's password. Administrative Units (AUs) allow us to create "virtual tenants" so the HR Helpdesk can only manage HR users, not IT or Executive users.

1. Run the following command:

   ```powershell
   .\Deploy-AdministrativeUnits.ps1 -UseParametersFile
   ```

2. It will create `AU-IT`, `AU-HR`, etc.
3. It will dynamically find `USR-HR-*` and add them to `AU-HR`.

#### Validate Administrative Units

1. Go to **Entra Admin Center** > **Identity** > **Roles & admins** > **Admin units**.
2. Verify Administrative Units like `AU-IT`, `AU-HR`, and `AU-Finance` are listed.
3. Select `AU-IT` > **Users**.
4. Confirm that users starting with `USR-IT-` (e.g., `USR-IT-Director`) are listed as members.
5. Repeat for `AU-HR` to confirm HR users are present.

### Step 3: Configure Restricted Management AUs

We will create a special AU for our Emergency Access accounts.

**Context**: Standard AUs are for delegation. Restricted Management AUs are for *protection*. By putting our Break Glass accounts here, we prevent a compromised Global Admin (or a rogue insider) from tampering with our emergency recovery keys.

1. Run the following command:

   ```powershell
   .\Configure-RestrictedManagementAUs.ps1 -UseParametersFile
   ```

2. This creates `AU-SEC-Restricted`.
3. It adds the accounts defined in `module.parameters.json` (e.g., `USR-BREAK-GLASS-01`) to this AU.
4. **Security Note**: Once enabled, even a Global Admin cannot modify these users unless they are explicitly assigned a role *scoped* to this AU.

#### Validate Restricted Management AUs

1. Go to **Entra Admin Center** > **Identity** > **Roles & admins** > **Administrative units**.
2. Verify `AU-SEC-Restricted` is listed.
3. Select `AU-SEC-Restricted` > **Properties**.
4. Verify that **Restricted management administrative unit** is set to **Yes**.
5. Select **Users** and confirm that your Break Glass accounts (e.g., `USR-BREAK-GLASS-01`) are listed as members.

## ✅ Validation

- **AUs**: Verify `AU-IT` exists and contains `USR-IT-Director`.
- **Restricted AU**: Verify `AU-SEC-Restricted` exists and contains the Break Glass accounts.
- **Test**: Try to modify a user in `AU-IT` (this will work for now, as we haven't scoped roles yet - that's Lab 04).

## 🚧 Troubleshooting

- **"Feature not available"**: Ensure you have Entra ID P1 licenses.
- **"Restricted Management not supported"**: This feature requires specific tenant configuration or P1/P2 licenses.

## 🎓 Learning Objectives Achieved

- **Segmentation**: You learned how to slice a single tenant into manageable virtual containers.
- **High Security**: You protected your most critical assets (Break Glass accounts) using Restricted Management AUs.

## 🧹 Cleanup

To remove the resources created in this lab (Administrative Units), run the cleanup script:

```powershell
.\Remove-DelegatedAdmin.ps1
```

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
