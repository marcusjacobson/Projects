<#
    .SYNOPSIS
        Update the default Passkey/FIDO2 Authentication Method policy in Entra based on provided variables.

    .DESCRIPTION
        This script updates the default Passkey/FIDO2 Authentication Method policy in Entra based on provided variables, after validating the JSON against a schema.
        It checks for conflicts with existing policies, validates group IDs, and performs additional error handling as needed.
        Updates to the policy are made using the Microsoft Graph REST API.

    .PARAMETER PolicyJson
        [string] A JSON representation containing the attributes of the policy to update. This parameter is mandatory.

    .PARAMETER SchemaFilePath
        [string] The path to the schema file used for validating the JSON representation of the policy. This parameter is mandatory.

    .INPUTS
        The script is intended to be run from Azure Pipelines, with variable input provided by pipeline-variables.yml.

    .OUTPUTS
        The script outputs verbose messages indicating the progress and results of the Authentication method policy update. 
        It also outputs error messages if any issues are encountered.

    .EXAMPLE
        .\passkey-policy-config.ps1 -PolicyJson $PolicyJson -SchemaFilePath $SchemaFilePath

    .NOTES
        File Name      : passkey-policy-config.ps1
        Author         : Marcus Jacobson
        Version History: 1.0.0, Initial version
        Release        : 2025-04-21 - this is the initial release date
        Updated        : 
        Issue Log      :
        - 2025-04-21: The current release does not correctly add multiple groups for includeTargets. It does work as expected for excludeTargets.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "JSON representation of the Authentication Method Policy.")]
    [string]$PolicyJson,

    [Parameter(Mandatory = $true,
        HelpMessage = "Path to the Authentication Method policy schema.")]
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

# Generating Access Token for REST API call.
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Retrieving Graph Access Token..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

try {
    $tokenResponse = az account get-access-token --resource https://graph.microsoft.com | ConvertFrom-Json
    $AccessToken = $tokenResponse.accessToken
    Write-Verbose "    Successfully retrieved Access Token: $($AccessToken.Substring(0, 10))... (obfuscated for security)" -Verbose
}
catch {
    Write-Error "Failed to retrieve Access Token using Azure CLI. Ensure the Azure CLI is authenticated and has the necessary permissions."
    exit 1
}

# Validate the provided Authentication Methods policy JSON against the provided schema. Exit the script if it fails.
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Validating the Authentication Methods policy definitions against the schema..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Load the User definition schema
$Schema = Get-Content -Path $SchemaFilePath -Raw -ErrorAction Stop

# Validate the authentication methods policy definitions against the schema
try {
    $PolicyJson | Test-Json -Schema $Schema -ErrorAction Stop | Out-Null
    Write-Verbose  "    The provided authentication methods policy definitions are compliant with the schema." -Verbose
}
catch {
    Write-Error "    The JSON file is not compliant with the schema. Error: $_" -ErrorAction Stop
}

# Deserialize the JSON string into a PowerShell object
$policyObject = $PolicyJson | ConvertFrom-Json

# Check for conflicts with existing policies
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose 
Write-Verbose  "Checking for conflicts within the requested policy..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
 

# Check to ensure provided group IDs are valid
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose 
Write-Verbose  "Checking provided group IDs exist in Entra..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Ensure all objects in includeTargets have an 'id' property
$policyObject.includeTargets = $policyObject.includeTargets | ForEach-Object {
    [PSCustomObject]@{
        targetType            = $_.targetType
        displayName           = $_.displayName
        isRegistrationRequired = $_.isRegistrationRequired
        id                    = $null  # Initialize 'id' property
    }
}

# Ensure all objects in excludeTargets have an 'id' property
$policyObject.excludeTargets = $policyObject.excludeTargets | ForEach-Object {
    [PSCustomObject]@{
        targetType  = $_.targetType
        displayName = $_.displayName
        id          = $null  # Initialize 'id' property
    }
}

# Define the URI to create a conditional access policy
$policyUri = " https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/fido2"

# Check to ensure provided group IDs are valid
# If provided, "all_users" will be treated as a special case within the includeTargets object
Write-Verbose "    Checking groups defined in includeTargets..." -Verbose
foreach ($target in $policyObject.includeTargets) {
    
    if ($target.displayName -ne "all_users") {
        $groupID = ConvertGroupNameToID -displayName $target.displayName

        if ($groupID) {
            # If the group exists, update the target ID
            $target.id = $groupID
            Write-Verbose "        The group [$($target.displayName)] exists. Updated ID: $($target.id)" -Verbose
        }
        else {
            # If the group does not exist, output a warning and continue to the next group
            Write-Error "    The group [$($target.displayName)] does not exist in Entra." -ErrorAction Stop
        }
    }
    else {
        # If the group is "all_users", set the ID to "all_users"
        $target.id = "all_users"
        Write-Verbose "        Assigning the includeTargets value to [$($target.id)]" -Verbose
    }
}

