<#
.SYNOPSIS
    Uploads department-specific test files to Microsoft Teams channels.

.DESCRIPTION
    This script uploads test files from the data-templates directory to Microsoft Teams
    channels within the Retail Operations Testing team. Files are distributed across
    channels based on content type and sensitivity to enable testing of Teams-specific
    DLP policies, channel-based classification scenarios, and Teams file sharing behaviors.
    
    Files are uploaded to the channel's document library (Files tab) and simulated as
    channel message attachments to test both storage and conversation-based DLP policies.

.PARAMETER ConfigPath
    Path to the global-config.json file. Defaults to templates/global-config.json.

.EXAMPLE
    .\Upload-TeamsTestData.ps1
    
    Uploads channel-specific files to all Teams channels using default configuration.

.EXAMPLE
    .\Upload-TeamsTestData.ps1 -ConfigPath "C:\custom\config.json"
    
    Uses a custom configuration file for Teams uploads.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-30
    Last Modified: 2025-12-30
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK (Microsoft.Graph.Teams, Microsoft.Graph.Files)
    - Service Principal with TeamMember.ReadWrite.All, Files.ReadWrite.All permissions
    - Test files generated in data-templates/ directory
    - Teams environment created (run New-TeamsEnvironment.ps1 first)
    - Test users added as team members
    
    Script development orchestrated using GitHub Copilot.

.FILE DISTRIBUTION
    - Customer Data Channel: PII files, loyalty files, customer profile files, SSN records
    - Financial Reports Channel: Credit card files, banking files, payment reports, financial data
#>

#
# =============================================================================
# Uploads test files to Microsoft Teams channels for DLP and classification testing
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "..\..\templates\global-config.json"
)

# =============================================================================
# Step 1: Load Configuration and Validate Test Files
# =============================================================================

Write-Host "📤 Teams Test Data Upload" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Step 1: Loading Configuration" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Resolve configuration path
$resolvedConfigPath = Join-Path $PSScriptRoot $ConfigPath
if (-not (Test-Path $resolvedConfigPath)) {
    Write-Host "   ❌ Configuration file not found: $resolvedConfigPath" -ForegroundColor Red
    exit 1
}

try {
    $config = Get-Content $resolvedConfigPath -Raw | ConvertFrom-Json
    Write-Host "   ✅ Configuration loaded from: $resolvedConfigPath" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to parse configuration file: $_" -ForegroundColor Red
    exit 1
}

# Validate teamsEnvironment section exists
if (-not $config.teamsEnvironment) {
    Write-Host "   ❌ Missing 'teamsEnvironment' section in configuration file" -ForegroundColor Red
    Write-Host "   💡 Run New-TeamsEnvironment.ps1 first to create Teams workspace" -ForegroundColor Yellow
    exit 1
}

Write-Host "   📋 Team: $($config.teamsEnvironment.teamName)" -ForegroundColor Cyan
Write-Host "   📁 Channels: $($config.teamsEnvironment.channels.Count)" -ForegroundColor Cyan
Write-Host ""

# Validate data-templates directory exists
$dataTemplatesPath = Join-Path $PSScriptRoot "..\data-templates"
if (-not (Test-Path $dataTemplatesPath)) {
    Write-Host "   ❌ Data templates directory not found: $dataTemplatesPath" -ForegroundColor Red
    Write-Host "   💡 Run Generate-TestData.ps1 first to create test files" -ForegroundColor Yellow
    exit 1
}

# Get list of test files
$testFiles = Get-ChildItem -Path $dataTemplatesPath -File
if ($testFiles.Count -eq 0) {
    Write-Host "   ❌ No test files found in: $dataTemplatesPath" -ForegroundColor Red
    Write-Host "   💡 Run Generate-TestData.ps1 first to create test files" -ForegroundColor Yellow
    exit 1
}

Write-Host "   ✅ Found $($testFiles.Count) test files available for upload" -ForegroundColor Green
Write-Host ""

# =============================================================================
# Step 2: Define Channel File Distribution
# =============================================================================

