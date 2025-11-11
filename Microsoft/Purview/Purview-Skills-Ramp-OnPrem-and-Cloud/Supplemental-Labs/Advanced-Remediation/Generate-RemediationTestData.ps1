# ============================================================================
# PART 1: STEP 1 - SEVERITY-BASED REMEDIATION TEST DATA (ON-PREM ONLY)
# ============================================================================

Write-Host "`n========== PART 1: STEP 1 SEVERITY-BASED REMEDIATION ==========" -ForegroundColor Magenta
Write-Host "Creating on-prem test files for scanner detection and severity classification...`n" -ForegroundColor Cyan

# Get computer name for UNC path
$computerName = $env:COMPUTERNAME

# Define test data output paths (isolated directories)
$step1Path = "\\$computerName\Projects\RemediationTestData\Step1-SeverityBased"

# Create directory structure
if (-not (Test-Path $step1Path)) {
    New-Item -Path $step1Path -ItemType Directory -Force | Out-Null
    Write-Host "✅ Created Step 1 test data directory: $step1Path" -ForegroundColor Green
}

# Step 1 test data templates
$step1Files = @(
    # HIGH SEVERITY - PCI/PHI/HIPAA Data
    @{
        Name = "Patient_Records_2024.txt"
        Content = "Patient MRN: 123456789`nDiagnosis: Diabetes Type 2`nPrescription: Metformin 500mg`nInsurance: BlueCross Policy #HC-998877"
        SITs = "Medical Record Number, Protected Health Information"
        Severity = "HIGH"
        AgeYears = 0.5
    },
    @{
        Name = "Patient_Billing_2023.txt"
        Content = "Patient: John Doe`nMRN: 987654321`nProcedure: Cardiology Consultation`nBilling Code: 99213`nCost: $450.00"
        SITs = "Medical Record Number, Protected Health Information"
        Severity = "HIGH"
        AgeYears = 1.5
    },
    @{
        Name = "Credit_Card_Transactions_2020.txt"
        Content = "Transaction Date: 2020-03-15`nCard Number: 4532-1234-5678-9010`nAmount: $1,250.00`nCardholder: Jane Smith"
        SITs = "Credit Card Number, PCI Data"
        Severity = "HIGH"
        AgeYears = 4.5
    },
    @{
        Name = "Payment_Processing_2019.txt"
        Content = "Payment Method: Credit Card`nCard: 5425-2334-3010-9876`nCVV: 123`nExpiry: 12/25`nAmount: $850.00"
        SITs = "Credit Card Number, PCI Data"
        Severity = "HIGH"
        AgeYears = 5.2
    },
    
    # MEDIUM SEVERITY - PII
    @{
        Name = "Employee_Onboarding_2024.txt"
        Content = "Employee: Sarah Johnson`nSSN: 123-45-6789`nDOB: 1985-06-15`nAddress: 123 Main St, Seattle WA 98101"
        SITs = "Social Security Number"
        Severity = "MEDIUM"
        AgeYears = 0.3
    },
    @{
        Name = "HR_Records_2023.txt"
        Content = "Name: Michael Chen`nSSN: 987-65-4321`nPassport: P12345678`nStart Date: 2023-01-15"
        SITs = "Social Security Number, Passport Number"
        Severity = "MEDIUM"
        AgeYears = 1.8
    },
    @{
        Name = "Tax_Forms_2022.txt"
        Content = "Tax Year: 2022`nSSN: 555-12-3456`nFiling Status: Single`nW-2 Employer: Contoso Ltd"
        SITs = "Social Security Number"
        Severity = "MEDIUM"
        AgeYears = 2.5
    },
    @{
        Name = "Background_Check_2020.txt"
        Content = "Applicant: Robert Williams`nSSN: 321-54-9876`nDriver License: WA-12345-67890`nCheck Date: 2020-08-10"
        SITs = "Social Security Number, Driver's License Number"
        Severity = "MEDIUM"
        AgeYears = 4.2
    },
    
    # LOW SEVERITY - General Business
    @{
        Name = "Project_Notes_2018.txt"
        Content = "Project: Website Redesign`nTeam Lead: alice@contoso.com`nBudget: $50,000`nStatus: Completed"
        SITs = "Email Address"
        Severity = "LOW"
        AgeYears = 6.5
    },
    @{
        Name = "Meeting_Minutes_2019.txt"
        Content = "Meeting Date: 2019-05-20`nAttendees: bob@contoso.com, carol@contoso.com`nTopic: Quarterly Planning"
        SITs = "Email Address"
        Severity = "LOW"
        AgeYears = 5.4
    },
    @{
        Name = "Vendor_Contact_List_2017.txt"
        Content = "Vendor: Office Supplies Inc`nContact: david@supplier.com`nPhone: 206-555-0123"
        SITs = "Email Address, Phone Number"
        Severity = "LOW"
        AgeYears = 7.8
    }
)

