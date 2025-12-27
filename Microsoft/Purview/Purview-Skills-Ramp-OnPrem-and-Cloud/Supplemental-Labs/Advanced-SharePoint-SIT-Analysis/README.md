# Supplemental Lab 02: Advanced SharePoint SIT Detection and Analysis

> **⚠️ Terminology Clarification**: This lab focuses on **Sensitive Information Types (SITs)** - pattern-based detection of structured data like credit cards, SSNs, and passport numbers.

## 📋 Overview

**Duration**: 3-4 hours active work + 30-45 min data creation

**Objective**: Master advanced SIT detection and analysis in SharePoint Online including DLP policy deployment for real-time protection, Activity Explorer validation, Content Explorer reporting for comprehensive SIT analysis, and PowerShell-based reporting automation.

**Learning Outcomes:**

- Deploy and validate SharePoint DLP policies for real-time sensitive data protection.
- Analyze DLP policy effectiveness using Activity Explorer and PowerShell reporting.
- Use Content Explorer (Classic) for comprehensive SIT detection reporting and analysis.
- Build advanced PowerShell scripts for SIT distribution analysis and compliance reporting.
- Understand Activity Explorer and Content Explorer data aggregation timing (both require 24-48 hours).
- Export and analyze SIT detection data for stakeholder reporting.
- Understand when to use Activity Explorer vs Content Explorer for SIT detection and compliance reporting.

### Understanding Detection Tools and Methods

This lab uses the **correct tools for SIT detection**: Activity Explorer and Content Explorer. Before starting the hands-on steps, understand when to use each detection method in production environments.

**Detection Method Comparison:**

| Aspect | Activity Explorer | Content Explorer (Classic) |
|--------|------------------|--------------------------|
| **Primary Purpose** | Real-time DLP event monitoring | Comprehensive SIT inventory reporting |
| **Data Type** | DLP policy matches (events) | SIT detections (files) |
| **Population Speed** | 24-48 hours | 24-48 hours |
| **Use Case** | Security monitoring, incident response | Compliance reporting, remediation planning |
| **Export Format** | CSV (event timeline) | CSV (file inventory with SIT details) |
| **Cost** | Included with DLP | Included with DLP |
| **Appropriate For** | SITs (pattern detection) ✅ | SITs (pattern detection) ✅ |

**When to Use Activity Explorer (Steps 1-2 of this lab):**

- ✅ Monitor DLP policy effectiveness in real-time.
- ✅ Investigate specific security incidents or policy violations.
- ✅ Validate new DLP policy rules are detecting as expected.
- ✅ Track user behavior (who accessed/shared sensitive files).
- ✅ Generate audit trails for compliance investigations.
- ✅ Dashboard/SIEM integration for security operations center (SOC).

**When to Use Content Explorer - Classic (Steps 3-4 of this lab):**

- ✅ Generate comprehensive SIT detection inventory across tenant.
- ✅ Plan sensitive data remediation projects (which files, where located).
- ✅ Export file lists for data subject access requests (DSAR).
- ✅ Quarterly/annual compliance reporting requirements.
- ✅ Validate sensitivity label application coverage.
- ✅ Analyze SIT distribution by department, site, or business unit.

---

## 📋 Prerequisites

**Required Before Starting:**

