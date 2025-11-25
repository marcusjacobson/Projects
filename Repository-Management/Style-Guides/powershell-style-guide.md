# PowerShell Script Style Guide for Azure Deployment Automation

This style guide establishes consistent visual and organizational patterns for PowerShell scripts in Azure deployment automation projects. It defines clear hierarchical structures, color schemes, and terminology usage to enhance readability, maintainability, and user experience.

## 📋 General Principles

### Professional Script Architecture

- Use clear, hierarchical organization with distinct orchestrator and individual script patterns.
- Implement consistent color schemes for visual clarity and user experience.
- Maintain standardized terminology throughout all scripts (Phase vs Step).
- Provide comprehensive status feedback and error handling.
- Follow established naming conventions and formatting standards.

### Visual Consistency and User Experience

- Use consistent color coding for similar message types across all scripts.
- Provide clear visual hierarchy with appropriate headers and indentation.
- Include progress indicators and status notifications for user feedback.
- Implement professional emoji usage for enhanced readability.

---

## 📝 Script Preamble Standards

### Industry-Standard Documentation Requirements

All PowerShell scripts must include a comprehensive preamble at the top of the file that provides complete documentation for users, administrators, and future maintainers. This preamble follows industry-standard practices and ensures professional documentation quality.

### Required Preamble Structure

PowerShell scripts must use the industry-standard comment-based help format with dot-prefixed headers. This format provides native PowerShell help integration and follows Microsoft's official documentation standards.

```powershell
<#
.SYNOPSIS
    Brief one-line description of what the script does.

.DESCRIPTION
    Comprehensive multi-paragraph description explaining the script's purpose,
    functionality, and expected outcomes. Include details about what the script
    accomplishes, how it integrates with other components, and any important
    operational considerations.

.PARAMETER ParameterName
    Description of each parameter including its purpose, expected values,
    and any special considerations for usage.

.EXAMPLE
    .\ScriptName.ps1 -UseParametersFile
    
    Basic usage with parameters file loading configuration from main.parameters.json.

.EXAMPLE
    .\ScriptName.ps1 -EnvironmentName "prodlab" -Location "East US"
    
    Custom usage with specific parameters for targeted deployment scenarios.

.NOTES
    Author: Marcus Jacobson
    Version: 1.0.0
    Created: YYYY-MM-DD
    Last Modified: YYYY-MM-DD
    
    Copyright (c) YYYY Marcus Jacobson. All rights reserved.
    Licensed under the MIT License.
    
    Requirements:
    - Azure CLI installed and authenticated
    - PowerShell 5.1+ or PowerShell 7+
    - Appropriate Azure permissions for the target operations
    - Any specific Azure services or features required
    - Additional tool or module dependencies
    
    Script development orchestrated using GitHub Copilot.

.SPECIALIZED_SECTION
    Custom sections specific to the script's functionality:
    - Deployment phases, validation components, security features, etc.
    - Use descriptive section names that reflect the script's purpose
    - Maintain consistent formatting with bullet points and clear hierarchy
#>
#
# =============================================================================
# Brief script summary line that reinforces the main purpose.
# =============================================================================
```

### Specialized Preamble Sections

Based on script functionality, include appropriate specialized sections that provide context-specific information relevant to users and maintainers.

#### When to Include Specialized Sections

Add specialized sections when your script has unique characteristics that benefit from additional documentation:

- **Complex workflows**: Scripts that orchestrate multiple operations or phases
- **Domain-specific functionality**: Scripts focused on compliance, cost analysis, testing, etc.
- **Integration requirements**: Scripts that interact with specific Azure services or external systems
- **Configuration dependencies**: Scripts with particular setup or prerequisite requirements

#### Common Specialized Section Types

Choose the most appropriate section type(s) for your script:

**PHASES** - For orchestrator scripts that coordinate multiple operations:

```powershell
# PHASES
#     Phase 1: [Brief description] ([script-name.ps1])
#     Phase 2: [Brief description] ([script-name.ps1])
#     Phase N: [Brief description] ([script-name.ps1])
```

