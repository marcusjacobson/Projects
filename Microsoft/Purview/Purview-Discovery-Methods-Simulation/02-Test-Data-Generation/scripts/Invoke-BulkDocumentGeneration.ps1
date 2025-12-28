<#
.SYNOPSIS
    Orchestrates bulk generation of all simulated documents for the Purview Discovery Methods Simulation.

.DESCRIPTION
    This orchestrator script coordinates the execution of all document generation scripts in the
    proper sequence to create a comprehensive test data set for Microsoft Purview classification,
    DLP policy testing, and monitoring activities.
    
    Execution Phases:
    - Phase 1: HR document generation (SSN patterns)
    - Phase 2: Financial document generation (credit cards, bank accounts)
    - Phase 3: Identity document generation (passports, driver's licenses, ITIN)
    - Phase 4: Mixed-format document generation (multiple SIT types)
    
    The orchestrator provides consolidated progress tracking, error handling, and comprehensive
    reporting across all document generation activities.

.PARAMETER GlobalConfigPath
    Optional path to the global configuration file.

.PARAMETER SkipHR
    When specified, skips HR document generation phase.

.PARAMETER SkipFinancial
    When specified, skips financial document generation phase.

.PARAMETER SkipIdentity
    When specified, skips identity document generation phase.

.PARAMETER SkipMixed
    When specified, skips mixed-format document generation phase.

.PARAMETER Force
    When specified, forces regeneration of all documents even if they exist.

.EXAMPLE
    .\Invoke-BulkDocumentGeneration.ps1
    
    Executes all document generation phases in sequence.

.EXAMPLE
    .\Invoke-BulkDocumentGeneration.ps1 -SkipHR -SkipFinancial
    
    Executes only identity and mixed-format generation phases.

.EXAMPLE
    .\Invoke-BulkDocumentGeneration.ps1 -Force
    
    Regenerates all documents, replacing existing files.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - All individual document generation scripts present
    - Global configuration file properly configured
    - Sufficient disk space for configured ScaleLevel
    
    Script development orchestrated using GitHub Copilot.

.PHASES
    - Phase 1: HR Document Generation (New-SimulatedHRDocuments.ps1)
    - Phase 2: Financial Document Generation (New-SimulatedFinancialRecords.ps1)
    - Phase 3: Identity Document Generation (New-SimulatedPIIContent.ps1)
    - Phase 4: Mixed-Format Document Generation (New-MixedContentDocuments.ps1)
#>
#
# =============================================================================
# Orchestrates bulk generation of all simulated documents.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$GlobalConfigPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipHR,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipFinancial,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipIdentity,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipMixed,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# =============================================================================
# Initialize
# =============================================================================

Write-Host "🚀 Bulk Document Generation Orchestrator" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta

$overallStartTime = Get-Date
$scriptsPath = $PSScriptRoot
$phaseResults = @()

try {
    $config = & "$PSScriptRoot\..\..\Shared-Utilities\Import-GlobalConfig.ps1" -GlobalConfigPath $GlobalConfigPath
    Write-Host "   ✅ Configuration loaded successfully" -ForegroundColor Green
    Write-Host "   📊 Scale Level: $($config.Simulation.ScaleLevel)" -ForegroundColor Cyan
    Write-Host "   📊 Total Documents Target: $($config.DocumentGeneration.TotalDocuments)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "   ❌ Failed to load configuration: $_" -ForegroundColor Red
    exit 1
}

# Build parameter set for child scripts
$childParams = @{}
if ($GlobalConfigPath) { $childParams.GlobalConfigPath = $GlobalConfigPath }
if ($Force) { 
    $childParams.Force = $true 
} else {
    # Default to SkipExisting unless Force is specified
    $childParams.SkipExisting = $true
}

# =============================================================================
# Phase 1: HR Document Generation
# =============================================================================

if (-not $SkipHR) {
    Write-Host "📋 Phase 1: HR Document Generation" -ForegroundColor Magenta
    Write-Host "====================================" -ForegroundColor Magenta
    
    $phaseStartTime = Get-Date
    
    try {
        $scriptPath = Join-Path $scriptsPath "New-SimulatedHRDocuments.ps1"
        
        Write-Host "🚀 Calling script 'New-SimulatedHRDocuments.ps1'..." -ForegroundColor Blue
        & $scriptPath @childParams
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "✅ Script 'New-SimulatedHRDocuments.ps1' completed successfully" -ForegroundColor Blue
            Write-Host "✅ Phase 1 completed successfully" -ForegroundColor Green
            
            $phaseResults += @{
                Phase = "HR Documents"
                Status = "Success"
                Duration = ((Get-Date) - $phaseStartTime).ToString('hh\:mm\:ss')
            }
        } else {
            throw "Script exited with code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "❌ Phase 1 failed: $_" -ForegroundColor Red
        $phaseResults += @{
            Phase = "HR Documents"
            Status = "Failed"
            Error = $_.Exception.Message
            Duration = ((Get-Date) - $phaseStartTime).ToString('hh\:mm\:ss')
        }
    }
    
    Write-Host ""
} else {
    Write-Host "⏭️  Skipping Phase 1: HR Document Generation" -ForegroundColor Yellow
    Write-Host ""
}

# =============================================================================
# Phase 2: Financial Document Generation
# =============================================================================

if (-not $SkipFinancial) {
    Write-Host "📋 Phase 2: Financial Document Generation" -ForegroundColor Magenta
    Write-Host "==========================================" -ForegroundColor Magenta
    
    $phaseStartTime = Get-Date
    
    try {
        $scriptPath = Join-Path $scriptsPath "New-SimulatedFinancialRecords.ps1"
        
        Write-Host "🚀 Calling script 'New-SimulatedFinancialRecords.ps1'..." -ForegroundColor Blue
        & $scriptPath @childParams
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "✅ Script 'New-SimulatedFinancialRecords.ps1' completed successfully" -ForegroundColor Blue
            Write-Host "✅ Phase 2 completed successfully" -ForegroundColor Green
            
            $phaseResults += @{
                Phase = "Financial Documents"
                Status = "Success"
                Duration = ((Get-Date) - $phaseStartTime).ToString('hh\:mm\:ss')
            }
        } else {
            throw "Script exited with code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "❌ Phase 2 failed: $_" -ForegroundColor Red
        $phaseResults += @{
            Phase = "Financial Documents"
            Status = "Failed"
            Error = $_.Exception.Message
            Duration = ((Get-Date) - $phaseStartTime).ToString('hh\:mm\:ss')
        }
    }
    
    Write-Host ""
} else {
    Write-Host "⏭️  Skipping Phase 2: Financial Document Generation" -ForegroundColor Yellow
    Write-Host ""
}

# =============================================================================
# Phase 3: Identity Document Generation
# =============================================================================

if (-not $SkipIdentity) {
    Write-Host "📋 Phase 3: Identity Document Generation" -ForegroundColor Magenta
    Write-Host "=========================================" -ForegroundColor Magenta
    
    $phaseStartTime = Get-Date
    
    try {
        $scriptPath = Join-Path $scriptsPath "New-SimulatedPIIContent.ps1"
        
        Write-Host "🚀 Calling script 'New-SimulatedPIIContent.ps1'..." -ForegroundColor Blue
        & $scriptPath @childParams
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "✅ Script 'New-SimulatedPIIContent.ps1' completed successfully" -ForegroundColor Blue
            Write-Host "✅ Phase 3 completed successfully" -ForegroundColor Green
            
            $phaseResults += @{
                Phase = "Identity Documents"
                Status = "Success"
                Duration = ((Get-Date) - $phaseStartTime).ToString('hh\:mm\:ss')
            }
        } else {
            throw "Script exited with code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "❌ Phase 3 failed: $_" -ForegroundColor Red
        $phaseResults += @{
            Phase = "Identity Documents"
            Status = "Failed"
            Error = $_.Exception.Message
            Duration = ((Get-Date) - $phaseStartTime).ToString('hh\:mm\:ss')
        }
    }
    
    Write-Host ""
} else {
    Write-Host "⏭️  Skipping Phase 3: Identity Document Generation" -ForegroundColor Yellow
    Write-Host ""
}

# =============================================================================
# Phase 4: Mixed-Format Document Generation
# =============================================================================

if (-not $SkipMixed) {
    Write-Host "📋 Phase 4: Mixed-Format Document Generation" -ForegroundColor Magenta
    Write-Host "=============================================" -ForegroundColor Magenta
    
    $phaseStartTime = Get-Date
    
    try {
        $scriptPath = Join-Path $scriptsPath "New-MixedContentDocuments.ps1"
        
        Write-Host "🚀 Calling script 'New-MixedContentDocuments.ps1'..." -ForegroundColor Blue
        & $scriptPath @childParams
        
        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Host "✅ Script 'New-MixedContentDocuments.ps1' completed successfully" -ForegroundColor Blue
            Write-Host "✅ Phase 4 completed successfully" -ForegroundColor Green
            
            $phaseResults += @{
                Phase = "Mixed-Format Documents"
                Status = "Success"
                Duration = ((Get-Date) - $phaseStartTime).ToString('hh\:mm\:ss')
            }
        } else {
            throw "Script exited with code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "❌ Phase 4 failed: $_" -ForegroundColor Red
        $phaseResults += @{
            Phase = "Mixed-Format Documents"
            Status = "Failed"
            Error = $_.Exception.Message
            Duration = ((Get-Date) - $phaseStartTime).ToString('hh\:mm\:ss')
        }
    }
    
    Write-Host ""
} else {
    Write-Host "⏭️  Skipping Phase 4: Mixed-Format Document Generation" -ForegroundColor Yellow
    Write-Host ""
}

# =============================================================================
# Bulk Generation Summary
# =============================================================================

Write-Host "🎯 Bulk Document Generation Summary" -ForegroundColor Magenta
Write-Host "====================================" -ForegroundColor Magenta

$overallDuration = (Get-Date) - $overallStartTime
$successCount = ($phaseResults | Where-Object { $_.Status -eq "Success" }).Count
$failureCount = ($phaseResults | Where-Object { $_.Status -eq "Failed" }).Count

Write-Host "   📊 Phases Executed: $($phaseResults.Count)" -ForegroundColor Cyan
Write-Host "   📊 Successful Phases: $successCount" -ForegroundColor Cyan
Write-Host "   📊 Failed Phases: $failureCount" -ForegroundColor Cyan
Write-Host "   ⏱️  Total Duration: $($overallDuration.ToString('hh\:mm\:ss'))" -ForegroundColor Cyan

Write-Host ""
Write-Host "   📋 Phase Results:" -ForegroundColor Cyan

foreach ($result in $phaseResults) {
    if ($result.Status -eq "Success") {
        Write-Host "      ✅ $($result.Phase) - Completed in $($result.Duration)" -ForegroundColor Green
    } else {
        Write-Host "      ❌ $($result.Phase) - Failed: $($result.Error)" -ForegroundColor Red
    }
}

# Collect document counts
try {
    $hrCount = (Get-ChildItem -Path (Join-Path $config.Paths.GeneratedDocumentsPath "HR") -File -ErrorAction SilentlyContinue).Count
    $finCount = (Get-ChildItem -Path (Join-Path $config.Paths.GeneratedDocumentsPath "Finance") -File -ErrorAction SilentlyContinue).Count
    $idCount = (Get-ChildItem -Path (Join-Path $config.Paths.GeneratedDocumentsPath "Identity") -File -ErrorAction SilentlyContinue).Count
    $mixCount = (Get-ChildItem -Path (Join-Path $config.Paths.GeneratedDocumentsPath "Mixed") -File -ErrorAction SilentlyContinue).Count
    $totalGenerated = $hrCount + $finCount + $idCount + $mixCount
    
    Write-Host ""
    Write-Host "   📊 Document Generation Statistics:" -ForegroundColor Cyan
    Write-Host "      • HR Documents: $hrCount" -ForegroundColor Cyan
    Write-Host "      • Financial Documents: $finCount" -ForegroundColor Cyan
    Write-Host "      • Identity Documents: $idCount" -ForegroundColor Cyan
    Write-Host "      • Mixed-Format Documents: $mixCount" -ForegroundColor Cyan
    Write-Host "      • Total Documents: $totalGenerated" -ForegroundColor Cyan
} catch {
    Write-Host "   ⚠️  Could not retrieve document counts" -ForegroundColor Yellow
}

# Generate consolidated report
$consolidatedReport = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    ScaleLevel = $config.Simulation.ScaleLevel
    TargetDocuments = $config.DocumentGeneration.TotalDocuments
    PhasesExecuted = $phaseResults.Count
    SuccessfulPhases = $successCount
    FailedPhases = $failureCount
    TotalDuration = $overallDuration.ToString('hh\:mm\:ss')
    PhaseResults = $phaseResults
}

