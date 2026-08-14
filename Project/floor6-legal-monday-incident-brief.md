# FinBridge Floor 6 (Legal) Monday Incident Brief

## 1) What we know right now (fact-based)
- Time of escalation: 09:14 via Slack from IT Ops lead.
- Affected area: Floor 6, Legal (45 users; recently moved to Windows 11 and Intune).
- Reported symptoms:
  - "At least a dozen" users cannot log in or logins are extremely slow.
  - One paralegal reports Copilot surfaced a client matter they believe they should not access.
  - Another report says desktop shortcuts disappeared.
- Recent change: new document management application rollout to Floor 6 on Friday afternoon.

## 2) What this likely means (to confirm)
- We likely have **more than one issue in parallel**:
  1. Access/performance issue (login failures and slow sign-in).
  2. Endpoint/profile/configuration side effect (missing desktop shortcuts).
  3. Potential information governance/security concern (unexpected Copilot retrieval).
- The Friday app rollout is a plausible trigger, but causality is **to confirm**.
- The Copilot report must be treated as a **potential confidentiality incident until disproven**.

## 3) Current severity and business impact
- Operational impact: high for Legal operations this morning.
- Current user impact: at least 12 users affected (to confirm exact count).
- Business urgency: high (partner-facing legal work may be blocked).
- Risk level: elevated because of potential client-data exposure claim (to confirm).

## 4) What we do right now (first 60–90 minutes)
1. Open a Major Incident bridge and assign three parallel workstreams:
   - Workstream A: login/performance.
   - Workstream B: endpoint/profile/shortcut changes.
   - Workstream C: data access/Copilot governance.
2. Freeze non-essential changes for Floor 6 until initial containment is complete.
3. Place a temporary safeguard on Copilot access for Floor 6 Legal users (or at minimum the reported user group) while validating the claim.
4. Confirm whether Friday's app deployment can be safely paused/rolled back for Floor 6 only.
5. Capture a verified impact list (names, device IDs, exact symptom, first seen time) from IT floor walkers/service desk.

## 5) Evidence required (no existing logs/exports available)
### A) Identity and sign-in evidence
- Entra ID sign-in logs for affected and unaffected comparators (same floor).
- Authentication result codes, Conditional Access outcomes, MFA prompts/failures.
- Sign-in latency timeline by user/device from 08:00 onward.

### B) Endpoint and policy evidence
- Intune device compliance state for impacted devices.
- Intune policy assignment and last check-in timing (especially changes since Friday).
- Application deployment status for new document management app (success/fail/pending).
- Endpoint event logs around user profile loading and shell initialization (for missing shortcuts).

### C) Data access/Copilot evidence
- M365 audit logs: prompts, retrieval events, file access path, user identity, timestamps.
- Source repository permissions for the allegedly exposed client matter.
- Copilot connector/index permissions and security trimming status.
- Whether the user could open the file directly or only saw a summary/reference.

### D) Change and scope evidence
- Exact rollout ring, assignment group, and timeline for Friday deployment.
- Comparison with non-Floor-6 users who received or did not receive the same change.
- Network/site telemetry for Floor 6 at incident start time.

## 6) Checks to run and decision points
1. Check if login failures correlate to a common Conditional Access or compliance failure.
   - Decision: if yes, apply targeted policy exception or rollback for Floor 6.
2. Check if slow sign-ins correlate to profile/app startup regression post-deployment.
   - Decision: disable problematic startup component or uninstall/rollback app.
3. Validate Copilot claim with auditable evidence.
   - Decision: if unauthorized access is confirmed, escalate as security incident, preserve evidence, notify Legal leadership and Security immediately.
4. Check if shortcut loss is profile redirection/known-folder or packaging side effect.
   - Decision: deploy remediation script/policy fix and restore standard desktop items.

## 7) Working hypotheses (explicitly provisional)
- H1 (most likely): Friday deployment introduced policy/app interaction causing sign-in degradation and profile symptoms.
- H2: Separate but concurrent issue with identity/compliance posture after Win11+Intune migration.
- H3 (high risk, lower certainty): Copilot surfaced content due to permission trimming/configuration gap, or misinterpreted result by user; must verify through audit trail.

## 8) What to tell partners by lunch (non-technical draft)
**Draft update (plain language):**
"This morning we identified a significant IT disruption affecting part of the Floor 6 Legal team. We are actively working three linked tracks: restoring normal sign-in performance, fixing user desktop configuration issues, and urgently validating a reported document access concern. As a precaution, we are applying temporary controls while we verify facts. We have paused non-essential changes in the affected area and assigned dedicated technical leads to each track. Our next formal update will include confirmed scope, root cause status, and recovery timing. Right now, our priority is service restoration and protection of client data."

## 9) Immediate comms cadence (recommended)
- Every 30 minutes to IT Ops + Legal operations manager.
- Partner update at or before lunch with:
  - confirmed affected count,
  - whether data exposure is confirmed or unconfirmed,
  - current workaround,
  - expected next update time.

## 10) Known unknowns to confirm before final RCA
- Exact percentage of affected users on Floor 6.
- Whether impact is isolated to Floor 6 or present in other rings.
- Whether Copilot output represented actual unauthorized access vs perceived mismatch.
- Whether one root cause explains all symptoms or multiple concurrent causes exist.
