# 00.02 Development Environment Setup

Set up essential Azure development tools using **beginner-friendly manual downloads first**, then progress to **PowerShell automation** for advanced users. Perfect for learning fundamentals before moving to command-line efficiency.

## 🎯 Objectives

- Install Azure CLI, PowerShell 7+, Visual Studio Code, and Bicep CLI using manual downloads.
- Learn each component's purpose before automating the process.
- Configure Azure authentication for all tools.
- Progress from manual understanding to automated efficiency.
- Validate complete development environment functionality.

## 🛠️ Required Tools

| Tool | Purpose |
|------|---------|
| **Azure CLI** | Command-line interface for Azure resource management |
| **PowerShell 7+** | Modern PowerShell with Azure modules |
| **Visual Studio Code** | Development environment with Azure extensions |
| **Bicep CLI** | Infrastructure-as-Code template development |

## 📁 Installation Guides

### Manual Installation (Recommended for Beginners)

**[Manual Installation Guide](./development-environment-setup.md)**

- **Beginner-friendly approach** with click-by-click instructions.
- Download and install each tool from official sources.
- Manual downloads first, then PowerShell alternatives for experienced users.
- Step-by-step validation and comprehensive troubleshooting.
- Perfect for learning fundamentals before automation.

### Automated Installation (Advanced PowerShell Users)

**[Automated Installation Script](../Scripts/scripts-deployment/Install-DevelopmentEnvironment.ps1)**

- **Advanced automation** using PowerShell with modular switches.
- Assumes PowerShell expertise and administrative access.
- Complete error handling and validation throughout installation process.
- Requires PowerShell 7+ to be installed manually first.
- Best for users comfortable with command-line automation.

## ✅ Validation Checklist

**Verify Installation Success (Choose Your Method):**

### 🖱️ Manual Testing (Beginner-Friendly)

- [ ] **Azure CLI**: Open PowerShell 7 and run `az --version` - should show version 2.77.0+.
- [ ] **PowerShell 7+**: Run `$PSVersionTable.PSVersion` - should show 7.5.2+.
- [ ] **Azure PowerShell**: Run `Get-Module Az -ListAvailable` - should list Azure modules.
- [ ] **Visual Studio Code**: Open VS Code, press `Ctrl+Shift+P`, type "Azure" - should see Azure commands.
- [ ] **Bicep CLI**: Run `az bicep version` - should return version information.
- [ ] **Authentication**: Both `az login` and `Connect-AzAccount` should work.

### ⚡ Automated Testing (Advanced Users)

- [ ] **Quick Test**: Run the comprehensive validation script from the manual guide.
- [ ] **Script Test**: Use `..\Scripts\scripts-deployment\Install-DevelopmentEnvironment.ps1 -ValidateOnly`.

## 🔍 Quick Test

### 🖱️ Individual Testing (Recommended for Beginners)

Open **PowerShell 7** and test each tool separately:

```powershell
# Test Azure CLI
az --version

# Test PowerShell version
$PSVersionTable.PSVersion

# Test Azure PowerShell modules
Get-Module Az -ListAvailable

# Test Bicep CLI
az bicep version
```

### ⚡ Comprehensive Testing (Advanced Users)

Run the complete validation script from the manual guide or use the automated script's validation mode:

```powershell
# Use automated validation
..\Scripts\scripts-deployment\Install-DevelopmentEnvironment.ps1 -ValidateOnly
```

All commands should return version information without errors.

## ✅ Success Validation

**Before proceeding to Module 00.03, verify all tools are working:**

- [ ] **Azure CLI authenticated**: `az account show` displays your subscription
- [ ] **PowerShell modules available**: `Get-Module Az -ListAvailable` shows Azure modules
- [ ] **VS Code ready**: Open VS Code, press `Ctrl+Shift+P`, type "Azure" - see Azure commands
- [ ] **All tools authenticated**: Both `az login` and `Connect-AzAccount` work without errors

> **🎯 Success Criteria**: All commands return valid information without error messages. If any fail, use the troubleshooting section in the detailed guide.

## 🔄 Next Steps

Continue to: [Azure Cost Fundamentals & Budget Setup](../00.03%20Azure%20Cost%20Fundamentals%20&%20Budget%20Setup/README.md)

## 📚 Resources

- **[Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)**
- **[PowerShell 7 Documentation](https://docs.microsoft.com/en-us/powershell/)**
- **[VS Code Azure Extensions](https://code.visualstudio.com/docs/azure/extensions)**
- **[Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)**

---

## 🤖 AI-Assisted Content Generation

This development environment setup guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Azure development environment setup while maintaining technical accuracy and current best practices.*
