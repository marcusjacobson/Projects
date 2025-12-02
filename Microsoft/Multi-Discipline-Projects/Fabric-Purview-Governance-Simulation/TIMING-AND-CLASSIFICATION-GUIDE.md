# Timing and Classification Reference Guide

This guide provides detailed timing expectations for Microsoft Purview scanning of Fabric workloads and recommendations for production environments.

---

## ⏱️ Quick Reference: Scan Timing Expectations

| Scenario | Expected Duration | Notes |
|----------|-------------------|-------|
| Admin API propagation | ~15 minutes | Required after enabling/modifying Fabric API settings |
| Small workspace scan (< 100 assets) | 5-15 minutes | Typical lab environment |
| Medium workspace scan (100-500 assets) | 15-45 minutes | Small production workloads |
| Large workspace scan (500-1000 assets) | 45-90 minutes | Medium production workloads |
| Enterprise workspace scan (1000+ assets) | 1-4 hours | Large production environments |
| Ingestion completion | 5-15 minutes | After scan job finishes |
| Catalog asset visibility | Immediate-15 minutes | Assets appear in Unified Catalog |

> **💡 Key Insight**: Unlike SharePoint Content Explorer classification (which can take up to **7 days**), Fabric Purview scans are significantly faster because they scan metadata and schema directly from the Fabric service rather than waiting for content indexing.

---

## 🔄 On-Demand vs Scheduled Scans

### On-Demand ("Once") Scans

**Best For**: Learning, testing, initial validation, ad-hoc governance checks

| Advantage | Description |
|-----------|-------------|
| **Immediate control** | Run scans when needed, not on a schedule |
| **Faster feedback** | Get classification results in minutes, not days |
| **Learning-friendly** | Perfect for hands-on labs and POCs |
| **Cost visibility** | See scan cost before committing |

| Limitation | Description |
|------------|-------------|
| **Manual intervention** | Must trigger each scan manually |
| **No automatic updates** | New assets require new scan |
| **Point-in-time only** | Snapshot of current state |

**When to Use On-Demand Scans:**

- During initial Fabric + Purview integration setup.
- When validating classification accuracy.
- After significant data model changes.
- For compliance audits requiring current-state assessment.
- In lab/learning environments (like this project).

### Scheduled ("Recurring") Scans

**Best For**: Production governance, ongoing compliance, automated monitoring

| Advantage | Description |
|-----------|-------------|
| **Automated governance** | Set and forget - scans run automatically |
| **Change detection** | Catches new/modified assets over time |
| **Consistent compliance** | Regular assessment without manual effort |
| **Audit trail** | Scan history for compliance documentation |

| Limitation | Description |
|------------|-------------|
| **Delayed visibility** | Must wait for scheduled run |
| **Resource consumption** | Scans consume capacity even when unnecessary |
| **Configuration overhead** | Requires initial scheduling setup |

**When to Use Scheduled Scans:**

- Production environments with ongoing data ingestion.
- Compliance requirements mandating regular classification.
- Multi-team environments where manual scanning is impractical.
- Integration with security operations workflows.

---

## 📊 Scan Levels (L1, L2, L3)

Microsoft Purview supports three levels of scanning, each providing different depth of metadata capture:

| Level | Captures | Use Case | Performance Impact |
|-------|----------|----------|-------------------|
| **L1 - Basic** | Asset name, size, timestamps, fully qualified name | Quick inventory, asset discovery | Fastest |
| **L2 - Schema** | L1 + column/field schema extraction | Structure discovery, data modeling | Moderate |
| **L3 - Classification** | L2 + data sampling + SIT classification | Full governance, compliance | Slowest |

### Scan Level Recommendations

| Scenario | Recommended Level | Rationale |
|----------|-------------------|-----------|
| Initial asset inventory | L1 | Fast overview of available data |
| Schema documentation | L2 | Capture structure without classification overhead |
| Governance/compliance | L3 | Full classification for sensitive data discovery |
| Large enterprise scans | L2 initially, L3 for sensitive sources | Balance speed with compliance needs |
| Learning/labs (this project) | L3 (Auto-detect) | Experience full classification capabilities |

### Fabric-Specific Considerations

> **⚠️ Preview Limitation**: For Fabric items besides Power BI, only **item-level metadata and lineage** can be scanned. For **Lakehouse tables and files**, sub-item level metadata scanning is available in preview.

This means:

- Lakehouse files and tables: Full schema and classification available.
- Warehouse tables: Full schema and classification available.
- KQL Database: Item-level metadata, limited sub-item scanning.
- Notebooks, Pipelines, Dataflows: Item-level metadata and lineage only.

---

## 🏢 Production Environment Recommendations

### Initial Deployment Pattern

1. **Week 1: Discovery Scan (L1)**
   - Run L1 scan across all Fabric workspaces.
   - Identify scope and asset count.
   - Estimate classification scan duration.

