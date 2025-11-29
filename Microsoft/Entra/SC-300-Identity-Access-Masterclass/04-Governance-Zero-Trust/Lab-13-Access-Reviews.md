# Lab 13: Access Reviews

**Skill:** Plan and implement Access Reviews
**Estimated Time:** 45 Minutes

---

## 📋 Lab Overview

**Scenario:** Users often change jobs but keep their old permissions ("Permission Creep"). Contoso wants to ensure that members of the "Sales" team are reviewed every month. If they don't need access, they should be removed.

### 🎯 Objectives

-   Create an Access Review for a Group.
-   Configure "Self-Review" vs "Manager Review".
-   Perform a review.
-   Apply the results.

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P2** (Required for Access Reviews) |
| **Role** | **Identity Governance Administrator** or **Global Administrator** |

> **💡 Exam Tip:**
> **Fallback Reviewers**: Who does the review if the user has no manager? You must specify this.
> **Auto-apply results**: If enabled, users who are denied are automatically removed. If disabled, an admin must manually apply the changes.

---

## 📝 Lab Steps

### Task 1: Create Access Review

1.  Navigate to **Identity Governance** > **Access Reviews**.
2.  Click **+ New access review**.
3.  **Select what to review**: **Teams + Groups**.
4.  **Select teams and groups**: Select **Dynamic-Sales-Team**.
    *   *Note: Usually you review "Assigned" groups. Reviewing Dynamic groups is less common because membership is rule-based, but valid for checking if the rule is too broad.*
    *   *Better Scenario*: Let's create a static group named `Project-Alpha` and add Alex to it for this lab.
5.  **Scope**: **All users**.
6.  **Reviews**:
    *   **Reviewers**: **Group owners** or **Selected users**. Let's choose **Selected users** -> **Bianca Pisani**.
    *   **Duration**: 3 days.
    *   **Recurrence**: **One time** (for this lab).
7.  **Settings**:
    *   **Auto apply results to resource**: **Disable** (We want to see the results first).
    *   **If reviewers don't respond**: **Keep access**.
8.  **Review name**: `Review-Project-Alpha`.
9.  Click **Create**.

### Task 2: Perform the Review (Bianca)

1.  Sign in as **Bianca Pisani**.
2.  She should receive an email, or she can go to `https://myaccess.microsoft.com`.
3.  Click **Access reviews** on the left.
4.  Click **Review-Project-Alpha**.
5.  She sees **Alex Wilber**.
6.  Decision: **Deny** (Simulating that Alex is off the project).
7.  Reason: "Project completed".
8.  Click **Submit**.

### Task 3: Verify and Apply (Admin)

1.  Switch back to your **Admin** console.
2.  Navigate to the **Access Review** you created.
3.  Click **Results**.
4.  You should see Alex Wilber marked as **Denied**.
5.  Click **Apply results**.
6.  *Result*: Alex will be removed from the `Project-Alpha` group.

---

## 🔍 Troubleshooting

*   **Review not started?**: Access reviews can take up to 30 minutes to change from "Initializing" to "Active".
*   **"Dynamic Groups"**: If you review a dynamic group, you *cannot* remove members (because the rule adds them back). You can only update the user's attributes to make them fall out of scope. This is why static groups are better targets for Access Reviews.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, ensuring alignment with the SC-300 exam objectives and Microsoft Entra best practices.

*AI tools were used to enhance productivity and ensure comprehensive coverage of access review topics while maintaining technical accuracy and reflecting current Azure portal interfaces.*
