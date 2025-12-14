# Lab 09: Final Validation

## 🎯 Objective

Validate the governance capabilities configured throughout this lab series: DLP policy detection, asset discovery in Unified Catalog, and the Power BI report governance chain.

**Duration**: 15-20 minutes

---

## 🏗️ What You'll Validate

| Component | Lab | Validation Focus |
|-----------|-----|------------------|
| **DLP Policy** | Lab 06 | Simulation results, detected matches |
| **Asset Discovery** | Lab 07 | Fabric assets visible in Unified Catalog |
| **Report Governance** | Lab 08 | Semantic model and report in workspace |

### Why Final Validation Matters

DLP policies require **propagation time** before detecting sensitive data:

- **Policy deployment**: Immediate (sync completed).
- **Real-time scanning**: Activates when users access reports.
- **Match detection**: Requires data access activity to trigger.

By completing Labs 07-08 after creating the DLP policy, you've allowed time for deployment while continuing to build the governance chain.

---

## 📋 Prerequisites

- [ ] Labs 01-08 completed.
- [ ] DLP policy created in Lab 06 (ideally 1+ hours ago).
- [ ] Data Map scan completed in Lab 07.
- [ ] Power BI report saved in Lab 08.

---

## 🔧 Step 1: Check DLP Policy Status

### Verify Policy Deployment

