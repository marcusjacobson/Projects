# Lab 0: Prerequisites & Time-Sensitive Setup

## 🎯 Lab Overview

This foundational lab establishes all prerequisites and initiates time-sensitive background operations that enable seamless progression through the remaining labs. By front-loading SharePoint site creation, initial data indexing, placeholder SIT creation, and retention label initialization, you'll eliminate active waiting periods and maximize your hands-on learning time.

**Critical Success Factor**: Complete this lab FIRST before proceeding to any other lab. The background processes initiated here (15-30 minutes for SharePoint indexing, up to 7 days for retention label activation) run while you work through Labs 1-4, ensuring you never have to stop and wait.

**Time Investment**: 30-45 minutes active work | Background processing continues during subsequent labs

---

## 📋 Learning Objectives

By completing Lab 0, you will:

- **Validate environment readiness**: Verify Microsoft 365 E5 licensing, admin permissions, and PowerShell module requirements
- **Establish SharePoint foundation**: Create test site and upload sample documents that trigger automatic background indexing
- **Initialize time-sensitive operations**: Create placeholder SITs and retention labels that process in the background during Labs 1-4
- **Understand timing optimization**: Learn why front-loading setup eliminates active waiting in classification and retention labs
- **Prepare for parallel learning**: Enable flexible lab completion (accelerated 2-3 days or production deployment over 1-2 weeks)

---

## ⏱️ Time Optimization Strategy

✅ **Lab 0**: Create SharePoint site + Upload data + Create retention labels → **Continue immediately to Lab 1**  
✅ **Labs 1-2**: Learn custom SITs (regex, keywords, EDM) while background processing completes  
✅ **Lab 3**: Validate classification results (indexing complete by now - no waiting!)  
✅ **Lab 4**: Use retention labels (simulation mode if fast, production mode if 7+ days elapsed)  
✅ **Total Delays**: ZERO active waiting - all background processing runs while you learn

---

## 🚀 Prerequisites Validation

### Required Licensing

**Microsoft 365 E5 OR Microsoft 365 E5 Compliance Add-On**:

- Required for advanced custom SITs (regex-based, EDM)
- Required for retention labels with auto-apply policies
- Required for On-Demand Classification
- Required for Content Explorer and Activity Explorer

**How to Verify**:

Navigate to Microsoft 365 Admin Center → **Billing** → **Licenses**

Look for active licenses:

- Microsoft 365 E5 (includes all features)
- Microsoft 365 E5 Compliance (if using E3 base + compliance add-on)

### Required Permissions

**Compliance Administrator OR Global Administrator Role**:

- Required to create Sensitive Information Types
- Required to configure retention labels and auto-apply policies
- Required to access Microsoft Purview Compliance Portal
- Required to execute PowerShell cmdlets against Security & Compliance

**How to Verify**:

```powershell
# Connect to Azure AD to check roles
Connect-AzureAD

# Get your role assignments
Get-AzureADDirectoryRoleMembership -ObjectId (Get-AzureADUser -ObjectId "your-admin@yourtenant.onmicrosoft.com").ObjectId | 
    Get-AzureADDirectoryRole | 
    Select-Object DisplayName
```

Expected output should include:

- `Compliance Administrator` OR `Global Administrator`

### Required PowerShell Modules

#### Understanding PowerShell 7 Module Path Behavior

**The Issue**: PowerShell 7 hardcodes `$HOME\Documents\PowerShell\Modules` as the first module search path. If your organization syncs Documents to OneDrive and applies DLP policies blocking script execution from cloud locations, you'll encounter authentication failures and governance blocks.

**The Solution**: Use `-Scope AllUsers` to install modules outside your user profile, or add a local path to your session if you don't have admin rights.

---

#### Module Installation: Choose Your Method

> **✅ Using Method 1**: This lab environment uses **Method 1** (AllUsers scope) to install modules to `C:\Program Files\PowerShell\Modules`, avoiding OneDrive sync restrictions.

