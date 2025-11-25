# Microsoft Entra Deployment Pipelines

A collection of Azure DevOps pipeline projects for automated deployment and management of Microsoft Entra ID (formerly Azure Active Directory) configurations. These pipelines enable Infrastructure-as-Code (IaC) approaches to manage authentication methods, conditional access policies, users, groups, and other Entra resources.

[[_TOC_]]

---

## Overview

This repository provides ready-to-use Azure DevOps pipeline projects that automate the deployment and configuration of Microsoft Entra ID resources. Each project follows a consistent pattern:

- **Azure Pipelines** for orchestration and execution
- **PowerShell scripts** using Microsoft Graph REST API for Entra operations
- **External variable files** (`pipeline-variables.yml`) for environment-specific configuration
- **JSON schema validation** to ensure data integrity - only used on some projects where it adds value
- **No pipeline modifications required** once configured for your environment

### Key Benefits

- ✅ **Declarative Configuration**: Define your Entra resources as code
- ✅ **Reusable**: Standardized patterns across all deployment projects
- ✅ **Version Controlled**: Track changes to your Entra configuration over time
- ✅ **Automated**: Reduce manual configuration errors
- ✅ **Validated**: JSON schema validation ensures data correctness before deployment

---

## Technologies Used

### Azure DevOps Pipelines

All deployment projects use **Azure Pipelines** YAML-based configurations for CI/CD automation.

- **Pipeline Definition**: `pipeline.yml` - Orchestrates the deployment workflow
- **Variable Template**: `pipeline-variables.yml` - Contains all environment-specific configuration
- **Trigger**: Manual execution (`trigger: none`) - pipelines run on-demand
- **Agent Pool**: Ubuntu-latest hosted agents

#### Microsoft Learn Resources for Azure DevOps Pipelines

