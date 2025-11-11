# Lab 2: Custom Sensitive Information Types (SITs)

Build advanced custom SITs using regex patterns, keyword dictionaries, confidence levels, and Exact Data Match (EDM) for structured database classification.

---

## 📋 Lab Summary

**Duration**: 2-3 hours active work

**Goal**: Master custom SIT creation from basic regex patterns to advanced EDM configurations for precise sensitive data detection.

**Skills**: Regex pattern design, keyword dictionary management, confidence level tuning, EDM schema creation, data hashing, compliance boundary definition

---

## 🎯 What You'll Learn

✅ Create regex-based custom SITs with pattern validation  
✅ Implement keyword dictionaries for context-aware detection  
✅ Configure multi-level confidence scoring (High/Medium/Low)  
✅ Design EDM schemas for structured database classification  
✅ Use EDMUploadAgent for secure data hashing and upload  
✅ Validate custom SIT accuracy in Content Explorer  
✅ Apply custom SITs to DLP policies and retention labels  

---

## 📚 Prerequisites

**Required Access**:

- Microsoft 365 E5 or E5 Compliance license
- Compliance Administrator or Organization Management role
- Microsoft Purview Information Protection access

**Technical Requirements**:

- PowerShell 7+ installed
- ExchangeOnlineManagement module v3.4.0+: `Install-Module ExchangeOnlineManagement -Scope CurrentUser`
- Microsoft.Purview module v2.1.0+: `Install-Module Microsoft.Purview -Scope CurrentUser`
- Security & Compliance PowerShell access

**Knowledge Prerequisites**:

- Lab 1 completion (On-Demand Classification fundamentals)
- Basic regex pattern understanding
- CSV file format familiarity
- PowerShell cmdlet execution experience

**Completed Labs**:

- **Lab 1: On-Demand Classification** - Provides foundation in basic SIT detection and Content Explorer usage

---

## 🤔 When to Use Custom SITs

**Use Custom SITs when**:

- Detecting organization-specific identifiers (employee IDs, project codes, customer numbers)
- Built-in SITs don't match your data formats
- Need higher detection accuracy with keyword context
- Require compliance boundary-based classification
- Managing structured databases with sensitive columns

| Scenario | Custom SIT (Regex) | Custom SIT (EDM) | Built-in SIT |
|----------|-------------------|------------------|--------------|
| **Employee IDs** | ✅ Pattern-based | ✅ Database validation | ❌ Not available |
| **Credit Cards** | ⚠️ Complex patterns | ❌ Overkill | ✅ Use built-in |
| **Customer Databases** | ❌ Too many records | ✅ Ideal for structured data | ❌ Not applicable |
| **Project Codes** | ✅ Simple patterns | ❌ Unnecessary | ❌ Not available |
| **Setup Time** | 15-30 minutes | 1-2 hours | Immediate |
| **Accuracy** | High with keywords | Very High (exact match) | High |
| **Maintenance** | Pattern updates | Database refreshes | None |

---

## 📂 Phase 1: Regex-Based Custom SIT Creation

### Step 1: Generate Test Data for Pattern Validation

Run the sample data creation script for Lab 2 pattern testing:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\02-CustomSITs\scripts"
.\Create-Lab2TestData.ps1
```

**What happens**:

- Creates `C:\PurviewLabs\Lab2-CustomSIT-Testing\` directory structure
- Generates test files with patterns:
  - **Project IDs**: `PROJ-2025-####` format (engineering, marketing, finance projects)
  - **Customer Numbers**: `CUST-######` format (6-digit customer identifiers)
  - **Purchase Order Numbers**: `PO-####-####-XXXX` format (department-year-sequence-vendor codes)
- Creates 15 test documents with embedded patterns for validation

**Expected Output**:

```text
✅ Test data created: 15 files in C:\PurviewLabs\Lab2-CustomSIT-Testing\
   - 5 files with Project ID patterns (PROJ-2025-####)
   - 5 files with Customer Number patterns (CUST-######)
   - 5 files with Purchase Order patterns (PO-####-####-XXXX)
```

---

### Step 2: Create Project ID Custom SIT (Regex Pattern)

Run the Project ID custom SIT creation script:

```powershell
.\Create-ProjectIDSIT.ps1
```

**Script Actions**:

