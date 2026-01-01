# Lab 01: Activity Explorer Validation

## 🎯 Objectives

By the end of this lab, you will:

- Navigate and use **Activity Explorer** to analyze user actions and policy enforcement
- Validate **DLP policy matches** across Exchange, SharePoint, OneDrive, and Teams workloads
- Review **label application events** (manual and automatic)
- Analyze **user overrides and justifications** for DLP policy exceptions
- Examine **external sharing attempts** and blocking behavior
- Identify patterns in policy effectiveness and user behavior

## ⏱️ Estimated Time

**30-40 minutes**

## 📋 Prerequisites

Before starting this lab:

- ✅ **Audit log enabled** (Day Zero Setup) - Required for Activity Explorer data
- ✅ **Pre-created DLP policies propagated** (1-2 hours from Day Zero Setup)
- ✅ **Lab 04 labels applied** - Manual labels in Office apps
- ✅ **Lab 05 DLP policies enhanced** - Notification rules configured
- ⏰ **Wait 24-48 hours** after policy creation for full Activity Explorer data

> **⏰ Latency Note**: Activity Explorer events can take 24-48 hours to appear. Pre-created baseline policies (Day Zero) should have extensive historical data available.

## 🔍 Part 1: DLP Policy Match Validation (All Workloads)

### Navigate to Activity Explorer

