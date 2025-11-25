<#
    .SYNOPSIS
        Creates a new Entra Conditional Access Risky Workload ID policy based on provided policy JSON block.

    .DESCRIPTION
        This script creates a new user risk policy in Azure AD Conditional Access. 
        It performs the following actions:
        - Confirms the policy JSON is valid and compliant with the schema.
        - Checks for conflicts in the within the Conditional Access Policy definition.
        - Confirms there is not an existing Conditional Access Policy with the same name.
        - Outputs the state of the policy to be created.
        - Confirms service principals to be included/excluded exist within Entra.
        - Validates the provided applications to be included can be used with Conditional Access.
        - Confirms the service principal risk levels are properly set within the policy definition.
        - Confirms the locations to be included/excluded exist within Entra.
        - Confirms the grant controls are properly set within the policy definition.
        - Creates the Conditional Access policy in Entra.

    .PARAMETER PolicyJson
        [string] JSON representation of the Conditional Access policy. This parameter is mandatory.

    .PARAMETER SchemaFilePath
        [string] JSON schema file path to validate the provided Conditional Access Policy values. This parameter is mandatory.

    .INPUTS
        The script is designed to be run from Azure Pipelines, with input variables provided from pipeline-variables.yml.

    .OUTPUTS
        The script outputs verbose messages indicating the progress and results of the conditional access policy creation process. 
        It also outputs an activity log for each action described above, and error messages if any issues are encountered.

    .NOTES
        File Name      : risky-signin-policy-create.ps1
        Author         : Marcus Jacobson
        Version History: 1.0.0, Initial version
        Release        : 2025-04-0s - this is the initial release date
        Updated        : 
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "JSON representation of the Conditional Access Policy.")]
    [string]$PolicyJson,

    [Parameter(Mandatory = $true,
        HelpMessage = "Path to the Conditional Access policy schema.")]
    [string]$SchemaFilePath
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

function ConvertUPNToID {
    param (
        [Parameter(Mandatory = $true)]
        [string] $userPrincipalName
    )

    # Define user URI 
    $userUri = 'https://graph.microsoft.com/v1.0/users?$select=id,userPrincipalName&$filter=userPrincipalName eq ''{0}'''

    # Create input object to validate if the provided UPN is valid
    $userInputObject = @{
        method = 'GET'
        uri  = "{0}" -f ($userUri -f [uri]::EscapeDataString($userPrincipalName))
    }

    # Invoke REST API function to test the inputObject
    $existingUser = Invoke-RESTCommand @userInputObject

    # Check if user exists within Entra. If the user does not exist, output a warning and continue to the next user
    if ($existingUser.value -and $existingUser.value.Count -gt 0) {
        # If the user exists, return the Existing User ID
        return $existingUser.value[0].id
    }
    else {
        # If the user does not exist, return null
        return $null
    }
}
function ConvertGroupNameToID {
    param (
        [Parameter(Mandatory = $true)]
        [string] $displayName
    )

    # Define group URI 
    $groupUri = 'https://graph.microsoft.com/v1.0/groups?$select=id,displayName&$filter=displayName eq ''{0}'''

    # Create input object to validate if the provided group display name is valid
    $groupInputObject = @{
        method = 'GET'
        uri  = "{0}" -f ($groupUri -f [uri]::EscapeDataString($displayName))
    }

    # Invoke REST API function to test the inputObject
    $existingGroup = Invoke-RESTCommand @groupInputObject

    # Check if group exists within Entra. If the group does not exist, output a warning and continue to the next group
    if ($existingGroup.value -and $existingGroup.value.Count -gt 0) {
        # If the group exists, return the Existing Group ID
        return $existingGroup.value[0].id
    }
    else {
        # If the group does not exist, return null
        return $null
    }
}

function ConvertServicePrincipalNameToID {
    param (
        [Parameter(Mandatory = $true)]
        [string] $displayName
    )

    # Define the service principal URI
    $servicePrincipalUri = 'https://graph.microsoft.com/v1.0/servicePrincipals?$select=id,displayName&$filter=displayName eq ''{0}'''

    # Create input object to validate if the provided service principal display name is valid
    $servicePrincipalInputObject = @{
        method = 'GET'
        uri    = ($servicePrincipalUri -f [uri]::EscapeDataString($displayName))
    }

    # Invoke REST API function to test the inputObject
    $existingServicePrincipal = Invoke-RESTCommand @servicePrincipalInputObject

    # Check if the service principal exists within Entra. If it does not exist, output a warning and return null
    if ($existingServicePrincipal.value -and $existingServicePrincipal.value.Count -gt 0) {
        # If the service principal exists, return the ID
        return $existingServicePrincipal.value[0].id
    }
    else {
        # If the service principal does not exist, return null
        Write-Warning "Service principal [$($displayName)] not found in Entra."
        return $null
    }
}

