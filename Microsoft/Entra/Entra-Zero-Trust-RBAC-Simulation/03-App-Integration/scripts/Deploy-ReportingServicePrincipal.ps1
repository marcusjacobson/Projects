<#
.SYNOPSIS
    Deploys a Service Principal with Certificate Authentication.

.DESCRIPTION
    Creates an App Registration 'APP-Reporting-Automation'.
    Generates a self-signed certificate and uploads the public key.
    Creates the Service Principal.
    Assigns 'AuditLog.Read.All' application permission.

.EXAMPLE
    .\Deploy-ReportingServicePrincipal.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-28
    Last Modified: 2025-11-28
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Deploys a Service Principal with Certificate Authentication.
# =============================================================================

[CmdletBinding()]
param(
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
            
            $AppName = $jsonParams."Deploy-ReportingServicePrincipal".appName
            $CertName = $jsonParams."Deploy-ReportingServicePrincipal".certName
            $Permissions = $jsonParams."Deploy-ReportingServicePrincipal".permissions
            $CertValidityYears = [int]$jsonParams."Deploy-ReportingServicePrincipal".certValidityYears
            $KeyDisplayName = $jsonParams."Deploy-ReportingServicePrincipal".keyCredentialDisplayName
        } else {
            Throw "Parameters file not found at $paramsPath"
        }
    } else {
        Throw "Please use -UseParametersFile or ensure module.parameters.json exists."
    }
    
    Write-Host "🚀 Deploying Reporting Service Principal..." -ForegroundColor Cyan

    # 1. Create Self-Signed Certificate
    $startDate = Get-Date
    $endDate = $startDate.AddYears($CertValidityYears)
    
    Write-Host "   Generating Self-Signed Certificate..."
    $cert = New-SelfSignedCertificate -Subject "CN=$CertName" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256 -NotAfter $endDate
    
    # Export Public Key
    $certData = [System.Convert]::ToBase64String($cert.GetRawCertData())
    
    # 2. Create App Registration
    try {
        $uri = "https://graph.microsoft.com/v1.0/applications?`$filter=displayName eq '$AppName'"
        $existingResponse = Invoke-MgGraphRequest -Method GET -Uri $uri
        $existing = $existingResponse.value | Select-Object -First 1

        if ($existing) {
            Write-Host "   ⚠️  App '$AppName' already exists." -ForegroundColor Yellow
            $appId = $existing.appId
            $appObjectId = $existing.id
        }
        else {
            $keyCredential = @{
                type = "AsymmetricX509Cert"
                usage = "Verify"
                key = $certData
                displayName = $KeyDisplayName
                startDateTime = $startDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                endDateTime = $endDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            }

            $body = @{
                displayName = $AppName
                keyCredentials = @($keyCredential)
            }

            $app = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/applications" -Body $body
            Write-Host "   ✅ Created App Registration '$AppName'" -ForegroundColor Green
            $appId = $app.appId
            $appObjectId = $app.id
        }

        # 3. Create Service Principal
        $spUri = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '$appId'"
        $spResponse = Invoke-MgGraphRequest -Method GET -Uri $spUri
        $sp = $spResponse.value | Select-Object -First 1

        if (-not $sp) {
            $body = @{ appId = $appId }
            $sp = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/servicePrincipals" -Body $body
            Write-Host "   ✅ Created Service Principal." -ForegroundColor Green
        }
        $spId = $sp.id

        # 4. Assign Permissions (AuditLog.Read.All)
        # Find Graph API Service Principal
        $graphSpUri = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '00000003-0000-0000-c000-000000000000'"
        $graphSpResponse = Invoke-MgGraphRequest -Method GET -Uri $graphSpUri
        $graphSp = $graphSpResponse.value | Select-Object -First 1
        
        foreach ($perm in $Permissions) {
            # Find the App Role
            $role = $graphSp.appRoles | Where-Object { $_.value -eq $perm }
            
            if ($role) {
                try {
                    $body = @{
                        principalId = $spId
                        resourceId = $graphSp.id
                        appRoleId = $role.id
                    }
                    Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/servicePrincipals/$spId/appRoleAssignments" -Body $body -ErrorAction SilentlyContinue
                    Write-Host "   ✅ Assigned '$perm' permission." -ForegroundColor Green
                }
                catch {
                    # Ignore if already assigned
                }
            }
            else {
                Write-Error "Could not find '$perm' role."
            }
        }

    }
    catch {
        Write-Error "Failed to deploy Service Principal: $_"
    }
    
    Write-Host "`n✅ Deployment Complete." -ForegroundColor Green
    Write-Host "   App ID: $appId" -ForegroundColor Yellow
    Write-Host "   Certificate Thumbprint: $($cert.Thumbprint)" -ForegroundColor Yellow
}
