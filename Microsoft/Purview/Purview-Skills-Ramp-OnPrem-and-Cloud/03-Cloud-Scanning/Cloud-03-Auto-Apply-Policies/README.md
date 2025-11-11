# Cloud-03: Auto-Apply Retention Policies

## 🎯 Lab Objectives

- Create auto-apply retention policies based on sensitive information types.
- Configure policy conditions for credit card and SSN detection.
- Understand simulation mode vs. automatic enforcement.
- Configure policy locations (SharePoint sites).
- Manage the up-to-7-day policy processing timeline.
- Test retention label application on sample documents.
- Validate auto-apply policy effectiveness.

## ⏱️ Estimated Duration

**Active Work**: 30-45 minutes  
**Wait Period**: Up to 7 days for policy processing and label application

> **⚠️ CRITICAL TIMING**: Auto-apply retention policies require **up to 7 days** to process and begin applying labels automatically. This is a Microsoft 365 service processing timeline, not a configuration issue.

## 📋 Prerequisites

- Cloud-01 completed (SharePoint site with sample documents).
- Cloud-02 completed (Retention label "Delete-After-3-Years" created).
- Sample files with credit card or SSN data uploaded to SharePoint.
- Retention label policy published and propagated (15-30 minutes from Cloud-02).
- Understanding of sensitive information types from OnPrem-02.

## 🤖 Auto-Apply Policies Overview

**What Are Auto-Apply Policies?**

Auto-apply retention policies automatically apply retention labels to content based on:

- **Sensitive information types**: Credit cards, SSNs, passport numbers, etc.
- **Keywords or phrases**: Specific terms or document titles
- **Metadata properties**: Document properties, created date, authors
- **Trainable classifiers**: Machine learning-based content detection

**Why Use Auto-Apply?**

- **Automation**: No manual label application required by users
- **Consistency**: Labels applied uniformly based on content analysis
- **Compliance**: Ensures regulatory requirements met automatically
- **Scale**: Handles thousands of documents without user intervention

**SharePoint Online Limitation**:

> **Important**: Auto-apply retention labels work in **SharePoint Online** and **OneDrive**, but **NOT on on-premises file shares** scanned by the Information Protection Scanner.

## ⏰ Understanding the Auto-Apply Processing Timeline

**Why the Wait?**

According to Microsoft's official documentation, auto-apply retention label policies can take **up to 7 days** for labels to be applied to content after policy creation.

**What Happens During Processing**:

Microsoft 365 processes auto-apply policies in the background:

1. **Day 0**: Policy created and submitted
2. **Days 1-7**: Microsoft 365 background processing:
   - Policy distributed to configured locations (SharePoint sites)
   - Content analyzed for sensitive information types (Credit Card Number, U.S. SSN)
   - Matching items identified based on classification groups and confidence levels
   - Retention labels automatically applied to matching content
3. **Day 7+**: Policy runs continuously on new and modified content

> **⏳ Microsoft 365 Service Timeline**: Auto-apply policies typically complete within 7 days, though some policies may process faster depending on content volume and tenant activity. If labels don't appear after 7 days, check policy status for errors.

**During This Lab**:

- Complete Cloud-03 configuration today (30-45 minutes).
- Proceed to Cloud-04 (eDiscovery - independent of auto-apply processing) and remaining labs.
- Return in 7 days to validate label application.
- Or check Reporting-01 (Activity Explorer) for early signs of processing during the wait period.

## 🚀 Lab Steps

### Step 1: Create Auto-Apply Policy for Retention Labels

Auto-apply policies automatically apply retention labels to content based on conditions like sensitive information types or keywords.

**Navigate to Label Policies:**

- Still in Purview Portal > **Records management** (or **Data lifecycle management**).
- Expand the **Policies** menu and then select **Label policies**.
- Click **Auto-apply a label** to start the wizard.

> **💡 Wizard Overview**: The Auto-apply wizard has 10 steps: Name, Choose info to label, Policy template selection (if applicable), Define classification groups and sensitive info types, Assign admin units, Scope type, Locations, Label selection, Mode, and Review/Finish. The exact flow varies based on condition type and template selections.

---

