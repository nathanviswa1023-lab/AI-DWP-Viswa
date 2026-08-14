# Runbook: Floor 6 Win11 Intune Login and Access Stabilization

Title: Runbook-Floor6-Win11-Intune-Login-Access-Stabilization
Version: 1.0
Date: 14/08/2026
Author: DWP Engineer
Reviewed: self
Status: draft
Change: initial version from incident triage

Incident pattern covered:
- Monday-morning login delays/failures for a subset of Floor 6 users after recent Win11 migration and Intune enrollment.
- Concurrent reports of missing desktop shortcuts.
- One reported Copilot output access concern requiring security validation.
- Friday afternoon document-management app rollout to the same floor before incident start.

Use this runbook for incidents matching the triage in triage-summary-finbridge-floor6-legal-win11-intune.md and immediate actions in Immediate fix.md.

---

## 1. Prerequisites

### A) Access Checklist
- [ ] [ELEVATED] Access to Microsoft Intune admin center with rights to view device compliance, app deployments, and assignments.
- [ ] [ELEVATED] Access to Microsoft Entra ID (Azure AD) sign-in logs and Conditional Access policy state.
- [ ] [ELEVATED] Access to Microsoft 365 Unified Audit logs (or delegated Security operations support).
- [ ] [ELEVATED] Permission to pause or ring-limit the Friday document-management app deployment.
- [ ] [ELEVATED] Permission to isolate a device (if Security team instructs) and preserve evidence.
- [ ] [ELEVATED] Access to Service Desk ticket queue and major incident bridge/comms channel.

### B) Tools Checklist
- [ ] Intune admin center open in browser.
- [ ] Entra admin center open in browser.
- [ ] Microsoft Purview or M365 audit interface open in browser.
- [ ] PowerShell 5.1+ available for endpoint checks (if remote support is needed).
- [ ] Standard incident evidence template ready (timestamps, users, devices, screenshots, event IDs).

### C) Mandatory End-User Input Checklist
- [ ] At least 5 affected users and 2 unaffected users from Floor 6.
- [ ] For each sampled user: username, device name, exact symptom, first seen time, and screenshot/error text.
- [ ] Confirmation whether issue is login failure, login delay, missing shortcuts, or combination.
- [ ] For Copilot concern: exact prompt, output snippet, timestamp, and application/context used.

### D) Incident Context Checklist
- [ ] Incident start time and current severity agreed with incident manager.
- [ ] Confirmed change window and deployment details for Friday document app rollout.
- [ ] Scope statement drafted: Floor 6 only vs wider estate (to confirm).
- [ ] Initial partner update deadline captured (by lunch).

---

## 2. Procedure

1. Open a major incident bridge and assign three tracks: login, endpoint/profile, and security validation.
Expected result: One incident channel with named owners and timestamped start.

2. Record a controlled user sample of 5 affected and 2 unaffected Floor 6 users in the incident log.
Expected result: Comparable sample exists for rapid differential diagnosis.

3. Pause or ring-limit further rollout of the Friday document-management app to Floor 6 only.
Expected result: No additional devices receive new deployment changes during triage.

4. In Entra sign-in logs, filter sampled affected users for the incident window and capture failure reasons.
Expected result: Authentication failure type is identified (for example Conditional Access, MFA, or credential path) or marked to confirm.

5. In Intune, open sampled affected devices and record compliance state, last check-in time, and app install status for the Friday deployment.
Expected result: Correlation matrix for affected users is captured.

6. In Intune, open sampled unaffected devices and record the same fields as Step 5.
Expected result: Differential baseline between affected and unaffected devices is captured.

7. Compare affected vs unaffected records and identify one common blocking pattern.
Expected result: Primary hypothesis is selected and documented with evidence.

8. If the common pattern is a newly enforced Conditional Access/compliance dependency, temporarily exclude a controlled pilot group (2 affected users) from the specific blocking condition per change control.
Expected result: Pilot users can attempt sign-in under controlled exception.

9. Have pilot users perform one sign-in attempt each and time to desktop.
Expected result: Sign-in succeeds or fails with measurable outcome for hypothesis confirmation.

