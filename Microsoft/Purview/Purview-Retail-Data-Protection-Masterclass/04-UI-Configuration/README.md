# UI Configuration Labs (Manual)

This section contains step-by-step guides for configuring Microsoft Purview using the Microsoft Purview compliance portal (click-ops). These labs are designed to build your understanding of the UI before moving to automation.

## 📚 Lab Index

| Lab ID | Title | Description |
|--------|-------|-------------|
| **Lab 01** | [Configure Custom SITs](01-Data-Classification/Lab-01-Custom-SITs.md) | Create the "Loyalty ID" regex pattern and keyword list. |
| **Lab 02** | [Configure Sensitivity Labels](02-Information-Protection/Lab-02-Configure-Labels.md) | Create and publish the 4-Tier taxonomy manually. |
| **Lab 03** | [Configure Auto-Labeling](02-Information-Protection/Lab-03-Auto-Labeling.md) | Set up service-side auto-labeling for data at rest. |
| **Lab 04** | [Configure DLP Policies](03-Data-Loss-Prevention/Lab-04-DLP-Policies.md) | Create the PCI-DSS blocking policy for Teams and Exchange. |

## 🛑 Before You Begin

- Ensure you have completed the **Day Zero Setup** (`01-Day-Zero-Setup`).
- Ensure you have generated test data (`02-Data-Foundation`).

## 📝 General Instructions

1.  Navigate to the **Microsoft Purview compliance portal** (purview.microsoft.com).
2.  Follow the steps in each lab document.
3.  Use the **Test Data** generated in the previous section to validate your policies.
4.  **Be Patient**: Policy changes can take 1-24 hours to take effect.

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for manual Purview configuration.

*AI tools were used to enhance productivity and ensure comprehensive coverage of UI configuration steps while maintaining technical accuracy.*
