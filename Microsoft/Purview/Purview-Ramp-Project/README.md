# Microsoft Purview Ramp Project - Comprehensive Lab Series

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

### Path 1: Weekend Learning (Labs 00-04)

**Duration**: 13-15 hours | **Complexity**: Beginner to Intermediate

**Best For**: Learning core Purview capabilities, understanding DLP lifecycle, preparing for certification

- Lab 00: Environment Setup (2-3 hrs)
- Lab 01: Scanner Deployment (4 hrs)
- Lab 02: DLP Configuration (2-3 hrs)
- Lab 03: Retention Labels (2-3 hrs)
- Lab 04: Validation & Reporting (1-2 hrs)

**Outcome**: Fully operational Purview environment with discovery, DLP, and retention capabilities

### Path 2: Production Deployment (Labs 00-05)

**Duration**: 17-22 hours | **Complexity**: Intermediate to Advanced

**Best For**: Production implementation, enterprise data governance projects, consultancy work

- All Weekend Learning labs (13-15 hrs)
- Lab 05: Advanced Remediation & Production Automation (4-6 hrs)

**Outcome**: Production-ready automation with multi-tier remediation, stakeholder reporting, and deployment checklists

### Path 3: Consultancy Project (Full Labs + Alignment Docs)

**Best For**: Specific project implementation with hybrid (on-prem + cloud) requirements

- Complete Labs 00-05 (17-22 hrs)
- Reference: ALIGNMENT-ANALYSIS.md for technical implementation details
- Reference: ALIGNMENT-SUMMARY.md for executive overview and decision framework

**Outcome**: 100% alignment with specific consultancy project brief including dual-source deduplication and severity-based remediation

## � Project Flow & Microsoft DLP Lifecycle Alignment

This project follows Microsoft's recommended DLP implementation phases:

```text
Foundation (Lab 00)
    ↓ [Plan & Prepare]
Discovery (Lab 01)
    ↓ [Prepare for DLP]
Protection (Lab 02)
    ↓ [Design & Simulate]
Lifecycle (Lab 03)
    ↓ [Implement & Test]
Validation (Lab 04)
    ↓ [Monitor & Fine-tune]
Production (Lab 05)
    ↓ [Deploy to Production]
```

**Microsoft DLP Lifecycle Mapping:**

| Microsoft Phase | Lab Coverage | Duration |
|----------------|-------------|----------|
| **Plan for DLP** | Lab 00: Environment planning & cost estimation | 2-3 hrs |
| **Prepare for DLP** | Lab 00: Setup + Lab 01: Scanner deployment | 6-7 hrs |
| **Design policies** | Lab 02: DLP configuration | 2-3 hrs |
| **Implement in simulation** | Lab 02-03: Simulation & testing | 4-6 hrs |
| **Monitor & fine-tune** | Lab 04: Validation & reporting | 1-2 hrs |
| **Deploy to production** | Lab 05: Production remediation patterns | 4-6 hrs |

## �🗂️ Lab Structure

### Lab 00: Environment Setup & Cost Management

**Duration**: 2-3 hours  
**Focus**: Azure VM, SQL Express, SMB shares, cost optimization

**Key Skills**:

- Azure infrastructure deployment
- Service account configuration
- Sample sensitive data creation (including 3+ year-old timestamp simulation)
- Cost monitoring and budget alerts

**Microsoft Phase**: Plan & Prepare for DLP

> **💡 Testing Capability**: Lab 00 includes PowerShell timestamp backdating to create files simulating 3+ year-old data (`PhoenixProject.txt`). This enables realistic testing of retention policies, age-based remediation workflows, and data lifecycle management throughout the entire lab series.

### Lab 01: Information Protection Scanner Deployment

**Duration**: 4 hours  
**Focus**: Scanner installation, cluster configuration, content scan jobs

**Key Skills**:

- Information Protection client installation
- App registration with API permissions
- Scanner cluster creation in Purview portal
- Content scan job configuration
- Discovery scan execution

**Microsoft Phase**: Prepare for DLP

### Lab 02: DLP On-Premises Configuration

**Duration**: 2-3 hours  
**Focus**: DLP policies, enforcement actions, activity monitoring

**Key Skills**:

- DLP policy creation for on-premises repositories
- Sensitive Information Type (SIT) configuration
- Enforcement actions (Block, Quarantine, Audit)
- Activity Explorer monitoring
- Policy simulation and testing

**Microsoft Phase**: Design policies + Implement in simulation

### Lab 03: Retention Labels & Data Lifecycle Management

**Duration**: 2-3 hours  
**Focus**: Auto-apply labels, adaptive scopes, retention policies, SharePoint eDiscovery basics

**Key Skills**:

- Retention label creation and configuration
- Auto-apply policies with SIT triggers
- Adaptive scopes for targeted application
- **Enhanced**: Last access time concepts and limitations
- **Enhanced**: SharePoint Content Search (eDiscovery)

**Microsoft Phase**: Implement & Test lifecycle management

### Lab 04: Validation & Reporting

**Duration**: 1-2 hours  
**Focus**: Activity Explorer, Data Estate Insights, scanner reports, basic remediation scripting

