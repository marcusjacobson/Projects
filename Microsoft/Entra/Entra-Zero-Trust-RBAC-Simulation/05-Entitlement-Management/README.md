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

### Step 1: Deploy Access Packages

We will create a catalog and an access package for internal users.

**Context**: Instead of IT manually adding users to groups, we bundle resources (Groups, Apps, SharePoint sites) into an "Access Package." Users request this package like an item in a shopping cart. This shifts the workload from IT to the business owners who actually know who needs access.

1. Run `Deploy-AccessPackages.ps1`.
2. Creates Catalog: `CAT-Marketing`.
3. Creates Access Package: `PKG-Marketing-Campaign`.
4. Adds `GRP-SEC-Marketing` to the package.
5. Creates an Assignment Policy allowing `USR-Mkt-Specialist` to request access.

### Step 2: Configure External Governance

We will create a package for guests.

**Context**: Guest access is often "set and forget," leading to security risks. By wrapping guest access in an Access Package, we enforce a lifecycle. The access expires automatically after 30 days unless renewed, and we can force a monthly review to ensure the guest is still relevant.

1. Run `Configure-ExternalGovernance.ps1`.
2. Creates Access Package: `PKG-External-Collaboration`.
3. Configures a policy:
    - **Expiration**: 30 Days.
    - **Access Reviews**: Monthly.
    - **Approval**: Required (Sponsor).

## ✅ Validation

- **My Access Portal**: Log in as `USR-Mkt-Specialist` to `myaccess.microsoft.com` and verify you can see the "Marketing Campaign" package.
- **Admin Center**: Verify the Catalog and Packages exist in Entitlement Management.

## 🚧 Troubleshooting

- **"Catalog not found"**: Ensure the script completed successfully.
- **"No access packages available"**: Check the Assignment Policy to ensure the user is in the target scope.

## 🎓 Learning Objectives Achieved

- **Self-Service**: You enabled users to request their own access, reducing helpdesk tickets.
- **Automated Lifecycle**: You ensured external access expires automatically, preventing stale guest accounts.

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
