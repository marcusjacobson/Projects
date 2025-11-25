# 00.01 Prerequisites & Environment Validation

This module covers the essential prerequisites and initial environment validation required before beginning the Azure AI Security Skills Challenge. Successful completion ensures your development environment meets all technical requirements for the 9-week learning journey.

## 🎯 Objectives

- Verify Azure subscription access and permissions.
- Validate regional requirements and service availability.
- Establish foundational understanding of required Azure services.
- Confirm subscription quotas and limits meet project requirements.
- Document baseline environment configuration for troubleshooting.

## 📋 Prerequisites Checklist

### Azure Subscription Requirements

**Essential Subscription Configuration:**

- [ ] **Active Azure Subscription**: Valid subscription with active billing status.
- [ ] **Subscription Type**: Pay-as-you-go, Visual Studio, or Enterprise Agreement subscription.
- [ ] **Permission Level**: Owner or Contributor permissions at subscription level.
- [ ] **Billing Access**: Access to cost management and billing information.
- [ ] **Multi-Factor Authentication**: MFA enabled for enhanced security.

> **💡 Production Tip**: Use a dedicated learning subscription to avoid conflicts with production resources and enable full experimentation without organizational constraints.

### Regional Requirements

**Deployment Region Configuration:**

- [ ] **Primary Region**: East US region access confirmed.
- [ ] **Service Availability**: Verify all required Azure services are available in East US.
- [ ] **Quota Validation**: Sufficient VM quotas available in East US region.
- [ ] **Compliance Requirements**: Organizational policies allow East US deployments.

> **⚠️ Regional Compliance**: East US is mandatory for complete AI security feature availability, including UEBA, Security Copilot, and advanced analytics services required in later weeks.

### Azure Service Requirements

**Core Services Validation:**

- [ ] **Microsoft Defender for Cloud**: Available and accessible in your subscription.
- [ ] **Azure OpenAI Service**: Regional availability confirmed for GPT models.
- [ ] **Microsoft Sentinel**: Access to advanced security analytics features.
- [ ] **Log Analytics**: Workspace creation and data ingestion capabilities.
- [ ] **Azure Storage**: Standard storage account creation permissions.
- [ ] **Azure Key Vault**: Secret management and secure configuration storage.
- [ ] **Azure Logic Apps**: Workflow automation and integration capabilities.

> **🔒 Security Notice**: Some advanced features require specific subscription types or additional licensing. Verify availability before proceeding with deployment planning.

### Subscription Limits and Quotas

**Resource Quota Validation:**

- [ ] **Virtual Machine Quotas**: Minimum 10 Standard_D2s_v3 VMs available.
- [ ] **Storage Account Limits**: Ability to create multiple storage accounts.
- [ ] **Defender Plan Quotas**: Standard tier availability for required resource types.
- [ ] **OpenAI Service Limits**: Model deployment quotas and token limits verified.
- [ ] **Log Analytics Workspace**: Data ingestion and retention limit verification.

> **💡 Quota Management**: Use the Azure portal's "Usage + quotas" section to verify current limits and request increases if needed before starting Week 1 deployments.

## ✅ Validation Steps

### Step 1: Azure Portal Access Verification

Confirm comprehensive Azure portal access and navigation capabilities:

- Navigate to the Azure portal ([portal.azure.com](https://portal.azure.com)).
- Verify subscription appears in subscription selector.
- Access the "All services" menu to confirm service availability.
- Navigate to "Cost Management + Billing" to verify billing access.

### Step 2: Service Availability Check

Validate that all required Azure services are available in your subscription:

- **Defender for Cloud**: Navigate to Microsoft Defender for Cloud service.
- **OpenAI Service**: Search for "Azure OpenAI" in the portal search.
- **Microsoft Sentinel**: Verify Sentinel service accessibility.
- **Resource Creation**: Test ability to create a resource group.

### Step 3: Regional Access Confirmation

Verify East US region access and service availability:

- Navigate to "Create a resource" → "Virtual Machine".
- Select East US as the region and verify available VM sizes.
- Check that advanced AI services show East US availability.
- Confirm no organizational policies block East US deployments.

### Step 4: Permission Level Verification

Confirm appropriate subscription permissions for resource management:

- Navigate to your subscription's "Access control (IAM)" section.
- Verify you have Owner or Contributor role assignment.
- Test resource group creation to confirm permissions.
- Validate ability to assign roles and manage policies.

## 🎯 Expected Results

Upon successful completion of this module:

- **Subscription Ready**: Azure subscription configured with appropriate access and permissions.
- **Regional Compliance**: East US region validated for all required services.
- **Service Accessibility**: All Azure AI Security services confirmed available.
- **Quota Sufficiency**: Resource limits verified to support full curriculum.
- **Baseline Documentation**: Environment configuration documented for troubleshooting reference.

## 🔄 Next Steps

After completing all prerequisite validations:

1. **Proceed to Module 00.02**: [Development Environment Setup](../00.02-Development-Environment-Setup/README.md).
2. **Document Configuration**: Save baseline configuration details for future reference.
3. **Plan Resource Organization**: Consider resource group naming strategy for the 9-week curriculum.

## 📚 Additional Resources

### Azure Documentation

- **Azure Subscription Guide**: [Azure subscription and service limits](https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits)
- **Regional Availability**: [Azure products available by region](https://azure.microsoft.com/en-us/global-infrastructure/services/)
- **Permission Management**: [Azure role-based access control (RBAC)](https://docs.microsoft.com/en-us/azure/role-based-access-control/)

### Cost Management Resources

- **Azure Pricing**: [Azure pricing calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
- **Cost Planning**: [Plan and manage costs](https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/plan-manage-costs)

---

## 🤖 AI-Assisted Content Generation

This comprehensive prerequisites and validation guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating essential Azure subscription requirements, regional compliance standards, and security validation procedures for the Azure AI Security Skills Challenge curriculum.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Azure environment prerequisites while maintaining technical accuracy and reflecting enterprise-grade deployment preparation standards.*
