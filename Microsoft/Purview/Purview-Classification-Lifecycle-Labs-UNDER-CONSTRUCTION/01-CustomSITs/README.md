# Lab 1: Custom Sensitive Information Types (Regex & Keywords)

Build custom SITs using advanced regex patterns, keyword dictionaries, and multi-level confidence scoring for precise organizational data detection.

---

## 📋 Lab Summary

**Duration**: 60-75 minutes active work | NO wait periods

**Goal**: Master regex-based custom SIT creation with pattern validation, keyword dictionaries, and confidence level tuning for organization-specific data formats.

**Skills**: Regex pattern design, keyword dictionary management, confidence level tuning, pattern validation, custom SIT testing

---

## 🎯 What You'll Learn

✅ Enhance placeholder SITs from Lab 0 with advanced regex patterns  
✅ Create new custom SITs for organization-specific identifiers  
✅ Implement keyword dictionaries for context-aware detection  
✅ Configure multi-level confidence scoring (High/Medium/Low)  
✅ Validate custom SIT accuracy against local test files  
✅ Understand SIT effectiveness measurement and tuning  
✅ Prepare custom SITs for SharePoint validation in Lab 3  

---

## 📚 Prerequisites

**Required Access**:

- Microsoft 365 E5 or E5 Compliance license
- Compliance Administrator or Organization Management role
- Microsoft Purview Information Protection access

**Technical Requirements**:

- PowerShell 7+ installed
- ExchangeOnlineManagement module v3.4.0+: `Install-Module ExchangeOnlineManagement -Scope CurrentUser`
- Security & Compliance PowerShell access

**Knowledge Prerequisites**:

- Basic regex pattern understanding (optional - patterns provided)
- PowerShell cmdlet execution experience
- Familiarity with Microsoft Purview portal navigation

**Completed Labs**:

- **Lab 0: Prerequisites & Time-Sensitive Setup** - Provides SharePoint test site and placeholder SITs as foundation

---

## 🤔 When to Use Custom SITs

**Use Custom SITs when**:

- Detecting organization-specific identifiers (employee IDs, project codes, customer numbers)
- Built-in SITs don't match your data formats
- Need higher detection accuracy with keyword context
- Require compliance boundary-based classification
- Managing format-specific identifiers with consistent patterns

| Scenario | Custom SIT (Regex) | Built-in SIT | Use Case |
|----------|-------------------|--------------|----------|
| **Employee IDs** | ✅ Pattern-based | ❌ Not available | Organization-specific formats |
| **Credit Cards** | ⚠️ Complex patterns | ✅ Use built-in | Standard formats already covered |
| **Project Codes** | ✅ Simple patterns | ❌ Not available | Custom organizational identifiers |
| **SSN/Tax IDs** | ❌ Use built-in | ✅ High accuracy | Standard government formats |
| **Setup Time** | 15-30 minutes | Immediate | Custom requires configuration |
| **Accuracy** | High with keywords (85-95%) | High (90%+) | Both provide excellent detection |
| **Maintenance** | Pattern updates needed | None | Custom requires ongoing updates |

---

## 📂 Exercise 1: Generate Test Data for Pattern Validation

### Step 1: Create Local Test Data

Run the sample data creation script for pattern testing:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\01-CustomSITs\scripts"
.\Create-Lab1TestData.ps1
```

**What happens**:

- Creates `C:\PurviewLabs\Lab1-CustomSIT-Testing\` directory structure
- Generates test files with patterns:
  - **Project IDs**: `PROJ-2025-####` format (engineering, marketing, finance projects)
  - **Customer Numbers**: `CUST-######` format (6-digit customer identifiers)
  - **Purchase Order Numbers**: `PO-####-####-XXXX` format (department-year-sequence-vendor codes)
- Creates 15 test documents with embedded patterns for local validation

**Expected Output**:

```text
✅ Test data created: 15 files in C:\PurviewLabs\Lab1-CustomSIT-Testing\
   - 5 files with Project ID patterns (PROJ-2025-####)
   - 5 files with Customer Number patterns (CUST-######)
   - 5 files with Purchase Order patterns (PO-####-####-XXXX)
```

> **💡 Local Testing Note**: These test files allow immediate pattern validation without waiting for SharePoint indexing. You can test and refine your regex patterns locally before deployment.

---

## 🔍 Exercise 2: Create Project ID Custom SIT

### Step 2: Create Project ID Custom SIT (Regex Pattern)

Run the Project ID custom SIT creation script:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\01-CustomSITs\scripts"
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

**Pattern Breakdown**:

```text
\b          = Word boundary (prevents matching within larger strings)
PROJ-       = Fixed prefix (literal text)
\d{4}       = Four digits (year: 2025)
-           = Hyphen separator
\d{4}       = Four digits (sequence number: 0001-9999)
\b          = Word boundary (ending)
```

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
❌ PROJ-2025-12345 (too many digits in sequence - must be exactly 4)
```

> **🔧 Pattern Design Tip**: Use word boundaries (`\b`) to prevent false positives from partial matches within longer strings. Test patterns at regex101.com before deployment.

---

## 👥 Exercise 3: Create Customer Number Custom SIT

### Step 3: Create Customer Number Custom SIT (Keywords + Pattern)

Run the Customer Number custom SIT creation script:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\01-CustomSITs\scripts"
.\Create-CustomerNumberSIT.ps1
```

> **⚠️ Replacement Notice**: This script will detect the placeholder "Contoso Customer Number" SIT created in Lab 0 and prompt you to remove and recreate it with enhanced features. **Select "Y" when prompted** to replace the basic placeholder with the advanced version that includes keyword dictionaries and multi-level confidence scoring.

**Script Actions**:

- **Replaces** the Lab 0 placeholder SIT: **Contoso Customer Number**
- Regex pattern: `\bCUST-\d{6}\b` (same pattern, enhanced detection)
- Keyword dictionary: customer, account, CUST, client, customer number, account number
- Confidence levels: High (85% with keywords), Medium (75% partial), Low (65% pattern-only)
- Enhanced detection with context validation

**Pattern Examples**:

```text
✅ CUST-123456 (pattern match - Low confidence)
✅ Customer account CUST-789012 requires verification (High confidence with context)
✅ Account number: CUST-345678 (Medium confidence)
```

**Best Practices for Keyword Selection**:

- Include official terms from business documentation
- Add common abbreviations and acronyms
- Consider plural forms and variations (customer, customers, client, clients)
- Test with real-world documents for false positives/negatives
- Balance specificity (reduce false positives) vs. recall (find all instances)

**Keyword Proximity Rules**:

- **300 characters**: Default proximity for keyword matching
- **Keywords before or after**: Pattern can appear anywhere within 300-character window
- **Multiple keywords**: More keywords increase confidence level
- **Case insensitive**: Keywords match regardless of capitalization

---

## 📦 Exercise 4: Create Purchase Order Custom SIT

### Step 4: Create Purchase Order Custom SIT (Complex Pattern)

