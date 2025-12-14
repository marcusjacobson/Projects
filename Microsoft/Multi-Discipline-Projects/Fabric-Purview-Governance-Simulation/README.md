# Fabric + Purview Governance Simulation

## 🎯 Project Overview

This hands-on simulation teaches **DLP and Information Protection for Microsoft Fabric data**. Through **ten progressive labs**, you'll build a Fabric data estate with sensitive data (SSN, Credit Card numbers), configure DLP policies to detect that data, discover assets in the Purview Unified Catalog, and create a governed Power BI report chain.

**Target Audience**: Data engineers, governance professionals, compliance officers, and anyone learning to protect sensitive data in Microsoft Fabric.

**Approach**: UI-based step-by-step instructions validated against current Microsoft portals. All labs can be completed using the Fabric portal and Purview portal—PowerShell is used only for data generation and cleanup.

**What You'll Accomplish**:

- **Build a Fabric Data Foundation**: Lakehouse with customer PII data (SSN) and transaction data (Credit Card numbers).
- **Configure DLP Policies**: Detect sensitive data patterns when users access Fabric reports.
- **Discover Assets**: Run Data Map scans to make Fabric assets searchable in Unified Catalog.
- **Create Governed Reports**: Power BI reports that connect to DLP-protected data sources.
- **Validate Governance**: Confirm DLP detection, asset discovery, and report governance chain.

> **💰 Cost Note**: This simulation works with **Fabric Trial (free for 60 days)** or **F2 capacity (~$0.36/hr with pause capability)**. DLP scanning incurs pay-per-scan costs with M365 E5 licensing. For enterprise capabilities beyond this project, see [ENTERPRISE-GOVERNANCE-CAPABILITIES.md](./ENTERPRISE-GOVERNANCE-CAPABILITIES.md).

---

## ⏱️ Time and Resource Considerations

| Consideration | Impact | Planning |
|---------------|--------|----------|
| **⏱️ Total Duration** | ~5-6 hours (hands-on) | Plan for full day or 2 sessions |
| **⏱️ DLP Propagation** | Up to 24 hours | Create DLP policy in Lab 06, validate in Lab 09 next day |
| **⏱️ Data Map Scan** | 5-15 minutes | Assets appear in Unified Catalog after scan |
| **💰 Fabric Cost** | $0 or ~$3-5 total | 60-day trial (free) OR F2 capacity with pause |
| **💰 DLP Cost** | Pay-per-scan | Included with M365 E5 licensing |
| **🔐 Licensing** | M365 E5 + Fabric | Required for DLP policy creation |

> **⚠️ DLP Timing Note**: DLP policies for Fabric use **real-time scanning**—they detect sensitive data when users access reports, not by proactively scanning data at rest. While policy sync completes in minutes, **full detection capability can take up to 24 hours** to propagate across your tenant. For best results, complete Labs 00-06 in one session, then return the next day for Labs 07-09.

> **💡 Recommended Approach**:
>
> - **Session 1 (4 hours)**: Labs 00-06 — Prerequisites, Fabric setup, data foundation, DLP policy creation
> - **Session 2 (1.5 hours, next day)**: Labs 07-09 — Data Map scan, Power BI report, validation
> - **Cleanup**: Lab 10 — When ready to remove resources

---

## 📚 Lab Progression

### [Lab 00: Prerequisites and Environment Setup](./00-Prerequisites-and-Setup/)

**Duration**: 30 minutes  
**Objective**: Validate licensing, configure Fabric Admin API access for Purview scanning

**What You'll Accomplish**:

- Verify Microsoft 365 E5 and Fabric licensing.
- Configure Fabric Admin API settings for Purview integration.
- Grant Purview MSI access to your Fabric workspace.
- Validate environment readiness for DLP and Data Map features.

**Key Deliverables**:

- Licensing confirmed (M365 E5, Fabric capacity).
- Admin API settings enabled for Purview.
- Workspace Viewer role granted to Purview MSI.

---

### [Lab 01: Enable Fabric and Create Workspace](./01-Enable-Fabric-Create-Workspace/)

**Duration**: 15-20 minutes  
**Objective**: Enable Microsoft Fabric and create a governed workspace for the simulation

