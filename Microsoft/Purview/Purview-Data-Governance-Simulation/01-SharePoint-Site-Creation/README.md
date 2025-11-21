# Lab 01: SharePoint Site Creation

This lab creates and configures simulated SharePoint Online sites that will host test content for the Purview Data Governance Simulation. Using a 4-script workflow, you will provision sites from configuration, apply permissions and metadata, validate the complete setup, and generate comprehensive reports.

## 🎯 Lab Objectives

- Provision simulated SharePoint sites for departmental scenarios using configuration-driven automation
- Configure site permissions, ownership, and security settings (including external sharing controls)
- Apply consistent site metadata for organizational classification
- Validate comprehensive site setup (accessibility, permissions, libraries, metadata)
- Generate detailed creation and validation reports for audit and troubleshooting
- Prepare fully configured sites for document upload operations

## 📋 Prerequisites

- Lab 00 completed (prerequisites validated and environment initialized)
- SharePoint Administrator permissions in your Microsoft 365 tenant
- Valid global-config.json with SharePointSites array configured
- PnP.PowerShell module installed (validated in Lab 00)

> **🔐 Authentication Note**: Each script in this lab uses browser-based interactive authentication. You do not need to establish a connection beforehand - the scripts handle authentication automatically.

## ⏱️ Estimated Duration

- **Small Scale (5 sites)**: 5-10 minutes
- **Medium Scale (12 sites)**: 10-15 minutes
- **Large Scale (25 sites)**: 15-25 minutes

## 📝 Lab Steps

### Step 1: Review SharePoint Sites Configuration

Before creating sites, review the configuration to understand what will be provisioned:

```powershell
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Data-Governance-Simulation\01-SharePoint-Site-Creation"

# Load configuration and display sites
$config = & "..\Shared-Utilities\Import-GlobalConfig.ps1"
$config.SharePointSites | Format-Table Name, Template, Department, Owner, Description -AutoSize
```

**Expected Output:**

```text
Name                 Template  Department         Owner                Description
----                 --------  ----------         -----                -----------
HR-Simulation        STS#3     Human Resources    admin@contoso.com    Simulated HR site with employee data
Finance-Simulation   STS#3     Finance            admin@contoso.com    Simulated Finance site with financial records
Legal-Simulation     STS#3     Legal              admin@contoso.com    Simulated Legal site with contracts
Marketing-Simulation STS#3     Marketing          admin@contoso.com    Simulated Marketing site with campaigns
IT-Simulation        STS#3     IT                 admin@contoso.com    Simulated IT site with technical docs
```

> **💡 Site Template Note**: `STS#3` is the Team Site template, which provides the best environment for document libraries and collaboration features needed for Purview classification.

### Step 2: Create SharePoint Sites

Run the site creation script to provision all configured sites:

```powershell
.\scripts\New-SimulatedSharePointSites.ps1 -SkipExisting
```

> **🔐 Authentication Note**: You will be prompted to authenticate **multiple times** during this script execution (typically 6+ times for 5 sites). This is expected behavior because:
>
> • **Initial connection**: Authenticates to SharePoint to create sites
> • **Per-site metadata configuration**: Each site requires a separate authenticated connection to configure property bag values (Department, SimulationSite, CompanyPrefix)
> • **PnP PowerShell security**: PnP connections are site-specific and don't persist across different site URLs
>
> **💡 Tip**: Keep your browser authentication tab open throughout the script execution. Most authentications will use cached credentials and complete automatically, but you may need to click "Continue" or "Accept" for each prompt.

> **💡 Best Practice**: The `-SkipExisting` parameter allows safe re-runs by skipping sites that already exist. This prevents errors if you need to re-execute the script or if some sites were created in a previous run.

**What This Script Does:**

- Loads SharePoint sites configuration from global-config.json
- Connects to SharePoint Online using browser-based authentication
- Creates each site with specified template and settings
- Applies site metadata (Department, Owner, Description)
- Implements throttling to respect SharePoint API limits
- Provides progress tracking for multi-site creation
- Logs all operations for audit trail

**Expected Output:**

