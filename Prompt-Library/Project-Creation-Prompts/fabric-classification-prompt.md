# Fabric + Purview Governance Simulation Project Creation Prompt

This prompt provides the complete project context and approved structure for creating a Microsoft Fabric + Purview data governance simulation project. The project covers Fabric enablement, data workloads (Lakehouse, Warehouse, KQL Database), Purview integration, auto-classification, and governance workflows.

> **📋 Project Status**: Structure approved (Version 3) - Ready for implementation
> **📅 Approval Date**: December 2025
> **🎯 Focus**: UI-based step-by-step instructions validated against Microsoft Learn

---

## 🎯 Universal AI Project Creation Prompt

```markdown
I need your help creating a new project from scratch. Please follow this structured approach:

## PROJECT CONTEXT

**Skill Area / Domain Expertise Required:**
Microsoft Fabric, Microsoft Purview, Data Governance, Data Engineering, Real-Time Analytics, Power BI

**Primary Technologies:**
- Microsoft Fabric (SaaS unified analytics platform)
- Microsoft Purview (Data governance, classification, lineage)
- Power BI (Visualization and reporting)
- Azure (underlying infrastructure and identity)

**Specific Targeted Content:**
A comprehensive hands-on simulation that teaches Microsoft Fabric + Purview integration from scratch. Users will:

1. **Enable Microsoft Fabric** in their tenant and create a governed workspace
2. **Build multiple data workloads**:
   - Lakehouse (Delta Lake storage, Spark notebooks)
   - Warehouse (SQL-based analytics, T-SQL queries)
   - KQL Database (Real-time streaming analytics)
3. **Ingest sample data** using Dataflows Gen2 and Data Factory pipelines
4. **Integrate with Microsoft Purview** using On-Demand scans for immediate classification
5. **Apply auto-classification** with 200+ built-in Sensitive Information Types (SITs)
6. **Explore governance features**: Data catalog, lineage tracking, sensitivity labels
7. **Create Power BI reports** from governed data assets
8. **Understand production patterns** through supplemental timing/classification documentation

**Approved Lab Structure (11 Labs):**

| Lab | Title | Duration | Key Focus |
|-----|-------|----------|----------|
| 00 | Prerequisites & Environment Setup | 30 min | Licensing, permissions, prerequisites checklist |
| 01 | Enable Fabric & Create Workspace | 30 min | Enable Fabric in tenant, create workspace |
| 02 | Create Lakehouse & Load Data | 45 min | Lakehouse creation, upload sample CSVs |
| 03 | Data Ingestion with Connectors | 45 min | Dataflows Gen2, Data Factory pipelines |
| 04 | Create Warehouse & SQL Analytics | 45 min | Warehouse creation, SQL queries |
| 05 | Real-Time Analytics with KQL | 45 min | Eventhouse, KQL Database, sample streaming |
| 06 | Purview Integration & Scanning | 60 min | **On-Demand scans** (primary path), Purview Hub |
| 07 | Classification, Catalog & Lineage | 45 min | View classifications, browse catalog, lineage |
| 08 | Sensitivity Labels & Governance | 45 min | Apply labels, Information Protection |
| 09 | Power BI Visualization | 45 min | Create reports from governed data |
| 10 | Cleanup & Reset | 30 min | Delete workspace, validation scripts |

**Total Estimated Time**: ~7-8 hours (full day workshop or 2-3 sessions)

**Target File Types to Create:**
- **Markdown documentation** (.md) - Primary focus; UI-based step-by-step instructions
- **Sample data files** (.csv, .json) - Pre-built datasets with classifiable PII/financial data
- **Sample documents** (.docx, .pdf) - For unstructured data classification
- **PowerShell scripts** (.ps1) - Validation and cleanup scripts only (not primary deployment)
- **KQL queries** (.kql) - Sample Kusto queries for Lab 05
- **SQL scripts** (.sql) - Sample T-SQL for Warehouse queries in Lab 04
- **JSON configuration** (.json) - Sample configurations and data templates

**Instruction Approach:**
- **PRIMARY**: UI-based portal instructions (app.fabric.microsoft.com, purview.microsoft.com)
- **SECONDARY**: PowerShell/CLI for validation, cleanup, and optional automation
- **CRITICAL**: All UI instructions MUST be validated against current Microsoft Learn documentation

**Organization & Structure Requirements:**
- **Numbered lab directories** (00-10) following repository convention
- **Each lab contains**: README.md with complete instructions, scripts/ subdirectory (if applicable)
- **data-templates/** folder at project root with pre-built sample datasets
- **Comprehensive project README** with navigation, prerequisites, and quick start
- **Self-contained labs** - each lab can be completed independently after prerequisites
- **Supplemental documentation** for timing, production patterns, and advanced topics

**Approved Directory Structure:**

```text
Microsoft/Multi-Discipline-Projects/Fabric-Purview-Governance-Simulation/
├── README.md                              # Project overview and navigation
├── TIMING-AND-CLASSIFICATION-GUIDE.md     # Scan timing, scheduled vs on-demand
├── TROUBLESHOOTING.md                     # Common issues and resolutions
├── data-templates/
│   ├── customers.csv                      # 500 records with PII (names, SSN, emails)
│   ├── transactions.csv                   # 1000 financial transactions
│   ├── streaming-events.json              # Sample IoT/event data for KQL
│   ├── employee-handbook.docx             # Unstructured document sample
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

