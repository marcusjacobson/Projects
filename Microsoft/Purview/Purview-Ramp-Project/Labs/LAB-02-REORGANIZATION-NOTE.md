# Lab 02 Reorganization - DLP Configuration Split

## 📋 Overview

Lab 02 has been split into two parts to accommodate the mandatory **30-60 minute DLP policy synchronization wait time** that occurs after policy creation.

---

## 🔄 Lab Structure Change

### Previous Structure (Single Lab)

**Lab-02-DLP-Configuration** (2-3 hours)
- Step 1: Create DLP Policy
- Step 2: Enable DLP in Scanner
- Step 3: Run Enforcement Scan
- Step 4: View Activity Explorer
- Step 5: Test Enforcement

**Problem**: Students were instructed to wait 30-60 minutes in the middle of the lab, creating confusion about whether to proceed or wait.

### New Structure (Two-Part Lab)

**Lab 02 - Part 1: DLP Policy Creation** (30-45 min active + 30-60 min wait)
- Step 1: Create DLP Policy in Purview Portal
- **ENDS WITH**: Mandatory sync wait instruction
- **Duration**: Policy creation work plus sync wait time

**Lab 02 - Part 2: DLP Enforcement & Monitoring** (1-2 hours)
- **STARTS AFTER**: Policy sync completes
- Step 1: Verify DLP Policy Sync Completion
- Step 2: Enable DLP in Scanner Content Scan Job
- Step 3: Run Enforcement Scan
- Step 4: View Activity in Activity Explorer
- Step 5: Test DLP Enforcement

---

## ⏳ Key Improvement

**Clear Stopping Point**: Part 1 ends with a prominent **STOP** section explaining:
- Why you must wait (DLP policy sync timing)
- How long to wait (30-60 minutes typical)
- What NOT to do during the wait (restart scanner, run scans)
- How to verify sync completion
- When it's safe to proceed to Part 2

This prevents students from:
- Restarting services unnecessarily during sync
- Running scans before policies are ready
- Getting confused about whether to proceed or wait
- Wasting time troubleshooting "issues" that are just normal sync delays

---

## 📂 Folder Structure

```
Labs/
├── Lab-00-Environment-Setup/
├── Lab-01-Scanner-Deployment/
├── Lab-02-Part-1-DLP-Policy-Creation/      ← Policy creation + sync wait
│   └── README.md
├── Lab-02-Part-2-DLP-Enforcement/          ← Enforcement + monitoring
│   └── README.md
├── Lab-03-Retention-Labels/
├── Lab-04-Validation-Reporting/
└── Lab-05-Advanced-Remediation/
```

---

## 🎯 Student Experience

### Part 1 Experience

1. Create DLP policy (30-45 minutes)
2. See clear **STOP** message
3. Understand sync requirement
4. Take break / work on other tasks
5. Verify sync completion
6. Proceed to Part 2 when ready

### Part 2 Experience

1. Verify prerequisites (sync complete)
2. Enable DLP enforcement
3. Run scans with policies
4. Monitor and validate
5. Complete lab successfully

---

## ✅ Benefits

- **Clear expectations**: Students know exactly when to wait
- **Reduced confusion**: No ambiguity about "Sync in progress" messages
- **Better time management**: Can take breaks or work on other tasks during sync
- **Prevents errors**: Stops students from taking actions that interfere with sync
- **Realistic learning**: Reflects real-world deployment timing constraints

---

## 📚 Related Documentation

- Lab 02 - Part 1: `Labs/Lab-02-Part-1-DLP-Policy-Creation/README.md`
- Lab 02 - Part 2: `Labs/Lab-02-Part-2-DLP-Enforcement/README.md`

---

*Reorganization completed: October 24, 2025*
*Based on real-world testing showing DLP policy sync timing as hard requirement*
