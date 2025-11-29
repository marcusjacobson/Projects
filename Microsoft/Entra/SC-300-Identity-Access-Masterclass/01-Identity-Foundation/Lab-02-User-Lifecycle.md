# Lab 02: User Lifecycle Management

**Skill:** Create, configure, and manage users
**Estimated Time:** 45 Minutes

---

## 📋 Lab Overview

**Scenario:** Contoso Corp is hiring 50 new employees for the "Sales" and "Marketing" departments. You need to create these users efficiently and ensure they are automatically assigned to the correct groups based on their department.

In this lab, you will use PowerShell to bulk create users and then use the Portal to configure Dynamic Groups.

### 🎯 Objectives

- Bulk create users using a CSV file and PowerShell.
- Create Dynamic Security Groups based on user attributes.
- Verify dynamic membership processing.

---

## 🔐 Licensing & RBAC Requirements

| Requirement | Details |
| :--- | :--- |
| **License** | **Microsoft Entra ID P1** (Required for Dynamic Groups) |
| **Role** | **User Administrator** or **Global Administrator** |

> **💡 Exam Tip:**
> **Dynamic Groups** require a **P1 license** for *every unique user* that is a member of a dynamic group. You cannot manually add or remove members from a dynamic group; membership is calculated solely by the rule.

---

## 📝 Lab Steps

### Task 1: Prepare the CSV File

1. Create a file named `users.csv` on your computer with the following content:

```csv
UserPrincipalName,DisplayName,Department,JobTitle,Password
alex.wilber@<YOUR_TENANT>.onmicrosoft.com,Alex Wilber,Sales,Sales Associate,P@ssword123!
bianca.pisani@<YOUR_TENANT>.onmicrosoft.com,Bianca Pisani,Sales,Sales Manager,P@ssword123!
christie.cline@<YOUR_TENANT>.onmicrosoft.com,Christie Cline,Marketing,Marketing Lead,P@ssword123!
david.so@<YOUR_TENANT>.onmicrosoft.com,David So,Marketing,Designer,P@ssword123!
```

> **⚠️ Important**: Replace `<YOUR_TENANT>` with your actual tenant name (e.g., `contoso-labs.com`).

### Task 2: Bulk Create Users via PowerShell

1. Open PowerShell as Administrator.
2. Connect to Microsoft Graph:
  
    ```powershell
    Connect-MgGraph -Scopes "User.ReadWrite.All"
    ```

3. Run the following script to import the users:

    ```powershell
    $users = Import-Csv "C:\path\to\users.csv"
    
    foreach ($user in $users) {
        $userParams = @{
            AccountEnabled = $true
            DisplayName = $user.DisplayName
            MailNickname = $user.UserPrincipalName.Split("@")[0]
            UserPrincipalName = $user.UserPrincipalName
            Department = $user.Department
            JobTitle = $user.JobTitle
            PasswordProfile = @{
                ForceChangePasswordNextSignIn = $true
                Password = $user.Password
            }
        }
        
        $newUser = New-MgUser -BodyParameter $userParams
        Write-Host "Created user: $($newUser.DisplayName)" -ForegroundColor Green
    }
    ```

> **💡 Note**: Assigning the result to `$newUser` suppresses the default table output, keeping your console clean.

### Task 3: Create Dynamic Groups (Portal)

Now that we have users with "Department" attributes, let's automate group membership.

1. Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com).
2. Navigate to **Identity** > **Groups** > **All groups**.
3. Click **New group**.
    - **Group type**: Security.
    - **Group name**: `Dynamic-Sales-Team`.
    - **Membership type**: **Dynamic User**.
4. Click **Add dynamic query**.
5. **Rule syntax**:
    - Property: `department`.
    - Operator: `Equals`.
    - Value: `Sales`.
6. The rule syntax box should show: `(user.department -eq "Sales")`
7. Click **Save** > **Create**.
8. Repeat the process for Marketing:
    - **Group name**: `Dynamic-Marketing-Team`.
    - **Rule**: `(user.department -eq "Marketing")`.

### Task 4: Verify Membership

1. Wait 1-2 minutes for the dynamic processing to run.
2. Open the `Dynamic-Sales-Team` group.
3. Click **Members**.
4. Verify that **Alex Wilber** and **Bianca Pisani** are listed.
5. Open the `Dynamic-Marketing-Team` group and verify **Christie** and **David**.

---

## 🔍 Troubleshooting

- **Script fails?**: Ensure the `UserPrincipalName` in your CSV matches your actual tenant domain exactly.
- **"Could not load type..." error?**: This indicates a version mismatch in the Microsoft Graph PowerShell modules. Run the following commands to fix it, then **restart your PowerShell terminal**:

    ```powershell
    Install-Module Microsoft.Graph.Authentication -Force -AllowClobber -Scope CurrentUser
    Install-Module Microsoft.Graph.Users -Force -AllowClobber -Scope CurrentUser
    ```

- **Members not showing?**: Dynamic group processing can take a few minutes (up to 24 hours in massive tenants, but usually fast in labs). Check the **Overview** page of the group for the "Last updated" timestamp.

## 🤖 AI-Assisted Content Generation

This lab guide was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for SC-300 certification preparation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exam objectives while maintaining technical accuracy.*