**Method 1: Install to AllUsers Scope** (Recommended - requires admin rights):

This installs modules to `C:\Program Files\PowerShell\Modules`, which is NOT affected by OneDrive sync:

```powershell
# Run PowerShell as Administrator
Install-Module -Name ExchangeOnlineManagement -Scope AllUsers -Force -Repository PSGallery
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope AllUsers -Force -Repository PSGallery

# Optional: PnP PowerShell (for advanced bulk operations in Lab 5)
Install-Module -Name PnP.PowerShell -Scope AllUsers -Force -Repository PSGallery

# Verify installations
Get-Module -Name ExchangeOnlineManagement, Microsoft.Online.SharePoint.PowerShell, PnP.PowerShell -ListAvailable | 
    Select-Object Name, Version, Path
```

**Expected Output**:

```
Name                                    Version   Path
----                                    -------   ----
ExchangeOnlineManagement                3.9.0     C:\Program Files\PowerShell\Modules\ExchangeOnlineManagement\3.9.0\...
Microsoft.Online.SharePoint.PowerShell  16.x.x    C:\Program Files\PowerShell\Modules\Microsoft.Online.SharePoint.PowerShell\...
PnP.PowerShell                          2.x.x     C:\Program Files\PowerShell\Modules\PnP.PowerShell\...
```

---

**Method 2: Local Directory with Session Path** (No admin rights required):

If you can't use admin rights, create a local directory and add it to your PowerShell session each time:

```powershell
# One-time setup: Create local modules directory
$localModulesPath = "C:\PowerShellModules"
New-Item -Path $localModulesPath -ItemType Directory -Force | Out-Null

# Download modules to temp location (faster than installing directly)
$tempPath = "$env:TEMP\TempModules"
Save-Module -Name ExchangeOnlineManagement -Path $tempPath -Repository PSGallery -Force
Save-Module -Name Microsoft.Online.SharePoint.PowerShell -Path $tempPath -Repository PSGallery -Force

# Copy to local directory
Copy-Item -Path "$tempPath\ExchangeOnlineManagement" -Destination $localModulesPath -Recurse -Force
Copy-Item -Path "$tempPath\Microsoft.Online.SharePoint.PowerShell" -Destination $localModulesPath -Recurse -Force
Remove-Item -Path $tempPath -Recurse -Force

# IMPORTANT: Add this command to every PowerShell session before using the modules
$env:PSModulePath = "C:\PowerShellModules;" + $env:PSModulePath

# Verify modules are available
Get-Module -Name ExchangeOnlineManagement, Microsoft.Online.SharePoint.PowerShell -ListAvailable | 
    Select-Object Name, Version, Path
```

> **💡 Automation Tip**: Add the path setup command to your PowerShell profile so it runs automatically:
>
> ```powershell
> # Add to profile (one-time)
> Add-Content -Path $PROFILE.CurrentUserCurrentHost -Value '$env:PSModulePath = "C:\PowerShellModules;" + $env:PSModulePath'
> ```

---

#### Troubleshooting: Relocating Existing OneDrive Modules

If you previously installed modules to OneDrive-synced locations:

```powershell
# Check current module locations
Get-Module -Name ExchangeOnlineManagement -ListAvailable | Select-Object Name, Version, Path

# If path shows OneDrive location (e.g., C:\Users\YourName\OneDrive\Documents\PowerShell\Modules)
# Uninstall from that location
Uninstall-Module -Name ExchangeOnlineManagement -AllVersions -Force
Uninstall-Module -Name Microsoft.Online.SharePoint.PowerShell -AllVersions -Force

# Then reinstall using Method 1 or Method 2 above
```

---

## 📝 Lab Exercises

### Exercise 1: Automated Prerequisites Validation

**Objective**: Run automated validation script to verify all prerequisites are met before proceeding.

**Function**: `Test-PurviewPrerequisites` (from Shared-Utilities module)

