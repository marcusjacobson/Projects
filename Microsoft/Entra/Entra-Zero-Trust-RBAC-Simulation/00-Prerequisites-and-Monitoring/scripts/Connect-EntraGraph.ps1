<#
.SYNOPSIS
    Connects to the Microsoft Graph PowerShell SDK with required scopes.

.DESCRIPTION
    This script handles the authentication to Microsoft Graph. It requests a comprehensive
    list of scopes required for the entire Entra Zero Trust RBAC Simulation project.
    It checks for an existing connection before attempting to connect.

.EXAMPLE
    .\Connect-EntraGraph.ps1

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-24
    Last Modified: 2025-11-24
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    
    Script development orchestrated using GitHub Copilot.

.SPECIALIZED_SECTION
    AUTHENTICATION SCOPES
    - User.Read.All (Directory reading)
    - RoleManagement.ReadWrite.Directory (RBAC management)
    - Policy.ReadWrite.ConditionalAccess (Security policies)
#>

[CmdletBinding()]
param()

begin {
    $Scopes = @(
        "User.Read.All",
        "Group.ReadWrite.All",
        "RoleManagement.ReadWrite.Directory",
        "AdministrativeUnit.ReadWrite.All",
        "Application.ReadWrite.All",
        "Policy.Read.All",
        "Policy.ReadWrite.AuthenticationMethod",
        "Policy.ReadWrite.ConditionalAccess",
        "IdentityRiskEvent.Read.All",
        "AuditLog.Read.All",
        "Directory.ReadWrite.All",
        "EntitlementManagement.ReadWrite.All",
        "AccessReview.ReadWrite.All",
        "LifecycleWorkflows.ReadWrite.All",
        "PrivilegedAccess.ReadWrite.AzureAD"
    )
}

process {
    Write-Verbose "Checking for existing Microsoft Graph connection..."
    
    try {
        $currentContext = Get-MgContext -ErrorAction Stop
        Write-Host "✅ Already connected to Microsoft Graph as $($currentContext.Account)" -ForegroundColor Green
        Write-Verbose "Scopes: $($currentContext.Scopes -join ', ')"
    }
    catch {
        Write-Host "🚀 Connecting to Microsoft Graph..." -ForegroundColor Cyan
        Connect-MgGraph -Scopes $Scopes -NoWelcome
        
        $currentContext = Get-MgContext
        if ($currentContext) {
            Write-Host "✅ Successfully connected as $($currentContext.Account)" -ForegroundColor Green
        }
        else {
            Write-Error "Failed to connect to Microsoft Graph."
        }
    }
}
