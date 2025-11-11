<#
.SYNOPSIS
    Test script to compare .txt vs .docx file classification behavior.

.DESCRIPTION
    Creates minimal test files in both .txt and .docx formats with identical
    sensitive content to determine if on-demand classification has different
    behavior for plain text vs Office files.

.EXAMPLE
    .\Test-TxtVsDocx-Classification.ps1

.NOTES
    Author: Marcus Jacobson
    Created: 2025-10-31
    
    This diagnostic script helps identify whether on-demand classification
    has undocumented limitations with .txt file content extraction.
    
    Test Process:
    1. Creates 2 .txt files with SSN and Credit Card data
    2. Creates 2 .docx files with identical content
    3. Uploads all files to a test folder in SharePoint
    4. Instructions for running on-demand scan on just these 4 files
    5. Compare results to determine file format impact
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$LibraryName,
    
    [Parameter(Mandatory = $false)]
    [string]$TestFolderName = "ClassificationTest-TxtVsDocx"
)

# =============================================================================
# Connect to SharePoint
# =============================================================================

Write-Host "🔍 Classification Format Test - .txt vs .docx" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Connecting to SharePoint..." -ForegroundColor Green
try {
    Connect-PnPOnline -Url $SiteUrl -Interactive -ErrorAction Stop
    Write-Host "   ✅ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Connection failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Create Test Content
# =============================================================================

Write-Host ""
Write-Host "📝 Creating test content..." -ForegroundColor Green

$testContent1 = @"
Financial Report - Test Document 1
Date: 2025-10-31

Customer Information:
Name: John Smith
SSN: 123-45-6789
Credit Card: 4532-1234-5678-9010

Account Balance: $15000
Transaction Date: 2025-10-15
"@

$testContent2 = @"
Financial Report - Test Document 2
Date: 2025-10-31

Customer Information:
Name: Jane Doe
SSN: 987-65-4321
Credit Card: 6011-1111-1111-1117

Account Balance: $25000
Transaction Date: 2025-10-20
"@

# =============================================================================
# Create .txt Files
# =============================================================================

Write-Host ""
Write-Host "📄 Creating .txt test files..." -ForegroundColor Green

$txtFile1 = "$env:TEMP\ClassificationTest-TXT-1.txt"
$txtFile2 = "$env:TEMP\ClassificationTest-TXT-2.txt"

$testContent1 | Out-File -FilePath $txtFile1 -Encoding utf8
$testContent2 | Out-File -FilePath $txtFile2 -Encoding utf8

Write-Host "   ✅ Created TXT file 1: $txtFile1" -ForegroundColor Green
Write-Host "   ✅ Created TXT file 2: $txtFile2" -ForegroundColor Green

# =============================================================================
# Create .docx Files (Using Word COM Object)
# =============================================================================

Write-Host ""
Write-Host "📄 Creating .docx test files..." -ForegroundColor Green

try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    
    # Create Document 1
    $docxFile1 = "$env:TEMP\ClassificationTest-DOCX-1.docx"
    $doc1 = $word.Documents.Add()
    $doc1.Content.Text = $testContent1
    $doc1.SaveAs([ref]$docxFile1)
    $doc1.Close()
    Write-Host "   ✅ Created DOCX file 1: $docxFile1" -ForegroundColor Green
    
    # Create Document 2
    $docxFile2 = "$env:TEMP\ClassificationTest-DOCX-2.docx"
    $doc2 = $word.Documents.Add()
    $doc2.Content.Text = $testContent2
    $doc2.SaveAs([ref]$docxFile2)
    $doc2.Close()
    Write-Host "   ✅ Created DOCX file 2: $docxFile2" -ForegroundColor Green
    
    $word.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    
} catch {
    Write-Host "   ⚠️  Word automation failed: $_" -ForegroundColor Yellow
    Write-Host "   📋 Creating .docx files manually required" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Please create 2 Word documents manually with this content:" -ForegroundColor Yellow
    Write-Host "   Document 1: $testContent1" -ForegroundColor Gray
    Write-Host "   Document 2: $testContent2" -ForegroundColor Gray
    
    $docxFile1 = $null
    $docxFile2 = $null
}

# =============================================================================
# Create Test Folder in SharePoint
# =============================================================================

Write-Host ""
Write-Host "📁 Creating test folder in SharePoint..." -ForegroundColor Green

