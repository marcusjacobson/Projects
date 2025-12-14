# Lab 04: Create Warehouse and SQL Analytics

## 🎯 Objective

Create a Fabric Warehouse and use cross-database queries to analyze Lakehouse data with T-SQL.

**Duration**: 30 minutes

---

## 🏗️ What You'll Build

| Item | Description |
|------|-------------|
| **AnalyticsWarehouse** | Fabric Warehouse optimized for T-SQL analytics and BI |
| **Cross-Database Queries** | T-SQL queries that access Lakehouse data directly (no duplication) |
| **vw_HighValueCustomers** | SQL view for premium customer analysis |
| **vw_CustomerSpendingAnalysis** | SQL view combining customer demographics with spending (for Power BI) |
| **sp_CreditScoreReport** | Stored procedure for parameterized reporting |

### Real-World Context

The Warehouse complements the Lakehouse for **business intelligence workloads**:

- **BI Analysts** prefer T-SQL over Spark for ad-hoc analysis.
- **Reporting tools** connect natively to SQL endpoints.
- **Performance optimization** through materialized views and statistics.

The **Cross-Database Query pattern** you're implementing is a key Fabric innovation:

- **Zero data movement** — query Lakehouse data from Warehouse without copying.
- **Single source of truth** — changes in Lakehouse reflect immediately in queries.
- **DDL in Warehouse** — create views and stored procedures that reference Lakehouse data.
- **Cost efficiency** — no storage duplication across analytics layers.

This architecture mirrors the **Medallion Architecture** (Bronze/Silver/Gold) used by data teams worldwide, where Lakehouses hold raw/refined data and Warehouses serve the consumption layer with reusable SQL objects.

---

## 📋 Prerequisites

- [ ] Lab 02 completed (Lakehouse with data).
- [ ] Access to `Fabric-Purview-Lab` workspace.
- [ ] Basic SQL knowledge recommended.

---

## 📊 Lakehouse vs Warehouse Overview

| Feature | Lakehouse | Warehouse |
|---------|-----------|-----------|
| **Primary Use** | Data engineering, ML, flexible storage | Business analytics, reporting |
| **Query Language** | T-SQL (via SQL endpoint), Spark SQL, PySpark | T-SQL only |
| **Schema** | Schema-on-read (flexible) | Schema-on-write (enforced) |
| **Performance** | Optimized for large-scale processing | Optimized for BI queries |
| **Data Format** | Delta Lake (Parquet) | Delta Lake (Parquet) |
| **DDL Support** | Limited (no stored procedures) | Full T-SQL DDL (views, procedures, functions) |

> **💡 Key Insight**: Both use Delta Lake format and T-SQL for querying. The Warehouse adds full DDL support for views, stored procedures, and advanced SQL objects that aren't available in the Lakehouse SQL endpoint.

---

## 🔧 Step 1: Create Warehouse

### Navigate to Workspace

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
2. Open your **Fabric-Purview-Lab** workspace.

### Create New Warehouse

1. Select **+ New item**.
2. In the **New item** pane, under **Store data**, select **Warehouse**.
3. Enter name: `AnalyticsWarehouse`.
4. Select **Create**.
5. Wait for the Warehouse to provision (30-60 seconds).

---

## 🔧 Step 2: Query Lakehouse Data Using Cross-Database Queries

Instead of duplicating data, Fabric Warehouse supports **cross-database queries** that let you query Lakehouse tables directly using three-part naming.

### Understanding Cross-Database Queries

In Fabric, you can query any item in OneLake using:

```sql
[ItemName].[Schema].[Table]
```

For example, to query the customers table in your Lakehouse:

```sql
SELECT * FROM [CustomerDataLakehouse].[dbo].[customers];
```

### Test Cross-Database Query

1. Select **New SQL query** in the toolbar (or select the dropdown arrow and choose **New SQL query**).
2. Run this query to verify access to Lakehouse data:

```sql
-- Query Lakehouse tables directly from Warehouse
SELECT TOP 10 * 
FROM [CustomerDataLakehouse].[dbo].[customers];
```

3. Select **Run** or press F5.
4. You should see customer data from the Lakehouse.

> **💡 Key Insight**: Cross-database queries provide zero-copy access to Lakehouse data. No data is duplicated—you're querying the source directly.

### Verify Both Tables Are Accessible

```sql
-- Verify customers table
SELECT COUNT(*) AS CustomerCount 
FROM [CustomerDataLakehouse].[dbo].[customers];

-- Verify transactions table
SELECT COUNT(*) AS TransactionCount 
FROM [CustomerDataLakehouse].[dbo].[transactions];
```

---

## 🔧 Step 3: Write Analytics Queries

