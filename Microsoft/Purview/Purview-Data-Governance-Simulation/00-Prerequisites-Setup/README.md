# Lab 00: Prerequisites Setup

This lab validates that your environment meets all requirements for the Purview Data Governance Simulation project and initializes the necessary directory structure and logging infrastructure.

## 🎯 Lab Objectives

- Validate Microsoft 365 E5 licensing and required permissions
- Verify PowerShell module installation and versions
- Test connectivity to SharePoint Online and Security & Compliance
- Initialize simulation directory structure
- Configure logging infrastructure
- Prepare environment for simulation execution

## 📋 Prerequisites

### Required Microsoft 365 Licensing

- **Microsoft 365 E5** license (includes Microsoft Purview Information Protection)
- **Azure Active Directory Premium P2** (included in E5)
- **SharePoint Online Plan 2** (included in E5)

### Required Permissions

- **SharePoint Administrator** or **Global Administrator** role
- **Compliance Administrator** role (for Purview operations)
- Ability to create SharePoint sites and upload content
- Access to Security & Compliance PowerShell

### Required PowerShell Modules

- **PnP.PowerShell** (version 2.3.0 or higher) - SharePoint Online operations
- **ExchangeOnlineManagement** (version 3.4.0 or higher) - Security & Compliance operations

> **💡 Note**: If you've used these modules in other projects, they're likely already installed. Step 2 below will verify installation status.

### Local Environment Requirements

- **Windows 10/11** or **Windows Server 2019+** with PowerShell 5.1+
- **PowerShell 7+** recommended for better performance
- **Internet connectivity** for Azure/Microsoft 365 services
- **Minimum 10 GB free disk space** for document generation (Large scale)

## ⏱️ Estimated Duration

- **Prerequisites Validation**: 5-10 minutes
- **Environment Initialization**: 2-3 minutes
- **Total Lab Time**: 10-15 minutes

## 📝 Lab Steps

### Step 1: Update Global Configuration

Before running any scripts, you must update the `global-config.json` file with your tenant-specific information.

Navigate to the project root directory and open `global-config.json`:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation"
code global-config.json  # Or use notepad, vim, etc.
```

> **📋 Configuration Overview**: The `global-config.json` file contains 7 main sections. This lab (Lab 00) covers **Environment**, **Simulation**, **SharePointSites**, **Paths**, and **Logging** configuration. Additional sections are detailed in later labs where they're actively used.
>
> **💾 Template Backup**: A template copy (`global-config.json.template`) is maintained in the project root. This file contains the default configuration with placeholder values and is used by the **Lab 06 Reset-Environment.ps1** script to restore configuration to defaults during cleanup operations.

#### Environment Configuration (Required - Lab 00)

Update the following required properties in the **Environment** section:

| Property | Description | Required Role(s) | Example |
|----------|-------------|------------------|---------|
| **TenantUrl** | Your SharePoint tenant URL | N/A (read-only reference) | `https://contoso.sharepoint.com` |
| **TenantDomain** | Your Microsoft 365 domain (custom or onmicrosoft.com) | N/A (read-only reference) | `contoso.com` or `contoso.onmicrosoft.com` |
| **AdminEmail** | Your admin email address (user running scripts) | **SharePoint Administrator** + **Compliance Administrator** | `admin@contoso.com` or `admin@contoso.onmicrosoft.com` |
| **AdminCenterUrl** | Your SharePoint admin center URL | `https://contoso-admin.sharepoint.com` |
| **ComplianceUrl** | Your Security & Compliance center URL | `https://compliance.microsoft.com` |
| **OrganizationName** | Your organization name | `Contoso Corporation` |

> **💡 Domain Support**: The simulation supports both **custom domains** (e.g., `contoso.com`) and **default onmicrosoft.com domains** (e.g., `contoso.onmicrosoft.com`). Use whichever domain is configured in your Microsoft 365 tenant.
>
> **👤 Required Roles for User Accounts**:
>
> - **AdminEmail** (user running scripts): Must have **SharePoint Administrator** + **Compliance Administrator** roles
> - **DefaultOwner**: Should have **SharePoint Administrator** role (can be any licensed user, but admin role recommended)
> - **Site Owners**: Must have **SharePoint Administrator** or **Site Collection Administrator** permissions
> - **NotificationEmail**: No specific role required (can be external email for notifications)