**COMPLIANCE STANDARDS** - For scripts managing regulatory or security compliance:

```powershell
# COMPLIANCE STANDARDS
#     - [Primary compliance framework]
#     - [Secondary compliance framework]
#     - [Additional standards as applicable]
```

**COST CATEGORIES** - For scripts analyzing or managing Azure costs:

```powershell
# COST CATEGORIES
#     - [Primary cost category] ([brief explanation])
#     - [Secondary cost category] ([brief explanation])
#     - [Additional cost factors as relevant]
```

**TEST SCENARIOS** - For validation or testing scripts:

```powershell
# TEST SCENARIOS
#     - [Test category 1] ([brief scope])
#     - [Test category 2] ([brief scope])
#     - [Additional test types as applicable]
```

**INTEGRATION POINTS** - For scripts that connect with external services:

```powershell
# INTEGRATION POINTS
#     - [Service/system 1] ([connection type])
#     - [Service/system 2] ([connection type])
#     - [Additional integrations as applicable]
```

**CONFIGURATION ITEMS** - For scripts that manage complex configurations:

```powershell
# CONFIGURATION ITEMS
#     - [Configuration area 1] ([scope or impact])
#     - [Configuration area 2] ([scope or impact])
#     - [Additional configuration aspects]
```

#### Guidelines for Creating Custom Specialized Sections

When none of the common types fit your script's unique requirements:

1. **Use descriptive section names** that clearly indicate the content purpose
2. **Follow the established format** with section header and bulleted list
3. **Keep entries concise** but informative enough to provide value
4. **Focus on information** that helps users understand scope, dependencies, or outcomes
5. **Consider the audience** - what would be most helpful for someone using or maintaining this script?

**Example of a custom specialized section:**

```powershell
# BACKUP OPERATIONS
#     - VM snapshot creation (point-in-time recovery)
#     - Configuration backup (settings and policies)
#     - Recovery testing (validation of backup integrity)
```

### Authorship and Attribution Standards

All scripts must include consistent authorship information:

```powershell
# AUTHOR
#     Marcus Jacobson
#     Script development orchestrated using GitHub Copilot
```

This attribution format:

- Identifies the primary author and maintainer
- Acknowledges the use of AI assistance in development
- Maintains transparency about development methodology
- Provides contact context for future maintenance

### Version Control Integration

The preamble supports version tracking:

```powershell
# VERSION
#     1.0.0
#
# CREATED
#     2025-08-04
#
# LAST MODIFIED
#     2025-08-04
```

Use semantic versioning (MAJOR.MINOR.PATCH) and maintain accurate timestamps for change tracking.

---

## 🎯 Script Classification and Structure

### Orchestrator Scripts (Use "Phase" Terminology)

**Purpose**: Scripts that call other scripts, manage complex workflows, or coordinate multiple deployment components.

**Examples**:

- `Deploy-Complete.ps1` - Master deployment orchestrator.
- `Test-FinalLabValidation.ps1` - Comprehensive validation workflow.
- `Remove-DefenderInfrastructure.ps1` - Multi-step decommission process.

**Structure**:

```powershell
# =============================================================================
# Phase 1: Infrastructure Foundation
# =============================================================================

Write-Host "📋 Phase 1: Infrastructure Foundation" -ForegroundColor Magenta
Write-Host "====================================" -ForegroundColor Magenta
```

### Individual Component Scripts (Use "Step" Terminology)

**Purpose**: Scripts that perform specific deployment tasks, individual component configurations, or focused operations.

**Examples**:

- `Deploy-InfrastructureFoundation.ps1` - Single-purpose infrastructure deployment.
- `Deploy-VirtualMachines.ps1` - VM-specific deployment.
- `Deploy-DefenderPlans.ps1` - Security plan configuration.
- `Deploy-SecurityFeatures.ps1` - Security feature setup.
- `Test-DeploymentValidation.ps1` - Validation operations.

**Structure**:

```powershell
# =============================================================================
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔍 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
```

### Pipeline-Executed Scripts (Use "Action" Terminology)

**Purpose**: Scripts designed to be executed within Azure DevOps pipelines or CI/CD environments, typically performing single focused tasks with parameter-driven configuration.

**Examples**:

- `rg-deploy.ps1` - Resource group creation/validation for pipeline.
- `analytics-rule-deploy.ps1` - Analytics rule deployment in pipeline context.
- `watchlist-deploy.ps1` - Watchlist management through pipeline.
- `deploy-log-analytics-sentinel.ps1` - Log Analytics workspace pipeline deployment.

**Structure**:

```powershell
# =============================================================================
# Action: Resource Group Validation and Creation
# =============================================================================

Write-Verbose "🔍 Validating Azure subscription access..." -Verbose
Write-Verbose "==========================================" -Verbose
```

**Key Characteristics:**

- **Parameter-Driven**: Heavy reliance on input parameters from pipeline variables
- **Verbose Logging**: Use `Write-Verbose` with `-Verbose` for pipeline visibility
- **REST API Integration**: Often use direct REST calls for enhanced control
- **Error Handling**: Comprehensive try-catch blocks for pipeline stability
- **No Interactive Elements**: No user prompts or interactive components

```powershell
# =============================================================================
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔍 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
```

---

## 🎨 Color Scheme Standards

### Primary Colors

- **Magenta** (`-ForegroundColor Magenta`): Main phase headers in orchestrator scripts.
- **Green** (`-ForegroundColor Green`): Step headers in individual scripts, success messages.
- **Blue** (`-ForegroundColor Blue`): Script orchestration notifications (calling scripts, completion status).
- **Red** (`-ForegroundColor Red`): Error messages, failure notifications.
- **Cyan** (`-ForegroundColor Cyan`): Informational messages, section descriptions.
- **Yellow** (`-ForegroundColor Yellow`): Warnings, confirmations, important notices.

### Pipeline-Specific Output Standards

**For Pipeline-Executed Scripts:**

- **Write-Verbose with -Verbose**: Primary output method for pipeline visibility
- **Write-Error**: For errors that should appear in pipeline logs
- **Write-Warning**: For warnings that need pipeline attention
- **No Write-Host**: Avoid colored output in pipeline contexts (use verbose instead)

**Pipeline Output Examples:**

```powershell
# Pipeline-friendly verbose output
Write-Verbose "🔍 Validating Azure subscription access..." -Verbose
Write-Verbose "    ✅ Subscription validation successful" -Verbose
Write-Verbose "    ❌ Subscription validation failed: $($_.Exception.Message)" -Verbose

# Error handling for pipelines
try {
    # Operation code
    Write-Verbose "    ✅ Operation completed successfully" -Verbose
} catch {
    Write-Error "Operation failed: $($_.Exception.Message)"
    throw
}
```

- **Yellow** (`-ForegroundColor Yellow`): Warnings, confirmations, important notices.

### Status Indicators

```powershell
# Success notifications
Write-Host "✅ Script 'Deploy-InfrastructureFoundation.ps1' completed successfully" -ForegroundColor Blue

# Failure notifications  
Write-Host "❌ Script 'Deploy-InfrastructureFoundation.ps1' failed (exit code: $LASTEXITCODE)" -ForegroundColor Red

# Script initiation
Write-Host "🚀 Calling script 'Deploy-InfrastructureFoundation.ps1'..." -ForegroundColor Blue
```

---

## 📊 Hierarchical Organization

### Orchestrator Scripts Structure

1. **Parameter validation and setup**.
2. **Phase 1**: Primary foundation (infrastructure, authentication).
3. **Phase 2**: Core components (VMs, networks, storage).
4. **Phase 3**: Security configuration (Defender plans, policies).
5. **Phase 4**: Advanced features (JIT access, monitoring).
6. **Phase 5**: Validation and reporting.

### Individual Scripts Structure

