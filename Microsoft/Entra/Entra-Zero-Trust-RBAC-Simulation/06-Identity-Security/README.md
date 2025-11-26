# Lab 06: Identity Security & Protection

This lab implements the "Verify Explicitly" pillar of Zero Trust. We will deploy Conditional Access policies to enforce MFA, block legacy authentication, and respond to risk events in real-time.

## 🎯 Lab Objectives

- **Conditional Access**: Deploy baseline policies (MFA for Admins, Block Legacy Auth) in "Report-Only" mode.
- **Identity Protection**: Configure automated responses to "User Risk" and "Sign-in Risk".
- **Authentication Methods**: Enable modern, phishing-resistant credentials (FIDO2, Microsoft Authenticator).
- **Safety Nets**: Ensure "Break Glass" accounts are excluded from all restrictive policies.

## 📚 Microsoft Learn & GUI Reference

- **Conditional Access**: [Building a Conditional Access policy](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policies)
- **Identity Protection**: [What is Identity Protection?](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)
- **Authentication Methods**: [Manage authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods)

> **💡 GUI Path**: `entra.microsoft.com` > **Protection** > **Conditional Access** | **Identity Protection**

## 📋 Prerequisites

- Completion of **Lab 01** (Break Glass accounts must exist).
- **Entra ID P2 License** (Required for Identity Protection).

## ⏱️ Estimated Duration

- **20 Minutes**

## 📝 Lab Steps

### Step 1: Configure Parameters File

Before deploying resources, you must configure the environment parameters.

**Context**: This project uses a centralized JSON configuration file to manage deployment settings. This ensures consistency across all scripts.

1. Navigate to the `infra` directory.
2. Open `module.parameters.json`.
3. Review the default settings.
4. Save the file.

### Step 2: Deploy Conditional Access Policies

We will create standard protection policies but keep them in "Report-Only" mode to prevent accidental lockouts.

**Context**: "Report-Only" allows us to see the impact of a policy (who would have been blocked?) without actually blocking anyone. This is a critical deployment best practice. We also explicitly exclude our Break Glass accounts (`ADM-BG-01`) to ensure we always have a way back in.

1. Open a PowerShell terminal.
2. Navigate to the `scripts` directory.
3. Run the following command:

   ```powershell
   .\Deploy-CAPolicies.ps1 -UseParametersFile
   ```

4. This creates:
    - `CA001: Require MFA for Admins` (Report-Only)
    - `CA002: Block Legacy Authentication` (Report-Only)
    - `CA003: Require MFA for All Users` (Report-Only)

### Step 3: Configure Identity Protection

We will automate the response to compromised accounts.

**Context**:

- **User Risk**: Indicates the user's credentials might be leaked (e.g., found on the dark web). Response: Force Password Change.
- **Sign-in Risk**: Indicates a specific login attempt is suspicious (e.g., Impossible Travel). Response: Require MFA.

1. Run the following command:

   ```powershell
   .\Configure-IdentityProtection.ps1 -UseParametersFile
   ```

2. Sets the User Risk policy to "High" -> "Block Access" (or "Require Password Change").
3. Sets the Sign-in Risk policy to "Medium and above" -> "Require MFA".

### Step 4: Configure Authentication Methods

We will enable stronger authentication methods to replace SMS and Voice.

**Context**: SMS and Voice MFA are vulnerable to SIM swapping and interception. We enable **Microsoft Authenticator** (Number Matching) and **FIDO2 Security Keys** (Phishing Resistant) to provide the highest level of security.

1. Run the following command:

   ```powershell
   .\Configure-AuthMethods.ps1 -UseParametersFile
   ```

2. Enables FIDO2 Security Keys for all users.
3. Enables Microsoft Authenticator for all users.
4. Disables SMS/Voice (optional, usually done in a phased approach).

## ✅ Validation

- **Conditional Access**: Go to **Protection** > **Conditional Access** and verify the policies exist and are in "Report-Only" state. Check the "Users" assignment to confirm `ADM-BG-01` is excluded.
- **Identity Protection**: Go to **Protection** > **Identity Protection** > **Risk policies** to verify the configuration.
- **Auth Methods**: Go to **Protection** > **Authentication methods** > **Policies** to see FIDO2 and Authenticator enabled.

## 🚧 Troubleshooting

- **"Policy creation failed"**: Ensure you have the `Policy.ReadWrite.ConditionalAccess` permission (handled by `Connect-EntraGraph.ps1`).
- **"Risk Policy not updated"**: Requires P2 license.

## 🎓 Learning Objectives Achieved

- **Safe Deployment**: You learned how to deploy powerful blocks without risking a "Resume Generating Event" (locking everyone out).
- **Automated Defense**: You configured the system to defend itself against compromised credentials without human intervention.

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
