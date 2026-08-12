# Root Cause Analysis Report
## Autopilot Enrolment Failure — 0x80180014

Report Date: 2026-08-11
Incident Date: 2026-08-11
Incident ID: INC-AUTOPILOT-20260811-01
Severity: Medium (single-device impact, blocks device provisioning)
Status: Root cause confirmed — remediation plan finalized, execution pending

---

## Executive Summary

A device undergoing Autopilot enrolment failed with error `0x80180014` ("The device is already enrolled in MDM"). The MDM diagnostic export shows the device carries a pre-existing MDM enrolment dated 2023-11-04, registered through a legacy manual MDM enrolment path rather than through Autopilot/Intune auto-enrolment. Because this stale enrolment record was never removed before the device was reset/repurposed for Autopilot, the new enrolment attempt was rejected outright, and 0 of 4 configuration profiles were able to apply, failing separately with `0x80070005` (Access denied) — consistent with the legacy enrolment session still holding the MDM policy channel.

Azure AD join, licensing (Intune P1 and Autopilot), and network connectivity were all confirmed healthy, ruling out identity, licensing, and connectivity as contributing factors.

Root cause determined:
- An orphaned legacy manual MDM enrolment record (2023-11-04) was never decommissioned before the device was returned to the Autopilot provisioning pool, causing the new enrolment attempt to be rejected as a duplicate and blocking all policy delivery.

---

## Scope and Impact

- Affected device: single device undergoing Autopilot enrolment (device identifier not present in export)
- Affected systems: Intune MDM enrolment service, device configuration profile delivery (4 profiles)
- User/business impact: device not usable for its intended assignment until enrolment succeeds; no evidence of broader tenant-wide enrolment outage
- Wider impact: potential recurrence risk for any other device migrated from the legacy manual MDM enrolment process without proper decommissioning

---

## Supporting Evidence

### Diagnostic Export Evidence (MDM Diagnostic Report)

1. `EnrollmentState: Failed`
   - The Autopilot/Intune enrolment attempt did not complete.

2. `ErrorCode: 0x80180014`
   - Documented Microsoft MDM enrolment error meaning "the device is already enrolled in MDM." This is a specific, non-generic error code — it does not indicate a licensing, network, or credential problem.

3. `ErrorDescription: The device is already enrolled in MDM.`
   - Confirms the error code interpretation directly from the diagnostic tool.

4. `MDMEnrolled: Yes (previous enrolment from 2023-11-04)`
   - Proves an active/registered enrolment record exists on the device dated nearly three years prior to this attempt.

5. `EnrolmentSource: Legacy manual MDM enrolment`
   - Confirms the existing enrolment was created outside the standard Autopilot/auto-enrolment workflow, consistent with a device that was manually enrolled under a prior process and not properly retired.

6. `ProfilesApplied: 0 of 4`
   - No configuration profiles were delivered, indicating the policy channel was not available to the new enrolment session.

7. `LastError: 0x80070005 (Access denied)`
   - Standard Win32 access-denied error, consistent with the device's policy/CSP write channel being held by the pre-existing (legacy) enrolment rather than the new one.

8. `AzureADJoined: Yes`
   - Rules out identity/join state as a contributing cause.

9. `IntuneP1License: Yes` / `AutopilotLicense: Yes`
   - Rules out licensing as a contributing cause.

10. `Network: All endpoints reachable, no proxy`
    - Rules out connectivity/firewall/proxy interference as a contributing cause.

### Evidence Not Available
- Exact enrolment attempt timestamp, device serial number/hardware hash, and Intune/Azure AD device object IDs were not present in the supplied export. These should be pulled from the live tenant (Intune admin center device list, `dsregcmd /status`, MDM diagnostic `.cab`) to complete remediation and close this RCA with a confirmed device record match.

---

## Incident Timeline

