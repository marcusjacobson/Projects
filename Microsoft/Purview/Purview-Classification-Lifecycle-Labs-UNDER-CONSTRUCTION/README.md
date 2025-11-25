# Purview Classification & Lifecycle Labs

## 🎯 Project Overview

This comprehensive lab environment demonstrates Microsoft Purview's data classification, information protection, and lifecycle management capabilities from the ground up. Through **six progressive hands-on labs** with **optimized timing**, you'll learn to implement enterprise-grade data governance using Sensitive Information Types (SITs), retention labels, auto-apply policies, and PowerShell automation.

**Target Audience**: IT professionals, compliance administrators, and security engineers learning Microsoft Purview Information Protection and Data Lifecycle Management.

**Approach**: "From scratch" implementation with optimized lab sequence that front-loads time-sensitive operations (SharePoint indexing, retention label activation) into Lab 0, eliminating active waiting periods in subsequent labs. Complete the entire curriculum in 2-3 focused days OR deploy to production over 1-2 weeks with fully activated retention labels.

---

## 📚 Lab Progression

### [Lab 0: Prerequisites & Time-Sensitive Setup](./00-Prerequisites-Setup/)

**Duration**: 30-45 minutes active work | Background processing continues during subsequent labs  
**Objective**: Establish all prerequisites and initiate time-sensitive background operations

**What You'll Learn**:

- Validate Microsoft 365 E5 licensing and admin permissions.
- Create SharePoint test site and upload sample documents (triggers 15-30 min background indexing).
- Create placeholder custom SITs (triggers 5-15 min global replication).
- Initialize retention labels (triggers up to 7-day activation for production deployment).
- Understand timing optimization strategy that eliminates active waiting in later labs.

**Key Deliverables**:

- SharePoint Communication Site with 20 sample documents uploaded.
- 3 placeholder custom SITs created (enhanced in Lab 1).
- 3 initial retention labels configured (used in Lab 4).
- All background processing initiated (runs while you complete Labs 1-3).

**Critical Success Factor**: ✅ **Complete Lab 0 FIRST** before any other lab. This front-loads all time-sensitive operations and enables seamless progression through the remaining curriculum.

---

### [Lab 1: Custom Sensitive Information Types (Regex & Keywords)](./01-CustomSITs/)

**Duration**: 60-75 minutes | NO wait periods  
**Objective**: Create and enhance custom SITs using advanced regex patterns and keyword dictionaries

**What You'll Learn**:

- Enhance placeholder SITs from Lab 0 with advanced regex patterns.
- Build keyword dictionaries for context-aware detection.
- Configure multi-level confidence scoring (High/Medium/Low 85%/75%/65%).
- Test custom SITs against local sample files (no SharePoint dependency).
- Understand SIT accuracy tuning and validation techniques.

**Key Deliverables**:

- 3+ custom regex-based SITs with varying confidence levels.
- Keyword dictionary SIT for specialized organizational terminology.
- SIT validation testing against sample data files.
- Enhanced SITs ready for Lab 3 SharePoint validation.

**Prerequisites**: Lab 0 completed (uses placeholder SITs as foundation for enhancements)

---

### [Lab 2: Exact Data Match (EDM) for Structured Data](./02-CustomSITs/)

**Duration**: 75-90 minutes | 30-60 min one-time EDM processing  
**Objective**: Implement Exact Data Match (EDM) for database-driven classification

**What You'll Learn**:

- Create EDM schemas for structured employee databases.
- Hash sensitive data tables using EdmUploadAgent.exe.
- Upload hashed data to Microsoft Purview secure storage.
- Configure EDM-based custom SITs for exact matching.
- Understand EDM vs regex accuracy differences (99% vs 85-95%).

**Key Deliverables**:

- EDM schema created with 3-5 searchable fields (EmployeeID, Email, SSN).
- Employee database (100 records) hashed and uploaded.
- EDM-based custom SIT configured for exact match classification.
- Validation showing zero false positives with EDM approach.

**Prerequisites**: Lab 0 completed, Lab 1 recommended for foundational SIT knowledge

---

### [Lab 3: On-Demand Classification & Content Explorer Validation](./03-OnDemandClassification/)

**Duration**: 30-45 minutes | NO active waiting (indexing from Lab 0 complete)  
**Objective**: Validate custom SITs against SharePoint content using On-Demand Classification

**What You'll Learn**:

- Trigger On-Demand Classification scans on SharePoint sites.
- Validate classification results using Content Explorer.
- Verify custom SITs from Labs 1-2 detect patterns correctly.
- Understand classification timing and background indexing behavior.
- Analyze SIT effectiveness with confidence level distribution reports.

**Key Deliverables**:

- On-Demand Classification executed successfully on SharePoint site from Lab 0.
- Content Explorer validation showing classified documents.
- Custom SIT accuracy verified (regex-based and EDM-based).
- Classification metrics report (detection counts, confidence levels).

