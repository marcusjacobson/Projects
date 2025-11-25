# Markdown Style Guide for Azure AI Security Skills Challenge

This style guide defines the formatting, punctuation, and tone standards for all markdown documentation within the Azure AI Security Skills Challenge project. It ensures consistency, professionalism, and clarity across all technical documentation.

## 📋 General Principles

### Professional Documentation Voice

- Use clear, concise, and professional language throughout all documentation.
- Write in an instructional tone suitable for technical professionals.
- Avoid casual language, contractions, and informal expressions.
- Maintain consistency in terminology and technical concepts.
- Use active voice when possible for clarity and directness.

### Accessibility and Clarity

- Write for a technical audience with basic understanding of Azure and security concepts.
- Provide sufficient context and explanation for complex procedures.
- Use descriptive headings that clearly indicate content purpose.
- Structure content logically with clear progression from simple to complex topics.

---

## 🎯 Punctuation Rules

### Bullet Points

- **Standalone bullet points must end with periods.**
- **Introductory bullet points that lead to sub-lists must end with colons.**
- This applies to all list items, maintaining logical punctuation based on their function.
- Use consistent bullet point formatting throughout the document.

### Table Cell Descriptions vs. Bullet Point Lists

**Critical Distinction**: Table cell descriptions are NOT bullet point lists and should NOT have periods added to them.

#### Table Cell Descriptions (NO Periods)

Table cells contain descriptions, explanations, or values - they are NOT standalone statements requiring periods:

| Setting | Value | Purpose |
|---------|-------|---------|
| **Authentication type** | **Active Directory OAuth** | OAuth 2.0 with Azure AD |
| **Method** | `GET` | Retrieve incidents from Microsoft Graph |
| **Plan Type** | **Consumption** | Cost-effective pay-per-execution |

#### Actual Bullet Point Lists (Periods Required)

These are true bulleted lists that require periods:

- Enable disk encryption on virtual machines.
- Install endpoint protection solution on machines.
- Apply system updates using Azure Update Manager integration.

#### Common Mistake to Avoid

❌ **Incorrect**: Adding periods to table cell descriptions

```markdown
| Purpose |
|---------|
| OAuth 2.0 with Azure AD. |
| Retrieve incidents from Microsoft Graph. |
```

✅ **Correct**: Table cell descriptions without periods

```markdown
| Purpose |
|---------|
| OAuth 2.0 with Azure AD |
| Retrieve incidents from Microsoft Graph |
```

#### Standalone Bullet Points (End with Periods)

Use periods when bullet points are complete, standalone actions or statements:

- Enable disk encryption on virtual machines.
- Install endpoint protection solution on machines.
- Apply system updates using Azure Update Manager integration.

#### Introductory Bullet Points (End with Colons)

Use colons when bullet points introduce or lead to sub-lists:

- Review and disable advanced protection for:
  - **Servers** → Set to **Off**.
  - **App Service** → Set to **Off**.
  - **Storage** → Set to **Off**.
- Configure the following settings:
  - Enable monitoring.
  - Set retention period.
  - Configure alerts.

#### Incorrect Examples

- Enable disk encryption on virtual machines
- Install endpoint protection solution on machines
- Review and disable advanced protection for.
  - **Servers** → Set to **Off**.
  - **App Service** → Set to **Off**.

### Sentences and Paragraphs

- All sentences must end with appropriate punctuation (periods, question marks, exclamation points).
- Use periods for declarative statements and instructions.
- Use question marks for rhetorical questions or user prompts.
- Avoid excessive exclamation points; use sparingly for emphasis.

### Code and Interface Elements

- Use backticks for single words, commands, or short code snippets: `command`.
- Use code blocks for multi-line code or extended commands.
- Use periods after sentences that contain inline code elements.

### Blockquote Usage

- **Use blockquotes for callouts, alerts, and highlighted information** that requires special attention from readers.
- **Blockquotes must be surrounded by blank lines** to ensure proper rendering and avoid MD032 lint warnings.
- **Use emoji indicators** to categorize different types of blockquotes for visual clarity and quick recognition.

#### Blockquote Categories and Appropriate Usage

**Security Notices and Warnings** (Use ⚠️ or 🚨):

- Security-related warnings and important operational considerations
- Permission scope explanations and access control information
- Production vs. lab environment distinctions

**Tips and Best Practices** (Use 💡, ✅, or 🔧):

- Helpful guidance and professional recommendations
- Technical explanations and "why" information
- Best practice recommendations and production tips

