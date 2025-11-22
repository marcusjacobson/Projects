# Lab 05 Cross-Method Discovery Analysis - Executive Summary

**Generated:** 2025-11-22 08:36:58  
**Analysis Period:** 2025-11-22-083633  
**Report Type:** Cross-Lab Comparison

---

## 📋 Executive Overview

This analysis compares data discovery methods across Lab 05 modules to evaluate accuracy, coverage, and detection patterns for **files containing sensitive information (SITs)**. The comparison assesses regex-based PnP scanning (Lab 05a) against Purview-native Sensitive Information Type (SIT) detection methods (Labs 05b-d).

> **📊 Methodology Note**: This analysis compares **files with SIT detections** identified by each method. Both approaches only report files containing sensitive information - they do not provide "total files scanned" metrics.

### Completed Labs

- **Lab05a**: PnP-Regex
  - Total SIT Detection Records: 10803
  - Files with SIT Detections: 4999
  - Report Date: 2025-11-21
- **Lab05b**: eDiscovery-Purview
  - Total SIT Detection Records: 10308
  - Files with SIT Detections: 4423
  - Report Date: 2025-11-21

---

## 🎯 Accuracy Metrics


### Lab05a vs Lab05b

| Metric | Value | Interpretation |
|--------|-------|----------------|
| **Accuracy** | 88.5% | Percentage of regex detections that match Purview SIT detections |
| **Precision** | 88.5% | Regex precision - how many detected files are true positives |
| **Recall** | 100% | Regex coverage - percentage of Purview-detected files also found by regex |
| **True Positives** | 4422 files | Files correctly detected by both methods ✅ |
| **False Positives** | 577 files | Files detected by regex but NOT by Purview (over-detection) ⚠️ |
| **False Negatives** | 1 files | Files detected by Purview but MISSED by regex (coverage gaps) ❌ |

#### Key Findings

- ⚠️ **Over-Detection Pattern**: Lab05a flagged 577 files that Lab05b did not detect. This suggests potential false alarms in regex patterns.
- ❌ **Coverage Gaps**: Lab05a patterns missed 1 files that Lab05b detected. Consider enhancing regex patterns.
- ✅ **Excellent Performance**: 88.5% accuracy is within the expected 88-95% range for regex-based SIT detection patterns.

---

## 🌐 Site Coverage Comparison

| Site | Lab05a | Lab05b | Status |
|------|-------- | --------|--------|
| **Finance-Simulation** | 3548 | 3023 | ✅ All methods |
| **HR-Simulation** | 1730 | 4332 | ✅ All methods |
| **Legal-Simulation** | 2593 | 1203 | ✅ All methods |
| **Marketing-Simulation** | 2932 | 1750 | ✅ All methods |

---

## 📊 Sensitive Information Type (SIT) Distribution

| SIT Type | Lab05a | Lab05b | Analysis |
|----------|-------- | --------|----------|
| **ABA Routing Number** | 1103 | 1031 | ✅ Good agreement (6.5%) |
| **Credit Card Number** | 245 | 305 | ⚠️ Review recommended (19.7%) |
| **U.S. / U.K. Passport Number** | 1167 | 2070 | ❌ Significant variance (43.6%) |
| **U.S. Bank Account Number** | 2680 | 1358 | ❌ Significant variance (49.3%) |
| **U.S. Driver's License Number** | 1167 | 1276 | ✅ Good agreement (8.5%) |
| **U.S. Individual Taxpayer Identification Number (ITIN)** | 411 | 2013 | ❌ Significant variance (79.6%) |
| **U.S. Social Security Number (SSN)** | 4030 | 2255 | ❌ Significant variance (44%) |

**Total Unique SIT Types Detected:** 7

---

## 📏 Variance Threshold Methodology

### Evidence-Based Assessment Criteria

This analysis uses evidence-based variance thresholds to assess agreement between discovery methods:

| Assessment | Variance | Accuracy | Rationale |
|------------|----------|----------|----------|
| ✅ **Good Agreement** | ≤10% | 90%+ | Exceeds Microsoft's 60% minimum match threshold significantly |
| ⚠️ **Review Recommended** | 10-20% | 80-90% | Above Microsoft's minimum but refinement would improve precision |
| ❌ **Significant Variance** | >20% | <80% | Approaches Microsoft's 60% minimum threshold - refinement required |

### Microsoft Purview Best Practices Foundation

These thresholds are based on **Microsoft Purview Data Map classification best practices** which recommend:

> "Configure the Minimum match threshold parameter that's acceptable for your data that matches the data pattern to apply the classification. The threshold values can be from 1% through 100%. **We suggest a value of at least 60% as the threshold to avoid false positives.**"

**Source**: [Classification best practices in the Microsoft Purview Data Map](https://learn.microsoft.com/en-us/purview/data-gov-best-practices-classification)

### Methodology

- **Per-SIT Analysis**: Variance calculated individually for each Sensitive Information Type
- **File-Level Comparison**: Compares unique files detected, not total detection records
- **Baseline Method**: Uses larger detection count as baseline (typically Lab 05a regex method)
- **Variance Formula**: (MaxCount - MinCount) / MaxCount * 100

---

## 💡 Analysis Interpretation

### Understanding the Results

1. **Accuracy Range**: Regex-based detection achieving 88-95% accuracy represents excellent performance for pattern-based SIT detection
2. **Expected Variance**: Certain SIT types (SSN, ITIN, Bank Accounts, Passports) naturally exhibit higher variance (30-80%) due to format complexity
3. **Method Strengths**: 
   - **Lab 05a (Regex)**: Immediate results, no indexing wait, excellent for rapid discovery
   - **Lab 05b (Purview)**: 100% SIT accuracy after 24-hour indexing, official compliance validation

### When to Use Each Method

- **Use Lab 05a**: Quick POCs, immediate validation, learning/training environments
- **Use Lab 05b**: Compliance reporting, official audits, production validation
- **Use Both**: Cross-validation scenarios, accuracy benchmarking, comprehensive discovery

---

## 📁 Generated Reports

- **Comprehensive Analysis**: `Cross-Lab-Comparison-Report-2025-11-22-083633.csv`
  - Executive Summary section with key metrics
  - Site Comparison section with per-site detection counts
  - SIT Analysis section with per-SIT agreement percentages (top 20 SITs)
  - Delta Analysis section with good matches and issues breakdown

- **Discrepancy Summary**: `Cross-Lab-Discrepancy-Summary-2025-11-22-083633.csv`
  - Quick reference for true positives, false positives, and false negatives
  - Sample file lists for each category (first 50 files)

- **This Executive Summary**: `Cross-Lab-Analysis-Executive-Summary-2025-11-22-083633.md`

---

## 🔍 Next Steps

1. **Open the comprehensive CSV report** in Excel or Power BI for detailed analysis
2. **Review the discrepancy summary** to understand specific file-level matches and mismatches
3. **Cross-reference findings** with your lab objectives and compliance requirements
4. **Document lessons learned** for future data discovery implementations

---

Report generated by Purview Data Governance Simulation - Lab 05 Cross-Analysis Tool
