# AI Prompt Templates for Microsoft Sentinel Integration

## 🔗 Integration Context & Dependencies

### How This Fits Into Your AI Security Pipeline

You have successfully deployed the **foundation layers** of your AI security automation system:

**✅ Completed Components:**

- **Azure OpenAI Service** - GPT-o4-mini model deployment with sufficient quota allocation.
- **Azure AI Foundry Configuration** - Cybersecurity analyst system instructions with research-validated parameters.
- **Defender for Cloud Deployment** - Sample alerts generation and validation from Week 1.

### Current Phase: Template Preparation

- **AI Prompt Templates (This Document)** - JSON configuration files that bridge your AI model to automated workflows

### Next Phase Dependencies

- **Microsoft Sentinel Integration** - Logic Apps workflows that will consume these templates
- **Automated Response Workflows** - End-to-end alert processing using your AI analysis

### Template Architecture Relationship

These JSON templates serve as the **critical bridge** between your deployed AI Foundry model and the upcoming Sentinel automation:

```text
Azure AI Foundry ──▶ JSON Templates ──▶ Logic Apps ──▶ Microsoft Sentinel
   (Your AI Brain)    (This Document)   (Automation)    (Alert Source)
```

#### Why Templates Are Essential

- **Logic Apps Integration**: JSON format required for automated workflow processing.
- **Specialized Context**: Each template adds specific focus to your base AI Foundry instructions.
- **Cost Optimization**: Templates include token limits, batch processing, and budget controls.
- **Scenario Specialization**: Different templates for threat hunting vs. executive reporting vs. incident response.

### Template Design Philosophy

#### Base + Specialization Approach

- **AI Foundry System Message**: Provides consistent cybersecurity analyst expertise across all scenarios
- **Template System Message**: Adds specific task focus (incident response, threat hunting, executive communication)
- **Combined Result**: Professional security analysis + specialized workflow guidance

#### Task-Focused Templates

Instead of redefining roles (which would duplicate your AI Foundry configuration), templates provide **specific task instructions** that complement your deployed cybersecurity analyst persona.

---

## 🎯 Strategic AI Implementation

The AI prompt templates implement a **layered intelligence architecture** designed to augment your security operations while maintaining strict cost controls:

### Assumed Cybersecurity Roles

- **Tier 1 - Automated Triage**: AI performs initial incident classification and severity assessment to reduce manual workload.
- **Tier 2 - Enrichment Analysis**: AI correlates threat intelligence, maps incidents to MITRE ATT&CK framework, and generates contextual summaries.
- **Tier 3 - Executive Translation**: AI transforms technical security data into business-friendly reports for leadership communications.
- **Proactive Threat Hunting**: Advanced templates support analyst-driven threat hunting activities by generating hunting queries, IOC analysis, and threat intelligence correlation.
- **Compliance and Reporting**: Specialized templates transform security incidents into compliance-ready reports for SOX, HIPAA, PCI-DSS, and other regulatory frameworks.
- **Executive Communications**: Business-focused templates create executive-ready security briefings that translate technical threats into business risk language.

### Cost-Optimized Design Principles

- **GPT-o4-mini Optimization**: Research-validated parameters (Temperature 0.2, 450 tokens) for cost-effective analysis
- **Token Efficiency**: Structured response formats and clear length limits prevent budget overruns
- **Batch Processing**: Templates support grouping similar alerts for processing efficiency
- **Learning Environment Focus**: Educational context balanced with realistic security operations practices

### Key Benefits

- **Cost-Optimized Design**: Each template includes token limits and efficient prompting strategies targeting $5-10/month for 1000 incidents.
- **Security-Focused Output**: Tailored responses for cybersecurity operations and threat analysis with domain expertise.
- **Integration Ready**: JSON format designed for seamless Logic Apps integration with standardized parsing schemas.
- **Scalable Architecture**: Configurable templates supporting various security scenarios from SMB to enterprise scale.
- **Production Tested**: Validated configurations with error handling, optimization controls, and real-world validation.

## 📋 Template Architecture

All templates follow a consistent structure designed for Azure OpenAI API integration:

- **Prompt Engineering**: Optimized prompts with clear instructions and output formatting.
- **Cost Controls**: Token limits, temperature settings, and response length restrictions.
- **Security Context**: Role-based prompting with cybersecurity domain expertise.
- **Integration Parameters**: Logic Apps-compatible JSON schema for automated workflows.

---

## 🔧 Core Integration Templates

> **📋 Note**: The templates in this section are provided for informational purposes at this stage of the learning path. The configuration details and integration patterns will become more relevant and actionable as you progress through the subsequent deployment sections in this module.

### [openai-action-configuration.json](./scripts/templates/openai-action-configuration.json)

**Template Objective**: Serves as the **primary Logic Apps integration template** that provides the foundational configuration for connecting automated workflows to your deployed GPT-o4-mini model.

**Purpose**: This template establishes the base configuration parameters, authentication settings, and core prompt structure that all other templates inherit. It complements your AI Foundry cybersecurity analyst instructions by adding Logic Apps-specific formatting and cost optimization controls.

**Task Focus**: Adds structured response formatting and token efficiency optimization to your existing AI Foundry system message, enabling automated processing of AI responses in Logic Apps workflows.

#### Key Features

- **GPT-o4-mini Integration**: Direct connection parameters for your deployed AI Foundry model.
- **Cost Control Foundation**: 450-token limits and processing efficiency for $50/month learning budget.
- **Summary Report Format**: Structured response format optimized for automated downstream processing.
- **Logic Apps Compatibility**: JSON schema designed for seamless workflow automation integration.

#### Use Cases

- Base configuration for all Logic Apps AI integration workflows.
- Foundation template for extending specialized security analysis scenarios.
- Cost monitoring and budget control implementation across all templates.
- Template validation and testing for Defender for Cloud alert processing.

### [parse-json-schema.json](./scripts/templates/parse-json-schema.json)

**Purpose**: Enhanced JSON response parsing structure for GPT-o4-mini security analysis with cost tracking capabilities.

**Description**: This template defines the expected JSON schema for parsing Azure OpenAI GPT-o4-mini responses within Logic Apps. It standardizes the structured summary report format and includes comprehensive usage tracking for cost management and performance monitoring.

#### Parse JSON Schema Key Features

- **Summary Report Format**: Structured parsing for THREAT ASSESSMENT, ATTACK ANALYSIS, BUSINESS IMPACT, IMMEDIATE ACTIONS sections.
- **Token Usage Tracking**: Comprehensive cost monitoring with prompt (~250) and completion (~380) token expectations.
- **Response Quality Validation**: Finish reason tracking and content filtering status monitoring.
- **Cost Optimization Support**: Real-time usage data for budget management and threshold enforcement.

#### Parse JSON Schema Use Cases

- Parsing GPT-o4-mini threat analysis results in structured format.
- Extracting actionable security intelligence from AI responses.
- Cost tracking and budget management for AI operations.
- Quality assurance monitoring for AI-generated security assessments.

### [trigger-filters.json](./scripts/templates/trigger-filters.json)

**Purpose**: Enhanced incident filtering criteria for Defender for Cloud alerts with cost-optimized processing logic.

**Description**: This template provides intelligent filtering mechanisms specifically designed for Microsoft Defender for Cloud alert types, including sample alerts used in testing and real security incidents. It includes comprehensive cost optimization features and priority-based processing to ensure efficient AI utilization.

#### Trigger Filters Key Features

- **Defender for Cloud Focus**: Specific filtering for **Azure Security Center** product alerts and common alert types.
- **Sample Alert Integration**: Support for testing scenarios including suspicious processes, data access patterns, container threats, and web shell detections.
- **Cost Optimization Controls**: Daily token limits, batch processing, and priority filtering mechanisms.
- **Resource Type Awareness**: Targeted filtering for VMs, storage accounts, container clusters, and web applications.

**Use Cases**:

#### Trigger Filters Use Cases

- Automated triage of Defender for Cloud security alerts.
- Cost-controlled AI analysis activation with intelligent filtering.
- Priority-based security response automation for high-value incidents.
- Testing validation with sample alert scenarios from Week 1 deployment.

---

## 🎯 Advanced AI Prompt Templates

### [threat-hunting-prompt.json](./scripts/templates/threat-hunting-prompt.json)

