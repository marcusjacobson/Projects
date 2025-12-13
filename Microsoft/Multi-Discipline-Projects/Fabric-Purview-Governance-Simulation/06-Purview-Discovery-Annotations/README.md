# Lab 06: Purview Discovery and Annotations

## 🎯 Objective

Explore how Microsoft Purview automatically discovers your Fabric assets, add business context through manual classifications and glossary terms, and explore data lineage across your Fabric workloads.

**Duration**: 60 minutes

---

## 🏗️ What You'll Build

| Item | Description |
|------|-------------|
| **Discovered Assets** | All Fabric items automatically indexed in Purview catalog |
| **Manual Classifications** | PII, Financial, and Custom classifications on sensitive columns |
| **Glossary Terms** | Business definitions linked to technical assets |
| **Data Lineage Map** | Visual representation of data flow across Fabric items |

### Real-World Context

Data governance is **no longer optional**—regulations like GDPR, CCPA, and HIPAA require organizations to:

- **Know what data they have** (discovery and cataloging).
- **Understand where sensitive data lives** (classification).
- **Document business meaning** (glossary and context).
- **Track data movement** (lineage).

Purview's **Live View** provides automatic discovery without complex scanning infrastructure:

- **Immediate visibility** — Fabric assets appear within minutes.
- **Zero configuration** — no agents, connectors, or scan schedules.
- **Free tier included** — no additional cost for basic governance.

The classifications and glossary terms you create here mirror what **Data Stewards** do daily in enterprise data governance programs.

---

## 📋 Prerequisites

- [ ] Labs 01-05 completed (Lakehouse, Warehouse, KQL Database with data).
- [ ] Microsoft Purview account access (free version is sufficient).
- [ ] Fabric Contributor permissions on your workspace.
- [ ] Data Curator role or higher in Purview (for editing assets).

---

## 💡 Understanding Live View and Manual Classification

This lab uses Purview's **free features**, which are included with Microsoft Fabric:

| Feature | Free Version | Enterprise (Paid) |
|---------|--------------|-------------------|
| **Cost** | $0 included with Fabric | ~$360+/month |
| **Asset Discovery** | ✅ Automatic "live view" | ✅ Automatic + deep scanning |
| **Manual Classification** | ✅ Up to 1,000 assets | ✅ Unlimited |
| **Auto-Classification** | ❌ Not available | ✅ 200+ built-in SITs |
| **Glossary Terms** | ✅ Create and link | ✅ Advanced workflows |
| **Data Lineage** | ✅ Fabric-native | ✅ Cross-source |

> **💡 Key Insight**: Live view automatically indexes Fabric metadata - no manual scanning configuration needed!

> **📖 Reference**: For enterprise scanning with automatic classification, see [ADVANCED-PURVIEW-ENTERPRISE-SCANNING.md](../ADVANCED-PURVIEW-ENTERPRISE-SCANNING.md).

---

## ⏱️ Timing Expectations

| Phase | Expected Duration |
|-------|-------------------|
| **Initial Sync** | 5-15 minutes after workspace creation |
| **Asset Updates** | Near real-time (minutes) |
| **Manual Classifications** | Immediate after saving |

> **💡 Key Insight**: Unlike SharePoint (7-day classification delay), Fabric assets appear in Purview almost immediately!

---

## 🔧 Step 1: Access Microsoft Purview

### Navigate to Purview Portal

