<#
.SYNOPSIS
    Deploys or updates Microsoft Sentinel watchlists with comprehensive CSV validation, schema change detection, security scanning, and intelligent change tracking.

.DESCRIPTION
    This script is part of a comprehensive Azure Infrastructure as Code (IaC) framework designed for enterprise-grade 
    Microsoft Sentinel and Log Analytics deployments. It handles watchlist operations with intelligent deployment 
    strategies, robust validation, and advanced security features.
    
    ## Framework Overview
    Built as a modular component within a Sentinel-focused IaC framework that supports:
    - Log Analytics Workspaces and Microsoft Sentinel deployments
    - Sentinel Analytics Rules (Scheduled and Near Real-Time)
    - Sentinel Watchlists with advanced management capabilities
    
    The framework uses a hybrid approach: Bicep templates for infrastructure and REST API calls for Sentinel-specific 
    configurations. All components share standardized patterns for authentication, validation, and error handling.
    
    ## Prerequisites & Requirements
    - PowerShell 5.1 or later
    - Azure CLI authentication (used by the framework's service connection pattern)
    - Required RBAC permissions for the Service Principal:
      * Microsoft Sentinel Contributor role on the workspace
      * Reader permissions on subscription and resource group
      * Log Analytics Workspace access
    
    ## Authentication & Security
    Uses Azure DevOps service connections with service principal delegation for secure, scalable authentication.
    The service principal leverages Azure CLI's built-in token management for reliable API access across all 
    framework components.
    
    ## Framework Integration
    Designed for Azure DevOps pipeline execution with standardized parameter passing via pipeline variables 
    (pipeline-variables.yml). Implements consistent REST API patterns and enterprise validation standards 
    used across all framework components.
    
    ## Advanced CSV Validation & Security
    Features comprehensive CSV validation with:
    - **Automatic Data Type Detection**: Analyzes column content to detect inconsistent data types and formatting issues
    - **Duplicate Detection**: Identifies duplicate values in search key columns and across rows
    - **Security Scanning**: Detects potential CSV injection attacks and malicious content patterns
    - **Schema Change Detection**: Automatically detects column additions, removals, or reordering
    - **Syntax Validation**: Verifies CSV structure, encoding, and format compliance
    - **Data Integrity Checks**: Validates field lengths, special characters, and content patterns
    
    ## Intelligent Deployment Strategies
    Features smart deployment strategies that automatically choose between:
    - **Update Strategy**: For data-only changes when column schema remains unchanged
    - **Recreation Strategy**: When columns are added/removed/reordered, items need removal, or search key changes
    
    ## Enhanced Change Analysis
    Includes sophisticated change tracking that:
    - Compares existing and new datasets at both schema and data levels
    - Automatically triggers watchlist recreation when column schema changes are detected
    - Skips item-level comparison when column changes make it irrelevant (with informational logging)
    - Provides detailed change summaries for additions, updates, and removals
    - Handles search key changes with proper recreation logic
    
    ## Multi-Stage Validation Pipeline
    Implements comprehensive validation covering:
    - Subscription verification and accessibility
    - Resource group validation and permissions
    - Log Analytics workspace confirmation
    - Microsoft Sentinel deployment verification
    - CSV file accessibility and security scanning
    - Column schema validation and change detection
    - Data integrity and format compliance
    
    ## Enterprise Features
    - Production-ready error handling with detailed troubleshooting guidance and retry logic for transient failures
    - Enhanced CSV validation with automatic data type detection and security scanning
    - Column schema change detection with automatic watchlist recreation
    - Comprehensive logging with verbose output for deployment tracking and audit requirements
    - Configurable SearchKey parameter for flexible column-based item identification
    - Robust error reporting with clear diagnostic information for pipeline debugging
    
    ## Validation Testing Resources
    The framework includes a comprehensive test suite for validation testing located in the 
    Template/Sample-CSVs/ directory, featuring:
    - **Sample CSV Files**: Pre-configured test files for various validation scenarios
    - **Error Test Cases**: CSV files designed to trigger specific validation errors (syntax errors, 
      data type mismatches, security issues, duplicate detection)
    - **Schema Change Tests**: Files to test column addition, removal, and reordering scenarios
    - **Documentation**: README.md and QUICK-START.md guides for testing procedures
    
    These resources enable thorough testing of all validation features and provide examples for 
    understanding expected behavior across different CSV data scenarios.

.PARAMETER WatchlistFilePath
    Path to the CSV file containing watchlist data. The file must include a header row with column names
    and at least one data row. All data is validated for integrity and format compliance.
    
    Required: Yes
    Type: String
    Example: "C:\Data\watchlist.csv"

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

.PARAMETER WatchlistAlias
    Name/alias of the watchlist to create or update in Microsoft Sentinel. This serves as the
    unique identifier for the watchlist within the workspace.
    
    Required: Yes
    Type: String
    Example: "ThreatIntelligence"

.PARAMETER WatchlistDescription
    Description of the watchlist displayed in Microsoft Sentinel. This helps users
    understand the purpose and contents of the watchlist.
    
    Required: Yes
    Type: String
    Example: "Known threat indicators and IOCs for threat hunting"

.PARAMETER SearchKey
    Column name to use as the search key for watchlist item comparison and identification.
    If not provided, defaults to the first column in the CSV file. The specified column must 
    exist in the CSV file.
    
    This parameter enables optimized item comparison, change tracking, and deduplication within 
    Microsoft Sentinel. When the search key changes or column schema changes are detected 
    (additions, removals, reordering), the script automatically recreates the watchlist to 
    ensure data consistency and proper indexing.
    
    The script intelligently handles schema changes by detecting column modifications and 
    triggering watchlist recreation when necessary, ensuring reliable operation regardless
    of data structure evolution.
    
    Required: No
    Type: String
    Default: First column in CSV
    Example: "userPrincipalName"

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    System.Object
    Returns detailed deployment information including watchlist ID, status, and deployment summary within the Azure Pipeline execution log.

.NOTES
    File Name      : watchlist-deploy.ps1
    Author         : Marcus Jacobson
    Prerequisite   : Azure CLI, PowerShell 5.1 or later, Microsoft Sentinel enabled workspace
    Version        : 3.0
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
    https://docs.microsoft.com/en-us/azure/sentinel/watchlists
    https://docs.microsoft.com/en-us/rest/api/securityinsights/
    https://docs.microsoft.com/en-us/azure/sentinel/kusto-queries
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true,
        HelpMessage = "ID of the subscription to deploy to.")]
    [string]$SubscriptionID,

    [Parameter(Mandatory = $true,
        HelpMessage = "Name of the resource group to deploy to.")]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true,
        HelpMessage = "Name of the Log Analytics Workspace.")]
    [string]$LogAnalyticsWorkspaceName,

    [Parameter(Mandatory = $true,
        HelpMessage = "File path for CSV file with Watchlist details.")]
    [string]$WatchlistFilePath,    
    
    [Parameter(Mandatory = $true,
        HelpMessage = "Name of Watchlist to create.")]
    [string]$WatchlistAlias,    
    
    [Parameter(Mandatory = $true,
        HelpMessage = "Description of watchlist.")]
    [string]$WatchlistDescription,
    
    [Parameter(Mandatory = $false,
        HelpMessage = "Optional search key column name for watchlist item comparison. If not provided, defaults to the first column in the CSV.")]
    [string]$SearchKey
)

