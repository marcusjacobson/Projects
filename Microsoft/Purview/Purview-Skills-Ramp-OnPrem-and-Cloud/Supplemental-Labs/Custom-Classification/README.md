# Supplemental Lab: Trainable Classifiers for Financial Reports

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

## � Critical Training Requirements (Updated November 2025)

**Microsoft's Official Guidance**:

> "You need at least 50 positive samples (up to 500) and at least 150 negative samples (up to 1,500) to train a classifier. **The more samples you provide, the more accurate the predictions the classifier makes will be.**"
>
> **Best Practice**: "For best results, have at least **200 items** in your test sample set that includes at least **50 positive examples** and at least **150 negative examples**."

**Recommended Training Dataset Sizes**:

| Configuration | Positive Samples | Negative Samples | Expected Accuracy | Use Case |
|--------------|-----------------|------------------|-------------------|----------|
| **Minimum Viable** | 50 | 150 | 40-60% | Testing only, NOT production |
| **Recommended** | **200-300** | **400-500** | **70-90%** | **Production deployment** |
| **Optimal** | 400-500 | 800-1,500 | 85-95% | Maximum accuracy |

---

## �📚 Prerequisites

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

## 📂 Phase 1: Training Sample Preparation (UPDATED - Enhanced Dataset)

> **⚠️ Critical Change**: The setup script now generates **300 positive** and **500 negative samples** based on Microsoft's recommended best practices for production deployment.

### Step 1: Run Enhanced Training Data Setup

Navigate to the Custom-Classification scripts directory and run the comprehensive setup script:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Custom-Classification"

# BEFORE RUNNING: Ensure script is configured for enhanced dataset
# $positiveCount = 300  # Increased from 100
# $negativeCount = 500  # Increased from 200

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
- **Generates and uploads 100 SEC-style financial report documents** to FinancialReports_Positive folder (ENHANCED with regulatory compliance language).
- **Generates and uploads 200 business documents** to BusinessDocs_Negative folder (DIVERSE non-financial content).

> 💡 **All-in-One Solution**: This single script performs complete setup - creates folder structure in the root Documents library and generates all training documents automatically.
>
> **⚠️ Critical Requirement**: The training data folders **MUST be in the root Documents library** of your SharePoint site for Purview's trainable classifier to recognize them. Creating a custom library or nested folder structure will prevent the folders from appearing in the Purview folder picker.

> **🎯 CRITICAL - Sample Specificity Requirements**:
>
> **Microsoft's Explicit Guidance**: "one set contains only items that **strongly represent** the content the classifier is designed to detect" and "Try to be **as specific as possible with your positive set**"
>
> **Enhanced Financial Reports Now Include**:
>
> - **SEC Filing Headers**: Form 10-Q, 10-K, 8-K regulatory designations
> - **Securities Exchange Act References**: Compliance language unique to financial reports
> - **Three Complete Financial Statements**: Consolidated Statements of Operations, Balance Sheets, Cash Flow Statements
> - **Management's Discussion and Analysis (MD&A)**: Required SEC Item 2 narrative
> - **Sarbanes-Oxley Certifications**: CEO attestations and regulatory compliance statements
> - **GAAP and FASB References**: Professional accounting standards citations
> - **Commission File Numbers and IRS Employer IDs**: Regulatory identifiers
> - **Professional Accounting Terminology**: EPS, diluted shares, operating cash flow, AOCI, etc.
>
> **Why This Matters**: The enhanced SEC-style reports **"strongly represent"** actual financial reports with unique regulatory and compliance language that never appears in generic business documents, providing the classifier with distinctive patterns for accurate detection.

**Business documents include**: HR policies, project plans, meeting notes, marketing materials, technical specifications, employee handbooks, legal documents, and operations procedures

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
2. Open **FinancialReports_Positive** folder - verify **300 items** (UPDATED).
3. Open **BusinessDocs_Negative** folder - verify **500 items** (UPDATED).
4. Use SharePoint search to test indexing:
   - Search for "revenue" (should find financial documents).
   - Search for "employee" (should find business documents).
5. Confirm folder item counts match expected totals (300/500).
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

