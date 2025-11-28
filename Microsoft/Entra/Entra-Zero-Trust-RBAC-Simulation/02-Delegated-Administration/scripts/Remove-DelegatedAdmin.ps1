<#
.SYNOPSIS
    Removes Administrative Units created in Lab 02.

.EXAMPLE
    .\Remove-DelegatedAdmin.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 02-Delegated-Administration
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
)

process {
    # Connect to Graph
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    # Load Parameters
    $paramsPath = Join-Path $PSScriptRoot "..\infra\module.parameters.json"
    if ($UseParametersFile -or (Test-Path $paramsPath)) {
        if (Test-Path $paramsPath) {
            Write-Host "📂 Loading parameters from $paramsPath..." -ForegroundColor Cyan
            $jsonParams = Get-Content $paramsPath | ConvertFrom-Json
            
            # Load from deployment sections to ensure we target exactly what was created
            $AuPrefix = $jsonParams."Deploy-AdministrativeUnits".auPrefix
            $RestrictedAuName = $jsonParams."Configure-RestrictedManagementAUs".auName
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }

    if (-not $Force) {
        $confirm = Read-Host "⚠️  Are you sure you want to delete all simulation Administrative Units? (y/n)"
        if ($confirm -ne 'y') { return }
    }

    Write-Host "🚀 Removing Administrative Units..." -ForegroundColor Cyan

    # Helper function for retries
    function Invoke-GraphRequestWithRetry {
        param(
            [string]$Method,
            [string]$Uri,
            [int]$MaxRetries = 3
        )
        
        $retry = 0
        $success = $false
        $response = $null
        
        while (-not $success -and $retry -lt $MaxRetries) {
            try {
                $response = Invoke-MgGraphRequest -Method $Method -Uri $Uri -ErrorAction Stop
                $success = $true
            }
            catch {
                $retry++
                if ($retry -eq $MaxRetries) {
                    throw $_
                }
                Write-Warning "   ⚠️  Connection failed. Retrying ($retry/$MaxRetries)..."
                Start-Sleep -Seconds 2
            }
        }
        return $response
    }

    # 1. Find Departmental AUs by Prefix
    $uri = "https://graph.microsoft.com/v1.0/directory/administrativeUnits?`$filter=startsWith(displayName, '$AuPrefix')"
    $ausResponse = Invoke-GraphRequestWithRetry -Method GET -Uri $uri
    $aus = @($ausResponse.value)

    # 2. Find Restricted AU by Name (if not already caught by prefix)
    if (-not ($aus | Where-Object { $_.displayName -eq $RestrictedAuName })) {
        $resUri = "https://graph.microsoft.com/v1.0/directory/administrativeUnits?`$filter=displayName eq '$RestrictedAuName'"
        $resResponse = Invoke-GraphRequestWithRetry -Method GET -Uri $resUri
        if ($resResponse.value) {
            $aus += $resResponse.value
        }
    }
    
    foreach ($au in $aus) {
        Write-Host "   Removing AU: $($au.displayName)"
        try {
            Invoke-GraphRequestWithRetry -Method DELETE -Uri "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$($au.id)"
            Write-Host "   ✅ Removed." -ForegroundColor Green
        }
        catch {
            # Check the full error record string as Invoke-MgGraphRequest errors are verbose
            $errString = $_.ToString()
            if ($errString -like "*restricted management administrative unit*" -or $errString -like "*Authorization_RequestDenied*") {
                Write-Host "      🔒 AU is protected (Restricted Management). Skipping deletion." -ForegroundColor Yellow
            } else {
                Write-Error "   ❌ Failed to remove $($au.displayName): $_"
            }
        }
    }
    
    Write-Host "✅ Cleanup Complete." -ForegroundColor Green
}