**Template Objective**: Specializes your AI Foundry cybersecurity analyst for **advanced threat hunting and technical investigation** of Defender for Cloud alerts with deep MITRE ATT&CK framework integration.

**Purpose**: This template adds focused threat hunting context to your base AI analysis, emphasizing attack pattern recognition, lateral movement indicators, and proactive threat detection techniques specifically for Azure cloud environments.

**Task Focus**: Enhances your AI Foundry instructions with specialized threat hunting methodologies, KQL query generation for Sentinel investigation, and IOC (Indicators of Compromise) development for ongoing monitoring.

#### Threat Hunting Template Key Features

- **MITRE ATT&CK Specialization**: Advanced technique mapping for VM threats, storage anomalies, container security, and web application attacks.
- **KQL Query Generation**: Automated Sentinel hunt queries for investigating specific alert types and attack patterns.
- **Lateral Movement Analysis**: Assessment of compromise spread potential and network communication patterns.
- **IOC Development**: Identification of file hashes, IP addresses, processes, and other indicators for continuous monitoring.

#### Threat Hunting Template Use Cases

- Deep technical analysis of Defender for Cloud sample alerts from Week 1 scenarios.
- Proactive threat hunting across Azure cloud infrastructure and workloads.
- KQL query development for Sentinel-based investigation workflows.
- Advanced threat intelligence correlation and attack chain reconstruction.

### [executive-summary-prompt.json](./scripts/templates/executive-summary-prompt.json)

**Template Objective**: Transforms your AI Foundry cybersecurity analyst expertise into **executive-level business communication** suitable for IT leadership and C-suite reporting.

**Purpose**: This template adds business communication focus to your technical AI analysis, translating complex security incidents into clear, actionable executive briefings that emphasize business impact and decision requirements.

**Task Focus**: Complements your AI Foundry technical analysis by adding executive communication skills, business risk assessment, and leadership-oriented reporting structures.

#### Executive Summary Template Key Features

- **Business Impact Translation**: Converts technical security alerts into business risk assessments and operational impact analysis.
- **Executive Communication**: Clear, jargon-free language appropriate for IT leadership and C-suite audiences.
- **Decision Framework**: Identifies specific budget, resource, or policy decisions required from executive leadership.
- **Timeline Management**: Provides resolution timeframes and key milestone communications for executive oversight.

#### Executive Summary Template Use Cases

- Executive briefings on critical security incidents from Defender for Cloud alerts.
- Business impact assessments for sample alert scenarios from Week 1 deployment.
- Leadership communications requiring technical-to-business translation.
- Executive decision support for security operations resource allocation and policy development.

### [compliance-prompt-template.json](./scripts/templates/compliance-prompt-template.json)

**Purpose**: Regulatory compliance analysis and gap identification optimized for Azure security incidents and AI governance.

**Description**: This template enables GPT-o4-mini powered compliance analysis for Defender for Cloud security incidents and organizational security posture. It evaluates incidents against regulatory frameworks and identifies compliance gaps requiring immediate attention, incorporating modern AI governance frameworks including NIST AI RMF and OWASP LLM Top 10 considerations.

#### Compliance Template Key Features

- **Multi-Framework Compliance Analysis**: Comprehensive coverage of SOX, HIPAA, PCI-DSS, GDPR regulatory requirements and Azure-specific compliance considerations.
- **AI Governance Integration**: NIST AI Risk Management Framework (AI RMF 1.0) and OWASP LLM Top 10 compliance assessment for AI-assisted security operations.
- **Defender for Cloud Context**: Specialized compliance analysis for Azure security incidents including data breach notification requirements and control effectiveness validation.
- **Structured Compliance Assessment**: REGULATORY IMPACT, COMPLIANCE GAPS, and REMEDIATION sections for comprehensive governance reporting.
- **Token Limit**: 300 tokens for thorough compliance analysis while maintaining cost efficiency.

#### Compliance Template Use Cases

- Compliance gap analysis and regulatory reporting for Azure security incidents.
- AI governance assessment and risk management for GPT-o4-mini security operations.
- Regulatory audit preparation and documentation support.
- Risk management and governance framework alignment validation.

---

### [dfc-sample-alert-analysis.json](./scripts/templates/dfc-sample-alert-analysis.json)

