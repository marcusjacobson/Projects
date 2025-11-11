# Lab 5: Runbooks and Operational Documentation

## Overview

This lab provides comprehensive operational documentation, runbooks, and standard operating procedures (SOPs) for maintaining and troubleshooting Microsoft Purview classification systems in production environments. It focuses on operational excellence, incident response, and sustainable maintenance practices.

**Time Investment**: 60-90 minutes (reading and understanding operational procedures)

**Learning Objectives**:

- Understand operational runbook structure and best practices.
- Learn incident response procedures for common Purview issues.
- Master troubleshooting techniques for classification failures.
- Implement proactive health checks and monitoring.
- Establish escalation workflows and support processes.
- Plan disaster recovery and business continuity procedures.

## What You'll Learn

### Operational Foundations

**Runbook Categories**:

| Category | Purpose | Use Cases |
|----------|---------|-----------|
| **Incident Response** | React to system issues and failures | Classification errors, permission issues, API throttling |
| **Maintenance Procedures** | Proactive system care and optimization | Health checks, log cleanup, certificate renewal |
| **Escalation Workflows** | When and how to escalate issues | Microsoft Support engagement, critical failures |
| **Health Checks** | Validate system health and performance | Daily validation, performance monitoring |
| **Disaster Recovery** | Restore operations after major incidents | Configuration backup, service restoration |

**Documentation Standards**:

| Standard | Purpose | Benefit |
|----------|---------|---------|
| **Consistent Structure** | All runbooks follow same format | Faster response during incidents |
| **Clear Prerequisites** | Required access and tools documented | Reduced delays in incident response |
| **Step-by-Step Instructions** | Detailed action items with validation | Consistent execution across team members |
| **Escalation Criteria** | When to involve next tier support | Appropriate resource allocation |
| **Success Validation** | How to verify resolution | Confirms issue is fully resolved |

### Operational Scenarios

This lab covers these critical operational scenarios:

**Incident Response**: Classification failures, permission denied errors, API throttling, scheduled task failures, workflow interruptions.

**Maintenance**: Regular health checks, log file cleanup, certificate renewal, SIT validation, label policy review.

**Escalation**: Microsoft Support engagement criteria, critical failure protocols, executive notification workflows.

**Health Monitoring**: Daily validation procedures, performance baseline tracking, capacity planning triggers.

**Disaster Recovery**: Configuration backup procedures, service restoration workflows, data recovery processes.

## Lab Structure

### Documentation Categories

```text
05-RunbooksAndDocs/
├── README.md (this file)
├── incident-response/
│   ├── classification-failure.md
│   ├── permission-denied.md
│   ├── api-throttling.md
│   ├── scheduled-task-failure.md
│   └── workflow-interruption.md
├── maintenance/
│   ├── daily-health-checks.md
│   ├── weekly-maintenance.md
│   ├── monthly-validation.md
│   └── certificate-renewal.md
├── escalation/
│   ├── microsoft-support.md
│   ├── critical-failures.md
│   └── executive-notification.md
├── health-checks/
│   ├── system-validation.md
│   └── performance-monitoring.md
└── disaster-recovery/
    ├── configuration-backup.md
    └── service-restoration.md
```

## Prerequisites

Before using these runbooks, ensure:

- Completed Labs 1-4 (basic understanding of Purview classification operations).
- Access to Microsoft Purview admin portal.
- Appropriate administrative permissions for troubleshooting actions.
- Familiarity with PowerShell scripts from previous labs.
- Understanding of your organization's support structure and escalation paths.

## Documentation Structure

Each runbook follows this standardized format:

**Header Section**:

- Document title and purpose.
- Severity level (Critical/High/Medium/Low).
- Estimated resolution time.
- Required permissions and prerequisites.

**Symptom Identification**:

- Common symptoms and error messages.
- How to recognize the issue.
- Impact assessment (service, users, data).

**Investigation Steps**:

- Data collection procedures.
- Log file locations and interpretation.
- Diagnostic commands and queries.
- Root cause analysis techniques.

