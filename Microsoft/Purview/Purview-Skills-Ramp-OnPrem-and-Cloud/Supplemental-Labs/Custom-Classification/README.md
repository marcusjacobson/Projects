# Supplemental Lab: Trainable Classifiers for Financial Reports

> **⚠️ UNDER DEVELOPMENT**: This lab is currently in development and testing. Lab will be validated and finalized after training completion and accuracy testing.

Create machine learning-based classifiers to automatically identify financial reports in Microsoft Purview.

---

## 📋 Lab Summary

**Duration**: 3 hours active + 24-hour ML training

**Goal**: Train a custom classifier to detect financial reports, apply to DLP policies, and validate accuracy.

**Skills**: ML training, sample curation, DLP integration, accuracy validation

---

## 🎯 What You'll Learn

✅ Create SharePoint training folders in Documents library (positive/negative samples)  
✅ Generate 100 financial reports + 200 non-financial documents  
✅ Train trainable classifier (24-hour automated ML workflow)  
✅ Review automated test results  
✅ Publish classifier and apply to DLP policy  
✅ Validate detection in Content Explorer  

---

## 📚 Prerequisites

**Required Access**:

- Microsoft 365 E5 or E5 Compliance license.
- Global Administrator or Compliance Administrator role.
- SharePoint Administrator role.

**Technical**:

- PowerShell 7+ installed.
- PnP PowerShell module: `Install-Module PnP.PowerShell -Scope CurrentUser`.
- SharePoint test site available.

**Knowledge**:

- Basic Microsoft Purview data classification understanding.
- SharePoint library management familiarity.
- PowerShell scripting basics.

---

## 🤔 When to Use Trainable Classifiers

**Use trainable classifiers when**:

- Documents have variable formats/structures.
- Pattern-based detection (regex) won't work.
- You have 50-500 representative positive samples available.
- Content is in English.
- You can provide 150-1,500 diverse negative samples.

| Scenario | Trainable Classifier | Custom SIT (Regex) |
|----------|---------------------|-------------------|
| **Content Type** | Unstructured documents | Structured patterns |
| **Examples** | Financial reports, contracts | Employee IDs, project codes |
| **Training Required** | Yes (24 hours) | No (immediate) |
| **Samples Needed** | 50-500 positive + 150-1,500 negative | Regex pattern only |
| **Accuracy** | 70-95% (probabilistic) | High (exact match) |
| **Language Support** | English only | All languages |
| **Best For** | Variable document formats | Fixed data patterns |

---

## 📂 Phase 1: Training Sample Preparation

### Step 1: Run Complete Training Data Setup

Navigate to the Custom-Classification scripts directory and run the comprehensive setup script:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Custom-Classification"
.\Setup-TrainableClassifierData.ps1
```

**What happens**:

- Script prompts for SharePoint site URL (e.g., `https://[YourTenant].sharepoint.com/sites/PurviewLab-RetentionTesting`).
- Checks for existing Entra ID app registration (needed for authentication):
  - If not found, guides through registration process (automatic, manual Azure Portal, or use existing Client ID).
  - Saves Client ID to environment variable for future runs.
- Prompts for authentication method (Interactive Browser or Device Code).
- Creates two folders in the root **Documents** library:
  - **FinancialReports_Positive** (for positive training samples).
  - **BusinessDocs_Negative** (for negative training samples).
- Generates and uploads 100 financial report documents to FinancialReports_Positive folder.
- Generates and uploads 200 business documents to BusinessDocs_Negative folder.

> 💡 **All-in-One Solution**: This single script performs complete setup - creates folder structure in the root Documents library and generates all 300 training documents automatically.
>
> **⚠️ Critical Requirement**: The training data folders **MUST be in the root Documents library** of your SharePoint site for Purview's trainable classifier to recognize them. Creating a custom library or nested folder structure will prevent the folders from appearing in the Purview folder picker.

**Financial reports include**: Quarterly earnings, annual reports, budget forecasts, cash flow statements, balance sheets, and income statements

