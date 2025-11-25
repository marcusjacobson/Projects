<#
    .SYNOPSIS
        Creates a new Entra Conditional Access User Risk policy based on provided policy JSON block.

    .DESCRIPTION
        This script creates a new user risk policy in Azure AD Conditional Access. 
        It performs the following actions:
        - Confirms the policy JSON is valid and compliant with the schema.
        - Checks for conflicts in the within the Conditional Access Policy definition.
        - Confirms there is not an existing Conditional Access Policy with the same name.
        - Outputs the state of the policy to be created.
        - Confirms users and groups to be included/excluded exist within Entra.
        - Validates the provided applications to be included/excluded can be used with Conditional Access.
        - Confirms the user risk levels are properly set within the policy definition.
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
        File Name      : user-risk-policy-create.ps1
        Author         : Marcus Jacobson
        Version History: 1.0.0, Initial version
        Release        : 2025-03-31 - this is the initial release date
        Updated        : 2025-04-03 (1.0.1) - minor updates to comments
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
    Write-Verbose  "    The provided user definitions are compliant with the schema." -Verbose
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

$messageFlag = $false

# Check to confirm that a policy with a passwordChange grant control is set to include all applications
if ($policyObject.grantControls.builtInControls -contains 'passwordChange') {
    
    # Check if the policy is set to include all applications when the grant control is set to passwordChange
    Write-Verbose "    Checking for conflicts relating to the passwordChange grant control." -Verbose
    if ($policyObject.conditions.applications.includeApplications -ine 'all') {
        Write-Warning "        The policy is set to include the [passwordChange] grant control, but does not include [all] applications."
        Write-Warning "            To use the [passwordChange] grant control, the policy must include [all] applications."
        Write-Warning "            Exiting pipeline."
        exit 1
    }
    else {
        Write-Verbose "        The policy is set to include the [passwordChange] grant control along with the required [all] applications value. Continuing with policy creation." -Verbose
        $messageFlag = $true
    }

    # Check to ensure the policy is set to exclude applications when the grant control is set to passwordChange
    if ($policyObject.conditions.applications.excludeApplications.count -ne 0 -or $policyObject.conditions.applications.excludeApplications -ine 'none') {
        Write-Warning "        The policy is set to include the [passwordChange] grant control, but contains applications to be excluded."
        Write-Warning "            To use the [passwordChange] grant control, the [excludeApplications] attribute must be empty or set to [none]."
        Write-Warning "            Exiting pipeline."
        exit 1
    }
    else {
        Write-Verbose "        The policy is set to include the [passwordChange] grant control along with no excluded applications. Continuing with policy creation." -Verbose
        $messageFlag = $true
    }
    
    # Check to ensure the policy is set to include MFA when the grant control is set to passwordChange
    if ($policyObject.grantControls.builtInControls -notcontains 'mfa') {
        Write-Warning "        The policy is set to include the [passwordChange] grant control, and does not include [mfa]."
        Write-Warning "            To use the [passwordChange] grant control, [mfa] must also be included."
        Write-Warning "            Exiting pipeline."
        exit 1
    }
    else {
        Write-Verbose "        The policy is set to include the [passwordChange] grant control along with the required [mfa] value. Continuing with policy creation." -Verbose
        $messageFlag = $true
    }

    # Check to ensure the operator is set to AND when the grant control is set to passwordChange
    if ($policyObject.grantControls.operator -ne 'AND') {
        Write-Warning "        The policy is set to include the [passwordChange] grant control, but the operator is not set to [AND]."
        Write-Warning "            To use the [passwordChange] grant control, the operator must be set to [AND]."
        Write-Warning "            Exiting pipeline."
        exit 1
    }
    else {
        Write-Verbose "        The policy is set to include the [passwordChange] grant control with the required [AND] operator. Continuing with policy creation." -Verbose
        $messageFlag = $true
    }
}