- Connects to Security & Compliance PowerShell
- Creates custom SIT: **Contoso Project Identifier**
- Defines regex pattern: `\bPROJ-\d{4}-\d{4}\b`
- Implements keyword dictionary for context awareness
- Configures three confidence levels:
  - **High (85%)**: Pattern + full keyword set (project, identifier, PROJ, development, initiative)
  - **Medium (75%)**: Pattern + partial keywords (project, PROJ)
  - **Low (65%)**: Pattern only (no keyword requirement)
- Character proximity: 300 characters for keyword matching

**Pattern Examples** (will be detected):

```text
✅ PROJ-2025-1234 (Low confidence - pattern only)
✅ Project PROJ-2025-5678 assigned to team (Medium confidence - partial keywords)
✅ Engineering project PROJ-2025-9012 development initiative started (High confidence - full keyword match)
```

**Invalid Patterns** (will NOT be detected):

```text
❌ PROJ-25-1234 (wrong year format - must be 4 digits)
❌ PROJ20251234 (missing hyphens)
❌ PROJECT-2025-1234 (wrong prefix - must be PROJ, not PROJECT)
```

---

### Step 3: Create Customer Number Custom SIT (Keywords + Pattern)

Run the Customer Number custom SIT creation script:

```powershell
.\Create-CustomerNumberSIT.ps1
```

**Script Actions**:

- Creates custom SIT: **Contoso Customer Number**
- Regex pattern: `\bCUST-\d{6}\b`
- Keyword dictionary: customer, account, CUST, client, customer number, account number
- Confidence levels: High (85% with keywords), Medium (75% partial), Low (65% pattern-only)
- Enhanced detection with context validation

**Pattern Examples**:

```text
✅ CUST-123456 (pattern match)
✅ Customer account CUST-789012 requires verification (high confidence with context)
✅ Account number: CUST-345678 (medium confidence)
```

**Best Practices for Keyword Selection**:

- Include official terms from business documentation
- Add common abbreviations and acronyms
- Consider plural forms and variations
- Test with real-world documents for false positives/negatives
- Balance specificity (reduce false positives) vs. recall (find all instances)

---

### Step 4: Create Purchase Order Custom SIT (Complex Pattern)

Run the Purchase Order custom SIT creation script:

```powershell
.\Create-PurchaseOrderSIT.ps1
```

**Script Actions**:

- Creates custom SIT: **Contoso Purchase Order Number**
- Complex regex: `\bPO-\d{4}-\d{4}-[A-Z]{4}\b`
- Pattern breakdown:
  - `PO-` = Fixed prefix
  - `\d{4}` = Department code (4 digits)
  - `\d{4}` = Fiscal year (4 digits)  
  - `[A-Z]{4}` = Vendor code (4 uppercase letters)
- Keywords: purchase order, PO, procurement, requisition, vendor
- Multi-part pattern validation for structured identifiers

**Pattern Examples**:

```text
✅ PO-3200-2025-ACME (Engineering dept, FY2025, ACME vendor)
✅ PO-4100-2024-MSFT (Marketing dept, FY2024, Microsoft vendor)
✅ Procurement purchase order PO-5300-2025-GOOG issued (high confidence)
```

**Complex Pattern Design Tips**:

- Break patterns into logical segments
- Use character classes for specific requirements ([A-Z], [0-9], etc.)
- Test patterns at regex101.com before implementation
- Document pattern segments in SIT description
- Consider future pattern evolution (year format changes, etc.)

---

### Step 5: Validate Regex-Based Custom SITs

Wait **5-15 minutes** for global SIT replication, then run validation:

```powershell
.\Validate-CustomSITs.ps1 -TestDataPath "C:\PurviewLabs\Lab2-CustomSIT-Testing"
```

**Validation Checks**:

- Queries all three custom SITs from Security & Compliance PowerShell
- Verifies SIT configuration (pattern, keywords, confidence levels)
- Tests pattern matching against local test files
- Generates confidence level distribution report
- Exports validation results to CSV

**Expected Results**:

```text
✅ Custom SIT: Contoso Project Identifier
   Pattern: PROJ-####-####
   Detection Count: 5 files (15 instances)
   High Confidence: 40%, Medium: 35%, Low: 25%

✅ Custom SIT: Contoso Customer Number  
   Pattern: CUST-######
   Detection Count: 5 files (12 instances)
   High Confidence: 50%, Medium: 30%, Low: 20%

✅ Custom SIT: Contoso Purchase Order Number
   Pattern: PO-####-####-XXXX
   Detection Count: 5 files (10 instances)  
   High Confidence: 60%, Medium: 25%, Low: 15%
```

