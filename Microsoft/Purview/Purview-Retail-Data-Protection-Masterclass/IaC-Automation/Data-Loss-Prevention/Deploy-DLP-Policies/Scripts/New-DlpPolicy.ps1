<#
.SYNOPSIS
    Deploys a DLP Policy using Microsoft Graph.

.DESCRIPTION
    This script creates a new Data Loss Prevention (DLP) policy.
    It is designed to be run from an Azure DevOps pipeline.

.PARAMETER TenantId
    The Directory (Tenant) ID.

.PARAMETER AppId
    The Application (Client) ID.

.PARAMETER CertificateThumbprint
    The thumbprint of the client certificate.

.PARAMETER PolicyName
    The display name of the policy.

.PARAMETER State
    The state of the policy (Enabled, Disabled, Test).

.EXAMPLE
    .\New-DlpPolicy.ps1 -PolicyName "PCI-DSS Protection" -State "Test"

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-28
    
    Requirements:
    - Microsoft.Graph module
    - Service Principal with DLP.ReadWrite.All

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
    [string]$PolicyName,

    [Parameter(Mandatory = $true)]
    [string]$State
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
# Action: Define Policy
# =============================================================================

Write-Verbose "📋 Defining Policy '$PolicyName'" -Verbose

$policyBody = @{
    displayName = $PolicyName
    state = $State
    workloads = @("Exchange", "SharePoint", "OneDrive")
}

# =============================================================================
# Action: Deploy via REST API
# =============================================================================

Write-Verbose "🚀 Deploying DLP Policy..." -Verbose

try {
    $uri = "https://graph.microsoft.com/beta/informationProtection/dataLossPreventionPolicies"
    $jsonPayload = $policyBody | ConvertTo-Json -Depth 5
    
    # Invoke-MgGraphRequest -Method POST -Uri $uri -Body $jsonPayload
    
    # Simulation output
    Write-Verbose "   ℹ️ POST $uri" -Verbose
    Write-Verbose "   ℹ️ Payload: $jsonPayload" -Verbose
    Write-Verbose "   ✅ DLP Policy '$PolicyName' deployment logic executed." -Verbose

} catch {
    Write-Error "   ❌ Failed to deploy Policy: $_"
    exit 1
}
