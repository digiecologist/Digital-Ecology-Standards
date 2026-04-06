# AP-12 — Phenological Drift Alert Antipatterns

**Pattern this relates to:** [P12 Phenological Drift Alerts](../patterns/p12-phenological-drift-alerts/)
**Category:** Warning Signs and Triggers

---

### AP-12-A: Boiling Frog

**What it is:** Degradation is gradual enough that no single data point triggers an alarm. Latency creeps from 180ms to 240ms to 310ms over six months. Each individual change is within tolerance. The cumulative change is not.

**Sign:** You look at a 6-month trend chart and cannot explain when the degradation started. It just... happened.

**The fix:** Trend alerting, not threshold alerting. The question is not "is this metric above X?" but "is this metric 20% worse than its 90-day baseline?" These are different calculations with different alert triggers.

```yaml
# prometheus alert rule — trend-based, not threshold-based
- alert: LatencyDrift
  expr: |
    (rate(http_request_duration_seconds_sum[1h]) / 
     rate(http_request_duration_seconds_count[1h]))
    > 
    1.2 * avg_over_time(
      rate(http_request_duration_seconds_sum[1h])[90d:1h]
    )
  for: 30m
  annotations:
    summary: "Latency 20% above 90-day baseline for 30+ minutes"
```

**Validated reference:** [Brendan Gregg USE Method](https://www.brendangregg.com/usemethod.html). Netflix Atlas time-series alerting on trend deviation.

---

### AP-12-B: Drift Without Baseline

**What it is:** Trend alerting is set up but baselines were never established. The "baseline" is the current value — so everything looks normal.

**Sign:** All trend alerts show 0% deviation. Always. Even during incidents.

**The fix:** Capture and store baselines at service launch and quarterly thereafter. A baseline that was set during an incident will make the incident look normal.

---

### AP-12-C: Noise-Signal Inversion

**What it is:** The drift alert fires so frequently that engineers start treating it as noise — often because the baseline includes a period of known poor performance.

**The fix:** Curate baselines. A baseline that includes known-bad periods produces drift alerts that fire constantly. Store baselines with provenance: when they were set, under what conditions, by whom.

---

*See also: [AP-README](README.md)*
