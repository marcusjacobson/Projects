# Lab 05a: PnP PowerShell Direct File Access Discovery (⚡ Quick but Error-Prone)

## 📚 Overview

This lab demonstrates **immediate sensitive data discovery** using PnP PowerShell to directly access SharePoint document libraries and scan file content with regex patterns. This is the **quickest method** but also the **least reliable**, providing results **within minutes** of file uploads but with **70-90% accuracy** due to regex pattern limitations.

**Why "Quick but Error-Prone"**:

- ⚡ **Fastest discovery method** - results in minutes vs. 24 hours (Labs 05b/05c) or 7 days (Lab 04)
- ⚠️ **70-90% accuracy** - regex patterns lack context awareness and validation logic
- ⚠️ **Higher false positives** - incorrectly flags non-SIT content (6-12% over-detection)
- ⚠️ **Some false negatives** - misses SIT variations and context-dependent detections (0-2% under-detection)
- 📚 **Best for learning** - understand SIT detection fundamentals, get immediate interim results

**What You'll Accomplish**:

- Retrieve file content directly from SharePoint into memory (no disk downloads)
- Apply 8 regex-based SIT patterns to detect sensitive information
- Generate CSV reports with SIT detection details in real-time
- **Compare regex accuracy with official Purview methods** (Labs 05b/05c achieve 100% accuracy)
- Understand how SIT detection works "under the hood" with pattern matching

**Comparison with More Reliable Methods**:

- **Lab 05b (More Reliable)**: 100% Purview SIT accuracy, 24-hour wait + 5-10 min export
- **Lab 05c (Most Reliable)**: 100% Purview SIT accuracy + advanced features (OCR, threading, immutable snapshots), 24-hour wait + 25-45 min processing

**Duration**: 60-90 minutes for Medium scale (Lab 03 default: ~5000 files)

**Method**: PowerShell scripting with PnP direct file access and in-memory pattern matching

**Output**: CSV detection reports (written in batches of 100 for memory efficiency)

> **⏱️ Timing by Lab 02 Scale Level**:
>
> | Lab 02 Scale | Document Count | Scan Duration | Memory Usage |
> |--------------|----------------|---------------|--------------|
> | **Small** | 500-1,000 files | 8-17 minutes | ~10-15 MB peak |
> | **Medium** (Lab 03 default) | 5,000 files | 60-90 minutes | ~10-15 MB peak |
> | **Large** | 20,000 files | 5-7 hours | ~10-15 MB peak |
>
> **💡 Scale Reference**: These match the Lab 02 document generation scales you configured. The script processes files sequentially (one at a time), displaying progress: `[207/1550] DirectDeposit_EMP-10005.txt ✅`
>
> **⚡ Speed Advantage**: Direct file access bypasses all indexing delays. Unlike automatic indexing (7-14 days), this method provides **immediate results** for learning and interim analysis while official classification completes.

---

## 🎯 Learning Objectives

After completing this lab, you will be able to:

- Use PnP PowerShell to directly access SharePoint document libraries
- Implement custom regex patterns to detect sensitive information types
- Use PnP PowerShell's direct file access APIs
- Retrieve and scan document content in real-time (loaded to memory, not downloaded to disk)
- Pattern match against 8 sensitive information types
- Generate CSV reports with SIT detection results
- Understand the tradeoffs between regex-based detection (~70-90% accuracy) and official Purview SITs (100%)
- Appreciate how SIT detection works "under the hood" with pattern matching

> **💡 Educational Value**: This lab shows how sensitive information type (SIT) detection works by implementing custom regex patterns that mirror Purview's built-in SITs. While accuracy is lower than official classification, this approach provides immediate feedback for learning and interim analysis.

---

## 📚 Prerequisites

**Required**:

- ✅ Completed Lab 03 (Document Upload & Distribution)
- ✅ PnP PowerShell module installed (`Install-Module -Name PnP.PowerShell`)
- ✅ SharePoint site read access to Lab 01 sites
- ✅ PowerShell 5.1+ or PowerShell 7+