```text
🔍 Step 1: Load Configuration and Connect to SharePoint
========================================================
   ✅ Configuration loaded successfully
   ✅ SharePoint connection established

🔍 Step 2: Validate Site Configuration
=======================================
   ✅ 5 sites configured for creation

🔍 Step 3: Create SharePoint Sites
===================================
[Progress Bar] Creating SharePoint sites... 20% | Elapsed: 00:01:15 | ETA: 00:05:00
   ✅ Created site: HR-Simulation
   ✅ Created site: Finance-Simulation
   ✅ Created site: Legal-Simulation
   ✅ Created site: Marketing-Simulation
   ✅ Created site: IT-Simulation

🔍 Step 4: Configure Site Metadata
===================================
   [Multiple authentication prompts - see note above]
   ✅ Metadata configured for all sites

🔍 Step 5: Site Creation Summary
=================================
   📊 Sites Created: 5
   📊 Sites Failed: 0
   📊 Total Duration: 00:01:44

🔍 Step 6: Generate Creation Report
====================================
   ✅ Report saved: site-creation-report-[timestamp].json

✅ SharePoint site creation completed successfully
```

> **⏱️ Performance Note**: Site creation typically takes 1-2 minutes per site due to SharePoint provisioning processes. The script implements appropriate throttling to avoid API limits.

**Review the Creation Report:**

After the script completes, review the detailed JSON report to see all site creation details:

```powershell
.\scripts\Show-SiteCreationReport.ps1
```

**Expected Report Output:**

```text
🔍 Step 1: Locate Most Recent Site Creation Report
===================================================
   ✅ Found report: site-creation-report-2025-11-16-171719.json
   📅 Created: 2025-11-16 17:17:19

🔍 Step 2: Load Report Data
============================
   ✅ Report data loaded successfully

📊 Site Creation Report Summary
================================
Sites Configured: 5
Sites Created:    5
Sites Skipped:    0
Sites Failed:     0
Duration:         00:01:44

✅ Created Sites:
   • HR-Simulation
   • Finance-Simulation
   • Legal-Simulation
   • Marketing-Simulation
   • IT-Simulation

✅ Report displayed successfully
```

### Step 3: Configure Site Permissions

After sites are created, configure permissions to match the organizational structure:

```powershell
.\scripts\Set-SitePermissions.ps1
```

**What This Script Does:**

- Sets site ownership based on configuration
- Configures site member permissions
- Applies visitor access controls
- Removes default sharing capabilities (for security simulation)
- Configures site collection administrator
- Validates permission inheritance settings

**Expected Output:**

```text
🔍 Step 1: Load Configuration
==============================
   ✅ Configuration loaded successfully
   ✅ 5 sites to configure

🔍 Step 2: Configure Site Permissions
======================================
   ✅ HR-Simulation: Owner set to admin@contoso.com
   ✅ Finance-Simulation: Owner set to admin@contoso.com
   ✅ Legal-Simulation: Owner set to admin@contoso.com
   ✅ Marketing-Simulation: Owner set to admin@contoso.com
   ✅ IT-Simulation: Owner set to admin@contoso.com

🔍 Step 3: Configure Security Settings
=======================================
   ✅ Disabled external sharing for all sites
   ✅ Applied site collection admin: admin@contoso.com

✅ Site permissions configured successfully
```

### Step 4: Verify Site Creation

Validate that all sites were created successfully and are accessible:

```powershell
.\scripts\Verify-SiteCreation.ps1
```

**What This Script Does:**

- Tests connectivity to each created site
- Validates site properties match configuration
- Checks document library existence
- Verifies permissions are correctly applied
- Tests write access to site document libraries
- Generates detailed validation report

**Expected Output:**

