<#
.SYNOPSIS
    Calculates and tracks weekly remediation progress metrics.

.DESCRIPTION
    This script aggregates data from various remediation steps to generate a weekly progress report.
    It calculates metrics such as files deleted, storage saved, remediation rate, and estimated cost savings.
    The script supports data collection from local and remote sources (VM) and maintains a historical
    CSV log of progress over time.
    
    It also generates a visual dashboard of remediation velocity to track team performance.

.PARAMETER None
    This script does not accept parameters. It prompts for configuration interactively.

.EXAMPLE
    .\Update-WeeklyProgress.ps1
    
    Runs the progress tracking wizard interactively.

.NOTES
    File Name      : Update-WeeklyProgress.ps1
    Author         : Marcus Jacobson
    Prerequisite   : PowerShell 5.1 or later, Network access to VM (optional)
    Version        : 1.0
    Last Updated   : July 17, 2025
    
    Script development orchestrated using GitHub Copilot.

.REPORTING OPERATIONS
    - Data Aggregation (Local/Remote)
    - Metric Calculation (Savings/Rate)
    - Historical Tracking (CSV)
    - Velocity Dashboard Generation
    - Weekly Report Export
#>
#
# =============================================================================
# Step 5: Weekly Progress Tracking
# =============================================================================

# Run this weekly to track progress
$weekNumber = 1  # Increment each week

Write-Host "`n========== CALCULATING WEEKLY METRICS ==========" -ForegroundColor Cyan

#============================================================================
# OPTION 1: Download Required Files from VM via Remote Access
#============================================================================

Write-Host "`nChecking for required files from VM..." -ForegroundColor Cyan

# Determine network location FIRST (needed for both file download and tombstone counting)
Write-Host "`n   Where is your admin machine located?" -ForegroundColor Cyan
Write-Host "   1. On a device in the same Azure VNet (e.g., another VM, peered network)" -ForegroundColor White
Write-Host "   2. On a device outside the VNet (e.g., work/home workstation)" -ForegroundColor White

$networkLocation = Read-Host "`n   Enter choice (1 or 2)"

# Initialize variables for potential reuse across script sections
$vmPublicIP = $null
$credential = $null

$remediationPlanPath = "C:\PurviewLab\RemediationPlan.csv"

