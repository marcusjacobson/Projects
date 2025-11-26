<#
.SYNOPSIS
    Validates the environment setup for Lab 00.

.DESCRIPTION
    Checks if the Log Analytics Workspace exists and if Diagnostic Settings are active.
    Uses Azure CLI (az rest) for validation to ensure consistency with deployment scripts.

.PARAMETER SubscriptionId
    The ID of the Azure Subscription used for deployment.

.PARAMETER ResourceGroupName
    Name of the Resource Group.

.PARAMETER WorkspaceName
    Name of the Log Analytics Workspace.

.PARAMETER UseParametersFile
    Switch to load parameters from ../infra/module.parameters.json.

.EXAMPLE
    .\Validate-Prerequisites.ps1 -UseParametersFile

.EXAMPLE
    .\Validate-Prerequisites.ps1 -SubscriptionId "..."

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 00-Prerequisites-and-Monitoring
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$WorkspaceName,

    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile
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

# Load parameters from file if requested
if ($UseParametersFile) {
    $paramsPath = Join-Path $PSScriptRoot "..\infra\module.parameters.json"
    if (Test-Path $paramsPath) {
        Write-Host "📂 Loading parameters from $paramsPath..." -ForegroundColor Cyan
        $jsonParams = Get-Content $paramsPath | ConvertFrom-Json
        
        # Load Global Parameters
        if ($jsonParams.global) {
            if (-not $SubscriptionId) { $SubscriptionId = $jsonParams.global.subscriptionId }
            if (-not $ResourceGroupName) { $ResourceGroupName = $jsonParams.global.resourceGroupName }
        }

        # Load Workspace Name from Deploy-LogAnalytics section
        if ($jsonParams."Deploy-LogAnalytics") {
            if (-not $WorkspaceName) { $WorkspaceName = $jsonParams."Deploy-LogAnalytics".workspaceName }
        }
    } else {
        Throw "Parameters file not found at $paramsPath"
    }
}

# Validate required parameters
if (-not $SubscriptionId) { Throw "Parameter -SubscriptionId is required (or use -UseParametersFile)." }
if (-not $ResourceGroupName) { Throw "Parameter -ResourceGroupName is required (or use -UseParametersFile)." }
if (-not $WorkspaceName) { Throw "Parameter -WorkspaceName is required (or use -UseParametersFile)." }

Write-Host "🔍 Starting Validation..." -ForegroundColor Cyan
Write-Host "   Subscription: $SubscriptionId"
Write-Host "   Resource Group: $ResourceGroupName"
Write-Host "   Workspace: $WorkspaceName"

# 0. Validate Azure CLI Connection (Required for az rest)
Write-Host "🔍 Checking Azure CLI context..." -ForegroundColor Cyan
try {
    $azContext = az account show -o json 2>$null | ConvertFrom-Json
    if ($azContext) {
        Write-Host "✅ Azure CLI session active for subscription: $($azContext.name)" -ForegroundColor Green
    } else {
        throw "No context"
    }
}
catch {
    Write-Warning "Azure CLI session not found or expired."
    $response = Read-Host "Do you want to login to Azure CLI now? (Y/N)"
    if ($response -eq 'Y') {
        az login
    } else {
        Throw "Azure CLI login is required for validation."
    }
}

# 0.1 Validate Graph Connection (Prerequisite for future labs)
if (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication) {
    $mgContext = Get-MgContext -ErrorAction SilentlyContinue
    if (-not $mgContext) {
        Write-Warning "Microsoft Graph connection not found."
        $response = Read-Host "Do you want to run Connect-EntraGraph.ps1 now? (Y/N)"
        if ($response -eq 'Y') {
            . "$PSScriptRoot\Connect-EntraGraph.ps1"
        } else {
            Write-Warning "Graph connection is required for subsequent labs."
        }
    } else {
        Write-Host "✅ Using existing Microsoft Graph session." -ForegroundColor Green
    }
}

# 1. Validate Log Analytics Workspace
$lawUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName`?api-version=2022-10-01"

try {
    $law = Invoke-RESTCommand -method 'GET' -uri $lawUri
    Write-Host "✅ Log Analytics Workspace found." -ForegroundColor Green
    
    if ($law.properties.retentionInDays -eq 90) {
        Write-Host "✅ Retention is set to 90 days." -ForegroundColor Green
    } else {
        Write-Host "❌ Retention is set to $($law.properties.retentionInDays) days (Expected: 90)." -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Log Analytics Workspace not found or not accessible." -ForegroundColor Red
    Write-Verbose $_
}

# 2. Validate Entra Diagnostic Settings
$settingName = "Entra-Simulation-Diagnostics"
$diagUri = "https://management.azure.com/providers/microsoft.aadiam/diagnosticSettings/$settingName`?api-version=2017-04-01"

try {
    $simSetting = Invoke-RESTCommand -method 'GET' -uri $diagUri
    Write-Host "✅ Diagnostic Setting '$settingName' found." -ForegroundColor Green
    
    # Check if logs are enabled
    $auditLog = $simSetting.properties.logs | Where-Object { $_.category -eq "AuditLogs" }
    if ($auditLog.enabled) {
        Write-Host "✅ AuditLogs streaming is ENABLED." -ForegroundColor Green
    } else {
        Write-Host "❌ AuditLogs streaming is DISABLED." -ForegroundColor Red
    }

    $signInLog = $simSetting.properties.logs | Where-Object { $_.category -eq "SignInLogs" }
    if ($signInLog.enabled) {
        Write-Host "✅ SignInLogs streaming is ENABLED." -ForegroundColor Green
    } else {
        Write-Host "❌ SignInLogs streaming is DISABLED." -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Diagnostic Setting '$settingName' NOT found." -ForegroundColor Red
    Write-Verbose $_
}
