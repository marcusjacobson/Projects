# Microsoft Sentinel Watchlist CSV Validation Test Suite

This folder contains comprehensive CSV test files for validating the watchlist deployment pipeline. Each file tests specific validation scenarios to ensure robust data quality and pipeline reliability.

## 📁 Test File Categories

### ✅ **Valid Files (Pipeline Success)**

These files should pass all validation checks and deploy successfully:

| File | Description | Data Types Tested |
|------|-------------|-------------------|
| `valid-watchlist.csv` | Perfect CSV with clean data | Email, String, Boolean, Number, DateTime, IP Address |
| `valid-semicolon-delimiter.csv` | Uses semicolon (`;`) as delimiter | Automatic delimiter detection |
| `valid-tab-delimiter.csv` | Uses tab delimiter | Tab-separated values |
| `valid-all-data-types.csv` | Comprehensive data type coverage | All supported types: Email, String, Boolean, Number, Decimal, GUID, DateTime, URL, IP Address |

### 🔴 **Critical Error Files (Pipeline Failure)**

These files contain critical validation errors that will **stop pipeline deployment**:

| File | Error Type | Expected Error Message | Description |
|------|------------|----------------------|-------------|
| `error-consecutive-delimiters.csv` | Duplicate Delimiters | "Consecutive delimiters detected (',,') indicating empty fields" | Contains `,,` indicating missing data |
| `error-leading-delimiter.csv` | Malformed Structure | "Line starts or ends with delimiter" | Row begins with comma |
| `error-trailing-delimiter.csv` | Malformed Structure | "Line starts or ends with delimiter" | Row ends with comma |
| `error-column-count-mismatch.csv` | Column Inconsistency | "Column count mismatch - expected X columns but found Y" | Rows have different column counts |
| `error-duplicate-headers.csv` | Header Duplication | "Duplicate column header" | Same column name appears twice |
| `error-value-too-long.csv` | Value Length | "Value exceeds 8000 characters" | Cell value too large for Sentinel |
| `error-empty-file.csv` | Empty File | "CSV file is empty" | Completely empty file |
| `error-no-data-rows.csv` | No Data | "CSV contains no data rows" | Only headers, no data |
| `error-malformed-quotes.csv` | CSV Syntax | "Failed to parse CSV" | Unmatched quote characters |

### 🟡 **Warning Files (Pipeline Continues)**

These files contain data quality issues but will **allow deployment to proceed**:

| File | Warning Type | Expected Warning Message | Description |
|------|-------------|-------------------------|-------------|
| `warning-mixed-data-types.csv` | Data Inconsistency | "Column 'X' has mixed data types (X% consistency)" | Mixed data types in columns |
| `warning-duplicate-emails.csv` | Duplicate Values | "Column 'Email' contains X duplicate Email values" | Duplicate email addresses |
| `warning-duplicate-guids.csv` | Duplicate Values | "Column 'GUID' contains X duplicate GUID values" | Duplicate GUID values |
| `warning-csv-injection.csv` | Security Risk | "Starts with special character (=, +, -, @)" | Potential CSV injection attempts |
| `warning-empty-rows.csv` | Data Quality | "Row X is completely empty" | Completely empty data rows |
| `warning-header-issues.csv` | Header Quality | Various header warnings | Special characters, long names, numeric start |

### 🔄 **Schema Change Files (Force Watchlist Recreation)**

These files test automatic detection of column schema changes that trigger watchlist recreation:

| File | Change Type | Expected Behavior | Description |
|------|-------------|-------------------|-------------|
| `test-column-change.csv` | Column Addition | Watchlist deleted and recreated | Adds `Location` and `EmployeeID` columns |
| `test-column-removed.csv` | Column Removal | Watchlist deleted and recreated | Removes `IsActive` and `Formula` columns |

**Schema Change Detection:** The system automatically compares existing watchlist columns with new CSV columns. If any columns are added, removed, or reordered, the watchlist will be deleted and recreated to maintain data integrity.

## 🧪 **Pipeline Testing Instructions**

Since your deployment pipeline automatically looks for `watchlist.csv` in the Template folder, testing involves replacing the CSV file contents and running the pipeline.

### **🔄 Testing Workflow**

1. **Backup the original CSV**
2. **Replace with test file**
3. **Run pipeline**
4. **Check validation results**
5. **Restore original CSV**

### **1. Testing Valid Files**
```powershell
# Backup original and test a valid file
Copy-Item ".\Template\watchlist.csv" ".\Template\watchlist.csv.backup"
Copy-Item ".\Template\Sample-CSVs\valid-watchlist.csv" ".\Template\watchlist.csv"

# Run your pipeline (example pipeline trigger)
# Pipeline will automatically use .\Template\watchlist.csv

# Restore original file
Move-Item ".\Template\watchlist.csv.backup" ".\Template\watchlist.csv" -Force
```

**Expected Result:** ✅ Pipeline succeeds with clean validation statistics

### **2. Testing Critical Errors**
```powershell
# Backup original and test an error file
Copy-Item ".\Template\watchlist.csv" ".\Template\watchlist.csv.backup"
Copy-Item ".\Template\Sample-CSVs\error-consecutive-delimiters.csv" ".\Template\watchlist.csv"

# Run your pipeline
# Pipeline will automatically detect the error file

# Restore original file
Move-Item ".\Template\watchlist.csv.backup" ".\Template\watchlist.csv" -Force
```

