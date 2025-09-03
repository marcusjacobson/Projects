# Stakeholder Communication Template

## Template Purpose

After successful AI Foundry testing, this template enables Logic Apps automation to create **multi-audience security communications** for different organizational levels and stakeholder groups.

## 🧪 Primary Testing Approach - AI Foundry Chat Interface

**Start here**: Test this template directly in Azure AI Foundry before Logic Apps integration to validate content quality and optimize token efficiency.

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
   You are a senior cybersecurity analyst specializing in multi-stakeholder incident communication and crisis management. Your expertise includes:

   RESEARCH & ANALYSIS METHODOLOGY:
   - Conduct rapid threat intelligence analysis using MITRE ATT&CK framework
   - Assess business impact across operational, financial, regulatory, and reputational dimensions
   - Evaluate incident scope, containment status, and recovery timeline requirements
   - Analyze stakeholder-specific concerns and communication needs based on organizational roles

   COMMUNICATION SPECIALIZATION AREAS:
   - Technical teams: Focus on immediate response procedures, forensic requirements, and system recovery actions
   - Business leadership: Emphasize operational continuity, resource allocation, and departmental coordination needs
   - Executive management: Provide strategic risk assessment, financial impact estimates, and decision-point identification
   - Customer communications: Balance transparency with reassurance, focusing on service impact and data protection
   - Regulatory compliance: Address notification requirements, cooperation protocols, and documentation obligations

   ANALYSIS FRAMEWORK:
   - Incident severity and business criticality assessment
   - Multi-audience risk communication with appropriate technical depth
   - Actionable next steps tailored to each stakeholder's authority and responsibility
   - Timeline coordination to prevent conflicting messages across communication channels
   - Professional tone that builds confidence while maintaining transparency about security measures

   Create structured, audience-appropriate security communications that enable effective organizational response and maintain stakeholder trust throughout incident management.
   ```

### 🎯 AI Foundry Testing Scenarios

#### Test 1: Critical Infrastructure Incident

##### User Message for Critical Infrastructure Testing

```text
Create multi-audience security communications for this critical domain controller incident:

INCIDENT: Primary domain controller CORPDC01 compromised via advanced persistent threat. Attacker maintained access for 48 hours, deployed backdoors, accessed Active Directory database, modified group policies affecting 2,500 users. Secondary DC isolated. All administrative credentials suspected compromised.

REQUIREMENTS:
- Technical teams: Detailed procedures and immediate actions.
- Business leadership: Operational impact and resource needs.
- Executive management: Strategic implications and decisions.
- Customer communication: Service impact and reassurance.
- Regulatory communication: Compliance obligations.
- Communication timeline: Sequenced notification schedule.

TOKEN LIMIT: 400 tokens maximum
```

#### Expected AI Foundry Output Quality

- Clear audience segmentation with appropriate language levels.
- Consistent incident facts across all communications.
- Action-oriented messaging with specific next steps.
- Professional tone balancing transparency with confidence.

#### Test 2: Data Exposure Scenario

##### User Message for Data Exposure Testing

```text
Create stakeholder communications for this data exposure incident:

INCIDENT: Customer database backup exposed on public cloud for 72 hours. 15,000 customer records affected (names, emails, phones, encrypted payment tokens). No evidence of external access but exposure window confirmed.

REQUIREMENTS:
- Multi-audience messaging (technical, business, executive, customer, regulatory).
- Customer trust preservation approach.
- Regulatory compliance messaging.
- Timeline coordination.

