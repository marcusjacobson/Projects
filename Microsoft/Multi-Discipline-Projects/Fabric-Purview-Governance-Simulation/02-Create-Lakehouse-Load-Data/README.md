# Lab 02: Create Lakehouse and Load Data

## 🎯 Objective

Create a Lakehouse in your Fabric workspace and load sample data containing classifiable sensitive information.

**Duration**: 45 minutes

---

## 📋 Prerequisites

- [ ] Lab 01 completed (Fabric enabled, workspace created).
- [ ] Sample data files available (`customers.csv`, `transactions.csv`).
- [ ] Access to `Fabric-Purview-Lab` workspace.

---

## 🔧 Step 1: Understand Lakehouse Architecture

Before creating a Lakehouse, understand its key components:

| Component | Description | Purpose |
|-----------|-------------|---------|
| **Files** | Unstructured storage (Azure Data Lake) | Store raw files, images, documents |
| **Tables** | Delta Lake tables | Structured data with ACID transactions |
| **SQL Endpoint** | T-SQL access to tables | Query tables using SQL |
| **Default Semantic Model** | Power BI dataset | Connect Power BI to Lakehouse data |

> **💡 Key Concept**: Lakehouse combines the flexibility of data lakes with the structure of data warehouses. Files are stored as-is, while Tables use Delta Lake format for transactional consistency.

---

## 🔧 Step 2: Create Lakehouse

### Navigate to Workspace

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Select **Workspaces** in the left navigation.

3. Select your **Fabric-Purview-Lab** workspace.

### Create New Lakehouse

1. Select **+ New item**.

2. In the **New item** pane, search for or select **Lakehouse**.

3. Enter the Lakehouse name: `CustomerDataLakehouse`.

4. Select **Create**.

5. Wait for the Lakehouse to be provisioned (typically 10-30 seconds).

### Explore Lakehouse Interface

Once created, you'll see:

1. **Explorer pane** (left): Shows Tables and Files folders.
2. **Main canvas** (center): Currently empty.
3. **Properties** (right): Lakehouse details.

---

## 🔧 Step 3: Upload Sample Data Files

### Locate Sample Data

The sample data files are in the `data-templates` folder:

- `customers.csv` - Customer records with PII (SSN, names, addresses).
- `transactions.csv` - Financial transactions with credit card numbers.

### Upload Files to Lakehouse

1. In the Lakehouse Explorer, right-click on **Files**.

2. Select **Upload** → **Upload files**.

3. Navigate to the `data-templates` folder.

4. Select `customers.csv` and select **Open**.

5. Repeat for `transactions.csv`.

6. Wait for uploads to complete (progress shown in notification area).

### Verify File Upload

1. Expand the **Files** folder in Explorer.

2. You should see both CSV files listed.

3. Select a file to preview its contents.

---

## 🔧 Step 4: Create Delta Tables from CSV Files

### Load customers.csv to Table

1. Right-click on `customers.csv` in the Files section.

2. Select **Load to Tables** → **New table**.

3. Configure the table:

   | Setting | Value |
   |---------|-------|
   | **New table name** | `customers` |
   | **Use first row as headers** | ✅ Checked |

4. Select **Load**.

5. Wait for the load operation to complete.

### Load transactions.csv to Table

1. Right-click on `transactions.csv`.

2. Select **Load to Tables** → **New table**.

3. Configure the table:

   | Setting | Value |
   |---------|-------|
   | **New table name** | `transactions` |
   | **Use first row as headers** | ✅ Checked |

4. Select **Load**.

5. Wait for completion.

### Verify Table Creation

1. Expand the **Tables** section in Explorer.

2. You should see both tables:
   - `customers`
   - `transactions`

3. Select a table to preview the data.

---

## 🔧 Step 5: Explore Delta Table Features

### View Table Schema

1. Select the `customers` table.

2. In the preview pane, select **View schema**.

