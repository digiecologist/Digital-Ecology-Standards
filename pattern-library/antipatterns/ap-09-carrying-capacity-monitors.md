# AP-09 — Carrying Capacity Monitor Antipatterns

**Pattern this relates to:** [P09 Carrying Capacity Monitors](../patterns/p09-carrying-capacity-monitors/)
**Category:** Warning Signs and Triggers
**TL;DR:** Either too many alerts (engineers ignore them all) or the wrong alerts (SLAs look fine while structural health degrades). Both result in the same outcome: surprises in production.

---

## The three ways this goes wrong

---

### AP-09-A: Alert Fatigue Loop

**What it is:** Alert volume is high enough that engineers begin triaging by instinct — silencing alerts that have "always been there" before checking if they are now telling you something real. The monitoring is technically in place, but functionally absent.

**Sign:** On-call engineers acknowledge alerts without opening the runbook. Alert-to-action rate is below 30%.

**Why it happens:** Alerts are added liberally and never pruned. Thresholds are set too low to catch transient noise. Every service ships with a default alert config that nobody reviews in context.

**What it looks like:**
```
Alert volume for typical on-call week:
  Monday:    47 alerts fired  →  3 required action
  Tuesday:   51 alerts fired  →  2 required action  
  Wednesday: 38 alerts fired  →  1 required action
  
Signal-to-noise ratio: ~5%
Result: Engineers stop reading alert descriptions
```

**The fix — P09 applied:** Every alert must answer the question "what do I do when this fires?" before it is allowed into production. Alerts that cannot be actioned are removed or rolled up. Alert volume is reviewed quarterly. The target is fewer, higher-quality signals — not comprehensive coverage.

**The one rule:** If an alert fires and you look at it and do nothing, that alert should not exist.

**Validated reference:** Google SRE Book — [Chapter 6: Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/). The "symptoms not causes" principle. [Charity Majors on alert fatigue](https://charity.wtf/).

**SCARS lens:** Simplify — alert sprawl is complexity that prevents the monitoring system from doing its job.

---

### AP-09-B: SLA Theatre

**What it is:** The system is monitored against SLAs and SLAs are being met — but the structural health of the ecosystem is degrading. Coupling is rising. Schema drift is accumulating. Recovery times are increasing. None of this is measured. Everything looks green until it doesn't.

**Sign:** SLA dashboards are all green the week before a significant incident. Post-mortem reveals the signs were there for weeks in unmeasured dimensions.

**Why it happens:** SLAs measure the outcomes users experience. They do not measure the structural properties that determine how the system will behave under stress six months from now. The two are related but not the same.

**What the gap looks like:**

| What SLA monitoring covers | What it misses |
|---|---|
| p99 latency | Coupling score trend |
| Error rate | Fan-in growth |
| Uptime | Schema drift accumulation |
| Throughput | Dead letter queue depth |
| | Recovery asymmetry |
| | Deployment frequency degradation |

**The fix — P09 applied:** Extend monitoring to the four ecological signals: coupling score, flow distribution, schema drift rate, and recovery asymmetry. These are leading indicators — they tell you where the system is heading, not just where it is.

**Validated reference:** DORA metrics — deployment frequency and change failure rate are the nearest established equivalents. [Accelerate](https://itrevolution.com/accelerate-book/) (Forsgren, Humble, Kim). Ruth Malan's SCARS as a structural health checklist.

**SCARS lens:** Cohesion — SLA Theatre monitors cohesion of output (meeting targets) without measuring cohesion of structure.

---

### AP-09-C: The Invisible Ceiling

**What it is:** Services have hard limits — database connection pools, memory ceilings, queue throughput caps — but these limits are not measured, not surfaced, and not alertable. The first indication that a ceiling exists is when it is hit.

**Sign:** Incidents involve a service hitting a hard limit that nobody knew was approaching. Post-mortem recommendations include "add monitoring for X" — which should have been present at launch.

**Why it happens:** Limits are configured at infrastructure provisioning time and then forgotten. They live in Terraform or CloudFormation, not in dashboards. Nobody owns the gap between "what is configured" and "what is being approached."

**What to measure:**
```yaml
# The ceilings to instrument per service
carrying_capacity_signals:
  - metric: db_connection_pool_utilization
    threshold_warn: 70%
    threshold_critical: 85%
    
  - metric: queue_depth_orders_processing  
    threshold_warn: 1000
    threshold_critical: 5000
    
  - metric: memory_utilization_percent
    threshold_warn: 75%
    threshold_critical: 90%
    
  - metric: thread_pool_active_count
    threshold_warn: 80%  # of max
    threshold_critical: 95%
```

**The fix — P09 applied:** Every service deployment includes a capacity contract: what are the configured limits, at what percentage do we alert, and what is the runbook action when the threshold is crossed? This is infrastructure-as-code for observability.

**Validated reference:** [USE Method](https://www.brendangregg.com/usemethod.html) (Brendan Gregg) — Utilisation, Saturation, Errors. Cloud provider capacity planning documentation. SRE workbook capacity planning chapter.

**SCARS lens:** Abstraction — The Invisible Ceiling is a failure to abstract infrastructure limits into observable, actionable signals.

---

## Fitness functions for these antipatterns

```yaml
# fitness-functions/monitors/alert-quality-gate.yml
# Run quarterly — flags alerts that have not triggered any action

name: Alert Quality Audit

checks:
  - name: Alert-to-action ratio
    query: |
      count(alerts_acknowledged_without_action, 30d) /
      count(alerts_fired, 30d)
    threshold: "< 0.3"  # Fail if more than 70% of alerts require no action
    action: Review and prune alerts below threshold

  - name: Alerts without runbooks
    query: count(alerts WHERE runbook_url IS NULL)
    threshold: "= 0"
    action: Block deployment of alert configs without runbook links

  - name: Ecological signals coverage
    required_metrics:
      - coupling_score
      - schema_drift_rate  
      - dead_letter_queue_depth
      - recovery_time_p95
    threshold: all_present
    action: Fail if any ecological signal lacks an alert threshold
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-11 Invisible Blast Radius](ap-11-cascade-risk-detectors.md) | Unmonitored ceilings create cascade conditions |
| [AP-02 Keystone Without Runbook](ap-02-keystone-interface.md) | Same root cause — governance declared but not maintained |
| [AP-12 Boiling Frog](ap-12-phenological-drift-alerts.md) | SLA Theatre and Boiling Frog are complementary failure modes |

---

*See also: [AP-README](README.md) for the full antipattern index.*
