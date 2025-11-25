# Microsoft Entra Learning Labs

## 🎯 Overview

This directory contains **comprehensive hands-on lab projects** designed to build practical Microsoft Entra ID expertise, focusing on **Identity as Code**, **DevSecOps automation**, and **Zero Trust security**. These projects provide deep, hands-on implementation experience with modern identity management patterns.

**Combined Learning Value**: 20-30 hours of hands-on lab work covering pipeline automation, Graph API integration, conditional access design, and privileged identity management.

---

## 📚 Project Portfolio

### [Entra Deployment Pipelines](./Entra-Deployment-Pipelines/)

**Focus**: Infrastructure as Code (IaC) for Identity, DevOps automation, and Graph API mastery

**Target Audience**: Identity Engineers, DevSecOps professionals, Cloud Architects, and Automation Engineers

**Duration**: 10-15 hours | **Cost**: $0 (Free Tier Azure DevOps + M365 Developer Tenant)

**Key Capabilities**:

- **Automated Identity Lifecycle**: User and group provisioning via CI/CD pipelines
- **Zero Trust Security**: Automated deployment of Conditional Access and Named Locations
- **Privileged Access**: Programmatic configuration of PIM for Groups
- **Graph API Mastery**: Direct API interaction without SDK dependencies
- **Pipeline Orchestration**: YAML-based Azure DevOps pipelines with service connections
- **Configuration Validation**: JSON schema validation for error prevention
- **Secure Authentication**: Service principal integration with least privilege

**Learning Paths**:

- **Foundation**: Pipeline setup, service connections, and basic user/group automation
- **Security**: Conditional Access policies, Named Locations, and Authentication Methods
- **Governance**: Privileged Identity Management (PIM) and lifecycle workflows
- **Advanced**: Complex JSON schema design and multi-tenant deployment patterns

**Coverage Depth**: ~35% of Entra landscape (Automation & Governance focus)

### [Entra Zero Trust RBAC Simulation](./Entra-Zero-Trust-RBAC-Simulation/)

**Focus**: Advanced RBAC, Identity Governance (IGA), and Zero Trust Architecture

**Target Audience**: Identity Architects, Security Engineers, Compliance Officers

**Duration**: 10-15 hours | **Cost**: $0 (M365 Developer Tenant)

**Key Capabilities**:

- **Delegated Administration**: Administrative Units and Custom Roles
- **Identity Governance**: Entitlement Management (Access Packages) and Access Reviews
- **Lifecycle Management**: Lifecycle Workflows for JML processes
- **App Governance**: App Consent Policies and Service Principal security
- **Advanced RBAC**: Custom Role Definitions and Scoped Assignments
- **Simulation Framework**: PowerShell-based lab environment with validation and cleanup

**Learning Paths**:

- **Foundation**: Identity hierarchy, tenant hardening, and break-glass accounts
- **Delegation**: Administrative Units and custom role definitions
- **Governance**: Entitlement management, access reviews, and lifecycle workflows
- **Security**: Conditional Access, Identity Protection, and authentication methods

**Coverage Depth**: ~45% of Entra landscape (Governance & Security focus)

---

## 📊 Comprehensive Microsoft Entra Capability Coverage

### Coverage Matrix

This matrix shows which project covers each Entra capability, highlighting the vast landscape of Entra skills.

#### ✅ Identity Administration & Lifecycle

| Capability | Complexity | Entra-Deployment-Pipelines Coverage | Entra-Zero-Trust-RBAC-Simulation Coverage |
|------------|------------|-------------------------------------|-------------------------------------------|
| **User Provisioning** | INTERMEDIATE | ✅ COMPREHENSIVE (Create, Update, Disable) | ✅ COMPREHENSIVE (Lab 01) |
| **Group Management** | BASIC | ✅ COMPREHENSIVE (Create, Members, Owners) | ✅ COMPREHENSIVE (Lab 01) |
| **Dynamic Groups** | INTERMEDIATE | ✅ COMPREHENSIVE (JSON Config) | ✅ COMPREHENSIVE (Lab 01/02) |
| **Administrative Units** | INTERMEDIATE | ❌ Not Covered (Restricted management scopes) | ✅ COMPREHENSIVE (Lab 02) |
| **Custom Security Attributes** | ADVANCED | ❌ Not Covered (Attribute definition & assignment) | ❌ Not Covered |
| **Company Branding** | BASIC | ✅ DETAILED (Logo, Colors, Text) | ❌ Not Covered |

