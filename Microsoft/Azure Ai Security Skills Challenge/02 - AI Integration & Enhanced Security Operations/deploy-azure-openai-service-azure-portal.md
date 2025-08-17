# Deploy Azure OpenAI Service Using Azure Portal

This comprehensive guide walks you through deploying Azure OpenAI Service using the Azure Portal interface. This method is ideal for learning Azure OpenAI components, understanding configuration options, and gaining hands-on experience before implementing automated deployments.

**Note**: This guide focuses on cost-effective deployment optimized for cybersecurity learning scenarios with o4-mini and optional GPT-5 exploration capabilities.

## 🎯 Overview

This Azure Portal deployment provides:

- **Interactive Learning Experience**: Step-by-step GUI-based deployment for educational purposes.
- **Cost-Optimized Configuration**: Pre-configured settings for budget-conscious security operations.
- **Security-First Approach**: Proper access controls and diagnostic logging setup.
- **Model Flexibility**: Support for both o4-mini (primary) and GPT-5 (advanced scenarios).
- **Integration Ready**: Configuration optimized for Sentinel and security automation workflows.

## 📋 Prerequisites

Before starting the deployment, ensure you have:

- **Active Azure Subscription**: With appropriate permissions to create resources.
- **Contributor Access**: Minimum role required for resource creation and configuration.
- **Resource Group**: Existing resource group or permissions to create one.
- **Azure OpenAI Access**: Approved access to Azure OpenAI service (may require application).
- **Basic Azure Knowledge**: Familiarity with Azure Portal navigation and resource management.
- **Cost Awareness**: Understanding of Azure OpenAI pricing model and token costs.

## 💰 Cost Estimation

### Expected Monthly Costs for Learning Lab

| Component | Configuration | Estimated Cost |
|-----------|---------------|----------------|
| **o4-mini** | 10,000 tokens/day | $2-5/month |
| **GPT-5** (Optional) | 1,000 tokens/day | $10-15/month |
| **text-embedding-3-small** | Standard usage | $0.60/month |
| **Diagnostic Logging** | 30-day retention | $2-5/month |
| **Total (o4-mini only)** | Basic learning setup | $5-10/month |
| **Total (with GPT-5)** | Enhanced learning setup | $15-25/month |

## 🚀 Step-by-Step Deployment

### Step 1: Access Azure Portal and Navigate to OpenAI

**Note**: Notice that Azure Open AI is now part of Azure AI Foundry. The additional features of Azure AI Foundry will be explored later in this project.

