# Lab 15: Sign-in Logs & Troubleshooting

**Skill:** Monitor and troubleshoot authentication
**Estimated Time:** 30 Minutes

---

## 📋 Lab Overview

**Scenario:** Users are reporting they cannot sign in. You need to investigate why. Is it a bad password? Conditional Access blocking them? Identity Protection?

In this lab, you will use the **Sign-in Logs** to diagnose the issues we simulated in previous labs.

### 🎯 Objectives

- Analyze "Interactive" vs "Non-Interactive" sign-ins.
- Diagnose a Conditional Access failure.
- Diagnose an Identity Protection block.
- Use filters to find specific events.

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P1** (Required for >7 days retention and advanced reports) |
| **Role** | **Reports Reader**, **Security Reader**, or **Global Administrator** |

> **💡 Exam Tip:**
> **Retention**:
>
> - **Free**: 7 days.
> - **P1/P2**: 30 days.
> - **Archival**: To keep logs longer (e.g., 1 year), you must export them to **Log Analytics** or **Storage Account**.

---

## 📝 Lab Steps

### Task 1: Analyze a Success

1. Navigate to **Entra ID** > **Monitoring & health** > **Sign-in logs**.
2. Find a recent **Success** event for **Alex Wilber**.
3. Click on the entry to open the details pane.
4. **Basic Info**: Check IP address, Location, and Client App.
5. **Authentication Details**: Click this tab.
    - Observe the steps: "First factor requirement satisfied", "MFA requirement satisfied".
    - This proves MFA was performed.

### Task 2: Analyze a Failure (Conditional Access)

1. Find a **Failure** event (Status: Failure).
2. Look for one where the **Sign-in error code** is `53003` (Access has been blocked by Conditional Access policies).
3. Click the entry.
4. Click the **Conditional Access** tab.
5. It will list all policies.
    - **Success**: Policy applied and passed.
    - **Failure**: Policy applied and blocked access.
    - **Not Applied**: Conditions didn't match.
6. Identify which policy caused the block (e.g., "Block Legacy Auth").

### Task 3: Analyze a Failure (Identity Protection)

1. Look for an event with error code `50126` (Invalid username or password) or a risk-related error.
2. If you simulated the Tor Browser sign-in (Lab 07), look for that event.
3. Click the **Security info** tab (if available) or check the **Risk State** column in the main view.
    - **Risk State**: "At risk".
    - **Risk Level**: "High".

### Task 4: Export Logs

1. Click the **Export Data** button in the top menu.
2. Select **Download CSV**.
3. Open the CSV in Excel.
4. *Exam Concept*: This is for manual, ad-hoc export. For automated, long-term retention, you configure **Diagnostic Settings**.

---

## 🔍 Troubleshooting

- **Logs empty?**: Logs can take 2-15 minutes to appear after the event.
- **"Non-Interactive" logs**: If you don't see an event in the main list, check the **Non-interactive user sign-ins** tab. This shows refresh tokens and background processes.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, ensuring alignment with the SC-300 exam objectives and Microsoft Entra best practices.

*AI tools were used to enhance productivity and ensure comprehensive coverage of monitoring and troubleshooting topics while maintaining technical accuracy and reflecting current Azure portal interfaces.*
