# Lab 03: App Integration

This lab secures the application layer of the tenant. We will implement governance controls to prevent illicit consent grants (Shadow IT) and deploy a secure non-human identity (Service Principal) for automation tasks.

## 🎯 Lab Objectives

- **App Consent Governance**: Restrict users from consenting to unverified third-party apps.
- **Admin Consent Workflow**: Enable a process for users to request access to blocked apps.
- **Service Principal Security**: Create a "Reporting Automation" identity secured with a self-signed certificate (not a secret).
- **Least Privilege**: Assign only `AuditLog.Read.All` to the Service Principal.

## 📚 Microsoft Learn & GUI Reference

- **Consent and Permissions**: [Configure how users consent to applications](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-user-consent)
- **Admin Consent Workflow**: [Configure the admin consent workflow](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-admin-consent-workflow)
- **Service Principals**: [Application and service principal objects in Entra ID](https://learn.microsoft.com/en-us/entra/identity-platform/app-objects-and-service-principals)

> **💡 GUI Path**: `entra.microsoft.com` > **Applications** > **Enterprise applications** > **Consent and permissions**

## 📋 Prerequisites

- Completion of **Lab 01**.
- **OpenSSL** or PowerShell PKI commands (included in script) to generate certificates.

## ⏱️ Estimated Duration

- **20 Minutes**

## 📝 Lab Steps

### Step 1: Configure App Consent Governance

We will restrict user consent to only apps from verified publishers that require low-impact permissions.

**Context**: Attackers often use "Illicit Consent Grants" (fake apps asking for "Read your email") to bypass MFA. By restricting consent, we stop users from accidentally handing over the keys to their data. The Admin Consent Workflow ensures productivity isn't blocked, just governed.

1. Run `Configure-AppConsentGovernance.ps1`.
2. This sets "Users can consent to apps" to **No** (or restricted).
3. It enables the **Admin Consent Workflow**, allowing users to request approval.

### Step 2: Deploy Reporting Service Principal

We will create an identity for a hypothetical "Daily Reporting Job". Instead of a password (client secret), we will use a certificate.

**Context**: Hard-coded passwords (Client Secrets) in scripts are a major security risk. Certificates are more secure because they are harder to steal and easier to manage. We also apply "Least Privilege" here—this bot only needs to read logs, so that's all we give it.

1. Run `Deploy-ReportingServicePrincipal.ps1`.
2. This script will:
    - Generate a self-signed certificate.
    - Create an App Registration (`APP-Reporting-Automation`).
    - Upload the certificate public key.
    - Create a Service Principal.
    - Assign `AuditLog.Read.All` (Application Permission).

## ✅ Validation

- **Consent**: Try to sign in to a new third-party app (e.g., Graph Explorer) as a standard user. You should see an "Approval Required" screen.
- **Service Principal**: Verify `APP-Reporting-Automation` exists in **App registrations**. Check **Certificates & secrets** to see the uploaded cert.

## 🚧 Troubleshooting

- **"Privileges not sufficient"**: You need Global Admin or Application Admin roles.
- **"Certificate generation failed"**: Ensure you are running as Administrator if using `New-SelfSignedCertificate`.

## 🎓 Learning Objectives Achieved

- **Shadow IT Prevention**: You stopped users from blindly granting data access to random apps.
- **Non-Human Security**: You learned why Certificates > Secrets for Service Principals (they expire, can't be phished easily).

## 🤖 AI-Assisted Content Generation

This Entra Zero Trust RBAC Simulation module was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content, PowerShell automation scripts, and lab scenarios were generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**, incorporating Microsoft Entra best practices and Zero Trust principles.

*AI tools were used to enhance productivity and ensure comprehensive coverage of identity security scenarios while maintaining technical accuracy and reflecting real-world enterprise configurations.*
