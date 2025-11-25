<#
    .SYNOPSIS
        This script creates groups in Microsoft Entra ID using REST API calls.

    .DESCRIPTION
        The script reads a JSON string containing group definitions and creates the groups in Microsoft Entra ID. 
        It validates the input parameters, checks if the group already exists, and creates the group if it does not. 
        The script also assigns members and owners to the groups and handles dynamic membership rules and role assignments.

    .PARAMETER GroupsJson
        [string] The JSON string containing the group definitions. This parameter is mandatory.

    .INPUTS
        The script is designed to be run from Azure Pipelines, with input variables provided by pipeline-variables.yml.

    .OUTPUTS
        The script outputs verbose messages indicating the progress and results of the group creation process. 
        It also outputs error messages if any issues are encountered.

    .EXAMPLE
        .\create-groups.ps1 -GroupsJson $GroupsJson
        This example runs the script with the specified JSON string containing the group definitions.

    .NOTES
        File Name      : create-groups.ps1
        Author         : Marcus Jacobson
        Version History: 1.0.0 > 1.0.1 
        Release        : 2025-02-27 - this is the initial release date
        Updated        : 2025-03-04 (1.0.1) - Processes user input variable as userPrincipalName instead of id
                         2025-03-11 (1.0.2) - Added support for adding groups as members
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [string]$GroupsJson
)

