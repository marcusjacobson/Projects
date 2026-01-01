<#
.SYNOPSIS
    Step 1: Sets up the prerequisites for EDM Data Upload.
    - Checks for Administrator privileges.
    - Verifies EDM Upload Agent installation.
    - Creates 'EDM_DataUploaders' security group.
    - Adds current user to the group.

.DESCRIPTION
    This script ensures your environment is ready for EDM operations.
    It handles the security group requirement that often causes "UserNotInSecurityGroup" errors.
    
    REQUIRES:
    - Run as Administrator
    - Interactive User Sign-in (for Graph operations)

.NOTES
    Author: Marcus Jacobson
    Version: 2.0.0
    Created: 2025-12-28
#>

# 1. Check Admin Privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Error: Administrator privileges required." -ForegroundColor Red
    Write-Host "   The EDM Upload Agent requires Admin rights to manage its token cache." -ForegroundColor Gray
    Write-Host "   Please right-click PowerShell/VS Code and select 'Run as Administrator'." -ForegroundColor Yellow
    exit
}

Write-Host "🛡️ Step 1: EDM Prerequisites Setup" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# 2. Check EDM Agent
$agentPath = "C:\Program Files\Microsoft\EdmUploadAgent\EdmUploadAgent.exe"
if (-not (Test-Path $agentPath)) {
    Write-Host "❌ EDM Upload Agent not found at: $agentPath" -ForegroundColor Red
    Write-Host "   Please install it from: https://go.microsoft.com/fwlink/?linkid=2088739" -ForegroundColor Yellow
    exit
}
Write-Host "✅ EDM Upload Agent found." -ForegroundColor Green

# 3. Connect to Graph for Group Management
Write-Host "`n🔐 Connecting to Microsoft Graph (for Security Group setup)..." -ForegroundColor Yellow
try {
    Connect-MgGraph -Scopes "Group.ReadWrite.All", "User.Read.All", "Directory.Read.All" -ErrorAction Stop
}
catch {
    Write-Host "❌ Failed to connect to Microsoft Graph." -ForegroundColor Red
    Write-Host "   Ensure 'Microsoft.Graph' module is installed: Install-Module Microsoft.Graph -Scope CurrentUser" -ForegroundColor Gray
    exit
}

# 4. Get Current User
$context = Get-MgContext
$upn = $context.Account
$user = Get-MgUser -UserId $upn -ErrorAction SilentlyContinue
if (-not $user) { $user = Get-MgUser -Filter "UserPrincipalName eq '$upn'" -ErrorAction SilentlyContinue }

if (-not $user) {
    Write-Host "❌ Could not find user object for '$upn'." -ForegroundColor Red
    exit
}
Write-Host "👤 Current User: $($user.DisplayName) ($($user.UserPrincipalName))" -ForegroundColor Gray

# 5. Manage Security Group
$groupName = "EDM_DataUploaders"
$group = Get-MgGroup -Filter "DisplayName eq '$groupName'" -ErrorAction SilentlyContinue

if ($group) {
    Write-Host "✅ Group '$groupName' already exists." -ForegroundColor Green
}
else {
    Write-Host "⚙️ Creating group '$groupName'..." -ForegroundColor Yellow
    $group = New-MgGroup -BodyParameter @{
        DisplayName = $groupName
        MailEnabled = $false
        MailNickname = "EDM_DataUploaders"
        SecurityEnabled = $true
    }
    Write-Host "✅ Group created successfully." -ForegroundColor Green
}

# 6. Add User to Group
$isMember = Get-MgGroupMember -GroupId $group.Id -Filter "Id eq '$($user.Id)'" -ErrorAction SilentlyContinue
if ($isMember) {
    Write-Host "✅ User is already a member of '$groupName'." -ForegroundColor Green
}
else {
    Write-Host "➕ Adding user to '$groupName'..." -ForegroundColor Yellow
    New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
    Write-Host "✅ User added successfully." -ForegroundColor Green
}

# 7. Verify Access (Propagation Check)
Write-Host "`n🕵️  Verifying EDM Access (Propagation Check)..." -ForegroundColor Yellow
Write-Host "   We will attempt to authorize with the EDM Agent to confirm permissions." -ForegroundColor Gray
Write-Host "   A sign-in window may appear." -ForegroundColor Gray

$agentDir = "C:\Program Files\Microsoft\EdmUploadAgent"
Push-Location $agentDir

# Run Authorize. This is the definitive test for "UserNotInSecurityGroup".
& .\EdmUploadAgent.exe /Authorize

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Verification Successful!" -ForegroundColor Green
    Write-Host "   Your user is correctly recognized by the EDM service." -ForegroundColor Gray
    Write-Host "   You are ready to proceed to Step 2." -ForegroundColor Green
}
else {
    Write-Host "`n⏳ Verification Failed (Propagation Delay)" -ForegroundColor Yellow
    Write-Host "   The EDM service does not recognize your group membership yet." -ForegroundColor Gray
    Write-Host "   This is normal. Please wait 1-2 minutes and run this verification command:" -ForegroundColor Gray
    Write-Host "   & '$agentDir\EdmUploadAgent.exe' /Authorize" -ForegroundColor White
    Write-Host "`n   Repeat until you see 'Command executed successfully'." -ForegroundColor Gray
}

Pop-Location
Write-Host "`n✅ Step 1 Complete." -ForegroundColor Green
