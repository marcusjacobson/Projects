# Supplemental IaC Labs: DevSecOps for Purview

This section demonstrates how to manage Microsoft Purview configurations using **Infrastructure as Code (IaC)**. Instead of clicking through the portal, you define your policies in code (PowerShell/JSON) and deploy them via Azure DevOps Pipelines.

## 🏗️ Architecture

We use a **Pipeline-Script** pattern:
1.  **YAML Pipeline**: Defines the trigger, variables, and execution steps.
2.  **PowerShell Script**: The logic that interacts with the Microsoft Graph API.
3.  **Service Connection**: Authenticates the pipeline to the tenant using the Service Principal.

## 📂 Directory Structure

| Folder | Content |
|--------|---------|
| `Pipeline/` | Azure DevOps YAML pipeline definitions (`.yml`). |
| `Scripts/` | PowerShell scripts executed by the pipelines (`.ps1`). |
| `Templates/` | JSON configuration files for SITs and Policies. |

## 🧪 Labs

### Lab 01: Automated Custom SIT Deployment
- **Goal**: Deploy the "Loyalty ID" regex pattern using a pipeline.
- **Files**:
    - `Data-Classification/Deploy-Custom-SITs/Pipeline/deploy-custom-sit.yml`
    - `Data-Classification/Deploy-Custom-SITs/Scripts/New-PurviewCustomSIT.ps1`

### Lab 02: Automated Auto-Labeling Policy
- **Goal**: Create a service-side auto-labeling policy for SharePoint.
- **Files**:
    - `Information-Protection/Deploy-AutoLabeling-Policies/Pipeline/deploy-auto-labeling.yml`
    - `Information-Protection/Deploy-AutoLabeling-Policies/Scripts/New-AutoLabelingPolicy.ps1`

## 🚀 How to Run

1.  **Create Service Connection**: In Azure DevOps, create a Service Connection using your Service Principal credentials. Name it `Purview-Service-Connection`.
2.  **Import Pipeline**: Create a new pipeline in Azure DevOps and select the YAML file from this repository.
3.  **Run Pipeline**: Execute the pipeline. It will authenticate and deploy the configuration.

## ⚠️ Prerequisites

- **Azure DevOps Organization**.
- **Service Principal** with `InformationProtectionPolicy.ReadWrite.All` (and others listed in `00-Prerequisites`).
- **Self-Hosted Agent** or **Microsoft-Hosted Agent** (requires installing modules).

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating best practices for Azure DevOps automation.

*AI tools were used to enhance productivity and ensure comprehensive coverage of IaC patterns while maintaining technical accuracy.*
