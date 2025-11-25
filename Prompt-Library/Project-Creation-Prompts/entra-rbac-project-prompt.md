# New Project Creation Prompt Template

This prompt template provides a structured approach for creating new projects from scratch using GitHub Copilot or other AI assistants. It ensures compliance with repository style guides, follows best practices, and iterates on project structure before implementation.

---

## 🎯 Universal AI Project Creation Prompt

```markdown
I need your help creating a new project from scratch. Please follow this structured approach:

## PROJECT CONTEXT

**Skill Area / Domain Expertise Required:**
Microsoft Entra ID, Identity Governance, Privileged Identity Management (PIM), PowerShell Automation, RBAC Architecture, Security Operations, Log Analytics.

**Specific Targeted Content:**
Create a comprehensive, production-ready Entra RBAC and Identity Governance solution. The project must be built systematically using PowerShell automation for all resource creation.
Key modules to include:
**Specific Targeted Content:**
Create a comprehensive, production-ready Entra RBAC and Identity Governance solution. The project must be built systematically using PowerShell automation for all resource creation.
**CRITICAL: Order of Operations**
To minimize backtracking and ensure dependencies are met, the project MUST follow this strict execution order:

1.  **00-Prerequisites-and-Monitoring**:
    *   Validate Graph PowerShell SDK permissions.
    *   **Deploy Log Analytics Workspace** and configure **Entra Diagnostic Settings** immediately.
    *   **Security Configuration**: Set Log Analytics **Retention Period to 90 Days** to meet standard security baseline requirements.
    *   This ensures all subsequent resource creation activities (Users, Groups, Roles) are captured in the Audit Logs for later analysis.
2.  **01-Identity-Foundation**:
    *   **Batch creation of Users and Groups using a Standard Business Structure**. Create a realistic hierarchy (C-Suite, IT, HR, Finance, Marketing) with varying seniority levels (Director, Manager, Individual Contributor).
    *   **Enforce Strict Naming Conventions**: Mandate prefix-based naming (e.g., `USR-`, `GRP-SEC-`, `GRP-M365-`, `AU-`) for all resources to ensure manageability and filtering.
    *   **Tenant Hardening**: Configure User Settings to restrict access to the Entra Admin Center, limit external user invitation rights, and **restrict Device Join** permissions (preventing shadow IT devices).
    *   **Self-Service & Registration**: Configure **SSPR** and **Combined Security Information Registration** to ensure users can manage their own credentials securely.
    *   **Create 2x Break Glass Accounts (Emergency Access)** with permanent Global Admin assignment (excluded from CA policies).
    *   Creation of Groups: Security, M365, and Dynamic Membership Rules based on the business structure. **Ensure groups intended for PIM/Role assignment are created with `isAssignableToRole = $true`.**
    *   **Group-Based Licensing**: Configure group-based licensing for the created users (e.g., assigning Entra ID P2 via a "All Users" or Departmental group) to ensure feature availability for downstream labs.
    *   *Dependency*: Monitoring (00) captures these creation events.
3.  **02-Delegated-Administration**:
    *   Create **Administrative Units (AUs)** for departments/regions.
    *   **Implement Restricted Management Administrative Units (RMAUs)** for high-value targets (e.g., Break Glass Accounts, Security Groups) to prevent modification by standard Global Admins.
    *   Populate AUs with the Users/Groups created in Lab 01.
    *   *Dependency*: Users/Groups must exist to be added to AUs.
4.  **03-App-Integration**:
    *   **App Registration Governance**: Explicitly set "Users can register applications" to **No** to prevent shadow app creation.
    *   **Implement Application Consent Governance**: Configure Admin Consent Workflows and restrict user consent to verified publishers only to prevent illicit consent grants.
    *   **Non-Human Identity Security**: Create a **"Reporting Automation" Service Principal** secured with a **Self-Signed Certificate**.
    *   **Least Privilege Enforcement**: Assign only the specific Graph API permissions required for reporting (e.g., `AuditLog.Read.All`, `User.Read.All`) to the Service Principal, avoiding broad Directory Roles.
    *   Configure **Microsoft Teams** and **Exchange Online** specific attributes and RBAC (e.g., Team Owners, Exchange Administrators).
    *   *Dependency*: Users/Groups must exist.
5.  **04-RBAC-and-PIM**:
    *   **Custom Role Definitions**: Create a "Tier 1 Helpdesk" custom role with strict least-privilege permissions (e.g., password reset only) to demonstrate granular control.
    *   **Entra Roles**: Assign permanent roles (if any) and scoped roles to AUs (e.g., Helpdesk Admin scoped to "Marketing AU").
    *   **PIM for Roles**: Configure PIM settings for high-privilege roles (Global Admin, Privileged Role Admin). **Mandate Approval Workflows** and require **Justification** on activation for sensitive roles.
    *   **PIM for Groups**: Onboard critical groups from Lab 01 to PIM and configure activation settings.
    *   *Dependency*: AUs and Groups must exist before assigning scoped roles or onboarding to PIM.
6.  **05-Entitlement-Management**:
    *   Create **Catalogs** and **Access Packages**.
    *   **External Identity Governance**: Create a specific Access Package for **Guest/External Users** with strict expiration policies and access reviews to secure the extended enterprise.
    *   Configure policies for self-service access to the Groups/Teams created in Lab 01/03.
    *   *Dependency*: Resources (Groups/Teams) must exist to be packaged.
7.  **06-Identity-Security**:
    *   **Configure Authentication Methods Policy** to enable FIDO2/Phishing-Resistant MFA. **Note**: Use **Passkeys in Microsoft Authenticator** to simulate/test phish-resistant MFA without requiring physical hardware keys.
    *   **Operational Note**: Include a callout about the necessity of an **MFA Registration Campaign (Nudge)** in a real production environment to onboard users before enforcement.
    *   Configure **Conditional Access** policies (including "Break Glass" exclusions and requiring **Phishing-Resistant MFA** for highly privileged roles/PIM activations).
    *   **Break Glass Hardening**: Ensure Emergency Access accounts are explicitly excluded from **Identity Protection** MFA registration policies to prevent lockout loops.
    *   **Block Legacy Authentication**: Explicitly configure a CA policy to block legacy protocols (POP3/IMAP/SMTP) to prevent MFA bypass.
    *   **Break Glass Monitoring**: Configure a **Log Analytics Alert** that triggers specifically when a Break Glass account signs in.
    *   Configure **Identity Protection** (User/Sign-in Risk policies).
    *   *Dependency*: Users, Groups, and PIM roles must exist to be targeted by policies.
8.  **07-Lifecycle-Governance**:
    *   **Access Reviews**: Create recurring reviews for the PIM groups and high-risk roles.
    *   **Lifecycle Workflows**: Implement "Joiner" (onboarding), "Mover" (attribute changes), and "Leaver" (account disable/remove) workflows.
    *   **Trigger Simulation**: Include a script to simulate "HR Events" (e.g., updating a user's `department` attribute) to demonstrate the "Mover" workflow in action.
    *   *Dependency*: Requires the full identity estate to be in place to govern it.
9.  **08-Final-Validation-and-Demo**:
    *   **End-to-End Walkthrough**: A comprehensive guide to demonstrate the full solution.
    *   **Scenarios**: Execute specific scenarios (e.g., "Onboard a new user, assign PIM role, activate role, access resource, trigger alert").
    *   **Reporting**: Generate a final configuration report.
10. **09-Project-Cleanup**:
    *   **Master Teardown Script**: A unified script to remove ALL resources created during the project (Users, Groups, AUs, Policies, App Registrations).
    *   **Safety Checks**: Ensure the script validates it is running in the correct environment and does not delete pre-existing tenant resources.

**Licensing & Resource Constraints:**
- **License Efficiency & Documentation**: The solution should be designed to be efficient (targeting ~20 simulated users to fit within common trial/developer limits). However, do NOT assume a specific subscription type. The project documentation must explicitly calculate and list the total licenses required based on the generated user set.
- **Feature-Specific Requirements**: Each lab/module README must explicitly list the required licenses for that specific capability (e.g., "Requires Entra ID P2 for PIM", "Requires M365 E5 for Data Governance").
- **License Assignment**: Include specific instructions or a dedicated guide on how to assign these required licenses to users via the **Microsoft 365 Admin Center**, ensuring users can correctly configure prerequisites.
- **Trial Guidance**: Include links or instructions for obtaining trial licenses (e.g., Entra Workload Identities, Entra ID P2) for users who do not have them.
- **Workload Identities**: The project should leverage Entra Workload ID features where applicable, but treat it as an optional/advanced component with clear prerequisite callouts.

**Target File Types to Create:**
- **PowerShell Scripts (.ps1)**: PRIMARY focus. All resource creation must be script-based using the Microsoft Graph PowerShell SDK.
- **Markdown Documentation (.md)**: Detailed lab guides following the specific structure defined below.
- **Bicep/JSON**: For deploying the Log Analytics Workspace.

**Organization & Structure Requirements:**
- **Modular Design**: Use the numbered directories listed in the "Order of Operations" above.
- **Self-Contained Scripts**: Each module must have its own `scripts/` folder.
- **Documentation Standards**:
    *   **Project Root README**: Must follow the structure of `Microsoft/Purview/Purview-Data-Governance-Simulation/README.md`.
        *   Sections: `🎯 Project Overview`, `⏱️ Time & Resource Considerations`, `📚 Lab Progression`, `📊 Capability Coverage`, `🚀 Quick Start` (One-block code snippet), `📁 Project Structure`, `💼 Professional Skills You'll Gain`.
    *   **Module READMEs**: Must follow the structure of `Microsoft/Purview/Purview-Data-Governance-Simulation/01-SharePoint-Site-Creation/README.md`.
        *   Sections: `🎯 Lab Objectives`, `📚 Microsoft Learn & GUI Reference`, `📋 Prerequisites`, `⏱️ Estimated Duration`, `📝 Lab Steps`, `✅ Validation`, `🚧 Troubleshooting`, `🎓 Learning Objectives Achieved`.
        *   **Content Strategy**: While the lab steps must focus on **PowerShell automation**, the `📚 Microsoft Learn & GUI Reference` section must provide the context for the GUI equivalent.
        *   **GUI Reference Requirement**: Each lab must start with a **VALIDATED** Microsoft Learn link explaining the process in the GUI. Any GUI navigation instructions must strictly use the **Microsoft Entra Admin Center** (`entra.microsoft.com`), avoiding the Azure Portal.
        *   **Security vs. Convenience Notes**: Whenever a configuration choice involves a trade-off (e.g., strict MFA vs. user friction, PIM duration vs. operational speed), include a specific **Callout** explaining the security benefit vs. the convenience cost.
