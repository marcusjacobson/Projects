# Fabric + Purview Governance Simulation

## 🎯 Project Overview

This comprehensive hands-on simulation teaches **Microsoft Fabric + Purview integration from scratch**. Through **eleven progressive labs**, you'll enable Microsoft Fabric, build multiple data workloads (Lakehouse, Warehouse, KQL Database), integrate with Microsoft Purview for auto-classification, and implement enterprise data governance workflows.

**Target Audience**: Data engineers, governance professionals, IT administrators, and anyone learning Microsoft Fabric and Purview integration from the ground up.

**Approach**: UI-based step-by-step instructions validated against Microsoft Learn documentation. All labs can be completed using the Azure portal, Fabric portal, and Purview portal - PowerShell is used only for validation and cleanup operations.

**What Makes This Different:**

- **From Scratch Setup**: Assumes Fabric has never been enabled - complete onboarding guidance included.
- **UI-First Approach**: All primary instructions are portal-based with clear navigation paths.
- **Multiple Data Workloads**: Covers Lakehouse, Warehouse, and KQL Database - not just one pattern.
- **On-Demand Scanning**: Focus on immediate scan results for faster learning feedback.
- **End-to-End Governance**: From raw data ingestion to classified, labeled, governed Power BI reports.
- **Production Patterns**: Supplemental documentation covers scheduled scans and enterprise recommendations.

---

## ⏱️ Time and Resource Considerations

**Before starting this project, understand these key factors:**

| Consideration | Impact | Planning |
|---------------|--------|----------|
| **⏱️ Lab Completion** | ~7-8 hours total | Plan for full day workshop or 2-3 sessions |
| **⏱️ Fabric Enablement** | ~15 minutes | Admin API settings require propagation time |
| **⏱️ On-Demand Scan** | 5-30 minutes | Depends on workspace asset count |
| **⏱️ Ingestion Processing** | 5-15 minutes | After scan completion |
| **💰 Fabric Capacity** | Pay-as-you-go or trial | F2+ capacity required for full features |
| **🔐 Licensing** | Fabric + Purview | Microsoft 365 E5 or equivalent recommended |

> **💡 Recommended Approach**:
>
> - **Session 1 (3 hours)**: Labs 00-03 - Prerequisites, Fabric enablement, Lakehouse, Data ingestion
> - **Session 2 (2.5 hours)**: Labs 04-06 - Warehouse, KQL, Purview integration
> - **Session 3 (2.5 hours)**: Labs 07-10 - Classification, Labels, Power BI, Cleanup

**Key Timing Note**: Unlike SharePoint Content Explorer (which requires up to 7 days for classification indexing), **Fabric Purview scans complete in minutes to hours** with On-Demand scanning. This project is designed for faster feedback loops.

---

## 📚 Lab Progression

### [Lab 00: Prerequisites and Environment Setup](./00-Prerequisites-and-Setup/)

**Duration**: 30 minutes  
**Objective**: Validate licensing, permissions, and environment readiness

**What You'll Learn**:

- Verify Microsoft 365 and Azure subscription requirements.
- Validate Fabric licensing and Purview access.
- Confirm required admin permissions (Fabric Admin, Purview roles).
- Understand the Fabric capacity model and trial options.
- Set up browser profiles for optimal lab experience.

**Key Deliverables**:

- Licensing validation completed.
- Admin permissions confirmed.
- Fabric capacity available (trial or paid).
- Environment readiness checklist completed.

---

### [Lab 01: Enable Fabric and Create Workspace](./01-Enable-Fabric-Create-Workspace/)

**Duration**: 30 minutes  
**Objective**: Enable Microsoft Fabric in your tenant and create a governed workspace

**What You'll Learn**:

- Enable Microsoft Fabric at the tenant level (Admin Portal).
- Configure Fabric Admin API settings for Purview integration.
- Create a Fabric workspace with appropriate capacity.
- Understand workspace roles and permissions.
- Configure workspace settings for governance.

**Key Deliverables**:

- Microsoft Fabric enabled in tenant.
- Admin API settings configured (15-minute propagation wait).
- Fabric workspace created and configured.
- Workspace ready for data workload creation.