**What You'll Accomplish**:

- Create a Fabric workspace with appropriate capacity.
- Configure workspace settings.
- Prepare workspace for Lakehouse creation.

**Key Deliverables**:

- `Fabric-Purview-Lab` workspace created.
- Workspace assigned to Fabric capacity (trial or F2).

**Prerequisites**: Lab 00 completed

---

### [Lab 02: Create Lakehouse and Load Customer Data](./02-Create-Lakehouse-Load-Data/)

**Duration**: 30 minutes  
**Objective**: Create a Lakehouse and load sample data containing classifiable sensitive information

**What You'll Accomplish**:

- Create a Lakehouse in your workspace.
- Run a notebook to generate customer data with SSN values.
- Verify Delta tables are created in the Lakehouse.

**Key Deliverables**:

- `CustomerDataLakehouse` created.
- `customers` table with SSN column (DLP-detectable).
- SQL endpoint available for querying.

**Prerequisites**: Lab 01 completed

---

### [Lab 03: Data Ingestion with Connectors](./03-Data-Ingestion-Connectors/)

**Duration**: 45 minutes  
**Objective**: Use Dataflows Gen2 and Data Factory pipelines to ingest and transform data

**What You'll Accomplish**:

- Create a Dataflow Gen2 to filter and enrich customer data.
- Build a Data Factory pipeline with data copy activities.
- Ingest transaction data containing Credit Card numbers (sensitive data).
- Monitor pipeline execution and refresh status.

**Key Deliverables**:

- `DF_CustomerSegmentation` dataflow created.
- `PL_TransactionLoader` pipeline created.
- `transactions` table with CreditCardNumber column (DLP-detectable).

**Prerequisites**: Lab 02 completed

---

### [Lab 04: Create Warehouse and SQL Analytics](./04-Create-Warehouse-SQL-Analytics/)

**Duration**: 30 minutes  
**Objective**: Create a Warehouse and use cross-database queries to analyze Lakehouse data with T-SQL

**What You'll Accomplish**:

- Create a Data Warehouse in your workspace.
- Configure cross-database queries to access Lakehouse tables.
- Understand how Warehouse integrates with Lakehouse data.

**Key Deliverables**:

- `AnalyticsWarehouse` created.
- Cross-database queries accessing Lakehouse tables.

**Prerequisites**: Lab 02 completed

---

### [Lab 05: Real-Time Intelligence with KQL](./05-Real-Time-Analytics-KQL/)

**Duration**: 45 minutes  
**Objective**: Create an Eventhouse and KQL Database to ingest and analyze streaming data

**What You'll Accomplish**:

- Create an Eventhouse and KQL Database.
- Ingest streaming event data using Kusto Query Language (KQL).
- Run real-time analytics queries on streaming data.
- Monitor ingestion and query performance.

**Key Deliverables**:

- `IoTEventhouse` and KQL Database created.
- Streaming events ingested and queryable.
- Real-time analytics capabilities demonstrated.

**Prerequisites**: Lab 02 completed

---

### [Lab 06: DLP Policy for Sensitive Data Detection](./06-DLP-Data-Classification/)

**Duration**: 35 minutes  
**Objective**: Create a DLP policy that detects SSN and Credit Card patterns in Fabric data

**What You'll Accomplish**:

- Create a Microsoft Purview DLP policy targeting Power BI.
- Configure detection for U.S. Social Security Number and Credit Card patterns.
- Deploy policy in simulation mode for testing.
- Understand how DLP real-time scanning works for Fabric.

**Key Deliverables**:

- `Fabric PII Detection - Lab` DLP policy created.
- Policy sync completed.
- Real-time scanning enabled for Power BI location.

**Prerequisites**: Labs 01-05 completed, M365 E5 license

> **💡 Timing Tip**: Create this policy before Labs 07-08 to allow propagation time.

---

### [Lab 07: Data Map and Asset Discovery](./07-Data-Map-Asset-Discovery/)

**Duration**: 15 minutes  
**Objective**: Run a Data Map scan to discover Fabric assets in Unified Catalog

**What You'll Accomplish**:

- Verify Fabric tenant registration in Data Map.
- Configure and run a scan on your workspace.
- Browse discovered assets in Unified Catalog.
- View table schema metadata.