# Check to confirm that a policy set to include all users does not also include specific users or groups
if ($policyObject.conditions.users.includeUsers -contains 'all') {
    
    # Check if there are additional user values besides "all"
    Write-Verbose "    Checking for conflicts relating to the inclusion of 'all' users." -Verbose
    if ($policyObject.conditions.users.includeUsers.Count -gt 1) {
        Write-Warning "        The policy is set to include [all] users, but additional specific users are included."
        Write-Warning "            To use the [all] option for users, no additional specific users or groups can be included."
        Write-Warning "            Exiting pipeline."
        exit 1
    }
    else {
        Write-Verbose "        The policy is set to include [all] users with no additional users defined. Continuing with policy creation." -Verbose
        $messageFlag = $true
    }

    # Check if any groups are included when "all" is specified
    if ($policyObject.conditions.users.includeGroups.Count -gt 0) {
       Write-Warning "         The policy is set to include [all] users, but specific groups are also included."
       Write-Warning "             To use the [all] option for users, no additional groups can be included."
       Write-Warning "             Exiting pipeline."
       exit 1
    }
    else {
        Write-Verbose "        The policy is set to include [all] users and contains no additional groups. Continuing with policy creation." -Verbose
        $messageFlag = $true
    }
}

# Confirming the excludeUsers and excludeGroups attributes do not contain the "all" value
if ($policyObject.conditions.users.excludeUsers -contains 'all' -or $policyObject.conditions.users.excludeGroups -contains 'all') {
    Write-Warning "        The policy is set to exclude [all] users or [all] groups."
    Write-Warning "            The [excludeUsers] or [excludeGroups] attribute cannot be set to [all]."
    Write-Warning "            Exiting pipeline."
    exit 1
}

# Check to confirm that a policy set to include all applications does not also include additional specific applications
if ($policyObject.conditions.applications.includeApplications -contains 'all') {
    
    # Check for conflicts with the inclusion of "all" applications
    Write-Verbose "    Checking for conflicts relating to the inclusion of 'all' applications." -Verbose
    if ($policyObject.conditions.applications.includeApplications.Count -gt 1) {
        Write-Warning "        The policy is set to include [all] applications, but additional specific applications are included."
        Write-Warning "            To use the [all] option for applications, no additional specific applications can be included."
        Write-Warning "            Exiting pipeline."
        exit 1
    }
    else {
        Write-Verbose "        The policy is set to include [all] applications with no additional applications defined. Continuing with policy creation." -Verbose
        $messageFlag = $true
    }
}