# Function to detect data type of a value
function Get-DataType {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Value
    )
    
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return 'Empty'
    }
    
    # Check for GUID format
    if ([System.Guid]::TryParse($Value, [ref][System.Guid]::Empty)) {
        return 'GUID'
    }
    
    # Check for email format (UPN)
    if ($Value -match '^[^\s@]+@[^\s@]+\.[^\s@]+$') {
        return 'Email'
    }
    
    # Check for IP address format
    if ($Value -match '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$') {
        return 'IPAddress'
    }
    
    # Check for URL format
    if ($Value -match '^https?://[^\s/$.?#].[^\s]*$') {
        return 'URL'
    }
    
    # Check for numeric format (integer)
    if ($Value -match '^\d+$') {
        return 'Number'
    }
    
    # Check for decimal format
    if ($Value -match '^\d+\.\d+$') {
        return 'Decimal'
    }
    
    # Check for boolean format
    if ($Value -match '^(true|false|1|0)$' -and $Value.Length -le 5) {
        return 'Boolean'
    }
      # Check for date format (basic ISO format)
    try {
        [void][DateTime]::Parse($Value)
        return 'DateTime'
    } catch {
        # Not a valid date
    }
    
    # Default to string
    return 'String'
}

# Function to validate CSV syntax and data consistency
function Test-CSVIntegrity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    $validationResults = @{
        IsValid = $true
        Errors = @()
        Warnings = @()
        Statistics = @{
            TotalRows = 0
            TotalColumns = 0
            EmptyFields = 0
            DuplicateRows = 0
            DataTypeInconsistencies = 0
        }
        DataTypes = @{}
    }
    
    try {
        # Read CSV file content
        $rawContent = Get-Content -Path $FilePath -Raw
        if ([string]::IsNullOrWhiteSpace($rawContent)) {
            $validationResults.Errors += "CSV file is empty"
            $validationResults.IsValid = $false
            return $validationResults
        }
        
        # Quick delimiter detection using string methods
        $firstLine = $rawContent.Split("`n")[0]
        $commaCount = ($firstLine.Split(',').Length - 1)
        $semicolonCount = ($firstLine.Split(';').Length - 1)
        $tabCount = ($firstLine.Split("`t").Length - 1)
        
        # Determine the most likely delimiter based on counts
        $delimiter = ','
        if ($semicolonCount -gt $commaCount -and $semicolonCount -gt $tabCount) {
            $delimiter = ';'
        } elseif ($tabCount -gt $commaCount -and $tabCount -gt $semicolonCount) {
            $delimiter = "`t"
        }
          # Check for duplicate delimiters (consecutive delimiters indicating empty fields)
        $lines = $rawContent.Split("`n")
        $duplicateDelimiterPattern = switch ($delimiter) {
            ',' { ',,' }
            ';' { ';;' }
            "`t" { "`t`t" }
            default { ',,' }
        }
          $lineNumber = 1
        foreach ($line in $lines) {
            if ($line.Trim()) {  # Skip empty lines
                if ($line.Contains($duplicateDelimiterPattern)) {
                    $validationResults.Errors += "Row ${lineNumber}: Consecutive delimiters detected ('$duplicateDelimiterPattern') indicating empty fields - this can cause critical data parsing issues"
                    $validationResults.IsValid = $false
                }
                
                # Check for leading/trailing delimiters which also indicate structural issues
                $trimmedLine = $line.Trim()
                if ($trimmedLine.StartsWith($delimiter) -or $trimmedLine.EndsWith($delimiter)) {
                    $validationResults.Errors += "Row ${lineNumber}: Line starts or ends with delimiter ('$delimiter') indicating malformed CSV structure"
                    $validationResults.IsValid = $false
                }
            }
            $lineNumber++
        }
          # Try to import CSV early - if this fails, we have fundamental syntax issues
        try {
            $csvData = Import-Csv -Path $FilePath -Delimiter $delimiter -ErrorAction Stop
        }
        catch {
            $validationResults.Errors += "Failed to parse CSV: $($_.Exception.Message)"
            $validationResults.IsValid = $false
            return $validationResults
        }
        
        if ($csvData.Count -eq 0) {
            $validationResults.Errors += "CSV contains no data rows"
            $validationResults.IsValid = $false
            return $validationResults
        }
        
        # Get headers and validate them once
        $headers = ($csvData[0] | Get-Member -MemberType NoteProperty).Name
        $validationResults.Statistics.TotalColumns = $headers.Count
        $validationResults.Statistics.TotalRows = $csvData.Count
        
        # Validate consistent column count across all rows (critical for data integrity)
        $rawLines = $rawContent.Split("`n") | Where-Object { $_.Trim() }
        $headerColumnCount = ($rawLines[0].Split($delimiter)).Count
        
        for ($i = 1; $i -lt $rawLines.Count; $i++) {
            $line = $rawLines[$i].Trim()
            if ($line) {
                $actualColumnCount = ($line.Split($delimiter)).Count
                if ($actualColumnCount -ne $headerColumnCount) {
                    $validationResults.Errors += "Row $($i + 1): Column count mismatch - expected $headerColumnCount columns but found $actualColumnCount. This indicates malformed CSV structure."
                    $validationResults.IsValid = $false
                }
            }        }
        
        # Batch validate headers
        $headerValidation = Test-CSVHeaders -Headers $headers
        $validationResults.Errors += $headerValidation.Errors
        $validationResults.Warnings += $headerValidation.Warnings
        if (-not $headerValidation.IsValid) {
            $validationResults.IsValid = $false
        }
        
        # Initialize data type tracking efficiently
        $dataTypeTracking = @{}
        $columnValues = @{}  # Store all values per column for efficient duplicate checking
        
        # Initialize data type results for each header
        foreach ($header in $headers) {
            $dataTypeTracking[$header] = @{}
            $columnValues[$header] = @()
            $validationResults.DataTypes[$header] = @{
                DetectedTypes = @{}
                MostCommonType = ''
                ConsistencyPercentage = 0
            }
        }
        
        # Single pass through data for all content validation
        $rowIndex = 2
        $emptyFieldCount = 0
        $rowHashes = @{}
        
        # Iterate through each row in the CSV data
        foreach ($row in $csvData) {
            $isEmptyRow = $true
            $rowData = @()
            
            foreach ($header in $headers) {
                $cellValue = $row.$header
                $rowData += $cellValue
                
                if ([string]::IsNullOrWhiteSpace($cellValue)) {
                    $emptyFieldCount++
                    if ($null -eq $cellValue -or $cellValue -eq '') {
                        # Collect empty value warnings but don't add immediately (batch later if needed)
                    }
                } else {
                    $isEmptyRow = $false
                    $trimmedValue = $cellValue.ToString().Trim()
                    
                    # Store value for duplicate checking
                    $columnValues[$header] += $cellValue
                    
                    # Batch data type detection and validation
                    $dataType = Get-DataType -Value $trimmedValue
                    if (-not $dataTypeTracking[$header].ContainsKey($dataType)) {
                        $dataTypeTracking[$header][$dataType] = 0
                    }
                    $dataTypeTracking[$header][$dataType]++
                    
                    # Quick validation checks (batch the expensive ones)
                    if ($cellValue.Length -gt 8000) {
                        $validationResults.Errors += "Row $rowIndex, Column '$header': Value exceeds 8000 characters"
                        $validationResults.IsValid = $false
                    }
                    
                    # Check for potential injection attempts (simple character check)
                    $firstChar = $cellValue[0]
                    if ($firstChar -eq '=' -or $firstChar -eq '+' -or $firstChar -eq '-' -or $firstChar -eq '@') {
                        $validationResults.Warnings += "Row $rowIndex, Column '$header': Starts with special character ($firstChar)"
                    }
                }
            }
            
            # Check for completely empty rows
            if ($isEmptyRow) {
                $validationResults.Warnings += "Row $rowIndex is completely empty"
            }
            
            # Efficient duplicate detection using hash
            $rowHash = ($rowData -join '|').GetHashCode()
            if ($rowHashes.ContainsKey($rowHash)) {
                $validationResults.Statistics.DuplicateRows++
            } else {
                $rowHashes[$rowHash] = $rowIndex
            }
            
            $rowIndex++
        }
        
        # Finalize statistics
        $validationResults.Statistics.EmptyFields = $emptyFieldCount
        
        # Batch process data type analysis and duplicate detection
        foreach ($header in $headers) {
            $typeStats = $dataTypeTracking[$header]
            $validationResults.DataTypes[$header].DetectedTypes = $typeStats
            
            if ($typeStats.Count -gt 0) {
                $mostCommon = $typeStats.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1
                $validationResults.DataTypes[$header].MostCommonType = $mostCommon.Key
                
                $totalValues = ($typeStats.Values | Measure-Object -Sum).Sum
                $consistencyPercentage = if ($totalValues -gt 0) { [Math]::Round(($mostCommon.Value / $totalValues) * 100, 2) } else { 0 }
                $validationResults.DataTypes[$header].ConsistencyPercentage = $consistencyPercentage
                
                if ($typeStats.Count -gt 1 -and $consistencyPercentage -lt 90) {
                    $validationResults.Statistics.DataTypeInconsistencies++
                    $validationResults.Warnings += "Column '$header' has mixed data types (${consistencyPercentage}% consistency)"
                }
                
                # Efficient duplicate checking for special types
                if ($mostCommon.Key -eq 'GUID' -or $mostCommon.Key -eq 'Email') {
                    $nonEmptyValues = $columnValues[$header] | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
                    $duplicateCount = $nonEmptyValues.Count - ($nonEmptyValues | Select-Object -Unique).Count
                    if ($duplicateCount -gt 0) {
                        $validationResults.Warnings += "Column '$header' contains $duplicateCount duplicate $($mostCommon.Key) values"
                    }
                }
            }
        }        
    } catch {
        $validationResults.Errors += "Failed to read CSV file: $($_.Exception.Message)"
        $validationResults.IsValid = $false
    }
    
    return $validationResults
}

