# Environment Portability Guide

This guide provides step-by-step instructions for moving the Purview Data Governance Simulation project between different environments (Development → Test → Production) or across different Microsoft 365 tenants (multi-tenant consultant scenarios).

## 🎯 Quick Start: Moving Between Environments

### Prerequisites

- Source environment scripts (complete project directory)
- Target environment credentials (admin access to Microsoft 365 tenant)
- Global Admin and Compliance Admin roles in target tenant
- 5-10 minutes for configuration updates

### Lift-and-Shift Process

#### Step 1: Copy Project Directory

Copy the entire project to the new environment location:

```powershell
# Copy project to new environment
Copy-Item -Path "C:\Purview-Simulation-Dev" -Destination "C:\Purview-Simulation-Prod" -Recurse

# Navigate to new location
Set-Location "C:\Purview-Simulation-Prod"
```

#### Step 2: Update Global Configuration

Edit `global-config.json` at the root of the project with environment-specific values.

**Development Environment (Before):**

```json
{
  "Environment": {
    "TenantUrl": "https://contoso-dev.sharepoint.com",
    "TenantDomain": "contoso-dev.onmicrosoft.com",
    "AdminEmail": "admin-dev@contoso-dev.onmicrosoft.com",
    "AdminCenterUrl": "https://contoso-dev-admin.sharepoint.com",
    "ComplianceUrl": "https://compliance.microsoft.com",
    "OrganizationName": "Contoso Corporation - DEV",
    "EnvironmentType": "Development",
    "Region": "North America"
  },
  "Simulation": {
    "ScaleLevel": "Small",
    "CompanyPrefix": "CONTOSO",
    "ResourcePrefix": "Dev-Sim",
    "DefaultOwner": "admin-dev@contoso-dev.onmicrosoft.com",
    "NotificationEmail": "compliance-dev@contoso-dev.onmicrosoft.com"
  }
}
```

**Production Environment (After):**

```json
{
  "Environment": {
    "TenantUrl": "https://contoso.sharepoint.com",
    "TenantDomain": "contoso.onmicrosoft.com",
    "AdminEmail": "admin@contoso.onmicrosoft.com",
    "AdminCenterUrl": "https://contoso-admin.sharepoint.com",
    "ComplianceUrl": "https://compliance.microsoft.com",
    "OrganizationName": "Contoso Corporation",
    "EnvironmentType": "Production",
    "Region": "North America"
  },
  "Simulation": {
    "ScaleLevel": "Large",
    "CompanyPrefix": "CONTOSO",
    "ResourcePrefix": "Prod-Sim",
    "DefaultOwner": "admin@contoso.onmicrosoft.com",
    "NotificationEmail": "compliance@contoso.onmicrosoft.com"
  }
}
```

#### Step 3: Validate Configuration

Run prerequisite validation with the new configuration:

```powershell
# Validate environment prerequisites
.\00-Prerequisites-Setup\scripts\Test-Prerequisites.ps1

# Expected output: All checks pass with production tenant details
```

#### Step 4: Execute Scripts

Run scripts normally - they automatically load production config:

```powershell
# All scripts automatically reference global-config.json
.\01-SharePoint-Site-Creation\scripts\New-SimulatedSharePointSites.ps1
.\02-Test-Data-Generation\scripts\Invoke-BulkDocumentGeneration.ps1
.\03-Document-Upload-Distribution\scripts\Invoke-BulkDocumentUpload.ps1
# ... continue with remaining labs
```

## 📋 Environment-Specific Configurations

### Development Environment

- **Purpose**: Feature development, testing, experimentation
- **Scale**: Small (5 sites, 500-1000 documents)
- **Naming**: `Dev-Sim-*` resource prefix
- **DLP Mode**: TestWithoutNotifications
- **Cleanup**: Frequent, automated cleanup enabled
- **Tenant**: contoso-dev.sharepoint.com

### Test/UAT Environment

- **Purpose**: User acceptance testing, validation
- **Scale**: Medium (10-12 sites, 3000-5000 documents)
- **Naming**: `Test-Sim-*` resource prefix
- **DLP Mode**: TestWithNotifications
- **Cleanup**: Weekly cleanup schedule
- **Tenant**: contoso-test.sharepoint.com

