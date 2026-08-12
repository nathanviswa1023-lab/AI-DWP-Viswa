# Autopilot Enrolment Failure — Analysis

Date: 2026-08-11
Analyst: DWP Engineering (Intune Compliance)
Status: Analysis complete — resolution finalized, pending remediation execution

## Scope Facts
- Enrolment: **Failed** — error code `0x80180014` ("The device is already enrolled in MDM")
- Azure AD joined: **Yes**
- Existing MDM enrolment: **Yes** — prior enrolment dated 2023-11-04, via legacy manual MDM enrolment
- Policy application: **Failed** — 0 of 4 profiles applied; last error `0x80070005` (Access denied)
- Licensing: **Correct** — Intune P1 license present; Autopilot license present
- Network connectivity: **Healthy** — all endpoints reachable, no proxy

## Ranked Most Likely Causes (Most Probable First)

### 1) Stale/orphaned legacy MDM enrolment blocking re-enrolment
Why this fits the evidence:
- Error `0x80180014` maps directly to "device already enrolled in MDM."
- Export confirms a pre-existing enrolment from 2023-11-04 via a *legacy manual* MDM enrolment path, not Autopilot's normal auto-enrolment — the old enrolment record was never cleaned up before the device was reset/repurposed for Autopilot.

Fastest check:
- Run `dsregcmd /status` on the device and check the `MDM Url`/enrollment GUID, or check **Intune admin center > Devices > All devices** for a duplicate/stale object with the same hardware hash or serial number, especially one showing "Legacy" enrolment type dated 2023-11-04.

Remediation if confirmed:
- Delete the stale device record from Intune (and Azure AD if a duplicate object exists).
- Remove the orphaned enrolment locally (`Settings > Accounts > Access work or school > Disconnect`, or `dsregcmd /leave` + MDM unenroll via `MdmDiagnosticsTool.exe`).
- Retrigger Autopilot enrolment.

### 2) Access-denied on profile delivery caused by the same conflicting enrolment
Why this fits the evidence:
- 0 of 4 profiles applied with `0x80070005` (Access denied) is consistent with the MDM channel being locked by the older enrolment — the new Autopilot enrolment session cannot take ownership of policy/CSP write access while the legacy session still holds it.
- This is a downstream symptom of cause #1 rather than an independent root cause, but ranked separately in case profile delivery still fails after the base enrolment conflict is resolved.

Fastest check:
- Review the MDM Diagnostic report (`MdmDiagnosticsTool.exe -area DeviceEnrollment;DeviceProvisioning -cab`) or Event Viewer under **Applications and Services Logs > Microsoft > Windows > DeviceManagement-Enterprise-Diagnostics-Provider** for the specific CSP/profile that returned access denied.

Remediation if confirmed:
- After clearing the stale enrolment (per #1), force a policy sync (`Settings > Accounts > Access work or school > Info > Sync`) and confirm profiles reapply cleanly.
- If access-denied persists on a specific CSP, check for a local GPO or certificate permission conflict blocking that CSP.

### 3) Duplicate device object / hardware hash mismatch in Autopilot registration
Why this fits the evidence:
- Devices previously enrolled outside of Autopilot (legacy manual enrolment) are sometimes re-imaged and re-registered for Autopilot without deleting the original Azure AD/Intune device object, causing a hardware-hash or serial-number collision that can also surface as an "already enrolled" error even after the obvious MDM record is cleared.

Fastest check:
- In **Intune admin center > Devices > Enrollment > Devices > Windows Autopilot Devices**, search by serial number for duplicate entries, and cross-check against the Azure AD **Devices** blade for more than one object tied to the same hardware ID.

Remediation if confirmed:
- Delete the duplicate Autopilot device registration (or the duplicate Azure AD device object).
- Re-sync the Autopilot device list from the OEM/partner source and re-run enrolment.

## Root Cause / Resolution Finalized
Cause **#1 — stale legacy MDM enrolment from 2023-11-04** is confirmed as the root cause. The evidence is a direct match rather than circumstantial:
- The error code (`0x80180014`) is the exact code Microsoft documents for "device already enrolled," not a generic enrolment failure.
- The export explicitly identifies the conflicting enrolment's source (legacy manual) and date, ruling out coincidence.
- Cause #2 (access-denied on profile push) is explained as a direct downstream effect of #1, not a competing root cause.
- Licensing and network were already ruled out as scope facts (both healthy/correct), narrowing the field to enrolment-state issues.
- Cause #3 (duplicate Autopilot/hardware-hash object) remains possible but unconfirmed, and is retained only as a fallback check if remediation of #1 does not resolve the failure.

## Remediation Plan (Finalized)
1. Locate the stale device object in Intune/Azure AD tied to the 2023-11-04 legacy enrolment (match by serial number/hardware hash).
2. Delete the stale Intune device record and, if a duplicate exists, the Azure AD device object.
3. On the physical device, remove the orphaned enrolment: `Settings > Accounts > Access work or school > Disconnect`, or `dsregcmd /leave` followed by MDM unenroll via `MdmDiagnosticsTool.exe`.
4. Retrigger Autopilot enrolment (reset device via **Settings > Accounts > Access work or school > Autopilot Reset**, or re-image and boot to OOBE).
5. Confirm successful enrolment and that all 4 profiles apply (`dsregcmd /status`, and **Intune admin center > Devices > [device] > Device configuration** shows Succeeded).
6. If profile application still fails after re-enrolment, escalate to cause #2 check (MDM diagnostic report / Event Viewer for the specific CSP access-denied).
7. If enrolment still fails with `0x80180014` after step 3, escalate to cause #3 (check for duplicate Autopilot/hardware-hash registration).

## Verification
- Enrolment state should report **Succeeded**.
- Profile count should read **4 of 4 applied**.
- No `0x80070005` errors in the post-remediation MDM diagnostic report.

## Notes
- This root-cause determination is based on the diagnostic export provided; no live device access was used for this analysis.
- Recommend documenting a KEDB entry for "stale legacy MDM enrolment blocking Autopilot" given this is likely to recur for other devices migrated from the legacy manual enrolment process.
