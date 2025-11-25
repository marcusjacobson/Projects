# Microsoft Sentinel Learning Labs

**Keywords:** Microsoft Sentinel, SIEM, SOAR, KQL, Threat Hunting, Incident Response, Logic Apps, Automation, DevSecOps, Infrastructure as Code (IaC), Bicep, Azure DevOps.

## 🎯 Overview

This directory contains **comprehensive hands-on lab projects** designed to build practical Microsoft Sentinel expertise focused on **Cloud-Native SIEM & SOAR** implementation. The portfolio demonstrates enterprise-grade security operations capabilities, from Infrastructure-as-Code deployment to advanced threat hunting and automation.

**Combined Learning Value**: 8-12 hours of hands-on lab work covering DevOps-driven deployment, KQL analytics, Logic App automation, and Unified Security Operations integration.

---

## 📚 Project Portfolio

### [Sentinel-as-Code](./Sentinel-as-Code/)

**Focus**: CI/CD deployment of Microsoft Sentinel artifacts using Azure DevOps/GitHub Actions and Bicep

**Target Audience**: DevSecOps engineers, Security Architects, and SOC Engineers implementing automated detection engineering

**Duration**: 8-12 hours active work | **Cost**: $5-50 (Log Analytics ingestion & Logic App execution)

**Key Capabilities**:

- **Infrastructure as Code**: Bicep templates for workspace and connector deployment
- **Content Management**: Repository-based management of Analytics Rules, Hunting Queries, and Playbooks
- **Automated Deployment**: Pipelines for validating and deploying security content
- **Version Control**: Git-based tracking of detection logic changes
- **KQL Engineering**: Custom analytics rules and correlation logic
- **SOAR Automation**: Logic App playbooks with managed identity authentication

**Learning Paths**:

- **Foundation** (Phase 1): Workspace deployment and RBAC configuration
- **Detection Engineering** (Phase 2): Analytics rules and hunting queries as code
- **Automation** (Phase 3): Playbook development and automated response

**Coverage Depth**: ~45% of Sentinel landscape (deployment and engineering focus)

---

## 🎓 Recommended Learning Sequence

> **💡 Important Note**: The Sentinel-as-Code project is designed as a **comprehensive, phased implementation**. It guides you from empty subscription to fully functional SOC infrastructure using modern DevOps practices.

### For Complete Sentinel Mastery

**Phased Implementation Approach** (2-3 weeks total):

1. **Week 1**: Infrastructure Foundation
   - Deploy Log Analytics Workspace via Bicep
   - Configure data retention and archiving policies
   - Implement Azure RBAC for SOC roles
   - Enable data connectors (Activity Log, Defender XDR)

2. **Week 2**: Detection Engineering
   - Develop custom KQL analytics rules
   - Implement "Near-Real-Time" (NRT) detections
   - Validate rules using pipeline tests
   - Deploy hunting queries and bookmarks

3. **Week 3**: SOAR & Automation
   - Design Logic App playbooks for incident enrichment
   - Configure automation rules for suppression and tagging
   - Implement managed identity authentication for playbooks
   - Test end-to-end incident response workflows

**Combined Total**: 10-15 hours active work | **Cost**: $5-50

---

## 📊 Comprehensive Microsoft Sentinel Capability Coverage

### Coverage Matrix: Project Comparison

This matrix shows which project covers each Sentinel capability, aligned with **SC-200** and **Unified SecOps** standards.

#### ✅ Core Architecture & Configuration

| Capability | Complexity | Sentinel-as-Code Coverage | Combined Status |
|------------|------------|---------------------------|-----------------|
| **Workspace Design** | INTERMEDIATE | ✅ Bicep deployment, retention config | ✅ COMPREHENSIVE |
| **Access Control (RBAC)** | INTERMEDIATE | ✅ Azure RBAC, Sentinel-specific roles | ✅ COMPREHENSIVE |
| **Data Connectors** | BASIC | ✅ Content Hub solutions, API connectors | ✅ EXTENSIVE |
| **Log Analytics** | INTERMEDIATE | ✅ Table configuration, basic KQL | ✅ COMPREHENSIVE |
| **Cost Management** | ADVANCED | 📅 Planned (Workbook integration) | 📅 Planned |
| **ASIM Normalization** | ADVANCED | 📅 Planned (Parser deployment) | 📅 Planned |

#### ✅ Threat Detection Engineering

| Capability | Complexity | Sentinel-as-Code Coverage | Combined Status |
|------------|------------|---------------------------|-----------------|
| **Analytics Rules (Scheduled)** | INTERMEDIATE | ✅ YAML-defined KQL rules, CI/CD deploy | ✅ COMPREHENSIVE |
| **NRT Rules** | INTERMEDIATE | 📅 Planned | 📅 Planned |
| **Threat Intelligence** | INTERMEDIATE | 📅 Planned (TI Feed integration) | 📅 Planned |
| **Watchlists** | INTERMEDIATE | 📅 Planned (CSV import automation) | 📅 Planned |
| **Behavioral Analytics (UEBA)** | ADVANCED | 📅 Planned (Entity configuration) | 📅 Planned |
| **Custom KQL Functions** | ADVANCED | ✅ Library deployment via pipeline | ✅ COMPREHENSIVE |

#### ✅ Security Orchestration & Automation (SOAR)