# Check if RemediationPlan.csv exists locally
if (-not (Test-Path $remediationPlanPath)) {
    Write-Host "`n[WARNING] RemediationPlan.csv not found locally" -ForegroundColor Yellow
    Write-Host "   Attempting to download from VM..." -ForegroundColor Gray
    
    if ($networkLocation -eq "1") {
        # Same VNet - Use Network Share
        Write-Host "`n   Using network share method (VNet connectivity)..." -ForegroundColor Cyan
        
        $vmNameOrIP = Read-Host "   Enter VM private IP or name (e.g., 10.0.1.4 or vm-purview-scan)"
        $vmSharePath = "\\$vmNameOrIP\c$\PurviewLab\RemediationPlan.csv"
        
        Write-Host "   Enter VM credentials (labadmin):" -ForegroundColor Cyan
        $credential = Get-Credential -UserName "labadmin" -Message "Enter password for VM access"
        
        try {
            # Map network drive with credentials
            Write-Host "   Accessing VM share: $vmSharePath" -ForegroundColor Gray
            
            # Use net use command to authenticate
            $netUseCommand = "net use \\$vmNameOrIP\c$ /user:labadmin $($credential.GetNetworkCredential().Password)"
            Invoke-Expression $netUseCommand | Out-Null
            
            # Copy file
            Write-Host "   Downloading RemediationPlan.csv from VM..." -ForegroundColor Gray
            Copy-Item -Path $vmSharePath -Destination $remediationPlanPath -ErrorAction Stop
            
            Write-Host "   [SUCCESS] RemediationPlan.csv downloaded successfully" -ForegroundColor Green
            
            # Also download SharePoint-Deletions.csv if it exists
            Write-Host "   Checking for SharePoint-Deletions.csv on VM..." -ForegroundColor Gray
            $spSharePath = "\\$vmNameOrIP\c$\PurviewLab\SharePoint-Deletions.csv"
            try {
                Copy-Item -Path $spSharePath -Destination "C:\PurviewLab\SharePoint-Deletions.csv" -ErrorAction Stop
                Write-Host "   [SUCCESS] SharePoint-Deletions.csv downloaded successfully" -ForegroundColor Green
            } catch {
                Write-Host "   [INFO] SharePoint-Deletions.csv not found on VM (Step 3 may not have been executed)" -ForegroundColor Gray
            }
            
            # Clean up network connection
            net use \\$vmNameOrIP\c$ /delete | Out-Null
            
        } catch {
            Write-Host "   [ERROR] Failed to download from VM: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "   Common issues:" -ForegroundColor Yellow
            Write-Host "   - VM name/IP incorrect or not reachable" -ForegroundColor Gray
            Write-Host "   - Credentials incorrect" -ForegroundColor Gray
            Write-Host "   - File path doesn't exist on VM" -ForegroundColor Gray
            Write-Host "   - NSG blocking SMB port 445" -ForegroundColor Gray
            Write-Host ""
            Write-Host "   Manual alternative: RDP to VM and copy file directly" -ForegroundColor Cyan
        }
        
    } else {
        # External Network - Use Public IP + PowerShell Remoting
        Write-Host "`n   Using Public IP with PowerShell Remoting..." -ForegroundColor Cyan
        
        $vmPublicIP = Read-Host "   Enter VM's public IP address (e.g., 20.120.45.78)"
        
        Write-Host "   Enter VM credentials (labadmin):" -ForegroundColor Cyan
        $credential = Get-Credential -UserName "labadmin" -Message "Enter password for VM access"
        
        Write-Host ""
        Write-Host "   [Prerequisites for external access]" -ForegroundColor Yellow
        Write-Host "   1. VM must have public IP assigned" -ForegroundColor Gray
        Write-Host "   2. NSG must allow WinRM (port 5985) from your IP" -ForegroundColor Gray
        Write-Host "   3. VM must be added to TrustedHosts (one-time setup)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "   💡 Why TrustedHosts? When connecting via public IP (non-domain)," -ForegroundColor Cyan
        Write-Host "      Windows requires explicit trust. This script can configure it" -ForegroundColor Cyan
        Write-Host "      automatically if you run PowerShell as Administrator." -ForegroundColor Cyan
        Write-Host ""
        
        $setupDone = Read-Host "   Have you added VM to TrustedHosts? (yes/no)"
        
        if ($setupDone -eq 'yes') {
            try {
                # Create PS Session to VM via public IP
                Write-Host "   Connecting to VM via PowerShell remoting..." -ForegroundColor Gray
                $session = New-PSSession -ComputerName $vmPublicIP -Credential $credential -ErrorAction Stop
                
                # Copy RemediationPlan.csv from VM
                Write-Host "   Downloading RemediationPlan.csv from VM..." -ForegroundColor Gray
                Copy-Item -Path "C:\PurviewLab\RemediationPlan.csv" -Destination $remediationPlanPath -FromSession $session -ErrorAction Stop
                
                Write-Host "   [SUCCESS] RemediationPlan.csv downloaded successfully" -ForegroundColor Green
                
                # Also download SharePoint-Deletions.csv if it exists
                Write-Host "   Checking for SharePoint-Deletions.csv on VM..." -ForegroundColor Gray
                try {
                    Copy-Item -Path "C:\PurviewLab\SharePoint-Deletions.csv" -Destination "C:\PurviewLab\SharePoint-Deletions.csv" -FromSession $session -ErrorAction Stop
                    Write-Host "   [SUCCESS] SharePoint-Deletions.csv downloaded successfully" -ForegroundColor Green
                } catch {
                    Write-Host "   [INFO] SharePoint-Deletions.csv not found on VM (Step 3 may not have been executed)" -ForegroundColor Gray
                }
                
                # Clean up session
                Remove-PSSession -Session $session
                
            } catch {
                Write-Host "   [ERROR] Failed to download from VM: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host ""
                Write-Host "   Common issues:" -ForegroundColor Yellow
                Write-Host "   - NSG blocking WinRM port 5985 from your IP" -ForegroundColor Gray
                Write-Host "   - WinRM not enabled on VM: Run 'Enable-PSRemoting -Force' on VM" -ForegroundColor Gray
                Write-Host "   - Public IP changed (check Azure Portal)" -ForegroundColor Gray
                Write-Host "   - TrustedHosts not configured (run setup command above)" -ForegroundColor Gray
                Write-Host ""
                Write-Host "   Manual alternative: RDP to public IP and copy file via clipboard" -ForegroundColor Cyan
                Write-Host "   Command: mstsc /v:$vmPublicIP" -ForegroundColor Gray
            }
        } else {
            # User hasn't configured TrustedHosts - offer to do it now
            Write-Host ""
            Write-Host "   Would you like to add the VM to TrustedHosts now? (yes/no)" -ForegroundColor Cyan
            $addNow = Read-Host "   "
            
            if ($addNow -eq 'yes') {
                # Check if running as Administrator
                $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
                
                if (-not $isAdmin) {
                    Write-Host ""
                    Write-Host "   [ERROR] PowerShell must be run as Administrator to configure TrustedHosts" -ForegroundColor Red
                    Write-Host ""
                    Write-Host "   Please do the following:" -ForegroundColor Yellow
                    Write-Host "   1. Close this PowerShell window" -ForegroundColor White
                    Write-Host "   2. Right-click PowerShell icon and select 'Run as Administrator'" -ForegroundColor White
                    Write-Host "   3. Run these two commands:" -ForegroundColor White
                    Write-Host ""
                    Write-Host "      Enable-PSRemoting -Force -SkipNetworkProfileCheck" -ForegroundColor Cyan
                    Write-Host "      Set-Item WSMan:\localhost\Client\TrustedHosts -Value '$vmPublicIP' -Force" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host "   4. Re-run this script (no need for Administrator after setup)" -ForegroundColor White
                    Write-Host ""
                    
                } else {
                    try {
                        Write-Host "   Checking WinRM service status..." -ForegroundColor Gray
                        
                        # Check if WinRM service exists and is running
                        $winrmService = Get-Service -Name WinRM -ErrorAction SilentlyContinue
                        
                        if ($null -eq $winrmService -or $winrmService.Status -ne 'Running') {
                            Write-Host "   Enabling PowerShell Remoting (WinRM)..." -ForegroundColor Gray
                            Enable-PSRemoting -Force -SkipNetworkProfileCheck | Out-Null
                            Write-Host "   [SUCCESS] WinRM service enabled" -ForegroundColor Green
                        } else {
                            Write-Host "   [SUCCESS] WinRM service already running" -ForegroundColor Green
                        }
                        
                        Write-Host "   Adding VM to TrustedHosts..." -ForegroundColor Gray
                        
                        # Get current TrustedHosts value
                        $currentHosts = (Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction Stop).Value
                        
                        if ($currentHosts -eq "") {
                            # No existing hosts - just add the VM
                            Set-Item WSMan:\localhost\Client\TrustedHosts -Value $vmPublicIP -Force
                        } else {
                            # Check if VM already in list
                            if ($currentHosts -split ',' | Where-Object { $_.Trim() -eq $vmPublicIP }) {
                                Write-Host "   [INFO] VM already in TrustedHosts list" -ForegroundColor Cyan
                            } else {
                                # Append to existing hosts
                                $newHosts = "$currentHosts,$vmPublicIP"
                                Set-Item WSMan:\localhost\Client\TrustedHosts -Value $newHosts -Force
                            }
                        }
                        
                        Write-Host "   [SUCCESS] VM added to TrustedHosts" -ForegroundColor Green
                        Write-Host ""
                        
                        # Now attempt the connection
                        try {
                            Write-Host "   Connecting to VM via PowerShell remoting..." -ForegroundColor Gray
                            $session = New-PSSession -ComputerName $vmPublicIP -Credential $credential -ErrorAction Stop
                            
                            Write-Host "   Downloading RemediationPlan.csv from VM..." -ForegroundColor Gray
                            Copy-Item -Path "C:\PurviewLab\RemediationPlan.csv" -Destination $remediationPlanPath -FromSession $session -ErrorAction Stop
                            
                            Write-Host "   [SUCCESS] RemediationPlan.csv downloaded successfully" -ForegroundColor Green
                            
                            # Also download SharePoint-Deletions.csv if it exists
                            Write-Host "   Checking for SharePoint-Deletions.csv on VM..." -ForegroundColor Gray
                            try {
                                Copy-Item -Path "C:\PurviewLab\SharePoint-Deletions.csv" -Destination "C:\PurviewLab\SharePoint-Deletions.csv" -FromSession $session -ErrorAction Stop
                                Write-Host "   [SUCCESS] SharePoint-Deletions.csv downloaded successfully" -ForegroundColor Green
                            } catch {
                                Write-Host "   [INFO] SharePoint-Deletions.csv not found on VM (Step 3 may not have been executed)" -ForegroundColor Gray
                            }
                            
                            Remove-PSSession -Session $session
                            
                        } catch {
                            Write-Host "   [ERROR] Failed to download: $($_.Exception.Message)" -ForegroundColor Red
                            Write-Host ""
                            Write-Host "   TrustedHosts is now configured. Common remaining issues:" -ForegroundColor Yellow
                            Write-Host "   - NSG blocking WinRM port 5985 from your IP" -ForegroundColor Gray
                            Write-Host "   - WinRM not enabled on VM: Run 'Enable-PSRemoting -Force' on VM" -ForegroundColor Gray
                            Write-Host "   - Firewall blocking connection on VM or local PC" -ForegroundColor Gray
                            Write-Host ""
                            Write-Host "   Manual alternative: RDP to public IP and copy file via clipboard" -ForegroundColor Cyan
                            Write-Host "   Command: mstsc /v:$vmPublicIP" -ForegroundColor Gray
                        }
                        
                    } catch {
                        Write-Host "   [ERROR] Failed to configure: $($_.Exception.Message)" -ForegroundColor Red
                        Write-Host ""
                        Write-Host "   Manual setup commands (run in Administrator PowerShell):" -ForegroundColor Yellow
                        Write-Host "   Enable-PSRemoting -Force -SkipNetworkProfileCheck" -ForegroundColor Cyan
                        Write-Host "   Set-Item WSMan:\localhost\Client\TrustedHosts -Value '$vmPublicIP' -Force" -ForegroundColor Cyan
                    }
                }
            } else {
                Write-Host ""
                Write-Host "   Manual setup commands (requires Administrator PowerShell):" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "   1. Enable WinRM service:" -ForegroundColor White
                Write-Host "      Enable-PSRemoting -Force -SkipNetworkProfileCheck" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "   2. Add VM to TrustedHosts:" -ForegroundColor White
                Write-Host "      Set-Item WSMan:\localhost\Client\TrustedHosts -Value '$vmPublicIP' -Force" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "   After running these commands, re-run this script." -ForegroundColor Yellow
                Write-Host ""
            }
        }
    }
} else {
    # File already exists locally
    Write-Host "`n[INFO] RemediationPlan.csv already exists locally - using cached copy" -ForegroundColor Cyan
    Write-Host "   (Delete the file if you want to re-download from VM)" -ForegroundColor Gray
    
    # Even if RemediationPlan.csv exists, check if we need to download SharePoint-Deletions.csv
    $sharePointDeletionsPath = "C:\PurviewLab\SharePoint-Deletions.csv"
    if (-not (Test-Path $sharePointDeletionsPath)) {
        Write-Host "`n   SharePoint-Deletions.csv not found locally - attempting download..." -ForegroundColor Cyan
        
        if ($networkLocation -eq "2") {
            # External access - use PowerShell remoting
            $vmPublicIP = Read-Host "   Enter VM's public IP address (e.g., 20.120.45.78)"
            Write-Host "   Enter VM credentials (labadmin):" -ForegroundColor Cyan
            $credential = Get-Credential -UserName "labadmin" -Message "Enter password for VM access"
            
            try {
                $session = New-PSSession -ComputerName $vmPublicIP -Credential $credential -ErrorAction Stop
                
                Write-Host "   Checking for SharePoint-Deletions.csv on VM..." -ForegroundColor Gray
                try {
                    Copy-Item -Path "C:\PurviewLab\SharePoint-Deletions.csv" -Destination $sharePointDeletionsPath -FromSession $session -ErrorAction Stop
                    Write-Host "   [SUCCESS] SharePoint-Deletions.csv downloaded successfully" -ForegroundColor Green
                } catch {
                    Write-Host "   [INFO] SharePoint-Deletions.csv not found on VM (Step 3 may not have been executed)" -ForegroundColor Gray
                }
                
                Remove-PSSession -Session $session
            } catch {
                Write-Host "   [WARNING] Could not connect to VM to check for SharePoint-Deletions.csv" -ForegroundColor Yellow
            }
        } else {
            # VNet access - use network share
            $vmNameOrIP = Read-Host "   Enter VM private IP or name (e.g., 10.0.1.4 or vm-purview-scan)"
            Write-Host "   Enter VM credentials (labadmin):" -ForegroundColor Cyan
            $credential = Get-Credential -UserName "labadmin" -Message "Enter password for VM access"
            
            try {
                $netUseCommand = "net use \\$vmNameOrIP\c$ /user:labadmin $($credential.GetNetworkCredential().Password)"
                Invoke-Expression $netUseCommand | Out-Null
                
                $spSharePath = "\\$vmNameOrIP\c$\PurviewLab\SharePoint-Deletions.csv"
                try {
                    Copy-Item -Path $spSharePath -Destination $sharePointDeletionsPath -ErrorAction Stop
                    Write-Host "   [SUCCESS] SharePoint-Deletions.csv downloaded successfully" -ForegroundColor Green
                } catch {
                    Write-Host "   [INFO] SharePoint-Deletions.csv not found on VM (Step 3 may not have been executed)" -ForegroundColor Gray
                }
                
                net use \\$vmNameOrIP\c$ /delete | Out-Null
            } catch {
                Write-Host "   [WARNING] Could not connect to VM to check for SharePoint-Deletions.csv" -ForegroundColor Yellow
            }
        }
    }
}

