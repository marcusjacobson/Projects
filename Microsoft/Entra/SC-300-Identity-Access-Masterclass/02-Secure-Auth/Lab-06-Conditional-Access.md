# Lab 06: Conditional Access Policies

**Skill:** Plan and implement Conditional Access policies
**Estimated Time:** 60 Minutes

---

## 📋 Lab Overview

**Scenario:** Contoso Corp has a strict security requirement:

1. **Admins** must *always* use MFA.
2. **Sales** users must use MFA *only* when outside the corporate office.
3. **Legacy Authentication** (POP3/IMAP) must be blocked for everyone.

In this lab, you will build these three foundational Conditional Access policies.

### 🎯 Objectives

- Create a "Require MFA for Admins" policy.
- Create a "Block Legacy Authentication" policy.
- Create a "Location-Based MFA" policy using Named Locations.

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P1** (Required for Conditional Access) |
| **Role** | **Conditional Access Administrator** or **Global Administrator** |

> **💡 Exam Tip:**
> Conditional Access signals include: **User/Group**, **Application**, **Device Platform**, **Location**, and **Risk** (P2 only).
> The decision is: **Block**, **Grant** (with controls like MFA), or **Session Control**.
> **Report-Only Mode** is critical for testing policies without locking yourself out.

---

## 📝 Lab Steps

### Task 1: Define a Named Location

1. Navigate to **ID Governance** > **Conditional Access** > **Named locations**.
2. Click **+ IP ranges location**.
3. **Name**: `Corporate Head Office`.
4. **Mark as trusted location**: Check this box.
5. **IP ranges**: Enter a dummy IP range (e.g., `1.2.3.4/32` or your actual public IP if you know it).
6. Click **Create**.

### Task 2: Policy 1 - Require MFA for Admins

1. Navigate to **Policies**.
2. Click **+ New policy**.
3. **Name**: `CA001-Require MFA for Admins`.
4. **Assignments**:
    - **Users**: Select **Directory roles**. Choose **Global Administrator**, **User Administrator**, **Security Administrator**.
    - **Resources**: **All resources (formerly 'All cloud apps')**.
5. **Access controls** > **Grant**:
    - Select **Grant access**.
    - Check **Require multifactor authentication**.
6. **Enable policy**: Set to **Report-only** (Safety first!).
7. Click **Create**.

### Task 3: Policy 2 - Block Legacy Auth

1. Click **+ New policy**.
2. **Name**: `CA002-Block Legacy Auth`.
3. **Assignments**:
    - **Users**: **All users**.
        - *Important*: **Exclude** your current admin account (Break-glass account).
    - **Resources**: **All resources (formerly 'All cloud apps')**.
    - **Conditions** > **Client apps**:
        - Configure: **Yes**.
        - Uncheck "Browser" and "Mobile apps and desktop clients".
        - Check **Exchange ActiveSync clients** and **Other clients**.
4. **Access controls** > **Grant**:
    - Select **Block access**.
5. **Enable policy**: **Report-only**.
6. Click **Create**.

### Task 4: Policy 3 - Location Based MFA for Sales

1. Click **+ New policy**.
2. **Name**: `CA003-Sales MFA External`.
3. **Assignments**:
    - **Users**: Select Users and groups > **Dynamic-Sales-Team** (Dynamic Group from Lab 02).
    - **Resources**: **All resources (formerly 'All cloud apps')**.
    - **Conditions** > **Locations**:
        - Configure: **Yes**.
        - Include: **Any location**.
        - Exclude: **Selected locations** > `Corporate Head Office`.
4. **Access controls** > **Grant**:
    - **Require multifactor authentication**.
5. **Enable policy**: **Report-only**.
6. Click **Create**.

### Create Policy from Template (Overview)

Microsoft provides pre-configured templates for common security scenarios. This is a quick way to deploy best-practice policies without configuring every setting manually.

1. Navigate to **Conditional Access** > **Policies**.
2. Click **+ New policy from template**.
3. Browse the categories:
    - **Identities**: e.g., "Require MFA for all users", "Block legacy authentication".
    - **Devices**: e.g., "Require compliant device".
4. **Exam Concept**: Templates are categorized by **Identity**, **Devices**, and **Zero Trust**. They allow you to view the policy settings (JSON) before creating them. When you create a policy from a template, it defaults to **Report-only** mode for safety.

---

## 🔍 Troubleshooting

- **Locked out?**: If you accidentally block yourself, use the "Break-glass" account you excluded in Task 3.
- **Policy not applying?**: Check the **What If** tool.
  - Click **Conditional Access** > **What If**.
  - Select a user (Alex Wilber).
  - Select an app.
  - Click **What If**. It will show you which policies would apply.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for SC-300 certification preparation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exam objectives while maintaining technical accuracy.*