# Confirm that the excludeApplication setting does not include the "all" value
if ($policyObject.conditions.applications.excludeApplications -contains 'all') {
    Write-Warning "        The policy is set to exclude [all] applications."
    Write-Warning "            The [excludeApplications] attribute cannot be set to [all] without using Global Secure Access."
    Write-Warning "            Exiting pipeline."
    exit 1
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

# Check the state of the policy and set the variable accordingly
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

# Validating the users and groups provided in the policy JSON block
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking Users and Groups..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Check if the members of includeUsers exists in Entra, and add the ID to the array if it does
$includeUserIDs = @()
$includeUsersObjects = $policyObject.conditions.users.includeUsers
if ($includeUsersObjects -ieq 'all') {
    Write-Verbose  "    The policy will be created with the following users included: [All users]." -Verbose
    $includeUserIDs = @('all')
}
elseif ($includeUsersObjects -ieq 'none' -or $null -eq $includeUsersObjects -or $includeUsersObjects.Count -eq 0) {
    Write-Verbose  "    The policy will be created with the following users included: [None]." -Verbose
}
else {
    Write-Verbose  "    The policy will be created with the following users included: [Select users]" -Verbose
    foreach ($userObject in $includeUsersObjects) {
        Write-Verbose  "        Checking user: $($userObject)" -Verbose
        $userID = ConvertUPNToID -displayName $userObject
        if ($userID) {
            Write-Verbose  "            The following user ID will be included in the policy: [$($userID)]" -Verbose
            $includeUserIDs += $userID
        }
        else {
            Write-Warning "            User [$($userObject)] not found in Entra. Skipping."
        }
    }
}

# Check if the members of excludeUsers exists in Entra, and add the ID to the array if it does
$excludeUserIDs = @()
$excludeUsersObjects = $policyObject.conditions.users.excludeUsers
if ($excludeUsersObjects -ieq 'all') {
    Write-Verbose  "    The policy will be created with the following users excluded: [All users]." -Verbose
    $excludeUserIDs = @('all')
}
elseif ($excludeUsersObjects -ieq 'none' -or $null -eq $includeUsersObjects -or $excludeUsersObjects.Count -eq 0) {
    Write-Verbose  "    The policy will be created with the following users excluded: [None]." -Verbose
}
else {
    Write-Verbose  "    The policy will be created with the following users excluded: [Select users]" -Verbose
    foreach ($userObject in $excludeUsersObjects) {
        Write-Verbose  "        Checking user: $($userObject)" -Verbose
        $userID = ConvertUPNToID -userPrincipalName $userObject
        if ($userID) {
            Write-Verbose  "            The following user ID will be excluded from the policy: [$($userID)]" -Verbose
            $excludeUserIDs += $userID
        }
        else {
            Write-Warning "            User [$($userObject)] not found in Entra. Skipping."
        }
    }
}

# Check if the members of includeGroups exists in Entra, and add the ID to the array if it does
$includeGroupIDs = @()
$includeGroupsObjects = $policyObject.conditions.users.includeGroups
if ($includeGroupsObjects -ieq 'none' -or $null -eq $includeGroupsObjects -or $includeGroupsObjects.Count -eq 0) {
    Write-Verbose  "    The policy will be created with the following groups included: [None]." -Verbose
}
else {
    Write-Verbose  "    The policy will be created with the following groups included: [Select groups]" -Verbose
    foreach ($groupObject in $includeGroupsObjects) {
        Write-Verbose  "        Checking group: $($groupObject)" -Verbose
        $groupID = ConvertGroupNameToID -displayName $groupObject
        if ($groupID) {
            Write-Verbose  "          The following group ID will be included in the policy: [$($groupID)]" -Verbose
            $includeGroupIDs += $groupID
        }
        else {
            Write-Warning "            Group [$($groupObject)] not found in Entra. Skipping."
        }
    }
}

# Check if the members of excludeGroups exists in Entra, and add the ID to the array if it does
$excludeGroupIDs = @()
$excludeGroupsObjects = $policyObject.conditions.users.excludeGroups
if ($excludeGroupsObjects -ieq 'none' -or $null -eq $excludeGroupsObjects -or $excludeGroupsObjects.Count -eq 0) {
    Write-Verbose  "    The policy will be created with the following groups excluded: [None]." -Verbose
}
else {
    Write-Verbose  "    The policy will be created with the following groups excluded: [Select groups]" -Verbose
    foreach ($groupObject in $excludeGroupsObjects) {
        Write-Verbose  "        Checking group: $($groupObject)" -Verbose
        $groupID = ConvertGroupNameToID -displayName $groupObject
        Write-Verbose  "            The following group ID will be excluded from the policy: [$($groupID)]" -Verbose
        if ($groupID) {
            $excludeGroupIDs += $groupID
        }
        else {
            Write-Warning "        Group [$($groupObject)] not found in Entra. Skipping."
        }
    }
}

# Validating the included and excluded applications provided in the policy JSON block
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking Applications to include/exclude as resources..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Regular expression for a valid GUID
$guidRegex = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'

# Check if the included applications exists in Entra, and add the ID to the array if it does
$includeApplicationIDs = @()
$includeApplicationsObjects = $policyObject.conditions.applications.includeApplications
if ($includeApplicationsObjects -ieq 'all') {
    Write-Verbose  "    The policy will be created with the following resources included: [All resources (formerly 'All cloud apps')]." -Verbose
    $includeApplicationIDs = @('all')
}
elseif ($includeApplicationsObjects -ieq 'none' -or $null -eq $includeApplicationsObjects -or $includeApplicationsObjects.Count -eq 0) {
    Write-Verbose  "    The policy will be created with the following resources included: [None]." -Verbose
}
else {
    Write-Verbose  "    The policy will be created with the following resources included: [Select resources]" -Verbose
    foreach ($applicationObject in $includeApplicationsObjects) {
        
        # Confirm if the application is a known resource, and add the ID to the array if it does
        if ($applicationObject -ieq "Office365") {
            Write-Verbose "            The following resource will be included in the policy: [Office 365]" -Verbose
            $includeApplicationIDs += $applicationObject
        }
        elseif ($applicationObject -ieq "MicrosoftAdminPortals") {
            Write-Verbose "            The following resource will be included in the policy: [Microsoft Admin Portals]" -Verbose
            $includeApplicationIDs += $applicationObject
        }
        elseif ($applicationObject -match $guidRegex) {
            Write-Verbose  "            The following resource will be included in the policy: [$($applicationObject)]" -Verbose
            $includeApplicationIDs += $applicationObject
        }
        else {
            Write-Warning "            Application [$($applicationObject)] is not eligible for Conditional Access or not found in Entra. Skipping."
        }
    }
}

# Check if the excluded applications exists in Entra, and add the ID to the array if it does
$excludeApplicationIDs = @()
$excludeApplicationsObjects = $policyObject.conditions.applications.excludeApplications
if ($excludeApplicationsObjects -ieq 'all') {
    Write-Verbose  "    The policy will be created with the following resources excluded: [All applications]." -Verbose
    $excludeApplicationIDs = @('all')
}
elseif ($excludeApplicationsObjects -ieq 'none' -or $null -eq $excludeApplicationsObjects -or $excludeApplicationsObjects.Count -eq 0) {
    Write-Verbose  "    The policy will be created with the following resources excluded: [None]." -Verbose
}
else {
    Write-Verbose  "    The policy will be created with the following resources excluded: [Select resources]" -Verbose
    foreach ($applicationObject in $excludeApplicationsObjects) {
         # Confirm if the application is a known resource, and add the ID to the array if it does
         if ($applicationObject -ieq "Office365") {
            Write-Verbose "            The following resource will be excluded from the policy: [Office 365]" -Verbose
            $excludeApplicationIDs += $applicationObject
        }
        elseif ($applicationObject -ieq "MicrosoftAdminPortals") {
            Write-Verbose "            The following resource will be excluded from the policy: [Microsoft Admin Portals]" -Verbose
            $excludeApplicationIDs += $applicationObject
        }
        elseif ($applicationObject -match $guidRegex) {
            Write-Verbose  "            The following resource will be excluded from the policy: [$($applicationObject)]" -Verbose
            $excludeApplicationIDs += $applicationObject
        }
        else {
            Write-Warning "            Application [$($applicationObject)] is not eligible for Conditional Access or not found in Entra. Skipping."
        }
    }
}

# Confirm the policy definition includes user risk levels
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking User Risk Levels..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define an array to hold the user risk levels
$userRiskLevels = $policyObject.conditions.userRiskLevels
if ($userRiskLevels -ieq 'none' -or $null -eq $userRiskLevels -or $userRiskLevels.Count -eq 0) {
    Write-Warning  "    User risk levels are required for a User Risk Policy." -Verbose
    Write-Warning  "    Exiting pipeline." -Verbose
    exit 1
}
else {
    Write-Verbose  "    The following user risk levels will be applied to in the policy:" -Verbose
    foreach ($userRiskLevel in $userRiskLevels) {
        Write-Verbose  "        $($userRiskLevel)" -Verbose
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
        users = @{
            includeUsers = $includeUserIDs
            excludeUsers = $excludeUserIDs
            includeGroups = $includeGroupIDs
            excludeGroups = $excludeGroupIDs
        }
        applications = @{
            includeApplications = $includeApplicationIDs
            excludeApplications = $excludeApplicationIDs
        }
        userRiskLevels = $userRiskLevels
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
