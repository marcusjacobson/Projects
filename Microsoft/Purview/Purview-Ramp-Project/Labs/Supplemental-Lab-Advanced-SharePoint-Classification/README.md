# Supplemental Lab 02: Advanced SharePoint & OneDrive Classification

## 📋 Overview

**Duration**: 3-4 hours

**Objective**: Master advanced SharePoint Online and OneDrive classification techniques including on-demand targeted scanning, search schema optimization for large-scale environments, and selective high-risk site targeting strategies.

**What You'll Learn:**

- Configure On-Demand Classification for selective SharePoint/OneDrive targeting
- Optimize SharePoint search indexing and managed properties for classification
- Implement selective targeting strategies for high-risk sites
- Understand search schema architecture and crawled property mapping
- Manually trigger site reindexing for immediate classification updates
- Estimate classification costs for large-scale environments

**Prerequisites from Labs 01-04:**

- ✅ Understanding of Sensitive Information Types (SITs) from Labs 01-02
- ✅ Experience with DLP policies and Activity Explorer from Lab 02-04
- ✅ SharePoint test site with sample sensitive data from Lab 03
- ✅ Microsoft 365 E5 Compliance trial activated

---

## 🎯 Lab Objectives

By the end of this lab, you will be able to:

1. **On-Demand Classification**: Create and execute targeted classification scans for specific SharePoint sites
2. **Search Schema Management**: Understand and configure managed properties for classification optimization
3. **Indexing Optimization**: Trigger manual site reindexing to accelerate classification
4. **Selective Targeting**: Implement strategies for high-risk site identification and targeted scanning
5. **Cost Estimation**: Calculate and optimize costs for large-scale classification projects
6. **Site-Specific Scans**: Configure scanner content scan jobs for specific SharePoint libraries
7. **Classification Results Analysis**: Interpret on-demand classification results and Content Explorer updates

---

## 🚨 Important: Modern SharePoint Classification Approaches

> **💡 Current State (October 2025)**: Microsoft Purview now offers multiple approaches for SharePoint/OneDrive classification:
>
> - **Continuous Classification**: Real-time classification for new/modified files (covered in Lab 03)
> - **On-Demand Classification**: Targeted scanning for historical data (this lab, **recommended for project use**)
> - **Information Protection Scanner**: On-premises + SharePoint on-premises only (Labs 01-02)
>
> **Project Alignment**: On-Demand Classification addresses your consultancy project's need to selectively target high-risk SharePoint sites without full tenant scans.

---

## 🧪 Lab Environment: Creating Test Data at Scale

To effectively test on-demand classification and search schema optimization, you need a substantial dataset. Here are practical approaches for ingesting test data:

### Option 1: Generate Synthetic Sensitive Documents (Recommended for Labs)

Use PowerShell to create realistic test documents with embedded sensitive information:

**Create 1,000+ Test Documents with PII:**

```powershell
# Connect to SharePoint Online
Connect-PnPOnline -Url "https://[tenant].sharepoint.com/sites/Finance" -Interactive

# Sample sensitive data patterns
$creditCards = @(
    "4532-1234-5678-9010", "5425-2334-3010-9876", "3782-822463-10005",
    "6011-1111-1111-1117", "3056-9309-0259-04", "4916-3385-0975-3862"
)

$ssns = @(
    "123-45-6789", "987-65-4321", "456-78-9012", 
    "234-56-7890", "345-67-8901", "567-89-0123"
)

$names = @(
    "John Smith", "Jane Doe", "Michael Johnson", "Sarah Williams",
    "David Brown", "Emily Davis", "Robert Miller", "Lisa Wilson"
)

# Generate 1000 documents with varying sensitive content
1..1000 | ForEach-Object {
    $docNumber = $_
    
    # Randomly decide content type (40% sensitive, 60% normal)
    $includeSensitive = (Get-Random -Maximum 100) -lt 40
    
    if ($includeSensitive) {
        # Create document with sensitive data
        $content = @"
Financial Report - Document $docNumber
Date: $(Get-Date -Format 'yyyy-MM-dd')

Customer Information:
Name: $(Get-Random -InputObject $names)
SSN: $(Get-Random -InputObject $ssns)
Credit Card: $(Get-Random -InputObject $creditCards)

Account Balance: `$$((Get-Random -Minimum 1000 -Maximum 50000))
Transaction History: Approved for $(Get-Random -Minimum 5 -Maximum 20) transactions.