1. **Name**: `Financial Reports Classifier v2` (or delete v1 if recreating).
2. **Description**: `Identifies SEC-style regulatory financial reports including 10-Q, 10-K, and 8-K filings with GAAP-compliant financial statements (enhanced training dataset: 300 positive / 500 negative samples)`.
3. **Choose site**: Select your SharePoint site (e.g., PurviewLab-RetentionTesting).
4. **Select folder**: Choose **FinancialReports_Positive**.
   - After selecting the Documents library, a folder picker should appear.
   - Select the **FinancialReports_Positive** folder containing your **300 training documents** (UPDATED).
5. Click **Next**.

> 💡 These **300 reports** provide robust pattern recognition for machine learning

**Add negative examples**:

1. **Choose site**: Same SharePoint site.
2. **Select folder**: Choose **BusinessDocs_Negative**.
3. Click **Next**.

> 💡 These **500 documents** teach what financial reports are NOT with maximum diversity

**Review and create**:

- Review settings (positive: **~300 files**, negative: **~500 files**) - UPDATED.
- Click **Create trainable classifier**.

---

### Step 5: Monitor Automated Training

Classifier status: **In progress**

Navigate to **Data loss prevention** → **Data classification** → **Classifiers** → **Trainable classifiers**

> ⏱️ **Wait**: Up to 24 hours for automated ML training and testing (modern 2024-2025 workflow)

**What happens automatically**:

- Hour 0-12: ML model trains on **300 positive + 500 negative samples** (enhanced dataset).
- Hour 12-24: Model refinement and automated testing.
- Hour 24 (or less): Status changes to **Ready to publish**.

> **Expected Outcome with Enhanced Dataset**: 70-90%+ accuracy

**Notes**:

- Testing is fully automated (no manual review required).
- Cannot interrupt training.
- No incremental retraining (must delete and recreate if accuracy low).

---

### Step 6: Review Test Results and Publish

After training completes, status → **Ready to publish**

Click classifier name to view details

**Automated Test Results**:

The system automatically tested the classifier and provides accuracy metrics:

- **Tested**: Number of items automatically tested.
- **Accuracy indicators**: System evaluation of classifier performance.
- **Status**: Ready for publication if accuracy is acceptable.

> 📊 Microsoft's automated testing validates the classifier is working correctly. **With enhanced dataset (300/500), expect 70-90%+ accuracy**.

**Accuracy Evaluation Guidelines**:

| Test Accuracy | Action | Recommendation |
|--------------|--------|----------------|
| **70-95%** | ✅ Publish immediately | Production-ready classifier |
| **50-70%** | ⚠️ Review false positives/negatives | Consider increasing to 400/800 samples |
| **Below 50%** | ❌ Delete and recreate | Improve sample quality, increase to 500/1,500 |

---

### Step 7: Publish Classifier for Production Use

After training completes and you've reviewed the automated test results:

**Verify Classifier is Ready**:

1. Navigate to **Data loss prevention** → **Classifiers**.
2. Select the **Trainable classifiers** tab.
3. Locate **Financial Reports Classifier**.
4. Status should show **Ready to publish**.

**Publish Classifier**:

1. Click the classifier name to open details.
2. Review the test results one final time:
   - **Expected with 300/500 samples**: 70-90%+ accuracy.
   - **Minimum acceptable**: 70% for production deployment.
   - **Below 70%**: Consider deleting and recreating with more samples.
3. Click **Publish for use**.
4. Confirmation dialog appears - click **Yes** to confirm.

**Verify Publication**:

1. Status changes to **Ready to use**.
2. The classifier is now available for:
   - DLP policies
   - Retention labels
   - Sensitivity labels
   - Auto-labeling policies

> ⏱️ **Availability**: Immediate - classifier can now be selected in policy configurations

> 💡 **Important**: Once published, the classifier cannot be unpublished. If accuracy is insufficient, you must delete the classifier and create a new one with improved training samples.

---

## 🚀 Phase 3: DLP Policy Integration

### Step 8: Create DLP Policy

