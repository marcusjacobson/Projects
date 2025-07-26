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

- **All bullet points must end with periods.**
- This applies to all list items, regardless of length or complexity.
- Use consistent bullet point formatting throughout the document.

#### Correct Examples

- Enable disk encryption on virtual machines.
- Install endpoint protection solution on machines.
- Apply system updates using Azure Update Manager integration.

#### Incorrect Examples

- Enable disk encryption on virtual machines
- Install endpoint protection solution on machines
- Apply system updates using Azure Update Manager integration

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

- Use consistent header hierarchy (H1, H2, H3, etc.).
- Include appropriate emoji icons for main sections when enhancing readability.
- Use descriptive headers that clearly indicate section content.
- Maintain logical content flow from general to specific information.

### Links and References

- Use descriptive link text that indicates destination content.
- Include screenshot references with clear descriptions.
- Format external links with full URLs when appropriate.
- Use consistent link formatting throughout documents.

### Code Blocks

- Use appropriate language identifiers for syntax highlighting.
- Include clear explanations before and after code blocks.
- Use consistent indentation and formatting within code blocks.
- Add comments to complex code examples for clarity.

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

### Punctuation Review

- [ ] All bullet points end with periods
- [ ] All sentences end with appropriate punctuation
- [ ] Consistent punctuation usage throughout document

### Formatting Review

- [ ] Interface elements use bold formatting instead of quotes
- [ ] Consistent header hierarchy and structure
- [ ] Proper code block formatting with language identifiers
- [ ] Consistent link formatting and descriptions

### Content Review

- [ ] Professional technical documentation tone throughout
- [ ] Clear, instructional language suitable for technical audience
- [ ] Logical content progression from simple to complex
- [ ] Sufficient context and explanation for procedures

### Technical Accuracy Review

- [ ] Consistent Azure resource naming conventions
- [ ] Accurate product names and terminology
- [ ] Current version references and date information
- [ ] Valid cross-references and external links

### Accessibility Review

- [ ] Descriptive headings and clear content structure
- [ ] Alternative text for visual references
- [ ] Consistent formatting for screen readers
- [ ] Clear language and terminology definitions

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

1. **Systematic Section-by-Section Review**: Go through the document from beginning to end, section by section. Do not skip around or jump between sections.

2. **Style Guide Compliance Areas**: Check for compliance with:
   - Punctuation rules (all bullet points must end with periods)
   - Bold formatting for interface elements instead of quotes
   - Professional technical documentation tone
   - Consistent header hierarchy and structure
   - Proper code block formatting
   - Azure resource naming conventions
   - Clear, instructional language suitable for technical professionals

3. **Implementation Method**: Use the replace_string_in_file tool with sufficient context (3-5 lines before and after) for precise edits.

4. **Multiple Passes**: After completing the first full section-by-section review, perform additional passes as needed until all style guide issues are resolved.

5. **Quality Assurance**: Use the Quality Assurance Checklist from the style guide to verify compliance before declaring the review complete.

6. **Completion Criteria**: Continue iterating through the document until you can confirm that all sections comply with the style guide standards.

Please start the review from the beginning of the document and work systematically through each section.
```

---

*This style guide is a living document that should be updated as project standards evolve and new formatting requirements are identified.*
