
<#
.SYNOPSIS
    Deploys a Log Analytics Workspace for Microsoft Sentinel using Azure REST API and Bicep templates.

.DESCRIPTION
    This script automates the deployment of a Log Analytics Workspace as the foundation for Microsoft Sentinel.
    It validates the target subscription and resource group, checks for existing workspace conflicts,
    compiles Bicep templates to ARM, and deploys the workspace using Azure REST APIs.
    
    The script includes comprehensive error handling, deployment status monitoring, and follows
    infrastructure-as-code best practices for enterprise security deployments.

.PARAMETER DeploymentName
    Name for the Azure Resource Manager deployment. Used for tracking and management purposes.

.PARAMETER LawBicepTemplatePath
    Full path to the Bicep template file that defines the Log Analytics Workspace configuration.

.PARAMETER SubscriptionID
    Azure subscription ID where the Log Analytics Workspace will be deployed. Must be a valid GUID.

.PARAMETER ResourceGroupName
    Name of the target resource group that will contain the Log Analytics Workspace.

.PARAMETER Location
    Azure region where the Log Analytics Workspace will be deployed (e.g., 'eastus', 'westeurope').

.PARAMETER WorkspaceName
    Display name for the Log Analytics Workspace. Must be unique within the resource group.

.PARAMETER RetentionInDays
    Data retention period in days for the Log Analytics Workspace. Affects cost and compliance.

.PARAMETER Sku
    Pricing tier for the Log Analytics Workspace (e.g., 'Free', 'PerGB2018', 'CapacityReservation').

.EXAMPLE
    .\deploy-log-analytics-sentinel.ps1 -DeploymentName "law-deployment-001" -LawBicepTemplatePath ".\template.bicep" -SubscriptionID "12345678-1234-1234-1234-123456789012" -ResourceGroupName "rg-security" -Location "eastus" -WorkspaceName "law-sentinel" -RetentionInDays 90 -Sku "PerGB2018"
    
    Deploys a Log Analytics Workspace with 90-day retention using the PerGB2018 pricing tier.

.EXAMPLE
    .\deploy-log-analytics-sentinel.ps1 -DeploymentName "law-prod-deployment" -LawBicepTemplatePath "C:\templates\law.bicep" -SubscriptionID "87654321-4321-4321-4321-210987654321" -ResourceGroupName "rg-sentinel-prod" -Location "westus2" -WorkspaceName "law-sentinel-prod" -RetentionInDays 365 -Sku "CapacityReservation"
    
    Deploys a production Log Analytics Workspace with extended retention and capacity reservation pricing.

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    System.String. Verbose output indicating deployment status and results.

.NOTES
    File Name      : deploy-log-analytics-sentinel.ps1
    Author         : Marcus Jacobson
    Prerequisite   : Azure CLI, PowerShell 5.1 or later, Bicep CLI
    Version        : 1.0
    Last Updated   : July 17, 2025
    
    Security Requirements:
    - User must be authenticated with appropriate permissions, or use a service principal with sufficient rights.
    - Service principal requires Log Analytics Contributor role
    - Bicep CLI must be installed and accessible
    
    Dependencies:
    - Azure CLI (az)
    - Bicep CLI (az bicep)
    - PowerShell 5.1 or later
    - Valid Bicep template file
    
    Script development orchestrated using GitHub Copilot.

.PIPELINE OPERATIONS
    - Resource Group Validation
    - Workspace Existence Check
    - Bicep Template Compilation
    - REST API Deployment
    - Deployment Status Monitoring

