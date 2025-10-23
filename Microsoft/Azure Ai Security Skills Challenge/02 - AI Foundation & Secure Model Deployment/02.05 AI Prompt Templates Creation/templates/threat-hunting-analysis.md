# Threat Hunting Analysis Template

## Template Purpose

This template specializes your AI Foundry cybersecurity analyst for **advanced threat hunting and technical investigation** of Defender for Cloud alerts with comprehensive MITRE ATT&CK framework integration and sophisticated attack pattern analysis.

## 🧪 Primary Testing Approach - AI Foundry Chat Interface

**System Message**: Use your established expert cybersecurity analyst configuration from Week 2 lab 02.04 (unchanged)

**User Message**: Apply the threat hunting template content below combined with sample incident data

**Testing Parameters**:

- **Temperature**: 0.2 (analytical precision for threat hunting).
- **Max Tokens**: 400 (optimized for character limit compliance in Microsoft Defender XDR alert comments).
- **Expected Range**: 350-380 tokens per threat hunting analysis.

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
- Embed threat intelligence context within KQL query comments for SOC analyst guidance.

OUTPUT FORMAT:
**THREAT ASSESSMENT:**
High-level threat evaluation and attack sophistication assessment only. Do not include MITRE techniques here.

**MITRE ATT&CK MAPPING:**
List specific technique IDs with sub-techniques and brief descriptions. Format: T####.### - Brief description

**IOC ANALYSIS:**
Provide IOCs with operational context for SOC analysts. Format: IOC_TYPE: value (threat context, confidence level, monitoring priority). Include detection recommendations and blocking guidance.

**HUNTING QUERIES:**
Provide KQL queries for investigation with embedded threat intelligence context in comments. Each query should be properly formatted with comments explaining purpose and including relevant threat actor TTPs, campaign attribution, and infrastructure patterns where applicable.

TOKEN LIMIT: 400 tokens maximum for threat hunting analysis optimized for Microsoft Defender XDR alert comments

CHARACTER LIMIT: Each analysis must fit within ~1000 characters per alert comment. Use multi-comment approach if needed.

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
    "max_tokens": 400,
    "temperature": 0.2
  }
}
```

> **💡 Logic Apps Configuration Tip**: Enable **JSON view** in Logic Apps designer for the HTTP action to see the complete `messages` array structure. Click the **<> JSON** button in the HTTP action to verify your template integration displays correctly with proper message role assignments and variable concatenation.

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

- **Expected Tokens**: 350-380 per analysis (optimized for alert comment character limits).
- **Cost per Analysis**: ~$0.00038 (GPT-4o-mini pricing).
- **Monthly SOC Budget**: ~$38 for 100,000 threat hunting analyses.
- **ROI Analysis**: $50,000+ analyst time savings through automated technical investigation.

**Volume-Based Pricing**:

- **Small SOC** (500/month): ~$0.24.
- **Medium SOC** (5,000/month): ~$2.40.
- **Large SOC** (50,000/month): ~$24.00.
- **Enterprise SOC** (200,000/month): ~$96.00.

**400 Token Allocation Justification**:

- **Character Limit Compliance**: Optimized for Microsoft Defender XDR alert comment ~1000 character limits.
- **Multi-Comment Strategy**: Structured delivery enables comprehensive analysis across multiple alert comments.
- **SOC Operational Focus**: Prioritizes immediate actionable insights for rapid incident triage.
- **Cost Optimization**: Balanced token usage reduces operational costs while maintaining analytical quality.

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
Attack sophistication: INTERMEDIATE - Uses common tools but demonstrates knowledge of enterprise authentication systems

**MITRE ATT&CK MAPPING:**
- T1078.003 (Valid Accounts: Local) - Domain administrator account compromise
- T1059.001 (PowerShell) - Encoded PowerShell execution for stealth
- T1027 (Obfuscation) - Base64 encoded command execution
- T1021.001 (RDP) - Remote desktop protocol for lateral movement
Lateral movement potential: HIGH - Administrative credentials enable network traversal

**IOC ANALYSIS:**
IP Addresses: 185.220.101.45 (TOR exit node, external)
User Accounts: DA-Admin (domain administrator - high-privilege target)
Processes: powershell.exe with execution policy bypass
Commands: Base64 encoded PowerShell payload (JABzAD0ATgBlAHcALQBPAGIA...)
Timing: Off-hours activity (02:30 UTC) - suspicious operational window

**HUNTING QUERIES:**
// Hunt for similar PowerShell execution patterns
// THREAT INTELLIGENCE: PowerShell bypass techniques commonly used by APT29/Cozy Bear
// for administrative account compromise and lateral movement campaigns
DeviceProcessEvents 
| where FileName =~ "powershell.exe" 
| where ProcessCommandLine contains "bypass"
| where ProcessCommandLine contains "encodedcommand"
| where TimeGenerated >= ago(30d)
| project TimeGenerated, DeviceName, AccountName, ProcessCommandLine

// Correlate authentication failures with administrative accounts  
// THREAT INTELLIGENCE: Administrative account targeting pattern observed in
// recent APT campaigns focusing on domain controller compromise
SigninLogs 
| where ResultType != 0 
| where UserPrincipalName contains "admin"
| where TimeGenerated >= ago(7d)
| summarize FailedAttempts=count() by UserPrincipalName, IPAddress, bin(TimeGenerated, 1h)
| where FailedAttempts >= 5

// Timeline reconstruction for off-hours administrative access
// THREAT INTELLIGENCE: Off-hours operations (02:00-04:00 UTC) indicate
// APT operational security practices to avoid detection
DeviceLogonEvents 
| where LogonType == 10 
| where TimeGenerated between (datetime(2024-01-01 02:00) .. datetime(2024-01-01 04:00))
| where AccountName contains "admin"
| project TimeGenerated, AccountName, RemoteIP, DeviceName
| order by TimeGenerated asc
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

**Token Efficiency**: 350-380 tokens per comprehensive analysis
**Analysis Accuracy**: 85%+ for MITRE ATT&CK technique identification  
**Response Time**: < 3 seconds via Azure OpenAI endpoint
**Cost Efficiency**: ~$0.00038 per advanced threat hunting analysis

**Quality Validation Checklist**:

- [ ] **MITRE ATT&CK Accuracy**: Technique IDs correctly mapped to observed behaviors
- [ ] **KQL Query Validity**: Queries execute successfully in Sentinel/Defender
- [ ] **IOC Specificity**: Indicators are actionable and technically accurate
- [ ] **Attribution Confidence**: Claims supported by technical evidence
- [ ] **Investigation Guidance**: Clear next steps for security analysts
- [ ] **Token Optimization**: Maximum analytical value within 400-token limit with character limit compliance

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

- [ ] AI Foundry testing completed with 400-token threat hunting analysis optimized for alert comments.
- [ ] MITRE ATT&CK technique mapping validated across diverse attack scenarios and threat levels.
- [ ] KQL query generation tested for syntax accuracy and investigation effectiveness within character limits.
- [ ] System message produces sophisticated technical analysis with attribution confidence scoring.
- [ ] User message format validated with complex multi-stage attack scenarios and APT-level campaigns.
- [ ] Token usage optimized within 350-380 range while maintaining comprehensive analytical depth and character limit compliance.

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
