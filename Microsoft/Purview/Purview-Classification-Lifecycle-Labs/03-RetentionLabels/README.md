# Lab 3: Retention Labels and Lifecycle Management

## 📋 Lab Overview

This lab focuses on **Microsoft Purview retention labels** and data lifecycle management. You'll learn how to create, configure, and apply retention labels to classified content, implementing automated retention policies that ensure compliance with organizational data governance requirements.

**Key Learning Objectives:**

- Understand retention label fundamentals and lifecycle management concepts
- Create retention labels with different retention periods and actions
- Configure retention label policies for automatic application
- Apply retention labels based on custom SIT classifications
- Validate retention behavior in SharePoint Online and Microsoft 365
- Monitor retention label deployment and effectiveness
- Implement event-based retention for advanced scenarios

**Time Investment:** 90-120 minutes

**Prerequisites:**

- Completed Lab 1 (On-Demand Classification) and Lab 2 (Custom SITs)
- Custom SITs created in Lab 2 (regex or EDM-based)
- SharePoint Online test site with classified content
- Microsoft Purview Compliance Portal access
- Security & Compliance PowerShell connection
- Exchange Online Management module v3.4.0+
- Microsoft.Purview module v2.1.0

---

## 🎯 Lab Objectives

By completing this lab, you will:

1. **Understand Retention Concepts**: Learn retention periods, disposition actions, and lifecycle stages
2. **Create Retention Labels**: Build labels for different data types with appropriate retention settings
3. **Configure Auto-Apply Policies**: Automate label application based on custom SIT detection
4. **Validate Retention Behavior**: Verify labels apply correctly and enforce retention rules
5. **Monitor Retention Metrics**: Track label adoption and compliance coverage
6. **Handle Disposition Review**: Manage end-of-lifecycle disposition workflows

---

## 📚 Retention Label Fundamentals

### What Are Retention Labels?

Retention labels define **how long content should be kept** and **what happens when the retention period expires**. They implement organizational records management and compliance requirements.

**Core Concepts:**

- **Retention Period**: Duration content must be kept (e.g., 3 years, 7 years)
- **Retention Start**: When retention clock begins (creation date, modification date, labeled date, event-based)
- **Disposition Action**: What happens after retention expires (delete automatically, require review, permanent retention)
- **Record Declaration**: Convert content to immutable records with restricted editing
- **Regulatory Records**: Strictest protection level - cannot be deleted even by admins

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

### Phase 1: Retention Label Creation

#### Step 1: Create Core Retention Labels

- Financial Records (7 years retention)
- HR Documents (5 years retention)
- General Business (3 years retention)
- Temporary Content (1 year retention)

#### Step 2: Create Record Labels

- Legal Hold (permanent retention)
- Regulatory Compliance (10 years, regulatory record)

### Phase 2: Auto-Apply Policy Configuration

#### Step 3: Configure Auto-Apply Policies

- Link retention labels to custom SITs from Lab 2
- Define policy scope (SharePoint sites, OneDrive, Exchange)
- Set policy priorities and conflict resolution

#### Step 4: Deploy Auto-Apply Policies

- Publish policies to Microsoft 365
- Monitor policy simulation results
- Activate policies for production labeling

### Phase 3: Validation and Monitoring

#### Step 5: Validate Retention Behavior

- Verify labels applied to classified content
- Test disposition actions (keep, delete, review)
- Validate record immutability

#### Step 6: Monitor Retention Metrics

- Track label adoption across content types
- Measure compliance coverage percentages
- Identify unlabeled sensitive content

### Phase 4: Event-Based Retention (Optional)

#### Step 7: Configure Event-Based Retention

- Create retention events (employee termination, contract expiration)
- Link labels to event types
- Trigger retention start based on business events

---

## 📝 Lab Exercises

### Exercise 1: Create Standard Retention Labels

**Objective**: Create retention labels for common business scenarios with different retention periods.

**Labels to Create:**

1. **Financial Records - 7 Years**
   - Retention: 7 years from creation date
   - Action: Delete automatically after 7 years
   - Scope: SharePoint, OneDrive, Exchange
   - Use Case: Invoices, financial statements, tax documents

2. **HR Documents - 5 Years**
   - Retention: 5 years from labeled date
   - Action: Require disposition review after 5 years
   - Scope: SharePoint, OneDrive
   - Use Case: Employee performance reviews, training records

3. **General Business - 3 Years**
   - Retention: 3 years from modification date
   - Action: Delete automatically after 3 years
   - Scope: SharePoint, OneDrive, Exchange
   - Use Case: Project documentation, meeting notes

4. **Temporary Content - 1 Year**
   - Retention: 1 year from creation date
   - Action: Delete automatically after 1 year
   - Scope: SharePoint, OneDrive, Teams
   - Use Case: Draft documents, working files

**PowerShell Script**: `Create-RetentionLabels.ps1`

**Expected Results:**

- 4 retention labels created in Purview Compliance Portal
- Each label configured with appropriate retention settings
- Labels visible in Data lifecycle management section
- Replication time: 5-10 minutes across Microsoft 365

