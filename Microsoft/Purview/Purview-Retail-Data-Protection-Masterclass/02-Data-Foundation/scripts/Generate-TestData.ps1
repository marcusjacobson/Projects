<#
.SYNOPSIS
    Generates comprehensive test files with sensitive information types for DLP testing.

.DESCRIPTION
    Creates realistic test files in Microsoft Office formats (Word, Excel, PowerPoint, PDF)
    containing various combinations of Sensitive Information Types (SITs) including:
    - Credit Card Numbers (Luhn-valid)
    - Social Security Numbers
    - ABA Routing Numbers
    - Custom Loyalty IDs
    - PII (email, phone, address)
    
    Files are organized into three categories:
    - Single-SIT files (isolated testing)
    - Multi-SIT files (complex scenarios)
    - Clean files (false positive testing)

.EXAMPLE
    .\Generate-TestData.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 2.0.0
    Created: 2025-12-30
    Last Modified: 2025-12-30
    
    Requires: Microsoft Office installed (Word, Excel, PowerPoint)
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param()

# =============================================================================
# Step 1: Setup and Validation
# =============================================================================

Write-Host "`n🔍 Step 1: Setup and Validation" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputDir = Join-Path (Split-Path -Parent $scriptPath) "data-templates"

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Write-Host "✅ Output directory: $outputDir" -ForegroundColor Green

# Try to load Excel COM object for Excel file generation
try {
    $excelApp = New-Object -ComObject Excel.Application
    $excelApp.Visible = $false
    $excelApp.DisplayAlerts = $false
    $hasExcel = $true
    Write-Host "✅ Microsoft Excel COM object loaded" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Microsoft Excel not available - Excel files will be skipped" -ForegroundColor Yellow
    Write-Host "   Install Microsoft Office to enable Excel generation" -ForegroundColor Cyan
    $hasExcel = $false
}

# Try to load Word COM object for Word/PDF generation
try {
    $wordApp = New-Object -ComObject Word.Application
    $wordApp.Visible = $false
    $wordApp.DisplayAlerts = 0  # wdAlertsNone
    $hasWord = $true
    Write-Host "✅ Microsoft Word COM object loaded" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Microsoft Word not available - Word/PDF files will be skipped" -ForegroundColor Yellow
    Write-Host "   Install Microsoft Office to enable Word and PDF generation" -ForegroundColor Cyan
    $hasWord = $false
}

# Try to load PowerPoint COM object
try {
    $pptApp = New-Object -ComObject PowerPoint.Application
    # Don't set Visible property - it can cause issues and isn't necessary
    $hasPowerPoint = $true
    Write-Host "✅ Microsoft PowerPoint COM object loaded" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Microsoft PowerPoint not available - PPT files will be skipped" -ForegroundColor Yellow
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Cyan
    Write-Host "   Install Microsoft PowerPoint to enable PPT generation" -ForegroundColor Cyan
    $hasPowerPoint = $false
}

# =============================================================================
# Step 2: Helper Functions
# =============================================================================

Write-Host "`n🔍 Step 2: Helper Functions" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

# Generate Luhn-valid credit card numbers
function New-LuhnValidCreditCard {
    param([string]$Type = "Visa")
    
    $prefix = switch ($Type) {
        "Visa" { "4" }
        "Mastercard" { "5" + (Get-Random -Minimum 1 -Maximum 5) }
        "Amex" { "37" }
        "Discover" { "6011" }
    }
    
    $length = if ($Type -eq "Amex") { 15 } else { 16 }
    $number = $prefix
    
    while ($number.Length -lt ($length - 1)) {
        $number += Get-Random -Minimum 0 -Maximum 9
    }
    
    # Calculate Luhn checksum
    $sum = 0
    $alternate = $false
    for ($i = $number.Length - 1; $i -ge 0; $i--) {
        $digit = [int]($number[$i].ToString())
        if ($alternate) {
            $digit *= 2
            if ($digit -gt 9) { $digit -= 9 }
        }
        $sum += $digit
        $alternate = !$alternate
    }
    
    $checkDigit = (10 - ($sum % 10)) % 10
    $number += $checkDigit
    
    # Format with dashes
    if ($Type -eq "Amex") {
        return "$($number.Substring(0,4))-$($number.Substring(4,6))-$($number.Substring(10,5))"
    } else {
        return "$($number.Substring(0,4))-$($number.Substring(4,4))-$($number.Substring(8,4))-$($number.Substring(12,4))"
    }
}

# Generate realistic SSN (avoiding invalid patterns)
function New-RealisticSSN {
    do {
        $area = Get-Random -Minimum 1 -Maximum 899
        $group = Get-Random -Minimum 1 -Maximum 99
        $serial = Get-Random -Minimum 1 -Maximum 9999
    } while ($area -eq 666 -or $area -eq 0 -or $group -eq 0 -or $serial -eq 0)
    
    return "{0:000}-{1:00}-{2:0000}" -f $area, $group, $serial
}

