# Triage Summary — T-1005

**Date raised:** 2026-08-05  
**Logged by:** Service Desk Analyst (AI-assisted draft — verified before use, per DWP Personal AI Usage Charter)

---

## Summary
Teams audio is not working (no sound in/out) on three machines located in the same meeting room, during the same meeting.

---

## Impact
| Field | Detail |
|---|---|
| Affected users | At least 3 (all occupants of the meeting room using the affected machines) — to-verify total headcount affected |
| Business urgency | Medium-High — meeting room is unusable for calls until resolved; escalate if room is booked for imminent/ongoing business-critical meetings — to-verify |
| Role / team | Unknown — to-verify |
| Time of onset | Not stated — to-verify (started this meeting only, or recurring issue in this room) |

---

## Known Facts
- Three separate machines, all in the same physical meeting room, are experiencing "audio dead" in Teams during the same meeting.
- No error code, error message, or specific symptom detail (e.g., no mic input vs. no speaker output vs. both) was provided — do not assume.
- No information given on whether this is a room-based conferencing device (e.g., Teams Room system) or individual laptops/desktops connecting to the same meeting.

---

## Missing Information to Gather
1. Exact symptom per machine: no output (speakers), no input (mic), or both — to-verify.
2. Are these individual user laptops, or a dedicated Teams Room / conferencing system (e.g., soundbar, room codec) — to-verify.
3. Room name/location and asset tags of the three machines (do **not** paste into AI tools; use internal systems only).
4. Is audio hardware shared (e.g., one room speakerphone/soundbar feeding all three) or independent per machine — to-verify.
5. Any error banners or device-selection prompts shown in Teams (e.g., "no speaker/mic detected") — to-verify.
6. Did this start suddenly (mid-meeting) or was audio broken from the start of the call?
7. Any recent changes: Windows update, Teams app update, driver update, or room AV equipment change/maintenance — to-verify.
8. Are other rooms/machines unaffected, confirming this is isolated to this specific room — to-verify.
9. Is the room's audio device shared via USB hub, Bluetooth, or direct connection, and is it powered on/connected — to-verify.
10. Does the issue persist across a Teams restart, machine reboot, or joining a new test call?

## Likely Category
**Audio/Peripheral Hardware — Teams Client (Meeting Room)** — probable sub-categories:
- Shared meeting room AV equipment fault (speakerphone/soundbar/codec) affecting all connected machines — to-verify
- Common cause across machines: driver, Teams update, or Windows update rolled out to room devices — to-verify
- Incorrect audio device selected in Teams settings on each machine — to-verify
- Network/policy change affecting Teams media (less likely given "audio dead" but not ruled out) — to-verify

---

## Suggested First Diagnostic Step
On one of the three affected machines, open Teams device settings during a test call and confirm which speaker/microphone device is selected and whether it is detected by Windows; if a shared room audio device (soundbar/speakerphone) is in use, check its power/connection status first, since a single shared hardware fault would explain identical symptoms across all three machines.

---

*Note: This summary was drafted using AI assistance. No DWP internal data, user PII, hostnames, or credentials were included in the AI prompt, in accordance with the DWP Personal AI Usage Charter. All fields marked "to-verify" must be confirmed via internal tooling before action.*
