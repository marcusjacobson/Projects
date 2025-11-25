# Entra Zero Trust RBAC Simulation

This project provides a comprehensive, hands-on simulation for building a production-ready Microsoft Entra ID environment from scratch. It focuses on implementing Zero Trust principles, Role-Based Access Control (RBAC), and Identity Governance using PowerShell automation.

## 🎯 Project Overview

This simulation guides you through the end-to-end process of setting up a secure Entra ID tenant. You will start with a blank slate and progressively build a sophisticated identity architecture that includes:

- **Identity Foundation**: Structured user/group hierarchy with strict naming conventions.
- **Zero Trust Security**: Phishing-resistant MFA, Conditional Access, and Break Glass accounts.
- **Least Privilege**: Administrative Units (AUs), Custom Roles, and Privileged Identity Management (PIM).
- **Governance**: Entitlement Management, Access Reviews, and Lifecycle Workflows.
- **Monitoring**: Log Analytics integration for comprehensive audit trails.

The entire environment is deployed using **Microsoft Graph PowerShell SDK**, providing a library of reusable, enterprise-grade scripts.

## ⏱️ Time & Resource Considerations

- **Estimated Time**: ~4-6 hours to complete all labs.
- **Skill Level**: Intermediate to Advanced.
- **Prerequisites**:
  - A Microsoft Entra ID tenant (Developer tenant recommended).
  - Global Administrator access.
  - **Licenses**: Entra ID P2 (or Microsoft Entra Suite) is required for PIM, Entitlement Management, and Lifecycle Workflows.

## 📚 Lab Progression

The project is structured as a sequential series of labs. It is critical to follow the **Order of Operations** to ensure dependencies are met.

| Lab | Module | Focus |
| :--- | :--- | :--- |
| **00** | [Prerequisites & Monitoring](./00-Prerequisites-and-Monitoring/README.md) | Log Analytics, Diagnostic Settings, SDK Setup |
| **01** | [Identity Foundation](./01-Identity-Foundation/README.md) | User/Group Hierarchy, Naming Conventions, Tenant Hardening |
| **02** | [Delegated Administration](./02-Delegated-Administration/README.md) | Administrative Units (AUs), Restricted Management AUs |
| **03** | [App Integration](./03-App-Integration/README.md) | App Consent Governance, Service Principals |
| **04** | [RBAC & PIM](./04-RBAC-and-PIM/README.md) | Custom Roles, PIM for Roles & Groups |
| **05** | [Entitlement Management](./05-Entitlement-Management/README.md) | Access Packages, Catalogs, External Governance |
| **06** | [Identity Security](./06-Identity-Security/README.md) | Phishing-Resistant MFA, Conditional Access, Break Glass |
| **07** | [Lifecycle Governance](./07-Lifecycle-Governance/README.md) | Lifecycle Workflows (JML), Access Reviews |
| **08** | [Validation & Demo](./08-Final-Validation-and-Demo/README.md) | End-to-End Testing, Configuration Reporting |
| **09** | [Project Cleanup](./09-Project-Cleanup/README.md) | Full Environment Teardown |

## 📊 Microsoft Entra Capability Coverage

### What This Project Covers

This project provides **hands-on practical experience with core Microsoft Entra ID Zero Trust and Governance capabilities**, focusing on:

- **Identity Governance** (Entitlement Management, Access Reviews, Lifecycle Workflows)
- **Privileged Identity Management** (PIM for Roles and Groups, Just-in-Time access)
- **Zero Trust Security** (Conditional Access, Phishing-Resistant MFA, Break Glass accounts)
- **Delegated Administration** (Administrative Units, Custom Roles, Restricted Management)
- **Application Security** (Service Principals, App Consent Policies)
- **Monitoring & Observability** (Log Analytics integration, Diagnostic Settings)
- **PowerShell Automation** (Microsoft Graph PowerShell SDK, enterprise-grade scripting)

