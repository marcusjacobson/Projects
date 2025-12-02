# Lab 08: Sensitivity Labels and Governance

## 🎯 Objective

Apply Microsoft Information Protection (MIP) sensitivity labels to Fabric assets and implement governance policies for data protection.

**Duration**: 45 minutes

---

## 📋 Prerequisites

- [ ] Lab 06-07 completed (Purview integration with classifications).
- [ ] Microsoft 365 E5 or Microsoft Purview Information Protection license.
- [ ] Sensitivity labels configured in Microsoft Purview Compliance Portal.
- [ ] Permissions to apply labels to Fabric items.

---

## 🔧 Step 1: Understand Sensitivity Labels in Fabric

### Labels vs Classifications

| Aspect | Classifications | Sensitivity Labels |
|--------|-----------------|-------------------|
| **Purpose** | Discover sensitive data | Protect sensitive data |
| **Source** | Auto-detected patterns | Manual or policy-applied |
| **Action** | Informational | Enforces protection |
| **Scope** | Column/asset level | Item level |

### Fabric Items That Support Labels

| Item Type | Label Support |
|-----------|--------------|
| **Lakehouse** | ✅ Supported |
| **Warehouse** | ✅ Supported |
| **Semantic Model** | ✅ Supported |
| **Report** | ✅ Supported |
| **Dataflow** | ✅ Supported |
| **KQL Database** | Limited |

---

## 🔧 Step 2: Check Available Sensitivity Labels

### Access Label Settings

