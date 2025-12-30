<#
.SYNOPSIS
    Creates and configures a Service Principal for the Purview Retail Data Protection Masterclass.

.DESCRIPTION
    This script automates the creation of an Azure AD Application and Service Principal required for the
    Purview Masterclass. It performs the following actions:
    1. Reads configuration from global-config.json.
    2. Creates a new Azure AD Application.
    3. Creates a Service Principal for the application.
    4. Generates a self-signed certificate and adds it to the application.
    5. Assigns required API permissions (App Roles) and grants admin consent.
    6. Exports the certificate and configuration details for use in subsequent labs.

.PARAMETER ConfigFile
    Path to the global-config.json file. Defaults to "..\..\templates\global-config.json".

.EXAMPLE
    .\Deploy-ServicePrincipal.ps1
    
    Standard usage using default configuration path.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-28
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    - User must have Application Administrator and Global Administrator (for consent) roles.
    
    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = "$PSScriptRoot\..\..\templates\global-config.json"
)

# =============================================================================
# Step 0: Verify and Install Prerequisites
# =============================================================================

Write-Host "🔧 Step 0: Verify and Install Prerequisites" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Check for Microsoft Graph modules and handle version conflicts
$requiredModules = @(
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Applications",
    "Microsoft.Graph.Identity.DirectoryManagement"
)

