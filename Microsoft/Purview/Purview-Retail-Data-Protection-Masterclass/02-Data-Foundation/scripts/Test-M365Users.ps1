<#
.SYNOPSIS
    Validates test users from global-config.json for M365 multi-workload testing.

.DESCRIPTION
    This script validates that the test users defined in global-config.json:
    - Exist in Microsoft Entra ID
    - Have M365 E5 or E5 Compliance licenses assigned
    - Have OneDrive provisioned (or can be provisioned)
    - Have Teams enabled
    - Meet the requirements for OneDrive and Teams file upload testing

.PARAMETER ConfigPath
    Path to the global-config.json file. Defaults to templates/global-config.json.

.EXAMPLE
    .\Test-M365Users.ps1
    
    Validates all test users using the default configuration file.

.EXAMPLE
    .\Test-M365Users.ps1 -ConfigPath "C:\custom\config.json"
    
    Validates users using a custom configuration file path.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: 2025-12-30
    Last Modified: 2025-12-30
    
    Copyright (c) 2025 Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Microsoft Graph PowerShell SDK (Microsoft.Graph.Users, Microsoft.Graph.Identity.DirectoryManagement)
    - Global Reader or User Administrator role
    - Service Principal with User.Read.All permissions
    
    Script development orchestrated using GitHub Copilot.

.VALIDATION CHECKS
    - User existence in Entra ID
    - M365 E5/E5 Compliance license assignment
    - OneDrive provisioning status
    - Teams enablement
    - Exchange Online mailbox status
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = "$PSScriptRoot\..\..\templates\global-config.json"
)

# =============================================================================
# Step 1: Load Configuration and Connect to Microsoft Graph
# =============================================================================

Write-Host "🔍 Validating Test Users from Configuration" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# Load configuration
if (-not (Test-Path $ConfigPath)) {
    Write-Host "❌ Configuration file not found: $ConfigPath" -ForegroundColor Red
    exit 1
}

try {
    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    Write-Host "✅ Configuration loaded from: $ConfigPath" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to parse configuration file: $_" -ForegroundColor Red
    exit 1
}

# Validate testUsers section exists
if (-not $config.testUsers -or $config.testUsers.Count -eq 0) {
    Write-Host "❌ No test users defined in configuration file" -ForegroundColor Red
    Write-Host "   Add a 'testUsers' array to global-config.json with user UPNs" -ForegroundColor Yellow
    Write-Host "   Example: `"testUsers`": [`"user1@domain.com`", `"user2@domain.com`"]" -ForegroundColor Yellow
    Write-Host "   See 00-Prerequisites/User-Setup-Guide.md for guidance" -ForegroundColor Yellow
    exit 1
}

Write-Host "   📋 Found $($config.testUsers.Count) users to validate" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# Step 2: Connect to Microsoft Graph
# =============================================================================

# Use the centralized connection helper script
$connectScript = Join-Path $PSScriptRoot "..\..\scripts\Connect-PurviewGraph.ps1"

if (-not (Test-Path $connectScript)) {
    Write-Host "❌ Connection helper script not found: $connectScript" -ForegroundColor Red
    Write-Host "   Ensure the project structure is intact" -ForegroundColor Yellow
    exit 1
}

try {
    & $connectScript
    Write-Host ""
} catch {
    Write-Host "❌ Failed to establish Graph connection: $_" -ForegroundColor Red
    exit 1
}

# =============================================================================
# Step 3: Validate Each Test User
# =============================================================================

$validationResults = @()
$validUsers = 0
$warningUsers = 0
$failedUsers = 0

