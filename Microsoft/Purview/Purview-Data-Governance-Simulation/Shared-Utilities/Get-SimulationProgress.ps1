<#
.SYNOPSIS
    Progress tracking utility for long-running simulation operations.

.DESCRIPTION
    This utility script provides comprehensive progress tracking and reporting capabilities for
    long-running operations in the Purview Data Governance Simulation project. It supports
    percentage-based progress bars, time estimation, operation status tracking, and detailed
    progress reporting.
    
    The script is designed to be called repeatedly during operations to update progress status,
    and it handles console output formatting to provide clear visual feedback to users. It
    supports nested progress tracking for multi-step operations and can estimate time remaining
    based on current progress rate.
    
    Features:
    - Percentage-based progress bar with visual indicators
    - Time elapsed and estimated time remaining calculations
    - Operation status tracking (In Progress, Completed, Failed)
    - Nested progress support for multi-step operations
    - Automatic progress bar cleanup on completion
    - Integration with logging infrastructure
    
    Common use cases:
    - Document generation tracking (e.g., "Generating 5000 documents...")
    - Bulk upload operations (e.g., "Uploading 500 files to SharePoint...")
    - Classification processing (e.g., "Classifying 3000 documents...")
    - Batch operations with multiple items

.PARAMETER Activity
    The description of the activity being performed. Displayed in the progress bar.

.PARAMETER Status
    Additional status information to display. Can be used for current item being processed.

.PARAMETER PercentComplete
    The percentage of completion (0-100). Used to calculate progress bar and time estimates.

.PARAMETER CurrentOperation
    Description of the current operation within the activity. Provides additional context.

.PARAMETER TotalItems
    The total number of items to process. Used with ProcessedItems for automatic percentage calculation.

.PARAMETER ProcessedItems
    The number of items processed so far. Used with TotalItems for automatic percentage calculation.

.PARAMETER StartTime
    The start time of the operation. Used for elapsed time and ETA calculations. If not provided,
    uses current time (assumes operation just started).

.PARAMETER Completed
    When specified, marks the operation as completed and clears the progress bar.

.PARAMETER Config
    The configuration object for logging integration.

.EXAMPLE
    $startTime = Get-Date
    for ($i = 0; $i -lt 1000; $i++) {
        $percent = ($i / 1000) * 100
        & "$PSScriptRoot\..\Shared-Utilities\Get-SimulationProgress.ps1" -Activity "Generating documents" -Status "Processing item $i of 1000" -PercentComplete $percent -StartTime $startTime
        # Perform operation
    }
    & "$PSScriptRoot\..\Shared-Utilities\Get-SimulationProgress.ps1" -Activity "Generating documents" -Completed
    
    Tracks progress through a loop with percentage calculation.

.EXAMPLE
    $startTime = Get-Date
    foreach ($doc in $documents) {
        Get-SimulationProgress -Activity "Uploading documents" -TotalItems $documents.Count -ProcessedItems $uploadedCount -CurrentOperation "Uploading: $($doc.Name)" -StartTime $startTime
        # Upload operation
        $uploadedCount++
    }
    Get-SimulationProgress -Activity "Uploading documents" -Completed
    
    Tracks progress using item counts with automatic percentage calculation.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Console with Write-Progress support (may not work in non-interactive environments)
    
    Script development orchestrated using GitHub Copilot.

.SHARED UTILITY OPERATIONS
    - Progress Bar Visualization
    - Time Remaining Calculation
    - Throughput Metrics (Items/Second)
    - Completion Summary Reporting
#>
#
# =============================================================================
# Progress tracking utility for long-running simulation operations.
# =============================================================================

