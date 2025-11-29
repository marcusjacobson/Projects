# Lab 05: Multi-Factor Authentication (MFA) Policies

**Skill:** Implement and manage authentication methods
**Estimated Time:** 45 Minutes

---

## 📋 Lab Overview

**Scenario:** Contoso Corp wants to move away from legacy per-user MFA and enforce modern, secure authentication methods. They want to ensure users can use the Microsoft Authenticator app and FIDO2 security keys, while disabling less secure methods like SMS for administrators.

In this lab, you will configure the **Authentication Methods Policy** in Entra ID.

### 🎯 Objectives

- Migrate from Legacy MFA to the Unified Authentication Methods Policy.
- Enable Microsoft Authenticator with "Number Matching".
- Configure a Temporary Access Pass (TAP) for onboarding.

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P1** (Required for Conditional Access integration) |
| **Role** | **Authentication Policy Administrator** or **Global Administrator** |

> **💡 Exam Tip:**
> The exam focuses heavily on the **migration** from the old "Per-User MFA" portal to the new "Authentication Methods" blade. Know that "Per-User MFA" is legacy. The modern way is **Conditional Access** + **Authentication Methods Policy**.

---

## 📝 Lab Steps

### Task 1: Configure Microsoft Authenticator

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com).
2. Navigate to **Entra ID** > **Authentication methods** > **Policies**.
3. Select **Microsoft Authenticator**.
4. **Enable and Target**:
    - Enable: **Yes**.
    - Target: **All users** (or select a specific group like "Sales").
    - *Note*: Ensure **Authentication mode** is set to **Any** (allows both Passwordless and Push) for the target group.
5. **Configure**:
    - Click the **Configure** tab.
    - **Allow use of Microsoft Authenticator OTP**: **Yes**.
    - **Feature Configuration**:
        - *Note*: For the settings below, you will see three status options: **Microsoft managed** (default), **Enabled**, and **Disabled**. We will explicitly select **Enabled** to force these security features on immediately.
    - **Require number matching for push notifications**:
        - Status: **Enabled**.
        - Target: **All users**.
    - **Show application name in push and passwordless notifications**:
        - Status: **Enabled**.
        - Target: **All users**.
    - **Show geographic location in push and passwordless notifications**:
        - Status: **Enabled**.
        - Target: **All users**.
    - **Microsoft Authenticator on companion applications**:
        - Status: **Enabled**.
        - Target: **All users**.
        - *Note*: This enables approval notifications on wearables (e.g., Apple Watch). We are enabling it for completeness, though it is optional for security.
6. Click **Save**.

### Task 2: Configure Temporary Access Pass (TAP)

TAP is crucial for passwordless onboarding.

1. In the **Policies** list, select **Temporary Access Pass**.
2. **Enable and Target**:
    - Enable: **Yes**.
    - Target: Select **All users**.
3. **Configure**:
    - **Minimum lifetime**: 10 minutes.
    - **Maximum lifetime**: 8 hours.
    - **Default lifetime**: 1 hour.
    - **Require one-time use**: **Yes**.
4. Click **Save**.

### Task 3: Issue a Temporary Access Pass (TAP)

Now that the policy is enabled, let's generate a TAP for a user (e.g., **Bianca Pisani**) so she can register her authentication methods without needing a password.

1. Navigate to **Entra ID** > **Users** > **All users**.
2. Click on **Bianca Pisani**.
3. Select **Authentication methods** from the left menu.
4. Click **+ Add authentication method**.
5. Choose **Temporary Access Pass**.
6. **Configuration**:
    - **Delayed start time**: (Leave blank for immediate).
    - **Duration**: 60 (minutes).
    - **One-time use**: Yes.
7. Click **Add**.
8. **Important**: Copy the **Pass code** shown on the screen. You will not be able to see it again.

> **💡 Admin Note**:
> While the TAP **policy** can be enabled for all users (as done in Task 2), the actual **Pass Code** must be generated on a **per-user basis**. There is no setting to automatically generate a TAP for every new user by default.
>
> *Enterprise Scenario*: For bulk onboarding, admins typically use **PowerShell** or **Microsoft Graph API** scripts to generate TAPs automatically when new user accounts are provisioned.

### Task 4: User Experience (Registering MFA with TAP)

1. Open a new InPrivate window.
2. Go to `https://aka.ms/mysecurityinfo`.
3. Sign in as **Bianca Pisani** (`bianca.pisani@...`).
4. When asked for a password, use the **Temporary Access Pass** you generated in the previous step.
5. You will be prompted to register a security info method immediately.
6. Choose **Authenticator app** and follow the prompts to scan the QR code with your phone.
7. **Crucial Step - Set a Password**:
    - Since the TAP was configured for **one-time use**, you cannot use it again. You need to set a permanent password for future access.
    - Navigate to `https://aka.ms/sspr` (Self-Service Password Reset).
    - Follow the prompts to create a new password.
    - *Note*: This works because you are already signed in and have just registered your MFA method, satisfying the SSPR requirements.

---

## 🔍 Troubleshooting

- **"Methods not available"?**: It can take up to 15 minutes for policy changes to propagate.
- **Legacy MFA conflict**: If a user has "Per-User MFA" enabled (Enforced), it might override some modern settings. Ensure Per-User MFA is **Disabled** for users targeted by Conditional Access.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for SC-300 certification preparation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exam objectives while maintaining technical accuracy.*