Run the Purchase Order custom SIT creation script:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\01-CustomSITs\scripts"
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
✅ Procurement purchase order PO-5300-2025-GOOG issued (High confidence)
```

**Complex Pattern Design Tips**:

- Break patterns into logical segments (dept-year-vendor)
- Use character classes for specific requirements ([A-Z], [0-9], etc.)
- Test patterns at regex101.com before implementation
- Document pattern segments in SIT description
- Consider future pattern evolution (year format changes, vendor code updates)

**Character Classes Reference**:

```text
\d      = Any digit (0-9)
\d{n}   = Exactly n digits
[A-Z]   = Uppercase letter
[A-Z]{n} = Exactly n uppercase letters
[a-z]   = Lowercase letter
\w      = Word character (letter, digit, underscore)
\s      = Whitespace
.       = Any character
```

---

## ✅ Exercise 5: Validate Custom SITs

### Step 5: Validate Regex-Based Custom SITs

Wait **5-15 minutes** for global SIT replication, then run validation:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\01-CustomSITs\scripts"
.\Validate-CustomSITs.ps1 -TestDataPath "C:\PurviewLabs\Lab1-CustomSIT-Testing"
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

> **⏱️ Replication Timing**: Custom SITs replicate globally within 5-15 minutes. If validation shows zero detections immediately after creation, wait 10 minutes and retry.

---

## 🎯 Exercise 6: Confidence Level Tuning

### Step 6: Fine-Tune Confidence Levels

Analyze pattern detection accuracy and keyword effectiveness:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\01-CustomSITs\scripts"
.\Tune-SITConfidence.ps1 -SITName "Contoso Project Identifier" -TestDataPath "C:\PurviewLabs\Lab1-CustomSIT-Testing"
```

**What Gets Analyzed**:

The script uses `Validation_Results.csv` from Exercise 5 to calculate:

- **Precision**: % of detections that are correct (measures false positives)
- **Recall**: % of expected patterns found (measures missed detections)
- **Keyword Coverage**: % of test files where each keyword appears near patterns

**Interpreting Results**:

| Metric | Good Performance | Action Needed |
|--------|------------------|---------------|
| **Precision** | ≥ 90% | < 80%: Add specific keywords to reduce false positives |
| **Recall** | ≥ 90% | < 80%: Add keyword variations to catch missed patterns |
| **Keyword Coverage** | ≥ 60% | < 50%: Remove/replace underperforming keywords |

**Expected Lab Results**: 100% precision and recall (test data is keyword-rich by design)

**Tuning Process** (if metrics show issues):

1. Edit keyword arrays in Create-[SITName]SIT.ps1
2. Re-run creation script with updated keywords
3. Validate with Validate-CustomSITs.ps1
4. Re-run tuning script to measure improvement

**Confidence Level Usage Guidelines**:

| Confidence Level | Use Case | DLP Policy Action |
|------------------|----------|-------------------|
| **High (85%)** | Pattern + strong keyword context | Block/Encrypt |
| **Medium (75%)** | Pattern + partial keywords | Notify user |
| **Low (65%)** | Pattern only | Audit/Report only |

> **💡 Lab Note**: Perfect metrics (100%/100%) are expected because test data was designed with keyword-rich content. Production data will show variation - use this process to refine based on real organizational documents.

---

## 💾 Exercise 7: Export Custom SIT Rule Package

### Step 7: Create Backup Documentation

