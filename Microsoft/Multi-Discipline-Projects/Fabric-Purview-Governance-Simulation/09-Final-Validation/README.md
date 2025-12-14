# Lab 09: Final Validation

## 🎯 Objective

Validate all governance capabilities configured throughout this lab series, including DLP policy results, data lineage, classifications, and endorsements.

**Duration**: 30-45 minutes

---

## 🏗️ What You'll Validate

| Component | Labs | Validation Focus |
|-----------|------|------------------|
| **DLP Policy Results** | Lab 06 | Policy tips, alerts, Activity Explorer |
| **Data Lineage** | Lab 07 | End-to-end data flow visualization |
| **Classifications** | Lab 06-07 | SIT detection across Fabric items |
| **Endorsements** | Lab 06 | Certified/Promoted badges |
| **Catalog Discovery** | Lab 07 | Assets discoverable in Purview |

### Why Final Validation Matters

Many Purview and DLP features require **propagation time**:

- **DLP policies**: 1-24 hours to fully deploy and scan.
- **Data Map scans**: 15-60 minutes after triggered.
- **Lineage visualization**: Updates after pipeline/dataflow runs.
- **Classification propagation**: Can take several hours.

By completing Labs 07-08 before validation, you've allowed sufficient time for all governance features to activate.

---

## 📋 Prerequisites

- [ ] Labs 01-08 completed.
- [ ] DLP policy created in Lab 06 (1+ hours ago recommended).
- [ ] Data Map scan triggered in Lab 07.
- [ ] Fabric workspace still active with all items.

---

## 🔧 Step 1: Trigger DLP Scans on Fabric Items

DLP scans occur automatically when data changes. To ensure your items have been scanned:

### Trigger Lakehouse Scan

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
2. Open your **Fabric-Purview-Lab** workspace.
3. Open `CustomerDataLakehouse`.
4. In the Lakehouse, trigger a data change:
   - Option A: Run a Dataflow refresh (Lab 03).
   - Option B: Add a small amount of data via notebook.
   - Option C: Simply wait — periodic scans may occur.

### Trigger Warehouse Scan

1. Open `AnalyticsWarehouse`.
2. Run a query that modifies data, or refresh the shortcuts.

### Trigger KQL Database Scan (If Configured)

1. Open `IoTEventhouse` → KQL Database.
2. Send new events or run a query that writes data.

> **⏱️ Timing**: If you just completed Lab 08, DLP has had sufficient time. If scans still show no results, allow another 15-30 minutes.

---

## 🔧 Step 2: View DLP Results

### Check for Policy Tips in Fabric

1. Return to your **Fabric-Purview-Lab** workspace.
2. Look for items with a **policy tip indicator**:
   - May appear as a shield icon or warning badge.
   - Hover over the icon to see the policy tip message.

3. Open an item with sensitive data (e.g., `CustomerDataLakehouse`).
4. Check for the policy tip banner in the item header.

### View DLP Alerts in Purview