**Key Deliverables**:

- Data Map scan completed.
- Lakehouse tables discoverable in Unified Catalog.
- Schema metadata (columns, types) visible.

**Prerequisites**: Labs 01-05 completed, Lab 00 Admin API settings configured

---

### [Lab 08: Power BI Report from Governed Data](./08-Power-BI-Visualization/)

**Duration**: 20 minutes  
**Objective**: Create a Power BI report that uses DLP-protected Lakehouse data

**What You'll Accomplish**:

- Create a semantic model from the Lakehouse.
- Build a Power BI report with visualizations.
- Save the report to your workspace.
- Understand the governance chain (Report → Semantic Model → Lakehouse).

**Key Deliverables**:

- `Customer Analytics Report` created.
- Report uses data from `customers` and `transactions` tables.
- Governance chain complete from source to visualization.

**Prerequisites**: Labs 01-07 completed

---

### [Lab 09: Final Validation](./09-Final-Validation/)

**Duration**: 20-30 minutes (plus DLP propagation wait time)  
**Objective**: Validate DLP detection, asset discovery, and report governance

**What You'll Accomplish**:

- Check DLP policy simulation results.
- Verify assets are discoverable in Unified Catalog.
- Confirm report governance chain is complete.
- Understand how DLP, Data Map, and reports work together for information protection.

**Key Deliverables**:

- DLP simulation results reviewed.
- Assets confirmed in Unified Catalog.
- Governance architecture documented.

**Prerequisites**: Labs 01-08 completed, DLP policy deployed (1+ hours ideal)

---

### [Lab 10: Cleanup and Reset](./10-Cleanup-Reset/)

**Duration**: 15 minutes  
**Objective**: Remove simulation resources

**What You'll Accomplish**:

- Delete Fabric workspace and all items.
- Remove DLP policy from Purview.
- Restore environment to clean state.

**Key Deliverables**:

- Workspace deleted.
- DLP policy removed.
- Environment ready for fresh start.

**Prerequisites**: Any labs completed

---

## 📊 Skills Coverage Matrix

### Professional Skills You'll Gain

Completing this project demonstrates proficiency in the following industry-recognized Microsoft Fabric and Purview governance skills:

#### **Core Technical Competencies**

**DLP and Information Protection for Fabric:**

- DLP policy design targeting Power BI and Fabric workloads.
- Sensitive Information Type (SIT) detection (SSN, Credit Card patterns).
- Real-time DLP scanning architecture for Fabric data assets.
- DLP policy lifecycle (simulation mode → enforcement → monitoring).
- Activity Explorer analysis for DLP policy matches.
- Alert investigation and incident management workflows.
- Information protection policy scoping for Power BI locations.

**Data Governance and Asset Discovery:**

- Purview Data Map configuration for Fabric tenant scanning.
- Live View synchronization between Fabric and Purview.
- Unified Catalog asset discovery and schema metadata.
- Fabric Admin API settings for Purview integration.
- Managed identity (MSI) role assignments for Purview access.
- Governance chain traceability (Report → Semantic Model → Lakehouse).

**Fabric Data Foundation (Governance Context):**

- Lakehouse architecture with Delta tables containing sensitive data patterns.
- SQL analytics endpoint for governed data access.
- Semantic model creation with DLP-protected data sources.
- Power BI report governance and data lineage.

---

### Covered Capabilities by Category

#### ✅ DLP for Microsoft Fabric (100% Core Features)

| Capability | Coverage Level | Lab(s) |
|------------|----------------|--------|
| **DLP Policy for Power BI** | ✅ EXTENSIVE | Lab 06, Lab 09 |
| **Sensitive Information Type (SIT) Detection** | ✅ COMPREHENSIVE | Lab 06 |
| **DLP Simulation Mode** | ✅ DETAILED | Lab 06, Lab 09 |
| **DLP Policy Enforcement** | ✅ DETAILED | Lab 09 |
| **Activity Explorer (DLP Matches)** | ✅ COMPREHENSIVE | Lab 09 |
| **DLP Alert Investigation** | ✅ DETAILED | Lab 09 |
| **Real-time Scanning Architecture** | ✅ DETAILED | Lab 06 |
| **Policy Sync and Propagation** | ✅ DETAILED | Lab 06, Lab 09 |

