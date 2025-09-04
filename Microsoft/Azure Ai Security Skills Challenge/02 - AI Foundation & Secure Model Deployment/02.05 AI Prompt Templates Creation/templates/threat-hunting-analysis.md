# Threat Hunting Analysis Template

## Template Purpose

This template specializes your AI Foundry cybersecurity analyst for **advanced threat hunting and technical investigation** of Defender for Cloud alerts with comprehensive MITRE ATT&CK framework integration and sophisticated attack pattern analysis.

## 🧪 Primary Testing Approach - AI Foundry Chat Interface

**System Message**: Use your established expert cybersecurity analyst configuration from Week 2 lab 02.04 (unchanged)

**User Message**: Apply the threat hunting template content below combined with sample incident data

**Testing Parameters**:

- **Temperature**: 0.2 (analytical precision for threat hunting).
- **Max Tokens**: 450 (comprehensive technical analysis).
- **Expected Range**: 380-420 tokens per threat hunting analysis.

---

## 🔧 Template Content & Logic Apps Integration

### **Complete Template for Logic Apps HTTP Action**

Use this template as your **user message variable** in Logic Apps, combined with incident data:

```text
ADVANCED THREAT HUNTING ANALYSIS REQUEST:

Focus on sophisticated threat hunting and technical investigation for this security incident. Provide specialized analysis with these critical requirements:

ANALYSIS FRAMEWORK:
- Map ALL observed behaviors to specific MITRE ATT&CK techniques (include precise technique IDs).
- Assess lateral movement potential, attack progression indicators, and persistence mechanisms.
- Identify comprehensive IOCs (file hashes, IP addresses, domains, processes, registry keys) for continuous monitoring.
- Evaluate attack sophistication level and potential threat actor attribution based on TTPs.

INVESTIGATION QUERIES:
- Generate actionable KQL queries for Microsoft Sentinel/Defender investigation.
- Focus on hunt queries that identify similar attack patterns across environment.
- Include timeline reconstruction queries and attack chain correlation analysis.
- Provide threat landscape correlation for campaign-level intelligence.

THREAT INTELLIGENCE CORRELATION:
- Correlate indicators with known APT campaigns and documented threat actor TTPs.
- Assess campaign infrastructure patterns and attribution confidence levels.
- Evaluate threat landscape context and provide intelligence-driven recommendations.

OUTPUT FORMAT:
**THREAT ASSESSMENT:**
Severity: [CRITICAL/HIGH/MEDIUM/LOW] | Confidence: [0-100%]
Attack Pattern: [Detailed attack classification]
MITRE ATT&CK: [Specific technique IDs with sub-techniques]

**ATTACK ANALYSIS:**
Attribution: [Threat actor correlation with confidence level]
IOCs: [Comprehensive indicators for monitoring and detection]
Timeline: [Attack progression and technique sequencing]

**HUNT QUERIES:**
[3-4 actionable KQL queries for immediate Sentinel investigation]

**IOC MONITORING:**
[Specific indicators with continuous monitoring recommendations]

**CONFIDENCE & EVIDENCE:**
Confidence: [0.0-1.0 scale with evidence justification]
Evidence: [Supporting indicators and technical artifacts]
Investigation: [Additional investigation areas and recommendations]

TOKEN LIMIT: 450 tokens maximum for comprehensive threat hunting analysis

INCIDENT DATA:
[Logic Apps will append detailed incident information here]
```

### **Logic Apps HTTP Action Configuration**

```json
{
  "method": "POST",
  "uri": "@parameters('openai-endpoint')",
  "headers": {
    "Content-Type": "application/json",
    "api-key": "@parameters('openai-api-key')"
  },
  "body": {
    "messages": [
      {
        "role": "system",
        "content": "@parameters('system-message-from-ai-foundry')"
      },
      {
        "role": "user",
        "content": "@{concat(variables('threat-hunting-template'), '\n\nINCIDENT DATA:\n', body('Parse_incident_data'))}"
      }
    ],
    "max_tokens": 450,
    "temperature": 0.2
  }
}
```

### **Comment Parsing for Conditional Logic Apps Actions**

The AI response enables sophisticated conditional workflows:

```json
{
  "If_Critical_APT_Activity": {
    "type": "If",
    "expression": "@and(contains(body('AI_Analysis')['severity'], 'CRITICAL'), contains(body('AI_Analysis')['attribution'], 'APT'))",
    "actions": {
      "Activate_incident_response_team": {},
      "Create_threat_intelligence_report": {},
      "Initiate_forensic_preservation": {}
    }
  },
  "If_Lateral_Movement_Detected": {
    "type": "If", 
    "expression": "@contains(body('AI_Analysis')['attack_analysis'], 'lateral movement')",
    "actions": {
      "Isolate_affected_systems": {},
      "Reset_compromised_credentials": {},
      "Deploy_additional_monitoring": {}
    }
  }
}
```

