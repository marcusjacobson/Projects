# Test User Setup Guide (Optional)

> **📝 Note**: This guide is only needed if you don't already have test users with M365 E5/E5 Compliance licenses assigned. If you already have licensed users, skip this and simply add their UPNs to `templates/global-config.json`.

## 🎯 Purpose

This guide walks through creating test users in Microsoft Entra ID and assigning the necessary licenses for multi-workload Purview testing (OneDrive, Teams, Exchange).

## 📋 Prerequisites

- **Global Administrator** or **User Administrator** role
- **Available M365 E5 or E5 Compliance licenses** (minimum 3 recommended)
- Access to [Microsoft Entra admin center](https://entra.microsoft.com)

---

## 👥 Recommended Test User Structure

For comprehensive DLP testing across departments, create **3 test users**:

| User | Department | Purpose |
|------|-----------|---------|
| `finance1@yourtenant.onmicrosoft.com` | Finance | Test PCI-DSS policies with credit card data |
| `sales1@yourtenant.onmicrosoft.com` | Sales | Test loyalty program and customer data policies |
| `compliance1@yourtenant.onmicrosoft.com` | Compliance | Test cross-department data access scenarios |

---

## 🧪 Step-by-Step User Creation

### Step 1: Access Entra Admin Center

Navigate to the Microsoft Entra admin center and sign in with your administrator account.

- Go to [entra.microsoft.com](https://entra.microsoft.com)
- Sign in with Global Administrator or User Administrator credentials

### Step 2: Create Users

Create each test user using the modern Entra interface.

- In the left navigation, expand **Identity** and select **Users** → **All users**
- Click **+ New user** → **Create new user**

**For each user, configure the following:**

**Basics Tab:**

| Field | Value | Example |
|-------|-------|---------|
| **User principal name** | Descriptive identifier | `finance1` |
| **Domain** | Your tenant domain | `@marcusj-dev.cloud` |
| **Display name** | Friendly name | `Finance User 1` |
| **Password** | Auto-generate or custom | *Auto-generate and show password* |
| **Account enabled** | Checked | ✅ |

**Properties Tab:**

| Field | Value |
|-------|-------|
| **First name** | `Finance` |
| **Last name** | `User 1` |
| **Job title** | `Financial Analyst` |
| **Department** | `Finance` |
| **Usage location** | `United States` (or your region) |

**Assignments Tab:**

Skip for now - we'll assign licenses in the next step.

**Review + Create:**

- Review the settings
- Click **Create**
- **Important**: Copy the auto-generated password (you'll need it for initial sign-in)

Repeat this process for the other users:

- **sales1@yourtenant.onmicrosoft.com** (Department: Sales, Job title: Sales Representative)
- **compliance1@yourtenant.onmicrosoft.com** (Department: Compliance, Job title: Compliance Officer)

### Step 3: Assign M365 E5 Licenses

Assign licenses to enable OneDrive, Teams, and Exchange capabilities.

- In **Users** → **All users**, click on the user you just created
- In the left menu, select **Licenses**
- Click **+ Assignments**

**Select the appropriate license:**

- **Microsoft 365 E5** (preferred - includes all features)
- **Microsoft 365 E5 Compliance** (alternative - includes DLP/classification features)

**Verify service plans are enabled:**

Ensure these services are enabled (checked):

- **Exchange Online (Plan 2)** - Required for email DLP testing
- **OneDrive for Business (Plan 2)** - Required for OneDrive file testing
- **Microsoft Teams** - Required for Teams channel testing
- **SharePoint Online (Plan 2)** - Required for site access
- **Microsoft Purview** - Required for classification and labeling

Click **Save** to assign the license.

Repeat for all test users.

> **⏱️ License Propagation**: It may take 5-15 minutes for licenses to fully provision. Wait until all services show as "Active" before proceeding.

### Step 4: Verify License Assignment

Confirm all users have active licenses.

- Return to **Users** → **All users**
- For each test user, verify the **Licenses** column shows the assigned license
- Click on each user and check **Licenses** to ensure all required service plans are enabled

**Quick verification checklist:**

- [ ] All 3 users created with descriptive UPNs
- [ ] Department field populated for each user
- [ ] M365 E5/E5 Compliance license assigned to each user
- [ ] Exchange Online, OneDrive, Teams services enabled
- [ ] Passwords saved securely (for initial sign-in if needed)

---

## 🔐 Optional: Initial User Sign-In

**Recommended but not required**: Have each test user sign in once to initialize their profile.

This ensures OneDrive and Exchange are fully provisioned before running the automation scripts.

- Navigate to [office.com](https://office.com)
- Sign in with each test user's UPN and auto-generated password
- Follow the password change prompt if required
- Verify access to:
  - **OneDrive** (click OneDrive icon in the app launcher)
  - **Teams** (click Teams icon in the app launcher)
  - **Outlook** (click Outlook icon in the app launcher)

> **💡 Why?**: Initial sign-in triggers full mailbox and OneDrive provisioning. While not strictly required (Graph API calls will trigger provisioning), it speeds up the process and helps troubleshoot any licensing issues before running automation.

---

## 📝 Update global-config.json

After creating users, update the configuration file with their UPNs.

**File location**: `templates/global-config.json`

**Add the testUsers section:**

```json
{
  "testUsers": [
    {
      "userPrincipalName": "finance1@yourtenant.onmicrosoft.com",
      "displayName": "Finance User 1",
      "department": "Finance"
    },
    {
      "userPrincipalName": "sales1@yourtenant.onmicrosoft.com",
      "displayName": "Sales User 1",
      "department": "Sales"
    },
    {
      "userPrincipalName": "compliance1@yourtenant.onmicrosoft.com",
      "displayName": "Compliance User 1",
      "department": "Compliance"
    }
  ],
  "_testUsers_comment": "Test users must already exist in Entra ID with M365 E5/E5 Compliance licenses assigned."
}
```

**Replace the example UPNs with your actual tenant domain.**

---

## ✅ Validation

Before proceeding to the data foundation labs, verify users are ready.

**Run the validation script** (to be created in the next lab update):

```powershell
cd 02-Data-Foundation\scripts
.\Test-M365Users.ps1
```

**Expected output:**

```text
🔍 Validating Test Users from Configuration
============================================

✅ finance1@yourtenant.onmicrosoft.com
   📧 Licensed: Microsoft 365 E5
   📁 OneDrive: Provisioned
   👥 Teams: Enabled

✅ sales1@yourtenant.onmicrosoft.com
   📧 Licensed: Microsoft 365 E5
   📁 OneDrive: Provisioned
   👥 Teams: Enabled

✅ compliance1@yourtenant.onmicrosoft.com
   📧 Licensed: Microsoft 365 E5
   📁 OneDrive: Provisioned
   👥 Teams: Enabled

📊 Summary: 3 of 3 users ready for multi-workload testing
```

---

## 🔍 Troubleshooting

### "License assignment failed" Error

**Cause**: No available licenses in the tenant.

**Solution**:

- Go to **Billing** → **Licenses** in Microsoft 365 admin center
- Verify you have available M365 E5 or E5 Compliance licenses
- If needed, purchase additional licenses or remove licenses from unused accounts

### "OneDrive not provisioned" Warning

**Cause**: User hasn't signed in yet or OneDrive is still initializing.

**Solution**:

- Wait 10-15 minutes after license assignment
- Have the user sign in to [office.com](https://office.com) and click the OneDrive icon
- OneDrive provisioning can take up to 24 hours in some cases
- Scripts will work even if OneDrive shows as "not provisioned" - Graph API will trigger provisioning

### "User already exists" Error

**Cause**: UPN is already in use.

**Solution**:

- Use a different UPN (e.g., `finance2@` instead of `finance1@`)
- Or update `global-config.json` to use the existing user if it meets the requirements

---

## 📚 What's Next?

After creating and licensing test users:

1. **Proceed to 02-Data-Foundation** to generate test files and upload to SharePoint
2. **Run the user validation script** to confirm OneDrive and Teams are ready
3. **Upload test files to OneDrive** for each user (new script to be created)
4. **Create Teams environment** and upload test files to channels (new script to be created)

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for Microsoft Entra ID user management and M365 license assignment.

*AI tools were used to enhance productivity and ensure comprehensive coverage of user setup requirements while maintaining technical accuracy.*