**Prerequisites**: Lab 00 completed

---

### [Lab 02: Create Lakehouse and Load Data](./02-Create-Lakehouse-Load-Data/)

**Duration**: 45 minutes  
**Objective**: Create a Lakehouse and load sample data containing classifiable information

**What You'll Learn**:

- Create a Lakehouse in your Fabric workspace.
- Understand Lakehouse architecture (Files vs Tables, Delta Lake).
- Upload sample CSV files containing PII data.
- Create Delta tables from uploaded files.
- Query data using the SQL analytics endpoint.

**Key Deliverables**:

- Lakehouse created in workspace.
- Sample data files uploaded (customers.csv, transactions.csv).
- Delta tables created from CSV files.
- SQL endpoint available for querying.

**Prerequisites**: Lab 01 completed

---

### [Lab 03: Data Ingestion with Connectors](./03-Data-Ingestion-Connectors/)

**Duration**: 45 minutes  
**Objective**: Use Dataflows Gen2 and Data Factory pipelines for data ingestion

**What You'll Learn**:

- Create a Dataflow Gen2 for data transformation.
- Build a Data Factory pipeline for orchestration.
- Connect to external data sources (sample data).
- Apply data transformations using Power Query.
- Schedule and monitor data pipeline runs.

**Key Deliverables**:

- Dataflow Gen2 created with transformations.
- Data Factory pipeline configured.
- Data successfully ingested into Lakehouse.
- Pipeline monitoring dashboard understood.

**Prerequisites**: Lab 02 completed

---

### [Lab 04: Create Warehouse and SQL Analytics](./04-Create-Warehouse-SQL-Analytics/)

**Duration**: 45 minutes  
**Objective**: Create a Data Warehouse and perform SQL-based analytics

**What You'll Learn**:

- Create a Fabric Data Warehouse.
- Understand Warehouse vs Lakehouse differences.
- Load data into Warehouse tables.
- Write T-SQL queries for analytics.
- Create views and stored procedures.

**Key Deliverables**:

- Data Warehouse created in workspace.
- Tables created and populated with data.
- SQL queries executed successfully.
- SQL endpoint ready for Power BI connection.

**Prerequisites**: Lab 02 completed (data available in Lakehouse)

---

### [Lab 05: Real-Time Analytics with KQL](./05-Real-Time-Analytics-KQL/)

**Duration**: 45 minutes  
**Objective**: Create a KQL Database for real-time streaming analytics

**What You'll Learn**:

- Create an Eventhouse and KQL Database.
- Understand real-time analytics architecture.
- Ingest sample streaming data (JSON events).
- Write KQL queries for data exploration.
- Create KQL querysets for reusable analytics.

**Key Deliverables**:

- Eventhouse created in workspace.
- KQL Database with sample data ingested.
- KQL queries written and saved.
- Real-time dashboard concepts understood.

**Prerequisites**: Lab 01 completed

---

### [Lab 06: Purview Integration and Scanning](./06-Purview-Integration-Scanning/)

**Duration**: 60 minutes  
**Objective**: Register Fabric tenant in Purview and run On-Demand scans

**What You'll Learn**:

- Access Purview Data Map and register Fabric as a data source.
- Configure authentication for Fabric scanning (Managed Identity).
- Run On-Demand ("Once") scans for immediate classification.
- Monitor scan progress and understand scan states.
- Access Purview Hub within Fabric portal.

**Key Deliverables**:

- Fabric tenant registered in Purview Data Map.
- On-Demand scan completed successfully.
- Scan results visible in Purview.
- Purview Hub accessible from Fabric workspace.

**Prerequisites**: Labs 02-05 completed (data assets exist to scan)

> **⏱️ Timing Note**: On-Demand scans typically complete in **5-30 minutes** for small workspaces. This is significantly faster than SharePoint classification which requires up to 7 days. See [TIMING-AND-CLASSIFICATION-GUIDE.md](./TIMING-AND-CLASSIFICATION-GUIDE.md) for detailed timing information.

---

