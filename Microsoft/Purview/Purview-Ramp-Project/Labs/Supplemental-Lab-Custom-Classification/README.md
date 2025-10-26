# Supplemental Lab 03: Custom Classification Techniques

## 📋 Overview

**Duration**: 4-6 hours (including 24-hour training wait for trainable classifiers)

**Objective**: Create custom Sensitive Information Types (SITs) using regex patterns and keyword lists, and build trainable classifiers using machine learning for organization-specific data patterns that built-in classifiers cannot detect.

**What You'll Learn:**

- Create custom regex-based Sensitive Information Types for organizational data patterns
- Configure character proximity, confidence levels, and supporting elements
- Build and train custom trainable classifiers using machine learning
- Prepare positive and negative sample sets for classifier training
- Test and validate custom classifiers before production deployment
- Integrate custom SITs and trainable classifiers with DLP policies
- Understand when to use regex-based vs. ML-based classification approaches

**Prerequisites from Labs 01-04:**

- ✅ Understanding of built-in SITs from Labs 01-02
- ✅ Experience with DLP policies from Lab 02
- ✅ SharePoint test site with document libraries from Lab 03
- ✅ Content Explorer and Activity Explorer familiarity from Lab 04
- ✅ Microsoft 365 E5 Compliance trial activated

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

1. **Custom SIT Creation**: Build regex-based patterns for organization-specific sensitive data
2. **Pattern Validation**: Use the Boost.RegEx engine to test and refine patterns
3. **Confidence Tuning**: Configure primary and supporting elements for accuracy
4. **Trainable Classifier Development**: Prepare sample sets and train ML-based classifiers
5. **Sample Set Curation**: Select appropriate positive and negative training samples
6. **Classifier Testing**: Validate trained classifiers before production use
7. **DLP Integration**: Apply custom classifiers to policies and retention labels
8. **Decision Framework**: Choose between Custom SITs and Trainable Classifiers based on use case

---

## 🚨 Important: Custom SIT vs. Trainable Classifier Decision Matrix

> **💡 Choosing the Right Approach**: Custom classification comes in two forms, each suited for different scenarios:

| Factor | Custom SIT (Regex-Based) | Trainable Classifier (ML-Based) |
|--------|-------------------------|--------------------------------|
| **Best For** | Structured data with predictable patterns | Unstructured documents with contextual meaning |
| **Examples** | Employee IDs, project codes, product SKUs, custom financial identifiers | Legal contracts, financial reports, strategic plans, HR documents |
| **Pattern Type** | Fixed format (numbers, letters, delimiters) | Variable content and structure |
| **Setup Time** | 30-60 minutes | 2-3 hours + 24-hour training |
| **Sample Requirements** | Regex pattern only | 50-500 positive + 150-1,500 negative samples |
| **Accuracy** | High for exact patterns | Improves with sample quality and quantity |
| **Maintenance** | Low (update regex as needed) | Medium (retraining requires recreation) |
| **Language Support** | All languages | **English only** for custom classifiers |
| **Recrawl Required** | Yes (SharePoint only) | Yes (SharePoint only) |

**Project Recommendation:**

- **Use Custom SITs** for: Project codes, employee IDs, custom product numbers, internal account formats
- **Use Trainable Classifiers** for: Financial report classification, legal document types, strategic business content, HR document categories

---

## 📖 Part A: Custom Sensitive Information Types (Regex-Based)

### Step 1: Plan Your Custom SIT Pattern

Before creating a custom SIT, identify the organizational data pattern you need to detect.

**Common Use Cases for Custom SITs:**

| Pattern Type | Example Format | Regex Complexity |
|--------------|----------------|------------------|
| **Employee ID** | `EMP-12345` or `E000123` | Low |
| **Project Code** | `PROJ-2025-FIN-001` | Low-Medium |
| **Product SKU** | `SKU-ABC-1234-XL` | Medium |
| **Custom Account Number** | `ACCT-1234-5678-9012` | Low |
| **Internal Reference** | `REF-2025-10-25-12345` | Medium |
| **Custom Financial ID** | `FIN-US-2025-Q4-001` | Medium-High |

**For This Lab, We'll Create:**

**Contoso Project Code SIT** to detect internal project identifiers:

- **Format**: `PROJ-[YEAR]-[DEPT]-[NUMBER]`
- **Examples**:
  - `PROJ-2025-FIN-001` (Finance project)
  - `PROJ-2024-HR-042` (HR project)
  - `PROJ-2025-IT-123` (IT project)
- **Pattern Rules**:
  - Starts with "PROJ-"
  - Year: 2020-2029
  - Department: 2-3 uppercase letters
  - Number: 3 digits

### Step 2: Create Custom SIT via Purview Portal

**Navigate to Custom SIT Creation:**