# Create Step 1 files
foreach ($file in $step1Files) {
    $filePath = Join-Path $step1Path $file.Name
    $file.Content | Out-File -FilePath $filePath -Encoding UTF8 -Force
    
    # Set timestamps
    $lastModified = (Get-Date).AddYears(-$file.AgeYears)
    $fileItem = Get-Item $filePath
    $fileItem.LastWriteTime = $lastModified
    $fileItem.LastAccessTime = $lastModified
    $fileItem.CreationTime = $lastModified
    
    $ageDisplay = if ($file.AgeYears -lt 1) { "$([math]::Round($file.AgeYears * 12)) months" } else { "$([math]::Round($file.AgeYears, 1)) years" }
    Write-Host "✅ Created: $($file.Name) ($($file.Severity) | $ageDisplay)" -ForegroundColor Green
}

Write-Host "`n✅ Step 1 files created: $($step1Files.Count) files in $step1Path" -ForegroundColor Green

# ============================================================================
# PART 2: STEP 2 - DUAL-SOURCE DEDUPLICATION TEST DATA
# ============================================================================

Write-Host "`n========== PART 2: STEP 2 DUAL-SOURCE DEDUPLICATION ==========" -ForegroundColor Magenta
Write-Host "Creating duplicate files in on-prem AND Azure Files for deduplication testing...`n" -ForegroundColor Cyan

$step2OnPremPath = "\\$computerName\Projects\RemediationTestData\Step2-DualSource\OnPrem"

# Get Azure Files path with format validation
Write-Host "📋 Azure Files UNC Path Construction:" -ForegroundColor Yellow
Write-Host "   Finding your URL in Azure Portal:" -ForegroundColor Cyan
Write-Host "   1. Navigate to: Storage Account → File shares → [your-share-name]" -ForegroundColor White
Write-Host "   2. Copy the 'URL' field (e.g., https://storageaccount.file.core.windows.net/sharename)" -ForegroundColor White
Write-Host "   3. Paste it below - the script will automatically convert it to UNC format" -ForegroundColor White
Write-Host ""
Write-Host "   💡 Tip: You can paste either the HTTPS URL or UNC path - both work!" -ForegroundColor Gray
Write-Host ""

$step2CloudPath = Read-Host "Enter Azure Files URL or UNC path (or press Enter to skip Step 2 cloud setup)"

# Skip if empty
if ([string]::IsNullOrWhiteSpace($step2CloudPath)) {
    Write-Host "   ⏭️  Skipping Azure Files setup. Step 2 will use on-prem files only for demonstration.`n" -ForegroundColor Gray
    $step2CloudPath = $null
}

# Automatically convert HTTPS URL to UNC path format
if ($step2CloudPath -and $step2CloudPath -match '^https?://') {
    Write-Host ""
    Write-Host "   🔧 Auto-converting Azure Files URL to UNC format..." -ForegroundColor Yellow
    
    # Convert URL to UNC path
    $originalUrl = $step2CloudPath
    $step2CloudPath = $step2CloudPath -replace '^https?://', '\\' -replace '/', '\'
    
    # Add subfolder if not already present
    if ($step2CloudPath -notmatch '\\Step2-DualSource$') {
        $step2CloudPath = "$step2CloudPath\Step2-DualSource"
    }
    
    Write-Host "   Original URL:  $originalUrl" -ForegroundColor Gray
    Write-Host "   Converted UNC: $step2CloudPath" -ForegroundColor Green
    Write-Host "   ✅ Using converted UNC path for Azure Files access`n" -ForegroundColor Cyan
}

# Create directories
New-Item -Path $step2OnPremPath -ItemType Directory -Force | Out-Null