# Helper function for efficient header validation
function Test-CSVHeaders {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Headers
    )
    
    $result = @{
        IsValid = $true
        Errors = @()
        Warnings = @()
    }
      # Check for duplicate headers
    $duplicateHeaders = $Headers | Group-Object | Where-Object { $_.Count -gt 1 }
    if ($duplicateHeaders) {
        foreach ($duplicateHeader in $duplicateHeaders) {
            $result.Errors += "Duplicate column header: '$($duplicateHeader.Name)'"
            $result.IsValid = $false
        }
    }
    
    # Batch validate all headers
    foreach ($header in $Headers) {
        # Check for problematic characters
        if ($header -match '[^\w\s\-_\.]') {
            $result.Warnings += "Column header '$header' contains special characters"
        }
        
        # Check for long headers
        if ($header.Length -gt 100) {
            $result.Warnings += "Column header '$header' is very long ($($header.Length) characters)"
        }
        
        # Check for headers starting with numbers
        if ($header -match '^\d') {
            $result.Warnings += "Column header '$header' starts with a number"
        }
    }
    
    return $result
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
        Write-Verbose "No Sentinel instance found with expected name: $expectedSolutionName" -Verbose
        $sentinelSolutionExists = $false
    }

}
catch {
    Write-Error "Failed to validate Sentinel deployment. Error: $($_.Exception.Message)"
}  


