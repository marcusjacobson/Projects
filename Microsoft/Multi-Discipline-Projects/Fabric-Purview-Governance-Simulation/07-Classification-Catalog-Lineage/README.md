# Lab 07: Classification, Catalog, and Lineage

## 🎯 Objective

Explore auto-classifications on your Fabric data, navigate the Data Catalog, and visualize data lineage across your Fabric assets.

**Duration**: 45 minutes

---

## 📋 Prerequisites

- [ ] Lab 06 completed (Purview scan finished successfully).
- [ ] At least one Fabric asset shows classifications.
- [ ] Access to Purview Data Catalog.

---

## 🔧 Step 1: Deep Dive into Classifications

### Navigate to Classified Assets

1. Go to [purview.microsoft.com](https://purview.microsoft.com).

2. Navigate to **Data Catalog** → **Browse**.

3. Search for: `CustomerDataLakehouse`.

4. Click on the Lakehouse to open its details.

### View Table Classifications

1. Expand the Lakehouse to see child tables.

2. Click on the `customers` table.

3. Navigate to the **Schema** tab.

4. Review column classifications:

   | Column | Classification | Confidence |
   |--------|---------------|------------|
   | SSN | U.S. Social Security Number (SSN) | High |
   | Email | Email Address | High |
   | Phone | U.S. Phone Number | Medium |
   | DateOfBirth | Date of Birth | Medium |
   | CreditScore | N/A (numeric, not PII) | N/A |

### Understanding Classification Confidence

- **High**: Strong pattern match, consistent data format.
- **Medium**: Partial pattern match, some variations.
- **Low**: Weak match, may need manual review.

---

## 🔧 Step 2: Explore Classification Types

### Sensitive Information Types (SITs)

Microsoft Purview uses 200+ built-in Sensitive Information Types:

| Category | Examples |
|----------|----------|
| **Financial** | Credit Card Number, Bank Account |
| **Healthcare** | Medicare ID, Health Insurance |
| **National ID** | SSN, Passport Numbers |
| **Contact Info** | Email, Phone, Address |
| **Credentials** | Passwords, API Keys |

### View All Classifications in Catalog

1. In Data Catalog, click **Browse**.

2. Use the **Classifications** filter in the left panel.

3. Select specific classifications to see affected assets:
   - **U.S. Social Security Number**
   - **Credit Card Number**
   - **Email Address**

4. This shows which assets contain each type of sensitive data.

---

## 🔧 Step 3: Explore Data Catalog Features

### Catalog Search Capabilities

1. Use the main search bar to find assets:

   **Search Examples:**
   - `customer` - Find all customer-related assets.
   - `transactions` - Find transaction data.
   - `SSN` - Find assets with SSN classification.

2. Review search results:
   - Asset type icons (table, column, report).
   - Classification badges.
   - Source information.

### Browse by Collection

1. In Data Catalog, click **Browse**.

2. Select **By source type**.

3. Choose **Microsoft Fabric**.

4. See all Fabric assets organized hierarchically.

### Use Asset Filters

1. Apply filters to narrow results:

   | Filter | Purpose |
   |--------|---------|
   | **Source type** | Filter by Fabric, SQL, etc. |
   | **Classification** | Filter by sensitivity type |
   | **Glossary term** | Filter by business terms |
   | **Owner** | Filter by data owner |

---

## 🔧 Step 4: Asset Details and Metadata

### View Complete Asset Information

1. Open the `customers` table asset.

2. Explore each tab:

   **Overview Tab:**
   - Asset description
   - Technical details
   - Qualified name (full path)

   **Properties Tab:**
   - Created date
   - Modified date
   - Technical metadata

   **Schema Tab:**
   - Column names and types
   - Classifications per column
   - Column descriptions

   **Lineage Tab:**
   - Data flow visualization
   - Upstream/downstream assets

   **Related Tab:**
   - Related assets
   - Linked glossary terms

---

## 🔧 Step 5: Add Business Context

### Edit Asset Description

1. On the asset Overview tab, click **Edit**.

2. Add a description:

   ```text
   Customer master data table containing demographic information,
   contact details, and financial indicators. Source: Lab sample data.
   Contains PII including SSN, email, and phone numbers.
   ```

3. Click **Save**.

### Add Owners and Experts

1. In the asset details, find the **Contacts** section.

2. Click **Edit** or **Add**.

3. Add yourself as:
   - **Owner**: Primary responsible party.
   - **Expert**: Subject matter expert.

4. Save changes.

### Apply Glossary Terms

1. If glossary terms exist, go to the **Related** tab.

2. Click **Add glossary terms**.

3. Link relevant business terms:
   - "Customer Data"
   - "Personal Information"
   - "Financial Records"

> **📝 Note**: Glossary terms may need to be created separately in the Glossary section.

---

## 🔧 Step 6: Explore Data Lineage

### View Asset Lineage

1. Open the `customers_segmented` table (created in Lab 03).

2. Navigate to the **Lineage** tab.

3. You should see a visual lineage diagram showing:
   - **Upstream**: Source data (customers table).
   - **Processing**: Dataflow transformation.
   - **Downstream**: Resulting table.

### Lineage Diagram Elements

| Element | Meaning |
|---------|---------|
| **Blue boxes** | Data assets (tables, files) |
| **Arrows** | Data flow direction |
| **Process nodes** | Transformations (Dataflows, Pipelines) |
| **Dotted lines** | Virtual relationships (shortcuts) |

### Trace Data Flow

1. Click on different nodes in the lineage diagram.

2. See how data flows:

   ```text
   customers.csv → CustomerDataLakehouse/customers → 
   DF_CustomerSegmentation → customers_segmented
   ```

3. This visualizes the transformation pipeline.

---

## 🔧 Step 7: Lineage Across Fabric Assets

### View Warehouse Lineage

1. Navigate to the `AnalyticsWarehouse`.

2. Open the lineage view.

3. You should see shortcuts connecting to Lakehouse tables.

### Cross-Asset Lineage

Fabric maintains lineage across:

- **Lakehouse tables** → **Warehouse shortcuts**
- **Dataflows** → **Output tables**
- **Pipelines** → **Destination tables**
- **Tables** → **Power BI datasets**

### Lineage Limitations

> **⚠️ Note**: Some lineage connections may not appear immediately:

- Manual uploads don't show source lineage.
- Some Fabric item types have limited lineage support.
- Lineage updates may lag behind data changes.

---

## 🔧 Step 8: Export and Report on Classifications

### Generate Classification Report

1. In Data Catalog, click **Insights** (if available).

2. Or use the **Data Estate Insights** dashboard.

3. View classification statistics:
   - Total classified assets.
   - Classification distribution.
   - Unclassified assets.

### Manual Classification Review

1. Use search with classification filter.

2. Export results (if export feature is available).

3. Create a manual inventory:

   | Asset | Type | Classifications |
   |-------|------|-----------------|
   | customers | Table | SSN, Email, Phone |
   | transactions | Table | Credit Card |
   | streaming-events | Table | None |

---

## 🔧 Step 9: Classification Best Practices

### Review Classification Accuracy

1. Check if classifications match expected data.

2. Look for:
   - **False positives**: Incorrectly classified columns.
   - **False negatives**: Missed sensitive data.

### Manual Classification Adjustment

1. If a column is misclassified, click on the classification badge.

2. You can:
   - **Confirm**: Validate the auto-classification.
   - **Remove**: Delete incorrect classification.
   - **Add**: Manually add a classification.

> **💡 Production Tip**: Document classification decisions for audit purposes.

---

## ✅ Validation Checklist

Before proceeding to Lab 08, verify:

- [ ] Can view column-level classifications on tables.
- [ ] Successfully searched for assets in Data Catalog.
- [ ] Added description to at least one asset.
- [ ] Viewed lineage for a transformed table.
- [ ] Understand the difference between auto and manual classifications.
- [ ] Can filter catalog by classification type.

---

## ❌ Troubleshooting

### No Classifications Visible

**Symptom**: Assets show but no classifications appear.

**Resolution**:

1. Re-run the scan from Lab 06.
2. Verify sample data contains recognizable PII patterns.
3. Check if classification rules are enabled.
4. Wait for full scan completion.

### Lineage Not Showing

**Symptom**: Lineage tab is empty or incomplete.

**Resolution**:

1. Ensure Dataflow/Pipeline has run at least once.
2. Wait for Purview to process lineage (up to 24 hours).
3. Some manual operations don't generate lineage.
4. Re-scan after pipeline execution.

### Cannot Edit Asset Metadata

**Symptom**: Edit buttons are disabled.

**Resolution**:

1. Verify you have Data Curator role in Purview.
2. Check collection permissions.
3. Some system-generated fields are read-only.

---

## 📊 Classification Summary Table

| Your Asset | Expected Classifications | Verification |
|------------|-------------------------|--------------|
| customers table | SSN, Email, Phone, DateOfBirth | ☐ Confirmed |
| transactions table | CreditCardNumber, AccountNumber | ☐ Confirmed |
| customers_segmented | Email (subset of customers) | ☐ Confirmed |
| IoTEvents table | None (no PII in sample data) | ☐ Confirmed |

---

## 📚 Related Resources

- [Understand classifications](https://learn.microsoft.com/purview/concept-classification)
- [Data Catalog overview](https://learn.microsoft.com/purview/data-catalog-overview)
- [Data lineage in Purview](https://learn.microsoft.com/purview/concept-data-lineage)
- [Sensitive information types](https://learn.microsoft.com/purview/sensitive-information-type-entity-definitions)

---

## ➡️ Next Steps

Proceed to:

**[Lab 08: Sensitivity Labels and Governance](../08-Sensitivity-Labels-Governance/)**

> **🎯 Important**: Lab 08 focuses on applying sensitivity labels from Microsoft Information Protection to your Fabric assets.

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Classification and lineage procedures were verified against Microsoft Purview documentation within **Visual Studio Code**.
