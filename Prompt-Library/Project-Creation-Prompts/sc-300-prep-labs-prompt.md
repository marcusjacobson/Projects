# SC-300 Identity & Access Administrator Lab Project Prompt

This prompt is designed to generate a comprehensive lab project for SC-300 certification preparation.

---

## 🎯 SC-300 Project Creation Prompt

```markdown
I need your help creating a new project from scratch. Please follow this structured approach:

## PROJECT CONTEXT

**Skill Area / Domain Expertise Required:**
Microsoft Entra ID, Identity & Access Management (IAM), SC-300 Certification Skills (Identity & Access Administrator Associate).

**Specific Targeted Content:**
Create a "Greenfield to Governance" simulation project designed to prepare users for the SC-300 exam. The project must demonstrate practical experience for all domains covered in the [SC-300 Study Guide](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/sc-300).

**Critical Design Requirements:**
1.  **Logical Progression**: The order of operations must build logically upon each other (Greenfield -> Governance) rather than strictly following the exam domain order.
    *   *Phase 1: Identity Foundation & Hybrid Simulation* (Tenant config, Users/Groups, AUs, Hybrid)
    *   *Phase 2: Secure Authentication & Access Control* (Auth methods, Conditional Access, ID Protection, External Identities)
    *   *Phase 3: Workload Identities & Application Modernization* (App Reg, Enterprise Apps, Managed Identities)
    *   *Phase 4: Identity Governance & Zero Trust* (PIM, Entitlement Management, Access Reviews)
    *   *Phase 5: Monitoring & Reporting* (Logs, KQL, Workbooks)
2.  **Study Material Alignment**: Replicate the steps and flows found in the official [SC-300 Prepare for the Exam modules](https://learn.microsoft.com/en-us/credentials/certifications/identity-and-access-administrator/?practice-assessment-type=certification#certification-prepare-for-the-exam) as closely as possible.
3.  **Exam "Soft Skills" Integration (CRITICAL)**:
    *   **Licensing Callouts**: Every lab MUST explicitly state the required license (Free, P1, P2, Governance) for the feature being configured. This is a frequent exam topic.
    *   **Least Privilege**: Do not just assume Global Admin. Each lab must identify the *minimum* Entra ID role required to perform the configuration (e.g., "Privileged Role Administrator" for PIM).
    *   **"Exam Tips" & Constraints**: Include callouts for common exam "gotchas" or constraints (e.g., "Dynamic groups cannot be manually modified", "MFA registration policy vs. Conditional Access").
    *   **Scenario Wrappers**: Frame each phase with a brief "Case Study" narrative (e.g., "Contoso needs to secure external access...") to mimic the exam's case study format.
4.  **Troubleshooting & "Break-Fix" Integration**:
    *   **Diagnostic Scenarios**: Exams often ask *why* access failed. Include specific "Troubleshooting" sections in labs (e.g., "User cannot access app - check Sign-in Logs," "Conditional Access 'What If' tool usage").
    *   **"Break-Fix" Challenges**: Where possible, include optional "Challenge" steps where the user must fix a misconfiguration (e.g., "A policy is blocking the CEO, find and fix it").
5.  **Portal vs. IaC Balance**:
    *   **Primary Focus**: The project should be **mostly portal-focused** (GUI step-by-step instructions) to match the exam's emphasis on the Microsoft Entra admin center.
    *   **Secondary Focus**: Leverage **PowerShell and Azure CLI** only where the study materials specifically call for it (e.g., bulk user creation, complex app registrations, or specific automation tasks mentioned in the exam skills).
6.  **Skill Tagging**: Every module, lab, and script must be explicitly tagged with the specific **SC-300 Skill/Domain** it addresses (e.g., "Skill: Implement and manage user identities").

**Target File Types to Create:**
*   **Markdown Guides (.md)**: Detailed, step-by-step lab guides for portal-based configurations. MUST include:
    *   **Estimated Time**: Clear duration for each lab (e.g., "Time: 45 Minutes").
    *   **Licensing/RBAC Headers**: Required licenses and roles.
    *   **"Exam Tip" Callouts**: Specific gotchas.
*   **PowerShell Scripts (.ps1)**: For automation tasks specifically required by the exam (e.g., bulk operations) and for **Environment Cleanup**.
*   **JSON/Bicep**: Only if strictly necessary for environment setup (e.g., Log Analytics Workspace).

**Organization & Structure Requirements:**
*   **Root Directory**: `Microsoft/Entra/SC-300-Identity-Access-Admin-Labs/`
*   **Phase Directories**: Numbered folders (e.g., `01-Identity-Foundation`, `02-Secure-Auth`) corresponding to the logical progression.
*   **Special Directories**:
    *   `00-Prerequisites`: Guide for setting up a Developer Tenant and activating P2 trials.
    *   `09-Cleanup`: Scripts/Guides to remove all created resources to prevent costs.
*   **Lab Structure**: Each phase should contain individual markdown files for specific labs (e.g., `Lab-01-Tenant-Config.md`).
*   **Scripts Folder**: A central `scripts/` folder for any PowerShell/CLI tools.
*   **Documentation**: A comprehensive root `README.md` mapping the labs to the SC-300 skills.
    *   **CRITICAL**: The README MUST include a "Covered Capabilities by Category" section, following the exact format of `Microsoft/Entra/Entra-Zero-Trust-RBAC-Simulation/README.md`.
    *   **Structure**: Use tables to list capabilities (e.g., "Identity Governance", "Zero Trust Security") with columns for "Capability", "Coverage Level" (e.g., ✅ COMPREHENSIVE), and "Project Section(s)".
    *   **Exclusions**: Also include a "What This Project Does NOT Cover" section for topics like Hybrid Sync (if not simulated) or specialized hardware features.

**Reference Project Strategy:**
- Review and adapt content from these existing projects to ensure high quality and consistency:
  - `Microsoft/Entra/Entra-Zero-Trust-RBAC-Simulation/` (Reuse logic for user creation and governance).
  - `Microsoft/Entra/Entra-Deployment-Pipelines/` (Reuse patterns for CA and Auth methods).
- **CRITICAL**: Duplicate and customize content. Do not link to other projects. The labs must be self-contained.
- **Adaptation**: Convert IaC-heavy patterns from reference projects into Portal-focused instructions where appropriate for SC-300.

**Additional Context:**
This project is a study aid. It should feel like a cohesive workshop. Assume the user starts with a fresh Developer Tenant.

## COMPLIANCE REQUIREMENTS

Before creating any content, you MUST:

1. **Review Repository Style-Guides:**
   - Read and understand the Markdown Style Guide (`Repository-Management/Style-Guides/markdown-style-guide.md`)
   - Read and understand the PowerShell Style Guide (`Repository-Management/Style-Guides/powershell-style-guide.md`)
   - Read and understand the Parameters File Style Guide (`Repository-Management/Style-Guides/parameters-file-style-guide.md`)

2. **Review Existing Reference Projects:**
   - Use `semantic_search` or `read_file` to extract relevant patterns from `Microsoft/Entra/`.
   - Identify reusable PowerShell logic for bulk operations.

3. **Follow Copilot Instructions:**
   - Adhere to standards in `.github/copilot-instructions.md`.
   - Use proper formatting, headers, and punctuation.
   - **Research First**: Use `fetch_webpage` to verify current Portal UI steps (button names, menu paths) from Microsoft Learn. Do NOT rely on training data for UI navigation.

## REQUIRED ITERATIVE APPROVAL PROCESS

### Phase 1: Project Structure Proposal

Before creating ANY files or content:

1. **Engage deep reasoning** to map the SC-300 skills to the logical project phases.
2. **Review reference projects** to identify what can be adapted vs. what needs to be written from scratch (Portal steps).
3. **Propose a complete directory structure** showing phases and specific labs.
4. **Define the Skills Coverage Matrix**: Map each proposed lab to specific SC-300 exam domains.
5. **Explain the Portal vs. IaC decision** for each lab (why is this one Portal? why is this one PowerShell?).
6. **Wait for my approval** before proceeding.

### Phase 2: Iterative Refinement

If I request changes:
1. **Revise the structure** based on feedback.
2. **Explain changes**.
3. **Present updated proposal**.

### Phase 3: Implementation

Only after approval:
1. **Create the directory structure**.
2. **Generate all files** following style guides.
3. **Ensure every lab has a "Skill Tag"**.
4. **Provide a summary**.

## OUTPUT FORMAT REQUIREMENTS

### For Project Structure Proposal:

```text
## Proposed Project Structure: SC-300 Identity & Access Administrator Labs

