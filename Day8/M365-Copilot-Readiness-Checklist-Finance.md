# Microsoft 365 Copilot Readiness Checklist — Finance Department (~200 users)

**Prepared by:** DWP Engineering
**Date:** 12/08/2026
**Scope:** Finance department, ~200 users, Microsoft 365 E5 licensed, Copilot add-on not yet assigned
**Context:** SharePoint permissions inherited from a 2019 migration, never audited since. Data in scope includes payroll, board packs, M&A documents, and client financial data.

---

## ⚠️ Why permissions come first in this checklist

Copilot doesn't create new access — it surfaces and summarises whatever a signed-in user can already reach. For most departments that's a manageable risk. For **this** department it is not, because:

- Permissions were inherited from a **2019 migration that has never been audited**, so nobody currently has full confidence in who can access what.
- The data set includes **payroll, board packs, M&A documents, and client financial data** — exactly the content where an oversharing mistake has the highest business, legal, and regulatory consequence.
- Copilot will actively **find and summarise over-permissioned content that a human might never have stumbled across manually** — it turns a dormant access problem into an active disclosure risk.

For this reason, **Section 1 (Permissions & Oversharing) must be fully complete and signed off before the Copilot licence is assigned to a single Finance user** — treat it as a hard gate, not a parallel workstream.

---

## Section 1 — Permissions & Oversharing Remediation (P0 — highest priority, gate to go-live)

- [ ] Run a full **SharePoint/OneDrive permissions and sharing report** across every Finance site, document library, and Teams-linked site (via SharePoint Advanced Management / Data Access Governance reports, or equivalent).
- [ ] Identify and remediate all sites/folders/files with **"Everyone" / "Everyone except external users" / broad "Anyone with the link"** sharing still in place from or since the 2019 migration.
- [ ] Specifically audit **payroll, board pack, M&A, and client financial data locations** for scope of access — confirm access lists match current org structure, not 2019-era group membership.
- [ ] Identify and clean up **broken or "ghost" inherited permissions** (e.g., permissions granted to security groups that have since been repurposed, disbanded, or renamed).
- [ ] Identify and disable/expire **anonymous ("Anyone") and unauthenticated external sharing links** anywhere in Finance content, replacing with named-user or "specific people" links.
- [ ] Run an **inactive/unused sites and libraries sweep** — identify Finance-adjacent sites nobody has touched since migration; either archive, remove Copilot's ability to index them, or bring them into scope of the audit.
- [ ] Confirm **OneDrive external sharing settings** at the tenant and site level match policy intent for Finance (e.g., external sharing disabled or restricted for M&A/board content).
- [ ] Where available, run **Permissions Analytics for Copilot / oversharing assessment** tooling to get a Copilot-specific view of "who could Copilot now surface this to" before go-live.
- [ ] Confirm **site owners are identified and accountable** for every Finance site — no orphaned sites with no active owner.
- [ ] Obtain **written sign-off from Finance data owners / Information Security** that the oversharing remediation is complete, with a dated snapshot of the "before" state for audit purposes.
- [ ] Schedule a **repeat permissions/oversharing scan 30 days post go-live** to catch anything missed or newly introduced.

---

## Section 2 — Licensing Prerequisites

- [ ] Confirm all ~200 Finance users hold an active **Microsoft 365 E5** licence (already in place per current state).
- [ ] Confirm **Microsoft 365 Copilot add-on licences** are purchased/available for the full Finance headcount (or the confirmed pilot subset — see Section 6).
- [ ] Confirm **Entra ID P1** is present for all in-scope users (included in E5) — required for Copilot-related Conditional Access and identity features.
- [ ] Confirm underlying workload licences Copilot depends on are active and unblocked: **Exchange Online, SharePoint Online, OneDrive, Teams**.
- [ ] Confirm no **service plan has been individually disabled** on any user's E5 licence that would silently break a Copilot dependency (e.g., SharePoint or Exchange plan turned off in a custom licence group).
- [ ] Do **not** assign Copilot add-on licences to any user until Section 1 sign-off is complete.

---

## Section 3 — Microsoft 365 Apps Client Version Requirements

