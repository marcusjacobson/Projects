<#
.SYNOPSIS
    Generates synthetic retail customer data with Luhn-valid credit card numbers.

.DESCRIPTION
    This script creates a CSV file containing realistic but fake customer data.
    It includes:
    - Full Names
    - Email Addresses
    - Credit Card Numbers (Visa, Mastercard, Amex) that pass Luhn validation.
    - Loyalty IDs (Format: RET-123456-X)
    
    This data is designed to trigger high-confidence DLP matches.

.PARAMETER Count
    Number of records to generate. Default is 100.

.PARAMETER OutputPath
    Path to save the CSV file.

.EXAMPLE
    .\Generate-RetailData.ps1 -Count 500 -OutputPath ".\Customers.csv"

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2024-05-22
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [int]$Count = 100,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

# =============================================================================
# Helper Functions
# =============================================================================

function Get-LuhnCheckDigit {
    param ([string]$Number)
    
    $sum = 0
    $alt = $true
    
    for ($i = $Number.Length - 1; $i -ge 0; $i--) {
        $n = [int][string]$Number[$i]
        
        if ($alt) {
            $n *= 2
            if ($n -gt 9) { $n -= 9 }
        }
        
        $sum += $n
        $alt = -not $alt
    }
    
    return ($sum * 9) % 10
}

function New-CreditCardNumber {
    param ([ValidateSet("Visa","Mastercard","Amex")]$Type)
    
    switch ($Type) {
        "Visa" { 
            $prefix = "4"
            $length = 16 
        }
        "Mastercard" { 
            $prefix = "5" + (Get-Random -Minimum 1 -Maximum 6) # 51-55
            $length = 16 
        }
        "Amex" { 
            $prefix = "3" + (Get-Random -InputObject 4,7) # 34 or 37
            $length = 15 
        }
    }
    
    # Generate random digits
    $randomDigitsCount = $length - $prefix.Length - 1
    $randomPart = -join (1..$randomDigitsCount | ForEach-Object { Get-Random -Minimum 0 -Maximum 10 })
    
    $partial = $prefix + $randomPart
    $checkDigit = Get-LuhnCheckDigit -Number $partial
    
    return $partial + $checkDigit
}

# =============================================================================
# Data Generation
# =============================================================================

Write-Host "🚀 Generating $Count records..." -ForegroundColor Cyan

$firstNames = @("James","Mary","John","Patricia","Robert","Jennifer","Michael","Linda","William","Elizabeth","David","Barbara")
$lastNames = @("Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez")
$domains = @("outlook.com","gmail.com","yahoo.com","hotmail.com","live.com")

$data = @()

for ($i = 1; $i -le $Count; $i++) {
    $first = $firstNames | Get-Random
    $last = $lastNames | Get-Random
    $domain = $domains | Get-Random
    
    $cardType = ("Visa","Mastercard","Amex") | Get-Random
    $cc = New-CreditCardNumber -Type $cardType
    
    $loyaltyId = "RET-{0:D6}-{1}" -f (Get-Random -Minimum 0 -Maximum 999999), ([char](Get-Random -Minimum 65 -Maximum 91))
    
    $record = [PSCustomObject]@{
        CustomerId = $i
        FirstName = $first
        LastName = $last
        Email = "$first.$last@$domain".ToLower()
        CreditCardNumber = $cc
        CardType = $cardType
        LoyaltyId = $loyaltyId
        TransactionDate = (Get-Date).AddDays(-(Get-Random -Minimum 0 -Maximum 365)).ToString("yyyy-MM-dd")
    }
    
    $data += $record
    
    if ($i % 100 -eq 0) {
        Write-Host "   ... $i records generated" -ForegroundColor Gray
    }
}

# =============================================================================
# Output
# =============================================================================

$parentDir = Split-Path $OutputPath -Parent
if (-not (Test-Path $parentDir)) {
    New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
}

$data | Export-Csv -Path $OutputPath -NoTypeInformation
Write-Host "✅ Data saved to: $OutputPath" -ForegroundColor Green
