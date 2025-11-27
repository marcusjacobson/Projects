# Lab 09: Cleanup

This lab provides a "Big Red Button" to reset your tenant. It removes all resources created during this simulation, allowing you to start fresh or leave the tenant clean.

## 🎯 Lab Objectives

- **Full Deletion**: Remove all Users, Groups, Roles, Policies, Access Packages, and Governance settings created by this project.
- **State Restoration**: Return the tenant to its pre-simulation state.

## ⚠️ Critical Warning

**This script deletes data.**
It functions as an orchestrator that executes the cleanup scripts for **Lab 07 down to Lab 01** in sequential order. It relies on the logic defined in each module's `Remove-*.ps1` script to target specific resources. You should **always** review the script before running it in a production or shared environment.

## 📋 Prerequisites

- **Global Administrator** role (required to delete other admins and policies).
- **Module Parameter Files**: Ensure the `module.parameters.json` files in Labs 01-07 are still present, as the cleanup scripts rely on them to identify resources.

## ⏱️ Estimated Duration

- **15 Minutes** (Deletion takes time due to API throttling).

## 📝 Lab Steps

### Step 1: Verify Module Parameters

The cleanup orchestration relies on the configuration files from the previous labs to know exactly what to delete.

**Context**: Instead of maintaining a separate list of resources to delete, this module reuses the logic from each individual lab. This ensures that if you changed a resource name in Lab 03's parameters, the cleanup script will correctly identify and remove it.

1. Ensure you have not deleted the `infra/module.parameters.json` files in the previous lab directories.

### Step 2: Execute Cleanup

We will run the master cleanup script.

**Context**: Cleaning up cloud resources manually is tedious and error-prone. This script orchestrates the removal process by calling the cleanup scripts for Labs 07, 06, 05, 04, 03, 02, and 01 in reverse order. This handles dependencies (e.g., removing Access Packages before Groups) automatically.

1. Open a PowerShell terminal.
2. Navigate to the `scripts` directory.
3. Run the following command:

   ```powershell
   .\Nuke-Simulation.ps1
   ```

4. **Confirmation**: You will be prompted to confirm the deletion. Type `Y` to proceed.

### Step 3: Verify Removal

We will use the validation script from Lab 08 to confirm everything is gone.

**Context**: In this specific case, we *want* the validation to fail. If the validation script says "User USR-CEO not found," that means the cleanup was successful.

1. Navigate to `../08-Validation-and-Reporting/scripts/`.
2. Run the following command:

   ```powershell
   .\Validate-AllLabs.ps1 -UseParametersFile
   ```

3. You should see a sea of **RED** (Failures), indicating the resources no longer exist.

## ✅ Validation

- **Users**: Verify `USR-CEO` is in the "Deleted users" bin (Soft Deleted).
- **Policies**: Verify `CA001` is gone from Conditional Access.
- **Governance**: Verify Access Packages and Catalogs are removed.

## 🚧 Troubleshooting

- **"User cannot be deleted"**: If a user is assigned to a role or resource that locks them, the script might fail. Wait 5 minutes and try again.
- **"Soft Delete"**: Entra ID soft-deletes users and groups (30-day recovery). If you want to re-run the simulation immediately, you may need to permanently delete them from the "Deleted users" blade.

## 🎓 Learning Objectives Achieved

- **Lifecycle Management**: You learned that "Decommissioning" is just as important as "Provisioning."
- **Idempotency**: You experienced the full cycle of Infrastructure-as-Code: Deploy -> Validate -> Destroy.

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