1. Go to [purview.microsoft.com](https://purview.microsoft.com).
2. Navigate to **Solutions** → **Data loss prevention** → **Policies**.
3. Locate your `Fabric PII Detection - Lab` policy.
4. Verify:
   - **Policy sync status**: Sync completed ✅
   - **Mode**: In simulation with notifications (or On)

### Check Simulation Results

1. Click on your `Fabric PII Detection - Lab` policy.
2. Review the **Simulation overview** tab:
   - **Total matches**: Number of items with detected sensitive data.
   - **Scanning per location**: Power BI status (Real-time).

> **💡 Note**: DLP for Fabric uses **real-time scanning** — it detects sensitive data when users access reports or semantic models, not by proactively scanning data at rest.

### Trigger Detection (If No Matches Yet)

If simulation shows 0 matches:

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
2. Open your **Fabric-Purview-Lab** workspace.
3. **Open** the `Customer Analytics Report` and interact with it.
4. Wait 15-30 minutes and check simulation results again.

---

## 🔧 Step 2: Validate Asset Discovery

### Verify Assets in Unified Catalog

1. In the [Purview portal](https://purview.microsoft.com), go to **Unified Catalog** → **Data assets**.
2. Click **Microsoft Fabric** under **Explore your data**.
3. Select your **Fabric-Purview-Lab** workspace.

### Confirm Discovered Assets

Navigate through categories to verify:

| Category | Expected Asset | Status |
|----------|----------------|--------|
| **Lakehouse** | `CustomerDataLakehouse` | Should show tables: `customers`, `customers_segmented`, `transactions` |
| **Warehouses** | `AnalyticsWarehouse` | Should be listed |
| **Datasets** | `CustomerDataLakehouse` | Semantic model |
| **Reports** | `Customer Analytics Report` | Power BI report |

### View Table Schema

1. Navigate to **Lakehouse** → `CustomerDataLakehouse` → **tables** → `customers`.
2. Click on the `customers` table.
3. Select the **Schema** tab.
4. Verify columns are listed (FirstName, LastName, SSN, State, CreditScore, etc.).

> **✅ Success**: Your Fabric assets are discoverable in the Unified Catalog with schema-level metadata.

---

## 🔧 Step 3: Verify Report Governance Chain

### Confirm Workspace Items

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
2. Open your **Fabric-Purview-Lab** workspace.
3. Verify these items exist:

| Item | Type | Purpose |
|------|------|---------|
| `CustomerDataLakehouse` | Lakehouse | Source data with DLP-protected columns (SSN, Credit Card) |
| `CustomerDataLakehouse` | Semantic model | Data layer created from Lakehouse |
| `Customer Analytics Report` | Report | Visualization using data from both tables |

### Verify Report Uses Governed Data

1. Open `Customer Analytics Report`.
2. Confirm the report displays data from:
   - **customers** table (State, CreditScore charts).
   - **transactions** table (Amount, MerchantCategory charts).

> **🎯 Governance Chain Complete**: The report connects to the semantic model, which connects to the Lakehouse containing DLP-protected data (SSN in `customers`, Credit Card in `transactions`).

---

## 🔗 Bringing It All Together: DLP and Information Protection

The three capabilities you validated work together to provide comprehensive information protection for your Fabric data estate.

### How These Components Complement Each Other

| Component | What It Does | Information Protection Role |
|-----------|--------------|----------------------------|
| **DLP Policy** | Detects sensitive data patterns (SSN, Credit Card) | **Prevention** — Alerts or blocks when PII is accessed |
| **Asset Discovery** | Catalogs all data assets with schema metadata | **Visibility** — Know what data exists and where |
| **Report Governance** | Tracks data flow from source to visualization | **Accountability** — Understand who consumes sensitive data |

### Real-World Governance Scenarios

**Scenario 1: Compliance Audit**:

When auditors ask "Where is PII stored in your analytics environment?":

1. **Unified Catalog** → Shows Lakehouse tables containing SSN and Credit Card columns.
2. **DLP Policy** → Provides evidence of monitoring and detection for those data types.
3. **Report Chain** → Documents which reports surface data from those tables.

**Scenario 2: Data Breach Response**:

If sensitive data exposure is suspected:

1. **DLP Alerts** → Identify which reports triggered matches for SSN/Credit Card.
2. **Asset Discovery** → Locate all tables containing similar sensitive columns.
3. **Report Governance** → Determine which downstream assets consumed the data.

**Scenario 3: New Report Request**:

When a business user wants a report with customer data:

1. **Unified Catalog** → Discover available data assets and their schemas.
2. **DLP Policy** → Automatic detection applies when report accesses sensitive data.
3. **Report Governance** → New report automatically inherits DLP coverage.

### The Governance Advantage

Without these tools, organizations face:

- **Shadow analytics** — Reports built on unknown data sources.
- **Compliance gaps** — No visibility into where PII exists.
- **Reactive responses** — Discovering sensitive data only after incidents.

With this governance stack:

- ✅ **Proactive discovery** — Know your data assets before building reports.
- ✅ **Automatic protection** — DLP applies to any report using sensitive data.
- ✅ **Audit-ready documentation** — Catalog and policies provide compliance evidence.

---

## ✅ Final Validation Checklist

### DLP Policy

- [ ] Policy sync status shows "Sync completed".
- [ ] Policy is in simulation mode (or enabled).
- [ ] Scanning per location shows Power BI as "Real-time".
- [ ] (Optional) Matches detected after accessing reports.

### Asset Discovery

- [ ] `Fabric-Purview-Lab` workspace visible in Unified Catalog.
- [ ] Lakehouse tables (`customers`, `transactions`) discoverable.
- [ ] Schema metadata visible when viewing table details.

### Report Governance

- [ ] Semantic model created from Lakehouse.
- [ ] Power BI report saved to workspace.
- [ ] Report uses data from both DLP-protected source tables.

---

## ❌ Troubleshooting

### No DLP Matches After Several Hours

**Symptom**: Policy deployed but simulation shows 0 matches.

**Resolution**:

1. DLP for Fabric uses **real-time scanning** — it requires data access activity.
2. Open the Power BI report and interact with visuals.
3. Wait 15-30 minutes and check simulation results again.
4. Verify policy scope includes Power BI location.

### Assets Not in Unified Catalog

**Symptom**: Cannot find workspace or assets in catalog.

**Resolution**:

1. Verify Data Map scan completed successfully (Lab 07).
2. Check scan scope included your workspace.
3. Re-run scan if assets are missing.

### Report Not Showing Data

**Symptom**: Report opens but visuals are empty.

**Resolution**:

1. Verify Lakehouse tables have data.
2. Check semantic model connection to Lakehouse.
3. Refresh the report data.

---

## ➡️ Next Steps

If you've completed validation and are ready to clean up:

**[Lab 10: Cleanup and Reset](../10-Cleanup-Reset/)**

> **💡 Tip**: Take screenshots of your DLP simulation results, Unified Catalog assets, and workspace items before cleanup for future reference.

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Validation procedures were aligned with actual lab deliverables within **Visual Studio Code**.
