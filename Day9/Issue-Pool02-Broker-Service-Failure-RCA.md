# Root Cause Analysis: Citrix VDI Session Launch Failure — FinBridge-VDI-Pool-02

**Date:** 2026-08-13  
**Author:** DWP Analyst  
**Review Status:** Draft  
**Incident Reference:** Pool-02 Broker Failure — 2026-08-13  
**Severity:** High  

---

## 1. Executive Summary

On 2026-08-13, 22 of 30 users on **FinBridge-VDI-Pool-02** were unable to launch Citrix virtual desktop sessions. The **Citrix Broker Service on Delivery Controller `dc-vdi-02`** was found in a `STOPPED` state. Windows Update had run at 00:15 the same day, stopping the service as part of its pre-install process. The host was not rebooted to complete the update, and no automated recovery mechanism restarted the service. As a result, all 22 machines dependent on `dc-vdi-02` could not register, leaving only 3 of 25 machines available in the pool — insufficient for the user load.

Root cause: **Absence of a service recovery policy and absence of a post-update mandatory reboot on a critical infrastructure component.**

---

## 2. Timeline of Events

| Time | Event |
|---|---|
| **Yesterday 23:40** | Citrix Broker Service last confirmed running on `dc-vdi-02` |
| **Today 00:15** | Windows Update installed on `dc-vdi-02`; reboot-required flag set; host not rebooted |
| **00:15 – 06:15** | Broker Service remains STOPPED; no automated recovery triggered; no alert fired |
| **06:15:22** | VDI-P02-014 attempts registration — fails: `connection refused dc-vdi-02.finbridge.local:80` |
| **06:16:01** | VDI-P02-017 attempts registration — fails with same error |
| **06:15 – 08:58** | All Pool-02 VMs continue failing registration silently; 22 machines unregistered |
| **08:58:03** | User jsmith attempts session launch on Pool-02 |
| **08:58:04** | Broker queries Pool-02 for available machines |
| **08:58:34** | Broker timeout (30,000 ms); session launch fails: error 1030 `No machines available in the desktop group` |
| **~08:58+** | 22 users report inability to launch sessions |
| **[Resolution]** | `CitrixBrokerService` restarted on `dc-vdi-02`; Pool-02 machines re-register; sessions restored |

---

## 3. Supporting Evidence

### 3.1 Broker Log Extract

```
[08:58:34] Session launch FAILED: error 1030 — 'No machines available in the desktop group'
```

Error 1030 is a standard Citrix broker response when zero machines are available for assignment in a desktop group. It is a consequence of the registration failure, not an independent fault.

### 3.2 Machine Catalog State at Time of Incident

| Pool | Provisioned | Registered | Unregistered |
|---|---|---|---|
| Pool-02 (dc-vdi-02) | 25 | 3 | 22 |
| Pool-01 (dc-vdi-01) | 20 | 19 | 1 |

### 3.3 VDI Machine Registration Errors (Pool-02)

```
VDI-P02-014 — 06:15:22 — Unable to contact Delivery Controller
              dc-vdi-02.finbridge.local:80 — connection refused

VDI-P02-017 — 06:16:01 — Unable to contact Delivery Controller
              dc-vdi-02.finbridge.local:80 — connection refused
```

Port 80 is the default Citrix Broker Service communication port. `Connection refused` confirms the service was not listening — consistent with a stopped service, not a network block (which would produce a timeout, not a refused connection).

### 3.4 Delivery Controller Health

```
dc-vdi-02:
  Service 'Citrix Broker Service' : STOPPED
  Last known running               : yesterday 23:40
  Windows Update installed        : today 00:15 (reboot required flag set, host not rebooted)

dc-vdi-01:
  Service 'Citrix Broker Service' : RUNNING
  Uptime                           : 14 days
```

`dc-vdi-01`, serving Pool-01, was unaffected — confirming the fault was isolated to `dc-vdi-02` and not a site-wide Citrix or network issue.

---

## 4. Five Whys Analysis

| Why # | Question | Answer |
|---|---|---|
| **Why 1** | Why could users not launch VDI sessions on Pool-02? | The Citrix Broker could not assign a machine — only 3 of 25 were registered (error 1030). |
| **Why 2** | Why were only 3 of 25 machines registered in Pool-02? | 22 machines could not contact their Delivery Controller (`dc-vdi-02`) on port 80 — connection refused. |
| **Why 3** | Why was `dc-vdi-02` refusing connections on port 80? | The Citrix Broker Service on `dc-vdi-02` was STOPPED — nothing was listening on port 80. |
| **Why 4** | Why was the Citrix Broker Service stopped? | Windows Update ran at 00:15 and stopped the service as part of its install process. The host was not rebooted to complete the update cycle and restart the service. |
| **Why 5** | Why was the service not automatically restarted and why was no alert raised? | No service recovery policy was configured on `dc-vdi-02`. No monitoring alert was in place to detect a stopped Broker Service. The stopped state went undetected for approximately 8 hours until users reported failures. |

