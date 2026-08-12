# Runbook: Autopilot Enrolment Failure Recovery (0x80180014)

Title: Runbook-Autopilot-Enrolment-Failure-Recovery
Version: 1.0
Date: 11/08/2026
Author: DWP Engineering (Intune Compliance)
Reviewed: self
Status: draft
Change: initial version from RCA

Incident pattern covered:
- Autopilot/Intune enrolment fails with `ErrorCode: 0x80180014` ("device already enrolled in MDM").
- Diagnostic export shows an existing MDM enrolment from a prior date, with `EnrolmentSource: Legacy manual MDM enrolment`.
- 0 of N configuration profiles apply, with `LastError: 0x80070005` (Access denied).

Use this runbook for incidents matching the RCA in [Issue-Autopilot-Enrolment-Failure-RCA.md](Issue-Autopilot-Enrolment-Failure-RCA.md).

---

## 1. Prerequisites

Complete this checklist before remediation.

### A) Access Checklist
- [ ] [ELEVATED] Confirm you can open Microsoft Intune admin center.
- [ ] [ELEVATED] Confirm you can delete/modify device records in Intune (Devices > All devices).
- [ ] [ELEVATED] Confirm you can open Azure AD/Entra device records for the affected device.
- [ ] [ELEVATED] Confirm you can view and manage Windows Autopilot Devices registrations.
- [ ] [ELEVATED] Confirm local admin access on the affected device (or remote session capability).

