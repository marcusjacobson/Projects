# Microsoft Purview Learning Labs

**Keywords:** Microsoft Purview, Data Governance, Information Protection, Data Loss Prevention (DLP), eDiscovery, Compliance, Data Classification, Sensitivity Labels, Retention Policies, PowerShell Automation.

## 🎯 Overview

This directory contains **three comprehensive hands-on lab projects** designed to build practical Microsoft Purview expertise across different capability areas. Together, these projects provide **70-80% coverage** of the Microsoft Purview capability landscape with deep, hands-on implementation experience.

**Combined Learning Value**: 30-40 hours of hands-on lab work covering on-premises scanning, cloud governance, data classification, retention management, discovery automation, and production workflows.

---

## 📚 Project Portfolio

### [Purview Data Governance Simulation](./Purview-Data-Governance-Simulation/)

**Focus**: Data discovery automation with four discovery methods, modern eDiscovery portal, and API integration

**Target Audience**: Consultants, pre-sales engineers, compliance teams comparing discovery methods and building POC demonstrations

**Duration**: 4-6 hours initial setup | **Cost**: $0 (cloud-only, no Azure infrastructure)

**Key Capabilities**:

- Three discovery methods (immediate regex, 24hr eDiscovery, 24hr Graph API)
- Modern eDiscovery portal (purview.microsoft.com with Cases preview, Condition builder)
- Microsoft Graph API automation (OAuth 2.0, tenant-wide discovery, SIEM integration)
- On-Demand Classification (7-day portal-based with estimation and cost analysis)
- Content Explorer proficiency (classification validation with 7-day update timing)
- SharePoint indexing status validation (real-time readiness checks)
- Configuration-driven architecture (single JSON config, multi-tenant portability)
- Browser-based authentication (no secrets/certificates required)

**Learning Paths**:

- **Immediate Discovery** (Lab 05a): Regex-based detection for instant results
- **24-Hour Discovery** (Lab 05b): eDiscovery compliance search after SharePoint indexing
- **24-Hour API Discovery** (Lab 05c): Automated Graph API scanning after indexing
- **7-Day Classification** (Lab 04): On-Demand Classification with Content Explorer validation

**Coverage Depth**: ~45% of Purview landscape (discovery and classification focus)

---

### [Purview Skills Ramp - On-Premises & Cloud Scanning](./Purview-Skills-Ramp-OnPrem-and-Cloud/)

**Focus**: Hybrid data governance with Information Protection Scanner, DLP policies, and retention labels

**Target Audience**: IT professionals implementing Purview across on-premises file shares, Azure Files, and SharePoint Online

**Duration**: 19.5-26.5 hours | **Cost**: $10-140 (Azure VM billing)

**Key Capabilities**:

- Information Protection Scanner deployment (on-prem/Azure Files)
- DLP policy configuration and enforcement
- Retention labels with last access time triggers (SharePoint Online)
- Activity Explorer cross-platform analysis
- Advanced remediation workflows (PnP PowerShell)
- Custom classification (regex SITs, trainable classifiers)

**Learning Paths**:

- **Accelerated** (2-3 days): Hands-on configuration only
- **Full Functional** (1-2 weeks): Complete with policy activation
- **Production Deployment** (2-4 weeks): Enterprise-ready with automation

**Coverage Depth**: ~48% of Purview landscape

---

### [Purview Classification & Lifecycle Labs](./Purview-Classification-Lifecycle-Labs-UNDER-CONSTRUCTION/)

**Focus**: Deep classification expertise with custom SITs, EDM, and lifecycle automation

**Target Audience**: Compliance administrators building advanced classification and retention capabilities

**Duration**: 5.5-7.5 hours | **Cost**: $0 (cloud-only, no Azure infrastructure)

**Key Capabilities**:

- Custom Sensitive Information Types (regex patterns, confidence tuning)
- Exact Data Match (EDM) for structured data
- On-Demand Classification and Content Explorer
- Retention label lifecycle (simulation vs production modes)
- PowerShell automation (bulk operations, compliance searches, reporting)
- Operational runbooks and handoff procedures

**Learning Paths**:

- **Accelerated** (2-3 days): Simulation mode, complete technical learning
- **Production Deployment** (1-2 weeks): Fully activated retention labels

**Coverage Depth**: ~35% of Purview landscape

---

## 🎓 Recommended Learning Sequence

> **💡 Important Note**: All three projects are **designed to be completed independently** and do not require each other. Each project provides complete, standalone learning value within its focus area. The combined approaches below maximize the full Purview experience across hybrid, cloud, and discovery automation scenarios, though there will be some intentional overlap in foundational concepts that reinforces learning.