# Perform actions based on the existence of the Sentinel onboarding state and instance
if ($sentinelSolutionExists) {
    Write-Verbose "        Sentinel Workspace exists for Log Analytics Workspace [$($LogAnalyticsWorkspaceName)]..." -Verbose
    Write-Verbose "        Continuing with watchlist creation." -Verbose
}

else {
    Write-Error "Sentinel Instance is does not exist for Log Analytics Workspace [$($LogAnalyticsWorkspaceName)]. Please ensure Sentinel is onboarded before creating analytic rules." -Verbose
}

# Validate Watchlist File
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Validating Watchlist file..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Read the CSV file and validate its structure
try {
    # Read and validate the CSV content
    if (-not (Test-Path -Path $WatchlistFilePath)) {
        throw "Watchlist file not found at: $WatchlistFilePath"
    }    
    
    # Perform comprehensive CSV validation with automatic data type detection
    Write-Verbose "    Performing comprehensive CSV syntax and content validation..." -Verbose
    $validationResult = Test-CSVIntegrity -FilePath $WatchlistFilePath
    
    # Report validation statistics
    Write-Verbose "    Validation Statistics:" -Verbose
    Write-Verbose "        Total Rows: $($validationResult.Statistics.TotalRows)" -Verbose
    Write-Verbose "        Total Columns: $($validationResult.Statistics.TotalColumns)" -Verbose
    Write-Verbose "        Empty Fields: $($validationResult.Statistics.EmptyFields)" -Verbose
    Write-Verbose "        Duplicate Rows: $($validationResult.Statistics.DuplicateRows)" -Verbose
    Write-Verbose "        Data Type Inconsistencies: $($validationResult.Statistics.DataTypeInconsistencies)" -Verbose
    
    # Report detected data types per column
    if ($validationResult.DataTypes.Count -gt 0) {
        Write-Verbose "    Detected Data Types by Column:" -Verbose
        foreach ($column in $validationResult.DataTypes.Keys) {
            $typeInfo = $validationResult.DataTypes[$column]
            if ($typeInfo.MostCommonType) {
                Write-Verbose "        '$column': $($typeInfo.MostCommonType) ($($typeInfo.ConsistencyPercentage)% consistent)" -Verbose
            }
        }
    }
    
    # Report warnings
    if ($validationResult.Warnings.Count -gt 0) {
        Write-Verbose "    Validation Warnings:" -Verbose
        foreach ($warning in $validationResult.Warnings) {
            Write-Verbose "        WARNING: $warning" -Verbose
        }
    }    # Handle validation errors
    if (-not $validationResult.IsValid) {
        Write-Verbose "    CSV validation failed with the following errors:" -Verbose
        foreach ($validationError in $validationResult.Errors) {
            Write-Verbose "        ERROR: $validationError" -Verbose
        }
        Write-Error "CSV file validation failed. Please correct the errors and try again."
        throw "CSV file validation failed. Please correct the errors and try again."
    }

    # Read the CSV content for further processing (now that we know it's valid)
    $csvContent = Import-Csv -Path $WatchlistFilePath -ErrorAction Stop
    
    if ($csvContent.Count -eq 0) {
        throw "Watchlist CSV file is empty or contains no data rows"
    }
    
    Write-Verbose "    CSV file successfully validated and contains $($csvContent.Count) data rows" -Verbose
    
    # Read and validate column structure dynamically from CSV
    $csvHeaders = ($csvContent[0] | Get-Member -MemberType NoteProperty).Name
    
    if ($csvHeaders.Count -eq 0) {
        throw "No columns found in CSV file. Please ensure the CSV has a valid header row."
    }
      # Set the detected columns as the schema for validation
    $detectedColumns = $csvHeaders
    
    Write-Verbose "    CSV file validation completed successfully:" -Verbose
    Write-Verbose "        Validated $($csvContent.Count) watchlist entries across $($detectedColumns.Count) columns with no errors" -Verbose
    Write-Verbose "        Column schema: $($detectedColumns -join ', ')" -Verbose
    
    # Validate and set search key column
    if ([string]::IsNullOrWhiteSpace($SearchKey)) {
        # No search key provided, default to first column
        $searchKeyColumn = $detectedColumns[0]
        Write-Verbose "    Search key not specified, defaulting to first column: '$searchKeyColumn'" -Verbose
    }
    else {
        # Search key provided, validate it exists in CSV columns
        if ($detectedColumns -contains $SearchKey) {
            $searchKeyColumn = $SearchKey
            Write-Verbose "    Using specified search key column: '$searchKeyColumn'" -Verbose
        }
        else {
            $availableColumns = $detectedColumns -join "', '"
            Write-Error "Specified search key column '$SearchKey' was not found in CSV columns. Available columns: '$availableColumns'"
            throw "Invalid search key column specified. Please use one of the available column names from the CSV file."
        }
    }
}

