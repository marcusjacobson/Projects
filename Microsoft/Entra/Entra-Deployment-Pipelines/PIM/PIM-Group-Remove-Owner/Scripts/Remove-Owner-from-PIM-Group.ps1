<#
    .SYNOPSIS
        Removes owners from an Entra PIM group, based on a JSON input of user principal names (UPNs).

    .DESCRIPTION
        This script is designed to remove owners from an Entra PIM group by taking a JSON input of user principal names (UPNs) and the group name. 
        It verifies the existence of the group and users in Entra, and then removes the users' access to the specified PIM group. 

    .PARAMETER UsersJson
        [string] A JSON representation of users to remove based on UPN. This parameter is mandatory.

    .PARAMETER GroupName
        [string] The name of the Entra group to which the users will be removed. This parameter is mandatory.

    .INPUTS
        The script is intended to be run from Azure Pipelines, with variable input provided by pipeline-variables.yml.

    .OUTPUTS
        The script outputs verbose messages indicating the progress and results of the PIM Group assignment process. 
        It also outputs error messages if any issues are encountered.

    .EXAMPLE
        .\Remove-Owner-from-PIM-Group.ps1 -UsersJson '{"users":[{"userPrincipalName":"user1@domain.com"},{"userPrincipalName":"user2@domain.com"}]}' -GroupName "MyEntraGroup"
        This example removes the users with the specified UPNs from the Entra group "MyEntraGroup".

    .NOTES
        File Name      : Remove-Owner-from-PIM-Group.ps1
        Author         : Marcus Jacobson
        Version History: 1.0.0, Initial version
        Release        : 2025-02-24 - this is the initial release date
        Updated        : 
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "JSON representation of users to add based on UPN.")]
    [string]$UsersJson,

    [Parameter(Mandatory = $true,
        HelpMessage = "Entra Group to add the users to.")]
    [string]$GroupName
)

# Verify the $UsersJson variable is not empty, and has been passed correctly. Exit the script if it fails.
if (-not $UsersJson) {
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

# Confirm group exists in Entra to add users to
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Confirming the group $groupName Exists..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Check if the group exists, or write an error if the $GroupName variable is empty
if ($null -ne $GroupName -or $GroupName -ne '') {
    
    # Define group URI 
    $groupUri = 'https://graph.microsoft.com/v1.0/groups?$select=id,displayName&$filter=displayName eq ''{0}'''

    # Create input object to validate if the provided UPN is valid
    $groupInputObject = @{
        method = 'GET'
        uri    = "{0}" -f ($groupUri -f [uri]::EscapeDataString($GroupName))
    }

    # Invoke REST API function to test the inputObject
    $existingGroup = Invoke-RESTCommand @groupInputObject

    # Confirm the group exists, an output if it does. If it does not, write an error and exit the script
    if (-not [String]::IsNullOrEmpty($existingGroup.error)) {
        #Only executes if there is an unknown error.
        Write-Error ('Failed to get group [{0}] because of [{1} - {2}].' -f $GroupName, $existingGroup.error.code, $existingGroup.error.message)
        continue
    }
    elseif ($existingGroup.value -and $existingGroup.value.Count -gt 0) {
        Write-Verbose  "        $($GroupName) exists with ID $($existingGroup.value[0].id). Continuing with the user assignments." -Verbose
        Write-Verbose "" -Verbose
        $groupID = $existingGroup.value[0].id
    }
    else {
        Write-Error ('Group [{0}] does not exist. Please check the group name and try again.' -f $GroupName)
        exit 1
    }
}

# Add users to the group
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Removing PIM Owner assignments to $GroupName" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Initialize counters
$noOfOwnersRemoved = 0

# Deserialize the JSON string into a PowerShell object
$userObjects = $UsersJson | ConvertFrom-Json

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
            Write-Warning ('            Bypassing user [{0}] from removal from the group because it does not exist.' -f $userObject)
            Write-Verbose "" -Verbose
            continue
    }
}

# Remove users from the PIM group as owners
if ($null -ne $users -and $users.Count -gt 0) {
    foreach ($user in $users) {

        # Define the REST URI for assigning eligibility to the PIM group.
        $pimUri = "https://graph.microsoft.com/v1.0/identityGovernance/privilegedAccess/group/eligibilityScheduleRequests"
                        
        # Define the API body for the assignment, with the assignment starting at the date and time the script is run, and ending at one year.
        $startDateTime = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        $endDateTime = (Get-Date).AddYears(1).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

        $ownerBody = @{
                "accessId" = "owner"
                "principalId" = $user.id
                "groupId" = $groupID
                "action" = "AdminRemove"
                "scheduleInfo" = @{
                    "startDateTime" = $startDateTime
                    "expiration" = @{
                        "type" = "AfterDateTime"
                        "endDateTime" = $endDateTime
                    }
                }
                "justification" = "Assign eligible request."
        }

        # Build REST API object
        $ownerInputObject = @{
            method = 'POST'
            uri    = $pimUri
            header = @{"Content-Type" = "application/json"}
            body   = ConvertTo-Json $ownerBody -Depth 10 -Compress
        }

        # Invoke REST API function to test the inputObject
        $ownerResponse = Invoke-RESTCommand @ownerInputObject

        # Check if user is already an owner of the group. If the user is already an owner, output a warning and continue to the next user, otherwise output confirmation the user was added as an owner.
        if (-not [String]::IsNullOrEmpty($ownerResponse.error)) {
            if ($($ownerResponse.error.message) -eq "The Role assignment does not exist.") {
                Write-Verbose "        User $($user.id) is not an existing owner of the group $($GroupName). Bypassing owner assignment to the group." -Verbose
                Write-Verbose "" -Verbose
                Continue
            }
            elseif ($($ownerResponse.error.message) -eq "Resource type not supported for onboarding") {
                Write-Error "           PIM is not enabled for the provided group. Please enable PIM for this group and try again." -Verbose
                $global:ScriptFailed = $true # Set the global ScriptFailed variable to true, to only exit with an error code if there is a failure other than the user already being an owner of the group
            }
            else {
                Write-Error "           Failed to remove user $($user.id) from the group $($GroupName) because of [$($ownerResponse.error.code) - $($ownerResponse.error.message)]." -Verbose
                $global:ScriptFailed = $true # Set the global ScriptFailed variable to true, to only exit with an error code if there is a failure other than the user already being an owner of the group
            }
        }
        else {
            Write-Verbose "        User $($user.id) successfully removed from PIM group $($GroupName) as an owner." -Verbose
            Write-Verbose "" -Verbose
            $noOfOwnersRemoved++
        }
    }
}

# Summary (stats)
Write-Verbose  "-------------------------------------------------" -Verbose
Write-Verbose  "Statistics:" -Verbose
Write-Verbose  "-------------------------------------------------" -Verbose
Write-Verbose  "    Number of users removed from the PIM Group $GroupName as owners       : $noOfOwnersRemoved" -Verbose
Write-Verbose  "" -Verbose

# Exit with an error code only if there were unexpected failures
if ($global:ScriptFailed) {
    exit 1
} else {
    exit 0
}