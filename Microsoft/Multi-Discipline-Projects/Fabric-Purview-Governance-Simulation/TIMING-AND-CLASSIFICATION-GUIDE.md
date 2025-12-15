# Timing and Classification Reference Guide

This guide provides timing expectations for the governance features used throughout the Fabric-Purview Governance Simulation labs.

> **📝 Note**: For enterprise capabilities beyond what's covered in these labs, see [ENTERPRISE-GOVERNANCE-CAPABILITIES.md](./ENTERPRISE-GOVERNANCE-CAPABILITIES.md).

---

## ⏱️ DLP Policy Timing

DLP for Fabric is a key component of Labs 06-09. Understanding timing helps set expectations for when detection results appear.

| Phase | Expected Duration | Notes |
|-------|-------------------|-------|
| Policy creation | Immediate | Policy saved in Purview portal |
| Policy sync | 5-15 minutes | "Sync completed" status appears |
| Real-time scanning activation | After sync | Detects sensitive data when accessed |
| Simulation results population | 15-60 minutes | After users access reports containing sensitive data |
| Full tenant propagation | Up to 24 hours | For consistent enforcement across all items |

### How DLP for Fabric Works

DLP policies for Power BI use **real-time scanning**—they detect sensitive data patterns (SSN, Credit Card) **when users access reports or semantic models**, not by proactively scanning data at rest.

**To trigger detection:**

1. Create and save the DLP policy.
2. Wait for "Sync completed" status.
3. Open a report that queries data containing sensitive patterns.
4. Check simulation results after 15-30 minutes.

> **💡 Key Insight**: If simulation shows 0 matches, it doesn't mean no sensitive data exists—it means no one has accessed items containing that data since the policy was deployed.

---

## ⏱️ Data Map Scan Timing

Labs 07-08 use Purview Data Map to discover Fabric assets in the Unified Catalog.

| Phase | Expected Duration | Notes |
|-------|-------------------|-------|
| Scan initiation | Immediate | Scan starts after clicking "Save and run" |
| Workspace discovery | 2-5 minutes | Workspace-level items appear |
| Table/column schema capture | 5-15 minutes | Full schema metadata extracted |
| Assets visible in Unified Catalog | After scan completes | Browse via Unified Catalog → Data assets |

### What Data Map Discovers

| Asset Level | Discovery Method | What You See |
|-------------|------------------|--------------|
| **Workspaces** | Automatic (Live View) | Workspace names in catalog |
| **Items** (Lakehouse, Warehouse) | Automatic + Scan | Item inventory with types |
| **Tables** | Requires scan | Table names under Lakehouse/Warehouse |
| **Columns** | Requires scan | Column names, data types in Schema tab |

> **💡 Key Insight**: Live View shows workspaces and items automatically. To see **tables and columns**, you must run a Data Map scan (Lab 07).

---

## ⏱️ Fabric Data Operations Timing

These timings apply to the data foundation labs (01-05).

| Operation | Expected Duration | Notes |
|-----------|-------------------|-------|
| Lakehouse creation | 1-2 minutes | Item appears in workspace |
| Notebook execution (data load) | 2-5 minutes | Depends on data volume |
| Table availability after load | Immediate | Tables visible in Lakehouse explorer |
| Warehouse creation | 1-2 minutes | Item appears in workspace |
| Cross-database query execution | Seconds | After Warehouse points to Lakehouse |
| Semantic model creation | 1-2 minutes | Default model created with Lakehouse |
| Report save | Immediate | Report appears in workspace |

---

## 📊 Lab-by-Lab Timing Summary

| Lab | Primary Activity | Typical Duration | Key Wait Points |
|-----|------------------|------------------|-----------------|
| **Lab 00** | Prerequisites and setup | 30 minutes | Admin API propagation (15-30 min) |
| **Lab 01** | Enable Fabric, create workspace | 15-20 minutes | None |
| **Lab 02** | Create Lakehouse, load data | 30 minutes | Data loading |
| **Lab 03** | Data ingestion with connectors | 45 minutes | Dataflow/pipeline execution |
| **Lab 04** | Warehouse and SQL analytics | 30 minutes | None |
| **Lab 05** | Real-Time Intelligence with KQL | 45 minutes | Data ingestion |
| **Lab 06** | DLP policy creation | 35 minutes | Policy sync (5-15 min) |
| **Lab 07** | Data Map scan | 15 minutes | Scan completion (5-15 min) |
| **Lab 08** | Power BI report | 20 minutes | None |
| **Lab 09** | Final validation | 20-30 minutes | DLP results (may need to wait) |

### Recommended Lab Sequencing

For optimal results, complete **Lab 06 (DLP policy)** before Labs 07-08. This allows the policy to propagate while you complete asset discovery and report creation. By Lab 09, simulation results should be available.

---

## 📋 Troubleshooting Timing Issues

### DLP Simulation Shows 0 Matches

**Expected behavior**: DLP requires data access activity to detect patterns.

**Resolution:**

1. Verify policy sync completed (check status in Policies list).
2. Open the Power BI report and interact with visuals.
3. Wait 15-30 minutes.
4. Check simulation results again.

### Data Map Scan Stuck or Failing

**Common causes:**

- Purview MSI doesn't have workspace Viewer access (Lab 00, Step 7.4).
- Admin API settings not fully propagated (wait 15-30 minutes).
- Scan scope doesn't include your workspace.

**Resolution:**

1. Verify workspace Viewer role assigned to Purview MSI.
2. Re-run scan after permission changes.

### Assets Not in Unified Catalog

**Common causes:**

- Scan hasn't completed yet.
- Scan scope missed your workspace.

**Resolution:**

1. Check scan status in Data Map → Data sources.
2. Verify scan scope includes `Fabric-Purview-Lab` workspace.
3. Re-run scan if needed.

### Report Not Showing in Catalog

**Expected behavior**: Reports appear after Data Map scan discovers them.

**Resolution:**

1. Re-run Data Map scan after saving report (Lab 08).
2. Wait for scan to complete.
3. Browse Unified Catalog → Data assets → Microsoft Fabric → Reports.

---

## 🔗 Related Documentation

- [DLP for Power BI](https://learn.microsoft.com/power-bi/enterprise/service-security-dlp-policies-for-power-bi-overview)
- [Purview Data Map Overview](https://learn.microsoft.com/purview/concept-data-map)
- [Enterprise Governance Capabilities](./ENTERPRISE-GOVERNANCE-CAPABILITIES.md)

---

## 🤖 AI-Assisted Content Generation

This timing reference guide was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Timing expectations were validated against lab testing within **Visual Studio Code**.