Now write some analytics queries that demonstrate cross-database joins and aggregations.

### Query 1: Customer State Distribution

1. Open a new query tab (**New SQL query** in the toolbar).
2. Copy and run this query:

```sql
-- Customer distribution by state (cross-database query)
SELECT 
    State,
    COUNT(*) AS CustomerCount,
    AVG(CreditScore) AS AvgCreditScore,
    MIN(CreditScore) AS MinCreditScore,
    MAX(CreditScore) AS MaxCreditScore
FROM [CustomerDataLakehouse].[dbo].[customers]
GROUP BY State
ORDER BY CustomerCount DESC;
```

3. Select **Run** or press F5 to see results.

### Query 2: Transaction Analysis by Category

In the same query tab (or a new one), run:

```sql
-- Transaction summary by merchant category
SELECT 
    MerchantCategory,
    COUNT(*) AS TransactionCount,
    SUM(Amount) AS TotalAmount,
    AVG(Amount) AS AvgAmount,
    MIN(TransactionDate) AS FirstTransaction,
    MAX(TransactionDate) AS LastTransaction
FROM [CustomerDataLakehouse].[dbo].[transactions]
GROUP BY MerchantCategory
ORDER BY TotalAmount DESC;
```

### Query 3: Customer Transaction Join

This query joins both tables:

```sql
-- Customer spending analysis (cross-database join)
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.State,
    c.CreditScore,
    COUNT(t.TransactionID) AS TotalTransactions,
    SUM(t.Amount) AS TotalSpending
FROM [CustomerDataLakehouse].[dbo].[customers] c
LEFT JOIN [CustomerDataLakehouse].[dbo].[transactions] t ON c.CustomerID = t.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.State, c.CreditScore
ORDER BY TotalSpending DESC;
```

---

## 🔧 Step 4: Create a View

### Create Reusable View

1. Open a new query tab.
2. Run this DDL statement:

```sql
-- Create a view for high-value customers (references Lakehouse data)
CREATE VIEW dbo.vw_HighValueCustomers
AS
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email,
    c.State,
    c.CreditScore,
    COALESCE(SUM(t.Amount), 0) AS TotalSpending,
    COUNT(t.TransactionID) AS TransactionCount
FROM [CustomerDataLakehouse].[dbo].[customers] c
LEFT JOIN [CustomerDataLakehouse].[dbo].[transactions] t ON c.CustomerID = t.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email, c.State, c.CreditScore
HAVING COALESCE(SUM(t.Amount), 0) > 1000 OR c.CreditScore >= 750;
```

3. Select **Run**.
4. The view is created in your Warehouse but queries Lakehouse data.

### Query the View

```sql
-- Use the view
SELECT * FROM dbo.vw_HighValueCustomers
ORDER BY TotalSpending DESC;
```

---

## 🔧 Step 5: Create a Stored Procedure

### Create Procedure for Reporting

```sql
-- Create a stored procedure for credit score analysis
CREATE PROCEDURE dbo.sp_CreditScoreReport
    @MinCreditScore INT = 650
AS
BEGIN
    SELECT 
        CASE 
            WHEN CreditScore >= 800 THEN 'Excellent'
            WHEN CreditScore >= 740 THEN 'Very Good'
            WHEN CreditScore >= 670 THEN 'Good'
            WHEN CreditScore >= 580 THEN 'Fair'
            ELSE 'Poor'
        END AS CreditTier,
        COUNT(*) AS CustomerCount,
        AVG(CreditScore) AS AvgScore
    FROM [CustomerDataLakehouse].[dbo].[customers]
    WHERE CreditScore >= @MinCreditScore
    GROUP BY 
        CASE 
            WHEN CreditScore >= 800 THEN 'Excellent'
            WHEN CreditScore >= 740 THEN 'Very Good'
            WHEN CreditScore >= 670 THEN 'Good'
            WHEN CreditScore >= 580 THEN 'Fair'
            ELSE 'Poor'
        END
    ORDER BY AvgScore DESC;
END;
```

### Execute Procedure

```sql
-- Run with default parameter
EXEC dbo.sp_CreditScoreReport;

-- Run with custom parameter
EXEC dbo.sp_CreditScoreReport @MinCreditScore = 700;
```

---

## 🔧 Step 6: Create View for Power BI

In Lab 08, you'll create Power BI visualizations. Create a view now that combines customer and spending data.

### Create Customer Spending View

1. Open a new query tab.
2. Enter this query (combining customer and transaction data):

