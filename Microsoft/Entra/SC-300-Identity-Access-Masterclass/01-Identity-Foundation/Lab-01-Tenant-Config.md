# Lab 01: Tenant Configuration

**Skill:** Configure and manage a Microsoft Entra tenant
**Estimated Time:** 30 Minutes

---

## 📋 Lab Overview

**Scenario:** Contoso Corp wants to ensure their sign-in experience reflects their brand identity and that users can sign in with a corporate domain name instead of the default `.onmicrosoft.com` address.

In this lab, you will configure the fundamental settings of your Entra ID tenant, including company branding and custom domain names.

### 🎯 Objectives

- Configure Company Branding for the sign-in page.
- Add and verify a Custom Domain name (Simulation).
- Configure Tenant Properties (Restrict access to admin portal).

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P1** (Required for Company Branding) |
| **Role** | **Global Administrator** or **Organizational Branding Administrator** |

> **💡 Exam Tip:**
> Company Branding requires at least a **Premium P1** license. It is NOT available in the Free tier. Also, remember that branding can be applied to specific languages (locale-based branding).

---

## 📝 Lab Steps

### Task 1: Configure Company Branding

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com).
2. Navigate to **Entra ID** > **Custom branding**.
3. Click **Edit** on the "Default sign-in" experience.
4. **Basics Tab**:
   - **Favicon**: Upload a small image (e.g., a logo icon).
   - **Background image**: Upload a large image (1920x1080).
   - **Page background color**: Select a hex color (e.g., `#0078D4`).
5. **Layout Tab**:
   - **Header**: Upload a header logo.
   - **Footer**: Add a footer link (e.g., "Privacy Policy") and URL.
6. **Sign-in form Tab**:
   - **Banner logo**: Upload your company logo.
   - **Square logo**: Upload a square version.
   - **Username hint**: Enter "Sign in with your Contoso ID".
7. Click **Review + create** > **Create**.
8. **Verification**: Open an InPrivate/Incognito window and browse to `https://portal.azure.com`. Enter your admin email. You should see your new branding.

### Task 2: Add a Custom Domain (Simulation)

*Note: If you do not own a domain name, you can perform the steps up to verification.*

1. Navigate to **Entra ID** > **Domain names**.
2. Click **+ Add custom domain**.
3. Enter a domain name (e.g., `contoso-lab.com`) and click **Add domain**.
4. Review the **TXT** record information provided.
   - **Host**: `@`.
   - **TXT Value**: `MS=ms12345678`.
   - **TTL**: `3600`.
5. **Exam Concept**: To verify the domain, you would add this TXT record to your DNS registrar (GoDaddy, Namecheap, etc.). Once verified, you can make it the **Primary** domain.
6. For this lab, you can delete the unverified domain after reviewing the process.

### Task 3: Configure Tenant Properties

**Objective:** Update the tenant name and restrict non-admin access.

1. **Rename Tenant (via Azure Portal)**:
   *Note: The "Properties" blade is sometimes difficult to locate in the new Entra Admin Center layout, so we will use the Azure Portal for this specific task.*
   - Navigate to the [Azure Portal](https://portal.azure.com).
   - Search for and select **Microsoft Entra ID**.
   - In the left menu, under **Manage**, select **Properties**.
   - **Name**: Update the tenant name to something recognizable (e.g., "Contoso Labs").
   - **Technical Contact**: Ensure your email is listed.
   - Click **Save**.

2. **Restrict Admin Portal Access (via Entra Admin Center)**:
   - Return to the [Microsoft Entra admin center](https://entra.microsoft.com).
   - Navigate to **Identity** > **Users** > **User settings**.
   - **Administration portal**:
     - **Restrict access to Microsoft Entra administration portal**: Set to **Yes**.
     - *Why?* This prevents non-admins from accessing the Entra admin center to browse user/group data.
   - Click **Save**.

---

## 🔍 Troubleshooting

- **Branding not showing?**: Ensure you are signing in with an account *in* that tenant. B2B guests might see their home tenant branding depending on the flow.
- **"Restrict access" not working?**: This setting restricts the *portal* view. It does not block PowerShell or API access. To block that, you need Conditional Access (covered in Lab 06).

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for SC-300 certification preparation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exam objectives while maintaining technical accuracy.*