### For Complete Purview Mastery

**Full Sequential Approach** (6-8 weeks total, complexity-based progression):

1. **Weeks 1-2**: Complete Skills-Ramp Sections 1-2 (Setup + On-Prem Scanning)
   - Build Azure infrastructure fundamentals
   - Deploy Information Protection Scanner
   - Configure DLP policies for file shares
   - Master hybrid identity management
   - Learn policy sync and enforcement validation

2. **Weeks 2-3**: Complete Skills-Ramp Section 3 (Cloud Scanning)
   - Extend to SharePoint Online governance
   - Implement retention labels with last access triggers
   - Execute eDiscovery searches
   - Build cross-platform DLP monitoring

3. **Weeks 3-4**: Complete Classification-Lifecycle Labs 0-6
   - Master custom SIT creation (regex patterns, confidence tuning)
   - Learn Exact Data Match (EDM) for structured data
   - Implement retention label lifecycle (simulation → production)
   - Build PowerShell automation scripts
   - Create operational runbooks and handoff procedures

4. **Weeks 4-5**: Complete Skills-Ramp Supplemental Labs
   - Advanced remediation workflows (multi-tier severity)
   - Trainable classifiers (ML-based, 24hr training)
   - Activity Explorer and Content Explorer mastery
   - Production-grade automation frameworks

5. **Weeks 5-6**: Complete Data-Governance-Simulation Labs 00-03 (Setup + Document Upload)
   - Apply SharePoint governance expertise
   - Execute large-scale document ingestion (5000 files, 5-25 sites)
   - Master PnP PowerShell bulk operations
   - Build realistic multi-site PII test environment

6. **Weeks 6-7**: Complete Data-Governance-Simulation Labs 04-05 (Classification + Discovery)
   - Start 7-day On-Demand Classification with cost estimation
   - Compare discovery methods (immediate regex vs 24hr eDiscovery vs 24hr Graph API)
   - Execute immediate regex discovery (Lab 05a)
   - Run 24-hour modern eDiscovery searches (Lab 05b)
   - Validate timing and accuracy tradeoffs

7. **Weeks 7-8**: Complete Data-Governance-Simulation Lab 05c (API Discovery)
   - Microsoft Graph API automated discovery (OAuth 2.0, delegated permissions)
   - Build recurring discovery automation for SIEM integration
   - Master API-based compliance workflows

**Combined Total**: 30-40 hours active work | **Cost**: $10-140

**Expected Overlap Areas** (reinforces learning):

- On-Demand Classification and Content Explorer
- eDiscovery and compliance searches
- Security & Compliance PowerShell cmdlets
- SharePoint Online governance concepts
- PnP PowerShell operations

**Unique Value from Combined Approach**:

- Comprehensive classification expertise (built-in SITs → custom regex → EDM → trainable classifiers)
- Multiple discovery methods (immediate → 24hr → 7-day classification → APIs)
- Hybrid deployment experience (on-premises scanner + cloud governance)
- Complete lifecycle understanding (policy creation → enforcement → monitoring → remediation)
- API integration proficiency (Microsoft Graph, OAuth 2.0)

---

## 📊 Comprehensive Microsoft Purview Capability Coverage

### Coverage Matrix: Three-Project Comparison

This matrix shows which project covers each Purview capability, with specific lab references.

#### ✅ Information Protection & Data Classification

