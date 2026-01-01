# Data Loss Prevention UI Configuration

> **⏳ TIMING PREREQUISITE**: Before proceeding with this lab, ensure you've completed:
>
> - **01-Day-Zero-Setup**: Baseline DLP policies already deployed and propagated (1-2 hours complete)
> - **03-Classification-UI**: Custom SITs, EDM classifiers, Document Fingerprints, and BundledEntity classifiers created
> - **04-Information-Protection-UI**: Sensitivity labels created (Public, General, Confidential, Highly Confidential)
> - **02-Data-Foundation**: Test files uploaded to SharePoint for DLP validation
>
> **Note**: You will enhance the 4 pre-created baseline DLP policies that have already propagated to M365 workloads. No additional wait time required for enhanced policies.

## 🛑 Run the Prerequisite Validation Script

**Before starting any labs**, run the automated prerequisite checker to ensure everything is ready:

```powershell
cd 05-Data-Loss-Prevention-UI\scripts
.\Test-LabPrerequisites.ps1
```

**This script validates**:

- ✅ PowerShell modules installed (ExchangeOnlineManagement)
- ✅ Security & Compliance PowerShell connection
- ✅ Baseline DLP policies exist (PCI-DSS, PII, Loyalty, External Sharing)
- ✅ Sensitivity labels available from Lab 04
- ✅ Custom classifiers available from Lab 03
- ✅ Test data in SharePoint

## 🎯 What This Lab Covers

This lab focuses on **enhancing pre-created DLP policies and configuring advanced DLP features** in the Purview portal to enforce sharing restrictions. You'll learn how to:

1. **Enhance Pre-Created DLP Policies** with notifications, overrides, and bundled conditions
2. **Replace Placeholder Rules** with custom SITs created in Lab 03
3. **Bundle SIT Detections** for high-confidence retail scenarios (same combinations as auto-labeling)
4. **Configure Advanced Features**: Policy tips, incident reports, alert tuning
5. **Test DLP Blocking** across Exchange, Teams, SharePoint, OneDrive with manual labels
6. **Create Optional Advanced Policies** (with propagation wait) for document fingerprinting and multi-condition scenarios

This is the final UI configuration lab before comprehensive validation in **07-Audit-and-Validation**.

## 📚 Lab Structure

### Lab 01: Enhance Pre-Created DLP Policies

[Lab-01-Enhance-DLP-Policies.md](Lab-01-Enhance-DLP-Policies.md)

Enhance the 4 baseline DLP policies created in Day Zero Setup by adding advanced features and bundled SIT detections.

**What You'll Learn**:

- Adding user notifications and policy tips to pre-created policies
- Configuring override capabilities with business justification
- Setting up incident reports for compliance teams
- Bundling multiple SIT detections for high-confidence rules
- Replacing placeholder rules with custom SITs
- Adding label-based and fingerprinting conditions

**Duration**: 40-50 minutes

**Policies Enhanced**:

1. **"PCI-DSS Protection (Retail)"** - Add notifications, overrides, bundle CC + ABA Routing conditions
2. **"Loyalty Card Protection (Retail)"** - Replace placeholder with Retail Loyalty ID, bundle Loyalty + Email
3. **"PII Data Protection (Retail)"** - Add EDM classifier, bundle SSN + EDM + BundledEntity (Names)
4. **"External Sharing Control (Retail)"** - Add label-based blocking (Highly Confidential), add fingerprinting

> **✅ No Wait Time**: Enhancing existing policies that already propagated during Day Zero Setup (1-2 hours elapsed)

### Lab 02: Advanced DLP Features

[Lab-02-Advanced-DLP-Features.md](Lab-02-Advanced-DLP-Features.md)

Configure advanced DLP capabilities for enhanced user experience and governance.

**What You'll Learn**:

- Customizing policy tips with actionable guidance
- Tuning alert thresholds and incident reports
- Configuring exceptions for security groups and locations
- Understanding policy modes (Test, TestWithNotifications, Enforce)
- Testing DLP enforcement across workloads (Exchange, Teams, SharePoint, OneDrive)

**Duration**: 25-30 minutes

**Advanced Features Covered**:

- Policy tip best practices and customization
- Alert tuning for compliance teams
- Exception management (security groups, SharePoint sites)
- Policy mode progression (Test → Enforce)
- Cross-workload validation

> **✅ Immediate Testing**: Test with manually-applied labels and pre-created classifiers

### Lab 03: Create Optional Advanced Policies

[Lab-03-Optional-Advanced-Policies.md](Lab-03-Optional-Advanced-Policies.md)

**OPTIONAL** - Create additional DLP policies for comprehensive coverage (requires 1-2 hour propagation).

**What You'll Learn**:

- Creating document fingerprinting-based DLP policies
- Building multi-condition bundled DLP rules
- Validating policy precedence and priority

**Duration**: 20-25 minutes (optional)

**Policies Created** (Optional):

1. **"Document Forms Protection (Retail)"** - Detects Credit App Form OR Employee Form fingerprints, blocks external sharing
2. **"Marketing List Protection (Retail)"** - Detects Loyalty ID + Email + Physical Address (all 3), blocks with override

> **⏳ New Policy Wait**: +1-2 hours for workload propagation (policies can be created in parallel). Full validation in **Lab 07-Audit-and-Validation**.

## 🛡️ DLP Policy Design Overview

### Pre-Created Baseline Policies (Day Zero Setup - Already Propagated)

**Policy 1: PCI-DSS Protection (Retail)**

**Original Configuration** (Day Zero):
- Workloads: Exchange, SharePoint, OneDrive, Teams
- Rules: Credit Card Data, Banking Data (ABA Routing)
- Action: Audit only (TestWithNotifications mode)

**Lab 01 Enhancements**:
- Add user notifications and policy tips
- Add override with business justification
- Add incident reports to compliance team
- Bundle conditions: Credit Card + ABA Routing → higher confidence PCI data
- Mode: Keep TestWithNotifications for safe testing

---

**Policy 2: Loyalty Card Protection (Retail)**

**Original Configuration** (Day Zero):
- Workloads: Exchange, SharePoint, OneDrive, Teams
- Rules: **Placeholder** (Credit Card - temporary)
- Action: Audit only

**Lab 01 Enhancements**:
- **Replace placeholder**: Delete Credit Card rule, add Retail Loyalty ID (custom SIT)
- **Bundle conditions**: Loyalty ID + Email (within 300 chars) → customer list detection
- Add user notifications and overrides
- Add incident reports

> **Why Bundling?** Loyalty ID alone could be isolated references. Loyalty ID + Email = high-confidence customer list export.

---

**Policy 3: PII Data Protection (Retail)**

**Original Configuration** (Day Zero):
- Workloads: Exchange, SharePoint, OneDrive, Teams
- Rules: U.S. SSN detection only
- Action: Audit only

**Lab 01 Enhancements**:
- **Add EDM classifier**: Retail Customer PII (EDM) for exact-match database validation
- **Add BundledEntity**: All Full Names for ML-based PII detection
- **Bundle conditions**: SSN OR EDM OR Names → comprehensive PII coverage
- Add stricter actions for external sharing (block without override)
- Add incident reports to privacy officer

> **Bundling Strategy**: SSN (pattern) + EDM (exact match) + Names (ML) = multi-layer PII protection

---

**Policy 4: External Sharing Control (Retail)**

**Original Configuration** (Day Zero):
- Workloads: Exchange, SharePoint, OneDrive, Teams
- Rules: Credit Card external sharing only
- Action: Audit only

**Lab 01 Enhancements**:
- **Add label-based rule**: Block external sharing of "Highly Confidential" labeled files
- **Add fingerprinting rule**: Block Credit Card Application Form and Employee Onboarding Form
- Combine: SIT-based + Label-based + Fingerprint-based = comprehensive external sharing control
- Add policy tips with override options

> **Multi-Method Protection**: SIT detects content, Labels detect classification, Fingerprints detect forms - layered defense

## 🛑 Before You Begin

### Required Permissions
- **Global Administrator** or **Compliance Administrator** role
- Access to Purview compliance portal (purview.microsoft.com)
- Permissions to create security groups (for policy exceptions)

## 🛑 Before You Begin

### Required Permissions

