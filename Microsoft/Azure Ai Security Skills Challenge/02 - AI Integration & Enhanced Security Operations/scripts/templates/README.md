# Defender XDR Integration Templates

This directory contains ARM templates for deploying Azure Logic Apps that integrate Azure OpenAI with Microsoft Defender XDR. These templates are used by the automated PowerShell deployment scripts to create the complete integration workflow.

## 📋 Active Template Files

### Logic App Deployment Templates

| Template File | Purpose | Used By |
|--------------|---------|---------|
| **logic-app-arm-template.json** | Complete Logic App ARM deployment template | Deploy-LogicAppWorkflow.ps1 |
| **logic-app-initial.json** | Logic App initial configuration and workflow | Deploy-LogicAppWorkflow.ps1 |
| **logic-app-diagnostics.json** | Logic App monitoring and diagnostic settings | Deploy-LogicAppWorkflow.ps1 |

### Integration Architecture

The templates work together to create a complete Defender XDR + Azure OpenAI integration:

- **ARM Template**: Deploys the Logic App resource with proper configuration
- **Initial Config**: Defines the workflow logic for incident processing
- **Diagnostics**: Sets up monitoring and logging for operational visibility

## 🔧 How to Use Templates

### Automated Deployment Integration

These templates are automatically loaded and deployed by the PowerShell automation scripts:

1. **Deploy-LogicAppWorkflow.ps1** references all three templates
2. **Templates are loaded programmatically** during deployment
3. **No manual template manipulation required** - handled by automation
4. **ARM template deployment** uses Azure Resource Manager for reliable provisioning

### Template Structure

#### ARM Template (`logic-app-arm-template.json`)

- Complete Azure Resource Manager template
- Defines Logic App resource and configuration
- Includes parameters for customization
- Handles dependencies and resource relationships

#### Configuration Templates

- **Initial Config**: Workflow definition and trigger setup
- **Diagnostics**: Application Insights integration and logging configuration

## 🔍 Template Validation

### Deployment Validation

Templates are validated during automated deployment:

```powershell
# Templates are validated as part of the deployment process
cd "scripts\scripts-deployment"
.\Deploy-LogicAppWorkflow.ps1 -UseParametersFile
```

### ARM Template Testing

The ARM template includes built-in validation:

- **Parameter validation** ensures proper configuration
- **Resource dependency checking** prevents deployment failures  
- **Schema validation** confirms template structure integrity
- 
---

**📋 Usage Note**: All templates are optimized for o4-mini deployment for cost-effective operations. Token limits are designed for budget-conscious security analysis while maintaining analytical quality.
