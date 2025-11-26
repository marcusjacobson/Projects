<#
.SYNOPSIS
    Configures Group-Based Licensing for the simulation users.

.DESCRIPTION
    Assigns a specified license (e.g., Entra ID P2) to a security group.
    This ensures all members automatically inherit the license.
    If no SkuId is provided, the script interactively prompts the user to select one.

.PARAMETER SkuId
    The SkuId of the license to assign. If not provided, the script lists available SKUs for selection.

.EXAMPLE
    .\Configure-GroupBasedLicensing.ps1

    Interactively select a license from the list.

.EXAMPLE
    .\Configure-GroupBasedLicensing.ps1 -SkuId "..."

    Non-interactive execution with a specific SkuId.

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 01-Identity-Foundation
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SkuId,

    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    # Connect to Graph
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    # Load Parameters (Optional for this script, but good for consistency)
    $paramsPath = Join-Path $PSScriptRoot "..\infra\module.parameters.json"
    if ($UseParametersFile -and (Test-Path $paramsPath)) {
        Write-Host "📂 Loading parameters from $paramsPath..." -ForegroundColor Cyan
        # $jsonParams = Get-Content $paramsPath | ConvertFrom-Json
        # Placeholder: If we add a skuId to the JSON in the future, we can load it here.
    }

    # 1. List Licenses if SkuId not provided
    if ([string]::IsNullOrEmpty($SkuId)) {
        Write-Host "📋 Fetching Available Licenses..." -ForegroundColor Cyan
        $skusResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/subscribedSkus"
        $skus = $skusResponse.value

        if ($null -eq $skus -or $skus.Count -eq 0) {
            Write-Error "No licenses found in the tenant."
            return
        }

        # Define common Entra ID / Security SKUs to highlight
        $targetSkuNames = @(
            "DEVELOPERPACK_E5",   # M365 E5 Developer
            "ENTERPRISEPREMIUM",  # Office 365 E5
            "ENTERPRISEPACK",     # Office 365 E3
            "AAD_PREMIUM",        # Entra ID P1
            "AAD_PREMIUM_P2",     # Entra ID P2
            "EMSPREMIUM",         # EMS E5
            "EMS",                # EMS E3
            "M365_E5",            # Microsoft 365 E5
            "SPE_E5",             # Microsoft 365 E5
            "SPE_E3"              # Microsoft 365 E3
        )

        Write-Host "`nSelect a license to assign to the group:" -ForegroundColor Cyan
        Write-Host "----------------------------------------" -ForegroundColor Cyan
        
        $selectionMap = @{}
        $counter = 1

        # Sort: Recommended first, then others
        $sortedSkus = $skus | Sort-Object { 
            if ($targetSkuNames -contains $_.skuPartNumber) { 0 } else { 1 } 
        }, skuPartNumber

        foreach ($sku in $sortedSkus) {
            $isRecommended = $targetSkuNames -contains $sku.skuPartNumber
            $marker = if ($isRecommended) { "⭐ (Recommended)" } else { "" }
            $available = $sku.prepaidUnits.enabled - $sku.consumedUnits
            
            # Colorize the output
            if ($isRecommended) {
                Write-Host "[$counter] $($sku.skuPartNumber) $marker" -ForegroundColor Green
            } else {
                Write-Host "[$counter] $($sku.skuPartNumber)"
            }
            Write-Host "    ID: $($sku.skuId)" -ForegroundColor DarkGray
            Write-Host "    Available: $available / $($sku.prepaidUnits.enabled)" -ForegroundColor DarkGray
            
            $selectionMap[$counter] = $sku.skuId
            $counter++
        }

        $validSelection = $false
        while (-not $validSelection) {
            $choice = Read-Host "`nEnter the number of the license to use"
            if ($choice -match '^\d+$' -and $selectionMap.ContainsKey([int]$choice)) {
                $SkuId = $selectionMap[[int]$choice]
                $validSelection = $true
                Write-Host "   ✅ Selected: $SkuId" -ForegroundColor Green
            } else {
                Write-Warning "Invalid selection. Please enter a number from the list."
            }
        }
    }

    Write-Host "🚀 Configuring Group-Based Licensing..." -ForegroundColor Cyan

    # 2. Create or Get the Licensing Group
    $groupName = "GRP-SEC-All-Licensed-Users"
    $desc = "Group for P2 Licensing"
    
    try {
        $uri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$groupName'"
        $existingResponse = Invoke-MgGraphRequest -Method GET -Uri $uri
        $existing = $existingResponse.value | Select-Object -First 1

        if ($existing) {
            Write-Host "   ⚠️  Group '$groupName' already exists." -ForegroundColor Yellow
            $groupId = $existing.id
        }
        else {
            $body = @{
                displayName = $groupName
                mailEnabled = $false
                mailNickname = "grp-licensing"
                securityEnabled = $true
                description = $desc
            }
            $group = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups" -Body $body
            Write-Host "   ✅ Created Group '$groupName'" -ForegroundColor Green
            $groupId = $group.id
        }
    }
    catch {
        Write-Error "Failed to get/create group: $_"
        return
    }

    # 3. Assign License to Group
    try {
        $addLicense = @{
            skuId = $SkuId
            disabledPlans = @()
        }
        
        $body = @{
            addLicenses = @($addLicense)
            removeLicenses = @()
        }
        
        Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups/$groupId/assignLicense" -Body $body
        Write-Host "   ✅ Assigned License ($SkuId) to Group '$groupName'" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to assign license: $_"
        Write-Host "   Note: Ensure you have available seats and the SkuId is correct." -ForegroundColor Yellow
    }

    # 4. Add All Simulation Users to this Group
    # We'll find all users starting with 'USR-'
    Write-Host "   🔍 Finding simulation users..." -ForegroundColor Cyan
    $usersUri = "https://graph.microsoft.com/v1.0/users?`$filter=startsWith(userPrincipalName, 'USR-')"
    $usersResponse = Invoke-MgGraphRequest -Method GET -Uri $usersUri
    $users = $usersResponse.value
    
    Write-Host "   Adding $($users.Count) users to licensing group..." -ForegroundColor Cyan
    
    foreach ($u in $users) {
        try {
            $memberBody = @{
                "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($u.id)"
            }
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups/$groupId/members/`$ref" -Body $memberBody -ErrorAction SilentlyContinue
        } catch {
            # Ignore if already member
        }
    }
    
    Write-Host "✅ Licensing Configuration Complete." -ForegroundColor Green
}
