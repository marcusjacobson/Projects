# Lab 03: Data Classification Validation

## 🎯 Objectives

By the end of this lab, you will:

- Navigate and use **Data Classification** to analyze SIT effectiveness across all classifiers
- Validate **built-in, custom, EDM, fingerprint, and bundled entity SIT detections**
- Review **classifier usage** and detection volumes
- Analyze **false positive rates** and detection confidence levels
- Examine **top SIT combinations** and bundling effectiveness
- Identify **sensitive item trends** over time for compliance posture assessment

## ⏱️ Estimated Time

**30-40 minutes**

## 📋 Prerequisites

Before starting this lab:

- ✅ **Lab 03 classifiers created** - Custom SIT, EDM, Fingerprints, BundledEntity (from 03-Classification-UI)
- ✅ **Lab 04 auto-labeling policies** - Using classifiers for label application
- ✅ **Lab 05 DLP policies** - Using classifiers for policy enforcement
- ✅ **Test data uploaded** - SharePoint/OneDrive files with SIT detections
- ⏰ **Wait 1-2 hours** after file upload for Data Classification indexing

> **⏰ Indexing Note**: Data Classification updates within 1 hour for new SIT detections. Historical trends require 7+ days of data.

## 🔍 Part 1: SIT Detection Effectiveness (All Classifier Types)

### Navigate to Data Classification

