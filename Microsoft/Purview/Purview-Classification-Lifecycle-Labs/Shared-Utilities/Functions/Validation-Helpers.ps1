# =============================================================================
# Validation-Helpers.ps1
# Common validation patterns and prerequisite checks
# =============================================================================

function Test-PurviewPrerequisites {
    <#
    .SYNOPSIS
        Validate prerequisites before script execution.
    
    .DESCRIPTION
        Checks for required PowerShell modules, versions, and permissions.
    
    .PARAMETER RequiredModules
        Array of module requirements with Name and MinVersion properties
    
    .PARAMETER RequireAdmin
        Check if running as administrator (default: $false)
    
    .PARAMETER TestConnectivity
        Test network connectivity to Microsoft 365 services (default: $false)
    
    .EXAMPLE
        $validation = Test-PurviewPrerequisites -RequiredModules @(
            @{ Name = "PnP.PowerShell"; MinVersion = "1.12.0" }
        )
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [hashtable[]]$RequiredModules,
        
        [Parameter(Mandatory = $false)]
        [switch]$RequireAdmin,
        
        [Parameter(Mandatory = $false)]
        [switch]$TestConnectivity
    )
    
    $result = [PSCustomObject]@{
        Success = $true
        Message = "All prerequisites met"
        FailedChecks = @()
    }
    
    Write-PurviewLog "Validating prerequisites..." -Level "INFO"
    
    # Check administrator privileges
    if ($RequireAdmin) {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) {
            $result.Success = $false
            $result.FailedChecks += "Administrator privileges required"
            Write-PurviewLog "❌ Not running as administrator" -Level "ERROR"
        } else {
            Write-PurviewLog "✅ Running as administrator" -Level "INFO"
        }
    }
    
    # Check required modules
    if ($RequiredModules) {
        foreach ($module in $RequiredModules) {
            $installed = Get-Module -Name $module.Name -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
            
            if (-not $installed) {
                $result.Success = $false
                $result.FailedChecks += "Module not installed: $($module.Name)"
                Write-PurviewLog "❌ Module not installed: $($module.Name)" -Level "ERROR"
            } elseif ($module.MinVersion -and $installed.Version -lt [Version]$module.MinVersion) {
                $result.Success = $false
                $result.FailedChecks += "Module version too low: $($module.Name) (installed: $($installed.Version), required: $($module.MinVersion))"
                Write-PurviewLog "❌ Module version too low: $($module.Name) v$($installed.Version) < v$($module.MinVersion)" -Level "ERROR"
            } else {
                Write-PurviewLog "✅ Module OK: $($module.Name) v$($installed.Version)" -Level "INFO"
            }
        }
    }
    
    # Test network connectivity
    if ($TestConnectivity) {
        $endpoints = @(
            "login.microsoftonline.com",
            "graph.microsoft.com",
            "outlook.office365.com"
        )
        
        foreach ($endpoint in $endpoints) {
            try {
                $testConnection = Test-NetConnection -ComputerName $endpoint -Port 443 -WarningAction SilentlyContinue
                if ($testConnection.TcpTestSucceeded) {
                    Write-PurviewLog "✅ Connectivity OK: $endpoint" -Level "INFO"
                } else {
                    $result.Success = $false
                    $result.FailedChecks += "Cannot connect to: $endpoint"
                    Write-PurviewLog "❌ Cannot connect to: $endpoint" -Level "ERROR"
                }
            } catch {
                $result.Success = $false
                $result.FailedChecks += "Connectivity test failed: $endpoint"
                Write-PurviewLog "❌ Connectivity test failed: $endpoint" -Level "ERROR"
            }
        }
    }
    
    if ($result.FailedChecks.Count -gt 0) {
        $result.Message = "Prerequisites not met: $($result.FailedChecks -join '; ')"
    }
    
    return $result
}

function Test-ModuleVersion {
    <#
    .SYNOPSIS
        Check if PowerShell module meets version requirement.
    
    .DESCRIPTION
        Validates that a specific module is installed and meets minimum version requirement.
    
    .PARAMETER ModuleName
        Name of the module to check
    
    .PARAMETER MinVersion
        Minimum required version
    
    .EXAMPLE
        Test-ModuleVersion -ModuleName "PnP.PowerShell" -MinVersion "1.12.0"
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        
        [Parameter(Mandatory = $false)]
        [string]$MinVersion
    )
    
    $installed = Get-Module -Name $ModuleName -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    
    $result = [PSCustomObject]@{
        ModuleName = $ModuleName
        Installed = $false
        InstalledVersion = $null
        MeetsRequirement = $false
        Message = ""
    }
    
    if (-not $installed) {
        $result.Message = "Module not installed"
        return $result
    }
    
    $result.Installed = $true
    $result.InstalledVersion = $installed.Version.ToString()
    
    if ($MinVersion) {
        if ($installed.Version -ge [Version]$MinVersion) {
            $result.MeetsRequirement = $true
            $result.Message = "Version OK: $($installed.Version) >= $MinVersion"
        } else {
            $result.MeetsRequirement = $false
            $result.Message = "Version too low: $($installed.Version) < $MinVersion"
        }
    } else {
        $result.MeetsRequirement = $true
        $result.Message = "Module installed: $($installed.Version)"
    }
    
    return $result
}

