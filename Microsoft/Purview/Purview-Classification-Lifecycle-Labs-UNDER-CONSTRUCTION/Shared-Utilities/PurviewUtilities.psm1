# =============================================================================
# PurviewUtilities.psm1
# Main PowerShell module for Microsoft Purview Classification Lifecycle Labs
# =============================================================================
#
# This module provides reusable utilities for connection management, error
# handling, logging, validation, and retry logic across all lab scripts.
#
# Version: 1.0.0
# Author: Marcus Jacobson
# Created: 2025-11-11
# =============================================================================

# Import all function files
$FunctionFiles = Get-ChildItem -Path "$PSScriptRoot\Functions" -Filter "*.ps1" -ErrorAction SilentlyContinue

foreach ($File in $FunctionFiles) {
    try {
        . $File.FullName
        Write-Verbose "Imported function file: $($File.Name)"
    } catch {
        Write-Error "Failed to import function file $($File.Name): $_"
    }
}

# Export all functions
$ExportedFunctions = @(
    # Connection Management
    'Connect-PurviewServices',
    'Disconnect-PurviewServices',
    'Test-PurviewConnection',
    'Get-ServiceConnectionStatus',
    
    # Error Handling
    'Invoke-WithErrorHandling',
    'Write-PurviewError',
    'Get-DetailedErrorInfo',
    'Test-PurviewOperation',
    
    # Logging Utilities
    'Write-PurviewLog',
    'Initialize-PurviewLog',
    'Write-ProgressStatus',
    'Write-SectionHeader',
    
    # Validation Helpers
    'Test-PurviewPrerequisites',
    'Test-ModuleVersion',
    'Test-ServicePrincipal',
    'Confirm-PurviewOperation',
    
    # Retry Logic
    'Invoke-WithRetry',
    'Wait-ForRateLimit',
    'Test-ShouldRetry'
)

Export-ModuleMember -Function $ExportedFunctions

# Module variables
$Script:LogPath = $null
$Script:LogInitialized = $false
$Script:ConnectedServices = @{}

# Display import message
Write-Verbose "PurviewUtilities module loaded successfully"
Write-Verbose "Available functions: $($ExportedFunctions.Count)"
