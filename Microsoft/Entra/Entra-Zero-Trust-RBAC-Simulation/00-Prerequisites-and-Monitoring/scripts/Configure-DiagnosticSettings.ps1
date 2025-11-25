<#
.SYNOPSIS
    Configures Entra ID Diagnostic Settings to stream logs to Log Analytics.

.DESCRIPTION
    Enables streaming of AuditLogs, SignInLogs, NonInteractiveUserSignInLogs, and 
    ServicePrincipalSignInLogs to the specified Log Analytics Workspace.

.PARAMETER WorkspaceId
    The full Azure Resource ID of the Log Analytics Workspace.
    Example: /subscriptions/123.../resourceGroups/rg.../providers/Microsoft.OperationalInsights/workspaces/law...

.EXAMPLE
    .\Configure-DiagnosticSettings.ps1 -WorkspaceId "/subscriptions/..."

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 00-Prerequisites-and-Monitoring
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceId
)

process {
    # Ensure Graph connection
    . "$PSScriptRoot\Connect-EntraGraph.ps1"

    Write-Host "🚀 Configuring Entra ID Diagnostic Settings..." -ForegroundColor Cyan

    $settingName = "Entra-Simulation-Diagnostics"
    
    # Define the logs to stream
    $logs = @(
        "AuditLogs",
        "SignInLogs",
        "NonInteractiveUserSignInLogs",
        "ServicePrincipalSignInLogs",
        "ManagedIdentitySignInLogs",
        "ProvisioningLogs",
        "RiskyUsers",
        "UserRiskEvents"
    )

    try {
        # Check if setting exists
        $existingSettings = Get-MgDiagnosticSetting -ErrorAction SilentlyContinue
        $targetSetting = $existingSettings | Where-Object { $_.Name -eq $settingName }

        if ($targetSetting) {
            Write-Host "⚠️  Diagnostic setting '$settingName' already exists." -ForegroundColor Yellow
            Write-Host "   To update it, please remove it manually in the portal or use Remove-MgDiagnosticSetting."
            return
        }

        # Construct the body for New-MgDiagnosticSetting
        # Note: The cmdlet parameters can be tricky, using the object-based approach is often more reliable for complex settings
        
        $params = @{
            Name = $settingName
            WorkspaceId = $WorkspaceId
            Logs = @()
        }

        foreach ($log in $logs) {
            $params.Logs += @{
                Category = $log
                Enabled = $true
                RetentionPolicy = @{
                    Enabled = $false
                    Days = 0
                }
            }
        }

        New-MgDiagnosticSetting -BodyParameter $params
        
        Write-Host "✅ Diagnostic Settings configured successfully." -ForegroundColor Green
        Write-Host "   Logs are now streaming to: $WorkspaceId"
    }
    catch {
        Write-Error "Failed to configure Diagnostic Settings: $_"
        Write-Host "   Note: This operation requires 'Monitor.Config' permissions or Global Admin." -ForegroundColor Yellow
    }
}
