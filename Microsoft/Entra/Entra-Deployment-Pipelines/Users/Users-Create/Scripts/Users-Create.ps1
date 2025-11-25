<#
    .SYNOPSIS
        This script creates new Microsoft Entra users and assigns group membership based on user definition. 
        User creation is validated against a JSON schema. 
        The script is designed to be run in Azure DevOps pipelines.
        
    .DESCRIPTION
        After validating the user definitions against the schema, the script creates users in Microsoft Entra and assigns them to groups specified in their user definition. 
        The user's manager is also validated and assigned if one is provided.
    
    .PARAMETER UserJson
        Required. JSON representation of users to create.

    .PARAMETER UsersSchemaFilePath
        Required. Path to the user definition JSON schema.

    .PARAMETER TenantFqdn
        Required. FQDN of the Entra tenant, e.g. yourcompany.onmicrosoft.com or yourcompany.com.

    .INPUTS
        Users-Create/Pipeline/pipeline.yml, Users-Create/Pipeline/pipeline-variables.yml (as input for pipeline.yml)
        To run this script, create a branch from Main in your Azure DevOps environment, and edit the pipeline-variables.yml file to include the user definitions.
        Upon committing the update and performing a pull request into Main, the pipeline will run and create the users in Entra.
        No edits to pipeline.yml or this script are required to create the new users.

    .OUTPUTS
        Azure DevOps Pipeline, as a method to provision users into Entra.

    .NOTES
        File Name      : Users-Create.ps1
        Author         : Marcus Jacobson (evolved from original Set-EnvironmentUsers.ps1 script built by Tomaz Mlakar)
        Version History: 2.0.0, Simplified generic version
        Release        : 2025-03-03 - this is the initial release date
        Updated        : 2025-10-23 - Simplified to generic group assignment model
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "JSON representation of users to add.")]
    [string]$UserJson,

    [Parameter(Mandatory = $true,
        HelpMessage = "Path to the Users definition JSON schema.")]
    [string]$UsersSchemaFilePath,

    [Parameter(Mandatory = $true,
        HelpMessage = "FQDN of the Entra tenant, e.g. yourcompany.onmicrosoft.com or yourcompany.com.")]
    [string]$TenantFqdn
)

#region Helper functions