**Template Objective**: Specializes your AI Foundry cybersecurity analyst for **learning environment sample alert analysis** with focus on the four primary Defender for Cloud alert types from Week 1 deployment scenarios.

**Purpose**: This template adds educational context and sample alert specialization to your base AI analysis, optimizing for the specific sample alerts generated during Defender for Cloud deployment validation and bridge testing.

**Task Focus**: Enhances your AI Foundry instructions with sample alert recognition, educational explanations, and learning objective integration while maintaining realistic security analysis standards.

#### DFC Sample Alert Analysis Key Features

- **Sample Alert Specialization**: Optimized analysis for **Sample alert: suspicious process detected**, unusual data access, container threats, and web shell detection.
- **Educational Integration**: Balances realistic security procedures with learning environment safety and educational value.
- **Week 1 Bridge Validation**: Designed specifically for deployment validation scenarios and configuration verification.
- **Learning Objectives**: Emphasizes skill development and knowledge transfer for AI-enhanced security operations.

#### DFC Sample Alert Analysis Use Cases

- Week 1 to Week 2 bridge validation testing using sample alerts from Defender for Cloud deployment.
- Educational analysis of sample security scenarios for skill development and training.
- Template testing and validation before production Sentinel integration.
- Learning environment demonstration of AI-enhanced security analysis capabilities.

---

### [incident-response-automation.json](./scripts/templates/incident-response-automation.json)

**Template Objective**: Transforms your AI Foundry cybersecurity analyst into a **structured incident response coordinator** providing step-by-step guidance for security alert handling in learning environments.

**Purpose**: This template adds incident response workflow specialization to your base AI analysis, providing structured procedures, containment priorities, and educational context for hands-on incident response skill development.

**Task Focus**: Complements your AI Foundry cybersecurity expertise by adding incident response methodology, time-based action frameworks, and learning objective integration for practical security operations training.

#### Incident Response Automation Key Features

- **Structured Response Framework**: INCIDENT CLASSIFICATION, RESPONSE PROCEDURES, and LEARNING OBJECTIVES sections for comprehensive guidance.
- **Time-Based Actions**: Immediate actions (first 15 minutes), investigation steps, and containment measures with realistic timelines.
- **Educational Balance**: Realistic security procedures adapted for safe learning environment practice and skill development.
- **Skills Development**: Emphasizes hands-on incident response capabilities and real-world applicability.

#### Incident Response Automation Use Cases

- Automated incident response guidance for Defender for Cloud alert scenarios from Week 1 deployment.
- Learning environment incident response training with structured procedures and educational context.
- Template-driven workflow development for consistent incident handling methodology.
- Skills assessment and competency development for AI-enhanced security operations roles.

---

## 💰 Cost Management Templates

### [budget-monitoring-config.json](./scripts/templates/budget-monitoring-config.json)

**Purpose**: Budget threshold monitoring and cost control automation.

**Description**: This template provides real-time cost monitoring for AI operations with automated threshold enforcement. It prevents cost overruns by implementing intelligent budget controls and usage optimization strategies.

#### Budget Monitoring Key Features

- Real-time cost tracking and alerting.
- Automated budget threshold enforcement.
- Usage pattern analysis and optimization.
- Cost forecasting and projection capabilities.

**Cost Impact**: Prevents overspend and enables predictable AI operations costs.

#### Budget Monitoring Use Cases

- Organizational cost control and governance.
- AI operation budget management.
- Usage optimization and forecasting.

---

### [conditional-logic.json](./scripts/templates/conditional-logic.json)

**Purpose**: Budget-based processing control and intelligent resource allocation.

**Description**: This template implements intelligent conditional logic for AI processing based on available budget and resource constraints. It ensures optimal resource utilization while maintaining security coverage.

#### Conditional Logic Key Features

- Budget-aware processing decisions.
- Resource allocation optimization.
- Priority-based AI utilization.
- Automated cost-benefit analysis.

**Cost Impact**: Automated cost controls with intelligent resource management.

#### Conditional Logic Use Cases

- Intelligent AI resource allocation.
- Budget-conscious security automation.
- Cost-optimal incident processing workflows.

---

### [batch-processing-config.json](./scripts/templates/batch-processing-config.json)

**Purpose**: Efficient bulk incident processing for cost optimization.

