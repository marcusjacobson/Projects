# Lab 01: Enable Fabric and Create Workspace

## 🎯 Objective

Enable Microsoft Fabric in your tenant and create a governed workspace for the simulation.

**Duration**: 15-20 minutes

---

## 🏗️ What You'll Build

| Item | Description |
|------|-------------|
| **Fabric Tenant Settings** | Enabled Microsoft Fabric capabilities for your organization |
| **Fabric-Purview-Lab** | Governed workspace assigned to Fabric capacity |
| **Capacity Assignment** | Workspace linked to trial or paid capacity |

### Real-World Context

Workspaces are the **fundamental governance boundary** in Microsoft Fabric. In production environments, organizations typically create workspaces aligned to:

- **Business domains** (Sales Analytics, HR Reporting, Finance Data).
- **Environments** (Development, Test, Production).
- **Security boundaries** (sensitive data segregation).
- **Cost centers** (capacity allocation and chargeback).

The workspace you create here mimics a **domain-specific analytics workspace** where a team would build and govern their data assets. Proper workspace design is critical for scalability, security, and cost management.

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

## 🔧 Step 2: Verify Capacity Assignment

### Check Available Capacities

1. In the Admin portal left menu, select **Capacity settings**.

2. You should see at least one capacity:
   - **Trial** - Free 60-day Fabric trial capacity.
   - **F2-F2048** - Fabric capacities (F SKUs).
   - **P1-P5** - Power BI Premium capacities (also support Fabric).

3. Note the capacity name for workspace assignment.

4. If you have a capacity available, proceed to Step 3.

### Start Trial (If No Capacity Available)

1. Close the Admin portal and return to the Fabric home page.

2. Select **Workspaces** in the left navigation.

3. Select **+ New workspace**.

4. You'll see a prompt to start a Fabric trial.

5. Select **Start trial**.

6. The trial activates immediately (60 days free).

---

## 🔧 Step 3: Create Fabric Workspace

### Create New Workspace

1. From the Fabric home page, select **Workspaces** in the left navigation.

2. Select **+ New workspace** (at the bottom of the Workspaces pane).

3. Configure the workspace:

   | Setting | Value |
   |---------|-------|
   | **Name** | `Fabric-Purview-Lab` |
   | **Description** | `Hands-on simulation for Fabric + Purview governance` |

4. Expand **Advanced** settings.

5. Under **License mode**, select:
   - **Trial** (if using trial capacity).
   - **Fabric capacity** and choose your capacity (if using paid F SKU).

6. Select **Apply**.

### Verify Workspace Creation

1. The new workspace appears in the Workspaces list.

2. Select the workspace to open it.

3. Verify the workspace is empty and ready for content.

---

## 🔧 Step 4: Configure Workspace Settings

### Manage Workspace Access

1. In your new workspace, select **Manage access** (top right of the workspace).

2. Review the current access assignments:

   | Role | Capabilities |
   |------|--------------|
   | **Admin** | Full control, can add/remove members, delete workspace |
   | **Member** | Can create/edit content, add members with lower permissions |
   | **Contributor** | Can create/edit content but cannot share |
   | **Viewer** | Read-only access |

3. Your account should have **Admin** role.

4. Select **X** or select outside the panel to close.

### Access Workspace Settings

1. Select **Workspace settings** (top right, next to **Manage access**).

2. Review the available settings categories in the left panel.

### Verify License Info

1. In workspace settings, select **License info** in the left panel.

2. Confirm the workspace shows your Fabric capacity (Trial or F SKU) that you selected during creation.

---

## 🔧 Step 5: Enable Git Integration (Optional)

For version control of Fabric items:

1. In workspace settings, select **Git integration**.

2. You can connect to Azure DevOps or GitHub.

3. For this lab, this is **optional** - skip if not needed.

---

## ✅ Validation Checklist

Before proceeding to Lab 02, verify:

- [ ] Microsoft Fabric is enabled in tenant settings.
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
