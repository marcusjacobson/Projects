# Information Protection UI Configuration

> **⏳ TIMING PREREQUISITE**: Before proceeding with this lab, ensure you've completed:
>
> - **01-Day-Zero-Setup**: Baseline labels (General, Confidential) already deployed and propagated (24 hours)
> - **03-Classification-UI**: Custom SITs, EDM classifiers, Document Fingerprints, and BundledEntity classifiers created
> - **02-Data-Foundation**: Test files uploaded to SharePoint for auto-labeling validation
>
> **Note**: You will enhance the pre-created baseline labels and leverage the auto-labeling policy that has already been running in simulation mode.

## 🛑 Run the Prerequisite Validation Script

**Before starting any labs**, run the automated prerequisite checker to ensure everything is ready:

```powershell
cd 04-Information-Protection-UI\scripts
.\Test-LabPrerequisites.ps1
```

**This script validates**:

- ✅ PowerShell modules installed (ExchangeOnlineManagement, Microsoft.Graph)
- ✅ Security & Compliance PowerShell connection
- ✅ Baseline labels exist (General, Confidential)
- ✅ Baseline auto-labeling policy exists and simulation status
- ✅ Custom classifiers available from Lab 03
- ✅ Test data in SharePoint

## 🎯 What This Lab Covers

This lab focuses on **enhancing sensitivity labels and configuring comprehensive auto-labeling policies** in the Purview portal. You'll learn how to:

1. **Complete the 4-Tier Label Taxonomy** (add Public, Highly Confidential, and sub-labels to baseline)
2. **Configure Scoped Labels** for departments (PCI Data, Project Falcon)
3. **Leverage Pre-Created Auto-Labeling** that has already run simulation
4. **Bundle SIT Detections** in auto-labeling policies for retail scenarios
5. **Manage Label Policies** with defaults, mandatory labeling, and justification requirements

This builds on the classifiers created in **03-Classification-UI**, leverages the baseline labels from **01-Day-Zero-Setup**, and provides the foundation for DLP enforcement in **05-Data-Loss-Prevention-UI**.

## 📚 Lab Structure

### Lab 01: Enhance Sensitivity Labels

[Lab-01-Enhance-Labels.md](Lab-01-Enhance-Labels.md)

Complete the 4-tier sensitivity label taxonomy by adding to the baseline labels deployed in Day Zero Setup.

**What You'll Learn**:

- Adding Public and Highly Confidential labels to complete the taxonomy
- Creating scoped sub-labels (PCI Data, Project Falcon) for department-specific protection
- Configuring encryption settings with Co-Authoring support
- Setting up visual markings (headers, footers, watermarks)
- Managing label priority and inheritance

**Duration**: 30-40 minutes

**Labels Created**:

- **Public**: No protection, no markings (new)
- **General**: Footer "Internal Use Only" (pre-created in Day Zero)
- **Confidential**: Header + encryption with Co-Authoring (pre-created, enhanced)
- **Highly Confidential**: Watermark + encryption with Co-Authoring (new)
  - Sub-label: **PCI Data** (scoped to Finance/Compliance)
  - Sub-label: **Project Falcon** (scoped to Strategy Team)

### Lab 02: Configure Auto-Labeling Policies

[Lab-02-Auto-Labeling.md](Lab-02-Auto-Labeling.md)

Leverage the pre-created auto-labeling policy and create bundled auto-labeling policies for comprehensive retail data protection.

**What You'll Learn**:

- Reviewing simulation results from pre-created auto-labeling policy
- Turning on enforcement or refining rules based on simulation
- Bundling multiple SIT detections for high-confidence auto-labeling
- Creating auto-labeling policies for EDM, Document Fingerprinting, and BundledEntity classifiers
- Understanding simulation timelines and validation strategies

**Duration**: 25-30 minutes

**Policies Configuration**:

1. **Pre-Created Policy**: "Auto-Label PII (Retail)" - Review and turn on (already simulated)
   - Detects: Credit Card Numbers, U.S. SSNs
   - Applies: Confidential label
   - Status: Simulation complete (ran during Day Zero Setup)

2. **Multi-SIT Policy (New)**: "Auto-Label High Risk Data (Retail)"
   - Detects: Credit Card + SSN + Loyalty ID (all 3 required)
   - Applies: Highly Confidential label
   - Bundled detection for high-confidence retail data classification