#### Simulation Configuration (Required - Lab 00)

Update the **Simulation** section:

| Property | Description | Valid Values | Required Role(s) | Example |
|----------|-------------|--------------|------------------|---------|
| **ScaleLevel** | Simulation scale controlling document generation and storage requirements | **Must be**: `Small`, `Medium`, or `Large` (case-sensitive) | N/A (configuration setting) | `Medium` |
| **CompanyPrefix** | Prefix for all simulated resources (used in SharePoint site titles) | Any alphanumeric string | N/A (label only) | `CONTOSO` |
| **ResourcePrefix** | Technical resource prefix for naming conventions | Any alphanumeric string | N/A (label only) | `Dev-Sim` |
| **DefaultOwner** | Email address for resource ownership (must be valid user in tenant) | Valid tenant email address | **SharePoint Administrator** (recommended, can be any licensed user) | `admin@contoso.com` |
| **NotificationEmail** | Email for notifications (must be valid user or external email) | Valid email address | No specific role (can be external email) | `admin@contoso.com` |

> **⚠️ ScaleLevel Validation**: The `ScaleLevel` property is strictly validated by scripts. Must be exactly `Small`, `Medium`, or `Large` (case-sensitive). Invalid values will cause configuration validation errors.
>
> **💡 Scale Impact**:
>
> - `Small`: 1 GB storage, 500-1,000 documents, 5-10 min generation
> - `Medium`: 5 GB storage, 5,000 documents, 20-30 min generation  
> - `Large`: 15 GB storage, 20,000 documents, 1-2 hours generation
>
> **💡 Important**: All other labs will automatically use these values. No hardcoding required!

#### SharePointSites Configuration (Review - Lab 01 Usage)

The **SharePointSites** array defines sites that will be created in **Lab 01**. Each site requires the following properties:

| Property | Description | Valid Values | Required Role(s) | Example |
|----------|-------------|--------------|------------------|---------|
| **Name** | Site alias (URL-friendly name) | Alphanumeric with hyphens | N/A (configuration setting) | `HR-Simulation` |
| **Template** | SharePoint site template type | `Team` or `Communication` (scripts use `TeamSite` template regardless) | N/A (configuration setting) | `Team` |
| **Department** | Department name (used in site title) | Any descriptive string | N/A (label only) | `Human Resources` |
| **Owner** | Site owner email (must be valid tenant user with permissions) | Valid tenant email address | **SharePoint Administrator** or **Site Collection Administrator** | `admin@contoso.com` |
| **Description** | Site description for metadata | Any descriptive string | `HR department simulation site` |

> **⚠️ Critical**: All `Owner` email addresses **must be valid users in your tenant** with SharePoint Administrator or Site Collection Administrator permissions. Site creation will fail if Owner emails don't exist in your tenant.
>
> **💡 Template Note**: While configuration accepts `Team` or `Communication` values, the New-PnPSite cmdlet always creates Team sites (Type: `TeamSite`) for consistency across all simulation sites.
>
> **📌 Lab Reference**: These sites are created in **Lab 01: SharePoint Site Creation**. Review the configuration now, but no action required until Lab 01.

#### BuiltInSITs Configuration (Review - Lab 02+ Usage)

The **BuiltInSITs** array defines which Sensitive Information Types are validated and scanned. Each SIT requires the following properties:

| Property | Description | Valid Values | Example |
|----------|-------------|--------------|---------|
| **Name** | Exact SIT name from Microsoft Purview Compliance Portal | Must match exactly (case-sensitive) | `U.S. Social Security Number (SSN)` |
| **Enabled** | Whether this SIT is included in validation and DLP policy testing | `true` or `false` | `true` |
| **Priority** | Classification priority for reporting and analytics | `High`, `Medium`, or `Low` (informational only, not validated) | `High` |
| **Description** | Brief description for reference and documentation | Any descriptive string | `Nine-digit SSN format` |

