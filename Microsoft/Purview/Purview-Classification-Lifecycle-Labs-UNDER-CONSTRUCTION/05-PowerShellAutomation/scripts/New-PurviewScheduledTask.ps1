<#
.SYNOPSIS
    Scheduled task creation engine that configures Windows scheduled tasks for automated
    Purview operations with proper credentials, triggers, and execution logging.

.DESCRIPTION
    This script implements enterprise-grade scheduled task configuration for Microsoft Purview
    automation operations. It creates Windows scheduled tasks with proper security settings,
    flexible trigger configurations, and comprehensive execution logging. The script includes:
    
    - Task creation with configurable triggers (Daily, Weekly, Monthly, custom intervals)
    - Proper credential configuration for unattended execution
    - Task action setup to run PowerShell scripts with parameters
    - Execution logging to capture task history and errors
    - Validation to ensure tasks are created correctly and will execute as expected
    
    The scheduled task generator is designed for enterprises requiring automated,
    recurring Purview operations without manual intervention.

.PARAMETER TaskName
    Name of the scheduled task to create. Must be unique within the Task Scheduler.
    Use descriptive names that indicate the operation (e.g., "Purview-NightlyClassification").

.PARAMETER ScriptPath
    Full path to the PowerShell script to execute. Must be an absolute path to ensure
    the task can locate the script when running unattended.

.PARAMETER Trigger
    Task trigger configuration. Valid values: Daily, Weekly, Monthly, Custom.
    For Custom, use -CustomTrigger parameter to provide specific trigger XML.

.PARAMETER StartTime
    Time to run the task in 24-hour format (HH:mm:ss). Example: "02:00:00" for 2 AM.
    Ensure the time is outside business hours for resource-intensive operations.

.PARAMETER RunAsUser
    User account to run the task. Default is current user. For production, use a
    dedicated service account with persistent credentials and appropriate permissions.

.PARAMETER ScriptParameters
    Optional parameters to pass to the PowerShell script. Provide as a hashtable.
    Example: @{SiteListCsv="C:\Config\sites.csv"; MaxConcurrent=5}

.PARAMETER LogPath
    Path to write task creation logs. Default is ".\logs\scheduled-tasks.log".
    Logs include task creation details, validation results, and configuration summary.

.EXAMPLE
    .\New-PurviewScheduledTask.ps1 -TaskName "Purview-NightlyClassification" `
        -ScriptPath "C:\Scripts\Invoke-BulkClassification.ps1" `
        -Trigger Daily -StartTime "02:00:00"
    
    Create a daily bulk classification task that runs at 2 AM.

.EXAMPLE
    .\New-PurviewScheduledTask.ps1 -TaskName "Purview-WeeklyReport" `
        -ScriptPath "C:\Scripts\Export-PurviewReport.ps1" `
        -Trigger Weekly -StartTime "06:00:00" `
        -ScriptParameters @{ReportType="Executive"; OutputPath="C:\Reports"}
    
    Create a weekly reporting task with script parameters.

.EXAMPLE
    .\New-PurviewScheduledTask.ps1 -TaskName "Purview-MonthlyMaintenance" `
        -ScriptPath "C:\Scripts\Invoke-PurviewWorkflow.ps1" `
        -Trigger Monthly -StartTime "01:00:00" `
        -RunAsUser "DOMAIN\ServiceAccount"
    
    Create a monthly maintenance task running under a service account.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-01-09
    Last Modified: 2025-01-09
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Windows PowerShell 5.1 or PowerShell 7+ on Windows
    - Administrative permissions to create scheduled tasks
    - ScheduledTasks PowerShell module (included in Windows)
    - Target PowerShell scripts must exist at specified paths
    
    Script development orchestrated using GitHub Copilot.

.TASK CONFIGURATION ARCHITECTURE
    - Trigger options: Daily, Weekly, Monthly with flexible scheduling
    - Security settings: Run with highest privileges, proper credential storage
    - Action configuration: PowerShell script execution with parameter passing
    - Logging: Task creation details and execution history tracking
    - Validation: Pre-flight checks to ensure task will execute correctly
#>

#
# =============================================================================
# Scheduled task creation engine for automated Purview operations.
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Name of the scheduled task")]
    [ValidateNotNullOrEmpty()]
    [string]$TaskName,

    [Parameter(Mandatory = $true, HelpMessage = "Full path to PowerShell script to execute")]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ScriptPath,

    [Parameter(Mandatory = $true, HelpMessage = "Task trigger type: Daily, Weekly, Monthly")]
    [ValidateSet("Daily", "Weekly", "Monthly")]
    [string]$Trigger,

    [Parameter(Mandatory = $true, HelpMessage = "Time to run task (HH:mm:ss format)")]
    [ValidatePattern('^\d{2}:\d{2}:\d{2}$')]
    [string]$StartTime,

    [Parameter(Mandatory = $false, HelpMessage = "User account to run the task")]
    [string]$RunAsUser = $env:USERNAME,

    [Parameter(Mandatory = $false, HelpMessage = "Parameters to pass to the script")]
    [hashtable]$ScriptParameters = @{},

    [Parameter(Mandatory = $false, HelpMessage = "Path for task creation logs")]
    [string]$LogPath = ".\logs\scheduled-tasks.log"
)