try {
    # Check if folder exists
    $existingFolder = Get-PnPFolder -Url "$LibraryName/$TestFolderName" -ErrorAction SilentlyContinue
    
    if ($existingFolder) {
        Write-Host "   ⚠️  Folder already exists, removing old files..." -ForegroundColor Yellow
        $items = Get-PnPListItem -List $LibraryName -FolderServerRelativeUrl "$LibraryName/$TestFolderName"
        foreach ($item in $items) {
            Remove-PnPListItem -List $LibraryName -Identity $item.Id -Force
        }
    } else {
        Add-PnPFolder -Name $TestFolderName -Folder $LibraryName | Out-Null
    }
    
    Write-Host "   ✅ Test folder ready: $TestFolderName" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ Folder creation failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Upload Files to SharePoint
# =============================================================================

Write-Host ""
Write-Host "📤 Uploading test files to SharePoint..." -ForegroundColor Green

try {
    # Upload .txt files
    Add-PnPFile -Path $txtFile1 -Folder "$LibraryName/$TestFolderName" | Out-Null
    Write-Host "   ✅ Uploaded: ClassificationTest-TXT-1.txt" -ForegroundColor Green
    
    Add-PnPFile -Path $txtFile2 -Folder "$LibraryName/$TestFolderName" | Out-Null
    Write-Host "   ✅ Uploaded: ClassificationTest-TXT-2.txt" -ForegroundColor Green
    
    # Upload .docx files if they were created
    if ($docxFile1 -and (Test-Path $docxFile1)) {
        Add-PnPFile -Path $docxFile1 -Folder "$LibraryName/$TestFolderName" | Out-Null
        Write-Host "   ✅ Uploaded: ClassificationTest-DOCX-1.docx" -ForegroundColor Green
        
        Add-PnPFile -Path $docxFile2 -Folder "$LibraryName/$TestFolderName" | Out-Null
        Write-Host "   ✅ Uploaded: ClassificationTest-DOCX-2.docx" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  .docx files not uploaded (manual creation required)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ❌ Upload failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Cleanup Local Files
# =============================================================================

Write-Host ""
Write-Host "🧹 Cleaning up local files..." -ForegroundColor Green

Remove-Item $txtFile1 -Force -ErrorAction SilentlyContinue
Remove-Item $txtFile2 -Force -ErrorAction SilentlyContinue
if ($docxFile1) { Remove-Item $docxFile1 -Force -ErrorAction SilentlyContinue }
if ($docxFile2) { Remove-Item $docxFile2 -Force -ErrorAction SilentlyContinue }

Write-Host "   ✅ Local files removed" -ForegroundColor Green

# =============================================================================
# Test Instructions
# =============================================================================

Write-Host ""
Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host "=".PadRight(79, '=') -ForegroundColor Cyan
Write-Host "📋 NEXT STEPS - Manual Testing Required" -ForegroundColor Cyan
Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host "=".PadRight(79, '=') -ForegroundColor Cyan
Write-Host ""

Write-Host "1️⃣  Wait 15-30 minutes for SharePoint to index the new files" -ForegroundColor Yellow
Write-Host ""

Write-Host "2️⃣  Verify indexing with SharePoint search:" -ForegroundColor Yellow
Write-Host "   • Search for: 123-45-6789" -ForegroundColor Gray
Write-Host "   • Search for: 987-65-4321" -ForegroundColor Gray
Write-Host "   • Both searches should find the test files" -ForegroundColor Gray
Write-Host ""

Write-Host "3️⃣  Run on-demand classification scan:" -ForegroundColor Yellow
Write-Host "   • Go to: Microsoft Purview compliance portal" -ForegroundColor Gray
Write-Host "   • Data classification → On-demand" -ForegroundColor Gray
Write-Host "   • Click: Scan items" -ForegroundColor Gray
Write-Host "   • Name: 'Test - TXT vs DOCX Format'" -ForegroundColor Gray
Write-Host "   • Scope: Select the specific folder '$TestFolderName'" -ForegroundColor Gray
Write-Host "   • Classifiers: U.S. Social Security Number, Credit Card Number" -ForegroundColor Gray
Write-Host "   • Confidence: Medium" -ForegroundColor Gray
Write-Host "   • Start the scan" -ForegroundColor Gray
Write-Host ""

Write-Host "4️⃣  Compare results:" -ForegroundColor Yellow
Write-Host "   • Wait for scan to complete" -ForegroundColor Gray
Write-Host "   • Check how many matches found" -ForegroundColor Gray
Write-Host "   • Expected: 4 files with sensitive data (2 SSN, 2 Credit Card each)" -ForegroundColor Gray
Write-Host ""
Write-Host "   ❓ CRITICAL QUESTIONS:" -ForegroundColor Yellow
Write-Host "   • Did .txt files get classified? (0 or 2 matches)" -ForegroundColor Gray
Write-Host "   • Did .docx files get classified? (0 or 2 matches)" -ForegroundColor Gray
Write-Host "   • If .docx works but .txt doesn't = FILE FORMAT LIMITATION" -ForegroundColor Red
Write-Host "   • If neither works = CONFIGURATION ISSUE" -ForegroundColor Red
Write-Host "   • If both work = ORIGINAL TEST DATA ISSUE" -ForegroundColor Red
Write-Host ""

Write-Host "5️⃣  Document findings:" -ForegroundColor Yellow
Write-Host "   • Screenshot the scan results" -ForegroundColor Gray
Write-Host "   • Note which file types were classified" -ForegroundColor Gray
Write-Host "   • This will determine if lab needs .docx instead of .txt" -ForegroundColor Gray
Write-Host ""

Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host "=".PadRight(79, '=') -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ Test files ready in SharePoint folder: $TestFolderName" -ForegroundColor Green
Write-Host "📁 Location: $SiteUrl/$LibraryName/$TestFolderName" -ForegroundColor Green
Write-Host ""
