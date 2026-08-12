# Microsoft 365 Copilot Guide — Partner Unexpected Matter Access

**Prepared by:** DWP Engineering  
**Date:** 12/08/2026  
**Audience:** Service desk and end user

---

## Incident triage summary

**Ticket summary:** Partner reports that Copilot surfaced and summarised a draft settlement from a legal matter the partner is not assigned to.

**Impact:** High sensitivity. Single user report, but possible wider information-governance exposure if permissions are mis-scoped. Requires prompt review because legal matter access may be broader than intended.

**Known facts:**

- Copilot surfaced content from a matter the user says they are not assigned to.
- The surfaced content was a draft settlement.
- The user did not expect to have visibility of that folder.

**Most likely cause:** Legacy, inherited, or unintended SharePoint or Microsoft 365 permissions.

**Other possible causes to check:**

- Access inherited through a Microsoft 365 group, Team, or historic workspace membership
- Matter workspace oversharing at folder or library level
- A stale access group that has not been cleaned up after past assignments

**Information to gather:**

1. Matter name, document path, and workspace location
2. Whether the user can open the file directly outside Copilot
3. Whether access is direct or inherited through a group
4. Whether other unrelated users also have access to the same matter workspace
5. Whether the matter workspace has a documented access-control owner

**First triage actions:**

1. Confirm the user's direct and inherited access to the file and folder.
2. Check group memberships linked to the matter workspace.
3. Review whether the same workspace is visible to other users outside the matter team.
4. Engage the document owner or legal data owner for permission correction.

**Initial support conclusion:** Not a Copilot bug. Treat as a permissions and governance incident exposed by Copilot.

---

## End-user communication

**Subject:** Review of unexpected matter content surfaced by Copilot

Hi,

Copilot does not create new access by itself. If it surfaced this draft settlement, that usually means your account already has some level of permission to the underlying folder or file in Microsoft 365. Because this is legal matter content, we are treating it as a permissions review rather than a normal usability issue.

**What you can do next:**

1. Do not circulate or rely on the document further.
2. Send IT the matter name and file or folder details.
3. If you believe you should never have had access, tell us that clearly so we can review related permissions as well.

Your report is useful because it helps identify access that may need to be tightened. The next step is an access review, not a Copilot repair.

---

## Your issue in plain English

Copilot surfaced and summarised a draft settlement from a matter you are not assigned to.

That does **not** mean Copilot created new access. Copilot only works with information your account can already reach. In plain terms, this usually means your account already has access to that folder or document somewhere in SharePoint, Teams, or another Microsoft 365 location.

Because this is legal matter content, this should be treated seriously. The likely issue is **unexpected or outdated permissions**, not Copilot making something up.

---

## What to do next

1. Do not rely on or circulate the document further.
2. Report the matter name, file, or folder to IT and the relevant document owner so access can be reviewed.
3. Ask for your permissions on that matter workspace to be checked and, if needed, removed.
4. If you believe you should never have had access, ask for a wider permissions review on related folders as well.

---

## What IT will likely check

- Whether you have direct access to the document or folder
- Whether you inherited access through a Microsoft 365 group, Team, or historic project membership
- Whether similar legal matter folders are overshared more broadly than intended

---

## Safe prompting guidance

Until the access review is complete, keep prompts tightly scoped to matters you know you should work on. For example:

> Summarise documents and emails from matters where I am currently a listed team member, and exclude anything outside my active matters.

That prompt will not override permissions, but it helps keep results focused on the right working set.

---

## Key point

This is most likely a **permissions hygiene issue that Copilot has exposed**, not a Copilot fault. The right next step is an access review.