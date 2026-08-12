# Microsoft 365 Copilot Guide — New Associate Outlook Context

**Prepared by:** DWP Engineering  
**Date:** 12/08/2026  
**Audience:** Service desk and end user

---

## Incident triage summary

**Ticket summary:** New associate who started this week reports that Copilot in Outlook cannot find relevant case emails needed for context.

**Impact:** Single user reported. Low-to-medium impact. The user can still use Outlook directly, but Copilot assistance is limited during onboarding.

**Known facts:**

- The user is a new starter from this week.
- The issue is within Copilot in Outlook.
- The complaint is that Copilot cannot find case emails needed for context.
- No service-wide issue has been reported.

**Most likely cause:** New account provisioning and mailbox indexing delay.

**Other possible causes to check:**

- Copilot licence not fully provisioned yet
- Outlook signed into the wrong mailbox or profile
- Mailbox still settling after creation or migration steps

**Information to gather:**

1. Exact start date of the user
2. Whether the Copilot licence has been assigned in Microsoft 365 admin tools
3. Whether Outlook is signed into the expected primary work mailbox
4. Whether Copilot fails on all email searches or only certain matters
5. Whether the same user can find those emails through standard Outlook search

**First triage actions:**

1. Confirm the Microsoft 365 Copilot licence is active.
2. Confirm the mailbox is provisioned and Outlook is using the correct work account.
3. Ask the user to retry after a short delay if the account is only days old.
4. Compare normal Outlook search results with Copilot behaviour.

**Initial support conclusion:** Most likely not a Copilot bug. Treat first as a provisioning and indexing delay for a new starter.

---

## End-user communication

**Subject:** Copilot in Outlook for a new starter

Hi,

Because your account is brand new, what you are seeing is usually expected for a short time. Copilot in Outlook depends on your mailbox being fully set up and indexed, and your Copilot licence being fully active. Both of those can take a little time after a new starter joins.

**What you can do next:**

1. Try again later today or the next working day.
2. Make sure Outlook is signed into your main work account.
3. If it still cannot find the emails after that, let IT know so we can check your licence and mailbox setup.

Your mailbox and emails are safe. This does not suggest data loss or missing emails; it usually means Copilot is still catching up with a new account.

---

## Your issue in plain English

You started this week and Copilot in Outlook cannot find the case emails you need.

For a brand-new starter, this is usually expected for a short period. Copilot in Outlook depends on two things being ready:

- your Microsoft 365 Copilot licence must be fully active
- your mailbox content must be indexed so Copilot can search and summarise it

If your account is only a few days old, one or both of those may still be catching up.

---

## What to do next

1. Give it a short amount of time if you only started this week.
2. Try again later the same day or the next working day.
3. Make sure you are signed into the correct work account in Outlook.
4. If Copilot still cannot find the emails after that, raise it with IT so they can confirm your licence has fully provisioned.

---

## What IT will likely check

- Whether your Copilot licence is assigned and active
- Whether your mailbox has fully provisioned
- Whether Outlook and Copilot are using your primary work mailbox correctly

---

## Better prompts to use once the account has settled

Try prompts with a time range, people, and outcome. For example:

> Summarise my emails from the last 7 days about the Hawthorne case and list any actions assigned to me.

Or:

> Look at my recent emails with Sarah Patel and explain the background to the case in plain English in 6 bullet points.

Specific prompts work better than broad requests like "find my case emails".

---

## Key point

This is most likely a **new-account setup and indexing delay, not a Copilot fault**.