function ConvertNamedLocationNameToId {
    param (
        [Parameter(Mandatory = $true)]
        [string] $displayName
    )

    # Define the named location URI
    $namedLocationUri = 'https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations?$select=id,displayName&$filter=displayName eq ''{0}'''

    # Create input object to validate if the provided named location display name is valid
    $namedLocationInputObject = @{
        method = 'GET'
        uri    = ($namedLocationUri -f [uri]::EscapeDataString($displayName))
    }

    # Invoke REST API function to test the inputObject
    $existingNamedLocation = Invoke-RESTCommand @namedLocationInputObject

    # Check if the named location exists within Entra. If it does not exist, output a warning and return null
    if ($existingNamedLocation.value -and $existingNamedLocation.value.Count -gt 0) {
        # If the named location exists, return the ID
        return $existingNamedLocation.value[0].id
    }
    else {
        # If the named location does not exist, return null
        Write-Warning "Named location [$($displayName)] not found in Entra."
        return $null
    }
}

# Verify the $PolicyJson variable is not empty, and has been passed correctly. Exit the script if it fails.
if (-not $PolicyJson) {
    Write-Error "PolicyJson is empty or not passed correctly."
    exit 1
}

# Validate the provided CA policy JSON against the provided schema. Exit the script if it fails.
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Validating the Conditional Access policy definitions against the schema..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Load the User definition schema
$Schema = Get-Content -Path $SchemaFilePath -Raw -ErrorAction Stop

# Validate the user CA policy definitions against the schema
try {
    $PolicyJson | Test-Json -Schema $Schema -ErrorAction Stop | Out-Null
    Write-Verbose  "    The provided workload identity policy definitions are compliant with the schema." -Verbose
}
catch {
    Write-Error "    The JSON file is not compliant with the schema. Error: $_" -ErrorAction Stop
}

# Deserialize the JSON string into a PowerShell object
$policyObject = $PolicyJson | ConvertFrom-Json

# Check for specific configuration conflict cases that will cause the policy to fail
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking for policy definition conflicts..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define a variable to track if the exception is cleared
$messageFlag = $false

# Define variable as an array for included locations objects
$includeSPObjects = $policyObject.conditions.clientApplications.includeServicePrincipals

# Check to confirm that the risky workload ID policy contains at least one included service principal\
if ($includeSPObjects -ieq 'none' -or $null -eq $includeSPObjects -or $includeSPObjects.Count -eq 0) {
    Write-Warning "    A Risky Workload ID policy must not have an [includeServicePrincipal] value of [None]."
    Write-Warning "        Please choose the Service Principal to include, or use [ServicePrincipalsInMyTenant]."
    Write-Warning "        Exiting pipeline."
    Exit 1
}

# Check to confirm that the risky workload ID policy does not contain an additional included service principal if "all" or "ServicePrincipalsInMyTenant" is included
if ($includeSPObjects -contains 'all' -or $includeSPObjects -contains 'ServicePrincipalsInMyTenant') {
    Write-Verbose "    Checking for conflicts relating to the inclusion of 'all' service principals." -Verbose
    if ($includeSPObjects.Count -gt 1) {
        Write-Warning "        The policy is set to include [All owned service principals], but additional specific service principals are included."
        Write-Warning "            To use the [all] option for service principals, no additional specific service principals can be included."
        Write-Warning "            Exiting pipeline."
        exit 1
    }
    else {
        Write-Verbose "        The policy is set to include [all] service principals with no additional service principals defined. Continuing with policy creation." -Verbose
        $messageFlag = $true
    }
}
# Define variable as an array for excluded locations objects
$excludeSPObjects = $policyObject.conditions.clientApplications.excludeServicePrincipals

# Confirm that the excludeApplication setting does not include the "all" value
if ($excludeSPObjects -contains 'all') {
    Write-Warning "        The policy is set to exclude [all] applications."
    Write-Warning "            The [excludeServicePrincipals] attribute cannot be set to [all]."
    Write-Warning "            Please choose the [excludeServicePrincipals] value to include, or use [none]."
    Write-Warning "            Exiting pipeline."
    exit 1
}

# Define variable as an array for included applications objects
$includeApplicationsObjects = $policyObject.conditions.applications.includeApplications

