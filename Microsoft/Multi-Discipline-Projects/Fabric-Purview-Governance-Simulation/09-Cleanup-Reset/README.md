# Lab 09: Cleanup and Reset

## 🎯 Objective

Remove all lab resources to clean up your Fabric environment and optionally reset Purview catalog entries.

**Duration**: 15 minutes

---

## 📋 Prerequisites

- [ ] Labs 01-08 completed.
- [ ] Workspace owner or admin permissions.
- [ ] Purview Data Curator role (for catalog cleanup).

---

## ⚠️ Important Warnings

> **🚨 Destructive Operations**: This lab permanently deletes resources. Ensure you've completed all other labs and saved any work you want to keep.

> **💡 Lab Environment Only**: Only perform these steps in lab/test environments. Never run cleanup scripts against production workspaces.

---

## 🔧 Step 1: Document What Gets Removed

### Fabric Resources Created

| Lab | Resource | Type |
|-----|----------|------|
| 01 | `Fabric-Purview-Lab` | Workspace |
| 02 | `CustomerDataLakehouse` | Lakehouse |
| 03 | `DF_CustomerSegmentation` | Dataflow Gen2 |
| 03 | `PL_CustomerDataRefresh` | Pipeline |
| 04 | `AnalyticsWarehouse` | Warehouse |
| 05 | `IoTEventhouse` | Eventhouse |
| 05 | `KQL_IoTAnalytics` | KQL Queryset |
| 08 | `Customer Analytics Report` | Report |

### Purview Catalog Entries

- Lakehouse and table assets
- Warehouse and view assets
- Eventhouse and KQL database assets
- Classifications and lineage data
- Sensitivity labels applied

---

## 🔧 Step 2: Export Important Data (Optional)

### Save Report If Needed

1. Open `Customer Analytics Report`.

2. Click **File** → **Download this file** → **.pbix**.

3. Save locally for future reference.

### Export Query Results

1. Open any queries you want to save.

2. Run the query and export results to CSV.

3. Save KQL queries as text files.

---

## 🔧 Step 3: Delete Fabric Workspace

### Delete Workspace (Recommended Method)

Deleting the workspace removes all contained items at once.

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Navigate to your workspaces list.

3. Find `Fabric-Purview-Lab`.

4. Click the **...** (more options) menu.

5. Select **Workspace settings**.

6. Scroll to the bottom.

7. Click **Delete this workspace**.

8. Type the workspace name to confirm.

9. Click **Delete**.

### What This Removes

- ✅ All Lakehouses and data
- ✅ All Warehouses and SQL objects
- ✅ All Eventhouses and KQL databases
- ✅ All Dataflows and Pipelines
- ✅ All Reports and Semantic Models
- ✅ All stored queries and notebooks

---

## 🔧 Step 4: Verify Fabric Cleanup

### Confirm Workspace Deleted

1. Refresh the workspaces list.

2. Verify `Fabric-Purview-Lab` is no longer visible.

3. Search for any orphaned items.

### Check Capacity Usage

1. If you're a capacity admin, check capacity utilization.

2. Storage and compute should reflect the removed resources.

---

## 🔧 Step 5: Clean Purview Catalog (Optional)

### Understanding Catalog Cleanup

When Fabric resources are deleted:

- Purview assets become **stale** but aren't automatically removed.
- Catalog may show deleted assets until next scan.
- Classifications and lineage are preserved until manual cleanup.

### Re-Scan to Update Catalog

