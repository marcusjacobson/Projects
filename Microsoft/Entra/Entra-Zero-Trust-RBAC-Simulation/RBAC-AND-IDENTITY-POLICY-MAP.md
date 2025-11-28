# 🗺️ RBAC & Identity Policy Map

This document provides a comprehensive map of the Role-Based Access Control (RBAC) structures, Identity Policies, and Governance configurations deployed throughout the **Entra Zero Trust RBAC Simulation**.

It serves as a quick reference for understanding the "who, what, and where" of the simulated environment.

## 🏗️ Lab 01: Identity Foundation

Establishes the core hierarchy and naming standards.

### 👥 User & Group Hierarchy

| Type | Naming Convention | Purpose | Examples |
| :--- | :--- | :--- | :--- |
| **Users** | `USR-[Role]-[Random]` | Standard identity format | `USR-ITAdmin-8x92`, `USR-Finance-2k19` |
| **Security Groups** | `GRP-SEC-[Dept]` | Departmental membership | `GRP-SEC-IT`, `GRP-SEC-HR`, `GRP-SEC-Finance` |
| **Break Glass** | `ADM-BreakGlass-[ID]` | Emergency access accounts | `ADM-BreakGlass-01` |

### 🛡️ Tenant Hardening Policies

- **User Settings**: Restrict access to Azure AD administration portal.
- **Group Settings**: Restrict ability to create Microsoft 365 groups.
- **External Collaboration**: Restrict guest invitations to specific admin roles.

---

## 🏢 Lab 02: Delegated Administration

Implements administrative boundaries using Administrative Units (AUs).

### 📦 Administrative Units (AUs)

| AU Name | Description | Restricted Management? |
| :--- | :--- | :--- |
| **AU-IT-Operations** | Contains IT staff and devices | No |
| **AU-HR-Systems** | Contains HR staff and sensitive accounts | No |
| **AU-Executive-Leadership** | Contains C-Suite identities | **Yes** (Highly Restricted) |

### 🔑 Delegated Roles (Scoped to AUs)

- **User Administrator** (Scoped to `AU-IT-Operations`)
- **Helpdesk Administrator** (Scoped to `AU-HR-Systems`)

---

## 📱 Lab 03: App Integration

Governs how applications interact with the directory.

### 📝 App Consent Policies

| Policy Name | Risk Level | Allowed Actions |
| :--- | :--- | :--- |
| **Low-Risk-App-Policy** | Low | Users can consent to low-impact permissions (e.g., `User.Read`) |
| **Admin-Review-Policy** | Medium/High | Requires Admin Consent workflow |

### 🤖 Service Principals

- **SP-Reporting-Automation**: Automated service account for generating reports (Certificate-based auth).

---

## 👑 Lab 04: RBAC & PIM

Defines custom roles and Just-in-Time (JIT) access.

### 🛠️ Custom Roles

| Role Name | Permissions | Scope |
| :--- | :--- | :--- |
| **Custom-App-Manager** | `microsoft.directory/applications/create`, `update` | Tenant-wide |
| **Custom-AU-Admin** | `microsoft.directory/administrativeUnits/manage` | Tenant-wide |

### ⏳ Privileged Identity Management (PIM)

| Role / Group | Assignment Type | Activation Req. | Duration |
| :--- | :--- | :--- | :--- |
| **Global Administrator** | Eligible | MFA + Ticket + Approval | 4 Hours |
| **User Administrator** | Eligible | MFA | 8 Hours |
| **GRP-PIM-Security-Admins** | Eligible | MFA + Justification | 8 Hours |

---

## 📦 Lab 05: Entitlement Management

Automates access requests via Access Packages.

### 📚 Catalogs & Access Packages

| Catalog | Access Package | Target Audience | Approval Policy |
| :--- | :--- | :--- | :--- |
| **CAT-Departmental-Access** | **PKG-Finance-Standard** | Internal Users | Manager Approval |
| **CAT-External-Collab** | **PKG-Vendor-Project-X** | Guest Users | Sponsor Approval |

---

## 🛡️ Lab 06: Identity Security

Enforces Zero Trust access controls.

### 🚦 Conditional Access Policies

| Policy Name | Target | Conditions | Controls |
| :--- | :--- | :--- | :--- |
| **CA001-Require-MFA-AllUsers** | All Users (Excl. Break Glass) | All Cloud Apps | Require MFA |
| **CA002-Block-Legacy-Auth** | All Users | Legacy Clients | Block Access |
| **CA003-Admin-PhishingResistant** | Admins | All Cloud Apps | Require Phishing-Resistant MFA |
| **CA004-Risk-Based-Access** | All Users | High User/Sign-in Risk | Block or Require Password Change |

### 🔐 Authentication Methods

- **FIDO2 Security Keys**: Enabled for all users (Enforced for Admins).
- **Microsoft Authenticator**: Enabled with Number Matching.
- **SMS/Voice**: Disabled for administrative roles.

---

## 🔄 Lab 07: Lifecycle Governance

Manages the Joiner-Mover-Leaver (JML) process.

### ♻️ Lifecycle Workflows

| Workflow | Trigger | Actions |
| :--- | :--- | :--- |
| **LIFECYCLE-Leaver-RealTime** | On-Demand | Disable Account, Remove Licenses, Remove Group Membership |
| **LIFECYCLE-Mover-Update** | Attribute Change | Update Group Memberships based on Dept change |

### 👁️ Access Reviews

| Review Name | Target | Frequency | Reviewer |
| :--- | :--- | :--- | :--- |
| **REV-Guest-Access-Monthly** | All Guests | Monthly | Self-Review |
| **REV-Admin-Roles-Quarterly** | PIM Assignments | Quarterly | Security Team |

---

## 🤖 AI-Assisted Content Generation

This policy map was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for Entra ID security and PowerShell automation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Identity Governance topics while maintaining technical accuracy and reflecting Microsoft best practices.*