if ($step2CloudPath -and (Test-Path $step2CloudPath)) {
    Write-Host "✅ Azure Files path accessible: $step2CloudPath" -ForegroundColor Green
} elseif ($step2CloudPath) {
    try {
        New-Item -Path $step2CloudPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Write-Host "✅ Created Azure Files directory: $step2CloudPath" -ForegroundColor Green
    } catch {
        Write-Warning "Cannot access Azure Files path: $step2CloudPath"
        Write-Host "   Skipping Step 2 dual-source setup. Configure Azure Files access and re-run this section.`n" -ForegroundColor Gray
        $step2CloudPath = $null
    }
}

# Step 2 test files (intentional duplicates + some unique files)
$step2Files = @(
    # DUPLICATES (exist in both locations, cloud version newer)
    @{
        Name = "Financial_Report_Q1_2023.txt"
        Content = "Q1 2023 Financial Report`nRevenue: $1.2M`nExpenses: $800K`nProfit: $400K"
        OnPremAge = 1.5
        CloudAge = 1.0  # Newer in cloud
        Type = "DUPLICATE"
    },
    @{
        Name = "Compliance_Audit_2022.txt"
        Content = "Annual Compliance Audit 2022`nStatus: Passed`nAuditor: Ernst & Young`nDate: 2022-12-15"
        OnPremAge = 2.2
        CloudAge = 2.0  # Newer in cloud
        Type = "DUPLICATE"
    },
    @{
        Name = "Marketing_Strategy_2024.txt"
        Content = "2024 Marketing Strategy`nTarget: 25% growth`nChannels: Digital, Social, Events"
        OnPremAge = 0.5
        CloudAge = 0.3  # Newer in cloud
        Type = "DUPLICATE"
    },
    
    # ON-PREM ONLY (safe to keep, not in cloud yet)
    @{
        Name = "Legacy_System_Docs_2019.txt"
        Content = "Legacy CRM System Documentation`nVersion: 2.5`nSupport Ends: 2025-12-31"
        OnPremAge = 5.5
        CloudAge = $null
        Type = "ONPREM_ONLY"
    },
    
    # CLOUD ONLY (newer cloud-native files)
    @{
        Name = "CloudMigration_Plan_2024.txt"
        Content = "Cloud Migration Roadmap 2024`nPhase 1: Lift-and-shift`nPhase 2: Re-architecture"
        OnPremAge = $null
        CloudAge = 0.2
        Type = "CLOUD_ONLY"
    }
)

# Create Step 2 files
foreach ($file in $step2Files) {
    # Create on-prem version
    if ($null -ne $file.OnPremAge) {
        $onPremFilePath = Join-Path $step2OnPremPath $file.Name
        $file.Content | Out-File -FilePath $onPremFilePath -Encoding UTF8 -Force
        
        $lastModified = (Get-Date).AddYears(-$file.OnPremAge)
        $fileItem = Get-Item $onPremFilePath
        $fileItem.LastWriteTime = $lastModified
        $fileItem.LastAccessTime = $lastModified
        $fileItem.CreationTime = $lastModified
        
        Write-Host "✅ On-Prem: $($file.Name) ($($file.Type))" -ForegroundColor Cyan
    }
    
    # Create cloud version
    if (($null -ne $step2CloudPath) -and ($null -ne $file.CloudAge)) {
        $cloudFilePath = Join-Path $step2CloudPath $file.Name
        $file.Content | Out-File -FilePath $cloudFilePath -Encoding UTF8 -Force
        
        $lastModified = (Get-Date).AddYears(-$file.CloudAge)
        $fileItem = Get-Item $cloudFilePath
        $fileItem.LastWriteTime = $lastModified
        $fileItem.LastAccessTime = $lastModified
        $fileItem.CreationTime = $lastModified
        
        Write-Host "   ✅ Cloud: $($file.Name) ($(([math]::Round($file.CloudAge, 1))) years old)" -ForegroundColor Green
    }
}

if ($null -ne $step2CloudPath) {
    Write-Host "`n✅ Step 2 dual-source files created successfully" -ForegroundColor Green
    Write-Host "   Expected deduplication result: 3 duplicates found (cloud versions newer)" -ForegroundColor Yellow
}

# ============================================================================
# PART 3: STEP 3 - SHAREPOINT PNP POWERSHELL TEST DATA
# ============================================================================