foreach ($upn in $config.testUsers) {
    Write-Host "🔍 Validating: $upn" -ForegroundColor Cyan
    
    $result = @{
        UPN = $upn
        DisplayName = ""
        Department = ""
        Exists = $false
        Licensed = $false
        LicenseName = ""
        OneDriveProvisioned = $false
        TeamsEnabled = $false
        ExchangeEnabled = $false
        Status = "Unknown"
        Issues = @()
    }
    
    try {
        # Check if user exists and get their details
        $user = Get-MgUser -UserId $upn -Property Id,DisplayName,UserPrincipalName,AssignedLicenses,Department,Mail -ErrorAction Stop
        $result.Exists = $true
        $result.DisplayName = $user.DisplayName
        $result.Department = $user.Department
        
        # Check license assignment
        if ($user.AssignedLicenses.Count -gt 0) {
            $result.Licensed = $true
            
            # Get license details
            $licenses = Get-MgUserLicenseDetail -UserId $upn
            $e5License = $licenses | Where-Object {
                $_.SkuPartNumber -match "SPE_E5|ENTERPRISEPREMIUM|M365_E5_COMPLIANCE|DEVELOPERPACK_E5"
            } | Select-Object -First 1
            
            if ($e5License) {
                $result.LicenseName = $e5License.SkuPartNumber
                
                # Check for required service plans
                $servicePlans = $e5License.ServicePlans
                
                # OneDrive
                $oneDrivePlan = $servicePlans | Where-Object {
                    $_.ServicePlanName -match "SHAREPOINTWAC|SHAREPOINTENTERPRISE" -and $_.ProvisioningStatus -eq "Success"
                }
                $result.OneDriveProvisioned = $null -ne $oneDrivePlan
                
                # Teams
                $teamsPlan = $servicePlans | Where-Object {
                    $_.ServicePlanName -match "TEAMS" -and $_.ProvisioningStatus -eq "Success"
                }
                $result.TeamsEnabled = $null -ne $teamsPlan
                
                # Exchange
                $exchangePlan = $servicePlans | Where-Object {
                    $_.ServicePlanName -match "EXCHANGE" -and $_.ProvisioningStatus -eq "Success"
                }
                $result.ExchangeEnabled = $null -ne $exchangePlan
                
            } else {
                $result.Issues += "No M365 E5 or E5 Compliance license found"
                $result.LicenseName = "Other (not E5)"
            }
        } else {
            $result.Issues += "No licenses assigned"
        }
        
        # Determine overall status
        if ($result.Licensed -and $result.OneDriveProvisioned -and $result.TeamsEnabled -and $result.ExchangeEnabled) {
            $result.Status = "Ready"
            $validUsers++
            Write-Host "   ✅ User is ready for multi-workload testing" -ForegroundColor Green
        } elseif ($result.Licensed) {
            $result.Status = "Warning"
            $warningUsers++
            Write-Host "   ⚠️  User is licensed but some services may need initialization" -ForegroundColor Yellow
        } else {
            $result.Status = "Failed"
            $failedUsers++
            Write-Host "   ❌ User is not properly licensed" -ForegroundColor Red
        }
        
        # Display details
        Write-Host "      � Display Name: $($result.DisplayName)" -ForegroundColor Gray
        if ($result.Department) {
            Write-Host "      🏢 Department: $($result.Department)" -ForegroundColor Gray
        } else {
            Write-Host "      🏢 Department: Not set" -ForegroundColor Yellow
        }
        Write-Host "      �📧 Licensed: $($result.LicenseName)" -ForegroundColor Gray
        if ($result.OneDriveProvisioned) {
            Write-Host "      📁 OneDrive: Provisioned" -ForegroundColor Gray
        } else {
            Write-Host "      📁 OneDrive: Not yet provisioned (will auto-provision on first access)" -ForegroundColor Yellow
        }
        if ($result.TeamsEnabled) {
            Write-Host "      👥 Teams: Enabled" -ForegroundColor Gray
        } else {
            Write-Host "      👥 Teams: Not enabled" -ForegroundColor Red
        }
        if ($result.ExchangeEnabled) {
            Write-Host "      📧 Exchange: Enabled" -ForegroundColor Gray
        } else {
            Write-Host "      📧 Exchange: Not enabled" -ForegroundColor Red
        }
        
        # Display issues
        if ($result.Issues.Count -gt 0) {
            foreach ($issue in $result.Issues) {
                Write-Host "      ⚠️  $issue" -ForegroundColor Yellow
            }
        }
        
    } catch {
        $result.Status = "Failed"
        $result.Issues += "User not found in Entra ID: $_"
        $failedUsers++
        Write-Host "   ❌ User not found in Entra ID" -ForegroundColor Red
    }
    
    $validationResults += $result
    Write-Host ""
}

# =============================================================================
# Step 3: Display Summary and Recommendations
# =============================================================================

Write-Host "📊 Validation Summary" -ForegroundColor Green
Write-Host "====================" -ForegroundColor Green
Write-Host "   Total Users:    $($config.testUsers.Count)" -ForegroundColor Cyan
Write-Host "   ✅ Ready:       $validUsers" -ForegroundColor Green
Write-Host "   ⚠️  Warnings:    $warningUsers" -ForegroundColor Yellow
Write-Host "   ❌ Failed:      $failedUsers" -ForegroundColor Red
Write-Host ""

if ($failedUsers -gt 0) {
    Write-Host "⚠️  Some users require attention before proceeding" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Recommended Actions:" -ForegroundColor Cyan
    Write-Host "   1. Review failed users above" -ForegroundColor White
    Write-Host "   2. Assign M365 E5 or E5 Compliance licenses in Entra admin center" -ForegroundColor White
    Write-Host "   3. Wait 5-15 minutes for license provisioning" -ForegroundColor White
    Write-Host "   4. Re-run this validation script" -ForegroundColor White
    Write-Host ""
    Write-Host "See: 00-Prerequisites/User-Setup-Guide.md for detailed instructions" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

if ($warningUsers -gt 0) {
    Write-Host "💡 Users with warnings can still be used for testing" -ForegroundColor Cyan
    Write-Host "   OneDrive/Teams services will auto-provision on first Graph API access" -ForegroundColor White
    Write-Host "   Or have users sign in to office.com once to initialize services" -ForegroundColor White
    Write-Host ""
}

Write-Host "✅ All users are ready for multi-workload testing!" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Run Generate-TestData.ps1 (if not already done)" -ForegroundColor White
Write-Host "   2. Run Upload-OneDriveTestData.ps1 to upload files to user OneDrive accounts" -ForegroundColor White
Write-Host "   3. Run New-TeamsEnvironment.ps1 to create Teams workspace" -ForegroundColor White
Write-Host "   4. Run Upload-TeamsTestData.ps1 to upload files to Teams channels" -ForegroundColor White
Write-Host ""

# Disconnect from Graph
Disconnect-MgGraph | Out-Null

exit 0