This document contains confidential customer data for internal use only.
"@
    } else {
        # Create normal document
        $content = @"
General Report - Document $docNumber
Date: $(Get-Date -Format 'yyyy-MM-dd')

Summary: This is a general business document without sensitive information.
Status: $(Get-Random -InputObject @('Active', 'Pending', 'Completed'))
Department: $(Get-Random -InputObject @('Marketing', 'Sales', 'Operations'))

No confidential data included in this document.
"@
    }
    
    # Create file locally
    $fileName = "TestDoc_$docNumber.txt"
    $tempPath = "$env:TEMP\$fileName"
    $content | Out-File -FilePath $tempPath -Encoding UTF8
    
    # Upload to SharePoint with date variation (distribute across 3 years)
    $daysBack = Get-Random -Minimum 0 -Maximum 1095  # 0-3 years
    $fileDate = (Get-Date).AddDays(-$daysBack)
    
    Add-PnPFile -Path $tempPath -Folder "Documents" | Out-Null
    
    # Update Created date for realistic distribution
    Set-PnPListItem -List "Documents" -Identity (Get-PnPListItem -List "Documents" -Fields "FileLeafRef" -Query "<View><Query><Where><Eq><FieldRef Name='FileLeafRef'/><Value Type='Text'>$fileName</Value></Eq></Where></Query></View>").Id -Values @{
        "Created" = $fileDate
        "Modified" = $fileDate.AddDays((Get-Random -Minimum 1 -Maximum 30))
    }
    
    # Clean up temp file
    Remove-Item -Path $tempPath -Force
    
    # Progress indicator every 50 files
    if ($docNumber % 50 -eq 0) {
        Write-Host "Created $docNumber documents..." -ForegroundColor Cyan
    }
}

Write-Host "✅ Completed: 1000 test documents uploaded with ~400 containing sensitive data" -ForegroundColor Green
```

**Expected Result:**

- 1,000 documents distributed across 3 years
- ~400 documents with Credit Card, SSN, and PII
- ~600 clean documents (for false positive testing)
- Mixed file ages for date range filtering validation

### Option 2: Duplicate and Modify Existing Lab Documents

Leverage documents from Labs 01-04 and scale them up:

```powershell
# Connect to source and target sites
Connect-PnPOnline -Url "https://[tenant].sharepoint.com/sites/TestSite" -Interactive

# Get existing test documents
$sourceFiles = Get-PnPListItem -List "Documents" -PageSize 500

# Duplicate each file 10 times with modifications
$sourceFiles | ForEach-Object {
    $sourceFile = $_
    $fileName = $sourceFile.FieldValues.FileLeafRef
    
    # Download original
    Get-PnPFile -Url $sourceFile.FieldValues.FileRef -Path $env:TEMP -Filename "temp_$fileName" -AsFile -Force
    
    # Create 10 variations
    1..10 | ForEach-Object {
        $variation = $_
        $newFileName = $fileName -replace '\.', "_v$variation."
        
        # Copy file (content modification optional)
        Copy-Item -Path "$env:TEMP\temp_$fileName" -Destination "$env:TEMP\$newFileName"
        
        # Upload variation
        Add-PnPFile -Path "$env:TEMP\$newFileName" -Folder "Documents" | Out-Null
        
        # Cleanup
        Remove-Item "$env:TEMP\$newFileName" -Force
    }
    
    # Cleanup temp original
    Remove-Item "$env:TEMP\temp_$fileName" -Force
}
```

**Expected Result:**

- Original 50-100 lab documents → 500-1,000 documents
- Preserves realistic sensitive content from Labs 01-04
- Quick scaling without creating new content

### Option 3: Import Sample Microsoft Datasets

Use publicly available Microsoft sample datasets:

**Contoso Sample Data:**

```powershell
# Download Contoso sample documents
$sampleDataUrl = "https://github.com/MicrosoftDocs/mslearn-purview-data-catalog/archive/refs/heads/main.zip"
$downloadPath = "$env:TEMP\ContosoDB.zip"

# Download and extract
Invoke-WebRequest -Uri $sampleDataUrl -OutFile $downloadPath
Expand-Archive -Path $downloadPath -DestinationPath "$env:TEMP\ContosoData" -Force

