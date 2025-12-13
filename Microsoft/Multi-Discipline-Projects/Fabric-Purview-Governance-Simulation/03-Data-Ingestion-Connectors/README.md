# Lab 03: Data Ingestion with Connectors

## 🎯 Objective

Use Dataflows Gen2 and Data Factory pipelines to ingest and transform data into your Lakehouse.

**Duration**: 45 minutes

---

## 📋 Prerequisites

- [ ] Lab 02 completed (Lakehouse created with data).
- [ ] Access to `Fabric-Purview-Lab` workspace.
- [ ] Familiarity with basic data transformation concepts.

---

## 🔧 Step 1: Understand Data Ingestion Options

Microsoft Fabric provides multiple ways to ingest data:

| Method | Best For | Complexity |
|--------|----------|------------|
| **Manual Upload** | Small files, one-time loads | Low |
| **Dataflows Gen2** | Data transformation, recurring loads | Medium |
| **Data Factory Pipelines** | Orchestration, complex workflows | Medium-High |
| **Notebooks** | Custom code, complex transformations | High |
| **Shortcuts** | Virtual access to external data | Low |

> **💡 This Lab Focus**: We'll create a Dataflow Gen2 for transformation and a simple pipeline for orchestration.

---

## 🔧 Step 2: Create a Dataflow Gen2

### Navigate to Workspace

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Open your **Fabric-Purview-Lab** workspace.

### Create Dataflow

1. Select **+ New item**.

2. In the **New item** pane, search for or select **Dataflow Gen2**.

3. The Power Query editor opens.

### Connect to Sample Data

For this lab, we'll create a simple dataflow that transforms data:

1. Select **Get data** in the Power Query ribbon.

2. Select **Text/CSV**.

3. For this example, we'll use the existing Lakehouse data:
   - Select **Cancel** on the external source dialog.
   - Instead, select **Get data** → **Microsoft Fabric** → **Lakehouse**.

4. Connect to your `CustomerDataLakehouse`.

5. Select the `customers` table.

6. Select **Create**.

---

## 🔧 Step 3: Apply Data Transformations

### Add Transformation Steps

1. With the customers data loaded, apply these transformations:

   **Filter High-Value Customers:**
   - Select the **CreditScore** column header.
   - Select the filter icon.
   - Select **Number Filters** → **Greater Than**.
   - Enter `650`.
   - Select **OK**.

2. **Add Calculated Column:**
   - Select **Add column** in the ribbon.
   - Select **Custom column**.
   - Name: `CustomerSegment`
   - Formula:

     ```powerquery
     if [CreditScore] >= 750 then "Premium"
     else if [CreditScore] >= 700 then "Standard"
     else "Basic"
     ```

   - Select **OK**.

3. **Select Final Columns:**
   - Select **Choose columns** in the ribbon.
   - Select: CustomerID, FirstName, LastName, Email, State, CreditScore, CustomerSegment.
   - Select **OK**.

### Review Applied Steps

1. Look at the **Query Settings** pane on the right.

2. Under **Applied Steps**, you should see:
   - Source
   - Navigation
   - Filtered Rows
   - Added Custom Column
   - Removed Other Columns

---

## 🔧 Step 4: Configure Dataflow Destination

### Set Output Destination

1. Select the query name in the Queries pane.

2. In the **Query settings** pane on the right, scroll to the bottom.

3. Select **Choose destination settings** (or **+ Add data destination** if shown).

4. Select **Lakehouse** as the destination type.

5. Connect to your `CustomerDataLakehouse`.

6. Configure destination:

   | Setting | Value |
   |---------|-------|
   | **Table name** | `customers_segmented` |
   | **Update method** | Replace |

6. Select **Next** → **Save settings**.

### Publish Dataflow

1. Select **Publish** in the top right.

2. Wait for the dataflow to be published.

3. Name the dataflow: `DF_CustomerSegmentation`.

4. The dataflow is now saved and ready to run.

---

## 🔧 Step 5: Run and Monitor Dataflow

### Execute Dataflow

