# Microsoft Purview Skills Ramp - On-Premises & Cloud Scanning

## 🎯 Project Overview

This hands-on lab series provides comprehensive practical experience with Microsoft Purview capabilities, organized by deployment scenario: **Setup**, **On-Premises Scanning**, **Cloud Scanning**, and **Advanced Supplemental Labs**. The labs follow Microsoft's DLP lifecycle methodology and are validated against current Microsoft Learn documentation (October 2025).

**This reorganized structure separates on-premises file share scanning from SharePoint/OneDrive cloud scanning**, making it easier to focus on specific deployment scenarios while maintaining complete technical coverage.

**What Makes This Different:**

- **Scenario-Based Organization**: Clear separation between on-prem and cloud scanning workflows.
- **100% Microsoft-Aligned**: Follows official DLP lifecycle (Plan → Prepare → Design → Simulate → Monitor → Deploy).
- **Progressive Skill Building**: Setup → On-Prem → Cloud → Validation → Advanced.
- **Production-Ready Patterns**: Real-world remediation automation for enterprise deployments.
- **Consultancy Project Alignment**: Addresses hybrid data governance with flexible learning paths.

---

## 🚀 Getting Started - Accessing This Project

### Option 1: Fork and Clone (Recommended for Version Control)

**Fork the repository** to your GitHub account, then clone it locally:

```powershell
# Clone your forked repository to the recommended location
git clone https://github.com/YOUR-USERNAME/Projects.git "c:\REPO\GitHub\Projects"

# Navigate to the Purview project
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud"
```

**Benefits**: Version control, ability to track your changes, easy sync with updates.

### Option 2: Direct Download (Quick Start)

**Download the repository** as a ZIP file:

1. Visit the [Projects repository](https://github.com/marcusjacobson/Projects).
2. Click **Code** → **Download ZIP**.
3. Extract to `c:\REPO\GitHub\` (creates `c:\REPO\GitHub\Projects\`).
4. Navigate to: `c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\`.

**Benefits**: Faster setup, no Git required, simpler for one-time use.

### Recommended Folder Structure for Lab Scripts

**All labs in this project use absolute paths with this recommended structure:**

```text
c:\REPO\GitHub\Projects\                          ← Repository root
└── Microsoft\
    └── Purview\
        └── Purview-Skills-Ramp-OnPrem-and-Cloud\ ← Project root
            ├── 01-Setup\
            │   ├── Setup-01-Licensing-and-Auditing\
            │   ├── Setup-02-Azure-Infrastructure\
            │   └── Setup-03-Service-Account-Creation\
            ├── 02-OnPrem-Scanning\
            │   ├── OnPrem-01-Scanner-Deployment\
            │   ├── OnPrem-02-Discovery-Scans\
            │   ├── OnPrem-03-DLP-Policy-Configuration\
            │   └── OnPrem-04-DLP-Activity-Monitoring\
            ├── 03-Cloud-Scanning\
            │   └── [Cloud labs with retention and eDiscovery]
            └── Supplemental-Labs\
                └── [Advanced automation labs]
```

**Example script paths used throughout the labs:**

```powershell
# Navigate to specific lab directories
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\01-Setup\Setup-02-Azure-Infrastructure"
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\02-OnPrem-Scanning\OnPrem-02-Discovery-Scans"
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\Supplemental-Labs\Advanced-Remediation"
```

> **📁 Lab Data Files**: Some labs generate CSV exports and data files. The default storage location is `C:\PurviewLab\` (examples: `ActivityExplorer_Export.csv`, `SITAnalysisReport_*.csv`). Create this directory before starting the labs:
>
> ```powershell
> # Create lab data directory
> New-Item -Path "C:\PurviewLab" -ItemType Directory -Force
> ```

### Using a Custom Path Without Affecting the Root Project

**If you download or clone to a different location** (e.g., `D:\MyLabs\Purview\`), you can update paths in your local copy while keeping your fork clean:

**Option A: Global Find and Replace (Recommended for Forks)**:

Use PowerShell to update all lab README files in your local repository:

```powershell
# Navigate to your project root
cd "D:\MyLabs\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud"

# Find and replace paths in all README files
Get-ChildItem -Path . -Filter "README.md" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $updatedContent = $content -replace 'c:\\REPO\\GitHub\\Projects\\Microsoft\\Purview\\Purview-Skills-Ramp-OnPrem-and-Cloud', 'D:\MyLabs\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud'
    Set-Content -Path $_.FullName -Value $updatedContent -NoNewline
}