- Sign in to the **Microsoft Purview portal**: [https://purview.microsoft.com](https://purview.microsoft.com)
- Navigate to **Information Protection** > **Classifiers** > **Sensitive info types**
- Click **+ Create sensitive info type**

> **💡 Alternative Navigation**: **Data loss prevention** > **Classifiers** > **Sensitive info types** leads to the same location.

**Step 2.1: Name and Description**

- **Name**: `Contoso Project Code`
- **Description**: `Detects internal Contoso project identifiers in format PROJ-YYYY-DEPT-NNN where YYYY is year, DEPT is 2-3 letter department code, and NNN is 3-digit project number`
- Click **Next**

**Step 2.2: Define Patterns**

This is where you configure the regex pattern and confidence levels.

**Primary Element Configuration:**

- Click **Create pattern**
- **Pattern name**: `Project Code - High Confidence`
- Click **Add primary element** > **Regular expression**

**Regular Expression Details:**

- **ID**: `ContosoProjectCodeRegex`
- **Regular expression**: 
  ```regex
  \bPROJ-202[0-9]-[A-Z]{2,3}-\d{3}\b
  ```
- **String match**: ☑️ (recommended for performance)

> **🔍 Regex Breakdown**:
> - `\b` = Word boundary (ensures clean start)
> - `PROJ-` = Literal prefix
> - `202[0-9]` = Years 2020-2029
> - `-` = Literal delimiter
> - `[A-Z]{2,3}` = 2-3 uppercase letters (department code)
> - `-` = Literal delimiter
> - `\d{3}` = Exactly 3 digits
> - `\b` = Word boundary (ensures clean end)

- Click **Done**

**Character Proximity:**

- **Detect primary element within this many characters of supporting elements**: `300` (default)
- Leave as default for now (we'll add supporting elements next)

**Confidence Level:**

- **High confidence**: Selected by default
- **Instance count**: 
  - Minimum: `1`
  - Maximum: `500`

> **💡 Confidence Levels Explained**:
> - **High confidence**: Primary element + supporting elements (or very specific regex)
> - **Medium confidence**: Primary element + some supporting elements
> - **Low confidence**: Primary element only (more false positives)

Click **Create** to save this pattern.

**Step 2.3: Add Supporting Elements (Optional but Recommended)**

Supporting elements increase detection accuracy by requiring corroborating evidence.

**Edit the Pattern:**

- Click on the **Project Code - High Confidence** pattern you just created
- Under **Supporting elements**, click **Add supporting elements or group of elements**

**Add Keyword List:**

- Select **Keyword list**
- **ID**: `ProjectKeywords`
- **Case insensitive**: ☑️
- **Keywords** (add each on new line):
  ```
  project
  initiative
  program
  project code
  project id
  project identifier
  budget
  timeline
  deliverable
  milestone
  ```
- Click **Done**

**Character Proximity for Supporting Elements:**

- **Detect primary element within this many characters of supporting elements**: `300`

This means the keyword must appear within 300 characters of the project code pattern for high confidence detection.

**Add Medium Confidence Pattern (Primary Element Only):**

- Click **Create pattern** again
- **Pattern name**: `Project Code - Medium Confidence`
- Use the same regex primary element (Contoso Project Code Regex)
- **No supporting elements**
- **Confidence level**: Medium confidence
- **Instance count**: Min `1`, Max `500`
- Click **Create**

**Result**: Two patterns with different confidence levels:
1. **High confidence**: Regex match + keyword proximity
2. **Medium confidence**: Regex match only

Click **Next** to continue.

**Step 2.4: Choose Recommended Confidence Level**

- Select **High confidence level** (recommended default)
- This determines which pattern triggers DLP policies by default
- Click **Next**

**Step 2.5: Review and Finish**

- Review all settings
- Click **Create**
- Click **Done**

> **⏱️ Availability**: Custom SIT is immediately available for use in DLP policies, but SharePoint detection requires site reindexing (see Step 8 in Supplemental Lab 02).

---

### Step 3: Test Custom SIT with Built-In Simulator

Before deploying to production, validate your custom SIT patterns:

**Access the Testing Tool:**

- From **Sensitive info types** list, locate **Contoso Project Code**
- Click the **...** (three dots) > **Test**

**Test with Sample Content:**

Enter test content in the text box:

```text
Finance Project Update

The finance department has initiated PROJ-2025-FIN-001 to modernize our 
accounting systems. This project will integrate with PROJ-2024-IT-042 
for infrastructure support.

Project Budget: $250,000
Timeline: Q1-Q4 2025
Project Manager: Jane Smith

Additional project codes to track:
- PROJ-2025-FIN-002 (Audit automation)
- PROJ-2025-HR-015 (Employee portal)
- PROJ-2024-LEG-008 (Contract management)

Contact the project office for more information.
```

**Expected Results:**

| Match | Confidence | Reason |
|-------|------------|--------|
| `PROJ-2025-FIN-001` | **High** | Regex + "project" keyword nearby |
| `PROJ-2024-IT-042` | **High** | Regex + "project" keyword nearby |
| `PROJ-2025-FIN-002` | **High** | Regex + "project" keyword nearby |
| `PROJ-2025-HR-015` | **High** | Regex + "project" keyword nearby |
| `PROJ-2024-LEG-008` | **High** | Regex + "project" keyword nearby |

**Test False Positive Scenarios:**

```text
Random text: PROJ-2025-ABC-999 appears here without any context.

This should match at medium confidence only.
```

**Expected Result:**

| Match | Confidence | Reason |
|-------|------------|--------|
| `PROJ-2025-ABC-999` | **Medium** | Regex match only, no supporting keywords |

**Test Non-Matches:**

```text
These should NOT match:
- PROJ-2019-FIN-001 (year too old, outside 2020-2029)
- PROJ-2025-F-001 (department code too short, needs 2-3 letters)
- PROJ-2025-FIN-12 (project number too short, needs 3 digits)
- PROJECT-2025-FIN-001 (wrong prefix, should be PROJ- not PROJECT-)
```

**Verify Results:**

- Click **Test** button
- Review matches and confidence levels
- Adjust regex or supporting elements if needed
- Re-test until patterns match expectations

---

### Step 4: Create Test Documents for Custom SIT Validation

Create SharePoint documents to validate real-world detection:

**PowerShell Script to Create Test Documents:**

```powershell
# Connect to SharePoint
Connect-PnPOnline -Url "https://[tenant].sharepoint.com/sites/TestSite" -Interactive

# Create documents with custom SIT patterns
$testDocs = @(
    @{
        Name = "Finance_Project_Proposal.txt"
        Content = @"
FINANCE PROJECT PROPOSAL

Project Code: PROJ-2025-FIN-001
Project Name: Accounting System Modernization
Budget: $250,000
Timeline: 6 months

This project will modernize our accounting infrastructure.
Contact: finance@contoso.com
"@
    },
    @{
        Name = "HR_Initiative_Overview.txt"
        Content = @"
HR DEPARTMENT INITIATIVE

Project ID: PROJ-2025-HR-015
Initiative: Employee Self-Service Portal
Project Manager: Sarah Johnson

Timeline and deliverables for this project are outlined below.
"@
    },
    @{
        Name = "IT_Infrastructure_Plan.txt"
        Content = @"
IT INFRASTRUCTURE PROJECT

Reference: PROJ-2024-IT-042
Description: Network upgrade initiative
Budget: $500,000

This program will improve network performance.
"@
    },
    @{
        Name = "Mixed_Content_Report.txt"
        Content = @"
QUARTERLY REPORT

Multiple projects are underway:
- PROJ-2025-FIN-001 (Finance)
- PROJ-2025-FIN-002 (Audit)
- PROJ-2025-HR-015 (HR Portal)
- PROJ-2024-LEG-008 (Legal)

All project codes are tracking on schedule.
"@
    },
    @{
        Name = "Medium_Confidence_Test.txt"
        Content = @"
TECHNICAL DOCUMENT

Random reference: PROJ-2025-IT-123

No project-related keywords in this document, should trigger medium confidence only.
"@
    }
)

# Upload test documents
$testDocs | ForEach-Object {
    $fileName = $_.Name
    $content = $_.Content
    
    # Create local file
    $tempPath = "$env:TEMP\$fileName"
    $content | Out-File -FilePath $tempPath -Encoding UTF8
    
    # Upload to SharePoint
    Add-PnPFile -Path $tempPath -Folder "Documents" | Out-Null
    
    # Cleanup
    Remove-Item -Path $tempPath -Force
    
    Write-Host "✅ Created: $fileName" -ForegroundColor Green
}

Write-Host "`n✅ All test documents created successfully" -ForegroundColor Green
```

**Expected Files Created:**

- 5 test documents with varying project code patterns
- Mix of high confidence and medium confidence scenarios
- Ready for SharePoint reindexing and Content Explorer validation

---

### Step 5: Apply Custom SIT to DLP Policy

Integrate your custom SIT with existing DLP policies:

**Navigate to DLP Policies:**

- In **Microsoft Purview portal**, go to **Data loss prevention** > **Policies**
- Click **+ Create policy**

**Configure Custom SIT Policy:**

**Step 5.1: Categories**

- Select **Custom** > **Custom policy**
- Click **Next**

**Step 5.2: Name and Description**

- **Name**: `Contoso Project Code Protection`
- **Description**: `Protects internal project codes from unauthorized sharing`
- Click **Next**

**Step 5.3: Locations**

- Select locations:
  - ☑️ **SharePoint sites**
  - ☑️ **OneDrive accounts**
  - ☑️ **Exchange email**
  - ☑️ **Teams chat and channel messages**
- Click **Next**

**Step 5.4: Define Policy Settings**

- Select **Create or customize advanced DLP rules**
- Click **Next**

**Step 5.5: Create Rule**

- Click **+ Create rule**
- **Name**: `Block External Sharing of Project Codes`
- **Description**: `Prevents project codes from being shared externally`

**Conditions:**

- **Content contains** > **Add** > **Sensitive info types**
- Search for and select: **Contoso Project Code**
- **Instance count**: From `1` to `Any`
- Click **Add**

**Actions:**

- **Restrict access or encrypt the content in Microsoft 365 locations**
- Select **Block everyone**

**User Notifications:**

- ☑️ **Notify users in Office 365 service with a policy tip**
- ☑️ **Email notification**
- Customize notification text:
  ```
  This content contains Contoso project codes (PROJ-YYYY-DEPT-NNN). 
  Sharing project codes externally is prohibited by company policy.
  ```

**User Overrides:**

- ☐ Leave unchecked (no overrides for project codes)

**Incident Reports:**

- ☑️ **Send an alert to admins when a rule match occurs**
- Alert severity: **High**
- ☑️ **Use email incident reports to notify you when a policy match occurs**

Click **Save** and **Next**.

**Step 5.6: Policy Mode**

- Select **Turn it on right away**
- Click **Next**

**Step 5.7: Review and Finish**

- Review all settings
- Click **Submit**
- Click **Done**

---

### Step 6: Validate Custom SIT Detection

After creating the DLP policy and allowing time for SharePoint reindexing:

**Monitor Content Explorer:**

- Navigate to **Information Protection** > **Explorers** > **Content Explorer**
- Wait for Content Explorer sync (15 minutes to 24 hours)

**Filter by Custom SIT:**

- In **Sensitive info types** filter, select **Contoso Project Code**
- Review detected items:
  - File names
  - Locations (SharePoint sites)
  - Instance counts
  - Confidence levels

**Verify Detection Accuracy:**

| Document | Expected Detection | Confidence |
|----------|-------------------|------------|
| Finance_Project_Proposal.txt | ✅ PROJ-2025-FIN-001 | High |
| HR_Initiative_Overview.txt | ✅ PROJ-2025-HR-015 | High |
| IT_Infrastructure_Plan.txt | ✅ PROJ-2024-IT-042 | High |
| Mixed_Content_Report.txt | ✅ 4 project codes | High |
| Medium_Confidence_Test.txt | ✅ PROJ-2025-IT-123 | Medium |

**Monitor Activity Explorer:**

- Navigate to **Information Protection** > **Explorers** > **Activity Explorer**
- Filter by:
  - **DLP policy name**: Contoso Project Code Protection
  - **Date range**: Last 7 days

**Expected Activities:**

- Policy matches when project codes detected
- Email blocks if project codes in emails
- SharePoint blocks if external sharing attempted
- User notifications sent

---

## 📖 Part B: Trainable Classifiers (Machine Learning-Based)

### Step 7: Understand Trainable Classifier Requirements

Before creating a trainable classifier, understand the ML-based approach:

**Key Differences from Custom SITs:**

| Aspect | Custom SIT | Trainable Classifier |
|--------|-----------|---------------------|
| **Detection Method** | Pattern matching (regex) | Machine learning (content analysis) |
| **Training Required** | No | Yes (24 hours) |
| **Sample Documents** | None | 50-500 positive + 150-1,500 negative |
| **Language** | Any | **English only** |
| **Content Type** | Structured data | Unstructured documents |
| **Maintenance** | Update regex | Recreate and retrain (no incremental training) |

**When to Use Trainable Classifiers:**

✅ **Good Use Cases:**
- Legal contracts (identifying contract types)
- Financial reports (quarterly reports, audit documents)
- Strategic business plans
- HR documents (performance reviews, disciplinary actions)
- Regulatory filings (10-K, 10-Q, prospectus)

❌ **Poor Use Cases:**
- Structured data with fixed patterns (use Custom SIT)
- Non-English content (not supported)
- Highly variable content without common patterns
- Small document sets (<50 samples)

**For This Lab, We'll Create:**

**Contoso Financial Report Classifier** to detect quarterly financial reports:

- **Document Type**: Financial reports with revenue, expenses, balance sheets
- **Common Characteristics**:
  - Contains financial tables and charts
  - Includes revenue, expenses, profit/loss data
  - Has quarter/year references (Q1, Q2, Q3, Q4)
  - Contains executive summary sections
  - Includes financial terminology (EBITDA, gross margin, net income)

---

### Step 8: Prepare Training Sample Sets

Create two SharePoint document libraries for training samples:

**Create Sample Libraries:**

```powershell
# Connect to SharePoint
Connect-PnPOnline -Url "https://[tenant].sharepoint.com/sites/TestSite" -Interactive

# Create library for positive samples (financial reports)
New-PnPList -Title "Financial_Reports_Positive" -Template DocumentLibrary -Url "Lists/FinancialReportsPositive"

# Create library for negative samples (other business documents)
New-PnPList -Title "Financial_Reports_Negative" -Template DocumentLibrary -Url "Lists/FinancialReportsNegative"

Write-Host "✅ Training libraries created" -ForegroundColor Green
```

**Sample Requirements:**

| Sample Type | Minimum | Recommended | Maximum |
|-------------|---------|-------------|---------|
| **Positive samples** | 50 | 100-200 | 500 |
| **Negative samples** | 150 | 300-500 | 1,500 |

**Supported File Types:**

- `.docx`, `.docm`, `.doc` (Word documents)
- `.pdf` (PDFs)
- `.txt` (plain text)
- `.pptx`, `.pptm`, `.ppt` (PowerPoint)
- `.msg`, `.eml` (email messages)
- `.rtf` (rich text format)

> **⚠️ Important**: All samples must be in **English**. Mixed language or non-English content will reduce classifier accuracy.

---

### Step 9: Generate Positive Training Samples (Financial Reports)

Create realistic financial report samples:

**Option 1: Generate Synthetic Financial Reports**

```powershell
# Generate 100 positive samples (financial reports)
1..100 | ForEach-Object {
    $reportNumber = $_
    $quarter = "Q$((Get-Random -Minimum 1 -Maximum 4))"
    $year = Get-Random -Minimum 2022 -Maximum 2025
    $revenue = (Get-Random -Minimum 5000000 -Maximum 50000000)
    $expenses = [int]($revenue * ((Get-Random -Minimum 60 -Maximum 85) / 100))
    $netIncome = $revenue - $expenses
    $grossMargin = [math]::Round((($revenue - $expenses) / $revenue) * 100, 2)
    
    $content = @"
CONTOSO CORPORATION
QUARTERLY FINANCIAL REPORT
$quarter $year

EXECUTIVE SUMMARY

This report presents Contoso Corporation's financial performance for $quarter $year.
The company achieved strong revenue growth and maintained healthy profit margins.

FINANCIAL HIGHLIGHTS

Revenue: `$$($revenue.ToString('N0'))
Operating Expenses: `$$($expenses.ToString('N0'))
Net Income: `$$($netIncome.ToString('N0'))
Gross Margin: $grossMargin%
EBITDA: `$$((Get-Random -Minimum 1000000 -Maximum 10000000).ToString('N0'))

BALANCE SHEET SUMMARY

Total Assets: `$$((Get-Random -Minimum 50000000 -Maximum 200000000).ToString('N0'))
Total Liabilities: `$$((Get-Random -Minimum 20000000 -Maximum 100000000).ToString('N0'))
Shareholders' Equity: `$$((Get-Random -Minimum 30000000 -Maximum 100000000).ToString('N0'))

INCOME STATEMENT

Revenue
  Product Sales: `$$((Get-Random -Minimum 2000000 -Maximum 20000000).ToString('N0'))
  Service Revenue: `$$((Get-Random -Minimum 1000000 -Maximum 10000000).ToString('N0'))
  Other Income: `$$((Get-Random -Minimum 100000 -Maximum 1000000).ToString('N0'))

Expenses
  Cost of Goods Sold: `$$((Get-Random -Minimum 2000000 -Maximum 15000000).ToString('N0'))
  Sales & Marketing: `$$((Get-Random -Minimum 1000000 -Maximum 8000000).ToString('N0'))
  Research & Development: `$$((Get-Random -Minimum 500000 -Maximum 5000000).ToString('N0'))
  General & Administrative: `$$((Get-Random -Minimum 500000 -Maximum 3000000).ToString('N0'))

CASH FLOW STATEMENT

Operating Activities: `$$((Get-Random -Minimum 1000000 -Maximum 10000000).ToString('N0'))
Investing Activities: -`$$((Get-Random -Minimum 500000 -Maximum 5000000).ToString('N0'))
Financing Activities: -`$$((Get-Random -Minimum 200000 -Maximum 2000000).ToString('N0'))

MANAGEMENT DISCUSSION

The $quarter $year quarter demonstrated solid financial performance with revenue growth
driven by increased product sales and expanding service offerings. Operating margins
remained strong due to operational efficiency improvements and cost management initiatives.

Looking forward, we anticipate continued revenue growth in the next quarter supported
by new product launches and market expansion strategies.

FINANCIAL METRICS

Return on Equity (ROE): $((Get-Random -Minimum 10 -Maximum 25))%
Return on Assets (ROA): $((Get-Random -Minimum 5 -Maximum 15))%
Debt-to-Equity Ratio: $([math]::Round((Get-Random) + 0.3, 2))
Current Ratio: $([math]::Round((Get-Random) + 1.5, 2))

This financial report contains confidential information and is intended for internal use only.

END OF REPORT
"@
    
    # Create and upload
    $fileName = "Financial_Report_${quarter}_${year}_${reportNumber}.txt"
    $tempPath = "$env:TEMP\$fileName"
    $content | Out-File -FilePath $tempPath -Encoding UTF8
    
    Add-PnPFile -Path $tempPath -Folder "Financial_Reports_Positive" | Out-Null
    Remove-Item -Path $tempPath -Force
    
    if ($reportNumber % 10 -eq 0) {
        Write-Host "Created $reportNumber financial report samples..." -ForegroundColor Cyan
    }
}

Write-Host "✅ Created 100 positive training samples (financial reports)" -ForegroundColor Green
```

**Option 2: Use Real Financial Report Templates**

Download and modify actual public company financial reports:

- Search for "quarterly financial report template" or "10-Q template"
- Download 50-100 unique financial report documents
- Remove company-specific confidential information
- Upload to **Financial_Reports_Positive** library

---

### Step 10: Generate Negative Training Samples (Non-Financial Documents)

Create diverse business documents that are NOT financial reports:

```powershell
# Generate 200 negative samples (various business documents)
$documentTypes = @(
    @{Type="Meeting Minutes"; Template="MEETING MINUTES`n`nDate: {date}`nAttendees: {attendees}`n`nAgenda Items:`n- Project updates`n- Budget review`n- Action items`n`nDiscussion:`n{discussion}`n`nAction Items:`n- Follow up on pending tasks`n- Schedule next meeting"},
    @{Type="Marketing Plan"; Template="MARKETING STRATEGY`n`nCampaign: {campaign}`nTarget Audience: {audience}`n`nObjectives:`n- Increase brand awareness`n- Drive customer engagement`n- Generate qualified leads`n`nTactics:`n- Social media campaigns`n- Content marketing`n- Email marketing`n`nBudget: {budget}`nTimeline: {timeline}"},
    @{Type="HR Policy"; Template="HUMAN RESOURCES POLICY`n`nPolicy Name: {policy}`nEffective Date: {date}`n`nPurpose:`nThis policy establishes guidelines for {purpose}.`n`nScope:`nApplies to all employees, contractors, and temporary staff.`n`nProcedures:`n1. {procedure1}`n2. {procedure2}`n3. {procedure3}`n`nCompliance:`nEmployees must comply with this policy. Violations may result in disciplinary action."},
    @{Type="Technical Documentation"; Template="TECHNICAL SPECIFICATION`n`nSystem: {system}`nVersion: {version}`n`nArchitecture Overview:`n{architecture}`n`nComponents:`n- Frontend: {frontend}`n- Backend: {backend}`n- Database: {database}`n`nAPI Endpoints:`n- GET /api/{endpoint1}`n- POST /api/{endpoint2}`n`nSecurity Requirements:`n- Authentication: OAuth 2.0`n- Authorization: Role-based access control`n- Encryption: TLS 1.3"},
    @{Type="Project Status"; Template="PROJECT STATUS REPORT`n`nProject: {project}`nStatus: {status}`nCompletion: {completion}%`n`nMilestones:`n- {milestone1} - Completed`n- {milestone2} - In Progress`n- {milestone3} - Pending`n`nRisks and Issues:`n- {risk1}`n- {risk2}`n`nNext Steps:`n- {nextstep1}`n- {nextstep2}"},
    @{Type="Sales Proposal"; Template="SALES PROPOSAL`n`nClient: {client}`nSolution: {solution}`n`nExecutive Summary:`n{summary}`n`nProposed Solution:`n{solution_detail}`n`nPricing:`n- Base Package: {price1}`n- Premium Package: {price2}`n- Enterprise Package: {price3}`n`nImplementation Timeline:`n{timeline}`n`nTerms and Conditions:`n{terms}"}
)

1..200 | ForEach-Object {
    $docNumber = $_
    $docType = Get-Random -InputObject $documentTypes
    
    # Replace template placeholders with random data
    $content = $docType.Template
    $content = $content -replace '\{date\}', (Get-Date -Format 'yyyy-MM-dd')
    $content = $content -replace '\{attendees\}', ((1..(Get-Random -Minimum 3 -Maximum 8) | ForEach-Object { "Person $_" }) -join ', ')
    $content = $content -replace '\{discussion\}', "Discussion about $(Get-Random -InputObject @('strategy', 'operations', 'planning', 'improvements'))"
    $content = $content -replace '\{campaign\}', "Campaign $(Get-Random -Minimum 100 -Maximum 999)"
    $content = $content -replace '\{audience\}', (Get-Random -InputObject @('Enterprise customers', 'Small businesses', 'Consumers', 'Partners'))
    $content = $content -replace '\{budget\}', "`$$((Get-Random -Minimum 10000 -Maximum 100000).ToString('N0'))"
    $content = $content -replace '\{timeline\}', "$(Get-Random -Minimum 3 -Maximum 12) months"
    $content = $content -replace '\{policy\}', (Get-Random -InputObject @('Remote Work', 'Time Off', 'Code of Conduct', 'Data Security'))
    $content = $content -replace '\{purpose\}', (Get-Random -InputObject @('employee conduct', 'work arrangements', 'leave management', 'security practices'))
    $content = $content -replace '\{procedure\d\}', "Procedure step $(Get-Random -Minimum 1 -Maximum 10)"
    $content = $content -replace '\{system\}', "System-$(Get-Random -Minimum 100 -Maximum 999)"
    $content = $content -replace '\{version\}', "v$(Get-Random -Minimum 1 -Maximum 5).$(Get-Random -Minimum 0 -Maximum 9)"
    $content = $content -replace '\{architecture\}', "Cloud-based $(Get-Random -InputObject @('microservices', 'monolithic', 'serverless')) architecture"
    $content = $content -replace '\{frontend\}', (Get-Random -InputObject @('React', 'Angular', 'Vue.js'))
    $content = $content -replace '\{backend\}', (Get-Random -InputObject @('Node.js', '.NET Core', 'Python'))
    $content = $content -replace '\{database\}', (Get-Random -InputObject @('SQL Server', 'PostgreSQL', 'MongoDB'))
    $content = $content -replace '\{endpoint\d\}', "endpoint$(Get-Random -Minimum 1 -Maximum 99)"
    $content = $content -replace '\{project\}', "Project-$(Get-Random -Minimum 1000 -Maximum 9999)"
    $content = $content -replace '\{status\}', (Get-Random -InputObject @('On Track', 'At Risk', 'Delayed', 'Completed'))
    $content = $content -replace '\{completion\}', (Get-Random -Minimum 10 -Maximum 100)
    $content = $content -replace '\{milestone\d\}', "Milestone $(Get-Random -Minimum 1 -Maximum 10)"
    $content = $content -replace '\{risk\d\}', "Risk: $(Get-Random -InputObject @('Resource constraints', 'Technical challenges', 'Schedule delays'))"
    $content = $content -replace '\{nextstep\d\}', "Next step: $(Get-Random -InputObject @('Review requirements', 'Update timeline', 'Schedule meeting'))"
    $content = $content -replace '\{client\}', "Client-$(Get-Random -Minimum 100 -Maximum 999)"
    $content = $content -replace '\{solution\}', (Get-Random -InputObject @('Cloud Migration', 'Digital Transformation', 'Security Enhancement'))
    $content = $content -replace '\{summary\}', "Comprehensive solution for business needs"
    $content = $content -replace '\{solution_detail\}', "Detailed implementation plan with milestones"
    $content = $content -replace '\{price\d\}', "`$$((Get-Random -Minimum 50000 -Maximum 500000).ToString('N0'))"
    $content = $content -replace '\{terms\}', "Standard terms and conditions apply"
    
    # Create and upload
    $fileName = "$($docType.Type -replace ' ', '_')_${docNumber}.txt"
    $tempPath = "$env:TEMP\$fileName"
    $content | Out-File -FilePath $tempPath -Encoding UTF8
    
    Add-PnPFile -Path $tempPath -Folder "Financial_Reports_Negative" | Out-Null
    Remove-Item -Path $tempPath -Force
    
    if ($docNumber % 20 -eq 0) {
        Write-Host "Created $docNumber negative samples..." -ForegroundColor Cyan
    }
}

Write-Host "✅ Created 200 negative training samples (non-financial documents)" -ForegroundColor Green
```

**Verification:**

```powershell
# Verify sample counts
$positiveCount = (Get-PnPListItem -List "Financial_Reports_Positive" -PageSize 500).Count
$negativeCount = (Get-PnPListItem -List "Financial_Reports_Negative" -PageSize 500).Count

Write-Host "`n📊 Training Sample Summary:" -ForegroundColor Cyan
Write-Host "   Positive samples (financial reports): $positiveCount" -ForegroundColor Green
Write-Host "   Negative samples (other documents): $negativeCount" -ForegroundColor Green

if ($positiveCount -ge 50 -and $negativeCount -ge 150) {
    Write-Host "`n✅ Sample requirements met! Ready to create trainable classifier." -ForegroundColor Green
} else {
    Write-Host "`n⚠️  Need more samples:" -ForegroundColor Yellow
    if ($positiveCount -lt 50) {
        Write-Host "   - Add $($50 - $positiveCount) more positive samples" -ForegroundColor Yellow
    }
    if ($negativeCount -lt 150) {
        Write-Host "   - Add $($150 - $negativeCount) more negative samples" -ForegroundColor Yellow
    }
}
```

---

### Step 11: Create and Train Trainable Classifier

**Navigate to Trainable Classifiers:**

- Sign in to **Microsoft Purview portal**: [https://purview.microsoft.com](https://purview.microsoft.com)
- Navigate to **Data classification** > **Classifiers** > **Trainable classifiers**
  - Alternatively: **Information Protection** > **Classifiers** > **Trainable classifiers**
- Click **+ Create trainable classifier**

**Step 11.1: Name and Description**

- **Name**: `Contoso Financial Reports`
- **Description**: `Identifies quarterly financial reports containing revenue, expenses, balance sheets, and financial metrics`
- Click **Next**

**Step 11.2: Select SharePoint Sites with Training Samples**

- Click **Choose sites**
- Search for and select your test site: `TestSite`
- Click **Add**
- Click **Next**

> **💡 Important**: The classifier will scan ALL document libraries in the selected site(s). Ensure your positive and negative sample libraries are in the site you select.

**Step 11.3: Select Seed Content (Positive Samples)**

- The wizard displays all document libraries in the selected site
- Find and select: **Financial_Reports_Positive**
- Click **Next**

**Positive Sample Verification:**

- Review the list of documents that will be used for training
- Ensure count is between 50-500 documents
- All documents must be in English
- All documents should be examples of financial reports

**Step 11.4: Select Content to Help Define What This Isn't (Negative Samples)**

- Find and select: **Financial_Reports_Negative**
- Click **Next**

**Negative Sample Verification:**

- Review the list of documents
- Ensure count is between 150-1,500 documents
- Documents should represent various business content types (NOT financial reports)
- Click **Next**

**Step 11.5: Review and Finish**

- **Summary**:
  - Name: Contoso Financial Reports
  - Positive samples: ~100 financial report documents
  - Negative samples: ~200 diverse business documents
- Click **Create trainable classifier**

**Training Process Initiated:**

- Status changes to **Training in progress**
- Estimated time: **24 hours**
- You will receive email notification when training completes

> **⏰ Training Timeline**: The automated training process has been significantly improved (October 2025). Previous process took 12+ days, current process completes in approximately 24 hours.

---

### Step 12: Monitor Training Progress and Test Results

**Check Training Status:**

- Navigate to **Data classification** > **Classifiers** > **Trainable classifiers**
- Locate **Contoso Financial Reports**
- Status indicators:
  - **Training in progress** - Initial state (0-24 hours)
  - **Need test results** - Training complete, testing in progress
  - **Ready to use** - Testing passed, available for policies
  - **Not ready to use** - Testing failed, requires more samples

**After 24 Hours - Review Test Results:**

Once training completes, Microsoft automatically tests the classifier:

**Automatic Testing Process:**

- System holds back portion of training samples for testing
- Classifier predicts whether test documents match or don't match
- Calculates accuracy metrics:
  - **Precision**: Percentage of predicted matches that were actually financial reports
  - **Recall**: Percentage of actual financial reports that were correctly identified
  - **F1 Score**: Overall accuracy metric (balance of precision and recall)

**Expected Test Results:**

| Metric | Good Performance | Excellent Performance |
|--------|------------------|----------------------|
| **Precision** | 70-85% | 85-95% |
| **Recall** | 70-85% | 85-95% |
| **F1 Score** | 70-85% | 85-95% |

**View Detailed Test Results:**

- Click on **Contoso Financial Reports** classifier
- Review **Test results** tab:
  - **Predicted match**: Files classifier thinks are financial reports
  - **Predicted not a match**: Files classifier thinks are NOT financial reports
  - **Actual match**: Files that actually are financial reports (from positive samples)
  - **Actual not a match**: Files that are NOT financial reports (from negative samples)

**Confusion Matrix:**

| | Predicted Match | Predicted Not Match |
|---|---|---|
| **Actual Match** | True Positives (TP) | False Negatives (FN) |
| **Actual Not Match** | False Positives (FP) | True Negatives (TN) |

**If Test Results Are Poor (<70% accuracy):**

The classifier status will be **Not ready to use**. To improve:

1. **Delete the classifier** (cannot retrain existing classifiers)
2. **Improve sample quality**:
   - Add more positive samples (up to 500)
   - Add more negative samples (up to 1,500)
   - Ensure greater diversity in negative samples
   - Verify all samples are in English
   - Remove ambiguous or low-quality samples
3. **Recreate and retrain** with improved samples

> **⚠️ No Incremental Training**: Unlike some ML systems, Microsoft trainable classifiers cannot be retrained. You must delete and recreate with better samples if accuracy is insufficient.

**If Test Results Are Good (≥70% accuracy):**

- Status changes to **Ready to use**
- Classifier is available for:
  - DLP policies
  - Retention labels
  - Sensitivity labels
  - Communication compliance policies

---

### Step 13: Publish and Apply Trainable Classifier

Once status is **Ready to use**, publish the classifier for production use:

**Publish Trainable Classifier:**

- From **Trainable classifiers** list, click **Contoso Financial Reports**
- Click **Publish classifier**
- Confirm publishing action
- Status changes to **Publishing** → **Ready to use**

**Apply to DLP Policy:**

- Navigate to **Data loss prevention** > **Policies**
- Click **+ Create policy**

**Configure Financial Report DLP Policy:**

- **Category**: Custom > Custom policy
- **Name**: `Financial Report External Sharing Prevention`
- **Description**: `Prevents quarterly financial reports from being shared externally`
- **Locations**: SharePoint sites, OneDrive accounts, Exchange email, Teams
- Click **Next** through to **Define policy settings**
- Select **Create or customize advanced DLP rules**

**Create Rule with Trainable Classifier:**

- Click **+ Create rule**
- **Name**: `Block Financial Report Sharing`
- **Conditions**:
  - **Content contains** > **Add** > **Trainable classifiers**
  - Select: **Contoso Financial Reports**
  - Click **Add**
- **Actions**:
  - **Restrict access or encrypt the content in Microsoft 365 locations**
  - Select **Block everyone**
- **User notifications**: ☑️ Enable with custom message
- **Incident reports**: ☑️ Send to admins
- Click **Save** and complete policy creation

**Apply to Retention Labels:**

- Navigate to **Information governance** > **Labels** > **Retention labels**
- Click **+ Create a label**
- **Name**: `Financial Reports - 7 Year Retention`
- Configure retention settings (e.g., retain for 7 years)
- Under **Auto-apply settings**:
  - Select **Automatically apply a label to content that contains**
  - Choose **Trainable classifiers**
  - Select **Contoso Financial Reports**
- Complete label creation and publish

---

### Step 14: Validate Trainable Classifier Detection

Create test documents and verify classifier detection:

**Create New Test Documents:**

```powershell
# Create test financial reports (should be detected)
$testFinancialReport = @"
CONTOSO CORPORATION QUARTERLY FINANCIAL REPORT
Q4 2025

EXECUTIVE SUMMARY
This report presents Q4 2025 financial performance.

FINANCIAL HIGHLIGHTS
Revenue: $15,000,000
Operating Expenses: $10,500,000
Net Income: $4,500,000
Gross Margin: 30%

BALANCE SHEET
Total Assets: $75,000,000
Total Liabilities: $35,000,000
Shareholders' Equity: $40,000,000
"@

$testFinancialReport | Out-File -FilePath "$env:TEMP\Q4_2025_Report.txt" -Encoding UTF8

# Upload to SharePoint
Connect-PnPOnline -Url "https://[tenant].sharepoint.com/sites/TestSite" -Interactive
Add-PnPFile -Path "$env:TEMP\Q4_2025_Report.txt" -Folder "Documents" | Out-Null

# Create non-financial document (should NOT be detected)
$testNonFinancial = @"
PROJECT STATUS UPDATE

Project: Website Redesign
Status: On Track
Completion: 75%

Milestones:
- Design phase completed
- Development in progress
- Testing planned for next month
"@

$testNonFinancial | Out-File -FilePath "$env:TEMP\Project_Status.txt" -Encoding UTF8
Add-PnPFile -Path "$env:TEMP\Project_Status.txt" -Folder "Documents" | Out-Null

Write-Host "✅ Test documents uploaded" -ForegroundColor Green
```

**Monitor Content Explorer (24-48 hours later):**

- Navigate to **Information Protection** > **Explorers** > **Content Explorer**
- Filter by **Trainable classifiers** > **Contoso Financial Reports**
- Verify:
  - ✅ Q4_2025_Report.txt appears (correctly identified as financial report)
  - ✅ Project_Status.txt does NOT appear (correctly identified as non-financial)

**Monitor Activity Explorer:**

- Navigate to **Information Protection** > **Explorers** > **Activity Explorer**
- Filter by **DLP policy name**: Financial Report External Sharing Prevention
- Look for policy matches on financial report documents

---

## 🎯 Lab 03 Completion Summary

**Skills Acquired:**

✅ **Custom SIT Creation**: Regex-based patterns for organizational data (project codes)
✅ **Pattern Configuration**: Primary elements, supporting elements, confidence levels
✅ **Regex Testing**: Built-in simulator for pattern validation
✅ **Custom SIT Integration**: DLP policies, Content Explorer, Activity Explorer
✅ **Trainable Classifier Development**: ML-based classification for unstructured content
✅ **Sample Set Curation**: Positive and negative training sample preparation
✅ **Classifier Training**: 24-hour automated training process
✅ **Accuracy Validation**: Test results interpretation and optimization
✅ **Production Deployment**: Publishing and applying classifiers to policies and labels

**Project Alignment:**

This lab directly addresses your consultancy project requirements:

- **Gap #4 (Custom Classifiers)**: ✅ FULLY COVERED
  - Custom SITs for structured organizational data patterns
  - Trainable classifiers for unstructured document classification

**Decision Framework for Future Classification Needs:**

| Scenario | Recommended Approach | Example |
|----------|---------------------|---------|
| Fixed format organizational IDs | **Custom SIT** (regex) | Employee IDs, product codes, account numbers |
| Structured data patterns | **Custom SIT** (regex) | Custom financial identifiers, project codes |
| Document type classification | **Trainable Classifier** (ML) | Financial reports, legal contracts, HR documents |
| Content with contextual meaning | **Trainable Classifier** (ML) | Strategic plans, regulatory filings |
| Non-English content | **Custom SIT** (regex only) | Trainable classifiers are English-only |
| Quick deployment needed | **Custom SIT** (30-60 min) | Immediate pattern detection |
| High accuracy for complex docs | **Trainable Classifier** (2-3 hours + 24hr training) | Document categorization |

**Integration with Other Labs:**

| Lab | Integration Point | Benefit |
|-----|-------------------|---------|
| **Lab 02** | DLP policies + custom classifiers | Enhanced protection for organization-specific data |
| **Lab 03** | Retention labels + trainable classifiers | Automatic classification and retention |
| **Lab 04** | Content/Activity Explorer + custom SITs | Comprehensive reporting with organizational patterns |
| **Supplemental Lab 02** | On-demand classification + custom classifiers | Targeted scanning with organization-specific detection |

**Next Steps:**

- Update main README to reference Supplemental Labs 02-03
- Apply custom SITs and trainable classifiers to real organizational data patterns
- Monitor accuracy and refine patterns based on false positives/negatives
- Train team members on when to use Custom SITs vs. Trainable Classifiers

---

## 📚 Reference Documentation

All lab steps are validated against current Microsoft Learn documentation (October 2025):

- [Create custom sensitive information types](https://learn.microsoft.com/en-us/purview/create-a-custom-sensitive-information-type)
- [Custom sensitive information types in the Microsoft Purview compliance portal](https://learn.microsoft.com/en-us/purview/create-a-custom-sensitive-information-type-in-compliance-portal)
- [Learn about trainable classifiers](https://learn.microsoft.com/en-us/purview/classifier-learn-about)
- [Create and publish custom trainable classifiers](https://learn.microsoft.com/en-us/purview/classifier-get-started-with)
- [Regular expressions in Boost.RegEx 5.1.3](https://www.boost.org/doc/libs/1_68_0/libs/regex/doc/html/)
- [Use a custom sensitive information type in DLP policies](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)
- [Apply retention labels automatically](https://learn.microsoft.com/en-us/purview/apply-retention-labels-automatically)

---

## 🤖 AI-Assisted Content Generation

This custom classification techniques supplemental lab was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview custom sensitive information type creation workflows, trainable classifier training methodologies, and machine learning-based classification capabilities validated against Microsoft Learn documentation (October 2025).

*AI tools were used to enhance productivity and ensure comprehensive coverage of both regex-based pattern matching (Custom SITs) and machine learning-based content classification (Trainable Classifiers) while maintaining technical accuracy and reflecting current Purview portal navigation, sample preparation requirements, and production deployment best practices.*