```text
🔍 Step 1: Load Configuration
==============================
   ✅ Configuration loaded successfully
   ✅ 5 sites to verify

🔍 Step 2: Verify Site Creation
================================
   ✅ HR-Simulation: Accessible, Document library present
   ✅ Finance-Simulation: Accessible, Document library present
   ✅ Legal-Simulation: Accessible, Document library present
   ✅ Marketing-Simulation: Accessible, Document library present
   ✅ IT-Simulation: Accessible, Document library present

🔍 Step 3: Verify Permissions
==============================
   ✅ All sites have correct ownership
   ✅ All sites have proper security configuration

🔍 Step 4: Test Document Library Access
========================================
   ✅ Write access validated for all sites

🔍 Step 5: Generate Validation Report
======================================
   ✅ Report saved: site-creation-validation-report-2025-11-16-173535.json

✅ Site creation verification completed - all sites ready for document upload
```

**Review the Validation Report:**

After the verification script completes, review the detailed validation report:

```powershell
.\scripts\Show-ValidationReport.ps1
```

**Expected Report Output:**

```text
🔍 Step 1: Locate Most Recent Validation Report
================================================
   ✅ Found report: site-creation-validation-report-2025-11-16-173535.json
   📅 Created: 2025-11-16 17:35:35

🔍 Step 2: Load Report Data
============================
   ✅ Report data loaded successfully

📊 Site Validation Report Summary
==================================
Sites Verified:              5
Accessible Sites:            5
Document Libraries Present:  5
Owners Correctly Configured: 5
Write Access Validated:      5
External Sharing Disabled:   5
Fully Validated Sites:       5

📋 Site-Level Validation Results
=================================

✅ Fully Validated Sites:
   • HR-Simulation
   • Finance-Simulation
   • Legal-Simulation
   • Marketing-Simulation
   • IT-Simulation

🔒 External Sharing Status
==========================
   ✅ External sharing disabled on all 5 sites

✅ Report displayed successfully
```

### Step 5: Review Created Sites in SharePoint

Open SharePoint in your browser to visually confirm site creation:

1. Navigate to your SharePoint tenant URL (from global-config.json)
2. Go to **Sites** in the left navigation
3. Search for sites with your simulation prefix (e.g., "Simulation")
4. Click on each site to verify accessibility

**What to Verify:**

- [ ] All sites appear in search results
- [ ] Site titles match configuration
- [ ] Document libraries are present
- [ ] You can access each site without errors
- [ ] Sites show correct ownership

## ✅ Validation

Verify lab completion by checking:

- [ ] **All sites created** - New-SimulatedSharePointSites.ps1 completed without errors
- [ ] **Permissions configured** - Set-SitePermissions.ps1 succeeded with external sharing disabled
- [ ] **Verification passed** - Verify-SiteCreation.ps1 shows all sites fully validated
- [ ] **Reports generated** - Both creation and validation reports saved to reports folder
- [ ] **Sites visible in portal** - Can access sites through SharePoint UI
- [ ] **Complete validation** - Show-ValidationReport.ps1 displays all metrics as successful

> **💡 Validation Tip**: Run `.\scripts\Show-ValidationReport.ps1` at any time to review the comprehensive validation status of all sites, including accessibility, permissions, libraries, and external sharing configuration.

## 🚧 Troubleshooting

### Issue: Multiple Authentication Prompts

**Behavior**: Script prompts for authentication 6+ times during execution

**This is expected behavior** - not an issue. The script requires:

- 1 authentication for initial SharePoint connection
- 1 authentication per site for metadata configuration (5 sites = 5 authentications)
- 1 final authentication for cleanup/validation

**Best Practices**:

- Keep the browser authentication window open
- Most prompts will auto-complete using cached credentials
- You may only need to click "Continue" or "Accept" for each prompt
- Don't close the browser between authentications

