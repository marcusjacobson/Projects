# Manual Installation Guide

This guide teaches you to set up Azure development tools using **manual downloads first**, then introduces **PowerShell automation** for users comfortable with command-line tools. Perfect for beginners who want to understand each component before moving to advanced methods.

## 🎯 What You'll Install

- **Azure CLI** - Command-line interface for Azure.
- **PowerShell 7+** - Modern PowerShell with Azure support.
- **Visual Studio Code** - Development environment.
- **Azure PowerShell Modules** - PowerShell modules for Azure.
- **VS Code Extensions** - Azure development extensions.
- **Bicep CLI** - Infrastructure-as-Code tooling.

## 📖 Installation Approach

This guide uses a **progressive approach**:

1. **🖱️ Manual Downloads** - Click, download, install (beginner-friendly).
2. **⚡ PowerShell Alternative** - Command-line shortcuts (for experienced users).
3. **✅ Validation** - Test everything works together.

## 🛠️ Step 1: Azure CLI

### 🖱️ Manual Azure CLI Download (Recommended for Beginners)

1. **Visit the Download Page:** Go to [Azure CLI for Windows](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows).
2. **Download the Installer:** Click **"Download the MSI installer"** - choose the **64-bit version** for better performance.
3. **Run the Installer:** Double-click the downloaded file and follow the setup wizard with default settings.
4. **Important:** Close and reopen your terminal after installation to refresh the PATH.

### ⚡ WinGet Azure CLI Installation (For Experienced Users)

If you're comfortable with command-line tools, you can install via WinGet:

```powershell
winget install --exact --id Microsoft.AzureCLI
```

### 🔧 Basic Configuration

After installation (either method), configure Azure CLI:

```powershell
az config set defaults.location=eastus
az config set core.output=table
az config set auto-upgrade.enable=yes
az login
```

## 🛠️ Step 2: PowerShell 7+

### 🖱️ Manual PowerShell Download (Recommended for Beginners)

