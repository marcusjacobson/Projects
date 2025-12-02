# Lab 01: Enable Fabric and Create Workspace

## 🎯 Objective

Enable Microsoft Fabric in your tenant and create a governed workspace for the simulation.

**Duration**: 30 minutes

---

## 📋 Prerequisites

- [ ] Lab 00 completed (prerequisites validated).
- [ ] Fabric Administrator or Global Administrator role.
- [ ] Fabric capacity available (trial or paid).

---

## 🔧 Step 1: Enable Microsoft Fabric in Tenant

### Navigate to Admin Portal

1. Go to [admin.powerbi.com](https://admin.powerbi.com).

2. In the left navigation, click **Tenant settings**.

3. Scroll down to find the **Microsoft Fabric** section.

### Enable Fabric for Users

1. Locate **Users can create Fabric items**.

2. Click to expand the setting.

3. Toggle the setting to **Enabled**.

4. Choose the scope:
   - **The entire organization** - Recommended for labs.
   - **Specific security groups** - For controlled rollout.

5. Click **Apply**.

> **💡 Tip**: For a lab environment, enabling for the entire organization is simplest. In production, use security groups for controlled access.

---

## 🔧 Step 2: Configure Admin API Settings (Critical for Purview)

### Enable Service Principal APIs

These settings are **required** for Purview to scan Fabric workloads.

1. In the Admin portal, scroll to **Developer settings** section.

2. Find **Allow service principals to use Power BI APIs**.

3. Enable this setting for your organization or specific groups.

4. Find **Allow service principals to use read-only admin APIs**.

5. Enable this setting as well.

6. Click **Apply** for each setting.

### Enable Fabric Admin API Settings

1. Scroll to **Admin API settings** section.

2. Find **Allow service principals to access read-only admin APIs**.

3. Ensure this is **Enabled**.

4. Find **Enhance admin APIs responses with detailed metadata**.

5. Enable this setting.

6. Click **Apply**.

> **⏱️ Important**: These API settings require approximately **15 minutes to propagate**. Plan a short break before attempting Purview integration in Lab 06.

---

## 🔧 Step 3: Verify Capacity Assignment

### Check Available Capacities

1. In the Admin portal, click **Capacity settings** in the left menu.

2. You should see at least one capacity:
   - **Trial** - Free 60-day capacity.
   - **F2-F64** - Paid Fabric capacities.
   - **P1-P5** - Power BI Premium capacities.

3. Note the capacity name for workspace assignment.

### Start Trial (If No Capacity Available)

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Click **Workspaces** in the left navigation.

3. Click **+ New workspace**.

4. You'll see a prompt to start a Fabric trial.

5. Click **Start trial**.

6. The trial activates immediately.

---

## 🔧 Step 4: Create Fabric Workspace

### Create New Workspace

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Click **Workspaces** in the left navigation.

3. Click **+ New workspace**.

4. Configure the workspace:

   | Setting | Value |
   |---------|-------|
   | **Name** | `Fabric-Purview-Lab` |
   | **Description** | `Hands-on simulation for Fabric + Purview governance` |

5. Expand **Advanced** settings.

6. Under **License mode**, select:
   - **Trial** (if using trial capacity).
   - **Fabric capacity** and select your capacity (if using paid).

7. Click **Apply**.

### Verify Workspace Creation

1. The new workspace should appear in the left navigation.

2. Click on the workspace to open it.

3. Verify the workspace is empty and ready for content.

---

## 🔧 Step 5: Configure Workspace Settings

### Access Workspace Settings

1. In your new workspace, click the **Settings** gear icon (top right).

2. Or click the workspace name → **Workspace settings**.

### Configure Security Settings

1. In workspace settings, click **Security**.

2. Review default role assignments:
   - **Admin**: Full control, can add members.
   - **Member**: Can create/edit content.
   - **Contributor**: Can create/edit but not share.
   - **Viewer**: Read-only access.

3. Your account should have **Admin** role.

### Configure License Info

1. Click **License info** in settings.

2. Verify the workspace is assigned to your Fabric capacity.

3. If not, click **Edit** and select the appropriate capacity.

---

## 🔧 Step 6: Enable Git Integration (Optional)

For version control of Fabric items:

1. In workspace settings, click **Git integration**.

2. You can connect to Azure DevOps or GitHub.

3. For this lab, this is **optional** - skip if not needed.

---

## ✅ Validation Checklist

Before proceeding to Lab 02, verify:

- [ ] Microsoft Fabric is enabled in tenant settings.
- [ ] Admin API settings are configured (service principals enabled).
- [ ] Fabric capacity is available and active.
- [ ] Workspace `Fabric-Purview-Lab` is created.
- [ ] Workspace is assigned to Fabric capacity.
- [ ] You have Admin role on the workspace.

---

## ❌ Troubleshooting

### Cannot Enable Fabric Settings

**Symptom**: Toggle for Fabric settings is greyed out.

**Resolution**:

1. Verify you have Fabric Administrator or Global Administrator role.
2. Check if tenant-level restrictions are in place.
3. Contact your IT administrator if settings are locked.

### Capacity Not Available

**Symptom**: No capacity options when creating workspace.

**Resolution**:

1. Start a Fabric trial from app.fabric.microsoft.com.
2. Request capacity access from your Fabric Administrator.
3. Verify your account is in the capacity admins group.

### Workspace Creation Fails

**Symptom**: Error when clicking Apply to create workspace.

**Resolution**:

1. Check workspace name doesn't contain special characters.
2. Verify workspace name is unique in your organization.
3. Ensure you have permission to create workspaces.

---

## 📚 Related Resources

- [Enable Microsoft Fabric for your organization](https://learn.microsoft.com/fabric/admin/fabric-switch)
- [Fabric workspace roles](https://learn.microsoft.com/fabric/get-started/roles-workspaces)
- [Fabric capacity concepts](https://learn.microsoft.com/fabric/enterprise/licenses)

---

## ➡️ Next Steps

Proceed to:

**[Lab 02: Create Lakehouse and Load Data](../02-Create-Lakehouse-Load-Data/)**

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Tenant configuration steps were verified against Microsoft Learn documentation within **Visual Studio Code**.
