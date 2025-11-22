# Lab 2: Exact Data Match (EDM) for Structured Data

Implement database-driven classification using Exact Data Match (EDM) for zero false positives and 99% accuracy with structured sensitive data.

---

## 📋 Lab Summary

**Duration**: 75-90 minutes active work | 30-60 min one-time EDM processing

**Goal**: Master Exact Data Match (EDM) configuration for structured database classification with exact matching, eliminating false positives inherent in regex-based pattern detection.

**Skills**: EDM schema design, secure data hashing, EDMUploadAgent usage, EDM-based custom SIT configuration, accuracy measurement

---

## 🎯 What You'll Learn

✅ Understand when to use EDM vs regex-based custom SITs  
✅ Create EDM schemas for structured employee databases  
✅ Hash sensitive data tables using EdmUploadAgent.exe  
✅ Upload hashed data to Microsoft Purview secure storage  
✅ Configure EDM-based custom SITs for exact matching  
✅ Validate EDM classification accuracy (99% vs regex 85-95%)  
✅ Measure false positive reduction with EDM approach  

---

## 📚 Prerequisites

**Required Access**:

- Microsoft 365 E5 or E5 Compliance license
- Compliance Administrator or Organization Management role
- **Global Administrator or User Administrator** role (for EDM_DataUploaders group setup)
- Microsoft Purview Information Protection access

**Security Group Setup** (one-time requirement):

```powershell
# Navigate to Lab 2 scripts directory
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\02-CustomSITs-EDM\scripts"

# Add your user to EDM_DataUploaders security group (required for data upload)
.\Add-EDMSecurityGroup.ps1
```

> **⏱️ Important**: After running the security group script, wait **15-30 minutes** for Azure AD group membership to propagate before attempting EDM data upload.

**EDMUploadAgent Installation** (one-time requirement):

The `Upload-EDMData.ps1` script can automatically install EDMUploadAgent, but **interactive installation is more reliable**:

- Download: [EdmUploadAgent.msi](https://download.microsoft.com/download/2/1/2/212aa2c0-9f12-4b1b-b729-6619ca0f3db3/EdmUploadAgent.msi)
- Double-click the downloaded MSI file
- Follow the installation wizard (accept all defaults)
- Agent installs to: `C:\Program Files\Microsoft\EdmUploadAgent\`

> **💡 Tip**: The script will attempt automatic installation if EdmUploadAgent is not found, but manual installation is recommended for reliability.

**Technical Requirements**:

- PowerShell 7+ installed
- ExchangeOnlineManagement module v3.4.0+: `Install-Module ExchangeOnlineManagement -Scope CurrentUser`
- Microsoft.Graph module (installed automatically by Add-EDMSecurityGroup.ps1)
- Security & Compliance PowerShell access
- Internet connectivity for EDMUploadAgent.exe download

**Knowledge Prerequisites**:

- CSV file format familiarity
- Basic understanding of data hashing concepts
- PowerShell cmdlet execution experience

**Completed Labs**:

- **Lab 0: Prerequisites & Time-Sensitive Setup** - Provides foundation and sample data
- **Lab 1: Custom SITs (Regex & Keywords)** - Recommended for understanding regex limitations that EDM solves

---

## 🤔 What is Exact Data Match (EDM)?

Exact Data Match (EDM) enables classification based on **exact values from structured databases** rather than pattern matching. This is ideal for:

- Employee databases (SSN, employee number, email, phone)
- Customer records (account numbers, customer IDs, contact information)
- Financial databases (account numbers, transaction IDs, credit card numbers)
- Compliance boundary enforcement (multi-tenant or multi-region data isolation)

### EDM vs. Regex Custom SITs

| Feature | Regex-Based SIT | EDM-Based SIT |
|---------|----------------|---------------|
| **Data Source** | Pattern matching | Database lookup (exact values) |
| **Accuracy** | High (~85-95%) | Very High (~99%) |
| **False Positives** | Moderate | Very Low (near zero) |
| **Setup Complexity** | Low (15-30 min) | High (1-2 hours) |
| **Maintenance** | Pattern updates | Database refreshes (monthly/quarterly) |
| **Ideal Use Case** | Format-based IDs | Structured databases with known values |
| **Scale** | Any size | 1M-100M records optimal |
| **Cost** | Low | Higher (processing and storage) |

### When to Use EDM

**✅ Use EDM when**:

- You have a structured database of sensitive values (employee records, customer lists)
- False positives are unacceptable (regulatory compliance requirements)
- Sensitivity requires exact matching (SSN, credit card numbers from known databases)
- You need compliance boundary enforcement (multi-tenant data isolation)
- Database refresh is manageable (monthly/quarterly updates acceptable)

**❌ Avoid EDM when**:

- Data doesn't exist in structured database format
- Pattern-based detection is sufficient (project codes, purchase orders)
- Database changes too frequently (daily updates required)
- Volume exceeds 100M records (performance degradation)
- Regex-based SIT already provides acceptable accuracy

---

## 📂 Exercise 1: Prepare EDM Source Database

### Step 1: Create Employee Database CSV

Create the employee database CSV file for EDM classification:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\02-CustomSITs-EDM\scripts"
.\Create-EDMSourceDatabase.ps1
```

**Script Actions**:

- Creates `C:\PurviewLabs\Lab2-EDM-Testing\` directory
- Generates `EmployeeDatabase.csv` with 100 employee records
- Columns: EmployeeID, FirstName, LastName, Email, Phone, SSN, Department, HireDate
- Realistic data with proper formatting:
  - Employee IDs: `EMP-####-####` format
  - SSNs: `###-##-####` format (validated checksums)
  - Emails: `firstname.lastname@contoso.com`
  - Phones: `(###) ###-####` format

**Sample Database Structure**:

```csv
EmployeeID,FirstName,LastName,Email,Phone,SSN,Department,HireDate
EMP-1234-5678,Emily,Rodriguez,emily.rodriguez@contoso.com,(206) 555-1234,123-45-6789,Engineering,2020-01-15
EMP-2345-6789,James,Patterson,james.patterson@contoso.com,(503) 555-2345,234-56-7890,Finance,2018-06-01
EMP-3456-7890,Michelle,Chen,michelle.chen@contoso.com,(415) 555-3456,345-67-8901,Marketing,2022-03-10
```

> **⚠️ Production Note**: In real environments, export actual employee data from HRIS systems (Workday, SAP SuccessFactors, ADP) ensuring PII handling compliance. Never store unencrypted SSNs or sensitive data beyond this lab environment.

**CSV File Requirements**:

- **UTF-8 encoding**: Required for EDMUploadAgent compatibility
- **No special characters**: Avoid commas, quotes, newlines within field values
- **Consistent columns**: All rows must have same number of columns
- **Header row required**: First row must contain column names matching schema
- **No empty rows**: Remove blank lines at end of file

---

## 🔐 Exercise 2: Create EDM Schema Definition

### Step 2: Design and Create EDM Schema

Run the EDM schema creation script:

```powershell
# Navigate to Lab 2 scripts directory (if not already there)
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\02-CustomSITs-EDM\scripts"

# Run EDM schema creation
.\Create-EDMSchema.ps1
```

**Script Actions**:

- Creates EDM schema XML file: `EmployeeDatabase_Schema.xml`
- Defines searchable fields (EmployeeID, Email, SSN)
- Configures caseInsensitive matching for email addresses
- Sets up column relationships and data store configuration
- Saves schema to `C:\PurviewLabs\Lab2-EDM-Testing\configs\`

**Schema Configuration**:

```xml
<EdmSchema xmlns="http://schemas.microsoft.com/office/2018/edm">
  <DataStore name="EmployeeDataStore" description="Contoso Employee Database for EDM Classification">
    <Field name="EmployeeID" searchable="true" />
    <Field name="FirstName" searchable="false" />
    <Field name="LastName" searchable="false" />
    <Field name="Email" searchable="true" caseInsensitive="true" />
    <Field name="Phone" searchable="false" />
    <Field name="SSN" searchable="true" />
    <Field name="Department" searchable="false" />
    <Field name="HireDate" searchable="false" />
  </DataStore>
</EdmSchema>
```

### Key EDM Schema Concepts

**Searchable Fields**:

- Columns Purview will match against document content
- EmployeeID, Email, SSN in this example
- Maximum 5 searchable fields recommended for performance
- Choose fields most likely to appear in documents

**Non-Searchable Fields**:

- Supporting data that enriches results but doesn't trigger classification
- FirstName, LastName, Department, HireDate in this example
- Useful for reporting and context but not for matching
- No limit on non-searchable fields

**Case Sensitivity**:

- `caseInsensitive="true"` for Email: `emily.rodriguez@contoso.com` = `Emily.Rodriguez@CONTOSO.COM`
- `caseInsensitive="false"` (default) for SSN: Exact case match required
- Use case-insensitive for fields with variable capitalization

**Data Store**:

- Logical container for related data (one data store per database/CSV file)
- Name must be unique across tenant
- Description helps identify purpose in Purview portal

---

## 📤 Exercise 3: Upload EDM Schema to Purview

### Step 3: Upload EDM Schema

Run the schema upload script:

```powershell
Upload the schema to Microsoft Purview:

```powershell
# Navigate to Lab 2 scripts directory (if not already there)
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\02-CustomSITs-EDM\scripts"

# Upload EDM schema
.\Upload-EDMSchema.ps1 -SchemaPath "C:\PurviewLabs\Lab2-EDM-Testing\configs\EmployeeDatabase_Schema.xml"
```

**Script Actions**:

- Connects to Security & Compliance PowerShell
- Uploads EDM schema using `New-DlpEdmSchema` cmdlet
- Validates schema structure and field definitions
- Registers data store name in Purview
- Prepares system for EDM data ingestion

**Expected Output**:

```text
✅ EDM Schema uploaded successfully
   Data Store Name: EmployeeDataStore
   Searchable Fields: EmployeeID, Email, SSN
   Schema Version: 1
   Status: Active
   Next Step: Download schema and upload employee data
```

**Validation Commands**:

```powershell
# Verify schema upload (view all EDM schemas)
Get-DlpEdmSchema

# Check specific schema details
Get-DlpEdmSchema | Where-Object {$_.DataStoreName -eq "EmployeeDataStore"} | 
    Format-List DataStoreName, Version, Description, CreatedDate, ModifiedDate
```

### Step 3b: Download Purview-Generated Schema (Required)

> **🔑 Critical Step**: EdmUploadAgent requires using the schema **downloaded from Purview** (not the manually created XML). Purview adds required system attributes like `maximumNumberOfTokens` that EdmUploadAgent needs.

**In an Administrator PowerShell terminal**, run these commands:

```powershell
cd "C:\Program Files\Microsoft\EdmUploadAgent"

# Authorize EdmUploadAgent (browser authentication)
.\EdmUploadAgent.exe /Authorize

# Download the Purview-generated schema
.\EdmUploadAgent.exe /SaveSchema /DataStoreName "EmployeeDataStore" /OutputDir "C:\PurviewLabs\Lab2-EDM-Testing\configs"
```

**Expected Output**:

```text
Command completed successfully.
```

**What This Does**:

- Downloads `EmployeeDataStore.xml` from Purview to your configs directory
- This schema includes system-generated attributes required by EdmUploadAgent
- The Upload-EDMData.ps1 script automatically uses this downloaded schema file

> **💡 Schema Versioning Tip**: EDM schemas are versioned. If you need to modify the schema later (add/remove fields), create a new schema version rather than deleting and recreating.
>
> **⚠️ Schema Already Exists**: If you see "data store name already in use", the schema was successfully created in a previous run. Use `Get-DlpEdmSchema | Where-Object {$_.DataStoreName -eq "EmployeeDataStore"}` to verify it exists, download the schema using the commands above, then proceed to Exercise 4 (Upload EDM Data).

---

## 🔒 Exercise 4: Hash and Upload Employee Data

> **📋 Prerequisites Check**: Before proceeding, ensure you have completed the one-time setup tasks in the Prerequisites section:
>
> - ✅ Run `Add-EDMSecurityGroup.ps1` and wait 15-30 minutes for group membership propagation
> - ✅ Install EdmUploadAgent.msi interactively (double-click installer)

### Step 4: Upload EDM Data

> **⚠️ Administrator Privileges Required**: This step requires running PowerShell as Administrator because EdmUploadAgent needs to create log files in protected directories. Right-click PowerShell → **Run as administrator** before proceeding.

Run the EDM data upload script:

```powershell
# Navigate to Lab 2 scripts directory
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\02-CustomSITs-EDM\scripts"

# Upload EDM data using EDMUploadAgent (must run as Administrator)
.\Upload-EDMData.ps1 -DatabasePath "C:\PurviewLabs\Lab2-EDM-Testing\EmployeeDatabase.csv" -DataStoreName "EmployeeDataStore"
```

**Script Actions**:

- Detects or installs EDMUploadAgent.exe from Microsoft
- Authorizes EDMUploadAgent with your Microsoft 365 tenant (if not already authorized)
- Uses the Purview-generated schema file (`EmployeeDataStore.xml`) downloaded in Exercise 3
- Validates CSV file structure matches schema exactly
- Creates hashed version of sensitive data (SHA-256)
- Uploads hashed data to Microsoft Purview secure storage
- Deletes local hashed file after successful upload (security best practice)

> **⏱️ Important**: After successful upload, wait **30-90 minutes** for EDM data indexing to complete before the data becomes active for classification.

**Expected Output**:

```text
✅ EDMUploadAgent found (MSI installation)
✅ CSV validation passed (100 records, 8 columns)
✅ Connected to Security & Compliance PowerShell
✅ Schema found and active
✅ EDMUploadAgent authorized successfully
✅ Data hashing completed (SHA-256)
✅ Upload to Purview completed
⏱️ EDM data will be active in 30-90 minutes
```

### EDM Security Model

**1. Local Hashing**:

```text
Original Value: "123-45-6789" (SSN)
↓
SHA-256 Hashing (local machine)
↓
Hashed Value: "A1B2C3D4E5F6...hash" (irreversible)
```

**2. Encrypted Upload**:

- Hashed data transmitted via TLS 1.3 to Purview
- No plaintext sensitive data ever leaves your environment
- Microsoft never sees original employee data

**3. Secure Storage**:

- Hashed values stored in Microsoft-managed secure enclave
- Encrypted at rest with Microsoft-managed keys
- Isolated per tenant (multi-tenant boundary enforcement)

**4. Comparison Only**:

- Purview compares document content hashes to stored hashes
- Match = classification triggered
- No match = no classification
- Original values never reconstructed

### Upload Process Timeline

```text
⏱️ Data Hashing: 1-5 minutes (depends on record count)
⏱️ Upload to Purview: 5-15 minutes (depends on file size)
⏱️ Purview Indexing: 15-60 minutes (backend processing)
⏱️ Classification Active: 30-90 minutes total from upload start
```

**Expected Output**:

```text
✅ EDMUploadAgent installed successfully
✅ CSV validation passed (100 records, 8 columns)
✅ Data hashing completed (SHA-256)
✅ Upload to Purview completed (2.3 MB)
✅ Local hash file deleted for security
⏱️ EDM data will be active in 30-90 minutes
```

> **⏱️ Timing Note**: EDM data takes 30-90 minutes to become active after upload. Continue to Exercise 5 (EDM SIT creation) while indexing completes in the background.

---

## 🎯 Exercise 5: Configure EDM Custom SIT

### Step 5: Configure EDM Custom SIT

Run the EDM SIT creation script:

```powershell
# Navigate to Lab 2 scripts directory (if not already there)
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\02-CustomSITs-EDM\scripts"

# Create EDM-based SIT
.\Create-EDM-SIT.ps1 -DataStoreName "EmployeeDataStore" -SchemaVersion "1.0"
```

**Script Actions**:

- Creates custom SIT: **Contoso Employee Record (EDM)**
- Links SIT to EmployeeDataStore EDM schema
- Configures primary searchable field (EmployeeID)
- Sets up supporting fields (Email, SSN) for enhanced detection
- Defines confidence levels based on field combinations:
  - **High (95%)**: EmployeeID + SSN + Email match
  - **Medium (85%)**: EmployeeID + any 1 additional field match
  - **Low (75%)**: EmployeeID match only

### EDM Detection Logic

**Document Content Example**:

```text
Employee EMP-1234-5678 with email emily.rodriguez@contoso.com and SSN 123-45-6789
```

**Purview Processing**:

1. **Extract potential values**: `EMP-1234-5678`, `emily.rodriguez@contoso.com`, `123-45-6789`
2. **Hash each value**: SHA-256 transformation locally
3. **Compare hashes to EmployeeDataStore**: Check if hashes exist in uploaded database
4. **Result**: ALL THREE MATCH → High Confidence (95%) classification
5. **Apply label**: "Employee Record - Confidential" (if retention policy configured)

**Partial Match Example**:

```text
Employee EMP-1234-5678 from Engineering department
```

**Processing**:

- Extracted: `EMP-1234-5678`
- Hashed and matched: ✅ Match found
- Additional fields: ❌ No email or SSN found
- Result: Medium Confidence (85%) - EmployeeID only

---

## ✅ Exercise 6: Validate EDM Classification

### Step 6: Create EDM Test Documents and Validate

> **⏱️ Timing Check - Are You Ready?**
>
> Before proceeding with validation, verify sufficient time has passed for EDM data indexing:
>
> ```powershell
> # Check when EDM schema was last modified (indicates data upload completion)
> Get-DlpEdmSchema | Where-Object {$_.DataStoreName -eq "EmployeeDataStore"} | Format-List DataStoreName, Version, ModifiedDate
> ```
>
> **Ready to proceed when**:
>
> - At least **30-60 minutes** have passed since the `ModifiedDate` shown above (when EDM data was uploaded in Exercise 4)
> - Example: If ModifiedDate shows `11/14/2025 12:16:49 PM`, wait until at least `12:46 PM - 1:16 PM` before validation
>
> **If less than 30 minutes have passed**: EDM indexing is likely still in progress. You can create test documents now, but wait the full time before running validation scripts.
>
> > **💡 Note**: Unfortunately, there's no direct command to check EDM indexing status. The indexing happens in the background on Microsoft's servers. The best approach is to wait the recommended 30-60 minutes, then test with a document containing known employee data.

Wait **30-60 minutes** for EDM indexing, then create test documents and validate:

```powershell
# Navigate to Lab 2 scripts directory (if not already there)
cd "C:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\02-CustomSITs-EDM\scripts"

# Create test documents with employee data
.\Create-EDMTestDocuments.ps1 -OutputPath "C:\PurviewLabs\Lab2-EDM-Testing\TestDocs"

# Wait for EDM indexing to complete (30-60 minutes from upload)

# Check EDM status (still in same scripts directory)
Get-DlpEdmSchema | Where-Object {$_.DataStoreName -eq "EmployeeDataStore"}

# Run validation
.\Validate-EDMClassification.ps1 -TestDataPath "C:\PurviewLabs\Lab2-EDM-Testing\TestDocs"
```

**Validation Checks**:

- Queries EDM data store status and record count
- Tests local pattern matching against employee database
- Verifies exact match detection (no false positives from pattern-like data)
- Compares detection accuracy: Regex-based vs. EDM-based
- Generates accuracy report with confidence level breakdown

**Expected Results**:

```text
📊 EDM Classification Validation Results:

✅ EDM Data Store Status:
   Name: EmployeeDataStore
   Records: 100
   Status: Active
   Last Updated: 2025-11-13 14:30:00

✅ Regex-Based SIT (Contoso Employee ID - from Lab 1):
   Total Detections: 150
   False Positives: 12 (8% - pattern matched non-employee IDs like TEMP-1234-5678)
   True Positives: 138 (92%)

✅ EDM-Based SIT (Contoso Employee Record):
   Total Detections: 138
   False Positives: 0 (0% - exact database match only)
   True Positives: 138 (100%)

🎯 Accuracy Improvement: +8% with EDM vs. regex-only approach
🎯 False Positive Elimination: 100% reduction (12 → 0)
```

### Why EDM Eliminates False Positives

**Regex Pattern** (`\bEMP-\d{4}-\d{4}\b`):

- Matches: `EMP-1234-5678` ✅ (valid employee)
- Matches: `EMP-9999-9999` ❌ (doesn't exist in database but matches pattern)
- Matches: `TEMP-1234-5678` ❌ (temporary ID, wrong prefix but similar format)

**EDM Exact Match**:

- Matches: `EMP-1234-5678` ✅ (exists in database)
- Matches: `EMP-9999-9999` ❌ (not in database = no match)
- Matches: `TEMP-1234-5678` ❌ (not in database = no match)

---

## 🔄 Exercise 7: EDM Database Refresh

> **⚠️ Administrator Privileges Required**: This exercise uses EdmUploadAgent.exe which requires running PowerShell as Administrator for hash creation and upload operations.

### Step 7: Update EDM Database

When employee data changes (new hires, terminations, data corrections), refresh EDM database:

```powershell
.\Refresh-EDMData.ps1 -DatabasePath "C:\PurviewLabs\Lab2-EDM-Testing\EmployeeDatabase_Updated.csv" -DataStoreName "EmployeeDataStore"
```

**Refresh Process**:

1. Export updated employee data from HRIS system
2. Validate CSV format matches original schema
3. Hash new data using EDMUploadAgent
4. Upload replaces previous data (not additive)
5. Wait 30-90 minutes for new data to become active

**Refresh Frequency Recommendations**:

| Organization Size | Recommended Frequency | Rationale |
|-------------------|----------------------|-----------|
| **< 500 employees** | Quarterly | Low turnover, minimal data changes |
| **500-5,000 employees** | Monthly | Moderate turnover, regular updates needed |
| **> 5,000 employees** | Bi-weekly or Monthly | High turnover, frequent data corrections |
| **High-security environments** | Weekly | Immediate termination reflection critical |

> **🔐 Security Best Practice**: Automate EDM refresh via scheduled PowerShell script with secure credential storage (Azure Key Vault). Never store plaintext employee data beyond the refresh process.

---

## 📊 Exercise 8: EDM Best Practices

### Advanced EDM Configuration Tips

**1. Optimize Searchable Fields**:

- **Use 3-5 searchable fields maximum** for optimal performance
- **Primary identifier**: EmployeeID (always searchable)
- **Supporting identifiers**: Email, SSN (2-3 additional fields)
- **Avoid searchable fields**: FirstName, LastName (too common, high false positive risk)

**2. Implement Compliance Boundaries**:

For multi-tenant or multi-region deployments:

```xml
<DataStore name="EmployeeDataStore_US" description="US Employee Database">
  <!-- US employee data only -->
</DataStore>

<DataStore name="EmployeeDataStore_EU" description="EU Employee Database">
  <!-- EU employee data with GDPR compliance -->
</DataStore>
```

**3. Monitor EDM Performance**:

```powershell
# Check EDM data store metrics
Get-DlpEdmSchema -DataStoreName "EmployeeDataStore" | 
    Select-Object DataStoreName, RecordCount, LastUpdated, Status

# Review EDM classification activity
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) -Operations "EDMMatch"
```

**4. Plan for Scale**:

| Records | Upload Time | Indexing Time | Refresh Strategy |
|---------|-------------|---------------|------------------|
| **< 10,000** | 1-2 min | 15-30 min | Full replace monthly |
| **10,000-100,000** | 5-10 min | 30-60 min | Full replace bi-weekly |
| **100,000-1M** | 15-30 min | 60-120 min | Incremental if supported |
| **> 1M** | 30-60 min | 2-4 hours | Partition by region/dept |

---

## ✅ Validation Checklist

Use this checklist to verify Lab 2 completion:

### EDM Schema Configuration

- [ ] Created employee database CSV with 100 records in proper format
- [ ] Defined EDM schema with searchable fields (EmployeeID, Email, SSN)
- [ ] Uploaded EDM schema to Microsoft Purview successfully
- [ ] Verified schema status shows "Active" in Purview

### EDM Data Upload

- [ ] Hashed employee data using EDMUploadAgent.exe successfully
- [ ] Uploaded hashed data to Purview without errors
- [ ] Verified record count matches source CSV (100 records)
- [ ] Waited 30-90 minutes for EDM indexing completion

### EDM Custom SIT

- [ ] Created **Contoso Employee Record (EDM)** custom SIT
- [ ] Linked SIT to EmployeeDataStore successfully
- [ ] Configured three confidence levels (High/Medium/Low)
- [ ] Verified SIT appears in Purview portal

### Accuracy Validation

- [ ] Created test documents with employee data from database
- [ ] Validated EDM classification has zero false positives
- [ ] Compared EDM accuracy (99%) vs regex accuracy (85-95%)
- [ ] Documented accuracy improvement metrics

---

## 🛠️ Troubleshooting Guide

### Common Issue: EDM Schema Upload Fails

**Symptoms**: `New-DlpEdmSchema` cmdlet returns error

**Common Errors**:

| Error Message | Solution |
|---------------|----------|
| **Schema name already exists** | Use unique DataStore name or delete existing schema first |
| **Invalid XML format** | Validate XML syntax using online XML validator |
| **Field name mismatch** | Ensure CSV column names match schema field names exactly (case-sensitive) |
| **Too many searchable fields** | Limit searchable fields to 5 maximum |

**Debug Commands**:

```powershell
# Check existing EDM schemas
Get-DlpEdmSchema | Select-Object DataStoreName, Status

# Delete existing schema if needed
Remove-DlpEdmSchema -DataStoreName "EmployeeDataStore"
```

---

### Common Issue: EDM Data Upload Fails

**Symptoms**: EDMUploadAgent returns error during data upload

**Common Errors**:

| Error Message | Solution |
|---------------|----------|
| **Schema not found** | Upload schema first using `New-DlpEdmSchema` cmdlet |
| **Column count mismatch** | Verify CSV columns match schema definition exactly |
| **Authentication failed** | Add user to EDM_DataUploaders security group, wait 1 hour for sync |
| **File size too large** | Split large databases into multiple CSV files (<100MB each) |
| **Invalid encoding** | Re-save CSV as UTF-8 encoding (not UTF-8 BOM or ANSI) |

**Validation Steps**:

```powershell
# Verify CSV column count
$csv = Import-Csv "C:\PurviewLabs\Lab2-EDM-Testing\EmployeeDatabase.csv"
$csv[0].PSObject.Properties.Name  # Should match schema fields exactly

# Check file encoding
Get-Content "C:\PurviewLabs\Lab2-EDM-Testing\EmployeeDatabase.csv" -Encoding UTF8

# Verify EDM_DataUploaders membership
Get-AzureADGroupMember -ObjectId "EDM_DataUploaders_GroupID"
```

---

### Common Issue: EDM Classification Not Working

**Symptoms**: EDM schema and data uploaded but no classifications appear

**Solutions**:

1. **Wait for indexing**: EDM data takes 30-90 minutes to become active after upload
2. **Verify data store status**: `Get-DlpEdmSchema | Where-Object {$_.DataStoreName -eq "EmployeeDataStore"}` shows schema exists
3. **Check record count**: Ensure uploaded records appear in Purview
4. **Test with known values**: Create document with exact database values
5. **Review searchable fields**: Verify document contains searchable field values (EmployeeID, Email, SSN)

**Debug Process**:

```powershell
# Step 1: Check EDM data store status
$edmStatus = Get-DlpEdmSchema | Where-Object {$_.DataStoreName -eq "EmployeeDataStore"}
Write-Host "DataStore: $($edmStatus.DataStoreName)"
Write-Host "Version: $($edmStatus.Version)"

# Step 2: Verify custom SIT linked to EDM
Get-DlpSensitiveInformationType | Where-Object {$_.Name -like "*Employee Record*"}

# Step 3: Test with known database value
# Create test.txt with: "Employee EMP-1234-5678 email emily.rodriguez@contoso.com SSN 123-45-6789"
# Upload to SharePoint and check Content Explorer after 15-30 minutes
```

---

### Common Issue: Too Many False Positives (Even with EDM)

**Symptoms**: EDM detecting values not in database

**Solutions**:

1. **Verify hash matching**: EDM should only match exact database values (no false positives)
2. **Check confidence levels**: Ensure "High" confidence requires multiple field matches
3. **Review test data**: Confirm test documents contain actual database values
4. **Validate upload**: Re-upload EDM data to ensure complete refresh

**Expected Behavior**:

- **EDM False Positives**: Should be ZERO (exact match only)
- **If false positives occur**: Likely using regex SIT instead of EDM SIT
- **Verify**: Check Content Explorer to see which SIT triggered classification

---

## 📚 Additional Resources

### Microsoft Learn Documentation

- **Exact Data Match (EDM)**: [https://learn.microsoft.com/purview/sit-create-edm-sit](https://learn.microsoft.com/purview/sit-create-edm-sit)
- **EDM Schema Reference**: [https://learn.microsoft.com/purview/sit-edm-schema-reference](https://learn.microsoft.com/purview/sit-edm-schema-reference)
- **EDMUploadAgent Reference**: [https://learn.microsoft.com/purview/sit-get-started-exact-data-match](https://learn.microsoft.com/purview/sit-get-started-exact-data-match)
- **EDM Refresh Process**: [https://learn.microsoft.com/purview/sit-refresh-edm-data](https://learn.microsoft.com/purview/sit-refresh-edm-data)

### Tools and Testing

- **CSV Validator**: [https://csvlint.io/](https://csvlint.io/) - Validate EDM source files
- **XML Validator**: [https://www.xmlvalidation.com/](https://www.xmlvalidation.com/) - Validate EDM schema syntax
- **PowerShell Gallery**: [https://www.powershellgallery.com/](https://www.powershellgallery.com/) - Find Purview modules

### Enterprise Best Practices

- **EDM Naming Conventions**: Use descriptive DataStore names (EmployeeDataStore_Region)
- **Security Group Management**: Limit EDM_DataUploaders membership to compliance admins only
- **Refresh Automation**: Schedule EDM refresh via Azure Automation or Task Scheduler
- **Compliance Boundaries**: Use separate data stores for multi-tenant or multi-region isolation
- **Audit Logging**: Enable audit logging for EDM upload operations
- **Refresh Cadence**: Monthly for most organizations, weekly for high-security environments

---

## ⏭️ Next Steps

**After completing Lab 2**:

1. Review EDM classification accuracy metrics and compare to Lab 1 regex results
2. Document EDM refresh schedule and automation requirements
3. Plan production EDM deployment with IT security and compliance teams
4. Proceed to **Lab 3: On-Demand Classification & Content Explorer Validation**
   - Validate both regex-based (Lab 1) and EDM-based (Lab 2) custom SITs against SharePoint content
   - Use Content Explorer to compare classification results
   - Analyze detection accuracy and false positive rates

**Skills Gained**:

✅ EDM schema design for structured employee databases  
✅ Secure data hashing and upload workflows  
✅ EDM-based custom SIT configuration and validation  
✅ Accuracy measurement and false positive reduction  
✅ Understanding when to use EDM vs regex-based classification  
✅ Enterprise EDM deployment and refresh best practices  

---

## 🤖 AI-Assisted Content Generation

This comprehensive EDM lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview Exact Data Match capabilities, secure data hashing workflows, and EDM best practices validated against Microsoft Learn documentation (November 2025).

*AI tools were used to enhance productivity and ensure comprehensive coverage of EDM configuration while maintaining technical accuracy and reflecting enterprise-grade data classification standards for structured sensitive data protection.*