| Capability | Complexity | Skills-Ramp Coverage | Classification-Lifecycle Coverage | Data-Governance-Simulation Coverage | Combined Status |
|------------|------------|---------------------|----------------------------------|-------------------------------------|-----------------|
| **Information Protection Scanner** | INTERMEDIATE | ✅ OnPrem-01, OnPrem-02 (deployment, discovery scans) | Not covered | Not covered | ✅ EXTENSIVE |
| **Built-in SITs** | BASIC | ✅ OnPrem-02, OnPrem-03, OnPrem-04 (DLP policies) | Not covered | ✅ Labs 02/05 (generation & discovery) | ✅ EXTENSIVE |
| **Custom SITs (Regex)** | INTERMEDIATE | ✅ Supplemental: Custom-Classification (Boost.RegEx patterns) | ✅ Lab 1 (7 exercises, confidence tuning 85%/75%/65%) | ✅ Lab 05a (scripted regex discovery) | ✅ COMPREHENSIVE |
| **Exact Data Match (EDM)** | ADVANCED | Not covered | ✅ Lab 2 (8 exercises, schema, hashing, upload) | Not covered | ✅ COMPREHENSIVE |
| **Trainable Classifiers (ML)** | EXPERT | ✅ Supplemental: Custom-Classification (300 samples, 24hr training) | Not covered | Not covered | ✅ COMPREHENSIVE |
| **Activity Explorer** | INTERMEDIATE | ✅ Supplemental: Advanced-Cross-Platform-SIT-Analysis (trending, dashboards) | Not covered | Not covered | ✅ EXTENSIVE |
| **Content Explorer** | INTERMEDIATE | ✅ Supplemental: Advanced-SharePoint-SIT-Analysis (reporting, exports) | ✅ Lab 3 (classification validation) | ✅ Lab 04 (7-day portal validation) | ✅ COMPREHENSIVE |
| **On-Demand Classification** | INTERMEDIATE | ✅ Supplemental: Advanced-SharePoint-SIT-Analysis (SharePoint re-indexing) | ✅ Lab 3 (manual triggers, validation) | ✅ Lab 04 (7-day portal-based, estimation) | ✅ COMPREHENSIVE |
| **eDiscovery Compliance Search** | INTERMEDIATE | ✅ Cloud-04 (KQL queries) | Not covered | ✅ Lab 05b (24hr modern portal, Cases preview) | ✅ COMPREHENSIVE |
| **Modern eDiscovery Portal** | INTERMEDIATE | Not covered | Not covered | ✅ Lab 05b (purview.microsoft.com, Condition builder) | ✅ COMPREHENSIVE |
| **Discovery Method Comparison** | INTERMEDIATE | Not covered | Not covered | ✅ Lab 05 overview (timing/accuracy matrix) | ✅ COMPREHENSIVE |
| **Keyword Dictionaries** | BASIC | Not covered | ✅ Lab 1 (context-aware detection) | Not covered | ✅ DETAILED |
| **SIT Confidence Tuning** | INTERMEDIATE | Not covered | ✅ Lab 1 (High/Medium/Low scoring) | Not covered | ✅ DETAILED |
| **EDM Schema Design** | ADVANCED | Not covered | ✅ Lab 2 (multi-field searchable schemas) | Not covered | ✅ COMPREHENSIVE |
| **EdmUploadAgent.exe** | ADVANCED | Not covered | ✅ Lab 2 (hash generation, secure upload) | Not covered | ✅ COMPREHENSIVE |

#### ✅ Data Loss Prevention (DLP)

| Capability | Complexity | Skills-Ramp Coverage | Classification-Lifecycle Coverage | Data-Governance-Simulation Coverage | Combined Status |
|------------|------------|---------------------|----------------------------------|-------------------------------------|-----------------|
| **DLP Policies (On-Premises)** | INTERMEDIATE | ✅ OnPrem-03, OnPrem-04 (file share enforcement) | Not covered | Not covered | ✅ EXTENSIVE |
| **DLP Policies (SharePoint Online)** | INTERMEDIATE | ✅ Supplemental: Advanced-SharePoint-SIT-Analysis (real-time protection) | Not covered | Not covered | ✅ EXTENSIVE |
| **DLP Policy Sync & Enforcement** | INTERMEDIATE | ✅ OnPrem-04 (1-2 hour sync validation) | Not covered | Not covered | ✅ COMPREHENSIVE |
| **DLP Reporting & Monitoring** | INTERMEDIATE | ✅ Supplemental: Advanced-Cross-Platform-SIT-Analysis (cross-platform metrics) | Not covered | Not covered | ✅ COMPREHENSIVE |
| **DLP Policies (Endpoint/Email/Teams)** | ADVANCED | Not covered | Not covered | Not covered | ❌ Not Covered |
| **Cloud App DLP (non-Microsoft)** | ADVANCED | Not covered | Not covered | Not covered | ❌ Not Covered |
| **DLP for Power Platform** | ADVANCED | Not covered | Not covered | Not covered | ❌ Not Covered |

> **💡 Note**: Data-Governance-Simulation focuses on **discovery** methods (finding sensitive data) rather than **prevention** (DLP policies). For comprehensive DLP coverage, see Skills-Ramp project.

#### ✅ Data Lifecycle Management & Retention