### Production/Demo Environment

- **Purpose**: Client demos, production simulations
- **Scale**: Large (20-25 sites, 15000-20000 documents)
- **Naming**: `Prod-Sim-*` resource prefix
- **DLP Mode**: Enforce (if appropriate)
- **Cleanup**: Manual approval required
- **Tenant**: contoso.sharepoint.com

## 📊 Configuration Comparison Matrix

| Setting | Development | Test | Production |
|---------|------------|------|------------|
| **TenantUrl** | contoso-dev.sharepoint.com | contoso-test.sharepoint.com | contoso.sharepoint.com |
| **TenantDomain** | contoso-dev.onmicrosoft.com | contoso-test.onmicrosoft.com | contoso.onmicrosoft.com |
| **ResourcePrefix** | Dev-Sim | Test-Sim | Prod-Sim |
| **ScaleLevel** | Small | Medium | Large |
| **Site Count** | 5 | 12 | 25 |
| **Document Count** | 500-1000 | 5000 | 20000 |
| **DLP Mode** | TestWithoutNotifications | TestWithNotifications | Enforce |
| **Cleanup** | Automated | Scheduled | Manual |
| **NotificationEmail** | dev-team@ | test-team@ | compliance@ |

## 🔧 Multi-Tenant Consultant Scenarios

### Maintaining Separate Client Configurations

Consultants working across multiple clients can maintain client-specific configurations:

#### Option A: Symbolic Link Approach (Recommended)

Create separate config files per client and use symbolic links:

```powershell
# Create client-specific config files
# Note: Keep these in a configs/ subdirectory or project root
# contoso-global-config.json (Client A)
# fabrikam-global-config.json (Client B)
# adventureworks-global-config.json (Client C)

# Switch to Contoso client
Remove-Item ./global-config.json -Force -ErrorAction SilentlyContinue
New-Item -ItemType SymbolicLink -Path ./global-config.json -Target ./contoso-global-config.json

# Run scripts (automatically use Contoso config)
.\01-SharePoint-Site-Creation\scripts\New-SimulatedSharePointSites.ps1

# Switch to Fabrikam client
Remove-Item ./global-config.json -Force
New-Item -ItemType SymbolicLink -Path ./global-config.json -Target ./fabrikam-global-config.json

# Run scripts (automatically use Fabrikam config)
.\01-SharePoint-Site-Creation\scripts\New-SimulatedSharePointSites.ps1
```

#### Option B: Config Path Parameter

Each script accepts optional `-GlobalConfigPath` parameter:

```powershell
# Execute for Contoso client
.\01-SharePoint-Site-Creation\scripts\New-SimulatedSharePointSites.ps1 `
    -GlobalConfigPath ./contoso-global-config.json

# Execute for Fabrikam client
.\01-SharePoint-Site-Creation\scripts\New-SimulatedSharePointSites.ps1 `
    -GlobalConfigPath ./fabrikam-global-config.json

# Execute for AdventureWorks client
.\01-SharePoint-Site-Creation\scripts\New-SimulatedSharePointSites.ps1 `
    -GlobalConfigPath ./adventureworks-global-config.json
```

#### Option C: Environment Variable

Set environment variable pointing to client config:

```powershell
# Set for Contoso
$env:PURVIEW_SIM_CONFIG = "C:\Configs\contoso-global-config.json"
.\01-SharePoint-Site-Creation\scripts\New-SimulatedSharePointSites.ps1

