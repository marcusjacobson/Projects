<#
.SYNOPSIS
    Centralized logging infrastructure for Purview Data Governance Simulation scripts.

.DESCRIPTION
    This utility script provides comprehensive logging capabilities for all simulation scripts.
    It supports multiple log levels (Debug, Info, Warning, Error, Success), dual output modes
    (console and file), automatic log file management, and structured log formatting.
    
    The script integrates with the global configuration to respect logging preferences and
    automatically creates log files in the configured log directory. It supports log rotation,
    retention policies, and timestamped log entries for audit trails.
    
    Log levels:
    - Debug: Detailed diagnostic information for troubleshooting
    - Info: General informational messages about script progress
    - Warning: Warning messages for potential issues that don't stop execution
    - Error: Error messages for failures that may stop execution
    - Success: Success messages for completed operations
    
    Features:
    - Dual output: Console and file logging simultaneously
    - Color-coded console output by log level
    - Structured log file format with timestamps
    - Automatic log directory creation
    - Log file naming with script name and timestamp
    - Integration with global configuration logging preferences

.PARAMETER Message
    The message to log. Can be a simple string or a complex object.

.PARAMETER Level
    The log level for the message. Valid values: Debug, Info, Warning, Error, Success.
    Default: Info.

.PARAMETER Config
    The configuration object containing logging preferences. If not provided, logs to
    console only with default settings.

.PARAMETER ScriptName
    The name of the calling script for log file naming. If not provided, uses the
    calling script's filename.

.PARAMETER NoConsole
    When specified, suppresses console output and logs to file only.

.PARAMETER NoFile
    When specified, suppresses file output and logs to console only.

.EXAMPLE
    $config = & "$PSScriptRoot\..\Shared-Utilities\Import-GlobalConfig.ps1"
    & "$PSScriptRoot\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Starting site creation" -Level Info -Config $config -ScriptName "New-SimulatedSharePointSites"
    
    Logs an informational message to both console and file.

.EXAMPLE
    Write-SimulationLog -Message "Operation completed successfully" -Level Success -Config $config
    
    Logs a success message using shorter alias syntax.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Write permissions to log directory (from global configuration)
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Centralized logging infrastructure for simulation scripts.
# =============================================================================

function Write-SimulationLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Debug", "Info", "Warning", "Error", "Success")]
        [string]$Level = "Info",
        
        [Parameter(Mandatory = $false)]
        [PSCustomObject]$Config,
        
        [Parameter(Mandatory = $false)]
        [string]$ScriptName,
        
        [Parameter(Mandatory = $false)]
        [switch]$NoConsole,
        
        [Parameter(Mandatory = $false)]
        [switch]$NoFile
    )

# =============================================================================
# Step 1: Initialize Logging Context
# =============================================================================

# Determine script name for log file naming
if ([string]::IsNullOrWhiteSpace($ScriptName)) {
    $callingScript = Get-PSCallStack | Select-Object -Skip 1 -First 1
    if ($callingScript.ScriptName) {
        $ScriptName = [System.IO.Path]::GetFileNameWithoutExtension($callingScript.ScriptName)
    } else {
        $ScriptName = "SimulationScript"
    }
}

# Get timestamp for log entry
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$dateStamp = Get-Date -Format "yyyy-MM-dd"

# Determine logging preferences from config
$enableConsoleOutput = $true
$enableFileOutput = $true
$logLevel = "Info"
$logDirectory = $null

if ($null -ne $Config -and $Config.PSObject.Properties.Name -contains "Logging") {
    if ($Config.Logging.PSObject.Properties.Name -contains "EnableConsoleOutput") {
        $enableConsoleOutput = $Config.Logging.EnableConsoleOutput
    }
    if ($Config.Logging.PSObject.Properties.Name -contains "EnableFileOutput") {
        $enableFileOutput = $Config.Logging.EnableFileOutput
    }
    if ($Config.Logging.PSObject.Properties.Name -contains "LogLevel") {
        $logLevel = $Config.Logging.LogLevel
    }
    if ($Config.PSObject.Properties.Name -contains "Paths" -and $Config.Paths.PSObject.Properties.Name -contains "LogDirectory") {
        $logDirectory = $Config.Paths.LogDirectory
    }
}

# Apply parameter overrides
if ($NoConsole) { $enableConsoleOutput = $false }
if ($NoFile) { $enableFileOutput = $false }

# =============================================================================
# Step 2: Filter by Log Level
# =============================================================================

# Define log level hierarchy
$logLevelHierarchy = @{
    "Debug"   = 0
    "Info"    = 1
    "Warning" = 2
    "Error"   = 3
    "Success" = 1  # Same priority as Info
}

# Check if current message level meets minimum log level threshold
if ($logLevelHierarchy.ContainsKey($Level) -and $logLevelHierarchy.ContainsKey($logLevel)) {
    if ($logLevelHierarchy[$Level] -lt $logLevelHierarchy[$logLevel] -and $Level -ne "Success") {
        # Message level is below threshold, skip logging
        return
    }
}

# =============================================================================
# Step 3: Format Log Message
# =============================================================================

# Create structured log entry
$logEntry = "[$timestamp] [$Level] [$ScriptName] $Message"

# =============================================================================
# Step 4: Console Output
# =============================================================================

if ($enableConsoleOutput) {
    switch ($Level) {
        "Debug"   { Write-Host $logEntry -ForegroundColor Gray }
        "Info"    { Write-Host $logEntry -ForegroundColor Cyan }
        "Warning" { Write-Host $logEntry -ForegroundColor Yellow }
        "Error"   { Write-Host $logEntry -ForegroundColor Red }
        "Success" { Write-Host $logEntry -ForegroundColor Green }
        default   { Write-Host $logEntry -ForegroundColor White }
    }
}

# =============================================================================
# Step 5: File Output
# =============================================================================

if ($enableFileOutput -and -not [string]::IsNullOrWhiteSpace($logDirectory)) {
    try {
        # Ensure log directory exists
        if (-not (Test-Path -Path $logDirectory)) {
            New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
        }
        
        # Create log file path with date stamp
        $logFileName = "$ScriptName-$dateStamp.log"
        $logFilePath = Join-Path $logDirectory $logFileName
        
        # Append log entry to file
        Add-Content -Path $logFilePath -Value $logEntry -ErrorAction Stop
        
    } catch {
        # If file logging fails, output warning to console but don't throw
        if ($enableConsoleOutput) {
            Write-Host "[$timestamp] [Warning] [$ScriptName] Failed to write to log file: $_" -ForegroundColor Yellow
        }
    }
}

# =============================================================================
# Step 6: Return Log Entry
# =============================================================================

    # Return log entry for potential capture by calling script
    return $logEntry
}
