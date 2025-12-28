# Purview Retail Data Protection Masterclass

This project simulates a real-world governance environment for a large retail chain, focusing on protecting customer PII and PCI-DSS data across the Microsoft 365 estate. It provides a comprehensive "from scratch" experience, moving from manual "click-ops" configuration to mature DevSecOps automation.

## 🎯 Project Objectives

- **Scenario-Based Learning**: Implement a governance strategy for a retail organization handling sensitive credit card and customer data.
- **High-Fidelity Simulation**: Generate and protect realistic data (Luhn-valid credit cards) to test high-confidence DLP matching.
- **Advanced Classification**: Deploy advanced features like Document Fingerprinting and Exact Data Match (EDM).
- **DevSecOps Maturity**: Transition from manual UI configuration to automated Infrastructure as Code (IaC) using PowerShell and Azure Pipelines.
- **Exfiltration Testing**: Validate policies by simulating real-world data exfiltration attempts.

## 📂 Project Structure

| Directory | Purpose |
|-----------|---------|
| `00-Prerequisites` | Setup scripts for Service Principals, Certificates, and Purview PAYG resources. |
| `01-Day-Zero-Setup` | **CRITICAL**: "Long-Lead" items (EDM indexing, Label publication) to be executed immediately to avoid wait times. |
| `02-Data-Foundation` | Scripts and templates for generating high-fidelity dummy data and loading it into M365 workloads. |
| `03-Classification-Design` | Documentation of the 4-Tier taxonomy, PCI-DSS mapping, and EDM schema definition. |
| `04-UI-Configuration` | Step-by-step guides for manual policy creation in the Purview Portal (Labels, DLP, Fingerprinting). |
| `05-Supplemental-IaC-Labs` | Automated deployment labs mirroring enterprise pipeline patterns for Custom SITs, Labels, and DLP. |
| `06-Exfiltration-Simulation` | Labs to simulate data exfiltration scenarios (USB, Teams, Sharing) to test policy effectiveness. |
| `07-Audit-and-Validation` | Guides for using Content Explorer and Activity Explorer to validate compliance and tune policies. |

## 🧠 Skills Coverage Matrix

| Skill / Technology | Lab / Section | Depth |
|-------------------|---------------|-------|
| **Purview Information Protection** | 04-UI-Configuration / 05-Supplemental-IaC-Labs | Advanced (Auto-labeling, EDM, Fingerprinting) |
| **Data Loss Prevention (DLP)** | 04-UI-Configuration / 05-Supplemental-IaC-Labs | Advanced (Endpoint, Teams, Custom SITs) |
| **PowerShell Automation** | 02-Data-Foundation / 05-Supplemental-IaC-Labs | Intermediate (Graph SDK, Data Generation) |
| **Azure DevOps Pipelines** | 05-Supplemental-IaC-Labs | Intermediate (YAML Pipelines, Service Connections) |
| **Microsoft Graph API** | 00-Prerequisites / 05-Supplemental-IaC-Labs | Intermediate (App-only Auth, Permissions) |
| **Data Governance Strategy** | 03-Classification-Design | Advanced (Taxonomy Design, Regulatory Mapping) |

## 🚀 Getting Started

1.  **Review Prerequisites**: Start with the `00-Prerequisites` folder to set up your environment and authentication.
2.  **Execute Day Zero Setup**: Immediately proceed to `01-Day-Zero-Setup` to initiate long-running backend processes.
3.  **Generate Data**: Use `02-Data-Foundation` to populate your tenant with realistic test data.
4.  **Configure Policies**: Follow the labs in `04-UI-Configuration` to build your governance framework.
5.  **Automate**: Explore `05-Supplemental-IaC-Labs` to implement the same policies using code.
6.  **Validate**: Run the simulations in `06-Exfiltration-Simulation` to test your defenses.

## ⚠️ Important Notes

- **Licensing**: This project requires **Microsoft 365 E5** (or E5 Compliance) and a **Purview Pay-As-You-Go (PAYG)** resource for full functionality.
- **Timing**: Some Purview features (EDM, Classifiers) have significant backend processing times (24-48 hours). Follow the `01-Day-Zero-Setup` guide carefully.
- **Cost**: Enabling PAYG features may incur Azure consumption costs. Monitor your usage.

---

## 🤖 AI-Assisted Content Generation

This project was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for Microsoft Purview deployment and Azure DevOps automation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Purview capabilities while maintaining technical accuracy and reflecting enterprise-grade documentation standards.*