| Capability | Complexity | Skills-Ramp Coverage | Classification-Lifecycle Coverage | Data-Governance-Simulation Coverage | Combined Status |
|------------|------------|---------------------|----------------------------------|-------------------------------------|-----------------|
| **Retention Labels** | INTERMEDIATE | ✅ Cloud-02 (creation, configuration) | ✅ Lab 0, Lab 4 (initialization, enhancement) | Not covered | ✅ COMPREHENSIVE |
| **Auto-Apply Policies** | INTERMEDIATE | ✅ Cloud-03 (SIT-based triggers) | ✅ Lab 4 (SIT-based, policy config) | Not covered | ✅ COMPREHENSIVE |
| **Last Access Time Retention** | INTERMEDIATE | ✅ Cloud-02 (SharePoint-specific trigger) | Not covered | Not covered | ✅ DETAILED |
| **Retention Simulation Mode** | INTERMEDIATE | ✅ Cloud-02, Cloud-03 (1-2 day validation) | ✅ Lab 4 (accelerated validation) | Not covered | ✅ DETAILED |
| **Retention Production Mode** | INTERMEDIATE | ✅ Cloud-02, Cloud-03 (7-day activation) | ✅ Lab 4 (production timeline) | Not covered | ✅ DETAILED |
| **Label Lifecycle Management** | INTERMEDIATE | ✅ Cloud-02 (creation to enforcement) | ✅ Lab 4 (enhancement, monitoring) | Not covered | ✅ EXTENSIVE |
| **Policy Adoption Monitoring** | INTERMEDIATE | Not covered | ✅ Lab 5 (coverage metrics, reporting) | Not covered | ✅ COMPREHENSIVE |
| **File Plan Descriptors** | INTERMEDIATE | Not covered | Not covered | Not covered | ❌ Not Covered |
| **Disposition Reviews** | INTERMEDIATE | Not covered | Not covered | Not covered | ❌ Not Covered |
| **Event-based Retention** | INTERMEDIATE | Not covered | Not covered | Not covered | ❌ Not Covered |
| **Regulatory Records** | INTERMEDIATE | Not covered | Not covered | Not covered | ❌ Not Covered |

#### ✅ eDiscovery & Legal

| Capability | Complexity | Skills-Ramp Coverage | Classification-Lifecycle Coverage | Data-Governance-Simulation Coverage | Combined Status |
|------------|------------|---------------------|----------------------------------|-------------------------------------|-----------------|
| **Content Search (Basic)** | INTERMEDIATE | ✅ Cloud-04 (KQL queries, exports) | Not covered | ✅ Lab 05b (24hr modern Cases preview) | ✅ COMPREHENSIVE |
| **KQL Query Language** | INTERMEDIATE | ✅ Cloud-04 (SIT-based discovery) | ✅ Lab 5 (compliance searches) | ✅ Lab 05b (Condition builder, metadata) | ✅ COMPREHENSIVE |
| **eDiscovery Export** | INTERMEDIATE | ✅ Cloud-04 (legal export workflows) | Not covered | ✅ Lab 05b (PST export, reporting) | ✅ COMPREHENSIVE |
| **Discovery Automation** | INTERMEDIATE | Not covered | Not covered | ✅ Lab 05c (API-based, scheduled) | ✅ COMPREHENSIVE |
| **eDiscovery (Premium)** | ADVANCED | Not covered | Not covered | Not covered | ❌ Not Covered |
| **Legal Hold** | INTERMEDIATE | Not covered | Not covered | Not covered | ❌ Not Covered |
| **Custodian Management** | ADVANCED | Not covered | Not covered | Not covered | ❌ Not Covered |

> **💡 Note**: Data-Governance-Simulation covers **eDiscovery (Basic)** comprehensively via Lab 05b modern portal. eDiscovery (Premium) features (custodians, review sets, advanced analytics) are not covered in any project.

#### ✅ SharePoint Online Governance

| Capability | Complexity | Skills-Ramp Coverage | Classification-Lifecycle Coverage | Data-Governance-Simulation Coverage | Combined Status |
|------------|------------|---------------------|----------------------------------|-------------------------------------|-----------------|
| **SharePoint Site Configuration** | BASIC | ✅ Cloud-01 (test site creation) | ✅ Lab 0 (Communication Site) | ✅ Lab 01 (5-25 Communication Sites) | ✅ COMPREHENSIVE |
| **Document Upload & Management** | BASIC | ✅ Cloud-01 (sample documents) | ✅ Lab 0 (sample data preparation) | ✅ Lab 03 (5000 bulk documents, PnP) | ✅ COMPREHENSIVE |
| **Bulk Document Upload** | INTERMEDIATE | Not covered | Not covered | ✅ Lab 03 (5000 files, PnP PowerShell) | ✅ COMPREHENSIVE |
| **Indexing Status Validation** | INTERMEDIATE | Not covered | Not covered | ✅ Lab 05b (Test-ContentIndexingStatus.ps1) | ✅ COMPREHENSIVE |
| **On-Demand Classification Triggers** | INTERMEDIATE | ✅ Supplemental: Advanced-SharePoint-SIT-Analysis | ✅ Lab 3 (manual re-indexing) | ✅ Lab 04 (7-day portal-based) | ✅ COMPREHENSIVE |
| **Classification Validation** | INTERMEDIATE | ✅ Cloud-01, Supplemental labs (Content Explorer) | ✅ Lab 3 (validation workflows) | ✅ Lab 04 (Content Explorer, 7-day) | ✅ COMPREHENSIVE |