> **💡 Priority Usage**: The `Priority` field is **informational only** and used for reporting/analytics. Scripts do not validate these values, so you can use any descriptive text if needed, though `High`, `Medium`, `Low` are recommended for consistency.
>
> **⚠️ SIT Name Validation**: SIT names must match **exactly** as shown in Purview Compliance Portal (case-sensitive). Incorrect names will cause validation failures in Lab 04+.
>
> **📌 Lab Reference**: Document generation occurs in **Lab 02**, validation starts in **Lab 04**. See Step 6 below for detailed configuration guidance.

#### DocumentGeneration Configuration (Review - Lab 02 Usage)

The **DocumentGeneration** section controls test document creation. Review the parameters now, but document generation happens in **Lab 02: Test Data Generation**.

> **📌 Lab Reference**: Documents are generated in **Lab 02: Test Data Generation**. See Step 5 below for detailed configuration guidance.

#### Paths Configuration (Auto-Configured - Lab 00)

The **Paths** section defines directory structure. Default values work for most scenarios and are automatically created during Lab 00 initialization.

| Path | Purpose | Default |
|------|---------|---------|
| **LogDirectory** | Log file storage | `./logs` |
| **OutputDirectory** | Script outputs | `./output` |
| **GeneratedDocumentsPath** | Generated test files | `./generated-documents` |
| **ReportsPath** | Validation reports | `./reports` |
| **TempPath** | Temporary files | `./temp` |

> **💡 Tip**: Paths are relative to the project root. Change only if you need custom directory locations.

#### Logging Configuration (Auto-Configured - Lab 00)

The **Logging** section controls log verbosity and retention. Default values are recommended for most scenarios.

| Setting | Purpose | Default |
|---------|---------|---------|
| **LogLevel** | Log verbosity | `Verbose` |
| **RetainLogDays** | Log retention period | `30` |
| **EnableConsoleOutput** | Display logs in console | `true` |
| **EnableFileOutput** | Write logs to files | `true` |

---

### Step 2: Run Prerequisites Validation

Run the Test-Prerequisites script to verify your environment meets all requirements:

```powershell
.\00-Prerequisites-Setup\scripts\Test-Prerequisites.ps1
```

**What This Script Does:**

- Verifies PowerShell version and module installations
- Loads and validates global-config.json configuration
- Tests authentication and connectivity to SharePoint and Security & Compliance
- Checks available disk space for document generation
- Validates write permissions to required directories

**Expected Output:**

```text
🔍 Step 1: Validate PowerShell Environment
==========================================
   ✅ PowerShell version: 7.4.0
   ✅ Module installed: PnP.PowerShell (2.3.0)
   ✅ Module installed: ExchangeOnlineManagement (3.4.0)

🔍 Step 2: Load and Validate Configuration
==========================================
   ✅ Configuration loaded successfully
   ✅ All required sections present

🔍 Step 3: Test Service Connectivity
====================================
   ✅ SharePoint Online connection successful
   ✅ Security & Compliance connection successful

🔍 Step 4: Validate Environment Requirements
============================================
   ✅ Disk space available: 25.4 GB (Required: 10 GB)
   ✅ Directory write permissions validated

✅ All prerequisites validated successfully
```

> **🔐 Authentication Note**: The script uses the Connection-Management module for authentication. Browser windows will open automatically for Microsoft 365 sign-in. Ensure you sign in with an account that has **SharePoint Administrator** and **Compliance Administrator** roles.

**If modules are missing, install them:**

```powershell
# Install PnP PowerShell (for SharePoint operations)
Install-Module -Name PnP.PowerShell -Scope CurrentUser -Force

# Install Exchange Online Management (for Security & Compliance)
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force

# Re-run prerequisites validation
.\00-Prerequisites-Setup\scripts\Test-Prerequisites.ps1
```

> **💡 Module Installation Tip**: Using `-Scope CurrentUser` installs modules to your user profile without requiring administrator privileges. If you encounter OneDrive sync issues with PowerShell 7, consider using `-Scope AllUsers` with administrator privileges to install to `C:\Program Files\PowerShell\Modules`.

### Step 3: Initialize Simulation Environment

Initialize the simulation environment to create directory structure and logging infrastructure:

```powershell
.\00-Prerequisites-Setup\scripts\Initialize-SimulationEnvironment.ps1
```

**What This Script Does:**

- Creates directory structure from `global-config.json` Paths section **in the project root directory**
- Initializes logging infrastructure
- Creates log directory and initial log files
- Validates write permissions to all directories
- Prepares environment for simulation execution

> **📁 Directory Location**: All directories are created **relative to the project root** where you run the script. For example, if you run the script from `C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation`, the directories will be created as:
>
> - `C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\logs`
> - `C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\output`
> - `C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\generated-documents`
> - `C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\reports`
> - `C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\temp`

**Expected Output:**

```text
🔍 Step 1: Load Global Configuration
=====================================
   ✅ Configuration loaded successfully
   📋 Organization: YourOrganization
   📋 Scale Level: Medium

🔍 Step 2: Create Directory Structure
======================================
   📋 Creating directory: Log Directory
      Path: ./logs
   ✅ Created: Log Directory
   📋 Creating directory: Output Directory
      Path: ./output
   ✅ Created: Output Directory
   📋 Creating directory: Generated Documents
      Path: ./generated-documents
   ✅ Created: Generated Documents
   📋 Creating directory: Reports Directory
      Path: ./reports
   ✅ Created: Reports Directory
   📋 Creating directory: Temp Directory
      Path: ./temp
   ✅ Created: Temp Directory

🔍 Step 3: Validate Write Permissions
======================================
   ✅ Write permissions validated: Log Directory
   ✅ Write permissions validated: Output Directory
   ✅ Write permissions validated: Generated Documents
   ✅ Write permissions validated: Reports Directory
   ✅ Write permissions validated: Temp Directory

🔍 Step 4: Initialize Logging Infrastructure
=============================================
   ✅ Logging infrastructure operational
   ✅ Log file created: Initialize-SimulationEnvironment-2025-11-16.log

✅ Simulation environment initialized successfully
```

### Step 4: Verify SharePoint Sites Configuration

Review the SharePoint sites that will be created in Lab 01:

```powershell
$config = & ".\Shared-Utilities\Import-GlobalConfig.ps1"
$config.SharePointSites | Format-Table Name, Template, Department, Owner
```

**Expected Output:**

```text
Name                Template       Department  Owner
----                --------       ----------  -----
HR-Simulation       STS#3          Human Resources  admin@contoso.com
Finance-Simulation  STS#3          Finance     admin@contoso.com
Legal-Simulation    STS#3          Legal       admin@contoso.com
Marketing-Simulation STS#3         Marketing   admin@contoso.com
IT-Simulation       STS#3          IT          admin@contoso.com
```

### Step 5: Configure Document Generation Settings

Review and adjust the document generation parameters based on your testing needs:

```powershell
$config.DocumentGeneration | Format-List
```

**Configuration Parameters:**

| Parameter | Description | Valid Values | Recommendation |
|-----------|-------------|--------------|----------------|
| **TotalDocuments** | Total number of documents to generate | Any integer (500-20,000 recommended) | Small: 1000, Medium: 5000, Large: 20000 |
| **FileTypeDistribution** | Percentage of each file type (must total 100) | `docx`, `xlsx`, `pdf`, `txt` keys with integer percentages | 45% docx, 30% xlsx, 15% pdf, 10% txt |
| **PIIDensity** | Concentration of PII in documents | `Low`, `Medium`, `High` (case-sensitive) | `Medium` for balanced testing |
| **CommentsEnabled** | Include comments in documents | `true` or `false` (boolean) | `true` for metadata testing |
| **MetadataEnabled** | Include custom SharePoint metadata | `true` or `false` (boolean) | `true` for classification testing |

> **⚠️ PIIDensity Validation**: Must be exactly `Low`, `Medium`, or `High` (case-sensitive). This controls PII pattern density: Low (1-2 patterns), Medium (3-5 patterns), High (6-10 patterns per document).

**Document Generation Scale Impact:**

| Scale | Total Docs | Storage | Generation Time | Use Case |
|-------|-----------|---------|-----------------|----------|
| **Small** | 500-1,000 | ~1 GB | 5-10 min | Quick testing, demos |
| **Medium** | 5,000 | ~4 GB | 20-30 min | Standard lab exercises |
| **Large** | 20,000 | ~15 GB | 1-2 hours | Production simulations |

