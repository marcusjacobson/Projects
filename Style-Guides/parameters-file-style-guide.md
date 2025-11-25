# Parameters File Style Guide for Azure AI Security Skills Challenge

This style guide establishes consistent standards for parameters file configuration and usage across Azure AI Security Skills Challenge projects. It defines proper parameter structure, naming conventions, and deployment patterns to ensure consistency and maintainability.

## 📋 General Principles

### Professional Parameters Architecture

- Use consistent parameter naming across all projects and components.
- Implement proper parameter validation and type enforcement.
- Maintain centralized configuration through standardized parameters files.
- Provide comprehensive documentation for all parameter purposes and values.
- Follow established Azure resource naming conventions.

### Configuration Consistency and Maintainability

- Use cumulative parameters approach for feature additions.
- Enable cross-component integration through shared foundation parameters.
- Implement proper parameter grouping by functionality and scope.
- Maintain backward compatibility when extending parameter sets.

---

## 📝 Parameters File Structure Standards

### Required Parameters File Format

All `main.parameters.json` files must follow the Azure Resource Manager parameters schema:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "parameterName": {
      "value": "parameter-value"
    }
  }
}
```

### Foundation Parameters (Required in All Projects)

These parameters must be present in every `main.parameters.json` file:

| Parameter | Type | Purpose | Example |
|-----------|------|---------|---------|
| `environmentName` | string | Resource naming prefix | `"aisec"` |
| `location` | string | Azure deployment region | `"East US"` |
| `notificationEmail` | string | Administrative contact email | `"admin@domain.com"` |

### Parameter Naming Conventions

- **CamelCase Format**: Use camelCase for all parameter names (`environmentName`, not `environment_name`)
- **Descriptive Names**: Use clear, descriptive parameter names that indicate purpose
- **Resource Group Naming**: Use `[component]ResourceGroupName` pattern for resource group references
- **Feature Flags**: Use `enable[FeatureName]` pattern for boolean feature toggles
- **Service-Specific**: Include service context in parameter names (`openAISku`, `storageAccountType`)

### Parameter Type Standards

```json
{
  "parameters": {
    "environmentName": { "value": "string-value" },
    "monthlyBudgetLimit": { "value": 150 },
    "enableFeature": { "value": true },
    "resourceTags": { 
      "value": {
        "Environment": "Lab",
        "Project": "AI Security"
      }
    },
    "allowedRegions": { 
      "value": ["East US", "West US 2", "Central US"] 
    }
  }
}
```

---

## 🎯 Parameter Categories and Organization

### Core Infrastructure Parameters

**Foundation Layer** (Required for all deployments):

```json
{
  "environmentName": { "value": "aisec" },
  "location": { "value": "East US" },
  "notificationEmail": { "value": "admin@domain.com" },
  "resourceTags": { 
    "value": {
      "Environment": "Lab",
      "Project": "AI Security Skills Challenge",
      "Week": "2"
    }
  }
}
```

### Feature-Specific Parameters

**Service Enablement Flags**:

```json
{
  "enableOpenAI": { "value": false },
  "enableCostManagement": { "value": true },
  "enableStorageAccount": { "value": true },
  "enableApplicationInsights": { "value": false }
}
```

**Service Configuration Parameters**:

```json
{
  "openAISku": { "value": "S0" },
  "storageAccountType": { "value": "Standard_LRS" },
  "monthlyBudgetLimit": { "value": 150 },
  "logRetentionDays": { "value": 30 }
}
```

### Cross-Component Integration Parameters

**Resource Group References**:

```json
{
  "aiResourceGroupName": { "value": "rg-aisec-ai" },
  "defenderResourceGroupName": { "value": "rg-aisec-defender-aisec" },
  "sentinelResourceGroupName": { "value": "rg-aisec-sentinel" }
}
```

**Service Integration Parameters**:

```json
{
  "logAnalyticsWorkspaceName": { "value": "law-aisec-defender" },
  "keyVaultName": { "value": "kv-aisec-ai" },
  "storageAccountName": { "value": "staisecai" }
}
```

---

## 🔤 Parameter Value Standards

### Email Address Parameters

**Automatic Object ID Resolution**:

- Use email addresses instead of manual Object ID lookup
- Deployment scripts automatically resolve email to Azure AD Object ID
- Provides better user experience and reduces configuration errors

```json
{
  "storageBlobContributorAccount": { "value": "user@domain.com" },
  "notificationEmail": { "value": "admin@domain.com" }
}
```

### Resource Naming Parameters

**Consistent Naming Patterns**:

```json
{
  "environmentName": { "value": "aisec" },
  "resourceGroupSuffix": { "value": "ai" },
  "storageAccountPrefix": { "value": "st" }
}
```

**Generated Resource Names** (Examples):

- Resource Group: `rg-aisec-ai`
- Storage Account: `staisecai`
- Key Vault: `kv-aisec-ai`
- Log Analytics: `law-aisec-ai`

### Boolean Feature Flags

**Feature Control Pattern**:

```json
{
  "enableOpenAI": { "value": false },
  "enableDefenderXDRIntegration": { "value": true },
  "enableMonitoring": { "value": true },
  "enableCostAlerts": { "value": true }
}
```

---

## 💻 PowerShell Script Integration

### Standard Script Parameter Pattern

All deployment scripts must support the `-UseParametersFile` parameter:

```powershell
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [switch]$UseParametersFile,
    
    [Parameter(Mandatory = $false)]
    [string]$EnvironmentName,
    
    [Parameter(Mandatory = $false)]
    [string]$Location
    # Additional parameters...
)

