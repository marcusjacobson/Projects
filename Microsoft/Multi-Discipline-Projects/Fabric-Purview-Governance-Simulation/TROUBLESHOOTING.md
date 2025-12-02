# Troubleshooting Guide

This guide covers common issues encountered during Microsoft Fabric + Purview integration and provides resolution steps.

---

## 🔍 Quick Issue Finder

| Issue Category | Common Symptoms | Jump To |
|----------------|-----------------|---------|
| **Fabric Enablement** | Cannot see Fabric workloads, capacity errors | [Fabric Issues](#fabric-enablement-issues) |
| **Workspace Creation** | Capacity assignment fails, permission errors | [Workspace Issues](#workspace-issues) |
| **Data Loading** | Upload failures, table creation errors | [Data Loading Issues](#data-loading-issues) |
| **Purview Scanning** | Scan not starting, authentication failures | [Purview Scanning Issues](#purview-scanning-issues) |
| **Classification** | No results, missing SITs, accuracy problems | [Classification Issues](#classification-issues) |
| **Sensitivity Labels** | Labels not appearing, policy errors | [Labeling Issues](#sensitivity-labeling-issues) |
| **Power BI** | Connection failures, DirectLake errors | [Power BI Issues](#power-bi-issues) |

---

## 🏭 Fabric Enablement Issues

### Fabric Option Not Visible in Admin Portal

**Symptoms:**

- Cannot find Microsoft Fabric settings in M365 Admin Center.
- Fabric workloads not appearing in Power BI service.

**Resolution:**

1. Verify your tenant has appropriate licensing (Microsoft 365 E5, F3, or Fabric capacity).
2. Check if Fabric is enabled at the tenant level:
   - Go to **admin.powerbi.com** → **Tenant settings** → **Microsoft Fabric**.
   - Ensure **Users can create Fabric items** is enabled.
3. If using trial, ensure trial capacity is properly activated.
4. Wait up to 24 hours for license propagation in new tenants.

### Fabric Capacity Not Available

**Symptoms:**

- "No capacity available" error when creating workspace.
- Cannot assign workspace to Fabric capacity.

**Resolution:**

1. **For Trials**: Start a Fabric trial from [app.fabric.microsoft.com](https://app.fabric.microsoft.com).
2. **For Paid**: Verify Fabric capacity (F2+) is provisioned in Azure portal.
3. Ensure your account has **Capacity Admin** or **Contributor** role on the capacity.
4. Check capacity is in a region supported by your subscription.

---

## 🗂️ Workspace Issues

### Cannot Create Workspace

**Symptoms:**

- "You don't have permission to create workspaces" error.
- Workspace creation option greyed out.

**Resolution:**

1. Verify tenant settings allow workspace creation:
   - **admin.powerbi.com** → **Tenant settings** → **Workspace settings**.
   - Check **Create workspaces** permission.
2. Ensure you're not in a restricted security group that blocks workspace creation.
3. Try creating from [app.fabric.microsoft.com](https://app.fabric.microsoft.com) instead of Power BI service.

### Workspace Not Assigned to Capacity

**Symptoms:**

- Fabric items cannot be created in workspace.
- "This workspace is not on a Fabric capacity" message.

**Resolution:**

1. Open workspace settings → **License info**.
2. Select **Trial** or your provisioned Fabric capacity.
3. If capacity not listed:
   - Verify you have capacity admin/contributor role.
   - Check capacity hasn't reached its limit.
   - Ensure capacity is running (not paused).

---

## 📊 Data Loading Issues

### File Upload Fails in Lakehouse

**Symptoms:**

- Drag-and-drop upload hangs or errors.
- "Upload failed" message without details.

**Resolution:**

1. **Check file size**: Maximum single file is 5 GB via UI.
2. **Check file format**: Ensure file is supported (.csv, .parquet, .json, etc.).
3. **Browser issues**: Try different browser or clear cache.
4. **Use OneLake File Explorer**: Install OneLake client for large file uploads.
5. **Alternative**: Use notebook upload or Data Factory pipeline.

### Table Creation Fails from CSV

**Symptoms:**

- "Load to Tables" operation fails.
- Table created but empty.

**Resolution:**

1. **Check CSV format**:
   - Ensure proper header row.
   - Verify consistent column counts.
   - Check for special characters in headers.
2. **Encoding issues**: Save CSV as UTF-8 encoding.
3. **Schema inference**: Large files may need explicit schema definition.
4. **Try Notebook approach**:

   ```python
   df = spark.read.csv("Files/yourfile.csv", header=True, inferSchema=True)
   df.write.format("delta").saveAsTable("your_table_name")
   ```

### Data Not Appearing in SQL Endpoint

**Symptoms:**

- Tables exist in Lakehouse but not visible in SQL endpoint.
- Queries return empty results.

**Resolution:**

1. **Wait for sync**: SQL endpoint sync can take a few minutes.
2. **Refresh metadata**: In SQL endpoint, right-click → **Refresh**.
3. **Check table format**: Only Delta tables appear in SQL endpoint (not raw files).
4. **Verify table creation**: Ensure table was saved as Delta format.

---

## 🔐 Purview Scanning Issues

### Cannot Register Fabric Tenant in Purview

**Symptoms:**

- Fabric not appearing as data source option.
- Registration fails with permission error.

**Resolution:**

1. **Verify Purview permissions**: You need **Data Source Administrator** role.
2. **Check Fabric Admin API settings**:
   - **admin.powerbi.com** → **Tenant settings** → **Admin API settings**.
   - Enable **Allow service principals to use Power BI APIs**.
   - Enable **Allow service principals to use read-only admin APIs**.
3. **Wait 15 minutes**: API settings require propagation time.
4. **Verify Purview account**: Ensure you're using the correct Purview account.

### Scan Authentication Fails

**Symptoms:**

- "Authentication failed" when running scan.
- Scan stuck in "Queued" state.

**Resolution:**

1. **For Managed Identity**:
   - Verify Purview Managed Identity has **Fabric Administrator** role.
   - Check Managed Identity is enabled on Purview account.
2. **For Service Principal**:
   - Verify client secret hasn't expired.
   - Check Service Principal is added to Purview.
   - Ensure correct permissions granted.
3. **For Delegated Auth**:
   - Verify admin consent was granted.
   - Check user has appropriate Fabric permissions.

### Scan Completes But No Assets Found

**Symptoms:**

- Scan shows "Completed" but 0 assets discovered.
- Data Map is empty after scan.

**Resolution:**

1. **Check scan scope**: Verify workspace is included in scan scope.
2. **Verify data exists**: Ensure Lakehouse/Warehouse has actual data.
3. **Check scan rule set**: Ensure rule set includes relevant file types.
4. **Review scan logs**: Check for warnings or errors in scan details.
5. **Wait for ingestion**: Assets appear after ingestion completes (5-15 min).

---

## 🏷️ Classification Issues

### No Classifications Appearing

**Symptoms:**

- Assets show in catalog but no classifications.
- Classification column is empty.

**Resolution:**

1. **Verify scan level**: Use L3 (or Auto-detect) for classification.
2. **Check scan rule set**: Ensure classification rules are enabled.
3. **Data format**: Classification works on structured data (tables, columns).
4. **Wait for ingestion**: Classification appears after full ingestion.
5. **Sample data**: Ensure data contains recognizable sensitive patterns.

### Wrong or Missing SITs Detected

**Symptoms:**

- Expected SIT not detected.
- Too many false positives.

**Resolution:**

1. **Verify data format**: Ensure SSN, credit cards, etc. match expected patterns.
2. **Confidence levels**: Check if classifications exist at different confidence levels.
3. **Custom scan rule set**: Create custom rule set with specific SITs enabled.
4. **Data quality**: Ensure sample data has proper formatting (no extra characters).

---

## 🔖 Sensitivity Labeling Issues

### Labels Not Appearing in Fabric

**Symptoms:**

- Sensitivity labels not visible on Fabric items.
- Cannot apply labels to assets.

**Resolution:**

1. **Verify licensing**: Information Protection requires Microsoft 365 E5 or equivalent.
2. **Check label policies**: Ensure labels are published to your user/group.
3. **Enable in Fabric**:
   - **admin.powerbi.com** → **Tenant settings** → **Information protection**.
   - Enable **Allow users to apply sensitivity labels for content**.
4. **Wait for sync**: Label policies can take up to 24 hours to propagate.

### Label Policy Not Applying

**Symptoms:**

- Auto-labeling not working.
- Manual labels not sticking.

**Resolution:**

1. **Check policy priority**: Higher priority policies override lower.
2. **Verify conditions**: Auto-label conditions must match data patterns.
3. **Label scope**: Ensure label is scoped to include Fabric items.
4. **Inheritance**: Check if parent item label is being inherited.

---

## 📊 Power BI Issues

### Cannot Connect to Lakehouse

**Symptoms:**

- "Cannot connect to data source" in Power BI.
- DirectLake connection fails.

**Resolution:**

1. **Verify workspace assignment**: Power BI and Lakehouse must be in same workspace (for DirectLake).
2. **Check permissions**: Ensure you have at least Viewer role on Lakehouse.
3. **SQL endpoint**: For external connections, use SQL connection string.
4. **Firewall**: Check if corporate firewall blocks Fabric endpoints.

### DirectLake Mode Not Working

**Symptoms:**

- Reports falling back to import mode.
- "Direct query required" message.

**Resolution:**

1. **Data format**: DirectLake requires Delta tables (not raw files).
2. **Same workspace**: Semantic model and Lakehouse must be in same workspace.
3. **Capacity tier**: DirectLake may require certain capacity tiers.
4. **Model complexity**: Some DAX functions force import mode.

---

## 🛠️ General Troubleshooting Steps

### Clear Browser Cache and Cookies

1. Open browser developer tools (F12).
2. Right-click refresh button → **Empty cache and hard reload**.
3. Or use incognito/private browsing mode.

### Check Service Health

1. Visit [status.fabric.microsoft.com](https://status.fabric.microsoft.com).
2. Check [admin.microsoft.com/servicestatus](https://admin.microsoft.com/servicestatus) for M365 services.
3. Review Azure status at [status.azure.com](https://status.azure.com).

### Collect Diagnostic Information

When reporting issues, gather:

1. **Workspace ID**: Workspace settings → About.
2. **Activity ID**: From error message or browser network tab.
3. **Timestamp**: Exact time of issue (with timezone).
4. **Screenshots**: Error messages and UI state.
5. **Browser/client info**: Version and type.

---

## 📞 Getting Help

### Microsoft Support Channels

| Channel | Best For |
|---------|----------|
| [Fabric Community](https://community.fabric.microsoft.com/) | General questions, community expertise |
| [Microsoft Q&A](https://learn.microsoft.com/answers/) | Technical questions with official responses |
| [Azure Support](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade) | Production issues, SLA-bound support |
| [Purview Community](https://techcommunity.microsoft.com/t5/microsoft-purview/ct-p/MicrosoftPurview) | Purview-specific discussions |

### Documentation Resources

| Resource | Link |
|----------|------|
| Fabric Documentation | [learn.microsoft.com/fabric/](https://learn.microsoft.com/fabric/) |
| Purview Documentation | [learn.microsoft.com/purview/](https://learn.microsoft.com/purview/) |
| Known Issues | [Fabric Known Issues](https://learn.microsoft.com/fabric/get-started/fabric-known-issues) |

---

## 🤖 AI-Assisted Content Generation

This troubleshooting guide was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. The issue categories, symptoms, and resolutions were compiled from Microsoft documentation and common support scenarios within **Visual Studio Code**.

*AI tools were used to organize troubleshooting patterns for Fabric + Purview integration issues.*
