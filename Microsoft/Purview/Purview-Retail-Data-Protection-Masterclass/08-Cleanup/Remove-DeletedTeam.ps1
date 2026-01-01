<#
.SYNOPSIS
    Permanently deletes a soft-deleted Microsoft Team from the recycle bin.

.DESCRIPTION
    This script connects to Microsoft Graph and permanently purges a team that was
    previously soft-deleted from the deleted items container (30-day recycle bin).

.PARAMETER TeamName
    The display name of the team to permanently delete.

.EXAMPLE
    .\Remove-DeletedTeam.ps1 -TeamName "Retail Operations Testing"

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-30
    
    Requirements:
    - Microsoft Graph PowerShell SDK installed
    - Azure CLI installed
    - Proper authentication configured (service principal + certificate)
    - Directory.ReadWrite.All permission
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$TeamName = "Retail Operations Testing",
    
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "..\..\scripts\Connect-PurviewGraph.ps1"
)

Write-Host "🗑️ Permanently Purging Deleted Team" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
Write-Host ""

# Load helper script using full path resolution
$helperScript = Join-Path $PSScriptRoot $ConfigPath

if (Test-Path $helperScript) {
    Write-Host "🔐 Authenticating to Microsoft Graph..." -ForegroundColor Cyan
    . $helperScript
} else {
    Write-Host "❌ Helper script not found: $helperScript" -ForegroundColor Red
    Write-Host "   Please ensure Connect-PurviewGraph.ps1 exists in 00-Prerequisites\scripts\" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🔍 Searching deleted items for team: $TeamName" -ForegroundColor Cyan

# Get deleted groups and check for Teams
try {
    # Use Get-MgDirectoryDeletedItemAsGroup to get deleted groups
    $deletedGroups = Get-MgDirectoryDeletedItemAsGroup -All
    
    Write-Host "   📋 Found $($deletedGroups.Count) deleted group(s)" -ForegroundColor Gray
    
    # Match by display name (contains partial match for flexibility)
    $deletedTeam = $deletedGroups | Where-Object {
        $_.DisplayName -like "*$TeamName*"
    } | Select-Object -First 1
    
    if ($deletedTeam) {
        Write-Host "   ✅ Found deleted item: $($deletedTeam.DisplayName)" -ForegroundColor Green
        Write-Host "      Group ID: $($deletedTeam.Id)" -ForegroundColor Cyan
        Write-Host "      Mail: $($deletedTeam.Mail)" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "🗑️ Permanently deleting from recycle bin..." -ForegroundColor Yellow
        
        # Permanently delete using PowerShell cmdlet
        try {
            Remove-MgDirectoryDeletedItem -DirectoryObjectId $deletedTeam.Id -Confirm:$false
            Write-Host "   ✅ Team PERMANENTLY DELETED from deleted items!" -ForegroundColor Green
            Write-Host ""
            Write-Host "✅ Ready for fresh creation test!" -ForegroundColor Green
            Write-Host "   Run: .\New-TeamsEnvironment.ps1" -ForegroundColor Cyan
        } catch {
            Write-Host "   ❌ Failed to permanently delete: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "💡 Alternative: Wait for automatic expiration (30 days) or restore then delete" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⚠️ No deleted items matching '$TeamName' found" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📋 All deleted groups:" -ForegroundColor Cyan
        
        if ($deletedGroups.Count -gt 0) {
            foreach ($group in $deletedGroups) {
                Write-Host "   - $($group.DisplayName) (ID: $($group.Id))" -ForegroundColor Gray
            }
        } else {
            Write-Host "   (No deleted groups found)" -ForegroundColor Gray
        }
        
        Write-Host ""
        Write-Host "✅ Ready for fresh creation test!" -ForegroundColor Green
        Write-Host "   Run: .\New-TeamsEnvironment.ps1" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   ❌ Error accessing deleted items: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
