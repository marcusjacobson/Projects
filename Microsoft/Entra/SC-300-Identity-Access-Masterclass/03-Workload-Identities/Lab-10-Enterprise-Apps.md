# Lab 10: Enterprise Applications & SSO

**Skill:** Implement and manage applications
**Estimated Time:** 45 Minutes

---

## 📋 Lab Overview

**Scenario:** Contoso uses "Salesforce" (or a similar SaaS app). You need to integrate it with Entra ID so users can use Single Sign-On (SSO) and you can manage access centrally.

In this lab, we will use a **Non-Gallery Application** simulation to demonstrate SAML SSO configuration.

### 🎯 Objectives

- Add an Enterprise Application from the Gallery (or Non-Gallery).
- Assign users and groups to the application.
- Configure Self-Service Application Access.

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P1** (Required for Self-Service Access with Groups) |
| **Role** | **Cloud Application Administrator** or **Global Administrator** |

> **💡 Exam Tip:**
> **User Assignment**: By default, "Assignment required?" is set to **Yes**. This means only users explicitly assigned can sign in. If set to **No**, *any* user in the tenant can sign in (useful for broad apps, but less secure).

---

## 📝 Lab Steps

### Task 1: Add an Enterprise App

1. Navigate to **Entra ID** > **Enterprise applications**.
2. Click **+ New application**.
3. Click **Create your own application**.
4. **Name**: `Contoso SAML App`.
5. **Option**: **Integrate any other application you don't find in the gallery (Non-gallery)**.
6. Click **Create**.

### Task 2: Assign Users

1. In the app menu, click **Users and groups**.
2. Click **+ Add user/group**.
3. Click **None Selected** under Users.
4. Select **Dynamic-Sales-Team**.
5. Click **Select** > **Assign**.
6. *Result*: Now, only members of the Sales team can access this app.

### Task 3: Configure Single Sign-On (Required for Self-Service)

*Note: Self-Service Application Access requires Single Sign-On to be configured first.*

1. In the app menu, click **Single sign-on**.
2. Select **SAML**.
3. Click **Edit** (pencil icon) for **Basic SAML Configuration**.
4. **Identifier (Entity ID)**: Enter `https://contoso.com/samlapp`.
5. **Reply URL (Assertion Consumer Service URL)**: Enter `https://jwt.ms`.
6. Click **Save**.
7. Close the configuration pane (X).

### Task 4: Configure Self-Service Access

**Important**: Self-service access requires a group where users can be *added* upon approval. You cannot use Dynamic Groups for this purpose because their membership is rule-based.

1. **Create a Group for Self-Service**:
    - Open a new tab and go to **Entra ID** > **Groups**.
    - Click **New group**.
    - **Group type**: Security.
    - **Group name**: `SAML-App-SelfService-Users`.
    - **Membership type**: **Assigned**.
    - Click **Create**.
2. Return to the **Contoso SAML App** tab.
3. In the app menu, click **Self-service**.
4. **Allow users to request access to this application?**: **Yes**.
5. **To which group should assigned users be added?**:
    - Click **Select group**.
    - Search for and select **SAML-App-SelfService-Users**.
    - Click **Select**.
6. **Require approval before granting access to this application?**: **Yes**.
7. **Who is allowed to approve access to this application?**: Select **Bianca Pisani** (Sales Manager).
8. Click **Save**.

### Task 5: User Experience (My Apps)

1. Open a new InPrivate window.
2. Sign in to `https://myapps.microsoft.com` as **Alex Wilber**.
3. You should see the **Contoso SAML App** icon (because Alex is in the Sales team).
4. Sign out and sign in as **David So** (Marketing).
5. You should **NOT** see the app.
6. Click **+ Add apps** (top right).
7. Search for **Contoso SAML App**.
8. Click on the app.
9. A dialog will appear: "Request access to Contoso SAML App".
10. Enter a business justification (e.g., "Need access for marketing campaign").
11. Click **Request approval**.
12. **Result**: The request is sent to the approver (Bianca).

### Task 6: Approve Access Request

**Understanding the Workflow**:
In a standard production environment with Microsoft 365 licenses (Exchange Online), the configured approver (**Bianca Pisani**) would receive an email notification. They would simply click a link in that email to approve or deny the request. This is the primary and recommended workflow for Self-Service Application Access.

**Lab Environment Limitation**:
In this lab environment, users do not have Exchange Online licenses, so email notifications are not delivered. Furthermore, the "Access requests" blade in the Enterprise Apps portal is a legacy feature that is often hidden or unreliable, making it difficult to approve requests without the email link.

**Action: Manual Approval (Fallback)**
Since we cannot use the email workflow and the portal blade is unavailable, we will simulate the approval by manually assigning the user to the application.

1. **Sign in as Admin**:
    - If you are not already signed in, sign in to the [Microsoft Entra admin center](https://entra.microsoft.com) as **Global Administrator**.
2. **Manually Assign User**:
    - Navigate to **Identity** > **Applications** > **Enterprise applications**.
    - Select **Contoso SAML App**.
    - Select **Users and groups** from the left menu.
    - Click **+ Add user/group**.
    - Click **None Selected** under Users.
    - Search for and select **David So**.
    - Click **Select** > **Assign**.
3. **Outcome**:
    - David So is now assigned to the application.
    - *Note*: The original request in the "My Apps" portal may remain in a "Pending" state indefinitely because we bypassed the formal approval object. This is expected behavior in this lab scenario.

**Note on Cancellation**:
Unlike the newer **Entitlement Management** (Access Packages) feature, the legacy Self-Service Application Access workflow does **not** allow users to cancel pending requests once submitted. If a request gets stuck (as it might here), it can be ignored once manual access is granted.

### Task 7: Verify Access (Requester)

1. Sign in to `https://myapps.microsoft.com` as **David So**.
2. You should now see the **Contoso SAML App** tile.
3. Click it to verify you are redirected to `jwt.ms` (the dummy SSO URL we configured).

---

## 🔍 Troubleshooting

- **App not appearing?**: It can take 1-2 minutes for group assignments to refresh in the My Apps portal.
- **"Message: AADSTS50105"**: This error means "The signed in user is not assigned to a role for the application." It confirms that "Assignment Required" is working.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for SC-300 certification preparation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exam objectives while maintaining technical accuracy.*
