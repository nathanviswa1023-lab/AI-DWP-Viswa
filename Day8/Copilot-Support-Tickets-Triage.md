# Microsoft 365 Copilot Support Tickets — Triage

**Prepared by:** DWP Engineering
**Date:** 12/08/2026
**Purpose:** First-line triage of 8 reported Copilot issues. For each ticket: ranked likely cause, fastest first check, and a call on whether this is genuinely a Copilot bug.

---

## ⚠️ Triage principle

Copilot doesn't create new access, indexing, or licensing — it surfaces whatever the signed-in user's identity, licence, and the tenant's search index already allow. The overwhelming majority of "Copilot can't do X" reports trace back to **permissions, indexing, licensing, sensitivity labels, or external/guest sharing boundaries** — not a fault in Copilot itself. A genuine Copilot bug is only concluded once those causes have been checked and ruled out.

---

## Summary table

| # | Ticket (short) | Likely cause (ranked) | Fastest check | Copilot bug? |
|---|---|---|---|---|
| 1 | Finance lead: won't summarise Q3 board pack, "I can see it myself" | 1. Sensitivity label restriction 2. Data indexing lag 3. Permissions/access boundary 4. License/client prerequisite | Check the board pack's sensitivity label/encryption settings | Unclear |
| 2 | New hire (day 1): Copilot in Outlook "knows nothing" about recent emails | 1. Data indexing lag 2. License/client prerequisite issue 3. Permissions/access boundary | Confirm Copilot licence is assigned and fully provisioned for the new hire | No |
| 3 | HR manager: "I don't have access to that content" pulling salary spreadsheet | 1. Permissions/access boundary 2. Sensitivity label restriction 3. Data indexing lag | Check the HR manager's actual permission entry on that specific spreadsheet | No |
| 4 | Sales rep: can't find client contract shared via guest link from another org | 1. Guest/external sharing limitation 2. Permissions/access boundary 3. Data indexing lag | Confirm the contract is hosted in the external org's tenant (cross-tenant guest content) | No |
| 5 | IT admin: Copilot stopped working for whole Finance team this morning, fine yesterday | 1. License/client prerequisite issue 2. Permissions/access boundary 3. Data indexing lag | Check Microsoft 365 Service Health for active incidents, and the admin change log for overnight licence/Conditional Access changes | Unclear |
| 6 | Manager: Copilot summarised a file they don't remember opening, from a forgotten folder | 1. Permissions/access boundary (legacy oversharing) | Check the file/folder's permission list for the manager's direct or group-based access | No |
| 7 | Analyst: Copilot gives generic answers, ignores internal SharePoint content | 1. License/client prerequisite issue (wrong mode/licence) 2. Data indexing lag 3. Permissions/access boundary | Confirm the analyst is using the "Work" (grounded) mode with a valid Copilot licence, not "Web" mode | No |
| 8 | EA: Copilot in Outlook can't see a shared mailbox's calendar she manages for her director | 1. Permissions/access boundary 2. License/client prerequisite issue (shared mailbox support limits) | Verify the EA's Full Access/delegate permission is correctly configured on the shared mailbox | No |

---

## Ticket 1 — Finance lead: Copilot won't summarise the Q3 board pack

**Likely cause (ranked):**
1. **Sensitivity label restriction** — board packs are prime candidates for "Highly Confidential"/encrypted labels; some label configurations block content extraction even for users with view rights.
2. **Data indexing lag** — a large board pack that was recently created or modified may not yet be crawled into the search index Copilot relies on.
3. **Permissions/access boundary** — the user can view the file via a link or delegated view, but their account may not hold the underlying permission Copilot checks against.
4. **License/client prerequisite issue** — less likely if the user is already using Copilot elsewhere.

**Fastest check:** Open the document's sensitivity label / protection settings (right-click → Properties, or Information Protection sidebar) to see if it's encrypted or restricts content extraction.

**Is this a Copilot bug?** **Unclear.** "I can see it myself" only confirms view access in the UI — it doesn't rule out a label restriction or an unindexed recent change. Needs the label and index status confirmed before concluding anything.

---

## Ticket 2 — New hire: Copilot in Outlook knows nothing about recent emails

**Likely cause (ranked):**
1. **Data indexing lag** — a brand-new mailbox has no built-up search index yet; Copilot in Outlook depends on that index to ground answers.
2. **License/client prerequisite issue** — Copilot licence assignment for a day-1 starter can take time to fully propagate.
3. **Permissions/access boundary** — unlikely, since this is the user's own mailbox.

**Fastest check:** Confirm in the Microsoft 365 admin center that the Copilot licence is assigned to the new hire and shows as fully provisioned (not still propagating).

