# AI Prompt Templates for Defender XDR Integration

## 🔗 Integration Context & Dependencies

### How This Fits Into Your AI Security Pipeline

You have successfully deployed the **foundation layers** of your AI security automation system:

**✅ Completed Components (02.04):**

- **Azure OpenAI Service** - GPT-4o-mini model deployment with cost-optimized parameters.
- **Azure AI Foundry Configuration** - Cybersecurity analyst system instructions (Temperature 0.2, 450 tokens max).
- **Defender for Cloud Deployment** - Sample alerts generation and validation from Week 1.

### Current Phase: Template Creation

- **AI Prompt Templates (This Lab)** - Specialized prompts that enhance your base AI model for specific security scenarios.
- **Template Storage** - Organized in `./templates/` subfolder for easy Logic Apps integration.

### Next Phase Dependencies (02.06)

- **Logic Apps Workflows** - Automated workflows that will leverage these tested and refined templates.
- **Defender XDR Integration** - End-to-end alert processing through unified security portal.

### Template Architecture Relationship

These templates work with your deployed AI Foundry model to provide specialized analysis:

```text
Defender XDR Incident ──▶ Logic Apps ──▶ Template + AI Model ──▶ Specialized Analysis
    (Alert Source)         (Automation)    (This Lab + 02.04)      (Security Insights)
```

### Template Design Philosophy

#### Enhanced Context Approach

Your AI Foundry model (02.04) provides the **base cybersecurity analyst expertise**. These templates add **specialized context** for specific scenarios:

- **Base AI Model**: General cybersecurity analysis capabilities.
- **Template Enhancement**: Specific task focus (threat hunting, executive reporting, compliance analysis).
- **Combined Result**: Targeted security analysis optimized for specific use cases.

#### Cost-Optimized Specialization

Templates are designed to work within your 450-token limit while providing maximum analytical value for different security scenarios.

---

## 🎯 Strategic AI Implementation

These prompt templates implement a **layered intelligence architecture** designed to augment your security operations while maintaining strict cost controls:

### Security Analysis Specializations

- **Tier 1 - Initial Triage**: AI performs rapid incident classification and severity assessment to reduce manual workload.
- **Tier 2 - Deep Analysis**: AI correlates threat intelligence, maps incidents to MITRE ATT&CK framework, and generates contextual summaries.
- **Tier 3 - Executive Communication**: AI transforms technical security data into business-friendly reports for leadership.
- **Specialized Focus Areas**: Threat hunting, compliance analysis, incident response coordination.

### Cost-Optimized Design Principles

- **GPT-4o-mini Optimization**: Research-validated parameters (Temperature 0.2, 450 tokens) for cost-effective analysis.
- **Token Efficiency**: Structured response formats and clear length limits prevent budget overruns.
- **Modular Design**: Each template focuses on a specific task to maximize analytical value per token.
- **Learning Environment Focus**: Educational context balanced with realistic security operations practices.

---

## 📋 Template Architecture Overview

All templates are designed to work seamlessly with your deployed AI Foundry model configuration:

- **System Message Enhancement**: Templates provide specialized context that builds upon your base cybersecurity analyst instructions.
- **AI Foundry Testing**: Templates enable you to test and refine specialized analysis capabilities before automation.
- **Cost Controls**: Built-in token limits and efficiency optimization for budget management.
- **Automation Ready**: Templates will be ready for Logic Apps integration in the next phase (02.06).

---

## 🔧 Core Security Analysis Templates

### Template Categories

The template library provides four main categories of specialized analysis:

1. **[Threat Analysis Templates](#threat-analysis-templates)** - Technical threat hunting and MITRE ATT&CK mapping.
2. **[Business Communication Templates](#business-communication-templates)** - Executive reporting and stakeholder communication.
3. **[Operational Response Templates](#operational-response-templates)** - Incident response and remediation guidance.
4. **[Compliance & Governance Templates](#compliance--governance-templates)** - Regulatory analysis and risk assessment.

### Template Usage in AI Foundry

Each template is designed for testing and refinement in your AI Foundry playground before automation integration:

```text
Testing Approach in AI Foundry:
1. Keep your existing system message from 02.04 unchanged
2. Copy template content into the user message area
3. Add sample incident data for realistic testing
4. Evaluate response quality and adjust template as needed
5. Note token usage and cost efficiency
```

**AI Foundry Playground Configuration:**

- **System Message**: Your established cybersecurity analyst instructions from 02.04
- **User Message**: `[Template content] + [Sample incident data]`
- **Parameters**: Temperature 0.2, Max tokens 450 (as configured in 02.04)

---

## 🎯 Threat Analysis Templates

### [threat-hunting-analysis.md](./templates/threat-hunting-analysis.md)

**Purpose**: Advanced threat hunting and technical investigation with deep MITRE ATT&CK framework integration.

**Specialization**: Attack pattern recognition, lateral movement analysis, and proactive threat detection with KQL query generation.

**Best For**: Sophisticated attacks, APT activities, and complex multi-stage incidents requiring detailed technical investigation.

### [incident-classification.md](./templates/incident-classification.md)

**Purpose**: Rapid incident triage and severity assessment for automated alert processing.

**Specialization**: Quick, accurate classification with confidence scoring and false positive detection.

**Best For**: High-volume environments where efficient resource allocation and alert triage are critical.

---

## 💼 Business Communication Templates

### [executive-summary.md](./templates/executive-summary.md)

**Purpose**: Transforms technical security analysis into executive-level business communication.

**Specialization**: Business impact translation, decision framework identification, and stakeholder communication.

**Best For**: C-suite reporting, board briefings, and critical incident leadership communication.

### [stakeholder-communication.md](./templates/stakeholder-communication.md)

**Purpose**: Multi-audience security communication for different organizational levels.

**Specialization**: Audience-appropriate messaging with escalation paths and action item prioritization.

**Best For**: Coordinating incident response across IT teams, business units, customers, and external partners.

---

## 🚨 Operational Response Templates

### [incident-response-coordination.md](./templates/incident-response-coordination.md)

**Purpose**: Structured incident response coordination with step-by-step guidance.

**Specialization**: Time-based action frameworks and resource allocation recommendations.

**Best For**: Active security incidents requiring coordinated response and procedural guidance.

### [remediation-guidance.md](./templates/remediation-guidance.md)

**Purpose**: Specific technical remediation steps and recovery planning.

**Specialization**: Technology-specific recovery procedures with validation and testing guidance.

**Best For**: System recovery, security hardening, and prevention of similar future incidents.

---

## 📊 Compliance & Governance Templates

### [compliance-analysis.md](./templates/compliance-analysis.md)

**Purpose**: Regulatory compliance analysis and gap identification for security incidents.

**Specialization**: Multi-framework analysis (SOX, HIPAA, PCI-DSS, GDPR) with AI governance integration.

**Best For**: Compliance-regulated environments requiring structured regulatory reporting and audit preparation.

### [risk-assessment.md](./templates/risk-assessment.md)

**Purpose**: Comprehensive risk assessment and business impact analysis.

**Specialization**: Quantified business impact scoring with strategic security planning recommendations.

**Best For**: Risk management decision support and security investment justification.

---

## 📝 Template Implementation Guide

### Getting Started

1. **Review Template Categories**: Understand the four main template categories and their purposes.
2. **Select Appropriate Templates**: Choose templates that match your specific security analysis needs.
3. **Integration Planning**: Plan how templates will be integrated into your Logic Apps workflows.
4. **Testing Strategy**: Develop validation scenarios for each template type.

### Template Customization

Each template can be customized for your specific environment:

- **Organizational Context**: Add your specific compliance requirements, tools, and procedures
- **Response Procedures**: Incorporate your incident response playbooks and escalation paths
- **Technology Stack**: Customize for your specific Azure services and security tools
- **Communication Preferences**: Adapt language and formatting for your organizational culture

### Cost Management

Templates are designed with cost optimization in mind:

- **Token Efficiency**: Each template includes token usage estimates
- **Response Length Controls**: Built-in limits prevent budget overruns
- **Batch Processing Compatibility**: Templates support efficient batch analysis
- **Performance Monitoring**: Usage tracking guidance for cost management

---

## 🧪 Template Testing & Validation

### Testing Approach

Each template includes comprehensive testing scenarios and validation criteria:

- **Detailed Test Cases**: Each template provides 3-4 specific testing scenarios with sample data and expected outputs
- **Validation Checklists**: Quality assurance criteria to verify template effectiveness
- **Cost Analysis**: Token usage optimization and budget planning guidance

### AI Foundry Testing Process

1. **Keep System Message**: Use your established cybersecurity analyst instructions from 02.04
2. **Load Template**: Copy template content as user message with sample incident data
3. **Validate Output**: Compare results against template-specific validation criteria
4. **Monitor Costs**: Track token usage against template efficiency targets

**📋 See individual template files for comprehensive testing scenarios and expected outputs.**

---

## 🤖 AI-Assisted Content Generation

This comprehensive AI prompt templates guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The prompt templates, Logic Apps integration patterns, and cost-optimization strategies were generated, structured, and refined through iterative collaboration between human cybersecurity expertise and AI assistance within **Visual Studio Code**, incorporating current Azure OpenAI service capabilities, Defender XDR integration patterns, and enterprise security operations best practices aligned with the deployed AI Foundry model from 02.04.

*AI tools were used to enhance productivity and ensure comprehensive coverage of prompt template functionality while maintaining technical accuracy and reflecting current Azure security automation best practices and Defender for Cloud alert scenarios.*