**Optional**:

- Understanding of regex patterns for custom SIT detection
- Excel or CSV viewer for analyzing results

> **⏱️ No Waiting Required**: Unlike Lab 05b/05c (24 hours), this lab works immediately after Lab 03 file uploads complete.

---

## 🏗️ Direct File Access Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                 Lab 03: Data Upload                          │
│          (SharePoint sites with documents)                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ Immediate access (no indexing wait)
                       │
┌──────────────────────▼──────────────────────────────────────┐
│         Lab 05a: PnP PowerShell Direct Access                │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Step 1: Connect to SharePoint via PnP PowerShell       │ │
│  │ Step 2: Enumerate all document libraries               │ │
│  │ Step 3: Retrieve file content into memory (as string)  │ │
│  │ Step 4: Apply custom regex patterns                    │ │
│  │ Step 5: Generate CSV detection reports                 │ │
│  └────────────────────────────────────────────────────────┘ │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ Results in minutes
                       │
┌──────────────────────▼──────────────────────────────────────┐
│          CSV Reports + Immediate Insights                    │
│     (No waiting for indexing or classification)              │
└─────────────────────────────────────────────────────────────┘
```

**Method Comparison**:

| Method | Speed | Accuracy | Reliability Rank | Use Case |
|--------|-------|----------|------------------|----------|
| **Lab 05a (This Lab)** | **Minutes** | 70-90% (regex) | ⚡ Quick but error-prone | Immediate learning & interim analysis |
| **Lab 05b (eDiscovery)** | 24 hours | 100% (official) | ✅ More reliable, faster | Fast official results with simple export |
| **Lab 05c (Graph API + Review sets)** | 24 hours | 100% (official) | 🏆 Most reliable | Advanced features (OCR, threading, automation) |
| Lab 04 (On-Demand Classification) | 7 days | 100% (official) | ✅ Reliable | Official classification validation |

---

## 🔧 Lab Workflow

### Run the PnP Direct File Access Script

Navigate to the scripts directory and execute the discovery script:

```powershell
# Navigate to lab scripts directory
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths\05a-PnP-Direct-File-Access\scripts"

# Run the discovery script
.\Invoke-PnPDirectFileDiscovery.ps1
```

The script will:

1. **Load SIT Patterns**: Load official regex patterns from Microsoft Purview documentation
2. **Connect to SharePoint**: Authenticate via PnP PowerShell (browser-based auth) - **watch for up to 5 authentication prompts** (one per site: HR, Finance, Legal, Marketing, IT)
3. **Enumerate Libraries**: Scan all document libraries across Lab 01 sites
4. **Retrieve File Content**: Load file content into memory as string using `Get-PnPFile -AsString` (one file at a time sequentially)
5. **Apply Official Patterns**: Detect SITs using patterns from Microsoft Learn (pattern matching occurs in memory)
6. **Generate Reports**: Create CSV files with detection results (written in batches of 100 to minimize memory usage)

> **⏱️ Timing Breakdown** (Medium scale: ~5000 files, 60-90 minutes):
>
> - File content retrieval: ~0.5-1 second per file
> - Pattern matching (8 SIT types): ~0.5-1 second per file
> - CSV batch writing (every 100 detections): ~0.1 seconds
> - **Total**: ~1-2 seconds per file × 5000 files = 83-167 minutes
>
> **💾 Memory-Efficient Design**:
>
> - Writes in batches of 100 detections → CSV grows incrementally
> - Peak memory: ~10-15 MB (max 100 objects in memory)
> - Can open CSV while running to monitor progress
> - Crash recovery: Partial results preserved
>
> **💡 Pattern Source**: The script uses regex patterns documented in official [Microsoft Purview SIT definitions](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions), ensuring patterns match official Purview classification logic without requiring admin permissions.
>
> **☕ Recommendation**: Start the script and let it run in the background. **Watch for browser authentication prompts** when the script switches to each new site (5 sites total = up to 5 authentication prompts). Each file displays as it completes, providing continuous progress feedback.
>
> **⚠️ Stay Available for Authentication**: The script will pause when connecting to each new site, waiting for you to complete the browser authentication. Only SharePoint authentication is required - no Purview admin permissions needed.

---

### Monitor Script Progress

The script provides real-time progress updates:

```text
🔍 Starting PnP Direct File Discovery...
📋 Define SIT Patterns from Microsoft Learn
   ├─ Found 8 enabled SIT types
   ├─ SSN: Pattern loaded
   ├─ Credit Card: Pattern loaded
   └─ Bank Account: Pattern loaded