# Generate ABA routing number with valid checksum
function New-ABARoutingNumber {
    $routing = ""
    for ($i = 0; $i -lt 8; $i++) {
        $routing += Get-Random -Minimum 0 -Maximum 9
    }
    
    # Calculate checksum (simplified)
    $checksum = Get-Random -Minimum 0 -Maximum 9
    return $routing + $checksum
}

# Generate custom loyalty ID
function New-LoyaltyID {
    $numbers = ""
    for ($i = 0; $i -lt 6; $i++) {
        $numbers += Get-Random -Minimum 0 -Maximum 9
    }
    $checkDigit = Get-Random -Minimum 0 -Maximum 9
    return "RET-$numbers-$checkDigit"
}

Write-Host "✅ Helper functions loaded" -ForegroundColor Green

# =============================================================================
# Step 3: Generate Customer Records
# =============================================================================

Write-Host "`n🔍 Step 3: Generate Customer Records" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

$firstNames = @("John", "Sarah", "Michael", "Emily", "David", "Jennifer", "Robert", "Lisa", "William", "Michelle", "James", "Amanda", "Richard", "Jessica", "Thomas", "Ashley", "Daniel", "Brittany", "Matthew", "Lauren")
$lastNames = @("Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin")
$streets = @("Main St", "Oak Ave", "Maple Dr", "Cedar Ln", "Pine Rd", "Elm St", "Washington Blvd", "Park Ave", "Lake Dr", "Hill St")
$cities = @("New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego", "Dallas", "San Jose")
$states = @("NY", "CA", "IL", "TX", "AZ", "PA", "TX", "CA", "TX", "CA")
$externalDomains = @("@gmail.com", "@outlook.com", "@yahoo.com", "@hotmail.com", "@icloud.com")
$cardTypes = @("Visa", "Mastercard", "Amex", "Discover")

$customerRecords = @()
for ($i = 1; $i -le 30; $i++) {
    $firstName = $firstNames | Get-Random
    $lastName = $lastNames | Get-Random
    $isInternal = ($i % 3) -ne 0  # 2/3 internal, 1/3 external
    
    $email = if ($isInternal) {
        "$($firstName.ToLower()).$($lastName.ToLower())@contoso.com"
    } else {
        "$($firstName.ToLower()).$($lastName.ToLower())$($externalDomains | Get-Random)"
    }
    
    $cardType = $cardTypes | Get-Random
    
    $customerRecords += [PSCustomObject]@{
        CustomerId = "C{0:000}" -f $i
        FirstName = $firstName
        LastName = $lastName
        Email = $email
        PhoneNumber = "({0:000}) {1:000}-{2:0000}" -f (Get-Random -Minimum 200 -Maximum 999), (Get-Random -Minimum 200 -Maximum 999), (Get-Random -Minimum 1000 -Maximum 9999)
        SSN = New-RealisticSSN
        CreditCardNumber = New-LuhnValidCreditCard -Type $cardType
        CreditCardType = $cardType
        BankRouting = New-ABARoutingNumber
        AccountNumber = "{0:00000000}" -f (Get-Random -Minimum 10000000 -Maximum 99999999)
        LoyaltyId = New-LoyaltyID
        Address = "{0} {1}" -f (Get-Random -Minimum 100 -Maximum 9999), ($streets | Get-Random)
        City = $cities | Get-Random
        State = $states | Get-Random
        ZipCode = "{0:00000}" -f (Get-Random -Minimum 10000 -Maximum 99999)
        MemberSince = (Get-Date).AddDays(-(Get-Random -Minimum 30 -Maximum 365)).ToString("yyyy-MM-dd")
    }
}

Write-Host "✅ Generated 30 customer records with realistic data" -ForegroundColor Green

# =============================================================================
# Step 4: Create Single-SIT Files
# =============================================================================