**Resolution Procedures**:

- Step-by-step remediation actions.
- Validation of each step.
- Alternative approaches if primary fails.
- Rollback procedures if needed.

**Verification**:

- How to confirm issue is resolved.
- Validation tests to run.
- Expected results after resolution.

**Prevention**:

- How to prevent recurrence.
- Monitoring improvements.
- Process enhancements.

**Escalation Criteria**:

- When to escalate to next tier.
- Required information for escalation.
- Contact information and procedures.

## Incident Response Runbooks

### Classification Failure Runbook

**File**: `incident-response/classification-failure.md`

**When to Use**: Documents fail to classify properly, classification results are inconsistent, or bulk classification operations fail.

**Key Topics**:

- Troubleshooting permission issues on SharePoint sites.
- Validating SIT definitions and patterns.
- Investigating API throttling and rate limits.
- Resolving PnP PowerShell connection errors.
- Reviewing classification logs for error patterns.

### Permission Denied Runbook

**File**: `incident-response/permission-denied.md`

**When to Use**: Scripts report permission errors, users cannot access classified content, or administrative operations fail due to insufficient permissions.

**Key Topics**:

- Validating SharePoint site permissions.
- Checking Exchange Online admin roles.
- Verifying Azure AD group memberships.
- Resolving service principal permission issues.
- Testing API access with reduced scope.

### API Throttling Runbook

**File**: `incident-response/api-throttling.md`

**When to Use**: Operations fail with 429 (Too Many Requests) errors, scripts experience intermittent timeouts, or bulk operations are slower than expected.

**Key Topics**:

- Understanding Microsoft Graph API throttling limits.
- Implementing exponential backoff retry logic.
- Optimizing batch sizes for bulk operations.
- Monitoring throttling metrics and patterns.
- Scheduling operations during low-usage periods.

### Scheduled Task Failure Runbook

**File**: `incident-response/scheduled-task-failure.md`

**When to Use**: Scheduled PowerShell tasks fail to execute, tasks complete but with errors, or tasks run but produce no results.

**Key Topics**:

- Validating task credentials and permissions.
- Reviewing task execution logs and history.
- Testing script execution in task context.
- Fixing path and environment variable issues.
- Configuring proper error handling and notifications.

### Workflow Interruption Runbook

**File**: `incident-response/workflow-interruption.md`

**When to Use**: Workflow orchestration scripts fail mid-execution, checkpoint validations fail unexpectedly, or rollback procedures are needed.

**Key Topics**:

- Identifying failed workflow steps.
- Analyzing checkpoint validation failures.
- Determining safe restart points.
- Executing rollback procedures.
- Preventing cascading failures.

## Maintenance Procedures

### Daily Health Checks

**File**: `maintenance/daily-health-checks.md`

**When to Use**: Every business day to validate system health and catch issues early.

**Key Topics**:

- Validating PowerShell module versions.
- Checking connection to Purview services.
- Reviewing overnight scheduled task results.
- Monitoring log file growth.
- Quick classification test on sample data.

**Execution Time**: 10-15 minutes

### Weekly Maintenance

**File**: `maintenance/weekly-maintenance.md`

**When to Use**: Once per week for proactive system care and optimization.

**Key Topics**:

- Reviewing classification coverage metrics.
- Analyzing error patterns from logs.
- Validating SIT effectiveness and accuracy.
- Cleaning up old log files.
- Testing backup and restore procedures.

**Execution Time**: 30-45 minutes

### Monthly Validation

**File**: `maintenance/monthly-validation.md`

**When to Use**: Once per month for comprehensive system validation and planning.

**Key Topics**:

- Full classification audit across all sites.
- Retention label compliance review.
- Performance baseline comparison.
- Capacity planning assessment.
- Documentation and runbook updates.

**Execution Time**: 60-90 minutes

### Certificate Renewal

**File**: `maintenance/certificate-renewal.md`

**When to Use**: Before certificates expire (typically 60-90 days notice).

**Key Topics**:

- Identifying expiring certificates.
- Service principal certificate renewal.
- App registration credential updates.
- Testing service connectivity after renewal.
- Updating automation scripts with new credentials.

**Execution Time**: 20-30 minutes

## Escalation Workflows

### Microsoft Support Engagement

**File**: `escalation/microsoft-support.md`

**When to Use**: Issues cannot be resolved with internal troubleshooting, Microsoft service issues suspected, or guidance needed on product capabilities.

**Key Topics**:

- When to open a Microsoft Support case.
- Required information for effective support cases.
- Severity level selection criteria.
- Collecting diagnostic information.
- Working with Microsoft support engineers.

### Critical Failures

**File**: `escalation/critical-failures.md`

**When to Use**: System-wide classification failures, data integrity issues, security incidents, or service outages affecting business operations.

**Key Topics**:

- Defining critical failure criteria.
- Immediate response procedures.
- Communication protocols during incidents.
- Emergency escalation contacts.
- Post-incident review procedures.

### Executive Notification

**File**: `escalation/executive-notification.md`

**When to Use**: Issues with business impact requiring executive awareness, compliance violations, or major project delays.

**Key Topics**:

- Executive notification criteria.
- Impact assessment for leadership.
- Communication templates and formats.
- Status update frequency.
- Resolution confirmation procedures.

## Health Checks

### System Validation

**File**: `health-checks/system-validation.md`

**When to Use**: Regular validation of all system components and integrations.

**Key Topics**:

- PowerShell module health validation.
- Service connectivity testing (SharePoint, Exchange, Purview).
- SIT definition validation.
- Retention label policy checks.
- Scheduled task status verification.

**Validation Frequency**: Daily for critical components, weekly for full validation.

### Performance Monitoring

**File**: `health-checks/performance-monitoring.md`

**When to Use**: Ongoing monitoring of system performance and capacity.

**Key Topics**:

- Classification throughput metrics.
- API response time tracking.
- Script execution duration trends.
- Resource utilization monitoring.
- Capacity planning triggers.

**Monitoring Frequency**: Continuous with weekly trend analysis.

## Disaster Recovery

### Configuration Backup

**File**: `disaster-recovery/configuration-backup.md`

**When to Use**: Regular backups of Purview configurations, before major changes, or prior to testing.

**Key Topics**:

- Backing up SIT definitions.
- Exporting retention label configurations.
- Saving DLP policy settings.
- Documenting custom scripts and workflows.
- Version control for configurations.

**Backup Frequency**: Weekly automated backups, on-demand before changes.

### Service Restoration

**File**: `disaster-recovery/service-restoration.md`

**When to Use**: After major incidents requiring configuration restoration, service rebuilds, or disaster recovery activation.

**Key Topics**:

- Restoring SIT definitions from backup.
- Recreating retention labels and policies.
- Re-establishing scheduled tasks.
- Validating restored configurations.
- Testing service functionality post-restoration.

**Recovery Time Objective (RTO)**: 4-8 hours for full restoration.

## Using These Runbooks Effectively

### Team Training

**Onboarding New Team Members**:

- Review all incident response runbooks.
- Practice with simulated incidents.
- Shadow experienced team members.
- Validate access to required systems.

**Ongoing Training**:

- Monthly review of recent incidents and resolutions.
- Quarterly runbook review and updates.
- Practice disaster recovery procedures annually.

### Runbook Maintenance

**Update Triggers**:

- After each incident (lessons learned).
- When Microsoft updates Purview capabilities.
- After process improvements identified.
- Quarterly scheduled review.

**Version Control**:

- Document all runbook changes.
- Maintain change log in each document.
- Review changes with team before implementation.
- Archive superseded versions.

### Incident Management

**Response Process**:

1. Identify symptom and select appropriate runbook.
2. Follow investigation steps to determine root cause.
3. Execute resolution procedures with validation.
4. Verify issue is fully resolved.
5. Document incident and resolution in ticketing system.
6. Update runbook if new information discovered.

**Post-Incident Activities**:

- Conduct post-incident review.
- Identify prevention opportunities.
- Update monitoring and alerting.
- Share lessons learned with team.

## Best Practices

### Documentation Standards

- Keep runbooks concise and actionable.
- Use screenshots and examples where helpful.
- Include actual command examples, not just descriptions.
- Document "gotchas" and common mistakes.
- Link to related runbooks and resources.

### Response Effectiveness

- Practice runbook procedures during non-incident times.
- Time how long procedures take (update estimates).
- Validate all commands work as documented.
- Keep emergency contact information current.
- Test escalation procedures periodically.

### Continuous Improvement

- Review metrics: incident frequency, resolution time, recurrence.
- Identify opportunities for automation.
- Consolidate duplicate or overlapping runbooks.
- Remove obsolete procedures.
- Incorporate team feedback.

## Integration with Previous Labs

### Lab 1: Basic Classification

- Use Lab 1 scripts for health check validations.
- Reference classification logs for troubleshooting.
- Leverage test data creation for incident reproduction.

### Lab 2: Custom SITs

- Validate SIT definitions during health checks.
- Troubleshoot pattern matching issues.
- Backup and restore SIT configurations.

### Lab 3: Retention Labels

- Verify label application during validations.
- Troubleshoot label policy issues.
- Validate label coverage metrics.

### Lab 4: PowerShell Automation

- Leverage automation scripts in maintenance procedures.
- Use logging framework for incident investigation.
- Reference workflow orchestration for complex restorations.

## Expected Outcomes

After completing this lab, you will have:

- Comprehensive runbook library for operational support.
- Structured incident response procedures.
- Proactive maintenance schedules.
- Clear escalation workflows.
- Disaster recovery procedures.
- Performance monitoring framework.

**Operational Readiness**: This lab ensures your team can effectively maintain and troubleshoot Purview classification systems in production environments with confidence and consistency.

## Lab Validation

### Runbook Completeness Checklist

- [ ] All incident response runbooks created and reviewed.
- [ ] Maintenance procedures documented with schedules.
- [ ] Escalation workflows defined with contact information.
- [ ] Health check procedures validated against systems.
- [ ] Disaster recovery tested with backup/restore cycle.
- [ ] Team trained on runbook usage.
- [ ] Runbook locations and access documented.

### Team Readiness Assessment

- [ ] Team members can locate and open appropriate runbooks.
- [ ] All team members have required permissions for procedures.
- [ ] Emergency contacts verified and current.
- [ ] Practice incident response completed successfully.
- [ ] Escalation procedures tested (non-production).

## Troubleshooting

### Common Documentation Issues

**Issue**: Runbook procedures don't match current environment.

**Solution**: Schedule quarterly runbook review sessions to validate against current systems.

**Issue**: Team members don't know which runbook to use.

**Solution**: Create symptom-to-runbook quick reference guide for common issues.

**Issue**: Procedures take longer than documented estimates.

**Solution**: Time actual execution and update estimates; consider automation opportunities.

## Next Steps

After completing this lab:

- Schedule regular maintenance procedures.
- Establish incident response on-call rotation.
- Practice disaster recovery procedures.
- Review and update escalation contacts.
- Implement health monitoring dashboards.
- Proceed to Shared Utilities for reusable PowerShell modules.

## Additional Resources

**Microsoft Documentation**:

- [Microsoft Purview Troubleshooting](https://learn.microsoft.com/en-us/purview/purview-troubleshooting)
- [SharePoint Online Limits](https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits)
- [Microsoft Graph Throttling Guidance](https://learn.microsoft.com/en-us/graph/throttling)

**Internal Resources**:

- Previous lab scripts for diagnostic commands.
- Organization-specific support contacts.
- Service level agreements (SLAs) for response times.

**External Resources**:

- PowerShell error handling best practices.
- Incident management frameworks (ITIL, DevOps).
- Runbook templates and examples.

---

*This lab focuses on operational excellence and sustainable maintenance practices. The runbooks and procedures ensure consistent, effective response to incidents and proactive system care.*