**Coverage Depth**: ~60% of total Microsoft Entra ID P2 capability landscape with **deep hands-on simulation experience** in covered areas (production-ready automation patterns).

### Covered Capabilities by Category

#### ✅ Identity Governance & Administration (IGA) (90% Simulation Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Entitlement Management** | ✅ COMPREHENSIVE | Lab 05 (Catalogs, Access Packages, External Governance) |
| **Access Reviews** | ✅ EXTENSIVE | Lab 07 (Guest reviews, High-privilege role reviews) |
| **Lifecycle Workflows** | ✅ EXTENSIVE | Lab 07 (Leaver scenarios, automated offboarding) |
| **Privileged Identity Management** | ✅ COMPREHENSIVE | Lab 04 (PIM for Roles, PIM for Groups, Activation) |
| **PIM for Groups** | ✅ DETAILED | Lab 04 (Just-in-Time access to privileged groups) |

#### ✅ Zero Trust Security & Access Control (85% Simulation Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Conditional Access** | ✅ COMPREHENSIVE | Lab 06 (Report-only policies, MFA enforcement, Legacy Auth block) |
| **Identity Protection** | ✅ EXTENSIVE | Lab 06 (User Risk, Sign-in Risk policies) |
| **Authentication Methods** | ✅ DETAILED | Lab 06 (FIDO2/Passkey, Microsoft Authenticator enforcement) |
| **Break Glass Accounts** | ✅ COMPREHENSIVE | Lab 01 & 06 (Creation, Exclusion from CA, Monitoring) |
| **Tenant Hardening** | ✅ EXTENSIVE | Lab 01 (User/Group settings, Collaboration restrictions) |

#### ✅ Delegated Administration & RBAC (80% Simulation Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Administrative Units (AUs)** | ✅ COMPREHENSIVE | Lab 02 (AU creation, Dynamic membership, Scoped roles) |
| **Restricted Management AUs** | ✅ DETAILED | Lab 02 (Hardening specific high-value targets) |
| **Custom RBAC** | ✅ EXTENSIVE | Lab 04 (Creating custom role definitions, Scoped assignments) |
| **Group-Based Licensing** | ✅ DETAILED | Lab 01 (Automated license assignment via groups) |

#### ✅ Application Identity & Security (85% Simulation Features)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **App Consent Governance** | ✅ COMPREHENSIVE | Lab 03 (Risk-based step-up consent policies) |
| **Service Principal Management** | ✅ EXTENSIVE | Lab 03 (Creation, Certificate-based auth) |
| **Enterprise App Config** | ✅ DETAILED | Lab 03 (Assignment requirements, Visibility) |
| **Workload Identity Basics** | ✅ DETAILED | Lab 03 (Service Principal security) |

#### ✅ Automation & Monitoring (95% Simulation Operations)

| Capability | Coverage Level | Project Section(s) |
|------------|----------------|-------------------|
| **Microsoft Graph PowerShell SDK** | ✅ COMPREHENSIVE | All Labs (Primary automation engine) |
| **Log Analytics Integration** | ✅ EXTENSIVE | Lab 00 (Diagnostic settings, Workspace creation) |
| **KQL Querying** | ✅ DETAILED | Lab 00 & 08 (Auditing, Sign-in logs analysis) |
| **Configuration Reporting** | ✅ COMPREHENSIVE | Lab 08 (JSON-based configuration exports) |

### What This Project Does NOT Cover

The following capabilities require **hybrid infrastructure**, **external services**, or **specialized hardware** beyond this project's cloud-only simulation scope:

#### ❌ Hybrid Identity (Requires On-Premises Infrastructure)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Entra Connect Sync** | ADVANCED | Requires on-premises Active Directory Domain Services |
| **Cloud Sync** | INTERMEDIATE | Requires on-premises agents |
| **Password Hash Sync (PHS)** | INTERMEDIATE | Dependent on hybrid sync engine |
| **Pass-through Auth (PTA)** | ADVANCED | Dependent on on-premises agents |
| **Active Directory Federation (ADFS)** | EXPERT | Legacy on-premises infrastructure not covered |

