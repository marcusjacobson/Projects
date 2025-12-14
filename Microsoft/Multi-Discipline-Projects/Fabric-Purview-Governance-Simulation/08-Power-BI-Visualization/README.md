# Lab 08: Power BI Visualization

## 🎯 Objective

Create Power BI reports using DirectLake mode to visualize your Lakehouse data, and observe how sensitivity labels flow to reports.

**Duration**: 45 minutes

---

## 🏗️ What You'll Build

| Item | Description |
|------|-------------|
| **Customer Analytics Report** | Interactive Power BI report with multiple visualizations |
| **DirectLake Connection** | High-performance link to Lakehouse data (no import) |
| **Customer Segmentation Dashboard** | Visual breakdown by segment, state, and credit score |
| **Inherited Sensitivity Label** | Label automatically applied from upstream data sources |

### Real-World Context

Power BI is where **data becomes decisions**:

- **Executives** view dashboards for strategic planning.
- **Analysts** explore data for insights and recommendations.
- **Operations teams** monitor KPIs and take action.

**DirectLake mode** is Fabric's breakthrough innovation:

- **No data copying** — queries read directly from Delta Lake files.
- **Near real-time** — changes in Lakehouse appear in reports within minutes.
- **Import-like performance** — fast queries without scheduled refreshes.

The **governance integration** you'll observe:

- Sensitivity labels flow from Lakehouse → Semantic Model → Report.
- Purview shows the complete lineage of your visualizations.
- Data protection policies apply throughout the analytics chain.

This demonstrates the **end-to-end governed analytics** pattern that organizations need for compliance and trust.

---

## 📋 Prerequisites

- [ ] Labs 01-07 completed (Lakehouse with data, DLP policies, lineage configured).
- [ ] Access to `Fabric-Purview-Lab` workspace.
- [ ] Basic familiarity with Power BI concepts.

---

## 🔧 Step 1: Understand DirectLake Mode

### DirectLake vs Import vs DirectQuery

| Mode | Data Location | Performance | Refresh |
|------|---------------|-------------|---------|
| **DirectLake** | Lakehouse/Delta | Fast | Near real-time |
| **Import** | Power BI dataset | Fastest | Scheduled |
| **DirectQuery** | Source system | Variable | Live |

> **💡 Key Insight**: DirectLake is unique to Fabric—it reads Delta Lake files directly without copying data, combining DirectQuery freshness with Import-like performance.

---

## 🔧 Step 2: Explore the Default Semantic Model

### Navigate to Lakehouse

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Open your `Fabric-Purview-Lab` workspace.

3. Select `CustomerDataLakehouse`.

### Locate Default Semantic Model

1. A default semantic model is automatically created when you create a Lakehouse.

2. In the workspace, look for an item with the same name as your Lakehouse but with a **semantic model** icon.

3. The semantic model uses **Direct Lake** mode, which queries data directly from OneLake delta tables.

### Open Semantic Model

1. In the workspace, find `CustomerDataLakehouse` (semantic model type).

2. Select to open it.

3. Direct Lake mode provides fast query performance without importing data.

---

## 🔧 Step 3: Explore Semantic Model

### View Tables and Relationships

1. In the semantic model view, explore:
   - Available tables
   - Column definitions
   - Any auto-detected relationships

2. Tables should include:
   - `customers`
   - `transactions`
   - `customers_segmented` (if created)

### Check Sensitivity Label

1. Look at the semantic model header.

2. Verify the sensitivity label from the Lakehouse flows through.

3. The label should match what you applied in Lab 07.

---

## 🔧 Step 4: Create Power BI Report

### Start New Report

There are multiple ways to create a report. Use one of these options:

**Option A - From Semantic Model:**

1. In the workspace, hover over the `CustomerDataLakehouse` semantic model.

2. Select the **...** (context menu) and choose **Create report**.

**Option B - From New Item:**

1. Select **+ New item**.

2. Select **Report**.

3. Choose **Pick a published semantic model**.

4. Select `CustomerDataLakehouse` semantic model.

The Power BI report editor opens with a live connection to the semantic model.

### Add Visualizations

**Visualization 1: Customer Distribution by State**

1. From the **Visualizations** pane, select **Map** (or **Filled Map**).

2. Add fields:
   - **Location**: `customers[State]`
   - **Size**: Count of CustomerID

3. The map shows customer concentration by state.

**Visualization 2: Credit Score Distribution**

1. Add a **Histogram** or **Column chart**.

2. Add fields:
   - **X-axis**: `customers[CreditScore]` (binned)
   - **Y-axis**: Count

3. This shows credit score distribution.

**Visualization 3: Transaction Summary**

1. Add a **Card** visual.

2. Add field: Sum of `transactions[Amount]`

3. This shows total transaction value.

---

## 🔧 Step 5: Create Dashboard Page

### Add Multiple Visualizations

Create a dashboard layout with:

1. **Top Row**: Summary cards
   - Total Customers (count)
   - Total Transactions (sum of Amount)
   - Average Credit Score

2. **Middle Row**: Charts
   - State distribution (bar chart)
   - Transaction types (pie chart)

3. **Bottom Row**: Detail table
   - Top customers by spending

### Example Card Visual

1. Add a **Card** visual.

2. Drag `customers[CustomerID]` to Values.

3. Change aggregation to **Count**.

4. Title: "Total Customers".

### Example Table Visual

1. Add a **Table** visual.

2. Add columns:
   - CustomerID
   - FirstName
   - LastName
   - State
   - CreditScore

3. Sort by CreditScore descending.

---

## 🔧 Step 6: Add Interactivity

### Create Slicers

1. Add a **Slicer** visual.

2. Add `customers[State]` to Field.

3. This allows filtering all visuals by state.

