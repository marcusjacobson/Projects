<#
.SYNOPSIS
    Generates the EDM Schema XML file for the Retail Customer Database.

.DESCRIPTION
    This script creates the 'RetailCustomerDB.xml' schema file required for Exact Data Match (EDM).
    This file must be uploaded to the Purview portal (or via PowerShell) to define the data structure.

.PARAMETER OutputPath
    Path to save the XML file. Default is current directory.

.EXAMPLE
    .\New-EdmSchema.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2024-05-22
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [string]$OutputPath = $PSScriptRoot
)

$xmlContent = @"
<EdmSchema xmlns="http://schemas.microsoft.com/office/2018/edm">
  <DataStore name="RetailCustomerDB" description="Customer Database for Retail Operations" version="1">
    <Field name="CustomerId" searchable="true" caseInsensitive="true" ignoredDelimiters="" />
    <Field name="FirstName" searchable="false" caseInsensitive="true" ignoredDelimiters="" />
    <Field name="LastName" searchable="false" caseInsensitive="true" ignoredDelimiters="" />
    <Field name="Email" searchable="true" caseInsensitive="true" ignoredDelimiters="" />
    <Field name="CreditCardNumber" searchable="false" caseInsensitive="false" ignoredDelimiters="" />
  </DataStore>
</EdmSchema>
"@

$fileName = "RetailCustomerDB.xml"
$fullPath = Join-Path $OutputPath $fileName

$xmlContent | Out-File -FilePath $fullPath -Encoding UTF8
Write-Host "✅ EDM Schema generated at: $fullPath" -ForegroundColor Green
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Open Purview Portal > Data classification > Exact Data Matches." -ForegroundColor Cyan
Write-Host "   2. Upload this XML file manually OR use the EDM Upload Agent." -ForegroundColor Cyan
