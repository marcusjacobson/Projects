<#
.SYNOPSIS
    Configures Group-Based Licensing for the simulation users.

.DESCRIPTION
    Assigns a specified license (e.g., Entra ID P2) to a security group.
    This ensures all members automatically inherit the license.

.PARAMETER SkuId
    The SkuId of the license to assign. If not provided, the script lists available SKUs.

.EXAMPLE
    .\Configure-GroupBasedLicensing.ps1 -SkuId "..."

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 01-Identity-Foundation
#>

[CmdletBinding()]
param(
    [string]$SkuId
)

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    # 1. List Licenses if SkuId not provided
    if ([string]::IsNullOrEmpty($SkuId)) {
        Write-Host "📋 Available Licenses in Tenant:" -ForegroundColor Cyan
        $skus = Get-MgSubscribedSku
        $skus | Select-Object SkuPartNumber, SkuId, ConsumedUnits, PrepaidUnits | Format-Table -AutoSize
        
        Write-Host "⚠️  Please run the script again with the desired SkuId." -ForegroundColor Yellow
        Write-Host "   Example: .\Configure-GroupBasedLicensing.ps1 -SkuId `"$($skus[0].SkuId)`""
        return
    }

    Write-Host "🚀 Configuring Group-Based Licensing..." -ForegroundColor Cyan

    # 2. Create or Get the Licensing Group
    $groupName = "GRP-SEC-All-Licensed-Users"
    $group = Get-MgGroup -Filter "DisplayName eq '$groupName'" -ErrorAction SilentlyContinue
    
    if (-not $group) {
        $group = New-MgGroup -DisplayName $groupName -MailEnabled:$false -MailNickname "grp-licensing" -SecurityEnabled -Description "Group for P2 Licensing"
        Write-Host "   ✅ Created Group '$groupName'" -ForegroundColor Green
    }

    # 3. Assign License to Group
    try {
        # Check if already assigned
        # Note: Graph API for group licensing is via 'assignedLicenses' property update
        
        $addLicense = @{
            SkuId = $SkuId
            DisabledPlans = @()
        }
        
        Set-MgGroup -GroupId $group.Id -AssignedLicenses @{ AddLicenses = @($addLicense); RemoveLicenses = @() }
        Write-Host "   ✅ Assigned License ($SkuId) to Group '$groupName'" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to assign license: $_"
        Write-Host "   Note: Ensure you have available seats and the SkuId is correct." -ForegroundColor Yellow
    }

    # 4. Add All Simulation Users to this Group
    # We'll find all users starting with 'USR-'
    $users = Get-MgUser -Filter "startsWith(userPrincipalName, 'USR-')" -All
    
    Write-Host "   Adding $($users.Count) users to licensing group..." -ForegroundColor Cyan
    
    foreach ($u in $users) {
        try {
            New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $u.Id -ErrorAction SilentlyContinue
        } catch {}
    }
    
    Write-Host "✅ Licensing Configuration Complete." -ForegroundColor Green
}
