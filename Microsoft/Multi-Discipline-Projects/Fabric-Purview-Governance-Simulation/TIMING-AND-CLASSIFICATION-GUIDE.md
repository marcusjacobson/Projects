# Timing and Classification Reference Guide

This guide provides timing expectations for the free Purview "Live View" discovery feature used in the main simulation labs (00-09).

> **📝 Note**: For enterprise Purview scanning with automatic classification, scheduled scans, and deep analysis, see [ADVANCED-PURVIEW-ENTERPRISE-SCANNING.md](./ADVANCED-PURVIEW-ENTERPRISE-SCANNING.md).

---

## ⏱️ Live View Timing Expectations

The main labs use Purview's **free Live View** feature, which automatically discovers Fabric assets without manual scan configuration.

| Scenario | Expected Duration | Notes |
|----------|-------------------|-------|
| Initial Live View sync | 5-15 minutes | After workspace creation or data changes |
| Asset visibility in catalog | Immediate-15 minutes | Assets appear in Data Catalog automatically |
| Manual classification save | Immediate | Changes visible after saving |
| Glossary term assignment | Immediate | Links appear after saving |
| Lineage visibility | 5-15 minutes | After data transformations complete |

> **💡 Key Insight**: Unlike SharePoint Content Explorer classification (which can take up to **7 days**), Fabric assets appear in Purview almost immediately via Live View!

---

## 🔄 Free vs Enterprise Features

| Feature | Free (Live View) | Enterprise (Paid) |
|---------|------------------|-------------------|
| **Asset Discovery** | ✅ Automatic | ✅ Automatic + deep scanning |
| **Manual Classification** | ✅ Up to 1,000 assets | ✅ Unlimited |
| **Automatic Classification** | ❌ Not available | ✅ 200+ built-in SITs |
| **Scheduled Scans** | ❌ Not available | ✅ Daily/weekly/monthly |
| **Glossary Terms** | ✅ Create and link | ✅ Advanced workflows |
| **Data Lineage** | ✅ Fabric-native | ✅ Cross-source |
| **Cost** | $0 (included) | ~$360+/month |

---

## ⏱️ Timing Comparison: Fabric vs SharePoint

| Aspect | Microsoft Fabric (Live View) | SharePoint/OneDrive |
|--------|------------------------------|---------------------|
| **Discovery Type** | Live View metadata sync | Content Explorer indexing |
| **Typical Wait Time** | Minutes | **Up to 7 days** |
| **Trigger** | Automatic (real-time sync) | System-managed indexing |
| **Classification** | Manual only (free version) | Automatic (after indexing) |

This timing difference makes Fabric an excellent platform for **learning and testing** Purview governance capabilities, as you can see asset discovery results quickly rather than waiting days.

---

## 📋 Troubleshooting Live View

### Assets Not Appearing in Purview

**Common Causes:**

- Wait 5-15 minutes for initial sync after creating new Fabric items.
- Verify you're searching in the correct Purview Data Catalog.
- Check that your Fabric workspace has data (empty workspaces show no assets).
- Refresh the browser or clear cache.

### Manual Classifications Not Saving

**Common Causes:**

- Verify you have **Data Curator** role or higher in Purview.
- Check that you're within the 1,000 asset limit for free manual classification.
- Refresh the asset detail page after saving.

### Lineage Not Showing

**Common Causes:**

- Lineage requires data transformations to have executed at least once.
- Wait 5-15 minutes after pipeline/dataflow execution.
- Some manual operations don't generate lineage automatically.

---

## 🔗 Related Documentation

- [Purview Data Catalog Overview](https://learn.microsoft.com/purview/data-catalog-home)
- [Microsoft Fabric + Purview Integration](https://learn.microsoft.com/fabric/governance/use-microsoft-purview-hub)
- [Enterprise Scanning Guide](./ADVANCED-PURVIEW-ENTERPRISE-SCANNING.md)

---

## 🤖 AI-Assisted Content Generation

This timing and classification reference guide was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. The timing expectations were researched and validated against Microsoft Learn documentation within **Visual Studio Code**.

*AI tools were used to synthesize Microsoft documentation into actionable guidance for Fabric + Purview governance implementations.*
