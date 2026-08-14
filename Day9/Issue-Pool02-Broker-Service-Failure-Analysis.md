# Issue Analysis: Citrix VDI Session Launch Failure — FinBridge-VDI-Pool-02

**Date:** 2026-08-13  
**Analyst:** DWP Analyst  
**Status:** Resolved  
**Severity:** High — 22 users unable to launch VDI sessions  

---

## 1. Incident Summary

22 of 30 users on **FinBridge-VDI-Pool-02** were unable to launch Citrix VDI sessions. Sessions failed with broker error 1030. The parallel pool, **FinBridge-VDI-Pool-01**, on the same Citrix site was unaffected. The root cause was the **Citrix Broker Service on Delivery Controller `dc-vdi-02` being in a STOPPED state**, caused by Windows Update processing overnight with no automated recovery and no reboot completing.

---

## 2. Scope

| Item | Detail |
|---|---|
| Affected pool | FinBridge-VDI-Pool-02 |
| Affected users | 22 of 30 |
| Unaffected pool | FinBridge-VDI-Pool-01 (same site) |
| Affected Delivery Controller | dc-vdi-02.finbridge.local |
| Healthy Delivery Controller | dc-vdi-01.finbridge.local |
| First evidence of failure | 06:15 — VDI-P02-014 failed registration attempt |
| Incident detected | ~08:58 — first user session launch failure logged |

---

## 3. Evidence Collected

### 3.1 Session Broker Log

```
[08:58:03] Session launch requested: user jsmith, Pool-02
[08:58:04] Broker: Querying available machines in Pool-02
[08:58:34] Broker: Timeout waiting for machine registration response (30000ms exceeded)
[08:58:34] Session launch FAILED: error 1030 — 'No machines available in the desktop group'
```

- **Error 1030** is a standard Citrix broker error indicating no machines were available in the desktop group. This is a downstream consequence of machine registration failure, not an independent fault.

### 3.2 Machine Catalog Registration Status

| Pool | Provisioned | Registered | Unregistered | Maintenance |
|---|---|---|---|---|
| Pool-02 | 25 | 3 | 22 | 0 |
| Pool-01 | 20 | 19 | 1 | 0 |

- Pool-02 had only 3 of 25 machines registered — insufficient to serve the user load.
- Pool-01 registration was healthy (19/20), confirming the fault is scoped to Pool-02 and its Delivery Controller.

### 3.3 Unregistered Machine Detail (Pool-02 sample)

```
VDI-P02-014: Last registration attempt 06:15:22, failed
  Error: Unable to contact Delivery Controller
  dc-vdi-02.finbridge.local:80 — connection refused

VDI-P02-017: Last registration attempt 06:16:01, failed
  Error: Unable to contact Delivery Controller
  dc-vdi-02.finbridge.local:80 — connection refused
```

- **Connection refused on port 80** confirms nothing is listening on the Broker Service port on `dc-vdi-02`.
- Registration failures began at ~06:15, approximately 6 hours before users started reporting the issue.

### 3.4 Delivery Controller Health

| Controller | Broker Service | Uptime / Notes |
|---|---|---|
| dc-vdi-02 | **STOPPED** | Last running: yesterday 23:40; Windows Update installed today 00:15; reboot-required flag set; host not rebooted |
| dc-vdi-01 | **RUNNING** | Uptime 14 days; no anomalies |

- The Citrix Broker Service on `dc-vdi-02` was last confirmed running at **23:40**, and Windows Update ran at **00:15**.
- The reboot-required flag was set but the host was not rebooted, leaving the system in an inconsistent state.

---

## 4. Impact Assessment

| Category | Detail |
|---|---|
| User impact | 22 users completely unable to launch VDI sessions |
| Business impact | Loss of virtual desktop access for affected users; productivity impact for the duration of the outage |
| Data loss | None |
| Security impact | None |
| Duration | From ~06:15 (first failed registration) to resolution |
| Pool-01 impact | None — dc-vdi-01 healthy throughout |

---

## 5. Hypothesis Evaluation

Three hypotheses were considered in ranked order:

| Rank | Hypothesis | Assessment |
|---|---|---|
| 1 | Citrix Broker Service stopped by Windows Update processing | **Confirmed** — service state directly observed as STOPPED; timeline aligns with update install |
| 2 | Pending reboot state preventing service restart | **Contributing factor** — reboot flag set; must be addressed to prevent recurrence |
| 3 | Windows Update broke Broker Service binaries/dependencies | **Not required to explain evidence** — eliminated if service restarts cleanly |

---

## 6. Remediation Steps

Steps were executed in the following order:

1. **Confirmed service state** — `Get-Service -Name 'CitrixBrokerService' -ComputerName dc-vdi-02` returned `Stopped`.
2. **Attempted service restart** — `Start-Service -Name 'CitrixBrokerService'` on `dc-vdi-02`. If this failed, a controlled reboot of `dc-vdi-02` was the fallback.
3. **Monitored Pool-02 re-registration** — watched `Registered` count recover in Citrix Studio as VMs reconnected (expected 5–15 minutes).
4. **Validated end-to-end** — confirmed affected users (e.g. jsmith) could successfully launch sessions.

---

## 7. Verification Checks

```powershell
# 1. Broker Service running
Get-Service -Name 'CitrixBrokerService' -ComputerName dc-vdi-02
# Expected: Running

# 2. Pool-02 registration recovered
Get-BrokerMachine -DesktopGroupName 'FinBridge-VDI-Pool-02' |
    Group-Object RegistrationState | Select-Object Name, Count
# Expected: Registered ~25, Unregistered ~0

# 3. User session launch test
# Ask jsmith (or another affected user) to attempt session launch
# Expected: Session launches without error 1030
```

---

## 8. Preventive Actions

| Action | Detail | Owner |
|---|---|---|
| Service recovery policy | Configure `CitrixBrokerService` to restart automatically on failure on all Delivery Controllers | Infrastructure / EUC Team |
| Maintenance window enforcement | Restrict Windows Update installation and reboots on Delivery Controllers to approved out-of-hours windows with mandatory reboot completion | Patching / Change Management |
| Controller update staggering | Never patch `dc-vdi-01` and `dc-vdi-02` on the same night | Patching Team |
| Broker service health alert | Configure SCOM / Azure Monitor / Citrix Director to alert within 2 minutes of `CitrixBrokerService` entering a non-running state | Monitoring Team |

---

## 9. Lessons Learned

- A stopped service on a single Delivery Controller caused an 8-hour undetected outage affecting 22 users, demonstrating a gap in proactive service monitoring.
- Windows Update was applied without a guaranteed reboot, creating a partially updated system state that left a critical service stopped.
- The 6-hour gap between first registration failure (06:15) and first user complaint (~08:58) indicates reliance on user reporting rather than automated alerting.
