# New Project Creation Prompt Template

This prompt template provides a structured approach for creating new projects from scratch using GitHub Copilot or other AI assistants. It ensures compliance with repository style guides, follows best practices, and iterates on project structure before implementation.

---

## 🎯 Universal AI Project Creation Prompt

```markdown
I need your help creating a new project from scratch. Please follow this structured approach:

## PROJECT CONTEXT

**Skill Area / Domain Expertise Required:**
Microsoft Purview Information Protection, Data Lifecycle Management, and PowerShell automation for enterprise data governance

**Specific Targeted Content:**
Create a comprehensive "from scratch" lab environment demonstrating Microsoft Purview's data classification, protection, and lifecycle management capabilities. The project should include:

1. **On-Demand Classification for SharePoint & OneDrive:**
   - Lab demonstrating manual re-indexing of existing content using Purview's On-Demand Classification
   - Steps to create new Sensitive Information Types (SITs)
   - Running On-Demand Classification on SharePoint sites
   - Validation of results in Content Explorer

2. **Custom Sensitive Information Types (SITs):**
   - Labs for creating and tuning custom SITs using regex patterns, keyword dictionaries, and confidence levels
   - Exact Data Match (EDM) configuration examples
   - Trainable Classifiers for unstructured data analysis

3. **Retention Labels & Data Lifecycle Management (DLM):**
   - Configuration of retention labels and auto-apply policies
   - Retention based on SIT detection and file age
   - Deletion workflows using retention policies
   - Tiered retention strategies and policy ceilings

4. **Automation & Scaling with PowerShell:**
   - Scripts using Compliance PowerShell for content searches
   - Automated bulk deletion and labeling actions
   - Monitoring classification and policy adoption across multiple sites
   - Error handling, logging, and modular design patterns

5. **Runbook Documentation:**
   - End-to-end Purview deployment procedures
   - Classification, labeling, retention, and automation workflows
   - Operational handoff guidance for enterprise teams

**Target File Types to Create:**
PowerShell scripts (.ps1), JSON configuration files (.json), Markdown documentation (.md), CSV data files for EDM examples (.csv), Bicep/ARM templates for infrastructure (.bicep), YAML workflow files if applicable (.yml)

**Organization & Structure Requirements:**
Follow Infrastructure-as-Code patterns with:
- Separate numbered lab directories (01-OnDemandClassification/, 02-CustomSITs/, 03-RetentionLabels/, etc.)
- scripts/ directory for PowerShell automation with proper preambles and error handling
- docs/ or individual lab README files with step-by-step instructions
- data/ or samples/ directory for example files and test data
- infra/ directory if Azure resources are needed
- Comprehensive root-level README with project overview, prerequisites, and lab progression
- Each lab should be self-contained but build on previous concepts
- Include validation steps and expected outcomes for each lab

**Content Reuse Strategy:**
- Review the existing Purview-Skills-Ramp-OnPrem-and-Cloud project in Microsoft/Purview/ directory
- Leverage and adapt relevant instructions, scripts, and patterns from that project
- **CRITICAL**: Duplicate and customize content rather than linking to it - this project must be fully self-contained
- Extract applicable PowerShell script patterns, documentation structures, and step-by-step procedures
- Adapt existing content to fit the new lab structure (On-Demand Classification, Custom SITs, Retention Labels, etc.)
- Do NOT assume any work from the reference project has been completed
- Do NOT create references or links to the other project - embed all necessary content directly
- Treat this as a "from scratch" implementation that reuses proven patterns but stands alone completely

**Additional Context:**
This is a "from scratch" setup - do not assume any prior Purview configuration or completed work. All prerequisites, environment setup, and foundational steps must be included. The project should be suitable for learning Purview from the ground up while following enterprise-grade practices for production readiness. While leveraging existing patterns from the Purview-Skills-Ramp project, all content must be duplicated and embedded directly into this project to ensure it can be used independently without external dependencies.

## COMPLIANCE REQUIREMENTS

Before creating any content, you MUST:

1. **Review Repository Style Guides:**
   - Read and understand the Markdown Style Guide (Style Guides/markdown-style-guide.md)
   - Read and understand the PowerShell Style Guide (Style Guides/powershell-style-guide.md) if applicable
   - Read and understand the Parameters File Style Guide (Style Guides/parameters-file-style-guide.md) if applicable
   - Follow any other relevant style guides in the repository

2. **Review Existing Reference Projects:**
   - Examine the Purview-Skills-Ramp-OnPrem-and-Cloud project in Microsoft/Purview/ directory
   - Use semantic_search or read_file to extract relevant patterns, scripts, and documentation structures
   - Identify reusable PowerShell modules, error handling patterns, and documentation templates
   - **CRITICAL**: Duplicate and adapt content - do not link to or reference the other project by name
   - Extract raw instructions and embed them directly into the new project structure

3. **Follow Copilot Instructions:**
   - Adhere to all standards defined in .github/copilot-instructions.md
   - Apply appropriate style guide compliance for each file type
   - Use proper formatting, headers, punctuation, and structure
   - Include AI-assisted content generation acknowledgments where required

4. **Apply Best Practices:**
   - Use proper naming conventions for files and resources
   - Implement consistent formatting and organization
   - Include comprehensive documentation and comments
   - Follow industry standards for the specified technology stack

5. **Research and Validate Before Creating:**
   - **NEVER rely on training data** for step-by-step instructions, code examples, or technical procedures
   - **USE DEEP REASONING AGENTS**: Always use deep reasoning models (e.g., Claude with extended thinking, GPT-o1, Gemini Deep Research) when performing research, analysis, or architectural decisions for project creation
   - **PRIMARY SOURCE**: Always use Microsoft Learn (learn.microsoft.com) as the primary validation source for Microsoft technologies
   - **SECONDARY SOURCES**: Validate against official documentation (docs.microsoft.com, github.com/Microsoft, official vendor docs)
   - **Code Validation**: Research current API versions, cmdlet syntax, SDK methods, and library versions before suggesting code
   - **UI/Portal Instructions**: Use fetch_webpage or documentation search to verify current portal navigation, menu locations, and button names
   - **Version Checking**: Confirm current versions, features, and deprecated methods before providing examples
   - **Multi-Source Verification**: Cross-reference multiple reputable sources when primary documentation is unclear

## REQUIRED ITERATIVE APPROVAL PROCESS

**Phase 1: Project Structure Proposal**

Before creating ANY files or content:

1. **Engage deep reasoning** for architectural analysis and technology selection
2. **Review existing reference project** (Purview-Skills-Ramp-OnPrem-and-Cloud) to identify reusable patterns and content
3. **Suggest a descriptive project name** that follows repository naming conventions
4. **Propose a complete directory structure** showing all folders and key files
5. **Explain the purpose** of each major directory and file type
6. **Describe the organization rationale** and how it meets the requirements
7. **Identify content to duplicate** from the reference project and how it will be adapted
8. **Wait for my approval or feedback** before proceeding

**Phase 2: Iterative Refinement**

If I request changes:

1. **Revise the proposed structure** based on my feedback
2. **Explain the changes made** and why they address my concerns
3. **Present the updated proposal** for review
4. **Repeat this process** until I explicitly approve the structure

**Phase 3: Implementation**

Only after I provide explicit approval:

1. **Create the directory structure** as approved
2. **Generate all files** following the repository style guides
3. **Ensure compliance** with all formatting and documentation standards
4. **Provide a summary** of what was created and next steps

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

- **01-OnDemandClassification/**: Lab 1 focused on manual re-indexing and On-Demand Classification with scripts for SIT creation, SharePoint site classification, and Content Explorer validation
- **02-CustomSITs/**: Lab 2 for creating and tuning custom Sensitive Information Types using regex patterns, keyword dictionaries, confidence levels, and EDM configuration
- **03-RetentionLabels/**: Lab 3 demonstrating retention label configuration, auto-apply policies, SIT-based retention, and tiered retention strategies
- **04-PowerShellAutomation/**: Lab 4 featuring Compliance PowerShell scripts for content searches, bulk operations, and multi-site monitoring
- **05-Runbooks/**: Lab 5 containing comprehensive runbook documentation for end-to-end deployment, workflows, and operational handoff
- **scripts/**: Shared PowerShell modules and reusable functions for error handling, logging, and common Purview operations
- **data/**: Sample CSV files for EDM testing, example documents with sensitive data, and test datasets

**Organization Rationale:**

Numbered lab directories enable progressive learning where each lab builds on concepts from previous labs. This structure supports both hands-on learning and enterprise production deployment. Shared scripts directory promotes code reusability and maintains DRY principles. Comprehensive documentation in each lab ensures clarity for both learning environments and operational handoff. The from-scratch approach means all prerequisites and foundational setup steps are included, making the project suitable for users new to Purview while following enterprise-grade practices.

**Key File Types to be Created:**

- PowerShell scripts (.ps1): 15-20 files - Automation for classification, labeling, retention policies, content searches, and monitoring operations
- Markdown documentation (.md): 8-10 files - Step-by-step lab instructions, runbooks, prerequisites, and validation procedures
- JSON configuration files (.json): 5-7 files - SIT definitions, retention policy configurations, EDM schema definitions
- CSV data files (.csv): 3-5 files - Sample datasets for EDM testing and sensitive data examples
- Bicep/ARM templates (.bicep): 2-3 files - Infrastructure deployment if Azure resources are required

**Compliance Considerations:**

- PowerShell Style Guide compliance for all .ps1 files including proper preambles, color schemes, Phase/Step/Action terminology, and error handling patterns
- Markdown Style Guide compliance for all documentation including proper headers, punctuation, formatting, and AI-assisted content acknowledgments
- Azure resource naming conventions following Microsoft best practices
- Comprehensive documentation with industry-standard comment-based help format for PowerShell scripts

**Research Validation Plan:**

- Microsoft Graph Security API for Purview operations (learn.microsoft.com/graph/api/resources/security-api-overview)
- Microsoft Purview Compliance PowerShell cmdlets and module documentation
- SharePoint Online Management Shell cmdlets for site operations
- Microsoft 365 Compliance Center portal navigation and UI workflows
- Sensitive Information Type schema definitions and regex pattern validation
- Exact Data Match (EDM) configuration requirements and limitations
- Retention policy capabilities, limitations, and best practices
- Current API versions and feature availability as of November 2025

**Content Reuse from Reference Project:**

- PowerShell script patterns and modules identified in Microsoft/Purview/Purview-Skills-Ramp-OnPrem-and-Cloud/
- Documentation structures and step-by-step instruction formats to be adapted
- Error handling patterns and logging mechanisms to be duplicated
- Configuration file templates and JSON schema examples to be customized
- Sample data files and test datasets to be replicated
- **Note**: All content will be extracted and embedded directly - no links or references to the source project

**Awaiting Approval:** Please review this structure and provide feedback or approval to proceed.

```text