**Reference Project Strategy:**

**Primary Reference Project:**

- `Microsoft/Purview/Purview-Data-Governance-Simulation/` - **Core template** for structure, lab format, README patterns, troubleshooting sections, and validation checklists

**Secondary Reference Projects:**

- `Microsoft/Purview/Purview-Skills-Ramp-OnPrem-and-Cloud/` - Sensitivity label procedures, Information Protection patterns
- `Microsoft/Multi-Discipline-Projects/Azure-Ai-Security-Skills-Challenge/` - Multi-component project organization

**Patterns to Duplicate and Adapt:**

- Lab README structure with Prerequisites, Steps, Validation, Troubleshooting sections
- Sample data templates with classifiable PII patterns
- PowerShell validation scripts with proper preamble and error handling
- TIMING-DELAY-CHEAT-SHEET.md format for timing documentation
- Comprehensive troubleshooting sections with expandable details

**Critical Requirements:**

- **DUPLICATE and customize** - never link to other projects
- **VALIDATE all UI instructions** against current Microsoft Learn documentation
- **SELF-CONTAINED labs** - each lab complete without external dependencies
- **FROM SCRATCH approach** - assume Fabric has never been enabled

**Additional Context:**

**"From Scratch" Requirements:**

- Assume Fabric has **never been enabled** in the tenant
- Assume Purview Data Map has **no registered sources**
- Include ALL prerequisite steps (licensing, permissions, tenant settings)
- No assumptions about existing workspaces, data, or configurations

**Target Audience:**

- Data engineers learning Fabric for the first time
- Governance professionals exploring Purview integration
- IT administrators evaluating Fabric + Purview capabilities
- No specific Azure subscription tier assumptions (works with trial/dev/prod)

**Key Technical Decisions:**

| Decision | Choice | Rationale |
|----------|--------|----------|
| Scan Type | On-Demand ("Once") | Faster feedback for learning; scheduled scans in supplemental doc |
| Sample Data | Pre-built CSVs + Microsoft alternatives | Hybrid approach; primary pre-built, fallback to MS samples |
| Instruction Style | UI-based with screenshots | Portal-first approach; PowerShell for validation/cleanup only |
| Purview Scope | Broad exposure | Cover Data Map, Catalog, Classification, Labels, Lineage |
| Power BI Depth | Medium | Create reports, basic DAX, no advanced modeling |

**Timing Research Findings (from Microsoft Learn):**