# Parameters file loading logic
if ($UseParametersFile) {
    $parametersPath = Join-Path $PSScriptRoot "..\infra\main.parameters.json"
    if (Test-Path $parametersPath) {
        $parametersContent = Get-Content $parametersPath | ConvertFrom-Json
        $EnvironmentName = $parametersContent.parameters.environmentName.value
        $Location = $parametersContent.parameters.location.value
        # Load additional parameters...
    }
}
```

### Script Execution Examples

**With Parameters File**:

```powershell
# Load all configuration from main.parameters.json
.\Deploy-StorageFoundation.ps1 -UseParametersFile
.\Deploy-AIFoundation.ps1 -UseParametersFile
.\Test-DeploymentValidation.ps1 -UseParametersFile -DetailedReport
```

**With Individual Parameters**:

```powershell
# Override specific parameters while using defaults for others
.\Deploy-AIFoundation.ps1 -EnvironmentName "prod" -Location "West US 2"
```

---

## 📊 Parameters File Extension Guidelines

### Cumulative Parameters Approach

**Adding New Features**:

1. **Never remove existing parameters** that other components depend on
2. **Add new parameters** for additional features or components
3. **Use feature flags** to enable/disable new functionality
4. **Maintain backward compatibility** with existing deployments

### Week 2 AI Integration Example

**Original Storage Foundation Parameters**:

```json
{
  "environmentName": { "value": "aisec" },
  "location": { "value": "East US" },
  "notificationEmail": { "value": "admin@domain.com" },
  "enableCostManagement": { "value": true }
}
```

**Extended for Defender XDR Integration**:

```json
{
  "environmentName": { "value": "aisec" },
  "location": { "value": "East US" },
  "notificationEmail": { "value": "admin@domain.com" },
  "enableCostManagement": { "value": true },
  "defenderResourceGroupName": { "value": "rg-aisec-defender-aisec" },
  "enableDefenderXDRIntegration": { "value": true },
  "recurrenceInterval": { "value": "PT15M" },
  "highSeverityOnly": { "value": true },
  "maxIncidentsPerRun": { "value": 10 }
}
```

### Cross-Week Dependencies

**Week 1 → Week 2 Integration**:

```json
{
  "week1ResourceGroupName": { "value": "rg-aisec-defender-aisec" },
  "logAnalyticsWorkspaceName": { "value": "law-aisec-defender" },
  "defenderForCloudEnabled": { "value": true }
}
```

**Week 2 → Week 3 Integration**:

```json
{
  "aiResourceGroupName": { "value": "rg-aisec-ai" },
  "openAIServiceName": { "value": "oai-aisec-ai" },
  "aiIntegrationEnabled": { "value": true }
}
```

---

## 🔍 Validation and Quality Assurance

### Parameters File Validation

**Pre-Deployment Validation**:

```bash
# Validate Bicep template with parameters
az deployment sub validate \
  --location "East US" \
  --template-file "main.bicep" \
  --parameters "@main.parameters.json"
