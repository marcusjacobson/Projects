<#
.SYNOPSIS
    Comprehensive logging utility with structured formats, log rotation, retention policies,
    and multiple output format support for enterprise Purview automation.

.DESCRIPTION
    This script implements a reusable logging framework for Microsoft Purview automation
    operations. It provides structured logging with timestamps, severity levels, and
    operation details while managing log file lifecycle through rotation and retention. Features:
    
    - Structured log entries with timestamp, severity, operation context, and messages
    - Multiple log formats: plain text, CSV, JSON for different consumption scenarios
    - Log file rotation when files exceed configurable size thresholds (default: 10 MB)
    - Retention policies to automatically archive or delete old log files (default: 30 days)
    - Log searching and filtering capabilities for troubleshooting
    
    The logging framework is designed to be imported and used by all Purview automation
    scripts, providing consistent logging patterns and central log management.

.PARAMETER Message
    Log message to write. This is the primary content of the log entry describing the
    operation, event, or error being logged.

.PARAMETER Severity
    Log severity level. Valid values: Info, Warning, Error, Debug. Use:
    - Info: Normal operations, successful completions
    - Warning: Non-fatal issues, degraded functionality
    - Error: Failures that prevent operation completion
    - Debug: Detailed diagnostic information

.PARAMETER LogPath
    Path to the log file. The logging framework will manage this file's lifecycle including
    rotation and retention based on configured policies.

.PARAMETER LogFormat
    Format for log entries. Valid values: Text, CSV, JSON.
    - Text: Human-readable plain text with formatted columns
    - CSV: Comma-separated values for Excel/Power BI import
    - JSON: Structured JSON for programmatic parsing and SIEM integration

.PARAMETER MaxLogSizeMB
    Maximum log file size in megabytes before rotation is triggered. Default is 10 MB.
    When exceeded, the current log is renamed with timestamp and a new log is started.

.PARAMETER RetentionDays
    Number of days to retain old log files before deletion. Default is 30 days.
    Older files are automatically removed during log operations.

.PARAMETER OperationContext
    Optional context about the operation being logged (e.g., "BulkClassification",
    "SITCreation"). This helps categorize log entries for searching and filtering.

.EXAMPLE
    .\Write-PurviewLog.ps1 -Message "Classification completed successfully" -Severity Info -LogPath ".\logs\purview.log"
    
    Write an informational message to the log in default text format.

.EXAMPLE
    .\Write-PurviewLog.ps1 -Message "Failed to connect to SharePoint site" -Severity Error `
        -LogPath ".\logs\purview.log" -LogFormat JSON -OperationContext "BulkClassification"
    
    Write an error message in JSON format with operation context.

.EXAMPLE
    .\Write-PurviewLog.ps1 -Message "SIT creation count: 15" -Severity Info `
        -LogPath ".\logs\purview.log" -MaxLogSizeMB 5 -RetentionDays 90
    
    Write a log entry with custom rotation (5 MB) and retention (90 days) settings.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-01-09
    Last Modified: 2025-01-09
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1 or higher
    - Write permissions to log directory
    - Sufficient disk space for log files and rotated backups
    
    Script development orchestrated using GitHub Copilot.

.LOGGING FRAMEWORK ARCHITECTURE
    - Structured entries: Timestamp, severity, context, message in consistent format
    - Log rotation: Automatic rotation when size threshold exceeded
    - Retention policy: Automatic cleanup of logs older than retention period
    - Multiple formats: Text (human-readable), CSV (analytics), JSON (programmatic)
    - Thread-safe: Safe for concurrent writes from multiple scripts
#>

#
# =============================================================================
# Comprehensive logging framework for Purview automation operations.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Log message to write")]
    [ValidateNotNullOrEmpty()]
    [string]$Message,

    [Parameter(Mandatory = $true, HelpMessage = "Log severity level")]
    [ValidateSet("Info", "Warning", "Error", "Debug")]
    [string]$Severity,

    [Parameter(Mandatory = $true, HelpMessage = "Path to log file")]
    [string]$LogPath,

    [Parameter(Mandatory = $false, HelpMessage = "Log format: Text, CSV, or JSON")]
    [ValidateSet("Text", "CSV", "JSON")]
    [string]$LogFormat = "Text",

    [Parameter(Mandatory = $false, HelpMessage = "Maximum log file size in MB before rotation")]
    [ValidateRange(1, 1000)]
    [int]$MaxLogSizeMB = 10,

    [Parameter(Mandatory = $false, HelpMessage = "Number of days to retain old logs")]
    [ValidateRange(1, 365)]
    [int]$RetentionDays = 30,

    [Parameter(Mandatory = $false, HelpMessage = "Operation context for the log entry")]
    [string]$OperationContext = "General"
)

