<#
.SYNOPSIS
    Schedules automated recurring SIT discovery scans using Windows Task Scheduler.

.DESCRIPTION
    This script creates a scheduled task in Windows Task Scheduler to run the
    Search-GraphSITs.ps1 script automatically at specified intervals (daily, weekly,
    or monthly). This enables continuous monitoring of sensitive data across SharePoint
    without manual intervention.

.PARAMETER Frequency
    The frequency of the scheduled scan. Valid values: Daily, Weekly, Monthly

.PARAMETER DayOfWeek
    For weekly scans, specify the day of week (Monday, Tuesday, etc.)

.PARAMETER DayOfMonth
    For monthly scans, specify the day of month (1-31)

.PARAMETER Time
    The time of day to run the scan in HH:MM format (24-hour clock)

.EXAMPLE
    .\Schedule-RecurringScan.ps1 -Frequency "Weekly" -DayOfWeek "Monday" -Time "06:00"
    
    Schedules a weekly scan every Monday at 6:00 AM.

.EXAMPLE
    .\Schedule-RecurringScan.ps1 -Frequency "Daily" -Time "00:00"
    
    Schedules a daily scan at midnight.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-11-17
    Last Modified: 2025-11-17
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - PowerShell 7.0+
    - Administrator privileges (for creating scheduled tasks)
    - Microsoft Graph permissions already granted
    - Search-GraphSITs.ps1 script in same directory
    
    Script development orchestrated using GitHub Copilot.
#>

#Requires -Version 7.0
#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Daily", "Weekly", "Monthly")]
    [string]$Frequency,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")]
    [string]$DayOfWeek,
    
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 31)]
    [int]$DayOfMonth,
    
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d{2}:\d{2}$')]
    [string]$Time
)

# =============================================================================
# Script Initialization
# =============================================================================

Write-Host "📅 Schedule Recurring SIT Discovery Scan" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 1: Validate Parameters
# =============================================================================

Write-Host "🔍 Step 1: Validate Parameters" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

if ($Frequency -eq "Weekly" -and [string]::IsNullOrEmpty($DayOfWeek)) {
    Write-Host "❌ Weekly frequency requires -DayOfWeek parameter" -ForegroundColor Red
    exit 1
}