```

**PowerShell Validation**:

```powershell
# Validate parameters file structure
$parametersPath = ".\infra\main.parameters.json"
if (Test-Path $parametersPath) {
    $parameters = Get-Content $parametersPath | ConvertFrom-Json
    if ($parameters.parameters.environmentName.value) {
        Write-Host "✅ Parameters file valid" -ForegroundColor Green
    }
}
```

### Required Parameter Checklist

Before deployment, verify:

- [ ] **Schema Declaration**: Correct Azure parameters schema URL
- [ ] **Content Version**: Proper version specification (`1.0.0.0`)
- [ ] **Foundation Parameters**: `environmentName`, `location`, `notificationEmail` present
- [ ] **Parameter Types**: Correct value types (string, integer, boolean, object, array)
- [ ] **Email Addresses**: Valid format for automatic Object ID resolution
- [ ] **Resource Names**: Follow Azure naming conventions
- [ ] **Feature Flags**: Appropriate boolean values for component enablement
- [ ] **Cross-References**: Valid resource group and service references

---

## 🛠️ Best Practices and Common Patterns

### Environment-Specific Configuration

**Lab Environment Example**:

```json
{
  "environmentName": { "value": "aisec" },
  "location": { "value": "East US" },
  "monthlyBudgetLimit": { "value": 150 },
  "openAISku": { "value": "S0" },
  "enableCostAlerts": { "value": true }
}
```

**Production Environment Considerations**:

```json
{
  "environmentName": { "value": "prod" },
  "location": { "value": "East US 2" },
  "monthlyBudgetLimit": { "value": 1000 },
  "openAISku": { "value": "S1" },
  "enableHighAvailability": { "value": true }
}
```

### Security and Compliance Parameters

**Security Configuration**:

```json
{
  "enablePrivateEndpoints": { "value": true },
  "restrictPublicAccess": { "value": false },
  "enableAuditLogging": { "value": true },
  "dataRetentionDays": { "value": 90 }
}
```

### Cost Management Parameters

**Budget and Cost Control**:

```json
{
  "monthlyBudgetLimit": { "value": 150 },
  "enableCostAlerts": { "value": true },
  "costAlertThresholds": { 
    "value": [50, 75, 90, 100] 
  },
  "enableAutoShutdown": { "value": true }
}
```

---

## 📚 Implementation Guidelines

### For New Parameters Files

- Start with foundation parameters template
- Add feature-specific parameters as needed
- Follow naming conventions consistently
- Include comprehensive parameter documentation
- Test parameter validation before deployment

### For Existing Parameters Files

- Use cumulative approach for additions
- Never remove parameters without impact analysis
- Update parameter documentation when extending
- Maintain backward compatibility with existing scripts
- Test all affected deployment scenarios

### For PowerShell Script Integration

- Implement `-UseParametersFile` parameter support
- Provide parameter loading logic and fallbacks
- Support both parameters file and individual parameter modes
- Include parameter validation and error handling
- Document parameter dependencies and requirements

---

## ✅ Quality Assurance Checklist

When reviewing parameters files, verify:

### Structure and Format

- [ ] **Correct JSON Schema**: Azure parameters schema declaration
- [ ] **Valid JSON Format**: Proper syntax and structure
- [ ] **Content Version**: Appropriate version specification
- [ ] **Parameter Organization**: Logical grouping and ordering

### Parameter Standards

- [ ] **Naming Conventions**: CamelCase format and descriptive names
- [ ] **Foundation Parameters**: Required parameters present
- [ ] **Type Consistency**: Appropriate parameter types (string, integer, boolean)
- [ ] **Value Validation**: Sensible default values and examples

### Integration Requirements

- [ ] **Cross-Component References**: Valid resource group and service names
- [ ] **Feature Flag Logic**: Proper boolean flag implementation
- [ ] **Email Format**: Valid email addresses for automatic resolution
- [ ] **Resource Naming**: Azure naming convention compliance

### Documentation and Usability

- [ ] **Parameter Documentation**: Clear descriptions and purposes
- [ ] **Example Values**: Realistic examples for configuration
- [ ] **Deployment Instructions**: Clear usage guidance
- [ ] **Validation Methods**: Testing and verification procedures

---

## 📖 Additional Resources

- **Azure Parameters Schema**: [Azure Resource Manager Parameters Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/parameters)
- **Azure Naming Conventions**: [Azure resource naming best practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- **PowerShell Best Practices**: [PowerShell Scripting Standards](https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101/00-introduction)
- **JSON Schema Validation**: [JSON Schema Specification](https://json-schema.org/)

---

## 🤖 AI-Assisted Content Generation

This comprehensive parameters file style guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Azure Resource Manager parameters best practices, PowerShell script integration patterns, and enterprise-grade configuration management standards.

*AI tools were used to enhance productivity and ensure comprehensive coverage of parameters file configuration standards while maintaining technical accuracy and reflecting Azure infrastructure-as-code best practices for multi-component deployment scenarios.*