---

## 🔐 Phase 2: Exact Data Match (EDM) Configuration

### What is Exact Data Match (EDM)?

Exact Data Match (EDM) enables classification based on exact values from structured databases rather than pattern matching. This is ideal for:

- Employee databases (SSN, employee number, email, phone)
- Customer records (account numbers, customer IDs, contact information)
- Financial databases (account numbers, transaction IDs, credit card numbers)
- Compliance boundary enforcement (multi-tenant or multi-region data isolation)

**EDM vs. Regex Custom SITs**:

| Feature | Regex-Based SIT | EDM-Based SIT |
|---------|----------------|---------------|
| **Data Source** | Pattern matching | Database lookup |
| **Accuracy** | High (~85-95%) | Very High (~99%) |
| **False Positives** | Moderate | Very Low |
| **Setup Complexity** | Low (15-30 min) | High (1-2 hours) |
| **Maintenance** | Pattern updates | Database refreshes |
| **Ideal Use Case** | Format-based IDs | Structured databases |
| **Scale** | Any size | 1M-100M records |

---

### Step 6: Prepare EDM Source Database

Create the employee database CSV file for EDM classification:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\02-CustomSITs\edm\scripts"
.\Create-EDMSourceDatabase.ps1
```

**Script Actions**:

- Creates `C:\PurviewLabs\Lab2-CustomSIT-Testing\EDM\` directory
- Generates `EmployeeDatabase.csv` with 100 employee records
- Columns: EmployeeID, FirstName, LastName, Email, Phone, SSN, Department, HireDate
- Realistic data with proper formatting:
  - Employee IDs: EMP-####-#### format
  - SSNs: ###-##-#### format (validated checksums)
  - Emails: `firstname.lastname@contoso.com`
  - Phones: (###) ###-#### format

**Sample Database Structure**:

```csv
EmployeeID,FirstName,LastName,Email,Phone,SSN,Department,HireDate
EMP-1234-5678,Emily,Rodriguez,emily.rodriguez@contoso.com,(206) 555-1234,123-45-6789,Engineering,2020-01-15
EMP-2345-6789,James,Patterson,james.patterson@contoso.com,(503) 555-2345,234-56-7890,Finance,2018-06-01
EMP-3456-7890,Michelle,Chen,michelle.chen@contoso.com,(415) 555-3456,345-67-8901,Marketing,2022-03-10
```

> **⚠️ Production Note**: In real environments, export actual employee data from HRIS systems (Workday, SAP SuccessFactors, ADP) ensuring PII handling compliance.

---

### Step 7: Create EDM Schema Definition

Run the EDM schema creation script:

```powershell
.\Create-EDMSchema.ps1
```

**Script Actions**:

- Creates EDM schema XML file: `EmployeeDatabase_Schema.xml`
- Defines searchable fields (EmployeeID, Email, SSN)
- Configures caseInsensitive matching for email addresses
- Sets up column relationships and data store configuration
- Saves schema to `C:\PurviewLabs\Lab2-CustomSIT-Testing\EDM\configs\`

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

**Key Concepts**:

- **Searchable fields**: Columns Purview will match against document content (EmployeeID, Email, SSN)
- **Non-searchable fields**: Supporting data that won't trigger classification but enriches results
- **caseInsensitive**: Email matching works regardless of case (`emily.rodriguez@contoso.com` = `Emily.Rodriguez@CONTOSO.COM`)
- **Data Store**: Logical container for related data (one data store per database/CSV file)

---

### Step 8: Upload EDM Schema to Microsoft Purview

Run the schema upload script:

```powershell
.\Upload-EDMSchema.ps1 -SchemaPath "C:\PurviewLabs\Lab2-CustomSIT-Testing\EDM\configs\EmployeeDatabase_Schema.xml"
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
   Schema Version: 1.0
   Status: Active
   Next Step: Hash and upload employee data