#### ✅ Purview Data Map for Fabric (100% Core Features)

| Capability | Coverage Level | Lab(s) |
|------------|----------------|--------|
| **Fabric Tenant Registration** | ✅ COMPREHENSIVE | Lab 00, Lab 07 |
| **Data Map Scan Configuration** | ✅ DETAILED | Lab 07 |
| **Live View Synchronization** | ✅ DETAILED | Lab 07 |
| **Unified Catalog Discovery** | ✅ COMPREHENSIVE | Lab 07 |
| **Schema Metadata Extraction** | ✅ DETAILED | Lab 07 |
| **Fabric Admin API Settings** | ✅ DETAILED | Lab 00 |
| **Purview MSI Role Assignment** | ✅ DETAILED | Lab 00 |

#### ✅ Governance Chain and Lineage (90% Core Features)

| Capability | Coverage Level | Lab(s) |
|------------|----------------|--------|
| **Report → Semantic Model → Lakehouse Chain** | ✅ COMPREHENSIVE | Lab 08, Lab 09 |
| **Semantic Model Governance** | ✅ DETAILED | Lab 08 |
| **DLP Coverage for Report Chain** | ✅ DETAILED | Lab 09 |
| **Asset Discovery Lineage** | ✅ DETAILED | Lab 07 |

#### ✅ Fabric Data Foundation (Governance Context Only)

| Capability | Coverage Level | Lab(s) |
|------------|----------------|--------|
| **Lakehouse with Sensitive Data** | ✅ COMPREHENSIVE | Lab 02 |
| **SQL Analytics Endpoint** | ✅ DETAILED | Lab 02, Lab 04 |
| **Delta Table Architecture** | ✅ DETAILED | Lab 02 |
| **Dataflows Gen2 (Data Movement)** | ✅ DETAILED | Lab 03 |
| **Data Factory Pipelines** | ✅ DETAILED | Lab 03 |

---

### What This Project Does NOT Cover

The following capabilities require **additional licensing**, **different Purview portals**, or are outside the scope of Fabric/Purview governance:

#### ❌ Advanced Purview Information Protection (Beyond Fabric)

| Capability | Why Not Covered |
|------------|-----------------|
| **Information Protection Scanner (On-Premises)** | Requires on-premises infrastructure; covered in [Purview-Skills-Ramp-OnPrem-and-Cloud](../../Purview/Purview-Skills-Ramp-OnPrem-and-Cloud/) |
| **Sensitivity Labels with Encryption** | Visual markings and encryption beyond scope; project focuses on DLP detection |
| **Custom SITs (Regex-based)** | Uses built-in SITs; custom patterns covered in other projects |
| **Trainable Classifiers (ML)** | Machine learning classification beyond scope |
| **Exact Data Match (EDM) SITs** | Requires database hashing infrastructure |

#### ❌ Purview Data Governance (Classic Portal)

| Capability | Why Not Covered |
|------------|-----------------|
| **Glossary Terms and Business Domains** | Classic Data Governance portal; project uses Unified Catalog |
| **Data Quality Rules** | Requires Purview Data Quality (separate capability) |
| **Data Lineage (Classic)** | Uses Live View lineage instead |
| **Collections and Access Policies** | Classic governance features beyond scope |

#### ❌ Advanced Fabric Analytics (Non-Governance)

| Capability | Why Not Covered |
|------------|-----------------|
| **Advanced Spark Processing** | Project uses basic notebook for DLP trigger only |
| **Eventhouse Advanced Features** | Real-Time Intelligence beyond basic demo |
| **Warehouse Performance Tuning** | Analytics optimization beyond governance focus |
| **Direct Lake Mode** | Advanced semantic model architecture beyond scope |

#### ❌ Compliance and Risk Management

| Capability | Why Not Covered |
|------------|-----------------|
| **Insider Risk Management** | Separate Purview capability requiring different setup |
| **Communication Compliance** | Not applicable to Fabric workloads |
| **eDiscovery** | Document search/legal hold beyond Fabric governance |
| **Retention Labels for Fabric** | Not currently supported for Fabric workloads |