catch {
    $exceptionMessage = $_.Exception.Message
    Write-Error "Failed to read or validate Watchlist file. Error: $exceptionMessage"
    throw
}

# Validate Watchlist existence
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Checking if Sentinel Watchlist already exists in the workspace [$($LogAnalyticsWorkspaceName)]..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define the URI to query the existing watchlists in the workspace
$uri = "https://management.azure.com/subscriptions/$($SubscriptionID)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($LogAnalyticsWorkspaceName)/providers/Microsoft.SecurityInsights/watchlists?api-version=2023-02-01-preview"

# Prepare query object for REST API call
$watchlistQueryObject = @{
    'method' = 'GET'
    'uri' = $uri
}

# Call the Invoke-RESTCommand function to check existing watchlists
try {
    $response = Invoke-RESTCommand @watchlistQueryObject
    
    # Check if the response contains any watchlists
    if ($response.value -and $response.value.Count -gt 0) {
        Write-Verbose "    Watchlists found in workspace [$($LogAnalyticsWorkspaceName)]:" -Verbose

        #Output found watchlists
        foreach ($watchlist in $response.value) {
            Write-Verbose "        Watchlist Name: $($watchlist.name)" -Verbose
        }
        
        Write-Verbose "" -Verbose
        
        # Check if a watchlist with the same name already exists
        $existingWatchlist = $response.value | Where-Object { $_.name -eq $WatchlistAlias }
          if ($existingWatchlist) {
            $isNewDeployment = $false
            Write-Verbose "    Watchlist [$($WatchlistAlias)] already exists." -Verbose
            
            # Get the existing search key from the watchlist properties
            $existingSearchKey = $null
            if ($existingWatchlist.properties -and $existingWatchlist.properties.itemsSearchKey) {
                $existingSearchKey = $existingWatchlist.properties.itemsSearchKey
                Write-Verbose "    Existing watchlist search key: '$existingSearchKey'" -Verbose
            } else {
                Write-Verbose "    Warning: Could not determine existing watchlist search key" -Verbose
            }
            
            # Retrieve existing watchlist items for validation and comparison
            Write-Verbose "    Retrieving existing watchlist items for validation and change tracking..." -Verbose
            $existingItemsUri = "https://management.azure.com/subscriptions/$($SubscriptionID)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($LogAnalyticsWorkspaceName)/providers/Microsoft.SecurityInsights/watchlists/$($WatchlistAlias)/watchlistItems?api-version=2023-02-01-preview"
            
            # Define the query object for retrieving existing watchlist items
            $existingItemsQueryObject = @{
                'method' = 'GET'
                'uri' = $existingItemsUri
            }
            
            # Attempt to retrieve existing watchlist items
            try {
                $existingItemsResponse = Invoke-RESTCommand @existingItemsQueryObject
                if ($existingItemsResponse.value) {
                    $existingWatchlistItems = $existingItemsResponse.value
                    Write-Verbose "    Found $($existingWatchlistItems.Count) existing items in watchlist" -Verbose
                    
                    # Validate the specified search key against existing watchlist structure if a custom search key is provided
                    if (-not [string]::IsNullOrWhiteSpace($SearchKey) -and $existingWatchlistItems.Count -gt 0) {
                        $existingItemSample = $existingWatchlistItems[0]
                        
                        # Check if the existing item sample has properties and itemsKeyValue
                        if ($existingItemSample.properties -and $existingItemSample.properties.itemsKeyValue) {
                            $existingColumns = ($existingItemSample.properties.itemsKeyValue | Get-Member -MemberType NoteProperty).Name
                            
                            # Validate the search key column against existing columns
                            if ($existingColumns -notcontains $SearchKey) {
                                $availableColumns = $existingColumns -join "', '"
                                Write-Error "Specified search key column '$SearchKey' does not exist in the existing watchlist structure."
                                Write-Error "Available columns in existing watchlist: '$availableColumns'"
                                throw "Invalid search key column specified for existing watchlist. The column must exist in the current watchlist structure."
                            } else {
                                Write-Verbose "    Validated: Search key column '$SearchKey' exists in existing watchlist structure" -Verbose
                            }
                        }
                    }
                } else {
                    $existingWatchlistItems = @()
                    Write-Verbose "    No existing items found in watchlist" -Verbose
                }
            }            catch {
                if ($_.Exception.Message -match "Invalid search key column") {
                    throw  # Re-throw validation errors
                }
                Write-Verbose "    Warning: Could not retrieve existing watchlist items for comparison. Error: $($_.Exception.Message)" -Verbose
                $existingWatchlistItems = @()
            }
        }
        else {
            $isNewDeployment = $true
            $existingWatchlistItems = @()
            Write-Verbose "    No watchlist found with the name [$($WatchlistAlias)]." -Verbose
            Write-Verbose "    Proceeding with watchlist deployment." -Verbose
        }
    }    else {
        $isNewDeployment = $true
        $existingWatchlistItems = @()
        Write-Verbose "    No watchlists found in workspace [$($LogAnalyticsWorkspaceName)]" -Verbose
        Write-Verbose "    Proceeding with watchlist deployment." -Verbose
    }
}
catch {
    Write-Error "Failed to retrieve watchlists in the workspace. Error: $($_.Exception.Message)"
    throw
}

