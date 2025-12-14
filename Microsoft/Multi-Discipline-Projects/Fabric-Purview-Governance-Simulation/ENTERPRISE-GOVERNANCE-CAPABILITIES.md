# Enterprise Governance Capabilities for Microsoft Fabric

## 🎯 Purpose

This guide explores **advanced governance capabilities** available through Microsoft Purview Enterprise and premium Microsoft 365 licensing. These features extend the foundation you built in Labs 01-09, adding deeper classification, automated protection, and proactive data discovery.

> **📋 What You Built**: Throughout this lab series, you configured DLP policies for real-time sensitive data detection, discovered Fabric assets in the Unified Catalog, and created a governed Power BI report chain—all using capabilities included with Microsoft 365 E5 and free Purview Data Governance.

---

## 🏗️ Your Current Governance Foundation

Before exploring enterprise capabilities, here's what you achieved with standard licensing:

| Capability | What You Configured | How It Works |
|------------|---------------------|--------------|
| **DLP for Fabric** | Policy detecting SSN and Credit Card patterns | Real-time scanning when users access reports |
| **Asset Discovery** | Data Map scan of Fabric workspace | Assets browsable in Unified Catalog with schema metadata |
| **Report Governance** | Power BI report → Semantic Model → Lakehouse | Governed data chain from source to visualization |

### What Real-Time DLP Provides

Your DLP policy detects sensitive data **when accessed**, not by proactively scanning data at rest:

- ✅ Alerts when reports containing SSN/Credit Card data are opened.
- ✅ Policy tips notify users about sensitive content.
- ✅ Simulation mode shows matches without blocking access.
- ✅ Incident reports for compliance documentation.

### What Asset Discovery Provides

Your Data Map scan captured Fabric metadata in the Unified Catalog:

- ✅ Lakehouse tables with column-level schema.
- ✅ Warehouse and semantic model inventory.
- ✅ Searchable data assets across the organization.
- ✅ Schema metadata for data discovery.

---

## 🚀 Enterprise Capabilities That Extend Your Foundation

The following capabilities require additional licensing or subscription costs but build directly on what you've configured.

### Automatic Classification at the Column Level

**What It Adds**: Instead of DLP detecting patterns at access time, enterprise scanning **proactively classifies columns** based on their content.

| Your Current State | Enterprise Addition |
|--------------------|---------------------|
| DLP detects SSN pattern when report opens | Purview labels the `SSN` column as "U.S. Social Security Number" during scheduled scan |
| You know data exists in Unified Catalog | You know **exactly which columns** contain sensitive data before anyone accesses it |
| Classification depends on user activity | Classification happens automatically on schedule |

**Key Benefit**: Proactive visibility. You don't wait for someone to access a report—you know where sensitive data lives across your entire Fabric estate.

**What's Required**: Purview Data Governance Enterprise (~$360+/month consumption-based billing).

---

### Sensitivity Labels That Flow to Fabric Items

**What It Adds**: Apply Microsoft Information Protection (MIP) sensitivity labels to Fabric items, with labels inherited downstream.

| Scenario | How Labels Help |
|----------|-----------------|
| **Lakehouse contains HR data** | Apply "Confidential - HR" label; label flows to semantic models and reports |
| **Report built from multiple sources** | Report inherits the most restrictive label from source data |
| **External sharing attempted** | Label-based policies can block or warn before sensitive data leaves the organization |

**Key Benefit**: Protection travels with the data. A "Highly Confidential" label on a Lakehouse table means every report built from that table inherits protection automatically.

**What's Required**: Microsoft 365 E5 or E5 Information Protection add-on (for label-based DLP enforcement on Fabric items).

---

### Auto-Labeling Based on Content Inspection

**What It Adds**: Automatically apply sensitivity labels when content matches sensitive information types—no manual labeling required.

| Your Current State | Enterprise Addition |
|--------------------|---------------------|
| DLP policy alerts on SSN detection | Auto-labeling applies "PII - SSN" label automatically |
| Manual label application required | Labels applied based on content, not user action |
| Alert-driven response | Proactive protection applied at discovery |

**Key Benefit**: Removes the human bottleneck. When your automated scan finds a new table with SSN data, it gets labeled immediately—not when someone remembers to apply a label.

**What's Required**: Microsoft 365 E5 + Purview Information Protection auto-labeling policies.

---

### Scheduled Deep Scanning with Data Profiling

**What It Adds**: Beyond schema discovery, enterprise scanning can **sample actual data** to detect patterns that don't appear in column names.

| Discovery Type | What It Finds |
|----------------|---------------|
| **Schema-only** (Your current state) | Column named "SSN" appears in catalog |
| **Deep scanning with profiling** | Column named "CustomerID" is flagged as actually containing SSN patterns |

**Key Benefit**: Catches hidden sensitive data. Developers don't always name columns accurately—"data_field_7" might contain credit card numbers. Data profiling finds what schema inspection misses.

**What's Required**: Purview Data Governance Enterprise with L3 (full) scan configuration.

---

### Collections for Hierarchical Data Organization

**What It Adds**: Organize your Fabric assets into a logical hierarchy that reflects your business structure, with permissions inherited per collection.

```text
Your Organization's Data Catalog
├── Finance
│   ├── Fabric-Finance-Prod (Lakehouse, Warehouse)
│   └── Fabric-Finance-Reports (Semantic Models, Reports)
├── Human Resources
│   └── Fabric-HR-Workspace (Highly Confidential)
└── Marketing
    └── Fabric-Marketing-Analytics (Internal Use)
```

