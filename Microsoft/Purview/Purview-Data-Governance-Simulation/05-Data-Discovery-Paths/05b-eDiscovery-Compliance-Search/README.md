# Lab 05b: eDiscovery Compliance Search Discovery (24-Hour Timeline)

## 📋 Overview

This lab demonstrates **official Purview-based sensitive data discovery** using Microsoft 365 eDiscovery Compliance Search to detect Sensitive Information Types (SITs) with **100% Purview accuracy**. Unlike Lab 05a's immediate regex-based scanning, this method uses Microsoft's native SIT detection engine and provides results within **24 hours** after SharePoint indexing completes.

**What You'll Accomplish**:

- Validate SharePoint Search indexing status for Lab 03 uploaded content
- Create eDiscovery Compliance Search with 8 targeted SIT types
- Execute search across all 5 simulation SharePoint sites
- Analyze official Purview SIT detection results (100% accurate)
- Compare eDiscovery findings with Lab 05a regex results for accuracy validation
- Export results for cross-method comparison and reporting

**Duration**: 24 hours wait time + 30-45 minutes hands-on portal configuration

**Method**: Portal-based Microsoft Purview eDiscovery with no scripting required

**Output**: Official Purview SIT detections exportable in CSV format for analysis

> **⏱️ Timing by Lab 02 Scale Level**:
>
> | Lab 02 Scale | Wait Time (Indexing) | Search Duration | Export Time |
> |--------------|---------------------|-----------------|-------------|
> | **Small** | 24 hours | 5-10 minutes | 2-5 minutes |
> | **Medium** (Lab 03 default) | 24 hours | 10-15 minutes | 5-10 minutes |
> | **Large** | 24 hours | 15-30 minutes | 10-20 minutes |
>
> **🔍 Scale Reference**: Wait time is consistent (24 hours for SharePoint Search indexing), but search execution and export times scale with document volume.
>
> **⚠️ Indexing Requirement**: eDiscovery Compliance Search relies on SharePoint Search index. Lab 03 content requires **up to 24 hours** to be indexed before discovery. Use `Test-ContentIndexingStatus.ps1` to check readiness before proceeding.

---

## 🎯 Learning Objectives

By completing this lab, you will:

- Understand SharePoint Search indexing timeline (24 hours vs 7-14 days for Microsoft Search)
- Validate content indexing status before executing eDiscovery searches
- Configure eDiscovery Compliance Search with targeted SIT detection
- Execute portal-based discovery using official Purview SIT detection engine
- Compare official SIT results (100% accuracy) with regex-based results (70-90%)
- Export and analyze eDiscovery findings for cross-method validation
- Establish ground truth dataset for evaluating other discovery methods

---

## 📚 Prerequisites

### Required Labs

- **Lab 02**: Test Data Generation (completed - provided synthetic sensitive documents)
- **Lab 03**: Document Upload & Distribution (completed **24+ hours ago** for indexing)
- **Lab 05a (recommended)**: PnP Direct File Access (provides comparison baseline)

### Required Access

