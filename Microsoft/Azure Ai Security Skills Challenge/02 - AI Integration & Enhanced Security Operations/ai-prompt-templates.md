# AI Prompt Templates for Security Operations

This document provides cost-optimized prompt templates for security scenarios. Each template is designed to maximize AI effectiveness while minimizing token usage and costs.

## 🎯 Design Principles

### Cost Optimization
- **Maximum 500 tokens per response** to control costs
- **Temperature 0.3** for focused, consistent responses
- **Structured prompts** to reduce unnecessary tokens
- **Clear output format** to minimize back-and-forth interactions

### Security Focus
- **Actionable insights** for immediate security response
- **Risk-based prioritization** to focus on critical threats
- **False positive detection** to reduce alert fatigue
- **Integration ready** for Sentinel and Logic Apps automation

## 📋 Template Categories

### 1. Threat Detection and Alert Triage

#### Basic Incident Analysis
```
Role: You are a cybersecurity analyst assistant.

Task: Analyze this security incident and provide:
1. Threat summary (2-3 sentences)
2. Risk level (Low/Medium/High/Critical)
3. Immediate action required (Yes/No + 1 sentence)
4. False positive likelihood (Low/Medium/High)

Incident Data: {incident_description}

Response Format:
Summary: [brief description]
Risk: [level]
Action: [Yes/No] [action if yes]
False Positive: [likelihood]

Max Response: 150 tokens
```

#### Alert Correlation
```
Role: Security operations expert.

Task: Correlate these alerts and identify patterns:
{alert_list}

Provide:
1. Related alerts (list IDs)
2. Attack pattern (if any)
3. Priority score (1-10)
4. Recommended investigation steps (max 3)

Format:
Related: [IDs]
Pattern: [description or "None detected"]
Priority: [score]
Steps: 1) [step] 2) [step] 3) [step]

Max Response: 200 tokens
```

### 2. Security Incident Summarization

#### Executive Summary
```
Role: Senior security analyst creating executive briefing.

Task: Create executive summary for this incident:
{incident_details}

Include:
1. What happened (1 sentence)
2. Impact assessment (1 sentence)
3. Current status (1 sentence)
4. Next steps (1 sentence)

Format:
Incident: [what happened]
Impact: [assessment]
Status: [current state]
Next: [immediate steps]

Max Response: 100 tokens
```

#### Technical Investigation Summary
```
Role: Technical security investigator.

Task: Summarize technical findings for:
{investigation_data}

Provide:
1. Attack vector used
2. Systems affected
3. Evidence collected
4. Containment status
5. Recovery recommendations

Format:
Vector: [attack method]
Systems: [affected resources]
Evidence: [key findings]
Containment: [status]
Recovery: [recommendations]

Max Response: 250 tokens
```

### 3. AI-Assisted Remediation Guidance

#### Immediate Response Actions
```
Role: Incident response specialist.

Task: Provide immediate response actions for:
Incident Type: {incident_type}
Affected Systems: {systems}
Current Status: {status}

Generate:
1. Immediate actions (priority order, max 5)
2. Resources needed
3. Estimated timeline
4. Success criteria

Format:
Actions:
1. [action] - [timeline]
2. [action] - [timeline]
...

Resources: [needed]
Timeline: [total estimate]
Success: [criteria]

Max Response: 300 tokens
```

#### Remediation Plan
```
Role: Security remediation expert.

Task: Create remediation plan for:
{vulnerability_or_incident}

Include:
1. Root cause
2. Remediation steps (numbered)
3. Validation methods
4. Prevention measures

Format:
Cause: [root cause]
Steps:
1. [step]
2. [step]
...
Validation: [method]
Prevention: [measures]

Max Response: 400 tokens
```

### 4. Risk Assessment and Prioritization

#### Risk Scoring
```
Role: Risk assessment analyst.

Task: Score this security event:
Event: {event_description}
Environment: {environment_context}

Assess:
1. Likelihood (1-5)
2. Impact (1-5)
3. Risk Score (calculation)
4. Priority level
5. Justification (1 sentence)

Format:
Likelihood: [score]/5
Impact: [score]/5
Risk: [likelihood × impact]/25
Priority: [Low/Medium/High/Critical]
Justification: [reasoning]

Max Response: 100 tokens
```

