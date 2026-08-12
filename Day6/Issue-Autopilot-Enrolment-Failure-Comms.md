# Autopilot Enrolment Failure Incident: Audience Communications

## Audience 1 - Non-technical executive
A device being set up through our automated deployment process (Autopilot) failed to complete setup because it was carrying an old device-management registration from 2023 that was never cleared before it was reused. No user data was at risk and no other devices or services were affected. The old registration is being removed and the device will be re-enrolled; we are also adding a check to our device reset process so this cannot recur for other devices.

## Audience 2 - Affected end-user team (non-technical)
Your new device could not finish its automated setup (Autopilot) because it still had an old management record on it from a previous setup back in 2023 that was never fully removed. This is not something you did, and no data on your account is at risk. IT will clear the old record and re-run the setup — please allow some time for this and avoid trying to sign in again until you're told the device is ready. If you see the same "already enrolled" message on any other device, contact the Service Desk with the device name/serial number.

## Audience 3 - Engineer-to-engineer internal note
Incident: INC-AUTOPILOT-20260811-01, Autopilot enrolment failure, 2026-08-11.

Root cause:
- Device carried an active legacy manual MDM enrolment dated 2023-11-04 (`EnrolmentSource: Legacy manual MDM enrolment`) that was never decommissioned before being reset for Autopilot.
- New enrolment attempt rejected with `ErrorCode: 0x80180014` ("device already enrolled in MDM").
- Configuration profile delivery failed as a direct downstream effect: `ProfilesApplied: 0 of 4`, `LastError: 0x80070005` (Access denied), consistent with the legacy enrolment session still holding the policy/CSP channel.
- Azure AD join, Intune P1/Autopilot licensing, and network connectivity all confirmed healthy — ruled out as contributing factors.

Exact action taken / to take:
- Located stale device object in Intune/Azure AD via serial number/hardware hash match.
- Delete stale Intune device record (and duplicate Azure AD object if present).
- On-device cleanup: `Settings > Accounts > Access work or school > Disconnect`, or `dsregcmd /leave` + `MdmDiagnosticsTool.exe` unenroll.
- Retrigger Autopilot enrolment (Autopilot Reset / re-image to OOBE).
- Confirm enrolment succeeds and 4 of 4 profiles apply.

Config and evidence details:
- `EnrollmentState: Failed`, `ErrorCode: 0x80180014`, `ErrorDescription: The device is already enrolled in MDM.`
- `MDMEnrolled: Yes (previous enrolment from 2023-11-04)`, `EnrolmentSource: Legacy manual MDM enrolment`.
- `ProfilesApplied: 0 of 4`, `LastError: 0x80070005 (Access denied)`.
- `AzureADJoined: Yes`, `IntuneP1License: Yes`, `AutopilotLicense: Yes`, `Network: All endpoints reachable, no proxy`.

Verification:
- Post-remediation, confirm `EnrollmentState: Succeeded`, `ProfilesApplied: 4 of 4`, no `0x80070005` in the follow-up diagnostic export.

Preventive action required:
- Mandatory MDM-cleanup/decommission check on any previously-enrolled device before Autopilot handoff.
- Inventory sweep for other devices still flagged with "legacy manual enrolment" as source.
- Automate the enrolment-cleanup step in the device retirement workflow.
- Publish KEDB entry for `0x80180014` + legacy enrolment source + `0x80070005` profile failure signature.
- Long term: retire the legacy manual MDM enrolment path once all devices are migrated.