- Navigate to [portal.azure.com](https://portal.azure.com).
- Sign in with your Azure credentials.
- Verify you have access to the correct subscription.
- Click the search bar at the top of the portal.
- Type **Azure OpenAI**.
- Select **Azure OpenAI** from the results.
- Click **+ Create** to start the deployment process.
- Ensure you're in the correct subscription and resource group.

### Step 2: Configure Basic Settings

#### Resource Configuration

- **Subscription**: Select your target Azure subscription.
- **Resource Group**: Use existing `rg-aisec-ai` from Week 2 storage foundation.
- **Resource Group Note**: Consistent with AI storage foundation for centralized management.
- **Name**: Enter unique name following pattern `openai-aisec-{unique-id}` (e.g., `openai-aisec-001`).
- **Region**: Select **East US** (consistent with Week 2 storage foundation region).
- **Pricing Tier**: Select **Standard S0** for pay-as-you-go pricing.

#### OpenAI Naming Tips

- Follow established Week 2 pattern: `openai-aisec-{unique-id}`.
- Use consistent region with storage foundation: **East US**.
- Maintain resource group consistency: `rg-aisec-ai`.

### Step 3: Configure Networking Settings

**Security Considerations**: Network access configuration directly impacts security posture and operational complexity. For **learning environments**, prioritize accessibility and cost-effectiveness with public access and appropriate IP restrictions. For **production environments**, implement private endpoints, network segmentation, and strict access controls. The configuration can be enhanced progressively as security requirements mature.

#### Public Network Access

- **Recommendation**: **Enabled from selected virtual networks and IP addresses**.
- **Learning Environments**: **All networks** (can be restricted later).
- **Production**: Use private endpoints and selected networks.

#### Private Endpoints (Optional for Learning)

- **Skip for learning labs** to reduce costs.
- **Recommended for production** deployments.
- Can be added later as security requirements evolve.

### Step 4: Complete the Azure OpenAI Creation Wizard

#### Wizard Completion

After configuring networking settings, proceed through the remaining wizard tabs. For **lab environments**, you can **skip adding tags** to simplify the process. Navigate to the **Review + create** tab where Azure will perform automatic validation of your configuration, then click **Create** to deploy the resource.

Allow 1-2 minutes for the resource deployment to complete. Then click **Go to resource**.

### Step 5: Managed Identity Setup

Once your Azure OpenAI resource is deployed, you'll need to navigate to the Identity settings to configure managed identity:

- In your deployed Azure OpenAI resource, expand **Resource management** and click **Identity**.
- In the default **System assigned** tab, change the status from **Off** to **On**.
- Click **Save** button at the top of the panel.
- Click **Yes** when prompted to confirm the creation.

Note the **Object (principal) ID** that appears after creation (you'll need this for role assignments).

#### Configure Azure Role Assignments

- After enabling the system-assigned identity, click **Azure role assignments** button.
- Click **+ Add role assignment (Preview)** to configure permissions.
- **Scope**: Choose appropriate scope based on your environment requirements (see table below).

| Role Assignment | Learning Environment | Production Environment |
|-----------------|---------------------|------------------------|
| **Scope** | Resource Group (`rg-aisec-ai`) | Specific Resource or minimal Resource Group |
| **Storage Access** | Storage Blob Data Reader | Storage Blob Data Reader (specific containers) |
| **Key Vault Access** | Key Vault Secrets User | Key Vault Secrets User (specific secrets) |
| **Cross-Resource OpenAI** | Cognitive Services OpenAI User | Cognitive Services OpenAI User (specific resources) |
| **Monitoring** | Reader (Resource Group) | Reader (specific resources only) |
| **Administrative** | Not recommended | Cognitive Services OpenAI Contributor (if needed) |

#### Recommended Initial Setup

- **Learning Environment**: Start with Storage Blob Data Reader at resource group level.
- **Production Environment**: Assign only Storage Blob Data Reader for specific storage containers.

#### Security Implementation Guidelines

- **Learning**: Broader permissions acceptable for educational exploration.
- **Production**: Strict principle of least privilege - only assign what's immediately needed.
- **Validation**: Test with minimal permissions first, then add only if required.
- **Documentation**: Record business justification for each permission granted.
- **Review Schedule**: Learning (monthly), Production (weekly or bi-weekly).

#### Managed Identity Types Comparison

| Feature | System-Assigned | User-Assigned |
|---------|----------------|---------------|
| **Lifecycle** | Tied to resource | Independent lifecycle |
| **Sharing** | Single resource only | Multiple resources |
| **Management** | Automatic creation/deletion | Manual creation/management |
| **Identity Reuse** | Not reusable | Reusable across resources |
| **Complexity** | Simple, automatic | More complex setup |

#### Environment-Specific Recommendations

##### For Learning Labs & Development

- ✅ **Use System-Assigned**: Simpler setup and automatic cleanup.
- ✅ **Single Resource Focus**: Perfect for isolated learning scenarios.
- ✅ **No External Dependencies**: Identity lifecycle matches the resource.
- ⚠️ **Limited Reusability**: Cannot share identity across multiple resources.

##### For Production Environments

- ✅ **Consider User-Assigned**: Better for complex architectures.
- ✅ **Identity Reuse**: Share identity across multiple OpenAI resources.
- ✅ **Centralized Management**: Better governance and role assignment control.
- ✅ **Disaster Recovery**: Identity persists during resource recreation.
- ⚠️ **Additional Complexity**: Requires separate identity resource management.

#### Key Benefits of Managed Identity

- **No Stored Credentials**: Eliminates need to store connection strings or API keys in code.
- **Automatic Key Rotation**: Azure handles credential lifecycle automatically.
- **Enhanced Security**: Reduces attack surface and improves compliance posture.
- **Azure AD Integration**: Seamlessly integrates with Azure Active Directory.

#### API Key Management

##### Understanding API Keys and Security Implications

Your Azure OpenAI resource automatically generates two API keys (Key 1 and Key 2) that serve as authentication credentials for programmatic access to the service. These keys enable applications, scripts, and tools to interact with your Azure OpenAI models through REST API calls, allowing you to:

- **Submit Chat Completions**: Send prompts to GPT models and receive AI-generated responses.
- **Generate Embeddings**: Convert text into vector representations for semantic search and analysis.
- **Stream Responses**: Receive real-time streaming responses for interactive applications.
- **Manage Deployments**: Programmatically interact with your model deployments.
- **Access Model Metadata**: Query information about available models and their capabilities.

The dual-key system provides **zero-downtime key rotation** - you can regenerate one key while applications continue using the other, then switch applications to the new key before regenerating the second key. You can view these keys by navigating to **Resource Management** → **Keys and Endpoint**.

#### Environment-Specific Security Considerations

| **Security Aspect** | **Learning Environment** | **Production Environment** |
|---------------------|-------------------------|---------------------------|
| **Primary Authentication** | API Keys acceptable | Managed Identity preferred |
| **Key Visibility** | Can view keys for learning | Minimize key exposure |
| **Key Storage** | Secure local storage acceptable | Azure Key Vault required |
| **Key Rotation** | Monthly or as-needed | Weekly/bi-weekly schedule |
| **Access Monitoring** | Basic usage tracking | Comprehensive audit logging |
| **Key Distribution** | Limited team members | Strict need-to-know basis |

#### Security Implementation Guidance

##### Learning Environment API Key Practices

- ✅ **API Keys**: Acceptable for educational exploration and testing.
- ✅ **Local Development**: Safe to use keys in local development environments.
- ✅ **Team Sharing**: Can share keys within learning cohort (with instructor guidance).
- ⚠️ **Basic Security**: Still avoid committing keys to public repositories.
- ⚠️ **Rotation**: Rotate monthly or if compromised.

##### Production Environment API Key Practices

- ✅ **Managed Identity First**: Always prefer managed identity over API keys.
- ✅ **Key Vault Storage**: Never store keys directly in applications or config files.
- ✅ **Automated Rotation**: Implement automated key rotation processes.
- ✅ **Access Logging**: Monitor all key usage with detailed audit trails.
- ❌ **Avoid Direct Usage**: Minimize scenarios requiring direct API key usage.

#### Key Security Best Practices

- **Never Commit Keys**: Use environment variables and .gitignore files.
- **Monitor Usage**: Set up alerts for unusual API key activity patterns.
- **Implement Retry Logic**: Handle rate limiting and authentication errors gracefully.
- **Document Access**: Maintain records of who has access to API keys and why.

**📚 Learn More**: For production deployments, consider implementing managed identity authentication instead of API keys. Learn how to configure managed identity access to Azure OpenAI: [Use managed identities with Azure AI services](https://learn.microsoft.com/en-us/azure/ai-services/authentication?tabs=powershell#authenticate-with-managed-identities)

### Step 6: Configure Monitoring and Logging

- In your Azure OpenAI resource, expand **Monitoring** in the left navigation pane.
- Click **Diagnostic settings**.
- Click **+ Add diagnostic setting** to create a new configuration.
- **Name**: Enter `openai-diagnostics-aisec` for the diagnostic setting name.
- **Categories**: In the **Logs** section, you'll see the following options:
  - ✅ **Audit**: Select this to enable audit logging (this is a single comprehensive category).
    - **Note**: When you select **Audit**, it captures all administrative operations, access patterns, and security-relevant events.
  - **Metrics**: Select **AllMetrics** for comprehensive performance monitoring.

#### Cost Considerations for Log Storage

- **Log Analytics Ingestion**: Approximately $2.30 per GB of data ingested.
- **Expected Volume**: Azure OpenAI audit logs typically generate 50-200 MB per month for learning environments.
- **Retention Costs**: Additional charges apply for data retained beyond the included retention period.
- **Cost Management**: Monitor usage in **Cost Management + Billing** to track actual consumption.
- **Optimization**: Consider shorter retention periods for non-production environments.

#### Log Analytics Workspace Recommendation

Check the option for **Send to Log Analytics workspace** and then review the options below for configuration.

For this Azure AI Security Skills Challenge, we recommend using the **Log Analytics workspace created during Week 1 Defender for Cloud deployment** (unless you removed it). This approach provides:

- **Centralized Security Monitoring**: All security logs and AI usage data in one location.
- **Cost Efficiency**: Shared ingestion and retention costs.
- **Enhanced Analytics**: Leverage Defender's monitoring capabilities for OpenAI log analysis.
- **Cross-Correlation**: Detect patterns between AI usage and security events.

#### Configuration Options

##### Option 1: Use Existing Week 1 Log Analytics Workspace (Recommended)

- Click the **Log Analytics workspace** dropdown.
- Select your existing workspace from Week 1 Defender for Cloud deployment.
- Named following pattern: `log-securitylab-{6-character-unique-id}` (e.g., `log-securitylab-abc123`).
- Verify it shows as **Connected** status.

##### Cross-Resource Group Considerations

- **Location**: The Week 1 workspace is in resource group `rg-aisec-defender-securitylab1`.
- **Data Management**: Diagnostic data flows across resource groups, which is normal and supported.
- **Access Control**: Ensure you have appropriate permissions to both resource groups.
- **Billing**: Log ingestion costs will appear under the Defender resource group's billing.
- **Lifecycle Management**: Deleting `rg-aisec-ai` won't affect the logs stored in the Defender workspace.
- **No Technical Limitations**: Cross-resource group logging is a standard Azure practice.

##### Option 2: Create New Log Analytics Workspace (If Week 1 Workspace Removed)

- Click **Create new** next to the Log Analytics workspace dropdown.
- **Name**: Enter `log-aisec-monitoring`.
- **Resource Group**: Select `rg-aisec-ai` (consistent with deployment).
- **Region**: Select **East US** (match your OpenAI resource region).
- Click **OK** to create the workspace.
- Wait for deployment completion before proceeding.

##### Additional options to consider

- **Archive to storage account**: Optional for long-term retention (skip for learning environments).
- **Stream to event hub**: Skip for learning environments.
- **Send to partner solution**: Skip for this project.

#### Save Diagnostic Settings

- Review your configuration to ensure the correct log categories and destination are selected.
- Click **Save** at the top of the diagnostic settings page to apply the configuration.
- Azure will validate and apply the settings (this may take a few moments).

#### Environment-Specific Logging Recommendations

| **Log Type** | **Learning Environment** | **Production Environment** |
|-------------|-------------------------|----------------------------|
| **Audit Logs** | Always enable | Always enable |
| **Metrics (AllMetrics)** | Enable for performance monitoring | Enable with alerting |
| **Cost Impact** | Low ($2-5/month) | Monitor and budget accordingly |
| **Privacy Considerations** | Audit logs contain operational data | Review data retention policies |

### Step 7: Configure Log Retention Settings

#### Log Analytics Workspace Data Retention

After configuring diagnostic settings, you should optimize log retention for cost management and compliance requirements. This step is particularly important if you created a new Log Analytics workspace in the previous step.

#### Sentinel Integration Considerations

If using the existing Week 1 Log Analytics workspace (recommended), your retention settings will affect both Defender for Cloud data and the new Azure OpenAI diagnostic data. Consider the following:

- **Unified Retention Policy**: Both security logs and AI usage logs will use the same retention period.
- **Cross-Service Analytics**: Longer retention enables correlation between AI usage patterns and security events.
- **Incident Response**: Security investigations may require access to historical AI usage data.
- **Compliance Impact**: Ensure retention meets requirements for both security monitoring and AI governance.
- **Cost Scaling**: Adding OpenAI logs will increase total ingestion volume and retention costs.

Review to review the data retention settings:

- In the Azure portal search bar, type **Log Analytics workspaces**.
- Click on your workspace (either the Week 1 workspace or newly created `log-aisec-monitoring`).
- This opens the workspace overview page.
- In the left navigation pane, under **Settings**, click **Usage and estimated costs**.
- Click **Data Retention** at the top of the page.
- You'll see the current retention period and associated costs.

##### Learning Environment Retention Settings

- **Retention Period**: Set to **30 days**.
- **Rationale**: Balances learning needs with cost optimization.
- **Cost Impact**: Minimizes charges while providing sufficient data for analysis.
- **Learning Value**: Adequate time to practice log analysis and monitoring.

##### Production Environment Retention Settings

- **Retention Period**: Set to **90-365 days** based on compliance requirements.
- **Regulatory Considerations**: Many industries require 90+ days for security logs.
- **Incident Response**: Longer retention supports thorough security investigations.
- **Cost Planning**: Budget accordingly as retention significantly impacts costs.

#### Retention Cost Optimization Tips

| **Retention Period** | **Learning Environment** | **Production Environment** |
|---------------------|-------------------------|----------------------------|
| **30 days** | ✅ Recommended | ⚠️ May not meet compliance |
| **90 days** | 💰 Higher cost | ✅ Standard compliance baseline |
| **365 days** | 💰 Expensive for learning | ✅ Enhanced compliance/forensics |
| **730 days** | ❌ Not recommended | ⚠️ Only if required by regulation |

#### Alternative Cost Management Strategies

- **Archive to Storage**: For long-term retention at lower cost.
- **Data Export**: Export logs to blob storage for compliance archiving.
- **Selective Retention**: Use different retention policies for different log types (if supported).

### Step 8: OpenAI Deployment Validation

#### Verify Configuration Before Model Deployment

Before proceeding to model deployment, validate that your Azure OpenAI resource is properly configured and ready for use.

- Navigate to your Azure OpenAI resource (either from recent resources or search for your resource name).
- Ensure you're viewing the resource **Overview** page.
- Confirm the **Status** shows as **Running**.
- Validate Essential Configuration:
  - **Resource Details**: Verify resource name follows pattern `openai-aisec-{unique-id}` in **East US** region.
  - **Identity**: Navigate to **Identity** under **Resource Management** and confirm System-assigned is **On**.
  - **Keys Access**: Go to **Keys and Endpoint** and verify you can see the endpoint URL and access keys.
  - **Diagnostic Settings**: Check **Monitoring** → **Diagnostic settings** shows your configured setting.
- Verify Model Deployment Readiness:
  - **Navigate to Model Deployments**: Click **Model deployments** in the left navigation.
  - **Deployment Interface**: Confirm you can access the **+ Create new deployment** button.
  - **Quota Check**: Click **Quotas** to verify you have available capacity for model deployments.
  - **Regional Models**: Confirm desired models (o4-mini, GPT-5) are available in your region.
- Record Connection Information:
  - **Endpoint URL**: Copy the endpoint from **Keys and Endpoint** (format: `https://openai-aisec-{unique-id}.openai.azure.com/`).
  - **Resource Location**: Note the region and resource group for documentation.
  - **API Keys**: Ensure keys are accessible (you'll need these for testing later).

#### Deployment Readiness Checklist

- [ ] Azure OpenAI resource status shows "Running".
- [ ] System-assigned managed identity is enabled.
- [ ] API keys and endpoint are accessible.
- [ ] Diagnostic logging is configured.
- [ ] Model deployment interface is accessible.
- [ ] Regional quota is available for desired models.
- [ ] Connection information documented.

**🚀 Ready for Next Phase**: Once all items above are verified, you're ready to proceed with model deployment in the next section.

## 🤖 Model Deployment

### Access Azure AI Foundry Chat Playground

Azure OpenAI is now fully integrated with Azure AI Foundry, which provides a chat-based interface for model deployment and testing.

**📋 Note**: We are using Azure AI Foundry to test our OpenAI deployment in this section. Azure AI Foundry offers many additional features beyond basic model deployment and testing, including advanced prompt engineering, model fine-tuning, and comprehensive AI project management capabilities. We will explore these additional Azure AI Foundry features later in the project.

- In your Azure OpenAI resource **Overview** page, click **Explore Azure AI Foundry portal**.
- This opens the Azure AI Foundry portal directly to a **Chat playground** interface.
- Sign in if prompted and ensure you're working with the correct subscription and resource. You'll land on the Chat playground page.
  - This is the modern interface for both deploying models and testing them.
  - The playground integrates deployment creation directly into the chat experience.

### Deploy o4-mini (Primary Model)

#### Model Deployment Through Chat Interface

- In the Chat playground, look for a **Deployments** dropdown at the top.
  - If no deployments exist, you'll see a **Create a deployment** button or link.
- Click **Create a deployment** to start the model deployment process.
- **Select a model**: Choose **o4-mini** from the available models.
- **Deployment name**: Enter `o4-mini-aisec`.
- **Model version**: Use the latest available version (typically auto-selected).
- **Deployment type**: Select **Global Standard** for pay-as-you-go pricing.
- Within the deployment box, click **Customize**.
- **Tokens per minute rate limit**: Move the slider to **10K** (10,000 Tokens per minute) for learning environment.
- **Content filter**: Keep default content filtering settings for learning.
- Review your configuration settings.
- Click **Deploy** to deploy the model.

The deployment should complete within a few seconds, and you will be returned the Chat playground screen for your model deployment.

#### Verify Deployment in Chat Playground

- Select your `o4-mini-aisec` deployment from the dropdown.
- Enter a test prompt in the chat interface: "Hello, this is a test of the o4-mini deployment for security operations."
- Click **Send** to verify the model responds appropriately.
- Confirm the response demonstrates the model is working correctly.

### Deploy Additional Models (Optional)

#### GPT-5 Advanced Model Deployment

⚠️ **Registration Required**: As of August 2025, access to GPT-5 requires advance registration and approval through Azure. You may need to request access before this model becomes available for deployment. This requirement will likely change in the near future as GPT-5 becomes more widely available.

⚠️ **Note**: GPT-5 availability may be limited by region and access approval. Check model availability in your region before proceeding.

- In the Chat playground, click the **Create new deployment** dropdown and select **From base models**.
- Click **Create a deployment** to start the model deployment process.
- **Select a model**: Choose **GPT-5** from the available models (if available in your region).
- **Deployment name**: Enter `gpt-5-aisec`.
- **Model version**: Use the latest available version (typically auto-selected).
- **Deployment type**: Select **Global Standard** for pay-as-you-go pricing.
- Within the deployment box, click **Customize**.
- **Tokens per minute rate limit**: Move the slider to **1K** (1,000 Tokens per minute) for cost control.
- **Content filter**: Keep default content filtering settings for learning.
- **Monitor costs closely**: GPT-5 has significantly higher token costs than o4-mini.
- Review your configuration settings carefully due to higher costs.
- Click **Deploy** to deploy the model.
- The deployment should complete within a few seconds, and you will be returned to the Chat playground screen.

##### Verify GPT-5 Deployment

- Select your `gpt-5-aisec` deployment from the dropdown.
- Enter a complex test prompt: "Analyze the security implications of this advanced persistent threat scenario and provide detailed mitigation strategies."
- Click **Send** to verify the model responds with enhanced analytical capabilities.
- Compare response quality and depth with o4-mini deployment.

#### Text Embedding Model for Semantic Analysis

**📋 Note**: Embedding models may not appear in the Chat playground dropdown as they serve a different purpose than chat models. They convert text to vectors for semantic search rather than generating conversational responses.

- In Azure AI Foundry, navigate to **Model catalog** in the left sidebar.
- Use the search bar to search for **text-embedding-3-small** or browse through available models.
- Click on the **text-embedding-3-small** model when you find it in the catalog.
  - You'll see the model details page with information about capabilities, pricing, and specifications.
  - Review the model description and use cases to confirm it meets your requirements.
- Click **Use this model** button to proceed with deployment.
- **Deployment name**: Enter `text-embedding-3-small-aisec`.
- **Deployment type**: Select **Global Standard** for pay-as-you-go pricing.
- Within the deployment box, click **Customize**.
- **Tokens per minute rate limit**: Move the slider to **10K** (10,000 Tokens per minute) for learning environment.
- **Content filter**: Keep default settings.
- Review your configuration settings on the deployment page.
- Click **Deploy** to deploy the model.
- The deployment should complete within a few seconds.

#### Verify Embedding Deployment

After successful deployment, you'll be taken directly to the model deployment page. This is the same interface used for chat models, showing deployment details and configuration options. Verify the deployment status shows as **Running** or **Succeeded**.

##### Configure Development Settings for Learning Environment

- **Language**: Select **Python** (recommended for learning and prototyping).
- **SDK**: Choose **Azure OpenAI SDK** for easier integration and examples.
- **Authentication type**: Select **Key Authentication** for learning environment (simpler than managed identity for initial testing).
  - **Note**: You can change these settings later based on your development preferences.
- **Deployment name**: Note your `embedding-aisec` deployment name.
- **Target URI**: Copy the endpoint URL (will use `/embeddings` endpoint, not `/chat/completions`).
- **API Key**: Record from the Keys and Endpoint section for testing.
- **API Version**: Note the version for API calls (typically displayed on the deployment page).

**Notes**:

- Unlike chat models, embedding models cannot be tested in the Chat playground.
- They are used programmatically via API calls to convert text into vector representations.
- The deployment page may show sample code snippets for your selected language/SDK.
- Use the provided code examples as a starting point for integration.

Your embedding deployment is now ready for programmatic use. You may test functionality using the sample code provided on the deployment page, and integration examples will be covered in later sections of this course.

#### Security Use Cases for Embeddings

- **Document Similarity**: Compare security policies, procedures, and threat intelligence documents.
- **Semantic Search**: Search through security documentation using natural language queries.
- **Log Analysis**: Group similar log entries for pattern detection and anomaly identification.
- **Threat Intelligence**: Find similar indicators of compromise (IoCs) and attack patterns.
- **Policy Compliance**: Compare new documents against existing security standards.

### Manage Deployments in Azure AI Foundry

#### Access Deployment Management

In Azure AI Foundry, navigate to **Management** → **Deployments** in the left sidebar. This shows all your model deployments with their status and configuration. In this section, you can modify rate limits, view usage metrics, and manage deployments.

##### Monitor Deployment Health

- Check that all deployments show **Succeeded** status.
- Note the **Target** and **Capacity** settings for each deployment.
- Record deployment names for use in API calls and applications.

### Test Model Functionality

From the deployment management page, navigate back to **Chat** in Azure AI Foundry as the deployment page won't allow interactive testing from the deployments page. Use the Chat playground for all interactive model testing.

- In the Chat playground, use the **Deployments** dropdown to select your deployed models.
- Switch between `o4-mini-aisec` and `gpt-5-aisec` (if deployed) to compare capabilities.
- Test each deployment individually to verify functionality.

#### Cybersecurity-Focused Testing Prompts

Use some of the prompts below within Azure AI Foundry Chat to test the security functionality of your model.

##### Basic Security Knowledge Testing

**Threat Analysis Prompt**:

```text
Explain the MITRE ATT&CK framework and identify the top 5 most common attack techniques used by advanced persistent threats (APTs). For each technique, provide a brief mitigation strategy.
```

**Incident Response Prompt**:

```text
A user reports suspicious email attachments and slow system performance. Create a step-by-step incident response plan for this scenario, including initial triage, evidence collection, and containment measures.
```

**Vulnerability Assessment Prompt**:

```text
Describe the difference between vulnerability scanning and penetration testing. Explain when each approach is most appropriate and what types of security findings each method typically uncovers.
```

**Security Policy Analysis Prompt**:

```text
Review this scenario: An organization wants to implement zero-trust architecture. Explain the key principles of zero-trust and provide a prioritized implementation roadmap for a mid-sized company.
```

**Log Analysis Training Prompt**:

```text
Explain how to identify potential indicators of compromise (IoCs) in system logs. What are the most critical log types to monitor for security incidents, and what specific patterns should security analysts look for?
```

##### Log Analytics Workspace Integration

The prompt below can be used to test the functionality of an existing Sentinel integration to your Log Analytics Workspace.

```text
Based on current security alerts and logs in our environment, what are the most common security events we should prioritize for investigation? Can you identify any patterns in our recent security data? Please also confirm if these are SAMPLE ALERTS.
```

**Note**: This prompt tests whether the model has access to the Log Analytics workspace data from your Week 1 Defender deployment. If the model responds with general advice rather than specific data from your environment, it means direct log access is not configured (which is expected in most standard deployments).

#### Verify Model Performance

- **o4-mini**: Expect fast, accurate responses with concise security guidance suitable for operational use. Well-suited for routine security questions, policy explanations, and standard incident response procedures.
- **GPT-5** (if deployed): Expect enhanced analytical capabilities with more detailed reasoning, complex threat analysis, and sophisticated security architecture recommendations. Response times may be slightly longer due to advanced processing.
- Compare response depth, accuracy, and practical applicability between models using the test prompts above.

#### Content Filtering Guidelines

- **⚠️ Never Test with Sensitive Data**: Do not input actual passwords, API keys, personal information, or real security incident details during testing.
- **Use Generic Examples**: Test security concepts using hypothetical scenarios, public threat intelligence, or sanitized examples only.
- **Content Filtering Purpose**: Azure OpenAI's content filtering automatically blocks harmful content including hate speech, violence, and inappropriate material while allowing legitimate security discussions.
- **Professional Security Topics**: The service is designed to handle professional cybersecurity topics appropriately, providing educational and operational guidance without exposing vulnerabilities or harmful techniques.

## 🛡️ Advanced Security Configuration

Most security configurations were completed during the initial deployment steps. This section provides a quick reference for additional security hardening based on your environment needs.

### Additional User Access Management

If you need to grant other users access to your Azure OpenAI resource beyond the managed identity already configured, go to your Azure OpenAI resource → **Access control (IAM)** → **+ Add** → **Add role assignment**

#### User Role Assignments (Reference Step 5 for detailed guidance)

| **Security Aspect** | **Learning Environment** | **Production Environment** |
|---------------------|--------------------------|----------------------------|
| **User Access Roles** | Cognitive Services OpenAI User | Cognitive Services OpenAI User (specific resources) |
| **Administrative Access** | Cognitive Services OpenAI Contributor (if needed) | Minimize - use managed identity instead |
| **Monitoring Access** | Reader (resource group level) | Reader (specific resources only) |
| **Key Access** | Direct API key access acceptable | Restrict to Key Vault access only |

**📚 Learn More**: [Azure role-based access control (Azure RBAC) documentation](https://learn.microsoft.com/en-us/azure/role-based-access-control/)

### Advanced API Key Security

**📚 Reference**: Complete API key security guidance is provided in **Step 5 - API Key Management**. For additional security hardening:

| **Security Practice** | **Learning Environment** | **Production Environment** |
|-----------------------|--------------------------|----------------------------|
| **Key Rotation Schedule** | Monthly or as-needed | Weekly/bi-weekly automated rotation |
| **Key Storage Method** | Local secure storage acceptable | Azure Key Vault mandatory |
| **Access Monitoring** | Basic usage review | Comprehensive audit logging with alerts |
| **Distribution Control** | Team-shared for learning | Strict need-to-know basis |
| **Emergency Procedures** | Manual key regeneration | Automated incident response |

**📚 Learn More**: [Azure Key Vault security overview](https://learn.microsoft.com/en-us/azure/key-vault/general/security-features)

### Advanced Network Security

**📚 Reference**: Network security basics were configured in **Step 3 - Networking Settings**. For production hardening:

| **Network Control** | **Learning Environment** | **Production Environment** |
|---------------------|--------------------------|----------------------------|
| **Public Access** | Enabled with IP restrictions | Disabled (private endpoints only) |
| **Private Endpoints** | Optional (cost optimization) | Required for all access |
| **Network Segmentation** | Basic firewall rules | Dedicated security VNet integration |
| **DNS Configuration** | Public DNS resolution | Private DNS zones mandatory |
| **Monitoring** | Basic connection logs | Network traffic analysis and alerting |

**📚 Learn More**: [Azure Private Endpoint overview](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)

## 📊 Monitoring and Cost Management

### Azure OpenAI Cost Analysis and Monitoring

**📅 Cost Data Freshness**: Azure cost data in Cost Analysis is typically available within **8-24 hours** of resource usage. Current-day costs may appear incomplete until the following day, and some usage details can take up to 72 hours to fully process. For real-time cost monitoring during active development, monitor your deployment's **token usage metrics** in Azure Monitor, which update within minutes of API calls.

#### Finding Your Azure OpenAI Usage and Costs

- Navigate to **Cost Management + Billing** → **Cost analysis**.
- Select your **Resource Group** (`rg-aisec-ai`) from the scope selector.
- Click the **Services** tab to see costs grouped by service.
- In the Services view, look for **Azure OpenAI Service** in the list.
- Expand the row to see detailed breakdown by deployment and usage type.
- Use the date picker to adjust time periods for your analysis.

##### Monitor Token Usage in Real-Time

- Go to your Azure OpenAI resource → **Monitoring** → **Metrics**.
- Select metrics like **Total Tokens**, **Prompt Tokens**, and **Generated Tokens**.
- Set time range to see current usage patterns and rate limit consumption.

#### Practical Cost Management Strategies

| **Cost Management Practice** | **Learning Environment** | **Production Environment** |
|------------------------------|-------------------------|----------------------------|
| **Token Usage Monitoring** | Monitor daily consumption patterns | Implement automated token tracking and alerting |
| **Model Selection Strategy** | Use o4-mini for 80-90% of requests, GPT-5 for complex scenarios | Optimize model selection based on cost-per-outcome analysis |
| **Rate Limit Configuration** | Start with conservative TPM limits (1K-10K) | Scale TPM based on actual demand patterns and SLA requirements |
| **Usage Pattern Analysis** | Weekly manual review of cost trends | Automated analysis with cost optimization recommendations |
| **Deployment Utilization** | Track which deployments generate the most cost | Implement cost allocation and chargeback by business unit |
| **Cost Review Frequency** | Weekly during initial learning phase | Daily monitoring with automated threshold alerts |
| **Threshold Management** | Be aware when daily costs exceed $2-3 | Implement automated scaling and budget enforcement |
| **Prompt Optimization** | Focus on learning efficient prompting techniques | Advanced prompt engineering for token efficiency at scale |
| **Expected Monthly Costs** | $2-35/month (Light to Enhanced Learning with GPT-5) | $25-100+/month (Production workloads with SLA requirements) |
| **Performance Monitoring** | Azure portal overview dashboard and manual metrics review | Azure AI Foundry metrics dashboard with real-time alerting |
| **Log Analytics Integration** | Basic diagnostic logging for learning purposes | Advanced KQL queries and cross-resource correlation analysis |
| **Dashboard Configuration** | Built-in Azure OpenAI dashboards for simple monitoring | Custom dashboards with multiple metrics and business KPIs |

#### Performance Monitoring

**📚 Learn More**: [Monitor Azure OpenAI](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/monitoring)

## 🚨 Troubleshooting Common Issues

For Azure OpenAI deployment and configuration issues, Microsoft provides comprehensive resources and support options. Rather than generic troubleshooting steps, use these validated Microsoft resources for specific issues:

### 📋 Quick Issue Resolution

#### Start Here for Common Problems

**Azure Portal Built-in Help**: Go to your Azure OpenAI resource → **Support + Troubleshooting** in the left pane. The portal will suggest relevant Learn articles and resources based on your issue description

#### 🔗 Official Microsoft Documentation & Support

| **Issue Type** | **Resource** | **Description** |
|---------------|-------------|-----------------|
| **Quota & Rate Limits** | [Azure OpenAI Quotas and Limits](https://learn.microsoft.com/en-us/azure/ai-foundry/openai/quotas-limits) | Official quotas, rate limits, regional availability, and quota increase requests |
| **Model Availability** | [Azure OpenAI Models Documentation](https://learn.microsoft.com/en-us/azure/ai-foundry/openai/concepts/models) | Current model availability by region and deployment types |
| **Quota Increase Requests** | [Quota Increase Request Form](https://aka.ms/oai/stuquotarequest) | Official form for requesting quota increases (high demand - filled in order received) |
| **General Support Issues** | [Azure AI Services Support Options](https://learn.microsoft.com/en-us/azure/ai-services/cognitive-services-support-options) | Comprehensive support options including Azure support tickets |
| **Azure Support Ticket** | [New Support Request](https://ms.portal.azure.com/#view/Microsoft_Azure_Support/NewSupportRequestV3Blade) | Direct Azure support for complex issues (select "Cognitive Services" in Service type) |

### 🎯 Most Common Issues & Direct Solutions

**"Quota Exceeded" Error**:

- Check [regional quota capacity](https://ai.azure.com/resource/quota) in Azure AI Foundry portal.
- Submit [quota increase request](https://aka.ms/oai/stuquotarequest) if needed.

**Model Not Available in Region**:

- Review [model availability by region](https://learn.microsoft.com/en-us/azure/ai-foundry/openai/concepts/models).
- Consider alternative regions or deployment types.

**Access Approval Needed**:

- Azure OpenAI requires service approval - apply through Azure portal if you receive access errors.
- Check subscription permissions and role assignments.

**Rate Limiting Issues**:

- Review [rate limits documentation](https://learn.microsoft.com/en-us/azure/ai-foundry/openai/quotas-limits) for your deployment type.
- Implement retry logic and gradual workload increases.

### 📞 When to Contact Microsoft Support

Create an [Azure Support Request](https://ms.portal.azure.com/#view/Microsoft_Azure_Support/NewSupportRequestV3Blade) for:

- Complex deployment failures not resolved by documentation.
- Suspected service outages or performance issues.
- Billing or quota allocation problems.
- Security or compliance concerns.

## 🔄 Integration with Security Tools

Azure OpenAI can enhance your security operations by integrating with various Azure security services. Below are the primary integration opportunities:

### Azure Security Tool Integration Overview

| **Security Tool** | **Integration Method** | **Use Cases** | **Implementation Approach** |
|------------------|------------------------|---------------|---------------------------|
| **Microsoft Sentinel** | Logic Apps, Custom Connectors, REST API | Automated incident analysis, threat hunting queries, alert enrichment, security report generation | Configure Logic Apps playbooks with OpenAI connectors for incident processing |
| **Defender for Cloud** | Logic Apps, Power Automate, REST API | Alert analysis and prioritization, compliance report generation, security recommendation explanations | Use APIs to feed Defender alerts through OpenAI for enhanced analysis |
| **Microsoft Entra ID** | Graph API, Logic Apps | User behavior analysis, risk assessment, anomaly detection in authentication patterns | Combine Entra logs with OpenAI for pattern analysis and risk scoring |
| **Defender for Identity** | REST API, Logic Apps | Identity threat analysis, lateral movement detection, suspicious activity investigation | Process identity alerts through OpenAI for contextual threat analysis |
| **Defender for Office 365** | Graph API, Power Automate | Email threat analysis, phishing detection enhancement, security awareness content generation | Analyze email threats and generate security awareness materials |
| **Azure Security Center** | REST API, Logic Apps | Vulnerability assessment reporting, security posture analysis, remediation guidance | Generate detailed remediation guidance and security posture summaries |
| **Azure Policy** | REST API, Logic Apps | Compliance gap analysis, policy recommendation generation, governance reporting | Analyze policy compliance and generate improvement recommendations |
| **Key Vault** | REST API, Logic Apps | Secret management alerts, access pattern analysis, security audit reporting | Monitor key vault access patterns and generate security audit reports |

### Integration Architecture Patterns

| **Pattern** | **Best For** | **Components** | **Benefits** |
|------------|-------------|----------------|-------------|
| **Event-Driven Processing** | Real-time incident response | Event Grid + Logic Apps + OpenAI | Immediate AI analysis of security events |
| **Scheduled Analysis** | Daily/weekly security reports | Logic Apps Timer + OpenAI + Email/Teams | Automated recurring security insights |
| **API-Based Integration** | Custom applications | Custom app + OpenAI REST API + Security tool APIs | Full control over integration logic |
| **Power Platform Integration** | Citizen developer solutions | Power Automate + Power Apps + OpenAI connector | Low-code security automation solutions |

### Common Integration Use Cases

| **Use Case** | **Input** | **OpenAI Processing** | **Output** |
|-------------|-----------|----------------------|------------|
| **Incident Enrichment** | Sentinel alerts, logs | Threat analysis, context generation | Enhanced incident details with AI insights |
| **Compliance Reporting** | Defender findings, policy violations | Gap analysis, recommendation generation | Executive-ready compliance reports |
| **Threat Hunting** | Security logs, IOCs | Pattern analysis, query generation | KQL queries and hunting hypotheses |
| **Security Training** | Incident examples, policies | Content generation, scenario creation | Security awareness training materials |
| **Risk Assessment** | Asset data, vulnerabilities | Risk scoring, prioritization | Prioritized remediation roadmaps |

### Implementation Considerations

| **Consideration** | **Recommendation** |
|------------------|-------------------|
| **Authentication** | Use managed identity where possible; API keys for development only. |
| **Data Privacy** | Never send actual sensitive data (PII, secrets) through OpenAI; use sanitized examples. |
| **Rate Limiting** | Implement retry logic and respect Azure OpenAI TPM limits. |
| **Cost Management** | Monitor token usage; use o4-mini for routine tasks, GPT-5 for complex analysis. |
| **Security** | Implement proper access controls and audit logging for all integrations. |
| **Compliance** | Ensure integrations meet your organization's data handling requirements. |

## 📋 Next Steps

Your Azure OpenAI service is now successfully deployed and integrated with your existing security infrastructure. Choose your next path based on your learning objectives:

### 🚀 Continue Week 2: Azure OpenAI + Sentinel Integration

**Next Phase in Week 2**: Build upon your OpenAI foundation with Sentinel automation:

- **Prerequisites Met**: ✅ Azure OpenAI deployed, ✅ Models configured, ✅ Cost monitoring active.
- **Next Step**: [Azure OpenAI + Sentinel Integration](./deploy-openai-sentinel-integration.md).
- **Expected Timeline**: 30-45 minutes to complete Logic Apps integration.
- **Key Benefits**: Automated incident analysis, AI-powered alert triage, intelligent security workflows.

### 🔄 OpenAI Deployment Reset & Decommissioning

**Alternative Path**: Clean up OpenAI resources while preserving storage foundation:

- **Selective Cleanup**: Keep storage foundation and Defender for Cloud, remove only OpenAI service.
- **Complete OpenAI Reset**: Remove OpenAI deployment to restart AI service learning experience.
- **Decommissioning Guide**: [Decommission Azure OpenAI Service](./decommission-azure-openai-service.md) *(Guide coming soon)*.
- **Cost Benefits**: Eliminate ongoing Azure OpenAI token costs while maintaining storage infrastructure.

### 📚 Extended OpenAI Learning & Experimentation

**Deep Dive Path**: Enhance your current OpenAI deployment before Sentinel integration:

- **Advanced Model Testing**: Experiment with GPT-5 deployment and cost comparison.
- **Custom Security Prompts**: Develop organization-specific AI security prompts using deployed models.

### 💰 Cost Management Reminder

**Ongoing OpenAI Monitoring**: Your deployment includes cost controls specific to OpenAI usage:

- **Token Usage Tracking**: Monitor daily token consumption in Azure AI Foundry.
- **Model Cost Comparison**: Track costs between o4-mini and GPT-5 (if deployed).
- **Budget Alerts**: OpenAI-specific spending alerts already configured.
- **Resource Lifecycle**: Use OpenAI decommissioning guide when ready to clean up AI services.

---

**🎯 Recommended Next Action**: Proceed to [Azure OpenAI + Sentinel Integration](./deploy-openai-sentinel-integration.md) to continue Week 2 and create automated AI-driven security workflows.

---

## 🔗 Additional Resources

- 📖 [Azure OpenAI Service Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/openai/).
- 📖 [Azure OpenAI Studio](https://oai.azure.com/).
- 📖 [Azure Monitor Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/).
- 📖 [Azure Cost Management](https://docs.microsoft.com/en-us/azure/cost-management-billing/).

---

## 🤖 AI-Assisted Content Generation

This comprehensive Azure Portal deployment guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Azure OpenAI service deployment best practices, security-focused configuration guidance, and hands-on learning approaches for cybersecurity professionals.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Azure Portal deployment procedures while maintaining technical accuracy and reflecting current Azure OpenAI service capabilities and security best practices.*
