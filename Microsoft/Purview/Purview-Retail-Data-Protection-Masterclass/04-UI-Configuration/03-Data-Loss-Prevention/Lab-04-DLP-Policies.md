# Lab 04: Configure DLP Policies

In this lab, you will enhance the baseline DLP policies created in **Day Zero Setup** by adding advanced features like user notifications, override capabilities, and custom Sensitive Information Types.

## 🎯 Objectives

- Edit the pre-created "PCI-DSS Protection (Retail)" policy to add user notifications and override capabilities.
- Replace the placeholder rule in "Loyalty Card Protection (Retail)" with the custom "Retail Loyalty ID" SIT.
- Configure "Block with Override" actions for business justification.
- Enable Policy Tips in Teams and Outlook.

## 📋 Prerequisites

- **Global Administrator** or **Compliance Administrator** role.
- **Sensitivity Labels** created in Lab 02.
- **Custom "Retail Loyalty ID" SIT** created in Lab 01.
- **Baseline DLP Policies** deployed in Day Zero Setup (01-Day-Zero-Setup).

## 📝 Step-by-Step Instructions

### Part 1: Edit the PCI-DSS Protection Policy

> **Note**: This policy was already created in Day Zero Setup to initiate M365 workload propagation. We will now enhance it with advanced features.

- Go to [purview.microsoft.com](https://purview.microsoft.com).
- Navigate to **Data Loss Prevention** > **Policies**.
- Find the policy named **"PCI-DSS Protection (Retail)"**.
- Click on the policy name to open it.
- Click **Edit policy** (top right).

**Skip to Step 6: Customize Rules**

- You can skip through the first 5 steps (they're already configured).
- Click **Next** until you reach the **Customize advanced DLP rules** page.

**Edit the Rules:**

- Edit the **"PCI-DSS Protection (Retail) - Credit Card Data"** rule.
- **User notifications**:
    - Toggle **On**.
    - Check **Notify the user in email and with a policy tip**.
    - Optionally customize the policy tip text.
- **User overrides**:
    - Toggle **On**.
    - Check **Require a business justification to override**.
- **Incident reports**:
    - Toggle **On**.
    - Send report to: Admin (your email).
- Click **Save**.

**Repeat for Banking Data Rule** (if desired):
- Edit the **"PCI-DSS Protection (Retail) - Banking Data"** rule.
- Apply the same notification and override settings.
- Click **Save**.

**Complete the Edit:**
- Click **Next** through remaining screens.
- Click **Submit** to save your changes.

### Part 2: Replace Placeholder in Loyalty Card Policy

> **Critical**: This policy was created with a placeholder rule using "Credit Card Number" because the custom SIT didn't exist yet. Now we'll replace it with the actual "Retail Loyalty ID" SIT.

- Navigate to **Data Loss Prevention** > **Policies**.
- Find the policy named **"Loyalty Card Protection (Retail)"**.
- Click on the policy name to open it.
- Click **Edit policy** (top right).

**Navigate to Rules:**

- Click **Next** until you reach the **Customize advanced DLP rules** page.

**Replace the Placeholder Rule:**

- Find the rule named **"Loyalty Card Protection (Retail) - Loyalty ID Detection (Placeholder)"**.
- Click **Delete** to remove this placeholder rule.
- Click **+ Create rule** to create the actual rule.

**Create the Loyalty ID Rule:**

- **Name**: Loyalty ID Detection
- **Conditions**:
    - **Content contains**: 
        - Click **Add** > **Sensitive info types**.
        - Search for **"Retail Loyalty ID"** (your custom SIT from Lab 01).
        - Select it and set **Instance count** to **1 to Any**.
    - (Optional) Add condition: **Content is shared** > **with people outside my organization**.
- **Actions**:
    - **Restrict access or encrypt the content**: Check **Block people outside your organization**.
- **User notifications**:
    - Toggle **On**.
    - Check **Notify the user in email and with a policy tip**.
- **User overrides**:
    - Toggle **On**.
    - Check **Require a business justification to override**.
- **Incident reports**:
    - Toggle **On**.
    - Send report to: Admin (your email).
- Click **Save**.

**Complete the Edit:**

- Click **Next** through remaining screens.
- Click **Submit** to save your changes.

> **💡 Important**: Because you edited an existing policy (not created a new one), the updated rules will be active immediately without requiring a new propagation wait!

## ✅ Validation

### Test PCI-DSS Protection Policy

- **Teams Test**: Try to paste a credit card number (from your generated data) into a chat with an external user (or a guest). You should see a "Message Blocked" policy tip with an option to override.
- **Email Test**: Try to email a file containing credit card numbers to a personal address (Gmail). You should receive a policy tip allowing override with business justification.

### Test Loyalty Card Protection Policy

- **Create a test file**: Create a Word document containing a Loyalty ID in the format `RET-123456-A`.
- **Email Test**: Try to email this file externally. You should receive a policy tip.
- **SharePoint Test**: Try to share this file with external users via SharePoint. The sharing should be blocked or require override.
- **Teams Test**: Try to attach this file in a Teams chat with an external user. You should see a policy tip.

### Verify in Activity Explorer

- Go to **Data Loss Prevention** > **Activity Explorer**.
- Wait 15-60 minutes for events to appear.
- Verify you see DLP policy matches for your test activities.

> **Note**: Policy changes can take 1-2 hours to fully propagate, but since the policies were already synced on Day Zero, the updated rules should be active much faster than creating new policies.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for DLP configuration.

*AI tools were used to enhance productivity and ensure comprehensive coverage of DLP policy steps while maintaining technical accuracy.*
