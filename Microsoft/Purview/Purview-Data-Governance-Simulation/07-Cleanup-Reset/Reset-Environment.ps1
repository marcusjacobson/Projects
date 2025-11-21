<#
.SYNOPSIS
    Resets the simulation environment to clean state.

.DESCRIPTION
    Performs comprehensive environment reset by removing all simulation resources,
    clearing reports directory (after archiving), resetting global configuration to
    defaults, and cleaning up temporary files and logs. Validates environment is clean
    and ready for future simulations.
    
    Use this script for complete cleanup after project completion or when starting fresh.

.PARAMETER Force
    Bypasses all confirmation prompts. Use with extreme caution.

.PARAMETER KeepReports
    Preserves Reports directory and its contents during reset.

.PARAMETER WhatIf
    Shows what would be reset without making any changes.

.EXAMPLE
    .\Reset-Environment.ps1 -WhatIf
    
    Previews reset actions without making changes.

.EXAMPLE
    .\Reset-Environment.ps1
    
    Resets environment with confirmation prompts.

.EXAMPLE
    .\Reset-Environment.ps1 -KeepReports
    
    Resets environment but preserves Reports directory.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Global Administrator or appropriate deletion permissions
    - PnP.PowerShell module for SharePoint operations
    - ExchangeOnlineManagement module for DLP operations
    - PowerShell 5.1+ or PowerShell 7+
    
    Script development orchestrated using GitHub Copilot.

.RESET OPERATIONS
    - Remove all simulation resources (Sites, DLP policies, Documents)
    - Clear Reports directory (unless -KeepReports specified)
    - Reset global configuration to template defaults
    - Clean up temporary files and logs
    - Validate clean environment state
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$KeepReports
)

# =============================================================================
# Action 1: Environment Setup and Safety Checks
# =============================================================================

Write-Host "🔄 Environment Reset" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan

# Load global configuration
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath
. (Join-Path $projectRoot "Shared-Utilities\Import-GlobalConfig.ps1")
$config = Import-GlobalConfig

# Load simulation logger
. (Join-Path $projectRoot "Shared-Utilities\Write-SimulationLog.ps1")

Write-SimulationLog -Message "Starting environment reset" -Level "Warning"

Write-Host "`n⚠️  CRITICAL WARNING: Complete Environment Reset" -ForegroundColor Red
Write-Host "================================================" -ForegroundColor Red
Write-Host "This will:" -ForegroundColor Yellow
Write-Host "  • Remove ALL simulation resources (Sites, DLP policies, Documents)" -ForegroundColor Yellow
Write-Host "  • Clear Reports directory $(if ($KeepReports) { '(PRESERVING)' } else { '(DELETING)' })" -ForegroundColor Yellow
Write-Host "  • Reset configuration to defaults" -ForegroundColor Yellow
Write-Host "  • Clean up temporary files and logs" -ForegroundColor Yellow
Write-Host "`nThis operation CANNOT be undone!" -ForegroundColor Red

if (-not $Force -and -not $WhatIfPreference) {
    Write-Host "`n📋 Pre-Reset Checklist:" -ForegroundColor Cyan
    Write-Host "   ☐ Have you run Export-FinalDocumentation.ps1?" -ForegroundColor Gray
    Write-Host "   ☐ Have you archived important reports?" -ForegroundColor Gray
    Write-Host "   ☐ Are you CERTAIN this is a simulation environment?" -ForegroundColor Gray
    Write-Host "   ☐ Have you reviewed what will be deleted?" -ForegroundColor Gray
    
    $confirmation = Read-Host "`nType 'RESET ENVIRONMENT' to confirm complete reset"
    if ($confirmation -ne "RESET ENVIRONMENT") {
        Write-Host "❌ Operation cancelled" -ForegroundColor Red
        Write-SimulationLog -Message "Environment reset cancelled by user" -Level "Info"
        exit 0
    }
}