**Prerequisites**: Lab 0 completed (SharePoint indexing from Lab 0 is now complete), Labs 1-2 completed (custom SITs ready for validation)

**Timing Note**: ✅ **By now, SharePoint indexing from Lab 0 is complete** (15-30 minutes elapsed during Labs 1-2). No active waiting required!

---

### [Lab 4: Retention Labels & Auto-Apply Policies](./04-RetentionLabels/)

**Duration**: 45-60 minutes | Flexible timing based on completion speed  
**Objective**: Configure and validate retention labels with auto-apply policies

**What You'll Learn**:

- Enhance initial retention labels from Lab 0 with custom SIT triggers.
- Configure auto-apply policies linking labels to Labs 1-2 custom SITs.
- Understand simulation mode (1-2 days) vs production mode (7 days) timing.
- Work with retention label policies regardless of activation timeline.
- Monitor retention label adoption and coverage metrics.

**Key Deliverables**:

- Enhanced retention labels with custom SIT-based auto-apply policies.
- Simulation mode results reviewed (if 1-2 days elapsed since Lab 0).
- Production label application validated (if 7+ days elapsed since Lab 0).
- Retention label coverage metrics and adoption reporting.

**Prerequisites**: Lab 0 completed (initial labels created), Labs 1-2 completed (custom SITs available as triggers), Lab 3 recommended (classification validation)

**Timing Flexibility**:
- ✅ **Fast completion (2-3 days total)**: Work in simulation mode, understand concepts fully
- ✅ **Production deployment (7+ days total)**: See full label application in production
- ✅ **Both paths provide complete learning experience!**

---

### [Lab 5: PowerShell Automation & Scaling](./05-PowerShellAutomation/)

**Duration**: 75-105 minutes | NO wait periods  
**Objective**: Implement enterprise-scale automation using Security & Compliance PowerShell

**What You'll Learn**:

- Execute compliance content searches using KQL syntax.
- Perform bulk deletion operations with audit trails.
- Apply retention labels at scale across multiple sites.
- Monitor classification policy adoption and coverage.
- Generate compliance reports for stakeholder review.

**Key Deliverables**:

- Compliance search scripts with parameterized KQL queries.
- Bulk operation scripts with error handling and logging.
- Multi-site monitoring dashboard data.
- Executive-level compliance report generation.

**Prerequisites**: Labs 0-4 completed (automation builds on all previous concepts)

---

### [Lab 6: Runbook Documentation](./06-Runbooks/)

**Duration**: 30-45 minutes (review and customization)  
**Objective**: Understand operational procedures and enterprise deployment workflows

**What You'll Learn**:

- End-to-end Purview deployment procedures.
- Classification workflow best practices.
- Retention label lifecycle management.
- Automation workflow integration patterns.
- Troubleshooting common scenarios.
- Operational handoff for IT teams.

**Key Deliverables**:

- Deployment runbook for new tenants.
- Classification and labeling workflow documentation.
- Retention policy implementation guide.
- Troubleshooting knowledge base.
- Operational support handoff checklist.

**Prerequisites**: Labs 0-5 completed (documentation references all previous labs)

---

## ⚡ Quick Start

### Prerequisites

**Microsoft 365 Licensing**:

- Microsoft 365 E5 OR Microsoft 365 E5 Compliance add-on.
- Required for advanced SITs, EDM, trainable classifiers, and auto-apply policies.

**Azure AD Permissions**:

- Compliance Administrator OR Global Administrator role.
- EDM_DataUploaders security group membership (for Lab 2 EDM section).

**Technical Requirements**:

- PowerShell 5.1+ or PowerShell 7+.
- ExchangeOnlineManagement module v3.0+.
- Internet connectivity for Microsoft 365 tenant access.

**Knowledge Prerequisites**:

- Basic understanding of Microsoft 365 administration.
- Familiarity with SharePoint Online navigation.
- PowerShell scripting fundamentals (for Labs 5-6).

### Getting Started - Recommended Approach

**Step 1: Start with Lab 0** (30-45 minutes active work):

Complete [Lab 0: Prerequisites & Time-Sensitive Setup](./00-Prerequisites-Setup/) to:
- Validate all prerequisites automatically
- Create SharePoint test site with sample documents (triggers 15-30 min background indexing)
- Create placeholder custom SITs (triggers 5-15 min global replication)
- Initialize retention labels (triggers up to 7-day activation)
- **Continue immediately to Lab 1 - no waiting required!**

**Step 2: Complete Labs 1-2** (4-5 hours active work):

Work through custom SIT creation while background processing from Lab 0 completes:
- [Lab 1: Custom SITs (Regex & Keywords)](./01-CustomSITs/) - 60-75 minutes
- [Lab 2: Exact Data Match (EDM)](./02-CustomSITs/) - 75-90 minutes

**Step 3: Validate in Lab 3** (30-45 minutes):

By now, SharePoint indexing from Lab 0 is complete (15-30 min elapsed):
- [Lab 3: On-Demand Classification & Content Explorer](./03-OnDemandClassification/)
- **No active waiting - immediate validation!**

