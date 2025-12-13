# Advanced Purview Enterprise Scanning for Microsoft Fabric

## 🎯 Overview

This document covers **advanced Microsoft Purview Data Governance Enterprise features** for scanning and classifying Microsoft Fabric data sources. These features require a separate Azure subscription with consumption-based billing and are **not included in the standard simulation labs**.

> **⚠️ Important**: The main simulation labs (00-10) are designed to work with the **free version** of Purview Data Governance. This document is supplementary content for organizations with enterprise Purview subscriptions.

---

## 📋 When Do You Need Enterprise?

### Free Version (Used in Main Labs)

The free version of Purview Data Governance provides:

- ✅ **Live View Discovery**: Fabric assets automatically appear in Purview.
- ✅ **Manual Classification**: Add classifications to up to 1,000 assets.
- ✅ **Glossary Terms**: Create and assign business terms.
- ✅ **Basic Lineage**: View Fabric-native lineage relationships.
- ✅ **Asset Annotations**: Add descriptions and owners.

### Enterprise Version (This Document)

Enterprise Purview Data Governance adds:

- ✅ **Deep Scanning**: Schema-level analysis with column profiling.
- ✅ **Automatic Classification**: 200+ built-in Sensitive Information Types (SITs).
- ✅ **Scheduled Scans**: Automated recurring discovery and classification.
- ✅ **Collections**: Hierarchical asset organization.
- ✅ **Workflows**: Approval processes and business workflows.
- ✅ **Unlimited Assets**: No annotation limits.
- ✅ **100+ Connectors**: Scan non-Azure sources (AWS, GCP, on-premises).

---

## 💰 Enterprise Pricing

### Billing Model

Purview Enterprise uses **Azure consumption-based billing**:

| Component | Description | Approximate Cost |
|-----------|-------------|------------------|
| **Capacity Unit (CU)** | Throughput + storage bundle | ~$0.50-$1.00/hour |
| **Minimum (1 CU × 24h × 30d)** | Monthly minimum | ~$360-$720/month |
| **Storage** | 10GB per CU included | Scales with metadata |
| **Operations** | 25 ops/sec per CU | Scales with usage |

### Key Cost Considerations

> **🚨 Critical**: Unlike Microsoft Fabric, Purview Enterprise **cannot be paused**. Once upgraded, you pay continuously based on Data Map size - even when idle.

| Aspect | Fabric (F2) | Purview Enterprise |
|--------|-------------|-------------------|
| **Pause/Resume** | ✅ Yes | ❌ No |
| **Minimum Monthly** | ~$0 (when paused) | ~$360 |
| **Delete & Recreate** | ✅ Data preserved | ⚠️ All metadata lost |

---

## 🔧 Enterprise Setup Process

### Step 1: Upgrade from Free Version