4. Add another slicer for transaction type.

### Configure Interactions

1. Select a visual.

2. Go to **Format** → **Edit interactions**.

3. Choose how other visuals respond to selections.

---

## 🔧 Step 7: Save and Publish Report

### Save Report

1. Select **File** → **Save**.

2. Name: `Customer Analytics Report`.

3. Select your `Fabric-Purview-Lab` workspace.

4. Select **Save**.

### Verify in Workspace

1. Return to the workspace view.

2. Find your saved report.

3. The report should show:
   - Report icon
   - Sensitivity label badge
   - Connection to semantic model

---

## 🔧 Step 8: Verify Label Inheritance

### Check Report Sensitivity

1. Select the report to open it.

2. Look for sensitivity label indicator.

3. The report should inherit the label from the semantic model.

### Label Flow Verification

Trace the label inheritance:

```text
Lakehouse (Confidential) 
    → Semantic Model (Confidential) 
        → Report (Confidential)
```

> **💡 Key Insight**: Sensitivity labels flow downstream, ensuring data protection throughout the analytics stack.

---

## 🔧 Step 9: Create Additional Visuals

### KPI Visual

1. Add a **KPI** visual.

2. Configure:
   - **Value**: Average Credit Score
   - **Trend axis**: (if date field available)
   - **Target**: 700

### Custom Measure (DAX)

1. In the semantic model or report, create a measure:

```dax
High Value Customers = 
CALCULATE(
    COUNTROWS(customers),
    customers[CreditScore] >= 750
)
```

2. Use this measure in a card visual.

### Conditional Formatting

1. Select a table visual.

2. Go to **Format** → **Cell elements** → **Background color**.

3. Apply rules:
   - Credit Score ≥ 750: Green
   - Credit Score 650-749: Yellow
   - Credit Score < 650: Red

---

## 🔧 Step 10: Explore Report in Purview

### View Report in Catalog

1. Go to [purview.microsoft.com](https://purview.microsoft.com).

2. Search for your report: `Customer Analytics Report`.

3. View the report asset page.

### Check Lineage from Report

1. Navigate to the **Lineage** tab.

2. You should see:
   - Report → Semantic Model → Lakehouse → Tables

3. This shows the complete data flow to the visualization layer.

---

## ✅ Validation Checklist

Before proceeding to Lab 09, verify:

- [ ] Semantic model exists for Lakehouse.
- [ ] Created Power BI report with multiple visualizations.
- [ ] Report shows sensitivity label inherited from source.
- [ ] Added interactive elements (slicers, filters).
- [ ] Report is saved to workspace.
- [ ] Report appears in Purview Data Catalog.
- [ ] Lineage shows connection from report to Lakehouse.

---

## ❌ Troubleshooting

### Cannot Create Report from Semantic Model

**Symptom**: Option to build report is unavailable.

**Resolution**:

1. Verify semantic model exists (check workspace items).
2. Refresh the Lakehouse SQL analytics endpoint.
3. Check your permissions on the semantic model.
4. Wait a few minutes after Lakehouse creation.

### Visualizations Show No Data

**Symptom**: Charts are empty despite having data.

**Resolution**:

1. Check that tables have data in Lakehouse.
2. Verify semantic model is properly connected.
3. Check field names match exactly.
4. Clear any active filters/slicers.

### Sensitivity Label Not Showing on Report

**Symptom**: Report doesn't show inherited label.

**Resolution**:

1. Verify source semantic model has a label.
2. Check that label inheritance is enabled.
3. Wait for label sync (up to 30 minutes).
4. Contact admin if labels aren't flowing.

### DAX Measure Errors

**Symptom**: Measure formula fails.

**Resolution**:

1. Check table and column names are correct.
2. Use square brackets for column names: `[ColumnName]`.
3. Verify data types match the function requirements.

---

## 📊 Sample Report Layout

```text
┌────────────────────────────────────────────────────────────┐
│  Customer Analytics Report           🏷️ Confidential      │
├─────────────┬─────────────┬─────────────┬─────────────────┤
│   Total     │   Total     │   Average   │   High Value    │
│  Customers  │ Transactions│Credit Score │   Customers     │
│     50      │   $125,432  │    712      │      18         │
├─────────────┴─────────────┴─────────────┴─────────────────┤
│                                                            │
│  [State Distribution Chart]    [Transaction Type Pie]     │
│                                                            │
├────────────────────────────────────────────────────────────┤
│  Filter: [State ▼]  [Credit Score Range ▼]                │
├────────────────────────────────────────────────────────────┤
│  CustomerID | Name        | State | Score | Spending      │
│  CUST-001   | John Smith  | CA    | 780   | $5,420       │
│  CUST-015   | Jane Doe    | TX    | 755   | $4,890       │
│  ...        | ...         | ...   | ...   | ...          │
└────────────────────────────────────────────────────────────┘
```

---

## 📚 Related Resources

- [Create Power BI reports](https://learn.microsoft.com/fabric/data-warehouse/reports-power-bi-service)
- [DirectLake overview](https://learn.microsoft.com/fabric/get-started/direct-lake-overview)
- [DAX reference](https://learn.microsoft.com/dax/dax-overview)
- [Sensitivity labels in Power BI](https://learn.microsoft.com/power-bi/enterprise/service-security-sensitivity-label-overview)

---

## ➡️ Next Steps

Proceed to:

**[Lab 09: Final Validation](../09-Final-Validation/)**

> **🎯 Important**: Lab 09 validates all governance capabilities you've configured: DLP policy results, data lineage, classifications, and endorsements. Your DLP policy (Lab 06) has had time to deploy while you completed Labs 07-08.

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Power BI and DirectLake procedures were verified against Microsoft Fabric documentation within **Visual Studio Code**.