- [ ] Confirm all Finance devices are running **Microsoft 365 Apps for enterprise** (not perpetual/volume-licensed Office 2019/2021) — Copilot in Word/Excel/PowerPoint/Outlook requires the subscription channel.
- [ ] Confirm devices are on **Current Channel or Monthly Enterprise Channel** at a supported build level (check current Microsoft minimum build requirements at time of rollout, as this moves forward regularly).
- [ ] Confirm **new Teams client** is deployed (classic Teams client does not support Copilot).
- [ ] Confirm **Outlook** is running the required build for Copilot (new Outlook or a supported classic Outlook build, per current Microsoft guidance).
- [ ] Confirm devices are on a supported **Windows 10 (with support) or Windows 11** build — align with the Win11 migration already completed for this estate.
- [ ] For any Finance users on **Mac or web-only access**, confirm supported browser (Edge/Chrome, current version) for Copilot web experiences.
- [ ] Identify and remediate any **outdated/unmanaged devices** (e.g., non-Intune-enrolled personal devices) accessing Finance data — these should not be Copilot-eligible until compliant.

---

## Section 4 — Identity / MFA Readiness

- [ ] Confirm **MFA is enforced for all 200 Finance users** — no exclusions, no legacy per-user MFA gaps.
- [ ] Confirm **legacy authentication protocols are blocked** tenant-wide (or at minimum for Finance-scoped Conditional Access) — legacy auth bypasses MFA.
- [ ] Confirm **Conditional Access policies** require compliant/Intune-managed devices for access to Finance SharePoint/OneDrive content, ahead of adding Copilot into the mix.
- [ ] Confirm **break-glass emergency access accounts** exist, are excluded from standard CA policy as designed, and are monitored.
- [ ] Confirm **sign-in and risk-based Conditional Access** (e.g., block on high-risk sign-in) is active for Finance users given the sensitivity of the data Copilot will now be able to surface.
- [ ] Review **guest/external identities** with any access into Finance sites — confirm still valid and necessary; remove stale guest accounts.

---

## Section 5 — Sensitivity Labelling

- [ ] Confirm a **sensitivity label taxonomy** exists and is published to Finance users (e.g., Public / Internal / Confidential / Highly Confidential).
- [ ] Confirm **payroll, board pack, and M&A content** is labelled at the appropriate "Highly Confidential" (or equivalent) tier, with encryption applied where supported.
- [ ] Confirm **default labelling** is configured for Finance document libraries so new content isn't left unlabelled by default.
- [ ] Confirm **mandatory labelling** (forced label selection on save/send) is enabled for Finance users, where policy requires it.
- [ ] Confirm **auto-labelling policies** (content-based, e.g., detecting payroll data patterns or M&A keywords) are configured and tested, not just relying on manual user labelling.
- [ ] Confirm **label priority/ordering** is correctly configured so the most restrictive applicable label wins on conflict.
- [ ] Test that **Copilot respects label-based encryption/restrictions** in practice (e.g., a user without rights to an encrypted "Highly Confidential" file cannot have Copilot summarise or surface its contents).
- [ ] Confirm **DLP policies** relevant to financial data (e.g., card numbers, client account data) are active and tested against Copilot-surfaced content, not just email/endpoint.

---

## Section 6 — End-User Comms & Enablement

- [ ] Prepare and send **pre-rollout communication** to Finance staff explaining what Copilot is, what it can access (their own permitted content only), and what it changes day-to-day.
- [ ] Run a **small pilot group first** (not all 200 users at once) — mirrors the phased-rollout approach used for other recent changes in this estate; expand only once the pilot is clean.
- [ ] Provide **practical guidance** on responsible use: e.g., don't assume a Copilot summary is complete/authoritative for board or regulatory decisions; verify source documents for high-stakes outputs.
- [ ] Brief users specifically that **oversharing issues found in Section 1 may change what they can see** in familiar sites/folders — set expectations so this isn't reported as a "fault."
- [ ] Identify **Finance champions/super-users** to field early questions and gather feedback before wider rollout.
- [ ] Confirm a **feedback/issue-reporting channel** is in place (e.g., service desk category or dedicated inbox) specifically for Copilot-related reports.
- [ ] Ensure Copilot usage guidance aligns with and references the organisation's existing **AI usage charter/acceptable use policy**.
- [ ] Prepare **service desk / self-service guidance** for common first-week issues (e.g., "Copilot not appearing," "can't see expected content") so support is ready before go-live, not reactive.

---

## Go-live gate summary

1. **Section 1 (Permissions & Oversharing) — must be 100% complete and signed off.**
2. Sections 2–5 (Licensing, Client versions, Identity/MFA, Sensitivity labelling) — must be complete.
3. Section 6 (Comms/Enablement) — pilot group briefed and ready.
4. Only then: assign Copilot licences to the agreed pilot group, monitor, then proceed to phased wider rollout.