function New-RandomPassword {
    $pass = New-Object -TypeName PSObject
    $pass | Add-Member -MemberType ScriptProperty -Name "Password" -Value { ("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | Sort-Object { Get-Random })[0..8] -join '' }
    $pass
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
            $inputObject += '--headers', "@$tmpPathHeader"
        }

        # Execute
        # -------
        try {
            $rawResponse = az rest @inputObject -o json 2>&1
            #Write-Verbose  "REST response: $rawResponse" -Verbose
        }
        catch {
            $rawResponse = $_
            #Write-Verbose  "REST error: $rawResponse" -Verbose
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

#endregion

# Initialize counters
$noOfUsersCreated = 0

# Deserialize the JSON string into a PowerShell object
# $userObjects = $UserJson | ConvertFrom-Json

# Load the User definition schema
$Schema = Get-Content -Path $UsersSchemaFilePath -Raw -ErrorAction Stop

Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Validating user definitions against the schema..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Validate the user definitions against the schema
try {
    $userJson | Test-Json -Schema $Schema -ErrorAction Stop | Out-Null
    Write-Verbose  "    The provided user definitions are compliant with the schema." -Verbose
}
catch {
    Write-Error "    The JSON file is not compliant with the schema. Error: $_" -ErrorAction Stop
}

# Deserialize the JSON string into a PowerShell object
try {
    $userDefinitions = $UserJson | ConvertFrom-Json
}
catch {
    Write-Error "Failed to convert UserJson to a PowerShell object. Error: $_"
    throw
}

# Create PowerShell object of user records
$userObjects = @() #Array for user objects to assign

foreach ($userDefinition in $userDefinitions.users) {
    Write-Verbose "        Adding $($userDefinition.firstName) $($userDefinition.lastName) to the user list." -Verbose
    $userObjects += $userDefinition
}
Write-Verbose "" -Verbose

foreach ($userObject in $userObjects) {
    Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
    Write-Verbose  "Creating user $($userObject.firstName) $($userObject.lastName)..." -Verbose
    Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

    $displayName = "{0} {1}" -f $userObject.firstName, $userObject.lastName
    $password = New-RandomPassword
    $mailNickname = "{0}.{1}" -f $($userObject.firstName -replace ' ', '').ToLower(), $($userObject.lastName -replace ' ', '').ToLower()
    $upn = "{0}@{1}" -f $mailNickname, $TenantFqdn

    # Get groups from user definition (if provided)
    $groups = @()
    if ($userObject.groups -and $userObject.groups.Count -gt 0) {
        $groups = $userObject.groups
    }
    
    # Check if user already exists, write a warning if the user dies not exist and continue to the next user
    $restUri = 'https://graph.microsoft.com/v1.0/users?$select=id,displayName&$filter=userPrincipalName eq ''{0}'''
    $restInputObject = @{
        method = 'GET'
        uri    = "{0}" -f ($restUri -f [uri]::EscapeDataString($upn))
    }
    $existingUser = Invoke-RESTCommand @restInputObject

    if (-not [String]::IsNullOrEmpty($existingUser.error)) {
        Write-Warning ('    Failed to get user [{0}] because of [{1} - {2}].' -f $displayName, $existingUser.error.code, $existingUser.error.message)
        Write-Warning ('        Bypassing user creation.')
        Write-Verbose "" -Verbose
        continue
    }

    # Define REST attributes and perform the user creation API call
    if ( -not $existingUser.value[0]) {
        if ($PSCmdlet.ShouldProcess(("User [{0}]" -f $displayName), "Create")) {
            $restUri = 'https://graph.microsoft.com/v1.0/users'
            $body = @{ 
                'accountEnabled'    = 'true'
                'displayName'       = $displayName
                'userPrincipalName' = $upn
                'mailNickname'      = $mailNickname
                'passwordProfile'   = $passwordProfile
                'givenName'         = $userObject.firstName
                'surname'           = $userObject.lastName
                'usageLocation'     = $userObject.location
            }
            $body['passwordProfile'] = @{
                'forceChangePasswordNextSignIn' = true
                'password'                      = "{0}" -f $password
            }
            # Add optional properties if provided
            if (-not [String]::IsNullOrEmpty($userObject.company)) { $body['companyName'] = $userObject.company }
            if (-not [String]::IsNullOrEmpty($userObject.department)) { $body['department'] = $userObject.department }
            if (-not [String]::IsNullOrEmpty($userObject.mobilePhone)) { $body['mobilePhone'] = $userObject.mobilePhone }
            if (-not [String]::IsNullOrEmpty($userObject.alternateEmail)) { $body['otherMails'] = @($userObject.alternateEmail) }
            if (-not [String]::IsNullOrEmpty($userObject.jobTitle)) { $body['jobTitle'] = $userObject.jobTitle }
            $restInputObject = @{
                method = 'POST'
                uri    = "{0}" -f $restUri
                header = @{
                    "Content-Type" = "application/json"
                }
                body   = ConvertTo-Json $body -Depth 10 -Compress
            }
            $addResponse = Invoke-RESTCommand @restInputObject
            if (-not [String]::IsNullOrEmpty($addResponse.error)) {
                Write-Error ('Failed to create user [{0}] details because of [{1} - {2}].' -f $displayName, $addResponse.error.code, $addResponse.error.message)
            }
            # Check success
            if ($addResponse.DisplayName -eq $displayName) {
                $userId = $addResponse.Id
                Write-Verbose  "    User $($displayName) successfully created." -Verbose
                # wait 5 sec
                Start-Sleep -s 5
                $noOfUsersCreated++
            }
            $addResponse = $null
        }
        
        # Assign manager to user if the declared manager exists
        if ($userObject.manager) {
            # Check user manager exists
            $restUri = 'https://graph.microsoft.com/v1.0/users?$select=id,displayName&$filter=userPrincipalName eq ''{0}'''
            $restInputObject = @{
                method = 'GET'
                uri    = "{0}" -f ($restUri -f [uri]::EscapeDataString($userObject.manager))
            }
            
            $existingManager = Invoke-RESTCommand @restInputObject

            # Assign manager to user if the declared manager exists, or output a warning if the manager does not exist
            if (-not [String]::IsNullOrEmpty($existingManager.error) -and (-not $existingManager.error -eq 'Request_ResourceNotFound')) {
                Write-Error ('Failed to get manager for user [{0}] because of [{1} - {2}].' -f $displayName, $existingManager.error.code, $existingManager.error.message)
                continue
            }
            else {          
                try {
                    $managerId = $existingManager.value[0].id
                    Write-Verbose  "        Assigning manager - ($($userObject.manager)) for user ($displayName)" -Verbose
                }
                Catch {
                    Write-Verbose  "        Manager - ($($userObject.manager)) does not exist!" -Verbose
                }
                
                $restUri = 'https://graph.microsoft.com/v1.0/users/{0}/manager/$ref'
                $body = @{ 
                    '@odata.id' = 'https://graph.microsoft.com/v1.0/users/{0}' -f $managerId 
                }
                $restInputObject = @{
                    method = 'PUT'
                    uri    = "{0}" -f ($restUri -f $userId)
                    header = @{
                        "Content-Type" = "application/json"
                    }
                    body   = ConvertTo-Json $body -Depth 10 -Compress
                }

                $addManagerResponse = Invoke-RESTCommand @restInputObject

                if (-not [String]::IsNullOrEmpty($addManagerResponse.error)) {
                    Write-Error ('Failed to assign manager [{0}] to user [{1}] because of [{2} - {3}].' -f $userObject.manager, $displayName, $addManagerResponse.error.code, $addManagerResponse.error.message)
                }
                else {
                    Write-Verbose  "            Manager ($($userObject.manager)) successfully assigned to user ($displayName)." -Verbose
                }
            }
        }
        else {
            Write-Verbose  "         No manager provided to assign to user user ($displayName)." -Verbose
        }

        # Assign group membership
        
        foreach ($group in $groups) {
        
            $group = $group.Trim()
            
            # Check group exists
            $restUri = 'https://graph.microsoft.com/v1.0/groups?$select=id,displayName&$filter=displayName eq ''{0}'''
            $restInputObject = @{
                method = 'GET'
                uri    = "{0}" -f ($restUri -f [uri]::EscapeDataString($group))
            }
            $existingGroup = Invoke-RESTCommand @restInputObject
            if (-not [String]::IsNullOrEmpty($existingGroup.error)) {
                Write-Error ('Failed to get group [{0}] because of [{1} - {2}].' -f $displayName, $existingGroup.error.code, $existingGroup.error.message)
                continue
            }
            if (-not $existingGroup.value[0]) {
                Write-Verbose  "     Group - ($group) cannot be found!" -Verbose
                continue
            }
            $groupId = $existingGroup.value[0].id

            # Check currently assigned membership to existing group
            $restUri = 'https://graph.microsoft.com/v1.0/users/{0}/memberOf'
            $restInputObject = @{
                method = 'GET'
                uri    = "{0}" -f ($restUri -f $userId)
            }

            $members = Invoke-RESTCommand @restInputObject

            if (-not [String]::IsNullOrEmpty($members.error)) {
                Write-Error ('Failed to get group members [{0}] because of [{1} - {2}].' -f $group, $members.error.code, $members.error.message)
                continue
            }

            # Membership add target user to the group
            if (-not (($members.value | Select-Object id) -match $groupId)) {
                Write-Verbose  "        Adding membership - ($group) for user ($displayName)" -Verbose

                if ($PSCmdlet.ShouldProcess(("Membership [{0}/{1}]" -f $group, $displayName ), "Add")) {
                    $restUri = 'https://graph.microsoft.com/v1.0/groups/{0}/members/$ref'
                    $body = @{ 
                        '@odata.id' = 'https://graph.microsoft.com/v1.0/directoryObjects/{0}' -f $userId 
                    }
                    $restInputObject = @{
                        method = 'POST'
                        uri    = "{0}" -f ($restUri -f $groupId)
                        header = @{
                            "Content-Type" = "application/json"
                        }
                        body   = ConvertTo-Json $body -Depth 10 -Compress
                    }
                    $addResponse = Invoke-RESTCommand @restInputObject
                    if (-not [String]::IsNullOrEmpty($addResponse.error)) {
                        Write-Error ('Failed to add user [{0}] to group [{1}] details because of [{2} - {3}].' -f $displayName, $group, $addResponse.error.code, $addResponse.error.message)
                    }
                    else {
                        Write-Verbose  "             User successfully added to group ($group)." -Verbose
                        Write-Verbose "" -Verbose
                    }
                }
            }
            else {
                Write-Verbose  "                Membership exists - ($group) for user ($displayName)!" -Verbose
                Write-Verbose "" -Verbose
            }
        }
    }
    else {
        Write-Verbose "    User already exists - ($displayName)!" -Verbose
        Write-Verbose "        Skipping user creation." -Verbose
        Write-Verbose "" -Verbose
    }
}

# Summary (stats)
Write-Verbose  "-------------------------------------------------" -Verbose
Write-Verbose  "Statistics:" -Verbose
Write-Verbose  "-------------------------------------------------" -Verbose
Write-Verbose  "Number of users created       : $noOfUsersCreated" -Verbose
Write-Verbose  "" -Verbose