# P09 — Carrying Capacity Monitors

**Category:** Warning Signs & Triggers | **Build priority:** BUILD FIRST | **Complexity:** Low
**AC score contribution:** Operational AC (Op-AC)

---

## 1. What this pattern is

Every ecosystem has a carrying capacity — the maximum load it can sustain without degrading. Software systems have the same property. Every service, queue, and database has a ceiling. The question is not whether you will approach it, but whether you will know before you hit it or only after things start breaking.

Carrying Capacity Monitors watch the four signals that matter most — coupling, flow distribution, schema drift, and recovery asymmetry — and alert before thresholds are crossed, not after services fail.

---

## 2. The value it brings

- Incidents caught before they become visible to users
- On-call engineers have signal, not noise — alerts fire on sustained breaches, not spikes
- AC score trajectory becomes trackable over time
- Post-mortems have a "we should have seen this coming" answer

---

## 3. The problem it solves

You know you need this pattern when incidents feel sudden but post-mortems reveal warning signs were there for weeks, or when you find out about problems when users report them.

The problem is reactive observability. Most systems are instrumented to detect failure after it has happened. This pattern shifts the posture from reactive to predictive.

---

## 4. Existing pattern equivalents and the gap this fills

| Pattern | Relationship |
|---|---|
| Four Golden Signals (Google SRE) | Latency, traffic, errors, saturation — Carrying Capacity Monitors add ecosystem-level signals |
| Health Endpoint pattern | The `/health` endpoint is the data source; this pattern defines what listens to it |
| DORA metrics | Carrying Capacity Monitors measure the architectural conditions that drive DORA metrics |

**The gap:** existing observability patterns are service-scoped. This pattern is ecosystem-scoped.

---

## 5. What needs to happen

1. Standardise on OpenTelemetry across all services — vendor-neutral, instrument once
2. Define a `/health` endpoint contract every service implements
3. Instrument the four ecological signals: coupling score, flow distribution, schema drift, recovery asymmetry
4. Define alert thresholds with runbooks — if you cannot write what to do when it fires, you are not ready to write the alert
5. Alert on sustained breaches, not spikes — a threshold crossed for 10 minutes, not one data point
6. Add ecosystem-level aggregation — landscape-wide coupling trend, AC score trajectory

---

## 6. Antipatterns

See [AP-09: Carrying Capacity Monitors antipatterns](../../antipatterns/ap-09-carrying-capacity-monitors.md).

**Alert soup:** too many alerts → engineers ignore them → real alerts missed. Any alert firing more than twice a week without action is broken.

> **Sign:** on-call engineers silence alert channels at the start of their shift.

**Service-only scope:** all service health checks pass, but end-to-end user journeys are degraded.

> **Sign:** the metrics dashboard shows everything green in the week before a major incident.

---

## 7. Architecture diagram

```
┌─────────────────────────────────────────────┐
│         EXISTING PRODUCTION SERVICES         │
│      READ-ONLY — monitor never writes        │
└──────┬────────────────────┬─────────────────┘
       │ trace data         │ /health endpoints
       ▼                    ▼
┌──────────────────────────────────────────────┐
│              INGESTION LAYER                  │
│  Trace Collector │ Health Crawler │ Schema Watcher │
└──────────────────────────┬───────────────────┘
                           ▼
┌──────────────────────────────────────────────┐
│              ANALYSIS ENGINE                  │
│  Coupling Score │ Flow Distribution │ Recovery │
└──────────────────────────┬───────────────────┘
                           ▼
┌──────────────────────────────────────────────┐
│           ALERTING & VIEWS                    │
│  Teams: their services    Architects: landscape│
│  Leadership: AC score     Alert router         │
└──────────────────────────────────────────────┘
```

---

## 8. Related patterns

| Pattern | Relationship |
|---|---|
| P01 Mycelial Mesh | Generates the flow and coupling data this pattern monitors |
| P02 Keystone Interface | Keystones need enhanced per-consumer monitoring |
| P11 Cascade Risk Detectors | Uses the coupling data this pattern collects |

---

## 9. Code snippet

```javascript
// Standard /health endpoint — the data source for carrying capacity monitoring
app.get('/health', async (req, res) => {
  const health = {
    status: 'healthy',
    version: process.env.SERVICE_VERSION,
    timestamp: new Date().toISOString(),
    dependencies: {}
  };

  for (const dep of dependencies) {
    try {
      const start = Date.now();
      await checkDependency(dep.url, { timeout: 2000 });
      health.dependencies[dep.name] = { status: 'healthy', latencyMs: Date.now() - start };
    } catch (err) {
      health.dependencies[dep.name] = { status: 'unhealthy', error: err.message };
      health.status = 'degraded';
    }
  }

  res.status(health.status === 'healthy' ? 200 : 503).json(health);
});
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Mean time to detect | < 5 minutes | Time between threshold crossing and alert |
| Alert fatigue rate | < 2 actionable alerts per engineer per week | Alert log analysis |
| Health endpoint coverage | 100% of production services | Health endpoint crawler |
| Incidents preceded by monitor signal | > 80% | Post-mortem tag analysis |

---

## 12. What to look out for

The monitor itself must pass its own health checks before alerting on others. Aggregate metrics hide signal — instrument and alert at the consumer level for keystone interfaces. Break the alert fatigue spiral early: enforce that every alert must be actionable.
