# Lab 00: Prerequisites and Environment Setup

## 🎯 Objective

Validate licensing, permissions, and environment readiness before beginning the Fabric + Purview simulation.

**Duration**: 30 minutes

---

## 🏗️ What You'll Build

| Item | Description |
|------|-------------|
| **Validated Environment** | Confirmed licensing, permissions, and capacity for Fabric and Purview |
| **Trial Capacity** | 60-day Microsoft Fabric trial (or F2 capacity if needed) |
| **Lab Path Decision** | Chosen approach based on available resources |

### Real-World Context

In enterprise environments, **environment validation is the foundation of every data platform deployment**. Organizations must verify:

- **Licensing compliance** before deploying analytics workloads.
- **Capacity planning** to ensure resources match workload requirements.
- **Permission structures** to enable proper governance from day one.
- **Cost forecasting** to align with budget constraints.

Skipping this validation step is the #1 cause of failed data platform implementations. This lab mirrors the discovery phase that consultants perform when assessing client readiness for Microsoft Fabric adoption.

---

## 🛤️ Choose Your Lab Path

This simulation supports two approaches based on your available resources:

| Approach | Best For | Fabric Cost | Purview Cost | Duration Limit |
|----------|----------|-------------|--------------|----------------|
| **Path A: Fabric Trial + Purview Free** | First-time learners, quick labs | $0 | $0 | 60 days |
| **Path B: Fabric F2 + Purview Free** | Extended learning, repeat demos | ~$0.36/hr (pause when idle) | $0 | Unlimited |

> **💡 Recommendation**: Start with **Path A** (Fabric Trial). It provides full Fabric capabilities at no cost for 60 days. Only consider Path B if your trial has expired or you need ongoing access beyond 60 days.

### What Both Paths Include

- ✅ Full Microsoft Fabric capabilities (Lakehouses, Warehouses, Data Pipelines, etc.).
- ✅ Purview "live view" automatic discovery of Fabric assets.
- ✅ Manual classification and annotation of up to 1,000 assets.
- ✅ Glossary terms and business context management.
- ✅ Basic data lineage within Fabric.

### What Requires Purview Enterprise (Additional Cost)

- ❌ Deep scanning with automatic classification.
- ❌ Collections for organizing assets hierarchically.
- ❌ Advanced workflows and approvals.
- ❌ Unlimited asset annotations.

