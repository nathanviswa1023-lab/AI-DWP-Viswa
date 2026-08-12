Symptom     : Windows device fails Autopilot/Intune enrolment. MDM diagnostic export shows `EnrollmentState: Failed`, `ErrorCode: 0x80180014`, `ErrorDescription: The device is already enrolled in MDM`.

Cause       : A stale legacy manual MDM enrolment record (created 2023-11-04) remained active on the device and was never removed before the device was reset/repurposed for Autopilot. The new enrolment session was rejected as a duplicate, and could not obtain the policy/CSP write channel, so 0 of 4 configuration profiles applied (`LastError: 0x80070005`, Access denied).

Scope       : Impact limited to the single device attempting Autopilot enrolment. Azure AD join, Intune P1/Autopilot licensing, and network connectivity were all confirmed healthy — this is an enrolment-state issue only, not identity, licensing, or connectivity.

Workaround  : None available while the stale enrolment remains in place — the device cannot complete enrolment or receive policy until the legacy MDM record is cleared.

Permanent fix: Delete the stale Intune device record (and duplicate Azure AD device object if present); on the device, remove the orphaned enrolment (`Settings > Accounts > Access work or school > Disconnect`, or `dsregcmd /leave` + `MdmDiagnosticsTool.exe` unenroll); retrigger Autopilot enrolment; confirm 4 of 4 profiles apply. Add a mandatory MDM-cleanup step to the device retirement/reset workflow so legacy enrolments are cleared before any device re-enters the Autopilot pool.

How to spot it: Pull the MDM diagnostic export/report from the device. Look for `ErrorCode: 0x80180014` combined with `MDMEnrolled: Yes` showing a prior enrolment date, especially where `EnrolmentSource` reads "Legacy manual MDM enrolment" rather than Autopilot auto-enrolment. `ProfilesApplied: 0 of N` with `LastError: 0x80070005` (Access denied) confirms the policy channel is blocked by the existing enrolment. Cross-check in Intune admin center > Devices > All devices for a device object matching the same serial number/hardware hash with an older enrolment date, and in Windows Autopilot Devices for a possible duplicate registration.