---

### LinkedIn Skills Keywords

For maximum visibility on LinkedIn and applicant tracking systems (ATS), this project covers:

`Microsoft Fabric` • `Microsoft Purview` • `Data Loss Prevention (DLP)` • `Information Protection` • `Data Governance` • `Power BI Governance` • `Sensitive Information Types (SIT)` • `Data Classification` • `Activity Explorer` • `Unified Catalog` • `Data Map` • `Asset Discovery` • `Lakehouse` • `Delta Tables` • `Semantic Models` • `Data Lineage` • `Compliance Management` • `M365 E5 Compliance` • `Real-time Scanning` • `DLP Policy Design` • `Governance Chain` • `Schema Metadata`

---

### Lab Skills Mapping

| Lab | Primary Skills |
|-----|----------------|
| **Lab 00** | Fabric Admin API, Purview MSI, prerequisite validation |
| **Lab 01** | Workspace governance, capacity assignment |
| **Lab 02** | Lakehouse architecture, sensitive data patterns |
| **Lab 03** | Data ingestion, connector configuration |
| **Lab 04** | Cross-database queries, SQL analytics |
| **Lab 05** | Real-Time Intelligence, KQL basics |
| **Lab 06** | **DLP policy design, SIT detection, simulation mode** |
| **Lab 07** | **Data Map scanning, Unified Catalog, Live View** |
| **Lab 08** | **Semantic model governance, report chain** |
| **Lab 09** | **DLP validation, Activity Explorer, alert investigation** |
| **Lab 10** | Cleanup procedures, policy removal |

---

## 📁 Project Structure

```text
Fabric-Purview-Governance-Simulation/
├── README.md                              # This file - project overview
├── TIMING-AND-CLASSIFICATION-GUIDE.md     # Timing expectations for DLP and scanning
├── ENTERPRISE-GOVERNANCE-CAPABILITIES.md  # Advanced capabilities guide
├── data-templates/                        # Sample data files for ingestion
│   ├── customers.csv
│   ├── transactions.csv
│   └── streaming-events.json
├── 00-Prerequisites-and-Setup/
│   ├── README.md
│   └── scripts/
├── 01-Enable-Fabric-Create-Workspace/
│   └── README.md
├── 02-Create-Lakehouse-Load-Data/
│   └── README.md
├── 03-Data-Ingestion-Connectors/
│   └── README.md
├── 04-Create-Warehouse-SQL-Analytics/
│   └── README.md
├── 05-Real-Time-Analytics-KQL/
│   └── README.md
├── 06-DLP-Data-Classification/
│   └── README.md
├── 07-Data-Map-Asset-Discovery/
│   └── README.md
├── 08-Power-BI-Visualization/
│   └── README.md
├── 09-Final-Validation/
│   └── README.md
└── 10-Cleanup-Reset/
    └── README.md
```

---

## 🔗 Related Resources

### Microsoft Documentation

| Topic | URL |
|-------|-----|
| DLP for Power BI | [learn.microsoft.com/power-bi/enterprise/service-security-dlp-policies-for-power-bi-overview](https://learn.microsoft.com/power-bi/enterprise/service-security-dlp-policies-for-power-bi-overview) |
| Purview Data Map | [learn.microsoft.com/purview/concept-data-map](https://learn.microsoft.com/purview/concept-data-map) |
| Fabric Lakehouse | [learn.microsoft.com/fabric/data-engineering/lakehouse-overview](https://learn.microsoft.com/fabric/data-engineering/lakehouse-overview) |
| Sensitivity Labels for Fabric | [learn.microsoft.com/fabric/governance/information-protection](https://learn.microsoft.com/fabric/governance/information-protection) |

### Related Projects

| Project | Description |
|---------|-------------|
| [Purview-Data-Governance-Simulation](../../Purview/Purview-Data-Governance-Simulation/) | SharePoint-focused Purview classification |

---

## 🤖 AI-Assisted Content Generation

This Fabric + Purview Governance Simulation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Lab content was validated against live Microsoft Fabric and Purview portals within **Visual Studio Code**.

*AI tools were used to ensure accurate, current documentation for DLP and information protection capabilities in Microsoft Fabric.*
