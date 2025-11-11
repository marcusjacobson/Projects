# Advanced Cross-Platform SIT Analysis

## 📋 Overview

**Duration**: 45-60 minutes

**Objective**: Integrate on-premises scanner and cloud SharePoint DLP monitoring data from prerequisite labs into a unified cross-platform SIT governance analysis, demonstrating comprehensive hybrid environment visibility through Activity Explorer and PowerShell-automated executive reporting.

> **💡 Capstone Lab**: This supplemental lab serves as a **capstone integration experience** that brings together outputs from **Advanced-Remediation Step 1** (test data generation) and **Advanced-SharePoint-SIT-Analysis Step 2** (DLP analysis) to demonstrate end-to-end hybrid SIT monitoring capabilities. You'll import data from both environments, perform unified cross-platform analysis, and generate integrated executive reports showing your complete governance posture.

### What You'll Learn

**Integrated Cross-Platform Analysis:**

- Import and consolidate Activity Explorer data from both on-premises scanner and cloud SharePoint DLP environments.
- Perform unified SIT detection analysis across hybrid infrastructure.
- Compare detection patterns, platform capabilities, and monitoring effectiveness between environments.
- Identify gaps, overlaps, and optimization opportunities in cross-platform governance.
- Generate comprehensive executive reports demonstrating unified hybrid monitoring strategy.
- Create reusable integration frameworks for recurring cross-platform compliance reviews.

### Required Prerequisite Labs

This **capstone lab** integrates advanced reporting and analysis from two prerequisite supplemental labs. You **must** complete both labs before starting:

| Prerequisite Lab | What You'll Reference | Why It's Needed |
|------------------|----------------------|-----------------|
| **Advanced-Remediation** (Supplemental Lab - Step 1 minimum) | On-premises scanner Activity Explorer "File discovered" events from RemediationTestData test files | Provides on-premises scanner Activity Explorer data from test files for integrated cross-platform analysis |
| **Advanced-SharePoint-SIT-Analysis** (Supplemental Lab - Step 2 minimum) | SharePoint DLP policy deployment, 1000 test documents with Credit Card/SSN patterns, Activity Explorer "DLP rule matched" events (~400 events) | Provides cloud SharePoint DLP Activity Explorer data showing SIT detection patterns for integrated cross-platform comparison |

**⏳ Timing Requirements**:

- Wait **24-48 hours** after completing **Advanced-Remediation Step 1** (test data generation) for Activity Explorer "File discovered" events to fully sync.
- Wait **15-30 minutes** after completing **Advanced-SharePoint-SIT-Analysis Step 2** (DLP policy deployment) for cloud DLP policy initial scan to complete.

> **💡 Capstone Architecture**: This lab demonstrates your ability to perform **unified cross-platform SIT governance** by comparing detection patterns, platform capabilities, and monitoring strategies across hybrid environments. Both prerequisite labs must be completed to provide the comparative data foundation.

### Lab Architecture

This lab demonstrates **hybrid SIT monitoring** by analyzing both platforms:

- **On-Premises Scanner**: "Files discovered" events showing file share SIT detection
- **Cloud SharePoint DLP**: "DLP policy match" events showing cloud workload SIT detection
- **Cross-Platform Analysis**: Unified reporting comparing detection capabilities, timing, and platform effectiveness

### C:\PurviewLab Report Mapping

This capstone lab imports Activity Explorer data exported from prerequisite labs. Here's the complete data flow:

| Report File | Created By | Activity Type | Purpose |
|-------------|-----------|---------------|---------|
| `ActivityExplorer_Export.csv` | **Advanced-Remediation** (Supplemental Lab - Step 1) | "File discovered" events | On-premises scanner Activity Explorer data from RemediationTestData test files |
| `ActivityExplorer_DLP_Export.csv` | **Advanced-SharePoint-SIT-Analysis** (Supplemental Lab - Step 2) | "DLP rule matched" events | Cloud SharePoint DLP Activity Explorer data showing SIT detection patterns |
| `Final_Stakeholder_Report_CrossPlatform.txt` | **This Lab** (Advanced-Cross-Platform-SIT-Analysis) | N/A - Output file | Comprehensive cross-platform analysis report combining both data sources |

> **💡 Prerequisites Reminder**: You must complete **both** prerequisite labs and export their Activity Explorer data to `C:\PurviewLab` before starting this integration lab. This lab **imports** existing data; it does not generate test data.

---

## 🎯 Lab Objectives

**Integrated Cross-Platform Workflow**:

1. Verify Activity Explorer data from on-premises scanner environment (from **Advanced-Remediation Step 1**)
2. Verify Activity Explorer data from cloud SharePoint DLP environment (from **Advanced-SharePoint-SIT-Analysis Step 2**)
3. Run automated PowerShell script to consolidate and analyze data from both platforms
4. Generate comprehensive cross-platform report comparing detection patterns and effectiveness
5. Review platform-specific strengths, gaps, and optimization opportunities
6. Understand complementary detection methods across hybrid infrastructure

> **📚 Next Steps**: After completing this lab, refer to **[Environment Cleanup Guide](../../Environment-Cleanup-Guide.md)** to remove Azure resources and terminate costs.

---

## 📖 Step-by-Step Instructions

### Required Data Files

This lab requires **two Activity Explorer CSV exports** in `C:\PurviewLab\`:

| Required File | Data Source | Contains |
|---------------|-------------|----------|
| `ActivityExplorer_Export.csv` | On-premises scanner "File discovered" events | Scanner detection data from RemediationTestData test files |
| `ActivityExplorer_DLP_Export.csv` | Cloud SharePoint "DLP rule matched" events | DLP policy detection data from SharePoint test documents |

**How to Obtain These Files:**

- **Option A (Recommended)**: Complete the prerequisite labs (**Advanced-Remediation Step 1** and **Advanced-SharePoint-SIT-Analysis Step 2**), which include Activity Explorer export instructions and generate these files automatically
- **Option B**: If you already completed the prerequisite labs but didn't export the Activity Explorer data, use the **Optional Data Export Procedures** below to extract the data manually

**Workflow Overview:**

1. **Verify Data Files**: Confirm both CSV files exist in C:\PurviewLab
2. **Generate Cross-Platform Report**: Run PowerShell script to analyze both data sources and generate comprehensive executive report

---

## 🔄 Optional: Activity Explorer Data Export Procedures

**⚠️ Use this section ONLY if you need to manually export Activity Explorer data.**

If you already have both CSV files in `C:\PurviewLab\`, **skip to Step 1** (Verify Data Files).

### Prerequisites for Manual Export

Before using these export procedures, you **must** have the following Purview data already established:

**For On-Premises Scanner Export** (`ActivityExplorer_Export.csv`):

- **Required Infrastructure Setup**: Complete **Lab 02 - OnPrem-02 through OnPrem-04** (Main Lab Series)
  - **OnPrem-02**: On-premises scanner installation and configuration
  - **OnPrem-03**: Scanner content scan jobs and enforcement scanning
  - **OnPrem-04**: Verification of scanner Activity Explorer data sync
- **Required Test Data**: Complete **Advanced-Remediation Step 1** (Supplemental Lab)
  - Creates RemediationTestData test files for scanner to discover
- **Activity Explorer Data Requirements**:
  - Scanner must be installed, configured, and have completed enforcement runs (Main Labs 02-04)
  - Test files must exist on file shares for scanner to detect (Advanced-Remediation Step 1)
  - **24-48 hours** wait time after scanner runs for Activity Explorer data sync
  - **Without Main Labs 02-04 scanner setup, Activity Explorer will have no "File discovered" events to export**
- **What This Export Contains**: ~114 "File discovered" events from on-premises scanner detecting RemediationTestData test files

**For SharePoint DLP Export** (`ActivityExplorer_DLP_Export.csv`):

- **Required Infrastructure Setup**: Complete **Lab 03 - Cloud-01 through Cloud-04** (Main Lab Series)
  - **Cloud-01**: SharePoint site creation and DLP policy fundamentals
  - **Cloud-02**: DLP policy deployment to SharePoint workloads
  - **Cloud-03**: DLP policy testing and validation
  - **Cloud-04**: Activity Explorer monitoring and DLP event verification
- **Required Test Data**: Complete **Advanced-SharePoint-SIT-Analysis Step 2** (Supplemental Lab)
  - Creates 1000 SharePoint test documents with Credit Card/SSN patterns for DLP to detect
- **Activity Explorer Data Requirements**:
  - DLP policies must be deployed to SharePoint (Main Labs 03-04)
  - Test documents must exist in SharePoint for DLP to scan (Advanced-SharePoint-SIT-Analysis Step 2)
  - **15-30 minutes** wait time after DLP policy deployment for initial scan and Activity Explorer data sync
  - **Without Main Labs 03-04 DLP setup, Activity Explorer will have no "DLP rule matched" events to export**
- **What This Export Contains**: ~351 "DLP rule matched" events from SharePoint DLP policy detecting sensitive data patterns

> **💡 Data Sync Timing**: Activity Explorer requires time to sync detection events. Ensure you've waited the appropriate time period after completing the prerequisite lab steps before attempting export.

---

### Export Procedure A: On-Premises Scanner Data

**Export Activity Explorer data showing on-premises scanner "File discovered" events.**

> **📊 Prerequisites**: Before proceeding, verify you completed **Advanced-Remediation Step 1** at least **24-48 hours ago** and the scanner enforcement run finished successfully.

#### Navigate to Activity Explorer

- Go to [compliance.microsoft.com](https://compliance.microsoft.com).
- Navigate to **Information Protection** → **Explorers** → **Activity Explorer**.

#### Configure Filters for On-Premises Scanner Data

1. **Date Range**: Click calendar → Select **Last 30 days** → Click **Apply**
2. **Activity Type**: Click **Activity** dropdown → Select **"File discovered"** → Click **Apply**
3. **Location**: Click **Location** dropdown → Select **"Endpoint devices"** → Click **Apply**

> **💡 Filter Explanation**: These filters isolate on-premises scanner activity from the RemediationTestData share. "File discovered" events indicate the scanner detected and classified files during enforcement scans.

#### Export and Save Data

1. With filters applied, click **Export** button
2. Browser downloads: `Activity explorer _ Microsoft Purview.csv`
3. **Rename** to: `ActivityExplorer_Export.csv`
4. **Move** to: `C:\PurviewLab\ActivityExplorer_Export.csv`

**Expected Data Volume**: ~114 events from 18 unique test files in RemediationTestData folder.

---

### Export Procedure B: SharePoint DLP Data

**Export Activity Explorer data showing cloud SharePoint "DLP rule matched" events.**

> **📊 Prerequisites**: Before proceeding, verify you completed **Advanced-SharePoint-SIT-Analysis Step 2** at least **15-30 minutes ago** and DLP policies are active on the SharePoint site.

#### Navigate to Activity Explorer

In Activity Explorer (still at [compliance.microsoft.com](https://compliance.microsoft.com)):

#### Configure Filters for SharePoint DLP Data

1. **Date Range**: Click calendar → Select **Last 7 days** → Click **Apply**
2. **Workload**: Click **Workload** dropdown → Select **SharePoint** → Click **Apply**
3. **Activity Type**: Click **Activity** dropdown → Select **DLP rule matched** → Click **Apply**

> **💡 Filter Explanation**: These filters isolate cloud SharePoint DLP policy matches from the PurviewLab-RetentionTesting site. "DLP rule matched" events indicate DLP policies detected sensitive data in SharePoint documents.

#### Export and Save Data

1. With filters applied, click **Export** button
2. Browser downloads: `Activity explorer _ Microsoft Purview.csv`
3. **Rename** to: `ActivityExplorer_DLP_Export.csv`
4. **Move** to: `C:\PurviewLab\ActivityExplorer_DLP_Export.csv`

**Expected Data Volume**: ~351 events from 285 unique SharePoint documents with Credit Card/SSN patterns.

---

## 🔍 Main Workflow: Cross-Platform Analysis

The following steps are required for all users.

---

### Step 1: Verify Required Data Files

Before beginning analysis, verify that both required CSV files exist in `C:\PurviewLab\`.

**Run File Verification Script:**

Navigate to the lab directory and execute:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-Cross-Platform-SIT-Analysis"
.\Verify-DataFiles.ps1
```