| Time / Date | Event | Evidence | Meaning |
|---|---|---|---|
| 2023-11-04 | Legacy manual MDM enrolment created | `MDMEnrolled: Yes (previous enrolment from 2023-11-04)`, `EnrolmentSource: Legacy manual MDM enrolment` | Device enrolled outside Autopilot workflow; this record was never subsequently removed |
| Prior to 2026-08-11 (exact date unknown) | Device prepared/reset for Autopilot deployment | Inferred from scope — device presented for Autopilot enrolment | Legacy enrolment record not decommissioned during reset/repurposing |
| 2026-08-11 | Autopilot/Intune enrolment attempt initiated | `EnrollmentState: Failed` | New enrolment session started against a device that was already MDM-enrolled |
| 2026-08-11 | Enrolment rejected | `ErrorCode: 0x80180014`, `ErrorDescription` | MDM service rejected the new enrolment because an active enrolment already exists |
| 2026-08-11 | Configuration profile delivery attempted | `ProfilesApplied: 0 of 4` | No profiles could be pushed under the failed enrolment |
| 2026-08-11 | Profile delivery fails | `LastError: 0x80070005 (Access denied)` | Policy channel unavailable to the new session, consistent with legacy enrolment holding it |
| 2026-08-11 | Supporting checks confirmed healthy | `AzureADJoined: Yes`, `IntuneP1License/AutopilotLicense: Yes`, `Network: healthy` | Identity, licensing, and connectivity eliminated as causes |
| 2026-08-11 | Scope facts extracted and analysis performed | Prior triage/analysis session | Root cause hypothesis formed and ranked |
| 2026-08-11 | Root cause confirmed, remediation plan finalized | This RCA | Ready for remediation execution |

---

## Root Cause Statement

The Autopilot enrolment failure was caused by a stale, undecommissioned legacy manual MDM enrolment record (dated 2023-11-04) remaining active on the device. When the device was later presented for Autopilot enrolment, the MDM service rejected the new enrolment attempt (`0x80180014`, "already enrolled in MDM") because it detected the pre-existing enrolment. As a direct consequence, the new enrolment session could not obtain the policy/CSP write channel, causing all 4 configuration profiles to fail with `0x80070005` (Access denied). Identity (Azure AD join), licensing, and network connectivity were all confirmed healthy and are not contributing factors.

---

## 5 Whys Analysis

**Why 1: Why did Autopilot enrolment fail?**
- Because the MDM service returned `0x80180014`, indicating the device was already enrolled in MDM.
- Evidence: `EnrollmentState: Failed`, `ErrorCode: 0x80180014`, `ErrorDescription: The device is already enrolled in MDM.`

**Why 2: Why was the device already enrolled in MDM?**
- Because a legacy manual MDM enrolment created on 2023-11-04 was still active on the device.
- Evidence: `MDMEnrolled: Yes (previous enrolment from 2023-11-04)`, `EnrolmentSource: Legacy manual MDM enrolment`.

**Why 3: Why was the legacy enrolment still active at the time of the new Autopilot attempt?**
- Because the device was not properly unenrolled/decommissioned from its prior legacy enrolment before being reset and re-presented for Autopilot provisioning.
- Evidence: enrolment source explicitly flagged as legacy/manual rather than Autopilot, with no corresponding removal recorded prior to the 2026-08-11 attempt.

**Why 4: Why did the profile application also fail (0 of 4, access denied)?**
- Because the still-active legacy enrolment session retained ownership of the device's MDM policy/CSP channel, denying the new enrolment session write access.
- Evidence: `ProfilesApplied: 0 of 4`, `LastError: 0x80070005 (Access denied)`.

**Why 5: Why is there no process step that catches/clears legacy enrolments before Autopilot re-provisioning?**
- Because device retirement/reset procedures for devices migrating from the legacy manual MDM process do not include a mandatory MDM unenrollment/device-object cleanup check prior to Autopilot handoff.
- Evidence: absence of any decommissioning record between the 2023-11-04 legacy enrolment and the 2026-08-11 Autopilot attempt; this is a process gap rather than a one-off technical fault.