### For Iterative Refinement:

```text

## Revised Project Structure (Version [N])

**Changes Made Based on Feedback:**

1. Separated Exact Data Match (EDM) configuration into a dedicated subsection within Lab 02 for better focus and to avoid overwhelming learners with complex configuration in initial labs
2. Added dedicated data/ directory to each lab containing sample files, test datasets, and CSV files for EDM examples to improve hands-on learning experience
3. Consolidated common PowerShell functions (error handling, logging, connection management) into shared scripts/ directory to promote code reusability and reduce duplication across labs
4. Enhanced Lab 05 runbook documentation to include more detailed operational handoff guidance and production deployment checklists
5. Added validation checkpoints at the end of each lab to ensure successful completion before progressing to the next lab

**Updated Directory Tree:**

```text
purview-labs/
├── README.md
├── 01-OnDemandClassification/
│   ├── README.md
│   ├── scripts/
│   └── data/
├── 02-CustomSITs/
│   ├── README.md
│   ├── scripts/
│   ├── data/
│   └── edm/
├── 03-RetentionLabels/
│   ├── README.md
│   ├── scripts/
│   └── configs/
├── 04-PowerShellAutomation/
│   ├── README.md
│   └── scripts/
├── 05-Runbooks/
│   ├── README.md
│   └── docs/
└── scripts/
    ├── common/
    └── modules/
