<#
.SYNOPSIS
    Deploys a Log Analytics Workspace for Entra ID monitoring using Azure REST API and Bicep.

.DESCRIPTION
    Creates a Resource Group and a Log Analytics Workspace in the specified Azure Subscription.
    Sets the data retention to 90 days to meet security baselines.
    Uses Azure REST API for deployment and Bicep for resource definition.

.PARAMETER UseParametersFile
    Switch to load parameters from 'module.parameters.json'.

.PARAMETER SubscriptionId
    The ID of the Azure Subscription where resources will be deployed.

.PARAMETER ResourceGroupName
    Name of the Resource Group to create. Default: 'rg-entra-simulation-monitor'

.PARAMETER WorkspaceName
    Name of the Log Analytics Workspace. Default: 'law-entra-simulation'

.PARAMETER Location
    Azure region for deployment. Default: 'EastUS'

.PARAMETER Sku
    Pricing tier for the Log Analytics Workspace. Default: 'PerGB2018'

.PARAMETER RetentionInDays
    Data retention period in days. Default: 90

.EXAMPLE
    .\Deploy-LogAnalytics.ps1 -UseParametersFile

.EXAMPLE
    .\Deploy-LogAnalytics.ps1 -SubscriptionId "00000000-0000-0000-0000-000000000000"

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-28
    Last Modified: 2025-11-28
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK
    - Azure CLI (az)
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Deploys a Log Analytics Workspace for Entra ID monitoring.
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile,

    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,

    [string]$ResourceGroupName,
    [string]$WorkspaceName,
    [string]$Location,
    [string]$Sku,
    [int]$RetentionInDays
)

function Convert-BicepToARMTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$BicepFilePath
    )

    try {
        $compiledTemplateContent = az bicep build --file $BicepFilePath --stdout
        if (-not $compiledTemplateContent) {
            throw "Failed to compile Bicep template. No output received from az bicep build."
        }
        return $compiledTemplateContent
    }
    catch {
        Write-Error "Failed to compile Bicep template. Error: $($_.Exception.Message)"
        throw
    }
}

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
        
        # Load Global Parameters
        if ($jsonParams.global) {
            if (-not $SubscriptionId -and $jsonParams.global.subscriptionId) { $SubscriptionId = $jsonParams.global.subscriptionId }
            if (-not $ResourceGroupName -and $jsonParams.global.resourceGroupName) { $ResourceGroupName = $jsonParams.global.resourceGroupName }
            if (-not $Location -and $jsonParams.global.location) { $Location = $jsonParams.global.location }
        }

        # Load Script-Specific Parameters
        if ($jsonParams."Deploy-LogAnalytics") {
            $scriptParams = $jsonParams."Deploy-LogAnalytics"
            if (-not $WorkspaceName -and $scriptParams.workspaceName) { $WorkspaceName = $scriptParams.workspaceName }
            if (-not $Sku -and $scriptParams.sku) { $Sku = $scriptParams.sku }
            if (-not $RetentionInDays -and $scriptParams.retentionInDays) { $RetentionInDays = $scriptParams.retentionInDays }
        }
    }
    else {
        Write-Warning "Parameters file not found at $jsonPath. Using provided parameters."
    }
}

# Validate required parameters
if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) { Throw "ResourceGroupName is required. Please provide it via parameter or use -UseParametersFile." }
if ([string]::IsNullOrWhiteSpace($WorkspaceName)) { Throw "WorkspaceName is required. Please provide it via parameter or use -UseParametersFile." }
if ([string]::IsNullOrWhiteSpace($Location)) { Throw "Location is required. Please provide it via parameter or use -UseParametersFile." }
if ([string]::IsNullOrWhiteSpace($Sku)) { Throw "Sku is required. Please provide it via parameter or use -UseParametersFile." }
if (-not $RetentionInDays) { Throw "RetentionInDays is required. Please provide it via parameter or use -UseParametersFile." }

if ([string]::IsNullOrWhiteSpace($SubscriptionId)) {
    Throw "SubscriptionId is required. Please provide it via parameter or module.parameters.json."
}