**Step 4: Choose Your Path for Labs 4-6**:

**Path A - Accelerated Learning (2-3 days total)**:
- Complete Lab 4 in simulation mode (retention labels not fully activated yet)
- Complete Labs 5-6 for automation and documentation
- **Result**: Full technical knowledge, labels in simulation mode

**Path B - Production Deployment (1-2 weeks total)**:
- Complete Lab 4 simulation review (1-2 days after Lab 0)
- Wait for retention label activation (7 days after Lab 0)
- Validate Lab 4 production deployment
- Complete Labs 5-6 for automation and documentation
- **Result**: Full production deployment with activated labels

### Installation Steps

#### Step 1: Install Required PowerShell Modules

```powershell
# Install Exchange Online Management (includes Security & Compliance PowerShell)
Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force

# Install SharePoint Online Management Shell (for multi-site operations)
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force

# Verify module installation
Get-Module -Name ExchangeOnlineManagement -ListAvailable
Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable
```

#### Step 2: Connect to Security & Compliance PowerShell

```powershell
# Import module
Import-Module ExchangeOnlineManagement

# Connect to Security & Compliance PowerShell
Connect-IPPSSession -UserPrincipalName your-admin@yourtenant.onmicrosoft.com
```

#### Step 3: Verify Permissions

```powershell
# Check your admin roles
Get-ManagementRoleAssignment -RoleAssignee "your-admin@yourtenant.onmicrosoft.com" | 
    Select-Object Role, RoleAssigneeType | 
    Format-Table -AutoSize
```

**Step 4: Begin with Lab 0** - This is now handled by the automated prerequisites validation in Lab 0!

---

## 🗂️ Project Structure

```text
Purview-Classification-Lifecycle-Labs/
├── README.md                                    # This file
├── 00-Prerequisites-Setup/                      # Lab 0: Front-loaded time-sensitive setup
│   ├── README.md
│   ├── scripts/                                 # Automated validation and initialization
│   └── data/                                    # Sample data templates
├── 01-CustomSITs/                               # Lab 1: Regex-based custom SITs (RENAMED from Lab 2 partial)
│   ├── README.md
│   ├── scripts/
│   ├── configs/
│   └── data/
├── 02-CustomSITs/                               # Lab 2: EDM configuration (RENAMED from Lab 2 partial)
│   ├── README.md
│   ├── scripts/
│   ├── configs/
│   ├── data/
│   └── edm/                                     # EDM-specific subdirectory
├── 03-OnDemandClassification/                   # Lab 3: Classification validation (MOVED from Lab 1)
│   ├── README.md
│   ├── scripts/
│   └── data/
├── 04-RetentionLabels/                          # Lab 4: Retention and lifecycle (RENAMED from Lab 3)
│   ├── README.md
│   ├── scripts/
│   └── configs/
├── 05-PowerShellAutomation/                     # Lab 5: Enterprise automation (RENAMED from Lab 4)
│   ├── README.md
│   ├── scripts/
│   └── configs/
├── 06-Runbooks/                                 # Lab 6: Operational docs (RENAMED from Lab 5)
│   ├── README.md
│   └── docs/
└── scripts/                                     # Shared utilities and modules
    ├── common/
    └── modules/
```

---

## 🔧 Shared Utilities

The `scripts/` directory contains reusable PowerShell functions used across all labs:

**Common Scripts**:

- `Connect-PurviewCompliance.ps1` - Authentication and connection management.
- `Test-Prerequisites.ps1` - Validate module installation and permissions (enhanced in Lab 0).
- `Write-ComplianceLog.ps1` - Standardized logging with color-coded output.

**PowerShell Modules**:

- `PurviewHelpers.psm1` - Exported functions for SIT management, retention operations, content searches.
- `ErrorHandling.psm1` - Enterprise error handling with retry logic and comprehensive reporting.

**Usage Example**:

```powershell
# Import shared modules
Import-Module ".\scripts\modules\PurviewHelpers.psm1" -Force
Import-Module ".\scripts\modules\ErrorHandling.psm1" -Force

# Use helper functions
Test-PurviewPrerequisites
Connect-PurviewCompliance -TenantName "yourtenant"
```

---

## 📊 Learning Outcomes

Upon completing all six labs, you will be able to:

**Information Protection & Classification**:

- Design and implement custom Sensitive Information Types for organizational data patterns.
- Configure Exact Data Match (EDM) for structured sensitive data protection.
- Tune confidence levels and instance counts for optimal detection accuracy.
- Execute On-Demand Classification to re-index existing SharePoint content.

**Data Lifecycle Management**:

- Create retention labels with file plan descriptors aligned to compliance requirements.
- Configure retention periods with appropriate deletion triggers (created/modified/labeled).
- Implement auto-apply policies based on sensitive data detection.
- Manage the retention label lifecycle from creation through enforcement.

**Automation & Scaling**:

- Write PowerShell scripts for compliance content searches using KQL syntax.
- Execute bulk operations (deletion, labeling) with comprehensive error handling.
- Monitor classification policy adoption across multiple SharePoint sites.
- Generate executive-level compliance reports for stakeholder review.

**Enterprise Deployment**:

- Follow production deployment runbooks for Purview Information Protection.
- Implement operational handoff procedures for IT support teams.
- Troubleshoot common classification and retention policy issues.
- Maintain Purview configurations in enterprise Microsoft 365 tenants.

---

## 💼 Professional Skills You'll Gain

Completing this project demonstrates proficiency in the following industry-recognized Microsoft Purview skills, formatted for LinkedIn profiles, resumes, and corporate workforce development systems:

### Core Technical Competencies

**Information Protection & Data Classification:**

- Sensitive Information Types (SIT) design and implementation (regex-based and EDM exact matching).
- Custom SIT development with confidence tuning and validation techniques.
- Exact Data Match (EDM) for structured sensitive data (database-driven classification).
- Data Classification tools (On-Demand Classification, Content Explorer validation).
- SharePoint Online data governance and compliance management.
- Data lifecycle management (retention labels, auto-apply policies, lifecycle triggers).

**Automation & Scripting:**

- Security & Compliance PowerShell for enterprise-scale operations.
- Compliance content searches using KQL (Keyword Query Language).
- Bulk classification and retention operations with error handling.
- Executive compliance reporting and metrics generation.
- PowerShell automation for repeatable deployment workflows.

**Cloud & Hybrid Architecture:**

- Microsoft 365 compliance center administration.
- SharePoint Online site configuration and document management.
- Microsoft Entra ID (formerly Azure AD) authentication and permissions.
- Microsoft Purview portal navigation and configuration.

### Business & Compliance Competencies

**Regulatory Compliance & Data Governance:**

- Data retention policy design and implementation.
- Compliance monitoring and policy adoption tracking.
- Records management best practices.
- Data lifecycle management strategies.
- Audit trail management and validation.

**Project & Process Management:**

- Technical documentation and operational runbook development.
- Multi-phase project execution (accelerated vs production timelines).
- Change management for data governance policies.
- Knowledge transfer and team enablement.

### Advanced Specializations

**Data Analytics & Pattern Recognition:**

- Regex pattern development for complex data detection (85-95% accuracy).
- EDM schema design for structured database protection (99% accuracy).
- Classification effectiveness analysis and confidence level tuning.
- SIT performance optimization and false positive reduction.

**Enterprise Architecture:**

- Scalable compliance automation framework development.
- Production-ready operational procedures and runbooks.
- Policy lifecycle management from design to enforcement.
- Cross-functional collaboration (IT, legal, compliance teams).

### Relevant Certifications & Career Paths

This project provides hands-on experience aligned with:

- **Microsoft Certified: Information Protection and Compliance Administrator Associate** (SC-400).
- **Microsoft Certified: Security, Compliance, and Identity Fundamentals** (SC-900).
- Roles: Compliance Administrator, Data Governance Analyst, Information Protection Specialist, Microsoft 365 Administrator, Records Manager.

### LinkedIn Skills Keywords

For maximum visibility on LinkedIn and applicant tracking systems (ATS), this project covers:

`Microsoft Purview` • `Information Protection` • `Data Classification` • `Sensitive Information Types (SIT)` • `Exact Data Match (EDM)` • `Retention Labels` • `Data Lifecycle Management` • `Auto-Apply Policies` • `Compliance Management` • `Microsoft 365 Administration` • `SharePoint Online` • `PowerShell Scripting` • `Security & Compliance PowerShell` • `KQL (Keyword Query Language)` • `Content Classification` • `Data Governance` • `Records Management` • `Compliance Reporting` • `Pattern Recognition` • `Regex Development` • `On-Demand Classification` • `Content Explorer` • `Technical Documentation` • `Operational Runbooks`

---

## 📊 Microsoft Purview Capability Coverage

### What This Project Covers

This project provides **hands-on practical experience with core Microsoft Purview data classification and lifecycle management capabilities**, focusing on:

- **Custom Sensitive Information Types** (regex-based pattern matching and EDM exact matching)
- **Data Classification** (On-Demand Classification, Content Explorer validation)
- **Retention Labels & Lifecycle Management** (auto-apply policies, simulation vs production modes)
- **SharePoint Online Governance** (site configuration, document classification, retention)
- **PowerShell Automation** (bulk operations, compliance searches, reporting)
- **Operational Documentation** (production runbooks, troubleshooting guides, handoff procedures)

**Coverage Depth**: ~35% of total Microsoft Purview capability landscape with **deep hands-on experience** in covered areas (comprehensive implementation, not superficial overview).

**Project Focus**: Hands-on practical labs suitable for IT professionals and compliance administrators building foundational to intermediate Purview Information Protection skills with emphasis on classification accuracy and lifecycle automation.

### Covered Capabilities by Category