1. **Step 1**: Environment validation and prerequisites.
2. **Step 2**: Template preparation and validation.
3. **Step 3**: Main deployment/configuration.
4. **Step 4**: Post-deployment validation.
5. **Step 5**: Integration and next steps.

---

## 🔤 Header Formatting Standards

### Phase Headers (Orchestrators)

```powershell
# =============================================================================
# Phase N: Descriptive Name
# =============================================================================

Write-Host "🔸 Phase N: Descriptive Name" -ForegroundColor Magenta
Write-Host "============================" -ForegroundColor Magenta
```

### Step Headers (Individual Scripts)

```powershell
# =============================================================================
# Step N: Descriptive Name
# =============================================================================

Write-Host "🔸 Step N: Descriptive Name" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
```

### Subsection Headers

```powershell
Write-Host "📋 Subsection description..." -ForegroundColor Cyan
```

---

## 🔔 Script Notification Patterns

### Enhanced Success/Failure Notifications

```powershell
# In orchestrator scripts when calling other scripts:
Write-Host "🚀 Calling script 'ScriptName.ps1'..." -ForegroundColor Blue
& $scriptPath @params

if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
    Write-Host "✅ Script 'ScriptName.ps1' completed successfully" -ForegroundColor Blue
    Write-Host "✅ Phase N completed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Script 'ScriptName.ps1' failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
    throw "Script exited with code: $LASTEXITCODE"
}
```

---

## 😀 Emoji and Icon Usage

### Standard Icons by Category

- **🚀** - Script initiation, deployment start.
- **✅** - Success, completion.
- **❌** - Errors, failures.
- **📋** - Configuration, lists.
- **🔍** - Validation, discovery.
- **🔐** - Security, authentication.
- **🛡️** - Defender, protection.
- **🖥️** - Virtual machines, compute.
- **🌐** - Networking, connectivity.
- **💾** - Storage, data.
- **📊** - Reporting, analysis.
- **⚠️** - Warnings, cautions.
- **💡** - Tips, recommendations.
- **🎯** - Targets, objectives.

---

## ⚠️ Error Handling Standards

### Consistent Error Patterns

```powershell
try {
    # Operation code
    Write-Host "   ✅ Operation successful" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Operation failed: $_" -ForegroundColor Red
    # Handle error appropriately
}
```

---

## 🌐 REST API Integration Standards

### Preferred Azure Operation Methods

**Always prefer REST API calls** over direct PowerShell cmdlets or standard CLI commands when possible. This approach provides enhanced control, better error handling, and more precise resource management.

- **For Azure Resources (ARM)**: Use `az rest` commands.
- **For Microsoft Entra ID (Graph)**: Use `Invoke-MgGraphRequest` (Microsoft Graph PowerShell SDK).

### REST API Method Hierarchy

**Recommended Order of Operations:**

1. **Primary**: Direct REST API calls (`az rest` or `Invoke-MgGraphRequest`)
2. **Secondary**: Azure CLI commands (`az resource`, `az group`, etc.)
3. **Tertiary**: Azure PowerShell cmdlets (only when REST API unavailable)

### REST API Implementation Patterns

**Resource Management Examples:**

```powershell
# Preferred: Direct REST API call
$response = az rest --method GET --url "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/resources?api-version=2021-04-01"
$resources = $response | ConvertFrom-Json

# Alternative: Standard Azure CLI (when REST API is complex)
$resources = az resource list --resource-group $resourceGroupName --output json | ConvertFrom-Json
```

**Resource Validation Examples:**

```powershell
# Preferred: REST API for resource existence check
try {
    $response = az rest --method GET --url "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Storage/storageAccounts/$storageAccountName?api-version=2023-01-01"
    $storageAccount = $response | ConvertFrom-Json
    Write-Verbose "   ✅ Storage account validated via REST API" -Verbose
} catch {
    Write-Error "Storage account validation failed: $($_.Exception.Message)"
}
```

**Microsoft Graph API Integration:**