$startTime = Get-Date

# =============================================================================
# Action 2: Remove All Simulation Resources
# =============================================================================

Write-Host "`n🗑️  Removing All Simulation Resources..." -ForegroundColor Cyan

$removalScript = Join-Path $scriptPath "Remove-SimulationResources.ps1"

if (Test-Path $removalScript) {
    Write-Host "   Executing comprehensive resource removal..." -ForegroundColor Gray
    
    $removalParams = @{
        ResourceType = "All"
    }
    
    if ($Force) {
        $removalParams.Force = $true
    }
    
    if ($WhatIfPreference) {
        $removalParams.WhatIf = $true
    }
    
    try {
        & $removalScript @removalParams
        Write-Host "   ✅ Simulation resources removed" -ForegroundColor Green
        Write-SimulationLog -Message "Simulation resources removed successfully" -Level "Info"
    } catch {
        Write-Host "   ⚠️  Error during resource removal: $_" -ForegroundColor Yellow
        Write-Host "   Continuing with environment reset..." -ForegroundColor Gray
        Write-SimulationLog -Message "Error during resource removal: $_" -Level "Warning"
    }
} else {
    Write-Host "   ⚠️  Remove-SimulationResources.ps1 not found" -ForegroundColor Yellow
    Write-Host "   Skipping resource removal..." -ForegroundColor Gray
}

# =============================================================================
# Action 3: Clear Reports Directory
# =============================================================================

if (-not $KeepReports) {
    Write-Host "`n📂 Clearing Reports Directory..." -ForegroundColor Cyan
    
    $reportsPath = Join-Path $projectRoot "Reports"
    
    if (Test-Path $reportsPath) {
        if ($PSCmdlet.ShouldProcess("Reports directory", "Clear all files")) {
            try {
                $reportFiles = Get-ChildItem -Path $reportsPath -Recurse -File
                
                if ($reportFiles.Count -eq 0) {
                    Write-Host "   ℹ️  Reports directory already empty" -ForegroundColor Gray
                } else {
                    Write-Host "   Found $($reportFiles.Count) files to remove" -ForegroundColor Gray
                    
                    $removedCount = 0
                    foreach ($file in $reportFiles) {
                        try {
                            Remove-Item $file.FullName -Force -ErrorAction Stop
                            $removedCount++
                        } catch {
                            Write-SimulationLog -Message "Failed to remove file $($file.Name): $_" -Level "Warning"
                        }
                    }
                    
                    Write-Host "   ✅ Removed $removedCount report files" -ForegroundColor Green
                    Write-SimulationLog -Message "Cleared Reports directory: $removedCount files removed" -Level "Info"
                }
                
                # Clean up empty subdirectories
                $reportDirs = Get-ChildItem -Path $reportsPath -Recurse -Directory | Sort-Object -Property FullName -Descending
                foreach ($dir in $reportDirs) {
                    if ((Get-ChildItem -Path $dir.FullName).Count -eq 0) {
                        Remove-Item $dir.FullName -Force -ErrorAction SilentlyContinue
                    }
                }
                
            } catch {
                Write-Host "   ⚠️  Error clearing Reports directory: $_" -ForegroundColor Yellow
                Write-SimulationLog -Message "Error clearing Reports directory: $_" -Level "Warning"
            }
        }
    } else {
        Write-Host "   ℹ️  Reports directory not found" -ForegroundColor Gray
    }
} else {
    Write-Host "`n📂 Preserving Reports Directory..." -ForegroundColor Cyan
    Write-Host "   ℹ️  Reports directory retained as requested" -ForegroundColor Gray
}

# =============================================================================
# Action 4: Reset Global Configuration
# =============================================================================

Write-Host "`n⚙️  Resetting Global Configuration..." -ForegroundColor Cyan

$configPath = Join-Path $projectRoot "global-config.json"
$templatePath = Join-Path $projectRoot "global-config.json.template"