**Key Benefit**: Scales governance to enterprise complexity. When your Fabric estate grows to 50+ workspaces, collections let you apply policies, permissions, and governance rules at the business unit level.

**What's Required**: Purview Data Governance Enterprise.

---

### Governance Workflows with Automated Actions

**What It Adds**: Trigger approval processes, notifications, or actions when governance events occur.

| Trigger | Automated Response |
|---------|-------------------|
| New table discovered with SSN classification | Notify Data Protection Officer |
| Access request for HR Lakehouse | Route to HR Manager for approval |
| Classification confidence below 80% | Flag for manual review |
| New Fabric workspace created | Add to default collection, apply baseline policies |

**Key Benefit**: Governance at scale without manual intervention. Your Lab 06 DLP policy alerts you when sensitive data is accessed—workflows can automatically escalate, remediate, or document without waiting for human action.

**What's Required**: Purview Data Governance Enterprise.

---

## 📊 Capability Comparison

| Capability | Your Current Setup | Enterprise Addition |
|------------|-------------------|---------------------|
| **Sensitive data detection** | Real-time (on access) | Proactive (scheduled scans) |
| **Classification** | DLP pattern matching | Column-level labels + data profiling |
| **Protection** | Alerts and policy tips | Auto-labeling + label-based policies |
| **Asset inventory** | Unified Catalog with schema | Collections + hierarchical organization |
| **Governance response** | Manual review of alerts | Automated workflows + approvals |
| **Discovery scope** | Registered Fabric workspaces | 100+ connectors (AWS, GCP, on-premises) |

---

## 💡 When Enterprise Makes Sense

### Your Foundation Is Sufficient When

- ✅ You have a limited number of Fabric workspaces (< 10).
- ✅ Real-time DLP detection meets compliance requirements.
- ✅ Manual label application is manageable.
- ✅ Schema-level discovery provides enough visibility.
- ✅ Alert-based governance response is acceptable.

### Consider Enterprise When

- Your Fabric estate spans **multiple business units** with different governance requirements.
- Compliance mandates require **proactive classification** (know where PII exists before it's accessed).
- You need **automated protection** that doesn't depend on user behavior.
- Data volume makes **manual labeling impractical**.
- You're integrating Fabric with **non-Microsoft data sources** (AWS S3, Snowflake, on-premises databases).

---

## 💰 Cost Considerations

### What You're Already Using

| Component | Cost | Included With |
|-----------|------|---------------|
| DLP for Fabric | Pay-per-scan | Microsoft 365 E5 |
| Unified Catalog | Free | Purview Data Governance (free tier) |
| Data Map scanning | Free | Purview Data Governance (free tier) |
| Sensitivity labels | Included | Microsoft 365 E5 |

### Enterprise Additions

| Component | Approximate Cost | What It Enables |
|-----------|------------------|-----------------|
| **Purview Enterprise** | ~$360-720/month (consumption) | Auto-classification, collections, workflows, deep scanning |
| **E5 Compliance add-on** | ~$12/user/month | Advanced auto-labeling, enhanced DLP policies |

> **⚠️ Important**: Unlike Microsoft Fabric, Purview Enterprise **cannot be paused**. Billing is continuous based on Data Map size.

---

## 🔗 How Enterprise Capabilities Connect

```text
┌─────────────────────────────────────────────────────────────────┐
│                 ENTERPRISE GOVERNANCE STACK                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Your Foundation (Labs 01-09)          Enterprise Extensions    │
│   ─────────────────────────────         ─────────────────────   │
│                                                                  │
│   Lakehouse with SSN/CC data    →    Auto-classified columns     │
│           ↓                                   ↓                  │
│   DLP detects on access         →    Proactive scheduled scans   │
│           ↓                                   ↓                  │
│   Alert to admin                →    Automated workflow action   │
│           ↓                                   ↓                  │
│   Manual label application      →    Auto-labeling applied       │
│           ↓                                   ↓                  │
│   Assets in Unified Catalog     →    Organized in Collections    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📚 Next Steps for Exploration

If your organization is considering enterprise governance capabilities:

1. **Evaluate current pain points**: Is real-time DLP sufficient, or do you need proactive classification?

2. **Assess Fabric growth trajectory**: Will your workspace count remain manageable for manual governance?

3. **Review compliance requirements**: Do regulations require you to **know** where PII exists, or just **detect** when it's accessed?

4. **Calculate total cost of ownership**: Enterprise licensing vs. manual governance overhead.

5. **Pilot with limited scope**: If you proceed, start with one business unit's workspaces before expanding.

### Related Microsoft Documentation

- [Microsoft Purview Data Governance Pricing](https://azure.microsoft.com/pricing/details/purview/)
- [Sensitivity Labels for Fabric](https://learn.microsoft.com/fabric/governance/information-protection)
- [Auto-Labeling Policies](https://learn.microsoft.com/purview/apply-sensitivity-label-automatically)
- [Purview Collections](https://learn.microsoft.com/purview/how-to-create-and-manage-collections)
- [Purview Workflows](https://learn.microsoft.com/purview/concept-workflow)

---

## 🤖 AI-Assisted Content Generation

This guide was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Enterprise capabilities were summarized from Microsoft Learn documentation within **Visual Studio Code**, with focus on how they extend the governance foundation built in Labs 01-09.