2. **Week 2: Priority Classification (L3)**
   - Run L3 scan on workspaces containing sensitive data.
   - Validate classification accuracy.
   - Review false positives/negatives.

3. **Week 3+: Scheduled Governance**
   - Configure recurring scans (weekly or monthly).
   - Establish scan monitoring and alerting.
   - Integrate with security operations workflows.

### Scan Frequency Guidelines

| Data Change Rate | Recommended Frequency | Notes |
|------------------|----------------------|-------|
| **High** (daily ingestion) | Weekly | Catches new sensitive data quickly |
| **Medium** (weekly updates) | Bi-weekly | Balance between coverage and cost |
| **Low** (monthly changes) | Monthly | Sufficient for stable data sources |
| **Compliance-driven** | As required | Match regulatory requirements |

### Cost Optimization Strategies

1. **Scope Carefully**: Scan only workspaces with sensitive data, not all Fabric content.
2. **Use Scan Levels Wisely**: L1 for inventory, L3 only where classification is needed.
3. **Off-Peak Scheduling**: Run large scans during low-activity periods.
4. **Incremental Scanning**: Enable incremental scans to skip unchanged assets.

---

## 🔍 Classification Accuracy

### Built-In Sensitive Information Types (SITs)

Microsoft Purview includes **200+ pre-configured SITs** that automatically detect sensitive data patterns:

| Category | Example SITs |
|----------|--------------|
| **Personal Identifiers** | SSN, Driver's License, Passport Number, National ID |
| **Financial Data** | Credit Card, Bank Account, ABA Routing Number |
| **Health Information** | Medical Record Number, Health Insurance ID |
| **Legal/Compliance** | Tax ID (ITIN), EU Tax Numbers, GDPR identifiers |
| **Credentials** | Passwords, API Keys, Connection Strings |

### Confidence Levels

Classifications are assigned confidence levels:

| Level | Meaning | Recommended Action |
|-------|---------|-------------------|
| **High (75-100%)** | Strong pattern match with multiple corroborating evidence | Trust classification, apply labels |
| **Medium (65-74%)** | Good pattern match, some evidence | Review before labeling |
| **Low (0-64%)** | Weak match, limited evidence | Manual verification required |

### Improving Classification Accuracy

1. **Custom Scan Rule Sets**: Exclude file types that generate false positives.
2. **Ignore Patterns**: Use regex to exclude known non-sensitive patterns.
3. **Custom SITs**: Create organization-specific patterns for internal identifiers.
4. **Review and Feedback**: Use classification feedback to improve accuracy over time.

---

## ⏱️ Timing Comparison: Fabric vs SharePoint

| Aspect | Microsoft Fabric | SharePoint/OneDrive |
|--------|------------------|---------------------|
| **Classification Type** | Data Map scan (metadata + schema + classification) | Content Explorer indexing |
| **Typical Wait Time** | Minutes to hours | **Up to 7 days** |
| **Control** | On-Demand or Scheduled | Primarily scheduled indexing |
| **Trigger** | User-initiated or recurring schedule | System-managed indexing |
| **Scan Customization** | Scope, schedule, rule sets | Limited configuration |

This timing difference makes Fabric an excellent platform for **learning and testing** Purview classification capabilities, as you can see results quickly rather than waiting days.

---

## 📋 Troubleshooting Timing Issues

### Scan Not Starting

- **Check Admin API settings**: Ensure "Allow service principals to use Power BI APIs" is enabled.
- **Wait 15 minutes**: API settings require propagation time.
- **Verify permissions**: Confirm Managed Identity or Service Principal has required roles.

### Scan Taking Longer Than Expected

- **Large asset count**: More assets = longer scan time.
- **L3 classification**: Data sampling adds time; consider L2 for initial scans.
- **Network/service issues**: Check Azure status for any service disruptions.

### Classification Results Not Appearing

- **Ingestion delay**: Wait 5-15 minutes after scan completion.
- **Browser cache**: Refresh or use incognito mode.
- **Catalog sync**: Data Map to Unified Catalog sync may have brief delays.

---

## 🔗 Related Documentation

- [Microsoft Purview Scanning Overview](https://learn.microsoft.com/purview/concept-scans-and-ingestion)
- [Register and Scan Fabric Tenant](https://learn.microsoft.com/purview/register-scan-fabric-tenant)
- [Scan Rule Sets](https://learn.microsoft.com/purview/create-a-scan-rule-set)
- [Classification Best Practices](https://learn.microsoft.com/purview/apply-classifications)

---

## 🤖 AI-Assisted Content Generation

This timing and classification reference guide was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. The timing expectations, scan level recommendations, and production patterns were researched and validated against Microsoft Learn documentation within **Visual Studio Code**.

*AI tools were used to synthesize Microsoft documentation into actionable guidance for Fabric + Purview governance implementations.*
