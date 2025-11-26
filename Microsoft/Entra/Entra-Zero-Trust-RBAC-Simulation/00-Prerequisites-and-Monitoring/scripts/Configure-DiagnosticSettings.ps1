<#
.SYNOPSIS
    Configures Entra ID Diagnostic Settings to stream logs to Log Analytics using Azure REST API.

.DESCRIPTION
    Enables streaming of AuditLogs, SignInLogs, NonInteractiveUserSignInLogs, and 
    ServicePrincipalSignInLogs to the specified Log Analytics Workspace.
    Uses Azure REST API for configuration.

.PARAMETER UseParametersFile
    Switch to load parameters from 'module.parameters.json'.

.PARAMETER WorkspaceId
    The full Azure Resource ID of the Log Analytics Workspace.
    If not provided, the script attempts to resolve it using WorkspaceName and ResourceGroupName from parameters.

.PARAMETER SettingName
    The name of the diagnostic setting. Default: 'Entra-Simulation-Diagnostics'

.EXAMPLE
    .\Configure-DiagnosticSettings.ps1 -UseParametersFile

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 00-Prerequisites-and-Monitoring
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile,

    [Parameter(Mandatory = $false)]
    [string]$WorkspaceId,

    [Parameter(Mandatory = $false)]
    [string]$SettingName
)

function Invoke-RESTCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $method,

        [Parameter(Mandatory = $true)]
        [string] $uri,

        [Parameter(Mandatory = $false)]
        [string] $body,

        [Parameter(Mandatory = $false)]
        [hashtable] $header
    )

    try {
        $inputObject = @(
            '--method', $method,
            '--uri', $uri
        )

        if ($body) {
            $tmpPath = Join-Path $PSScriptRoot ("REST-$method-{0}.json" -f (New-Guid))
            $body | Out-File -FilePath $tmpPath -Force
            $inputObject += '--body', "@$tmpPath"
        }

        if (-not $header) {
            $header = @{}
        }
        
        $compressedHeader = ConvertTo-Json $header -Depth 10 -Compress
        if ($compressedHeader.length -gt 2) {
            $tmpPathHeader = Join-Path $PSScriptRoot ("REST-$method-header-{0}.json" -f (New-Guid))
            $compressedHeader | Out-File -FilePath $tmpPathHeader -Force
            $inputObject += '--headers', "@$tmpPathHeader"
        }

        $rawResponse = az rest @inputObject -o json 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw $rawResponse
        }

        if ($rawResponse.Exception) {
            $rawResponse = $rawResponse.Exception.Message
        }

        if (($rawResponse -is [string]) -and $rawResponse -match '^[a-zA-Z].+?\((.*)\)$') {
            if ($Matches.count -gt 0) {
                $rawResponse = $Matches[1]
            }
        }
        if ($rawResponse) {
            if (Test-Json ($rawResponse | Out-String) -ErrorAction 'SilentlyContinue') {
                return (($rawResponse | Out-String) | ConvertFrom-Json)
            }
            else {
                return $rawResponse
            }
        }
    }
    catch {
        throw $_
    }
    finally {
        if ((-not [String]::IsNullOrEmpty($tmpPathHeader)) -and (Test-Path $tmpPathHeader)) {
            Remove-item -Path $tmpPathHeader -Force
        }
        if ((-not [String]::IsNullOrEmpty($tmpPath)) -and (Test-Path $tmpPath)) {
            Remove-item -Path $tmpPath -Force
        }
    }
}

# Load parameters from JSON file if switch is used
if ($UseParametersFile) {
    $jsonPath = Join-Path $PSScriptRoot "..\infra\module.parameters.json"
    if (Test-Path $jsonPath) {
        $jsonParams = Get-Content $jsonPath | ConvertFrom-Json
        
        # Load Global Parameters (for resolving WorkspaceId if needed)
        if ($jsonParams.global) {
            if (-not $SubscriptionId -and $jsonParams.global.subscriptionId) { $SubscriptionId = $jsonParams.global.subscriptionId }
            if (-not $ResourceGroupName -and $jsonParams.global.resourceGroupName) { $ResourceGroupName = $jsonParams.global.resourceGroupName }
        }

        # Load Script-Specific Parameters
        if ($jsonParams."Configure-DiagnosticSettings") {
            $scriptParams = $jsonParams."Configure-DiagnosticSettings"
            if (-not $SettingName -and $scriptParams.settingName) { $SettingName = $scriptParams.settingName }
        }
        
        # Load Workspace Name from Deploy-LogAnalytics section if needed
        if (-not $WorkspaceId -and $jsonParams."Deploy-LogAnalytics") {
             $WorkspaceName = $jsonParams."Deploy-LogAnalytics".workspaceName
        }
    }
    else {
        Write-Warning "Parameters file not found at $jsonPath. Using provided parameters."
    }
}

# Set defaults
if (-not $SettingName) { $SettingName = "Entra-Simulation-Diagnostics" }

# Resolve WorkspaceId if not provided
if (-not $WorkspaceId) {
    if ($SubscriptionId -and $ResourceGroupName -and $WorkspaceName) {
        Write-Host "Resolving Workspace ID for '$WorkspaceName' in '$ResourceGroupName'..." -ForegroundColor Cyan
        $lawUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName`?api-version=2022-10-01"
        try {
            $law = Invoke-RESTCommand -method 'GET' -uri $lawUri
            $WorkspaceId = $law.id
            Write-Host "✅ Resolved Workspace ID: $WorkspaceId" -ForegroundColor Green
        }
        catch {
            Throw "Failed to resolve Workspace ID. Ensure the workspace exists and parameters are correct."
        }
    }
    else {
        Throw "WorkspaceId is required. Provide it directly or ensure SubscriptionId, ResourceGroupName, and WorkspaceName are available in parameters."
    }
}

Write-Host "🚀 Configuring Entra ID Diagnostic Settings..." -ForegroundColor Cyan
Write-Host "   Setting Name: $SettingName"
Write-Host "   Target Workspace: $WorkspaceId"

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

# Construct Body for Diagnostic Setting
$diagBodyObj = @{
    properties = @{
        workspaceId = $WorkspaceId
        logs = @()
    }
}

foreach ($log in $logs) {
    $diagBodyObj.properties.logs += @{
        category = $log
        enabled = $true
        retentionPolicy = @{
            enabled = $false
            days = 0
        }
    }
}

$diagBody = $diagBodyObj | ConvertTo-Json -Depth 10

# Diagnostic Settings URI for Entra ID (aadiam)
$diagUri = "https://management.azure.com/providers/microsoft.aadiam/diagnosticSettings/$SettingName`?api-version=2017-04-01"

try {
    # Check if setting exists
    try {
        Invoke-RESTCommand -method 'GET' -uri $diagUri | Out-Null
        Write-Host "⚠️  Diagnostic setting '$SettingName' already exists. Updating..." -ForegroundColor Yellow
    }
    catch {
        Write-Host "Creating new Diagnostic Setting..." -ForegroundColor Cyan
    }

    # Create or Update
    Invoke-RESTCommand -method 'PUT' -uri $diagUri -body $diagBody -header @{ 'Content-Type' = 'application/json' } | Out-Null
    
    Write-Host "✅ Diagnostic Settings configured successfully." -ForegroundColor Green
    Write-Host "   Logs are now streaming to: $WorkspaceId"
}
catch {
    Write-Error "Failed to configure Diagnostic Settings: $_"
    Write-Host "   Note: This operation requires 'Global Admin' or 'Security Admin' roles." -ForegroundColor Yellow
}