#============================================================================
# Load Remediation Plan (Now Available Locally or Downloaded)
#============================================================================

if (Test-Path $remediationPlanPath) {
    $remediationPlan = Import-Csv $remediationPlanPath
    Write-Host "[SUCCESS] Remediation plan loaded: $($remediationPlan.Count) total files" -ForegroundColor Green
    
    # Calculate files by action type
    $autoDeleteFiles = $remediationPlan | Where-Object { $_.Action -match 'AUTO_DELETE' }
    $manualReviewFiles = $remediationPlan | Where-Object { $_.Action -eq 'MANUAL_REVIEW' }
    
    Write-Host "   AUTO_DELETE candidates: $($autoDeleteFiles.Count)" -ForegroundColor Gray
    Write-Host "   MANUAL_REVIEW files: $($manualReviewFiles.Count)" -ForegroundColor Gray
} else {
    Write-Host "[WARNING] RemediationPlan.csv not found at $remediationPlanPath" -ForegroundColor Yellow
    Write-Host "   Copy this file from the VM if needed" -ForegroundColor Gray
    $remediationPlan = @()
    $autoDeleteFiles = @()
    $manualReviewFiles = @()
}

# Calculate files deleted from tombstone count (Step 4)
Write-Host "`nCalculating deleted files from tombstones..." -ForegroundColor Cyan
$tombstoneCount = 0

