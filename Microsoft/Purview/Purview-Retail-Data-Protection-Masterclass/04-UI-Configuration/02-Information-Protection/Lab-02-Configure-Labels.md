# Lab 02: Configure Sensitivity Labels

In this lab, you will manually create the "Confidential" and "Highly Confidential" labels in the Microsoft Purview portal. This establishes the core of your data protection strategy.

## 🎯 Objectives

- Create a "Confidential" label with encryption.
- Create a "Highly Confidential" label with visual markings and encryption.
- Publish these labels to a policy.

## 📋 Prerequisites

- **Global Administrator** or **Compliance Administrator** role.
- **Day Zero Setup** completed (to ensure the "General" label exists if you ran the script, otherwise we will create it here).

## 📝 Step-by-Step Instructions

### Part 1: Create the "Confidential" Label

- Go to [purview.microsoft.com](https://purview.microsoft.com) and sign in.
- Navigate to **Information Protection** > **Labels**.
- Click **+ Create a label** to start the wizard.

**Step 1: Define the scope**

- **Name**: Confidential
- **Display name**: Confidential
- **Description for users**: Sensitive business data that could cause damage if leaked.
- **Scope**: Select **Items** (Files, Emails). Uncheck "Groups & sites" and "Schematized data assets" for this lab.

**Step 2: Choose protection settings**

- Check **Apply or remove encryption**.
- Check **Apply content marking**.

**Step 3: Configure encryption**

- Select **Assign permissions now**.
- **User access to content expires**: Never.
- **Offline access**: Always.
- Click **Assign permissions**.
    - Click **Add all users and groups in your organization**.
    - Select permissions: **Co-Author**.
    - Click **Save**.

**Step 4: Configure content marking**

- Toggle **Content marking** to On.
- Select **Add a header**.
- **Text**: "Confidential - Internal Use Only".
- **Font size**: 10.
- **Color**: Black.
- Click **Save**.

**Step 5: Auto-labeling**

- Leave auto-labeling **Off** for now (we will configure this in Lab 03).

**Step 6: Review and Finish**

- Review your settings.
- Click **Create label**.
- Choose **Don't create a policy yet** (we will do this at the end).

### Part 2: Create the "Highly Confidential" Label

- Click **+ Create a label** again.

**Step 1: Define the scope**

- **Name**: Highly Confidential
- **Display name**: Highly Confidential
- **Description**: Critical data (PCI-DSS, Strategy).
- **Scope**: **Items** (Files, Emails).

**Step 2: Choose protection settings**

- Check **Apply or remove encryption**.
- Check **Apply content marking**.

**Step 3: Configure encryption**

- Select **Assign permissions now**.
- Click **Assign permissions**.
    - Click **Add all users and groups in your organization**.
    - Select permissions: **Co-Author**.
    - Click **Save**.

**Step 4: Configure content marking**

- Toggle **Content marking** to On.
- Select **Add a watermark**.
- **Text**: "RESTRICTED".
- **Font size**: 24.
- **Color**: Red.
- **Layout**: Diagonal.
- Click **Save**.

**Step 5: Review and Finish**

- Click **Create label**.

### Part 3: Publish Labels

- Navigate to **Information Protection** > **Label policies**.
- Click **Publish label**.

**Step 1: Choose labels**

- Click **Choose labels to publish**.
- Select **General**, **Confidential**, and **Highly Confidential**.
- Click **Add**.

**Step 2: Choose users**

- Select **Users and groups**.
- Choose **All** (or select specific users for testing).

**Step 3: Policy settings**

- **Default label**: Select **General**.
- **Mandatory labeling**: Check **Require users to apply a label to their emails and documents**.
- **Justification**: Check **Require users to provide justification to remove a label or lower its classification**.

**Step 4: Name and Finish**

- **Name**: Global Sensitivity Policy.
- Click **Submit**.

## ✅ Validation

- Wait approximately 24 hours for the policy to propagate.
- Open **Word** or **Outlook**.
- Verify the **Sensitivity** button appears on the ribbon.
- Verify you see the labels: **General**, **Confidential**, **Highly Confidential**.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for manual Purview configuration.

*AI tools were used to enhance productivity and ensure comprehensive coverage of label configuration steps while maintaining technical accuracy.*