Write-Host "🚀 Starting Log Analytics Deployment..." -ForegroundColor Cyan
Write-Host "   Subscription ID: $SubscriptionId"
Write-Host "   Resource Group:  $ResourceGroupName"
Write-Host "   Workspace Name:  $WorkspaceName"
Write-Host "   Location:        $Location"

# Ensure Resource Group Exists
$rgUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourcegroups/$ResourceGroupName`?api-version=2021-04-01"
try {
    Invoke-RESTCommand -method 'GET' -uri $rgUri | Out-Null
    Write-Host "✅ Resource Group '$ResourceGroupName' already exists." -ForegroundColor Green
}
catch {
    Write-Host "Creating Resource Group '$ResourceGroupName'..." -ForegroundColor Cyan
    $rgBody = @{ location = $Location } | ConvertTo-Json
    Invoke-RESTCommand -method 'PUT' -uri $rgUri -body $rgBody -header @{ 'Content-Type' = 'application/json' } | Out-Null
    Write-Host "✅ Resource Group created." -ForegroundColor Green
}

# Deploy Log Analytics Workspace using Bicep
$bicepPath = Join-Path $PSScriptRoot "..\infra\logAnalytics.bicep"
if (-not (Test-Path $bicepPath)) {
    Throw "Bicep template not found at $bicepPath"
}

Write-Host "Compiling Bicep template..." -ForegroundColor Cyan
$armTemplateContent = Convert-BicepToARMTemplate -BicepFilePath $bicepPath
$armTemplateObject = $armTemplateContent | ConvertFrom-Json

$deploymentName = "deploy-law-$(Get-Date -Format 'yyyyMMddHHmm')"
$deployUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Resources/deployments/$deploymentName`?api-version=2021-04-01"

$deployBody = @{
    'properties' = @{
        'mode' = 'Incremental'
        'template' = $armTemplateObject
        'parameters' = @{
            'workspaceName' = @{ 'value' = $WorkspaceName }
            'location' = @{ 'value' = $Location }
            'sku' = @{ 'value' = $Sku }
            'retentionInDays' = @{ 'value' = $RetentionInDays }
        }
    }
} | ConvertTo-Json -Depth 10 -Compress

Write-Host "Deploying Log Analytics Workspace..." -ForegroundColor Cyan
try {
    $response = Invoke-RESTCommand -method 'PUT' -uri $deployUri -body $deployBody -header @{ 'Content-Type' = 'application/json' }
    
    if ($response.properties.provisioningState -eq 'Succeeded') {
        Write-Host "✅ Workspace deployed successfully." -ForegroundColor Green
    }
    elseif ($response.properties.provisioningState -eq 'Accepted' -or $response.properties.provisioningState -eq 'Running') {
        Write-Host "⏳ Deployment accepted. Waiting for completion..." -ForegroundColor Yellow
        
        $maxWait = 600
        $elapsed = 0
        $interval = 10
        
        while ($elapsed -lt $maxWait) {
            Start-Sleep -Seconds $interval
            $elapsed += $interval
            
            $status = Invoke-RESTCommand -method 'GET' -uri $deployUri
            if ($status.properties.provisioningState -eq 'Succeeded') {
                Write-Host "✅ Workspace deployed successfully." -ForegroundColor Green
                break
            }
            elseif ($status.properties.provisioningState -eq 'Failed') {
                Throw "Deployment failed: $($status | ConvertTo-Json -Depth 5)"
            }
        }
    }
}
catch {
    Throw "Deployment failed: $_"
}

# Retrieve Workspace ID for output
$lawUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName`?api-version=2022-10-01"
$law = Invoke-RESTCommand -method 'GET' -uri $lawUri

Write-Host "`n📋 Deployment Summary:" -ForegroundColor Cyan
Write-Host "   Resource Group:    $ResourceGroupName"
Write-Host "   Workspace Name:    $WorkspaceName"
Write-Host "   Azure Resource ID: $($law.id)" -ForegroundColor Yellow
Write-Host "   Workspace GUID:    $($law.properties.customerId)" -ForegroundColor Gray
Write-Host "`n⚠️  Copy the 'Azure Resource ID' if you need to configure Diagnostic Settings manually!" -ForegroundColor Cyan