function Test-ServicePrincipal {
    <#
    .SYNOPSIS
        Validate service principal configuration.
    
    .DESCRIPTION
        Tests service principal authentication with certificate.
    
    .PARAMETER ClientId
        Service principal client ID
    
    .PARAMETER Thumbprint
        Certificate thumbprint
    
    .PARAMETER Tenant
        Tenant name (e.g., contoso.onmicrosoft.com)
    
    .PARAMETER TestUrl
        SharePoint URL to test connection
    
    .EXAMPLE
        Test-ServicePrincipal -ClientId "..." -Thumbprint "..." -Tenant "contoso.onmicrosoft.com" -TestUrl "https://contoso.sharepoint.com"
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ClientId,
        
        [Parameter(Mandatory = $true)]
        [string]$Thumbprint,
        
        [Parameter(Mandatory = $true)]
        [string]$Tenant,
        
        [Parameter(Mandatory = $false)]
        [string]$TestUrl
    )
    
    $result = [PSCustomObject]@{
        Success = $false
        Message = ""
        Details = @{}
    }
    
    Write-PurviewLog "Testing service principal configuration..." -Level "INFO"
    
    # Check if certificate exists
    $cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Thumbprint -eq $Thumbprint }
    if (-not $cert) {
        $result.Message = "Certificate not found: $Thumbprint"
        Write-PurviewLog "❌ $($result.Message)" -Level "ERROR"
        return $result
    }
    
    $result.Details.CertificateFound = $true
    $result.Details.CertificateExpiry = $cert.NotAfter
    Write-PurviewLog "✅ Certificate found (expires: $($cert.NotAfter))" -Level "INFO"
    
    # Test connection if URL provided
    if ($TestUrl) {
        try {
            Connect-PnPOnline -Url $TestUrl -ClientId $ClientId -Thumbprint $Thumbprint -Tenant $Tenant -ErrorAction Stop
            $web = Get-PnPWeb -ErrorAction Stop
            Disconnect-PnPOnline
            
            $result.Success = $true
            $result.Message = "Service principal authentication successful"
            $result.Details.TestConnection = "Success"
            $result.Details.ConnectedTo = $web.Url
            Write-PurviewLog "✅ Service principal authentication successful" -Level "INFO"
        } catch {
            $result.Success = $false
            $result.Message = "Service principal authentication failed: $_"
            $result.Details.TestConnection = "Failed"
            Write-PurviewLog "❌ Service principal authentication failed: $_" -Level "ERROR"
        }
    } else {
        $result.Success = $true
        $result.Message = "Certificate validation successful (connection not tested)"
    }
    
    return $result
}

function Confirm-PurviewOperation {
    <#
    .SYNOPSIS
        Get user confirmation for critical operations.
    
    .DESCRIPTION
        Prompts user for confirmation with clear messaging about operation impact.
    
    .PARAMETER Message
        Confirmation message
    
    .PARAMETER DefaultYes
        Default to Yes if user just presses Enter (default: $false)
    
    .PARAMETER ForcePrompt
        Always prompt even if running non-interactively
    
    .EXAMPLE
        if (Confirm-PurviewOperation -Message "Delete all test data?") {
            # Perform deletion
        }
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [switch]$DefaultYes,
        
        [Parameter(Mandatory = $false)]
        [switch]$ForcePrompt
    )
    
    # Check if running interactively
    if (-not $ForcePrompt -and -not [Environment]::UserInteractive) {
        Write-PurviewLog "Running non-interactively, assuming No" -Level "WARNING"
        return $false
    }
    
    $prompt = if ($DefaultYes) { "$Message (Y/n)" } else { "$Message (y/N)" }
    Write-Host "`n$prompt " -ForegroundColor Yellow -NoNewline
    
    $response = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($response)) {
        $confirmed = $DefaultYes
    } else {
        $confirmed = $response -match "^[Yy]"
    }
    
    $action = if ($confirmed) { "confirmed" } else { "declined" }
    Write-PurviewLog "User $action operation: $Message" -Level "INFO"
    
    return $confirmed
}