#### Wizard Step 1: Name Your Auto-Labeling Policy

- **Name**: `Auto-Delete-Old-Sensitive-Files`
- **Description**: `Automatically apply 3-year deletion label to files containing sensitive data`
- Click **Next**.

---

#### Wizard Step 2: Choose the Type of Content You Want to Apply This Label To

Select one of the available condition types:

- Apply label to content that contains sensitive info.
- Apply label to content that contains specific words or phrase, or properties.
- Apply label to content that matches a trainable classifier.
- Apply label to cloud attachments and links shared in Exchange, Teams, Viva Engage and Copilot.

For this lab, choose **Apply label to content that contains sensitive info**. Click **Next**.

---

#### Wizard Step 3: Choose Policy Template or Custom Policy (Conditional)

This step appears only if you selected "sensitive info types" in Step 2.

**Content that contains sensitive info:**

You'll see options to search or browse for pre-configured policy templates organized by regulation category (Financial, Medical and health, Privacy) or create a custom policy.

**For This Lab - Use Custom Policy:**

- Select **Custom** > **Custom policy**, This allows you to manually select specific sensitive info types (Credit Card, SSN).
- Click **Next**.

> **💡 Template vs. Custom**:
>
> - **Templates**: Pre-configured bundles of sensitive info types for specific regulations (e.g., "U.S. Financial Data" includes Credit Card, Bank Account, Tax ID)
> - **Custom policy**: Manually select specific sensitive info types for targeted control
> - Templates are useful for compliance with specific regulations; custom policies offer precision
>
>
> **Financial Templates:**
>
> - U.S. Financial Data: Credit Card Number, U.S. Bank Account Number, ABA Routing Number
> - GLBA (Gramm-Leach-Bliley Act)
> - PCI-DSS (Payment Card Industry Data Security Standard)
>
> **Privacy Templates:**
>
> - U.S. Personally Identifiable Information (PII) Data: SSN, Driver's License, Passport Number
> - GDPR (General Data Protection Regulation)
> - Australia Privacy Act
>
> **Medical and Health Templates:**
>
> - U.S. Health Insurance Act (HIPAA): Medical terms, drug names, patient identifiers
> - U.K. Medical Data

---

#### Wizard Step 4: Define Content That Contains Sensitive Info

After selecting **Custom policy**, you'll see the classification group configuration interface.

**Classification Groups Overview:**

This screen allows you to create one or more classification groups. Each group is a logical container for sensitive information types that work together to identify content.

**Options on This Screen:**

- **Use an existing classification group** - Select from previously created groups (if any exist).
- **Create group** - Create a new classification group with custom sensitive info types.

**For This Lab - Create a New Classification Group:**

Since no classification groups exist yet in your tenant, you'll create your first group.

**Create Group:**

- Click **Create group**.
- **Group name**: Enter a descriptive name such as `Financial and Identity Data`.
- **Group operator**: Select how multiple sensitive info types within this group should relate:
  - **Any of these** - Content matches if it contains ANY of the selected sensitive info types (OR logic).
  - **All of these** - Content matches only if it contains ALL of the selected sensitive info types (AND logic).

**For This Lab:**

- **Group name**: `Financial and Identity Data`.
- **Group operator**: Select **Any of these**.
  - This means files will be labeled if they contain Credit Card Number OR SSN.
  - More flexible for real-world scenarios where files may contain different types of sensitive data.

> **💡 Group Operator Guidance**:
>
> - **Any of these (OR)**: Best for broad coverage - labels content if it contains at least one sensitive info type. Recommended for most scenarios.
> - **All of these (AND)**: Strict matching - requires ALL sensitive info types to be present in the same file. Use when multiple data types together indicate higher sensitivity.
>
> **📚 Multiple Groups**: You can create multiple classification groups on this screen with different operators. The policy will then evaluate all groups together. For this lab, one group is sufficient.

**Add Sensitive Information Types to the Group:**

After configuring the group name and operator, you'll add specific sensitive information types to this group.

- Click **Add** (under the Sensitive info types section).
- In the **Add sensitive info types** flyout panel, search for and select:
  - **Credit Card Number**.
  - **U.S. Social Security Number (SSN)**.