**Important Notes and Considerations** (Use 🔒, 🏢, or 📚):

- Critical information that affects decision-making
- Cost considerations and operational impact information
- Additional learning resources and documentation links

**Results and Outcomes** (Use 🎯, 🎉):

- Expected results from procedures
- Success indicators and validation points
- Achievement summaries and accomplishments

#### Blockquote Formatting Standards

**Single-Line Blockquotes:**

```markdown
> **💡 Production Tip**: Start with high-severity incidents only, then expand to medium/low severity as you validate the system works reliably.
```

**Multi-Line Blockquotes with Lists:**

```markdown
> **⚠️ Security Notice - Write Permissions**: The `ReadWrite.All` permissions grant significant access to modify security incidents and alerts. This allows the Logic App to add comments, update incident properties, and modify alert classifications. Only grant these permissions in trusted environments and ensure proper app registration security:
>
> • **Application Scope**: These permissions apply to all security incidents/alerts in your tenant
> • **Audit Trail**: All changes made by the app registration are logged and auditable
> • **Principle of Least Privilege**: Consider using `Read.All` permissions initially, then upgrade to `ReadWrite.All` only when write operations are needed
```

**Multi-Paragraph Blockquotes:**

```markdown
> **🚨 Microsoft Graph API Limitation**: While incidents have a `comments` property in their schema, **there is no functional API endpoint to POST comments directly to incidents**. The `/comments` endpoint for incidents either doesn't exist or returns errors consistently.
>
> **🎯 Working Solution**: Add comments to individual **alerts** within the incident. Alert comments work reliably and appear in the Defender XDR portal.
>
> **📱 UI vs API Limitation**: Even in the Defender XDR web interface, incident comments are limited and primarily appear in the Activity Log. Alert comments provide better visibility and programmatic access.
```

#### Blockquote Best Practices

**Spacing Requirements:**

- Always include blank lines before and after blockquotes
- Use `>` followed by a space for all blockquote lines
- Include `>` on empty lines within multi-paragraph blockquotes

**Content Guidelines:**

- Start with a bold emoji-prefixed label for categorization
- Use professional, instructional tone consistent with document standards
- Include actionable information and specific guidance
- Limit blockquote length to maintain readability (typically 3-5 sentences per section)

**When to Use Blockquotes vs. Regular Text:**

- **Use blockquotes for**: Warnings, tips, important notes, special considerations, and highlighted information that requires reader attention
- **Use regular text for**: Step-by-step instructions, configuration details, standard explanations, and general procedural content

**Common Blockquote Anti-Patterns to Avoid:**

```markdown
❌ Incorrect (no spacing):
Regular text here.
> **Tip**: This is a blockquote.
More regular text.

❌ Incorrect (inconsistent emoji usage):
> This is important information without proper categorization.

❌ Incorrect (too long and unfocused):
> This blockquote contains multiple unrelated pieces of information that should be broken into separate callouts or moved to regular text for better readability and organization.

✅ Correct (proper spacing and categorization):
Regular text here.

> **💡 Production Tip**: This is a focused, well-categorized blockquote with proper spacing.

More regular text here.
```

---

## 🔤 Formatting Standards

### Bold Text for Interface Elements

- **Bold all quoted targets instead of using quotation marks.**
- This includes button text, menu items, field names, resource names, and UI elements.
- Bold formatting provides better visual hierarchy and modern documentation standards.

#### Correct Formatting Examples

- Click **Create** to proceed with deployment.
- Navigate to **Environment settings** in the left menu.
- Set the **Virtual machine name** to **vm-windows-server**.
- Toggle the status to **On** for enhanced protection.

#### Incorrect Formatting Examples

- Click "Create" to proceed with deployment.
- Navigate to "Environment settings" in the left menu.
- Set the "Virtual machine name" to "vm-windows-server".
- Toggle the status to "On" for enhanced protection.

### Headers and Structure