# Set for Fabrikam
$env:PURVIEW_SIM_CONFIG = "C:\Configs\fabrikam-global-config.json"
.\01-SharePoint-Site-Creation\scripts\New-SimulatedSharePointSites.ps1
```

### Client Configuration Directory Structure

```text
Purview-Data-Governance-Simulation/
├── global-config.json (symlink to active client)
├── configs/
│   ├── contoso-global-config.json
│   ├── fabrikam-global-config.json
│   ├── adventureworks-global-config.json
│   └── global-config.template.json
└── [lab directories...]
```

## ⚠️ Troubleshooting

### Issue: Scripts still reference old tenant

**Symptom**: Scripts attempt to connect to previous environment's tenant URL

**Solution**:

1. Verify `global-config.json` was updated correctly
2. Check no cached connection exists: `Disconnect-PnPOnline`
3. Clear PowerShell session and reload: `Remove-Module PnP.PowerShell -Force`
4. Restart PowerShell session if issues persist

### Issue: Permission errors in new environment

**Symptom**: "Access Denied" or "Insufficient Permissions" errors

**Solution**:

1. Verify AdminEmail account has **Global Admin** role
2. Verify AdminEmail account has **Compliance Admin** role
3. Check site permissions: User must be site collection administrator
4. Ensure browser authentication completed successfully
5. Try explicit permission grant: `Grant-PnPTenantServicePrincipalPermission`

### Issue: Site names conflict in production

**Symptom**: "Site already exists" error during site creation

**Solution**:

1. Update `SharePointSites` array in `global-config.json` with production-specific names
2. Add environment prefix: Change `HR-Simulation` to `Prod-HR-Simulation`
3. Use ResourcePrefix: Leverage `$config.Simulation.ResourcePrefix` in site names
4. Delete conflicting sites if safe to do so: Use Lab 07 cleanup scripts

### Issue: Paths don't exist in new environment

**Symptom**: "Path not found" or "Cannot create directory" errors

**Solution**:

1. Update `Paths` section in `global-config.json` with valid paths for new environment
2. Create directories before running scripts: `New-Item -Path $config.Paths.LogDirectory -ItemType Directory -Force`
3. Use relative paths (default) instead of absolute paths for portability
4. Verify permissions on parent directories

### Issue: Authentication repeatedly prompts

**Symptom**: Browser authentication window appears for every script

**Solution**:

1. Connection caching may not be working - check PnP.PowerShell version (requires 2.x)
2. Use Shared-Utilities connection wrappers that implement session reuse
3. Authenticate once at session start: `.\Shared-Utilities\Connect-PurviewServices.ps1`
4. Check if connection timeout settings are too aggressive

### Issue: Built-in SITs not detected

**Symptom**: Classification reports show zero detections despite PII in documents

**Solution**:

1. Verify built-in SITs are enabled in Microsoft Purview portal
2. Allow time for classification (15-30 min for Small scale)
3. Trigger On-Demand Classification explicitly: Lab 04 scripts
4. Check SIT names match exactly (case-sensitive): Review `BuiltInSITs` array
5. Validate PII patterns in generated documents match SIT regex patterns

## ✅ Portability Validation Checklist

Before considering environment migration complete, verify:

- [ ] `global-config.json` updated with all new environment values
- [ ] TenantUrl, TenantDomain, AdminEmail reflect new tenant
- [ ] ResourcePrefix updated for environment differentiation
- [ ] SharePointSites array has valid site names (no conflicts)
- [ ] DefaultOwner and NotificationEmail are valid accounts in new tenant
- [ ] Paths section points to valid directories (created or creatable)
- [ ] ScaleLevel appropriate for new environment (Small for dev, Large for prod)
- [ ] Prerequisite validation passes: `Test-Prerequisites.ps1`
- [ ] Authentication successful: Browser-based login completed
- [ ] No hardcoded values remain in scripts (all read from config)
- [ ] Lab-specific configs (if present) reference global config correctly
- [ ] Cleanup targets validated to prevent accidental production deletion

## 📚 Additional Resources

- **Microsoft Purview Documentation**: [learn.microsoft.com/purview](https://learn.microsoft.com/en-us/purview/)
- **PnP PowerShell**: [pnp.github.io/powershell/](https://pnp.github.io/powershell/)
- **Sensitive Information Types**: [learn.microsoft.com/purview/sensitive-information-type-entity-definitions](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)
- **DLP Policies**: [learn.microsoft.com/purview/dlp-learn-about-dlp](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp)

---

## 🤖 AI-Assisted Content Generation

This portability guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of environment migration scenarios while maintaining technical accuracy.*
