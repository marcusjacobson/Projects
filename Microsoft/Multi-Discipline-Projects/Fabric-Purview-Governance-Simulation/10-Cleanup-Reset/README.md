# Lab 10: Cleanup and Reset

## 🎯 Objective

Remove all lab resources to clean up your Fabric environment and optionally reset Purview catalog entries.

**Duration**: 15 minutes

---

## 💰 Cost Impact Summary

Before cleanup, understand which items generate ongoing costs:

| Resource | Cost When Active | Cost When Idle | Recommendation |
|----------|------------------|----------------|----------------|
| **Fabric Trial Capacity** | $0 | $0 | ✅ Keep until expiration |
| **Fabric F2 Capacity** | ~$0.36/hr | $0 (paused) | ⚠️ Pause or delete |
| **Fabric Workspace** | Consumes capacity | Minimal storage | ⚠️ Delete |
| **Purview PAYG Account** | Per scan (~<$1) | $0 | ✅ Keep (free when idle) |
| **DLP Policy** | $0 | $0 | ⚠️ Delete (clutter) |

> **💡 Key Insight**: The Purview pay-as-you-go account does **not** generate costs unless you run Data Map scans. You can safely keep it for future labs.

---

## 🏗️ Cleanup Overview

**Deleting the workspace removes all Fabric items automatically.** Only the DLP policy requires manual deletion.

| Cleanup Action | Method |
|----------------|--------|
| Fabric workspace + all contents | Delete workspace (Step 2) |
| DLP policy | Manual deletion in Purview (Step 4) |
| Purview catalog entries | Automatic (Live View sync) |

---

## 📋 Prerequisites

- [ ] Labs 01-09 completed (or ready to cleanup).
- [ ] Workspace owner or admin permissions.

---

## ⚠️ Important Warnings

> **🚨 Destructive Operations**: This lab permanently deletes resources. Ensure you've completed all other labs and saved any work you want to keep.
>
> **💡 Lab Environment Only**: Only perform these steps in lab/test environments. Never run cleanup scripts against production workspaces.

---

## 🔧 Step 1: Export Important Data (Optional)

### Save Report If Needed

1. Open `Customer Analytics Report`.

2. Select **File** → **Download this file** → **.pbix**.

3. Save locally for future reference.

### Export Query Results

1. Open any queries you want to save.

2. Run the query and export results to CSV.

3. Save KQL queries as text files.

---

## 🔧 Step 2: Delete Fabric Workspace

### Delete Workspace (Recommended Method)

Deleting the workspace removes all contained items at once.

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Navigate to your workspaces list.

3. Find `Fabric-Purview-Lab`.

4. Select the **...** (more options) menu.

5. Select **Workspace settings**.

6. Scroll to the bottom.

7. Select **Delete this workspace**.

8. Type the workspace name to confirm.

9. Select **Delete**.

### What This Removes

- ✅ All Lakehouses and data
- ✅ All Warehouses and SQL objects
- ✅ All Eventhouses and KQL databases
- ✅ All Dataflows and Pipelines
- ✅ All Reports and Semantic Models
- ✅ All stored queries and notebooks

---

## 🔧 Step 3: Verify Workspace Deleted

- Refresh the workspaces list at [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
- Verify `Fabric-Purview-Lab` is no longer visible.

---

## 🔧 Step 4: Delete DLP Policy

The DLP policy created in Lab 06 is **not** deleted with the workspace—it must be removed manually.

### Navigate to DLP Policies

- Go to [purview.microsoft.com](https://purview.microsoft.com).
- Navigate to **Solutions** → **Data loss prevention** → **Policies**.

### Delete the Lab Policy

- Find `Fabric PII Detection - Lab` policy.
- Select the policy, then click **Delete policy**.
- Confirm deletion.

> **💡 Why Delete?** DLP policies are tenant-wide. Leaving unused policies creates clutter and potential confusion. Delete lab policies to maintain a clean policy inventory.

---

## 🔧 Step 5: Purview Catalog (Automatic)

Purview catalog entries are cleaned up automatically:

- **Live View** syncs within 15-30 minutes.
- No manual action required.

> **💡 Keep for Future Use**: Glossary terms, Data Map scan definitions, and Purview PAYG billing have **no ongoing cost** and can be reused.

---

## ✅ Cleanup Checklist

- [ ] Workspace `Fabric-Purview-Lab` deleted (Step 2).
- [ ] DLP policy `Fabric PII Detection - Lab` deleted (Step 4).
- [ ] Fabric F2 capacity **paused** (if applicable).

---

## 🔄 Reset for Future Labs

If you want to run the labs again:

1. **Create new workspace** with fresh name or same name.
2. **Upload sample data** from `data-templates/` folder.
3. **Start from Lab 01** with clean environment.

### Sample Data Files (Not Affected by Cleanup)

The `data-templates/` folder in this repository contains:

- `customers.csv` - Customer records with SSN patterns
- `transactions.csv` - Transaction records with Credit Card patterns
- `streaming-events.json` - IoT events for Eventhouse

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

1. Wait 15-30 minutes for Live View sync.
2. Wait up to 24 hours for complete catalog cleanup.
3. Manually delete assets if immediate cleanup needed.
4. This is normal behavior—catalog may preserve history temporarily.

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
| **Data Engineering (Lakehouse)** | Lab 02 |
| **Data Pipelines & Dataflows** | Lab 03 |
| **Data Warehousing** | Lab 04 |
| **Real-Time Analytics (Eventhouse)** | Lab 05 |
| **DLP & Data Classification** | Labs 06, 09 |
| **Data Map & Asset Discovery** | Lab 07 |
| **Business Intelligence (Power BI)** | Lab 08 |
| **Resource Lifecycle Management** | Lab 10 |

### Key Takeaways

1. **Fabric + Purview Integration**: Seamless governance across the analytics stack.

2. **DirectLake Performance**: Near real-time analytics without data movement.

3. **Live View Discovery**: Automatic asset discovery without manual scanning.

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
- Consider enterprise Purview for automatic classification (see [ADVANCED-PURVIEW-ENTERPRISE-SCANNING.md](../ADVANCED-PURVIEW-ENTERPRISE-SCANNING.md)).
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

## 🎉 Congratulations

You have successfully completed all 9 labs of the **Fabric-Purview Governance Simulation**.

Return to the [Project README](../README.md) for additional resources and next steps.
