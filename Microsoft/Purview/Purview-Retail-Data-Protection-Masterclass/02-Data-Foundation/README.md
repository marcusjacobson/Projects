# Data Foundation: Generating High-Fidelity Test Data

To effectively test Data Loss Prevention (DLP) and Exact Data Match (EDM) policies, we need realistic test data. "Lorem Ipsum" text is insufficient because modern DLP engines look for specific patterns, checksums (Luhn algorithm), and proximity to keywords.

## 🎯 Data Strategy

We will generate a dataset simulating a Retail Customer Database containing:
- **Customer Names** (First, Last)
- **Credit Card Numbers** (Luhn-valid Visa, Mastercard, Amex)
- **Email Addresses**
- **Physical Addresses**
- **Loyalty IDs** (Custom pattern for Regex testing)

## 🛠️ Tools Included

### `scripts/Generate-RetailData.ps1`
This PowerShell script generates a CSV file containing thousands of synthetic customer records.
- **Luhn Validation**: Ensures all credit card numbers pass the Luhn check, triggering high-confidence DLP matches.
- **Keyword Injection**: Adds context keywords like "CVV", "Expiry", "Billing" to trigger proximity rules.
- **Format Variety**: Can output CSV, JSON, and simple text files.

### `scripts/Upload-TestDocs.ps1`
This script takes the generated data and uploads it to:
- **SharePoint Online**: Creates a "Retail Operations" site and uploads files.
- **OneDrive**: Uploads files to the current user's OneDrive.
- **Teams**: Posts snippets of data to a Teams channel (for Teams DLP testing).

## 🧪 Lab Instructions

1.  **Generate the Seed Data**:
    ```powershell
    .\scripts\Generate-RetailData.ps1 -Count 1000 -OutputPath ".\Output\CustomerDB.csv"
    ```
2.  **Review the Data**: Open the CSV and verify the credit card numbers look real (but are fake).
3.  **Upload to M365**:
    ```powershell
    .\scripts\Upload-TestDocs.ps1 -SourcePath ".\Output\CustomerDB.csv" -SiteUrl "https://yourtenant.sharepoint.com/sites/RetailOps"
    ```

## ⚠️ Security Warning
While this data is synthetic, it looks real to security tools. **Do not upload this data to production environments** unless you want to trigger real alerts. Always use a dedicated test tenant or sandbox.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for synthetic data generation in security testing.

*AI tools were used to enhance productivity and ensure comprehensive coverage of data generation requirements while maintaining technical accuracy.*
