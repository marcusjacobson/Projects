# Week 00 to Week 1 Bridge: Environment Readiness Check

Quick validation that your Week 00 setup is complete and you're ready to begin Week 1 Microsoft Defender for Cloud deployment.

## 🔍 Quick Readiness Check

### Step 1: Azure Portal Access

1. Navigate to [portal.azure.com](https://portal.azure.com) and sign in.
2. Verify your subscription appears and is accessible.
3. Check that **East US** is available when creating resources.

### Step 2: Development Tools

1. **Azure CLI**: Run `az --version` (should show v2.60+) and `az account show` (shows your subscription).
2. **PowerShell**: Run `Get-Module -ListAvailable Az` (should show v10.0+ modules).
3. **VS Code**: Verify Azure extensions are installed and authenticated.

### Step 3: Service Registration Check

1. In **Azure Portal**: **Subscriptions** → Your Subscription → **Settings** → **Resource providers**.
2. Verify these show as **Registered**:
   - `Microsoft.Security`
   - `Microsoft.OperationalInsights`
   - `Microsoft.PolicyInsights`
   - `Microsoft.Storage`
   - `Microsoft.KeyVault`

### Step 4: Deployment Permissions

1. Navigate to **Resource groups** in **Azure Portal**.
2. Click **+ Create** and select **East US** region.
3. Verify the form loads without errors (then cancel).

## ✅ Final Checklist

- [ ] **Portal Access**: Can sign in and navigate **Azure Portal**.
- [ ] **Tools Working**: Azure CLI, PowerShell, and VS Code all functional.  
- [ ] **Services Registered**: All required resource providers registered.
- [ ] **Permissions Confirmed**: Can access resource creation forms.
- [ ] **Region Available**: East US selectable for deployments.

## 🚀 Ready for Week 1?

If all checklist items are complete, you're ready to begin:

**Start Week 1**: [Defender for Cloud Learning](../../01-Defender-for-Cloud-Deployment-Mastery/learning-resources.md)

## 🔧 Need Help?

**Issues with any step?** Check [Module 00.04 Troubleshooting & Resources](../00.04-Troubleshooting-%26-Resources/README.md) for solutions.

---

## 🤖 AI-Assisted Content Generation

This streamlined Week 00 to Week 1 Bridge validation guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, focusing on creating a concise, user-friendly environment readiness check that eliminates complexity while ensuring all critical Azure deployment prerequisites are validated.

*AI tools were used to enhance productivity and ensure comprehensive coverage of essential validation scenarios while maintaining technical accuracy and reflecting current Azure development standards and security deployment best practices for educational progression.*