if (Test-Path $configPath) {
    if ($PSCmdlet.ShouldProcess("Global configuration", "Reset to defaults")) {
        try {
            # Create backup of current configuration
            $backupPath = Join-Path $projectRoot "global-config.backup.json"
            Copy-Item $configPath $backupPath -Force -ErrorAction SilentlyContinue
            Write-Host "   ℹ️  Configuration backed up to: $backupPath" -ForegroundColor Gray
            
            # Restore from template if available
            if (Test-Path $templatePath) {
                Copy-Item $templatePath $configPath -Force
                Write-Host "   ✅ Configuration restored from template" -ForegroundColor Green
                Write-SimulationLog -Message "Global configuration restored from global-config.json.template" -Level "Info"
            } else {
                # Fallback: Reset configuration values (keep structure, reset runtime values)
                $config = Get-Content $configPath | ConvertFrom-Json
                
                # Reset simulation metadata
                if ($config.SimulationMetadata) {
                    $config.SimulationMetadata.LastRun = $null
                    $config.SimulationMetadata.DocumentsCreated = 0
                    $config.SimulationMetadata.IncidentsGenerated = 0
                }
                
                # Save reset configuration
                $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
                
                Write-Host "   ✅ Configuration reset to defaults" -ForegroundColor Green
                Write-Host "   ⚠️  Template file not found - used fallback reset method" -ForegroundColor Yellow
                Write-SimulationLog -Message "Global configuration reset (template not found, used fallback)" -Level "Warning"
            }
            
        } catch {
            Write-Host "   ⚠️  Error resetting configuration: $_" -ForegroundColor Yellow
            Write-SimulationLog -Message "Error resetting configuration: $_" -Level "Warning"
        }
    }
} else {
    Write-Host "   ℹ️  Global configuration not found" -ForegroundColor Gray
}

# =============================================================================
# Action 5: Clean Up Temporary Files and Logs
# =============================================================================

Write-Host "`n🧹 Cleaning Up Temporary Files..." -ForegroundColor Cyan

# Clean up log files older than 30 days
$logPath = Join-Path $projectRoot "Logs"
if (Test-Path $logPath) {
    if ($PSCmdlet.ShouldProcess("Old log files", "Remove files older than 30 days")) {
        try {
            $oldLogs = Get-ChildItem -Path $logPath -Recurse -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) }
            
            if ($oldLogs.Count -eq 0) {
                Write-Host "   ℹ️  No old log files to clean" -ForegroundColor Gray
            } else {
                $removedCount = 0
                foreach ($log in $oldLogs) {
                    try {
                        Remove-Item $log.FullName -Force -ErrorAction Stop
                        $removedCount++
                    } catch {
                        Write-SimulationLog -Message "Failed to remove log $($log.Name): $_" -Level "Warning"
                    }
                }
                
                Write-Host "   ✅ Removed $removedCount old log files" -ForegroundColor Green
            }
        } catch {
            Write-Host "   ⚠️  Error cleaning log files: $_" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "   ℹ️  Logs directory not found" -ForegroundColor Gray
}

# Clean up temporary PowerShell files
$tempFiles = @("*.tmp", "*.temp", "~*")
foreach ($pattern in $tempFiles) {
    if ($PSCmdlet.ShouldProcess("Temporary files ($pattern)", "Remove")) {
        $temps = Get-ChildItem -Path $projectRoot -Filter $pattern -Recurse -File -ErrorAction SilentlyContinue
        if ($temps.Count -gt 0) {
            $temps | Remove-Item -Force -ErrorAction SilentlyContinue
            Write-Host "   ✅ Removed $($temps.Count) temporary files ($pattern)" -ForegroundColor Gray
        }
    }
}

# =============================================================================
# Action 6: Validate Clean Environment
# =============================================================================

Write-Host "`n✔️  Validating Clean Environment..." -ForegroundColor Cyan

