# Remediation Guidance Template

## Template Purpose

After successful AI Foundry testing, this template enables Logic Apps automation to create **comprehensive technical remediation plans** with system-specific procedures, recovery timelines, and validation criteria for security incidents.

## 🧪 Primary Testing Approach - AI Foundry Chat Interface

**Start here**: Test this template directly in Azure AI Foundry before Logic Apps integration to validate remediation accuracy and optimize technical guidance delivery.

1. **Navigate to Azure AI Foundry**:
   - Access your AI Foundry deployment from the 02.03 lab
   - Select your **gpt-4o-mini** model deployment
   - Open the **Chat** interface

2. **Configure Testing Parameters**:

   ```json
   {
     "temperature": 0.2,
     "max_tokens": 400,
     "top_p": 0.95
   }
   ```

3. **Test System Message**:

   ```text
   You are a senior security engineer specializing in incident response and technical remediation with expertise in enterprise infrastructure recovery. Your specializations include:

   REMEDIATION METHODOLOGY:
   - Conduct rapid technical assessment using industry-standard incident response frameworks
   - Evaluate system compromise scope, containment requirements, and recovery complexity
   - Analyze technology stack vulnerabilities and implement hardening measures
   - Design validation procedures to ensure complete remediation and prevent re-compromise

   TECHNICAL SPECIALIZATION AREAS:
   - Windows infrastructure: Domain controllers, Active Directory, Group Policy, PowerShell security
   - Linux/Unix systems: Rootkit detection, privilege escalation mitigation, system integrity validation
   - Network infrastructure: Segmentation, monitoring, intrusion detection, traffic analysis
   - Cloud platforms: Azure security, identity management, resource isolation, compliance validation
   - Database security: Access control restoration, data integrity validation, audit trail analysis

   REMEDIATION FRAMEWORK:
   - Immediate containment and evidence preservation procedures
   - Step-by-step technical recovery with validation checkpoints
   - System-specific hardening recommendations and security improvements
   - Recovery timeline estimation with resource and expertise requirements
   - Post-remediation monitoring and success criteria definition

   Create actionable technical remediation plans that ensure thorough incident recovery while implementing preventive measures to strengthen security posture and reduce future risk.
   ```

### 🎯 AI Foundry Testing Scenarios

#### Test 1: Domain Controller Compromise

##### User Message for Domain Controller Testing

```text
Create comprehensive technical remediation plan for this critical infrastructure incident:

INCIDENT: Primary domain controller CORPDC01 compromised via privilege escalation attack. Attacker maintained access for 72 hours, created Golden Tickets, modified Group Policy, installed persistent backdoors, accessed SYSVOL share. 500+ domain users affected, authentication services degraded.

REQUIREMENTS:
- Immediate containment: Evidence preservation and isolation procedures.
- Technical recovery: Step-by-step domain controller rebuild and hardening.
- Validation procedures: Testing authentication services and security controls.
- Timeline estimation: Recovery phases with resource requirements.
- Hardening recommendations: Prevent similar future compromises.

TOKEN LIMIT: 400 tokens maximum
```

#### Expected AI Foundry Output Quality

- Specific technical procedures with command sequences and validation steps.
- Realistic recovery timelines based on system complexity.
- Evidence preservation considerations throughout remediation process.
- Comprehensive hardening measures to prevent re-compromise.

#### Test 2: Ransomware Recovery Scenario

##### User Message for Ransomware Testing

```text
Create detailed remediation plan for this enterprise ransomware incident:

INCIDENT: WannaCry variant encrypted 200+ workstations and 15 servers including file servers and email systems. Primary backup server also compromised. Offsite backups available but 48 hours old. Critical business systems offline, $100K ransom demand.

REQUIREMENTS:
- Technical recovery procedures with validation checkpoints.
- System rebuilding from clean backups and hardening measures.
- Network segmentation and monitoring improvements.
- Recovery timeline with realistic milestone estimates.

TOKEN LIMIT: 400 tokens maximum
```

#### Response Quality Metrics

Validate each AI Foundry test produces:

- [ ] **Technical Accuracy**: Procedures are technically sound and executable.
- [ ] **Evidence Preservation**: Forensic considerations maintained throughout.
- [ ] **Validation Completeness**: Testing procedures ensure complete remediation.
- [ ] **Token Compliance**: Response within 380-400 token range.
- [ ] **Hardening Focus**: Security improvements prevent similar incidents.