```powershell
# Microsoft Graph REST API calls
$graphResponse = az rest --method GET --url "https://graph.microsoft.com/v1.0/security/incidents" --resource "https://graph.microsoft.com"
$incidents = $graphResponse | ConvertFrom-Json

# Enhanced error handling for Graph API
try {
    $response = az rest --method POST --url "https://graph.microsoft.com/v1.0/security/incidents/$incidentId/comments" --body $commentJson --resource "https://graph.microsoft.com"
    Write-Verbose "   ✅ Comment added via Microsoft Graph API" -Verbose
} catch {
    Write-Warning "Graph API operation failed: $($_.Exception.Message)"
}
```

### Pipeline-Specific REST API Usage

**For Pipeline-Executed Scripts:**

```powershell
# Use REST API for enhanced Azure resource control in pipelines
Write-Verbose "🔍 Validating resource via REST API..." -Verbose

try {
    $apiResponse = az rest --method GET --url $resourceUrl --query "{name:name, status:properties.provisioningState}"
    $resourceInfo = $apiResponse | ConvertFrom-Json
    
    Write-Verbose "    ✅ Resource validation successful: $($resourceInfo.name)" -Verbose
} catch {
    Write-Error "REST API validation failed: $($_.Exception.Message)"
    throw
}
```

### REST API Benefits

**Why Prefer REST API Calls:**

- **Enhanced Control**: Direct access to Azure Resource Manager APIs
- **Better Error Handling**: More precise error messages and status codes
- **API Version Control**: Explicit API version specification for consistency
- **Pipeline Reliability**: More stable execution in automated environments
- **Future-Proofing**: Direct alignment with Azure's native REST interface
- **Advanced Features**: Access to preview features and advanced configurations

### REST API Best Practices

**Implementation Guidelines:**

- **Always specify API versions** explicitly in REST URLs
- **Include comprehensive error handling** for REST API responses
- **Use appropriate HTTP methods** (GET, POST, PUT, DELETE, PATCH)
- **Validate JSON responses** before processing data
- **Include retry logic** for transient failures
- **Log REST API calls** for debugging and audit purposes

**Error Handling Pattern:**

```powershell
# Standard REST API error handling pattern
try {
    $response = az rest --method $httpMethod --url $apiUrl --body $requestBody
    $result = $response | ConvertFrom-Json
    
    # Validate response structure
    if ($result -and $result.name) {
        Write-Verbose "   ✅ REST API operation successful" -Verbose
        return $result
    } else {
        throw "Invalid response structure from REST API"
    }
} catch {
    Write-Error "REST API operation failed: $($_.Exception.Message)"
    # Include specific retry logic if appropriate
    throw
}
```

---

## 💡 Best Practices

### 1. Consistent Indentation

- Use 4 spaces for indentation.
- Align continuation lines properly.
- Maintain consistent bracket placement.

### 2. Descriptive Messages

- Include context in all messages.
- Provide actionable error information.
- Use consistent terminology throughout.

### 3. Progressive Disclosure

- Start with high-level phase/step information.
- Provide detailed feedback within sections.
- Summarize results at completion.

### 4. User Experience

- Use consistent color coding for similar message types.
- Provide clear visual hierarchy.
- Include progress indicators for long operations.

---

## 📝 Examples

### Complete Orchestrator Pattern

```powershell
# =============================================================================
# Phase 1: Infrastructure Foundation
# =============================================================================

Write-Host "📋 Phase 1: Infrastructure Foundation" -ForegroundColor Magenta
Write-Host "====================================" -ForegroundColor Magenta

try {
    $scriptPath = Join-Path $scriptsPath "Deploy-InfrastructureFoundation.ps1"
    $params = @{ EnvironmentName = $EnvironmentName; Location = $Location }
    
    Write-Host "🚀 Calling script 'Deploy-InfrastructureFoundation.ps1'..." -ForegroundColor Blue
    & $scriptPath @params
    
    if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
        Write-Host "✅ Script 'Deploy-InfrastructureFoundation.ps1' completed successfully" -ForegroundColor Blue
        Write-Host "✅ Phase 1 completed successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Script 'Deploy-InfrastructureFoundation.ps1' failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
        throw "Script exited with code: $LASTEXITCODE"
    }
} catch {
    Write-Host "❌ Phase 1 failed: $_" -ForegroundColor Red
    exit 1
}
```