#### ✅ Automation & Scripting

| Capability | Complexity | Skills-Ramp Coverage | Classification-Lifecycle Coverage | Data-Governance-Simulation Coverage | Combined Status |
|------------|------------|---------------------|----------------------------------|-------------------------------------|-----------------|
| **Security & Compliance PowerShell** | INTERMEDIATE | ✅ All sections (cmdlet operations) | ✅ Labs 0-5 (all operations) | ✅ Labs 04/05a (discovery operations) | ✅ COMPREHENSIVE |
| **PnP PowerShell** | INTERMEDIATE | ✅ Supplemental: Advanced-Remediation (bulk operations) | Not covered | ✅ Labs 01/03/05a (site creation, bulk upload) | ✅ COMPREHENSIVE |
| **Microsoft Graph PowerShell SDK** | INTERMEDIATE | Not covered | Not covered | ✅ Lab 05c (OAuth 2.0, delegated permissions) | ✅ EXTENSIVE |
| **Discovery Automation** | INTERMEDIATE | Not covered | Not covered | ✅ Lab 05c (scheduled scans, SIEM) | ✅ COMPREHENSIVE |
| **Azure CLI** | BASIC | ✅ Setup-02 (infrastructure deployment) | Not covered | Not covered | ✅ COMPREHENSIVE |
| **Bicep IaC** | INTERMEDIATE | ✅ Setup-02 (Azure resource provisioning) | Not covered | Not covered | ✅ COMPREHENSIVE |
| **Compliance Content Searches** | INTERMEDIATE | ✅ Cloud-04 (KQL-based searches) | ✅ Lab 5 (parameterized queries) | ✅ Lab 05b (modern portal, Cases) | ✅ COMPREHENSIVE |
| **Bulk Operations (Deletion)** | INTERMEDIATE | ✅ Supplemental: Advanced-Remediation (deduplication, tombstones) | ✅ Lab 5 (audit trails, error handling) | Not covered | ✅ COMPREHENSIVE |
| **Bulk Label Application** | INTERMEDIATE | Not covered | ✅ Lab 5 (multi-site scaling) | Not covered | ✅ COMPREHENSIVE |
| **Policy Monitoring Scripts** | INTERMEDIATE | Not covered | ✅ Lab 5 (coverage dashboards) | Not covered | ✅ EXTENSIVE |
| **Compliance Reporting** | INTERMEDIATE | ✅ Supplemental: Advanced-Cross-Platform-SIT-Analysis (executive reports) | ✅ Lab 5 (stakeholder reporting) | ✅ Labs 05a/c (CSV discovery reports) | ✅ COMPREHENSIVE |
| **REST API Integration** | ADVANCED | ✅ Supplemental: Advanced-Remediation (Azure Resource Management) | Not covered | ✅ Lab 05c (Graph API) | ✅ COMPREHENSIVE |
| **Configuration-Driven Architecture** | INTERMEDIATE | Not covered | Not covered | ✅ All Labs (single JSON config) | ✅ DETAILED |
| **Browser-Based Authentication** | INTERMEDIATE | Not covered | Not covered | ✅ All Labs (no secrets required) | ✅ DETAILED |

#### ✅ Azure & Cloud Infrastructure

| Capability | Complexity | Skills-Ramp Coverage | Classification-Lifecycle Coverage | Data-Governance-Simulation Coverage | Combined Status |
|------------|------------|---------------------|----------------------------------|-------------------------------------|-----------------|
| **Azure VM Deployment** | INTERMEDIATE | ✅ Setup-02 (Windows Server, SQL Express) | Not covered | Not covered | ✅ COMPREHENSIVE |
| **Azure Resource Management** | INTERMEDIATE | ✅ Setup-02 (resource groups, RBAC) | Not covered | Not covered | ✅ COMPREHENSIVE |
| **Azure Files Integration** | INTERMEDIATE | ✅ OnPrem-02 (scanner repository) | Not covered | Not covered | ✅ COMPREHENSIVE |
| **Microsoft Entra ID (Azure AD)** | INTERMEDIATE | ✅ Setup-03 (service accounts, app registration) | ✅ Labs 0-5 (authentication, permissions) | ✅ Lab 05c (OAuth 2.0, delegated permissions) | ✅ COMPREHENSIVE |
| **Hybrid Identity Management** | INTERMEDIATE | ✅ Setup-01, Setup-03 (on-prem + cloud) | Not covered | Not covered | ✅ DETAILED |

#### ✅ Operational Documentation & Runbooks

