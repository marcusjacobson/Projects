# Configure AI Cost Management & Budgets - End of Week Setup

This guide provides comprehensive budget and cost monitoring setup for your AI Security Skills Challenge infrastructure. Perform these steps **at the end of Week 2** after all resources have been deployed and have generated initial cost data.

## 🎯 Overview

**When to Use This Guide:**
- At the end of Week 2 (after 24-48 hours of resource deployment)
- Before proceeding to Week 3 activities
- When planning for long-term resource management

**Why Separate Budget Setup:**
- Azure Cost Management requires 24-48 hours to recognize new resource groups
- Budget filters need existing cost data to populate resource options
- End-of-week timing ensures all resources are properly tracked

## 📋 Prerequisites

Before configuring budgets, ensure:

- All Week 2 AI infrastructure has been deployed for at least 24-48 hours
- Resources have generated some cost data (even minimal usage)
- You have Cost Management Contributor permissions
- All resource groups and services are actively running

**Required Infrastructure:**
- ✅ Resource group `rg-aisec-ai` with active resources
- ✅ Storage account with containers and some usage
- ✅ Azure OpenAI service (if deployed)
- ✅ Logic Apps (if deployed)
- ✅ Any additional AI services from Week 2

---

## 💰 Budget Configuration Strategy

### Budget Scope Recommendations

| Budget Type | Scope | Monthly Amount | Purpose |
|-------------|-------|----------------|---------|
| **AI Foundation** | Resource Group: `rg-aisec-ai` | $25 | Core storage and AI services |
| **AI Development** | Resource Group: `rg-aisec-dev` | $50 | Development and testing resources |
| **Overall AI Project** | Subscription (filtered) | $100 | Total AI project spending cap |

### Cost Expectations by Service

| Service | Expected Monthly Cost | Notes |
|---------|----------------------|--------|
| **Storage Account (LRS, Hot)** | $5-15 | Data volume dependent |
| **Azure OpenAI (GPT-4)** | $20-60 | Usage-based pricing |
| **Logic Apps** | $5-20 | Run frequency dependent |
| **Application Insights** | $2-10 | Log volume dependent |
| **Total Week 2 Foundation** | **$32-105/month** | Varies by usage patterns |

---

## 🚀 Step 1: Verify Resource Visibility

Before creating budgets, confirm all resources are visible in Cost Management.

### Check Cost Data Availability

1. Navigate to **Cost Management + Billing** in Azure Portal
2. Go to **Cost Management** → **Cost analysis**
3. Set scope to your subscription
4. Apply filters:
   - **Resource group**: `rg-aisec-ai`
   - **Time range**: Last 7 days
5. Verify you see cost data for your deployed resources

### Validate Resource Group Filters

1. In **Cost analysis**, click **Add filter**
2. Select **Resource group**
3. Confirm `rg-aisec-ai` appears in the dropdown options
4. If not visible, wait another 24 hours and retry

---

## 💸 Step 2: Create AI Foundation Budget

### Navigate to Budget Creation

1. In **Cost Management + Billing**, go to **Budgets**
2. Click **+ Add** to create a new budget
3. Configure the scope and filters for your AI foundation

### AI Storage Foundation Budget

**Primary budget for core AI storage and basic services:**

| Setting | Value | Purpose |
|---------|--------|---------|
| **Scope** | Resource Group: `rg-aisec-ai` | Target AI-specific resources |
| **Name** | `AI Storage Foundation - Week 2` | Clear identification |
| **Amount** | `$25` | Conservative foundation budget |
| **Reset period** | `Monthly` | Standard monthly tracking |
| **Budget period** | Start: Current month, End: 3 months | Project duration |

### Alert Configuration

Set up proactive monitoring with multiple alert thresholds:

| Alert Type | Threshold | Recipients | Action |
|------------|-----------|------------|--------|
| **Early Warning** | 50% ($12.50) | Your email | Monitor usage patterns |
| **Management Alert** | 75% ($18.75) | Your email + manager | Review resource usage |
| **Critical Alert** | 90% ($22.50) | Your email + manager | Immediate action required |
| **Forecasted Alert** | 100% forecasted | Your email | Projected overage warning |

---

## 🔍 Step 3: Create Service-Specific Budgets

### Azure OpenAI Service Budget

If you've deployed Azure OpenAI services:

| Setting | Value |
|---------|--------|
| **Scope** | Subscription |
| **Filters** | Service name: `Cognitive Services` |
| **Name** | `Azure OpenAI - AI Security Project` |
| **Amount** | `$50` |
| **Alerts** | 60%, 80%, 95% |

### Logic Apps Budget

For AI automation workflows:

| Setting | Value |
|---------|--------|
| **Scope** | Subscription |
| **Filters** | Service name: `Logic Apps` |
| **Name** | `Logic Apps - AI Automation` |
| **Amount** | `$20` |
| **Alerts** | 70%, 85%, 95% |

---

## 📊 Step 4: Configure Cost Monitoring

### Set Up Cost Alerts

Beyond budgets, configure subscription-level anomaly detection:

1. Go to **Cost Management** → **Cost alerts**
2. Click **+ Add** → **Anomaly alert**
3. Configure:
   - **Scope**: Subscription
   - **Alert name**: `AI Project Cost Anomaly`
   - **Email recipients**: Your contact information

### Weekly Cost Review Setup

Schedule regular cost reviews:

1. **Cost Analysis Saved Views**:
   - Create custom view: "AI Weekly Costs"
   - Filter by: Resource group `rg-aisec-ai`
   - Group by: Service name
   - Save and pin to dashboard

2. **Cost Export** (Optional):
   - Set up automated export for detailed analysis
   - Export scope: Resource group `rg-aisec-ai`
   - Schedule: Weekly on Sunday nights

---

## 🎯 Step 5: Budget Management Best Practices

### Cost Optimization Strategies

**For Storage Accounts:**
- Monitor container usage patterns
- Consider cool tier for infrequently accessed AI models
- Review and clean up test data regularly

**For Azure OpenAI:**
- Track token usage and optimize prompts
- Use appropriate model tiers (GPT-3.5 vs GPT-4)
- Implement request throttling in applications

**For Logic Apps:**
- Optimize trigger frequency
- Use consumption vs standard pricing based on usage
- Review and consolidate workflow runs

### Ongoing Management

**Weekly Tasks:**
- Review cost trends in Cost Analysis
- Check budget alert emails and take action
- Verify resource usage aligns with project needs

**Monthly Tasks:**
- Adjust budget amounts based on usage patterns
- Review and optimize underutilized resources
- Update forecasts for upcoming project phases

---

## 🚨 Budget Alert Response Guide

### 50% Budget Alert Response

1. **Review** current month's spending pattern
2. **Analyze** which services are driving costs
3. **Document** usage patterns for future planning
4. **Continue** normal operations with awareness

### 75% Budget Alert Response

1. **Investigate** unexpected cost drivers
2. **Review** resource configurations for optimization opportunities
3. **Consider** scaling down non-essential resources
4. **Communicate** with team about usage patterns

### 90% Budget Alert Response

1. **Immediate review** of all active resources
2. **Identify** and stop non-essential services
3. **Implement** cost controls (quotas, throttling)
4. **Plan** for additional budget if needed for project completion

---

## 📋 Deployment Checklist

Complete budget setup verification:

- ✅ Resource group `rg-aisec-ai` visible in Cost Management filters
- ✅ AI Foundation Budget ($25) created with 50%, 75%, 90% alerts
- ✅ Service-specific budgets configured for OpenAI and Logic Apps
- ✅ Anomaly detection enabled for subscription
- ✅ Weekly cost review view saved and dashboard configured
- ✅ Budget alert response procedures documented
- ✅ Team contact information configured for critical alerts

### 📝 Budget Configuration Summary

Record your budget setup:

```text
AI Cost Management Configuration
================================
Setup Date: [Date]
Primary Budget: $25/month (rg-aisec-ai)
OpenAI Budget: $50/month (Cognitive Services)
Logic Apps Budget: $20/month (Logic Apps)
Total AI Project Cap: $100/month
Alert Recipients: [Your email addresses]
Review Schedule: Weekly (Sundays)
```

---

## 🔗 Integration with Project Phases

### Week 2 Completion
- Budget foundation established
- Cost monitoring active
- Usage patterns baseline created

### Week 3 Preparation
- Budget allocations adjusted for security integrations
- Additional resource group budgets as needed
- Enhanced monitoring for production-like workloads

### Project Continuation
- Budget adjustments based on actual usage
- Cost optimization implementations
- Resource lifecycle management

---

## 🛠️ Troubleshooting Budget Issues

### Resource Group Not Visible in Filters

**Symptoms**: `rg-aisec-ai` doesn't appear in budget filter dropdown

**Solutions**:
1. Wait 24-48 hours after resource creation
2. Verify resources have generated usage data
3. Check Cost Analysis shows resource group data
4. Create subscription-level budget with resource group filter instead

### Budget Alerts Not Triggering

**Symptoms**: Exceeding thresholds but no email alerts

**Solutions**:
1. Verify email addresses are correct in budget configuration
2. Check spam/junk folders for azure-noreply@microsoft.com
3. Add azure-noreply@microsoft.com to safe sender list
4. Test with lower threshold (e.g., 10%) to verify alert functionality

### Inaccurate Cost Forecasting

**Symptoms**: Forecast doesn't match actual usage patterns

**Solutions**:
1. Allow 30+ days for forecast accuracy improvement
2. Review and remove one-time setup costs from forecast period
3. Use actual cost alerts instead of forecasted for immediate response
4. Manually calculate expected monthly costs based on service pricing

---

## 📚 Additional Resources

- [Azure Cost Management Best Practices](https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/cost-mgt-best-practices)
- [Budget Alert Automation](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/cost-management-budget-scenario)
- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- [OpenAI Service Pricing](https://azure.microsoft.com/pricing/details/cognitive-services/openai-service/)

---

**📋 Status**: Complete this budget setup at the end of Week 2 to ensure accurate cost monitoring for ongoing AI Security Skills Challenge activities.