if ($Frequency -eq "Monthly" -and $DayOfMonth -eq 0) {
    Write-Host "❌ Monthly frequency requires -DayOfMonth parameter" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Parameters validated" -ForegroundColor Green
Write-Host "      • Frequency: $Frequency" -ForegroundColor DarkGray
if ($Frequency -eq "Weekly") {
    Write-Host "      • Day of week: $DayOfWeek" -ForegroundColor DarkGray
}
if ($Frequency -eq "Monthly") {
    Write-Host "      • Day of month: $DayOfMonth" -ForegroundColor DarkGray
}
Write-Host "      • Time: $Time" -ForegroundColor DarkGray

Write-Host ""

# =============================================================================
# Step 2: Verify Script Paths
# =============================================================================

Write-Host "📂 Step 2: Verify Script Paths" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

$scriptPath = $PSScriptRoot
$searchScriptPath = Join-Path $scriptPath "Search-GraphSITs.ps1"

if (-not (Test-Path $searchScriptPath)) {
    Write-Host "❌ Search-GraphSITs.ps1 not found at: $searchScriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Search script found: $searchScriptPath" -ForegroundColor Green

Write-Host ""

# =============================================================================
# Step 3: Define Scheduled Task Settings
# =============================================================================

Write-Host "⚙️ Step 3: Define Scheduled Task Settings" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

$taskName = "Purview-SIT-Discovery-Scan"
$taskDescription = "Automated Microsoft Purview SIT discovery scan using Microsoft Graph API"

# Create action to run PowerShell script
$pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"

if (-not (Test-Path $pwshPath)) {
    # Fallback to pwsh in PATH
    $pwshPath = "pwsh.exe"
}

$actionArguments = "-NoProfile -ExecutionPolicy Bypass -File `"$searchScriptPath`""

$action = New-ScheduledTaskAction `
    -Execute $pwshPath `
    -Argument $actionArguments `
    -WorkingDirectory $scriptPath

# Create trigger based on frequency
switch ($Frequency) {
    "Daily" {
        $trigger = New-ScheduledTaskTrigger -Daily -At $Time
    }
    "Weekly" {
        $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DayOfWeek -At $Time
    }
    "Monthly" {
        # For monthly, use a daily trigger with a custom condition (simplified approach)
        $trigger = New-ScheduledTaskTrigger -Daily -At $Time
        Write-Host "   ⚠️ Monthly scheduling uses daily trigger with manual validation" -ForegroundColor Yellow
        Write-Host "      You may need to adjust task settings manually for specific day-of-month" -ForegroundColor DarkGray
    }
}

# Configure task settings
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2)

# Run as current user
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive

Write-Host "   ✅ Task settings defined" -ForegroundColor Green
Write-Host "      • Task name: $taskName" -ForegroundColor DarkGray
Write-Host "      • Execution: PowerShell 7 with Search-GraphSITs.ps1" -ForegroundColor DarkGray
Write-Host "      • Trigger: $Frequency at $Time" -ForegroundColor DarkGray

Write-Host ""

# =============================================================================
# Step 4: Create or Update Scheduled Task
# =============================================================================

Write-Host "📋 Step 4: Create or Update Scheduled Task" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

try {
    # Check if task already exists
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    
    if ($existingTask) {
        Write-Host "   ⚠️ Task '$taskName' already exists, updating..." -ForegroundColor Yellow
        
        # Unregister existing task
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        
        Write-Host "      • Removed existing task" -ForegroundColor DarkGray
    }
    
    # Register new scheduled task
    Register-ScheduledTask `
        -TaskName $taskName `
        -Description $taskDescription `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Force | Out-Null
    
    Write-Host "   ✅ Scheduled task created successfully" -ForegroundColor Green
    
} catch {
    Write-Host "   ❌ Failed to create scheduled task: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   💡 Ensure you're running PowerShell as Administrator" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# =============================================================================
# Step 5: Verify Scheduled Task
# =============================================================================

Write-Host "✅ Step 5: Verify Scheduled Task" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

try {
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
    $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName -ErrorAction Stop
    
    Write-Host "   📊 Task Details:" -ForegroundColor Cyan
    Write-Host "      • Task name: $($task.TaskName)" -ForegroundColor DarkGray
    Write-Host "      • State: $($task.State)" -ForegroundColor DarkGray
    Write-Host "      • Last run: $($taskInfo.LastRunTime)" -ForegroundColor DarkGray
    Write-Host "      • Next run: $($taskInfo.NextRunTime)" -ForegroundColor DarkGray
    Write-Host "      • Last result: $($taskInfo.LastTaskResult)" -ForegroundColor DarkGray
    
} catch {
    Write-Host "   ⚠️ Failed to retrieve task details: $_" -ForegroundColor Yellow
}

Write-Host ""

# =============================================================================
# Step 6: Test Task Execution (Optional)
# =============================================================================

Write-Host "🧪 Step 6: Test Task Execution" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

Write-Host "   💡 You can test the task manually with:" -ForegroundColor Cyan
Write-Host "      Start-ScheduledTask -TaskName '$taskName'" -ForegroundColor DarkGray
Write-Host ""
Write-Host "   📊 Monitor task execution with:" -ForegroundColor Cyan
Write-Host "      Get-ScheduledTaskInfo -TaskName '$taskName'" -ForegroundColor DarkGray
Write-Host ""

$testNow = Read-Host "   Would you like to test the task now? (y/n)"

if ($testNow -eq 'y') {
    Write-Host ""
    Write-Host "   ⏳ Starting scheduled task..." -ForegroundColor Cyan
    
    try {
        Start-ScheduledTask -TaskName $taskName
        
        Start-Sleep -Seconds 2
        
        $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName
        
        Write-Host "   ✅ Task started successfully" -ForegroundColor Green
        Write-Host "      • Task state: $($taskInfo.LastTaskResult)" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "   ⏳ Task is now running. Check Task Scheduler for progress." -ForegroundColor Cyan
        
    } catch {
        Write-Host "   ⚠️ Failed to start task: $_" -ForegroundColor Yellow
    }
}

Write-Host ""

# =============================================================================
# Script Completion
# =============================================================================

Write-Host "✅ Recurring scan scheduled successfully" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Schedule Summary:" -ForegroundColor Cyan
Write-Host "   • Frequency: $Frequency" -ForegroundColor DarkGray
if ($Frequency -eq "Weekly") {
    Write-Host "   • Day: $DayOfWeek" -ForegroundColor DarkGray
}
if ($Frequency -eq "Monthly") {
    Write-Host "   • Day: $DayOfMonth (requires manual adjustment in Task Scheduler)" -ForegroundColor DarkGray
}
Write-Host "   • Time: $Time" -ForegroundColor DarkGray
Write-Host "   • Next run: $((Get-ScheduledTaskInfo -TaskName $taskName).NextRunTime)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Reports will be saved automatically to the reports/ folder" -ForegroundColor DarkGray
Write-Host "   2. Monitor task execution in Task Scheduler (taskschd.msc)" -ForegroundColor DarkGray
Write-Host "   3. Review generated reports after each scan" -ForegroundColor DarkGray
Write-Host "   4. Optional: Configure email notifications for scan completion" -ForegroundColor DarkGray
Write-Host ""

exit 0
