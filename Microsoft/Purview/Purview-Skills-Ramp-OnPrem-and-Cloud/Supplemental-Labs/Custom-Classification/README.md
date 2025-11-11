# Supplemental Lab: Trainable Classifiers for Financial Reports

> **⚠️ UNDER DEVELOPMENT**: This lab is currently in development and testing. The 24-hour ML training phase is in progress (initiated November 10, 2025). Lab will be validated and finalized after training completion and accuracy testing (~November 12, 2025).

Create machine learning-based classifiers to automatically identify financial reports in Microsoft Purview.

---

## 📋 Lab Summary

**Duration**: 3 hours active + 24-hour ML training

**Goal**: Train a custom classifier to detect financial reports, apply to DLP policies, and validate accuracy.

**Skills**: ML training, sample curation, DLP integration, accuracy validation

---

## 🎯 What You'll Learn

✅ Create SharePoint training libraries (positive/negative samples)  
✅ Generate 100 financial reports + 200 non-financial documents  
✅ Train trainable classifier (24-hour automated ML workflow)  
✅ Review test results (precision, recall, F1 score)  
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

| Scenario | Trainable Classifier | Custom SIT (Regex) |
|----------|---------------------|-------------------|
| **Content Type** | Unstructured documents | Structured patterns |
| **Examples** | Financial reports, contracts | Employee IDs, project codes |
| **Training Required** | Yes (24 hours) | No (immediate) |
| **Samples Needed** | 50-500 positive + 150-1,500 negative | Regex pattern only |
| **Accuracy** | 70-95% | High (exact match) |
| **Language** | English only | All languages |
| **Best For** | Variable document formats | Fixed data patterns |

**Use trainable classifiers when**:

- Documents have variable formats/structures.
- Pattern-based detection won't work.
- You have representative samples available.
- Content is in English.

---

## Phase 1: Training Sample Preparation

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
- Creates **Classifier_Training** library in SharePoint.
- Creates two folders within the library:
  - **FinancialReports_Positive** (for positive training samples).
  - **BusinessDocs_Negative** (for negative training samples).
- Generates and uploads 100 financial report documents to FinancialReports_Positive folder.
- Generates and uploads 200 business documents to BusinessDocs_Negative folder.

> 💡 **All-in-One Solution**: This single script performs complete setup - creates library structure and generates all 300 training documents automatically.

**Financial reports include**: Quarterly earnings, annual reports, budget forecasts, cash flow statements, balance sheets, and income statements

**Business documents include**: HR policies, project plans, meeting notes, marketing materials, technical specifications, and employee handbooks

---

### Step 2: Wait for SharePoint and Purview Indexing

> ⏱️ **Required Wait Time**: **Minimum 1 hour, recommended 2-3 hours** before creating classifier

**Microsoft's Official Guidance**: "If you create a new SharePoint site and folder for your seed data, allow at least an hour for that location to be indexed before creating the trainable classifier that uses that seed data." (Source: [Microsoft Learn - Trainable Classifiers](https://learn.microsoft.com/en-us/purview/trainable-classifiers-learn-about))

**Two indexing systems must complete**:

1. **SharePoint Search Indexing** (1+ hours) - Makes content searchable
2. **Purview Compliance Crawler** (1-2+ hours) - Makes folders visible in classifier picker

**Verify indexing complete** (REQUIRED before creating classifier):

1. Navigate to **Classifier_Training** library
2. Open **FinancialReports_Positive** folder - verify 100 items
3. Open **BusinessDocs_Negative** folder - verify 200 items
4. Use SharePoint search to test indexing:
   - Search for "revenue" (should find financial documents)
   - Search for "employee" (should find business documents)

> **⚠️ Critical**: If you attempt to create the classifier before indexing completes, the folders **will not appear** in the Purview folder picker. Wait the full recommended time (2-3 hours from script completion) to ensure both SharePoint search and Purview's compliance crawler have indexed the folders.

**How to confirm indexing for trainable classifiers**:

- SharePoint search returns results from both folders.
- Documents appear when searching for content-specific terms (e.g., "revenue", "balance sheet").
- Folder item counts match expected totals (100 in FinancialReports_Positive, 200 in BusinessDocs_Negative).
- **Most important**: Enough time has elapsed (2-3 hours minimum) for Purview's compliance crawler to discover the folders.

> 💡 **Why the Wait?**: Microsoft Purview's compliance crawler runs independently from SharePoint search indexing. Even if SharePoint search finds your files within 1 hour, Purview's classifier picker may need additional time (up to 2-3 hours total) to discover and make folders available for selection.

---

## 📝 Phase 2: Classifier Creation and Training

### Step 3: Create Trainable Classifier

> **⚠️ Critical Prerequisites**:
> 
> 1. **Indexing**: Wait minimum 1 hour (2-3 hours recommended) since script completion
> 2. **Permissions**: **The account you use to sign into Purview MUST have SharePoint access to the folders** (Microsoft requirement)
>
> **Verify SharePoint Access First**:
> - Navigate directly to your SharePoint site in a browser
> - Can you see the **Classifier_Training** library and both folders?
> - If NO: Grant your Purview admin account permissions to the SharePoint site (Site Settings → Site permissions → Add user with Read access)
> - If YES: Proceed to create classifier

