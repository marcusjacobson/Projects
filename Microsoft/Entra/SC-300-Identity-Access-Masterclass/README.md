# SC-300 Identity & Access Masterclass

This project provides a comprehensive, hands-on simulation for preparing for the **SC-300: Microsoft Identity and Access Administrator** certification. It is designed to take you from a "Greenfield" tenant to a fully governed, secure environment, mirroring the real-world journey of an Identity Administrator.

## 🎯 Project Overview

This masterclass guides you through the end-to-end process of setting up a secure Microsoft Entra ID tenant. Unlike the exam's domain order, this project follows a logical deployment progression:

1. **Identity Foundation**: Setting up the tenant, users, and groups.
2. **Secure Authentication**: Implementing Zero Trust access controls.
3. **Workload Identities**: Integrating applications and services.
4. **Governance & Zero Trust**: Automating access and privilege management.
5. **Monitoring**: Auditing and reporting on identity security.

## ⏱️ Time & Resource Considerations

- **Estimated Time**: ~8-10 hours to complete all labs.
- **Skill Level**: Intermediate.
- **Prerequisites**:
  - A Microsoft Entra ID tenant (Free Tier is sufficient for foundational labs).
  - Global Administrator access.
  - **Licenses**: Microsoft Entra ID P2 (Free 30-day trial available) is required for advanced features like PIM, Identity Protection, and Entitlement Management.

## 📚 Lab Progression

| Phase | Lab | Focus | Delivery |
| :--- | :--- | :--- | :--- |
| **00** | [Tenant Setup](./00-Prerequisites/Lab-00-Tenant-Setup.md) | Entra Tenant, P2 License | Portal |
| **01** | [Tenant Config](./01-Identity-Foundation/Lab-01-Tenant-Config.md) | Branding, Custom Domains | Portal |
| **01** | [User Lifecycle](./01-Identity-Foundation/Lab-02-User-Lifecycle.md) | Bulk Creation, Dynamic Groups | PowerShell/Portal |
| **01** | [Admin Units](./01-Identity-Foundation/Lab-03-Administrative-Units.md) | Delegation, Scoped Roles | Portal |
| **01** | [Hybrid Sim](./01-Identity-Foundation/Lab-04-Hybrid-Simulation.md) | Connect Sync Concepts | Portal |
| **02** | [Auth Methods](./02-Secure-Auth/Lab-05-Auth-Methods.md) | FIDO2, Authenticator, SSPR | Portal |
| **02** | [Conditional Access](./02-Secure-Auth/Lab-06-Conditional-Access.md) | Zero Trust Policies | Portal |
| **02** | [Identity Protection](./02-Secure-Auth/Lab-07-Identity-Protection.md) | Risk Policies | Portal |
| **02** | [External Identities](./02-Secure-Auth/Lab-08-External-Identities.md) | B2B, Guest Access | Portal |
| **03** | [App Registration](./03-Workload-Identities/Lab-09-App-Registration.md) | App Roles, API Permissions | Portal |
| **03** | [Enterprise Apps](./03-Workload-Identities/Lab-10-Enterprise-Apps.md) | SSO, Assignment | Portal |
| **03** | [App Governance](./03-Workload-Identities/Lab-11-App-Governance.md) | Consent, Permissions | Portal |
| **04** | [PIM](./04-Governance-Zero-Trust/Lab-12-PIM-Roles.md) | JIT Access | Portal |
| **04** | [Access Reviews](./04-Governance-Zero-Trust/Lab-13-Access-Reviews.md) | Guest Reviews | Portal |
| **04** | [Entitlement Mgmt](./04-Governance-Zero-Trust/Lab-14-Entitlement-Management.md) | Access Packages | Portal |
| **05** | [Sign-in Logs](./05-Monitoring/Lab-15-Sign-in-Logs.md) | Troubleshooting | Portal |
| **05** | [Audit Logs](./05-Monitoring/Lab-16-Audit-Logs.md) | Tracking Changes | Portal |

## 📊 Microsoft Entra Capability Coverage

### Covered Capabilities by Category

#### ✅ Identity Governance & Administration (IGA)

| Capability | Coverage Level | Project Section(s) |
| :--- | :--- | :--- |
| **Entitlement Management** | ✅ COMPREHENSIVE | Lab 13 (Catalogs, Access Packages) |
| **Access Reviews** | ✅ EXTENSIVE | Lab 14 (Guest reviews) |
| **Privileged Identity Management** | ✅ COMPREHENSIVE | Lab 12 (PIM for Roles, Activation) |
| **Administrative Units** | ✅ DETAILED | Lab 03 (Delegation) |

#### ✅ Zero Trust Security & Access Control

| Capability | Coverage Level | Project Section(s) |
| :--- | :--- | :--- |
| **Conditional Access** | ✅ COMPREHENSIVE | Lab 06 (MFA, Block Legacy Auth) |
| **Identity Protection** | ✅ EXTENSIVE | Lab 07 (User/Sign-in Risk) |
| **Authentication Methods** | ✅ DETAILED | Lab 05 (FIDO2, SSPR) |
| **External Identities** | ✅ DETAILED | Lab 08 (B2B Settings) |

#### ✅ Workload Identities & Application Security

| Capability | Coverage Level | Project Section(s) |
| :--- | :--- | :--- |
| **App Registration** | ✅ DETAILED | Lab 09 (App Roles, APIs) |
| **Enterprise Apps** | ✅ DETAILED | Lab 10 (SSO, Assignment) |
| **Managed Identities** | ✅ DETAILED | Lab 11 (User-Assigned) |

#### ✅ Monitoring & Automation

| Capability | Coverage Level | Project Section(s) |
| :--- | :--- | :--- |
| **Log Analytics** | ✅ DETAILED | Lab 15 (Diagnostics) |
| **KQL Querying** | ✅ DETAILED | Lab 16 (Hunting) |
| **PowerShell Automation** | ✅ TARGETED | Lab 02, Lab 11 (Bulk Ops) |

### What This Project Does NOT Cover

The following capabilities require **hybrid infrastructure**, **external services**, or **specialized hardware** beyond this project's cloud-only simulation scope:

#### ❌ Hybrid Identity (Requires On-Premises Infrastructure)

| Capability | Why Not Covered |
| :--- | :--- |
| **Entra Connect Sync** | Requires on-premises Active Directory Domain Services (Covered conceptually in Lab 04) |
| **Password Hash Sync (PHS)** | Dependent on hybrid sync engine |
| **Pass-through Auth (PTA)** | Dependent on on-premises agents |
| **Active Directory Federation (ADFS)** | Legacy on-premises infrastructure not covered |

#### ❌ Device Management (Requires Intune/Hardware)

| Capability | Why Not Covered |
| :--- | :--- |
| **Intune Device Compliance** | Requires Intune license and physical/VM devices to enroll |
| **Windows Hello for Business** | Requires device enrollment and TPM hardware |

## 🤖 AI-Assisted Content Generation

This project was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for SC-300 certification preparation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exam objectives while maintaining technical accuracy.*
