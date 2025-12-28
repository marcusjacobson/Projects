# Day Zero Setup: Long-Lead Items

**⚠️ CRITICAL STEP**: Execute the tasks in this section **IMMEDIATELY**.

Microsoft Purview has several features that require significant backend processing time before they become active. To ensure you can complete the labs without waiting, you must initiate these processes on "Day Zero".

## ⏳ Wait Times Overview

| Feature | Action | Estimated Wait Time |
|---------|--------|---------------------|
| **Exact Data Match (EDM)** | Schema Indexing | 12 - 24 Hours |
| **Sensitivity Labels** | Policy Publication | 24 Hours (for full client availability) |
| **DLP Policies** | Policy Sync to Endpoint | 1 - 24 Hours |
| **Audit Log** | Initial Enablement | 24 Hours |

## 📋 Day Zero Checklist

### 1. Enable Purview Pay-As-You-Go (PAYG)
**Why?** EDM and other advanced features require an Azure Subscription link.
- **Action**: Go to Purview Portal > Settings > Compliance Manager > Set up Azure subscription.
- **Validation**: Ensure the status shows "Active".

### 2. Create and Index EDM Schema
**Why?** The EDM hash must be uploaded and indexed by Microsoft before you can use it in policies.
- **Action**:
    1.  Navigate to `03-Classification-Design`.
    2.  Run the `scripts/New-EdmSchema.ps1` script to define the schema.
    3.  Run the `scripts/Upload-EdmData.ps1` script to hash and upload the seed data.
- **Validation**: Check the "Data classification" > "Exact Data Matches" tab. Status must be "Completed".

### 3. Publish "Baseline" Sensitivity Labels
**Why?** Labels take time to propagate to Office apps and the AIP client.
- **Action**:
    1.  Run the `scripts/Deploy-BaselineLabels.ps1` script in this directory.
    2.  This will create a "General" and "Confidential" label and publish them to your user.
- **Validation**: Check Word/Excel for the "Sensitivity" button and the presence of these labels.

### 4. Enable Audit Logging
**Why?** You cannot track exfiltration or policy matches if auditing is off.
- **Action**: Run `Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true` via Exchange Online PowerShell.
- **Validation**: `Get-AdminAuditLogConfig | Select-Object UnifiedAuditLogIngestionEnabled` should return `True`.

## 🚀 Automation Scripts

Use the scripts in this directory to perform these actions quickly.

- `scripts/Deploy-BaselineLabels.ps1`: Creates and publishes the initial label taxonomy.
- `scripts/Enable-AuditLogging.ps1`: Turns on the Unified Audit Log.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for managing Purview propagation delays.

*AI tools were used to enhance productivity and ensure comprehensive coverage of Day Zero requirements while maintaining technical accuracy.*