Navigate to [purview.microsoft.com](https://purview.microsoft.com)

**Sign in with the SAME account that has SharePoint site access**

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
4. **Choose library**: Select **Classifier_Training**.
5. **Select folder**: Choose **FinancialReports_Positive**.
   - After selecting the library, a folder picker should appear.
   - Select the FinancialReports_Positive folder containing your 100 training documents.
6. Click **Next**.

> 💡 These 100 reports teach the classifier what financial reports look like

> **⚠️ Folder Picker Troubleshooting**: If the folder picker is empty after selecting your library:
> 
> **Workaround - Proceed with Site-Level Selection**:
> - If the folder picker doesn't populate after waiting 2-3 hours, you can proceed by selecting only the SharePoint site without selecting specific folders
> - The Purview wizard allows continuing without folder selection and will crawl all folders within the selected site
> - This approach has been validated to work successfully for trainable classifier creation
> 
> **Standard Troubleshooting** (if picker should work):
> - **Account Permissions**: Verify Purview account has Read access to SharePoint site/library/folders
> - **Insufficient Wait Time**: Purview compliance crawler needs 1-2+ hours minimum (sometimes up to 48-72 hours)
> - **SharePoint Indexing**: Test by searching for "revenue" in library - if no results, indexing incomplete
> - **Account Consistency**: Use same account for PowerShell script authentication AND Purview portal login

**Add negative examples**:

1. **Choose site**: Same SharePoint site.
2. **Choose library**: **Classifier_Training**.
3. **Select folder**: Choose **BusinessDocs_Negative**.
4. Click **Next**.

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

## � Phase 3: DLP Policy Integration

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

## � Phase 4: Validation and Reporting

### Step 10: Content Explorer Validation

Navigate to **Data classification** → **Content explorer**

1. Click **Trainable classifiers** (left nav).
2. Locate **Financial Reports Classifier**.
3. Click classifier name to view identified files.

**Expected**:

- Files from Financial_Reports_Positive library.
- Other SharePoint files matching pattern.

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

### Step 15: Activity Explorer Monitoring

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

### Step 16: Executive Summary Report

Export Activity Explorer data:

1. Navigate to **Activity explorer**.
2. Apply filters (DLP matched + classifier + 30 days).
3. Click **Export**.

**Analyze with PowerShell**:

```powershell
$activities = Import-Csv "C:\Path\To\Export.csv"

# Total detections
Write-Host "Total: $($activities.Count)"

# Unique users
$users = ($activities | Select-Object -Unique User).Count
Write-Host "Users: $users"

# Blocked shares
$blocked = ($activities | Where-Object {$_.Action -eq "Blocked"}).Count
Write-Host "Blocked: $blocked"

# Top locations
$activities | Group-Object Location | 
    Sort-Object Count -Descending | 
    Select-Object -First 5 | 
    Format-Table -AutoSize
```

---

## ✅ Lab Validation Checklist

Confirm completion:

- [ ] Created Financial_Reports_Positive and Financial_Reports_Negative libraries.
- [ ] Generated 100 positive samples (financial reports).
- [ ] Generated 200 negative samples (business documents).
- [ ] Waited 1 hour for SharePoint indexing.
- [ ] Created trainable classifier.
- [ ] Waited 24 hours for ML training.
- [ ] Reviewed test results (>70% accuracy).
- [ ] Published classifier (Ready to use).
- [ ] Created DLP policy with classifier.
- [ ] Tested DLP protection (sharing blocked).
- [ ] Validated in Content Explorer.
- [ ] Monitored in Activity Explorer.
- [ ] Exported data for executive report.

---

## 📅 Complete Timeline

**Day 1**:

- Hour 0-1: Create libraries + generate samples.
- Hour 1: Wait for indexing.
- Hour 2: Create classifier + start training.

**Day 2**:

- Hour 24: Training complete.
- Hour 25: Review results + publish.
- Hour 26: Create DLP policy.
- Hour 27: Test policy.

**Day 3** (if needed):

- Hour 48-72: Content Explorer sync.
- Export + create reports.

**Total**: 3-4 hours active + 24hr training + 1-24hr sync

---

## 🔧 Troubleshooting

### Low Accuracy (<70%)

**Causes**:

- Inconsistent positive samples.
- Negative too similar to positive.
- Insufficient quantity.

**Solutions**:

- Delete and recreate.
- Ensure positive all financial reports.
- Increase diversity in negatives.
- Increase count (200 positive, 400 negative).

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

- ✅ Create SharePoint training libraries.
- ✅ Generate training samples with PowerShell.
- ✅ Train custom ML classifiers.
- ✅ Interpret ML metrics (precision, recall, F1).
- ✅ Apply classifiers to DLP policies.
- ✅ Validate with Content/Activity Explorer.

**Business Skills**:

- ✅ Decide when to use trainable classifiers vs. custom SITs.
- ✅ Assess accuracy for production deployment.
- ✅ Create executive summary reports.
- ✅ Identify retraining needs from false positives.

**Production Readiness**:

- ✅ Deploy with modern 24-hour training.
- ✅ Monitor performance metrics.
- ✅ Document accuracy for audits.
- ✅ Troubleshoot common issues.

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
