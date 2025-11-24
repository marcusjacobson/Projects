# =============================================================================
# Connection-Management.ps1
# Connection management functions for Microsoft Purview services
# =============================================================================

# Initialize connection tracking
if (-not $Script:ConnectedServices) {
    $Script:ConnectedServices = @{
        SharePoint = $false
        Exchange = $false
        ComplianceCenter = $false
    }
}

function Connect-PurviewServices {
    <#
    .SYNOPSIS
        Connect to Microsoft Purview services.
    
    .DESCRIPTION
        Establishes connections to SharePoint Online, Exchange Online, and
        Compliance Center based on specified services. Supports both interactive
        and certificate-based authentication.
    
    .PARAMETER Services
        Array of services to connect to. Valid values: "SharePoint", "Exchange", "ComplianceCenter"
    
    .PARAMETER TenantUrl
        SharePoint tenant URL (e.g., https://contoso.sharepoint.com)
    
    .PARAMETER PnPClientId
        Azure AD App Registration Client ID for PnP.PowerShell interactive authentication.
        Defaults to PnP Management Shell multi-tenant app (31359c7f-bd7e-475c-86db-fdb8c937548e).
        Can be overridden with custom app registration from global-config.json.
    
    .PARAMETER Interactive
        Use interactive authentication (default: $true)
    
    .PARAMETER ClientId
        Service principal client ID for certificate authentication
    
    .PARAMETER Thumbprint
        Certificate thumbprint for service principal authentication
    
    .PARAMETER Tenant
        Tenant name (e.g., contoso.onmicrosoft.com) for certificate auth
    
    .EXAMPLE
        Connect-PurviewServices -Services @("SharePoint", "Exchange") -TenantUrl "https://contoso.sharepoint.com" -Interactive
        
        Connects to SharePoint and Exchange using interactive authentication.
    
    .EXAMPLE
        Connect-PurviewServices -Services @("SharePoint") -TenantUrl "https://contoso.sharepoint.com" -ClientId "..." -Thumbprint "..." -Tenant "contoso.onmicrosoft.com"
        
        Connects to SharePoint using certificate-based authentication.
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
        
        Script development orchestrated using GitHub Copilot.
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("SharePoint", "Exchange", "ComplianceCenter")]
        [string[]]$Services,
        
        [Parameter(Mandatory = $false)]
        [switch]$Interactive = $true,
        
        [Parameter(Mandatory = $false)]
        [string]$TenantUrl,
        
        [Parameter(Mandatory = $false)]
        [string]$PnPClientId = "31359c7f-bd7e-475c-86db-fdb8c937548e",
        
        [Parameter(Mandatory = $false)]
        [string]$ClientId,
        
        [Parameter(Mandatory = $false)]
        [string]$Thumbprint,
        
        [Parameter(Mandatory = $false)]
        [string]$Tenant
    )
    
    Write-Verbose "Connecting to Purview services: $($Services -join ', ')"
    
    foreach ($service in $Services) {
        try {
            switch ($service) {
                "SharePoint" {
                    if ($Interactive) {
                        if (-not $TenantUrl) {
                            throw "TenantUrl parameter is required for SharePoint connection"
                        }
                        
                        # First, always disconnect any existing connections to ensure clean state
                        try {
                            Disconnect-PnPOnline -ErrorAction SilentlyContinue
                            Write-Verbose "Disconnected any existing SharePoint connections"
                        } catch {
                            # Ignore disconnect errors
                        }
                        
                        Write-Host "   🌐 Launching browser for SharePoint authentication..." -ForegroundColor Cyan
                        Write-Host "   📋 Please sign in when the browser window opens..." -ForegroundColor Cyan
                        # Use app registration with both SharePoint and Microsoft Graph permissions for PnP v3.x compatibility
                        Connect-PnPOnline -Url $TenantUrl -Interactive -ClientId $PnPClientId -ErrorAction Stop
                        Write-Host "   ✅ Connected to SharePoint Online" -ForegroundColor Green
                    } else {
                        if (-not ($TenantUrl -and $ClientId -and $Thumbprint -and $Tenant)) {
                            throw "TenantUrl, ClientId, Thumbprint, and Tenant parameters required for certificate auth"
                        }
                        Connect-PnPOnline -Url $TenantUrl -ClientId $ClientId -Thumbprint $Thumbprint -Tenant $Tenant -ErrorAction Stop
                        Write-Host "   ✅ Connected to SharePoint Online (Certificate)" -ForegroundColor Green
                    }
                    $Script:ConnectedServices["SharePoint"] = $true
                }
                
                "Exchange" {
                    Import-Module ExchangeOnlineManagement -ErrorAction Stop
                    
                    if ($Interactive) {
                        # Check for existing session
                        $existingSession = Get-PSSession | Where-Object { 
                            $_.ComputerName -like "*compliance.protection.outlook.com*" -and 
                            $_.State -eq "Opened" 
                        } | Select-Object -First 1
                        
                        if ($null -ne $existingSession) {
                            Write-Host "   ℹ️  Existing Exchange/Compliance session found - reusing" -ForegroundColor Cyan
                        } else {
                            Write-Host "   🌐 Connecting to Exchange/Compliance Center..." -ForegroundColor Cyan
                            Write-Host "   📋 Please sign in when prompted..." -ForegroundColor Cyan
                            # Use Connect-ExchangeOnline instead of Connect-IPPSSession
                            # This has better modern auth support and avoids WAM/MSAL runtime DLL issues
                            # Connect-ExchangeOnline connects to both Exchange and Security & Compliance Center
                            Connect-ExchangeOnline -ErrorAction Stop
                            Write-Host "   ✅ Connected to Exchange Online" -ForegroundColor Green
                        }
                    } else {
                        if (-not ($ClientId -and $Thumbprint -and $Tenant)) {
                            throw "ClientId, Thumbprint, and Tenant parameters required for certificate auth"
                        }
                        Connect-IPPSSession -AppId $ClientId -CertificateThumbprint $Thumbprint -Organization $Tenant -ErrorAction Stop
                        Write-Host "   ✅ Connected to Exchange Online (Certificate)" -ForegroundColor Green
                    }
                    $Script:ConnectedServices["Exchange"] = $true
                }
                
                "ComplianceCenter" {
                    # Same as Exchange connection
                    if (-not $Script:ConnectedServices["Exchange"]) {
                        Import-Module ExchangeOnlineManagement -ErrorAction Stop
                        
                        if ($Interactive) {
                            Write-Host "   🌐 Connecting to Compliance Center..." -ForegroundColor Cyan
                            Write-Host "   📋 Please sign in when prompted..." -ForegroundColor Cyan
                            # Use Connect-ExchangeOnline instead of Connect-IPPSSession
                            # This has better modern auth support and avoids WAM/MSAL runtime DLL issues
                            # Connect-ExchangeOnline connects to both Exchange and Security & Compliance Center
                            Connect-ExchangeOnline -ErrorAction Stop
                            Write-Host "   ✅ Connected to Compliance Center" -ForegroundColor Green
                        } else {
                            Connect-IPPSSession -AppId $ClientId -CertificateThumbprint $Thumbprint -Organization $Tenant -ErrorAction Stop
                            Write-Host "   ✅ Connected to Compliance Center (Certificate)" -ForegroundColor Green
                        }
                        $Script:ConnectedServices["Exchange"] = $true
                    }
                    $Script:ConnectedServices["ComplianceCenter"] = $true
                }
            }
        } catch {
            Write-Error ('Failed to connect to {0}: {1}' -f $service, $_.Exception.Message)
            throw
        }
    }
}

