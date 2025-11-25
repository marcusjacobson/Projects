<#
.SYNOPSIS
    Validates the environment setup for Lab 00.

.DESCRIPTION
    Checks if the Log Analytics Workspace exists and if Diagnostic Settings are active.

.PARAMETER SubscriptionId
    The ID of the Azure Subscription used for deployment.

.PARAMETER ResourceGroupName
    Name of the Resource Group. Default: 'rg-entra-simulation-monitor'

.PARAMETER WorkspaceName
    Name of the Log Analytics Workspace. Default: 'law-entra-simulation'

.EXAMPLE
    .\Validate-Prerequisites.ps1 -SubscriptionId "..."

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 00-Prerequisites-and-Monitoring
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [string]$ResourceGroupName = "rg-entra-simulation-monitor",
    [string]$WorkspaceName = "law-entra-simulation"
)

process {
    Write-Host "🔍 Starting Validation..." -ForegroundColor Cyan

    # 1. Validate Azure Resources
    if (Get-Module -ListAvailable -Name Az.Accounts) {
        try {
            Connect-AzAccount -Subscription $SubscriptionId -ErrorAction SilentlyContinue | Out-Null
            $law = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -ErrorAction SilentlyContinue
            
            if ($law) {
                Write-Host "✅ Log Analytics Workspace found." -ForegroundColor Green
                if ($law.RetentionInDays -eq 90) {
                    Write-Host "✅ Retention is set to 90 days." -ForegroundColor Green
                } else {
                    Write-Host "❌ Retention is set to $($law.RetentionInDays) days (Expected: 90)." -ForegroundColor Red
                }
            } else {
                Write-Host "❌ Log Analytics Workspace not found." -ForegroundColor Red
            }
        }
        catch {
            Write-Host "⚠️  Could not validate Azure resources (Az module error)." -ForegroundColor Yellow
        }
    }

    # 2. Validate Entra Diagnostic Settings
    . "$PSScriptRoot\Connect-EntraGraph.ps1"
    
    try {
        $settings = Get-MgDiagnosticSetting -ErrorAction SilentlyContinue
        $simSetting = $settings | Where-Object { $_.Name -eq "Entra-Simulation-Diagnostics" }

        if ($simSetting) {
            Write-Host "✅ Diagnostic Setting 'Entra-Simulation-Diagnostics' found." -ForegroundColor Green
            
            # Check if logs are enabled
            $auditLog = $simSetting.Logs | Where-Object { $_.Category -eq "AuditLogs" }
            if ($auditLog.Enabled) {
                Write-Host "✅ AuditLogs streaming is ENABLED." -ForegroundColor Green
            } else {
                Write-Host "❌ AuditLogs streaming is DISABLED." -ForegroundColor Red
            }
        } else {
            Write-Host "❌ Diagnostic Setting 'Entra-Simulation-Diagnostics' NOT found." -ForegroundColor Red
        }
    }
    catch {
        Write-Error "Failed to check Diagnostic Settings: $_"
    }
}
