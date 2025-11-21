<#
.SYNOPSIS
    Initializes simulation environment directories and logging infrastructure.

.DESCRIPTION
    This script creates the necessary directory structure for the Purview Data Governance
    Simulation project based on configuration in global-config.json. It initializes the
    logging infrastructure, validates write permissions, and prepares the environment for
    simulation execution.
    
    The script creates directories for:
    - Log files (operations and diagnostic logging)
    - Generated documents (test data storage)
    - Output files (reports and results)
    - Reports (classification and DLP metrics)
    - Temporary files (processing workspace)
    
    It validates that all directories are writable and initializes the logging system
    with appropriate configuration from the global config file.

.PARAMETER GlobalConfigPath
    Optional path to the global configuration file. If not specified, uses default location.

.PARAMETER Force
    When specified, recreates directories even if they already exist (clears contents).

.PARAMETER SkipLoggingTest
    When specified, skips the logging infrastructure test (useful for automation scenarios).

.EXAMPLE
    .\Initialize-SimulationEnvironment.ps1
    
    Creates directory structure and initializes logging with default configuration.

.EXAMPLE
    .\Initialize-SimulationEnvironment.ps1 -Force
    
    Recreates directory structure even if directories already exist.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-16
    Last Modified: 2025-11-16
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 5.1+ or PowerShell 7+
    - Write permissions to parent directories
    - Valid global-config.json configuration file
    
    Script development orchestrated using GitHub Copilot.
#>
#
# =============================================================================
# Initializes simulation directory structure and logging infrastructure.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$GlobalConfigPath,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipLoggingTest
)

# =============================================================================
# Step 1: Load Global Configuration
# =============================================================================

Write-Host "🔍 Step 1: Load Global Configuration" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

try {
    $config = & "$PSScriptRoot\..\..\Shared-Utilities\Import-GlobalConfig.ps1" -GlobalConfigPath $GlobalConfigPath
    Write-Host "   ✅ Configuration loaded successfully" -ForegroundColor Green
    Write-Host "   📋 Organization: $($config.Environment.OrganizationName)" -ForegroundColor Cyan
    Write-Host "   📋 Scale Level: $($config.Simulation.ScaleLevel)" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Failed to load global configuration: $_" -ForegroundColor Red
    throw "Configuration load failure. Ensure global-config.json exists and is valid."
}

# =============================================================================
# Step 2: Create Directory Structure
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 2: Create Directory Structure" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$directoriesToCreate = @(
    @{Name = "Log Directory"; Path = $config.Paths.LogDirectory; Description = "Operation and diagnostic logs"},
    @{Name = "Output Directory"; Path = $config.Paths.OutputDirectory; Description = "Script outputs and results"},
    @{Name = "Generated Documents"; Path = $config.Paths.GeneratedDocumentsPath; Description = "Test documents for upload"},
    @{Name = "Reports Directory"; Path = $config.Paths.ReportsPath; Description = "Classification and DLP reports"},
    @{Name = "Temp Directory"; Path = $config.Paths.TempPath; Description = "Temporary processing files"}
)

$createdDirectories = @()
$existingDirectories = @()

foreach ($dirInfo in $directoriesToCreate) {
    $dirPath = $dirInfo.Path
    
    if (Test-Path -Path $dirPath) {
        if ($Force) {
            Write-Host "   🔄 Recreating existing directory: $($dirInfo.Name)" -ForegroundColor Yellow
            Write-Host "      Path: $dirPath" -ForegroundColor Cyan
            
            try {
                Remove-Item -Path $dirPath -Recurse -Force -ErrorAction Stop
                New-Item -Path $dirPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
                $createdDirectories += $dirPath
                Write-Host "   ✅ Recreated: $($dirInfo.Name)" -ForegroundColor Green
            } catch {
                Write-Host "   ❌ Failed to recreate directory: $_" -ForegroundColor Red
                throw "Directory recreation failed: $dirPath"
            }
        } else {
            Write-Host "   ℹ️  Directory already exists: $($dirInfo.Name)" -ForegroundColor Cyan
            Write-Host "      Path: $dirPath" -ForegroundColor Cyan
            $existingDirectories += $dirPath
        }
    } else {
        Write-Host "   📋 Creating directory: $($dirInfo.Name)" -ForegroundColor Cyan
        Write-Host "      Path: $dirPath" -ForegroundColor Cyan
        Write-Host "      Purpose: $($dirInfo.Description)" -ForegroundColor Cyan
        
        try {
            New-Item -Path $dirPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
            $createdDirectories += $dirPath
            Write-Host "   ✅ Created: $($dirInfo.Name)" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ Failed to create directory: $_" -ForegroundColor Red
            throw "Directory creation failed: $dirPath"
        }
    }
}

Write-Host ""
Write-Host "   📊 Summary: Created $($createdDirectories.Count) directories, Found $($existingDirectories.Count) existing" -ForegroundColor Cyan

# =============================================================================
# Step 3: Validate Write Permissions
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 3: Validate Write Permissions" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$permissionErrors = @()

