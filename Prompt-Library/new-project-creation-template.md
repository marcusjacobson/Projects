# New Project Creation Prompt Template

This prompt template provides a structured approach for creating new projects from scratch using GitHub Copilot or other AI assistants. It ensures compliance with repository style guides, follows best practices, and iterates on project structure before implementation.

---

## 🎯 Universal AI Project Creation Prompt

```markdown
I need your help creating a new project from scratch. Please follow this structured approach:

## PROJECT CONTEXT

**Skill Area / Domain Expertise Required:**
[INSERT SKILL AREA / DOMAIN EXPERTISE HERE]
(e.g., Microsoft Purview, Azure OpenAI, Microsoft Sentinel, Entra ID, DevSecOps, etc.)

**Specific Targeted Content:**
[INSERT SPECIFIC TARGETED CONTENT HERE]
(Describe the project goals, specific labs, features, or workflows to be created. Be detailed about what the user should learn or achieve.)

**Target File Types to Create:**
[INSERT TARGET FILE TYPES HERE]
(e.g., PowerShell scripts (.ps1), Bicep templates (.bicep), Markdown docs (.md), JSON configs (.json), YAML pipelines (.yml))

**Organization & Structure Requirements:**
[INSERT ORGANIZATION REQUIREMENTS HERE]
(e.g., Numbered lab directories, infra/ folder, scripts/ folder, comprehensive README, self-contained labs)

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
- **Configuration procedures** for Azure resources, services, or integrations
- **Installation workflows** and setup procedures
- **API endpoints** and authentication requirements
- **Resource properties** and configuration options
- **Current versions** of software, APIs, or services
- **Deprecated features** or replaced functionality

**Research Process:**

1. **Engage deep reasoning** for complex analysis, architectural decisions, or multi-faceted research
2. **Identify what needs validation** (UI paths, code syntax, API versions, etc.)
3. **Use appropriate research tools** (fetch_webpage for documentation, semantic search for internal patterns)
4. **Verify current state** (check dates, versions, and "as of" indicators)
5. **Cross-reference when uncertain** (use multiple official sources)
6. **Document research** (note version numbers, dates, and source URLs in comments)

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
