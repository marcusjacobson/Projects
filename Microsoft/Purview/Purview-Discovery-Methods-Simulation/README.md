# Purview Discovery Methods Simulation

## 🎯 Project Overview

This comprehensive lab environment demonstrates Microsoft Purview Information Protection through **automated simulation** of enterprise-scale data governance workflows. Through **five progressive hands-on labs**, you'll implement SharePoint provisioning, realistic document generation, classification validation, DLP policy enforcement, and comprehensive monitoring - all using **browser-based authentication** and **configuration-driven architecture** for complete environment portability.

**Target Audience**: Security engineers, compliance administrators, consultants, and IT professionals implementing Microsoft Purview Information Protection in enterprise environments.

**Approach**: Fully automated simulation environment with configuration-driven design. Generate thousands of realistic HR/PII documents, validate built-in Sensitive Information Type (SIT) detection, implement DLP policies, and monitor effectiveness - all without writing custom SITs or managing credentials. Complete the simulation cycle in **1-2 days** OR scale to enterprise-level demonstrations with **20,000+ documents** for production validation.

**What Makes This Different:**

- **Configuration-Driven**: Single `global-config.json` file controls all environment values - no hardcoded tenants, URLs, or emails.
- **Complete Portability**: Move between Dev/Test/Prod by updating one config file. Multi-tenant ready for consultants.
- **Browser-Based Auth**: Zero secrets, credentials, or app registrations. All authentication via interactive browser flow.
- **Scalable Simulation**: Three scale levels (Small/Medium/Large) adjust complexity automatically from demos to enterprise simulations.
- **Built-In SITs Focus**: Leverages Microsoft's built-in Sensitive Information Types - no custom SIT creation required.
- **Repeatable Cleanup**: Complete environment reset for multiple demonstrations and testing iterations.

---

## ⏱️ Time & Resource Considerations

**Before starting this project, understand these key factors:**

| Consideration | Impact | Planning |
|---------------|--------|----------|
| **⏱️ Document Generation** | 5-10 min (Small) to 1-2 hours (Large) | Start Small for testing, scale up for demos |
| **⏱️ Document Upload** | 20-40 min (Small) to 3-5 hours (Large) | Plan upload during low-network activity |
| **⏱️ Classification Time** | Up to 7 days (all scales) | On-Demand Classification async process; Content Explorer updates within 7 days |
| **💾 Storage Impact** | 100 MB - 1 GB (Small) to 10-15 GB (Large) | Monitor SharePoint storage quotas |
| **🔄 Throttling** | PnP PowerShell: 600 req/min, 2500 req/hour | Scripts include automatic retry logic |

> **⏱️ Recommended Timeline**: **7-14 days for complete workflow with classification**
>
> - **Day 1**: Complete Labs 00-03 (Setup, Sites, Generation, Upload: ~2-4 hours hands-on)
> - **Days 2-7**: On-Demand Classification processing (up to 7 days async, Content Explorer updates within 7 days)
> - **Day 2+ (Parallel)**: Lab 05a immediate regex discovery (88-95% accuracy, no classification wait)
> - **Day 3+ (24hr wait)**: Lab 05b eDiscovery search + Lab 05c Graph API discovery (100% Purview SITs after SharePoint Search indexing)
> - **Days 7-14**: Lab 04 Content Explorer validation (after Microsoft Search indexing)
> - **Cleanup**: Lab 06 anytime (15-30 minutes)
>
> **💡 Accelerated Option**: Complete Labs 00-03 + 05a in **4-6 hours** for immediate regex-based discovery (88-95% accuracy) without waiting for classification or indexing.

**Resource Management**:

1. **Start Small**: Begin with Small scale (1,000 documents) for testing
2. **Monitor Storage**: Check SharePoint storage consumption before Large scale
3. **Throttling Awareness**: Scripts handle throttling automatically with retry logic
4. **Cleanup Critical**: Always run Lab 06 cleanup to remove simulation data

---

## 📚 Lab Progression

### [Lab 00: Prerequisites Setup](./00-Prerequisites-Setup/)

**Duration**: 10-15 minutes | Background setup  
**Objective**: Validate environment readiness and initialize simulation infrastructure

**What You'll Learn**:

- Validate Microsoft 365 E5 licensing and required Purview permissions.
- Configure global-config.json with tenant-specific information.
- Test PowerShell module versions and service connectivity.
- Initialize directory structure and logging infrastructure.
- Understand configuration-driven architecture and portability design.

**Key Deliverables**:

- `global-config.json` updated with tenant information (TenantUrl, AdminEmail, etc.).
- PowerShell modules validated: PnP.PowerShell v2.0+, ExchangeOnlineManagement v3.0+.
- Directory structure created (logs, output, generated-documents, reports, temp).
- Logging infrastructure initialized for simulation tracking.