## Template Enhancement Context

Your AI Foundry model testing validated technical remediation capabilities. Logic Apps integration adds **automated remediation planning** for:

- System-specific recovery procedures from Defender XDR incidents.
- Technical validation steps and testing requirements.
- Recovery timeline estimation with resource planning.
- Security hardening recommendations tailored to incident types.

## Logic Apps Integration Quick Reference

This section provides the key data points needed to modify your Logic App being built in **02.06** to add remediation guidance capabilities. The detailed implementation steps will be covered in lab **02.07**.

### AI Foundry System Message Update

**First, update your AI Foundry deployment** with the remediation guidance system message from the testing section above. This ensures your model is optimized for technical remediation planning before Logic Apps integration.

1. **Navigate to Azure AI Foundry** → Your deployment → **Chat** interface
2. **Update System Message** with the comprehensive remediation guidance prompt from the testing section
3. **Test the updated configuration** using the provided test scenarios
4. **Validate technical accuracy and completeness** before proceeding to Logic Apps integration

### Logic App Configuration

Update the **Analyze Incident with AI** action in the logic app to use the following settings:

#### Message Configuration - Remediation Guidance

Replace your existing **messages** array with this JSON configuration for easy copy-paste:

```json
[
  {
    "role": "system",
    "content": "You are a senior security engineer specializing in incident response and technical remediation with expertise in enterprise infrastructure recovery. Focus on immediate containment procedures, step-by-step technical recovery with validation checkpoints, system-specific hardening recommendations, recovery timeline estimation with resource requirements, and post-remediation monitoring. Create actionable technical remediation plans that ensure thorough incident recovery while implementing preventive measures to strengthen security posture."
  },
  {
    "role": "user", 
    "content": "Create comprehensive technical remediation plan for this Defender XDR incident: Title: [INCIDENT_TITLE], Description: [INCIDENT_DESCRIPTION], Severity: [INCIDENT_SEVERITY]. OUTPUT 5 SECTIONS: **IMMEDIATE CONTAINMENT:** Critical isolation procedures and evidence preservation steps **TECHNICAL RECOVERY:** Step-by-step remediation with validation checkpoints **SYSTEM HARDENING:** Security improvements and configuration changes **RECOVERY VALIDATION:** Testing procedures and success criteria **TIMELINE & RESOURCES:** Recovery phases with expertise and resource requirements. REQUIREMENTS: Technically accurate procedures, evidence preservation, realistic timelines, TOKEN LIMIT: 400 tokens maximum."
  }
]
```

### Expected AI Response Structure

The AI will return structured output in this format:

```text
**IMMEDIATE CONTAINMENT:** [Containment and preservation content]

**TECHNICAL RECOVERY:** [Recovery procedures content]

**SYSTEM HARDENING:** [Hardening recommendations content]

**RECOVERY VALIDATION:** [Validation procedures content]

**TIMELINE & RESOURCES:** [Timeline and resource content]
```

### Comment Parsing Configuration

**Update your existing comment extraction actions** with this structured approach for remediation guidance:

#### Update Extract AI Analysis Sections (Existing Compose Action)

In your existing `Extract AI Analysis Sections` Compose action, **replace the current JSON content** with this remediation guidance configuration:

```json
{
  "immediateContainment": "@{first(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**TECHNICAL RECOVERY:**'))}",
  "technicalRecovery": "@{first(split(last(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**TECHNICAL RECOVERY:**')), '**SYSTEM HARDENING:**'))}",
  "systemHardening": "@{first(split(last(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**SYSTEM HARDENING:**')), '**RECOVERY VALIDATION:**'))}",
  "recoveryValidation": "@{first(split(last(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**RECOVERY VALIDATION:**')), '**TIMELINE & RESOURCES:**'))}",
  "timelineResources": "@{last(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**TIMELINE & RESOURCES:**'))}"
}
```

#### Update Create Comments Array (Existing Compose Action)

In your existing `Create Comments Array` Compose action, **replace the current JSON content** with this remediation guidance configuration:

```json
[
  {
    "prefix": "[Remediation - Containment]",
    "content": "@{outputs('Extract AI Analysis Sections')['immediateContainment']}",
    "order": 1
  },
  {
    "prefix": "[Remediation - Recovery]", 
    "content": "@{outputs('Extract AI Analysis Sections')['technicalRecovery']}",
    "order": 2
  },
  {
    "prefix": "[Remediation - Hardening]",
    "content": "@{outputs('Extract AI Analysis Sections')['systemHardening']}",
    "order": 3
  },
  {
    "prefix": "[Remediation - Validation]",
    "content": "@{outputs('Extract AI Analysis Sections')['recoveryValidation']}",
    "order": 4
  },
  {
    "prefix": "[Remediation - Timeline]",
    "content": "@{outputs('Extract AI Analysis Sections')['timelineResources']}",
    "order": 5
  }
]
```

### Cost Impact

| Metric | Default Setup | Remediation Template | Difference |
|--------|----------------------|--------------------|------------|
| **Cost per Incident** | ~$0.00018 | ~$0.00036 | **+$0.00018** (2x) |
| **Token Usage** | 180-200 tokens | 380-400 tokens | **+200 tokens** |
| **Execution Time** | 30-45 seconds | 90-150 seconds | **+60-105 seconds** |
| **Comments Generated** | 4 analysis comments | 5 remediation plans | **+1 comment** |

**Cost Justification**: The 2x cost increase provides comprehensive technical recovery guidance, potentially reducing incident resolution time by 40-60% and preventing costly re-compromises through improved hardening measures.

## Template Customization

Adapt this template for your infrastructure needs by customizing technology stacks, recovery procedures, organizational processes, and validation requirements to match your specific security operations environment.

### **Customization Areas**

**TECHNOLOGY STACK:**

- Customize for your specific operating systems and enterprise applications.
- Include your backup and recovery procedures and validation tools.
- Adapt for your network architecture and security control implementations.

**RECOVERY PROCEDURES:**

- Add your change management and approval processes for remediation activities.
- Include your testing and validation requirements for system restoration.
- Customize for your maintenance windows and business continuity requirements.

**ORGANIZATIONAL PROCESSES:**

- Include your incident response team structure and escalation procedures.
- Add your vendor relationships and external support arrangements.
- Customize for your skill requirements and training development needs.

**COMPLIANCE ENVIRONMENT:**

- Add your regulatory validation and documentation requirements.
- Include your audit control testing and evidence collection procedures.

---

## 🎯 Implementation Outcomes & Success Metrics

### **Expected Template Benefits**

- **Comprehensive Recovery Planning**: Generates complete technical remediation plans with validation checkpoints for thorough incident recovery.
- **Evidence-Aware Procedures**: Maintains forensic integrity while enabling effective system restoration and hardening.
- **Timeline Accuracy**: AI-driven recovery estimation reduces planning time by 60-70% while improving milestone reliability.
- **Hardening Integration**: Built-in security improvement framework reduces re-compromise risk by implementing preventive measures.

### **Comprehensive Validation Checklist**

**Phase 1: AI Foundry Testing** (Complete before Logic Apps integration):

- [ ] AI Foundry testing completed with 400-token technical responses.
- [ ] Technical accuracy validated in chat interface for multiple incident types.
- [ ] System message produces appropriate remediation depth and validation procedures.
- [ ] User message format tested with sample incident data.
- [ ] Token usage remains within 380-400 range.
- [ ] Evidence preservation considerations maintained throughout procedures.

**Phase 2: Logic Apps Integration** (Validate after 02.07 implementation):

- [ ] Remediation plans appear correctly in Defender XDR portal with technical accuracy.
- [ ] Comment parsing separates containment vs. recovery procedures appropriately.
- [ ] Token usage stays within cost parameters for technical guidance.
- [ ] Recovery timelines reflect realistic system complexity and resource requirements.
- [ ] Integration testing validates end-to-end workflow performance with technical teams.

---

## 🤖 AI-Assisted Content Generation

This comprehensive remediation guidance template was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating enterprise incident response best practices, Azure OpenAI integration patterns, and technical recovery procedures for security operations workflows.

*AI tools were used to enhance productivity and ensure comprehensive coverage of remediation planning strategies while maintaining technical accuracy and reflecting modern incident response practices for organizational security recovery operations.*
