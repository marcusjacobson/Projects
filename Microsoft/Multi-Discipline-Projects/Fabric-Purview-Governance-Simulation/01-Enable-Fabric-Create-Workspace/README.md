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

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com) and sign in.

2. Select the **Settings** (gear icon) in the top right corner.

3. Select **Admin portal** from the menu.

4. In the Admin portal, select **Tenant settings**.

### Enable Fabric for Users

1. In Tenant settings, scroll to the **Microsoft Fabric** section.

2. Expand **Users can create Fabric items**.

3. Toggle the setting to **Enabled**.

4. Choose the scope:
   - **The entire organization** - Recommended for labs.
   - **Specific security groups** - For controlled rollout.

5. Select **Apply**.

> **💡 Tip**: For a lab environment, enabling for the entire organization is simplest. In production, use security groups for controlled access.

---

## 🔧 Step 2: Configure Admin API Settings (Critical for Purview)

These settings are **required** for Purview to scan Fabric workloads via service principals.

### Enable Service Principal Settings for Fabric APIs

1. In the Admin portal **Tenant settings**, scroll to the **Developer settings** section.

2. Find **Service principals can use Fabric APIs** and expand it.

   > **📝 Note**: This setting is being replaced by two newer settings. You may see either the legacy setting or the new settings depending on your tenant:
   >
   > - **Service principals can create workspaces, connections, and deployment pipelines**
   > - **Service principals can call Fabric public APIs**

3. Enable the setting(s) for your organization or specific security groups.

4. Select **Apply**.

### Enable Read-Only Admin API Access

1. In Tenant settings, scroll to the **Admin API settings** section.

2. Find **Service principals can access read-only admin APIs** and expand it.

3. Toggle to **Enabled**.

4. (Optional) Specify security groups to limit which service principals can use admin APIs.

5. Select **Apply**.

### Enable Detailed Metadata (Optional but Recommended)

1. Still in **Admin API settings**, find **Enhance admin APIs responses with detailed metadata**.

2. Toggle to **Enabled**.

3. Select **Apply**.

> **⏱️ Important**: These API settings require approximately **15 minutes to propagate**. Plan a short break before attempting Purview integration in Lab 06.

---

## 🔧 Step 3: Verify Capacity Assignment

### Check Available Capacities

1. In the Admin portal left menu, select **Capacity settings**.

2. You should see at least one capacity:
   - **Trial** - Free 60-day Fabric trial capacity.
   - **F2-F2048** - Fabric capacities (F SKUs).
   - **P1-P5** - Power BI Premium capacities (also support Fabric).

3. Note the capacity name for workspace assignment.

### Start Trial (If No Capacity Available)

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Select **Workspaces** in the left navigation.

3. Select **+ New workspace**.

4. You'll see a prompt to start a Fabric trial.

5. Select **Start trial**.

6. The trial activates immediately (60 days free).

---

## 🔧 Step 4: Create Fabric Workspace

### Create New Workspace

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Select **Workspaces** in the left navigation.

3. Select **+ New workspace** (at the bottom of the Workspaces pane).

4. Configure the workspace:

   | Setting | Value |
   |---------|-------|
   | **Name** | `Fabric-Purview-Lab` |
   | **Description** | `Hands-on simulation for Fabric + Purview governance` |

5. Expand **Advanced** settings.

6. Under **License mode**, select:
   - **Trial** (if using trial capacity).
   - **Fabric capacity** and choose your capacity (if using paid F SKU).

7. Select **Apply**.

### Verify Workspace Creation

1. The new workspace appears in the Workspaces list.

2. Select the workspace to open it.

3. Verify the workspace is empty and ready for content.

---

## 🔧 Step 5: Configure Workspace Settings

### Access Workspace Settings

1. In your new workspace, select the **Settings** gear icon (top right).

2. Or select the workspace name → **Workspace settings**.

### Configure Security Settings

1. In workspace settings, select **Security** (or **Manage access** depending on your view).

2. Review default role assignments:

   | Role | Capabilities |
   |------|--------------|
   | **Admin** | Full control, can add/remove members, delete workspace |
   | **Member** | Can create/edit content, add members with lower permissions |
   | **Contributor** | Can create/edit content but cannot share |
   | **Viewer** | Read-only access |

3. Your account should have **Admin** role.

### Configure License Info

1. Select **License info** in settings.

2. Verify the workspace is assigned to your Fabric capacity.

3. If not, select **Edit** and choose the appropriate capacity.

---

## 🔧 Step 6: Enable Git Integration (Optional)

For version control of Fabric items:

1. In workspace settings, select **Git integration**.

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

- Verify you have Fabric Administrator or Global Administrator role.
- Check if tenant-level restrictions are in place.
- Contact your IT administrator if settings are locked.

### Capacity Not Available

**Symptom**: No capacity options when creating workspace.

**Resolution**:

- Start a Fabric trial from [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
- Request capacity access from your Fabric Administrator.
- Verify your account is in the capacity admins group.

### Workspace Creation Fails

**Symptom**: Error when selecting Apply to create workspace.

**Resolution**:

- Check workspace name doesn't contain special characters.
- Verify workspace name is unique in your organization.
- Ensure you have permission to create workspaces.

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
