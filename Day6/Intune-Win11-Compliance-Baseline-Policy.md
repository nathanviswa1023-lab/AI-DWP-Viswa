# Windows 11 Intune Compliance Policy — Security Baseline Translation

Version: v1.1 — updated against live tenant screenshots
Date: 11/08/2026
Status: Draft — pending security team sign-off; grace-period discrepancy needs action
Author: DWP Engineering (Intune Compliance)

## Purpose
Translate the 7 approved security baseline requirements into concrete Windows 10/11 Intune compliance policy settings, with expected enforcement effect, known false-positive triggers, and tuning recommendations. Grace period target: **7 days** across all settings.

## ⚠️ Knowledge-currency disclaimer
Intune admin center navigation and setting labels have changed several times (Endpoint Manager → Intune admin center rebrand, ongoing migration of policy types onto the Settings Catalog). Paths below have now been **confirmed against a live tenant policy** (`DWP - windows 10/11 compliance polic base line`, screenshot review 11/08/2026) — corrections from the original draft are noted per requirement. Any row still flagged **UI-VERIFY** was not visible in the reviewed screenshots and should still be checked live before go-live.

Base navigation (confirmed):
`Microsoft Intune admin center (intune.microsoft.com) > Devices > Compliance > Policies > [Policy name] > Properties > Compliance settings > Edit`

Confirmed top-level categories in this tenant: **Device Health**, **Microsoft Defender Antimalware**, **Device Security** (not "System Security" as originally guessed — corrected below).

---

## Requirement 1 — BitLocker enabled on OS drive

| Field | Detail |
|---|---|
| Settings name | **Require BitLocker** (category: *Device Health*) — displays as **Bitlocker** in the Properties summary view |
| UI path | Devices > Compliance > Policies > [Policy] > Properties > Compliance settings > **Device Health** > Bitlocker ✅ **Confirmed live** |
| Value | **Require** (shows as "Required" in the read-only Properties summary) |
| Effect | Device is marked non-compliant unless the OS drive reports as BitLocker-encrypted. Blocks conditional access for unencrypted disks. |
| False-positive risk | Encryption in progress (used-space-only encryption can take time to report as "on"); reporting relies on device health attestation-style CSP checks that can lag after a fresh build/re-image; BitLocker temporarily suspended during firmware/driver updates (e.g., WinRE or TPM firmware push) drops protector status without disabling encryption; devices not yet Azure AD/Entra joined so key escrow/report hasn't synced. |
| Recommendation | Keep the 7-day grace period — it covers the typical suspend/resume window during patch cycles. Exclude imaging/staging device groups from this policy while builds are in provisioning. Confirm with `manage-bde -status` during pilot to distinguish "still encrypting" from "genuinely unencrypted" before tightening. |

---

## Requirement 2 — Secure Boot enabled

| Field | Detail |
|---|---|
| Settings name | **Require Secure Boot to be enabled on the device** (category: *Device Health*) — displays as **Secure Boot** in the Properties summary view |
| UI path | Devices > Compliance > Policies > [Policy] > Properties > Compliance settings > **Device Health** > Secure Boot ✅ **Confirmed live** |
| Value | **Require** (shows as "Required" in the read-only Properties summary) |
| Effect | Blocks devices that boot with Secure Boot disabled or unsupported, reducing risk of unsigned/rootkit bootloaders. |
| False-positive risk | Health-attestation-based reporting can be delayed 12–48h after enrollment or reimage, so a genuinely compliant device may briefly show non-compliant; legacy/CSM (Compatibility Support Module) BIOS mode devices and some Gen1 Hyper-V or older VDI templates don't support Secure Boot at all even though patched and safe; OEM firmware defaults occasionally ship with Secure Boot off despite hardware support. |
| Recommendation | 7-day grace absorbs most attestation lag. Maintain a separate compliance policy (or exclusion group) for any legacy VM/VDI pools that cannot support Secure Boot, rather than exempting them from the whole baseline — track those separately as a known accepted risk. |

---

## Requirement 3 — Minimum OS build (N-1: 22621.2861)

| Field | Detail |
|---|---|
| Settings name | **Minimum OS version** (category: *Device Properties*) |
| UI path | Devices > Compliance policies > Create policy > Windows 10 and later > Compliance settings > **Device Properties** > Minimum OS version `⚠️ UI-VERIFY` |
| Value | `10.0.22621.2861` — **must use the full 4-part build string**, not just `22621.2861` (this is the most common data-entry error) |
| Effect | Devices below the specified build are non-compliant, forcing update to at least the accepted patch level. |
| False-positive risk | Legitimate update-ring lag: devices on a slower deployment ring or with deferred feature/quality updates via Windows Update for Business policy may not yet have installed the build even though patching is proceeding normally; update installed but pending a restart the user hasn't actioned; incorrect value format (short build string) causes the policy to never evaluate true, flagging the entire estate. |
| Recommendation | Raise the minimum-build value only a few days **after** your update ring has substantially completed rollout (align the value bump with your patch-Tuesday deployment cadence, not the release date). Keep the 7-day grace to cover restart-pending devices. Double check the value is entered as the full `10.0.xxxxx.xxxxx` string. |

