<#
.SYNOPSIS
    Configures PIM for Groups.

.DESCRIPTION
    Assigns 'Exchange Administrator' role to 'GRP-SEC-IT'.
    Demonstrates how to use a group for role assignment.
    Note: Configuring 'Eligible' membership for the group itself (PIM for Groups) 
    often requires Beta endpoints. This script sets up the foundation.

.EXAMPLE
    .\Configure-PIM-Groups.ps1

.NOTES
    Project: Entra-Zero-Trust-RBAC-Simulation
    Module: 04-RBAC-and-PIM
#>

[CmdletBinding()]
param()

process {
    . "$PSScriptRoot\..\..\00-Prerequisites-and-Monitoring\scripts\Connect-EntraGraph.ps1"

    Write-Host "🚀 Configuring PIM for Groups..." -ForegroundColor Cyan

    # 1. Get Group and Role
    $groupName = "GRP-SEC-IT"
    $group = Get-MgGroup -Filter "DisplayName eq '$groupName'" -ErrorAction Stop
    
    $roleName = "Exchange Administrator"
    $role = Get-MgDirectoryRole -Filter "DisplayName eq '$roleName'" -ErrorAction SilentlyContinue
    if (-not $role) {
        $template = Get-MgDirectoryRoleTemplate -Filter "DisplayName eq '$roleName'"
        $role = New-MgDirectoryRole -RoleTemplateId $template.Id
    }

    # 2. Assign Role to Group (Active Assignment)
    # We use PIM (RoleAssignmentScheduleRequest) to assign it, so it's managed by PIM.
    # We assign it as "Permanent Active" so the group always has the permission, 
    # but users will activate their membership into the group.
    
    try {
        $params = @{
            Action = "adminAssign"
            Justification = "PIM for Groups Setup"
            RoleId = $role.TemplateId # PIM uses TemplateId usually
            DirectoryScopeId = "/"
            PrincipalId = $group.Id
            ScheduleInfo = @{
                StartDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
                Expiration = @{
                    Type = "NoExpiration"
                }
            }
            AssignmentType = "Assigned" # Active
        }

        New-MgRoleManagementDirectoryRoleAssignmentScheduleRequest -BodyParameter $params
        Write-Host "   ✅ Assigned '$roleName' to '$groupName' (Active)." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to assign role to group: $_"
    }

    # 3. Instructions for PIM for Groups (Member Eligibility)
    Write-Host "`nℹ️  PIM for Groups Configuration:" -ForegroundColor Cyan
    Write-Host "   The group '$groupName' now has the '$roleName' role."
    Write-Host "   To complete the setup (make users eligible to join the group):"
    Write-Host "   1. Go to Entra Admin Center > Identity Governance > PIM > Groups"
    Write-Host "   2. Select '$groupName'"
    Write-Host "   3. Add 'USR-IT-Admin' as an 'Eligible' member."
    Write-Host "   (This step requires P2 and is best done in the portal for this simulation)" -ForegroundColor Yellow
}