**Business documents include**: HR policies, project plans, meeting notes, marketing materials, technical specifications, and employee handbooks

---

### Step 2: Wait for SharePoint and Purview Indexing

> ⏱️ **Required Wait Time**: **Minimum 1 hour, recommended 2-3 hours** before creating classifier
>
> **Microsoft's Official Guidance**: "If you create a new SharePoint site and folder for your seed data, allow at least an hour for that location to be indexed before creating the trainable classifier that uses that seed data." (Source: [Microsoft Learn - Trainable Classifiers](https://learn.microsoft.com/en-us/purview/trainable-classifiers-learn-about))

**Two indexing systems must complete**:

1. **SharePoint Search Indexing** (1+ hours) - Makes content searchable.
2. **Purview Compliance Crawler** (1-2+ hours) - Makes folders visible in classifier picker.

> **⚠️ Critical**: If you attempt to create the classifier before indexing completes, the folders **will not appear** in the Purview folder picker. Wait the full recommended time (2-3 hours from script completion) to ensure both SharePoint search and Purview's compliance crawler have indexed the folders.

**Verify indexing complete** (REQUIRED before creating classifier):

1. Navigate to your SharePoint site's **Documents** library.
2. Open **FinancialReports_Positive** folder - verify 100 items.
3. Open **BusinessDocs_Negative** folder - verify 200 items.
4. Use SharePoint search to test indexing:
   - Search for "revenue" (should find financial documents).
   - Search for "employee" (should find business documents).
5. Confirm folder item counts match expected totals.
6. Most important: Ensure 2-3 hours have elapsed since script completion.

---

## 🤖 Phase 2: Classifier Creation and Training

### Step 3: Create Trainable Classifier

> **⚠️ Critical Prerequisites**:
>
> 1. **Indexing**: Wait minimum 1 hour (2-3 hours recommended) since script completion
> 2. **Permissions**: **The account you use to sign into Purview MUST have SharePoint access to the folders** (Microsoft requirement)
>
> **Verify SharePoint Access First**:
>
> - Navigate directly to your SharePoint site in a browser.
> - Can you see the **Documents** library with the **FinancialReports_Positive** and **BusinessDocs_Negative** folders?
> - If NO: Grant your Purview admin account permissions to the SharePoint site (Site Settings → Site permissions → Add user with Read access).
> - If YES: Proceed to create classifier.