```

**Updated Rationale:**

The revised structure addresses feedback about complexity by isolating advanced EDM topics into a clear subsection, making it easier for learners to skip or revisit as needed. The dedicated data directories improve hands-on learning by providing immediate access to test files. Shared PowerShell modules reduce code duplication and demonstrate enterprise best practices for maintainable automation. Enhanced validation checkpoints ensure users can confirm successful completion before moving forward, reducing frustration and support requests. The updated structure maintains progressive learning while providing flexibility for different skill levels and use cases.

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

**Example Research Patterns:**

```text
WRONG: "Navigate to Settings → Security → Enable MFA"
(Relying on training data for UI navigation)

RIGHT: [Use fetch_webpage to research current Azure portal navigation]
"Navigate to **Azure Portal** → **Azure Active Directory** → **Security** → **Multifactor authentication** 
(As of November 2025, path verified from learn.microsoft.com)"
```

```text
WRONG: New-AzStorageAccount -Name "storage" -ResourceGroupName "rg"
(Assuming parameter syntax from training data)

RIGHT: [Research current Az PowerShell cmdlet documentation]
New-AzStorageAccount -ResourceGroupName "rg-name" -Name "storageaccountname" -Location "eastus" -SkuName "Standard_LRS"
# Verified against Az.Storage module v6.x documentation (November 2025)
```

### For Implementation Summary

```text

