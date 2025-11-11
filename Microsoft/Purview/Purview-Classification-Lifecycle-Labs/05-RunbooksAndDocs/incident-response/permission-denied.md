# Incident Response Runbook: Permission Denied

## Document Information

**Severity**: High  
**Estimated Resolution Time**: 20-40 minutes  
**Required Permissions**: Global Administrator, SharePoint Administrator, Exchange Administrator  
**Last Updated**: 2025-11-11

## Purpose

This runbook provides procedures for diagnosing and resolving permission-related errors in Microsoft Purview operations. Use this when scripts report permission errors, users cannot access classified content, or administrative operations fail due to insufficient permissions.

## Symptoms

Common indicators of permission issues:

- Error messages containing "Access is denied" or "Unauthorized".
- PowerShell commands fail with 403 (Forbidden) HTTP status.
- Service principal authentication failures.
- Users report inability to view or modify classified documents.
- DLP policy operations fail with permission errors.
- Exchange Online cmdlets return "You don't have sufficient permissions".

**Impact Assessment**:

- **Service**: Classification and labeling operations blocked.
- **Users**: Cannot perform authorized actions on content.
- **Data**: Administrative operations cannot execute.

## Investigation Steps

### Step 1: Identify Permission Scope

Determine which service or resource is denying permissions.

**Check Error Message Details:**

```powershell
# Review recent logs for permission errors
Get-Content ".\logs\*.log" -Tail 200 | Select-String -Pattern "denied|unauthorized|403|forbidden" -Context 2,2
```

**Common Permission Scopes**:

| Error Pattern | Affected Service | Required Role |
|---------------|------------------|---------------|
| "Access to site is denied" | SharePoint Online | Site Collection Admin |
| "You don't have sufficient permissions" | Exchange Online | Compliance Administrator |
| "Unauthorized to perform operation" | Microsoft Graph API | Application permissions |
| "Access to resource is forbidden" | Azure AD | Global Administrator |

### Step 2: Verify Account Permissions

Check the account's actual permissions against requirements.

**SharePoint Site Permissions:**

```powershell
# Connect to SharePoint
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/YourSite" -Interactive

# Check current user's permissions
Get-PnPSiteCollectionAdmin
Get-PnPGroup | Select-Object Title, @{Name="Members";Expression={(Get-PnPGroupMember -Group $_.Title).Email -join ", "}}
```

**Exchange Online Roles:**

```powershell
# Connect to Exchange Online
Connect-ExchangeOnline

# Check current user's admin roles
Get-ManagementRoleAssignment -RoleAssignee "user@yourtenant.onmicrosoft.com" | Select-Object Role, RoleAssigneeType
```

**Azure AD Roles:**

```powershell
# Connect to Azure AD
Connect-AzureAD

# Check user's directory roles
$user = Get-AzureADUser -ObjectId "user@yourtenant.onmicrosoft.com"
Get-AzureADDirectoryRole | ForEach-Object {
    $role = $_
    Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Where-Object { $_.ObjectId -eq $user.ObjectId } | Select-Object @{Name="Role";Expression={$role.DisplayName}}
}
```

### Step 3: Test Service Principal Permissions (If Applicable)

For automation using service principals, validate app permissions.

**Check App Registration Permissions:**

Navigate to Azure Portal app registration.

