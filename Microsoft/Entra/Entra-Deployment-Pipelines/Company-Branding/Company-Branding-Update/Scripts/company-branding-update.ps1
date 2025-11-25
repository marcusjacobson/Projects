<#
    .SYNOPSIS
        Updates the company branding settings for an organization in Entra using REST API.
            
    .DESCRIPTION
        This script updates various company branding settings for an organization in Entra. 
        It retrieves the organization details and current branding settings using REST API, and then updates the branding settings based on the provided parameters. 
        The script is designed to be run from Azure Pipelines, with input variables provided through pipeline-variables.yml.

    .PARAMETER BackgroundColor
        [string] Background color for the branding. This parameter is mandatory.

    .PARAMETER HeaderBackgroundColor
        [string] Background color for the header. This parameter is mandatory.

    .PARAMETER CustomPrivacyAndCookiesText
        [string] Text for custom privacy and cookies. This parameter is mandatory.

    .PARAMETER CustomTermsOfUseText
        [string] Text for custom terms of use. This parameter is mandatory.

    .PARAMETER UsernameHintText
        [string] Hint text for the username field. This parameter is mandatory.

    .PARAMETER SignInPageText
        [string] Text for the sign-in page. This parameter is mandatory.

    .PARAMETER CustomCannotAccessYourAccountText
        [string] Text for custom "cannot access your account". This parameter is mandatory.

    .PARAMETER CustomForgotMyPasswordText
        [string] Text for custom "forgot my password". This parameter is mandatory.

    .PARAMETER CustomResetItNowText
        [string] Text for custom "reset it now". This parameter is mandatory.

    .INPUTS
        Inputs are provided from Azure Pipelines as defined in pipeline-variables.yml.

    .OUTPUTS
        None. 

    .NOTES
        File Name      : company-branding-update.ps1
        Author         : Marcus Jacobson
        Version History: 1.0.0, Initial version
        Release        : 2025-02-26 - this is the initial release date
        Updated        : 
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "Background color for the branding.")]
    [string]$BackgroundColor,

    [Parameter(Mandatory = $true,
        HelpMessage = "Background color for the header.")]
    [string]$HeaderBackgroundColor,

    [Parameter(Mandatory = $true,
        HelpMessage = "Text for custom privacy and cookies.")]
    [string]$CustomPrivacyAndCookiesText,

    [Parameter(Mandatory = $true,
        HelpMessage = "Text for custom terms of use.")]
    [string]$CustomTermsOfUseText,

    [Parameter(Mandatory = $true,
        HelpMessage = "Hint text for the username field.")]
    [string]$UsernameHintText,

    [Parameter(Mandatory = $true,
        HelpMessage = "Text for the sign-in page.")]
    [string]$SignInPageText,

    [Parameter(Mandatory = $true,
        HelpMessage = "Text for custom cannot access your account.")]
    [string]$CustomCannotAccessYourAccountText,

    [Parameter(Mandatory = $true,
        HelpMessage = "Text for custom forgot my password.")]
    [string]$CustomForgotMyPasswordText,

    [Parameter(Mandatory = $true,
        HelpMessage = "Text for custom reset it now.")]
    [string]$CustomResetItNowText
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

# Define the URI to get the organization details
$orgDetailsUri = "https://graph.microsoft.com/v1.0/organization"

# Build the REST API object to get the organization details
$orgDetailsInputObject = @{
    method = 'GET'
    uri    = $orgDetailsUri
    header = @{"Content-Type" = "application/json"}
}

# Call the Invoke-RESTCommand function to get the organization details
$orgDetailsResponse = Invoke-RESTCommand @orgDetailsInputObject

# Store the organization ID in a variable
$organizationId = $orgDetailsResponse.value[0].id

Write-Verbose "organizationId: $($organizationId)" -Verbose

# Update Company Branding for the organization
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking if Company Branding has been enabled for this organziation..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI to get the branding details
$brandingDetailsUri = "https://graph.microsoft.com/v1.0/organization/$($organizationId)/branding"

# Build the REST API object to get the branding details
$brandingDetailsInputObject = @{
    method = 'GET'
    uri    = $brandingDetailsUri
    header = @{"Content-Type" = "application/json"}
}

# Call the Invoke-RESTCommand function to get the branding details
$brandingDetailsResponse = Invoke-RESTCommand @brandingDetailsInputObject

# Check if branding is set up
if ($brandingDetailsResponse -eq $null -or $brandingDetailsResponse.error) {
    Write-Verbose "Branding is not set up. Please enable company branding in Azure Portal before running this pipeline..." -Verbose
    Exit 1
}
else {
    Write-Verbose "    Branding is set up. Proceeding with update..." -Verbose
    Write-Verbose "" -Verbose
}

# Update Company Branding for the organization
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Updating company branding..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

#Define list URI
$brandingURI = "https://graph.microsoft.com/v1.0/organization/$($organizationId)/branding"

# Define the body of the request
$body = @{
    "backgroundColor" = $BackgroundColor
    "headerBackgroundColor" = $HeaderBackgroundColor
    "customPrivacyAndCookiesText" = $CustomPrivacyAndCookiesText
    "customTermsOfUseText" = $CustomTermsOfUseText
    "usernameHintText" = $UsernameHintText
    "signInPageText" = $SignInPageText
    "customCannotAccessYourAccountText" = $CustomCannotAccessYourAccountText
    "customForgotMyPasswordText" = $CustomForgotMyPasswordText
    "customResetItNowText" = $CustomResetItNowText
}

# Build named location Rest API object
$brandingInputObject = @{
    method = 'PATCH'
    uri    = $brandingUri
    header = @{
        "Content-Type" = "application/json"
        "Accept-Language" = "0"
    }
    body   = ConvertTo-Json $body -Depth 10 -Compress
}

$response = Invoke-RESTCommand @brandingInputObject

# Check successful named location deployment, and output an error if it fails. End the script on an error.
if (-not [String]::IsNullOrEmpty($response.error)) {
    Write-Error ('Failed to update Company Branding [{0}] because of [{1} - {2}].' -f $DisplayName, $response.error.code, $response.error.message)
}
else {
    # Output confirmation of successful role assignment
    Write-Verbose "    The Company Branding for tenant $($organizationId) has been updated." -Verbose
    Write-Verbose "    The following values have been updated:" -Verbose
    Write-Verbose "    $($body | ConvertTo-Json )" -Verbose
}





