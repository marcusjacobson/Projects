# Data Foundation: Multi-Workload Test Data Deployment

> **✅ Prerequisites**: Complete **00-Prerequisites** to configure service principal authentication and global configuration settings.
>
> **👥 Test Users**: If you don't have test users with M365 E5 licenses, see [User Setup Guide](../00-Prerequisites/User-Setup-Guide.md) to create them in Entra ID.

## 🎯 What You're Creating and Deploying

This lab generates **16 comprehensive test files** in native Microsoft Office formats and deploys them across **multiple M365 workloads** for comprehensive DLP and classification testing:

### M365 Workload Coverage

- **SharePoint Online**: Team site document library (organizational content)
- **OneDrive for Business**: Individual user storage (personal files)
- **Microsoft Teams**: Team channels with file attachments (collaboration scenarios)

This multi-workload approach enables testing of:

- **Cross-workload DLP policies** (same file in different locations)
- **User-scoped policies** (department-based restrictions)
- **Sharing scenarios** (internal collaboration vs external sharing)
- **Classification consistency** (labels applied across workloads)

### Test File Categories

**Single-SIT Files (4 files)** - Isolated testing:

- **CreditCards-Only.xlsx** - Credit card numbers only (Luhn-valid)
- **SSN-Records.docx** - Social Security Numbers only
- **Banking-DirectDeposit.xlsx** - ABA routing numbers only
- **Loyalty-Program-Members.docx** - Custom loyalty IDs (RET-XXXXXX-X pattern)

**Multi-SIT Files (6 files)** - Complex scenarios:

- **CustomerDatabase-FULL.xlsx** - ALL SITs (CC, SSN, Banking, Loyalty, PII)
- **Payment-Processing-Report.docx** - Credit cards + ABA routing numbers
- **Payment-Processing-Report.pdf** - Same content as DOCX, PDF format
- **Customer-Profile-Export.docx** - PII + SSN + Loyalty IDs
- **Q4-Financial-Review.pptx** - CC + SSN + Banking + Loyalty (presentation format)
- **Retail-Financial-Data.xlsx** - Multi-sheet workbook with various SIT combinations

**Clean Control Files (3 files)** - False positive testing:

- **Product-Catalog.xlsx** - Product inventory (no sensitive data)
- **Team-Meeting-Notes.docx** - Meeting notes (no sensitive data)
- **Q1-Sales-Strategy.pptx** - Sales presentation (no sensitive data)

**Document Fingerprinting Templates (3 files)** - Structure-based detection:

- **Credit-Card-Application-Form.docx** - Standardized credit card application template
- **Employee-Onboarding-Form.docx** - HR employee onboarding template
- **Store-Audit-Report-Template.xlsx** - Retail compliance audit template

### Sensitive Information Types Included

All files use **30 realistic customer records** with:    

- **Luhn-Valid Credit Cards** (Visa, Mastercard, Amex, Discover)
- **Realistic SSNs** (avoiding invalid patterns: 000-xx-xxxx, xxx-00-xxxx, 666-xx-xxxx)
- **ABA Routing Numbers** (with valid checksums)
- **Custom Loyalty IDs** (RET-XXXXXX-X pattern for custom SIT testing)
- **PII** (names, emails, phone numbers, addresses)

This comprehensive test data will trigger:

- **Auto-labeling policies** (various SIT detection combinations)
- **DLP policies** (single and multi-SIT scenarios)
- **Content Explorer classification**
- **Custom SIT validation** (Loyalty IDs)
- **Document Fingerprinting** (structure-based form detection)
- **Named Entity detection** (ML-based PII identification)

## 📍 SharePoint Site Architecture

This lab creates a dedicated **Retail Operations** SharePoint Team Site for DLP testing:

| Component | Value | Purpose |
|-----------|-------|---------|
| **Site Name** | `Retail-Operations` | URL-safe site identifier |
| **Site Title** | `Retail Operations - DLP Testing` | Display name in SharePoint |
| **Site Type** | Team Site | Collaborative document library |
| **Owner** | Admin email from config | Site collection administrator |
| **Document Library** | `Shared Documents` | Default document storage location |

> **📝 Configuration**: All site details are defined in `templates/global-config.json` under the `sharePointSite` section.

## 🧪 Lab Instructions

### Step 0: Validate Test Users (Multi-Workload Testing)

**If you plan to test OneDrive and Teams**, validate that your test users are properly configured.

```powershell
cd scripts

.\Test-M365Users.ps1
```

**What this validates**:

- Users exist in Entra ID with UPNs from `global-config.json`
- M365 E5 or E5 Compliance licenses are assigned
- OneDrive, Teams, and Exchange services are enabled
- Users are ready for file uploads across workloads

**Expected output**:

```text
✅ finance1@marcusj-dev.cloud
   📧 Licensed: SPE_E5
   📁 OneDrive: Provisioned
   👥 Teams: Enabled

✅ sales1@marcusj-dev.cloud
   📧 Licensed: SPE_E5
   📁 OneDrive: Provisioned
   👥 Teams: Enabled

📊 Summary: 3 of 3 users ready for multi-workload testing
```

> **💡 Note**: If you only plan to test SharePoint (not OneDrive/Teams), you can skip this step and proceed directly to Step 1.

### Step 1: Configure global-config.json

Before running scripts, ensure your configuration file is properly set up:

**Location**: `templates/global-config.json`

**Required Settings**:

```json
{
  "tenantId": "your-tenant-id-guid",
  "sharePointRootUrl": "https://yourtenant.sharepoint.com",
  "sharePointSite": {
    "name": "Retail-Operations",
    "title": "Retail Operations - DLP Testing",
    "owner": "admin@yourtenant.onmicrosoft.com"
  },
  "testUsers": [
    "user1@yourtenant.onmicrosoft.com",
    "user2@yourtenant.onmicrosoft.com",
    "user3@yourtenant.onmicrosoft.com"
  ],
  "servicePrincipal": {
    "appId": "your-app-id-guid",
    "certificateName": "PurviewAutomationCert"
  }
}
```

> **💡 Test Users**: For OneDrive/Teams testing, add 2-3 users with M365 E5 licenses. See [User Setup Guide](../00-Prerequisites/User-Setup-Guide.md) if you need to create users. 
> **Note** - If M365 licenses are not available for users in your tenant, ignore this configuration.

### Step 2: Generate Test Files

Generate all 13 test files with realistic sensitive data:

```powershell
.\Generate-TestData.ps1
```

**What happens**:

- Initializes Microsoft Office COM objects (Excel, Word, PowerPoint)
- Generates 30 customer records with Luhn-valid credit cards, realistic SSNs, ABA routing numbers
- Creates 13 files in `data-templates/` directory:
  - 5 Excel workbooks (.xlsx)
  - 5 Word documents (.docx)
  - 1 PDF document (.pdf)
  - 2 PowerPoint presentations (.pptx)

**Expected output**:

```text
✅ Microsoft Excel COM object loaded
✅ Microsoft Word COM object loaded
✅ Microsoft PowerPoint COM object loaded
✅ Generated 30 customer records with realistic data
✅ Created: CreditCards-Only.xlsx (Credit Card SIT only)
✅ Created: SSN-Records.docx (SSN SIT only)
...
📈 Total Files Generated: 13
📂 Output Location: C:\...\data-templates
```

> **⚠️ Requirements**: Requires Microsoft Office installed (Excel, Word, PowerPoint). Script uses COM automation - no PowerShell modules needed.

### Step 2a: Generate Custom SIT and EDM Test Data

Generate two specialized CSV files for **Custom SIT testing** and **EDM classifier creation**:

```powershell
.\Generate-CustomSitTestData.ps1
```

**What happens**:

- Generates **two CSV files** with customer data for different testing purposes:
  - **CustomerDB_TestData.csv** (8 fields, 5 customers) - Custom SIT keyword proximity testing
  - **CustomerDB_EDM.csv** (7 fields, 3 customers) - EDM wizard schema creation
- Creates both files in `..\.\Output\` directory
- TestData includes **MembershipType** column with keyword-rich values ("Rewards Member", "Loyalty Gold", etc.)
- EDM file excludes MembershipType for streamlined EDM schema definition

**Expected output**:

```text
📋 Generating Custom SIT and EDM Test Data
===========================================

🔸 Section 1: Custom SIT Test Data (Keyword Proximity Testing)
   📁 Output: ..\Output\CustomerDB_TestData.csv
   ✅ Generated 5 customer records
   📋 8 fields (includes MembershipType for keyword testing)

🔸 Section 2: EDM Test Data (Schema Creation)
   📁 Output: ..\Output\CustomerDB_EDM.csv
   ✅ Generated 3 customer records  
   📋 7 fields (streamlined for EDM wizard)

📊 Summary
===========
✅ CustomerDB_TestData.csv: 8 fields, 5 rows
   Use for: Lab 01 Custom SIT testing (keyword proximity)

✅ CustomerDB_EDM.csv: 7 fields, 3 rows
   Use for: Lab 02 EDM wizard upload (schema creation)
```

> **📝 Note**: This script generates **two distinct CSV files** for different lab purposes:
>
> - **CustomerDB_TestData.csv** (8 fields): Used in **Lab 01 (Custom SIT)** for keyword proximity testing with MembershipType column containing keywords like "Rewards", "Loyalty", "Points"
> - **CustomerDB_EDM.csv** (7 fields): Used in **Lab 02 (EDM Classifiers)** for EDM wizard schema creation, excludes MembershipType for streamlined schema definition
>
> The 7-field EDM file is deliberately smaller (3 customers vs 5) to simplify wizard upload and schema validation. Both files share the same 7 core fields: CustomerId, FirstName, LastName, Email, PhoneNumber, CreditCardNumber, LoyaltyId.

### Step 3: Create the Retail Operations SharePoint Site

```powershell
.\New-RetailSite.ps1
```

**What happens**:

- Loads configuration from `global-config.json`
- Connects to SharePoint using service principal with certificate authentication
- Creates new Team Site: `https://yourtenant.sharepoint.com/sites/Retail-Operations`
- Provisions default `Shared Documents` library
- Validates site creation and accessibility

**Expected output**:

```text
✅ Configuration loaded
   📋 Tenant: https://yourtenant.sharepoint.com
✅ Found certificate (expires: MM/DD/YYYY)
✅ Connected to SharePoint with service principal
🚀 Creating site (may take 1-2 minutes)...
✅ Site created successfully!
```

> **⏱️ Timing**: Site creation takes 1-2 minutes. If site already exists, script detects it and continues.

### Step 4: Upload Test Files to SharePoint

```powershell
.\Upload-TestDocs.ps1
```

**What happens**:

- Validates all 13 test files in `data-templates/` directory
- Connects to Retail Operations SharePoint site using service principal
- Uploads all files to `Shared Documents` library
- Checks for duplicates and skips already-uploaded files

**Expected output**:

```text
✅ Found 13 test files to upload
   📄 Banking-DirectDeposit.xlsx (0.01 MB)
   📄 CreditCards-Only.xlsx (0.01 MB)
   ...
✅ Connected to SharePoint with service principal
✅ Site validated: Retail Operations - DLP Testing
📤 Uploading Banking-DirectDeposit.xlsx...
   ✅ Uploaded successfully
...
📊 Upload Summary
   Total Files:    13
   ✅ Uploaded:    13
   ⚠️  Skipped:    0
```

---