```

---

### Step 9: Hash and Upload Employee Data

Use the EDMUploadAgent to securely hash and upload employee database:

```powershell
.\Upload-EDMData.ps1 -DatabasePath "C:\PurviewLabs\Lab2-CustomSIT-Testing\EDM\EmployeeDatabase.csv" -DataStoreName "EmployeeDataStore"
```

**Script Actions**:

- Downloads and installs EDMUploadAgent.exe (if not present)
- Validates CSV file structure matches schema
- Creates hashed version of sensitive data (SHA-256)
- Uploads hashed data to Microsoft Purview secure storage
- Deletes local hashed file after successful upload

**EDM Security Model**:

1. **Local Hashing**: Employee data hashed on-premises with SHA-256 (SSN "123-45-6789" → "A1B2C3D4...hash")
2. **Encrypted Upload**: Hashed data transmitted via TLS 1.3 to Purview
3. **Secure Storage**: Hashed values stored in Microsoft-managed secure enclave
4. **Comparison Only**: Purview compares document content hashes to stored hashes (never sees original values)

**Upload Process Timeline**:

```text
⏱️ Data Hashing: 1-5 minutes (depends on record count)
⏱️ Upload to Purview: 5-15 minutes (depends on file size)
⏱️ Purview Indexing: 15-60 minutes (backend processing)
⏱️ Classification Active: 30-90 minutes total from upload start
```

---

### Step 10: Create EDM-Based Custom SIT

Run the EDM SIT creation script:

```powershell
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

**Detection Logic**:

```text
Document Content: "Employee EMP-1234-5678 with email emily.rodriguez@contoso.com and SSN 123-45-6789"

Purview Process:
1. Extracts: EMP-1234-5678, emily.rodriguez@contoso.com, 123-45-6789
2. Hashes each value: SHA-256 transformation
3. Compares hashes to EmployeeDataStore
4. Result: ALL THREE MATCH → High Confidence (95%) classification
5. Applies label: "Employee Record - Confidential"
```

**EDM Best Practices**:

- Use multiple searchable fields for higher accuracy
- Include primary identifier + 1-2 supporting fields
- Refresh EDM database monthly or when employee data changes significantly
- Monitor false positive rate in Activity Explorer
- Consider compliance boundaries for multi-tenant scenarios

---

### Step 11: Validate EDM Classification

Upload test documents containing employee data to SharePoint, then run validation:

```powershell
# Create test documents with employee data
.\Create-EDMTestDocuments.ps1

# Wait 30-60 minutes for EDM indexing

# Run validation
.\Validate-EDMClassification.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/PurviewLab"
```

**Validation Checks**:

- Queries Content Explorer for EDM-classified documents
- Verifies exact match detection (no false positives from pattern-like data)
- Compares detection accuracy: Regex-based vs. EDM-based
- Generates accuracy report with confidence level breakdown

**Expected Results**:

```text
📊 EDM Classification Validation Results:

✅ Regex-Based SIT (Contoso Employee ID):
   Total Detections: 150
   False Positives: 12 (8% - pattern matched non-employee IDs)
   True Positives: 138 (92%)

✅ EDM-Based SIT (Contoso Employee Record):
   Total Detections: 138
   False Positives: 0 (0% - exact database match only)
   True Positives: 138 (100%)

🎯 Accuracy Improvement: +8% with EDM vs. regex-only approach
```

---

## 📊 Phase 3: Advanced SIT Configuration

### Step 12: Configure Confidence Level Tuning

Fine-tune confidence levels to reduce false positives while maintaining high recall:

```powershell
.\Tune-SITConfidence.ps1 -SITName "Contoso Project Identifier" -TestDataPath "C:\PurviewLabs\Lab2-CustomSIT-Testing"
```

**Tuning Process**:

1. **Baseline Testing**: Run SIT against 100 test documents
2. **False Positive Analysis**: Identify incorrectly classified documents
3. **Keyword Adjustment**: Add/remove keywords to improve context matching
4. **Confidence Threshold**: Adjust High/Medium/Low boundaries
5. **Validation**: Re-test and measure accuracy improvement

**Confidence Level Guidelines**:

| Confidence Level | Recommended Use Case | Example |
|------------------|----------------------|---------|
| **95%+** | EDM exact matches, highly sensitive data | Employee SSN + ID + Email match |
| **85-94%** | Pattern + strong keyword context | "Employee ID EMP-1234-5678 assigned to project" |
| **75-84%** | Pattern + weak keyword context | "EMP-1234-5678 project code" |
| **65-74%** | Pattern only, no keywords | "EMP-1234-5678" (standalone pattern) |
| **< 65%** | Avoid (too many false positives) | Pattern with low specificity |