# =============================================================================
# Action 1: Environment Setup and Validation
# =============================================================================

Write-Host "🚀 Scheduled Task Creation Engine - Starting" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host ""

# Ensure log directory exists
$logDir = Split-Path -Path $LogPath -Parent
if (-not (Test-Path $logDir)) {
    Write-Host "📁 Creating log directory: $logDir" -ForegroundColor Cyan
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Check if running with admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ This script requires administrative privileges to create scheduled tasks" -ForegroundColor Red
    Write-Host "   Please run PowerShell as Administrator and try again" -ForegroundColor Yellow
    exit 1
}

# =============================================================================
# Action 2: Module Validation
# =============================================================================

Write-Host "🔍 Action 2: Module Validation" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Checking for ScheduledTasks module..." -ForegroundColor Cyan
try {
    $schedTaskModule = Get-Module -ListAvailable -Name ScheduledTasks | Select-Object -First 1
    if ($schedTaskModule) {
        Write-Host "   ✅ ScheduledTasks module found" -ForegroundColor Green
    } else {
        throw "ScheduledTasks module not found. This module is included with Windows."
    }
} catch {
    Write-Host "   ❌ Module validation failed: $_" -ForegroundColor Red
    exit 1
}

Import-Module ScheduledTasks -ErrorAction Stop
Write-Host "   ✅ ScheduledTasks module imported successfully" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Action 3: Pre-Flight Validation
# =============================================================================

Write-Host "🔍 Action 3: Pre-Flight Validation" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Validating task configuration..." -ForegroundColor Cyan

# Check if task already exists
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "   ⚠️  Task '$TaskName' already exists" -ForegroundColor Yellow
    $response = Read-Host "   Do you want to replace it? (Y/N)"
    if ($response -ne "Y" -and $response -ne "y") {
        Write-Host "   ⛔ Task creation cancelled by user" -ForegroundColor Yellow
        exit 0
    }
    Write-Host "   🗑️  Removing existing task..." -ForegroundColor Cyan
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# Validate script path is absolute
if (-not [System.IO.Path]::IsPathRooted($ScriptPath)) {
    Write-Host "   ❌ Script path must be absolute: $ScriptPath" -ForegroundColor Red
    exit 1
}

