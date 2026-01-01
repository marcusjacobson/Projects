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
| `03-Classification-UI` | **UI Lab**: Create Custom SITs and EDM classifiers in the Purview portal. |
| `04-Information-Protection-UI` | **UI Lab**: Configure sensitivity labels, visual markings, and auto-labeling policies. |
| `05-Data-Loss-Prevention-UI` | **UI Lab**: Build DLP policies for PCI-DSS and PII protection with user notifications. |
| `06-Exfiltration-Simulation` | Test your governance framework by simulating data exfiltration scenarios (Email, Teams, Sharing). |
| `07-Audit-and-Validation` | Review Activity Explorer and Content Explorer to validate compliance and tune policies. |
| `08-Cleanup` | Scripts to remove all resources created during the labs. |
| `IaC-Automation` | **Supplemental**: PowerShell scripts and Azure DevOps pipelines for automated deployment (mirrors UI labs). |

## 🧠 Skills Coverage Matrix

| Skill / Technology | Lab / Section | Depth |
|-------------------|---------------|-------|
| **Purview Information Protection** | 04-Information-Protection-UI / IaC-Automation | Advanced (Auto-labeling, Visual Markings, Scoped Labels) |
| **Data Classification** | 03-Classification-UI / IaC-Automation | Advanced (EDM, Custom SITs, Regex Patterns) |
| **Data Loss Prevention (DLP)** | 05-Data-Loss-Prevention-UI / IaC-Automation | Advanced (Multi-workload, User Notifications, Overrides) |
| **PowerShell Automation** | 02-Data-Foundation / IaC-Automation | Intermediate (Graph SDK, Data Generation, COM Objects) |
| **Azure DevOps Pipelines** | IaC-Automation | Intermediate (YAML Pipelines, Service Connections) |
| **Microsoft Graph API** | 00-Prerequisites / IaC-Automation | Intermediate (App-only Auth, Permissions) |
| **Data Governance Strategy** | All UI Labs (03, 04, 05) | Advanced (Taxonomy Design, Regulatory Mapping, Testing) |

## 🚀 Getting Started

### Learning Path Overview

This project follows a structured progression from manual UI configuration to enterprise-grade automation:

**Phase 1: Foundation Setup (Day 0-1)**
1. **00-Prerequisites**: Set up authentication and Azure resources
2. **01-Day-Zero-Setup**: Initiate long-running backend processes (EDM indexing)
3. **02-Data-Foundation**: Generate and upload realistic test data

**Phase 2: UI Configuration Labs (Day 2-7)**
4. **03-Classification-UI**: Create custom SITs and EDM classifiers
5. **04-Information-Protection-UI**: Build sensitivity label taxonomy
6. **05-Data-Loss-Prevention-UI**: Configure DLP policies and enforcement

**Phase 3: Testing & Validation (Week 2)**
7. **06-Exfiltration-Simulation**: Test policies with real-world scenarios
8. **07-Audit-and-Validation**: Review results and tune detection

**Phase 4: Automation (Optional)**
9. **IaC-Automation**: Deploy the same configuration using PowerShell and Azure DevOps

### Quick Start (Recommended Path)

1. **Review Prerequisites**: Start with the `00-Prerequisites` folder to set up your environment and authentication.
2. **Execute Day Zero Setup**: Immediately proceed to `01-Day-Zero-Setup` to initiate long-running backend processes (EDM schema upload).
3. **Generate Data**: Use `02-Data-Foundation` to populate your tenant with realistic test data (13 files with Luhn-valid credit cards).
4. **Configure via UI**: Work through `03-Classification-UI`, `04-Information-Protection-UI`, and `05-Data-Loss-Prevention-UI` sequentially.
5. **Test**: Run the simulations in `06-Exfiltration-Simulation` to validate your defenses.
6. **Analyze**: Use `07-Audit-and-Validation` to review detection accuracy and compliance.
7. **Automate** (Optional): Explore `IaC-Automation` to implement the same policies using code.

## ⚠️ Important Notes

- **Licensing**: This project requires **Microsoft 365 E5** (or E5 Compliance) and a **Purview Pay-As-You-Go (PAYG)** resource for full functionality.
- **Timing**: Some Purview features (EDM, Auto-labeling) have significant backend processing times (12-48 hours). Follow the `01-Day-Zero-Setup` guide carefully.
- **Cost**: Enabling PAYG features may incur Azure consumption costs. Monitor your usage in the Azure portal.
- **Lab Sequence**: The UI labs (03, 04, 05) must be completed in order, as each builds on the previous configuration.
- **Test Data**: Always use the synthetic data from `02-Data-Foundation` - never use real customer data in a test environment.

## 🎓 Learning Approach

### UI Labs First (Recommended for Beginners)
Complete labs 03, 04, and 05 to understand Purview concepts through hands-on portal configuration. This builds foundational knowledge before attempting automation.

### IaC Only (For Experienced Users)
If you're already familiar with Purview, skip the UI labs and go straight to `IaC-Automation` to deploy everything via PowerShell and Azure DevOps pipelines.

### Hybrid Approach (Best for Teams)
Have junior team members work through UI labs while senior engineers build the IaC automation in parallel. Then compare results for quality validation.

---

## 🤖 AI-Assisted Content Generation

This project was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for Microsoft Purview deployment and Azure DevOps automation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Purview capabilities while maintaining technical accuracy and reflecting enterprise-grade documentation standards.*
