# Adding a Windows Application to the Intune App Catalog — Step-by-Step Guide

Version: v1.0
Date: 11/08/2026
Status: Draft — for use before any phased rollout begins
Author: DWP Engineering (Intune App Deployment)

Worked example used throughout: **FinBridge Connect v3.1**, a Windows LOB app packaged as a `.intunewin` file.

| Field | Value |
|---|---|
| Install command | `FinBridgeConnect_Setup.exe /silent` |
| Uninstall command | `FinBridgeConnect_Setup.exe /uninstall /silent` |
| Detection method | Registry key `HKLM\SOFTWARE\FinBridge\Connect\Version = 3.1` |

## ⚠️ Knowledge-currency disclaimer
The Intune admin center is updated frequently and exact menu labels, button text, and blade layouts **do change between tenant versions and over time**. Every navigation path and field label in this guide should be treated as a **starting point, not gospel** — where a step is marked `⚠️ UI-VERIFY`, stop and confirm the actual wording/location in your own tenant before proceeding. Screenshots and label text have not been re-validated against a live tenant for this guide (unlike the compliance-policy document in this same folder set).

---

## 1. Where to add an app in Intune

### 1.1 Navigation path
1. Sign in to **Microsoft Intune admin center** (`intune.microsoft.com`).
2. In the left-hand menu, select **Apps**.
3. Select **Windows** (under the *By platform* section). `⚠️ UI-VERIFY` — some tenant versions list this as **All apps** with a platform filter instead of a dedicated per-platform blade.
4. Select **+ Add** (or **+ Create**) at the top of the Windows apps list.
5. A panel titled **Select app type** opens on the right — this is the key decision point covered in section 1.2.

### 1.2 Choosing the correct app type
The **App type** dropdown controls which fields you'll be asked for later. Pick based on what you are actually deploying:

| App type to select | When to use it | Notes |
|---|---|---|
| **Windows app (Win32)** | Deploying a traditional Windows installer wrapped as a `.intunewin` file — this is what **FinBridge Connect v3.1** uses | This is the LOB (line-of-business) app path. Requires the Win32 Content Prep Tool to have already produced the `.intunewin` file before you start this wizard. |
| **Microsoft Store app (new)** | Deploying an app sourced from the Microsoft Store catalog (e.g., a public or private-store listing) | No install/uninstall command or detection rule needed — Intune manages this via the store listing metadata. `⚠️ UI-VERIFY` — label has changed from "Microsoft Store for Business" in older tenants; some tenants may still show the legacy name. |
| **Web link** | Adding a shortcut/tile to a website (e.g., an internal portal) rather than installing software | No executable is deployed; this just pins a URL as an "app" tile for discovery. |

For FinBridge Connect v3.1, select **Windows app (Win32)**, then choose **Select** to continue.

---

## 2. Required fields when creating the LOB Windows app

The Win32 app wizard has seven steps, confirmed against a live tenant screenshot review (reviewed 11/08/2026) ✅: **App information → Program → Requirements → Detection rules → Dependencies → Supersedence → Assignments** (with a **Return codes** section nested inside Program, and a final **Review + create**). `⚠️ UI-VERIFY` — step naming is fairly stable but this list can still change between tenant versions; confirm the tabs shown live before relying on this order.

### 2.1 Select the app package
1. On the **App information** step, first select the folder icon next to **Select app package file** and upload the `.intunewin` file produced for FinBridge Connect v3.1.
2. Intune reads the package metadata and pre-fills some fields automatically — review, don't blindly trust, the auto-filled values.

### 2.2 App information
Fill in (or confirm auto-filled values). Fields marked **Required** below match a live tenant screenshot review (`Add App > Windows app (Win32)`, reviewed 11/08/2026) — confirmed live except **Name**, which wasn't visible in the reviewed screenshot and should still be checked live:

| Field | Required? | Value for FinBridge Connect v3.1 |
|---|---|---|
| Name | Yes `⚠️ UI-VERIFY` — not visible in reviewed screenshot | `FinBridge Connect v3.1` |
| Description | **Yes** ✅ Confirmed live — supports Markdown, with a live preview pane shown underneath as you type | e.g., "FinBridge Connect client — required for finance team connectivity to the FinBridge platform." |
| Publisher | **Yes** ✅ Confirmed live | `FinBridge` (use the actual vendor/publisher name) |
| App Version | No ✅ Confirmed live | `3.1` |
| Category | No ✅ Confirmed live — dropdown, "0 selected" by default | Optional; pick a relevant category if your tenant uses this for Company Portal browsing |
| Show this as a featured app | No ✅ Confirmed live — Yes/No toggle, defaults to **No** | Leave as **No** during pilot; only feature it in Company Portal once rollout is confirmed |

Other fields on this step (logo, information URL, privacy URL) may also appear depending on tenant version — optional metadata, useful for Company Portal presentation but not functionally required for deployment.

### 2.3 Program
| Field | Value for FinBridge Connect v3.1 |
|---|---|
| Install command | `FinBridgeConnect_Setup.exe /silent` |
| Uninstall command | `FinBridgeConnect_Setup.exe /uninstall /silent` |
| Install behavior | **System** — install runs in the System context, so it applies machine-wide regardless of which user is logged in. Use **User** only if the installer specifically requires per-user context (e.g., writes to `HKCU` or a user profile and cannot be adapted). |
| Device restart behavior | Typically **Determine behavior based on return codes** unless the installer is known to always/never require a restart. |