.LINK
    https://docs.microsoft.com/en-us/azure/sentinel/
    https://docs.microsoft.com/en-us/azure/azure-monitor/logs/
    https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/
    https://docs.microsoft.com/en-us/rest/api/loganalytics/
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "Name for the REST API deployment.")]
    [string]$DeploymentName,

    [Parameter(Mandatory = $true,
        HelpMessage = "Path to BICEP file to create Log Analytics Workspace.")]
    [string]$LawBicepTemplatePath,
    
    [Parameter(Mandatory = $true,
        HelpMessage = "ID of the subscription to deploy the VM to.")]
    [string]$SubscriptionID,

    [Parameter(Mandatory = $true,
        HelpMessage = "Display name for the target resource group.")]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true,
        HelpMessage = "Location for the public IP address deployment.")]
    [string]$Location,

    [Parameter(Mandatory = $false,
        HelpMessage = "Display name for the Log Analytics Workspace.")]
    [string]$WorkspaceName,

    [Parameter(Mandatory = $false,
        HelpMessage = "The amount of retention days for data within the workspace.")]
    [int]$RetentionInDays,

    [Parameter(Mandatory = $false,
        HelpMessage = "Type of Log Analytics Workspace SKU.")]
    [string]$Sku
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

# Validate if the Log Analytics Workspace already exists
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking if the Log Analytics Workspace [$($WorkspaceName)] already exists in the subscription & resource group..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

$lawExistsInSubscription = $false
$lawExistsInResourceGroup = $false

# Define the URI to query all Log Analytics Workspaces in the subscription
$uri = "https://management.azure.com/subscriptions/$($SubscriptionID)/providers/Microsoft.OperationalInsights/workspaces?api-version=2025-02-01"


# Define the object for the request
$subscriptionQueryObject = @{
    'method' = 'GET'
    'uri' = $uri
}

Write-Verbose "    Checking if Log Analytics Workspace [$($WorkspaceName)] exists in subscription [$($subscriptionName)]..." -Verbose
# Call the Invoke-RESTCommand function to check Log Analytics Workspaces in the subscription
try {
    $response = Invoke-RESTCommand @subscriptionQueryObject

    # Create an array of all VNet names in the subscription
    $lawsInSubscription = $response.value | ForEach-Object { $_.name }

    if ($lawsInSubscription -contains $WorkspaceName) {
        Write-Verbose "        Log Analytics Workspace [$($WorkspaceName)] already exists within the subscription." -Verbose
        $lawExistsInSubscription = $true
    }
    else {
        Write-Verbose "        Log Analytics Workspace [$($WorkspaceName)] does not exist in the subscription [$($subscriptionName)]." -Verbose
    }
}
catch {
    Write-Error "Failed to retrieve Log Analytics Workspaces in the subscription. Error: $($_.Exception.Message)"
}

Write-Verbose "    Checking if Log Analytics Workspace [$($WorkspaceName)] exists in the resource group [$($ResourceGroupName)]..." -Verbose

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

    if ($lawsInResourceGroup -contains $WorkspaceName) {
        Write-Verbose "        Log Analytics Workspace [$($WorkspaceName)] already exists in the resource group [$($ResourceGroupName)]." -Verbose
        $lawExistsInResourceGroup = $true
    }
    else {
        Write-Verbose "        Log Analytics Workspace [$($WorkspaceName)] does not exist in the resource group [$($ResourceGroupName)]." -Verbose
        Write-Verbose "        Proceeding with the Log Analytics Workspace deployment..." -Verbose
    }
}
catch {
    Write-Error "Failed to retrieve Log Analytics Workspaces in the resource group. Error: $($_.Exception.Message)"
}