#### ✅ Information Protection & Data Classification (100% Core Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Custom SITs (Regex-based)** | ✅ COMPREHENSIVE | Lab 1 (7 exercises with confidence tuning) |
| **Exact Data Match (EDM) SITs** | ✅ COMPREHENSIVE | Lab 2 (8 exercises with schema design, hashing, upload) |
| **On-Demand Classification** | ✅ EXTENSIVE | Lab 3 (SharePoint re-indexing and validation) |
| **Content Explorer** | ✅ EXTENSIVE | Lab 3 (classification validation and reporting) |
| **SIT Confidence Tuning** | ✅ DETAILED | Lab 1 (High/Medium/Low 85%/75%/65%) |
| **Keyword Dictionaries** | ✅ DETAILED | Lab 1 (context-aware detection patterns) |
| **EDM Schema Design** | ✅ COMPREHENSIVE | Lab 2 (multi-field searchable schemas) |
| **EdmUploadAgent.exe** | ✅ COMPREHENSIVE | Lab 2 (hash generation and data upload) |

#### ✅ Data Lifecycle Management (90% Core Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Retention Labels** | ✅ COMPREHENSIVE | Lab 0 (initialization), Lab 4 (enhancement) |
| **Auto-Apply Policies** | ✅ COMPREHENSIVE | Lab 4 (SIT-based triggers, policy configuration) |
| **Retention Simulation Mode** | ✅ DETAILED | Lab 4 (1-2 day accelerated validation) |
| **Retention Production Mode** | ✅ DETAILED | Lab 4 (7-day activation timeline) |
| **Label Lifecycle Management** | ✅ EXTENSIVE | Lab 4 (creation, enhancement, activation, monitoring) |
| **Policy Adoption Monitoring** | ✅ COMPREHENSIVE | Lab 5 (coverage metrics, reporting) |

#### ✅ SharePoint Online Governance (80% Classification Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **SharePoint Site Configuration** | ✅ COMPREHENSIVE | Lab 0 (Communication Site creation) |
| **Document Upload & Management** | ✅ COMPREHENSIVE | Lab 0 (sample data preparation) |
| **On-Demand Classification Triggers** | ✅ EXTENSIVE | Lab 3 (manual re-indexing initiation) |
| **Classification Validation** | ✅ EXTENSIVE | Lab 3 (Content Explorer results analysis) |

#### ✅ PowerShell Automation & Scaling (85% Compliance Operations)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Security & Compliance PowerShell** | ✅ EXTENSIVE | Labs 0-5 (all operations automated) |
| **Compliance Content Searches** | ✅ COMPREHENSIVE | Lab 5 (KQL syntax, parameterized queries) |
| **Bulk Operations (Deletion)** | ✅ COMPREHENSIVE | Lab 5 (error handling, audit trails) |
| **Bulk Label Application** | ✅ COMPREHENSIVE | Lab 5 (multi-site scaling patterns) |
| **Policy Adoption Monitoring** | ✅ EXTENSIVE | Lab 5 (classification coverage dashboards) |
| **Compliance Reporting** | ✅ COMPREHENSIVE | Lab 5 (executive-level report generation) |

#### ✅ Operational Documentation & Runbooks (90% Enterprise Patterns)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Production Deployment Runbooks** | ✅ EXTENSIVE | Lab 6 (end-to-end procedures) |
| **Classification Workflow Documentation** | ✅ COMPREHENSIVE | Lab 6 (best practices, operational guides) |
| **Troubleshooting Knowledge Base** | ✅ COMPREHENSIVE | Lab 6 (common scenarios, resolutions) |
| **Operational Handoff Procedures** | ✅ COMPREHENSIVE | Lab 6 (IT support team enablement) |

### What This Project Does NOT Cover

The following capabilities require **enterprise-scale deployments**, **advanced licensing**, or **specialized infrastructure** beyond this project's scope:

#### ❌ Data Loss Prevention (DLP) - Advanced

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **DLP Policies (Endpoint/Cloud App/Email)** | INTERMEDIATE | Project focuses on classification and lifecycle, not data loss prevention policies |
| **DLP Policy Enforcement** | INTERMEDIATE | No policy blocking/quarantine workflows covered |
| **DLP Reporting & Alerts** | INTERMEDIATE | Activity Explorer focused on classification only |
| **Cross-platform DLP** | ADVANCED | Windows/macOS/SaaS app DLP beyond scope |

#### ❌ Advanced Sensitivity & Encryption (Intermediate to Expert)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Sensitivity Labels (Encryption)** | INTERMEDIATE | Encryption/visual markings not core to classification-focused project |
| **Double Key Encryption** | EXPERT | Requires external key server, complex PKI setup |
| **Customer Key** | EXPERT | Tenant-level encryption keys, enterprise-only feature |
| **Azure Information Protection (AIP) Scanner** | ADVANCED | On-premises file share scanning not covered (SharePoint Online focus) |

