# Microsoft Purview Ramp Project - Comprehensive Lab Series

## ⚠️ Critical Time & Cost Considerations

**Before starting this project, understand these key constraints:**

| Consideration | Impact | Action Required |
|---------------|--------|-----------------|
| **💰 Azure VM Costs** | **$3-5/day** continuous billing | Delete Resource Group immediately after labs |
| **⏱️ DLP Policy Sync** | **1-2 hours** before enforcement works | Create policies, wait, then run scans |
| **⏱️ Retention Simulation** | **1-2 days** for results (email notification) | Plan multi-day timeline for Lab 03 |
| **⏱️ Retention Activation** | **2-7 days** for production label application | Required for full Lab 03 completion |
| **⏱️ Activity Explorer** | **15-30 min** (basic) → **24 hrs** (trending) | Wait 24 hours for complete dashboard data |
| **⏱️ Audit Log Aggregation** | **Up to 24-48 hours** for complete visibility | Scanner activity may take time to appear |
| **🧹 Cleanup Re-Commission** | **4-6 hours** to rebuild full environment | Plan carefully before deleting Azure resources |

> **⏱️ Recommended Timeline**: **1-2 weeks total**
>
> - **Week 1**: Complete Labs 00-02 (hands-on configuration: ~10-12 hours)
> - **Between Weeks**: DLP policy sync (1-2 hrs), Retention simulation (1-2 days), Label activation (2-7 days)
> - **Week 2**: Complete Labs 03-04 with fully activated policies (hands-on: ~3-5 hours)
> - **Optional Week 3**: Supplemental Lab for production automation patterns (4-6 hours)
>
> **💡 Accelerated Learning Option**: You can complete the hands-on configuration in **2-3 focused days** (13-15 hours total), but understand that retention labels will be in simulation mode only and Activity Explorer data may be incomplete. This approach teaches concepts but doesn't demonstrate full production functionality.

**Cost Control Critical Path**:

1. Lab 00 **starts billing** (~$3-5/day for VM + SQL)
2. Complete Labs 00-04 over 1-2 weeks (~$21-70 total cost depending on timeline)
3. **Deallocate VM between sessions** to save ~60% of compute costs
4. **Delete Azure Resource Group immediately after final validation** (see [Environment-Cleanup-Guide.md](./Labs/Environment-Cleanup-Guide.md))

> **💰 Cost Optimization**: If completing over 2 weeks, **deallocate (stop) the VM** when not actively working. This reduces daily cost from $3-5/day to ~$0.50-1.00/day (storage only). VM restarts in 2-3 minutes vs 4-6 hours to rebuild from scratch.

---

## 🎯 Project Overview

This hands-on lab series provides complete practical experience with Microsoft Purview capabilities, from foundational infrastructure through production-ready data governance automation. The labs follow Microsoft's DLP lifecycle methodology and are validated against current Microsoft Learn documentation (October 2025).

**What Makes This Different:**

- **100% Microsoft-Aligned**: Follows official DLP lifecycle (Plan → Prepare → Design → Simulate → Monitor → Deploy)
- **Progressive Skill Building**: Foundation → Discovery → Protection → Lifecycle → Validation → Production
- **Production-Ready Patterns**: Real-world remediation automation for enterprise deployments
- **Consultancy Project Alignment**: Addresses hybrid data governance with on-premises + cloud scenarios

## 📋 Learning Objectives

Master the complete Purview implementation lifecycle:

- **Foundation & Planning**: Environment setup, cost management, prerequisite configuration
- **Discovery & Classification**: Information Protection Scanner deployment and sensitive data discovery
- **Data Loss Prevention**: Policy design, simulation mode testing, enforcement configuration
- **Lifecycle Management**: Retention labels, auto-apply policies, SharePoint eDiscovery
- **Validation & Reporting**: Activity Explorer analysis, Data Estate Insights, stakeholder reporting
- **Production Automation**: Multi-tier remediation, dual-source deduplication, progress tracking

## 🎓 Learning Paths

### Path 1: Full Functional Learning (Labs 00-04)

**Duration**: 1-2 weeks | **Hands-On Time**: 13-15 hours | **Complexity**: Beginner to Intermediate

**Best For**: Learning complete Purview capabilities with full production functionality, understanding real-world timelines, preparing for certification

**Timeline Breakdown**:

- **Week 1 (Days 1-3)**: Labs 00-02 hands-on configuration (10-12 hours)
  - Lab 00: Environment Setup (2-3 hrs)
  - Lab 01: Scanner Deployment (4 hrs)
  - Lab 02: DLP Configuration (2-3 hrs)
  - **Wait Period**: DLP policy sync (1-2 hours)

- **Between Weeks (Days 4-10)**: Microsoft backend processing
  - Lab 03: Configure retention policies in simulation mode (2-3 hrs hands-on)
  - **Wait Period**: Simulation results (1-2 days)
  - **Wait Period**: Activate labels in production (2-7 days)
  - **Wait Period**: Activity Explorer full aggregation (24-48 hours)

- **Week 2 (Days 11-14)**: Validation with complete data (3-5 hours)
  - Lab 03: Review simulation results, activate production labels
  - Lab 04: Validation & Reporting with full Activity Explorer data (1-2 hrs)
  - Environment cleanup

**Outcome**: Fully operational Purview environment with discovery, DLP, and retention capabilities operating in production mode with complete visibility

**Cost**: ~$21-70 total ($3-5/day × 7-14 days, or ~$7-28 if VM deallocated between sessions)

---

### Path 2: Accelerated Concepts Learning (Labs 00-04, Simulation Mode Only)

**Duration**: 2-3 focused days | **Hands-On Time**: 13-15 hours | **Complexity**: Beginner to Intermediate

**Best For**: Learning Purview concepts and configuration steps without waiting for full production activation, portfolio demonstration of technical knowledge

**Timeline Breakdown**:

- **Day 1 (8-10 hours)**: Labs 00-02
  - Complete environment setup, scanner deployment, DLP configuration
  - **Accept**: DLP enforcement scan won't work until policies sync (1-2 hours)
  