#### ✅ Access Management & Zero Trust

| Capability | Complexity | Entra-Deployment-Pipelines Coverage | Entra-Zero-Trust-RBAC-Simulation Coverage |
|------------|------------|-------------------------------------|-------------------------------------------|
| **Conditional Access** | ADVANCED | ✅ COMPREHENSIVE (Risk, Location, Device, App) | ✅ COMPREHENSIVE (Lab 06) |
| **Named Locations** | INTERMEDIATE | ✅ COMPREHENSIVE (IP Ranges, Countries) | ❌ Not Covered |
| **MFA Configuration** | INTERMEDIATE | ✅ DETAILED (Auth Methods Policy) | ✅ DETAILED (Lab 06) |
| **Passwordless/FIDO2** | ADVANCED | ✅ DETAILED (FIDO2 Policy) | ✅ DETAILED (Lab 06) |
| **Identity Protection** | ADVANCED | ✅ EXTENSIVE (User Risk & Sign-in Risk Policies) | ✅ EXTENSIVE (Lab 06) |
| **Global Secure Access** | EXPERT | ❌ Not Covered (SSE/ZTNA configuration) | ❌ Not Covered |
| **External ID (B2B/B2C)** | ADVANCED | ❌ Not Covered (Cross-tenant access settings) | ❌ Not Covered |

#### ✅ Identity Governance (IGA)

| Capability | Complexity | Entra-Deployment-Pipelines Coverage | Entra-Zero-Trust-RBAC-Simulation Coverage |
|------------|------------|-------------------------------------|-------------------------------------------|
| **Privileged Identity Mgmt** | ADVANCED | ✅ EXTENSIVE (PIM for Groups) | ✅ EXTENSIVE (Lab 04) |
| **Entitlement Management** | ADVANCED | ❌ Not Covered (Access Packages, Catalogs) | ✅ COMPREHENSIVE (Lab 05) |
| **Access Reviews** | ADVANCED | ❌ Not Covered (Recertification campaigns) | ✅ COMPREHENSIVE (Lab 07) |
| **Lifecycle Workflows** | ADVANCED | ❌ Not Covered (Joiner/Mover/Leaver automation) | ✅ COMPREHENSIVE (Lab 07) |
| **Permissions Management** | EXPERT | ❌ Not Covered (CIEM/Multi-cloud permissions) | ❌ Not Covered |

#### ✅ Workload Identities

| Capability | Complexity | Entra-Deployment-Pipelines Coverage | Entra-Zero-Trust-RBAC-Simulation Coverage |
|------------|------------|-------------------------------------|-------------------------------------------|
| **App Registrations** | INTERMEDIATE | ❌ Not Covered (OAuth2/OIDC app config) | ✅ DETAILED (Lab 03) |
| **Managed Identities** | INTERMEDIATE | ❌ Not Covered (Azure resource identity) | ❌ Not Covered |
| **Workload ID Federation** | ADVANCED | ❌ Not Covered (OIDC federation/GitHub Actions) | ❌ Not Covered |
| **Service Principals** | INTERMEDIATE | ✅ COMPREHENSIVE (Pipeline authentication) | ✅ DETAILED (Lab 03) |

#### ✅ DevSecOps & Automation

| Capability | Complexity | Entra-Deployment-Pipelines Coverage | Entra-Zero-Trust-RBAC-Simulation Coverage |
|------------|------------|-------------------------------------|-------------------------------------------|
| **Azure DevOps Pipelines** | INTERMEDIATE | ✅ COMPREHENSIVE (YAML, Triggers, Variables) | ❌ Not Covered |
| **Microsoft Graph API** | ADVANCED | ✅ COMPREHENSIVE (Direct REST calls) | ✅ COMPREHENSIVE (PowerShell SDK) |
| **Infrastructure as Code** | ADVANCED | ✅ COMPREHENSIVE (Declarative JSON) | ✅ COMPREHENSIVE (PowerShell Scripts) |
| **Schema Validation** | ADVANCED | ✅ COMPREHENSIVE (JSON Schema Draft-07) | ❌ Not Covered |
| **Service Principal Auth** | INTERMEDIATE | ✅ COMPREHENSIVE (App Registration, Secrets) | ✅ DETAILED (Connect Scripts) |

---

## 🔮 Future Skilling Opportunities