**Expected Output:**

```text
🔍 Verifying Activity Explorer Data Files
=========================================

✅ Found ActivityExplorer_Export.csv (114 events)

✅ Found ActivityExplorer_DLP_Export.csv (351 events)

=========================================
✅ All required data files present - Ready for cross-platform analysis!

Next Step: Run .\Generate-CrossPlatform-Report.ps1
```

> **⚠️ If Files Missing**: If either file is missing, the script will display specific guidance:
>
> - **Missing on-premises data**: Use Export Procedure A above
> - **Missing SharePoint data**: Use Export Procedure B above
> - **Missing C:\PurviewLab directory**: Create it first with `mkdir C:\PurviewLab`

---

### Step 2: Integrated Cross-Platform Analysis

#### Step 2.1: Run Integrated Analysis Script

The PowerShell script performs unified cross-platform analysis by loading both CSV files and comparing detection patterns across environments.

> **⚠️ Prerequisites**: Ensure both CSV files exist in `C:\PurviewLab\` (verified in Step 1):
>
> - `ActivityExplorer_Export.csv`
> - `ActivityExplorer_DLP_Export.csv`

**Run the Integrated Analysis Script:**

Navigate to the lab directory and execute:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-Cross-Platform-SIT-Analysis"
.\Generate-CrossPlatform-Report.ps1
```

**Expected Output:**

The script generates a comprehensive cross-platform comparison report saved to `C:\PurviewLab\Final_Stakeholder_Report_CrossPlatform.txt`.