# Determine tombstone access method based on network location
if ($networkLocation -eq "1") {
    # Same VNet - Can access network share directly
    $computerName = $env:COMPUTERNAME
    $networkPath = "\\$computerName\Projects\RemediationTestData"
    
    Write-Host "   Checking for tombstones at: $networkPath" -ForegroundColor Gray
    
    if (Test-Path $networkPath) {
        $tombstones = Get-ChildItem -Path $networkPath -Recurse -Filter "*.DELETED_*.txt" -ErrorAction SilentlyContinue
        $tombstoneCount = $tombstones.Count
        Write-Host "[SUCCESS] Found $tombstoneCount tombstone files on network share" -ForegroundColor Green
        
        # Calculate total size saved from tombstone metadata
        $totalSizeMB = 0
        foreach ($tombstone in $tombstones) {
            $content = Get-Content $tombstone.FullName -Raw
            if ($content -match 'Size:\s+([\d.]+)\s+MB') {
                $totalSizeMB += [decimal]$matches[1]
            }
        }
        $storageSavedGB = [math]::Round($totalSizeMB / 1024, 2)
        Write-Host "   Total storage saved: $storageSavedGB GB" -ForegroundColor Cyan
    } else {
        Write-Host "[WARNING] Network path not accessible: $networkPath" -ForegroundColor Yellow
        Write-Host "   Using manual count instead" -ForegroundColor Gray
        $tombstoneCount = Read-Host "Enter number of files deleted this week"
        $storageSavedGB = Read-Host "Enter storage saved in GB"
    }
    
} else {
    # External Network - Download tombstone summary from VM via PowerShell remoting
    Write-Host "   External access detected - downloading tombstone summary from VM..." -ForegroundColor Cyan
    
    # Check if we have the required connection variables from earlier
    if (-not $vmPublicIP -or -not $credential) {
        Write-Host "   [INFO] VM connection details not available from earlier steps" -ForegroundColor Cyan
        $vmPublicIP = Read-Host "   Enter VM's public IP address (e.g., 20.120.45.78)"
        Write-Host "   Enter VM credentials (labadmin):" -ForegroundColor Cyan
        $credential = Get-Credential -UserName "labadmin" -Message "Enter password for VM access"
    }
    
    try {
        # Create PS Session to VM to count tombstones remotely
        Write-Host "   Connecting to VM to count tombstones..." -ForegroundColor Gray
        $session = New-PSSession -ComputerName $vmPublicIP -Credential $credential -ErrorAction Stop
        
        # Execute tombstone counting script on VM
        $tombstoneData = Invoke-Command -Session $session -ScriptBlock {
            $computerName = $env:COMPUTERNAME
            $networkPath = "\\$computerName\Projects\RemediationTestData"
            
            if (Test-Path $networkPath) {
                $tombstones = Get-ChildItem -Path $networkPath -Recurse -Filter "*.DELETED_*.txt" -ErrorAction SilentlyContinue
                
                $totalSizeMB = 0
                foreach ($tombstone in $tombstones) {
                    $content = Get-Content $tombstone.FullName -Raw
                    if ($content -match 'Size:\s+([\d.]+)\s+MB') {
                        $totalSizeMB += [decimal]$matches[1]
                    }
                }
                
                [PSCustomObject]@{
                    Count = $tombstones.Count
                    TotalSizeMB = $totalSizeMB
                    Path = $networkPath
                }
            } else {
                [PSCustomObject]@{
                    Count = 0
                    TotalSizeMB = 0
                    Path = $networkPath
                }
            }
        }
        
        $tombstoneCount = $tombstoneData.Count
        $storageSavedGB = [math]::Round($tombstoneData.TotalSizeMB / 1024, 2)
        
        Write-Host "[SUCCESS] Found $tombstoneCount tombstone files on VM" -ForegroundColor Green
        Write-Host "   Total storage saved: $storageSavedGB GB" -ForegroundColor Cyan
        
        Remove-PSSession -Session $session
        
    } catch {
        Write-Host "[WARNING] Failed to download tombstone data from VM: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "   Using manual count instead" -ForegroundColor Gray
        $tombstoneCount = Read-Host "Enter number of files deleted this week"
        $storageSavedGB = Read-Host "Enter storage saved in GB"
    }
}