**Project Name:** SC-300-Identity-Access-Masterclass

**Directory Tree:**
...

**Skills Coverage Matrix:**
| SC-300 Domain | Lab / Module | Delivery Method (Portal/PowerShell) |
|---------------|--------------|-------------------------------------|
| Implement user identities | Lab 01 - User Creation | PowerShell (Bulk) |
| Implement Conditional Access | Lab 05 - CA Policies | Portal |
...

**Rationale:**
[Explain the logical flow and how it covers the exam objectives.]

**Awaiting Approval:** Please review this structure.
```

## RESEARCH AND VALIDATION REQUIREMENTS

**MANDATORY VALIDATION STEP:**

Before generating ANY step-by-step instructions (GUI) or code (PowerShell, ARM, Bicep), you MUST validate the approach against official Microsoft Learn documentation.

**Validation Checklist:**

- **Modernity Check**: Ensure the method is the current recommended practice (e.g., using Microsoft Graph PowerShell instead of AzureAD module, using Entra Admin Center instead of Azure Portal for Identity).
- **Portal Navigation**: Use `fetch_webpage` or MCP tools to verify exact menu paths, button names, and wizard steps. Do NOT rely on training data.
- **Code Syntax**: Verify all PowerShell cmdlets, ARM templates, and Bicep files against the latest API versions and syntax references on Microsoft Learn.
- **Exam Alignment**: Ensure the content aligns with the *current* SC-300 exam guide.

## CRITICAL RULES

1. **Portal First**: Default to GUI instructions unless the exam explicitly tests automation skills for that topic.
2. **Validate Everything**: All GUI paths and code (PowerShell/Bicep) MUST be validated against Microsoft Learn for accuracy and modernity.
3. **Tag Skills**: Every lab MUST state which exam skill it covers at the top.
4. **Self-Contained**: No external dependencies or links to other repo projects.
5. **Research UI**: Do not guess menu paths. Verify them.

```markdown
```

---

## 🤖 AI-Assisted Content Generation

This project creation prompt was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating SC-300 exam requirements and repository-specific compliance standards.

*AI tools were used to enhance productivity and ensure comprehensive coverage of certification objectives while maintaining technical accuracy and reflecting established repository standards.*