| Capability | Complexity | Skills-Ramp Coverage | Classification-Lifecycle Coverage | Data-Governance-Simulation Coverage | Combined Status |
|------------|------------|---------------------|----------------------------------|-------------------------------------|-----------------|
| **Production Deployment Runbooks** | INTERMEDIATE | Integrated throughout all sections | ✅ Lab 6 (end-to-end procedures) | Not covered | ✅ EXTENSIVE |
| **Classification Workflow Docs** | INTERMEDIATE | ✅ Supplemental labs (operational guides) | ✅ Lab 6 (best practices) | ✅ Labs 04/05 (discovery workflows) | ✅ COMPREHENSIVE |
| **Troubleshooting Knowledge Base** | INTERMEDIATE | Each lab includes troubleshooting | ✅ Lab 6 (common scenarios, resolutions) | Each lab includes troubleshooting | ✅ COMPREHENSIVE |
| **Operational Handoff Procedures** | INTERMEDIATE | ✅ Environment cleanup guide | ✅ Lab 6 (IT support enablement) | Not covered | ✅ COMPREHENSIVE |

#### ✅ Advanced Production Workflows

| Capability | Complexity | Skills-Ramp Coverage | Classification-Lifecycle Coverage | Data-Governance-Simulation Coverage | Combined Status |
|------------|------------|---------------------|----------------------------------|-------------------------------------|-----------------|
| **Production Remediation Workflows** | ADVANCED | ✅ Supplemental: Advanced-Remediation (multi-tier severity) | Not covered | Not covered | ✅ EXTENSIVE |
| **Dual-source Deduplication** | ADVANCED | ✅ Supplemental: Advanced-Remediation (Activity + Content Explorer) | Not covered | Not covered | ✅ DETAILED |
| **Progress Tracking Dashboards** | INTERMEDIATE | ✅ Supplemental: Advanced-Remediation (CSV tracking) | Not covered | Not covered | ✅ DETAILED |

### ❌ Capabilities NOT Covered in Any Project

The following capabilities require **enterprise-scale deployments**, **advanced licensing**, or **specialized infrastructure** beyond all three projects' scope:

#### Endpoint & Client Protection

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Endpoint DLP (Windows/macOS)** | ADVANCED | Requires device onboarding, client agent deployment beyond lab scope |
| **Cloud App DLP (non-Microsoft)** | ADVANCED | Requires Defender for Cloud Apps integration |
| **DLP for Power Platform** | ADVANCED | Requires Power Apps/Automate environment setup |
| **Mobile Device DLP (iOS/Android)** | ADVANCED | Requires Intune integration and device enrollment |

#### Advanced Encryption & Key Management

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Sensitivity Labels (Encryption)** | INTERMEDIATE | Visual markings/encryption not core to classification-focused projects |
| **Double Key Encryption** | EXPERT | Requires external key server, complex PKI infrastructure |
| **Customer Key** | EXPERT | Tenant-level encryption keys, enterprise-only feature |
| **Azure Information Protection (Unified Labels)** | INTERMEDIATE | Overlaps with classification focus, limited additional value |

#### Advanced Records Management

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **File Plan Descriptors** | INTERMEDIATE | Advanced records metadata beyond basic retention scope |
| **Disposition Reviews** | INTERMEDIATE | Manual approval workflows require workflow setup |
| **Multi-stage Disposition** | ADVANCED | Complex approval chains not implemented |
| **Event-based Retention** | INTERMEDIATE | Custom event triggers require external integration |
| **Regulatory Records (Immutable)** | INTERMEDIATE | Regulatory records features require compliance framework |

#### Advanced eDiscovery & Legal

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **eDiscovery (Premium)** | ADVANCED | Custodian management, review sets, predictive coding require legal workflow beyond Basic eDiscovery covered in Data-Governance-Simulation Lab 05b |
| **Legal Hold Notifications** | ADVANCED | Custodian communication workflow beyond scope |
| **Advanced Indexing** | ADVANCED | Error remediation for partially indexed content not covered |
| **Conversation Threading** | ADVANCED | Email thread reconstruction requires eDiscovery Premium |

> **💡 Note**: Data-Governance-Simulation Lab 05b covers **eDiscovery (Basic)** comprehensively using the modern purview.microsoft.com portal with Cases preview, Condition builder, and KQL queries. eDiscovery (Premium) features are not covered.

#### Insider Risk & Behavioral Analytics

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Insider Risk Management** | EXPERT | ML-based user risk scoring, forensic evidence require separate deployment |
| **Communication Compliance** | EXPERT | Regulatory monitoring (SEC, FINRA) requires compliance workflow setup |
| **Adaptive Protection** | EXPERT | Dynamic risk-based DLP policy adjustment requires Insider Risk integration |
| **User Activity Analytics** | EXPERT | Behavioral analytics require extended data collection period |

