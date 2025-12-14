# Lab 07: Data Map and Lineage

## 🎯 Objective

Use **Microsoft Purview Data Map** to scan your Fabric assets and visualize **data lineage** — showing how data flows from Lakehouse through Warehouse to analytics outputs.

**Duration**: 25 minutes

---

## 💰 Cost Note

> **✅ Pay-As-You-Go Required**: This lab uses Purview Data Map features that require pay-as-you-go billing. If you completed Lab 00, billing should already be enabled and propagated.
>
> **📊 Scanning Costs**: Data Map scans incur minimal costs based on assets scanned. A single scan of your lab workspace typically costs less than $1.

---

## 🏗️ What You'll Build

| Item | Description |
|------|-------------|
| **Data Map Scan** | Automated discovery of Fabric assets and metadata |
| **Lineage Visualization** | Visual flow showing data movement across items |
| **Asset Metadata** | Schema-level details for Lakehouse and Warehouse tables |
| **Cross-Item Relationships** | Connections between Lakehouse, Warehouse, and shortcuts |

### Real-World Context

Data lineage answers critical governance questions:

- **Where did this data come from?** — Trace upstream sources.
- **What depends on this data?** — Identify downstream impacts before changes.
- **How does sensitive data flow?** — Track PII from source to report.
- **Who transformed this data?** — Audit data processing history.

Enterprise lineage scenarios:

- **Regulatory Compliance** — Prove data provenance for audits.
- **Impact Analysis** — Understand blast radius before schema changes.
- **Data Quality** — Trace issues back to source systems.
- **Security** — Track where sensitive data propagates.

---

## 📋 Prerequisites

