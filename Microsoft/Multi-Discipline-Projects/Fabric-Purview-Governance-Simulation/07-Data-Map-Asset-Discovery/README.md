# Lab 07: Data Map and Asset Discovery

## 🎯 Objective

Use **Microsoft Purview Data Map** to scan your Fabric workspace and make assets **discoverable** in the Unified Catalog. This complements DLP (Lab 06) by providing visibility into what data assets exist and where sensitive data resides.

**Duration**: 15 minutes

---

## 💰 Cost Note

> **✅ Pay-As-You-Go Required**: This lab uses Purview Data Map features that require pay-as-you-go billing. If you completed Lab 00, billing should already be enabled and propagated.
>
> **📊 Scanning Costs**: Data Map scans incur minimal costs based on assets scanned. A single scan of your lab workspace typically costs less than $1.

---

## 🏗️ What You'll Build

| Item | Purpose for Governance |
|------|------------------------|
| **Data Map Scan** | Automated discovery of Fabric assets and metadata |
| **Unified Catalog Entry** | Assets browsable with schema details |
| **Governance Visibility** | Know what data exists before applying DLP policies |

### How Data Map Complements DLP

| Capability | What It Does | Lab |
|------------|--------------|-----|
| **DLP Policies** | Detect sensitive data (SSN, Credit Card) in real-time | Lab 06 |
| **Data Map Scan** | Discover all assets and their schemas | Lab 07 |
| **Unified Catalog** | Browse and search governed assets | Lab 07 |

**Together they answer:**

- **DLP**: "Does this data contain sensitive information?"
- **Data Map**: "What data assets do we have?"
- **Combined**: "Where is our sensitive data across all assets?"

---

## 📋 Prerequisites

- [ ] Labs 01-05 completed (Lakehouse with `customers` and `transactions` tables).
- [ ] **Pay-as-you-go billing enabled** (completed in Lab 00).
- [ ] **Fabric registered in Data Map** (completed in Lab 00).
- [ ] **Purview MSI has workspace access** (completed in Lab 00, Step 7.4).

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

## 🔧 Step 2: Run a Data Map Scan

### Create New Scan

1. In Data Map → **Data sources**, locate **Fabric-Lab**.
2. Click **View details**, then select **New scan**.

### Configure Scan Settings

| Setting | Value |
|---------|-------|
| **Name** | `Fabric-Lab-Scan-01` (or auto-generated) |
| **Personal workspaces** | **Include** |
| **Integration runtime** | Azure AutoResolveIntegrationRuntime |
| **Credential** | Microsoft Purview MSI (system) |
| **Collection** | **Select domain only** |

3. Click **Test connection** to verify connectivity.
4. Click **Continue**.

> 📷 **Screenshot**: New scan dialog showing scan settings (Name, Personal workspaces, Credential) with Test connection button

### Select Scan Scope

1. On the **Scope your scan** screen, select **Yes (Preview)**.
2. Expand the workspace tree and select **Fabric-Purview-Lab**.
3. Click **Continue**.

> 📷 **Screenshot**: "Scope your scan" screen showing workspace tree with Fabric-Purview-Lab checkbox selected

### Configure Scan Trigger

1. Select **Once** (not Recurring).
2. Click **Continue**, then **Save and run**.

### Wait for Scan

Scan typically takes **5-15 minutes**. You can navigate away and return.

---

## 🔧 Step 3: Validate Assets in Unified Catalog

### Browse Discovered Assets

1. In the Purview portal, go to **Unified Catalog** → **Data assets**.
2. Click **Microsoft Fabric** under **Explore your data**.
3. Select **Fabric-Purview-Lab** workspace.

> 📷 **Screenshot**: Unified Catalog → Data assets showing Microsoft Fabric categories with workspace assets listed

### Verify Discovery

Navigate through the categories to confirm your assets:

| Category | Expected Assets |
|----------|-----------------|
| **Lakehouse** | `CustomerDataLakehouse` → tables: `customers`, `customers_segmented`, `transactions` |
| **Warehouses** | `AnalyticsWarehouse` |
| **Datasets** | `CustomerDataLakehouse` (semantic model) |
| **Reports** | `Customer Analytics Report` |

### View Asset Details

1. Click on a table (e.g., `customers`).
2. Review the available tabs:
   - **Overview** — Asset summary
   - **Properties** — Metadata details
   - **Schema** — Column names and types
   - **Contacts** — Data stewards (if assigned)

> **✅ Success**: Your Fabric assets are now discoverable in the Unified Catalog with schema-level metadata.

---

## ✅ Validation Checklist

Before proceeding to Lab 08:

- [ ] Scan completed successfully on Fabric-Lab data source.
- [ ] Can browse to `Fabric-Purview-Lab` workspace in Unified Catalog.
- [ ] Lakehouse tables (`customers`, `transactions`) are visible with schema.

---

## ❌ Troubleshooting

### Test Connection Fails

**Symptom**: Permission errors even after configuring Admin API settings.

**Resolution**:

1. Verify the Purview MSI has **Viewer** role on the workspace (Lab 00, Step 7.4).
2. Go to **Fabric-Purview-Lab** workspace → **Manage access** → confirm `payg-billing` is listed.
3. If missing, add `payg-billing` with **Viewer** role and wait 2-3 minutes.
4. Retry **Test connection**.

### Scan Fails to Start

**Resolution**:

1. Verify you have **Data Source Administrator** role in Purview.
2. Check that pay-as-you-go billing is active.
3. Ensure Fabric data source registration is complete.

### No Assets Discovered

**Resolution**:

1. Verify scan scope includes your workspace (select **Yes (Preview)**).
2. Check that Fabric items exist and contain data.
3. Re-run the scan with broader scope.

---

## ➡️ Next Steps

Proceed to:

**[Lab 09: Final Validation](../09-Final-Validation/)**

> **🎯 Lab 09 brings it together**: Validate DLP detection results, verify assets in catalog, and confirm your end-to-end governance implementation.

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Data Map and Unified Catalog procedures were verified against Microsoft Purview documentation within **Visual Studio Code**.