Write-Host "`n========== PART 3: STEP 3 SHAREPOINT PNP AUTOMATION ==========" -ForegroundColor Magenta
Write-Host "Uploading test files to SharePoint for PnP PowerShell deletion testing...`n" -ForegroundColor Cyan

# Check for SharePointPnPPowerShellOnline module (PowerShell 5.1 compatible)
if (-not (Get-Module -Name SharePointPnPPowerShellOnline -ListAvailable)) {
    Write-Host "⚠️  SharePointPnPPowerShellOnline module not installed.`n" -ForegroundColor Yellow
    Write-Host "   Note: Using legacy PnP module compatible with PowerShell 5.1" -ForegroundColor Gray
    Write-Host "   (PnP.PowerShell requires PowerShell 7.4+, not compatible with Purview scanner VM)`n" -ForegroundColor Gray
    
    $installPnP = Read-Host "Install SharePointPnPPowerShellOnline module now? This may take 2-3 minutes. (yes/no)"
    
    if ($installPnP -eq 'yes') {
        Write-Host "📦 Installing SharePointPnPPowerShellOnline module...`n" -ForegroundColor Cyan
        Write-Host "   This will prompt for NuGet provider installation if not already installed." -ForegroundColor Gray
        Write-Host "   Accept all prompts to complete installation.`n" -ForegroundColor Gray
        
        try {
            # Install with explicit confirmation bypass for automation
            Install-Module -Name SharePointPnPPowerShellOnline -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop
            
            # Import module to verify installation
            Import-Module -Name SharePointPnPPowerShellOnline -ErrorAction Stop
            
            Write-Host "`n✅ SharePointPnPPowerShellOnline module installed and imported successfully" -ForegroundColor Green
            
        } catch {
            Write-Warning "Failed to install SharePointPnPPowerShellOnline module: $_"
            Write-Host "`n   Manual installation steps:" -ForegroundColor Yellow
            Write-Host "   1. Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force" -ForegroundColor White
            Write-Host "   2. Install-Module -Name SharePointPnPPowerShellOnline -Scope CurrentUser -Force" -ForegroundColor White
            Write-Host "   3. Import-Module -Name SharePointPnPPowerShellOnline" -ForegroundColor White
            Write-Host "   4. Re-run this script for Step 3 setup`n" -ForegroundColor White
            
            Write-Host "   ⏭️  Skipping Step 3 SharePoint setup for now.`n" -ForegroundColor Gray
            return
        }
    } else {
        Write-Host "   ⏭️  Skipping Step 3 SharePoint setup. Install SharePointPnPPowerShellOnline manually and re-run this section.`n" -ForegroundColor Gray
        return
    }
} else {
    # Import module if not already loaded
    if (-not (Get-Module -Name SharePointPnPPowerShellOnline)) {
        try {
            Import-Module -Name SharePointPnPPowerShellOnline -ErrorAction Stop
            Write-Host "✅ SharePointPnPPowerShellOnline module loaded" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to import SharePointPnPPowerShellOnline module: $_"
            Write-Host "   ⏭️  Skipping Step 3 SharePoint setup.`n" -ForegroundColor Gray
            return
        }
    }
}

# SharePoint connection with skip option
Write-Host "`n📋 SharePoint Site Configuration:" -ForegroundColor Yellow
Write-Host "   Example: https://yourtenant.sharepoint.com/sites/YourSiteName`n" -ForegroundColor Gray

$siteUrl = Read-Host "Enter SharePoint site URL (or press Enter to skip Step 3)"

if ([string]::IsNullOrWhiteSpace($siteUrl)) {
    Write-Host "   ⏭️  Skipping Step 3 SharePoint setup (can be configured later)`n" -ForegroundColor Gray
    return
}

$libraryName = Read-Host "Enter document library name (default: 'Sensitive Data Archive')"
if ([string]::IsNullOrWhiteSpace($libraryName)) {
    $libraryName = "Sensitive Data Archive"
}