### Complete Individual Script Pattern

```powershell
# =============================================================================
# Step 1: Environment Validation
# =============================================================================

Write-Host "🔍 Step 1: Environment Validation" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "📋 Validating deployment environment..." -ForegroundColor Cyan
try {
    # Validation logic
    Write-Host "   ✅ Environment validation successful" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Environment validation failed: $_" -ForegroundColor Red
    throw
}
```

---

## 🎯 Implementation Guidelines

### For New PowerShell Scripts

- Start with this style guide as the foundation for all new PowerShell script development.
- Determine script classification (orchestrator vs individual) before beginning development.
- Apply appropriate color schemes and terminology consistently throughout the script.
- Implement comprehensive status notifications and error handling patterns.

### For Existing PowerShell Scripts

- Perform systematic script-by-script reviews using this guide.
- Apply fixes using the replace_string_in_file methodology for precision.
- Focus on one style guide element at a time (headers, then colors, then notifications).
- Test scripts after modifications to ensure functionality is preserved.

### For Script Review Processes

- Use this guide as the primary reference for PowerShell script standardization tasks.
- Implement changes systematically rather than skipping around scripts.
- Ensure complete script coverage by reviewing from beginning to end.
- Apply sufficient context when making edits to ensure accuracy.

---

## 📚 Additional Resources

