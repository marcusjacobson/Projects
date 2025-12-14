# Lab 03: Data Ingestion with Connectors

## 🎯 Objective

Use Dataflows Gen2 and Data Factory pipelines to ingest and transform data into your Lakehouse.

**Duration**: 45 minutes

---

## 🏗️ What You'll Build

| Item | Description |
|------|-------------|
| **DF_CustomerSegmentation** | Dataflow Gen2 that filters and enriches customer data |
| **customers_segmented** | New table with high-value customers and segment classifications |
| **PL_CustomerDataRefresh** | Pipeline that orchestrates dataflow execution |
| **Scheduled Refresh** | Automated daily pipeline trigger (optional) |

### Real-World Context

This lab implements a **customer segmentation pipeline**—one of the most common analytics patterns in business:

- **Marketing teams** use segmentation to target campaigns by customer value tier.
- **Sales teams** prioritize outreach based on customer potential.
- **Risk teams** apply different credit policies to Premium vs. Basic customers.

The **Dataflow → Pipeline pattern** you're building is the standard approach for:

- **ETL/ELT workflows** (Extract, Transform, Load).
- **Scheduled data refreshes** (daily, hourly, real-time).
- **Orchestrated dependencies** (run transformation A, then B, then C).

In production, organizations build hundreds of these pipelines to move and transform data across their analytics estate.

---

## 📋 Prerequisites

- [ ] Lab 02 completed (Lakehouse created with data).
- [ ] Access to `Fabric-Purview-Lab` workspace.
- [ ] Familiarity with basic data transformation concepts.

---

## 📥 Data Ingestion Options Overview

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

## 🔧 Step 1: Create a Dataflow Gen2

### Navigate to Workspace

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Open your **Fabric-Purview-Lab** workspace.

### Create Dataflow

1. Select **+ New item**.

2. In the **New item** pane, search for or select **Dataflow Gen2**.

3. In the **New Dataflow Gen2** dialog:
   - **Name**: `DF_CustomerSegmentation`
   - Leave **Enable Git integration** checked.

4. Select **Create**.

5. The Power Query editor opens.

### Connect to Lakehouse Data

The Power Query editor displays a welcome screen with data source options:

- **Add default destination** - Configure output location.
- **Import from Excel** - Load Excel files.
- **Import from SQL Server** - Connect to SQL databases.
- **Import from a Text/CSV file** - Load CSV/text files.
- **Import from dataflows** - Reuse other dataflows.

1. Select **Get data from another source →** at the bottom.

2. In the **Choose data source** dialog, search for or select **Lakehouse**.

3. Select your `CustomerDataLakehouse`.

4. Select the `customers` table.

5. Select **Create** to load the data into Power Query.

---

## 🔧 Step 2: Apply Data Transformations

### Explore the Power Query Interface

Once the data loads, you'll see:

- **Queries pane** (left): Shows your `customers` query.
- **Data preview** (center): Displays the table data with column headers.
- **Query settings** (right): Shows **Properties** (query name), **Applied steps**, and **Data destination**.

The **Applied steps** section shows the steps already applied:

- Source
- Navigation (one or more steps depending on how you connected)

> 📷 **Screenshot**: Power Query editor showing Queries pane (left), data preview (center), and Query settings with Applied steps (right)

### Add Transformation Steps

1. **Filter High-Value Customers:**
   - Select the **CreditScore** column header.
   - Select the filter dropdown arrow.
   - Select **Number Filters** → **Greater Than**.
   - Enter `650`.
   - Select **OK**.

2. **Add Calculated Column:**
   - Select **Add column** in the ribbon.
   - Select **Custom column**.
   - **New column name**: `CustomerSegment`
   - **Data type**: Leave as default (auto-detects text).
   - **Custom column formula**:

     ```powerquery
     if [CreditScore] >= 750 then "Premium"
     else if [CreditScore] >= 700 then "Standard"
     else "Basic"
     ```

   - Select **OK**.

> 📷 **Screenshot**: Custom column dialog showing column name "CustomerSegment" and the if-then-else formula entered

3. **Select Final Columns:**
   - Select **Home** in the ribbon.
   - Select **Choose columns**.
   - Select: CustomerID, FirstName, LastName, Email, State, CreditScore, CustomerSegment.
   - Select **OK**.

### Review Applied Steps

1. In the **Query settings** pane on the right, review **Applied steps**.

2. You should now see these steps:
   - Source
   - Navigation
   - Navigation 1
   - Navigation 2
   - Filtered rows
   - Added custom
   - Choose columns

---

## 🔧 Step 3: Configure Dataflow Destination

### Set Output Destination

1. In the **Query settings** pane on the right, locate **Data destination** at the bottom.

2. Select the **+** button next to **Data destination**.

3. Select **Lakehouse** as the destination type.

4. In the **Connect to data destination** dialog, select your connection and select **Next**.

5. In the **Choose destination target** dialog:
   - Select **New table** (default).
   - In the left pane, expand and select **CustomerDataLakehouse**.
   - **Table name**: Enter `customers_segmented`.

6. Select **Next**.

7. Review the column mapping settings and select **Save settings**.

> 📷 **Screenshot**: Data destination configuration showing Lakehouse selected with table name "customers_segmented" entered

