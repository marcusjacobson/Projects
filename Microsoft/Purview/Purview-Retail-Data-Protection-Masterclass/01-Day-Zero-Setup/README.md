# Day Zero Setup: Long-Lead Items

**⚠️ CRITICAL STEP**: Execute the tasks in this section **IMMEDIATELY**.

Microsoft Purview has several features that require significant backend processing time before they become active. To ensure you can complete the labs without waiting, you must initiate these processes on "Day Zero".

## ⏳ Wait Times Overview

| Feature | Action | Estimated Wait Time |
|---------|--------|---------------------|
| **Pay-As-You-Go (PAYG)** | Billing Propagation | 4 - 24 Hours |
| **Sensitivity Labels** | Policy Publication | 24 Hours (for full client availability) |
| **Auto-Labeling Policies** | Simulation Results | 24 - 48 Hours |
| **DLP Policies** | Policy Propagation | 1 - 2 Hours (M365 workloads) |
| **Audit Log** | Initial Enablement | 24 Hours |

## 📋 Day Zero Checklist

### 1. Enable Purview Pay-As-You-Go (PAYG)

**Why?** Advanced Purview features require an Azure Subscription link.

- **Pre-Check (Optional)**:
  - Go to [purview.microsoft.com](https://purview.microsoft.com) > **Settings** (gear icon) > **Account**.
  - If you see an Azure Subscription listed under "Billing & Usage", PAYG is **already enabled**. You can skip this step.
- **Action**: Run the script from the `scripts` directory:

    ```powershell
    cd scripts
    .\Enable-PurviewPAYG.ps1
    ```
  
  - This script checks for existing Purview accounts.
  - **If enabled**: It will report "✅ Purview Pay-As-You-Go is ALREADY enabled" and exit safely.
  - **If not enabled**: It creates an Azure Resource Group and a Purview Account to enable billing.
  - **Note**: This script requires the `Az` PowerShell module and Owner/Contributor rights on your Azure Subscription.

- **Validation**:
  - The script output will confirm either "✅ Pay-As-You-Go billing is now enabled" or "ALREADY enabled".
  - In the Azure Portal, verify the `pview-payg-*` (or your existing) resource exists.

### 2. Publish "Baseline" Sensitivity Labels

**Why?** While labels often appear in Web Apps within an hour, full propagation to Desktop Apps (Word, Excel) and the AIP Client can take up to **24 hours**. Deploying them now ensures they are fully available when you reach **Lab 04**.

**Authentication Note**: Unlike the EDM step above, this script uses **Service Principal** authentication (configured in Prerequisites) to interact with the Microsoft Graph API.

- **Action**: Run the deployment script:

    ```powershell
    .\Deploy-BaselineLabels.ps1
    ```

- **What to Expect**:
  - The script connects to Security & Compliance PowerShell using the Service Principal.
  - It checks for existing labels by **Display Name** to prevent duplicates.
  - It creates two labels: **"General"** and **"Confidential"** (if they don't already exist).
  - **Note**: This script only creates the **Label Definitions**. You must create a **Label Policy** (in Lab 04 or via portal) to publish them to users. Auto-labeling policies are also a separate future step.

  **Example Output (Idempotent Run):**

  ```text
  🔌 Connecting to Microsoft Graph...
     📂 Loading configuration from global-config.json...
     ✅ Found certificate 'PurviewAutomationCert' in user store.
     ✅ Found App ID in ServicePrincipal-Details.txt
  🔍 Step 1: Environment Validation
  =================================
     ✅ Microsoft.Graph module is already installed.
  🔐 Step 2: Authentication
  ========================
     🚀 Connecting to Microsoft Graph...
     ✅ Successfully connected to tenant...
  📋 Step 1: Defining Label Taxonomy
  ==================================
  🔐 Step 2: Connecting to Security & Compliance PowerShell
  ========================================================
     🔍 Retrieving default domain from Microsoft Graph...
     ✅ Organization Domain: marcusj-dev.cloud
     🚀 Connecting to IPPSSession (App-Only)...
     ✅ Connected to Security & Compliance PowerShell
  🚀 Step 3: Deploying Labels
  ===========================
     ⏳ Processing label: General
     ✅ Label 'General' already exists (ID: ...). Skipping creation.
     ⏳ Processing label: Confidential
     ✅ Label 'Confidential' already exists (ID: ...). Skipping creation.
     ℹ️ Note: Policy publication is required to make these labels visible to users.
     ℹ️ Please create a Label Policy in the Purview Portal or via script to publish these.
  ```

- **Validation**:
  - The script creates label definitions successfully.
  - **Note**: Labels require up to 24 hours for full propagation to desktop apps.
  - After propagation, open **Word** or **Excel** and verify the **Sensitivity** button appears.
  - You'll create a Label Policy in **Lab 04** to publish these labels to users.

### 3. Deploy Label Policy

**Why?** Label definitions alone don't make labels visible to users. A Label Policy is required to publish labels, and policy propagation takes up to 24 hours. Creating the policy now ensures labels are fully available when you reach **Lab 04**.

- **Action**: Run the deployment script:

    ```powershell
    .\Deploy-LabelPolicy.ps1
    ```

- **What to Expect**:
  - The script creates a "Global Sensitivity Policy" that publishes the baseline labels.
  - It assigns the policy to **All Users** in your tenant.
  - Sets **"General"** as the default label for new documents.
  - Enables **mandatory labeling** (users must apply a label).
  - Requires **justification** to remove or downgrade a label.
  - Policy propagates to M365 apps within 24 hours.

- **Validation**:
  - After 24 hours, open **Word** or **Excel** (desktop or web).
  - Verify the **Sensitivity** button appears on the ribbon.
  - Click it and confirm you see **"General"** and **"Confidential"** labels.
  - Create a new document and verify you're prompted to select a label.

![label-policy](.images/label-policy.png)

### 4. Deploy Auto-Labeling Policy

**Why?** Auto-labeling policies scan SharePoint/OneDrive for sensitive content and automatically apply labels. Simulation mode takes 24-48 hours to analyze files and provide results. Starting this now means you'll have simulation data ready when you reach **Lab 03**.

- **Action**: Run the deployment script:

    ```powershell
    .\Deploy-AutoLabelingPolicy.ps1
    ```

- **What to Expect**:
  - The script creates an auto-labeling policy named **"Auto-Label PII (Retail)"**.
  - Creates **4 detection rules** (2 for SharePoint, 2 for OneDrive) to scan for **Credit Card Numbers** and **U.S. Social Security Numbers**.
  - Runs in **Simulation Mode** (safe - no files are modified).
  - Automatically applies the **"Confidential"** label when PII/PCI data is detected.
  - Simulation takes **24-48 hours** to complete analysis.
  - Aligns with baseline DLP policy scope (PCI-DSS + PII protection).

- **Validation**:
  - Go to [purview.microsoft.com](https://purview.microsoft.com) > **Information Protection** > **Auto-labeling**.
  - Verify **"Auto-Label PII (Retail)"** policy appears with status **"Simulation"**.
  - Click the policy to confirm **4 rules** are configured (2 for SharePoint, 2 for OneDrive).
  - After 24-48 hours, click the policy to **View simulation results**.
  - You'll see a list of files that matched either **Credit Card** or **SSN** patterns.
  - Results show where sensitive payment and identity data exists across your tenant.
  - In **Lab 03**, you can review results and turn on enforcement if desired.

![autolabel-policy](.images/autolabel-policy.png)

> **💡 Key Point**: This policy runs in simulation mode only. It identifies matching files without modifying them. You'll have visibility into what would be auto-labeled before enforcing the policy. The dual SIT detection (Credit Cards + SSN) aligns with your DLP policy scope and provides comprehensive coverage of retail PII/PCI data.

### 5. Deploy Baseline DLP Policies

**Why?** DLP policies require time to propagate across Exchange, SharePoint, OneDrive, and Teams workloads. Creating baseline policies now ensures they are active when you reach the configuration and testing labs.

- **Action**: Run the deployment script:

    ```powershell
    .\Deploy-BaselineDlpPolicies.ps1
    ```

- **What to Expect**:
  - The script creates **four** baseline policies in **"Test with Notifications"** mode:
    1. **"PCI-DSS Protection (Retail)"**: Detects Credit Cards and ABA Routing Numbers.
    2. **"PII Data Protection (Retail)"**: Detects U.S. SSNs.
    3. **"Loyalty Card Protection (Retail)"**: Uses a placeholder rule (Credit Card) until the custom SIT is created.
    4. **"External Sharing Control (Retail)"**: Restricts external sharing of sensitive files.
  - All policies target **Exchange, SharePoint, OneDrive, and Teams** and propagate within 1-2 hours.

- **Validation**:
  - Go to [purview.microsoft.com](https://purview.microsoft.com) > **Data Loss Prevention** > **Policies**.
  - Verify all 4 policies show status "On (Test)" with M365 locations enabled.

![policy-pcidss](.images/policy-pcidss.png)

> **💡 Key Point**: These policies are created now to start the propagation timer. In **Lab 04**, you'll edit them to add advanced features (custom SITs, notifications, overrides) without triggering a new wait. Only creating NEW policies or adding NEW LOCATIONS requires propagation time.

### 6. Enable Audit Logging

**Why?** You cannot track data exfiltration or policy matches if auditing is off.

- **Action**: Run the enablement script:

    ```powershell
    .\Enable-AuditLogging.ps1
    ```

- **What to Expect**:
  - The script connects to Exchange Online PowerShell.
  - It checks the current status of `UnifiedAuditLogIngestionEnabled`.
  - If disabled, it enables it and warns about the 24-hour activation period.
- **Validation**:
  - Run the script again; it should report "✅ Unified Audit Log is ALREADY enabled."
- **Future Context**: You will use these logs in **Lab 07: Audit and Validation** to investigate simulated data leaks.

## 🚀 Automation Scripts

Use the scripts in this directory to perform these actions quickly.

> **Note**: All scripts should be run from the `scripts` directory.

- `Enable-PurviewPAYG.ps1`: Enables Pay-As-You-Go billing.
- `Deploy-BaselineLabels.ps1`: Creates baseline label definitions.
- `Deploy-LabelPolicy.ps1`: Creates and publishes the Global Sensitivity Policy.
- `Deploy-AutoLabelingPolicy.ps1`: Creates auto-labeling policy in simulation mode for PII detection.
- `Deploy-BaselineDlpPolicies.ps1`: Creates comprehensive baseline DLP policies (PCI-DSS, PII, Loyalty ID, External Sharing).
- `Enable-AuditLogging.ps1`: Turns on the Unified Audit Log.

> **📋 EDM Scripts Archived**: EDM-related scripts (`Initialize-EdmPrerequisites.ps1`, `Sync-EdmSchema.ps1`, `Upload-EdmData.ps1`, `Test-EdmWorkflow.ps1`) have been moved to `archived-edm-scripts/` folder. The EDM workflow is now handled in **Lab 02** using the portal wizard approach. See `archived-edm-scripts/ARCHIVE-REFERENCE.md` for reference patterns and IaC development guidance.

> **Note**: Ensure you have run `Deploy-ServicePrincipal.ps1` in the prerequisites section before running these scripts.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for managing Purview propagation delays.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Day Zero requirements while maintaining technical accuracy.*