1. **Visit the Download Page:** Go to [PowerShell GitHub Releases](https://github.com/PowerShell/PowerShell/releases/latest)
2. **Find the Windows Installer:** Look for **PowerShell 7.5.2** (current version as of September 2025)
3. **Download:** Click on **PowerShell-7.5.2-win-x64.msi** (Windows 64-bit installer)
4. **Install:** Double-click the downloaded file and ensure **"Add PowerShell to PATH"** is checked
5. **Find the Application:** After installation, look for **"PowerShell 7"** in Start Menu (not "Windows PowerShell")

### ⚡ WinGet PowerShell Installation (For Experienced Users)

If you prefer command-line installation:

```powershell
winget install Microsoft.PowerShell
```

### ✅ Verify Installation

Open **PowerShell 7** and check the version:

```powershell
$PSVersionTable.PSVersion
# Should show version 7.5.2 or higher
```

## 🛠️ Step 3: Visual Studio Code

### 🖱️ Manual VS Code Download (Recommended for Beginners)

1. **Visit the Download Page:** Go to [Visual Studio Code](https://code.visualstudio.com/download)
2. **Choose Windows:** Click the large **Windows** download button for the 64-bit installer
3. **Download:** Save the **VSCodeUserSetup-x64-1.xx.x.exe** file to your computer
4. **Install:** Double-click the installer and **check "Add to PATH"** during installation
5. **Launch:** Open VS Code from Start Menu or desktop shortcut after installation

### ⚡ WinGet VS Code Installation (For Experienced Users)

If you prefer command-line installation:

```powershell
winget install Microsoft.VisualStudioCode
```

## 🛠️ Step 4: Azure PowerShell Modules

### 📋 Prerequisites Check

Before installing Azure modules, ensure you have:

- **PowerShell 7+ installed** (from Step 2).
- **Execution policy set** for security (we'll help you with this).

### 🖱️ Manual Module Installation (Recommended for Beginners)

#### Step 1: Set Execution Policy

Open **PowerShell 7** (as Administrator recommended) and allow module installation:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

When prompted, type **Y** and press Enter.

#### Step 2: Install Azure Modules

Install the core Azure modules one by one (copy and paste each command):

```powershell
# Install core Azure module (this takes a few minutes)
Install-Module -Name Az -Repository PSGallery -Force -Scope CurrentUser

# Install security-specific modules
Install-Module -Name Az.Security -Force -Scope CurrentUser
Install-Module -Name Az.SecurityInsights -Force -Scope CurrentUser
Install-Module -Name Az.CognitiveServices -Force -Scope CurrentUser
Install-Module -Name Az.OperationalInsights -Force -Scope CurrentUser
```

#### Step 3: Connect to Azure

```powershell
Import-Module Az
Connect-AzAccount
```

### ⚡ PowerShell Script Installation (For Experienced Users)

If you're comfortable with PowerShell scripting, you can run all installation commands at once:

```powershell
# Set execution policy and install all modules in one go
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
$modules = @('Az', 'Az.Security', 'Az.SecurityInsights', 'Az.CognitiveServices', 'Az.OperationalInsights')
$modules | ForEach-Object { Install-Module -Name $_ -Repository PSGallery -Force -Scope CurrentUser }
Import-Module Az
Connect-AzAccount
```

## 🛠️ Step 5: VS Code Extensions

### 🖱️ Manual Extension Installation (Recommended for Beginners)

**Install Extensions Using VS Code Interface:**

1. **Open VS Code** (from Start Menu or desktop)
2. **Open Extensions Panel:** Press `Ctrl+Shift+X` or click the Extensions icon in the sidebar
3. **Install Each Extension:** Search for and install these essential extensions:

   **Search for → Install:**
   - Search **"Azure Account"** → Install the one by Microsoft (`ms-vscode.azure-account`).
   - Search **"Azure CLI Tools"** → Install by Microsoft (`ms-azuretools.azure-cli-tools`).
   - Search **"Azure Resource Groups"** → Install by Microsoft (`ms-azuretools.vscode-azureresourcegroups`).
   - Search **"Bicep"** → Install by Microsoft (`ms-azuretools.vscode-bicep`).
   - Search **"PowerShell"** → Install by Microsoft (`ms-vscode.powershell`).
   - Search **"YAML"** → Install by Red Hat (`redhat.vscode-yaml`).

4. **Restart VS Code** after installing all extensions

### ⚡ Command Line Extension Installation (For Experienced Users)

If you're comfortable with terminals and have VS Code in PATH:

```powershell
# Run these commands in PowerShell 7
code --install-extension ms-vscode.azure-account
code --install-extension ms-azuretools.azure-cli-tools
code --install-extension ms-azuretools.vscode-azureresourcegroups
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-vscode.powershell
code --install-extension redhat.vscode-yaml
```

### 🔐 Connect VS Code to Azure

**Set Up Azure Integration:**

1. **Open Command Palette:** Press `Ctrl+Shift+P` in VS Code
2. **Sign Into Azure:** Type **"Azure: Sign In"** and press Enter
3. **Complete Authentication:** Follow the browser login process
4. **Verify Connection:** Check that Azure extensions show your subscriptions

## 🛠️ Step 6: Bicep CLI

### 📦 Automatic Installation via Azure CLI

Bicep CLI installs easily through Azure CLI (no separate download needed):

**Install Bicep:**

```powershell
az bicep install
```

**Verify Installation:**

```powershell
az bicep version
```

> **💡 Why Bicep?** Bicep is Microsoft's modern language for deploying Azure resources. It's simpler than JSON templates and integrates perfectly with Azure CLI.

## ✅ Validation & Testing

### 🖱️ Manual Testing (Recommended for Beginners)

**Test Each Tool Individually:**

1. **Test Azure CLI:** Open PowerShell 7 and run:

   ```powershell
   az --version
   ```

   You should see version 2.77.0 or higher.

2. **Test PowerShell:** Check your version:

   ```powershell
   $PSVersionTable.PSVersion
   ```

   You should see version 7.5.2 or higher.

3. **Test VS Code:** Open Command Palette (`Ctrl+Shift+P`) and type "Azure" - you should see Azure commands.

4. **Test Azure PowerShell:** Run:

   ```powershell
   Get-Module Az -ListAvailable
   ```

   You should see Azure modules listed.

5. **Test Bicep:** Check the version:

   ```powershell
   az bicep version
   ```

### ⚡ Comprehensive Automated Test (For Experienced Users)

**Complete Environment Validation Script:**

We provide a comprehensive validation script that tests all components of your Azure development environment.

**Run the validation script**:

```powershell
# Navigate to the Scripts folder
cd "..\Scripts\scripts-validation"

# Run basic validation
.\Test-AzureEnvironment.ps1

# Run detailed validation with extension checking and additional components
.\Test-AzureEnvironment.ps1 -DetailedReport

# Run quiet validation for logging/automation scenarios
.\Test-AzureEnvironment.ps1 -QuietMode
```

**What the script validates**:

- **PowerShell Version**: Checks for PowerShell 7+ (recommended) vs PowerShell 5.1.
- **Azure CLI**: Verifies installation and version information.
- **Azure PowerShell Modules**: Validates Az module and optional security modules.
- **Visual Studio Code**: Confirms VS Code is available in PATH and checks Azure extensions (with `-DetailedReport`).
- **Bicep CLI**: Ensures Bicep is available via Azure CLI.
- **Azure Authentication**: Checks authentication status for both Azure CLI and PowerShell.

**Expected Output**:

The script provides clear status indicators:

- ✅ **PASS**: Component installed and working correctly.
- ⚠️ **WARNING**: Component has minor issues or is not authenticated.
- ❌ **FAIL**: Component not installed or not working.
- 📊 **Summary**: Overall environment status with recommendations.

**Script Location**: [`Scripts\scripts-validation\Test-AzureEnvironment.ps1`](../Scripts/scripts-validation/Test-AzureEnvironment.ps1)

### 🎯 Expected Results

When everything is properly installed, you should see:

- **PowerShell:** Version 7.5.2 or higher.
- **Azure CLI:** Version 2.77.0 or higher.
- **Az Module:** Version 13.0.0 or higher.
- **VS Code:** Latest version with all 6 Azure extensions installed.
- **Bicep:** Current version displayed.
- **Authentication:** Connected to your Azure subscription (after running `az login` and `Connect-AzAccount`).

### 🖥️ VS Code Integration Test

**Test Azure Integration in VS Code:**

1. **Open VS Code** from Start Menu
2. **Open a New File:** Press `Ctrl+N`
3. **Save As Bicep:** Press `Ctrl+S` and save as `test.bicep`
4. **Test IntelliSense:** Type `resource` and see if autocomplete suggestions appear
5. **Test Azure Commands:** Press `Ctrl+Shift+P` and type "Azure" to see Azure commands
6. **Check Extensions:** Press `Ctrl+Shift+X` and verify all 6 Azure extensions are installed and enabled

## 🛠️ Common Issues & Solutions

### 🔍 Azure CLI Problems

#### "az is not recognized"

- **Solution:** Restart your PowerShell/Command Prompt after installation
- **Check PATH:** Run `Get-Command az` in PowerShell to verify installation
- **Reinstall:** If problems persist, download and reinstall the 64-bit MSI

### 🔍 PowerShell 7 Problems  

#### Can't find PowerShell 7

- **Look for the right app:** Search for "PowerShell 7" in Start Menu (not "Windows PowerShell")
- **Check installation:** Look in `C:\Program Files\PowerShell\7\` folder
- **PATH issues:** Run this to verify: `$env:PATH -split ';' | Where-Object { $_ -like '*PowerShell*' }`

### 🔍 Azure PowerShell Module Problems

#### "Execution policy" errors

- **Solution:** Run PowerShell as Administrator and execute:

  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

- **Verify:** Check with `Get-ExecutionPolicy`

#### Module installation fails

- **Run as Administrator:** Right-click PowerShell 7 → "Run as Administrator"
- **Check repository:** Verify PSGallery is trusted:

  ```powershell
  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
  ```

### 🔍 VS Code Extension Problems

#### Extensions not working

- **Check VS Code PATH:** Run `code --version` in PowerShell
- **Manual installation:** Use Extensions panel instead of command-line
- **Azure authentication:** Sign out and back into Azure Account in VS Code
- **Restart:** Close and reopen VS Code after installing extensions

#### Azure commands not appearing

- **Verify extensions:** Press `Ctrl+Shift+X` and check all 6 Azure extensions are installed
- **Sign in:** Press `Ctrl+Shift+P` → search "Azure: Sign In"
- **Reload window:** Press `Ctrl+Shift+P` → search "Developer: Reload Window"

### 🔍 Authentication Issues

#### Can't sign into Azure

- **Multiple tenants:** Use `az login --tenant <tenant-id>` if you have multiple tenants
- **Clear cached tokens:** Run `az account clear` then `az login` again
- **PowerShell authentication:** Run `Disconnect-AzAccount` then `Connect-AzAccount`
- **Browser issues:** Try `az login --use-device-code` for alternative login method

### 🆘 Get Additional Help

If you're still having trouble:

1. **Check versions:** Run the validation scripts above to identify specific issues
2. **Online documentation:** Visit [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/) for detailed help
3. **Community support:** Search [Microsoft Q&A](https://docs.microsoft.com/en-us/answers/) for solutions
4. **Start over:** If multiple issues persist, consider reinstalling individual components

---

## 🤖 AI-Assisted Content Generation

This manual installation guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of manual installation procedures while maintaining technical accuracy and current best practices.*