### Exercise 2: Create Record Retention Labels

**Objective**: Create record labels for legal and regulatory compliance requiring immutability.

**Labels to Create:**

1. **Legal Hold - Permanent**
   - Retention: Permanent (no deletion)
   - Record Type: Standard record
   - Action: Keep forever, no deletion allowed
   - Use Case: Litigation documents, legal proceedings

2. **Regulatory Compliance - 10 Years**
   - Retention: 10 years from creation date
   - Record Type: Regulatory record
   - Action: Delete automatically after 10 years
   - Immutability: Cannot be deleted by anyone before expiration
   - Use Case: SEC filings, FDA submissions, compliance records

**PowerShell Script**: `Create-RecordLabels.ps1`

**Expected Results:**

- 2 record labels created with immutability settings
- Labels enforce record restrictions upon application
- Content labeled as records cannot be deleted
- Regulatory records have strictest protection

### Exercise 3: Configure Auto-Apply Policies for Custom SITs

**Objective**: Automatically apply retention labels based on custom SIT detection from Lab 2.

**Policies to Create:**

1. **Auto-Apply: Financial Records**
   - Trigger: "Contoso Purchase Order Number" SIT detected
   - Label: Financial Records - 7 Years
   - Scope: SharePoint sites, OneDrive accounts
   - Simulation: 7 days before production deployment

2. **Auto-Apply: Employee Records**
   - Trigger: "Contoso Employee Record (EDM)" SIT detected
   - Label: HR Documents - 5 Years
   - Scope: SharePoint sites, OneDrive accounts
   - Priority: High (applied before conflicting policies)

3. **Auto-Apply: Customer Data**
   - Trigger: "Contoso Customer Number" SIT detected
   - Label: General Business - 3 Years
   - Scope: SharePoint sites, Exchange mailboxes
   - Conditions: High confidence matches only (85%+)

**PowerShell Script**: `Create-AutoApplyPolicies.ps1`

**Expected Results:**

- 3 auto-apply policies created and published
- Policies enter simulation mode for 7 days
- Simulation results show estimated label applications
- Policies activate automatically after simulation period

### Exercise 4: Validate Retention Label Application

**Objective**: Verify retention labels apply correctly to content containing custom SITs.

**Validation Steps:**

1. **Upload Test Documents**: Upload files containing SIT patterns from Lab 2
2. **Run Classification**: Execute on-demand classification scan
3. **Wait for Policy Processing**: Allow 24-48 hours for auto-apply policies
4. **Verify Labels**: Check document properties show retention labels
5. **Test Disposition**: Attempt to delete labeled content (should be blocked during retention)

**PowerShell Script**: `Validate-RetentionLabels.ps1`

**Expected Results:**

- Documents containing SITs automatically receive retention labels
- Label metadata visible in SharePoint document properties
- Retention period countdown displayed in UI
- Disposition actions enforced (cannot delete during retention)

### Exercise 5: Monitor Retention Metrics and Coverage

**Objective**: Track retention label adoption and identify unlabeled sensitive content.

**Metrics to Monitor:**

1. **Label Adoption Rate**
   - Total items labeled vs total items scanned
   - Percentage coverage by SIT type
   - Growth trends over time

2. **Unlabeled Sensitive Content**
   - Items containing SITs without retention labels
   - High-risk content requiring immediate attention
   - Policy gaps requiring configuration updates

3. **Policy Effectiveness**
   - Auto-apply success rate
   - Manual vs automatic label application
   - Policy conflicts and resolution

**PowerShell Script**: `Monitor-RetentionMetrics.ps1`

**Expected Results:**

- Dashboard showing label adoption percentages
- List of unlabeled sensitive content items
- CSV export with detailed retention metrics
- Recommendations for policy improvements

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
- Wait 24-48 hours for initial policy processing
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
- Wait 24 hours for event processing

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
- Auto-apply policy processing: 24-48 hours initial, then real-time
- Label replication: 5-10 minutes across Microsoft 365
- Disposition review: 30 days after retention expires

**Policy Processing:**

- Simulation mode: 7 days default
- Production labeling: Continuous after simulation
- Classification scan: 2-4 hours for 10,000 documents
- Event-based triggers: 24 hours processing time

---

## ⏭️ Next Steps

After completing Lab 3, you will have:

- ✅ Retention labels configured for common business scenarios
- ✅ Auto-apply policies linking labels to custom SIT detection
- ✅ Validated retention behavior and disposition enforcement
- ✅ Established retention metrics monitoring

**Continue to Lab 4: PowerShell Automation** to learn:

- Bulk retention label operations
- Scheduled retention policy updates
- Automated disposition review workflows
- Advanced scripting patterns for Purview administration

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

This comprehensive Lab 3 retention labels guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview retention management best practices, lifecycle management workflows, and enterprise records management standards.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Purview retention labels while maintaining technical accuracy and reflecting data lifecycle management best practices for compliance and governance scenarios.*
