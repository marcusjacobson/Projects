
<#
.SYNOPSIS
    Enables Microsoft Sentinel on an existing Log Analytics Workspace using Azure REST API.

.DESCRIPTION
    This script enables Microsoft Sentinel (Azure Sentinel) on a pre-existing Log Analytics Workspace.
    It validates the subscription, resource group, and workspace existence before enabling Sentinel.
    
    This script is typically executed after the Log Analytics Workspace deployment as part of a
    comprehensive Microsoft Sentinel infrastructure-as-code deployment pipeline.

.PARAMETER SubscriptionID
    Azure subscription ID containing the target Log Analytics Workspace. Must be a valid GUID format.

.PARAMETER ResourceGroupName
    Name of the resource group containing the Log Analytics Workspace where Sentinel will be enabled.

.PARAMETER Location
    Azure region where the Log Analytics Workspace is located (e.g., 'eastus', 'westeurope').

.PARAMETER LogAnalyticsWorkspaceName
    Name of the existing Log Analytics Workspace where Microsoft Sentinel will be enabled.

.PARAMETER CustomerManagedKey
    Boolean string indicating whether to use customer-managed keys for encryption ('true' or 'false').
    Default is 'false'. Note: CMK must be pre-configured on the Log Analytics Workspace.

.EXAMPLE
    .\deploy-sentinel.ps1 -SubscriptionID "12345678-1234-1234-1234-123456789012" -ResourceGroupName "rg-security" -Location "eastus" -LogAnalyticsWorkspaceName "law-sentinel" -CustomerManagedKey "false"
    
    Enables Microsoft Sentinel on the specified workspace with standard encryption.

.EXAMPLE
    .\deploy-sentinel.ps1 -SubscriptionID "87654321-4321-4321-4321-210987654321" -ResourceGroupName "rg-sentinel-prod" -Location "westus2" -LogAnalyticsWorkspaceName "law-sentinel-prod" -CustomerManagedKey "true"
    
    Enables Microsoft Sentinel with customer-managed key encryption (CMK must be pre-configured).

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    System.String. Verbose output indicating validation and enablement status.

.NOTES
    File Name      : deploy-sentinel.ps1
    Author         : Marcus Jacobson
    Prerequisite   : Azure CLI, PowerShell 5.1 or later, Existing Log Analytics Workspace
    Version        : 1.0
    Last Updated   : July 17, 2025
    
    Security Requirements:
    - User must be authenticated with appropriate permissions, or use a service principal with sufficient rights.
    - Service principal requires Microsoft Sentinel Contributor role
    - Log Analytics Workspace must exist and be accessible
    - For CMK: Customer-managed keys must be pre-configured on the workspace
    
    Dependencies:
    - Azure CLI (az)
    - PowerShell 5.1 or later
    - Existing Log Analytics Workspace
    - Network connectivity to Azure management endpoints

.LINK
    https://docs.microsoft.com/en-us/azure/sentinel/
    https://docs.microsoft.com/en-us/azure/sentinel/customer-managed-keys
    https://docs.microsoft.com/en-us/azure/azure-monitor/logs/
    https://docs.microsoft.com/en-us/rest/api/securityinsights/
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "ID of the subscription to deploy the VM to.")]
    [string]$SubscriptionID,

    [Parameter(Mandatory = $true,
        HelpMessage = "Display name for the target resource group.")]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true,
        HelpMessage = "Location for the public IP address deployment.")]
    [string]$Location,

    [Parameter(Mandatory = $true,
        HelpMessage = "Name for the Log Analytics Workspace.")]
    [string]$LogAnalyticsWorkspaceName,

    [Parameter(Mandatory = $false,
        HelpMessage = "Boolean value for whether Sentinel will be deployed with a customer managed key.")]
    [string]$CustomerManagedKey
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
function Convert-BicepToARMTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$BicepFilePath
    )

    try {
        # Compile the Bicep template into an ARM template and capture the output
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
        Write-Verbose "    Subscription ID '$SubscriptionID' exists with the name: $subscriptionName" -Verbose
        Write-Verbose "    Proceeding with the Log Analytics Workspace deployment..." -Verbose
    }
    else {
        Write-Error "    Subscription ID $($SubscriptionID) was not found."
    }
}
catch {
    Write-Error "Failed to retrieve subscription. Error: $($_.Exception.Message)"
}