- **Testing & Validation**: Each module must include a dedicated "Validation" or "Testing" phase in its scripts and documentation to demonstrate the effects of the configuration (e.g., "Verify User Creation", "Test PIM Activation").
- **Lifecycle Management**: Every module must include a corresponding `cleanup-` or `remove-` script to safely reverse the changes made by that lab (intended for users who do not progress further). Additionally, a **Master Cleanup** module must be provided at the end of the project.
- **Best Practices**: Follow the repository's PowerShell and Markdown style guides strictly.
    *   **Idempotency**: All scripts MUST be idempotent (check if resource exists before creating/modifying) to allow safe re-runs.
    *   **Error Handling**: Implement robust error handling, specifically for **Graph API Throttling (429 errors)** with back-off logic.
    *   **Safety**: All state-changing scripts MUST support the `-WhatIf` parameter to allow admins to preview changes before execution.
    *   Use `Write-Verbose` for detailed execution logging.

**Reference Project Strategy:**
- Review the existing projects in the repository for reusable patterns, style compliance, and structure:
  - `Microsoft/Entra/` (Identity & Access Management).
  - `Microsoft/Multi-Discipline-Projects/Azure-Ai-Security-Skills-Challenge/` (AI Security & Defender for Cloud).
  - `Microsoft/Purview/Purview-Data-Governance-Simulation/` (Data Governance & Discovery).
  - `Microsoft/Purview/Purview-Skills-Ramp-OnPrem-and-Cloud/` (Hybrid Information Protection).
  - `Microsoft/Sentinel/Sentinel-as-Code/` (SIEM/SOAR Automation).