> **📚 See**: [Purview Enterprise Features and Costs](#-purview-enterprise-features-and-costs) at the end of this document for detailed pricing.

---

## 📋 Prerequisites

Before starting this lab, ensure you have:

- [ ] Access to a Microsoft 365 tenant with admin permissions.
- [ ] Web browser (Microsoft Edge or Google Chrome recommended).
- [ ] Internet connectivity.

---

## 🔧 Step 1: Verify Microsoft 365 Licensing

### Understanding Fabric and Purview Licensing

Microsoft Fabric and Purview Data Governance are licensed separately:

- **Microsoft Fabric**: Requires either a trial capacity or paid F-SKU capacity.
- **Purview Data Governance**: Free version included with Microsoft 365; enterprise version requires Azure subscription.

### License Compatibility Matrix

| Your Subscription | Fabric Access | Purview Free (Live View) | Purview Enterprise | This Lab |
|-------------------|---------------|--------------------------|--------------------|-----------|
| **Microsoft 365 E5** | ✅ Can start trial or add F-SKU | ✅ Included | ⚠️ Separate Azure cost | ✅ Supported |
| **Microsoft 365 E3** | ✅ Can start trial or add F-SKU | ✅ Included | ⚠️ Separate Azure cost | ✅ Supported |
| **Developer Subscription** | ✅ Can start 60-day trial | ✅ Included | ⚠️ Separate Azure cost | ✅ Supported |
| **Fabric Trial (standalone)** | ✅ 60 days full access | ✅ Included | ⚠️ Separate Azure cost | ✅ Supported |
| **Fabric F2-F64 (paid)** | ✅ Full with pause/resume | ✅ Included | ⚠️ Separate Azure cost | ✅ Supported |
| **Power BI Pro only** | ❌ No Fabric capacity | ✅ Limited | ❌ N/A | ❌ Not sufficient |

> **⚠️ Important**: Purview Enterprise (full scanning, automatic classification) is NOT included in any Microsoft 365 license. It requires a separate Azure subscription with consumption-based billing (~$360+/month minimum). This simulation is designed to work with the **free version** of Purview Data Governance.

### Path A: Verify or Start Fabric Trial (Recommended)

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. If prompted, click **Start trial** to activate your 60-day free trial.

3. If trial is already active or you have existing capacity, you'll see the Fabric home page.

4. Click **Settings** (gear icon) → **Admin portal** → **Capacity settings** to verify your capacity.

> **💡 Tip**: The Fabric trial provides full capabilities at no cost for 60 days. This is sufficient to complete all labs in this simulation.

### Path B: Set Up Fabric F2 Capacity (When Trial Not Available)

If your trial has expired or is unavailable:

1. Go to [portal.azure.com](https://portal.azure.com).

2. Search for **Microsoft Fabric** in the marketplace.

3. Create a new Fabric capacity:
   - **SKU**: F2 (smallest, ~$0.36/hour).
   - **Region**: Same as your other Azure resources.
   - **Resource group**: Create new or use existing.

4. After creation, **pause the capacity** immediately to stop billing:
   - Navigate to the Fabric capacity resource.
   - Click **Pause** in the command bar.

5. **Resume only when actively using** for lab exercises.

> **💰 Cost Control Tip**: With F2 and disciplined pause/resume, 4 hours/week × 4 weeks = 16 hours × $0.36 = **~$6/month**. Set up an Azure Automation runbook to auto-pause daily as a safety net.

---

## 🔧 Step 2: Verify Admin Permissions

### Required Permissions

| Permission | Purpose | Required For | How to Verify |
|------------|---------|--------------|---------------|
| **Fabric Administrator** | Enable Fabric, configure tenant settings | All labs | Fabric Admin portal access |
| **Fabric Workspace Admin** | Create and manage Fabric workspaces | All labs | Create workspace in Fabric portal |
| **Purview Reader** | View discovered assets in Purview | Labs 06-08 | Access purview.microsoft.com |
| **Purview Data Catalog Curator** | Annotate and classify assets | Labs 07-08 (free version) | Edit asset metadata |
| **Purview Data Source Administrator** | Register sources, run scans | Enterprise only | Purview Data Map → Sources |

### Verify Fabric Admin Access

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Click the **Settings** gear icon (top right) and select **Admin portal**.

3. If you can access the **Admin portal**, you have Fabric admin rights.

4. Navigate to **Tenant settings** to verify you can view and modify settings.

> **⚠️ Not an Admin?** Contact your IT administrator to request temporary admin access for this simulation, or use a developer/trial tenant where you have full control.

### Verify Purview Free Version Access

The free version of Purview Data Governance provides "live view" discovery of Fabric assets.

1. Go to [purview.microsoft.com](https://purview.microsoft.com).

2. Accept the terms and privacy conditions if prompted, then select **Get started**.

3. On the portal **home page**, verify you can see:
   - **Solution cards** showing available Purview solutions.
   - **Settings** option (gear icon).

4. Check for **Data Governance** solutions:
   - Look for **Unified Catalog** or **Data Catalog** in available solutions.
   - If visible, you have access to the free data governance features.

5. To verify your permissions:
   - Select **Settings** (gear icon) → **Roles and scopes**.
   - Look for your assigned role groups.

> **💡 What to Expect with Free Version**:
>
> - ✅ Fabric assets appear automatically via "live view" (no scanning required).
> - ✅ Manual classification and glossary term assignment.
> - ✅ Up to 1,000 annotated assets.
> - ❌ No automatic classification or deep scanning.
> - ❌ No collections for hierarchical organization.

---

## 🔧 Step 3: Verify Fabric Capacity

Microsoft Fabric requires a capacity (compute resources) to run workloads.

### Check Existing Capacity

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Click the **Settings** gear icon (top right).

3. Select **Admin portal** → **Capacity settings**.

4. Look for available capacities:

| Capacity Type | Cost | Pause/Resume | Best For |
|---------------|------|--------------|----------|
| **Trial** | Free (60 days) | ❌ Cannot pause | First-time learners |
| **F2** | ~$0.36/hour | ✅ Yes | Cost-controlled labs |
| **F4-F64** | $0.72-$23/hour | ✅ Yes | Larger workloads |
| **P1-P5** | $4,995+/month | ❌ No | Enterprise production |

### Path A: Start Trial Capacity (Recommended)

If no capacity exists and trial is available:

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Click on any workspace or try to create a new item.

3. You'll see a prompt: **"Start a Microsoft Fabric trial"**.

4. Click **Start trial** - activates immediately for 60 days.

> **💡 Note**: Trial capacity is shared across your organization. Check with colleagues before starting.

### Path B: Create F2 Capacity (When Trial Unavailable)

If trial is expired or unavailable:

1. Go to [portal.azure.com](https://portal.azure.com) → **Create a resource**.

2. Search **Microsoft Fabric** → **Create**.

3. Configure:
   - **Name**: `fabric-lab-capacity`
   - **Size**: F2 (smallest)
   - **Region**: Your preferred region
   - **Fabric capacity administrator**: Your account

4. Click **Review + Create** → **Create**.

5. **Immediately pause** the capacity after creation to avoid charges.

> **💰 F2 Cost Management**:
>
> - Billed per-second when running (~$0.36/hour).
> - **Pause** when not actively using.
> - Set up daily auto-pause runbook as safety net.
> - Estimated lab cost: $5-15/month with disciplined usage.

---

## 🔧 Step 4: Browser and Environment Setup

### Recommended Browser Configuration

1. **Use Microsoft Edge or Google Chrome** for best compatibility.

2. **Sign in to the correct account**:
   - Open a new browser window or use a profile.
   - Go to [portal.azure.com](https://portal.azure.com).
   - Verify you're signed in with your admin account.

3. **Disable pop-up blockers** for Microsoft domains:
   - `*.microsoft.com`
   - `*.microsoftonline.com`
   - `*.fabric.microsoft.com`
   - `*.powerbi.com`

### Create a Dedicated Browser Profile (Optional but Recommended)

1. In Edge: Click profile icon → **Add profile** → **Add**.
2. Name it "Fabric Labs" or similar.
3. Sign in with your lab account.
4. This keeps lab work separate from personal browsing.

---

## 🔧 Step 5: Enable Pay-As-You-Go Billing for Purview (Required for Lab 06)

> **⚠️ Critical for Later Labs**: Labs 06-07 require Microsoft Purview features (DLP for Fabric, Data Map) that need **pay-as-you-go billing** enabled. Complete this now so billing propagates during Labs 01-05.

### Why Enable Now?

- Pay-as-you-go billing takes **a few hours** to propagate.
- If you wait until Lab 06, you'll hit a blocker and need to wait.
- Enabling now allows propagation during Labs 01-05.

### Enable Pay-As-You-Go

1. Go to [purview.microsoft.com](https://purview.microsoft.com).
2. Look for the **rocket icon** (🚀) in the top-right header near the Settings gear.
3. Click the rocket and select **Get Started**.
   - Alternatively: **Settings** → **Account details** → configure billing.
4. Select your **Azure subscription** from the list (must be in the same tenant as your M365).
5. Select or create a **Resource group**:
   - **Recommended**: Create a new resource group named `rg-purview-billing` or `rg-fabric-governance-lab`.
   - In Azure Portal: **Resource groups** → **+ Create** → Name: `rg-purview-billing` → Region: your region → **Create**.
6. Complete the setup wizard.

> **📝 Requirements**:
>
> - **Global Administrator** role required for this step.
> - Active Azure subscription in the same tenant.
> - A resource group in that subscription.

### Verify Billing Enabled

After completing the wizard:

1. Go to **Settings** → **Account details**.
2. Verify your Azure subscription is linked.
3. You should see billing configuration details.

> **💡 Note**: Full propagation can take a few hours. Continue to Lab 01 — by the time you reach Lab 06, billing will be active.

---

## 🔧 Step 6: Register Fabric in Data Map (Required for Lab 07)

> **📊 For Lineage Visibility**: Registering Fabric as a data source in Data Map enables lineage visualization in Lab 07. Complete this now so it's ready when needed.

### Register Fabric Data Source

1. In the [Purview portal](https://purview.microsoft.com), navigate to **Data Map** in the left menu.
2. Select **Data sources**.
3. Click **Register**.
4. In the **Register data source** panel:
   - Search for and select **Fabric (Includes Power BI)**.
5. Configure the registration:
   - **Data source name**: `Fabric-Lab`
   - **Tenant ID**: Auto-populated with your tenant ID.
   - **Domain**: Select your domain (e.g., `payg-billing`).
   - **Collection**: Leave as default (Select domain only).
6. Click **Register**.

### Verify Registration

After registration, you should see:

- **Fabric-Lab** appears in the Data sources map view.
- The Fabric icon indicates successful registration.
- You can click **View details** to see registration information.

> **💡 Note**: You'll configure and run a scan in Lab 07. Registration now ensures the data source is ready.

---

## 🔧 Step 7: Create Security Group for Purview Scanning (Required for Lab 07)

> **🔐 Required for Data Map Scanning**: Microsoft Purview uses its Managed Identity to scan Fabric. The Fabric Admin API requires this identity to be in a security group with explicit API permissions.

### Why This Is Required

When you enabled pay-as-you-go billing in Step 5, Azure created a **Managed Identity** for your Purview account. This identity (named the same as your Purview account, e.g., `payg-billing`) needs permission to access Fabric's read-only admin APIs for scanning.

Without this configuration, the Data Map scan in Lab 07 will fail with:

- ✓ Access: Passed
- ✗ Assets (+ lineage): Failed
- ✗ Detailed metadata: Failed

### Step 7.1: Create Security Group in Microsoft Entra ID

1. Go to [entra.microsoft.com](https://entra.microsoft.com) or [portal.azure.com](https://portal.azure.com) → **Microsoft Entra ID**.
2. Navigate to **Groups** → **All groups** → **New group**.
3. Configure the group:
   - **Group type**: Security
   - **Group name**: `Purview-Fabric-Scanners`
   - **Group description**: Security group for Purview Managed Identity to scan Fabric tenant
   - **Membership type**: Assigned
4. Click **Create**.

### Step 7.2: Add Purview Managed Identity to the Group

1. Open the newly created **Purview-Fabric-Scanners** group.
2. Go to **Members** → **Add members**.
3. Search for **payg-billing** (the Purview account created in Step 5).
4. Select it and click **Select**.

### Step 7.3: Enable Admin API Access for the Security Group

1. Go to **Fabric Admin Portal**: [app.fabric.microsoft.com](https://app.fabric.microsoft.com) → **Settings** (gear icon) → **Admin portal**.
2. Navigate to **Tenant settings**.
3. Scroll to the **Admin API settings** section.
4. Find **Allow service principals to use read-only admin APIs**:
   - Toggle to **Enabled**.
   - Select **Specific security groups**.
   - Click **Add groups** and search for `Purview-Fabric-Scanners`.
   - Add the group and click **Apply**.
5. Verify these additional settings are enabled (should already be from Step 6):
   - **Enhance admin APIs responses with detailed metadata**: Enabled for the same security group.
   - **Enhance admin APIs responses with DAX and mashup expressions**: Enabled for the same security group.

> **⏱️ Propagation Time**: Admin API settings can take **up to 15 minutes** to propagate. The scan configuration in Lab 07 won't work immediately after these changes.

### Step 7.4: Grant Workspace Access to Purview MSI

The Admin API settings allow Purview to call tenant-level APIs, but it also needs **direct workspace access** to scan workspace contents.

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
2. Open your **Fabric-Purview-Lab** workspace (create it now if it doesn't exist).
3. Click **Manage access** (in the workspace header or via **...** menu).
4. Click **+ Add people or groups**.
5. Search for `payg-billing` (your Purview Managed Identity).
6. Assign **Viewer** role (minimum required for scanning).
7. Click **Add**.

> **💡 Why Viewer?** The Purview MSI needs to read workspace metadata and asset schemas. Viewer provides read-only access without modification permissions.

### Verify Security Group Configuration

After completing the steps above:

| Setting | Expected Value |
|---------|----------------|
| **Security Group** | `Purview-Fabric-Scanners` created in Entra ID |
| **Group Members** | Purview Managed Identity (e.g., `payg-billing`) added |
| **Admin API Access** | Enabled for `Purview-Fabric-Scanners` security group |
| **Detailed Metadata** | Enabled for `Purview-Fabric-Scanners` security group |
| **DAX Expressions** | Enabled for `Purview-Fabric-Scanners` security group |
| **Workspace Access** | `payg-billing` has Viewer role on `Fabric-Purview-Lab` workspace |

---

## ✅ Validation Checklist

Before proceeding to Lab 01, verify:

### Fabric Requirements (All Labs)

- [ ] **Fabric Capacity**: Trial is active OR F2 capacity created and can be resumed.
- [ ] **Admin Access**: Can access Fabric Admin portal via [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
- [ ] **Workspace Creation**: Can create a new Fabric workspace.

### Purview Requirements (Labs 06-08)

- [ ] **Portal Access**: Can access [purview.microsoft.com](https://purview.microsoft.com).
- [ ] **Free Version**: Can see Data Governance solutions (Unified Catalog or Data Catalog).
- [ ] **Permissions**: Have Reader or Curator role assigned.
- [ ] **Pay-As-You-Go**: Billing enabled (Step 5) — propagates during Labs 01-05.
- [ ] **Data Map Registration**: Fabric registered as data source (Step 6).
- [ ] **Security Group**: `Purview-Fabric-Scanners` group created with Purview MSI as member (Step 7).
- [ ] **Admin API Access**: Service principal read-only API access enabled for security group (Step 7).
- [ ] **Workspace Access**: Purview MSI (`payg-billing`) has Viewer role on target workspace (Step 7.4).

### General Requirements

- [ ] **Browser Setup**: Signed into correct account in Microsoft Edge or Chrome.
- [ ] **Azure Access** (Path B only): Can access [portal.azure.com](https://portal.azure.com) to manage F2 capacity.

---

## 🔧 Optional: Run Prerequisites Validation Script

A PowerShell script is provided to automate prerequisites checking:

```powershell
# Navigate to the scripts directory
cd "00-Prerequisites-and-Setup/scripts"

# Run the prerequisites check
.\Test-Prerequisites.ps1
```

The script validates:

- PowerShell version (5.1+ or 7+).
- Network connectivity to Microsoft services (Fabric, Purview, Power BI, Azure).
- Azure CLI installation (optional - only used in cleanup lab).
- Sample data files existence.

---

## ❌ Troubleshooting

### Cannot Access Admin Portal

**Symptom**: "You don't have permission to access this page" when selecting **Admin portal** from Fabric settings.

**Resolution**:

1. Verify you're signed in with the correct account at [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
2. Request Fabric Admin role from your Global Admin.
3. Or use a developer/trial tenant where you have full control.

### Fabric Trial Not Available

**Symptom**: "Trial not available for your organization" message.

**Resolution**:

1. Someone else in your org may have already started a trial - check with colleagues.
2. Contact your admin to check trial status and request access.
3. **Use Path B**: Create an F2 capacity in Azure portal (~$0.36/hour with pause/resume).
4. See [Step 3: Path B](#path-b-create-f2-capacity-when-trial-unavailable) for F2 setup instructions.

### Purview Data Governance Not Visible

**Symptom**: Can access Purview portal but don't see Unified Catalog, Data Map, or Data Governance solutions.

**Resolution**:

1. **This is expected with many subscriptions** - Data Governance is a separate product.
2. The **free version** of Purview Data Governance should be available at [purview.microsoft.com](https://purview.microsoft.com).
3. If you see no Data Governance options:
   - Your tenant may not have the free version enabled yet.
   - Try accessing via [web.purview.azure.com](https://web.purview.azure.com) (classic portal).
   - Contact your Global Administrator to enable Purview Data Governance.
4. **For this simulation**: The free version with "live view" is sufficient for Labs 06-08.
5. **For full scanning**: Requires Purview Enterprise (~$360+/month) - see [Purview Enterprise Features](#-purview-enterprise-features-and-costs).

---

## 📚 Related Resources

- [Microsoft Fabric documentation](https://learn.microsoft.com/fabric/)
- [Microsoft Purview documentation](https://learn.microsoft.com/purview/)
- [Fabric licensing overview](https://learn.microsoft.com/fabric/enterprise/licenses)
- [Fabric capacity pause/resume](https://learn.microsoft.com/fabric/enterprise/pause-resume)
- [Purview free version overview](https://learn.microsoft.com/purview/data-governance-free-version)
- [Purview roles and permissions](https://learn.microsoft.com/purview/catalog-permissions)

---

## 💰 Purview Enterprise Features and Costs

> **📖 Detailed Documentation**: For complete enterprise feature documentation, see [ENTERPRISE-GOVERNANCE-CAPABILITIES.md](../ENTERPRISE-GOVERNANCE-CAPABILITIES.md).

### Quick Summary: Free vs Enterprise

| Feature | Free Version | Enterprise |
|---------|--------------|--------------------|
| **Fabric Asset Discovery** | ✅ Live view (automatic) | ✅ Live view + deep scanning |
| **Manual Classification** | ✅ Up to 1,000 assets | ✅ Unlimited |
| **Automatic Classification** | ❌ Not available | ✅ 200+ built-in classifiers |
| **Cost** | **$0** | **~$360-720+/month** |
| **Pause/Resume** | N/A | **❌ Cannot pause** |

### Do You Need Enterprise for This Simulation?

**No** - The free version is sufficient for all labs in this simulation.

- ✅ Live view discovers Fabric assets automatically.
- ✅ Manual classification teaches the same governance concepts.
- ✅ Glossary terms and annotations work in free version.
- ✅ Data lineage is visible for Fabric workloads.

**Consider Enterprise Only If**:

- You need to scan non-Azure/Fabric sources (on-premises, AWS, GCP).
- You require automatic classification at scale (200+ sensitive information types).
- You're building a production data governance solution.

> **⚠️ Warning**: Purview Enterprise **cannot be paused** like Fabric. Once upgraded, billing continues even when idle. See the advanced document for cost optimization strategies.

---

## ➡️ Next Steps

Once all prerequisites are validated, proceed to:

**[Lab 01: Enable Fabric and Create Workspace](../01-Enable-Fabric-Create-Workspace/)**

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Prerequisites and validation steps were verified against Microsoft Learn documentation within **Visual Studio Code**.