# Perform change analysis for existing watchlists
$addedItems = @()
$removedItems = @()
$searchKeyChanged = $false
$columnsChanged = $false

if (-not $isNewDeployment -and $existingWatchlistItems) {
    Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
    Write-Verbose "Analyzing watchlist changes before deployment..." -Verbose
    Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
    
    Write-Verbose "    New search key column: '$searchKeyColumn'" -Verbose
    
    # Check if search key has changed
    if ($existingSearchKey -and $existingSearchKey -ne $searchKeyColumn) {
        $searchKeyChanged = $true
        Write-Verbose "    Search key change detected: '$existingSearchKey' -> '$searchKeyColumn'" -Verbose
        Write-Verbose "    Watchlist will be deleted and recreated due to search key change." -Verbose
    } else {
        Write-Verbose "    Search key unchanged: '$searchKeyColumn'" -Verbose
    }
    
    # Check for column schema changes (added, removed, or reordered columns)
    if ($existingWatchlistItems.Count -gt 0) {
        $existingItemSample = $existingWatchlistItems[0]
        
        # Compare the columns in the existing watchlist item with the detected columns
        if ($existingItemSample.properties -and $existingItemSample.properties.itemsKeyValue) {
            $existingColumns = @(($existingItemSample.properties.itemsKeyValue | Get-Member -MemberType NoteProperty).Name | Sort-Object)
            $newColumns = @($detectedColumns | Sort-Object)
            
            # Create strings to compare column schemas
            $existingColumnsString = $existingColumns -join ","
            $newColumnsString = $newColumns -join ","
            
            # Compare the existing and new column schema strings
            if ($existingColumnsString -ne $newColumnsString) {
                $columnsChanged = $true
                Write-Verbose "    Column schema change detected:" -Verbose
                Write-Verbose "        Existing columns ($($existingColumns.Count)): $($existingColumns -join ', ')" -Verbose
                Write-Verbose "        New columns ($($newColumns.Count)): $($newColumns -join ', ')" -Verbose
                
                # Identify specific changes
                $addedColumns = $newColumns | Where-Object { $_ -notin $existingColumns }
                $removedColumns = $existingColumns | Where-Object { $_ -notin $newColumns }
                
                # Log added and removed columns
                if ($addedColumns) {
                    Write-Verbose "        Added columns: $($addedColumns -join ', ')" -Verbose
                }
                if ($removedColumns) {
                    Write-Verbose "        Removed columns: $($removedColumns -join ', ')" -Verbose
                }
                
                Write-Verbose "    Watchlist will be deleted and recreated due to column schema change." -Verbose
            } else {
                Write-Verbose "    Column schema unchanged: $($existingColumns -join ', ')" -Verbose
            }
        } else {
            Write-Verbose "    Warning: Could not determine existing column schema for comparison" -Verbose
        }
    }    
    
    # Perform detailed change analysis if columns haven't changed
    if (-not $columnsChanged) {
        # Create lookup tables for comparison
        $existingItemsLookup = @{}
        
        # Populate existing items lookup with search key values
        foreach ($existingItem in $existingWatchlistItems) {
            if ($existingItem.properties -and $existingItem.properties.itemsKeyValue) {
                
                # Extract the search key value from the existing item
                $keyValue = $existingItem.properties.itemsKeyValue.$searchKeyColumn
                
                # If the key value exists, add it to the lookup
                if ($keyValue) {
                    $existingItemsLookup[$keyValue] = $existingItem.properties.itemsKeyValue
                }
            }
        }
        
        # Create lookup for new items
        $newItemsLookup = @{}
        
        # Populate new items lookup with search key values
        foreach ($newItem in $csvContent) {
            
            # Extract the search key value from the new item
            $keyValue = $newItem.$searchKeyColumn
            
            # If the key value exists, add it to the lookup
            if ($keyValue) {
                $newItemsLookup[$keyValue] = $newItem
            }
        }
        
        # Find added items (in new but not in existing)
        foreach ($newKey in $newItemsLookup.Keys) {
            if (-not $existingItemsLookup.ContainsKey($newKey)) {
                $addedItems += $newItemsLookup[$newKey]
            }
        }
        
        # Find removed items (in existing but not in new)
        foreach ($existingKey in $existingItemsLookup.Keys) {
            
            # If the existing key is not in the new items lookup, add it to removed items
            if (-not $newItemsLookup.ContainsKey($existingKey)) {
                $removedItems += $existingItemsLookup[$existingKey]
            }
        }        
        
        Write-Verbose "    Change analysis complete:" -Verbose
        Write-Verbose "        Added: $($addedItems.Count) items" -Verbose
        Write-Verbose "        Removed: $($removedItems.Count) items" -Verbose        
        Write-Verbose "        Total items after update: $($csvContent.Count)" -Verbose
        
        # Add informational note if search key changed
        if ($searchKeyChanged) {
            Write-Verbose "    NOTE: Change analysis is informational only since watchlist will be recreated due to search key change." -Verbose
        }
    } else {
        # Skip detailed change analysis when column schema has changed
        # Column changes make item-level comparison meaningless due to schema differences
        Write-Verbose "    Skipping detailed change analysis due to column schema change." -Verbose
        Write-Verbose "    All items will be considered as new after recreation." -Verbose
    }
}