- Leverage and adapt relevant instructions, scripts, and patterns from these projects.
- **CRITICAL**: Duplicate and customize content rather than linking to it - this project must be fully self-contained.
- Extract applicable PowerShell script patterns, documentation structures, and step-by-step procedures.
- Do NOT assume any work from reference projects has been completed.
- Do NOT create references or links to other projects - embed all necessary content directly.

**Additional Context:**
This is a "from scratch" setup - do not assume any prior configuration or completed work. All prerequisites, environment setup, and foundational steps must be included. The project should be suitable for learning from the ground up while following enterprise-grade practices for production readiness.

## COMPLIANCE REQUIREMENTS

Before creating any content, you MUST:

1. **Review Repository Style-Guides:**
   - Read and understand the Markdown Style Guide (`Repository-Management/Style-Guides/markdown-style-guide.md`)
   - Read and understand the PowerShell Style Guide (`Repository-Management/Style-Guides/powershell-style-guide.md`) if applicable
   - Read and understand the Parameters File Style Guide (`Repository-Management/Style-Guides/parameters-file-style-guide.md`) if applicable
   - Follow any other relevant style guides in the repository

2. **Review Existing Reference Projects:**
   - Use `semantic_search` or `read_file` to extract relevant patterns, scripts, and documentation structures from the projects listed above.
   - Identify reusable PowerShell modules, error handling patterns, and documentation templates.