### **Cost Analysis & Budget Planning**

**Token Usage & Pricing**:

- **Expected Tokens**: 380-420 per analysis (1.8x stakeholder template).
- **Cost per Analysis**: ~$0.00038 (GPT-4o-mini pricing).
- **Monthly SOC Budget**: ~$38 for 100,000 threat hunting analyses.
- **ROI Analysis**: $50,000+ analyst time savings through automated technical investigation.

**Volume-Based Pricing**:

- **Small SOC** (500/month): ~$0.19.
- **Medium SOC** (5,000/month): ~$1.90.
- **Large SOC** (50,000/month): ~$19.00.
- **Enterprise SOC** (200,000/month): ~$76.00.

---

## 🧪 Testing Scenarios & Expected Results

### **Core Validation Test Cases**

#### **Test Scenario 1: Domain Controller Compromise Analysis**

**Sample Test Input**:

```text
Multiple failed login attempts detected from IP 185.220.101.45 targeting domain administrator account "DA-Admin", followed by successful authentication and immediate PowerShell execution: powershell.exe -windowstyle hidden -executionpolicy bypass -encodedcommand JABzAD0ATgBlAHcALQBPAGIA... on CORPDC01. Event occurred during off-hours (02:30 UTC) with unusual geolocation (TOR exit node). Subsequent lateral movement observed to file servers and backup systems with credential harvesting indicators.
```

**Expected AI Response Format**:

```text
**THREAT ASSESSMENT:**
Severity: CRITICAL | Confidence: 90%
Attack Pattern: Administrative account compromise with lateral movement
MITRE ATT&CK: T1078.003 (Valid Accounts: Local), T1059.001 (PowerShell), T1027 (Obfuscation), T1021.001 (RDP)

**ATTACK ANALYSIS:**
Attribution: TTPs consistent with APT29/Cozy Bear techniques (medium confidence)
IOCs: 185.220.101.45 (TOR exit node), Base64 encoded PowerShell, Off-hours timing pattern
Timeline: Credential compromise → PowerShell execution → Lateral movement (15-minute window)

**HUNT QUERIES:**
DeviceProcessEvents | where FileName =~ "powershell.exe" and ProcessCommandLine contains "bypass"
SigninLogs | where ResultType != 0 | summarize FailedAttempts=count() by UserPrincipalName, IPAddress
DeviceLogonEvents | where LogonType == 10 and TimeGenerated between (datetime(2024-01-01 02:00) .. datetime(2024-01-01 03:00))

**IOC MONITORING:**
Monitor 185.220.101.45 and associated TOR infrastructure for continued activity
Track PowerShell executions with execution policy bypass parameters  
Alert on off-hours administrative authentications from external IPs

**CONFIDENCE & EVIDENCE:**
Confidence: 0.90 - Strong correlation of TTPs, timing, and infrastructure indicators
Evidence: Authentication logs, process execution telemetry, network indicators
Investigation: Decode PowerShell payload, analyze file system artifacts, correlate with threat intelligence
```

#### **Test Scenario 2: Advanced Persistent Threat Campaign Analysis**

**Sample Test Input**:

```text
Coordinated attack sequence: (1) Spear-phishing email with PDF exploit targeting finance department, (2) Cobalt Strike beacon deployment via PowerShell reflective loading, (3) Credential harvesting using Mimikatz-like techniques, (4) Data staging in C:\Windows\Temp\update.log, (5) Exfiltration to suspicious cloud storage service. Attack infrastructure includes domains previously associated with financial sector targeting campaigns.
```

**Expected AI Response Quality Indicators**:

- **Accurate MITRE ATT&CK Mapping**: T1566.001, T1059.001, T1003.001, T1041, T1567.002.
- **Campaign Attribution**: FIN7/Carbanak correlation with confidence scoring.
- **Actionable Hunt Queries**: 3-4 KQL queries targeting similar attack patterns.
- **Comprehensive IOCs**: Domains, file paths, process names, network indicators.
- **Evidence-Based Confidence**: 85-95% confidence with supporting technical evidence.

#### **Test Scenario 3: Lateral Movement & Privilege Escalation**

**Sample Test Input**:

```text
Sequential authentication events: User "CORP\jsmith" authenticated to DC01 (10:15), FILE-SRV-01 (10:17), BACKUP-SRV-02 (10:19), MAIL-SRV-01 (10:22). Source IP consistent (10.1.1.45) but authentication methods varied (NTLM, Kerberos). No scheduled tasks or legitimate access patterns support this behavior. Suspicious service account creation observed 30 minutes prior.
```

**Validation Criteria**:

- [ ] Correctly identifies lateral movement techniques (T1021, T1078, T1135).
- [ ] Provides timeline analysis with attack progression assessment.
- [ ] Generates hunt queries for authentication pattern detection.
- [ ] Assesses persistence mechanisms and privilege escalation potential.
- [ ] Recommends specific containment and investigation actions.

### **Performance & Quality Metrics**

**Token Efficiency**: 380-420 tokens per comprehensive analysis
**Analysis Accuracy**: 85%+ for MITRE ATT&CK technique identification  
**Response Time**: < 3 seconds via Azure OpenAI endpoint
**Cost Efficiency**: ~$0.00038 per advanced threat hunting analysis

**Quality Validation Checklist**:

- [ ] **MITRE ATT&CK Accuracy**: Technique IDs correctly mapped to observed behaviors
- [ ] **KQL Query Validity**: Queries execute successfully in Sentinel/Defender
- [ ] **IOC Specificity**: Indicators are actionable and technically accurate
- [ ] **Attribution Confidence**: Claims supported by technical evidence
- [ ] **Investigation Guidance**: Clear next steps for security analysts
- [ ] **Token Optimization**: Maximum analytical value within 450-token limit

## Template Customization

Adapt this template for your specific environment by customizing threat intelligence sources, MITRE ATT&CK focus areas, organizational context, and industry-specific threat landscapes to optimize threat hunting effectiveness.

### **Customization Areas**

**THREAT INTELLIGENCE INTEGRATION:**

- Integrate your specific threat intelligence feeds, IOC databases, and campaign attribution sources.
- Include organization-specific threat actor profiles and historical attack patterns.
- Adapt for your industry threat landscape (financial, healthcare, government, technology).

**TECHNICAL ENVIRONMENT:**

- Customize for your specific Azure services, network architecture, and security tool stack.
- Include your SIEM platform specifics (Sentinel, Splunk, QRadar) and log source configurations.
- Adapt for your monitoring capabilities, detection rules, and security control implementations.

**MITRE ATT&CK FOCUS:**

- Emphasize techniques most relevant to your environment and attack surface.
- Include industry-specific technique priorities and threat model considerations.
- Customize for your asset criticality, business processes, and risk tolerance levels.

**INVESTIGATION WORKFLOWS:**

- Define your specific escalation procedures, incident response team structure, and forensic capabilities.
- Include your investigation timelines, evidence preservation requirements, and legal considerations.
- Customize for your threat hunting team expertise, tool proficiency, and analytical capabilities.

---

## 🎯 Implementation Outcomes & Success Metrics

### **Expected Template Benefits**

- **Advanced Threat Detection**: Sophisticated threat hunting analysis identifying APT-level campaigns and complex attack patterns previously missed by automated tools.
- **MITRE ATT&CK Intelligence**: Comprehensive technique mapping and attribution analysis providing strategic threat intelligence for organizational security improvement.
- **Investigation Acceleration**: Automated KQL query generation and IOC correlation reducing manual investigation time by 75% for complex incidents.
- **Threat Intelligence Integration**: Automated correlation with known campaigns and threat actors providing enterprise-level attribution assessment and strategic security guidance.

### **Comprehensive Validation Checklist**

**Phase 1: AI Foundry Testing** (Complete before Logic Apps integration):

- [ ] AI Foundry testing completed with 450-token advanced threat hunting analysis.
- [ ] MITRE ATT&CK technique mapping validated across diverse attack scenarios and threat levels.
- [ ] KQL query generation tested for syntax accuracy and investigation effectiveness.
- [ ] System message produces sophisticated technical analysis with attribution confidence scoring.
- [ ] User message format validated with complex multi-stage attack scenarios and APT-level campaigns.
- [ ] Token usage optimized within 380-420 range while maintaining comprehensive analytical depth.

**Phase 2: Logic Apps Integration** (Validate after Week 3 implementation):

- [ ] Threat hunting analyses appear correctly in Defender XDR portal with comprehensive technical detail.
- [ ] Comment parsing enables advanced conditional Logic Apps actions based on attribution and attack sophistication.
- [ ] Token usage remains cost-effective for enterprise-level threat hunting operations.
- [ ] Integration testing validates automated threat intelligence correlation and campaign attribution.
- [ ] Advanced hunt queries execute successfully in Microsoft Sentinel and provide actionable investigation guidance.

---

## 🤖 AI-Assisted Content Generation

This comprehensive threat hunting analysis template was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating advanced threat hunting methodologies, MITRE ATT&CK framework integration, and sophisticated campaign attribution techniques for enterprise cybersecurity operations.

*AI tools were used to enhance productivity and ensure comprehensive coverage of threat hunting strategies while maintaining technical accuracy and reflecting advanced SOC automation practices for complex threat investigation and attribution analysis.*