Write-Host "✅ All README files updated with your custom path" -ForegroundColor Green
```

**Option B: Git Branch for Path Customization (Keeps Main Branch Clean)**:

```powershell
# Create a local branch for your path customizations
git checkout -b custom-paths

# Run the find-and-replace script from Option A
# Commit your path changes to this branch only
git add .
git commit -m "Update paths for local environment"

# Your custom-paths branch now has your modifications
# The main branch remains unchanged and can sync with upstream
```

**Option C: Manual Per-Lab Updates (Quick but Repetitive)**:

Update the `cd` command at the start of each lab as you work through them:

```powershell
# Original path in lab README
cd "c:\REPO\GitHub\Projects\Microsoft\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\01-Setup\Setup-01-Licensing-and-Auditing"

# Your custom path (update before running)
cd "D:\MyLabs\Purview\Purview-Skills-Ramp-OnPrem-and-Cloud\01-Setup\Setup-01-Licensing-and-Auditing"
```

> **🔀 Git Best Practice**: If you forked the repository and want to keep syncing updates from the original project:
>
> - Use **Option B** (Git Branch) to isolate your path customizations
> - Keep your `main` branch clean for pulling upstream changes
> - Work from your `custom-paths` branch for all lab activities
> - Merge upstream updates into `main`, then rebase `custom-paths` as needed

---

## ⚠️ Critical Time & Cost Considerations

**Before starting this project, understand these key constraints:**

| Consideration | Impact | Action Required |
|---------------|--------|-----------------|
| **💰 Azure VM Costs** | **$3-5/day** continuous billing | Delete Resource Group immediately after labs |
| **⏱️ DLP Policy Sync** | **1-2 hours** before enforcement works | Create policies, wait, then run scans |
| **⏱️ Retention Simulation** | **1-2 days** for results (email notification) | Plan multi-day timeline for Cloud labs |
| **⏱️ Retention Activation** | **Up to 7 days** for production label application | Required for full Cloud lab completion |
| **⏱️ Activity Explorer** | **24-48 hours** for data population | Wait 24-48 hours for complete dashboard data |
| **⏱️ Audit Log Aggregation** | **Up to 24-48 hours** for complete visibility | Scanner activity may take time to appear |
| **🧹 Cleanup Re-Commission** | **4-6 hours** to rebuild full environment | Plan carefully before deleting Azure resources |

> **⏱️ Recommended Timeline**: **1-2 weeks total**
>
> - **Week 1**: Complete Sections 1-2 (Setup + On-Prem Scanning: ~5.5-8.5 hours hands-on)
> - **Between Weeks**: DLP policy sync (1-2 hrs), Retention simulation (1-2 days), Label activation (up to 7 days)
> - **Week 2**: Complete Section 3 (Cloud with fully activated policies: ~3-4 hours)
> - **Optional Weeks 2-4**: Supplemental Labs for production automation (11-14 hours)
>
> **💡 Accelerated Learning Option**: You can complete the hands-on configuration in **2-3 focused days** (~8.5-12.5 hours total), but retention labels will be in simulation mode only and Activity Explorer data may be incomplete.

**Cost Control Critical Path**:

1. Section 1 **starts billing** (~$3-5/day for VM + SQL)
2. Complete Sections 1-3 over 1-2 weeks (~$21-70 total cost depending on timeline)
3. **Deallocate VM between sessions** to save ~60% of compute costs
4. **Delete Azure Resource Group immediately after final validation**

> **💰 Cost Optimization**: If completing over 2 weeks, **deallocate (stop) the VM** when not actively working. This reduces daily cost from $3-5/day to ~$0.50-1.00/day (storage only). VM restarts in 2-3 minutes vs 4-6 hours to rebuild from scratch.

---

## 📚 Project Structure

This project is organized into **3 main sections plus optional supplemental labs** with **11 core labs + 4 advanced labs**:

### **Section 1: Setup (01-Setup/)**

**Purpose**: Foundational prerequisites with time-sensitive components

**Duration**: 2-3 hours | **Wait Period**: 2-24 hours (auditing activation)

| Lab | Duration | Key Activities |
|-----|----------|----------------|
| **Setup-01-Licensing-and-Auditing** | 30-45 min | M365 E5 trial activation, License assignment, **Auditing enablement** (2-24 hr activation) |
| **Setup-02-Azure-Infrastructure** | 1.5-2 hours | Resource Group, Windows Server VM, SQL Express, SMB file shares, Azure Files, Auto-shutdown |
| **Setup-03-Service-Account-Creation** | 15-30 min | Entra ID service account, License assignment, Role configuration |

**Prerequisites**: Azure subscription, M365 tenant, admin access  
**Cost Impact**: **Starts $3-5/day billing**  
**Next**: Section 2 (On-Prem Scanning)

---

### **Section 2: On-Premises Scanning (02-OnPrem-Scanning/)**

**Purpose**: Information Protection Scanner for on-premises file shares and Azure Files

**Duration**: 3.5-5.5 hours | **Wait Period**: 1-2 hours (DLP policy sync)

| Lab | Duration | Key Activities |
|-----|----------|----------------|
| **OnPrem-01-Scanner-Deployment** | 2-3 hours | Install Purview client, Create app registration, Configure scanner cluster, Create scan job |
| **OnPrem-02-Discovery-Scans** | 1-2 hours | Add repositories (UNC paths + Azure Files), Execute discovery scan, Analyze results |
| **OnPrem-03-DLP-Policy-Configuration** | 1 hour | Create DLP policy, Configure SIT rules, Set enforcement actions, **Wait 1-2 hours** |
| **OnPrem-04-DLP-Activity-Monitoring** | 2-3 hours | Run enforcement scan, Verify policy detection, Review Activity Explorer |

**Prerequisites**: Section 1 completed  
**Technical Focus**: Hybrid scanning (on-prem + cloud storage), Built-in SITs, DLP enforcement  
**Next**: Section 3 (Cloud Scanning) or Supplemental Labs

---

### **Section 3: Cloud Scanning (03-Cloud-Scanning/)**

**Purpose**: SharePoint Online/OneDrive retention labels and lifecycle management

**Duration**: 3-4 hours | **Wait Period**: Up to 7 days (includes optional 1-2 day simulation)

| Lab | Duration | Key Activities |
|-----|----------|----------------|
| **Cloud-01-SharePoint-Foundation** | 30-45 min | Create SharePoint test site, Upload test documents, Verify Content Explorer |
| **Cloud-02-Retention-Labels** | 1-1.5 hours | Create retention label, Configure last access time trigger, Enable simulation |
| **Cloud-03-Auto-Apply-Policies** | 1 hour | Create auto-apply policy, Configure SIT triggers, **Wait 1-2 days for simulation (optional)** |
| **Cloud-04-SharePoint-eDiscovery** | 1-1.5 hours | Content Search with KQL, SIT-based discovery, Export results |

**Prerequisites**: Section 1 completed (Section 2 recommended but not required)  
**Technical Focus**: SharePoint retention, Auto-apply automation, Last access time (SPO only)  
**Critical Wait**: **Up to 7 days** for full label processing (includes optional 1-2 day simulation)  
**Next**: Supplemental Labs (optional advanced topics)

---

### **Supplemental Labs (Supplemental-Labs/)**

**Purpose**: Optional advanced topics and production patterns (assumes Sections 1-3 complete)

**Duration**: 8-11 hours | **Wait Period**: 24-48 hours (Activity Explorer)

> 💡 **Sample Data Available**: Labs with Activity Explorer dependencies include sample CSV files for immediate script testing while waiting for Purview sync. See each lab's `sample-data/` directory.

| Lab | Duration | Key Activities |
|-----|----------|----------------|
| **Advanced-Cross-Platform-SIT-Analysis** | 45-60 min | Activity Explorer cross-platform analysis, Data Classification dashboards, Capstone integration, Executive reporting |
| **Advanced-Remediation** | 4-6 hours | Multi-tier severity matrix, Dual-source deduplication, PnP PowerShell, Tombstones, Progress tracking dashboards |
| **Advanced-SharePoint-SIT-Analysis** | 3-4 hours | DLP deployment for SIT protection, Activity Explorer validation (24-48 hrs), Content Explorer reporting (24-48 hrs), PowerShell SIT distribution analysis |

**Prerequisites**: Sections 1-3 completed (Advanced-Cross-Platform-SIT-Analysis requires OnPrem-04 from Section 2 and Advanced-SharePoint-SIT-Analysis Step 2)  
**Flexible Ordering**: ✅ **Complete in any order** - all 3 labs are fully independent (recommended: Advanced-SharePoint → Advanced-Remediation → Advanced-Cross-Platform)  
**Technical Focus**: Cross-platform SIT analysis, Production automation, SharePoint DLP optimization  
**Sample Data**: Available in `Advanced-SharePoint-SIT-Analysis/sample-data/` and `Advanced-Cross-Platform-SIT-Analysis/sample-data/`

---

## 🎓 Learning Paths

### Path 1: Core Functional Learning (Sections 1-3)

**Duration**: 1-2 weeks | **Hands-On Time**: 8.5-12.5 hours | **Complexity**: Beginner to Intermediate

**Best For**: Learning complete Purview capabilities with foundational production functionality

**Timeline**:

- Week 1: Sections 1-2 (Setup + On-Prem: 5.5-8.5 hours).
- Between Weeks: DLP sync (1-2 hrs), Retention simulation/activation (up to 7 days).
- Week 2: Section 3 (Cloud: 3-4 hours).

**Cost**: ~$21-70 total (or ~$7-28 if VM deallocated between sessions)

---

### Path 2: Accelerated Concepts (Sections 1-3, Simulation Mode)

**Duration**: 2-3 focused days | **Hands-On Time**: 8.5-12.5 hours | **Complexity**: Beginner to Intermediate

**Best For**: Learning configuration steps without waiting for production activation

**Timeline**:

- Day 1: Sections 1-2 (5.5-8.5 hours).
- Days 2-3: Section 3 (3-4 hours, simulation mode only).

**Cost**: ~$10-15 total  
**Limitation**: Policies remain in simulation/test mode, Activity Explorer data incomplete

---

### Path 3: Production Deployment (Sections 1-3 + Supplemental Labs)

**Duration**: 2-4 weeks | **Hands-On Time**: 19.5-26.5 hours | **Complexity**: Intermediate to Advanced

**Best For**: Production implementation, enterprise projects, consultancy work

**Timeline**:

- Week 1: Sections 1-2 (5.5-8.5 hours).
- Week 2: Section 3 with full activation (3-4 hours).
- Weeks 2-4: Supplemental Labs (11-14 hours).

**Cost**: ~$28-140 total (or ~$14-56 if VM deallocated)

---

## 💰 Cost & Time Summary

| Section | Duration | Active Work | Wait Periods | Daily Cost |
|---------|----------|-------------|--------------|------------|
| **1. Setup** | Day 1 | 2-3 hours | 2-24 hrs (auditing) | **Starts $3-5/day** |
| **2. OnPrem Scanning** | Days 2-3 | 3.5-5.5 hours | 1-2 hrs (DLP sync) | $3-5/day |
| **3. Cloud Scanning** | Days 4-14 | 3-4 hours | **Up to 7 days** (retention) | $3-5/day |
| **Supplemental Labs** | Flexible | 11-14 hours | 24-48 hrs (Activity Explorer) + 24 hrs (ML) | $3-5/day |

**Total Project Cost**:

- Accelerated (2-3 days): $10-15.
- Full Functional (1-2 weeks): $21-70.
- Production Deployment (2-4 weeks): $28-140.

---

## ⚙️ Prerequisites

- Azure subscription with appropriate permissions.
- Microsoft 365 E5 Compliance or Purview trial license.
- Basic PowerShell and Azure CLI knowledge.
- Entra ID (Azure AD) tenant access.

---

## 🚀 Getting Started

1. **Choose your learning path** (see Learning Paths section above)
2. **Start with**: [Section 1: Setup](./01-Setup/README.md)
3. **Progress through sections** based on your learning objectives:
   - **On-Prem Focus**: Sections 1 → 2 → Supplemental Labs
   - **Cloud Focus**: Sections 1 → 3 → Supplemental Labs
   - **Complete Coverage**: Sections 1 → 2 → 3 → Supplemental Labs
4. **Complete cleanup** using [Environment-Cleanup-Guide.md](./Environment-Cleanup-Guide.md)

---

## 📚 Reference Documentation

All lab steps are validated against current Microsoft Learn documentation:

- [Microsoft Purview Information Protection Scanner](https://learn.microsoft.com/en-us/purview/deploy-scanner).
- [DLP On-Premises Repositories](https://learn.microsoft.com/en-us/purview/dlp-on-premises-scanner-learn).
- [Retention Labels & Policies](https://learn.microsoft.com/en-us/purview/create-apply-retention-labels).
- [Data Lifecycle Management](https://learn.microsoft.com/en-us/purview/data-lifecycle-management).

---

## 📊 Microsoft Purview Capability Coverage

### Professional Skills You'll Gain

Completing this project demonstrates proficiency in the following industry-recognized Microsoft Purview skills, formatted for LinkedIn profiles, resumes, and corporate workforce development systems:

#### **Core Technical Competencies**

**Information Protection & Data Governance:**

- Microsoft Purview Information Protection Scanner (deployment, configuration, administration).
- Sensitive Information Types (SIT) detection and classification (built-in patterns).
- Data Loss Prevention (DLP) policy design, implementation, and enforcement.
- Data Classification tools (Activity Explorer, Content Explorer, On-Demand Classification).
- SharePoint Online data governance and compliance management.
- Retention Labels and auto-apply policies for data lifecycle management.
- eDiscovery content search and legal export workflows (KQL query language).

**Automation & Scripting:**

- PowerShell automation for compliance workflows and reporting.
- PnP PowerShell for SharePoint remediation and bulk operations.
- Azure CLI for infrastructure deployment and management.
- Bicep Infrastructure-as-Code (IaC) for Azure resource provisioning.
- REST API integration for Azure resource management and Microsoft Graph.

**Cloud & Hybrid Infrastructure:**

- Azure Resource Management (resource groups, subscriptions, RBAC).
- Microsoft Entra ID (formerly Azure AD) application registration and authentication.
- Hybrid identity management (on-premises and cloud integration).
- Azure Virtual Machine deployment and configuration (Windows Server).
- Microsoft 365 compliance center administration.

#### **Business & Compliance Competencies**

**Regulatory Compliance & Risk Management:**

- GDPR compliance implementation (data minimization, subject access requests).
- Data privacy and protection best practices.
- Compliance reporting and stakeholder communication.
- Risk assessment for sensitive data exposure.
- Audit trail management and documentation.

**Project & Process Management:**

- Technical documentation and knowledge transfer.
- Cost optimization for cloud compliance solutions.
- Multi-phase project execution (lab environment to production readiness).
- Cross-functional collaboration (IT, legal, compliance teams).
- Change management for data governance policies.

#### **Advanced Specializations**

**Data Analytics & Reporting:**

- CSV data analysis and executive summary generation.
- PowerShell-based business intelligence reporting.
- Compliance metrics tracking and KPI monitoring.
- Multi-source data consolidation (Activity Explorer, Content Explorer, scanner logs).

**Enterprise Architecture:**

- Hybrid cloud architecture design (on-premises + Microsoft 365).
- Security architecture for data protection workflows.
- Scalable compliance automation framework development.
- Production remediation workflow design and implementation.

#### **Relevant Certifications & Career Paths**

This project provides hands-on experience aligned with:

- **Microsoft Certified: Information Protection and Compliance Administrator Associate** (SC-400).
- **Microsoft Certified: Security, Compliance, and Identity Fundamentals** (SC-900).
- **Microsoft Certified: Azure Administrator Associate** (AZ-104) - Infrastructure components.
- Roles: Compliance Administrator, Data Governance Analyst, Information Protection Specialist, Cloud Security Engineer, Microsoft 365 Administrator.

#### **LinkedIn Skills Keywords**

For maximum visibility on LinkedIn and applicant tracking systems (ATS), this project covers:

`Microsoft Purview` • `Data Loss Prevention (DLP)` • `Information Protection` • `Data Governance` • `Compliance Management` • `Microsoft 365 Administration` • `Azure Administration` • `PowerShell Scripting` • `PnP PowerShell` • `SharePoint Online` • `Microsoft Entra ID` • `Azure Active Directory` • `Sensitive Information Types` • `Content Classification` • `eDiscovery` • `Retention Policies` • `GDPR Compliance` • `Data Privacy` • `Cloud Security` • `Hybrid Cloud Architecture` • `Infrastructure as Code (IaC)` • `Azure Bicep` • `REST API` • `Microsoft Graph API` • `KQL (Keyword Query Language)` • `Compliance Reporting` • `Risk Management` • `Audit & Compliance` • `Technical Documentation` • `Cost Optimization`

---

### What This Project Covers

This project provides **hands-on practical experience with core Microsoft Purview data governance capabilities**, focusing on:

- **Information Protection Scanner** (on-premises and cloud)
- **Data Loss Prevention** (DLP policy implementation)
- **Retention Labels** (lifecycle management)
- **eDiscovery** (basic content search and export)
- **Data Classification** (Activity Explorer, Content Explorer)
- **Production Automation** (remediation workflows, PnP PowerShell)

**Coverage Depth**: ~40% of total Microsoft Purview capability landscape with **deep hands-on experience** in covered areas (not superficial overview).

**Project Focus**: Hands-on practical labs suitable for IT professionals, consultants, and compliance administrators building foundational to intermediate Purview skills.

### Covered Capabilities by Category

#### ✅ Information Protection & Data Classification (100% Core Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Information Protection Scanner** | ✅ EXTENSIVE | Section 2 (OnPrem-01, OnPrem-02) |
| **Built-in Sensitive Information Types (SITs)** | ✅ EXTENSIVE | Section 2 (OnPrem-02, OnPrem-03, OnPrem-04) |
| **Activity Explorer** | ✅ EXTENSIVE | Supplemental (Advanced-Cross-Platform-SIT-Analysis) |
| **Content Explorer** | ✅ EXTENSIVE | Supplemental (Advanced-SharePoint-SIT-Analysis) |
| **Data Classification Dashboards** | ✅ COMPREHENSIVE | Supplemental (Advanced-Cross-Platform-SIT-Analysis) |
| **On-demand Classification (Preview)** | ✅ DETAILED | Supplemental (Advanced-SharePoint-SIT-Analysis) |
| **SharePoint Search Schema** | ✅ DETAILED | Supplemental (Advanced-SharePoint-SIT-Analysis) |

#### ✅ Data Loss Prevention (100% On-Premises Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **DLP Policies (On-premises)** | ✅ EXTENSIVE | Section 2 (OnPrem-03, OnPrem-04) |
| **DLP Policy Sync & Enforcement** | ✅ COMPREHENSIVE | Section 2 (OnPrem-04) |
| **DLP Reporting & Monitoring** | ✅ COMPREHENSIVE | Supplemental (Advanced-Cross-Platform-SIT-Analysis) |
| **Cross-platform SIT Analysis** | ✅ COMPREHENSIVE | Supplemental (Advanced-Cross-Platform-SIT-Analysis) |

#### ✅ Data Lifecycle Management (90% Core Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Retention Labels** | ✅ COMPREHENSIVE | Section 3 (Cloud-02) |
| **Auto-apply Policies** | ✅ COMPREHENSIVE | Section 3 (Cloud-03) |
| **Last Access Time Retention** | ✅ DETAILED | Section 3 (Cloud-02) |
| **Retention Simulation Mode** | ✅ DETAILED | Section 3 (Cloud-02, Cloud-03) |

#### ✅ eDiscovery & Legal (40% - Basic Features Only)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Content Search (Basic)** | ✅ COMPREHENSIVE | Section 3 (Cloud-04) |
| **KQL Query Language** | ✅ DETAILED | Section 3 (Cloud-04) |
| **eDiscovery Export** | ✅ COMPREHENSIVE | Section 3 (Cloud-04) |

#### ✅ Production Automation & Remediation (90% Custom Workflows)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Production Remediation Workflows** | ✅ EXTENSIVE | Supplemental (Advanced-Remediation) |
| **Multi-tier Severity Matrix** | ✅ DETAILED | Supplemental (Advanced-Remediation) |
| **Dual-source Deduplication** | ✅ DETAILED | Supplemental (Advanced-Remediation) |
| **PnP PowerShell Automation** | ✅ EXTENSIVE | Supplemental (Advanced-Remediation) |

#### ✅ Azure Infrastructure & M365 Setup (100%)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Azure Infrastructure (VM, Storage)** | ✅ COMPREHENSIVE | Section 1 (Setup-02) |
| **Entra ID Service Accounts** | ✅ DETAILED | Section 1 (Setup-03) |
| **M365 E5 Licensing** | ✅ COMPREHENSIVE | Section 1 (Setup-01) |
| **Auditing Enablement** | ✅ COMPREHENSIVE | Section 1 (Setup-01) |

### What This Project Does NOT Cover

The following capabilities require **enterprise-scale deployments**, **advanced licensing**, or **specialized infrastructure** beyond this project's scope:

#### ❌ Endpoint & Cloud App DLP (Advanced)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Endpoint DLP (Windows/macOS)** | ADVANCED | Requires device onboarding, client deployment beyond lab scope |
| **Cloud App DLP (non-Microsoft)** | ADVANCED | Requires Defender for Cloud Apps integration |
| **DLP for Power Platform** | ADVANCED | Requires Power Apps/Automate environment setup |

#### ❌ Advanced Sensitivity & Encryption (Intermediate to Expert)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Sensitivity Labels (Encryption)** | INTERMEDIATE | Encryption/visual markings not core to discovery-focused project |
| **Exact Data Match (EDM) SITs** | ADVANCED | Requires database hashing, complex data matching infrastructure |
| **Double Key Encryption** | EXPERT | Requires external key server, complex PKI setup |
| **Customer Key** | EXPERT | Tenant-level encryption keys, enterprise-only feature |

#### ❌ Records Management (Full Suite - Intermediate)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **File Plan Descriptors** | INTERMEDIATE | Advanced records metadata not covered (project covers retention labels only) |
| **Disposition Reviews** | INTERMEDIATE | Manual approval workflows beyond scope |
| **Multi-stage Disposition** | ADVANCED | Complex approval workflows not implemented |
| **Event-based Retention** | INTERMEDIATE | Custom event triggers not covered |
| **Regulatory Records** | INTERMEDIATE | Immutable records features not covered |

#### ❌ eDiscovery (Premium - Advanced)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **eDiscovery (Premium)** | ADVANCED | Custodian management, review sets, predictive coding require legal workflow setup |
| **Legal Hold Notifications** | ADVANCED | Custodian communications workflow beyond scope |
| **Advanced Indexing** | ADVANCED | Error remediation for partially indexed content not covered |

#### ❌ Insider Risk & Communication Compliance (Expert)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Insider Risk Management** | EXPERT | ML-based user risk scoring, forensic evidence require separate deployment |
| **Communication Compliance** | EXPERT | Regulatory monitoring (SEC, FINRA) requires compliance workflow setup |
| **Adaptive Protection** | EXPERT | Dynamic risk-based DLP policy adjustment requires Insider Risk integration |

#### ❌ Audit & Lifecycle (Extended Features - Intermediate)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Audit (Premium)** | INTERMEDIATE | Extended retention beyond 180 days not covered |
| **Inactive Mailboxes** | INTERMEDIATE | Mailbox preservation after user departure not covered |
| **Archive Mailboxes** | BASIC | Additional mailbox storage not covered |
| **PST Import Service** | INTERMEDIATE | Bulk PST file import not covered |

#### ❌ Advanced Governance & Compliance (Intermediate to Advanced)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Information Barriers** | ADVANCED | User segmentation policies (ethical walls) not covered |
| **Privileged Access Management** | EXPERT | Just-in-time admin access beyond scope |
| **Container Labels (Teams/Groups/Sites)** | INTERMEDIATE | Teams/Groups/Sites sensitivity labels not covered |
| **Compliance Boundaries** | ADVANCED | Multi-geo eDiscovery constraints not covered |
| **Litigation Hold** | INTERMEDIATE | Mailbox-level holds not covered |

#### ❌ Privacy & Data Governance (Microsoft Priva - Advanced)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Priva Privacy Risk Management** | ADVANCED | Privacy risk detection requires separate Priva deployment |
| **Priva Subject Rights Requests** | ADVANCED | GDPR/CCPA data subject request workflows not covered |
| **Priva Consent Management (Preview)** | ADVANCED | Consumer consent tracking requires Priva setup |

### Project Scope Statement

**What You'll Learn**:

- Comprehensive on-premises and cloud data discovery using Information Protection Scanner.
- DLP policy design, implementation, and enforcement for hybrid environments.
- Retention label configuration with auto-apply and simulation capabilities.
- Basic eDiscovery for content search and export.
- Activity Explorer and Content Explorer for data classification insights.
- Production-ready remediation workflows with PnP PowerShell automation.

**What You Won't Learn** (Requires Separate Study/Certification):

- Endpoint DLP device management.
- eDiscovery Premium legal workflows.
- Insider Risk Management ML models.
- Communication Compliance regulatory monitoring.
- Advanced encryption (EDM, Double Key, Customer Key).
- Microsoft Priva privacy solutions.

**Best Suited For**:

- IT professionals building Purview foundational skills.
- Consultants implementing hybrid data governance solutions.
- Compliance administrators managing retention and DLP policies.
- Organizations evaluating Purview capabilities for proof-of-concept deployments.

**Not a Replacement For**:

- Microsoft Purview certification exam preparation (requires broader capability coverage).
- Enterprise-scale production deployments (simplified lab environment).
- Legal/compliance team training on eDiscovery Premium or Insider Risk workflows.

---

## 🎓 Learning Path Alignment

This project maps to the following Microsoft Learn paths:

- **Purview Information Protection**: Data classification, labeling, protection.
- **DLP Implementation**: Policy design, enforcement, monitoring.
- **Records Management**: Retention, lifecycle, compliance reporting.

---

## 🤖 AI-Assisted Content Generation

This reorganized Purview skills ramp project was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was reorganized, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.
