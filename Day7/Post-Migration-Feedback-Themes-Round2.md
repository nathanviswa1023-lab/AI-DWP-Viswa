# Post-Migration End-User Feedback — Themes & Priority Ranking (Round 2)

Source: 15 FinBridge staff comments collected after the Win11 migration
Date compiled: 2026-08-12
Author: DWP Analyst review

---

## 1. Themes (unranked)

| # | Theme | Count | Comments | Severity |
|---|---|---|---|---|
| 1 | Shared Credentials Vault Inaccessible | 3 | "Shared credentials vault is completely inaccessible, whole team blocked." (#5) / "Third day now I can't access the credentials vault, this is urgent." (#8) / "Vault access still broken, escalated to my manager now." (#14) | Blocker |
| 2 | Admin Console Lockouts | 2 | "Second engineer this week locked out of the admin console entirely." (#3) / "Admin console lockouts happening across the whole team now, not just one person." (#10) | Blocker |
| 3 | Test VM Remote Access Failure | 2 | "Can't remote into any of my test VMs since the update, blocking my whole day." (#1) / "My test VM access is still down, can't do my job today either." (#12) | Blocker |
| 4 | Minor Cosmetic / UI Changes | 5 | "New ticketing system dashboard is a nicer colour scheme." (#2) / "Font in the new portal is slightly smaller, hard to read for some of us." (#4) / "Notification sounds changed, mildly annoying but not a big deal." (#7) / "Dashboard refresh is a bit slower than before, barely noticeable." (#9) / "Small UI icon changes, took a second to adjust but fine." (#15) | Minor |
| 5 | Positive Feedback / Smooth Migration | 3 | "Overall the rollout felt smoother than last time, appreciate it." (#6) / "Nice that the new theme supports dark mode properly now." (#11) / "No issues at all for me, everything's working fine." (#13) | Positive |

---

## 2. Top 3 priorities to act on today

Ranking weighs **severity first, then volume and business impact**. All three Blocker themes are prioritised above every Minor or Positive theme regardless of comment count. Among the three Blocker themes, persistence of the issue, breadth of impact, and business-criticality are used to order them.

---

### 🥇 #1 — Shared Credentials Vault Inaccessible (3 comments — Blocker)

**Why it ranks #1:** This is the highest-volume Blocker theme and the most operationally critical. All three comments confirm the vault has been completely inaccessible — not intermittently slow, but fully blocked. Comment #8 confirms this has been unresolved for at least three days, and comment #14 shows it has already been escalated to a manager, meaning informal resolution has been attempted and failed. Comment #5 explicitly states the whole team is blocked, meaning this is not an individual account problem but a systemic access failure. A shared credentials vault being unreachable is a significant security concern as well as a productivity one — staff may be tempted to work around it using unsafe alternatives.

**Tell your manager:** The shared credentials vault has been completely inaccessible for at least three days, the whole team is blocked, and it has already been escalated internally without resolution. This is the most urgent issue on the list — it stops work and creates a security risk if staff work around it.

---

### 🥈 #2 — Admin Console Lockouts (2 comments — Blocker)

**Why it ranks #2:** Two comments, but the language in both reveals a rapidly worsening pattern. Comment #3 describes a second engineer locked out this week — implying it has happened more than once and is not a one-off. Comment #10 then confirms the problem has spread to the whole team, not just individual accounts. The shift from "one person" to "whole team" within what appears to be a short window indicates an active and escalating issue rather than a configuration artefact from migration. Admin console access is used for privileged operations, so a team-wide lockout has a disproportionate impact on IT or engineering functions.

**Tell your manager:** Admin console lockouts have escalated from a single user to the whole engineering team within a short period. This is a Blocker that is actively spreading — it needs urgent investigation to determine whether it is a policy change, a permissions regression, or something else.

---

### 🥉 #3 — Test VM Remote Access Failure (2 comments — Blocker)

**Why it ranks #3:** Two comments from what appear to be different users, both confirming they cannot remote into any test VMs since the update. Comment #1 describes it blocking their entire working day; comment #12 confirms it is still unresolved on at least a second day. The phrase "can't do my job today either" in comment #12 signals this is a multi-day, unresolved issue rather than a transient connectivity blip. While this ranks third due to slightly lower breadth than the top two themes, it is no less a full work-stoppage for the affected users.

**Tell your manager:** At least two staff members have been completely unable to remote into test VMs since the update, and the issue persists across multiple days. Anyone whose role depends on VM access cannot work at all until this is fixed.

---

## 3. Themes considered but not in today's top 3

- **Minor Cosmetic / UI Changes (5 comments, Minor)** — Highest raw comment volume of all themes, but no comment in this group describes a work-stoppage. Font size (#4) is the only item with potential accessibility implications and warrants a follow-up, but it does not outrank any Blocker theme. Dashboard speed (#9) is described as "barely noticeable." The remaining items are neutral observations or positive minor wins.
- **Positive Feedback / Smooth Migration (3 comments, Positive)** — Noted for context and morale. Three staff report no issues and two make positive comments about the dark mode support and overall rollout quality. This is encouraging but does not change prioritisation of the Blocker themes.

---

## 4. Summary

| Theme | Count | Severity | Action |
|---|---|---|---|
| Shared Credentials Vault Inaccessible | 3 | Blocker | Immediate — unresolved 3+ days, whole team blocked |
| Admin Console Lockouts | 2 | Blocker | Immediate — actively spreading across the team |
| Test VM Remote Access Failure | 2 | Blocker | Immediate — multi-day, full work-stoppage |
| Minor Cosmetic / UI Changes | 5 | Minor | Monitor — note font size for accessibility follow-up |
| Positive Feedback | 3 | Positive | No action required |
