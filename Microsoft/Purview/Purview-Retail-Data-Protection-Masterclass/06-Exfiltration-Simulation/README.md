# Exfiltration Simulation Labs

This section contains scenarios to test the effectiveness of your Data Loss Prevention (DLP) policies. You will act as a "Bad Actor" (or negligent employee) attempting to leak sensitive data.

## 🧪 Scenarios

### Scenario 1: The "USB" Drop
- **Goal**: Copy a file containing Credit Card numbers to a USB drive.
- **Expected Result**: Endpoint DLP should block the copy action and display a toast notification.
- **Prerequisite**: Endpoint DLP enabled and policy applied to your device.

### Scenario 2: The "Personal Cloud" Upload
- **Goal**: Upload a "Highly Confidential" file to a personal Google Drive or Dropbox.
- **Expected Result**: Edge/Chrome (with extension) should block the upload.

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
    .\scripts\Simulate-Exfiltration.ps1 -Action Generate
    ```
2.  **Attempt Exfiltration**:
    - Try to copy `HoneyFile_CC.docx` to a USB drive.
    - Try to attach `HoneyFile_CC.docx` to a personal email.
3.  **Review Audits**:
    - Go to **Purview Portal** > **Data Loss Prevention** > **Activity Explorer**.
    - Verify the events are logged.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for security control validation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of exfiltration scenarios while maintaining technical accuracy.*