- **Microsoft 365 Role**: eDiscovery Manager or Compliance Administrator
- **SharePoint Sites**: Read access to all simulation sites from Lab 03
- **Microsoft Purview Portal**: Access to [purview.microsoft.com](https://purview.microsoft.com)

### Optional Prerequisites

- **Lab 04**: On-Demand Classification (in progress - compare when complete after 7 days)
- Basic understanding of eDiscovery concepts and Purview portal navigation

### Timing Considerations

**When to Start This Lab**:

- ✅ **24+ hours after Lab 03 completion** (allows SharePoint Search indexing)
- ✅ **While Lab 04 is running** (parallel discovery - Lab 04 takes 7 days)
- ⚠️ **Before Labs 05c/05d** (those require 7-14 days for Microsoft Search indexing)

---

## 🏗️ Architecture & Method Comparison

### Discovery Timeline Comparison

| Method | Indexing Wait | Execution Time | Accuracy | Automation |
|--------|---------------|----------------|----------|------------|
| **Lab 05a: PnP Direct** | None (immediate) | 60-90 min | 70-90% (regex) | ✅ Scripted |
| **Lab 05b: eDiscovery** | **24 hours** | **10-15 min** | **100% (Purview SITs)** | ❌ Portal-based |
| **Lab 05c: Graph API** | 7-14 days | 5-10 min | 100% (Purview SITs) | ✅ Scripted |
| **Lab 05d: SharePoint Search** | 7-14 days | 5-10 min | 100% (Purview SITs) | ✅ Scripted |

> **💡 Key Insight**: eDiscovery uses SharePoint's **search index** (24-hour indexing) rather than the full **Microsoft Search unified index** (7-14 days). This provides official Purview SIT accuracy much faster than waiting for Content Explorer results while maintaining 100% detection quality.

### How eDiscovery Search Works

```text
┌─────────────────────────────────────────────────────────────┐
│ Lab 03: Upload Documents to SharePoint                      │
│ • 5 simulation sites                                         │
│ • ~5000 files (Medium scale)                                │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ SharePoint Search Indexing (24 Hours)                       │
│ • Files crawled and indexed                                 │
│ • Metadata extracted                                         │
│ • Content made searchable                                    │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ eDiscovery Compliance Search (Lab 05b)                      │
│ 1. Create search with 8 targeted SIT types                  │
│ 2. Select all 5 simulation sites                            │
│ 3. Execute search (10-15 min)                               │
│ 4. Review results with Purview SIT detection               │
│ 5. Export findings for analysis                             │
└─────────────────────────────────────────────────────────────┘
```

This lab searches for the same 8 SITs used in the Purview Data Governance Simulation project:

1. **U.S. Social Security Number (SSN)**
2. **Credit Card Number**
3. **U.S. Bank Account Number**
4. **U.S./U.K. Passport Number**
5. **U.S. Driver's License Number**
6. **U.S. Individual Taxpayer Identification Number (ITIN)**
7. **ABA Routing Number**
8. **International Bank Account Number (IBAN)**

---

## 🔧 Lab Workflow

### Step 1: Validate Content Indexing Status

Before creating the eDiscovery search, verify that Lab 03 content has been indexed by SharePoint Search.

#### Option 1: Use Validation Script (Recommended)

```powershell
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05b-eDiscovery-Compliance-Search\scripts"
.\Test-ContentIndexingStatus.ps1
```

This script automatically:

- ✅ Checks for files modified in the last 48 hours (default window)
- ✅ Evaluates if content exceeds 24-hour indexing threshold
- ✅ Provides clear readiness status with percentage score
- ✅ Generates status report saved to `reports/` directory

**Optional Parameters**:

```powershell
# Check larger time window (72 hours) with custom threshold
.\Test-ContentIndexingStatus.ps1 -HoursToCheck 72 -IndexingThresholdHours 24
```

**Expected Output When Ready** (24+ hours after Lab 03):

```text
🔍 Starting Content Indexing Status Check...
==========================================

📋 Step 1: Load Configuration
============================
✅ Configuration loaded
   🔧 Tenant: https://yourtenant.sharepoint.com/
   🔧 Sites to check: 5

🔍 Step 2: Scan SharePoint Sites for Recent Files
================================================

📊 Time Window Configuration:
   Current Time: 2025-11-17 16:45:00
   Looking back: 48 hours (2.0 days)
   Window Start: 2025-11-15 16:45:00
   Indexing Threshold: 24 hours
   Ready Cutoff: 2025-11-16 16:45:00

💡 Logic: Files modified before cutoff time (24 hrs ago) are likely indexed

🔐 Connecting to SharePoint...
✅ Connected successfully

📂 Scanning: HR-Simulation
   URL: https://yourtenant.sharepoint.com/sites/HR-Simulation
   ✅ Found 1550 total files, 1550 recent files

📂 Scanning: Finance-Simulation
   ✅ Found 1400 total files, 1400 recent files

📂 Scanning: Legal-Simulation
   ✅ Found 950 total files, 950 recent files

📂 Scanning: Marketing-Simulation
   ✅ Found 1100 total files, 1100 recent files

📂 Scanning: IT-Simulation
   ✅ Found 0 total files, 0 recent files

📊 Scan Summary:
   Total sites scanned: 5
   Total recent files found: 5000

⚖️  Step 3: Evaluate Indexing Readiness
======================================

📊 Recent File Analysis:
   Files modified in window: 5000
   Oldest recent file: [FileName]
   From site: HR-Simulation
   Modified: 2025-11-16 14:30:00
   Age: 26.3 hours

✅ Content likely fully indexed - ready for eDiscovery search
   Oldest recent file age: 26.3 hours
   Required minimum: 24 hours
   Status: All recent files exceed indexing threshold

📊 Readiness Score: 100%

📋 Step 4: Next Steps
=====================

✅ Proceed with Lab 05b eDiscovery Compliance Search:

   1. Navigate to purview.microsoft.com
   2. eDiscovery > Cases (preview)
   3. Create search in Content Search case
   4. Configure 8 targeted SIT types with Condition builder
   5. Include all 5 simulation SharePoint sites
   6. Run query and review Statistics

💡 Tip: 5000 files modified in the last 48 hours are ready for search

📊 Step 5: Generate Status Report
==================================

CurrentTime            : 2025-11-17 16:45:00
WindowStartTime        : 2025-11-15 16:45:00
HoursChecked           : 48
IndexingThresholdHours : 24
SitesScanned           : 5
TotalRecentFiles       : 5000
OldestFileAge          : 26.3
ReadinessScore         : 100
IsReady                : True
Status                 : Ready

📋 Per-Site Breakdown:

Site                 TotalFiles RecentFiles OldestRecent
----                 ---------- ----------- ------------
HR-Simulation              1550        1550 11/16/2025 2:30:00 PM
Finance-Simulation         1400        1400 11/16/2025 2:35:00 PM
Legal-Simulation            950         950 11/16/2025 2:40:00 PM
Marketing-Simulation       1100        1100 11/16/2025 2:45:00 PM
IT-Simulation                 0           0

✅ Status report saved: ..\reports\Indexing-Status-2025-11-17-164500.json

✅ Lab 05b eDiscovery Compliance Search is ready to proceed!
   All content modified in the last 48 hours has exceeded the 24-hour indexing threshold
```

**Expected Output When Not Ready** (<24 hours after Lab 03):

```text
⚖️  Step 3: Evaluate Indexing Readiness
======================================

📊 Recent File Analysis:
   Files modified in window: 5000
   Oldest recent file: [FileName]
   From site: HR-Simulation
   Modified: 2025-11-17 05:36:41
   Age: 10.8 hours

❌ Content not ready - wait before proceeding with eDiscovery
   Oldest recent file age: 10.8 hours
   Required minimum: 24 hours
   Recommend waiting: 13.2 more hours

📊 Readiness Score: 45%

📋 Step 4: Next Steps
=====================

⏳ Wait for indexing to complete, then proceed:

   Recommended wait time: 13.2 hours
   Check back after: 2025-11-18 05:36:41

🔄 While Waiting:
   • Review Lab 05a PnP Direct File Access results
   • Monitor Lab 04 On-Demand Classification progress
   • Read eDiscovery documentation and prepare search query

🔁 Run this script again later to recheck status
```

> **⚠️ Important**: If the script indicates content is not ready, wait the recommended time before proceeding. Incomplete indexing will result in zero or partial search results.

---

### Step 3: Create eDiscovery Search for Targeted SIT Detection

Use the modern eDiscovery experience to create a search for sensitive information types.

**Step 3a: Navigate to eDiscovery**:

1. In the Microsoft Purview portal, select the **eDiscovery** solution card
2. In the left navigation, select **Cases (preview)**
3. You'll see the default **Content Search** case (or create a new case for organization)

> **💡 Tip**: The "Content Search" case provides a convenient location for standalone searches without creating a formal eDiscovery case. For lab purposes, you can use this default case or create a dedicated case named "Lab-05b-SIT-Discovery".

**Step 3b: Create New Search**:

1. Select the **Content Search** case (or your custom case)
2. On the **Searches** tab, click **Create a search**
3. On the **Enter details to get started** page:
   - **Search name**: `Lab05b-SIT-Discovery-Search`
   - **Search description**: "Targeted SIT detection across 5 simulation sites - Lab 05b eDiscovery method"
4. Click **Create** to proceed to search configuration

**Step 3c: Add Data Sources (SharePoint Sites)**:

1. On the **Query** tab, in the **Data sources** section, click the **+** icon (Search and add), then select **Add data sources**
2. In the **Add data sources** flyout, you'll see a list of users and groups by default
3. In the **Filter** section on the left, configure:
   - **Locations to include**: Select **Sites only** (to exclude mailboxes and only search SharePoint sites)
4. In the **Search** section, use the search box to find your SharePoint sites by entering the site URL:
   - Enter: `https://yourtenant.sharepoint.com/sites/HR-Simulation`
   - Click **Search** - the site group will appear in the results
   - Select the checkbox next to the site group that appears
5. Repeat the search process for each of the remaining simulation sites:
   - `https://yourtenant.sharepoint.com/sites/Finance-Simulation`
   - `https://yourtenant.sharepoint.com/sites/Legal-Simulation`
   - `https://yourtenant.sharepoint.com/sites/Marketing-Simulation`
   - `https://yourtenant.sharepoint.com/sites/IT-Simulation`
6. After selecting all 5 sites, click **Save and close** to confirm data sources
7. Back on the Query tab, verify all 5 sites appear in the **Data sources** section

> **💡 Search Tip**: When you enter a SharePoint site URL in the search box, the system filters to show the Microsoft 365 group associated with that site. Selecting the group adds the site as a data source.
>
> **⚠️ Important**: Ensure you have **Sites only** selected in the **Locations to include** filter. This prevents mailboxes from being added and focuses the search on SharePoint content only.

**Step 3d: Configure Search Query with Condition Builder**:

Use the Condition Builder to specify Sensitive Information Types (SITs):

1. On the **Query** tab, ensure **Condition builder** mode is selected (default)
2. The **Keywords** condition appears by default - leave it empty (we're searching by SITs only)
3. Click **Add conditions** below the Keywords field
4. The **Choose which conditions to add** flyout appears with recently used and common conditions visible
5. Click **Show more** to see all available conditions
6. In the flyout, configure the condition finder:
   - In the **Filter conditions by area** section, select **SharePoint and OneDrive sites** to narrow options
   - In the **Tell us what you're looking for** search box, type "Sensitive information type"
   - Select **Sensitive Type** from the filtered results
7. Click **Add** to add the SIT condition to your query
8. **Critical Step**: In the condition that was added, change the operator from **Equal** to **Equal any of** (this ensures OR logic instead of AND logic)

**Step 3e: Select Target Sensitive Information Types**:

Configure the 8 specific SITs for detection with instance count and confidence levels:

1. After adding the **Sensitive Type** condition and changing the operator to **Equal any of**, click in the **Value** field
2. **Important - Query Logic Structure**: The query must maintain this structure:
   - **Keywords** (blank) **AND** (connects to first condition)
   - **Sensitive information type (SIT) Equal any of** [all 8 SITs with OR logic between them]
   - The top-level connection between Keywords and the SIT condition should remain **AND**
   - Within the SIT condition itself, all 8 types are connected with **OR** logic (achieved by using "Equal any of" operator)
   - This structure finds documents matching any of the 8 SITs (not requiring all SITs simultaneously)
3. In the SIT selection interface, you'll configure each SIT with its parameters. Add all 8 SITs one at a time by clicking **+ Add value** after each:
   - **U.S. Social Security Number (SSN)** - Min: `1`, Max: `500`, Confidence: **High**
   - **Credit Card Number** - Min: `1`, Max: `500`, Confidence: **High**
   - **U.S. Bank Account Number** - Min: `1`, Max: `500`, Confidence: **High**
   - **U.S./U.K. Passport Number** - Min: `1`, Max: `500`, Confidence: **High**
   - **U.S. Driver's License Number** - Min: `1`, Max: `500`, Confidence: **Medium**
   - **U.S. Individual Taxpayer Identification Number (ITIN)** - Min: `1`, Max: `500`, Confidence: **High**
   - **ABA Routing Number** - Min: `1`, Max: `500`, Confidence: **High**
   - **International Banking Account Number (IBAN)** - Min: `1`, Max: `500`, Confidence: **High**
4. After adding all 8 SITs, your condition will show: **Sensitive information type (SIT) Equal any of** with all 8 SIT types listed
5. This creates the correct OR logic: documents containing **any one or more** of these 8 SITs will match

> **💡 Configuration Recommendations**:
>
> - **Min count**: Set to `1` to detect documents with at least one instance of the SIT
> - **Max count**: Use `500` (the maximum supported value) for broadest detection. While Microsoft documentation references "Any" as a valid value, the Condition Builder UI requires a numeric value. Setting a specific lower number (e.g., `5`) helps identify high-risk documents with many instances
> - **Confidence levels**:
>   - **High (85-100%)**: Fewest false positives, recommended for most SITs (SSN, Credit Card, Bank Account, Passport, ITIN, ABA Routing, IBAN)
>   - **Medium (66-84%)**: Balanced detection, useful for Driver's License numbers which have more format variations
>   - **Low (≤65%)**: Most permissive, higher false positive rate
>
> **⚠️ UI Limitation**: The Condition Builder UI does not accept "Any" as a literal text value in the Max count field despite documentation indicating it's supported in the underlying query syntax. Always use numeric values (1-500) when configuring SITs through the portal interface.
>
> **⚠️ Critical - Operator Selection**: You **must** use the **Equal any of** operator (not **Equal**) when adding multiple SITs. Using the default **Equal** operator and adding multiple separate SIT conditions creates AND logic, which requires documents to contain ALL SITs simultaneously (resulting in zero matches). The **Equal any of** operator creates the correct OR logic where documents matching ANY of the selected SITs will be found.

**Step 3f: Save Search Configuration**:

1. Review your search configuration:
   - **Data sources**: 5 SharePoint simulation sites
   - **Keywords**: (empty - searching by SITs only)
   - **Conditions**: Sensitive information type (SIT) - Equal any of [8 SITs listed]
2. Click **Save as draft** to save the search without running it yet

> **✅ Configuration Complete**: Your search is now configured to scan 5 SharePoint sites for 8 specific types of sensitive information using OR logic (documents matching any of the 8 SITs will be found). The search is saved and ready to execute.

---

### Step 4: Run the eDiscovery Search

Execute the search to detect sensitive information across your SharePoint sites.

**Step 4a: Initiate Search Execution**:

1. In your case, on the **Searches** tab, select `Lab05b-SIT-Discovery-Search`
2. On the search details page, click **Run query**
3. In the **Choose search results** flyout, select your view preference:
   - **Statistics**: Generates summary with categories, SIT types, errors (recommended for first run)
   - **Sample**: Generates representative sample of results
4. For Statistics view, check **Include categories** to see SIT type breakdown
5. Click **Run query** to start execution

> **⚠️ Expected Warning**: You may see this warning message when running the search (this is normal and can be ignored for discovery purposes):
>
> "This search query uses conditions (Identifier, Sensitivity label, and Sensitive Type) that are only supported in the modern eDiscovery experience. Do not use this query to run purges or delete data, as it will result in unintended data loss."
>
> This warning appears because your query uses modern eDiscovery features (SIT conditions). It's simply alerting you that this type of query should not be used for data deletion operations. **For discovery and export purposes (this lab's objective), this warning can be safely ignored.**

**Step 4b: Monitor Search Progress**:

The search executes and processes content from all 5 SharePoint sites:

1. The **Statistics** tab shows processing status
2. Monitor the progress indicator as the search runs
3. Typical completion time: 5-15 minutes depending on content volume

**Expected Progress Indicators:**

```text
🔍 Search status: Running
   ⏳ Processing data sources...
   ⏳ Analyzing content against SIT conditions...
   
🔍 Search status: Completed
   ✅ Data sources processed: 5
   ✅ Items analyzed: 5000+
   ✅ Items matching conditions: 4000-5000 (typical for Medium scale)
```

> **💡 Performance Note**: Search execution time varies based on the number of files indexed since Lab 03. The eDiscovery search engine analyzes content against all 8 specified SIT patterns in a single pass.
>
> **⚠️ Troubleshooting**: If the search remains in "Running" status for more than 30 minutes, check the **Errors** category in Statistics view for indexing issues or permission problems with specific sites.

**Step 4c: Troubleshooting Zero Results**:

If your search returns no results, verify your query syntax:

1. On the search details page, check the **Query** syntax displayed
2. The query should show OR logic between SIT conditions:

   ```text
   ((SensitiveType="<guid1>|1..500|85..100")) OR ((SensitiveType="<guid2>|1..500|85..100")) OR ...
   ```

3. If you see AND operators between SIT conditions instead of OR, you need to recreate the search:
   - Delete the current search
   - Follow Step 3d to ensure you use the **Equal any of** operator
   - The issue occurs when using the default **Equal** operator with multiple separate SIT conditions

---

### Step 5: Review Search Results and Statistics

Analyze the search findings using the modern eDiscovery statistics and sample views.

**Step 5a: Access Statistics Summary**:

After search completion, the **Statistics** tab displays comprehensive results:

1. **Summary section** shows overall statistics:
   - **Total matches**: Total items matching the search query (e.g., 4423 items, 2.9 MB)
   - **Locations**: Number of locations searched that had hits (e.g., 4/5)
   - **Data sources**: Number of people, groups and tenant locations that had hits (e.g., 4/5)

2. **Search hit trends** section provides detailed breakdowns:
   - **Top data sources**: Data sources that make up the most search hits
   - **Top sensitive information types (SITs)**: SITs in SharePoint files most often included in search hits
   - **Top Item Classes**: Most seen item classes within search hits
   - **Top communication participants**: Senders or recipients for emails, Teams chats, and calendar invites (not applicable for SharePoint-only searches)
   - **Top location type**: Hit count by location type (mailbox vs site)

**Step 5b: Review Top Data Sources**:

In the **Search hit trends** section, view the **Top data sources** chart:

1. This shows which data sources (SharePoint sites) have the most search hits
2. For each data source, you'll see:
   - **Site name**: e.g., "[Your-Tenant] - HR", "[Your-Tenant] - Finance"
   - **Item count**: Number of items with SIT detections
3. Expected distribution (Medium scale from Lab 02):
   - **HR-Simulation**: 1500-1600 items (highest - employee records, benefits)
   - **Finance-Simulation**: 1100-1200 items (financial documents, invoices)
   - **Marketing-Simulation**: 800-900 items (customer data)
   - **Legal-Simulation**: 800-900 items (contracts, agreements)
   - **IT-Simulation**: 0 items (technical documentation, no sensitive data)
4. Click **View top 100** to see the complete list of data sources

**Step 5c: Review Top Sensitive Information Types (SITs)**:

In the **Search hit trends** section, view the **Top sensitive information types (SITs)** chart:

1. This shows which SITs are most often included in the search hits
2. For each SIT type, you'll see:
   - **SIT name**: e.g., "U.S. Social Security Number (SSN)"
   - **Item count**: Number of items containing this SIT
3. Expected top SITs (based on Lab 02 data generation):
   - **Custom**: 2700-2800 items (custom SITs from your tenant)
   - **U.S. Social Security Number (SSN)**: 2200-2300 items (highest volume from targeted list)
   - **All Full Names**: 1500-1600 items (built-in entity detection)
   - **EU Tax Identification Number (TIN)**: 1300-1400 items
   - **EU Passport Number**: 1000-1100 items
4. Click **View top 100** to see the complete list of detected SIT types

> **💡 Note**: The results may include SITs beyond your 8 targeted types. Microsoft Purview's search engine detects all sensitive information types present in the content, not just those specified in your query conditions. The query filters which **documents** to return (those containing your 8 targeted SITs), but the statistics show **all SITs detected** within those documents.

**Step 5d: Review Additional Statistics**:

1. **Top Item Classes**: Shows the item types (e.g., "IPM.File" for all file types)
   - Expected: All 4423 items will show as "IPM.File" for SharePoint documents
2. **Top communication participants**: Shows email/Teams participants
   - Expected: "No data" (not applicable for SharePoint-only searches)
3. **Top location type**: Shows mailbox vs site distribution
   - Expected: All items show as "Site" (4423 items)

**Step 5e: View Sample Results (Optional)**:

To view detailed file-level information with actual document samples, you need to generate sample results:

> **⚠️ Sample Tab Behavior**: The **Sample** tab shows **no data** by default because you initially ran the query with "Statistics" view (Step 4a). Sample results are only generated when you explicitly run the query with "Sample" view selected.

**To Generate Sample Results**:

1. From the search details page, click **Run query** again
2. In the **Choose search results** flyout, select **Sample** (instead of Statistics)
3. Configure sample parameters:
   - **Sample size**: Select **10** items per location (provides representative sample without long processing time)
   - The sample will be randomly selected from your search results
4. Click **Run query** to generate the sample
5. Wait for sample generation to complete (typically 2-5 minutes)
6. Once complete, the **Sample** tab will display individual files

**Viewing Sample Results**:

After sample generation completes, the Sample tab shows:

- **File listing**: Individual documents that match your search query
- **File metadata**: Name, location, author, modified date for each document
- **Content preview**: Click on any item to attempt preview
  - **Supported formats**: .txt, .html, .eml, .pdf files can be previewed directly in the browser
  - **Word documents (.docx)**: Cannot be previewed in-browser - you'll see "Preview not available" or similar message
  - **To view Word documents**: Click **Download original item** to download the file, then open it locally in Microsoft Word
- **SIT highlights**: For previewable formats, sensitive information types detected are highlighted in the preview pane

> **💡 Preview Limitation**: Since Lab 03 uploads primarily Word documents (.docx format), most sample results will show **"Preview not available"**. This is expected behavior - Word documents require download for viewing. The file metadata (name, location, SIT types detected) is still visible in the listing, which provides sufficient information to validate search accuracy.
>
> **💡 Is This Step Necessary?**: Sample results are **optional** for this lab. The Statistics view (Step 5a-5d) already provides comprehensive analysis with total counts, SIT distribution, and site-level breakdowns. Sample results are most useful when you need to:
>
> - Verify the quality and relevance of detected content
> - Review actual documents before exporting the entire dataset
> - Confirm specific SIT patterns are being detected correctly
>
> **For this lab's objectives** (comparing discovery methods and validating SIT detection), the Statistics view provides sufficient information. You can proceed directly to Step 6 (Export) without generating sample results.

---

### Step 6: Export Search Results for Analysis

**Step 6a: Initiate Export**:

1. From the search details page (while viewing any tab - Statistics, Sample, or Query), locate the **Export** button at the top of the page
2. Click **Export** to begin the export process
3. In the **Export** flyout pane that appears, configure the following options:

**Export Configuration**:

- **Export name**: `Lab05b-SIT-Discovery-Export` (or accept default name based on search)
- **Export description**: "Lab 05b eDiscovery search results for SIT analysis and cross-method comparison" (optional)

**Select items to include in your export**:

- Select **Indexed items that match your search query** (recommended - exports only items matching your 8 targeted SITs)
- Alternative: **Indexed items that match your search query and partially indexed items that might not match query** (includes potential partially-indexed items)

**Additional export options**:

- **Enable de-duplication for Exchange content**: Optional (not applicable for SharePoint-only searches)
- **Include versions for SharePoint documents**: Optional (includes document version history if needed)

4. Click **Export** to start preparing the export package

> **💡 Export Process**: The export process copies search results from SharePoint to a Microsoft-provided Azure Storage location. This preparation typically takes 20-35 minutes depending on the number of items (4000-5000 items for Medium scale).

**Step 6b: Monitor Export Status**:

1. From the search details page, click **Process manager** in the left navigation
   - Alternatively, select **Process manager** from the **Searches** area to see all search-related processes
2. In the Process manager view, locate your export process in the list
3. The Process manager displays comprehensive export information:
   - **Export name**: Your export name (e.g., `Lab05b-SIT-Discovery-Export`)
   - **Status**: Current export status (see status progression below)
   - **Process type**: "Export"
   - **Created**: Date and time export was initiated
   - **Completed**: Date and time export finished (blank until complete)
   - **Duration**: Running time for the export process
   - **Created by**: Your user account

**Status Progression**:

- **In progress**: Export package is being created and uploaded to Azure Storage
  - Click on the export name to view detailed progress with progress bar, estimated completion time, and elapsed time
  - The **Overview** tab shows number of locations processed and items exported in real-time
- **Complete**: Export is ready for download
- **Failed**: Export encountered an error (check error details in Process manager)
- **Canceled**: Export was manually stopped by user

4. Monitor the status until it shows **Complete** (typically 20-35 minutes for 4000-5000 items)

> **⏱️ Timing Note**: Export preparation time varies based on:
>
> - Number of items (4423 items = ~10 minutes)
> - Total data size (2.9 MB = faster, larger datasets = longer)
> - Current Microsoft 365 service load
>
> **💡 Process Manager Benefits**: Unlike the legacy Exports tab, Process manager provides real-time progress tracking with percentage complete, estimated time remaining, and detailed status information for active exports.

**Step 6c: Download Export Packages**:

> **💡 Portal Note**: As of November 2025, Microsoft Purview uses a modernized export download process that does NOT require an export key or the legacy eDiscovery Export Tool. Export packages download directly from the browser using pre-authorized links.

1. On the **Exports** tab, click on your completed export name to open the export details flyout
2. Review the **Export packages** section, which shows the packages available for download:
   - **Reports-Content_Search-Lab05b_SIT_Discove...** (Reports package with Results.csv) - ~741 KB
   - **Items.1.001.Lab05b_SIT_Discovery_Export** (Content package with actual files) - ~4.05 MB
   - Each package shows its size to help you plan download time
3. Enable browser pop-ups by clicking **Allow browser pop-ups to download files** at the top of the page if prompted
4. **Download packages one at a time** to avoid browser download issues:
   
   **First: Download Reports Package**
   - Check the box next to the **Reports-Content_Search-Lab05b_SIT_Discove...** package (~741 KB)
   - Click **Download** at the top of the flyout page
   - Wait for the download to complete before proceeding to Items package
   
   **Second: Download Items Package (Optional)**
   - Uncheck the Reports package box
   - Check the box next to the **Items.1.001.Lab05b_SIT_Discovery_Export** package (~4.05 MB)
   - Click **Download** again
   - Monitor the download progress in your browser

> **📦 Multiple Export Packages**: Large exports are split into multiple packages (typically a Reports package with CSV files and one or more Items packages with actual file content). **Download packages one at a time** - selecting multiple packages simultaneously may result in only one package downloading, causing confusion.

> **⚠️ Download Requirements**:
>
> - **Allow pop-ups**: Configure your browser to allow pop-ups from purview.microsoft.com
> - **Automatic downloads**: Set browser to "Allow" automatic downloads for the Purview portal
> - **Download location**: Set your preferred download folder or allow browser to prompt for location
> - **Network access**: Ensure your organization allows downloads from Microsoft Purview endpoints

**Step 6d: Monitor Package Downloads**:

1. The packages will download directly from your browser (no export tool required)
2. **Download timing** (when downloading packages one at a time):
   - **Reports package** (741 KB): Typically completes in 30 seconds - 2 minutes
   - **Items package** (4.05 MB): Typically completes in 2-5 minutes
3. By default, packages download to your browser's default download folder (e.g., `C:\Users\YourName\Downloads\`)
4. **Recommended**: Move the downloaded .zip files to the project reports folder for organization:
   - Destination: `C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05b-eDiscovery-Compliance-Search\reports\`

#### Step 6e: Extract Reports Package

Extract the Reports package to access Results.csv for analysis:

**Use extraction script (Recommended - bypasses Windows Defender block)**:

```powershell
# Navigate to scripts folder
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05b-eDiscovery-Compliance-Search\scripts"

# Extract Reports package only
.\Expand-eDiscoveryExportPackages.ps1 -ExtractReports
```

The script automatically:

- Finds the most recent Reports package by name pattern
- Handles timestamped file names dynamically
- Extracts to the reports\ folder
- Verifies Results.csv exists
- Provides clear status and next steps

After extraction, verify you have the key files in the `reports\` folder:

**Reports Package Contents** (required for Lab 05b analysis):

- **Summary-YYYY-MM-DD_HH-MM-SS.csv**: High-level export statistics including job details, search query, start/end times, security filters, and overall results summary
- **Locations-YYYY-MM-DD_HH-MM-SS.csv**: Per-site breakdown showing data source names, SharePoint site URLs, item counts, sizes, and status for each location searched
- **Settings-YYYY-MM-DD_HH-MM-SS.csv**: Export configuration settings including decryption options, output formats, indexing parameters, and feature toggles
- **Items_0_YYYY-MM-DD_HH-MM-SS.csv**: Detailed item-level results with full metadata for each detected file (file names, locations, sensitive types, authors, dates, SharePoint paths, etc.) - **primary file for analysis scripts**

> **💡 File Naming**: All Reports package files include timestamps (YYYY-MM-DD_HH-MM-SS) matching your export execution time. The Items_0 file is the primary analysis input containing all detection results.

#### Step 6f: Extract Items Package (Optional)

If you downloaded the Items package and want to review actual file content:

**Use extraction script (Recommended)**:

```powershell
# Navigate to reports folder
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05b-eDiscovery-Compliance-Search\reports"

# Extract Items package
Expand-Archive -Path "Items.1.001.Lab05b_SIT_Discovery_Export.zip" -DestinationPath ".\" -Force
```

> **💡 Note**: Replace the file name with your actual Items package name if it differs.

After extraction, verify the Items package contents:

**Items Package Contents** (optional, contains actual files):

- **SharePoint/** folder with site-specific subfolders:
  - **HR-Simulation/Shared Documents/** - Benefits enrollments, employee records (.docx, .xlsx, .txt, .pdf)
  - **Finance-Simulation/Shared Documents/** - ACH authorizations, financial documents (.docx, .pdf)
  - **Legal-Simulation/Shared Documents/** - Background checks, legal agreements (.pdf, .docx)
  - **Marketing-Simulation/Shared Documents/** - Customer data, mixed analysis files (.docx, .xlsx)
- Each site subfolder contains the **Shared Documents/** library with actual files that matched the search query
- Files are organized exactly as they appear in SharePoint with original filenames and formats
- Useful for reviewing actual file content and validating SIT detections, but not required for Lab 05b analysis which uses Items_0 CSV file

> **📂 Package Structure**: Items package mirrors the SharePoint site structure: `SharePoint/[Site-Name]/Shared Documents/[Files]`. This allows you to review the actual documents that triggered SIT detections, but the metadata analysis uses the Items_0 CSV from the Reports package.

> **💡 Performance Tips**:
>
> - Use a local drive for downloads (not network/UNC path or external USB drive)
> - Avoid OneDrive or synced cloud folders during download
> - Temporarily disable antivirus scanning if download speeds are slow
> - Enable parallel downloading in your browser settings for faster large file downloads

#### Step 6g: Verify Extraction Completion

Confirm all export files are successfully extracted and ready for analysis:

**Verify Reports Package Files** (in `reports\` folder):

```powershell
# Check for extracted Reports package CSV files
Get-ChildItem "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05b-eDiscovery-Compliance-Search\reports" -Filter "*.csv" | Format-Table Name, Length, LastWriteTime
```

You should see:

- **Summary-YYYY-MM-DD_HH-MM-SS.csv** - Export statistics
- **Locations-YYYY-MM-DD_HH-MM-SS.csv** - Per-site breakdown
- **Settings-YYYY-MM-DD_HH-MM-SS.csv** - Export configuration
- **Items_0_YYYY-MM-DD_HH-MM-SS.csv** - Detection results (primary analysis file)

**Verify Items Package Files** (optional, if downloaded):

```powershell
# Check SharePoint folder structure
Get-ChildItem "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05b-eDiscovery-Compliance-Search\reports\SharePoint" -Directory
```

You should see site folders: **Finance-Simulation**, **HR-Simulation**, **Legal-Simulation**, **Marketing-Simulation**

---

### Step 7: Run Detection Analysis Script

After confirming all export files are extracted and in place, run the analysis script to review eDiscovery detection patterns.

#### Step 7a: Basic Detection Analysis

Run the analysis script with the Items_0 CSV file:

```powershell
# Navigate to scripts folder
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05b-eDiscovery-Compliance-Search\scripts"

# Run analysis (automatically finds most recent Items_0 CSV)
.\Invoke-eDiscoveryResultsAnalysis.ps1
```

> **💡 Automatic File Discovery**: The script automatically finds the most recent Items_0 CSV file in the reports folder based on the timestamp in the filename, eliminating the need to manually specify the file path.

#### Step 7b: Cross-Method Comparison with Lab 05a (Recommended)

**Option 1: Use Centralized Cross-Lab Analysis (Recommended)**:

The Lab 05 directory includes a centralized comparison orchestrator that automatically compares results across all completed discovery methods with comprehensive accuracy metrics:

**Before running**, edit `lab05-comparison-config.json` to enable only Lab 05a and Lab 05b:

```json
{
  "comparisonSettings": {
    "enabledLabs": {
      "lab05a": true,
      "lab05b": true,
      "lab05c": false,
      "lab05d": false
    }
  }
}
```

Once the config file has been updated, change folders and run the comparison script below:

```powershell
# Navigate to Lab 05 root directory
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths"

# Compare Lab 05a and Lab 05b only (filters out incomplete labs)
.\scripts\Invoke-CrossLabAnalysis.ps1 -UseConfig
```

**Benefits of centralized comparison**:

- Automatically finds latest reports from both labs
- Comprehensive accuracy metrics (precision, recall, F1 score)
- Detailed false positive/negative analysis
- Detection overlap matrix
- Consolidated findings report (CSV and optional HTML)
- Configurable filtering and thresholds

> **📚 Configuration Guide**: For detailed configuration options and advanced comparison scenarios, see **[CROSS-LAB-ANALYSIS.md](../CROSS-LAB-ANALYSIS.md)** in the Lab 05 root directory.

---

**Option 2: Use Lab 05b Analysis Script (Quick Comparison)**:

For a quick file-level comparison without advanced metrics:

```powershell
# Navigate to reports folder
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05b-eDiscovery-Compliance-Search\reports"

# Find most recent Items_0 CSV and Lab 05a results, then compare
$items0Csv = Get-ChildItem -Filter "Items_0*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$lab05aPath = "..\..\05a-PnP-Direct-File-Access\reports"
$lab05aCsv = Get-ChildItem -Path $lab05aPath -Filter "PnP-Discovery*.csv" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

.\..\scripts\Invoke-eDiscoveryResultsAnalysis.ps1 `
    -ResultsCsvPath $items0Csv.FullName `
    -Lab05aResultsPath $lab05aCsv.FullName
```

This provides basic comparison metrics integrated with the Lab 05b analysis output.

---

**Comparison Output Examples**:

Both approaches provide accuracy validation between regex-based (Lab 05a) and official Purview SIT (Lab 05b) detection methods:

- **Precision**: Percentage of Lab 05a detections confirmed by eDiscovery (measures false positive rate)
- **Recall**: Percentage of eDiscovery detections captured by Lab 05a (measures false negative rate)
- **Overlapping files**: Files detected by both methods (true positives)
- **False positives**: Files detected by Lab 05a but not eDiscovery (regex over-detection)
- **False negatives**: Files detected by eDiscovery but missed by Lab 05a (regex gaps)

> **💡 Comprehensive Analysis**: For comparing eDiscovery results with other Lab 05 discovery methods (Graph API, SharePoint Search), use the centralized `Invoke-CrossLabAnalysis.ps1` script with appropriate configuration. See the main **[Lab 05 README](../README.md)** for complete cross-method analysis workflows.

---

### Step 8: Understanding SIT GUID Exports and Mapping

**Important**: eDiscovery exports contain **only GUIDs** in the "Sensitive type" column, not friendly SIT names. Some GUIDs may represent **deprecated or renamed Microsoft SITs** that no longer appear in `Get-DlpSensitiveInformationType` results.

#### Why GUIDs Don't Always Resolve

**eDiscovery Export Behavior**:

1. **Historical Scan Results**: eDiscovery exports use **cached detection results** from when files were originally scanned
2. **GUID-Only Format**: The "Sensitive type" column contains only GUIDs separated by `$#,#&` delimiters
3. **Deprecated SITs**: Files scanned with SIT definitions that have since been removed/renamed will export with unresolvable GUIDs
4. **No Friendly Names**: Microsoft Purview exports GUIDs by design; friendly name resolution happens during analysis

**Example Raw Export Format**:

```text
Sensitive type: cb353f78-2b72-4c3c-8827-92ebe4f69fdf$#,#&1771481d-a337-4dbf-8e64-af8da0cc3ee9
```

#### GUID-to-Name Mapping File

The analysis scripts use a centralized mapping file to resolve GUIDs to friendly SIT names:

**Location**: `05-Data-Discovery-Paths\Purview-SIT-GUID-Mapping.json`

This file contains:

- **Universal built-in SIT GUIDs** (consistent across all Microsoft 365 tenants)
- **Deprecated SIT mappings** for legacy GUIDs no longer in tenant definitions
- **Tenant-verified mappings** based on eDiscovery export analysis

**Common Deprecated SITs Found in Exports**:

| GUID | Friendly Name | Status |
|------|---------------|--------|
| `1771481d-a337-4dbf-8e64-af8da0cc3ee9` | U.S. Bank Account Number | Deprecated GUID (SIT renamed/restructured) |
| `11631f87-7ffe-4052-b173-abda16b231f3` | U.S. / U.K. Passport Number | Deprecated GUID (SIT renamed/restructured) |

#### Handling Unmapped GUIDs

If the analysis script detects unmapped GUIDs:

1. **Diagnostic Script Launch**: The analysis script automatically offers to launch `Resolve-UnmappedSITGuids.ps1`
2. **Context Analysis**: The diagnostic script analyzes file patterns, co-occurring SITs, and detection volumes
3. **Intelligent Suggestions**: Provides suggested friendly names based on context:
   - **File pattern matching**: "BenefitsEnrollment" → Employee Benefits Data
   - **Co-occurrence analysis**: Co-occurs with SSN → Related Identity Verification
   - **Volume-based inference**: >1000 occurrences → Likely deprecated built-in SIT
4. **Interactive Mapping**: Confirm or customize suggested mappings before updating the JSON file

**Manual Mapping Addition**:

If you identify a GUID that should be added to the mapping file:

```json
{
  "sitMappings": {
    "your-guid-here": "Friendly SIT Name",
    "1771481d-a337-4dbf-8e64-af8da0cc3ee9": "U.S. Bank Account Number"
  }
}
```

After updating the mapping file, re-run the analysis script to apply the new mappings.

> **💡 Cross-Lab Consistency**: The centralized mapping file ensures **consistent SIT naming across all Lab 05 discovery methods** (05a, 05b, 05c, 05d) for accurate cross-method comparison.

---

## 📊 Expected Results

### Sample eDiscovery Detection Summary

Based on Lab 02's document generation, you should see approximately:

**Overall Statistics** (based on Medium scale from Lab 02):

- **Total matches**: 4000-5000 items (depending on Lab 02 scale level)
- **Total size**: 2-5 MB
- **Locations with hits**: 4-5 sites out of 5 simulation sites
- **Data sources with hits**: 4-5 locations
- **Date range**: Last 7-30 days (depending on Lab 03 execution date)

**SIT Type Distribution**:

| SIT Type | Detections | Confidence Level |
|----------|------------|------------------|
| U.S. Social Security Number | 15-20 | High (85%+) |
| Credit Card Number | 10-15 | High (85%+) |
| U.S. Bank Account Number | 8-12 | Medium (75%+) |
| U.S./U.K. Passport Number | 5-8 | High (85%+) |
| U.S. Driver's License Number | 5-8 | Medium (75%+) |
| ITIN | 3-5 | High (85%+) |
| ABA Routing Number | 8-12 | High (85%+) |
| IBAN | 5-8 | High (85%+) |

**Top 3 Sites by Detection Count**:
1. HR-Simulation: 25-35 detections
2. Finance-Simulation: 20-30 detections
3. Legal-Simulation: 10-15 detections

---

## 🔍 Troubleshooting

### Issue: "No items found" despite Lab 03 content uploaded 24+ hours ago

**Cause**: Content may not be indexed yet, or sites weren't included in search scope

**Solution**:
1. Verify 24 hours have passed since Lab 03 completion
2. Test search with simple keyword query (e.g., "Employee") to verify content is searchable
3. Check that all 5 site URLs are correct in search locations
4. Manually request re-indexing of simulation sites (SharePoint site settings > Advanced settings > Reindex site)

---

### Issue: "Access denied" when trying to create Content Search

**Cause**: Insufficient permissions for eDiscovery

**Solution**:
```powershell
# Request eDiscovery Manager role from tenant admin
# Admin can grant access via Microsoft 365 Admin Center:
# 1. Go to admin.microsoft.com
# 2. Navigate to Roles > eDiscovery Manager
# 3. Add your user account
```

---

### Issue: Search results show different counts than Lab 05a (PnP method)

**Cause**: Expected behavior - Lab 05a uses regex (70-90% accuracy), eDiscovery uses official Purview SITs (100% accuracy)

**Solution**:
This is **not an error**. The differences highlight:
- **eDiscovery detections > PnP detections**: PnP regex missed some patterns (false negatives)
- **PnP detections > eDiscovery detections**: PnP regex over-detected patterns (false positives)

Use eDiscovery results as the "ground truth" for validating Lab 05a accuracy.

---

### Issue: Export download fails or gets stuck

**Cause**: Network interruption or antivirus blocking eDiscovery Export Tool

**Solution**:
1. Check firewall/antivirus isn't blocking the export tool
2. Try downloading from a different network
3. Restart export tool and re-paste export key
4. If persistent, export results to PST format instead of individual files

---

### Issue: Can't find specific SIT type in condition builder

**Cause**: SIT name variation or deprecated SIT type

**Solution**:
Use exact SIT names from Microsoft documentation:
- "U.S. Social Security Number (SSN)" not "Social Security Number"
- "Credit Card Number" not "Credit Card"
- Search for SIT in condition builder with partial name (e.g., "Social")

---

## ✅ Validation Checklist

After completing Lab 05b, verify:

- [ ] **24 hours elapsed** since Lab 03 content upload
- [ ] **Content is indexed** (test search confirmed files are searchable)
- [ ] **Compliance search created** with 8 targeted SIT conditions
- [ ] **All 5 simulation sites** included in search scope
- [ ] **Search completed successfully** within 15 minutes
- [ ] **At least 60 SIT detections** found across all sites
- [ ] **All 8 SIT types detected** at least once
- [ ] **Results exported** to local machine in CSV format
- [ ] **Comparison with Lab 05a** completed (accuracy validation)
- [ ] **Results documented** in lab summary template

---

## 📝 Lab Summary Template

```markdown
# Lab 05b: eDiscovery Compliance Search Discovery - Summary

**Completion Date**: [Date]

**Search Configuration**:
- Search Name: Lab05b-SIT-Discovery-Compliance-Search
- Locations: 5 SharePoint sites (HR, Finance, Legal, Marketing, IT)
- Query Type: Sensitive Information Type detection
- Targeted SITs: 8 (SSN, Credit Card, Bank Account, Passport, Driver's License, ITIN, ABA Routing, IBAN)

**Discovery Results**:
- Total Items Matched: [Count] files
- Locations with Hits: [Count] sites
- Most Common SIT Type: [SIT Name] ([Count] detections)
- Site with Most Sensitive Data: [Site Name] ([Count] detections)

**Search Performance**:
- Search Start Time: [Timestamp]
- Search End Time: [Timestamp]
- Search Duration: [Duration]
- Items Processed: [Count]

**Top 5 Files by SIT Detection**:
1. [FileName] - [Site] - [SIT Types]
2. [FileName] - [Site] - [SIT Types]
3. [FileName] - [Site] - [SIT Types]
4. [FileName] - [Site] - [SIT Types]
5. [FileName] - [Site] - [SIT Types]

**Method Effectiveness**:
- ✅ 100% Purview SIT accuracy (official detection engine)
- ✅ 24-hour wait time acceptable for compliance searches
- ✅ Portal-based interface (no scripting required)
- ✅ Export functionality for further analysis

**Comparison with Lab 05a (PnP Direct Access)**:
- Lab 05a Detections: [Count] files
- Lab 05b Detections: [Count] files
- Overlapping Detections: [Count] files
- Lab 05a Estimated Accuracy: [Percentage]%
- Lab 05a False Positives: [Count] files
- Lab 05a False Negatives: [Count] files

**Next Steps**:
- [ ] Compare with Lab 04 On-Demand Classification (when complete)
- [ ] Wait 7-14 days for Labs 05c/05d (Graph API and SharePoint Search methods)
- [ ] Document accuracy differences between immediate (Lab 05a) and official (Lab 05b) methods
- [ ] Use eDiscovery results as ground truth for validating other discovery methods

**Key Learnings**:
- [Insight about eDiscovery 24-hour indexing timeline]
- [Insight about Purview SIT detection accuracy]
- [Insight about eDiscovery as ground truth for validation]
- [Insight about differences between Lab 05a regex and Lab 05b official SIT detection]
```

---

## 🔗 Related Labs

- **Lab 04**: On-Demand Classification Validation (7-day official Purview scan, Content Explorer results)
- **Lab 05a**: PnP PowerShell Direct File Access (immediate discovery, custom regex)
- **Lab 05c**: Graph API Discovery (7-14 day indexing, automated recurring discovery)
- **Lab 05d**: SharePoint Search Discovery (7-14 day indexing, site-specific queries)

---

## 📚 Additional Resources

- [Microsoft 365 Compliance Search Overview](https://learn.microsoft.com/en-us/purview/ediscovery-content-search)
- [Keyword Queries and Search Conditions for eDiscovery](https://learn.microsoft.com/en-us/purview/ediscovery-keyword-queries-and-search-conditions)
- [eDiscovery Permissions](https://learn.microsoft.com/en-us/purview/ediscovery-assign-permissions)
- [Export Content Search Results](https://learn.microsoft.com/en-us/purview/ediscovery-export-search-results)
- [Sensitive Information Type Entity Definitions](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-entity-definitions)

---

## 🤖 AI-Assisted Content Generation

This comprehensive eDiscovery Compliance Search discovery guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating research findings from Microsoft Learn documentation about eDiscovery timing, SharePoint search indexing delays (24-hour timeline), and the distinction between immediate discovery methods and search index-dependent approaches.

*AI tools were used to enhance productivity and ensure comprehensive coverage of official Purview SIT detection through eDiscovery while maintaining technical accuracy and reflecting Microsoft 365 compliance and data governance best practices for multi-method sensitive data discovery scenarios.*
