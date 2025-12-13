# Lab 05: Real-Time Intelligence with KQL

## 🎯 Objective

Create an Eventhouse and KQL Database to ingest and analyze streaming data using Kusto Query Language (KQL).

**Duration**: 45 minutes

---

## 📋 Prerequisites

- [ ] Labs 01-02 completed (Workspace and Lakehouse exist).
- [ ] Access to `Fabric-Purview-Lab` workspace.
- [ ] Sample file: `streaming-events.json` from `data-templates/` folder.

---

## 🔧 Step 1: Understand Real-Time Intelligence Components

| Component | Purpose |
|-----------|---------|
| **Eventhouse** | Container for KQL databases and real-time data |
| **KQL Database** | Stores and queries time-series data |
| **KQL Queryset** | Saved KQL queries for analysis |
| **Eventstream** | Ingests real-time event data |

> **💡 Key Insight**: KQL (Kusto Query Language) is optimized for log and time-series data analysis, making it ideal for IoT, telemetry, and security scenarios.

---

## 🔧 Step 2: Create Eventhouse

### Navigate to Workspace

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Open your **Fabric-Purview-Lab** workspace.

### Create Eventhouse

1. Select **+ New item**.

2. In the **New item** pane, search for **Eventhouse** and select it.

3. Enter name: `IoTEventhouse`.

4. Select **Create**.

5. Wait for provisioning (1-2 minutes).

> **📝 Note**: Both an Eventhouse and its default child KQL database are created with the same name. The database name can be renamed at any time.

---

## 🔧 Step 3: Explore KQL Database

### Open KQL Database

1. In the Eventhouse, you'll see the default KQL Database.

2. Select **IoTEventhouse** (the database name).

3. The database overview shows:
   - Database details
   - Tables (empty initially)
   - Query options

---

## 🔧 Step 4: Create Table and Ingest Sample Data

### Prepare Sample Data

First, ensure you have the `streaming-events.json` file from the `data-templates/` folder.

### Get Data into KQL Database

1. In the KQL Database view, select **Get data**.

2. Select **Local file**.

3. Create a new table:
   - **Table name**: `IoTEvents`
   - Select **Next**.

4. Upload the `streaming-events.json` file.

5. Review the schema detection:
   - Fabric automatically detects JSON structure.
   - Verify column names and types.

6. Select **Finish** to complete ingestion.

### Verify Data Ingestion

1. After ingestion completes, select the `IoTEvents` table.

2. Preview the data to confirm it was loaded correctly.

---

## 🔧 Step 5: Write KQL Queries

### Open KQL Queryset

1. Select **New** → **KQL Queryset**.

2. Name: `KQL_IoTAnalytics`.

3. Connect to your `IoTEventhouse` database.

### Query 1: Basic Data Exploration

```kql
// View all events
IoTEvents
| take 20
```

1. Copy this query into the query editor.
2. Select **Run** or press Shift+Enter.

### Query 2: Event Count by Device

```kql
// Count events per device
IoTEvents
| summarize EventCount = count() by DeviceID
| order by EventCount desc
```

### Query 3: Temperature Analysis

```kql
// Temperature statistics by location
IoTEvents
| summarize 
    AvgTemp = avg(Temperature),
    MinTemp = min(Temperature),
    MaxTemp = max(Temperature),
    EventCount = count()
    by Location
| order by AvgTemp desc
```

### Query 4: Time-Based Analysis

```kql
// Events over time (grouped by hour)
IoTEvents
| extend Hour = bin(Timestamp, 1h)
| summarize EventCount = count() by Hour
| order by Hour asc
| render timechart
```

### Query 5: Anomaly Detection

```kql
// Find high temperature events (potential anomalies)
IoTEvents
| where Temperature > 80
| project Timestamp, DeviceID, Location, Temperature, Humidity
| order by Temperature desc
```

---

## 🔧 Step 6: Create Materialized View

Materialized views pre-aggregate data for faster queries.

### Create View

```kql
// Create materialized view for device statistics
.create materialized-view DeviceStats on table IoTEvents
{
    IoTEvents
    | summarize 
        AvgTemperature = avg(Temperature),
        AvgHumidity = avg(Humidity),
        EventCount = count(),
        LastEvent = max(Timestamp)
        by DeviceID, Location
}
```

> **⚠️ Note**: In Fabric KQL Database, materialized views may have limited support. If this command fails, skip to the next step.

### Alternative: Create Function