**Alternative**: If you want to reduce authentication prompts, you can use certificate-based authentication with a registered Azure AD App. See [PnP PowerShell authentication documentation](https://pnp.github.io/powershell/articles/authentication.html) for details.

### Issue: Site Creation Fails with "Site already exists"

**Error**: `A site already exists at https://contoso.sharepoint.com/sites/HR-Simulation`

**Solution**:

```powershell
# Option 1: Use -SkipExisting parameter (Recommended)
.\scripts\New-SimulatedSharePointSites.ps1 -SkipExisting
```

This is the recommended approach as it safely skips existing sites and only creates new ones.

```powershell
# Option 2: Delete existing site and recreate
Remove-PnPTenantSite -Url "https://contoso.sharepoint.com/sites/HR-Simulation" -Force
Remove-PnPDeletedSite -Identity "https://contoso.sharepoint.com/sites/HR-Simulation" -Force

# Then rerun creation script
.\scripts\New-SimulatedSharePointSites.ps1 -SkipExisting
```

**Option 3**: Update site names in global-config.json to avoid conflicts.

### Issue: "Access Denied" During Site Creation

**Error**: `Access is denied. You do not have permission to perform this action`

**Solution**:

- Verify you have **SharePoint Administrator** role
- Check in Microsoft 365 Admin Center → **Roles** → **SharePoint Administrator**
- Wait 5-10 minutes after role assignment for propagation
- Disconnect and reconnect to SharePoint: `Disconnect-PnPOnline; Connect-PnPOnline -Interactive`

### Issue: Site Creation Times Out

**Error**: `The operation has timed out` or long delays during creation

**Solution**:

- This is normal for SharePoint site provisioning (1-2 minutes per site)
- The script includes automatic retry logic
- If persistent, check SharePoint service health: [Microsoft 365 Service Status](https://admin.microsoft.com/ServiceStatus)
- Reduce concurrent operations by modifying script throttling settings

### Issue: Sites Created But Not Visible

**Error**: Sites created successfully but don't appear in SharePoint portal

**Solution**:

- Wait 5-10 minutes for SharePoint indexing to complete
- Clear browser cache and refresh SharePoint portal
- Use direct site URL: `https://contoso.sharepoint.com/sites/SiteName`
- Check SharePoint Admin Center → **Active sites** for comprehensive view

### Issue: Validation Script Shows Errors

**Error**: Verify-SiteCreation.ps1 reports issues with sites after creation

**Solution**:

1. Review the validation report for specific issues:

   ```powershell
   .\scripts\Show-ValidationReport.ps1
   ```

2. Common validation issues and fixes:
   - **Site not accessible**: Wait 2-3 minutes for SharePoint provisioning to complete, then rerun verification
   - **Owner not configured correctly**: Rerun `.\scripts\Set-SitePermissions.ps1` to fix ownership
   - **External sharing not disabled**: Verify SharePoint Administrator role and rerun permissions script
   - **Metadata missing**: This indicates property bag configuration failed - check authentication during site creation

3. After addressing issues, rerun the verification:

   ```powershell
   .\scripts\Verify-SiteCreation.ps1
   ```

## 📚 Additional Resources

- [SharePoint Site Creation Overview](https://learn.microsoft.com/en-us/sharepoint/create-site-collection)
- [PnP PowerShell - New-PnPSite](https://pnp.github.io/powershell/cmdlets/New-PnPSite.html)
- [SharePoint Site Templates](https://learn.microsoft.com/en-us/sharepoint/sites/site-template-comparison)
- [SharePoint Permissions](https://learn.microsoft.com/en-us/sharepoint/understanding-permission-levels)

## 🎓 Learning Objectives Achieved

After completing this lab, you will have:

- ✅ Provisioned multiple SharePoint sites using automated PowerShell scripts
- ✅ Configured site permissions, ownership, and security settings (external sharing controls)
- ✅ Applied site metadata through property bag configuration for organizational classification
- ✅ Executed comprehensive validation testing (accessibility, permissions, libraries, write access, metadata)
- ✅ Generated detailed creation and validation reports for audit and troubleshooting purposes
- ✅ Demonstrated configuration-driven infrastructure provisioning with zero hardcoded values
- ✅ Prepared fully validated sites ready for Purview-monitored document upload operations

## 🚀 Next Steps

Proceed to **Lab 02: Test Data Generation** to create simulated documents containing sensitive information types for Purview classification testing.

```powershell
# Next lab command
cd ..\02-Test-Data-Generation
.\scripts\Invoke-BulkDocumentGeneration.ps1
```

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating SharePoint Online best practices and PowerShell automation standards.

*AI tools were used to enhance productivity and ensure comprehensive coverage of SharePoint site provisioning while maintaining technical accuracy.*