- **Day 2-3 (5-7 hours)**: Labs 03-04
  - Configure retention labels in simulation mode (won't wait for results)
  - Complete validation with basic Activity Explorer data (15-30 min sync, not full 24-hour aggregation)
  - **Accept**: Retention labels stay in simulation mode (not activated in production)
  - **Accept**: Activity Explorer shows basic data only (no trending charts)

**Outcome**: Complete understanding of Purview configuration and concepts, but policies remain in simulation/test mode without full production activation

**Cost**: ~$10-15 total (2-3 days with immediate cleanup)

> **⚠️ Limitation**: This accelerated path teaches configuration steps but does NOT demonstrate full production functionality. Retention labels won't actually apply to files, and Activity Explorer data will be incomplete.

---

### Path 3: Production Deployment Simulation (Labs 00-04 + Supplemental Labs)

**Duration**: 2-4 weeks | **Hands-On Time**: 24-37 hours | **Complexity**: Intermediate to Advanced

**Best For**: Production implementation, enterprise data governance projects, consultancy work, advanced SharePoint scenarios, organization-specific classification requirements

**Timeline Breakdown**:

- **Week 1**: Complete Labs 00-02 (10-12 hours hands-on)
- **Week 2**: Configure Lab 03, wait for simulation/activation, complete Lab 04 with full data (3-5 hours hands-on)
- **Week 2-3**: Supplemental Lab - Advanced remediation automation (4-6 hours hands-on)
- **Week 3-4 (Optional)**: Advanced SharePoint classification (3-4 hours) + Custom classification techniques (4-6 hours including 24-hour ML training wait)

**Outcome**: Production-ready automation with multi-tier remediation, stakeholder reporting, deployment checklists, fully activated Purview policies, advanced SharePoint on-demand classification capabilities, and custom SITs/trainable classifiers for organization-specific data patterns

**Cost**: ~$28-140 total ($3-5/day × 14-28 days, or ~$14-56 if VM deallocated between sessions)

> **⏱️ Production Timeline**: This path requires full 1-2 week waiting periods for retention label simulation (1-2 days) + activation (2-7 days). Use wait periods to work on Supplemental Labs for advanced automation patterns, SharePoint optimization, and custom classification techniques.

> **💡 Flexible Supplemental Labs**: The three supplemental labs can be completed in any order based on project needs:
>
> - **Remediation Automation**: For production deployment workflows
> - **Advanced SharePoint**: For large-scale SharePoint/OneDrive environments
> - **Custom Classification**: For organization-specific data patterns

---

## 🗂️ Lab Overview

### Lab 00: Environment Setup & Cost Management

**Duration**: 2-3 hours | **Microsoft Phase**: Plan & Prepare for DLP

Azure infrastructure deployment, service account configuration, sample sensitive data creation (includes PowerShell timestamp backdating for 3+ year-old data testing), cost monitoring and budget alerts.

### Lab 01: Information Protection Scanner Deployment

**Duration**: 4 hours | **Microsoft Phase**: Prepare for DLP

Information Protection client installation, app registration with API permissions, scanner cluster creation, content scan job configuration, discovery scan execution.

### Lab 02: DLP On-Premises Configuration

**Duration**: 2-3 hours | **Microsoft Phase**: Design policies + Implement in simulation

DLP policy creation for on-premises repositories, Sensitive Information Type (SIT) configuration, enforcement actions (Block, Quarantine, Audit), Activity Explorer monitoring, policy simulation and testing.

> **⏱️ Wait Required**: 1-2 hours for policies to sync to scanner before enforcement scans.

### Lab 03: Retention Labels & Data Lifecycle Management

**Duration**: 2-3 hours | **Microsoft Phase**: Implement & Test lifecycle management

Retention label creation, auto-apply policies with SIT triggers, adaptive scopes, last access time concepts, SharePoint Content Search (eDiscovery).

> **⏱️ Wait Required**: 1-2 days for simulation results, then 2-7 days for production activation = **3-9 days total**. This is why this project requires 1-2 weeks.

### Lab 04: Validation & Reporting

**Duration**: 1-2 hours | **Microsoft Phase**: Monitor & fine-tune

Scanner report analysis, Activity Explorer deep dive, Data Estate Insights, 4 fundamental PowerShell remediation patterns (safe deletion, archiving, bulk processing, last access time analysis).

> **⏱️ Wait Required**: 15-30 minutes for basic data, 24-48 hours for complete trending charts.

### Supplemental Lab: Advanced Remediation Automation

**Duration**: 4-6 hours | **Microsoft Phase**: Deploy to production | **Optional**: Production Path only

Multi-tier remediation decision matrix, dual-source deduplication (on-prem + cloud), SharePoint PnP PowerShell bulk deletion, on-premises tombstone creation, progress tracking dashboards, stakeholder reporting templates, production deployment checklist.

### Supplemental Lab: Advanced SharePoint & OneDrive Classification

**Duration**: 3-4 hours | **Microsoft Phase**: Optimize & Scale | **Optional**: Advanced SharePoint scenarios

Modern on-demand classification for targeted scanning of specific high-risk SharePoint sites, search schema optimization with managed properties, manual site re-indexing for accelerated classification, selective targeting strategies for large-scale environments, cost estimation and optimization for pay-as-you-go classification scans.

**Key Capabilities**: On-demand classification wizard (scope selection, classifier filtering, file date ranges), SharePoint search architecture and crawled properties, custom managed property creation for remediation tracking, production selective targeting patterns.

> **💡 Use Case**: Organizations needing to selectively classify historical SharePoint data in high-risk sites (Finance, HR, Legal) without full tenant scans, or requiring optimized indexing for large-scale classification projects.

### Supplemental Lab: Custom Classification Techniques

**Duration**: 4-6 hours (includes 24-hour ML training wait) | **Microsoft Phase**: Advanced Protection | **Optional**: Organization-specific data patterns

Create custom Sensitive Information Types (SITs) using regex patterns for organizational data (project codes, employee IDs, custom financial identifiers), and build trainable classifiers using machine learning for unstructured document types (financial reports, legal contracts, strategic plans).

**Key Capabilities**: Regex-based pattern matching with Boost.RegEx 5.1.3, confidence levels and supporting elements, trainable classifier training with positive/negative samples (50-500 positive, 150-1,500 negative), 24-hour automated ML training, accuracy validation with precision/recall metrics, integration with DLP policies and retention labels.

**Decision Framework**: Custom SITs for structured data with fixed patterns (30-60 min setup), Trainable Classifiers for unstructured documents requiring contextual understanding (2-3 hours + 24-hour training).

> **💡 Use Case**: Organizations with unique data patterns not covered by built-in classifiers, or requiring automated document type classification for compliance and lifecycle management.

> **⚠️ Note**: Trainable classifiers support **English language only** for custom training. Custom SITs work with all languages.

---

## ⚙️ Prerequisites

- Azure subscription with appropriate permissions
- Microsoft 365 E5 Compliance or Purview trial license
- Basic PowerShell and Azure CLI knowledge
- Entra ID (Azure AD) tenant access

---

## 💰 Cost & Time Summary

| Learning Path | Duration | Hands-On Time | Total Cost | Cost (Deallocated) |
|---------------|----------|---------------|------------|-------------------|
| **Accelerated Concepts** | 2-3 days | 13-15 hrs | $10-15 | $10-15 |
| **Full Functional** | 1-2 weeks | 13-15 hrs | $21-70 | $7-28 |
| **Production Deployment** | 2-4 weeks | 24-37 hrs | $28-140 | $14-56 |
| **+ All Supplemental Labs** | Add 11-16 hrs | +11-16 hrs | - | - |

**Supplemental Lab Time Breakdown**:

- Advanced Remediation Automation: 4-6 hours
- Advanced SharePoint Classification: 3-4 hours
- Custom Classification Techniques: 4-6 hours (includes 24-hour ML training wait)

**Why 1-2 weeks?** Lab 03 retention label processing requires mandatory 3-9 day wait (1-2 days simulation + 2-7 days activation). Microsoft's backend processing cannot be rushed.

**Cost Breakdown** (Full Functional Path example):

- Azure VM (Standard_D2s_v3): ~$17-35 for 7-14 days
- Azure Files Premium (100 GiB): ~$4-8 for 7-14 days
- **Daily cost if running**: $3-5/day
- **Daily cost if deallocated**: $0.50-1.00/day (storage only, VM restarts in 2-3 min)

**Cost Optimization**: Deallocate VM between sessions during wait periods. Delete Resource Group immediately after final validation.

> **⚠️ Critical**: Azure resources bill 24/7 until deleted. Always delete Resource Group after completing labs to terminate $3-5/day billing.

---

## 🧹 Cleanup & Re-Commission Times

**When to Clean Up**: Immediately after Lab 04 (or Supplemental Lab)

| Component | Cost Impact | Re-Commission Time | Recommended Action |
|-----------|-------------|-------------------|-------------------|
| **Azure Resource Group** | **$3-5/day** | **4-6 hours** (full rebuild) | ✅ **DELETE IMMEDIATELY** |
| **DLP Policies** | No cost | 1-2 hours (policy sync) | ⚠️ Disable if returning within 2 weeks |
| **Retention Labels** | No cost | **1-9 days** (simulation + activation) | ⚠️ Disable if returning within 2 weeks |
| **App Registration** | No cost | 15-30 minutes | ✅ Safe to delete |
| **SharePoint Test Site** | Minimal | 30-60 minutes (recycle bin <93 days) | ✅ Safe to delete |

**See**: [Environment-Cleanup-Guide.md](./Labs/Environment-Cleanup-Guide.md) for detailed step-by-step cleanup instructions.

---

## 🚀 Getting Started

1. **Choose your learning path** (see Learning Paths section above):
   - Accelerated Concepts (2-3 days, simulation mode)
   - Full Functional (1-2 weeks, recommended)
   - Production Deployment (2-3 weeks)

2. **Start with**: [Lab 00: Environment Setup](./Labs/Lab-00-Environment-Setup/README.md)

3. **Progress sequentially** through Labs 01-04 (and optional Supplemental Lab)

4. **Complete cleanup** using [Environment-Cleanup-Guide.md](./Labs/Environment-Cleanup-Guide.md)

---

## 📚 Reference Documentation

All lab steps are validated against current Microsoft Learn documentation:

- [Microsoft Purview Information Protection Scanner](https://learn.microsoft.com/en-us/purview/deploy-scanner)
- [DLP On-Premises Repositories](https://learn.microsoft.com/en-us/purview/dlp-on-premises-scanner-learn)
- [Retention Labels & Policies](https://learn.microsoft.com/en-us/purview/create-apply-retention-labels)
- [Data Lifecycle Management](https://learn.microsoft.com/en-us/purview/data-lifecycle-management)

## 🎓 Learning Path Alignment

This project maps to the following Microsoft Learn paths:

- **Purview Information Protection**: Data classification, labeling, protection
- **DLP Implementation**: Policy design, enforcement, monitoring
- **Records Management**: Retention, lifecycle, compliance reporting

## 🤖 AI-Assisted Content Generation

This comprehensive Purview ramp project was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview documentation and real-world consultancy project requirements.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Purview capabilities while maintaining technical accuracy and reflecting current portal navigation and configuration steps.*
