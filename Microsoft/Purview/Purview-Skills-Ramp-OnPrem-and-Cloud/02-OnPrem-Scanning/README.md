# Section 2: On-Premises Scanning with Microsoft Purview

## 📋 Section Overview

This section provides comprehensive hands-on labs for deploying, configuring, and validating Microsoft Purview Information Protection scanner for on-premises file repositories. You'll learn how to discover sensitive data, apply Data Loss Prevention (DLP) policies, and monitor compliance activity across on-premises file shares.

**Learning Path**: Deploy Scanner → Discover Sensitive Data → Apply DLP Policies → Monitor & Report

---

## 🎯 What You'll Accomplish

By completing this section, you will:

- **Deploy** the Purview Information Protection scanner on Windows Server 2022
- **Discover** sensitive information (credit cards, SSNs, PII) in on-premises file shares
- **Protect** sensitive data using DLP policies synchronized from the Purview portal
- **Monitor** DLP activity using Activity Explorer and generate compliance reports
- **Automate** reporting workflows with PowerShell scripts for ongoing monitoring

---

## 📚 Lab Sequence

Complete these labs in order for a full on-premises scanning deployment:

### [OnPrem-01: Scanner Deployment](./OnPrem-01-Scanner-Deployment)

**Duration**: 1.5-2 hours | **Objective**: Install and configure the scanner infrastructure

**What You'll Learn**:

- Install Purview Information Protection scanner client on Windows Server 2022.
- Configure scanner cluster in Purview portal with authentication credentials.
- Set up scanner database and service account authentication.
- Verify scanner installation and understand scanner architecture.

**Key Deliverables**:

- Scanner client installed and running.
- Scanner cluster created and authenticated.
- SQL database configured for scanner data storage.

---

### [OnPrem-02: Discovery Scans](./OnPrem-02-Discovery-Scans)

**Duration**: 1-2 hours (includes 30-60 minutes scan execution) | **Objective**: Discover sensitive data in file shares

**What You'll Learn**:

- Add on-premises file share repositories to scanner content scan jobs.
- Execute discovery scans to identify sensitive content.
- Review detailed CSV scan reports with sensitive information type detections.
- Analyze discovery results in Purview Activity Explorer.

**Key Deliverables**:

- Discovery scan completed successfully.
- Detailed CSV reports showing Credit Card, SSN, and PII detections.
- Understanding of sensitive information type detection patterns.

---

### [OnPrem-03: DLP Policy Configuration](./OnPrem-03-DLP-Policy-Configuration)

**Duration**: 30-45 minutes active + 1-2 hours policy sync wait | **Objective**: Create and apply DLP policies

**What You'll Learn**:

- Create custom DLP policies for on-premises repositories in Purview portal.
- Configure DLP rules with sensitive information type conditions.
- Understand DLP rule actions (block vs audit) and user notifications.
- Verify DLP policy synchronization and enforcement scan execution.
- Validate DLP detection in scanner reports (Information Type Name populated).

**Key Deliverables**:

- DLP policy created and synchronized to scanner.
- Enforcement scan completed with DLP detections.
- Scanner reports show Information Type Name column populated.

**⚠️ Important**: Allow 1-2 hours for DLP policy synchronization before running enforcement scans

---

### [OnPrem-04: DLP Activity Monitoring & Reporting](./OnPrem-04-DLP-Enforcement-Validation)

**Duration**: 15-20 minutes | **Objective**: Monitor DLP activity and generate compliance reports

**What You'll Learn**:

- Navigate Activity Explorer and filter for on-premises DLP activity (Endpoint devices).
- Configure **Customize columns** to include Sensitive info type for comprehensive reporting.
- Export Activity Explorer data to CSV for stakeholder reporting.
- Generate executive summaries and detailed reports using PowerShell automation.
- Establish weekly monitoring cadence for ongoing compliance.
- Distinguish between on-premises scanner activity and cloud workload activity.

**Key Deliverables**:

- Activity Explorer configured to display on-premises DLP events.
- CSV exports with sensitive data type information.
- PowerShell-generated executive summary and detailed reports.
- Weekly monitoring workflow established.

**Prerequisites**: OnPrem-03 must be completed with DLP detection working, auditing enabled, and 15-30 minutes elapsed for data sync

---

## ⏱️ Total Time Investment

| Component | Duration |
|-----------|----------|
| **Active Lab Time** | 3.5-5.5 hours |
| **Wait Periods** | 1-2 hours (DLP policy sync) |
| **Total End-to-End** | 4.5-7.5 hours |

**💡 Pro Tip**: Start OnPrem-03 DLP policy creation early in your session, then complete other tasks during the 1-2 hour sync wait period.

---

## ✅ Overall Completion Checklist

Track your progress through the on-premises scanning learning path:

- [ ] **OnPrem-01**: Scanner client deployed, cluster created, service authenticated
- [ ] **OnPrem-02**: Discovery scan completed, sensitive data identified in CSV reports
- [ ] **OnPrem-03**: DLP policy created, synchronized, enforcement scan validated
- [ ] **OnPrem-04**: Activity Explorer accessed, reports generated, monitoring cadence established

---

## 🎓 Skills You'll Gain

**Technical Capabilities**:

- Deploy and configure enterprise information protection scanners.
- Execute discovery and enforcement scans for sensitive data.
- Create and manage DLP policies for on-premises repositories.
- Monitor DLP activity using Activity Explorer with proper filtering.
- Generate compliance reports from multiple data sources.

**Operational Knowledge**:

- Understand scanner architecture and authentication flows.
- Differentiate between discovery and enforcement scan modes.
- Navigate DLP policy synchronization timing requirements.
- Distinguish on-premises scanner activity from cloud workload activity.
- Implement automated reporting workflows with PowerShell.

**Compliance & Reporting**:

- Export and analyze DLP activity data.
- Create stakeholder-ready compliance documentation.
- Establish regular monitoring cadences for ongoing compliance.
- Leverage multiple reporting sources (Activity Explorer, scanner CSVs, audit logs).

---

## 🔗 Navigation

**Current Section**: 02-OnPrem-Scanning

**Previous Section**: [01-Setup](../01-Setup) - Azure and on-premises environment setup

**Next Section**: [03-Cloud-Scanning](../03-Cloud-Scanning) - SharePoint Online scanning and retention labels

---

## 📖 Documentation Standards

All labs in this section follow consistent formatting and structure:

- **Prerequisites**: Clearly listed requirements and validation steps
- **Step-by-Step Instructions**: Detailed procedures with screenshots and validation
- **PowerShell Scripts**: Production-ready automation with error handling
- **Troubleshooting**: Common issues and resolutions specific to each lab
- **Validation Checklists**: Confirm successful completion before proceeding

---

## 🤖 AI-Assisted Content Generation

This section guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of on-premises scanning workflows while maintaining technical accuracy for Microsoft Purview Information Protection scanner deployment.*
