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
| **Microsoft Graph** | `InformationProtectionPolicy.Read.All` | Read existing policies |
| **Microsoft Graph** | `User.Read.All` | Read user profiles for scoping |
| **Microsoft Graph** | `Group.Read.All` | Read group membership for scoping |
| **Microsoft Graph** | `Files.ReadWrite.All` | Generate and modify test files in SharePoint/OneDrive |
| **Microsoft Graph** | `Sites.ReadWrite.All` | Manage SharePoint sites for test data |
| **Office 365 Exchange Online** | `Exchange.ManageAsApp` | Required for Exchange Online PowerShell (Audit Log) |

### Setup Steps

1. **Configure Global Settings**: Review and update `templates/global-config.json` if necessary (default settings are usually sufficient).
2. **Run Deployment Script**: Execute the automated setup script to create the Service Principal, assign permissions, and generate certificates.

   ```powershell
   # Navigate to scripts directory
   cd scripts

   # Run the deployment script
   .\Deploy-ServicePrincipal.ps1
   ```

3. **Review Output**: The script will output the **Application ID**, **Tenant ID**, and **Certificate Thumbprint**. It also saves these details to `scripts\ServicePrincipal-Details.txt` in the project root.
   > **Note**: The script will display a **Certificate Password** on the screen. This password is **only required if you need to move the certificate** to another machine, which is outside the scope of this project. The Service Principal and certificate are intended to be removed as part of the project cleanup process.
4. **Verify Permissions**: Log in to the Azure Portal (Entra ID) and verify the App Registration has the required permissions and admin consent granted.

## 🛠️ Connection Scripts

Use the provided global connection script located in `../../scripts/Connect-PurviewGraph.ps1` to establish a session with the Microsoft Graph SDK using your Service Principal. The script automatically detects the configuration from the deployment output.

```powershell
..\..\scripts\Connect-PurviewGraph.ps1
```

> **Note**: You can still provide parameters manually if you need to override the detected values.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for Microsoft Purview authentication and setup.

*AI tools were used to enhance productivity and ensure comprehensive coverage of prerequisite requirements while maintaining technical accuracy.*