**Key Skills**:

- Scanner report analysis and interpretation
- Activity Explorer deep dive
- Data Estate Insights utilization
- **Enhanced**: 4 fundamental PowerShell remediation patterns
  - Safe deletion with audit trail
  - Archive instead of delete
  - Bulk processing with error handling
  - Last access time analysis

**Microsoft Phase**: Monitor & fine-tune

### Lab 05: Advanced Remediation (Production Path Only)

**Duration**: 4-6 hours  
**Focus**: Multi-tier severity-based remediation, dual-source deduplication, PnP PowerShell, progress tracking

**Key Skills**:

- Multi-tier remediation decision matrix (HIGH/MEDIUM/LOW severity)
- Dual-source deduplication (on-prem + Nasuni/cloud)
- SharePoint PnP PowerShell bulk deletion automation
- On-premises tombstone creation for audit compliance
- Weekly/monthly progress tracking dashboards
- Stakeholder reporting templates
- Production deployment checklist

**Microsoft Phase**: Deploy to production

## 📚 Supplemental Documentation Guide

### When to Use Each Document

#### README.md (This File)

- **Use For**: Project overview, learning path selection, lab navigation
- **Best For**: First-time visitors, planning your learning journey

#### LAB-SUMMARY.md

- **Use For**: Quick reference for lab objectives, durations, and key topics
- **Best For**: Navigating between labs, estimating time commitments

#### ALIGNMENT-ANALYSIS.md

- **Use For**: Technical implementation details for consultancy project gaps
- **Best For**: Understanding specific PowerShell patterns, advanced scenarios
- **Audience**: Technical implementers working on production deployments

#### ALIGNMENT-SUMMARY.md

- **Use For**: Executive overview of project alignment and enhancement decisions
- **Best For**: Understanding why Labs 03-05 were enhanced, decision framework
- **Audience**: Project managers, stakeholders evaluating lab coverage

#### FLOW-AUDIT-REPORT.md

- **Use For**: Microsoft best practices validation and lab progression analysis
- **Best For**: Verifying alignment with official Microsoft DLP lifecycle
- **Audience**: Quality assurance, compliance teams validating methodology

## 🚀 Quick Start Guide

### Weekend Learning Path (Labs 00-04)

**Saturday (8-10 hours):**

1. **Morning**: Lab 00 - Environment Setup (2-3 hrs)
   - Deploy Azure VM and SQL Express
   - Create SMB shares with sample data
   - Configure service account

2. **Afternoon**: Lab 01 - Scanner Deployment (4 hrs)
   - Install Information Protection client
   - Create app registration
   - Deploy scanner cluster
   - Run discovery scan

3. **Evening**: Lab 02 - DLP Configuration (2-3 hrs)
   - Create DLP policies
   - Configure enforcement actions
   - Review Activity Explorer

**Sunday (5-7 hours):**

1. **Morning**: Lab 03 - Retention Labels (2-3 hrs)
   - Create retention labels
   - Configure auto-apply policies
   - Test SharePoint Content Search

2. **Afternoon**: Lab 04 - Validation & Reporting (1-2 hrs)
   - Analyze scanner reports
   - Review Activity Explorer and Data Estate Insights
   - Practice basic remediation scripting patterns

3. **Evening**: Cleanup and documentation

### Production Deployment Path (Add Lab 05)

**Additional 4-6 hours** beyond Weekend Learning Path:

- Multi-tier remediation automation
- Dual-source deduplication scripts
- PnP PowerShell bulk operations
- Progress tracking dashboard setup
- Production deployment checklist execution

Start with: [Lab 00: Environment Setup](./Labs/Lab-00-Environment-Setup/README.md)

## 💰 Cost Considerations

**Estimated Total Cost**: $10-15 for complete weekend (Labs 00-04)

**Breakdown**:

- **Azure VM** (Standard_D2s_v3, 24-48 hours): ~$7.50
- **Azure Files Premium** (100 GiB minimum, 2-3 days): ~$2.30
- **SQL Express**: Free
- **Purview Licensing**: Use E5 trial (30-day free trial available)
- **Bandwidth/Storage**: < $1

**Cost Optimization Tips**:

- **Deallocate VM** when not actively working (saves ~60% of compute costs)
- **Use auto-shutdown schedules** to prevent accidental overnight charges
- **Delete Lab 05 resources** immediately after completion (Nasuni simulation, extra storage)
- **Complete labs in 2 focused days** rather than extending over a full week

**Production Deployment (Lab 05)**:

- Additional $5-10 for extended VM usage and extra storage/resources
- Consider using dedicated Dev/Test subscription pricing if available

## ⚙️ Prerequisites

- Azure subscription with appropriate permissions
- Microsoft 365 E5 Compliance or Purview trial license
- Basic PowerShell and Azure CLI knowledge
- Entra ID (Azure AD) tenant access

## 🚀 Quick Start

1. Start with [Lab 00: Environment Setup](./Labs/Lab-00-Environment-Setup/README.md)
2. Progress sequentially through Labs 01-04
3. Each lab includes validation steps before proceeding
4. Complete cleanup guide after finishing labs

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