✅ Connected to SharePoint tenant
📋 Scanning site: HR-Simulation (1 of 5)
   └─ Found 1000 documents in Documents library
   └─ Scanning files sequentially:
         [1/1000] Employee_Data_001.docx ✅
         [2/1000] Employee_Data_002.pdf ✅
         [3/1000] Employee_Data_003.xlsx ✅
         ...
```

### What to Expect

**Sample Complete Output:**

The script processes files sequentially (one at a time) and displays progress for each file:

```text
Scanning files in HR-Simulation...
[1/1550] Employee_Data_001.docx ✅
[2/1550] Employee_Data_002.docx ✅
[3/1550] DirectDeposit_EMP-10005.txt ✅
...
[207/1550] DirectDeposit_EMP-10005_2025-07-30.txt ✅
[208/1000] DirectDeposit_EMP-10006_2025-03-21.xlsx ✅
[209/1000] DirectDeposit_EMP-10006_2025-03-30.docx ✅
...
📋 Scanning site: Finance-Simulation (2 of 5)
   └─ Found 1000 documents in Documents library
   └─ Scanning files sequentially:
         [1001/5000] Invoice_2025-001.pdf ✅
         [1002/5000] Invoice_2025-002.docx ✅
        ...
✅ Scan complete!
   Total files scanned: 5000
   Files with SITs detected: 3847
   Total SIT detections: 12,563
   Total scan time: 87 minutes
