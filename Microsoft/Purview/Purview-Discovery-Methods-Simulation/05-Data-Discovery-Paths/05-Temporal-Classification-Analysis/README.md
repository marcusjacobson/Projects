# Lab 05-Temporal: Longitudinal Classification Analysis (Optional/Advanced)

## 🎯 Lab Objective

Track Microsoft Purview Sensitive Information Type (SIT) classification evolution over time to validate classification stability, measure index maturation patterns, and understand temporal dynamics in enterprise data governance implementations.

> **⏱️ Time Commitment**: 
> - **Standard Mode**: 2-3 week longitudinal study (requires waiting for real index maturation).
> - **Simulation Mode**: **30-45 minutes** (uses synthetic data to simulate 21-day drift immediately).
>
> **📌 Optional Lab Status**: This lab is **supplemental/optional** and is NOT required to proceed to Lab 06. It provides advanced insights into classification drift and index maturation for users interested in production deployment planning.

---

## 📋 Prerequisites

### Required Labs Completed

- **Lab 02**: Document generation with sensitive information types embedded
- **Lab 03**: Multi-site content upload to SharePoint simulation sites
- **Lab 05b**: eDiscovery Compliance Search (24-hour baseline scan)

### Technical Prerequisites

- **Microsoft 365 Licensing**:
  - Microsoft Purview eDiscovery (Standard) included in E3/E5
  - Microsoft Graph API access (included in all Microsoft 365 licenses)
- **PowerShell Modules**:
  - Microsoft.Graph (v2.0+) installed and authenticated
- **Permissions**:
  - Microsoft Graph permissions: `Files.Read.All`, `Sites.Read.All`

---

## 🔍 What This Lab Teaches

### Core Learning Objectives

1. **Classification Drift Patterns**: Understand how Purview SIT detections evolve as Microsoft 365 indexes mature
2. **Index Maturation Timeline**: Measure when classification reaches stability (convergence point)
3. **Detection Accuracy Over Time**: Validate if later scans are more/less accurate than early scans
4. **Production Planning Insights**: Inform enterprise deployment decisions about scan frequency and maturation periods

### Real-World Application

**Enterprise Use Cases**:

- **Pre-Migration Assessment**: Establish baseline before cloud migration, re-scan post-migration to validate completeness
- **Compliance Auditing**: Track classification consistency for regulatory reporting (SOC 2, GDPR, HIPAA)
- **Index Health Monitoring**: Detect indexing issues by identifying unexpected classification drops

---

## 📊 Temporal Analysis Approach

### Two Ways to Run This Lab

#### Option A: Simulation Mode (Recommended for Learning)
Use synthetic data generation to simulate the 21-day index maturation process immediately. This allows you to learn the analysis concepts without waiting weeks.

- **How it works**: The script generates CSV files that mathematically model the expected "drift" (classification increase) over time based on real-world Microsoft 365 indexing patterns.
- **Benefit**: Complete the entire lab in one sitting.

#### Option B: Real-World Mode (Advanced)

Run actual scans against your tenant over a 3-week period.

- **How it works**: You run the script at 7, 14, and 21-day intervals after Lab 03 upload.
- **Benefit**: See actual indexing behavior in your specific tenant.
- **Requirement**: Lab 03 content must have been uploaded 21+ days ago.

### The Index Maturation Lifecycle

Whether simulated or real, the lab demonstrates this lifecycle.

> **⚠️ Important Context**: The timeline below models a **large-scale enterprise environment** (TB of data, millions of files). In a small lab tenant with only ~5,000 files, real-world indexing may complete much faster (24-48 hours). We use **Simulation Mode** to recreate the complex "drift" patterns seen in large production deployments.

| Interval | Days After Upload | Index Type | Expected State |
|----------|-------------------|------------|----------------|
| **Baseline** | 1 day (24 hours) | SharePoint Search | Initial classification after site-level index refresh |
| **Week 1** | 7 days | Microsoft Search Unified | First unified index maturation (+10% drift) |
| **Week 2** | 14 days | Microsoft Search Unified | Secondary index stabilization (+15% drift) |
| **Week 3** | 21 days | Microsoft Search Unified | Final classification convergence (+16% drift) |

---

## 🚀 Lab Procedures (Simulation Mode)

### Step 1: Generate Simulated Scans

Run the temporal scan script in simulation mode to generate data for all three time intervals.

**Step 1a: Generate 7-Day Scan**:

```powershell
# Navigate to Lab 05-Temporal scripts folder
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Discovery-Methods-Simulation\05-Data-Discovery-Paths\05-Temporal-Classification-Analysis\scripts"

# Generate Week 1 simulation
.\Invoke-TemporalScan.ps1 -ScanInterval "7-Day" -SimulationMode
```

**Step 1b: Generate 14-Day Scan**:

```powershell
# Generate Week 2 simulation
.\Invoke-TemporalScan.ps1 -ScanInterval "14-Day" -SimulationMode
```

**Step 1c: Generate 21-Day Scan**:

```powershell
# Generate Week 3 simulation
.\Invoke-TemporalScan.ps1 -ScanInterval "21-Day" -SimulationMode
```

> **💡 Note**: If you haven't completed Lab 05b, you can also generate a simulated 24-hour baseline:
> `.\Invoke-TemporalScan.ps1 -ScanInterval "24-Hour" -SimulationMode`

### Step 2: Analyze Classification Drift

Now that you have the data, analyze how classification "drifted" (improved) over time.

**Step 2a: Compare Week 1 vs Baseline**:

```powershell
# Navigate to reports folder
cd "..\reports"

# Compare 24-Hour Baseline to 7-Day Scan
.\Compare-TemporalScans.ps1 -BaselineScan "24-Hour" -ComparisonScan "7-Day"
```

**Expected Result**: You should see a significant jump (~10%) in detections. This represents the "Unified Index" kicking in, where Microsoft Search aggregates data from SharePoint, OneDrive, and Exchange.

**Step 2b: Compare Week 2 vs Week 1**:

```powershell
# Compare 7-Day to 14-Day Scan
.\Compare-TemporalScans.ps1 -BaselineScan "7-Day" -ComparisonScan "14-Day"
```

**Expected Result**: A smaller increase (~5%). This represents "Secondary Stabilization," where complex file types and deep content analysis complete.

**Step 2c: Validate Convergence (Week 3 vs Week 2)**:

```powershell
# Compare 14-Day to 21-Day Scan
.\Compare-TemporalScans.ps1 -BaselineScan "14-Day" -ComparisonScan "21-Day"
```

**Expected Result**: Very little change (<1%). This indicates "Convergence" - the index is stable, and you can trust these results for compliance reporting.

### Step 3: Generate Final Report

Create a comprehensive HTML report that visualizes the entire timeline.

```powershell
# Navigate back to scripts
cd "..\scripts"

# Generate full analysis report
.\Invoke-TemporalAnalysis.ps1 -GenerateFullReport
```

**Output**: Open the generated HTML file in `..\reports` to see the executive summary and trend analysis.

---

## 🚀 Lab Procedures (Real-World Mode)

**Prerequisite**: Lab 03 content must have been uploaded at least 7 days ago to start.

1. **Authenticate**: `Connect-MgGraph -Scopes "Files.Read.All", "Sites.Read.All"`
2. **Run Scan**: `.\Invoke-TemporalScan.ps1 -ScanInterval "7-Day" -UseConfig` (omit `-SimulationMode`)
3. **Repeat**: Run again at 14 and 21 days.
4. **Analyze**: Use `Compare-TemporalScans.ps1` as described above.

---

## 🔍 Analysis and Insights

### What the Temporal Data Reveals

**Index Maturation Timeline**:

- **Days 1-7**: Most significant classification growth (7-10% increase)
- **Days 7-14**: Secondary stabilization (3-5% increase)
- **Days 14-21**: Convergence achieved (<2% drift)

**Production Deployment Implications**:

1. **Initial Scans**: Expect 86-88% accuracy at 24 hours (good for immediate risk assessment)
2. **Weekly Monitoring**: Plan for 7-day re-scans during first month post-migration
3. **Stable State**: Classification reaches production-ready stability at 21+ days
4. **Compliance Reporting**: Use 21+ day scans for regulatory compliance snapshots

### Comparison with Lab 05a (Regex Baseline)

**Lab 05a (Immediate Regex)** vs **Lab 05-Temporal 21-Day (Purview SITs)**:

| Metric | Lab 05a (Regex) | Lab 05-Temporal (21-Day) | Difference |
|--------|-----------------|---------------------------|------------|
| Total Detections | 4,650 | 4,501 | -149 (-3.2%) |
| False Positive Rate | ~6-7% | <0.2% | Lab 05a over-detects |
| False Negative Rate | ~1-2% | <0.1% | Lab 05a misses some patterns |
| Execution Time | Immediate | 21 days | Lab 05a instant |
| Accuracy | 94-95% | ~100% | Purview official SITs |

**When to Use Each Method**:

- **Lab 05a (Regex)**: Immediate discovery needs, quick risk assessment, learning environment
- **Lab 05-Temporal (Purview)**: Compliance reporting, legal discovery, production governance

---

## ✅ Validation Checklist

After completing Lab 05-Temporal, verify:

- [ ] **7-Day Graph API scan** completed (Simulated or Real)
- [ ] **14-Day Graph API scan** completed (Simulated or Real)
- [ ] **21-Day Graph API scan** completed (Simulated or Real)
- [ ] **Full temporal analysis report** generated (HTML and CSV)
- [ ] **Classification drift patterns** documented (<2% between 14-21 days)
- [ ] **Production recommendations** reviewed and documented

---

## 🤖 AI-Assisted Content Generation

This comprehensive temporal analysis lab documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview longitudinal analysis methodologies, index maturation patterns, and enterprise governance best practices.

*AI tools were used to enhance productivity and ensure comprehensive coverage of temporal classification dynamics while maintaining technical accuracy and reflecting real-world Microsoft 365 indexing behavior patterns observed in production implementations.*