### [Lab 07: Classification, Catalog, and Lineage](./07-Classification-Catalog-Lineage/)

**Duration**: 45 minutes  
**Objective**: Explore classification results, browse the data catalog, and view lineage

**What You'll Learn**:

- Review auto-classification results (200+ built-in SITs).
- Browse assets in the Purview Unified Catalog.
- Search and filter data assets by classification.
- View end-to-end data lineage for Fabric assets.
- Understand lineage from source to Power BI.

**Key Deliverables**:

- Classification results reviewed and validated.
- Data catalog navigation mastered.
- Asset search and filtering understood.
- Lineage visualization explored.

**Prerequisites**: Lab 06 completed (scan finished with results)

---

### [Lab 08: Sensitivity Labels and Governance](./08-Sensitivity-Labels-Governance/)

**Duration**: 45 minutes  
**Objective**: Apply sensitivity labels and implement governance controls

**What You'll Learn**:

- Understand sensitivity label architecture.
- Apply sensitivity labels to Fabric assets.
- Configure label policies for automatic labeling.
- Implement access controls based on labels.
- Review governance compliance in Purview.

**Key Deliverables**:

- Sensitivity labels applied to Fabric assets.
- Label policies understood.
- Governance controls implemented.
- Compliance posture reviewed.

**Prerequisites**: Lab 07 completed

---

### [Lab 09: Power BI Visualization](./09-Power-BI-Visualization/)

**Duration**: 45 minutes  
**Objective**: Create Power BI reports from governed Fabric data

**What You'll Learn**:

- Connect Power BI to Lakehouse (DirectLake mode).
- Connect Power BI to Warehouse (SQL endpoint).
- Create basic DAX measures.
- Build interactive visualizations.
- Publish reports to workspace with governance inheritance.

**Key Deliverables**:

- Power BI report connected to Fabric data.
- DirectLake mode configured for optimal performance.
- Visualizations created from governed data.
- Report published with inherited sensitivity labels.

**Prerequisites**: Labs 02-04 completed (data sources available)

---

### [Lab 10: Cleanup and Reset](./10-Cleanup-Reset/)

**Duration**: 30 minutes  
**Objective**: Remove simulation resources and restore environment

**What You'll Learn**:

- Delete Fabric workspace and all contained items.
- Remove Purview scan configuration.
- Clean up any remaining resources.
- Validate cleanup completion.
- Prepare environment for fresh start.

**Key Deliverables**:

- Fabric workspace deleted.
- Purview registration removed.
- Environment restored to clean state.
- Cleanup validation completed.

**Prerequisites**: Any labs completed (can run cleanup at any stage)

---

## 📊 Skills Coverage Matrix

| Skill / Technology | Lab | Depth | Key Learning Outcomes |
|-------------------|-----|-------|----------------------|
| Microsoft Fabric Enablement | 01 | Basic | Enable Fabric, understand licensing, create workspace |
| Lakehouse Architecture | 02 | Intermediate | Delta Lake, Spark, file vs table storage |
| Dataflows Gen2 | 03 | Intermediate | Data transformation, M queries, connectors |
| Data Factory Pipelines | 03 | Basic | Orchestration, copy activities, scheduling |
| Data Warehouse (SQL) | 04 | Intermediate | T-SQL, dimensional modeling, SQL endpoint |
| KQL Database | 05 | Intermediate | Eventhouse, streaming ingestion, KQL syntax |
| Real-Time Analytics | 05 | Basic | Event-driven architecture, time-series data |
| Purview Data Map | 06 | Intermediate | Source registration, on-demand scanning |
| Purview Hub (Fabric) | 06 | Basic | Native Fabric-Purview integration |
| Auto-Classification | 07 | Intermediate | 200+ SITs, classification results, accuracy |
| Data Catalog | 07 | Basic | Asset discovery, metadata, search |
| Data Lineage | 07 | Basic | End-to-end lineage visualization |
| Sensitivity Labels | 08 | Intermediate | Information Protection, label policies |
| Data Governance | 08 | Intermediate | Access controls, compliance, auditing |
| Power BI Reporting | 09 | Intermediate | DirectLake, DAX basics, governed reports |
| Power BI + Purview | 09 | Basic | Governed data sources, certified datasets |

