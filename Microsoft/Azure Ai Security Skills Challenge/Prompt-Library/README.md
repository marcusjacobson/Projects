# AI Prompt Library

**Author:** Marcus Jacobson  
**Version:** 1.0.0  
**Last Updated:** February 15, 2025

This library contains curated AI prompts designed for security, governance, and AI agent use cases as part of the Azure AI Security Skills Challenge. All prompts follow a standardized template for consistency and reusability.

## 📁 Folder Structure

```
Prompt-Library/
├── Security/           # Security-focused prompts
├── Governance/         # Data governance and compliance prompts  
├── AI_Agents/          # AI agent development and management prompts
└── prompt-template.md  # Standard template for all prompts
```

## 🎯 Purpose

The AI Prompt Library serves as a centralized repository for:

- **Security Analysts:** Prompts for threat detection, incident response, and security analysis
- **Governance Teams:** Prompts for compliance checking, policy review, and risk assessment  
- **AI Developers:** Prompts for building, testing, and managing AI agents and workflows
- **Administrators:** Prompts for system monitoring, configuration management, and troubleshooting

## 📝 Contributing New Prompts

### Using the Template

1. Copy the [`prompt-template.md`](prompt-template.md) file
2. Rename it to describe your prompt (use kebab-case: `my-security-prompt.md`)
3. Place it in the appropriate category folder:
   - **Security/**: For security analysis, threat detection, incident response
   - **Governance/**: For compliance, policy, data governance, risk management
   - **AI_Agents/**: For AI agent development, management, and automation
4. Fill out all sections of the template completely

### Required Information

Each prompt must include:

- **Clear purpose and objectives**
- **Recommended deployment tools** (Microsoft 365 Copilot, GitHub Copilot, Azure OpenAI, etc.)
- **Expected results and success criteria**
- **Complete usage instructions**
- **Example use cases**
- **Security and limitation considerations**
- **Testing and validation guidance**

### Tagging Convention

Use consistent tags to make prompts discoverable:

- **Category Tags:** `#security`, `#governance`, `#ai-agents`
- **Tool Tags:** `#copilot`, `#defender`, `#purview`, `#fabric`, `#openai`
- **Use Case Tags:** `#threat-detection`, `#compliance`, `#automation`, `#analysis`
- **Difficulty Tags:** `#beginner`, `#intermediate`, `#advanced`

## 🛠️ Supported Tools

Our prompts are designed to work with:

### Microsoft AI Tools
- Microsoft 365 Copilot (Word, Excel, PowerPoint, Outlook, Teams)
- GitHub Copilot (VS Code, CLI, Chat)
- Copilot Studio
- Microsoft Defender XDR
- Microsoft Purview
- Microsoft Priva
- Microsoft Fabric
- Azure AI Foundry
- Azure OpenAI Studio

### External AI Platforms
- ChatGPT (OpenAI)
- Claude (Anthropic)
- Custom AI applications

## 📊 Quality Standards

All prompts must meet these criteria:

### Accuracy
- Produce consistent, reliable results
- Include validation steps
- Provide clear success criteria

### Completeness
- Cover all necessary information
- Include prerequisites and setup
- Provide troubleshooting guidance

### Security
- Handle sensitive data appropriately
- Include privacy considerations
- Follow compliance requirements

### Usability
- Clear, step-by-step instructions
- Real-world examples
- Actionable outputs

## 🔄 Maintenance

### Regular Reviews
- Monthly prompt testing and validation
- Quarterly updates for tool changes
- Annual comprehensive review

### Version Control
- All changes tracked in version history
- Semantic versioning (Major.Minor.Patch)
- Change documentation required

### Community Feedback
- Submit issues for prompt improvements
- Share success stories and variations
- Contribute new use cases and examples

## 📚 Getting Started

1. **Browse the Categories:** Explore Security, Governance, and AI_Agents folders
2. **Read the Template:** Understand the structure using [`prompt-template.md`](prompt-template.md)
3. **Try Examples:** Start with beginner-level prompts in your area of interest
4. **Contribute:** Create new prompts using the standard template
5. **Share:** Document your experiences and improvements

## 🔗 Related Resources

- [Azure AI Security Skills Challenge Overview](../README.md)
- [Project Setup & Administration](../00%20-%20Project%20Setup%20&%20Admin/README.md)
- [Microsoft 365 Copilot Documentation](https://docs.microsoft.com/copilot/)
- [Azure AI Platform Documentation](https://docs.microsoft.com/azure/ai/)
- [GitHub Copilot Documentation](https://docs.github.com/copilot)

---

**Note:** This prompt library is part of the Azure AI Security Skills Challenge and follows Microsoft's responsible AI principles and security best practices.
