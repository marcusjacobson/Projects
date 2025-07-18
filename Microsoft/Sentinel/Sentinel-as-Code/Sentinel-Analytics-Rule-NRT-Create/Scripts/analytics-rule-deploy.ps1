<#
.SYNOPSIS
    Deploys or updates Microsoft Sentinel NRT analytics rules with external KQL query processing and comprehensive validation.

.DESCRIPTION
    This script automates the deployment of Microsoft Sentinel NRT analytics rules using a pipeline-driven 
    approach that combines JSON payload templates with external KQL query files. Designed for Azure DevOps 
    environments with standardized authentication and validation patterns.
    
    Key Features:
    - Pipeline-optimized design for Azure DevOps execution with mandatory parameter validation
    - Advanced KQL file processing that preserves comments and formatting for Sentinel UI display
    - Template validation that enforces consistency between file references and pipeline parameters
    - Intelligent rule management that creates new rules or updates existing ones based on display name matching
    - Comprehensive Azure resource validation including subscription, workspace, and Sentinel deployment verification
    - Built-in KQL syntax validation with performance and best practice recommendations
    
    Prerequisites:
    - PowerShell 5.1 or later
    - Azure CLI authentication via Azure DevOps service connections
    - Microsoft Sentinel Contributor role on the target workspace
    
    The script processes KQL files with complete comment preservation while ensuring ARM template compatibility.
    Template files must reference KQL files using the "@filename.kql" syntax, which is validated against the
    pipeline KQLFilePath parameter to ensure consistency.

.PARAMETER TemplateFilePath
    Path to the analytics rule JSON payload template file. This file contains the rule definition with 
    a KQL file reference (e.g., "@filename.kql") that will be processed and replaced with the actual 
    KQL query content from the external file specified in KQLFilePath.
    
    Required: Yes
    Type: String
    Example: "C:\Templates\NRT-analytics-rule-payload.json"

.PARAMETER SubscriptionID
    Azure subscription ID where the Microsoft Sentinel workspace is deployed. The script validates 
    that this subscription exists and is accessible with the current authentication context.
    
    Required: Yes
    Type: String (GUID format)
    Example: "12345678-1234-1234-1234-123456789012"

.PARAMETER ResourceGroupName
    Name of the Azure resource group containing the Log Analytics workspace and Microsoft Sentinel deployment.
    The script validates that this resource group exists within the specified subscription.
    
    Required: Yes
    Type: String
    Example: "rg-sentinel-prod"

.PARAMETER LogAnalyticsWorkspaceName
    Name of the Log Analytics workspace where Microsoft Sentinel is deployed. The script validates 
    that this workspace exists and has Microsoft Sentinel enabled.
    
    Required: Yes
    Type: String
    Example: "law-sentinel-workspace"

.PARAMETER KQLFilePath
    Path to the KQL query file as defined in pipeline variables. This parameter must match the file 
    reference specified in the template's query field. For example, if the template contains 
    "@NRT-analytics-rule-query.kql", the pipeline must pass the path to that exact filename.
    This enforces consistency between template configuration and pipeline variables.
    
    Required: Yes
    Type: String
    Example: "$(Build.SourcesDirectory)/Templates/NRT-analytics-rule-query.kql"

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    System.Object
    Returns detailed deployment information including analytics rule ID, status, and deployment summary.

.NOTES
    File Name      : analytics-rule-deploy.ps1
    Author         : Marcus Jacobson
    Prerequisite   : Azure CLI, PowerShell 5.1 or later, Microsoft Sentinel enabled workspace
    Version        : 1.0
    Last Updated   : July 17, 2025
    
    Security Requirements:
    - User must be authenticated with appropriate permissions, or use a service principal with sufficient rights.
    - Service principal requires Microsoft Sentinel Contributor role on the target workspace
    - Must have permissions to validate subscription and workspace details
    
    Dependencies:
    - Azure CLI (az)
    - PowerShell 5.1 or later
    - Microsoft Sentinel enabled Log Analytics Workspace
    - Network connectivity to Azure management endpoints

