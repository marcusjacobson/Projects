# Lab 04: Create Warehouse and SQL Analytics

## 🎯 Objective

Create a Fabric Warehouse, load data from the Lakehouse, and run T-SQL analytics queries.

**Duration**: 30 minutes

---

## 📋 Prerequisites

- [ ] Lab 02 completed (Lakehouse with data).
- [ ] Access to `Fabric-Purview-Lab` workspace.
- [ ] Basic SQL knowledge recommended.

---

## 🔧 Step 1: Understand Lakehouse vs Warehouse

| Feature | Lakehouse | Warehouse |
|---------|-----------|-----------|
| **Primary Use** | Data engineering, ML | Business analytics, reporting |
| **Query Language** | Spark SQL, PySpark | T-SQL |
| **Schema** | Schema-on-read | Schema-on-write |
| **Performance** | Optimized for large-scale processing | Optimized for BI queries |
| **Data Format** | Delta Lake (Parquet) | Delta Lake (Parquet) |

> **💡 Key Insight**: Both use Delta Lake format, enabling seamless data sharing via shortcuts.

---

## 🔧 Step 2: Create Warehouse

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

## 🔧 Step 3: Create Shortcut to Lakehouse Data

Instead of duplicating data, we'll create a shortcut to the Lakehouse tables.

### Add Shortcut

1. In the Warehouse, expand the **Schemas** folder.

2. Right-click on **dbo** schema.

3. Select **New shortcut**.

4. Choose **Microsoft OneLake**.

5. Navigate to:
   - Your workspace: `Fabric-Purview-Lab`
   - Lakehouse: `CustomerDataLakehouse`
   - Tables folder

6. Select the following tables (hold Ctrl to multi-select):
   - `customers`
   - `transactions`
   - `customers_segmented` (if created in Lab 03)

7. Select **Create**.

### Verify Shortcuts

1. Expand **dbo** → **Tables**.

2. You should see the shortcut tables with a shortcut icon.

3. These tables reference the Lakehouse data directly.

---

## 🔧 Step 4: Write Analytics Queries

### Open Query Editor

1. Select **New SQL query** in the toolbar.

2. A new query tab opens.

### Query 1: Customer State Distribution

Copy and run this query:

```sql
-- Customer distribution by state
SELECT 
    State,
    COUNT(*) AS CustomerCount,
    AVG(CreditScore) AS AvgCreditScore,
    MIN(CreditScore) AS MinCreditScore,
    MAX(CreditScore) AS MaxCreditScore
FROM dbo.customers
GROUP BY State
ORDER BY CustomerCount DESC;
```

1. Select the query text.
2. Select **Run** or press F5.
3. View results in the results pane.

### Query 2: Transaction Analysis

```sql
-- Transaction summary by type
SELECT 
    TransactionType,
    COUNT(*) AS TransactionCount,
    SUM(Amount) AS TotalAmount,
    AVG(Amount) AS AvgAmount,
    MIN(TransactionDate) AS FirstTransaction,
    MAX(TransactionDate) AS LastTransaction
FROM dbo.transactions
GROUP BY TransactionType
ORDER BY TotalAmount DESC;
```

### Query 3: Customer Transaction Join

```sql
-- Customer spending analysis
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.State,
    c.CreditScore,
    COUNT(t.TransactionID) AS TotalTransactions,
    SUM(t.Amount) AS TotalSpending
FROM dbo.customers c
LEFT JOIN dbo.transactions t ON c.CustomerID = t.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.State, c.CreditScore
ORDER BY TotalSpending DESC;
```

---

## 🔧 Step 5: Create a View

### Create Reusable View

1. Open a new query tab.

2. Run this DDL statement:

```sql
-- Create a view for high-value customers
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
FROM dbo.customers c
LEFT JOIN dbo.transactions t ON c.CustomerID = t.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email, c.State, c.CreditScore
HAVING COALESCE(SUM(t.Amount), 0) > 1000 OR c.CreditScore >= 750;
```

3. Select **Run**.

4. The view is created.

### Query the View

```sql
-- Use the view
SELECT * FROM dbo.vw_HighValueCustomers
ORDER BY TotalSpending DESC;
```

---

## 🔧 Step 6: Create a Stored Procedure

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
    FROM dbo.customers
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

## 🔧 Step 7: Save and Organize Queries

### Save Query as Item

1. Select the **Save** icon in the query tab.

2. Name: `QRY_CustomerAnalytics`.

3. The query is saved to your workspace.

### View Saved Queries

1. Return to workspace view.

2. Find your saved query in the item list.

3. Saved queries can be shared and scheduled.

---

## 🔧 Step 8: Explore Query Insights

### View Query Performance

1. In the Warehouse, select **Query insights** in the left navigation.

2. This shows query history and performance metrics.

3. Review:
   - Query duration
   - Data processed
   - Cache usage

### Understand Query Plans

1. In a query tab, prefix your query with:

```sql
EXPLAIN
SELECT * FROM dbo.customers WHERE State = 'CA';
```

2. This shows the query execution plan.

---

## ✅ Validation Checklist

Before proceeding to Lab 05, verify:

- [ ] Warehouse `AnalyticsWarehouse` exists.
- [ ] Shortcuts to Lakehouse tables are working.
- [ ] Analytics queries run successfully.
- [ ] View `vw_HighValueCustomers` is created.
- [ ] Stored procedure `sp_CreditScoreReport` works.
- [ ] At least one query is saved to workspace.

---

## ❌ Troubleshooting

### Shortcut Creation Fails

**Symptom**: Cannot create shortcut to Lakehouse.

**Resolution**:

1. Verify you have access to the Lakehouse.
2. Check that tables exist in the Lakehouse.
3. Ensure the Lakehouse is in the same capacity region.

### Query Returns No Results

**Symptom**: Queries run but return empty results.

**Resolution**:

1. Verify shortcuts are active (not broken).
2. Check if source data exists in Lakehouse.
3. Review filter conditions in WHERE clause.

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
