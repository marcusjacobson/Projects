# Lab 11: App Governance & Consent

**Skill:** Implement and manage application access
**Estimated Time:** 30 Minutes

---

## 📋 Lab Overview

**Scenario:** Users are blindly consenting to third-party apps that ask for "Read your email" permissions. This is a security risk. Contoso wants to restrict user consent but allow users to *request* admin approval for apps they need.

### 🎯 Objectives

- Configure User Consent Settings (Disable/Restrict).
- Configure the Admin Consent Workflow.
- Review App Consent Requests.

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Free** (Basic consent settings) / **P1** (Advanced) |
| **Role** | **Global Administrator** or **Privileged Role Administrator** |

> **💡 Exam Tip:**
> **Risk-Based Step-Up Consent**: You can allow users to consent to low-risk apps, but require admin approval if the app is "Risky" (verified publisher missing, etc.).
> **Verified Publisher**: A gold badge for apps. You can set policies to only allow consent for Verified Publishers.

---

## 📝 Lab Steps

### Task 1: Restrict User Consent

1. Navigate to **Entra ID** > **Enterprise applications**.
2. Click **Security** > **Consent and permission**.
3. **User consent for applications**:
    - Select **Allow user consent for apps from verified publishers, for selected permissions (Recommended)**.
    - *Alternatively*: Select **Do not allow user consent** for maximum security.
4. If you chose "Recommended":
    - Click **Select permissions to classify as low impact**.
    - Select `User.Read`, `offline_access`, `openid`, `profile`.
    - Click **Yes, add selected permissions**.
5. Click **Save**.

### Task 2: Configure Admin Consent Workflow

1. Click **Admin consent settings**.
2. **Users can request admin consent to apps they are unable to consent to**: **Yes**.
3. **Select users to review admin consent requests**: Select **Global Administrator** (or your specific admin user).
4. **Selected users will receive email notifications**: **Yes**.
5. Click **Save**.

### Task 3: Simulate a Request

1. Open a new InPrivate window.
2. Navigate to **Graph Explorer**: `https://developer.microsoft.com/en-us/graph/graph-explorer`.
    - *Note*: Graph Explorer is a public tool, so it will load without credentials initially. You must sign in to the tool itself to test tenant permissions.
3. Click the **Profile/Sign In** icon in the top-right corner of the webpage (not the browser profile).
4. Sign in as **Alex Wilber**.
5. You should now see the **"Approval required"** screen.
6. Enter a justification: "Need access to view groups for HR project".
7. Click **Request approval**.

### Task 4: Approve the Request

1. Switch back to your Admin window.
2. Navigate to **Enterprise applications** > **Admin consent requests**.
3. You should see the request from Alex.
4. Click on the request.
5. Click **Review permissions and consent**.
6. Review what the app is asking for.
7. Click **Accept**.

---

## 🔍 Troubleshooting

- **No email received?**: Ensure the admin user has a valid Exchange mailbox (requires license) to receive the email notification. However, the request will always appear in the portal regardless of email.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, ensuring alignment with the SC-300 exam objectives and Microsoft Entra best practices.

*AI tools were used to enhance productivity and ensure comprehensive coverage of application governance topics while maintaining technical accuracy and reflecting current Azure portal interfaces.*
