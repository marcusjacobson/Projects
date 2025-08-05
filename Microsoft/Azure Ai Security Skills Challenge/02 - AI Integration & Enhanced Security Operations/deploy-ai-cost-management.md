# Deploy AI Cost Management

This guide implements comprehensive cost monitoring and automated budget controls for AI services. This is a critical first step before deploying any AI services to ensure you stay within the $150/month budget.

## 🎯 Overview

The AI cost management system provides:

- **Progressive Budget Alerts**: 50%, 75%, 90%, and 100% forecast alerts
- **Automated Monitoring**: Real-time cost tracking across AI and Week 1 resources
- **Email Notifications**: Immediate alerts when thresholds are reached
- **Cost Analytics**: Detailed breakdown of AI service usage and costs
- **Automated Controls**: Logic Apps for future automated service shutdown

## 💰 Budget Configuration

### Alert Thresholds

| Threshold | Purpose | Action |
|-----------|---------|--------|
| **50%** ($75) | Early Warning | Monitor usage patterns |
| **75%** ($112.50) | Action Required | Review and optimize services |
| **90%** ($135) | Critical Alert | Consider scaling down or pausing |
| **100%** (Forecast) | Predictive Alert | Automated intervention triggers |

### Scope Coverage

The budget monitors costs across:
- AI resource group (`rg-aisec-ai`)
- Week 1 resource group (`rg-aisec-defender-test`)
- Integrated cost tracking for complete lab oversight

## 🖱️ Azure Portal Deployment

### Step 1: Navigate to Cost Management

