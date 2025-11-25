<#
    .SYNOPSIS
        Creates a new named locations list in Entra Conditional Access based on provided countries and regions.

    .DESCRIPTION
        This script creates a new named locations list in Azure AD Conditional Access using a JSON representation 
        of countries and regions. 
        It checks if a named location list with the provided display name already exists, validates the country 
        abbreviations, and then creates the named location list if it does not already exist. 

    .PARAMETER CountriesJson
        [string] JSON representation of the countries and regions for the named locations list. This parameter is mandatory.

    .PARAMETER DisplayName
        [string] Display name for the new named locations list. This parameter is mandatory.

    .PARAMETER IncludeUnknownCountriesAndRegions
        [string] Boolean flag indicating whether to include unknown countries and regions. This parameter is mandatory.

    .INPUTS
        The script is designed to be run from Azure Pipelines, with input variables provided from pipeline-variables.yml.

    .OUTPUTS
        The script outputs verbose messages indicating the progress and results of the named location list creation process. 
        It also outputs error messages if any issues are encountered.

    .EXAMPLE
        .\named-locations-new-list-countries.ps1 -CountriesJson '{"countriesAndRegions":[{"countryOrRegion":"US"},{"countryOrRegion":"CA"}]}' -DisplayName "North America" -IncludeUnknownCountriesAndRegions $false
        This example creates a named locations list called "North America" with the countries US and CA, and does not include unknown countries and regions.

    .NOTES
        File Name      : named-locations-new-list-countries.ps1
        Author         : Marcus Jacobson
        Version History: 1.0.0, Initial version
        Release        : 2025-02-26 - this is the initial release date
        Updated        : 
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "JSON representation of the countries and regions for the named locations list.")]
    [string]$CountriesJson,

    [Parameter(Mandatory = $true,
        HelpMessage = "Display name for the new named locations list.")]
    [string]$DisplayName,

    [Parameter(Mandatory = $true,
        HelpMessage = "Boolean flag for whether to include unknown countries and regions.")]
    [string]$IncludeUnknownCountriesAndRegions
)

# Verify the $CountriesJson variable is not empty, and has been passed correctly. Exit the script if it fails.
if (-not $CountriesJson) {
    Write-Error "CountriesJson is empty or not passed correctly."
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

# Create/update users
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
    Write-Verbose "    The named location list $($DisplayName) already exists. Please create a list with a name that doesn't already exist." -Verbose
    Write-Verbose "    Exiting pipeline." -Verbose
    Exit 1
}
else {
    Write-Verbose "    The named location list $($DisplayName) does not exist already. Proceeding with list creation..." -Verbose
    Write-Verbose "" -Verbose
}

# Create/update users
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking provided countries to ensure they are formatted correctly" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose


# Initialize an empty array to store country abbreviations
$countryAbbreviations = @()

# Deserialize the JSON string into a PowerShell object
$countriesObjects = $CountriesJson | ConvertFrom-Json

# Loop through each country in the list and only add the 2-letter acronyms to the array. Skip any entries that are not 2-letter acronyms.
foreach ($country in $countriesObjects.countriesAndRegions) {
    
    # Check if the country abbreviation is legitimate
    if ($country.countryOrRegion.Length -ne 2) {
        Write-Verbose "    The country abbreviation $($country.countryOrRegion) is not a valid 2-letter acronym." -Verbose
        Write-Verbose "        $($country.countryOrRegion) will be excluded from the Named Locations list." -Verbose
        Write-Verbose "" -Verbose
    }
    else {
        # Add the country abbreviation to the array
        Write-Verbose  "   Adding $($country.countryOrRegion) to the abbreviations list." -Verbose
        Write-Verbose "" -Verbose
        $countryAbbreviations += $country.countryOrRegion
    }   
}

# Exit the pipeline if the countryAbbreviations array is empty
if ($countryAbbreviations.Count -eq 0) {
    Write-Verbose "The country abbreviation list is empty. Please provide a list with valid 2-letter acronyms." -Verbose
    Write-Verbose "Exiting pipeline." -Verbose
    Exit 1
}

# Create/update users
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Creating new named location" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

#Define list URI
$listURI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations"

# Define the body of the request
$body = @{
    "@odata.type" = "#microsoft.graph.countryNamedLocation"
    "displayName" = $DisplayName
    "countriesAndRegions" = $countryAbbreviations
    "includeUnknownCountriesAndRegions" = $IncludeUnknownCountriesAndRegions
}

# Build named location Rest API object
$namedLocationInputObject = @{
    method = 'POST'
    uri    = $listUri
    header = @{"Content-Type" = "application/json"}
    body   = ConvertTo-Json $body -Depth 10 -Compress
}

$response = Invoke-RESTCommand @namedLocationInputObject

# Check successful named location deployment, and output an error if it fails. End the script on an error.
if (-not [String]::IsNullOrEmpty($response.error)) {
    Write-Error ('Failed to create named location list [{0}] because of [{1} - {2}].' -f $DisplayName, $response.error.code, $response.error.message)
}
else {
    # Output confirmation of successful role assignment
    Write-Verbose "    The named location list $($DisplayName) was successfully deployed with the following countries:" -Verbose
        foreach ($country in $countryAbbreviations) {
        Write-Verbose "        $($country)" -Verbose
    }
    Write-Verbose "    Please note that this named location list is not assigned to a Conditional Access policy yet." -Verbose
}





