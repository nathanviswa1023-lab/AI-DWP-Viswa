# Post-Migration Feedback Themes (Round 3)

Date: 2026-08-12
Scope: 15 end-user comments from FinBridge staff after Windows 11 migration
Note: Each comment is assigned to exactly one theme.

## Clustered Themes

### 1) Credentials Vault Access Loss
- count: 3
- Quotes:
  - "Shared credentials vault is completely inaccessible, whole team blocked."
  - "Third day now I can't access the credentials vault, this is urgent."
- severity: Blocker

### 2) Admin Console Lockouts
- count: 2
- Quotes:
  - "Second engineer this week locked out of the admin console entirely."
  - "Admin console lockouts happening across the whole team now, not just one person."
- severity: Blocker

### 3) Test VM Remote Access Failure
- count: 2
- Quotes:
  - "Can't remote into any of my test VMs since the update, blocking my whole day."
  - "My test VM access is still down, can't do my job today either."
- severity: Blocker

### 4) UI Readability and Change Friction
- count: 2
- Quotes:
  - "Font in the new portal is slightly smaller, hard to read for some of us."
  - "Small UI icon changes, took a second to adjust but fine."
- severity: Friction

### 5) Minor Performance/Notification Irritants
- count: 2
- Quotes:
  - "Notification sounds changed, mildly annoying but not a big deal."
  - "Dashboard refresh is a bit slower than before, barely noticeable."
- severity: Minor

### 6) Positive Rollout Sentiment
- count: 4
- Quotes:
  - "Overall the rollout felt smoother than last time, appreciate it."
  - "No issues at all for me, everything's working fine."
- severity: Positive

## Top 2 Themes to Act Today

1. Credentials Vault Access Loss (Theme 1)
- Why now: Multi-day outage language ("Third day"), team-wide blocker, and management escalation indicates immediate operational and security access risk.

2. Admin Console Lockouts (Theme 2)
- Why now: Pattern spreading across team and blocking privileged admin workflows; high risk of incident-response delays.

## Proactive Notification (for Top Theme 1)

Subject: Ongoing issue: Shared Credentials Vault Access (FinBridge)

Hello FinBridge team,

We are actively investigating an ongoing issue affecting access to the shared credentials vault for some users after the Windows 11 migration.

What we know now:
- Some users are unable to open the shared credentials vault.
- The issue is impacting normal admin and support activities.
- Engineering and platform teams are treating this as a high-priority service issue.

What you should do now:
- Do not repeatedly retry login more than 2 times in a row.
- Raise or update your ticket with: "Vault access post-Win11 migration" and include time of failure + screenshot if available.
- If your work is blocked, notify your team lead and mark the ticket as "Business Impact: High".

Next update:
- We will send the next status update within 60 minutes, even if the fix is still in progress.

Thank you for your patience while we work to restore full access.

- DWP Support Team