**What It Validates**:

- Microsoft 365 E5 or E5 Compliance licensing
- Compliance Administrator or Global Administrator role assignment
- PowerShell module versions (ExchangeOnlineManagement 3.0+, SharePoint Online Management Shell)
- Security & Compliance PowerShell connectivity
- SharePoint Admin Center access
- Microsoft Purview Compliance Portal access

**How to Run**:

```powershell
# Import the Shared-Utilities module
Import-Module "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\Shared-Utilities\PurviewUtilities.psm1" -Force

# Run prerequisites validation
Test-PurviewPrerequisites -RequiredModules @(
    @{ Name = "ExchangeOnlineManagement"; MinVersion = "3.0.0" }
    @{ Name = "Microsoft.Online.SharePoint.PowerShell"; MinVersion = "16.0.0" }
) -Verbose
```

**Expected Output**:

```text
✅ License Validation: Microsoft 365 E5 detected
✅ Permission Validation: Compliance Administrator role assigned
✅ Module Validation: ExchangeOnlineManagement v3.4.0 installed
✅ Module Validation: SharePoint Online Management Shell v16.0.24211.12000 installed
✅ Connectivity Validation: Security & Compliance PowerShell connection successful
✅ Portal Access Validation: Microsoft Purview Compliance Portal accessible

🎯 All prerequisites validated successfully! Ready to proceed with Lab 0 setup.
```

**Troubleshooting**:

If validation fails, the script provides specific remediation steps:

- Missing license → Link to Microsoft 365 Admin Center trial activation
- Insufficient permissions → Instructions for role assignment
- Outdated modules → PowerShell commands to update modules
- Connectivity issues → Authentication and MFA troubleshooting guidance

---

### Exercise 2: SharePoint Test Site Creation & Initial Indexing

**Objective**: Create SharePoint Online test site and upload sample documents to trigger automatic background indexing (15-30 minutes).

**Script**: `Initialize-SharePointTestSite.ps1`

**What It Does**:

1. **Creates SharePoint Communication Site**: "Purview Classification Lab"
2. **Creates document library structure**: Finance, HR, Projects folders
3. **Generates sample documents**: 20 files with embedded sensitive data patterns
   - Credit card numbers (Visa, Mastercard, American Express formats)
   - Social Security Numbers (valid format with checksum)
   - Email addresses and phone numbers
   - Employee IDs (placeholder patterns for Lab 1 custom SIT validation)
   - Customer numbers (placeholder patterns for Lab 1 custom SIT validation)
4. **Uploads files to SharePoint**: Triggers automatic SharePoint indexing
5. **Returns site URL**: For use in subsequent labs

**How to Run**:

```powershell
# Navigate to Lab 0 scripts directory
cd C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\00-Prerequisites-Setup\scripts

# Run SharePoint site initialization
.\Initialize-SharePointTestSite.ps1 -Verbose
```

The script will prompt you for:
- **Tenant name**: e.g., `contoso` (from contoso.sharepoint.com)
- The script automatically creates the site at: `https://yourtenant.sharepoint.com/sites/PurviewClassificationLab`

**Parameters**:

- `Verbose`: Show detailed progress during execution

**Expected Output**:

```text
🚀 Creating SharePoint Communication Site: Purview Classification Lab
   ✅ Site created: https://yourtenant.sharepoint.com/sites/PurviewClassificationLab

📋 Creating document library structure...
   ✅ Finance folder created
   ✅ HR folder created  
   ✅ Projects folder created

📄 Generating sample documents with embedded sensitive data...
   ✅ Created 20 sample files in C:\PurviewLabs\Lab0-SampleData\

📤 Uploading files to SharePoint...
   ✅ Uploaded 6 files to Finance folder
   ✅ Uploaded 7 files to HR folder
   ✅ Uploaded 7 files to Projects folder

⏱️ Background Indexing Started: SharePoint will index these documents over the next 15-30 minutes.
   Continue to Exercise 3 immediately - no need to wait!

🎯 Site URL: https://yourtenant.sharepoint.com/sites/PurviewClassificationLab
   Save this URL - you'll use it in Labs 1, 3, 4, and 5.
```