- **Global Administrator** or **Compliance Administrator** role
- Access to Purview compliance portal (purview.microsoft.com)
- Permissions to create security groups (for policy exceptions)

### Prerequisites Checklist

- [ ] Completed **01-Day-Zero-Setup** (baseline DLP policies deployed and propagated)
- [ ] Wait time elapsed: 1-2 hours for baseline DLP policy propagation (complete)
- [ ] Completed **03-Classification-UI** (Custom SITs, EDM, Fingerprints, BundledEntity classifiers exist)
- [ ] Completed **04-Information-Protection-UI** (Sensitivity labels created)
- [ ] Completed **02-Data-Foundation** (test files uploaded for validation)
- [ ] **Ran prerequisite validation script** (see above)

### Verify Pre-Created DLP Policies

**Check Baseline DLP Policies Exist** (PowerShell):

```powershell
Connect-IPPSSession
Get-DlpCompliancePolicy | Select-Object Name, Mode | Format-Table
```

**Expected Policies**:
- "PCI-DSS Protection (Retail)" - Mode: TestWithNotifications
- "PII Data Protection (Retail)" - Mode: TestWithNotifications
- "Loyalty Card Protection (Retail)" - Mode: TestWithNotifications
- "External Sharing Control (Retail)" - Mode: TestWithNotifications

**Check Policy Rules** (PowerShell):

```powershell
Get-DlpComplianceRule | Where-Object {$_.Policy -like "*Retail*"} | Select-Object Name, Policy, ContentContainsSensitiveInformation | Format-List
```

**Expected**: Each policy has rules using built-in SITs (Credit Card, SSN) and placeholders to be replaced

**Check Classifiers from Lab 03** (PowerShell):

```powershell
Get-DlpSensitiveInformationType -Identity "Retail Loyalty ID"
Get-DlpEdmSchema | Where-Object {$_.Name -like "*Retail*"}
```

**Expected**: Custom SIT, EDM schema, fingerprints available for adding to DLP rules

**Check Labels from Lab 04** (PowerShell):

```powershell
Get-Label | Select-Object DisplayName, Guid | Format-Table
```

**Expected**: Public, General, Confidential, Highly Confidential labels available for label-based DLP conditions

## 📝 General Lab Instructions

1. Navigate to the **Microsoft Purview compliance portal** (purview.microsoft.com)
2. Go to **Data Loss Prevention** > **Policies**
3. Start with **Lab 01** (Enhance Pre-Created Policies) to add advanced features to baseline policies
4. Proceed to **Lab 02** (Advanced DLP Features) for policy tips, alerts, and cross-workload testing
5. Optionally complete **Lab 03** (Create Advanced Policies) for additional coverage (requires 1-2 hour wait)
6. **Immediate Validation**: Test policy tips and blocking with pre-created policies (already propagated)
7. **Full Validation**: Lab 07-Audit-and-Validation for Activity Explorer review and optional new policy testing

## ⚠️ Important Configuration Notes

### DLP Policy Modes

- **Test mode (no tips)**: Logs matches, no user impact
- **Test mode with tips** (TestWithNotifications): Shows policy tips to users, logs matches
- **Enforce**: Blocks actions and shows policy tips

**Current State**: All pre-created baseline policies are in **TestWithNotifications** mode
**Recommendation**: Keep TestWithNotifications for Labs 01-02 to validate detection and user experience

### Workload Propagation Times (Pre-Created Policies)

**Baseline Policies** (Day Zero Setup):
- **Exchange Online**: Already propagated (1-2 hours elapsed)
- **SharePoint/OneDrive**: Already propagated (1-2 hours elapsed)
- **Microsoft Teams**: Already propagated (1-2 hours elapsed)

**Enhanced Policies** (Lab 01):
- **Rule updates**: Apply immediately (no additional wait)
- **New conditions**: Apply immediately (no additional wait)
- **Testing**: Can start immediately after enhancements

**Optional New Policies** (Lab 03):
- **Document Forms Protection (Retail)**: +1-2 hours for propagation
- **Marketing List Protection (Retail)**: +1-2 hours for propagation
- **Recommendation**: Create both at start of Lab 03, continue working, test after completion

### Bundled SIT Detection Strategy

Following the combination strategies from **03-Classification-UI**, DLP policies use the same bundling logic:

| Bundled Detection | SITs Combined | Retail Scenario | Confidence Level |
|-------------------|---------------|-----------------|------------------|
| **High-Risk Data** | CC + SSN + Loyalty (all 3) | Complete customer profile export | Very High |
| **Customer List** | Loyalty ID + Email (both) | Marketing campaign export | High |
| **Comprehensive PII** | SSN OR EDM OR Names (any) | Any PII detection | Medium-High |
| **PCI Data** | Credit Card + ABA Routing (both) | Payment processing data | Very High |

> **💡 Bundling Benefits**: Reduces false positives, increases detection confidence, aligns with realistic retail data usage patterns

## 📚 Next Steps

After completing this DLP configuration lab:

1. **Lab 07-Audit-and-Validation**: Review comprehensive validation for all DLP policies
   - **Activity Explorer**: DLP matches, policy tips shown, user overrides, external sharing attempts
   - **Content Explorer**: Files with labels, SIT detections across all workloads
   - **Data Classification**: Classifier effectiveness, false positive analysis
   - Full validation for optional new policies created in Lab 03

2. **IaC-Automation**: Automate DLP policy deployment
   - PowerShell scripts for policy creation and rule management
   - Azure DevOps pipelines for enterprise deployment
   - Version control and change management

## 🎯 Key Takeaways

- **Leverage pre-created baseline policies** to avoid redundant 1-2 hour wait times
- **DLP policies** enforce sharing restrictions based on content classification (SITs, EDM, Labels, Fingerprints)
- **Bundled SIT detection** provides high-confidence matching aligned with realistic retail scenarios
- **Layered detection**: SIT-based + Label-based + Fingerprint-based = comprehensive protection
- **User education** through policy tips reduces accidental violations
- **Override capabilities** balance security with business flexibility
- **Test mode** validates policies before enforcement with minimal user impact
- **Incident reporting** provides visibility for compliance teams

## 🎓 Recommended Lab Sequence

Complete the labs in this order for optimal learning progression:

1. **Lab 01: Enhance Pre-Created DLP Policies** (40-50 min) - Add notifications, overrides, bundled conditions (no wait)
2. **Lab 02: Advanced DLP Features** (25-30 min) - Policy tips, alerts, cross-workload testing (no wait)
3. **Lab 03: Create Optional Advanced Policies** (20-25 min, optional) - Document forms, marketing list protection (+1-2 hour wait)

**Total Time**: ~65-80 minutes for core DLP enhancement (no wait)
**Optional Time**: +20-25 minutes for advanced policies (+1-2 hour propagation)

**Immediate Validation**: Test with pre-created policies (already propagated)
**Full Validation**: Lab 07-Audit-and-Validation (after optional policy propagation)

## ⚠️ Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| **Policy not triggering** | Policy still propagating (1-2 hours) | Check policy status in Compliance Portal → DLP → Policies |
| **Too many false positives** | SIT instance count too low | Increase instance count (e.g., 5 → 10) or adjust confidence level |
| **Policy tips not appearing** | Tips not enabled in rule configuration | Edit rule → User notifications → Enable "Show policy tips" |
| **External sharing still allowed** | Policy in Test mode | Change to TestWithNotifications or On (after validation) |
| **Label-based rules not working** | Labels not published or propagated | Verify label policy published (24 hours), check file labels in Office apps |
| **Fingerprint not detecting** | Document variations too different | Use multiple fingerprints for same document type (blank vs filled) |
| **EDM not detecting** | Schema hash refresh needed | Wait 1-2 hours after schema changes, verify EDM datastore status |
| **Override not working** | Override justification required | Enable "Require business justification" in rule configuration |
| **No DLP incidents generated** | Audit logging not enabled | Enable audit log (Office 365 Security & Compliance → Audit log search) |

---

## 🤖 AI-Assisted Content Generation

This comprehensive Data Loss Prevention guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview DLP capabilities, bundled SIT detection strategies, and enterprise-grade data protection standards aligned with retail business scenarios.

*AI tools were used to enhance productivity and ensure comprehensive coverage of DLP policy configuration while maintaining technical accuracy and reflecting modern Purview compliance capabilities for 2025.*