.LINK
    https://docs.microsoft.com/en-us/rest/api/securityinsights/
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "Path to the analytics rule payload file.")]
    [string]$TemplateFilePath,

    [Parameter(Mandatory = $true,
        HelpMessage = "ID of the subscription to deploy to.")]
    [string]$SubscriptionID,

    [Parameter(Mandatory = $true,
        HelpMessage = "Name of the resource group to deploy to.")]
    [string]$ResourceGroupName,    [Parameter(Mandatory = $true,
        HelpMessage = "Name of the Log Analytics Workspace.")]
    [string]$LogAnalyticsWorkspaceName,

    [Parameter(Mandatory = $true,
        HelpMessage = "Path to the KQL query file as defined in pipeline variables.")]
    [string]$KQLFilePath
)

# Function to process KQL file for ARM template deployment
function Get-ProcessedKQLQuery {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$KQLFilePath
    )
    
    try {
        # Validate KQL file exists
        if (-not (Test-Path -Path $KQLFilePath)) {
            throw "KQL file not found at: $KQLFilePath"
        }
        
        # Read the KQL file content
        $kqlContent = Get-Content -Path $KQLFilePath -Raw
        Write-Verbose "    Original file size: $($kqlContent.Length) characters" -Verbose

        if ([string]::IsNullOrWhiteSpace($kqlContent)) {
            throw "KQL file is empty or contains only whitespace"
        }
        
        Write-Verbose "    Processing KQL content for ARM template deployment" -Verbose
        Write-Verbose "        Retaining all comments and formatting for Sentinel UI display" -Verbose
        Write-Verbose "        Note: Markdown cells from VS Code notebooks will be processed as KQL comments" -Verbose
        
        # Process KQL content in single pass for ARM template compatibility
        $lines = $kqlContent -split "`r?`n"
        Write-Verbose "    Total lines to process: $($lines.Count)" -Verbose
        
        # Initialize variables for processed lines and block comment state
        $processedLines = @()
        $inBlockComment = $false
        
        # Iterate through each line to handle comments and formatting
        foreach ($line in $lines) {
            $currentLine = $line
            
            # Handle block comments /* */ - preserve them but track state
            if ($currentLine -match '/\*' -and $currentLine -notmatch '\*/') {
                $inBlockComment = $true
                # Keep the line as-is, including the block comment start
                $processedLines += $currentLine
                continue
            }
            
            # If we are currently in a block comment, check for end of block
            if ($inBlockComment) {
                if ($currentLine -match '\*/') {
                    $inBlockComment = $false
                    # Keep the line as-is, including the block comment end
                    $processedLines += $currentLine
                    continue
                } else {
                    # Keep block comment content as-is
                    $processedLines += $currentLine
                    continue
                }
            }
            
            # Handle inline comments - ensure proper spacing for ARM template compatibility
            if ($currentLine -match '//') {
                # Fix spacing for inline comments: ensure space after //
                $currentLine = $currentLine -replace '//([^\s])', '// $1'
            }
            
            # Keep all lines (including empty lines and standalone comments)
            # This preserves the original formatting for display in Sentinel UI
            $processedLines += $currentLine
        }
        
        # Join with newlines to create ARM template compatible single-line string
        # The newlines will be preserved when displayed in Sentinel UI
        $formattedQuery = $processedLines -join "`n"
        
        # Final validation and cleanup
        $formattedQuery = $formattedQuery.Trim()
        
        if ([string]::IsNullOrWhiteSpace($formattedQuery)) {
            throw "KQL file contains no valid query content after processing"
        }
        
        Write-Verbose "    Processed query length: $($formattedQuery.Length) characters" -Verbose
        Write-Verbose "    Query formatted for ARM template with preserved display formatting" -Verbose
        
        return $formattedQuery    }
    catch {
        Write-Error "Failed to process KQL file. Error: $($_.Exception.Message)"
        throw
    }
}