3. **EDM Policy (New)**: "Auto-Label Customer PII (EDM)"
   - Detects: Retail Customer PII (EDM) classifier
   - Applies: Confidential label
   - Exact-match customer database validation

4. **Document Fingerprinting Policy (New)**: "Auto-Label Forms (Retail)"
   - Detects: Credit Card Application Form, Employee Onboarding Form fingerprints
   - Applies: Highly Confidential label
   - Structure-based form protection

5. **BundledEntity Policy (New)**: "Auto-Label Contact Data (Retail)"
   - Detects: All Full Names + All Physical Addresses (both required)
   - Applies: General label
   - ML-based PII detection for customer contact lists

> **⏳ New Policy Timeline**: The 4 new auto-labeling policies will run in simulation mode for 24-48 hours. Full simulation results will be reviewed in **Lab 07-Audit-and-Validation**.

### Lab 03: Label Policy Management

[Lab-03-Label-Policy-Management.md](Lab-03-Label-Policy-Management.md)

Configure advanced label policy settings for enhanced governance and user experience.

**What You'll Learn**:

- Setting default labels for documents and emails
- Enabling mandatory labeling (require users to classify content)
- Configuring justification requirements for label changes
- Understanding client-side vs service-side labeling
- Testing label application in Office applications

**Duration**: 15-20 minutes

**Policy Enhancements**:

- Default label: General (for all new documents)
- Mandatory labeling: Enabled (users must select a label)
- Justification required: For removing or downgrading labels
- Scoped policies: Department-specific label visibility

## 🏷️ Sensitivity Label Taxonomy Overview

| Label Name | Scope | Encryption | Visual Marking | Auto-Labeling Trigger | Source |
|------------|-------|------------|----------------|----------------------|--------|
| **Public** | File, Email | None | None | None (manual only) | Lab 01 (new) |
| **General** | File, Email | None | Footer: "Internal Use Only" | Names + Addresses (BundledEntity) | Day Zero (baseline) |
| **Confidential** | File, Email | Co-Authoring | Header: "Confidential - Internal Use" | SSN or Credit Card or EDM match | Day Zero (enhanced in Lab 01) |
| **Highly Confidential** | File, Email | Co-Authoring | Watermark: "RESTRICTED" | CC + SSN + Loyalty (all 3) or Forms | Lab 01 (new) |

### Sub-Labels (Scoped to Departments)

- **Highly Confidential \ PCI Data**: Scoped to Finance and Compliance security groups
- **Highly Confidential \ Project Falcon**: Scoped to Strategy Team security group

### Auto-Labeling Policy Summary

| Policy Name | Detection Logic | Label Applied | Status | Created In |
|-------------|-----------------|---------------|--------|------------|
| **Auto-Label PII (Retail)** | Credit Card OR SSN | Confidential | Pre-created, simulation complete | Day Zero Setup |
| **Auto-Label High Risk Data (Retail)** | CC AND SSN AND Loyalty ID | Highly Confidential | New, simulation running | Lab 02 |
| **Auto-Label Customer PII (EDM)** | Retail Customer PII (EDM) | Confidential | New, simulation running | Lab 02 |
| **Auto-Label Forms (Retail)** | Credit App Form OR Employee Form | Highly Confidential | New, simulation running | Lab 02 |
| **Auto-Label Contact Data (Retail)** | Names AND Addresses (BundledEntity) | General | New, simulation running | Lab 02 |

## 🛑 Before You Begin

### Required Permissions

- **Global Administrator** or **Compliance Administrator** role
- Access to Purview compliance portal (purview.microsoft.com)
- Permissions to create security groups (for scoped labels)

### Prerequisites Checklist

- [ ] Completed **01-Day-Zero-Setup** (baseline labels and auto-labeling policy deployed)
- [ ] Wait time elapsed: 24 hours for baseline label propagation
- [ ] Completed **03-Classification-UI** (Custom SITs, EDM, Fingerprints, BundledEntity classifiers exist)
- [ ] Completed **02-Data-Foundation** (test files uploaded to SharePoint)
- [ ] **Ran prerequisite validation script** (see above)

### Verify Pre-Created Assets

**Check Baseline Labels Exist** (PowerShell):

```powershell
Connect-IPPSSession
Get-Label | Select-Object DisplayName, Guid | Format-Table
```

**Expected**: General, Confidential labels exist

**Check Auto-Labeling Policy Status** (PowerShell):

```powershell
Get-AutoSensitivityLabelPolicy | Select-Object Name, Mode | Format-Table
```

