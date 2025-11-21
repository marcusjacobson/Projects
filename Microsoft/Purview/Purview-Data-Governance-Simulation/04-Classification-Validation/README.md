# Classification Validation

This lab initiates **on-demand classification** for uploaded documents and validates that built-in Sensitive Information Types (SITs) are correctly detected. You'll start a classification scan that populates Content Explorer within 7 days, enabling all four Lab 05 discovery methods.

> **⏱️ Timing Context**: On-demand classification provides Content Explorer results within **7 days** for new data, compared to 7-14 days for automatic classification. This lab teaches the proactive scanning workflow used in enterprise environments.

---

## 🚀 Quick Navigation: Your Lab 04 + Lab 05 Workflow

**Recommended Approach for All Users:**

1. **Complete Lab 04 Step 1** (~15-30 minutes): [Start on-demand classification scan](#step-1-initiate-on-demand-classification-scan)
   - Initiates 7-day classification process that enables Labs 05c/05d
   - Required for Labs 05c and 05d, but also provides validation baseline for Labs 05a and 05b

2. **Start Labs 05a or 05b Immediately** (no waiting - proceed right after Step 1):
   - ✅ **[Lab 05a: PnP Direct File Access](../05-Data-Discovery-Paths/05a-PnP-Direct-File-Access/)** - Start now, works immediately
   - ✅ **[Lab 05b: eDiscovery Compliance Search](../05-Data-Discovery-Paths/05b-eDiscovery-Compliance-Search/)** - Start after 24 hours from Lab 03
   - These labs do NOT require classification completion

3. **Return to Lab 04 Steps 2-7** (after ~7 days): Complete validation once classification finishes
   - This completes Lab 04 and enables Labs 05c/05d

4. **Start Advanced Labs 05c or 05d** (after completing Lab 04 Steps 2-7):
   - ✅ **[Lab 05c: Graph API Discovery](../05-Data-Discovery-Paths/05c-Graph-API-Discovery/)** - Automated recurring reports
   - ✅ **[Lab 05d: SharePoint Search Discovery](../05-Data-Discovery-Paths/05d-SharePoint-Search-Discovery/)** - Site-specific queries
   - These labs REQUIRE Lab 04 Steps 2-7 completion

> **💡 Why This Workflow?** By starting Lab 04's classification scan first, you enable all four Lab 05 discovery methods. While waiting for classification to complete (~7 days), you can explore Labs 05a and 05b immediately. This maximizes your learning efficiency and ensures you have flexibility to try all discovery approaches.
>
> **⚠️ What If You Skip Lab 04?** Labs 05a and 05b will work, but Labs 05c and 05d will require waiting 7-14 days for automatic indexing. Starting Lab 04 now accelerates this to 7 days and provides official Purview validation results.

**For detailed Lab 05 path comparison**, see the [Next Steps: Choose Your Lab 05 Discovery Path](#-next-steps-choose-your-lab-05-discovery-path) section at the end of this document.

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

## 🎯 Use Case: Enterprise Data Discovery & Reporting

**Real-World Scenario**: Organizations with hundreds of SharePoint sites and petabytes of existing data need to quickly identify HR-related sensitive information (SSN, PII, etc.) for reporting, analysis, and compliance purposes. Traditional eDiscovery can take days or weeks to scan large datasets.

**This Lab's Role**: Initiate **on-demand classification scans** to proactively classify newly uploaded documents from Lab 03 and populate the **Content Explorer / Microsoft Search unified index**. This lab provides:

1. **7-day results** (faster than 7-14 day automatic indexing)
2. **Portal-based comprehensive scan** with official Purview SIT accuracy
3. **Foundation for Labs 05c/05d** - These discovery paths query the same Content Explorer index
4. **Validation baseline** - Compare Lab 05a regex detection against official Purview results

**Lab 04 vs Lab 05**: Lab 04 populates Content Explorer with classification data. Lab 05 provides **four different methods** to discover and report on that data (or access files directly without classification).

### Lab 04 Approach: On-Demand Classification + Content Explorer

This lab uses **on-demand classification scans** initiated through the Microsoft Purview Compliance Portal, with results validated in **Content Explorer**. This approach:

- ✅ Requires no PowerShell authentication (avoids WAM issues)
- ✅ Provides fastest results for new content (7 days vs. 7-14 days automatic)
- ✅ Proactive scanning - don't wait for passive Microsoft Search indexing
- ✅ Enables visual exploration of classified content in Content Explorer
- ✅ Enables manual CSV exports for validation
- ✅ Serves as foundation for Lab 05 discovery paths

### Required Prerequisites

**For Lab Environment** (Labs 1-3 completed):

- ✅ SharePoint sites created (Lab 01)
- ✅ Test documents generated with SITs (Lab 02)
- ✅ Documents uploaded to SharePoint (Lab 03)
- ⏱️ Wait 15-30 minutes for SharePoint document indexing (not classification - just file indexing)

**For Existing Production Data**:

- ✅ Microsoft Purview Information Protection enabled
- ✅ SharePoint sites included in Purview compliance scope
- ✅ Compliance Administrator role to initiate on-demand scans
- ⏱️ For historical data already in SharePoint: Automatic classification likely already complete (check Content Explorer)

> **💡 Note**: This project focuses on **data discovery and reporting**, not DLP policies or prevention. Classification is all you need for finding and reporting on sensitive data.

**Classification Timeline**:

Classification timelines are **fixed by Microsoft's backend indexing processes**, not dependent on document volume:

- **On-Demand Classification** (This Lab): Content Explorer updates within **7 days** after scan completion
- **Automatic Classification** (Alternative): Microsoft Search indexing takes **7-14 days** for new SharePoint content

> **💡 Lab Approach**: This lab uses on-demand classification to accelerate results for Lab 03 uploads (new content).
>
> **💡 Production Note**: For existing data already in SharePoint (months/years old), automatic classification has likely completed. Check Content Explorer immediately for historical data.

---

## Classification Validation Workflow

This lab uses the Microsoft Purview Compliance Portal web interface to initiate on-demand classification scans and validate results.

> **⏱️ Workflow Timeline**: This lab involves initiating a classification scan (15-30 minutes), then waiting up to 7 days for scan completion before validation. You'll start the scan, then return to complete validation steps once classification finishes.

---

## 🚀 Lab 05 Path Dependencies & Recommendations

**Which Lab 05 Discovery Paths Require Classification?**

| Lab 05 Path | Requires Classification? | When Can You Start? |
|-------------|--------------------------|---------------------|
| **Lab 05a: PnP Direct File Access** | ❌ No | ✅ **Immediately after Lab 04 Step 1** |
| **Lab 05b: eDiscovery Compliance Search** | ❌ No | ✅ **24 hours after Lab 03** (can start after Lab 04 Step 1) |
| **Lab 05c: Graph API Discovery** | ✅ Yes | ⏳ **After Lab 04 Steps 2-7 complete** (~7 days) |
| **Lab 05d: SharePoint Search Discovery** | ✅ Yes | ⏳ **After Lab 04 Steps 2-7 complete** (~7 days) |

### Recommended Approach: Start Classification Now

Even if you plan to begin with Lab 05a or Lab 05b (which work without classification), **we recommend starting the on-demand classification scan now**:

- **Enables all discovery methods**: You'll have the flexibility to explore Labs 05c and 05d without additional waiting
- **Provides validation baseline**: Official Purview SIT detection results to compare against Lab 05a's regex accuracy
- **Teaches enterprise workflow**: Learn the on-demand classification process used in real-world scenarios
- **Accelerates unified index population**: 7 days with Lab 04 vs. 7-14 days waiting for automatic indexing

> **⏱️ Timeline Strategy**:
>
> 1. Complete Lab 04 Step 1 to start classification scan (~15-30 minutes)
> 2. **Immediately proceed to Lab 05a or 05b** - no waiting required
> 3. After ~7 days, return to complete Lab 04 Steps 2-7
> 4. Then start Labs 05c or 05d (now enabled by completed classification)
>
> **🔑 What Gets Enabled**: Labs 05a/05b work immediately (no classification needed). Labs 05c/05d require Lab 04 Steps 2-7 completion, which populates the Microsoft Search unified index (Content Explorer) needed for advanced discovery methods.

---

### Step 1: Initiate On-Demand Classification Scan

> **⏱️ Timing Advantage**: On-Demand Classification provides Content Explorer results within **7 days** compared to **7-14 days** for automatic (passive) classification that relies on Microsoft Search indexing.
>
> **🔑 Enables Lab 05c/05d**: Starting this on-demand scan populates the Microsoft Search unified index (Content Explorer), which is required for Lab 05c (Graph API Discovery) and Lab 05d (SharePoint Search Discovery). Lab 05a and Lab 05b do NOT require this step.

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
>
> **💡 Next Steps - Choose Your Path**:
>
> - **Option 1**: [Go to Lab 05a](../05-Data-Discovery-Paths/05a-PnP-Direct-File-Access/) or [Lab 05b](../05-Data-Discovery-Paths/05b-eDiscovery-Compliance-Search/) now - these work immediately without waiting
> - **Option 2**: Wait for classification to complete (~7 days), then return here to complete Steps 2-7 before starting Labs 05c or 05d
> - The classification scan runs as a background process in Microsoft Purview

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

> **💡 Optional Step**: During the 7-day waiting period, you can monitor scan progress and check Content Explorer for early results. Most users will skip this step and return after classification completes.

**Check On-Demand Scan Status**:

- Navigate to **Data Classification** > **Classifiers** > **On-demand classification** tab
- Find your scan by name: `Lab03-HR-Security-Classification`
- Review scan status progression:
  - **Estimating** → **Estimation complete** → **Classifying** → **Complete**
- Click on the scan name to view detailed progress:
  - **Items scanned**: Current count of items processed
  - **Items with sensitive info**: Running count of detections
  - **Estimated completion**: Projected finish time (if shown)
  - **Progress percentage**: Visual indicator of completion status

**Check Content Explorer for Early Results**:

- Navigate to **Solutions** > **Data Lifecycle Management** > **Explorers** > **Content explorer**
- Browse to the **Sensitive info types** filter/category in the left navigation
- Click on each SIT type to see if documents are appearing (e.g., "U.S. Social Security Number (SSN)")
- Check the document count displayed for each SIT type
- Use the **Locations** filter to see which SharePoint sites have classified content

**What to Monitor**:

- **Document counts per SIT type**: Should increase as classification progresses (e.g., SSN shows 250+ documents)
- **Sensitive info types appearing**: Should start seeing SSN, Credit Card, Bank Account, Passport, Driver's License, ITIN, ABA Routing Number, IBAN
- **Site locations**: Should include your simulation SharePoint sites (HR-Simulation, Finance-Simulation, Legal-Simulation, Marketing-Simulation, IT-Simulation)

**If classification is not progressing after expected timeframes**:

> **⏱️ Timing Expectations**:
>
> - **On-Demand Classification**: Allow up to 7 days for scan completion after starting classification in Step 2
> - **Automatic Classification**: Allow 7-14 days for Microsoft Search indexing of new SharePoint content

**Troubleshooting Steps**:

- For **on-demand scans**: Check scan status in **Data Classification** > **Classifiers** > **On-demand classification** tab > Click your scan name for detailed progress
- For **automatic classification**: Verify documents uploaded successfully in Lab 03 (check SharePoint sites manually)
- Confirm SharePoint sites are included in Purview compliance scope (**Settings** > **Data sources** > Verify SharePoint Online is enabled)
- Note: Auto-labeling policies are NOT required for classification detection (only for applying retention/sensitivity labels)
- Be patient: Classification is a background process that can take several days to complete

> **💡 Why Target Specific SITs?**: By selecting only the 8 HR/security-related SITs that match our Lab 02 document generation, the scan is more efficient (faster processing) and results are more relevant (no noise from unrelated SITs). This focused approach aligns with real-world best practices where organizations scan for specific compliance requirements rather than all 300+ available SITs.

### Step 4: View Classification Results in Content Explorer

> **⏱️ When to Check**: After on-demand classification completes (up to 7 days), or after automatic classification indexing completes (7-14 days for new content).

Once classification completes, explore the detailed results.

Navigate to Content Explorer and review classification data:

- Click on **Sensitive info types** tab
- Click on individual SIT types to see documents containing them:
  - **U.S. Social Security Number (SSN)** - Should show ~250 documents (HR category)
  - **Credit Card Number** - Should show ~180 documents (Financial category)
  - **U.S. Bank Account Number** - Should show ~175 documents (Financial category)
  - **U.S./U.K. Passport Number** - Should show ~80 documents (Identity category)
  - **U.S. Driver's License Number** - Should show ~85-95 documents (Identity category, varies by state format)
  - **U.S. Individual Taxpayer Identification Number (ITIN)** - Should show ~90 documents (Identity category)
  - **ABA Routing Number** - Should show ~165 documents (Financial category)
  - **International Bank Account Number (IBAN)** - Should show ~50 documents (Financial category)

For each SIT type, examine:

- **Document count**: Total documents containing this SIT
- **Locations**: SharePoint sites where SITs were detected
- **Confidence levels**: Distribution of High/Medium/Low confidence detections

**Expected Classification Coverage** (based on Lab 02 generation):

| Document Category | Expected SIT Coverage | Typical Confidence |
|-------------------|------------------------|-------------------|
| **HR Documents** | 95-100% (SSN detection) | High (95%+) |
| **Financial Documents** | 85-95% (Multi-SIT) | High (90%+) |
| **Identity Documents** | 85-95% (Passport/DL/ITIN) | High (90%+) |
| **Mixed Documents** | 60-75% (Multiple SITs) | Mixed (85%+) |

### Step 5: Export Classification Data Manually

Export classification results for use in Lab 05 (DLP) and Lab 06 (Reporting).

**Manual Export Process**:

For each sensitive information type:

- In **Content Explorer**, click on the SIT type (e.g., "U.S. Social Security Number (SSN)")
- Click the **Export** button (top-right of the results pane)
- Choose export options:
  - **Date range**: Last 30 days (or custom range to include all Lab 03 upload dates)
  - **Format**: CSV recommended for Lab 06 reporting
- Click **Export** and wait for the export to complete (may take 5-15 minutes)
- Download the CSV file when ready (you'll receive an in-portal notification or check **Exports** section)
- Save the exported CSV to your local Reports directory: `C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\reports\`

**File Naming Convention** (recommended):

- `classification-results-SSN-2025-11-17.csv`
- `classification-results-CreditCard-2025-11-17.csv`
- `classification-results-BankAccount-2025-11-17.csv`
- `classification-results-Passport-2025-11-17.csv`
- `classification-results-DriverLicense-2025-11-17.csv`
- `classification-results-ITIN-2025-11-17.csv`
- `classification-results-ABARouting-2025-11-17.csv`
- `classification-results-IBAN-2025-11-17.csv`

**Alternative: Export All SITs in One Report**:

- In **Content Explorer**, select **All sensitive info types** view
- Click **Export** to export comprehensive classification data
- Save as: `classification-results-complete-2025-11-17.csv`

### Step 6: Validate SIT Detection Accuracy Manually

Compare exported classification results against Lab 02 document generation reports.

**Manual Validation Process**:

Open the Lab 02 generation report:

- Navigate to: `C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\02-Test-Data-Generation\reports\`
- Open the most recent generation report (e.g., `generation-report-2025-11-15-*.json`)
- Review the **expected SIT counts** by category

Compare against Content Explorer data:

| SIT Type | Expected (Lab 02) | Detected (Lab 04) | Accuracy | Status |
|----------|-------------------|-------------------|----------|--------|
| **SSN** | ~250 | _[Your count]_ | _[Calculate %]_ | ✅ Pass if >95% |
| **Credit Card** | ~180 | _[Your count]_ | _[Calculate %]_ | ✅ Pass if >95% |
| **Bank Account** | ~175 | _[Your count]_ | _[Calculate %]_ | ✅ Pass if >95% |
| **Passport** | ~80 | _[Your count]_ | _[Calculate %]_ | ✅ Pass if >95% |
| **Driver's License** | ~85-95 | _[Your count]_ | _[Calculate %]_ | ✅ Pass if >85% |
| **ITIN** | ~90 | _[Your count]_ | _[Calculate %]_ | ✅ Pass if >95% |
| **ABA Routing** | ~165 | _[Your count]_ | _[Calculate %]_ | ✅ Pass if >95% |
| **IBAN** | ~50 | _[Your count]_ | _[Calculate %]_ | ✅ Pass if >90% |

**Accuracy Calculation**:

```text
Accuracy % = (Detected Count / Expected Count) × 100

Example:
Expected SSN: 250
Detected SSN: 245
Accuracy = (245 / 250) × 100 = 98% ✅ Pass (above 95% threshold)
```

**Validation Results**:

- ✅ **Pass**: Accuracy ≥ 95% for most SIT types (Driver's License ≥ 85% acceptable due to format variations)
- ⚠️ **Warning**: Accuracy 85-94% (investigate low-confidence detections or pattern mismatches)
- ❌ **Fail**: Accuracy < 85% (review document generation patterns, check for file corruption, verify SIT definitions match)

### Step 7: Document Your Findings

Create a summary of classification validation results for Lab 05 and Lab 06.

**Create a manual summary document** (save as `classification-validation-summary-2025-11-17.md` in reports directory):

```markdown
# Lab 04 Classification Validation Summary

**Completed**: 2025-11-17  
**Method**: Portal UI with On-Demand Classification (Recommended)  
**Scan Name**: Lab03-HR-Security-Classification  
**Classification Timeline**: [Your scan initiation date] to [completion date] (up to 7 days)

## On-Demand Classification Scan Details

- **Scan Status**: [Estimating / Classifying / Complete]
- **Sites Scanned**: [List your 5 simulation sites]
- **Estimated File Count**: [From estimation phase]
- **Date Range**: Content created or modified in last 30 days
- **Targeted SITs**: 8 HR/security-related sensitive info types (focused scan)

## Classification Coverage

- **Total Documents**: [Your count from Lab 03]
- **Documents with SITs**: [Your count from Content Explorer]
- **Coverage %**: [Calculate: (Documents with SITs / Total Documents) × 100]

## SIT Detection Results

| SIT Type | Expected | Detected | Accuracy | Confidence Distribution |
|----------|----------|----------|----------|-------------------------|
| SSN | 250 | [Your count] | [%] | High: [%], Med: [%], Low: [%] |
| Credit Card | 180 | [Your count] | [%] | High: [%], Med: [%], Low: [%] |
| Bank Account | 175 | [Your count] | [%] | High: [%], Med: [%], Low: [%] |
| Passport | 80 | [Your count] | [%] | High: [%], Med: [%], Low: [%] |
| Driver's License | 85-95 | [Your count] | [%] | High: [%], Med: [%], Low: [%] |
| ITIN | 90 | [Your count] | [%] | High: [%], Med: [%], Low: [%] |
| ABA Routing | 165 | [Your count] | [%] | High: [%], Med: [%], Low: [%] |
| IBAN | 50 | [Your count] | [%] | High: [%], Med: [%], Low: [%] |

## Validation Status

- ✅ Overall Accuracy: [Your calculated average accuracy]
- ✅ Classification coverage meets target (>90%)
- ✅ High confidence detections: [Your %] (Target: >85%)
- ✅ Ready to proceed to Lab 05 (DLP Policy Implementation)

## Notes

[Any observations, unexpected results, or issues encountered]
```

---

## 🎯 Next Steps: Choose Your Lab 05 Discovery Path

**Where You Are Now**: Lab 04 classification is complete (or you completed Step 1 and are ready to start immediate labs).

Choose from **four discovery methods** in Lab 05 based on what you've completed:

**Available Now (after Lab 04 Step 1)**: Labs 05a and 05b  
**Available After Lab 04 Steps 2-7**: Labs 05c and 05d

### Lab 05a: PnP PowerShell Direct File Access

**Timeline**: ✅ **Start immediately after Lab 04 Step 1**  
**Accuracy**: 70-90% (regex-based)  
**Lab 04 Required**: Only Step 1 (scan initiation)

Direct file enumeration via PnP PowerShell with custom regex pattern matching.

**Best For**: Immediate results while waiting for classification to complete, learning SIT detection fundamentals, interim analysis.

**[Go to Lab 05a →](../05-Data-Discovery-Paths/05a-PnP-Direct-File-Access/)**

---

### Lab 05b: eDiscovery Compliance Search

**Timeline**: ✅ **Start after Lab 04 Step 1** (needs 24 hours from Lab 03 upload)  
**Accuracy**: 100% (official Purview SITs)  
**Lab 04 Required**: Only Step 1 (scan initiation)

Portal-based eDiscovery search with official Purview SIT detection.

**Best For**: Fast official results while waiting for Lab 04 classification, compliance-quality reporting, validating Lab 05a regex accuracy.

**[Go to Lab 05b →](../05-Data-Discovery-Paths/05b-eDiscovery-Compliance-Search/)**

---

### Lab 05c: Graph API Discovery

**Timeline**: ⏳ **Requires Lab 04 Steps 2-7 completion** (~7 days after Step 1)  
**Accuracy**: 100% (official Purview SITs)  
**Lab 04 Required**: ✅ Yes (all steps through validation)

Automated Microsoft Graph Search API queries with PowerShell scripting.

**Best For**: Recurring monitoring, SIEM integration, large-scale tenant-wide discovery, automation.

**Prerequisites**: Return to complete Lab 04 Steps 2-7 after classification finishes before starting this lab.

**[Go to Lab 05c →](../05-Data-Discovery-Paths/05c-Graph-API-Discovery/)**

---

### Lab 05d: SharePoint Search Discovery

**Timeline**: ⏳ **Requires Lab 04 Steps 2-7 completion** (~7 days after Step 1)  
**Accuracy**: 100% (official Purview SITs)  
**Lab 04 Required**: ✅ Yes (all steps through validation)

Site-specific queries via PnP PowerShell with rich metadata extraction.

**Best For**: Targeted site scans, detailed file metadata, custom SIT pattern validation.

**Prerequisites**: Return to complete Lab 04 Steps 2-7 after classification finishes before starting this lab.

**[Go to Lab 05d →](../05-Data-Discovery-Paths/05d-SharePoint-Search-Discovery/)**

---

### Quick Decision Guide

| Your Priority | Choose This Lab | When Can You Start? |
|---------------|-----------------|---------------------|
| "I need results right now" | **Lab 05a** (immediate, regex-based) | ✅ After Lab 04 Step 1 |
| "I need official SITs fast" | **Lab 05b** (24 hours, 100% accurate) | ✅ After Lab 04 Step 1 + 24 hours |
| "I need automated recurring scans" | **Lab 05c** (Graph API, fully automated) | ⏳ After Lab 04 Steps 2-7 (~7 days) |
| "I need detailed site-specific reports" | **Lab 05d** (SharePoint Search, rich metadata) | ⏳ After Lab 04 Steps 2-7 (~7 days) |

> **💡 Workflow Summary**:
> 
> - **Now**: Labs 05a and 05b work immediately after completing Lab 04 Step 1
> - **Later**: Return to complete Lab 04 Steps 2-7 (~7 days), then Labs 05c and 05d become available
> - Lab 04's full completion populates the Microsoft Search unified index (Content Explorer) needed for Labs 05c/05d

---

## Validation Checklist

**Phase 1 (After Step 1 - Immediate)**:

- [ ] **Classification Scan Initiated**: Created scan targeting 5 simulation SharePoint sites with 8 HR/security SITs
- [ ] **Scan Status Confirmed**: Scan shows "Estimating" or "Classifying" status in portal
- [ ] **Ready for Labs 05a/05b**: Can proceed to immediate discovery paths while waiting

**Phase 2 (After Steps 2-7 - After ~7 Days)**:

- [ ] **Classification Complete**: Content Explorer shows classified documents (>90% coverage)
- [ ] **SIT Detection Verified**: All 8 expected SIT types visible (SSN, Credit Card, Bank Account, Passport, Driver's License, ITIN, ABA Routing, IBAN)
- [ ] **Results Exported**: Downloaded CSV exports from Content Explorer
- [ ] **Accuracy Validated**: Compared detected counts against Lab 02 reports (>90% accuracy)
- [ ] **Findings Documented**: Created classification validation summary in reports directory
- [ ] **Ready for Labs 05c/05d**: Content Explorer populated, advanced discovery paths enabled

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
- Exporting classification data manually for validation and reporting.
- Validating SIT detection accuracy against known document generation reports.
- Documenting classification validation findings for stakeholder communication.

### Deliverables

- **Classification validation reports** (CSV exports from Content Explorer).
- **Accuracy validation summary** comparing detected SITs against Lab 02 generation reports.
- **Documentation of findings** including SIT detection rates, confidence scores, and any anomalies.
- **Readiness for Lab 05** with understanding of three discovery path options.

---

## Completion Criteria

You have successfully completed Lab 04 when:

1. ✅ **Classification Scan Initiated** (Step 1): Created and started on-demand classification scan targeting Lab 03 SharePoint sites.
2. ✅ **Classification Complete** (After ~7 days): Purview scan finished and Content Explorer shows classified documents.
3. ✅ **SIT Detection Validated** (Steps 2-7): Verified expected SIT types detected with >90% accuracy.
4. ✅ **Results Exported** (Step 5): Downloaded CSV reports for key sensitive information types.
5. ✅ **Accuracy Validated** (Step 6): Compared detected counts against Lab 02 generation reports.
6. ✅ **Findings Documented** (Step 7): Created classification validation summary.

> **⏱️ Two-Phase Completion**: Complete Step 1 (~15-30 minutes), then return after ~7 days to complete Steps 2-7.

**Ready for Lab 05**: You can start Labs 05a/05b immediately after Step 1, or wait to start Labs 05c/05d after completing all steps.

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

_AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Purview classification validation while maintaining technical accuracy and reflecting enterprise-grade data discovery standards for sensitive information detection._
