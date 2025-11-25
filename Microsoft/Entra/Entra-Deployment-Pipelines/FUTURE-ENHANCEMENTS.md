# Future Enhancement Ideas

This document outlines potential additional deployment pipeline opportunities to expand the Entra Deployment Pipelines repository. Each project follows the existing REST API structure and pattern established in the repository.

---

## How to Use This Document

Each project idea is presented in a table format with the following components required for implementation:

- **Project Name**: The folder name and pipeline identifier
- **Purpose**: What the pipeline accomplishes
- **REST API Endpoint**: The Microsoft Graph API endpoint to call
- **HTTP Method**: GET, POST, PUT, PATCH, or DELETE
- **Required Permissions**: Microsoft Graph API permissions needed
- **Input Variables**: What goes in `pipeline-variables.yml`
- **Schema Validation**: Whether a JSON schema file is needed

All projects can be implemented using the existing `Invoke-RESTCommand` helper function pattern.

---
[[_TOC_]]

---

## Application Management

| Project Name | Purpose | REST API Endpoint | HTTP Method | Required Permissions | Input Variables | Schema Required |
|-------------|---------|-------------------|-------------|---------------------|-----------------|-----------------|
| **App-Registration-Create** | Create application registration with API permissions | `https://graph.microsoft.com/v1.0/applications` | POST | Application.ReadWrite.All | displayName, redirectUris, requiredResourceAccess (API permissions), signInAudience | ✅ Yes |
| **Service-Principal-Create** | Create service principal for an application | `https://graph.microsoft.com/v1.0/servicePrincipals` | POST | Application.ReadWrite.All | appId (from app registration), tags, notes | ❌ No |
| **App-Role-Assignment** | Assign users/groups to application roles | `https://graph.microsoft.com/v1.0/servicePrincipals/{id}/appRoleAssignedTo` | POST | AppRoleAssignment.ReadWrite.All | servicePrincipalId, principalId (user/group), appRoleId | ❌ No |
| **App-Registration-Delete** | Delete application registration | `https://graph.microsoft.com/v1.0/applications/{id}` | DELETE | Application.ReadWrite.All | applicationId or displayName | ❌ No |

