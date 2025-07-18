
<#
.SYNOPSIS
    Creates an Azure Resource Group for Microsoft Sentinel deployment using Azure REST API.

.DESCRIPTION
    This script validates the target Azure subscription and creates a resource group if it doesn't exist.
    It performs comprehensive validation checks to ensure the subscription is accessible and the resource
    group name is available. The script uses Azure REST APIs directly for enhanced control and error handling.
    
    This is typically the first step in a Microsoft Sentinel infrastructure deployment pipeline,
    establishing the foundational resource container for security resources.

.PARAMETER SubscriptionID
    Azure subscription ID where the resource group will be created. Must be a valid GUID format.

.PARAMETER ResourceGroupName
    Name for the Azure resource group. Must follow Azure naming conventions and be unique within the subscription.

.PARAMETER Location
    Azure region where the resource group will be created (e.g., 'eastus', 'westeurope', 'southcentralus').

.EXAMPLE
    .\rg-deploy.ps1 -SubscriptionID "12345678-1234-1234-1234-123456789012" -ResourceGroupName "rg-sentinel-prod" -Location "eastus"
    
    Creates a resource group named 'rg-sentinel-prod' in the East US region.

.EXAMPLE
    .\rg-deploy.ps1 -SubscriptionID "87654321-4321-4321-4321-210987654321" -ResourceGroupName "rg-security-dev" -Location "westeurope"
    
    Creates a development resource group in the West Europe region.

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    System.String. Verbose output indicating validation and creation status.

.NOTES
    File Name      : rg-deploy.ps1
    Author         : Marcus Jacobson
    Prerequisite   : Azure CLI, PowerShell 5.1 or later
    Version        : 1.0
    Last Updated   : July 17, 2025
    
    Security Requirements:
    - User must be authenticated with appropriate permissions, or use a service principal with sufficient rights.
    - Service principal requires Contributor role at subscription or resource group level
    - Must have permissions to validate subscription details
    
    Dependencies:
    - Azure CLI (az)
    - PowerShell 5.1 or later
    - Network connectivity to Azure management endpoints

.LINK
    https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal
    https://docs.microsoft.com/en-us/azure/sentinel/
    https://docs.microsoft.com/en-us/azure/governance/policy/
    https://docs.microsoft.com/en-us/rest/api/resources/resource-groups
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "ID of the subscription to add the resource group to.")]
    [string]$SubscriptionID,

    [Parameter(Mandatory = $true,
        HelpMessage = "Display name for the resource group.")]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true,
        HelpMessage = "Location for the resource group deployment.")]
    [string]$Location
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

        # Build Body
        # ---------
        if ($body) {
            $tmpPath = Join-Path $PSScriptRoot ("REST-$method-{0}.json" -f (New-Guid))
            $body | Out-File -FilePath $tmpPath -Force

            $tmpPathValue = Get-Content -Path $tmpPath
            
            $inputObject += '--body', "@$tmpPath"
        }

        # Build Header
        # -----------
        if (-not $header) {
            $header = @{}
        }
        
        $compressedHeader = ConvertTo-Json $header -Depth 10 -Compress

        if ($compressedHeader.length -gt 2) {
            # non-empty
            $tmpPathHeader = Join-Path $PSScriptRoot ("REST-$method-header-{0}.json" -f (New-Guid))
            $compressedHeader | Out-File -FilePath $tmpPathHeader -Force

            $compressedHeaderValue = Get-Content -Path $tmpPathHeader

            $inputObject += '--headers', "@$tmpPathHeader"
        }

        # Execute
        # -------
        try {
            $rawResponse = az rest @inputObject -o json 2>&1
        }
        catch {
            $rawResponse = $_
        }

        if ($rawResponse.Exception) {
            $rawResponse = $rawResponse.Exception.Message
        }

        # Remove wrappers such as 'Conflict({...})' from the repsonse
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
        # Remove temp files
        if ((-not [String]::IsNullOrEmpty($tmpPathHeader)) -and (Test-Path $tmpPathHeader)) {
            Remove-item -Path $tmpPathHeader -Force
        }
        if ((-not [String]::IsNullOrEmpty($tmpPath)) -and (Test-Path $tmpPath)) {
            Remove-item -Path $tmpPath -Force
        }
    }
}


# Validate subscription ID
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking to confirm subscription ID exists..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI to query the subscription list
$uri = "https://management.azure.com/subscriptions/$($SubscriptionID)?api-version=2020-01-01"

# Define the object for the request
$subscriptionQueryObject = @{
    'method' = 'GET'
    'uri' = $uri
}

# Call the Invoke-RESTCommand function check the provided subscription ID
try {
    $response = Invoke-RESTCommand @subscriptionQueryObject

    # Check if the response contains the subscription 
    if ($response -and $response.subscriptionId -eq $SubscriptionID) {
        $subscriptionName = $response.displayName
        Write-Verbose "    Subscription ID [$($SubscriptionID)] exists with the name: [$($subscriptionName)]" -Verbose
    }
    else {
        Write-Error "    Subscription ID [$($SubscriptionID)] was not found."
    }
}
catch {
    Write-Error "Failed to retrieve subscription. Error: $($_.Exception.Message)"
}

# Checking if the resource group already exists
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking to ensure the resource group $($ResourceGroupName) does not already exist..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI to query the resource group
$uri = "https://management.azure.com/subscriptions/$($SubscriptionID)/resourceGroups/$($ResourceGroupName)?api-version=2020-06-01"

# Define the object for the request
$resourceGroupQueryObject = @{
    'method' = 'GET'
    'uri' = $uri
}

# Call the Invoke-RESTCommand function check the provided resource group name
try {
    $response = Invoke-RESTCommand @resourceGroupQueryObject

    # Check if the response contains the resource group
    if ($response -and $response.name -eq $ResourceGroupName) {
        Write-Verbose "    Resource group '$($ResourceGroupName)' already exists." -Verbose
        Write-Verbose "    Continuing with creation of Log Analytics Workspace in existing Resource Group [$($ResourceGroupName)]." -Verbose
    }
    else {
        Write-Verbose "    Resource group '$($ResourceGroupName)' does not exist. Continuing with resource group creation." -Verbose

        # Create the resource group
        Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
        Write-Verbose  "Creating the resource group $($ResourceGroupName)..." -Verbose
        Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

        # Define the URI to create the resource group
        $uri = "https://management.azure.com/subscriptions/$($SubscriptionID)/resourceGroups/$($ResourceGroupName)?api-version=2020-06-01"  

        # Define the body for the request
        $body = @{
            'location' = $Location
        } | ConvertTo-Json -Depth 10

        # Define the object for the request
        $resourceGroupCreateObject = @{
            'method' = 'PUT'
            'uri' = $uri
            'body' = $body
            'header' = @{
                'Content-Type' = 'application/json'
            }
        }

        # Call the Invoke-RESTCommand function to create the resource group
        try {
            $response = Invoke-RESTCommand @resourceGroupCreateObject

            # Check if the response contains the resource group
            if ($response -and $response.name -eq $ResourceGroupName) {
                Write-Verbose "    Resource group '$($ResourceGroupName)' created successfully." -Verbose
            }
            else {
                Write-Error "Failed to create resource group. Error: $($response | Out-String)"
            }
        }
        catch {
            Write-Error "Failed to create resource group. Error: $($_.Exception.Message)"
        }
    }
}
catch {
    Write-Error "Failed to retrieve resource group. Error: $($_.Exception.Message)"
}
                    


