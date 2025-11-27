# Lab 05: Entitlement Management

This lab automates the request and approval process for accessing resources. We will use Entitlement Management (ELM) to create Access Packages that bundle groups, apps, and sites, allowing users (internal and external) to request access via a self-service portal.

## 🎯 Lab Objectives

- **Create Catalogs**: Organize resources into a "Marketing" catalog.
- **Deploy Access Packages**: Create a "Marketing Campaign" package containing the Marketing group.
- **External Governance**: Create a package specifically for external guests with strict expiration and access reviews.

## 📚 Microsoft Learn & GUI Reference

- **Entitlement Management**: [What is entitlement management?](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-overview)
- **Access Packages**: [Create a new access package](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-access-package-create)

> **💡 GUI Path**: `entra.microsoft.com` > **Identity Governance** > **Entitlement management**

## 📋 Prerequisites

- Completion of **Lab 01**.
- **Entra ID P2 License**.

## ⏱️ Estimated Duration

- **20 Minutes**

## 📝 Lab Steps

### Step 1: Configure Parameters File

Before deploying resources, you must configure the environment parameters.

**Context**: This project uses a centralized JSON configuration file to manage deployment settings. This ensures consistency across all scripts.

1. Navigate to the `infra` directory.
2. Open `module.parameters.json`.
3. Review the default settings.
4. Save the file.

### Step 2: Deploy Access Packages

We will create a catalog and an access package for internal users.

**Context**: Instead of IT manually adding users to groups, we bundle resources (Groups, Apps, SharePoint sites) into an "Access Package." Users request this package like an item in a shopping cart. This shifts the workload from IT to the business owners who actually know who needs access.

1. Run the following command:

   ```powershell
   .\Deploy-AccessPackages.ps1 -UseParametersFile
   ```

2. Creates Catalog: `CAT-Marketing`.
3. Creates Access Package: `PKG-Marketing-Campaign`.
4. Adds `GRP-SEC-Marketing` to the package.
5. Creates an Assignment Policy allowing `USR-Mkt-Specialist` to request access.

#### Validate Access Packages

1. Go to **Entra Admin Center** > **Identity Governance** > **Entitlement management** > **Access packages**.
2. Click on **PKG-Marketing-Campaign**.
3. Select **Resource roles** and verify **GRP-SEC-Marketing** is listed.
4. Select **Policies** and verify **Internal Users Policy** is listed.

### Step 3: Configure External Governance

We will create a package for guests.

**Context**: Guest access is often "set and forget," leading to security risks. By wrapping guest access in an Access Package, we enforce a lifecycle. The access expires automatically after 30 days unless renewed, and we can force a monthly review to ensure the guest is still relevant.

1. Run the following command:

   ```powershell
   .\Configure-ExternalGovernance.ps1 -UseParametersFile
   ```

2. Creates Access Package: `PKG-Partner-Collab`.
3. Configures a policy:
    - **Expiration**: 30 Days.
    - **Access Reviews**: Monthly.
    - **Approval**: Required (Sponsor).

#### Validate External Governance

1. Go to **Entra Admin Center** > **Identity Governance** > **Entitlement management** > **Connected organizations**.
2. Verify **Partner Corp** is listed.
3. Navigate to **Access packages** and select **PKG-Partner-Collab**.
4. Select **Policies** and verify **Partner Access Policy** is listed.
5. Verify the policy settings show **Expiration: 30 Days** and **Require approval**.

> **ℹ️ Note on Guest Access Testing**: Since this lab does not provision real external guest accounts, we cannot fully test the request flow for the 'Partner Corp' package. In a real scenario, you would share the **My Access Portal Link** (e.g., `https://myaccess.microsoft.com/@<your-tenant-domain>`) with the external partner. They would sign in with their own credentials, and because their domain matches the "Connected Organization" configured, they would see the package available for request.

## ✅ Validation

- **My Access Portal**: Log in as `USR-Mkt-Specialist` to `myaccess.microsoft.com` and verify you can see the "Marketing Campaign" package.
- **Admin Center**: Use the specific validation steps above to confirm configuration.

## 🧹 Cleanup

To remove the resources created in this lab (Catalogs, Access Packages, Connected Organizations), run the cleanup script:

```powershell
.\Remove-EntitlementMgmt.ps1 -UseParametersFile
```

> **ℹ️ Note**: The cleanup script removes the Entitlement Management configuration (Catalogs, Packages, Policies) but **does not delete** the underlying resources (e.g., the `GRP-SEC-Marketing` group) or the users created in previous labs. This allows those resources to be reused in other simulations.

## 🚧 Troubleshooting

- **"Catalog not found"**: Ensure the script completed successfully.
- **"No access packages available"**: Check the Assignment Policy to ensure the user is in the target scope.

## 🎓 Learning Objectives Achieved

- **Self-Service**: You enabled users to request their own access, reducing helpdesk tickets.
- **Automated Lifecycle**: You ensured external access expires automatically, preventing stale guest accounts.

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
