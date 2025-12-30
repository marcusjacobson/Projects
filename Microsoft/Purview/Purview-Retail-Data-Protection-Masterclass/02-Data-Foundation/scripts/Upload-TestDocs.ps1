<#
.SYNOPSIS
    Uploads all test data files to Retail Operations SharePoint site.

.DESCRIPTION
    This script uploads all generated test files from data-templates directory
    to the SharePoint site for DLP testing and classification. Includes files
    with single SITs, multiple SITs, and clean control files for comprehensive
    testing scenarios.
    
    Uses PnP.PowerShell with service principal authentication (certificate-based)
    for automated, non-interactive deployment.

.EXAMPLE
    .\Upload-TestDocs.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 4.0.0
    Created: 2025-12-29
    Last Modified: 2025-12-30
    
    Requirements:
    - Run Generate-TestData.ps1 first to create test files
    - Service principal with SharePoint permissions configured
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param()

# =============================================================================
# Step 1: Load Configuration
# =============================================================================

Write-Host "`n🔍 Step 1: Load Configuration" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent (Split-Path -Parent $scriptPath)
$configPath = Join-Path $projectRoot "templates\global-config.json"

if (-not (Test-Path $configPath)) {
    Write-Host "❌ Configuration file not found: $configPath" -ForegroundColor Red
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
Write-Host "✅ Configuration loaded" -ForegroundColor Green

# =============================================================================
# Step 2: Validate Source Files
# =============================================================================

Write-Host "`n🔍 Step 2: Validate Source Files" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

$dataTemplatesDir = Join-Path (Split-Path -Parent $scriptPath) "data-templates"

if (-not (Test-Path $dataTemplatesDir)) {
    Write-Host "❌ data-templates directory not found: $dataTemplatesDir" -ForegroundColor Red
    Write-Host "   Run Generate-TestData.ps1 first to create test files" -ForegroundColor Yellow
    exit 1
}

$sourceFiles = Get-ChildItem -Path $dataTemplatesDir -File
if ($sourceFiles.Count -eq 0) {
    Write-Host "❌ No test files found in data-templates directory" -ForegroundColor Red
    Write-Host "   Run Generate-TestData.ps1 first to create test files" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found $($sourceFiles.Count) test files to upload" -ForegroundColor Green
foreach ($file in $sourceFiles) {
    $fileSizeMB = [math]::Round($file.Length / 1MB, 2)
    if ($fileSizeMB -eq 0) { $fileSizeMB = [math]::Round($file.Length / 1KB, 2); $unit = "KB" } else { $unit = "MB" }
    Write-Host "   📄 $($file.Name) ($fileSizeMB $unit)" -ForegroundColor Cyan
}

# =============================================================================
# Step 3: Connect to SharePoint
# =============================================================================

Write-Host "`n🔍 Step 3: Connect to SharePoint" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

$tenantUrl = $config.sharePointRootUrl.TrimEnd('/')
$siteUrl = "$tenantUrl/sites/$($config.sharePointSite.name)"
$tenantId = $config.tenantId

# Get app registration details from service principal config
$appId = "497be3e7-9fe4-444c-beaa-3d486889d1c3"  # From global-config servicePrincipal

# Get certificate thumbprint from local certificate store
Write-Host "   🔍 Looking for certificate in local store..." -ForegroundColor Cyan
$cert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=PurviewAutomationCert" } | Sort-Object NotAfter -Descending | Select-Object -First 1

if (-not $cert) {
    Write-Host "❌ Certificate not found in certificate store" -ForegroundColor Red
    Write-Host "   Expected: CN=PurviewAutomationCert" -ForegroundColor Yellow
    exit 1
}

Write-Host "   ✅ Found certificate (expires: $($cert.NotAfter))" -ForegroundColor Green
Write-Host "   🔐 Connecting with service principal..." -ForegroundColor Cyan

try {
    try { Disconnect-PnPOnline } catch { }
    Connect-PnPOnline -Url $siteUrl -ClientId $appId -Thumbprint $cert.Thumbprint -Tenant $tenantId -ErrorAction Stop
    Write-Host "   ✅ Connected to SharePoint with service principal" -ForegroundColor Green
    
    $web = Get-PnPWeb
    Write-Host "   ✅ Site validated: $($web.Title)" -ForegroundColor Green
} catch {
    Write-Host "❌ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 4: Upload Files to SharePoint
# =============================================================================

$libraryName = "Shared Documents"
$uploadedCount = 0
$skippedCount = 0
$failedCount = 0

foreach ($file in $sourceFiles) {
    try {
        # Check if file already exists
        $existingFile = Get-PnPFile -Url "$libraryName/$($file.Name)" -AsListItem -ErrorAction SilentlyContinue
        
        if ($existingFile) {
            Write-Host "⚠️  $($file.Name) - Already exists, skipping" -ForegroundColor Yellow
            $skippedCount++
        } else {
            Write-Host "📤 Uploading $($file.Name)..." -ForegroundColor Cyan
            
            Add-PnPFile `
                -Path $file.FullName `
                -Folder $libraryName `
                -ErrorAction Stop | Out-Null
            
            Write-Host "   ✅ Uploaded successfully" -ForegroundColor Green
            $uploadedCount++
        }
    } catch {
        Write-Host "   ❌ Upload failed: $($_.Exception.Message)" -ForegroundColor Red
        $failedCount++
    }
}

# =============================================================================
# Step 5: Summary
# =============================================================================

Write-Host "`n📊 Upload Summary" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green
Write-Host "   Total Files:    $($sourceFiles.Count)" -ForegroundColor White
Write-Host "   ✅ Uploaded:    $uploadedCount" -ForegroundColor Green
Write-Host "   ⚠️  Skipped:    $skippedCount" -ForegroundColor Yellow
if ($failedCount -gt 0) {
    Write-Host "   ❌ Failed:      $failedCount" -ForegroundColor Red
}

Write-Host "`n📂 SharePoint Location:" -ForegroundColor Cyan
Write-Host "   Site: $siteUrl" -ForegroundColor White
Write-Host "   Library: $libraryName" -ForegroundColor White

Write-Host "`n💡 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Navigate to SharePoint site to view uploaded files" -ForegroundColor White
Write-Host "   2. Configure DLP policies to detect sensitive information" -ForegroundColor White
Write-Host "   3. Test auto-labeling on files with different SIT combinations" -ForegroundColor White
Write-Host "   4. Verify classification in Content Explorer" -ForegroundColor White

Write-Host "`n✅ Script complete" -ForegroundColor Green
Disconnect-PnPOnline
