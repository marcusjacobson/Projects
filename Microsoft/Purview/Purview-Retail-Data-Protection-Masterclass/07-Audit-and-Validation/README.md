# Audit and Validation

After configuring policies and running simulations, you must validate that the system is working as expected. This section guides you through the Microsoft Purview reporting tools.

## 📊 Key Tools

### Content Explorer
- **Purpose**: Visibility into *where* sensitive data resides.
- **Usage**: Verify that your "RetailCustomerDB" SIT is correctly identifying files in SharePoint and OneDrive.
- **Lab**: Navigate to **Data classification** > **Content explorer**. Drill down into SharePoint to find your generated test files.

### Activity Explorer
- **Purpose**: Visibility into *what* is happening to labeled data.
- **Usage**: Verify that your "Exfiltration Simulation" events (Label Applied, File Copied, DLP Rule Matched) are logged.
- **Lab**: Navigate to **Data classification** > **Activity explorer**. Filter by "Activity type" > "DLPRuleMatch".

## 📝 Validation Checklist

| Check | Tool | Success Criteria |
|-------|------|------------------|
| **Data Discovery** | Content Explorer | Test files are discovered and classified as "Highly Confidential". |
| **Label Application** | Activity Explorer | "Label applied" events appear for auto-labeling policies. |
| **DLP Blocking** | Activity Explorer | "DLPRuleMatch" events appear for the USB copy attempt. |
| **False Positives** | Content Explorer | Ensure "General" files are NOT misclassified as "Confidential". |

## 🔍 Troubleshooting

- **No Events?**: Check if the Audit Log is enabled (`01-Day-Zero-Setup`).
- **Delay?**: Remember that Activity Explorer can have a latency of 24 hours.
- **Wrong Policy?**: Use the "Match" details in Activity Explorer to see which rule triggered.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for compliance auditing.

*AI tools were used to enhance productivity and ensure comprehensive coverage of validation tools while maintaining technical accuracy.*