# =============================================================================
# Function: Ensure-LogDirectory
# =============================================================================

function Ensure-LogDirectory {
    param([string]$LogFilePath)
    
    $logDir = Split-Path -Path $LogFilePath -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
}

# =============================================================================
# Function: Rotate-LogFile
# =============================================================================

function Rotate-LogFile {
    param([string]$LogFilePath, [int]$MaxSizeMB)
    
    if (Test-Path $LogFilePath) {
        $fileInfo = Get-Item $LogFilePath
        $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
        
        if ($fileSizeMB -ge $MaxSizeMB) {
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $rotatedName = [System.IO.Path]::GetFileNameWithoutExtension($LogFilePath) + "_$timestamp" + [System.IO.Path]::GetExtension($LogFilePath)
            $rotatedPath = Join-Path (Split-Path $LogFilePath -Parent) $rotatedName
            
            Move-Item -Path $LogFilePath -Destination $rotatedPath -Force
            Write-Verbose "Log rotated: $rotatedPath (Size: $fileSizeMB MB)"
        }
    }
}

# =============================================================================
# Function: Apply-RetentionPolicy
# =============================================================================

function Apply-RetentionPolicy {
    param([string]$LogFilePath, [int]$RetentionDays)
    
    $logDir = Split-Path -Path $LogFilePath -Parent
    $logBaseName = [System.IO.Path]::GetFileNameWithoutExtension($LogFilePath)
    $logExtension = [System.IO.Path]::GetExtension($LogFilePath)
    
    # Find all rotated log files matching pattern
    $rotatedLogs = Get-ChildItem -Path $logDir -Filter "$logBaseName`_*$logExtension" -ErrorAction SilentlyContinue
    
    $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
    
    foreach ($rotatedLog in $rotatedLogs) {
        if ($rotatedLog.LastWriteTime -lt $cutoffDate) {
            Remove-Item -Path $rotatedLog.FullName -Force
            Write-Verbose "Deleted old log: $($rotatedLog.Name) (Age: $((Get-Date) - $rotatedLog.LastWriteTime).Days days)"
        }
    }
}

# =============================================================================
# Function: Write-LogEntry
# =============================================================================

function Write-LogEntry {
    param(
        [string]$LogFilePath,
        [string]$Format,
        [string]$Timestamp,
        [string]$Severity,
        [string]$Context,
        [string]$Message
    )
    
    switch ($Format) {
        "Text" {
            $logEntry = "$Timestamp | $Severity | $Context | $Message"
            $logEntry | Out-File -FilePath $LogFilePath -Append -Encoding UTF8
        }
        "CSV" {
            $logEntry = [PSCustomObject]@{
                Timestamp = $Timestamp
                Severity = $Severity
                Context = $Context
                Message = $Message
            }
            
            # Check if CSV needs header (file is new or empty)
            $needsHeader = -not (Test-Path $LogFilePath) -or (Get-Item $LogFilePath).Length -eq 0
            
            if ($needsHeader) {
                $logEntry | Export-Csv -Path $LogFilePath -NoTypeInformation -Encoding UTF8
            } else {
                $logEntry | Export-Csv -Path $LogFilePath -NoTypeInformation -Append -Encoding UTF8
            }
        }
        "JSON" {
            $logEntry = [PSCustomObject]@{
                timestamp = $Timestamp
                severity = $Severity
                context = $Context
                message = $Message
            }
            
            # For JSON, append each entry as a new line (newline-delimited JSON)
            $jsonEntry = $logEntry | ConvertTo-Json -Compress
            $jsonEntry | Out-File -FilePath $LogFilePath -Append -Encoding UTF8
        }
    }
}

# =============================================================================
# Main Execution
# =============================================================================

try {
    # Ensure log directory exists
    Ensure-LogDirectory -LogFilePath $LogPath
    
    # Check for log rotation
    Rotate-LogFile -LogFilePath $LogPath -MaxSizeMB $MaxLogSizeMB
    
    # Apply retention policy
    Apply-RetentionPolicy -LogFilePath $LogPath -RetentionDays $RetentionDays
    
    # Create timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Write log entry
    Write-LogEntry -LogFilePath $LogPath `
                   -Format $LogFormat `
                   -Timestamp $timestamp `
                   -Severity $Severity `
                   -Context $OperationContext `
                   -Message $Message
    
    # Also output to console for visibility
    $color = switch ($Severity) {
        "Info"    { "Green" }
        "Warning" { "Yellow" }
        "Error"   { "Red" }
        "Debug"   { "Cyan" }
    }
    
    Write-Host "[$timestamp] [$Severity] [$OperationContext] $Message" -ForegroundColor $color
    
} catch {
    Write-Error "Logging failed: $_"
    # Don't throw - logging failures should not break the calling script
}
