# Week 2 Cost Analysis Guide

This comprehensive guide provides detailed analysis procedures for evaluating actual costs from your deployed Week 2 AI foundation infrastructure and validating spending against budget projections.

## 📋 Overview

Understanding your actual Week 2 costs enables informed decision-making for future deployments and helps identify optimization opportunities specific to AI foundation services.

## 💰 Week 2 AI Foundation Cost Analysis

### Expected vs Actual Cost Review

**Expected Week 2 Costs** (From Week 00 projections):

| Service Category | Expected Monthly Cost | Notes |
|------------------|---------------------|-------|
| **Azure OpenAI Service** | $15-25 | GPT-4o-mini with 100 TPM capacity |
| **Storage Account** | $1-3 | Standard_LRS with basic lifecycle policies |
| **Application Insights** | $2-5 | Basic monitoring and logging |
| **Supporting Services** | $3-8 | Key Vault, networking, tags |
| **Total Week 2 Expected** | **$21-41** | Conservative learning environment estimate |

### Deployed Infrastructure Cost Review

**Analyze Your Actual Spending** from modules 02.02-02.06:

Navigate to **Cost Management + Billing** → **Cost Analysis** to review:

- **Storage Account Costs** (02.02): Blob storage, tables, and lifecycle policy overhead
- **Azure OpenAI Service Costs** (02.03): GPT-4o-mini token consumption and capacity charges
- **Model Customization Costs** (02.04): System instruction processing and configuration overhead
- **Prompt Template Costs** (02.05): Template testing and validation token usage
- **Validation Testing Costs** (02.06): Comprehensive testing and performance baseline establishment

### Cost Attribution Analysis

**Resource Group Cost Breakdown**:

```powershell
# Analyze costs by resource group for Week 2 infrastructure
az cost-management query --scope="/subscriptions/$(az account show --query id -o tsv)" \
  --dataset-aggregation='{"totalCost":{"name":"PreTaxCost","function":"Sum"}}' \
  --dataset-grouping='[{"type":"Dimension","name":"ResourceGroup"}]' \
  --timeframe="MonthToDate" \
  --dataset-filter='{"dimensions":{"name":"ResourceGroup","operator":"In","values":["rg-aisec-ai"]}}'
```

**Service-Level Cost Analysis**:

```powershell
# Detailed breakdown by service type
az cost-management query --scope="/subscriptions/$(az account show --query id -o tsv)" \
  --dataset-aggregation='{"totalCost":{"name":"PreTaxCost","function":"Sum"}}' \
  --dataset-grouping='[{"type":"Dimension","name":"ServiceName"}]' \
  --timeframe="MonthToDate" \
  --dataset-filter='{"tags":{"name":"Component","operator":"In","values":["AI-Foundation"]}}'
```

## 🎯 Azure OpenAI Service Cost Deep Dive

### Token Usage Analysis

**Actual Token Consumption Review**:

Based on your deployed GPT-4o-mini model from module 02.04:

```powershell
# Retrieve actual token usage metrics
az cognitiveservices account list-usage \
  --name "oai-aisec-ai" \
  --resource-group "rg-aisec-ai" \
  --query "value[?name.value=='TokenTransaction']" \
  --output table

# Alternative: Monitor API usage through Azure Monitor
az monitor metrics list \
  --resource "/subscriptions/{subscription}/resourceGroups/rg-aisec-ai/providers/Microsoft.CognitiveServices/accounts/oai-aisec-ai" \
  --metric "TokenTransaction" \
  --interval PT1H \
  --start-time $(Get-Date -Format "yyyy-MM-01T00:00:00Z")
```

**Token Cost Breakdown Analysis**:

```json
{
  "week2_token_analysis": {
    "learning_activities": {
      "module_02_04_testing": "~50K tokens",
      "module_02_05_templates": "~75K tokens", 
      "module_02_06_validation": "~100K tokens"
    },
    "total_estimated_tokens": "~225K tokens",
    "cost_calculation": {
      "input_tokens": "150K × $0.15/1M = $0.023",
      "output_tokens": "75K × $0.60/1M = $0.045",
      "total_token_cost": "~$0.07 for learning activities",
      "capacity_cost": "$15-25/month for 100 TPM reservation"
    }
  }
}
```

### Usage Pattern Optimization Opportunities

**Analyze Your Actual Usage Patterns**:

- **Peak Usage Times**: When do you use AI services most frequently during Week 2?
- **Token Efficiency**: What's your cost per security analysis from testing activities?
- **Capacity Utilization**: Is your 100 TPM capacity appropriate for actual usage patterns?
- **Response Quality vs Cost**: How well do 450-token limits balance analysis quality with cost?

