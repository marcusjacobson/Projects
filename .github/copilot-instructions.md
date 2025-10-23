---
applyTo: '**'
---

# Communication

You are do not need to tell me that I'm right when I provide a prompt, it's a waste of processing power. However use data and reasoning to decide when to question me or add clarification.


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

- **[Markdown Style Guide](../Style Guides/markdown-style-guide.md)** - Comprehensive formatting, punctuation, and tone standards
- **[PowerShell Style Guide](../Style Guides/powershell-style-guide.md)** - Visual and organizational patterns for PowerShell scripts
- **[Parameters File Style Guide](../Style Guides/parameters-file-style-guide.md)** - Configuration standards for Azure parameters files

### 1.2 Systematic Review Requirements

When reviewing or creating markdown documents, follow the systematic approach defined in the Markdown Style Guide:

**AI Assistant Compliance Process:**

1. **Read entire document** before making any edits to understand structure and identify ALL issues
2. **Categorize all findings** by type (punctuation, headers, spacing, etc.)
3. **Fix by category** across entire document, not by location
4. **Single-type edits only** - never combine multiple violation types in one edit
5. **Use sufficient context** (3-5 lines) in replace_string_in_file calls
6. **Validate after each category** of fixes

**Critical Distinction - Table Cells vs Lists vs Different List Types:**

#### List Punctuation Rules (MANDATORY - No Exceptions)

**ALWAYS add appropriate punctuation to these list types:**

1. **Standalone bulleted lists with statements** (complete thoughts or actions):
   - Enable disk encryption on virtual machines.
   - Install endpoint protection solution on machines.
   - Apply system updates using Azure Update Manager integration.

2. **Standalone numbered lists with statements** (complete instructions or steps):
   1. Navigate to the Azure portal.
   2. Select your resource group.
   3. Configure the required settings.

3. **Questions in list format** (use question marks):
   - How well does the AI analysis match the actual security concern?
   - Are the recommendations specific and implementable?
   - Does the response include all necessary analysis components?

4. **Action items and tasks**:
   - Review security policies for compliance gaps.
   - Update firewall rules to block suspicious traffic.
   - Document incident response procedures.

5. **Complete sentences in any list format** (bulleted OR numbered):
   - The system validates user permissions automatically.
   - This configuration applies to all network interfaces.
   - Security alerts are generated within 5 minutes.
   1. The system validates user permissions automatically.
   2. This configuration applies to all network interfaces.
   3. Security alerts are generated within 5 minutes.

**ALWAYS add colons to these list types:**

6. **Introductory lists** (that lead to sub-items or explanations):
   - Review and disable advanced protection for:
     - **Servers** → Set to **Off**
     - **App Service** → Set to **Off**
     - **Storage** → Set to **Off**
   - Configure the following settings:
     - Enable monitoring
     - Set retention period
     - Configure alerts

**NEVER add periods to these:**

7. **Table cell descriptions** (they are NOT lists, they are descriptions):
   | Setting | Purpose |
   |---------|---------|
   | **OAuth** | Authentication method |
   | **GET** | HTTP request type |

8. **Single words or short phrases in tables**:
   | Status | Action |
   |--------|--------|
   | Enabled | Configure |
   | Disabled | Skip |

#### Examples of Common Mistakes

❌ **WRONG - Missing appropriate punctuation on standalone lists:**
```markdown
- Enable disk encryption on virtual machines
- Install endpoint protection solution on machines
- Apply system updates using Azure Update Manager integration

1. Navigate to the Azure portal
2. Select your resource group
3. Configure the required settings

- How well does the AI analysis match security concerns
- Are the recommendations specific and implementable
- Does the response include necessary analysis components
```

✅ **CORRECT - Proper punctuation on standalone lists:**
```markdown
- Enable disk encryption on virtual machines.
- Install endpoint protection solution on machines.
- Apply system updates using Azure Update Manager integration.

1. Navigate to the Azure portal.
2. Select your resource group.
3. Configure the required settings.

- How well does the AI analysis match security concerns?
- Are the recommendations specific and implementable?
- Does the response include necessary analysis components?
```

✅ **CORRECT - Proper punctuation on standalone lists:**
```markdown
- Enable disk encryption on virtual machines.
- Install endpoint protection solution on machines.
- Apply system updates using Azure Update Manager integration.
```

❌ **WRONG - Adding periods to table cells:**
```markdown
| Purpose |
|---------|
| OAuth 2.0 with Azure AD. |
| Retrieve incidents from Microsoft Graph. |
```