> **⚠️ IMPORTANT: Multi-Workload Testing Requirements**
>
> **Steps 5-7 require test users with M365 E5/E5 Compliance licenses** for OneDrive and Teams deployment.
>
> **Before proceeding, validate your test users:**
>
> ```powershell
> .\Test-M365Users.ps1
> ```
>
> This script validates that users defined in `global-config.json`:
>
> - Exist in Microsoft Entra ID
> - Have M365 E5 or E5 Compliance licenses assigned
> - Have OneDrive, Teams, and Exchange services enabled
>
> **Expected output:**
>
> ```text
> ✅ finance1@yourtenant.onmicrosoft.com
>    📧 Licensed: SPE_E5
>    📁 OneDrive: Provisioned
>    👥 Teams: Enabled
>
> 📊 Summary: 3 of 3 users ready for multi-workload testing
> ```
>
> **If validation fails or you don't have licensed test users:**
>
> - Skip Steps 5-7 (OneDrive and Teams deployment)
> - Your lab environment will use **SharePoint-only data** for classification and DLP testing
> - All future labs (03-Classification, 04-Information Protection, 05-DLP) will still work, but will only demonstrate policies on SharePoint locations
>
> **To enable full multi-workload testing:**
>
> - See [User Setup Guide](../00-Prerequisites/User-Setup-Guide.md) to create and license test users
> - Re-run `Test-M365Users.ps1` to confirm readiness
> - Proceed with Steps 5-7 to deploy data across all M365 workloads

---

### Step 5: Upload Test Files to OneDrive

**If you want to test OneDrive DLP policies and classification**, upload files to test users' OneDrive accounts.

```powershell
.\Upload-OneDriveTestData.ps1
```

**What happens**:

- Validates test users from `global-config.json`
- Checks OneDrive provisioning status using Microsoft Graph
- Connects to Microsoft Graph using service principal
- Creates folder structure in each user's OneDrive: `DLP Testing/[Department]`
- Uploads department-specific files to each user:
  - **Finance users**: Credit card files, banking files, financial reports
  - **Sales users**: Loyalty program files, customer profile files
  - **Compliance users**: All file types for cross-department testing
- Reports upload status for each user

