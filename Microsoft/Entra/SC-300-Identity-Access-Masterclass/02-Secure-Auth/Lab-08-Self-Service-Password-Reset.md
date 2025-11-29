# Lab 08: Self-Service Password Reset (SSPR)

**Skill:** Manage self-service password reset
**Estimated Time:** 30 Minutes

---

## 📋 Lab Overview

**Scenario:** To reduce Helpdesk calls, Contoso Corp wants to allow users to reset their own passwords if they forget them. This must be integrated with the MFA registration so users don't have to register twice.

### 🎯 Objectives

- Enable SSPR for a specific group.
- Configure authentication methods for SSPR.
- Enable "Combined Registration" (Converged experience).

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P1** (Required for SSPR Writeback and Group targeting) |
| **Role** | **Global Administrator** or **Authentication Policy Administrator** |

> **💡 Exam Tip:**
> **SSPR Writeback**: If you have Hybrid Identity, you need to enable "Password Writeback" in Entra Connect *and* enable "Write back passwords to your on-premises directory" in the SSPR settings in the portal.

---

## 📝 Lab Steps

### Task 1: Enable SSPR

1. Navigate to **Entra ID** > **Password reset**.
2. **Properties**:
    - **Self service password reset enabled**: Select **Selected**.
    - **Select group**: Choose **Dynamic-Sales-Team**.
    - *Note: In production, you usually select "All", but for staged rollouts, use groups.*
3. Click **Save**.

### Task 2: Configure Authentication Methods (Converged Policy)

> **Note**: Microsoft has migrated SSPR method management to the unified "Authentication Methods" policy. You may see a banner stating "Authentication Methods for SSPR and Signin can now be managed in one converged policy."

1. Click **Authentication methods** (in the SSPR menu).
2. **Number of methods required to reset**: Set to **1** (for easier testing) or **2** (for higher security).
3. **Methods available to users**:
    - If you see a list of checkboxes (Legacy), check **Mobile app notification**, **Mobile app code**, and **Email**.
    - **Modern Experience**: If you only see "Security questions" or a link to the **Authentication methods policy**:
        - This is normal for newer tenants. The methods are now managed centrally.
        - Click the link **"Use the auth methods policy to manage other authentication methods"** (or navigate to **Entra ID** > **Authentication methods** > **Policies**).
        - Verify that **Microsoft Authenticator**, **SMS**, and **Email OTP** are **Enabled** and targeted to **All users** (as configured in Lab 05).
4. Click **Save** (if you made changes in the SSPR blade).

### Task 3: Configure Registration

1. Click **Registration**.
2. **Require users to register when signing in**: **Yes**.
3. **Number of days before users are asked to re-confirm**: **180**.
4. Click **Save**.

### Task 4: Verify Registration & Test SSPR

Before testing the reset, we must ensure Alex has completed the registration process, especially since we enforced it in Task 3.

1. Open a new InPrivate window.
2. Go to `https://aka.ms/mysecurityinfo`.
3. Sign in as **Alex Wilber**.
4. **Registration Prompt**: Because we enabled "Require users to register" in Task 3, you may be interrupted to confirm your security info.
    - Follow the prompts to confirm or add authentication methods (e.g., Email or Phone).
    - *Note*: Even if you registered MFA in Lab 05, SSPR often requires re-confirmation or additional methods depending on your policy.
5. Once you reach the "Security info" page, **Sign out**.
6. Now, go to `https://aka.ms/sspr`.
7. Enter **Alex Wilber's** UserPrincipalName.
8. Complete the CAPTCHA.
9. Follow the prompts to verify your identity.
10. Enter a new password.
11. **Success**: You should be able to sign in with the new password.

---

## 🔍 Troubleshooting

- **"You can't reset your password"**: Ensure the user is in the **Dynamic-Sales-Team** group.
- **"Contact your admin"**: If the user hasn't registered enough authentication methods (e.g., only has Email, but policy requires 2 methods), they cannot use SSPR.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for SC-300 certification preparation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exam objectives while maintaining technical accuracy.*
