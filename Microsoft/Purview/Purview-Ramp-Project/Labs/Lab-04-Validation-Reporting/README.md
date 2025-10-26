# Lab 04: Validation & Reporting

> **📂 This lab is divided into two parts due to Activity Explorer and Data Classification dashboard sync requirements**

## 📋 Lab Overview

**Total Duration**: 3.5-4 hours (including 24 hour mandatory wait time)

**Objective**: Validate Purview deployment success, analyze scanner reports, quantify old data for remediation, monitor DLP effectiveness through Activity Explorer, and create a comprehensive stakeholder summary report.

**Prerequisites from Labs 01-03:**

- ✅ Lab 01 complete: Scanner deployed and discovery scan executed
- ✅ Lab 02 complete: DLP policies configured and enforcement scan executed
- ✅ Lab 03 complete or in progress: Retention labels configured, auto-apply policy processing
- ✅ Scanner CSV reports generated and accessible
- ✅ Sample data in file shares with sensitive information

---

## 🗂️ Lab Structure

This lab is split into **two parts** with a mandatory wait period between them:

### [**Part 1: Scanner Analysis & Remediation Planning**](Lab-04-Part-1-Analysis-Remediation/README.md)

**Duration**: 2-3 hours (all immediate activities)

**Activities**:

- Analyze scanner CSV reports for sensitive data distribution
- Quantify old data (3+ years) for remediation opportunities
- Practice basic PowerShell remediation patterns (deletion, archiving, bulk processing)
- Create draft stakeholder report with scanner findings
- Validate Labs 01-02 completion
- **WAIT** for Activity Explorer data sync (15-30 min to 24 hours)

➡️ **[Start Lab 04 - Part 1](Lab-04-Part-1-Analysis-Remediation/README.md)**

---

### [**Part 2: Activity Monitoring & Final Reporting**](Lab-04-Part-2-Monitoring-Reporting/README.md)

> **⚠️ PREREQUISITE**: Complete Part 1 and wait 24 hours for Activity Explorer and Data Classification dashboards to fully sync before starting Part 2

**Duration**: 1 hour

**Activities**:

- Analyze Activity Explorer for DLP policy effectiveness
- Review Data Classification dashboards for sensitive data trends
- Finalize stakeholder report with monitoring insights
- Complete final validation checklist for all labs (01-04)
- Execute environment cleanup to terminate Azure costs

➡️ **[Start Lab 04 - Part 2](Lab-04-Part-2-Monitoring-Reporting/README.md)**

---

## 🎯 Combined Learning Objectives

By the end of Lab 04 (both parts), you will be able to:

1. **Scanner Report Analysis**: Interpret scanner CSV reports for sensitive data distribution and DLP enforcement results
2. **Data Age Analysis**: Quantify old data (3+ years) eligible for remediation based on file age
3. **Remediation Scripting**: Practice fundamental PowerShell patterns for safe file deletion, archiving, and bulk processing
4. **Activity Explorer**: Monitor DLP policy matches and user activity across on-premises and cloud locations
5. **Data Classification**: Interpret dashboards showing sensitive data trends, labeling status, and compliance metrics
6. **Stakeholder Reporting**: Create comprehensive executive reports combining scanner analysis and monitoring insights
7. **Complete Validation**: Validate successful completion of all labs across time-delayed policy processing
8. **Environment Cleanup**: Properly terminate Azure resources to prevent ongoing costs

---

## ⏳ Important: Activity Explorer & Dashboard Sync Requirements

**Why Two Parts?**

Activity Explorer and Data Classification dashboards require **15-30 minutes to 24 hours** for data synchronization after scanner activity. This sync process populates monitoring dashboards with audit events, DLP matches, and aggregated compliance metrics.

**Sync Process**:

1. ✅ **Part 1**: Analyze scanner reports, quantify old data, practice remediation scripting, create draft report
2. ⏳ **Wait 15-30 min to 24 hours**: Activity Explorer events sync, Data Classification dashboards aggregate (mandatory wait)
3. ✅ **Part 2**: Review complete monitoring data, finalize stakeholder report, validate all labs, cleanup environment

**What Happens During Sync**:

- **Activity Explorer** (15-30 minutes to 24 hours):
  - Scanner activity events populate in audit system
  - DLP policy match events appear in monitoring dashboards
  - On-premises repository activity becomes visible
  - User context data syncs (if available)

- **Data Classification Dashboards** (1-2 days for full aggregation):
  - Top Sensitive Info Types visualization updates
  - Locations with Sensitive Data distribution calculates
  - DLP Policy Effectiveness trends populate
  - Labeling Status percentages aggregate

> **⏰ Optimal Wait Time**: **24 hours after Part 1 completion** ensures all monitoring data is fully synced and dashboards are completely populated. Minimum wait is 15-30 minutes for initial Activity Explorer data, but dashboards may show incomplete aggregation.

---

## 📚 Key Concepts

### Scanner Report Analysis

**DetailedReport CSV**: File-by-file scan results with sensitive data findings

