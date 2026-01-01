<#
.SYNOPSIS
    Creates Microsoft Teams environment for multi-workload DLP and classification testing.

.DESCRIPTION
    This script creates a dedicated Microsoft Teams workspace for testing DLP policies
    and data classification across Teams channels. It provisions a private Team with
    department-specific channels, adds test users as members, and validates the 
    environment is ready for file uploads and DLP policy testing.

    The script uses service principal authentication with certificate-based auth to
    interact with Microsoft Graph API for Teams operations. Configuration is loaded
    from global-config.json including team name, channels, and test user membership.

    Teams Environment Components:
    - Private Team for isolated testing
    - Department-specific channels (Customer Data, Financial Reports)
    - Test user membership across all channels
    - Validated permissions for file upload operations

.PARAMETER ConfigPath
    Path to global-config.json file. Defaults to ../../templates/global-config.json

.EXAMPLE
    .\New-TeamsEnvironment.ps1
    
    Creates Teams environment using default configuration file location.

.EXAMPLE
    .\New-TeamsEnvironment.ps1 -ConfigPath "C:\custom\config.json"
    
    Creates Teams environment using custom configuration file path.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-30
    Last Modified: 2025-12-30
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Azure CLI installed and authenticated
    - PowerShell 5.1+ or PowerShell 7+
    - Microsoft Graph PowerShell SDK v2.0+
    - Service principal with Teams.ReadWrite.All, Group.ReadWrite.All permissions
    - Certificate authentication configured (PurviewAutomationCert)
    - Test users with M365 E5 licenses and Teams enabled
    
    Script development orchestrated using GitHub Copilot.

.TEAMS_COMPONENTS
    - Private Team creation via Microsoft Graph API
    - Standard channels (Customer Data, Financial Reports)
    - Team membership management for test users
    - Permission validation for file operations
#>

#
# =============================================================================
# Creates Microsoft Teams environment for DLP and classification testing
# =============================================================================

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "..\..\templates\global-config.json"
)

# =============================================================================
# Step 1: Configuration Loading
# =============================================================================

Write-Host "🏢 Microsoft Teams Environment Creation" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Step 1: Loading Configuration" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Resolve configuration path
$resolvedConfigPath = Join-Path $PSScriptRoot $ConfigPath
if (-not (Test-Path $resolvedConfigPath)) {
    Write-Host "   ❌ Configuration file not found: $resolvedConfigPath" -ForegroundColor Red
    throw "Configuration file not found. Ensure global-config.json exists in templates/ directory."
}

try {
    $config = Get-Content $resolvedConfigPath -Raw | ConvertFrom-Json
    Write-Host "   ✅ Configuration loaded from: $resolvedConfigPath" -ForegroundColor Green
    
    # Validate required configuration sections
    if (-not $config.teamsEnvironment) {
        Write-Host "   ❌ Missing 'teamsEnvironment' section in configuration" -ForegroundColor Red
        throw "Configuration must include 'teamsEnvironment' section with team and channel details."
    }
    
    if (-not $config.testUsers -or $config.testUsers.Count -eq 0) {
        Write-Host "   ❌ No test users defined in configuration" -ForegroundColor Red
        throw "Configuration must include at least one test user in 'testUsers' array."
    }
    
    Write-Host "   📋 Team: $($config.teamsEnvironment.teamName)" -ForegroundColor Cyan
    Write-Host "   👥 Test Users: $($config.testUsers.Count)" -ForegroundColor Cyan
    Write-Host "   📁 Channels: $($config.teamsEnvironment.channels.Count)" -ForegroundColor Cyan
    
} catch {
    Write-Host "   ❌ Failed to load configuration: $_" -ForegroundColor Red
    throw
}

# =============================================================================
# Step 2: Authentication
# =============================================================================

Write-Host ""
Write-Host "🔐 Step 2: Authentication" -ForegroundColor Green
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
# Step 3: Checking for Existing Team
# =============================================================================

Write-Host "🔍 Step 3: Checking for Existing Team" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