> **📋 OneDrive Provisioning Requirement**: OneDrive sites must be provisioned before file uploads can occur. Users must sign in to [office.com](https://office.com) and click the OneDrive app launcher **once** to initialize their OneDrive for Business site. This is a Microsoft 365 requirement - service principals cannot trigger initial OneDrive creation.

**Expected output**:

```text
✅ Validated 3 test users from configuration
✅ Connected to Microsoft Graph

� Provisioning OneDrive Sites
   🔐 Connecting to SharePoint Admin Center...
   ✅ Connected to SharePoint Admin Center
   🚀 Requesting OneDrive provisioning for test users...
   ✅ Provisioning requests submitted
   ⏳ Waiting 60 seconds for OneDrive sites to provision...
   ✅ Provisioning wait complete

📤 Uploading to OneDrive: finance1@marcusj-dev.cloud
   📁 Created folder: DLP Testing/Finance
   ✅ CreditCards-Only.xlsx
   ✅ Payment-Processing-Report.docx
   ✅ Q4-Financial-Review.pptx
   📊 Finance uploads: 5 files

📤 Uploading to OneDrive: sales1@marcusj-dev.cloud
   📁 Created folder: DLP Testing/Sales
   ✅ Loyalty-Program-Members.docx
   ✅ Customer-Profile-Export.docx
   📊 Sales uploads: 4 files

📊 OneDrive Upload Summary
   Users Processed: 3
   Total Files:     13
   ✅ Uploaded:     13
```

> **⏱️ Critical Timing: Microsoft Graph Eventual Consistency Delay**
>
> After users first access OneDrive at office.com, **Microsoft Graph requires 5-10 minutes** to fully recognize and make the drive accessible for programmatic file operations. This is Microsoft 365's backend replication and eventual consistency behavior.
>
> **What you'll see during the delay:**
>
> - **Step 0** (Test-M365Users.ps1) may show "OneDrive ready" (the site exists in SharePoint)
> - **Step 5** may show "OneDrive not yet provisioned" or "NotFound" errors (Graph API hasn't fully replicated)
> - Folder creation may succeed after retry attempts, but some file uploads may still fail with NotFound errors
>
> **Resolution:**
>
> 1. Have each test user sign in to [office.com](https://office.com) and click **OneDrive** app launcher
> 2. **Wait 5-10 minutes** after each user's first OneDrive access
> 3. Re-run `.\Upload-OneDriveTestData.ps1`
> 4. All file uploads should succeed after the replication window
>
> **The script includes retry logic** (3 attempts with 5-second delays) to handle minor delays, but cannot overcome the initial 5-10 minute Graph API propagation period. This is normal Microsoft 365 behavior documented in Microsoft Learn's [Best Practices for Microsoft Graph](https://learn.microsoft.com/en-us/graph/best-practices-concept#handling-expected-errors).
>
> **Files will appear in Content Explorer within 24-48 hours for classification.**
>
> **🔐 Authentication**: Script uses service principal authentication for Graph API file uploads. Manual user sign-in is only required for initial OneDrive site creation (Microsoft 365 design requirement).

### Step 6: Create Teams Environment

**If you want to test Teams DLP policies**, create a Team with channels for testing.

```powershell
.\New-TeamsEnvironment.ps1
```

**What happens**:

- Loads Teams configuration from `global-config.json`
- Creates private Team: "Retail Operations Testing"
- Creates channels from configuration (Customer Data, Financial Reports)
- Adds all test users as team members
- Sets up proper permissions for file uploads

**Expected output**:

```text
✅ Configuration loaded
🚀 Creating Team: Retail Operations Testing

✅ Team created successfully
   Team ID: abc123-team-id-guid
   
📁 Creating channels...
   ✅ Customer Data
   ✅ Financial Reports

👥 Adding team members...
   ✅ finance1@yourtenant.com
   ✅ sales1@yourtenant.com
   ✅ compliance1@yourtenant.com

✅ Teams environment ready for testing!
```

> **⏱️ Timing**: Team creation takes 1-2 minutes. Channel creation is nearly instant.

### Step 7: Upload Test Files to Teams Channels

**Upload test files to Teams channels** to test DLP policies on Teams attachments and file tabs.

```powershell
.\Upload-TeamsTestData.ps1
```

**What happens**:

- Connects to the Teams environment created in Step 6
- **Requests user authentication** for channel message posting (service principals cannot post messages)
- Uploads department-specific files to appropriate channels:
  - **Customer Data channel**: PII files, loyalty files, customer profiles
  - **Financial Reports channel**: Credit card files, banking files, financial data
- Posts channel messages with file attachments (simulates real user behavior)
- Creates file tabs for key documents

**Expected output**:

```text
👤 Step 6: User Authentication for Channel Messages
====================================================

   📝 Service principals cannot post channel messages
   🔐 Please sign in with your admin account (team member)

   ✅ User authentication successful
   👤 Signed in as: admin@yourtenant.onmicrosoft.com

📤 Step 7: Uploading Files to Channels
=======================================

📁 Uploading to channel: Customer Data
   ✅ Customer-Profile-Export.docx (uploaded + posted in channel)
   ✅ Loyalty-Program-Members.docx (uploaded + posted in channel)
   ✅ SSN-Records.docx (uploaded + posted in channel)
   ✅ CustomerDatabase-FULL.xlsx (uploaded to Files tab)
   📊 Channel uploads: 4 files

📁 Uploading to channel: Financial Reports
   ✅ CreditCards-Only.xlsx (uploaded + posted in channel)
   ✅ Payment-Processing-Report.pdf (uploaded + posted in channel)
   ✅ Banking-DirectDeposit.xlsx (uploaded + posted in channel)
   ✅ Q4-Financial-Review.pptx (uploaded to Files tab)
   ✅ Retail-Financial-Data.xlsx (uploaded + posted in channel)
   📊 Channel uploads: 5 files

📊 Step 8: Upload Summary
=========================

📈 Teams Upload Statistics
   Channels Processed:  2
   Total Files:         9
   ✅ Uploaded:         9
   📧 Messages Posted:  7
```

> **💡 Realistic Scenarios**: Most files (7 of 9) are posted as channel messages with attachments to simulate real user behavior and trigger DLP policies on Teams conversations. A few files are uploaded directly to the Files tab for testing file storage classification scenarios without message context.
>
> **🔐 Authentication**: The script uses service principal authentication for file uploads to SharePoint, then prompts for user authentication (via browser sign-in) to post channel messages. This is required because Microsoft Graph API does not allow service principals to post Teams messages. Sign in with an admin account that is a member of the team.

## ✅ Validation Steps

After uploading to SharePoint (and optionally OneDrive/Teams), verify files are accessible and being scanned:

### SharePoint Validation (Within 5 Minutes)

1. Open a browser and navigate to: `https://yourtenant.sharepoint.com/sites/Retail-Operations`
2. Click **Documents** in the left navigation
3. Confirm all **13 test files** are present in the library
4. Preview files to verify content:
   - **CustomerDatabase-FULL.xlsx** - Should show all customer data with SITs
   - **Payment-Processing-Report.pdf** - Should display credit card and banking info
   - **Q4-Financial-Review.pptx** - Should show presentation slides with financial data

![sharepoint-docs](.images/sharepoint-docs.png)

### OneDrive Validation (Within 5 Minutes - If Applicable)

**If you uploaded files to OneDrive**, verify they appear in user accounts.

- Sign in to [office.com](https://office.com) as one of the test users
- Click **OneDrive** in the app launcher
- Navigate to **DLP Testing** folder → **[Department]** subfolder
- Confirm files are present and accessible
- Preview a file to verify content matches expectations

**Or verify via admin access:**

- Go to [OneDrive admin center](https://admin.onedrive.com)
- Search for a test user
- Click **Files** to view their OneDrive content
- Verify **DLP Testing** folder contains uploaded files

### Teams Validation (Within 5 Minutes - If Applicable)

**If you created a Teams environment**, verify the team and files are accessible.

- Sign in to [teams.microsoft.com](https://teams.microsoft.com) as one of the test users
- Locate **Retail Operations Testing** team in the left sidebar
- Click each channel (**Customer Data**, **Financial Reports**)
- Verify channel messages show file attachments
- Click **Files** tab to see all uploaded files

**Check from admin perspective:**

- Go to [Teams admin center](https://admin.teams.microsoft.com)
- Navigate to **Teams** → **Manage teams**
- Search for "Retail Operations Testing"
- Verify team members and channels are configured correctly

### DLP Scanning Verification (Within 1 Hour)

1. Go to [Microsoft Purview Compliance Center](https://purview.microsoft.com)
2. Navigate to **Data loss prevention** → **Activity explorer**
3. Filter by **Location** and check activity across workloads:
   - **SharePoint**: File accessed/File modified in Retail-Operations site
   - **OneDrive**: File created/File accessed in test user OneDrive accounts
   - **Teams**: File shared/Message sent in Retail Operations Testing team
4. Look for activity related to your uploaded files
5. Check for DLP policy matches across all workloads:
   - Files with credit cards should show CC detection (all locations)
   - Files with SSNs should show SSN detection (all locations)
   - Multi-SIT files should show multiple detections regardless of location

### Content Classification Verification (Within 24 Hours)

1. Go to **Data classification** → **Content explorer**
2. Navigate to **Locations** and check all workloads:
   - **SharePoint**: Search for "Retail Operations" site
   - **OneDrive**: Filter by test user UPNs
   - **Teams**: Search for "Retail Operations Testing" team
3. Verify files are classified by detected SITs across all locations:
   - **Credit Card Number** - Should show files in SharePoint + OneDrive (Finance users) + Teams (Financial Reports channel)
   - **U.S. Social Security Number (SSN)** - Should show files across all workloads
   - **U.S. Bank Account Number** - Should show banking files in multiple locations
   - **Custom SIT (Loyalty ID)** - Should detect loyalty files wherever uploaded

### Auto-Labeling Verification (Within 24-48 Hours)

1. Return to SharePoint site and check file properties
2. Right-click any multi-SIT file → **Details**
3. Check the **Sensitivity** field for applied labels
4. Expected labels (based on your auto-labeling policies):
   - Files with CC + SSN should receive higher sensitivity label
   - Files with single SITs may receive lower sensitivity label
   - Clean control files should have no labels

> **💡 Simulation Mode**: If your auto-labeling policy is in simulation mode:
>
> 1. Go to Purview → **Information protection** → **Auto-labeling**
> 2. Click your auto-labeling policy
> 3. Click **Simulation results** tab
> 4. Wait 24-48 hours, then check which files would be labeled

### Expected Classification Results

| File Name | Expected SITs Detected | Expected Count |
|-----------|----------------------|----------------|
| CreditCards-Only.xlsx | Credit Card Number | 12 instances |
| SSN-Records.docx | U.S. Social Security Number | 8 instances |
| Banking-DirectDeposit.xlsx | U.S. Bank Account Number | 12 instances |
| Loyalty-Program-Members.docx | Custom Loyalty ID | 12 instances |
| CustomerDatabase-FULL.xlsx | CC, SSN, Banking, Loyalty, PII | 30+ instances |
| Payment-Processing-Report.docx/pdf | Credit Card, Banking | 10+ instances |
| Customer-Profile-Export.docx | SSN, Loyalty, PII | 8+ instances |
| Q4-Financial-Review.pptx | CC, SSN, Banking, Loyalty | 5+ instances |
| Retail-Financial-Data.xlsx | CC, SSN, Banking, Loyalty | 20+ instances |
| Product-Catalog.xlsx | **NONE** (clean file) | 0 instances |
| Team-Meeting-Notes.docx | **NONE** (clean file) | 0 instances |
| Q1-Sales-Strategy.pptx | **NONE** (clean file) | 0 instances |

## 🔍 Troubleshooting

### "Microsoft Office not available" Warning

**Cause**: Excel, Word, or PowerPoint not installed on the system.

**Solution**:

- Install Microsoft Office (365, 2021, 2019, or 2016)
- Script will gracefully skip file types for unavailable applications
- Minimum files created: 0 (if no Office apps), Maximum: 13 (all Office apps available)

### "Failed to resolve site" Error

**Cause**: SharePoint site doesn't exist or service principal lacks permissions.

**Solution**:

- Run `New-RetailSite.ps1` first to create the site
- Verify site URL format: `https://yourtenant.sharepoint.com/sites/Retail-Operations`
- Confirm app registration has `Sites.ReadWrite.All` permission
- Check certificate is valid and uploaded to app registration

### "Certificate not found" Error

**Cause**: PurviewAutomationCert certificate not in local certificate store.

**Solution**:

- Complete **00-Project-Setup-and-Admin** to generate and install certificate
- Verify certificate exists: `Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -eq "CN=PurviewAutomationCert"}`
- Ensure certificate is uploaded to Azure AD app registration

### "Upload failed" Error

**Cause**: Network issues, file already exists, or permission problems.

**Solution**:

- Script automatically skips files that already exist (check "Skipped" count)
- Verify service principal has `Files.ReadWrite.All` permission
- Check firewall/proxy settings for SharePoint connectivity
- Delete existing files from SharePoint and re-run upload

### Re-running the Lab

To start fresh with a clean SharePoint site:

```powershell
# 1. Delete site from SharePoint admin center or via browser
# 2. Remove from recycle bin using this PowerShell command:
$cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -eq "CN=PurviewAutomationCert"} | Select-Object -First 1
Connect-PnPOnline -Url "https://yourtenant-admin.sharepoint.com" -ClientId "your-app-id" -Thumbprint $cert.Thumbprint -Tenant "yourtenant.onmicrosoft.com"
Remove-PnPTenantDeletedSite -Identity "https://yourtenant.sharepoint.com/sites/Retail-Operations" -Force

# 3. Re-run scripts in order:
.\Generate-TestData.ps1
.\New-RetailSite.ps1
.\Upload-TestDocs.ps1
```

---

## 📚 What's Next?

After uploading test files and validating detection:

1. **Monitor DLP Activity** (Immediate - 24 Hours)
   - Check Activity Explorer for DLP policy matches
   - Verify different SIT types are being detected
   - Confirm clean control files don't trigger false positives

2. **Review Content Classification** (24-48 Hours)
   - Use Content Explorer to see files categorized by SIT
   - Verify single-SIT vs multi-SIT classification accuracy
   - Check confidence scores for SIT detections

3. **Validate Auto-Labeling** (24-48 Hours)
   - Review simulation results for auto-labeling policies
   - Identify which files would receive which sensitivity labels
   - Compare multi-SIT files vs single-SIT label assignments

4. **Test File Sharing** (Next Lab)
   - Share files externally to trigger DLP policies
   - Test policy tips and user notifications
   - Verify blocking vs audit-only behavior

5. **Advanced DLP Configuration** (Future Labs)
   - Create custom DLP policies for specific file combinations
   - Configure advanced rules for multi-SIT scenarios
   - Set up custom SIT for Loyalty ID pattern (RET-XXXXXX-X)

## 📁 Project Structure

```text
02-Data-Foundation/
├── README.md                          # This file
├── scripts/
│   ├── Generate-TestData.ps1          # Creates 13 test files with Office COM automation
│   ├── New-RetailSite.ps1             # Creates SharePoint site via service principal
│   ├── New-TeamsEnvironment.ps1       # Creates Teams workspace with channels
│   ├── Test-M365Users.ps1             # Validates test users for multi-workload testing
│   ├── Upload-OneDriveTestData.ps1    # Uploads files to test user OneDrive accounts
│   ├── Upload-TeamsTestData.ps1       # Uploads files to Teams channels with user auth
│   └── Upload-TestDocs.ps1            # Uploads all test files to SharePoint
├── data-templates/                    # Generated test files (created by Generate-TestData.ps1)
│   ├── Banking-DirectDeposit.xlsx
│   ├── CreditCards-Only.xlsx
│   ├── Customer-Profile-Export.docx
│   ├── CustomerDatabase-FULL.xlsx
│   ├── Loyalty-Program-Members.docx
│   ├── Payment-Processing-Report.docx
│   ├── Payment-Processing-Report.pdf
│   ├── Product-Catalog.xlsx
│   ├── Q1-Sales-Strategy.pptx
│   ├── Q4-Financial-Review.pptx
│   ├── Retail-Financial-Data.xlsx
│   ├── SSN-Records.docx
│   └── Team-Meeting-Notes.docx
└── templates/
    └── global-config.json              # Configuration (from 00-Prerequisites)
```

## ⚠️ Security Warning

While this data is **100% synthetic** (generated algorithmically with Luhn-valid algorithms), it appears **authentic to security scanning tools**.

**Do not upload this data to production environments** unless you want to trigger:

- Real DLP policy violations
- Security incident alerts  
- Compliance audit findings
- Potential regulatory reporting

**Always use a dedicated test tenant, sandbox environment, or properly labeled development workspace.**

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for synthetic data generation in security testing.

*AI tools were used to enhance productivity and ensure comprehensive coverage of data generation requirements while maintaining technical accuracy.*
