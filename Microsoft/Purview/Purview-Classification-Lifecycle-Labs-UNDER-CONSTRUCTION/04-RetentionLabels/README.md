# Lab 4: Retention Labels & Auto-Apply Policies

## 📋 Lab Overview

This lab focuses on **enhancing retention labels** created in Lab 0 and configuring **auto-apply policies** that automatically apply retention labels based on custom SIT detection from Labs 1-2. You'll learn advanced retention label configuration, policy-driven automation, and flexible timing approaches that accommodate both accelerated learning and production deployment timelines.

**Key Learning Objectives:**

- Enhance initial retention labels from Lab 0 with advanced configuration.
- Configure auto-apply policies linking retention labels to custom SITs from Labs 1-2.
- Understand simulation mode (1-2 days) vs production mode (7+ days) timing flexibility.
- Work with retention label policies regardless of activation timeline.
- Monitor retention label adoption and compliance coverage.
- Implement event-based retention for advanced scenarios.

**Time Investment:** 45-60 minutes active work

**Timing Flexibility:**

- ✅ **Accelerated Path (2-3 days since Lab 0)**: Work in simulation mode, complete learning objectives
- ✅ **Production Path (7+ days since Lab 0)**: See fully activated retention labels in production
- ✅ **Both paths provide complete retention label lifecycle understanding!**

**Prerequisites:**

- ✅ Completed Lab 0 (initial retention labels created in Exercise 4)
- ✅ Completed Lab 1 (custom regex-based SITs created)
- ✅ Completed Lab 2 (EDM-based SIT created)
- ✅ Completed Lab 3 (classification validation with Content Explorer)
- SharePoint Online test site with classified content from Lab 0
- Microsoft Purview Compliance Portal access
- Security & Compliance PowerShell connection
- Exchange Online Management module v3.4.0+

---

## 🎯 Lab Objectives

By completing this lab, you will:

1. **Review Initial Labels from Lab 0**: Understand placeholder retention labels created in Lab 0 Exercise 4
2. **Enhance Retention Labels**: Add advanced configuration to initial labels with custom SIT triggers
3. **Configure Auto-Apply Policies**: Automate label application based on custom SIT detection from Labs 1-2
4. **Understand Timing Flexibility**: Work with simulation mode OR production mode based on elapsed time
5. **Validate Retention Behavior**: Verify labels apply correctly and enforce retention rules (simulation or production)
6. **Monitor Retention Metrics**: Track label adoption and compliance coverage regardless of activation state

---

## 📚 Retention Label Fundamentals

### What Are Retention Labels?

Retention labels define **how long content should be kept** and **what happens when the retention period expires**. They implement organizational records management and compliance requirements. In Lab 0 Exercise 4, you created **initial placeholder retention labels** that are now enhanced in this lab with custom SIT triggers.

**Core Concepts:**

- **Retention Period**: Duration content must be kept (e.g., 3 years, 7 years)
- **Retention Start**: When retention clock begins (creation date, modification date, labeled date, event-based)
- **Disposition Action**: What happens after retention expires (delete automatically, require review, permanent retention)
- **Record Declaration**: Convert content to immutable records with restricted editing
- **Regulatory Records**: Strictest protection level - cannot be deleted even by admins
- **Auto-Apply Policies**: Automatically apply labels based on SIT detection (configured in this lab)

### Initial Labels from Lab 0

In **Lab 0 Exercise 4**, you created three initial retention labels:

1. **Contoso Financial Records - 7 Years**
   - Retention: 7 years from creation date
   - Action: Delete automatically after 7 years
   - Created as placeholder in Lab 0, enhanced in this lab

2. **Contoso HR Documents - 5 Years**
   - Retention: 5 years from labeled date
   - Action: Require disposition review after 5 years
   - Created as placeholder in Lab 0, enhanced in this lab

3. **Contoso General Business - 3 Years**
   - Retention: 3 years from modification date
   - Action: Delete automatically after 3 years
   - Created as placeholder in Lab 0, enhanced in this lab