# Deploy Watchlist
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
Write-Verbose  "Deploying or updating Sentinel watchlist [$($WatchlistAlias)] to [$($LogAnalyticsWorkspaceName)]..." -Verbose
Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

# Define variables for deployment strategy
$needsRecreation = $false
$recreationReason = ""

# Determine deployment strategy based on whether there are removals or search key changes
if (-not $isNewDeployment -and $existingWatchlistItems) {
    
    # Prepare recreation strategy due to search key change
    if ($searchKeyChanged) {
        $needsRecreation = $true
        $recreationReason = "search key change from '$existingSearchKey' to '$searchKeyColumn'"
        Write-Verbose "    Search key change detected. Watchlist will be deleted and recreated." -Verbose
    } 
    
    # Prepare recreation strategy due to column change
    elseif ($columnsChanged) {
        $needsRecreation = $true
        $recreationReason = "column schema change detected"
        Write-Verbose "    Column schema change detected. Watchlist will be deleted and recreated." -Verbose
    } 
    
    # Prepare recreation strategy due to items being deleted
    elseif ($removedItems.Count -gt 0) {
        $needsRecreation = $true
        $recreationReason = "$($removedItems.Count) items to be removed"
        Write-Verbose "    Detected $($removedItems.Count) items to be removed. Watchlist will be deleted and recreated." -Verbose
    }
}

if ($needsRecreation) {
    
    # Delete existing watchlist first
    Write-Verbose "    Deleting existing watchlist due to: $recreationReason..." -Verbose
    $deleteUri = "https://management.azure.com/subscriptions/$($SubscriptionID)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($LogAnalyticsWorkspaceName)/providers/Microsoft.SecurityInsights/watchlists/$($WatchlistAlias)?api-version=2025-03-01"
    
    # Prepare query object for REST API call
    $deleteWatchlistObject = @{
        'method' = 'DELETE'
        'uri' = $deleteUri
    }
    
    try {
        
        # Call the Invoke-RESTCommand function delete watchlist
        $deleteResponse = Invoke-RESTCommand @deleteWatchlistObject
        
        # Confirm watchlist has been deleted
        if ($deleteResponse -or $null -eq $deleteResponse) {
            Write-Verbose "        Existing watchlist deleted successfully." -Verbose
        }
        
        # Wait a moment for the deletion to complete
        Start-Sleep -Seconds 5
    }
    catch {
        Write-Error "Failed to delete existing watchlist. Error: $($_.Exception.Message)"
        throw
    }
} else {
    Write-Verbose "    No search key changes or item removals detected. Proceeding with standard update." -Verbose
}

Write-Verbose "" -Verbose