# Function to validate KQL syntax and best practices
function Test-KQLSyntax {
    param (
        [Parameter(Mandatory = $true)]
        [string]$KQLContent
    )
    
    $validationResult = [PSCustomObject]@{
        IsValid = $true
        Errors = @()
        Warnings = @()
        Info = @()
    }
    
    try {       
        
                
        # First check quotes in the original content
        $singleQuoteCount = ($KQLContent.ToCharArray() | Where-Object { $_ -eq "'" }).Count
        $doubleQuoteCount = ($KQLContent.ToCharArray() | Where-Object { $_ -eq '"' }).Count
        
        if ($singleQuoteCount % 2 -ne 0) {
            $validationResult.Errors += "Unmatched single quotes detected"
            $validationResult.IsValid = $false
        }
        if ($doubleQuoteCount % 2 -ne 0) {
            $validationResult.Errors += "Unmatched double quotes detected"
            $validationResult.IsValid = $false
        }        
        
        # Check for empty content, or content with only comments
        # -------------------------------------------------------------------------------------------------------------------

        # Check if query contains only comments (without modifying the content)
        $lines = $KQLContent -split "`r?`n"
        $nonCommentContent = ($lines | ForEach-Object { 
            # Remove single-line comments for validation check only
            $_ -replace '//.*$', ''
        }) -join "`n"
        
        # Remove multi-line comments for validation check only
        $nonCommentContent = $nonCommentContent -replace '/\*[\s\S]*?\*/', ''
        $nonCommentContent = $nonCommentContent.Trim()
        
        # Check for empty query after comment removal (validation only)
        if ([string]::IsNullOrWhiteSpace($nonCommentContent)) {
            $validationResult.Errors += "Query contains no executable KQL content (only comments or whitespace)"
            $validationResult.IsValid = $false
        }
        # -------------------------------------------------------------------------------------------------------------------
        
        # Check for unmatched parentheses
        $openParens = ($KQLContent | Select-String -Pattern '\(' -AllMatches).Matches.Count
        $closeParens = ($KQLContent | Select-String -Pattern '\)' -AllMatches).Matches.Count
        if ($openParens -ne $closeParens) {
            $validationResult.Errors += "Unmatched parentheses detected (Open: $openParens, Close: $closeParens)"
            $validationResult.IsValid = $false
        }
        
        # Check for time filter presence for the steps below
        # -------------------------------------------------------------------------------------------------------------------
        # Enhanced time filter validation
        $timeFilterPatterns = @(
            'TimeGenerated\s*>=?\s*ago\(',
            '_TimeReceived\s*>=?\s*ago\(',
            'Timestamp\s*>=?\s*ago\('
        )
        
        $hasTimeFilter = $false
        foreach ($pattern in $timeFilterPatterns) {
            if ($KQLContent -match $pattern) {
                $hasTimeFilter = $true
                break
            }
        }
        # -------------------------------------------------------------------------------------------------------------------

        # Check for large table queries without time filters
        # -------------------------------------------------------------------------------------------------------------------
        # Enhanced large table detection - including common Sentinel tables
        $largeTables = @('SigninLogs', 'AuditLogs', 'SecurityEvent', 'CommonSecurityLog', 'Syslog', 'Event', 'Heartbeat')
        $foundLargeTables = @()
        
        foreach ($table in $largeTables) {
            if ($KQLContent -match "\b$table\b") {
                $foundLargeTables += $table
            }
        }
        
        if (-not $hasTimeFilter -and $foundLargeTables.Count -gt 0) {
            $validationResult.Warnings += "No time filter detected for large table query ($($foundLargeTables -join ', ')) - this may cause performance issues"
        }
        # -------------------------------------------------------------------------------------------------------------------
        
        # Check for join syntax without proper time filtering
        if ($KQLContent -match '\|\s*join\s*\(' -and $foundLargeTables.Count -gt 1) {
            # Check if both sides of join have time filters
            $joinPattern = '\|\s*join\s*\(([\s\S]*?)\)\s*on'
            if ($KQLContent -match $joinPattern) {
                $joinContent = $matches[1]
                $hasJoinTimeFilter = $false
                foreach ($pattern in $timeFilterPatterns) {
                    if ($joinContent -match $pattern) {
                        $hasJoinTimeFilter = $true
                        break
                    }
                }
                if (-not $hasJoinTimeFilter) {
                    $validationResult.Warnings += "Join operation detected without time filter on joined table - consider adding time filters to both sides of the join for better performance"
                }
            }        }
        
        # Generic check for potential field reference issues in joins
        if ($KQLContent -match '\|\s*join\s*\(' -and $KQLContent -match '\|\s*project\s+') {
            # Extract project clause content
            $projectMatch = $KQLContent -match '\|\s*project\s+([^|]+)'
            if ($projectMatch) {
                $projectContent = $matches[1].Trim()
                
                # Check for fields that don't use explicit table qualifiers ($left./$right.)
                # This is a potential issue in joins where field names might be ambiguous
                $unqualifiedFields = @()
                $fields = $projectContent -split ',' | ForEach-Object { $_.Trim() }
                
                foreach ($field in $fields) {
                    # Skip if field uses proper join syntax ($left.field, $right.field)
                    # Skip common fields that exist in most tables (TimeGenerated, etc.)
                    if ($field -notmatch '^\s*\$(left|right)\.' -and 
                        $field -notmatch '^(TimeGenerated|Computer|Account)$' -and
                        $field -match '^[A-Za-z][A-Za-z0-9_]*$') {
                        $unqualifiedFields += $field
                    }
                }
                
                if ($unqualifiedFields.Count -gt 0) {
                    $validationResult.Warnings += "Join query projects unqualified fields ($($unqualifiedFields -join ', ')). Consider using `$left.fieldname or `$right.fieldname syntax to avoid ambiguity"
                }
            }
        }
        
        # Check for entity fields
        $entityFields = @('UserPrincipalName', 'IPAddress', 'AccountName', 'HostName')
        $foundEntityFields = @()
        foreach ($field in $entityFields) {
            if ($cleanContent -match "\b$field\b") {
                $foundEntityFields += $field
            }
        }
        
        if ($foundEntityFields.Count -gt 0) {
            $validationResult.Info += "Potential entity mapping fields detected: $($foundEntityFields -join ', ')"
        }
        
    }
    catch {
        $validationResult.Errors += "Validation failed: $($_.Exception.Message)"
        $validationResult.IsValid = $false
    }
    
    return $validationResult
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
        # Ensure URI is properly formatted
        $uri = [Uri]::EscapeUriString($uri)
        
        # Start building command
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

# Validate subscription ID
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose "Validating subscription ID: $SubscriptionID" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI to query the subscription list
$uri = "https://management.azure.com/subscriptions/$($SubscriptionID)?api-version=2020-01-01"

# Define the object for the request
$subscriptionQueryObject = @{
    'method' = 'GET'
    'uri' = $uri
}

# Call the Invoke-RESTCommand function check the provided subscription ID
try {
    $response = Invoke-RESTCommand @subscriptionQueryObject    # Check if the response contains the subscription 
    if ($response -and $response.subscriptionId -eq $SubscriptionID) {
        $subscriptionName = $response.displayName
        Write-Verbose "    Subscription '$subscriptionName' validated successfully" -Verbose
    }
    else {
        Write-Error "Subscription ID $($SubscriptionID) was not found."
    }
}
catch {
    Write-Error "Failed to retrieve subscription. Error: $($_.Exception.Message)"
}

# Validate Log Analytics Workspace
Write-Verbose "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose "Validating Log Analytics Workspace: $LogAnalyticsWorkspaceName" -Verbose
Write-Verbose "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI to query all Log Analytics Workspaces in the resource group
$uri = "https://management.azure.com/subscriptions/$($SubscriptionID)/resourcegroups/$($ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces?api-version=2025-02-01"

$rgQueryObject = @{
    'method' = 'GET'
    'uri' = $uri
}

# Call the Invoke-RESTCommand function to checkLog Analytics Workspaces in the resource group
try {
    $response = Invoke-RESTCommand @rgQueryObject

    # Create an array of all Log Analytics Workspaces in the resource group
    $lawsInResourceGroup = $response.value | ForEach-Object { $_.name }    
    
    if ($lawsInResourceGroup -contains $LogAnalyticsWorkspaceName) {
        Write-Verbose "    Log Analytics Workspace validated successfully" -Verbose
    }
    else {
        Write-Error "Log Analytics Workspace [$($LogAnalyticsWorkspaceName)] does not exist in resource group [$($ResourceGroupName)]."
    }
}
catch {
    Write-Error "Failed to retrieve Log Analytics Workspaces in the resource group. Error: $($_.Exception.Message)"
}

# Validate Sentinel
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose "Validating Sentinel deployment" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI to check the Sentinel instance in the resource group
$sentinelInstanceUri = "https://management.azure.com/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.OperationsManagement/solutions?api-version=2015-11-01-preview"

# Check the Sentinel instance in the resource group
$sentinelInstanceObject = @{
    'method' = 'GET'
    'uri' = $sentinelInstanceUri
}

# Determine if the Sentinel instance exists
try {    
    $sentinelInstanceResponse = Invoke-RESTCommand @sentinelInstanceObject
    
    # Check if an object of type "Solution" (for the Sentinel instance) with the expected name exists within the resource group
    $expectedSolutionName = "SecurityInsights($($LogAnalyticsWorkspaceName))"    # Check if the expected solution name matches the actual solution name
    if ($sentinelInstanceResponse.value.name -eq $expectedSolutionName) {
        Write-Verbose "    Sentinel instance validated successfully" -Verbose
        $sentinelSolutionExists = $true
    }
    else {
        Write-Verbose "    No Sentinel instance found with expected name: $expectedSolutionName" -Verbose
        $sentinelSolutionExists = $false
    }

}
catch {
    Write-Error "Failed to validate Sentinel deployment. Error: $($_.Exception.Message)"
}  


# Perform actions based on the existence of the Sentinel onboarding state and instance
if ($sentinelSolutionExists) {
    Write-Verbose "        Sentinel Workspace exists for Log Analytics Workspace [$($LogAnalyticsWorkspaceName)]..." -Verbose
    Write-Verbose "        Continuing with Analytic Rule creation." -Verbose
}

else {
    Write-Error "Sentinel Instance is does not exist for Log Analytics Workspace [$($LogAnalyticsWorkspaceName)]. Please ensure Sentinel is onboarded before creating analytic rules." -Verbose
}

# Validate if Analytics Rule already exists
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Parsing Analytics Rules Details from payload file..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Read the template file to get the rule details
try {

    # Read and validate the template content
    if (-not (Test-Path -Path $TemplateFilePath)) {
        throw "Template file not found at: $TemplateFilePath"
    }

    # Extract the content of the template file
    $templateContent = Get-Content -Path $TemplateFilePath -Raw
    
    # Validate the JSON is properly formatted
    if (-not (Test-Json -Json $templateContent)) {
        throw "Invalid JSON format in template file"
    }
    
    # Parse JSON to PowerShell object and validate required properties
    $templateObject = $templateContent | ConvertFrom-Json

    if (-not $templateObject.properties -or -not $templateObject.kind) {
        throw "Template file missing required properties (properties and kind)"
    }

    # Extract the static display name from template
    $ruleDisplayName = $templateObject.properties.displayName
    $ruleKind = $templateObject.kind
    Write-Verbose "    Using rule display name: $ruleDisplayName" -Verbose
    Write-Verbose "    Using rule kind: $ruleKind" -Verbose    # Process KQL query based on pipeline-driven configuration
    
    # Check if the template has a KQL file reference
    if ($templateObject.properties.query -like "@*") {
        
        # Template has file reference - validate it matches pipeline parameter
        $kqlFileReference = $templateObject.properties.query.Substring(1)
        Write-Verbose "    Validating KQL file references:" -Verbose
        Write-Verbose "        Detected KQL file reference in template: $kqlFileReference" -Verbose
        
        # Extract filename from pipeline path for comparison
        $pipelineFileName = [System.IO.Path]::GetFileName($KQLFilePath)
        Write-Verbose "        Pipeline KQL file name: $pipelineFileName" -Verbose        # Validate that template reference matches pipeline configuration
        
        # Exit the pipeline with an error if there is a mismatch detected
        if ($kqlFileReference -ne $pipelineFileName) {
            Write-Error "File reference mismatch detected between template and pipeline parameters. Please correct and re-run the pipeline."
        }
        
        Write-Verbose "        ✅ Template file reference matches pipeline parameter" -Verbose
        Write-Verbose "" -Verbose
        
        # Invoke the REST Command to process the KQL query file
        $processedQuery = Get-ProcessedKQLQuery -KQLFilePath $KQLFilePath

        # Validate KQL syntax and best practices
        Write-Verbose "" -Verbose
        Write-Verbose "    Validating KQL syntax and best practices..." -Verbose
        # $originalKQLContent = Get-Content -Path $KQLFilePath -Raw
        $validationResult = Test-KQLSyntax -KQLContent $processedQuery
        
        # Handle validation results
        if ($validationResult.Info.Count -gt 0) {
            foreach ($info in $validationResult.Info) {
                Write-Verbose "        ℹ️ $info" -Verbose
            }
        }
        
        $warningCount = 0
        if ($validationResult.Warnings.Count -gt 0) {
            foreach ($warning in $validationResult.Warnings) {
                Write-Warning "        ⚠️ KQL Validation Warning: $warning"
                $warningCount++
            }

        }        
        
        if (-not $validationResult.IsValid) {
            Write-Warning "        ❌ KQL Validation Failed. The following errors must be fixed before deployment:"
            foreach ($validationError in $validationResult.Errors) {
                Write-Warning "        • $validationError"
            }
            throw "KQL validation failed. Please fix the errors in the KQL file and re-run the pipeline."
        }
        
        Write-Verbose "        ✅ KQL validation completed successfully" -Verbose
        
        # Update the template object with the processed query
        $templateObject.properties.query = $processedQuery

        Write-Verbose "    ✅ KQL query loaded and processed successfully." -Verbose
    }    
    else {
        # Template doesn't have file reference - this is unexpected in pipeline context
        Write-Error "Expected template to contain KQL file reference (e.g., '@filename.kql') but found. Please correct and re-run the pipeline."
    }

}
catch {
    Write-Error "Failed to read or parse template file. Error: $($_.Exception.Message)"
    throw
}

# Validate if Analytics Rule already exists
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking if Analytics Rule already exists for the Sentinel workspace..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI to check the Analytics Rule in the Sentinel workspace
$analyticsRuleUri = "https://management.azure.com/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($LogAnalyticsWorkspaceName)/providers/Microsoft.SecurityInsights/alertRules?api-version=2023-02-01-preview"

$ruleQueryObject = @{
    'method' = 'GET'
    'uri' = $analyticsRuleUri
}

try {
    
    # Invoke the REST command to get existing analytics rules
    $analyticsRuleResponse = Invoke-RESTCommand @ruleQueryObject
    
    # Initialize variables
    $ruleExists = $false
    $existingRuleId = $null
    $allRules = @()

    Write-Verbose "    Checking for existing Analytics Rule: [$($ruleDisplayName)]..." -Verbose
    
    # Collect all rules from API response with pagination support
    if ($analyticsRuleResponse -and $analyticsRuleResponse.value) {
        $allRules += $analyticsRuleResponse.value
        
        # Handle pagination if present
        $nextLink = $analyticsRuleResponse.'@odata.nextLink'
        while ($nextLink) {
            $pageResponse = Invoke-RESTCommand -method 'GET' -uri $nextLink
            if ($pageResponse.value) {
                $allRules += $pageResponse.value
            }
            $nextLink = $pageResponse.'@odata.nextLink'
        }
    }

    # Search for existing rule by display name
    foreach ($rule in $allRules) {
        if ($rule.properties -and $rule.properties.displayName) {
            $existingDisplayName = $rule.properties.displayName
            
            # Check for exact match or case-insensitive match
            if ($existingDisplayName -eq $ruleDisplayName -or 
                $existingDisplayName.Trim() -ieq $ruleDisplayName.Trim()) {
                $existingRuleId = $rule.name
                $ruleExists = $true
                break
            }
        }
    }
    
    # Log the result
    if ($ruleExists) {
        Write-Verbose "        ✅ Existing rule found - will update rule ID: $existingRuleId" -Verbose
    } else {
        Write-Verbose "        ℹ️ Existing rule found - will create new rule" -Verbose
    }
}
catch {
    Write-Error "Failed to validate existing Analytics Rule. Error: $($_.Exception.Message)"
    throw
}

# Create or Update Analytics Rule via ARM Template
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Creating or updating analytics rule [$($ruleDisplayName)]..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

try {    
    
    # Determine rule ID based on whether we're creating or updating
    if ($ruleExists -and $existingRuleId) {
        $RuleID = $existingRuleId
        Write-Verbose "    Using existing rule ID for update: $RuleID" -Verbose
    } else {
        $RuleID = [System.Guid]::NewGuid().ToString()
        Write-Verbose "    Generated new rule ID for creation: $RuleID" -Verbose
    }

    # Create analytics rule using direct SecurityInsights API
    $operationType = if ($ruleExists) { "Updating" } else { "Creating" }
    Write-Verbose "    $operationType analytics rule..." -Verbose

    # Construct the SecurityInsights API URI
    $alertRuleUri = "https://management.azure.com/subscriptions/$($SubscriptionID)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($LogAnalyticsWorkspaceName)/providers/Microsoft.SecurityInsights/alertRules/$($RuleID)?api-version=2023-02-01-preview"
    
    Write-Verbose "        Rule Kind: $($templateObject.kind)" -Verbose
    Write-Verbose "        Rule Display Name: $($templateObject.properties.displayName)" -Verbose

    # Create the request payload using the template object directly
    $rulePayload = @{
        'kind' = $templateObject.kind
        'properties' = $templateObject.properties
    }
    
    # Convert payload to JSON with proper depth
    $rulePayloadJson = $rulePayload | ConvertTo-Json -Depth 20 -Compress
    
    Write-Verbose "        Payload size: $($rulePayloadJson.Length) characters" -Verbose
    Write-Verbose "" -Verbose
    
    # Create the analytics rule using direct REST API
    $createRuleObject = @{
        'method' = 'PUT'
        'uri' = $alertRuleUri
        'body' = $rulePayloadJson
        'header' = @{
            'Content-Type' = 'application/json'
        }
    }
    
    # Execute REST API call to create/update the analytic rule
    Write-Verbose "    Executing API call to create/update the analytic rule..." -Verbose
    $createRuleResponse = Invoke-RESTCommand @createRuleObject

    # Checking for errors in the API response
    # ----------------------------------------------------------------------------------------------------------------------------------------
    # Check for authentication or authorization errors
    if ($createRuleResponse -is [string] -and $createRuleResponse -match "ERROR:.*not found|ERROR:.*authentication|ERROR:.*authorization") {
        throw "Authentication/Authorization error: $createRuleResponse"
    }
      # Check for API errors in PSCustomObject response  
    if ($createRuleResponse.error) {
        $errorCode = $createRuleResponse.error.code
        $errorMessage = $createRuleResponse.error.message
        throw "API Error [$errorCode]: $errorMessage"
    }
    
    # Check for BadRequest validation errors
    if ($createRuleResponse -and $createRuleResponse.GetType().Name -eq "PSCustomObject" -and 
        ($createRuleResponse.PSObject.Properties.Name -contains "code" -and $createRuleResponse.code -eq "BadRequest")) {
        throw "API Validation Error: $($createRuleResponse.message)"
    }
    # ----------------------------------------------------------------------------------------------------------------------------------------
      # Check if the response is a PSCustomObject with expected properties    
    if ($createRuleResponse) {
        # Check if response has the expected structure
        if ($createRuleResponse.name -and $createRuleResponse.properties) {
            
            # Determine if the rule was created or updated based on existence
            $operationResult = if ($ruleExists) { "updated" } else { "created" }
            Write-Verbose "        ✅ Analytics rule $operationResult successfully!" -Verbose
            Write-Verbose "            Rule ID: $($createRuleResponse.name)" -Verbose
            Write-Verbose "            Rule Name: $($createRuleResponse.properties.displayName)" -Verbose
            Write-Verbose "            Rule Kind: $($createRuleResponse.kind)" -Verbose
            Write-Verbose "            Rule Enabled: $($createRuleResponse.properties.enabled)" -Verbose
            
            if ($createRuleResponse.properties.severity) {
                Write-Verbose "            Rule Severity: $($createRuleResponse.properties.severity)" -Verbose
            }
        } else {
            
            # If the response is a string, it may indicate a simple success message or error
            $operationResult = if ($ruleExists) { "update" } else { "creation" }
            Write-Verbose "         ✅ Analytics rule $operationResult completed (response format: $($createRuleResponse.GetType().Name))" -Verbose
            if ($createRuleResponse -is [string]) {
                Write-Verbose "            Response: $createRuleResponse" -Verbose
            }
        }
        
        Write-Verbose "" -Verbose

        # Verify the rule was created/updated by retrieving it
        $verificationAction = if ($ruleExists) { "update" } else { "creation" }
        Write-Verbose "    Verifying rule $verificationAction..." -Verbose
        
        # Construct the rule verification object for the REST API call
        $verifyRuleObject = @{
            'method' = 'GET'
            'uri' = $alertRuleUri
        }
        
        try {            
            
            # Invoke the REST command to verify the rule creation
            $verifyResponse = Invoke-RESTCommand @verifyRuleObject
            
            # Check for authentication errors in verification
            if ($verifyResponse -is [string] -and $verifyResponse -match "ERROR:.*not found|ERROR:.*authentication|ERROR:.*authorization") {
                Write-Verbose "        Verification skipped due to authentication error: $verifyResponse" -Verbose
                return
            }
            
            # Check if the verification response is a PSCustomObject with expected properties
            if ($verifyResponse -and $verifyResponse.name -eq $RuleID) {
                Write-Verbose "        ✅ Rule verification successful!" -Verbose
                Write-Verbose "             Verified rule ID: $($verifyResponse.name)" -Verbose
                Write-Verbose "             Verified rule name: $($verifyResponse.properties.displayName)" -Verbose
            } else {
                Write-Verbose "        Verification response: $($verifyResponse | ConvertTo-Json -Depth 3 -Compress)" -Verbose
                Write-Warning "        Rule verification inconclusive - response doesn't match expected format"
            }
        }
        catch {
            Write-Verbose "        Verification failed with error: $($_.Exception.Message)" -Verbose
            Write-Warning "        Unable to verify rule creation due to API error"
        }
    } else {
        throw "No response received from SecurityInsights API"
    }
    
    Write-Verbose "" -Verbose
    
    # Output any KQL validation warnings if they exist
    if ($warningCount -gt 0) {
        Write-Warning "    ⚠️ $warningCount KQL validation warnings were encountered during rule creation. Please review the warnings above."
        Write-Verbose "    Analytics rule operation completed with KQL validation warnings." -Verbose
    }
    else {
        Write-Verbose "    ✅ Analytics rule operation completed successfully with no KQL validation warnings." -Verbose
    }
}
catch {
    $operationAction = if ($ruleExists) { "update" } else { "create" }
    Write-Error "Failed to $operationAction analytics rule via SecurityInsights API. Error: $($_.Exception.Message)"
    throw
}

# Final cleanup and summary
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Analytics Rule Deployment Summary" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "    Subscription: $SubscriptionID" -Verbose
Write-Verbose  "    Resource Group: $ResourceGroupName" -Verbose
Write-Verbose  "    Workspace: $LogAnalyticsWorkspaceName" -Verbose
Write-Verbose  "    Rule ID: $RuleID" -Verbose
Write-Verbose  "    Rule Name: $ruleDisplayName" -Verbose
Write-Verbose  "    Rule Kind: $ruleKind" -Verbose
Write-Verbose  "    Operation: $(if ($ruleExists) { 'Update' } else { 'Create' })" -Verbose
Write-Verbose  "    Status: Completed" -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

