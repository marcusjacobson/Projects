# Lab 08: Validation & Reporting

This lab serves as the "Quality Assurance" phase. We will run a comprehensive validation suite to ensure all previous labs were deployed correctly and generate "As-Built" documentation for the simulated tenant.

## 🎯 Lab Objectives

- **Full Stack Validation**: Verify the configuration of Users, Groups, Roles, Policies, and Governance features.
- **As-Built Documentation**: Generate a detailed HTML/JSON report of the tenant's current state.
- **Zero Trust Assessment**: Score the tenant against Zero Trust best practices.

## 📚 Microsoft Learn & GUI Reference

- **Entra ID Reporting**: [What are Entra reports?](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/overview-reports)

> **💡 GUI Path**: `entra.microsoft.com` > **Monitoring & health**

## 📋 Prerequisites

- Completion of **Labs 00-07**.
- **Global Reader** role (minimum) to read all configurations.

## ⏱️ Estimated Duration

- **10 Minutes**

## 📝 Lab Steps

### Step 1: Run Full Validation

We will execute a master validation script that checks every resource created in this project.

**Context**: In Infrastructure-as-Code (IaC), validation is critical. This script acts as a "Unit Test" for your tenant. It checks if `USR-CEO` exists, if `CA001` is in Report-Only mode, if `AU-IT` has the right members, etc.

1. Open a PowerShell terminal.
2. Navigate to the `scripts` directory.
3. Run `Validate-AllLabs.ps1`.
4. Review the console output. Green means **PASS**, Red means **FAIL**.

### Step 2: Generate Configuration Report

We will export the current configuration into a readable format.

**Context**: Auditors often ask for "As-Built" documentation. Instead of taking screenshots, we generate a report that lists every policy, role assignment, and group setting. This provides a point-in-time snapshot of your security posture.

1. Run `Generate-ConfigurationReport.ps1`.
2. The script will export data to the `reports/` folder (created automatically).
3. Open the generated HTML/JSON file to view your tenant's configuration.

## ✅ Validation

- **Console Output**: Ensure `Validate-AllLabs.ps1` returns "All checks passed" (or explains what is missing).
- **Report File**: Verify a new file exists in `reports/` with today's timestamp.

## 🚧 Troubleshooting

- **"Resource not found"**: If a check fails, go back to the specific Lab (e.g., Lab 04 for PIM) and re-run the deployment script. The scripts are idempotent (safe to run multiple times).
- **"Access Denied"**: Ensure you are still connected with the correct scopes (`Connect-EntraGraph.ps1`).

## 🎓 Learning Objectives Achieved

- **Auditing**: You learned how to programmatically verify the state of a tenant.
- **Documentation**: You automated the creation of technical documentation, saving hours of manual work.

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
