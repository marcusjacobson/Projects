# =============================================================================
# Logging-Utilities.ps1
# Logging and output functions for Purview operations
# =============================================================================

function Initialize-PurviewLog {
    <#
    .SYNOPSIS
        Initialize logging for Purview operations.
    
    .DESCRIPTION
        Sets up log file path and creates log directory if needed. Must be called
        before using Write-PurviewLog.
    
    .PARAMETER LogPath
        Full path to log file
    
    .PARAMETER CreateDirectory
        Create log directory if it doesn't exist (default: $true)
    
    .EXAMPLE
        Initialize-PurviewLog -LogPath ".\logs\script-execution.log"
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$LogPath,
        
        [Parameter(Mandatory = $false)]
        [switch]$CreateDirectory = $true
    )
    
    $Script:LogPath = $LogPath
    
    # Create directory if needed
    if ($CreateDirectory) {
        $logDir = Split-Path $LogPath -Parent
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }
    }
    
    $Script:LogInitialized = $true
    
    # Write initial log entry
    $separator = "=" * 80
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $Script:LogPath -Value "`n$separator"
    Add-Content -Path $Script:LogPath -Value "[$timestamp] Log session started"
    Add-Content -Path $Script:LogPath -Value "$separator"
}

function Write-PurviewLog {
    <#
    .SYNOPSIS
        Write message to Purview log file.
    
    .DESCRIPTION
        Writes timestamped messages to the log file initialized by Initialize-PurviewLog.
        Also displays messages to console with appropriate colors.
    
    .PARAMETER Message
        Message to log
    
    .PARAMETER Level
        Log level: "INFO", "WARNING", "ERROR", "DEBUG"
    
    .PARAMETER LogPath
        Override default log path (optional)
    
    .EXAMPLE
        Write-PurviewLog "Operation completed" -Level "INFO"
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "DEBUG")]
        [string]$Level = "INFO",
        
        [Parameter(Mandatory = $false)]
        [string]$LogPath
    )
    
    # Use provided path or script-level path
    $targetPath = if ($LogPath) { $LogPath } else { $Script:LogPath }
    
    if (-not $targetPath) {
        Write-Warning "Log path not initialized. Call Initialize-PurviewLog first."
        return
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    try {
        Add-Content -Path $targetPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Warning "Failed to write to log file: $_"
    }
    
    # Write to console with appropriate color
    $color = switch ($Level) {
        "INFO" { "Gray" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        "DEBUG" { "Cyan" }
        default { "Gray" }
    }
    
    Write-Host $logEntry -ForegroundColor $color
}

function Write-ProgressStatus {
    <#
    .SYNOPSIS
        Display progress information with consistent formatting.
    
    .DESCRIPTION
        Wrapper around Write-Progress with consistent formatting and optional logging.
    
    .PARAMETER Activity
        Description of the activity
    
    .PARAMETER Status
        Current status message
    
    .PARAMETER PercentComplete
        Percentage complete (0-100)
    
    .PARAMETER CurrentOperation
        Description of current operation
    
    .PARAMETER LogProgress
        Also log progress to file (default: $false)
    
    .EXAMPLE
        Write-ProgressStatus -Activity "Processing Sites" -Status "Site 5 of 10" -PercentComplete 50
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Activity,
        
        [Parameter(Mandatory = $false)]
        [string]$Status,
        
        [Parameter(Mandatory = $false)]
        [int]$PercentComplete,
        
        [Parameter(Mandatory = $false)]
        [string]$CurrentOperation,
        
        [Parameter(Mandatory = $false)]
        [switch]$LogProgress
    )
    
    $progressParams = @{
        Activity = $Activity
    }
    
    if ($Status) { $progressParams.Status = $Status }
    if ($PercentComplete) { $progressParams.PercentComplete = $PercentComplete }
    if ($CurrentOperation) { $progressParams.CurrentOperation = $CurrentOperation }
    
    Write-Progress @progressParams
    
    if ($LogProgress -and $Script:LogInitialized) {
        $logMessage = "$Activity - $Status"
        if ($PercentComplete) {
            $logMessage += " ($PercentComplete%)"
        }
        Write-PurviewLog $logMessage -Level "DEBUG"
    }
}

function Write-SectionHeader {
    <#
    .SYNOPSIS
        Display section header with consistent formatting.
    
    .DESCRIPTION
        Creates formatted section headers for console output and logging.
    
    .PARAMETER Text
        Header text
    
    .PARAMETER Color
        Console color (default: "Cyan")
    
    .PARAMETER Separator
        Separator character (default: "=")
    
    .PARAMETER Width
        Width of separator line (default: 80)
    
    .EXAMPLE
        Write-SectionHeader -Text "Phase 1: Environment Validation"
    
    .NOTES
        Author: Marcus Jacobson
        Version: 1.0.0
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Text,
        
        [Parameter(Mandatory = $false)]
        [string]$Color = "Cyan",
        
        [Parameter(Mandatory = $false)]
        [string]$Separator = "=",
        
        [Parameter(Mandatory = $false)]
        [int]$Width = 80
    )
    
    $separatorLine = $Separator * $Width
    
    Write-Host "`n$separatorLine" -ForegroundColor $Color
    Write-Host $Text -ForegroundColor $Color
    Write-Host "$separatorLine" -ForegroundColor $Color
    
    if ($Script:LogInitialized) {
        Write-PurviewLog "`n$separatorLine" -Level "INFO"
        Write-PurviewLog $Text -Level "INFO"
        Write-PurviewLog "$separatorLine" -Level "INFO"
    }
}
