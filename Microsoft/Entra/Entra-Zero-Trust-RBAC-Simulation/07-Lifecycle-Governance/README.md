# Lab 07: Lifecycle Governance

This lab automates the "Joiner, Mover, Leaver" (JML) process and ensures access rights are recertified regularly. We will use Access Reviews to prevent "privilege creep" and Lifecycle Workflows to handle employee offboarding securely.

## 🎯 Lab Objectives

- **Access Reviews**: Automate the recertification of Guest users and High-Privilege roles.
- **Lifecycle Workflows**: Create a "Leaver" workflow to automatically disable accounts and remove licenses when an employee leaves.
- **Governance**: Ensure that access is not permanent and is reviewed by the right people.

## 📚 Microsoft Learn & GUI Reference

- **Access Reviews**: [What are access reviews?](https://learn.microsoft.com/en-us/entra/id-governance/access-reviews-overview)
- **Lifecycle Workflows**: [What are lifecycle workflows?](https://learn.microsoft.com/en-us/entra/id-governance/what-are-lifecycle-workflows)

> **💡 GUI Path**: `entra.microsoft.com` > **Identity Governance** > **Access Reviews** | **Lifecycle Workflows**

## 📋 Prerequisites

- Completion of **Lab 01**.
- **Entra ID P2 License** (Required for Governance features).

## ⏱️ Estimated Duration

- **15 Minutes**

## 📝 Lab Steps

### Step 1: Deploy Access Reviews

We will create two critical reviews: one for external guests and one for Global Administrators.

**Context**:

- **Guest Review**: Guests often finish their project but keep their account. This review asks them (or their sponsor) "Do you still need this?" every 90 days.
- **Admin Review**: "Privilege Creep" happens when admins accumulate rights they no longer need. This review forces a quarterly justification for holding the "Global Admin" role.

1. Open a PowerShell terminal.
2. Navigate to the `scripts` directory.
3. Run `Deploy-AccessReviews.ps1`.
4. Creates:
    - `REV-Guest-Access`: Quarterly review of all guests.
    - `REV-Global-Admins`: Quarterly review of the Global Admin role.

### Step 2: Configure Lifecycle Workflows

We will automate the "Leaver" process to ensure immediate security upon termination.

**Context**: Manual offboarding is slow and risky. If HR terminates an employee on Friday, but IT doesn't disable the account until Monday, that's a 3-day window for data theft. Lifecycle Workflows listen to the "EmployeeLeaveDateTime" attribute and execute actions automatically.

1. Run `Configure-LifecycleWorkflows.ps1`.
2. Creates a workflow `LCW-RealTime-Leaver` that triggers when a user's `employeeLeaveDateTime` is reached.
3. **Actions**:
    - Disable User Account.
    - Remove from all Groups.
    - Remove all Licenses.
    - (Optional) Delete user after X days.

## ✅ Validation

- **Access Reviews**: Go to **Identity Governance** > **Access Reviews** and verify the two reviews are "Active" or "Scheduled".
- **Lifecycle Workflows**: Go to **Identity Governance** > **Lifecycle Workflows** > **Workflows** and verify the Leaver workflow exists.

## 🚧 Troubleshooting

- **"Workflow creation failed"**: Ensure you have the `LifecycleWorkflows.ReadWrite.All` permission.
- **"Attribute not found"**: The `employeeLeaveDateTime` attribute must be populated for the workflow to trigger (we simulate this in the script).

## 🎓 Learning Objectives Achieved

- **Automated Hygiene**: You replaced manual "cleanup scripts" with native, audit-ready governance tools.
- **Risk Reduction**: You ensured that high-risk access (Admins, Guests) is temporary and monitored.

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