#### Threat Intelligence Context
```
Role: Threat intelligence analyst.

Task: Provide threat context for:
{threat_indicators}

Include:
1. Known threat actor (if identified)
2. TTPs observed
3. Industry targeting
4. Mitigation priority
5. Additional IOCs to monitor

Format:
Actor: [name or "Unknown"]
TTPs: [techniques]
Targeting: [industries/regions]
Priority: [level]
Monitor: [additional IOCs]

Max Response: 200 tokens
```

## 🔧 Integration Examples

### Logic Apps Integration

#### Sentinel Automation Prompt
```json
{
  "prompt": "Analyze this Sentinel incident: @{triggerBody()['properties']['description']}. Provide: 1) Summary, 2) Severity (Low/Medium/High/Critical), 3) Recommended actions, 4) False positive likelihood. Max 150 tokens.",
  "max_tokens": 150,
  "temperature": 0.3
}
```

#### Cost-Optimized Batch Processing
```json
{
  "prompt": "Analyze these 5 alerts in batch: @{variables('alertBatch')}. For each, provide: ID, Risk Level, Action Required (Y/N). Format: [ID]: [Risk] - [Y/N]. Max 200 tokens total.",
  "max_tokens": 200,
  "temperature": 0.2
}
```

## 💰 Cost Management Guidelines

### Token Optimization Strategies

1. **Use Structured Formats**: Reduces tokens needed for parsing
2. **Limit Response Length**: Set maximum token limits for each prompt type
3. **Batch Multiple Requests**: Process multiple items in single requests
4. **Reuse Context**: Reference previous analysis when possible
5. **Avoid Repetitive Phrases**: Use abbreviations and concise language

### Cost Monitoring

| Template Type | Avg Tokens | Est. Cost/Use | Monthly Estimate* |
|---------------|------------|---------------|-------------------|
| Alert Triage | 150 | $0.0003 | $9 (1000 alerts) |
| Incident Summary | 200 | $0.0004 | $12 (1000 incidents) |
| Risk Assessment | 100 | $0.0002 | $6 (1000 assessments) |
| Remediation | 300 | $0.0006 | $18 (1000 remediations) |

*Based on GPT-3.5-turbo pricing and estimated usage

### Budget Alerts Integration

```json
{
  "costThreshold": 0.01,
  "alertCondition": "Daily token usage exceeds $0.01",
  "action": "Send notification and reduce prompt frequency"
}
```

## 🔍 Template Validation

### Testing Prompts

Use these test scenarios to validate prompt effectiveness:

1. **Sample Malware Alert**: Test detection and response prompts
2. **Phishing Incident**: Validate incident summarization
3. **Network Anomaly**: Test risk assessment templates
4. **False Positive**: Verify false positive detection accuracy

### Performance Metrics

Track these metrics for prompt optimization:
- Response relevance (1-5 scale)
- Token efficiency (actual vs. target tokens)
- False positive detection rate
- Time to actionable insight

## 🔗 Advanced Integration Patterns

### Chained Prompts for Complex Analysis

```
1. Initial Triage → Risk Level
2. If High Risk → Detailed Analysis
3. If Critical → Immediate Response Plan
4. All Levels → Executive Summary
```

### Conditional Logic Integration

```json
{
  "condition": "@{outputs('Risk_Assessment')['risk_level']}",
  "high": "Execute detailed analysis prompt",
  "medium": "Execute standard analysis prompt", 
  "low": "Execute basic triage prompt"
}
```

## 📚 Best Practices

### Prompt Engineering Tips

1. **Be Specific**: Clear role and task definitions
2. **Use Examples**: Include format examples in complex prompts
3. **Set Boundaries**: Explicit token and format limits
4. **Test Iteratively**: Refine prompts based on output quality
5. **Monitor Costs**: Track token usage per prompt type

### Security Considerations

1. **Sanitize Inputs**: Remove sensitive data before prompts
2. **Validate Outputs**: Human review for critical decisions
3. **Audit Trail**: Log all AI interactions for review
4. **Access Controls**: Restrict prompt modification permissions

---

## 🔗 Next Steps

1. **[Test with Sample Data](./simulate-threat-scenarios.md)** - Validate prompts with realistic scenarios
2. **[Deploy Sentinel Integration](./deploy-openai-sentinel-integration.md)** - Automate prompt execution
3. **Monitor Cost Impact** - Track actual vs. estimated costs
4. **Refine Based on Results** - Optimize prompts for better cost/performance ratio

---

**📋 Usage Note**: These templates are optimized for GPT-3.5-turbo. Adjust token limits and complexity for other models as needed.
