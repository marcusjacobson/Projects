# Lab 02: DLP On-Premises Configuration

> **📂 This lab is divided into two parts due to DLP policy synchronization requirements**

## 📋 Lab Overview

**Total Duration**: 3-4 hours (including 1-2 hour mandatory wait time)

**Objective**: Configure Data Loss Prevention (DLP) policies to protect sensitive information on on-premises file repositories and monitor DLP detection through the Purview scanner.

**Prerequisites from Lab 01:**

- ✅ Information Protection Scanner deployed and operational
- ✅ Discovery scan completed successfully showing sensitive data
- ✅ Scanner service running and authenticated
- ✅ Repositories configured (Finance, HR, Projects, Azure Files)

---

## 🗂️ Lab Structure

This lab is split into **two parts** with a mandatory wait period between them:

### [**Part 1: DLP Policy Creation**](Lab-02-Part-1-DLP-Policy-Creation/README.md)

**Duration**: 30-45 minutes + 1-2 hour wait

**Activities**:

- Create DLP policy in Purview portal
- Configure rules for Credit Card (block) and SSN (audit)
- Set up user notifications and admin alerts
- **WAIT** for DLP policy sync to complete (1-2 hours)

➡️ **[Start Lab 02 - Part 1](Lab-02-Part-1-DLP-Policy-Creation/README.md)**

---

### [**Part 2: DLP Enforcement & Monitoring**](Lab-02-Part-2-DLP-Enforcement/README.md)

> **⚠️ PREREQUISITE**: Complete Part 1 and verify DLP policy sync is complete before starting Part 2

**Duration**: 1-2 hours

**Activities**:

- Enable DLP in scanner content scan job
- Run scanner with DLP policy detection
- Interpret DLP results in scanner reports
- Monitor DLP activity in Activity Explorer

➡️ **[Start Lab 02 - Part 2](Lab-02-Part-2-DLP-Enforcement/README.md)**

---

## 🎯 Combined Learning Objectives

By the end of Lab 02 (both parts), you will be able to:

1. **Policy Creation**: Create custom DLP policies for on-premises repositories
2. **Rule Configuration**: Configure DLP rules with sensitive information type conditions
3. **Action Types**: Implement different enforcement actions (block vs audit)
4. **Scanner Integration**: Enable DLP policy detection in scanner content scan jobs
5. **Scan Execution**: Run scans with DLP policy application
6. **Results Analysis**: Interpret DLP detection results in scanner reports
7. **Activity Monitoring**: Monitor DLP activity using Activity Explorer

---

## ⚠️ Important: DLP Policy Sync Requirements

**Why Two Parts?**

DLP policies for on-premises repositories require **1-2 hours** for synchronization between the Purview cloud service and the on-premises scanner infrastructure. This synchronization cannot be accelerated.

**Sync Process**:

1. ✅ **Part 1**: Create DLP policy in Purview portal
2. ⏳ **Wait 1-2 hours**: Policy syncs to scanner infrastructure (mandatory wait)
3. ✅ **Part 2**: Enable DLP in scanner and run enforcement scans

**What Happens During Sync**:

- DLP policy distributes to Purview service endpoints
- Scanner infrastructure downloads policy configuration
- Policy becomes available for on-premises enforcement

> **� Do NOT skip the sync wait**: Attempting to run DLP scans before sync completes will result in no DLP detections and failed enforcement.

---

## 📚 Key Concepts

### DLP Policy Components

**Policy**: Container for one or more rules that define how to protect sensitive data

- **Name**: Lab-OnPrem-Sensitive-Data-Protection
- **Location**: On-premises repositories (file shares, Azure Files)
- **Scope**: Full directory (all users and groups)

**Rules**: Specific conditions and actions for sensitive data protection

- **Block-Credit-Card-Access**: Detects credit card numbers → Blocks file access
- **Audit-SSN-Access**: Detects Social Security Numbers → Logs activity only

**Sensitive Information Types (SITs)**: Pre-built patterns that detect sensitive data

- Credit Card Number (Luhn validation, 16 digits)
- U.S. Social Security Number (XXX-XX-XXXX format)

### Enforcement vs Audit Modes

**Block Enforcement** (Credit Cards):

- Scanner detects sensitive content
- Applies restrictive NTFS permissions
- Generates alerts and logs
- Prevents unauthorized access

