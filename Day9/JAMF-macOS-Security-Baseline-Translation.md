# JAMF Pro macOS Security Baseline Translation

Version: v1.1 - expanded to match Day6 baseline translation depth
Date: 2026-08-13
Status: Draft - pending JAMF tenant verification for UI-labelled items
Author: DWP Engineering (Apple Device Management)
Scope: 25-device Design team macOS fleet

## Purpose
Translate the 6 approved macOS security baseline requirements into concrete JAMF Pro configuration profile settings, with expected enforcement effect, common false-positive triggers, and deployment recommendations suitable for a small managed creative-device fleet.

## Knowledge-currency disclaimer
JAMF Pro UI labels, payload names, and placement change over time, especially where classic configuration profile payloads, newer Settings Catalog equivalents, managed software update workflows, and declarative device management controls overlap. Any row marked **UI-VERIFY** should be checked in your own JAMF Pro instance before implementation rather than trusting the exact label in this document.

Base navigation pattern in most tenants:
`Computers > Configuration Profiles > New`

Where the tenant exposes both a classic payload and a newer Settings Catalog equivalent, use the method your platform team already standardises on. Do not mix control types unnecessarily within the same baseline unless there is a clear reporting reason.

---

## Requirement 1 - FileVault disk encryption must be enabled

| Field | Detail |
|---|---|
| Settings name | **FileVault** settings under a macOS security profile, typically within **Security & Privacy** `UI-VERIFY` |
| Payload type | **Security & Privacy** > **FileVault** `UI-VERIFY` |
| UI path | Computers > Configuration Profiles > [Profile] > Security & Privacy > FileVault `UI-VERIFY` |
| Value | Enable FileVault; escrow personal recovery key to JAMF Pro; enforce enablement for logged-in users at next suitable login/logout event |
| Effect | Forces full-disk encryption so data at rest is protected if a Mac is lost, stolen, or decommissioned incorrectly. Escrowing the recovery key preserves supported break-glass recovery for the service desk. |
| False-positive risk | New enrollments can report before encryption completes; users may defer the FileVault enablement prompt; devices already encrypted outside JAMF can take time to reconcile in inventory; Apple silicon devices still completing Setup Assistant or Secure Token handoff can appear temporarily unhealthy; local admin token issues can block escrow even though encryption itself starts. |
| Recommendation | Pilot first with assigned-user devices, not shared Macs. Verify both encryption state and recovery-key escrow during pilot rather than treating those as the same control. For small fleets, delayed user action is the most common cause of apparent failure. |

---

## Requirement 2 - Gatekeeper must be enabled (identified developers only)

| Field | Detail |
|---|---|
| Settings name | Gatekeeper / app launch policy, typically expressed as allowing **Mac App Store and identified developers** `UI-VERIFY` |
| Payload type | **Security & Privacy** > **General** `UI-VERIFY` |
| UI path | Computers > Configuration Profiles > [Profile] > Security & Privacy > General `UI-VERIFY` |
| Value | Set application control to **Mac App Store and identified developers** |
| Effect | Prevents unsigned or unnotarised applications from launching by default while still permitting the normal macOS trust model for signed software from identified developers. |
| False-positive risk | Design and engineering tools are often side-loaded during testing and may be signed incorrectly, not notarised, or repackaged by internal packaging processes; a user may previously have approved an app manually, causing a healthy local state while inventory still appears stale; third-party deployment failures are often misread as Gatekeeper blocks when the real issue is code signing or notarisation. |
| Recommendation | Validate every niche creative tool, plug-in host, and codec utility used by the Design team before broad rollout. Gatekeeper controls usually fail at the edges of the software catalogue, not on mainstream apps like Adobe Creative Cloud itself. |

---

## Requirement 3 - Minimum macOS version: current stable minus one point release

