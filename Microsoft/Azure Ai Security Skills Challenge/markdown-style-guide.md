# Markdown Style Guide for Azure AI Security Skills Challenge

This style guide defines the formatting, punctuation, and tone standards for all markdown documentation within the Azure AI Security Skills Challenge project. It ensures consistency, professionalism, and clarity across all technical documentation.

## 📋 General Principles

### Professional Technical Documentation Voice

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
```

### List Formatting

- **Ensure lists are surrounded by blank lines** to avoid MD032 lint warnings.
- Use consistent list formatting throughout documents.
- Maintain proper indentation for nested lists.
- Follow punctuation rules for list items (periods for standalone, colons for introductory).

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

- [ ] **Punctuation**: Standalone bullet points end with periods, introductory ones with colons
- [ ] **Headers**: Hash-based headers (####) instead of bold text, unique descriptive names
- [ ] **Interface Elements**: Bold formatting instead of quotes for UI elements
- [ ] **Code Blocks**: Surrounded by blank lines with language identifiers
- [ ] **Lists**: Surrounded by blank lines with proper punctuation

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

### Essential Patterns to Remember

```text
✅ Correct patterns:

#### Unique Descriptive Header

- List item with period.
- Introductory item with colon:
  - Sub-item details.

Click **Button Name** to proceed.

```powershell
# Code with blank lines before and after
Get-AzResource
```

❌ Avoid these patterns:

**Header Text:**

- List item without period
- Click "Button Name" to proceed

Code without proper spacing or language ID
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
Please review this markdown document for compliance with the Azure AI Security Skills Challenge markdown style guide. Follow these requirements:

1. **Systematic Section-by-Section Review**: Go through the document from beginning to end, section by section. Do not skip around or jump between sections. Read the document in logical chunks (50-100 lines at a time) to ensure comprehensive coverage.

2. **Style Guide Compliance Areas**: Check for compliance with:
   - Punctuation rules (standalone bullet points end with periods, introductory bullet points end with colons)
   - Bold formatting for interface elements instead of quotes  
   - Hash-based headers (#, ##, ###) instead of bold text for section titles
   - **Bold text followed by colons converted to proper headers** (e.g., "**Configuration Steps:**" → "#### Configuration Steps")
   - **Unique header names to avoid MD024 duplicate heading warnings** (e.g., "Configuration Steps" → "Workbook Configuration Steps")
   - **Code blocks surrounded by blank lines** (MD031 compliance)
   - **Lists surrounded by blank lines** (MD032 compliance)
   - Professional technical documentation tone
   - Consistent header hierarchy and proper document structure
   - Proper code block formatting with language identifiers
   - Azure resource naming conventions
   - Clear, instructional language suitable for technical professionals

3. **Implementation Method**: Use the replace_string_in_file tool with sufficient context (3-5 lines before and after) for precise edits. Make one type of fix at a time rather than multiple simultaneous changes.

4. **Common Issues to Look For**:
   - Bold text acting as section headers (especially those ending with colons)
   - Duplicate heading text (make headers unique and descriptive)
   - Lists or code blocks not surrounded by blank lines
   - Missing language identifiers in code blocks
   - Interface elements in quotes instead of bold formatting

5. **Multiple Passes**: After completing the first full section-by-section review, perform additional passes as needed until all style guide issues are resolved. Run get_errors tool to check for remaining lint warnings.

6. **Quality Assurance**: Use the Quality Assurance Checklist from the style guide to verify compliance before declaring the review complete.

7. **Completion Criteria**: Continue iterating through the document until you can confirm that:
   - All sections comply with the style guide standards
   - No markdown lint warnings remain (MD024, MD031, MD032, MD001, MD040)
   - The document maintains professional technical documentation standards throughout

Please start the review from the beginning of the document and work systematically through each section. Focus on catching bold text that should be headers, ensuring header uniqueness, and verifying proper spacing around code blocks and lists.
```

---

*This style guide is a living document that should be updated as project standards evolve and new formatting requirements are identified.*
