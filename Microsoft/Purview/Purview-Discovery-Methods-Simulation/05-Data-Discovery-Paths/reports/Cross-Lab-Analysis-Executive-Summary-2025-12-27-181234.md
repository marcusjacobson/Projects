# Lab 05 Cross-Method Discovery Analysis
## Data-Driven Validation of Method Effectiveness Claims

**Generated:** 2025-12-27 18:12:38  
**Analysis Period:** 2025-12-27-181234  
**Report Type:** Cross-Lab Statistical Comparison

---

## 📋 Executive Overview

This analysis provides **statistical evidence** supporting Lab 05 method effectiveness claims by comparing actual detection data from three discovery approaches scanning the **same 5 SharePoint sites**. The data validates accuracy ranges, identifies method-specific strengths/weaknesses, and quantifies trade-offs for stakeholder decision-making.

### Analysis Purpose

✅ **Validates** documented accuracy claims (Lab 05a: 88-95% expected)  
✅ **Quantifies** method effectiveness differences (regex vs Purview SIT engines)  
✅ **Identifies** specific SIT types where methods diverge significantly  
✅ **Supports** informed method selection for different use cases  

> **📊 Data Consistency Confirmed**: All three labs were configured to scan the same 5 SharePoint sites (Finance, HR, Legal, Marketing, IT). Different site coverage in results reflects different detection effectiveness, not different scanning scope. CSVs only include sites where SIT detections were found.

### Methods Analyzed


#### Lab05a: PnP-Regex

- **Files with Sensitive Content**: 780 unique files
- **Total Detection Records**: 1572 SIT instances
- **Sites with Detections**: 3 sites
- **Report Generated**: 2025-12-23


#### Lab05b: eDiscovery-Purview

- **Files with Sensitive Content**: 701 unique files
- **Total Detection Records**: 1015 SIT instances
- **Sites with Detections**: 1 sites
- **Report Generated**: 2025-12-27


#### Lab05c: Graph-API-Purview

- **Files with Sensitive Content**: 754 unique files
- **Total Detection Records**: 1068 SIT instances
- **Sites with Detections**: 3 sites
- **Report Generated**: 2025-12-27

### Data Source Validation

✅ **Consistent Configuration**: All labs configured to scan the same 5 SharePoint sites  
✅ **Same Data Source**: Finance-Simulation, HR-Simulation, Legal-Simulation, Marketing-Simulation, IT-Simulation  
✅ **Different Results Expected**: CSVs only show sites WHERE SIT detections occurred  
✅ **Apples-to-Apples Comparison**: When comparing common files, they originate from identical SharePoint content  

> **Key Finding**: Different site coverage in results demonstrates method effectiveness variations, not configuration differences. Lab 05a may detect SITs in Finance/IT while Purview methods don't (or vice versa).
> **💡 Data Mismatch Analysis**:
> - **File Count**: Lab 05c returned **53 more files** than Lab 05b. This likely reflects **SharePoint indexing updates** occurring between the Lab 05b run and the Lab 05c run.


---

## 🎯 Method Comparison: Speed vs. Accuracy vs. Workflow Trade-offs

### Lab 05a vs Lab 05b vs Lab 05c: Complete Discovery Method Spectrum

**The Trade-off Story:**

You're comparing **all three discovery approaches**: immediate regex (05a), manual portal export (05b), and automated API export (05c). This provides the complete picture of discovery method trade-offs across speed, accuracy, and automation.

#### Comprehensive Timeline Comparison

| Method | Indexing Wait | Processing Time | Workflow | Total Time | Accuracy | Best Use Case |
|--------|---------------|-----------------|----------|------------|----------|---------------|
| **Lab 05a** | None | 60-90 min | PowerShell direct access | **60-90 min** | 88-95% (regex) [Actual: 89.87%] | Immediate learning/interim results |
| **Lab 05b** | 24 hours | 15-30 min | Portal UI → Manual export | **24 hrs + 30 min** | ~100% (Purview) | Fast compliance reports |
| **Lab 05c** | 24 hours | 15-30 min | Graph API → Automated export | **24 hrs + 30 min** | ~100% (Purview) | Automated recurring scans |

#### The Discovery Method Journey

**Phase 1: Immediate Discovery (Lab 05a)**
- **Timeline**: Minutes after document upload
- **Accuracy**: 88-95% with regex patterns
- **Use Case**: Rapid prototyping, learning, interim validation
- **Limitations**: Pattern-based false positives, no context awareness

**Phase 2: Manual Official Validation (Lab 05b)**
- **Timeline**: 24 hours wait + 15-30 minute export
- **Accuracy**: ~100% with Purview SITs
- **Use Case**: One-time compliance reports, audit validation
- **Limitations**: Manual portal workflow

**Phase 3: Automated Official Validation (Lab 05c)**
- **Timeline**: 24 hours wait + 15-30 minute export
- **Accuracy**: ~100% with Purview SITs
- **Use Case**: Recurring automated scans, SIEM integration
- **Limitations**: API complexity