10. If pilot sign-in improves, apply the same temporary controlled exception to remaining affected Floor 6 users only.
Expected result: Broader Floor 6 login restoration begins without estate-wide policy rollback.

11. If pilot sign-in does not improve, revert pilot exception immediately and switch hypothesis to app/profile impact.
Expected result: Security posture is restored while alternate cause path is pursued.

12. For missing shortcuts reports, run company-approved profile refresh/rebuild action for one affected pilot user.
Expected result: Desktop shortcuts reappear or root symptom is isolated for further profile remediation.

13. Repeat Step 12 for up to two more affected users only if Step 12 succeeded.
Expected result: Profile-side symptom is reduced for repeated cases.

14. For the Copilot concern, preserve evidence (prompt/output/timestamp/user/device) without modifying source permissions.
Expected result: Audit-quality evidence package is created.

15. In M365 audit and data-access logs, validate whether surfaced content matched actual user entitlements at event time.
Expected result: Security status is classified as false positive, entitlement-consistent result, or potential unauthorized exposure (to confirm until evidence complete).

16. If unauthorized exposure is indicated, escalate to Security Incident process and keep containment active on related accounts/devices as directed.
Expected result: Security workflow is formally engaged with preserved evidence chain.

17. Publish a floor update message with current status, immediate user actions, and next update time.
Expected result: Users receive reassurance and a clear expectation without unowned resolution ETA.

18. Publish partner-facing lunch update with impact, action taken, risk position, and next checkpoint.
Expected result: Non-technical stakeholders receive accurate and controlled status.

---

## 3. Verification

1. Confirm no new affected-user spikes in Service Desk queue for Floor 6 over a 30-minute observation window.
Expected result: Ticket intake trend stabilizes or declines.

2. Re-test sign-in with the original 5 affected sample users.
Expected result: At least 4 of 5 complete sign-in in acceptable time agreed by incident manager.

3. Confirm Intune check-ins are current for remediated users.
Expected result: Devices report recent sync and stable compliance state.

4. Confirm missing-shortcut symptom is resolved for at least 2 previously affected users.
Expected result: Users confirm desktop baseline restored.

5. Confirm Copilot concern status with Security owner (false positive, entitlement-consistent, or active investigation).
Expected result: Security position is explicitly documented before closure decision.

6. Issue a closure recommendation only if business operations are restored and security risk is either cleared or transitioned to formal investigation.
Expected result: Incident state can be downgraded or closed with auditable rationale.

---

## 4. Rollback

Use rollback immediately if login success drops, new symptoms spread, or security risk increases after changes.

1. Revert any temporary Conditional Access/compliance exception created in Procedure Step 8 or Step 10.
Expected result: Original policy enforcement state is restored.

2. Undo any emergency assignment changes applied to Floor 6 app deployment rings and return to pre-incident assignment snapshot.
Expected result: Deployment scope matches known pre-incident state.

3. Re-enable deployment hold if rollback reintroduces instability and freeze further endpoint changes for Floor 6.
Expected result: Change noise is contained while recovery path is reassessed.

4. Remove profile remediation action from additional users if it causes broader desktop/profile regressions.
Expected result: Further profile impact is prevented.

5. If unauthorized exposure risk increases, isolate implicated user/device per Security instruction and suspend non-essential access pathways.
Expected result: Potential data exposure blast radius is reduced.

6. Send rollback status update to incident bridge and stakeholders with revised risk statement and next technical checkpoint time.
Expected result: All parties have synchronized awareness of rollback state and next actions.

---

## 5. Notes

Edge cases
- A single floor can have multiple concurrent causes; keep security validation separate from performance/login remediation.
- Missing shortcuts may represent profile redirection sync lag rather than data loss.
- Sign-in failures may be intermittent; always capture exact timestamp for each test attempt.

Warnings
- Do not declare a data breach without entitlement and audit confirmation.
- Do not apply estate-wide policy rollback for a floor-scoped incident unless approved by incident manager.
- Do not promise exact restoration time to users or partners unless dependency owners commit it.

Related incidents/documents
- triage-summary-finbridge-floor6-legal-win11-intune.md
- Immediate fix.md
- The-Copilot-Incident.md