TOKEN LIMIT: 400 tokens maximum
```

#### Response Quality Metrics

Validate each AI Foundry test produces:

- [ ] **Audience Differentiation**: Distinct language and detail levels.
- [ ] **Message Consistency**: Core facts aligned across audiences.
- [ ] **Actionable Content**: Clear next steps for each stakeholder group.
- [ ] **Token Compliance**: Response within 380-400 token range.
- [ ] **Professional Tone**: Confidence-building yet transparent messaging.

## Template Enhancement Context

Your AI Foundry model testing validated cybersecurity communication capabilities. Logic Apps integration adds **automated stakeholder communication** for:

- Multi-audience message generation from Defender XDR incidents.
- Audience-specific language adaptation and tone optimization.
- Risk communication frameworks for organizational stakeholders.
- Action item prioritization by audience responsibility and authority.

## Logic Apps Integration Quick Reference

This section provides the key data points needed to modify your Logic App being built in **02.06** to add stakeholder communication capabilities. The detailed implementation steps will be covered in lab **02.07**.

### AI Foundry System Message Update

**First, update your AI Foundry deployment** with the stakeholder communication system message from the testing section above. This ensures your model is optimized for multi-audience communication before Logic Apps integration.

1. **Navigate to Azure AI Foundry** → Your deployment → **Chat** interface
2. **Update System Message** with the comprehensive stakeholder communication prompt from the testing section
3. **Test the updated configuration** using the provided test scenarios
4. **Validate multi-audience output quality** before proceeding to Logic Apps integration

### Logic App Configuration

Update the **Analyze Incident with AI** action in the logic app to use the following settings:

#### Message Configuration - Stakeholder Communications

Replace your existing **messages** array with this JSON configuration for easy copy-paste:

```json
[
  {
    "role": "system",
    "content": "You are a senior cybersecurity analyst specializing in multi-stakeholder incident communication and crisis management. Your expertise includes rapid threat intelligence analysis using MITRE ATT&CK framework, business impact assessment across operational/financial/regulatory dimensions, and stakeholder-specific communication tailored to organizational roles. Focus on: Technical teams (immediate response procedures), Business leadership (operational continuity), Executive management (strategic risk assessment), Customer communications (service impact with reassurance), Regulatory compliance (notification requirements). Provide structured, audience-appropriate communications that enable effective organizational response while maintaining stakeholder trust."
  },
  {
    "role": "user", 
    "content": "Create multi-audience security communications for this Defender XDR incident: Title: [INCIDENT_TITLE], Description: [INCIDENT_DESCRIPTION], Severity: [INCIDENT_SEVERITY]. OUTPUT 5 SECTIONS: **TECHNICAL TEAMS:** Detailed procedures and immediate technical actions required **BUSINESS LEADERSHIP:** Operational impact assessment and resource coordination needs **EXECUTIVE MANAGEMENT:** Strategic implications, decisions required, and cost estimates **CUSTOMER COMMUNICATION:** Service impact messaging with reassurance and transparency **REGULATORY COMMUNICATION:** Compliance obligations and formal notification requirements. REQUIREMENTS: Audience-appropriate language, consistent core facts, action-oriented messaging, professional tone, TOKEN LIMIT: 400 tokens maximum."
  }
]
```

### Expected AI Response Structure

The AI will return structured output in this format:

```text
**TECHNICAL TEAMS:** [Technical response content]

**BUSINESS LEADERSHIP:** [Business leadership content]

**EXECUTIVE MANAGEMENT:** [Executive management content]

**CUSTOMER COMMUNICATION:** [Customer communication content]

