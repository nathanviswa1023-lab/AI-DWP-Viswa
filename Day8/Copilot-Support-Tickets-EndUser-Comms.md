# Copilot Support Tickets — End-User Communications

**Prepared by:** DWP Engineering
**Date:** 12/08/2026
**Purpose:** Plain-English messages to send back to each end user, explaining what's happening with their Copilot issue and what happens next. Based on the triage in [Copilot-Support-Tickets-Triage.md](./Copilot-Support-Tickets-Triage.md).

---

## Ticket 1 — Finance lead: Copilot won't summarise the Q3 board pack

**Subject: Update on your Copilot / Q3 board pack issue**

Hi,

Thanks for reporting this. Being able to see a file yourself doesn't always mean Copilot can read and summarise it — a couple of things can cause that gap, most commonly:

- The board pack may have a confidentiality/protection setting applied that stops Copilot from reading its contents, even though you can open it.
- If the file was created or edited very recently, it can take a little time before Copilot's search index picks it up.

**What we're doing:** We're checking the document's protection settings and confirming it's been fully indexed.

**What you can do in the meantime:** Continue working with the file directly as normal — this doesn't affect your ability to open or edit it, only Copilot's ability to summarise it. We'll come back to you once we know which of the two it is and whether it can be resolved.

---

## Ticket 2 — New hire: Copilot in Outlook doesn't know about recent emails

**Subject: Copilot in Outlook — expected for new accounts**

Hi,

Welcome aboard! What you're seeing is normal for a brand-new account and isn't a fault. Two things typically need to "catch up" for a new starter:

- Your mailbox needs a short time to be fully indexed before Copilot can use its contents.
- Your Copilot licence can take a little time to fully activate after being assigned.

**What we're doing:** We're confirming your Copilot licence is active and fully set up.

**What you can do:** Give it a short period and try again — this typically resolves itself within a day or so as your account settles in. If it's still not working after that, let us know and we'll look further.

---

## Ticket 3 — HR manager: "I don't have access to that content" (salary spreadsheet)

**Subject: Copilot access message — expected behaviour**

Hi,

The message you received ("I don't have access to that content") is Copilot correctly telling you that your account doesn't currently have permission to that specific spreadsheet — it's not a bug, it's Copilot respecting the same access rules as everything else in SharePoint/Teams.

**What we're doing:** We're checking exactly what access you currently have to that file, and confirming with the data owner whether you should be granted access.

**What you can do:** If you believe you should have access to this spreadsheet for your role, let us know and we'll raise it with the file owner to review. Please don't request access from colleagues informally in the meantime — it needs to go through the proper approval so the audit trail is correct.

---

## Ticket 4 — Sales rep: Copilot can't find a client contract shared via a guest link

**Subject: Copilot and externally-shared files — a known limitation**

Hi,

This one is a known limitation rather than a fault: when a file is shared with you via a guest link from another company's system, it lives entirely in their environment, not ours. Copilot generally isn't able to search or summarise files that live outside our organisation, even when you have a valid link to open them.

**What we're doing:** We're confirming this is indeed an externally-hosted file so we can close this out with the right explanation.

**What you can do:** Continue opening the contract directly via the link as you have been — that access isn't affected. For anything you need Copilot to search or summarise, the most reliable option is to save a copy into our own SharePoint/Teams once you're cleared to do so, so it's inside our environment and indexed properly.

---

## Ticket 5 — IT admin: Copilot stopped working for the whole Finance team this morning

**Subject: Copilot outage — Finance team — investigating**

Hi,

Thanks for flagging this quickly. Because this affected the whole team suddenly, and was working fine yesterday, we're treating it as a priority investigation rather than an individual issue.

**What we're doing:** We're checking Microsoft's service status for any ongoing incidents, and reviewing our own admin change logs for anything altered overnight (licensing or access policy changes) that could explain a team-wide, same-morning change.

**What you can do:** Please ask the Finance team to hold off retrying repeatedly for now, and let us know if anyone sees a specific error message (rather than just "not working") — that detail will help us narrow this down faster. We'll update you as soon as we have a cause.

---

## Ticket 6 — Manager: Copilot surfaced a file they don't remember opening

**Subject: About the file Copilot found for you**

Hi,

This isn't a fault — Copilot only ever shows you files that your account already has permission to access, the same as if you searched for it yourself in SharePoint. The fact that you didn't remember the file or folder usually just means the access was granted a while ago (e.g. from an old project or team) and simply hadn't been used since.

**What we're doing:** We're reviewing where that access came from, as part of good housekeeping, to make sure your current permissions still make sense for your role.

**What you can do:** Nothing required from you. If you don't recognise why you have access to that folder at all, let us know and we can look at removing access you no longer need.

---

## Ticket 7 — Analyst: Copilot gives generic answers, doesn't use internal content

**Subject: Getting Copilot to use our internal SharePoint content**

Hi,

This usually comes down to which "mode" Copilot is running in. Copilot Chat can answer using general web knowledge only, or it can be set to ground its answers in our internal SharePoint/Teams content — if it's set to the general mode, or your licence for the internal mode isn't active, you'll get exactly the kind of generic answers you've described.

**What we're doing:** We're confirming your licence is correctly set up for grounded (internal-content) answers.

**What you can do:** In Copilot Chat, check whether you have an option to switch between "Web" and "Work" (or similar) — try switching to the work/internal option and see if that changes the results. Let us know either way and we'll follow up with the licensing check regardless.

---

## Ticket 8 — Executive assistant: Copilot can't see a shared mailbox's calendar

**Subject: Copilot and the shared mailbox calendar**

Hi,

Copilot's support for shared mailboxes (like the one you manage for your director) is more limited than for your own personal mailbox — even with full access to manage it day-to-day, Copilot doesn't always have the same visibility into shared mailbox content.

**What we're doing:** We're double-checking your permissions on the shared mailbox are set up correctly, and confirming what level of support Copilot currently offers for shared mailboxes.

**What you can do:** Continue managing the calendar directly in Outlook as normal — that isn't affected. We'll let you know if there's a supported way to bring Copilot into that workflow, or if this is simply a current limitation to be aware of.
