<#
.SYNOPSIS
    Bulk creates users in Microsoft Entra ID from a CSV file for lab simulations.

.DESCRIPTION
    This script automates the creation of multiple user accounts in a Microsoft Entra ID tenant.
    It is designed for the SC-300 Masterclass to populate the environment with test users
    required for Identity Governance, Conditional Access, and RBAC labs.
    
    The script:
    1. Connects to Microsoft Graph.
    2. Imports users from a specified CSV file.
    3. Creates users with specified attributes (Department, JobTitle).
    4. Assigns initial passwords.

.PARAMETER CsvPath
    The path to the CSV file containing user data. Defaults to "users.csv" in the current directory.

.EXAMPLE
    .\New-BulkUsers.ps1 -CsvPath "C:\Labs\users.csv"
    
    Creates users defined in the specified CSV file.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-05-20
    Last Modified: 2025-05-20
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft.Graph PowerShell module
    - User Administrator or Global Administrator role
    
    Script development orchestrated using GitHub Copilot.

.CONFIGURATION ITEMS
    - User Attributes: DisplayName, UserPrincipalName, Department, JobTitle
    - Password Profile: ForceChangePasswordNextSignIn = $true
#>
#
# =============================================================================
# New-BulkUsers.ps1
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$CsvPath = ".\users.csv"
)

# =============================================================================
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔍 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

try {
    Write-Host "📋 Checking for Microsoft.Graph module..." -ForegroundColor Cyan
    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
        throw "Microsoft.Graph.Users module is not installed. Please run 'Install-Module Microsoft.Graph'."
    }
    Write-Host "   ✅ Microsoft.Graph module found" -ForegroundColor Green

    Write-Host "📋 Checking CSV file existence..." -ForegroundColor Cyan
    if (-not (Test-Path $CsvPath)) {
        throw "CSV file not found at path: $CsvPath"
    }
    Write-Host "   ✅ CSV file found" -ForegroundColor Green

} catch {
    Write-Host "   ❌ Validation failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 2: Connect to Microsoft Graph
# =============================================================================

Write-Host "🔍 Step 2: Connect to Microsoft Graph" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

try {
    Write-Host "🚀 Connecting to Microsoft Graph..." -ForegroundColor Cyan
    Connect-MgGraph -Scopes "User.ReadWrite.All" -ErrorAction Stop
    Write-Host "   ✅ Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Connection failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Process Users
# =============================================================================

Write-Host "🔍 Step 3: Process Users" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

try {
    $users = Import-Csv $CsvPath
    
    foreach ($user in $users) {
        Write-Host "📋 Processing user: $($user.DisplayName)" -ForegroundColor Cyan
        
        $userParams = @{
            AccountEnabled = $true
            DisplayName = $user.DisplayName
            MailNickname = $user.UserPrincipalName.Split("@")[0]
            UserPrincipalName = $user.UserPrincipalName
            Department = $user.Department
            JobTitle = $user.JobTitle
            PasswordProfile = @{
                ForceChangePasswordNextSignIn = $true
                Password = $user.Password
            }
        }

        try {
            New-MgUser -BodyParameter $userParams -ErrorAction Stop | Out-Null
            Write-Host "   ✅ Created user: $($user.DisplayName)" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️ Failed to create user '$($user.DisplayName)': $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ❌ Processing failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Bulk user creation completed" -ForegroundColor Blue