**Critical Success Factor**: ✅ **Update `global-config.json` FIRST** with your tenant details. All subsequent labs read from this single configuration file.

---

### [Lab 01: SharePoint Site Creation](./01-SharePoint-Site-Creation/)

**Duration**: 10-15 minutes (5 sites) to 30-45 minutes (25 sites)  
**Objective**: Provision SharePoint sites representing organizational departments

**What You'll Learn**:

- Create SharePoint sites from `global-config.json` specifications.
- Configure site templates (Communication vs Team sites).
- Set site permissions and ownership automatically.
- Use `-SkipExisting` parameter for idempotent re-runs.
- Validate site creation success and readiness.

**Key Deliverables**:

- SharePoint sites created (default: HR, Finance, Legal, Marketing, IT).
- Site permissions configured with specified owners.
- Sites ready for document upload in Lab 03.

**Prerequisites**: Lab 00 completed (configuration validated)

---

### [Lab 02: Test Data Generation](./02-Test-Data-Generation/)

**Duration**: 5-10 minutes (Small) to 1-2 hours (Large)  
**Objective**: Generate realistic documents containing built-in Sensitive Information Types

**What You'll Learn**:

- Generate HR documents with U.S. Social Security Numbers (SSN).
- Create financial records with Credit Card numbers, Bank Accounts, ABA Routing Numbers.
- Produce identity documents with Passport numbers, Driver's Licenses, ITIN.
- Generate mixed-format documents (.docx, .xlsx, .pdf, .txt) with varying PII density.
- Understand built-in SIT patterns and confidence levels.

**Key Deliverables**:

- Generated documents stored in `./generated-documents` directory.
- Document distribution: 45% docx, 30% xlsx, 15% pdf, 10% txt (configurable).
- Built-in SITs embedded: SSN, Credit Cards, Passports, Driver's Licenses, ITIN, Bank Accounts, Routing Numbers.
- Scale-appropriate document counts (500-1,000 Small | 5,000 Medium | 20,000 Large).

**Prerequisites**: Lab 00 completed (environment validated, directory structure initialized), Lab 01 **optional** (sites not required for local document generation - only needed later for Lab 03 upload)

---

### [Lab 03: Document Upload Distribution](./03-Document-Upload-Distribution/)

**Duration**: 20-40 minutes (Small) to 3-5 hours (Large)  
**Objective**: Upload generated documents to SharePoint sites with intelligent distribution

**What You'll Learn**:

- Execute bulk document upload operations with throttling management.
- Distribute documents realistically across department sites (HR docs → HR site).
- Apply SharePoint metadata to uploaded documents (Department, ContentType, PIIDensity).
- Validate upload completion and distribution accuracy.
- Understand PnP PowerShell throttling limits and retry logic.

**Key Deliverables**:

- Documents uploaded to SharePoint sites from Lab 01.
- Intelligent distribution: HR documents → HR site, Financial → Finance site, etc.
- Custom SharePoint metadata applied: Department, ContentType, PIIDensity, GeneratedDate.
- Upload validation report confirming distribution success.

**Prerequisites**: Lab 01 completed (sites exist), Lab 02 completed (documents generated)

---

### [Lab 04: Classification Validation](./04-Classification-Validation/)

**Duration**: 30-60 minutes hands-on | Up to 7 days background classification  
**Objective**: Execute On-Demand Classification and validate official Purview SIT detection

**What You'll Learn**:

- Create and configure On-Demand Classification scans in Microsoft Purview portal (purview.microsoft.com).
- Review estimation results before starting classification (items for review, cost analysis).
- Start classification manually using "Start classification" workflow.
- Monitor classification progress through portal status updates (Estimating → Classifying → Completed).
- Query Content Explorer for classification results after completion.
- Validate official Purview SIT detection accuracy (100% accuracy with built-in SITs).
- Generate classification coverage reports and compliance metrics.

**Key Deliverables**:

- On-Demand Classification scan created and estimation completed (typically 300-500 items for review).
- Cost analysis validated before starting classification (typically $5-15 for simulation scale).
- Classification executed successfully across all simulation sites (7-day process).
- Content Explorer validation showing classified documents and detected SITs (updates within 7 days).
- Classification coverage report: detection counts by SIT type, confidence levels, and distribution.
- SIT effectiveness analysis for built-in types (High/Medium/Low confidence distribution).

**Prerequisites**: Lab 03 completed (documents uploaded to SharePoint), `BuiltInSITs` configured in `global-config.json`