**REGULATORY COMMUNICATION:** [Regulatory communication content]
```

### Comment Parsing Configuration

**Update your existing comment extraction actions** with this structured approach for stakeholder communications:

#### Update Extract AI Analysis Sections (Existing Compose Action)

In your existing `Extract AI Analysis Sections` Compose action, **replace the current JSON content** with this stakeholder communication configuration:

```json
{
  "technicalTeams": "@{first(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**BUSINESS LEADERSHIP:**'))}",
  "businessLeadership": "@{first(split(last(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**BUSINESS LEADERSHIP:**')), '**EXECUTIVE MANAGEMENT:**'))}",
  "executiveManagement": "@{first(split(last(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**EXECUTIVE MANAGEMENT:**')), '**CUSTOMER COMMUNICATION:**'))}",
  "customerCommunication": "@{first(split(last(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**CUSTOMER COMMUNICATION:**')), '**REGULATORY COMMUNICATION:**'))}",
  "regulatoryCommunication": "@{last(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**REGULATORY COMMUNICATION:**'))}"
}
```

#### Update Create Comments Array (Existing Compose Action)

In your existing `Create Comments Array` Compose action, **replace the current JSON content** with this stakeholder communication configuration:

```json
[
  {
    "prefix": "[Stakeholder - Technical]",
    "content": "@{outputs('Extract AI Analysis Sections')['technicalTeams']}",
    "order": 1
  },
  {
    "prefix": "[Stakeholder - Business]", 
    "content": "@{outputs('Extract AI Analysis Sections')['businessLeadership']}",
    "order": 2
  },
  {
    "prefix": "[Stakeholder - Executive]",
    "content": "@{outputs('Extract AI Analysis Sections')['executiveManagement']}",
    "order": 3
  },
  {
    "prefix": "[Stakeholder - Customer]",
    "content": "@{outputs('Extract AI Analysis Sections')['customerCommunication']}",
    "order": 4
  },
  {
    "prefix": "[Stakeholder - Regulatory]",
    "content": "@{outputs('Extract AI Analysis Sections')['regulatoryCommunication']}",
    "order": 5
  }
]
```

### Cost Impact

| Metric | Default Setup | Stakeholder Template | Difference |
|--------|----------------------|---------------------|------------|
| **Cost per Incident** | ~$0.00018 | ~$0.00036 | **+$0.00018** (2x) |
| **Token Usage** | 180-200 tokens | 380-400 tokens | **+200 tokens** |
| **Execution Time** | 30-45 seconds | 90-150 seconds | **+60-105 seconds** |
| **Comments Generated** | 4 technical comments | 5 stakeholder communications | **+1 comment** |

**Cost Justification**: The 2x cost increase provides 5x communication value through multi-audience coverage, potentially reducing manual stakeholder communication costs by $500-2000 per major incident.

## Template Customization

Adapt this template for your organizational needs by customizing stakeholder groups, communication channels, regulatory requirements, and organizational hierarchy to match your specific security operations structure.

### **Customization Areas**

**ORGANIZATIONAL HIERARCHY:**

- Customize for your specific management structure and reporting relationships.
- Include your communication protocols and approval processes.
- Adapt for your corporate culture and communication preferences.

**STAKEHOLDER MAPPING:**

- Add your specific stakeholder groups and communication requirements.
- Include your external partner and vendor communication procedures.
- Customize for your customer base and market positioning.

**COMMUNICATION CHANNELS:**

- Include your preferred communication tools and platforms.
- Add your crisis communication procedures and backup channels.
- Customize for your geographic and time zone considerations.

**REGULATORY ENVIRONMENT:**

- Add your specific regulatory relationships and notification requirements.
- Include your legal and compliance review procedures.

---

## 🎯 Implementation Outcomes & Success Metrics

### **Expected Template Benefits**

- **Multi-Audience Efficiency**: Generates 5 stakeholder-specific communications simultaneously from a single incident.
- **Consistent Messaging**: Ensures aligned core facts across all organizational levels while adapting language appropriately.
- **Automated Triage**: AI-driven prioritization reduces manual communication effort by 70-80%.
- **Compliance Support**: Built-in regulatory communication framework reduces legal review time.

### **Comprehensive Validation Checklist**

**Phase 1: AI Foundry Testing** (Complete before Logic Apps integration):

- [ ] AI Foundry testing completed with 400-token responses.
- [ ] Multi-audience content validated in chat interface.
- [ ] System message produces appropriate stakeholder segmentation.
- [ ] User message format tested with sample incident data.
- [ ] Token usage remains within 380-400 range.
- [ ] Professional tone maintained across all stakeholder communications.

**Phase 2: Logic Apps Integration** (Validate after 02.07 implementation):

- [ ] Stakeholder communications appear correctly in Defender XDR portal.
- [ ] Comment parsing separates technical vs. executive messaging appropriately.
- [ ] Token usage stays within cost parameters.
- [ ] Customer communications maintain appropriate transparency.
- [ ] Integration testing validates end-to-end workflow performance.

---

## 🤖 AI-Assisted Content Generation

This comprehensive stakeholder communication template was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating multi-audience crisis communication best practices, Azure OpenAI integration patterns, and enterprise security operations workflows.

*AI tools were used to enhance productivity and ensure comprehensive coverage of stakeholder communication strategies while maintaining technical accuracy and reflecting modern security operations practices for organizational incident response.*
