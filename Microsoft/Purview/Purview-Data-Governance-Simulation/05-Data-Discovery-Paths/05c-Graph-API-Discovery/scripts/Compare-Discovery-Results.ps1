<#
.SYNOPSIS
    Simplified comparison of Lab 05b and Lab 05c discovery results.

.DESCRIPTION
    Compares the latest detailed analysis CSVs from Lab 05b (Manual) and Lab 05c (Graph API).
    Checks for parity in:
    1. Total unique files detected
    2. Total SIT instances detected
    3. Breakdown by SIT Type

.NOTES
    Author: Marcus Jacobson
    Script development orchestrated using GitHub Copilot.
#>

$ErrorActionPreference = "Stop"

function Get-LatestReport {
    param($Path, $Pattern)
    Get-ChildItem -Path $Path -Filter $Pattern -ErrorAction SilentlyContinue | 
        Sort-Object LastWriteTime -Descending | 
        Select-Object -First 1
}

# Define paths
$lab05cReportsPath = Join-Path $PSScriptRoot "..\reports"
$lab05bReportsPath = Join-Path $PSScriptRoot "..\..\05b-eDiscovery-Compliance-Search\reports"

Write-Host "`n🔍 Finding latest analysis reports..." -ForegroundColor Cyan

# Get latest files
$file05c = Get-LatestReport -Path $lab05cReportsPath -Pattern "eDiscovery-Detailed-Analysis-*.csv"
$file05b = Get-LatestReport -Path $lab05bReportsPath -Pattern "eDiscovery-Detailed-Analysis-*.csv"

if (-not $file05c -or -not $file05b) {
    Write-Error "Could not find analysis reports in one or both folders."
}

Write-Host "   📄 Lab 05c (API):    $($file05c.Name)" -ForegroundColor Green
Write-Host "   📄 Lab 05b (Manual): $($file05b.Name)" -ForegroundColor Green

# Import data
Write-Host "`n📋 Importing data..." -ForegroundColor Cyan
$data05c = Import-Csv $file05c.FullName
$data05b = Import-Csv $file05b.FullName

# 1. File Count Comparison
Write-Host "`n📊 1. File Count Comparison" -ForegroundColor Magenta
Write-Host "=============================" -ForegroundColor Magenta

$files05c = $data05c | Select-Object -ExpandProperty FileName -Unique
$files05b = $data05b | Select-Object -ExpandProperty FileName -Unique

$count05c = $files05c.Count
$count05b = $files05b.Count
$diffFiles = $count05c - $count05b

Write-Host "   Lab 05c Unique Files: $count05c" -ForegroundColor Cyan
Write-Host "   Lab 05b Unique Files: $count05b" -ForegroundColor Cyan

if ($diffFiles -eq 0) {
    Write-Host "   ✅ File counts match exactly." -ForegroundColor Green
} else {
    Write-Host "   ❌ Variance: $diffFiles files" -ForegroundColor Red
    
    # Check for missing files
    $missingIn05c = $files05b | Where-Object { $files05c -notcontains $_ }
    if ($missingIn05c) {
        Write-Host "   ⚠️  Files in 05b but missing in 05c (First 5):" -ForegroundColor Yellow
        $missingIn05c | Select-Object -First 5 | ForEach-Object { Write-Host "      - $_" }
    }
}

# 2. SIT Instance Comparison
Write-Host "`n📊 2. SIT Instance Comparison" -ForegroundColor Magenta
Write-Host "=============================" -ForegroundColor Magenta

$sitCount05c = $data05c.Count
$sitCount05b = $data05b.Count
$diffSits = $sitCount05c - $sitCount05b

Write-Host "   Lab 05c Total SIT Instances: $sitCount05c" -ForegroundColor Cyan
Write-Host "   Lab 05b Total SIT Instances: $sitCount05b" -ForegroundColor Cyan

if ($diffSits -eq 0) {
    Write-Host "   ✅ SIT instance counts match exactly." -ForegroundColor Green
} else {
    Write-Host "   ❌ Variance: $diffSits instances" -ForegroundColor Red
}

# 3. SIT Type Breakdown
Write-Host "`n📊 3. SIT Type Breakdown" -ForegroundColor Magenta
Write-Host "==========================" -ForegroundColor Magenta

$group05c = $data05c | Group-Object SIT_Type | Sort-Object Name
$group05b = $data05b | Group-Object SIT_Type | Sort-Object Name

# Create a combined list of SIT types
$allSits = ($group05c.Name + $group05b.Name) | Select-Object -Unique | Sort-Object

$table = @()
foreach ($sit in $allSits) {
    $c = ($group05c | Where-Object Name -eq $sit).Count
    if (-not $c) { $c = 0 }
    
    $b = ($group05b | Where-Object Name -eq $sit).Count
    if (-not $b) { $b = 0 }
    
    $diff = $c - $b
    $match = if ($diff -eq 0) { "✅" } else { "❌" }
    
    $table += [PSCustomObject]@{
        "SIT Type" = $sit
        "Lab 05c" = $c
        "Lab 05b" = $b
        "Diff" = $diff
        "Match" = $match
    }
}

$table | Format-Table -AutoSize

Write-Host "`n🏁 Comparison Complete" -ForegroundColor Green