**Timing Note**: ⏱️ **Classification runs asynchronously** over up to 7 days. Process includes estimation phase (minutes), then classification phase (up to 7 days), with Content Explorer updates appearing within 7 days of scan completion. Portal at purview.microsoft.com provides progress tracking.

> **💡 Strategic "Fire and Forget" Workflow**:
>
> 1. **Start Lab 04 Immediately**: Initiate the classification scan (Step 1).
> 2. **Do Not Wait**: Proceed immediately to Lab 05a or 05b (which do not require classification).
> 3. **Return Later**: Come back in 7 days to validate results in Content Explorer.
>
> **Why?** Lab 04 is the **only** way to populate **Content Explorer (Visualization)**, but Lab 05 provides **CSV Reports (Discovery)**. Lab 04 serves as the "Gold Standard" baseline to validate the accuracy of your Lab 05 discovery reports.

> **💡 Parallel Execution**: While Lab 04 classification runs asynchronously over 7 days, you can proceed with discovery labs:
>
> - **Lab 05a**: Immediate regex-based discovery (88-95% accuracy, no classification required)
> - **Lab 05b**: 24-hour eDiscovery search (100% Purview SITs, no classification required)
> - **Lab 05c**: 24-hour Graph API discovery (100% Purview SITs, no classification required)

---

### [Lab 05: Data Discovery Paths](./05-Data-Discovery-Paths/)

**Duration**: 1-3 hours (varies by path and timing requirements)  
**Objective**: Discover and report sensitive data using four distinct approaches with different timelines and accuracy levels

**What You'll Learn**:

- Choose between three discovery methods based on timing needs: Immediate (05a) or 24 hours (05b/05c).
- Understand accuracy differences: 70-90% regex detection (05a) vs 100% Purview SITs (05b/05c).
- Execute manual portal-based discovery with PnP PowerShell direct file access.
- Run official compliance searches using modern eDiscovery portal (purview.microsoft.com).
- Automate tenant-wide discovery using Microsoft Graph Search API.
- Generate comprehensive CSV reports for compliance audits and security operations.

**Three Discovery Paths**:

- **Lab 05a: PnP Direct File Access** - Immediate results with custom regex detection (70-90% accuracy)
- **Lab 05b: eDiscovery Compliance Search** - 24-hour results with official Purview SITs (100% accuracy)
- **Lab 05c: Graph API Discovery** - Automated tenant-wide scanning after 24 hours indexing (100% accuracy)

**Timeline Distinctions**:

- **Immediate**: Lab 05a (regex-based, learning-focused)
- **24 hours**: Lab 05b/05c (SharePoint Search index, compliance searches/API)

**Key Deliverables**:

- CSV discovery reports with SIT types, file paths, confidence levels, and rich metadata.
- Automation scripts for recurring discovery (Lab 05c with Microsoft Graph API).
- Discovery comparison analysis across multiple methods and accuracy levels.
- Compliance audit reports suitable for stakeholder presentations.

**Prerequisites**: Lab 04 (step 1) completed (classification active for portal-based discovery)

---

### [Lab 06: Cleanup and Reset](./06-Cleanup-Reset/)

**Duration**: 15-30 minutes  
**Objective**: Remove simulation resources and restore environment to clean state

**What You'll Learn**:

- Execute targeted cleanup of specific simulation resources.
- Perform complete environment reset (sites, documents, logs).
- Restore `global-config.json` to default template values.
- Validate cleanup completion and resource removal.
- Export cleanup documentation report.

**Key Deliverables**:

- Simulation sites removed from SharePoint tenant.
- Generated documents deleted from local directories.
- Configuration restored to default template (`global-config.json.template`).
- Cleanup validation report confirming resource removal.
- Environment ready for next simulation iteration.

**Prerequisites**: Any labs completed (can run cleanup at any stage)

**Safety Features**: WhatIf support, confirmation prompts, backup creation before deletion

---

## 📊 Microsoft Purview Capability Coverage

### What This Project Covers

This project provides **hands-on practical experience with core Microsoft Purview discovery methods simulation capabilities**, focusing on:

- **Built-In Sensitive Information Types** (leveraging Microsoft's pre-configured SITs with 100% accuracy)
- **On-Demand Classification** (7-day portal-based classification with estimation and cost analysis)
- **Content Explorer Validation** (classification coverage analysis with 7-day update timing)
- **Three Discovery Methods** (immediate regex, 24hr eDiscovery, 24hr Graph API)
- **Modern eDiscovery Portal** (purview.microsoft.com with Cases preview and Condition builder)
- **Microsoft Graph API** (automated tenant-wide discovery)
- **SharePoint Online Governance** (automated site provisioning, document distribution, metadata management)
- **PowerShell & API Automation** (Graph SDK, PnP PowerShell, OAuth 2.0 authentication)
- **Configuration-Driven Architecture** (environment portability, multi-tenant support, scalable simulations)

**Coverage Depth**: ~45% of total Microsoft Purview capability landscape with **deep hands-on simulation experience** in covered areas (production-ready automation patterns with multiple discovery methods, not theoretical overview).

**Project Focus**: Automated simulation environment suitable for consultants, pre-sales engineers, compliance administrators, and IT professionals building practical Purview demonstration and POC capabilities with emphasis on rapid deployment, realistic data governance scenarios, and comprehensive discovery method comparison.

### Covered Capabilities by Category

#### ✅ Information Protection & Data Classification (80% Simulation Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Built-In SITs (Pre-configured)** | ✅ COMPREHENSIVE | Lab 02 (SSN, Credit Cards, Passport, ITIN, Bank Accounts) |
| **On-Demand Classification** | ✅ EXTENSIVE | Lab 04 (estimation, cost analysis, 7-day classification, Content Explorer) |
| **Content Explorer** | ✅ EXTENSIVE | Lab 04 (classification metrics, 7-day updates, coverage reporting) |
| **Synthetic PII Generation** | ✅ COMPREHENSIVE | Lab 02 (realistic HR/Financial document creation) |
| **Classification Validation** | ✅ DETAILED | Lab 04 (100% Purview SIT accuracy, confidence analysis) |
| **Multi-SIT Document Generation** | ✅ COMPREHENSIVE | Lab 02 (mixed content with multiple PII types) |
| **Modern Purview Portal** | ✅ COMPREHENSIVE | Labs 04, 05b (purview.microsoft.com, eDiscovery Cases) |

#### ✅ Data Discovery & Compliance Search (85% Simulation Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **eDiscovery Compliance Search** | ✅ COMPREHENSIVE | Lab 05b (modern Cases preview, Condition builder, 24hr results) |
| **Direct File Access Discovery** | ✅ COMPREHENSIVE | Lab 05a (PnP PowerShell, immediate regex-based detection) |
| **Microsoft Graph API Discovery** | ✅ EXTENSIVE | Lab 05c (automated tenant-wide scans, SIEM integration) |
| **Multi-Method Discovery Comparison** | ✅ COMPREHENSIVE | Lab 05 overview (timing/accuracy matrix, decision guide) |
| **CSV Report Generation** | ✅ COMPREHENSIVE | Labs 05a/05c (Excel-ready discovery reports) |
| **Discovery Automation** | ✅ EXTENSIVE | Lab 05c (scheduled scans, recurring discovery) |

#### ✅ SharePoint Online Governance (90% Simulation Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Automated Site Provisioning** | ✅ COMPREHENSIVE | Lab 01 (5-25 sites, department-based organization) |
| **Bulk Document Upload** | ✅ COMPREHENSIVE | Lab 03 (throttling management, distribution logic) |
| **Document Distribution** | ✅ EXTENSIVE | Lab 03 (realistic cross-site content placement) |
| **Metadata Management** | ✅ DETAILED | Lab 03 (document properties, organizational context) |
| **Site Permission Configuration** | ✅ EXTENSIVE | Lab 01 (ownership, access management) |

#### ✅ PowerShell Automation & API Integration (95% Simulation Operations)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Browser-Based Authentication** | ✅ COMPREHENSIVE | All labs (interactive auth, OAuth 2.0) |
| **PnP PowerShell Operations** | ✅ COMPREHENSIVE | Labs 01, 03, 05a (sites, upload, discovery) |
| **Microsoft Graph SDK** | ✅ EXTENSIVE | Lab 05c (Graph Search API, delegated permissions) |
| **Bulk Document Generation** | ✅ COMPREHENSIVE | Lab 02 (500-20,000 documents with realistic PII) |
| **Throttling Management** | ✅ COMPREHENSIVE | Lab 03 (automatic retry logic, rate limiting) |
| **Indexing Status Validation** | ✅ COMPREHENSIVE | Lab 05b (real SharePoint scanning, readiness checks) |
| **Discovery Automation** | ✅ EXTENSIVE | Lab 05c (scheduled scans, recurring discovery) |
| **Environment Cleanup** | ✅ COMPREHENSIVE | Lab 06 (complete resource removal, reset operations) |

#### ✅ Configuration Management & Portability (100% Core Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Configuration-Driven Design** | ✅ COMPREHENSIVE | All labs (global-config.json single source of truth) |
| **Environment Portability** | ✅ COMPREHENSIVE | Documentation (Dev/Test/Prod migration) |
| **Multi-Tenant Support** | ✅ EXTENSIVE | Configuration (consultant-friendly patterns) |
| **Scalable Simulations** | ✅ COMPREHENSIVE | Configuration (Small/Medium/Large scale levels) |
| **Template-Based Reset** | ✅ COMPREHENSIVE | Lab 06 (pristine configuration restoration) |

### What This Project Does NOT Cover

The following capabilities require **custom development**, **advanced configuration**, or **specialized scenarios** beyond this project's simulation scope:

#### ❌ Custom Sensitive Information Types (Advanced Configuration)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Custom SITs (Regex-based)** | INTERMEDIATE | Project uses built-in SITs only; custom SIT creation requires advanced configuration |
| **Exact Data Match (EDM) SITs** | ADVANCED | Complex EDM schema design beyond simulation scope |
| **SIT Confidence Tuning** | INTERMEDIATE | Uses default confidence levels for built-in SITs |
| **Keyword Dictionaries** | INTERMEDIATE | Custom dictionaries not required for built-in SIT simulation |

#### ❌ Advanced Sensitivity & Encryption (Intermediate to Expert)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Sensitivity Labels** | INTERMEDIATE | Project focuses on classification and DLP, not document encryption |
| **Label Encryption** | ADVANCED | Encryption workflows not part of basic governance simulation |
| **Label Inheritance** | INTERMEDIATE | Advanced labeling scenarios beyond scope |
| **Double Key Encryption** | EXPERT | Requires external key server, enterprise-only feature |

#### ❌ Records Management & Retention (Intermediate)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Retention Labels** | INTERMEDIATE | Classification and DLP focus; retention lifecycle management not simulation objective |
| **Auto-Apply Retention Policies** | INTERMEDIATE | Retention lifecycle management not simulation objective |
| **Disposition Reviews** | ADVANCED | Manual approval workflows beyond simulation scope |
| **File Plan Descriptors** | INTERMEDIATE | Advanced records metadata not covered |

#### ❌ Cross-Platform DLP (Advanced)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Endpoint DLP (Windows/macOS)** | ADVANCED | Requires device onboarding, client deployment beyond simulation scope |
| **Cloud App DLP** | ADVANCED | Third-party SaaS app integration beyond SharePoint Online focus |
| **Email DLP (Exchange)** | INTERMEDIATE | Email protection not part of SharePoint-focused simulation |
| **Teams DLP** | INTERMEDIATE | Teams content governance beyond simulation scope |

#### ❌ Data Loss Prevention (DLP) Policies (Not Covered)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **DLP Policies (SharePoint)** | INTERMEDIATE | Project focuses on discovery and classification; DLP policy creation beyond scope |
| **Policy Templates** | INTERMEDIATE | DLP policy configuration not part of governance simulation |
| **DLP Incident Management** | INTERMEDIATE | Focus is on data discovery, not prevention policies |
| **Test Mode Policies** | BASIC | DLP testing workflows not included in discovery-focused project |

#### ❌ Advanced Compliance Features (Expert-Level)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **eDiscovery (Premium)** | ADVANCED | Basic eDiscovery covered in Lab 05b; Premium features (custodians, review sets, advanced holds) beyond scope |
| **Communication Compliance** | EXPERT | Regulatory monitoring (SEC, FINRA) beyond scope |
| **Insider Risk Management** | EXPERT | User behavior analytics, risk scoring not covered |
| **Information Barriers** | EXPERT | Organizational segmentation beyond simulation needs |
| **Privileged Access Management** | EXPERT | Just-in-time admin access beyond scope |

### Project Scope Statement

**Primary Mission**: Provide repeatable, scalable Microsoft Purview Information Protection simulation environment for **rapid POC deployment**, **demonstration preparation**, and **data discovery workflow validation** using **built-in capabilities and multiple discovery methods**.

**Ideal For**: Consultants preparing client demonstrations, pre-sales engineers validating Purview discovery capabilities, IT professionals learning classification and search workflows, compliance teams comparing discovery methods before production deployment.

**Not Suitable For**: Custom SIT development, DLP policy implementation, advanced retention lifecycle management, or production compliance configurations requiring custom pattern development.

**Complementary Projects**: For hybrid on-premises/cloud scenarios, see [Purview-Skills-Ramp-OnPrem-and-Cloud](../Purview-Skills-Ramp-OnPrem-and-Cloud/).

---

## 🎓 Skills Development Analysis

### Core Competencies Developed

| Skill Area | Labs | Proficiency Level |
|------------|------|-------------------|
| **Microsoft Purview Configuration** | 00, 01, 04, 05 | Intermediate to Advanced |
| **PowerShell Automation** | All Labs | Intermediate to Advanced |
| **Microsoft Graph API Integration** | 05c | Intermediate |
| **SharePoint Administration** | 01, 03, 07 | Intermediate |
| **PII Data Generation** | 02 | Foundational |
| **Classification Workflows** | 04 | Intermediate to Advanced |
| **Data Discovery Methods** | 05a, 05b, 05c | Advanced |
| **eDiscovery Compliance Search** | 05b | Advanced |
| **Compliance Reporting** | 06 | Intermediate |
| **Environment Portability** | 00, 07 | Advanced |

### Microsoft Learn Alignment

This project complements official Microsoft Learn paths:

- **[Microsoft Purview Information Protection](https://learn.microsoft.com/en-us/training/paths/purview-information-protection/)** - Classification and sensitivity labels
- **[Data Loss Prevention in Microsoft 365](https://learn.microsoft.com/en-us/training/modules/m365-compliance-information-prevent-data-loss/)** - DLP policy creation and monitoring
- **[Manage Microsoft Purview](https://learn.microsoft.com/en-us/training/paths/manage-microsoft-purview/)** - Governance and compliance management

### Progressive Learning Path

**Beginner → Intermediate**: Start with this project's **Small scale** simulation to understand core Purview workflows, then explore:

- **[Purview-Skills-Ramp-OnPrem-and-Cloud](../Purview-Skills-Ramp-OnPrem-and-Cloud/)** for on-premises scanner deployment

**Intermediate → Advanced**: Complete this project's **Large scale** simulation, then advance to:

- Custom SIT development (regex patterns, EDM)
- Hybrid scanning scenarios (on-prem + cloud) via Skills-Ramp project
- Production automation with PowerShell at scale

---

---

## 🚀 Quick Start

**Complete simulation in 5 steps:**

1. **Configure**: Update `global-config.json` with your tenant information (see [Lab 00](./00-Prerequisites-Setup/)).
2. **Validate Environment**: Run `.\00-Prerequisites-Setup\Test-Prerequisites.ps1`.
3. **Create Sites**: Run `.\01-SharePoint-Site-Creation\New-SimulatedSharePointSites.ps1 -SkipExisting`.
4. **Generate & Upload Documents**: Execute Labs 02-03 scripts in sequence.
5. **Execute Classification & Discovery**: Complete Labs 04-05 (7-day classification, then choose discovery path based on timing needs).

**Full Sequential Execution** (copy-paste for complete simulation):

```powershell
# Lab 00: Validate prerequisites
.\00-Prerequisites-Setup\Test-Prerequisites.ps1

# Lab 01: Create SharePoint sites  
.\01-SharePoint-Site-Creation\New-SimulatedSharePointSites.ps1 -SkipExisting

# Lab 02: Generate test documents
.\02-Test-Data-Generation\New-TestDocuments.ps1

# Lab 03: Upload to SharePoint
.\03-Document-Upload-Distribution\Upload-DocumentsToSharePoint.ps1

# Lab 04: On-Demand Classification (up to 7 days for completion)
# Portal: purview.microsoft.com > Data loss prevention > Classifiers > On-demand classification
# Create scan > Review estimation > Start classification

# Lab 05a: Immediate discovery (regex-based, 70-90% accuracy)
.\05-Data-Discovery-Paths\05a-PnP-Direct-Discovery\scripts\Search-SensitiveData.ps1

# Lab 05b: eDiscovery (wait 24 hours after Lab 03 for SharePoint Search index)
.\05-Data-Discovery-Paths\05b-eDiscovery-Compliance-Search\scripts\Test-ContentIndexingStatus.ps1
# Portal: purview.microsoft.com > eDiscovery > Cases (preview) > Create search

# Lab 05c: Graph API Discovery (wait 24 hours after Lab 03 for SharePoint Search index)
# See Lab 05 overview for decision guide on which path to use

# Lab 05: Discover sensitive data across sites (multiple paths available)
# Choose one or more discovery methods based on timing needs

# Lab 06: Cleanup (when ready to remove all simulation resources)
.\06-Cleanup-Reset\scripts\Reset-Environment.ps1 -FullReset -Confirm:$false
```

> **💡 Best Practice**: Start with **Small scale** (1,000 documents) for testing, then scale up to Medium or Large for demonstrations.

---

## 🎯 Simulation Scale Levels

Choose your simulation scale in `global-config.json` based on testing vs demonstration needs:

| Scale | Documents | Sites | Generation Time | Upload Time | Classification Time | Storage | Use Case |
|-------|-----------|-------|-----------------|-------------|---------------------|---------|----------|
| **Small** | 500-1,000 | 5 | 5-10 min | 20-40 min | 15-30 min | 100 MB - 1 GB | Testing, POCs, Quick Demos |
| **Medium** | 5,000 | 10-15 | 45-60 min | 1.5-2 hours | 2-3 hours | 3-5 GB | Standard Demos, Training |
| **Large** | 20,000 | 20-25 | 1-2 hours | 3-5 hours | 4-6 hours | 10-15 GB | Enterprise Scale Demos |

**Recommendation**: Start with Small for initial testing, validate workflows work correctly, then scale up for demonstrations.

---

## 📁 Project Structure

```text
Purview-Data-Governance-Simulation/
├── 00-Prerequisites-Setup/        # Environment validation and configuration
├── 01-SharePoint-Site-Creation/   # SharePoint site provisioning
├── 02-Test-Data-Generation/       # PII document generation
├── 03-Document-Upload-Distribution/ # Document upload and metadata
├── 04-Classification-Validation/  # On-Demand Classification and validation
├── 05-Data-Discovery-Paths/       # Data discovery and reporting
├── 06-Cleanup-Reset/              # Environment cleanup and reset
├── global-config.json             # Single source of truth for configuration
├── global-config.json.template    # Pristine template for reset operations
├── README.md                      # This file
└── Documentation/                 # Technical documentation
    ├── AUTHENTICATION-STANDARDIZATION.md # Browser-based auth patterns
    ├── IMPLEMENTATION-STATUS.md          # Current project status
    ├── PORTABILITY-GUIDE.md              # Multi-tenant migration guide
    └── PROJECT-FLOW-ANALYSIS.md          # Dependency and timeline analysis
```

**Prerequisites**: M365 E5 licensing, PowerShell modules, admin permissions. See [Lab 00: Prerequisites Setup](./00-Prerequisites-Setup/) for complete requirements.

---

## 💼 Professional Skills You'll Gain

Completing this project demonstrates proficiency in the following industry-recognized Microsoft Purview skills, formatted for LinkedIn profiles, resumes, and corporate workforce development systems:

### Core Technical Competencies

**Microsoft Purview Configuration & Administration:**

- Built-in Sensitive Information Types (SIT) deployment and validation (100% accuracy).
- On-Demand Classification workflow execution with estimation and cost analysis (7-day processing).
- Modern eDiscovery portal operations (purview.microsoft.com, Cases preview, Condition builder).
- Content Explorer proficiency for classification validation (7-day update timing).
- Three discovery method implementations (immediate regex, 24hr eDiscovery, 24hr APIs).
- SharePoint Online data governance and compliance management.
- Purview Information Protection configuration and lifecycle management.

**Automation & Scripting:**

- PowerShell automation for Purview simulation workflows.
- Microsoft Graph PowerShell SDK for tenant-wide discovery automation (OAuth 2.0, delegated permissions).
- PnP PowerShell for SharePoint bulk operations and document management.
- Automated document generation with realistic PII patterns.
- Configuration-driven deployment patterns for environment portability.
- Modern authentication implementation (interactive browser-based, OAuth 2.0, no service principals required).

**Testing & Validation:**

- Synthetic PII data generation for compliance testing.
- Classification accuracy validation and coverage analysis (100% Purview SIT accuracy).
- Discovery method comparison and effectiveness analysis (regex vs official Purview SITs).
- SharePoint Search indexing status validation and readiness checks.
- Multi-method discovery results comparison (immediate, 24hr timelines).
- Compliance monitoring dashboard development.
- Executive-level reporting for data governance metrics.

### Business & Compliance Competencies

**Data Governance & Compliance:**

- Data classification strategy implementation (7-day On-Demand Classification).
- Discovery method selection and timing strategy (immediate vs 24hr vs 7-14 day).
- eDiscovery compliance search execution and analysis.
- Automated discovery workflows with Microsoft Graph API.
- Purview simulation environments for POC and demonstrations.
- Data discovery validation workflows across multiple methods.

**Project & Process Management:**

- Configuration management best practices (single source of truth patterns).
- Environment portability strategies for multi-tenant deployments.
- Simulation-to-production workflow design.
- Technical documentation and operational procedures.
- Repeatable demonstration environments for stakeholder presentations.

### Advanced Specializations

**Environment Architecture:**

- Configuration-driven infrastructure design (zero hardcoded values).
- Multi-tenant simulation portability patterns.
- Consultant-friendly deployment frameworks.
- Template-based environment reset and cleanup procedures.
- Scalable simulation architectures (Small/Medium/Large scale levels).

**Demonstration & Enablement:**

- POC environment rapid deployment (4-6 hours Small scale).
- Enterprise-scale demonstrations (20,000 documents, multiple sites).
- Stakeholder presentation preparation and validation.
- Training environment setup for compliance teams.

### Relevant Certifications & Career Paths

This project provides hands-on experience aligned with:

- **Microsoft Certified: Information Protection and Compliance Administrator Associate** (SC-400).
- **Microsoft Certified: Security, Compliance, and Identity Fundamentals** (SC-900).
- Roles: Compliance Administrator, Data Governance Analyst, Purview Consultant, Microsoft 365 Administrator, Pre-Sales Engineer (Microsoft Purview demonstrations).

### LinkedIn Skills Keywords

For maximum visibility on LinkedIn and applicant tracking systems (ATS), this project covers:

`Microsoft Purview` • `Information Protection` • `Data Classification` • `Built-In SITs` • `On-Demand Classification` • `Content Explorer` • `eDiscovery` • `Compliance Search` • `Data Discovery` • `Microsoft Graph API` • `Microsoft Graph PowerShell SDK` • `Compliance Management` • `Microsoft 365 Administration` • `SharePoint Online` • `PowerShell Scripting` • `PnP PowerShell` • `API Integration` • `OAuth 2.0 Authentication` • `Data Governance` • `Discovery Automation` • `Compliance Reporting` • `Compliance Testing` • `Simulation Environments` • `POC Development` • `Configuration Management` • `Modern Authentication` • `Technical Documentation` • `Demonstration Environments`

---

## 🔧 Configuration Management

The `global-config.json` file is the **single source of truth** for all environment-specific values. Complete configuration documentation is in **[Lab 00: Prerequisites Setup](./00-Prerequisites-Setup/)**.

**Key Sections**: Environment (tenant URLs), Simulation (scale level), SharePointSites (site definitions), BuiltInSITs (SIT selections), DocumentGeneration (counts, file types, PII density), Paths (directories), Logging (levels, retention).

> **✅ Critical**: Update `global-config.json` with your tenant details BEFORE running any lab scripts.
---

## 🌐 Environment Portability

**Zero hardcoded values** • **One-file migration** • **Multi-tenant ready** • **Dev/Test/Prod support**

Change `global-config.json` only → Scripts work in new environment automatically. Ideal for consultants maintaining multiple client configurations.

---

## 🔐 Authentication

**Browser-based authentication** (no secrets, certificates, or app registrations required):

- **SharePoint**: `Connect-PnPOnline -Interactive`
- **Security & Compliance**: `Connect-IPPSSession`

Eliminates complex service principal configuration.

---

## 📊 Built-In Sensitive Information Types

**Personal**: SSN, Passport, Driver's License, ITIN  
**Financial**: Credit Cards, Bank Accounts, ABA Routing Numbers

Built-in SITs are immediately available in any M365 E5 tenant.

---

## 📚 Additional Resources

**Microsoft Documentation**: [Purview Overview](https://learn.microsoft.com/en-us/purview/) • [SIT Reference](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions) • [DLP Policies](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp)

**PowerShell Modules**: [PnP PowerShell](https://pnp.github.io/powershell/) • [Exchange Online Management](https://learn.microsoft.com/en-us/powershell/exchange/)

**Related Projects**: [Skills-Ramp-OnPrem-and-Cloud](../Purview-Skills-Ramp-OnPrem-and-Cloud/) (hybrid scanning)

**Repository Style-Guides**: [PowerShell](../../../Repository-Management/Style-Guides/powershell-style-guide.md) • [Markdown](../../../Repository-Management/Style-Guides/markdown-style-guide.md) • [Parameters](../../../Repository-Management/Style-Guides/parameters-file-style-guide.md)

**Advanced Scenarios**: [Future Enhancements & Integrations](FUTURE-ENHANCEMENTS.md) - Enterprise integrations (SIEM, ITSM, AI/ML), operational automation, compliance extensions, and advanced analytics beyond core simulation capabilities

---

## ⚠️ Important Considerations

**Resource Management**: Storage 100 MB - 15 GB • Cleanup critical • Template restoration via `global-config.json.template`

**Performance**: Start Small scale • Throttling automatic (600 req/min) • Classification 15 min - 6 hours • Background processing

**Security**: Test environments only • Browser auth • Global Admin + Compliance Admin required • Synthetic PII patterns

---

## 🤝 Contributing

Contributions welcome! Follow repository style guides (PowerShell, Markdown, Parameters) • Configuration-driven architecture • Comprehensive error handling and logging.

---

## 📄 License

This project is part of the Projects repository demonstrating Microsoft Purview capabilities.

## 🤖 AI-Assisted Content Generation

This comprehensive Purview Discovery Methods Simulation project was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, configuration architecture, and documentation were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview Information Protection best practices, browser-based authentication patterns, and enterprise-grade discovery methods simulation workflows.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Purview simulation requirements while maintaining technical accuracy and reflecting established repository standards for infrastructure automation and documentation quality.*

---

**Ready to simulate enterprise data governance?** Start with [Lab 00: Prerequisites Setup](00-Prerequisites-Setup/README.md)!