# Take action based on the existence of the Log Analytics Workspace
# Exit the pipeline if the workspace exists in the subscription but in a different resource group
if ($lawExistsInSubscription -eq $true -and $lawExistsInResourceGroup -eq $false) {
    Write-Error "Log Analytics Workspace [$($WorkspaceName)] already exists in the subscription [$($subscriptionName)] but in a different resource group."
    exit 1
}
# If the workspace does not exist in the resource group, proceed to create it
elseif ($lawExistsInResourceGroup -eq $false) {
    # Create the Log Analytics Workspace in the resource group
    Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
    Write-Verbose  "Creating the [$($WorkspaceName)] in the resource group [$($ResourceGroupName)]..." -Verbose
    Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

    # Convert the Bicep template to an ARM template
    $armTemplateContent = Convert-BicepToARMTemplate -BicepFilePath $LawBicepTemplatePath

    # Parse the ARM template content into a PowerShell object
    $armTemplateObject = $armTemplateContent | ConvertFrom-Json

    # Define the URI to create the Log Analytics Workspace in the resource group
    $uri = "https://management.azure.com/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.Resources/deployments/$($DeploymentName)?api-version=2021-04-01"

    # Create the body for the Log Analytics Workspace deployment
    $body = @{
        'properties' = @{
            'mode' = 'Incremental'
            'template' = $armTemplateObject
            'parameters' = @{
                'location' = @{
                    'value' = $Location
                }
                'workspaceName' = @{
                    'value' = $WorkspaceName
                }
                'retentionInDays' = @{
                    'value' = $RetentionInDays
                }
                'sku' = @{
                    'value' = $Sku
                }
            }
        }
    } | ConvertTo-Json -Depth 10 -Compress

    # Define the object for the request
    $lawCreateObject = @{
        'method' = 'PUT'
        'uri' = $uri
        'body' = $body
        'header' = @{
            'Content-Type' = 'application/json'
        }
    }

    # Call the Invoke-RESTCommand function to create the Log Analytics Workspace in the resource group
    try {
        $response = Invoke-RESTCommand @lawCreateObject

        # Check if the response indicates success
        if ($response -and $response.properties -and $response.properties.provisioningState -eq 'Succeeded') {
            Write-Verbose "        Log Analytics Workspace [$($WorkspaceName)] created successfully in resource group [$($ResourceGroupName)]." -Verbose
        }
        elseif ($response -and $response.properties -and $response.properties.provisioningState -eq 'Accepted') {
            Write-Verbose "        Log Analytics Workspace [$($WorkspaceName)] deployment is in progress in resource group [$($ResourceGroupName)]." -Verbose
            Write-Verbose "            Waiting for the deployment to complete..." -Verbose

            # Wait loop
            $maxWaitTime = 600 # Maximum wait time in seconds (10 minutes)
            $pollingInterval = 15 # Polling interval in seconds
            $elapsedTime = 0
            $deploymentSucceeded = $false

            while ($elapsedTime -lt $maxWaitTime) {
                Start-Sleep -Seconds $pollingInterval
                $elapsedTime += $pollingInterval

                # Check the deployment status
                $deploymentStatusUri = "https://management.azure.com/subscriptions/$($SubscriptionID)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.Resources/deployments/$($DeploymentName)?api-version=2021-04-01"
                $statusResponse = Invoke-RESTCommand -method 'GET' -uri $deploymentStatusUri

                if ($statusResponse -and $statusResponse.properties -and $statusResponse.properties.provisioningState -eq 'Succeeded') {
                    Write-Verbose "        Log Analytics Workspace [$($WorkspaceName)] deployment completed successfully." -Verbose
                    Write-Verbose "        Proceeding with Sentinel creation..." -Verbose
                    $deploymentSucceeded = $true
                    break
                }
                elseif ($statusResponse -and $statusResponse.properties -and $statusResponse.properties.provisioningState -eq 'Failed') {
                    Write-Error "       Log Analytics Workspace [$($WorkspaceName)] deployment failed. Response: $($statusResponse | ConvertTo-Json -Depth 10)"
                    break
                }
                else {
                    Write-Verbose "            Deployment still in progress. Elapsed time: $elapsedTime seconds." -Verbose
                }
            }

            if (-not $deploymentSucceeded) {
                Write-Error "       Log Analytics Workspace [$($WorkspaceName)] deployment did not complete within the maximum wait time of $maxWaitTime seconds."
            }
        }
        else {
            Write-Error "Failed to create Log Analytics Workspace. Response: $($response | ConvertTo-Json -Depth 10)"
        }
    }
    catch {
        Write-Error "Failed to create Public IP. Error: $($_.Exception.Message)"
    }
}
# If the workspace exists in the resource group, proceed to create Sentinel
else {
    Write-Verbose "        Proceeding with Sentinel creation..." -Verbose
}

