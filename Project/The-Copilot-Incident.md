# Triage Summary: Copilot Unauthorized Content Access

## Summary
User reports Copilot retrieved case/matter content they do not have permission to access.

## Impact
- **Who:** Single user (to confirm if isolated or broader)
- **Business Urgency:** HIGH — Potential data leakage; compliance/audit concern
- **Scope:** To confirm — single matter or multiple documents involved

## Known Facts
- User accessed Copilot and received content for a matter/case
- User confirmed they have no authorization for this matter
- Copilot rendered the unauthorized content in the response

## Missing Information to Gather
- **User and Copilot context:** Which Copilot instance (Microsoft Copilot, company-hosted, integrated plugin)?
- **Source system:** Where is the matter/case data stored (SharePoint, document library, case management system)?
- **Access scope:** Does the user have access to *any* matters, or is this role completely restricted?
- **Reproduction:** Can the user reliably reproduce this? (exact prompt/steps)
- **Timeline:** When did this occur? Has it happened before?
- **Scope confirmation:** Is this affecting only this user or others with similar roles?
- **Content sensitivity:** Classification level of the matter (confidential, client-sensitive, etc.)?

## Likely Category
**Information Security / Data Access Control**
- Root cause: Permissions not enforced in Copilot's data retrieval layer
- Secondary: Possible authentication/session token issue

## First Diagnostic Steps
1. **Verify user's actual permissions** — Confirm in source system (SharePoint/case management) that user genuinely lacks access
2. **Check Copilot configuration** — Review what data sources Copilot queries and if row-level security (RLS) is enabled
3. **Reproduce with exact prompt** — Have user provide the exact query/prompt that returned unauthorized content
4. **Session audit** — Review audit logs for this user's Copilot session and data retrieval calls
5. **Escalate to:** Information Security / Data Governance team (not Level 2 Support alone)

---

## Escalation (if needed)

**Escalation Statement:**
"A user has accessed content via Copilot that exceeds their documented permissions in the underlying system. This indicates a potential gap in access control enforcement within the Copilot integration, requiring immediate audit of data retrieval permissions and verification whether other users can access unauthorized content."