$reportPath = Join-Path $config.Paths.ReportsPath "bulk-document-generation-report-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').json"

try {
    $consolidatedReport | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportPath -Force -Encoding UTF8
    Write-Host ""
    Write-Host "   ✅ Consolidated report saved: $(Split-Path $reportPath -Leaf)" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Could not save consolidated report: $_" -ForegroundColor Yellow
}

# =============================================================================
# Next Steps Guidance
# =============================================================================

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan

if ($failureCount -eq 0) {
    Write-Host "   ✅ All document generation phases completed successfully" -ForegroundColor Green
    Write-Host "   1. Proceed to Lab 03 for document upload to SharePoint" -ForegroundColor Cyan
    Write-Host "   2. Review generated documents in: $($config.Paths.GeneratedDocumentsPath)" -ForegroundColor Cyan
    Write-Host "   3. Check generation reports in: $($config.Paths.ReportsPath)" -ForegroundColor Cyan
} else {
    Write-Host "   ⚠️  Some document generation phases failed" -ForegroundColor Yellow
    Write-Host "   1. Review errors above and in individual phase logs" -ForegroundColor Cyan
    Write-Host "   2. Retry failed phases individually" -ForegroundColor Cyan
    Write-Host "   3. Check disk space and permissions" -ForegroundColor Cyan
}

if ($failureCount -eq 0) {
    Write-Host ""
    Write-Host "✅ Bulk document generation completed successfully - all phases successful" -ForegroundColor Green
    & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Bulk document generation completed: All phases successful" -Level Success -Config $config -ScriptName "Invoke-BulkDocumentGeneration"
    exit 0
} else {
    Write-Host ""
    Write-Host "⚠️  Bulk document generation completed with failures - review above" -ForegroundColor Yellow
    exit 1
}