## Project Implementation Complete

**Created Structure:**

Created 5 numbered lab directories (01-OnDemandClassification through 05-Runbooks), 18 PowerShell scripts across labs and shared modules, 9 markdown documentation files including comprehensive README files for each lab, 6 JSON configuration files for SIT definitions and retention policies, 4 CSV sample datasets for EDM testing, and 1 shared scripts directory with common modules for connection management, error handling, and logging.

**Style Guide Compliance:**

- ✅ Markdown formatting standards applied to all documentation files
- ✅ PowerShell Style Guide followed: proper preambles with SYNOPSIS/DESCRIPTION/EXAMPLES, appropriate Phase/Step terminology, consistent color schemes (Green for steps, Cyan for info, Red for errors), comprehensive error handling with try-catch blocks, and modular design patterns
- ✅ Proper documentation headers and industry-standard comment-based help included in all scripts
- ✅ AI-assisted content generation acknowledgments added to all comprehensive documentation files

**Research Validation Performed:**

- ✅ Microsoft Purview APIs validated against Microsoft Learn Purview documentation (learn.microsoft.com/purview, November 2025)
- ✅ PowerShell cmdlets verified using Microsoft.Purview module v2.1.0 documentation and ExchangeOnlineManagement module v3.x references
- ✅ Current versions confirmed: Microsoft.Purview module v2.1.0, SharePoint Online Management Shell v16.0.24211.12000, ExchangeOnlineManagement v3.4.0
- ✅ Microsoft Purview Compliance portal navigation validated November 2025 from official Microsoft 365 admin documentation (learn.microsoft.com/microsoft-365/compliance)
- ✅ SIT regex patterns and EDM schema validated against current Purview documentation and schema requirements
- ✅ Retention policy capabilities and limitations verified against Microsoft 365 compliance feature documentation

**Next Steps:**

1. Review prerequisites in root README.md and set up Microsoft 365 E5 trial environment or ensure appropriate Purview licensing (E5 Compliance or equivalent)
2. Execute Lab 01-OnDemandClassification to establish baseline Purview configuration, create initial SITs, and test On-Demand Classification on a sample SharePoint site
3. Validate Content Explorer results showing classified documents, then proceed to Lab 02-CustomSITs to develop custom regex-based and EDM-based sensitive information types
4. Complete Lab 03-RetentionLabels to implement retention policies and observe their application across SharePoint sites
5. Advance to Lab 04-PowerShellAutomation to automate classification and monitoring operations at scale
6. Review Lab 05-Runbooks for operational handoff and production deployment guidance

**Additional Notes:**

This project assumes no prior Purview configuration or existing deployment. All labs are designed for progressive learning with comprehensive validation checkpoints at each stage. PowerShell scripts include production-grade error handling, logging, and connection management suitable for enterprise use. Each lab builds on concepts from previous labs but remains self-contained with clear prerequisites listed. The project follows repository style guides for PowerShell and Markdown, ensuring consistency with other projects. All content has been validated against current Microsoft Learn documentation as of November 2025.
```

## CRITICAL RULES

1. **Never skip the approval phase** - Always wait for explicit approval before creating files
2. **Never assume project structure** - Always propose and iterate based on feedback
3. **Always read style guides first** - Ensure compliance from the start, not as an afterthought
4. **Always review reference projects** - Use semantic_search and read_file to extract reusable patterns from Purview-Skills-Ramp project
5. **Always duplicate, never link** - Extract and embed content directly; never create references or links to other projects
6. **Always validate against official documentation** - Never rely on training data for technical instructions, code examples, or current procedures
7. **Always use deep reasoning agents** - Engage extended thinking/deep reasoning models for research, analysis, architectural decisions, and technology validation
8. **Always research before suggesting** - Use Microsoft Learn for Microsoft technologies, official vendor docs for other technologies
9. **Always provide detailed explanations** - Help me understand your design decisions
10. **Always be ready to iterate** - Expect multiple rounds of refinement
11. **Never create partial implementations** - Wait for full approval of the complete structure

## STYLE GUIDE COMPLIANCE CHECKLIST

Before implementing, verify:

- [ ] Reviewed applicable style guides from Style Guides/ directory
- [ ] Reviewed existing Purview-Skills-Ramp-OnPrem-and-Cloud project for reusable patterns
- [ ] Identified PowerShell scripts, documentation templates, and configuration files to duplicate
- [ ] Planned content extraction strategy - no links or references, only embedded duplicated content
- [ ] Understood repository copilot-instructions.md requirements
- [ ] Confirmed file naming conventions for target technology
- [ ] Identified required documentation standards
- [ ] Planned for AI-assisted content generation acknowledgments
- [ ] Understood header, formatting, and punctuation requirements
- [ ] Identified any technology-specific patterns to follow
- [ ] **Researched current documentation** from Microsoft Learn or official sources for all technical content
- [ ] **Validated API versions, cmdlet syntax, and library versions** against current official documentation
- [ ] **Verified UI navigation paths and portal instructions** using current official resources (not training data)
- [ ] **Engaged deep reasoning agents** for architectural decisions, technology selection, and complex analysis

## EXAMPLE USAGE

**Example Fill-In:**

```text
**Skill Area / Domain Expertise Required:**
Microsoft Purview Information Protection, Data Lifecycle Management, and PowerShell automation for enterprise data governance