**Expected Result:** 🔴 Pipeline fails with specific error messages

### **3. Testing Warnings**
```powershell
# Backup original and test a warning file
Copy-Item ".\Template\watchlist.csv" ".\Template\watchlist.csv.backup"
Copy-Item ".\Template\Sample-CSVs\warning-mixed-data-types.csv" ".\Template\watchlist.csv"

# Run your pipeline
# Pipeline will process warnings but continue deployment

# Restore original file
Move-Item ".\Template\watchlist.csv.backup" ".\Template\watchlist.csv" -Force
```

**Expected Result:** 🟡 Pipeline succeeds with warning messages

### **🚀 Automated Testing Script**
```powershell
# Quick test script for multiple scenarios
$testFiles = @(
    "valid-watchlist.csv",
    "error-consecutive-delimiters.csv",
    "warning-mixed-data-types.csv"
)

# Backup original
Copy-Item ".\Template\watchlist.csv" ".\Template\watchlist.csv.backup"

foreach ($testFile in $testFiles) {
    Write-Host "Testing: $testFile" -ForegroundColor Yellow
    Copy-Item ".\Template\Sample-CSVs\$testFile" ".\Template\watchlist.csv"
    
    # Trigger your pipeline here
    Write-Host "Pipeline triggered for $testFile - Check results manually" -ForegroundColor Cyan
    Read-Host "Press Enter when pipeline complete to continue to next test"
}

# Restore original
Move-Item ".\Template\watchlist.csv.backup" ".\Template\watchlist.csv" -Force
Write-Host "Original watchlist.csv restored" -ForegroundColor Green
```

## 📊 **Expected Validation Output Examples**

### **Valid File Output:**
```
Validation Statistics:
    Total Rows: 5
    Total Columns: 7
    Empty Fields: 0
    Duplicate Rows: 0
    Data Type Inconsistencies: 0

Detected Data Types by Column:
    'UserPrincipalName': Email (100% consistent)
    'Department': String (100% consistent)
    'IsActive': Boolean (100% consistent)
    'EmployeeID': Number (100% consistent)
```

### **Critical Error Output:**
```
CSV validation failed with the following errors:
    ERROR: Row 3: Consecutive delimiters detected (',,') indicating empty fields - this can cause critical data parsing issues
    ERROR: Row 5: Column count mismatch - expected 3 columns but found 2. This indicates malformed CSV structure.
```

### **Warning Output:**
```
Validation Warnings:
    WARNING: Column 'IsActive' has mixed data types (75% consistency)
    WARNING: Row 2, Column 'Formula': Starts with special character (=)
    WARNING: Column 'Email' contains 2 duplicate Email values
```

### **Column Schema Change Output:**
```
Analyzing watchlist changes before deployment...
    Column schema change detected:
        Existing columns (4): Department, Formula, IsActive, UserPrincipalName
        New columns (5): Department, EmployeeID, IsActive, Location, UserPrincipalName
        Added columns: EmployeeID, Location
        Removed columns: Formula
    Watchlist will be deleted and recreated due to column schema change.

Deploying or updating Sentinel watchlist...
    Column schema change detected. Watchlist will be deleted and recreated.
    Deleting existing watchlist due to: column schema change detected...
```

## 🔧 **Data Type Detection**

The validation system automatically detects these data types:

| Type | Detection Pattern | Example |
|------|------------------|---------|
| **Email** | `user@domain.com` format | `john.doe@company.com` |
| **GUID** | Standard GUID format | `550e8400-e29b-41d4-a716-446655440000` |
| **IP Address** | IPv4 format | `192.168.1.10` |
| **URL** | `http://` or `https://` | `https://www.company.com` |
| **Number** | Integer values | `12345` |
| **Decimal** | Decimal values | `85.5` |
| **Boolean** | `true/false/1/0` | `true` |
| **DateTime** | Parseable date formats | `2024-01-15T10:30:00Z` |
| **String** | Everything else | `IT Department` |

## 🎯 **Testing Checklist**

Use this checklist to validate your team's testing:

- [ ] **Valid Files**: All valid files deploy successfully
- [ ] **Critical Errors**: All error files fail with correct error messages
- [ ] **Warnings**: All warning files deploy with warning messages
- [ ] **Delimiter Detection**: Semicolon and tab delimited files work correctly
- [ ] **Data Type Detection**: Various data types are correctly identified
- [ ] **Statistics Reporting**: Validation statistics appear in pipeline logs
- [ ] **Search Key Validation**: Custom search keys work correctly

## 📝 **Team Testing Notes**

- **Pipeline Logs**: Always check the "Validating Watchlist file..." section for detailed validation output
- **Error Handling**: Critical errors will stop deployment and display specific row/column information
- **Performance**: Validation is optimized for large files with single-pass processing
- **Security**: CSV injection attempts are detected and warned about
- **Flexibility**: System automatically detects delimiter types (comma, semicolon, tab)

## 🚀 **Integration Testing**

For comprehensive testing, create test pipelines that:

1. **Test each file type** in the validation system
2. **Verify error handling** with malformed data
3. **Validate deployment success** with clean data
4. **Check warning reporting** with quality issues
5. **Test search key functionality** with different column selections

---

**Created:** June 13, 2025  
**Purpose:** Microsoft Sentinel Watchlist CSV Validation Testing  
**Framework:** Azure Infrastructure as Code (IaC) Automation Framework