**Is this a Copilot bug?** **No.** A day-old account with an unbuilt index and/or a licence still propagating is expected, not a fault.

---

## Ticket 3 — HR manager: "I don't have access to that content" (salary spreadsheet)

**Likely cause (ranked):**
1. **Permissions/access boundary** — the explicit denial message is Copilot enforcing exactly what the signed-in account can access; the manager may have only seen the file via someone else's screen, a stale link, or assumed access they don't actually hold.
2. **Sensitivity label restriction** — the spreadsheet may carry a label that blocks AI content extraction even for users with some access.
3. **Data indexing lag** — less likely, since the response is a specific access denial, not a "not found" result.

**Fastest check:** Look up the HR manager's actual permission entry on that specific spreadsheet (not the folder/site) to confirm whether they genuinely have access.

**Is this a Copilot bug?** **No.** An explicit "I don't have access" response is the expected boundary-enforcement behaviour working as designed.

---

## Ticket 4 — Sales rep: can't find client contract shared via guest link from another org

**Likely cause (ranked):**
1. **Guest/external sharing limitation** — Copilot has limited-to-no ability to index or ground on content hosted in another organisation's tenant, even when a guest link grants the user access.
2. **Permissions/access boundary** — the guest link may not equate to the persistent permission Copilot checks.
3. **Data indexing lag** — external/cross-tenant content is generally outside the scope of what gets indexed at all.

**Fastest check:** Confirm the contract is hosted in the external organisation's SharePoint/OneDrive (not the rep's own tenant) — cross-tenant guest content is a known indexing boundary.

**Is this a Copilot bug?** **No.** This matches a documented limitation: Copilot does not reliably index content that lives in another tenant, regardless of guest access.

---

## Ticket 5 — IT admin: Copilot stopped working for the whole Finance team this morning

**Likely cause (ranked):**
1. **License/client prerequisite issue** — a bulk licence change, expiry, or sync failure overnight affecting the team.
2. **Permissions/access boundary** — a Conditional Access or group policy change applied to Finance overnight.
3. **Data indexing lag** — unlikely to cause a sudden, team-wide "stopped working" pattern.

**Fastest check:** Check Microsoft 365 Service Health / admin center for active incidents, and the admin audit/change log for any overnight licence or Conditional Access changes affecting the Finance group.

**Is this a Copilot bug?** **Unclear.** A sudden, simultaneous, team-wide failure after working fine yesterday is consistent with either an admin-side change (licence/CA) or a genuine service incident — this is the one ticket where a real fault is plausible, but it still needs Service Health and the change log checked first before calling it a Copilot bug.

---

## Ticket 6 — Manager: Copilot summarised a file they don't remember opening, from a forgotten folder

**Likely cause (ranked):**
1. **Permissions/access boundary** — classic legacy oversharing: the manager (directly or via a group) still holds access from an old project/migration, and Copilot is correctly surfacing content within that access.

**Fastest check:** Check the file or folder's permission list to confirm the manager's direct or group-based access and where it originated.

**Is this a Copilot bug?** **No.** This is Copilot working as designed — surfacing content the account can already reach. It's a useful signal to flag for an oversharing/permissions review, not a product fault.

---

## Ticket 7 — Analyst: Copilot gives generic answers, ignores internal SharePoint content

**Likely cause (ranked):**
1. **License/client prerequisite issue** — the analyst may be using ungrounded "Web" mode in Copilot Chat, or lack the M365 Copilot licence needed for "Work" (tenant-grounded) mode.
2. **Data indexing lag** — if the relevant SharePoint content hasn't been crawled yet tenant-wide.
3. **Permissions/access boundary** — the analyst may simply lack access to the SharePoint content they expect Copilot to draw on.

**Fastest check:** Confirm which mode the analyst is using in Copilot Chat (Work vs Web) and confirm they hold a valid M365 Copilot licence.

**Is this a Copilot bug?** **No.** "Generic, non-grounded answers" is the expected behaviour of Web mode or a missing licence, not a fault.

---

## Ticket 8 — Executive assistant: Copilot in Outlook can't see a shared mailbox's calendar

**Likely cause (ranked):**
1. **Permissions/access boundary** — Full Access/delegate permission on a shared mailbox doesn't always equate to the Graph-level visibility Copilot checks.
2. **License/client prerequisite issue** — Copilot's support for shared/delegated mailboxes is more limited than for a user's primary mailbox.

**Fastest check:** Verify the EA's Full Access and Send-As/delegate permissions are correctly configured on the shared mailbox.

**Is this a Copilot bug?** **No.** This matches a known product limitation around shared mailbox support rather than a fault.
