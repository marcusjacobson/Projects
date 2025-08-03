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

6. **Completion Criteria**: Continue iterating through the script until you can confirm that all sections comply with the style guide standards.

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

*This style guide is a living document that should be updated as project standards evolve and new PowerShell scripting requirements are identified.*