1. Go to [purview.microsoft.com](https://purview.microsoft.com).
2. Navigate to **Data loss prevention** → **Alerts**.
3. Look for alerts from your `Fabric PII Detection - Lab` policy.
4. Click an alert to see:
   - Which item triggered the alert.
   - Which SITs were detected.
   - Match count and confidence level.

### Check Activity Explorer

1. In the [Purview portal](https://purview.microsoft.com), go to **Data classification** → **Activity explorer**.
2. Filter by:
   - **Activity type**: DLP policy matched
   - **Workload**: Microsoft Fabric / Power BI
3. Review detected activities and matched items.

> **💡 Tip**: If your policy is in simulation mode, check the **DLP simulation mode** dashboard under Data loss prevention to see policy matches without enforcement.

---

## 🔧 Step 3: Verify Data Lineage

### Review End-to-End Lineage

1. In the [Purview portal](https://purview.microsoft.com), go to **Data Catalog**.
2. Search for `CustomerDataLakehouse`.
3. Open the asset and click the **Lineage** tab.
4. Verify you can see:
   - Source files (`customers.csv`, `transactions.csv`)
   - Lakehouse tables
   - Downstream connections (Warehouse shortcuts, Reports)

### Expected Lineage Flow

```
CSV Files → Lakehouse Tables → Warehouse Shortcuts → Power BI Reports
              ↓
         Dataflow Gen2 (transformations)
```

### Lineage Not Showing?

- **Trigger a dataflow/pipeline run** — lineage captures after execution.
- **Wait for Data Map scan** — lineage updates with catalog scans.
- **Check scan status** in Data Map → Sources.

---

## 🔧 Step 4: Validate Classifications

### Check SIT Detection in Catalog

1. In the [Purview portal](https://purview.microsoft.com), go to **Data Catalog**.
2. Search for your Lakehouse tables (`customers`, `transactions`).
3. Open a table asset and check the **Schema** tab.
4. Look for classification labels on columns:
   - `SSN` column → U.S. Social Security Number
   - `CreditCardNumber` column → Credit Card Number

### Review Classification Summary

1. In the Purview portal, go to **Data Estate Insights** (if available).
2. Review:
   - Total classified assets
   - Classification types found
   - Sensitive data distribution

---

## 🔧 Step 5: Apply and Verify Endorsements

Endorsements signal data quality and trust to data consumers.

### Types of Endorsements

| Endorsement | Meaning | Use Case |
|-------------|---------|----------|
| **Promoted** | Recommended for use | Quality validated data |
| **Certified** | Officially approved | Production-ready, trusted |

### Apply Endorsements

1. In your Fabric workspace, select an item (e.g., `CustomerDataLakehouse`).
2. Click **More options** (three dots) → **Settings**.
3. Find the **Endorsement** section.
4. Select **Certified** or **Promoted**.
5. Add notes: `Contains PII - DLP monitored`
6. Click **Apply** or **Save**.

### Suggested Endorsements

| Item | Endorsement | Notes |
|------|-------------|-------|
| `CustomerDataLakehouse` | **Certified** | Primary source, DLP protected |
| `AnalyticsWarehouse` | **Promoted** | Derived data, DLP protected |
| `Customer Analytics Report` | **Promoted** | End-user reporting |

### Verify Endorsements Display

1. Return to the workspace list view.
2. Look for endorsement badges (ribbon icons) on endorsed items.
3. Hover to see the endorsement type and notes.

---

## 🔧 Step 6: Governance Summary Review

### Create Your Governance Scorecard

Review what you've implemented across this lab series:

| Capability | Status | Notes |
|------------|--------|-------|
| **Data Lake Storage** | ✅ | Lakehouse with Delta tables |
| **Data Warehouse** | ✅ | SQL analytics with shortcuts |
| **Real-Time Analytics** | ✅ | Eventhouse with KQL |
| **Data Ingestion** | ✅ | Dataflows and Pipelines |
| **Data Visualization** | ✅ | Power BI reports |
| **DLP Protection** | ✅ | Policy detecting SSN, Credit Card |
| **Data Lineage** | ✅ | End-to-end visibility |
| **Data Classification** | ✅ | Automatic SIT detection |
| **Endorsements** | ✅ | Trust signals applied |
| **Catalog Discovery** | ✅ | Assets searchable in Purview |

### Enterprise Governance Alignment

This lab demonstrated key pillars of a modern data governance strategy:

- **Data Protection**: DLP policies prevent sensitive data exposure.
- **Data Quality**: Endorsements signal trustworthy data sources.
- **Data Discovery**: Catalog makes data findable and understandable.
- **Data Lineage**: Trace data from source to consumption.
- **Compliance**: Classification supports regulatory requirements.

---

## ✅ Final Validation Checklist

Before proceeding to cleanup, verify:

### DLP Policy Results

- [ ] DLP policy has been deployed (created 1+ hours ago).
- [ ] Policy tips visible on Fabric items with sensitive data.
- [ ] Alerts appearing in Purview DLP Alerts dashboard.
- [ ] Activity Explorer shows DLP policy matches.

### Data Lineage

- [ ] Lakehouse assets visible in Purview Data Catalog.
- [ ] Lineage tab shows data flow from files → tables → reports.
- [ ] Dataflow/Pipeline runs captured in lineage.

### Classifications

- [ ] SSN column classified as U.S. Social Security Number.
- [ ] CreditCardNumber column classified as Credit Card Number.
- [ ] Classifications visible in Purview asset schema.

### Endorsements

- [ ] Key items endorsed as Certified or Promoted.
- [ ] Endorsement badges visible in workspace view.
- [ ] Endorsement notes indicate governance status.

---

## ❌ Troubleshooting

### No DLP Policy Tips After 24 Hours

**Symptom**: Policy deployed but no visible policy tips.

**Resolution**:

1. Verify policy is **not** in simulation mode (or check simulation dashboard).
2. Confirm data contains matching SIT patterns (SSN format: 123-45-6789).
3. Check policy scope includes your workspace.
4. Trigger a data modification to invoke scan.

### Lineage Not Showing

**Symptom**: Assets appear in catalog but no lineage connections.

**Resolution**:

1. **Run a dataflow or pipeline** — lineage captures on execution.
2. **Trigger Data Map scan** — lineage requires recent scan.
3. **Check data connections** — DirectQuery sources may not show lineage.
4. **Wait** — lineage propagation can take 30-60 minutes.

### Classifications Not Appearing

**Symptom**: Tables exist in catalog but columns not classified.

**Resolution**:

1. **Verify data format** — Delta tables are required for classification.
2. **Check Data Map scan status** — classification happens during scans.
3. **Validate data patterns** — ensure SSN/Credit Card columns have proper format.
4. **Review scan rule set** — ensure default classification rules are enabled.

### Endorsements Not Visible

**Symptom**: Applied endorsement but badge not showing.

**Resolution**:

1. **Refresh the workspace view** — badges may not update instantly.
2. **Check permissions** — endorsement requires workspace contributor role.
3. **Verify endorsement saved** — re-open item settings to confirm.

---

## 📚 Related Resources

- [DLP for Fabric and Power BI Overview](https://learn.microsoft.com/en-us/purview/dlp-powerbi-get-started)
- [Microsoft Purview Data Catalog](https://learn.microsoft.com/en-us/purview/catalog-overview)
- [Fabric Endorsement Overview](https://learn.microsoft.com/en-us/fabric/governance/endorsement-overview)
- [Data Lineage in Microsoft Purview](https://learn.microsoft.com/en-us/purview/lineage-overview)
- [Sensitive Information Types Reference](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-entity-definitions)

---

## ➡️ Next Steps

If you've completed all validation checks and are ready to clean up your lab environment:

**[Lab 10: Cleanup and Reset](../10-Cleanup-Reset/)**

> **💡 Tip**: Take screenshots of your governance dashboard, lineage views, and DLP alerts before cleanup for future reference or portfolio documentation.

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Validation procedures were consolidated from throughout the lab series within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Fabric and Purview governance validation while maintaining technical accuracy against official Microsoft documentation.*
