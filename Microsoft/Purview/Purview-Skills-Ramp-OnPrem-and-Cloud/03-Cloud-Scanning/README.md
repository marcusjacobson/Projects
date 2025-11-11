# Section 3: Cloud-Based Data Governance with Microsoft Purview

## 📋 Section Overview

This section provides comprehensive hands-on labs for implementing Microsoft Purview data governance capabilities in cloud-based Microsoft 365 environments. You'll learn how to manage content lifecycle with retention labels, automatically classify sensitive data using auto-apply policies, and discover content using eDiscovery across SharePoint Online and OneDrive for Business.

**Learning Path**: Create SharePoint Foundation → Configure Retention Labels → Auto-Apply Policies → eDiscovery Search & Export

---

## 🎯 What You'll Accomplish

By completing this section, you will:

- **Deploy** SharePoint Online team sites with sample sensitive data repositories
- **Create** retention labels with time-based deletion policies for data lifecycle management
- **Configure** auto-apply policies that automatically label content based on sensitive information types
- **Search** cloud content using eDiscovery with Keyword Query Language (KQL) for compliance investigations
- **Export** eDiscovery results for legal review and compliance documentation
- **Understand** cloud vs. on-premises data governance capabilities and limitations

---

## 📚 Lab Sequence

Complete these labs in order for a full cloud data governance deployment:

### [Cloud-01: SharePoint Online Foundation Setup](./Cloud-01-SharePoint-Foundation)

**Duration**: 30-45 minutes | **Objective**: Establish cloud repository with sensitive test data

**What You'll Learn**:

- Create SharePoint Online team site for retention testing.
- Upload sample documents containing sensitive information types (credit cards, SSNs).
- Understand SharePoint Online vs. on-premises file share capabilities.
- Establish foundation for retention label and auto-apply policy testing.
- Configure folder structure for sensitive data archiving.

**Key Deliverables**:

- SharePoint "Retention Testing" team site created.
- Sensitive Data Archive folder with Excel and Word sample files.
- Test documents containing detectable sensitive information types.
- Understanding of cloud-only data governance scope.

**💡 Important Context**: Retention labels with auto-apply policies work in **SharePoint Online** and **OneDrive for Business**, but **NOT on on-premises file shares** scanned by the Information Protection Scanner (OnPrem-01/02).

---

### [Cloud-02: Retention Labels Configuration](./Cloud-02-Retention-Labels)

**Duration**: 45-60 minutes | **Objective**: Create retention labels for automated data lifecycle management

**What You'll Learn**:

- Create retention labels with file plan descriptors for organizational categorization.
- Configure retention periods with time-based deletion policies.
- Understand retention trigger events (creation, modification, labeled).
- Set automatic deletion actions after retention period expires.
- Publish retention labels to SharePoint locations.

**Key Deliverables**:

- "Delete-After-3-Years" retention label created.
- File plan descriptors configured (Finance, Financial Records, SOX compliance).
- Retention settings: 3-year period based on last modification.
- Label published to "Retention Testing" SharePoint site.
- Understanding of retention label lifecycle management.

**⚠️ Publishing Wait**: Allow 15-30 minutes for label publishing to propagate to SharePoint sites

---

### [Cloud-03: Auto-Apply Retention Policies](./Cloud-03-Auto-Apply-Policies)

**Duration**: 30-45 minutes active + up to 7 days processing wait | **Objective**: Automate label application based on sensitive data

**What You'll Learn**:

- Create auto-apply retention policies based on sensitive information types.
- Configure policy conditions for credit card and SSN detection.
- Understand simulation mode vs. automatic enforcement options.
- Configure policy scope (specific SharePoint sites).
- Manage the Microsoft 365 service processing timeline (up to 7 days).
- Validate auto-apply policy effectiveness using search and Activity Explorer.

**Key Deliverables**:

- "Auto-Delete-Old-Sensitive-Files" policy created.
- Policy configured to detect Credit Card Number and U.S. SSN sensitive info types.
- SharePoint "Retention Testing" site added as target location.
- Label "Delete-After-3-Years" assigned for auto-application.
- Understanding of 7-day background processing timeline.

**⚠️ CRITICAL TIMING**: Auto-apply retention policies require **up to 7 days** for Microsoft 365 background processing to analyze content and apply labels. This is a service processing timeline, not a configuration issue.

**💡 Pro Tip**: Configure Cloud-03 policy early, then proceed to Cloud-04 (eDiscovery) and other labs during the wait period. Return after 7 days to validate label application.

---

### [Cloud-04: eDiscovery for SharePoint and OneDrive](./Cloud-04-SharePoint-eDiscovery)

**Duration**: 45-60 minutes | **Objective**: Search and export cloud content for compliance investigations

**What You'll Learn**:

- Create eDiscovery (Standard) case in Microsoft Purview portal.
- Search cloud-only locations (SharePoint Online, OneDrive, Exchange Online).
- Use Keyword Query Language (KQL) to find sensitive information types.
- Configure content search queries with sensitive info type conditions.
- Review search statistics and preview sample results.
- Export search results for legal/compliance documentation.
- Understand eDiscovery vs. retention label use cases.

**Key Deliverables**:

