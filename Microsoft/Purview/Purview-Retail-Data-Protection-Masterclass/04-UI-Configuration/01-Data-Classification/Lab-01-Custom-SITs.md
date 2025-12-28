# Lab 01: Configure Custom Sensitive Information Types (SITs)

In this lab, you will create a Custom Sensitive Information Type (SIT) to detect our proprietary "Retail Loyalty ID" format. This demonstrates how to extend Purview beyond the built-in types.

## 🎯 Objectives

- Create a Regex-based SIT for `RET-123456-X`.
- Add a keyword list to increase confidence.
- Test the SIT against sample data.

## 📋 Prerequisites

- **Global Administrator** or **Compliance Administrator** role.
- **Test Data** generated in `02-Data-Foundation`.

## 📝 Step-by-Step Instructions

### Part 1: Create the SIT

- Go to [purview.microsoft.com](https://purview.microsoft.com).
- Navigate to **Data classification** > **Classifiers** > **Sensitive info types**.
- Click **+ Create sensitive info type**.

**Step 1: Name and Description**

- **Name**: Retail Loyalty ID
- **Description**: Detects loyalty card numbers in the format RET-123456-X.
- Click **Next**.

**Step 2: Define Patterns**

- Click **+ Create pattern**.
- **Confidence level**: High confidence.
- **Primary element**:
    - Select **Regular expression**.
    - **Regex**: `RET-\d{6}-[A-Z]`
- **Supporting elements** (Optional but recommended):
    - Select **Keyword list**.
    - **Keywords**: Loyalty, Member, Rewards, Points, Retail.
    - **Character proximity**: 300 characters.
- Click **Create**.
- Click **Next**.

**Step 3: Review and Finish**

- Click **Create**.

### Part 2: Test the SIT

- In the list of Sensitive info types, find **Retail Loyalty ID**.
- Click on it to open the details pane.
- Click **Test**.
- Upload the `CustomerDB.csv` file generated in `02-Data-Foundation`.
- Click **Test**.
- **Validation**: You should see matches for the Loyalty ID column.

## ✅ Validation

- Ensure the test returns matches.
- Note the confidence level (High vs Medium) based on whether keywords were found nearby.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for custom classification.

*AI tools were used to enhance productivity and ensure comprehensive coverage of SIT configuration steps while maintaining technical accuracy.*