- ✅ **Audit logging enabled 24+ hours ago** (verify with test audit search in Microsoft Purview portal).
- ✅ **SharePoint test site created** (empty site is fine - you'll create test data in this lab).
- ✅ **Basic understanding of Sensitive Information Types (SITs)** from any prior lab.
- ✅ **Microsoft 365 E5 Compliance trial** activated.

**If Missing Prerequisites:**

- **Audit logging <24 hours old** → Wait for Content Explorer infrastructure (required for Steps 3-4)
- **No SharePoint site** → Create site now (takes 5 minutes)
- **Never used SITs** → Complete Section 02 (OnPrem-02) or Section 03 (Cloud-03) first

---

## 🎯 Lab Workflow

**Phase 1: Environment Setup (30-45 min)**:

1. Create 1,000 test documents with embedded PII
2. Upload to SharePoint test site
3. Wait for automatic SharePoint crawl (1-2 hours in background - can proceed to Phase 2 during wait)

**Phase 2: Real-Time DLP Protection (1-2 hours)**:

1. Deploy SharePoint DLP policy for real-time sensitive data protection (Step 1 - 15 min)
2. Validate DLP policy detections in Activity Explorer with optional PowerShell effectiveness analysis (Step 2 - 30-45 min)

**Phase 3: Comprehensive SIT Analysis & Reporting (1-2 hours)**:

1. Use Content Explorer (Classic) to view comprehensive SIT detections (Step 3 - 15 min)
2. Export SIT detection data for stakeholder reporting (Step 3 - 10 min)
3. Build advanced PowerShell analysis scripts for SIT distribution reporting (Step 4 - 30 min)

> **🔍 Key Learning**: This lab demonstrates the correct tools for SIT detection and analysis (see "Understanding Detection Tools and Methods" in Overview for detailed comparison):
>
> - **DLP Policies + Activity Explorer (Steps 1-2)**: DLP protection with events appearing within 24-48 hours
> - **Content Explorer (Classic) (Steps 3-4)**: Comprehensive SIT reporting with data populated within 24-48 hours
> - **PowerShell Analysis (Step 4)**: Automated reporting and compliance analysis for stakeholder communication

**Total Cost Estimate**: $0

---

## 🧪 Test Environment Setup

To test DLP policies and Content Explorer effectively, you need a substantial dataset with embedded sensitive information. This section provides PowerShell automation to generate 1,000 synthetic test documents.

---

### Generate 1,000 Synthetic Sensitive Documents

Use PowerShell to create realistic test documents with embedded sensitive information:

**Create 1,000+ Test Documents with PII:**

> **💻 Execute From**: **Admin Machine (your workstation)**  
> **Why**: Creates test data in SharePoint Online (cloud-based) - no VM network access needed  
> **Requirements**:
>
> - SharePoint PnP PowerShell module: `Install-Module -Name PnP.PowerShell -Scope CurrentUser`
> - **Microsoft Word installed locally** (required for .docx file generation using COM automation)
> - SharePoint site collection admin permissions on target site
> - Internet connectivity to SharePoint Online

**Run the Test Document Generation Script:**

The script is located in this lab's folder. Navigate to the lab directory and execute:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-SharePoint-SIT-Analysis"
.\Generate-TestDocuments.ps1
```

**What the script does:**

- Prompts for your SharePoint site URL and extracts tenant information.
- Handles Entra ID app registration (automatic/manual/existing Client ID).
- Connects to SharePoint Online with your choice of authentication method.
- Creates 1,000 Word documents (.docx) with synthetic PII data:
  - 40% contain sensitive data (SSN, Credit Card numbers)
  - 60% contain normal business content (no PII)
- Uploads documents to your specified SharePoint library.
- Distributes file creation dates across 3-year period for realistic testing.
- Provides progress updates every 50 documents.

> **⚠️ Existing App Registration**: If you already have a **PnP PowerShell Interactive** app registration in your tenant, you must manually add the **Sites.ReadWrite.All** (or **Sites.FullControl.All**) delegated permission and **grant admin consent** before running this script:
>
> 1. Go to **Azure Portal** → **Entra ID** → **App registrations** → **PnP PowerShell Interactive**
> 2. Click **API permissions** → **+ Add a permission** → **SharePoint** → **Delegated permissions**
> 3. Select **Sites.ReadWrite.All** (or **Sites.FullControl.All**) → **Add permissions**
> 4. Click **Grant admin consent for [your tenant]** (blue button)
> 5. Verify green checkmark appears next to the permission
> 6. **Important**: If you were already connected to SharePoint, you must **restart your PowerShell session** to get a new token with the updated permissions
>
> **💡 Document Library Name**: When prompted for the document library name, use **Shared Documents** (the default). Even though SharePoint displays "Documents" in the left navigation, the actual library name in the API is "Shared Documents". This is a common SharePoint naming quirk.

**Expected Output:**

```text
Checking Entra ID App Registration...
   Environment variable already set: 12345678-1234-1234-1234-123456789012

Connecting to SharePoint Online...
Authentication method? (1=Interactive Browser, 2=Device Code): 1
   Opening browser for authentication...
✅ Connected to SharePoint successfully

Document Library Selection...
Enter document library name (default: 'Shared Documents'): 
   Using library: Shared Documents

Initializing Microsoft Word...
   ✅ Word COM object initialized

Created 50 documents (50 successful, 0 failed)...
Created 100 documents (100 successful, 0 failed)...
...
Created 1000 documents (1000 successful, 0 failed)...

Cleaning up Word COM object...
✅ Completed: 1000 documents uploaded successfully, 0 failed
   Expected sensitive documents: ~400
```

**Expected Results**:

- 1,000 Word documents (.docx) uploaded to your SharePoint library.
- ~400 files contain SSN, credit card, and PII data.
- ~600 clean files for false positive testing.
- Mixed creation dates (0-3 years old) for realistic distribution.

**Lab Benefits**:

| Benefit | Explanation |
|---------|-------------|
| **Predictable Content** | Known PII patterns for validation |
| **Realistic Scale** | 1,000 files = typical department site |
| **Manageable Scope** | Smaller dataset for initial testing and validation |
| **Cost-Effective** | No additional costs (uses free DLP + Content Explorer) |
| **Easy Debugging** | Small enough to manually validate results |
| **Office Format** | .docx files ensure reliable SIT detection and DLP policy matching |

**Next Steps**: After creating test data, wait 1-2 hours for automatic SharePoint crawl, then proceed to the steps below.

---

### 📁 Sample Data for Script Testing

This lab includes pre-built sample CSV files that allow you to test the PowerShell analysis scripts **without waiting for SharePoint indexing and Purview explorers to sync with your live data**. SharePoint crawls and Purview's Content Explorer / Activity Explorer typically require **24-48 hours** to populate after uploading documents.

**Sample Files Location**: `./sample-data/`

| File | Purpose | Script |
|------|---------|--------|
| `Sample_ContentExplorer_SIT_Export.csv` | Content Explorer export with SIT detections | `Generate-SITAnalysisReport.ps1` |
| `Sample_ActivityExplorer_DLP_Export.csv` | Activity Explorer export with DLP events | `Generate-DLPEffectivenessReport.ps1` |

**When to Use Sample Data:**

- ✅ **Immediate script testing** - Test PowerShell scripts right after uploading documents (no 24-48 hour wait).
- ✅ **Learning the workflow** - Understand script output format before running with production data.
- ✅ **Offline demonstration** - Show stakeholders the analysis capabilities without live tenant access.
- ✅ **Validation baseline** - Compare sample output to actual tenant exports.

**Sample Data Contents:**

| Sample File | Records | SIT Types | Key Columns |
|-------------|---------|-----------|-------------|
| `Sample_ContentExplorer_SIT_Export.csv` | 20 files | SSN, Credit Card, Bank Account | Name, Location, Sensitive info type, Trainable classifiers |
| `Sample_ActivityExplorer_DLP_Export.csv` | 25 DLP events | SSN, Credit Card | File, Rule, Happened, User, Activity, Workload |

**Run Scripts with Sample Data:**

```powershell
# Navigate to lab directory
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-SharePoint-SIT-Analysis"

# Test SIT Analysis Report script
.\Generate-SITAnalysisReport.ps1 -ExportPath ".\sample-data\Sample_ContentExplorer_SIT_Export.csv"

# Test DLP Effectiveness Report script  
.\Generate-DLPEffectivenessReport.ps1 -ExportPath ".\sample-data\Sample_ActivityExplorer_DLP_Export.csv"
```

> **💡 Interactive Mode**: Both scripts also support interactive path entry. Run without parameters and the script will prompt you to enter the file path.

**When Your Live Data Is Ready:**

After 24-48 hours, export your actual tenant data from Purview:

1. **Content Explorer**: Export → Save as `ContentExplorer_SIT_Export.csv`
2. **Activity Explorer**: Export → Save as `ActivityExplorer_DLP_Export.csv`
3. Run scripts with your exported files to analyze real detections.

---

## 📖 Step-by-Step Instructions

### Understanding SharePoint Search Architecture

Before you can classify and protect SharePoint content, you need to understand how SharePoint's search architecture discovers, processes, and indexes files. The crawl-to-classification workflow explains how content moves from creation to being available for sensitivity labeling and policy enforcement.

**Key Concepts:**

| Component | Purpose | Classification Impact |
|-----------|---------|----------------------|
| **Crawl** | Discovers content and metadata | Determines what files are available for classification |
| **Content Processing** | Maps crawled properties to managed properties | Enables searchable classification metadata |
| **Index** | Stores processed content | Source for classification queries and reporting |
| **Managed Properties** | Searchable/refinable metadata | Custom properties for classification tracking |

**Classification Workflow:**

```text
File Created/Modified
    ↓
Crawl Process (automatic or manual)
    ↓
Content Processing (extract metadata)
    ↓
Search Index Updated
    ↓
Classification Available
    ↓
Policies Applied (DLP, Retention, etc.)
```

> **⏱️ Automatic Crawl Schedule**: SharePoint Online automatically crawls content, but timing varies (minutes to hours).

---

### Step 1: Create SharePoint DLP Policy for Real-Time Protection

Establish DLP policies to provide **real-time protection** for your SharePoint documents. This step demonstrates how DLP policies enable immediate SIT detection and blocking, forming the foundation for comprehensive SIT analysis in Steps 3-4.

> **💡 Why DLP First**: DLP policies detect sensitive data within **15-30 minutes** and actively block/audit sharing attempts. This provides the data foundation for Content Explorer analysis in later steps. Deploy DLP for immediate protection, then use Content Explorer for comprehensive SIT reporting.

**Navigate to DLP Policies:**

- Go to [Microsoft Purview portal](https://purview.microsoft.com).
- Navigate to **Solutions** → **Data loss prevention** (left navigation).
- Select **Policies**.
- Click **+ Create policy**.

**DLP Policy Creation Wizard:**

#### Choose What Type of Data to Protect

The policy creation wizard starts with a splash screen asking "What info do you want to protect?" with two tile options.

- Select the **Enterprise applications & devices** tile (left option).
- Click the tile to proceed.

> **💡 Option Context**:
>
> - **Enterprise applications & devices** = Protection for data across all connected sources including Microsoft 365 locations (SharePoint, OneDrive, Exchange), Microsoft Copilot experiences, data connectors, enterprise-registered apps, managed apps accessed with Edge for Business browser, and on-premises repositories.
> - **Inline web traffic** = Protection for data transferred in real-time with unmanaged cloud apps through Edge for Business browser and network SASE/SSE integrations.
>
> For SharePoint Online protection, **Enterprise applications & devices** is the correct choice as it includes all Microsoft 365 locations.

#### Select Policy Template

- Under **Categories**, select: **Custom**.
- Under **Regulations**, select: **Custom policy** (allows full control over rules and conditions).
- Click **Next**.

> **💡 Template Options**: Microsoft provides pre-built templates for Financial, Medical/Health, and Privacy regulations. Custom policy gives you complete control over sensitive information types, conditions, and actions.

#### Name Your Policy

- **Name**: `SharePoint Sensitive Data Protection - Lab`
- **Description**: `DLP policy for lab SharePoint site - detects credit cards and SSNs with immediate protection`
- Click **Next**.

> **⚠️ Policy Name Conflict**: If you see error "A compliance policy with name 'SharePoint Sensitive Data Protection - Lab' already exists", you have two options:
>
> **Option 1 - Delete Existing Policy (Recommended for Labs)**:
>
> - Navigate to **Data loss prevention** → **Policies**
> - Find **SharePoint Sensitive Data Protection - Lab**
> - Click **...** (three dots) → **Delete policy**
> - Confirm deletion
> - Return to **+ Create policy** and start over
>
> **Option 2 - Use Unique Name**:
>
> - Add date/timestamp to policy name: `SharePoint Sensitive Data Protection - Lab 2025-12-26`
> - Continue with wizard using unique name

#### Assign Admin Units

- **Full directory** is selected by default (applies policy to all users and groups).
- For this lab, keep the default **Full directory** selection.
- Click **Next**.

> **📚 Note**: Admin units allow scoping DLP policies to specific organizational units within your Microsoft Entra ID tenant. Full directory applies the policy across your entire organization, which is appropriate for lab scenarios.

#### Configure Locations

DLP policies can apply to multiple locations. For this lab, we focus exclusively on SharePoint sites.

By default, several locations are checked (enabled). **Uncheck all locations EXCEPT SharePoint sites:**

1. Click to **uncheck** the following locations (toggle them to OFF):
   - **Exchange email** → Uncheck
   - **OneDrive accounts** → Uncheck
   - **Teams chat and channel messages** → Uncheck
   - **Instances** → Uncheck
   - **On-premises repositories** → Uncheck
   - **Power BI workspaces** → Uncheck (if shown)

2. Keep **ONLY** this location checked:
   - ✅ **SharePoint sites** → Keep checked (ON)

3. Configure the SharePoint location:
   - Click **Choose sites** (under SharePoint sites)
   - Search for and select your lab SharePoint site (the site where you uploaded 1000 test documents)
   - Click **+** to confirm selection
   - Click **Done** to return to location selection

4. Click **Next**.

> **💡 Lab Approach**: Targeting only your specific SharePoint site limits DLP policy scope to test data. In production, you would target specific sites, all sites, or use sensitivity labels to determine policy application.

#### Select Rule Configuration Method

- Select **Create or customize advanced DLP rules**.
- Click **Next**.

You'll now create two DLP rules: one for Credit Card data (with blocking) and one for SSN data (with auditing).

#### Add First Rule - Credit Card Detection

Click **+ Create rule** to define detection and action settings:

**Rule Name and Description:**

- **Name**: `Block-Credit-Card-External-Sharing`
- **Description**: `Block external sharing of documents containing credit card numbers`

**Configure Conditions:**

Add **FIRST condition** (required for external blocking):

Under **Conditions**, click **+ Add condition** → **Content is shared from Microsoft 365**:

- Select **with people outside my organization**.

> **⚠️ Required Condition**: When using "Block people outside your organization" action, you MUST include "Content is shared from Microsoft 365 with people outside my organization" as a condition. This tells DLP to trigger the rule only during external sharing attempts.

Add **SECOND condition** (sensitive content detection):

Click **+ Add condition** → **Content contains**:

- Click **Add** → **Sensitive info types**.
- Search for and select **Credit Card Number**.
- Click **Add**.
- **Instance count**:
  - From: `1`
  - To: `Any`

Verify **Condition Logic**:

- Ensure conditions are combined with **AND** operator (default).
- Rule triggers when: External sharing attempt **AND** Content contains credit cards.

**Configure Actions:**

Under **Actions**, click **+ Add an action** → **Restrict access or encrypt the content in Microsoft 365 locations**:

- Select **Block people outside your organization**.
- The action will prevent external sharing when conditions are met.

**User Notifications:**

- Enable **User notifications**: Turn toggle **On**.
- Check: **Notify the user who sent, shared, or last modified the content**.

**Incident Reports:**

- **Severity level**: Select **High** from the dropdown.
- **Send alert every time an activity matches the rule**: Selected.

Click **Save** to create the first rule.

#### Add Second Rule - SSN Detection (Audit Mode)

Click **+ Create rule** again:

- **Name**: `Audit-SSN-External-Sharing`
- **Description**: `Audit documents containing U.S. Social Security Numbers`

**Configure Conditions:**

Add **FIRST condition**:

Under **Conditions**, click **+ Add condition** → **Content is shared from Microsoft 365**:

- Select **with people outside my organization**.

Add **SECOND condition**:

Click **+ Add condition** → **Content contains**:

- Click **Add** → **Sensitive info types**.
- Search for and select **U.S. Social Security Number (SSN)**.
- Click **Add**.
- **Instance count**:
  - From: `1`
  - To: `Any`

**Configure Actions (Audit Only):**

For audit-only monitoring, **do NOT add any actions**:

- Under **Actions**, you will see **+ Add an action** option.
- **Do not click** this for the SSN audit rule.
- Leave the Actions section empty (no actions configured).

> **💡 Audit vs Enforcement**:
>
> - **Audit-only rule** (SSN): No actions configured → DLP detects and logs SSN files but doesn't block sharing
> - **Enforcement rule** (Credit Card): Actions configured → DLP detects files AND blocks external sharing
>
> Leaving Actions empty creates a monitoring/discovery rule that logs activity in Activity Explorer without disrupting user access.

**User Notifications:**

- Enable **User notifications**: Turn toggle **On**.
- Notify users with policy tip.

**Incident Reports:**

- **Severity level**: Select **Medium** from the dropdown.
- **Send alert every time an activity matches the rule**: Selected.

Click **Save** to create the second rule.

Click **Next** to advance to Policy mode.

#### Policy Mode

- Select **Turn the policy on immediately**.
- Click **Next**.

> **⚠️ Production Note**: For production deployments, use **Run the policy in simulation mode** to review matches before enforcement. For this lab, immediate enforcement demonstrates DLP blocking behavior.

#### Review and Finish

- Review policy configuration.
- Click **Submit** to create the DLP policy.

> **💡 Data Lifecycle Management Recommendation (Optional)**: After clicking **Submit**, Microsoft may display a recommendation prompt suggesting you use auto-labeling policies in Data Lifecycle Management to delete obsolete data. This is an optional best practice for production environments but **NOT required for this lab**. You can safely **dismiss or skip this prompt** - it does not affect your DLP policy functionality.

**Expected Result:**

- DLP policy created: "SharePoint Sensitive Data Protection - Lab".
- Policy status: Active.
- Locations: Your SharePoint lab site.
- Rules: 2 (Credit card blocking, SSN auditing).

> **⏱️ DLP Processing Time**: Allow **15-30 minutes** for DLP policy to perform initial scan of your SharePoint site. During this time, DLP analyzes all 1000 documents and identifies matches for policy rules.

---

### Step 2: Validate DLP Policy Detection in Activity Explorer

After creating the DLP policy, verify it's actively detecting sensitive data and generating "DLP policy match" events in Activity Explorer.

> **📊 Data Availability**: Activity Explorer requires **24-48 hours** after DLP policy creation for initial events to appear. If you see no events immediately, wait 24-48 hours and refresh.

**Navigate to Activity Explorer:**

- Go to [Microsoft Purview portal](https://purview.microsoft.com).
- Navigate to **Solutions** → **Information protection** (left navigation).
- Select **Explorers** → **Activity explorer**.

> **💡 Portal Navigation Note**: Activity Explorer was reorganized in 2024 and is now under **Information Protection → Explorers** (previously under "Data Classification → Activity explorer"). Functionality remains identical.

**Configure Filters for SharePoint DLP Analysis:**

**Filter 1: Date Range**:

- Click the **calendar icon** (date range filter).
- Select **Last 7 days** (or **Last 30 days** if checking historical data).
- Click **Apply**.

**Filter 2: Activity Type**:

- Click **Activity** dropdown.
- Search for **"DLPRuleMatch"**.
- Select **DLPRuleMatch** (this is the activity type for cloud DLP detections).
- Click **Apply**.

> **💡 Activity Type Clarification**: The activity type **"DLPRuleMatch"** is specific to cloud DLP policies (SharePoint, OneDrive, Exchange, Teams, Endpoint DLP). This is different from:
>
> - **"Files discovered"** - Generated by on-premises Information Protection Scanner (OnPrem-02)
> - **"Retention label applied"** - Generated by auto-apply retention policies (Cloud-03)

**Filter 3: Location** (Optional - for focused analysis)

- Click **Location** dropdown.
- Select **SharePoint** (this is the workload category, not individual site selection).
- Click **Apply**.

> **💡 Location Filter Note**: The Location dropdown shows workload categories (SharePoint, OneDrive, Exchange, Teams) rather than individual sites. While the **File** column displays full file paths including site URLs, it doesn't provide filtering capabilities. **To filter Activity Explorer data by specific SharePoint site, export to CSV** (see Export Activity Explorer Data section below) and filter the **File** column in Excel or PowerShell.

**Filter 4: Policy** (Optional)

- Click **Policy** dropdown.
- Search for **"SharePoint Sensitive Data Protection - Lab"**.
- Select your DLP policy.
- Click **Apply**.

**Expected Activity Explorer Results:**

After filters are applied, you should see:

| Metric | Expected Value | What It Means |
|--------|----------------|---------------|
| **Total Activities** | ~400 events | Matches your test data (40% of 1000 docs have sensitive data) |
| **Activity** | DLP rule matched | Cloud DLP detections (not on-premises scanner) |
| **Location** | SharePoint | Events filtered to scanned SharePoint sites |
| **Policy** | SharePoint Sensitive Data Protection - Lab | Your newly created DLP policy |
| **User** | Your admin account or DLP system account | Who triggered the detection |
| **Happened** | Date when the file was scanned | When DLP policy performed initial scan |

**Explore Individual Activity Events:**

- Click on any **DLPRuleMatch** event in the list.
- Review the details panel:
  - **File name**: TestDoc_XXX.docx (from your test data).
  - **Sensitive info types detected**: Credit Card Number OR U.S. SSN.
  - **Policy rule matched**: High Severity - Credit Card Detection OR Low Severity - SSN Detection.
  - **Rule actions**: Block external sharing.
  - **Location**: Full SharePoint file path.

**Export Activity Explorer Data:**

For detailed analysis and reporting:

- Click **Export** button in Activity Explorer toolbar.
- Save CSV to your local machine (e.g., `C:\PurviewLab\ActivityExplorer_DLP_Export.csv`).
- Open CSV in Excel to review:
  - File names with DLP matches.
  - Sensitive info type distributions (Credit Card vs SSN).
  - Detection timestamps.
  - Policy rule severity (High vs Low).

**PowerShell Analysis of Activity Explorer Export (Optional):**

For deeper analysis beyond the Activity Explorer UI, run the DLP effectiveness analysis script:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-SharePoint-SIT-Analysis"

# Interactive mode - script will prompt for file path
.\Generate-DLPEffectivenessReport.ps1

# Or specify the export path directly
.\Generate-DLPEffectivenessReport.ps1 -ExportPath "C:\PurviewLab\ActivityExplorer_DLP_Export.csv"
```

> **💡 Can't Wait for Live Data?** Use the sample data to test the script immediately:
> `.\Generate-DLPEffectivenessReport.ps1 -ExportPath ".\sample-data\Sample_ActivityExplorer_DLP_Export.csv"`

This script provides comprehensive DLP policy analysis including:

- **Detection Summary**: Total matches, unique files, detection rate vs expected test data.
- **Severity Distribution**: High severity (credit cards) vs Low severity (SSNs) rule matches.
- **Sensitive Info Type Breakdown**: Credit Card vs SSN detection counts.
- **Timing Analysis**: First/last detection timestamps, detection window duration.
- **Recommendations**: Policy optimization suggestions based on detection patterns.
- **Automated Report**: Exports detailed analysis to the same directory as your export file.

**Compare DLP Detection vs Expected Test Data:**

| Metric | Expected (Test Data) | Actual (DLP Detection) | Analysis |
|--------|---------------------|----------------------|----------|
| **Total Sensitive Files** | ~400 (40% of 1000) | [Your result from Activity Explorer] | Match indicates accurate detection |
| **Credit Card Files** | ~200 (20% of 1000) | [High severity rule matches] | Validates rule configuration |
| **SSN Files** | ~200 (20% of 1000) | [Low severity rule matches] | Validates rule configuration |
| **Detection Time** | 15-30 minutes after policy creation | [Actual time from policy creation to first event] | Measures DLP responsiveness |

**Key Insights from DLP Validation:**

- ✅ **Real-Time Protection**: DLP detected sensitive files within 15-30 minutes (vs days for classification scans).
- ✅ **Blocking Effectiveness**: External sharing blocked for ~400 files containing PII.
- ✅ **User Visibility**: Policy tips notify users when they attempt to share sensitive files.
- ✅ **Audit Trail**: Activity Explorer provides complete history for compliance reporting.

**Validation Checklist:**

- [ ] Activity Explorer shows "DLPRuleMatch" events.
- [ ] Total events approximately match test data distribution (~400 sensitive files).
- [ ] Events show your SharePoint site as location.
- [ ] Sensitive info types include Credit Card Number and U.S. SSN.
- [ ] Policy name matches "SharePoint Sensitive Data Protection - Lab".
- [ ] Export CSV successfully downloaded for further analysis.

> **💡 DLP vs Classification Timing**: DLP policy matches appear in Activity Explorer within **24-48 hours** (background aggregation). Content Explorer provides comprehensive SIT analysis within **24-48 hours** of policy deployment. Both tools provide comprehensive periodic analysis with similar timing.

---

### Step 3: Comprehensive SIT Analysis Using Content Explorer (Classic)

Content Explorer (Classic) provides several advantages for SIT analysis:

**Why Use Content Explorer:**

- ✅ Uses same detection engine as DLP (proven working in Activity Explorer).
- ✅ Shows SIT matches within 24-48 hours (faster than traditional periodic scanning).
- ✅ Provides filtering, grouping, and export capabilities.
- ✅ Displays confidence scores and instance counts per file.
- ✅ No additional classification scan required (uses existing DLP detections).
- ✅ No additional costs (included with DLP licensing).

**Navigate to Content Explorer (Classic):**

- Go to **Microsoft Purview portal**: [https://purview.microsoft.com](https://purview.microsoft.com).
- Navigate to **Information Protection** → **Explorers** → **Content explorer (classic)**.

> **💡 Portal Navigation**: If you don't see "Content explorer (classic)", you may only see "Content explorer" (the modern version). The classic version provides better SIT filtering and export capabilities. If only modern Content Explorer is available, the steps below will be similar but with a different UI layout.

**View SIT Detections:**

- In the left navigation tree, expand **Sensitive info types**.
- You'll see all SITs with detections in your tenant:
  - **Credit Card Number** (with file count).
  - **U.S. Social Security Number (SSN)** (with file count).
  - Other built-in and custom SITs that have detected content.

**Expected Results After 24-48 Hours:**

| SIT Type | Expected Count | What This Represents |
|----------|----------------|---------------------|
| **Credit Card Number** | ~200 files | Files containing credit card patterns (20% of 1,000 test docs) |
| **U.S. Social Security Number (SSN)** | ~200 files | Files containing SSN patterns (20% of 1,000 test docs) |
| **Total Unique Files** | ~400 files | 40% of test data contains sensitive information |

> **⏱️ Data Availability Timing**: Content Explorer typically populates within **24-48 hours** after DLP policy detections appear in Activity Explorer. If you don't see results immediately:
>
> - **Wait 24-48 hours** for Content Explorer data sync
> - **Verify Activity Explorer** still shows DLP policy matches (if Activity Explorer works, Content Explorer will eventually sync)
> - **Check date filters** in Content Explorer to ensure you're viewing the correct time range

**Analyze SIT Detections by Type:**

Click on **Credit Card Number** in the left tree:

- View all files with credit card detections.
- Review columns:
  - **File name**: TestDoc_XXX.docx.
  - **Location**: Full SharePoint site and library path.
  - **Instance count**: How many credit card numbers found in this file.
  - **Confidence**: Detection confidence level (typically 85-100% for built-in SITs).
  - **Last modified**: When file was last changed.

Click on **U.S. Social Security Number (SSN)** in the left tree:

- View all files with SSN detections.
- Same column structure as credit card results.
- Separate list from credit card (files may appear in both if they contain both SIT types).

**Filter SIT Results by SharePoint Location:**

To focus only on your test site files:

- In the results view, use the **Location** filter at the top.
- Select **SharePoint** as the location type.
- Use the search box to filter by specific site URL fragment:
  - Type part of your site name (e.g., "PurviewTest" or "SensitiveDataTest").
  - Results narrow to show only files from matching locations.

**Export SIT Detection Data:**

For stakeholder reporting and remediation planning:

- Click **Export** button in Content Explorer toolbar.
- Select export scope:
  - **Current view**: Exports currently filtered/displayed results.
  - **All sensitive info types**: Exports all SIT detections across tenant.
- Choose **Current view** to export only your SharePoint test site results.
- Save CSV to your local machine (e.g., `C:\PurviewLab\ContentExplorer_SIT_Export.csv`).

**Export CSV Columns Include:**

| Column | Purpose | Example Value |
|--------|---------|---------------|
| **Name** | File name | TestDoc_042.docx |
| **Location** | Full file path | `https://tenant.sharepoint.com/sites/PurviewTest/Shared Documents/TestDoc_042.docx` |
| **Sensitive info type** | SIT name | Credit Card Number |
| **Instance count** | How many matches in file | 1 |
| **Confidence** | Detection confidence (%) | 95 |
| **Last modified** | File modification date | 2025-11-08 |
| **Last modified by** | User who last edited | `admin@tenant.onmicrosoft.com` |
| **Owner** | File owner | `admin@tenant.onmicrosoft.com` |

**Validation Checklist:**

- [ ] Content Explorer (Classic) accessible from Information Protection → Explorers
- [ ] Sensitive info types tree shows Credit Card Number with ~200 file count
- [ ] Sensitive info types tree shows U.S. SSN with ~200 file count
- [ ] Clicking each SIT shows detailed file list with SharePoint paths
- [ ] Location filter successfully narrows results to test site
- [ ] Export CSV successfully downloads with expected ~400 file records
- [ ] Confidence scores mostly "High" (85-100%)
- [ ] File paths match your SharePoint test site structure

> **💡 Timing Comparison Summary:**
>
> | Method | Detection Time | Purpose | Cost |
> |--------|---------------|---------|------|
> | **Activity Explorer** | 24-48 hours | DLP event aggregation and monitoring | Included with DLP |
> | **Content Explorer** | 24-48 hours | Comprehensive SIT inventory reporting | Included with DLP |
>
> For SIT detection and reporting, **Activity Explorer + Content Explorer** provide the fastest, most cost-effective solution.

---

### Step 4: Advanced PowerShell SIT Analysis and Reporting

Now that you have exported SIT detection data from Content Explorer, build advanced PowerShell scripts to analyze SIT distribution, generate stakeholder reports, and automate compliance reporting workflows.

**Import Content Explorer Export Data:**

> **💻 Execute From**: **Admin Machine (your workstation)**
>
> **Prerequisites**: Content Explorer CSV export saved locally (e.g., `C:\PurviewLab\ContentExplorer_SIT_Export.csv`)

Run the comprehensive SIT analysis script to generate detailed reports:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-SharePoint-SIT-Analysis"

# Interactive mode - script will prompt for file path
.\Generate-SITAnalysisReport.ps1

# Or specify the export path directly
.\Generate-SITAnalysisReport.ps1 -ExportPath "C:\PurviewLab\ContentExplorer_SIT_Export.csv"
```

> **💡 Can't Wait for Live Data?** Use the sample data to test the script immediately:
> `.\Generate-SITAnalysisReport.ps1 -ExportPath ".\sample-data\Sample_ContentExplorer_SIT_Export.csv"`

> **✅ Updated for New Content Explorer Format**: This script has been updated to parse the new JSON array format introduced by Microsoft in Content Explorer exports. The script now correctly extracts SIT names, confidence levels (high/medium/low), and instance counts from the JSON structure.
>
> **Script Capabilities**:
>
> - **Parses JSON Arrays**: Automatically extracts SIT objects from the "Sensitive info type" column.
> - **Confidence Breakdown**: Reports high/medium/low confidence detections instead of percentage scores.
> - **Instance Calculation**: Calculates total instances per file from JSON (low + medium + high counts).
> - **Location Handling**: Gracefully handles exports with or without the Location column.
> - **Accurate Statistics**: All reports reflect actual data from your Content Explorer export.

**Expected Console Output:**

```text
🔍 Step 1: Environment Validation
=================================
   ✅ Content Explorer export found

📥 Step 2: Import Content Explorer Data
=======================================
   ✅ Loaded Content Explorer data: 135 total SIT detections

📊 Step 3: SIT Type Distribution Analysis
=========================================

Sensitive Info Type                                   Files Detected Total Instances
-------------------                                   -------------- ---------------
Credit Card Number                                               135          403.00
All Full Names                                                   134          402.00
U.S. Social Security Number (SSN)                                 88          220.00
U.S. Individual Taxpayer Identification Number (ITIN)             27           81.00

   Total unique SIT types detected: 4
   Total SIT instances across all files: 1106

📍 Step 4: SharePoint Site Distribution
=======================================
   ⚠️  Location data not available in export - cannot analyze SharePoint site distribution
   Note: Ensure full Content Explorer export includes Location column

🎯 Step 5: Detection Confidence Distribution
============================================

Confidence Level             Instance Count
----------------             --------------
Low confidence detections            384.00
Medium confidence detections         361.00
High confidence detections           361.00

   High confidence detections: 32.6% of total instances

🔢 Step 6: Sensitive Data Instance Distribution
===============================================

Instances Per File Number of Files
------------------ ---------------
9                               93
7                               22
6                               19
1                                1

   Files with multiple SIT instances: 134

⚠️  Step 7: High-Risk File Identification
=========================================

Top 10 High-Risk Files (Multiple SIT Instances):

File             Total SIT Instances
----             -------------------
TestDoc_1.docx                  9.00
TestDoc_743.docx                9.00
TestDoc_727.docx                9.00

SIT Breakdown for highest-risk file: TestDoc_1.docx

SITName                           High Conf Med Conf Low Conf Total
-------                           --------- -------- -------- -----
Credit Card Number                        1        1        1     3
U.S. Social Security Number (SSN)         1        1        1     3
All Full Names                            1        1        1     3

   📝 High-risk files require priority review for data retention compliance

📄 Step 8: Generate Stakeholder Compliance Report
=================================================
   ✅ Stakeholder report saved to: C:\PurviewLab\SIT_Analysis_Stakeholder_Report.txt

✅ Advanced PowerShell SIT analysis complete!
   Reports available in: C:\PurviewLab
```

**Stakeholder Report Sample (C:\PurviewLab\SIT_Analysis_Stakeholder_Report.txt):**

```text
================================================================================
SHAREPOINT SIT DETECTION ANALYSIS REPORT
================================================================================
Generated: 2025-11-09 12:18:37
Data Source: Microsoft Purview Content Explorer

EXECUTIVE SUMMARY
-----------------
Total Files with Sensitive Information: 135
Unique SIT Types Detected: 4
Total SIT Instances: 1106
High Confidence Detections: 361 instances (32.6%)
High-Risk Files (3+ SIT instances): 134

SENSITIVE INFORMATION TYPE BREAKDOWN
------------------------------------
  Credit Card Number: 135 files (403 instances)
  All Full Names: 134 files (402 instances)
  U.S. Social Security Number (SSN): 88 files (220 instances)
  U.S. Individual Taxpayer Identification Number (ITIN): 27 files (81 instances)

DETECTION CONFIDENCE ANALYSIS
-----------------------------
  High Confidence (detailed pattern match): 361 instances
  Medium Confidence (probable match): 361 instances
  Low Confidence (possible false positive): 384 instances

RISK ASSESSMENT
---------------
High-Risk Files (3+ SIT instances): 134 files
Files with Multiple SIT types: 134 files
Average SIT Instances per File: 8.2
```

This script provides comprehensive Content Explorer analysis including:

- **SIT Type Distribution**: Breakdown of detected sensitive information types (Credit Cards, SSNs, etc.) with file counts and total instances
- **SharePoint Site Distribution**: Analysis of which SharePoint sites contain sensitive data (when Location column available)
- **Confidence Score Analysis**: High/Medium/Low confidence detection categorization from JSON data
- **Instance Count Distribution**: Files with single vs multiple sensitive data instances calculated from JSON
- **High-Risk File Identification**: Top 10 files with 3+ SIT instances with detailed confidence breakdown
- **Stakeholder Compliance Report**: Executive summary with accurate statistics, compliance implications, and recommendations
- **Automated Report Export**: Detailed analysis saved to `C:\PurviewLab\SIT_Analysis_Stakeholder_Report.txt`

**PowerShell Script Output Files:**

| File | Purpose | Audience |
|------|---------|----------|
| `DLP_Effectiveness_Report.txt` | DLP policy detection summary (from Step 2) | IT Security, DLP administrators |
| `SIT_Analysis_Stakeholder_Report.txt` | Executive compliance summary | Compliance officers, management |
| `ContentExplorer_SIT_Export.csv` | Raw SIT detection data | Data analysts, remediation teams |
| `ActivityExplorer_DLP_Export.csv` | DLP event timeline (from Step 2) | Audit teams, security operations |

---

## 🔍 Advanced Content Explorer Features

### Advanced Validation and Pattern Analysis

Content Explorer provides advanced features for validating SIT matches and analyzing classification patterns. These capabilities help ensure accuracy and inform remediation priorities.

**Prerequisites:**

- **Content Explorer data available** (24-48 hours from DLP policy deployment in Steps 1-2)
- **Content Explorer Content Viewer** role assigned (required to preview files and provide feedback)

---

#### File Preview and Classification Validation

Content Explorer allows you to review individual files to ensure classification accuracy:

**Access File Preview:**

1. Navigate to **Content Explorer** and apply filters (by site, SIT, or label)
2. Drill down through **All locations** > **SharePoint** > *your site* > *document library*
3. **Double-click a file** to open native preview in Content Explorer

**Verify SIT Matches:**

- Review file content to confirm sensitive information is present.
- Check if classifier correctly identified the data type.
- Look for false positives (flagged incorrectly) or false negatives (missed sensitive data).

**Provide Match/Not Match Feedback:**

After reviewing each file:

- Click **Match** if classification correctly identifies sensitive content.
- Click **Not a Match** if classification is incorrect or a false positive.
- Feedback trains classifiers to improve accuracy for your organization's data patterns.

> **🎯 Accuracy Improvement**: Match/Not Match feedback is critical for custom trainable classifiers. For built-in SITs (Credit Card, SSN), feedback helps Microsoft improve detection accuracy across all tenants.

**Sample Validation Workflow:**

| File Type | Review Focus | Action |
|-----------|--------------|--------|
| **High confidence match** | Confirm SIT is present | Mark **Match** to reinforce accuracy |
| **Medium confidence match** | Verify if content contains SIT | Mark **Match** or **Not a Match** based on review |
| **Unexpected SIT detection** | Check for false positive | Mark **Not a Match** if incorrect |

---

#### Pattern Analysis and Trend Identification for Remediation Prioritization

Use Content Explorer's aggregated views to identify remediation priorities:

**By Site Analysis:**

- Expand **All locations** > **SharePoint**.
- Compare sensitive item counts across sites.
- **Action**: Prioritize sites with highest PII concentrations for remediation.

**By Sensitive Information Type:**

- Expand **Sensitive info types**.
- Review which SITs have highest match counts.
- **Action**: Focus DLP policies on most prevalent data types.

**By Label Coverage:**

- Expand **Sensitivity labels** and **Retention labels**.
- Identify files with classification but no applied labels.
- **Action**: Adjust auto-apply label policies to close coverage gaps.

**By File Age** (using exported data):

- Export Content Explorer results to CSV (see next section).
- Sort by **Modified Date** column.
- **Action**: Target files 3+ years old for deletion/archival per remediation criteria.

**Pattern Analysis Table:**

| Analysis Dimension | Insight | Remediation Action |
|-------------------|---------|-------------------|
| **Site with most PII** | HR site: 1,842 SSN matches | Week 1 remediation priority |
| **Most common SIT** | Credit Card: 3,421 matches | Strengthen payment processing DLP |
| **Label gaps** | 2,103 high-confidence files unlabeled | Configure auto-apply retention labels |
| **Old sensitive data** | 1,318 files 3+ years old with PII | Flag for deletion approval (remediation workflow) |

---

#### Export and Integration Capabilities for Reporting

Generate comprehensive reports using Content Explorer data:

**Export from Content Explorer:**

1. Navigate to desired view (by SIT, location, or label)
2. Click **Export** button
3. Download `.csv` file with:
   - File paths and locations
   - Detected SITs and confidence levels
   - Applied sensitivity/retention labels
   - Timestamps and metadata

**Use Exported Data For:**

- **Stakeholder Reporting**: Executive summaries of PII distribution
- **Remediation Planning**: Input for deletion/retention decisions (Supplemental Lab: Advanced Remediation)
- **Compliance Audits**: Demonstrate classification coverage and accuracy
- **Trend Analysis**: Track classification improvements over time

**Export Functionality:**

- Click **Export** button in Content Explorer.
- Downloads CSV with complete classification data for offline analysis.
- Useful for: Custom reporting, remediation planning, stakeholder communications.

---

#### Remediation Workflow Integration

Use Content Explorer findings to inform data lifecycle decisions:

**High-Risk Files** (3+ years old with PII):

- Export files meeting age + sensitivity criteria.
- Cross-reference with business owners for deletion approval.
- Apply retention labels to prevent accidental deletion before review.

**Business-Critical Files:**

- Identify files with high-sensitivity labels but critical retention needs.
- Apply appropriate retention labels to balance security and compliance.

**Compliance Gaps:**

- Files with PII but no protection (no sensitivity labels).
- Files with sensitivity labels but no retention labels.
- Manual review candidates for reclassification.

---

## 📚 Optional: Manual Site Re-indexing for Accelerated Classification

This optional technique can accelerate classification updates when needed. It is not required for the core lab workflow but may be useful in specific scenarios.

**When to Consider Manual Re-indexing:**

- New sensitivity labels created and need immediate application.
- Custom SITs added and historical content needs reclassification.
- After bulk remediation to update Content Explorer.
- Accelerating classification for demo/validation purposes.

**Trigger Manual Reindex:**

**For Entire Site:**

- Navigate to your SharePoint site.
- **Settings** (gear icon) → **Site information** → **View all site settings**.
- Under **Search**, click **Search and offline availability**.
- Click **Reindex site** button.
- Click **OK** to confirm.

**For Specific Document Library:**

- Navigate to the document library.
- **Settings** (gear) > **Library settings**.
- Click **Advanced settings**.
- Scroll to **Reindex Document Library**.
- Click **Reindex Document Library** button.
- Click **OK** to confirm.

**For Specific List:**

- Navigate to the list.
- **Settings** (gear) > **List settings**.
- Click **Advanced settings**.
- Scroll to **Reindex List**.
- Click **Reindex List** button.
- Click **OK** to confirm.

> **⚠️ Impact of Reindexing**: Forces full recrawl of all content. For large sites, this can take hours or days. Use selectively for specific libraries/lists when possible instead of full site reindex.

**Expected Timeline:**

| Scope | Typical Reindex Duration | Classification Availability |
|-------|-------------------------|----------------------------|
| Small library (100s of files) | 15-30 minutes | +30 min for policy application |
| Medium library (1000s of files) | 1-4 hours | +1-2 hours for policy application |
| Large site (10,000+ files) | 4-24 hours | +2-4 hours for policy application |
| Entire site collection | 24-72 hours | +4-8 hours for policy application |

**Monitor Reindex Progress:**

- No built-in progress indicator in SharePoint.
- Check Content Explorer or Activity Explorer for updated classification results.
- Verify by searching for recently updated metadata in SharePoint search.

---

## ✅ Lab Validation Checklist

Before proceeding, verify you have completed all core objectives:

### DLP Policy and Real-Time Detection (Steps 1-2)

- [ ] DLP policy created and active for SharePoint test site
- [ ] Activity Explorer shows ~400 DLPRuleMatch events within 30 minutes of policy creation
- [ ] Activity Explorer export CSV downloaded with file names and SIT types
- [ ] PowerShell DLP effectiveness analysis script executed successfully
- [ ] DLP effectiveness report generated: `C:\PurviewLab\DLP_Effectiveness_Report.txt`

### Content Explorer SIT Analysis (Step 3)

- [ ] Content Explorer (Classic) accessible from Information Protection → Explorers
- [ ] Sensitive info types tree shows Credit Card Number with ~200 file count
- [ ] Sensitive info types tree shows U.S. SSN with ~200 file count
- [ ] Clicking each SIT shows detailed file list with SharePoint paths and confidence scores
- [ ] Location filter successfully narrows results to test site
- [ ] Export CSV successfully downloaded: `C:\PurviewLab\ContentExplorer_SIT_Export.csv`
- [ ] Export contains expected ~400 file records with SIT details

### Advanced PowerShell Analysis (Step 4)

- [ ] PowerShell SIT distribution analysis script executed successfully
- [ ] SIT type distribution shows Credit Card (200) and SSN (200) breakdown
- [ ] SharePoint site distribution analysis identifies test site
- [ ] Confidence score analysis shows mostly High (85-100%) detections
- [ ] High-risk files identified (multiple SIT instances or high confidence)
- [ ] Stakeholder compliance report generated: `C:\PurviewLab\SIT_Analysis_Stakeholder_Report.txt`

### Detection Method Understanding

- [ ] Understand difference between Activity Explorer (real-time events) vs Content Explorer (inventory)
- [ ] Know when to use Activity Explorer for real-time monitoring and incident response
- [ ] Know when to use Content Explorer for comprehensive SIT inventory and compliance reporting
- [ ] Understand both tools are included with Microsoft Purview DLP licensing at no additional cost
- [ ] Can articulate appropriate tool selection for SIT detection projects (reference Overview section)

---

## 🔍 Troubleshooting

### Issue: Word COM Automation Fails During Document Generation

**Symptoms**: Script fails when trying to create Word documents with error "Failed to initialize Word" or "Cannot create COM object"

**Solutions:**

1. **Verify Microsoft Word is installed**: Check that Microsoft Office/Word is installed on the machine running the script
   - Open Word manually to confirm installation
   - Ensure Word is activated with a valid license
2. **Run PowerShell as Administrator**: COM automation may require elevated permissions
   - Right-click PowerShell and select "Run as Administrator"
   - Re-run the script with administrative privileges
3. **Check Office/Word version compatibility**: Ensure Office version supports COM automation
   - Office 2016 or later recommended
   - Microsoft 365 Apps fully supported
4. **Disable Office Protected View**: Protected View can interfere with COM automation
   - Open Word → **File** → **Options** → **Trust Center** → **Trust Center Settings**
   - Under **Protected View**, uncheck "Enable Protected View for files originating from the Internet"
5. **Alternative approach - Manual document creation**: If COM automation continues to fail:
   - Use the test script output to create a few Word documents manually with sample PII content
   - Upload manually created documents to SharePoint for initial testing
   - Create at least 10-20 documents with varied SSN and Credit Card patterns for validation
6. **Close existing Word instances**: COM automation can conflict with open Word windows
   - Close all Word windows before running the script
   - Check Task Manager for hidden WINWORD.EXE processes

> **💡 Production Consideration**: For production scenarios requiring large-scale document generation, consider:
>
> - Using SharePoint document templates and PnP provisioning
> - Leveraging Microsoft Graph API with Office Online for document creation
> - Employing PowerShell Open XML SDK for programmatic .docx creation (no Word required)

---

### Issue: Activity Explorer Not Showing DLP Events

**Symptoms**: DLP policy created but Activity Explorer shows zero events after 30+ minutes

**Solutions**:

1. **Verify DLP policy status**: Navigate to **Data loss prevention** → **Policies** and confirm policy shows as **Active**
2. **Check policy scope**: Ensure your SharePoint test site is included in policy locations
3. **Verify audit logging**: Navigate to **Audit** and confirm "Start recording user and admin activity" is enabled for 24+ hours
4. **Confirm test data has sensitive content**: Open a few test documents and verify they contain credit card numbers or SSNs
5. **Wait longer**: In some tenants, Activity Explorer can take up to 2 hours for initial sync
6. **Check date filter**: Expand Activity Explorer date range to "Last 30 days" to capture earlier events
7. **Review DLP rules**: Confirm rules are enabled (not disabled) and configured with correct SIT types

### Issue: Content Explorer Not Showing SIT Detections

**Symptoms**: DLP policy working in Activity Explorer, but Content Explorer shows no SIT detections after 48+ hours

**Solutions**:

1. **Wait for data sync**: Content Explorer requires 24-48 hours (sometimes up to 72 hours) for initial population
2. **Verify Activity Explorer has data**: If Activity Explorer shows DLP events, Content Explorer will eventually sync
3. **Check date filters**: In Content Explorer, ensure date filters aren't excluding your data range
4. **Refresh portal**: Sign out and back in to Microsoft Purview portal to force data refresh
5. **Verify DLP policy scope**: Content Explorer only shows detections from active DLP policies
6. **Check SIT tree**: Expand "Sensitive info types" tree - if you see Credit Card Number or U.S. SSN nodes, data is syncing
7. **Use modern Content Explorer**: If classic version unavailable, use modern Content Explorer with similar filtering

### Issue: Content Explorer Export CSV is Empty

**Symptoms**: Export button works but downloaded CSV contains zero records or only headers

**Solutions**:

1. **Verify results visible in UI**: Before exporting, confirm Content Explorer tree shows file counts next to SIT names
2. **Check export scope**: Ensure you selected "Current view" (not "All sensitive info types" if you want filtered results)
3. **Wait for export processing**: Large exports (>10,000 files) may take several minutes to generate
4. **Try smaller scope**: Filter to specific SIT type or location before exporting
5. **Check download location**: Verify CSV downloaded to correct folder (default: Downloads folder)
6. **Alternative export**: Use Activity Explorer export as backup (captures DLP events with file paths)

### Issue: PowerShell Analysis Scripts Show Unexpected Results

**Symptoms**: PowerShell SIT analysis shows very different counts than Content Explorer UI

**Solutions**:

1. **Verify CSV file path**: Confirm PowerShell script is loading correct export CSV file
2. **Check CSV structure**: Open CSV in Excel and verify columns match expected format (Name, Location, Sensitive info type, etc.)
3. **Review CSV encoding**: Ensure CSV exported with UTF-8 encoding (not UTF-16 or ANSI)
4. **Validate import**: Add `$sitData | Get-Member` to PowerShell script to verify CSV columns imported correctly
5. **Check for duplicate exports**: Ensure you're analyzing the most recent Content Explorer export
6. **Compare with Activity Explorer**: Cross-reference counts with Activity Explorer DLP events for validation

### Issue: SIT Detection Counts Don't Match Test Data

**Symptoms**: Expected ~400 detections (40% of 1,000 files) but seeing significantly different counts

**Solutions**:

1. **Verify test data upload**: Confirm all 1,000 documents successfully uploaded to SharePoint
2. **Check document content**: Open sample files and verify they contain PII (SSNs, credit cards)
3. **Review DLP policy rules**: Ensure policy includes both Credit Card Number and U.S. SSN SIT types
4. **Check confidence thresholds**: DLP policy may be using high confidence thresholds that filter some matches
5. **Wait for full sync**: Initial DLP scan may take 30-60 minutes to process all 1,000 documents
6. **Verify SharePoint indexing**: Use SharePoint search to confirm all documents are indexed
7. **Review file formats**: Ensure documents are .docx format (not .txt or other formats that may not scan correctly)

### Issue: Understanding Tool Selection for SIT vs Trainable Classifiers

**Symptoms**: Confusion about when to use Activity Explorer, Content Explorer, or On-Demand Classification

**Decision Matrix:**

| Goal | Correct Tool | Why |
|------|--------------|-----|
| **Find files with credit cards, SSNs, passport numbers** | **Content Explorer (Classic)** + Activity Explorer | Uses DLP detection engine for pattern matching |
| **Monitor DLP policy matches** | **Activity Explorer** | Shows DLP events within 24-48 hours |
| **Generate compliance report of SIT detections** | **Content Explorer (Classic) export** | Provides file inventory with SIT details |
| **Categorize documents by type (Resumes, Financial Statements)** | **On-Demand Classification** (Supplemental Lab 03) | Uses ML models for document type classification |
| **Create custom detection patterns** | **Custom SITs** (Supplemental Lab 03 Part A) | Regex-based pattern definitions |
| **Train ML model for document categorization** | **Trainable Classifiers** (Supplemental Lab 03 Part B) | Requires training samples and ML model creation |

**Key Principle**: **SITs** (pattern detection like credit cards) → Use **DLP + Content Explorer**. **Trainable Classifiers** (ML document categorization like "Resume") → Use **On-Demand Classification** (covered in Supplemental Lab 03).

---

## 🎯 Key Learning Outcomes

After completing this lab, you have demonstrated the following production-level competencies:

**Technical Skills:**

**Technical Skills:**

- ✅ **DLP Policy Deployment**: Deploy and configure SharePoint DLP policies for real-time SIT protection.
- ✅ **Activity Explorer Analysis**: Monitor and analyze DLP policy events (24-48 hours).
- ✅ **Content Explorer Mastery**: Use Content Explorer (Classic) for comprehensive SIT inventory reporting (24-48 hours).
- ✅ **PowerShell Automation**: Build advanced PowerShell scripts for SIT distribution analysis and stakeholder reporting.
- ✅ **Tool Selection**: Understand when to use Activity Explorer vs Content Explorer vs On-Demand Classification.

**Business Skills:**

- ✅ **Compliance Reporting**: Generate executive summaries and stakeholder compliance reports.
- ✅ **Risk Assessment**: Identify high-risk files based on SIT instances, confidence scores, and business context.
- ✅ **Cost Optimization**: Leverage free DLP+Content Explorer tools instead of paid on-demand classification for SITs.
- ✅ **Detection Timing**: Plan security strategies based on detection speed (Activity: 24-48 hours, Content: 24-48 hours).

**Production Readiness:**

- ✅ **Appropriate Tool Usage**: Use correct tools for SIT detection (DLP+Content Explorer) vs document classification (Trainable Classifiers).
- ✅ **Reporting Automation**: Automate SIT detection reports for quarterly compliance reviews.
- ✅ **Audit Trail**: Maintain comprehensive DLP event history and SIT inventory for compliance audits.
- ✅ **Stakeholder Communication**: Translate technical SIT detection data into business-focused compliance reports.

---

## 🏁 Completion Confirmation

Before moving to the next lab or cleanup, verify:

- [ ] DLP policy successfully deployed and detecting sensitive content in SharePoint.
- [ ] Activity Explorer validated with ~400 DLPRuleMatch events within 30 minutes.
- [ ] Content Explorer (Classic) showing Credit Card Number (~200) and U.S. SSN (~200) detections.
- [ ] Content Explorer CSV export downloaded with SIT detection details.
- [ ] PowerShell SIT distribution analysis executed with results saved.
- [ ] Stakeholder compliance report generated and reviewed.
- [ ] Understand Content Explorer is correct tool for SITs (not on-demand classification).
- [ ] Know when to use Supplemental Lab 03 for Trainable Classifiers and on-demand classification.

---

## 🎯 Lab 02 Completion Summary

**Skills Acquired:**

✅ **SIT Detection with DLP**: DLP protection and Activity Explorer event monitoring (24-48 hours).
✅ **Content Explorer Reporting**: Comprehensive SIT inventory analysis and export (24-48 hours).
✅ **PowerShell Automation**: Advanced SIT distribution analysis and stakeholder reporting scripts.
✅ **Tool Selection Mastery**: Distinguish between SITs (DLP+Content Explorer) vs Trainable Classifiers (On-Demand Classification).
✅ **Cost-Effective Approach**: Leverage free DLP+Content Explorer tools for SIT analysis vs paid on-demand classification.
✅ **Compliance Reporting**: Generate executive summaries and audit-ready SIT detection reports.
✅ **Detection Timing Understanding**: Plan security strategies based on Activity Explorer (24-48 hours) and Content Explorer (24-48 hours) data aggregation timing.

**What This Lab Covered (SIT Detection):**

- ✅ **DLP Policy Deployment**: Real-time protection for SharePoint sensitive data.
- ✅ **Activity Explorer**: Real-time DLP event monitoring and timeline analysis.
- ✅ **Content Explorer (Classic)**: Comprehensive SIT inventory, filtering, and export.
- ✅ **PowerShell Analysis**: Automated SIT distribution reporting and compliance summaries.

**What This Lab Did NOT Cover (Trainable Classifiers):**

- ❌ **On-Demand Classification**: Not appropriate for SIT detection (designed for Trainable Classifiers).
- ❌ **Custom Trainable Classifiers**: ML-based document categorization (see Supplemental Lab 03 Part B).
- ❌ **Custom SIT Creation**: Regex-based pattern definitions (see Supplemental Lab 03 Part A).
- ❌ **Document Type Classification**: Categorizing files as "Resumes", "Financial Statements", etc..

**Project Alignment:**

This lab provides production-ready skills for:

- **SIT Detection and Reporting**: Using DLP + Content Explorer for pattern-based sensitive data discovery.
- **Real-Time Protection**: Activity Explorer for security monitoring and incident response.
- **Compliance Reporting**: Automated stakeholder reports for audit and remediation planning.
- **Cost-Effective Approach**: Free DLP+Content Explorer tools instead of paid classification scans.

**Integration with Other Labs:**

| Lab | Integration Point | Benefit |
|-----|-------------------|---------|
| **Module 03 (Cloud-03)** | Basic SIT detection foundation | Advanced reporting and analysis builds on Module 03 basics |
| **Supplemental Lab 03** | Custom SITs + Trainable Classifiers | Create custom detection patterns and ML document categorization |
| **Advanced Reporting Lab** | Cross-platform analysis | Combine SharePoint SIT data with on-premises scanner results |
| **Advanced Remediation Lab** | Remediation automation | Use Content Explorer exports to drive automated cleanup workflows |

**Next Steps:**

- **Supplemental Lab 03: Custom-Classification**: Learn Custom SITs (Part A) and Trainable Classifiers (Part B) with on-demand classification
- **Advanced Reporting Lab**: Combine SharePoint SIT detections with on-premises scanner results for unified reporting
- **Advanced Remediation Lab**: Use Content Explorer exports to build automated sensitive data remediation workflows

---

## 📚 Reference Documentation

All lab steps are validated against current Microsoft Learn documentation (November 2025):

- [Learn about data loss prevention](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp)
- [Activity explorer in Microsoft Purview](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)
- [Content explorer in Microsoft Purview](https://learn.microsoft.com/en-us/purview/data-classification-content-explorer)
- [Sensitive information type entity definitions](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)
- [Learn about trainable classifiers](https://learn.microsoft.com/en-us/purview/classifier-learn-about)
- [On-demand classification in Microsoft Purview](https://learn.microsoft.com/en-us/purview/on-demand-classification) (for Trainable Classifiers - covered in Supplemental Lab 03)

---

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of SharePoint DLP analysis, Activity Explorer monitoring, and Content Explorer validation while maintaining technical accuracy for cloud sensitive information type detection.*
