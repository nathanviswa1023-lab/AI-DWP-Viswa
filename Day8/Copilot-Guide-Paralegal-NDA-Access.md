# Microsoft 365 Copilot Guide — Paralegal NDA Access Message

**Prepared by:** DWP Engineering  
**Date:** 12/08/2026  
**Audience:** Service desk and end user

---

## Incident triage summary

**Ticket summary:** Paralegal asked Copilot to summarise a client NDA in SharePoint and received the message: **"I don't have access to that content."** The file is in a folder she has heard about but has not previously opened herself.

**Impact:** Single user reported. Medium business impact. Productivity is affected because the user cannot use Copilot to speed up document review, but there is no evidence of data loss or service outage.

**Known facts:**

- The content is a client NDA stored in SharePoint.
- Copilot returned an explicit access-denied style message.
- The user has not previously opened the folder herself.
- The folder was only mentioned in a meeting.

**Most likely cause:** SharePoint permissions boundary. Copilot is enforcing the same access model as the underlying Microsoft 365 content source.

**Other possible causes to check:**

- Sensitivity label or encryption on the document
- Search or indexing delay if the file was recently added or moved
- A mismatch between folder-level and file-level permissions

**Information to gather:**

1. Can the user open the folder and file directly in SharePoint with her own account?
2. Is there an access request option shown in SharePoint?
3. Is the file protected by a sensitivity label or encryption policy?
4. Was the NDA recently created, uploaded, moved, or re-permissioned?
5. Does the user need access as part of her current role, and who is the data owner?

**First triage actions:**

1. Ask the user to test direct access to the folder and file in SharePoint.
2. Check file and folder permissions in SharePoint.
3. Check whether a sensitivity label is blocking Copilot content extraction.
4. If the user can open the file manually, verify whether indexing has completed.

**Initial support conclusion:** Most likely not a Copilot fault. Treat first as an access and content-governance check.

---

## End-user communication

**Subject:** Update on your Copilot NDA summary request

Hi,

The message you received, **"I don't have access to that content,"** usually means Copilot is correctly following the same access rules as SharePoint. In plain English, Copilot can only summarise files that your own account is already allowed to open.

Because this NDA is in a folder you have not opened before, the most likely reason is that your account does not currently have access to that folder or file. If you try opening it directly in SharePoint and you are blocked there too, that confirms it is an access issue rather than a Copilot fault.

**What you can do next:**

1. Try opening the folder and file directly in SharePoint.
2. If access is denied there as well, request access through the file owner or the normal approval route.
3. If you can open the file but Copilot still cannot summarise it, let IT know so we can check indexing or document protection settings.

Your existing files and access are safe. Copilot is not exposing anything new here; it is applying the same permissions already set on the document.

---

## Your issue in plain English

You asked Copilot to summarise a client NDA in SharePoint and got the message: **"I don't have access to that content."**

This usually means Copilot is working correctly and protecting access to the file. Copilot can only read documents that **your own account is already allowed to open**. Hearing about a folder in a meeting does not give access to it, and Copilot cannot bypass SharePoint permissions.

In this case, the strongest clue is that the file is in a folder you have never opened before. That suggests your account may not currently have permission to the folder or document.

---

## What to do next

1. Try opening the folder and the NDA directly in SharePoint with your own account.
2. If SharePoint also blocks you, request access through the file owner or the normal approval route.
3. If you can open the file manually but Copilot still cannot summarise it, let IT know. The document may still be indexing or have a protection setting that limits Copilot.
4. Once access is granted, open the file once yourself before asking Copilot again.

---

## What IT will likely check

- Whether your account has permission to the specific folder and file
- Whether the document has a sensitivity or protection label applied
- Whether the file has finished indexing for Microsoft 365 search and Copilot

---

## Better prompt to use once access is confirmed

Try a specific prompt such as:

> Summarise this NDA in plain English in 5 bullet points, focusing on termination, liability, confidentiality, and any unusual obligations.

If you need a legal-review version, try:

> Summarise this NDA for a paralegal review. List the key clauses, the main risks, and any wording that should be escalated to a solicitor.

---

## Key point

This is most likely an **access issue, not a Copilot fault**. Copilot is following the same SharePoint permissions as the rest of Microsoft 365.