- **Use hash-based headers (#, ##, ###) instead of bold text for section titles.**
- **Avoid using bold text followed by colons as section headers** - convert these to proper hash-based headers.
- **Make header text unique to avoid duplicate heading lint warnings** - use descriptive, specific titles.
- Use consistent header hierarchy (H1, H2, H3, etc.) to create proper document structure.
- Include appropriate emoji icons for main sections when enhancing readability.
- Use descriptive headers that clearly indicate section content.
- Maintain logical content flow from general to specific information.
- Reserve bold text for interface elements, resource names, and emphasis within content.

#### Common Bold Text Header Issues to Avoid

These patterns should be converted to proper headers:

```markdown
❌ Incorrect (Bold text acting as headers):
**Configuration Steps:**
**Verification Steps:** 
**Expected Results:**
**Important Notes:**
**Cost Monitoring:**
**What Gets Removed:**

✅ Correct (Proper hash-based headers):
#### Configuration Steps
#### Verification Steps  
#### Expected Results
#### Important Notes
#### Cost Monitoring
#### What Gets Removed
```

#### Header Uniqueness Requirements

Avoid duplicate headers by making them specific:

```markdown
❌ Incorrect (Duplicate headers):
#### Configuration Steps (appears multiple times)
#### Verification Steps (appears multiple times)

✅ Correct (Unique descriptive headers):
#### Workbook Configuration Steps
#### Sentinel Connector Configuration Steps
#### Defender XDR Verification Steps
#### Sentinel Verification Steps
```

#### Correct Header Examples

```markdown
# Main Document Title
## Major Section Title
### Subsection Title
#### Detailed Topic Title
```

#### Incorrect Header Examples

```markdown
**Major Section Title**
**Subsection Title**
**Detailed Topic Title**
```

#### When to Use Bold vs Headers

- **Use Headers For**: Document structure, section titles, step titles, topic organization, any text that serves as a section divider or organizer.
- **Use Bold For**: Interface elements, button names, field names, resource names, emphasis within content, subsection labels within paragraphs.

#### Bold Text vs Header Decision Matrix

| Content Type | Formatting | Example |
|--------------|------------|---------|
| Section divider | Header (####) | `#### Configuration Steps` |
| Subsection within content | Bold | `**Configuration Steps:** Follow these procedures...` |
| Interface element | Bold | `Click **Save** to proceed` |
| Resource name | Bold | `Navigate to **Resource Group**` |
| Standalone section | Header (####) | `#### Expected Results` |
| Timeline/status info | Header (####) | `#### Defender XDR Timeline` |

### Code Block Formatting

- Use appropriate language identifiers for syntax highlighting.
- **Ensure code blocks are surrounded by blank lines** to avoid MD031 lint warnings.
- Include clear explanations before and after code blocks.
- Use consistent indentation and formatting within code blocks.
- Add comments to complex code examples for clarity.

#### Correct Code Block Formatting

Use proper spacing and language identifiers:

```text
✅ Correct format:
Text before code block.

```powershell
# PowerShell command example
Get-AzResourceGroup
```

Text after code block.

❌ Incorrect format:
Text before code block.

```powershell
# PowerShell command example  
Get-AzResourceGroup
```

Text after code block.

```text
# Example without proper formatting
```

### List Formatting

- **Ensure lists are surrounded by blank lines** to avoid MD032 lint warnings.
- Use consistent list formatting throughout documents.
- Maintain proper indentation for nested lists.
- Follow punctuation rules for list items (periods for standalone, colons for introductory).
- **For step-by-step instructions, use bullet points with paragraph breaks between logical groupings for enhanced readability.**

#### Correct List Formatting

```markdown
✅ Correct (surrounded by blank lines):
Text before list.

- First list item.
- Second list item.
- Third list item.

Text after list.

❌ Incorrect (no blank lines):
Text before list.
- First list item.
- Second list item.
Text after list.
```

#### Step-by-Step Instruction Formatting

**Bullet Point Steps with Logical Groupings** (Required format for all procedures)

```markdown
- Go to [portal.azure.com](https://portal.azure.com) and sign in.
- Navigate to **Resource Groups** in the left menu.
  - This opens the resource group management interface.
- Click **+ Create** to start the creation process.
- Enter the required information.
```

Navigate to your newly created resource group.

- Verify the resource group appears in the list.
- Check that all settings are configured correctly.
- Test access to ensure proper permissions.

```markdown
```

**Key Benefits of Bullet/Paragraph Format:**


- **Enhanced Readability**: Logical groupings with paragraph breaks improve scanning and comprehension.
- **Flexible Structure**: Accommodates complex procedures with multiple phases or contexts.
- **Natural Flow**: Paragraph breaks between sections create natural reading rhythm.
- **Accessibility**: Easier to follow for users with different learning preferences.
- **Modern Documentation Style**: Aligns with current technical writing best practices.

### Links and References

- Use descriptive link text that indicates destination content.
- Include screenshot references with clear descriptions.
- Format external links with full URLs when appropriate.
- Use consistent link formatting throughout documents.

---

## 📖 Content Structure Standards

### Prerequisites Sections

- List all requirements clearly with bullet points ending in periods.
- Include access level requirements and technical prerequisites.
- Specify knowledge level expectations for readers.
- Provide links to foundational concepts when necessary.

### Step-by-Step Instructions

- Use numbered lists for sequential procedures.
- Include clear action-oriented headings for each step.
- Provide expected results and validation steps.
- Include troubleshooting guidance for common issues.

### Configuration Sections

- Use consistent subheading structure for configuration options.
- Explain the purpose and benefits of each configuration.
- Include recommended settings for different scenarios.
- Provide clear before/after state descriptions.

### Screenshots and Visual References

- Include screenshot references with descriptive text.
- Use consistent screenshot reference formatting.
- Provide alternative text descriptions for accessibility.
- Link to official Microsoft documentation when appropriate.

---

## 🛠️ Technical Writing Standards

### Azure Resource Names

- Use consistent naming conventions for resources.
- Bold resource names when they appear in instructions.
- Use descriptive names that indicate resource purpose.
- Follow Azure naming best practices and conventions.

### Version and Date References

- Include version information for software and services.
- Reference current year in documentation titles when relevant.
- Update version references when content is revised.
- Use "2025 Edition" or similar indicators for current standards.

### Terminology Consistency

- Use official Microsoft product names consistently.
- Maintain consistent terminology throughout documents.
- Define acronyms and abbreviations on first use.
- Use glossaries for complex technical concepts when needed.

### Integration and Cross-References

- Provide clear cross-references between related sections.
- Link to relevant Microsoft Learn documentation.
- Include references to prerequisite knowledge or procedures.
- Maintain consistent cross-reference formatting.

---

## ✅ Quality Assurance Checklist

When reviewing any markdown document, verify:

### Core Formatting Standards

- [ ] **Punctuation - Lists**: Standalone bullet points end with periods, introductory ones with colons
- [ ] **Punctuation - Tables**: Table cell descriptions do NOT have periods added (they are descriptions, not lists)
- [ ] **Headers**: Hash-based headers (####) instead of bold text, unique descriptive names
- [ ] **Interface Elements**: Bold formatting instead of quotes for UI elements
- [ ] **Code Blocks**: Surrounded by blank lines with language identifiers
- [ ] **Lists**: Surrounded by blank lines with proper punctuation
- [ ] **Blockquotes**: Proper emoji categorization, surrounded by blank lines, appropriate usage for callouts/warnings

### Document Structure

- [ ] **Header Hierarchy**: Proper progression (##, ###, ####) without skipping levels
- [ ] **Professional Tone**: Clear, instructional language for technical audience
- [ ] **Content Flow**: Logical progression from simple to complex topics
- [ ] **Cross-References**: Valid links and consistent formatting

### Technical Standards

- [ ] **Azure Resources**: Consistent naming conventions, bold when referenced
- [ ] **Terminology**: Official Microsoft product names, defined acronyms
- [ ] **Accessibility**: Descriptive headings, alternative text for visuals

### Markdown Lint Compliance

- [ ] **MD001**: Header levels increment by one only
- [ ] **MD024**: No duplicate headings (unique names required)
- [ ] **MD031**: Code blocks surrounded by blank lines
- [ ] **MD032**: Lists surrounded by blank lines  
- [ ] **MD040**: Code blocks have language specified

---

## 🔍 Quick Reference Guide

### Most Common Formatting Issues

1. **Bold text with colons acting as headers** → Convert to proper hash headers (####)
2. **Duplicate header names** → Make headers unique and descriptive
3. **Missing blank lines around code blocks/lists** → Add blank lines before and after
4. **Interface elements in quotes** → Use bold formatting instead
5. **Inconsistent header hierarchy** → Follow proper progression (##, ###, ####)
6. **Blockquotes without proper spacing or categorization** → Add blank lines and emoji indicators
7. **Adding periods to table cell descriptions** → Table descriptions are NOT lists, do not add periods

### Essential Patterns to Remember

```text
✅ Correct patterns:

#### Unique Descriptive Header

- List item with period.
- Introductory item with colon:
  - Sub-item details.

Click **Button Name** to proceed.

| Setting | Purpose |
|---------|---------|
| **OAuth** | Authentication method |
| **GET** | HTTP request type |

```powershell
# Code with blank lines before and after
Get-AzResource
```

> **💡 Production Tip**: This is a properly formatted blockquote with emoji categorization.

❌ Avoid these patterns:

**Header Text:**

- List item without period
- Click "Button Name" to proceed

| Setting | Purpose |
|---------|---------|
| **OAuth** | Authentication method. |
| **GET** | HTTP request type. |

Code without proper spacing or language ID

```text
# Example without proper formatting
```

---

## 🎯 Implementation Guidelines

### For New Documents

- Start with this style guide as the foundation for all new markdown documentation.
- Review each section against the quality assurance checklist before publication.
- Ensure consistent application of all formatting and punctuation rules.

### For Existing Documents

- Perform systematic section-by-section reviews using this guide.
- Apply fixes using the replace_string_in_file methodology for precision.
- Focus on one style guide element at a time (punctuation, then formatting, then content tone).
- Validate changes against the quality assurance checklist.

### For Review Processes

- Use this guide as the primary reference for copy editing tasks.
- Implement changes systematically rather than skipping around documents.
- Ensure complete document coverage by reviewing from beginning to end.
- Apply sufficient context when making edits to ensure accuracy.

---

## 🤖 AI-Assisted Content Generation Requirements

All comprehensive markdown documentation must include an AI-assisted content generation section at the end of the document to maintain transparency and provide attribution for AI assistance used in content creation.

### Required Section Format

```markdown
## 🤖 AI-Assisted Content Generation

This [document type] was [created/updated] with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, [specific context about the content or technical aspects covered].

*AI tools were used to enhance productivity and ensure comprehensive coverage of [specific domain or topic] while maintaining technical accuracy and reflecting [relevant standards or best practices].*
```

### Implementation Guidelines

- **Placement**: Always place this section at the end of the document, before any final notes or disclaimers.
- **Customization**: Adapt the template content to reflect the specific document type, technical domain, and scope of AI assistance.
- **Consistency**: Use the same emoji (🤖) and header format across all documents.
- **Attribution**: Always mention **GitHub Copilot** and **Visual Studio Code** as the primary AI tools used.

### Examples of Proper Implementation

#### For Technical Deployment Guides

```markdown
This comprehensive deployment guide was updated for 2025 with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Defender for Cloud architecture changes, MMA deprecation, and modern agentless capabilities.
```

#### For Infrastructure-as-Code Documentation

```markdown
This comprehensive modular Infrastructure-as-Code deployment guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, Bicep templates, and Infrastructure-as-Code architecture were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.
```

#### For Decommissioning Guides

```markdown
This comprehensive decommissioning guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, leveraging GitHub Copilot's capabilities to ensure accuracy, completeness, and adherence to Microsoft Azure best practices.
```

### Documents Requiring AI-Assisted Content Generation Sections

- **All comprehensive guides** (deployment, configuration, decommissioning)
- **Technical documentation** longer than 500 lines
- **Tutorial and step-by-step content**
- **Reference documentation** with substantial AI-generated content
- **Any document where AI assistance significantly contributed to content creation**

### Documents That May Exclude This Section

- **Simple README files** with basic project descriptions
- **Template files** and boilerplate content
- **Brief technical notes** under 100 lines
- **Configuration files** and data-only content

---

## 📚 Additional Resources

- **Microsoft Learn Documentation**: [docs.microsoft.com](https://docs.microsoft.com)
- **Azure Naming Conventions**: [Azure resource naming best practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- **Markdown Syntax Guide**: [GitHub Markdown Guide](https://guides.github.com/features/mastering-markdown/)
- **Technical Writing Best Practices**: [Microsoft Writing Style Guide](https://learn.microsoft.com/en-us/style-guide/welcome/)

---

## 🤖 AI Assistant Compliance Prompt

Use this prompt when you want to ensure a markdown file is fully compliant with this style guide:

```text
Please review this markdown document for compliance with the Azure AI Security Skills Challenge markdown style guide. Follow this systematic methodology:

## PHASE 1: COMPREHENSIVE ANALYSIS BEFORE EDITING

1. **Full Document Scan**: Read through the ENTIRE document first to understand structure and identify ALL issues before making any edits. Create a comprehensive issue inventory categorized by type.

2. **Issue Classification**: Categorize ALL findings into these specific types:
   
   **A. PUNCTUATION VIOLATIONS:**
   - Standalone bullet points missing periods (should end with ".")
   - Introductory bullet points missing colons (should end with ":")
   - Lists within blockquotes missing periods
   - NOTE: Table cell descriptions are NOT lists - do not add periods to table cells
   
   **B. HEADER FORMATTING VIOLATIONS:**
   - Bold text acting as section headers (convert to proper hash headers)
   - Bold text followed by colons that should be headers
   - Duplicate header names (make unique and descriptive)
   - Incorrect header hierarchy (MD001 violations)
   
   **C. INTERFACE ELEMENT VIOLATIONS:**
   - Interface elements in quotes instead of bold formatting
   - Resource names not properly bolded
   
   **D. SPACING AND STRUCTURE VIOLATIONS:**
   - Code blocks not surrounded by blank lines (MD031)
   - Lists not surrounded by blank lines (MD032)
   - Blockquotes improperly spaced or categorized
   
   **E. CONTENT STRUCTURE VIOLATIONS:**
   - Missing language identifiers in code blocks (MD040)
   - Inconsistent step-by-step formatting
   - Improper blockquote usage or categorization

3. **Critical Distinction - Table Cells vs Lists**: 
   - **NEVER add periods to table cell descriptions** - they are descriptions, not standalone bullet points
   - **DO add periods to actual bulleted lists** outside of tables
   - **Example CORRECT**: Table cell: "OAuth 2.0 with Azure AD" (no period)
   - **Example CORRECT**: List item: "Enable authentication for security." (with period)

## PHASE 2: SYSTEMATIC CORRECTION BY CATEGORY

4. **Fix by Category, Not by Location**: Address all issues of ONE type across the entire document before moving to the next type:
   
   **Step A: Fix ALL punctuation violations**
   - Find all standalone bullet point lists and add periods
   - Find all introductory bullet point lists and ensure colons
   - Fix lists within blockquotes
   - SKIP table cell descriptions completely
   
   **Step B: Fix ALL header violations**
   - Convert bold text headers to proper hash headers
   - Make duplicate headers unique
   - Fix header hierarchy issues
   
   **Step C: Fix ALL interface element violations**
   - Convert quoted interface elements to bold
   - Bold resource names consistently
   
   **Step D: Fix ALL spacing violations**
   - Add blank lines around code blocks
   - Add blank lines around lists
   - Fix blockquote spacing
   
   **Step E: Fix ALL structure violations**
   - Add language identifiers to code blocks
   - Standardize step-by-step formatting
   - Improve blockquote categorization

5. **Single-Type Edits Only**: Make only ONE type of edit per replace_string_in_file call. Never combine multiple violation types in a single edit.

## PHASE 3: VALIDATION AND QUALITY ASSURANCE

6. **Comprehensive Validation**: After each category of fixes:
   - Run get_errors tool to check for new lint warnings
   - Verify changes didn't introduce new issues
   - Confirm the specific violation type is fully resolved

7. **Final Quality Check**: Use the Quality Assurance Checklist:
   - [ ] Standalone bullet points end with periods
   - [ ] Introductory bullet points end with colons  
   - [ ] Lists within blockquotes have proper punctuation
   - [ ] Table cell descriptions remain unchanged (no periods added)
   - [ ] Bold text headers converted to hash headers
   - [ ] Headers are unique and descriptive
   - [ ] Interface elements are bolded, not quoted
   - [ ] Code blocks surrounded by blank lines with language identifiers
   - [ ] Lists surrounded by blank lines
   - [ ] Blockquotes properly spaced and categorized
   - [ ] Zero markdown lint warnings (MD001, MD024, MD031, MD032, MD040)

## CRITICAL RULES TO PREVENT COMMON MISTAKES:

**❌ NEVER DO:**
- Add periods to table cell descriptions
- Mix multiple violation types in one edit
- Skip the comprehensive analysis phase
- Make assumptions about document structure

**✅ ALWAYS DO:**
- Read entire document before editing
- Categorize ALL issues before fixing ANY issues
- Fix one violation type at a time across entire document  
- Distinguish between table descriptions and actual lists
- Use sufficient context (3-5 lines) in replace_string_in_file calls
- Validate after each category of fixes

## SYSTEMATIC IMPLEMENTATION:

1. Read entire document and create issue inventory by category
2. Report comprehensive findings to user before making any edits
3. Fix all punctuation issues across entire document
4. Fix all header issues across entire document  
5. Fix all interface element issues across entire document
6. Fix all spacing issues across entire document
7. Fix all structure issues across entire document
8. Run final validation and quality assurance checklist
9. Report completion with summary of all changes made

This methodology ensures systematic, comprehensive compliance while preventing common mistakes like treating table descriptions as lists or making partial fixes that require multiple iterations.
```

---

*This style guide is a living document that should be updated as project standards evolve and new formatting requirements are identified.*
