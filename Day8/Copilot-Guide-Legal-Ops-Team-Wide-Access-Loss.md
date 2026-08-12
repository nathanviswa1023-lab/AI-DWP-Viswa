# Microsoft 365 Copilot Guide — Legal Ops Team-Wide Access Loss

**Prepared by:** DWP Engineering  
**Date:** 12/08/2026  
**Audience:** Service desk and end user

---

## Incident triage summary

**Ticket summary:** Legal ops manager reports that all 40 people on the Legal team lost Copilot access this morning after it worked normally last week.

**Impact:** High. Multi-user, same-time failure affecting a full team. Potential service degradation, licensing issue, or policy change with business-wide productivity impact for the legal function.

**Known facts:**

- Approximately 40 Legal team users are affected.
- The issue started this morning.
- Copilot worked for those users last week.
- The report indicates a sudden team-wide change rather than isolated user failure.

**Most likely cause:** Service-side or tenant-side configuration issue.

**Other possible causes to check:**

- Microsoft 365 service incident affecting Copilot
- Bulk licence removal, expiry, or provisioning problem
- Conditional Access, group membership, or policy change applied overnight

**Information to gather:**

1. Exact error message seen by one or more affected users
2. Whether all Legal users are affected or only a subset
3. Whether the failure is in one Copilot app or across Outlook, Word, Teams, and Chat
4. Whether any admin changes were made overnight to licensing or access policy
5. Whether Microsoft 365 service health reports an active incident

**First triage actions:**

1. Check Microsoft 365 service health immediately.
2. Review admin audit logs for licensing, group, and Conditional Access changes.
3. Confirm whether affected users still hold the expected Copilot licences.
4. Gather one or two exact screenshots or messages rather than many duplicate reports.

**Initial support conclusion:** Could be a real service incident or tenant configuration change. Treat as a priority team-wide incident until ruled out.

---

## End-user communication

**Subject:** Legal team Copilot access issue under investigation

Hi,

We are treating this as a team-wide incident because it affected a large number of Legal users at the same time after working normally last week. That pattern usually points to a service issue, licensing problem, or access-policy change rather than something any one user has done.

**What you can do next:**

1. Please avoid repeated retries for now.
2. Send IT one exact error message or screenshot from an affected user if available.
3. Wait for a further update while we check service health and licensing.

Your files and permissions are not being changed by this investigation. At this stage we are checking why Copilot access dropped for the team and whether this is linked to a Microsoft 365 incident or an overnight admin change.

---

## Your issue in plain English

All 40 people on the Legal team lost access to Copilot this morning after it worked normally last week.

When a whole team is affected at the same time, that usually points to a **service issue, licensing problem, or policy change**, rather than anything an individual user has done wrong. This is different from a one-person setup issue.

---

## What to do next

1. Treat this as a team-wide incident rather than asking each user to troubleshoot separately.
2. Capture the exact error message or screenshot from one or two affected users.
3. Avoid repeated retries across the whole team while IT investigates.
4. Wait for a service update from IT once the cause is confirmed.

---

## What IT will likely check

- Microsoft 365 service health for active Copilot incidents
- Any overnight licence changes affecting the Legal team
- Any access policy, Conditional Access, or group membership changes applied since yesterday

---

## What to tell users meanwhile

You can tell the team:

> We are investigating a team-wide Copilot access issue. This looks more like a service, licensing, or access-policy problem than an issue with any one account. Please avoid repeated retries for now and send IT any exact error message you see.

---

## Prompting reminder after service is restored

Once access is back, users should return to specific prompts such as:

> Summarise today's emails about the Denton matter and list actions due this week.

That will help confirm normal Copilot behaviour has returned.

---

## Key point

This is most likely a **tenant or team-level service/configuration issue**, not an end-user mistake.