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
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 03-App-Integration
#>

[CmdletBinding()]
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    $appName = "APP-Reporting-Automation"
    
    Write-Host "🚀 Deploying Reporting Service Principal..." -ForegroundColor Cyan

    # 1. Create Self-Signed Certificate
    $certName = "EntraSimulationCert"
    $startDate = Get-Date
    $endDate = $startDate.AddYears(1)
    
    Write-Host "   Generating Self-Signed Certificate..."
    $cert = New-SelfSignedCertificate -Subject "CN=$certName" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256 -NotAfter $endDate
    
    # Export Public Key
    $certData = [System.Convert]::ToBase64String($cert.GetRawCertData())
    
    # 2. Create App Registration
    try {
        $existing = Get-MgApplication -Filter "DisplayName eq '$appName'" -ErrorAction SilentlyContinue
        if ($existing) {
            Write-Host "   ⚠️  App '$appName' already exists." -ForegroundColor Yellow
            $appId = $existing.AppId
            $appObjectId = $existing.Id
        }
        else {
            $keyCredential = @{
                Type = "AsymmetricX509Cert"
                Usage = "Verify"
                Key = $certData
                DisplayName = "Automation Cert"
                StartDateTime = $startDate
                EndDateTime = $endDate
            }

            $app = New-MgApplication -DisplayName $appName -KeyCredentials @($keyCredential)
            Write-Host "   ✅ Created App Registration '$appName'" -ForegroundColor Green
            $appId = $app.AppId
            $appObjectId = $app.Id
        }

        # 3. Create Service Principal
        $sp = Get-MgServicePrincipal -Filter "AppId eq '$appId'" -ErrorAction SilentlyContinue
        if (-not $sp) {
            $sp = New-MgServicePrincipal -AppId $appId
            Write-Host "   ✅ Created Service Principal." -ForegroundColor Green
        }
        $spId = $sp.Id

        # 4. Assign Permissions (AuditLog.Read.All)
        # Find Graph API Service Principal
        $graphSp = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"
        
        # Find the App Role
        $role = $graphSp.AppRoles | Where-Object { $_.Value -eq "AuditLog.Read.All" }
        
        if ($role) {
            try {
                New-MgServicePrincipalAppRoleAssignment -PrincipalId $spId -ResourceId $graphSp.Id -AppRoleId $role.Id -ErrorAction SilentlyContinue
                Write-Host "   ✅ Assigned 'AuditLog.Read.All' permission." -ForegroundColor Green
            }
            catch {
                # Ignore if already assigned
            }
        }
        else {
            Write-Error "Could not find 'AuditLog.Read.All' role."
        }

    }
    catch {
        Write-Error "Failed to deploy Service Principal: $_"
    }
    
    Write-Host "`n✅ Deployment Complete." -ForegroundColor Green
    Write-Host "   App ID: $appId" -ForegroundColor Yellow
    Write-Host "   Certificate Thumbprint: $($cert.Thumbprint)" -ForegroundColor Yellow
}
