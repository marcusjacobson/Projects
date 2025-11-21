# Lab 05c: Graph API Discovery (Post-Indexing Automated Discovery)

## 📋 Overview

This lab guides you through **automated discovery and reporting** of sensitive data using the Microsoft Graph Search API. This method uses PowerShell automation to programmatically query classified content after the **7-14 day Microsoft Search indexing** period, generate recurring reports, and integrate with security dashboards or SIEM systems.

**Timeline**: 7-14 days after Lab 03 content upload (Microsoft Search indexing delay)

**Duration**: 2-3 hours initial setup, then fully automated

**Approach**: PowerShell automation with Microsoft Graph API

**Output**: Automated JSON/CSV reports with trend analysis and scheduled execution

---

## 🎯 Learning Objectives

After completing this lab, you will be able to:

- Configure Microsoft Graph API permissions for search operations
- Authenticate to Microsoft Graph using app-based or interactive methods
- Write PowerShell scripts to query sensitive data programmatically
- Generate automated JSON/CSV reports with detection metadata
- Schedule recurring scans using Windows Task Scheduler
- Analyze trends in sensitive data discovery over time
- Integrate discovery results with SIEM or security dashboards
- Bypass Content Explorer's 1,000-item export limitation

---

## ⏱️ Timeline Comparison - Understanding Graph API Timing

| Method | Timeline | Search Index Required? | Accuracy | Best Use Case |
|--------|----------|----------------------|----------|---------------|
| **Lab 05a: PnP Direct File Access** | Immediate | ❌ No | Custom regex (70-90%) | Immediate discovery, learning |
| **Lab 05b: eDiscovery** | 24 hours | ✅ Yes (SharePoint Search) | Purview SITs (100%) | Compliance searches with official SITs |
| **Lab 05c: Graph API** | **7-14 days** | **✅ Yes (Microsoft Search)** | **Purview SITs (100%)** | **Automated recurring discovery** |
| **Lab 05d: SharePoint Search** | 7-14 days | ✅ Yes (Microsoft Search) | Purview SITs (100%) | Site-specific automated queries |
| **Lab 04: On-Demand Classification** | 7 days | ❌ No (direct scan) | Purview SITs (100%) | Comprehensive portal-based discovery |

> **⚠️ Critical Timing Requirement**: Lab 05c relies on the **Microsoft Search unified index**, which requires **7-14 days** to fully index newly uploaded SharePoint content from multi-user sites. The Graph API queries this same index used by Content Explorer, Graph API search, and SharePoint Search. Start this lab **7-14 days after Lab 03 (Document Upload)** to ensure content is searchable. For faster results, use **Lab 05a (immediate)**, **Lab 05b (24 hours)**, or **Lab 04 On-Demand Classification (7 days)** instead.

---

## 📚 Prerequisites

**Required**:

- ✅ **Completed Lab 03** (Document Upload) **7-14 days ago** (Microsoft Search indexing time)
- ✅ Completed Lab 04 (Classification Validation) for comparison baseline
- ✅ PowerShell 7.0+ installed ([Download here](https://github.com/PowerShell/PowerShell/releases))
- ✅ Azure AD Global Administrator or Application Administrator role (for one-time permission grant)
- ✅ Basic PowerShell scripting knowledge (or willingness to learn)

> **💡 Timing Note**: If you need results sooner than 7-14 days, use:
>
> - **Lab 05a (PnP Direct File Access)**: Immediate results with custom regex
> - **Lab 05b (eDiscovery)**: 24-hour results with official Purview SITs
> - **Lab 04 (On-Demand Classification)**: 7-day results with official Purview SITs and Content Explorer integration

**Optional**:

- Azure AD app registration for unattended automation (recommended for production)
- SIEM or dashboard integration endpoint (Splunk, Azure Sentinel, etc.)
- JSON viewer for analyzing report outputs

---

## 🏗️ Architecture Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                   Microsoft Graph API                        │
│          (Search API + Information Protection API)           │
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

### Step 1: Install Required PowerShell Modules

Install the Microsoft Graph PowerShell SDK for authentication and API access:

Open PowerShell 7 as Administrator and run:

```powershell
# Install Microsoft Graph SDK
Install-Module Microsoft.Graph -Scope CurrentUser -Force

# Verify installation
Get-Module Microsoft.Graph -ListAvailable
```

**Expected Output**:

```text
ModuleType Version    PreRelease Name
---------- -------    ---------- ----
Script     2.x.x                 Microsoft.Graph
```

> **💡 Note**: The Microsoft Graph SDK is a collection of modules. The installation may take 3-5 minutes depending on your connection speed.

---

### Step 2: Grant Microsoft Graph API Permissions

Run the permission grant script to configure necessary API permissions:

Navigate to the lab scripts directory:

```powershell
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05b-Graph-API-Discovery\scripts"
```

Execute the permission grant script:

```powershell
.\Grant-GraphPermissions.ps1
```

**What this script does**:

- Connects to Microsoft Graph with admin consent
- Grants the following delegated permissions:
  - `Files.Read.All` - Read files in SharePoint and OneDrive
  - `Sites.Read.All` - Read SharePoint site structure
  - `InformationProtectionPolicy.Read` - Read sensitivity labels and SIT definitions
- Creates an interactive authentication session

**Expected Prompts**:

1. **Sign-in prompt**: Authenticate with your Azure AD admin account
2. **Consent prompt**: Review and accept the requested permissions
3. **Success message**: "✅ Graph API permissions granted successfully"

> **⚠️ Security Note**: These are **Read-Only** permissions. The automation cannot modify content, only discover and report on classified data. Always follow the principle of least privilege in production environments.

---

### Step 3: Test Graph API Connectivity

Validate that authentication and permissions are working correctly:

Run the connectivity test script:

```powershell
.\Test-GraphConnectivity.ps1
```

**What this script tests**:

- Microsoft Graph authentication flow
- Permission validation (Files.Read.All, Sites.Read.All)
- Sample query to retrieve SharePoint sites
- JSON response parsing

**Expected Output**:

```text
🔍 Testing Microsoft Graph API Connectivity...
==============================================

✅ Authentication successful
✅ Permissions validated (Files.Read.All, Sites.Read.All, InformationProtectionPolicy.Read)
✅ Sample query successful: Retrieved 15 SharePoint sites
✅ JSON parsing successful

📊 Sample Sites Retrieved:
  - AI Security Challenge Team Site
  - Finance Department
  - Human Resources
  [Additional sites...]

🎯 Graph API connectivity test PASSED
```

> **💡 Troubleshooting**: If authentication fails, ensure you're using an account with appropriate admin roles and that MFA is configured correctly.

---

### Step 4: Run Tenant-Wide SIT Discovery

Execute the main discovery script to scan your entire SharePoint environment:

Run the search script:

```powershell
.\Search-GraphSITs.ps1
```

**What this script does**:

- Queries Microsoft Graph Search API for all classified documents
- Filters results by SIT type (Credit Card, SSN, Bank Account, etc.)
- Extracts metadata (filename, location, SIT instances, confidence, modified date)
- Generates structured JSON output with full discovery results
- Creates CSV summary report for Excel analysis

**Expected Runtime**: 5-15 minutes depending on tenant size

**Progress Output**:

```text
🔍 Starting Microsoft Graph SIT Discovery...
============================================

📊 Scanning SharePoint sites (1 of 15): AI Security Challenge Team Site
   ✅ Found 45 documents with sensitive data
📊 Scanning SharePoint sites (2 of 15): Finance Department
   ✅ Found 23 documents with sensitive data
📊 Scanning SharePoint sites (3 of 15): Human Resources
   ✅ Found 67 documents with sensitive data

[Progress continues...]

✅ Discovery scan complete
📁 Report saved: reports\SIT_Discovery_2025-11-17_143022.json
📊 Summary saved: reports\SIT_Discovery_Summary_2025-11-17_143022.csv

📈 Discovery Summary:
   - Total documents scanned: 3,482
   - Documents with sensitive data: 247
   - Unique SIT types detected: 8
   - High confidence detections (>95%): 198
```

---

### Step 5: Review Discovery Reports

Examine the generated reports to understand your sensitive data landscape:

**JSON Report** (`SIT_Discovery_[Date].json`):

- Complete discovery results with full metadata
- Nested structure organized by SIT type
- Suitable for programmatic processing or SIEM ingestion

**JSON Structure**:

```json
{
  "discoveryDate": "2025-11-17T14:30:22Z",
  "totalDocumentsScanned": 3482,
  "documentsWithSensitiveData": 247,
  "sitTypes": [
    {
      "sitName": "Credit Card Number",
      "documentCount": 45,
      "documents": [
        {
          "fileName": "Customer_Orders_Q4.xlsx",
          "location": "https://tenant.sharepoint.com/sites/Finance/Documents",
          "sitInstances": 12,
          "confidence": 98,
          "lastModified": "2025-11-10T08:23:15Z",
          "owner": "finance@domain.com"
        }
      ]
    }
  ]
}
```

**CSV Summary Report** (`SIT_Discovery_Summary_[Date].csv`):

- Excel-friendly format for quick analysis
- Columns: FileName, Location, SITType, Instances, Confidence, LastModified, Owner
- Suitable for pivot tables and stakeholder reporting

**Open in Excel**:

```powershell
# Open CSV in Excel for analysis
Invoke-Item ".\reports\SIT_Discovery_Summary_2025-11-17_143022.csv"
```

> **💡 Analysis Tip**: Use Excel pivot tables to group by SIT Type or Location for executive summaries showing PII concentration across departments.

---

### Step 6: Generate Trend Analysis Report

If you have historical discovery data, generate trend analysis to track changes over time:

Run the trend analysis script:

```powershell
.\Export-TrendAnalysis.ps1 -ReportsFolder ".\reports" -DaysToAnalyze 30
```

**What this script does**:

- Analyzes multiple historical JSON reports from the `reports/` folder
- Calculates trends: increasing/decreasing sensitive data counts
- Identifies new SIT types detected since previous scans
- Generates trend visualization data for dashboards

**Expected Output**:

```text
📈 Generating Trend Analysis...
===============================

📊 Analyzing reports from the last 30 days:
   - 2025-10-18: 235 documents with sensitive data
   - 2025-10-25: 241 documents with sensitive data
   - 2025-11-01: 238 documents with sensitive data
   - 2025-11-08: 243 documents with sensitive data
   - 2025-11-17: 247 documents with sensitive data

📊 Trend Summary:
   - Overall change: +12 documents (+5.1%)
   - Average weekly growth: +3 documents
   - New SIT types detected: Phone Number (first seen 2025-11-08)
   - Top growing site: Human Resources (+15 documents)

📁 Trend report saved: reports\Trend_Analysis_2025-11-17.json
```

> **💡 Best Practice**: Run discovery scans weekly to establish baseline trends and identify anomalies (sudden spikes in sensitive data).

---

### Step 7: Schedule Automated Recurring Scans

Configure Windows Task Scheduler to run discovery scans automatically:

Run the scheduling script:

```powershell
.\Schedule-RecurringScan.ps1 -Frequency "Weekly" -DayOfWeek "Monday" -Time "06:00"
```

**What this script does**:

- Creates a scheduled task in Windows Task Scheduler
- Runs `Search-GraphSITs.ps1` automatically at specified intervals
- Saves reports to `reports/` folder with timestamped filenames
- Sends email notifications on completion (optional)

**Scheduling Options**:

```powershell
# Weekly scan every Monday at 6 AM
.\Schedule-RecurringScan.ps1 -Frequency "Weekly" -DayOfWeek "Monday" -Time "06:00"

# Daily scan at midnight
.\Schedule-RecurringScan.ps1 -Frequency "Daily" -Time "00:00"

# Monthly scan on the 1st at 3 AM
.\Schedule-RecurringScan.ps1 -Frequency "Monthly" -DayOfMonth 1 -Time "03:00"
```

**Verify Scheduled Task**:

```powershell
# View created scheduled task
Get-ScheduledTask -TaskName "Purview-SIT-Discovery-Scan" | Format-List
```

**Expected Output**:

```text
TaskName   : Purview-SIT-Discovery-Scan
State      : Ready
Triggers   : Weekly on Monday at 6:00 AM
Actions    : Start PowerShell script: Search-GraphSITs.ps1
LastRunTime: N/A (not yet executed)
NextRunTime: 2025-11-18 06:00:00
```

> **⚠️ Important**: Ensure the account running the scheduled task has Microsoft Graph permissions. Use service accounts or app registrations for production automation.

---

### Step 8: (Optional) Configure SIEM Integration

If you have a SIEM or security dashboard, integrate discovery results for centralized monitoring:

Run the SIEM export script:

```powershell
.\Export-ToSIEM.ps1 -SIEMType "Splunk" -SplunkHECUrl "https://splunk.domain.com:8088/services/collector" -Token "your-hec-token"
```

**Supported SIEM Types**:

- **Splunk**: HTTP Event Collector (HEC) integration
- **Azure Sentinel**: Log Analytics workspace integration
- **Generic Webhook**: POST JSON to any HTTP endpoint

**What this script does**:

- Reads latest discovery JSON report
- Formats data according to SIEM requirements
- Sends events to SIEM via API
- Logs successful/failed transmissions

**Example for Azure Sentinel**:

```powershell
.\Export-ToSIEM.ps1 -SIEMType "Sentinel" -WorkspaceId "your-workspace-id" -SharedKey "your-shared-key"
```

> **💡 Integration Benefits**: SIEM integration enables correlation with other security events, automated alerting, and centralized compliance reporting.

---

## ✅ Validation Checklist

Verify you've completed all automation setup and discovery steps:

- [ ] **PowerShell Modules**: Installed Microsoft.Graph SDK successfully
- [ ] **API Permissions**: Granted Files.Read.All, Sites.Read.All, InformationProtectionPolicy.Read
- [ ] **Connectivity Test**: Validated Graph API authentication and permissions
- [ ] **Discovery Scan**: Executed `Search-GraphSITs.ps1` and generated JSON/CSV reports
- [ ] **Report Review**: Analyzed discovery results in JSON and CSV formats
- [ ] **Trend Analysis**: Generated trend report comparing historical scans (if applicable)
- [ ] **Automation Setup**: Scheduled recurring scans using Task Scheduler
- [ ] **SIEM Integration**: Configured SIEM export (optional)
- [ ] **Documentation**: Saved reports to `reports/` folder for audit trail

---

## 📊 Expected Outcomes

After completing this lab, you will have:

**Deliverables**:

- JSON discovery reports with complete metadata
- CSV summary reports for Excel analysis
- Trend analysis reports tracking changes over time (if historical data available)
- Scheduled task for automated recurring scans
- SIEM integration (optional) for centralized monitoring

**Skills Acquired**:

- Microsoft Graph API authentication and permission management
- PowerShell automation for data discovery
- Scheduled task configuration for unattended execution
- Trend analysis and reporting techniques
- SIEM integration for security operations

**Knowledge Gained**:

- Graph API capabilities for programmatic discovery
- Automation advantages over manual portal workflows
- Trend analysis for anomaly detection
- Integration patterns for enterprise security tools

---

## 🎯 Completion Criteria

You have successfully completed Lab 05b when:

- ✅ Graph API permissions are granted and connectivity is validated
- ✅ `Search-GraphSITs.ps1` executes successfully and generates reports
- ✅ JSON and CSV reports are saved in the `reports/` folder
- ✅ Scheduled task is configured for recurring automated scans
- ✅ You understand how to analyze discovery results and identify trends

---

## 🚀 Next Steps

### Option 1: Lab 06 - Power BI Visualization (Recommended)

Transform your automated reports into interactive dashboards:

- Import JSON/CSV reports into Power BI
- Create automated refresh schedules syncing with your recurring scans
- Build executive dashboards with trend charts

**[→ Proceed to Lab 06: Power BI Visualization](../../06-Power-BI-Visualization/)**

---

### Option 2: Lab 07 - Environment Cleanup

If you've completed your discovery objectives, proceed to cleanup:

**[→ Proceed to Lab 07: Environment Cleanup](../../07-Environment-Cleanup/)**

---

## 🔧 Troubleshooting

### Issue: Graph API authentication fails

**Symptoms**: "Insufficient privileges" or "Access denied" errors

**Causes**:

- Insufficient permissions (need Files.Read.All, Sites.Read.All)
- Admin consent not granted
- MFA configuration issues

**Solutions**:

- Re-run `Grant-GraphPermissions.ps1` with Global Admin account
- Verify permissions in Azure Portal under **Enterprise Applications > Permissions**
- Check Azure AD sign-in logs for failed authentication details
- Ensure MFA is configured and functional for admin account

---

### Issue: Discovery scan returns no results

**Symptoms**: JSON report shows 0 documents with sensitive data

**Causes**:

- Classification not yet indexed by Graph Search API
- Insufficient permissions to read SharePoint content
- Search API query syntax issues

**Solutions**:

- Wait 30-60 minutes after Lab 04 completion for indexing
- Verify `Files.Read.All` and `Sites.Read.All` permissions are granted
- Test connectivity with `Test-GraphConnectivity.ps1`
- Check SharePoint sites are accessible and not private/hidden
- Review script output for query errors or throttling warnings

---

### Issue: Scheduled task fails to execute

**Symptoms**: Task shows "Last Run Result: The operator or administrator has refused the request"

**Causes**:

- Task running under account without Graph API permissions
- PowerShell execution policy restriction
- Script path or working directory misconfigured

**Solutions**:

- Configure task to run under account with API permissions (service account recommended)
- Set PowerShell execution policy: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Verify script path is absolute, not relative
- Test script manually under the same account used by scheduled task
- Review Task Scheduler History tab for detailed error logs

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

- [Microsoft Graph Search API Documentation](https://learn.microsoft.com/en-us/graph/api/resources/search-api-overview)
- [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview)
- [Graph API permissions reference](https://learn.microsoft.com/en-us/graph/permissions-reference)
- [Task Scheduler automation best practices](https://learn.microsoft.com/en-us/windows/win32/taskschd/task-scheduler-start-page)
- [Azure Sentinel data ingestion](https://learn.microsoft.com/en-us/azure/sentinel/connect-custom-logs)
- [Splunk HTTP Event Collector](https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector)

---

## 🤖 AI-Assisted Content Generation

This comprehensive automated data discovery guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Graph API best practices, PowerShell automation patterns, and enterprise security operations workflows.

_AI tools were used to enhance productivity and ensure comprehensive coverage of programmatic data discovery while maintaining technical accuracy and reflecting enterprise-grade automation and integration standards._