**Install behavior — system vs user context, why it matters:** System-context installs run as `NT AUTHORITY\SYSTEM` with no interactive desktop, so the install command **must be a genuinely silent/unattended switch** (as FinBridge Connect's `/silent` flag provides) — an installer that pops a UI and waits for a click will hang and eventually fail/time out under System context.

#### Return codes
Still within the Program step, review the **Return codes** table. Defaults are usually pre-populated; confirm they match your installer's actual behavior:

| Return code | Meaning |
|---|---|
| `0` | Success |
| `1707` | Success |
| `3010` | Soft reboot required (treated as success, restart pending) |
| `1641` | Hard reboot initiated (treated as success) |
| `1618` | Another installation in progress → retry |
| Anything else (e.g., non-zero/non-listed) | Failure |

If FinBridge Connect's installer uses non-standard exit codes, add/edit rows here so Intune doesn't misreport a genuine success as a failure (or vice versa).

### 2.4 Requirements
Confirmed against a live tenant screenshot review (`Add App > Windows app (Win32) > Requirements`, reviewed 11/08/2026):

| Field | Required? | Value for FinBridge Connect v3.1 |
|---|---|---|
| Operating system architecture restriction | No — radio button, defaults to **"No. Allow this app to be installed on all systems."** ✅ Confirmed live | Leave as **No** unless FinBridge Connect is known to be architecture-specific; only select **Yes** and pick 32-bit/64-bit if the vendor confirms the package won't run on both. |
| Minimum operating system | **Yes** ✅ Confirmed live — dropdown of friendly OS version names (e.g., "Windows 10 1607"), not raw build numbers | Select the lowest supported Windows version matching whatever the vendor documents as minimum-supported. `⚠️ UI-VERIFY` — the list of selectable OS versions changes as Microsoft adds new releases/retires old ones, so the exact options shown will differ from any example here. |
| Disk space required (MB) | No ✅ Confirmed live | Optional; leave blank unless a minimum is known |
| Physical memory required (MB) | No ✅ Confirmed live | Optional; leave blank unless a minimum is known |
| Minimum number of logical processors required | No ✅ Confirmed live | Optional; leave blank unless a minimum is known |
| Minimum CPU speed required (MHz) | No ✅ Confirmed live | Optional; leave blank unless a minimum is known |

**Configure additional requirement rules** (below the fields above) lets you add custom **Type** / **Path/Script** based requirement rules (e.g., a registry, file, or script-based prerequisite check). Shows **"No requirements are specified"** by default — leave empty for FinBridge Connect v3.1 unless a specific prerequisite (e.g., a dependency that must already be installed) needs to be enforced.

### 2.5 Detection rules
This is how Intune determines the app installed successfully **after** the install command exits with a success code — without this, Intune cannot report accurate install status.

The **Rules format** dropdown is **required** ✅ Confirmed live and offers exactly two options — pick carefully, as this choice changes every field shown below it:

| Rules format option | What it shows | Use for FinBridge Connect v3.1? |
|---|---|---|
| **Manually configure detection rules** | Lets you pick a rule **Type** (Registry, MSI, File) and fill in matching criteria — this is the option used below | **Yes** — use this option |
| **Use a custom detection script** | Replaces the rule-builder with **Script file** (upload) and **Script content** (read-only preview) fields, plus a **Run script as 32-bit process on 64-bit clients** Yes/No toggle (defaults to **No**) | Not needed here — reserve for apps where no simple registry/MSI/file check can reliably confirm install state |

For FinBridge Connect v3.1, select **Manually configure detection rules**, then configure:

| Field | Value |
|---|---|
| Rule type | **Registry** |
| Key path | `HKEY_LOCAL_MACHINE\SOFTWARE\FinBridge\Connect` |
| Value name | `Version` |
| Detection method | **String comparison** |
| Operator | **Equals** |
| Value | `3.1` |
| Associated with a 32-bit app on 64-bit clients? | Set per how the installer actually writes the key (check whether it lands under `WOW6432Node` on 64-bit devices) |

**Other rule types available under Manually configure detection rules** (use whichever matches the installer type, not necessarily registry):
- **MSI product code** — best choice when the package is a genuine MSI; Intune can read the product code directly from the MSI and auto-populate this.
- **File** — detects presence/version of a specific file/path on disk (e.g., the installed `.exe`).
- **Registry** — used above; good when the vendor's installer reliably writes a version key.

Whichever method is chosen, it must reliably distinguish "installed" from "not installed" — a key/file that exists regardless of install state produces false "Installed" reports.

### 2.6 Scope tags / Assignments
The remaining wizard steps (Scope tags, if shown, and Assignments) are covered in section 3 below. Complete **Review + create** only after Assignments are set correctly for a **pilot group**, not the full estate — see section 3.2.

---

## 3. Assignment basics

### 3.1 Required vs Available vs Uninstall

| Assignment type | Behavior | Typical use |
|---|---|---|
| **Required** | App installs automatically, silently, without user action, on any device/user in the assigned group | Mandatory business apps that must be present (e.g., FinBridge Connect for the finance team) |
| **Available** | App appears in **Company Portal** for the user to install on demand; not pushed automatically | Optional/self-service apps users may want but don't all need |
| **Uninstall** | Intune actively removes the app from any device/user in the assigned group | Decommissioning an app, or excluding a subgroup from an app that's Required elsewhere |

`⚠️ UI-VERIFY` — assignment group targeting (device group vs user group) and the exact wording of these three intents are stable concepts, but the layout of the Assignments blade (tabs vs sections) has changed across Intune versions.

### 3.2 Why pilot first, not the full 10,000-device fleet
1. Go to the **Assignments** step and add the **Required** assignment group.
2. Select a **small, dedicated pilot/test Azure AD group** (e.g., 10–25 devices or users) — **not** an all-devices or all-users group.
3. Do **not** proceed to a broader assignment until the pilot has been verified (section 4) across at least one normal patch/reboot cycle.

**Why this matters:** an install command, detection rule, or requirement rule error only surfaces once the app actually attempts to deploy. Assigning **Required** directly to all ~10,000 devices means:
- A bad install command (e.g., a typo, wrong switch, or an installer that silently fails) fails on the **entire fleet simultaneously**, not a small recoverable subset.
- A wrong detection rule can cause Intune to **endlessly re-attempt** installation on every check-in cycle across the whole estate, generating unnecessary load and noise.
- Any unexpected side effect (reboot prompts, conflicting software, licensing checks) is discovered at the worst possible scale.

A pilot group lets you catch and fix packaging/detection issues against a handful of devices, with minimal helpdesk impact, before wider rollout.

---

## 4. Verification steps

### 4.1 Confirm the app appears correctly in the catalog
1. Go to **Apps > Windows** and locate **FinBridge Connect v3.1** in the app list.
2. Open the app and check the **Overview** blade — confirm name, publisher, and version match what was entered in section 2.2.
3. Check the **Device install status** and **User install status** tabs are present and not showing an error banner (e.g., "app content not fully processed" — if seen, wait and refresh; large `.intunewin` packages can take time to finish processing after upload).

### 4.2 Check install status on an assigned test device
1. On the test device, open **Company Portal** (or, for admin-side verification) go back to **Intune admin center > Apps > Windows > FinBridge Connect v3.1 > Device install status**.
2. Find the specific pilot device in the list and review its **Status** column (see meanings in section 4.3 below).
3. If status doesn't update promptly, on the test device open **Settings > Accounts > Access work or school > [tenant] > Info > Sync** (or run `Sync` from the Company Portal app) to force an immediate check-in rather than waiting for the default sync interval. `⚠️ UI-VERIFY` — exact Settings app path/wording varies by Windows build.
4. For deeper diagnostics on the device itself, the **IME (Intune Management Extension) logs** under `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs` record the actual install command execution and exit code — useful if status is stuck or shows Failed.

### 4.3 What the statuses mean

| Status | Meaning |
|---|---|
| **Installed** | The install command ran, returned a success code, and the detection rule (registry key `Version = 3.1` in this example) was found — Intune considers the app present. |
| **Failed** | The install command returned a non-success exit code, or ran successfully but the detection rule was **not** found afterwards (e.g., wrong registry path, or install genuinely failed). Check IME logs and the return-codes table (section 2.3) to distinguish a real install failure from a detection-rule mismatch. |
| **Not applicable** | The device doesn't meet the **Requirements** rules (section 2.4) — e.g., wrong OS architecture or below minimum OS version — so Intune never attempted the install. This is expected/normal for out-of-scope devices, not an error. |
| **Pending install** / **In progress** | The device has received the assignment but hasn't completed installation yet (may be waiting on a check-in, a scheduled maintenance window, or mid-download). |

---

## Summary — end-to-end checklist for FinBridge Connect v3.1

1. Upload `.intunewin` package via **Apps > Windows > Add > Windows app (Win32)**.
2. Complete **App information** (name, description, publisher, version `3.1`).
3. Set **Program**: install `FinBridgeConnect_Setup.exe /silent`, uninstall `FinBridgeConnect_Setup.exe /uninstall /silent`, behavior **System**.
4. Review **Return codes** table for accuracy.
5. Set **Requirements**: correct architecture + minimum OS version.
6. Set **Detection rule**: registry, `HKLM\SOFTWARE\FinBridge\Connect`, value `Version`, string equals `3.1`.
7. Assign **Required** to a small pilot group only.
8. Verify catalog listing, then verify install status on pilot device(s), confirming **Installed** before considering wider phased rollout.

## Recommended next steps
1. Confirm every `⚠️ UI-VERIFY` item against the live tenant before executing this guide for real.
2. Once the pilot group shows **Installed** with no unexpected **Failed** results across a full patch cycle, proceed to the phased rollout plan (outside the scope of this document).
3. Keep this guide updated with corrected navigation labels once verified live, following the same confirmed/UI-VERIFY convention used in the compliance-policy document in this folder set.