```kql
// Create a function for reusable queries
.create-or-alter function DeviceStatistics() {
    IoTEvents
    | summarize 
        AvgTemperature = avg(Temperature),
        AvgHumidity = avg(Humidity),
        EventCount = count(),
        LastEvent = max(Timestamp)
        by DeviceID, Location
}
```

### Use the Function

```kql
// Call the function
DeviceStatistics()
| order by EventCount desc
```

---

## 🔧 Step 7: Visualize Query Results

### Render Charts

```kql
// Temperature by location as bar chart
IoTEvents
| summarize AvgTemp = avg(Temperature) by Location
| render barchart
```

```kql
// Event distribution as pie chart
IoTEvents
| summarize Count = count() by DeviceID
| render piechart
```

```kql
// Temperature trend as line chart
IoTEvents
| order by Timestamp asc
| project Timestamp, Temperature
| render linechart
```

### Pin to Dashboard (Optional)

1. After running a query with visualization, select **Pin to dashboard**.

2. Create a new dashboard or add to existing.

3. This creates real-time monitoring capabilities.

---

## 🔧 Step 8: Save and Organize Queries

### Save KQL Queryset

1. Select **Save** in the KQL Queryset.

2. Verify `KQL_IoTAnalytics` is saved to your workspace.

### Create Additional Queryset for Alerts

1. Create another KQL Queryset: `KQL_IoTAlerts`.

2. Add alert-focused queries:

```kql
// Temperature threshold alert
IoTEvents
| where Temperature > 85
| project AlertTime = Timestamp, DeviceID, Location, Temperature
| extend AlertSeverity = case(
    Temperature > 95, "Critical",
    Temperature > 90, "High",
    "Medium"
)
| order by AlertTime desc
```

---

## ✅ Validation Checklist

Before proceeding to Lab 06, verify:

- [ ] Eventhouse `IoTEventhouse` exists.
- [ ] KQL Database contains `IoTEvents` table.
- [ ] Sample data is visible in the table.
- [ ] KQL queries execute successfully.
- [ ] At least one visualization renders correctly.
- [ ] KQL Queryset `KQL_IoTAnalytics` is saved.

---

## ❌ Troubleshooting

### Data Ingestion Fails

**Symptom**: Error when uploading JSON file.

**Resolution**:

1. Verify JSON format is valid (array of objects).
2. Check that file isn't too large (< 100 MB for single upload).
3. Ensure column names don't have spaces or special characters.

### Query Syntax Errors

**Symptom**: KQL query fails to parse.

**Resolution**:

1. KQL is case-sensitive for function names.
2. Use `|` (pipe) to chain operators.
3. End commands with semicolon if running multiple.

### Visualization Not Rendering

**Symptom**: `render` command doesn't show chart.

**Resolution**:

1. Verify data is returned by the query.
2. Check that column types are appropriate for the chart type.
3. Try a different render type (barchart, piechart, timechart).

### Materialized View Fails

**Symptom**: `.create materialized-view` returns error.

**Resolution**:

1. Use functions instead (`.create-or-alter function`).
2. Materialized views have specific requirements in Fabric.
3. Check documentation for current limitations.

---

## 📚 KQL Quick Reference

| Operator | Purpose | Example |
|----------|---------|---------|
| `where` | Filter rows | `where Temperature > 70` |
| `summarize` | Aggregate data | `summarize avg(Temperature) by Location` |
| `project` | Select columns | `project Timestamp, DeviceID` |
| `extend` | Add calculated column | `extend TempF = Temperature * 9/5 + 32` |
| `order by` | Sort results | `order by Timestamp desc` |
| `take` | Limit rows | `take 100` |
| `render` | Visualize | `render barchart` |
| `bin` | Time bucketing | `bin(Timestamp, 1h)` |

---

## 📚 Related Resources

- [Eventhouse overview](https://learn.microsoft.com/fabric/real-time-intelligence/eventhouse)
- [KQL quick reference](https://learn.microsoft.com/azure/data-explorer/kql-quick-reference)
- [Real-Time Intelligence tutorial](https://learn.microsoft.com/fabric/real-time-intelligence/tutorial-introduction)

---

## ➡️ Next Steps

Proceed to:

**[Lab 06: Purview Integration and Scanning](../06-Purview-Integration-Scanning/)**

> **🎯 Important**: Lab 06 is a critical integration point where we connect Microsoft Purview to scan all the Fabric assets you've created.

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. KQL queries were verified against Azure Data Explorer documentation within **Visual Studio Code**.