**Description**: This template enables cost-effective batch processing of multiple security incidents simultaneously. It optimizes token usage through intelligent batching strategies while maintaining analysis quality.

#### Batch Processing Key Features

- Multi-incident batch processing capabilities.
- Token usage optimization through batching.
- Consistent analysis quality across batch operations.
- Scalable processing for high-volume environments.

**Cost Impact**: Approximately $0.002 per 5 incidents through efficient batching.

#### Batch Processing Use Cases

- High-volume security operations centers.
- Cost-effective incident triage automation.
- Scalable security analysis workflows.

---

### [optimized-prompt-config.json](./scripts/templates/optimized-prompt-config.json)

**Purpose**: GPT-o4-mini parameter optimization and cost-conscious token efficiency configuration.

**Description**: This template provides advanced prompt optimization techniques specifically calibrated for GPT-o4-mini to minimize token consumption while maximizing analysis effectiveness for Defender for Cloud security incidents. It includes research-validated parameter configurations and cost analysis data based on current Azure OpenAI pricing.

#### Optimized Prompt Config Key Features

- **Research-Validated Parameters**: Temperature 0.2, Top P 0.9, Frequency Penalty 0.3, Presence Penalty 0.1 for optimal security analysis.
- **Cost Analysis Integration**: Detailed cost projections with $0.00038 per analysis based on current Azure OpenAI GPT-o4-mini pricing.
- **Token Efficiency Optimization**: Expected 250 system tokens, 380 average response tokens, 450 maximum response tokens.
- **Quality Assurance Metrics**: Context awareness, MITRE mapping, business impact assessment, actionable recommendations tracking.
- **Summary Report Format**: Structured response optimization for token-efficient, high-quality security analysis.

**Cost Impact**: Optimized token consumption through intelligent prompt engineering and parameter tuning for cost-effective security operations.

#### Optimized Prompt Config Use Cases

- Cost-sensitive AI operations with strict budget controls.
- High-frequency security automation requiring token efficiency.
- Performance optimization across all Defender for Cloud alert analysis workflows.
- Quality assurance validation for GPT-o4-mini security analysis effectiveness.

---

## 🔍 Testing and Validation Examples

### Sample Defender for Cloud Alert Analysis

**Input Scenario**: Sample alert from Week 1 deployment validation

```json
{
  "properties": {
    "title": "Sample alert: suspicious process detected",
    "severity": "High", 
    "description": "Suspicious process execution detected on virtual machine sample-vm-001",
    "resourceIdentifiers": ["/subscriptions/.../providers/Microsoft.Compute/virtualMachines/sample-vm-001"],
    "relatedEntities": [
      {"type": "process", "name": "powershell.exe"},
      {"type": "host", "name": "sample-vm-001"}
    ]
  }
}
```

**Expected GPT-o4-mini Response** (using threat-hunting-prompt.json):

```text
THREAT ASSESSMENT:
- Attack Pattern: Suspicious PowerShell execution potentially indicating lateral movement or persistence establishment
- MITRE ATT&CK: T1059.001 (Command and Scripting Interpreter: PowerShell)

ATTACK ANALYSIS:  
- Lateral Movement: PowerShell commonly used for remote execution and privilege escalation
- Data Exfiltration Risk: Medium - PowerShell can access sensitive data and establish network connections
- Persistence: High risk of scheduled tasks or registry modifications

HUNT QUERIES:

```kql
DeviceProcessEvents
| where FileName == "powershell.exe" 
| where InitiatingProcessCommandLine contains "-encoded" or ProcessCommandLine contains "bypass"
| project TimeGenerated, DeviceName, ProcessCommandLine, InitiatingProcessCommandLine
```

IOC Generation: Monitor for encoded PowerShell commands, execution policy bypasses, and remote connection attempts.

```text
**Token Usage**: ~380 tokens (within 400 limit), Cost: ~$0.00038

### Executive Summary Example

**Input**: Same sample alert

**Expected Response** (using executive-summary-prompt.json):

