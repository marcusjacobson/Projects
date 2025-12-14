# Fabric + Purview Governance Simulation

## 🎯 Project Overview

This comprehensive hands-on simulation teaches **Microsoft Fabric + Purview integration from scratch**. Through **ten progressive labs**, you'll enable Microsoft Fabric, build multiple data workloads (Lakehouse, Warehouse, KQL Database), integrate with Microsoft Purview for data discovery, and implement data governance workflows.

**Target Audience**: Data engineers, governance professionals, IT administrators, and anyone learning Microsoft Fabric and Purview integration from the ground up.

**Approach**: UI-based step-by-step instructions validated against Microsoft Learn documentation. All labs can be completed using the Azure portal, Fabric portal, and Purview portal - PowerShell is used only for validation and cleanup operations.

**What Makes This Different:**

- **Low/No Cost Fabric Options**: Use the 60-day free trial OR pay-as-you-go F2 capacity (~$0.36/hr) that can be paused when not in use.
- **Zero Cost Purview Path**: Labs use Purview Free version with "live view" discovery - no enterprise subscription required.
- **From Scratch Setup**: Assumes Fabric has never been enabled - complete onboarding guidance included.
- **UI-First Approach**: All primary instructions are portal-based with clear navigation paths.
- **Multiple Data Workloads**: Covers Lakehouse, Warehouse, and KQL Database - not just one pattern.
- **Live View Discovery**: Fabric assets automatically appear in Purview - no scanning configuration needed.
- **End-to-End Governance**: From raw data ingestion to annotated, labeled, governed Power BI reports.

> **💰 Cost Note**: This simulation works with **Fabric Trial (free for 60 days)** or **F2 capacity (~$0.36/hr with pause capability)** combined with **Purview Free version**. Pause your Fabric capacity between lab sessions to minimize costs. For advanced scanning with automatic classification, see [ADVANCED-PURVIEW-ENTERPRISE-SCANNING.md](./ADVANCED-PURVIEW-ENTERPRISE-SCANNING.md).

---

## ⏱️ Time and Resource Considerations

**Before starting this project, understand these key factors:**

| Consideration | Impact | Planning |
|---------------|--------|----------|
| **⏱️ Lab Completion** | ~7-8 hours total | Plan for full day workshop or 2-3 sessions |
| **⏱️ Fabric Enablement** | ~5 minutes | Enable Fabric tenant settings and create workspace |
| **⏱️ Live View Sync** | 5-15 minutes | Fabric assets appear in Purview automatically |
| **💰 Fabric Cost** | $0 or ~$3-5 total | 60-day trial (free) OR F2 capacity with pause |
| **💰 Purview Cost** | $0 with free version | Enterprise scanning costs ~$360+/month extra |
| **🔐 Licensing** | Fabric + M365 | Developer subscription or M365 E3/E5 |

> **💡 Fabric Capacity Options**:
>
> - **Option 1 - Free Trial**: 60-day Fabric trial with full capabilities (recommended for first-time users)
> - **Option 2 - F2 Capacity**: ~$0.36/hour, **pause when not in use** to minimize costs (~$3-5 for all labs)
> - **Cost Tip**: If using F2, pause your capacity after each session - you only pay for active hours

> **💡 Recommended Approach**:
>
> - **Session 1 (3 hours)**: Labs 00-03 - Prerequisites, Fabric enablement, Lakehouse, Data ingestion
> - **Session 2 (2 hours)**: Labs 04-05 - Warehouse, Real-Time Analytics (KQL)
> - **Session 3 (3 hours)**: Labs 06-10 - DLP Classification, Data Map & Lineage, Power BI, Final Validation, Cleanup

**Key Timing Note**: Unlike SharePoint Content Explorer (which requires up to 7 days for classification indexing), **Fabric assets appear in Purview within minutes** via automatic Live View discovery. This project is designed for faster feedback loops.

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
- Create a Fabric workspace with appropriate capacity.
- Understand workspace roles and permissions.
- Configure workspace settings for governance.

**Key Deliverables**:

- Microsoft Fabric enabled in tenant.
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

### [Lab 06: DLP Data Classification](./06-DLP-Data-Classification/)

**Duration**: 35 minutes  
**Objective**: Create DLP policies that automatically detect sensitive data in Fabric items

**What You'll Learn**:

- Create Microsoft Purview DLP policies targeting Fabric and Power BI.
- Configure Sensitive Information Type (SIT) detection for SSN, credit cards, financial data.
- Apply DLP policies to Lakehouse, Warehouse, AND KQL Database.
- View policy tips and alerts when sensitive data is detected.
- Configure endorsements for data quality governance.

**Key Deliverables**:

- DLP policy created in Microsoft Purview portal.
- SIT detection configured for PII data patterns.
- Policy tips visible on flagged Fabric items.
- Admin alerts configured for compliance monitoring.
- Endorsements applied for governance visibility.