**Specific Targeted Content:**
Create a comprehensive "from scratch" lab environment demonstrating Microsoft Purview's data classification, protection, and lifecycle management capabilities. The project should include:

1. **On-Demand Classification for SharePoint & OneDrive:**
   - Lab demonstrating manual re-indexing of existing content using Purview's On-Demand Classification
   - Steps to create new Sensitive Information Types (SITs)
   - Running On-Demand Classification on SharePoint sites
   - Validation of results in Content Explorer

2. **Custom Sensitive Information Types (SITs):**
   - Labs for creating and tuning custom SITs using regex patterns, keyword dictionaries, and confidence levels
   - Exact Data Match (EDM) configuration examples
   - Trainable Classifiers for unstructured data analysis

3. **Retention Labels & Data Lifecycle Management (DLM):**
   - Configuration of retention labels and auto-apply policies
   - Retention based on SIT detection and file age
   - Deletion workflows using retention policies
   - Tiered retention strategies and policy ceilings

4. **Automation & Scaling with PowerShell:**
   - Scripts using Compliance PowerShell for content searches
   - Automated bulk deletion and labeling actions
   - Monitoring classification and policy adoption across multiple sites
   - Error handling, logging, and modular design patterns

5. **Runbook Documentation:**
   - End-to-end Purview deployment procedures
   - Classification, labeling, retention, and automation workflows
   - Operational handoff guidance for enterprise teams

**Target File Types to Create:**
PowerShell scripts (.ps1), JSON configuration files (.json), Markdown documentation (.md), CSV data files for EDM examples (.csv), Bicep/ARM templates for infrastructure (.bicep), YAML workflow files if applicable (.yml)

**Organization & Structure Requirements:**
Follow Infrastructure-as-Code patterns with:
- Separate numbered lab directories (01-OnDemandClassification/, 02-CustomSITs/, 03-RetentionLabels/, etc.)
- scripts/ directory for PowerShell automation with proper preambles and error handling
- docs/ or individual lab README files with step-by-step instructions
- data/ or samples/ directory for example files and test data
- infra/ directory if Azure resources are needed
- Comprehensive root-level README with project overview, prerequisites, and lab progression
- Each lab should be self-contained but build on previous concepts
- Include validation steps and expected outcomes for each lab
- Leverage existing patterns and instructions from similar projects in the repository without explicit references

**Additional Context:**
This is a "from scratch" setup - do not assume any prior Purview configuration or completed work. All prerequisites, environment setup, and foundational steps must be included. The project should be suitable for learning Purview from the ground up while following enterprise-grade practices for production readiness.
```

**Alternative Example (Simpler Project):**

```text
**Skill Area / Domain Expertise Required:**
Azure Logic Apps integration with Microsoft Defender XDR for automated incident response

**Specific Targeted Content:**
Create a Logic App workflow that monitors Defender XDR for high-severity incidents, enriches them with AI-generated analysis using Azure OpenAI, and posts results to Microsoft Teams

**Target File Types to Create:**
Bicep templates (.bicep), PowerShell deployment scripts (.ps1), JSON configuration files (.json), Logic App workflow definition (JSON), Markdown documentation (.md)

