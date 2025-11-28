<#
.SYNOPSIS
    Automatically removes duplicate MCP server tools from VS Code settings.

.DESCRIPTION
    This script identifies and disables duplicate MCP server tools in your
    VS Code user settings. It preserves the primary instance of each tool
    and disables duplicates (typically those ending with '2' or marked as
    experimental duplicates).

.PARAMETER BackupSettings
    Create a backup of settings.json before making changes.

.PARAMETER WhatIf
    Preview changes without modifying settings.

.EXAMPLE
    .\Remove-DuplicateMCPTools.ps1 -BackupSettings
    
    Remove duplicates with a backup created first.

.EXAMPLE
    .\Remove-DuplicateMCPTools.ps1 -WhatIf
    
    Preview what would be changed without modifying settings.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-11
    
    Script development orchestrated using GitHub Copilot.

.UTILITY OPERATIONS
    - VS Code Settings Management
    - JSON Configuration Parsing
    - Backup Creation
    - Tool Disabling Logic
    - Change Reporting
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$BackupSettings,
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

# =============================================================================
# Configuration
# =============================================================================

$settingsPath = Join-Path $env:APPDATA "Code\User\settings.json"

# Known duplicate tool patterns to disable
$duplicateTools = @(
    # Microsoft Documentation duplicates (keep primary, disable *doc2*)
    "mcp_microsoft_doc2_microsoft_docs_search",
    "mcp_microsoft_doc2_microsoft_code_sample_search",
    "mcp_microsoft_doc2_microsoft_docs_fetch",
    
    # Bicep experimental duplicates (if not actively using)
    "mcp_bicep_experim_get_az_resource_type_schema",
    "mcp_bicep_experim_list_az_resource_types_for_provider",
    "mcp_bicep_experim_get_bicep_best_practices"
)

# Tool categories to disable (from earlier analysis)
$toolCategoriesToDisable = @(
    "activate_notebook_management_tools",
    "activate_git_tools_issue_management",
    "activate_git_tools_pull_requests",
    "activate_git_tools_workspace_management",
    "activate_git_tools_file_management"
)

# =============================================================================
# Main Processing
# =============================================================================

Write-Host "🔍 MCP Duplicate Tool Removal Utility" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Verify settings file exists
if (-not (Test-Path $settingsPath)) {
    Write-Host "❌ VS Code settings file not found: $settingsPath" -ForegroundColor Red
    exit 1
}

# Create backup if requested
if ($BackupSettings) {
    $backupPath = "$settingsPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "💾 Creating backup: $backupPath" -ForegroundColor Yellow
    Copy-Item $settingsPath $backupPath
    Write-Host "✅ Backup created successfully" -ForegroundColor Green
    Write-Host ""
}

# Read current settings
Write-Host "📄 Reading current VS Code settings..." -ForegroundColor Cyan
try {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
}
catch {
    Write-Host "❌ Failed to parse settings.json: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Initialize github.copilot.chat.tools.enabled if it doesn't exist
if (-not $settings.'github.copilot.chat.tools.enabled') {
    $settings | Add-Member -NotePropertyName 'github.copilot.chat.tools.enabled' -NotePropertyValue ([PSCustomObject]@{}) -Force
    Write-Host "✅ Initialized github.copilot.chat.tools.enabled section" -ForegroundColor Green
}

# Track changes
$changesCount = 0
$disabledTools = @()

Write-Host ""
Write-Host "🔧 Processing duplicate tools..." -ForegroundColor Cyan
Write-Host ""

# Disable duplicate individual tools
foreach ($toolName in $duplicateTools) {
    Write-Host "   🔍 Checking: $toolName" -ForegroundColor White
    
    if ($WhatIf) {
        Write-Host "   ⚠️  Would disable: $toolName" -ForegroundColor Yellow
        $changesCount++
        $disabledTools += $toolName
    }
    else {
        # Add property to disable the tool
        $settings.'github.copilot.chat.tools.enabled' | Add-Member -NotePropertyName $toolName -NotePropertyValue $false -Force
        Write-Host "   ✅ Disabled: $toolName" -ForegroundColor Green
        $changesCount++
        $disabledTools += $toolName
    }
}

Write-Host ""
Write-Host "🗂️  Processing tool categories..." -ForegroundColor Cyan
Write-Host ""

# Disable unnecessary tool categories
foreach ($category in $toolCategoriesToDisable) {
    Write-Host "   🔍 Checking category: $category" -ForegroundColor White
    
    if ($WhatIf) {
        Write-Host "   ⚠️  Would disable category: $category" -ForegroundColor Yellow
        $changesCount++
        $disabledTools += $category
    }
    else {
        # Add property to disable the category
        $settings.'github.copilot.chat.tools.enabled' | Add-Member -NotePropertyName $category -NotePropertyValue $false -Force
        Write-Host "   ✅ Disabled category: $category" -ForegroundColor Green
        $changesCount++
        $disabledTools += $category
    }
}

# Save changes if not in WhatIf mode
if (-not $WhatIf -and $changesCount -gt 0) {
    Write-Host ""
    Write-Host "💾 Saving changes to settings.json..." -ForegroundColor Cyan
    
    try {
        $settings | ConvertTo-Json -Depth 100 | Set-Content $settingsPath -Encoding UTF8
        Write-Host "✅ Settings saved successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to save settings: $($_.Exception.Message)" -ForegroundColor Red
        
        # Restore from backup if it exists
        if ($BackupSettings -and (Test-Path $backupPath)) {
            Write-Host "🔄 Restoring from backup..." -ForegroundColor Yellow
            Copy-Item $backupPath $settingsPath -Force
            Write-Host "✅ Settings restored from backup" -ForegroundColor Green
        }
        
        exit 1
    }
}

# Summary
Write-Host ""
Write-Host "📊 Summary" -ForegroundColor Cyan
Write-Host "==========" -ForegroundColor Cyan
Write-Host "   Total changes: $changesCount" -ForegroundColor White

if ($WhatIf) {
    Write-Host "   Mode: Preview only (no changes made)" -ForegroundColor Yellow
}
else {
    Write-Host "   Mode: Changes applied" -ForegroundColor Green
}

Write-Host ""
Write-Host "📋 Disabled Tools/Categories:" -ForegroundColor Cyan
foreach ($tool in $disabledTools) {
    Write-Host "   • $tool" -ForegroundColor White
}

Write-Host ""
Write-Host "🔄 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Restart VS Code to apply changes" -ForegroundColor White
Write-Host "   2. Open GitHub Copilot chat to verify reduced tool count" -ForegroundColor White
Write-Host "   3. To re-enable a tool, edit settings.json and set it to 'true'" -ForegroundColor White

if ($BackupSettings) {
    Write-Host ""
    Write-Host "💾 Backup Location:" -ForegroundColor Cyan
    Write-Host "   $backupPath" -ForegroundColor White
}

Write-Host ""
Write-Host "✅ Operation completed successfully!" -ForegroundColor Green