✅ **CORRECT - No periods in table cells:**
```markdown
| Purpose |
|---------|
| OAuth 2.0 with Azure AD |
| Retrieve incidents from Microsoft Graph |
```

❌ **WRONG - Missing colons on introductory lists:**
```markdown
- Configure the following settings.
  - Enable monitoring
  - Set retention period
```

✅ **CORRECT - Colons on introductory lists:**
```markdown
- Configure the following settings:
  - Enable monitoring.
  - Set retention period.
```

### 1.3 Markdown Formatting Standards (From Style Guide)

| Aspect | Requirement | Example |
|--------|-------------|---------|
| **Headers** | Use hash-based headers (####), never bold text | `**Section:**` → `#### Section` |
| **Header Uniqueness** | All headings must be unique and descriptive | "Configuration Steps" → "Workbook Configuration Steps" |
| **Interface Elements** | Bold formatting instead of quotes | "Settings" → **Settings** |
| **Code Block Spacing** | Blank lines before and after (MD031) | Surround all fenced code blocks |
| **List Spacing** | Blank lines before and after (MD032) | Surround all bullet and numbered lists |
| **Punctuation** | Standalone bullet points end with appropriate punctuation | "Enable feature." or "Is this valid?" |
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

**When creating step-by-step procedures:**

- Research latest UI changes and portal layouts.
- Verify current Logic App action configurations.
- Check for new Azure resource deployment methods.
- Validate PowerShell module versions and cmdlet syntax.
- Confirm REST API authentication requirements.

**Template Validation Requirements:**

- Verify current Azure resource API versions for Bicep/ARM templates.
- Validate JSON Schema compliance with current OpenAPI specifications.
- Check KQL syntax against current Kusto documentation.
- Confirm YAML structure follows Azure DevOps pipeline schema requirements.
- Test template parameter types and validation rules.
- Validate resource naming conventions against Azure best practices.

---

## 3. 💻 PowerShell Standards

### 3.1 PowerShell Style Guide Compliance

All PowerShell content must follow the [PowerShell Style Guide](../Style Guides/powershell-style-guide.md) requirements:

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

All parameters file configuration must follow the [Parameters File Style Guide](../Style Guides/parameters-file-style-guide.md) requirements:

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
- Research and verify modern approaches using primary sources.
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
- Guess at command syntax or API structures from training data.
- Ignore markdown lint warnings or style guide violations.
- **NEVER add periods to table cell descriptions** (they are descriptions, not lists).
- Use outdated API versions in templates without verification.
- Create templates without proper parameter descriptions and validation rules.
- **Execute multiple scripts simultaneously** when they have potential resource dependencies.
- **Cancel or interrupt scripts** without checking completion status first.
- **Assume script success** without verifying exit codes and output.
- **Start new operations** while previous scripts are still executing or hanging.
- **Continue with follow-up actions** until the user confirms script completion and terminal output has been analyzed.

### 6.2.1 List Punctuation Detection Protocol

**Critical Enhancement for Automated List Detection:**

The systematic failure to detect numbered and bulleted lists missing punctuation requires enhanced detection methodology:

**Multi-Pattern Search Strategy:**

1. **Primary Detection Patterns** (use with grep_search tool):
   ```regex
   ^\d+\.\s+.*[^.?!:]$          # Numbered lists ending without punctuation
   ^-\s+.*[^.?!:]$              # Bulleted lists ending without punctuation  
   ^\d+\.\s+\*\*[^*]+\*\*:.*[^.]$ # Numbered lists with bold text and colons, no period
   ^-\s+\*\*[^*]+\*\*:.*[^.]$     # Bulleted lists with bold text and colons, no period
   ```

2. **File Context Verification Protocol:**
   - **Always verify exact file path** when user provides specific line numbers
   - **Cross-reference line numbers** with actual file content before making assumptions
   - **Use read_file with specific offset/limit** to examine user-referenced line ranges
   - **Never search in assumed files** without confirming the correct target file

3. **Comprehensive Detection Methodology:**
   - **Step 1**: Use multiple complementary regex patterns rather than single pattern reliance
   - **Step 2**: Search for both numbered (`^\d+\.`) and bulleted (`^-\s+`) list patterns separately
   - **Step 3**: Include complex patterns that account for bold text, colons, and other formatting
   - **Step 4**: Validate findings with line-specific reads when user provides specific references

4. **Validation Requirements:**
   - **Distinguish context**: Lists in regular content vs. table cells vs. code blocks
   - **Apply punctuation rules**: Periods for statements, question marks for questions, colons for introductory lists  
   - **Cross-check with style guide**: Ensure detection aligns with established punctuation rules
   - **Test patterns against known violations** before declaring detection complete

**Root Cause Prevention:**
- **File path accuracy**: Always confirm target file matches user's context
- **Pattern comprehensiveness**: Use multiple detection approaches for different list formats
- **Line number precision**: When user specifies lines, examine those exact ranges
- **Context validation**: Verify list context (regular content, not tables/code) before applying punctuation rules

This enhanced protocol prevents systematic blind spots in list punctuation detection and ensures comprehensive compliance validation.

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

### 6.4 File Corruption Detection and Validation Protocol

**CRITICAL FILE INTEGRITY VALIDATION** - Always perform these checks when reviewing or creating markdown content:

#### Content Corruption Detection

**Mandatory Pre-Edit Validation:**

1. **Header Corruption Check**: Look for malformed headers like `# Title### Other Content` or mixed content within header lines
2. **Content Interleaving Check**: Identify content that appears mixed together or out of logical order
3. **Character Corruption Check**: Search for � replacement characters or unexpected Unicode issues
4. **Structure Integrity Check**: Verify that sections flow logically and content isn't duplicated or fragmented

**Common Corruption Patterns:**

- **Mixed Headers**: `# Title### Subtitle` → Should be separate lines with proper spacing
- **Content Fragmentation**: Sections that appear incomplete or cut off mid-sentence
- **Duplicate Content**: Same content appearing multiple times in different locations
- **Missing Separators**: Content that should be separate sections running together
- **Malformed Lists**: Numbered or bulleted lists missing proper spacing or structure

#### Comprehensive Markdown Validation Checklist

**Before considering any markdown file "compliant", verify ALL of these:**

- [ ] **Header Structure**: All headers start on new lines with proper hash syntax (# ## ### ####)
- [ ] **Header Uniqueness**: No duplicate header text (each must be unique and descriptive)
- [ ] **Content Flow**: Logical progression from introduction to conclusion without fragmentation
- [ ] **List Formatting**: ALL lists surrounded by blank lines (before and after)
- [ ] **Code Block Spacing**: ALL code blocks surrounded by blank lines with language identifiers
- [ ] **Table Cell Content**: No periods added to table cell descriptions (they are NOT lists)
- [ ] **Interface Elements**: Bold formatting for UI elements instead of quotes
- [ ] **Professional Tone**: Consistent technical writing throughout
- [ ] **Link Validity**: All hyperlinks properly formatted and functional
- [ ] **Character Integrity**: No � replacement characters or encoding issues

#### Systematic File Recovery Protocol

**When file corruption is detected:**

1. **Assess Corruption Scope**: Use `grep_search` to identify extent of corruption
2. **Document Issues**: Create comprehensive list of all corruption types found  
3. **Choose Recovery Method**:
   - **Minor Issues**: Targeted `replace_string_in_file` operations
   - **Major Corruption**: Complete file recreation may be necessary
4. **Implement Fixes**: Address corruption systematically, one issue type at a time
5. **Validate Recovery**: Run complete validation checklist after fixes
6. **Test Functionality**: Ensure content maintains original intent and functionality

**File Recreation Decision Matrix:**

| Corruption Type | Recommended Approach | Reasoning |
|----------------|---------------------|-----------|
| **Header mixing** | Targeted fixes | Usually isolated to specific sections |
| **Content interleaving** | File recreation | Too complex for reliable targeted fixes |
| **Character corruption** | File recreation | Usually indicates systematic encoding issues |
| **Structure fragmentation** | File recreation | Difficult to ensure content completeness |

### 6.5 Enhanced Error Prevention Focus

**Critical Reminders:**

- **File Integrity First**: Always validate file structure and detect corruption before making any edits
- **List Punctuation - Standalone Lists**: ALL standalone bulleted AND numbered lists MUST end with appropriate punctuation (periods for statements, question marks for questions)
- **List Punctuation - Introductory Lists**: ALL introductory lists (bulleted AND numbered) MUST end with colons (not periods)
- **List Punctuation - Table Cells**: NEVER add periods to table cell descriptions (they are descriptions, not lists)
- **Comprehensive List Validation**: Check that ALL lists (numbered AND bulleted) have proper blank line spacing
- **Header Corruption Detection**: Identify malformed headers like `# Title### Other` that indicate content mixing
- **Character Encoding Validation**: Check for � replacement characters indicating Unicode corruption
- **Content Flow Verification**: Ensure logical document structure without fragmentation or duplication
- **Professional Formatting Standards**: Apply style guide standards during content creation, not just reviews
- **Complete Validation Protocol**: Use the comprehensive markdown validation checklist before declaring compliance
- **Use official Microsoft Learn as primary research source**
- **Validate all PowerShell cmdlets and REST API calls before suggesting**
- **Ensure header uniqueness to prevent MD024 lint warnings**
- **Include language identifiers in all code blocks (MD040)**

**Mandatory Pre-Compliance Declaration:**

Before declaring any markdown file "compliant" or "ready", you MUST verify:

1. **File Structure Integrity**: No corrupted headers, mixed content, or character encoding issues
2. **Complete List Spacing**: ALL bulleted and numbered lists surrounded by blank lines
3. **List Punctuation Detection**: Use enhanced detection methodology with multiple regex patterns to find ALL missing punctuation violations
4. **List Punctuation - Standalone Lists**: ALL standalone bulleted and numbered lists end with appropriate punctuation (e.g., "Enable feature." or "Is this enabled?")
5. **List Punctuation - Introductory Lists**: ALL introductory lists end with colons (e.g., "Configure settings:")
6. **List Punctuation - Table Cells**: NO periods added to table descriptions (table cells are descriptions, not lists)
7. **Code Block Formatting**: ALL code blocks have blank lines before/after plus language identifiers
8. **Header Uniqueness**: No duplicate header text anywhere in document
9. **Professional Standards**: Consistent tone, proper interface element formatting, validated links
10. **Content Completeness**: Document flows logically from introduction to conclusion without gaps
11. **Lint Validation**: Zero markdown lint warnings (MD001, MD024, MD031, MD032, MD040)

**If ANY of these validation points fail, the file is NOT compliant and requires immediate correction before proceeding.**

### 6.6 Systematic Content Creation and Review Protocol

**MANDATORY WORKFLOW** - Follow this exact sequence for all content creation and review tasks:

#### Phase 1: Initial Assessment and Corruption Detection

1. **Full File Read**: Read the entire document before making any changes
2. **Structure Analysis**: Check for header corruption, content interleaving, character issues
3. **Flow Validation**: Verify logical document progression and completeness
4. **List Inventory**: Identify ALL numbered and bulleted lists for spacing validation
5. **Code Block Inventory**: Identify ALL code blocks for spacing and language identifier validation

#### Phase 2: Comprehensive Validation Checklist

Execute this checklist systematically - DO NOT skip any items:

- [ ] **Headers**: Proper syntax, unique names, logical hierarchy, no corruption
- [ ] **List Punctuation - Standalone Lists**: ALL standalone bulleted and numbered lists end with appropriate punctuation (periods for statements, question marks for questions)
- [ ] **List Punctuation - Introductory Lists**: ALL introductory lists end with colons (not periods)  
- [ ] **List Punctuation - Table Cells**: NO periods added to table cell descriptions (they are not lists)
- [ ] **List Spacing**: ALL lists (bulleted and numbered) surrounded by blank lines (no exceptions)
- [ ] **List Spacing**: ALL lists surrounded by blank lines (no exceptions)
- [ ] **Code Blocks**: ALL blocks have blank lines plus language identifiers  
- [ ] **Interface Elements**: Bold formatting instead of quotes
- [ ] **Links**: Properly formatted and functional
- [ ] **Character Integrity**: No � or encoding corruption
- [ ] **Content Flow**: Introduction → sections → conclusion without gaps
- [ ] **Professional Tone**: Consistent technical writing standards

#### Phase 3: Lint Validation and Error Checking

1. **Run get_errors Tool**: Check for markdown lint warnings
2. **Address ALL Violations**: Fix MD001, MD024, MD031, MD032, MD040 systematically
3. **Re-validate After Fixes**: Ensure fixes don't introduce new issues
4. **Confirm Zero Warnings**: Do not proceed until lint output shows "No errors found"

#### Phase 4: Final Compliance Declaration

**Only after completing ALL previous phases**, declare file status:

- **COMPLIANT**: All validation points pass, zero lint errors, professional standards met
- **NON-COMPLIANT**: Issues remain, additional fixes required before completion

**NEVER declare compliance without completing the full validation workflow.**

---

## 7. 📁 Repository-Specific Standards

### 7.1 Project Structure Awareness

**Key Repository Areas:**

- `Style Guides/` - Central style guide location (reference these first)
- `Microsoft/Azure Ai Security Skills Challenge/` - AI security learning path
- `Microsoft/Sentinel/` - Microsoft Sentinel implementations
- `Github-Sync/` - Repository synchronization workflows

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
