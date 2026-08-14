# Prevention Note - Floor 6 Monday Incident

Version: 1.0  
Date: 14/08/2026  
Author: DWP Engineer  
Status: Draft

## 1. Single Process Change (Concrete Control)

Control name: **Friday Change Safety Gate - Legal Access Canary + Monday Readiness Hold**

What changes:
- No Friday afternoon app deployment to Legal floors is allowed to move to "complete" unless a named canary gate passes.
- Gate must be run on a representative legal user set before close of business Friday.
- Monday 08:00-10:00 hypercare hold remains active; rollback path is pre-approved.

Required gate checks (all must pass):
1. Sign-in time check on canary users stays within agreed threshold.
2. Desktop profile check confirms standard shortcuts are present after first sign-in.
3. Access-boundary check confirms Copilot does not surface data outside user entitlement.
4. Intune compliance and app deployment status match expected policy state.

Why this would have caught the issue before Monday:
- Reasoning for login/performance: the incident appeared on Monday after Friday change on one floor; a mandatory Friday canary sign-in and Monday hypercare would have exposed slow/failing sign-in before peak business.
- Reasoning for missing shortcuts: shortcut loss is visible immediately after sign-in; canary profile check would have flagged it before broad user impact.
- Reasoning for Copilot signal: "matter never had access to" is an access-boundary alarm; a required pre-release entitlement challenge test would have triggered security escalation before production hours.

Owner and evidence:
- Owner: Change Manager + Floor Service Lead + Security Duty Analyst.
- Evidence artifact: one signed gate record with timestamps, user IDs (masked), pass/fail results, and rollback readiness confirmation.
- Decision rule: any failed check means rollout is held and incident path opened immediately.

---

## 2. Conclusions With Reasoning (Not Just Answers)

1. Conclusion: Copilot report is a **security signal**, not an app bug.
Reasoning: the statement is about unexpected access to client matter content, which is an authorization boundary question; authorization boundaries are security controls and must be investigated via entitlement and audit evidence.

2. Conclusion: Login and performance are likely change-correlated, not random background noise.
Reasoning: symptoms started after a Friday floor-specific deployment, then surfaced at Monday peak; floor-scoped timing plus change correlation is stronger than a random coincidence hypothesis.

3. Conclusion: One incident can contain multiple concurrent causes.
Reasoning: sign-in delays, shortcut disappearance, and a potential access anomaly can share timing but not necessarily one root cause; running parallel workstreams prevents false closure.

4. Conclusion: Communication should commit to update times, not fix times.
Reasoning: dependency-controlled incidents have uncertain duration; promising exact resolution times without confirmed control causes credibility and governance risk.

---

## 3. Required Reflection (First Instinct That Was Wrong)

My first instinct was that this was a broad identity service outage.

Why that instinct was wrong:
- Evidence did not support tenant-wide impact; reports were concentrated on Floor 6.
- Timing aligned with a known local change (Friday app rollout).
- Additional symptom (missing shortcuts) suggested endpoint/profile side effects, not pure identity outage.

What changed my mind:
- Scope evidence (floor-specific) + change timeline (post-rollout) outweighed the outage assumption.
- The Copilot statement reframed risk: this was not only availability (login), but also potential confidentiality (access control).

Correction applied:
- Shifted from single-cause outage model to three-track model: login restoration, endpoint/profile stabilization, and security validation.

---

## 3a. AI-Generated Script and Hand Correction (Before/After)

Purpose of script: enforce the Friday Safety Gate before rollout completion.

### Before (AI-generated, insufficient)
```powershell
# AI-generated draft (insufficient)
param(
  [string]$Floor = "Floor6",
  [string]$AppName = "DocMgmtApp"
)

$devices = Get-IntuneManagedDevice -Filter "floor eq '$Floor'"
$failures = 0

foreach ($d in $devices) {
  $app = Get-IntuneAppInstallStatus -DeviceId $d.Id -AppName $AppName
  if ($app.Status -ne "Installed") {
    $failures++
  }
}

if ($failures -gt 0) {
  Write-Host "Gate Failed"
  exit 1
}

Write-Host "Gate Passed"
exit 0
```

Why this was wrong:
- It checks only app install status.
- It does not check sign-in latency, profile integrity, or access-boundary safety.
- It cannot detect the Copilot security signal class at all.

