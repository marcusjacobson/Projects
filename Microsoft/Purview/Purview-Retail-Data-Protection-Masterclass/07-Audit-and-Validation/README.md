# 07 - Audit and Validation (Comprehensive Policy Validation)

## 🎯 Overview

After configuring Information Protection labels, auto-labeling policies, and DLP policies throughout Labs 04-05, this lab provides **comprehensive validation** using Microsoft Purview's three primary reporting tools:

- **Activity Explorer**: Validate DLP matches, label applications, user actions, and policy effectiveness
- **Content Explorer**: Verify auto-labeled files, label distribution, and simulation results
- **Data Classification**: Analyze SIT detections, classifier effectiveness, and false positive rates

This lab validates **both pre-created baseline policies** (from Day Zero Setup) and **new policies created in Labs 04-05** after appropriate wait periods.

## ⏱️ Timing Prerequisites

**Before starting this lab, ensure:**

- ✅ **Day Zero Setup complete** (2+ weeks ago) - Baseline labels, auto-labeling policy, DLP policies propagated
- ✅ **Lab 04 auto-labeling policies** (24-48 hours simulation) - 4 bundled policies simulated
- ✅ **Lab 05 optional DLP policies** (1-2 hours propagation) - If created, fully propagated
- ✅ **Manual label testing** (immediate) - Files manually labeled in Office apps from Lab 04
- ✅ **Audit log enabled** (Day Zero Setup) - Required for Activity Explorer data

> **⏰ Timing Note**: Activity Explorer has 24-48 hour latency for some event types. Content Explorer updates within 1-2 hours. Data Classification updates within 1 hour for new detections.

## 📁 Lab Structure

This section contains **3 comprehensive validation labs** using Microsoft Purview's reporting capabilities:

### Lab 01: Activity Explorer Validation (30-40 min)
- **Part 1**: DLP policy match validation (all workloads)
- **Part 2**: Label application events (manual and automatic)
- **Part 3**: User override and justification analysis
- **Part 4**: External sharing attempt analysis

### Lab 02: Content Explorer Validation (25-35 min)
- **Part 1**: Auto-labeled file discovery and distribution
- **Part 2**: Label simulation results analysis
- **Part 3**: Workload distribution verification (SharePoint, OneDrive, Exchange)
- **Part 4**: SIT detection in labeled content

### Lab 03: Data Classification Validation (30-40 min)
- **Part 1**: SIT detection effectiveness (built-in, custom, EDM, fingerprints, bundled entities)
- **Part 2**: Classifier usage analysis and false positive review
- **Part 3**: Top SIT combinations and bundling effectiveness
- **Part 4**: Sensitive item trends and compliance posture

**Total Time**: ~85-115 minutes

## 📊 Validation Scope

### Pre-Created Baseline Policies (Day Zero Setup)

| Policy Type | Policy Name | Validation Focus |
|-------------|-------------|------------------|
| **Labels** | General, Confidential | Manual application events, workload distribution |
| **Auto-Labeling** | Auto-Label PII (Retail) | Credit Card + SSN detections, simulation results |
| **DLP** | PCI-DSS Protection (Retail) | Credit Card + ABA matches, blocking events |
| **DLP** | PII Data Protection (Retail) | U.S. SSN matches, user overrides |
| **DLP** | Loyalty Card Protection (Retail) | Retail Loyalty ID detections (enhanced in Lab 05) |
| **DLP** | External Sharing Control (Retail) | External sharing attempts, policy tips shown |

### New Policies from Labs 04-05

| Lab | Policy Type | Policy Name | Validation Focus |
|-----|-------------|-------------|------------------|
| **04** | Labels | Public, Highly Confidential, PCI Data, Project Falcon | Manual application, workload distribution |
| **04** | Auto-Labeling | High-Risk Data (Retail) | CC + SSN + Loyalty bundled detection |
| **04** | Auto-Labeling | Customer List (Retail) | Loyalty + Email bundled detection |
| **04** | Auto-Labeling | Contact Data (Retail) | Names + Addresses bundled detection |
| **04** | Auto-Labeling | Standard Forms (Retail) | Document fingerprint detection |
| **05** | DLP | Document Forms Protection (Retail) | Fingerprint-based DLP matches (optional) |
| **05** | DLP | Marketing List Protection (Retail) | Multi-condition bundling (optional) |

## 🔍 Before You Begin

### Prerequisite Validation

**Run the prerequisite validation script** to verify all policies are ready for comprehensive validation:

```powershell
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Retail-Data-Protection-Masterclass\07-Audit-and-Validation\scripts"
.\Test-LabPrerequisites.ps1
```

**Script validates**:
- Audit log enabled and events flowing
- Baseline labels published and propagated
- Pre-created auto-labeling policy simulation complete
- Pre-created DLP policies propagated (4 policies)
- Lab 04 auto-labeling policies simulation complete (if applicable)
- Lab 05 optional DLP policies propagated (if applicable)
- Test data available in SharePoint for validation

### Manual Verification Commands

**Check audit log status**:
```powershell
Get-AdminAuditLogConfig | Select-Object UnifiedAuditLogIngestionEnabled
```