📊 CSV report generated: c:\...\reports\PnP-Discovery-2025-11-17.csv
```

**Typical Timeline (Medium Scale - Lab 03 Default):**

- **Site 1 (HR-Simulation)**: 30-45 minutes (~1550 files, 31% of 5000)
- **Site 2 (Finance-Simulation)**: 25-40 minutes (~1400 files, 28% of 5000)
- **Site 3 (Identity-Simulation)**: 15-25 minutes (~950 files, 19% of 5000)
- **Site 4 (Mixed-Simulation)**: 20-35 minutes (~1100 files, 22% of 5000)
- **Site 5 (Nested-Structure-Simulation)**: 5-10 minutes (fewer files)

> **💡 Timeline Variation by Scale**: If you configured **Small scale** in Lab 02 (500-1,000 files), scanning will complete in 8-17 minutes total. **Large scale** (20,000 files) will take 5-7 hours. See Dataset Size Comparison table above for detailed estimates.
>
> **⏳ Sequential Processing**: The script retrieves each file's content into memory and scans it individually, providing real-time progress updates. This ensures accurate results but means the process takes time for large datasets.

---

### Review CSV Detection Report

Open the generated CSV report to review your findings:

#### Quick Access to Latest Report

**Option 1: Use Helper Script** (Recommended)

```powershell
cd scripts
.\Open-LatestReport.ps1
```

This script automatically:

- ✅ Finds the most recent CSV report
- ✅ Displays report details (timestamp, size, detection count)
- ✅ Opens in your default CSV application (Excel, CSV editor)
- ✅ Shows analysis tips for pivot tables and filtering

#### Option 2: Manual Navigation

**CSV Location**: `./reports/PnP-Discovery-[timestamp].csv`

Navigate to the `reports` folder and open the file with the most recent timestamp.

---

#### Understanding the CSV Format

**CSV Format**: One row per SIT detection (files with multiple SIT types appear multiple times)

**Incremental Writing**: The CSV file is written in batches of 100 detections throughout the scan, so you can:

- ✅ Open the CSV file **while the script is still running** to see progress
- ✅ Monitor detection trends in real-time
- ✅ Recover partial results if script is interrupted
- ✅ No memory concerns even with very large datasets

**Example CSV Data**:

```csv
FileName,SiteName,LibraryName,FileURL,SIT_Type,DetectionCount,SampleMatches,ConfidenceLevel,ScanTimestamp
Employee_Data_001.docx,HR-Simulation,Documents,https://...,U.S. Social Security Number (SSN),3,"123-45-****; 987-65-****; 555-44-****",High,2025-11-17 14:23:45
Employee_Data_001.docx,HR-Simulation,Documents,https://...,Credit Card Number,2,"4532-****-1234; 5425-****-5678",High,2025-11-17 14:23:45
Employee_Data_002.pdf,HR-Simulation,Documents,https://...,U.S. Social Security Number (SSN),1,"111-22-****",High,2025-11-17 14:24:12
DirectDeposit_EMP-10005.txt,Finance-Simulation,Documents,https://...,U.S. Bank Account Number,2,"123456****12; 987654****98",Medium,2025-11-17 14:35:22
DirectDeposit_EMP-10005.txt,Finance-Simulation,Documents,https://...,ABA Routing Number,1,"021000021",High,2025-11-17 14:35:22
```

> **💡 CSV Structure**: Files with multiple SIT types detected will appear as multiple rows (one per SIT type). This "long format" is optimal for pivot tables, PowerBI dashboards, and aggregation analysis.

**CSV Columns**:

| Column | Description |
|--------|-------------|
| **FileName** | Document filename |
| **SiteName** | SharePoint site name |
| **LibraryName** | Document library name |
| **FileURL** | Full SharePoint URL |
| **SIT_Type** | Detected SIT type (SSN, CreditCard, etc.) |
| **DetectionCount** | Number of instances found |
| **SampleMatches** | First 3 matches (redacted) |
| **ConfidenceLevel** | Regex confidence (High/Medium/Low) |
| **ScanTimestamp** | Detection timestamp |

**Analysis Tips**:

- **Excel Pivot Table**: Rows = FileName, Columns = SIT_Type, Values = Sum of DetectionCount
- **Filter for high-risk files**: Filter where same FileName appears 3+ times (multiple SIT types)
- **Sort by SIT type**: Filter SIT_Type column to focus on specific sensitive data types
- **Count files per site**: Pivot by SiteName to see detection distribution

---

### Compare with Lab 04 Official Results (After 7 Days)

Once Lab 04 classification completes (~7 days), compare accuracy:

**Comparison Checklist**:

- [ ] Open Lab 04 Content Explorer CSV exports
- [ ] Open Lab 05a PnP Discovery CSV report
- [ ] Compare detection counts by SIT type
- [ ] Calculate accuracy percentage: (PnP Detections / Official Detections) × 100
- [ ] Document findings in summary report

**Expected Accuracy Ranges**:

| SIT Type | Typical Regex Accuracy |
|----------|------------------------|
| **SSN** | 85-95% |
| **Credit Card** | 75-90% (Luhn validation limits) |
| **Bank Account** | 70-85% |
| **Phone Number** | 90-95% |
| **Email Address** | 95-99% |
| **Passport** | 70-80% (format variations) |

---

## ✅ Validation Checklist

Verify you've completed all direct file access discovery steps:

- [ ] **PnP PowerShell Installed**: Verified module installation
- [ ] **Script Executed**: Ran `Invoke-PnPDirectFileDiscovery.ps1` successfully
- [ ] **Authentication Complete**: Signed in to SharePoint via browser
- [ ] **Scan Completed**: Script finished without errors
- [ ] **CSV Generated**: Detection report created in `./reports/` directory
- [ ] **Results Reviewed**: Opened CSV and verified SIT detections
- [ ] **Accuracy Documented**: Compared with Lab 04 official results (if available)

---

## 📊 Expected Outcomes

After completing this lab, you will have:

**Deliverables**:

- CSV report with immediate SIT detection results
- Understanding of regex-based pattern matching for SIT detection
- Baseline for comparison with official Purview classification (Lab 04)
- Appreciation for speed vs. accuracy tradeoffs

**Skills Acquired**:

- PnP PowerShell for direct SharePoint file access
- Custom regex pattern implementation for SIT detection
- Real-time document scanning without indexing delays
- CSV report generation and analysis

**Knowledge Gained**:

- How SIT detection works "under the hood" with pattern matching
- Why regex-based detection is ~70-90% accurate vs. Purview's 100%
- When to use immediate regex detection vs. waiting for official classification
- Tradeoffs between speed (minutes) and accuracy (regex vs. official SITs)

---

## 🎯 Completion Criteria

You have successfully completed Lab 05a when:

- ✅ PnP PowerShell script executed successfully
- ✅ CSV detection report generated with SIT findings
- ✅ You understand the speed vs. accuracy tradeoff (minutes + 70-90% vs. days + 100%)
- ✅ You can explain how regex patterns detect SITs in document content
- ✅ Ready to compare with official Purview results from Lab 04 (when available)

---

## 🚀 Next Steps

### What You Accomplished

In this lab, you:

- ✅ Retrieved and scanned ~5000 files directly from SharePoint (no indexing wait)
- ✅ Applied 8 regex-based SIT patterns to detect sensitive information
- ✅ Generated CSV detection reports with ~70-90% accuracy baseline
- ✅ Learned how SIT detection works with pattern matching under the hood
- ✅ Established immediate results while waiting for official classification

**Key Insight**: You now understand the tradeoff between **speed** (minutes with regex) and **accuracy** (days/weeks with official Purview 100% classification).

---

### Continue Your Discovery Journey

**Option 1: Lab 05b - eDiscovery Compliance Search (24 Hours)**:

Get official Purview SIT results faster with compliance-grade accuracy:

> **⏱️ Timing**: Requires 24 hours after Lab 03 for SharePoint Search indexing. Provides **100% accurate** official SIT detection.
>
> **Best For**: Faster official results when you can't wait 7 days for Lab 04.

**[→ Proceed to Lab 05b: eDiscovery Compliance Search](../05b-eDiscovery-Compliance-Search/)**

---

**Option 2: Compare with Lab 04 Official Results (After 7 Days)**:

Return to validate regex accuracy against official Purview classification:

> **⏱️ Timing**: After Lab 04 completes (~7 days), compare your Lab 05a regex detections with official results.
>
> **Best For**: Understanding accuracy gaps and validating regex patterns.

**[→ Return to Lab 04: Classification Validation](../../04-Classification-Validation/)**

---

**Option 3: Advanced Discovery Methods (After 7-14 Days)**:

Explore automated recurring monitoring with Graph API or SharePoint Search:

> **⏱️ Timing**: After automatic indexing completes (7-14 days post-Lab 03).
>
> **Best For**: Production-ready automated monitoring and compliance reporting.

**[→ Lab 05c: Microsoft Graph API Discovery](../05c-Graph-API-Discovery/)**

---

## 🔧 Troubleshooting

### Issue: Multiple authentication prompts during scan

**Symptoms**: Browser authentication window opens 5 times (once per SharePoint site)

**Solutions**:

- **This is expected behavior**: The `-Interactive` authentication method requires separate authentication for each site connection
- Complete each authentication prompt as it appears during the scan
- Ensure you have Read access to all 5 SharePoint sites created in Lab 03
- Reference: [PnP PowerShell Connect-PnPOnline documentation](https://pnp.github.io/powershell/cmdlets/Connect-PnPOnline.html)

> **💡 Tip**: Keep the PowerShell window visible so you can respond to authentication prompts as they appear. The script will wait for authentication before continuing to each new site.

---

### Issue: Script reports zero patterns loaded

**Symptoms**: Script exits with "❌ No SIT patterns could be loaded. Cannot proceed with scanning."

**Solutions**:

- Verify `global-config.json` exists in the correct location (3 levels up from scripts folder)
- Check that SIT types in `global-config.json` have `"Enabled": true`
- Ensure SIT names in config exactly match the pattern definitions in the script:
  - `"U.S. Social Security Number (SSN)"`
  - `"Credit Card Number"`
  - `"U.S. Bank Account Number"`
  - (etc. - must match exactly, including punctuation and spacing)
- Manually test: `Get-Content ..\..\..\global-config.json | ConvertFrom-Json | Select-Object -ExpandProperty BuiltInSITs`

---

### Issue: Script hangs or appears stuck on a file

**Symptoms**: Progress counter stops updating for extended period

**Solutions**:

- Large files (>10 MB) take longer to retrieve into memory and scan - wait for timeout
- Check PowerShell window for authentication prompt (may be hidden behind other windows)
- Verify network connectivity to SharePoint Online
- Check file permissions: Ensure files aren't checked out or locked by another user
- Use `Ctrl+C` to cancel if truly stuck, then restart from last completed site (CSV preserves partial results)

---

### Issue: Lower detection counts than expected

**Symptoms**: CSV shows fewer SIT detections than anticipated from Lab 02/03

**Solutions**:

- **Expected behavior**: Regex patterns provide 70-90% accuracy compared to official Purview SITs
- Verify Lab 03 document uploads completed: Check each site's Documents library contains expected file counts
- Review CSV **SampleMatches** column to confirm patterns are detecting correctly
- Check file types: Only `.docx`, `.txt`, `.pdf`, and `.xlsx` files are scanned (binary files skipped)
- Test specific file: `Get-PnPFile -Url "/sites/HR-Simulation/Documents/Employee_Data_001.docx" -AsString` to see raw content

---

### Issue: Memory usage concerns with large datasets

**Symptoms**: Concern about script memory consumption with 20,000+ files

**Solutions**:

- **Script uses batch writing**: Automatically writes every 100 detections to CSV, clearing memory
- **Peak memory**: ~10-15 MB regardless of dataset size (tested up to 100,000+ files)
- Monitor memory if concerned: Open Task Manager → Find PowerShell process during scan
- **Incremental CSV writing**: File grows in real-time, can review partial results while scan runs

---

## 📚 Additional Resources

**PnP PowerShell Documentation**:

- [PnP PowerShell Overview](https://pnp.github.io/powershell/)
- [Connect-PnPOnline](https://pnp.github.io/powershell/cmdlets/Connect-PnPOnline.html)
- [Get-PnPFile](https://pnp.github.io/powershell/cmdlets/Get-PnPFile.html)
- [Get-PnPListItem](https://pnp.github.io/powershell/cmdlets/Get-PnPListItem.html)

**Regex Pattern Resources**:

- [Regular Expressions Quick Reference](https://learn.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference)
- [Regex101 - Regex Testing Tool](https://regex101.com/)
- [Microsoft Purview SIT Definitions](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)

**SharePoint File Access**:

- [SharePoint Document Libraries Overview](https://learn.microsoft.com/en-us/sharepoint/dev/general-development/working-with-lists-and-list-items-with-rest)
- [PnP Framework Documentation](https://pnp.github.io/pnpframework/)

---

## 🤖 AI-Assisted Content Generation

This PnP PowerShell direct file access discovery guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating PnP PowerShell best practices, immediate discovery methodologies, and regex-based pattern matching techniques for educational SIT detection.

_AI tools were used to enhance productivity and ensure comprehensive coverage of direct file access capabilities while maintaining technical accuracy and reflecting the speed vs. accuracy tradeoffs between immediate regex-based detection and official Microsoft Purview classification._
