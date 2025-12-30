# Exfiltration Simulation Labs

This section contains scenarios to test the effectiveness of your Data Loss Prevention (DLP) policies. You will act as a "Bad Actor" (or negligent employee) attempting to leak sensitive data.

## 🧪 Scenarios

### Scenario 1: The "Personal Cloud" Upload
- **Goal**: Upload a file containing Credit Card numbers to a personal Google Drive or Dropbox account.
- **Expected Result**: Microsoft Edge should detect the sensitive content and block the upload (if browser-based DLP extensions are configured), or the activity should be logged in Activity Explorer for audit purposes.
- **Prerequisite**: DLP policies applied to M365 workloads.

### Scenario 2: The "External Email" Leak
- **Goal**: Attach a file containing PII data to an email sent to an external recipient.
- **Expected Result**: Exchange DLP should block the email and display a policy tip to the user.

### Scenario 3: The "Teams" Leak
- **Goal**: Paste a list of Credit Card numbers into a Teams chat with an external user.
- **Expected Result**: Teams DLP should block the message and show a "Message Blocked" policy tip.

## 🛠️ Simulation Tools

### `scripts/Simulate-Exfiltration.ps1`
This script generates a "Honey File" containing sensitive data and attempts to move it to various locations to trigger alerts.

### `scripts/Test-DlpRules.ps1`
This script runs the `Test-DlpPolicies` cmdlet (if available) to validate rule logic against specific text strings.

## 📝 Lab Instructions

1.  **Generate Honey File**:
    ```powershell
    # Navigate to scripts directory
    cd scripts

    # Generate Honey File
    .\Simulate-Exfiltration.ps1 -Action Generate
    ```
2.  **Attempt M365 Exfiltration Scenarios**:
    - Try to attach `HoneyFile_CC.docx` to an email sent to an external recipient.
    - Try to share `HoneyFile_CC.docx` externally via OneDrive or SharePoint.
    - Try to paste sensitive content into a Teams chat with an external user.
    - Try to upload `HoneyFile_CC.docx` to a personal cloud storage account via browser.
3.  **Review Audits**:
    - Go to **Purview Portal** > **Data Loss Prevention** > **Activity Explorer**.
    - Verify the M365 exfiltration attempts are logged and policy actions are recorded.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for security control validation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exfiltration scenarios while maintaining technical accuracy.*