**Check label policy status**:
```powershell
Get-LabelPolicy | Select-Object Name, Enabled, Mode, WhenCreatedUTC, WhenChangedUTC
```

**Check auto-labeling policies**:
```powershell
Get-AutoSensitivityLabelPolicy | Select-Object Name, Mode, ApplySensitivityLabel, WhenCreatedUTC
```

**Check DLP policies**:
```powershell
Get-DlpCompliancePolicy | Select-Object Name, Mode, Enabled, Workload, WhenCreatedUTC
```

## 📋 General Instructions

### Three-Phase Validation Approach

**Phase 1: Activity Explorer** (Lab 01)
- Focus on **user actions and policy enforcement**
- Validate DLP matches, label applications, overrides
- Analyze external sharing attempts and blocking behavior
- Review user justifications and business reasons

**Phase 2: Content Explorer** (Lab 02)
- Focus on **where sensitive content resides**
- Verify auto-labeling simulation results
- Check label distribution across workloads
- Identify top SIT detections in labeled files

**Phase 3: Data Classification** (Lab 03)
- Focus on **classifier effectiveness and accuracy**
- Analyze built-in, custom, EDM, and fingerprint SIT usage
- Review false positive rates and bundling effectiveness
- Examine sensitive item trends over time

### Validation Best Practices

> **💡 Systematic Approach**: Start with Activity Explorer (what happened), then Content Explorer (where it is), then Data Classification (how accurate are detections)

> **⚠️ Latency Awareness**: Activity Explorer events may take 24-48 hours to appear. Content Explorer updates within 1-2 hours. Plan validation timing accordingly.

> **📊 False Positive Analysis**: Use Data Classification to identify patterns in false positives, then refine SIT instance counts or confidence levels in policies

> **🎯 Bundling Effectiveness**: Compare single-SIT detections vs bundled-SIT detections to validate that bundling reduces false positives while maintaining detection coverage

## 📚 Next Steps

After completing this comprehensive validation lab:

1. **Lab 08-Exfiltration-Simulation**: Test DLP policies with realistic sharing scenarios
   - Share files via Outlook email with external recipients
   - Share via Teams chat with guest users
   - Share via OneDrive external links
   - Validate policy tips, blocking behavior, and override workflows

2. **IaC-Automation**: Automate policy deployment and validation
   - PowerShell scripts for policy creation, testing, and reporting
   - Azure DevOps pipelines for enterprise deployment
   - Automated validation scripts for continuous compliance monitoring

## 🎯 Key Takeaways

- **Activity Explorer** shows real-time user actions and policy enforcement events
- **Content Explorer** provides visibility into labeled content across all workloads
- **Data Classification** reveals SIT effectiveness and false positive rates
- **Baseline policies** (Day Zero) provide immediate validation data
- **New policies** (Labs 04-05) require 24-48 hours for full validation data
- **Bundled SIT detection** can be validated through Data Classification trends
- **False positive analysis** is critical for policy tuning and user adoption
- **Cross-workload validation** ensures consistent protection across SharePoint, OneDrive, Exchange, Teams

## 🎓 Recommended Lab Sequence

Complete the labs in this order for optimal validation progression:

1. **Lab 01: Activity Explorer Validation** (30-40 min) - User actions, DLP matches, overrides
2. **Lab 02: Content Explorer Validation** (25-35 min) - Auto-labeled files, workload distribution
3. **Lab 03: Data Classification Validation** (30-40 min) - SIT effectiveness, false positives

**Total Time**: ~85-115 minutes

**Immediate Validation**: Pre-created baseline policies (Day Zero)
**Full Validation**: New policies after 24-48 hour simulation/propagation

## ⚠️ Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| **No events in Activity Explorer** | Audit log not enabled or 24-48 hour latency | Verify audit log enabled: `Get-AdminAuditLogConfig`, wait 24-48 hours |
| **Auto-labeling simulation not complete** | Policies still in simulation (24-48 hours) | Check policy mode: `Get-AutoSensitivityLabelPolicy \| Select Mode` |
| **Content Explorer shows no files** | Indexing delay (1-2 hours) or no labeled content | Wait 1-2 hours, verify labels applied manually in Office apps |
| **DLP matches not appearing** | Policy in Test mode or not propagated | Check policy mode: `Get-DlpCompliancePolicy \| Select Mode, Enabled` |
| **False positive rate too high** | SIT instance count too low | Increase instance count (5 → 10) or add bundled conditions |
| **Fingerprint not detecting** | Document variation too different from training | Create multiple fingerprints for same document type (blank, filled) |
| **EDM not detecting** | Schema refresh needed or datastore not indexed | Wait 1-2 hours, verify EDM status: `Get-DlpEdmSchema` |
| **Labels not appearing in Content Explorer** | Label policy not published (24 hours) | Verify label policy: `Get-LabelPolicy \| Select Enabled, WhenChangedUTC` |
| **Bundled SIT not detecting** | Condition logic incorrect (AND vs OR) | Review policy conditions, test with known good data |

---

## 🤖 AI-Assisted Content Generation

This comprehensive audit and validation guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview reporting capabilities, validation methodologies, and enterprise-grade compliance auditing standards for 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of validation tools while maintaining technical accuracy and reflecting modern Purview compliance capabilities.*
