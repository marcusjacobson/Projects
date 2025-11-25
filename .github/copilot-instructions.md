---
applyTo: '**'
---

# Projects Repository – AI Assistant Instructions

This repository contains various technology projects including Azure AI Security ---

## 4. 🚀 Azure DevOps Pipeline Development Standards

### 4.1 Pipeline Architecture Awarenesss Challenge, Microsoft Sentinel implementations, and GitHub automation workflows. All content follows strict style guides and professional documentation standards to ensure consistency, accuracy, and maintainability.

## 📋 Repository Purpose

**Core Function:** Multi-project technology portfolio with focus on Azure security, AI integration, and automation

**Primary Content:** Markdown documentation, PowerShell scripts, Infrastructure-as-Code templates, and GitHub workflows

**Quality Standard:** Enterprise-grade documentation and code with strict lint compliance and style guide adherence

---

## 1. 📏 Style Guide Compliance (Primary Focus)

### 1.1 Style Guide References

This repository maintains centralized style guides that MUST be followed for all content:

- **[Markdown Style Guide](../Repository-Management/Style-Guides/markdown-style-guide.md)** - Comprehensive formatting, punctuation, and tone standards
- **[PowerShell Style Guide](../Repository-Management/Style-Guides/powershell-style-guide.md)** - Visual and organizational patterns for PowerShell scripts
- **[Parameters File Style Guide](../Repository-Management/Style-Guides/parameters-file-style-guide.md)** - Configuration standards for Azure parameters files

### 1.2 Systematic Review Requirements

When reviewing or creating markdown documents, follow the systematic approach defined in the Markdown Style Guide:

**AI Assistant Compliance Process:**

1. **Read entire document** before making any edits to understand structure and identify ALL issues
2. **Categorize all findings** by type (punctuation, headers, spacing, etc.)
3. **Fix by category** across entire document, not by location
4. **Single-type edits only** - never combine multiple violation types in one edit
5. **Use sufficient context** (3-5 lines) in replace_string_in_file calls
6. **Validate after each category** of fixes

**Critical Distinction - Table Cells vs Lists:**

- **NEVER add periods to table cell descriptions** - they are descriptions, not standalone bullet points
- **DO add periods to actual bulleted lists** outside of tables
- **Example CORRECT**: Table cell: "OAuth 2.0 with Azure AD" (no period)
- **Example CORRECT**: List item: "Enable authentication for security." (with period)

### 1.3 Markdown Formatting Standards (From Style Guide)

