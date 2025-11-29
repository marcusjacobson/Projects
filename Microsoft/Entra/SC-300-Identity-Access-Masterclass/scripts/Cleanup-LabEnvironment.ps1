<#
.SYNOPSIS
    Cleans up resources created during the SC-300 Masterclass labs.

.DESCRIPTION
    This script removes the test users, groups, and administrative units created
    during the simulation labs to return the tenant to a clean state.
    
    The script:
    1. Connects to Microsoft Graph.
    2. Removes specific test users (Alex, Bianca, Christie, David).
    3. Removes specific dynamic groups.
    4. Removes the "Paris Branch" Administrative Unit.

.PARAMETER Force
    Skips confirmation prompts.

.EXAMPLE
    .\Cleanup-LabEnvironment.ps1 -Force
    
    Removes all lab resources without prompting.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-05-20
    Last Modified: 2025-05-20
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft.Graph PowerShell module
    - Global Administrator role
    
    Script development orchestrated using GitHub Copilot.

.CLEANUP TARGETS
    - Users: Alex Wilber, Bianca Pisani, Christie Cline, David So
    - Groups: Dynamic-Sales-Team, Dynamic-Marketing-Team, Project-Alpha
    - Admin Units: Paris Branch
#>
#
# =============================================================================
# Cleanup-LabEnvironment.ps1
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# =============================================================================
# Step 1: Connect to Microsoft Graph
# =============================================================================

Write-Host "🔍 Step 1: Connect to Microsoft Graph" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

try {
    Write-Host "🚀 Connecting to Microsoft Graph..." -ForegroundColor Cyan
    Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All" -ErrorAction Stop
    Write-Host "   ✅ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Connection failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Remove Users
# =============================================================================

Write-Host "🔍 Step 2: Remove Users" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green

$targetUsers = @("Alex Wilber", "Bianca Pisani", "Christie Cline", "David So")

foreach ($userName in $targetUsers) {
    try {
        $user = Get-MgUser -Filter "DisplayName eq '$userName'" -ErrorAction SilentlyContinue
        if ($user) {
            Write-Host "📋 Removing user: $userName" -ForegroundColor Cyan
            Remove-MgUser -UserId $user.Id -ErrorAction Stop
            Write-Host "   ✅ Removed user: $userName" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ User not found: $userName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove user '$userName': $_" -ForegroundColor Red
    }
}

# =============================================================================
# Step 3: Remove Groups
# =============================================================================

Write-Host "🔍 Step 3: Remove Groups" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

$targetGroups = @("Dynamic-Sales-Team", "Dynamic-Marketing-Team", "Project-Alpha")

foreach ($groupName in $targetGroups) {
    try {
        $group = Get-MgGroup -Filter "DisplayName eq '$groupName'" -ErrorAction SilentlyContinue
        if ($group) {
            Write-Host "📋 Removing group: $groupName" -ForegroundColor Cyan
            Remove-MgGroup -GroupId $group.Id -ErrorAction Stop
            Write-Host "   ✅ Removed group: $groupName" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Group not found: $groupName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove group '$groupName': $_" -ForegroundColor Red
    }
}

# =============================================================================
# Step 4: Remove Administrative Units
# =============================================================================

Write-Host "🔍 Step 4: Remove Administrative Units" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$targetAUs = @("Paris Branch")

foreach ($auName in $targetAUs) {
    try {
        $au = Get-MgDirectoryAdministrativeUnit -Filter "DisplayName eq '$auName'" -ErrorAction SilentlyContinue
        if ($au) {
            Write-Host "📋 Removing Admin Unit: $auName" -ForegroundColor Cyan
            Remove-MgDirectoryAdministrativeUnit -AdministrativeUnitId $au.Id -ErrorAction Stop
            Write-Host "   ✅ Removed Admin Unit: $auName" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Admin Unit not found: $auName" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Failed to remove Admin Unit '$auName': $_" -ForegroundColor Red
    }
}

Write-Host "✅ Cleanup completed" -ForegroundColor Blue
