# Slack Issue Breakdown - Separated Problems and First Checks

## 1) Potential unauthorized client-data exposure via Copilot (highest urgency)
### What to check first
- Confirm the specific user, timestamp, and prompt details from the report.
- Review M365/Copilot audit evidence for returned citations/source references.
- Validate permissions on the referenced client matter (file/folder ACLs).
- Check whether the user could open the source directly or only saw a generated reference/summary.

### Why this first
- This is a potential confidentiality/legal-risk event.
- If confirmed, it may require immediate security and legal escalation.
- Risk exposure can increase if not contained quickly.

### Status
- To confirm.

## 2) Sign-in failures and very slow logins (high operational urgency)
### What to check first
- Compare Entra sign-in results for affected vs unaffected Floor 6 users in the same time window.
- Check Conditional Access outcomes, MFA challenges, and failure codes.
- Verify Intune compliance and recent check-in status for impacted devices.

### Why this second
- At least a dozen users are reportedly unable to work effectively.
- This is the largest immediate productivity and business continuity impact.

### Status
- To confirm.

## 3) Missing desktop shortcuts (configuration/profile symptom)
### What to check first
- Compare one impacted and one unaffected device for policy/app assignment differences.
- Check profile/shell initialization events around first login Monday.
- Validate whether Friday's deployment included shortcut management or profile-affecting components.

### Why this third
- User-impacting, but typically lower immediate risk than data exposure or login lockout.
- May be a side-effect of the same underlying change causing sign-in issues.

### Status
- To confirm.

## 4) Friday document-management rollout as common trigger (cross-cutting cause)
### What to check first
- Confirm rollout scope/ring and exact deployment timeline.
- Review install success/failure trends for Floor 6 devices.
- Correlate symptom start times against deployment/check-in times.
- Assess whether a controlled pause or rollback for Floor 6 is feasible.

### Why this now
- This is the strongest shared change signal across multiple symptoms.
- If correlated, rollback/pause may provide the fastest containment path.

### Status
- To confirm causality.

## Recommended order of execution
1. Validate and contain potential Copilot data-access issue.
2. Restore sign-in path for affected users.
3. Triage and remediate missing shortcuts.
4. Confirm change correlation and decide on targeted rollback/pause.