```text
Generating cross-platform comparison report...

✅ Cross-platform analysis complete
📄 Report saved to: C:\PurviewLab\Final_Stakeholder_Report_CrossPlatform.txt
```

**Review Generated Report:**

```powershell
notepad C:\PurviewLab\Final_Stakeholder_Report_CrossPlatform.txt
```

**Report Contents:**

- **Executive Summary**: Unified metrics across both platforms
- **On-Premises Scanner Analysis**: Total events, unique files, detection patterns by share
- **Cloud SharePoint DLP Analysis**: Total events, unique documents, DLP policy matches
- **Cross-Platform Comparison**: Side-by-side effectiveness analysis
- **Platform Strengths & Gaps**: Complementary capabilities and optimization opportunities
- **Strategic Recommendations**: Actionable guidance for hybrid governance

---

#### Step 2.2: Interpret Cross-Platform Analysis Results

> **📊 Understanding Your Results**: The report compares two complementary monitoring approaches:
>
> - **On-Premises Scanner**: Batch discovery of existing sensitive files across file shares
> - **Cloud SharePoint DLP**: Real-time detection and policy enforcement on cloud documents
>
> Your specific results will vary based on the data created in prerequisite labs.

**Key Metrics to Review:**

| Metric Category | On-Premises Scanner | SharePoint DLP | Insights |
|-----------------|---------------------|----------------|----------|
| **Detection Volume** | Total "File discovered" events | Total "DLP rule matched" events | Compare event counts and unique file ratios |
| **Coverage Scope** | File shares (Finance, HR, Projects) | SharePoint sites and document libraries | Identify coverage gaps in hybrid environment |
| **Detection Timing** | Batch scans (scheduled intervals) | Real-time policy enforcement | Understand complementary detection windows |
| **Platform Effectiveness** | Historical file discovery | Active collaboration monitoring | Assess which platform best fits each workload |

**What This Analysis Tells Your Leadership:**

✅ **Hybrid Monitoring Validated**: Both platforms successfully detecting sensitive data in their respective environments

✅ **Complementary Coverage**: Scanner handles legacy file shares; DLP monitors cloud collaboration

✅ **Detection Consistency**: Cross-platform comparison validates SIT pattern accuracy across environments

✅ **Governance Strategy**: Clear understanding of platform strengths informs future protection decisions

**Next Steps:**

- Review the generated report for detailed platform-specific findings.
- Identify any coverage gaps that require additional protection.

> **🎯 Capstone Lab Complete**: You now have a comprehensive cross-platform analysis report demonstrating **end-to-end hybrid SIT governance** across both on-premises and cloud environments. The `Final_Stakeholder_Report_CrossPlatform.txt` provides all the insights needed for compliance leadership, with detailed breakdowns by share location (on-premises) and SIT type (SharePoint), cross-platform comparison, strategic recommendations, and actionable next steps. **This capstone achievement demonstrates your mastery of unified cross-platform monitoring, data consolidation, and executive-level compliance reporting.**

---

## Conclusion

**Skills Demonstrated:**

- **Activity Explorer Proficiency**: Export sensitive data discovery and DLP policy match events using workload-specific filtering.
- **Cross-Platform Analysis**: Compare on-premises scanner detection with cloud DLP policy enforcement.
- **PowerShell Reporting**: Generate professional executive stakeholder reports from Activity Explorer exports.
- **Workload Filtering Understanding**: Apply correct Activity Explorer filters for different data sources.
- **Hybrid Governance Strategy**: Understand complementary detection methods across on-premises and cloud environments.

**Key Takeaways:**

- **Activity Types Matter**: "Files discovered" (scanner) vs "DLP policy match" (cloud DLP) represent different detection mechanisms.
- **Workload Filtering**: Activity Explorer uses workload-specific filters to separate monitoring streams.
- **Detection Methods**: Scanner provides batch discovery; DLP provides real-time enforcement.
- **Unified Visibility**: Activity Explorer consolidates cross-platform monitoring in single interface.
- **Complementary Approaches**: Scanner and DLP work together for comprehensive sensitive data governance.

**Next Lab Recommendations:**

- **Advanced-DLP-Policy-Testing**: Create additional DLP policies for OneDrive, Teams, and Exchange workloads.
- **Scanner-Advanced-Configuration**: Configure scanner content scan jobs for additional on-premises repositories.
- **Activity-Explorer-Advanced-Queries**: Explore Activity Explorer's advanced filtering and export capabilities.

---

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of cross-platform Activity Explorer analysis and PowerShell reporting automation while maintaining technical accuracy for hybrid data governance scenarios.*
