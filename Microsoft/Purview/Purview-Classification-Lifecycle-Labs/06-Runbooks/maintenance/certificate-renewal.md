# Maintenance Procedure: Certificate Renewal

## Document Information

**Frequency**: As needed (60-90 days before expiration)  
**Execution Time**: 20-30 minutes  
**Required Permissions**: Azure AD Application Administrator  
**Last Updated**: 2025-11-11

## Purpose

Renew expiring certificates used for service principal authentication to prevent automation disruptions and maintain secure access to Microsoft 365 services.

## Certificate Lifecycle

**Typical Certificate Lifespan**: 1-2 years  
**Renewal Window**: 60-90 days before expiration  
**Critical Window**: 30 days before expiration  
**Outage Risk**: <7 days before expiration

## Identification Procedures

### 1. Identify Expiring Certificates

```powershell
# Connect to Azure AD
Connect-AzureAD

# Get all app registrations with certificates
$apps = Get-AzureADApplication -All $true
$expiringCerts = @()

foreach ($app in $apps) {
    $creds = Get-AzureADApplicationKeyCredential -ObjectId $app.ObjectId
    
    foreach ($cert in $creds) {
        $daysUntilExpiry = ($cert.EndDate - (Get-Date)).Days
        
        if ($daysUntilExpiry -le 90 -and $daysUntilExpiry -gt 0) {
            $expiringCerts += [PSCustomObject]@{
                ApplicationName = $app.DisplayName
                ApplicationId = $app.AppId
                ObjectId = $app.ObjectId
                Thumbprint = $cert.KeyId
                EndDate = $cert.EndDate
                DaysRemaining = $daysUntilExpiry
                Status = if ($daysUntilExpiry -le 30) { "CRITICAL" } elseif ($daysUntilExpiry -le 60) { "WARNING" } else { "INFO" }
            }
        }
    }
}

# Display expiring certificates
Write-Host "`n=== Expiring Certificates ===" -ForegroundColor Cyan
$expiringCerts | Sort-Object DaysRemaining | ForEach-Object {
    $color = switch ($_.Status) {
        "CRITICAL" { "Red" }
        "WARNING" { "Yellow" }
        "INFO" { "Gray" }
    }
    Write-Host "$($_.Status): $($_.ApplicationName) expires in $($_.DaysRemaining) days" -ForegroundColor $color
}

# Export for tracking
$expiringCerts | Export-Csv ".\reports\expiring-certificates-$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
```

### 2. Identify Scripts Using Certificates

```powershell
# Search scripts for certificate authentication
$scriptFiles = Get-ChildItem ".\scripts" -Filter "*.ps1" -Recurse

Write-Host "`n=== Scripts Using Certificate Authentication ===" -ForegroundColor Cyan

foreach ($script in $scriptFiles) {
    $content = Get-Content $script.FullName -Raw
    
    if ($content -match "Certificate|Thumbprint|-ClientId") {
        Write-Host "  📄 $($script.Name)" -ForegroundColor Gray
        
        # Extract certificate thumbprints if present
        if ($content -match "Thumbprint.*=.*[`"']([A-F0-9]{40})[`"']") {
            Write-Host "     Thumbprint: $($Matches[1])" -ForegroundColor DarkGray
        }
    }
}
```

## Certificate Renewal Procedures

### 1. Generate New Certificate

```powershell
# Generate self-signed certificate (valid for 2 years)
$certName = "PurviewAutomation-$((Get-Date).Year)"
$cert = New-SelfSignedCertificate `
    -Subject "CN=$certName" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -KeyAlgorithm RSA `
    -HashAlgorithm SHA256 `
    -NotAfter (Get-Date).AddYears(2)

Write-Host "✅ Certificate created" -ForegroundColor Green
Write-Host "   Thumbprint: $($cert.Thumbprint)" -ForegroundColor Gray
Write-Host "   Expires: $($cert.NotAfter)" -ForegroundColor Gray

# Export certificate for backup
$certPath = ".\certs\$certName-$(Get-Date -Format 'yyyyMMdd').pfx"
$certPassword = Read-Host "Enter certificate password" -AsSecureString
Export-PfxCertificate -Cert $cert -FilePath $certPath -Password $certPassword

Write-Host "✅ Certificate exported to $certPath" -ForegroundColor Green
```

### 2. Update App Registration

