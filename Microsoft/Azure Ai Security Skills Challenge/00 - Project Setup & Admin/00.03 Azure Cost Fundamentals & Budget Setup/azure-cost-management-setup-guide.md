# Azure Cost Management & Budget Setup Guide

This comprehensive guide provides essential Azure cost concepts and step-by-step budget setup to protect your AI Security Skills Challenge learning environment from unexpected charges.

## 📋 Overview

Understanding Azure billing and setting up cost protection is essential before starting your hands-on labs. This guide combines the fundamental concepts with practical setup steps to get you ready for cost-effective learning.

## 💰 Azure Cost Fundamentals

### How Azure Pricing Works

**Pay-as-You-Go Model**:

- You only pay for resources you actually use.
- Billing is calculated hourly or per-transaction.
- Perfect for learning environments where usage varies.

**Key Cost Factors**:

- **Compute**: Virtual machines, app services, AI services (charged by usage time).
- **Storage**: Data storage, backups, file transfers (charged by gigabytes stored).
- **Networking**: Data moving between regions or to internet (charged by gigabytes transferred).

### Expected Learning Costs

| Week | Focus Area | Typical Cost Range | Key Cost Drivers |
|------|------------|-------------------|------------------|
| **Week 1** | Defender for Cloud Foundation | $8-15 | VMs, Log Analytics, monitoring |
| **Week 2** | AI Foundation & Storage | $5-12 | Storage accounts, OpenAI service testing |
| **Week 3** | Logic Apps & Integration | $3-8 | Logic App executions, API calls |
| **Total Monthly** | **All Learning Activities** | **$15-30** | **With proper resource management** |

> **💡 Cost Reality**: The $150 budget provides significant safety margin. Most students spend $15-30/month total when following cost-saving practices.

## 🛡️ Essential Cost-Saving Practices

### Before Each Lab Session

- Review current month's spending in Azure Cost Management.
- Clean up resources from previous weeks that are no longer needed.
- Verify budget alerts are working.

### During Lab Work

- **Stop VMs when not actively using them** (biggest cost saver).
- Use recommended resource sizes (typically the smallest available).
- Follow lab instructions carefully to avoid unnecessary resources.
- Disable services between learning sessions when possible.

### After Each Lab Session

- Review what resources were created.
- Keep only resources needed for next week's labs.
- Remove temporary test resources that generate ongoing charges.

## 🚀 Step-by-Step Budget Setup

### Prerequisites

- Active Azure subscription with billing access permissions.
- Valid email address for budget alert notifications.
- 15-20 minutes for setup and validation.

### Step 1: Access Azure Cost Management

Navigate to cost management features:

- Go to [portal.azure.com](https://portal.azure.com) and sign in.
- Search for **Cost Management + Billing** in the top search bar.
- Select **Cost Management + Billing** from results.
- Select your subscription from the list (this sets the scope for your budget).

### Step 2: Create Your Learning Budget

Set up cost protection:

- In the left sidebar, select **Budgets**.
- Select **Add** to create a new budget.
- Verify the correct scope is shown (your subscription).
- Configure your budget settings:

| Setting | Recommended Value | Purpose |
|---------|------------------|---------|
| **Budget name** | `AI-Security-Learning-Budget` | Clear identifier |
| **Reset period** | `Monthly` | Aligns with billing cycle |
| **Creation date** | `First day of current month` | Immediate activation |
| **Expiration date** | `6 months from now` | Covers full program |
| **Budget amount** | `150` | Safety threshold with buffer |

### Step 3: Configure Alert Notifications

Set up email alerts:

- Select **Next** after configuring budget details
- In **Alert conditions**, configure these alerts:

| Alert Type | Threshold | Recipients | Purpose |
|------------|----------|-----------|---------|
| **Actual** | **75%** ($112.50) | Your primary email | Early warning |
| **Actual** | **90%** ($135) | Your primary email + backup | Critical alert |

**Configuration Details**:

- Select **Actual** alert type (recommended for learning).
- Enter your email in **Alert recipients** field.
- Select your preferred **Email language**.
- Add backup recipients if desired.

### Step 4: Create and Validate

Complete the setup:

- Select **Create** to finalize your budget.
- Wait for **Budget created successfully** confirmation.
- Verify your budget appears in the **Budgets** list.
- Confirm **Status** shows as **Active**.

### Step 5: Test Alerts (Optional)

Verify notifications work:

- Edit your budget and temporarily set 75% alert to 1%.
- Update and wait 15-30 minutes for test email.
- Check email (including spam) for alerts from `azure-noreply@microsoft.com`.
- Reset alert threshold back to 75%.

## 🎯 Using Your Budget Effectively

### Regular Monitoring

- Navigate to **Cost Management + Billing** → **Budgets** for overview.
- Use **Cost Analysis** for detailed spending breakdown by service.
- Review spending trends weekly during your learning journey.

### Alert Response Guide

**75% Alert ($112.50)**:

- Review current spending in Cost Analysis.
- Clean up unnecessary resources from previous labs.
- Continue learning with increased cost awareness.

**90% Alert ($135)**:

- Immediate review of all active resources.
- Pause new deployments temporarily.
- Focus on completing current week's objectives.
- Consider budget adjustment if spending is legitimate learning activity.

## 🔧 Troubleshooting Common Issues

### Budget Not Creating

**Solutions**:

- Verify **Cost Management Contributor** permissions.
- Ensure budget amount is between $1-$1,000,000.
- Check subscription is active and in good standing.
- Wait up to 48 hours for new subscription cost management availability.

### Email Alerts Not Received

**Solutions**:

- Check spam/junk folders for `azure-noreply@microsoft.com`.
- Add `azure-noreply@microsoft.com` to approved senders.
- Verify email address in alert configuration.
- Alerts can take up to 1 hour after threshold evaluation.

### Budget Not Tracking Resources

**Solutions**:

- Verify budget scope includes your subscription.
- Check resources are in correct subscription.
- Review cost analysis to confirm resource tracking.

## ✅ Success Validation

After completing this guide, you should have:

- ✅ **Active $150 monthly budget** protecting your learning environment
- ✅ **Email alerts** at 75% and 90% thresholds
- ✅ **Cost visibility** through Azure Cost Management
- ✅ **Learning readiness** to start Week 1 with confidence

## 📈 Next Steps

With your budget setup complete:

1. **Bookmark Cost Management** for easy access.
2. **Plan weekly spending reviews** during your learning journey.
3. **Begin Week 1** Defender for Cloud labs with cost protection in place.
4. **Adjust budget** based on actual learning patterns if needed.

---

## 🤖 AI-Assisted Content Generation

This comprehensive Azure Cost Management & Budget Setup Guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, combining essential cost concepts with practical budget implementation for Azure learning environments.

*AI tools were used to enhance productivity while maintaining focus on cost-effective learning preparation and comprehensive budget protection setup.*
