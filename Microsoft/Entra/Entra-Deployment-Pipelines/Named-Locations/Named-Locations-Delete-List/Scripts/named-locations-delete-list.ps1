<#
    .SYNOPSIS
        Deletes a named location list in Entra Conditional Access.

    .DESCRIPTION
        This script deletes a named location list in Entra Conditional Access based on the provided display name.
        It first checks if the named location list exists, and if it does, it proceeds to delete it.

    .PARAMETER DisplayName
        [string] The display name of the named location list to be deleted. This parameter is mandatory.

    .INPUTS
        The script is designed to be run from Azure Pipelines, with variable input provided by pipeline-variables.yml.

    .OUTPUTS
        None. The script does not produce any output objects.

    .EXAMPLE
        The script outputs verbose messages indicating the progress and results of the named location list deletion process. 
        It also outputs error messages if any issues are encountered.

    .NOTES
        File Name      : named-locations-delete-list.ps1
        Author         : Marcus Jacobson
        Version History: 1.0.0, Initial version
        Release        : 2025-02-24 - this is the initial release date
        Updated        : 
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "Display name for the named locations list.")]
    [string]$DisplayName
)

# Verify the $DisplayName variable is not empty, and has been passed correctly. Exit the script if it fails.
if (-not $DisplayName) {
    Write-Error "DisplayName is empty or not passed correctly."
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

# Create/update users
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking if there isa  named location list with the name $DisplayName" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define list URI for checking existing named locations
$listURI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations"

# Build named location Rest API object for GET request
$checkNamedLocationInputObject = @{
    method = 'GET'
    uri    = $listURI
    header = @{"Content-Type" = "application/json"}
}

# Invoke the REST command to check for existing named locations
$response = Invoke-RESTCommand @checkNamedLocationInputObject

# Check if the named location already exists
$existingNamedLocation = $response.value | Where-Object { $_.displayName -eq $DisplayName }

if ($existingNamedLocation) {
    Write-Verbose "    The named location list $($DisplayName) exists. Continuing with deletion of the list..." -Verbose
    Write-Verbose "" -Verbose
}
else {
    Write-Verbose "    The named location list $($DisplayName) does not exist. There is nothing to delete!" -Verbose
    Write-Verbose "    Exiting pipeline." -Verbose
    Exit 1
}

# Create/update users
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Deleting the named location list..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

#Define list URI
$listURI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations/$($existingNamedLocation.id)"

# Build named location Rest API object
$namedLocationDeleteObject = @{
    method = 'DELETE'
    uri    = $listUri
}

$response = Invoke-RESTCommand @namedLocationDeleteObject

# Check successful named location deployment, and output an error if it fails. End the script on an error.
if (-not [String]::IsNullOrEmpty($response.error)) {
    Write-Error ('Failed to delete named location list [{0}] because of [{1} - {2}].' -f $DisplayName, $response.error.code, $response.error.message)
}
else {
    # Output confirmation of successful role assignment
    Write-Verbose "    The named location list $($DisplayName) was successfully deleted:" -Verbose
}