| Capability | Complexity | Sentinel-as-Code Coverage | Combined Status |
|------------|------------|---------------------------|-----------------|
| **Automation Rules** | BASIC | ✅ Incident triggers, suppression logic | ✅ COMPREHENSIVE |
| **Logic App Playbooks** | INTERMEDIATE | ✅ JSON definition, managed identity | ✅ COMPREHENSIVE |
| **Context Enrichment** | INTERMEDIATE | ✅ External API integration patterns | ✅ EXTENSIVE |
| **Remediation Actions** | ADVANCED | 📅 Planned (Block IP/User workflows) | 📅 Planned |
| **Unified Automation** | ADVANCED | 📅 Planned (XDR cross-product rules) | 📅 Planned |

#### ✅ Threat Hunting & Investigation

| Capability | Complexity | Sentinel-as-Code Coverage | Combined Status |
|------------|------------|---------------------------|-----------------|
| **Hunting Queries** | INTERMEDIATE | ✅ Repository-managed queries | ✅ COMPREHENSIVE |
| **Investigation Graph** | BASIC | ✅ Incident investigation workflows | ✅ DETAILED |
| **Bookmarks** | BASIC | 📅 Planned | 📅 Planned |
| **Jupyter Notebooks** | EXPERT | 📅 Planned (Python environment setup) | 📅 Planned |
| **Livestream** | INTERMEDIATE | 📅 Planned | 📅 Planned |

#### ✅ Visualization & Reporting

| Capability | Complexity | Sentinel-as-Code Coverage | Combined Status |
|------------|------------|---------------------------|-----------------|
| **Workbooks** | INTERMEDIATE | ✅ JSON definition, gallery deployment | ✅ COMPREHENSIVE |
| **Executive Reporting** | INTERMEDIATE | 📅 Planned | 📅 Planned |
| **Operational Dashboards** | BASIC | ✅ SOC efficiency metrics | ✅ DETAILED |

### ❌ Capabilities NOT Covered

The following capabilities require **specialized infrastructure**, **extended data collection**, or **enterprise-scale integration**:

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **SAP Threat Monitoring** | EXPERT | Requires SAP infrastructure and specialized connectors |
| **OT/IoT Security** | ADVANCED | Requires IoT devices and Defender for IoT integration |
| **Codeless Connector Platform** | ADVANCED | Requires custom API development environment |
| **Bring Your Own ML (BYO-ML)** | EXPERT | Requires Azure Databricks/ML workspace integration |

---

## 🎯 Project Selection Guide

### Choose Sentinel-as-Code When You Need

- ✅ **DevSecOps experience** (CI/CD, Git, Pipelines)
- ✅ **Infrastructure-as-Code skills** (Bicep/ARM)
- ✅ **Automated detection engineering**
- ✅ **Version-controlled security logic**
- ✅ **Repeatable SOC deployments**
- ✅ **Custom KQL development workflows**

**Best For**: Security Engineers, DevOps Engineers, SOC Architects, and consultants building scalable MSSP platforms.

---

## 🚀 Getting Started

### Quick Navigation

**For Automated SOC Deployment**:  
→ Start with [Sentinel-as-Code](./Sentinel-as-Code/)

---

## 💼 Professional Skills Development

### Combined Skills Portfolio

Completing the Sentinel-as-Code project demonstrates proficiency in:

**Core Technical Competencies**:

- **SIEM Architecture**: Workspace design, data collection strategies, and RBAC models
- **Detection Engineering**: Advanced KQL, correlation logic, and false positive tuning
- **SOAR Development**: Logic App design, API integration, and automated response
- **DevSecOps**: Git version control, CI/CD pipelines (Azure DevOps/GitHub), and Bicep IaC
- **Unified SecOps**: Integration with Microsoft Defender XDR and incident management

**Certification Alignment**:

- **Microsoft Certified: Security Operations Analyst Associate** (SC-200)
- **Microsoft Certified: Azure Security Engineer Associate** (AZ-500)
- **Microsoft Certified: DevOps Engineer Expert** (AZ-400) - Pipeline components

### Career Paths

**Roles supported by this expertise**:

- Security Operations Center (SOC) Analyst
- Threat Detection Engineer
- Security Automation Engineer
- Cloud Security Architect
- SIEM Engineer
- DevSecOps Engineer

---

## 📊 Combined Time & Cost Summary

| Project | Active Work | Background Processing | Azure Cost |
|---------|-------------|----------------------|------------|
| **Sentinel-as-Code** | 8-12 hours | Continuous (Ingestion/Analytics) | $5-50 |
| **Combined Total** | **8-12 hours** | **Continuous** | **$5-50** |

**Recommended Timeline**: 2-3 weeks for complete mastery of the code-based deployment and detection engineering lifecycle.

---

## 📖 Additional Resources

**Microsoft Official Documentation**:

- [Microsoft Sentinel Documentation](https://learn.microsoft.com/en-us/azure/sentinel/)
- [Best practices for Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/best-practices)
- [Sentinel-as-Code (Official GitHub)](https://github.com/Azure/Azure-Sentinel/tree/master/Tools/Sentinel-All-In-One)

**Certification Resources**:

- [SC-200: Microsoft Security Operations Analyst](https://learn.microsoft.com/en-us/certifications/exams/sc-200)
- [AZ-500: Microsoft Azure Security Technologies](https://learn.microsoft.com/en-us/certifications/exams/az-500)

---

## 🤖 AI-Assisted Content Generation

This comprehensive Sentinel learning portfolio overview was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Sentinel capability analysis, professional skills development frameworks, and comprehensive coverage mapping validated against current Microsoft Learn documentation as of November 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Sentinel capabilities while maintaining technical accuracy, professional skills alignment for career development, and reflecting industry best practices for Cloud-Native SIEM and SOAR.*