| Field | Detail |
|---|---|
| Settings name | No single universally named JAMF config-profile field cleanly maps to **minimum macOS version** across all current JAMF variants. This is usually achieved through a combination of software update enforcement and reporting logic rather than one literal compliance field. |
| Payload type | **Software Update** or newer managed software update / declarative update controls `UI-VERIFY` |
| UI path | Computers > Configuration Profiles > [Profile] > Software Update `UI-VERIFY`, or equivalent managed software update workflow in your tenant |
| Value | Configure update enforcement so devices are held within one supported point release of the current stable macOS release. Review the approved target each time Apple ships a new stable release or point release. |
| Effect | Keeps the Design fleet inside the approved support window instead of allowing Macs to remain several releases behind on security and platform fixes. |
| False-positive risk | This is the most likely control to be overstated if written too simply: JAMF generally controls update behaviour, deferrals, deadlines, and enforcement timing rather than behaving like Intune compliance with a literal minimum-version gate. Healthy devices may appear overdue if they are within an approved deferral window, pending restart after a completed update, offline during the enforcement window, or temporarily paused because a critical design application has not yet been certified on the new release. |
| ⚠️ Coverage gap | If audit wording requires a hard statement such as "device must be at least macOS X.Y.Z," JAMF profile settings alone may be insufficient as evidence. Pair update enforcement with a smart group, extension attribute, or inventory report that evaluates the actual installed macOS version. |
| Recommendation | Treat this as a two-part control: enforce updates operationally, and report version compliance separately. For a 25-device Design fleet, the safest pattern is to approve a target version after app-compatibility review, allow a short validation ring, then move the rest of the group to the same target. |

---

## Requirement 4 - Firewall must be enabled

| Field | Detail |
|---|---|
| Settings name | **Firewall** within a macOS security profile `UI-VERIFY` |
| Payload type | **Security & Privacy** > **Firewall** `UI-VERIFY` |
| UI path | Computers > Configuration Profiles > [Profile] > Security & Privacy > Firewall `UI-VERIFY` |
| Value | Enable firewall |
| Effect | Turns on the built-in macOS application firewall to reduce unsolicited inbound connections to services running on the Mac. |
| False-positive risk | Inventory lag after profile deployment; device locally healthy but not yet checked in; technicians can misread blocked inbound prompts for remote-support or collaboration tools as a broken state; some teams confuse the macOS application firewall with network content filters, EDR, or edge firewalling and assume the wrong signal is being measured. |
| Recommendation | Validate any required inbound workflows separately, especially specialist design tools that advertise local services or rely on peer discovery. The baseline requirement is that the built-in firewall remains on, not that every inbound app is blocked with no exceptions. |

---

## Requirement 5 - Login password required after sleep or screen saver

| Field | Detail |
|---|---|
| Settings name | Password required after sleep or screen saver, often surfaced under macOS security or login controls `UI-VERIFY` |
| Payload type | **Security & Privacy** > **General** or an equivalent login/security restriction `UI-VERIFY` |
| UI path | Computers > Configuration Profiles > [Profile] > Security & Privacy > General, or equivalent settings-catalog location `UI-VERIFY` |
| Value | Require password immediately after sleep or screen saver begins |
| Effect | Forces the signed-in user to re-authenticate when the Mac wakes or the screen saver ends, reducing walk-up access risk in studios, shared offices, and hot-desk spaces. |
| False-positive risk | Local user settings may not reflect instantly until the session refreshes; shared creative workstations using fast user switching can look inconsistent during profile application; administrators sometimes test only one scenario, such as manual screen lock, and miss that sleep and screen saver behaviour may evaluate slightly differently from a user perspective. |
| Recommendation | Verify the lock behaviour on both Intel and Apple silicon pilot devices and on any Macs that use external displays or docking workflows, since user reports often focus on wake behaviour rather than the underlying policy state. |

---

## Requirement 6 - Automatic security updates enabled

