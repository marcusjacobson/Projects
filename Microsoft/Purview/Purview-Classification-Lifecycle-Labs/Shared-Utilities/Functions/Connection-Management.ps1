# =============================================================================
# Connection-Management.ps1
# Connection management functions for Microsoft Purview services
# =============================================================================

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
    
    .PARAMETER Interactive
        Use interactive authentication (default: $true)
    
    .PARAMETER TenantUrl
        SharePoint tenant URL (e.g., https://contoso.sharepoint.com)
    
    .PARAMETER ClientId
        Service principal client ID for certificate authentication
    
    .PARAMETER Thumbprint
        Certificate thumbprint for service principal authentication
    
    .PARAMETER Tenant
        Tenant name (e.g., contoso.onmicrosoft.com) for certificate auth
    
    .EXAMPLE
        Connect-PurviewServices -Services @("SharePoint", "Exchange") -Interactive
        
        Connects to SharePoint and Exchange using interactive authentication.
    
    .EXAMPLE
        Connect-PurviewServices -Services @("SharePoint") -TenantUrl "https://contoso.sharepoint.com" -ClientId "..." -Thumbprint "..." -Tenant "contoso.onmicrosoft.com"
        
        Connects to SharePoint using certificate-based authentication.
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
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
        [string]$ClientId,
        
        [Parameter(Mandatory = $false)]
        [string]$Thumbprint,
        
        [Parameter(Mandatory = $false)]
        [string]$Tenant
    )
    
    Write-PurviewLog "Connecting to Purview services: $($Services -join ', ')" -Level "INFO"
    
    foreach ($service in $Services) {
        try {
            switch ($service) {
                "SharePoint" {
                    if ($Interactive) {
                        if (-not $TenantUrl) {
                            throw "TenantUrl parameter is required for SharePoint connection"
                        }
                        Connect-PnPOnline -Url $TenantUrl -Interactive -ErrorAction Stop
                        Write-PurviewLog "✅ Connected to SharePoint Online (Interactive)" -Level "INFO"
                    } else {
                        if (-not ($TenantUrl -and $ClientId -and $Thumbprint -and $Tenant)) {
                            throw "TenantUrl, ClientId, Thumbprint, and Tenant parameters required for certificate auth"
                        }
                        Connect-PnPOnline -Url $TenantUrl -ClientId $ClientId -Thumbprint $Thumbprint -Tenant $Tenant -ErrorAction Stop
                        Write-PurviewLog "✅ Connected to SharePoint Online (Certificate)" -Level "INFO"
                    }
                    $Script:ConnectedServices["SharePoint"] = $true
                }
                
                "Exchange" {
                    if ($Interactive) {
                        Connect-IPPSSession -ErrorAction Stop
                        Write-PurviewLog "✅ Connected to Exchange Online (Interactive)" -Level "INFO"
                    } else {
                        if (-not ($ClientId -and $Thumbprint -and $Tenant)) {
                            throw "ClientId, Thumbprint, and Tenant parameters required for certificate auth"
                        }
                        Connect-IPPSSession -AppId $ClientId -CertificateThumbprint $Thumbprint -Organization $Tenant -ErrorAction Stop
                        Write-PurviewLog "✅ Connected to Exchange Online (Certificate)" -Level "INFO"
                    }
                    $Script:ConnectedServices["Exchange"] = $true
                }
                
                "ComplianceCenter" {
                    # Same as Exchange connection
                    if (-not $Script:ConnectedServices["Exchange"]) {
                        if ($Interactive) {
                            Connect-IPPSSession -ErrorAction Stop
                            Write-PurviewLog "✅ Connected to Compliance Center (Interactive)" -Level "INFO"
                        } else {
                            Connect-IPPSSession -AppId $ClientId -CertificateThumbprint $Thumbprint -Organization $Tenant -ErrorAction Stop
                            Write-PurviewLog "✅ Connected to Compliance Center (Certificate)" -Level "INFO"
                        }
                        $Script:ConnectedServices["Exchange"] = $true
                    }
                    $Script:ConnectedServices["ComplianceCenter"] = $true
                }
            }
        } catch {
            Write-PurviewError "Failed to connect to $service`: $_"
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
    
    Write-PurviewLog "Disconnecting from Purview services" -Level "INFO"
    
    # Disconnect SharePoint
    if ($Script:ConnectedServices["SharePoint"]) {
        try {
            Disconnect-PnPOnline -ErrorAction SilentlyContinue
            Write-PurviewLog "✅ Disconnected from SharePoint Online" -Level "INFO"
            $Script:ConnectedServices["SharePoint"] = $false
        } catch {
            Write-PurviewError "Failed to disconnect from SharePoint: $_"
        }
    }
    
    # Disconnect Exchange/Compliance Center
    if ($Script:ConnectedServices["Exchange"] -or $Script:ConnectedServices["ComplianceCenter"]) {
        try {
            Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
            Write-PurviewLog "✅ Disconnected from Exchange Online" -Level "INFO"
            $Script:ConnectedServices["Exchange"] = $false
            $Script:ConnectedServices["ComplianceCenter"] = $false
        } catch {
            Write-PurviewError "Failed to disconnect from Exchange: $_"
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
        $result.Message = "Connection test failed: $_"
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