#### ❌ Records Management (Full Suite - Intermediate)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **File Plan Descriptors** | INTERMEDIATE | Advanced records metadata not covered (basic retention labels only) |
| **Disposition Reviews** | INTERMEDIATE | Manual approval workflows beyond scope |
| **Multi-stage Disposition** | ADVANCED | Complex approval workflows not implemented |
| **Event-based Retention** | INTERMEDIATE | Custom event triggers not covered |
| **Regulatory Records** | INTERMEDIATE | Immutable records features not covered |

#### ❌ eDiscovery (Intermediate to Advanced)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **eDiscovery (Standard)** | INTERMEDIATE | Content search workflows not covered (classification focus) |
| **eDiscovery (Premium)** | ADVANCED | Custodian management, review sets beyond scope |
| **Legal Hold** | INTERMEDIATE | Litigation hold workflows not implemented |
| **Export & Review Sets** | INTERMEDIATE | Legal export procedures not covered |

#### ❌ Advanced Classification & Machine Learning (Expert)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Trainable Classifiers** | EXPERT | ML-based document classification requires 300+ sample curation and 24-hour training |
| **Fingerprinting** | ADVANCED | Document template-based classification not covered |
| **Named Entities** | ADVANCED | Pre-built entity detection (addresses, names) not covered |

#### ❌ Insider Risk & Communication Compliance (Expert)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Insider Risk Management** | EXPERT | ML-based user risk scoring requires separate deployment |
| **Communication Compliance** | EXPERT | Regulatory monitoring (SEC, FINRA) beyond scope |
| **Adaptive Protection** | EXPERT | Dynamic risk-based policy adjustment requires Insider Risk integration |

#### ❌ Audit & Lifecycle (Extended Features - Intermediate)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Audit (Premium)** | INTERMEDIATE | Extended retention beyond 180 days not covered |
| **Inactive Mailboxes** | INTERMEDIATE | Mailbox preservation after user departure not covered |
| **Archive Mailboxes** | BASIC | Additional mailbox storage not covered |
| **PST Import Service** | INTERMEDIATE | Bulk PST file import not covered |

#### ❌ Advanced Governance & Collaboration (Intermediate to Advanced)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Information Barriers** | ADVANCED | User segmentation policies (ethical walls) not covered |
| **Privileged Access Management** | EXPERT | Just-in-time admin access beyond scope |
| **Container Labels (Teams/Groups/Sites)** | INTERMEDIATE | Teams/Groups/Sites sensitivity labels not covered |
| **Multi-Geo Capabilities** | ADVANCED | Cross-region data residency not covered |

---

## ⏱️ Lab Progression, Prerequisites & Timing

### Complete Lab Sequence with Dependencies

| Lab | Duration | Prerequisites | Background Processing & Sync Delays | Status After Completion |
|-----|----------|---------------|-------------------------------------|------------------------|
| **Lab 0** | 30-45 min | None (start here) | **Initiates**: SharePoint indexing (15-30 min), SIT replication (5-15 min), Retention labels (up to 7 days) | ✅ Foundation ready, background processing running |
| **Lab 1** | 60-75 min | Lab 0 complete | None (SIT replication from Lab 0 completes during this lab) | ✅ Regex SITs created, ready for validation |
| **Lab 2** | 75-90 min | Lab 0 complete, Lab 1 recommended | EDM data hashing/upload: 30-60 min (background) | ✅ EDM SITs created, ready for validation |
| **Lab 3** | 30-45 min | Labs 0-2 complete | **None** - SharePoint indexing from Lab 0 is complete (15-30 min elapsed during Labs 1-2) | ✅ Classification validated, SITs confirmed working |
| **Lab 4** | 45-60 min | Labs 0-3 complete | **Flexible**: Simulation mode (1-2 days) OR Production mode (7+ days from Lab 0) | ✅ Auto-apply policies configured, labels applying |
| **Lab 5** | 75-105 min | Labs 0-4 complete | None | ✅ Automation scripts ready, reporting implemented |
| **Lab 6** | 30-45 min | Labs 0-5 complete | None | ✅ Runbooks documented, operational handoff ready |
| **Total** | **5.5-7.5 hours** | Sequential progression | **All background ops front-loaded in Lab 0** | **Complete Purview classification & lifecycle system** |

### Critical Timing & Synchronization Points

| Operation | Duration | Impact | When It Completes |
|-----------|----------|--------|-------------------|
| **SharePoint indexing** (Lab 0) | 15-30 min | Required for Lab 3 On-Demand Classification | Completes during Labs 1-2 (no active waiting) |
| **Custom SIT replication** (Lab 0) | 5-15 min | Required for SITs to be globally available | Completes during Lab 1 (no active waiting) |
| **EDM data processing** (Lab 2) | 30-60 min | Required for EDM SIT matching to work | Runs in background during Lab 2 completion |
| **Retention label simulation** (Lab 0/4) | 1-2 days | Optional - review simulation results in Lab 4 | Wait 1-2 days after Lab 0 to see simulation data |
| **Retention label production** (Lab 0/4) | Up to 7 days | Optional - see fully activated labels in Lab 4 | Wait 7+ days after Lab 0 for production activation |

