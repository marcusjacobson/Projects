<#
.SYNOPSIS
    Adds users to the EDM_DataUploaders security group required for EDM data upload.

.DESCRIPTION
    This script creates the EDM_DataUploaders security group if it doesn't exist and adds
    specified users to it. This group membership is required for the EdmUploadAgent to
    successfully authorize and upload EDM data to Microsoft Purview.

.PARAMETER UserPrincipalName
    The User Principal Name (email) of the user to add to the EDM_DataUploaders group.
    If not specified, the current user will be added.

.EXAMPLE
    .\Add-EDMSecurityGroup.ps1
    
    Adds the current user to the EDM_DataUploaders group.

.EXAMPLE
    .\Add-EDMSecurityGroup.ps1 -UserPrincipalName "admin@contoso.com"
    
    Adds the specified user to the EDM_DataUploaders group.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-14
    Last Modified: 2025-11-14
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Azure AD PowerShell module (Microsoft.Graph or AzureAD)
    - Global Administrator or User Administrator role in Azure AD
    - Microsoft 365 or Azure AD Premium subscription
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Creates and configures EDM_DataUploaders security group for EDM upload permissions.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$UserPrincipalName
)

# =============================================================================
# Step 1: Module Check and Installation
# =============================================================================

Write-Host "🔍 Step 1: Module Check" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green

Write-Host "📋 Checking for Microsoft Graph PowerShell module..." -ForegroundColor Cyan

try {
    $graphModule = Get-Module -ListAvailable -Name Microsoft.Graph.Groups, Microsoft.Graph.Users
    
    if (-not $graphModule) {
        Write-Host "   ℹ️  Microsoft Graph module not found. Installing..." -ForegroundColor Yellow
        Install-Module Microsoft.Graph -Scope CurrentUser -Force -AllowClobber
        Write-Host "   ✅ Microsoft Graph module installed" -ForegroundColor Green
    } else {
        Write-Host "   ✅ Microsoft Graph module found" -ForegroundColor Green
    }
    
    Write-Host ""
    
} catch {
    Write-Host "   ❌ Module check failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Connect to Microsoft Graph
# =============================================================================

Write-Host "🔐 Step 2: Microsoft Graph Authentication" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

Write-Host "📋 Connecting to Microsoft Graph..." -ForegroundColor Cyan
Write-Host "   ℹ️  You will be prompted to sign in via browser" -ForegroundColor Yellow

try {
    # Connect with required permissions
    Connect-MgGraph -Scopes "Group.ReadWrite.All", "User.Read.All", "Directory.ReadWrite.All" -NoWelcome
    
    Write-Host "   ✅ Connected to Microsoft Graph" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host "   ❌ Authentication failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Get Current User
# =============================================================================

Write-Host "👤 Step 3: User Identification" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

try {
    if (-not $UserPrincipalName) {
        # Get current user context
        $context = Get-MgContext
        $UserPrincipalName = $context.Account
        Write-Host "📋 Using current user: $UserPrincipalName" -ForegroundColor Cyan
    } else {
        Write-Host "📋 Using specified user: $UserPrincipalName" -ForegroundColor Cyan
    }
    
    # Get user object
    $user = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'" -ErrorAction Stop
    
    if (-not $user) {
        throw "User not found: $UserPrincipalName"
    }
    
    Write-Host "   ✅ User found: $($user.DisplayName)" -ForegroundColor Green
    Write-Host "      ID: $($user.Id)" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host "   ❌ User lookup failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 4: Create or Get EDM_DataUploaders Group
# =============================================================================

Write-Host "👥 Step 4: Security Group Setup" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

Write-Host "📋 Checking for EDM_DataUploaders group..." -ForegroundColor Cyan

try {
    # Check if group exists
    $group = Get-MgGroup -Filter "displayName eq 'EDM_DataUploaders'" -ErrorAction SilentlyContinue
    
    if (-not $group) {
        Write-Host "   ℹ️  Group not found. Creating EDM_DataUploaders group..." -ForegroundColor Yellow
        
        $groupParams = @{
            DisplayName = "EDM_DataUploaders"
            Description = "Users authorized to upload Exact Data Match (EDM) sensitive data to Microsoft Purview"
            MailEnabled = $false
            MailNickname = "EDM_DataUploaders"
            SecurityEnabled = $true
        }
        
        $group = New-MgGroup -BodyParameter $groupParams
        Write-Host "   ✅ EDM_DataUploaders group created" -ForegroundColor Green
        
        # Wait for group creation to propagate
        Start-Sleep -Seconds 5
    } else {
        Write-Host "   ✅ EDM_DataUploaders group found" -ForegroundColor Green
    }
    
    Write-Host "      Group ID: $($group.Id)" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host "   ❌ Group setup failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 5: Add User to Group
# =============================================================================

Write-Host "➕ Step 5: Add User to Group" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

Write-Host "📋 Adding user to EDM_DataUploaders group..." -ForegroundColor Cyan

try {
    # Check if user is already a member
    $existingMember = Get-MgGroupMember -GroupId $group.Id -All | Where-Object { $_.Id -eq $user.Id }
    
    if ($existingMember) {
        Write-Host "   ℹ️  User is already a member of EDM_DataUploaders" -ForegroundColor Yellow
    } else {
        # Add user to group
        $memberParams = @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($user.Id)"
        }
        
        New-MgGroupMemberByRef -GroupId $group.Id -BodyParameter $memberParams
        
        Write-Host "   ✅ User added to EDM_DataUploaders group successfully" -ForegroundColor Green
    }
    
    Write-Host ""
    
} catch {
    Write-Host "   ❌ Failed to add user to group: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 6: Verify Membership
# =============================================================================

Write-Host "✅ Step 6: Verification" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green

Write-Host "📋 Verifying group membership..." -ForegroundColor Cyan

try {
    $members = Get-MgGroupMember -GroupId $group.Id -All
    
    Write-Host "   ✅ Current EDM_DataUploaders members:" -ForegroundColor Green
    
    foreach ($member in $members) {
        $memberUser = Get-MgUser -UserId $member.Id -ErrorAction SilentlyContinue
        if ($memberUser) {
            $isCurrent = if ($memberUser.Id -eq $user.Id) { " (YOU)" } else { "" }
            Write-Host "      • $($memberUser.DisplayName) ($($memberUser.UserPrincipalName))$isCurrent" -ForegroundColor White
        }
    }
    
    Write-Host ""
    
} catch {
    Write-Host "   ⚠️  Verification warning: $_" -ForegroundColor Yellow
    Write-Host ""
}

# =============================================================================
# Summary and Next Steps
# =============================================================================

Write-Host "🎉 EDM Security Group Configuration Complete!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "   • Group: EDM_DataUploaders" -ForegroundColor White
Write-Host "   • User: $($user.DisplayName) ($UserPrincipalName)" -ForegroundColor White
Write-Host "   • Status: Active" -ForegroundColor White
Write-Host ""
Write-Host "⏱️  Important: Wait 15-30 minutes for Azure AD group membership to propagate" -ForegroundColor Yellow
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Wait 15-30 minutes for group membership propagation" -ForegroundColor White
Write-Host "   2. Re-run: .\Upload-EDMData.ps1 -DatabasePath 'C:\PurviewLabs\Lab2-EDM-Testing\EmployeeDatabase.csv' -DataStoreName 'EmployeeDataStore'" -ForegroundColor White
Write-Host "   3. EdmUploadAgent authorization should now succeed" -ForegroundColor White
Write-Host ""

# Disconnect
Disconnect-MgGraph | Out-Null
