# Triage Summary — T-1008

**Date raised:** 2026-08-05  
**Logged by:** Service Desk Analyst (AI-assisted draft — verified before use, per DWP Personal AI Usage Charter)

---

## Summary
VPN connects successfully but user cannot reach any internal resources following a Windows 11 upgrade.

---

## Impact
| Field | Detail |
|---|---|
| Affected users | 1 (reporting user) — to-verify whether other recently upgraded users are affected |
| Business urgency | High — no access to internal resources likely blocks remote work entirely — to-verify actual business impact/priority |
| Role / team | Unknown — to-verify |
| Time of onset | Began after Windows 11 upgrade — to-verify exact date/time of upgrade and first failed connection |

---

## Known Facts
- VPN client reports/shows a successful connection (tunnel establishes).
- Once connected, no internal resources (e.g., file shares, intranet sites, internal apps) are reachable.
- Issue began following a Windows 11 upgrade on the device.
- No error codes, error messages, or specific symptoms have been provided — do not assume.
- No information given on VPN client/version, connection type (full tunnel vs split tunnel), or which specific resources were tested.

---

## Missing Information to Gather
1. Exact VPN client name and version in use, and whether it was reinstalled/updated as part of the Windows 11 upgrade — to-verify.
2. Which specific internal resources were tested (e.g., file shares by UNC path/name, intranet URLs, internal apps) and how they fail (timeout, "cannot reach," DNS error, access denied) — to-verify.
3. Whether the user can resolve internal hostnames (DNS) while connected, or only IP-based access was tried — to-verify.
4. Whether this is full-tunnel or split-tunnel VPN, and if routing/split-tunnel config appears intact — to-verify.
5. Results of `ipconfig` while connected — assigned VPN IP, DNS servers, and default gateway — to-verify.
6. Whether Windows Firewall or third-party security software settings changed/reset during the Windows 11 upgrade — to-verify.
7. Whether other users who upgraded to Windows 11 report the same symptom (isolated device vs wider pattern) — to-verify.
8. Whether the device was a clean install or in-place upgrade — to-verify.
9. Any recent network adapter driver changes/updates as part of the upgrade — to-verify.
10. Whether reverting to a known-good network profile or reconnecting the VPN session changes behavior — to-verify.

## Likely Category
**Network / VPN Connectivity — Post-OS Upgrade** — probable sub-categories:
- DNS resolution failure for internal resources over VPN (client/adapter DNS settings reset by upgrade) — to-verify
- Split-tunnel/routing configuration reset or altered by the Windows 11 upgrade — to-verify
- Windows Firewall or security software rule reset blocking internal traffic post-upgrade — to-verify
- VPN client incompatibility or corrupted install introduced during the upgrade — to-verify

---

## Suggested First Diagnostic Step
With the VPN connected, run `ipconfig /all` on the affected device to confirm whether a VPN adapter IP address and internal DNS server(s) have been assigned, then attempt to resolve an internal hostname and ping an internal IP address directly; this will help determine whether the issue is DNS resolution, routing, or a firewall/security block, and confirms whether the fault is upgrade-related or configuration-related.

---

*Note: This summary was drafted using AI assistance. No DWP internal data, user PII, hostnames, or credentials were included in the AI prompt, in accordance with the DWP Personal AI Usage Charter. All fields marked "to-verify" must be confirmed via internal tooling before action.*