**Audit Only** (SSNs):

- Scanner detects sensitive content
- Logs detection in reports
- Generates alerts
- **Does NOT modify file permissions**
- Used for discovery and monitoring

### Test Mode vs Enforce Mode

> **💡 Consultancy Best Practice**: Lab 02 - Part 2 uses **Test mode** (detection only) instead of **Enforce mode** (blocking) to demonstrate safe DLP deployment.

**Test Mode** (Recommended for consultancies):

- Scanner detects DLP policy matches
- Logs all detections in reports and Activity Explorer
- **Does NOT apply blocking actions**
- Generates `Information Type Name` and `Applied Label` in CSV reports
- Safe for client environments with no business disruption

**Enforce Mode** (Production deployment):

- Scanner detects DLP policy matches
- **Applies all configured actions** (block, quarantine, restrict)
- Modifies file permissions and access controls
- Requires careful testing and stakeholder approval

---

## 🚀 Getting Started

### Option 1: Complete Both Parts (Recommended)

1. **Start Part 1**: Create DLP policy in Purview portal
2. **Wait 1-2 hours**: Allow policy sync to complete
3. **Verify sync**: Check Purview portal for sync completion
4. **Start Part 2**: Enable DLP in scanner and run enforcement scans

### Option 2: Split Across Sessions

**Session 1**:

- Complete Part 1 (30-45 minutes)
- Trigger DLP policy sync
- End session

**Session 2** (next day or after 1-2 hours):

- Verify sync completion
- Complete Part 2 (1-2 hours)

---

## 📖 Detailed Instructions

### [📘 Lab 02 - Part 1: DLP Policy Creation](Lab-02-Part-1-DLP-Policy-Creation/README.md)

Complete step-by-step instructions for:

- Navigating Purview DLP portal
- Creating custom DLP policies
- Configuring rules with sensitive information types
- Setting up notifications and alerts
- Verifying policy sync requirements

### [📗 Lab 02 - Part 2: DLP Enforcement & Monitoring](Lab-02-Part-2-DLP-Enforcement/README.md)

Complete step-by-step instructions for:

- Enabling DLP in scanner content scan jobs
- Running scans with DLP policy detection
- Interpreting DLP results in scanner reports
- Monitoring DLP activity in Activity Explorer
- Understanding Test mode vs Enforce mode

---

## ✅ Success Criteria

After completing both parts of Lab 02, you should have:

### Part 1 Completion

- [ ] DLP policy **Lab-OnPrem-Sensitive-Data-Protection** created
- [ ] Two rules configured: Block-Credit-Card-Access and Audit-SSN-Access
- [ ] Policy location set to **On-premises repositories**
- [ ] Policy sync status verified (no "Sync in progress" message)

### Part 2 Completion

- [ ] DLP enabled in scanner content scan job
- [ ] Scan completed with DLP policy detection
- [ ] Scanner CSV reports show `Information Type Name` column populated
- [ ] Activity Explorer displays DLP matches for on-premises repositories
- [ ] Credit Card and SSN detections confirmed in reports

---

## 🚀 Next Steps

After completing Lab 02 (both parts):

**➡️ [Proceed to Lab 03: Retention Labels & Data Lifecycle Management](../Lab-03-Retention-Labels/README.md)**

In Lab 03, you will:

- Create retention labels for data lifecycle management
- Configure auto-apply policies for on-premises repositories
- Test retention label application in SharePoint Online
- Understand retention label limitations for on-premises file shares

---

## 📚 Reference Documentation

- [Microsoft Purview DLP for On-Premises Repositories](https://learn.microsoft.com/en-us/purview/dlp-on-premises-scanner-learn)
- [DLP Policy Configuration](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)
- [Sensitive Information Types Reference](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)
- [Activity Explorer Documentation](https://learn.microsoft.com/en-us/purview/data-classification-activity-explorer)
- [Information Protection Scanner - DLP Integration](https://learn.microsoft.com/en-us/purview/deploy-scanner-configure-install)

---

## 🤖 AI-Assisted Content Generation

This lab navigation guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating the latest Microsoft Purview DLP documentation and best practices for on-premises repository protection as of October 2025.

*AI tools were used to enhance productivity and ensure comprehensive coverage of DLP configuration procedures while maintaining technical accuracy and current portal navigation steps.*