#### Advanced Audit & Lifecycle

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Audit (Premium)** | INTERMEDIATE | Extended retention beyond 180 days not essential for learning |
| **Inactive Mailboxes** | INTERMEDIATE | Mailbox preservation after user departure not covered |
| **Archive Mailboxes** | BASIC | Additional mailbox storage not essential for labs |
| **PST Import Service** | INTERMEDIATE | Bulk PST file import not covered |

#### Advanced Governance & Collaboration

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Information Barriers** | ADVANCED | User segmentation policies (ethical walls) require org structure setup |
| **Privileged Access Management** | EXPERT | Just-in-time admin access beyond scope |
| **Container Labels (Teams/Groups/Sites)** | INTERMEDIATE | Teams/Groups/Sites sensitivity labels not covered |
| **Multi-Geo Capabilities** | ADVANCED | Cross-region data residency requires enterprise tenant |
| **Compliance Boundaries** | ADVANCED | Multi-geo eDiscovery constraints not covered |

---

## 🎯 Project Selection Guide

### Choose Skills-Ramp When You Need

- ✅ **Hybrid environment experience** (on-premises + cloud)
- ✅ **Information Protection Scanner expertise**
- ✅ **DLP policy implementation** (on-prem and SharePoint)
- ✅ **Azure infrastructure skills** (VM, Storage, RBAC)
- ✅ **Advanced remediation workflows** (production-grade automation)
- ✅ **Trainable classifiers** (ML-based classification)
- ✅ **Cross-platform analysis** (Activity Explorer proficiency)
- ✅ **Azure/Bicep IaC knowledge**

**Best For**: IT professionals deploying Purview across hybrid environments, consultants implementing enterprise projects, infrastructure-focused learners

---

### Choose Classification-Lifecycle When You Need

- ✅ **Deep classification expertise** (custom SITs, EDM)
- ✅ **Zero Azure costs** (cloud-only, no infrastructure)
- ✅ **Fast completion** (5.5-7.5 hours active work)
- ✅ **Retention label mastery** (simulation vs production modes)
- ✅ **PowerShell automation focus** (compliance operations)
- ✅ **Operational runbooks** (handoff documentation)
- ✅ **Optimized timing** (no active waiting periods)

**Best For**: Compliance administrators, classification specialists, learners wanting quick hands-on experience, organizations with M365 E5 only (no Azure subscription)

---

### Choose Data-Governance-Simulation When You Need

- ✅ **Discovery method comparison** (immediate, 24hr, API options)
- ✅ **Modern eDiscovery portal** (purview.microsoft.com, Cases preview)
- ✅ **API integration skills** (Microsoft Graph, SharePoint Search, OAuth 2.0)
- ✅ **Zero Azure costs** (cloud-only, no infrastructure)
- ✅ **Fast initial setup** (4-6 hours active work)
- ✅ **POC demonstration preparation** (consultant-friendly, repeatable)
- ✅ **Discovery automation** (scheduled scans, SIEM integration)
- ✅ **SharePoint indexing expertise** (timing validation, readiness checks)

**Best For**: Consultants building POC demonstrations, pre-sales engineers comparing discovery methods, compliance teams evaluating timing requirements, organizations with M365 E5 only (no Azure subscription)

---


### Complete All Three Projects When You Want

- ✅ **Comprehensive Purview expertise** (70-80% capability coverage)
- ✅ **Hybrid + cloud proficiency** (on-prem scanner + SharePoint governance)
- ✅ **Advanced classification skills** (built-in SITs, custom regex, EDM, trainable classifiers)
- ✅ **Multiple discovery methods** (immediate, 24hr, 7-day classification, APIs)
- ✅ **Production-ready workflows** (DLP enforcement, retention automation, remediation, API integration)
- ✅ **API integration expertise** (Microsoft Graph, SharePoint Search, OAuth 2.0)
- ✅ **Career advancement** (SC-400 certification preparation, comprehensive professional portfolio)
- ✅ **Enterprise deployment readiness** (complete operational knowledge)

**Best For**: Career-focused professionals, enterprise implementation teams, comprehensive learning programs, SC-400 exam preparation, full-stack Purview specialists

---

## 🚀 Getting Started

### Quick Navigation

**For Discovery Method Comparison & API Integration**:  
→ Start with [Purview Data Governance Simulation](./Purview-Data-Governance-Simulation/)

**For Hybrid Data Governance**:  
→ Start with [Purview Skills Ramp](./Purview-Skills-Ramp-OnPrem-and-Cloud/)