| Field | Detail |
|---|---|
| Settings name | Automatic update settings for Apple security updates `UI-VERIFY` |
| Payload type | **Software Update** `UI-VERIFY` |
| UI path | Computers > Configuration Profiles > [Profile] > Software Update, or equivalent software update enforcement workflow `UI-VERIFY` |
| Value | Enable automatic checking, downloading, and installation of security updates; where the tenant distinguishes operating system updates from application updates, ensure the security-relevant operating system update behaviour is explicitly enabled |
| Effect | Reduces exposure time after Apple releases security fixes by allowing managed Macs to obtain and install updates with minimal user intervention. |
| False-positive risk | Devices that are asleep, off network, VPN-isolated, or low on disk space can miss install windows; updates may be downloaded but still waiting for a restart; deferral settings aimed at creative-app compatibility testing can make a healthy device look overdue; Apple release metadata occasionally causes short-lived reporting inconsistency immediately after new updates are published. |
| Recommendation | Separate the policy decision for "security updates should be automatic" from the operational decision for "how quickly major or point releases are forced." Design fleets often tolerate automatic security patching well, but may need more controlled timing for full OS jumps. |

---

## Reporting and enforcement model - JAMF-specific caveat
Unlike Intune device compliance policies, JAMF Pro does not always express these controls as one central compliance policy with a built-in noncompliance action timeline. Configuration profiles enforce settings, but evidence and exception handling are often split across:

1. Configuration Profiles for the control itself
2. Smart Groups for scoping and identifying drift
3. Inventory data or Extension Attributes for reporting on actual state
4. Separate operational workflows for remediation, notification, or escalation

This matters most for Requirement 3 and Requirement 6. A configuration profile can strongly influence update behaviour, but version-based audit reporting usually still needs a reporting object in JAMF rather than just a payload screenshot.

## Suggested deployment pattern for the 25-device Design fleet

| Area | Recommendation |
|---|---|
| Scope | Assign only to the Design device group, not the wider macOS estate |
| Pilot size | 3 to 5 Macs representing different hardware generations and creative software stacks |
| Validation window | At least one patch cycle before broad deployment |
| Reporting | Pair the profile with a smart group for FileVault state and macOS version tracking |
| Exceptions | Track temporary app-compatibility holds explicitly rather than leaving devices silently behind baseline |

## Common false-positive themes across this baseline

| Theme | Why it matters |
|---|---|
| Inventory lag | JAMF can show stale state if a Mac has not checked in after a change |
| User deferral | FileVault enablement and update restarts often depend on user timing |
| Software compatibility holds | Design fleets legitimately delay some OS movement while validating creative tools |
| Mixed UI models | Classic payload labels and newer settings/declarative labels may not match documentation exactly |
| Local state vs reported state | A Mac can be healthy locally while inventory or smart-group membership still reflects the previous check-in |

## Summary table

| # | Requirement | Payload type | Value | Key caveat |
|---|---|---|---|---|
| 1 | FileVault enabled | Security & Privacy > FileVault | Enable FileVault and escrow recovery key | Verify encryption and escrow separately |
| 2 | Gatekeeper enabled | Security & Privacy > General | Mac App Store and identified developers | Validate niche creative tools and plug-ins |
| 3 | Minimum macOS version N-1 | Software Update / managed update controls | Keep devices within one supported point release | Needs reporting logic as well as update enforcement |
| 4 | Firewall enabled | Security & Privacy > Firewall | Enable firewall | Test legitimate inbound exceptions separately |
| 5 | Password after sleep or screen saver | Security & Privacy > General or equivalent | Require password immediately | Exact field naming may vary |
| 6 | Automatic security updates | Software Update | Enable automatic security updates | Separate security patching from major OS timing decisions |

## Recommended next steps
1. Verify each **UI-VERIFY** row in your own JAMF Pro tenant before build-out.
2. Translate Requirement 3 from policy wording into a concrete approved target macOS version after each Apple release review.
3. Build a companion smart group or report for actual macOS version state so the baseline is enforceable and auditable.
4. Pilot on 3 to 5 Design Macs before broad scope, with at least one Adobe-heavy and one plug-in-heavy workstation included.
5. Record any approved temporary app-compatibility exceptions explicitly rather than leaving update drift undocumented.