Sign in to [Microsoft Purview portal](https://purview.microsoft.com)

Navigate to **Data loss prevention** → **Policies**

**Start Policy Creation**:

1. Click **+ Create policy**.

**Choose what type of data to protect**:

1. Select **Data stored in connected sources** (default for SharePoint, OneDrive, Exchange, Teams).
2. Click **Next**.

**Choose a template**:

1. In the **Categories** list, select **Custom**.
2. In the **Regulations** list, select **Custom policy**.
3. Click **Next**.

**Name and Description**:

- **Name**: `Protect Financial Reports`
- **Description**: `Prevents unauthorized sharing of SEC-style financial reports using trainable classifier detection`
- Click **Next**.

**Admin Units**:

- Accept the **Full directory** default (applies policy to all users).
- Click **Next**.

**Locations** (Choose where to apply the policy):

- Select **SharePoint sites** (toggle to **On**).
- Select **OneDrive accounts** (toggle to **On**).
- Leave all other locations **Off** (Exchange, Teams, Devices, etc.).
- Click **Next**.

> 💡 **Production Tip**: Start with SharePoint and OneDrive to protect stored documents. Expand to Exchange and Teams later if needed.

**Policy Settings**:

- Select **Create or customize advanced DLP rules**.
- Click **Next**.

---

### Step 9: Configure Advanced DLP Rule

**Create Rule**:

1. Click **+ Create rule**.
2. **Name**: `Block External Sharing of Financial Reports`
3. **Description**: `Blocks external sharing when trainable classifier detects SEC-style financial reports`

**Conditions** (What to detect):

1. Under **Conditions**, click **+ Add condition**.
2. Select **Content contains**.
3. Click **Add** dropdown → **Trainable classifiers**.
4. In the classifier picker, select **Financial Reports Classifier** (the one you published).
5. Click **Add**.

> ✅ The rule now triggers when content matches your custom trainable classifier

**Actions** (What to do when detected):

1. Under **Actions**, click **+ Add an action**.
2. Select **Restrict access or encrypt the content in Microsoft 365 locations**.
3. Choose **Block users from receiving email or accessing shared SharePoint, OneDrive, and Teams files**.
4. Select **Block only people outside your organization** (allows internal sharing).

> 💡 **Alternative**: Select **Block everyone** to prevent all sharing (more restrictive)

**User Notifications** (Educate users):

1. Toggle **User notifications** to **On**.
2. Select **Notify users in Office 365 service with a policy tip**.
3. Check **Policy tips**.
4. In the **Customize the policy tip text** box, enter:

   ```text
   This document contains SEC-style financial information and cannot be shared externally. Contact compliance@yourorg.com with questions.
   ```

5. Check **Show the policy tip as a dialog for the end user before send** (for email).

**User Overrides** (Optional - not recommended for financial data):

- Leave **Allow overrides from M365 services** unchecked (prevent bypassing).

**Incident Reports** (Alert admins):

1. Under **Incident reports**, toggle to **On**.
2. Select **Send an alert to admins when a rule match occurs**.
3. Choose **Send alert every time an activity matches the rule** (for immediate notification).
4. In **Send the alert to these people**, add admin email addresses.

**Additional Options**:

- **Evaluate rule per component**: Leave unchecked (default evaluates entire document as single unit).
- **Priority**: Leave at default value (rules evaluated in order created).

> 💡 **Note**: Priority determines rule evaluation order when multiple rules exist in the policy. Lower numbers = higher priority.

**Save Rule**:

1. Click **Save** (returns to policy settings page).
2. Verify your rule appears in the rules list.
3. Click **Next**.

---

### Step 10: Policy Mode and Deployment

**Policy Mode** (Critical deployment decision):

Microsoft recommends phased deployment:

**Phase 1 - Simulation Mode** (Recommended start):

- Select **Run the policy in simulation mode**.
- Optional: Check **Show policy tips while in simulation mode** (educate users without blocking).
- Click **Next**.

> 💡 **Best Practice**: Run in simulation for 7-14 days to:
>
> - Validate detection accuracy
> - Identify false positives
> - Educate users with policy tips
> - Gather activity data in Activity Explorer

**Phase 2 - Full Enforcement** (After validation):

- Select **Turn it on right away** (enforces blocking).
- Click **Next**.

> ⚠️ **Production Deployment**: Only enable enforcement after simulation confirms accuracy and user readiness

**Alternative - Keep Off**:

- Select **Keep it off** (for final review before deployment).

**Review and Submit**:

1. Review all policy settings:
   - Name: Protect Financial Reports
   - Locations: SharePoint sites, OneDrive accounts
   - Rule: Block External Sharing of Financial Reports
   - Condition: Financial Reports Classifier
   - Action: Block external sharing
   - Notifications: Policy tips enabled
2. Click **Submit**.
3. Click **Done**.

**Policy Status**:

- Status shows **In simulation mode** (if Phase 1) or **On** (if Phase 2).
- Policy takes effect within 1 hour.

---

### Step 11: Test DLP Protection

**Simulation Mode Testing** (if running in simulation):

1. Navigate to SharePoint site.
2. Upload a financial report from the training set (or generate with script).
3. Attempt external share:
   - Click **Share** on the document.
   - Enter external email address (e.g., `external@gmail.com`).
   - Click **Send**.

**Expected Behavior in Simulation**:

- ✅ Sharing completes (not blocked in simulation mode).
- ✅ Policy tip appears if enabled.
- ✅ Activity logged in Activity Explorer.
- ✅ Admin alert sent (if configured).

**Full Enforcement Testing** (if policy turned on):

1. Upload financial report to SharePoint.
2. Attempt external share.

**Expected Behavior in Enforcement**:

- ❌ Sharing blocked with error message.
- ✅ Policy tip displays: "This document contains SEC-style financial information...".
- ✅ Activity logged in Activity Explorer.
- ✅ Admin alert sent immediately.

> ⏱️ **Detection Time**: 15 minutes - 24 hours for new content (depends on indexing and classification sync)

---

## 📊 Phase 4: Validation and Reporting

### Step 12: Content Explorer Validation

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

### Step 13: Activity Explorer Monitoring

Navigate to **Data classification** → **Activity explorer**

**Apply Filters**:

- **Activities**: DLP policy matched.
- **Classifiers**: Financial Reports Classifier.
- **Date range**: Last 7 days.

**Expected Activities**:

- File uploads with classifier detection.
- Blocked share attempts (if policy in enforcement mode).
- Policy tip notifications.
- User override attempts (if allowed).

**Use Cases**:

- Compliance audits and reporting.
- User behavior analysis.
- Policy tuning (identify false positives/negatives).
- Security incident investigation.

---

### Step 14: Executive Summary Report

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
- [ ] Published classifier to "Ready to use" status (Step 7).
- [ ] Created DLP policy named "Protect Financial Reports" (Step 8).
- [ ] Configured advanced DLP rule with trainable classifier condition (Step 9).
- [ ] Set DLP action to block external sharing (Step 9).
- [ ] Enabled policy tips for user education (Step 9).
- [ ] Configured incident reports and admin alerts (Step 9).
- [ ] Set policy mode (simulation or enforcement) (Step 10).
- [ ] Tested DLP protection in appropriate mode (Step 11).
- [ ] Validated detections in Content Explorer (Step 12).
- [ ] Monitored activity in Activity Explorer (Step 13).
- [ ] Exported Activity Explorer data (Step 14).
- [ ] Ran Analyze-ClassifierActivity.ps1 for executive summary (Step 14).

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

**Common Causes**:

- **Insufficient training data quantity**: Minimum 300 positive / 500 negative samples recommended for production.
- **Poor sample quality**: Positive samples must "strongly represent" the target content type.
- **Insufficient sample diversity**: Negative samples should cover wide range of non-target content.

**Solutions**:

- ✅ **Use recommended dataset sizes**: **300 positive / 500 negative samples minimum** for production deployment.
- ✅ Delete classifier and recreate with larger dataset if current accuracy below 70%.
- ✅ Ensure all positive samples are genuine financial reports with consistent regulatory language.
- ✅ Maximize negative sample diversity (HR, marketing, technical, legal, operations documents).
- ✅ Review automated test results carefully - **70%+ accuracy required for production**.
- ✅ If still failing with 300/500, consider maximum: 500 positive / 1,500 negative samples.

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

- [Get started with trainable classifiers](https://learn.microsoft.com/en-us/purview/trainable-classifiers-get-started-with) - Official guidance on sample requirements (50-500 positive, 150-1,500 negative).
- [Learn about trainable classifiers](https://learn.microsoft.com/en-us/purview/trainable-classifiers-learn-about) - Process flow and retraining requirements.
- [Increase classifier accuracy](https://learn.microsoft.com/en-us/purview/data-classification-increase-accuracy) - Tuning classifiers and using feedback.
- [Create and deploy DLP policies](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy) - DLP policy integration.
- [DLP policy conditions](https://learn.microsoft.com/en-us/purview/dlp-conditions-and-exceptions) - Using trainable classifiers in DLP rules.
- [Content Explorer](https://learn.microsoft.com/en-us/purview/data-classification-content-explorer) - Validating classifier detections.
- [Activity Explorer](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer) - Monitoring classifier activity.

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