### Save and Run Dataflow

1. Select **Save & run** in the **Home** ribbon (or select the dropdown arrow next to the save icon).

2. This saves your changes and immediately starts running the dataflow.

---

## 🔧 Step 4: Monitor Dataflow and Verify Output

### Return to Workspace

1. Return to the workspace view (select **Fabric-Purview-Lab** in the breadcrumb or navigation).

2. In the workspace item list, you'll see:
   - **CustomerDataLakehouse** (Lakehouse)
   - **CustomerDataLakehouse** (SQL analytics endpoint)
   - **DF_CustomerSegmentation** (Dataflow Gen2) - may show a spinning indicator if still running

3. The **Refreshed** column shows when the dataflow last ran.

### Monitor Execution

1. If the dataflow is still running (spinning indicator), wait for it to complete (typically 1-2 minutes).

2. The **Refreshed** column updates when the dataflow finishes.

3. Execution status indicators:
   - **Spinning icon**: Currently running.
   - **Checkmark**: Completed successfully.
   - **Error icon**: Failed - hover for details.

### Verify Output

1. Open **CustomerDataLakehouse** from the workspace.

2. In the Explorer pane, right-click on **Tables**.

3. Select **Refresh** from the context menu.

4. Expand **Tables** → **dbo** and look for the `customers_segmented` table.

5. Select the table to preview the data and verify:
   - Only customers with CreditScore > 650 appear.
   - The **CustomerSegment** column shows Premium, Standard, or Basic values.

---

## 🔧 Step 5: Create a Data Factory Pipeline

### Create New Pipeline

1. In the workspace, select **+ New item**.

2. Search for or select **Pipeline**.

3. In the **Name** field, enter `PL_CustomerDataRefresh`.

4. Select **Create**.

### Pipeline Welcome Screen

The pipeline opens to a welcome screen with options:

- **Start with a blank canvas**:
  - **Pipeline activity** - Build custom orchestrations.
- **Start with guidance**:
  - **Copy data assistant** - Guided data copy wizard.
  - **Practice with sample data** - Use sample templates.
  - **Templates** - Pre-built pipeline templates.

### Add Dataflow Activity

1. Select **Pipeline activity** to start with a blank canvas.

2. In the **Home** ribbon, select **Dataflow** from the toolbar.

3. A Dataflow activity appears on the canvas.

4. With the activity selected, configure in the properties pane below:
   - **General** tab → **Name**: `Run Customer Segmentation`
   - **Settings** tab → **Dataflow**: Select `DF_CustomerSegmentation`.

5. Select **Save** in the toolbar (or press Ctrl+S).

> 📷 **Screenshot**: Pipeline editor canvas showing Dataflow activity with properties pane displaying General and Settings tabs

---

## 🔧 Step 6: Configure Pipeline Schedule (Optional)

### Open Schedule Settings

1. From the pipeline editor, select **Schedule** in the toolbar.

2. A settings panel opens on the right with tabs: **About**, **Endorsement**, **Schedule**.

3. The **Schedule** tab shows:
   - **Refresh status**: Shows last successful refresh and a **Run now** button.
   - **Scheduled run**: Where you configure automated schedules.

### Add a Schedule

1. Select **+ Add schedule**.

2. Configure the schedule:

   | Setting | Value |
   |---------|-------|
   | **Repeat** | Daily |
   | **Time of day** | 02:00 AM |
   | **Start date and time** | Today's date |
   | **End date and time** | A date 1 week from today |
   | **Time zone** | Your local time zone |

3. Select **Save** to save the schedule.

4. For this lab, you can delete the schedule after testing (schedules incur compute costs).

> **💡 Note**: You can also run the pipeline manually using the **Run now** button in the Refresh status section.

---

## 🔧 Step 7: Run Pipeline Manually

### Execute Pipeline

1. In the pipeline editor, select **Run** in the **Home** ribbon.

2. The pipeline starts executing immediately.

### Monitor Pipeline Run

The **Output** pane appears at the bottom of the screen showing:

- **Pipeline run ID**: Unique identifier for this run.
- **Pipeline status**: Shows **In progress** while running.
- **Activity list**: Shows each activity with:
  - **Activity name**: `Run Customer Segmentation`
  - **Activity status**: Queued → In progress → Succeeded
  - **Run start**: Timestamp when the activity started.
  - **Duration**: How long the activity has been running.

1. Wait for the **Pipeline status** to change to **Succeeded**.

2. The **Activity status** for `Run Customer Segmentation` should also show **Succeeded**.

3. If any activity fails, select it to view error details in the **Output** column.

> 📷 **Screenshot**: Pipeline Output pane showing activity status progression (In progress → Succeeded) with duration and timestamps

> **💡 Note**: The output pane auto-refreshes for 5 minutes while the pipeline is running. You can select **Turn off auto-refresh** to stop automatic updates.

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

### Dataflow Save & Run Fails

**Symptom**: Error when saving or running dataflow.

**Resolution**:

1. Check for unsupported Power Query functions.
2. Verify destination Lakehouse is accessible.
3. Ensure column names don't contain special characters.
4. Check that the destination table name is valid (no spaces or special characters).

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
