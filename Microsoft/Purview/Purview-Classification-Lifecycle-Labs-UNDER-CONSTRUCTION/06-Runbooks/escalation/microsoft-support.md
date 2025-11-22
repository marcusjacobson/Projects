# Escalation Workflow: Microsoft Support

## Document Information

**Purpose**: Engaging Microsoft Support for Purview issues  
**Decision Time**: 15 minutes (determining if escalation needed)  
**Last Updated**: 2025-11-11

## When to Escalate

Open Microsoft Support case when:

- Issue cannot be resolved after 2 hours of troubleshooting.
- Microsoft service health shows active incidents affecting your operations.
- Issue affects multiple tenants or sites (potential service-wide issue).
- Data integrity concerns or potential data loss.
- Product capability questions beyond available documentation.
- Security-related issues or concerns.

## Support Case Priority Levels

| Severity | Criteria | Response Time | Example |
|----------|----------|---------------|---------|
| **A (Critical)** | Production down, major business impact | 1 hour | Complete classification system failure |
| **B (High)** | Significant degradation, time-sensitive | 2 hours | Classification not working for key sites |
| **C (Normal)** | Minor impact, workaround available | Next business day | Configuration questions, optimization |

## Required Information Before Opening Case

Collect this information before contacting support:

**Environment Details:**

- Tenant ID (find in Azure Portal).
- Subscription ID.
- Affected site URLs or resource names.
- Version numbers of PowerShell modules used.

**Issue Details:**

- Complete error messages with timestamps.
- Screenshots showing the issue.
- Steps to reproduce the problem.
- When issue first started.
- Changes made recently (if any).

**Troubleshooting Completed:**

- List of runbooks followed.
- Resolution steps attempted.
- Results of each troubleshooting step.
- Relevant log files.

## Opening a Support Case

### Option 1: Microsoft 365 Admin Center

Navigate to support section.

- Go to [admin.microsoft.com](https://admin.microsoft.com).
- Click **Support** → **New service request**.
- Select **Microsoft Purview** or **Information Protection**.
- Describe issue clearly and concisely.
- Attach collected diagnostic information.
- Select appropriate severity level.

### Option 2: Azure Portal (For Azure-Related Issues)

Navigate to support.

- Go to [portal.azure.com](https://portal.azure.com).
- Click **Help + support** → **New support request**.
- Select **Technical** issue type.
- Choose appropriate service (Azure AD, SharePoint, etc.).
- Complete issue details and diagnostic information.

### Option 3: PowerShell (For Programmatic Case Creation)

```powershell
# Note: Requires appropriate Azure PowerShell modules and permissions
# This is an advanced option - UI methods are typically sufficient
```

## Working with Microsoft Support

**Best Practices:**

- Respond promptly to support engineer questions.
- Provide requested diagnostic information quickly.
- Schedule screen-sharing sessions when offered.
- Document all recommendations and actions taken.
- Request confirmation before making significant changes.

**Communication:**

- Use case portal for all formal communications.
- Email responses are tracked automatically.
- Phone calls should be followed up with written summary.

## Case Resolution and Closure

**Before Closing Case:**

- Verify issue is fully resolved in your environment.
- Document root cause and resolution steps.
- Update relevant runbooks with new information discovered.
- Share lessons learned with team.

**Post-Resolution:**

- Complete satisfaction survey if sent.
- Save case number and resolution summary.
- Update internal documentation with case reference.

## Internal Escalation

If Microsoft Support case is not progressing:

- Request escalation to support manager after 24 hours.
- Involve your Microsoft Technical Account Manager (TAM) if available.
- Escalate through your Microsoft account team.

## Document History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-11-11 | 1.0 | Initial creation | Marcus Jacobson |

---

*This document is part of the Microsoft Purview Classification Lifecycle Labs operational documentation.*
