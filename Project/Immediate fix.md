# FinBridge Floor 6 Monday Incident - Immediate Fix

## Summary (one line)
Floor 6 (Legal) is experiencing a likely multi-symptom post-change incident (login delays/failures, possible Copilot access concern, and missing shortcuts) following a Friday app rollout, requiring immediate containment and evidence-led triage.

## Impact (who/how many/business urgency)
- Affected area: FinBridge Floor 6, Legal team (45 people).
- Reported affected users: "at least a dozen" unable to log in or seeing very slow sign-in.
- Potential data risk: one report that Copilot surfaced a client matter the user says they never had access to (to confirm).
- Business urgency: High. Monday morning operational disruption in Legal with partner update requested by lunch.

## Known facts
- Floor 6 users were recently migrated to Windows 11 and enrolled in Intune.
- A new document management app was rolled out to Floor 6 on Friday afternoon.
- At 09:14, IT Ops lead reported:
  - At least a dozen users cannot log in or login is very slow.
  - One paralegal reported Copilot surfaced a matter they believe they should not access (to confirm).
  - Another user reported desktop shortcuts vanished.
- No logs or exports are currently provided.

## Missing information to gather
- Scope and timeline:
  - Exact number of affected users and whether impact is still increasing (to confirm).
  - Whether symptoms are limited to Floor 6 only or seen elsewhere (to confirm).
  - Exact first-seen time for each symptom (login, Copilot claim, missing shortcuts) (to confirm).
- Identity and access:
  - UPNs of impacted users and whether failures are password, MFA, Conditional Access, or profile load related (to confirm).
  - Whether affected users are in specific Intune/Azure AD groups tied to recent changes (to confirm).
- Endpoint and change correlation:
  - Device names, build versions, last check-in time, compliance state, and app install status in Intune (to confirm).
  - Deployment details of Friday document app rollout (assignment scope, install results, detection/remediation outcomes) (to confirm).
- Copilot data-access concern:
  - Exact prompt used, timestamp, tenant/app context, and screenshot evidence (to confirm).
  - Whether returned content is truly unauthorized or a similarly named permitted matter (to confirm).
  - Relevant audit trail (M365 Unified Audit, SharePoint/OneDrive permissions, Copilot audit events where available) (to confirm).
- User profile/shell:
  - Whether missing shortcuts are local profile reset/temporary profile, OneDrive KFM state, or GPO/Intune policy effect (to confirm).

## Likely category
- Primary: Major incident, probable change-related endpoint/identity regression after Friday rollout (to confirm).
- Security track (parallel): Potential data exposure concern via Copilot output, severity to be determined after access validation (to confirm).
- User environment track: Possible profile/policy/application side effects (to confirm).

## Suggest first diagnostics step
- First step: Open a formal major incident bridge and split into three parallel workstreams immediately:
  1. Login/performance triage for a 5-user sample (known affected and unaffected) to identify common failure point.
  2. Change validation for Friday app rollout in Intune (assignment scope, install failures, policy conflicts).
  3. Security validation of the Copilot access claim with evidence preservation and least-privilege checks.

## Immediate fix (now)
- Contain and stabilize:
  - Pause or ring-limit further rollout of the new document management app to prevent additional impact while triage runs.
  - Ask Floor 6 users to avoid repeated login retries every few seconds; use a controlled retry window to reduce lockout and authentication noise.
- Restore business continuity:
  - Prioritize legal-critical users/cases for assisted sign-in and temporary alternate access path (to confirm available method in your environment).
  - Provide a temporary shared process for urgent legal document handling while user endpoints are being stabilized (to confirm local process owner).
- Handle potential data concern safely:
  - Capture evidence of the Copilot output report immediately (user statement, prompt, screenshot, timestamp).
  - Do not declare data breach at this stage; treat as potential unauthorized exposure pending access verification.
- Communications control:
  - Send one coordinated status note to Floor 6 and one partner-facing update before lunch.
  - Set expectation: active triage, prioritized restoration, next update time committed (not final resolution time).

## Plain-language note to Floor 6
Team,

We know Floor 6 is having a difficult start this morning, and we are sorry for the disruption.

What we are seeing right now is a mix of login delays and desktop issues, and we are actively checking whether these are linked to a recent software change made on Friday. We are also urgently reviewing one reported Copilot result to confirm whether any access rules were affected.

What we are doing now:
- Prioritizing sign-in recovery for people blocked from working.
- Reviewing Friday's software rollout and pausing any further spread while we verify.
- Investigating the Copilot report with security and access checks.

What we need from you:
- If you are affected, report your name, device name, and what exact error or behavior you see.
- If you can work, please avoid repeated sign-in attempts on behalf of others, as this can slow diagnosis.

We will provide the next update by [insert time], and then continue with regular updates until services are stable.

Thank you for your patience while we work this through.
