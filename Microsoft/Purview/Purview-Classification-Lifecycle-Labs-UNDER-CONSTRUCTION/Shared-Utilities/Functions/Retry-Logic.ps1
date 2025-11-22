# =============================================================================
# Retry-Logic.ps1
# Retry and exponential backoff mechanisms
# =============================================================================

function Invoke-WithRetry {
    <#
    .SYNOPSIS
        Execute script block with exponential backoff retry logic.
    
    .DESCRIPTION
        Implements retry pattern with exponential backoff for handling transient
        failures, API throttling, and network issues.
    
    .PARAMETER ScriptBlock
        Script block to execute
    
    .PARAMETER MaxRetries
        Maximum number of retry attempts (default: 5)
    
    .PARAMETER InitialDelay
        Initial delay in seconds before first retry (default: 10)
    
    .PARAMETER BackoffMultiplier
        Multiplier for exponential backoff (default: 2)
    
    .PARAMETER MaxDelay
        Maximum delay between retries in seconds (default: 160)
    
    .PARAMETER RetryableErrors
        Array of error patterns that should trigger retry
    
    .EXAMPLE
        $result = Invoke-WithRetry -ScriptBlock { Get-PnPWeb } -MaxRetries 3
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxRetries = 5,
        
        [Parameter(Mandatory = $false)]
        [int]$InitialDelay = 10,
        
        [Parameter(Mandatory = $false)]
        [double]$BackoffMultiplier = 2.0,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxDelay = 160,
        
        [Parameter(Mandatory = $false)]
        [string[]]$RetryableErrors = @("429", "throttle", "rate.*limit", "timeout", "503", "502")
    )
    
    $attempt = 0
    $delay = $InitialDelay
    $lastError = $null
    
    while ($attempt -lt $MaxRetries) {
        $attempt++
        
        try {
            Write-PurviewLog "Attempt $attempt of $MaxRetries" -Level "DEBUG"
            $result = & $ScriptBlock
            
            if ($attempt -gt 1) {
                Write-PurviewLog "✅ Operation succeeded after $attempt attempts" -Level "INFO"
            }
            
            return $result
        } catch {
            $lastError = $_
            $shouldRetry = Test-ShouldRetry -ErrorRecord $_ -RetryableErrors $RetryableErrors
            
            if (-not $shouldRetry -or $attempt -ge $MaxRetries) {
                Write-PurviewError "Operation failed after $attempt attempts" -ErrorRecord $_
                throw
            }
            
            Write-PurviewLog "⚠️ Attempt $attempt failed, retrying in $delay seconds: $($_.Exception.Message)" -Level "WARNING"
            Wait-ForRateLimit -Seconds $delay
            
            # Calculate next delay with exponential backoff
            $delay = [Math]::Min($delay * $BackoffMultiplier, $MaxDelay)
        }
    }
    
    # Should never reach here, but just in case
    if ($lastError) {
        throw $lastError
    }
}

function Wait-ForRateLimit {
    <#
    .SYNOPSIS
        Intelligent delay for rate limiting scenarios.
    
    .DESCRIPTION
        Provides configurable delay with progress indicator for rate limit handling.
    
    .PARAMETER Seconds
        Number of seconds to wait
    
    .PARAMETER ShowProgress
        Display progress bar (default: $true)
    
    .EXAMPLE
        Wait-ForRateLimit -Seconds 30
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$Seconds,
        
        [Parameter(Mandatory = $false)]
        [bool]$ShowProgress = $true
    )
    
    if ($ShowProgress) {
        for ($i = 0; $i -lt $Seconds; $i++) {
            $percentComplete = [Math]::Round((($i + 1) / $Seconds) * 100)
            $remainingSeconds = $Seconds - $i - 1
            
            Write-Progress `
                -Activity "Waiting for rate limit" `
                -Status "Remaining: $remainingSeconds seconds" `
                -PercentComplete $percentComplete
            
            Start-Sleep -Seconds 1
        }
        Write-Progress -Activity "Waiting for rate limit" -Completed
    } else {
        Start-Sleep -Seconds $Seconds
    }
}

function Test-ShouldRetry {
    <#
    .SYNOPSIS
        Determine if operation should be retried based on error.
    
    .DESCRIPTION
        Analyzes error to determine if it's a transient error that warrants retry.
    
    .PARAMETER ErrorRecord
        PowerShell error record
    
    .PARAMETER RetryableErrors
        Array of error patterns that should trigger retry
    
    .EXAMPLE
        $shouldRetry = Test-ShouldRetry -ErrorRecord $_ -RetryableErrors @("429", "throttle")
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,
        
        [Parameter(Mandatory = $false)]
        [string[]]$RetryableErrors = @("429", "throttle", "rate.*limit", "timeout", "503", "502")
    )
    
    $errorMessage = $ErrorRecord.Exception.Message.ToLower()
    
    # Check if error matches any retryable pattern
    foreach ($pattern in $RetryableErrors) {
        if ($errorMessage -match $pattern.ToLower()) {
            Write-PurviewLog "Error matches retryable pattern: $pattern" -Level "DEBUG"
            return $true
        }
    }
    
    # Check for specific HTTP status codes
    if ($ErrorRecord.Exception -is [System.Net.WebException]) {
        $statusCode = [int]$ErrorRecord.Exception.Response.StatusCode
        if ($statusCode -in @(429, 502, 503, 504)) {
            Write-PurviewLog "HTTP status code $statusCode is retryable" -Level "DEBUG"
            return $true
        }
    }
    
    Write-PurviewLog "Error is not retryable" -Level "DEBUG"
    return $false
}