Export custom SIT metadata for documentation and reference:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Classification-Lifecycle-Labs\01-CustomSITs\scripts"
.\Export-CustomSITPackage.ps1 -OutputPath "C:\PurviewLabs\Lab1-CustomSIT-Testing\SIT-Package-Backup.xml"
```

**Script Actions**:

- Exports all custom SIT metadata to CSV format (timestamped filename)
- Creates `SIT-Package-Backup_YYYYMMDD_HHMMSS_Metadata.csv` with SIT configurations
- Includes Name, Description, Publisher, State, Confidence levels
- Provides documentation reference for version control

**Expected Output Files**:

```text
C:\PurviewLabs\Lab1-CustomSIT-Testing\
├── SIT-Package-Backup_20251114_101227_Metadata.csv  (metadata export)
└── Validation_Results.csv  (from Exercise 5)
```

**What the Export Provides**:

| Information | Purpose |
|-------------|---------|
| **SIT Names** | Quick reference of all custom SITs created |
| **Patterns** | Documentation of regex patterns used |
| **Publishers** | Track which tenant created the SITs |
| **States** | Production vs Development status |
| **Export Date** | Version tracking and change history |

**Real-World Backup/Restore Scenarios**:

For production environments requiring full backup/restore capabilities:

1. **Manual Portal Export**: Use Purview portal to export SIT rule packages (XML format)
   - Navigate to **Data classification** → **Sensitive info types**
   - Select custom SIT → **Export** → Save XML rule package
2. **PowerShell Get-DlpSensitiveInformationType**: Document SIT configurations

   ```powershell
   Get-DlpSensitiveInformationType -Identity "Contoso Project Identifier" | 
       Select-Object Name, Description, Publisher, RecommendedConfidence |
       Export-Csv "SIT-Documentation.csv"
   ```

3. **Multi-Tenant Deployment**: Recreate SITs using creation scripts
   - Copy `Create-*SIT.ps1` scripts to target tenant
   - Run scripts in target tenant to recreate identical SITs
   - Validate with `Validate-CustomSITs.ps1`

> **⚠️ Lab Note**: The export script provides **metadata documentation only** for lab reference and version control. Full programmatic backup/restore of rule packages requires advanced Microsoft Graph API integration beyond lab scope. For production scenarios, use Purview portal export or maintain creation scripts in version control.
>
> **💡 Version Control Best Practice**: Store your `Create-*SIT.ps1` scripts in Git repositories as the source of truth. These scripts can recreate SITs identically across environments and serve as living documentation of your pattern designs.

---

## ✅ Validation Checklist

Use this checklist to verify Lab 1 completion:

### Custom SIT Creation

- [ ] Created **Contoso Project Identifier** SIT with PROJ-####-#### pattern
- [ ] Created **Contoso Customer Number** SIT with CUST-###### pattern
- [ ] Created **Contoso Purchase Order Number** SIT with PO-####-####-XXXX pattern
- [ ] Validated all three SITs detect patterns in local test documents
- [ ] Verified keyword-based confidence level scoring works correctly
- [ ] Confirmed SITs appear in Purview portal under **Data classification** → **Sensitive info types**

### Pattern Validation

- [ ] Tested patterns using regex101.com before deployment
- [ ] Verified word boundaries prevent false positives
- [ ] Validated character classes match expected data formats
- [ ] Tested edge cases (missing hyphens, wrong digit counts, case variations)

### Confidence Level Configuration

- [ ] Configured three confidence levels (High/Medium/Low) for each SIT
- [ ] Tested keyword proximity matching (300 characters)
- [ ] Verified High confidence requires full keyword set
- [ ] Confirmed Low confidence matches pattern only

### Backup and Documentation

- [ ] Exported custom SIT metadata for documentation reference
- [ ] Stored creation scripts in version control (Git)
- [ ] Documented pattern design decisions
- [ ] Recorded keyword selection rationale

---

## 🛠️ Troubleshooting Guide

### Common Issue: Custom SIT Not Detecting Patterns

**Symptoms**: SIT created successfully but validation shows zero detections

**Solutions**:

1. **Wait for replication**: Custom SITs take 5-15 minutes for global replication
2. **Verify pattern syntax**: Test regex at regex101.com before deployment
3. **Check word boundaries**: Ensure `\b` is used correctly to match whole words
4. **Validate test data**: Confirm test documents actually contain the expected patterns
5. **Review confidence levels**: Try Medium or Low confidence instead of High only

```powershell
# Force SIT configuration refresh
Get-DlpSensitiveInformationType | Where-Object {$_.Name -like "Contoso*"}
```

---

### Common Issue: Too Many False Positives

**Symptoms**: SIT detecting patterns in non-sensitive content

**Solutions**:

1. **Add keywords**: Increase required keyword matches for high confidence
2. **Refine regex**: Make pattern more specific (add word boundaries, context)
3. **Raise confidence threshold**: Require higher confidence for DLP policy triggers
4. **Test with production data**: Validate against real-world documents before deployment

**Example Refinement**:

```powershell
# Before (too broad):
$pattern = '\d{4}-\d{4}'

