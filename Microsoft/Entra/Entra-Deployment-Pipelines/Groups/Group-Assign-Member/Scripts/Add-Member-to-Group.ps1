<#
    .SYNOPSIS
        Adds members to an Entra group based on a JSON input of user principal names (UPNs).
        
    .DESCRIPTION
        This script adds members to a specified Entra group by taking a JSON input of user principal names (UPNs). 
        It verifies the existence of the group and users in Entra, and then adds the users to the group. 

    .PARAMETER UsersJson
        JSON representation of users to add based on UPN. This parameter is mandatory and must be a valid JSON string.
    
    .PARAMETER GroupsJson
        JSON representation of groups to add based on display name. This parameter is mandatory and must be a valid JSON string.    

    .PARAMETER GroupName
        The name of the Entra group to add the users to. This parameter is mandatory, and the script will confirm it is a valid group name.

    .INPUTS
        The script is designed to be run from Azure Pipelines, with variable inputs provided by pipeline-variables.yml.

    .OUTPUTS
        Verbose output indicating the status of the group and user verification, and the result of the member addition process.

    .EXAMPLE
        .\Add-Member-to-Group.ps1 -UsersJson '{"users":[{"userPrincipalName":"user1@domain.com"},{"userPrincipalName":"user2@domain.com"}]}' -GroupName "MyGroup"
        This example adds the users with UPNs user1@domain.com and user2@domain.com to the Entra group named "MyGroup".

    .NOTES
        File Name      : Add-Member-to-Group.ps1
        Author         : Marcus Jacobson
        Version History: 1.0.2
        Release        : 2025-02-27 - this is the initial release date
        Updated        : 2025-03-10 - updated with logic to check if the group is a dynamic group
                         2025-03-11 - updated to include the ability to add users or groups as members
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "JSON representation of users to add based on UPN.")]
    [string]$UsersJson,

    [Parameter(Mandatory = $true,
        HelpMessage = "JSON representation of groups to add based on display name.")]
    [string]$GroupsJson,

    [Parameter(Mandatory = $true,
        HelpMessage = "Entra Group to add the users to.")]
    [string]$GroupName
)

# Verify the $UsersJson variable is not empty, and has been passed correctly. Exit the script if it fails.
if (-not $UsersJson -and -not $GroupsJson) {
    Write-Error "No values user or group values provided to add as members to the target group."
    exit 1
}

