# Microsoft 365 Copilot Guide — Contract Specialist Generic Answers

**Prepared by:** DWP Engineering  
**Date:** 12/08/2026  
**Audience:** Service desk and end user

---

## Incident triage summary

**Ticket summary:** Contract specialist reports that Copilot gives vague, generic answers when asked about clauses in the contract templates library and does not appear to read the documents.

**Impact:** Single user reported. Medium impact. User productivity and content quality are affected because Copilot is not grounding on internal templates as expected.

**Known facts:**

- The user is asking about clauses in a contract templates library.
- Copilot replies are generic rather than document-specific.
- The user believes Copilot is not reading the source documents.

**Most likely cause:** Copilot is not grounding against internal work content.

**Other possible causes to check:**

- User is in a web or general mode instead of work-grounded mode
- User lacks access to the template library or parts of it
- SharePoint library indexing has not completed
- Prompts are too broad to force a document-specific answer

**Information to gather:**

1. Which Copilot entry point is being used
2. Whether the user can open the template library and documents directly
3. Whether the user sees a work-grounded mode option
4. Whether the issue affects all templates or only some files
5. Whether the same library can be found via normal SharePoint or Microsoft 365 search

**First triage actions:**

1. Confirm the user is using the work-grounded Copilot experience.
2. Confirm the user's Microsoft 365 Copilot licence is active.
3. Verify access to the SharePoint template library.
4. Check whether the library content is searchable and indexed.
5. Test with a narrow prompt against a specific open template.

**Initial support conclusion:** Most likely not a document fault. Treat as a grounding, access, indexing, or prompt-quality issue first.

---

## End-user communication

**Subject:** Why Copilot is giving generic answers on contract templates

Hi,

When Copilot gives broad, generic answers about internal templates, it usually means it is not using the documents in your template library as its source. That can happen if it is running in a general mode, if the library is not fully available to Copilot yet, or if the prompt is too broad to point it at the right content.

**What you can do next:**

1. Make sure you are using the work or internal-content mode.
2. Open the relevant template or the template library in SharePoint first.
3. Ask a specific question about a named clause or template rather than a broad question.
4. If the answers stay generic, let IT know so we can check licence, access, and indexing.

Your template documents are not being altered by this. The issue is usually about how Copilot is finding and grounding on the content, not about the documents themselves.

---

## Your issue in plain English

You are asking Copilot about clauses in your contract templates library, but the answers are vague and generic.

That usually means Copilot is **not grounding its answer in your internal documents**. Common reasons are:

- it is using a general web-style mode rather than work content
- it does not yet have access to the template library content
- the library content has not fully indexed yet
- the prompt is too broad, so Copilot falls back to a generic answer

---

## What to do next

1. Check that you are using the work or internal-content mode, not a general web mode.
2. Open the relevant template manually first, or open the template library in SharePoint.
3. Ask about a specific clause, template, or risk area instead of asking a broad question.
4. If the problem continues, ask IT to confirm your licence and whether the library content is available to Copilot.

---

## What IT will likely check

- Whether your Microsoft 365 Copilot licence is active
- Whether the contract templates library is accessible to your account
- Whether the SharePoint library has indexed properly for Microsoft 365 search

---

## Better prompts to use

Instead of:

> Tell me about clauses in our templates.

Use prompts like:

> Using our contract templates library, explain the limitation of liability clause in plain English and compare how it differs across the main template versions.

Or:

> Review the confidentiality clause in this template and list any wording that is stricter than our usual standard position.

The more specific the prompt, the more likely Copilot is to use the right document and give a useful answer.

---

## Key point

This is most likely a **grounding, access, indexing, or prompt-quality issue**, not a Copilot fault in the document itself.