# After (more specific):
$pattern = '\bPROJ-\d{4}-\d{4}\b'  # Added word boundaries and PROJ prefix
```

---

### Common Issue: Keyword Proximity Not Working

**Symptoms**: High confidence matches not triggering despite keywords present

**Solutions**:

1. **Check proximity distance**: Default 300 characters - verify keywords are close enough
2. **Verify keyword list**: Ensure keywords are spelled correctly and case matches
3. **Test keyword variations**: Try plural forms, abbreviations, synonyms
4. **Review proximity calculation**: Purview counts characters, not words

**Debug Command**:

```powershell
# Check SIT configuration including keyword proximity
Get-DlpSensitiveInformationType -Identity "Contoso Project Identifier" | 
    Select-Object -ExpandProperty SensitiveInformationTypeRulePackages
```

---

### Common Issue: Pattern Matches Partial Strings

**Symptoms**: Pattern matching within larger identifiers incorrectly

**Solutions**:

1. **Add word boundaries**: Use `\b` at start and end of pattern
2. **Test boundary conditions**: Verify boundaries work with punctuation, spaces, line breaks
3. **Consider lookahead/lookbehind**: Advanced regex for complex boundary requirements

**Example Fix**:

```powershell
# Problem: Matches "123PROJ-2025-1234567"
$pattern = 'PROJ-\d{4}-\d{4}'

# Solution: Only matches exact format
$pattern = '\bPROJ-\d{4}-\d{4}\b'
```

---

## 📚 Additional Resources

### Microsoft Learn Documentation

- **Custom SITs Overview**: [https://learn.microsoft.com/purview/sit-create-custom](https://learn.microsoft.com/purview/sit-create-custom)
- **Regex Pattern Reference**: [https://learn.microsoft.com/purview/sit-regex-syntax](https://learn.microsoft.com/purview/sit-regex-syntax)
- **Confidence Levels**: [https://learn.microsoft.com/purview/sit-confidence-levels](https://learn.microsoft.com/purview/sit-confidence-levels)
- **Keyword Dictionaries**: [https://learn.microsoft.com/purview/sit-keyword-dictionaries](https://learn.microsoft.com/purview/sit-keyword-dictionaries)

### Tools and Testing

- **Regex Tester**: [https://regex101.com/](https://regex101.com/) - Test patterns before deployment
- **PowerShell ISE**: Built-in PowerShell editor for script development
- **VS Code**: Modern editor with PowerShell extension for advanced development

### Enterprise Best Practices

- **SIT Naming Conventions**: Use consistent prefixes (Contoso, Organization name)
- **Version Control**: Store SIT rule packages in Git for change tracking
- **Testing Workflow**: Dev tenant → staging validation → production deployment
- **Documentation**: Maintain pattern design rationale and keyword selection notes
- **Review Cadence**: Quarterly review of custom SIT effectiveness and accuracy

---

## ⏭️ Next Steps

**After completing Lab 1**:

1. Review local validation results for all custom SITs
2. Document any pattern refinements needed based on testing
3. Commit creation scripts and metadata export to version control (Git)
4. Proceed to **Lab 2: Exact Data Match (EDM) for Structured Data**
   - Implement EDM for employee database classification
   - Compare EDM accuracy (99%) vs regex-based accuracy (85-95%)
   - Learn when to use EDM vs regex-based custom SITs

**Skills Gained**:

✅ Regex pattern design for organization-specific identifiers  
✅ Keyword dictionary management for context-aware classification  
✅ Multi-level confidence scoring optimization  
✅ Custom SIT validation and local testing techniques  
✅ Pattern refinement and false positive reduction  
✅ Enterprise deployment and backup best practices  

---

## 🤖 AI-Assisted Content Generation

This comprehensive custom SIT lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview Information Protection capabilities, regex pattern best practices, and custom SIT workflows validated against Microsoft Learn documentation (November 2025).

*AI tools were used to enhance productivity and ensure comprehensive coverage of regex-based custom SIT creation while maintaining technical accuracy and reflecting enterprise-grade data classification standards.*
