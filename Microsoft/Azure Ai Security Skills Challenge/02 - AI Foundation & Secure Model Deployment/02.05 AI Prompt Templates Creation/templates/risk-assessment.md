# Risk Assessment Template

## Template Purpose

After successful AI Foundry testing, this template enables Logic Apps automation to create **comprehensive risk assessments and business impact analysis** with quantitative risk scoring and strategic planning integration for security incidents.

## 🧪 Primary Testing Approach - AI Foundry Chat Interface

**Start here**: Test this template directly in Azure AI Foundry before Logic Apps integration to validate risk analysis accuracy and optimize quantitative assessment delivery.

1. **Navigate to Azure AI Foundry**:
   - Access your AI Foundry deployment from the 02.03 lab
   - Select your **gpt-4o-mini** model deployment
   - Open the **Chat** interface

2. **Configure Testing Parameters**:

   ```json
   {
     "temperature": 0.2,
     "max_tokens": 450,
     "top_p": 0.95
   }
   ```

3. **Test System Message**:

   ```text
   You are a senior risk management analyst specializing in cybersecurity risk assessment and business impact quantification with expertise in enterprise risk frameworks. Your specializations include:

   RISK ASSESSMENT METHODOLOGY:
   - Conduct quantitative risk analysis using industry-standard frameworks (NIST, ISO 27001, FAIR)
   - Evaluate business impact across financial, operational, reputational, and regulatory dimensions
   - Assess threat likelihood and vulnerability exposure with probability modeling
   - Analyze control effectiveness and residual risk calculation for strategic decision-making

   BUSINESS IMPACT SPECIALIZATION:
   - Financial modeling: Direct costs, indirect costs, opportunity costs, and strategic investment implications
   - Operational assessment: Business continuity, service disruption, productivity impact, and recovery requirements
   - Strategic analysis: Competitive positioning, market confidence, innovation delays, and long-term business effects
   - Regulatory compliance: Violation costs, enforcement actions, ongoing oversight, and compliance investment needs

   RISK MANAGEMENT FRAMEWORK:
   - Risk scoring with confidence intervals and probability distributions
   - Mitigation strategy evaluation with cost-benefit analysis and ROI calculations
   - Timeline assessment for immediate, short-term, and long-term risk horizons
   - Residual risk evaluation and risk acceptance criteria alignment
   - Strategic implications for enterprise risk management and board governance

   Create actionable risk assessments that support data-driven decision-making for cybersecurity investments while aligning with organizational risk appetite and strategic business objectives.
   ```

### 🎯 AI Foundry Testing Scenarios

#### Test 1: Financial Services Infrastructure Compromise

##### User Message for Financial Services Testing

```text
Create comprehensive risk assessment for this critical banking infrastructure incident:

INCIDENT: Core banking platform compromise at regional bank affecting 500,000 customer accounts. Attack persisted 5 days undetected with confirmed data exfiltration of customer PII and transaction data. Online banking, mobile apps, and ATM network impacted. Payment processing disrupted for 18 hours. Preliminary forensics indicates nation-state attribution.

REQUIREMENTS:
- Quantitative risk scoring: Overall risk assessment with confidence intervals.
- Business impact analysis: Financial, operational, and reputational cost estimation.
- Threat landscape context: Industry alignment and attribution assessment.
- Control effectiveness: Current security posture evaluation and gaps.
- Strategic implications: Long-term competitive and regulatory impact.

TOKEN LIMIT: 450 tokens maximum
```

#### Expected AI Foundry Output Quality

- Quantitative risk scores with confidence intervals and probability ranges.
- Financial impact estimates with best/likely/worst case scenarios.
- Strategic business implications beyond immediate incident response.
- Evidence-based control effectiveness assessment and investment priorities.

#### Test 2: Healthcare Data Breach Scenario

##### User Message for Healthcare Testing

```text
Create detailed risk assessment for this healthcare provider incident:

INCIDENT: Regional hospital system EHR breach affecting 85,000 patient records including medical histories and diagnostic images. Medical device network partially compromised with patient safety implications. Ransomware deployed but contained. Evidence of 14-day unauthorized access with data staging for exfiltration. Clinical operations disrupted for 6 hours.

REQUIREMENTS:
- Risk profile with patient safety and regulatory focus.
- Financial impact including regulatory penalties and litigation exposure.
- Control effectiveness assessment for medical device security.
- Mitigation strategies with cost-benefit analysis and ROI.

TOKEN LIMIT: 450 tokens maximum
```

#### Response Quality Metrics

Validate each AI Foundry test produces:

- [ ] **Quantitative Accuracy**: Risk scores align with incident severity and business impact.
- [ ] **Financial Precision**: Cost estimates reflect realistic industry benchmarks.
- [ ] **Strategic Context**: Long-term business implications addressed comprehensively.
- [ ] **Token Compliance**: Response within 420-450 token range.
- [ ] **Decision Support**: Analysis supports investment and resource allocation decisions.

## Template Enhancement Context

Your AI Foundry model testing validated risk assessment and business impact capabilities. Logic Apps integration adds **automated risk analysis** for:

- Quantitative risk scoring from Defender XDR incidents with confidence intervals.
- Financial impact modeling across multiple cost categories and time horizons.
- Strategic business impact assessment for competitive positioning and market effects.
- Control effectiveness evaluation with investment prioritization and ROI analysis.

## Logic Apps Integration Quick Reference

This section provides the key data points needed to modify your Logic App being built in Week 3 to add risk assessment capabilities. The detailed implementation steps will be covered in future labs.

### AI Foundry System Message Update

**First, update your AI Foundry deployment** with the risk assessment system message from the testing section above. This ensures your model is optimized for quantitative risk analysis before Logic Apps integration.

1. **Navigate to Azure AI Foundry** → Your deployment → **Chat** interface
2. **Update System Message** with the comprehensive risk assessment prompt from the testing section
3. **Test the updated configuration** using the provided test scenarios
4. **Validate risk scoring accuracy and business impact precision** before proceeding to Logic Apps integration

### Logic App Configuration

Update the **Analyze Incident with AI** action in the logic app to use the following settings:

#### Message Configuration - Risk Assessment

Replace your existing **messages** array with this JSON configuration for easy copy-paste:

```json
[
  {
    "role": "system",
    "content": "You are a senior risk management analyst specializing in cybersecurity risk assessment and business impact quantification with expertise in enterprise risk frameworks. Focus on quantitative risk analysis using industry-standard frameworks, business impact evaluation across financial/operational/strategic dimensions, control effectiveness assessment with investment prioritization, and strategic implications for enterprise risk management. Create actionable risk assessments that support data-driven decision-making for cybersecurity investments."
  },
  {
    "role": "user", 
    "content": "Create comprehensive risk assessment for this Defender XDR incident: Title: [INCIDENT_TITLE], Description: [INCIDENT_DESCRIPTION], Severity: [INCIDENT_SEVERITY]. OUTPUT 5 SECTIONS: **RISK PROFILE:** Overall risk score with confidence intervals and risk categorization **BUSINESS IMPACT:** Financial impact ranges and operational disruption assessment **CONTROL ASSESSMENT:** Current security control effectiveness and investment priorities **MITIGATION ANALYSIS:** Risk reduction strategies with cost-benefit analysis and ROI **STRATEGIC IMPLICATIONS:** Long-term business effects and competitive positioning impact. REQUIREMENTS: Quantitative scoring, realistic financials, evidence-based assessments, TOKEN LIMIT: 450 tokens maximum."
  }
]
```

### Expected AI Response Structure

The AI will return structured output in this format:

```text
**RISK PROFILE:** [Risk scoring and categorization content]

**BUSINESS IMPACT:** [Financial and operational impact content]

**CONTROL ASSESSMENT:** [Security control effectiveness content]

**MITIGATION ANALYSIS:** [Risk reduction strategies content]

**STRATEGIC IMPLICATIONS:** [Long-term business impact content]
```

### Comment Parsing Configuration

**Update your existing comment extraction actions** with this structured approach for risk assessment:

#### Update Extract AI Analysis Sections (Existing Compose Action)

In your existing `Extract AI Analysis Sections` Compose action, **replace the current JSON content** with this risk assessment configuration:

```json
{
  "riskProfile": "@{first(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**BUSINESS IMPACT:**'))}",
  "businessImpact": "@{first(split(last(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**BUSINESS IMPACT:**')), '**CONTROL ASSESSMENT:**'))}",
  "controlAssessment": "@{first(split(last(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**CONTROL ASSESSMENT:**')), '**MITIGATION ANALYSIS:**'))}",
  "mitigationAnalysis": "@{first(split(last(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**MITIGATION ANALYSIS:**')), '**STRATEGIC IMPLICATIONS:**'))}",
  "strategicImplications": "@{last(split(first(body('Analyze Incident with AI')['choices'])['message']['content'], '**STRATEGIC IMPLICATIONS:**'))}"
}
```

#### Update Create Comments Array (Existing Compose Action)

In your existing `Create Comments Array` Compose action, **replace the current JSON content** with this risk assessment configuration:

```json
[
  {
    "prefix": "[Risk - Profile]",
    "content": "@{outputs('Extract AI Analysis Sections')['riskProfile']}",
    "order": 1
  },
  {
    "prefix": "[Risk - Business Impact]", 
    "content": "@{outputs('Extract AI Analysis Sections')['businessImpact']}",
    "order": 2
  },
  {
    "prefix": "[Risk - Control Assessment]",
    "content": "@{outputs('Extract AI Analysis Sections')['controlAssessment']}",
    "order": 3
  },
  {
    "prefix": "[Risk - Mitigation Analysis]",
    "content": "@{outputs('Extract AI Analysis Sections')['mitigationAnalysis']}",
    "order": 4
  },
  {
    "prefix": "[Risk - Strategic Impact]",
    "content": "@{outputs('Extract AI Analysis Sections')['strategicImplications']}",
    "order": 5
  }
]
```

### Cost Impact

| Metric | Default Setup | Risk Assessment Template | Difference |
|--------|----------------------|--------------------------|------------|
| **Cost per Incident** | ~$0.00018 | ~$0.00041 | **+$0.00023** (2.3x) |
| **Token Usage** | 180-200 tokens | 420-450 tokens | **+240 tokens** |
| **Execution Time** | 30-45 seconds | 120-180 seconds | **+90-135 seconds** |
| **Comments Generated** | 4 analysis comments | 5 risk assessments | **+1 comment** |

**Cost Justification**: The 2.3x cost increase provides comprehensive risk quantification and strategic business impact analysis, potentially supporting risk-informed decisions worth millions in avoided losses and optimized security investments.

## Template Customization

Adapt this template for your risk management framework by customizing risk scoring methodologies, business impact criteria, financial modeling approaches, and strategic alignment requirements to match your specific enterprise risk management environment.

### **Customization Areas**

**ORGANIZATIONAL RISK FRAMEWORK:**

- Customize for your specific risk scoring methodology and risk appetite statements.
- Include your risk management governance structure and decision-making authority.
- Adapt for your enterprise risk register and risk reporting requirements.

**BUSINESS IMPACT CRITERIA:**

- Add your specific business impact categories and quantitative metrics.
- Include your operational resilience and business continuity requirements.
- Customize for your industry positioning and competitive landscape considerations.

**FINANCIAL MODELING:**

- Include your cost accounting and financial impact measurement methodologies.
- Add your capital allocation and investment evaluation processes.
- Customize for your budgeting cycles and financial planning requirements.

**STRATEGIC ALIGNMENT:**

- Add your strategic planning horizons and business objective alignment.
- Include your competitive analysis and market intelligence integration.
- Customize for your innovation roadmaps and technology investment priorities.

---

## 🎯 Implementation Outcomes & Success Metrics

### **Expected Template Benefits**

- **Quantitative Risk Intelligence**: Generates comprehensive risk scores with confidence intervals enabling data-driven security investment decisions.
- **Financial Impact Precision**: Provides realistic cost estimates across multiple scenarios supporting accurate budgeting and resource allocation.
- **Strategic Business Alignment**: AI-driven analysis reduces risk assessment time by 70-80% while improving decision quality and board reporting.
- **Investment Optimization**: Built-in ROI analysis framework enables risk-informed prioritization of security controls and mitigation strategies.

### **Comprehensive Validation Checklist**

**Phase 1: AI Foundry Testing** (Complete before Logic Apps integration):

- [ ] AI Foundry testing completed with 450-token quantitative responses.
- [ ] Risk scoring accuracy validated in chat interface for multiple incident types.
- [ ] System message produces appropriate financial impact ranges and strategic context.
- [ ] User message format tested with sample incident data.
- [ ] Token usage remains within 420-450 range.
- [ ] Business impact analysis supports strategic decision-making requirements.

**Phase 2: Logic Apps Integration** (Validate after Week 3 implementation):

- [ ] Risk assessments appear correctly in Defender XDR portal with quantitative accuracy.
- [ ] Comment parsing separates risk profile vs. mitigation analysis appropriately.
- [ ] Token usage stays within cost parameters for comprehensive risk analysis.
- [ ] Financial impact estimates support budgeting and investment decision processes.
- [ ] Integration testing validates end-to-end workflow performance with risk management teams.

---

## 🤖 AI-Assisted Content Generation

This comprehensive risk assessment template was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating enterprise risk management best practices, Azure OpenAI integration patterns, and quantitative risk analysis methodologies for security operations workflows.

*AI tools were used to enhance productivity and ensure comprehensive coverage of risk assessment strategies while maintaining technical accuracy and reflecting modern enterprise risk management practices for organizational cybersecurity investment decision-making.*
