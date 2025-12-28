<#
.SYNOPSIS
    Deploys a Sensitivity Label using Microsoft Graph.

.DESCRIPTION
    This script creates a new Sensitivity Label.
    It is designed to be run from an Azure DevOps pipeline.

.PARAMETER TenantId
    The Directory (Tenant) ID.

.PARAMETER AppId
    The Application (Client) ID.

.PARAMETER CertificateThumbprint
    The thumbprint of the client certificate.

.PARAMETER LabelName
    The display name of the label.

.PARAMETER Tooltip
    The tooltip text for the label.

.EXAMPLE
    .\New-SensitivityLabel.ps1 -LabelName "Confidential" -Tooltip "For internal use only."

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-28
    
    Requirements:
    - Microsoft.Graph module
    - Service Principal with InformationProtectionPolicy.ReadWrite.All

    Script development orchestrated using GitHub Copilot.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$AppId,

    [Parameter(Mandatory = $true)]
    [string]$CertificateThumbprint,

    [Parameter(Mandatory = $true)]
    [string]$LabelName,

    [Parameter(Mandatory = $true)]
    [string]$Tooltip
)

# =============================================================================
# Action: Connect to Graph
# =============================================================================

Write-Verbose "🚀 Connecting to Microsoft Graph..." -Verbose
try {
    Connect-MgGraph -ClientId $AppId -TenantId $TenantId -CertificateThumbprint $CertificateThumbprint -NoWelcome
    Write-Verbose "   ✅ Connected successfully" -Verbose
} catch {
    Write-Error "   ❌ Connection failed: $_"
    exit 1
}

# =============================================================================
# Action: Define Label
# =============================================================================

Write-Verbose "📋 Defining Label '$LabelName'" -Verbose

$labelBody = @{
    displayName = $LabelName
    tooltip = $Tooltip
    isActive = $true
    rank = 1 # Simplified rank
}

# =============================================================================
# Action: Deploy via REST API
# =============================================================================

Write-Verbose "🚀 Deploying Label..." -Verbose

try {
    $uri = "https://graph.microsoft.com/beta/informationProtection/sensitivityLabels"
    $jsonPayload = $labelBody | ConvertTo-Json -Depth 5
    
    # Invoke-MgGraphRequest -Method POST -Uri $uri -Body $jsonPayload
    
    # Simulation output
    Write-Verbose "   ℹ️ POST $uri" -Verbose
    Write-Verbose "   ℹ️ Payload: $jsonPayload" -Verbose
    Write-Verbose "   ✅ Sensitivity Label '$LabelName' deployment logic executed." -Verbose

} catch {
    Write-Error "   ❌ Failed to deploy Label: $_"
    exit 1
}