1. Go to [Microsoft Purview Compliance Portal](https://compliance.microsoft.com)
2. Navigate to **Data classification** → **Activity explorer**
3. Review the default dashboard showing activity trends

> **💡 Dashboard Overview**: Activity Explorer shows 30 days of activity by default. Use date filters to focus on specific time periods.

### Filter for DLP Matches

**Configure filters to view DLP policy matches:**

- Click **Filters** at the top
- **Activity**: Select **DLP policy match**
- **Date range**: Last 30 days (or custom range after Lab 05 completion)
- **Workload**: All workloads (to see cross-platform enforcement)
- Click **Apply**

**Expected Results**:

| Workload | Expected Matches | Validation |
|----------|------------------|------------|
| **Exchange Online** | External email with Credit Card, SSN, Loyalty ID | Verify "PCI-DSS Protection" and "PII Data Protection" triggered |
| **SharePoint Online** | Test files uploaded with sensitive data | Verify document-based policies triggered |
| **OneDrive for Business** | Personally uploaded test files | Verify user-specific storage matches |
| **Teams** | Chat/channel messages or file shares | Verify Teams-specific DLP enforcement |

### Drill Down into Specific Matches

**Select a DLP match event** to view details:

- **User**: Who triggered the policy
- **Policy**: Which DLP policy matched
- **Rule**: Specific rule within the policy that triggered
- **Sensitive Information Types**: Which SITs were detected
- **Action**: Block, Allow with override, Notify only
- **Justification**: User's business justification (if override allowed)

> **🎯 Validation Focus**: Confirm that bundled SIT detections (e.g., Credit Card + ABA Routing) show higher confidence than single-SIT matches

## 🏷️ Part 2: Label Application Events (Manual and Automatic)

### View Manual Label Applications

**Change filters to view label events:**

- **Activity**: Select **Sensitivity label applied**
- **Label**: All labels (or filter by specific label like "Confidential")
- **Application**: Filter by Office apps (Word, Excel, PowerPoint, Outlook)
- Click **Apply**

**Expected Results**:

| Label | Application Method | Workload | User Action |
|-------|-------------------|----------|-------------|
| **General** | Manual | Word/Excel | User selected label from ribbon |
| **Confidential** | Manual | Outlook | User selected label for email |
| **Highly Confidential** | Manual | PowerPoint | User applied from sensitivity bar |
| **PCI Data** | Manual | Excel | User applied to payment data file |

> **💡 Manual vs Automatic**: Manual applications appear immediately. Automatic labeling events appear after simulation completes (24-48 hours).

### View Auto-Labeling Policy Results

**Filter for automatic label applications:**

- **Activity**: Select **Sensitivity label applied**
- **Application**: Filter by **Auto-labeling policy**
- **Date range**: After Lab 04 auto-labeling simulation complete
- Click **Apply**

**Expected Policies**:

| Auto-Labeling Policy | Label Applied | SIT Detection | Files Labeled |
|---------------------|---------------|---------------|---------------|
| **Auto-Label PII (Retail)** | Confidential | Credit Card + SSN | Customer exports, payment files |
| **High-Risk Data (Retail)** | Highly Confidential | CC + SSN + Loyalty (all 3) | Complete customer profiles |
| **Customer List (Retail)** | Confidential | Loyalty + Email (both) | Marketing lists |
| **Contact Data (Retail)** | Confidential | Names + Addresses (both) | Contact databases |
| **Standard Forms (Retail)** | Highly Confidential | Document fingerprints | Credit apps, employee forms |

> **🎯 Bundling Validation**: Verify that bundled policies (3 SITs required) labeled fewer files with higher accuracy than single-SIT policies

## ⚖️ Part 3: User Override and Justification Analysis

### Filter for Override Events

**Configure filters to view user overrides:**

- **Activity**: Select **DLP rule override**
- **Policy**: All DLP policies (or specific policy like "PCI-DSS Protection")
- **Date range**: Last 30 days
- Click **Apply**

**Expected Override Scenarios**:

| Policy | Override Type | User Justification | Validation |
|--------|---------------|-------------------|------------|
| **PCI-DSS Protection** | False positive | "Internal team distribution only" | Verify business justification reasonable |
| **External Sharing Control** | Business need | "Vendor requires payment file for processing" | Verify override logged with timestamp |
| **PII Data Protection** | Urgent need | "Compliance audit requires immediate access" | Verify user identity and role |

> **⚠️ Security Review**: High override rates may indicate policies are too strict or users need additional training

### Analyze Justification Patterns

**Review common justification themes:**

1. Click on individual override events
2. Read user-provided justifications
3. Identify patterns:
   - Legitimate business needs (vendor collaboration, audit requirements)
   - Potential policy tuning opportunities (frequent false positives)
   - Training gaps (users misunderstanding policy intent)

**Action Items from Analysis**:

- **High False Positives**: Increase SIT instance count or add exceptions
- **Legitimate Overrides**: Consider adding permanent exceptions for specific scenarios
- **Policy Misunderstanding**: Create user training or improve policy tips

## 🌐 Part 4: External Sharing Attempt Analysis

### Filter for External Sharing Events

**Configure filters to view external sharing attempts:**

- **Activity**: Select **File shared externally**
- **Workload**: SharePoint Online, OneDrive for Business
- **Date range**: Last 30 days
- Click **Apply**

**Expected Sharing Scenarios**:

| Sharing Method | Content Type | DLP Action | User Response |
|----------------|--------------|------------|---------------|
| **OneDrive Link** | Credit Card data file | Blocked | User notified via policy tip |
| **SharePoint Share** | Customer list with Loyalty IDs | Allowed with notification | User justified: "Partner collaboration" |
| **Email Attachment** | PII file with SSN | Blocked | User contacted admin for exception |
| **Teams Guest Access** | Confidential labeled file | Allowed | Guest user has appropriate permissions |

> **💡 Policy Effectiveness**: Compare blocked attempts vs allowed-with-justification to gauge policy strictness

### Cross-Reference with DLP Policies

**For each external sharing attempt:**

1. Note the **Policy** that triggered
2. Check if it's a baseline policy (Day Zero) or enhanced policy (Lab 05)
3. Review the **Rule details** to see SIT combinations detected
4. Verify **Notification** was sent to user
5. Check if **Override** was used and justification provided

**Validation Checklist**:

- [ ] External Sharing Control (Retail) blocked Credit Card external shares
- [ ] PII Data Protection (Retail) detected SSN in shared files
- [ ] Loyalty Card Protection (Retail) detected Retail Loyalty ID in marketing lists
- [ ] Document Forms Protection (Retail) blocked fingerprinted forms (if Lab 05 optional created)

## 📊 Validation Summary

### Activity Explorer Key Metrics

After completing all parts of this lab, you should observe:

| Metric | Expected Value | Validation |
|--------|----------------|------------|
| **Total DLP Matches** | 50+ events (varies by test data) | Policies actively enforcing |
| **Label Applications** | 100+ events (manual + automatic) | Labels being adopted |
| **User Overrides** | <10% of total matches | Policies appropriately strict |
| **External Sharing Blocked** | 20+ events | External sharing control effective |
| **False Positives** | <5% of matches | SIT detection accurate |

> **🎯 Success Criteria**: DLP policies triggering on expected content, low override rates, minimal false positives, external sharing controlled

## 🔍 Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| **No events appearing** | 24-48 hour latency or audit log disabled | Wait 24-48 hours, verify audit log: `Get-AdminAuditLogConfig` |
| **DLP matches missing** | Policy in Test mode (no logging) | Change to TestWithNotifications: `Set-DlpCompliancePolicy -Mode TestWithNotifications` |
| **Label events missing** | Labels not applied or indexing delay | Manually label files in Office apps, wait 1-2 hours |
| **Override events missing** | Override not enabled in policy | Edit DLP rule → Allow overrides → Require justification |
| **External sharing not blocked** | Workload not enabled in policy | Edit DLP policy → Locations → Enable SharePoint/OneDrive |

## ✅ Lab Completion Checklist

Before proceeding to Lab 02 (Content Explorer), verify:

- [ ] Viewed DLP policy matches across all workloads (Exchange, SharePoint, OneDrive, Teams)
- [ ] Analyzed manual and automatic label application events
- [ ] Reviewed user override patterns and justifications
- [ ] Examined external sharing attempts and blocking behavior
- [ ] Identified false positives and policy tuning opportunities
- [ ] Validated that bundled SIT detections show higher confidence than single-SIT matches

## 📚 Next Steps

**Proceed to Lab 02: Content Explorer Validation** to analyze where sensitive content resides across workloads and verify auto-labeling simulation results.

---

*This lab validates Activity Explorer capabilities for auditing user actions and policy enforcement across Microsoft 365 workloads.*