- [Azure Pipelines Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/)
- [YAML Schema Reference](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/)
- [Create your first pipeline](https://learn.microsoft.com/en-us/azure/devops/pipelines/create-first-pipeline)

### PowerShell & Microsoft Graph REST API

All scripts are written in **PowerShell** and interact with Microsoft Entra ID using the **Microsoft Graph REST API**.

- **Graph API Version**: v1.0 (stable)
- **Authentication**: Azure CLI task with service principal
- **API Calls**: Custom `Invoke-RESTCommand` function using `az rest`

#### Microsoft Learn Resources for REST API

- [Microsoft Graph REST API Reference](https://learn.microsoft.com/en-us/graph/api/overview)
- [Microsoft Graph API Best Practices](https://learn.microsoft.com/en-us/graph/best-practices-concept)
- [Use the Microsoft Graph API](https://learn.microsoft.com/en-us/graph/use-the-api)

#### Specific API Endpoints Used

- [Users API](https://learn.microsoft.com/en-us/graph/api/resources/user)
- [Groups API](https://learn.microsoft.com/en-us/graph/api/resources/group)
- [Conditional Access API](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- [Authentication Methods API](https://learn.microsoft.com/en-us/graph/api/resources/authenticationmethods-overview)
- [Named Locations API](https://learn.microsoft.com/en-us/graph/api/resources/namedlocation)
- [Privileged Identity Management API](https://learn.microsoft.com/en-us/graph/api/resources/privilegedidentitymanagementv3-overview)

### Azure CLI Task

The **AzureCLI@2** task is used in all pipelines to:

- Authenticate to Azure using a service connection
- Execute PowerShell scripts with authenticated context
- Provide service principal credentials for Graph API calls

#### Microsoft Learn Resources for Azure CLI Pipeline Tasks

- [Azure CLI Task Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/azure-cli-v2)
- [Azure Service Connections](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints)

### JSON Schema Validation

Projects that create or update resources include **JSON schema files** (`*.schema.json`) to validate input data before deployment.

- **Validation**: PowerShell `Test-Json` cmdlet validates against JSON Schema Draft-07
- **Error Prevention**: Catches configuration errors before API calls
- **Documentation**: Schema files serve as documentation for expected data structure

---

## 📊 Microsoft Entra Capability Coverage

### What This Project Covers

This project provides **hands-on practical experience with automated Microsoft Entra ID configuration and deployment**, focusing on:

- **Infrastructure as Code (IaC)** (declarative configuration for identity resources)
- **Microsoft Graph API Automation** (direct API interaction without SDK dependencies)
- **Azure DevOps Integration** (CI/CD pipelines for identity management)
- **Conditional Access Management** (automated policy deployment for risk and compliance)
- **Privileged Identity Management** (programmatic PIM for Groups configuration)
- **User & Group Lifecycle** (automated provisioning and membership management)
- **Security Configuration** (Authentication methods and named locations)
- **JSON Schema Validation** (data integrity and error prevention)

**Coverage Depth**: ~35% of total Microsoft Entra ID capability landscape with **deep hands-on automation experience** in covered areas (production-ready pipeline patterns).

**Project Focus**: Automated deployment environment suitable for Identity Engineers, DevSecOps professionals, and Cloud Architects building repeatable, auditable identity infrastructure with emphasis on Graph API mastery and pipeline orchestration.

### Covered Capabilities by Category

#### ✅ Identity Administration & Lifecycle (90% Automation Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **User Provisioning** | ✅ COMPREHENSIVE | Users-Create, Users-Properties-Edit, User-Disable |
| **Group Management** | ✅ COMPREHENSIVE | Group-Create, Group-Assign/Remove-Member/Owner |
| **Nested Groups** | ✅ EXTENSIVE | Group-Assign-Groups-as-Member |
| **Company Branding** | ✅ DETAILED | Company-Branding-Update |

#### ✅ Access Management & Security (85% Automation Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Conditional Access Policies** | ✅ COMPREHENSIVE | Risky-SignIn, User-Risk, Risky-Workload-Identities |
| **Named Locations** | ✅ COMPREHENSIVE | Named-Locations (Countries, IP Ranges) |
| **Authentication Methods** | ✅ DETAILED | FIDO2-Passkey-Config |
| **Privileged Identity Management** | ✅ EXTENSIVE | PIM-Group-Assign/Extend/Remove (Member/Owner) |

#### ✅ DevOps & Automation (100% Core Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Azure DevOps Pipelines** | ✅ COMPREHENSIVE | All Projects (YAML pipelines) |
| **Microsoft Graph REST API** | ✅ COMPREHENSIVE | All Scripts (Direct API calls) |
| **JSON Schema Validation** | ✅ COMPREHENSIVE | Template/*.schema.json |
| **Configuration Management** | ✅ COMPREHENSIVE | pipeline-variables.yml |
| **Service Principal Auth** | ✅ COMPREHENSIVE | AzureCLI task integration |

### What This Project Does NOT Cover

The following capabilities require **custom development**, **hybrid infrastructure**, or **specialized scenarios** beyond this project's scope:

#### ❌ Hybrid Identity (Infrastructure Required)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Entra Connect Sync** | ADVANCED | Requires on-premises server infrastructure |
| **Cloud Sync** | INTERMEDIATE | Requires on-premises agent deployment |
| **Password Writeback** | INTERMEDIATE | Requires hybrid connectivity |
| **Active Directory Federation** | EXPERT | Legacy infrastructure not focus of cloud-native automation |

#### ❌ Application Management (Advanced Configuration)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **App Registrations** | INTERMEDIATE | Focus is on core identity governance, not app dev |
| **Enterprise Applications** | INTERMEDIATE | SSO/SAML configuration varies too widely for generic templates |
| **App Proxy** | ADVANCED | Requires connector installation |

#### ❌ Advanced Governance (Expert-Level)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Access Reviews** | ADVANCED | Complex scheduling and reviewer logic |
| **Entitlement Management** | ADVANCED | Access Packages and Catalogs require complex dependency mapping |
| **Lifecycle Workflows** | ADVANCED | Native workflow engine replaces some external automation needs |

### Project Scope Statement

**Primary Mission**: Provide repeatable, scalable Microsoft Entra ID deployment patterns for **Infrastructure as Code adoption**, **disaster recovery preparation**, and **multi-tenant management** using **standard DevOps tools**.

**Ideal For**: Identity Engineers moving to DevSecOps, MSPs managing multiple tenants, and organizations requiring strict change control for identity configuration.

**Not Suitable For**: One-off manual configurations, hybrid identity synchronization management, or complex SaaS application SSO setups.

---

## 🎓 Skills Development Analysis

### Core Competencies Developed

| Skill Area | Projects | Proficiency Level |
|------------|----------|-------------------|
| **Microsoft Entra Configuration** | All | Intermediate to Advanced |
| **Microsoft Graph REST API** | All Scripts | Advanced |
| **Azure DevOps Pipelines** | All Pipelines | Intermediate |
| **PowerShell Scripting** | All Scripts | Advanced |
| **Infrastructure as Code** | All | Intermediate |
| **JSON Data Modeling** | Templates | Intermediate |
| **Conditional Access Design** | CA Projects | Advanced |
| **Privileged Access Strategy** | PIM Projects | Intermediate |
| **Identity Security Posture** | Auth Methods | Intermediate |

---

## Project Structure

Each deployment project follows a consistent folder structure:

```text
<Project-Name>/
├── Pipeline/
│   ├── pipeline.yml              # Main pipeline definition (DO NOT EDIT after setup)
│   └── pipeline-variables.yml    # Environment-specific variables (EDIT THIS)
├── Scripts/
│   └── <script-name>.ps1         # PowerShell script (DO NOT EDIT)
└── Template/                      # (Optional - not all projects have this)
    ├── <resource>.schema.json    # JSON schema for validation
    └── <reference-data>.json     # Reference data files
```

### Important Files

| File | Purpose | Should You Edit? |
|------|---------|------------------|
| `pipeline.yml` | Orchestrates the deployment workflow | ❌ No - only update repository references once during setup |
| `pipeline-variables.yml` | Contains all environment-specific configuration | ✅ Yes - customize for your environment |
| `*.ps1` | PowerShell scripts that perform the actual deployment | ❌ No - scripts are generic and reusable |
| `*.schema.json` | Validates JSON input data structure | ❌ No - defines the expected data format |
| `*.json` (in Template) | Reference data (e.g., country codes) | ℹ️ Informational - used as examples |

---

## Available Deployment Projects

### Authentication Methods

| Project | Description | Graph API Reference |
|---------|-------------|---------------------|
| **FIDO2-Passkey-Config** | Configure FIDO2/Passkey authentication method policy | [FIDO2 Authentication Method](https://learn.microsoft.com/en-us/graph/api/resources/fido2authenticationmethodconfiguration) |

### Company Branding

| Project | Description | Graph API Reference |
|---------|-------------|---------------------|
| **Company-Branding-Update** | Update Entra company branding (logo, colors, text) | [Organization Branding](https://learn.microsoft.com/en-us/graph/api/resources/organizationalbrandingproperties) |

### Conditional Access

| Project | Description | Graph API Reference |
|---------|-------------|---------------------|
| **Risky-SignIn-Policy-Create** | Create conditional access policy for risky sign-ins | [Conditional Access Policy](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy) |
| **Risky-Workload-Identities-Create** | Create policy for risky workload/service principal identities | [Conditional Access Policy](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy) |
| **User-Risk-Policy-Create** | Create conditional access policy for user risk | [Conditional Access Policy](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy) |

### Groups

| Project | Description | Graph API Reference |
|---------|-------------|---------------------|
| **Group-Create** | Create new Entra security groups | [Create Group](https://learn.microsoft.com/en-us/graph/api/group-post-groups) |
| **Group-Assign-Member** | Add users as members to groups | [Add Group Member](https://learn.microsoft.com/en-us/graph/api/group-post-members) |
| **Group-Assign-Owner** | Add users as owners to groups | [Add Group Owner](https://learn.microsoft.com/en-us/graph/api/group-post-owners) |
| **Group-Assign-Groups-as-Member** | Add groups as members of other groups (nested groups) | [Add Group Member](https://learn.microsoft.com/en-us/graph/api/group-post-members) |
| **Group-Remove-Member** | Remove users from group membership | [Remove Group Member](https://learn.microsoft.com/en-us/graph/api/group-delete-members) |
| **Group-Remove-Owner** | Remove users from group ownership | [Remove Group Owner](https://learn.microsoft.com/en-us/graph/api/group-delete-owners) |

### Named Locations

| Project | Description | Graph API Reference |
|---------|-------------|---------------------|
| **Named-Locations-New-List-Countries** | Create new named location based on country list | [Named Location](https://learn.microsoft.com/en-us/graph/api/resources/namedlocation) |
| **Named-Locations-New-List-IP-Ranges** | Create new named location based on IP ranges | [Named Location](https://learn.microsoft.com/en-us/graph/api/resources/namedlocation) |
| **Named-Locations-Edit-Countries** | Update existing named location countries | [Update Named Location](https://learn.microsoft.com/en-us/graph/api/namedlocation-update) |
| **Named-Locations-Edit-IP-Ranges** | Update existing named location IP ranges | [Update Named Location](https://learn.microsoft.com/en-us/graph/api/namedlocation-update) |
| **Named-Locations-Delete-List** | Delete a named location | [Delete Named Location](https://learn.microsoft.com/en-us/graph/api/namedlocation-delete) |

**Note**: For country-based named locations, use ISO 3166-1 alpha-2 two-letter country codes. Reference: [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)

### Privileged Identity Management (PIM)

| Project | Description | Graph API Reference |
|---------|-------------|---------------------|
| **PIM-Group-Assign-Member** | Assign eligible membership to PIM-enabled groups | [PIM for Groups](https://learn.microsoft.com/en-us/graph/api/resources/privilegedidentitymanagement-for-groups-api-overview) |
| **PIM-Group-Assign-Owner** | Assign eligible ownership to PIM-enabled groups | [PIM for Groups](https://learn.microsoft.com/en-us/graph/api/resources/privilegedidentitymanagement-for-groups-api-overview) |
| **PIM-Group-Extend-Member** | Extend eligible membership assignments | [PIM for Groups](https://learn.microsoft.com/en-us/graph/api/resources/privilegedidentitymanagement-for-groups-api-overview) |
| **PIM-Group-Extend-Owner** | Extend eligible ownership assignments | [PIM for Groups](https://learn.microsoft.com/en-us/graph/api/resources/privilegedidentitymanagement-for-groups-api-overview) |
| **PIM-Group-Remove-Member** | Remove eligible membership from PIM-enabled groups | [PIM for Groups](https://learn.microsoft.com/en-us/graph/api/resources/privilegedidentitymanagement-for-groups-api-overview) |
| **PIM-Group-Remove-Owner** | Remove eligible ownership from PIM-enabled groups | [PIM for Groups](https://learn.microsoft.com/en-us/graph/api/resources/privilegedidentitymanagement-for-groups-api-overview) |

### Users

| Project | Description | Graph API Reference |
|---------|-------------|---------------------|
| **Users-Create** | Create new Entra users with group assignments | [Create User](https://learn.microsoft.com/en-us/graph/api/user-post-users) |
| **User-Disable** | Disable user accounts | [Update User](https://learn.microsoft.com/en-us/graph/api/user-update) |
| **Users-Properties-Edit** | Update user properties (department, job title, etc.) | [Update User](https://learn.microsoft.com/en-us/graph/api/user-update) |

---

## Getting Started

### Prerequisites

Before using these deployment pipelines, ensure you have:

1. **Azure DevOps Organization and Project**
   - [Create an organization](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/create-organization)
   - [Create a project](https://learn.microsoft.com/en-us/azure/devops/organizations/projects/create-project)

2. **Azure Subscription with Entra ID Tenant**
   - Active Azure subscription
   - Appropriate permissions to create service principals

3. **Service Principal with Required Permissions**
   - Create a service principal for pipeline authentication
   - Grant Microsoft Graph API permissions based on the operations you'll perform
   - [Create a service principal](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal)

4. **Azure DevOps Service Connection**
   - Create an Azure Resource Manager service connection
   - Use the service principal created above
   - [Create a service connection](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints)

### Required Microsoft Graph API Permissions

The service principal needs appropriate **Application Permissions** (not Delegated) in Microsoft Graph:

| Operation Category | Required Permissions |
|-------------------|---------------------|
| **Users** | `User.ReadWrite.All`, `Directory.ReadWrite.All` |
| **Groups** | `Group.ReadWrite.All`, `Directory.ReadWrite.All` |
| **Conditional Access** | `Policy.ReadWrite.ConditionalAccess`, `Policy.Read.All`, `Application.Read.All` |
| **Authentication Methods** | `Policy.ReadWrite.AuthenticationMethod` |
| **PIM** | `PrivilegedAccess.ReadWrite.AzureADGroup`, `RoleManagementPolicy.ReadWrite.AzureADGroup` |
| **Named Locations** | `Policy.ReadWrite.ConditionalAccess` |
| **Company Branding** | `Organization.ReadWrite.All` |

**Important**: After granting API permissions, an admin must provide **admin consent** for the service principal.

#### Microsoft Learn Resources fir Graph API Permissions

- [Microsoft Graph Permissions Reference](https://learn.microsoft.com/en-us/graph/permissions-reference)
- [Grant Admin Consent](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/grant-admin-consent)

---

## How to Customize for Your Environment

### Step 1: Import Pipelines into Azure DevOps

1. **Clone or Import Repository**
   - Import this repository into your Azure DevOps project
   - [Import a Git repo](https://learn.microsoft.com/en-us/azure/devops/repos/git/import-git-repository)

2. **Create Pipeline for Each Project**
   - Navigate to **Pipelines** → **New Pipeline**
   - Select **Azure Repos Git** (or your repository source)
   - Select **Existing Azure Pipelines YAML file**
   - Point to the `pipeline.yml` file in the project folder you want to deploy
   - Example: `Users/Users-Create/Pipeline/pipeline.yml`
   - [Create a pipeline](https://learn.microsoft.com/en-us/azure/devops/pipelines/create-first-pipeline)

### Step 2: Update Repository References (One-Time Setup)

In each `pipeline.yml` file, update the repository reference to match your Azure DevOps project:

```yaml
resources:
  repositories:
    - repository: <YOUR-REPOSITORY-NAME>
      type: git
      name: '<YOUR-PROJECT-NAME>/<YOUR-REPOSITORY-NAME>'
```

**Example:**

```yaml
resources:
  repositories:
    - repository: EntraDeployments
      type: git
      name: 'MyProject/Entra-Deployment-Pipelines'
```

### Step 3: Customize Variable Files

Each project has a `pipeline-variables.yml` file that contains all environment-specific configuration. This is the **ONLY file you need to edit** for each deployment.

#### Common Variables Across All Projects

Every `pipeline-variables.yml` includes:

```yaml
serviceConnection: '<YOUR-SERVICE-CONNECTION-NAME>'
```

**Action Required**: Replace `<YOUR-SERVICE-CONNECTION-NAME>` with the name of your Azure DevOps service connection.

#### Project-Specific Variables

Each project has additional variables specific to its purpose. Look for comments marked with **`REQUIRED:`** in the variable files.

**Example - Users-Create Project:**

```yaml
variables:
  serviceConnection: "MyAzureConnection"  # REQUIRED: Your service connection name
  domain: "contoso.com"                    # REQUIRED: Your tenant domain
  
  userProperties: >
    {
      "users": [
        {
          "firstName": "John",
          "lastName": "Doe",
          "location": "US",                # REQUIRED: 2-letter country code
          "company": "Contoso Corp",       # Optional
          "department": "IT",              # Optional
          "jobTitle": "Engineer",          # Optional
          "manager": "manager@contoso.com", # Optional: must exist in Entra
          "groups": ["IT-Team", "All-Users"] # Optional: groups must exist
        }
      ]
    }
```

### Step 4: Validate Your Configuration

Before running pipelines:

1. **Review JSON Structure**: Ensure your JSON in variable files is properly formatted
2. **Check Schema Files**: Review `Template/*.schema.json` files to understand required vs. optional fields
3. **Verify Resource Existence**: For references (groups, users, managers), ensure they exist in your Entra tenant
4. **Test with Small Scope**: Start with a single user/group/policy to validate the pipeline works

---

## Pipeline Execution

### Running a Pipeline

1. Navigate to **Pipelines** in Azure DevOps
2. Select the pipeline you want to run
3. Click **Run pipeline**
4. Review the variables (optional - can override pipeline-variables.yml values)
5. Click **Run**

#### Microsoft Learn Resources for Azure Pipelines

- [Run a pipeline](https://learn.microsoft.com/en-us/azure/devops/pipelines/create-first-pipeline#run-the-pipeline)
- [Pipeline runs](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/runs)

### Pipeline Execution Flow

All pipelines follow this standard execution pattern:

1. **Checkout**: Clone the repository to the pipeline agent
2. **Authenticate**: Azure CLI task authenticates using the service connection
3. **Load Variables**: Import variables from `pipeline-variables.yml`
4. **Schema Validation** (if applicable): Validate JSON input against schema
5. **Execute Script**: Run PowerShell script with Microsoft Graph REST API calls
6. **Output Results**: Display verbose logging showing operation results

### Monitoring Pipeline Runs

- **Real-time Logs**: View live output as the pipeline executes
- **Verbose Logging**: All scripts include detailed verbose output
- **Error Handling**: Scripts include comprehensive error handling and informative messages
- **Pipeline History**: Track all executions and changes over time

---

## Security Considerations

### Service Principal Security

- **Least Privilege**: Grant only the minimum required Graph API permissions
- **Rotate Credentials**: Regularly rotate service principal secrets
- **Audit Access**: Monitor service principal activity in Entra audit logs
- **Separate Service Principals**: Consider using different service principals for different operation categories

### Pipeline Security

- **Manual Triggers**: All pipelines use `trigger: none` to prevent accidental execution
- **Branch Policies**: Implement branch policies to require pull request reviews
- **Pipeline Permissions**: Restrict who can run pipelines using Azure DevOps permissions
- **Variable Security**: Use Azure DevOps secret variables for sensitive data

#### Microsoft Learn Resources for Pipeline Security

- [Pipeline Security](https://learn.microsoft.com/en-us/azure/devops/pipelines/security/overview)
- [Secure your pipeline](https://learn.microsoft.com/en-us/azure/devops/pipelines/security/templates)

### Change Management Best Practices

1. **Use Git Branches**: Create feature branches for configuration changes
2. **Pull Requests**: Require PR reviews before merging to main
3. **Test in Non-Production**: Test pipelines in dev/test tenants first
4. **Document Changes**: Use commit messages to document why changes were made
5. **Rollback Plan**: Keep previous configurations in Git history for easy rollback

---

## Contributing

This repository follows a standardized pattern. When contributing:

1. **Maintain Consistency**: Follow the existing project structure
2. **Use Generic Placeholders**: Use `<YOUR-X-NAME>` format for environment-specific values
3. **Add Comments**: Include detailed comments in variable files
4. **Update Documentation**: Update this README when adding new projects
5. **Preserve Author Attribution**: Maintain existing author information in script headers

---

## Additional Resources

### Microsoft Learn Documentation

- [Microsoft Entra ID Documentation](https://learn.microsoft.com/en-us/entra/identity/)
- [Microsoft Graph Documentation](https://learn.microsoft.com/en-us/graph/)
- [Azure DevOps Pipelines Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)

### Useful Tools

- [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer) - Test Microsoft Graph API calls
- [JWT.ms](https://jwt.ms/) - Decode and inspect tokens
- [JSON Schema Validator](https://www.jsonschemavalidator.net/) - Validate JSON against schemas

### Related Microsoft Learn Modules

- [Manage Azure identities and governance](https://learn.microsoft.com/en-us/training/paths/azure-administrator-manage-identities-governance/)
- [Implement and manage hybrid identity](https://learn.microsoft.com/en-us/training/paths/implement-manage-hybrid-identity/)
- [Build a CI/CD pipeline with Azure Pipelines](https://learn.microsoft.com/en-us/training/modules/create-a-build-pipeline/)

---

## Support and Feedback

For issues, questions, or contributions, please use the repository's issue tracking system in Azure DevOps.

**Version**: 2.0  
**Last Updated**: October 2025  
**Maintained By**: Marcus Jacobson