- **PowerShell Best Practices**: [docs.microsoft.com/powershell](https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101/00-introduction)
- **Azure PowerShell Documentation**: [Azure PowerShell Guide](https://docs.microsoft.com/en-us/powershell/azure/)
- **PowerShell Style Guide**: [PowerShell Community Style Guide](https://poshcode.gitbooks.io/powershell-practice-and-style/)
- **Azure Naming Conventions**: [Azure resource naming best practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)

---

## 🤖 AI Assistant Compliance Prompt

Use this prompt when you want to ensure a PowerShell script is fully compliant with this style guide:

```text
Please review this PowerShell script for compliance with the Azure Deployment Automation PowerShell style guide. Follow these requirements:

1. **Systematic Section-by-Section Review**: Go through the script from beginning to end, section by section. Do not skip around or jump between sections.

2. **Style Guide Compliance Areas**: Check for compliance with:
   - **Script preamble standards**: Complete industry-standard documentation header including SYNOPSIS, DESCRIPTION, AUTHOR, VERSION, CREATED/LAST MODIFIED, COPYRIGHT, LICENSE, REQUIREMENTS, EXAMPLES, NOTES, and appropriate specialized sections
   - **Authorship attribution**: Consistent "Marcus Jacobson" with "Script development orchestrated using GitHub Copilot" format
   - **Specialized sections**: Appropriate specialized sections based on script type (PHASES for orchestrators, COMPLIANCE STANDARDS, COST CATEGORIES, TEST SCENARIOS, INTEGRATION POINTS, CONFIGURATION ITEMS, or custom sections as applicable)
   - **Preamble structure**: Verify all required sections are present and follow the established format and ordering
   - **Version control integration**: Proper semantic versioning and timestamp accuracy
   - Script classification (orchestrator vs individual component)
   - Proper terminology usage (Phase for orchestrators, Step for individual scripts)
   - Color scheme standards (Magenta for phases, Green for steps, Blue for notifications, Red for failures)
   - Header formatting standards with proper comment blocks and Write-Host statements
   - Enhanced status notification patterns for script calls
   - Emoji and icon usage following established standards
   - Consistent indentation and code formatting
   - Professional error handling patterns
   - Progressive disclosure and user experience principles

3. **Implementation Method**: Use the replace_string_in_file tool with sufficient context (3-5 lines before and after) for precise edits.

4. **Multiple Passes**: After completing the first full section-by-section review, perform additional passes as needed until all style guide issues are resolved.

5. **Functionality Preservation**: Ensure that all modifications maintain the original script functionality while improving compliance.

6. **Completion Criteria**: Continue iterating through the script until you can confirm that:
   - The script has a complete, professional preamble with all required sections
   - All preamble sections follow the established format and contain appropriate content
   - Authorship attribution is consistent with project standards
   - Specialized sections are included when applicable and provide meaningful context
   - All script sections comply with style guide standards
   - The script maintains its original functionality while meeting documentation standards

Please start the review from the beginning of the script and work systematically through each section.
```

---

## ✅ Compliance

All PowerShell scripts in the Azure deployment automation project should follow these standards to ensure:

- Consistent user experience across all scripts.
- Clear visual hierarchy and organization.
- Effective error handling and reporting.
- Professional appearance and maintainability.

---

## 📈 Revision History

- **v1.0** - Initial style guide establishment.
- Covers orchestrator vs. individual script patterns.
- Defines comprehensive color scheme and terminology.
- Establishes header formatting and notification standards.

---

## 🔧 Emoji Corruption Handling

### Detection and Resolution of Emoji Corruption Issues

PowerShell scripts may occasionally experience emoji corruption where Unicode characters become malformed, typically displaying as � replacement characters or causing mixed content within files. This issue has been observed in development environments and requires specific handling procedures.

#### Common Corruption Symptoms

- **Mixed Content**: Script text becomes interleaved with corrupted characters
- **Malformed Emojis**: Emojis display as � or other replacement characters  
- **Preamble Corruption**: Comment-based help sections become fragmented
- **Header Disruption**: Step headers and formatting become unreadable
- **File Structure Issues**: Code blocks appear out of order or duplicated

#### Corruption Resolution Methodology

**When emoji corruption is detected, follow this systematic approach:**

1. **Assessment Phase**:
   - Verify corruption scope using `grep_search` with `�` pattern
   - Check if corruption affects preamble, headers, or content body
   - Determine if file structure remains intact or requires complete recreation

2. **Resolution Strategy**:
   - **Minor Corruption**: Use targeted `replace_string_in_file` operations
   - **Extensive Corruption**: Complete file recreation is the most reliable solution
   - **Preamble Corruption**: Often requires full file recreation due to interleaved content

3. **File Recreation Process**:

   ```powershell
   # Remove corrupted file
   Remove-Item "path\to\corrupted-script.ps1" -Force
   
   # Recreate using clean content in sections
   # Build preamble, parameters, and script body separately
   # Use terminal commands with proper escaping for emojis
   ```

4. **Validation Steps**:
   - Verify syntax with `get_errors` tool
   - Check emoji integrity with targeted `grep_search`
   - Confirm no � corruption characters remain
   - Validate PowerShell style guide compliance

#### Prevention Best Practices

- **File Encoding**: Always use UTF-8 encoding for PowerShell scripts
- **Terminal Creation**: Use PowerShell terminal commands for complex emoji content
- **Systematic Building**: Create scripts in logical sections rather than single operations
- **Regular Validation**: Check emoji integrity during development process

#### Recovery Success Indicators

- Zero PowerShell syntax errors
- Clean emoji display (🔍, 🚀, ✅, etc.)
- No � replacement characters
- Proper PowerShell style guide compliance
- Functional script execution

This approach has proven effective in resolving severe emoji corruption issues that cannot be addressed through standard editing operations.

---

*This style guide is a living document that should be updated as project standards evolve and new PowerShell scripting requirements are identified.*

---

## 🤖 AI-Assisted Content Generation

This comprehensive PowerShell style guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell scripting standards, preamble templates, and automation best practices were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating modern PowerShell development practices and enterprise-grade scripting standards.

*AI tools were used to enhance productivity and ensure comprehensive coverage of PowerShell scripting standards while maintaining technical accuracy and reflecting industry best practices for infrastructure automation and deployment scripting.*