# Verify the $GroupsName variable is not empty, and has been passed correctly. Exit the script if it fails.
if (-not $GroupName) {
    Write-Error "GroupName is empty or not passed correctly."
    exit 1
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

# Confirm group exists in Entra to add users to
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Confirming the group $groupName Exists..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Check if the group exists, or write an error if the $GroupName variable is empty
if ($null -ne $GroupName -or $GroupName -ne '') {
    
    # Define group URI 
    $groupUri = 'https://graph.microsoft.com/v1.0/groups?$select=id,groupTypes,displayName&$filter=displayName eq ''{0}'''

    # Create input object to validate if the provided UPN is valid
    $groupInputObject = @{
        method = 'GET'
        uri    = "{0}" -f ($groupUri -f [uri]::EscapeDataString($GroupName))
    }

    # Invoke REST API function to test the inputObject
    $existingGroup = Invoke-RESTCommand @groupInputObject

    $group = $existingGroup.value[0]
    $groupID = $group.id  

    # Confirm the group exists, an output if it does. If it does not, write an error and exit the script
    if (-not [String]::IsNullOrEmpty($existingGroup.error)) {
        #Only executes if there is an unknown error.
        Write-Error ('Failed to get group [{0}] because of [{1} - {2}].' -f $GroupName, $existingGroup.error.code, $existingGroup.error.message)
        continue
    }
    elseif ($existingGroup.value -and $existingGroup.value.Count -gt 0) {
        
        #Exits the pipeline if the group is a dynamic group, since assignments cannot be manually added to dynamic groups.
        if ($group.groupTypes -contains "DynamicMembership") {
            Write-Verbose "        $($GroupName) is a dynamic group. Assignments cannot be manually added to dynamic groups." -Verbose
            Write-Verbose "        Exiting pipeline." -Verbose
            exit 1
        }
        else {
            Write-Verbose  "        $($GroupName) exists with ID $($group.id). Continuing with the member assignments." -Verbose
            Write-Verbose "" -Verbose
        }
    }
    else {
        Write-Error ('Group [{0}] does not exist. Please check the group name and try again.' -f $GroupName)
        exit 1
    }
}

# Initialize counters
$noOfMembersAdded = 0

# Add users to the group
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Adding user(s) as members to $GroupName" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Deserialize the JSON string into a PowerShell object
$userObjects = $UsersJson | ConvertFrom-Json

if ($null -eq $userObjects) {
    Write-Verbose "No users have been provided to add as members of the group."
    Write-Verbose "" -Verbose
}

# Create an array empty to capture user UIDs
$users = @()

# Loop through each user object
foreach ($userObject in $userObjects.users) {

    # Define user URI 
    $userUri = 'https://graph.microsoft.com/v1.0/users?$select=id,userPrincipalName&$filter=userPrincipalName eq ''{0}'''
    
    # Create input object to validate if the provided UPN is valid
    $userInputObject = @{
        method = 'GET'
        uri    = "{0}" -f ($userUri -f [uri]::EscapeDataString($userObject.userPrincipalName))
    }
    
    # Invoke REST API function to test the inputObject
    $existingUser = Invoke-RESTCommand @userInputObject
    
    # Check if user exists within Entra. If the user does not exist, output a warning and continue to the next user
    if (-not [String]::IsNullOrEmpty($existingUser.error)) {
        # Only executes if there is an unknown error.
        Write-Error ('Failed to get user [{0}] because of [{1} - {2}].' -f $userObject, $existingUser.error.code, $existingUser.error.message)
        continue
    }
    elseif ($existingUser.value -and $existingUser.value.Count -gt 0) {
            # If the user exists, add the user ID to the users array
            Write-Verbose  "        $($userObject.userPrincipalName) exists in Entra, with the id value of $($existingUser.value[0].id)." -Verbose
            Write-Verbose "" -Verbose
            $users += @{ id = $existingUser.value[0].id }
    }
    else {
            Write-Warning ('        User [{0}] does not exist in Entra. Please check the user name and try again.' -f $userObject)
            Write-Warning ('            Bypassing user [{0}] from assignment to the group because it does not exist.' -f $userObject)
            Write-Verbose "" -Verbose
            continue
    }
}

# Add users to the group as members
if ($null -ne $users -and $users.Count -gt 0) {
    foreach ($user in $users) {
        
        # Manually concatenate the groupURI to include $ref at the end, since explicitly putting it in treats it as a variable.
        $groupUri = "https://graph.microsoft.com/v1.0/groups/$groupId/members/" + "$" + "ref"
                        
        # Define the API body with the correct odata.id format
        $memberBody = @{
            '@odata.id' = "https://graph.microsoft.com/v1.0/directoryObjects/$($user.id)"
        }
        
        # Build REST API object
        $memberInputObject = @{
            method = 'POST'
            uri    = $groupUri
            header = @{"Content-Type" = "application/json"}
            body   = ConvertTo-Json $memberBody -Depth 10 -Compress
        }
        
        # Invoke REST API function to test the inputObject
        $memberResponse = Invoke-RESTCommand @memberInputObject
        
        # Check if user is already a member of the group. If the user is already an member, output a warning and continue to the next user, otherwise output confirmation the user was added as a member.
        if (-not [String]::IsNullOrEmpty($memberResponse.error)) {
            if ($($memberResponse.error.message) -eq "One or more added object references already exist for the following modified properties: 'members'.") {
                Write-Verbose "        User $($user.id) is already a member of group $($GroupName). Bypassing member assignment to the group." -Verbose
                Write-Verbose "" -Verbose
                Continue
            }
            else {
                Write-Error "           Failed to add user $($user.id) to group $($GroupName) because of [$($memberResponse.error.code) - $($memberResponse.error.message)]." -Verbose
                $global:ScriptFailed = $true # Set the global ScriptFailed variable to true, to only exit with an error code if there is a failure other than the user already being a member of the group
            }
        }
        else {
            Write-Verbose "        User $($user.id) successfully added to group $($GroupName)." -Verbose
            Write-Verbose "" -Verbose
            $noOfMembersAdded++
        }
    }
}

# Add groups as members of the target group
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Adding group(s) as members of $GroupName" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Deserialize the JSON string into a PowerShell object
$groupObjects = $GroupsJson | ConvertFrom-Json

if ($null -eq $groupObjects) {
    Write-Verbose "    No groups have been provided to add as members of the group."
    Write-Verbose "" -Verbose
}

# Create an array empty to capture group IDs
$groups = @()

# Loop through each user object
foreach ($groupObject in $groupObjects.groups) {

    # Define user URI 
    $groupUri = 'https://graph.microsoft.com/v1.0/groups?$select=id,displayName&$filter=displayName eq ''{0}'''
    
    # Create input object to validate if the provided display name is valid
    $groupInputObject = @{
        method = 'GET'
        uri    = "{0}" -f ($groupUri -f [uri]::EscapeDataString($groupObject.displayName))
    }
    
    # Invoke REST API function to test the inputObject
    $existingGroup = Invoke-RESTCommand @groupInputObject
    
    # Check if group exists within Entra. If the group does not exist, output a warning and continue to the next group
    if (-not [String]::IsNullOrEmpty($existingGroup.error)) {
        # Only executes if there is an unknown error.
        Write-Error ('Failed to get group [{0}] because of [{1} - {2}].' -f $groupObject, $existingGroup.error.code, $existingGroup.error.message)
        continue
    }
    elseif ($existingGroup.value -and $existingGroup.value.Count -gt 0) {
            # If the group exists, add the group ID to the groups array
            Write-Verbose  "        $($groupObject.displayName) exists in Entra, with the id value of $($existingGroup.value[0].id)." -Verbose
            Write-Verbose "" -Verbose
            $groups += @{ id = $existingGroup.value[0].id }
    }
    else {
            Write-Warning ('        Group [{0}] does not exist in Entra. Please check the group name and try again.' -f $userObject)
            Write-Warning ('            Bypassing group [{0}] from assignment to the target group because it does not exist.' -f $userObject)
            Write-Verbose "" -Verbose
            continue
    }
}

# Add groups to the target group as members
if ($null -ne $groups -and $groups.Count -gt 0) {
    foreach ($group in $groups) {
        
        # Manually concatenate the groupURI to include $ref at the end, since explicitly putting it in treats it as a variable.
        $groupUri = "https://graph.microsoft.com/v1.0/groups/$groupId/members/" + "$" + "ref"
                        
        # Define the API body with the correct odata.id format
        $memberBody = @{
            '@odata.id' = "https://graph.microsoft.com/v1.0/directoryObjects/$($group.id)"
        }
        
        # Build REST API object
        $memberInputObject = @{
            method = 'POST'
            uri    = $groupUri
            header = @{"Content-Type" = "application/json"}
            body   = ConvertTo-Json $memberBody -Depth 10 -Compress
        }
        
        # Invoke REST API function to test the inputObject
        $memberResponse = Invoke-RESTCommand @memberInputObject
        
        # Check if group is already a member of the target group. If the group is already an member, output a warning and continue to the next group, otherwise output confirmation the group was added as a member.
        if (-not [String]::IsNullOrEmpty($memberResponse.error)) {
            if ($($memberResponse.error.message) -eq "One or more added object references already exist for the following modified properties: 'members'.") {
                Write-Verbose "        Group $($group.id) is already a member of group $($GroupName). Bypassing member assignment to the group." -Verbose
                Write-Verbose "" -Verbose
                Continue
            }
            elseif ($($memberResponse.error.message) -like "*Nesting is currently not supported for groups that can be assigned to a role.*"){
                Write-Verbose "        $($GroupName) has an assigned role. Groups cannot be added as members to role-assigned groups." -Verbose
                Write-Verbose "            Bypassing group $($group.id) from member assignment to $($GroupName)." -Verbose
                Write-Verbose "" -Verbose
                Continue
            }
            else {
                Write-Error "           Failed to add group $($group.id) as a member of group $($GroupName) because of [$($memberResponse.error.code) - $($memberResponse.error.message)]." -Verbose
                $global:ScriptFailed = $true # Set the global ScriptFailed variable to true, to only exit with an error code if there is a failure other than the group already being a member of the target group
            }
        }
        else {
            Write-Verbose "        Group $($group.id) successfully added as a member of group $($GroupName)." -Verbose
            Write-Verbose "" -Verbose
            $noOfMembersAdded++
        }
    }
}

# Summary (stats)
Write-Verbose  "-------------------------------------------------" -Verbose
Write-Verbose  "Statistics:" -Verbose
Write-Verbose  "-------------------------------------------------" -Verbose
Write-Verbose  "    Number of members added to $GroupName       : $noOfMembersAdded" -Verbose
Write-Verbose  "" -Verbose

# Exit with an error code only if there were unexpected failures
if ($global:ScriptFailed) {
    exit 1
} else {
    exit 0
}