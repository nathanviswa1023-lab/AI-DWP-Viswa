# Triage Summary — T-1004

**Date raised:** 2026-08-04  
**Logged by:** Service Desk Analyst (AI-assisted draft — verified before use, per DWP Personal AI Usage Charter)

---

## Summary
Company app fails to install from Company Portal, returning error 0x87D1041C.

---

## Impact
| Field | Detail |
|---|---|
| Affected users | 1 reported (reporter only) — to-verify whether other Company Portal users/devices are affected |
| Business urgency | Medium — to-verify against whether the app is required for an immediate business task or deadline |
| Role / team | Unknown — to-verify |
| Device(s) affected | Unknown — to-verify single device vs. multiple |

---

## Known Facts
- The install is being attempted via Company Portal (Intune-managed app deployment).
- The install fails with error code 0x87D1041C, as reported by the user.
- No further detail on when the failure occurs (download stage, install stage, or post-install), was provided.
- No app name, device type, or OS version was provided.

---

## Missing Information to Gather
1. Exact app name and version being installed.
2. Device name, make/model, and OS version/build — do **not** paste into AI tools; use internal systems only.
3. Whether the failure happens every time or intermittently.
4. At which stage the failure occurs (download, download %, install, or finalisation) — to-verify.
5. Whether other apps install successfully from Company Portal on the same device.
6. Whether this is isolated to one device/user or affecting multiple — to-verify.
7. Recent changes to the device (OS update, reimage, enrollment change, storage cleanup) — to-verify.
8. Available free disk space on the device.
9. Network connectivity type at time of install (corporate LAN, VPN, home broadband).
10. Whether the device shows as compliant/healthy in endpoint management console (internal tooling only).
11. Full text of any additional on-screen message accompanying the error code.

## Likely Category
**Endpoint App Deployment / Intune Company Portal install failure** — probable sub-categories (all to-verify, no root cause assumed):
- Device compliance/enrollment issue — to-verify
- Insufficient disk space or storage constraint — to-verify
- Network/connectivity interruption during download or install — to-verify
- App package or deployment configuration issue — to-verify

---

## Suggested First Diagnostic Step
Ask the user to confirm the app name, device details, and exact stage at which the install fails, then check the device's compliance/enrollment status and available disk space via approved internal endpoint management tooling to see if either condition correlates with the failure before investigating further.

---

*Note: This summary was drafted using AI assistance. No DWP internal data, user PII, hostnames, or credentials were included in the AI prompt, in accordance with the DWP Personal AI Usage Charter. The error code above was provided by the reporter; no error code, meaning, registry key, or KB number was invented or assumed. All fields marked "to-verify" must be confirmed via internal tooling before action.*