```powershell
# Upload new certificate to Azure AD app registration
Connect-AzureAD

$appId = "your-application-id" # Replace with actual app ID
$app = Get-AzureADApplication -Filter "AppId eq '$appId'"

# Upload certificate
$certBase64 = [System.Convert]::ToBase64String($cert.RawData)
New-AzureADApplicationKeyCredential -ObjectId $app.ObjectId -CustomKeyIdentifier $certName -Value $certBase64 -Type AsymmetricX509Cert -Usage Verify

Write-Host "✅ Certificate uploaded to app registration" -ForegroundColor Green

# Verify certificate is present
$creds = Get-AzureADApplicationKeyCredential -ObjectId $app.ObjectId
Write-Host "`nCertificates for $($app.DisplayName):" -ForegroundColor Cyan
$creds | ForEach-Object {
    Write-Host "  Thumbprint: $($_.KeyId)" -ForegroundColor Gray
    Write-Host "  Expires: $($_.EndDate)" -ForegroundColor Gray
}
```

### 3. Test New Certificate Authentication

```powershell
# Test connection with new certificate
try {
    Connect-PnPOnline -Url "https://yourtenant.sharepoint.com" `
        -ClientId $appId `
        -Tenant "yourtenant.onmicrosoft.com" `
        -Thumbprint $cert.Thumbprint
    
    # Test a simple command
    $web = Get-PnPWeb
    Write-Host "✅ Authentication successful with new certificate" -ForegroundColor Green
    Write-Host "   Connected to: $($web.Title)" -ForegroundColor Gray
    
    Disconnect-PnPOnline
} catch {
    Write-Host "❌ Authentication failed: $_" -ForegroundColor Red
}
```

### 4. Update Scripts with New Certificate

```powershell
# Update scripts to use new certificate thumbprint
$oldThumbprint = "OLD_THUMBPRINT_HERE"
$newThumbprint = $cert.Thumbprint

$scriptsToUpdate = Get-ChildItem ".\scripts" -Filter "*.ps1" -Recurse | 
    Where-Object { (Get-Content $_.FullName -Raw) -match $oldThumbprint }

Write-Host "`n=== Updating Scripts ===" -ForegroundColor Cyan

foreach ($script in $scriptsToUpdate) {
    $content = Get-Content $script.FullName -Raw
    $updated = $content -replace $oldThumbprint, $newThumbprint
    Set-Content $script.FullName -Value $updated
    
    Write-Host "✅ Updated: $($script.Name)" -ForegroundColor Green
}
```

### 5. Remove Old Certificate (After Validation)

```powershell
# WAIT 24-48 hours and verify all automation works before removing old certificate

# Remove old certificate from app registration
Connect-AzureAD
$app = Get-AzureADApplication -Filter "AppId eq '$appId'"
$oldCred = Get-AzureADApplicationKeyCredential -ObjectId $app.ObjectId | 
    Where-Object { $_.EndDate -lt (Get-Date).AddDays(90) }

if ($oldCred) {
    Remove-AzureADApplicationKeyCredential -ObjectId $app.ObjectId -KeyId $oldCred.KeyId
    Write-Host "✅ Removed old certificate from app registration" -ForegroundColor Green
} else {
    Write-Host "No old certificates found to remove" -ForegroundColor Gray
}
```

## Certificate Renewal Checklist

- [ ] Identified all expiring certificates (within 60-90 days).
- [ ] Documented scripts and services using certificates.
- [ ] Generated new certificate (2-year validity).
- [ ] Exported certificate to secure backup location.
- [ ] Uploaded new certificate to Azure AD app registration.
- [ ] Tested authentication with new certificate.
- [ ] Updated all scripts with new certificate thumbprint.
- [ ] Validated all scheduled tasks work with new certificate.
- [ ] Waited 24-48 hours for full validation.
- [ ] Removed old certificate from app registration.
- [ ] Updated documentation with new certificate details.

## Validation Testing

After certificate renewal, test these scenarios:

```powershell
# Test 1: Manual script execution
.\Invoke-PurviewClassification.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/TestSite"

# Test 2: Scheduled task execution
Start-ScheduledTask -TaskName "Purview Classification - Daily"
Start-Sleep -Seconds 30
Get-ScheduledTaskInfo -TaskName "Purview Classification - Daily" | Select-Object LastTaskResult, LastRunTime

# Test 3: Service connections
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com" -ClientId $appId -Tenant "yourtenant.onmicrosoft.com" -Thumbprint $newThumbprint
Get-PnPWeb | Select-Object Title, Url
Disconnect-PnPOnline
```

## Prevention and Monitoring

**Setup Expiration Alerts:**

```powershell
# Schedule monthly certificate expiration check
.\New-PurviewScheduledTask.ps1 `
    -TaskName "Certificate Expiration Check" `
    -ScriptPath "C:\Scripts\Check-CertificateExpiration.ps1" `
    -Trigger Monthly `
    -StartTime "09:00:00"
```

**Renewal Timeline:**

- **90 days**: Initial notification and planning.
- **60 days**: Generate new certificate and upload to Azure AD.
- **45 days**: Update test environments.
- **30 days**: Update production scripts and validate.
- **7 days**: Final validation before old certificate expires.
- **Expiration day**: Remove old certificate from Azure AD.

## Related Procedures

- **Scheduled Task Failure**: If certificate renewal causes task failures
- **Permission Denied**: If new certificate lacks required permissions
- **Configuration Backup**: Backup updated configurations after renewal

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This document is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*
