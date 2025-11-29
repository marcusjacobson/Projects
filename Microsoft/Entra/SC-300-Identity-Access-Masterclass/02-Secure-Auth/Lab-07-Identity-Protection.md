# Lab 07: Identity Protection (Risk-Based Policies)

**Skill:** Manage user risk and sign-in risk
**Estimated Time:** 45 Minutes

---

## 📋 Lab Overview

**Scenario:** Contoso Corp wants to automate responses to compromised accounts.

1. If a user is flagged as **High Risk** (e.g., leaked credentials), they should be forced to change their password securely.
2. If a sign-in looks suspicious (e.g., **Unfamiliar Location**), they should be forced to perform MFA.

In this lab, you will configure **Identity Protection** policies.

### 🎯 Objectives

- Configure the **User Risk Policy**.
- Configure the **Sign-in Risk Policy**.
- Simulate a risky sign-in (using Tor Browser or VPN).

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P2** (Required for Risk-Based CA) |
| **Role** | **Security Administrator** or **Global Administrator** |

> **💡 Exam Tip:**
>
> - **User Risk**: Probability that the *identity* is compromised (e.g., Leaked Credentials). Remediation: **Password Change**.
> - **Sign-in Risk**: Probability that the *authentication request* is not the owner (e.g., Anonymous IP, Unfamiliar Location). Remediation: **MFA**.

---

## 📝 Lab Steps

### Task 1: Configure User Risk Policy (Modern CA Approach)

*Note: The legacy "User risk policy" blade is now read-only. We must use Conditional Access.*

1. Navigate to **Entra ID** > **Conditional Access** > **Policies**.
2. Click **+ New policy**.
3. **Name**: `CA004-Remediate High User Risk`.
4. **Assignments**:
    - **Users**: **All users** (Exclude your admin).
    - **Resources**: **All resources (formerly 'All cloud apps')**..
    - **Conditions** > **User risk**:
        - Configure: **Yes**.
        - Select **High**.
5. **Access controls** > **Grant**:
    - Select **Grant access**.
    - Check **Require password change**.
6. **Enable policy**: **Report-only**.
7. Click **Create**.

### Task 2: Configure Sign-in Risk Policy (Modern CA Approach)

1. Click **+ New policy**.
2. **Name**: `CA005-Remediate Medium+ Sign-in Risk`.
3. **Assignments**:
    - **Users**: **All users** (Exclude your admin).
    - **Resources**: **All resources (formerly 'All cloud apps')**.
    - **Conditions** > **Sign-in risk**:
        - Configure: **Yes**.
        - Select **High** and **Medium**.
4. **Access controls** > **Grant**:
    - Select **Grant access**.
    - Check **Require multifactor authentication**.
5. **Enable policy**: **Report-only**.
6. Click **Create**.

### Task 3: Simulate Risk (Optional)

*Note: Risk detection is not instant. It can take 5-10 minutes for offline risk and real-time for sign-in risk.*

1. **Tor Browser Method**:
    - Download and open the **Tor Browser**.
    - Navigate to `https://myapps.microsoft.com`.
    - Sign in as **Alex Wilber**.
    - **Expected Result**: Because Tor uses anonymous IPs, this should trigger a **Medium/High Sign-in Risk**.
    - The policy should block access or demand MFA immediately.

### Task 4: Review Risky Users

1. Navigate to **ID Protection** > **Risky users**.
2. If the simulation worked, you should see Alex Wilber listed.
3. Click on the user to see details:
    - **Risk level**: High/Medium.
    - **Risk detail**: Anonymous IP address.
4. **Remediation**: Click **Dismiss user risk** (if it was a false positive) or **Reset password**.

---

## 🔍 Troubleshooting

- **Risk not triggering?**: Identity Protection relies on machine learning. In a brand new tenant with no history, "Unfamiliar Location" might not trigger immediately because *every* location is unfamiliar. "Anonymous IP" (Tor) is the most reliable test.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for SC-300 certification preparation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exam objectives while maintaining technical accuracy.*