# Check to ensure provided group IDs are valid
# If provided, "all_users" will be treated as a group name since it is not a special case for excludeTargets
Write-Verbose "    Checking groups defined in excludeTargets..." -Verbose
foreach ($target in $policyObject.excludeTargets) {
    
    $groupID = ConvertGroupNameToID -displayName $target.displayName

    if ($groupID) {
        # If the group exists, update the target ID
        $target.id = $groupID
        Write-Verbose "        The group [$($target.displayName)] exists. Updated ID: $($target.id)" -Verbose
    }
    else {
        # If the group does not exist, output a warning and continue to the next group
        Write-Error "    The group [$($target.displayName)] does not exist in Entra." -ErrorAction Stop
    }
}

# Create the Authentication Method policy
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Creating FIDO2 Authentication Method Policy..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Extract the first entry for includeTargets and excludeTargets
# Remaining entries will be added later in the script since the policy can only be updated with one of these objects at a time
$firstIncludeTarget = $policyObject.includeTargets[0]
$remainingIncludeTargets = $policyObject.includeTargets[1..($policyObject.includeTargets.Count - 1)]  # Remaining entries   
$firstExcludeTarget = $policyObject.excludeTargets[0]
$remainingExcludeTargets = $policyObject.excludeTargets[1..($policyObject.excludeTargets.Count - 1)]  # Remaining entries

# Define boolean variables to check if multiple includeTargets or excludeTargets are defined
$multipleIncludeTargets = $false
$multipleExcludeTargets = $false

If ($remainingIncludeTargets.Count -gt 0) {
    $multipleIncludeTargets = $true
}
If ($remainingExcludeTargets.Count -gt 0) {
    $multipleExcludeTargets = $true
}

# Output the first includeTarget and excludeTarget that will be included in the policy deployment
Write-Verbose "    Updating the policy with the first includeTarget [$($firstIncludeTarget.displayName)] and the first excludeTarget [$($firstExcludeTarget.displayName)]..." -Verbose

#Define Odata type for the policy object
$odataType = "#microsoft.graph.fido2AuthenticationMethodConfiguration"

# Define the URI to create a authentication method policy
$policyUri = " https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/fido2"

# Build the body of the request
$body = @{
    '@odata.type' = $odataType
    state = $policyObject.state
    isSelfServiceRegistrationAllowed = $policyObject.isSelfServiceRegistrationAllowed
    isAttestationEnforced = $policyObject.isAttestationEnforced
    keyRestrictions = @{
        isEnforced = $policyObject.keyRestrictions.isEnforced
        enforcementType = $policyObject.keyRestrictions.enforcementType
        aaGuids = $policyObject.keyRestrictions.aaGuids
    }
    includeTargets = @(
        @{
            targetType = $firstIncludeTarget.targetType
            id = $firstIncludeTarget.id
            isRegistrationRequired = $firstIncludeTarget.isRegistrationRequired
        }
    )
    excludeTargets = @(
        @{
            targetType = $firstExcludeTarget.targetType
            id = $firstExcludeTarget.id
        }
    )
}

# Build REST API object
$policyInputObject = @{
    method = 'PATCH'
    uri    = $policyUri
    header = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $($AccessToken)"
    }
    body   = ($body | ConvertTo-Json -Depth 10 -Compress)
}

# Invoke REST API function to create the authentication method policy
$response = Invoke-RESTCommand @policyInputObject


# Check if the initial policy creation was successful
if (-not [String]::IsNullOrEmpty($response.error)) {
    Write-Error ('Failed to create authentication method policy [{0}] because of [{1} - {2}].' -f $policyObject.displayName, $response.error.code, $response.error.message)
    exit 1
}
else {
    Write-Verbose "        The policy was successfully updated with the provided policy attributes." -Verbose
    Write-Verbose "            Note: At this time, only the first provided includeTarget and excludeTarget have been added." -Verbose
}

# Perform a check to add additional includeTargets and excludeTargets to the policy if they are defined in the variables
Write-Verbose "    Checking for additional includeTargets and excludeTargets..." -Verbose

# Retrieve the current policy to get existing includeTargets and excludeTargets
$currentPolicy = Invoke-RestMethod -Uri $policyUri -Method GET -Headers @{
    "Authorization" = "Bearer $AccessToken"
}

if (-not $currentPolicy) {
    Write-Error "Failed to retrieve the current policy. Ensure the policy exists and the API call is authorized." -ErrorAction Stop
}

# Extract the existing includeTargets
$currentIncludeTargets = $currentPolicy.includeTargets

Write-Verbose "    Current includeTargets: $($currentIncludeTargets | ConvertTo-Json -Depth 10 -Compress)" -Verbose

