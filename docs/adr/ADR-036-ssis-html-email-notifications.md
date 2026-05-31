# ADR-036. HTML Email Notifications from SSIS via SMTP

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS ETL pipelines run on a schedule and require operator notification when failures or critical events occur. The on-premise environment has an internal SMTP server for enterprise email delivery.

**Current implementation:**
- **SSIS Send Mail Task**: Sends HTML-formatted email on package failure or completion
- **SMTP connection manager**: Configured with internal SMTP server address
- **Email body**: HTML content with embedded CSS styling, sent as `MailFormat=HTML`
- **Recipients**: Operations team distribution list
- **No external notification service**: No Slack, PagerDuty, or Teams webhooks

## Decision

We use **SSIS Send Mail Task with internal SMTP** for ETL notifications:

1. **SMTP server**: Internal enterprise SMTP relay (no external email services)
2. **HTML format**: Emails formatted as HTML with embedded styling for readability
3. **Event triggers**: OnError (failure notification), OnWarning (non-critical alert), OnPostExecute (success summary)
4. **No external notification integration**: Slack, PagerDuty, Microsoft Teams webhooks are not used
5. **Static recipient lists**: Distribution lists configured in SSIS connection manager (not dynamic)

## Consequences

**Positive:**
- No additional infrastructure (uses existing enterprise SMTP)
- HTML emails are human-readable with styled tables and status summaries
- SSIS native task — no custom code required
- Operations team receives familiar email format

**Negative:**
- **SMTP server dependency**: If internal SMTP is down, notifications are silently lost
- **No guaranteed delivery**: No retry logic if SMTP server is temporarily unavailable
- **No escalation path**: Cannot escalate to on-call rotation or incident management system
- **HTML email rendering**: Different email clients render HTML differently (Outlook, webmail)
- **No rich alerting**: No push notifications, no mobile alerts, no incident correlation
- **Static recipients**: Cannot dynamically route notifications based on failing pipeline type

**Future constraints:**
- Evaluate webhook integration (Teams/Slack) for richer alerting
- Add SMTP retry logic or fallback SMTP server
- Consider SendGrid/Amazon SES if SMTP reliability becomes an issue
- Dynamic recipient routing based on pipeline type or failure severity

## Related ADRs

- ADR-021: SSIS as pure orchestrator (Send Mail Task is part of control flow)
- ADR-035: ETL logging pattern (emails sent in addition to log table writes)
