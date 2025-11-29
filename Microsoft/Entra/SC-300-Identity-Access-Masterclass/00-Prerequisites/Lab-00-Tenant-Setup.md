# Lab 00: Tenant Setup & Prerequisites

**Skill:** Configure and manage a Microsoft Entra tenant
**Estimated Time:** 30 Minutes

---

## 📋 Lab Overview

In this lab, you will prepare your environment for the SC-300 Masterclass. You can use a **Free Tier** tenant for the basics and activate a **P2 Trial** for advanced features, or use a Microsoft 365 Developer Tenant if available.

### 🎯 Objectives

- Provision a Microsoft Entra ID tenant (Free or Developer).
- Activate a Microsoft Entra ID P2 trial (if needed).
- Verify Global Administrator access.

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P2** (Required for PIM, Identity Protection) |
| **Role** | **Global Administrator** |

> **💡 Exam Tip:**
> The SC-300 exam frequently asks which license is required for specific features. Remember:
>
> - **Free**: Basic user management, SSO (up to 10 apps).
> - **P1**: Conditional Access, Dynamic Groups, Self-Service Password Reset (SSPR).
> - **P2**: Privileged Identity Management (PIM), Identity Protection, Entitlement Management, Access Reviews.

---

## 📝 Lab Steps

### Task 1: Provision a Tenant

You have two primary options for setting up your lab environment:

**Option A: Free Tenant + P2 Trial (Recommended)**
This is the most accessible method if you cannot obtain a Developer Subscription.

1. Create a free Azure account or use an existing Microsoft account to sign up for a [Free Microsoft Entra ID tenant](https://entra.microsoft.com).
2. You can perform the foundational labs (01-04) with the Free tier.
3. For advanced labs (05+), you will activate a P2 trial in Task 2.

**Option B: Microsoft 365 Developer Program**
If you can access it, this provides a renewable E5 license.

1. Navigate to the [Microsoft 365 Developer Program](https://developer.microsoft.com/en-us/microsoft-365/dev-program).
2. Click **Join Now** and sign in with a personal Microsoft Account (MSA).
3. Follow the wizard to set up your E5 Developer Subscription.
    - **Region**: Choose a region close to you.
    - **Domain**: Create a unique domain (e.g., `contoso-labs-yourname.onmicrosoft.com`).
    - **Admin User**: Create your primary Global Admin account.

### Task 2: Verify or Activate P2 Licensing

Advanced labs (PIM, Identity Protection, etc.) require a **Microsoft Entra ID P2** license.

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com) as your Global Admin.
2. Navigate to **Identity** > **Overview**.
3. Check the **License** field in the "Basic information" card.
    - **Developer Tenant**: Should say **Microsoft Entra ID P2**.
    - **Free Tenant**: Will say **Microsoft Entra ID Free**.
4. **To Activate a P2 Trial** (Required for Free tenants):
    - Navigate to **Billing** > **Licenses** > **All products**.
    - Click **Try/Buy**.
    - Find **Microsoft Entra ID P2** and click **Free trial** (usually 30 days).
    - Follow the prompts to activate.

### Task 3: Prepare PowerShell Environment

Some labs require PowerShell. Let's prepare your local machine.

1. Open PowerShell as Administrator.
2. Install the Microsoft Graph module:

    ```powershell
    Install-Module Microsoft.Graph -Scope CurrentUser
    ```

3. Verify installation:

    ```powershell
    Get-InstalledModule Microsoft.Graph
    ```

---

## 🔍 Troubleshooting

**"I can't join the Developer Program"**: Microsoft sometimes pauses new sign-ups. If so, you can use a standard 30-day trial of "Microsoft 365 E5" from the [Microsoft 365 Product Page](https://www.microsoft.com/en-us/microsoft-365/enterprise/office-365-e5).

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for SC-300 certification preparation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exam objectives while maintaining technical accuracy.*
