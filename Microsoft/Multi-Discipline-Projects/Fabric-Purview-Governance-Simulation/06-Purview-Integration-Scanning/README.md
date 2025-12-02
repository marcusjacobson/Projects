# Lab 06: Purview Integration and Scanning

## 🎯 Objective

Register Microsoft Fabric as a data source in Purview and run On-Demand scans to discover and catalog your Fabric assets.

**Duration**: 60 minutes (includes scan wait time)

---

## 📋 Prerequisites

- [ ] Labs 01-05 completed (Lakehouse, Warehouse, KQL Database with data).
- [ ] Microsoft Purview account access with Data Curator role or higher.
- [ ] Fabric Admin or Contributor permissions on your workspace.

---

## ⏱️ Critical Timing Information

Before starting this lab, understand these timing expectations:

| Phase | Expected Duration |
|-------|-------------------|
| **Admin API Propagation** | 10-15 minutes after workspace changes |
| **On-Demand Scan Start** | 1-5 minutes |
| **On-Demand Scan Completion** | 5-30 minutes (depends on data volume) |
| **Classification Processing** | Included in scan time |
| **Catalog Availability** | Immediate after scan completes |

> **💡 Key Insight**: Unlike SharePoint (7-day classification delay), Fabric classifications appear immediately after On-Demand scan completion.

> **📖 Reference**: See [TIMING-AND-CLASSIFICATION-GUIDE.md](../TIMING-AND-CLASSIFICATION-GUIDE.md) for detailed timing expectations.

---

## 🔧 Step 1: Access Microsoft Purview

### Navigate to Purview Portal

1. Open a new browser tab.

