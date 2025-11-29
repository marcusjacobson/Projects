# Lab 03: Administrative Units & Delegation

**Skill:** Configure and manage administrative units
**Estimated Time:** 30 Minutes

---

## 📋 Lab Overview

**Scenario:** Contoso Corp has a "Paris Branch" office. The local IT Helpdesk in Paris needs to manage user passwords for Paris employees, but they should NOT have access to manage users in the New York headquarters or Global Admins.

In this lab, you will use **Administrative Units (AUs)** to implement this "Least Privilege" delegation model.

### 🎯 Objectives

- Create an Administrative Unit for the Paris Branch.
- Assign users to the Administrative Unit.
- Assign a scoped "User Administrator" role to a user over *only* that AU.
- Verify the restriction (Negative Testing).

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P1** (Required for AUs) |
| **Role** | **Privileged Role Administrator** or **Global Administrator** |

> **💡 Exam Tip:**
> Administrative Units are the cloud equivalent of **Organizational Units (OUs)** in Active Directory. They are used to restrict the *scope* of administrative roles. Without AUs, a "User Administrator" can manage *all* users in the tenant (except high-privilege admins).

---

## 📝 Lab Steps

### Task 1: Create the Administrative Unit

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com).
2. Navigate to **Entra ID** > **Roles & admins** > **Admin units**.
3. Click **+ Add**.
4. **Name**: `Paris Branch`.
5. **Description**: `Scope for Paris office users and devices`.
6. Click **Review + create** > **Create**.

### Task 2: Populate the AU

1. Open the **Paris Branch** AU you just created.
2. Click **Users** > **Add member**.
3. Select **Alex Wilber** and **Bianca Pisani** (from Lab 02).
4. Click **Select**.

### Task 3: Delegate Administration

Now we will make **David So** the admin for this unit.

1. Still inside the **Paris Branch** AU, click **Roles and administrators**.
2. Click **User Administrator**.
3. Click **Add assignments**.
4. Search for **David So**.
5. Click **Add**.

> **Note**: David So now holds the "User Administrator" role, but *only* within the scope of the "Paris Branch" AU.

### Task 4: Verify Delegation (The "Break-Fix" Test)

1. Open a new InPrivate/Incognito window.
2. Sign in as **David So** (`david.so@<YOUR_TENANT>.onmicrosoft.com`).
    - *Note: You may need to reset his password first if you didn't save it from Lab 02.*
3. **Positive Test**:
    - Navigate to **Identity** > **Roles & admins** > **Admin units**.
    - Click on **Paris Branch** > **Users**.
    - Select **Alex Wilber**.
    - Click **Reset password**.
    - **Result**: It should allow you to proceed because David is scoped to this AU.
4. **Negative Test**:
    - Navigate to **Identity** > **Users** > **All users**.
    - **Result**: You should observe that **Christie Cline** is NOT visible in the list (or the list may be empty).
    - *Note*: Because "Restrict access to Microsoft Entra administration portal" was enabled in Lab 01, David cannot browse the global user list using his default user permissions. He is restricted to seeing/managing only the users within his assigned Administrative Unit.

---

## 🔍 Troubleshooting

- **David can manage everyone?**: Check if David has a *tenant-level* role assigned. Go to his user profile > **Assigned roles**. He should only have the scoped role in the AU, not a global one.
- **Can't reset password?**: Ensure David has the "User Administrator" role. "Helpdesk Administrator" can also reset passwords but has different restrictions (cannot reset admins).

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for SC-300 certification preparation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exam objectives while maintaining technical accuracy.*
