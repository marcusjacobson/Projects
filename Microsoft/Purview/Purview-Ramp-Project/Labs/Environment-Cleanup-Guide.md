# Microsoft Purview Weekend Lab - Environment Cleanup Guide

## 📋 Overview

**Purpose**: Remove all Azure resources and Microsoft Purview configurations to terminate ongoing costs after completing Labs 01-04.

**When to Use This Guide**: After completing **Lab 04 Part 2** and validating all deliverables, use this guide to properly clean up your lab environment.

> **💰 Cost Termination Critical**: Complete cleanup ensures no background services continue billing. Estimated total lab cost for weekend usage: **~$5-15** (depending on VM runtime and region).

---

## ⚠️ Critical Re-Commission Waiting Periods

**Before deleting any components, understand the time investment required to recreate them if needed:**

| Component | Deletion Impact | Re-Commission Time | Recommendation |
|-----------|----------------|-------------------|----------------|
| **Azure Resource Group** (Step 1) | VM, SQL, networking deleted | **4-6 hours** (full VM deployment + scanner install) | ✅ Safe to delete (major cost driver) |
| **Entra ID App Registration** (Step 2) | Scanner authentication broken | **15-30 minutes** (recreate app + assign permissions) | ✅ Safe to delete (no cost) |
| **Scanner Cluster & Scan Job** (Step 3) | Scanner configuration lost | **1-2 hours** (recreate cluster + scan job + first scan) | ✅ Safe to delete (no cost, requires VM anyway) |
| **DLP Policy** (Step 4) | DLP enforcement stopped | **2-4 hours** (recreate policy + 1-2hr sync + enforcement scan) | ⚠️ Consider disabling instead |
| **Retention Labels** (Step 5) | Auto-apply stopped | **1-7 days** (recreate label + policy + simulation/activation) | ⚠️ Consider disabling instead |
| **SharePoint Test Site** (Step 6) | Test content deleted | **30-60 minutes** (recreate site + upload files + configure) | ✅ Safe to delete (minimal cost) |

**Decision Matrix**:

- **Definitely Delete** (Major Cost Savings): Azure Resource Group (Step 1)
- **Safe to Delete** (No Cost): Entra ID App Registration (Step 2), Scanner configurations (Step 3), SharePoint test site (Step 6)
- **Consider Carefully** (Time-Intensive Re-Commission): DLP Policy (Step 4), Retention Labels (Step 5)

**Recommended Cleanup Approaches by Scenario**:

| Your Scenario | Recommended Actions |
|---------------|---------------------|
| **Never returning to lab** | Delete everything (Steps 1-6) |
| **Might return in 1-2 weeks** | Delete Steps 1, 2, 3, 6; **Disable** (not delete) Steps 4, 5 |
| **Actively practicing/demonstrating** | Delete Steps 1, 6; Keep Steps 2, 3, 4, 5 active |
| **Production tenant with real policies** | Delete Steps 1, 3, 6 only; Keep production policies in Steps 4, 5 |

---

## ⏳ Timing Recommendation

**Complete Cleanup Immediately After**:

- ✅ Lab 04 Part 2 finished
- ✅ Final stakeholder report saved locally
- ✅ All screenshots and CSV exports downloaded
- ✅ Validation summary completed
- ✅ Portfolio deliverables exported

> **⚠️ Do Not Delay Cleanup**: Azure resources continue billing even when not actively in use. The scanner VM, SQL database, and storage accounts generate charges 24/7 until deleted.

---

## 📊 Summary of Components by Re-Commission Risk