- Click **Add** to confirm selections.

**Configure Confidence Level and Instance Count:**

After adding the sensitive info types, you'll see them listed with configuration options:

**For Credit Card Number:**

- **Confidence level**: Select **Medium confidence** (recommended for balance between accuracy and coverage).
  - Low confidence: More matches, higher false positives.
  - Medium confidence: Balanced approach (recommended).
  - High confidence: Fewer matches, higher accuracy.
- **Instance count**:
  - **From**: `1`.
  - **To**: `Any`.
  - This means the policy will match if 1 or more credit card numbers are detected.

**For U.S. Social Security Number (SSN):**

- **Confidence level**: Select **Medium confidence**.
- **Instance count**:
  - **From**: `1`.
  - **To**: `Any`.

> **💡 Confidence Level Guidance**: Higher confidence levels require more supporting evidence (keywords, formatting, context) around the detected pattern. Medium confidence provides a good balance for most scenarios. Start with medium and adjust based on simulation results.
>
> **📚 Instance Count**: This defines how many unique instances of the sensitive info type must be present. Setting "From: 1" means even a single occurrence will trigger the policy. Adjust based on your risk tolerance and data patterns.

**Review Classification Group:**

- Verify your group configuration:
  - **Group name**: Financial and Identity Data.
  - **Group operator**: Any of these.
  - **Sensitive info types**: Credit Card Number (Medium, 1-Any), U.S. Social Security Number (Medium, 1-Any).
- Click **Next** to continue.

> **💡 Lab Recommendation**: Using sensitive info types aligns with the remediation scenario from the consultancy project and enables targeted retention based on data classification.

---

#### Wizard Step 5: Assign Admin Units

- Keep the default: **Full directory**.
- Click **Next**.

> **📚 Administrative Units**: These allow scoping policies to specific organizational units. For this lab, we use the full directory to include all locations.

---

#### Wizard Step 6: Choose the Type of Retention Policy to Create (Scope)

Select policy scope type:

- **Static**: Policy applies to all specified locations or specific included/excluded locations.
- **Adaptive**: Policy uses dynamic queries to target users, groups, or sites (requires pre-configured adaptive scopes).

For this lab:

- Select **Static**.
- Click **Next**.

> **📚 Adaptive vs. Static Scopes**:
>
> - **Static scopes**: Fixed locations (all sites, specific sites, all users, specific users).
> - **Adaptive scopes**: Dynamic membership based on queries (e.g., all users in Finance department, all sites with specific tags).
> - Adaptive scopes require pre-configuration before policy creation.

---

#### Wizard Step 7: Choose Locations to Apply the Policy

**Select SharePoint Sites:**

- **Status**: Ensure **Exchange mailboxes** is **OFF** (not needed for this lab).
- **Status**: Turn **ON** for **SharePoint classic and communication sites**.
- **Status**: Ensure **OneDrive accounts** is **OFF** (not needed for this lab).
- **Status**: Ensure **Microsoft 365 Groups** is **OFF** (not needed for this lab).

**Configure SharePoint Sites:**

- Leave **SharePoint classic and communication sites** set to **All sites** (default).
- This will apply the policy to all current and future SharePoint sites in your tenant.
- The **Retention Testing** site from Cloud-01 will automatically be included.

> **💡 Lab Approach**: Using "All sites" simplifies the lab workflow and ensures the policy automatically applies to the **Retention Testing** site you created in Cloud-01. In production environments, you would typically scope policies to specific sites or use adaptive scopes for more targeted deployment.

---

#### Wizard Step 8: Choose a Label to Auto-Apply

- Click **+ Add label**.
- Select **Delete-After-3-Years** and click **Add**.
- Review label details:
  - **Retention settings**: 3 years keep + delete.
  - **Is record**: No.
  - **Is regulatory**: No.
- Click **Next**.

---

#### Wizard Step 9: Decide Whether to Test or Run Your Policy (Mode)

**Policy Mode Options:**

**Test the policy before running it** (Recommended):

- Preview which files would be labeled without actually applying labels.
- Simulation results typically appear within 1-2 days.
- Review results, refine policy, then turn on.
- Best for: Complex policies, testing conditions, gradual deployment.