3. **Follow Copilot Instructions:**
   - Adhere to all standards defined in `.github/copilot-instructions.md`.
   - Apply appropriate style guide compliance for each file type.
   - Use proper formatting, headers, punctuation, and structure.
   - Include AI-assisted content generation acknowledgments where required.

4. **Apply Best Practices:**
   - Use proper naming conventions for files and resources.
   - Implement consistent formatting and organization.
   - Include comprehensive documentation and comments.
   - Follow industry standards for the specified technology stack.

5. **Research and Validate Before Creating:**
   - **NEVER rely on training data** for step-by-step instructions, code examples, or technical procedures.
   - **USE DEEP REASONING AGENTS**: Always use deep reasoning models (e.g., Claude with extended thinking, GPT-o1, Gemini Deep Research) when performing research, analysis, or architectural decisions.
   - **PRIMARY SOURCE**: Always use Microsoft Learn (`learn.microsoft.com`) as the primary validation source for Microsoft technologies.
   - **SECONDARY SOURCES**: Validate against official documentation (`docs.microsoft.com`, `github.com/Microsoft`, official vendor docs).
   - **Code Validation**: Research current API versions, cmdlet syntax, SDK methods, and library versions before suggesting code.
   - **UI/Portal Instructions**: Use `fetch_webpage` or documentation search to verify current portal navigation, menu locations, and button names.
   - **Version Checking**: Confirm current versions, features, and deprecated methods before providing examples.

## REQUIRED ITERATIVE APPROVAL PROCESS

### Phase 1: Project Structure Proposal

Before creating ANY files or content:

1. **Engage deep reasoning** for architectural analysis and technology selection.
2. **Review existing reference projects** to identify reusable patterns and content.
3. **Suggest a descriptive project name** that follows repository naming conventions.
4. **Propose a complete directory structure** showing all folders and key files.
5. **Explain the purpose** of each major directory and file type.
6. **Describe the organization rationale** and how it meets the requirements.
7. **Define the Skills Coverage Matrix** showing which specific skills/technologies are covered in each lab/section.
8. **Identify content to duplicate** from reference projects and how it will be adapted.
9. **Wait for my approval or feedback** before proceeding.

### Phase 2: Iterative Refinement

If I request changes:

1. **Revise the proposed structure** based on my feedback.
2. **Explain the changes made** and why they address my concerns.
3. **Present the updated proposal** for review.
4. **Repeat this process** until I explicitly approve the structure.

### Phase 3: Implementation

Only after I provide explicit approval:

1. **Create the directory structure** as approved.
2. **Generate all files** following the repository style guides.
3. **Ensure compliance** with all formatting and documentation standards.
4. **Provide a summary** of what was created and next steps.

## OUTPUT FORMAT REQUIREMENTS

### For Project Structure Proposal:

```text

## Proposed Project Structure

**Project Name:** [descriptive-project-name]

**Directory Tree:**

```text
project-root/
├── README.md
├── directory1/
│   ├── subdirectory/
│   │   ├── file1.ext
│   │   └── file2.ext
│   └── file3.ext
├── directory2/
│   ├── file4.ext
│   └── file5.ext
└── directory3/
    └── file6.ext
```

**Directory Purpose Explanations:**

- **[Directory Name]**: [Explanation of purpose and contents]
- **[Directory Name]**: [Explanation of purpose and contents]
...

**Skills Coverage Matrix:**

| Skill / Technology | Lab / Section | Depth (Basic/Intermediate/Advanced) |
|-------------------|---------------|-------------------------------------|
| [Skill 1]         | [Lab 01]      | [Depth]                             |
| [Skill 2]         | [Lab 02]      | [Depth]                             |
...

**Organization Rationale:**
[Explain why this structure was chosen and how it supports the learning objectives.]

**Key File Types to be Created:**

- [File Type]: [Count] - [Description]
...

**Compliance Considerations:**

- [List specific style guides and standards to be followed]

**Research Validation Plan:**

- [List specific documentation sources and APIs to be researched]

**Content Reuse from Reference Projects:**

- [List specific patterns or content to be adapted from existing repo projects]

**Awaiting Approval:** Please review this structure and provide feedback or approval to proceed.

```

### For Iterative Refinement:

```text

## Revised Project Structure (Version [N])

**Changes Made Based on Feedback:**

1. [Change 1]
2. [Change 2]
...

**Updated Directory Tree:**
...

**Updated Rationale:**
...

**Awaiting Approval:** Please review these revisions and provide feedback or approval to proceed.
```