# Add remaining includeTargets to the current list
foreach ($target in $remainingIncludeTargets) {
    $groupID = ConvertGroupNameToID -displayName $target.displayName

    if ($groupID) {
        # Append the new group to the existing excludeTargets
        $currentIncludeTargets += @{
            targetType = $target.targetType
            id = $groupID
            isRegistrationRequired = $target.isRegistrationRequired
        }
        Write-Verbose "        Adding group [$($target.displayName)] with ID [$groupID] to includeTargets." -Verbose
    }
    else {
        Write-Error "    The group [$($target.displayName)] does not exist in Entra." -ErrorAction Stop
    }
}

Write-Verbose "    Updated includeTargets: $($currentIncludeTargets | ConvertTo-Json -Depth 10 -Compress)" -Verbose

# Update the policy with the new includeTargets array
$updateBody = @{
    includeTargets = $currentIncludeTargets
}

$updateInputObject = @{
    method = 'PATCH'
    uri    = $policyUri
    header = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $($AccessToken)"
    }
    body   = ($updateBody | ConvertTo-Json -Depth 10 -Compress)
}

# Invoke REST API function to update the policy
$updateResponse = Invoke-RESTCommand @updateInputObject

# Check if the update was successful
if (-not [String]::IsNullOrEmpty($updateResponse.error)) {
    Write-Error ('Failed to update authentication method policy with includeTargets because of [{0} - {1}].' -f $updateResponse.error.code, $updateResponse.error.message)
    exit 1
}
else {
    if ($multipleIncludeTargets) {
        Write-Verbose "            Successfully updated the policy with additional includeTargets." -Verbose
    }
    else {
        Write-Verbose "        No additional includeTargets were provided." -Verbose
    }
}

# Extract the existing excludeTargets
$currentExcludeTargets = $currentPolicy.excludeTargets

# Add remaining excludeTargets to the current list
foreach ($target in $remainingExcludeTargets) {
    $groupID = ConvertGroupNameToID -displayName $target.displayName

    if ($groupID) {
        # Append the new group to the existing excludeTargets
        $currentExcludeTargets += @{
            targetType = $target.targetType
            id = $groupID
        }

        Write-Verbose "        Adding group [$($target.displayName)] with ID [$groupID] to excludeTargets." -Verbose
    }
    else {
        Write-Error "    The group [$($target.displayName)] does not exist in Entra." -ErrorAction Stop
    }
}

# Update the policy with the new excludeTargets array
$updateBody = @{
    excludeTargets = $currentExcludeTargets
}

$updateInputObject = @{
    method = 'PATCH'
    uri    = $policyUri
    header = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $($AccessToken)"
    }
    body   = ($updateBody | ConvertTo-Json -Depth 10 -Compress)
}

# Invoke REST API function to update the policy
$updateResponse = Invoke-RESTCommand @updateInputObject

# Check if the update was successful
if (-not [String]::IsNullOrEmpty($updateResponse.error)) {
    Write-Error ('Failed to update authentication method policy with excludeTargets because of [{0} - {1}].' -f $updateResponse.error.code, $updateResponse.error.message)
    exit 1
}
else {
    if ($multipleExcludeTargets) {
        Write-Verbose "            Successfully updated the policy with additional excludeTargets." -Verbose
    }
    else {
        Write-Verbose "        No additional excludeTargets were provided." -Verbose    
    }
}

# Output a summary of the policy deployment
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Summary..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Check successful authentication method policy deployment, and output an error if it fails. End the script on an error.
if (-not [String]::IsNullOrEmpty($response.error)) {
    Write-Error ('Failed to create authentication method policy [{0}] because of [{1} - {2}].' -f $policyObject.displayName, $response.error.code, $response.error.message)
}
else {
    # Output confirmation of successful authentication method policy deployment
    Write-Verbose "    The [Passkeys (FIDO2)] authentication method policy was successfully updated with the following properties:" -Verbose
    Write-Verbose "        State: $($policyObject.state)" -Verbose
    Write-Verbose "        SelfServiceRegistration: $($policyObject.isSelfServiceRegistrationAllowed)" -Verbose
    Write-Verbose "        AttestationEnforcement: $($policyObject.isAttestationEnforced)" -Verbose
    Write-Verbose "        KeyRestrictions: $($policyObject.keyRestrictions.isEnforced)" -Verbose
    Write-Verbose "        KeyRestrictions EnforcementType: $($policyObject.keyRestrictions.enforcementType)" -Verbose
    Write-Verbose "        KeyRestrictions AA GUIDs:" -Verbose
    foreach ($target in $policyObject.keyRestrictions.aaGuids) {
        Write-Verbose "            $($target)" -Verbose
    }
    Write-Verbose "        IncludeTargets:" -Verbose
    foreach ($target in $policyObject.includeTargets) {
        Write-Verbose "             [$($target.displayName)]" -Verbose
    }
    Write-Verbose "        ExcludeTargets:" -Verbose
    foreach ($target in $policyObject.excludeTargets) {
        Write-Verbose "             [$($target.displayName)]" -Verbose
    }
}