- Go to [portal.azure.com](https://portal.azure.com).
- Navigate to **Azure Active Directory** → **App registrations**.
- Find your app registration.
- Click **API permissions**.

Verify required permissions are granted.

- Confirm permissions include required scopes (e.g., `Sites.ReadWrite.All`, `InformationProtectionPolicy.Read`).
- Check **Status** column shows **Granted for [tenant]**.
- If not granted, admin consent required.

**Test Service Principal Authentication:**

```powershell
# Test certificate-based authentication
$certThumbprint = "YOUR_CERT_THUMBPRINT"
$appId = "YOUR_APP_ID"
$tenantId = "YOUR_TENANT_ID"

Connect-PnPOnline -Url "https://yourtenant.sharepoint.com" -ClientId $appId -Tenant $tenantId -Thumbprint $certThumbprint

# Verify connection successful
$web = Get-PnPWeb
Write-Host "Successfully connected to: $($web.Title)" -ForegroundColor Green
```

### Step 4: Check User Access to Classified Content

For user-reported issues, verify actual file permissions.

**Navigate to SharePoint document:**

- Open the document's SharePoint location.
- Hover over document name, click **...** (three dots).
- Select **Manage access**.
- Review **Who has access** section.

**Verify Sensitivity Label Permissions:**

```powershell
# Get document with labels
$file = Get-PnPFile -Url "Shared Documents/sensitive-file.docx" -AsListItem

# Check sensitivity label (if applied)
$labelProperty = $file.FieldValues["_ComplianceTag"]
Write-Host "Applied Label: $labelProperty"

# Get label details
Connect-IPPSSession
Get-Label -Identity $labelProperty | Select-Object DisplayName, ContentType, LabelActions
```

### Step 5: Validate Permission Inheritance

Check if permission issues stem from broken inheritance.

**Check SharePoint Inheritance:**

```powershell
# Connect to site
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/YourSite" -Interactive

# Check if list has unique permissions
$list = Get-PnPList -Identity "Documents"
$list.HasUniqueRoleAssignments  # True = unique permissions (inheritance broken)

# Check specific item
$item = Get-PnPListItem -List "Documents" -Id 1
$item.HasUniqueRoleAssignments
```

**Expected Result**: Inheritance should typically be $false unless intentionally broken.

## Resolution Procedures

### Resolution Step 1: Grant SharePoint Site Permissions

Add appropriate permissions to SharePoint sites.

**Using PowerShell:**

```powershell
# Connect to SharePoint Admin Center
Connect-PnPOnline -Url "https://yourtenant-admin.sharepoint.com" -Interactive

# Add Site Collection Administrator
Set-PnPTenantSite -Url "https://yourtenant.sharepoint.com/sites/YourSite" -Owners "user@yourtenant.onmicrosoft.com"

# OR add to site members group
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/YourSite" -Interactive
Add-PnPGroupMember -LoginName "user@yourtenant.onmicrosoft.com" -Group "YourSite Members"
```

**Validation:**

```powershell
# Verify permission added
Get-PnPSiteCollectionAdmin
# OR
Get-PnPGroupMember -Group "YourSite Members"
```

### Resolution Step 2: Assign Exchange Online Admin Roles

Grant required administrative roles in Exchange Online.

**Using PowerShell:**

```powershell
# Connect to Exchange Online
Connect-ExchangeOnline

# Add user to Compliance Administrator role
Add-RoleGroupMember -Identity "Compliance Administrator" -Member "user@yourtenant.onmicrosoft.com"

# OR create custom role assignment
New-ManagementRoleAssignment -Role "Information Protection Admin" -User "user@yourtenant.onmicrosoft.com"
```

**Validation:**

```powershell
# Verify role assignment
Get-RoleGroupMember -Identity "Compliance Administrator"
```

**Expected Result**: User appears in role group members list.

### Resolution Step 3: Grant Azure AD Directory Roles

Assign Azure AD administrative roles for tenant-level operations.

**Using Azure Portal:**

Navigate to Azure AD role assignment.

- Go to [portal.azure.com](https://portal.azure.com).
- Navigate to **Azure Active Directory** → **Roles and administrators**.
- Search for required role (e.g., "Compliance Administrator").
- Click the role name.
- Click **+ Add assignments**.

Add user to role.

- Search for user email address.
- Select user from results.
- Click **Add**.

**Using PowerShell:**

```powershell
# Connect to Azure AD
Connect-AzureAD

# Get the role template
$role = Get-AzureADDirectoryRole | Where-Object { $_.DisplayName -eq "Compliance Administrator" }

# If role not activated, activate it first
if (-not $role) {
    $roleTemplate = Get-AzureADDirectoryRoleTemplate | Where-Object { $_.DisplayName -eq "Compliance Administrator" }
    Enable-AzureADDirectoryRole -RoleTemplateId $roleTemplate.ObjectId
    $role = Get-AzureADDirectoryRole | Where-Object { $_.DisplayName -eq "Compliance Administrator" }
}

# Add user to role
$user = Get-AzureADUser -ObjectId "user@yourtenant.onmicrosoft.com"
Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId $user.ObjectId
```

**Validation:**

```powershell
# Verify role membership
Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId | Where-Object { $_.UserPrincipalName -eq "user@yourtenant.onmicrosoft.com" }
```

### Resolution Step 4: Grant Admin Consent for Service Principal

Provide admin consent for app registration API permissions.

**Using Azure Portal:**

Navigate to app registration permissions.

- Go to [portal.azure.com](https://portal.azure.com).
- Navigate to **Azure Active Directory** → **App registrations**.
- Find and open your app registration.
- Click **API permissions**.
- Click **Grant admin consent for [tenant name]**.
- Confirm by clicking **Yes**.

**Verify Permissions Granted:**

Check Status column shows **Granted for [tenant]** in green.

**Using PowerShell (Advanced):**

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.ReadWrite.All", "DelegatedPermissionGrant.ReadWrite.All"

# Get service principal
$sp = Get-MgServicePrincipal -Filter "displayName eq 'Your App Name'"

# Grant specific permission (example: Sites.ReadWrite.All)
$resourceSp = Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0ff1-ce00-000000000000'"  # SharePoint
$permission = $resourceSp.AppRoles | Where-Object { $_.Value -eq "Sites.ReadWrite.All" }

New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -AppRoleId $permission.Id -ResourceId $resourceSp.Id
```

**Validation:**

```powershell
# Test service principal connection
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com" -ClientId $appId -Tenant $tenantId -Thumbprint $certThumbprint
Get-PnPWeb  # Should succeed without errors
```

### Resolution Step 5: Restore Permission Inheritance

If permissions were unintentionally broken, restore inheritance.

**Using SharePoint UI:**

Navigate to document library settings.

- Open SharePoint site and library.
- Click **Settings** (gear icon) → **Library settings**.
- Click **Permissions for this document library**.
- If inheritance is broken, click **Delete unique permissions**.
- Confirm restoration of inheritance.

**Using PowerShell:**

```powershell
# Connect to site
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/YourSite" -Interactive

# Reset list inheritance
Reset-PnPListInheritance -Identity "Documents"

# OR reset specific item inheritance
Set-PnPListItemPermission -List "Documents" -Identity 1 -InheritPermissions
```

**Validation:**

```powershell
# Verify inheritance restored
$list = Get-PnPList -Identity "Documents"
$list.HasUniqueRoleAssignments  # Should return $false
```

## Verification

Confirm permission issue is resolved.

**Verification Checklist:**

- [ ] PowerShell commands execute without permission errors.
- [ ] User can access previously restricted content.
- [ ] Classification scripts complete successfully.
- [ ] Service principal authentication succeeds.
- [ ] No 403/Unauthorized errors in recent logs.

**Validation Commands:**

```powershell
# Test SharePoint access
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/YourSite" -Interactive
Get-PnPList  # Should list all libraries

# Test Exchange Online access
Connect-IPPSSession
Get-DlpSensitiveInformationType | Select-Object -First 5  # Should return SITs

# Test classification operation
.\Invoke-PurviewClassification.ps1 -SiteUrl "https://yourtenant.sharepoint.com/sites/YourSite"  # Should complete successfully
```

**Expected Result**: All commands complete successfully without errors.

## Prevention

Implement these practices to prevent permission issues.

**Documentation:**

- Maintain current list of required permissions for all automation accounts.
- Document service principal permissions in app registration notes.
- Create permission checklists for new team member onboarding.

**Regular Audits:**

- Quarterly review of admin role assignments.
- Monthly validation of service principal permissions.
- Automated alerts when permission-related errors exceed threshold.

**Least Privilege Principle:**

- Grant minimum required permissions for each operation.
- Use dedicated service accounts for automation (not user accounts).
- Regularly review and remove unnecessary permissions.
- Implement just-in-time (JIT) access for sensitive operations when possible.

**Change Management:**

- Require approval for permission changes in production.
- Test permission changes in non-production environment first.
- Document all permission grants with business justification.

## Escalation Criteria

Escalate if:

- Cannot determine which permissions are required after investigation.
- Permission grants don't resolve the issue after 1 hour.
- Permissions require Global Administrator consent unavailable to team.
- Issue affects compliance-critical operations.
- Security concerns about granting requested permissions.

**Escalation Process:**

See `escalation/microsoft-support.md` for Microsoft Support engagement procedures.

**Required Information:**

- Complete error messages with HTTP status codes.
- List of permissions currently granted to account/service principal.
- Screenshots of permission screens.
- Business justification for required permissions.

## Related Runbooks

- **Classification Failure**: See `incident-response/classification-failure.md` for classification-specific permission issues.
- **Microsoft Support**: See `escalation/microsoft-support.md` for engaging Microsoft Support on permission questions.

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This runbook is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*