# Check to confirm that a policy set to applications only includes all applications
if ($includeApplicationsObjects -and ($includeApplicationsObjects -ine 'none' -and $includeApplicationsObjects -ine 'all')) {
    Write-Warning "    The Risky Workload ID policy contains a [includeApplications] value of [$($includeApplicationsObjects)]."
    Write-Warning "        A Risky Workload ID policy must only have an [includeApplications] value of [all] or [none]."      
    Write-Warning "        Exiting pipeline."
    exit 1
}

# Define variable as an array for included locations objects
$includeLocationsObjects = $policyObject.conditions.locations.includeLocations

# Check to confirm that a policy set to include all locations does not also include additional specific locations
if ($includeLocationsObjects -contains 'all') {
    
    # Check for conflicts with the inclusion of "all" applications
    Write-Verbose "    Checking for conflicts relating to the inclusion of 'all' locations." -Verbose
    if ($includeLocationsObjects.Count -gt 1) {
        Write-Warning "        The policy is set to include [all] locations, but additional specific locations are included."
        Write-Warning "            To use the [all] option for locations, no additional specific locations can be included."
        Write-Warning "            Exiting pipeline."
        exit 1
    }
    else {
        Write-Verbose "        The policy is set to include [all] locations with no additional locations defined. Continuing with policy creation." -Verbose
        $messageFlag = $true
    }
}

# Check to confirm that the risky workload ID policy does not contain an included location of "none"
if ($includeLocationsObjects-ieq 'none' -or $null -eq $includeLocationsObjects -or $includeLocationsObjects.Count -eq 0) {
    Write-Warning "    A Risky Workload ID policy must not have an [includeLocations] value of [None]."
    Write-Warning "        Please choose the [includeLocation] value to include, or use [all]."
    Write-Warning "        Exiting pipeline."
    Exit 1
}

# Define variable as an array for excluded locations objects
$excludeLocationsObjects = $policyObject.conditions.locations.excludeLocations

# Check to confirm that the risky workload ID policy does not contain an excluded location of "all"
$excludeLocationsObjects = $policyObject.conditions.locations.excludeLocations
if ($excludeLocationsObjects -contains 'all') {
    Write-Warning "    A Risky Workload ID policy must not have an [excludeLocations] value of [all]."
    Write-Warning "        Please choose the [excludeLocation] value to include, or use [none]."
    Write-Warning "        Exiting pipeline."
    Exit 1
}

# Continue if no conflicts are found
if ($messageFlag -eq $false) {
    Write-Verbose  "    The policy does not contain any conflicting settings. Continuing with policy creation." -Verbose
}

# Verify a policy does not already exist with the same name
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking if there is already a conditional access policy with the name: $($policyObject.displayName)" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI for the request
$uri = "https://graph.microsoft.com/beta/identity/conditionalAccess/policies" 

# Get the list of existing policies and save to a hashtable
$existingPoliciesInputObject = @{
    method = 'GET'
    uri = $uri
}

# Invoke REST API function to test the inputObject
$existingPolicies = Invoke-RESTCommand @existingPoliciesInputObject

# Declare a variable to track if a policy with the same name already exists
$existingPolicyFlag = $false

# Compare the existing policies with the new policy to be created, and exit if a match is found
foreach ($policy in $existingPolicies.value) {
    if ($policy.displayName -eq $policyObject.displayName) {
        Write-Warning "    A policy with the name $($policyObject.displayName) already exists. Please choose a different name."
        $existingPolicyFlag = $true
    }
}

# If a policy with the same name already exists, exit the script
if ($existingPolicyFlag -eq $true) {
    Write-Warning "   Exiting pipeline."
    exit 1
}
else {
    Write-Verbose "    No policy with the name $($policyObject.displayName) exists. Proceeding with policy creation." -Verbose
}

# Verify the state of the policy is valid
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Confirming state of Conditional Access policy..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Check if the state of the policy is set to enabled, disabled, or report-only
$enabledState = $policyObject.state
if ($enabledState -ieq 'enabled') {
    Write-Verbose  "    The policy will be created with the following state: [Enabled]." -Verbose
}
elseif ($enabledState -ieq 'disabled') {
    Write-Verbose  "    The policy will be created with the following state: [Disabled]." -Verbose
}
elseif ($enabledState -ieq 'enabledForReportingButNotEnforced') {
    Write-Verbose  "    The policy will be created with the following state: [Report-only]." -Verbose
}
else {
    Write-Warning  "    The policy is not defined with a valid state." -Verbose
    Write-Warning  "    Exiting pipeline." -Verbose
    exit 1
}