---

## Requirement 4 — Microsoft Defender real-time protection on

| Field | Detail |
|---|---|
| Settings name | **Real-time protection**, under category **Microsoft Defender Antimalware** — corrected from original draft's "System Security > Microsoft Defender Antivirus" |
| UI path | Devices > Compliance > Policies > [Policy] > Properties > Compliance settings > **Microsoft Defender Antimalware** > Real-time protection ✅ **Confirmed live** (category is its own top-level section, not nested under System/Device Security) |
| Value | **Require** |
| Effect | Non-compliant if Defender real-time scanning is off, uninstalled, or reporting unhealthy. |
| False-positive risk | Devices running an approved third-party AV put Defender into **passive mode**, which reports real-time protection as off even though the device is protected; Tamper Protection or GPO/Intune AV policy conflicts can cause transient misreporting; brief real-time protection toggles during AV vendor migration or scheduled full-scan handoff; Defender for Endpoint connector sync delay (reporting lag up to a few hours). |
| Recommendation | Exclude devices in the approved third-party-AV group from this specific setting (assess via that vendor's own compliance signal instead). Keep 7-day grace to absorb sync/reporting lag. Confirm Tamper Protection status isn't conflicting during pilot testing. |

---

## Requirement 5 — Firewall enabled for all profiles

| Field | Detail |
|---|---|
| Settings name | **Firewall** (category: originally guessed *System Security* — this tenant uses **Device Security** as the equivalent category name, so update accordingly) |
| UI path | Devices > Compliance > Policies > [Policy] > Properties > Compliance settings > **Device Security** > Firewall `⚠️ UI-VERIFY` (not visible in reviewed screenshots — confirm the Firewall row sits in Device Security alongside the Password setting before relying on this path) |
| Value | **Require** |
| Effect | Non-compliant if the Windows Firewall service is disabled. |
| ⚠️ Coverage gap | This compliance toggle only checks whether the **Windows Firewall service itself is running** — it does **not** independently verify that Domain, Private, and Public profiles are each individually enabled. To actually enforce "all profiles on", pair this compliance check with a separate **Endpoint security > Firewall** configuration profile (Firewall CSP, Settings Catalog) that sets `EnableFirewall = true` for Domain/Private/Public profiles. Compliance alone cannot fully satisfy this requirement as literally stated. |
| False-positive risk | Approved third-party firewall/EDR products manage the network stack and can cause the native Windows Firewall service to report disabled even though the device is protected; brief service restarts during patching; network profile misdetection (e.g., device flips to Public profile unexpectedly on VPN/guest Wi-Fi) can trigger profile-specific policy failures if a config profile is also in place. |
| Recommendation | Deploy the companion configuration profile referenced above rather than relying on compliance policy alone. Add an exclusion for the approved third-party firewall group. Keep 7-day grace for transient service restarts. |

---

## Requirement 6 — PIN or password configured

| Field | Detail |
|---|---|
| Settings name | **Require a password to unlock mobile devices** plus **Required password type** (category: **Device Security** — corrected from original draft's "System Security") |
| UI path | Devices > Compliance > Policies > [Policy] > Properties > Compliance settings > **Device Security** > Require a password to unlock mobile devices ✅ **Confirmed live**; Required password type = Device default (or Numeric/Alphanumeric to mandate a PIN specifically) |
| Value | Require a password to unlock mobile devices = **Require**; Required password type = **Device default** (accepts Windows Hello PIN or password) |
| Effect | Device is non-compliant if no lock-screen credential (PIN/password/Hello) is configured. |
| False-positive risk | New/Autopilot devices mid-provisioning where the user hasn't completed Windows Hello/PIN setup yet; shared or kiosk-mode devices with no interactive sign-in context; TPM provisioning delay blocking PIN creation on first boot; biometric-only sign-in occasionally reporting inconsistently against the password-type check. |
| Recommendation | 7-day grace covers normal first-login PIN setup delay. Exclude dedicated kiosk/shared-device groups from this specific requirement and manage them under a separate kiosk compliance policy. Pair with a Windows Hello for Business (or Enrollment Status Page) policy to force PIN creation at first sign-in, reducing genuine non-compliance rather than relying on grace period alone. |

---

## Requirement 7 — Device must not be jailbroken/rooted

| Field | Detail |
|---|---|
| Settings name | **No direct Windows equivalent exists.** "Jailbroken/rooted" is an iOS/Android compliance setting (*Device Health* > Jailbroken devices, Require = Block). Windows has no native "jailbreak" detection setting. |
| Closest Windows mapping | Combine: **Require Secure Boot** + **Require code integrity** (category: *Device Health*, blocks devices with disabled/tampered kernel code signing) + **Require BitLocker** (Requirements 1 & 2 above). Optionally add **Defender for Endpoint machine risk score** (category: *Device Health*, if MDE is onboarded) to catch broader tamper/compromise indicators. |
| UI path | Devices > Compliance policies > Create policy > Windows 10 and later > Compliance settings > **Device Health** > Require code integrity `⚠️ UI-VERIFY`; Machine risk score row appears only if Microsoft Defender for Endpoint connector is enabled under Endpoint security > Microsoft Defender for Endpoint. |
| Value | Require code integrity = **Require**; Machine risk score (if available) = **Medium** or **Low** threshold, per risk appetite |
| Effect | Detects boot/kernel-level tampering consistent with jailbreak-style compromise (unsigned drivers, disabled code integrity, elevated device risk). |
| False-positive risk | Code integrity checks can flag legitimately signed but unusual third-party kernel drivers (some security/VPN/print drivers); MDE risk score can spike temporarily from benign admin activity (e.g., driver installs, PowerShell admin scripts) and needs time to decay. |
| Recommendation | Document clearly for the security team that Requirement 7 is satisfied via a **compound mapping**, not a single literal setting — this is a policy-writing decision that needs their explicit sign-off. Use "Medium" risk score threshold rather than "Low" to reduce noise from routine admin activity, and keep 7-day grace so risk scores have time to decay after benign events. |

---

## Grace period — applies policy-wide, not per setting
Intune compliance policies do not attach grace period to individual settings. It's configured once per policy under:

`Devices > Compliance > Policies > [Policy] > Actions for noncompliance > Edit` ✅ **Confirmed live**

### ⚠️ Discrepancy found in the current live configuration
The reviewed tenant policy is currently set as:

| Action | Schedule |
|---|---|
| Mark device noncompliant | **Immediately** |
| Add device to retire list | **7 Days** |

This does **not** match the requirement of a 7-day grace period before enforcement. As configured, a device is flagged non-compliant (and any linked Conditional Access block triggers) the moment a check fails, with **zero** grace — the 7-day timer only delays the destructive **retire/wipe** action, which is a much harsher outcome than "grace period."

**Recommendation:** change the **"Mark device noncompliant"** action schedule from *Immediately* to **7 days**, so devices have a genuine 7-day grace window before being flagged non-compliant / losing access. Decide separately (with the security team) whether the "Add device to retire list" action should remain at 7 days or be extended/removed — auto-retiring (wiping) a device is a significant, hard-to-reverse action and shouldn't be conflated with the baseline's grace-period requirement.

---

## Summary table

| # | Requirement | Category | Setting | Value | Grace (target) |
|---|---|---|---|---|---|
| 1 | BitLocker OS drive | Device Health | Require BitLocker | Require | 7 days |
| 2 | Secure Boot | Device Health | Require Secure Boot to be enabled on the device | Require | 7 days |
| 3 | Min OS build N-1 | Device Properties | Minimum OS version | 10.0.22621.2861 | 7 days |
| 4 | Defender real-time protection | Microsoft Defender Antimalware | Real-time protection | Require | 7 days |
| 5 | Firewall all profiles | Device Security `⚠️ UI-VERIFY` | Firewall (+ companion Firewall config profile) | Require | 7 days |
| 6 | PIN/password | Device Security | Require a password to unlock mobile devices | Require | 7 days |
| 7 | Not jailbroken/rooted | Device Health | Require code integrity (+ Secure Boot + BitLocker + MDE risk score) | Require / Medium | 7 days |

## Recommended next steps
1. Fix the live policy's **Actions for noncompliance**: change "Mark device noncompliant" from *Immediately* to **7 days** so the grace period actually applies before enforcement (see discrepancy callout above).
2. Confirm the Firewall setting's exact category (`⚠️ UI-VERIFY`) — not visible in the reviewed screenshots.
3. Deploy the standalone Firewall configuration profile alongside Requirement 5's compliance check.
4. Pilot on a small ring for one full patch cycle to validate false-positive assumptions before enterprise-wide rollout.
5. Get explicit security team sign-off on the compound mapping used for Requirement 7, and on the retire-list wipe timing (7 days) vs. the grace-period timing (also 7 days) so the two are not accidentally treated as the same control.
