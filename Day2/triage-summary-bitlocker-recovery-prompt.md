# Triage Summary — T-1001

**Date raised:** 2026-08-04  
**Logged by:** Service Desk Analyst (AI-assisted draft — verified before use, per DWP Personal AI Usage Charter)

---

## Summary
New Win11 laptop prompts for the BitLocker recovery key on every boot instead of unlocking automatically.

---

## Impact
| Field | Detail |
|---|---|
| Affected users | 1 (reporter only — to-verify whether this is isolated or affects other new-build devices) |
| Business urgency | High — user cannot access the device without the recovery key each boot; risk of lockout if key is unavailable |
| Role / team | Unknown — to-verify |
| Time of onset | Not stated — to-verify (e.g. from first boot, or after an update/reboot) |

---

## Known Facts
- Device is a new Windows 11 laptop.
- BitLocker is prompting for the recovery key on every boot (repeating, not a one-off).
- No error code, TPM message, or specific prompt text was provided — do not assume one.

---

## Missing Information to Gather
1. Username and device asset tag / hostname (required to pull logs — do **not** paste into AI tools; use internal systems only).
2. Exact wording of the recovery prompt/screen shown on boot — to-verify.
3. Was the recovery key successfully entered, and did the device boot normally afterwards each time?
4. Is this the very first boot after provisioning, or has the device worked normally before and only recently started prompting?
5. Any recent BIOS/UEFI firmware updates, TPM changes, boot order changes, or Windows Updates applied?
6. Is Secure Boot enabled, and has any BIOS setting been changed (e.g. by the user or a deployment tool)?
7. Is the device Autopilot/Intune managed, and is it checking in / compliant?
8. Was the device docked/undocked, or any external boot media used, around the time this started?
9. Is the recovery key currently escrowed in Azure AD/Intune/AD, and is it retrievable — to-verify.

## Likely Category
**Endpoint Security / Device Encryption (BitLocker)** — probable sub-categories:
- TPM/PCR measurement change (firmware, boot order, or Secure Boot setting) causing repeated recovery prompts
- Provisioning/Autopilot BitLocker policy not yet fully applied on a new build
- Hardware or firmware issue affecting TPM state — to-verify

---

## Suggested First Diagnostic Step
Confirm with the user whether the recovery key successfully unlocks the device and it boots to the desktop normally afterwards, then check the device's BitLocker/TPM status via approved internal tooling (not by requesting the recovery key itself, which must never be shared in chat, email, or pasted into AI tools). This will confirm whether the device is otherwise healthy and guide whether to escalate to the endpoint/security team for TPM or firmware investigation.

---

*Note: This summary was drafted using AI assistance. No DWP internal data, user PII, hostnames, recovery keys, or credentials were included in the AI prompt, in accordance with the DWP Personal AI Usage Charter. All fields marked "to-verify" must be confirmed via internal tooling before action.*