$validationResults = @{
    ReportsCleared = $true
    ConfigurationReset = $true
    TemporaryFilesCleared = $true
    EnvironmentClean = $true
}

# Validate Reports directory
if (-not $KeepReports) {
    $reportsPath = Join-Path $projectRoot "Reports"
    if (Test-Path $reportsPath) {
        $remainingFiles = Get-ChildItem -Path $reportsPath -Recurse -File
        if ($remainingFiles.Count -gt 0) {
            $validationResults.ReportsCleared = $false
            Write-Host "   ⚠️  Reports directory still contains $($remainingFiles.Count) files" -ForegroundColor Yellow
        } else {
            Write-Host "   ✅ Reports directory cleared" -ForegroundColor Green
        }
    }
}

# Validate configuration
$configPath = Join-Path $projectRoot "global-config.json"
if (Test-Path $configPath) {
    Write-Host "   ✅ Configuration file present" -ForegroundColor Green
} else {
    $validationResults.ConfigurationReset = $false
    Write-Host "   ⚠️  Configuration file missing" -ForegroundColor Yellow
}

# Validate no temporary files
$tempCount = (Get-ChildItem -Path $projectRoot -Include "*.tmp", "*.temp", "~*" -Recurse -File -ErrorAction SilentlyContinue).Count
if ($tempCount -eq 0) {
    Write-Host "   ✅ No temporary files remaining" -ForegroundColor Green
} else {
    $validationResults.TemporaryFilesCleared = $false
    Write-Host "   ⚠️  $tempCount temporary files still present" -ForegroundColor Yellow
}

$validationResults.EnvironmentClean = $validationResults.ReportsCleared -and $validationResults.ConfigurationReset -and $validationResults.TemporaryFilesCleared

# =============================================================================
# Action 7: Generate Reset Summary
# =============================================================================

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n✅ Environment Reset Complete" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

Write-Host "`n📊 Reset Summary:" -ForegroundColor Cyan
Write-Host "   Duration: $([math]::Round($duration.TotalMinutes, 1)) minutes" -ForegroundColor Gray
Write-Host "   Operation Mode: $(if ($WhatIfPreference) { 'Preview (WhatIf)' } elseif ($Force) { 'Force' } else { 'Interactive' })" -ForegroundColor Gray
Write-Host "   Reports: $(if ($KeepReports) { 'Preserved' } else { 'Cleared' })" -ForegroundColor Gray
Write-Host "   Environment Status: $(if ($validationResults.EnvironmentClean) { 'CLEAN' } else { 'NEEDS ATTENTION' })" -ForegroundColor $(if ($validationResults.EnvironmentClean) { "Green" } else { "Yellow" })

Write-Host "`n✔️  Validation Results:" -ForegroundColor Cyan
Write-Host "   Reports Cleared: $(if ($validationResults.ReportsCleared -or $KeepReports) { '✅' } else { '❌' })" -ForegroundColor Gray
Write-Host "   Configuration Reset: $(if ($validationResults.ConfigurationReset) { '✅' } else { '❌' })" -ForegroundColor Gray
Write-Host "   Temporary Files Cleared: $(if ($validationResults.TemporaryFilesCleared) { '✅' } else { '❌' })" -ForegroundColor Gray

Write-Host "`n💡 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Run Test-CleanupCompletion.ps1 to verify resource removal" -ForegroundColor Gray
Write-Host "   2. Review any validation warnings above" -ForegroundColor Gray
Write-Host "   3. Environment is ready for future simulations" -ForegroundColor Gray
Write-Host "   4. Refer to Lab 00 README to start new simulation" -ForegroundColor Gray

Write-SimulationLog -Message "Environment reset completed: $(if ($validationResults.EnvironmentClean) { 'Success' } else { 'Partial' })" -Level "Info"

if (-not $validationResults.EnvironmentClean) {
    exit 1
}

exit 0
