# Zero Trust Alignment Guide

This document outlines how the **Entra Zero Trust RBAC Simulation** project aligns with Microsoft's Zero Trust security model. It maps the specific configurations, policies, and labs in this simulation to the core principles and pillars of Zero Trust.

## Core Zero Trust Principles

The Microsoft Zero Trust model is built on three guiding principles. Here is how this project implements them:

### 1. Verify Explicitly

*Always authenticate and authorize based on all available data points, including user identity, location, device health, service or workload, data classification, and anomalies.*

**Project Alignment:**

- **Conditional Access Policies**: The simulation implements granular CA policies (Lab 06) that verify user identity, location (Named Locations), and risk level before granting access.
- **Strong Authentication**: MFA enforcement is a core component of the identity foundation (Lab 01).
- **Identity Protection**: Integration with Identity Protection (Lab 06) ensures that risky sign-ins are detected and blocked or challenged.

### 2. Use Least Privilege Access

*Limit user access with just-in-time and just-enough-access (JIT/JEA), risk-based adaptive polices, and data protection to help secure both data and productivity.*

**Project Alignment:**

- **RBAC Structure**: The project defines a strict hierarchy of Administrative Units (AUs) and custom roles (Lab 02) to ensure admins only have access to their specific scope (e.g., "Helpdesk (US)").
- **Privileged Identity Management (PIM)**: Critical roles like Global Admin and Security Admin are not permanently assigned. Instead, they are eligible roles requiring activation, justification, and approval (Lab 04).
- **Entitlement Management**: Access Packages (Lab 05) ensure users only have access to the resources they need for the duration they need it.

### 3. Assume Breach

*Minimize blast radius and segment access. Verify end-to-end encryption and use analytics to get visibility, drive threat detection, and improve defenses.*

**Project Alignment:**

- **Segmentation**: Administrative Units (Lab 02) segment management capabilities, preventing a compromised helpdesk account in one region from affecting the entire tenant.
- **Break Glass Accounts**: The inclusion of emergency access accounts (Lab 01) acknowledges the possibility of identity system failure or compromise.
- **Monitoring & Reporting**: The validation phase (Lab 08) emphasizes the importance of audit logs and sign-in logs to detect anomalies.

---

## Alignment by Zero Trust Pillar

This simulation primarily focuses on the **Identity** pillar, which is the control plane for Zero Trust, but it touches on others as well.

| Zero Trust Pillar | Project Component | Alignment Description | Gaps / Future Work |
|-------------------|-------------------|-----------------------|--------------------|
| **Identity** | **Labs 01, 02, 04, 05, 06** | **Strong Alignment.** The project covers the entire identity lifecycle: foundation, protection, governance, and privileged access. It uses Entra ID as the central policy enforcement point. | Integration with HR-driven provisioning (inbound) is currently manual/simulated. |
| **Endpoints (Devices)** | **Lab 06 (Conditional Access)** | **Partial Alignment.** Conditional Access policies reference device compliance states (e.g., "Require Compliant Device"). | The project assumes device compliance signals are present but does not simulate the Intune/MDM enrollment process itself. |
| **Applications** | **Lab 03 (App Integration)** | **Strong Alignment.** Enterprise Applications are configured with specific roles and assignment requirements. SSO is emphasized. | Deeper integration with Defender for Cloud Apps for session control could be added. |
| **Data** | **Lab 05 (Entitlement Mgmt)** | **Partial Alignment.** Access to SharePoint sites is governed via Access Packages. | Does not currently include Purview Information Protection labels or DLP policies (covered in separate Purview projects). |
| **Infrastructure** | **Lab 02 (RBAC)** | **Indirect Alignment.** RBAC principles applied here for Entra roles set the stage for Azure RBAC for infrastructure resources. | Direct Azure Resource (Subscription/VM) RBAC is outside the scope of this specific Entra simulation. |
| **Network** | **Lab 06 (Named Locations)** | **Partial Alignment.** Uses "Trusted Locations" and "Blocked Countries" to gate access based on network location. | Does not cover Private Link, VNET injection, or Azure Firewall integration. |
| **Visibility** | **Lab 08 (Reporting)** | **Strong Alignment.** Focuses on using Log Analytics and Entra Workbooks to visualize security posture and access patterns. | Could be expanded to include Sentinel integration for automated incident response. |

## Maturity Model Assessment

Based on the [Microsoft Zero Trust Maturity Model](https://learn.microsoft.com/en-us/security/zero-trust/maturity-model), this project moves an organization from **Traditional** to **Advanced/Optimal** stages in the Identity pillar:

- **Traditional**: On-premises identity, static passwords. *(Project starts after this stage)*
- **Advanced**: Hybrid identity, MFA enforcement, conditional access, basic PIM. *(Core of Labs 01-04)*
- **Optimal**: Automated identity governance, risk-based policies, continuous validation. *(Labs 05-07)*

## Recommendations for "Optimal" State

To fully achieve an "Optimal" Zero Trust state based on this simulation foundation, consider the following enhancements:

1. **Automate Lifecycle Workflows**: Fully implement Lifecycle Workflows (Lab 07) to automate joiner/mover/leaver processes without manual intervention.
2. **Integrate Signals**: Connect Microsoft Defender for Endpoint signals to Conditional Access policies to block compromised devices in real-time.
3. **Passwordless**: Transition from MFA to Passwordless authentication (FIDO2/Windows Hello) for a better user experience and higher security assurance.