**For Classification & Lifecycle Expertise**:  
→ Start with [Purview Classification & Lifecycle Labs](./Purview-Classification-Lifecycle-Labs-UNDER-CONSTRUCTION/)

**For Complete Mastery**:  
→ Complete Data-Governance-Simulation Labs 00-05, then Skills-Ramp Sections 1-2, then Classification-Lifecycle Labs 0-6, then Skills-Ramp Section 3 + Supplemental Labs

---

## 💼 Professional Skills Development

### Combined Skills Portfolio

Completing all three projects demonstrates proficiency in:

**Core Technical Competencies**:

- Information Protection (scanner deployment, custom SITs, EDM, trainable classifiers)
- Data Discovery (three methods: immediate regex, 24hr eDiscovery, 24hr APIs)
- API Integration (Microsoft Graph, OAuth 2.0, SIEM connectivity)
- Modern eDiscovery Portal (purview.microsoft.com, Cases preview, Condition builder)
- Data Loss Prevention (policy design, enforcement, cross-platform monitoring)
- Data Lifecycle Management (retention labels, auto-apply policies, lifecycle triggers)
- Automation & Scripting (PowerShell, PnP, Microsoft Graph SDK, Azure CLI, Bicep IaC)
- Cloud & Hybrid Architecture (Azure, M365, hybrid identity)

**Business & Compliance Competencies**:

- Regulatory compliance and data governance
- Risk management and audit trail documentation
- Project management and change management
- Technical documentation and knowledge transfer

**Advanced Specializations**:

- Machine Learning (trainable classifiers, 24-hour model training)
- Data Analytics (pattern recognition, regex development, executive reporting)
- Enterprise Architecture (hybrid design, scalable automation frameworks)
- Production Operations (remediation workflows, deduplication, progress tracking)

### Certification Alignment

All three projects provide hands-on experience aligned with:

- **Microsoft Certified: Information Protection and Compliance Administrator Associate** (SC-400)
- **Microsoft Certified: Security, Compliance, and Identity Fundamentals** (SC-900)
- **Microsoft Certified: Azure Administrator Associate** (AZ-104) - Infrastructure components from Skills-Ramp

### Career Paths

**Roles supported by combined expertise**:

- Compliance Administrator
- Information Protection Specialist
- Data Governance Analyst
- Data Discovery Specialist
- Microsoft 365 Administrator
- Cloud Security Engineer
- Azure Administrator
- API Integration Engineer
- Purview Implementation Consultant

---

## 📊 Combined Time & Cost Summary

| Project | Active Work | Background Processing | Azure Cost |
|---------|-------------|----------------------|------------|
| **Data-Governance-Simulation** | 4-6 hours | 24hr-14 days (indexing, classification) | $0 |
| **Skills-Ramp** | 19.5-26.5 hours | 24-48 hours (Activity Explorer, retention) | $10-140 |
| **Classification-Lifecycle** | 5.5-7.5 hours | All front-loaded (no active waiting) | $0 |
| **Combined Total** | **30-40 hours** | **Optimized sequencing** | **$10-140** |

**Recommended Combined Timeline**: 6-8 weeks for complete three-project mastery with full discovery timing validation and production deployment activation periods

---

## 📖 Additional Resources

**Project Documentation**:

- [Microsoft Purview Timing Delay Reference Guide](./TIMING-DELAY-CHEAT-SHEET.md) - Comprehensive timing expectations for all Purview operations validated against Microsoft Learn documentation (November 2025). All timing claims across all three projects are validated against this authoritative reference.

**Microsoft Official Documentation**:

- [Microsoft Purview Information Protection](https://learn.microsoft.com/en-us/purview/information-protection)
- [Microsoft Purview Data Lifecycle Management](https://learn.microsoft.com/en-us/purview/data-lifecycle-management)
- [Deploy the Microsoft Purview Information Protection Scanner](https://learn.microsoft.com/en-us/purview/deploy-scanner)

**Certification Resources**:

- [SC-400: Microsoft Information Protection and Compliance Administrator](https://learn.microsoft.com/en-us/certifications/exams/sc-400)
- [SC-900: Microsoft Security, Compliance, and Identity Fundamentals](https://learn.microsoft.com/en-us/certifications/exams/sc-900)

---

## 🤖 AI-Assisted Content Generation

This comprehensive Purview learning portfolio overview was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview capability analysis, professional skills development frameworks, and comprehensive coverage mapping validated against current Microsoft Learn documentation as of November 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Purview capabilities while maintaining technical accuracy, professional skills alignment for career development, and reflecting industry best practices for information protection, data lifecycle management, and hybrid data governance.*