| Aspect | Requirement | Example |
|--------|-------------|---------|
| **Headers** | Use hash-based headers (####), never bold text | `**Section:**` → `#### Section` |
| **Header Uniqueness** | All headings must be unique and descriptive | "Configuration Steps" → "Workbook Configuration Steps" |
| **Interface Elements** | Bold formatting instead of quotes | "Settings" → **Settings** |
| **Code Block Spacing** | Blank lines before and after (MD031) | Surround all fenced code blocks |
| **List Spacing** | Blank lines before and after (MD032) | Surround all bullet and numbered lists |
| **Punctuation** | Standalone bullet points end with periods | "Enable feature." |
| **Punctuation** | Introductory bullet points end with colons | "Configure settings:" |

### 1.4 AI Prompt Integration

When asked to review markdown formatting, use the AI Assistant Compliance Prompt from the Markdown Style Guide to ensure systematic, comprehensive compliance while preventing common mistakes.

---

## 2. 🔍 Research and Validation Standards

### 2.1 Primary Source Hierarchy

**Required Research Order:**

1. **Microsoft Learn Documentation** (learn.microsoft.com) - Primary for Microsoft technologies
2. **Official Microsoft Documentation** (docs.microsoft.com, github.com/Microsoft)
3. **Google Cloud Documentation** (cloud.google.com) - For GCP technologies
4. **AWS Documentation** (docs.aws.amazon.com) - For AWS technologies
5. **Official Product Documentation** - Direct from vendor sources
6. **Third-party sources** - Only after validating with official sources

### 2.2 Content Accuracy Requirements

**Before providing any instructions:**

- Verify current API versions and available features.
- Check for deprecated methods or outdated approaches.
- Validate all PowerShell cmdlets and parameters.
- Confirm Azure portal navigation paths are current.
- Test REST API endpoints and required headers.

**Link Validation Process:**

- Verify each hyperlink resolves correctly.
- Ensure link content matches the referenced context.
- Use descriptive link text that indicates destination.
- Prefer official documentation links over third-party tutorials.

### 2.3 Modern Instruction Standards

**CRITICAL: Always Research Current UI/Workflows for Step-by-Step Instructions**

Portal interfaces, admin centers, and product UIs change frequently. **NEVER rely on training data** for step-by-step procedural instructions. Always research current workflows using official documentation.

**Mandatory Research Before Creating/Updating Step-by-Step Instructions:**

- **Azure Portal Navigation**: Use `fetch_webpage` to verify current menu locations, button names, and wizard workflows from [learn.microsoft.com/azure](https://learn.microsoft.com/en-us/azure/)
- **M365 Admin Center**: Research current UI layout (Simplified view vs Dashboard view) from official Microsoft 365 documentation
- **Product Installation Workflows**: Verify current download pages, installer UIs, and configuration wizards
- **API/Service Configurations**: Check current authentication flows, permission requirements, and API endpoints
- **Portal Terminology**: Confirm current button labels ("Create" vs "+ Add", "Purchase services" vs "Marketplace", etc.)

**When Creating Step-by-Step Procedures:**

- **Research first, write second**: Use `fetch_webpage` to gather current workflow information before documenting steps
- **Include version indicators**: Add "As of [Month Year]" notes for time-sensitive UI instructions
- **Document UI variations**: Note when interfaces differ (subscription types, regions, view modes)
- **Verify navigation paths**: Confirm menu hierarchies, search terminology, and button sequences
- **Test current terminology**: Use exact current button names, field labels, and menu items
- **Add portal notes**: Include blockquotes explaining known UI variations or recent changes

**Example Research Pattern for Step-by-Step Instructions:**

```markdown
> **💡 Portal Note**: The Azure Portal interface may vary slightly based on your 
> subscription type and region. The steps below reflect the current portal as of 
> [Month Year].
```

**Template Validation Requirements:**

- Verify current Azure resource API versions for Bicep/ARM templates using official documentation
- Validate JSON Schema compliance with current OpenAPI specifications
- Check KQL syntax against current Kusto documentation
- Confirm YAML structure follows Azure DevOps pipeline schema requirements
- Test template parameter types and validation rules
- Validate resource naming conventions against Azure best practices

---

## 3. 💻 PowerShell Standards

### 3.1 PowerShell Style Guide Compliance

All PowerShell content must follow the [PowerShell Style Guide](../Repository-Management/Style-Guides/powershell-style-guide.md) requirements:

**Script Classification:**

- **Orchestrator Scripts** use "Phase" terminology with Magenta headers.
- **Individual Scripts** use "Step" terminology with Green headers.
- **Pipeline-Executed Scripts** use "Action" terminology with Write-Verbose patterns.
- Proper color scheme implementation for status notifications.

**Preamble Requirements:**

- Industry-standard comment-based help format.
- Complete documentation including SYNOPSIS, DESCRIPTION, EXAMPLES.
- Proper authorship attribution: "Marcus Jacobson" with "GitHub Copilot" acknowledgment.
- Appropriate specialized sections based on script functionality.

**Pipeline-Specific Requirements:**

- Use Write-Verbose with -Verbose for pipeline visibility.
- Parameter-driven configuration from pipeline variables loaded from `pipeline-variables.yml`.
- Comprehensive try-catch blocks for pipeline stability.
- REST API integration for enhanced control.
- No interactive elements or user prompts.

**Command-Line Parameters File Integration:**

- Use `-UseParametersFile` parameter pattern for command-line deployment scripts following established IaC patterns.
- Load configuration from centralized `main.parameters.json` files in each project's `infra/` directory.
- Follow cumulative parameters approach - add new parameters for additional features without overwriting existing ones.
- Enable cross-component integration through shared foundation parameters (environmentName, location, etc.).
- **Note**: Pipeline-based projects use `pipeline-variables.yml` instead of parameters files.

**REST API Integration Requirements:**

- **Always prefer REST API calls via `az rest` commands** over direct Azure PowerShell cmdlets or standard Azure CLI commands when possible.
- Use REST API calls for enhanced control, better error handling, and more precise resource management.
- Follow the recommended method hierarchy: `az rest` (primary) → Azure CLI commands (secondary) → Azure PowerShell cmdlets (tertiary).
- Include comprehensive error handling and API version specifications for REST API calls.
- Use REST API integration for pipeline reliability and future-proofing with Azure's native interfaces.

### 3.2 Command Validation Requirements

**Before suggesting any PowerShell commands:**

1. Verify cmdlet exists in current PowerShell/Azure PowerShell versions.
2. Check parameter names and syntax against latest documentation.
3. Validate REST API endpoints and required authentication.
4. Confirm Azure CLI command structure and available options.
5. Test JSON payload structure for API calls.

**Never assume or guess:**

- PowerShell cmdlet parameters from training data.
- Azure REST API endpoint structures.
- Authentication requirements or token formats.
- JSON schema without verification.

### 3.3 Emoji Corruption Resolution

**PowerShell scripts may experience Unicode emoji corruption requiring specific handling:**

**Detection Indicators:**
- Mixed content with interleaved characters
- Emojis displaying as � replacement characters
- Corrupted preamble sections with fragmented help content
- Malformed step headers and formatting disruption

**Resolution Protocol:**
1. **Assess corruption scope** using `grep_search` with `�` pattern
2. **For extensive corruption**: Complete file recreation is most reliable solution
3. **Recreation process**: 
   - Remove corrupted file with `Remove-Item`
   - Build script in logical sections using terminal commands
   - Use proper PowerShell escaping for emoji characters
   - Validate with `get_errors` and emoji integrity checks
4. **Success validation**: Zero syntax errors, clean emoji display, no � characters

**This methodology has proven effective for severe corruption cases that cannot be resolved through standard editing operations.**

---

## 4. � Azure DevOps Pipeline Development Standards

### 4.1 Pipeline Architecture Awareness

**Repository Pipeline Patterns:**

When working with Azure DevOps pipeline-driven projects like Sentinel-as-Code:

- **Foundation Layer First**: Resource Group → Log Analytics → Microsoft Sentinel deployment order.
- **Sequential Dependencies**: Each stage depends on successful completion of previous stage.
- **Service Connection Integration**: Pipeline authentication through Azure service connections.
- **Variable Template Usage**: Centralized configuration through pipeline-variables.yml patterns.

### 4.2 Pipeline PowerShell Script Standards

**Script Development for Pipelines:**

- Follow Pipeline-Executed Scripts classification from PowerShell Style Guide.
- Use "Action" terminology instead of "Phase" or "Step".
- Implement Write-Verbose with -Verbose for pipeline output visibility.
- Design for parameter-driven configuration from pipeline variables.
- Include comprehensive try-catch blocks for pipeline stability.
- Use REST API calls for enhanced Azure resource control.
- Avoid any interactive elements or user prompts.

**Pipeline YAML Standards:**

- Use multi-stage pipeline structure with clear stage dependencies.
- Implement proper job and step organization.
- Include displayName properties for clear pipeline visualization.
- Use condition checks for stage execution control.
- Implement variable template references for configuration management.

### 4.3 Sentinel-as-Code Project Patterns

**When working with Microsoft Sentinel automation:**

- Understand foundation deployment pattern (RG → LA → Sentinel → Content).
- Recognize security content deployment as separate layer.
- Use REST API integration for Sentinel-specific operations.
- Implement proper error handling for sequential dependencies.
- Follow established naming conventions for pipeline stages and jobs.

### 4.4 Pipeline vs Command-Line Distinction

**Recognize project development approaches:**

- **Command-Line Projects**: Use traditional PowerShell patterns with Write-Host, interactive elements
- **Pipeline Projects**: Use Write-Verbose patterns, parameter-driven configuration, no user interaction
- **Hybrid Projects**: May contain both approaches - apply appropriate patterns based on execution context
- **Documentation**: Clearly distinguish between approaches in procedural documentation

---

## 5.  Documentation Creation Standards

### 5.1 Content Structure Requirements

**New Document Creation:**

- Use proper markdown headers (####) from the start, never bold text.
- Apply style guide formatting during initial creation, not just reviews.
- Include appropriate emoji usage following established patterns.
- Implement proper spacing around lists and code blocks immediately.

**Professional Documentation Voice:**

- Clear, concise, instructional language for technical professionals.
- Avoid casual language, contractions, and informal expressions.
- Maintain consistency in terminology and technical concepts.
- Use active voice when possible for clarity and directness.

### 5.2 Step-by-Step Instruction Formatting

**Preferred Format** (from Markdown Style Guide):

Use bullet points with paragraph breaks between logical groupings:

```markdown
- Go to [portal.azure.com](https://portal.azure.com) and sign in.
- Navigate to **Resource Groups** in the left menu.
- Click **+ Create** to start the creation process.

Navigate to your newly created resource group.

- Verify the resource group appears in the list.
- Check that all settings are configured correctly.
- Test access to ensure proper permissions.
```

### 5.3 Quality Assurance Integration

**Before completing any document:**

- Run through the Quality Assurance Checklist from the Markdown Style Guide.
- Verify all markdown lint warnings are resolved (MD001, MD024, MD031, MD032, MD040).
- Confirm interface elements use bold formatting instead of quotes.
- Validate that headers are unique and descriptive.
- Ensure blockquotes have proper emoji categorization and spacing.

### 5.4 Template File Formatting Standards

**Infrastructure-as-Code Templates (Bicep/ARM):**

- Use consistent parameter naming with descriptive names (`workspaceName` not `name`).
- Include resource API versions explicitly (`@2023-09-01`).
- Implement proper parameter types and descriptions.
- Use consistent indentation (2 spaces for YAML, 4 spaces for JSON).
- Include comprehensive parameter validation where applicable.
- Follow Azure resource naming conventions in default values.

**JSON Schema and Configuration Files:**

- Use proper JSON formatting with consistent indentation (2 spaces).
- Include descriptive `description` properties for all schema elements.
- Implement appropriate type validation (`string`, `integer`, `object`, `array`).
- Use `enum` constraints for limited value sets.
- Include `required` arrays for mandatory properties.
- Provide meaningful examples in descriptions for complex schema elements.

**Azure DevOps Pipeline YAML Templates:**

- Use consistent YAML formatting with 2-space indentation.
- Include comprehensive comments explaining pipeline stages and variables.
- Structure variable groups with clear sectioning and security guidance.
- Use descriptive `displayName` properties for all jobs and steps.
- Implement proper variable scoping and template references.
- Include security best practices in variable comments.

**KQL (Kusto Query Language) Templates:**

- Use consistent capitalization for KQL operators (uppercase: `WHERE`, `SUMMARIZE`, `JOIN`).
- Implement proper time range specifications with clear variable naming.
- Use descriptive column aliases for calculated fields.
- Include comments explaining complex query logic.
- Structure multi-line queries with logical indentation.
- Follow Kusto naming conventions for functions and variables.

**JSON Configuration Templates:**

- Maintain consistent property ordering (type, description, required properties first).
- Use meaningful property names that indicate purpose and data type.
- Include comprehensive validation rules where applicable.
- Implement proper nesting structure for complex configurations.
- Use descriptive comment-style documentation where JSON supports it.
- Follow established naming patterns within the same template family.

**Template Documentation Requirements:**

- Include header comments explaining template purpose and usage.
- Document all parameters with types, purposes, and example values.
- Specify required Azure permissions or prerequisites.
- Include deployment examples and common configuration scenarios.
- Reference related templates and dependencies.
- Maintain version information and last modified dates.

**Parameters File Standards (main.parameters.json) - Command-Line Scripts Only:**

All parameters file configuration must follow the [Parameters File Style Guide](../Repository-Management/Style-Guides/parameters-file-style-guide.md) requirements:

**Consistent Parameters File Usage:**

- **Always use `-UseParametersFile` parameter** in command-line PowerShell deployment scripts following established IaC patterns.
- **Centralized configuration** through `main.parameters.json` files in each project's `infra/` directory.
- **Cumulative parameters approach** - add new parameters for additional features without overwriting existing ones.
- **Environment-specific values** configured in parameters file rather than hard-coded in scripts.
- **Pipeline Distinction**: Pipeline-based projects use `pipeline-variables.yml` instead of parameters files.

**Parameters File Structure Requirements:**

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environmentName": { "value": "descriptive-env-name" },
    "location": { "value": "East US" },
    "notificationEmail": { "value": "admin@domain.com" },
    "feature1EnableFlag": { "value": false },
    "feature2EnableFlag": { "value": false }
  }
}
```

**Script Integration Patterns:**

```powershell
# Standard parameters file loading pattern
.\scripts\Deploy-ComponentName.ps1 -UseParametersFile
.\scripts\Test-ComponentValidation.ps1 -UseParametersFile -DetailedReport
.\scripts\Remove-ComponentName.ps1 -UseParametersFile -Force
```

**Parameters File Extension Guidelines:**

- **Additive approach only** - never remove or modify existing parameters that other components depend on.
- **Feature-specific grouping** - group related parameters together with descriptive naming.
- **Boolean flags** - use `enable[FeatureName]` pattern for optional component deployment.
- **Default values** - provide safe defaults that work in lab environments.
- **Production overrides** - document which parameters typically need production-specific values.

**Cross-Component Parameter Sharing:**

- **Shared foundation parameters** - `environmentName`, `location`, `notificationEmail` used across all components.
- **Resource group references** - use descriptive parameter names like `defenderResourceGroupName`, `aiResourceGroupName`.
- **Cross-week dependencies** - Week 2 can reference Week 1 resource groups through parameters.
- **Service integration** - OpenAI services, storage accounts, and other shared resources referenced through parameters.

---

## 6. 🤖 AI Response Guidelines

### 6.1 Content Validation Process

**When multiple solutions exist:**

- Present options with brief pros/cons.
- Ask for user preference before proceeding.
- Explain rationale for recommendations.
- Consider complexity, maintainability, and best practices.

**Decision Points Requiring Confirmation:**

- Choice between deployment methods (Portal vs CLI vs IaC).
- Script architecture decisions (orchestrator vs individual components).
- Authentication approaches (service principal vs managed identity).
- Documentation depth and scope for new content.

### 6.2 Implementation Standards

**Always:**

- Follow systematic section-by-section approach for document reviews.
- Use replace_string_in_file with sufficient context (3-5 lines).
- Address one formatting issue category at a time across entire document.
- Apply proper markdown headers (#### Header Name) for ALL content structure from the start.
- **Research current UI/workflows using `fetch_webpage`** before writing step-by-step instructions.
- **NEVER rely on training data** for portal navigation, admin center workflows, or product installation steps.
- Validate web resource links for currency and accuracy.
- Use the style guides' AI compliance prompts for systematic reviews.
- **Prefer REST API calls via `az rest` commands** over direct PowerShell cmdlets or standard Azure CLI commands when possible.
- **Always wait for script completion** before attempting to execute additional commands.
- **Use `isBackground=false`** for all PowerShell script executions to ensure proper completion tracking.
- **Monitor script execution status** and exit codes before proceeding to next operations.
- **Allow sufficient time** for Azure CLI operations and resource provisioning to complete.
- **Check script completion** using `get_terminal_output` when scripts appear to hang or timeout.
- **Never attempt parallel script execution** for deployment scripts that may have dependencies.
- **Validate exit codes and errors** before considering script operations successful.
- **When scripts are running or hanging**, provide clear guidance to the user about script status and ask them to confirm when execution is complete.
- **After script completion confirmation**, immediately analyze terminal output using `get_terminal_output` to determine success/failure and next steps.

**Template File Standards:**

- Verify API versions in Bicep/ARM templates match current Azure documentation.
- Validate JSON Schema against current specifications and include proper descriptions.
- Use consistent indentation (2 spaces for YAML/JSON, 4 spaces for complex nested structures).
- Include comprehensive parameter documentation in template headers.
- Follow established naming conventions for template parameters and resources.
- Implement proper validation rules and required property arrays.

**Never:**

- Skip sections or make arbitrary changes without understanding context.
- Use bold text with colons as section headers (`**Section Name:**` is WRONG).
- Mix multiple fix types in single edit operation.
- **Rely on training data for UI navigation paths, button names, or portal workflows** - always research current interfaces.
- Guess at command syntax or API structures from training data.
- Ignore markdown lint warnings or style guide violations.
- Add periods to table cell descriptions (they are not lists).
- Use outdated API versions in templates without verification.
- Create templates without proper parameter descriptions and validation rules.
- **Execute multiple scripts simultaneously** when they have potential resource dependencies.
- **Cancel or interrupt scripts** without checking completion status first.
- **Assume script success** without verifying exit codes and output.
- **Start new operations** while previous scripts are still executing or hanging.
- **Continue with follow-up actions** until the user confirms script completion and terminal output has been analyzed.
- **Write step-by-step instructions without researching current UI** from official documentation.

### 6.3 Script Execution Monitoring Protocol

**When a script is launched or appears to be running:**

1. **Acknowledge script execution** and inform the user that the script is running
2. **Explain expected behavior** (e.g., "This deployment script typically takes 3-5 minutes to complete")
3. **Request user confirmation** when script execution is complete using this format:

> **🔄 Script Execution Status**: The Deploy-LogicAppWorkflow.ps1 script is currently running. This script typically takes several minutes to complete as it validates prerequisites, creates Azure resources, and configures integrations.
> 
> **⏳ Please confirm when the script has finished executing** (either successfully or with an error) so I can analyze the terminal output and determine the next steps.
> 
> **Expected indicators of completion:**
> - The PowerShell prompt returns (PS C:\...\>)
> - You see a final success message or error message
> - The script execution stops with an exit code

4. **After user confirmation**, immediately use `get_terminal_output` to analyze results
5. **Determine next steps** based on terminal output analysis (success, specific errors, or partial completion)

**Script Hanging Protocol:**

- If a script appears to hang for an extended period, inform the user and ask them to:
  - Check if the script is waiting for input
  - Verify if Azure CLI authentication is required
  - Confirm if any Azure operations are still in progress
  - Cancel the script if necessary and report what step it stopped at

### 6.3 Error Prevention Focus

**Critical Reminders:**

- Distinguish between table descriptions and actual lists for punctuation.
- Use official Microsoft Learn as primary research source.
- **Always use `fetch_webpage` to research current UI before writing step-by-step instructions.**
- **Portal interfaces change frequently** - verify current menu locations, button names, and workflows.
- Validate all PowerShell cmdlets and REST API calls before suggesting.
- Apply style guide standards during content creation, not just reviews.
- Ensure header uniqueness to prevent MD024 lint warnings.
- Include language identifiers in all code blocks (MD040).

---

## 7. 📁 Repository-Specific Standards

### 7.1 Project Structure Awareness

**Key Repository Areas:**

- `Style-Guides/` - Central style guide location (reference these first)
- `Microsoft/Azure Ai Security Skills Challenge/` - AI security learning path
- `Microsoft/Sentinel/` - Microsoft Sentinel implementations
- `Repository-Management/Github-Sync/` - Repository synchronization workflows

### 7.2 Cross-Reference Standards

**When working across projects:**

- Use relative paths for internal repository links.
- Reference style guides consistently across all projects.
- Maintain naming conventions appropriate to each project area.
- Ensure documentation standards apply uniformly.

### 7.3 Workflow Integration

**For GitHub Actions and automation:**

- Follow PowerShell style guide for any script components.
- Use proper markdown formatting for workflow documentation.
- Validate YAML syntax and structure.
- Test automation scripts before suggesting implementation.

---

## 8. ⚠️ Common Issues & Prevention

### 8.1 Frequent Formatting Mistakes

| Issue | Prevention | Correct Approach |
|-------|-----------|------------------|
| Bold pseudo-headers | Use proper headers from creation | `**Setup:**` → `#### Setup` |
| Table cell periods | Recognize descriptions vs lists | Table: "OAuth method" (no period) |
| Missing code spacing | Add blank lines during creation | Surround all ```blocks |
| Duplicate headings | Make headers descriptive and unique | "Configuration" → "Database Configuration" |
| Outdated commands | Verify with current documentation | Check PowerShell cmdlet versions |
| Template API versions | Verify current versions | `@2023-09-01` not `@2020-01-01` |
| Missing template docs | Include comprehensive headers | Parameter types, purposes, examples |
| Inconsistent indentation | Follow language standards | 2 spaces YAML, 4 spaces nested JSON |

### 8.2 Research Validation Checklist

Before providing technical guidance:

- [ ] Consulted official Microsoft Learn documentation
- [ ] Verified current API versions and features
- [ ] Checked for deprecated methods or approaches
- [ ] Validated command syntax against latest docs
- [ ] Tested provided links for accuracy and relevance
- [ ] Confirmed authentication requirements
- [ ] Reviewed for recent UI or process changes

**Template-Specific Validation:**

- [ ] Verified Azure resource API versions in Bicep/ARM templates
- [ ] Validated JSON Schema compliance with current OpenAPI specs
- [ ] Confirmed KQL syntax against Kusto documentation
- [ ] Checked YAML structure against Azure DevOps pipeline schema
- [ ] Tested template parameter validation rules
- [ ] Verified resource naming conventions follow Azure best practices

---

This instruction set ensures all AI assistance maintains the high standards established in the repository's style guides while providing accurate, current, and professionally formatted content across all projects.

---

## 🤖 AI-Assisted Content Generation

This comprehensive AI assistant instructions document was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Azure DevOps pipeline development standards, PowerShell scripting guidelines, and comprehensive template formatting requirements.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Azure development practices while maintaining technical accuracy and reflecting enterprise-grade documentation standards for multi-project technology portfolios.*
