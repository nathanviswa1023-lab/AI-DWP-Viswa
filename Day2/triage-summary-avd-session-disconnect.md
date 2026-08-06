# Triage Summary — T-1003

**Date raised:** 2026-08-04  
**Logged by:** Service Desk Analyst (AI-assisted draft — verified before use, per DWP Personal AI Usage Charter)

---

## Summary
AVD (Azure Virtual Desktop) session disconnects after approximately 10 minutes, then automatically reconnects.

---

## Impact
| Field | Detail |
|---|---|
| Affected users | 1 reported (reporter only) — to-verify whether other AVD users are affected |
| Business urgency | Medium-High — repeated disconnects interrupt active work and may cause unsaved data loss; to-verify against business criticality of user's role |
| Role / team | Unknown — to-verify |
| Time of onset | Not stated — to-verify (e.g. always occurred, or started recently after a change) |

---

## Known Facts
- User is connecting to an Azure Virtual Desktop (AVD) session.
- The session disconnects at roughly the ~10 minute mark.
- The session then reconnects automatically (not requiring a full manual re-login) — to-verify exact reconnect behaviour (auto vs. manual).
- No error code, disconnect reason code, or specific message text was provided — do not assume one.

---

## Missing Information to Gather
1. Username and host pool / session host name (required to pull logs — do **not** paste into AI tools; use internal systems only).
2. Exact disconnect message or reason code shown to the user, if any — to-verify.
3. Client device type and AVD client used (Windows Desktop client, web client, mobile, etc.).
4. Network connection type (corporate LAN, home broadband, VPN, mobile hotspot) and stability of that connection.
5. Is the ~10 minute pattern consistent every time, or does it vary?
6. Does disconnection correlate with idle/inactivity, or does it happen during active use?
7. Any recent changes to Conditional Access, session timeout policies, or host pool configuration — to-verify.
8. Is this affecting a single session host or multiple, and is it isolated to one user or wider — to-verify.
9. Time of day and frequency of occurrence (constant vs. intermittent).
10. Any local network equipment (firewall, proxy, Wi-Fi) that could be dropping idle connections.

## Likely Category
**Azure Virtual Desktop (AVD) / Remote Session Connectivity** — probable sub-categories:
- Session/Conditional Access timeout policy causing periodic disconnects — to-verify
- Network-level idle timeout (client-side firewall, proxy, or Wi-Fi) dropping the connection — to-verify
- Host pool or session host performance/health issue — to-verify

---

## Suggested First Diagnostic Step
Ask the user to confirm the exact behaviour (does the screen freeze, show a disconnect message, or go to a black screen before reconnecting?) and note the network type in use, then check the AVD session host and Conditional Access/session policy settings via approved internal tooling to see if a timeout policy or host health issue aligns with the ~10 minute pattern.

---

*Note: This summary was drafted using AI assistance. No DWP internal data, user PII, hostnames, or credentials were included in the AI prompt, in accordance with the DWP Personal AI Usage Charter. All fields marked "to-verify" must be confirmed via internal tooling before action.*