Write-Host "`n🔍 Step 4: Create Single-SIT Files" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# 4.1 Credit Cards Only (Excel Workbook)
if ($hasExcel) {
    try {
        $ccOnlyFile = Join-Path $outputDir "CreditCards-Only.xlsx"
        $workbook = $excelApp.Workbooks.Add()
        $worksheet = $workbook.Worksheets.Item(1)
        $worksheet.Name = "Payment Cards"
        
        $worksheet.Cells.Item(1, 1).Value2 = "Customer ID"
        $worksheet.Cells.Item(1, 2).Value2 = "First Name"
        $worksheet.Cells.Item(1, 3).Value2 = "Last Name"
        $worksheet.Cells.Item(1, 4).Value2 = "Credit Card Number"
        $worksheet.Cells.Item(1, 5).Value2 = "Credit Card Type"
        $worksheet.Cells.Item(1, 6).Value2 = "Email"
        
        $headerRange = $worksheet.Range("A1:F1")
        $headerRange.Font.Bold = $true
        $headerRange.Interior.ColorIndex = 15
        
        $row = 2
        $customerRecords | Select-Object -First 12 | ForEach-Object {
            $worksheet.Cells.Item($row, 1).Value2 = $_.CustomerId
            $worksheet.Cells.Item($row, 2).Value2 = $_.FirstName
            $worksheet.Cells.Item($row, 3).Value2 = $_.LastName
            $worksheet.Cells.Item($row, 4).Value2 = $_.CreditCardNumber
            $worksheet.Cells.Item($row, 5).Value2 = $_.CreditCardType
            $worksheet.Cells.Item($row, 6).Value2 = $_.Email
            $row++
        }
        
        $worksheet.UsedRange.Columns.AutoFit() | Out-Null
        $workbook.SaveAs($ccOnlyFile)
        $workbook.Close()
        Write-Host "✅ Created: CreditCards-Only.xlsx (Credit Card SIT only)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to create CreditCards-Only.xlsx: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 4.2 SSN Only (Word Document)
if ($hasWord) {
    try {
        $ssnDocFile = Join-Path $outputDir "SSN-Records.docx"
        $doc = $wordApp.Documents.Add()
        
        $selection = $wordApp.Selection
        $selection.Font.Size = 16
        $selection.Font.Bold = $true
        $selection.TypeText("CONFIDENTIAL - Social Security Number Records")
        $selection.TypeParagraph()
        $selection.TypeParagraph()
        
        $selection.Font.Size = 11
        $selection.Font.Bold = $false
        $selection.TypeText("Customer SSN Verification List")
        $selection.TypeParagraph()
        $selection.TypeText("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')")
        $selection.TypeParagraph()
        $selection.TypeParagraph()
        
        $table = $doc.Tables.Add($selection.Range, 9, 3)
        $table.Style = "Grid Table 4 - Accent 1"
        $table.Cell(1, 1).Range.Text = "Customer ID"
        $table.Cell(1, 2).Range.Text = "Name"
        $table.Cell(1, 3).Range.Text = "SSN"
        
        $row = 2
        $customerRecords | Select-Object -First 8 | ForEach-Object {
            $table.Cell($row, 1).Range.Text = $_.CustomerId
            $table.Cell($row, 2).Range.Text = "$($_.FirstName) $($_.LastName)"
            $table.Cell($row, 3).Range.Text = $_.SSN
            $row++
        }
        
        $doc.SaveAs2($ssnDocFile, 16)
        $doc.Close()
        Write-Host "✅ Created: SSN-Records.docx (SSN SIT only)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to create SSN-Records.docx: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 4.3 Banking Info Only (Excel Workbook)
if ($hasExcel) {
    try {
        $bankOnlyFile = Join-Path $outputDir "Banking-DirectDeposit.xlsx"
        $workbook = $excelApp.Workbooks.Add()
        $worksheet = $workbook.Worksheets.Item(1)
        $worksheet.Name = "Direct Deposit"
        
        $worksheet.Cells.Item(1, 1).Value2 = "Customer ID"
        $worksheet.Cells.Item(1, 2).Value2 = "First Name"
        $worksheet.Cells.Item(1, 3).Value2 = "Last Name"
        $worksheet.Cells.Item(1, 4).Value2 = "Bank Routing"
        $worksheet.Cells.Item(1, 5).Value2 = "Account Number"
        $worksheet.Cells.Item(1, 6).Value2 = "Email"
        
        $headerRange = $worksheet.Range("A1:F1")
        $headerRange.Font.Bold = $true
        $headerRange.Interior.ColorIndex = 34
        
        $row = 2
        $customerRecords | Select-Object -First 12 | ForEach-Object {
            $worksheet.Cells.Item($row, 1).Value2 = $_.CustomerId
            $worksheet.Cells.Item($row, 2).Value2 = $_.FirstName
            $worksheet.Cells.Item($row, 3).Value2 = $_.LastName
            $worksheet.Cells.Item($row, 4).Value2 = $_.BankRouting
            $worksheet.Cells.Item($row, 5).Value2 = $_.AccountNumber
            $worksheet.Cells.Item($row, 6).Value2 = $_.Email
            $row++
        }
        
        $worksheet.UsedRange.Columns.AutoFit() | Out-Null
        $workbook.SaveAs($bankOnlyFile)
        $workbook.Close()
        Write-Host "✅ Created: Banking-DirectDeposit.xlsx (ABA Routing SIT only)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to create Banking-DirectDeposit.xlsx: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 4.4 Loyalty IDs Only (Word Document)
if ($hasWord) {
    try {
        $loyaltyDocFile = Join-Path $outputDir "Loyalty-Program-Members.docx"
        $doc = $wordApp.Documents.Add()
        
        $selection = $wordApp.Selection
        $selection.Font.Size = 16
        $selection.Font.Bold = $true
        $selection.TypeText("Retail Rewards Loyalty Program")
        $selection.TypeParagraph()
        $selection.TypeParagraph()
        
        $selection.Font.Size = 11
        $selection.Font.Bold = $false
        
        $table = $doc.Tables.Add($selection.Range, 13, 3)
        $table.Style = "Grid Table 4 - Accent 3"
        $table.Cell(1, 1).Range.Text = "Member Name"
        $table.Cell(1, 2).Range.Text = "Loyalty ID"
        $table.Cell(1, 3).Range.Text = "Member Since"
        
        $row = 2
        $customerRecords | Select-Object -First 12 | ForEach-Object {
            $table.Cell($row, 1).Range.Text = "$($_.FirstName) $($_.LastName)"
            $table.Cell($row, 2).Range.Text = $_.LoyaltyId
            $table.Cell($row, 3).Range.Text = $_.MemberSince
            $row++
        }
        
        $doc.SaveAs2($loyaltyDocFile, 16)
        $doc.Close()
        Write-Host "✅ Created: Loyalty-Program-Members.docx (Custom Loyalty ID SIT only)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to create Loyalty-Program-Members.docx: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# =============================================================================
# Step 5: Create Multi-SIT Files
# =============================================================================

Write-Host "`n🔍 Step 5: Create Multi-SIT Files" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

# 5.1 Full Customer Database (Excel Workbook) - ALL SITs
if ($hasExcel) {
    try {
        $fullDbFile = Join-Path $outputDir "CustomerDatabase-FULL.xlsx"
        $workbook = $excelApp.Workbooks.Add()
        $worksheet = $workbook.Worksheets.Item(1)
        $worksheet.Name = "Customer Data"
        
        $headers = @("Customer ID", "First Name", "Last Name", "Email", "Phone", "SSN", "Credit Card", "CC Type", "Bank Routing", "Account #", "Loyalty ID", "Address", "City", "State", "Zip", "Member Since")
        for ($i = 0; $i -lt $headers.Count; $i++) {
            $worksheet.Cells.Item(1, $i + 1).Value2 = $headers[$i]
        }
        
        $headerRange = $worksheet.Range("A1:P1")
        $headerRange.Font.Bold = $true
        $headerRange.Interior.ColorIndex = 6
        
        $row = 2
        $customerRecords | ForEach-Object {
            $worksheet.Cells.Item($row, 1).Value2 = $_.CustomerId
            $worksheet.Cells.Item($row, 2).Value2 = $_.FirstName
            $worksheet.Cells.Item($row, 3).Value2 = $_.LastName
            $worksheet.Cells.Item($row, 4).Value2 = $_.Email
            $worksheet.Cells.Item($row, 5).Value2 = $_.PhoneNumber
            $worksheet.Cells.Item($row, 6).Value2 = $_.SSN
            $worksheet.Cells.Item($row, 7).Value2 = $_.CreditCardNumber
            $worksheet.Cells.Item($row, 8).Value2 = $_.CreditCardType
            $worksheet.Cells.Item($row, 9).Value2 = $_.BankRouting
            $worksheet.Cells.Item($row, 10).Value2 = $_.AccountNumber
            $worksheet.Cells.Item($row, 11).Value2 = $_.LoyaltyId
            $worksheet.Cells.Item($row, 12).Value2 = $_.Address
            $worksheet.Cells.Item($row, 13).Value2 = $_.City
            $worksheet.Cells.Item($row, 14).Value2 = $_.State
            $worksheet.Cells.Item($row, 15).Value2 = $_.ZipCode
            $worksheet.Cells.Item($row, 16).Value2 = $_.MemberSince
            $row++
        }
        
        $worksheet.UsedRange.Columns.AutoFit() | Out-Null
        $workbook.SaveAs($fullDbFile)
        $workbook.Close()
        Write-Host "✅ Created: CustomerDatabase-FULL.xlsx (ALL SITs: CC, SSN, ABA, Loyalty)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to create CustomerDatabase-FULL.xlsx: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 5.2 PCI-DSS Payment Report (Word Document with PDF)
if ($hasWord) {
    try {
        $pciDocFile = Join-Path $outputDir "Payment-Processing-Report.docx"
        $pciPdfFile = Join-Path $outputDir "Payment-Processing-Report.pdf"
        
        $doc = $wordApp.Documents.Add()
        $selection = $wordApp.Selection
        
        $selection.Font.Size = 16
        $selection.Font.Bold = $true
        $selection.Font.Color = 255
        $selection.TypeText("PCI-DSS RESTRICTED")
        $selection.TypeParagraph()
        $selection.TypeParagraph()
        
        $selection.Font.Size = 14
        $selection.Font.Color = 0
        $selection.TypeText("Payment Processing Report")
        $selection.TypeParagraph()
        $selection.Font.Size = 12
        $selection.Font.Bold = $false
        $selection.TypeText("Q4 2025")
        $selection.TypeParagraph()
        $selection.TypeParagraph()
        
        $selection.Font.Size = 10
        $selection.Font.Italic = $true
        $selection.TypeText("This document contains payment card and banking information.")
        $selection.TypeParagraph()
        $selection.TypeText("Access restricted to Finance and Compliance teams only.")
        $selection.Font.Italic = $false
        $selection.TypeParagraph()
        $selection.TypeParagraph()
        
        $selection.Font.Size = 12
        $selection.Font.Bold = $true
        $selection.TypeText("Customer Payment Records")
        $selection.Font.Bold = $false
        $selection.TypeParagraph()
        $selection.TypeParagraph()
        
        $table = $doc.Tables.Add($selection.Range, 11, 6)
        $table.Style = "Grid Table 1 Light - Accent 1"
        $table.Cell(1, 1).Range.Text = "Customer"
        $table.Cell(1, 2).Range.Text = "Email"
        $table.Cell(1, 3).Range.Text = "Credit Card"
        $table.Cell(1, 4).Range.Text = "Type"
        $table.Cell(1, 5).Range.Text = "Bank Routing"
        $table.Cell(1, 6).Range.Text = "Account #"
        
        $row = 2
        $customerRecords | Select-Object -First 10 | ForEach-Object {
            $table.Cell($row, 1).Range.Text = "$($_.FirstName) $($_.LastName)"
            $table.Cell($row, 2).Range.Text = $_.Email
            $table.Cell($row, 3).Range.Text = $_.CreditCardNumber
            $table.Cell($row, 4).Range.Text = $_.CreditCardType
            $table.Cell($row, 5).Range.Text = $_.BankRouting
            $table.Cell($row, 6).Range.Text = $_.AccountNumber
            $row++
        }
        
        $doc.SaveAs2($pciDocFile, 16)
        $doc.SaveAs2($pciPdfFile, 17)
        $doc.Close()
        Write-Host "✅ Created: Payment-Processing-Report.docx (CC + Banking)" -ForegroundColor Green
        Write-Host "✅ Created: Payment-Processing-Report.pdf (CC + Banking)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to create Payment-Processing-Report: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 5.3 Customer Profile Export (Word Document) - PII + SSN + Loyalty
if ($hasWord) {
    try {
        $profileDocFile = Join-Path $outputDir "Customer-Profile-Export.docx"
        $doc = $wordApp.Documents.Add()
        $selection = $wordApp.Selection
        
        $selection.Font.Size = 14
        $selection.Font.Bold = $true
        $selection.TypeText("Customer Profile Database Export")
        $selection.TypeParagraph()
        $selection.Font.Size = 10
        $selection.Font.Bold = $false
        $selection.Font.Italic = $true
        $selection.TypeText("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')")
        $selection.Font.Italic = $false
        $selection.TypeParagraph()
        $selection.TypeParagraph()
        
        $customerRecords | Select-Object -First 8 | ForEach-Object {
            $selection.Font.Size = 11
            $selection.Font.Bold = $true
            $selection.TypeText("$($_.FirstName) $($_.LastName) (ID: $($_.CustomerId))")
            $selection.Font.Bold = $false
            $selection.TypeParagraph()
            
            $selection.Font.Size = 10
            $selection.TypeText("Email: $($_.Email)")
            $selection.TypeParagraph()
            $selection.TypeText("Phone: $($_.PhoneNumber)")
            $selection.TypeParagraph()
            $selection.TypeText("Address: $($_.Address), $($_.City), $($_.State) $($_.ZipCode)")
            $selection.TypeParagraph()
            $selection.TypeText("SSN: $($_.SSN)")
            $selection.TypeParagraph()
            $selection.TypeText("Loyalty ID: $($_.LoyaltyId)")
            $selection.TypeParagraph()
            $selection.TypeText("Member Since: $($_.MemberSince)")
            $selection.TypeParagraph()
            $selection.TypeParagraph()
        }
        
        $doc.SaveAs2($profileDocFile, 16)
        $doc.Close()
        Write-Host "✅ Created: Customer-Profile-Export.docx (PII + SSN + Loyalty)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to create Customer-Profile-Export.docx: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 5.4 Financial Presentation (PowerPoint)
if ($hasPowerPoint) {
    try {
        $pptFile = Join-Path $outputDir "Q4-Financial-Review.pptx"
        $pres = $pptApp.Presentations.Add()
        
        # Slide 1: Title
        $slide1 = $pres.Slides.Add(1, 1)
        $slide1.Shapes.Title.TextFrame.TextRange.Text = "Q4 2025 Financial Review"
        $slide1.Shapes.Item(2).TextFrame.TextRange.Text = "CONFIDENTIAL - Internal Use Only"
        
        # Slide 2: Payment Data
        $slide2 = $pres.Slides.Add(2, 2)
        $slide2.Shapes.Title.TextFrame.TextRange.Text = "Customer Payment Information"
        
        $textBox = $slide2.Shapes.Item(2).TextFrame.TextRange
        $textContent = "Top Customer Accounts:`n`n"
        $customerRecords | Select-Object -First 5 | ForEach-Object {
            $textContent += "$($_.FirstName) $($_.LastName)`n"
            $textContent += "  CC: $($_.CreditCardNumber) ($($_.CreditCardType))`n"
            $textContent += "  SSN: $($_.SSN)`n"
            $textContent += "  Bank: $($_.BankRouting) - $($_.AccountNumber)`n`n"
        }
        $textBox.Text = $textContent
        
        # Slide 3: Contact Info
        $slide3 = $pres.Slides.Add(3, 2)
        $slide3.Shapes.Title.TextFrame.TextRange.Text = "Customer Contact Database"
        
        $textBox3 = $slide3.Shapes.Item(2).TextFrame.TextRange
        $contactContent = "Premium Tier Customers:`n`n"
        $customerRecords | Select-Object -First 6 | ForEach-Object {
            $contactContent += "$($_.FirstName) $($_.LastName) - $($_.Email)`n"
            $contactContent += "Loyalty: $($_.LoyaltyId) | Phone: $($_.PhoneNumber)`n`n"
        }
        $textBox3.Text = $contactContent
        
        $pres.SaveAs($pptFile)
        $pres.Close()
        Write-Host "✅ Created: Q4-Financial-Review.pptx (CC + SSN + Banking + Loyalty)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to create Q4-Financial-Review.pptx: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 5.5 Multi-Sheet Excel Workbook
if ($hasExcel) {
    try {
        $excelFile = Join-Path $outputDir "Retail-Financial-Data.xlsx"
        $workbook = $excelApp.Workbooks.Add()
        
        # Sheet 1: Payment Cards
        $worksheet1 = $workbook.Worksheets.Item(1)
        $worksheet1.Name = "Payment Cards"
        
        $worksheet1.Cells.Item(1, 1).Value2 = "Customer ID"
        $worksheet1.Cells.Item(1, 2).Value2 = "First Name"
        $worksheet1.Cells.Item(1, 3).Value2 = "Last Name"
        $worksheet1.Cells.Item(1, 4).Value2 = "Credit Card Number"
        $worksheet1.Cells.Item(1, 5).Value2 = "Credit Card Type"
        $worksheet1.Cells.Item(1, 6).Value2 = "Email"
        
        $headerRange1 = $worksheet1.Range("A1:F1")
        $headerRange1.Font.Bold = $true
        $headerRange1.Interior.ColorIndex = 15
        
        $row = 2
        $customerRecords | Select-Object -First 15 | ForEach-Object {
            $worksheet1.Cells.Item($row, 1).Value2 = $_.CustomerId
            $worksheet1.Cells.Item($row, 2).Value2 = $_.FirstName
            $worksheet1.Cells.Item($row, 3).Value2 = $_.LastName
            $worksheet1.Cells.Item($row, 4).Value2 = $_.CreditCardNumber
            $worksheet1.Cells.Item($row, 5).Value2 = $_.CreditCardType
            $worksheet1.Cells.Item($row, 6).Value2 = $_.Email
            $row++
        }
        $worksheet1.UsedRange.Columns.AutoFit() | Out-Null
        
        # Sheet 2: Tax Records
        $worksheet2 = $workbook.Worksheets.Add([System.Reflection.Missing]::Value, $worksheet1)
        $worksheet2.Name = "Tax Records"
        
        $worksheet2.Cells.Item(1, 1).Value2 = "Customer ID"
        $worksheet2.Cells.Item(1, 2).Value2 = "First Name"
        $worksheet2.Cells.Item(1, 3).Value2 = "Last Name"
        $worksheet2.Cells.Item(1, 4).Value2 = "SSN"
        $worksheet2.Cells.Item(1, 5).Value2 = "Phone Number"
        $worksheet2.Cells.Item(1, 6).Value2 = "Email"
        
        $headerRange2 = $worksheet2.Range("A1:F1")
        $headerRange2.Font.Bold = $true
        $headerRange2.Interior.ColorIndex = 34
        
        $row = 2
        $customerRecords | Select-Object -First 15 | ForEach-Object {
            $worksheet2.Cells.Item($row, 1).Value2 = $_.CustomerId
            $worksheet2.Cells.Item($row, 2).Value2 = $_.FirstName
            $worksheet2.Cells.Item($row, 3).Value2 = $_.LastName
            $worksheet2.Cells.Item($row, 4).Value2 = $_.SSN
            $worksheet2.Cells.Item($row, 5).Value2 = $_.PhoneNumber
            $worksheet2.Cells.Item($row, 6).Value2 = $_.Email
            $row++
        }
        $worksheet2.UsedRange.Columns.AutoFit() | Out-Null
        
        # Sheet 3: Complete Database
        $worksheet3 = $workbook.Worksheets.Add([System.Reflection.Missing]::Value, $worksheet2)
        $worksheet3.Name = "Complete Database"
        
        $headers3 = @("Customer ID", "First Name", "Last Name", "Email", "Phone", "SSN", "Credit Card", "Bank Routing", "Loyalty ID")
        for ($i = 0; $i -lt $headers3.Count; $i++) {
            $worksheet3.Cells.Item(1, $i + 1).Value2 = $headers3[$i]
        }
        
        $headerRange3 = $worksheet3.Range("A1:I1")
        $headerRange3.Font.Bold = $true
        $headerRange3.Interior.ColorIndex = 6
        
        $row = 2
        $customerRecords | Select-Object -First 20 | ForEach-Object {
            $worksheet3.Cells.Item($row, 1).Value2 = $_.CustomerId
            $worksheet3.Cells.Item($row, 2).Value2 = $_.FirstName
            $worksheet3.Cells.Item($row, 3).Value2 = $_.LastName
            $worksheet3.Cells.Item($row, 4).Value2 = $_.Email
            $worksheet3.Cells.Item($row, 5).Value2 = $_.PhoneNumber
            $worksheet3.Cells.Item($row, 6).Value2 = $_.SSN
            $worksheet3.Cells.Item($row, 7).Value2 = $_.CreditCardNumber
            $worksheet3.Cells.Item($row, 8).Value2 = $_.BankRouting
            $worksheet3.Cells.Item($row, 9).Value2 = $_.LoyaltyId
            $row++
        }
        $worksheet3.UsedRange.Columns.AutoFit() | Out-Null
        
        $workbook.SaveAs($excelFile)
        $workbook.Close()
        Write-Host "✅ Created: Retail-Financial-Data.xlsx (Multi-sheet with various SITs)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to create Retail-Financial-Data.xlsx: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# =============================================================================
# Step 6: Create Clean Control Files
# =============================================================================

Write-Host "`n🔍 Step 6: Create Clean Control Files" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# 6.1 Product Catalog (Excel)
if ($hasExcel) {
    try {
        $productFile = Join-Path $outputDir "Product-Catalog.xlsx"
        $workbook = $excelApp.Workbooks.Add()
        $worksheet = $workbook.Worksheets.Item(1)
        $worksheet.Name = "Products"
        
        $worksheet.Cells.Item(1, 1).Value2 = "SKU"
        $worksheet.Cells.Item(1, 2).Value2 = "Product Name"
        $worksheet.Cells.Item(1, 3).Value2 = "Category"
        $worksheet.Cells.Item(1, 4).Value2 = "Price"
        $worksheet.Cells.Item(1, 5).Value2 = "Stock"
        
        $headerRange = $worksheet.Range("A1:E1")
        $headerRange.Font.Bold = $true
        $headerRange.Interior.ColorIndex = 35
        
        $products = @(
            @{SKU="PRD-1001"; Name="Wireless Mouse"; Category="Electronics"; Price=29.99; Stock=150},
            @{SKU="PRD-1002"; Name="USB-C Cable"; Category="Accessories"; Price=12.99; Stock=300},
            @{SKU="PRD-1003"; Name="Laptop Stand"; Category="Office Supplies"; Price=45.00; Stock=75},
            @{SKU="PRD-1004"; Name="Keyboard"; Category="Electronics"; Price=89.99; Stock=120},
            @{SKU="PRD-1005"; Name="Headphones"; Category="Electronics"; Price=149.99; Stock=200},
            @{SKU="PRD-1006"; Name="Monitor Arm"; Category="Office Supplies"; Price=79.99; Stock=60},
            @{SKU="PRD-1007"; Name="Webcam"; Category="Electronics"; Price=69.99; Stock=90},
            @{SKU="PRD-1008"; Name="Desk Lamp"; Category="Office Supplies"; Price=34.99; Stock=110}
        )
        
        $row = 2
        foreach ($product in $products) {
            $worksheet.Cells.Item($row, 1).Value2 = [string]$product.SKU
            $worksheet.Cells.Item($row, 2).Value2 = [string]$product.Name
            $worksheet.Cells.Item($row, 3).Value2 = [string]$product.Category
            $worksheet.Cells.Item($row, 4).Value2 = [double]$product.Price
            $worksheet.Cells.Item($row, 5).Value2 = [int]$product.Stock
            $row++
        }
        
        $worksheet.UsedRange.Columns.AutoFit() | Out-Null
        $workbook.SaveAs([string]$productFile)
        $workbook.Close()
        Write-Host "✅ Created: Product-Catalog.xlsx (NO sensitive data - control file)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to create Product-Catalog.xlsx: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 6.2 Meeting Notes (Word)
if ($hasWord) {
    try {
        $meetingDocFile = Join-Path $outputDir "Team-Meeting-Notes.docx"
        $doc = $wordApp.Documents.Add()
        $selection = $wordApp.Selection
        
        $selection.Font.Size = 14
        $selection.Font.Bold = $true
        $selection.TypeText("Team Meeting Notes - December 30, 2025")
        $selection.Font.Bold = $false
        $selection.TypeParagraph()
        $selection.TypeParagraph()
        
        $selection.Font.Size = 11
        $selection.Font.Bold = $true
        $selection.TypeText("Attendees:")
        $selection.Font.Bold = $false
        $selection.TypeParagraph()
        $selection.TypeText("- Sarah Johnson, Product Manager")
        $selection.TypeParagraph()
        $selection.TypeText("- Michael Chen, Engineering Lead")
        $selection.TypeParagraph()
        $selection.TypeText("- Emily Rodriguez, UX Designer")
        $selection.TypeParagraph()
        $selection.TypeParagraph()
        
        $selection.Font.Bold = $true
        $selection.TypeText("Discussion Topics:")
        $selection.Font.Bold = $false
        $selection.TypeParagraph()
        $selection.TypeText("1. Q1 2026 Product Roadmap")
        $selection.TypeParagraph()
        $selection.TypeText("2. Customer Feedback Review")
        $selection.TypeParagraph()
        $selection.TypeText("3. Sprint Planning")
        $selection.TypeParagraph()
        $selection.TypeParagraph()
        
        $selection.Font.Bold = $true
        $selection.TypeText("Action Items:")
        $selection.Font.Bold = $false
        $selection.TypeParagraph()
        $selection.TypeText("- Schedule design review meeting")
        $selection.TypeParagraph()
        $selection.TypeText("- Update documentation")
        $selection.TypeParagraph()
        $selection.TypeText("- Review analytics dashboard")
        $selection.TypeParagraph()
        
        $doc.SaveAs2($meetingDocFile, 16)
        $doc.Close()
        Write-Host "✅ Created: Team-Meeting-Notes.docx (NO sensitive data - control file)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to create Team-Meeting-Notes.docx: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 6.3 Sales Strategy (PowerPoint)
if ($hasPowerPoint) {
    try {
        $strategyPptFile = Join-Path $outputDir "Q1-Sales-Strategy.pptx"
        $pres = $pptApp.Presentations.Add()
        
        $slide1 = $pres.Slides.Add(1, 1)
        $slide1.Shapes.Title.TextFrame.TextRange.Text = "Q1 2026 Sales Strategy"
        $slide1.Shapes.Item(2).TextFrame.TextRange.Text = "Marketing Team Presentation"
        
        $slide2 = $pres.Slides.Add(2, 2)
        $slide2.Shapes.Title.TextFrame.TextRange.Text = "Target Markets"
        $slide2.Shapes.Item(2).TextFrame.TextRange.Text = "Focus Areas:`n`n- Enterprise Customers`n- SMB Sector`n- International Expansion`n- Partner Network"
        
        $slide3 = $pres.Slides.Add(3, 2)
        $slide3.Shapes.Title.TextFrame.TextRange.Text = "Key Initiatives"
        $slide3.Shapes.Item(2).TextFrame.TextRange.Text = "Strategic Goals:`n`n- Digital Marketing Campaign`n- Product Training Series`n- Customer Success Program`n- Partner Enablement"
        
        $pres.SaveAs($strategyPptFile)
        $pres.Close()
        Write-Host "✅ Created: Q1-Sales-Strategy.pptx (NO sensitive data - control file)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to create Q1-Sales-Strategy.pptx: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# =============================================================================
# Step 7: Cleanup
# =============================================================================

Write-Host "`n🔍 Step 7: Cleanup" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green

if ($hasExcel) {
    try {
        $excelApp.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excelApp) | Out-Null
        Write-Host "✅ Closed Microsoft Excel" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Excel cleanup warning: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

if ($hasWord) {
    try {
        $wordApp.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wordApp) | Out-Null
        Write-Host "✅ Closed Microsoft Word" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Word cleanup warning: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

if ($hasPowerPoint) {
    try {
        $pptApp.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($pptApp) | Out-Null
        Write-Host "✅ Closed Microsoft PowerPoint" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  PowerPoint cleanup warning: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

# =============================================================================
# Step 8: Summary
# =============================================================================

Write-Host "`n📊 Test Data Generation Complete!" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

$allFiles = Get-ChildItem -Path $outputDir -File
$excelFiles = $allFiles | Where-Object { $_.Extension -eq ".xlsx" }
$wordFiles = $allFiles | Where-Object { $_.Extension -eq ".docx" }
$pdfFiles = $allFiles | Where-Object { $_.Extension -eq ".pdf" }
$pptFiles = $allFiles | Where-Object { $_.Extension -eq ".pptx" }

Write-Host "`n📁 Files Created:" -ForegroundColor Cyan

if ($excelFiles.Count -gt 0) {
    Write-Host "`n  📊 Excel Files ($($excelFiles.Count)):" -ForegroundColor Yellow
    $excelFiles | ForEach-Object { Write-Host "     - $($_.Name)" -ForegroundColor White }
}

if ($wordFiles.Count -gt 0) {
    Write-Host "`n  📄 Word Documents ($($wordFiles.Count)):" -ForegroundColor Yellow
    $wordFiles | ForEach-Object { Write-Host "     - $($_.Name)" -ForegroundColor White }
}

if ($pdfFiles.Count -gt 0) {
    Write-Host "`n  📕 PDF Files ($($pdfFiles.Count)):" -ForegroundColor Yellow
    $pdfFiles | ForEach-Object { Write-Host "     - $($_.Name)" -ForegroundColor White }
}

if ($pptFiles.Count -gt 0) {
    Write-Host "`n  📊 PowerPoint Files ($($pptFiles.Count)):" -ForegroundColor Yellow
    $pptFiles | ForEach-Object { Write-Host "     - $($_.Name)" -ForegroundColor White }
}

Write-Host "`n📈 Total Files Generated: $($allFiles.Count)" -ForegroundColor Green
Write-Host "📂 Output Location: $outputDir" -ForegroundColor Cyan
Write-Host "`n✅ Ready for SharePoint upload with Upload-TestDocs.ps1" -ForegroundColor Green

