# Lab 05d: SharePoint Search Discovery (Post-Indexing Site-Specific Queries)

## 📋 Overview

This lab guides you through **targeted discovery and reporting** of sensitive data using PnP PowerShell and the SharePoint Search API. This approach provides the most granular control over discovery scope, extracting rich metadata (file paths, authors, modified dates) and enabling site-specific deep scans for high-priority areas like HR, Finance, or Legal departments.

**Timeline**: 7-14 days after Lab 03 content upload (Microsoft Search unified indexing delay)

**Duration**: 1-2 hours per site or scope

**Approach**: PnP PowerShell with SharePoint Search API querying Microsoft Search index

**Output**: Site-specific CSV reports with rich metadata and advanced filtering

---

## 🎯 Learning Objectives

After completing this lab, you will be able to:

- Install and configure PnP PowerShell for SharePoint automation
- Authenticate to SharePoint Online using PnP cmdlets
- Execute SharePoint Search queries targeting document libraries
- Extract rich metadata including file paths, authors, modified dates, and file sizes
- Implement custom SIT pattern detection logic for targeted validation
- Generate site-specific detailed reports for compliance and audit
- Apply advanced filtering by date range, file type, or folder path
- Test custom SIT patterns before full tenant-wide rollout

---

## ⏱️ Discovery Method Timeline Comparison

Choose the discovery method that matches your timeline and requirements:

| Lab | Method | Timeline | Microsoft Search Index Required? | SIT Accuracy | Best Use Case |
|-----|--------|----------|----------------------------------|--------------|---------------|
| **Lab 05a** | PnP PowerShell Direct File Access | **Immediate** | ❌ No | 70-90% (regex) | Immediate discovery, learning SIT detection |
| **Lab 05b** | eDiscovery Compliance Search | **24 hours** | ✅ Yes (SharePoint Search) | 100% (Purview) | Official compliance searches |
| **Lab 05c** | Graph API Discovery | **7-14 days** | ✅ Yes (Microsoft Search unified) | 100% (Purview) | Automated recurring discovery |
| **Lab 05d** | SharePoint Search Discovery | **7-14 days** | ✅ Yes (Microsoft Search unified) | 100% (Purview) | Site-specific automated queries |
| **Lab 04** | On-Demand Classification | **7 days** | ❌ No (direct scan) | 100% (Purview) | Portal-based comprehensive scan |

---

## 📚 Prerequisites

**Required**:

- ✅ Completed **Lab 03** (Document Upload) **7-14 days ago** for Microsoft Search unified index population
- ✅ PowerShell 7.0+ installed ([Download here](https://github.com/PowerShell/PowerShell/releases))
- ✅ Site Collection Administrator access to target SharePoint sites
- ✅ Basic PowerShell scripting knowledge

> **⏱️ Critical Timing Requirement**: Lab 05d relies on the **Microsoft Search unified index**, which requires **7-14 days** to index newly uploaded SharePoint content. This is the same index used by Content Explorer and Graph API (Lab 05c). This lab should only be started **7-14 days after Lab 03 (Document Upload)** to ensure content is searchable via SharePoint Search API.
>
> **💡 Faster Alternatives**: If you need results sooner:
>
> - **Lab 05a** (PnP Direct File Access): Immediate results with custom regex detection
> - **Lab 05b** (eDiscovery Compliance Search): 24-hour results with official Purview SITs
> - **Lab 04** (On-Demand Classification): 7-day results with official Purview SITs

**Optional**:

- Custom SIT definitions from your organization (if testing custom patterns)
- Specific site URLs for targeted scanning (HR, Finance, Legal sites)
- CSV viewer or Excel for report analysis

---

## 🏗️ Architecture Overview

```text
┌─────────────────────────────────────────────────────────────┐
│              SharePoint Online Environment                   │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│   │   HR Site    │  │ Finance Site │  │  Legal Site  │     │
│   │  (Targeted)  │  │  (Targeted)  │  │  (Targeted)  │     │
│   └──────────────┘  └──────────────┘  └──────────────┘     │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ PnP PowerShell + Search API
                       │
┌──────────────────────▼──────────────────────────────────────┐
│           SharePoint Search API Queries                      │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ ContentClass:STS_ListItem_DocumentLibrary               │ │
│  │ SensitiveType:"Credit Card Number"                      │ │
│  │ Path:https://tenant.sharepoint.com/sites/HR/*          │ │
│  │ Write>=2025-01-01                                       │ │
│  └────────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ Metadata Extraction
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                 PnP PowerShell Scripts                       │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │  Connection   │  │ Search & Query │  │ Report Export  │ │
│  │     Setup     │  │   Execution    │  │  with Metadata │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ Output
                       │
┌──────────────────────▼──────────────────────────────────────┐
│          Site-Specific CSV Reports                           │
│  Columns: FileName, FullPath, SITType, Instances,           │
│           Confidence, Author, Modified, Size                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Lab Workflow

### Step 1: Install PnP PowerShell Module

Install the PnP PowerShell module for SharePoint Online automation:

Open PowerShell 7 as Administrator and run:

```powershell
# Install PnP PowerShell module
Install-Module PnP.PowerShell -Scope CurrentUser -Force

# Verify installation
Get-Module PnP.PowerShell -ListAvailable
```

**Expected Output**:

```text
ModuleType Version    PreRelease Name
---------- -------    ---------- ----
Script     2.x.x                 PnP.PowerShell
```

> **💡 Note**: PnP PowerShell is the modern replacement for the legacy SharePointPnPPowerShellOnline module. Always use PnP.PowerShell for new projects.

---

### Step 2: Connect to SharePoint Site

Run the connection script to authenticate to your target SharePoint site:

Navigate to the lab scripts directory:

```powershell
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05c-SharePoint-Search-Discovery\scripts"
```

Execute the connection script:

```powershell
.\Connect-PnPSites.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/YourTargetSite"
```

**What this script does**:

- Prompts for interactive authentication (browser-based)
- Establishes PnP PowerShell connection to the specified site
- Validates site access and permissions
- Caches authentication for subsequent commands

**Expected Prompts**:

1. **Browser window opens**: Sign in with your SharePoint admin credentials
2. **Consent prompt**: Accept permission request (first-time only)
3. **Success message**: "✅ Connected to site: https://yourtenant.sharepoint.com/sites/YourTargetSite"

**Connection Verification**:

```powershell
# Verify current connection
Get-PnPConnection
```

**Expected Output**:

```text
Url                      : https://yourtenant.sharepoint.com/sites/YourTargetSite
ConnectionMethod         : ManagedIdentity
PSCredential            : 
CurrentTenant           : yourtenant.onmicrosoft.com
ConnectionType          : O365
```

> **💡 Multi-Site Scanning**: To scan multiple sites, run `Connect-PnPSites.ps1` with different `-SiteUrl` parameters in sequence, or modify the script to iterate through a site list.

---

### Step 3: Identify Target Sites and Libraries

Before running discovery scans, identify high-priority sites and document libraries:

Run the site enumeration script:

```powershell
.\Get-SiteLibraries.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/YourTargetSite"
```

**What this script does**:

- Lists all document libraries in the connected site
- Shows item counts and storage usage
- Identifies libraries with the highest document counts
- Recommends priority libraries for targeted scanning

**Expected Output**:

```text
📚 Document Libraries in AI Security Challenge Team Site:
==========================================================

Library Name          Item Count    Size (GB)    Last Modified
--------------------------------------------------------------------
Documents             1,234         2.5          2025-11-15
Finance Reports       456           1.2          2025-11-12
HR Records            789           3.1          2025-11-14
Shared Documents      234           0.8          2025-11-10

💡 Recommended Priority Libraries (highest document counts):
  1. Documents (1,234 items)
  2. HR Records (789 items)
  3. Finance Reports (456 items)
```

> **💡 Targeting Strategy**: Focus on libraries with high document counts or known sensitive content (HR, Finance, Legal). This targeted approach is more efficient than full tenant scans.

---

### Step 4: Run Site-Specific SIT Discovery

Execute the SharePoint Search discovery script for your target site:

Run the search script:

```powershell
.\Search-SharePointSITs.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/YourTargetSite" -Library "Documents"
```

**What this script does**:

- Queries SharePoint Search API for documents in the specified library
- Filters results by classified content (SIT detections)
- Extracts rich metadata:
  - File name and full SharePoint path
  - Author and last modified date
  - File size and extension
  - SIT type, instances, and confidence level
- Generates CSV report with all metadata columns

**Progress Output**:

```text
🔍 Starting SharePoint Search Discovery...
==========================================

📊 Target: https://yourtenant.sharepoint.com/sites/YourTargetSite/Documents
🔍 Searching for classified documents...

✅ Found 45 documents with sensitive data
📊 Processing metadata extraction...
   - Document 1/45: Customer_Orders_Q4.xlsx (Credit Card Number detected)
   - Document 2/45: Employee_Records_2025.docx (SSN detected)
   - Document 3/45: Financial_Report_Nov.xlsx (Bank Account Number detected)
   [Progress continues...]

✅ Discovery complete
📁 Report saved: reports\YourTargetSite_Documents_2025-11-17.csv

📈 Discovery Summary:
   - Total documents scanned: 1,234
   - Documents with sensitive data: 45
   - Unique SIT types detected: 6
   - Average confidence: 94.2%
```

**Runtime**: 5-15 minutes depending on library size

---

### Step 5: Review Site-Specific CSV Report

Open the generated CSV report to analyze discovery results:

```powershell
# Open CSV in Excel
Invoke-Item ".\reports\YourTargetSite_Documents_2025-11-17.csv"
```

**CSV Column Reference**:

| Column | Description | Analysis Use |
|--------|-------------|--------------|
| **FileName** | Document name | Quick identification |
| **FullPath** | Complete SharePoint URL | Exact document location |
| **SITType** | Detected SIT name | Categorize by sensitivity |
| **Instances** | Number of SIT detections | Assess severity (high count = higher risk) |
| **Confidence** | Detection confidence % | Validate true positives (>90% = reliable) |
| **Author** | Document creator | Contact for remediation |
| **Modified** | Last modified date | Identify stale sensitive data |
| **FileSize** | Size in MB | Prioritize large files |
| **Extension** | File type | Identify risky formats (Excel, Word) |

**Sample CSV Content**:

```csv
FileName,FullPath,SITType,Instances,Confidence,Author,Modified,FileSize,Extension
Customer_Orders_Q4.xlsx,https://tenant.sharepoint.com/sites/Finance/Documents/Customer_Orders_Q4.xlsx,Credit Card Number,12,98,finance@domain.com,2025-11-10,2.3,.xlsx
Employee_Records_2025.docx,https://tenant.sharepoint.com/sites/HR/Documents/Employee_Records_2025.docx,U.S. Social Security Number,67,99,hr@domain.com,2025-11-14,1.8,.docx
```

> **💡 Analysis Techniques**: Use Excel pivot tables to group by Author (identify top contributors), Modified Date (find stale sensitive data), or SITType (categorize by risk level).

---

### Step 6: Apply Advanced Filtering

Refine your discovery scope using advanced filtering parameters:

**Filter by Date Range** (find recent sensitive data):

```powershell
.\Search-SharePointSITs.ps1 -SiteUrl "https://tenant.sharepoint.com/sites/Finance" -Library "Documents" -ModifiedAfter "2025-09-01"
```

**Filter by File Type** (target specific formats):

```powershell
.\Search-SharePointSITs.ps1 -SiteUrl "https://tenant.sharepoint.com/sites/HR" -Library "Records" -FileExtension ".xlsx,.docx"
```

**Filter by Folder Path** (narrow scope to specific folders):

```powershell
.\Search-SharePointSITs.ps1 -SiteUrl "https://tenant.sharepoint.com/sites/Legal" -Library "Documents" -FolderPath "/Contracts/2025"
```

**Filter by SIT Type** (target specific sensitivity):

```powershell
.\Search-SharePointSITs.ps1 -SiteUrl "https://tenant.sharepoint.com/sites/Finance" -Library "Documents" -SITType "Credit Card Number"
```

**Combine Multiple Filters** (precise targeting):

```powershell
.\Search-SharePointSITs.ps1 `
  -SiteUrl "https://tenant.sharepoint.com/sites/HR" `
  -Library "Employee Records" `
  -ModifiedAfter "2025-01-01" `
  -FileExtension ".docx" `
  -SITType "U.S. Social Security Number"
```

> **💡 Production Tip**: Advanced filtering significantly reduces scan time and report size. Use filters to focus on high-priority content for compliance audits.

---

### Step 7: Test Custom SIT Patterns (Optional)

If your organization has custom SIT definitions, validate detection accuracy before full rollout:

Run the custom SIT validation script:

```powershell
.\Test-CustomSITPatterns.ps1 -SiteUrl "https://tenant.sharepoint.com/sites/TestSite" -CustomSITName "Employee ID Pattern"
```

**What this script does**:

- Searches for documents matching your custom SIT definition
- Compares detected instances against expected patterns
- Validates confidence levels meet thresholds
- Identifies false positives and false negatives

**Expected Output**:

```text
🧪 Testing Custom SIT Pattern: Employee ID Pattern
===================================================

📊 Pattern Definition:
   - Regex: EMP-[0-9]{6}
   - Confidence Threshold: 85%
   - Expected Format: EMP-123456

🔍 Searching test documents...
   ✅ Test Document 1: 5 instances detected (expected: 5) - PASS
   ✅ Test Document 2: 3 instances detected (expected: 3) - PASS
   ⚠️ Test Document 3: 2 instances detected (expected: 3) - FAIL (1 false negative)
   ❌ Test Document 4: 4 instances detected (expected: 2) - FAIL (2 false positives)

📊 Validation Summary:
   - Total test documents: 4
   - Passed validation: 2 (50%)
   - False positives: 2
   - False negatives: 1
   - Recommendation: Refine regex pattern to reduce false positives

📁 Detailed results: reports\CustomSIT_Validation_EmployeeID_2025-11-17.csv
```

> **💡 Custom SIT Best Practice**: Always test custom patterns on a small sample set before deploying tenant-wide. Use this validation workflow to iteratively refine pattern accuracy.

---

## ✅ Validation Checklist

Verify you've completed all targeted discovery and reporting steps:

- [ ] **PnP PowerShell Installation**: Installed PnP.PowerShell module successfully
- [ ] **Site Connection**: Connected to target SharePoint site(s) using `Connect-PnPSites.ps1`
- [ ] **Site Enumeration**: Identified priority document libraries with `Get-SiteLibraries.ps1`
- [ ] **Discovery Scan**: Executed `Search-SharePointSITs.ps1` for target sites/libraries
- [ ] **CSV Report Review**: Analyzed site-specific CSV reports with rich metadata
- [ ] **Advanced Filtering**: Applied date range, file type, or folder path filters (if applicable)
- [ ] **Custom SIT Testing**: Validated custom SIT patterns (if applicable)
- [ ] **Documentation**: Saved CSV reports to `reports/` folder for audit trail

---

## 📊 Expected Outcomes

After completing this lab, you will have:

**Deliverables**:

- Site-specific CSV reports with rich metadata (file paths, authors, modified dates)
- Filtered discovery results targeting high-priority content
- Custom SIT validation reports (if applicable)
- Documentation of sensitive data concentration by site/library

**Skills Acquired**:

- PnP PowerShell connection and authentication
- SharePoint Search API query construction
- Advanced filtering for targeted discovery
- Rich metadata extraction and reporting
- Custom SIT pattern validation techniques

**Knowledge Gained**:

- SharePoint Search capabilities for programmatic discovery
- Metadata extraction for enhanced compliance reporting
- Targeted scanning strategies for high-priority sites
- Custom SIT testing workflows before production deployment

---

## 🎯 Completion Criteria

You have successfully completed Lab 05d when:

- ✅ PnP PowerShell is connected to target SharePoint site(s)
- ✅ `Search-SharePointSITs.ps1` executes successfully and generates CSV reports
- ✅ CSV reports include rich metadata (paths, authors, modified dates, file sizes)
- ✅ You have applied advanced filtering to refine discovery scope
- ✅ Custom SIT patterns are validated (if applicable to your organization)
- ✅ Site-specific reports are saved to `reports/` folder

---

## 🚀 Next Steps

### Option 1: Lab 06 - Power BI Visualization (Recommended)

Transform your site-specific reports into interactive dashboards:

- Import CSV reports from multiple sites into Power BI
- Create heat maps showing PII concentration by site/library
- Build detailed drill-down reports by author or document type

**[→ Proceed to Lab 06: Power BI Visualization](../../06-Power-BI-Visualization/)**

---

### Option 2: Scan Additional Sites

Expand your discovery to other high-priority sites:

- Repeat Step 2 (Connect) with different `-SiteUrl` parameters
- Run `Search-SharePointSITs.ps1` for each site/library
- Consolidate CSV reports for comprehensive tenant analysis

**Recommended Additional Sites**:

- Human Resources site (employee records, payroll data)
- Finance site (financial reports, credit card transactions)
- Legal site (contracts, litigation documents)
- Executive site (board materials, strategic plans)

---

### Option 3: Lab 07 - Environment Cleanup

If you've completed your discovery objectives, proceed to cleanup:

**[→ Proceed to Lab 07: Environment Cleanup](../../07-Environment-Cleanup/)**

---

## 🔧 Troubleshooting

### Issue: PnP PowerShell connection fails

**Symptoms**: "Access denied" or "Could not connect to site" errors

**Causes**:

- Insufficient permissions (need Site Collection Administrator)
- MFA configuration issues
- Tenant authentication policy restrictions

**Solutions**:

- Verify you have Site Collection Administrator role on target site
- Complete MFA authentication when browser prompt appears
- Check Azure AD Conditional Access policies for SharePoint
- Try disconnecting and reconnecting: `Disconnect-PnPOnline; Connect-PnPSites.ps1 -SiteUrl "..."`
- Review detailed error with: `$Error[0] | Format-List -Force`

---

### Issue: Search query returns no results

**Symptoms**: "0 documents with sensitive data" despite Lab 04 validation showing classified content

**Causes**:

- SharePoint Search index delay (can take 30-60 minutes)
- Incorrect site URL or library name
- Search scope limited by permissions

**Solutions**:

- Wait 1 hour after Lab 04 completion for search index refresh
- Verify site URL is correct (no typos, correct tenant name)
- Ensure library name matches exactly (case-sensitive)
- Test with broader scope (remove filters) to verify connectivity
- Check site permissions - you may not have access to all libraries

---

### Issue: CSV report missing metadata columns

**Symptoms**: CSV lacks expected columns like Author or Modified Date

**Causes**:

- Search API didn't return managed properties
- Documents lack metadata (newly uploaded, not crawled)
- Script version outdated

**Solutions**:

- Wait 24 hours for newly uploaded documents to be fully crawled
- Verify script is latest version from repository
- Check if documents have metadata populated (view in SharePoint UI)
- Run script with `-Verbose` parameter to see API response details
- Update search query to explicitly request managed properties

---

### Issue: Custom SIT validation shows high false positive rate

**Symptoms**: `Test-CustomSITPatterns.ps1` detects instances that aren't actually sensitive data

**Causes**:

- SIT regex pattern too broad
- Confidence threshold too low
- Insufficient context validation in pattern

**Solutions**:

- Refine regex pattern to be more specific (add context requirements)
- Increase confidence threshold from 75% to 85-90%
- Add additional validators (checksum validation, format validation)
- Test pattern on diverse document set before production deployment
- Consult with compliance team to review pattern accuracy
- Reference Microsoft's built-in SIT patterns for best practices

---

## 📚 Additional Resources

- [PnP PowerShell Documentation](https://pnp.github.io/powershell/)
- [SharePoint Search API Reference](https://learn.microsoft.com/en-us/sharepoint/dev/general-development/sharepoint-search-rest-api-overview)
- [Search Query Syntax (KQL)](https://learn.microsoft.com/en-us/sharepoint/dev/general-development/keyword-query-language-kql-syntax-reference)
- [Custom Sensitive Information Types](https://learn.microsoft.com/en-us/purview/create-a-custom-sensitive-information-type)
- [SharePoint Search Managed Properties](https://learn.microsoft.com/en-us/sharepoint/manage-search-schema)
- [PnP PowerShell Installation Guide](https://pnp.github.io/powershell/articles/installation.html)

---

## 🤖 AI-Assisted Content Generation

This comprehensive targeted data discovery guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating PnP PowerShell best practices, SharePoint Search API techniques, and enterprise-grade targeted discovery workflows.

_AI tools were used to enhance productivity and ensure comprehensive coverage of site-specific data discovery while maintaining technical accuracy and reflecting enterprise compliance and audit reporting standards._