**Organization & Structure Requirements:**
Follow Infrastructure-as-Code patterns with separate infra/ for templates, scripts/ for automation, and comprehensive README documentation at root level
```

---

## ADDITIONAL GUIDANCE FOR AI ASSISTANTS

### Best Practices for Multi-Model Compatibility

1. **Clear Section Markers:** Use distinct headers and formatting for easy parsing
2. **Explicit Instructions:** State requirements directly without ambiguity
3. **Structured Output:** Define expected response formats clearly
4. **Iterative Design:** Build in feedback loops and approval gates
5. **Compliance Focus:** Emphasize style guide and standard adherence
6. **Contextual Awareness:** Reference existing repository patterns
7. **Documentation-First Approach:** Always validate technical content against official sources before suggesting
8. **Research Integration:** Use fetch_webpage, documentation search, or semantic search tools to validate current information
9. **Deep Reasoning Engagement:** Use extended thinking capabilities for architectural decisions, complex analysis, and comprehensive research

### Adaptation Tips for Different Models

- **Claude:** Excels at following structured instructions and iterative refinement; strong research capabilities with fetch_webpage; supports extended thinking for deep reasoning
- **GPT Models:** Strong with technical implementation and code generation; can use web search for validation; o1 models provide advanced reasoning capabilities
- **Gemini:** Effective with multi-step reasoning and project planning; good at documentation synthesis; Deep Research mode for comprehensive analysis

### Deep Reasoning Use Cases

**Always engage deep reasoning agents for:**

- **Architectural Decisions:** Choosing between competing technologies, frameworks, or design patterns
- **Complex Analysis:** Evaluating trade-offs, scalability considerations, or security implications
- **Research Synthesis:** Combining information from multiple sources to form comprehensive recommendations
- **Technology Selection:** Determining optimal tools, libraries, or services for specific requirements
- **Problem Decomposition:** Breaking down complex projects into logical, manageable components
- **Best Practice Validation:** Analyzing whether proposed approaches align with industry standards
- **Integration Planning:** Designing how multiple systems, services, or components should interact

**How to Request Deep Reasoning:**

- **Claude:** "Please use extended thinking to analyze..." or enable deep reasoning in chat settings
- **GPT o1:** Use o1-preview or o1-mini models which engage reasoning automatically
- **Gemini:** Request "Deep Research" mode or use Gemini 2.0 Flash Thinking experimental model
- **General:** Explicitly state "Please engage deep reasoning for this analysis..."

### Research Tools and Techniques

**Available Research Methods:**

- **fetch_webpage**: Retrieve current content from Microsoft Learn, official documentation pages
- **Documentation Search**: Query official documentation repositories and knowledge bases
- **Semantic Search**: Find existing patterns and implementations within the repository (especially in Purview-Skills-Ramp project)
- **read_file**: Extract specific content from existing project files to duplicate and adapt
- **Version Checking**: Verify current API versions, library versions, and feature availability

**When to Use Each Method:**

- **Step-by-step portal instructions**: Use fetch_webpage on Microsoft Learn articles
- **Code syntax validation**: Search official API documentation or SDK references
- **Current feature availability**: Check version-specific documentation and release notes
- **Best practices**: Review official guidance documents and architecture centers
- **Deprecated features**: Verify against changelog and migration guides
- **Content extraction from reference projects**: Use semantic_search to find relevant files, then read_file to extract and duplicate content

### Common Pitfalls to Avoid

- Creating files before receiving approval
- Skipping style guide review in favor of speed
- Making assumptions about project structure
- Ignoring existing repository patterns
- Rushing implementation without iteration
- **Relying on training data for step-by-step instructions or code examples**
- **Assuming API versions, cmdlet syntax, or SDK methods without validation**
- **Providing UI navigation instructions without researching current portal layouts**
- **Suggesting code patterns without verifying against official documentation**
- **Skipping documentation research in favor of speed**
- **Not engaging deep reasoning for complex architectural or analytical decisions**
- **Making technology choices without thorough evaluation and reasoning**

```

---

## 🤖 AI-Assisted Content Generation

This project creation prompt template was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for AI prompting, multi-model compatibility, and repository-specific compliance requirements.

*AI tools were used to enhance productivity and ensure comprehensive coverage of project creation workflows while maintaining technical accuracy and reflecting established repository standards for content creation and style guide adherence.*

```