> **⏱️ Time Optimization Strategy**: Lab 0 front-loads ALL time-sensitive operations into the beginning of the curriculum. While you actively work through Labs 1-3, background processing completes automatically. By the time you reach Lab 3, SharePoint indexing is done - **no active waiting required**. Lab 4 offers flexibility: work in simulation mode (2-3 days total) OR wait for full production activation (7+ days) - both paths provide complete learning experience.

### Lab Progression Summary

**Active Work Time**: 5.5-7.5 hours total hands-on lab work  
**Background Processing**: All initiated in Lab 0, completes during Labs 1-3  
**No Active Waiting**: Zero time spent waiting for processes to complete  
**Flexible Timeline**: Complete in 2-3 focused days (simulation mode) OR 1-2 weeks (production mode)

---

## 🚀 Learning Path Options

### Path A: Accelerated Technical Learning (2-3 Days)

**Best For**: Learning Purview capabilities quickly, technical training, proof-of-concept validation

**Timeline**:

- **Day 1**: Labs 0-2 (Complete setup + custom SITs: 5-6 hours)
- **Day 2**: Labs 3-4 (Classification validation + retention simulation mode: 4-5 hours)
- **Day 3**: Labs 5-6 (Automation + documentation: 5-6 hours)

**Total Active Work**: 14-17 hours over 3 days

**Background Processing**: All initiated in Lab 0, completes during active learning

**Result**: Complete technical understanding of Purview classification and lifecycle management, retention labels in simulation mode

---

### Path B: Production Deployment (1-2 Weeks)

**Best For**: Enterprise production deployment, seeing fully activated retention labels, real-world implementation

**Timeline**:
- **Week 1, Day 1**: Lab 0 (Setup with retention label initialization: 45 min)
- **Week 1, Days 2-3**: Labs 1-2 (Custom SITs: 5-6 hours spread over 2 days)
- **Week 1, Day 4**: Lab 3 (Classification validation: 45 min)
- **Week 1, Day 5**: Lab 4 simulation review (1 hour)
- **Between Weeks**: Wait 7 days for retention label production activation
- **Week 2, Day 1**: Lab 4 production validation (1 hour)
- **Week 2, Days 2-3**: Lab 5 (Automation: 4 hours spread over 2 days)
- **Week 2, Day 4**: Lab 6 (Documentation: 1 hour)

**Total Active Work**: 12-14 hours over 2 weeks

**Background Processing**: 7-day retention label activation between weeks

**Result**: Full production deployment with activated retention labels, enterprise-ready configuration

---

## 🚨 Critical Success Factors

**Before Starting**:

- ✅ **Start with Lab 0 FIRST** - This front-loads all time-sensitive operations and enables seamless lab progression.
- ✅ Verify Microsoft 365 E5 or E5 Compliance licensing for your test account.
- ✅ Confirm Compliance Administrator or Global Administrator role assignment.
- ✅ Install ExchangeOnlineManagement module v3.0+ and SharePoint Online Management Shell.
- ✅ Review Microsoft Purview portal navigation (compliance.microsoft.com).

**Common Pitfalls to Avoid**:

- ❌ **Skipping Lab 0**: Attempting to start with Lab 1 will result in missing SharePoint sites, sample data, and prerequisites.
- ❌ **Insufficient Licensing**: Basic Microsoft 365 plans don't include advanced SITs or EDM - verify E5 Compliance licensing.
- ❌ **Incorrect Permissions**: Requires Compliance Administrator role minimum - Global Reader is insufficient.
- ❌ **Module Version Issues**: ExchangeOnlineManagement v2.x lacks REST API support - upgrade to v3.0+.
- ❌ **Misunderstanding Background Processing**: Lab 0 initiates background operations that complete while you work through Labs 1-3 - this is intentional and eliminates active waiting.
- ❌ **EDM Security Group Missing**: EDM upload requires EDM_DataUploaders group membership - add before Lab 2 EDM section.

---

## 🔍 Validation Checkpoints

Each lab includes validation steps to confirm successful completion:

**Lab 0 Validation**:

- SharePoint Communication Site created with sample documents uploaded.
- 3 placeholder custom SITs created and visible in Purview portal.
- 3 initial retention labels configured with auto-apply simulation mode.
- All background processing initiated (SharePoint indexing, SIT replication, retention label processing).

**Lab 1 Validation**:

- Enhanced custom regex SITs detect test patterns with correct confidence levels.
- Keyword dictionaries match specialized organizational terminology.
- Multi-level confidence scoring (High/Medium/Low) configured correctly.
- SIT validation testing passes against local sample files.

**Lab 2 Validation**:

- EDM schema uploads successfully via PowerShell (`New-DlpEdmSchema` cmdlet).
- Sensitive data table hash uploads complete via EdmUploadAgent.exe.
- EDM-based custom SIT created and linked to data store.
- Exact match validation shows zero false positives compared to regex approach.

**Lab 3 Validation**:

- Custom SIT appears in Microsoft Purview portal under **Data classification** → **Sensitive info types**.
- On-Demand Classification scan completes without errors in SharePoint site settings.
- Content Explorer shows classified documents matching your custom SIT patterns from Labs 1-2.
- Classification metrics report shows detection counts and confidence level distribution.

**Lab 4 Validation**:

- Enhanced retention labels appear in **Records management** → **File plan**.
- Auto-apply policy shows "On" status (not "Off (Error)") in **Data lifecycle management**.
- Simulation mode results display in policy details (if 1-2 days elapsed).
- Labels begin appearing on documents (if 7+ days elapsed, production mode).

**Lab 5 Validation**:

- Compliance search cmdlets execute without authentication errors.
- Bulk operation scripts complete with comprehensive success/failure logs.
- Multi-site monitoring scripts return classification coverage metrics.
- Compliance reports generate in CSV/JSON format for executive review.

**Lab 6 Validation**:

- Runbook documentation covers all prerequisite steps and dependencies.
- Workflow diagrams accurately reflect portal navigation and configuration steps.
- Troubleshooting guide includes common error messages with resolution steps.
- Operational handoff checklist provides complete information for IT support teams.

---

## 🛠️ Troubleshooting Resources

**Common Issues & Solutions**:

1. **PowerShell Connection Failures**:
   - **Symptom**: `Connect-IPPSSession` fails with authentication errors.
   - **Solution**: Verify MFA enrollment, check conditional access policies, ensure ExchangeOnlineManagement v3.0+ installed.

2. **SIT Not Detecting Content**:
   - **Symptom**: Custom SIT created but doesn't match expected documents.
   - **Solution**: Verify regex pattern syntax, check confidence level settings (try Medium instead of High), test with simplified patterns first.

3. **EDM Upload Failures**:
   - **Symptom**: EdmUploadAgent.exe errors during hash/upload process.
   - **Solution**: Verify EDM_DataUploaders group membership, check CSV file encoding (must be UTF-8), ensure column count matches schema fields.

4. **Retention Labels Not Applying**:
   - **Symptom**: Auto-apply policy shows "On" but labels don't appear after 7+ days.
   - **Solution**: Run PowerShell retry command: `Set-RetentionCompliancePolicy -Identity "PolicyName" -RetryDistribution`.

5. **Compliance Search Errors**:
   - **Symptom**: Content search fails with KQL syntax errors.
   - **Solution**: Validate KQL syntax using Microsoft documentation, test queries in Content Search UI before PowerShell, check location specifications.

**Additional Support**:

- Microsoft Learn Documentation: [learn.microsoft.com/purview](https://learn.microsoft.com/en-us/purview/)
- Microsoft 365 Admin Center: **Health** → **Service health** for platform issues.
- Each lab's README.md includes detailed troubleshooting sections with lab-specific guidance.

---

## 📖 Additional Resources

**Microsoft Official Documentation**:

- [Microsoft Purview Information Protection](https://learn.microsoft.com/en-us/purview/information-protection)
- [Sensitive Information Types Entity Definitions](https://learn.microsoft.com/en-us/purview/sit-sensitive-information-type-entity-definitions)
- [Learn About Exact Data Match](https://learn.microsoft.com/en-us/purview/sit-learn-about-exact-data-match-based-sits)
- [Create and Publish Retention Labels with PowerShell](https://learn.microsoft.com/en-us/purview/bulk-create-publish-labels-using-powershell)
- [Security & Compliance PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/scc-powershell)

**PowerShell Module References**:

- [ExchangeOnlineManagement Module](https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2)
- [Connect to Security & Compliance PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell)
- [SharePoint Online Management Shell](https://learn.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online)

**Compliance & Governance**:

- [Microsoft Purview Compliance Manager](https://learn.microsoft.com/en-us/purview/compliance-manager)
- [Data Lifecycle Management Overview](https://learn.microsoft.com/en-us/purview/data-lifecycle-management)
- [Microsoft 365 Retention Policies](https://learn.microsoft.com/en-us/purview/retention)

---

## 🤝 Contributing

This project is designed for learning and can be customized for organizational needs. When adapting labs:

- Follow the PowerShell Style Guide in `Style-Guides/powershell-style-guide.md`.
- Maintain markdown formatting standards from `Style-Guides/markdown-style-guide.md`.
- Test all scripts in a non-production tenant before enterprise deployment.
- Update validation checkpoints when modifying lab objectives.

---

## 📝 License

Copyright (c) 2025 Marcus Jacobson. All rights reserved.  
Licensed under the MIT License.

---

## 🤖 AI-Assisted Content Generation

This comprehensive lab curriculum was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview Information Protection best practices, PowerShell automation patterns, enterprise data governance workflows, professional skills development frameworks, and capability coverage analysis validated against current Microsoft Learn documentation as of November 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Purview capabilities while maintaining technical accuracy, professional skills alignment for career development, and reflecting industry best practices for information protection and data lifecycle management.*