1. Go to [purview.microsoft.com](https://purview.microsoft.com).

2. Click **Upgrade** in the top ribbon or **Settings** → **View all settings**.

3. Select your **Azure subscription** and **resource group**.

4. Acknowledge the billing terms.

5. Click **Upgrade**.

> **⏱️ Timing**: Upgrade completes within minutes. An Azure resource (`Microsoft.Purview/accounts`) is created.

### Step 2: Verify Enterprise Features

After upgrade, verify access to:

1. **Data Map** → **Sources** (full source registration).

2. **Scan** configuration with scheduling options.

3. **Collections** for organizing assets.

4. **Workflows** for governance processes.

### Step 3: Register Microsoft Fabric Tenant

1. In **Data Map** → **Sources**, click **Register**.

2. Search for **Microsoft Fabric** or **Power BI**.

3. Configure registration:

   | Setting | Value |
   |---------|-------|
   | **Name** | `Fabric-Tenant-Enterprise` |
   | **Tenant** | Your Azure AD tenant |
   | **Credential** | Managed Identity (recommended) |

4. Click **Register**.

---

## 🔍 Deep Scanning Configuration

### Create Enterprise Scan

1. In Data Map → Sources, find your Fabric tenant.

2. Click the **New scan** icon.

3. Configure scan settings:

   | Setting | Recommended Value |
   |---------|-------------------|
   | **Name** | `Fabric-Enterprise-Scan-01` |
   | **Scope** | Select specific workspaces |
   | **Credential** | Managed Identity |
   | **Integration Runtime** | Azure AutoResolve |

### Select Asset Types

Choose Fabric item types to scan:

| Item Type | Deep Scanning | Classification Support |
|-----------|---------------|----------------------|
| **Lakehouse** | ✅ Full schema | ✅ Column-level |
| **Warehouse** | ✅ Full schema | ✅ Column-level |
| **KQL Database** | ✅ Tables/columns | ✅ Column-level |
| **Semantic Model** | ✅ Measures/columns | ⚠️ Limited |
| **Dataflow** | ✅ Schema | ✅ Column-level |
| **Pipeline** | ⚠️ Metadata only | ❌ N/A |

### Configure Classification Rules

1. In scan configuration, select **Scan rule set**.

2. Choose classification categories:

   | Category | Examples |
   |----------|----------|
   | **Financial** | Credit Card, Bank Account, SWIFT Code |
   | **Healthcare** | Medicare ID, DEA Number |
   | **National ID** | SSN, Passport, Driver's License |
   | **Contact Info** | Email, Phone, Address |
   | **Credentials** | API Keys, Passwords |

3. Set classification sensitivity threshold:

   - **High**: Only confident matches (fewer false positives).
   - **Medium**: Balanced accuracy.
   - **Low**: More matches (potential false positives).

### Schedule Scan

For production environments, configure scheduled scanning:

| Schedule Type | Use Case |
|---------------|----------|
| **Once** | Initial discovery, testing |
| **Daily** | High-change environments |
| **Weekly** | Standard governance |
| **Monthly** | Stable environments |

---

## 📊 Scan Results Analysis

### Understanding Scan Levels

Enterprise scans provide three analysis levels:

| Level | What It Discovers | Classification |
|-------|-------------------|----------------|
| **L1 (Basic)** | Asset names, hierarchy | ❌ No |
| **L2 (Standard)** | Schema, columns, types | ✅ Yes |
| **L3 (Full)** | Data sampling, profiling | ✅ Enhanced |

### Classification Confidence Levels

| Confidence | Meaning | Action |
|------------|---------|--------|
| **High (80%+)** | Strong pattern match | Auto-apply classification |
| **Medium (60-80%)** | Partial match | Review recommended |
| **Low (<60%)** | Weak match | Manual review required |

### Viewing Scan Results

1. Navigate to **Data Map** → **Sources** → Your Fabric source.

2. Click **View details** → **Scans** tab.

3. Review scan statistics:

   | Metric | Description |
   |--------|-------------|
   | **Total assets** | Items discovered |
   | **Classified assets** | Items with classifications |
   | **New classifications** | First-time detections |
   | **Updated** | Changed since last scan |

---

## 🗂️ Collections for Fabric Assets

### Create Collection Hierarchy

Enterprise Purview allows organizing assets into collections:

```text
Root Collection
├── Production
│   ├── Finance
│   │   └── Fabric-Finance-Workspace
│   └── HR
│       └── Fabric-HR-Workspace
├── Development
│   └── Fabric-Dev-Workspace
└── Test
    └── Fabric-Test-Workspace
```

### Configure Collection

1. In Data Map, click **Collections**.

2. Create collection hierarchy:

   - Click **+ Add collection**.
   - Name: `Fabric-Production`.
   - Parent: Root Collection.
   - Description: "Production Fabric workspaces".

3. Assign permissions per collection.

### Move Assets to Collections

1. After scanning, assets appear in root collection.

2. Select assets and click **Move**.

3. Choose target collection.

4. Collections inherit from parent for permissions.

---

## 🔄 Workflow Integration

### Available Workflow Types

Enterprise Purview includes governance workflows:

| Workflow | Purpose |
|----------|---------|
| **Data access request** | Users request access to assets |
| **Term approval** | Approve new glossary terms |
| **Update request** | Request metadata changes |
| **Custom workflows** | Business-specific processes |

### Configure Workflow for Fabric

1. Go to **Management** → **Workflows**.

2. Create new workflow:

   - **Trigger**: When classification detected.
   - **Condition**: Classification = "U.S. Social Security Number".
   - **Action**: Notify data owner for review.

3. This automates governance when sensitive data is discovered.

---

## 📈 Enterprise Best Practices

### Scan Strategy

1. **Initial Full Scan**: Run once to discover all assets.

2. **Incremental Scans**: Weekly scans for changes only.

3. **Scope Limitation**: Scan specific workspaces, not entire tenant.

4. **Off-Hours Scheduling**: Run scans during low-usage periods.

### Cost Optimization

1. **Monitor CU Usage**: Track capacity unit consumption in Azure portal.

2. **Limit Scan Frequency**: Weekly scans sufficient for most scenarios.

3. **Scope Control**: Only scan workspaces that need governance.

4. **Classification Rules**: Use targeted rule sets, not all 200+ SITs.

### Governance Integration

1. **Link to M365 Labels**: Connect Purview classifications to sensitivity labels.

2. **Data Owner Assignment**: Assign owners to assets for accountability.

3. **Glossary Alignment**: Map Fabric assets to business glossary terms.

4. **Lineage Documentation**: Use lineage to document data flows.

---

## 🔗 Fabric-Specific Considerations

### Supported Fabric Items

| Fabric Item | Scan Support | Classification | Lineage |
|-------------|--------------|----------------|---------|
| Lakehouse | ✅ Full | ✅ Column-level | ✅ Full |
| Warehouse | ✅ Full | ✅ Column-level | ✅ Full |
| KQL Database | ✅ Full | ✅ Column-level | ⚠️ Limited |
| Semantic Model | ✅ Schema | ⚠️ Limited | ✅ Full |
| Dataflow Gen2 | ✅ Schema | ✅ Column-level | ✅ Full |
| Pipeline | ⚠️ Metadata | ❌ N/A | ✅ Full |
| Notebook | ⚠️ Metadata | ❌ N/A | ⚠️ Limited |
| Report | ✅ Metadata | ❌ N/A | ✅ Full |

### Admin API Requirements

For enterprise scanning to work properly:

1. **Enable Admin API**: Fabric Admin Portal → Tenant settings → Admin API settings.

2. **Allow Service Principal**: Enable service principal access to read-only admin APIs.

3. **Propagation Time**: Wait 15-30 minutes after enabling settings.

### Scan Permissions

| Permission | Purpose | Where to Configure |
|------------|---------|-------------------|
| **Fabric Admin** | Full tenant access | M365 Admin Center |
| **Workspace Admin** | Workspace-level access | Fabric workspace settings |
| **Purview Data Source Admin** | Register and scan sources | Purview Data Map |

---

## ❌ Common Issues and Solutions

### Scan Fails with Permission Error

**Symptom**: Scan starts but fails with authentication error.

**Resolution**:

1. Verify managed identity has Fabric permissions.
2. Check Admin API settings are enabled.
3. Wait for permission propagation (15-30 minutes).
4. Re-register the Fabric source.

### No Classifications Detected

**Symptom**: Scan completes but shows no classifications.

**Resolution**:

1. Verify classification rules are enabled in scan rule set.
2. Check data format matches expected patterns (SSN format, etc.).
3. Increase classification sensitivity threshold.
4. Manually review sample data for recognizable PII.

### Incomplete Lineage

**Symptom**: Lineage shows gaps or missing connections.

**Resolution**:

1. Ensure all data transformation steps have run at least once.
2. Wait 24 hours for lineage processing.
3. Re-scan after pipeline executions.
4. Some manual operations don't generate lineage.

### High CU Consumption

**Symptom**: Billing higher than expected.

**Resolution**:

1. Reduce scan frequency (weekly instead of daily).
2. Limit scope to essential workspaces only.
3. Use targeted classification rules instead of all SITs.
4. Monitor CU consumption in Azure Cost Management.

---

## 📚 Related Resources

- [Microsoft Purview Data Governance Pricing](https://azure.microsoft.com/pricing/details/purview/)
- [Register and Scan Fabric Tenant](https://learn.microsoft.com/purview/register-scan-fabric-tenant)
- [Purview Data Map Overview](https://learn.microsoft.com/purview/concept-data-map)
- [Classification in Purview](https://learn.microsoft.com/purview/concept-classification)
- [Purview Collections](https://learn.microsoft.com/purview/data-map-collections-manage-classic)
- [Purview Workflows](https://learn.microsoft.com/purview/concept-workflow)

---

## 🤖 AI-Assisted Content Generation

This supplementary documentation was created with the assistance of **GitHub Copilot** powered by Claude Opus 4.5. Enterprise scanning procedures and pricing information were verified against Microsoft Learn documentation within **Visual Studio Code**.

*This document covers advanced enterprise features that require additional Azure subscription costs. The main simulation labs are designed to work with the free version of Purview Data Governance.*
