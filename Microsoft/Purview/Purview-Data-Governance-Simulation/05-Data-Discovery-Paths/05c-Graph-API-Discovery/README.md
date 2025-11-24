# Lab 05c: Graph API Discovery (Post-Indexing Automated Discovery via API)

## 📋 Overview

This lab guides you through **automated discovery and reporting** of sensitive data using the Microsoft Graph eDiscovery API. This method uses PowerShell automation to programmatically create eDiscovery cases, run searches, and initiate exports - **the same workflow as Lab 05b but initiated via API** instead of manual portal clicks.

**Workflow**: API calls → Create Case → Create Search → Initiate Export → Manual Download (15-30 min) → Extract → Analyze

**Timeline**: 24 hours after Lab 03 content upload (SharePoint Search indexing delay) + **15-30 minute export processing**

**Duration**: 2-3 hours initial setup, then API-initiated workflow

**Approach**: PowerShell automation with Microsoft Graph eDiscovery API for export initiation, then manual download and extraction using Lab 05b scripts

**Output**: CSV reports with SIT detection data, identical to Lab 05b

> **🤖 API Automation vs. Manual Portal**: This lab produces **identical results to Lab 05b** (same SIT data, same accuracy, same export format) but uses:
>
> - **Lab 05b**: Manual portal clicks → Create search → Export → Download → Extract (15-30 min)
> - **Lab 05c**: PowerShell API calls → Create search → Initiate export → Monitor in portal → Download → Extract (15-30 min)
>
> **⏱️ Processing Time**: Export processing takes **15-30 minutes** for large datasets (4,400+ files).
>
> **🔄 When to Use Lab 05c**: Choose this when you need **API-initiated discovery** (programmatic case/search creation, recurring scans, integration with other systems). For fully manual one-time discovery, Lab 05b is simpler.

---

## 🎯 Learning Objectives

After completing this lab, you will be able to:

- Configure Microsoft Graph API permissions for eDiscovery operations
- Create and manage eDiscovery cases programmatically via Graph API
- Automate eDiscovery searches using PowerShell and Graph API
- Export search results programmatically (same data as Lab 05b portal export)
- Generate JSON/CSV reports with SIT detection data via API
- Understand Graph API authentication and permission management
- Compare manual portal workflow (Lab 05b) vs. automated API workflow (Lab 05c)
- Implement scheduled/recurring discovery scans via automation
- Integrate eDiscovery data into custom reporting systems

---

## ⏱️ Timeline Comparison - Understanding Graph API Discovery Timing

| Method | Timeline | Search Index Required? | Workflow | Accuracy | Reliability Rank | Best Use Case |
|--------|----------|----------------------|----------|----------|------------------|---------------|
| **Lab 05a: PnP Direct File Access** | Immediate | ❌ No | PowerShell direct access | 70-90% (regex) | ⚡ Quick but error-prone | Immediate discovery, learning |
| **Lab 05b: eDiscovery (Manual)** | 24 hours | ✅ Yes (SharePoint Search) | Portal UI → Direct export → Download → Extract (15-30 min) | 100% (Purview SITs) | ✅ Reliable, manual | One-time compliance searches |
| **Lab 05c: eDiscovery (API)** | **24 hours** | **✅ Yes (SharePoint Search)** | **Graph API → Initiate export → Monitor/download → Extract (15-30 min)** | **100% (Purview SITs)** | **🏆 Reliable, API-initiated** | **API-driven workflows, recurring scans** |

> **⚠️ Critical Timing Requirement**: Lab 05c relies on the **SharePoint Search index** (same backend as Lab 05b), which requires **24 hours** to fully index newly uploaded SharePoint content from multi-user sites. The eDiscovery API queries this same index used by the eDiscovery Center and Content Search. Start this lab **24 hours after Lab 03 (Document Upload)** to ensure content is searchable. For immediate results, use **Lab 05a** instead.
>
> **🤖 Lab 05b vs. Lab 05c - Same Data, Different Method**:
>
> - **Lab 05b (Manual)**: Portal UI clicks → Create search → Export → Download → Extract (15-30 min total)
> - **Lab 05c (API)**: PowerShell script → Create search via API → Initiate export via API → Monitor in portal → Download → Extract (15-30 min total)
>
> **📊 Identical Output**: Both produce the same Items_0.csv with populated "Sensitive type" column containing SIT GUIDs.
>
> **💡 When to Choose Each Method**:
>
> - **Lab 05b**: Fully manual workflow, prefer UI for all steps, one-time discovery
> - **Lab 05c**: API-initiated discovery, programmatic case/search creation, recurring scans, system integration

---

## 📚 Prerequisites

**Required**:

- ✅ **Completed Lab 03** (Document Upload) **24 hours ago** (SharePoint Search indexing time)
- ✅ Completed Lab 04 (Classification Validation) for comparison baseline
- ✅ PowerShell 7.0+ installed ([Download here](https://github.com/PowerShell/PowerShell/releases))
- ✅ Azure AD Global Administrator or Application Administrator role (for one-time permission grant)
- ✅ Basic PowerShell scripting knowledge (or willingness to learn)

> **💡 Timing Note**: Lab 05c has the same 24-hour indexing timeline as Lab 05b (both use SharePoint Search index). For immediate results, use:
>
> - **Lab 05a (PnP Direct File Access)**: Immediate results with custom regex

**Optional**:

- Azure AD app registration for unattended automation (recommended for production)
- SIEM or dashboard integration endpoint (Splunk, Azure Sentinel, etc.)
- JSON viewer for analyzing report outputs

---

## 🏗️ Architecture Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                   Microsoft Graph API                        │
│                    (eDiscovery API)                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ HTTPS Queries
                       │
┌──────────────────────▼──────────────────────────────────────┐
│              PowerShell Automation Scripts                   │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │ Authentication │  │ Search & Query │  │ Report Export  │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ Output
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                   Report Outputs                             │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────────┐ │
│  │ JSON Files │  │ CSV Files  │  │ Trend Analysis Logs    │ │
│  └────────────┘  └────────────┘  └────────────────────────┘ │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ Optional Integration
                       │
┌──────────────────────▼──────────────────────────────────────┐
│            SIEM / Dashboard / Task Scheduler                 │
│    (Splunk, Azure Sentinel, Power BI, Scheduled Tasks)      │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Lab Workflow

### Phase 1: Lab Setup and Readiness Confirmation

Before running automated discovery, complete the following setup steps to ensure your environment is properly configured and your SharePoint sites are indexed and ready for Graph API queries.

---

#### Step 1: Install Required PowerShell Modules

Install the Microsoft Graph PowerShell SDK for authentication and API access:

Open PowerShell 7 as Administrator and run:

```powershell
# Remove any existing Microsoft.Graph modules to avoid version conflicts
Get-Module Microsoft.Graph* -ListAvailable | Uninstall-Module -Force

# Install Microsoft Graph SDK to system-wide location (avoids OneDrive sync conflicts)
Install-Module Microsoft.Graph -Scope AllUsers -Force -AllowClobber

# Verify installation
Get-Module Microsoft.Graph -ListAvailable
```

**Expected Output**:

```text
ModuleType Version    PreRelease Name
---------- -------    ---------- ----
Script     2.x.x                 Microsoft.Graph
```

> **💡 Note**: The Microsoft Graph SDK is a collection of modules. The installation may take 3-5 minutes depending on your connection speed. If you encounter version conflicts, the uninstall step above ensures a clean installation.
>
> **⚠️ Administrator Required**: This installation uses `-Scope AllUsers` to install modules to `C:\Program Files\PowerShell\Modules\`, avoiding OneDrive sync conflicts that can occur with user profile directories. You must run PowerShell 7 **as Administrator** for this installation method.
>
> **⚠️ Version Conflict Resolution**: If you see errors like "Could not load type 'Microsoft.Graph.Authentication.AzureIdentityAccessTokenProvider'", this indicates module version conflicts. Close all PowerShell windows, reopen PowerShell 7 as Administrator, and repeat the installation steps above.

---

#### Step 2: Grant Microsoft Graph eDiscovery Permissions

Run the permission grant script to configure necessary eDiscovery API permissions:

> **💡 Standard PowerShell Session**: You can now close the Administrator PowerShell window and open a **standard PowerShell 7 session** (non-administrator). Step 2 and all subsequent steps use delegated permissions and do not require local administrator rights.

Navigate to the lab scripts directory:

```powershell
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05c-Graph-API-Discovery\scripts"
```

Execute the permission grant script:

```powershell
.\Grant-GraphPermissions.ps1
```

**What this script does**:

- Connects to Microsoft Graph with admin consent
- Grants the following delegated permissions:
  - `eDiscovery.Read.All` - Read eDiscovery cases and searches
  - `eDiscovery.ReadWrite.All` - Create and manage eDiscovery cases and searches
- Creates an interactive authentication session

**Expected Prompts**:

1. **Sign-in prompt**: Authenticate with your Azure AD admin account
2. **Consent prompt**: Review and accept the requested permissions
3. **Success message**: "✅ Graph API permissions granted successfully"

> **⚠️ Security Note**: These are **Read-Only** permissions. The automation cannot modify content, only discover and report on classified data. Always follow the principle of least privilege in production environments.

---

#### Step 3: Test Graph API Connectivity

Validate that authentication and permissions are working correctly:

Run the connectivity test script:

```powershell
.\Test-GraphConnectivity.ps1
```

**What this script tests**:

- Microsoft Graph authentication flow
- Permission validation (eDiscovery.Read.All, eDiscovery.ReadWrite.All)
- eDiscovery case creation and deletion
- API response parsing

**Expected Output**:

```text
🔬 Step 4: Test eDiscovery Case Creation
========================================

⏳ Creating temporary eDiscovery case...
✅ Successfully created test eDiscovery case
   • Case ID: 184b003a-f824-4063-8c9d-abb28aa8a7a6
   • Case Name: Connectivity-Test-20251122-120624

⏳ Cleaning up test case...
✅ Test case deleted successfully

🎯 eDiscovery API access validated:
   • Case creation: Working
   • Case deletion: Working
   • Permissions: Correctly configured

✅ Graph API connectivity test PASSED
```

> **💡 Troubleshooting**: If authentication fails, ensure you're using an account with appropriate admin roles and that MFA is configured correctly.

---

#### Step 4: Verify Site Indexing Status (Go/No-Go Decision)

Before proceeding with automated discovery, verify that your SharePoint sites are indexed in the SharePoint Search index (used by eDiscovery):

Run the site availability diagnostic:

```powershell
.\Test-SiteAvailability.ps1
```

**What this diagnostic does**:

- Connects to Microsoft Graph API
- Searches for all 5 simulation sites using `Get-MgSite -Search`
- Confirms sites exist in SharePoint
- Verifies sites are indexed in SharePoint Search (required for eDiscovery API discovery)
- Provides clear go/no-go decision for Lab 05c readiness

**Expected Output if Ready**:

```text
✅ DIAGNOSIS: Ready for Lab 05c
═══════════════════════════════════

   ✅ All 5 simulation sites exist in SharePoint
   ✅ All 5 sites are indexed in Graph API Search

   🎯 READY FOR LAB 05C?   YES - Proceed immediately!

   ▶️ Next Steps:
      1. Run: .\Invoke-GraphSitDiscovery.ps1
      2. Expect to find 4,400-4,500 files with sensitive data
      3. Review generated reports in reports\ folder
```

**Expected Output if Not Ready**:

```text
⏳ DIAGNOSIS: Indexing In Progress
═══════════════════════════════════

   ✅ All 5 simulation sites exist in SharePoint
   ⚠️ SharePoint Search indexing NOT complete yet

   🎯 READY FOR LAB 05C?   NOT YET - Wait for indexing to complete

   ⏰ Timeline Estimate:
      • Oldest site created: X hours ago
      • Typical indexing time: 24 hours
      • Estimated hours remaining: Y hours

   💡 Your Options While Waiting:
      1. ⏳ WAIT: Run this diagnostic again in 4-6 hours
      2. ⚡ Lab 05a (PnP): Immediate results (custom regex)
```

> **⚠️ Critical Prerequisite**: If the diagnostic shows "NOT YET - Wait for indexing", **DO NOT proceed with Lab 05c**. The eDiscovery API will return 0 results until sites are fully indexed. Use Lab 05a for immediate results, or wait and re-run this diagnostic in 4-6 hours.

> **💡 How This Works**: The diagnostic uses `Get-MgSite -Search` which queries the same SharePoint Search index that Lab 05c eDiscovery API relies on. If the Search API can find your sites, the eDiscovery API discovery will work. This is the most reliable way to test readiness without running the full discovery scan.

**🎯 Phase 1 Complete**: If the diagnostic shows "YES - Proceed immediately!", your environment is fully configured and ready for automated discovery. Proceed to Phase 2.

---

### Phase 2: Discovery and Analysis

Now that your environment is configured and sites are confirmed indexed, run the automated 3-script discovery workflow.

---

#### Step 5: Create eDiscovery Case and Search

Execute the first script to create an eDiscovery case and configure the search:

Run the case creation script:

```powershell
.\Invoke-GraphSitDiscovery.ps1
```

**What this script does**:

- Creates a temporary eDiscovery case for the search
- Configures an eDiscovery search with SensitiveType query targeting all enabled SITs
- Executes the search across all tenant SharePoint sites
- Retrieves aggregate statistics (total items found, total size)
- **Outputs**: CaseId and SearchId for use in next step

**Expected Output**:

```text
🔍 Starting Microsoft Graph eDiscovery SIT Discovery...
========================================================

📋 Step 3: Create eDiscovery Case
✅ eDiscovery case created: Lab05c-Discovery-20251122-143022
   • Case ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890

📋 Step 4: Create Search with SIT Query
✅ eDiscovery search created: Lab05c-SIT-Search-20251122-143022
   • Search ID: b2c3d4e5-f6a7-8901-bcde-f12345678901
   • Query: SensitiveType:"Credit Card Number" OR SensitiveType:"U.S. Social Security Number (SSN)" OR ...

✅ Case and search created successfully
   • Use CaseId and SearchId for next step
```

---

### Step 6: Initiate Export and Manual Download

Execute the export script to initiate the export operation via Graph API:

Run the export initiation script (auto-discovers most recent Lab05c case and search):

```powershell
.\Export-SearchResults.ps1
```

> **💡 What This Script Does**: The Export-SearchResults.ps1 script ONLY initiates the export via Graph API (equivalent to clicking "Export" in the portal). You will then manually download the completed export from the Compliance Portal and extract it using the local extraction script.

> **💡 Auto-Discovery**: The script automatically finds the most recent Lab05c case (matching `Lab05c-Discovery-*`) and search (matching `Lab05c-SIT-Search-*`) from Step 5. No manual GUIDs needed!
>
> **Manual Override**: To specify a particular case/search: `.\Export-SearchResults.ps1 -CaseId "abc..." -SearchId "def..."`

**What this script does**:

- Auto-discovers the most recent Lab05c case and search (or validates provided GUIDs)
- Initiates direct export operation via Graph API (same as Lab 05b portal "Export" button)
- Provides instructions for monitoring export status and manual download workflow

**Export Processing Time**: Typically 15-30 minutes for large datasets (4,400+ files)

**Expected Output**:

```text
🔍 Step 1: Validate Microsoft Graph Connection
================================================
   ✅ Connected to Microsoft Graph
      • Tenant: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
      • Account: admin@yourtenant.onmicrosoft.com

🔍 Step 2: Discover Case and Search
====================================
   🔎 Discovering Lab05c cases...
   📋 Found 1 active Lab05c case(s):

      [1] Lab05c-Discovery-2025-11-23_150703
          Created: 2025-11-23T15:07:03Z
          Status: active

   ✅ Selected case: Lab05c-Discovery-2025-11-23_150703

   🔎 Auto-discovering most recent Lab05c search in case...
   ✅ Auto-discovered search: Lab05c-SIT-Search-2025-11-23_150703
      • Search ID: bbbbbbbb-cccc-dddd-eeee-ffffffffffff

📦 Step 3: Initiate Direct Export
==================================
   ✅ Export request submitted
      • Export Name: Lab05c-Export-2025-11-23_222921
      • Export ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

✅ Step 4: Export Initiated Successfully
========================================
   📊 Export request submitted successfully
      • Case: Lab05c-Discovery-2025-11-23_150703
      • Search: Lab05c-SIT-Search-2025-11-23_150703
      • Export Name: Lab05c-Export-2025-11-23_222921

   ⏱️  Export Processing Time: Typically 15-30 minutes for large datasets (4,400+ files)

================================================================================================
  📋 Next Steps: Manual Download and Extraction
================================================================================================

🔍 Step 1: Monitor Export Status in Compliance Portal
   1. Navigate to: https://compliance.microsoft.com/ediscovery
   2. Click 'eDiscovery' in left navigation
   3. Open case: Lab05c-Discovery-2025-11-23_150703
   4. Go to 'Exports' tab
   5. Wait for export status to show 'Completed' (refresh periodically)

📥 Step 2: Download Export Package
   Once export status shows 'Completed':
   1. Click the export name: Lab05c-Export-2025-11-23_222921
   2. Click 'Download results' button
   3. Save the .zip file to: C:\REPO\...\05c-Graph-API-Discovery\reports\

📦 Step 3: Extract Export Package
   Run the Lab 05b extraction script with Lab 05c reports folder:

   cd ..\..\05b-eDiscovery-Compliance-Search\scripts
   .\Expand-eDiscoveryExportPackages.ps1 -ReportsFolder '..\..\05c-Graph-API-Discovery\reports'

📊 Step 4: Analyze Extracted Data
   Return to Lab 05c scripts and run analysis:

   cd ..\..\05c-Graph-API-Discovery\scripts
   .\Invoke-GraphDiscoveryAnalysis.ps1

================================================================================================
  ✅ Export Script Complete - Awaiting Manual Download
================================================================================================
```

---

#### Manual Download Workflow (Standard Process)

The export initiation script starts the export process via Graph API. You then monitor and download the completed export from the Compliance Portal, following the same process as Lab 05b Step 5c.

**Step 1: Monitor Export Status in Compliance Portal**:

> **💡 Portal Note**: As of November 2025, Microsoft Purview uses a modernized export download process that does NOT require an export key or the legacy eDiscovery Export Tool. Export packages download directly from the browser using pre-authorized links.

Navigate to the Compliance Portal to monitor export completion:

1. Go to **Compliance Portal**: [https://compliance.microsoft.com/ediscovery](https://compliance.microsoft.com/ediscovery)
2. Click **eDiscovery** in the left navigation
3. Open your case (e.g., `Lab05c-Discovery-2025-11-23_150703`)
4. Go to the **Exports** tab
5. Monitor the export status - wait for **Status: Completed** (typically 15-30 minutes for 4,400+ files)

> **⏱️ Timing Note**: Export preparation time varies based on:
>
> - Number of items (4,400-4,500 items = ~15-30 minutes)
> - Total data size (larger datasets = longer)
> - Current Microsoft 365 service load

**Step 2: Download Export Packages**:

Once the export shows "Completed":

1. On the **Exports** tab, click on your completed export name to open the export details flyout
2. Review the **Export packages** section, which shows the packages available for download:
   - **Reports-Content_Search-Lab05c...** (Reports package with Results.csv) - ~741 KB
   - **Items.1.001.Lab05c_Export** (Content package with actual files) - ~4.05 MB
   - Each package shows its size to help you plan download time
3. Enable browser pop-ups by clicking **Allow browser pop-ups to download files** at the top of the page if prompted
4. **Download Reports package** (required for analysis):
   - Check the box next to the **Reports-Content_Search-Lab05c...** package
   - Click **Download** at the top of the flyout page
   - Wait for the download to complete
   - By default, the package downloads to your browser's default download folder (e.g., `C:\Users\YourName\Downloads\`)
5. **Move the downloaded .zip file** to the Lab 05c reports folder:
   - Destination: `C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05c-Graph-API-Discovery\reports\`

> **💡 Items Package (Optional)**: The Items package contains actual SharePoint files and is optional for Lab 05c analysis. If you want to review actual file content, download it using the same process and move it to the reports folder.

**Step 3: Extract the Downloaded Export**:

Use the Lab 05c extraction script to extract the Reports package:

```powershell
# Ensure you're in the Lab 05c scripts directory
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05c-Graph-API-Discovery\scripts"

# Extract Reports package only
.\Expand-eDiscoveryExportPackages.ps1 -ExtractReports
```

The script automatically:

- Finds the most recent Reports package by name pattern
- Handles timestamped file names dynamically
- Extracts to the reports\ folder
- Verifies Results.csv exists
- Provides clear status and next steps

**Expected Extraction Output**:

```text
📦 eDiscovery Export Package Extraction (Lab 05c)
===================================================

🔍 Step 1: Validate Reports Folder
===================================
   ✅ Reports folder validated
      • Path: C:\REPO\GitHub\Projects\...\05c-Graph-API-Discovery\reports

📋 Step 2: Determine Extraction Scope
======================================
   📄 Extracting Reports package only

📄 Step 3: Extract Reports Package
===================================
   ✅ Found Reports package: Reports-Content_Search-Lab05c-SIT-Search-2025-11-23_155412.zip
   📊 Package details:
      • Size: 741 KB
      • Last Modified: 2025-11-23 15:54:12

   ✅ Reports package extracted successfully
      • Extracted to: C:\REPO\GitHub\Projects\...\05c-Graph-API-Discovery\reports\Reports-Content_Search-Lab05c-SIT-Search-2025-11-23_155412\
      • Files extracted: 3 (Results.csv, Manifest.xml, Export Summary.csv)

   ✅ Items_0.csv ready at: C:\REPO\GitHub\Projects\...\Items_0_2025-11-23_15-54-12.csv

✅ Extraction Complete
======================
   ✅ Reports package extracted and validated
   📄 Items_0.csv ready for analysis

📊 Step 4: Analyze Extracted Data
   Return to Lab 05c scripts and run analysis:

   cd scripts
   .\Invoke-GraphDiscoveryAnalysis.ps1
```

> **💡 Note**: The extraction script automatically finds the most recent `.zip` file matching the export naming pattern. The extracted `Items_0.csv` (or `Results.csv`) contains the same data structure as Lab 05b, with populated "Sensitive type" column containing SIT GUIDs.

**Step 4: Run Analysis on Extracted Data**:

With the Reports package extracted, run the analysis script:

```powershell
# Run analysis (auto-discovers extracted Items_0.csv)
.\Invoke-GraphDiscoveryAnalysis.ps1
```

The analysis script automatically finds the most recent extracted `Items_0.csv` and produces SIT distribution statistics.

---

### Step 7: Review Analysis Results

The analysis script (run in Step 6 after extraction) automatically loads the extracted `Items_0.csv` and generates SIT distribution statistics.

**Expected Analysis Output**:

```text
📊 Step 1: Load Export Data
===========================
   ✅ Loaded Items_0.csv: 4,400-4,500 rows

🔍 Step 2: Parse SIT Detections
================================
   ✅ Parsed SIT GUIDs from "Sensitive type" column
   ✅ Total detection records: 10,000-10,500
   ✅ Unique SIT types: 7

📈 Step 3: Generate Statistics
===============================

   SIT Distribution:
   • SSN: 2,200-2,400 detections (22-24%)
   • Passport: 1,600-1,700 detections (16-17%)
   • ITIN: 1,550-1,650 detections (15-16%)
   • Bank Account: 1,350-1,450 detections (13-14%)
   • ABA Routing: 1,000-1,100 detections (10-11%)
   • Driver's License: 850-950 detections (9-10%)
   • Credit Card: 300-350 detections (3-4%)

✅ Analysis Complete
   📁 Report saved: reports\Lab05c-Analysis-20251123_160530.csv
```

---

### Step 8: Cross-Method Comparison with Labs 05a/05b (Optional)

The Lab 05 directory includes a centralized comparison orchestrator that automatically compares results across all completed discovery methods with comprehensive accuracy metrics:

**Before running**, edit `lab05-comparison-config.json` to enable Lab 05a, Lab 05b, and Lab 05c:

```json
{
  "comparisonSettings": {
    "enabledLabs": {
      "lab05a": true,
      "lab05b": true,
      "lab05c": true
    }
  }
}
```

Once the config file has been updated, change folders and run the comparison script below:

```powershell
# Navigate to Lab 05 root directory
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths"

# Compare all completed labs (filters out incomplete labs)
.\scripts\Invoke-CrossLabAnalysis.ps1 -UseConfig
```

**Benefits of centralized comparison**:

- Automatically finds latest reports from all labs
- Comprehensive accuracy metrics (precision, recall, F1 score)
- Detailed false positive/negative analysis
- Detection overlap matrix
- Consolidated findings report (CSV and optional HTML)
- Configurable filtering and thresholds

> **📚 Configuration Guide**: For detailed configuration options and advanced comparison scenarios, see **[CROSS-LAB-ANALYSIS.md](../CROSS-LAB-ANALYSIS.md)** in the Lab 05 root directory.

---

## 📊 Expected Results

### Direct Export CSV Structure

The `Items_0.csv` file contains complete SIT detection data identical to Lab 05b's manual portal export:

| Column Category | Examples |
|----------------|----------|
| **File Metadata** | FileName, Author, Created, Modified, Size, Detected language |
| **SIT Detection Data** | Sensitive type (populated with SIT GUIDs) |
| **Location Metadata** | Location, Site, Item path, Document link |

### Statistics Summary

**Expected Results for Typical Simulation Dataset**:

- **Total Files Exported**: 4,400-4,500
- **Files with SIT Detections**: 4,400-4,500 (100%)
- **Total SIT Detection Records**: 10,000-10,500 (one row per SIT detection per file)
- **Unique SIT Types**: 7 (all enabled types)
- **Export Timeline**: 5-10 minutes (after 24-hour SharePoint Search indexing)

**SIT Distribution** (Representative from simulation dataset):

| SIT Type | Detection Count | % of Total |
|----------|----------------|------------|
| SSN | 2,200-2,400 | 22-24% |
| Passport | 1,600-1,700 | 16-17% |
| ITIN | 1,550-1,650 | 15-16% |
| Bank Account | 1,350-1,450 | 13-14% |
| ABA Routing | 1,000-1,100 | 10-11% |
| Driver's License | 850-950 | 9-10% |
| Credit Card | 300-350 | 3-4% |

### Cross-Lab Comparison

**Lab 05b (Manual Portal) vs Lab 05c (Graph API Automation)**:

- **Detection Results**: Identical (both use SharePoint Search + official Purview SITs)
- **Expected Variance**: ±1-2% per SIT type (timing differences only)
- **Timeline**: Both 24 hours + 5-10 minutes
- **Output Format**: Identical `Items_0.csv` structure with populated "Sensitive type" column
- **Key Difference**: Lab 05c automates via API for recurring scans, scheduled reports, system integration

---

## ✅ Validation Checklist

After completing all steps, verify:

### Lab 05c Direct Export Workflow (Steps 1-7)

- [ ] ✅ App registration created with correct API permissions (eDiscovery.Read.All, eDiscovery.ReadWrite.All)
- [ ] ✅ Graph API authentication validated via Test-GraphConnectivity.ps1
- [ ] ✅ eDiscovery case created via Graph API (status: active)
- [ ] ✅ eDiscovery search configured with correct SIT query
- [ ] ✅ SharePoint Search indexing complete (24 hours after Lab 03)
- [ ] ✅ Site availability validated via Test-SiteAvailability.ps1
- [ ] ✅ Direct export operation completed (5-10 minutes)
- [ ] ✅ Export package downloaded and extracted successfully
- [ ] ✅ Items_0.csv extracted with 4,400-4,500 rows
- [ ] ✅ Verified "Sensitive type" column is POPULATED (90-100% of rows)
- [ ] ✅ SIT GUIDs present in expected format (comma-separated with $#,#& delimiters)

### Analysis and Validation (Step 7)

- [ ] ✅ Invoke-GraphDiscoveryAnalysis.ps1 executed successfully
- [ ] ✅ Analysis report generated with SIT distribution statistics
- [ ] ✅ All 7 SIT types detected and counted
- [ ] ✅ Total detection records: 10,000-10,500
- [ ] ✅ Detection counts match expected simulation results

### Technical Validation

- [ ] ✅ Items_0.csv contains complete file metadata
- [ ] ✅ "Sensitive type" column populated with SIT GUIDs
- [ ] ✅ Export timeline completed within 5-10 minutes
- [ ] ✅ Output format matches Lab 05b manual portal export
- [ ] ✅ Analysis statistics align with Lab 05b results (±1-2% variance)

---

## ✅ Lab Completion Checklist

Verify you've completed all automation setup and discovery steps:

**Phase 1: Lab Setup and Readiness Confirmation**:

- [ ] **PowerShell Modules**: Installed Microsoft.Graph SDK successfully (Step 1)
- [ ] **eDiscovery Permissions**: Granted eDiscovery.Read.All, eDiscovery.ReadWrite.All (Step 2)
- [ ] **Connectivity Test**: Validated Graph eDiscovery API authentication and case creation (Step 3)
- [ ] **Site Indexing Verification**: Ran `Test-SiteAvailability.ps1` and received "YES - Proceed immediately!" diagnosis - confirms 24-hour SharePoint Search indexing complete (Step 4)

**Phase 2: Graph API Discovery Execution**:

- [ ] **Case Creation**: Executed `Invoke-GraphSitDiscovery.ps1` and created eDiscovery case via Graph API (Step 5)
- [ ] **Search Configuration**: Configured eDiscovery search with SIT query successfully (Step 5)
- [ ] **Direct Export**: Executed `Export-SearchResults.ps1` and exported search results directly (Step 6)
- [ ] **Export Validation**: Verified Items_0.csv extracted with populated "Sensitive type" column (Step 6)
- [ ] **SIT Analysis**: Executed `Invoke-GraphDiscoveryAnalysis.ps1` and analyzed SIT detection data (Step 7)
- [ ] **Results Validation**: Confirmed all 7 SIT types detected with expected counts (Step 7)

---

## 📊 Expected Outcomes

After completing this lab, you will have:

**Deliverables**:

- eDiscovery case and search created via Graph API
- Items_0.csv export with populated SIT detection data
- JSON and CSV analysis reports with SIT distribution statistics
- Cross-lab comparison analysis validating Graph API accuracy matches manual eDiscovery UI

**Skills Acquired**:

- Microsoft Graph API authentication and permission management
- PowerShell automation for eDiscovery workflows
- Direct export operations via Graph API
- Cross-method validation and accuracy assessment
- API-driven compliance reporting and automation

**Knowledge Gained**:

- Graph API capabilities for programmatic eDiscovery
- Automation advantages over manual portal workflows (scheduled scans, recurring reports, system integration)
- API-driven compliance operations
- Integration patterns for automated discovery and reporting

---

## 🎯 Completion Criteria

You have successfully completed Lab 05c when:

- ✅ Graph eDiscovery API permissions are granted and connectivity is validated
- ✅ eDiscovery case and search created successfully via Graph API
- ✅ SharePoint Search indexing validated (24 hours after Lab 03)
- ✅ Direct export workflow executed successfully (Steps 6-7)
- ✅ Export completed within 5-10 minutes
- ✅ Items_0.csv extracted with 4,400-4,500 rows
- ✅ "Sensitive type" column populated with SIT GUIDs (90-100%)
- ✅ All 7 SIT types detected and validated
- ✅ Analysis confirms detection counts match expected simulation results
- ✅ Cross-lab comparison shows ±1-2% variance with Lab 05b (if performed)
- ✅ JSON and CSV reports are saved in the `reports/` folder
- ✅ You understand how Graph API automation achieves the same compliance-grade accuracy as manual eDiscovery UI workflows

---

## 🚀 Next Steps

After completing Lab 05c and cross-lab comparison:

### Option 1: Lab 06 - Cleanup and Reset

If you've completed your discovery objectives, proceed to cleanup:

**[→ Proceed to Lab 06: Cleanup and Reset](../../06-Cleanup-Reset/)**

---

## 🔧 Troubleshooting

### Issue: Microsoft.Graph module version conflicts

**Symptoms**:

- "Could not load type 'Microsoft.Graph.Authentication.AzureIdentityAccessTokenProvider'" error
- Authentication prompt doesn't appear
- Module loading errors during script execution

**Causes**:

- Multiple versions of Microsoft.Graph modules installed
- Conflicting dependencies between Microsoft.Graph.Core and Microsoft.Graph.Authentication
- Cached module assemblies from previous PowerShell sessions

**Solutions**:

```powershell
# Solution 1: Clean reinstall of Microsoft.Graph modules
# Close ALL PowerShell windows first, then open PowerShell 7 as Administrator

# Remove all Microsoft.Graph modules
Get-Module Microsoft.Graph* -ListAvailable | Uninstall-Module -Force

# Clear PowerShell module cache
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\PowerShell\ModuleAnalysisCache" -Force -ErrorAction SilentlyContinue

# Reinstall Microsoft.Graph SDK to system-wide location (avoids OneDrive conflicts)
Install-Module Microsoft.Graph -Scope AllUsers -Force -AllowClobber

# Verify clean installation
Get-Module Microsoft.Graph* -ListAvailable | Select-Object Name, Version

# Close and reopen PowerShell 7 before running lab scripts
```

```powershell
# Solution 2: If Solution 1 doesn't work, use specific module versions
Install-Module Microsoft.Graph -RequiredVersion 2.11.0 -Scope AllUsers -Force -AllowClobber
```

> **💡 Important**: After reinstalling modules, **close all PowerShell windows** and open a fresh PowerShell 7 session before running the lab scripts. This ensures clean module loading without cached assemblies.

---

### Issue: Graph eDiscovery API authentication fails

**Symptoms**: "Insufficient privileges" or "Access denied" errors

**Causes**:

- Insufficient permissions (need eDiscovery.Read.All, eDiscovery.ReadWrite.All)
- Admin consent not granted
- MFA configuration issues

**Solutions**:

- Re-run `Grant-GraphPermissions.ps1` with Global Admin account
- Verify permissions in Azure Portal under **Enterprise Applications > Permissions**
- Check Azure AD sign-in logs for failed authentication details
- Ensure MFA is configured and functional for admin account

---

### Issue: Discovery scan returns no results

**Symptoms**: JSON report shows 0 items found

**Causes**:

- SharePoint Search indexing not complete (requires 24 hours after Lab 03)
- Insufficient eDiscovery permissions
- eDiscovery search query syntax issues

**Solutions**:

- Wait 24 hours after Lab 03 completion for SharePoint Search indexing
- Run `Test-SiteAvailability.ps1` to verify indexing status
- Verify `eDiscovery.Read.All` and `eDiscovery.ReadWrite.All` permissions are granted
- Test connectivity with `Test-GraphConnectivity.ps1`
- Check SharePoint sites are accessible and not private/hidden
- Review script output for eDiscovery API errors or throttling warnings

---

### Issue: Report file access denied

**Symptoms**: "Access to the path is denied" when writing reports

**Causes**:

- Insufficient NTFS permissions on `reports/` folder
- File locked by another process (Excel, antivirus)
- Script running as different user than folder owner

**Solutions**:

- Verify NTFS permissions on `reports/` folder (modify rights needed)
- Close any open CSV/JSON files in Excel or viewers
- Run script as administrator temporarily to test
- Move `reports/` folder to user profile directory (e.g., `Documents\Purview-Reports\`)

---

## 📚 Additional Resources

- [Microsoft Graph eDiscovery API Documentation](https://learn.microsoft.com/en-us/graph/api/resources/ediscovery-ediscoverycase)
- [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview)
- [Graph eDiscovery permissions reference](https://learn.microsoft.com/en-us/graph/permissions-reference#ediscovery-permissions)
- [PowerShell automation best practices](https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/00-introduction)
- [Microsoft 365 eDiscovery solutions](https://learn.microsoft.com/en-us/purview/ediscovery)

---

## 🤖 AI-Assisted Content Generation

This comprehensive automated data discovery guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Graph eDiscovery API best practices, PowerShell automation patterns, and enterprise security operations workflows.

_AI tools were used to enhance productivity and ensure comprehensive coverage of programmatic data discovery while maintaining technical accuracy and reflecting enterprise-grade automation and integration standards._