# Validating the workload identities provided in the policy JSON block
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking Workload Identities/Service Principals..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Check if the members of includeServicePrincipals exists in Entra, and add the ID to the array if it does
$includeServicePrincipals = @()
$includeSPObjects = $policyObject.conditions.clientApplications.includeServicePrincipals
if ($includeSPObjects -ieq 'all' -or $includeSPObjects -eq 'ServicePrincipalsInMyTenant') {
    Write-Verbose  "    The policy will be created with the following service principals included: [All owned service principals]." -Verbose
    $includeServicePrincipals = @('ServicePrincipalsInMyTenant')
}
else {
    Write-Verbose  "    The policy will be created with the following service principals included: [Select service principals]." -Verbose
    foreach ($spObject in $includeSPObjects) {
        Write-Verbose  "        Checking service principal: $($spObject)" -Verbose
        $spID = ConvertServicePrincipalNameToID -displayName $spObject
        if ($spID) {
            Write-Verbose  "            The following service principal will be included in the policy: [$($spID)]" -Verbose
            $includeServicePrincipals += $spID
        }
        else {
            Write-Verbose "            Service principal [$($spObject)] not found in Entra. Skipping." -Verbose
        }
    }
}

# Check if the members of excludeServicePrincipals exists in Entra, and add the ID to the array if it does
$excludeServicePrincipals = @()
$excludeSPObjects = $policyObject.conditions.clientApplications.excludeServicePrincipals
if ($excludeSPObjects -ieq 'none' -or $null -eq $excludeSPObjects -or $excludeSPObjects.Count -eq 0) {
    Write-Verbose  "    The policy will be created with the following service principals excluded: [None]." -Verbose
    $excludeServicePrincipals = @()
}
else {
    Write-Verbose  "    The policy will be created with the following service principals excluded: [Select Workload Identities]" -Verbose
    foreach ($spObject in $excludeSPObjects ) {
        Write-Verbose  "        Checking workload identity: $($spObject)" -Verbose
        $spID = ConvertServicePrincipalNameToID -displayName $spObject
        if ($spID) {
            Write-Verbose  "            The following service principal will be excluded from the policy: [$($spID)]" -Verbose
            $excludeServicePrincipals += $spID
        }
        else {
            Write-Verbose "            Service principal [$($spObject)] not found in Entra. Skipping." -Verbose
        }
    }
}

# Validating the included and excluded applications provided in the policy JSON block
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking Applications to include as resources..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define an array to hold the applications to be included in the policy
$includeApplicationIDs = @()

# Check if the included applications exists in Entra, and add the ID to the array if it does
$includeApplicationsObjects = $policyObject.conditions.applications.includeApplications
if ($includeApplicationsObjects -ieq 'all') {
    Write-Verbose "    The policy will be created with the following resources included: [All resources (formerly 'All cloud apps')]." -Verbose
    $includeApplicationIDs = @('all')
}
elseif ($includeApplicationsObjects -ieq 'none' -or $null -eq $includeApplicationsObjects -or $includeApplicationsObjects.Count -eq 0) {
    Write-Verbose "    The policy will be created with the following resources included: [None]." -Verbose
    $includeApplicationIDs = @('None')
}
else {
    Write-Warning "    The Risky Workload ID policy contains a [includeApplications] value of [$($includeApplicationsObjects)]."
    Write-Warning "        A Risky Workload ID policy must only have an [includeApplications] value of [all] or [none]."      
    Write-Warning "        Exiting pipeline."
    exit 1
}

# Confirm the policy definition includes service principal risk levels
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking Service Principal Risk Levels..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define an array to hold the service principal risk levels
$spRiskLevels = $policyObject.conditions.servicePrincipalRiskLevels

# Check if the service principal risk levels are set to "none" or null, and exit if they are
if ($null -eq $spRiskLevels-or $spRiskLevels.Count -eq 0) {
    Write-Warning  "    Service Principal risk levels are required for a Risky Workload Identity Policy." -Verbose
    Write-Warning  "    Exiting pipeline." -Verbose
    exit 1
}
else {
    Write-Verbose  "    The following service principal risk levels will be applied to in the policy:" -Verbose
    foreach ($spRiskLevel in $spRiskLevels) {
        Write-Verbose  "        $($spRiskLevel)" -Verbose
    }
}

# Validating the locations provided in the policy JSON block
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking Locations to include/exclude..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define an array to hold the locations to be included in the policy
$includeLocations = @()