**Cost Per Analysis Calculation**:

```powershell
# Calculate average cost per security analysis
$totalTokenCost = 0.07  # From your actual usage analysis
$analysesPerformed = 25  # Count from your Week 2 testing
$costPerAnalysis = $totalTokenCost / $analysesPerformed

Write-Output "Average cost per security analysis: $($costPerAnalysis.ToString('C4'))"
```

## 🗄️ Storage Account Cost Analysis

### Storage Utilization Review

**Analyze Your Storage Costs** from module 02.02 deployment:

```powershell
# Storage account usage and cost analysis
az storage account show-usage \
  --account-name "staisecai" \
  --resource-group "rg-aisec-ai"

# Detailed storage metrics
az monitor metrics list \
  --resource "/subscriptions/{subscription}/resourceGroups/rg-aisec-ai/providers/Microsoft.Storage/storageAccounts/staisecai" \
  --metric "UsedCapacity" \
  --interval P1D \
  --start-time $(Get-Date -Format "yyyy-MM-01T00:00:00Z")
```

**Storage Cost Components Analysis**:

| Cost Component | Week 2 Usage | Monthly Cost | Optimization Opportunity |
|----------------|--------------|--------------|-------------------------|
| **Blob Storage (Hot)** | ~5-10 GB | $0.05-0.18 | Move infrequent data to Cool tier |
| **Table Storage** | ~1-2 GB | $0.05-0.10 | Optimize table structure |
| **Transactions** | ~10K operations | $0.02-0.05 | Batch operations where possible |
| **Data Transfer** | ~1-2 GB | $0.09-0.17 | Minimize cross-region transfers |

### Storage Optimization Opportunities

**Lifecycle Policy Impact Assessment**:

```json
{
  "storage_optimization_analysis": {
    "current_configuration": {
      "primary_tier": "Hot",
      "lifecycle_policies": "Basic cleanup after 365 days",
      "redundancy": "Standard_LRS"
    },
    "optimization_opportunities": {
      "cool_tier_migration": {
        "trigger": "Data older than 30 days",
        "savings_potential": "20-30%",
        "implementation": "Automated lifecycle policy"
      },
      "archive_tier_usage": {
        "trigger": "Data older than 90 days",
        "savings_potential": "40-60%", 
        "consideration": "Compliance retention requirements"
      },
      "cleanup_automation": {
        "trigger": "Temporary files older than 7 days",
        "savings_potential": "10-15%",
        "implementation": "Automated cleanup scripts"
      }
    }
  }
}
```

## 📊 Supporting Services Cost Analysis

### Infrastructure Supporting Costs

**Review Supporting Service Costs**:

| Service | Week 2 Usage | Expected Cost | Optimization Notes |
|---------|--------------|---------------|-------------------|
| **Key Vault** | 1 vault, ~50 operations | $1-2/month | Minimal optimization potential |
| **Application Insights** | Basic monitoring | $2-5/month | Adjust retention if high volume |
| **Virtual Network** | Basic networking | $1-3/month | Consider peering optimization |
| **Resource Management** | Tagging, policies | $0-1/month | No optimization needed |

### Cost Attribution Validation

**Verify Proper Cost Attribution**:

```powershell
# Validate resource tagging for accurate cost tracking
az resource list \
  --resource-group "rg-aisec-ai" \
  --query "[].{Name:name, Tags:tags}" \
  --output table

# Check for untagged resources affecting cost attribution
az resource list \
  --resource-group "rg-aisec-ai" \
  --query "[?tags==null].{Name:name, Type:type, Location:location}" \
  --output table
```

**Expected Tag Structure Validation**:

```json
{
  "required_cost_tags": {
    "Project": "AI-Security-Skills-Challenge",
    "Week": "Week-02",
    "Component": "AI-Foundation", 
    "Environment": "Learning",
    "Owner": "learner-email@domain.com"
  },
  "cost_attribution_benefits": {
    "accurate_tracking": "Component-level cost visibility",
    "trend_analysis": "Week-over-week cost comparison",
    "optimization_targeting": "Service-specific optimization focus"
  }
}
```

## 📈 Cost Variance Analysis

### Budget vs Actual Comparison

**Analyze Spending Variance**:

```powershell
# Compare actual spending to Week 2 budget allocation
az consumption budget list \
  --scope="/subscriptions/$(az account show --query id -o tsv)" \
  --query "[?name=='AI-Security-Learning-Budget'].{Name:name, Amount:amount, CurrentSpend:currentSpend}" \
  --output table
```

**Variance Analysis Framework**:

| Category | Budgeted | Actual | Variance | Analysis |
|----------|----------|--------|----------|----------|
| **OpenAI Services** | $20 | $XX | +/-$XX | Token usage efficiency |
| **Storage Services** | $5 | $XX | +/-$XX | Data accumulation patterns |
| **Supporting Services** | $10 | $XX | +/-$XX | Infrastructure overhead |
| **Total Week 2** | $35 | $XX | +/-$XX | Overall learning efficiency |

### Trend Analysis and Forecasting

**Project Week 3 Costs Based on Week 2 Patterns**:

```json
{
  "week3_cost_projection": {
    "base_week2_cost": "$XX (actual Week 2 spending)",
    "automation_additions": {
      "logic_apps": "$5-10/month",
      "additional_storage": "$3-5/month", 
      "enhanced_monitoring": "$2-4/month"
    },
    "projected_week3_total": "$XX + $10-19 = $XX-XX/month",
    "optimization_opportunities": {
      "week2_learnings": "Apply Week 2 optimization to Week 3",
      "automation_efficiency": "Batch processing cost savings",
      "scaling_considerations": "Volume discounts and reserved capacity"
    }
  }
}
```

## 🔍 Cost Health Assessment

### Week 2 Cost Health Checklist

Validate the health of your Week 2 cost management:

#### Budget Adherence Assessment

- [ ] **Within Budget**: Actual Week 2 costs are within expected $21-41 range
- [ ] **Service Distribution**: Costs appropriately distributed across OpenAI, storage, and support services
- [ ] **No Unexpected Charges**: No surprise services or excessive usage charges
- [ ] **Alert Functionality**: Budget alerts triggered appropriately based on spending

#### Resource Efficiency Assessment

- [ ] **OpenAI Efficiency**: Token usage aligns with expected learning activities (~225K tokens)
- [ ] **Storage Optimization**: Storage growth patterns are reasonable for learning activities
- [ ] **Resource Utilization**: No significantly underutilized or oversized resources
- [ ] **Cost Attribution**: All resources properly tagged for accurate cost tracking

#### Optimization Readiness Assessment

- [ ] **Baseline Established**: Clear understanding of Week 2 baseline costs for comparison
- [ ] **Patterns Documented**: Usage patterns documented for future optimization
- [ ] **Opportunities Identified**: Specific optimization opportunities identified and prioritized
- [ ] **Week 3 Planning**: Cost projections prepared for Week 3 automation scaling

### Cost Optimization Priority Matrix

**Prioritize optimization efforts based on impact and effort**:

| Optimization | Cost Impact | Implementation Effort | Priority | Timeline |
|--------------|-------------|----------------------|----------|----------|
| **Token Efficiency** | High ($5-15/month) | Medium | High | Immediate |
| **Storage Lifecycle** | Medium ($2-8/month) | Low | High | This week |
| **Resource Right-sizing** | Medium ($3-10/month) | Medium | Medium | Next week |
| **Alert Refinement** | Low (risk mitigation) | Low | Medium | Ongoing |

## 📋 Week 2 Cost Analysis Summary

### Key Findings Documentation

**Document your Week 2 cost analysis findings**:

```json
{
  "week2_cost_analysis_summary": {
    "actual_total_cost": "$XX.XX",
    "budget_variance": "+/-$XX.XX (+/-XX%)",
    "highest_cost_service": "Service name ($XX.XX)",
    "biggest_surprise": "Description of unexpected cost",
    "optimization_potential": "$XX.XX savings identified",
    "week3_projection": "$XX.XX projected monthly cost"
  },
  "key_learnings": [
    "Learning 1: Specific insight about costs",
    "Learning 2: Optimization opportunity discovered", 
    "Learning 3: Usage pattern insight"
  ],
  "action_items": [
    "Action 1: Specific optimization to implement",
    "Action 2: Budget adjustment needed",
    "Action 3: Week 3 planning consideration"
  ]
}
```

### Next Steps Planning

**Prepare for Week 3 Cost Management**:

1. **Apply Week 2 Optimizations**: Implement identified cost savings before Week 3
2. **Adjust Budget Projections**: Update Week 3 budget based on actual Week 2 spending
3. **Refine Monitoring**: Adjust alerts and monitoring based on actual usage patterns
4. **Document Baseline**: Establish Week 2 as cost baseline for automation scaling evaluation

---

## 🤖 AI-Assisted Content Generation

This comprehensive Week 2 Cost Analysis Guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Azure cost analysis methodologies, AI service cost optimization strategies, and practical cost attribution techniques for educational environments.

*AI tools were used to enhance productivity and ensure comprehensive coverage of AI foundation cost analysis while maintaining technical accuracy and reflecting current Azure Cost Management capabilities for AI-driven security operations.*
