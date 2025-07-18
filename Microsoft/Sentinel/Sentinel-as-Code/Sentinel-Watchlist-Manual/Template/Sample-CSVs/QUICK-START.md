# Quick Start Guide - CSV Validation Testing

## 🚀 Pipeline Testing (Recommended)

Your pipeline automatically looks for `watchlist.csv`, so testing involves replacing that file and running the pipeline.

### Quick Test Workflow

```powershell
# 1. Backup original file
Copy-Item ".\Template\watchlist.csv" ".\Template\watchlist-backup.csv"

# 2. Replace with test file
Copy-Item ".\Template\Sample-CSVs\valid-watchlist.csv" ".\Template\watchlist.csv"

# 3. Run your pipeline (triggers validation automatically)

# 4. Restore original file after testing
Copy-Item ".\Template\watchlist-backup.csv" ".\Template\watchlist.csv"
```

### Test Different Scenarios

```powershell
# Test valid file (should succeed)
Copy-Item ".\Template\Sample-CSVs\valid-watchlist.csv" ".\Template\watchlist.csv"
# Run pipeline → ✅ Should succeed with clean validation

# Test error file (should fail)  
Copy-Item ".\Template\Sample-CSVs\error-consecutive-delimiters.csv" ".\Template\watchlist.csv"
# Run pipeline → 🔴 Should fail with specific error

# Test warning file (should succeed with warnings)
Copy-Item ".\Template\Sample-CSVs\warning-mixed-data-types.csv" ".\Template\watchlist.csv"
# Run pipeline → 🟡 Should succeed with warnings

# Test column schema change (should trigger recreation)
Copy-Item ".\Template\Sample-CSVs\test-column-change.csv" ".\Template\watchlist.csv"
# Run pipeline → 🔄 Should detect column changes and recreate watchlist
```

### Test Column Change Detection Logic

```powershell
# Validate the column change detection logic
cd "c:\REPO\marcusjacobson\IaC-Testing\Sentinel\Sentinel-Watchlist-Manual\Scripts"
.\validate-column-detection.ps1
```

## 🧪 Alternative: Standalone Testing Script

For comprehensive testing without triggering deployment:

```powershell
cd "c:\REPO\marcusjacobson\IaC-Testing\Sentinel\Sentinel-Watchlist-Manual\Scripts"
.\test-validation-suite.ps1
```

### Test Specific Categories

```powershell
# Test only valid files
.\test-validation-suite.ps1 -TestCategory "Valid"

# Test only error files  
.\test-validation-suite.ps1 -TestCategory "Errors"

# Test only warning files
.\test-validation-suite.ps1 -TestCategory "Warnings"
```

## 📂 File Summary (20 Test Files)

### ✅ Valid Files (4) - Should Deploy Successfully

- `valid-watchlist.csv` - Perfect CSV with clean data
- `valid-semicolon-delimiter.csv` - Semicolon delimited  
- `valid-tab-delimiter.csv` - Tab delimited
- `valid-all-data-types.csv` - All data types coverage

### 🔴 Error Files (9) - Should Fail Deployment  

- `error-consecutive-delimiters.csv` - Double commas (,,)
- `error-leading-delimiter.csv` - Row starts with comma
- `error-trailing-delimiter.csv` - Row ends with comma
- `error-column-count-mismatch.csv` - Inconsistent column counts
- `error-duplicate-headers.csv` - Same column name twice
- `error-value-too-long.csv` - Cell value > 8000 characters
- `error-empty-file.csv` - Completely empty
- `error-no-data-rows.csv` - Only headers
- `error-malformed-quotes.csv` - Unmatched quotes

### 🔄 Schema Change Files (2) - Should Trigger Watchlist Recreation

- `test-column-change.csv` - Adds Location & EmployeeID columns
- `test-column-removed.csv` - Removes IsActive & Formula columns

### 🟡 Warning Files (6) - Should Deploy with Warnings

- `warning-mixed-data-types.csv` - Mixed data types in columns
- `warning-duplicate-emails.csv` - Duplicate email addresses
- `warning-duplicate-guids.csv` - Duplicate GUID values
- `warning-csv-injection.csv` - Potential injection (=, +, -, @)
- `warning-empty-rows.csv` - Empty data rows
- `warning-header-issues.csv` - Header quality issues

## 🎯 Expected Results

| Test Type | Pipeline Result | Error/Warning Display |
|-----------|----------------|---------------------|
| **Valid** | ✅ Succeeds | Clean validation stats |
| **Error** | 🔴 Fails | Specific error messages with row numbers |
| **Warning** | 🟡 Succeeds | Warning messages but deployment continues |

---

**Quick Reference Created:** June 13, 2025