- [ ] Labs 01-06 completed (Lakehouse, Warehouse, KQL Database with DLP policies).
- [ ] **Pay-as-you-go billing enabled** (completed in Lab 00).
- [ ] **Fabric registered in Data Map** (completed in Lab 00).
- [ ] Access to **Microsoft Purview portal** ([purview.microsoft.com](https://purview.microsoft.com)).

> **🔒 Permissions**: You need **Data Source Administrator** or **Data Curator** role in Purview to run scans.

---

## 🔧 Step 1: Verify Fabric Data Source Registration

### Navigate to Data Map

1. Go to [purview.microsoft.com](https://purview.microsoft.com).
2. In the left navigation, select **Data Map**.
3. Select **Data sources**.

### Verify Registration

1. In the **Map view** or **Table view**, locate your **Fabric-Lab** data source.
2. Click **View details** to confirm:
   - **Data source name**: `Fabric-Lab`
   - **Type**: Fabric (Includes Power BI)
   - **Status**: Registered

> **❌ Not registered?** Return to Lab 00, Step 6 to register Fabric as a data source.

---

## 🔧 Step 2: Configure and Run a Scan

### Create New Scan

1. In Data Map → **Data sources**, locate **Fabric-Lab** in the Map view.
2. Click **View details** on the Fabric-Lab tile, then select **New scan**.
   - Or click the scan icon (🔍) directly on the tile.

### Configure Scan Settings

The **Scan "Fabric-Lab"** panel opens on the right:

| Setting | Value | Notes |
|---------|-------|-------|
| **Name** | `Fabric-Lab-Scan-01` | Auto-generated, can customize |
| **Personal workspaces** | **Include** (selected) | Scans personal workspaces too |
| **Integration runtime** | Azure AutoResolveIntegrationRuntime | Default, no change needed |
| **Credential** | Microsoft Purview MSI (system) | Uses Purview's managed identity |
| **Domain** | `payg-billing` | Auto-populated from your setup |
| **Collection** | **Select domain only** | Click dropdown → select this option |

> **📝 Note**: The info banner states "In addition to Power BI items, other Fabric items can also be scanned in Fabric tenants." — this confirms your Lakehouse, Warehouse, and KQL items will be included.
>
> **⚠️ Permissions Note**: The panel reminds you to give the managed identity of the Microsoft Purview account permissions to connect to your Fabric. This was configured in Lab 00.

3. Click **Test connection** (optional) to verify connectivity.
4. Click **Continue** to proceed to scope selection.

### Select Scan Scope

1. On the scope selection screen, expand the workspace tree.
2. Select the items to scan:
   - ✅ **Fabric-Purview-Lab** workspace (or select individual items)
   - This includes: CustomerDataLakehouse, AnalyticsWarehouse, IoTEventhouse
3. Click **Continue**.

### Configure Scan Trigger

1. **Scan rule set**: Use default Fabric scan rules (or select custom if available).
2. **Scan trigger**: Select **Once** for manual scan.
   - Production environments typically use scheduled scans (daily, weekly).
3. Review settings and click **Save and run**.

### Monitor Scan Progress

1. After starting the scan, you'll see a progress indicator.
2. Scan duration depends on asset count and data volume.
3. For your lab items, expect **5-15 minutes**.

> **💡 Tip**: You can navigate away and return — the scan continues in the background.

---

## 🔧 Step 3: View Discovered Assets

### Check Scan Results

1. Once the scan completes, navigate to **Data Map** → **Data sources**.
2. Click on **Fabric-Lab** → **View details**.
3. Verify the scan statistics:
   - **Assets discovered**: Should show your Lakehouse, Warehouse, KQL Database.
   - **Scan status**: Completed.
   - **Last scan**: Today's date.

### Browse Discovered Assets

1. In the Purview portal, go to **Unified Catalog** or **Data Catalog**.
2. Search for your assets:
   - `CustomerDataLakehouse`
   - `AnalyticsWarehouse`
   - `IoTEventhouse`
3. Select an asset to view details.

### Explore Asset Metadata

For each discovered asset, examine:

| Metadata | What It Shows |
|----------|---------------|
| **Schema** | Tables, columns, data types |
| **Properties** | Owner, location, format |
| **Contacts** | Data stewards, owners |
| **Related** | Connected assets, lineage links |

---

## 🔧 Step 4: View Data Lineage

### Access Lineage View

1. In the Data Catalog, open **CustomerDataLakehouse**.
2. Select the **Lineage** tab (or look for lineage icon).
3. The lineage graph shows data flow relationships.

### Understand Lineage Visualization

The lineage diagram displays:

| Element | Meaning |
|---------|---------|
| **Nodes** | Data assets (Lakehouse, Warehouse, tables) |
| **Arrows** | Data flow direction (upstream → downstream) |
| **Colors** | Asset types (blue for Fabric items) |
| **Levels** | Data processing stages |

### Expected Lineage for Your Lab

Based on your lab configuration, you should see:

```text
[CustomerDataLakehouse] 
       ↓
   (Shortcut)
       ↓
[AnalyticsWarehouse]
       ↓
   (Future: Power BI Report)
```

> **💡 Note**: Lineage depth depends on how you connected items. If you created shortcuts in Lab 04, those connections appear in lineage.

---

## 🔧 Step 5: Explore Warehouse Lineage

### Navigate to Warehouse

1. In the Data Catalog, search for `AnalyticsWarehouse`.
2. Open the asset and select the **Lineage** tab.

### View Upstream Sources

1. The lineage view shows what data feeds into the Warehouse.
2. Look for connections to:
   - **CustomerDataLakehouse** (if shortcuts were created).
   - Any external sources configured.

### View Downstream Dependencies

1. Toggle to see downstream assets.
2. In future labs, Power BI reports connected to the Warehouse will appear here.

---

## 🔧 Step 6: View KQL Database in Data Map

### Navigate to KQL Database

1. Search for `IoTEventhouse` in the Data Catalog.
2. Open the asset details.

### Examine KQL Metadata

KQL Database assets show:

- **Tables**: Event tables created in Lab 05.
- **Schema**: Column definitions and types.
- **Connections**: Related Eventhouse and workspace.

> **💡 Note**: KQL Database lineage may show limited connections since it receives streaming data rather than ETL pipelines.

---

## 🔧 Step 7: Use Lineage for Impact Analysis

### Scenario: Schema Change Assessment

Imagine you need to modify a column in the Lakehouse. Use lineage to assess impact:

1. Open **CustomerDataLakehouse** → **Lineage**.
2. Identify all downstream assets.
3. Click on each downstream asset to understand dependencies.
4. Document which reports or queries might break.

### Scenario: Data Quality Issue

When you discover data quality issues:

1. Open the affected asset.
2. View **upstream** lineage to trace the source.
3. Identify where bad data entered the pipeline.
4. Fix at the source rather than downstream.

---

## ✅ Validation Checklist

Before proceeding to Lab 08, verify:

### Data Map Scan

- [ ] Scan completed successfully on Fabric-Lab data source.
- [ ] Assets discovered: Lakehouse, Warehouse, KQL Database.
- [ ] Scan status shows "Completed" with today's date.

### Asset Discovery

- [ ] CustomerDataLakehouse appears in Data Catalog with schema details.
- [ ] AnalyticsWarehouse appears with table metadata.
- [ ] IoTEventhouse (KQL Database) appears with event tables.

### Lineage Visualization

- [ ] Lineage tab accessible for discovered assets.
- [ ] Can see data flow connections between related items.
- [ ] Understand upstream/downstream relationship visualization.

---

## ❌ Troubleshooting

### Scan Fails to Start

**Symptom**: "Failed to start scan" or permission errors.

**Resolution**:

1. Verify you have **Data Source Administrator** role in Purview.
2. Check that pay-as-you-go billing is active.
3. Ensure Fabric data source registration is complete.
4. Try re-registering the Fabric data source.

### No Assets Discovered

**Symptom**: Scan completes but shows 0 assets.

**Resolution**:

1. Verify scan scope includes your workspace.
2. Check that Fabric items exist and contain data.
3. Ensure your account has access to the Fabric workspace.
4. Re-run the scan with broader scope.

### Lineage Not Showing Connections

**Symptom**: Assets appear but lineage is empty or minimal.

**Resolution**:

1. Lineage requires actual data connections (shortcuts, pipelines).
2. DirectQuery or live connections may not show lineage.
3. Run dataflows or pipelines to establish tracked connections.
4. Wait 24 hours after data movement for lineage to update.

### Scan Takes Too Long

**Symptom**: Scan runs for more than 30 minutes.

**Resolution**:

1. Large workspaces take longer — this is normal.
2. Reduce scan scope to specific items.
3. Check Purview service health for any issues.
4. Cancel and restart if stuck beyond 1 hour.

---

## 📊 Lineage Interpretation Guide

### Understanding Flow Direction

| Arrow Direction | Meaning |
|-----------------|---------|
| **→ Right** | Data flows downstream (to consumers) |
| **← Left** | Data comes from upstream (sources) |
| **↔ Both** | Bidirectional data movement |

### Asset Types in Lineage

| Icon/Color | Asset Type |
|------------|------------|
| **Fabric icon** | Lakehouse, Warehouse, KQL Database |
| **Database icon** | SQL-based data stores |
| **File icon** | Files in OneLake |
| **Report icon** | Power BI reports (after Lab 08) |

### Lineage Depth

| Level | Description |
|-------|-------------|
| **Direct** | Immediate upstream/downstream connections |
| **Extended** | Full lineage chain across multiple hops |
| **Column-level** | Specific column transformations (enterprise feature) |

---

## 📚 Related Resources

- [Purview Data Map Overview](https://learn.microsoft.com/en-us/purview/concept-data-map)
- [Register and Scan Fabric](https://learn.microsoft.com/en-us/purview/register-scan-fabric-tenant)
- [Data Lineage in Purview](https://learn.microsoft.com/en-us/purview/concept-data-lineage)
- [Fabric Governance with Purview](https://learn.microsoft.com/en-us/fabric/governance/use-microsoft-purview-hub)
- [Lineage Best Practices](https://learn.microsoft.com/en-us/purview/how-to-lineage-data-factory)

---

## ➡️ Next Steps

Proceed to:

**[Lab 08: Power BI Visualization](../08-Power-BI-Visualization/)**

> **🎯 Important**: Lab 08 creates Power BI reports from your governed data. After creating reports, return to Data Map to see how lineage extends to your visualizations.

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Data Map and lineage procedures were verified against Microsoft Purview documentation within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Purview Data Map capabilities while maintaining technical accuracy against official Microsoft documentation.*