1. Sign in to the [Azure Portal](https://portal.azure.com)
2. Search for "Cost Management + Billing"
3. Select your subscription
4. Go to **Cost Management** > **Budgets**

### Step 2: Create Budget

1. Click **+ Add** to create a new budget
2. Configure budget settings:

| Setting | Value | Description |
|---------|--------|-------------|
| **Name** | `AI Security Lab Budget` | Descriptive budget name |
| **Reset Period** | `Monthly` | Monthly budget cycle |
| **Creation Date** | `Current month start` | When budget tracking begins |
| **Expiration Date** | `One year from now` | Budget duration |
| **Amount** | `150` | Monthly budget limit in USD |

### Step 3: Configure Scope

1. Select **Resource Group** scope
2. Add both resource groups:
   - `rg-aisec-ai` (AI services)
   - `rg-aisec-defender-test` (Week 1 infrastructure)

### Step 4: Set Up Alerts

Create four alert conditions:

#### Alert 1: Early Warning (50%)
- **Condition**: Actual cost
- **Threshold**: 50% of budget
- **Email**: Your notification email
- **Alert frequency**: Once per month

#### Alert 2: Action Required (75%)
- **Condition**: Actual cost
- **Threshold**: 75% of budget
- **Email**: Your notification email
- **Alert frequency**: Once per month

#### Alert 3: Critical (90%)
- **Condition**: Actual cost
- **Threshold**: 90% of budget
- **Email**: Your notification email
- **Alert frequency**: Once per month

#### Alert 4: Predictive (100%)
- **Condition**: Forecasted cost
- **Threshold**: 100% of budget
- **Email**: Your notification email
- **Alert frequency**: Once per month

### Step 5: Create Action Group

1. Go to **Monitor** > **Action Groups**
2. Click **+ Create**
3. Configure the action group:

| Setting | Value |
|---------|--------|
| **Name** | `AI Budget Alerts` |
| **Short Name** | `AIBudget` |
| **Email Action** | Your notification email |
| **Enable Common Schema** | ✅ Checked |

## 🔧 Infrastructure-as-Code Deployment

### Step 1: Update Parameters

Ensure your `main.parameters.json` includes:

```json
{
  "notificationEmail": {
    "value": "your-email@domain.com"
  },
  "monthlyBudgetLimit": {
    "value": 150
  },
  "enableCostManagement": {
    "value": true
  }
}
```

### Step 2: Deploy Using Azure CLI

```bash
# Deploy cost management components
az deployment sub create \
  --location "East US" \
  --template-file "infra/main.bicep" \
  --parameters "infra/main.parameters.json" \
  --parameters enableOpenAI=false enableSentinelIntegration=false enableAIStorage=false
```

### Step 3: Deploy Using PowerShell

```powershell
# Deploy cost management
New-AzSubscriptionDeployment `
  -Location "East US" `
  -TemplateFile "infra/main.bicep" `
  -TemplateParameterFile "infra/main.parameters.json" `
  -enableOpenAI $false `
  -enableSentinelIntegration $false `
  -enableAIStorage $false
```

## ⚡ Automated Script Deployment

Use the dedicated PowerShell script:

```powershell
# Navigate to scripts directory
cd "scripts"

# Deploy cost management
.\Deploy-CostManagement.ps1 -EnvironmentName "aisec" -NotificationEmail "your-email@domain.com" -BudgetLimit 150
```

## ✅ Validation Steps

### 1. Verify Budget Creation

```bash
# List budgets
az consumption budget list --scope "/subscriptions/{subscription-id}"
```

### 2. Test Alert Configuration

```powershell
# Check action group
Get-AzActionGroup -ResourceGroupName "rg-aisec-ai"
```

### 3. Validate Email Notifications

Test the alert system:
1. Check email delivery for action group test
2. Verify alert rules are active
3. Confirm budget thresholds are configured correctly

## 📊 Cost Monitoring Dashboard

### Daily Monitoring Routine

1. **Check Cost Analysis**:
   - Go to Cost Management > Cost Analysis
   - Filter by resource groups
   - Review daily spend trends

2. **Review Service Costs**:
   - Monitor Azure OpenAI usage
   - Track storage account costs
   - Validate Logic Apps consumption

3. **Optimize as Needed**:
   - Adjust OpenAI model capacity
   - Review storage retention policies
   - Scale down unused services

### Weekly Cost Review

Create a weekly routine to:
- Analyze cost trends and patterns
- Identify optimization opportunities
- Adjust budget allocations if needed
- Plan for upcoming AI service deployments

## 🔧 Advanced Cost Controls

### Automated Shutdown Logic App

The deployment includes a Logic App foundation for future automated controls:

```json
{
  "triggerCondition": "Budget threshold exceeded",
  "actions": [
    "Send detailed cost alert",
    "Log budget violation",
    "Prepare for automated scaling"
  ]
}
```

### Resource Tagging Strategy

All resources are tagged for cost tracking:
- `Environment`: Environment identifier
- `Project`: Azure AI Security Skills Challenge
- `CostCenter`: AI-Security-Integration
- `BudgetLimit`: Monthly budget amount

## 💡 Cost Optimization Tips

### Immediate Savings
- Use GPT-3.5-turbo instead of GPT-4 (90% cost savings)
- Implement token limits in prompts (500 max tokens)
- Use temperature 0.3 for focused responses
- Deploy minimal OpenAI capacity (10 units)

### Ongoing Optimization
- Monitor token usage patterns
- Implement prompt caching where possible
- Use batch processing for multiple requests
- Schedule non-critical AI operations during off-peak hours

## 🔍 Cost Troubleshooting

### High Costs Indicators

**Azure OpenAI**:
- High token usage per request
- Frequent API calls
- Using expensive models (GPT-4)
- High capacity deployment

**Storage**:
- Large file uploads
- Frequent access operations
- Long retention periods
- Premium storage tiers

**Logic Apps**:
- High execution frequency
- Complex workflows
- Premium connectors usage

### Quick Fixes

1. **Reduce OpenAI Capacity**: Scale down to minimum viable units
2. **Optimize Prompts**: Reduce token count and complexity
3. **Adjust Storage**: Implement lifecycle policies
4. **Review Logic Apps**: Optimize trigger frequency

## 🔗 Next Steps

After successful cost management deployment:

1. **[Deploy Azure OpenAI Service](./deploy-azure-openai-service.md)** - Add AI capabilities with cost controls
2. **Monitor Initial Costs** - Track baseline costs before AI services
3. **Set Up Weekly Reviews** - Establish cost monitoring routine

## 🛠️ Troubleshooting

### Common Issues

**Budget Not Creating**
- Verify subscription permissions
- Check resource group names exist
- Ensure email format is valid

**Alerts Not Firing**
- Verify action group configuration
- Check email spam folder
- Confirm budget scope includes correct resources

**Cost Data Delayed**
- Azure cost data has 24-48 hour delay
- Use Azure Cost Management for real-time estimates
- Monitor resource metrics for immediate feedback

## 📚 Additional Resources

- [Azure Cost Management Documentation](https://docs.microsoft.com/en-us/azure/cost-management-billing/)
- [Budget Alert Best Practices](https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/cost-mgt-alerts-monitor-usage-spending)
- [Azure OpenAI Pricing](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/openai-service/)

---

**📋 Deployment Status**: After completing this guide, mark cost management as configured in the [Week 2 checklist](./README.md#checklist).
