<#
.SYNOPSIS
    Creates Emergency Access (Break Glass) accounts.

.DESCRIPTION
    Creates two cloud-only accounts with the Global Administrator role.
    These accounts are critical for tenant recovery if Conditional Access misconfiguration occurs.
    Naming convention: ADM-BG-01, ADM-BG-02.

.EXAMPLE
    .\Deploy-BreakGlassAccounts.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 01-Identity-Foundation
#>

[CmdletBinding()]
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    $Domain = (Get-MgDomain | Where-Object { $_.IsInitial }).Id
    # Generate a complex password (in reality, this should be 16+ chars, random)
    $PasswordProfile = @{
        Password = "Emergency!Access!2025!" 
        ForceChangePasswordNextSignIn = $false # BG accounts usually don't expire/change often
    }

    $BGAccounts = @("ADM-BG-01", "ADM-BG-02")
    
    # Get Global Admin Role
    $roleName = "Global Administrator"
    $role = Get-MgDirectoryRole | Where-Object { $_.DisplayName -eq $roleName }
    if (-not $role) {
        # Activate the role template if it doesn't exist (common in new tenants)
        $roleTemplate = Get-MgDirectoryRoleTemplate | Where-Object { $_.DisplayName -eq $roleName }
        $role = New-MgDirectoryRole -RoleTemplateId $roleTemplate.Id
    }

    Write-Host "🚀 Deploying Break Glass Accounts..." -ForegroundColor Cyan

    foreach ($acc in $BGAccounts) {
        $upn = "$acc@$Domain"
        
        try {
            # 1. Create User
            $existing = Get-MgUser -UserId $upn -ErrorAction SilentlyContinue
            if ($existing) {
                Write-Host "   ⚠️  Account '$upn' already exists." -ForegroundColor Yellow
                $userId = $existing.Id
            }
            else {
                $userParams = @{
                    DisplayName = "Emergency Access $acc"
                    UserPrincipalName = $upn
                    MailNickname = $acc
                    AccountEnabled = $true
                    PasswordProfile = $PasswordProfile
                    UsageLocation = "US"
                }
                $newUser = New-MgUser -BodyParameter $userParams
                Write-Host "   ✅ Created Account '$upn'" -ForegroundColor Green
                $userId = $newUser.Id
            }

            # 2. Assign Global Admin
            try {
                New-MgDirectoryRoleMemberByRef -DirectoryRoleId $role.Id -BodyParameter @{ "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$userId" } -ErrorAction SilentlyContinue
                Write-Host "   ✅ Assigned Global Admin to '$upn'" -ForegroundColor Green
            }
            catch {
                # Ignore if already member
            }
        }
        catch {
            Write-Error "Failed to process $upn: $_"
        }
    }

    Write-Host "`n⚠️  IMPORTANT: Store these credentials securely (e.g., Password Manager, Physical Safe)." -ForegroundColor Red
    Write-Host "   Password: Emergency!Access!2025!" -ForegroundColor Yellow
}