**Example Configuration:**

```json
"DocumentGeneration": {
  "TotalDocuments": 5000,
  "FileTypeDistribution": {
    "docx": 45,
    "xlsx": 30,
    "pdf": 15,
    "txt": 10
  },
  "PIIDensity": "Medium",
  "CommentsEnabled": true,
  "MetadataEnabled": true
}
```

> **💡 Performance Tip**: Start with Small scale (1,000 documents) for initial testing, then increase to Medium or Large for comprehensive validation.

### Step 6: Verify Built-In SITs Configuration

Review the built-in Sensitive Information Types that will be targeted for validation and scanning:

```powershell
$config.BuiltInSITs | Where-Object { $_.Enabled } | Format-Table Name, Priority, Description
```

**Expected Output:**

```text
Name                          Priority  Description
----                          --------  -----------
U.S. Social Security Number   High      9-digit SSN format
Credit Card Number            High      Major card types (Visa, MC, Amex)
U.S./U.K. Passport Number     High      Passport formats
U.S. Driver's License Number  Medium    State-specific formats
U.S. Individual Taxpayer...   Medium    ITIN format
ABA Routing Number            Medium    9-digit routing numbers
U.S. Bank Account Number      Low       8-17 digit account numbers
International Banking...      Low       IBAN formats
```

> **💡 Important Distinction**:
>
> - **Document Generation** (Lab 02): Creates diverse content containing **all PII types** regardless of Enabled flags
> - **Validation & Scanning** (Labs 04-06): Uses `Enabled: true` SITs to determine **what to validate and scan for**
> - This separation allows you to generate rich test data once, then selectively test different SIT combinations

**How to Add Additional Built-In SITs:**

