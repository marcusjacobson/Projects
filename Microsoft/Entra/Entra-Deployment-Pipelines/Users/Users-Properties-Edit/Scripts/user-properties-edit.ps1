<#
    .SYNOPSIS
        Updates user properties in Entra based on the provided UserPrincipalName and JSON input.

    .DESCRIPTION
        This script updates user properties in Entra by taking a UserPrincipalName and a JSON string representing the user properties to be updated.
        It verifies the existence of the user, validates the properties, and updates them using the Microsoft Graph API. 

    .PARAMETER UserPrincipalName
        [string] The UPN of the user account to update. This parameter is mandatory.

    .PARAMETER UserJson
        [string] A JSON representation of the user properties to update. This parameter is mandatory.

    .INPUTS
        The script is designed to be run from Azure Pipelines, with input variables provided by pipeline-variables.yml.

    .OUTPUTS
        The script outputs verbose messages indicating the progress and results of the user properties update process. 
        It also outputs error messages if any issues are encountered.

    .EXAMPLE
        .\user-properties-edit.ps1 -UserPrincipalName "user@example.com" -UserJson '{"displayName": "New Display Name"}'
        This example updates the display name of the user with the UPN "user@example.com" to "New Display Name".

    .NOTES
        File Name      : user-properties-edit.ps1
        Author         : Marcus Jacobson
        Version History: 1.0.0, Initial version
        Release        : 2025-02-27 - this is the initial release date
        Updated        : 
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
    HelpMessage = "UPN of user account to update.")]
    [string]$UserPrincipalName,    

    [Parameter(Mandatory = $true,
        HelpMessage = "JSON representation of users to add based on UPN.")]
    [string]$UserJson
)

# Verify the $GroupsName variable is not empty, and has been passed correctly. Exit the script if it fails.
if (-not $UserPrincipalName) {
    Write-Error "UserPrincipalName is empty or not passed correctly."
    exit 1
}

# Verify the $UserJson variable is not empty, and has been passed correctly. Exit the script if it fails.
if (-not $UserJson) {
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

# Confirm user exists in Entra.
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Confirming the user $UserPrincipalName Exists..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define user URI 
$userUri = "https://graph.microsoft.com/v1.0/users/$($UserPrincipalName)"

# Create input object to validate if the provided UPN is valid
$userInputObject = @{
    method = 'GET'
    uri    = $userUri
}

# Invoke REST API function to test the inputObject
$existingUser = Invoke-RESTCommand @userInputObject

# Confirm the provided UserPrincipalName exists in Entra and provide an output if it does. If it does not, write an error and exit the script
if ($existingUser -and $existingUser.id) {
    Write-Verbose  "    $($UserPrincipalName) exists with ID $($existingUser.id). Continuing with the user update." -Verbose
    Write-Verbose "" -Verbose
    $userID = $existingUser.id
}
elseif ($existingUser -and ($existingUser.error.code -eq "Request_ResourceNotFound")) {
    # Provide an error code if the user does not exist.
    Write-Warning (    'User [{0}] does not exist in Entra.' -f $UserPrincipalName)
    Write-Warning (    'Exiting pipeline')
    exit 1
}
else {
    # Provide an error code if the user does not exist.
    Write-Error ('Failed to get user [{0}] because of [{1} - {2}].' -f $UserPrincipalName, $existingUser.error.code, $existingUser.error.message)
    exit 1
}

# Edit user properties
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Updating properties for $UserPrincipalName" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Deserialize the JSON string into a PowerShell object
$userProperties = $UserJson | ConvertFrom-Json

# Define array to keep track of updated properties
$updatedProperties = @()

# List of valid properties that can be updated
$validProperties = @(
    "displayName", "givenName", "surname", "jobTitle", "companyName", "department",
    "mobilePhone", "accountEnabled", "usageLocation", "aboutMe", "birthday",
    "businessPhones", "city", "country", "employeeId", "faxNumber", "hireDate",
    "interests", "mailNickname", "officeLocation", "passwordPolicies", "passwordProfile",
    "postalCode", "preferredLanguage", "proxyAddresses", "responsibilities", "schools",
    "skills", "state", "streetAddress", "userPrincipalName", "userType"
)

# Loop through each user object
foreach ($property in $userProperties.PSObject.Properties) {
    $propertyName = $property.Name
    $propertyValue = $property.Value

    # Check if the property is a valid Entra user property
    if ($validProperties -notcontains $propertyName) {
        Write-Verbose "    Property '$propertyName' is not a valid Entra user property. Skipping update." -Verbose
        continue
    }
    else {
        # Check if the property exists in the existingUser object
        if ($existingUser.PSObject.Properties.Match($propertyName)) {
            $existingValue = $existingUser.$propertyName
        } else {
            $existingValue = $null
        }

        # Add the updated property to the array
        $updatedProperties += [PSCustomObject]@{
            PropertyName = $propertyName
            PropertyValue = $propertyValue
        } 

        # Create the REST API call to update the value
        $updateUri = "https://graph.microsoft.com/v1.0/users/$($userID)"
        $updateBody = @{
            $propertyName = $propertyValue
        }

        $updateInputObject = @{
            method = 'PATCH'
            uri    = $updateUri
            header = @{"Content-Type" = "application/json"}
            body   = ConvertTo-Json $updateBody -Depth 10 -Compress
        }

        # Invoke REST API function to update the property
        $updateResponse = Invoke-RESTCommand @updateInputObject

        if (-not [String]::IsNullOrEmpty($updateResponse.error)) {
            Write-Error "           Failed to update property '$propertyName' for user $($UserPrincipalName) because of [$($updateResponse.error.code) - $($updateResponse.error.message)]." -Verbose
            $global:ScriptFailed = $true
        }
    }
}

# Summary (stats)
Write-Verbose "" -Verbose
Write-Verbose  "-------------------------------------------------" -Verbose
Write-Verbose  "Statistics:" -Verbose
Write-Verbose  "-------------------------------------------------" -Verbose
Write-Verbose  "    The user $($UserPrincipalName) has been updated to contain the following properties:" -Verbose
foreach ($property in $updatedProperties) {
    Write-Verbose "        '$($property.PropertyName)': '$($property.PropertyValue)'." -Verbose
}

# Exit with an error code only if there were unexpected failures
if ($global:ScriptFailed) {
    exit 1
} else {
    exit 0
}