| Risk Level | Components | Re-Commission Time | Delete Recommendation |
|------------|------------|-------------------|-----------------------|
| **CRITICAL** | Azure Resource Group (VM + SQL + networking) | 4-6 hours full rebuild | ✅ YES - Highest cost driver, always delete |
| **HIGH** | Retention Labels + Auto-Apply Policies | 1-2d sim + 2-7d activation (9d total) | ⚠️ ONLY if completely done with Purview learning |
| **MEDIUM** | DLP Policies | 1-2 hours sync to scanner | ⚠️ Keep if might test DLP scenarios again |
| **MEDIUM** | SharePoint Test Site | Instant if <93d (recycle bin) | ⚠️ Keep if practicing retention workflows |
| **LOW** | Scanner Cluster + SQL Database | Deleted automatically with Resource Group | ✅ YES - No standalone cost |
| **LOW** | Entra ID App Registration (Service Principal) | 15-30 minutes recreation | ✅ YES - No cost, easy to recreate |
| **NONE** | Activity Explorer Data | Uses existing data, no deletion needed | N/A - Leave in place |
| **NONE** | CSV Reports, Dashboard Screenshots | Local files only | N/A - Delete manually if desired |

---

## 🧹 Step-by-Step Cleanup Process

### Step 1: Delete Azure Resource Group (⚠️ MAJOR RE-COMMISSION TIME)

This removes all Azure resources created in the lab: Scanner VM, SQL database, Key Vault, storage accounts, networking components.

> **🚨 CRITICAL - Re-Commission Waiting Period**: If you delete the Azure resource group (scanner VM) and later need to recreate it, you will face **4-6 hour re-deployment time** for:
>
> - **VM deployment**: 10-15 minutes for Azure resource creation
> - **VM configuration**: 30-45 minutes for Windows Server setup, RDP access, file share creation
> - **Scanner installation**: 1-2 hours for PowerShell module install, scanner deployment, SQL configuration
> - **Initial discovery scan**: 1-2 hours for first scan of sample data (varies by data volume)
> - **DLP enforcement scan** (if needed): Additional 1-2 hours with `-Reset` parameter
>
> **⚠️ Recommendation**: The Azure Resource Group is the **primary cost driver** (~$3-10/day for VM + SQL + networking). **Always delete this step** to terminate costs, but understand you'll need **4-6 hours** to recreate the full lab environment if you return.
>
> **💰 Cost Impact**: Keeping the VM running costs approximately:
>
> - **B2s VM** (2 vCPU, 4GB RAM): ~$0.05-0.10/hour = $1.20-2.40/day
> - **Managed Disk**: ~$0.15/day
> - **SQL Express** (included with VM): No additional charge
> - **Networking** (Public IP, NSG): ~$0.05/day
> - **Total**: ~$1.50-3.00/day or ~$45-90/month if left running

**Azure CLI Method (Recommended)**:

```powershell
# On local machine with Azure CLI installed
az login

# List your resource groups to confirm name
az group list --output table

# Delete the lab resource group (replace with your actual name)
$resourceGroup = "rg-purview-lab"  # Adjust to your resource group name
az group delete --name $resourceGroup --yes --no-wait

Write-Host "✅ Resource group deletion initiated (runs in background)" -ForegroundColor Green
Write-Host "All Azure resources will be deleted in 5-10 minutes" -ForegroundColor Cyan
Write-Host "⚠️ Re-commissioning this environment will take 4-6 hours" -ForegroundColor Yellow
```

**Azure Portal Method (Alternative)**:

Navigate to Azure Portal:

- Go to [portal.azure.com](https://portal.azure.com)
- Navigate to **Resource Groups**
- Find your lab resource group (e.g., `rg-purview-lab`)
- Click the resource group name
- Click **Delete resource group** at the top
- Type the resource group name to confirm
- Click **Delete**

> **⏳ Deletion Timeline**: Resource group deletion takes **5-10 minutes** and runs asynchronously. You can proceed with other cleanup steps while this completes in the background.

**Resources Removed**:

- ✅ Virtual Machine (scanner VM) - **Reverse-engineers Lab 00 (Environment Setup) and Lab 01 (Scanner Deployment)**
- ✅ Managed Disk (OS disk for VM)
- ✅ Network Interface Card (NIC)
- ✅ Public IP Address
- ✅ Network Security Group (NSG)
- ✅ Virtual Network (VNet)
- ✅ SQL Express Database (scanner configuration storage)
- ✅ Key Vault (scanner service principal secrets)
- ✅ Storage Accounts (if created for Azure Files testing in Lab 03)

**Re-Creation Requirements (If Deleted)**:

If you delete and later need to recreate the scanner environment:

1. **Lab 00 - Environment Setup** (2-3 hours):
   - Deploy new Windows Server VM with correct size/region
   - Configure RDP access, Windows Firewall, Remote Desktop
   - Install PowerShell 7, Azure CLI, Azure PowerShell modules
   - Create file shares (Finance, HR, Projects) with sample sensitive data
   - Verify file share access via UNC paths

2. **Lab 01 - Scanner Deployment** (2-3 hours):
   - Install Microsoft Purview Information Protection Scanner module
   - Configure SQL Express database for scanner storage
   - Create Entra ID app registration (service principal)
   - Assign Purview permissions to service principal
   - Install scanner with authentication
   - Create scanner cluster and content scan job
   - Run initial discovery scan (1-2 hours depending on data volume)

3. **Total Re-Commission Time**: 4-6 hours minimum

> **💡 Time-Saving Alternative**: If you plan to return to the lab within 1-2 weeks, consider **stopping (deallocating) the VM** instead of deleting the resource group. This saves ~70% of costs while preserving configuration:
>
> ```powershell
> # Stop VM to save costs (compute charges stop, storage charges continue)
> az vm deallocate --resource-group $resourceGroup --name $vmName
>
> # Cost when stopped: ~$0.50-1.00/day (storage only)
> # Re-start time: 2-3 minutes (vs. 4-6 hours for full rebuild)
> ```
>
> **Trade-off**: Stopped VM still incurs storage costs (~$0.50-1.00/day) but can be restarted in minutes instead of hours.

---

### Step 2: Remove Entra ID App Registration

Delete the service principal used for scanner authentication.

**Portal Navigation**:

- Go to [portal.azure.com](https://portal.azure.com)
- Navigate to **Entra ID** → **App registrations**
- Switch to **All applications** tab (not just "Owned applications")
- Find your scanner app registration (e.g., `Purview-Scanner-ServicePrincipal`)
- Click the app name to open details
- Click **Delete** at the top of the page
- Confirm deletion in the dialog

> **🔒 Security Cleanup**: Deleting the app registration removes the service principal and all associated credentials. This prevents any potential unauthorized access using the scanner identity.

**What Gets Removed**:

- ✅ App registration and service principal
- ✅ Client secret credentials
- ✅ API permissions granted to the app
- ✅ Scanner authentication identity

---

### Step 3: Remove Scanner Cluster and Scan Job

Delete scanner configurations from Microsoft Purview portal.

**Remove Scanner Cluster**:

- Go to [compliance.microsoft.com](https://compliance.microsoft.com)
- Navigate to **Information Protection** → **Scanner** → **Clusters**
- Select your scanner cluster (e.g., `EastUS-Scanner`)
- Click **Delete cluster** in the toolbar
- Confirm deletion in the dialog

**Remove Content Scan Job**:

- Navigate to **Information Protection** → **Scanner** → **Content scan jobs**
- Select your scan job (e.g., `OnPrem-File-Share-Scan`)
- Click **Delete** in the toolbar
- Confirm deletion

> **💡 Cleanup Note**: Since the scanner VM is deleted in Step 1, the scanner cluster becomes orphaned in Purview. Deleting from the portal cleans up configuration metadata and prevents clutter in your tenant.

**What Gets Removed**:

- ✅ Scanner cluster registration
- ✅ Content scan job configuration
- ✅ Scan schedule and repository mappings
- ✅ Scanner metadata from Purview

---

### Step 4: Remove DLP Policy (⚠️ CAREFUL - Sync Waiting Period)

If you want to clean up the DLP policy created for lab testing.

> **🚨 CRITICAL - Re-Commission Waiting Period**: If you delete the DLP policy and later need to recreate it, you will face **1-2 hour sync waiting periods** for:
>
> - **DLP policy sync to scanner**: After policy creation/modification, scanner requires 1-2 hours to receive policy updates
> - **DLP policy sync to Microsoft 365 locations**: SharePoint, OneDrive, Exchange require policy synchronization time
> - **Scanner enforcement scan**: Must run scanner with `-Reset` parameter to apply new DLP rules after sync completes
>
> **⚠️ Recommendation**: Only delete the DLP policy if you are certain you won't need to recreate it within 2-3 hours, OR if you're willing to wait for sync and re-run enforcement scans.
>
> **📊 Impact on Lab 02 Completion**: Deleting the DLP policy removes the configurations you created in Lab 02 Part 1 & Part 2. If you need to demonstrate or validate DLP functionality again, you'll need to recreate the policy and wait for sync.

**Portal Navigation**:

- Go to [compliance.microsoft.com](https://compliance.microsoft.com)
- Navigate to **Data Loss Prevention** → **Policies**
- Find `Lab-OnPrem-Sensitive-Data-Protection` (or your custom policy name)
- Click the policy name to view policy details
- Click **Delete policy** in the toolbar or **•••** (More actions) → **Delete**
- Confirm deletion in the dialog

> **⚠️ Production Caution**: If you have other DLP policies in your tenant (production or other test policies), ensure you're deleting the **correct lab policy only**. Check these identifiers before confirming deletion:
>
> - **Policy Name**: Lab-OnPrem-Sensitive-Data-Protection
> - **Rules**: Block-Credit-Card-Access (High severity), Audit-SSN-Access (Low severity)
> - **Locations**: On-premises repositories only (scanner-configured locations)
> - **Creation Date**: Match your Lab 02 Part 1 creation date

> **🔒 Production Consideration**: In a real environment, you would typically **keep the DLP policy** and refine it for ongoing protection rather than delete it. For this lab, deletion is safe since it only applies to test data on the now-deleted scanner VM.

**Alternative: Turn Off DLP Policy (Without Deletion)**:

If you want to avoid re-commission sync waiting periods:

**Disable DLP Policy (Without Deletion):**

- Navigate to the DLP policy in Purview portal
- Click the policy name
- Toggle policy status to **Off** or **Turn off**
- Policy stops enforcing rules but remains configured
- **Re-enable anytime** with only 1-2 hour sync wait (vs. full policy recreation)

**Benefits of Disabling vs. Deleting:**

| Approach | Re-Commission Time | Data Protected | Best For |
|----------|-------------------|----------------|----------|
| **Disable (Turn Off)** | 1-2 hours (sync only) | Policy inactive but configured | Temporary lab pause, might reuse policy |
| **Delete** | 1-2 hours (policy recreation + sync) + scanner enforcement scan | No protection | Permanent cleanup, won't reuse policy |

> **💡 Best Practice**: For lab environments you might revisit or demonstrate, **turn off the DLP policy** instead of deleting it. For permanent cleanup with no intention to return, **delete the policy**.

**What Gets Removed (If Deleted)**:

- ✅ DLP policy configuration
- ✅ Block-Credit-Card-Access rule (High severity, Block action)
- ✅ Audit-SSN-Access rule (Low severity, Audit action)
- ✅ Policy-to-location mappings (on-premises scanner repositories)
- ✅ DLP policy sync state from scanner cluster
- ✅ Activity Explorer events will retain historical data but no new DLP events will be generated

**Re-Creation Requirements (If Deleted)**:

If you delete and later need to recreate the DLP policy:

1. **Create DLP policy** in Purview portal (Lab 02 Part 1 steps)
2. **Wait 1-2 hours** for policy sync to scanner cluster
3. **Verify sync complete**: Check scanner cluster shows "Ready" status (no "Sync in progress")
4. **Run enforcement scan**: Execute `Start-AIPScan -Reset` on scanner VM
5. **Validate in reports**: Check DetailedReport CSV for "Information Type Name" and "Action" columns
6. **Total time**: 2-4 hours from policy creation to validated enforcement

> **⏳ Time Investment**: Full DLP policy re-commission and validation takes **2-4 hours** including sync wait and enforcement scan completion. Consider this time investment before deleting if you might need the policy again.

---

### Step 5: Remove Retention Label & Auto-Apply Policy (⚠️ CAREFUL - Time-Based Constraints)

If you created retention labels in Lab 03 and want to clean them up.

> **🚨 CRITICAL - Re-Commission Waiting Period**: If you delete retention labels or auto-apply policies and later need to recreate them, you may face **7-day waiting periods** for:
>
> - **Auto-apply policy re-activation**: Up to 7 days for labels to apply after turning policy back on
> - **Simulation mode testing**: 1-2 days (small sites) to 2-7 days (large sites) for simulation results
> - **Label application propagation**: Labels take 24-48 hours to appear on files after policy activation
>
> **⚠️ Recommendation**: Only delete retention labels/policies if you are certain you won't need to recreate them for at least 7-10 days, OR if you're willing to accept the waiting period for re-commissioning.

**Step 5A: Remove Auto-Apply Policy**:

Portal Navigation:

- Go to [compliance.microsoft.com](https://compliance.microsoft.com)
- Navigate to **Records Management** → **Label policies** OR **Data lifecycle management** → **Microsoft 365** → **Retention labels**
- Find `Auto-Delete-Old-Sensitive-Files` policy (or your custom policy name)
- Click the policy name to view details
- Click **Delete policy** in the toolbar
- Confirm deletion in the dialog

> **⏳ Deletion Impact**:
>
> - Auto-apply policy deletion is **immediate**
> - Labels already applied to files **remain** until manually removed or retention period expires
> - No new labels will be applied after policy deletion
> - **Re-creation waiting period**: If you recreate the policy, expect **1-7 days** for simulation/activation

**Step 5B: Remove Retention Label**:

Portal Navigation:

- Navigate to **Records Management** → **File plan** OR **Data lifecycle management** → **Microsoft 365** → **Retention labels**
- Find `Delete-After-3-Years` label (or your custom label name)
- Click the label name to view details
- Click **Delete** in the toolbar
- Confirm deletion

> **⚠️ Label Deletion Constraints**: Retention labels can **only be deleted** if:
>
> 1. **No files are currently tagged** with the label across all locations (SharePoint, OneDrive, Exchange, Teams)
> 2. **No active auto-apply policies** reference the label (delete policies first)
> 3. **No manual publishing policies** include the label
>
> If deletion fails with "Label in use" error:
>
> - Wait **24-48 hours** for SharePoint to clear cached label references
> - Manually remove labels from files in SharePoint test site (**File properties** → **Remove label**)
> - Check OneDrive and Exchange for files with the label applied
> - Verify all auto-apply and publishing policies are deleted
> - Retry label deletion after confirming no references remain

**Step 5C: Alternative - Keep Labels Inactive Instead of Deleting**:

If you want to avoid re-commission waiting periods but stop labels from applying:

**Turn Off Auto-Apply Policy (Without Deletion):**

- Navigate to the auto-apply policy in Purview portal
- Click the policy name
- Toggle policy status to **Off** or **Disabled**
- Labels already applied remain, but no new applications occur
- **Re-enable anytime** without 7-day waiting period

**Benefits of Keeping vs. Deleting:**

| Approach | Re-Commission Time | Storage Impact | Best For |
|----------|-------------------|----------------|----------|
| **Keep (Turn Off)** | Instant (toggle back On) | Minimal (policy metadata only) | Temporary lab pause, might reuse |
| **Delete** | 1-7 days (re-create + wait) | None | Permanent cleanup, won't reuse |

> **💡 Best Practice**: For lab environments you might revisit, **turn off policies** instead of deleting them. For permanent cleanup with no intention to return, **delete policies and labels**.

**What Gets Removed (If Deleted)**:

- ✅ Auto-apply policy configuration
- ✅ Simulation mode results and history
- ✅ Delete-After-3-Years retention label
- ✅ Label-to-location policy assignments
- ✅ Retention schedule settings
- ⚠️ Labels already applied to files **remain** until manually removed

---

### Step 6: Delete SharePoint Test Site (Optional)

If you created a SharePoint test site in Lab 03 Step 7.

**SharePoint Admin Center Method**:

- Go to **SharePoint Admin Center**: [admin.microsoft.com](https://admin.microsoft.com) → **SharePoint**
- Click **Active sites** in the left navigation
- Find your test site (e.g., `Purview-Retention-Testing`)
- Select the site checkbox
- Click **Delete** in the toolbar
- Confirm deletion
- Site moves to **Deleted sites** (30-day recycle bin)

**Permanent Deletion (Optional)**:

- Navigate to **Deleted sites** in SharePoint Admin Center
- Select your test site from the recycle bin
- Click **Permanently delete**
- Confirm permanent deletion

> **📅 Site Restoration Window**: Deleted SharePoint sites can be restored within **93 days** (30 days in recycle bin + 63 days in second-stage recycle bin). For complete cleanup, permanently delete from the recycle bin immediately.

**What Gets Removed**:

- ✅ SharePoint test site and all content
- ✅ Sample files used for retention label testing
- ✅ Site permissions and configurations
- ✅ Document library with test documents

---

### Step 7: Verify Cost Termination

Confirm no ongoing Azure charges remain after cleanup.

**PowerShell Verification**:

```powershell
# Check for any remaining resources in subscription
az resource list --query "[].{Name:name, Type:type, ResourceGroup:resourceGroup}" --output table

# Should show empty or only non-lab resources
# If lab resources remain, delete individually:
# az resource delete --ids <resource-id>
```

**Azure Portal Cost Analysis**:

- Go to **Azure Portal** → **Cost Management + Billing**
- Navigate to **Cost Analysis**
- Filter by resource group (your lab resource group name)
- Set date range to include cleanup date
- Verify costs flatline after deletion date

Expected result after cleanup:

- **$0.00/day** for lab resources after resource group deletion completes
- Costs should drop to zero within 24 hours of deletion

**Check for Unexpected Charges**:

Monitor Cost Management for 2-3 days after cleanup to ensure:

- No lingering storage account charges
- No network bandwidth charges from data transfers
- No VM compute charges
- No SQL database charges

> **💰 Expected Total Lab Cost**: For a weekend lab (Friday deployment to Sunday cleanup), expect approximately **$5-15 total** depending on:
>
> - VM size (B2s vs. higher SKUs)
> - VM runtime hours
> - Azure region pricing
> - Storage account usage
> - Network bandwidth consumption

---

## ✅ Cleanup Verification Checklist

Use this checklist to confirm complete environment cleanup:

**Azure Resources**:

- [ ] Resource group deleted (confirmed in Azure Portal)
- [ ] VM deleted and no compute charges
- [ ] SQL database deleted
- [ ] Key Vault deleted
- [ ] Storage accounts deleted (if created)
- [ ] Networking resources deleted (VNet, NSG, NIC, Public IP)
- [ ] No remaining lab resources in subscription

**Entra ID**:

- [ ] App registration deleted
- [ ] Service principal removed
- [ ] No orphaned credentials

**Microsoft Purview**:

- [ ] Scanner cluster deleted
- [ ] Content scan job deleted
- [ ] DLP policy removed (optional, recommended)
- [ ] Retention label deleted (optional)
- [ ] Auto-apply policy deleted (optional)

**SharePoint**:

- [ ] Test site deleted (if created)
- [ ] Site permanently removed from recycle bin (optional)

**Cost Verification**:

- [ ] Cost Management shows $0.00/day for lab resources
- [ ] No unexpected charges for 2-3 days post-cleanup
- [ ] Total lab cost within expected range ($5-15)

---

## 📊 Cleanup Summary Documentation

Create a cleanup completion record for your portfolio:

```powershell
$cleanupSummary = @"
MICROSOFT PURVIEW WEEKEND LAB - CLEANUP COMPLETED
==================================================
Cleanup Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
Total Lab Duration: [Lab start date] to $(Get-Date -Format 'yyyy-MM-dd')

AZURE RESOURCES REMOVED
-----------------------
Resource Group: [your-resource-group-name]
Resources Deleted:
  ✅ Virtual Machine: [vm-name]
  ✅ Managed Disk: [disk-name]
  ✅ Network Interface: [nic-name]
  ✅ Public IP Address: [ip-name]
  ✅ Network Security Group: [nsg-name]
  ✅ Virtual Network: [vnet-name]
  ✅ SQL Database: [sql-instance-name]
  ✅ Key Vault: [kv-name]
  ✅ Storage Accounts: [storage-account-names]

ENTRA ID CLEANUP
----------------
  ✅ App Registration Deleted: [app-registration-name]
  ✅ Service Principal Removed
  ✅ Client Secrets Deleted

MICROSOFT PURVIEW CLEANUP
--------------------------
  ✅ Scanner Cluster Deleted: [cluster-name]
  ✅ Content Scan Job Deleted: [scan-job-name]
  ✅ DLP Policy Deleted: Lab-OnPrem-Sensitive-Data-Protection
  ✅ Retention Label Deleted: Delete-After-3-Years (if applicable)
  ✅ Auto-Apply Policy Deleted: Auto-Apply-Delete-After-3-Years (if applicable)

SHAREPOINT CLEANUP
------------------
  ✅ Test Site Deleted: [site-name] (if created)
  ✅ Site Permanently Removed from Recycle Bin

COST VERIFICATION
-----------------
  ✅ No ongoing charges confirmed
  ✅ Resource group costs: $0.00/day
  ✅ Total estimated lab cost: $[X.XX]
  ✅ Cost breakdown:
    • VM compute: $[X.XX]
    • Storage: $[X.XX]
    • Networking: $[X.XX]
    • Other services: $[X.XX]

LAB ARTIFACTS PRESERVED LOCALLY
--------------------------------
  ✅ Scanner CSV reports (DetailedReport, SummaryReport, DLPReport)
  ✅ Remediation candidates CSV
  ✅ Activity Explorer export CSV
  ✅ Data Classification dashboard screenshots (4 images)
  ✅ PowerShell remediation script examples
  ✅ Final stakeholder report
  ✅ Validation summary document
  ✅ Cleanup summary (this document)

PORTFOLIO DELIVERABLES READY
-----------------------------
All lab deliverables exported and saved locally for:
  • Resume/LinkedIn skills demonstration
  • Work sample portfolio
  • GitHub project showcase (sanitized)
  • Blog post or technical writing sample

CLEANUP STATUS: ✅ COMPLETE
NO ONGOING AZURE COSTS REMAINING
"@

# Save cleanup summary
$cleanupSummary | Out-File "C:\PurviewLab\Cleanup_Summary.txt" -Encoding UTF8
Write-Host "✅ Cleanup summary saved to C:\PurviewLab\Cleanup_Summary.txt" -ForegroundColor Green
Write-Host "Environment successfully cleaned up - no ongoing Azure costs!" -ForegroundColor Cyan
```

---

## 📚 Reference Documentation

- [Azure Resource Group Deletion](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Entra ID App Registration Management](https://learn.microsoft.com/en-us/entra/identity-platform/howto-remove-app)
- [Microsoft Purview Scanner Management](https://learn.microsoft.com/en-us/purview/deploy-scanner-configure-install)
- [DLP Policy Management](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)
- [Retention Label Management](https://learn.microsoft.com/en-us/purview/create-retention-labels-data-lifecycle-management)
- [Azure Cost Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/)

---

## 🤖 AI-Assisted Content Generation

This environment cleanup guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Azure resource management best practices, Microsoft Purview configuration cleanup procedures, and cost termination verification based on current documentation as of October 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of environment cleanup procedures while maintaining technical accuracy and alignment with Azure resource management and Microsoft Purview administration best practices.*
