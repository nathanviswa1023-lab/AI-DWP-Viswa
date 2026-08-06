# Triage Summary — T-1002

**Date raised:** 2026-08-04  
**Logged by:** Service Desk Analyst (AI-assisted draft — verified before use, per DWP Personal AI Usage Charter)

---

## Summary
Finance user cannot open a shared mailbox following a migration.

---

## Impact
| Field | Detail |
|---|---|
| Affected users | 1 reported (reporter only — to-verify whether other Finance users sharing the same mailbox are also affected) |
| Business urgency | Medium-High — to-verify; likely time-sensitive if Finance team relies on the shared mailbox for daily processing (e.g. invoicing, approvals) |
| Role / team | Finance — to-verify specific team/function |
| Time of onset | Since/after the migration — exact date/time not stated, to-verify |

---

## Known Facts
- User is in Finance.
- Issue began in connection with a migration (type of migration — e.g. mailbox move, tenant-to-tenant, on-prem to cloud — not stated, to-verify).
- The user cannot open the shared mailbox (exact symptom — error message, blank folder, access denied, mailbox not visible — not stated, do not assume).

---

## Missing Information to Gather
1. Username and shared mailbox name/address (do **not** paste into AI tools; use internal systems only).
2. Exact error message or behaviour seen when attempting to open the mailbox (e.g. "cannot expand folder", permissions error, mailbox missing from list) — to-verify.
3. Which client is used to access the mailbox — Outlook desktop, Outlook Web App (OWA), mobile — and version, if desktop.
4. Was the shared mailbox previously accessible to this user before the migration?
5. What migration was performed, and when (date/time), and by which team — to-verify.
6. Has the shared mailbox permission (Full Access / Send As / Send on Behalf) been reassigned or verified post-migration?
7. Is the shared mailbox auto-mapped in Outlook, or does the user add it manually?
8. Are other users who have access to the same shared mailbox affected, or is this isolated to one user?
9. Has the user tried restarting Outlook, or accessing via OWA, to isolate a client-side cache issue?
10. Any recent password reset, account changes, or licence changes for the user around the same time — to-verify.

## Likely Category
**Messaging / Exchange Online — Shared Mailbox Access (Post-Migration)** — probable sub-categories:
- Permissions not migrated/reapplied correctly (Full Access/Send As) — to-verify
- Outlook client cache/profile not refreshed after migration (autodiscover or autocomplete pointing to old mailbox location) — to-verify
- Mailbox migration batch incomplete or still propagating — to-verify

---

## Suggested First Diagnostic Step
Ask the user to try accessing the shared mailbox via Outlook Web App (OWA) using their own credentials to determine whether the issue is client-side (Outlook profile/cache) or a genuine permissions/migration issue, then confirm via approved internal tooling whether the user's account still holds Full Access permission on the shared mailbox post-migration.

---

*Note: This summary was drafted using AI assistance. No DWP internal data, user PII, mailbox names, hostnames, or credentials were included in the AI prompt, in accordance with the DWP Personal AI Usage Charter. All fields marked "to-verify" must be confirmed via internal tooling before action.*