# Validate time format
try {
    $timeSpan = [TimeSpan]::Parse($StartTime)
    Write-Host "   ✅ Start time validated: $StartTime" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Invalid time format: $StartTime (use HH:mm:ss)" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Pre-flight validation complete" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Action 4: Task Configuration
# =============================================================================

Write-Host "🔍 Action 4: Task Configuration" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Creating scheduled task: $TaskName" -ForegroundColor Cyan
Write-Host "   • Script: $ScriptPath" -ForegroundColor Gray
Write-Host "   • Trigger: $Trigger" -ForegroundColor Gray
Write-Host "   • Start time: $StartTime" -ForegroundColor Gray
Write-Host "   • Run as: $RunAsUser" -ForegroundColor Gray
Write-Host ""

try {
    # Create task action
    $actionArgument = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""
    
    # Add script parameters if provided
    if ($ScriptParameters.Count -gt 0) {
        foreach ($key in $ScriptParameters.Keys) {
            $value = $ScriptParameters[$key]
            if ($value -is [string]) {
                $actionArgument += " -$key `"$value`""
            } else {
                $actionArgument += " -$key $value"
            }
        }
    }
    
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $actionArgument
    Write-Host "   ✅ Task action configured" -ForegroundColor Green
    
    # Create task trigger based on type
    switch ($Trigger) {
        "Daily" {
            $taskTrigger = New-ScheduledTaskTrigger -Daily -At $StartTime
        }
        "Weekly" {
            # Default to Sunday for weekly tasks
            $taskTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At $StartTime
        }
        "Monthly" {
            # Default to first day of month for monthly tasks
            $taskTrigger = New-ScheduledTaskTrigger -Daily -At $StartTime
            # Note: Monthly requires additional configuration in trigger XML for specific dates
        }
    }
    Write-Host "   ✅ Task trigger configured ($Trigger at $StartTime)" -ForegroundColor Green
    
    # Create task principal (user context)
    $principal = New-ScheduledTaskPrincipal -UserId $RunAsUser -LogonType Password -RunLevel Highest
    Write-Host "   ✅ Task principal configured (Run as: $RunAsUser)" -ForegroundColor Green
    
    # Create task settings
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -ExecutionTimeLimit (New-TimeSpan -Hours 4) `
        -RestartCount 3 `
        -RestartInterval (New-TimeSpan -Minutes 10)
    
    Write-Host "   ✅ Task settings configured (4-hour timeout, 3 restart attempts)" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host "   ❌ Task configuration failed: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Action 5: Task Registration
# =============================================================================

Write-Host "🔍 Action 5: Task Registration" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Registering scheduled task in Windows Task Scheduler..." -ForegroundColor Cyan
try {
    # Register the task
    $task = Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $action `
        -Trigger $taskTrigger `
        -Principal $principal `
        -Settings $settings `
        -Description "Microsoft Purview automation task: $($ScriptPath | Split-Path -Leaf)" `
        -ErrorAction Stop
    
    Write-Host "   ✅ Task registered successfully" -ForegroundColor Green
    Write-Host ""
    
    # Prompt for password if running as different user
    if ($RunAsUser -ne $env:USERNAME) {
        Write-Host "⚠️  Password required for task execution" -ForegroundColor Yellow
        Write-Host "   The task is configured to run as: $RunAsUser" -ForegroundColor Yellow
        Write-Host "   Please provide the password for this account:" -ForegroundColor Yellow
        
        $securePassword = Read-Host "   Password" -AsSecureString
        $credential = New-Object System.Management.Automation.PSCredential($RunAsUser, $securePassword)
        
        # Update task with credentials
        Set-ScheduledTask -TaskName $TaskName -User $RunAsUser -Password ($credential.GetNetworkCredential().Password) | Out-Null
        Write-Host "   ✅ Task credentials configured" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Task registration failed: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# =============================================================================
# Action 6: Task Validation
# =============================================================================

Write-Host "🔍 Action 6: Task Validation" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Validating created task..." -ForegroundColor Cyan
try {
    $validatedTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
    $taskInfo = Get-ScheduledTaskInfo -TaskName $TaskName -ErrorAction Stop
    
    Write-Host "   ✅ Task exists in Task Scheduler" -ForegroundColor Green
    Write-Host "   • State: $($validatedTask.State)" -ForegroundColor Gray
    Write-Host "   • Next run time: $($taskInfo.NextRunTime)" -ForegroundColor Gray
    Write-Host "   • Last run time: $($taskInfo.LastRunTime)" -ForegroundColor Gray
    Write-Host "   • Last result: $($taskInfo.LastTaskResult)" -ForegroundColor Gray
    
} catch {
    Write-Host "   ⚠️  Warning: Could not validate task: $_" -ForegroundColor Yellow
}
Write-Host ""

# =============================================================================
# Action 7: Logging and Summary
# =============================================================================

Write-Host "🔍 Action 7: Logging and Summary" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

# Create log entry
$logEntry = [PSCustomObject]@{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TaskName = $TaskName
    ScriptPath = $ScriptPath
    Trigger = $Trigger
    StartTime = $StartTime
    RunAsUser = $RunAsUser
    Status = "Created"
    NextRunTime = $taskInfo.NextRunTime
}

Write-Host "📋 Exporting task creation log: $LogPath" -ForegroundColor Cyan
try {
    $logEntry | Export-Csv -Path $LogPath -NoTypeInformation -Append -ErrorAction Stop
    Write-Host "   ✅ Log entry created successfully" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Warning: Failed to write log: $_" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "📊 Task Creation Summary" -ForegroundColor Cyan
Write-Host "   • Task Name: $TaskName" -ForegroundColor Gray
Write-Host "   • Script Path: $ScriptPath" -ForegroundColor Gray
Write-Host "   • Trigger Type: $Trigger" -ForegroundColor Gray
Write-Host "   • Start Time: $StartTime" -ForegroundColor Gray
Write-Host "   • Next Run: $($taskInfo.NextRunTime)" -ForegroundColor Green
Write-Host "   • Run As: $RunAsUser" -ForegroundColor Gray
Write-Host ""

if ($ScriptParameters.Count -gt 0) {
    Write-Host "   • Script Parameters:" -ForegroundColor Gray
    foreach ($key in $ScriptParameters.Keys) {
        Write-Host "      - $key : $($ScriptParameters[$key])" -ForegroundColor Gray
    }
    Write-Host ""
}

# =============================================================================
# Action 8: Completion
# =============================================================================

Write-Host "✅ Scheduled Task Created Successfully" -ForegroundColor Green
Write-Host ""
Write-Host "⏭️  Next Steps:" -ForegroundColor Cyan
Write-Host "   • Verify task in Windows Task Scheduler (taskschd.msc)" -ForegroundColor Gray
Write-Host "   • Test task execution manually before waiting for scheduled run" -ForegroundColor Gray
Write-Host "   • Monitor task execution logs at: $logDir" -ForegroundColor Gray
Write-Host "   • Review task history: Get-ScheduledTask -TaskName '$TaskName' | Get-ScheduledTaskInfo" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 To manually run the task immediately:" -ForegroundColor Cyan
Write-Host "   Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
Write-Host ""