1. Go to [app.fabric.microsoft.com](https://app.fabric.microsoft.com).

2. Click the **Settings** gear icon (top right).

3. Select **Admin portal** (if you have admin access).

4. Or go to **Workspace settings** → **Information protection**.

### Common Sensitivity Labels

Your organization may have labels like:

| Label | Description | Protection Level |
|-------|-------------|-----------------|
| **Public** | No restrictions | None |
| **General** | Business data | Low |
| **Confidential** | Sensitive business data | Medium |
| **Highly Confidential** | Critical data | High |

> **📝 Note**: Available labels depend on your organization's configuration. If no labels appear, contact your Microsoft 365 administrator.

---

## 🔧 Step 3: Apply Labels to Lakehouse

### Navigate to Lakehouse

1. Open your `Fabric-Purview-Lab` workspace.

2. Click on `CustomerDataLakehouse`.

### Apply Sensitivity Label

1. In the Lakehouse view, look for the **Sensitivity** label indicator.
   - This may be in the toolbar, header, or settings.

2. Click on the label selector.

3. Choose an appropriate label based on data sensitivity:
   - Since the data contains SSN and financial information, select **Confidential** or higher.

4. Confirm the label application.

### Verify Label Applied

1. Return to the workspace view.

2. The Lakehouse should now show a sensitivity label badge.

3. Hover over the badge to see label details.

---

## 🔧 Step 4: Apply Labels to Warehouse

### Label the Warehouse

1. Click on `AnalyticsWarehouse`.

2. Find the sensitivity label option.

3. Apply the same or equivalent label as the Lakehouse.

### Label Inheritance

> **💡 Key Concept**: When you create shortcuts from a labeled source:

- Shortcuts may inherit the source label.
- Views and queries may show parent label.
- Label inheritance settings vary by organization.

---

## 🔧 Step 5: Apply Labels via Workspace Settings

### Bulk Label Application

1. Go to workspace **Settings** (gear icon).

2. Look for **Sensitivity labels** or **Information protection** section.

3. If available, you can set default labels for:
   - New items created in workspace.
   - Specific item types.

### Workspace Default Label

1. Set a default sensitivity label for the workspace.

2. This ensures all new items receive baseline protection.

3. Users can upgrade labels but may not downgrade (depending on policy).

---

## 🔧 Step 6: View Labels in Purview

### Check Labels in Data Catalog

1. Go to [purview.microsoft.com](https://purview.microsoft.com).

2. Navigate to **Data Catalog** → **Browse**.

3. Search for your Lakehouse.

4. View the asset details.

5. Look for sensitivity label information in:
   - Overview tab
   - Properties tab
   - A dedicated Labels section

### Label Governance Report

1. In Purview, look for **Insights** or **Reports**.

2. Check for sensitivity label distribution reports.

3. View which assets have labels applied.

---

## 🔧 Step 7: Understand Label Enforcement

### What Labels Protect

Depending on label configuration, sensitivity labels can:

| Protection | Description |
|------------|-------------|
| **Visual marking** | Watermarks, headers, footers |
| **Encryption** | Data encrypted at rest |
| **Access control** | Restrict who can open items |
| **Export restrictions** | Block download/export |
| **Sharing restrictions** | Limit sharing capabilities |

### Fabric-Specific Behavior

1. **Reports**: Labels flow to underlying data.

2. **Exports**: Labeled data may be restricted from export.

3. **Sharing**: External sharing may be blocked for labeled items.

---

## 🔧 Step 8: Create Label Policies (Admin Only)

> **⚠️ Note**: This step requires Purview Compliance administrator access.

### Access Compliance Portal

1. Go to [compliance.microsoft.com](https://compliance.microsoft.com).

2. Navigate to **Information Protection** → **Labels**.

### Create Auto-Labeling Policy (Optional)

1. Click **Create auto-labeling policy**.

2. Configure:

   | Setting | Value |
   |---------|-------|
   | **Name** | `Fabric-PII-Auto-Label` |
   | **Conditions** | Contains SSN, Credit Card |
   | **Label to apply** | Confidential |
   | **Scope** | Microsoft Fabric |

3. This automatically labels items containing sensitive data.

> **📝 Lab Note**: You may not have permissions to create policies. This step is informational for understanding enterprise governance.

---

## 🔧 Step 9: Governance Dashboard

### Access Governance Features

1. In Fabric, go to your workspace.

2. Look for **Governance** or **Endorsement** options.

3. Fabric provides governance features including:
   - **Certified**: Officially approved for use.
   - **Promoted**: Recommended for broader use.

### Endorse Your Lakehouse

1. Click on `CustomerDataLakehouse`.

2. Find the endorsement option (may be in item settings or menu).

3. Apply **Certified** or **Promoted** endorsement.

4. Add certification details:
   - Certified by: Your name
   - Certification date: Today
   - Notes: "Lab validation complete"

---

## 🔧 Step 10: Review Protection Status

### Verify All Labels Applied

1. Return to workspace view.

2. Check that each item shows appropriate indicators:
   - Sensitivity labels
   - Endorsement badges
   - Classification info (from Purview)

### Document Label Assignments

Create a summary for your lab:

| Asset | Type | Sensitivity Label | Endorsement |
|-------|------|------------------|-------------|
| CustomerDataLakehouse | Lakehouse | Confidential | Certified |
| AnalyticsWarehouse | Warehouse | Confidential | Promoted |
| IoTEventhouse | Eventhouse | General | None |
| DF_CustomerSegmentation | Dataflow | Confidential | None |

---

## ✅ Validation Checklist

Before proceeding to Lab 09, verify:

- [ ] Understand difference between classifications and sensitivity labels.
- [ ] Applied sensitivity label to Lakehouse.
- [ ] Applied sensitivity label to Warehouse.
- [ ] Labels are visible in workspace view.
- [ ] Understand label protection capabilities.
- [ ] Applied endorsement to at least one item.

---

## ❌ Troubleshooting

### No Sensitivity Labels Available

**Symptom**: Cannot find option to apply sensitivity labels.

**Resolution**:

1. Verify your Microsoft 365 license includes Information Protection.
2. Check if labels are published to your account.
3. Contact your Microsoft 365 administrator.
4. Labels may need to be enabled for Fabric in admin portal.

### Cannot Apply Label

**Symptom**: Label option is grayed out or unavailable.

**Resolution**:

1. Check your permissions on the item.
2. Verify label policy allows you to apply this label.
3. Some items may have inherited labels that can't be changed.
4. Check if item is in a protected capacity.

### Label Not Visible in Purview

**Symptom**: Applied label but Purview doesn't show it.

**Resolution**:

1. Wait for sync (can take 15-30 minutes).
2. Re-run Purview scan to pick up label changes.
3. Check if Fabric-Purview sync is enabled.

---

## 📊 Sensitivity Label Decision Matrix

Use this to determine appropriate labels:

| Data Type | Recommended Label | Rationale |
|-----------|------------------|-----------|
| SSN, Credit Card | Highly Confidential | Regulated PII |
| Email, Phone | Confidential | Personal information |
| Customer names | Confidential | Business-sensitive |
| IoT telemetry | General | Non-sensitive operational |
| Public datasets | Public | No sensitivity |

---

## 📚 Related Resources

- [Sensitivity labels in Fabric](https://learn.microsoft.com/fabric/governance/service-security-sensitivity-label-overview)
- [Microsoft Information Protection](https://learn.microsoft.com/purview/information-protection)
- [Apply sensitivity labels](https://learn.microsoft.com/fabric/governance/apply-sensitivity-labels)
- [Label inheritance](https://learn.microsoft.com/fabric/governance/sensitivity-labels-inheritance)

---

## ➡️ Next Steps

Proceed to:

**[Lab 09: Power BI Visualization](../09-Power-BI-Visualization/)**

> **🎯 Important**: Lab 09 creates Power BI reports from your labeled data, demonstrating how sensitivity flows through the analytics stack.

---

## 🤖 AI-Assisted Content Generation

This lab documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Sensitivity label procedures were verified against Microsoft Information Protection documentation within **Visual Studio Code**.