**Root Cause Statement:**  
The Citrix Broker Service on `dc-vdi-02` was stopped by Windows Update processing. It was not restarted because: (a) no service recovery policy was configured to restart it automatically, (b) no reboot was enforced to complete the update cycle, and (c) no monitoring alert existed to detect the stopped state. The failure went undetected for ~8 hours until impacted users raised the issue.

---

## 5. Contributing Factors

| Factor | Detail |
|---|---|
| No service recovery policy | `CitrixBrokerService` had no configured failure action to attempt automatic restart |
| No mandatory post-update reboot | Windows Update was permitted to install without enforcing an immediate or scheduled reboot on a critical infrastructure host |
| No proactive service monitoring | No alert was configured to detect `CitrixBrokerService` in a non-running state |
| Single controller dependency | Pool-02 was exclusively served by `dc-vdi-02` with no failover to `dc-vdi-01` during the outage |
| Delayed detection | 6-hour gap between first registration failure (06:15) and first user report (~08:58) — entirely dependent on user reporting |

---

## 6. Remediation Actions Taken

| Step | Action |
|---|---|
| 1 | Confirmed `CitrixBrokerService` was `Stopped` on `dc-vdi-02` |
| 2 | Restarted `CitrixBrokerService` on `dc-vdi-02` |
| 3 | Monitored Pool-02 machine re-registration in Citrix Studio until `Registered` count recovered |
| 4 | Validated end-to-end session launch for affected users |
| 5 | Scheduled controlled reboot of `dc-vdi-02` during next maintenance window to clear the pending reboot flag |

---

## 7. Preventive Actions

### 7.1 Immediate (within 24 hours)

| Action | Command / Detail |
|---|---|
| Configure service recovery policy on all Delivery Controllers | `sc.exe \\dc-vdi-02 failure CitrixBrokerService reset= 86400 actions= restart/60000/restart/60000/restart/120000` — restart on 1st, 2nd, and 3rd failure |
| Verify same policy is applied to `dc-vdi-01` | Run same command against `dc-vdi-01` |

### 7.2 Short-term (within 1 week)

| Action | Detail | Owner |
|---|---|---|
| Enforce mandatory reboot on Delivery Controllers post-update | Configure WSUS / Intune Update Ring for Delivery Controllers to require reboot completion within the maintenance window, not deferred indefinitely | Patching / Change Management |
| Create Broker Service health monitor | SCOM alert / Azure Monitor / Citrix Director threshold: if `CitrixBrokerService` is non-running for > 2 minutes on any Delivery Controller, fire P1 alert to on-call team | Monitoring Team |

### 7.3 Medium-term (within 1 month)

| Action | Detail | Owner |
|---|---|---|
| Stagger Delivery Controller patching | Enforce policy: `dc-vdi-01` and `dc-vdi-02` must not be patched on the same night. Patch one, validate, then patch the other | Change Management |
| Review Pool-02 controller redundancy | Assess whether Pool-02 VMs can register against both `dc-vdi-01` and `dc-vdi-02` for resilience, or whether a third controller is warranted | EUC / Infrastructure |
| Add registration failure alerting | Alert if more than 10% of machines in any pool transition to `Unregistered` state within a 15-minute window | Monitoring Team |

---

## 8. Lessons Learned

1. **Critical services require explicit recovery policies.** A service stopped by an OS process should restart automatically — relying on manual intervention creates unnecessary outage duration.
2. **Windows Update on infrastructure hosts must enforce reboot completion.** A host with a pending reboot is in an indeterminate state and should not remain in production without resolution.
3. **User reporting is not a monitoring strategy.** An 8-hour silent failure period, detectable from registration error logs since 06:15, demonstrates the need for automated infrastructure alerting.
4. **Single-controller pool design carries risk.** Where possible, pools should be able to register against multiple Delivery Controllers to tolerate a single controller failure.

---

## 9. Sign-off

| Role | Name | Date |
|---|---|---|
| Analyst | | 2026-08-13 |
| EUC Lead | | |
| Change Manager | | |