**Turn on policy** (Immediate deployment):

- Labels will be applied automatically to matching content within up to 7 days.
- No simulation phase.
- Best for: Policies you've already tested or simple scenarios.

For this lab:

- Select **Test the policy before running it**.
- This allows you to see which files match without making changes.
- Click **Next**.

> **💡 Simulation Mode Benefits**:
>
> - **Safe testing**: See what would happen without making actual changes.
> - **Refinement**: Adjust sensitive info types, keywords, or locations based on results.
> - **Validation**: Confirm policy matches expected content before deployment.
> - **Gradual rollout**: Start with small scope, expand after validating.
>
> **⏳ Processing Time**: Simulation typically completes within 1-2 days depending on content volume. You'll receive an email notification when simulation completes.

---

#### Wizard Step 10: Review and Finish

**Review All Policy Settings:**

- **Policy name**: Auto-Delete-Old-Sensitive-Files.
- **Policy description**: Automatically apply 3-year deletion label to files containing sensitive data.
- **Info to label**: Apply label to content that contains sensitive info.
- **Locations to apply the policy**: SharePoint classic and communication sites (All Sites).
- **Label**: Delete-After-3-Years (3 years retention, delete automatically).
- **Mode**: Simulation mode.

**Submit Policy:**

- Verify all settings are correct.
- Click **Submit** to create the policy.
- Policy creation confirmation appears.
- Click **Done**.

**Policy Status:**

- Return to **Label policies** page and click **Refresh** to see the new policy.
- Your new policy appears with **Status**: **In simulation***.
- Click on the policy name to view details and processing status.

> **✅ Success Indicator**: Policy appears in Label policies list with "In simulation" status and begins processing within minutes. Simulation results typically available within 1-2 days.

---

### Step 6: Monitor Simulation Results (Optional but Recommended)

If you selected simulation mode, you can monitor the simulation progress and view results.

**Check Simulation Status:**

- Navigate to **Data lifecycle management** > **Label policies**.
- Locate your policy: **Auto-Delete-Old-Sensitive-Files**.
- **Status** column shows: **In simulation** (processing) or **Completed (in simulation)**.
- Click on the policy name to view details.

**View Simulation Results:**

After simulation completes (typically 1-2 days, depending on the amount of data to analyze):

> **💡 Simulation Timeline Note**: Microsoft Learn states simulation "typically completes within one or two days, depending on the amount of data to analyze." If using adaptive scopes, these "can take a few days to fully populate" before simulation even starts. You'll receive an email notification when simulation completes. Check the **Status** column - it should show "Completed (in simulation)" when ready to review.

- Click **View simulation** from the policy details pane.
- Review matching items:
  - **Number of items**: Count of files that match the conditions.
  - **Locations**: Distribution across SharePoint sites.
  - **File samples**: Preview of specific files that would be labeled.
- **Sample details**: Click on samples to see file names, locations, and why they matched.

**Refine Policy Based on Results:**

If simulation shows unexpected results:

- **Too many matches**: Adjust sensitive info types, increase confidence levels, or narrow locations.
- **Too few matches**: Verify test files contain valid SIT patterns, check confidence levels.
- **Wrong files matched**: Review sensitive info type configuration, add exclusions.
- Click **Edit policy** to make adjustments.
- Restart simulation to validate changes.

**Turn On Policy After Validation:**

Once simulation results meet expectations:

- Click **Turn on policy** from the policy details pane.
- Policy status changes to **On** (active).
- Labels will be applied automatically to matching content within 7 days.

---

### Step 7: Verify SharePoint Test Site and Files

Before testing the auto-apply policy, verify your SharePoint foundation from Cloud-01 is ready.

**Confirm SharePoint Site Exists (Created in Cloud-01):**

- Navigate to `https://[yourtenant].sharepoint.com/sites/RetentionTesting`.
- Verify you can access the site without errors.
- This is the site you created in **Cloud-01: SharePoint Foundation Setup**.

> **💡 Lab Note**: If you haven't completed Cloud-01 yet, go back and complete **[Cloud-01: SharePoint Foundation Setup](../Cloud-01-SharePoint-Foundation/README.md)** first. That lab walks through creating the SharePoint site, folder structure, and uploading sample files with sensitive data.