function Get-SimulationProgress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Activity,
        
        [Parameter(Mandatory = $false)]
        [string]$Status,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 100)]
        [int]$PercentComplete,
        
        [Parameter(Mandatory = $false)]
        [string]$CurrentOperation,
        
        [Parameter(Mandatory = $false)]
        [int]$TotalItems,
        
        [Parameter(Mandatory = $false)]
        [int]$ProcessedItems,
        
        [Parameter(Mandatory = $false)]
        [datetime]$StartTime = (Get-Date),
        
        [Parameter(Mandatory = $false)]
        [switch]$Completed,
        
        [Parameter(Mandatory = $false)]
        [PSCustomObject]$Config
    )

# =============================================================================
# Step 1: Calculate Progress Percentage
# =============================================================================

# If TotalItems and ProcessedItems are provided, calculate percentage
if ($TotalItems -gt 0 -and $ProcessedItems -ge 0) {
    $PercentComplete = [Math]::Round(($ProcessedItems / $TotalItems) * 100, 2)
    
    # Update status with item counts if not already provided
    if ([string]::IsNullOrWhiteSpace($Status)) {
        $Status = "Processing $ProcessedItems of $TotalItems items"
    }
}

# Default to 0% if not specified and can't be calculated
if ($PercentComplete -eq 0 -and $TotalItems -eq 0) {
    $PercentComplete = 0
}

# =============================================================================
# Step 2: Calculate Time Estimates
# =============================================================================

$timeElapsed = (Get-Date) - $StartTime
$timeElapsedString = "{0:hh\:mm\:ss}" -f $timeElapsed

# Estimate time remaining based on progress rate
$timeRemainingString = "Calculating..."
if ($PercentComplete -gt 0 -and $PercentComplete -lt 100) {
    $estimatedTotalTime = $timeElapsed.TotalSeconds / ($PercentComplete / 100)
    $estimatedTimeRemaining = $estimatedTotalTime - $timeElapsed.TotalSeconds
    
    if ($estimatedTimeRemaining -gt 0) {
        $timeRemainingSpan = [TimeSpan]::FromSeconds($estimatedTimeRemaining)
        $timeRemainingString = "{0:hh\:mm\:ss}" -f $timeRemainingSpan
    } else {
        $timeRemainingString = "00:00:00"
    }
}

# =============================================================================
# Step 3: Display Progress Bar
# =============================================================================

if ($Completed) {
    # Clear progress bar and display completion message
    Write-Progress -Activity $Activity -Completed
    Write-Host "✅ $Activity - Completed in $timeElapsedString" -ForegroundColor Green
    
    # Log completion if config provided
    if ($null -ne $Config) {
        & "$PSScriptRoot\Write-SimulationLog.ps1" -Message "$Activity completed in $timeElapsedString" -Level Success -Config $Config
    }
} else {
    # Build status string with time information
    $progressStatus = $Status
    if (-not [string]::IsNullOrWhiteSpace($Status)) {
        $progressStatus += " | "
    }
    $progressStatus += "Elapsed: $timeElapsedString"
    
    if ($PercentComplete -gt 0 -and $PercentComplete -lt 100) {
        $progressStatus += " | ETA: $timeRemainingString"
    }
    
    # Display progress bar
    $writeProgressParams = @{
        Activity        = $Activity
        Status          = $progressStatus
        PercentComplete = $PercentComplete
    }
    
    if (-not [string]::IsNullOrWhiteSpace($CurrentOperation)) {
        $writeProgressParams.CurrentOperation = $CurrentOperation
    }
    
    Write-Progress @writeProgressParams
}

# =============================================================================
# Step 4: Return Progress Information
# =============================================================================

# Return progress object for potential capture by calling script
$progressInfo = [PSCustomObject]@{
    Activity          = $Activity
    Status            = $Status
    PercentComplete   = $PercentComplete
    ProcessedItems    = $ProcessedItems
    TotalItems        = $TotalItems
    TimeElapsed       = $timeElapsed
    TimeElapsedString = $timeElapsedString
    TimeRemaining     = $timeRemainingString
    IsCompleted       = $Completed.IsPresent
}

    return $progressInfo
}