function Disconnect-PurviewServices {
    <#
    .SYNOPSIS
        Disconnect from all Purview services.
    
    .DESCRIPTION
        Safely disconnects from SharePoint Online and Exchange Online sessions.
    
    .EXAMPLE
        Disconnect-PurviewServices
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Disconnecting from Purview services"
    
    # Disconnect SharePoint
    if ($Script:ConnectedServices["SharePoint"]) {
        try {
            Disconnect-PnPOnline -ErrorAction SilentlyContinue
            Write-Verbose "Disconnected from SharePoint Online"
            $Script:ConnectedServices["SharePoint"] = $false
        } catch {
            Write-Warning ('Failed to disconnect from SharePoint: {0}' -f $_.Exception.Message)
        }
    }
    
    # Disconnect Exchange/Compliance Center
    if ($Script:ConnectedServices["Exchange"] -or $Script:ConnectedServices["ComplianceCenter"]) {
        try {
            Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
            Write-Verbose "Disconnected from Exchange Online"
            $Script:ConnectedServices["Exchange"] = $false
            $Script:ConnectedServices["ComplianceCenter"] = $false
        } catch {
            Write-Warning ('Failed to disconnect from Exchange: {0}' -f $_.Exception.Message)
        }
    }
}

function Test-PurviewConnection {
    <#
    .SYNOPSIS
        Test connectivity to a Purview service.
    
    .DESCRIPTION
        Verifies that a connection to the specified service is active and functional.
    
    .PARAMETER Service
        Service to test. Valid values: "SharePoint", "Exchange", "ComplianceCenter"
    
    .EXAMPLE
        Test-PurviewConnection -Service "SharePoint"
        
        Returns: [PSCustomObject]@{ Service = "SharePoint"; Connected = $true; Message = "Connected" }
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("SharePoint", "Exchange", "ComplianceCenter")]
        [string]$Service
    )
    
    $result = [PSCustomObject]@{
        Service = $Service
        Connected = $false
        Message = ""
    }
    
    try {
        switch ($Service) {
            "SharePoint" {
                $web = Get-PnPWeb -ErrorAction Stop
                $result.Connected = $true
                $result.Message = "Connected to: $($web.Url)"
            }
            
            "Exchange" {
                $sits = Get-DlpSensitiveInformationType -ResultSize 1 -ErrorAction Stop
                $result.Connected = $true
                $result.Message = "Connected to Exchange Online"
            }
            
            "ComplianceCenter" {
                $labels = Get-Label -ResultSize 1 -ErrorAction Stop
                $result.Connected = $true
                $result.Message = "Connected to Compliance Center"
            }
        }
    } catch {
        $result.Connected = $false
        $result.Message = "Connection test failed - " + $_.Exception.Message
    }
    
    return $result
}

function Get-ServiceConnectionStatus {
    <#
    .SYNOPSIS
        Get current connection status for all services.
    
    .DESCRIPTION
        Returns a hashtable with connection status for all Purview services.
    
    .EXAMPLE
        Get-ServiceConnectionStatus
        
        Returns: @{ SharePoint = $true; Exchange = $false; ComplianceCenter = $false }
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param ()
    
    return $Script:ConnectedServices.Clone()
}

# Note: Export-ModuleMember is not needed when dot-sourcing
# Functions are automatically available in the calling scope
