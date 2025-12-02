# Lab 00: Prerequisites and Environment Setup

## 🎯 Objective

Validate licensing, permissions, and environment readiness before beginning the Fabric + Purview simulation.

**Duration**: 30 minutes

---

## 📋 Prerequisites

Before starting this lab, ensure you have:

- [ ] Access to a Microsoft 365 tenant with admin permissions.
- [ ] Web browser (Microsoft Edge or Google Chrome recommended).
- [ ] Internet connectivity.

---

## 🔧 Step 1: Verify Microsoft 365 Licensing

### Required Licenses

The following licenses support Microsoft Fabric and Purview integration:

| License Type | Fabric Access | Purview Access | Recommended |
|--------------|---------------|----------------|-------------|
| **Microsoft 365 E5** | ✅ Full | ✅ Full | ✅ Best for labs |
| **Microsoft 365 E3 + Fabric** | ✅ Full | ⚠️ Limited | ✅ Good alternative |
| **Fabric Trial** | ✅ 60 days | ⚠️ Limited | ✅ Free option |
| **Power BI Premium Per User** | ⚠️ Limited | ❌ No | ❌ Not sufficient |

### Verify Your License

1. Go to [admin.microsoft.com](https://admin.microsoft.com).

2. Navigate to **Billing** → **Licenses**.

3. Look for one of the following:
   - Microsoft 365 E5
   - Microsoft Fabric (Free/Pro/Premium)
   - Power BI Premium Per User (can start Fabric trial)

4. If you don't have a Fabric license, you can start a **60-day free trial**:
   - Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
   - Click **Start trial** when prompted.
   - The trial includes full Fabric capacity for 60 days.

> **💡 Tip**: For this simulation, a Fabric trial is sufficient. You don't need a paid capacity to complete all labs.

---

## 🔧 Step 2: Verify Admin Permissions

### Required Permissions

| Permission | Purpose | How to Verify |
|------------|---------|---------------|
| **Fabric Administrator** | Enable Fabric, configure tenant settings | Admin Portal access |
| **Purview Data Curator** | Register sources, run scans | Purview Data Map access |
| **Workspace Admin** | Create and manage Fabric workspaces | Power BI service |

### Verify Fabric Admin Access

1. Go to [admin.powerbi.com](https://admin.powerbi.com).

2. If you can access the **Admin portal**, you have Fabric/Power BI admin rights.

3. Navigate to **Tenant settings** to verify you can view and modify settings.

> **⚠️ Not an Admin?** Contact your IT administrator to request temporary admin access for this simulation, or use a developer/trial tenant where you have full control.

### Verify Purview Access

1. Go to [purview.microsoft.com](https://purview.microsoft.com).

2. Navigate to **Data Map** → **Sources**.

3. If you can view the Data Map, you have at least read access.

4. To run scans, you need **Data Source Administrator** role:
   - In Purview, go to **Data Map** → **Collections**.
   - Select the root collection.
   - Click **Role assignments**.
   - Verify your account has **Data source administrators** role.

---

## 🔧 Step 3: Verify Fabric Capacity

Microsoft Fabric requires a capacity (compute resources) to run workloads.

### Check Existing Capacity

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Click the **Settings** gear icon (top right).

3. Select **Admin portal** → **Capacity settings**.

4. Look for available capacities:
   - **Trial capacity**: Free 60-day trial.
   - **F2-F64**: Paid Fabric capacities.
   - **P1-P5**: Power BI Premium capacities (support Fabric).

### Start a Trial Capacity (If Needed)

If no capacity is available:

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Click on any workspace or try to create a new item.

3. You'll see a prompt: **"Start a Microsoft Fabric trial"**.

4. Click **Start trial**.

5. The trial capacity activates immediately and lasts 60 days.

> **💡 Tip**: Trial capacity is shared across your organization. If someone else started a trial, you can use it.

---

## 🔧 Step 4: Verify Purview Data Map Access

### Navigate to Purview Data Map

1. Go to [purview.microsoft.com](https://purview.microsoft.com).

2. In the left navigation, click **Data Map**.

3. You should see the Data Map interface with:
   - **Sources** tab.
   - **Classifications** tab.
   - **Scan rule sets** tab.

### Verify Registration Permissions

1. In Data Map, click **Register**.

2. You should see a list of available data sources including:
   - Azure Data Lake Storage
   - Azure SQL Database
   - Power BI
   - **Fabric** (if available in your region)

> **⚠️ Fabric Source Not Visible?** Fabric as a Purview data source is in preview. It may not be available in all regions or tenants. Check the [Microsoft documentation](https://learn.microsoft.com/purview/register-scan-fabric-tenant) for current availability.

---

## 🔧 Step 5: Browser and Environment Setup

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

## ✅ Validation Checklist

Before proceeding to Lab 01, verify:

- [ ] **Licensing**: Microsoft 365 E5 or Fabric trial is active.
- [ ] **Admin Access**: Can access admin.powerbi.com Admin portal.
- [ ] **Purview Access**: Can access purview.microsoft.com Data Map.
- [ ] **Fabric Capacity**: Trial or paid capacity is available.
- [ ] **Browser Setup**: Signed into correct account in supported browser.

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

- Azure CLI installation and authentication.
- PowerShell module versions.
- Service connectivity.
- Basic permission checks.

---

## ❌ Troubleshooting

### Cannot Access Admin Portal

**Symptom**: "You don't have permission to access this page" at admin.powerbi.com.

**Resolution**:

1. Verify you're signed in with the correct account.
2. Request Fabric Admin role from your Global Admin.
3. Or use a developer/trial tenant where you have full control.

### Fabric Trial Not Available

**Symptom**: "Trial not available for your organization" message.

**Resolution**:

1. Someone else in your org may have already started a trial.
2. Contact your admin to check trial status.
3. Request access to existing trial capacity.

### Purview Data Map Empty

**Symptom**: Can access Purview but Data Map shows no sources.

**Resolution**:

1. This is normal for new/empty Purview accounts.
2. You'll register Fabric as a source in Lab 06.
3. Verify you have Data Source Administrator role.

---

## 📚 Related Resources

- [Microsoft Fabric documentation](https://learn.microsoft.com/fabric/)
- [Microsoft Purview documentation](https://learn.microsoft.com/purview/)
- [Fabric licensing overview](https://learn.microsoft.com/fabric/enterprise/licenses)
- [Purview roles and permissions](https://learn.microsoft.com/purview/catalog-permissions)

---

## ➡️ Next Steps

Once all prerequisites are validated, proceed to:

**[Lab 01: Enable Fabric and Create Workspace](../01-Enable-Fabric-Create-Workspace/)**

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Prerequisites and validation steps were verified against Microsoft Learn documentation within **Visual Studio Code**.