**Background Processing Initiated**:

- ⏱️ **SharePoint indexing**: 15-30 minutes for 20 documents
- ⏱️ **Classification readiness**: Documents will be ready for Lab 3 validation
- ✅ **No active waiting required**: Continue immediately to Exercise 3

---

### Exercise 3: Placeholder Custom SIT Creation

**Objective**: Create simple placeholder custom SITs in the **Microsoft Purview Compliance Portal** that will be enhanced in Lab 1, triggering background replication (5-15 minutes).

**Where SITs Are Created**: Custom Sensitive Information Types are created and managed in the **Microsoft Purview Compliance Portal** under **Data Classification** → **Classifiers** → **Sensitive info types**. The script uses Security & Compliance PowerShell to automate creation, which is functionally equivalent to manual creation through the portal UI.

**Script**: `Create-PlaceholderSITs.ps1`

**What It Does**:

1. **Creates 3 placeholder regex-based custom SITs**:
   - **Contoso Employee ID**: Pattern `EMP-\d{4}-\d{4}` (matches sample data from Exercise 2)
   - **Contoso Customer Number**: Pattern `CUST-\d{6}` (matches sample data from Exercise 2)
   - **Contoso Project Code**: Pattern `PROJ-\d{4}-\d{4}` (basic pattern for Lab 1 enhancement)

2. **Configures basic settings**:
   - Low confidence threshold (65%) for initial testing
   - Minimal keywords for basic context validation
   - Enabled for immediate availability

3. **Triggers background replication**: SITs replicate globally within 5-15 minutes

**How to Run**:

```powershell
# Navigate to Lab 0 scripts directory
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\00-Prerequisites-Setup\scripts"

# Run placeholder SIT creation
.\Create-PlaceholderSITs.ps1 -Verbose
```

**Expected Output**:

```text
🔐 Creating Placeholder Custom SITs...

✅ Created: Contoso Employee ID
   Pattern: EMP-\d{4}-\d{4}
   Confidence: Low (65%)
   Status: Enabled

✅ Created: Contoso Customer Number
   Pattern: CUST-\d{6}
   Confidence: Low (65%)
   Status: Enabled

✅ Created: Contoso Project Code
   Pattern: PROJ-\d{4}-\d{4}
   Confidence: Low (65%)
   Status: Enabled

⏱️ Background Replication Started: Custom SITs will be available globally in 5-15 minutes.
   Continue to Exercise 4 immediately - no need to wait!

💡 Lab 1 Enhancement: In Lab 1, you'll enhance these SITs with advanced regex patterns,
   keyword dictionaries, and multi-level confidence scoring (High/Medium/Low).
```

**Why Placeholder SITs?**:

- Initiates background replication early (runs during Labs 1-2)
- Provides basic patterns to test against sample data in Lab 3
- Serves as foundation for Lab 1 enhancements (keywords, confidence tuning)
- Demonstrates SIT lifecycle (create → enhance → production deployment)

**Troubleshooting**:

**Issue**: Authentication error: "Unable to load DLL 'msalruntime'"

**Solution**: This is a known issue with Web Account Manager (WAM) on some Windows systems. The script uses modern browser-based authentication to bypass this issue. If you still see authentication failures:

- Verify you have **Compliance Administrator** or **Global Administrator** role
- Ensure **ExchangeOnlineManagement** module v3.0+ is installed: `Get-Module -Name ExchangeOnlineManagement -ListAvailable`
- Try updating the module: `Update-Module -Name ExchangeOnlineManagement -Force`
- If browser authentication doesn't open, check if pop-ups are blocked or try running `Connect-IPPSSession` manually in a separate PowerShell window first

**Issue**: "Duplicate name" error when creating SITs