- Open a new browser tab.
- Go to [purview.microsoft.com](https://purview.microsoft.com).
- Sign in with your organizational account.

You'll land on the unified Purview portal home page.

### Explore the Main Navigation

In the left navigation, note the main sections:

- **Data Catalog** - Browse and search data assets.
- **Data Map** - View data sources and lineage (limited in free version).
- **Information Protection** - Sensitivity labels and policies.
- **Risk and Compliance** - Governance reporting.

---

## 🔧 Step 2: View Fabric Assets in Data Catalog

### Navigate to Data Catalog

- In the left navigation, select **Data Catalog**.
- Select **Browse** to explore available assets.

### Search for Your Fabric Assets

- In the search bar at the top, type your workspace name: `Fabric-Purview-Lab`.
- Press Enter or select the search icon.

You should see your Fabric assets listed:

| Expected Asset | Type |
|---------------|------|
| `CustomerDataLakehouse` | Lakehouse |
| `AnalyticsWarehouse` | Warehouse |
| `IoTEventhouse` | Eventhouse/KQL Database |
| Various tables | Tables within each |

> **💡 Note**: If assets don't appear immediately, wait 5-15 minutes for initial sync to complete.

### View Asset Details

- Select `CustomerDataLakehouse` to open its details page.
- Review the information displayed:
  - **Overview**: Basic metadata and description.
  - **Properties**: Technical properties and settings.
  - **Schema**: Table and column information.
  - **Contacts**: Asset owners and stewards.

---

## 🔧 Step 3: Access Purview Hub in Fabric

### Navigate from Fabric Portal

- Return to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
- Navigate to your `Fabric-Purview-Lab` workspace.
- In the left navigation, look for **Purview hub**.

### Explore Purview Hub

- Select **Purview hub**.
- This shows Purview integration status for your workspace.

Review the hub sections:

| Section | Purpose |
|---------|---------|
| **Data estate insights** | Overview of discovered assets |
| **Sensitivity labels** | Label status for workspace items |
| **Endorsements** | Certified and promoted items |

> **📝 Note**: The Purview hub in Fabric provides a workspace-centric view of governance data without leaving Fabric.

---

## 🔧 Step 4: Navigate Between Portals

### Open Asset in Fabric from Purview

- In Purview Data Catalog, select one of your Fabric assets.
- Look for an **Open in Fabric** or external link option.
- Select to navigate directly to the asset in Fabric portal.

### Open Asset in Purview from Fabric

- In Fabric portal, right-click on a Lakehouse or Warehouse item.
- Look for **View in Purview** or similar option.
- Select to navigate directly to the asset in Purview.

### Practice the Navigation Flow

Try this workflow:

1. Start in **Fabric** → View your Lakehouse.
2. Navigate to **Purview** → View the same asset's metadata.
3. Return to **Fabric** → Continue working with the data.

This seamless navigation is essential for governance workflows.

---

## 🔧 Step 5: Add Manual Classifications

### Navigate to Your Table Asset

- In Purview Data Catalog, search for: `CustomerDataLakehouse`.
- Expand the Lakehouse and select the `customers` table.

### Open the Schema Tab

- Navigate to the **Schema** tab.
- Review the column list and data types.

You'll add classifications manually based on your knowledge of the data:

| Column | Suggested Classification | Reason |
|--------|-------------------------|--------|
| `SSN` | Government ID | Contains Social Security Numbers |
| `Email` | Contact Information | Personal email addresses |
| `Phone` | Contact Information | Personal phone numbers |
| `DateOfBirth` | Personal Information | Birth date is PII |
| `CustomerID` | No classification | System identifier, not sensitive |

### Add Classification to a Column

- Select the `SSN` column row (or the edit icon if available).
- Look for **Add classification** or a classification dropdown.
- Select an appropriate classification:
  - If available: **Government Identification Numbers > SSN**
  - Alternative: **Personal Information > Government ID**
- Save the classification.

Repeat for other PII columns (Email, Phone, DateOfBirth).

> **💡 Note**: Classification options depend on your Purview configuration. Use the closest matching classification available.

---

## 🔧 Step 6: Create Glossary Terms

### Navigate to Glossary

- In the left navigation, select **Data Catalog**.
- Select **Glossary**.
- This is where business terms are defined and managed.

### Create a New Term

- Select **+ New term** or **Add term**.
- Fill in the term details:

| Field | Value |
|-------|-------|
| **Name** | `Customer Data` |
| **Definition** | Data directly related to customer identity, demographics, and contact information |
| **Status** | Approved |
| **Experts** | Add yourself |

- Select **Create** or **Save**.

### Create Additional Terms

Create 2-3 more terms for your lab:

#### Financial Information Term

| Field | Value |
|-------|-------|
| **Name** | `Financial Information` |
| **Definition** | Data related to monetary transactions, credit, or payment information |

#### Event Data Term

| Field | Value |
|-------|-------|
| **Name** | `Event Data` |
| **Definition** | Time-series or streaming data from IoT devices, sensors, or applications |

---

## 🔧 Step 7: Link Glossary Terms and Add Metadata

### Link Terms to Assets

- Navigate back to **Data Catalog** → **Browse**.
- Open the `customers` table asset.
- Look for the **Related** or **Glossary terms** tab/section.
- Select **Add glossary term** or **Link term**.
- Search for: `Customer Data` and select it.

Repeat to link:

- `transactions` table → `Financial Information` term.
- `IoTEvents` table → `Event Data` term.

### Add Asset Descriptions

- Open the `customers` table asset.
- Select **Edit** on the Overview tab.
- Add a description:

```text
Customer master data table containing demographic information,
contact details, and financial indicators. Source: Lab sample data.
Contains PII including SSN, email, and phone numbers.
```

- Select **Save**.

### Add Owners and Experts

- In the asset details, find the **Contacts** section.
- Select **Edit** or **Add**.
- Add yourself as **Owner** and **Expert**.
- Save changes.

---

## 🔧 Step 8: Search and Filter the Catalog

### Use Search Effectively

In the Data Catalog search bar, try different approaches:

**Search by asset name:**

- Type: `CustomerDataLakehouse`
- Results show the exact asset.

**Search by keyword:**

- Type: `customer`
- Results show all assets containing "customer" in name or description.

**Search by glossary term:**

- Type: `Customer Data`
- Results show assets linked to that term.

### Apply Filters

Use the filter panel on the left to narrow results:

| Filter | Use Case |
|--------|----------|
| **Source type** | Show only Microsoft Fabric assets |
| **Asset type** | Show only Tables, Lakehouses, etc. |
| **Classification** | Show assets with specific classifications |
| **Glossary term** | Show assets linked to a term |
| **Owner** | Show assets you own |

---

## 🔧 Step 9: Explore Data Lineage

### View Asset Lineage

- Open an asset that was created through transformation (e.g., `customers_segmented` if created in Lab 03).
- Navigate to the **Lineage** tab.

You should see a visual lineage diagram showing:

- **Upstream**: Source data tables.
- **Processing**: Dataflow or Pipeline nodes.
- **Downstream**: Output tables and reports.

### Lineage Diagram Elements

| Element | Meaning |
|---------|---------|
| **Rectangular boxes** | Data assets (tables, files) |
| **Arrows** | Data flow direction |
| **Process nodes** | Transformations (Dataflows, Pipelines) |
| **Dotted lines** | Virtual relationships (shortcuts) |

### View Cross-Asset Lineage

- Navigate to the `AnalyticsWarehouse` asset.
- Open the **Lineage** tab.
- You should see connections to Lakehouse tables (via shortcuts).

Fabric maintains lineage across different workload types:

| From | To | Lineage Visible |
|------|-----|-----------------|
| Lakehouse tables | Warehouse shortcuts | ✅ Yes |
| Dataflows | Output tables | ✅ Yes |
| Pipelines | Destination tables | ✅ Yes |
| Tables | Power BI datasets | ✅ Yes (after Lab 08) |

> **⚠️ Note**: Manual file uploads may not show source lineage. Lineage updates can lag behind data changes.

---

## ✅ Validation Checklist

Before proceeding to Lab 07, verify:

### Discovery and Navigation

- [ ] Successfully signed in to Purview portal.
- [ ] Located Fabric assets in Data Catalog search.
- [ ] Viewed asset details for at least one Lakehouse/Warehouse.
- [ ] Accessed Purview Hub from within Fabric portal.
- [ ] Navigated between Fabric and Purview portals.

### Annotations and Classifications

- [ ] Added manual classification to at least one column.
- [ ] Created at least one glossary term.
- [ ] Linked a glossary term to an asset.
- [ ] Added description to at least one asset.
- [ ] Added yourself as owner/expert on an asset.

### Lineage

- [ ] Viewed lineage for at least one asset.
- [ ] Explored cross-asset lineage (Lakehouse → Warehouse).

---

## ❌ Troubleshooting

### Assets Not Appearing in Purview

**Symptom**: Cannot find Fabric assets in Data Catalog.

**Resolution**:

- Wait 5-15 minutes after workspace creation for initial sync.
- Verify Fabric-Purview integration is enabled in Fabric Admin portal.
- Ensure your workspace is on an active Fabric capacity.
- Refresh the Data Catalog page.

### Cannot Add Classifications

**Symptom**: Classification options are not available or disabled.

**Resolution**:

- Verify you have Data Curator role in Purview.
- Check collection permissions for your workspace.
- Some classification types require specific configuration.
- Try refreshing the page and re-opening the asset.

### Glossary Terms Not Linking

**Symptom**: Cannot link term to asset.

**Resolution**:

- Verify the term status is "Approved" (not Draft).
- Check that you have permission to edit the asset.
- Ensure you're in the correct collection context.
- Try creating a new term if existing terms won't link.

### Lineage Not Showing

**Symptom**: Lineage tab is empty or incomplete.

**Resolution**:

- Ensure transformation (Dataflow/Pipeline) has run at least once.
- Wait for Purview to process lineage (up to 24 hours for complex flows).
- Manual uploads don't generate source lineage.
- Re-check after pipeline execution.

### Purview Hub Not Visible in Fabric

**Symptom**: Cannot find Purview hub option in Fabric.

**Resolution**:

- Verify Purview integration is enabled by your Fabric administrator.
- Check that you have Contributor or higher role on the workspace.
- Try navigating to a specific item and look for governance options.

---

## 📊 Lab Timeline Summary

```text
┌─────────────────────────────────────────────────────────────┐
│                    Lab 06 Timeline                          │
├─────────────────────────────────────────────────────────────┤
│  0:00-0:10  │  Navigate Purview portal, explore layout      │
│  0:10-0:20  │  Search and view Fabric assets in catalog     │
│  0:20-0:25  │  Access Purview Hub, practice navigation      │
│  0:25-0:35  │  Add manual classifications to columns        │
│  0:35-0:45  │  Create glossary terms, link to assets        │
│  0:45-0:55  │  Explore data lineage across workloads        │
│  0:55-1:00  │  Complete validation checklist                │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Annotation Summary Table

Track your progress with this table:

| Asset | Classification | Glossary Term | Description | Owner |
|-------|---------------|---------------|-------------|-------|
| customers table | ☐ Government ID (SSN) | ☐ Customer Data | ☐ Added | ☐ You |
| customers.Email | ☐ Contact Info | - | - | - |
| transactions | ☐ Financial | ☐ Financial Information | ☐ Added | ☐ You |
| IoTEvents | ☐ None needed | ☐ Event Data | ☐ Added | ☐ You |

---

## 📚 Related Resources

- [Purview Hub in Fabric](https://learn.microsoft.com/fabric/governance/use-microsoft-purview-hub)
- [Purview Data Catalog overview](https://learn.microsoft.com/purview/data-catalog-overview)
- [Manual classification in Purview](https://learn.microsoft.com/purview/apply-classifications)
- [Glossary terms](https://learn.microsoft.com/purview/concept-business-glossary)
- [Data lineage in Purview](https://learn.microsoft.com/purview/concept-data-lineage)

---

## ➡️ Next Steps

Proceed to:

**[Lab 07: Sensitivity Labels and Governance](../07-Sensitivity-Labels-Governance/)**

> **🎯 Important**: Lab 07 focuses on applying Microsoft 365 sensitivity labels to your Fabric assets.

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Discovery, classification, and lineage procedures were verified against Microsoft Purview documentation within **Visual Studio Code**.