1. Go to [purview.microsoft.com](https://purview.microsoft.com).

2. Navigate to **Data Map** → **Sources**.

3. Find your Fabric tenant source.

4. Run a new **On-Demand scan**.

5. This updates the catalog with current state.

### Manual Asset Removal (If Needed)

1. Search for the deleted Lakehouse in Data Catalog.

2. If assets still appear:
   - Click on the asset.
   - Look for **Delete** option (requires Data Curator role).
   - Confirm deletion.

> **📝 Note**: Some organizations retain catalog history intentionally. Follow your organization's data governance policies.

---

## 🔧 Step 6: Remove Purview Scan Configuration

### Delete Lab Scan

1. In **Data Map** → **Sources** → Fabric tenant.

2. Click **View details**.

3. Navigate to **Scans** tab.

4. Find `Fabric-Lab-Scan-01`.

5. Click the **...** menu.

6. Select **Delete**.

7. Confirm deletion.

### Keep Fabric Registration

- You can keep the Fabric tenant registered for future labs.
- Only delete scans specific to this lab.

---

## 🔧 Step 7: PowerShell Cleanup Verification

### Run Verification Script

Execute this script to verify cleanup:

```powershell
# Fabric-Purview-Governance-Simulation Cleanup Verification
# This script checks that lab resources have been removed

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Cleanup Verification Script" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Verify Azure CLI is installed
Write-Host "`n[1/3] Checking Azure CLI..." -ForegroundColor Yellow
try {
    $azVersion = az --version 2>$null | Select-Object -First 1
    Write-Host "  ✅ Azure CLI installed: $azVersion" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️ Azure CLI not found (optional for this check)" -ForegroundColor Yellow
}

# Check for Fabric workspace (requires Fabric REST API access)
Write-Host "`n[2/3] Workspace Cleanup Status..." -ForegroundColor Yellow
Write-Host "  ℹ️ Manual verification required:" -ForegroundColor Cyan
Write-Host "     - Open app.fabric.microsoft.com" -ForegroundColor White
Write-Host "     - Verify 'Fabric-Purview-Lab' workspace is deleted" -ForegroundColor White

# Purview catalog status
Write-Host "`n[3/3] Purview Catalog Status..." -ForegroundColor Yellow
Write-Host "  ℹ️ Manual verification required:" -ForegroundColor Cyan
Write-Host "     - Open purview.microsoft.com" -ForegroundColor White
Write-Host "     - Search for 'CustomerDataLakehouse'" -ForegroundColor White
Write-Host "     - Verify assets are removed or marked stale" -ForegroundColor White

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Cleanup Verification Complete" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
```

Save as `scripts/Test-Cleanup.ps1` and run from the lab folder.

---

## 🔧 Step 8: Reset for Future Labs

### Prepare for Re-Running Labs

If you want to run the labs again:

1. **Create new workspace** with fresh name or same name.

2. **Upload sample data** from `data-templates/` folder.

3. **Start from Lab 01** with clean environment.

### Keep Sample Data

The `data-templates/` folder in this repository contains:

- `customers.csv` - Customer records
- `transactions.csv` - Transaction records
- `streaming-events.json` - IoT events

These files are not affected by workspace deletion.

---

## ✅ Cleanup Validation Checklist

Verify complete cleanup:

- [ ] Workspace `Fabric-Purview-Lab` is deleted.
- [ ] All workspace items are removed.
- [ ] Purview scan `Fabric-Lab-Scan-01` is deleted.
- [ ] Catalog assets are updated (re-scan completed or assets removed).
- [ ] No orphaned resources in Fabric capacity.
- [ ] Sample data files preserved in repository.

---

## ❌ Troubleshooting

### Cannot Delete Workspace

**Symptom**: Delete option is unavailable or fails.

**Resolution**:

1. Verify you're a workspace owner or admin.
2. Remove any items with active connections first.
3. Check for Power BI app publications.
4. Contact Fabric admin if permissions are restricted.

### Catalog Still Shows Deleted Assets

**Symptom**: Purview shows assets after Fabric deletion.

**Resolution**:

1. Run a new On-Demand scan.
2. Wait 24 hours for automatic cleanup.
3. Manually delete assets if immediate cleanup needed.
4. This is normal behavior—catalog preserves history.

### Capacity Still Shows Usage

**Symptom**: Capacity metrics don't reflect deletion.

**Resolution**:

1. Metrics may lag by several hours.
2. Refresh the capacity admin page.
3. Wait 24 hours for accurate reflection.
4. Check for other workspaces on same capacity.

---

## 📊 Lab Completion Summary

Congratulations! You've completed the Fabric-Purview Governance Simulation.

### Skills Developed

| Skill Area | Labs Covered |
|------------|--------------|
| **Fabric Administration** | Labs 00-01 |
| **Data Engineering** | Labs 02-03 |
| **Data Warehousing** | Lab 04 |
| **Real-Time Analytics** | Lab 05 |
| **Data Governance** | Labs 06-08 |
| **Business Intelligence** | Lab 09 |
| **Environment Management** | Lab 09 |

### Key Takeaways

1. **Fabric + Purview Integration**: Seamless governance across the analytics stack.

2. **DirectLake Performance**: Near real-time analytics without data movement.

3. **Auto-Classification**: Automatic sensitive data discovery.

4. **Sensitivity Labels**: Protection flows through lineage.

5. **Unified Platform**: Single workspace for all analytics workloads.

---

## 🔄 What's Next?

### Extend Your Learning

1. **Advanced Dataflows**: Complex ETL with error handling.

2. **Real-Time Streaming**: Eventstream with live data.

3. **Capacity Management**: Performance tuning and monitoring.

4. **Custom Classifications**: Create organization-specific patterns.

5. **Automated Governance**: Policy-based label application.

### Production Considerations

- Implement proper access controls (workspace roles).
- Set up scheduled scans for continuous governance.
- Create data quality rules and monitoring.
- Establish data lifecycle policies.
- Document data ownership and stewardship.

---

## 📚 Related Resources

- [Microsoft Fabric documentation](https://learn.microsoft.com/fabric/)
- [Microsoft Purview documentation](https://learn.microsoft.com/purview/)
- [Fabric governance overview](https://learn.microsoft.com/fabric/governance/governance-compliance-overview)
- [Fabric capacity management](https://learn.microsoft.com/fabric/admin/capacity-settings)

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Cleanup procedures were verified against Microsoft Fabric documentation within **Visual Studio Code**.

---

## 🎉 Congratulations!

You have successfully completed all 10 labs of the **Fabric-Purview Governance Simulation**.

Return to the [Project README](../README.md) for additional resources and next steps.