#### ❌ Device Management (Requires Intune/Hardware)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Intune Device Compliance** | ADVANCED | Requires Intune license and physical/VM devices to enroll |
| **Hybrid Azure AD Join** | ADVANCED | Requires on-premises AD and device line-of-sight |
| **Windows Hello for Business** | INTERMEDIATE | Requires device enrollment and TPM hardware |

#### ❌ External Identities & CIAM (Specialized Scenarios)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Entra External ID (B2C)** | ADVANCED | Requires separate B2C tenant creation |
| **B2B Direct Connect** | ADVANCED | Requires two cooperating Entra tenants |
| **Cross-Tenant Sync** | ADVANCED | Requires multi-tenant environment |

#### ❌ Advanced Network & Legacy Access

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Global Secure Access (SSE)** | EXPERT | Requires advanced networking configuration |
| **App Proxy** | INTERMEDIATE | Requires on-premises connector for internal apps |
| **NPS Extension (Radius)** | INTERMEDIATE | Requires on-premises NPS server |

#### ❌ Operational & Advanced Security (Specialized/UI-Heavy)

| Capability | Complexity | Why Not Covered |
|------------|------------|-----------------|
| **Self-Service Password Reset (SSPR)** | INTERMEDIATE | Requires specific policy configuration distinct from Auth Methods |
| **Company Branding** | BASIC | UI-focused customization not suitable for automation simulation |
| **Entra Permissions Management (CIEM)** | EXPERT | Separate product requiring distinct licensing and setup |
| **Workload Identities Premium** | ADVANCED | Advanced Conditional Access for workloads not covered |
| **Verified ID** | ADVANCED | Decentralized identity infrastructure out of scope |

## 🚀 Quick Start

1. **Clone the repository**:

    ```powershell
    git clone https://github.com/marcusjacobson/Projects.git
    cd Projects/Microsoft/Entra/Entra-Zero-Trust-RBAC-Simulation
    ```

2. **Install Prerequisites**:
    Ensure you have the Microsoft Graph PowerShell SDK installed:

    ```powershell
    Install-Module Microsoft.Graph -Scope CurrentUser
    ```

3. **Start Lab 00**:
    Navigate to `00-Prerequisites-and-Monitoring` and follow the instructions to initialize your environment.

## 📁 Project Structure

```text
Entra-Zero-Trust-RBAC-Simulation/
├── 00-Prerequisites-and-Monitoring/  # Logging & Connectivity
├── 01-Identity-Foundation/           # Users, Groups, Hardening
├── 02-Delegated-Administration/      # Admin Units (AUs)
├── 03-App-Integration/               # App Consent & Service Principals
├── 04-RBAC-and-PIM/                  # Custom Roles & PIM
├── 05-Entitlement-Management/        # Access Packages
├── 06-Identity-Security/             # MFA, CA Policies, Break Glass
├── 07-Lifecycle-Governance/          # JML Workflows
├── 08-Final-Validation-and-Demo/     # Reporting & Testing
└── 09-Project-Cleanup/               # Teardown Scripts
```

## 💼 Professional Skills You'll Gain

By completing this simulation, you will develop practical skills in:

- **Zero Trust Architecture**: Implementing "Verify Explicitly" and "Use Least Privilege" in a real tenant.
- **PowerShell Automation**: Managing Entra ID at scale using the Graph SDK.
- **Identity Governance**: Designing and implementing automated access lifecycles.
- **Security Operations**: Configuring audit logging and monitoring for identity threats.

---

## 🤖 AI-Assisted Content Generation

This project was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for Entra ID security and PowerShell automation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Identity Governance topics while maintaining technical accuracy and reflecting Microsoft best practices.*