foreach ($dirInfo in $directoriesToCreate) {
    $testFilePath = Join-Path $dirInfo.Path ".permission_test_$(Get-Date -Format 'yyyyMMddHHmmss').tmp"
    
    try {
        # Attempt to create a test file
        "Write permission test" | Out-File -FilePath $testFilePath -Force -ErrorAction Stop
        
        # Attempt to read the test file
        $testContent = Get-Content -Path $testFilePath -ErrorAction Stop
        
        # Attempt to delete the test file
        Remove-Item -Path $testFilePath -Force -ErrorAction Stop
        
        Write-Host "   ✅ Write permissions validated: $($dirInfo.Name)" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Write permission test failed: $($dirInfo.Name)" -ForegroundColor Red
        Write-Host "      Error: $_" -ForegroundColor Red
        $permissionErrors += "$($dirInfo.Name): $_"
    }
}

if ($permissionErrors.Count -gt 0) {
    Write-Host ""
    Write-Host "   ❌ Write permission validation failed for directories:" -ForegroundColor Red
    foreach ($error in $permissionErrors) {
        Write-Host "      • $error" -ForegroundColor Red
    }
    throw "Write permissions insufficient for simulation directories"
}

# =============================================================================
# Step 4: Initialize Logging Infrastructure
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 4: Initialize Logging Infrastructure" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

Write-Host "   📋 Logging configuration:" -ForegroundColor Cyan
Write-Host "      Log Level: $($config.Logging.LogLevel)" -ForegroundColor Cyan
Write-Host "      Console Output: $($config.Logging.EnableConsoleOutput)" -ForegroundColor Cyan
Write-Host "      File Output: $($config.Logging.EnableFileOutput)" -ForegroundColor Cyan
Write-Host "      Retention: $($config.Logging.RetainLogDays) days" -ForegroundColor Cyan

if (-not $SkipLoggingTest) {
    Write-Host "   📋 Testing logging infrastructure..." -ForegroundColor Cyan
    
    try {
        # Test logging at different levels
        & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Logging infrastructure test - Info level" -Level Info -Config $config -ScriptName "Initialize-SimulationEnvironment"
        & "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Logging infrastructure test - Success level" -Level Success -Config $config -ScriptName "Initialize-SimulationEnvironment"
        
        Write-Host "   ✅ Logging infrastructure operational" -ForegroundColor Green
        
        # Check for log file creation
        $logFileName = "Initialize-SimulationEnvironment-$(Get-Date -Format 'yyyy-MM-dd').log"
        $logFilePath = Join-Path $config.Paths.LogDirectory $logFileName
        
        if (Test-Path -Path $logFilePath) {
            Write-Host "   ✅ Log file created: $logFileName" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Log file not found (may be expected with current configuration)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Logging infrastructure test failed: $_" -ForegroundColor Red
        Write-Host "   💡 Logging may still work - error could be configuration-related" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⏭️  Logging infrastructure test skipped (SkipLoggingTest parameter)" -ForegroundColor Yellow
}

# =============================================================================
# Step 5: Create Environment Information File
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 5: Create Environment Information File" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

$environmentInfo = @{
    InitializedAt       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Organization        = $config.Environment.OrganizationName
    TenantDomain        = $config.Environment.TenantDomain
    ScaleLevel          = $config.Simulation.ScaleLevel
    ProjectRoot         = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
    DirectoriesCreated  = $createdDirectories
    DirectoriesExisting = $existingDirectories
    PowerShellVersion   = $PSVersionTable.PSVersion.ToString()
    PowerShellEdition   = $PSVersionTable.PSEdition
}

$envInfoPath = Join-Path $config.Paths.OutputDirectory "environment-info.json"

try {
    $environmentInfo | ConvertTo-Json -Depth 5 | Out-File -FilePath $envInfoPath -Force -Encoding UTF8
    Write-Host "   ✅ Environment information saved: environment-info.json" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Could not save environment information: $_" -ForegroundColor Yellow
}

# =============================================================================
# Step 6: Initialization Summary
# =============================================================================

Write-Host ""
Write-Host "🔍 Step 6: Initialization Summary" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

Write-Host "   ✅ Directory structure initialized" -ForegroundColor Green
Write-Host "   ✅ Write permissions validated" -ForegroundColor Green
Write-Host "   ✅ Logging infrastructure configured" -ForegroundColor Green
Write-Host "   ✅ Environment ready for simulation execution" -ForegroundColor Green

Write-Host ""
Write-Host "📊 Environment Details:" -ForegroundColor Cyan
Write-Host "   Organization: $($config.Environment.OrganizationName)" -ForegroundColor Cyan
Write-Host "   Scale Level: $($config.Simulation.ScaleLevel)" -ForegroundColor Cyan
Write-Host "   SharePoint Sites: $($config.SharePointSites.Count)" -ForegroundColor Cyan
Write-Host "   Built-In SITs Enabled: $(($config.BuiltInSITs | Where-Object { $_.Enabled }).Count)" -ForegroundColor Cyan

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Review Lab 01 README.md for SharePoint site creation guidance" -ForegroundColor Cyan
Write-Host "   2. Run Lab 01 scripts to create simulated SharePoint sites" -ForegroundColor Cyan
Write-Host "   3. Proceed through labs sequentially for complete simulation" -ForegroundColor Cyan

Write-Host ""
Write-Host "✅ Simulation environment initialization completed successfully" -ForegroundColor Green

# Log initialization completion
& "$PSScriptRoot\..\..\Shared-Utilities\Write-SimulationLog.ps1" -Message "Simulation environment initialized successfully" -Level Success -Config $config -ScriptName "Initialize-SimulationEnvironment"

exit 0