Write-Host "📁 Step 2: Channel File Distribution" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Define which files go to which channel based on content type
# Structure: @{ FileName = @{ PostAsMessage = $true/$false; MessageText = "text" } }
$channelFileDistribution = @{
    "Customer Data" = @{
        "Customer-Profile-Export.docx" = @{ PostAsMessage = $true; MessageText = "Customer profiles for Q4 review" };
        "Loyalty-Program-Members.docx" = @{ PostAsMessage = $true; MessageText = "Updated loyalty member list" };
        "SSN-Records.docx" = @{ PostAsMessage = $true; MessageText = "Employee records for verification" };
        "CustomerDatabase-FULL.xlsx" = @{ PostAsMessage = $false; MessageText = "" }
    };
    "Financial Reports" = @{
        "CreditCards-Only.xlsx" = @{ PostAsMessage = $true; MessageText = "Payment card data for audit" };
        "Payment-Processing-Report.pdf" = @{ PostAsMessage = $true; MessageText = "Monthly payment processing summary" };
        "Q4-Financial-Review.pptx" = @{ PostAsMessage = $false; MessageText = "" };
        "Banking-DirectDeposit.xlsx" = @{ PostAsMessage = $true; MessageText = "Direct deposit routing information" };
        "Retail-Financial-Data.xlsx" = @{ PostAsMessage = $true; MessageText = "Retail financial analysis data" }
    }
}

Write-Host "   ✅ File distribution configured for $($channelFileDistribution.Keys.Count) channels" -ForegroundColor Green
foreach ($channelName in $channelFileDistribution.Keys) {
    $fileCount = $channelFileDistribution[$channelName].Keys.Count
    $messageCount = ($channelFileDistribution[$channelName].Values | Where-Object { $_.PostAsMessage -eq $true }).Count
    Write-Host "      • $channelName : $fileCount files ($messageCount as messages)" -ForegroundColor Cyan
}
Write-Host ""

# =============================================================================
# Step 3: Authentication
# =============================================================================

Write-Host "🔐 Step 3: Authentication" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

# Load and execute authentication helper
$authScriptPath = Join-Path $PSScriptRoot "..\..\scripts\Connect-PurviewGraph.ps1"
if (Test-Path $authScriptPath) {
    Write-Host "   📂 Loading authentication helper..." -ForegroundColor Cyan
    Write-Host ""
    . $authScriptPath
    Write-Host ""
} else {
    Write-Host "   ❌ Authentication helper not found: $authScriptPath" -ForegroundColor Red
    throw "Connect-PurviewGraph.ps1 is required for authentication. Run 00-Prerequisites setup first."
}

# =============================================================================
# Step 4: Find Team and Channels
# =============================================================================

Write-Host "🔍 Step 4: Locating Team and Channels" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

