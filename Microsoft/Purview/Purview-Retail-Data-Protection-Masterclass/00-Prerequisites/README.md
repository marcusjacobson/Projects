# Prerequisites and Environment Setup

This section outlines the necessary prerequisites for the Purview Retail Data Protection Masterclass. Before proceeding with the labs, ensure your environment is correctly configured.

## 📋 Requirements

### 1. Licensing
- **Microsoft 365 E5** or **Microsoft 365 E5 Compliance** license.
- **Azure Subscription** linked to the tenant for Purview Pay-As-You-Go (PAYG) features (required for EDM and advanced classification).

### 2. Permissions
- **Global Administrator** or **Compliance Administrator** role in the Microsoft 365 tenant.
- **Application Administrator** role (to create the Service Principal).
- **Owner** or **Contributor** role on the Azure Subscription (for PAYG setup).

### 3. Technical Environment
- **PowerShell 7+** installed.
- **Microsoft Graph PowerShell SDK** installed (`Install-Module Microsoft.Graph`).
- **Visual Studio Code** with the PowerShell extension.
- **Azure DevOps Organization** (free tier is sufficient) for the IaC labs.

## 🔐 Authentication Setup

This project uses a **Service Principal** with Certificate-based authentication for all automated tasks. This mirrors a production DevSecOps environment.

### Required Graph Permissions
The Service Principal requires the following **Application** permissions:

| API | Permission | Purpose |
|-----|------------|---------|
| **Microsoft Graph** | `InformationProtectionPolicy.ReadWrite.All` | Manage Sensitivity Labels and Policies |
| **Microsoft Graph** | `InformationProtectionPolicy.Read.All` | Read existing policies |
| **Microsoft Graph** | `User.Read.All` | Read user profiles for scoping |
| **Microsoft Graph** | `Group.Read.All` | Read group membership for scoping |
| **Microsoft Graph** | `Files.ReadWrite.All` | Generate and modify test files in SharePoint/OneDrive |
| **Microsoft Graph** | `Sites.ReadWrite.All` | Manage SharePoint sites for test data |
| **Office 365 Exchange Online** | `Exchange.ManageAsApp` | Required for Exchange Online PowerShell (Audit Log) |

### Setup Steps

1.  **Create Service Principal**: Run the `New-PurviewServicePrincipal.ps1` script (if available in your library) or manually create an App Registration in Entra ID.
2.  **Grant Consent**: Grant admin consent for the permissions listed above.
3.  **Generate Certificate**: Create a self-signed certificate and upload the public key to the App Registration.
4.  **Store Credentials**: Save the Application ID, Tenant ID, and Certificate Thumbprint. You will need these for the connection scripts.

## 🛠️ Connection Scripts

Use the provided `scripts/Connect-PurviewGraph.ps1` script in this directory to establish a session with the Microsoft Graph SDK using your Service Principal.

```powershell
.\scripts\Connect-PurviewGraph.ps1 -TenantId "your-tenant-id" -AppId "your-app-id" -CertificateThumbprint "your-thumbprint"
```

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for Microsoft Purview authentication and setup.

*AI tools were used to enhance productivity and ensure comprehensive coverage of prerequisite requirements while maintaining technical accuracy.*
