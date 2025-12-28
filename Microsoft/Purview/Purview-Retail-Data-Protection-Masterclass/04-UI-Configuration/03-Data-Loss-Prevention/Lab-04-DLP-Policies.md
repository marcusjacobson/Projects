# Lab 04: Configure DLP Policies

In this lab, you will create a Data Loss Prevention (DLP) policy to protect PCI-DSS data (Credit Cards) across Exchange, Teams, and Endpoints.

## 🎯 Objectives

- Create a DLP policy blocking Credit Card numbers.
- Configure a "Block with Override" action for business justification.
- Enable Policy Tips in Teams and Outlook.

## 📋 Prerequisites

- **Global Administrator** or **Compliance Administrator** role.
- **Sensitivity Labels** created in Lab 02.

## 📝 Step-by-Step Instructions

### Part 1: Create the Policy

- Go to [purview.microsoft.com](https://purview.microsoft.com).
- Navigate to **Data Loss Prevention** > **Policies**.
- Click **+ Create policy**.

**Step 1: Choose Template**

- **Categories**: Financial.
- **Template**: U.S. Financial Data (includes Credit Card Number, ABA Routing Number).
- Click **Next**.

**Step 2: Name the Policy**

- **Name**: PCI-DSS Protection (Retail).
- **Description**: Blocks sharing of credit card data externally.
- Click **Next**.

**Step 3: Assign Admin Units**

- Click **Next** (default).

**Step 4: Choose Locations**

- Toggle **On**:
    - Exchange email.
    - SharePoint sites.
    - OneDrive accounts.
    - Teams chat and channel messages.
    - Devices (Endpoint DLP).
- Click **Next**.

**Step 5: Define Policy Settings**

- Select **Review and customize default settings from the template**.
- Click **Next**.

**Step 6: Customize Rules**

- Edit the **Low volume of content detected** rule.
- **Conditions**:
    - Content contains: Credit Card Number.
    - Content is shared: with people outside my organization.
- **Actions**:
    - **Restrict access or encrypt the content**: Block people outside your organization.
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
- (Optional) Repeat for "High volume" rule or delete it to simplify.

**Step 7: Policy Mode**

- Select **Turn it on right away**.
- Click **Next**.
- Click **Submit**.

## ✅ Validation

- Wait 1-24 hours for sync.
- **Teams Test**: Try to paste a credit card number (from your generated data) into a chat with an external user (or a guest). You should see a "Message Blocked" tip.
- **Email Test**: Try to email the CSV file to a personal address (Gmail). You should receive a bounce-back or policy tip.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for DLP configuration.

*AI tools were used to enhance productivity and ensure comprehensive coverage of DLP policy steps while maintaining technical accuracy.*
