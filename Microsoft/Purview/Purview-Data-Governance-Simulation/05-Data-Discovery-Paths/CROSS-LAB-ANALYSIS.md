# Cross-Lab Analysis Configuration Guide

## 📋 Overview

The cross-lab analysis orchestrator compares results from multiple Lab 05 discovery methods to understand accuracy differences, detection patterns, and method strengths/weaknesses. This guide explains how to configure and run comprehensive comparisons using the `lab05-comparison-config.json` configuration file.

---

## 🎯 Why Compare Discovery Methods?

**Understanding Accuracy Trade-offs**:

- **Lab 05a (PnP regex)**: 70-90% accuracy - fast but approximate
- **Lab 05b (eDiscovery)**: 100% accuracy - official Purview SITs with 24-hour wait
- **Lab 04 (On-Demand)**: 100% accuracy - comprehensive portal-based scan with 7-day wait
- **Labs 05c/05d (Graph/SharePoint Search)**: 100% accuracy - automated with 7-14 day indexing

**Validation Use Cases**:

- Validate Lab 05a regex patterns against official Purview SIT detection
- Identify false positives (Lab 05a detected but eDiscovery didn't)
- Identify false negatives (eDiscovery detected but Lab 05a missed)
- Understand which files are consistently detected across all methods
- Measure accuracy improvements from regex to official SITs

---

## 🚀 Quick Start (No Configuration Needed)

For simple comparisons without customization:

```powershell
# Navigate to Lab 05 directory
cd "Microsoft\Purview\Purview-Data-Governance-Simulation\05-Data-Discovery-Paths"

# Auto-detect all completed labs and generate comparison
.\scripts\Invoke-CrossLabAnalysis.ps1

# Generate HTML report with visualizations
.\scripts\Invoke-CrossLabAnalysis.ps1 -GenerateHtmlReport
```

The script automatically:
- Searches for completed lab reports in default locations
- Compares all available discovery methods
- Generates console output and CSV summary
- Requires minimum 2 completed labs

---

## ⚙️ Configuration File Structure

The `lab05-comparison-config.json` file provides advanced control over comparison analysis. Edit this file to customize which labs are compared, apply filters, and control output formats.

### Configuration Sections

| Section | Purpose | Common Use Cases |
|---------|---------|------------------|
| **comparisonSettings** | Enable/disable labs, output formats | Compare only specific methods |
| **reportPaths** | Customize search locations | Non-standard report directories |
| **analysisOptions** | Toggle analysis features | Focus on specific metrics |
| **filterOptions** | Filter by SIT type, location, date | Targeted analysis scenarios |
| **outputSettings** | Control report generation | Custom output directories |
| **comparisonThresholds** | Set accuracy/alert thresholds | Custom success criteria |
| **schemaMapping** | CSV field name mappings | Custom report formats |

---

## 📝 Common Configuration Scenarios

### Scenario 1: Compare Only Lab 05a and Lab 05b

**Use Case**: Quick validation of regex accuracy against official Purview SITs (24-hour results)

**Configuration** (`lab05-comparison-config.json`):

```json
{
  "comparisonSettings": {
    "enabledLabs": {
      "lab05a": true,
      "lab05b": false,
      "lab05c": false,
      "lab05d": false
    "generateHtmlReport": true
  }
}
```

**Run**:

```powershell
.\scripts\Invoke-CrossLabAnalysis.ps1 -UseConfig
```

---

### Scenario 2: Analyze Only High-Priority SIT Types

**Use Case**: Focus comparison on most critical sensitive information types (SSN, Credit Cards, Bank Accounts)

**Configuration**:

```json
{
  "comparisonSettings": {
    "enabledLabs": {
      "lab05a": true,
      "lab05b": true,
      "lab05c": true,
      "lab05d": true
  },
  "filterOptions": {
    "sitTypeFilter": {
      "enabled": true,
      "includedTypes": [
        "U.S. Social Security Number (SSN)",
        "Credit Card Number",
        "U.S. Bank Account Number"
      ]
    }
  }
}
```

**Run**:

```powershell
.\scripts\Invoke-CrossLabAnalysis.ps1 -UseConfig -GenerateHtmlReport
```

---

### Scenario 3: Compare Specific SharePoint Sites Only

**Use Case**: Site-specific comparison for high-risk departments (HR, Finance, Legal)

**Configuration**:

```json
{
  "comparisonSettings": {
    "enabledLabs": {
      "lab05a": true,
      "lab05b": true,
      "lab05c": true,
      "lab05d": true,
      "lab04": false
    }
  },
  "filterOptions": {
    "locationFilter": {
      "enabled": true,
      "includedSites": [
        "HR-Simulation",
        "Finance-Simulation",
        "Legal-Simulation"
      ]
    }
  }
}
```

**Run**:

```powershell
.\scripts\Invoke-CrossLabAnalysis.ps1 -UseConfig
```

---

### Scenario 4: Time-Based Comparison (Recent Detections Only)

**Use Case**: Compare only recent detections within specific date range

**Configuration**:

```json
{
  "filterOptions": {
    "dateRangeFilter": {
      "enabled": true,
      "startDate": "2025-11-01",
      "endDate": "2025-11-18"
    }
  }
}
```

**Run**:

```powershell
.\scripts\Invoke-CrossLabAnalysis.ps1 -UseConfig
```

---

### Scenario 5: High-Confidence Detections Only

**Use Case**: Filter to only high-confidence detections (75%+ confidence) for compliance reporting

**Configuration**:

```json
{
  "filterOptions": {
    "confidenceThreshold": {
      "enabled": true,
      "minimumConfidence": 75
    }
  },
  "outputSettings": {
    "reportPrefix": "High-Confidence-Analysis"
  }
}
```

**Run**:

```powershell
.\scripts\Invoke-CrossLabAnalysis.ps1 -UseConfig
```

---

### Scenario 6: Combined Filtering (High-Priority SITs in HR and Finance)

**Use Case**: Laser-focused analysis on SSN/Credit Cards in HR and Finance departments only

**Configuration**:

```json
{
  "comparisonSettings": {
    "enabledLabs": {
      "lab05a": true,
      "lab05b": true,
      "lab05c": false,
      "lab05d": false,
      "lab04": true
    },
    "generateHtmlReport": true
  },
  "filterOptions": {
    "sitTypeFilter": {
      "enabled": true,
      "includedTypes": [
        "U.S. Social Security Number (SSN)",
        "Credit Card Number"
      ]
    },
    "locationFilter": {
      "enabled": true,
      "includedSites": [
        "HR-Simulation",
        "Finance-Simulation"
      ]
    },
    "confidenceThreshold": {
      "enabled": true,
      "minimumConfidence": 80
    }
  },
  "outputSettings": {
    "reportPrefix": "HR-Finance-HighRisk-Analysis"
  }
}
```

**Run**:

```powershell
.\scripts\Invoke-CrossLabAnalysis.ps1 -UseConfig
```

---

## 🔧 Configuration Reference

### Comparison Settings

```json
{
  "comparisonSettings": {
    "enabledLabs": {
      "lab05a": true,    // PnP Direct File Access (regex)
      "lab05b": true,    // eDiscovery Compliance Search (24hr)
      "lab05c": true,    // Graph API Discovery (7-14 days)
      "lab05d": true,    // SharePoint Search (7-14 days)
      "lab04": true      // On-Demand Classification (7 days)
    },
    "minimumLabsRequired": 2,
    "autoDetectReports": true,
    "generateHtmlReport": false,
    "generateDetailedCsvReport": true
  }
}
```

**Properties**:

- `enabledLabs`: Enable (`true`) or disable (`false`) specific labs from comparison
- `minimumLabsRequired`: Minimum number of completed labs needed (default: 2)
- `autoDetectReports`: Auto-search report folders vs explicit paths (default: `true`)
- `generateHtmlReport`: Create HTML visualization report (default: `false`)
- `generateDetailedCsvReport`: Generate detailed CSV summary (default: `true`)

---

### Report Paths

```json
{
  "reportPaths": {
    "lab05a": {
      "enabled": true,
      "searchPattern": "PnP-Discovery-*.csv",
      "defaultPath": ".\\05a-PnP-Direct-File-Access\\reports\\",
      "useLatestReport": true,
      "explicitPath": null
    }
  }
}
```

**Properties per lab**:

- `enabled`: Include this lab in comparison (overridden by `comparisonSettings.enabledLabs`)
- `searchPattern`: File pattern to match (wildcards supported)
- `defaultPath`: Directory to search for reports
- `useLatestReport`: Use most recent file (`true`) or fail if multiple found (`false`)
- `explicitPath`: Override auto-detection with specific file path (default: `null`)

---

### Filter Options

#### SIT Type Filter

```json
{
  "filterOptions": {
    "sitTypeFilter": {
      "enabled": false,
      "includedTypes": [
        "U.S. Social Security Number (SSN)",
        "Credit Card Number",
        "U.S. Bank Account Number",
        "U.S./U.K. Passport Number",
        "U.S. Driver's License Number"
      ]
    }
  }
}
```

**Purpose**: Focus comparison on specific sensitive information types

**Common SIT Types**:
- `"U.S. Social Security Number (SSN)"`
- `"Credit Card Number"`
- `"U.S. Bank Account Number"`
- `"ABA Routing Number"`
- `"U.S./U.K. Passport Number"`
- `"U.S. Driver's License Number"`
- `"ITIN"`
- `"IBAN"`

#### Location Filter

```json
{
  "filterOptions": {
    "locationFilter": {
      "enabled": false,
      "includedSites": [
        "HR-Simulation",
        "Finance-Simulation",
        "Legal-Simulation"
      ]
    }
  }
}
```

**Purpose**: Analyze specific SharePoint sites only

**Site Names**: Use exact site names from Lab 03 content distribution (HR-Simulation, Finance-Simulation, Legal-Simulation, IT-Simulation, Marketing-Simulation)

#### Date Range Filter

```json
{
  "filterOptions": {
    "dateRangeFilter": {
      "enabled": false,
      "startDate": "2025-11-01",
      "endDate": "2025-11-18"
    }
  }
}
```

**Purpose**: Compare detections within specific timeframe

**Date Format**: `"YYYY-MM-DD"` (ISO 8601)

#### Confidence Threshold

```json
{
  "filterOptions": {
    "confidenceThreshold": {
      "enabled": false,
      "minimumConfidence": 75
    }
  }
}
```

**Purpose**: Filter to high-confidence detections only

**Confidence Levels**:
- `85-100`: High confidence (strong pattern match with context validation)
- `75-84`: Medium-high confidence (good pattern match)
- `60-74`: Medium confidence (pattern match with some ambiguity)
- `< 60`: Low confidence (weak pattern match)

---

### Output Settings

```json
{
  "outputSettings": {
    "outputDirectory": ".\\reports",
    "reportPrefix": "Cross-Lab-Analysis",
    "timestampFormat": "yyyy-MM-dd-HHmmss",
    "csvDelimiter": ",",
    "includeRawData": false,
    "compressOldReports": false
  }
}
```

**Properties**:

- `outputDirectory`: Directory for report output (relative or absolute path)
- `reportPrefix`: Prefix for report filenames (useful for categorizing analyses)
- `timestampFormat`: PowerShell date format string for report timestamps
- `csvDelimiter`: CSV field delimiter (`,` or `;` or `\t`)
- `includeRawData`: Include full normalized data in CSV export (default: `false`)
- `compressOldReports`: Auto-compress reports older than 30 days (default: `false`)

---

### Comparison Thresholds

```json
{
  "comparisonThresholds": {
    "accuracyWarningThreshold": 60,
    "accuracyTargetThreshold": 80,
    "overlapMinimumPercentage": 70,
    "falsePositiveAlertThreshold": 20
  }
}
```

**Purpose**: Define success criteria and alert thresholds

**Properties**:

- `accuracyWarningThreshold`: Trigger warning if Lab 05a accuracy below this % (default: 60)
- `accuracyTargetThreshold`: Target accuracy goal for regex methods (default: 80)
- `overlapMinimumPercentage`: Expected minimum overlap between Purview methods (default: 70)
- `falsePositiveAlertThreshold`: Alert if false positives exceed this % (default: 20)

---

### Visualization Settings

```json
{
  "outputSettings": {
    "csvOutput": {
      "enabled": true,
      "outputPath": ".\\reports\\cross-lab-comparison.csv"
    },
    "htmlReport": {
      "enabled": false,
      "includeCharts": true,
      "includeDetailedTables": true,
      "theme": "light"
    }
  }
}
```

**HTML Report Options**:

- `enabled`: Generate HTML visualization (can also use `-GenerateHtmlReport` flag)
- `includeCharts`: Include visualization charts (requires HTML enabled)
- `includeDetailedTables`: Include detailed comparison tables
- `theme`: Visual theme (`"light"` or `"dark"`)

---

### Schema Mapping

```json
{
  "schemaMapping": {
    "lab05a": {
      "fileNameField": "FileName",
      "sitTypeField": "SITType",
      "locationField": "SiteUrl",
      "confidenceField": "Confidence"
    },
    "lab05b": {
      "fileNameField": "Subject/Title",
      "sitTypeField": "Sensitive Information Types",
      "locationField": "Location",
      "confidenceField": null
    }
  }
}
```

**Purpose**: Map CSV column names to normalized fields for comparison

**Use Case**: Customize if you've modified report CSV structures or column names

**Standard Mappings**:
- `fileNameField`: Column containing file/document name
- `sitTypeField`: Column containing sensitive information type
- `locationField`: Column containing SharePoint site/location
- `confidenceField`: Column containing confidence percentage (null if not available)

---

## 📊 Expected Comparison Results

### Typical Patterns (Lab 05a vs Lab 05b)

| Metric | Expected Value | Interpretation |
|--------|----------------|----------------|
| **Lab 05a Accuracy** | 70-90% | Regex-based detection matches official SITs |
| **Overlap Count** | 70-90% of Lab 05a | Files correctly detected by both methods |
| **False Positives** | 5-15% of Lab 05a | Regex over-detected patterns without context |
| **False Negatives** | 10-30% missed | Regex patterns missed SIT variations |
| **Lab 05b Additional** | 10-20% more files | Official SITs catch what regex missed |

### Example Output

```text
🔍 Step 1: Lab Completion Detection
====================================
📋 Checking Lab 05a (PnP Direct File Access)...
   ✅ Lab 05a results auto-detected: PnP-Discovery-2025-11-18-143022.csv
📋 Checking Lab 05b (eDiscovery Compliance Search)...
   ✅ Lab 05b results auto-detected: Results.csv
📋 Lab 05c disabled in configuration (skipping)

✅ Found 2 completed labs for comparison

🎯 Accuracy Analysis (Lab 05a vs Purview Methods)
==================================================
📊 Comparing Lab05a (regex) vs Lab05b (Purview SITs)
   True Positives: 38 files (correctly detected by regex)
   False Positives: 7 files (regex detected, Purview didn't)
   False Negatives: 14 files (Purview detected, regex missed)
   Accuracy: 84.4%
   Precision: 84.4%
   Recall: 73.1%
```

---

## 🎯 Interpreting Results

### High Accuracy (80-90%)

**Meaning**: Regex patterns closely match official Purview SIT detection

**Action**: Lab 05a provides reliable interim results while waiting for official scans

**Use Cases**: Learning environment, immediate discovery needs, pattern validation

### Moderate Accuracy (60-79%)

**Meaning**: Regex patterns capture core SITs but miss variations

**Action**: Use Lab 05a for quick discovery, validate with Lab 05b/04 for compliance

**Improvement**: Refine regex patterns based on false negative analysis

### Low Accuracy (<60%)

**Meaning**: Significant divergence between regex and official SIT detection

**Action**: Rely on Purview SIT methods (05b/c/d) for accurate counts

**Investigation**: Review false positives/negatives to understand pattern gaps

---

### eDiscovery Detections > PnP Detections

**Cause**: PnP regex patterns missed some SIT variations (false negatives)

**Examples**:
- SSN format variations (with/without dashes, spaces)
- Credit card numbers with special formatting
- International variations of common SITs

**Impact**: Lab 05a underestimates sensitive data presence

**Mitigation**: Use official Purview SIT methods for compliance reporting

---

### PnP Detections > eDiscovery Detections

**Cause**: PnP regex over-detected patterns without proper validation (false positives)

**Examples**:
- Number sequences that look like SSNs but fail checksum validation
- Credit card patterns that don't match valid issuer ranges
- Dates or IDs misidentified as SITs

**Impact**: Lab 05a overestimates sensitive data presence

**Mitigation**: Review false positives to refine regex patterns

---

### Files Detected by All Methods

**Meaning**: High-confidence sensitive data detections across all approaches

**Characteristics**:
- Clear, unambiguous SIT patterns
- Standard formatting
- Strong context indicators

**Action Priority**: Focus remediation efforts on these files first (verified across methods)

---

## 🛠️ Troubleshooting

### Issue: "Insufficient data: Need at least 2 completed labs"

**Cause**: Fewer than 2 labs have completed reports available

**Solution**:
1. Complete at least 2 Lab 05 paths (05a, 05b, 05c, 05d)
2. Verify report files exist in expected locations
3. Check `enabledLabs` configuration (ensure at least 2 are `true`)
4. Verify file paths in `reportPaths` configuration

---

### Issue: "Configuration file not found"

**Cause**: `lab05-comparison-config.json` not in expected location

**Solution**:
1. Verify config file exists in Lab 05 root directory
2. Use `-ConfigPath` parameter to specify custom location:
   ```powershell
   .\scripts\Invoke-CrossLabAnalysis.ps1 -UseConfig -ConfigPath ".\path\to\config.json"
   ```
3. Run without `-UseConfig` to use command-line parameters instead

---

### Issue: "Failed to load CSV: Column not found"

**Cause**: CSV structure doesn't match expected schema mapping

**Solution**:
1. Review CSV file structure (column names)
2. Update `schemaMapping` in config file to match actual column names
3. Ensure CSV files are properly exported (not truncated or corrupted)

---

### Issue: No results after applying filters

**Cause**: Filters too restrictive (no detections match all criteria)

**Solution**:
1. Review filter settings in `filterOptions`
2. Disable filters one at a time to identify which is too restrictive
3. Expand SIT type list or location list
4. Adjust confidence threshold lower
5. Widen date range

---

## 📁 Output Files

### CSV Report: `Cross-Lab-Analysis-YYYY-MM-DD-HHMMSS.csv`

**Location**: `.\reports\`

**Contents**:
- Lab name and detection method
- Total detections per lab
- Unique files per lab
- Report generation date

**Use**: Import into Excel for further analysis

---

### HTML Report: `Cross-Lab-Analysis-YYYY-MM-DD-HHMMSS.html`

**Location**: `.\reports\`

**Contents** (when `-GenerateHtmlReport` enabled):
- Executive summary with key metrics
- Detection comparison tables
- Accuracy statistics (if regex labs included)
- SIT distribution charts
- Detailed findings and recommendations

**Use**: Share with stakeholders, embed in documentation

---

## 🎓 Next Steps

1. **Quick Test**: Run orchestrator without configuration to see auto-detection in action
2. **Review Config**: Open `lab05-comparison-config.json` and review available settings
3. **Customize**: Edit configuration based on your specific analysis needs
4. **Run Comparison**: Execute `.\scripts\Invoke-CrossLabAnalysis.ps1 -UseConfig`
5. **Analyze Results**: Review console output, CSV report, and optional HTML visualization
6. **Refine**: Adjust filters and settings based on initial findings

---

## 🤖 AI-Assisted Content Generation

This cross-lab analysis configuration guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview comparison methodologies, data analysis best practices, and configuration-driven automation standards.

*AI tools were used to enhance productivity and ensure comprehensive coverage of cross-lab analysis configuration while maintaining technical accuracy and reflecting enterprise-grade sensitive data discovery comparison standards.*