**Verify Sensitive Data Archive Folder:**

- In the **Retention Testing** site, click **Documents** from the left menu.
- Confirm the **Sensitive Data Archive** folder exists (created in Cloud-01).
- Open the folder to view contents.

**Confirm Sample Files with Sensitive Data:**

Verify the following files exist in the **Sensitive Data Archive** folder (uploaded in Cloud-01):

- ✅ **EmployeeSSNArchive.xlsx** - Contains sample SSN data (123-45-6789 format).
- ✅ **OldCreditCardTransactions.txt** - Contains sample credit card numbers (4532-1234-5678-9010 format).

**If Files Are Missing:**

If you need to add additional test files or recreate the sample files:

**Upload Additional Files (if needed):**

- Navigate to the **Sensitive Data Archive** folder.
- Click **Upload** > **Files**.
- Select the test files you created.
- Click **Open** to upload.

> **⚠️ Policy Scope**: The auto-apply policy you created in Steps 1-6 is configured for "All sites" in SharePoint. This means it will automatically scan the **Retention Testing** site (and all other SharePoint sites in your tenant) for content matching the sensitive information types (Credit Card Number, U.S. SSN). No additional site-specific configuration is needed.

---

## ✅ Validation Checklist

### Auto-Apply Policy Created (Complete Today)

- [ ] Policy name: "Auto-Delete-Old-Sensitive-Files".
- [ ] Auto-apply condition: Sensitive information types selected.
- [ ] Information types: Credit Card Number, U.S. Social Security Number.
- [ ] Retention label: "Delete-After-3-Years" (created in Cloud-02).
- [ ] Location: SharePoint sites (All sites).
- [ ] Policy status: "In simulation" or "On".

### Simulation Mode (Optional - If Selected in Step 1)

- [ ] Understand simulation mode shows estimated matches without applying labels.
- [ ] Simulation results may take 1-2 days to populate (depending on data volume).
- [ ] Simulation provides confidence before automatic enforcement.
- [ ] Can turn on policy after reviewing simulation results.

### Wait Period Awareness

- [ ] **Understand**: Policy requires up to 7 days to process and apply labels.
- [ ] **Planned**: Return date to validate (today + 7 days).
- [ ] **Alternative**: Can proceed to Cloud-04 and remaining labs while waiting.

### Return Validation (After Up to 7 Days) ⏳

Come back to verify these items after the processing period:

- [ ] Navigate to SharePoint Retention Testing site (created in Cloud-01).
- [ ] Open Documents library > Sensitive Data Archive folder.
- [ ] Select sample file with credit card/SSN data.
- [ ] View file details/properties.
- [ ] Check for retention label: "Delete-After-3-Years".
- [ ] Verify label applied automatically (not manually).
- [ ] Check Activity Explorer for label application events.

## 🔍 Troubleshooting

### Auto-apply policy not showing in list

**Symptoms**: Cannot find policy after creation

**Solutions**:

1. Wait 5-10 minutes for policy to appear.
2. Refresh browser page (Ctrl+F5).
3. Check correct location: Purview portal > Data lifecycle management > Label policies.
4. Verify publishing completed without errors.
5. Check audit log for policy creation event.

### Simulation mode stuck or no results

**Symptoms**: Simulation never completes or shows zero matches

**Solutions**:

1. **Wait longer**: Simulation typically takes 1-2 days but may take longer depending on data volume.
2. **Skip simulation**: Turn on the policy directly for immediate processing (still requires up to 7 days for label application).
3. **Check content**: Verify SharePoint files actually contain credit card/SSN patterns.
4. **Review information types**: Ensure correct sensitive info types selected.
5. **Location scope**: Confirm SharePoint site included in policy.

### Labels not applied after 7+ days

**Symptoms**: Wait period exceeded but no labels visible

**Solutions**:

1. **Verify policy status**: Check policy shows "On" in portal (not "Off (Error)").
2. **Check file content**: Open sample file and confirm credit card/SSN data present.
3. **Sensitive info type validation**: Test patterns match expected formats (16-digit credit cards, XXX-XX-XXXX SSNs).
4. **Location verification**: Confirm SharePoint site correctly specified in policy.
5. **Review Activity Explorer**: Data lifecycle events may show processing status.
6. **Check service health**: M365 Admin Center > Health > Service health.
7. **Retry policy distribution**: Use PowerShell `Set-RetentionCompliancePolicy -Identity <policy name> -RetryDistribution` command.
8. **Contact support**: If 7+ days with persistent errors, open M365 support case.

> **📚 Reference**: Microsoft Learn states that if labels don't appear after 7 days, check for errors and retry distribution using PowerShell. See [How long it takes for retention labels to take effect](https://learn.microsoft.com/en-us/purview/apply-retention-labels-automatically#how-long-it-takes-for-retention-labels-to-take-effect).

---

## 💡 Auto-Apply Policy Best Practices

**For Lab Environment**:

- Create policy today, proceed to other labs during wait period.
- Use simulation mode to build confidence (optional, adds wait time).
- Test with small file set (2-3 files) before expanding scope.
- Document policy creation date for validation planning.

**For Production Deployments**:

- **Always use simulation mode first** for organization-wide policies.
- Start with pilot SharePoint site before expanding to all sites.
- Communicate up-to-7-day processing timeline to stakeholders.
- Monitor Activity Explorer during initial processing period.
- Plan phased rollout across multiple SharePoint sites.

## ⏭️ Next Steps

### Option 1: Proceed to Next Labs (Recommended)

Auto-apply policy created! While waiting for processing:

- ✅ Auto-apply policy configured with sensitive information types.
- ✅ Policy published to SharePoint locations.
- ✅ Up-to-7-day processing timeline understood.
- ⏳ Policy processing in background.

**Proceed to [Cloud-04: SharePoint eDiscovery](../Cloud-04-SharePoint-eDiscovery/README.md)** to learn Content Search capabilities while waiting for auto-apply processing.

**Then continue**:

- Complete Cloud-04 (30-45 minutes).
- Complete Reporting-01, Reporting-02, Reporting-03 (3-4 hours).
- Complete Supplemental labs if desired (11-16 hours).
- **Return to this lab after up to 7 days** to validate retention label application.

### Option 2: Manual Label Testing (Immediate Alternative)

If you want to test retention labels today without waiting:

1. Navigate to SharePoint Retention Testing site > Documents.
2. Select a sample file with credit card/SSN data.
3. Click **Details** pane (i icon).
4. Find **Apply retention label** dropdown.
5. Select "Delete-After-3-Years".
6. Verify label appears in file properties.

This demonstrates label functionality immediately, while auto-apply processes in background.

## 📅 Validation Timeline

| Day | Activity | Expected Outcome |
|-----|----------|------------------|
| **Day 0 (Today)** | Create auto-apply policy | Policy published, status "On" or "In simulation" |
| **Days 1-7** | Microsoft 365 background processing | Policy distributed to locations, content analyzed for sensitive info types, labels applied to matching files |
| **Day 7 (Return)** | Validation | Verify labels applied automatically to credit card/SSN files |

> **📚 Microsoft Learn Reference**: According to [official Microsoft documentation](https://learn.microsoft.com/en-us/purview/apply-retention-labels-automatically#how-long-it-takes-for-retention-labels-to-take-effect), auto-apply retention labels can take **up to 7 days** to be applied to content.

## 📚 Reference Documentation

- [Auto-apply retention labels](https://learn.microsoft.com/en-us/purview/apply-retention-labels-automatically)
- [Auto-apply based on sensitive information](https://learn.microsoft.com/en-us/purview/apply-retention-labels-automatically#auto-apply-labels-to-content-with-specific-types-of-sensitive-information)
- [Simulation mode for auto-apply](https://learn.microsoft.com/en-us/purview/apply-retention-labels-automatically#learn-about-simulation-mode)
- [How long retention policies take to apply](https://learn.microsoft.com/en-us/purview/retention#how-long-it-takes-for-retention-policies-to-take-effect)

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of auto-apply retention policy configuration while maintaining technical accuracy for automated label deployment scenarios.*