# Calculate SharePoint deletions from Step 3 log (if exists)
Write-Host "`nChecking for SharePoint deletions..." -ForegroundColor Cyan
$sharePointDeletionsPath = "C:\PurviewLab\SharePoint-Deletions.csv"
$sharePointDeletedCount = 0
if (Test-Path $sharePointDeletionsPath) {
    $sharePointDeletions = Import-Csv $sharePointDeletionsPath
    $sharePointDeletedCount = $sharePointDeletions.Count
    
    if ($sharePointDeletedCount -gt 0) {
        Write-Host "[SUCCESS] SharePoint deletions: $sharePointDeletedCount files" -ForegroundColor Green
    } else {
        Write-Host "[INFO] SharePoint-Deletions.csv exists but contains 0 deletions" -ForegroundColor Gray
        Write-Host "   This means Step 3 was executed but no files were actually deleted" -ForegroundColor Gray
        Write-Host "   (Step 3 creates empty CSV if no deletions occur)" -ForegroundColor Gray
    }
} else {
    Write-Host "[INFO] No SharePoint deletions log found" -ForegroundColor Gray
    Write-Host "   This file is created by Step 3 (SharePoint PnP PowerShell deletion)" -ForegroundColor Gray
    Write-Host "   If you executed Step 3 on the VM, the file should have been downloaded above" -ForegroundColor Gray
}

