# Lab 03: Configure Auto-Labeling

In this lab, you will configure a Service-Side Auto-Labeling policy. This scans data at rest (SharePoint/OneDrive) and automatically applies the "Confidential" label if it finds PII.

## 🎯 Objectives

- Create an auto-labeling policy for "U.S. Social Security Number".
- Run the policy in "Simulation Mode" first.
- Review matched items.

## 📋 Prerequisites

- **Global Administrator** or **Compliance Administrator** role.
- **"Confidential" Label** created in Lab 02.

## 📝 Step-by-Step Instructions

### Part 1: Create the Policy

- Go to [purview.microsoft.com](https://purview.microsoft.com).
- Navigate to **Information Protection** > **Auto-labeling**.
- Click **+ Create auto-labeling policy**.

**Step 1: Choose Template**

- **Categories**: Privacy.
- **Template**: U.S. Personally Identifiable Information (PII) Data.
- Click **Next**.

**Step 2: Name the Policy**

- **Name**: Auto-Label PII (Retail).
- Click **Next**.

**Step 3: Assign Admin Units**

- Click **Next** (default).

**Step 4: Choose Locations**

- Toggle **On**:
    - SharePoint sites.
    - OneDrive accounts.
- (Exchange is optional but can be slow to simulate).
- Click **Next**.

**Step 5: Define Rules**

- Use the **Common rules**.
- Ensure "U.S. Social Security Number (SSN)" is selected.
- Click **Next**.

**Step 6: Choose Label**

- Select **Confidential**.
- Click **Next**.

**Step 7: Policy Mode**

- Select **Run policy in simulation mode**.
- Check **Turn on policy simulation**.
- Click **Next**.
- Click **Create policy**.

### Part 2: Review Simulation

- Wait 24-48 hours for the simulation to complete.
- Return to **Auto-labeling**.
- Click on your policy.
- Click **View simulation results**.
- You will see a list of files that matched.
- If satisfied, click **Turn on policy** to enforce the labeling.

## ✅ Validation

- Upload a file containing fake SSNs to SharePoint.
- Wait for the simulation to catch it.
- Once turned on, verify the file icon changes to show the "Confidential" lock/badge.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for automated classification.

*AI tools were used to enhance productivity and ensure comprehensive coverage of auto-labeling steps while maintaining technical accuracy.*