**Expected**: "Auto-Label PII (Retail)" in TestWithoutNotifications mode (simulation complete)

**Check Classifiers from Lab 03** (PowerShell):

```powershell
Get-DlpSensitiveInformationType -Identity "Retail Loyalty ID"
Get-DlpEdmSchema | Where-Object {$_.Name -like "*Retail*"}
```

**Expected**: Custom SIT, EDM schema, fingerprints, BundledEntity classifiers available

## 📝 General Lab Instructions

1. Navigate to the **Microsoft Purview compliance portal** (purview.microsoft.com)
2. Start with **Lab 01** (Enhance Labels) to complete the label taxonomy
3. Proceed to **Lab 02** (Auto-Labeling) to leverage pre-created policy and create bundled policies
4. Complete **Lab 03** (Label Policy Management) for advanced governance settings
5. **Immediate Validation**: Test label application manually in Office apps
6. **Simulation Validation**: New auto-labeling policies validate in **Lab 07-Audit-and-Validation** (24-48 hours)

## ⚠️ Important Timing Notes

### Label Propagation (Pre-Created Baseline)

- **Portal**: Baseline labels (General, Confidential) already propagated from Day Zero Setup
- **SharePoint/OneDrive**: Available immediately for new labels created in Lab 01
- **Office Apps**: New labels appear within 1-2 hours
- **Exchange**: Email labels available within 4-6 hours

### Auto-Labeling Simulation

**Pre-Created Policy** (Day Zero Setup):

- **"Auto-Label PII (Retail)"**: Simulation already complete (24-48 hours elapsed during Day Zero wait)
- **Review simulation results** in Lab 02 Part 1
- **Turn on enforcement** immediately or refine rules

**New Policies** (Lab 02):

- **4 new bundled auto-labeling policies**: Start 24-48 hour simulation
- **Policies run in parallel**: All 4 simulate during same 24-48 hour window
- **Immediate validation**: Policies visible in portal, simulation begins
- **Full simulation results**: Reviewed in **Lab 07-Audit-and-Validation**

> **💡 Key Point**: You can proceed to **Lab 05-Data-Loss-Prevention-UI** immediately after Lab 04. DLP policies can reference labels as soon as they exist (doesn't require auto-labeling completion).

## 📚 Next Steps

After completing these Information Protection labs:

1. **Lab 05-Data-Loss-Prevention-UI**: Enhance pre-created DLP policies that enforce sharing restrictions based on labels and SITs
   - Leverage labels created in this lab for label-based DLP rules
   - Bundle SIT detections in DLP policies (same retail scenarios)
   - Can start immediately (doesn't require auto-labeling simulation completion)

2. **Lab 07-Audit-and-Validation**: Review comprehensive validation for all policies
   - **Activity Explorer**: Label application events, user actions
   - **Content Explorer**: Auto-labeled files, label distribution, simulation results for new policies
   - **Data Classification**: Classifier effectiveness across all SIT types

3. **IaC-Automation**: Automate label and auto-labeling policy deployment using PowerShell

## 🎯 Key Takeaways

- **Leverage pre-created assets** from Day Zero Setup to avoid redundant wait times
- **Sensitivity labels** provide visual markings and encryption for data protection
- **Bundled auto-labeling** increases confidence by requiring multiple SITs (e.g., CC + SSN + Loyalty = high-risk retail data)
- **Auto-labeling** applies labels based on content classification (SITs, EDM, Fingerprints, BundledEntity)
- **Simulation mode** validates auto-labeling accuracy before enforcement (pre-created policy already simulated)
- **Scoped labels** restrict usage to specific departments (Finance, Compliance, Strategy)
- **Label policies** control default labels, mandatory labeling, and justification requirements

## 🎓 Recommended Lab Sequence

Complete the labs in this order for optimal learning progression:

1. **Lab 01: Enhance Sensitivity Labels** (30-40 min) - Complete 4-tier taxonomy
2. **Lab 02: Configure Auto-Labeling Policies** (25-30 min) - Leverage pre-created + create bundled policies
3. **Lab 03: Label Policy Management** (15-20 min) - Advanced governance settings

**Total Time**: ~70-90 minutes for complete Information Protection configuration

**Immediate Validation**: Test manual label application in Office apps
**Full Validation**: Lab 07-Audit-and-Validation (after 24-48 hour simulation for new policies)

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for Microsoft Purview sensitivity label configuration.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Information Protection requirements while maintaining technical accuracy.*