### B) Tools Checklist
- [ ] Intune admin center access (https://intune.microsoft.com).
- [ ] Microsoft Entra admin center access (device object lookup).
- [ ] Remote support tool or physical access to the affected device.
- [ ] `MdmDiagnosticsTool.exe` (built into Windows).
- [ ] Event Viewer on the endpoint.

### C) Mandatory End-User/Requester Input Checklist
- [ ] Device name and serial number.
- [ ] Whether the device was previously enrolled/used before (approximate prior enrolment date if known).
- [ ] Time the current enrolment attempt was made.
- [ ] Exact error code/message shown (`0x80180014` or other).
- [ ] MDM diagnostic export/report from the device, if available.

### D) Incident Context Checklist
- [ ] Confirm error code is `0x80180014` and description references "already enrolled in MDM."
- [ ] Confirm `EnrolmentSource` in the export/report shows a legacy/manual enrolment, not Autopilot.
- [ ] Confirm `ProfilesApplied` count and `LastError` (typically `0x80070005`).
- [ ] Confirm Azure AD join, licensing, and network were already checked and are healthy (per scope facts).

---

## 2. Procedure

Follow steps in order. Each step has one action and an expected result.

1. Open the MDM diagnostic export/report for the affected device (or generate one via `MdmDiagnosticsTool.exe -area DeviceEnrollment;DeviceProvisioning -cab <path>`).
Expected result: `ErrorCode: 0x80180014` and `MDMEnrolled: Yes` with a prior enrolment date are confirmed.

2. Open Intune admin center path Devices -> All devices, and search by the device serial number.
Expected result: One or more device records matching the serial number/hardware hash are found.

3. Identify the device record showing the older enrolment date and legacy enrolment type.
Expected result: Stale device record is identified and distinguished from any new/expected Autopilot record.

4. [ELEVATED] Open Microsoft Entra admin center path Identity -> Devices -> All devices, and search the same device identifier.
Expected result: Confirm whether a duplicate Azure AD device object exists alongside the Intune record.

5. [ELEVATED] Delete the stale Intune device record identified in step 3.
Expected result: Device no longer appears as enrolled in Intune under the old record.

6. [ELEVATED] If a duplicate Azure AD device object was found in step 4, delete it as well.
Expected result: No duplicate device object remains in Azure AD.

7. On the physical device, open Settings -> Accounts -> Access work or school.
Expected result: Existing work/school account connection (if visible) is located.

8. Select the account entry and choose Disconnect.
Expected result: Device is disconnected from the stale MDM enrolment.

9. If Disconnect is not available or fails, open an elevated command prompt and run `dsregcmd /leave`.
Expected result: Command completes and device leaves the prior Azure AD/MDM join state.

10. Run `MdmDiagnosticsTool.exe -area DeviceEnrollment -cab C:\Temp\mdm-cleanup.cab` to confirm no active enrolment remains.
Expected result: Diagnostic output no longer shows an active MDM enrolment.

11. Restart the device.
Expected result: Device restarts cleanly with no enrolment state carried over.

12. Boot the device to OOBE (Out-of-Box Experience) — via Autopilot Reset from Settings, or by reimaging if Autopilot Reset is not available.
Expected result: Device reaches the Autopilot enrolment screen.

13. Allow the device to complete Autopilot enrolment, staying connected to a healthy network throughout.
Expected result: Enrolment proceeds without the `0x80180014` error.

14. Once enrolment completes, pull a fresh MDM diagnostic export.
Expected result: `EnrollmentState: Succeeded` and `ProfilesApplied` shows all expected profiles applied (e.g., 4 of 4).

15. If the same `0x80180014` error recurs, open Intune admin center path Devices -> Enrollment -> Devices -> Windows Autopilot Devices and search by serial number.
Expected result: Check for a duplicate Autopilot device registration or hardware-hash collision.

16. If profiles still fail to apply after successful enrolment, open Event Viewer path Applications and Services Logs -> Microsoft -> Windows -> DeviceManagement-Enterprise-Diagnostics-Provider.
Expected result: Identify the specific CSP/profile still returning `0x80070005` for further investigation.

---

## 3. Verification

Complete all checks before closure.

1. Open Intune admin center path Devices -> All devices and locate the device by serial number.
Expected result: Device shows a single, current record with enrolment status Succeeded.

2. Open the device's Device configuration / Device compliance blade in Intune.
Expected result: All assigned profiles show Succeeded (no pending/error states).

3. On the device, run `dsregcmd /status`.
Expected result: Output shows `AzureAdJoined: YES` and `MDM url` populated with the current tenant's MDM endpoint.

4. Pull a fresh MDM diagnostic export from the device.
Expected result: `EnrollmentState: Succeeded`, `ProfilesApplied` shows full count, no `0x80070005` errors present.

5. Confirm with the requester/end user that the device completed setup and is usable.
Expected result: User confirms device is functional and no further setup prompts appear.

6. Check Intune/Autopilot device list for any remaining duplicate records for this device.
Expected result: Only one active device record exists for the serial number.

7. Record closure evidence including device serial number, deleted stale record IDs, and verification timestamps.
Expected result: Closure record is complete and auditable.

---

## 4. Rollback

Use this section if the device becomes unusable or enrolment issues worsen after cleanup actions.

Goal:
- Restore device to a known state or escalate within 15 minutes if cleanup steps do not resolve enrolment.

1. [ELEVATED] If the device fails to reach OOBE after `dsregcmd /leave`/disconnect, do not repeat the leave/unenroll steps again — this risks further inconsistent state.
Expected result: Cleanup actions are paused, avoiding compounding the issue.

2. [ELEVATED] Re-image the device from a known-good deployment image if OOBE cannot be reached through Autopilot Reset.
Expected result: Device returns to a clean, unenrolled starting state.

3. [ELEVATED] Re-check Intune/Azure AD for any residual device objects tied to the serial number and remove them before retrying enrolment.
Expected result: No conflicting device records remain.

4. Retry Autopilot enrolment from OOBE.
Expected result: Enrolment proceeds normally.

5. If enrolment still fails with the same or a different error code after re-imaging, escalate to L3/Intune platform team with the full diagnostic export attached.
Expected result: Issue is handed off with full evidence for deeper platform-level investigation.

6. Document rollback/escalation start time, actions taken, and outcome.
Expected result: Rollback/escalation evidence is complete.

---

## 5. Notes

Edge cases
- Device may show a duplicate Autopilot registration if it was re-hashed/re-registered without removing the original entry — check Windows Autopilot Devices list if `0x80180014` recurs after cleanup.
- Devices offline at the time of cleanup will retain the stale enrolment until they can reach the network to process the disconnect/unenroll.
- Cached enrolment tokens can occasionally cause a brief re-appearance of the old enrolment state immediately after cleanup — a restart before OOBE resolves this in most cases.

Warnings
- Do not delete an Intune/Azure AD device record without first confirming (via serial number/hardware hash) it is the stale legacy record, not the device's only valid record.
- Do not skip the on-device disconnect/unenroll step — deleting the cloud-side record alone can leave the device in an inconsistent local state.
- Do not close the incident without confirming `ProfilesApplied` shows the full expected profile count, not just `EnrollmentState: Succeeded`.

Related incidents
- [Issue-Autopilot-Enrolment-Failure-Analysis.md](Issue-Autopilot-Enrolment-Failure-Analysis.md)
- [Issue-Autopilot-Enrolment-Failure-RCA.md](Issue-Autopilot-Enrolment-Failure-RCA.md)
- [Issue-Autopilot-Enrolment-Failure-KEDB.md](Issue-Autopilot-Enrolment-Failure-KEDB.md)
- [Issue-Autopilot-Enrolment-Failure-Closure-Note.md](Issue-Autopilot-Enrolment-Failure-Closure-Note.md)
