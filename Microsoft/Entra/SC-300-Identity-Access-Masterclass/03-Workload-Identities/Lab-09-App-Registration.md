# Lab 09: Application Registration

**Skill:** Implement and manage applications
**Estimated Time:** 45 Minutes

---

## 📋 Lab Overview

**Scenario:** Contoso's development team has built a custom web application called "Contoso HR Portal". They need you to register this application in Entra ID so that users can sign in with their corporate credentials (OIDC) and the app can read user profiles (Graph API).

### 🎯 Objectives

- Register a new application (Single Tenant).
- Configure Redirect URIs.
- Configure API Permissions (Delegated vs Application).
- Create a Client Secret.

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Free** (App registration is a core feature) |
| **Role** | **Application Developer**, **Cloud Application Administrator**, or **Global Administrator** |

> **💡 Exam Tip:**
>
> - **App Registration**: The definition of the app (The "Blueprint"). Lives in the home tenant.
> - **Enterprise Application (Service Principal)**: The instance of the app in a specific tenant. Lives in every tenant that uses the app.
> - **Redirect URI**: Where Entra ID sends the token after authentication. Must match the code exactly.

---

## 📝 Lab Steps

### Task 1: Register the Application

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com).
2. Navigate to **Entra ID** > **App registrations**.
3. Click **+ New registration**.
4. **Name**: `Contoso HR Portal`.
5. **Supported account types**: **Accounts in this organizational directory only (Single tenant)**.
6. **Redirect URI**:
    - Platform: **Web**.
    - URI: `https://jwt.ms` (We use this Microsoft tool to decode and visualize the token for testing).
7. Click **Register**.
8. **Enable Implicit Flow for Testing** - Required for Task 4:
    - In the left menu, click **Authentication**.
    - Scroll down to **Implicit grant and hybrid flows**.
    - Check **ID tokens (used for implicit and hybrid flows)**.
    - *Note*: This is required because our test URL uses `response_type=id_token` to receive the token directly.
    - Click **Save**.

### Task 2: Configure API Permissions

1. In the app menu, click **API permissions**.
2. Notice `User.Read` (Delegated) is added by default.
3. Click **+ Add a permission**.
4. Select **Microsoft Graph**.
5. Select **Delegated permissions**.
6. Search for and check **Directory.Read.All** (Allows the app to read directory data *as the user*).
7. Click **Add permissions**.
8. **Grant Admin Consent**:
    - Notice the status says "Not granted for <Tenant>".
    - Click **Grant admin consent for <Tenant>**.
    - Click **Yes**.
    - *Why?* `Directory.Read.All` requires admin approval; users cannot consent to it themselves.

### Task 3: Create Client Secret

1. Click **Certificates & secrets**.
2. Click **+ New client secret**.
3. **Description**: `WebAppSecret1`.
4. **Expires**: **180 days** (Recommended).
5. Click **Add**.
6. **Important**: Copy the **Value** immediately. You will never see it again.

### Task 4: Test the Registration

1. Construct the URL to simulate a sign-in:
    `https://login.microsoftonline.com/<YOUR_TENANT_ID>/oauth2/v2.0/authorize?client_id=<YOUR_APP_ID>&response_type=id_token&redirect_uri=https://jwt.ms&scope=openid%20profile&nonce=12345`
2. Replace `<YOUR_TENANT_ID>` and `<YOUR_APP_ID>` with values from the **Overview** blade.
3. Paste the URL into a browser.
4. Sign in as **Alex Wilber**.
5. **Success**: You should be redirected to `jwt.ms` and see a decoded token showing Alex's claims (name, email, etc.).

---

## 🔍 Troubleshooting

- **"Reply URL does not match"**: Ensure the Redirect URI in the URL matches exactly what you entered in the portal (`https://jwt.ms`).
- **"Need admin approval"**: If you didn't grant admin consent in Task 2, standard users might be blocked from signing in if the "User consent" settings are restrictive.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for SC-300 certification preparation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exam objectives while maintaining technical accuracy.*
