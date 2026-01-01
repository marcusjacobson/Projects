<#
.SYNOPSIS
    Generates test data files for Custom SIT and EDM testing.

.DESCRIPTION
    Creates two CSV files for different testing purposes:
    - CustomerDB_TestData.csv (8 fields): For Custom SIT testing with MembershipType keywords
    - CustomerDB_EDM.csv (7 fields): For EDM wizard schema creation (no MembershipType)

.NOTES
    Author: Marcus Jacobson
    Version: 2.0.0
    Created: 2025-12-31
    Last Modified: 2025-12-31
    
    Script development orchestrated using GitHub Copilot.
#>

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputDir = Join-Path (Split-Path -Parent $scriptPath) "Output"

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

Write-Host "`n📋 Generating Test Data Files" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

# =============================================================================
# File 1: CustomerDB_TestData.csv (8 fields - for Custom SIT testing)
# =============================================================================

Write-Host "`n🔸 Generating CustomerDB_TestData.csv (8 fields)..." -ForegroundColor Magenta

$testDataPath = Join-Path $outputDir "CustomerDB_TestData.csv"

$testDataContent = @"
CustomerId,FirstName,LastName,Email,PhoneNumber,CreditCardNumber,LoyaltyId,MembershipType
C001,John,Doe,john.doe@contoso.com,555-123-4567,1234-5678-9012-3456,RET-123456-7,Rewards Member
C002,Jane,Smith,jane.smith@contoso.com,555-234-5678,2345-6789-0123-4567,RET-234567-8,Loyalty Gold
C003,Alice,Johnson,alice.j@contoso.com,555-345-6789,3456-7890-1234-5678,RET-345678-9,Points Member
C004,Bob,Williams,bob.w@contoso.com,555-456-7890,4567-8901-2345-6789,RET-456789-0,Retail Rewards
C005,Carol,Brown,carol.brown@contoso.com,555-567-8901,5678-9012-3456-7890,RET-567890-1,Member Plus
"@

$testDataContent | Out-File -FilePath $testDataPath -Encoding UTF8

Write-Host "✅ Test data created: $testDataPath" -ForegroundColor Green
Write-Host "   Rows: 5 customers" -ForegroundColor Cyan
Write-Host "   Fields: 8 (includes MembershipType with keywords)" -ForegroundColor Cyan
Write-Host "   Purpose: Custom SIT keyword proximity testing (Lab 01)" -ForegroundColor Gray

# =============================================================================
# File 2: CustomerDB_EDM.csv (7 fields - for EDM wizard)
# =============================================================================

Write-Host "`n🔸 Generating CustomerDB_EDM.csv (7 fields)..." -ForegroundColor Magenta

$edmPath = Join-Path $outputDir "CustomerDB_EDM.csv"

$edmContent = @"
CustomerId,FirstName,LastName,Email,PhoneNumber,CreditCardNumber,LoyaltyId
C001,John,Doe,john.doe@contoso.com,555-123-4567,1234-5678-9012-3456,RET-123456-7
C002,Jane,Smith,jane.smith@contoso.com,555-234-5678,2345-6789-0123-4567,RET-234567-8
C003,Alice,Johnson,alice.j@contoso.com,555-345-6789,3456-7890-1234-5678,RET-345678-9
"@

$edmContent | Out-File -FilePath $edmPath -Encoding UTF8

Write-Host "✅ EDM schema file created: $edmPath" -ForegroundColor Green
Write-Host "   Rows: 3 customers" -ForegroundColor Cyan
Write-Host "   Fields: 7 (no MembershipType)" -ForegroundColor Cyan
Write-Host "   Purpose: EDM wizard schema creation (Lab 02)" -ForegroundColor Gray

# =============================================================================
# Summary
# =============================================================================

Write-Host "`n📊 Summary" -ForegroundColor Cyan
Write-Host "==========" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ CustomerDB_TestData.csv: 8 fields, 5 customers" -ForegroundColor Green
Write-Host "   Use for: Lab 01 Custom SIT testing (keyword proximity)" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ CustomerDB_EDM.csv: 7 fields, 3 customers" -ForegroundColor Green
Write-Host "   Use for: Lab 02 EDM wizard upload (schema creation)" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Both files share common data structure for primary/supporting elements" -ForegroundColor Yellow
Write-Host "   (CustomerId, FirstName, LastName, Email, PhoneNumber, CreditCardNumber, LoyaltyId)" -ForegroundColor Gray
Write-Host ""
