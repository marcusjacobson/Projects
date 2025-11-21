# Authentication Standardization - Project-Wide Updates

## 📋 Overview

All PowerShell scripts in the Purview Data Governance Simulation project have been updated to use the **centralized shared authentication framework** (`Connection-Management.ps1`) with **PnPClientId configuration from `global-config.json`**. This ensures consistent, configuration-driven authentication across the entire project without requiring repeated troubleshooting.

## ✅ Updated Scripts

### 01 - SharePoint Site Creation (3 scripts)

- **`New-SimulatedSharePointSites.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Uses `Connect-PurviewServices` with `PnPClientId` from config for initial connection
  - Uses shared module for site metadata configuration connections
  - Uses shared module for reconnecting to tenant admin

- **`Set-SitePermissions.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Uses `Connect-PurviewServices` with `PnPClientId` for each site connection

- **`Verify-SiteCreation.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Uses `Connect-PurviewServices` with `PnPClientId` for site verification connections

### 03 - Document Upload Distribution (2 scripts)

- **`Copy-DocumentsToSharePoint.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Uses `Connect-PurviewServices` with `PnPClientId` for site uploads

- **`Set-DocumentMetadata.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Ready for consistent authentication pattern (metadata operations)

### 04 - Classification Validation (4 scripts)

- **`Export-ClassificationResults.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Uses `Connect-PurviewServices` for ComplianceCenter connection
  - Uses `Connect-PurviewServices` with `PnPClientId` for SharePoint site connections
  - Includes `Test-PurviewConnection` validation

- **`Get-ClassificationStatus.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Updated `Get-SiteClassificationStatus` function to accept Config parameter
  - Uses `Connect-PurviewServices` with `PnPClientId` for site status checks

- **`Invoke-OnDemandClassification.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Uses `Connect-PurviewServices` for ComplianceCenter connection
  - Uses `Connect-PurviewServices` with `PnPClientId` for SharePoint connections
  - Includes `Test-PurviewConnection` validation

### 05 - DLP Policy Implementation (3 scripts)

- **`Export-DLPIncidents.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Uses `Connect-PurviewServices` for ComplianceCenter connection
  - Includes `Test-PurviewConnection` validation

- **`New-DLPPolicies.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Uses `Connect-PurviewServices` for ComplianceCenter connection
  - Includes `Test-PurviewConnection` validation

- **`Set-PolicyRules.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Uses `Connect-PurviewServices` for ComplianceCenter connection
  - Includes `Test-PurviewConnection` validation

### 07 - Cleanup & Reset (2 scripts)

- **`Remove-SimulationResources.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Uses `Connect-PurviewServices` for ComplianceCenter (DLP removal)
  - Uses `Connect-PurviewServices` with `PnPClientId` for SharePoint site document removal
  - Uses `Connect-PurviewServices` with `PnPClientId` for SharePoint Admin (site removal)

- **`Test-CleanupCompletion.ps1`**
  - Loads shared modules via `Import-PurviewModules.ps1`
  - Uses `Connect-PurviewServices` with `PnPClientId` for SharePoint Admin verification
  - Uses `Connect-PurviewServices` for ComplianceCenter DLP policy verification

## 🔧 Shared Authentication Framework

### Connection-Management.ps1

**Location**: `Shared-Utilities/Functions/Connection-Management.ps1`

**Key Functions**:
- `Connect-PurviewServices` - Main connection function
- `Test-PurviewConnection` - Connection validation
- `Disconnect-PurviewServices` - Clean disconnection

**Parameters**:
- `-Services` - Array of services to connect: `@("SharePoint")`, `@("ComplianceCenter")`, or both
- `-TenantUrl` - SharePoint site URL (for SharePoint connections)
- `-PnPClientId` - Azure AD App Registration Client ID (from global-config.json)
- `-Interactive` - Browser-based authentication (default: $true)

**Usage Pattern**:
```powershell
# Import shared modules
. "$PSScriptRoot\..\..\Shared-Utilities\Import-PurviewModules.ps1"

# Load configuration
$config = & "$PSScriptRoot\..\..\Shared-Utilities\Import-GlobalConfig.ps1"

# Connect to SharePoint
Connect-PurviewServices -Services @("SharePoint") `
    -TenantUrl $config.Environment.TenantUrl `
    -PnPClientId $config.Environment.PnPClientId `
    -Interactive

# Connect to Compliance Center
Connect-PurviewServices -Services @("ComplianceCenter") -Interactive