# Check if the included locations exists in Entra, and add the ID to the array if it does
$includeLocationsObjects = $policyObject.conditions.locations.includeLocations
if ($includeLocationsObjects -ieq 'all') {
    Write-Verbose  "    The policy will be created with the following locations included: [All locations]." -Verbose
    $includeLocations = @('All')
}
elseif ($includeLocationsObjects -ieq 'allTrusted') {
    Write-Verbose  "    The policy will be created with the following locations included: [All trusted locations]." -Verbose
    $includeLocations = @('AllTrusted')
}
else {
    Write-Verbose  "    The policy will be created with the following locations included: [Select locations]" -Verbose
    foreach ($locationObject in $includeLocationsObjects) {
        Write-Verbose  "        Checking workload identity: $($locationObject)" -Verbose
        $locationID = ConvertNamedLocationNameToId -displayName $locationObject
        if ($locationID) {
            Write-Verbose  "            The following location will be included in the policy: [$($locationID)]" -Verbose
            $includeLocations += $locationID
        }
        else {
            Write-Verbose "            Location [$($location)] not found in Entra. Skipping." -Verbose
        }
    }
}

# Define an array to hold the locations to be excluded in the policy
$excludeLocations = @()

# Check if the excluded locations exists in Entra, and add the ID to the array if it does
$excludeLocationsObjects = $policyObject.conditions.locations.excludeLocations
if ($excludeLocationsObjects -ieq 'allTrusted') {
    Write-Verbose  "    The policy will be created with the following locations excluded: [All trusted locations]." -Verbose
    $excludeLocations = @('AllTrusted')
}
elseif ($excludeLocationsObjects -ieq 'none' -or $null -eq $excludeLocationsObjects -or $excludeLocationsObjects.Count -eq 0) {
    Write-Verbose  "    The policy will be created with the following locations excluded: [None]." -Verbose
}
else {
    Write-Verbose  "    The policy will be created with the following locations excluded: [Select locations]" -Verbose
    foreach ($locationObject in $excludeLocationsObjects) {
        Write-Verbose  "        Checking workload identity: $($locationObject)" -Verbose
        $locationID = ConvertNamedLocationNameToId -displayName $locationObject
        if ($locationID) {
            Write-Verbose  "            The following location will be excluded from the policy: [$($locationID)]" -Verbose
            $excludeLocations += $locationID
        }
        else {
            Write-Verbose "            Location [$($locationObject)] not found in Entra. Skipping." -Verbose
        }
    }
}

# Confirm the grant controls within the policy definition are applied correctly
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking Grant Controls..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the variables for the grant control operator
$operator = $policyObject.grantControls.operator
if ($operator -eq 'OR' -or $operator -eq 'AND') {
    Write-Verbose  "    Grant Controls Operator: [$($operator)]" -Verbose
}
else {
    Write-Error  "    Grant Controls Operator must be 'OR' or 'AND'. Check case sensitivity!" -Verbose
}


# Define the variables for the grant control builtInControls
$builtInControlValues = @()

# Add the builtInControls to the array
$builtInControls = $policyObject.grantControls.builtInControls
foreach ($builtInControl in $builtInControls) {
    $builtInControlValues += $builtInControl
    Write-Verbose  "        Applying built in control value: [$($builtInControl)]" -Verbose
} 

# Create the conditional access policy
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Creating Conditional Access Policy..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI to create a conditional access policy
$policyUri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"

# Build the body of the request
$body = @{
    displayName = $policyObject.displayName
    state = $policyObject.state
    conditions = @{
        clientApplications = @{
            includeServicePrincipals = $includeServicePrincipals
            excludeServicePrincipals = $excludeServicePrincipals
        }
        applications = @{
            includeApplications = $includeApplicationIDs
        }
        servicePrincipalRiskLevels = $spRiskLevels
        locations = @{
            includeLocations = $includeLocations
            excludeLocations = $excludeLocations
        }
    }
    grantControls = @{
        operator = $operator
        builtInControls = $builtInControlValues
    }
}

# Build REST API object
$policyInputObject = @{
    method = 'POST'
    uri    = $policyUri
    header = @{"Content-Type" = "application/json"}
    body   = ($body | ConvertTo-Json -Depth 10 -Compress)
}

# Invoke REST API function to create the conditional access policy
$response = Invoke-RESTCommand @policyInputObject

# Check successful conditional access policy deployment, and output an error if it fails. End the script on an error.
if (-not [String]::IsNullOrEmpty($response.error)) {
    Write-Error ('Failed to create conditional access policy [{0}] because of [{1} - {2}].' -f $policyObject.displayName, $response.error.code, $response.error.message)
}
else {
    # Output confirmation of successful conditional access policy deployment
    Write-Verbose "    The conditional access policy $($policyObject.displayName) was successfully deployed." -Verbose
}
