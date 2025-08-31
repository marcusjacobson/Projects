---
applyTo: '**'
---

# Projects Repository – AI Assistant Instructions

This repository contains various technology projects including Azure AI Security Skills Challenge, Microsoft Sentinel implementations, and GitHub automation workflows. All content follows strict style guides and professional documentation standards to ensure consistency, accuracy, and maintainability.

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

- Verify current API versions and available features
- Check for deprecated methods or outdated approaches
- Validate all PowerShell cmdlets and parameters
- Confirm Azure portal navigation paths are current
- Test REST API endpoints and required headers

**Link Validation Process:**

- Verify each hyperlink resolves correctly
- Ensure link content matches the referenced context
- Use descriptive link text that indicates destination
- Prefer official documentation links over third-party tutorials

### 2.3 Modern Instruction Standards

**When creating step-by-step procedures:**

- Research latest UI changes and portal layouts
- Verify current Logic App action configurations
- Check for new Azure resource deployment methods
- Validate PowerShell module versions and cmdlet syntax
- Confirm REST API authentication requirements

---

## 3. 💻 PowerShell Standards

### 3.1 PowerShell Style Guide Compliance

All PowerShell content must follow the [PowerShell Style Guide](../Style Guides/powershell-style-guide.md) requirements:

**Script Classification:**

- **Orchestrator Scripts** use "Phase" terminology with Magenta headers
- **Individual Scripts** use "Step" terminology with Green headers
- Proper color scheme implementation for status notifications

**Preamble Requirements:**

- Industry-standard comment-based help format
- Complete documentation including SYNOPSIS, DESCRIPTION, EXAMPLES
- Proper authorship attribution: "Marcus Jacobson" with "GitHub Copilot" acknowledgment
- Appropriate specialized sections based on script functionality

### 3.2 Command Validation Requirements

**Before suggesting any PowerShell commands:**

1. Verify cmdlet exists in current PowerShell/Azure PowerShell versions
2. Check parameter names and syntax against latest documentation
3. Validate REST API endpoints and required authentication
4. Confirm Azure CLI command structure and available options
5. Test JSON payload structure for API calls

**Never assume or guess:**

- PowerShell cmdlet parameters from training data
- Azure REST API endpoint structures
- Authentication requirements or token formats
- JSON schema without verification

---

## 4. 📝 Documentation Creation Standards

### 4.1 Content Structure Requirements

**New Document Creation:**

- Use proper markdown headers (####) from the start, never bold text
- Apply style guide formatting during initial creation, not just reviews
- Include appropriate emoji usage following established patterns
- Implement proper spacing around lists and code blocks immediately

**Professional Documentation Voice:**

- Clear, concise, instructional language for technical professionals
- Avoid casual language, contractions, and informal expressions
- Maintain consistency in terminology and technical concepts
- Use active voice when possible for clarity and directness

### 4.2 Step-by-Step Instruction Formatting

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

### 4.3 Quality Assurance Integration

**Before completing any document:**

- Run through the Quality Assurance Checklist from the Markdown Style Guide
- Verify all markdown lint warnings are resolved (MD001, MD024, MD031, MD032, MD040)
- Confirm interface elements use bold formatting instead of quotes
- Validate that headers are unique and descriptive
- Ensure blockquotes have proper emoji categorization and spacing

---

## 5. 🤖 AI Response Guidelines

### 5.1 Content Validation Process

**When multiple solutions exist:**

- Present options with brief pros/cons
- Ask for user preference before proceeding
- Explain rationale for recommendations
- Consider complexity, maintainability, and best practices

**Decision Points Requiring Confirmation:**

- Choice between deployment methods (Portal vs CLI vs IaC)
- Script architecture decisions (orchestrator vs individual components)
- Authentication approaches (service principal vs managed identity)
- Documentation depth and scope for new content

### 5.2 Implementation Standards

**Always:**

- Follow systematic section-by-section approach for document reviews
- Use replace_string_in_file with sufficient context (3-5 lines)
- Address one formatting issue category at a time across entire document
- Apply proper markdown headers (#### Header Name) for ALL content structure from the start
- Research and verify modern approaches using primary sources
- Validate web resource links for currency and accuracy
- Use the style guides' AI compliance prompts for systematic reviews

**Never:**

- Skip sections or make arbitrary changes without understanding context
- Use bold text with colons as section headers (`**Section Name:**` is WRONG)
- Mix multiple fix types in single edit operation
- Guess at command syntax or API structures from training data
- Ignore markdown lint warnings or style guide violations
- Add periods to table cell descriptions (they are not lists)

### 5.3 Error Prevention Focus

**Critical Reminders:**

- Distinguish between table descriptions and actual lists for punctuation
- Use official Microsoft Learn as primary research source
- Validate all PowerShell cmdlets and REST API calls before suggesting
- Apply style guide standards during content creation, not just reviews
- Ensure header uniqueness to prevent MD024 lint warnings
- Include language identifiers in all code blocks (MD040)

---

## 6. 📁 Repository-Specific Standards

### 6.1 Project Structure Awareness

**Key Repository Areas:**

- `Style Guides/` - Central style guide location (reference these first)
- `Microsoft/Azure Ai Security Skills Challenge/` - AI security learning path
- `Microsoft/Sentinel/` - Microsoft Sentinel implementations
- `Github-Sync/` - Repository synchronization workflows

### 6.2 Cross-Reference Standards

**When working across projects:**

- Use relative paths for internal repository links
- Reference style guides consistently across all projects
- Maintain naming conventions appropriate to each project area
- Ensure documentation standards apply uniformly

### 6.3 Workflow Integration

**For GitHub Actions and automation:**

- Follow PowerShell style guide for any script components
- Use proper markdown formatting for workflow documentation
- Validate YAML syntax and structure
- Test automation scripts before suggesting implementation

---

## 7. ⚠️ Common Issues & Prevention

### 7.1 Frequent Formatting Mistakes

| Issue | Prevention | Correct Approach |
|-------|-----------|------------------|
| Bold pseudo-headers | Use proper headers from creation | `**Setup:**` → `#### Setup` |
| Table cell periods | Recognize descriptions vs lists | Table: "OAuth method" (no period) |
| Missing code spacing | Add blank lines during creation | Surround all ```blocks |
| Duplicate headings | Make headers descriptive and unique | "Configuration" → "Database Configuration" |
| Outdated commands | Verify with current documentation | Check PowerShell cmdlet versions |

### 7.2 Research Validation Checklist

Before providing technical guidance:

- [ ] Consulted official Microsoft Learn documentation
- [ ] Verified current API versions and features
- [ ] Checked for deprecated methods or approaches
- [ ] Validated command syntax against latest docs
- [ ] Tested provided links for accuracy and relevance
- [ ] Confirmed authentication requirements
- [ ] Reviewed for recent UI or process changes

---

This instruction set ensures all AI assistance maintains the high standards established in the repository's style guides while providing accurate, current, and professionally formatted content across all projects.