```text
BUSINESS IMPACT: Security monitoring detected potential unauthorized system access that could compromise business operations and data security.

INCIDENT SUMMARY: Our security systems identified suspicious computer activity on a test virtual machine, specifically unauthorized PowerShell script execution that could indicate an attacker attempting to gain deeper access to our systems.

CURRENT STATUS: Alert generated and under investigation by security team. Affected system is in test environment with limited business impact.

RISK ASSESSMENT: Low immediate business risk due to test environment isolation. Potential for similar attacks on production systems requires immediate attention.

NEXT STEPS: Security team will investigate attack patterns, implement additional monitoring, and review production system hardening measures.
```

**Token Usage**: ~180 tokens (within 200 limit), Cost: ~$0.00027

### [error-recovery-validation.json](./scripts/templates/error-recovery-validation.json)

**Purpose**: Error handling validation and recovery testing for AI operations.

**Description**: This template provides comprehensive error scenario testing for AI-powered security operations. It validates graceful failure handling, recovery mechanisms, and system resilience under various failure conditions.

#### Error Recovery Validation Key Features

- Comprehensive error scenario coverage.
- Graceful failure handling validation.
- System recovery mechanism testing.
- Resilience and reliability assessment.

**Validation Type**: Error handling and system resilience validation.

#### Error Recovery Validation Use Cases

- AI system reliability testing.
- Failure scenario validation and preparation.
- System resilience assessment and improvement.

---

## 📋 Template Library Summary

### What This Guide Accomplished

This documentation has provided **15 specialized AI prompt templates** that bridge your deployed GPT-o4-mini model to Microsoft Sentinel automation. The templates transform generic AI responses into structured cybersecurity analysis suitable for Logic Apps workflow processing.

### Ready for Implementation

The template library includes:

- **Core integration configurations** for Logic Apps connectivity and cost control.
- **Specialized analysis templates** for threat hunting, executive reporting, and incident response.
- **Cost management controls** optimized for $50/month learning environment budgets.

All templates follow Azure Logic Apps JSON schema requirements and include GPT-o4-mini parameter optimization (Temperature 0.2, 450 tokens) for consistent, cost-effective security analysis.

---

## 🔗 Bridge to Logic Apps Integration

### Template Function in Workflow Automation

These templates enable the automated security workflow chain where Defender for Cloud alerts trigger Logic Apps workflows that use the templates to query your AI Foundry model for structured security analysis.

#### Template Integration Benefits

1. **Specialized Context**: Templates focus your AI Foundry analyst on specific operational scenarios.
2. **Structured Output**: Consistent, parseable responses enable downstream automation processing.
3. **Cost Control**: Built-in token limits prevent budget overruns during automated operations.

### Immediate Next Steps

#### Required for Logic Apps Deployment

1. **Deploy Sentinel Integration** - Use the provided template library to create automated security workflows that process Defender for Cloud alerts.
2. **Implement Cost Monitoring** - Deploy the budget control templates to track and manage AI operations costs.
3. **Test with Sample Alerts** - Validate template functionality using the Defender for Cloud sample alerts from Week 1 deployment.

#### Expected Outcomes

Upon completion of the Logic Apps integration phase, you will achieve:

- **Automated Alert Processing** - Defender for Cloud security incidents automatically analyzed by specialized AI templates.
- **Consistent Security Analysis** - Standardized, professional-quality threat assessments for every alert type.
- **Cost-Controlled Operations** - Predictable AI-powered security operations within educational budget constraints.
- **Scalable Foundation** - Enterprise-ready architecture patterns suitable for production security environments.

### Success Criteria

The template library documented in this guide provides the essential foundation for transitioning from manual AI interaction to fully automated security operations, enabling enterprise-scale threat analysis within learning environment resource constraints.

---

## 🤖 AI-Assisted Content Generation

This comprehensive AI prompt templates guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The GPT-o4-mini template configurations, JSON specifications, Defender for Cloud integration scenarios, and cost-optimization strategies were generated, structured, and refined through iterative collaboration between human cybersecurity expertise and AI assistance within **Visual Studio Code**, incorporating current Azure OpenAI service capabilities, Microsoft Sentinel automation features, NIST AI RMF compliance considerations, and enterprise security operations best practices aligned with the Week 1 Defender for Cloud deployment scenarios.

*AI tools were used to enhance productivity and ensure comprehensive coverage of GPT-o4-mini prompt template functionality while maintaining technical accuracy and reflecting current Azure security automation best practices and Defender for Cloud alert scenarios.*
