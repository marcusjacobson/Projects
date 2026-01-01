# Lab 02: Content Explorer Validation

## 🎯 Objectives

By the end of this lab, you will:

- Navigate and use **Content Explorer** to discover labeled content across workloads
- Validate **auto-labeling simulation results** for policies created in Lab 04
- Analyze **label distribution** across SharePoint, OneDrive, and Exchange
- Review **SIT detections** within labeled files
- Identify **top labeled locations** and content types
- Verify **workload coverage** for comprehensive protection

## ⏱️ Estimated Time

**25-35 minutes**

## 📋 Prerequisites

Before starting this lab:

- ✅ **Lab 04 auto-labeling policies** - Simulation complete (24-48 hours)
- ✅ **Manual labels applied** - Files labeled in Office apps during Lab 04
- ✅ **Test data uploaded** - SharePoint/OneDrive test files from Lab 02
- ⏰ **Wait 1-2 hours** after label application for Content Explorer indexing

> **⏰ Indexing Note**: Content Explorer updates within 1-2 hours of label application. Auto-labeling simulation must be complete (24-48 hours) to see results.

## 🔍 Part 1: Auto-Labeled File Discovery and Distribution

### Navigate to Content Explorer

1. Go to [Microsoft Purview Compliance Portal](https://compliance.microsoft.com)
2. Navigate to **Data classification** → **Content explorer**
3. Review the default view showing top labels and locations

> **💡 Dashboard Overview**: Content Explorer shows labeled content across all workloads. Use filters to drill down into specific labels or locations.

### View Auto-Labeling Results by Label

**Filter to see auto-labeled files:**

- Click on the **Sensitivity labels** section
- Select **Confidential** label
- Review the count and distribution

**Expected Auto-Labeled Files**:

| Label | Auto-Labeling Policy | Expected Files | SIT Detection |
|-------|---------------------|----------------|---------------|
| **Confidential** | Auto-Label PII (Retail) | 20-30 files | Credit Card + SSN |
| **Confidential** | Customer List (Retail) | 10-15 files | Loyalty + Email |
| **Confidential** | Contact Data (Retail) | 15-20 files | Names + Addresses |
| **Highly Confidential** | High-Risk Data (Retail) | 5-10 files | CC + SSN + Loyalty (all 3) |
| **Highly Confidential** | Standard Forms (Retail) | 8-12 files | Document fingerprints |

> **🎯 Validation Focus**: Files labeled by auto-labeling policies should match the SIT combinations defined in Lab 04

### Drill Down into Specific Label

**Select the "Confidential" label** to view details:

1. Click on **Confidential** in the label list
2. Review the **Locations** section (SharePoint, OneDrive, Exchange)
3. Click **SharePoint Online** to see site distribution
4. Select a specific site to view individual files

**Expected Distribution**:

- **SharePoint Online**: Bulk of test data (customer lists, payment files, forms)
- **OneDrive for Business**: User-specific uploads (personal test files)
- **Exchange Online**: Email attachments with sensitive data

## 📊 Part 2: Label Simulation Results Analysis

### View Auto-Labeling Policy Simulation Summary

**Navigate to label policy details:**

1. In Content Explorer, note the total count for each auto-labeled category
2. Go to **Information protection** → **Auto-labeling**
3. Select **Auto-Label PII (Retail)** (baseline policy from Day Zero)
4. Review **Simulation results** tab

**Expected Simulation Data**:

| Policy | Items Matched | Items to Label | Confidence | Status |
|--------|---------------|----------------|------------|--------|
| **Auto-Label PII (Retail)** | 25-35 files | 25-35 files | High (85-95%) | Simulation Complete |
| **High-Risk Data (Retail)** | 5-10 files | 5-10 files | Very High (95-100%) | Simulation Complete |
| **Customer List (Retail)** | 10-15 files | 10-15 files | High (90-95%) | Simulation Complete |
| **Contact Data (Retail)** | 15-20 files | 15-20 files | Medium-High (80-90%) | Simulation Complete |
| **Standard Forms (Retail)** | 8-12 files | 8-12 files | Very High (95-100%) | Simulation Complete |

> **💡 Turning On Auto-Labeling**: If policies are still in simulation mode, turn them on in **Information protection** → **Auto-labeling** → Select policy → **Turn on policy**

### Compare Simulation vs Actual Labels

**Cross-reference simulation results with Content Explorer:**

- **Simulation "Items to Label"**: Projected files to be labeled
- **Content Explorer Count**: Actual files labeled (after turning on)
- **Variance**: Should be <10% difference (indicates accurate simulation)

**Validation Checklist**:

- [ ] Simulation count matches Content Explorer count (+/- 10%)
- [ ] High-confidence policies (bundled SITs) show lower volume but higher accuracy
- [ ] Single-SIT policies show higher volume but may have more false positives
- [ ] Document fingerprint policies show very high confidence (95-100%)

## 🌐 Part 3: Workload Distribution Verification

### Analyze Label Distribution by Workload

**View workload coverage:**

1. In Content Explorer, select a label (e.g., **Confidential**)
2. Review the **Locations** breakdown
3. Click into each workload to see file counts

**Expected Workload Distribution**:

| Workload | Expected Files | Content Type |
|----------|----------------|--------------|
| **SharePoint Online** | 60-70% of labeled files | Document libraries, lists, bulk data |
| **OneDrive for Business** | 20-30% of labeled files | Personal uploads, user-specific data |
| **Exchange Online** | 5-10% of labeled files | Email attachments, calendar items |
| **Teams** | 5-10% of labeled files | Shared files in channels, chat attachments |

> **🎯 Coverage Goal**: Labeled content should span all workloads to ensure comprehensive protection

### Identify Top Labeled Locations

**Drill down into SharePoint sites:**

1. Click **SharePoint Online** in the locations list
2. Review the **Top SharePoint sites** with labeled content
3. Select a site to view document libraries and files

**Expected Top Locations**:

- **Retail Ops** SharePoint site (test data repository from Lab 02)
- **Finance** document library (payment files with Credit Card + SSN)
- **Marketing** document library (customer lists with Loyalty + Email)
- **HR** document library (employee forms with fingerprints)

**Validation**:

- [ ] Test data sites show expected label distribution
- [ ] Production sites (if any) show appropriate labeling
- [ ] No unexpected sites with high volumes of sensitive data

## 🔍 Part 4: SIT Detection in Labeled Content

### View Sensitive Information Types in Files

**Analyze SIT detections within labeled content:**

1. In Content Explorer, select a label (e.g., **Highly Confidential**)
2. Drill down to a specific file (e.g., "Customer-Profile-Export.docx")
3. Review the **Details** pane showing:
   - **Label**: Highly Confidential
   - **Label Source**: Auto-labeling policy (or Manual)
   - **Sensitive Info Types**: Credit Card, U.S. SSN, Retail Loyalty ID
   - **Instance Counts**: Number of each SIT detected

**Expected SIT Detections by Label**:

| Label | Policy | SIT Combination | Instance Counts |
|-------|--------|-----------------|-----------------|
| **Highly Confidential** | High-Risk Data (Retail) | CC (5), SSN (5), Loyalty (5) | All 3 SITs present |
| **Confidential** | Auto-Label PII (Retail) | CC (3), SSN (3) | 2 SITs present |
| **Confidential** | Customer List (Retail) | Loyalty (10), Email (10) | 2 SITs present |
| **Confidential** | Contact Data (Retail) | Names (15), Addresses (15) | 2 BundledEntity SITs |
| **Highly Confidential** | Standard Forms (Retail) | Fingerprint match (1) | Document fingerprint |

> **🎯 Bundling Validation**: Files labeled by bundled policies should show multiple SIT types, confirming AND condition logic works correctly

### False Positive Review

**Identify potential false positives:**

1. In Content Explorer, select **General** label (should be low-sensitivity files)
2. Drill down to individual files
3. Check if any files have unexpected SIT detections

**False Positive Indicators**:

- Files labeled "General" but contain Credit Card numbers (misclassification)
- Test data labeled "Highly Confidential" when it should be "Confidential"
- Non-sensitive files incorrectly matched by SITs (e.g., phone numbers as SSN)

**Action Items**:

- [ ] Document false positives with file names and SIT detections
- [ ] Review SIT instance counts (may need to increase threshold)
- [ ] Consider adding exceptions for specific file types or locations
- [ ] Refine auto-labeling policy conditions if false positive rate >5%

## 📊 Validation Summary

### Content Explorer Key Metrics

After completing all parts of this lab, you should observe:

| Metric | Expected Value | Validation |
|--------|----------------|------------|
| **Total Labeled Files** | 100+ files (manual + automatic) | Labels being applied |
| **Auto-Labeling Coverage** | 60-70% of test data | Auto-labeling effective |
| **Workload Distribution** | SharePoint (60-70%), OneDrive (20-30%), Exchange/Teams (10-20%) | Cross-platform coverage |
| **Bundled Policy Accuracy** | <5% false positives | High-confidence detections |
| **Simulation Match Rate** | 90%+ match between simulation and actual | Accurate policy tuning |

> **🎯 Success Criteria**: Auto-labeling policies labeling expected files, minimal false positives, comprehensive workload coverage

## 🔍 Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| **No labeled files appearing** | Indexing delay (1-2 hours) or labels not applied | Wait 1-2 hours, manually label files in Office apps |
| **Auto-labeling count is zero** | Simulation not complete or policy not turned on | Wait 24-48 hours for simulation, turn on policy |
| **File details not showing SITs** | File not scanned or SIT not detected | Re-upload file, verify SIT exists in test data |
| **Wrong label applied** | Multiple policies matched, highest priority won | Review auto-labeling policy priority order |
| **SharePoint sites not appearing** | Site not crawled or permissions issue | Wait for site crawl (up to 24 hours), verify admin access |
| **High false positive rate** | SIT instance count too low or confidence too low | Increase instance count (5 → 10), use Medium-High confidence |

## ✅ Lab Completion Checklist

Before proceeding to Lab 03 (Data Classification), verify:

- [ ] Viewed auto-labeling simulation results for all policies created in Lab 04
- [ ] Analyzed label distribution across SharePoint, OneDrive, Exchange, Teams
- [ ] Drilled down into specific files to verify SIT detections
- [ ] Identified top labeled locations (SharePoint sites, OneDrive users)
- [ ] Reviewed false positives and documented tuning opportunities
- [ ] Confirmed bundled SIT policies show multiple SIT types in labeled files

## 📚 Next Steps

**Proceed to Lab 03: Data Classification Validation** to analyze SIT detection effectiveness, classifier usage, and false positive rates across all policies.

---

*This lab validates Content Explorer capabilities for discovering and analyzing labeled content across Microsoft 365 workloads.*