---

### Step 13: Create Custom SIT Rule Package

Package all custom SITs into a single deployable rule package for version control and disaster recovery:

```powershell
.\Export-CustomSITPackage.ps1 -OutputPath "C:\PurviewLabs\Lab2-CustomSIT-Testing\SIT-Package-Backup.xml"
```

**Script Actions**:

- Exports all custom SITs to XML rule package format
- Includes regex patterns, keywords, confidence levels
- Embeds EDM schema references (but not hashed data)
- Creates version-controlled backup for disaster recovery

**Rule Package Uses**:

- **Backup and Restore**: Disaster recovery for accidental SIT deletion
- **Version Control**: Git/GitHub integration for change tracking
- **Multi-Tenant Deployment**: Deploy same SITs across multiple Microsoft 365 tenants
- **Development Workflow**: Test SITs in dev tenant, promote to production

**Import Process** (if needed for restore):

```powershell
.\Import-CustomSITPackage.ps1 -PackagePath "C:\PurviewLabs\Lab2-CustomSIT-Testing\SIT-Package-Backup.xml"
```

---

## ✅ Validation Checklist

Use this checklist to verify Lab 2 completion:

### Regex-Based Custom SITs

- [ ] Created **Contoso Project Identifier** SIT with PROJ-####-#### pattern
- [ ] Created **Contoso Customer Number** SIT with CUST-###### pattern
- [ ] Created **Contoso Purchase Order Number** SIT with PO-####-####-XXXX pattern
- [ ] Validated all three SITs detect patterns in test documents
- [ ] Verified keyword-based confidence level scoring works correctly
- [ ] Confirmed SITs appear in Content Explorer with correct detection counts

### EDM Configuration

- [ ] Created employee database CSV with 100 records
- [ ] Defined EDM schema with searchable fields (EmployeeID, Email, SSN)
- [ ] Uploaded EDM schema to Microsoft Purview successfully
- [ ] Hashed and uploaded employee data using EDMUploadAgent
- [ ] Created **Contoso Employee Record (EDM)** custom SIT
- [ ] Validated EDM classification has zero false positives
- [ ] Verified EDM accuracy improvement over regex-based detection

### Advanced Configuration

- [ ] Tuned confidence levels for optimal accuracy
- [ ] Exported custom SIT rule package for backup
- [ ] Documented pattern design decisions for team reference
- [ ] Tested SITs with real-world sample documents (if available)

---

## 🛠️ Troubleshooting Guide

### Common Issue: Custom SIT Not Detecting Patterns

**Symptoms**: SIT created successfully but Content Explorer shows zero detections

**Solutions**:

1. **Wait for replication**: Custom SITs take 5-15 minutes for global replication
2. **Verify pattern syntax**: Test regex at regex101.com before deployment
3. **Check keyword proximity**: Ensure keywords are within 300 characters of pattern
4. **Validate content**: Confirm test documents actually contain the expected patterns
5. **Re-run On-Demand Classification**: Force immediate re-indexing of test site

```powershell
# Force re-indexing
Start-RetentionAutoLabelSimulation -SharePointLocation "https://contoso.sharepoint.com/sites/PurviewLab"
```

---

### Common Issue: EDM Classification Not Working

**Symptoms**: EDM schema uploaded but no classifications appear

**Solutions**:

1. **Verify schema upload**: `Get-DlpEdmSchema -DataStoreName "EmployeeDataStore"`
2. **Check data upload status**: Review EDMUploadAgent logs for errors
3. **Wait for indexing**: EDM data takes 30-90 minutes to become active after upload
4. **Validate CSV format**: Ensure column names match schema EXACTLY (case-sensitive)
5. **Test with known values**: Upload document with exact database values to test

**EDM Upload Log Location**:

```text
Windows: C:\Users\<YourUser>\AppData\Local\Microsoft\EdmUploadAgent\Logs\
```

---

### Common Issue: Too Many False Positives

**Symptoms**: SIT detecting patterns in non-sensitive content

**Solutions**:

1. **Add keywords**: Increase required keyword matches for high confidence
2. **Refine regex**: Make pattern more specific (add word boundaries, context)
3. **Raise confidence threshold**: Require higher confidence for DLP policy triggers
4. **Use EDM instead**: Replace regex-based SIT with EDM for exact match accuracy

**Example Refinement**:

```powershell
# Before (too broad):
$pattern = '\d{4}-\d{4}'

# After (more specific):
$pattern = '\bEMP-\d{4}-\d{4}\b'  # Added word boundaries and EMP prefix
```

---

### Common Issue: EDM Data Upload Fails

**Symptoms**: EDMUploadAgent returns error during data upload

**Common Errors**:

| Error Message | Solution |
|---------------|----------|
| **Schema not found** | Upload schema first using `New-DlpEdmSchema` cmdlet |
| **Column mismatch** | Verify CSV column names match schema definition exactly |
| **Authentication failed** | Re-authenticate with `Connect-IPPSSession` before upload |
| **File size too large** | Split large databases into multiple CSV files (<100MB each) |
| **Invalid hash format** | Regenerate hash file and retry upload |

**Debug Commands**:

```powershell
# Check EDM schema status
Get-DlpEdmSchema

# Verify column names
(Import-Csv "C:\PurviewLabs\Lab2-CustomSIT-Testing\EDM\EmployeeDatabase.csv")[0].PSObject.Properties.Name

# Test authentication
Get-ConnectionInformation
```

---

## 📚 Additional Resources

### Microsoft Learn Documentation

- **Custom SITs Overview**: [https://learn.microsoft.com/purview/sit-create-custom](https://learn.microsoft.com/purview/sit-create-custom)
- **Regex Pattern Reference**: [https://learn.microsoft.com/purview/sit-regex-syntax](https://learn.microsoft.com/purview/sit-regex-syntax)
- **Exact Data Match (EDM)**: [https://learn.microsoft.com/purview/sit-create-edm-sit](https://learn.microsoft.com/purview/sit-create-edm-sit)
- **Confidence Levels**: [https://learn.microsoft.com/purview/sit-confidence-levels](https://learn.microsoft.com/purview/sit-confidence-levels)
- **EDMUploadAgent Reference**: [https://learn.microsoft.com/purview/sit-get-started-exact-data-match](https://learn.microsoft.com/purview/sit-get-started-exact-data-match)

### Tools and Testing

- **Regex Tester**: [https://regex101.com/](https://regex101.com/) - Test patterns before deployment
- **CSV Validator**: [https://csvlint.io/](https://csvlint.io/) - Validate EDM source files
- **PowerShell Gallery**: [https://www.powershellgallery.com/](https://www.powershellgallery.com/) - Find Purview modules

### Enterprise Best Practices

- **SIT Naming Conventions**: Use consistent prefixes (Contoso, Organization name)
- **Version Control**: Store SIT rule packages in Git for change tracking
- **Testing Workflow**: Dev tenant → staging validation → production deployment
- **Documentation**: Maintain pattern design rationale and keyword selection notes
- **Refresh Cadence**: Update EDM databases monthly or after significant HR/CRM changes

---

## ⏭️ Next Steps

**After completing Lab 2**:

1. Review classification results in Content Explorer for all custom SITs
2. Compare regex-based vs. EDM-based accuracy metrics
3. Document lessons learned for custom SIT design patterns
4. Proceed to **Lab 3: Retention Labels and Auto-Apply Policies**
   - Apply custom SITs to retention labels for lifecycle management
   - Create auto-apply retention policies based on custom SIT detection
   - Test retention hold behavior on classified documents

**Skills Gained**:

✅ Regex pattern design for organization-specific identifiers  
✅ Keyword dictionary management for context-aware classification  
✅ Multi-level confidence scoring optimization  
✅ EDM schema design and data hashing workflows  
✅ Custom SIT validation and accuracy measurement  
✅ Enterprise deployment and version control best practices  

---

## 🤖 AI-Assisted Content Generation

This comprehensive custom SIT lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview Information Protection capabilities, regex pattern best practices, and Exact Data Match (EDM) workflows validated against Microsoft Learn documentation (November 2025).

*AI tools were used to enhance productivity and ensure comprehensive coverage of custom SIT creation while maintaining technical accuracy and reflecting enterprise-grade data classification standards.*