```sql
-- Customer spending analysis for Power BI visualization
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.State,
    c.CreditScore,
    CASE 
        WHEN c.CreditScore >= 750 THEN 'Premium'
        WHEN c.CreditScore >= 700 THEN 'Standard'
        ELSE 'Basic'
    END AS CustomerSegment,
    COUNT(t.TransactionID) AS TotalTransactions,
    COALESCE(SUM(t.Amount), 0) AS TotalSpending
FROM [CustomerDataLakehouse].[dbo].[customers] c
LEFT JOIN [CustomerDataLakehouse].[dbo].[transactions] t ON c.CustomerID = t.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.State, c.CreditScore;
```

3. Run the query to verify it works (you should see customer data with segments and spending).
4. **Select the entire query text** (Ctrl+A in the query editor, or manually highlight from `SELECT` to the final semicolon).
5. With the query text selected, select **Save as view** in the toolbar.
6. In the **Save as view** dialog:
   - **Name**: `vw_CustomerSpendingAnalysis`
   - Select **OK** or **Save**.
7. The view is saved in your Warehouse under **Views**.

> **⚠️ Important**: You must select/highlight the query text before clicking **Save as view**. If you click the button without selecting text, you'll see an error: "To save as a view, select the text of one SELECT statement."
>
> **💡 Why Save as a View?**: In Fabric Warehouse, queries are saved as views rather than standalone query files. This view will be available as a data source in Lab 08 for Power BI visualizations.

### Verify All Objects Created

1. In the Explorer pane (left side), expand **Schemas** → **dbo** → **Views** to see both views.
2. Expand **Stored Procedures** to see the stored procedure.
3. Close any open query tabs — the permanent objects are saved in the Warehouse.

---

## 🔧 Step 7: Explore Query Insights

Fabric Warehouse provides built-in query insights through system views in the **queryinsights** schema.

### View Available Insight Views

1. In the Explorer pane, expand **Schemas** → **queryinsights** → **Views**.
2. You'll see these system views:
   - `exec_requests_history` — History of all query executions
   - `exec_sessions_history` — Session connection history
   - `frequently_run_queries` — Most commonly executed queries
   - `long_running_queries` — Queries that took longest to execute
   - `sql_pool_insights` — Overall pool performance metrics

### Query Execution History

1. Open a new query tab.
2. Run this query to see your recent query history:

```sql
SELECT TOP 20
    start_time,
    end_time,
    DATEDIFF(SECOND, start_time, end_time) AS duration_seconds,
    command,
    status
FROM queryinsights.exec_requests_history
ORDER BY start_time DESC;
```

3. Review your queries from this lab session.

### Find Long-Running Queries

```sql
SELECT *
FROM queryinsights.long_running_queries;
```

> **💡 Tip**: These insights help identify slow queries and optimization opportunities in production scenarios.

---

## ✅ Validation Checklist

Before proceeding to Lab 05, verify:

- [ ] Warehouse `AnalyticsWarehouse` exists.
- [ ] Cross-database queries to Lakehouse tables work.
- [ ] Analytics queries run successfully and return data.
- [ ] View `vw_HighValueCustomers` exists (check Explorer → Views).
- [ ] View `vw_CustomerSpendingAnalysis` exists (check Explorer → Views).
- [ ] Stored procedure `sp_CreditScoreReport` exists (check Explorer → Stored Procedures).

---

## ❌ Troubleshooting

### Cross-Database Query Fails

**Symptom**: Error "Invalid object name" when querying Lakehouse.

**Resolution**:

1. Verify the Lakehouse name is spelled correctly (case-sensitive).
2. Check that the Lakehouse exists in the same workspace.
3. Ensure you have read access to the Lakehouse.
4. Use the exact three-part name: `[LakehouseName].[dbo].[TableName]`.

### Query Returns No Results

**Symptom**: Queries run but return empty results.

**Resolution**:

1. Verify data exists in the Lakehouse tables.
2. Check filter conditions in WHERE clause.
3. Run a simple `SELECT COUNT(*)` to verify table access.

### View or Procedure Already Exists

**Symptom**: Error "object already exists".

**Resolution**:

Use CREATE OR ALTER instead:

```sql
CREATE OR ALTER VIEW dbo.vw_HighValueCustomers
AS
-- view definition
```

---

## 📚 Related Resources

- [Create a Warehouse](https://learn.microsoft.com/fabric/data-warehouse/create-warehouse)
- [T-SQL reference for Fabric](https://learn.microsoft.com/fabric/data-warehouse/tsql-surface-area)
- [Query data using SQL](https://learn.microsoft.com/fabric/data-warehouse/query-warehouse)

---

## ➡️ Next Steps

Proceed to:

**[Lab 05: Real-Time Analytics with KQL](../05-Real-Time-Analytics-KQL/)**

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. T-SQL queries and procedures were verified against Fabric documentation within **Visual Studio Code**.