- **File Path**: UNC path to scanned file
- **Sensitive Information Types**: Which SITs detected (Credit Card, SSN, etc.)
- **DLP Policy Matched**: Which DLP policy triggered
- **DLP Action**: Enforcement action taken (Block, Audit)
- **Last Modified**: File age for remediation analysis

**SummaryReport CSV**: High-level statistics

- Total files scanned
- Files with sensitive data
- SIT distribution counts
- DLP policy effectiveness summary

### Activity Explorer Monitoring

**Purpose**: Real-time and historical visibility into DLP matches, label application, and user activity

**Key Metrics**:

- **Total Activities**: Number of DLP policy match events
- **Activities by Location**: Which shares triggered most DLP matches (Finance: credit cards, HR: SSNs)
- **Activities by Severity**: High vs. Low severity DLP matches
- **Activities Over Time**: Trend of DLP events showing scanner execution spikes
- **Users Involved**: Which accounts accessed sensitive data (typically scanner service account in lab)

### Data Classification Dashboards

**Top Sensitive Info Types**: Bar chart showing most common SIT types detected (Credit Card, SSN, Email)

**Locations with Sensitive Data**: Distribution across repositories (on-prem file shares, Azure Files, SharePoint)

**Labeling Status**: Percentage of files with sensitivity/retention labels applied

**DLP Policy Effectiveness**: DLP match trends, policy/rule breakdown, user overrides

### Remediation Analysis

**3+ Year Old Data**: Files eligible for deletion or archival based on last modified date

**Remediation Patterns**:

1. **Safe Deletion**: Delete with audit trail logging
2. **Archive**: Move to cold storage (Azure Archive tier or separate file share)
3. **Bulk Processing**: Process thousands of files with error handling
4. **Access Time Analysis**: Distinguish unused files from read-only usage

---

## 📊 What You'll Accomplish

### Part 1 Deliverables

**Technical Analysis**:
- ✅ Scanner report analysis summary (file counts, SIT distribution, DLP actions)
- ✅ Old data quantification CSV (3+ year files with remediation recommendations)
- ✅ PowerShell remediation script examples

**Documentation**:
- ✅ Draft stakeholder report with scanner findings
- ✅ Labs 01-02 validation checklist completed

### Part 2 Deliverables

**Monitoring Analysis**:
- ✅ Activity Explorer export CSV with DLP policy match events
- ✅ Data Classification dashboard screenshots (4 images)
- ✅ Dashboard summary document with key metrics

**Final Documentation**:
- ✅ Complete stakeholder report (scanner + monitoring data)
- ✅ All labs (01-04) validation checklist
- ✅ Environment cleanup summary confirming cost termination

---

## 💼 Real-World Application

**Consultancy Project Scenario**:

Your client needs a comprehensive assessment of their on-premises file shares:

1. **Discovery**: Identify where sensitive data exists (scanner reports)
2. **Compliance**: Verify DLP policies are protecting high-risk data (Activity Explorer)
3. **Remediation**: Quantify old data eligible for deletion/archival (file age analysis)
4. **Reporting**: Present findings and recommendations to stakeholders (final report)
5. **Governance**: Monitor ongoing effectiveness through dashboards

**Skills Demonstrated**:

- **Technical**: Purview scanner deployment, DLP configuration, retention labels
- **Analytical**: Data classification analysis, remediation opportunity identification
- **Business Communication**: Executive stakeholder reporting, ROI quantification
- **Project Management**: Multi-phase lab completion, time-delayed validation

---

## 🚀 Getting Started

**Recommended Approach**:

1. **Today**: Complete Lab 04 Part 1 (2-3 hours)
   - Analyze all scanner reports
   - Quantify old data for remediation
   - Practice PowerShell patterns
   - Create draft report
   - Start 24-hour wait timer

2. **Tomorrow**: Complete Lab 04 Part 2 (1 hour)
   - Review Activity Explorer with complete data
   - Capture Data Classification dashboard screenshots
   - Finalize stakeholder report
   - Validate all labs
   - Execute environment cleanup

**Time Management**:

- Part 1: Best completed in one sitting (2-3 hour block)
- Wait Period: 24 hours (overnight or next day)
- Part 2: Best completed in one sitting (1 hour block)

---

## 📚 Reference Documentation

- [Scanner CSV Report Columns](https://learn.microsoft.com/en-us/purview/deploy-scanner-configure-install#detailed-report-columns)
- [Activity Explorer Documentation](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)
- [Data Classification Dashboards](https://learn.microsoft.com/en-us/purview/data-classification-overview)
- [PowerShell File Management](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/)
- [Azure Resource Cleanup](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)

---

## 🤖 AI-Assisted Content Generation

This lab navigation guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Purview validation workflows, remediation analysis patterns, Activity Explorer monitoring, and stakeholder reporting procedures based on current documentation as of October 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of validation, reporting, and monitoring workflows while maintaining technical accuracy and alignment with enterprise data governance practices.*