# Validate Log Analytics Workspace
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking to confirm Log Analytics Workspace $($LogAnalyticsWorkspaceName) exists in the resource group $($ResourceGroupName)..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI to query all Log Analytics Workspaces in the resource group
$uri = "https://management.azure.com/subscriptions/$($SubscriptionID)/resourcegroups/$($ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces?api-version=2025-02-01"

$rgQueryObject = @{
    'method' = 'GET'
    'uri' = $uri
}

# Call the Invoke-RESTCommand function to checkLog Analytics Workspaces in the resource group
try {
    $response = Invoke-RESTCommand @rgQueryObject

    # Create an array of all Log Analytics Workspaces in the resource group
    $lawsInResourceGroup = $response.value | ForEach-Object { $_.name }

    if ($lawsInResourceGroup -contains $LogAnalyticsWorkspaceName) {
        Write-Verbose "    Log Analytics Workspace [$($LogAnalyticsWorkspaceName)] exists in the resource group [$($ResourceGroupName)]." -Verbose
        Write-Verbose "    Proceeding with the Sentinel deployment..." -Verbose
    }
    else {
        Write-Error "    Log Analytics Workspace [$($LogAnalyticsWorkspaceName)] does not exist in the resource group [$($ResourceGroupName)]." -Verbose
    }
}
catch {
    Write-Error "Failed to retrieve Log Analytics Workspaces in the resource group. Error: $($_.Exception.Message)"
}

# Validate Sentinel
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking existence of Sentinel deployment and previous Sentinel onboarding states..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI to check the Sentinel onboarding state
$onboardingStateUri = "https://management.azure.com/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($LogAnalyticsWorkspaceName)/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2025-03-01"

# Define the URI to check the Sentinel instance in the resource group
$sentinelInstanceUri = "https://management.azure.com/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.OperationsManagement/solutions?api-version=2015-11-01-preview"

# Check the Sentinel onboarding state
$onboardingStateObject = @{
    'method' = 'GET'
    'uri' = $onboardingStateUri
}

# Check the Sentinel instance in the resource group
$sentinelInstanceObject = @{
    'method' = 'GET'
    'uri' = $sentinelInstanceUri
}

# Check onboarding state
try {
    $onboardingStateResponse = Invoke-RESTCommand @onboardingStateObject

    # Determine if the onboarding state exists
    if ($onboardingStateResponse -and $onboardingStateResponse.error.code -eq "NotFound") {
        Write-Verbose "    No existing Sentinel onboarding state found for this Log Analytics Workspace." -Verbose
        $onboardingStateExists = $false
    }
    elseif ($onboardingStateResponse.id -eq "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($LogAnalyticsWorkspaceName)/providers/Microsoft.SecurityInsights/onboardingStates/default") {
        Write-Verbose "    Existing Sentinel onboarding state found for this Log Analytics Workspace." -Verbose
        $onboardingStateExists = $true
    }
    else {
        Write-Verbose "    Unknown error." -Verbose
        exit 1
    }
}
catch {
    Write-Error "Failed to validate Sentinel onboarding state. Error: $($_.Exception.Message)"
}