# Define URI to create or update the watchlist
$uri = "https://management.azure.com/subscriptions/$($SubscriptionID)/resourceGroups/$($ResourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($LogAnalyticsWorkspaceName)/providers/Microsoft.SecurityInsights/watchlists/$($WatchlistAlias)?api-version=2025-03-01"

# Read the raw CSV content as string for the source property
$csvRawContent = Get-Content -Path $WatchlistFilePath -Raw
$csvRawContent = $csvRawContent.Trim()  # Remove any trailing whitespace

# Prepare watchlist body for the REST API call
$watchlistBody = @{
    properties = @{
        displayName = $WatchlistAlias
        description = $WatchlistDescription
        provider = "Microsoft"
        sourceType = "Local"
        rawContent = $csvRawContent
        itemsSearchKey = $searchKeyColumn  # Use the validated search key column as the search key
        contentType = "text/csv"
    }
} | ConvertTo-Json -Depth 10

# Prepare query object for REST API call
$watchlistObject = @{
    'method' = 'PUT'
    'uri' = $uri
    'body' = $watchlistBody
}


Write-Verbose "    Sending watchlist deployment request..." -Verbose
Write-Verbose "        Watchlist payload size: $($watchlistBody.Length) characters" -Verbose

try { 
    # Call the Invoke-RESTCommand function to deploy the watchlist
    $response = Invoke-RESTCommand @watchlistObject
    
    # Output summary if the Watchlist has been deployed successfully
    if ($response -and $response.id) {
        Write-Verbose "    Watchlist [$($WatchlistAlias)] deployed successfully." -Verbose

        Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
        Write-Verbose  "Watchlist Deployment Summary" -Verbose
        Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose

        Write-Verbose "    Watchlist ID: $($response.id)" -Verbose        
        Write-Verbose "    Watchlist Name: $($response.name)" -Verbose
        if ($response.properties) {

            # Display watchlist properties
            if ($null -ne $response.properties.numberOfLinesToSkip) {
                Write-Verbose "    Lines to Skip: $($response.properties.numberOfLinesToSkip)" -Verbose
            }
            if ($response.properties.uploadStatus) {
                Write-Verbose "    Upload Status: $($response.properties.uploadStatus)" -Verbose
            }
            
            # Output deployment summary for new watchlist deployment            
            if ($isNewDeployment) {
                Write-Verbose "    Deployment Type: New watchlist creation" -Verbose
                Write-Verbose "    Data Rows Deployed: $($csvContent.Count)" -Verbose
                Write-Verbose "    Search Key Column: $searchKeyColumn" -Verbose
            } 
            
            # Output deployment summaries depending on recreation strategy
            else {
                if ($needsRecreation) {
                    
                    # Summary output for recreated watchlist due to a new Search key
                    if ($searchKeyChanged) {
                        Write-Verbose "    Deployment Type: Watchlist recreation (due to search key change)" -Verbose
                        Write-Verbose "    Previous Search Key: $existingSearchKey" -Verbose
                        Write-Verbose "    New Search Key: $searchKeyColumn" -Verbose
                    } 
                    
                    # Summary output for recreated watchlist due to item removals
                    else {
                        Write-Verbose "    Deployment Type: Watchlist recreation (due to item removals or column schema change)" -Verbose
                        Write-Verbose "    Search Key Column: $searchKeyColumn" -Verbose
                    }
                } 
                
                # Summary output for appended rows to an existing watchlist
                else {
                    Write-Verbose "    Deployment Type: Watchlist update (append/deduplicate)" -Verbose
                    Write-Verbose "    Search Key Column: $searchKeyColumn" -Verbose
                }
                
                Write-Verbose "    Total Data Rows: $($csvContent.Count)" -Verbose                
                
                # Only show added/removed counts if we performed detailed analysis (no search key change)
                if (-not $searchKeyChanged) {
                    Write-Verbose "    Added Items: $($addedItems.Count)" -Verbose
                    Write-Verbose "    Removed Items: $($removedItems.Count)" -Verbose
                } else {
                    Write-Verbose "    All items considered new due to search key change" -Verbose
                }
                
                # Display details of added/removed items only if we performed detailed analysis (no search key change)
                if (-not $searchKeyChanged) {
                    # Display details of added items if any
                    if ($addedItems.Count -gt 0) {
                        Write-Verbose "" -Verbose
                        Write-Verbose "    Added Items Details:" -Verbose
                        foreach ($addedItem in $addedItems) {
                            $searchKey = $addedItem.$searchKeyColumn
                            Write-Verbose "        + $searchKeyColumn`: $searchKey" -Verbose
                        }
                    }
                    
                    # Display details of removed items if any
                    if ($removedItems.Count -gt 0) {
                        Write-Verbose "" -Verbose
                        Write-Verbose "    Removed Items Details:" -Verbose
                        foreach ($removedItem in $removedItems) {
                            $searchKey = $removedItem.$searchKeyColumn
                            Write-Verbose "        - $searchKeyColumn`: $searchKey" -Verbose
                        }
                    }                
                }
            }
        }

        Write-Verbose  "-------------------------------------------------------------------------------------------------------------------" -Verbose
    }
    else {
        Write-Error "Failed to deploy watchlist. Response: $($response | ConvertTo-Json -Depth 5)"
        throw "Watchlist deployment failed."
    }
}
catch {
    Write-Error "Failed to deploy watchlist. Error: $($_.Exception.Message)"
    throw
}