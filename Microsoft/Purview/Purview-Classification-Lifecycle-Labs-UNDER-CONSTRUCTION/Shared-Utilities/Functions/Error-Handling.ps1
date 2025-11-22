# =============================================================================
# Error-Handling.ps1
# Standardized error handling functions
# =============================================================================

function Invoke-WithErrorHandling {
    <#
    .SYNOPSIS
        Execute script block with standardized error handling.
    
    .DESCRIPTION
        Wraps script execution with try-catch-finally pattern, provides consistent
        error logging and optional cleanup actions.
    
    .PARAMETER ScriptBlock
        Script block to execute
    
    .PARAMETER ErrorActionPreference
        Action on error: "Stop", "Continue", "SilentlyContinue"
    
    .PARAMETER Finally
        Script block to execute in finally clause (cleanup)
    
    .PARAMETER LogErrors
        Log errors to Purview log (default: $true)
    
    .EXAMPLE
        Invoke-WithErrorHandling -ScriptBlock { 
            Get-PnPWeb 
        } -Finally { 
            Disconnect-PnPOnline 
        }
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Stop", "Continue", "SilentlyContinue")]
        [string]$ErrorActionPreference = "Stop",
        
        [Parameter(Mandatory = $false)]
        [scriptblock]$Finally,
        
        [Parameter(Mandatory = $false)]
        [bool]$LogErrors = $true
    )
    
    try {
        & $ScriptBlock
    } catch {
        if ($LogErrors) {
            Write-PurviewError "Error in script execution: $_"
            
            $errorDetails = Get-DetailedErrorInfo -ErrorRecord $_
            Write-PurviewLog "Error details: $($errorDetails.ErrorMessage)" -Level "ERROR"
            Write-PurviewLog "Error location: $($errorDetails.ScriptName):$($errorDetails.LineNumber)" -Level "ERROR"
        }
        
        if ($ErrorActionPreference -eq "Stop") {
            throw
        } elseif ($ErrorActionPreference -eq "Continue") {
            Write-Warning "Error occurred but continuing: $_"
        }
    } finally {
        if ($Finally) {
            try {
                & $Finally
            } catch {
                Write-Warning "Error in finally block: $_"
            }
        }
    }
}

function Write-PurviewError {
    <#
    .SYNOPSIS
        Log errors with consistent formatting.
    
    .DESCRIPTION
        Writes error messages to log file and console with standardized formatting.
    
    .PARAMETER Message
        Error message
    
    .PARAMETER ErrorRecord
        PowerShell error record (optional)
    
    .PARAMETER IncludeStackTrace
        Include stack trace in log (default: $false)
    
    .EXAMPLE
        Write-PurviewError "Failed to connect to service" -ErrorRecord $_
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,
        
        [Parameter(Mandatory = $false)]
        [switch]$IncludeStackTrace
    )
    
    # Log primary error message
    Write-PurviewLog "❌ ERROR: $Message" -Level "ERROR"
    
    # Log error record details if provided
    if ($ErrorRecord) {
        $errorDetails = Get-DetailedErrorInfo -ErrorRecord $ErrorRecord
        
        Write-PurviewLog "  Error type: $($errorDetails.ErrorType)" -Level "ERROR"
        Write-PurviewLog "  Error message: $($errorDetails.ErrorMessage)" -Level "ERROR"
        
        if ($errorDetails.ScriptName) {
            Write-PurviewLog "  Location: $($errorDetails.ScriptName):$($errorDetails.LineNumber)" -Level "ERROR"
        }
        
        if ($IncludeStackTrace -and $errorDetails.StackTrace) {
            Write-PurviewLog "  Stack trace: $($errorDetails.StackTrace)" -Level "ERROR"
        }
    }
}

function Get-DetailedErrorInfo {
    <#
    .SYNOPSIS
        Extract comprehensive error details from ErrorRecord.
    
    .DESCRIPTION
        Parses PowerShell error record to extract useful debugging information.
    
    .PARAMETER ErrorRecord
        PowerShell error record
    
    .EXAMPLE
        $errorInfo = Get-DetailedErrorInfo -ErrorRecord $_
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )
    
    $errorInfo = [PSCustomObject]@{
        ErrorType = $ErrorRecord.Exception.GetType().FullName
        ErrorMessage = $ErrorRecord.Exception.Message
        ScriptName = $ErrorRecord.InvocationInfo.ScriptName
        LineNumber = $ErrorRecord.InvocationInfo.ScriptLineNumber
        LineText = $ErrorRecord.InvocationInfo.Line
        CommandName = $ErrorRecord.InvocationInfo.InvocationName
        StackTrace = $ErrorRecord.ScriptStackTrace
        TargetObject = $ErrorRecord.TargetObject
        CategoryInfo = $ErrorRecord.CategoryInfo.ToString()
        FullyQualifiedErrorId = $ErrorRecord.FullyQualifiedErrorId
    }
    
    return $errorInfo
}

function Test-PurviewOperation {
    <#
    .SYNOPSIS
        Validate operation success and return result.
    
    .DESCRIPTION
        Tests whether an operation completed successfully and returns standardized result object.
    
    .PARAMETER ScriptBlock
        Script block to test
    
    .PARAMETER OperationName
        Name of operation for logging
    
    .PARAMETER ExpectException
        Whether exception indicates failure (default: true)
    
    .EXAMPLE
        $result = Test-PurviewOperation -ScriptBlock { Get-PnPWeb } -OperationName "Get SharePoint Web"
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        
        [Parameter(Mandatory = $true)]
        [string]$OperationName,
        
        [Parameter(Mandatory = $false)]
        [bool]$ExpectException = $true
    )
    
    $result = [PSCustomObject]@{
        OperationName = $OperationName
        Success = $false
        ErrorMessage = $null
        Result = $null
        Timestamp = Get-Date
    }
    
    try {
        $result.Result = & $ScriptBlock
        $result.Success = $true
        Write-PurviewLog "✅ Operation succeeded: $OperationName" -Level "INFO"
    } catch {
        $result.Success = $false
        $result.ErrorMessage = $_.Exception.Message
        
        if ($ExpectException) {
            Write-PurviewError "Operation failed: $OperationName" -ErrorRecord $_
        }
    }
    
    return $result
}