## RESEARCH AND VALIDATION REQUIREMENTS

Before suggesting any code, step-by-step instructions, or technical procedures, you MUST validate against official sources:

### Primary Research Sources (in order of priority)

1. **Microsoft Learn** (learn.microsoft.com) - Primary source for all Microsoft technologies
2. **Official Microsoft Documentation** (docs.microsoft.com, github.com/Microsoft)
3. **Cloud Provider Official Docs** (Azure, AWS, GCP official documentation)
4. **Official Product Documentation** (Vendor-specific docs for third-party tools)
5. **Reputable Technical Resources** (Only after validating with official sources)

### What Requires Research Validation

**ALWAYS research before providing:**

- **Step-by-step instructions** for portal navigation, admin centers, or product UIs
- **Code examples** including API calls, cmdlet syntax, SDK methods
- **Configuration procedures** for Entra/Azure resources, services, or integrations
- **Installation workflows** and setup procedures
- **API endpoints** and authentication requirements
- **Resource properties** and configuration options
- **Current versions** of software, APIs, or services
- **Deprecated features** or replaced functionality

**Research Process:**

1.  **Engage deep reasoning** for complex analysis, architectural decisions, or multi-faceted research
2.  **Identify what needs validation** (UI paths, code syntax, API versions, etc.)
3.  **Use appropriate research tools** (fetch_webpage for documentation, semantic search for internal patterns)
4.  **Verify current state** (check dates, versions, and "as of" indicators)
5.  **Cross-reference when uncertain** (use multiple official sources)
6.  **Document research** (note version numbers, dates, and source URLs in comments)
7.  **Modern Terminology Check**: Ensure all terms are current (e.g., "Entra ID" instead of "Azure AD", "Microsoft Purview" instead of "Azure Purview"). Validate all names, steps, and licenses against the latest Microsoft Learn documentation.
8.  **Portal URL Check**: Ensure all GUI references point to `entra.microsoft.com` (Microsoft Entra Admin Center) and NOT `portal.azure.com`.

## CRITICAL RULES

1. **Never skip the approval phase** - Always wait for explicit approval before creating files.
2. **Never assume project structure** - Always propose and iterate based on feedback.
3. **Always read style guides first** - Ensure compliance from the start, not as an afterthought.
4. **Always review reference projects** - Use semantic_search and read_file to extract reusable patterns.
5. **Always duplicate, never link** - Extract and embed content directly; never create references or links to other projects.
6. **Always validate against official documentation** - Never rely on training data for technical instructions, code examples, or current procedures.
7. **Always use deep reasoning agents** - Engage extended thinking/deep reasoning models for research, analysis, architectural decisions, and technology validation.
8. **Always research before suggesting** - Use Microsoft Learn for Microsoft technologies, official vendor docs for other technologies.
9. **Always provide detailed explanations** - Help me understand your design decisions.
10. **Always be ready to iterate** - Expect multiple rounds of refinement.
11. **Never create partial implementations** - Wait for full approval of the complete structure.

## STYLE GUIDE COMPLIANCE CHECKLIST

Before implementing, verify:

- [ ] Reviewed applicable style guides from `Repository-Management/Style-Guides/` directory.
- [ ] Reviewed existing reference projects for reusable patterns.
- [ ] Identified PowerShell scripts, documentation templates, and configuration files to duplicate.
- [ ] Planned content extraction strategy - no links or references, only embedded duplicated content.
- [ ] Understood repository `.github/copilot-instructions.md` requirements.
- [ ] Confirmed file naming conventions for target technology.
- [ ] Identified required documentation standards.
- [ ] Planned for AI-assisted content generation acknowledgments.
- [ ] Understood header, formatting, and punctuation requirements.
- [ ] Identified any technology-specific patterns to follow.
- [ ] **Researched current documentation** from Microsoft Learn or official sources for all technical content.
- [ ] **Validated API versions, cmdlet syntax, and library versions** against current official documentation.
- [ ] **Verified UI navigation paths and portal instructions** using current official resources (not training data).
- [ ] **Engaged deep reasoning agents** for architectural decisions, technology selection, and complex analysis.

```

---

## 🤖 AI-Assisted Content Generation

This project creation prompt template was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for AI prompting, multi-model compatibility, and repository-specific compliance requirements.

*AI tools were used to enhance productivity and ensure comprehensive coverage of project creation workflows while maintaining technical accuracy and reflecting established repository standards for content creation and style guide adherence.*
