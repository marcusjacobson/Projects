# Lab 09: Final Validation

## 🎯 Objective

Validate the governance capabilities configured throughout this lab series: DLP policy detection, asset discovery in Unified Catalog, and the Power BI report governance chain.

**Duration**: 20-30 minutes (plus DLP propagation wait time)

---

## 🏗️ What You'll Validate

| Component | Source Lab | Validation Focus |
|-----------|------------|------------------|
| **DLP Policy** | Lab 06 | Simulation review, enable policy, trigger scan, verify matches, investigate alerts |

> **💡 Note**: Asset Discovery (Lab 07) and Report Governance (Lab 08) were validated in their respective labs. This lab focuses on the DLP workflow, alert investigation, and how all governance components work together.

---

## 🔄 Understanding DLP Detection Triggers

> **⚠️ Important**: DLP for Fabric does **not** proactively scan data at rest. It evaluates data only when trigger events occur.

| Asset Type | Trigger Events |
|------------|----------------|
| **Lakehouse** | Data changes: new data, adding tables, updating existing tables |
| **Semantic Model** | Publish, Republish, On-demand refresh, Scheduled refresh |

**Key Behavior**: Adding a single row triggers a **full table scan**—you don't need to reload entire tables.

**Timing**: Allow 15-30 minutes after triggering for results to appear in Activity Explorer and Alerts.

---

## 📋 Prerequisites

- [ ] Labs 01-08 completed.
- [ ] DLP policy created in Lab 06 (in simulation mode, ideally 1+ hours ago).
- [ ] Data Map scan completed in Lab 07.
- [ ] Power BI report saved in Lab 08.

---

## 🔧 Step 1: Review DLP Policy Simulation and Enable

Before triggering data changes, first verify your DLP policy simulation completed successfully and then enable the policy for enforcement.

### Navigate to DLP Policies

