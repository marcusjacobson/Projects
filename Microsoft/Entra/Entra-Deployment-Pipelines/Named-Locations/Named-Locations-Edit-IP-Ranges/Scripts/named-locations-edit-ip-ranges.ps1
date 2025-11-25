<#
    .SYNOPSIS
        This script updates the IP ranges for a named location in Entra Conditional Access.

    .DESCRIPTION
        The script checks if a named location list with the specified display name already exists in Entra Conditional Access. 
        If it does not exist, the script validates the provided IP ranges to ensure they are in correct CIDR notation. 
        It then updates the provided named location list with the validated IP ranges. 

    .PARAMETER IPRanges
        [string] JSON representation of the provided IP ranges in CIDR notation. This parameter is mandatory.

    .PARAMETER DisplayName
        [string] Display name for the new named locations list. This parameter is mandatory.

    .PARAMETER IsTrusted
        [string] Boolean indicating if the named location is trusted. This parameter is mandatory.

    .INPUTS
        The script is designed to be run from Azure Pipelines, with input variables provided from pipeline-variables.yml.

    .OUTPUTS
        The script outputs verbose messages indicating the progress and results of the named location list creation process. 
        It also outputs error messages if any issues are encountered.

    .EXAMPLE
        .\named-locations-edit-ip-ranges.ps1 -IPRanges '{"ipRanges":[{"cidrAddress":"192.168.1.0/24"}]}' -DisplayName "Office Locations" -IsTrusted "true"
        This example updates the named location "Office Locations" with the provided IP range and marks it as trusted.

    .NOTES
        File Name      : named-locations-edit-ip-ranges.ps1
        Author         : Marcus Jacobson
        Version History: 1.0.0, Initial version
        Release        : 2025-02-24 - this is the initial release date
        Updated        : 
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "JSON representation of the provided IP ranges in CIDR notation.")]
    [string]$IPRanges,

    [Parameter(Mandatory = $true,
        HelpMessage = "Display name for the new named locations list.")]
    [string]$DisplayName,

    [Parameter(Mandatory = $true,
        HelpMessage = "Display name for the new named locations list.")]
    [string]$IsTrusted
)

# Verify the $IPRanges variable is not empty, and has been passed correctly. Exit the script if it fails.
if (-not $IPRanges) {
    Write-Error "IPRanges is empty or not passed correctly."
    exit 1
}

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

# Check if the named location already exists
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking if there is already a named location list with the name $DisplayName" -Verbose
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
    Write-Verbose "    The named location list $($DisplayName) exists. Proceeding with list update..." -Verbose
    Write-Verbose "" -Verbose
    $namedLocationID = $existingNamedLocation.id
}
else {
    Write-Verbose "    The named location list $($DisplayName) does not exist." -Verbose
    Write-Verbose "    Exiting pipeline." -Verbose
    Exit 1
}

# Perform validation checks on the provided IP addresses
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking provided IP addresses to ensure they are formatted correctly" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Initialize an empty array to store IP ranges
$cidrIPs= @()

# Deserialize the JSON string into a PowerShell object
$ipObjects = $IPRanges | ConvertFrom-Json

Write-Verbose "    The following IP ranges were provided:" -Verbose
foreach ($ip in $ipObjects.ipRanges) {
    Write-Verbose "        $($ip.cidrAddress)" -Verbose
}

# Define regex patterns for validating CIDR notation
$ipv4CidrRegex = '^(([0-9]{1,3}\.){3}[0-9]{1,3}\/([0-9]|[1-2][0-9]|3[0-2]))$'
$ipv6FullRegex = '^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}\/([0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8])$'
$ipv6PrivateRegex = '^fd[0-9a-fA-F]{2}(:[0-9a-fA-F]{1,4}){0,6}::?\/([0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8])$'
$ipv6DoubleColonStartRegex = '^::[0-9a-fA-F]{1,4}\/([0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8])$'
$ipv6DoubleColonMiddleRegex = '^[0-9a-fA-F]{1,4}::[0-9a-fA-F]{1,4}\/([0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8])$'

# Loop through each IP range in the list to determine if it is presented correctly in CIDR notation
foreach ($ipRange in $ipObjects.ipRanges) {
    
    # Check if the IP range is in valid IPv4 CIDR notation
    if ($ipRange.cidrAddress -match $ipv4CidrRegex) {
        
        # Add the valid IPv4 range to the array
        Write-Verbose  "    Adding IPv4 range $($ipRange.cidrAddress) to the IP ranges list." -Verbose
        Write-Verbose "" -Verbose
        $cidrIPs += $ipRange
    }
    # Check if the IP range is in valid IPv6 CIDR notation
    elseif ($ipRange.cidrAddress -match $ipv6FullRegex -or
            $ipRange.cidrAddress -match $ipv6PrivateRegex -or
            $ipRange.cidrAddress -match $ipv6DoubleColonStartRegex -or
            $ipRange.cidrAddress -match $ipv6DoubleColonMiddleRegex) {
        
        # Add the valid IPv6 range to the array
        Write-Verbose  "    Adding IPv6 range $($ipRange.cidrAddress) to the IP ranges list." -Verbose
        Write-Verbose "" -Verbose
        $cidrIPs += $ipRange
    }
    else {
        # Write notification that the IP range is not in valid CIDR notation and will be skipped.
        Write-Verbose "    The IP range $($ipRange.cidrAddress) is not in valid CIDR notation." -Verbose
        Write-Verbose "        $($ipRange.cidrAddress) will be excluded from the IP ranges list." -Verbose
        Write-Verbose "" -Verbose
    }
}

# Exit the pipeline if the ipRanges array is empty
if ($cidrIPs.Count -eq 0) {
    Write-Verbose "The IP Ranges list is empty. Please ensure you provide the IP ranges in CIDR notation." -Verbose
    Write-Verbose "Exiting pipeline." -Verbose
    Exit 1
}

# Build the named location Rest API object
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Updating named location with valid IP addresses" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

#Define list URI
$listURI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations/$($namedLocationID)"

# Define the body of the request
$body = @{
    "@odata.type" = "#microsoft.graph.ipNamedLocation"
    "displayName" = $DisplayName
    "ipRanges" = $cidrIPs
    "isTrusted" = [bool]::Parse($IsTrusted)
}

# Build named location Rest API object
$namedLocationInputObject = @{
    method = 'PATCH'
    uri    = $listUri
    header = @{"Content-Type" = "application/json"}
    body   = ConvertTo-Json $body -Depth 10 -Compress
}

# Invoke the REST command to create the named location
$response = Invoke-RESTCommand @namedLocationInputObject

# Check successful named location deployment, and output an error if it fails. End the script on an error.
if (-not [String]::IsNullOrEmpty($response.error)) {
    Write-Error ('Failed to update named location list [{0}] because of [{1} - {2}].' -f $DisplayName, $response.error.code, $response.error.message)
}
else {
    # Output confirmation of successful role assignment
    Write-Verbose "    The named location list $($DisplayName) was successfully updated with the following IP Ranges:" -Verbose
        foreach ($ipRange in $cidrIPs) {
        Write-Verbose "        $($ipRange.cidrAddress)" -Verbose
    }
    Write-Verbose "    Please note that any countries removed in the Pipeline-Variables file are not recorded in the pipeline, but will be removed from the named locations list." -Verbose
}