2. Go to [purview.microsoft.com](https://purview.microsoft.com).

3. Sign in with your organizational account.

4. You'll land on the unified Purview portal.

### Navigate to Data Map

1. In the left navigation, expand **Data Catalog**.

2. Click **Data Map**.

3. This is where you'll register and scan data sources.

---

## 🔧 Step 2: Verify Existing Fabric Connection

Microsoft Fabric tenants are often automatically connected to Purview.

### Check Registered Sources

1. In Data Map, click **Sources**.

2. Look for **Microsoft Fabric** or **Power BI** in the source list.

3. If Fabric is already registered, you'll see your tenant listed.

### If Not Registered

If Microsoft Fabric is not visible:

1. Click **Register** (or **+ New** → **Register**).

2. Search for **Microsoft Fabric**.

3. Select it and configure:

   | Setting | Value |
   |---------|-------|
   | **Name** | `Fabric-Tenant` or similar |
   | **Tenant** | Your Azure AD tenant |

4. Click **Register**.

---

## 🔧 Step 3: Access Fabric Through Purview Hub

### Alternative: Use Purview Hub in Fabric

1. Return to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. In your workspace, look for **Purview hub** in the left navigation.

3. Click **Purview hub**.

4. This shows Purview integration status for your Fabric items.

> **📝 Note**: The Purview hub in Fabric provides a workspace-centric view of governance data.

---

## 🔧 Step 4: Configure Scan for Fabric Workspace

### Create New Scan

1. In Purview Data Map → Sources, find your Fabric tenant.

2. Click on the Fabric source to expand it.

3. Click the **New scan** icon (or right-click → **New scan**).

4. Configure the scan:

   | Setting | Value |
   |---------|-------|
   | **Name** | `Fabric-Lab-Scan-01` |
   | **Scope** | Select your `Fabric-Purview-Lab` workspace |
   | **Credential** | Use default (managed identity) |

5. Click **Continue**.

### Select Asset Types

1. Choose which Fabric item types to scan:
   - ✅ Lakehouse
   - ✅ Warehouse
   - ✅ KQL Database
   - ✅ Dataset/Semantic Model
   - ✅ Dataflow
   - ✅ Pipeline

2. Click **Continue**.

### Configure Scan Trigger

1. **Critical**: Select **Once** (On-Demand scan).

2. This runs immediately and completes faster than scheduled scans.

3. Click **Continue**.

### Review and Create

1. Review your scan configuration.

2. Click **Save and run**.

3. The scan starts immediately.

---

## 🔧 Step 5: Monitor Scan Progress

### View Scan Status

1. Click on your Fabric source in Data Map.

2. Select **View details**.

3. Navigate to **Scans** tab.

4. Find `Fabric-Lab-Scan-01` in the list.

5. Status will show:
   - **In Progress**: Scan is running.
   - **Completed**: Scan finished successfully.
   - **Failed**: Check error details.

### Expected Scan Duration

| Workspace Contents | Expected Time |
|-------------------|---------------|
| Lab setup (3-5 items) | 5-15 minutes |
| Medium workspace (10-20 items) | 15-30 minutes |
| Large workspace (50+ items) | 30-60 minutes |

> **⏳ Wait for scan completion before proceeding to verification steps.**

---

## 🔧 Step 6: Verify Scan Results

### Check Discovered Assets

1. In Purview, go to **Data Catalog** → **Browse**.

2. Search for your workspace name: `Fabric-Purview-Lab`.

3. You should see discovered assets:
   - `CustomerDataLakehouse` (Lakehouse)
   - `AnalyticsWarehouse` (Warehouse)
   - `IoTEventhouse` (Eventhouse/KQL Database)
   - Tables within each

### View Asset Details

1. Click on `CustomerDataLakehouse`.

2. Review the asset page:
   - **Overview**: Basic metadata.
   - **Schema**: Columns and data types.
   - **Classifications**: Auto-detected sensitive data types.
   - **Lineage**: Data flow relationships.

---

## 🔧 Step 7: Review Auto-Classifications

### Navigate to Classifications

1. Click on the `customers` table under your Lakehouse.

2. Go to the **Schema** tab.

3. Look for classification icons next to columns:

   | Column | Expected Classification |
   |--------|------------------------|
   | `SSN` | U.S. Social Security Number |
   | `Email` | Email Address |
   | `CreditCardNumber` | Credit Card Number |
   | `Phone` | Phone Number |

### Understanding Classification Levels

Classifications are applied at multiple levels:

- **Asset Level**: Overall sensitivity of the data source.
- **Column Level**: Specific sensitive data types per column.
- **Row Sampling**: Based on sample data analysis.

> **💡 Production Tip**: Auto-classification accuracy depends on data quality and format consistency.

---

## 🔧 Step 8: Explore Data Catalog

### Search Catalog

1. In Data Catalog, use the search bar.

2. Search for: `customer`.

3. Results show all assets containing "customer":
   - Tables
   - Columns
   - Views

### Apply Filters

1. Use the filter panel to narrow results:
   - **Source type**: Microsoft Fabric
   - **Classification**: Personal data
   - **Data source**: Your workspace

### View Glossary Terms

1. Go to **Data Catalog** → **Glossary**.

2. This shows business terms that can be linked to assets.

3. In later labs, you can associate terms with your Fabric assets.

---

## 🔧 Step 9: Check Scan History

### Review Scan Details

1. Go back to **Data Map** → **Sources**.

2. Click your Fabric source → **View details**.

3. Navigate to **Scans** tab.

4. Click on `Fabric-Lab-Scan-01`.

5. Review:
   - **Status**: Completed
   - **Start time**: When scan began
   - **Duration**: How long it took
   - **Assets discovered**: Number of items found

### Scan Statistics

Look for these metrics:

| Metric | Description |
|--------|-------------|
| **Total assets** | Number of Fabric items discovered |
| **New assets** | First-time discoveries |
| **Updated assets** | Changed since last scan |
| **Deleted assets** | Removed from source |

---

## ✅ Validation Checklist

Before proceeding to Lab 07, verify:

- [ ] Fabric tenant is registered in Purview Data Map.
- [ ] On-Demand scan completed successfully.
- [ ] Lakehouse appears in Data Catalog.
- [ ] Warehouse appears in Data Catalog.
- [ ] KQL Database appears in Data Catalog.
- [ ] At least one table shows classifications.
- [ ] Column-level classifications are visible for PII columns.

---

## ❌ Troubleshooting

### Fabric Source Not Visible

**Symptom**: Cannot find Microsoft Fabric in source list.

**Resolution**:

1. Verify Purview and Fabric are in the same tenant.
2. Check that Fabric-Purview integration is enabled in Admin portal.
3. Wait 15 minutes for Admin API propagation.
4. Refresh the Data Map sources page.

### Scan Fails to Start

**Symptom**: Scan remains in "Queued" state.

**Resolution**:

1. Check Purview integration runtime status.
2. Verify you have appropriate permissions on the workspace.
3. Ensure Fabric capacity is running (not paused).
4. Try creating a new scan with different settings.

### No Classifications Detected

**Symptom**: Assets discovered but no classifications shown.

**Resolution**:

1. Verify sample data contains recognizable PII patterns.
2. Check that classification rules are enabled in Purview.
3. Wait for full scan completion (partial results may lack classifications).
4. See [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) for detailed guidance.

### Workspace Not in Scope

**Symptom**: Can't select workspace during scan setup.

**Resolution**:

1. Verify workspace has items (empty workspaces may not appear).
2. Check your permissions on the workspace.
3. Ensure workspace is on a Fabric capacity.
4. Wait 15 minutes after workspace creation.

---

## 📊 Scan Timing Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    Lab 06 Timeline                          │
├─────────────────────────────────────────────────────────────┤
│  0:00-0:10  │  Navigate Purview, verify registration        │
│  0:10-0:20  │  Configure and start On-Demand scan           │
│  0:20-0:40  │  Wait for scan completion (5-20 min typical)  │
│  0:40-0:55  │  Verify results, explore catalog              │
│  0:55-1:00  │  Complete validation checklist                │
└─────────────────────────────────────────────────────────────┘
```

---

## 📚 Related Resources

- [Connect Purview to Fabric](https://learn.microsoft.com/fabric/governance/use-microsoft-purview-hub)
- [Scan Microsoft Fabric sources](https://learn.microsoft.com/purview/register-scan-fabric-tenant)
- [Purview Data Map overview](https://learn.microsoft.com/purview/concept-data-map)
- [Classification in Purview](https://learn.microsoft.com/purview/concept-classification)

---

## ➡️ Next Steps

Proceed to:

**[Lab 07: Classification, Catalog, and Lineage](../07-Classification-Catalog-Lineage/)**

> **🎯 Important**: In Lab 07, you'll explore the classifications in detail and work with lineage visualization.

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Scanning procedures and timing expectations were verified against Microsoft Learn documentation within **Visual Studio Code**.
