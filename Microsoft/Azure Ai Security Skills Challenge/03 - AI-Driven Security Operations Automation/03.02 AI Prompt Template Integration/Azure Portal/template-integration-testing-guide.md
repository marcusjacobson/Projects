# SOC AI Analysis Integration Testing Guide - Azure Portal

This guide provides a systematic approach to test SOC-focused AI prompt templates within your existing Logic App from Module 03.01. **The primary goal is to enhance Microsoft Defender XDR alert comments with AI-generated analysis that reduces SOC analyst investigation effort by providing immediate, actionable security insights directly within alert details.**

## 🎯 Core Purpose: Enhanced Defender Alert Comments for SOC Efficiency

### Alert Comment Enhancement Strategy

**Target Audience**: SOC Analysts requiring immediate, actionable security analysis within Defender XDR alert comments.

**Primary Objective**: Reduce time-to-investigation by embedding AI-generated analysis directly into Defender alert comments, eliminating the need for analysts to perform initial triage research manually.

**Comment Character Optimization**: All templates are optimized to remain within Microsoft Graph API's ~1000 character limit per alert comment while delivering maximum operational value through multi-comment structured analysis.

> **⚠️ Character Limit Warning**: While every effort has been made to optimize templates for Microsoft Graph API's ~1000 character limit per alert comment, truncation may still occur based on AI model responses. The templates include explicit character guidance and token limits to minimize this risk, but AI-generated content can vary in length. If truncation occurs, consider:
>
> - **Reducing token limits** further (from 350-400 to 250-300 tokens)
> - **Simplifying prompt requirements** to request more concise responses
> - **Testing with multiple incident types** to identify patterns that cause longer responses
> - **Monitoring actual character counts** in Defender XDR alert comments during testing

### What You'll Accomplish

- **SOC Template Testing**: Systematically test specialized AI prompt templates that generate actionable alert comment analysis optimized for security operations center workflows.
- **Alert Comment Validation**: Verify that AI-generated comments remain within character limits while providing comprehensive analysis through structured multi-comment delivery.
- **Investigation Efficiency**: Document how enhanced alert comments reduce initial investigation time and improve incident response quality.
- **Optimal Template Mapping**: Identify which templates work best for different alert types and provide the most valuable insights within Defender alert comment constraints.

### SOC-Focused Testing Strategy for Alert Comment Enhancement

Each template test follows this pattern optimized for Defender alert comment integration and SOC analyst workflow efficiency:

1. **Clear Previous Alerts**: Resolve any existing Defender XDR incidents to ensure clean testing environment.
2. **Generate Fresh Alerts**: Create new sample alerts in Defender for Cloud to provide consistent testing data.
3. **Wait for Consolidation**: Allow 5-10 minutes for alerts to propagate to Defender XDR as consolidated incidents.
4. **Modify Logic App**: Update with specific SOC-focused template content optimized for alert comment character limits.
5. **Test and Document**: Run Logic App and validate that enhanced alert comments provide immediate operational value while remaining within character constraints.

**Character Limit Validation**: Each template test includes verification that AI-generated comments remain under the ~1000 character Microsoft Graph API limit per comment while delivering comprehensive analysis through structured multi-comment formatting.

## 🎯 Prerequisites

### Required Completion

- [x] **Module 03.01**: Azure OpenAI + Defender XDR Integration deployed and operational
- [x] **Week 2 Module 02.05**: AI Prompt Templates created and validated
- [x] **Active Azure Environment**: Defender for Cloud and Defender XDR enabled

## 🧪 Template Testing Workflow

### Testing Process Overview

For each template, you'll modify **three specific actions** in your Logic App:

1. **System Message** (Role definition).
2. **User Message Template** (Analysis request format).
3. **Max Tokens Setting** (Response length optimization).

### Logic App Actions to Modify

| Action Name | Location in Logic App | What to Change |
|-------------|----------------------|----------------|
| **Generate AI Analysis** | Inside For Each loop | System message and User message content |
| **Extract AI Analysis Sections** | Inside For Each loop | Parsing logic for template-specific sections |
| **Create Comments Array** | Inside For Each loop | Comment formatting for template outputs |

> **🔧 Critical Integration Requirements**: Each template requires updating **both the Messages array AND the two Compose actions** (Extract AI Analysis Sections + Create Comments Array) to properly parse and display the AI response in Defender XDR. These Compose action updates are essential for structured comment display.

## 🎭 SOC Template Testing Schedule

### Recommended Testing Order for Security Operations

Test templates in this order optimized for SOC analyst workflow and operational efficiency:

| Order | Template | SOC Purpose | AI Analysis Output Sections | Character Optimization |
|-------|----------|-------------|---------------------------|------------------------|
| **1** | [Incident Classification](#-template-1-incident-classification) | Rapid triage & severity assessment | Classification, Business Impact, Response Priority, False Positive Analysis | 4 sections, 350 tokens |
| **2** | [Threat Hunting Analysis](#-template-2-threat-hunting-analysis) | Technical investigation & IOC analysis | Threat Assessment, Attack Analysis, Hunt Queries, IOC Monitoring | 4 sections, 400 tokens |
| **3** | [Risk Assessment](#-template-3-risk-assessment) | Business impact scoring | Risk Score, Business Impact, Strategic Implications, Mitigation Priorities | 4 sections, 350 tokens |
| **4** | [Compliance Analysis](#-template-4-compliance-analysis) | Regulatory compliance analysis | Regulatory Impact, Compliance Gaps, AI Governance, Remediation Priorities | 6 sections, 400 tokens |
| **5** | [Incident Response Coordination](#-template-5-incident-response-coordination) | Multi-team response coordination | Incident Classification, Immediate Actions, Containment Procedures, Investigation Coordination | 4 sections, 400 tokens |
| **6** | [Remediation Guidance](#-template-6-remediation-guidance) | Technical recovery procedures | Immediate Containment, Technical Recovery, System Hardening, Recovery Validation | 4 sections, 400 tokens |

> **📋 Note**: Executive communication templates (Executive Summary, Stakeholder Communication) are covered in **Module 03.03: Executive AI Communication & Reporting** for comprehensive document generation rather than alert comment integration.

### Alert Generation Strategy

Before each template test:

1. **Navigate to Defender XDR Portal**: [https://security.microsoft.com](https://security.microsoft.com).
2. **Resolve All Active Incidents**: Mark all current incidents as resolved.
3. **Generate Fresh Alerts**: Use one of these methods:
   - **Network Activity**: Generate failed login attempts or suspicious network connections.
   - **File Activity**: Create suspicious file downloads or executions.
   - **Security Configuration**: Trigger security policy violations.
   - **Access Control**: Generate unauthorized access attempts.
4. **Wait for Propagation**: Allow 5-10 minutes for new alerts to consolidate into multi-stage incidents.
5. **Verify New Incidents**: Confirm fresh incidents appear in Defender XDR before testing.

---

## 🔍 Template 1: Incident Classification

### Purpose

Test the general incident triage and severity assessment template for rapid alert processing and false positive detection.

### Alert Generation Recommendation

**Recommended Defender for Cloud Plans for This Template**:

- **Virtual Machines** - Generates authentication failures, security configuration issues, and policy violations ideal for triage analysis
- **Storage Accounts** - Produces data access alerts and configuration drift incidents suitable for classification
- **Azure SQL Databases** - Creates authentication and access control alerts perfect for severity assessment

### Logic App Modifications

#### 1. Update Messages Array

Navigate to your Logic App → **Generate AI Analysis* action → **Messages** section:

> **📝 Note**: This action may have a different name if you chose custom naming during Module 03.01 deployment. Look for the Azure OpenAI action that creates chat completions within your "For Each Incident" loop.
> **⚠️ Important - Messages Array Configuration**: Before pasting the JSON below, ensure the **Messages** field is configured in **JSON view** (Input entire array) rather than **detail inputs** mode (detail inputs for array item). In the Logic Apps designer, look for toggle options near the Messages field that allow you to switch between these input modes. JSON view is required for proper array configuration.

Replace the entire messages array with:

```json
[
  {
    "role": "system",
    "content": "You are an expert cybersecurity analyst specializing in rapid incident triage and classification. Provide concise, actionable incident assessment focused on immediate SOC operations. Each section must be under 650 characters to fit within Defender alert comment limits while delivering essential classification guidance within exactly 350 tokens. Focus on essential assessment criteria only."
  },
  {
    "role": "user",
    "content": "INCIDENT CLASSIFICATION REQUEST:\n\nProvide rapid triage classification for immediate SOC implementation:\n\nINCIDENT DETAILS:\nTitle: @{item()?['displayName']}\nDescription: @{item()?['description']}\nSeverity: @{item()?['severity']}\n\nSTRICT OUTPUT FORMAT (each section max 650 chars, focus on essential assessment):\n**INCIDENT CLASSIFICATION:**\nSeverity level (CRITICAL/HIGH/MEDIUM/LOW/INFORMATIONAL) with primary threat indicators only.\n\n**BUSINESS IMPACT:**\nImmediate operational and data risk assessment with key business implications only.\n\n**RESPONSE PRIORITY:**\nUrgency level, escalation requirements, and containment timeline only.\n\n**CONFIDENCE ASSESSMENT:**\nConfidence score (0.0-1.0), false positive likelihood, and key evidence supporting classification only."
  }
]
```

##### Update Max Tokens Setting

**Why 350 tokens?** Classification analysis focuses on structured, concise triage outputs including severity assessment, confidence scoring, and false positive analysis. The balanced token limit ensures comprehensive classification without unnecessary verbosity, optimizing for rapid incident processing.

In the **Advanced parameters** → **max_tokens**: Change to `350`

### Expected Results

**Analysis Focus**:

- Clear severity classification with confidence scoring.
- False positive assessment with supporting evidence.
- Business impact evaluation and resource allocation guidance.
- Immediate action recommendations with timeline expectations.

**Token Usage**: ~280-320 tokens per analysis

#### 2. Update Extract AI Analysis Sections (Compose Action)

Navigate to your Logic App → **Extract AI Analysis Sections** action (Compose action within your For Each loop):

> **📝 Note**: This Compose action may have a different name if you chose custom naming during Module 03.01 deployment. Look for the Compose action that parses the AI response into structured sections.

Replace the existing JSON content with this incident classification configuration:

```json
{
  "classification": "@{first(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**BUSINESS IMPACT:**'))}",
  "businessImpact": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**BUSINESS IMPACT:**')), '**RESPONSE PRIORITY:**'))}",
  "responsePriority": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**RESPONSE PRIORITY:**')), '**CONFIDENCE ASSESSMENT:**'))}",
  "confidenceAssessment": "@{last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**CONFIDENCE ASSESSMENT:**'))}"
}
```

#### 3. Update Create Comments Array (Compose Action)

Navigate to your Logic App → **Create Comments Array** action (Compose action within your For Each loop):

> **📝 Note**: This Compose action may have a different name if you chose custom naming during Module 03.01 deployment. Look for the Compose action that creates the comment array for Defender XDR.

Replace the existing JSON content with this incident classification configuration:

```json
[
  {
    "prefix": "[Classification - Severity]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['classification']}",
    "order": 1
  },
  {
    "prefix": "[Classification - Business Impact]", 
    "content": "@{outputs('Extract_AI_Analysis_Sections')['businessImpact']}",
    "order": 2
  },
  {
    "prefix": "[Classification - Response Priority]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['responsePriority']}",
    "order": 3
  },
  {
    "prefix": "[Classification - Confidence]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['confidenceAssessment']}",
    "order": 4
  }
]
```

### Classification Template - Sample Expected Alert Comments

After running your Logic App with this template, you should see comments similar to these in your Defender XDR incident. Specific results may vary when using AI analysis.

**[Classification - Severity]**

```text
**INCIDENT CLASSIFICATION:** HIGH
Multi-stage attack pattern detected with execution and evasion tactics indicating advanced persistent threat behavior. Primary threat indicators include credential harvesting attempts and lateral movement preparation. Severity justified by sophistication level and potential system access.
```

**[Classification - Business Impact]**

```text
Significant risk to sensitive data integrity and potential regulatory non-compliance. Immediate threat to business operations due to credential compromise activities. High potential for operational disruption and reputational damage if successful.
```

**[Classification - Response Priority]**

```text
Immediate human intervention required. Escalate to incident response team and notify stakeholders. Containment actions should be initiated within 1 hour. Automated response actions include account isolation and network monitoring enhancement.
```

**[Classification - Confidence]**

```text
0.85 - High confidence in classification due to multi-stage attack pattern indicators. False positive likelihood moderate (30%) due to potential benign process misclassification. Evidence supports high severity: execution tactics, credential targeting, and evasion techniques observed.
```

---

## 🔍 Template 2: Threat Hunting Analysis

### Threat Hunting Purpose

Test the advanced threat hunting template focusing on technical investigation, MITRE ATT&CK mapping, and sophisticated attack pattern analysis.

### Threat Hunting Alert Generation

**Recommended Defender for Cloud Plans for This Template**:

- **Virtual Machines** - Generates suspicious process execution, lateral movement indicators, and malware detection alerts
- **Containers** - Produces container runtime threats, malicious image deployment, and Kubernetes attack patterns
- **DNS** - Creates DNS tunneling, domain generation algorithm (DGA), and command & control communication alerts

### Threat Hunting Logic App Modifications

#### 1. Update Threat Hunting Messages

Navigate to the **Generate AI Analysis** action in your Logic App and replace the complete messages array with:

> **📝 Note**: This action may have a different name if you chose custom naming during Module 03.01 deployment. Look for the Azure OpenAI action that creates chat completions within your "For Each Incident" loop.
> **⚠️ Important - Messages Array Configuration**: Before pasting the JSON below, ensure the **Messages** field is configured in **JSON view** (Input entire array) rather than **detail inputs** mode (detail inputs for array item). In the Logic Apps designer, look for toggle options near the Messages field that allow you to switch between these input modes. JSON view is required for proper array configuration.

```json
[
    {
        "role": "system",
        "content": "You are a cybersecurity threat hunting specialist specializing in rapid MITRE ATT&CK analysis and IOC extraction for SOC operations. Provide concise, actionable threat hunting analysis focused on immediate operational value. Each section must be under 650 characters to fit within Defender alert comment limits while delivering essential threat hunting guidance within exactly 350 tokens. Focus on essential analysis only."
    },
    {
        "role": "user",
        "content": "THREAT HUNTING ANALYSIS REQUEST:\n\nProvide rapid threat hunting analysis for immediate SOC implementation:\n\nINCIDENT DETAILS:\nTitle: @{item()?['displayName']}\nDescription: @{item()?['description']}\nSeverity: @{item()?['severity']}\n\nSTRICT OUTPUT FORMAT (each section max 650 chars, essential analysis only):\n**THREAT ASSESSMENT:**\nAttack sophistication, threat actor profile, and campaign attribution only.\n\n**MITRE ATT&CK MAPPING:**\nTop 3-4 technique IDs with brief descriptions only. Format: T####.### - Brief description\n\n**IOC ANALYSIS:**\nCritical IOCs with context AND specific hunt guidance: IOC_TYPE: value (threat level, confidence, priority). Include what to search for in logs.\n\n**HUNTING QUERIES:**\nBasic starter KQL queries only - single table, essential filters. Keep queries under 200 characters each."
    }
]
```

##### Update Threat Hunting Max Tokens Setting

**Why 350 tokens?** Threat hunting analysis focuses on essential IOC extraction, concise MITRE ATT&CK mapping, and actionable KQL queries. The reduced token limit ensures comprehensive analysis without verbose KQL query comments that cause truncation, optimizing for rapid threat hunting operations.

In the **Advanced parameters** → **max_tokens**: Change to `350`

#### 2. Update Extract AI Analysis Sections for Threat Hunting (Compose Action)

Navigate to your Logic App → **Extract AI Analysis Sections** action (Compose action within your For Each loop):

Replace the existing JSON content with this threat hunting configuration:

```json
{
  "threatAssessment": "@{first(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**MITRE ATT&CK MAPPING:**'))}",
  "attackAnalysis": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**MITRE ATT&CK MAPPING:**')), '**IOC ANALYSIS:**'))}",
  "iocAnalysis": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**IOC ANALYSIS:**')), '**HUNTING QUERIES:**'))}",
  "huntingQueries": "@{last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**HUNTING QUERIES:**'))}"
}
```

#### 3. Update Create Comments Array for Threat Hunting (Compose Action)

Navigate to your Logic App → **Create Comments Array** action (Compose action within your For Each loop):

Replace the existing JSON content with this threat hunting configuration:

```json
[
  {
    "prefix": "[Hunt - Threat Assessment]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['threatAssessment']}",
    "order": 1
  },
  {
    "prefix": "[Hunt - Attack Analysis]", 
    "content": "@{outputs('Extract_AI_Analysis_Sections')['attackAnalysis']}",
    "order": 2
  },
  {
    "prefix": "[Hunt - IOC Monitoring]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['iocAnalysis']}",
    "order": 3
  },
  {
    "prefix": "[Hunt - KQL Queries]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['huntingQueries']}",
    "order": 4
  }
]
```

### Threat Hunting Expected Results

**Analysis Focus**:

- Concise MITRE ATT&CK technique mapping with essential IDs only.
- Critical IOC extraction with operational context AND hunt guidance for what to search for.
- Basic starter KQL queries under 200 characters each - single table focus.
- Character limit optimized format preventing truncation with hunt guidance distributed across sections.

**Token Usage**: ~280-330 tokens per analysis

**KQL Strategy**: Provide essential starter queries while embedding detailed hunt guidance in IOC Analysis section to maximize character efficiency.

### Threat Hunting Template - Sample Expected Alert Comments

After running your Logic App with this template, you should see comments similar to these in your Defender XDR incident:

**[Hunt - Threat Assessment]**

```text
THREAT ASSESSMENT:
Attack sophistication: INTERMEDIATE - Uses common credential stuffing tools with enterprise targeting. Threat actor profile: Financially motivated cybercriminal group based on TTPs. Campaign attribution: Possible APT28-style credential harvesting operation targeting enterprise authentication systems.
```

**[Hunt - Attack Analysis]**

```text
MITRE ATT&CK MAPPING:
- T1110.001 (Brute Force: Password Guessing) - Multiple authentication failures
- T1078 (Valid Accounts) - Credential stuffing attempts  
- T1021.001 (Remote Services: RDP) - Remote desktop protocol usage
- T1082 (System Information Discovery) - System reconnaissance activity
```

**[Hunt - KQL Queries]**

```text
HUNTING QUERIES:
// Hunt authentication failures
SecurityEvent | where EventID == 4625 | summarize count() by Account, IpAddress

// Check successful logins from flagged IPs  
SigninLogs | where IPAddress in (dynamic(["192.168.1.100"])) | project TimeGenerated, UserPrincipalName

// Process execution monitoring
DeviceProcessEvents | where ProcessCommandLine contains "powershell" | project Timestamp, DeviceName, ProcessCommandLine
```

**[Hunt - IOC Monitoring]**

```text
IOC ANALYSIS:
IP_ADDRESS: 192.168.1.100 (C2 infrastructure, HIGH confidence, BLOCK immediately) - Hunt: Search firewall logs, proxy logs, DNS queries
IP_ADDRESS: 203.0.113.5 (TOR exit node, MEDIUM confidence, MONITOR) - Hunt: Check for outbound connections, unusual traffic patterns  
USER_ACCOUNT: john.doe@company.com (credential target, HIGH confidence, RESET password) - Hunt: Authentication logs, privilege usage, file access
DOMAIN: malicious-domain.com (APT infrastructure, HIGH confidence, BLOCK) - Hunt: DNS resolution logs, web proxy traffic
Actions: Deploy blocks, reset passwords, enhance monitoring for IOC patterns above.
```

---

## 🔍 Template 3: Risk Assessment

### Risk Assessment Purpose

Test the business impact evaluation template focusing on risk scoring, business context, and organizational impact assessment.

### Risk Assessment Alert Generation

**Recommended Defender for Cloud Plans for This Template**:

- **Storage Accounts** - Generates data exposure incidents, unauthorized access attempts, and data exfiltration alerts
- **Azure SQL Databases** - Produces privilege escalation attempts, SQL injection attacks, and sensitive data access violations
- **Key Vaults** - Creates cryptographic key access violations and certificate management security alerts

### Risk Assessment Logic App Modifications

#### 1. Update Risk Assessment Messages

Navigate to the **Generate AI Analysis** action in your Logic App and replace the complete messages array with:

> **📝 Note**: This action may have a different name if you chose custom naming during Module 03.01 deployment. Look for the Azure OpenAI action that creates chat completions within your "For Each Incident" loop.
> **⚠️ Important - Messages Array Configuration**: Before pasting the JSON below, ensure the **Messages** field is configured in **JSON view** (Input entire array) rather than **detail inputs** mode (detail inputs for array item). In the Logic Apps designer, look for toggle options near the Messages field that allow you to switch between these input modes. JSON view is required for proper array configuration.

```json
[
    {
        "role": "system",
        "content": "You are a cybersecurity risk analyst. Provide concise risk assessment with quantitative scoring. Each section under 650 characters. Use exactly this format with section headers."
    },
    {
        "role": "user",
        "content": "Risk assessment needed:\n\nAlert: @{item()?['displayName']}\nDescription: @{item()?['description']}\nSeverity: @{item()?['severity']}\n\nProvide analysis in this exact format:\n\n**RISK SCORE:**\n[Risk level with score]\n\n**BUSINESS IMPACT:**\n[Business impact details]\n\n**STRATEGIC IMPLICATIONS:**\n[Strategic considerations]\n\n**MITIGATION PRIORITIES:**\n[Priority actions]"
    }
]
```

##### Update Risk Assessment Max Tokens Setting

**Why 350 tokens?** Risk assessment analysis focuses on essential business impact evaluation, quantitative scoring, and mitigation priorities. The reduced token limit ensures comprehensive analysis without verbose explanations that cause parsing failures, optimizing for reliable section extraction.

In the **Advanced parameters** → **max_tokens**: Change to `350`

#### 2. Update Extract AI Analysis Sections for Risk Assessment (Compose Action)

Navigate to your Logic App → **Extract AI Analysis Sections** action (Compose action within your For Each loop):

Replace the existing JSON content with this risk assessment configuration:

```json
{
  "riskScore": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**RISK SCORE:**')), '**BUSINESS IMPACT:**'))}",
  "businessImpact": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**BUSINESS IMPACT:**')), '**STRATEGIC IMPLICATIONS:**'))}",
  "strategicImplications": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**STRATEGIC IMPLICATIONS:**')), '**MITIGATION PRIORITIES:**'))}",
  "mitigationPriorities": "@{last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**MITIGATION PRIORITIES:**'))}"
}
```

#### 3. Update Create Comments Array for Risk Assessment (Compose Action)

Navigate to your Logic App → **Create Comments Array** action (Compose action within your For Each loop):

Replace the existing JSON content with this risk assessment configuration:

```json
[
  {
    "prefix": "[Risk - Quantitative Score]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['riskScore']}",
    "order": 1
  },
  {
    "prefix": "[Risk - Business Impact]", 
    "content": "@{outputs('Extract_AI_Analysis_Sections')['businessImpact']}",
    "order": 2
  },
  {
    "prefix": "[Risk - Strategic Impact]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['strategicImplications']}",
    "order": 3
  },
  {
    "prefix": "[Risk - Mitigation Plan]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['mitigationPriorities']}",
    "order": 4
  }
]
```

### Risk Assessment Expected Results

**Analysis Focus**:

- Quantitative risk scoring with essential methodology factors.
- Business impact evaluation with operational and financial analysis.
- Strategic implications and regulatory compliance assessment.
- Time-bound mitigation priorities with specific action items.

**Token Usage**: ~280-330 tokens per analysis

### Risk Assessment Template - Sample Expected Alert Comments

After running your Logic App with this template, you should see comments similar to these in your Defender XDR incident:

**[Risk - Quantitative Score]**

```text
RISK SCORE: 78/100 (HIGH RISK)
Key factors: Threat level (8/10), vulnerability exposure (9/10), asset criticality (8/10). Probability of exploitation: 45% within 48 hours. Impact magnitude: $500K-$2M potential loss. Risk tolerance exceeded - organizational threshold is 60/100 for critical assets.
```

**[Risk - Business Impact]**

```text
BUSINESS IMPACT:
Financial: $125K incident response costs, GDPR fines up to $2M, 5-15% customer churn estimate. Operational: 4-8 hour service degradation, 200 staff hours remediation. Recovery Time: 4 hours maximum downtime. Dependencies: Customer authentication, payment processing affected. Stakeholder Impact: 50,000 customers, 25 partners, 500 employees require notification.
```

**[Risk - Strategic Impact]**

```text
STRATEGIC IMPLICATIONS:
Risk Appetite: EXCEEDED - incident surpasses board-approved thresholds for customer data protection. Regulatory: GDPR Article 33 notification mandatory, PCI DSS investigation required, SOC 2 audit findings likely. Competitive Position: Security differentiator at risk, customer trust declining. Q4 acquisition targets may drop 15-25% if breach becomes public.
```

**[Risk - Mitigation Plan]**

```text
IMMEDIATE (0-4h): Contain exposure, isolate systems, legal notification procedures, crisis team mobilization.
SHORT-TERM (1-7d): Forensic investigation, customer notification, regulatory communication, media coordination.
STRATEGIC (1-3m): Zero-trust acceleration ($500K budget), SOC enhancement, compliance program advancement, trust rebuilding initiative.
```

---

## 🔍 Template 4: Compliance Analysis

### Compliance Analysis Purpose

Test the regulatory compliance evaluation template focusing on framework mapping, audit implications, and compliance risk assessment.

### Compliance Analysis Alert Generation

**Recommended Defender for Cloud Plans for This Template**:

- **Storage Accounts** - Generates data privacy violations, unauthorized data access, and GDPR/CCPA compliance alerts
- **Azure Cosmos DB Accounts** - Produces database access control failures and audit logging compliance issues
- **AI Services** - Creates responsible AI violations, model governance issues, and AI compliance framework alerts

**Best Alert Types for This Template**:

- Data privacy violations.
- Access control failures.
- Audit logging issues.
- Regulatory compliance gaps.

### Compliance Analysis Logic App Modifications

#### 1. Update Compliance Analysis Messages

Navigate to the **Generate AI Analysis** action in your Logic App and replace the complete messages array with:

> **📝 Note**: This action may have a different name if you chose custom naming during Module 03.01 deployment. Look for the Azure OpenAI action that creates chat completions within your "For Each Incident" loop.

> **⚠️ Important - Messages Array Configuration**: Before pasting the JSON below, ensure the **Messages** field is configured in **JSON view** (Input entire array) rather than **detail inputs** mode (detail inputs for array item). In the Logic Apps designer, look for toggle options near the Messages field that allow you to switch between these input modes. JSON view is required for proper array configuration.

```json
[
    {
        "role": "system",
        "content": "You are a cybersecurity compliance analyst specializing in SOC operations and regulatory response. Provide operationally-focused compliance analysis with specific technical controls, monitoring requirements, and actionable validation steps. Each section must be under 650 characters and contain concrete actions SOC analysts can implement immediately. Keep responses concise while ensuring complete actionable guidance."
    },
    {
        "role": "user",
        "content": "SOC COMPLIANCE ANALYSIS REQUEST:\n\nProvide operationally-focused compliance guidance for immediate SOC implementation:\n\nINCIDENT DETAILS:\nTitle: @{item()?['displayName']}\nDescription: @{item()?['description']}\nSeverity: @{item()?['severity']}\n\nSOC-FOCUSED OUTPUT (each section max 650 chars, prioritize immediate actions):\n**REGULATORY IMPACT:**\nFramework violations (GDPR Articles/SOX Sections/HIPAA Rules/PCI Requirements) with specific penalty exposure and notification deadlines.\n\n**COMPLIANCE VIOLATIONS:**\nSpecific regulatory breaches with exact article references, financial penalties, and enforcement likelihood.\n\n**AUDIT IMPLICATIONS:**\nImmediate audit trail requirements, evidence collection steps, and mandatory notification timelines with specific recipients.\n\n**REMEDIATION STRATEGY:**\nTechnical controls to implement immediately (24h/7d/30d) with specific configuration changes and validation steps.\n\n**DOCUMENTATION NEEDS:**\nSpecific logs to preserve, evidence collection procedures, and compliance documentation templates required.\n\n**GOVERNANCE IMPROVEMENTS:**\nSpecific policy updates, monitoring rules, and technical controls needed to prevent recurrence with implementation timelines."
    }
]
```

##### Update Compliance Analysis Max Tokens Setting

**Why 400 tokens?** Compliance analysis is optimized for concise, actionable content that fits within the Microsoft Graph API ~1000 character limit per alert comment. The 6-section format with 400 tokens ensures each section stays under 650 characters while delivering essential compliance information for SOC operations.

In the **Advanced parameters** → **max_tokens**: Change to `400`

#### 2. Update Extract AI Analysis Sections for Compliance Analysis (Compose Action)

Navigate to your Logic App → **Extract AI Analysis Sections** action (Compose action within your For Each loop):

Replace the existing JSON content with this compliance analysis configuration:

```json
{
  "regulatoryImpact": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**REGULATORY IMPACT:**')), '**COMPLIANCE VIOLATIONS:**'))}",
  "complianceViolations": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**COMPLIANCE VIOLATIONS:**')), '**AUDIT IMPLICATIONS:**'))}",
  "auditImplications": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**AUDIT IMPLICATIONS:**')), '**REMEDIATION STRATEGY:**'))}",
  "remediationStrategy": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**REMEDIATION STRATEGY:**')), '**DOCUMENTATION NEEDS:**'))}",
  "documentationNeeds": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**DOCUMENTATION NEEDS:**')), '**GOVERNANCE IMPROVEMENTS:**'))}",
  "governanceImprovements": "@{last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**GOVERNANCE IMPROVEMENTS:**'))}"
}
```

#### 3. Update Create Comments Array for Compliance Analysis (Compose Action)

Navigate to your Logic App → **Create Comments Array** action (Compose action within your For Each loop):

Replace the existing JSON content with this compliance analysis configuration:

```json
[
  {
    "prefix": "[Compliance - Regulatory Impact]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['regulatoryImpact']}",
    "order": 1
  },
  {
    "prefix": "[Compliance - Violations]", 
    "content": "@{outputs('Extract_AI_Analysis_Sections')['complianceViolations']}",
    "order": 2
  },
  {
    "prefix": "[Compliance - Audit Impact]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['auditImplications']}",
    "order": 3
  },
  {
    "prefix": "[Compliance - Remediation Strategy]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['remediationStrategy']}",
    "order": 4
  },
  {
    "prefix": "[Compliance - Documentation]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['documentationNeeds']}",
    "order": 5
  },
  {
    "prefix": "[Compliance - Governance]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['governanceImprovements']}",
    "order": 6
  }
]
```

### Compliance Analysis Expected Results

**Analysis Focus**:

- **Immediate regulatory obligations** with specific notification deadlines and recipients.
- **Technical compliance violations** with exact regulatory references and enforcement probabilities.
- **Operational audit requirements** with specific evidence collection and preservation steps.
- **Technical remediation controls** with configuration steps and validation procedures (24h/7d/30d timelines).
- **Specific documentation templates** and log preservation requirements for compliance validation.
- **Implementable governance controls** with monitoring rules and policy updates to prevent recurrence.

**Token Usage**: ~350-400 tokens per analysis

**SOC Operational Focus**: Each section provides immediately actionable steps that SOC analysts can implement without waiting for management approval, including specific technical controls, configuration changes, and evidence collection procedures optimized for regulatory compliance validation.

**Character Limit Compliance**: All sections optimized to stay under 650 characters per comment to prevent Microsoft Graph API truncation while maintaining comprehensive compliance guidance.

### Compliance Analysis Template - Sample Expected Alert Comments

After running your Logic App with this template, you should see comments similar to these in your Defender XDR incident:

**[Compliance - Regulatory Impact]**

```text
REGULATORY FRAMEWORK ASSESSMENT:
GDPR Article 32 (Security of Processing) - VIOLATION: Insufficient access controls. Penalty: €20M or 4% turnover. Notification: 72 hours to DPA.
PCI DSS Requirement 8.2 (User Authentication) - NON-COMPLIANCE: MFA not enforced for privileged access. Impact: Validation requirements increase.
SOC 2 Controls - CC6.1 (Logical Access), CC7.1 (System Monitoring) DEFICIENCY: Access management and monitoring gaps identified.
```

**[Compliance - Violations]**

```text
COMPLIANCE VIOLATIONS:
Data Privacy: 15,000 personal records potentially accessed without authorization - GDPR Article 34 notification required.
Industry Standards: ISO 27001 Annex A.9 (Access Control) objectives not met. SOX Section 404 may be impacted if financial systems accessed.
Contracts: 25 enterprise customer DPAs potentially breached. Third-party audit requirements need remediation evidence.
```

**[Compliance - Audit Impact]**

```text
AUDIT IMPLICATIONS:
External: SOC 2 Type II findings likely - customer trust/contract impact. ISO 27001 review required within 30 days.
Internal: Board audit committee requires root cause analysis within 45 days.
Regulatory: Financial services examination possible if customer financial data accessed. HIPAA audit expansion if health data involved.
Documentation: Comprehensive incident response documentation and forensic evidence preservation required.
```

**[Compliance - Remediation Strategy]**

```text
TECHNICAL REMEDIATION (24h/7d/30d):
GDPR (30-90 days): Encryption at rest, enhanced access controls, DLP deployment, privacy impact assessment updates, staff training.
PCI DSS (60 days): MFA for cardholder environment, network segmentation validation, accelerated vulnerability management.
ISO 27001/SOC 2 (90 days): Access control updates, monitoring enhancement, risk reassessment, control objective alignment.
```

**[Compliance - Documentation]**

```text
EVIDENCE PRESERVATION:
Logs Required: SIEM (90 days), firewalls, endpoint security - chain of custody protocol mandatory.
Templates: GDPR incident reports, PCI DSS forensic documentation, SOC 2 exception reports.
Storage: Secure documentation repository with access controls and audit trails.
Timeline: Evidence collection within 24 hours, documentation completion within 72 hours.
```

**[Compliance - Governance]**

```text
GOVERNANCE IMPROVEMENTS:
Policy Updates: Access control procedures, data handling guidelines, incident response plans (30 days).
Monitoring: Enhanced audit policies, SIEM rule deployment, file integrity monitoring (7 days).
Controls: MFA enforcement, privileged access management, vulnerability scanning automation (14 days).
Training: Staff security awareness, compliance requirements, incident procedures (60 days).
```

---

## 🔍 Template 5: Incident Response Coordination

### Incident Response Coordination Purpose

Test the comprehensive incident response coordination template focusing on step-by-step procedural guidance, timeline management, and team coordination for security incidents.

### Incident Response Coordination Alert Generation

**Recommended Defender for Cloud Plans for This Template**:

- **Virtual Machines** - Generates complex compromise scenarios requiring full incident response coordination
- **Containers** - Produces multi-stage attack patterns requiring coordinated response procedures
- **Azure SQL Databases** - Creates data breach incidents requiring comprehensive coordination protocols

### Incident Response Coordination Logic App Modifications

#### 1. Update Incident Response Coordination Messages

Navigate to the **Generate AI Analysis** action in your Logic App and replace the complete messages array with:

> **📝 Note**: This action may have a different name if you chose custom naming during Module 03.01 deployment. Look for the Azure OpenAI action that creates chat completions within your "For Each Incident" loop.
> **⚠️ Important - Messages Array Configuration**: Before pasting the JSON below, ensure the **Messages** field is configured in **JSON view** (Input entire array) rather than **detail inputs** mode (detail inputs for array item). In the Logic Apps designer, look for toggle options near the Messages field that allow you to switch between these input modes. JSON view is required for proper array configuration.

```json
[
    {
        "role": "system",
        "content": "You are an experienced incident response coordinator with expertise in cybersecurity emergency management, team mobilization, and crisis leadership. Provide structured, time-bound incident response coordination guidance for security incidents. Each section must be under 800 characters to fit within Defender alert comment limits while delivering actionable response procedures within exactly 400 tokens. DO NOT truncate sections."
    },
    {
        "role": "user",
        "content": "INCIDENT RESPONSE COORDINATION REQUEST:\n\nProvide structured incident response coordination for immediate SOC implementation:\n\nINCIDENT DETAILS:\nTitle: @{item()?['displayName']}\nDescription: @{item()?['description']}\nSeverity: @{item()?['severity']}\n\nSTRICT OUTPUT FORMAT (each section under 800 chars):\n**INCIDENT CLASSIFICATION:**\nSeverity assessment, response level determination, and resource allocation requirements.\n\n**IMMEDIATE ACTIONS:**\nCritical first response actions (0-30 minutes) with specific timelines and responsible parties.\n\n**CONTAINMENT PROCEDURES:**\nSpecific containment steps with isolation requirements and evidence preservation protocols.\n\n**COORDINATION REQUIREMENTS:**\nTeam mobilization, communication protocols, and escalation procedures with notification timelines."
    }
]
```

##### Update Incident Response Coordination Max Tokens Setting

**Why 400 tokens?** Incident response coordination is optimized for character limit compliance while delivering comprehensive procedural guidance. The streamlined 4-section format with 400 tokens ensures each section stays well under the ~1000 character limit while providing essential coordination procedures for SOC operations.

In the **Advanced parameters** → **max_tokens**: Change to `400`

#### 2. Update Extract AI Analysis Sections for Incident Response Coordination (Compose Action)

Navigate to your Logic App → **Extract AI Analysis Sections** action (Compose action within your For Each loop):

Replace the existing JSON content with this incident response coordination configuration:

```json
{
  "incidentClassification": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**INCIDENT CLASSIFICATION:**')), '**IMMEDIATE ACTIONS:**'))}",
  "immediateActions": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**IMMEDIATE ACTIONS:**')), '**CONTAINMENT PROCEDURES:**'))}",
  "containmentProcedures": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**CONTAINMENT PROCEDURES:**')), '**COORDINATION REQUIREMENTS:**'))}",
  "coordinationRequirements": "@{last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**COORDINATION REQUIREMENTS:**'))}"
}
```

#### 3. Update Create Comments Array for Incident Response Coordination (Compose Action)

Navigate to your Logic App → **Create Comments Array** action (Compose action within your For Each loop):

Replace the existing JSON content with this incident response coordination configuration:

```json
[
  {
    "prefix": "[IR - Incident Classification]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['incidentClassification']}",
    "order": 1
  },
  {
    "prefix": "[IR - Immediate Actions]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['immediateActions']}",
    "order": 2
  },
  {
    "prefix": "[IR - Containment Procedures]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['containmentProcedures']}",
    "order": 3
  },
  {
    "prefix": "[IR - Team Coordination]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['coordinationRequirements']}",
    "order": 4
  }
]
```

### Incident Response Coordination Expected Results

**Analysis Focus**:

- Comprehensive step-by-step procedural guidance with specific timelines.
- Clear team coordination requirements and resource allocation.
- Evidence preservation and forensic investigation protocols.
- Communication management with internal and external notification requirements.

**Token Usage**: ~380-400 tokens per analysis

### Incident Response Coordination Template - Sample Expected Alert Comments

After running your Logic App with this template, you should see comments similar to these in your Defender XDR incident:

**[IR - Incident Classification]**

```text
INCIDENT CLASSIFICATION:
Severity: Medium. This incident involves persistence and privilege escalation, indicating potential unauthorized access. Response Level: Level 2, requiring immediate attention but not full-scale mobilization. Resource Allocation: Assemble a response team including SOC analysts, incident handlers, and forensic experts. Ensure availability of tools for monitoring and analysis. Prioritize affected systems and user accounts for investigation. Document all findings and actions taken for post-incident review.
```

**[IR - Immediate Actions]**

```text
IMMEDIATE ACTIONS:
0-10 min: Alert SOC team and initiate incident ticket. Responsible: SOC Manager.
10-20 min: Assess affected systems and user accounts; gather initial logs. Responsible: SOC Analysts.
20-30 min: Notify IT and system owners of potential impact; prepare for deeper analysis. Responsible: Incident Handler. Ensure all communications are logged for future reference.
```

**[IR - Containment Procedures]**

```text
CONTAINMENT PROCEDURES:
1. Isolate affected systems from the network to prevent further escalation.
2. Disable compromised user accounts and reset passwords.
3. Preserve evidence by creating disk images and collecting relevant logs.
4. Document all actions taken, including timestamps and personnel involved.
5. Ensure that forensic tools are used for evidence collection to maintain integrity.
```

**[IR - Team Coordination]**

```text
TEAM COORDINATION:
Mobilize the incident response team immediately. Establish a communication channel (e.g., Slack or Teams) for real-time updates. Notify stakeholders within 30 minutes of incident detection. Escalate to senior management if the incident severity increases. Conduct regular briefings every hour to assess progress and adjust strategies as needed. Document all communications and decisions for post-incident analysis.
```

---

## 🔍 Template 6: Remediation Guidance

### Remediation Guidance Purpose

Test the comprehensive technical remediation template focusing on system recovery procedures, security hardening measures, and validation criteria for complete incident resolution.

### Remediation Guidance Alert Generation

**Recommended Defender for Cloud Plans for This Template**:

- **Virtual Machines** - Generates system compromise scenarios requiring detailed technical remediation
- **Storage Accounts** - Produces data integrity issues requiring comprehensive recovery procedures  
- **Azure SQL Databases** - Creates database security incidents requiring technical restoration guidance

### Remediation Guidance Logic App Modifications

#### 1. Update Remediation Guidance Messages

Navigate to the **Generate AI Analysis** action in your Logic App and replace the complete messages array with:

> **📝 Note**: This action may have a different name if you chose custom naming during Module 03.01 deployment. Look for the Azure OpenAI action that creates chat completions within your "For Each Incident" loop.
> **⚠️ Important - Messages Array Configuration**: Before pasting the JSON below, ensure the **Messages** field is configured in **JSON view** (Input entire array) rather than **detail inputs** mode (detail inputs for array item). In the Logic Apps designer, look for toggle options near the Messages field that allow you to switch between these input modes. JSON view is required for proper array configuration.

```json
[
    {
        "role": "system",
        "content": "You are a senior security engineer specializing in incident response and technical remediation. Provide concise, actionable technical remediation guidance focused on immediate SOC implementation. Each section must be under 650 characters to fit within Defender alert comment limits while delivering essential technical guidance within exactly 350 tokens. Prioritize essential actions over detailed commands."
    },
    {
        "role": "user",
        "content": "TECHNICAL REMEDIATION GUIDANCE REQUEST:\n\nCreate technical remediation plan for immediate SOC implementation:\n\nINCIDENT DETAILS:\nTitle: @{item()?['displayName']}\nDescription: @{item()?['description']}\nSeverity: @{item()?['severity']}\n\nSTRICT OUTPUT FORMAT (each section max 650 chars, focus on essential actions):\n**IMMEDIATE CONTAINMENT:**\nCritical isolation and evidence preservation steps with essential commands only.\n\n**TECHNICAL RECOVERY:**\nKey remediation steps with validation checkpoints and rollback options.\n\n**SYSTEM HARDENING:**\nEssential security improvements to prevent similar incidents with timelines.\n\n**RECOVERY VALIDATION:**\nCore testing procedures and success criteria to confirm complete remediation."
    }
]
```

##### Update Remediation Guidance Max Tokens Setting

**Why 400 tokens?** Technical remediation guidance is optimized for character limit compliance while delivering essential recovery procedures. The 4-section format with 400 tokens and tighter character limits (800→650 chars) ensure each section stays well under the Microsoft Graph API ~1000 character limit while providing comprehensive technical remediation guidance for SOC operations.

In the **Advanced parameters** → **max_tokens**: Change to `400`

#### 2. Update Extract AI Analysis Sections for Remediation Guidance (Compose Action)

Navigate to your Logic App → **Extract AI Analysis Sections** action (Compose action within your For Each loop):

Replace the existing JSON content with this remediation guidance configuration:

```json
{
  "immediateContainment": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**IMMEDIATE CONTAINMENT:**')), '**TECHNICAL RECOVERY:**'))}",
  "technicalRecovery": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**TECHNICAL RECOVERY:**')), '**SYSTEM HARDENING:**'))}",
  "systemHardening": "@{first(split(last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**SYSTEM HARDENING:**')), '**RECOVERY VALIDATION:**'))}",
  "recoveryValidation": "@{last(split(first(body('Generate_AI_Analysis')['choices'])['message']['content'], '**RECOVERY VALIDATION:**'))}"
}
```

#### 3. Update Create Comments Array for Remediation Guidance (Compose Action)

Navigate to your Logic App → **Create Comments Array** action (Compose action within your For Each loop):

Replace the existing JSON content with this remediation guidance configuration:

```json
[
  {
    "prefix": "[Remediation - Immediate Containment]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['immediateContainment']}",
    "order": 1
  },
  {
    "prefix": "[Remediation - Technical Recovery]", 
    "content": "@{outputs('Extract_AI_Analysis_Sections')['technicalRecovery']}",
    "order": 2
  },
  {
    "prefix": "[Remediation - System Hardening]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['systemHardening']}",
    "order": 3
  },
  {
    "prefix": "[Remediation - Recovery Validation]",
    "content": "@{outputs('Extract_AI_Analysis_Sections')['recoveryValidation']}",
    "order": 4
  }
]
```

### Remediation Guidance Expected Results

**Analysis Focus**:

- Essential technical containment and isolation procedures.
- Concise recovery processes with key validation checkpoints.
- Priority system hardening measures to prevent reoccurrence.
- Focused testing procedures to confirm complete remediation.

**Token Usage**: ~380-400 tokens per analysis (optimized for character limit compliance)

### Remediation Guidance Template - Sample Expected Alert Comments

After running your Logic App with this template, you should see comments similar to these in your Defender XDR incident:

**[Remediation - Immediate Containment]**

```text
IMMEDIATE CONTAINMENT:
1. NETWORK ISOLATION: Execute 'netsh advfirewall set allprofiles state on' to enable firewall blocking
2. EVIDENCE PRESERVATION: Create forensic images using FTK Imager or dd command before any changes
3. ACCESS CONTROL: Disable compromised accounts via 'Disable-ADAccount -Identity [username]'
4. SYSTEM QUARANTINE: Isolate affected systems while maintaining administrative access for investigation

Critical Success: Network isolated within 5 minutes, forensic evidence secured
Escalation: Contact Incident Commander if containment fails within 30 minutes
```

**[Remediation - Technical Recovery]**

```text
TECHNICAL RECOVERY:
1. BACKUP VALIDATION: Verify clean backup integrity using checksums and malware scanning
2. SYSTEM REBUILD: Deploy fresh OS from approved baseline with security hardening
3. DATA RESTORATION: Restore validated clean data, scan for malicious artifacts
4. SERVICE RESTORATION: Gradually restore services starting with critical business functions

Rollback Plan: Revert to isolation if new issues arise during recovery
Timeline: 2-4 hours for complete system recovery with validation checkpoints
```

**[Remediation - System Hardening]**

```text
SYSTEM HARDENING:
1. PATCH DEPLOYMENT: Install critical security updates addressing root cause vulnerabilities
2. ACCESS ENHANCEMENT: Implement least privilege, enable MFA for administrative accounts
3. MONITORING EXPANSION: Deploy additional logging focused on attack vectors used
4. CONFIGURATION SECURITY: Disable unnecessary services, implement network segmentation

Implementation: 48-72 hours with vulnerability scanning validation
Sign-off: CISO approval required before declaring hardening complete
```

**[Remediation - Recovery Validation]**

```text
RECOVERY VALIDATION:
1. BUSINESS TESTING: Validate core workflows, user authentication, data access patterns
2. SECURITY VERIFICATION: Test firewall rules, intrusion detection, backup integrity
3. PERFORMANCE MONITORING: Confirm system metrics, network connectivity, service response
4. STAKEHOLDER APPROVAL: Document residual issues, obtain business sign-off

Success Criteria: Zero security alerts for 48 hours, >95% baseline performance
Timeline: 2-3 business days including stakeholder validation and final approval
```

---

## �📊 Testing Documentation Template

## 📊 Character Limit Optimization Summary

All templates have been optimized for Microsoft Defender XDR alert comment character limit compliance while maximizing operational value for SOC analysts:

### Template Configuration Optimization

| Template | Token Limit | Sections | Character Limit Focus | SOC Operational Value |
|----------|-------------|----------|----------------------|----------------------|
| **Template 1 (Classification)** | 350 tokens | 4 sections | ~275-325 chars/section | Rapid triage & severity assessment |
| **Template 2 (Threat Hunting)** | 400 tokens | 4 sections | ~300-350 chars/section | Technical investigation & IOC analysis |
| **Template 3 (Risk Assessment)** | 400 tokens | 4 sections | ~300-350 chars/section | Business impact scoring & executive support |
| **Template 4 (Compliance Analysis)** | 400 tokens | 6 sections | ~200-300 chars/section | Regulatory compliance & audit requirements |
| **Template 5 (Incident Response)** | 400 tokens | 4 sections | ~300-350 chars/section | Multi-team coordination & procedural guidance |
| **Template 6 (Remediation)** | 400 tokens | 4 sections | ~300-350 chars/section | Technical recovery & system hardening |

### Character Limit Safety Measures

**Multiple Protection Layers**:

- **Token Limits**: Constrained to 350-400 tokens per template
- **Character Guidance**: Explicit 800-character per-section maximums in system messages
- **Section Optimization**: Reduced from 5-8 sections to 4-6 sections per template
- **Multi-Comment Structure**: Content distributed across multiple focused comments

**API Compliance Validation**: All templates tested to remain well under Microsoft Graph API ~1000 character limit per alert comment while delivering comprehensive SOC-focused analysis.

---

## 🧪 Template Testing Performance Tracking

### Performance Tracking

For each template test, document the following:

#### Template Performance Assessment

| Metric | Template 1 (Classification) | Template 2 (Threat Hunting) | Template 3 (Risk Assessment) | Template 4 (Compliance Analysis) | Template 5 (Incident Response) | Template 6 (Remediation) |
|--------|--------------------------------|--------------------------------|----------------------------------|-----------------------------------|----------------------------------|---------------------------|
| **Token Usage** | ___ tokens | ___ tokens | ___ tokens | ___ tokens | ___ tokens | ___ tokens |
| **Response Time** | ___ seconds | ___ seconds | ___ seconds | ___ seconds | ___ seconds | ___ seconds |
| **Analysis Quality** | ___/10 | ___/10 | ___/10 | ___/10 | ___/10 | ___/10 |
| **Relevance Score** | ___/10 | ___/10 | ___/10 | ___/10 | ___/10 | ___/10 |
| **Actionability** | ___/10 | ___/10 | ___/10 | ___/10 | ___/10 | ___/10 |

#### Qualitative Assessment

**Template Effectiveness Notes**:

- **Most Effective For**: [Alert type that worked best with this template]
- **Key Strengths**: [What this template did exceptionally well]
- **Areas for Improvement**: [What could be enhanced]
- **Best Use Cases**: [When to apply this template in production]

### Comparison Analysis

After testing all templates, complete this analysis:

#### Overall Template Rankings

| Rank | Template | Primary Strength | Best Alert Types | Production Suitability |
|------|----------|------------------|------------------|----------------------|
| **1** | _________ | _____________ | _____________ | ___/10 |
| **2** | _________ | _____________ | _____________ | ___/10 |
| **3** | _________ | _____________ | _____________ | ___/10 |
| **4** | _________ | _____________ | _____________ | ___/10 |
| **5** | _________ | _____________ | _____________ | ___/10 |

#### Template Selection Strategy

Based on your testing, document your recommended template selection logic:

**Alert Type → Template Mapping**:

- **Network Security Alerts** → _____________
- **Access Management Issues** → _____________
- **Data Privacy Concerns** → _____________
- **Critical Infrastructure** → _____________
- **Compliance Violations** → _____________

---

## 🔧 Troubleshooting Common Issues

### Logic App Workflow Validation Errors

#### "Action not defined in template" Error

**Problem**: When implementing the Compose action configurations, you may encounter validation errors like:

```text
The action(s) 'Generate AI Analysis' referenced by 'inputs' in action 'Extract_AI_Analysis_Sections' are not defined in the template.
```

**Root Cause**: This error typically occurs due to:

1. **Action Name Mismatch**: The referenced action name doesn't exactly match your actual action name
2. **Logic App Designer Sync Issues**: Sometimes the Designer needs to refresh to recognize action references
3. **Action Dependency Issues**: The referenced action may not be properly saved or validated

**Solution**:

1. **Verify Exact Action Name**: Double-check that your Azure OpenAI action is exactly named `Generate AI Analysis` (case-sensitive)

2. **Save and Refresh**:
   - Save your Azure OpenAI action changes first
   - Refresh the Logic App Designer (F5 or browser refresh)
   - Then configure the Compose actions

3. **Alternative Action Names**: If your action has a different name, common variations include:
   - `Create_chat_completion` (default Azure OpenAI connector name)
   - `OpenAI_Chat_Completion`
   - `Generate_AI_Response`
   - `AI_Analysis_Action`

4. **Update References**: If using a different action name, replace `'Generate AI Analysis'` with your exact action name in both:
   - **Extract AI Analysis Sections** (parsing Compose action)
   - **Create Comments Array** (formatting Compose action)

5. **Validation**: Save and test your Logic App to ensure the references work correctly.

#### "seedValue parameter not provided" Error

**Problem**: When implementing the complete JSON message arrays above, you may encounter a validation error stating that the "seedValue parameter not provided" during Logic App workflow validation.

**Root Cause**: Logic Apps Designer requires a `defaultValue` attribute for all workflow parameters to enable proper validation, parameter display, and IntelliSense functionality in the Designer interface.

**Solution**: Update your Logic App's workflow parameters to include a default value for the `seedValue` parameter.

##### **Why seedValue = 42?**

Based on comprehensive research of Microsoft's Azure OpenAI documentation:

- **Microsoft's Standard**: Azure OpenAI documentation consistently uses `seed=42` in all reproducible output examples
- **Official Recommendation**: Microsoft Q&A responses explicitly recommend `seed=42` as the example value
- **Industry Alignment**: While some frameworks use `12345`, Microsoft's documentation standardizes on `42`
- **Reproducible Results**: The seed parameter enables deterministic sampling for consistent AI responses

##### **Parameter Architecture Understanding**

**ARM Template Parameters vs Workflow Parameters**:

| Parameter Type | Purpose | Default Value Requirement | Example |
|---------------|---------|---------------------------|---------|
| **ARM Template Parameters** | Deployment-time configuration | Optional (deployment fails if required and not provided) | `main.parameters.json` file |
| **Workflow Parameters** | Runtime Logic App operation | Required for Designer validation | Workflow definition schema |

**ARM Template Parameters** (in `main.parameters.json`):

```json
{
  "seedValue": {
    "value": 42
  }
}
```

**Workflow Parameters** (in Logic App definition):

```json
{
  "parameters": {
    "seedValue": {
      "defaultValue": 42,
      "type": "int"
    }
  }
}
```

##### **Resolution Steps**

1. **Verify Parameters File**: Ensure your `main.parameters.json` includes the updated seed value:

```json
{
  "seedValue": {
    "value": 42
  }
}
```

1. **Update Workflow Definition**: In your Logic App, add `defaultValue` to the workflow parameters section:

**Navigate to**: Logic Apps → Your Logic App → **Logic app designer** → **Parameters** tab

**Add/Update Parameter**:

- **Name**: `seedValue`
- **Type**: `Integer`
- **Default Value**: `42`
- **Description**: `Seed value for reproducible AI responses (Microsoft recommended: 42)`

1. **Validate and Save**: Save your Logic App workflow to validate the parameter configuration.

### JSON Message Array Formatting Issues

#### Escape Sequence Problems

**Problem**: JSON parsing errors when implementing the message arrays.

**Solution**: Ensure proper escape sequences for quotes within the JSON:

```json
[
  {
    \"role\": \"system\",
    \"content\": \"Your system message here\"
  },
  {
    \"role\": \"user\", 
    \"content\": \"Your user message here\"
  }
]
```

#### Dynamic Content Integration

**Problem**: Logic App expressions not evaluating correctly within JSON arrays.

**Solution**: Use proper dynamic content syntax:

```json
[
  {
    \"role\": \"user\",
    \"content\": \"Analyze this incident: @{variables('incidentDetails')}, Alert Classification: @{items('For_Each_Incident')?['classification']}, etc.\"
  }
]
```

### Token Limit and Response Issues

#### Truncated AI Responses

**Problem**: AI responses getting cut off mid-sentence.

**Root Cause**: Max tokens setting too low for comprehensive analysis.

**Solution**: Adjust max tokens based on template complexity:

| Template Type | Recommended Max Tokens | Reasoning |
|--------------|----------------------|-----------|
| **Incident Classification** | 500-750 | Structured, concise outputs |
| **Threat Hunting Analysis** | 800-1200 | Technical details and queries |
| **Risk Assessment** | 600-900 | Business impact analysis |
| **Executive Summary** | 400-600 | High-level, concise reporting |
| **Compliance Analysis** | 900-1500 | Detailed regulatory mapping |

#### Poor Response Quality

**Problem**: AI responses lack depth or miss important details.

**Solutions**:

- **Increase Temperature**: From 0.3 to 0.5-0.7 for more creative analysis
- **Adjust Top-P**: Use 0.95 for balanced response diversity
- **Review System Message**: Ensure clear role definition and expectations
- **Enhance Context**: Include more incident details in user message

### Performance Optimization

#### High Token Costs

**Problem**: Template testing consuming excessive tokens.

**Solutions**:

- **Optimize Prompts**: Remove unnecessary instructions and examples
- **Batch Processing**: Test multiple incidents simultaneously
- **Template Comparison**: Use A/B testing with smaller token budgets first
- **Smart Filtering**: Apply templates only to incidents meeting specific criteria

### Logic App Designer Issues

#### Parameter Display Problems

**Problem**: Parameters not showing correctly in Designer interface.

**Solution**: Verify all workflow parameters have:

- Proper `type` definition (`string`, `int`, `bool`, `object`, `array`)
- Appropriate `defaultValue` for each parameter type
- Clear `description` for usability

#### Action Configuration Validation

**Problem**: Azure OpenAI connector actions failing validation.

**Checklist**:

- [ ] **Connection Name**: Matches your OpenAI connection
- [ ] **Deployment Name**: Matches your model deployment
- [ ] **Messages**: Properly formatted JSON array
- [ ] **Parameters**: All required parameters have values or defaults
- [ ] **Authentication**: Service connection active and authorized

---

## 🎯 Next Steps and Integration

### Template Integration Strategy

After completing all template tests:

1. **Document Optimal Mappings**: Record which templates work best for different alert types.
2. **Cost-Benefit Analysis**: Evaluate token usage vs. analysis quality improvements.
3. **Production Implementation**: Plan intelligent template selection logic.
4. **Continuous Improvement**: Establish ongoing template optimization process.

### Progression to Advanced Integration

With template testing complete, you'll be ready for:

- **Dynamic Template Selection**: Implement Logic App logic to automatically choose templates.
- **A/B Testing Framework**: Compare template performance systematically.
- **Multi-Template Analysis**: Apply multiple templates to complex incidents.
- **Template Optimization**: Fine-tune templates based on testing results.

## 📚 Reference Links

### Template Resources

Each template referenced in this guide:

- **[Incident Classification Template](../../02%20-%20AI%20Foundation%20&%20Secure%20Model%20Deployment/02.05%20AI%20Prompt%20Templates%20Creation/templates/incident-classification.md)**
- **[Threat Hunting Analysis Template](../../02%20-%20AI%20Foundation%20&%20Secure%20Model%20Deployment/02.05%20AI%20Prompt%20Templates%20Creation/templates/threat-hunting-analysis.md)**
- **[Risk Assessment Template](../../02%20-%20AI%20Foundation%20&%20Secure%20Model%20Deployment/02.05%20AI%20Prompt%20Templates%20Creation/templates/risk-assessment.md)**
- **[Executive Summary Template](../../02%20-%20AI%20Foundation%20&%20Secure%20Model%20Deployment/02.05%20AI%20Prompt%20Templates%20Creation/templates/executive-summary.md)**
- **[Compliance Analysis Template](../../02%20-%20AI%20Foundation%20&%20Secure%20Model%20Deployment/02.05%20AI%20Prompt%20Templates%20Creation/templates/compliance-analysis.md)**

### Azure Documentation

- **[Logic Apps Designer Guide](https://docs.microsoft.com/azure/logic-apps/logic-apps-workflow-definition-language)** - For understanding Logic App modifications
- **[Microsoft Defender XDR Portal](https://security.microsoft.com)** - For incident management and alert generation
- **[Azure OpenAI Token Optimization](https://platform.openai.com/docs/guides/prompt-engineering)** - For template optimization strategies

---

## 🤖 AI-Assisted Content Generation

This comprehensive AI Prompt Template Integration Testing Guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating systematic testing methodologies, Azure Logic Apps configuration patterns, and AI prompt optimization strategies for security operations automation in lab environments.

*AI tools were used to enhance productivity and ensure comprehensive coverage of template testing approaches while maintaining technical accuracy and reflecting current Azure Logic Apps capabilities and AI prompt engineering best practices for cost-effective security operations.*