**Microsoft Learn**: [Application Resource](https://learn.microsoft.com/en-us/graph/api/resources/application) | [Service Principal Resource](https://learn.microsoft.com/en-us/graph/api/resources/serviceprincipal)

---

## Authentication Methods

| Project Name | Purpose | REST API Endpoint | HTTP Method | Required Permissions | Input Variables | Schema Required |
|-------------|---------|-------------------|-------------|---------------------|-----------------|-----------------|
| **SMS-Authentication-Config** | Configure SMS authentication method policy | `https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/sms` | PATCH | Policy.ReadWrite.AuthenticationMethod | state (enabled/disabled), includeTargets (groups), excludeTargets | ✅ Yes |
| **Voice-Authentication-Config** | Configure voice call authentication policy | `https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/voice` | PATCH | Policy.ReadWrite.AuthenticationMethod | state, includeTargets, excludeTargets | ✅ Yes |
| **Email-Authentication-Config** | Configure email OTP authentication policy | `https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/email` | PATCH | Policy.ReadWrite.AuthenticationMethod | state, includeTargets, excludeTargets, allowExternalIdToUseEmailOtp | ✅ Yes |
| **Temporary-Access-Pass-Generate** | Generate temporary access pass for user | `https://graph.microsoft.com/v1.0/users/{id}/authentication/temporaryAccessPassMethods` | POST | UserAuthenticationMethod.ReadWrite.All | userId, lifetimeInMinutes, isUsableOnce | ❌ No |
| **Authentication-Methods-User-List** | List authentication methods registered by user | `https://graph.microsoft.com/v1.0/users/{id}/authentication/methods` | GET | UserAuthenticationMethod.Read.All | userPrincipalName or userId | ❌ No |

**Microsoft Learn**: [Authentication Methods Policy](https://learn.microsoft.com/en-us/graph/api/resources/authenticationmethodspolicy)

---

## Identity Governance

| Project Name | Purpose | REST API Endpoint | HTTP Method | Required Permissions | Input Variables | Schema Required |
|-------------|---------|-------------------|-------------|---------------------|-----------------|-----------------|
| **Access-Review-Create** | Create access review for groups/apps/roles | `https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions` | POST | AccessReview.ReadWrite.All | displayName, scope (groups/apps/roles), reviewers, settings (frequency, duration) | ✅ Yes |
| **Terms-of-Use-Create** | Create terms of use agreement | `https://graph.microsoft.com/v1.0/identityGovernance/termsOfUse/agreements` | POST | Agreement.ReadWrite.All | displayName, file (PDF), isViewingBeforeAcceptanceRequired | ❌ No |
| **Access-Package-Create** | Create entitlement management access package | `https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/accessPackages` | POST | EntitlementManagement.ReadWrite.All | catalogId, displayName, description, accessPackageResources | ✅ Yes |
| **Access-Package-Policy-Create** | Create access package assignment policy | `https://graph.microsoft.com/v1.0/identityGovernance/entitlementManagement/assignmentPolicies` | POST | EntitlementManagement.ReadWrite.All | accessPackageId, displayName, requestorSettings, approvalSettings, expiration | ✅ Yes |

**Microsoft Learn**: [Access Reviews](https://learn.microsoft.com/en-us/graph/api/resources/accessreviewsv2-overview) | [Entitlement Management](https://learn.microsoft.com/en-us/graph/api/resources/entitlementmanagement-overview)

---

## Administrative Units

| Project Name | Purpose | REST API Endpoint | HTTP Method | Required Permissions | Input Variables | Schema Required |
|-------------|---------|-------------------|-------------|---------------------|-----------------|-----------------|
| **Administrative-Unit-Create** | Create administrative unit | `https://graph.microsoft.com/v1.0/administrativeUnits` | POST | AdministrativeUnit.ReadWrite.All | displayName, description, membershipType (assigned/dynamic), membershipRule | ❌ No |
| **Administrative-Unit-Add-Members** | Add users/groups/devices to AU | `https://graph.microsoft.com/v1.0/administrativeUnits/{id}/members/$ref` | POST | AdministrativeUnit.ReadWrite.All | administrativeUnitId, members (array of user/group/device IDs) | ❌ No |
| **Administrative-Unit-Assign-Roles** | Assign scoped role to AU | `https://graph.microsoft.com/v1.0/administrativeUnits/{id}/scopedRoleMembers` | POST | RoleManagement.ReadWrite.Directory | administrativeUnitId, roleId, roleMemberInfo (user/service principal) | ❌ No |
| **Administrative-Unit-Delete** | Delete administrative unit | `https://graph.microsoft.com/v1.0/administrativeUnits/{id}` | DELETE | AdministrativeUnit.ReadWrite.All | administrativeUnitId or displayName | ❌ No |

**Microsoft Learn**: [Administrative Units](https://learn.microsoft.com/en-us/graph/api/resources/administrativeunit)

---

## Directory Roles

| Project Name | Purpose | REST API Endpoint | HTTP Method | Required Permissions | Input Variables | Schema Required |
|-------------|---------|-------------------|-------------|---------------------|-----------------|-----------------|
| **Directory-Role-Assignment** | Assign user/SP to directory role | `https://graph.microsoft.com/v1.0/directoryRoles/{id}/members/$ref` | POST | RoleManagement.ReadWrite.Directory | roleId or roleTemplateId, principalId (user/service principal) | ❌ No |
| **Directory-Role-Remove-Member** | Remove user/SP from directory role | `https://graph.microsoft.com/v1.0/directoryRoles/{id}/members/{memberId}/$ref` | DELETE | RoleManagement.ReadWrite.Directory | roleId, memberId (user/service principal to remove) | ❌ No |
| **Custom-Role-Create** | Create custom directory role definition | `https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions` | POST | RoleManagement.ReadWrite.Directory | displayName, description, rolePermissions (actions allowed), isEnabled | ✅ Yes |
| **PIM-Role-Assignment-Eligible** | Create eligible role assignment via PIM | `https://graph.microsoft.com/v1.0/roleManagement/directory/roleEligibilityScheduleRequests` | POST | RoleEligibilitySchedule.ReadWrite.Directory | principalId, roleDefinitionId, directoryScopeId, scheduleInfo (duration) | ✅ Yes |

**Microsoft Learn**: [Directory Roles](https://learn.microsoft.com/en-us/graph/api/resources/directoryrole) | [PIM](https://learn.microsoft.com/en-us/graph/api/resources/privilegedidentitymanagement-directory)

---

## Device Management

| Project Name | Purpose | REST API Endpoint | HTTP Method | Required Permissions | Input Variables | Schema Required |
|-------------|---------|-------------------|-------------|---------------------|-----------------|-----------------|
| **Device-List-Stale** | List devices inactive for X days | `https://graph.microsoft.com/v1.0/devices?$filter=approximateLastSignInDateTime le {date}` | GET | Device.Read.All | inactiveDays (calculate date filter) | ❌ No |
| **Device-Delete** | Delete device registration | `https://graph.microsoft.com/v1.0/devices/{id}` | DELETE | Device.ReadWrite.All | deviceId or deviceName | ❌ No |
| **Device-Update-Extension-Attributes** | Update device extension attributes | `https://graph.microsoft.com/v1.0/devices/{id}` | PATCH | Device.ReadWrite.All | deviceId, extensionAttributes (extensionAttribute1-15) | ❌ No |
| **Device-Registration-Policy-Update** | Update device registration settings | `https://graph.microsoft.com/v1.0/policies/deviceRegistrationPolicy` | PATCH | Policy.ReadWrite.DeviceConfiguration | userDeviceQuota, multiFactorAuthConfiguration, azureADJoin, azureADRegistration | ✅ Yes |

**Microsoft Learn**: [Device Resource](https://learn.microsoft.com/en-us/graph/api/resources/device) | [Device Registration Policy](https://learn.microsoft.com/en-us/graph/api/resources/deviceregistrationpolicy)

---

## Identity Protection

| Project Name | Purpose | REST API Endpoint | HTTP Method | Required Permissions | Input Variables | Schema Required |
|-------------|---------|-------------------|-------------|---------------------|-----------------|-----------------|
| **Risky-Users-Confirm-Compromised** | Mark users as compromised | `https://graph.microsoft.com/v1.0/identityProtection/riskyUsers/confirmCompromised` | POST | IdentityRiskyUser.ReadWrite.All | userIds (array of user IDs to mark as compromised) | ❌ No |
| **Risky-Users-Dismiss** | Dismiss risky user detections | `https://graph.microsoft.com/v1.0/identityProtection/riskyUsers/dismiss` | POST | IdentityRiskyUser.ReadWrite.All | userIds (array of user IDs to dismiss) | ❌ No |
| **Risky-Users-List** | List all risky users | `https://graph.microsoft.com/v1.0/identityProtection/riskyUsers?$filter=riskState eq 'atRisk'` | GET | IdentityRiskyUser.Read.All | riskLevel filter (low, medium, high) | ❌ No |
| **Risky-Service-Principals-Confirm-Compromised** | Mark service principals as compromised | `https://graph.microsoft.com/v1.0/identityProtection/riskyServicePrincipals/confirmCompromised` | POST | IdentityRiskyServicePrincipal.ReadWrite.All | servicePrincipalIds (array of SP IDs) | ❌ No |
| **Risk-Detections-List** | List all risk detections | `https://graph.microsoft.com/v1.0/identityProtection/riskDetections` | GET | IdentityRiskEvent.Read.All | filter by riskType, riskState, detectionTimingType | ❌ No |

**Microsoft Learn**: [Identity Protection](https://learn.microsoft.com/en-us/graph/api/resources/identityprotection-overview) | [Risky Users](https://learn.microsoft.com/en-us/graph/api/resources/riskyuser)

---

## B2B Collaboration

| Project Name | Purpose | REST API Endpoint | HTTP Method | Required Permissions | Input Variables | Schema Required |
|-------------|---------|-------------------|-------------|---------------------|-----------------|-----------------|
| **B2B-Invitation-Send** | Send B2B invitation to external users | `https://graph.microsoft.com/v1.0/invitations` | POST | User.Invite.All | invitedUserEmailAddress, inviteRedirectUrl, invitedUserDisplayName, sendInvitationMessage | ❌ No |
| **Cross-Tenant-Access-Policy-Update** | Configure cross-tenant access settings | `https://graph.microsoft.com/v1.0/policies/crossTenantAccessPolicy/partners/{tenantId}` | PATCH | Policy.ReadWrite.CrossTenantAccess | tenantId, b2bCollaborationInbound, b2bCollaborationOutbound, b2bDirectConnectInbound | ✅ Yes |
| **External-Users-List-Inactive** | List external users inactive for X days | `https://graph.microsoft.com/v1.0/users?$filter=userType eq 'Guest' and signInActivity/lastSignInDateTime le {date}` | GET | User.Read.All, AuditLog.Read.All | inactiveDays (calculate date filter) | ❌ No |
| **External-Users-Remove** | Delete external/guest users | `https://graph.microsoft.com/v1.0/users/{id}` | DELETE | User.ReadWrite.All | userIds or userPrincipalNames (array) | ❌ No |

**Microsoft Learn**: [Invitations](https://learn.microsoft.com/en-us/graph/api/resources/invitation) | [Cross-Tenant Access](https://learn.microsoft.com/en-us/graph/api/resources/crosstenantaccesspolicy)

---

## Advanced Conditional Access

| Project Name | Purpose | REST API Endpoint | HTTP Method | Required Permissions | Input Variables | Schema Required |
|-------------|---------|-------------------|-------------|---------------------|-----------------|-----------------|
| **Authentication-Strength-Create** | Create custom authentication strength | `https://graph.microsoft.com/v1.0/identity/conditionalAccess/authenticationStrength/policies` | POST | Policy.ReadWrite.ConditionalAccess | displayName, description, allowedCombinations (auth methods) | ✅ Yes |
| **Authentication-Context-Create** | Create authentication context | `https://graph.microsoft.com/v1.0/identity/conditionalAccess/authenticationContextClassReferences` | POST | Policy.ReadWrite.ConditionalAccess | id (c1-c25), displayName, description, isAvailable | ❌ No |
| **CA-Policy-Enable-Disable** | Enable or disable CA policy | `https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies/{id}` | PATCH | Policy.ReadWrite.ConditionalAccess | policyId, state (enabled, disabled, enabledForReportingButNotEnforced) | ❌ No |
| **CA-Policy-Delete** | Delete conditional access policy | `https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies/{id}` | DELETE | Policy.ReadWrite.ConditionalAccess | policyId or displayName | ❌ No |
| **CA-Policy-Export-All** | Export all CA policies (backup) | `https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies` | GET | Policy.Read.All | outputFormat (JSON file export) | ❌ No |

**Microsoft Learn**: [Authentication Strengths](https://learn.microsoft.com/en-us/graph/api/resources/authenticationstrengthpolicy) | [Authentication Context](https://learn.microsoft.com/en-us/graph/api/resources/authenticationcontextclassreference)

---

## Reporting & Export

| Project Name | Purpose | REST API Endpoint | HTTP Method | Required Permissions | Input Variables | Schema Required |
|-------------|---------|-------------------|-------------|---------------------|-----------------|-----------------|
| **Sign-In-Logs-Export** | Export sign-in logs for date range | `https://graph.microsoft.com/v1.0/auditLogs/signIns?$filter=createdDateTime ge {startDate} and createdDateTime le {endDate}` | GET | AuditLog.Read.All, Directory.Read.All | startDate, endDate, outputPath (CSV/JSON) | ❌ No |
| **Audit-Logs-Export** | Export directory audit logs | `https://graph.microsoft.com/v1.0/auditLogs/directoryAudits?$filter=activityDateTime ge {startDate}` | GET | AuditLog.Read.All | startDate, endDate, category filter, outputPath | ❌ No |
| **Provisioning-Logs-Export** | Export app provisioning logs | `https://graph.microsoft.com/v1.0/auditLogs/provisioning?$filter=activityDateTime ge {startDate}` | GET | AuditLog.Read.All | startDate, endDate, servicePrincipalFilter, outputPath | ❌ No |
| **Group-Membership-Report** | Export all group memberships | `https://graph.microsoft.com/v1.0/groups/{id}/members` | GET | Group.Read.All | groupIds (array) or all groups, outputPath | ❌ No |
| **User-License-Report** | Export user license assignments | `https://graph.microsoft.com/v1.0/users?$select=displayName,userPrincipalName,assignedLicenses` | GET | User.Read.All | outputPath (CSV/JSON) | ❌ No |

**Microsoft Learn**: [Audit Logs](https://learn.microsoft.com/en-us/graph/api/resources/azure-ad-auditlog-overview) | [Sign-in Logs](https://learn.microsoft.com/en-us/graph/api/resources/signin)

---

## License Management

| Project Name | Purpose | REST API Endpoint | HTTP Method | Required Permissions | Input Variables | Schema Required |
|-------------|---------|-------------------|-------------|---------------------|-----------------|-----------------|
| **License-Assign-Users** | Assign licenses to users | `https://graph.microsoft.com/v1.0/users/{id}/assignLicense` | POST | User.ReadWrite.All, Directory.ReadWrite.All | userIds (array), addLicenses (skuId array), removeLicenses | ✅ Yes |
| **License-Assign-Group** | Assign licenses to group (group-based) | `https://graph.microsoft.com/v1.0/groups/{id}/assignLicense` | POST | Group.ReadWrite.All, Directory.ReadWrite.All | groupId, addLicenses (skuId array), removeLicenses | ✅ Yes |
| **License-Remove-Users** | Remove licenses from users | `https://graph.microsoft.com/v1.0/users/{id}/assignLicense` | POST | User.ReadWrite.All | userIds (array), removeLicenses (skuId array) | ❌ No |
| **License-SKU-List** | List available license SKUs in tenant | `https://graph.microsoft.com/v1.0/subscribedSkus` | GET | Organization.Read.All | none (reports available licenses) | ❌ No |

**Microsoft Learn**: [License Assignment](https://learn.microsoft.com/en-us/graph/api/user-assignlicense) | [Subscribed SKUs](https://learn.microsoft.com/en-us/graph/api/resources/subscribedsku)

---

## Cleanup & Maintenance

| Project Name | Purpose | REST API Endpoint | HTTP Method | Required Permissions | Input Variables | Schema Required |
|-------------|---------|-------------------|-------------|---------------------|-----------------|-----------------|
| **Stale-Groups-Report** | List groups with no members | `https://graph.microsoft.com/v1.0/groups?$expand=members&$filter=members/$count eq 0` | GET | Group.Read.All | outputPath (report file) | ❌ No |
| **Stale-Groups-Delete** | Delete groups with no members | `https://graph.microsoft.com/v1.0/groups/{id}` | DELETE | Group.ReadWrite.All | groupIds (array) or query criteria | ❌ No |
| **Disabled-Users-List** | List all disabled user accounts | `https://graph.microsoft.com/v1.0/users?$filter=accountEnabled eq false` | GET | User.Read.All | outputPath (report file) | ❌ No |
| **Deleted-Items-Purge** | Permanently delete soft-deleted items | `https://graph.microsoft.com/v1.0/directory/deletedItems/{id}` | DELETE | Directory.ReadWrite.All | objectType (users/groups/apps), deletedItemIds | ❌ No |
| **Service-Principals-Cleanup-Expired** | Remove expired service principal credentials | `https://graph.microsoft.com/v1.0/servicePrincipals/{id}/removeKey` or `/removePassword` | POST | Application.ReadWrite.All | servicePrincipalId, keyId (credential to remove) | ❌ No |

**Microsoft Learn**: [Deleted Items](https://learn.microsoft.com/en-us/graph/api/directory-deleteditems-list) | [Service Principal Management](https://learn.microsoft.com/en-us/graph/api/resources/serviceprincipal)

---

## Implementation Priority Matrix

| Priority | Project Name | Complexity | Business Value | Implementation Effort |
|----------|-------------|------------|----------------|----------------------|
| **HIGH** | App-Registration-Create | Medium | Very High | 3-5 days |
| **HIGH** | Service-Principal-Create | Low | Very High | 2-3 days |
| **HIGH** | B2B-Invitation-Send | Low | High | 2-3 days |
| **HIGH** | License-Assign-Users | Medium | High | 3-4 days |
| **HIGH** | Authentication-Strength-Create | Medium | High | 3-4 days |
| **HIGH** | Sign-In-Logs-Export | Medium | High | 3-4 days |
| **MEDIUM** | Access-Review-Create | High | High | 5-7 days |
| **MEDIUM** | Administrative-Unit-Create | Low | Medium | 2-3 days |
| **MEDIUM** | Directory-Role-Assignment | Low | Medium | 2-3 days |
| **MEDIUM** | Device-Delete | Low | Medium | 2-3 days |
| **MEDIUM** | Risky-Users-Confirm-Compromised | Low | High | 2-3 days |
| **MEDIUM** | CA-Policy-Enable-Disable | Low | Medium | 1-2 days |
| **MEDIUM** | External-Users-Remove | Low | Medium | 2-3 days |
| **LOW** | Custom-Role-Create | Medium | Low | 3-4 days |
| **LOW** | Terms-of-Use-Create | Medium | Low | 3-4 days |
| **LOW** | Device-Registration-Policy-Update | Medium | Low | 2-3 days |

---

## Standard Implementation Template

For each new project, follow this implementation pattern:

### 1. Folder Structure

```text
Entra/<Category>/<Project-Name>/
├── Pipeline/
│   ├── pipeline.yml              # Standard Azure Pipeline
│   └── pipeline-variables.yml    # Variables (EDIT THIS)
├── Scripts/
│   └── <script-name>.ps1         # PowerShell with Invoke-RESTCommand
└── Template/ (if schema required)
    └── <resource>.schema.json    # JSON schema for validation
```

### 2. Script Pattern

```powershell
# Load and validate schema (if applicable)
$Schema = Get-Content -Path $SchemaFilePath -Raw
$InputJson | Test-Json -Schema $Schema -ErrorAction Stop

# Build REST API request
$restUri = 'https://graph.microsoft.com/v1.0/<endpoint>'
$body = @{ ... } | ConvertTo-Json -Depth 10 -Compress

$restInputObject = @{
    method = 'POST'  # or GET, PATCH, PUT, DELETE
    uri    = $restUri
    header = @{ "Content-Type" = "application/json" }
    body   = $body
}

# Execute REST command
$response = Invoke-RESTCommand @restInputObject

# Error handling
if (-not [String]::IsNullOrEmpty($response.error)) {
    Write-Error "Failed: $($response.error.message)"
}
```

### 3. Pipeline Variables Template

```yaml
variables:
  serviceConnection: '<YOUR-SERVICE-CONNECTION-NAME>'
  scriptPath: "$(Build.SourcesDirectory)/Entra/<Category>/<Project>/Scripts/<script>.ps1"
  
  # Project-specific variables
  <variableName>: "<value>"
```

### 4. Required Components Checklist

- [ ] Script header with synopsis, description, author (Marcus Jacobson)
- [ ] Parameter validation with help messages
- [ ] JSON schema file (if complex input required)
- [ ] Comprehensive error handling
- [ ] Verbose logging for all operations
- [ ] Generic placeholder values in pipeline-variables.yml
- [ ] Comments with REQUIRED: markers
- [ ] Microsoft Learn documentation links

---

**Last Updated**: October 2025  
**Version**: 2.0

This document focuses on implementable projects using the established REST API patterns in the repository.

**Use Cases**:

- Standardize app registrations across environments
- Set up multi-tenant applications consistently
- Configure API permissions and admin consent programmatically

**Graph API**: [Application Resource](https://learn.microsoft.com/en-us/graph/api/resources/application)

**Key Operations**:

- Create application with specified properties
- Add API permissions (delegated and application)
- Configure authentication (redirect URIs, certificates, secrets)
- Set app roles and optional claims

---

### Service-Principal-Create

**Purpose**: Create service principals for applications with role assignments and access policies.

**Use Cases**:

- Deploy service principals for automation
- Assign Azure RBAC roles to service principals
- Configure managed identities

**Graph API**: [Service Principal Resource](https://learn.microsoft.com/en-us/graph/api/resources/serviceprincipal)

**Key Operations**:

- Create service principal from app registration
- Assign directory roles
- Configure tags and notes for governance

---

### App-Role-Assignment

**Purpose**: Assign application roles to users, groups, or service principals.

**Use Cases**:

- Manage application access through role assignments
- Bulk assign users to applications
- Configure SSO application access

**Graph API**: [App Role Assignment](https://learn.microsoft.com/en-us/graph/api/resources/approleassignment)

---

### App-Consent-Grant

**Purpose**: Automate OAuth2 permission grants for applications.

**Use Cases**:

- Grant admin consent to applications programmatically
- Standardize delegated permission grants
- Manage user consent settings

**Graph API**: [OAuth2 Permission Grant](https://learn.microsoft.com/en-us/graph/api/resources/oauth2permissiongrant)

---

## Advanced Authentication Methods

### SMS-Authentication-Config

**Purpose**: Configure SMS-based authentication method policy.

**Use Cases**:

- Enable/disable SMS authentication for specific groups
- Configure SMS as backup MFA method
- Set allowed/blocked user lists

**Graph API**: [SMS Authentication Method Configuration](https://learn.microsoft.com/en-us/graph/api/resources/smsauthenticationmethodconfiguration)

---

### Voice-Authentication-Config

**Purpose**: Configure voice call authentication method policy.

**Graph API**: [Voice Authentication Method Configuration](https://learn.microsoft.com/en-us/graph/api/resources/voiceauthenticationmethodconfiguration)

---

### Email-Authentication-Config

**Purpose**: Configure email OTP authentication method policy.

**Graph API**: [Email Authentication Method Configuration](https://learn.microsoft.com/en-us/graph/api/resources/emailauthenticationmethodconfiguration)

---

### Temporary-Access-Pass-Config

**Purpose**: Configure Temporary Access Pass (TAP) authentication policy and generate TAPs for users.

**Use Cases**:

- Enable passwordless onboarding
- Generate temporary access passes for users
- Configure TAP lifetime and usage limits

**Graph API**: [Temporary Access Pass](https://learn.microsoft.com/en-us/graph/api/resources/temporaryaccesspassauthenticationmethod)

---

### Certificate-Based-Authentication-Config

**Purpose**: Configure certificate-based authentication policies.

**Graph API**: [Certificate-Based Authentication Configuration](https://learn.microsoft.com/en-us/graph/api/resources/certificatebasedauthconfiguration)

---

### Password-Policy-Config

**Purpose**: Configure password policies including complexity, expiration, and banned password lists.

**Graph API**: [Authentication Methods Policy](https://learn.microsoft.com/en-us/graph/api/resources/authenticationmethodspolicy)

---

## Identity Governance & Lifecycle

### Access-Review-Create

**Purpose**: Create and schedule access reviews for groups, applications, and directory roles.

**Use Cases**:

- Periodic review of group memberships
- Review application access assignments
- Privileged role access reviews

**Graph API**: [Access Reviews](https://learn.microsoft.com/en-us/graph/api/resources/accessreviewsv2-overview)

**Key Operations**:

- Create recurring access reviews
- Configure reviewers (managers, group owners, specific users)
- Set review scope and frequency
- Auto-apply review decisions

---

### Lifecycle-Workflow-Create

**Purpose**: Automate user lifecycle workflows (joiner, mover, leaver scenarios).

**Use Cases**:

- Onboarding automation (assign groups, licenses, send welcome email)
- Transfer workflows (move between departments)
- Offboarding automation (remove access, export data)

**Graph API**: [Lifecycle Workflows](https://learn.microsoft.com/en-us/graph/api/resources/identitygovernance-lifecycleworkflows-overview)

**Key Operations**:

- Define workflow triggers (days from hire date, termination date)
- Configure tasks (add to group, assign license, send email)
- Set execution conditions

---

### Terms-of-Use-Create

**Purpose**: Create and manage terms of use policies for conditional access.

**Use Cases**:

- Legal compliance requirements
- Acceptable use policies
- GDPR consent tracking

**Graph API**: [Terms of Use](https://learn.microsoft.com/en-us/graph/api/resources/agreement)

---

### Entitlement-Management-Package-Create

**Purpose**: Create access packages for entitlement management.

**Use Cases**:

- Self-service access requests
- Time-bound access grants
- Approval workflows for resource access

**Graph API**: [Access Packages](https://learn.microsoft.com/en-us/graph/api/resources/accesspackage)

---

## Administrative Units

### Administrative-Unit-Create

**Purpose**: Create administrative units for delegated administration.

**Use Cases**:

- Delegate user/group management to specific admins
- Segment directory for geo-based or org-based management
- Restrict admin visibility to specific subsets of users/groups

**Graph API**: [Administrative Units](https://learn.microsoft.com/en-us/graph/api/resources/administrativeunit)

**Key Operations**:

- Create administrative units
- Add members (users, groups, devices)
- Assign scoped role members

---

### Administrative-Unit-Add-Members

**Purpose**: Add users, groups, or devices to administrative units.

**Graph API**: [Add AU Member](https://learn.microsoft.com/en-us/graph/api/administrativeunit-post-members)

---

### Administrative-Unit-Assign-Roles

**Purpose**: Assign scoped roles to users for specific administrative units.

**Graph API**: [Add Scoped Role Member](https://learn.microsoft.com/en-us/graph/api/administrativeunit-post-scopedrolemembers)

---

## Directory Roles & Custom Roles

### Directory-Role-Assignment

**Purpose**: Assign users or service principals to built-in directory roles.

**Use Cases**:

- Automate role assignments for new admins
- Bulk assign Global Reader role
- Configure least-privilege access

**Graph API**: [Directory Roles](https://learn.microsoft.com/en-us/graph/api/resources/directoryrole)

---

### Custom-Role-Create

**Purpose**: Create custom directory roles with specific permissions.

**Use Cases**:

- Create least-privilege admin roles
- Build org-specific role definitions
- Delegate specific administrative tasks

**Graph API**: [Role Definitions](https://learn.microsoft.com/en-us/graph/api/resources/unifiedroledefinition)

---

### PIM-Role-Assignment

**Purpose**: Create eligible and active directory role assignments through PIM.

**Use Cases**:

- Just-in-time admin access
- Time-bound privileged role assignments
- Approval workflows for role activation

**Graph API**: [PIM Role Assignments](https://learn.microsoft.com/en-us/graph/api/resources/privilegedidentitymanagement-directory)

---

## Device Management

### Device-Registration-Policy-Config

**Purpose**: Configure device registration policies (who can join/register devices).

**Graph API**: [Device Registration Policy](https://learn.microsoft.com/en-us/graph/api/resources/deviceregistrationpolicy)

---

### Device-Compliance-Policy-Create

**Purpose**: Create device compliance policies for Intune integration.

**Graph API**: [Device Compliance Policies](https://learn.microsoft.com/en-us/graph/api/resources/intune-deviceconfig-devicecompliancepolicy)

---

### Device-Cleanup

**Purpose**: Remove stale device registrations based on last activity date.

**Use Cases**:

- Clean up inactive devices
- Remove devices not signed in for X days
- Maintain device hygiene

**Graph API**: [Device Resource](https://learn.microsoft.com/en-us/graph/api/resources/device)

---

## Identity Protection

### Risk-Detection-Config

**Purpose**: Configure risk detection settings and policies.

**Graph API**: [Risk Detections](https://learn.microsoft.com/en-us/graph/api/resources/riskdetection)

---

### Risky-Users-Remediation

**Purpose**: Automate remediation actions for risky users (dismiss, confirm safe, confirm compromised).

**Use Cases**:

- Batch confirm users as compromised
- Dismiss low-risk alerts
- Force password reset for risky users

**Graph API**: [Risky Users](https://learn.microsoft.com/en-us/graph/api/resources/riskyuser)

---

### Risky-Service-Principal-Remediation

**Purpose**: Manage risky service principal detections.

**Graph API**: [Risky Service Principals](https://learn.microsoft.com/en-us/graph/api/resources/riskyserviceprincipal)

---

## B2B & External Identities

### B2B-Invitation-Send

**Purpose**: Send bulk B2B invitations to external users.

**Use Cases**:

- Partner onboarding
- Vendor/contractor access
- Guest user provisioning

**Graph API**: [Invitations](https://learn.microsoft.com/en-us/graph/api/resources/invitation)

---

### Cross-Tenant-Access-Policy-Config

**Purpose**: Configure cross-tenant access settings for B2B collaboration.

**Use Cases**:

- Allow/block specific tenants
- Configure default cross-tenant access
- Enable B2B direct connect

**Graph API**: [Cross-Tenant Access Policy](https://learn.microsoft.com/en-us/graph/api/resources/crosstenantaccesspolicy)

---

### B2B-Policy-Config

**Purpose**: Configure B2B collaboration settings (allow/deny lists, invitation restrictions).

**Graph API**: [Authorization Policy](https://learn.microsoft.com/en-us/graph/api/resources/authorizationpolicy)

---

### External-User-Cleanup

**Purpose**: Remove inactive external/guest users.

**Use Cases**:

- Clean up guest accounts not used in X days
- Remove B2B users from specific domains
- Maintain external user hygiene

**Graph API**: [User Resource](https://learn.microsoft.com/en-us/graph/api/resources/user)

---

## Entitlement Management

### Catalog-Create

**Purpose**: Create catalogs for grouping access packages.

**Graph API**: [Access Package Catalog](https://learn.microsoft.com/en-us/graph/api/resources/accesspackagecatalog)

---

### Access-Package-Policy-Create

**Purpose**: Define policies for access package requests and assignments.

**Use Cases**:

- Configure approval requirements
- Set access duration and expiration
- Define requestor scope

**Graph API**: [Access Package Assignment Policy](https://learn.microsoft.com/en-us/graph/api/resources/accesspackageassignmentpolicy)

---

### Connected-Organization-Create

**Purpose**: Add connected organizations for B2B entitlement management.

**Graph API**: [Connected Organization](https://learn.microsoft.com/en-us/graph/api/resources/connectedorganization)

---

## Advanced Conditional Access

### Authentication-Strength-Create

**Purpose**: Create custom authentication strength policies.

**Use Cases**:

- Require phishing-resistant MFA for specific scenarios
- Define allowed authentication methods combinations
- Create tiered authentication requirements

**Graph API**: [Authentication Strengths](https://learn.microsoft.com/en-us/graph/api/resources/authenticationstrengthpolicy)

---

### Authentication-Context-Create

**Purpose**: Create authentication context class references for step-up authentication.

**Use Cases**:

- Require re-authentication for sensitive operations
- Step-up auth for SharePoint sites or Teams channels
- Conditional access based on resource sensitivity

**Graph API**: [Authentication Context](https://learn.microsoft.com/en-us/graph/api/resources/authenticationcontextclassreference)

---

### Continuous-Access-Evaluation-Config

**Purpose**: Configure continuous access evaluation policies.

**Graph API**: [Continuous Access Evaluation](https://learn.microsoft.com/en-us/graph/api/resources/continuousaccessevaluationpolicy)

---

### Session-Control-Policy-Create

**Purpose**: Create conditional access policies with advanced session controls.

**Use Cases**:

- Conditional Access App Control integration
- Persistent browser sessions configuration
- Sign-in frequency policies

**Graph API**: [Conditional Access Policy](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)

---

## Reporting & Monitoring

### Sign-In-Logs-Export

**Purpose**: Export and analyze sign-in logs to storage/log analytics.

**Use Cases**:

- Compliance reporting
- Security analytics
- User behavior analysis

**Graph API**: [Sign-in Logs](https://learn.microsoft.com/en-us/graph/api/resources/signin)

---

### Audit-Logs-Export

**Purpose**: Export directory audit logs for compliance.

**Graph API**: [Directory Audit](https://learn.microsoft.com/en-us/graph/api/resources/directoryaudit)

---

### Provisioning-Logs-Export

**Purpose**: Export provisioning logs for app provisioning monitoring.

**Graph API**: [Provisioning Logs](https://learn.microsoft.com/en-us/graph/api/resources/provisioningobjectsummary)

---

### License-Usage-Report

**Purpose**: Generate reports on license assignment and usage.

**Use Cases**:

- License optimization
- Cost analysis
- Compliance reporting

**Graph API**: [Subscribed SKUs](https://learn.microsoft.com/en-us/graph/api/resources/subscribedsku)

---

## Security & Compliance

### Security-Defaults-Config

**Purpose**: Enable/disable security defaults for the tenant.

**Graph API**: [Identity Security Defaults](https://learn.microsoft.com/en-us/graph/api/resources/identitysecuritydefaultsenforcementpolicy)

---

### Password-Protection-Config

**Purpose**: Configure banned password lists and lockout thresholds.

**Graph API**: Part of Authentication Methods Policy

---

### Multi-Factor-Auth-Settings-Config

**Purpose**: Configure tenant-wide MFA settings and trusted IPs.

**Graph API**: [MFA Settings](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)

---

### Domain-Add-Verify

**Purpose**: Automate custom domain addition and DNS verification.

**Use Cases**:

- Add multiple domains to tenant
- Automate DNS record creation/verification
- Configure domain federation settings

**Graph API**: [Domains](https://learn.microsoft.com/en-us/graph/api/resources/domain)

---

### Organization-Branding-Localization

**Purpose**: Configure localized branding for different languages.

**Graph API**: [Organizational Branding Localization](https://learn.microsoft.com/en-us/graph/api/resources/organizationalbrandinglocalization)

---

### Data-Loss-Prevention-Policy-Config

**Purpose**: Configure DLP policies for Entra-integrated applications.

**Graph API**: [Information Protection](https://learn.microsoft.com/en-us/graph/api/resources/informationprotection)

---

## Implementation Priority Recommendations

### High Priority (Most Requested)

1. **App-Registration-Create** - Critical for DevOps automation
2. **Service-Principal-Create** - Essential for service automation
3. **Access-Review-Create** - Core governance requirement
4. **Lifecycle-Workflow-Create** - High-value automation
5. **Authentication-Strength-Create** - Enhanced security controls
6. **B2B-Invitation-Send** - Common partnership scenario

### Medium Priority

1. **Administrative-Unit-Create** - For large organizations
2. **Directory-Role-Assignment** - Common admin task
3. **Device-Cleanup** - Hygiene/compliance
4. **Terms-of-Use-Create** - Compliance requirement
5. **Cross-Tenant-Access-Policy-Config** - B2B scenarios
6. **Sign-In-Logs-Export** - Security/compliance reporting

### Lower Priority (Niche Use Cases)

1. **Custom-Role-Create** - Advanced scenarios
2. **Connected-Organization-Create** - Specific entitlement scenarios
3. **Certificate-Based-Authentication-Config** - Specific security requirements
4. **Domain-Add-Verify** - One-time setup, less frequent

---

## Design Patterns to Maintain

When implementing new deployment projects, maintain consistency with existing patterns:

### Standard Project Structure

```text
<Project-Name>/
├── Pipeline/
│   ├── pipeline.yml
│   └── pipeline-variables.yml
├── Scripts/
│   └── <script-name>.ps1
└── Template/ (optional)
    └── <resource>.schema.json
```

### Script Requirements

- Use `Invoke-RESTCommand` helper function for Graph API calls
- Include comprehensive error handling
- Provide verbose logging for all operations
- Include JSON schema validation where applicable
- Maintain Marcus Jacobson attribution in headers
- Follow existing comment/documentation patterns

### Variable File Standards

- Use generic placeholders: `<YOUR-X-NAME>`
- Include `REQUIRED:` markers for mandatory configuration
- Provide example values with clear comments
- Reference Microsoft Learn documentation where applicable
- Include schema file references for complex JSON structures

### Pipeline Standards

- Use `trigger: none` (manual execution)
- Target `ubuntu-latest` agents
- Use `AzureCLI@2` task for authentication
- Reference external variable template
- Keep pipeline.yml generic and reusable

---

## Additional Considerations

### Batch Operations

Consider creating "batch" versions of existing single-item operations:

- **Batch-User-Disable**: Disable multiple users from CSV/JSON
- **Batch-Group-Member-Add**: Add multiple users to multiple groups
- **Batch-License-Assignment**: Assign licenses to multiple users

### Backup/Export Operations

- **Export-Conditional-Access-Policies**: Export all CA policies for backup
- **Export-Groups-Configuration**: Export all groups and memberships
- **Export-PIM-Configuration**: Export all PIM settings
- **Tenant-Configuration-Backup**: Export comprehensive tenant settings

### Validation/Reporting Pipelines

- **Validate-CA-Policy-Coverage**: Report on users/apps not covered by CA
- **Report-Stale-Groups**: Identify groups with no members or activity
- **Report-License-Compliance**: Show assigned vs. available licenses
- **Audit-Admin-Assignments**: Report on all privileged role assignments

---

## Integration Opportunities

### Integration with Other Azure Services

- **Azure Key Vault**: Store secrets/certificates for app registrations
- **Azure Storage**: Export logs and reports to blob storage
- **Azure Monitor**: Send pipeline telemetry and success/failure metrics
- **Log Analytics**: Stream Entra logs for advanced querying

### Integration with External Systems

- **ServiceNow**: Create pipeline triggers from ServiceNow requests
- **HR Systems**: Sync user lifecycle from HR data
- **SIEM Systems**: Push audit data to security tools
- **Ticketing Systems**: Auto-create tickets for failed operations

---

## Documentation Enhancements

### Video Tutorials

- Getting started with the repository
- Step-by-step pipeline configuration
- Troubleshooting common issues
- Security best practices

### Sample Scenarios

- Onboarding new employees (Users-Create + Group-Assign-Member + License assignment)
- Offboarding process (User-Disable + Group-Remove-Member + PIM cleanup)
- Partner onboarding (B2B-Invitation + Group-Assign + Conditional Access)
- Privileged access workflow (PIM-Group-Assign + Access-Review)

---

**Last Updated**: October 2025  
**Version**: 1.0

This document is a living document and should be updated as new opportunities are identified or Microsoft Graph API capabilities expand.