| Activity | Expected Duration | Notes |
|----------|-------------------|-------|
| Admin API propagation | ~15 minutes | Required after enabling Fabric API settings |
| On-Demand scan (small workspace) | 5-30 minutes | Depends on asset count |
| Ingestion completion | 5-15 minutes | After scan finishes |
| **No 7-day wait** | N/A | Unlike SharePoint, Fabric scans are near-immediate |

**Supplemental Documentation:**

- `TIMING-AND-CLASSIFICATION-GUIDE.md` - Scheduled scan benefits, L1/L2/L3 levels, production recommendations
- `TROUBLESHOOTING.md` - Common issues, permission problems, scan failures

**Skills Coverage Matrix (Approved):**

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

**Microsoft Learn Documentation to Validate:**

| Topic | Primary URL | Purpose |
|-------|-------------|----------|
| Fabric Overview | `learn.microsoft.com/fabric/get-started/` | Labs 01-05 |
| Fabric Lakehouse | `learn.microsoft.com/fabric/data-engineering/lakehouse-overview` | Lab 02 |
| Fabric Warehouse | `learn.microsoft.com/fabric/data-warehouse/` | Lab 04 |
| Fabric Real-Time Analytics | `learn.microsoft.com/fabric/real-time-intelligence/` | Lab 05 |
| Purview + Fabric | `learn.microsoft.com/purview/register-scan-fabric-tenant` | Lab 06 |
| Purview Classification | `learn.microsoft.com/purview/concept-scans-and-ingestion` | Labs 06-07 |
| Sensitivity Labels | `learn.microsoft.com/purview/sensitivity-labels` | Lab 08 |

## COMPLIANCE REQUIREMENTS

Before creating any content, you MUST:

1. **Review Repository Style-Guides:**
   - Read and understand the Markdown Style Guide (`Repository-Management/Style-Guides/markdown-style-guide.md`)
   - Read and understand the PowerShell Style Guide (`Repository-Management/Style-Guides/powershell-style-guide.md`) if applicable
   - Read and understand the Parameters File Style Guide (`Repository-Management/Style-Guides/parameters-file-style-guide.md`) if applicable
   - Follow any other relevant style guides in the repository

2. **Review Existing Reference Projects:**
   - Use `semantic_search` or `read_file` to extract relevant patterns, scripts, and documentation structures from the projects listed above.
   - Identify reusable PowerShell modules, error handling patterns, and documentation templates.

3. **Follow Copilot Instructions:**
   - Adhere to all standards defined in `.github/copilot-instructions.md`.
   - Apply appropriate style guide compliance for each file type.
   - Use proper formatting, headers, punctuation, and structure.
   - Include AI-assisted content generation acknowledgments where required.

4. **Apply Best Practices:**
   - Use proper naming conventions for files and resources.
   - Implement consistent formatting and organization.
   - Include comprehensive documentation and comments.
   - Follow industry standards for the specified technology stack.

5. **Research and Validate Before Creating:**
   - **NEVER rely on training data** for step-by-step instructions, code examples, or technical procedures.
   - **USE DEEP REASONING AGENTS**: Always use deep reasoning models (e.g., Claude with extended thinking, GPT-o1, Gemini Deep Research) when performing research, analysis, or architectural decisions.
   - **PRIMARY SOURCE**: Always use Microsoft Learn (`learn.microsoft.com`) as the primary validation source for Microsoft technologies.
   - **SECONDARY SOURCES**: Validate against official documentation (`docs.microsoft.com`, `github.com/Microsoft`, official vendor docs).
   - **Code Validation**: Research current API versions, cmdlet syntax, SDK methods, and library versions before suggesting code.
   - **UI/Portal Instructions**: Use `fetch_webpage` or documentation search to verify current portal navigation, menu locations, and button names.
   - **Version Checking**: Confirm current versions, features, and deprecated methods before providing examples.

## REQUIRED ITERATIVE APPROVAL PROCESS

### Phase 1: Project Structure Proposal

Before creating ANY files or content:

1. **Engage deep reasoning** for architectural analysis and technology selection.
2. **Review existing reference projects** to identify reusable patterns and content.
3. **Suggest a descriptive project name** that follows repository naming conventions.
4. **Propose a complete directory structure** showing all folders and key files.
5. **Explain the purpose** of each major directory and file type.
6. **Describe the organization rationale** and how it meets the requirements.
7. **Define the Skills Coverage Matrix** showing which specific skills/technologies are covered in each lab/section.
8. **Identify content to duplicate** from reference projects and how it will be adapted.
9. **Wait for my approval or feedback** before proceeding.

### Phase 2: Iterative Refinement

If I request changes:

1. **Revise the proposed structure** based on my feedback.
2. **Explain the changes made** and why they address my concerns.
3. **Present the updated proposal** for review.
4. **Repeat this process** until I explicitly approve the structure.

### Phase 3: Implementation

Only after I provide explicit approval:

1. **Create the directory structure** as approved.
2. **Generate all files** following the repository style guides.
3. **Ensure compliance** with all formatting and documentation standards.
4. **Provide a summary** of what was created and next steps.

## OUTPUT FORMAT REQUIREMENTS

### For Project Structure Proposal:

```text

## Proposed Project Structure

**Project Name:** [descriptive-project-name]

**Directory Tree:**

```text
project-root/
├── README.md
├── directory1/
│   ├── subdirectory/
│   │   ├── file1.ext
│   │   └── file2.ext
│   └── file3.ext
├── directory2/
│   ├── file4.ext
│   └── file5.ext
└── directory3/
    └── file6.ext
```

**Directory Purpose Explanations:**

- **[Directory Name]**: [Explanation of purpose and contents]
- **[Directory Name]**: [Explanation of purpose and contents]
...

**Skills Coverage Matrix:**

| Skill / Technology | Lab / Section | Depth (Basic/Intermediate/Advanced) |
|-------------------|---------------|-------------------------------------|
| [Skill 1]         | [Lab 01]      | [Depth]                             |
| [Skill 2]         | [Lab 02]      | [Depth]                             |
...

**Organization Rationale:**
[Explain why this structure was chosen and how it supports the learning objectives.]

**Key File Types to be Created:**

- [File Type]: [Count] - [Description]
...

**Compliance Considerations:**

- [List specific style guides and standards to be followed]

**Research Validation Plan:**

- [List specific documentation sources and APIs to be researched]

**Content Reuse from Reference Projects:**

- [List specific patterns or content to be adapted from existing repo projects]

**Awaiting Approval:** Please review this structure and provide feedback or approval to proceed.

```

### For Iterative Refinement:

```text

## Revised Project Structure (Version [N])

**Changes Made Based on Feedback:**

1. [Change 1]
2. [Change 2]
...

**Updated Directory Tree:**
...

**Updated Rationale:**
...

**Awaiting Approval:** Please review these revisions and provide feedback or approval to proceed.
```

## RESEARCH AND VALIDATION REQUIREMENTS

Before suggesting any code, step-by-step instructions, or technical procedures, you MUST validate against official sources:

### Primary Research Sources (in order of priority)

1. **Microsoft Learn** (learn.microsoft.com) - Primary source for all Microsoft technologies
2. **Official Microsoft Documentation** (docs.microsoft.com, github.com/Microsoft)
3. **Cloud Provider Official Docs** (Azure, AWS, GCP official documentation)
4. **Official Product Documentation** (Vendor-specific docs for third-party tools)
5. **Reputable Technical Resources** (Only after validating with official sources)

### What Requires Research Validation

**ALWAYS research before providing:**

- **Step-by-step instructions** for portal navigation, admin centers, or product UIs
- **Code examples** including API calls, cmdlet syntax, SDK methods
- **Configuration procedures** for Azure resources, services, or integrations
- **Installation workflows** and setup procedures
- **API endpoints** and authentication requirements
- **Resource properties** and configuration options
- **Current versions** of software, APIs, or services
- **Deprecated features** or replaced functionality

**Research Process:**