**What's Different in This Lab:**

- **Lab 0**: Created labels with basic retention settings, no auto-apply policies
- **Lab 4**: Enhance labels with auto-apply policies linked to custom SITs from Labs 1-2

### Retention Label Activation Timing

> **⏱️ Understanding Retention Label Timing**: Retention labels go through two phases:
>
> **Phase 1 - Simulation Mode (1-2 days after creation)**:
> - Auto-apply policies show **estimated** label applications
> - Labels are **not yet applied** to content
> - You can review simulation results and adjust policies
> - Complete learning experience available in simulation mode
>
> **Phase 2 - Production Mode (7+ days after creation)**:
> - Auto-apply policies **actively apply** labels to content
> - Labels appear on documents in SharePoint and OneDrive
> - Retention periods enforced and visible to users
> - Full production deployment realized
>
> **Both modes provide complete learning!** This lab adapts to whichever phase you're in based on time elapsed since Lab 0.

### Retention Label Types

**Standard Retention Labels:**

- Keep content for specified period, then allow deletion
- Users can still edit content during retention
- Example: "Retain 3 Years Then Delete"

**Record Labels:**

- Content becomes immutable upon labeling
- Editing restricted, deletion prevented during retention
- Example: "Legal Hold - Permanent"

**Regulatory Record Labels:**

- Strictest protection - cannot be deleted by anyone
- Metadata changes only (title, description)
- Example: "Regulatory Compliance - 7 Years"

### Retention vs Deletion Policies

| Feature | Retention Labels | Deletion Policies |
|---------|------------------|-------------------|
| Scope | Item-level (file, email, document) | Container-level (site, mailbox, Teams) |
| User Control | Users can apply/change labels | Automatic, no user control |
| Flexibility | Different labels for different items | Same policy for entire location |
| Disposition | Multiple actions (keep, delete, review) | Delete only |
| Records | Can declare records | Cannot declare records |
| Use Case | Compliance, records management | Storage optimization, cleanup |

---

## 🔄 Lab Workflow Overview

### Phase 1: Review Initial Retention Labels from Lab 0

#### Exercise 1: Verify Initial Retention Labels

- Review retention labels created in Lab 0 Exercise 4
- Verify labels are published and available in Purview portal
- Check replication status across Microsoft 365
- Understand current activation state (simulation vs production)

### Phase 2: Configure Auto-Apply Policies

#### Exercise 2: Create Auto-Apply Policies for Custom SITs

- Link Lab 0 retention labels to custom SITs from Labs 1-2
- Configure policy scope (SharePoint sites, OneDrive, Exchange)
- Set policy priorities and conflict resolution
- Understand simulation period and production activation

### Phase 3: Flexible Timing - Simulation or Production Mode

#### Exercise 3A: Work with Simulation Mode (1-3 days since Lab 0)

- Review simulation results showing estimated label applications
- Analyze which content would receive labels in production
- Understand auto-apply policy logic and SIT triggers
- Complete full learning objectives without waiting for production

#### Exercise 3B: Work with Production Mode (7+ days since Lab 0)

- Validate labels actively applied to content
- Verify retention periods displayed on documents
- Test disposition actions and retention enforcement
- See complete production deployment lifecycle

### Phase 4: Monitoring and Validation

#### Exercise 4: Monitor Retention Metrics

- Track label adoption across content types (simulation or production)
- Measure compliance coverage percentages
- Identify unlabeled sensitive content
- Generate executive-level compliance reports

---

## 📝 Lab Exercises

### Exercise 1: Verify Initial Retention Labels from Lab 0

**Objective**: Confirm retention labels created in Lab 0 Exercise 4 are active and ready for enhancement.

**Labels to Verify (Created in Lab 0):**

1. **Contoso Financial Records - 7 Years**
   - Retention: 7 years from creation date
   - Action: Delete automatically after 7 years
   - Scope: SharePoint, OneDrive, Exchange