# Calculate total files deleted
$totalFilesDeleted = $tombstoneCount + $sharePointDeletedCount

# Manual review metrics (requires user input for now)
Write-Host "`nManual review metrics:" -ForegroundColor Cyan
Write-Host "   These track manual human review work done outside automated scripts." -ForegroundColor Gray
Write-Host "   Press Enter to skip (use 0 for all values) if no manual reviews were performed." -ForegroundColor Gray
Write-Host ""

$manualReviewsInput = Read-Host "How many HIGH severity files did you manually review this week? (default: 0)"
$manualReviewsCompleted = if ([string]::IsNullOrWhiteSpace($manualReviewsInput)) { 0 } else { [int]$manualReviewsInput }

$highSeverityInput = Read-Host "How many HIGH severity files did you remediate (delete/archive/retain decision)? (default: 0)"
$highSeverityResolved = if ([string]::IsNullOrWhiteSpace($highSeverityInput)) { 0 } else { [int]$highSeverityInput }

$filesRetainedInput = Read-Host "How many files did you decide to RETAIN (keep)? (default: 0)"
$filesRetained = if ([string]::IsNullOrWhiteSpace($filesRetainedInput)) { 0 } else { [int]$filesRetainedInput }

# Calculate remediation rate
if ($remediationPlan.Count -gt 0) {
    $remediationRate = [math]::Round(($totalFilesDeleted / $remediationPlan.Count) * 100, 0)
    $remediationRateString = "$remediationRate%"
} else {
    $remediationRateString = "N/A"
}

