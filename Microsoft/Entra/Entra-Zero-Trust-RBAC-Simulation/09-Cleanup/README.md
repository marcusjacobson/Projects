# Lab 09: Cleanup

This lab provides a "Big Red Button" to reset your tenant. It removes all resources created during this simulation, allowing you to start fresh or leave the tenant clean.

## 🎯 Lab Objectives

- **Full Deletion**: Remove all Users, Groups, Roles, Policies, Access Packages, and Governance settings created by this project.
- **State Restoration**: Return the tenant to its pre-simulation state.

## ⚠️ Critical Warning

**This script deletes data.**
It is designed to target *only* resources with the specific prefixes used in this project (`USR-`, `GRP-`, `AU-`, `ROLE-`, `CA00X`, etc.). However, you should **always** review the script before running it in a production or shared environment.

## 📋 Prerequisites

- **Global Administrator** role (required to delete other admins and policies).

## ⏱️ Estimated Duration

- **15 Minutes** (Deletion takes time due to API throttling).

## 📝 Lab Steps

### Step 1: Execute Cleanup

We will run the master cleanup script.

**Context**: Cleaning up cloud resources manually is tedious and error-prone. This script reverses the actions of Labs 01-07. It handles dependencies (e.g., you can't delete a group if it's assigned to an Access Package) by deleting resources in the correct order.

1. Open a PowerShell terminal.
2. Navigate to the `scripts` directory.
3. Run `Nuke-Simulation.ps1`.
4. **Confirmation**: You will be prompted to confirm the deletion. Type `Y` to proceed.

### Step 2: Verify Removal

We will use the validation script from Lab 08 to confirm everything is gone.

**Context**: In this specific case, we *want* the validation to fail. If the validation script says "User USR-CEO not found," that means the cleanup was successful.

1. Navigate to `../08-Validation-and-Reporting/scripts/`.
2. Run `Validate-AllLabs.ps1`.
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