The current portfolio focuses on **Core Identity**, **Automation**, and **Governance**. To achieve **Entra Architect** status, consider expanding your skills into these advanced areas not yet covered by the projects:

### 1. External Identities & Cross-Tenant Access

- **B2B Collaboration**: Configuring Cross-Tenant Access Settings (inbound/outbound trust).
- **B2B Direct Connect**: Enabling Teams Shared Channels.
- **Verified ID**: Implementing decentralized identity credentials.

### 2. Workload Identity & DevSecOps

- **Workload ID Federation**: Replacing secrets with OIDC federation (e.g., for GitHub Actions).
- **Permissions Management**: CIEM for right-sizing permissions across Azure, AWS, and GCP.

### 3. Zero Trust Network Access (SSE)

- **Microsoft Entra Internet Access**: Secure Web Gateway (SWG) for SaaS apps.
- **Microsoft Entra Private Access**: ZTNA replacement for VPNs.

---

## 🎯 Project Selection Guide

### Choose Entra-Deployment-Pipelines When You Need

- ✅ **Infrastructure as Code experience** for identity
- ✅ **DevOps pipeline skills** (Azure DevOps)
- ✅ **Graph API automation expertise**
- ✅ **Repeatable deployment patterns** for multiple tenants
- ✅ **Disaster recovery preparation** (identity config as code)
- ✅ **Strict change management** requirements

**Best For**: Identity Engineers, DevOps Engineers, Cloud Architects, MSPs managing multiple tenants

### Choose Entra-Zero-Trust-RBAC-Simulation When You Need

- ✅ **Deep dive into Identity Governance** (IGA)
- ✅ **Advanced RBAC and delegation models**
- ✅ **Hands-on experience with Administrative Units**
- ✅ **Understanding of Entitlement Management**
- ✅ **Simulation of real-world identity scenarios**
- ✅ **PowerShell scripting mastery** for Entra

**Best For**: Identity Architects, Security Engineers, Compliance Officers, IAM Administrators


---

## 💼 Professional Skills Development

### Skills Portfolio

Completing these projects demonstrates proficiency in:

**Core Technical Competencies**:

- **Identity as Code**: Managing Entra resources using declarative configuration files
- **Pipeline Automation**: Building and maintaining CI/CD workflows for identity
- **Graph API Integration**: Constructing complex REST API requests for identity management
- **Zero Trust Implementation**: Deploying Conditional Access and strong authentication at scale
- **Privileged Access Management**: Configuring PIM for just-in-time access
- **JSON Data Modeling**: Designing schemas for configuration validation

**Business & Compliance Competencies**:

- **Change Management**: Implementing Git-based workflows for identity changes
- **Audit & Compliance**: Creating auditable deployment trails
- **Standardization**: Enforcing consistent security baselines across environments
- **Operational Efficiency**: Reducing manual effort and human error

### Certification Alignment

These projects provide hands-on experience aligned with:

- **Microsoft Certified: Identity and Access Administrator Associate** (SC-300)
- **Microsoft Certified: DevOps Engineer Expert** (AZ-400)
- **Microsoft Certified: Security, Compliance, and Identity Fundamentals** (SC-900)

### Career Paths

**Roles supported by this expertise**:

- Identity Engineer
- DevSecOps Engineer
- Cloud Security Architect
- Azure Administrator
- Automation Engineer
- IAM Consultant

---

## 📖 Additional Resources

**Microsoft Official Documentation**:

- [Microsoft Entra Documentation](https://learn.microsoft.com/en-us/entra/)
- [Microsoft Graph API Reference](https://learn.microsoft.com/en-us/graph/api/overview)
- [Azure DevOps Documentation](https://learn.microsoft.com/en-us/azure/devops/)

**Certification Resources**:

- [SC-300: Microsoft Identity and Access Administrator](https://learn.microsoft.com/en-us/certifications/exams/sc-300)
- [AZ-400: Designing and Implementing Microsoft DevOps Solutions](https://learn.microsoft.com/en-us/certifications/exams/az-400)

---

## 🤖 AI-Assisted Content Generation

This comprehensive Microsoft Entra learning portfolio overview was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra capability analysis, professional skills development frameworks, and comprehensive coverage mapping validated against current Microsoft Learn documentation as of November 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Microsoft Entra capabilities while maintaining technical accuracy, professional skills alignment for career development, and reflecting industry best practices for identity automation, DevSecOps, and Zero Trust security.*