**Prerequisites**: Labs 01-05 completed, M365 E5 license (or E3 + Compliance add-on)

> **🔒 Licensing Note**: DLP for Fabric requires M365 E5. This lab provides hands-on experience with automatic data classification that scans actual data content in Lakehouse tables, Warehouse tables, and KQL databases.

---

### [Lab 07: Data Map and Lineage](./07-Data-Map-Lineage/)

**Duration**: 25 minutes  
**Objective**: Scan Fabric assets with Data Map and visualize data lineage

**What You'll Learn**:

- Configure and run a Data Map scan on Fabric data sources.
- View discovered assets with schema-level metadata.
- Visualize data lineage showing flow from Lakehouse to Warehouse.
- Use lineage for impact analysis and data tracing.
- Understand upstream and downstream data dependencies.

**Key Deliverables**:

- Data Map scan completed for Fabric workspace.
- Asset metadata visible in Data Catalog.
- Lineage visualization showing data flow relationships.
- Impact analysis skills for schema change assessment.

**Prerequisites**: Labs 01-06 completed, Fabric registered in Data Map (Lab 00)

---

### [Lab 08: Power BI Visualization](./08-Power-BI-Visualization/)

**Duration**: 45 minutes  
**Objective**: Create Power BI reports from governed Fabric data

**What You'll Learn**:

- Connect Power BI to Lakehouse (DirectLake mode).
- Connect Power BI to Warehouse (SQL endpoint).
- Create basic DAX measures.
- Build interactive visualizations.
- Publish reports to workspace with governance inheritance.
- View updated lineage showing reports in Data Map.

**Key Deliverables**:

- Power BI report connected to Fabric data.
- DirectLake mode configured for optimal performance.
- Visualizations created from governed data.
- Report published with inherited sensitivity labels.
- Lineage extended to show report dependencies.

**Prerequisites**: Labs 01-07 completed (data sources and lineage available)

---

### [Lab 09: Final Validation](./09-Final-Validation/)

**Duration**: 30-45 minutes  
**Objective**: Validate all governance capabilities configured throughout the lab series

**What You'll Learn**:

- Verify DLP policy results (policy tips, alerts, Activity Explorer).
- Validate end-to-end data lineage visualization.
- Confirm automatic classifications on sensitive data.
- Apply and verify endorsements on Fabric items.
- Review governance scorecard across all lab components.

**Key Deliverables**:

- DLP policy tips visible on Fabric items.
- Lineage showing complete data flow.
- Classifications applied to sensitive columns.
- Endorsements signaling data quality.
- Governance summary documenting all capabilities.

**Prerequisites**: Labs 01-08 completed, DLP policy deployed (1+ hours)

---

### [Lab 10: Cleanup and Reset](./10-Cleanup-Reset/)

**Duration**: 15 minutes  
**Objective**: Remove simulation resources and restore environment

**What You'll Learn**:

- Delete Fabric workspace and all contained items.
- Remove Purview manual classifications and annotations.
- Clean up DLP policies in Purview portal.
- Validate cleanup completion.
- Prepare environment for fresh start.

**Key Deliverables**:

- Fabric workspace deleted.
- Purview annotations removed.
- DLP policies removed.
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
| DLP for Fabric | 06 | Intermediate | DLP policies, SIT detection, policy tips |
| Purview Data Map | 07 | Intermediate | Source registration, scanning, asset discovery |
| Data Lineage | 07 | Intermediate | End-to-end lineage visualization, impact analysis |
| Data Catalog | 07 | Basic | Asset discovery, schema metadata, search |
| Power BI Reporting | 08 | Intermediate | DirectLake, DAX basics, governed reports |
| Sensitivity Labels | 08 | Basic | Information Protection, label inheritance |
| Power BI + Purview | 08 | Basic | Governed data sources, lineage to reports |

---

## 📁 Project Structure

```text
Fabric-Purview-Governance-Simulation/
├── README.md                              # This file - project overview
├── TIMING-AND-CLASSIFICATION-GUIDE.md     # Live View timing expectations
├── ADVANCED-PURVIEW-ENTERPRISE-SCANNING.md # Enterprise scanning guide (optional)
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
├── 06-DLP-Data-Classification/
│   └── README.md
├── 07-Data-Map-Lineage/
│   └── README.md
├── 08-Power-BI-Visualization/
│   └── README.md
├── 09-Final-Validation/
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
- Live View discovery timing and behavior analysis.
- Free vs Enterprise feature comparison and documentation.
- Reference project patterns from Purview-Data-Governance-Simulation.

*AI tools were used to validate current Microsoft documentation, research scan timing expectations, and ensure comprehensive coverage of Fabric + Purview integration patterns while maintaining technical accuracy.*