try {
    Write-Host "   🔎 Searching for team: $($config.teamsEnvironment.teamName)" -ForegroundColor Cyan
    
    # Search for team by display name
    $team = Get-MgGroup -Filter "displayName eq '$($config.teamsEnvironment.teamName)' and resourceProvisioningOptions/Any(x:x eq 'Team')" -Property "Id,DisplayName" -ErrorAction Stop
    
    if (-not $team) {
        Write-Host "   ❌ Team not found: $($config.teamsEnvironment.teamName)" -ForegroundColor Red
        Write-Host "   💡 Run New-TeamsEnvironment.ps1 first to create the team" -ForegroundColor Yellow
        exit 1
    }
    
    # Handle both single object and array returns
    if ($team -is [array]) {
        $teamId = $team[0].Id
    } else {
        $teamId = $team.Id
    }
    
    Write-Host "   ✅ Found team: $($config.teamsEnvironment.teamName)" -ForegroundColor Green
    Write-Host "      Team ID: $teamId" -ForegroundColor Cyan
    
    # Get all channels in the team
    $channels = Get-MgTeamChannel -TeamId $teamId
    Write-Host "   ✅ Found $($channels.Count) channels" -ForegroundColor Green
    
    # Create channel ID lookup
    $channelLookup = @{}
    foreach ($channel in $channels) {
        $channelLookup[$channel.DisplayName] = $channel.Id
        Write-Host "      • $($channel.DisplayName)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "   ❌ Failed to locate team: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# =============================================================================
# Step 5: Get SharePoint Site for Team
# =============================================================================

Write-Host "🌐 Step 5: Locating Team SharePoint Site" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

try {
    # Get the team's SharePoint site URL
    $teamSite = Get-MgTeam -TeamId $teamId -Property "webUrl"
    
    if (-not $teamSite.WebUrl) {
        Write-Host "   ❌ Could not retrieve team SharePoint site URL" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "   ✅ Team SharePoint site located" -ForegroundColor Green
    Write-Host "      URL: $($teamSite.WebUrl)" -ForegroundColor Cyan
    
    # Get the group's drive (SharePoint document library)
    $groupDrives = Get-MgGroupDrive -GroupId $teamId -All
    
    if (-not $groupDrives -or $groupDrives.Count -eq 0) {
        Write-Host "   ❌ Could not locate team document library" -ForegroundColor Red
        exit 1
    }
    
    # Get the main drive ID - handle both single object and array
    if ($groupDrives -is [array]) {
        $driveId = $groupDrives[0].Id
    } else {
        $driveId = $groupDrives.Id
    }
    
    if (-not $driveId) {
        Write-Host "   ❌ Drive ID is empty or null" -ForegroundColor Red
        Write-Host "      Debug: GroupDrives count = $($groupDrives.Count)" -ForegroundColor Yellow
        Write-Host "      Debug: GroupDrives type = $($groupDrives.GetType().Name)" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "   ✅ Document library ready" -ForegroundColor Green
    Write-Host "      Drive ID: $driveId" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ Failed to locate SharePoint site: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# =============================================================================
# Step 6: User Authentication for Message Posting
# =============================================================================

Write-Host "👤 Step 6: User Authentication for Channel Messages" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "   📝 Service principals cannot post channel messages" -ForegroundColor Cyan
Write-Host "   🔐 Please sign in with your admin account (team member)" -ForegroundColor Cyan
Write-Host ""

try {
    # Disconnect service principal session first
    Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
    
    # Connect with user account for message posting
    # Requires ChannelMessage.Send permission (user-delegated)
    Connect-MgGraph -Scopes "ChannelMessage.Send", "Files.Read.All" -NoWelcome
    
    Write-Host "   ✅ User authentication successful" -ForegroundColor Green
    $userContext = Get-MgContext
    Write-Host "   👤 Signed in as: $($userContext.Account)" -ForegroundColor Gray
    
} catch {
    Write-Host "   ❌ User authentication failed: $_" -ForegroundColor Red
    Write-Host "   ⚠️  Files uploaded successfully, but messages cannot be posted" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# =============================================================================
# Step 7: Upload Files to Channels
# =============================================================================

Write-Host "📤 Step 7: Uploading Files to Channels" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

$uploadStats = @{
    TotalFiles = 0
    UploadedFiles = 0
    SkippedFiles = 0
    MessagesPosted = 0
    FailedFiles = 0
}

foreach ($channelName in $channelFileDistribution.Keys) {
    
    # Check if channel exists
    if (-not $channelLookup.ContainsKey($channelName)) {
        Write-Host "   ⚠️  Channel not found: $channelName (skipping)" -ForegroundColor Yellow
        continue
    }
    
    # Get the channel ID for message posting
    $channelId = $channelLookup[$channelName]
    
    $channConfig = $channelFileDistribution[$channelName]
    
    Write-Host "📁 Uploading to channel: $channelName" -ForegroundColor Cyan
    Write-Host "   Channel ID: $channelId" -ForegroundColor Gray
    
    # Get the channel folder in the document library
    # Channel folders are named after the channel in the "Shared Documents" library
    $channelFolderName = $channelName
    
    $channelUploadCount = 0
    $filesConfig = $channelFileDistribution[$channelName]
    
    foreach ($fileName in $filesConfig.Keys) {
        $fileConfig = $filesConfig[$fileName]
        $filePath = Join-Path $dataTemplatesPath $fileName
        
        if (-not (Test-Path $filePath)) {
            Write-Host "   ⚠️  $fileName (not found, skipping)" -ForegroundColor Yellow
            $uploadStats.SkippedFiles++
            continue
        }
        
        $uploadStats.TotalFiles++
        
        try {
            # Upload file to the channel folder in SharePoint
            # Path format: /teams/{channelName}/{fileName}
            $targetPath = "$channelFolderName/$fileName"
            
            Write-Host "   📤 Uploading: $fileName" -ForegroundColor Gray
            
            $fileAlreadyExists = $false
            try {
                $existingItem = Get-MgDriveItemByPath -DriveId $driveId -ItemPath $targetPath -ErrorAction Stop
                $fileAlreadyExists = $true
            } catch {
                # File doesn't exist, proceed with upload
            }
            
            if (-not $fileAlreadyExists) {
                # Upload the file using Microsoft Graph
                $fileSize = (Get-Item $filePath).Length
                if ($fileSize -lt 4MB) {
                    # Simple upload for small files
                    # Upload using PUT method with proper path format
                    $uploadResult = Set-MgDriveItemContent -DriveId $driveId -DriveItemId "root:/$targetPath`:" -InFile $filePath
                    $uploadStats.UploadedFiles++
                    $channelUploadCount++
                    
                } else {
                    # For larger files, use upload session (not implemented in this basic version)
                    Write-Host "      ⚠️  File too large for simple upload (>4MB), skipping" -ForegroundColor Yellow
                    $uploadStats.SkippedFiles++
                    continue
                }
            }
            
            # If configured to post as message, create a channel message with file attachment
            if ($fileConfig.PostAsMessage) {
                try {
                    # Get the uploaded file item to get its web URL and ID
                    # Use Get-MgDriveItem with path format: root:/path/to/file.ext
                    $uploadedItem = Get-MgDriveItem -DriveId $driveId -DriveItemId "root:/$targetPath"
                    
                    # Generate a unique attachment ID for this message
                    $attachmentId = [guid]::NewGuid().ToString()
                    
                    # Create channel message with file attachment
                    # Message will appear from the authenticated user account
                    $messageBody = @{
                        body = @{
                            contentType = "html"
                            content = "<p>$($fileConfig.MessageText)</p><p><attachment id=`"$attachmentId`"></attachment></p>"
                        }
                        attachments = @(
                            @{
                                id = $attachmentId
                                contentType = "reference"
                                contentUrl = $uploadedItem.WebUrl
                                name = $fileName
                            }
                        )
                    }
                    
                    # Post message to channel
                    New-MgTeamChannelMessage -TeamId $teamId -ChannelId $channelId -BodyParameter $messageBody -ErrorAction Stop | Out-Null
                    
                    if ($fileAlreadyExists) {
Write-Host "   📧 Messages Posted:  $($uploadStats.MessagesPosted)" -ForegroundColor Green
                        Write-Host "      ✅ $fileName (already uploaded, posted in channel)" -ForegroundColor Yellow
                    } else {
                        Write-Host "      ✅ $fileName (uploaded + posted in channel)" -ForegroundColor Green
                    }
                    $uploadStats.MessagesPosted++
                    
                } catch {
                    if ($fileAlreadyExists) {
                        Write-Host "      ⚠️  $fileName (already uploaded, message post failed)" -ForegroundColor Yellow
                    } else {
                        Write-Host "      ✅ $fileName (uploaded, message post failed)" -ForegroundColor Yellow
                    }
                    Write-Host "         Error: $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                # Just uploaded to Files tab without message
                if ($fileAlreadyExists) {
                    Write-Host "      ✅ $fileName (already in Files tab)" -ForegroundColor Yellow
                    $uploadStats.SkippedFiles++
                } else {
                    Write-Host "      ✅ $fileName (uploaded to Files tab)" -ForegroundColor Green
                    $uploadStats.UploadedFiles++
                }
            }
            $channelUploadCount++
            
        } catch {
            Write-Host "      ❌ $fileName (failed: $($_.Exception.Message))" -ForegroundColor Red
            $uploadStats.FailedFiles++
        }
    }
    
    Write-Host "   📊 Channel uploads: $channelUploadCount files" -ForegroundColor Cyan
    Write-Host ""
}

# =============================================================================
# Step 8: Upload Summary
# =============================================================================

Write-Host "📊 Step 8: Upload Summary" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""

Write-Host "📈 Teams Upload Statistics" -ForegroundColor Cyan
Write-Host "   Channels Processed:  $($channelFileDistribution.Keys.Count)" -ForegroundColor White
Write-Host "   Total Files:         $($uploadStats.TotalFiles)" -ForegroundColor White
Write-Host "   ✅ Uploaded:         $($uploadStats.UploadedFiles)" -ForegroundColor Green

if ($uploadStats.SkippedFiles -gt 0) {
    Write-Host "   ⚠️  Skipped:         $($uploadStats.SkippedFiles)" -ForegroundColor Yellow
}
if ($uploadStats.FailedFiles -gt 0) {
    Write-Host "   ❌ Failed:           $($uploadStats.FailedFiles)" -ForegroundColor Red
}
Write-Host ""

if ($uploadStats.UploadedFiles -gt 0) {
    Write-Host "✅ Teams file upload completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Verify files appear in Teams channels at teams.microsoft.com" -ForegroundColor White
    Write-Host "   2. Check Files tab in each channel" -ForegroundColor White
    Write-Host "   3. Wait 24-48 hours for Content Explorer classification" -ForegroundColor White
    Write-Host "   4. Test DLP policies on Teams file sharing and attachments" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "⚠️  No new files were uploaded" -ForegroundColor Yellow
    Write-Host "   💡 All files may already exist in Teams channels" -ForegroundColor Cyan
    Write-Host ""
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph | Out-Null

Write-Host "✅ Script completed!" -ForegroundColor Green
exit 0