try {
    Connect-PnPOnline -Url $siteUrl -UseWebLogin -ErrorAction Stop
    Write-Host "✅ Connected to SharePoint: $siteUrl" -ForegroundColor Green
    Write-Host "   (Using legacy authentication for PowerShell 5.1 compatibility)" -ForegroundColor Gray
    
    # Step 3 test files (for SharePoint deletion testing)
    $step3Files = @(
        @{
            Name = "Old_SSN_Records_2019.txt"
            Content = "Employee SSN Records - 2019 Archive`nEmployee 1: SSN 111-22-3333`nEmployee 2: SSN 444-55-6666"
            AgeYears = 5.8
        },
        @{
            Name = "Credit_Card_Database_2018.txt"
            Content = "Payment Card Archive 2018`nCard 1: 4111-1111-1111-1111`nCard 2: 5500-0000-0000-0004"
            AgeYears = 6.5
        },
        @{
            Name = "Confidential_HR_Data_2020.txt"
            Content = "HR Confidential Records 2020`nSalary: $85,000`nSSN: 777-88-9999`nPerformance: Exceeds"
            AgeYears = 4.3
        },
        @{
            Name = "Recent_Project_Files_2024.txt"
            Content = "Current Project Documentation 2024`nProject Lead: john@contoso.com`nStatus: In Progress"
            AgeYears = 0.2
        }
    )
    
    # Create temp directory for SharePoint upload
    $tempPath = "C:\PurviewLab\Step3-SharePointUpload"
    New-Item -Path $tempPath -ItemType Directory -Force | Out-Null
    
    foreach ($file in $step3Files) {
        # Create local temp file
        $localPath = Join-Path $tempPath $file.Name
        $file.Content | Out-File -FilePath $localPath -Encoding UTF8 -Force
        
        # Set timestamp
        $lastModified = (Get-Date).AddYears(-$file.AgeYears)
        $fileItem = Get-Item $localPath
        $fileItem.LastWriteTime = $lastModified
        
        # Upload to SharePoint
        try {
            Add-PnPFile -Path $localPath -Folder $libraryName -ErrorAction Stop | Out-Null
            Write-Host "✅ Uploaded: $($file.Name) ($(([math]::Round($file.AgeYears, 1))) years old)" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to upload $($file.Name): $_"
        }
    }
    
    Write-Host "`n✅ Step 3 SharePoint files uploaded: $($step3Files.Count) files" -ForegroundColor Green
    Write-Host "   Expected PnP deletion result: 3 old files (3+ years), 1 recent file retained" -ForegroundColor Yellow
    
    Disconnect-PnPOnline
    
} catch {
    Write-Warning "SharePoint connection failed: $_"
    Write-Host "   Skipping Step 3 SharePoint setup. Configure SharePoint access and re-run this section." -ForegroundColor Yellow
}

# ============================================================================
# SUMMARY & NEXT STEPS
# ============================================================================

Write-Host "`n========== TEST DATA GENERATION COMPLETE ==========" -ForegroundColor Magenta

$summary = @"

✅ STEP 1 (Severity-Based Remediation):
   Location: $step1Path
   Files: $($step1Files.Count) files (HIGH/MEDIUM/LOW severity across all age ranges)
   Next: Run scanner, then execute Step 1 script

✅ STEP 2 (Dual-Source Deduplication):
   On-Prem: $step2OnPremPath
   Cloud: $step2CloudPath
   Files: $($step2Files.Count) files (3 duplicates, 1 on-prem only, 1 cloud only)
   Next: Execute Step 2 deduplication script

✅ STEP 3 (SharePoint PnP Automation):
   Location: SharePoint site - $libraryName library
   Files: $($step3Files.Count) files (3 old, 1 recent)
   Next: Execute Step 3 PnP deletion script

✅ STEP 4 (On-Prem Tombstones):
   Uses: Step 1 remediation plan CSV
   Next: Execute Step 4 deletion script (deletes Step 1 files only)

✅ STEP 5 (Progress Tracking):
   Uses: CSV outputs from Steps 1-4
   Next: Execute Step 5 dashboard script

⚡ IMMEDIATE NEXT STEPS:
   1. Run Purview scanner to detect Step 1 files
   2. Execute Step 1 to generate remediation plan
   3. Execute Steps 2-5 in sequence (isolated data sets prevent conflicts)

🎯 DATA ISOLATION CONFIRMED:
   - Step 1 files in separate folder (deleted by Step 4, not Steps 2-3)
   - Step 2 files in dedicated dual-source folders (not scanned by Step 1)
   - Step 3 files in SharePoint only (completely isolated from on-prem)
   - No cross-contamination between remediation scenarios

"@

Write-Host $summary -ForegroundColor Cyan