# Estimate cost savings ($3 per GB per month for storage)
$costSavingsUSD = [math]::Round($storageSavedGB * 3, 0)

# Build current week stats with calculated values
$currentStats = [PSCustomObject]@{
    Date = Get-Date -Format "yyyy-MM-dd"
    Week = $weekNumber
    FilesDeleted = $totalFilesDeleted  # Calculated from tombstones + SharePoint logs
    FilesArchived = 0  # Update if you have archive operations
    FilesRetained = $filesRetained  # User input
    RemediationRate = $remediationRateString  # Calculated from total deleted / total candidates
    StorageSavedGB = $storageSavedGB  # Calculated from tombstone metadata
    CostSavingsUSD = $costSavingsUSD  # Estimated at $3/GB/month
    ManualReviewsCompleted = $manualReviewsCompleted  # User input
    HighSeverityResolved = $highSeverityResolved  # User input
    TombstonesCreated = $tombstoneCount  # Calculated
    SharePointDeleted = $sharePointDeletedCount  # Calculated
}

Write-Host "`n========== WEEKLY SUMMARY ==========" -ForegroundColor Green
Write-Host "Files Deleted: $totalFilesDeleted ($tombstoneCount on-prem + $sharePointDeletedCount SharePoint)" -ForegroundColor White
Write-Host "Storage Saved: $storageSavedGB GB" -ForegroundColor White
Write-Host "Remediation Rate: $remediationRateString" -ForegroundColor White
Write-Host "Estimated Cost Savings: `$$costSavingsUSD/month" -ForegroundColor White

# Check for duplicate week entries before appending (handles script re-runs)
$csvPath = "C:\PurviewLab\ProgressTracking.csv"

if (Test-Path $csvPath) {
    $existingData = Import-Csv $csvPath
    
    # Check if this week already exists (exclude baseline Week 0)
    $existingWeek = $existingData | Where-Object { 
        [int]$_.Week -eq $weekNumber -and [int]$_.Week -gt 0 
    }
    
    if ($existingWeek) {
        # Week already exists - replace it with updated data
        Write-Host "`n[WARNING] Week $weekNumber data already exists in tracking file" -ForegroundColor Yellow
        Write-Host "          Replacing previous entry with updated metrics..." -ForegroundColor Yellow
        
        # Remove old entry for this week, keep baseline + other weeks
        $updatedData = $existingData | Where-Object { 
            -not ([int]$_.Week -eq $weekNumber -and [int]$_.Week -gt 0) 
        }
        
        # IMPORTANT: Merge column schemas by combining baseline + weekly data
        # This ensures all columns are present when we rewrite the CSV
        $allData = @($updatedData) + @($currentStats)
        
        # Rewrite entire CSV with merged schema (includes all columns from both baseline and weekly data)
        $allData | Export-Csv $csvPath -NoTypeInformation -Force
        
        Write-Host "[SUCCESS] Week $weekNumber data updated (previous entry replaced)" -ForegroundColor Green
    } else {
        # First time for this week - check for schema compatibility
        # If baseline has different columns, we need to merge schemas
        $baselineRow = $existingData | Where-Object { [int]$_.Week -eq 0 }
        
        if ($baselineRow) {
            # Get all unique column names from baseline and current stats
            $baselineColumns = $baselineRow.PSObject.Properties.Name
            $weeklyColumns = $currentStats.PSObject.Properties.Name
            
            # Check if schemas are different
            $schemaMismatch = ($baselineColumns | Where-Object { $weeklyColumns -notcontains $_ }).Count -gt 0 -or `
                              ($weeklyColumns | Where-Object { $baselineColumns -notcontains $_ }).Count -gt 0
            
            if ($schemaMismatch) {
                Write-Host "`n[INFO] Detected column schema differences between baseline and weekly data" -ForegroundColor Cyan
                Write-Host "       Merging schemas to ensure all columns are preserved..." -ForegroundColor Cyan
                
                # Merge schemas by rewriting entire CSV
                $allData = @($existingData) + @($currentStats)
                $allData | Export-Csv $csvPath -NoTypeInformation -Force
                
                Write-Host "[SUCCESS] Week $weekNumber data added with merged column schema" -ForegroundColor Green
            } else {
                # Schemas match - normal append
                $currentStats | Export-Csv $csvPath -Append -NoTypeInformation -Force
                Write-Host "[SUCCESS] Week $weekNumber data added to tracking file" -ForegroundColor Green
            }
        } else {
            # No baseline found - normal append
            $currentStats | Export-Csv $csvPath -Append -NoTypeInformation -Force
            Write-Host "[SUCCESS] Week $weekNumber data added to tracking file" -ForegroundColor Green
        }
    }
} else {
    # CSV doesn't exist yet - create it
    $currentStats | Export-Csv $csvPath -NoTypeInformation -Force
    Write-Host "[SUCCESS] Tracking file created with Week $weekNumber data" -ForegroundColor Green
}