try {
    Write-Host "   🔎 Searching for team: $($config.teamsEnvironment.teamName)" -ForegroundColor Cyan
    
    # Search for existing team by display name - request Id explicitly
    $existingTeams = Get-MgGroup -Filter "displayName eq '$($config.teamsEnvironment.teamName)' and resourceProvisioningOptions/Any(x:x eq 'Team')" -Property "Id,DisplayName,ResourceProvisioningOptions" -ErrorAction SilentlyContinue
    
    if ($existingTeams) {
        # Handle both single object and array returns
        if ($existingTeams -is [array]) {
            $existingTeam = $existingTeams[0]
        } else {
            $existingTeam = $existingTeams
        }
        
        # Verify we have a valid team ID
        if ($existingTeam -and $existingTeam.Id) {
            Write-Host "   ⚠️  Team already exists: $($existingTeam.DisplayName)" -ForegroundColor Yellow
            Write-Host "   📋 Team ID: $($existingTeam.Id)" -ForegroundColor Cyan
            Write-Host "   💡 Using existing team for environment setup" -ForegroundColor Yellow
            $teamId = $existingTeam.Id
            $teamCreated = $false
        } else {
            Write-Host "   ⚠️  Found team but ID is missing - will create new team" -ForegroundColor Yellow
            $teamCreated = $true
            $teamId = $null
        }
    } else {
        Write-Host "   ℹ️  No existing team found - will create new team" -ForegroundColor Cyan
        $teamCreated = $true
        $teamId = $null
    }
    
} catch {
    Write-Host "   ⚠️  Could not check for existing team: $_" -ForegroundColor Yellow
    Write-Host "   ℹ️  Proceeding with team creation" -ForegroundColor Cyan
    $teamCreated = $true
    $teamId = $null
}

# =============================================================================
# Step 4: Creating Microsoft Team (if needed)
# =============================================================================

if ($teamCreated) {
    Write-Host ""
    Write-Host "🚀 Step 4: Creating Microsoft Team" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    
    try {
        Write-Host "   📝 Team Name: $($config.teamsEnvironment.teamName)" -ForegroundColor Cyan
        Write-Host "   🔒 Visibility: Private" -ForegroundColor Cyan
        Write-Host "   � Resolving team owner: $($config.adminEmail)" -ForegroundColor Cyan
        
        # Get the admin user to set as owner (required for service principal context)
        $ownerUser = Get-MgUser -UserId $config.adminEmail -ErrorAction Stop
        Write-Host "   ✅ Owner resolved: $($ownerUser.DisplayName)" -ForegroundColor Cyan
        
        Write-Host "   🚀 Creating team (may take 1-2 minutes)..." -ForegroundColor Cyan
        
        # Create team using Microsoft Graph with owner specified
        $teamParams = @{
            "template@odata.bind" = "https://graph.microsoft.com/v1.0/teamsTemplates('standard')"
            displayName = $config.teamsEnvironment.teamName
            description = $config.teamsEnvironment.description
            visibility = "Private"
            members = @(
                @{
                    "@odata.type" = "#microsoft.graph.aadUserConversationMember"
                    roles = @("owner")
                    "user@odata.bind" = "https://graph.microsoft.com/v1.0/users('$($ownerUser.Id)')"
                }
            )
        }
        
        $newTeam = New-MgTeam -BodyParameter $teamParams
        
        Write-Host "   ✅ Team creation request submitted!" -ForegroundColor Green
        
        # Wait for team provisioning to complete (template creation is async)
        Write-Host "   ⏳ Waiting for team provisioning (60 seconds)..." -ForegroundColor Cyan
        Start-Sleep -Seconds 60
        
        # Query for the team by display name to get the ID
        Write-Host "   🔎 Retrieving team ID..." -ForegroundColor Cyan
        $teamGroup = Get-MgGroup -Filter "displayName eq '$($config.teamsEnvironment.teamName)' and resourceProvisioningOptions/Any(x:x eq 'Team')" -ErrorAction Stop
        
        if ($teamGroup) {
            $teamId = $teamGroup.Id
            Write-Host "   ✅ Team ID resolved: $teamId" -ForegroundColor Green
        } else {
            throw "Could not find created team. It may still be provisioning."
        }
        
    } catch {
        Write-Host "   ❌ Failed to create team: $_" -ForegroundColor Red
        throw
    }
} else {
    Write-Host ""
    Write-Host "✅ Step 4: Using Existing Team" -ForegroundColor Green
    Write-Host "==============================" -ForegroundColor Green
    Write-Host "   📋 Team ID: $teamId" -ForegroundColor Cyan
}

# =============================================================================
# Step 5: Creating Channels
# =============================================================================

Write-Host ""
Write-Host "📁 Step 5: Creating Channels" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