# Verify the $GroupsJson variable is not empty, and has been passed correctly. Exit the script if it fails.
if (-not $GroupsJson) {
    Write-Error "GroupsJson is empty or not passed correctly."
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

# Initialize counters
$noOfGroupsCreated = 0

# Deserialize the JSON string into a PowerShell object
$groupObjects = $GroupsJson | ConvertFrom-Json

foreach ($group in $groupObjects.groups) {
    Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
    Write-Verbose  "Creating group $($group.displayName) - $($group.groupDescription)" -Verbose
    Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
    
    # Define Group Parameters
    $displayName = $group.displayName
    $mailNickname = $group.mailNickname
    $groupDescription = $group.groupDescription
    $securityEnabled = $group.securityEnabled
    $mailEnabled = $group.mailEnabled
    $isAssignableToRole = $group.isAssignableToRole
    $groupTypes = $group.groupTypes

    # Assign role attribute if the group is role assignable, or remove the role assignment if the group is not role assignable
    if ($isAssignableToRole -eq $true) {
        $role = $group.role
    }
    else {
        Write-Warning "    The group [$displayName] is not role assignable. Removing declared role assignment: $($role)"
        Write-Verbose "" -Verbose
        $role = $null
    }

    # Assign dynamicMembershipRule attribute if the group is DynamicMembership
    if ($groupTypes -eq 'DynamicMembership') {
        $dynamicMembershipRule = $group.dynamicMembershipRule
        if ($mailEnabled -eq $true) {
            # Output a warning message if the group is mail enabled with Dynamic Membership
            Write-Warning "    The group [$displayName] cannot be mail enabled with Dynamic Membership. Changing mailEnabled value to false."
            Write-Verbose "" -Verbose
            $mailEnabled = $false
        }
    }
    elseif ($groupTypes -eq 'Unified' -and ($null -ne $dynamicMembershipRule -or $dynamicMembershipRule -ne '' -or $dynamicMembershipRule -ne "")) {
        # Output a warning message if the group is Unified with a dynamic membership rule
        Write-Warning "    The group [$displayName] cannot be created with as a Unified group with a dynamic membership rule. Removing dynamicMembershipRule."
        Write-Verbose "" -Verbose
        $dynamicMembershipRule = $null
    }
    else {
        # Output a generic warning message if there is another groupType mismatch
        Write-Warning "        The group type '$groupType' is not valid for $displayName. Please check the group type and try again."
        Write-Verbose "" -Verbose
    }

    # Error check for invalid parameter assignments when isAssignableToRole is set to $true. Exit the pipeline if mismatch is found.
    if ($isAssignableToRole -eq $true -and $securityEnabled -ne $true) {
        Write-Error "Group [$displayName] cannot be created because 'securityEnabled' must be true when 'isAssignableToRole' is true."
        exit 1
    } elseif ($isAssignableToRole -eq $true -and $groupTypes -eq 'DynamicMembership') {
        Write-Error "Group [$displayName] cannot be created with a role assignment if with Dynamic Membership is enabled. Please either set 'isAssignableToRole' as False, or set the groupType as '[Unified]'."
        exit 1
    }

    # If one or more users as members are provided, validate if the members(s) exist in Entra and assign them to the members object if they are valid and exist in Entra.
    if ($null -ne $group.membersUsers -or $group.membersUsers -ne '') {
        
        $members = @()
        # Validate and assign members
        foreach ($memberObject in $group.membersUsers) {

            Write-Verbose  "    Validating user to assign as member - $($memberObject.userPrincipalName)" -Verbose
            
            # Define member URI 
            $memberUri = 'https://graph.microsoft.com/v1.0/users?$select=id,userPrincipalName&$filter=userPrincipalName eq ''{0}'''
            
            # Create input object to validate if the member ID is a valid user GUID
            $memberInputObject = @{
                method = 'GET'
                uri    = "{0}" -f ($memberUri -f [uri]::EscapeDataString($memberObject.userPrincipalName))
            }
            
            # Invoke REST API function to test the inputObject
            $existingMember = Invoke-RESTCommand @memberInputObject
            
            # Check if user exists within Entra. If the user does not exist, output a warning and continue to the next user
            if (-not [String]::IsNullOrEmpty($existingMember.error)) {
                # Only executes if there is an unknown error.
                Write-Error ('Failed to get user [{0}] because of [{1} - {2}].' -f $memberObject, $existingMember.error.code, $existingMember.error.message)
                continue
            }
            elseif ($existingMember.value -and $existingMember.value.Count -gt 0) {
                    # If the user exists, add the user ID to the members array
                    Write-Verbose  "        $($memberObject.userPrincipalName) exists in Entra, with the id value of $($existingMember.value[0].id)." -Verbose
                    Write-Verbose "" -Verbose
                    $members += @{ id = $existingMember.value[0].id }
            }
            else {
                    Write-Warning ('        User [{0}] does not exist in Entra. Please check the user name and try again.' -f $memberObject)
                    Write-Warning ('            Bypassing user [{0}] from assignment to the group as a member because it does not exist.' -f $memberObject)
                    Write-Verbose "" -Verbose
                    continue
            }
        }
    }

    # If one or more groups as members are provided, validate if the members(s) exist in Entra and assign them to the members object if they are valid and exist in Entra.
    if ($null -ne $group.membersGroups -or $group.membersGroups -ne '') {
        
        # Validate and assign members
        foreach ($memberObject in $group.membersGroups) {

            Write-Verbose  "    Validating group to assign as member - $($memberObject.displayName)" -Verbose
            
            # Define member URI 
            $memberUri = 'https://graph.microsoft.com/v1.0/groups?$select=id,displayName&$filter=displayName eq ''{0}'''
            
            # Create input object to validate if the member ID is a valid user GUID
            $memberInputObject = @{
                method = 'GET'
                uri    = "{0}" -f ($memberUri -f [uri]::EscapeDataString($memberObject.displayName))
            }
            
            # Invoke REST API function to test the inputObject
            $existingMember = Invoke-RESTCommand @memberInputObject
            
            # Check if group exists within Entra. If the group does not exist, output a warning and continue to the next group
            if (-not [String]::IsNullOrEmpty($existingMember.error)) {
                # Only executes if there is an unknown error.
                Write-Error ('Failed to get group [{0}] because of [{1} - {2}].' -f $memberObject, $existingMember.error.code, $existingMember.error.message)
                continue
            }
            elseif ($existingMember.value -and $existingMember.value.Count -gt 0) {
                    # If the user exists, add the user ID to the members array
                    Write-Verbose  "        $($memberObject.displayName) exists in Entra, with the id value of $($existingMember.value[0].id)." -Verbose
                    Write-Verbose "" -Verbose
                    $members += @{ id = $existingMember.value[0].id }
            }
            else {
                    Write-Warning ('        Group [{0}] does not exist in Entra. Please check the group name and try again.' -f $memberObject)
                    Write-Warning ('            Bypassing group [{0}] from assignment to the group as a member because it does not exist.' -f $memberObject)
                    Write-Verbose "" -Verbose
                    continue
            }
        }
    }

    # If one or more owners are provided, validate if the owner(s) exist in Entra and assign them to the owners object if they are valid and exist in Entra.
    if ($null -ne $group.owners -or $group.owners -ne '') {
        
        
        $owners = @()
        # Validate and assign owners
        foreach ($OwnerObject in $group.owners) {
            
            Write-Verbose  "    Validating owner - $($OwnerObject.userPrincipalName)" -Verbose
            
            # Define owner URI
            $ownerUri = 'https://graph.microsoft.com/v1.0/users?$select=id,userPrincipalName&$filter=userPrincipalName eq ''{0}'''
            
            # Create input object to validate if the owner ID is a valid user GUID
            $ownerInputObject = @{
                method = 'GET'
                uri    = "{0}" -f ($ownerUri -f [uri]::EscapeDataString($ownerObject.userPrincipalName))
            }
            
            # Invoke REST API function to test the inputObject
            $existingOwner = Invoke-RESTCommand @ownerInputObject
            
            # Check if user exists within Entra. If the user does not exist, output a warning and continue to the next user
            if (-not [String]::IsNullOrEmpty($existingOwner.error)) {
                # Only executes if there is an unknown error.
                Write-Error ('Failed to get user [{0}] because of [{1} - {2}].' -f $ownerObject, $existingOwner.error.code, $existingOwner.error.message)
                continue
            }
            elseif ($existingOwner.value -and $existingOwner.value.Count -gt 0) {
                    # If the user exists, add the user ID to the owners array
                    Write-Verbose  "        $($ownerObject.userPrincipalName) exists in Entra, with the id value of $($existingOwner.value[0].id)." -Verbose
                    Write-Verbose "" -Verbose
                    $owners += @{ id = $existingOwner.value[0].id }
            }
            else {
                    Write-Warning ('        User [{0}] does not exist in Entra. Please check the user name and try again.' -f $ownerObject)
                    Write-Warning ('            Bypassing user [{0}] from assignment to the group as an owner because it does not exist.' -f $ownerObject)
                    Write-Verbose "" -Verbose
                    continue
            }
        }
    }

    # Check if group already exists
    $restUri = 'https://graph.microsoft.com/v1.0/groups?$select=id,displayName&$filter=displayName eq ''{0}'''
    $restInputObject = @{
        method = 'GET'
        uri    = "{0}" -f ($restUri -f [uri]::EscapeDataString($displayName))
    }
    $existingGroup = Invoke-RESTCommand @restInputObject
    if (-not [String]::IsNullOrEmpty($existingGroup.error)) {
        Write-Error ('Failed to get group [{0}] because of [{1} - {2}].' -f $displayName, $existingGroup.error.code, $existingGroup.error.message)
        continue
    }
    
    # Create groups groups that do not already exist
    if ( -not $existingGroup.value[0]) {
        Write-Verbose  "    Creating group - ($displayName)" -Verbose

        # Build REST API object components
        if ($PSCmdlet.ShouldProcess(("Group [{0}]" -f $displayName), "Create")) {
            $restUri = 'https://graph.microsoft.com/v1.0/groups'
            $body = @{ 
                'displayName'        = $displayName
                'description'        = $groupDescription
                'mailNickname'       = $mailNickname
                'mailEnabled'        = $mailEnabled
                'securityEnabled'    = $securityEnabled
                'isAssignableToRole' = $isAssignableToRole
            }
            
            # Add groupType if isAssignableToRole is false, and the groupType is set to DynamicMembership. 
            # Unified groups are created with groupType as 'Unified' by default.  
            if ($isAssignableToRole -eq $false -and $groupTypes -eq 'DynamicMembership') {
                $body.groupTypes = @('DynamicMembership')
            }

            # Add dynamicMembershipRule if groupType is DynamicMembership
            if ($groupTypes -eq 'DynamicMembership' -and -not [String]::IsNullOrEmpty($dynamicMembershipRule)) {
                # Ensure the dynamicMembershipRule is correctly formatted
                $formattedMembershipRule = $dynamicMembershipRule -replace '\s+', ' ' # Remove extra spaces
                $formattedMembershipRule = $formattedMembershipRule.Trim() # Trim leading and trailing spaces

                # Add dynamicMembershipRule to the body
                $body.membershipRule = $formattedMembershipRule
                $body.membershipRuleProcessingState = "On"
            }

            # Build REST API object
            $restInputObject = @{
                method = 'POST'
                uri    = "{0}" -f $restUri
                header = @{
                    "Content-Type" = "application/json"
                }
                body   = ConvertTo-Json $body -Depth 10 -Compress
            }
            
            # Invoke REST API function to create group
            $addResponse = Invoke-RESTCommand @restInputObject
            if (-not [String]::IsNullOrEmpty($addResponse.error)) {
                if ($addResponse.error.code -eq 'DynamicGroupQueryParseError') {
                    # Output a descriptive error message if the dynamicMembershipRule syntax is invalid, then end the script.
                    Write-Warning ('Failed to create group [{0}] details because of [{1} - {2}].' -f $displayName, $addResponse.error.code, $addResponse.error.message)
                    Write-Warning ('If using a Dynamic Membership rule, use the appropriate syntax with the correct escape characters before double quotes.')   
                    Write-Warning ('Correct Syntax Example: "dynamicMembershipRule": "(user.department -eq \"Sample Department\")"')
                    exit 1
                }
                else {
                    # Output a generic error message if the group creation fails for any other reason
                    Write-Error ('Failed to create group [{0}] details because of [{1} - {2}].' -f $displayName, $addResponse.error.code, $addResponse.error.message)
                }
            }
            # Check if group was successfully created
            if ($addResponse.DisplayName -eq $displayName) {
                $groupId = $addResponse.Id
                Write-Verbose  "        Group successfully created." -Verbose
                # Iterate group creation counter
                $noOfGroupsCreated++
                
                # Output a message if the group is role assignable but no role is provided
                if ($role -eq $null -or $role -eq '') { 
                    Write-Verbose  "        No provided role to assign for the group $($displayName)" -Verbose
                }
                elseif ($isAssignableToRole -eq $true) {
                    # Start process to assign role to the group
                    Write-Verbose "        Assigning role - ($role) to group - ($displayName)" -Verbose
                    
                    #Build REST API input object to check if role is valid
                    $roleUri = 'https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?$select=displayName&$filter=displayName eq ''{0}'''
                    $roleInputObject = @{
                        method = 'GET'
                        uri    = "{0}" -f ($roleUri -f [uri]::EscapeDataString($role))
                    }
                    
                    # Invoke REST API function to check role definition
                    $roleDefinition = Invoke-RESTCommand @roleInputObject
                    
                    # Check the API output to confirm if the role definition is valid, and only assign the role if valid
                    if (-not $roleDefinition.value -or $roleDefinition.value.Count -eq 0) {
                        # Output warning message if the role is not valid, and bypass the role assignment
                        Write-Warning "            The role '$role' is not valid. Please check the role name and try again."
                        Write-Verbose "            The group will be created without the assigned role" -Verbose
                        Write-Verbose "" -Verbose
                        continue
                    }
                    else {
                    
                        # Get roleId for the valid role              
                        $roleId = $roleDefinition.value[0].id
                        
                        # Define attributes for role assignment Rest API object
                        $roleAssignmentUri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments"
                        $roleAssignmentBody = @{
                            "principalId" = $groupId
                            "roleDefinitionId" = $roleId
                            "directoryScopeId" = "/"
                        }
                        
                        # Build role assignment Rest API object
                        $roleAssignmentInputObject = @{
                            method = 'POST'
                            uri    = $roleAssignmentUri
                            header = @{"Content-Type" = "application/json"}
                            body   = ConvertTo-Json $roleAssignmentBody -Depth 10 -Compress
                        }

                        # Invoke REST API function to assign role
                        $roleAssignmentResponse = Invoke-RESTCommand @roleAssignmentInputObject

                        # Check successful role assignment, and output an error if the role assignment fails. End the script on an error.
                        if (-not [String]::IsNullOrEmpty($roleAssignmentResponse.error)) {
                            Write-Error ('Failed to assign role [{0}] to group [{1}] because of [{2} - {3}].' -f $role, $displayName, $roleResponse.error.code, $roleResponse.error.message)
                        }
                        else {
                            # Output confirmation of successful role assignment
                            Write-Verbose "        $($role) successfully assigned to $($displayName)." -Verbose
                        }
                    }
                }
                else {
                    # Output message if the role assignable group was created without a role
                    Write-Verbose "        The group has been created without an assigned role" -Verbose
                    Write-Verbose "" -Verbose
                }

                # Add members to the group
                if ($null -ne $members -and $members.Count -gt 0) {
                    foreach ($member in $members) {
                        # Manually concatenate the groupURI to include $ref at the end, since explicitly putting it in treats it as a variable.
                        $groupUri = "https://graph.microsoft.com/v1.0/groups/$groupId/members/" + "$" + "ref"
                        
                        # Define the API body with the correct odata.id format
                        $memberBody = @{
                            '@odata.id' = "https://graph.microsoft.com/v1.0/directoryObjects/$($member.id)"
                        }
                        
                        # Build REST API object
                        $memberInputObject = @{
                            method = 'POST'
                            uri    = $groupUri
                            header = @{"Content-Type" = "application/json"}
                            body   = ConvertTo-Json $memberBody -Depth 10 -Compress
                        }
                        $memberResponse = Invoke-RESTCommand @memberInputObject
                        if ($($memberResponse.error.message) -like "*Nesting is currently not supported for groups that can be assigned to a role.*"){
                            Write-Verbose "        The target group has an assigned role. Groups cannot be added as members to role-assigned groups." -Verbose
                            Write-Verbose "            Bypassing group $($member.id) from member assignment." -Verbose
                            Continue
                        }
                        elseif (-not [String]::IsNullOrEmpty($memberResponse.error)) {
                            Write-Error ('Failed to add member [{0}] to group [{1}] because of [{2} - {3}].' -f $member.id, $displayName, $memberResponse.error.code, $memberResponse.error.message)
                        } 
                        else {
                            Write-Verbose "        Member $($member.id) successfully added to group $($displayName)." -Verbose
                        }
                    }
                }

                # Add owners to the group
                if ($null -ne $owners -and $owners.Count -gt 0) {
                    foreach ($owner in $owners) {
                        # Manually concatenate the groupURI to include $ref at the end, since explicitly putting it in treats it as a variable.
                        $groupUri = "https://graph.microsoft.com/v1.0/groups/$groupId/owners/" + "$" + "ref"
                        
                        # Define the API body with the correct odata.id format
                        $ownerBody = @{
                            '@odata.id' = "https://graph.microsoft.com/v1.0/users/$($owner.id)"
                        }
                        
                        # Build REST API object
                        $ownerInputObject = @{
                            method = 'POST'
                            uri    = $groupUri
                            header = @{"Content-Type" = "application/json"}
                            body   = ConvertTo-Json $ownerBody -Depth 10 -Compress
                        }
                        $ownerResponse = Invoke-RESTCommand @ownerInputObject
                        if (-not [String]::IsNullOrEmpty($ownerResponse.error)) {
                            Write-Error ('Failed to add owner [{0}] to group [{1}] because of [{2} - {3}].' -f $owner.id, $displayName, $ownerResponse.error.code, $ownerResponse.error.message)
                        } else {
                            Write-Verbose "        Owner $($owner.id) successfully added to group $($displayName)." -Verbose
                        }
                    }
                }

                # wait 5 sec to avoid throttling
                Start-Sleep -s 5
            }
            $addResponse = $null
            Write-Verbose "" -Verbose
        }
    }
    else {
        # Output message if group already exists
        Write-Verbose  "    Group exists - ($displayName)!" -Verbose
        Write-Verbose  "        $displayName will not be created." -Verbose
        Write-Verbose  "" -Verbose
    }
}

# Summary (stats)
Write-Verbose  "-------------------------------------------------" -Verbose
Write-Verbose  "Statistics:" -Verbose
Write-Verbose  "-------------------------------------------------" -Verbose
Write-Verbose  "    Number of groups created       : $noOfGroupsCreated" -Verbose
Write-Verbose  "" -Verbose