# Generate progress report by reading current CSV data
# Note: CSV read is safe because schema merging ensures all columns exist
$allProgress = Import-Csv "C:\PurviewLab\ProgressTracking.csv"
$weeklyProgress = $allProgress | Where-Object { $_.Week -gt 0 }

# Calculate average files per week from all weekly entries
if ($weeklyProgress.Count -gt 0) {
    $avgFilesPerWeek = ($weeklyProgress | Measure-Object -Property FilesDeleted -Average -ErrorAction SilentlyContinue).Average
    if ($null -eq $avgFilesPerWeek) { $avgFilesPerWeek = 0 }
    $avgFilesPerWeek = [math]::Round($avgFilesPerWeek, 0)
} else {
    $avgFilesPerWeek = 0
}

# Calculate projected completion
if ($remediationRate -gt 0 -and $weekNumber -gt 0) {
    $weeksRemaining = [math]::Ceiling((100 - $remediationRate) / ($remediationRate / $weekNumber))
    $projectedCompletion = "~$weeksRemaining weeks"
} else {
    $projectedCompletion = "TBD"
}

$progressReport = @"

============================================================
REMEDIATION PROGRESS REPORT - WEEK $weekNumber
============================================================
Date: $(Get-Date -Format 'yyyy-MM-dd')

REMEDIATION SUMMARY:
  Files Deleted This Week: $totalFilesDeleted
  Files Archived This Week: 0
  Files Retained: $filesRetained

CUMULATIVE PROGRESS:
  Total Remediation Rate: $remediationRateString
  Storage Reclaimed: $storageSavedGB GB
  Estimated Cost Savings: `$$costSavingsUSD/month

COMPLIANCE METRICS:
  Manual Reviews Completed: $manualReviewsCompleted
  High-Severity Files Resolved: $highSeverityResolved

VELOCITY ANALYSIS:
  Avg Files/Week: $avgFilesPerWeek
  Projected Completion: $projectedCompletion

NEXT WEEK TARGETS:
  - Delete 600 files (20% increase)
  - Archive 250 files
  - Complete 30 manual reviews for HIGH severity data

============================================================
"@

Write-Host $progressReport -ForegroundColor Cyan

# Save report
$progressReport | Out-File "C:\PurviewLab\WeeklyReport-Week$weekNumber.txt" -Encoding UTF8

# Display remediation velocity dashboard
Write-Host "`n========== REMEDIATION VELOCITY DASHBOARD ==========" -ForegroundColor Cyan

foreach ($week in $weeklyProgress) {
    # Convert string values to integers for display
    $filesDeleted = if ($week.FilesDeleted) { [int]$week.FilesDeleted } else { 0 }
    $storageSaved = if ($week.StorageSavedGB) { [decimal]$week.StorageSavedGB } else { 0 }
    
    $barLength = [math]::Round($filesDeleted / 10)  # Scale for display
    $bar = "█" * $barLength
    
    Write-Host "Week $($week.Week): " -NoNewline -ForegroundColor Yellow
    Write-Host "$bar " -NoNewline -ForegroundColor Green
    Write-Host "($filesDeleted files, $storageSaved GB)" -ForegroundColor White
}

Write-Host "`n" -NoNewline