---

## 📁 Project Structure

```text
Fabric-Purview-Governance-Simulation/
├── README.md                              # This file - project overview
├── TIMING-AND-CLASSIFICATION-GUIDE.md     # Scan timing and scheduling guidance
├── TROUBLESHOOTING.md                     # Common issues and resolutions
├── data-templates/                        # Sample data files
│   ├── customers.csv                      # 500 records with PII
│   ├── transactions.csv                   # 1000 financial transactions
│   ├── streaming-events.json              # Sample IoT/event data
│   ├── employee-handbook.docx             # Unstructured document
│   └── financial-report.pdf               # PDF with financial data
├── 00-Prerequisites-and-Setup/
│   ├── README.md
│   └── scripts/
│       └── Test-Prerequisites.ps1
├── 01-Enable-Fabric-Create-Workspace/
│   └── README.md
├── 02-Create-Lakehouse-Load-Data/
│   ├── README.md
│   └── scripts/
├── 03-Data-Ingestion-Connectors/
│   └── README.md
├── 04-Create-Warehouse-SQL-Analytics/
│   ├── README.md
│   └── sql/
│       └── sample-queries.sql
├── 05-Real-Time-Analytics-KQL/
│   ├── README.md
│   └── kql/
│       └── sample-queries.kql
├── 06-Purview-Integration-Scanning/
│   └── README.md
├── 07-Classification-Catalog-Lineage/
│   └── README.md
├── 08-Sensitivity-Labels-Governance/
│   └── README.md
├── 09-Power-BI-Visualization/
│   └── README.md
└── 10-Cleanup-Reset/
    ├── README.md
    └── scripts/
        └── Remove-FabricResources.ps1
```

---

## 🔗 Related Resources

### Microsoft Learn Documentation

| Topic | URL |
|-------|-----|
| Microsoft Fabric Overview | [learn.microsoft.com/fabric/get-started/](https://learn.microsoft.com/fabric/get-started/) |
| Fabric Lakehouse | [learn.microsoft.com/fabric/data-engineering/lakehouse-overview](https://learn.microsoft.com/fabric/data-engineering/lakehouse-overview) |
| Fabric Data Warehouse | [learn.microsoft.com/fabric/data-warehouse/](https://learn.microsoft.com/fabric/data-warehouse/) |
| Fabric Real-Time Intelligence | [learn.microsoft.com/fabric/real-time-intelligence/](https://learn.microsoft.com/fabric/real-time-intelligence/) |
| Purview + Fabric Scanning | [learn.microsoft.com/purview/register-scan-fabric-tenant](https://learn.microsoft.com/purview/register-scan-fabric-tenant) |
| Purview Classification | [learn.microsoft.com/purview/concept-scans-and-ingestion](https://learn.microsoft.com/purview/concept-scans-and-ingestion) |
| Sensitivity Labels | [learn.microsoft.com/purview/sensitivity-labels](https://learn.microsoft.com/purview/sensitivity-labels) |

### Related Projects in This Repository

| Project | Description |
|---------|-------------|
| [Purview-Data-Governance-Simulation](../../Purview/Purview-Data-Governance-Simulation/) | SharePoint-focused Purview classification simulation |
| [Purview-Skills-Ramp-OnPrem-and-Cloud](../../Purview/Purview-Skills-Ramp-OnPrem-and-Cloud/) | Hybrid information protection labs |

---

## 🤖 AI-Assisted Content Generation

This comprehensive Fabric + Purview Governance Simulation project was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. The project structure, lab content, sample data templates, and documentation were generated through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

**Research and Validation:**

- Microsoft Learn documentation for Fabric and Purview integration.
- Timing behavior analysis for On-Demand vs Scheduled scans.
- Classification architecture review (L1/L2/L3 scan levels).
- Reference project patterns from Purview-Data-Governance-Simulation.

*AI tools were used to validate current Microsoft documentation, research scan timing expectations, and ensure comprehensive coverage of Fabric + Purview integration patterns while maintaining technical accuracy.*
