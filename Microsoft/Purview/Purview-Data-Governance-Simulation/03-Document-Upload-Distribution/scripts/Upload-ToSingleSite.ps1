<#
.SYNOPSIS
    Uploads documents from a local folder to a single SharePoint site.

.DESCRIPTION
    This script replicates the proven upload pattern.
    It connects to a SharePoint site and uploads all documents from a specified local folder.
    
    Key features:
    - Same session upload (connect + upload in one execution)
    - Simple Interactive authentication with ClientId
    - Proven pattern from working labs
    
.PARAMETER SiteUrl
    Full URL of the SharePoint site (e.g., "https://tenant.sharepoint.com/sites/HR-Simulation").

.PARAMETER SourceFolder
    Local folder path containing documents to upload.

.PARAMETER TargetLibrary
    Target document library name. Default: "Documents".

.EXAMPLE
    .\Upload-ToSingleSite.ps1 -SiteUrl "https://marcusjcloud.sharepoint.com/sites/HR-Simulation" -SourceFolder "..\..\02-Test-Data-Generation\scripts\generated-documents\HR"
    
.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$SourceFolder,
    
    [Parameter(Mandatory = $false)]
    [string]$TargetLibrary = "Shared Documents"
)

# =============================================================================
# Step 1: Validate Source Folder
# =============================================================================

Write-Host "`n📋 Step 1: Validate Source Folder" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

if (-not (Test-Path $SourceFolder)) {
    Write-Host "❌ Source folder not found: $SourceFolder" -ForegroundColor Red
    exit 1
}

$documents = Get-ChildItem -Path $SourceFolder -File -Recurse
$totalDocs = $documents.Count

Write-Host "✅ Found $totalDocs documents to upload" -ForegroundColor Green
Write-Host "   📁 Source: $SourceFolder" -ForegroundColor Cyan

if ($totalDocs -eq 0) {
    Write-Host "⚠️  No documents to upload" -ForegroundColor Yellow
    exit 0
}

# =============================================================================
# Step 2: Load Configuration for ClientId
# =============================================================================

Write-Host "`n📋 Step 2: Load Configuration" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent (Split-Path -Parent $scriptPath)
$configPath = Join-Path $projectRoot "global-config.json"

if (-not (Test-Path $configPath)) {
    Write-Host "❌ Configuration file not found: $configPath" -ForegroundColor Red
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
$appClientId = $config.Environment.PnPClientId

Write-Host "✅ Configuration loaded" -ForegroundColor Green
Write-Host "   🔧 Client ID: $appClientId" -ForegroundColor Cyan

# =============================================================================
# Step 3: Connect to SharePoint Site
# =============================================================================

Write-Host "`n📋 Step 3: Connect to SharePoint Site" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

try {
    Write-Host "🔐 Connecting to: $SiteUrl" -ForegroundColor Cyan
    Write-Host "   (Browser window will open for authentication)" -ForegroundColor Yellow
    
    # Use the exact pattern from working labs
    Connect-PnPOnline -Url $SiteUrl -Interactive -ClientId $appClientId
    
    Write-Host "✅ Connected to SharePoint successfully" -ForegroundColor Green
    
    # Verify connection
    $web = Get-PnPWeb
    Write-Host "   ✅ Site verified: $($web.Title)" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 4: Upload Documents
# =============================================================================

Write-Host "`n📋 Step 4: Upload Documents" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

# Get list of existing files in target library
Write-Host "🔍 Checking for existing files in target library..." -ForegroundColor Cyan
try {
    $existingFiles = Get-PnPFolderItem -FolderSiteRelativeUrl $TargetLibrary -ItemType File -ErrorAction SilentlyContinue
    $existingFileNames = @($existingFiles | ForEach-Object { $_.Name })
    Write-Host "   📊 Found $($existingFileNames.Count) existing files" -ForegroundColor Gray
} catch {
    Write-Host "   ⚠️  Could not retrieve existing files, will attempt all uploads" -ForegroundColor Yellow
    $existingFileNames = @()
}

$uploadStartTime = Get-Date
$successCount = 0
$failCount = 0
$skippedCount = 0
$currentDoc = 0

foreach ($doc in $documents) {
    $currentDoc++
    $progress = [Math]::Round(($currentDoc / $totalDocs) * 100, 1)
    
    Write-Host "📄 [$currentDoc/$totalDocs] ($progress%) Uploading: $($doc.Name)" -ForegroundColor Gray
    
    # Check if file already exists
    if ($existingFileNames -contains $doc.Name) {
        $skippedCount++
        Write-Host "   ⏭️  Already exists (skipped)" -ForegroundColor Yellow
        continue
    }
    
    try {
        # Upload file to target library
        Add-PnPFile -Path $doc.FullName -Folder $TargetLibrary -ErrorAction Stop | Out-Null
        $successCount++
        Write-Host "   ✅ Success" -ForegroundColor Green
    } catch {
        $failCount++
        Write-Host "   ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Small delay every 50 files to avoid throttling
    if ($currentDoc % 50 -eq 0) {
        Write-Host "   ⏳ Pausing 5 seconds (throttle protection)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }
}

$uploadEndTime = Get-Date
$duration = $uploadEndTime - $uploadStartTime

# =============================================================================
# Step 5: Upload Summary
# =============================================================================

Write-Host "`n📋 Step 5: Upload Summary" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

Write-Host "📊 Results:" -ForegroundColor Cyan
Write-Host "   • Total Documents: $totalDocs" -ForegroundColor Cyan
Write-Host "   • Successful: $successCount" -ForegroundColor Green
Write-Host "   • Skipped: $skippedCount" -ForegroundColor Yellow
Write-Host "   • Failed: $failCount" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Red" })
Write-Host "   • Success Rate: $([Math]::Round((($successCount + $skippedCount) / $totalDocs) * 100, 1))%" -ForegroundColor Cyan
Write-Host "   • Duration: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan

Disconnect-PnPOnline

if ($failCount -eq 0) {
    Write-Host "`n✅ All documents uploaded successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️  Upload completed with $failCount failures" -ForegroundColor Yellow
    exit 1
}