1. Go to [Microsoft Purview Compliance Portal](https://compliance.microsoft.com)
2. Navigate to **Data classification** → **Overview**
3. Review the dashboard showing:
   - **Top sensitive info types**
   - **Locations with sensitive data**
   - **Items with sensitive data by workload**

> **💡 Dashboard Overview**: Data Classification provides a comprehensive view of all SIT detections across the tenant, regardless of labeling or DLP policy status.

### View Built-In SIT Detections

**Review built-in SIT usage:**

- Click **Sensitive info types** tab
- Sort by **Count** (descending) to see most detected SITs
- Review the top built-in SITs

**Expected Built-In SIT Detections**:

| SIT Name | Expected Count | Primary Use | Workloads |
|----------|----------------|-------------|-----------|
| **Credit Card Number** | 150-200 detections | Auto-labeling, DLP (PCI-DSS) | SharePoint, OneDrive, Exchange |
| **U.S. Social Security Number (SSN)** | 100-150 detections | Auto-labeling, DLP (PII) | SharePoint, OneDrive |
| **ABA Routing Number** | 50-75 detections | DLP (PCI-DSS bundling) | SharePoint, OneDrive |
| **Email Address** | 200-300 detections | DLP (Customer List bundling) | All workloads |

> **🎯 Volume Expectations**: Built-in SITs detect highest volumes due to broad usage across test data

### View Custom SIT Detections

**Analyze custom classifier usage:**

- In **Sensitive info types** tab, filter by **Type**: Custom
- Review custom SITs created in Lab 03

**Expected Custom SIT Detections**:

| Custom SIT | Expected Count | Pattern | Used In |
|------------|----------------|---------|---------|
| **Retail Loyalty ID** | 80-120 detections | RET-XXXXXX-X | Auto-labeling (Customer List), DLP (Loyalty Card Protection) |

> **💡 Custom SIT Effectiveness**: Custom SITs should show high precision (low false positives) due to specific regex patterns

### View EDM Classifier Detections

**Review exact data match performance:**

- In **Sensitive info types** tab, look for **Retail Customer PII** (EDM classifier)
- Click to view detection details

**Expected EDM Detections**:

| EDM Schema | Expected Count | Match Type | Used In |
|------------|----------------|------------|---------|
| **Retail Customer PII** | 40-60 detections | Exact match (Email + Phone + DOB) | DLP (PII Data Protection bundling) |

> **🎯 EDM Precision**: EDM should show very high confidence (95-100%) with near-zero false positives due to exact database matching

### View Document Fingerprint Detections

**Analyze fingerprint-based classification:**

- In **Sensitive info types** tab, look for fingerprint classifiers:
  - **Credit Card Application Form**
  - **Employee Onboarding Form**
- Click to view detection details

**Expected Fingerprint Detections**:

| Fingerprint | Expected Count | Document Type | Used In |
|-------------|----------------|---------------|---------|
| **Credit Card Application Form** | 15-25 detections | Blank and filled versions | Auto-labeling (Standard Forms), DLP (Document Forms) |
| **Employee Onboarding Form** | 10-20 detections | HR standardized form | Auto-labeling (Standard Forms), DLP (Document Forms) |

> **💡 Fingerprint Accuracy**: Fingerprints show high confidence for exact document matches, lower for variations (handwritten, scanned)

### View BundledEntity SIT Detections

**Review bundled entity classifier usage:**

- Look for BundledEntity SITs from Lab 03:
  - **All Full Names**
  - **All Physical Addresses**
  - **All Medical Terms**
- Click to view detection volumes

**Expected BundledEntity Detections**:

| BundledEntity SIT | Expected Count | Detection Logic | Used In |
|-------------------|----------------|-----------------|---------|
| **All Full Names** | 200-300 detections | Person name patterns | Auto-labeling (Contact Data), DLP (PII bundling) |
| **All Physical Addresses** | 180-250 detections | Address formats | Auto-labeling (Contact Data), DLP (PII bundling) |
| **All Medical Terms** | 0-5 detections | Medical terminology | Acknowledged but not tested (retail focus) |

> **🎯 BundledEntity Volume**: BundledEntity SITs detect high volumes due to aggregating multiple sub-classifiers (first name + last name, etc.)

## 📊 Part 2: Classifier Usage Analysis and False Positive Review

### Analyze SIT Usage by Policy

**Cross-reference SIT detections with policy usage:**

1. In **Sensitive info types** tab, select a SIT (e.g., **Credit Card Number**)
2. View **Used in** section showing:
   - Auto-labeling policies
   - DLP policies
   - Retention policies (if applicable)

**Expected Policy Usage**:

| SIT | Auto-Labeling Policies | DLP Policies | Total Policies |
|-----|------------------------|--------------|----------------|
| **Credit Card Number** | Auto-Label PII, High-Risk Data | PCI-DSS Protection, External Sharing Control | 4 policies |
| **U.S. SSN** | Auto-Label PII, High-Risk Data | PII Data Protection, External Sharing Control | 4 policies |
| **Retail Loyalty ID** | Customer List, High-Risk Data | Loyalty Card Protection, Marketing List Protection | 4 policies |
| **All Full Names** | Contact Data | PII Data Protection (bundled) | 2 policies |

> **💡 Policy Consolidation**: High-usage SITs indicate critical classifiers that warrant careful monitoring and tuning

### Review False Positive Rates

**Identify false positive patterns:**

1. Navigate to **Data classification** → **Content explorer**
2. Select files labeled with low-sensitivity labels (e.g., **General**)
3. Check for unexpected SIT detections

**False Positive Indicators**:

| File Type | Unexpected SIT | Likely Cause | Tuning Action |
|-----------|----------------|--------------|---------------|
| **Test documentation** | Credit Card Number | Sample card numbers in docs (4111-1111-1111-1111) | Add exceptions for test patterns |
| **Phone directories** | U.S. SSN | Phone numbers misidentified (xxx-xx-xxxx format) | Increase confidence level to Medium-High |
| **Address books** | Full Names | Every contact entry (expected) | No action (correct detection) |
| **Marketing templates** | Email Address | Template variables ({email}) | Add exceptions for template syntax |

**False Positive Rate Calculation**:

- **Total SIT Detections**: Count from Data Classification overview
- **False Positives**: Manual review of sample files (10-20 files per SIT)
- **False Positive Rate**: (False Positives / Sample Size) × 100
- **Acceptable Rate**: <5% for production, <10% for initial deployment

**Action Items**:

- [ ] Document false positives by SIT type
- [ ] Increase instance count for high-volume false positive SITs
- [ ] Add exceptions for known false positive patterns
- [ ] Consider switching from built-in SITs to custom SITs for higher precision

## 🔗 Part 3: Top SIT Combinations and Bundling Effectiveness

### View Top SIT Combinations

**Analyze which SITs frequently appear together:**

1. In **Content explorer**, select a label created by bundled policy (e.g., **Highly Confidential** from High-Risk Data policy)
2. Drill down to individual files
3. Note which SIT combinations are present

**Expected Bundled Combinations**:

| Bundling Strategy | SITs Present | File Count | False Positive Rate |
|-------------------|--------------|------------|---------------------|
| **High-Risk Data** (CC + SSN + Loyalty all 3) | Credit Card, SSN, Loyalty | 5-10 files | <2% (very high confidence) |
| **Customer List** (Loyalty + Email both) | Loyalty ID, Email Address | 10-15 files | <5% (high confidence) |
| **Contact Data** (Names + Addresses both) | All Full Names, All Physical Addresses | 15-20 files | 5-10% (medium-high confidence) |
| **PCI Data** (CC + ABA both) | Credit Card, ABA Routing | 8-12 files | <3% (very high confidence) |

> **🎯 Bundling Benefits**: Files with multiple SITs (AND conditions) show significantly lower false positive rates compared to single-SIT detections

### Compare Bundled vs Single-SIT Detection Rates

**Calculate detection precision:**

**Single-SIT Policies** (OR condition, lower threshold):

- **Auto-Label PII (Retail)**: Credit Card OR SSN
  - **Total Detections**: 25-35 files
  - **False Positives**: 2-4 files (8-12% rate)
  - **Confidence**: Medium-High

**Bundled-SIT Policies** (AND condition, higher threshold):

- **High-Risk Data (Retail)**: Credit Card AND SSN AND Loyalty (all 3)
  - **Total Detections**: 5-10 files
  - **False Positives**: 0-1 files (<2% rate)
  - **Confidence**: Very High

**Bundling Effectiveness Metrics**:

| Metric | Single-SIT Policies | Bundled-SIT Policies | Improvement |
|--------|---------------------|----------------------|-------------|
| **Detection Volume** | 25-35 files | 5-10 files | 70% reduction (fewer alerts) |
| **False Positive Rate** | 8-12% | <2% | 80-85% reduction |
| **Confidence Level** | Medium-High (80-90%) | Very High (95-100%) | +10-15% confidence |
| **User Impact** | Higher alert fatigue | Lower alert fatigue | Improved user experience |

> **💡 Bundling Trade-offs**: Bundling reduces volume and false positives but may miss some true positives. Balance based on business risk tolerance.

## 📈 Part 4: Sensitive Item Trends and Compliance Posture

### View Sensitive Item Trends Over Time

**Analyze historical detection patterns:**

1. Navigate to **Data classification** → **Overview**
2. Review **Sensitive items over time** chart (7-day, 30-day, 90-day views)
3. Identify trends and anomalies

**Expected Trend Patterns**:

| Time Period | Detection Volume | Trend | Interpretation |
|-------------|------------------|-------|----------------|
| **Week 1** (Day Zero Setup) | Low volume (test data upload) | Baseline established | Initial classifier deployment |
| **Week 2-3** (Labs 03-04) | Medium volume (auto-labeling simulation) | Gradual increase | Policies discovering existing data |
| **Week 4+** (Labs 05-07) | High volume (DLP enforcement) | Plateau or slight decrease | Comprehensive coverage achieved |

> **🎯 Healthy Trend**: Detection volume should plateau after initial discovery phase, indicating policies are covering most sensitive data

### Identify Anomalous Spikes

**Review unusual detection increases:**

- **Sudden Spike**: Large batch of files uploaded with sensitive data
- **Gradual Increase**: Users creating more sensitive content over time
- **Unexpected Drop**: Policy disabled, SIT modified, or data deleted

**Investigation Actions**:

1. Click on spike date in trend chart
2. Review **Top locations** for that period
3. Identify which sites/users contributed to spike
4. Determine if spike is legitimate (bulk upload) or concerning (data leak)

### Compliance Posture Assessment

**Use Data Classification metrics to assess compliance:**

| Metric | Current Value | Target Value | Status |
|--------|---------------|--------------|--------|
| **Total Sensitive Items** | 500-1000+ detections | Comprehensive coverage | ✅ Good |
| **Labeled Items** | 100+ files labeled | 20%+ of sensitive items | ✅ Good |
| **DLP-Protected Items** | 4 policies active | All sensitive workloads | ✅ Good |
| **False Positive Rate** | <5% across all SITs | <10% acceptable, <5% target | ✅ Excellent |
| **Unprotected Sensitive Data** | Detections without label/DLP | <10% of total | 🔄 Monitor |

**Action Items Based on Posture**:

- [ ] **High unprotected data**: Create additional auto-labeling policies
- [ ] **High false positives**: Tune SIT confidence levels or instance counts
- [ ] **Low detection volume**: Upload more test data or expand policy scope
- [ ] **Uneven workload coverage**: Expand DLP policies to all workloads

## 📊 Validation Summary

### Data Classification Key Metrics

After completing all parts of this lab, you should observe:

| Metric | Expected Value | Validation |
|--------|----------------|------------|
| **Total SIT Detections** | 500-1000+ across all SITs | Classifiers actively detecting |
| **Built-In SIT Usage** | 60-70% of total detections | Standard patterns common |
| **Custom SIT Precision** | <5% false positives | Regex patterns accurate |
| **EDM Detection Rate** | 40-60 exact matches | Database integration working |
| **Fingerprint Accuracy** | 95-100% confidence | Document matching effective |
| **BundledEntity Volume** | 200-300 detections | Aggregated classifiers active |
| **Bundling Effectiveness** | 70%+ reduction in false positives | AND conditions working |

> **🎯 Success Criteria**: SITs detecting expected volumes, <5% false positive rate, bundling reducing alert fatigue, comprehensive workload coverage

## 🔍 Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| **SIT count is zero** | Indexing delay or no matching files | Wait 1-2 hours, upload test files with SITs |
| **EDM not detecting** | Schema not uploaded or datastore not indexed | Verify EDM status: `Get-DlpEdmSchema`, wait 1-2 hours |
| **Fingerprint not matching** | Document variation too different | Create multiple fingerprints (blank, filled, scanned) |
| **High false positive rate** | Confidence level too low or instance count too low | Increase to Medium-High confidence, increase instance count (5 → 10) |
| **BundledEntity count very high** | Multiple sub-classifiers aggregating | Expected behavior, tune by increasing confidence |
| **Trend chart shows no data** | Less than 7 days of data collected | Wait 7 days from initial classifier deployment |
| **Custom SIT not appearing** | SIT not published or indexing delay | Publish SIT, wait 1 hour for indexing |
| **Policy usage not showing** | Policy not using the SIT | Verify SIT is added to auto-labeling or DLP policy conditions |

## ✅ Lab Completion Checklist

Before completing the Audit and Validation section, verify:

- [ ] Reviewed all SIT types: built-in, custom, EDM, fingerprints, bundled entities
- [ ] Analyzed detection volumes and false positive rates for each SIT
- [ ] Validated bundled SIT policies show higher confidence and lower false positives
- [ ] Reviewed sensitive item trends over time (if 7+ days of data available)
- [ ] Assessed compliance posture using Data Classification metrics
- [ ] Identified tuning opportunities for high false positive SITs
- [ ] Documented which SITs are most effective for retail scenario detection

## 📚 Next Steps

**Proceed to Lab 08: Exfiltration Simulation** (if available) to test DLP policies with realistic sharing scenarios, or proceed to **IaC-Automation** to automate policy deployment.

**Comprehensive Validation Complete!** You have now validated:
- ✅ **Activity Explorer**: User actions and policy enforcement
- ✅ **Content Explorer**: Labeled content distribution
- ✅ **Data Classification**: SIT effectiveness and false positive analysis

---

*This lab validates Data Classification capabilities for analyzing SIT detection effectiveness and compliance posture across Microsoft 365.*