# Upload to SharePoint
Connect-PnPOnline -Url "https://[tenant].sharepoint.com/sites/Finance" -Interactive

Get-ChildItem "$env:TEMP\ContosoData" -Recurse -File | ForEach-Object {
    Add-PnPFile -Path $_.FullName -Folder "SampleData" | Out-Null
}

Write-Host "✅ Uploaded Contoso sample dataset to SharePoint" -ForegroundColor Green
```

> **💡 Alternative Sample Datasets**:
> 
> - [Microsoft Learn sample files](https://learn.microsoft.com/en-us/training/modules/protect-information-sensitivity-labels/)
> - [Northwind sample data](https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/northwind-pubs)
> - [Adventure Works sample documents](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks)

### Option 4: Bulk Upload via SharePoint Migration Tool (For 10,000+ Files)

For large-scale testing (10,000+ files), use the official Microsoft tool:

**Download and Configure:**

- Download [SharePoint Migration Tool (SPMT)](https://aka.ms/spmt-ga-page)
- Install on your local machine or Azure VM

**Create Local Test Dataset:**

```powershell
# Create 10,000+ local files with sensitive data patterns
$outputFolder = "C:\TestData\Finance"
New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null

1..10000 | ForEach-Object {
    $content = @"
Financial Record $_
SSN: $(Get-Random -Minimum 100000000 -Maximum 999999999 | ForEach-Object { $_.ToString().Insert(3,'-').Insert(6,'-') })
Credit Card: 4532-$(Get-Random -Minimum 1000 -Maximum 9999)-$(Get-Random -Minimum 1000 -Maximum 9999)-$(Get-Random -Minimum 1000 -Maximum 9999)
Date: $(Get-Date -Format 'yyyy-MM-dd')
"@
    $content | Out-File -FilePath "$outputFolder\Finance_Record_$_.txt" -Encoding UTF8
    
    if ($_ % 1000 -eq 0) {
        Write-Host "Created $_ files..." -ForegroundColor Cyan
    }
}
```

**Migrate to SharePoint:**

- Open SharePoint Migration Tool
- Select **SharePoint** as source
- Source: `C:\TestData\Finance`
- Destination: `https://[tenant].sharepoint.com/sites/Finance/Documents`
- Click **Migrate**
- Monitor progress (typically 1,000-5,000 files per hour)

**Expected Result:**

- 10,000+ files for realistic large-scale testing
- Faster than API-based upload for bulk operations
- Preserves file metadata and timestamps

### Option 5: Use Microsoft 365 Test Data Generator (Advanced)

For enterprise-scale testing, use Microsoft's internal test data generator:

```powershell
# Install Microsoft Graph PowerShell SDK
Install-Module Microsoft.Graph -Scope CurrentUser

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Sites.ReadWrite.All", "Files.ReadWrite.All"

# Create test site hierarchy with data
# (Requires custom implementation using Graph API batch operations)
```

> **⚠️ Note**: This approach requires custom development but enables programmatic creation of realistic site structures, metadata, and content at scale.

### Recommended Approach for This Lab

**Balanced Test Dataset (1,500 files, 2-3 hours)**:

| Source | Files | Sensitive Content | Purpose |
|--------|-------|-------------------|---------|
| **Option 1 (Synthetic)** | 1,000 | ~400 with PII | Primary test dataset |
| **Lab 01-04 documents** | 50 | High accuracy PII | Validation baseline |
| **Duplicated variations** | 450 | Mixed | Volume testing |
| **TOTAL** | **1,500** | **~450 (30%)** | Realistic distribution |

**Execution Plan:**

1. **Day 1**: Create 1,000 synthetic documents using Option 1 (30-45 minutes)
2. **Day 1**: Duplicate Lab 01-04 documents 10x using Option 2 (15-20 minutes)
3. **Day 1**: Wait for automatic crawl (~1-2 hours) OR trigger manual reindex (Step 8)
4. **Day 2**: Execute on-demand classification scan (Steps 2-6)
5. **Day 2**: Analyze results and optimize (Steps 7-9)

**Cost Estimate:**

- 1,500 files @ $0.50 per 1,000 items = **~$0.75** for on-demand classification
- Storage: Negligible (1,500 × ~2KB average = ~3MB)
- **Total estimated cost**: <$1.00

