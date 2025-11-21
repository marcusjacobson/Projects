<#
.SYNOPSIS
    Orchestrates upload of all generated documents to SharePoint sites.

.DESCRIPTION
    Runs the single-site upload script multiple times, once per site, using the
    proven pattern from Purview-Classification-Lifecycle-Labs.
    
.EXAMPLE
    .\Upload-AllDocuments.ps1
    
.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    
    Script development orchestrated using GitHub Copilot.
#>

# =============================================================================
# Upload Orchestration Using Proven Lab Pattern
# =============================================================================

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$uploaderScript = Join-Path $scriptPath "Upload-ToSingleSite.ps1"
$documentsBasePath = Join-Path (Split-Path -Parent $scriptPath) "..\02-Test-Data-Generation\scripts\generated-documents"

# =============================================================================
# Phase 1: Upload HR Documents
# =============================================================================

Write-Host "`n📋 Phase 1: Upload HR Documents" -ForegroundColor Magenta
Write-Host "===============================" -ForegroundColor Magenta

$hrSource = Join-Path $documentsBasePath "HR"
if (Test-Path $hrSource) {
    Write-Host "🚀 Uploading HR documents to HR-Simulation..." -ForegroundColor Blue
    
    & $uploaderScript `
        -SiteUrl "https://marcusjcloud.sharepoint.com/sites/HR-Simulation" `
        -SourceFolder $hrSource
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Phase 1 completed successfully`n" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Phase 1 completed with errors`n" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  HR documents folder not found: $hrSource`n" -ForegroundColor Yellow
}

# =============================================================================
# Phase 2: Upload Financial Documents
# =============================================================================

Write-Host "`n📋 Phase 2: Upload Financial Documents" -ForegroundColor Magenta
Write-Host "======================================" -ForegroundColor Magenta

$financialSource = Join-Path $documentsBasePath "Finance"
if (Test-Path $financialSource) {
    Write-Host "🚀 Uploading Financial documents to Finance-Simulation..." -ForegroundColor Blue
    
    & $uploaderScript `
        -SiteUrl "https://marcusjcloud.sharepoint.com/sites/Finance-Simulation" `
        -SourceFolder $financialSource
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Phase 2 completed successfully`n" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Phase 2 completed with errors`n" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Financial documents folder not found: $financialSource`n" -ForegroundColor Yellow
}

# =============================================================================
# Phase 3: Upload Identity Documents
# =============================================================================

Write-Host "`n📋 Phase 3: Upload Identity Documents" -ForegroundColor Magenta
Write-Host "=====================================" -ForegroundColor Magenta

$identitySource = Join-Path $documentsBasePath "Identity"
if (Test-Path $identitySource) {
    Write-Host "🚀 Uploading Identity documents to Legal-Simulation..." -ForegroundColor Blue
    
    & $uploaderScript `
        -SiteUrl "https://marcusjcloud.sharepoint.com/sites/Legal-Simulation" `
        -SourceFolder $identitySource
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Phase 3 completed successfully`n" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Phase 3 completed with errors`n" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Identity documents folder not found: $identitySource`n" -ForegroundColor Yellow
}

# =============================================================================
# Phase 4: Upload Mixed Documents (Optional)
# =============================================================================

Write-Host "`n📋 Phase 4: Upload Mixed Documents (Optional)" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta

$mixedSource = Join-Path $documentsBasePath "Mixed"
if (Test-Path $mixedSource) {
    Write-Host "📋 Mixed documents can be uploaded to any remaining site:" -ForegroundColor Cyan
    Write-Host "   • Marketing-Simulation" -ForegroundColor Gray
    Write-Host "   • IT-Simulation" -ForegroundColor Gray
    Write-Host "`n💡 Run manually:" -ForegroundColor Yellow
    Write-Host '   .\Upload-ToSingleSite.ps1 -SiteUrl "https://marcusjcloud.sharepoint.com/sites/Marketing-Simulation" -SourceFolder "..\..\02-Test-Data-Generation\scripts\generated-documents\Mixed"' -ForegroundColor Gray
} else {
    Write-Host "⚠️  Mixed documents folder not found: $mixedSource" -ForegroundColor Yellow
}

# =============================================================================
# Upload Summary
# =============================================================================

Write-Host "`n🎯 Upload Orchestration Complete" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta

Write-Host "✅ Primary document categories uploaded:" -ForegroundColor Green
Write-Host "   • HR Documents → HR-Simulation" -ForegroundColor Cyan
Write-Host "   • Financial Documents → Finance-Simulation" -ForegroundColor Cyan
Write-Host "   • Identity Documents → Legal-Simulation" -ForegroundColor Cyan

Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Check SharePoint sites to verify uploads" -ForegroundColor Gray
Write-Host "   2. Upload Mixed documents if needed (see Phase 4 above)" -ForegroundColor Gray
Write-Host "   3. Run .\Test-UploadValidation.ps1 to verify" -ForegroundColor Gray

Write-Host "`n✅ Upload orchestration completed!`n" -ForegroundColor Green