#### Workflow Evolution

| Discovery Path | Timeline | Accuracy | Primary Use Case |
|----------------|----------|----------|------------------|
| **Lab 05a** | Immediate | 88-95% | Rapid validation, time-sensitive investigations |
| **Lab 05b** | 24h wait + 15-30min export | ~100% | Reliable discovery with Purview SITs (Manual) |
| **Lab 05c** | 24h wait + 15-30min export | ~100% | Reliable discovery with Purview SITs (Automated) |

**Trade-off Analysis**: Speed ←→ Accuracy ←→ Automation

#### False Positive/Negative Analysis Across Methods

**Lab 05a False Positives** (regex over-detection):
- Employee IDs matching SSN patterns
- Order numbers matching bank account patterns
- Cannot distinguish US passport (9 digits) from SSN

**Lab 05b/05c Advantages** (over Lab 05a):
- Context-aware Purview SIT engine eliminates pattern-only false positives
- Document classification understands HR vs Financial vs Immigration documents
- ~100% accuracy with official Purview SIT detection

#### Data Structure and File Count Variations

**CSV Format Differences**:
- **Lab 05a**: Custom columns, immediate export
- **Lab 05b/05c**: Identical eDiscovery export format (Items_0.csv)

**Expected File Counts (Medium Scale ~5,000 uploaded)**:
- **Lab 05a**: ~4,650-5,000 files (includes false positives)
- **Lab 05b**: ~4,400 files (Purview ground truth)
- **Lab 05c**: ~4,400 files (Purview ground truth)

> **💡 Cross-Lab Analysis Note**: Lab 05b and 05c both use the official Purview engine. Since Review Set Deduplication is disabled, they should return identical file counts. The observed discrepancy suggests potential issues with the API export completeness or timing.

#### Recommended Usage Strategy

1. **Start with Lab 05a**: Get immediate results for rapid validation (60-90 minutes)
2. **After 24 hours, use Lab 05b**: Validate Lab 05a accuracy with official Purview SITs (Manual)
3. **For ongoing operations, implement Lab 05c**: Automated recurring scans (API)

**Combined Approach Benefits**:
- Immediate interim results from Lab 05a while waiting for indexing
- Official compliance validation from Lab 05b for audits and reporting  
- Long-term automation with Lab 05c for security operations and SIEM integration

---

## 💡 Analysis Interpretation

### Understanding the Results

**Complete Discovery Method Spectrum:**

1. **Lab 05a (Regex)**: 88-95% accuracy, immediate results (60-90 min), manual pattern-based discovery
2. **Lab 05b (Direct Export)**: 100% SIT accuracy, fast export (24hr + 10 min), portal-based official validation
3. **Lab 05c (Graph API)**: 100% SIT accuracy, automated processing (24hr + 30 min), API-driven automation with OCR/threading

**Accuracy Progression:**
- **Lab 05a → Lab 05b**: 5-12% accuracy improvement by eliminating regex false positives
- **Lab 05b → Lab 05c**: Same 100% accuracy (both use Purview SIT engine)

**Method Strengths:**

- **Lab 05a (Regex)**: Immediate results, no indexing wait, excellent for rapid discovery and learning
- **Lab 05b (Direct Export)**: Fast official validation (5-10 min after indexing), simple CSV format, portal-based workflow
- **Lab 05c (Graph API)**: Full API automation, recurring scans, SIEM integration, programmatic access

**When to Use Each Method:**

- **Use Lab 05a**: Learning phase, emergency triage, quick spot checks, immediate validation needs
- **Use Lab 05b**: One-time compliance reports, fast official audits, simple manual workflows
- **Use Lab 05c**: Production phase, recurring automated scans, SIEM integration, legal hold workflows, advanced analytics
- **Recommended Path**: Learn with 05a → Validate with 05b → Automate with 05c

---

## 📁 Generated Reports

- **Comprehensive Analysis**: `Cross-Lab-Comparison-Report-2025-12-27-181234.csv`
  - Executive Summary section with key metrics
  - Site Comparison section with per-site detection counts
  - SIT Analysis section with per-SIT agreement percentages (top 20 SITs)
  - Delta Analysis section with good matches and issues breakdown

- **Discrepancy Summary**: `Cross-Lab-Discrepancy-Summary-2025-12-27-181234.csv`
  - Quick reference for true positives, false positives, and false negatives
  - Sample file lists for each category (first 50 files)

- **This Executive Summary**: `Cross-Lab-Analysis-Executive-Summary-2025-12-27-181234.md`

---

## 🔍 Next Steps

1. **Open the comprehensive CSV report** in Excel or Power BI for detailed analysis
2. **Review the discrepancy summary** to understand specific file-level matches and mismatches
3. **Cross-reference findings** with your lab objectives and compliance requirements
4. **Document lessons learned** for future data discovery implementations

---

Report generated by Purview Discovery Methods Simulation - Lab 05 Cross-Analysis Tool