# Determine if the Sentinel instance exists
try {    
    $sentinelInstanceResponse = Invoke-RESTCommand @sentinelInstanceObject
    
    # Check if an object of type "Solution" (for the Sentinel instance) with the expected name exists within the resource group
    $expectedSolutionName = "SecurityInsights($($LogAnalyticsWorkspaceName))"

    # Check if the expected solution name matches the actual solution name
    if ($sentinelInstanceResponse.value.name -eq $expectedSolutionName) {
        Write-Verbose "    Sentinel instance (Solution) with name [$($expectedSolutionName)] already exists in the resource group [$($ResourceGroupName)]." -Verbose
        $sentinelSolutionExists = $true
    }
    else {
        Write-Verbose "    No Sentinel instance (Solution) with name [$($expectedSolutionName)] found in the resource group [$($ResourceGroupName)]." -Verbose
        $sentinelSolutionExists = $false
    }

}
catch {
    Write-Error "Failed to validate Sentinel deployment. Error: $($_.Exception.Message)"
}  


# Perform actions based on the existence of the Sentinel onboarding state and instance
if ($onboardingStateExists -and $sentinelSolutionExists) {
    Write-Verbose "        Skipping Sentinel deployment and exiting pipeline..." -Verbose
    Exit 1
}
elseif ($onboardingStateExists -and -not $sentinelSolutionExists) {
    # Perform cleanup of orphaned Sentinel onboarding state used in a previous deployment
    Write-Verbose "    Previously deployed Sentinel onboarding state exists without a Sentinel instance." -Verbose
    Write-Verbose "        Purging orphaned Sentinel onboarding state..." -Verbose
    
    # Define the URI to delete the previous Sentinel onboarding state
    $purgeUri = "https://management.azure.com/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($LogAnalyticsWorkspaceName)/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2025-03-01"

    # Define the object for the request
    $sentinelDeleteObject = @{
        'method' = 'DELETE'
        'uri' = $purgeUri
    }

    # Perform the REST API call to delete the orphaned Sentinel onboarding state
    try {
        # Ignore linter warning for the $deleteResponse variable on the following line. The variable is required to run the command, but there is no meaningful response to reference later.
        $deleteResponse = Invoke-RESTCommand @sentinelDeleteObject
        Write-Verbose "        Previous Sentinel onboarding state purged successfully." -Verbose
        Write-Verbose "        Proceeding with Sentinel deployment..." -Verbose
    }
    catch {
        Write-Error "        Failed to delete the previous Sentinel onboarding state. Error: $($_.Exception.Message)"
        Exit 1
    }
}
elseif (-not $onboardingStateExists -and -not $sentinelSolutionExists) {
    Write-Verbose "        Proceeding with Sentinel deployment..." -Verbose
}
else {
    Write-Error "Unexpected state: Onboarding state or Sentinel instance check returned inconsistent results."
}

# Onboard Sentinel
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Onboarding Sentinel for the Log Analytics Workspace $($LogAnalyticsWorkspaceName)..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI for the Sentinel onboarding state
$uri = "https://management.azure.com/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($LogAnalyticsWorkspaceName)/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2025-03-01"

# Create new Sentinel onboarding state for the Log Analytics Workspace
Write-Verbose "    Creating new Sentinel onboarding state for this Log Analytics Workspace..." -Verbose

# Define the request body
$body = @{
    properties = @{
        "customerManagedKey" = $CustomerManagedKey
    }
} | ConvertTo-Json -Depth 10

#Define the object for the request
$sentinelCreateObject = @{
    'method' = 'PUT'
    'uri' = $uri
    'body' = $body
    'header' = @{
        'Content-Type' = 'application/json'
    }
}

# Invoke the REST API to create Sentinel
$response = Invoke-RESTCommand @sentinelCreateObject

if ($response.error.code -eq "NotFound") {
    Write-Error "        Failed to deploy Sentinel to the Log Analytics Workspace $($LogAnalyticsWorkspaceName)." -Verbose
}
else {
    Write-Verbose "        Sentinel has been successfully deployed to the Log Analytics Workspace $($LogAnalyticsWorkspaceName)." -Verbose
}
