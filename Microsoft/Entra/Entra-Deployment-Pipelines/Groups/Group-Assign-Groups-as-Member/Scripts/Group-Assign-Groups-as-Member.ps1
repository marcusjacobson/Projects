<#
    .SYNOPSIS
        Adds groups as members to an Entra group based on a JSON input of display names.
        
    .DESCRIPTION
        This script adds groups as members to a specified Entra group by taking a JSON input of display names. 
        It verifies the existence of the target group and groups to add as members in Entra, and then adds the groups as members of the target group. 

    .PARAMETER GroupsJson
        JSON representation of groups to add based on display name. This parameter is mandatory and must be a valid JSON string.

    .PARAMETER GroupName
        The name of the target Entra group to add the groups as members of. This parameter is mandatory, and the script will confirm it is a valid group name.

    .INPUTS
        The script is designed to be run from Azure Pipelines, with variable inputs provided by pipeline-variables.yml.

    .OUTPUTS
        Verbose output indicating the status and verification of all groups, and the result of the member addition process.

    .EXAMPLE
        .\Group-Assign-Groups-as-Members.ps1 -GroupsJson '{"groups":[{"displayName":"Group Name 1"},{"displayName":"Group Name 2"}]}' -GroupName "MyGroup"
        This example adds the groups with the display names "Group Name 1" and "Group Name 2" as members of the Entra group named "MyGroup".

    .NOTES
        File Name      : Group-Assign-Groups-as-Member.ps1
        Author         : Marcus Jacobson
        Version History: 1.0.0, Initial version
        Release        : 2025-03-10 - this is the initial release date
        Updated        : 
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "JSON representation of groups to add based on display name.")]
    [string]$GroupsJson,

    [Parameter(Mandatory = $true,
        HelpMessage = "Entra Group to add the users to.")]
    [string]$GroupName
)

# Verify the $GroupsJson variable is not empty, and has been passed correctly. Exit the script if it fails.
if (-not $GroupsJson) {
    Write-Error "GroupsJson is empty or not passed correctly."
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

# Confirm target group exists in Entra, to add groups to as members
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

    # Store the group object into a variable for future reference
    $targetGroup = $existingGroup.value[0]

    # Store the Group Type of the target group into a variable for future reference
    $targetGroupType = $targetGroup.groupTypes

    # Confirm the group exists, an output if it does. If it does not, write an error and exit the script
    if (-not [String]::IsNullOrEmpty($existingGroup.error)) {
        #Only executes if there is an unknown error.
        Write-Error ('Failed to get group [{0}] because of [{1} - {2}].' -f $GroupName, $existingGroup.error.code, $existingGroup.error.message)
        continue
    }
    elseif ($existingGroup.value -and $existingGroup.value.Count -gt 0) {
        $group = $existingGroup.value[0]
        #Exits the pipeline if the group is a dynamic group, since users cannot be manually added to dynamic groups.
        if ($group.groupTypes -contains "DynamicMembership") {
            Write-Verbose "        $($GroupName) is a dynamic group. Users cannot be manually added to dynamic groups." -Verbose
            Write-Verbose "        Exiting pipeline." -Verbose
            exit 1
        }
        else {
            Write-Verbose  "        $($GroupName) exists with ID $($group.id). Continuing with the user assignments." -Verbose
            Write-Verbose "" -Verbose
            $groupID = $group.id
        }
    }
    else {
        Write-Error ('Group [{0}] does not exist. Please check the group name and try again.' -f $GroupName)
        exit 1
    }
}

# Add groups as members of the target group
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Adding groups as members of $GroupName" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Initialize counters
$noOfMembersAdded = 0

# Deserialize the JSON string into a PowerShell object
$groupObjects = $GroupsJson | ConvertFrom-Json

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
            elseif ($($memberResponse.error.message) -eq "Nesting is currently not supported for groups that can be assigned to a role.") {
                Write-Verbose "        Group $($group.id) is a role group. Bypassing member assignment to the group." -Verbose
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
Write-Verbose  "    Number of groups added as members of $GroupName       : $noOfMembersAdded" -Verbose
Write-Verbose  "" -Verbose

# Exit with an error code only if there were unexpected failures
if ($global:ScriptFailed) {
    exit 1
} else {
    exit 0
}