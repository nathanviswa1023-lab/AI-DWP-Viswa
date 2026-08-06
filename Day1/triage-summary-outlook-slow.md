# Triage Summary — INC-001

**Date raised:** 2026-08-04  
**Logged by:** Service Desk Analyst (AI-assisted draft — verified before use, per DWP Personal AI Usage Charter)

---

## Summary
User's new Win11 laptop is running very slowly and Outlook fails to open (spinning) since this morning; other applications appear unaffected.

---

## Impact
| Field | Detail |
|---|---|
| Affected users | 1 (reporter only — to confirm whether others on same build are affected) |
| Business urgency | Medium — user cannot access email; productivity blocked but no confirmed wider service impact |
| Role / team | Unknown — **to confirm** |
| Time of onset | This morning (2026-08-04) — exact time **to confirm** |

---

## Known Facts
- Laptop is a new Win11 machine deployed approximately one week ago.
- Symptom: system-wide slowness onset today.
- Outlook will not open — application appears to launch then hangs (spinning cursor/loading indicator).
- User reports other applications are working — **unverified by analyst**.
- No hardware change or user action cited as a trigger.

---

## Missing Information to Gather
1. Username and device asset tag / hostname (required to pull logs — do **not** paste into AI tools; use internal systems only).
2. Exact time slowness began — did it follow a reboot, Windows Update, or sign-in event?
3. Has the device had any Windows Updates, policy pushes, or Intune/SCCM deployments overnight or this morning?
4. Is Outlook Microsoft 365 (cloud) or on-premises? Is it a fresh install or migrated profile?
5. Are Teams, OneDrive, or other M365 apps also affected?
6. Has the device been rebooted since the issue started?
7. Are there any on-screen error codes or Event Viewer warnings visible to the user?
8. Is this affecting any other users on the same Win11 build batch — **to confirm with deployment team**.

---

## Likely Category
**Endpoint Performance / Application Hang** — probable sub-categories:
- Post-deployment background process overload (e.g. AV scan, Windows Update, Intune compliance check, profile sync)
- Outlook profile corruption or first-run configuration issue on new device
- Insufficient resources during first-week provisioning tasks

---

## Suggested First Diagnostic Step
Ask the user to open **Task Manager** (`Ctrl + Shift + Esc`) and report:
- CPU, Memory, and Disk % in the **Performance** tab
- The top processes by CPU/Disk in the **Processes** tab

This will confirm whether a background process (e.g. MsMpEng, TiWorker, OneDrive, or Outlook first-run) is consuming resources, and will guide whether to escalate to endpoint team or resolve at first line.

---

*Note: This summary was drafted using AI assistance. No DWP internal data, user PII, hostnames, or credentials were included in the AI prompt, in accordance with the DWP Personal AI Usage Charter. All fields marked "to confirm" must be verified via internal tooling before action.*