1. **Engage deep reasoning** for complex analysis, architectural decisions, or multi-faceted research
2. **Identify what needs validation** (UI paths, code syntax, API versions, etc.)
3. **Use appropriate research tools** (fetch_webpage for documentation, semantic search for internal patterns)
4. **Verify current state** (check dates, versions, and "as of" indicators)
5. **Cross-reference when uncertain** (use multiple official sources)
6. **Document research** (note version numbers, dates, and source URLs in comments)

## CRITICAL RULES

1. **Never skip the approval phase** - Always wait for explicit approval before creating files.
2. **Never assume project structure** - Always propose and iterate based on feedback.
3. **Always read style guides first** - Ensure compliance from the start, not as an afterthought.
4. **Always review reference projects** - Use semantic_search and read_file to extract reusable patterns.
5. **Always duplicate, never link** - Extract and embed content directly; never create references or links to other projects.
6. **Always validate against official documentation** - Never rely on training data for technical instructions, code examples, or current procedures.
7. **Always use deep reasoning agents** - Engage extended thinking/deep reasoning models for research, analysis, architectural decisions, and technology validation.
8. **Always research before suggesting** - Use Microsoft Learn for Microsoft technologies, official vendor docs for other technologies.
9. **Always provide detailed explanations** - Help me understand your design decisions.
10. **Always be ready to iterate** - Expect multiple rounds of refinement.
11. **Never create partial implementations** - Wait for full approval of the complete structure.

## STYLE GUIDE COMPLIANCE CHECKLIST

Before implementing, verify:

- [ ] Reviewed applicable style guides from `Repository-Management/Style-Guides/` directory.
- [ ] Reviewed existing reference projects for reusable patterns.
- [ ] Identified PowerShell scripts, documentation templates, and configuration files to duplicate.
- [ ] Planned content extraction strategy - no links or references, only embedded duplicated content.
- [ ] Understood repository `.github/copilot-instructions.md` requirements.
- [ ] Confirmed file naming conventions for target technology.
- [ ] Identified required documentation standards.
- [ ] Planned for AI-assisted content generation acknowledgments.
- [ ] Understood header, formatting, and punctuation requirements.
- [ ] Identified any technology-specific patterns to follow.
- [ ] **Researched current documentation** from Microsoft Learn or official sources for all technical content.
- [ ] **Validated API versions, cmdlet syntax, and library versions** against current official documentation.
- [ ] **Verified UI navigation paths and portal instructions** using current official resources (not training data).
- [ ] **Engaged deep reasoning agents** for architectural decisions, technology selection, and complex analysis.

```

---

## 🤖 AI-Assisted Content Generation

This Fabric + Purview Governance Simulation project creation prompt was developed with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. The project structure, lab organization, timing research, and technical decisions were generated through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

**Research Conducted:**
- Microsoft Learn documentation for Fabric scanning and Purview integration
- Timing behavior analysis for On-Demand vs Scheduled scans
- Classification architecture review (L1/L2/L3 scan levels)
- Reference project analysis from Purview-Data-Governance-Simulation

*AI tools were used to validate current Microsoft documentation, research scan timing expectations, and ensure comprehensive coverage of Fabric + Purview integration patterns while maintaining technical accuracy.*

---

## ✅ Implementation Status

**Structure Approved**: Version 3 (December 2025)

**Ready for Implementation**:
- [ ] Create directory structure at `Microsoft/Multi-Discipline-Projects/Fabric-Purview-Governance-Simulation/`
- [ ] Generate project README.md with navigation and prerequisites
- [ ] Create TIMING-AND-CLASSIFICATION-GUIDE.md supplemental documentation
- [ ] Create TROUBLESHOOTING.md with common issues
- [ ] Build sample data templates (customers.csv, transactions.csv, etc.)
- [ ] Generate Lab 00-10 README files with UI-validated instructions
- [ ] Create validation and cleanup PowerShell scripts

**Next Step**: Run this prompt with a fresh conversation to begin implementation phase.