2. **Contoso HR Documents - 5 Years**
   - Retention: 5 years from labeled date
   - Action: Require disposition review after 5 years
   - Scope: SharePoint, OneDrive

3. **Contoso General Business - 3 Years**
   - Retention: 3 years from modification date
   - Action: Delete automatically after 3 years
   - Scope: SharePoint, OneDrive, Exchange

**Verification Steps:**

Navigate to Microsoft Purview Compliance Portal.

- Go to [Microsoft Purview Portal](https://compliance.microsoft.com).
- Navigate to **Records management** → **File plan**.
- Verify all three retention labels from Lab 0 are listed.
- Click each label to view details (retention settings, scope, disposition action).

Check replication status.

- Labels should show "Published" status (not "Draft").
- Verify labels are available across Microsoft 365 (replication takes 5-10 minutes from Lab 0).
- Check label visibility in SharePoint document library (manual application available).

**PowerShell Verification**: `Verify-RetentionLabelsFromLab0.ps1`

```powershell
# List all retention labels created in Lab 0
Get-ComplianceTag | Where-Object {$_.Name -like "Contoso*"} |
    Select-Object Name, RetentionDuration, RetentionAction, IsRecordLabel |
    Format-Table -AutoSize
```

**Expected Results:**

- 3 retention labels from Lab 0 visible in Purview portal
- Labels show correct retention periods and disposition actions
- Labels are published and available for policy configuration
- No auto-apply policies configured yet (configured in Exercise 2)

---

### Exercise 2: Configure Auto-Apply Policies for Custom SITs

**Objective**: Create auto-apply policies that automatically assign Lab 0 retention labels based on custom SIT detection from Labs 1-2.

**Policies to Create (Linking Lab 0 Labels to Labs 1-2 Custom SITs):**

1. **Auto-Apply: Financial Records → Purchase Order SIT**
   - Retention Label: Contoso Financial Records - 7 Years (from Lab 0)
   - Trigger: "Purchase Order Custom SIT" (created in Lab 1)
   - Scope: SharePoint sites, OneDrive accounts
   - Confidence: High (85%+) for precise matching
   - Simulation: Enters simulation mode upon creation

2. **Auto-Apply: HR Documents → Employee Database EDM SIT**
   - Retention Label: Contoso HR Documents - 5 Years (from Lab 0)
   - Trigger: "Employee Database EDM SIT" (created in Lab 2)
   - Scope: SharePoint sites, OneDrive accounts
   - Confidence: High (99% exact matches from EDM)
   - Priority: High (applied before conflicting policies)

3. **Auto-Apply: General Business → Customer Number SIT**
   - Retention Label: Contoso General Business - 3 Years (from Lab 0)
   - Trigger: "Customer Number Custom SIT" (created in Lab 1)
   - Scope: SharePoint sites, Exchange mailboxes
   - Confidence: Medium (75%+) for broader coverage
   - Conditions: Documents not already labeled with higher retention

**PowerShell Script**: `Create-AutoApplyPolicies.ps1`

**Expected Results:**

- 3 auto-apply policies created and published
- Policies link Lab 0 retention labels to Labs 1-2 custom SITs
- Policies enter simulation mode automatically (1-2 day completion period)
- Simulation results show estimated label applications
- **Timing Note**: Policies activate for production labeling up to 7 days after creation

---

### Exercise 3: Work with Simulation Mode or Production Mode

**Objective**: Understand and work with retention label policies regardless of activation timeline.

This exercise has two paths depending on time elapsed since Lab 0:

#### Path A: Simulation Mode (1-3 Days Since Lab 0)

**If you're completing labs in accelerated timeframe**, auto-apply policies are in simulation mode showing estimated label applications.

**Simulation Mode Validation Steps:**

Review simulation results.

- Navigate to **Data lifecycle management** → **Auto-apply** in Purview portal.
- Click each auto-apply policy name to view details.
- Review **Simulation results** section showing:
  - **Estimated documents to label**: Count of documents that would receive labels
  - **SIT detections**: Which custom SITs triggered label application
  - **Confidence levels**: Distribution across High/Medium/Low matches

Analyze simulation insights.

- Verify simulation detects content with Lab 1 regex SITs (Project ID, Customer Number, Purchase Order).
- Verify simulation detects content with Lab 2 EDM SIT (Employee Database exact matches).
- Check for policy conflicts (multiple labels matching same document).
- Review estimated timeline for production activation (up to 7 days from Lab 0).

**Learning Outcome - Simulation Mode**:

> **✅ Complete Learning Experience**: Simulation mode provides full understanding of auto-apply policy logic, SIT triggers, and estimated coverage WITHOUT waiting for production activation. You understand retention label lifecycle completely!

#### Path B: Production Mode (7+ Days Since Lab 0)

**If you're completing labs with production deployment timeline**, auto-apply policies are actively applying labels to content.

**Production Mode Validation Steps:**

Verify labels applied to content.

- Navigate to SharePoint test site from Lab 0.
- Open **Documents** library and select a file containing custom SIT patterns.
- View document properties (information panel on right side).
- Verify **Retention label** field shows applied label name.
- Check **Retention period** countdown displayed.

Test disposition enforcement.

- Attempt to delete a document with retention label applied.
- Verify deletion is blocked with message: "This item is under retention and cannot be deleted".
- Check document edit restrictions (records are immutable, standard labels allow editing).

Validate SIT-based label application.

- Review documents in Finance folder → Should have "Contoso Financial Records - 7 Years" label (Purchase Order SIT detected).
- Review documents in HR folder → Should have "Contoso HR Documents - 5 Years" label (Employee EDM SIT detected).
- Review documents in Projects folder → Should have "Contoso General Business - 3 Years" label (Customer Number SIT detected).

**Learning Outcome - Production Mode**:

> **✅ Production Deployment Complete**: You've seen the full retention label lifecycle from creation (Lab 0) through auto-apply policy configuration (Lab 4) to active production deployment. Enterprise-ready retention management!

**PowerShell Validation Script**: `Validate-RetentionPolicyMode.ps1`

```powershell
# Check if policies are in simulation or production mode
Get-RetentionCompliancePolicy -DistributionDetail | 
    Where-Object {$_.Name -like "*Auto-Apply*"} |
    Select-Object Name, Mode, @{Name="DaysActive";Expression={(Get-Date) - $_.WhenCreated | Select-Object -ExpandProperty Days}} |
    Format-Table -AutoSize
```

**Expected Results (Both Paths):**

- **Simulation Mode**: Understand complete policy logic and estimated coverage
- **Production Mode**: See active label application and retention enforcement
- **Both**: Complete retention label lifecycle understanding achieved!

### Exercise 4: Validate Retention Label Application

**Objective**: Verify retention labels apply correctly to content containing custom SITs.

**Validation Steps:**

1. **Upload Test Documents**: Upload files containing SIT patterns from Lab 2
2. **Run Classification**: Execute on-demand classification scan
3. **Wait for Policy Processing**: Allow up to 7 days for auto-apply policies
4. **Verify Labels**: Check document properties show retention labels
5. **Test Disposition**: Attempt to delete labeled content (should be blocked during retention)

**PowerShell Script**: `Validate-RetentionLabels.ps1`

**Expected Results:**

- Documents containing SITs automatically receive retention labels
- Label metadata visible in SharePoint document properties
- Retention period countdown displayed in UI
- Disposition actions enforced (cannot delete during retention)

### Exercise 4: Monitor Retention Metrics and Coverage

**Objective**: Track retention label adoption and identify coverage gaps (works in both simulation and production modes).

**Metrics to Monitor:**

1. **Label Adoption Rate (Simulation or Production)**
   - **Simulation Mode**: Estimated items to be labeled vs total items scanned
   - **Production Mode**: Actual items labeled vs total items scanned
   - Percentage coverage by SIT type (Lab 1 regex SITs vs Lab 2 EDM SIT)
   - Growth trends over time

2. **Unlabeled Sensitive Content**
   - Items containing custom SITs from Labs 1-2 without retention labels
   - High-risk content requiring immediate attention
   - Policy gaps requiring configuration updates

3. **Policy Effectiveness**
   - Auto-apply success rate (simulation estimates or production actuals)
   - SIT detection accuracy from Labs 1-2 validation
   - Policy conflicts and resolution via priority settings

**PowerShell Script**: `Monitor-RetentionMetrics.ps1`

**Expected Results (Both Modes):**

- Dashboard showing label adoption percentages (estimated or actual)
- List of unlabeled sensitive content items requiring attention
- CSV export with detailed retention metrics for reporting
- Recommendations for policy improvements and coverage gaps

### Exercise 6: Event-Based Retention Configuration (Optional)

**Objective**: Configure retention labels that start retention based on business events rather than fixed dates.

**Event Types to Create:**

1. **Employee Termination**
   - Trigger: HR system notification of employee separation
   - Label: HR Documents - 5 Years (starts on termination date)
   - Use Case: Employee files, access logs, performance reviews

2. **Contract Expiration**
   - Trigger: Contract end date reached
   - Label: Financial Records - 7 Years (starts on expiration date)
   - Use Case: Vendor contracts, service agreements

**PowerShell Script**: `Create-EventBasedRetention.ps1`

**Expected Results:**

- Event types registered in Purview
- Event-based retention labels created
- Business events trigger retention clock start
- Content retained based on actual business milestones

---

## 🛠️ PowerShell Scripts

### Script 1: Create-RetentionLabels.ps1

**Purpose**: Creates standard retention labels for common business scenarios.

**Parameters:**

- `-LabelPrefix`: Prefix for label names (default: "Contoso")
- `-PublishImmediately`: Publish labels immediately after creation (default: $true)

**Labels Created:**

- Financial Records - 7 Years
- HR Documents - 5 Years
- General Business - 3 Years
- Temporary Content - 1 Year

**Execution Time**: 2-3 minutes

### Script 2: Create-RecordLabels.ps1

**Purpose**: Creates record labels with immutability settings for legal and regulatory compliance.

**Parameters:**

- `-LabelPrefix`: Prefix for label names (default: "Contoso")
- `-EnableRegulatoryRecords`: Enable regulatory record creation (default: $true)

**Labels Created:**

- Legal Hold - Permanent
- Regulatory Compliance - 10 Years

**Execution Time**: 2-3 minutes

### Script 3: Create-AutoApplyPolicies.ps1

**Purpose**: Configures auto-apply policies linking retention labels to custom SITs from Lab 2.

**Parameters:**

- `-SimulationMode`: Enable 7-day simulation before production (default: $true)
- `-SITNames`: Array of custom SIT names to use (default: Lab 2 SITs)
- `-Scope`: Policy scope locations (default: SharePoint, OneDrive)

**Policies Created:**

- Auto-Apply: Financial Records (Purchase Order SIT)
- Auto-Apply: Employee Records (Employee EDM SIT)
- Auto-Apply: Customer Data (Customer Number SIT)

**Execution Time**: 5-7 minutes

### Script 4: Validate-RetentionLabels.ps1

**Purpose**: Validates retention labels applied correctly to content with comprehensive testing.

**Parameters:**

- `-SharePointSiteUrl`: SharePoint site URL to validate
- `-DetailedReport`: Enable verbose validation output (default: $false)
- `-ExportPath`: CSV export path for validation results

**Validation Checks:**

- Label presence on classified content
- Correct label assignment based on SIT detection
- Disposition action enforcement
- Record immutability verification

**Execution Time**: 5-10 minutes (depends on content volume)

### Script 5: Monitor-RetentionMetrics.ps1

**Purpose**: Monitors retention label adoption metrics and identifies coverage gaps.

**Parameters:**

- `-SharePointSiteUrl`: SharePoint site URL to monitor
- `-ReportingPeriod`: Days to include in metrics (default: 30)
- `-ExportPath`: CSV export path for metrics

**Metrics Generated:**

- Label adoption rate by SIT type
- Unlabeled sensitive content count
- Policy effectiveness scores
- Coverage gap recommendations

**Execution Time**: 10-15 minutes (depends on content volume)

### Script 6: Create-EventBasedRetention.ps1 (Optional)

**Purpose**: Configures event-based retention for business milestone-driven retention.

**Parameters:**

- `-EventTypes`: Array of event type names to create
- `-LabelPrefix`: Prefix for event-based label names

**Components Created:**

- Event types (Employee Termination, Contract Expiration)
- Event-based retention labels
- Event trigger configurations

**Execution Time**: 3-5 minutes

---

## ✅ Validation Checklist

After completing Lab 3, verify the following:

### Retention Label Creation

- [ ] **Standard labels created**: Financial Records, HR Documents, General Business, Temporary Content
- [ ] **Record labels created**: Legal Hold, Regulatory Compliance
- [ ] **Label settings configured**: Retention periods, disposition actions, scope
- [ ] **Labels published**: Visible in Purview Compliance Portal
- [ ] **Replication complete**: Labels available across Microsoft 365 (5-10 minutes)

### Auto-Apply Policy Configuration

- [ ] **Policies created**: Financial Records, Employee Records, Customer Data
- [ ] **SIT triggers configured**: Linked to Lab 2 custom SITs
- [ ] **Scope defined**: SharePoint, OneDrive, Exchange as appropriate
- [ ] **Simulation active**: 7-day simulation period started
- [ ] **Simulation results reviewed**: Estimated label applications analyzed

### Validation and Testing

- [ ] **Test content uploaded**: Files containing SIT patterns from Lab 2
- [ ] **Classification executed**: On-demand scan completed
- [ ] **Labels applied**: Auto-apply policies labeled content correctly
- [ ] **Disposition enforced**: Cannot delete content during retention period
- [ ] **Record immutability**: Record-labeled content restricted from editing

### Monitoring and Metrics

- [ ] **Adoption metrics collected**: Label coverage percentages calculated
- [ ] **Unlabeled content identified**: Sensitive items without labels listed
- [ ] **Policy effectiveness measured**: Success rates and conflicts analyzed
- [ ] **Recommendations generated**: Policy improvements identified

---

## 🔍 Troubleshooting

### Common Issues and Solutions

**Issue**: Retention labels not visible after creation

**Solution:**

- Wait 5-10 minutes for replication across Microsoft 365
- Verify Security & Compliance PowerShell connection
- Check label publication status: `Get-ComplianceTag -Identity "LabelName"`
- Republish labels if needed: `Set-ComplianceTag -Identity "LabelName" -Force`

**Issue**: Auto-apply policies not labeling content

**Solution:**

- Verify policy is active (not in simulation mode): `Get-RetentionCompliancePolicy`
- Check SIT names match exactly (case-sensitive)
- Wait up to 7 days for initial policy processing
- Run on-demand classification: `Start-ScanForSensitiveInformation`
- Verify content contains SITs at required confidence level (85%+)

**Issue**: Cannot delete content after label application

**Solution:**

- This is expected behavior during retention period
- Verify retention period has not expired
- Check disposition action (if "Delete automatically", cannot manual delete)
- For records, immutability is enforced until retention expires
- Use disposition review workflow for managed deletion

**Issue**: Policy conflicts - multiple labels match same content

**Solution:**

- Review policy priorities: Higher number = higher priority
- Check policy conditions and refine SIT triggers
- Use label priority settings to resolve conflicts automatically
- Most restrictive label wins by default (longest retention)

**Issue**: Event-based retention not starting

**Solution:**

- Verify event type created: `Get-RetentionEvent`
- Check event trigger date is in the past
- Confirm label linked to event type
- Trigger event manually: `New-RetentionEvent`
- Wait up to 7 days for event processing

---

## 📊 Expected Results

### Label Adoption Metrics

After completing Lab 3 and allowing 48 hours for policy processing:

**Standard Labels:**

- Financial Records: 80-90% adoption on Purchase Order documents
- HR Documents: 70-80% adoption on Employee EDM matches
- General Business: 60-70% adoption on Customer Number documents
- Temporary Content: Manual application only (on-demand)

**Record Labels:**

- Legal Hold: Manual application only (as needed)
- Regulatory Compliance: Policy-driven or manual application

**Overall Coverage:**

- Sensitive content labeled: 75-85% (auto-apply policies)
- Unlabeled sensitive content: 15-25% (requiring manual review)
- Policy conflicts: < 5% (resolved by priority)

### Performance Benchmarks

**Label Application Time:**

- Manual label application: Immediate (< 1 second)
- Auto-apply policy processing: Up to 7 days for initial application
- Label replication: 5-10 minutes across Microsoft 365
- Disposition review: 30 days after retention expires

**Policy Processing:**

- Simulation mode: 1-2 days completion
- Production labeling: Continuous after simulation
- Classification scan: 2-4 hours for 10,000 documents
- Event-based triggers: Up to 7 days synchronization time

---

## ⏭️ Next Steps

After completing Lab 4, you will have:

- ✅ Enhanced retention labels from Lab 0 with auto-apply policies
- ✅ Auto-apply policies linking labels to custom SITs from Labs 1-2
- ✅ Understanding of simulation mode and production mode timing flexibility
- ✅ Validated retention behavior (simulation insights or production enforcement)
- ✅ Established retention metrics monitoring capability

**Continue to [Lab 5: PowerShell Automation & Scaling](../05-PowerShellAutomation/README.md)** to learn:

- Bulk retention label operations across multiple sites
- Scheduled retention policy updates and maintenance
- Automated compliance content searches using KQL syntax
- Advanced scripting patterns for enterprise-scale Purview administration
- Executive-level compliance reporting and metrics generation

Lab 5 builds on retention label management from Lab 4, introducing enterprise automation workflows for scaling Purview operations across large Microsoft 365 tenants.

---

## 📚 Additional Resources

### Microsoft Learn Documentation

- [Retention labels overview](https://learn.microsoft.com/en-us/purview/retention)
- [Auto-apply retention labels](https://learn.microsoft.com/en-us/purview/apply-retention-labels-automatically)
- [Records management in Purview](https://learn.microsoft.com/en-us/purview/records-management)
- [Event-based retention](https://learn.microsoft.com/en-us/purview/event-driven-retention)
- [Disposition of content](https://learn.microsoft.com/en-us/purview/disposition)

### PowerShell Cmdlet Reference

- `New-ComplianceTag`: Create retention labels
- `New-RetentionCompliancePolicy`: Create auto-apply policies
- `New-RetentionComplianceRule`: Configure policy rules
- `Get-ComplianceTag`: Retrieve label details
- `Get-RetentionCompliancePolicy`: View policy status
- `Start-ScanForSensitiveInformation`: Trigger on-demand classification

### Community Resources

- [Microsoft Tech Community - Purview](https://techcommunity.microsoft.com/t5/security-compliance-and-identity/bd-p/MicrosoftSecurityandCompliance)
- [Purview Blog](https://techcommunity.microsoft.com/t5/security-compliance-and-identity/bg-p/SecurityandComplianceBlog)
- [Purview YouTube Channel](https://www.youtube.com/c/MicrosoftSecurity)

---

## 🤖 AI-Assisted Content Generation

This comprehensive Lab 4 retention labels and auto-apply policies guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview retention management best practices, timing flexibility for both accelerated learning and production deployment, and lifecycle management workflows validated against current Microsoft Learn documentation as of November 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Purview retention labels and auto-apply policies while maintaining technical accuracy and reflecting data lifecycle management best practices for compliance and governance scenarios with optimized lab sequencing.*