1. **Find the exact SIT name** in Microsoft Purview Compliance Portal:

   - Navigate to: [Compliance Portal > Data Classification > Classifiers > Sensitive Info Types](https://compliance.microsoft.com/classificationdefinitions)
   - Search for the SIT you want to add
   - Copy the **exact name** as shown in Purview (case-sensitive)
   - **Works for both**: Microsoft's built-in SITs AND any custom SITs already created in your tenant

2. **Add to global-config.json** in the `BuiltInSITs` array:

   ```json
   {
     "Name": "Exact Name from Purview",
     "Enabled": true,
     "Priority": "High|Medium|Low",
     "Description": "Brief description for reference"
   }
   ```

3. **Example - Adding EU Data Protection SITs:**

   ```json
   {
     "Name": "EU Debit Card Number",
     "Enabled": true,
     "Priority": "High",
     "Description": "European debit card numbers"
   },
   {
     "Name": "EU Driver's License Number",
     "Enabled": false,
     "Priority": "Medium",
     "Description": "European driver's license formats"
   }
   ```

4. **Example - Adding Pre-Existing Custom SITs:**

   ```json
   {
     "Name": "Contoso Employee ID",
     "Enabled": true,
     "Priority": "High",
     "Description": "Custom SIT for employee identification numbers"
   },
   {
     "Name": "Custom Patient Record Number",
     "Enabled": true,
     "Priority": "High",
     "Description": "Healthcare-specific patient identifiers"
   }
   ```

5. **Set Enabled flag** based on your testing scenario:
   - `"Enabled": true` → Include in validation and DLP policy testing
   - `"Enabled": false` → Exclude from validation (documents may still contain this data type)

> **📚 Note on Custom SIT Creation**: This project does **NOT** cover creating new custom SITs from scratch. It assumes you're using Microsoft's built-in SITs or pre-existing custom SITs already created in your tenant. To learn how to create custom SITs, see the separate [Purview-Classification-Lifecycle-Labs](../../Purview-Classification-Lifecycle-Labs/) project.

**Reference**: [Microsoft Purview Sensitive Information Type Definitions](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)

## ✅ Validation

Verify lab completion by checking:

- [ ] **PowerShell modules verified** - PnP.PowerShell and ExchangeOnlineManagement installed
- [ ] **Directory structure created** - All directories from Paths section exist
- [ ] **Logging operational** - Log files created in LogDirectory
- [ ] **Configuration loaded** - Import-GlobalConfig.ps1 runs without errors
- [ ] **SharePoint sites reviewed** - Understand what will be created in Lab 01
- [ ] **Built-in SITs reviewed** - Understand targeted sensitive data types

## 🚧 Troubleshooting

### Issue: PowerShell Module Not Found

**Error**: `Module 'PnP.PowerShell' not found`

**Solution**:

```powershell
Install-Module -Name PnP.PowerShell -Scope CurrentUser -Force
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
```

### Issue: Insufficient Permissions

**Error**: `Access denied` or `Insufficient permissions` during script execution

**Solution**:

- Verify you have **SharePoint Administrator** role in Microsoft 365 Admin Center
- Verify you have **Compliance Administrator** role in Microsoft 365 Admin Center
- Contact your Global Administrator to grant required permissions
- The scripts will prompt for authentication automatically when needed

### Issue: Authentication Prompts Not Appearing

**Error**: Scripts fail with "You are not signed in" errors

**Solution**:

- Ensure pop-ups are enabled in your browser for Microsoft authentication pages
- Verify that `Import-PurviewModules.ps1` successfully loads the Connection-Management module
- Try running the script again - authentication prompts should appear automatically
- If issues persist, manually test connection: `Connect-PnPOnline -Url "https://yourtenant.sharepoint.com" -Interactive`

### Issue: Connectivity Failures

**Error**: `Unable to connect to SharePoint Online` or `Connection timeout`

**Solution**:

- Verify internet connectivity
- Check firewall/proxy settings allow Microsoft 365 connections
- Try disconnecting from VPN if applicable
- Ensure you're not behind restrictive network policies
- The scripts will automatically retry authentication if connection fails

### Issue: Disk Space Insufficient

**Error**: `Insufficient disk space for simulation scale`

**Solution**:

- Free up disk space (delete temporary files, empty recycle bin)
- Change simulation scale in global-config.json to **Small** (requires ~500 MB)
- Update **Paths.GeneratedDocumentsPath** to different drive with more space

### Issue: Configuration Validation Errors

**Error**: `Configuration validation failed: Missing required section: Environment`

**Solution**:

- Review global-config.json syntax (valid JSON format)
- Ensure all required sections present: Environment, Simulation, SharePointSites, BuiltInSITs, Paths, Logging
- Run JSON validator: `Get-Content global-config.json | ConvertFrom-Json` to check syntax
- Compare against template in project root: PORTABILITY-GUIDE.md

## 📚 Additional Resources

- [Microsoft Purview Information Protection Overview](https://learn.microsoft.com/en-us/purview/information-protection)
- [PnP PowerShell Documentation](https://pnp.github.io/powershell/)
- [Security & Compliance PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell)
- [SharePoint Online Limits](https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits)

## 🎓 Learning Objectives Achieved

After completing this lab, you have:

- ✅ Validated Microsoft 365 E5 licensing and administrator permissions
- ✅ Verified PowerShell module installation and versions
- ✅ Tested connectivity to SharePoint Online and Security & Compliance
- ✅ Initialized simulation directory structure and logging infrastructure
- ✅ Configured global-config.json for complete environment portability
- ✅ Reviewed SharePoint sites and SITs configuration for upcoming labs
- ✅ Prepared your environment for automated simulation execution

## 🚀 Next Steps

You have successfully completed the prerequisites setup and your environment is ready for the Purview Data Governance Simulation. Your global configuration is centralized, your directory structure is initialized, and logging is operational.

Proceed to **Lab 01: SharePoint Site Creation** to create the simulated SharePoint sites that will host test content. Lab 01 will use the site definitions you reviewed in Step 4 to automatically create Team sites for each department.

```powershell
# Navigate to Lab 01 and create SharePoint sites
cd ..\01-SharePoint-Site-Creation
.\scripts\New-SimulatedSharePointSites.ps1
```

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview best practices and PowerShell automation standards.

*AI tools were used to enhance productivity and ensure comprehensive coverage of prerequisites validation while maintaining technical accuracy.*