- eDiscovery case created with appropriate permissions.
- Content search configured for "Retention Testing" SharePoint site.
- KQL query targeting Credit Card Number and U.S. SSN sensitive info types.
- Search results validated showing document matches.
- Understanding of cloud-only eDiscovery scope (no on-premises file shares).

**Prerequisites**: Cloud-01 must be completed (SharePoint site with sensitive data). Cloud-02/03 recommended but not required.

**⚠️ CRITICAL LIMITATION**: eDiscovery (Standard) searches **ONLY cloud-based Microsoft 365 content**. On-premises file shares discovered by Information Protection Scanner (OnPrem-01/02) **CANNOT** be searched using cloud eDiscovery.

---

## ⏱️ Total Time Investment

| Component | Duration |
|-----------|----------|
| **Active Lab Time** | 3.5-4.75 hours |
| **Wait Periods** | Up to 7 days (auto-apply processing) |
| **Total End-to-End** | 7-10 days (includes processing wait) |

**💡 Pro Tip**: Start Cloud-03 auto-apply policy early in your learning path, then complete Cloud-04 and Section 4 (Reporting) labs during the 7-day wait period.

---

## ✅ Overall Completion Checklist

Track your progress through the cloud data governance learning path:

- [ ] **Cloud-01**: SharePoint site created, sensitive data uploaded, folder structure established
- [ ] **Cloud-02**: Retention label created, file plan descriptors configured, label published
- [ ] **Cloud-03**: Auto-apply policy created, sensitive info types configured, 7-day processing initiated
- [ ] **Cloud-04**: eDiscovery case created, content search executed, results validated

**Post-Wait Period Validation** (after 7 days):

- [ ] Return to Cloud-03 and verify retention labels automatically applied to sample documents
- [ ] Review Activity Explorer (Reporting-01) for auto-labeling activity events
- [ ] Validate label application via SharePoint document properties

---

## 🎓 Skills You'll Gain

**Technical Capabilities**:

- Deploy SharePoint Online team sites for collaborative content management.
- Create and configure retention labels with lifecycle management policies.
- Implement auto-apply policies based on sensitive information type detection.
- Execute eDiscovery searches using Keyword Query Language (KQL).
- Export compliance data for legal review and documentation.

**Operational Knowledge**:

- Understand cloud vs. on-premises data governance capabilities.
- Navigate Microsoft 365 background processing timelines (auto-apply policies).
- Differentiate between retention labels and eDiscovery use cases.
- Manage retention trigger events (creation, modification, labeled).
- Distinguish cloud-only eDiscovery scope from on-premises limitations.

**Compliance & Governance**:

- Implement defensible deletion policies for sensitive data.
- Automate data lifecycle management based on regulatory requirements.
- Support legal investigations with eDiscovery search and export.
- Establish data minimization practices aligned with GDPR.
- Document compliance with file plan descriptors and audit trails.

---

## 🔗 Navigation

**Current Section**: 03-Cloud-Scanning

**Previous Section**: [02-OnPrem-Scanning](../02-OnPrem-Scanning) - On-premises scanner deployment and DLP

**Next Section**: [Supplemental-Labs](../Supplemental-Labs) - Advanced optional labs (cross-platform analysis, remediation, custom classification)

---

## ⚠️ Critical Understanding: Cloud vs. On-Premises Scope

**Cloud Capabilities (This Section)**:

- ✅ **Retention Labels**: SharePoint Online, OneDrive for Business.
- ✅ **Auto-Apply Policies**: SharePoint Online, OneDrive for Business.
- ✅ **eDiscovery (Standard)**: SharePoint Online, OneDrive, Exchange Online, Teams.

**On-Premises Limitations**:

- ❌ **Retention Labels**: NOT supported for on-premises file shares discovered by Information Protection Scanner.
- ❌ **Auto-Apply Policies**: NOT supported for on-premises file shares.
- ❌ **Cloud eDiscovery**: CANNOT search on-premises file shares or Exchange mailboxes.

**Integration Points**:

- **OnPrem-02 (Discovery Scans)**: Identifies sensitive data in on-premises file shares for **classification awareness**
- **Cloud-01 (SharePoint)**: Provides **cloud migration target** where retention labels and auto-apply policies work
- **Hybrid Strategy**: Scanner discovers on-premises data → Cloud migration enables full lifecycle management

> **💡 Architectural Insight**: The Information Protection Scanner (OnPrem-01/02) provides **discovery and DLP enforcement** for on-premises file shares, but **data lifecycle management** (retention, auto-apply) requires cloud-based repositories like SharePoint Online or OneDrive for Business.

---

## 📖 Documentation Standards

All labs in this section follow consistent formatting and structure:

- **Prerequisites**: Clearly listed requirements with links to prerequisite labs
- **Step-by-Step Instructions**: Detailed procedures with current UI guidance (post-August 2025)
- **Portal Navigation Notes**: Interface variations explained with portal version context
- **Wait Period Guidance**: Explicit timing expectations for Microsoft 365 background processing
- **Troubleshooting**: Common issues and resolutions specific to each lab
- **Validation Checklists**: Confirm successful completion before proceeding to next lab

---

## 🤖 AI-Assisted Content Generation

This section guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of cloud data governance workflows while maintaining technical accuracy for Microsoft Purview retention and compliance scenarios.*