Navigate to [purview.microsoft.com](https://purview.microsoft.com)

**Sign in with the SAME account that has SharePoint site access**:

1. Navigate to **Data loss prevention** (left navigation)
2. Click **Classifiers**
3. Select the **Trainable classifiers** tab
4. Click **Create trainable classifier**

---

### Step 4: Configure Classifier and Select Samples

**Add positive examples**:

1. **Name**: `Financial Reports Classifier`.
2. **Description**: `Identifies financial reports including quarterly earnings, annual reports, and financial statements`.
3. **Choose site**: Select your SharePoint site (e.g., PurviewLab-RetentionTesting).
4. **Select folder**: Choose **FinancialReports_Positive**.
   - After selecting the Documents library, a folder picker should appear.
   - Select the **FinancialReports_Positive** folder containing your 100 training documents.
5. Click **Next**.

> 💡 These 100 reports teach the classifier what financial reports look like

**Add negative examples**:

1. **Choose site**: Same SharePoint site.
2. **Select folder**: Choose **BusinessDocs_Negative**.
3. Click **Next**.

> 💡 These 200 documents teach what financial reports are NOT

**Review and create**:

- Review settings (positive: 100 files, negative: 200 files).
- Click **Create trainable classifier**.

---

### Step 5: Monitor Automated Training

Classifier status: **In progress**

Navigate to **Data loss prevention** → **Data classification** → **Classifiers** → **Trainable classifiers**

> ⏱️ **Wait**: Up to 24 hours for automated ML training and testing (modern 2024-2025 workflow)

**What happens automatically**:

- Hour 0-12: ML model trains on samples.
- Hour 12-24: Model refinement and automated testing.
- Hour 24 (or less): Status changes to **Training is complete and items have been tested**.

**Notes**:

- Testing is fully automated (no manual review required).
- Cannot interrupt training.
- No incremental retraining (must delete and recreate if accuracy low).

---

### Step 6: Review Test Results and Publish

After training completes, status → **Training is complete and items have been tested**

Click classifier name to view details

**Automated Test Results**:

The system automatically tested the classifier and provides accuracy metrics:

- **Tested**: Number of items automatically tested.
- **Accuracy indicators**: System evaluation of classifier performance.
- **Status**: Ready for publication if accuracy is acceptable.

> 📊 Microsoft's automated testing validates the classifier is working correctly. For production use, monitor actual detection rates after deployment and recreate with more samples if needed.

**Publish classifier**:

1. Review test results.
2. Click **Publish for use**.
3. Status → **Ready to use**.

> ⏱️ Immediate - now available for DLP policies, retention labels, and sensitivity labels

**If accuracy concerns**:

- Delete classifier.
- Improve sample quality (ensure positive samples are consistent, negative samples are diverse).
- Increase sample count (200-500 positive, 400-1,500 negative).
- Recreate classifier with improved dataset.

---

## 🚀 Phase 3: DLP Policy Integration

### Step 7: Create DLP Policy

Navigate to **Data loss prevention** → **Policies**

1. Click **+ Create policy**.
2. Category: **Custom** → **Custom policy**.
3. Click **Next**.

**Policy Configuration**:

- **Name**: `Protect Financial Reports`.
- **Description**: `Prevents unauthorized sharing of financial reports`.
- Click **Next**.

**Locations**:

- Enable: **SharePoint sites**, **OneDrive accounts**.
- Disable others.
- Click **Next**.

**Policy Settings**:

- Select **Create or customize advanced DLP rules**.
- Click **Next**.

---

### Step 8: Configure DLP Rule

Click **+ Create rule**

**Rule Configuration**:

- **Name**: `Block External Sharing of Financial Reports`

**Conditions**:

- Click **+ Add condition** → **Content contains**.
- Click **Add** → **Trainable classifiers**.
- Select **Financial Reports Classifier**.
- Click **Add**.

**Actions**:

- Click **+ Add an action** → **Restrict access or encrypt**.
- Select **Block everyone**.

**User Notifications**:

- Enable **Show users a policy tip**.
- Message: `This document contains financial information and cannot be shared externally`.

Click **Save** → **Next**

**Policy Mode**:

- Select **Turn it on right away**.
- Click **Next** → **Submit**.

---

### Step 9: Test DLP Protection

Upload test document to SharePoint:

1. Navigate to SharePoint site with external sharing.
2. Upload financial report (or generate with script).
3. Attempt external share (click **Share** → enter external email).

**Expected Behavior**:

- Policy tip appears.
- Sharing blocked.
- Activity logged.

> ⏱️ Detection: 15 min - 24 hours for new content

---

## 📊 Phase 4: Validation and Reporting

### Step 10: Content Explorer Validation

Navigate to **Data classification** → **Content explorer**

1. Click **Trainable classifiers** (left nav).
2. Locate **Financial Reports Classifier**.
3. Click classifier name to view identified files.

**Expected**:

- Files from FinancialReports_Positive folder in Documents library.
- Other SharePoint files matching the financial reports pattern.

> ⏱️ Wait: 1-24 hours for sync

**Filtering**:

- Location (SharePoint site/OneDrive).
- Date modified.
- Owner.

**Export**:

- Click **Export** for CSV report.
- Use for compliance reporting.

---

### Step 11: Activity Explorer Monitoring

Navigate to **Data classification** → **Activity explorer**

**Apply Filters**:

- **Activities**: DLP policy matched.
- **Classifiers**: Financial Reports Classifier.
- **Date range**: Last 7 days.

**Expected Activities**:

- File uploads with classifier detection.
- Blocked share attempts.
- User notifications.

**Use Cases**:

- Compliance audits.
- User behavior analysis.
- Policy tuning (false positives).

---

### Step 12: Executive Summary Report

Export Activity Explorer data:

1. Navigate to **Activity explorer**.
2. Apply filters (DLP matched + classifier + 30 days).
3. Click **Export** and save the CSV file.

**Analyze Activity Explorer data**:

Navigate to the Custom-Classification scripts directory and run the analysis script:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Custom-Classification"
.\Analyze-ClassifierActivity.ps1
```

**What the script provides**:

- Total trainable classifier detections.
- Unique users triggering DLP policies.
- Blocked sharing attempts.
- Top 5 locations by activity volume.
- Activity timeline (last 7 days).

---

## ✅ Lab Validation Checklist

Confirm completion:

- [ ] Ran Setup-TrainableClassifierData.ps1 script (Step 1).
- [ ] Created FinancialReports_Positive and BusinessDocs_Negative folders in Documents library.
- [ ] Generated 100 positive samples (financial reports).
- [ ] Generated 200 negative samples (business documents).
- [ ] Waited 2-3 hours for SharePoint and Purview indexing (Step 2).
- [ ] Verified folders appear in SharePoint search.
- [ ] Created trainable classifier in Purview portal (Step 3).
- [ ] Configured classifier with positive and negative samples (Step 4).
- [ ] Waited 24 hours for automated ML training (Step 5).
- [ ] Reviewed automated test results (Step 6).
- [ ] Published classifier to "Ready to use" status (Step 6).
- [ ] Created DLP policy named "Protect Financial Reports" (Step 7).
- [ ] Configured DLP rule with trainable classifier condition (Step 8).
- [ ] Set DLP action to "Block everyone" (Step 8).
- [ ] Enabled policy tip for users (Step 8).
- [ ] Set policy mode to "Turn it on right away" (Step 8).
- [ ] Tested DLP protection (sharing blocked) (Step 9).
- [ ] Validated detections in Content Explorer (Step 10).
- [ ] Monitored activity in Activity Explorer (Step 11).
- [ ] Exported Activity Explorer data (Step 12).
- [ ] Ran Analyze-ClassifierActivity.ps1 for executive summary (Step 12).

---

## 📅 Complete Timeline

**Day 1 - Setup and Configuration**:

- **Hour 0-1**: Run Setup-TrainableClassifierData.ps1 (Step 1).
  - Creates folders in Documents library.
  - Generates 100 positive samples (financial reports).
  - Generates 200 negative samples (business documents).
- **Hour 1-3**: Wait for SharePoint search and Purview compliance indexing (Step 2).
  - Required: Minimum 1 hour, recommended 2-3 hours.
  - Verify folders appear in SharePoint search.
- **Hour 3-4**: Create and configure trainable classifier (Steps 3-4).
  - Create classifier in Purview portal.
  - Select Documents library and folders.
  - Configure positive samples (FinancialReports_Positive).
  - Configure negative samples (BusinessDocs_Negative).
  - Submit for automated ML training (Step 5 begins).

**Day 2 - Training Completion and DLP Deployment**:

- **Hour 24-25**: ML training completes automatically (Step 5 ends).
  - Review automated test results (Step 6).
  - Publish classifier to "Ready to use" status (Step 6).
- **Hour 25-26**: Create DLP policy (Steps 7-8).
  - Create "Protect Financial Reports" policy.
  - Configure rule with trainable classifier condition.
  - Set action to "Block everyone".
  - Enable policy tip for users.
  - Set policy mode to "Turn it on right away".
- **Hour 26-27**: Test DLP protection (Step 9).
  - Upload test financial document.
  - Attempt external sharing (should be blocked).
  - Verify policy tip appears.

**Day 3+ - Validation and Reporting**:

- **Hour 48-72**: Content Explorer and Activity Explorer sync (Steps 10-11).
  - Validate detections in Content Explorer (Step 10).
  - Monitor activity in Activity Explorer (Step 11).
  - Wait time: 1-24 hours for full sync.
- **Hour 72+**: Executive reporting (Step 12).
  - Export Activity Explorer data.
  - Run Analyze-ClassifierActivity.ps1.
  - Generate executive summary with metrics.

**Total Active Time**: 3-4 hours (spread across 3+ days)  
**Total Elapsed Time**: 72+ hours (includes 24-hour training + 48-hour sync)

---

## 🔧 Troubleshooting

### Low Classifier Accuracy or Poor Detection Rates

**Causes**:

- Inconsistent positive samples (too much variation in format/content).
- Negative samples too similar to positive samples.
- Insufficient sample quantity (below recommended minimums).
- Training data quality issues.

**Solutions**:

- Delete classifier and recreate with improved samples.
- Ensure all positive samples are genuine financial reports.
- Increase diversity in negative samples (different document types).
- Increase sample count: 200-500 positive, 400-1,500 negative (recommended).
- Review Step 6 automated test results before publishing.

---

### Content Explorer Empty

**Causes**:

- Sync delay (1-24 hours).
- No new content since publish.
- DLP not applied to locations.

**Solutions**:

- Wait 24 hours.
- Upload test documents.
- Verify DLP enabled for locations.

---

### DLP Not Blocking

**Causes**:

- Policy in test mode.
- Low classifier accuracy.
- Incorrect conditions.

**Solutions**:

- Change to "Turn it on right away".
- Review test results (may need retraining).
- Verify rule has trainable classifier condition.
- Test with known sample.

---

## 📚 Reference Documentation

**Microsoft Learn** (November 2025):

- [Get started with trainable classifiers](https://learn.microsoft.com/en-us/purview/trainable-classifiers-get-started-with)
- [Create custom trainable classifiers](https://learn.microsoft.com/en-us/purview/classifier-get-started-with)
- [Create and deploy DLP policies](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)
- [DLP policy conditions](https://learn.microsoft.com/en-us/purview/dlp-conditions-and-exceptions)
- [Content Explorer](https://learn.microsoft.com/en-us/purview/data-classification-content-explorer)
- [Activity Explorer](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)

---

## 🎓 Key Learning Outcomes

**Technical Skills**:

- ✅ Run PowerShell scripts to automate training data setup.
- ✅ Create folders in SharePoint Documents library.
- ✅ Generate training samples with PowerShell (300 documents).
- ✅ Understand SharePoint search and Purview compliance indexing.
- ✅ Create custom trainable classifiers in Purview portal.
- ✅ Configure positive and negative training samples.
- ✅ Monitor automated ML training (24-hour process).
- ✅ Review and interpret automated test results.
- ✅ Apply classifiers to DLP policies.
- ✅ Configure DLP rules with trainable classifier conditions.
- ✅ Test DLP protection and policy tips.
- ✅ Validate detections with Content Explorer.
- ✅ Monitor activity with Activity Explorer.
- ✅ Export and analyze Activity Explorer data.
- ✅ Generate executive summary reports with PowerShell.

**Business Skills**:

- ✅ Decide when to use trainable classifiers vs. custom SITs.
- ✅ Assess automated test results for production deployment.
- ✅ Create executive summary reports from Activity Explorer data.
- ✅ Identify retraining needs from detection patterns.
- ✅ Balance sample quality vs. quantity for optimal accuracy.

**Production Readiness**:

- ✅ Deploy with modern automated 24-hour ML training workflow.
- ✅ Monitor performance metrics via Content/Activity Explorer.
- ✅ Document classifier configuration for audits.
- ✅ Troubleshoot common classifier and DLP issues.
- ✅ Understand indexing requirements (2-3 hours for Purview).

---

## 🏆 Next Steps

Consider:

- Expand DLP to Teams chat and Exchange.
- Create additional classifiers (contracts, HR docs, legal agreements).
- Use for retention label auto-application.
- Integrate with sensitivity labels.
- Build PowerShell dashboards for monitoring.

---

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of trainable classifier creation, machine learning training, and Content Explorer validation while maintaining technical accuracy for custom classification scenarios.*
