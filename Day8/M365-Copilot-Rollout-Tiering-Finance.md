# M365 Copilot Readiness — Rollout Tiering (Finance Department)

**Prepared by:** DWP Engineering
**Date:** 12/08/2026
**Source:** [M365-Copilot-Readiness-Checklist-Finance.md](./M365-Copilot-Readiness-Checklist-Finance.md)

This document re-sorts the readiness checklist into three risk-based tiers for the Finance rollout (~200 users, unaudited permissions since a 2019 migration, data including payroll, board packs, M&A documents, and client financial data).

---

## Tier 1 — MUST complete before rollout (blocking)

*Failure here means Copilot either creates an active security/compliance exposure, or operates without the safety controls this data set requires. Rollout does not proceed until every item below is signed off.*

**Permissions & Oversharing (all items):**
- [ ] Full SharePoint/OneDrive permissions and sharing report across all Finance sites/libraries
- [ ] Remediation of "Everyone" / "Everyone except external users" / broad "Anyone with the link" sharing
- [ ] Explicit access audit of payroll, board pack, M&A, and client financial data locations
- [ ] Cleanup of broken/"ghost" inherited permissions from repurposed or disbanded groups
- [ ] Disabling of anonymous/unauthenticated external sharing links
- [ ] Sweep of inactive/unused Finance sites and libraries for lingering broad permissions
- [ ] OneDrive external sharing settings confirmed to match policy for Finance content
- [ ] Permissions Analytics for Copilot / oversharing assessment run and reviewed
- [ ] Site ownership confirmed for every Finance site (no orphaned sites)
- [ ] Written sign-off from Finance data owners / Information Security on remediation completion

**Identity security (core, not enablement):**
- [ ] MFA enforced for all 200 Finance users, no exclusions
- [ ] Legacy authentication protocols blocked for Finance-scoped access
- [ ] Conditional Access requiring compliant/managed devices for Finance SharePoint/OneDrive access

**Sensitivity & data protection (top-tier content only):**
- [ ] Payroll, board pack, and M&A content correctly labelled at "Highly Confidential" (or equivalent) with encryption applied
- [ ] Confirmed test that Copilot cannot surface/summarise encrypted, label-restricted content to unauthorised users
- [ ] DLP policies for financial data patterns tested specifically against Copilot-surfaced content

---

## Tier 2 — SHOULD complete before rollout (high risk if skipped)

*Important and expected before go-live, but a gap here delays or degrades the rollout rather than causing a silent data exposure. These should still be done before Copilot licences are assigned, but a small, tracked exception here is a judgement call, not a hard stop.*

**Licensing:**
- [ ] Microsoft 365 E5 confirmed for all in-scope users
- [ ] Copilot add-on licences purchased/available for the pilot/full headcount
- [ ] Entra ID P1 confirmed present for all in-scope users
- [ ] Underlying workload licences (Exchange, SharePoint, OneDrive, Teams) confirmed active
- [ ] No individually disabled service plans breaking a Copilot dependency

**Client versions:**
- [ ] Microsoft 365 Apps for enterprise on Current/Monthly Enterprise Channel, supported build
- [ ] New Teams client deployed
- [ ] Outlook on required supported build
- [ ] Windows 10 (supported)/Windows 11 confirmed
- [ ] Supported browser confirmed for Mac/web-only users
- [ ] Outdated/unmanaged devices identified and excluded from Copilot eligibility

**Identity (supporting controls):**
- [ ] Break-glass accounts confirmed, excluded correctly, and monitored
- [ ] Risk-based Conditional Access (e.g., block high-risk sign-in) active for Finance users
- [ ] Guest/external identities with Finance access reviewed for continued validity

**Sensitivity labelling (broader rollout, beyond top-tier content):**
- [ ] Label taxonomy published and understood by users
- [ ] Default labelling configured on Finance libraries
- [ ] Mandatory labelling enabled where policy requires
- [ ] Label priority/ordering configured correctly
- [ ] Auto-labelling policies configured and initially tested

**Enablement:**
- [ ] Pre-rollout communication sent to Finance staff
- [ ] Pilot group selected and briefed
- [ ] Champions/super-users identified
- [ ] Feedback/issue-reporting channel established
- [ ] Copilot guidance aligned to the organisation's AI usage charter
- [ ] Initial service desk guidance prepared for common first-week issues

---

## Tier 3 — CAN complete during/after rollout (lower risk)

*Reasonable to finish once the pilot is live, since a gap here is low-impact, easily corrected, and often benefits from real usage data anyway.*

- [ ] 30-day repeat permissions/oversharing scan post go-live (by design, this happens *after* rollout as a safety net, not before)
- [ ] Tuning/refinement of auto-labelling accuracy based on real content patterns observed post-launch
- [ ] Expansion of champions network and comms beyond the initial pilot group as rollout phases widen
- [ ] Iteration of self-service/service desk guidance based on actual pilot feedback and real tickets
- [ ] Ongoing device compliance monitoring cycle (initial check is Tier 2; continuous monitoring continues indefinitely)

---

## Why Permissions & Oversharing is MUST, even though licensing and client version are simpler to verify

Licensing and client-version checks are necessary, but they are **self-evident and self-correcting failures**: if a user is missing a Copilot licence, Copilot simply doesn't appear for them — visible immediately, low severity, fixed in minutes by assigning a licence. If a device is on an unsupported Office build, Copilot again just doesn't activate. Nothing bad happens; the result is a delay for that user, not damage. These are best understood as **enablement checks** — if incomplete, you get friction, not harm.

Permissions and oversharing is a fundamentally different category: it is a **silent failure mode**. If a site or document is over-permissioned, Copilot will not error or warn — it will succeed, and it will summarise or surface payroll, board, M&A, or client financial data to someone who has some technical access path to it but was never intended to see it. There is no symptom until after the exposure has already happened, and unlike a missing licence, **you cannot undo a disclosure** — once sensitive content has been seen, copied, or acted on, tightening the permission afterwards doesn't reverse the harm.

This risk is not theoretical for this department specifically: permissions here were inherited from a **2019 migration that has never been audited**, so the probability that live oversharing already exists today is high, not hypothetical. Combined with the sensitivity of the data set (payroll, board packs, M&A, client financial data), this is the one category where "fix it after rollout" is not an acceptable fallback — by the time the gap is discovered, the exposure has already occurred. That is why it sits alone at the top of Tier 1, ahead of every other item regardless of how quick or simple those other checks are to perform.