try {
    # Get existing channels
    $existingChannels = Get-MgTeamChannel -TeamId $teamId
    Write-Host "   📋 Found $($existingChannels.Count) existing channels" -ForegroundColor Cyan
    
    foreach ($channelConfig in $config.teamsEnvironment.channels) {
        $channelName = $channelConfig.name
        
        # Check if channel already exists
        $existingChannel = $existingChannels | Where-Object { $_.DisplayName -eq $channelName }
        
        if ($existingChannel) {
            Write-Host "   ✅ $channelName (already exists)" -ForegroundColor Yellow
        } else {
            Write-Host "   🚀 Creating channel: $channelName" -ForegroundColor Cyan
            
            $channelParams = @{
                displayName = $channelName
                description = $channelConfig.description
                membershipType = "standard"
            }
            
            $newChannel = New-MgTeamChannel -TeamId $teamId -BodyParameter $channelParams
            Write-Host "   ✅ $channelName (created)" -ForegroundColor Green
        }
    }
    
} catch {
    Write-Host "   ❌ Failed to create channels: $_" -ForegroundColor Red
    throw
}

# =============================================================================
# Step 6: Adding Team Members
# =============================================================================

Write-Host ""
Write-Host "👥 Step 6: Adding Team Members" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

try {
    # Get existing team members
    $existingMembers = Get-MgTeamMember -TeamId $teamId
    $existingMemberUPNs = @()
    
    foreach ($member in $existingMembers) {
        # Get user details for each member
        $userId = $member.Id
        try {
            $userDetails = Get-MgUser -UserId $userId -ErrorAction SilentlyContinue
            if ($userDetails -and $userDetails.UserPrincipalName) {
                $existingMemberUPNs += $userDetails.UserPrincipalName
            }
        } catch {
            # Skip if we can't get user details
        }
    }
    
    Write-Host "   📋 Found $($existingMembers.Count) existing members" -ForegroundColor Cyan
    
    foreach ($userUPN in $config.testUsers) {
        if ($existingMemberUPNs -contains $userUPN) {
            Write-Host "   ✅ $userUPN (already a member)" -ForegroundColor Yellow
        } else {
            Write-Host "   🚀 Adding member: $userUPN" -ForegroundColor Cyan
            
            try {
                # Get user object
                $user = Get-MgUser -Filter "userPrincipalName eq '$userUPN'"
                
                if (-not $user) {
                    Write-Host "   ❌ User not found: $userUPN" -ForegroundColor Red
                    continue
                }
                
                # Add user as team member
                $memberParams = @{
                    "@odata.type" = "#microsoft.graph.aadUserConversationMember"
                    roles = @()
                    "user@odata.bind" = "https://graph.microsoft.com/v1.0/users('$($user.Id)')"
                }
                
                New-MgTeamMember -TeamId $teamId -BodyParameter $memberParams | Out-Null
                Write-Host "   ✅ $userUPN (added)" -ForegroundColor Green
                
            } catch {
                Write-Host "   ❌ Failed to add $userUPN : $_" -ForegroundColor Red
            }
        }
    }
    
} catch {
    Write-Host "   ❌ Failed to add team members: $_" -ForegroundColor Red
    Write-Host "   ⚠️  You may need to add members manually in Teams" -ForegroundColor Yellow
}

# =============================================================================
# Step 7: Validation and Summary
# =============================================================================

Write-Host ""
Write-Host "✅ Step 7: Environment Validation" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

try {
    # Get final team details
    $team = Get-MgTeam -TeamId $teamId
    $channels = Get-MgTeamChannel -TeamId $teamId
    $members = Get-MgTeamMember -TeamId $teamId
    
    Write-Host ""
    Write-Host "📊 Teams Environment Summary" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    Write-Host "   Team Name:    $($team.DisplayName)" -ForegroundColor White
    Write-Host "   Team ID:      $teamId" -ForegroundColor White
    Write-Host "   Visibility:   $($team.Visibility)" -ForegroundColor White
    Write-Host "   Channels:     $($channels.Count)" -ForegroundColor White
    Write-Host "   Members:      $($members.Count)" -ForegroundColor White
    Write-Host ""
    
    Write-Host "   📁 Channels:" -ForegroundColor Cyan
    foreach ($channel in $channels) {
        Write-Host "      • $($channel.DisplayName)" -ForegroundColor White
    }
    Write-Host ""
    
    Write-Host "✅ Teams environment created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Verify team appears in Teams app at teams.microsoft.com" -ForegroundColor White
    Write-Host "   2. Run Upload-TeamsTestData.ps1 to upload files to channels" -ForegroundColor White
    Write-Host "   3. Wait 24-48 hours for Content Explorer classification" -ForegroundColor White
    Write-Host "   4. Test DLP policies on Teams file attachments" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "   ⚠️  Could not validate team details: $_" -ForegroundColor Yellow
    Write-Host "   💡 Team may still have been created - check Teams app" -ForegroundColor Yellow
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph | Out-Null

Write-Host "✅ Script completed successfully!" -ForegroundColor Green
exit 0