foreach ($moduleName in $requiredModules) {
    $module = Get-InstalledModule -Name $moduleName -ErrorAction SilentlyContinue
    
    if (-not $module) {
        Write-Host "   📦 Installing $moduleName..." -ForegroundColor Cyan
        try {
            Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Write-Host "   ✅ Installed $moduleName" -ForegroundColor Cyan
        }
        catch {
            Write-Host "   ❌ Failed to install $moduleName : $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "   ✅ $moduleName is installed (Version: $($module.Version))" -ForegroundColor Cyan
    }
}

# Import modules to ensure they're loaded correctly
try {
    Import-Module Microsoft.Graph.Authentication -Force -ErrorAction Stop
    Import-Module Microsoft.Graph.Applications -Force -ErrorAction Stop
    Import-Module Microsoft.Graph.Identity.DirectoryManagement -Force -ErrorAction Stop
    Write-Host "   ✅ Microsoft Graph modules loaded successfully" -ForegroundColor Cyan
}
catch {
    Write-Host "   ⚠️ Module loading issue detected. Attempting to resolve..." -ForegroundColor Yellow
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    # Uninstall and reinstall to fix version conflicts
    Write-Host "   🔄 Removing existing Graph modules..." -ForegroundColor Cyan
    Get-InstalledModule Microsoft.Graph* | ForEach-Object {
        Write-Host "      Removing $($_.Name)..." -ForegroundColor Cyan
        Uninstall-Module -Name $_.Name -AllVersions -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "   📦 Reinstalling Microsoft.Graph (this may take 2-3 minutes)..." -ForegroundColor Cyan
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force -AllowClobber
    
    Write-Host "`n   ✅ Modules reinstalled successfully." -ForegroundColor Green
    Write-Host "   🔄 Please close PowerShell completely and run the script again in a fresh session." -ForegroundColor Yellow
    Write-Host "      (The current session has cached the old assemblies)" -ForegroundColor Cyan
    exit 0
}

# =============================================================================
# Step 1: Initialization and Configuration
# =============================================================================

Write-Host "`n📋 Step 1: Initialization and Configuration" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Check for Config File
if (-not (Test-Path $ConfigFile)) {
    Write-Host "❌ Configuration file not found at: $ConfigFile" -ForegroundColor Red
    exit 1
}

$config = Get-Content $ConfigFile | ConvertFrom-Json
$appName = $config.servicePrincipal.displayName
$certName = $config.servicePrincipal.certificateName

# Check for Force switch
$Force = $false
if ($args -contains "-Force") {
    $Force = $true
    Write-Host "   ⚠️ Force mode enabled: Existing resources will be recreated." -ForegroundColor Yellow
}

Write-Host "   ✅ Configuration loaded for App: $appName" -ForegroundColor Cyan

# =============================================================================
# Step 2: Connect to Microsoft Graph
# =============================================================================

Write-Host "`n🔐 Step 2: Connect to Microsoft Graph" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Ensure we are not connected as a Service Principal from a previous session
# The deployment script requires Interactive User Authentication (Global Admin/App Admin)
# because the Service Principal does not exist yet or doesn't have permissions to create itself.
if (Get-MgContext) {
    Write-Host "   🔄 Disconnecting existing session to ensure correct User context..." -ForegroundColor Cyan
    Disconnect-MgGraph
}

# Required scopes for creating apps and granting consent
$scopes = @(
    "AppRoleAssignment.ReadWrite.All",
    "Application.ReadWrite.All",
    "Directory.ReadWrite.All",
    "RoleManagement.ReadWrite.Directory"
)

try {
    $connectParams = @{ Scopes = $scopes; ErrorAction = "Stop" }
    
    if ($config.tenantId -and $config.tenantId -ne "YOUR-TENANT-ID-HERE") {
        $connectParams["TenantId"] = $config.tenantId
        Write-Host "   Using Tenant ID from config: $($config.tenantId)" -ForegroundColor Cyan
    }

    Connect-MgGraph @connectParams
    Write-Host "   ✅ Connected to Microsoft Graph" -ForegroundColor Cyan
}
catch {
    if ($_.Exception.Message -like "*Could not load type*Microsoft.Identity.Client*") {
        Write-Host "   ❌ Assembly version conflict detected" -ForegroundColor Red
        Write-Host "`n   🔧 Fixing: Removing all Graph modules and reinstalling..." -ForegroundColor Yellow
        
        # Disconnect if partially connected
        Disconnect-MgGraph -ErrorAction SilentlyContinue
        
        # Remove all versions
        Get-InstalledModule Microsoft.Graph* | ForEach-Object {
            Write-Host "      Removing $($_.Name)..." -ForegroundColor Cyan
            Uninstall-Module -Name $_.Name -AllVersions -Force -ErrorAction SilentlyContinue
        }
        
        Write-Host "   📦 Reinstalling Microsoft.Graph module (this may take 2-3 minutes)..." -ForegroundColor Cyan
        Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force -AllowClobber -Repository PSGallery
        
        Write-Host "`n   ✅ Modules reinstalled successfully." -ForegroundColor Green
        Write-Host "   🔄 IMPORTANT: Close PowerShell completely and run this script again in a NEW session." -ForegroundColor Yellow
        Write-Host "      (Press Ctrl+D or type 'exit' to close this session)" -ForegroundColor Cyan
        exit 0
    }
    else {
        Write-Host "   ❌ Failed to connect to Microsoft Graph: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# =============================================================================
# Step 3: Create Application and Service Principal
# =============================================================================

Write-Host "`n🚀 Step 3: Create Application and Service Principal" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

try {
    # Check if app exists
    $existingApp = Get-MgApplication -Filter "DisplayName eq '$appName'" -ErrorAction SilentlyContinue
    
    # Handle array return (multiple apps with same name)
    if ($existingApp -is [array]) {
        $existingApp = $existingApp[0]
        Write-Host "   ⚠️ Multiple applications found with name '$appName'. Using the first one." -ForegroundColor Yellow
    }

    if ($existingApp -and -not $Force) {
        Write-Host "   ⚠️ Application '$appName' already exists. Using existing app." -ForegroundColor Yellow
        $app = $existingApp
    }
    elseif ($existingApp -and $Force) {
        Write-Host "   ⚠️ Application '$appName' exists. Removing for clean install..." -ForegroundColor Yellow
        Remove-MgApplication -ApplicationId $existingApp.Id -ErrorAction Stop
        Start-Sleep -Seconds 10 # Wait for deletion propagation
        $app = New-MgApplication -DisplayName $appName -SignInAudience "AzureADMyOrg"
        Write-Host "   ✅ Created Application: $($app.AppId)" -ForegroundColor Cyan
    }
    else {
        $app = New-MgApplication -DisplayName $appName -SignInAudience "AzureADMyOrg"
        Write-Host "   ✅ Created Application: $($app.AppId)" -ForegroundColor Cyan
    }

    # Check if SP exists
    $existingSp = Get-MgServicePrincipal -Filter "AppId eq '$($app.AppId)'" -ErrorAction SilentlyContinue
    
    # Handle array return
    if ($existingSp -is [array]) {
        $existingSp = $existingSp[0]
    }

    if ($existingSp -and -not $Force) {
        Write-Host "   ⚠️ Service Principal already exists. Using existing SP." -ForegroundColor Yellow
        $sp = $existingSp
    }
    elseif ($existingSp -and $Force) {
        Write-Host "   ⚠️ Service Principal exists. Removing for clean install..." -ForegroundColor Yellow
        Remove-MgServicePrincipal -ServicePrincipalId $existingSp.Id -ErrorAction Stop
        Start-Sleep -Seconds 10
        $sp = New-MgServicePrincipal -AppId $app.AppId
        Write-Host "   ✅ Created Service Principal: $($sp.Id)" -ForegroundColor Cyan
    }
    else {
        $sp = New-MgServicePrincipal -AppId $app.AppId
        Write-Host "   ✅ Created Service Principal: $($sp.Id)" -ForegroundColor Cyan
    }
}
catch {
    Write-Host "   ❌ Failed to create App or SP: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 4: Certificate Management
# =============================================================================

Write-Host "`n🔐 Step 4: Certificate Management" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

try {
    # Define global certificates path
    $globalCertPath = Join-Path $PSScriptRoot "..\..\Certificates"
    if (-not (Test-Path $globalCertPath)) {
        New-Item -ItemType Directory -Path $globalCertPath -Force | Out-Null
    }

    $certPath = Join-Path $globalCertPath "$certName.pfx"
    $cerPath = Join-Path $globalCertPath "$certName.cer"
    
    # Create Self-Signed Cert
    $cert = New-SelfSignedCertificate -Subject "CN=$certName" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -NotAfter (Get-Date).AddYears(2)
    
    # Generate Random Password for PFX protection
    $certPassword = -join ((33..126) | Get-Random -Count 24 | ForEach-Object {[char]$_})
    $password = ConvertTo-SecureString -String $certPassword -Force -AsPlainText
    
    # Export to PFX
    Export-PfxCertificate -Cert $cert -FilePath $certPath -Password $password
    
    # Export public key
    Export-Certificate -Cert $cert -FilePath $cerPath -Type CERT | Out-Null
    
    Write-Host "   ✅ Generated Certificate: $certPath" -ForegroundColor Cyan

    # Add to Application
    # Key must be a byte array, not a Base64 string for the SDK model
    $certBytes = $cert.GetRawCertData()
    
    $keyCredential = @{
        type = "AsymmetricX509Cert"
        usage = "Verify"
        key = $certBytes
        displayName = $certName
        startDateTime = $cert.NotBefore.ToUniversalTime()
        endDateTime = $cert.NotAfter.ToUniversalTime()
    }

    Update-MgApplication -ApplicationId $app.Id -KeyCredentials @($keyCredential)
    Write-Host "   ✅ Uploaded Certificate to Application" -ForegroundColor Cyan
}
catch {
    if ($_.Exception.Message -like "*Resource*does not exist*") {
        Write-Host "   ❌ The Application object was not found. It may have been deleted recently. Try running with -Force to recreate it." -ForegroundColor Red
    }
    Write-Host "   ❌ Failed to manage certificate: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 5: Assign Permissions and Grant Consent
# =============================================================================

Write-Host "`n🛡️ Step 5: Assign Permissions and Grant Consent" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

foreach ($resource in $config.servicePrincipal.permissions) {
    $resourceAppName = $resource.resourceAppName
    $resourceAppId = $resource.resourceAppId
    
    Write-Host "   Processing permissions for: $resourceAppName" -ForegroundColor Cyan
    
    try {
        # Get Resource Service Principal (e.g., Graph)
        $resourceSp = Get-MgServicePrincipal -Filter "AppId eq '$resourceAppId'" -ErrorAction Stop
        
        foreach ($roleName in $resource.roles) {
            # Find the AppRole
            $appRole = $resourceSp.AppRoles | Where-Object { $_.Value -eq $roleName }
            
            if ($null -eq $appRole) {
                Write-Host "      ⚠️ Role '$roleName' not found in $resourceAppName" -ForegroundColor Yellow
                continue
            }
            
            # Check if assignment exists
            $existingAssignment = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id | Where-Object { $_.ResourceId -eq $resourceSp.Id -and $_.AppRoleId -eq $appRole.Id }
            
            if ($existingAssignment) {
                Write-Host "      ⚠️ Permission '$roleName' already assigned." -ForegroundColor Yellow
            }
            else {
                # Assign the role (Requires both ServicePrincipalId for the URL and PrincipalId for the body)
                New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -ResourceId $resourceSp.Id -AppRoleId $appRole.Id | Out-Null
                Write-Host "      ✅ Granted Admin Consent for: $roleName" -ForegroundColor Cyan
            }
        }
    }
    catch {
        Write-Host "      ❌ Failed to process permissions for $($resourceAppName): $_" -ForegroundColor Red
    }
}

# =============================================================================
# Step 5b: Assign Directory Roles (Required for Compliance PowerShell and SharePoint)
# =============================================================================

Write-Host "`n👑 Step 5b: Assign Directory Roles" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Roles to assign
$roleNames = @("Compliance Administrator", "SharePoint Administrator")

foreach ($roleName in $roleNames) {
    try {
        # 1. Get the Role Template (Client-side filtering to avoid OData limitations)
        $allTemplates = Get-MgDirectoryRoleTemplate -All
        $roleTemplate = $allTemplates | Where-Object { $_.DisplayName -eq $roleName }
        
        if ($roleTemplate) {
            # 2. Check if the role is already instantiated in the directory
            # We also use client-side filtering here for safety, though RoleTemplateId filter usually works
            $allRoles = Get-MgDirectoryRole -All
            $role = $allRoles | Where-Object { $_.RoleTemplateId -eq $roleTemplate.Id }
            
            if (-not $role) {
                Write-Host "   ⚙️ Activating '$roleName' role in directory..." -ForegroundColor Cyan
                $role = New-MgDirectoryRole -RoleTemplateId $roleTemplate.Id
            }
            
            # 3. Add SP to Role (Idempotent approach)
            # We try to add directly. If it fails with "already exists", we consider it a success.
            # This avoids issues where Get-MgDirectoryRoleMember returns incomplete lists due to latency.
            try {
                New-MgDirectoryRoleMemberByRef -DirectoryRoleId $role.Id -BodyParameter @{ "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($sp.Id)" } -ErrorAction Stop
                Write-Host "   ✅ Assigned '$roleName' role to Service Principal" -ForegroundColor Cyan
            }
            catch {
                if ($_.Exception.Message -like "*already exist*") {
                    Write-Host "   ⚠️ Service Principal is already a $roleName." -ForegroundColor Yellow
                }
                else {
                    throw $_
                }
            }
        }
        else {
            Write-Host "   ❌ Could not find role template for '$roleName'" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "   ❌ Failed to assign '$roleName' role: $_" -ForegroundColor Red
    }
}

# =============================================================================
# Step 6: Output Configuration
# =============================================================================

Write-Host "`n📊 Step 6: Output Configuration" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

$output = @"
----------------------------------------------------------------
SETUP COMPLETE
----------------------------------------------------------------
Tenant ID:       $((Get-MgContext).TenantId)
App ID:          $($app.AppId)
Cert Thumbprint: $($cert.Thumbprint)
Cert Path (PFX): $certPath
Cert Path (CER): $cerPath
----------------------------------------------------------------
Please save these details securely. You will need them for the labs.
"@

Write-Host $output -ForegroundColor Cyan

Write-Host "`n🔑 CERTIFICATE PASSWORD (NOT SAVED TO FILE):" -ForegroundColor Yellow
Write-Host "   $certPassword" -ForegroundColor White -BackgroundColor Black
Write-Host "   ⚠️  Save this password securely! It is required to import the PFX file." -ForegroundColor Yellow

# Save to a local file for reference
$globalScriptsPath = Join-Path $PSScriptRoot "..\..\scripts"
if (-not (Test-Path $globalScriptsPath)) {
    New-Item -ItemType Directory -Path $globalScriptsPath -Force | Out-Null
}
$output | Out-File (Join-Path $globalScriptsPath "ServicePrincipal-Details.txt")
Write-Host "   ✅ Details saved to ..\..\scripts\ServicePrincipal-Details.txt" -ForegroundColor Green
