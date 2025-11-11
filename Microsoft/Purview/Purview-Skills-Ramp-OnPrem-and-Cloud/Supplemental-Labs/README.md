# Supplemental Labs Overview

This section contains advanced labs that assume you have completed the first three sections (Setup, OnPrem Scanning, and Cloud Scanning). These labs focus on production-ready automation, advanced SIT detection and analysis, cross-platform governance, and custom sensitive information types.

## Labs in this Section

- **[Advanced-Cross-Platform-SIT-Analysis](./Advanced-Cross-Platform-SIT-Analysis/)**: Capstone integration lab that consolidates Activity Explorer data from on-premises scanner and cloud SharePoint DLP environments into unified cross-platform SIT governance analysis with automated executive reporting (45-60 minutes active work + prerequisite lab completion).
- **[Advanced-Remediation](./Advanced-Remediation/)**: Production remediation workflows including multi-tier severity-based strategies, dual-source deduplication (on-prem + cloud), SharePoint PnP PowerShell bulk deletion, tombstone creation, and stakeholder progress tracking (4-6 hours).
- **[Advanced-SharePoint-SIT-Analysis](./Advanced-SharePoint-SIT-Analysis/)**: DLP policy deployment for real-time SIT protection, Activity Explorer validation (15-30 min), Content Explorer comprehensive reporting (24-48 hours), and PowerShell-based SIT distribution analysis (3-4 hours active work + 30-45 min data creation).
- **[Custom-Classification](./Custom-Classification/)** ⚠️ **UNDER DEVELOPMENT**: Trainable Classifiers with ML training, sample curation (100 financial reports + 200 business documents), accuracy validation, and DLP policy integration (3 hours active work + 24-hour ML training wait). *Currently in ML training phase - will be finalized after validation (~November 12, 2025).*

## Estimated Duration

- **Total Active Time**: 11-14 hours
- **Wait Periods**:
  - 24-48 hours for Activity Explorer data sync (required for Advanced-Cross-Platform-SIT-Analysis)
  - 24-48 hours for Content Explorer data sync (Advanced-SharePoint-SIT-Analysis)
  - 24 hours for Trainable Classifier ML training (Custom-Classification)

## Prerequisites

- **Required Sections**:
  - Section 1: Setup (all 3 labs)
  - Section 2: OnPrem Scanning (at least OnPrem-01 and OnPrem-02)
  - Section 3: Cloud Scanning (at least Cloud-01 and Cloud-02)

- **Technical Requirements**:
  - PnP PowerShell module for Advanced Remediation and Custom-Classification
  - SharePoint Online admin access
  - Microsoft Purview portal access with appropriate permissions
  - Understanding of Activity Explorer and Content Explorer for SIT detection

## Flexible Ordering

✅ **These labs can be completed in any order** based on your learning priorities:

- Start with **Advanced-SharePoint-SIT-Analysis** if you want to master DLP policy deployment and real-time SIT detection with Activity Explorer (recommended first supplemental lab).
- Start with **Advanced-Remediation** if you need production remediation workflows and stakeholder progress tracking.
- Start with **Advanced-Cross-Platform-SIT-Analysis** after completing both Advanced-Remediation (Step 1 minimum) and Advanced-SharePoint-SIT-Analysis (Step 2 minimum) for capstone integration experience.
- Start with **Custom-Classification** if you need custom classification capabilities for unique business requirements.

> **💡 Recommended Sequence**: Advanced-SharePoint-SIT-Analysis → Advanced-Remediation → Advanced-Cross-Platform-SIT-Analysis → Custom-Classification

## Cost Considerations

- **Advanced-SharePoint-SIT-Analysis**: No additional costs beyond existing Microsoft Purview licensing (DLP policies and SIT detection included)
- **Custom-Classification**: ML training and validation incur minimal compute costs
- **Advanced-Remediation**: No additional costs beyond existing Purview licensing
- **Advanced-Cross-Platform-SIT-Analysis**: Analysis and reporting only (no additional costs)

## Completion Checklist

- [ ] DLP policies deployed with real-time SIT detection validated via Activity Explorer
- [ ] Content Explorer comprehensive SIT reporting completed with PowerShell automation
- [ ] Advanced remediation workflows tested with multi-tier severity matrix and dual-source deduplication
- [ ] Cross-platform SIT governance analysis completed with integrated executive reporting
- [ ] Trainable Classifiers trained with 300 sample documents and validated (24-hour ML training wait)
- [ ] Production automation patterns and stakeholder reporting frameworks understood

> **Note:** All technical steps, scripts, and instructions are preserved exactly as in the original project. No technical content has been changed.
