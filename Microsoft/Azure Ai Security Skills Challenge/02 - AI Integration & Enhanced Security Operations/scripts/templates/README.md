# Sentinel Integration Templates

This directory contains JSON templates for configuring Azure OpenAI + Sentinel integration using Logic Apps. These templates provide standardized configurations for various integration scenarios.

## 📋 Template Files Overview

### Core Integration Templates

| Template File | Purpose | Usage |
|--------------|---------|--------|
| **openai-action-configuration.json** | Azure OpenAI API configuration | Logic App OpenAI connector setup |
| **parse-json-schema.json** | Response parsing structure | Parse JSON action schema |
| **trigger-filters.json** | Incident filtering criteria | Sentinel trigger configuration |

### Advanced AI Prompt Templates

| Template File | Purpose | Token Limit | Use Case |
|--------------|---------|-------------|----------|
| **threat-hunting-prompt.json** | Advanced threat analysis | 400 tokens | APT detection, IOC generation |
| **executive-summary-prompt.json** | Business-friendly reporting | 200 tokens | Executive briefings |
| **compliance-prompt-template.json** | Regulatory compliance analysis | 300 tokens | Compliance gap reporting |

### Cost Management Templates

| Template File | Purpose | Cost Impact |
|--------------|---------|-------------|
| **budget-monitoring-config.json** | Budget threshold monitoring | Prevents overspend |
| **conditional-logic.json** | Budget-based processing control | Automated cost controls |
| **batch-processing-config.json** | Efficient bulk processing | ~$0.002 per 5 incidents |
| **optimized-prompt-config.json** | Cost-conscious prompt settings | Reduced token consumption |

### Testing and Validation Templates

| Template File | Purpose | Validation Type |
|--------------|---------|-----------------|
| **error-recovery-validation.json** | Failure scenario testing | Error handling validation |
| **xdr-alert-correlation.json** | Cross-product integration | XDR correlation testing |

## 🔧 How to Use Templates

### In Logic Apps Designer

1. **Copy template content** from the JSON file
2. **Paste into Logic App action** configuration
3. **Customize dynamic content** placeholders (e.g., `@{triggerBody()}`)
4. **Test configuration** before deploying to production

### Template Customization

#### Dynamic Content Placeholders

Templates use Logic Apps dynamic content syntax:

```json
{
  "content": "Analyze incident @{triggerBody()?['properties']?['title']}"
}
```

Replace placeholders with actual Logic App trigger/action outputs.

#### Environment-Specific Values

Update these values for your environment:

- **Resource Group Names**: Change `rg-ai-integration-eastus` to your naming convention
- **Budget Names**: Update `ai-security-budget` to your budget resource name
- **Deployment IDs**: Modify `o4-mini-deployment` to match your OpenAI model deployment
- **Token Limits**: Adjust based on your cost requirements and analysis depth needs

## 💰 Cost Optimization Guidelines

### Token Management by Template

| Template | Default Tokens | Cost per Use | Optimization Tips |
|----------|----------------|-------------|-------------------|
| **Basic Analysis** | 500 tokens | ~$0.0003 | Use for standard incident triage |
| **Threat Hunting** | 400 tokens | ~$0.0002 | Reserve for high-severity incidents |
| **Executive Summary** | 200 tokens | ~$0.0001 | Batch process low-priority alerts |
| **Compliance Report** | 300 tokens | ~$0.0002 | Weekly/monthly scheduled runs |

### Monthly Cost Estimates

Based on 1000 incidents per month using o4-mini:

- **Mixed Usage**: $5-8/month (recommended distribution)
- **High-Complexity Only**: $10-15/month (all incidents use threat hunting template)
- **Basic Only**: $3-5/month (standard analysis template only)

## 🔍 Template Validation

### JSON Schema Validation

All templates follow proper JSON formatting and Logic Apps dynamic content syntax. Validate before deployment:

```powershell
# PowerShell validation example
$template = Get-Content "openai-action-configuration.json" | ConvertFrom-Json
if ($template) { Write-Host "Template valid" } else { Write-Host "Template invalid" }
```

### Integration Testing

Use templates with Logic Apps **Test** functionality:

1. **Load template** into Logic App action
2. **Replace placeholders** with test data
3. **Run Logic App test** to validate functionality
4. **Review outputs** for expected format and content

## 📚 Related Documentation

- **[Main Deployment Guide](../deploy-openai-defender-xdr-integration.md)** - Complete integration walkthrough
- **[AI Prompt Templates](../ai-prompt-templates.md)** - Additional prompt engineering guidance
- **[Cost Management Guide](../deploy-ai-cost-management.md)** - Budget monitoring and controls

## 🔧 Troubleshooting Templates

### Common Issues

| Issue | Cause | Solution |
|-------|-------|---------|
| **JSON Parse Error** | Invalid JSON syntax | Validate JSON format |
| **Dynamic Content Failed** | Incorrect placeholder syntax | Verify `@{...}` expressions |
| **Template Not Found** | Incorrect file path | Check relative path references |
| **Token Limit Exceeded** | Template too verbose | Use optimized prompt templates |

### Template Updates

When updating templates:

1. **Test in development** Logic App first
2. **Validate with sample data** before production deployment  
3. **Update documentation** if functionality changes
4. **Monitor cost impact** of template modifications

---

**📋 Usage Note**: All templates are optimized for o4-mini deployment for cost-effective operations. Token limits are designed for budget-conscious security analysis while maintaining analytical quality.
