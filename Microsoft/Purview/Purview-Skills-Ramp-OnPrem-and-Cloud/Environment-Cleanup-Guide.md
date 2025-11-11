# Microsoft Purview Weekend Lab - Environment Cleanup Guide

## 📋 Overview

**Purpose**: Remove Azure resources and Microsoft Purview configurations to manage costs after completing the Purview Skills Ramp project.

**When to Use This Guide**: After completing the on-premises and cloud scanning labs and validating all deliverables, use this guide to properly clean up your environment.

> **💰 Cost Termination Critical**: Complete cleanup ensures no background services continue billing. Estimated total lab cost for weekend usage: **~$5-15** (depending on VM runtime and region).

---

## 🎯 Two-Track Cleanup Approach

This guide provides **two cleanup strategies** based on your learning objectives and future lab needs:

### Track 1: Quick Cleanup (Minimal Re-Creation Impact)

**Use when**: Taking a short break (1-2 weeks) or might return to practice specific scenarios  
**Time to complete**: 15-30 minutes  
**Re-creation time if needed**: 30-90 minutes  
**Cost savings**: ~90% reduction ($0.30-0.50/day remaining)

### Track 2: Full Decommission (Complete Teardown)

**Use when**: Finished with all Purview learning or not returning for months  
**Time to complete**: 30-45 minutes  
**Re-creation time if needed**: 6-10 hours (with multi-day waiting periods)  
**Cost savings**: 100% termination ($0.00/day)

---

## ⚡ Track 1: Quick Cleanup - Remove High-Cost Items Only

**Objective**: Eliminate major cost drivers while preserving configurations that take significant time to recreate.

**Total Time**: 15-30 minutes  
**Cost Reduction**: ~90% (from $1.50-3.00/day → $0.10-0.50/day)  
**Re-Creation Impact**: Low (30-90 minutes to restore if needed)

---

### 📦 Step 1.1: Delete Azure Resource Group (VM + Infrastructure)

**Component**: Scanner VM, SQL Server, all networking resources  
**Current Cost**: **$1.50-3.00/day** (primary cost driver)  
**Deletion Time**: 5-10 minutes (Azure background process)  
**Re-Creation Time**: 4-6 hours (VM deployment + scanner install + initial scan)

> **💰 Primary Cost Driver**: The Scanner VM and SQL Server account for 80-90% of total lab costs. **Always delete the Resource Group** in any cleanup scenario.

**Option A: Azure Portal**:

1. Go to [portal.azure.com](https://portal.azure.com) and sign in.
2. Navigate to **Resource Groups** in the left menu.
3. Locate and click your lab resource group (e.g., `rg-purview-weekend-lab`).

4. Click **Delete resource group** at the top of the page.

5. In the confirmation dialog:
   - Type the resource group name exactly as shown.
   - Check **Apply force delete for selected Virtual machines and Virtual machine scale sets** (optional, speeds up deletion).
   - Click **Delete**.

**Expected Deletion Timeline**:

- Initial submission: Instant.
- Background processing: 5-10 minutes for full deletion.
- Verification: Resource group disappears from your list.

**Option B: Azure CLI Deletion (PowerShell)**:

```powershell
# Set your Azure subscription context (use your subscription ID)
az account set --subscription "YOUR-SUBSCRIPTION-ID"

# Delete the resource group (async process)
az group delete --name "rg-purview-weekend-lab" --yes --no-wait

# Verify deletion status (optional, check after 5-10 minutes)
az group show --name "rg-purview-weekend-lab"
# Expected result: ResourceNotFound error after deletion completes
```

**What Gets Removed**:

- ✅ Scanner VM (`vm-scanner-purview`).
- ✅ SQL Server instance.
- ✅ Virtual network, NSG, public IP.
- ✅ Storage accounts (boot diagnostics, scanner configuration).
- ✅ Managed disks (VM OS disk, data disks).

**Cost Impact**:

- **Before deletion**: $1.50-3.00/day
- **After deletion**: $0.00/day (Resource Group costs eliminated)
- **Savings**: 80-90% of total lab costs

**Re-Creation Requirements** (if needed):

1. **New VM deployment**: 30-45 minutes (Azure deployment time).
2. **Scanner installation**: 1-2 hours (Install-Scanner.ps1 + prerequisites).
3. **Initial content scan**: 2-3 hours (first scan discovery of repositories).
4. **Total**: 4-6 hours (with automation scripts from Labs 01-02).

> **💡 Automation Benefit**: The scripts created during Labs 01-04 reduce manual recreation by ~1-2 hours compared to portal-only configuration.

---

### 📦 Step 1.2: Delete SharePoint Test Site (Optional Lab Content)

**Component**: Test SharePoint team site with sensitive data files  
**Current Cost**: $0.05-0.10/day (SharePoint storage)  
**Deletion Time**: 5 minutes  
**Re-Creation Time**: 30-60 minutes (site + file uploads)  
**Recovery Option**: ✅ Instant restore if < 93 days (recycle bin)

> **🌐 Cloud Lab Content**: This removes the SharePoint test site created in **Section 03 Part 1 (Cloud-01-SharePoint-Foundation)**. Only needed if you created cloud scanning content.

**Portal Deletion Steps**:

1. Go to [SharePoint Admin Center](https://admin.microsoft.com/sharepoint).
2. Navigate to **Sites → Active sites**.
3. Find your test site (e.g., `Purview Test Site` or similar).

4. Select the site and click **Delete** from the toolbar.

5. Confirmation dialog appears:
   - Review site details to ensure correct site.
   - Click **Delete** to confirm.

**Expected Deletion Timeline**:

- Site moved to **Deleted sites** recycle bin: Instant.
- Retention period: 93 days before permanent deletion.
- Storage released: After 93 days (or manual permanent delete).

**Permanent Deletion** (Optional - if you want immediate storage release):

1. In SharePoint Admin Center, go to **Sites → Deleted sites**.
2. Select your site from the deleted sites list.
3. Click **Delete permanently** → Confirm.

**Recovery Option** (if needed within 93 days):

1. In SharePoint Admin Center, go to **Sites → Deleted sites**.
2. Select your site.
3. Click **Restore** → Site returns to active status immediately.

**What Gets Removed**:

- ✅ SharePoint team site structure.
- ✅ Document libraries with test sensitive files.
- ✅ Site permissions and configurations.
- ✅ Any retention labels applied to cloud content.

**Cost Impact**:

- **Before deletion**: $0.05-0.10/day (storage)
- **After deletion**: $0.00/day (storage released after 93 days)
- **Savings**: Minimal but eliminates test content overhead

**Re-Creation Requirements** (if needed):

1. **Create new team site**: 10-15 minutes (portal wizard).
2. **Upload test files with sensitive data**: 15-20 minutes (credit cards, SSNs).
3. **Configure document library**: 5-10 minutes (columns, views).
4. **Total**: 30-45 minutes.

---

### 📦 Step 1.3: Verify Cost Termination

**Objective**: Confirm all major cost drivers have been eliminated.

**Verification Commands** (PowerShell):

```powershell
# 1. Verify Resource Group deletion
az group list --output table --query "[].{Name:name, Location:location, Status:properties.provisioningState}"
# Expected: Your lab resource group should NOT appear in the list

# 2. Check for orphaned resources (should return empty)
az resource list --output table --query "[?resourceGroup=='rg-purview-weekend-lab']"
# Expected: Empty result or "Resource group 'rg-purview-weekend-lab' could not be found"

# 3. Check Azure Cost Management (wait 24-48 hours for final charges)
# Go to: https://portal.azure.com → Cost Management + Billing → Cost Analysis
# Expected: $0.00/day after cleanup (may show residual charges for partial days)
```

**Expected Daily Cost After Track 1 Cleanup**:

- **Azure Resources**: $0.00/day (Resource Group deleted)
- **SharePoint Storage**: $0.00/day (site deleted or in recycle bin)
- **Microsoft Purview**: $0.10-0.30/day (scanner metadata, DLP policies remain)
- **Total**: ~$0.10-0.50/day (90% reduction from $1.50-3.00/day)

> **📊 Cost Monitoring**: Check Azure Cost Management 2-3 days after cleanup to verify costs dropped to minimal levels. Any significant remaining costs indicate orphaned resources.
>
> **💡 Purview Metadata Cost**: The $0.10-0.30/day residual cost represents Purview service metadata (scanner cluster registrations, DLP policies, retention labels). These are minimal-cost configuration items that take significant time to recreate, which is why Track 1 preserves them.

---

## 🗑️ Track 2: Full Decommission - Complete Environment Teardown

**Objective**: Remove ALL lab components including configurations that take days/weeks to recreate.

**Total Time**: 30-45 minutes (deletion actions)  
**Cost Reduction**: 100% termination ($0.00/day)  
**Re-Creation Impact**: **HIGH** (6-10 hours + multi-day waiting periods)

> ⚠️ **Warning**: Full decommission removes components with **significant re-creation time**. Only proceed if you are **completely finished** with Purview learning objectives or willing to wait days for retention label re-activation.

---

### 📦 Step 2.1: Complete Track 1 Cleanup First

**Before proceeding with Track 2, ensure you have completed all Track 1 steps**:

- ✅ Azure Resource Group deleted (Step 1.1).
- ✅ SharePoint test site deleted (Step 1.2).
- ✅ Cost termination verified (Step 1.3).

Track 2 builds on Track 1 by removing lower-cost but time-intensive configuration items.

---

### 📦 Step 2.2: Delete Entra ID App Registration (Service Principal)

**Component**: Scanner authentication service principal  
**Current Cost**: $0.00 (no cost)  
**Deletion Time**: 2-3 minutes  
**Re-Creation Time**: 15-30 minutes (app + permissions + admin consent)

> **🔐 Security Note**: This removes the service principal credentials used by the scanner. Without the Resource Group (VM), this app registration is orphaned and serves no purpose.

**Portal Deletion Steps**:

1. Go to [Entra ID Admin Center](https://entra.microsoft.com).
2. Navigate to **Applications → App registrations**.
3. Select **All applications** tab.
4. Find your scanner app registration (e.g., `Purview-Scanner-App`).

5. Click the app name to open details.
6. Click **Delete** at the top → Confirm deletion.

**Expected Deletion Timeline**:

- App registration removed: Instant.
- Service principal deleted: Automatic (within minutes).
- Permissions revoked: Immediate.

**What Gets Removed**:

- ✅ App registration and client ID.
- ✅ Client secret credentials.
- ✅ API permissions (Microsoft Graph, Azure Rights Management).
- ✅ Service principal object.

**Re-Creation Requirements** (if needed):

1. **Create new app registration**: 5 minutes (portal wizard).
2. **Generate client secret**: 2 minutes (Certificates & secrets).
3. **Assign API permissions**: 5 minutes (Microsoft Graph, AIPService).
4. **Admin consent**: 3 minutes (tenant admin approval).
5. **Update scanner configuration**: 5-10 minutes (reconfigure with new credentials).
6. **Total**: 20-30 minutes.

---

### 📦 Step 2.3: Delete Scanner Cluster & Scan Job Metadata

**Component**: Purview scanner cluster and scan job configurations  
**Current Cost**: $0.00 (no cost, metadata only)  
**Deletion Time**: 5 minutes  
**Re-Creation Time**: 1-2 hours (cluster + scan job + first scan)

> **📋 Metadata Only**: Without the Scanner VM (deleted in Track 1), this scanner cluster is orphaned. Deleting removes configuration metadata from the Microsoft Purview portal.

**Portal Deletion Steps**:

1. Go to [Microsoft Purview Portal](https://purview.microsoft.com).
2. Navigate to **Data Map → Scanning → Scanner Clusters**.
3. Locate your scanner cluster (e.g., `scanner-cluster-purview`).

4. Click **Delete** (trash icon) → Confirm deletion.

5. Navigate to **Data Map → Scanning → Scan Jobs**.
6. Delete all scan jobs associated with your cluster.

**Expected Deletion Timeline**:

- Cluster metadata removed: Instant.
- Scan job history cleared: Automatic.
- Repository references orphaned: Immediate.

**What Gets Removed**:

- ✅ Scanner cluster registration.
- ✅ Scanner SQL database connection.
- ✅ All scan jobs and schedules.
- ✅ Scan history and logs (portal view).
- ✅ Repository path configurations.

**Re-Creation Requirements** (if needed):

1. **Recreate cluster**: 15-20 minutes (requires VM from Track 1).
2. **Create new scan job**: 20-30 minutes (repository paths + schedule).
3. **First content scan**: 2-3 hours (discovery of file shares).
4. **Total**: 3-4 hours (requires VM infrastructure).

> **⚠️ Dependency Note**: Scanner cluster requires VM infrastructure. Cannot recreate without first completing Track 1 Azure Resource Group deployment.

---

### 📦 Step 2.4: Delete or Disable DLP Policy

**Component**: Microsoft Purview DLP policy (on-premises enforcement)  
**Current Cost**: $0.00 (no cost)  
**Deletion Time**: 5 minutes  
**Re-Creation Time**: 2-4 hours (policy creation + 1-2 hour sync + enforcement scan)

> ⚠️ **Re-Commission Warning**: DLP policies take **1-2 hours to sync** to on-premises scanners after creation. Factor this waiting period into re-creation plans.

**Option A: Turn Off DLP Policy (Preserve Configuration)**:

**Use when**: Might return to DLP testing within 1-2 months

**Portal Steps**:

1. Go to [Microsoft Purview Portal](https://purview.microsoft.com).
2. Navigate to **Solutions → Data Loss Prevention → Policies**.
3. Find your DLP policy (e.g., `Weekend Lab DLP - File Shares`).

4. Click the policy name → Click **Edit policy**.
5. In the **Policy settings** page:
   - Set **Status** to **Off** (turns off enforcement).
   - Click **Save**.

**Impact**:

- ✅ Policy configuration preserved.
- ✅ No enforcement actions on scanner.
- ✅ Policy appears in portal as "Off".
- ✅ Can be re-enabled instantly (no sync wait).

**Re-Activation Requirements** (if needed):

1. **Enable policy**: Instant (toggle to "On").
2. **Sync to scanner**: 5-10 minutes (policy status update).
3. **Enforcement scan**: 30-60 minutes (next scheduled scan).
4. **Total**: 40-70 minutes (no re-creation needed).

**Option B: Delete DLP Policy (Permanent Removal)**:

**Use when**: Completely finished with DLP learning objectives

**Portal Steps**:

1. Go to [Microsoft Purview Portal](https://purview.microsoft.com).
2. Navigate to **Solutions → Data Loss Prevention → Policies**.
3. Find your DLP policy.

4. Click **Delete** (trash icon) → Confirm deletion.

**Expected Deletion Timeline**:

- Policy metadata removed: Instant.
- Policy sync to scanner: 10-30 minutes (removal notification).
- Enforcement stopped: Immediate on scanner.

**What Gets Removed**:

- ✅ DLP policy definition (sensitive info types, actions).
- ✅ Policy rules and conditions.
- ✅ Enforcement actions (block, audit).
- ✅ Policy history and compliance reports.

**Re-Creation Requirements** (if needed):

1. **Recreate policy**: 30-45 minutes (sensitive info types + rules + conditions).
2. **Sync to scanner**: **1-2 hours** (policy distribution waiting period).
3. **First enforcement scan**: 1-2 hours (depending on repository size).
4. **Total**: 2.5-4.5 hours (with significant sync waiting period).

> **📊 Lab Context**: This removes the DLP policy created in **Section 02 (OnPrem-03-DLP-Policy-Configuration)**. All DLP detections in Activity Explorer will show policy as deleted.

**Recommendation**:

- **Turn Off** if you might test DLP scenarios again (preserves config, instant re-enable)
- **Delete** only if completely done with Purview DLP learning

---

### 📦 Step 2.5: Delete or Disable Retention Labels & Auto-Apply Policies

**Component**: Retention labels and auto-apply policies  
**Current Cost**: $0.00 (no cost)  
**Deletion Time**: 10-15 minutes (if no files tagged)  
**Re-Creation Time**: **1-7 days** (simulation + label activation)

> ⚠️ **CRITICAL RE-COMMISSION WARNING**: Retention labels take **up to 7 days to activate** after creation. This is the **longest re-creation waiting period** of any component. Only delete if completely finished with Purview learning.

**Deletion Prerequisites**:

- ✅ **No files currently tagged**: Retention labels can only be deleted if no files have the label applied.
- ✅ **Auto-apply policy disabled/deleted**: Remove policies before deleting labels.
- ✅ **24-48 hour cache clear**: May need to wait for label cache to clear.

**Option A: Turn Off Auto-Apply Policy (Preserve Labels)**:

**Use when**: Might return to retention testing, want to keep labels available

**Portal Steps**:

1. Go to [Microsoft Purview Portal](https://purview.microsoft.com).
2. Navigate to **Solutions → Records Management → Label policies**.
3. Find your auto-apply policy (e.g., `Auto-Apply Retention Labels - SharePoint`).

4. Click the policy name → Click **Edit policy**.
5. Set **Status** to **Off** → Click **Save**.

**Impact**:

- ✅ Retention labels still exist (visible to users).
- ✅ No automatic labeling on new files.
- ✅ Existing labeled files retain labels.
- ✅ Can be re-enabled instantly.

**Re-Activation Requirements** (if needed):

1. **Enable policy**: Instant (toggle to "On").
2. **Processing time**: 1-24 hours (auto-apply to matching files).
3. **Total**: 1-24 hours (no re-creation needed).

**Option B: Delete Auto-Apply Policy & Retention Labels (Permanent Removal)**:

**Use when**: Completely finished with retention learning objectives

**Step 1: Delete Auto-Apply Policy**:

1. Go to [Microsoft Purview Portal](https://purview.microsoft.com).
2. Navigate to **Solutions → Records Management → Label policies**.
3. Find your auto-apply policy.

4. Click **Delete** (trash icon) → Confirm deletion.

**Expected Deletion Timeline**:

- Policy metadata removed: Instant.
- Policy processing stopped: Immediate.
- Existing labeled files: Labels remain until manually removed or label deleted.

**Step 2: Verify No Files Are Tagged** (Required before deleting labels):

**Option A: SharePoint Admin Center Check**:

1. Go to [SharePoint Admin Center](https://admin.microsoft.com/sharepoint).
2. Navigate to **Sites → Active sites**.
3. Select your test site → Click **View files**.
4. Check **Retention** column for any files with labels applied.

**Option B: PowerShell Check** (Comprehensive):

```powershell
# Connect to SharePoint Online
Connect-SPOService -Url "https://YOUR-TENANT-admin.sharepoint.com"

# Get all sites
$sites = Get-SPOSite -Limit All

# Check for retention labels applied
foreach ($site in $sites) {
    Write-Host "Checking site: $($site.Url)" -ForegroundColor Cyan
    # Note: Detailed file-level label checking requires PnP PowerShell or manual portal inspection
}
```

**If Files Are Tagged**:

- **Option 1**: Remove labels manually from files (portal or PowerShell).
- **Option 2**: Delete SharePoint test site first (Step 1.2), wait 24-48 hours, then delete labels.
- **Option 3**: Wait 24-48 hours for label cache to clear.

**Step 3: Delete Retention Labels**:

1. Go to [Microsoft Purview Portal](https://purview.microsoft.com).
2. Navigate to **Solutions → Records Management → File plan**.
3. Find your retention labels (e.g., `Financial Records 7yr`, `Healthcare Records 10yr`).

4. Select each label → Click **Delete** → Confirm deletion.

**Expected Deletion Timeline**:

- Label removed from portal: Instant (if no files tagged).
- Label availability cleared: 24-48 hours (cache propagation).
- Error if files tagged: Deletion blocked until files untagged.

**What Gets Removed**:

- ✅ Retention label definitions.
- ✅ Auto-apply policies and rules.
- ✅ Retention periods and disposal actions.
- ✅ Label metadata and descriptions.

**Re-Creation Requirements** (if needed):

1. **Create retention labels**: 30-45 minutes (define retention periods + disposal).
2. **Simulate label application**: **1-2 days** (Content Explorer processing).
3. **Create auto-apply policy**: 20-30 minutes (conditions + locations).
4. **Label activation**: **2-7 days** (Microsoft backend processing).
5. **Auto-labeling processing**: 1-24 hours (apply to matching files).
6. **Total**: **4-10 days** (with multi-day waiting periods).

> **📊 Lab Context**: This removes retention labels created in **Section 03 Part 2 (Cloud-02-Retention-Labels)** and auto-apply policies from **Section 03 Part 3 (Cloud-03-Auto-Apply-Policies)**.

**Waiting Period Breakdown**:

- **Simulation waiting**: 1-2 days (Content Explorer to process label simulation).
- **Label activation**: 2-7 days (Microsoft Purview backend processing).
- **Auto-apply processing**: 1-24 hours (policy applies labels to matching files).
- **Total maximum wait**: **Up to 10 days** for full re-creation and activation.

**Recommendation**:

- **Turn Off Policy** if you might test retention scenarios again (preserves labels, instant re-enable)
- **Delete Everything** only if completely finished with Purview retention learning (longest re-commission wait)

---

### 📦 Step 2.6: Final Cost Verification

**Objective**: Confirm 100% cost termination after Track 2 full decommission.

**Verification Commands** (PowerShell):

```powershell
# 1. Verify Resource Group deletion (from Track 1)
az group list --output table --query "[].{Name:name, Location:location}"
# Expected: No lab resource groups

# 2. Verify Entra ID app deleted
az ad app list --display-name "Purview-Scanner-App" --output table
# Expected: Empty result

# 3. Check Azure Cost Management (24-48 hours after cleanup)
# Go to: https://portal.azure.com → Cost Management + Billing → Cost Analysis
# Filter: Last 7 days, Group by: Resource
# Expected: $0.00/day for all lab resources
```

**Manual Portal Verification**:

1. **Microsoft Purview Portal** ([purview.microsoft.com](https://purview.microsoft.com)):
   - Navigate to **Data Map → Scanning → Scanner Clusters**
   - Expected: No lab scanner clusters
   - Navigate to **Solutions → Data Loss Prevention → Policies**
   - Expected: No lab DLP policies (or policies set to "Off" if using disable option)
   - Navigate to **Solutions → Records Management → File plan**
   - Expected: No lab retention labels (or labels with no policies if using disable option)

2. **SharePoint Admin Center** ([admin.microsoft.com/sharepoint](https://admin.microsoft.com/sharepoint)):
   - Navigate to **Sites → Active sites**
   - Expected: No test SharePoint sites (or site in "Deleted sites" if < 93 days)

3. **Entra ID Admin Center** ([entra.microsoft.com](https://entra.microsoft.com)):
   - Navigate to **Applications → App registrations**
   - Expected: No lab app registrations

**Expected Daily Cost After Track 2 Full Decommission**:

- **Azure Resources**: $0.00/day.
- **SharePoint Storage**: $0.00/day.
- **Microsoft Purview**: $0.00/day.
- **Entra ID**: $0.00/day.
- **Total**: **$0.00/day** (100% cost termination).

> **📊 Cost Monitoring**: Check Azure Cost Management 2-3 days after cleanup. Any charges indicate orphaned resources or unexpected usage. Monitor for 7 days to catch monthly/weekly billed services.

---

## 📋 Final Cleanup Checklist

**Track 1: Quick Cleanup** (if completed):

- [ ] Azure Resource Group deleted (`rg-purview-weekend-lab`).
- [ ] SharePoint test site deleted or moved to recycle bin.
- [ ] Cost termination verified: $0.10-0.50/day remaining.
- [ ] Purview configurations preserved (DLP policies, retention labels).
- [ ] Re-creation time if needed: 30-90 minutes.

**Track 2: Full Decommission** (if completed):

- [ ] All Track 1 items completed above.
- [ ] Entra ID app registration deleted (`Purview-Scanner-App`).
- [ ] Scanner cluster & scan job metadata deleted.
- [ ] DLP policy deleted or disabled (status confirmed in portal).
- [ ] Retention labels & auto-apply policies deleted or disabled.
- [ ] Cost termination verified: $0.00/day.
- [ ] Re-creation time if needed: 6-10 hours + multi-day waiting periods.

---

## 📊 Cleanup Summary Template

**Copy this template to document your cleanup actions**:

```markdown
# Microsoft Purview Weekend Lab - Cleanup Summary
**Date**: [YYYY-MM-DD]
**Cleanup Track**: Track 1: Quick Cleanup / Track 2: Full Decommission

## Resources Deleted
- [ ] Azure Resource Group: [resource-group-name]
- [ ] SharePoint Test Site: [site-name or N/A]
- [ ] Entra ID App Registration: [app-name or N/A]
- [ ] Scanner Cluster: [cluster-name or N/A]
- [ ] DLP Policy: [Deleted / Disabled / N/A]
- [ ] Retention Labels: [Deleted / Disabled / N/A]

## Cost Verification
- **Cost Before Cleanup**: $[amount]/day
- **Cost After Cleanup**: $[amount]/day
- **Total Lab Cost**: $[total for weekend]
- **Verification Date**: [YYYY-MM-DD]

## Re-Creation Time (if needed)
- **Track 1 Components**: 30-90 minutes
- **Track 2 Components**: 6-10 hours + multi-day waits
- **Automation Benefit**: ~1-2 hours saved with lab scripts

## Notes
[Add any custom notes, issues encountered, or deviations from standard cleanup]
```

---

## 💡 Automation Benefit - Script Impact on Re-Creation Time

> **🚀 Lab Scripts Reduce Re-Creation Time**: The 22 PowerShell scripts created during Labs 01-04 significantly reduce environment re-creation time compared to manual portal configuration.

**Scripts Created During This Lab**:

**Lab 01 - OnPrem-02 Discovery Scans** (12 scripts):

- Scanner VM: Update-ScannerConfiguration, Create-ScannerSMBShares, Test-RepositoryAccess, Enable-FileSharingFirewall, Grant-ScannerNTFSPermissions, Start-InitialScan, Monitor-ScanProgress, Get-DetailedScanReport.
- Admin Machine: Verify-OnPrem01Completion, Test-RepositoryPathDiagnostics, Update-RepositoryPathsPostFix, Invoke-ScanAfterFix.

**Lab 02 - OnPrem-03 DLP Policy Configuration** (8 scripts):

- Scanner VM: Enable-ScannerDLP, Sync-DLPPolicies, Start-DLPScanWithReset, Monitor-DLPScan, Get-DLPScanReport.
- Admin Machine: Verify-OnPrem02Completion, Test-DLPPolicySync, Verify-ActivityExplorerSync.

**Lab 04 - OnPrem-04 DLP Enforcement Validation** (2 scripts):

- Admin Machine: Generate-DLPExecutiveSummary, Invoke-WeeklyDLPMonitoring.

**Time Savings with Scripts**:

| Task | Manual (Portal Only) | With Scripts | Time Saved |
|------|---------------------|--------------|------------|
| Scanner configuration | 60-90 min | 30-45 min | **30-45 min** |
| DLP policy setup & sync | 90-120 min | 45-60 min | **45-60 min** |
| Monitoring & reporting | 45-60 min | 15-30 min | **30 min** |
| **Total Recreation** | **3-4.5 hours** | **1.5-2.25 hours** | **~1-2 hours saved** |

**Script Benefits**:

- ✅ **Automated validation**: Scripts verify prerequisites and configurations.
- ✅ **Error handling**: Comprehensive try-catch blocks prevent incomplete setups.
- ✅ **Consistent results**: Eliminates manual configuration errors.
- ✅ **Progress monitoring**: Real-time status updates during operations.
- ✅ **Detailed reporting**: Automated DLP detection summaries and dashboards.

> **💡 Recommendation**: Keep your lab scripts repository even after cleanup. These scripts accelerate future Purview learning environments and serve as portfolio demonstration of automation capabilities.

---

## 🔬 Track 3: Supplemental Labs Cleanup (Optional Advanced Components)

**Objective**: Remove test data, scripts, and configurations created during optional Supplemental Labs.

**Total Time**: 15-30 minutes (if supplemental labs were completed)  
**Cost Impact**: No additional cost reduction (supplemental labs use existing infrastructure)  
**Re-Creation Impact**: Low (1-2 hours to regenerate test data and re-run scripts)

> **📋 Scope Note**: This section only applies if you completed any of the 4 Supplemental Labs. If you only completed Sections 1-3 (Core Labs), skip this section entirely.

---

### 📦 Step 3.1: Clean Up Test Data Files

**Components**: Test documents generated by supplemental lab scripts  
**Deletion Time**: 5-10 minutes  
**Re-Creation Time**: 15-30 minutes (automated script generation)

**Test Data Locations**:

| Supplemental Lab | Test Data Location | Files Generated |
|-----------------|-------------------|-----------------|
| **Advanced-Cross-Platform-SIT-Analysis** | `C:\PurviewLab\ActivityExplorer_Export.csv` | Activity Explorer CSV exports |
| **Advanced-Remediation** | `C:\RemediationLab\` | Test sensitive files (Finance, HR, Legal) |
| **Advanced-SharePoint-SIT-Analysis** | SharePoint test site document library | DLP test documents |
| **Custom-Classification** | `C:\TrainableClassifier\` | 300+ training samples (financial, business docs) |

**Cleanup Commands** (PowerShell):

```powershell
# Remove test data directories (if supplemental labs were completed)
$testDataPaths = @(
    "C:\PurviewLab",
    "C:\RemediationLab",
    "C:\TrainableClassifier",
    "C:\Reports"  # From OnPrem-04 DLP reporting
)

foreach ($path in $testDataPaths) {
    if (Test-Path $path) {
        Write-Host "Removing test data: $path" -ForegroundColor Yellow
        Remove-Item $path -Recurse -Force
        Write-Host "  ✅ Removed successfully" -ForegroundColor Green
    } else {
        Write-Host "  ⏭️ Path not found (lab not completed): $path" -ForegroundColor Gray
    }
}

Write-Host "`n✅ Test data cleanup complete" -ForegroundColor Green
```

**What Gets Removed**:

- ✅ Activity Explorer CSV exports.
- ✅ Remediation test files (duplicates, severity-based samples).
- ✅ Trainable classifier training samples (positive/negative).
- ✅ Generated reports and analysis outputs.
- ✅ PowerShell script test outputs.

**Re-Creation Requirements** (if needed):

1. **Test document generation**: 15-30 minutes (automated scripts).
2. **Activity Explorer re-export**: 5-10 minutes (manual portal export).
3. **Training samples**: 30-45 minutes (Generate-PositiveTrainingSamples.ps1, Generate-NegativeTrainingSamples.ps1).
4. **Total**: 50-85 minutes.

---

### 📦 Step 3.2: Remove SharePoint Test Documents (Optional)

**Component**: Test documents uploaded to SharePoint during Advanced-SharePoint-SIT-Analysis  
**Deletion Time**: 5-10 minutes  
**Re-Creation Time**: 15-20 minutes (automated script + portal)

> **🌐 SharePoint Cleanup**: This is separate from the main SharePoint test site deletion in Track 1. This removes additional test documents created specifically for advanced SIT analysis.

**Portal Deletion Steps**:

1. Go to your SharePoint test site (created in Cloud-01-SharePoint-Foundation).
2. Navigate to **Documents** library.
3. Select all test documents created by `Generate-TestDocuments.ps1` script.

4. Click **Delete** → Confirm deletion.

**PowerShell Cleanup Option** (Alternative):

```powershell
# Connect to SharePoint Online (requires PnP PowerShell)
Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/PurviewTestSite" -Interactive

# Get all test documents (filter by naming pattern)
$testDocs = Get-PnPListItem -List "Documents" -PageSize 1000 | 
    Where-Object {$_["FileLeafRef"] -like "SIT-Test-*"}

Write-Host "Found $($testDocs.Count) test documents to remove" -ForegroundColor Yellow

# Remove test documents
foreach ($doc in $testDocs) {
    Remove-PnPListItem -List "Documents" -Identity $doc.Id -Force
    Write-Host "  ✅ Removed: $($doc['FileLeafRef'])" -ForegroundColor Gray
}

Write-Host "`n✅ SharePoint test documents cleanup complete" -ForegroundColor Green
```

**What Gets Removed**:

- ✅ SIT test documents (credit cards, SSNs, healthcare data).
- ✅ DLP policy test files.
- ✅ Custom SIT validation documents.

---

### 📦 Step 3.3: Delete Trainable Classifier (If Created)

**Component**: Custom trainable classifier from Custom-Classification lab  
**Deletion Time**: 5 minutes  
**Re-Creation Time**: **24-28 hours** (3-4 hours data prep + 24-hour ML training)

> ⚠️ **CRITICAL RE-COMMISSION WARNING**: Trainable classifiers require **24-hour ML training** after creation. Only delete if you are completely finished with custom classification learning.

**Portal Deletion Steps**:

1. Go to [Microsoft Purview Portal](https://purview.microsoft.com).
2. Navigate to **Data Classification → Trainable classifiers**.
3. Select **Custom classifiers** tab.
4. Find your custom classifier (e.g., `Financial Reports Classifier`).

5. Click **Delete** (trash icon) → Confirm deletion.

**Expected Deletion Timeline**:

- Classifier metadata removed: Instant.
- Training data released: Automatic.
- Model deprovisioned: Immediate.

**What Gets Removed**:

- ✅ Custom trainable classifier definition.
- ✅ ML model and training data references.
- ✅ Classification rules and confidence thresholds.
- ✅ Classifier accuracy metrics and validation results.

**Re-Creation Requirements** (if needed):

1. **Generate training samples**: 1-2 hours (300+ documents).
2. **Upload and curate samples**: 1-2 hours (organize positive/negative).
3. **Submit for training**: 10 minutes.
4. **ML training wait**: **24 hours** (Microsoft backend processing).
5. **Accuracy validation**: 30-60 minutes (test and refine).
6. **Total**: **26-28 hours** (with 24-hour ML training wait).

**Recommendation**:

- **Keep classifier** if you might need custom classification again (no cost to maintain).
- **Delete only** if completely finished with Purview custom classification learning.

---

### 📦 Step 3.4: Supplemental Labs Cleanup Verification

**Verification Commands** (PowerShell):

```powershell
# 1. Verify test data directories removed
$expectedPaths = @("C:\PurviewLab", "C:\RemediationLab", "C:\TrainableClassifier", "C:\Reports")
$remainingPaths = $expectedPaths | Where-Object { Test-Path $_ }

if ($remainingPaths.Count -eq 0) {
    Write-Host "✅ All test data directories removed" -ForegroundColor Green
} else {
    Write-Host "⚠️ Remaining test data paths: $($remainingPaths -join ', ')" -ForegroundColor Yellow
}

# 2. Check SharePoint test documents (requires PnP PowerShell)
# Connect-PnPOnline -Url "https://yourtenant.sharepoint.com/sites/PurviewTestSite" -Interactive
# $remainingTestDocs = Get-PnPListItem -List "Documents" -PageSize 1000 | 
#     Where-Object {$_["FileLeafRef"] -like "SIT-Test-*"}
# Write-Host "SharePoint test documents remaining: $($remainingTestDocs.Count)" -ForegroundColor Cyan

# 3. Verify trainable classifier deleted (manual portal check required)
Write-Host "`n📋 Manual Verification Required:" -ForegroundColor Yellow
Write-Host "  • Check Purview portal for trainable classifier deletion" -ForegroundColor Gray
Write-Host "  • Verify SharePoint test site for remaining test documents" -ForegroundColor Gray
```

**Expected State After Supplemental Cleanup**:

- **Local Test Data**: All C:\ test directories removed
- **SharePoint Documents**: Test documents deleted from document libraries
- **Trainable Classifiers**: Custom classifiers removed from Purview portal
- **Scripts**: Scripts remain in repository for future use (recommended to keep)

**Cost Impact**:

- **Before supplemental cleanup**: $0.00/day (supplemental labs don't add infrastructure cost)
- **After supplemental cleanup**: $0.00/day (no change)
- **Purpose**: Removes test data clutter, frees up local storage

---

## 🤖 AI-Assisted Content Generation

This guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of environment cleanup procedures while maintaining technical accuracy for Azure cost management and lab decommissioning.*