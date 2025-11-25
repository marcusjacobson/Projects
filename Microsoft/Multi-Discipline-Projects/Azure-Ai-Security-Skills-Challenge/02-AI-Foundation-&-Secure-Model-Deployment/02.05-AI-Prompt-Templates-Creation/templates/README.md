# AI Prompt Templates for Security Analysis

This folder contains specialized prompt templates designed to enhance your Azure OpenAI GPT-4o-mini model for specific security analysis scenarios with Microsoft Defender XDR integration.

## Template Categories

### 🎯 Threat Analysis Templates

- **[threat-hunting-analysis.md](./threat-hunting-analysis.md)** - Advanced threat hunting with MITRE ATT&CK mapping and behavioral analysis
- **[incident-classification.md](./incident-classification.md)** - Rapid incident triage and severity classification with business impact assessment

### 💼 Business Communication Templates

- **[executive-summary.md](./executive-summary.md)** - Executive-level business communication and strategic decision support
- **[stakeholder-communication.md](./stakeholder-communication.md)** - Multi-audience security communications with stakeholder management

### 🚨 Operational Response Templates

- **[incident-response-coordination.md](./incident-response-coordination.md)** - Structured incident response coordination with role-based communication
- **[remediation-guidance.md](./remediation-guidance.md)** - Comprehensive technical remediation and implementation guidance

### 📊 Compliance & Governance Templates

- **[compliance-analysis.md](./compliance-analysis.md)** - Regulatory compliance analysis with NIST AI RMF, GDPR, and industry standards
- **[risk-assessment.md](./risk-assessment.md)** - Comprehensive risk assessment with business impact analysis and OWASP LLM considerations

## How to Use These Templates

1. **Choose the appropriate template** for your security analysis needs
2. **Copy the template content** from the "Template Content" section
3. **Use as the user message** in your Logic Apps HTTP action
4. **Combine with incident data** that Logic Apps will append
5. **Configure with your AI Foundry system message** from 02.04

## Integration with Logic Apps

These templates are designed for seamless integration with the Logic Apps workflows using specific structures identified in each template. To apply the template, update the following Logic App actions:

- **Open AI action**: Analyze Incident with AI.
- **Compose action**: Extract AI Analysis Sections.
- **Compose action**: Create Comments Array.

## Cost Optimization

All templates are optimized for GPT-4o-mini cost efficiency:

- **Token limits**: 300-450 tokens per template (varies by template complexity)
- **Cost per analysis**: ~$0.00021-$0.00041 (based on current GPT-4o-mini pricing)
- **Monthly budget**: <$1 for 1000+ analyses across all templates
- **Pricing model**: $0.15 input / $0.60 output per 1M tokens

## Template Customization

Each template includes customization guidance for:

- **Organizational procedures and policies** - Adapt to your security framework and incident response procedures
- **Compliance requirements and regulatory frameworks** - Including NIST AI RMF with Generative AI Profile, GDPR, SOX, HIPAA, and industry-specific standards
- **Technical environment and tool integration** - Microsoft Defender XDR, Azure Security Center, and third-party SIEM platforms  
- **Communication preferences and stakeholder needs** - Executive reporting styles, technical detail levels, and audience-specific formatting
- **AI and LLM-specific considerations** - OWASP Top 10 for Large Language Models 2025 and responsible AI practices

## Quality Validation

Each template includes validation checklists to ensure:

- **Appropriate output format and structure** - Professional formatting with clear sections and actionable insights
- **Professional tone and audience-appropriate language** - Executive-level summaries vs technical implementation details
- **Actionable recommendations and specific guidance** - Concrete next steps with priorities and timelines
- **Cost-effective token usage within limits** - Optimized for GPT-4o-mini efficiency while maintaining quality
- **Integration compatibility with automated workflows** - Seamless Logic Apps integration with consistent JSON formatting
- **Compliance with modern security frameworks** - NIST AI RMF Generative AI Profile and OWASP LLM security considerations