- Go to [purview.microsoft.com](https://purview.microsoft.com).
- Navigate to **Solutions** → **Data loss prevention** → **Policies**.
- Click on your `Fabric PII Detection - Lab` policy.

### Verify Simulation Status

Review the **Simulation overview** tab:

| Check | Expected Value | Notes |
|-------|----------------|-------|
| **Simulation status** | "Complete" or "In progress" | Status shows simulation ran |
| **Sync status** | "Sync completed" | Policy synced to Fabric/Power BI |
| **Total matches** | 0 | **Expected** — Data existed before policy, no trigger occurred |
| **Scanning per location** | Power BI: Real-time | Confirms Fabric coverage |

### Enable the DLP Policy

According to [Microsoft's DLP deployment guidance](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy#policy-deployment-steps), after confirming simulation works correctly, change the policy state to enable enforcement:

- On your policy page, click **Edit policy** (or access policy settings).
- Navigate to the **Policy mode** section.
- Change from **Run the policy in simulation mode** to **Turn it on right away**.
- Click **Submit** to save changes.

> **⚠️ Important**: Enabling the policy means DLP actions (alerts, notifications) will now be enforced. In a lab environment this is safe. In production, follow Microsoft's recommended deployment steps to gradually roll out policies.

### Wait for Policy Sync

After enabling, wait **5-10 minutes** for the policy change to sync to Fabric locations. You can verify sync status:

- Return to the policy overview.
- Confirm **Sync status** shows "Sync completed" after the change.

---

## 🔧 Step 2: Trigger DLP Evaluation

Now that the policy is enabled, trigger a data change event in your Lakehouse to initiate DLP scanning. The SQL analytics endpoint is **read-only**, so you must use one of these methods.

### Option A: Spark Notebook (Required for INSERT)

> **⚠️ Why a Notebook?** Earlier labs used the **SQL analytics endpoint** for SELECT queries. However, that endpoint is **read-only**—you cannot INSERT, UPDATE, or DELETE data through it. To modify Lakehouse data, you must use a Spark notebook with the `%%sql` magic command.

Create a notebook to add test rows with sensitive data patterns:

- Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
- Open the **Fabric-Purview-Lab** workspace.
- Click **+ New item** → **Notebook**.
- Name it `DLP-Trigger-Notebook`.
- Ensure the notebook is attached to your Lakehouse (check the **Lakehouse** panel on the left).

Add and run this cell to insert a test customer with SSN:

```sql
%%sql
-- Add test row to customers table to trigger DLP scan
-- When Lakehouse is attached, reference tables directly (no prefix needed)
INSERT INTO customers 
VALUES ('C999', 'Test', 'DLPTrigger', 'test.trigger@example.com', '(555) 999-9999', '999-99-9999', '2000-01-01', '999 Trigger Lane', 'Test City', 'TX', '77777', 'USA', 700, 'Standard', '2024-12-14')
```

Run a second cell to verify the insert:

```sql
%%sql
SELECT * FROM customers WHERE CustomerID = 'C999'
```

Add and run this cell to insert a test transaction with Credit Card:

```sql
%%sql
-- Add test row to transactions table to trigger DLP scan
-- Table has 14 columns: TransactionID, CustomerID, TransactionDate, TransactionTime, Amount, Currency, MerchantName, MerchantCategory, CreditCardNumber, CardType, PaymentMethod, Status, Description, Location
INSERT INTO transactions 
VALUES ('T9999', 'C999', '2024-12-14', '08:30:00', 99.99, 'USD', 'Test Store', 'Testing', '4532-9999-8888-7777', 'Visa', 'Credit Card', 'Completed', 'DLP trigger test transaction', 'Test City TX')
```

Verify the transaction insert:

```sql
%%sql
SELECT * FROM transactions WHERE TransactionID = 'T9999'
```

> **💡 Tip**: Adding rows to BOTH tables triggers DLP evaluation on each, maximizing detection coverage. Each table will be fully scanned.

### Option B: Re-load CSV Files to Tables

If you prefer not to use a notebook, you can re-load the CSV files to the Delta tables:

- Navigate to **CustomerDataLakehouse** → **Files**.
- Right-click on `customers.csv` and select **Load to Tables** → **Existing table** → select `customers` → choose **Overwrite**.
- Repeat for `transactions.csv`.

> **⚠️ Important Distinction**: Files in the **Files** folder are separate from Delta tables. Simply re-uploading a CSV to Files does NOT update the Delta table. You must use **Load to Tables** with the **Overwrite** option to update the actual table data that downstream components (semantic model, reports) consume.
>
> **⚠️ Note on Semantic Model Refresh**: Refreshing the semantic model alone will NOT trigger DLP matches for SSN/Credit Card patterns. The semantic model contains aggregated data and relationships—not the raw text values where PII patterns exist. You must modify the **Lakehouse tables** (Option A or B) to trigger detection of sensitive data patterns.

### Optional: Update Segmented Table via Dataflow

To maximize coverage, also trigger the `customers_segmented` table:

- Open the **Customer Segmentation Pipeline** (if created in Lab 03).
- Run the dataflow to refresh the segmented data.
- This creates another data change event for DLP to evaluate.

### After Triggering

Wait **15-30 minutes** for DLP to complete evaluation, then proceed to Step 3.

---

## 🔧 Step 3: Verify DLP Detections in Activity Explorer

After the 15-30 minute wait, check Activity Explorer to confirm DLP detected sensitive data.

### Navigate to Activity Explorer

- Go to [purview.microsoft.com](https://purview.microsoft.com).
- Navigate to **Solutions** → **Data loss prevention** → **Activity explorer**.
- Filter: **Workload** = `Power BI`, **Activity** = `DLP policy matched`.

### Expected Results

You should see DLP policy matches showing:

- **Item name**: `CustomerDataLakehouse`
- **Policy matched**: `Fabric PII Detection - Lab`
- **Sensitive info types**: U.S. Social Security Number, Credit Card Number

### If No Results Appear

1. Verify 15-30 minutes have passed since Step 2.
2. Confirm policy is **enabled** (not simulation mode).
3. Check **Sync status** shows "Sync completed".
4. Re-run INSERT statements if needed.

---

## 🔧 Step 4: Investigate DLP Alert Details

Now investigate the alerts to confirm the sensitive data patterns detected.

### Check DLP Alerts Dashboard

- Navigate to **Solutions** → **Data loss prevention** → **Alerts**.
- Select an alert from your `Fabric PII Detection - Lab` policy.

### Alert Detail Pane Tabs

| Tab | Information |
|-----|-------------|
| **Details** | Event ID, Location, Impacted entities (Item name, Workspace) |
| **Source** | "Preview not available" (expected for Fabric) |
| **Classifiers** | Sensitive info types detected |
| **Metadata** | Additional context |

**Key fields to verify:**

- **Item name**: `CustomerDataLakehouse`
- **Sensitive info types detected**: Click link to see SSN and/or Credit Card

### DLP Detection Granularity (Expected Limitation)

> **⚠️ Important**: DLP for Fabric provides **item-level** detection only.

| What You See | What You Don't See |
|--------------|-------------------|
| ✅ Lakehouse name | ❌ Specific table |
| ✅ Sensitive info types | ❌ Specific column/row |
| ✅ Policy matched | ❌ Content preview |

The validation is that DLP **detected** sensitive data in your Lakehouse. You know from your data design that SSN is in `customers.SSN` and Credit Card is in `transactions.CreditCardNumber`.

### Optional: Microsoft Defender XDR

DLP alerts also flow to [security.microsoft.com](https://security.microsoft.com):

- Go to **Incidents & alerts** → **Incidents**.
- Filter: **Service Source** = `Data Loss Prevention`.

### Manage Alert Status

Update alert status after investigation:

- **Resolved - True Positive**: Confirmed detection.
- **Resolved - False Positive**: Tune policy if detection was incorrect.

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

### DLP Policy Workflow (Steps 1-4)

- [ ] Policy sync status shows "Sync completed".
- [ ] Simulation confirmed 0 matches before triggering (expected behavior).
- [ ] Policy changed from simulation mode to **enabled**.
- [ ] Data change trigger executed (INSERT to customers and transactions tables).
- [ ] Matches detected in Activity Explorer after trigger.
- [ ] Alerts visible in DLP Alerts dashboard.
- [ ] Investigated alert details to confirm detected SITs (SSN, Credit Card).
- [ ] (Optional) Reviewed alerts in Microsoft Defender XDR.

### From Previous Labs (Already Validated)

- [ ] **Lab 07**: Fabric assets discoverable in Unified Catalog with schema metadata.
- [ ] **Lab 08**: Semantic model and Power BI report created and saved to workspace.

---

## ❌ Troubleshooting

### No DLP Matches After Triggering

**Symptom**: Policy enabled and data inserted, but no matches appear.

**Resolution**:

1. Verify at least **15-30 minutes** have passed since INSERT.
2. Confirm policy is **enabled** (not still in simulation mode).
3. Check **Sync status** shows "Sync completed" after enabling.
4. Verify policy scope includes **Fabric and Power BI** location.
5. Re-run the INSERT statements from Step 2 if needed.

### Simulation Shows 0 Matches Before Enabling

**Symptom**: Simulation dashboard shows 0 total matches.

**Resolution**:

This is **expected behavior**! DLP for Fabric uses **real-time scanning**—it requires data change events. The data existed before the policy was created, so no scanning occurred. Follow Steps 2-3 to trigger detection.

---

## ➡️ Next Steps

If you've completed validation and are ready to clean up:

**[Lab 10: Cleanup and Reset](../10-Cleanup-Reset/)**

> **💡 Tip**: Take screenshots of your DLP simulation results, Unified Catalog assets, and workspace items before cleanup for future reference.

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Validation procedures were aligned with actual lab deliverables within **Visual Studio Code**.