3. Review the automatically inferred data types:

   | Column | Expected Type |
   |--------|--------------|
   | CustomerID | string |
   | FirstName | string |
   | LastName | string |
   | Email | string |
   | SSN | string |
   | DateOfBirth | string or date |
   | CreditScore | integer |

### Understand Data Types

Delta Lake infers data types from CSV data. For this lab, all types should work correctly. In production, you might need to:

- Cast date columns explicitly.
- Validate numeric type inference.
- Handle null values appropriately.

---

## 🔧 Step 6: Query Data Using SQL Endpoint

### Access SQL Endpoint

1. In the Lakehouse view, look at the top navigation.

2. Find the dropdown that shows **Lakehouse**.

3. Select it and choose **SQL analytics endpoint**.

4. The view switches to SQL-based exploration.

### Run Sample Queries

1. Select **New SQL query**.

2. Run this query to explore customer data:

   ```sql
   SELECT 
       CustomerID,
       FirstName,
       LastName,
       Email,
       State,
       CreditScore
   FROM customers
   WHERE CreditScore > 700
   ORDER BY CreditScore DESC
   LIMIT 10;
   ```

3. Select **Run** to execute.

4. Review results in the output pane.

### Query Transactions

1. Create another query:

   ```sql
   SELECT 
       CustomerID,
       TransactionDate,
       Amount,
       MerchantName,
       CardType
   FROM transactions
   WHERE Amount > 500
   ORDER BY Amount DESC;
   ```

2. Run and review results.

---

## 🔧 Step 7: Verify Data for Classification

The uploaded data contains sensitive information that Purview will classify:

| Data Element | Example | Expected SIT |
|--------------|---------|--------------|
| **SSN** | 123-45-6789 | U.S. Social Security Number (SSN) |
| **Credit Card** | 4532-1234-5678-9012 | Credit Card Number |
| **Email** | john.smith@example.com | Email Address |
| **Phone** | (555) 123-4567 | Phone Number (U.S.) |

> **💡 Classification Note**: When Purview scans this Lakehouse in Lab 06, it will automatically detect these sensitive information types using built-in classifiers.

---

## ✅ Validation Checklist

Before proceeding to Lab 03, verify:

- [ ] Lakehouse `CustomerDataLakehouse` exists in workspace.
- [ ] Files folder contains `customers.csv` and `transactions.csv`.
- [ ] Tables folder contains `customers` and `transactions` tables.
- [ ] Data preview shows records with PII (SSN, credit cards, etc.).
- [ ] SQL endpoint is accessible and queries work.

---

## ❌ Troubleshooting

### File Upload Fails

**Symptom**: Upload hangs or shows error.

**Resolution**:

1. Check file size (max 5 GB per file via UI).
2. Try a different browser.
3. Clear browser cache and retry.
4. Use smaller file chunks if very large.

### Load to Tables Fails

**Symptom**: "Load to Tables" operation fails.

**Resolution**:

1. Verify CSV has consistent column counts.
2. Check for special characters in header row.
3. Try saving CSV with UTF-8 encoding.
4. Check Lakehouse capacity/permissions.

### Tables Not Appearing in SQL Endpoint

**Symptom**: Tables exist but not visible in SQL view.

**Resolution**:

1. Wait 1-2 minutes for sync.
2. Refresh the SQL endpoint view.
3. Verify tables are Delta format (not just files).

---

## 📚 Related Resources

- [Create a Lakehouse](https://learn.microsoft.com/fabric/data-engineering/create-lakehouse)
- [Delta Lake overview](https://learn.microsoft.com/fabric/data-engineering/lakehouse-and-delta-tables)
- [Load data into Lakehouse](https://learn.microsoft.com/fabric/data-engineering/load-data-lakehouse)

---

## ➡️ Next Steps

Proceed to:

**[Lab 03: Data Ingestion with Connectors](../03-Data-Ingestion-Connectors/)**

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Lakehouse creation steps were verified against Microsoft Learn documentation within **Visual Studio Code**.