### After (hand-corrected, control-complete)
```powershell
# Hand-corrected gate script: Friday Change Safety Gate
param(
  [string]$Floor = "Floor6",
  [string]$AppName = "DocMgmtApp",
  [int]$MaxSignInSeconds = 90
)

$gateFail = $false
$report = @()

# 1) App deployment health
$devices = Get-IntuneManagedDevice -Filter "floor eq '$Floor'"
foreach ($d in $devices) {
  $app = Get-IntuneAppInstallStatus -DeviceId $d.Id -AppName $AppName
  if ($app.Status -ne "Installed") {
    $gateFail = $true
    $report += "APP_FAIL:$($d.DeviceName)"
  }
}

# 2) Sign-in performance (canary users only)
$canaries = Get-CanaryUsers -Floor $Floor
foreach ($u in $canaries) {
  $signin = Get-SignInProbeResult -UserPrincipalName $u.UserPrincipalName
  if ($signin.SecondsToDesktop -gt $MaxSignInSeconds -or -not $signin.Success) {
    $gateFail = $true
    $report += "SIGNIN_FAIL:$($u.UserPrincipalName):$($signin.SecondsToDesktop)s"
  }
}

# 3) Desktop profile integrity check
foreach ($u in $canaries) {
  $profile = Get-DesktopBaselineCheck -UserPrincipalName $u.UserPrincipalName
  if (-not $profile.ShortcutsPresent) {
    $gateFail = $true
    $report += "PROFILE_FAIL:$($u.UserPrincipalName):ShortcutsMissing"
  }
}

# 4) Access-boundary challenge (security check)
foreach ($u in $canaries) {
  $challenge = Test-CopilotEntitlementBoundary -UserPrincipalName $u.UserPrincipalName
  if (-not $challenge.WithinEntitlement) {
    $gateFail = $true
    $report += "SECURITY_FAIL:$($u.UserPrincipalName):PotentialUnauthorizedSurface"
  }
}

if ($gateFail) {
  Write-Host "GATE_FAILED"
  $report | ForEach-Object { Write-Host $_ }
  New-ChangeHoldTicket -Floor $Floor -Reason "Safety gate failure"
  exit 1
}

Write-Host "GATE_PASSED"
$report | ForEach-Object { Write-Host $_ }
exit 0
```

Why the corrected version is better:
- It enforces all three risk domains seen in this incident: availability, user environment, and confidentiality boundary.
- It creates explicit pass/fail output and triggers hold workflow on failure.
- It turns the Copilot case into a mandatory security gate check rather than optional investigation.

---

## 4. Runbook as Single Source for L1/L2 (Pass/Fail Check)

Single source runbook:
- Runbook-Floor6-Win11-Intune-Login-Access-Stabilization.md

Re-expression mapping:
1. L1 article (KB-L1-Floor6-Login-and-Access-Self-Service.md)
Reasoning: Simplifies runbook actions into safe end-user steps only (one retry, capture evidence, contact path), with no new technical logic added.

2. L2 article (KB-L2-Floor6-Login-and-Access-Technical.md)
Reasoning: Preserves the same runbook sequence (track split, hold rollout, compare affected/unaffected, controlled pilot exception, security validation, rollback) in technical language.

Pass statement:
- Both articles are transformations of one procedure source, not independently researched playbooks.

---

## 5. Partner Note Readability Check

Partner-facing artifact:
- tell the partners by lunch.md

Why it is readable by non-technical readers:
- Uses plain headings: what happened, what is being done, what is still open.
- Avoids platform-specific jargon and code terms.
- States risk position clearly without claiming certainty not yet proven.
- Commits to next update time instead of unsupported fix ETA.

---

## 6. Final Prevention Recommendation

Adopt the **Friday Change Safety Gate - Legal Access Canary + Monday Readiness Hold** as a mandatory release control for legal-floor changes.

Reasoning summary:
- It addresses exactly the failure pattern seen: change-linked login/performance disruption plus a possible access-boundary event.
- It creates a named accountability path, objective pass/fail evidence, and a pre-approved hold/rollback trigger.
- It would likely have converted Monday disruption into a controlled Friday/Saturday hold decision.