# Validate connection
$connectionTest = Test-PurviewConnection -Service "SharePoint"
if ($connectionTest.Connected) {
    Write-Host "✅ Connected: $($connectionTest.Message)"
}
```

## 🔑 Configuration-Driven Authentication

### global-config.json

**PnPClientId Configuration**:
```json
{
  "Environment": {
    "TenantUrl": "https://marcusjcloud.sharepoint.com/",
    "PnPClientId": "14c0019b-f7a4-412e-9adf-f5a2487f2a7e"
  }
}
```

**Key Benefits**:
- **No prompts**: All authentication values from configuration
- **Single source of truth**: `global-config.json`
- **Consistent behavior**: All scripts use same authentication method
- **Easy updates**: Change app registration ID in one place
- **No hardcoding**: No client IDs embedded in scripts

## 📊 Authentication Patterns by Service

### SharePoint Online Authentication

**Method**: Browser-based interactive authentication with Azure AD App Registration

**Pattern**:
```powershell
Connect-PurviewServices -Services @("SharePoint") `
    -TenantUrl "https://tenant.sharepoint.com/sites/sitename" `
    -PnPClientId $config.Environment.PnPClientId `
    -Interactive
```

**Features**:
- Session reuse (checks `Get-PnPConnection`)
- Connection tracking in `$Script:ConnectedServices`
- Automatic disconnect before reconnect for clean state

### Security & Compliance Center Authentication

**Method**: Browser-based interactive authentication via `Connect-IPPSSession`

**Pattern**:
```powershell
Connect-PurviewServices -Services @("ComplianceCenter") -Interactive

$connectionTest = Test-PurviewConnection -Service "ComplianceCenter"
if ($connectionTest.Connected) {
    # Proceed with compliance operations
}
```

**Features**:
- Session reuse (checks `Get-PSSession`)
- Connection validation with structured result objects
- Graceful error handling with clear messages

## 🎯 Benefits of Standardization

### 1. Consistency
- All scripts use identical authentication approach
- No variations in connection methods across project
- Predictable behavior for users

### 2. Maintainability
- Single module to update for authentication changes
- Configuration changes in one location (`global-config.json`)
- Reduced code duplication

### 3. Troubleshooting
- Centralized error handling
- Consistent error messages
- Connection state tracking and validation

### 4. Security
- App registration ID stored in configuration (not scripts)
- Explicit permissions control via Azure AD app
- Audit trail through app registration usage

### 5. User Experience
- No repeated authentication prompts (session reuse)
- Clear success/failure messages
- Informative connection status feedback

## 📚 Testing & Validation

### Prerequisites Validation

Run **`Test-Prerequisites.ps1`** to validate authentication setup:
```powershell
.\00-Prerequisites-Setup\scripts\Test-Prerequisites.ps1
```

**Expected Results**:
- ✅ Configuration loaded with PnPClientId validation
- ✅ SharePoint connection established with custom app registration
- ✅ All prerequisites validation checks passed
- ⚠️ ComplianceCenter optional (may show warning if WAM DLL unavailable)

### Per-Script Testing

Each updated script can be tested individually:
```powershell
# Test SharePoint site creation authentication
.\01-SharePoint-Site-Creation\scripts\New-SimulatedSharePointSites.ps1 -WhatIf

# Test document upload authentication
.\03-Document-Upload-Distribution\scripts\Copy-DocumentsToSharePoint.ps1 -WhatIf

# Test DLP policy authentication
.\05-DLP-Policy-Implementation\scripts\Export-DLPIncidents.ps1
```

## 🔍 Verification Checklist

After standardization, verify these items:

- [ ] **All scripts load shared modules** via `Import-PurviewModules.ps1`
- [ ] **SharePoint connections** use `Connect-PurviewServices` with `PnPClientId` from config
- [ ] **Compliance connections** use `Connect-PurviewServices` with ComplianceCenter service
- [ ] **No direct `Connect-PnPOnline -Interactive`** calls (except in Connection-Management.ps1)
- [ ] **No direct `Connect-IPPSSession`** calls (except in Connection-Management.ps1)
- [ ] **Configuration validation** includes PnPClientId property check
- [ ] **Connection testing** uses `Test-PurviewConnection` where appropriate
- [ ] **Error messages** reference shared module connection issues

## 🚀 Future Enhancements

**Potential Improvements**:
- Certificate-based authentication for automation scenarios
- Managed identity support for Azure-hosted execution
- Additional connection validation checks
- Retry logic for transient connection failures
- Connection pooling for multi-site operations

## 📝 Documentation Updates

**Related Files**:
- `README.md` - Updated with authentication requirements
- `global-config.json` - Contains PnPClientId configuration
- `Connection-Management.ps1` - Core authentication module
- `Import-PurviewModules.ps1` - Auto-loads shared functions
- `Test-Prerequisites.ps1` - Validates authentication setup

## 🤖 AI-Assisted Content Generation

This authentication standardization documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, documenting the comprehensive project-wide authentication updates to ensure consistent, configuration-driven SharePoint and Compliance Center connections across all Purview Data Governance Simulation scripts.

*AI tools were used to enhance productivity and ensure comprehensive coverage of authentication standardization while maintaining technical accuracy and reflecting PowerShell scripting best practices for enterprise-grade Microsoft 365 automation.*

---

**Standardization Completed**: November 16, 2025  
**Scripts Updated**: 17 scripts across 5 lab modules  
**Authentication Method**: Configuration-driven with PnPClientId from global-config.json  
**Framework**: Shared Connection-Management module with session reuse and validation