1. Return to the workspace view.

2. Find `DF_CustomerSegmentation` in the item list.

3. Hover over it and select the **Refresh** icon.

4. The dataflow starts executing.

### Monitor Execution

1. Select the dataflow name.

2. Select **Refresh history**.

3. View the execution status:
   - **In Progress**: Currently running.
   - **Succeeded**: Completed successfully.
   - **Failed**: Check error details.

### Verify Output

1. Open `CustomerDataLakehouse`.

2. Expand **Tables**.

3. Look for `customers_segmented` table.

4. Preview the data to verify transformations applied.

---

## 🔧 Step 6: Create a Data Factory Pipeline

### Create New Pipeline

1. Return to workspace.

2. Select **+ New item**.

3. Select **Data pipeline**.

4. Name: `PL_CustomerDataRefresh`.

5. Select **Create**.

### Add Dataflow Activity

1. In the pipeline canvas, you'll see the activity palette.

2. Drag **Dataflow** activity onto the canvas.

3. Configure the activity:
   - **Name**: `Run Customer Segmentation`
   - **Settings** tab → Select `DF_CustomerSegmentation`.

4. Select **Save**.

---

## 🔧 Step 7: Add Pipeline Orchestration

### Add Notification (Optional)

1. From the activity palette, add a **Set variable** activity after the dataflow.

2. This demonstrates pipeline orchestration concepts.

### Configure Pipeline Schedule

1. Select the pipeline canvas (not an activity).

2. Select **Schedule** in the toolbar.

3. Configure:

   | Setting | Value |
   |---------|-------|
   | **Scheduled run** | On |
   | **Repeat** | Daily |
   | **Time** | 02:00 AM |

4. Select **Apply** to save.

5. For this lab, you can turn the schedule **Off** after configuring.

---

## 🔧 Step 8: Run Pipeline Manually

### Execute Pipeline

1. Select **Run** in the pipeline toolbar.

2. Confirm the run.

3. The pipeline starts executing.

### Monitor Pipeline Run

1. Select **View run history** or **Monitor**.

2. View the pipeline run status.

3. Expand the run to see individual activity status.

4. Verify the dataflow activity completed successfully.

---

## ✅ Validation Checklist

Before proceeding to Lab 04, verify:

- [ ] Dataflow `DF_CustomerSegmentation` exists and runs successfully.
- [ ] Table `customers_segmented` exists in Lakehouse.
- [ ] New table contains `CustomerSegment` calculated column.
- [ ] Pipeline `PL_CustomerDataRefresh` exists.
- [ ] Pipeline can execute the dataflow successfully.

---

## ❌ Troubleshooting

### Dataflow Publish Fails

**Symptom**: Error when publishing dataflow.

**Resolution**:

1. Check for unsupported Power Query functions.
2. Verify destination Lakehouse is accessible.
3. Ensure column names don't contain special characters.

### Pipeline Activity Fails

**Symptom**: Dataflow activity fails in pipeline.

**Resolution**:

1. Check dataflow runs successfully standalone first.
2. Verify pipeline has access to the dataflow.
3. Check for timeout issues (increase timeout in settings).

### Data Not Appearing in Destination

**Symptom**: Dataflow succeeds but table is empty.

**Resolution**:

1. Check the destination table name.
2. Verify update method (Replace vs Append).
3. Ensure filter conditions aren't too restrictive.

---

## 📚 Related Resources

- [Create a Dataflow Gen2](https://learn.microsoft.com/fabric/data-factory/create-first-dataflow-gen2)
- [Data Factory pipelines](https://learn.microsoft.com/fabric/data-factory/create-first-pipeline-with-sample-data)
- [Power Query transformations](https://learn.microsoft.com/power-query/power-query-quickstart-using-power-bi)

---

## ➡️ Next Steps

Proceed to:

**[Lab 04: Create Warehouse and SQL Analytics](../04-Create-Warehouse-SQL-Analytics/)**

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Dataflow and pipeline steps were verified against Microsoft Learn documentation within **Visual Studio Code**.
