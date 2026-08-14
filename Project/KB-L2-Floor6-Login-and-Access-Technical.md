# KB-L2: Floor 6 Win11 Intune Login and Access Technical Guidance

Version: 1.0
Date: 14/08/2026
Status: Draft
Source: Runbook-Floor6-Win11-Intune-Login-Access-Stabilization v1.0

## Summary
This article is the technical expression of the runbook for recurring Floor 6 incidents involving login delays/failures, missing desktop shortcuts, and a concurrent Copilot access concern after Friday app rollout.

## Prerequisites
- [ELEVATED] Intune admin access (device compliance, app deployment assignments/status).
- [ELEVATED] Entra sign-in logs and Conditional Access visibility.
- [ELEVATED] M365/Purview audit access (or Security delegation).
- [ELEVATED] Approval path for temporary pilot exceptions and rollback.
- Incident sample set: 5 affected users, 2 unaffected users, each with user/device/timestamp/symptom.

## Procedure (mapped from source runbook)
1. Start MI bridge with three tracks (login, profile, security).
Expected result: clear ownership and timeline.

2. Freeze further rollout noise (pause/ring-limit Friday app to Floor 6).
Expected result: no new deployment-induced variance.

3. Collect Entra sign-in evidence for affected sample.
Expected result: failure mode classification.

4. Collect Intune compliance and app state for affected and unaffected devices.
Expected result: side-by-side differential dataset.

5. Identify common blocking pattern and test controlled pilot exception for 2 users.
Expected result: hypothesis confirmed or rejected by timed sign-in outcome.

6. If confirmed, expand temporary exception to affected Floor 6 users only.
Expected result: service restoration without estate-wide rollback.

7. If not confirmed, revert exception and pivot to app/profile path.
Expected result: security baseline restored; alternate remediation path active.

8. Pilot profile refresh for missing shortcuts and scale only on success.
Expected result: desktop baseline restored for profile-affected users.

9. Preserve Copilot evidence and validate entitlement vs surfaced content in audit logs.
Expected result: classify as false positive, entitlement-consistent, or potential unauthorized exposure.

10. Escalate to Security Incident process if exposure is indicated.
Expected result: containment and forensic workflow engaged.

## Verification
- Queue trend stable/down over 30 minutes.
- 4/5 original affected users achieve acceptable sign-in time.
- Remediated devices show current Intune check-in.
- Missing shortcuts resolved in minimum 2 validated users.
- Security owner recorded explicit Copilot risk status.

## Rollback
1. Remove temporary Conditional Access/compliance exceptions.
Expected result: pre-incident policy state restored.

2. Restore app deployment assignment to pre-incident snapshot.
Expected result: assignment baseline restored.

3. Re-freeze endpoint changes if rollback increases instability.
Expected result: blast radius contained.

4. Stop further profile remediation if regressions appear.
Expected result: no additional profile damage.

5. Isolate implicated account/device if security risk rises.
Expected result: exposure surface reduced pending Security direction.

## Notes
- Treat login restoration and security validation as parallel tracks.
- Do not declare breach without entitlement/audit confirmation.
- Do not publish unowned ETA; publish next-update time instead.