---

## 📖 Step-by-Step Instructions

### Step 1: Understanding SharePoint Search Architecture

Before implementing selective classification, understand how SharePoint indexing and search schema impact classification performance.

**SharePoint Search Components:**

Navigate to Microsoft Learn to review current architecture:

- [Search solutions for SharePoint](https://learn.microsoft.com/en-us/sharepoint/dev/solution-guidance/search-solutions-in-sharepoint-2013-and-sharepoint-online)

**Key Concepts:**

| Component | Purpose | Classification Impact |
|-----------|---------|----------------------|
| **Crawl** | Discovers content and metadata | Determines what files are available for classification |
| **Content Processing** | Maps crawled properties to managed properties | Enables searchable classification metadata |
| **Index** | Stores processed content | Source for classification queries and reporting |
| **Managed Properties** | Searchable/refinable metadata | Custom properties for classification tracking |

**Classification Workflow:**

```text
File Created/Modified
    ↓
Crawl Process (automatic or manual)
    ↓
Content Processing (extract metadata)
    ↓
Search Index Updated
    ↓
Classification Available
    ↓
Policies Applied (DLP, Retention, etc.)
```

> **⏱️ Automatic Crawl Schedule**: SharePoint Online automatically crawls content, but timing varies (minutes to hours). Manual reindexing accelerates this process.

---

### Step 2: Configure On-Demand Classification (Targeted Scanning)

**Use Case**: Your project needs to scan specific high-risk SharePoint sites for historical sensitive data without scanning the entire tenant.

**Navigate to On-Demand Classification:**

- Sign in to the **Microsoft Purview portal**: [https://purview.microsoft.com](https://purview.microsoft.com)
- Navigate to **Data loss prevention** > **Classifiers** > **On-demand classification**
  - Alternatively: **Information Protection** > **Classifiers** > **On-demand classification**

> **💡 Portal Navigation**: On-demand classification is available in both **Data loss prevention** and **Information Protection** sections. The functionality is identical.

**Create New Scan:**

- Click **+ New scan** to start the wizard
- Follow the wizard to configure your targeted scan

**Step 2.1: Name and Description**:

- **Name**: `High-Risk-Sites-Classification-Scan`
- **Description**: `Targeted classification scan for Finance and HR SharePoint sites containing potentially sensitive data for remediation project`
- Click **Next**

**Step 2.2: Scope and Location (Selective Targeting)**:

This is where you implement selective targeting strategy:

**Targeting Options:**

| Option | Use Case | Example |
|--------|----------|---------|
| **All SharePoint sites and OneDrive accounts** | Full tenant scan (not recommended for selective targeting) | Complete organizational audit |
| **Only specific ones** | **Recommended for project**: Target known high-risk sites | Finance site, HR site, Executive site |
| **Skip certain sites** | Scan tenant except low-risk areas | Exclude marketing, public sites |

**For Selective High-Risk Targeting:**

- Select **Only specific ones**
- Click **Choose sites**
- Enter specific site URLs:
  - `https://[tenant].sharepoint.com/sites/Finance`
  - `https://[tenant].sharepoint.com/sites/HumanResources`
  - `https://[tenant].sharepoint.com/sites/ExecutiveTeam`
- Click **Add** for each site
- Click **Next**

> **🎯 Project Tip**: For your consultancy project, create a list of high-risk sites based on:
> - Departments handling sensitive data (Finance, HR, Legal)
> - Known data classification concerns from stakeholders
> - Previous audit findings or compliance requirements
> - Sites with older data (3+ years) identified in discovery

**Step 2.3: Classifiers to Scan For**

Choose which sensitive information types and trainable classifiers to include:

**Default Behavior:**

- Scans for **all available classifiers** in your tenant (both built-in and custom)
- Can process up to **50 classifiers per scan**

**For Targeted Classification (Recommended):**

- Select **Select specific classifiers**
- Choose relevant SITs for your project:
  - ☑️ Credit Card Number
  - ☑️ U.S. Social Security Number (SSN)
  - ☑️ U.S. Passport Number
  - ☑️ All Types of Medical Terms
  - ☑️ [Any custom SITs you created in Supplemental Lab 03]
- Click **Next**

> **⚠️ Important**: Selecting specific classifiers improves scan performance and cost. Only selected classifiers will update their classification results for scanned files.

**Step 2.4: File Last Modified Date Range**

Configure time-based targeting to focus on older, unclassified data:

**Options:**

| Date Range | Use Case | Project Alignment |
|------------|----------|-------------------|
| **Past year** (default) | Recently modified files | Quick validation scan |
| **Past 3 years** | **Recommended**: Focuses on data nearing retention limits | Remediation project data age criteria |
| **Past 5 years** | Long-term historical scan | Comprehensive audit |
| **Custom range** | Specific date spans | Targeted regulatory compliance |

**For Project Use:**

- Select **Past 3 years** to align with your remediation criteria
- This matches the "3+ years old" threshold from Lab 04 remediation planning
- Click **Next**

**Step 2.5: File Extensions**

Default behavior includes all supported file extensions. You can customize if needed:

**Supported Extensions** (partial list):
- Documents: `.docx`, `.doc`, `.pdf`, `.txt`, `.rtf`
- Spreadsheets: `.xlsx`, `.xls`, `.csv`
- Presentations: `.pptx`, `.ppt`
- Emails: `.msg`, `.eml`
- OneNote: `.one`
- And many more...

**For Most Projects:**

- Leave default (all extensions) unless you have specific requirements
- Click **Next**

---

### Step 3: Review Estimation and Optimize Scope

After configuring the scan, Purview provides an **estimation phase** before actual classification begins.

**Estimation Process:**

- Duration: Depends on scope (typically **15-30 minutes** for moderate site collection)
- Purpose: Calculate total files, estimated cost, and processing time
- Limits: 
  - Maximum **50,000 locations** (sites/OneDrive accounts)
  - Maximum **20 million files** per scan

**Review Estimation Results:**

- From the **On-demand classification** page, select your scan
- Click **View estimation**

**Estimation Overview Tab:**

| Metric | Example Value | Analysis |
|--------|---------------|----------|
| **Total items found** | 45,230 | Files matching criteria |
| **Estimated cost** | $22.62 | Based on pay-as-you-go pricing |
| **Estimated duration** | 6-8 hours | Processing time estimate |
| **Sites included** | 3 | High-risk sites targeted |

> **💰 Cost Optimization**: On-demand classification uses pay-as-you-go billing. Current pricing (October 2025) is approximately **$0.50 per 1,000 items classified**. Always review estimation before starting classification.

**Optimization Options:**

If estimation shows higher cost/volume than expected:

- **Edit scan**: Click **Edit scan** button
- **Narrow scope**: 
  - Reduce date range (e.g., past 1 year instead of 3)
  - Select fewer classifiers
  - Target specific document libraries instead of entire sites
- **Rerun estimation**: After edits, estimation recalculates
- **Proceed when satisfied**: Balance between coverage and cost

---

### Step 4: Execute Classification Scan

After reviewing and accepting the estimation:

**Start Classification:**

- On the **Estimation overview** tab, click **Start classification**
- Confirm the action when prompted
- Scan status changes to **In progress**

**Monitor Progress:**

- **Progress percentage**: Visible on scan overview page
- **Items classified**: Real-time count updates
- **Estimated time remaining**: Adjusted based on processing rate

**Typical Timeline:**

| Scope | Estimated Duration | Monitoring Recommendation |
|-------|-------------------|---------------------------|
| Small (1-5K items) | 30-60 minutes | Check hourly |
| Medium (5-50K items) | 2-8 hours | Check every 2-4 hours |
| Large (50K+ items) | 8-24 hours | Check daily |

> **⏰ Best Practice**: Classification can begin up to **30 days after estimation**, but minimizing the gap ensures greater accuracy. Start classification within **24-48 hours** of estimation for best results.

**Cancel In-Progress Scans:**

- If needed, click **Cancel Scan** on the Estimation overview tab
- Use this if you need to adjust scope or pause for budget reasons

---

### Step 5: Analyze On-Demand Classification Results

Once classification completes (status: **Completed**):

**View Results:**

- From **On-demand classification** page, select your completed scan
- Click **View estimation** (shows final results, not just estimates)

**Estimation Overview Tab (Final Results):**

Review actual classification results:

| Result Metric | Example | Action |
|---------------|---------|--------|
| **Items classified** | 42,187 | Total files processed |
| **Items with sensitive info** | 3,421 | Files requiring attention |
| **High confidence matches** | 2,103 | Priority remediation targets |
| **Medium confidence matches** | 1,318 | Secondary review |
| **Actual cost** | $21.09 | Final billing amount |

**Items for Review Tab:**

Detailed file-level results with filtering capabilities:

**Available Filters:**

- **Classifier name**: Filter by specific SIT (Credit Card, SSN, etc.)
- **Confidence level**: High, Medium, Low
- **File type**: Filter by extension
- **Site**: Filter by specific SharePoint site
- **Modified date**: Sort by file age

**Export Results:**

- Click **Export** button to download CSV
- Use exported data for:
  - Integration with remediation scripts (Supplemental Lab 01)
  - Stakeholder reporting (Lab 04 patterns)
  - Cross-referencing with scanner results (Lab 01-02)

> **📊 Integration with Lab 04**: Exported on-demand classification results complement scanner CSV reports, providing SharePoint-specific insights for your comprehensive remediation plan.

---

### Step 6: Content Explorer Updates

Classification results automatically update **Content Explorer** for ongoing monitoring:

**Timeline for Content Explorer Updates:**

- **Initial results**: Available in on-demand classification scan results (immediate)
- **Content Explorer sync**: **Within 7 days** of scan completion
- **Activity Explorer**: Updates based on normal sync schedule (15-30 min to 24 hours for events)

**View Updated Content Explorer:**

- Navigate to **Information Protection** > **Explorers** > **Content Explorer**
- Filter by:
  - **Locations**: SharePoint sites you scanned
  - **Sensitive info types**: Classifiers you selected
  - **Labels**: Any auto-applied sensitivity or retention labels

**Monitoring Long-Term:**

After on-demand classification, Content Explorer provides:

- Trend analysis for sensitive data distribution
- Label coverage metrics
- Policy effectiveness over time
- New file classification (continuous classification)

> **🔄 Continuous + On-Demand Approach**: On-demand classification addresses historical data. Continuous classification (Lab 03) handles new files. Together, they provide complete coverage.

---

### Step 7: SharePoint Search Schema Optimization (Advanced)

For large-scale projects, optimizing search schema improves classification performance and reporting capabilities.

**Use Case**: Create custom managed properties to track classification status and remediation actions.

**Navigate to Search Schema:**

- **Tenant-Level** (recommended for organization-wide properties):
  - Go to **SharePoint admin center**: [https://admin.microsoft.com/sharepoint](https://admin.microsoft.com/sharepoint)
  - Navigate to **More features** > **Search** > **Open** > **Manage Search Schema**

- **Site Collection-Level** (for site-specific properties):
  - On the SharePoint site, click **Settings** (gear icon) > **Site settings**
  - Under **Site Collection Administration**, click **Search Schema**

> **💡 Scope Decision**: Use tenant-level for properties needed across all sites. Use site collection-level for site-specific customization.

**Understanding Crawled vs. Managed Properties:**

| Property Type | Purpose | Example |
|---------------|---------|---------|
| **Crawled Properties** | Content/metadata extracted during crawl | `ows_Author`, `ows_Created`, `ows_FileExtension` |
| **Managed Properties** | Searchable/refinable properties in index | `Author`, `Created`, `FileExtension`, `RefinableString00` |
| **Mapping** | Links crawled properties to managed properties | `ows_CustomClassification` → `RefinableString00` |

**Create Custom Managed Property for Classification Tracking:**

While you can't directly control Purview classification properties, you can create custom site columns that become searchable:

1. **Create Site Column**:
   - Navigate to your SharePoint site
   - **Settings** > **Site settings** > **Site columns**
   - Click **Create**
   - Name: `RemediationStatus`
   - Type: **Choice** (Track Status, Approved for Deletion, Retained, etc.)
   - Click **OK**

2. **Add to Document Library**:
   - Navigate to your target document library
   - **Settings** (gear) > **Library settings**
   - Under **Columns**, click **Add from existing site columns**
   - Select **RemediationStatus**
   - Click **OK**

3. **Request Reindex** (trigger search schema update):
   - In **Library settings**, click **Advanced settings**
   - Scroll to **Reindex Document Library**
   - Click **Reindex Document Library** button
   - Confirm the action

4. **Map to Managed Property** (after 1-2 hour crawl):
   - Go to **Search Schema** (tenant or site collection level)
   - Search for your column: `ows_RemediationStatus`
   - Find an unused **RefinableString** property (e.g., `RefinableString00`)
   - Click the **RefinableString00** property
   - Under **Alias**, add: `RemediationStatus`
   - Under **Mappings to crawled properties**, click **Add a Mapping**
   - Search and select: `ows_RemediationStatus`
   - Click **OK**

**Benefits for Project:**

- Track remediation workflow status directly in SharePoint metadata
- Create views/filters for "Approved for Deletion" vs "Retained" files
- Generate reports combining classification results + remediation status
- Integrate with PowerShell automation (Supplemental Lab 01)

---

### Step 8: Manual Site Reindexing for Accelerated Classification

When you need immediate classification updates (without waiting for automatic crawl):

**Use Cases:**

- New sensitivity labels created and need immediate application
- Custom SITs added and historical content needs reclassification
- After bulk remediation to update Content Explorer
- Accelerating classification for demo/validation purposes

**Trigger Manual Reindex:**

**For Entire Site:**

- Navigate to your SharePoint site
- **Settings** (gear) > **Site settings**
- Under **Search**, click **Search and offline availability**
- Click **Reindex site** button
- Click **OK** to confirm

**For Specific Document Library:**

- Navigate to the document library
- **Settings** (gear) > **Library settings**
- Click **Advanced settings**
- Scroll to **Reindex Document Library**
- Click **Reindex Document Library** button
- Click **OK** to confirm

**For Specific List:**

- Navigate to the list
- **Settings** (gear) > **List settings**
- Click **Advanced settings**
- Scroll to **Reindex List**
- Click **Reindex List** button
- Click **OK** to confirm

> **⚠️ Impact of Reindexing**: Forces full recrawl of all content. For large sites, this can take hours or days. Use selectively for specific libraries/lists when possible instead of full site reindex.

**Expected Timeline:**

| Scope | Typical Reindex Duration | Classification Availability |
|-------|-------------------------|----------------------------|
| Small library (100s of files) | 15-30 minutes | +30 min for policy application |
| Medium library (1000s of files) | 1-4 hours | +1-2 hours for policy application |
| Large site (10,000+ files) | 4-24 hours | +2-4 hours for policy application |
| Entire site collection | 24-72 hours | +4-8 hours for policy application |

**Monitor Reindex Progress:**

- No built-in progress indicator in SharePoint
- Check Content Explorer or Activity Explorer for updated classification results
- Verify by searching for recently updated metadata in SharePoint search

---

### Step 9: Implement Selective Targeting Strategy (Production Pattern)

Based on your consultancy project needs, implement a phased selective targeting approach:

**Phase 1: High-Risk Site Identification**

Use this criteria matrix:

| Risk Factor | High Priority | Medium Priority | Low Priority |
|-------------|---------------|-----------------|--------------|
| **Data Sensitivity** | Finance, HR, Legal | Executive, Operations | Marketing, Public |
| **Data Age** | 3+ years unclassified | 1-3 years | <1 year |
| **Volume** | 10,000+ files | 1,000-10,000 files | <1,000 files |
| **Regulatory Exposure** | PCI DSS, HIPAA, SOX | GDPR, CCPA | Internal only |
| **Previous Audit Findings** | Known violations | Suspected issues | Clean |

**Phase 2: Targeted Scan Execution**

Create multiple focused scans rather than one large scan:

**Scan 1: Finance Sites (Week 1)**
- Scope: Finance-specific SharePoint sites
- Classifiers: Credit Card, SSN, Bank Account, Financial Terms
- Date Range: Past 3 years
- Expected Items: ~15,000 files

**Scan 2: HR Sites (Week 2)**
- Scope: Human Resources SharePoint sites
- Classifiers: SSN, Passport, Medical Terms, Employment Records
- Date Range: Past 3 years
- Expected Items: ~8,000 files

**Scan 3: Legal/Executive Sites (Week 3)**
- Scope: Legal and Executive team sites
- Classifiers: All sensitive types
- Date Range: Past 5 years (longer retention)
- Expected Items: ~5,000 files

**Phase 3: Integration with Remediation Workflow**

Combine on-demand classification results with remediation scripts:

```powershell
# Load on-demand classification results (exported CSV)
$onDemandResults = Import-Csv -Path "C:\Reports\OnDemand-Finance-Sites.csv"

# Load scanner results (from Lab 01-04)
$scannerResults = Import-Csv -Path "$env:LOCALAPPDATA\Microsoft\MSIP\Scanner\Reports\DetailedReport_Latest.csv"

# Combine for comprehensive view
$allSensitiveFiles = @()

# Add on-demand results (SharePoint Online)
$allSensitiveFiles += $onDemandResults | Select-Object @{N='Source';E={'OnDemandScan'}}, FilePath, @{N='SITs';E={$_.ClassifierName}}, @{N='Confidence';E={$_.ConfidenceLevel}}

# Add scanner results (On-premises + Azure Files)
$allSensitiveFiles += $scannerResults | Select-Object @{N='Source';E={'Scanner'}}, 'File Path' -as FilePath, 'Sensitive Information Types' -as SITs, 'DLP Policy' -as Confidence

# Create unified remediation plan using Supplemental Lab 01 patterns
# Apply severity-based matrix, age-based actions, etc.
```

**Phase 4: Stakeholder Reporting**

Combine on-demand classification with Lab 04 reporting patterns:

- Total files scanned (on-prem + SharePoint)
- Sensitive data distribution by location
- Cost analysis (scanner infrastructure + on-demand classification fees)
- Remediation progress tracking
- Timeline for full coverage

---

## 🎯 Lab 02 Completion Summary

**Skills Acquired:**

✅ **On-Demand Classification**: Targeted scanning of specific SharePoint sites for historical data
✅ **Search Schema Management**: Understanding of crawled/managed properties for classification
✅ **Indexing Optimization**: Manual reindex triggering for accelerated classification
✅ **Selective Targeting**: Strategic approach to high-risk site identification
✅ **Cost Estimation**: Budget planning for large-scale classification projects
✅ **SharePoint Integration**: Combining on-demand classification with continuous classification
✅ **Results Analysis**: Interpreting and exporting classification results for remediation

**Project Alignment:**

This lab directly addresses your consultancy project requirements:

- **Gap #1 (SharePoint Indexing Optimization)**: ✅ Covered through search schema management and manual reindexing
- **Gap #2 (Selective On-Demand Classification)**: ✅ Covered through on-demand classification targeted scans

**Integration with Other Labs:**

| Lab | Integration Point | Benefit |
|-----|-------------------|---------|
| **Lab 01-02** | Scanner results + on-demand results | Comprehensive sensitive data inventory (on-prem + cloud) |
| **Lab 03** | Continuous classification + on-demand | Complete coverage (historical + new files) |
| **Lab 04** | Reporting patterns + Content Explorer | Unified stakeholder reporting |
| **Supplemental Lab 01** | Remediation scripts + classification results | Automated remediation workflow |

**Next Steps:**

- **Supplemental Lab 01**: Advanced remediation automation using combined classification results
- **Supplemental Lab 03**: Custom classification (SITs and trainable classifiers) for project-specific data patterns

---

## 📚 Reference Documentation

All lab steps are validated against current Microsoft Learn documentation (October 2025):

- [On-demand classification in Microsoft Purview](https://learn.microsoft.com/en-us/purview/on-demand-classification)
- [Manage the search schema in SharePoint](https://learn.microsoft.com/en-us/sharepoint/manage-search-schema)
- [Manually request crawling and re-indexing](https://learn.microsoft.com/en-us/sharepoint/crawl-site-content)
- [Overview of crawled and managed properties in SharePoint](https://learn.microsoft.com/en-us/sharepoint/crawled-and-managed-properties-overview)
- [Search solutions for SharePoint](https://learn.microsoft.com/en-us/sharepoint/dev/solution-guidance/search-solutions-in-sharepoint-2013-and-sharepoint-online)
- [Microsoft Purview billing models](https://learn.microsoft.com/en-us/purview/purview-billing-models)

---

## 🤖 AI-Assisted Content Generation

This advanced SharePoint and OneDrive classification supplemental lab was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview on-demand classification capabilities, SharePoint search architecture, and modern classification optimization techniques validated against Microsoft Learn documentation (October 2025).

*AI tools were used to enhance productivity and ensure comprehensive coverage of advanced SharePoint classification strategies while maintaining technical accuracy and reflecting current Purview portal navigation, on-demand classification workflows, and search schema management best practices.*
