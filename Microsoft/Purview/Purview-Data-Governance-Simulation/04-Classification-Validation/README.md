# Classification Validation

This lab initiates **on-demand classification** for uploaded documents and validates that built-in Sensitive Information Types (SITs) are correctly detected. You'll start a classification scan that populates Content Explorer within 7 days, enabling all four Lab 05 discovery methods.

> **⏱️ Timing Context**: On-demand classification provides Content Explorer results within **7 days** for new data, compared to 7-14 days for automatic classification. This lab teaches the proactive scanning workflow used in enterprise environments.

---

## 🚀 Quick Navigation: Lab 04 + Lab 05 Workflow

1. **Start Lab 04 Step 1** (~15 min): [Initiate classification scan](#step-1-initiate-on-demand-classification-scan). This starts the 7-day deep scan for Content Explorer.
2. **Go to Lab 05** (Immediate): Proceed to **[Lab 05a](../05-Data-Discovery-Paths/05a-PnP-Direct-File-Access/)**, **[Lab 05b](../05-Data-Discovery-Paths/05b-eDiscovery-Compliance-Search/)**, or **[Lab 05c](../05-Data-Discovery-Paths/05c-Graph-API-Discovery/)**. You do *not* need to wait for Lab 04 to finish.
3. **Return Later** (7 Days): Come back to Lab 04 Steps 2-7 to validate your Lab 05 findings against the official Content Explorer baseline.

> **💡 Strategy**: Start the slow scan now (Lab 04), do the fast discovery now (Lab 05), and validate later.

**For guidance on using your results**, see [Next Steps](#-next-steps-leveraging-your-classification-baseline).

---

## Objectives

By completing this lab, you will:

- Trigger on-demand classification for SharePoint document libraries
- Monitor classification progress and completion status
- Validate built-in SIT detection accuracy across document categories
- Measure classification coverage percentages for all sites
- Export Content Explorer data for detailed classification analysis
- Generate comprehensive classification reports with confidence scores
- Verify expected SIT patterns match classification results

## Prerequisites

- Lab 00: Prerequisites Setup completed
- Lab 01: SharePoint Site Creation completed
- Lab 02: Test Data Generation completed
- Lab 03: Document Upload & Distribution completed
- Microsoft Purview Information Protection configured
- SharePoint Online sites included in Purview compliance scope
- Security & Compliance Center PowerShell access
- Content Explorer access with one of these role assignments:
  - **Compliance Administrator** role (Entra ID / Microsoft Purview role)
  - **Security Administrator** role (Entra ID / Microsoft Purview role)
  - OR **Content Explorer List viewer** + **Content Explorer Content viewer** role groups (for granular access)
  - For more information, see [Permissions in the Microsoft Purview portal](https://learn.microsoft.com/en-us/purview/purview-permissions)

## Microsoft Purview Classification Architecture

### Built-in SIT Detection

Microsoft Purview uses pattern matching, checksums, and machine learning to detect these built-in SITs:

| SIT Name | Pattern Detection | Document Categories |
|----------|-------------------|---------------------|
| **U.S. Social Security Number (SSN)** | Format: XXX-XX-XXXX with validation | HR Documents |
| **Credit Card Number** | Luhn algorithm validation, card prefixes | Financial Documents |
| **U.S. Bank Account Number** | 8-17 digit patterns | Financial Documents |
| **U.S./U.K. Passport Number** | Alphanumeric patterns, country codes | Identity Documents |
| **U.S. Driver's License Number** | State-specific formats (CA, TX, NY, FL) | Identity Documents |
| **U.S. Individual Taxpayer ID (ITIN)** | Format: 9XX-XX-XXXX | Identity Documents |
| **ABA Routing Number** | 9-digit with checksum validation | Financial Documents |
| **International Bank Account Number (IBAN)** | Country-specific IBAN formats | Financial Documents |

### Classification Process

1. **Document Indexing**: SharePoint indexes uploaded documents (15-30 minutes)
2. **On-Demand Classification**: Request classification via API or UI
3. **Pattern Matching**: Purview scans content for SIT patterns
4. **Confidence Scoring**: Assigns confidence levels (High: 85-100%, Medium: 75-84%, Low: 65-74%)
5. **Content Explorer Update**: Results visible in Content Explorer (may take additional time)
6. **Activity Logging**: Classification events logged in Activity Explorer

### Classification Timing

> **⏱️ Classification Methods**:
>
> - **On-Demand Classification** (This Lab): Up to **7 days** for scan completion and Content Explorer visibility
> - **Automatic Classification** (Alternative): **7-14 days** for Microsoft Search indexing of new content
>
> This lab uses on-demand classification to accelerate results for Lab 03 uploads.

## Lab Structure

```text
04-Classification-Validation/
├── README.md (this file)
└── reports/                                  # Classification validation reports
```

---

## 🎯 Strategic Context: The "Fire and Forget" Workflow

**Real-World Scenario**: Organizations need to quickly identify sensitive information (SSN, PII) for reporting and compliance, but deep scanning takes time.

**The Strategy**:

1. **Start Lab 04 (Deep Scan)**: Initiate the 7-day Content Explorer scan immediately.
2. **Switch to Lab 05 (Rapid Discovery)**: Use fast tools (Regex, eDiscovery) to get immediate results while waiting.
3. **Validate Later**: Use Lab 04's "Gold Standard" visual results to verify your Lab 05 findings after 7 days.

### 🔍 Comparison: Lab 04 vs. Lab 05

| Feature | ✅ Lab 04 (Content Explorer) | ⚡ Lab 05 (Discovery Paths) |
|---------|------------------------------|----------------------------|
| **Role** | **"Gold Standard" Baseline** | **Rapid Discovery & Reporting** |
| **Engine** | Data Classification Service (DCS) | SharePoint Search / Graph API |
| **Timeline** | **7 Days** (Deep Scan) | **Immediate - 24 Hours** |
| **Output** | Visual Dashboard | CSV Reports & Analytics |

> **🔥 "Fire and Forget"**: Start Step 1 now, then **ignore this lab** and proceed to Lab 05. Do not wait for completion.

---

## Classification Validation Workflow

This lab uses the Microsoft Purview Compliance Portal web interface to initiate on-demand classification scans and validate results.

> **⏱️ Workflow Timeline**: This lab involves initiating a classification scan (15-30 minutes), then waiting up to 7 days for scan completion before validation. You'll start the scan, then return to complete validation steps once classification finishes.

---

### Step 1: Initiate On-Demand Classification Scan

> **⏱️ Timing Advantage**: On-Demand Classification provides Content Explorer results within **7 days** compared to **7-14 days** for automatic (passive) classification that relies on Microsoft Search indexing.
>
> **🔑 Enables Validation**: Starting this on-demand scan populates Content Explorer, which serves as your "Gold Standard" validation baseline for all Lab 05 discovery methods.

Initiate a proactive classification scan for your Lab 03 SharePoint sites.

**Navigate to Microsoft Purview Portal**:

- Open a web browser and navigate to: [https://purview.microsoft.com](https://purview.microsoft.com)
- Sign in with your Microsoft 365 credentials (Compliance Administrator or Security Administrator role required)

**Navigate to On-Demand Classification**:

- Navigate to **Data Classification** > **Classifiers** in the left navigation
- Select the **On-demand classification** tab
- Click **+ New scan** button to launch the classification wizard

**Step 1: Name Your Scan**:

- **Scan name**: Enter `Lab03-HR-Security-Classification`
- **Description**: "On-demand classification for HR and security-related sensitive data from Lab 03 uploads"
- Click **Next**

**Step 2: Choose Locations**:

- Select **SharePoint** as the location type
- Click **Choose sites**
- Add your simulation SharePoint sites:
  - Search for and add: HR-Simulation site
  - Search for and add: Finance-Simulation site
  - Search for and add: Legal-Simulation site
  - Search for and add: Marketing-Simulation site
  - Search for and add: IT-Simulation site
- Click **Next**

**Step 3: Define Scan Rules**:

> **💡 Targeted SIT Selection**: This project focuses on HR and security-related sensitive data. We'll select specific SITs that align with our Lab 02 document generation rather than scanning for all 300+ built-in SITs. This makes the scan more efficient and results more relevant.

- **Sensitive info types**: Click **Choose sensitive info types**
- **Select these HR and security-related SITs** (aligned with Lab 02 generation):
  - ✅ **U.S. Social Security Number (SSN)** - Primary HR identifier
  - ✅ **Credit Card Number** - Financial security data
  - ✅ **U.S. Bank Account Number** - Financial account data
  - ✅ **U.S./U.K. Passport Number** - Identity verification documents
  - ✅ **U.S. Driver's License Number** - Identity verification documents
  - ✅ **U.S. Individual Taxpayer Identification Number (ITIN)** - Tax-related HR data
  - ✅ **ABA Routing Number** - Banking information
  - ✅ **International Bank Account Number (IBAN)** - International banking data
- **Trainable classifiers**: Leave unselected (not used in this lab)
- Click **Next**

**Step 4: Choose Date Range and File Types**:

- **Date range**: Select **Content created or modified in the last 30 days** (captures Lab 03 uploads)
- **File types**: Leave default selection (Word, Excel, PowerPoint, PDF - matches Lab 02 generation)
- Click **Next**

**Step 5: Review and Create**:

- Review your scan configuration:
  - Scan name: Lab03-HR-Security-Classification
  - Locations: 5 SharePoint sites
  - Sensitive info types: 8 HR/security-related SITs
  - Date range: Last 30 days
  - File types: Office documents and PDFs
- Click **Submit** to create the scan

**Monitor Scan Initiation**:

- The scan will begin automatically after submission
- Initial status: **Estimating** (calculating scope and duration)
- **⏱️ Estimation Phase**: Typically completes within 15 minutes to 2 hours depending on document count
- You'll see a progress indicator showing the estimation phase

**View Estimation Results**:

Once estimation completes, you can view the scan details:

- Go to **Data Classification** > **Classifiers** > **On-demand classification** tab
- Find your scan: `Lab03-HR-Security-Classification`
- Click on the scan name to view details
- Review the **estimated item count** (should match your Lab 03 upload total ~1,000 files)
- Review the **estimated completion time** for the classification phase

**Start Classification Phase**:

After estimation completes, you must manually start the classification phase:

1. From the **On-demand classification** page, select your scan from the list: `Lab03-HR-Security-Classification`
2. Select **View estimation** to review the estimation results
3. On the **Estimation overview** tab, review:
   - **Items for review**: Documents matching your scan conditions (typically 300-500 files)
   - **Items available for scanning**: Total items analyzed (typically ~5,000)
   - **Estimated cost**: Processing cost based on item count
4. Select **Start classification** to begin the classification phase
5. The scan status will change from **Estimation complete** to **Classifying**

> **⏱️ Classification Timeline**: The classification phase can take **up to 7 days** to complete. You will receive in-portal notifications as the scan progresses through stages. Content Explorer will update within 7 days of scan completion.

---

### Step 2: Access Content Explorer (After Classification Completes)

> **⏱️ When to Start This Step**: Return to this step after your on-demand classification scan completes (up to 7 days after Step 1), OR if you're validating automatic classification that has already completed for existing production data.

Navigate to Content Explorer to review classification results.

- Open a web browser and navigate to: [https://purview.microsoft.com](https://purview.microsoft.com)
- Sign in with your Microsoft 365 credentials
- Navigate to **Solutions** > **Data Lifecycle Management** > **Explorers** > **Content explorer**
- Alternatively, use the global search bar and search for "Content Explorer"

**Expected Result**:

- Content Explorer dashboard loads successfully
- You see overview statistics for classified content
- Document counts appear for various sensitive info types
- No "Access Denied" errors (if you see errors, verify your role assignments per Prerequisites section)

---

### Step 3: Monitor Classification Progress (Optional)

> **💡 Optional Step**: Most users skip this step and return after 7 days.

**Check On-Demand Scan Status**:

- Navigate to **Data Classification** > **Classifiers** > **On-demand classification**.
- Review scan status: **Estimating** → **Classifying** → **Complete**.

**Check Content Explorer for Early Results**:

- Navigate to **Content Explorer**.
- Check if document counts for SITs (e.g., SSN) are increasing.
- **Note**: If counts are low, be patient. This is a background process.

### Step 4: Verify Data Population (Pre-Check)

> **⏱️ When to Check**: After on-demand classification completes (up to 7 days).

Before recording your official baseline in Step 5, verify that Content Explorer is populated with data that roughly matches your Lab 02 generation expectations.

**Expected Classification Coverage** (based on Lab 02 generation):

| Document Category | Expected SIT Coverage | Typical Confidence |
|-------------------|------------------------|-------------------|
| **HR Documents** | 95-100% (SSN detection) | High (95%+) |
| **Financial Documents** | 85-95% (Multi-SIT) | High (90%+) |
| **Identity Documents** | 85-95% (Passport/DL/ITIN) | High (90%+) |
| **Mixed Documents** | 60-75% (Multiple SITs) | Mixed (85%+) |

If your Content Explorer is empty or shows very low counts (<10), **do not proceed**. Wait for classification to complete.

### Step 5: Use Content Explorer as Visual Baseline

Instead of manually exporting CSV files (which is time-consuming and prone to format issues), use Content Explorer's visual interface as your "Gold Standard" baseline.

**Why Visual Validation?**

- **Accuracy**: Content Explorer uses the Data Classification Service (DCS), which is the most accurate engine in the Purview ecosystem.
- **Simplicity**: You can quickly see the total count of "U.S. Social Security Number (SSN)" without managing 8 different CSV files.
- **Verification**: You will use these visual counts to verify the automated reports generated in Lab 05.

**Action: Record Your Baseline Counts**:

Navigate to **Content Explorer** > **Sensitive info types** and record the total document count for each of your target SITs:

| SIT Type | Content Explorer Count (Visual) |
|----------|---------------------------------|
| **U.S. Social Security Number (SSN)** | _________________ |
| **Credit Card Number** | _________________ |
| **U.S. Bank Account Number** | _________________ |
| **U.S./U.K. Passport Number** | _________________ |
| **U.S. Driver's License Number** | _________________ |
| **U.S. Individual Taxpayer ID (ITIN)** | _________________ |
| **ABA Routing Number** | _________________ |
| **International Bank Account Number (IBAN)** | _________________ |

> **💡 Tip**: Take a screenshot of your Content Explorer dashboard for your records.

### Step 6: Run Cross-Lab Analysis (Lab 05)

Now that you have your visual baseline from Lab 04, use the automated tools in Lab 05 to generate a comprehensive comparison report.

**Navigate to Lab 05**:

- Open PowerShell
- Navigate to: `C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths`

**Run the Analysis Script**:

```powershell
.\scripts\Invoke-CrossLabAnalysis.ps1 -GenerateHtmlReport
```

**What This Does**:

1. **Scans** for completed reports from Lab 05a (PnP), Lab 05b (eDiscovery), and Lab 05c (Graph API).
2. **Normalizes** the data (handles different CSV formats, column names, and confidence scores).
3. **Generates** a unified HTML report comparing detection counts across all methods.

### Step 7: Validate Automated Findings

Compare your **Lab 05 Automated Report** against your **Lab 04 Visual Baseline**.

1. Open the generated HTML report from `05-Data-Discovery-Paths\reports\`.
2. Look at the **Detection Accuracy** section.
3. Compare the **Lab 05b/05c** counts against your **Content Explorer** notes from Step 5.

**Validation Criteria**:

- **Perfect Match**: Lab 05b/05c counts match Content Explorer exactly. (Expected for 100% indexed data).
- **Minor Variance (<5%)**: Acceptable due to indexing timing differences (Content Explorer can lag behind eDiscovery by 24-48 hours).
- **Major Variance (>10%)**: Indicates an issue.
  - *Higher in Content Explorer*: eDiscovery index might be stale.
  - *Higher in eDiscovery*: Content Explorer visualization might be delayed.

**Conclusion**:

If your Lab 05 automated reports match your Lab 04 visual baseline, you have successfully validated that your automated discovery pipelines (Lab 05) are accurate and reliable for ongoing compliance monitoring.

---

## 🎯 Next Steps: Leveraging Your Classification Baseline

Now that you have a validated "Gold Standard" baseline in Content Explorer, you can use this data to drive your data protection strategy.

### 1. Continuous Monitoring

Content Explorer is not just a one-time validation tool. Use it to monitor sensitive data growth over time.

- **Trend Analysis**: Check if sensitive data is increasing in unauthorized locations (e.g., "Marketing" site suddenly has Credit Card numbers).
- **Policy Effectiveness**: Verify if DLP policies are effectively blocking new sensitive data uploads.

### 2. Refine Automated Discovery (Lab 05)

If you noticed discrepancies between your Lab 04 baseline and your Lab 05 automated reports:

- **False Positives**: If Lab 05a (Regex) found more items than Content Explorer, those are likely false positives. Tune your regex patterns.
- **False Negatives**: If Lab 05b/c missed items found in Content Explorer, investigate indexing latency or search query scope.

### 3. Prioritize Remediation

Use the **Confidence Level** and **Count** to prioritize protection efforts:

- **Immediate Action**: High-volume, High-confidence detections in low-security sites (e.g., "Public" or "Marketing").
- **Investigation**: Low-confidence detections that might require manual review or "Trainable Classifiers" to improve accuracy.

> **🔄 Loop Back**: If you haven't run the full comparison yet, return to **[Lab 05 - Cross-Lab Analysis](../05-Data-Discovery-Paths/CROSS-LAB-ANALYSIS.md)** to generate your final compliance report.

---

## Validation Checklist

**Phase 1 (After Step 1 - Immediate)**:

- [ ] **Classification Scan Initiated**: Created scan targeting 5 simulation SharePoint sites with 8 HR/security SITs
- [ ] **Scan Status Confirmed**: Scan shows "Estimating" or "Classifying" status in portal
- [ ] **Ready for Labs 05a/05b**: Can proceed to immediate discovery paths while waiting

**Phase 2 (After Steps 2-7 - After ~7 Days)**:

- [ ] **Classification Complete**: Content Explorer shows classified documents (>90% coverage)
- [ ] **SIT Detection Verified**: All 8 expected SIT types visible (SSN, Credit Card, Bank Account, Passport, Driver's License, ITIN, ABA Routing, IBAN)
- [ ] **Visual Baseline Recorded**: Documented counts from Content Explorer for all target SITs
- [ ] **Cross-Lab Analysis Run**: Executed `Invoke-CrossLabAnalysis.ps1` in Lab 05
- [ ] **Automated Findings Validated**: Confirmed Lab 05 automated reports match Lab 04 visual baseline
- [ ] **Ready for Monitoring**: Content Explorer established as "Gold Standard" for ongoing compliance monitoring

---

## Expected Outcomes

Upon successful completion of Lab 04, you will have:

### Knowledge Acquired

- Understanding of Microsoft Purview automatic classification timelines and processes.
- Knowledge of Content Explorer capabilities for validating sensitive information detection.
- Familiarity with classification accuracy validation methodologies.
- Awareness of enterprise data discovery options for Lab 05 decision.

### Skills Demonstrated

- Accessing and navigating the modern Microsoft Purview portal.
- Using Content Explorer to review classified content and SIT detections.
- Establishing a visual baseline for sensitive data validation.
- Validating automated discovery pipelines against "Gold Standard" classification data.
- Documenting classification validation findings for stakeholder communication.

### Deliverables

- **Visual Baseline Records** (Screenshots/Notes from Content Explorer).
- **Cross-Lab Analysis Report** (HTML report from Lab 05).
- **Validation Confirmation** verifying automated discovery accuracy.
- **Readiness for Lab 05** with understanding of three discovery path options.

---

## Completion Criteria

You have successfully completed Lab 04 when:

1. ✅ **Classification Scan Initiated** (Step 1): Created and started on-demand classification scan targeting Lab 03 SharePoint sites.
2. ✅ **Classification Complete** (After ~7 days): Purview scan finished and Content Explorer shows classified documents.
3. ✅ **SIT Detection Validated** (Steps 2-4): Verified expected SIT types detected with >90% accuracy.
4. ✅ **Visual Baseline Recorded** (Step 5): Documented "Gold Standard" counts from Content Explorer.
5. ✅ **Cross-Lab Analysis Run** (Step 6): Generated automated comparison report in Lab 05.
6. ✅ **Findings Validated** (Step 7): Confirmed automated reports match visual baseline.

> **⏱️ Two-Phase Completion**: Complete Step 1 (~15-30 minutes), then return after ~7 days to complete Steps 2-7.

**Ready for Lab 05**: You can start Labs 05a/05b/05c immediately after Step 1, or wait to validate results after completing all steps.

---

## Additional Resources

- **Microsoft Purview Classification**: [Learn about data classification](https://learn.microsoft.com/en-us/purview/data-classification-overview)
- **Content Explorer**: [Use Content Explorer](https://learn.microsoft.com/en-us/purview/data-classification-content-explorer)
- **Activity Explorer**: [Use Activity Explorer](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)
- **Built-in SIT Definitions**: [Sensitive information type entity definitions](https://learn.microsoft.com/en-us/purview/sit-defn-all)
- **Classification Confidence**: [Confidence levels in entity definitions](https://learn.microsoft.com/en-us/purview/sit-confidence-levels)

---

## 🤖 AI-Assisted Content Generation

This comprehensive classification validation guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview classification validation best practices, Content Explorer workflows, and enterprise data discovery methodologies.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Purview classification validation while maintaining technical accuracy and reflecting enterprise-grade data discovery standards for sensitive information detection.*