**Systemic cause:**
- The device provisioning/reset workflow lacks a mandatory step to verify and clear prior MDM enrolment state before a device is handed off to Autopilot, allowing stale legacy enrolments to silently block future enrolments.

---

## Resolution / Remediation Actions (Finalized Plan)

1. Locate the stale device object in Intune/Azure AD tied to the 2023-11-04 legacy enrolment (match by serial number/hardware hash).
2. Delete the stale Intune device record and, if a duplicate exists, the Azure AD device object.
3. On the physical device, remove the orphaned enrolment: `Settings > Accounts > Access work or school > Disconnect`, or `dsregcmd /leave` followed by MDM unenroll via `MdmDiagnosticsTool.exe`.
4. Retrigger Autopilot enrolment (Autopilot Reset, or re-image and boot to OOBE).
5. Confirm successful enrolment and that all 4 profiles apply (`dsregcmd /status`; Intune admin center shows device configuration Succeeded).
6. If profile application still fails after re-enrolment, pull the MDM diagnostic `.cab` / Event Viewer (`DeviceManagement-Enterprise-Diagnostics-Provider`) to isolate the specific CSP still returning access denied.
7. If `0x80180014` recurs after step 3, check for a duplicate Autopilot device registration or hardware-hash collision in the Windows Autopilot Devices list.

---

## Preventive Actions

### Immediate (0-7 days)

1. **Pre-Autopilot enrolment cleanup check**
   - Before handing any previously-enrolled device to Autopilot, require a check for existing MDM enrolment (`dsregcmd /status`) and clear it if present.
   - Owner: Device Provisioning Team
   - Success metric: 100% of re-provisioned devices verified clear of prior MDM enrolment before Autopilot handoff.

2. **Stale enrolment search across legacy device population**
   - Query Intune/Azure AD for devices still showing "legacy manual enrolment" as the enrolment source and cross-check against devices scheduled for Autopilot redeployment.
   - Owner: Intune Compliance Team
   - Success metric: full inventory of at-risk devices produced within 7 days.

### Near Term (7-30 days)

3. **Automate legacy enrolment decommissioning**
   - Build a scripted/automated step in the device retirement workflow that unenrolls MDM and removes the device object before the device re-enters the Autopilot pool.
   - Owner: Platform Engineering
   - Success metric: zero manual steps required; automated cleanup runs on every device retirement.

4. **KEDB entry for this failure signature**
   - Document `0x80180014` + legacy enrolment source + `0x80070005` profile failure as a known error, with the confirmed remediation steps, for first-line triage reuse.
   - Owner: Service Desk Knowledge Management
   - Success metric: KEDB article published and linked from the Autopilot enrolment failure triage runbook.

### Long Term (30-90 days)

5. **Retire the legacy manual MDM enrolment path**
   - Where feasible, migrate any remaining legacy-enrolled devices to standard Autopilot/auto-enrolment and disable/limit further use of the legacy manual enrolment method to prevent recurrence at the source.
   - Owner: Intune Compliance Team / Security team sign-off
   - Success metric: no active devices remaining on legacy manual MDM enrolment; policy documented in the compliance baseline.

6. **Provisioning workflow audit**
   - Periodic audit (quarterly) of device reset/retirement procedures to confirm the MDM-cleanup step is consistently followed across all device lifecycle teams.
   - Owner: DWP Engineering (Intune Compliance)
   - Success metric: quarterly audit shows 0 stale-enrolment-caused Autopilot failures.

---

## Notes
- This RCA is based on the MDM diagnostic export supplied during triage; live tenant data (device serial number, Intune device object IDs, exact attempt timestamp) should be attached once pulled, to fully close out the incident record.
- Related document: [Issue-Autopilot-Enrolment-Failure-Analysis.md](Issue-Autopilot-Enrolment-Failure-Analysis.md) for the scope facts extraction and ranked-cause analysis that preceded this RCA.