**Solution**: SITs with these names already exist. Run the cleanup script first:

```powershell
.\Remove-PlaceholderSITs.ps1 -Verbose
```

---

### Exercise 4: Initial Retention Label Configuration

**Objective**: Create initial retention labels to trigger 7-day activation period for Lab 4 production deployment.

**Script**: `Initialize-RetentionLabels.ps1`

**What It Does**:

1. **Creates 3 foundational retention labels**:
   - **Financial Records - 7 Years**: Retention from creation date, auto-delete after 7 years
   - **HR Documents - 5 Years**: Retention from labeled date, disposition review after 5 years (reviewer email configured via portal)
   - **General Business - 3 Years**: Retention from modified date, auto-delete after 3 years

2. **Creates auto-apply policies**:
   - Links labels to placeholder SITs from Exercise 3
   - Policies created in production mode by default
   - **Important**: Enable simulation mode manually in Purview portal before activating policies

3. **Triggers background processing**:
   - ⏱️ **Policy deployment**: 5-10 minutes for policies to activate
   - ⏱️ **Simulation mode**: Enable in portal for 1-2 day preview before production
   - ⏱️ **Production activation**: Up to 7 days for full label application

**How to Run**:

```powershell
# Navigate to Lab 0 scripts directory
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\00-Prerequisites-Setup\scripts"

# Run retention label initialization
.\Initialize-RetentionLabels.ps1 -EnableSimulationMode -Verbose
```

**Parameters**:

- `EnableSimulationMode`: Parameter present but simulation mode must be enabled manually via portal (PowerShell doesn't support this parameter)
- `Verbose`: Show detailed progress during execution

**Expected Output**:

```text
🏷️ Creating Initial Retention Labels...

✅ Created: Financial Records - 7 Years
   Retention: 7 years from creation date
   Action: Delete automatically after 7 years
   Scope: SharePoint, OneDrive, Exchange

✅ Created: HR Documents - 5 Years
   Retention: 5 years from labeled date
   Action: Disposition review after 5 years
   Scope: SharePoint, OneDrive

✅ Created: General Business - 3 Years
   Retention: 3 years from modification date
   Action: Delete automatically after 3 years
   Scope: SharePoint, OneDrive, Exchange

📋 Creating Auto-Apply Policies...

✅ Policy Created: Auto-Apply Financial Records (background deployment in progress)
   Trigger: Contoso Customer Number SIT detected
   ⚠️  Enable simulation mode via Purview portal before activating
   Production: Up to 7 days for full deployment

✅ Policy Created: Auto-Apply HR Documents (background deployment in progress)
   Trigger: Contoso Employee ID SIT detected
   ⚠️  Enable simulation mode via Purview portal before activating
   Production: Up to 7 days for full deployment

✅ Policy Created: Auto-Apply General Business (background deployment in progress)
   Trigger: Contoso Project Code SIT detected
   ⚠️  Enable simulation mode via Purview portal before activating
   Production: Up to 7 days for full deployment

⏱️ Background Processing Timeline:
   Policies created - enable simulation mode via portal for 1-2 day preview
   7 days: Full production label application (if activated)

💡 Lab 4 Flexibility:
   - Enable simulation mode in Purview portal for safe testing
   - Fast completion (2-3 days): Work in simulation mode, understand concepts
   - Production deployment (7+ days): See full label application in action
   - Both paths provide complete learning experience!

🎯 Next Step: Proceed immediately to Lab 1 - Custom SITs (Regex & Keywords)
   No waiting required! Background processing continues while you learn.
```

**Troubleshooting**:

**Issue**: "Duplicate name" error when creating retention labels or policies

**Solution**: Retention labels or policies with these names already exist from a previous run. Use the cleanup script to remove them first:

```powershell
.\Remove-RetentionLabels.ps1 -Verbose
```

**Note**: Retention policy and label removal occurs via background deployment. After running the cleanup script, wait 5-10 minutes for changes to fully propagate before re-running `Initialize-RetentionLabels.ps1`.

**Issue**: "ReviewerEmail recipient not found" error

**Solution**: The script has been updated to create labels without reviewer email. If you need disposition review functionality, configure reviewer email addresses manually in the Purview portal after label creation.

---

## ✅ Lab 0 Completion Checklist

Before proceeding to Lab 1, verify the following:

### Prerequisites Validated

- [ ] **Microsoft 365 E5 or E5 Compliance licensing confirmed**
- [ ] **Compliance Administrator or Global Administrator role assigned**
- [ ] **ExchangeOnlineManagement module v3.0+ installed**
- [ ] **SharePoint Online Management Shell installed**
- [ ] **Test-PurviewPrerequisites function passed all validation checks**

### SharePoint Foundation Established

- [ ] **SharePoint Communication Site created**: "Purview Classification Lab"
- [ ] **Document library structure created**: Finance, HR, Projects folders
- [ ] **Sample documents uploaded**: 20 files with embedded sensitive data
- [ ] **Site URL documented**: Save for use in Labs 1, 3, 4, 5
- [ ] **Background indexing initiated**: 15-30 minute processing started

### Placeholder SITs Created

- [ ] **Contoso Employee ID SIT created**: Pattern `EMP-\d{4}-\d{4}`
- [ ] **Contoso Customer Number SIT created**: Pattern `CUST-\d{6}`
- [ ] **Contoso Project Code SIT created**: Pattern `PROJ-\d{4}-\d{4}`
- [ ] **SIT replication initiated**: 5-15 minute global replication started

### Initial Retention Labels Configured

- [ ] **Financial Records - 7 Years label created**
- [ ] **HR Documents - 5 Years label created**
- [ ] **General Business - 3 Years label created**
- [ ] **Auto-apply policies created**: Enable simulation mode via Purview portal
- [ ] **Background processing initiated**: Policies deployed, ready for portal configuration

---

## 🔍 Validation & Troubleshooting

### Validation Steps

**Verify SharePoint Site Creation**:

```powershell
# Connect to SharePoint Online
Connect-SPOService -Url "https://yourtenant-admin.sharepoint.com"

# List sites to verify creation
Get-SPOSite -Identity "https://yourtenant.sharepoint.com/sites/PurviewClassificationLab" | 
    Select-Object Url, Title, Status
```

Expected: Site URL and Title displayed with Status = "Active"

**Verify Custom SIT Creation**:

```powershell
# Connect to Security & Compliance PowerShell
Connect-IPPSSession -UserPrincipalName your-admin@yourtenant.onmicrosoft.com

# List custom SITs
Get-DlpSensitiveInformationType | 
    Where-Object {$_.Publisher -eq "yourtenant.onmicrosoft.com"} |
    Select-Object Name, Publisher, State
```

Expected: 3 custom SITs listed with State = "Enabled"

**Verify Retention Label Creation**:

```powershell
# List retention labels
Get-ComplianceTag | 
    Select-Object Name, RetentionDuration, RetentionAction | 
    Format-Table -AutoSize
```

Expected: 3 retention labels listed with correct retention periods (2555 days for 7 years, etc.)

### Common Issues

**Issue**: SharePoint site creation fails with "Access Denied"

**Solution**:

- Verify SharePoint Administrator or Global Administrator role
- Check if your account has SharePoint Online license assigned
- Try using SharePoint Admin Center UI as fallback: https://yourtenant-admin.sharepoint.com

**Issue**: Custom SIT creation fails with "Duplicate name" error

**Solution**:

- Custom SITs with same name already exist from previous attempt
- Navigate to Lab 0 scripts directory and run cleanup script:
  
  ```powershell
  cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\00-Prerequisites-Setup\scripts"
  .\Remove-PlaceholderSITs.ps1
  ```

- Re-run Exercise 3 with fresh SIT creation

**Issue**: Retention label creation fails with licensing error

**Solution**:

- Verify Microsoft 365 E5 or E5 Compliance license is assigned to your account
- Check in Microsoft 365 Admin Center → **Users** → **Active users** → Your account → **Licenses**
- Wait 15-30 minutes after license assignment for activation

---

## ⏭️ Next Steps

**Congratulations!** You've completed Lab 0 and initiated all time-sensitive background operations. Here's what happens next:

### Background Processing Timeline

**During Labs 1-2 (Next 4-6 Hours Active Work)**:

- ⏱️ SharePoint indexing completes (15-30 minutes) → Ready for Lab 3
- ⏱️ Custom SIT replication completes (5-15 minutes) → Ready for Lab 1 enhancements
- ⏱️ Retention policy deployment completes (5-10 minutes) → Ready for portal configuration

**After Labs 1-4 (If Completing Over 7+ Days)**:

- ⏱️ Enable simulation mode in portal → 1-2 days for preview results
- ⏱️ Retention labels fully activated (7 days after enabling) → Ready for Lab 4 production validation

### Recommended Next Steps

**Immediate Action** (No Waiting):

Proceed directly to **Lab 1: Custom Sensitive Information Types (Regex & Keywords)**:

- Enhance placeholder SITs from Lab 0 with advanced patterns
- Add keyword dictionaries for context-aware detection  
- Configure multi-level confidence scoring (High/Medium/Low)
- Test enhanced SITs against local sample files

**No Waiting Required**: Lab 1 has zero time delays and can be completed immediately while background processing from Lab 0 continues.

**Learning Path Options**:

**Path A: Accelerated Learning (2-3 Days Total)**:

- Complete Labs 0-2 on Day 1 (5-6 hours)
- Complete Labs 3-4 on Day 2 (simulation mode for retention labels, 4-5 hours)
- Complete Labs 5-6 on Day 3 (automation and documentation, 5-6 hours)
- **Result**: Full technical knowledge, retention labels in simulation mode

**Path B: Production Deployment (1-2 Weeks Total)**:

- Week 1: Complete Labs 0-2 (5-6 hours spread over 2-3 days)
- Week 1: Complete Lab 3 (2 hours - classification validation)
- Wait 7 days for retention label activation
- Week 2: Complete Lab 4 with production labels (2 hours)
- Week 2: Complete Labs 5-6 (5-6 hours spread over 2-3 days)
- **Result**: Full production deployment with activated retention labels

---

## 📚 Additional Resources

**Microsoft Learn Documentation**:

- [Plan for Microsoft Purview Information Protection](https://learn.microsoft.com/en-us/purview/information-protection)
- [Get started with sensitivity labels](https://learn.microsoft.com/en-us/purview/get-started-with-sensitivity-labels)
- [Learn about retention policies and retention labels](https://learn.microsoft.com/en-us/purview/retention)
- [SharePoint Online service description](https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-service-description)

**PowerShell References**:

- [Connect to Security & Compliance PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell)
- [Connect to SharePoint Online PowerShell](https://learn.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online)
- [ExchangeOnlineManagement module](https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2)

**Community Resources**:

- [Microsoft Tech Community - Purview](https://techcommunity.microsoft.com/t5/security-compliance-and-identity/bd-p/MicrosoftSecurityandCompliance)
- [Purview Blog](https://techcommunity.microsoft.com/t5/security-compliance-and-identity/bg-p/SecurityandComplianceBlog)

---

## 🤖 AI-Assisted Content Generation

This Lab 0 prerequisites and time-sensitive setup guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview Information Protection best practices, time optimization strategies validated against the successful Purview-Skills-Ramp-OnPrem-and-Cloud project architecture, and enterprise deployment patterns for efficient lab progression.

*AI tools were used to enhance productivity and ensure comprehensive coverage of prerequisite validation while maintaining technical accuracy and reflecting best practices for front-loading time-sensitive operations to eliminate active waiting periods in subsequent labs.*
