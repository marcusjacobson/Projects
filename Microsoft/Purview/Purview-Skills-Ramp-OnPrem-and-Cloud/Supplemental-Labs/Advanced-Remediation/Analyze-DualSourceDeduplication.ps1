# Get computer name for UNC paths
$computerName = $env:COMPUTERNAME

# Define on-prem source
$onPremPath = "\\$computerName\Projects"

# Get cloud storage path with auto-conversion from URL
Write-Host "`n📋 Azure Files Cloud Storage Path:" -ForegroundColor Yellow
Write-Host "   Finding your URL in Azure Portal:" -ForegroundColor Cyan
Write-Host "   1. Navigate to: Storage Account → File shares → [your-share-name]" -ForegroundColor White
Write-Host "   2. Copy the 'URL' field (e.g., https://storageaccount.file.core.windows.net/sharename)" -ForegroundColor White
Write-Host "   3. Paste it below - the script will automatically convert it to UNC format" -ForegroundColor White
Write-Host ""
Write-Host "   💡 Tip: You can paste either the HTTPS URL or UNC path - both work!" -ForegroundColor Gray
Write-Host ""

$cloudPath = Read-Host "Enter Azure Files URL or UNC path"

# Automatically convert HTTPS URL to UNC path format
if ($cloudPath -match '^https?://') {
    Write-Host ""
    Write-Host "   🔧 Auto-converting Azure Files URL to UNC format..." -ForegroundColor Yellow
    
    # Convert URL to UNC path
    $originalUrl = $cloudPath
    $cloudPath = $cloudPath -replace '^https?://', '\\' -replace '/', '\'
    
    Write-Host "   Original URL:  $originalUrl" -ForegroundColor Gray
    Write-Host "   Converted UNC: $cloudPath" -ForegroundColor Green
    Write-Host "   ✅ Using converted UNC path for cloud storage access`n" -ForegroundColor Cyan
}

# Get file inventories from both sources
Write-Host "Scanning on-premises files..." -ForegroundColor Cyan
$onPremFiles = Get-ChildItem -Path $onPremPath -Recurse -File -ErrorAction SilentlyContinue |
    Select-Object Name, Length, LastWriteTime, FullName

Write-Host "Scanning cloud storage files..." -ForegroundColor Cyan
$cloudFiles = Get-ChildItem -Path $cloudPath -Recurse -File -ErrorAction SilentlyContinue |
    Select-Object Name, Length, LastWriteTime, FullName

# Find duplicates by name and size
$duplicates = @()

foreach ($onPremFile in $onPremFiles) {
    $match = $cloudFiles | Where-Object {
        $_.Name -eq $onPremFile.Name -and
        $_.Length -eq $onPremFile.Length
    } | Select-Object -First 1
    
    if ($match) {
        $duplicates += [PSCustomObject]@{
            FileName = $onPremFile.Name
            OnPremPath = $onPremFile.FullName
            CloudPath = $match.FullName
            SizeMB = [math]::Round($onPremFile.Length / 1MB, 2)
            OnPremLastModified = $onPremFile.LastWriteTime
            CloudLastModified = $match.LastWriteTime
            Recommendation = if ($match.LastWriteTime -gt $onPremFile.LastWriteTime) {
                'Delete on-prem (cloud version newer)'
            } else {
                'Verify before deletion'
            }
        }
    }
}

# Summary
Write-Host "`n========== DUAL-SOURCE ANALYSIS ==========" -ForegroundColor Cyan
Write-Host "On-Prem Files: $($onPremFiles.Count)" -ForegroundColor Yellow
Write-Host "Cloud Files: $($cloudFiles.Count)" -ForegroundColor Yellow
Write-Host "Duplicates Found: $($duplicates.Count)" -ForegroundColor Green
Write-Host "Potential Storage Savings: $(($duplicates | Measure-Object -Property SizeMB -Sum).Sum) MB`n" -ForegroundColor Green

# Export for review
$duplicates | Export-Csv "C:\PurviewLab\Duplicates.csv" -NoTypeInformation

# Safe deletion of on-prem duplicates
Write-Host "Files safe to delete from on-premises (exist in cloud storage):" -ForegroundColor Yellow
$safeDeletions = $duplicates | Where-Object {$_.Recommendation -eq 'Delete on-prem (cloud version newer)'}
$safeDeletions | Select-Object FileName, SizeMB, OnPremPath | Format-Table -AutoSize

# Optional: Execute deletion (uncomment to run)
<#
foreach ($duplicate in $safeDeletions) {
    try {
        Remove-Item -Path $duplicate.OnPremPath -Force -Verbose
        Write-Host "✅ Deleted: $($duplicate.FileName)" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to delete: $($duplicate.OnPremPath) - $_"
    }
}
#>

# Verification Step: Confirm files are deleted (if deletion was executed)
Write-Host "`n========== DELETION VERIFICATION ==========" -ForegroundColor Magenta
Write-Host "Verifying deletion results...`n" -ForegroundColor Cyan

$deletionResults = @{
    Deleted = 0
    StillExists = 0
    CloudCopiesVerified = 0
}

foreach ($duplicate in $safeDeletions) {
    $onPremPath = $duplicate.OnPremPath
    $cloudPath = $duplicate.CloudPath
    
    # Check if on-prem file still exists
    if (Test-Path $onPremPath) {
        Write-Host "⚠️  On-prem file still exists: $($duplicate.FileName)" -ForegroundColor Yellow
        $deletionResults.StillExists++
    } else {
        Write-Host "✅ Confirmed deleted from on-prem: $($duplicate.FileName)" -ForegroundColor Green
        $deletionResults.Deleted++
    }
    
    # Verify cloud copy exists
    if (Test-Path $cloudPath) {
        Write-Host "   ✅ Cloud copy verified: $cloudPath" -ForegroundColor Gray
        $deletionResults.CloudCopiesVerified++
    } else {
        Write-Host "   ⚠️  WARNING: Cloud copy not found: $cloudPath" -ForegroundColor Red
    }
}

Write-Host "`n========== VERIFICATION SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Files Successfully Deleted from On-Prem: $($deletionResults.Deleted)" -ForegroundColor Green
Write-Host "Files Still Exist On-Prem: $($deletionResults.StillExists)" -ForegroundColor $(if ($deletionResults.StillExists -gt 0) { 'Yellow' } else { 'Green' })
Write-Host "Cloud Copies Verified: $($deletionResults.CloudCopiesVerified)" -ForegroundColor Cyan

if ($deletionResults.StillExists -eq 0 -and $deletionResults.Deleted -gt 0) {
    Write-Host "`n✅ All duplicates deleted successfully from on-premises!" -ForegroundColor Green
    Write-Host "   Cloud storage remains intact with $($deletionResults.CloudCopiesVerified) files preserved." -ForegroundColor Cyan
} elseif ($deletionResults.Deleted -eq 0) {
    Write-Host "`n💡 No files were deleted (deletion code is commented out)." -ForegroundColor Gray
    Write-Host "   Uncomment the deletion block above to execute deletion." -ForegroundColor Gray
} else {
    Write-Host "`n⚠️  Some files were not deleted. Review errors above." -ForegroundColor Yellow
}

if ($deletionResults.CloudCopiesVerified -ne $safeDeletions.Count) {
    Write-Host "`n⚠️  WARNING: Some cloud copies are missing! Do NOT delete on-prem files without verified cloud backups." -ForegroundColor Red
}
