# AP-11 — Cascade Risk Detector Antipatterns

**Pattern this relates to:** [P11 Cascade Risk Detectors](../patterns/p11-cascade-risk-detectors/)
**Category:** Warning Signs and Triggers
**TL;DR:** The blast radius of failures is larger than expected, circuit breakers exist but don't help, or the dependency graph isn't known until something breaks.

---

## The three ways this goes wrong

---

### AP-11-A: Invisible Blast Radius

**What it is:** The dependency graph is not mapped. When a service fails, nobody knows which other services will be affected until they start throwing errors. Incident response becomes archaeology — tracing backwards from symptoms to find the source.

**Sign:** Every significant incident post-mortem includes "we didn't realise X depended on Y."

**Why it happens:** Dependency relationships grow organically. Each team knows their immediate dependencies but not the transitive ones. There is no mechanism for surfacing the full graph.

**What this costs:**
```
Incident timeline with invisible blast radius:
  T+0:00  Service A starts degrading
  T+0:08  First user reports
  T+0:15  On-call acknowledges — assumes isolated issue
  T+0:35  Second service shows errors — now tracing dependencies
  T+0:55  Third service found — team is now doing graph traversal live
  T+1:20  Full blast radius understood
  T+1:45  Mitigation complete

With visible blast radius (same incident):
  T+0:00  Service A starts degrading
  T+0:05  Cascade Risk Detector alerts: "A is degrading — known blast radius: B, C, D"
  T+0:08  On-call has the full map, starts parallel mitigation
  T+0:35  Mitigation complete
```

**The fix — P11 applied:** Build and maintain a dependency graph. Automate its extraction from service manifests and network traffic. Make blast radius queryable before incidents. Run cascade risk scoring quarterly and surface the top 5 highest-risk services.

**Validated reference:** [Netflix Chaos Engineering](https://netflixtechblog.com/chaos-engineering-upgraded-878d341f15fa) — blast radius management. [AWS X-Ray](https://aws.amazon.com/xray/) service maps. [Jaeger](https://www.jaegertracing.io/) distributed tracing for dependency discovery.

**SCARS lens:** Separation — services that are not separated in the dependency graph are implicitly coupled.

---

### AP-11-B: Circuit Breaker Theatre

**What it is:** Circuit breakers are configured and present in every service. They appear in architecture diagrams. They are referenced in post-mortems as existing. But when a cascade happens, they either do not trip (thresholds too high), trip and make things worse (no fallback defined), or trip and the calling service errors immediately anyway.

**Sign:** A post-mortem where circuit breakers "existed but didn't help."

**Why it happens:** Circuit breakers are installed as a pattern compliance checkbox. The threshold values are defaults. The fallback behaviour — what to do when the breaker is open — is not defined. The breaker trips; the service is not prepared for the open state.

**The three failure modes:**

1. **Threshold too high** — breaker never trips because it requires 50% error rate over 60 seconds. By then the damage is done.

2. **No fallback** — breaker trips, calling service immediately throws an unhandled exception. The service fails faster, not safer.

3. **Breaker not tested** — breaker is in place, but nobody has verified it trips under real failure conditions.

```javascript
// Circuit Breaker Theatre — what it looks like
const breaker = new CircuitBreaker(callPaymentService, {
  timeout: 3000,
  errorThresholdPercentage: 50,  // trips at 50% — too late
  resetTimeout: 30000
  // No fallback defined
});

breaker.fire(orderData)
  .catch(err => {
    throw err;  // No graceful degradation — just re-throws
  });

// Circuit Breaker working correctly
const breaker = new CircuitBreaker(callPaymentService, {
  timeout: 1000,                  // Tight timeout
  errorThresholdPercentage: 20,   // Trips early
  resetTimeout: 15000,
  volumeThreshold: 5              // Minimum calls before measuring
});

breaker.fallback(() => ({         // Always define the fallback
  status: 'queued',
  message: 'Payment processing delayed — order confirmed',
  retryAfter: 30
}));
```

**The fix — P11 applied:** For every circuit breaker, define: the threshold (trip early, not late), the fallback behaviour (what the user sees when the breaker is open), and a test that verifies the breaker trips under simulated failure conditions.

**Validated reference:** [Netflix Hystrix documentation](https://github.com/Netflix/Hystrix/wiki) — the original circuit breaker implementation with fallback patterns. [Resilience4j](https://resilience4j.readme.io/docs/circuitbreaker) — modern Java implementation. Michael Nygard's [Release It!](https://pragprog.com/titles/mnee2/release-it-second-edition/) — the source of circuit breaker pattern in software.

**SCARS lens:** Abstraction — Circuit Breaker Theatre fails to abstract failure into recoverable behaviour.

---

### AP-11-C: Sync Bridge Denial

**What it is:** An organisation has adopted async-first architecture (P01) but critical paths still include synchronous call chains. These sync bridges are the highest-risk cascade paths: one slow database query propagates as latency through every synchronous caller in the chain. The bridges are known, justified ("this one really needs to be synchronous"), and unmitigated.

**Sign:** "Yes, there are a few synchronous calls, but they're to very reliable services." The reliable service has an incident.

**Why it happens:** Not all synchronous calls can be eliminated. The problem is not their existence but the refusal to measure and mitigate their cascade risk. The justification for keeping them synchronous becomes the justification for not adding circuit breakers.

**What the risk looks like:**
```
Sync call chain:
  API Gateway → Order Service → Payment Service → Bank API
  
Latency propagation under Bank API degradation (300ms → 3000ms):
  Bank API:        3000ms
  Payment Service: 3000ms + 50ms overhead = 3050ms
  Order Service:   3050ms + 100ms overhead = 3150ms
  API Gateway:     3150ms + 50ms overhead = 3200ms (timeout)
  
Every request times out at the gateway.
User impact: 100%.
```

**The fix — P11 applied:** Sync bridges are identified and registered. Every sync bridge has a circuit breaker with a fallback. High-risk sync bridges get a migration plan to async (P01), with a timeline. The goal is not zero synchronous calls — it is zero unmitigated synchronous calls.

**Validated reference:** Sam Newman's [Building Microservices](https://samnewman.io/books/building_microservices_2nd_edition/) — synchronous call chain risks. Architecture for Flow (Susanne Kaiser) — flow efficiency and synchronous coupling.

**SCARS lens:** Separation — unmitigated sync bridges are the tightest form of runtime coupling.

---

## Fitness function for cascade risk

```javascript
// fitness-functions/cascade/cascade-risk-score.js
// Run in CI — fail if high-risk services lack circuit breakers

async function auditCascadeRisk(serviceGraph) {
  const report = {
    highRiskServices: [],
    unmitgatedSyncBridges: [],
    circuitBreakerGaps: []
  };

  for (const service of serviceGraph.services) {
    const risk = calculateRisk(service, serviceGraph);
    
    if (risk.level === 'HIGH') {
      const hasBreaker = service.circuitBreakers?.length > 0;
      const hasFallback = service.circuitBreakers?.every(cb => cb.fallback);
      const isTested = service.circuitBreakers?.every(cb => cb.testCoverage > 0);
      
      if (!hasBreaker || !hasFallback || !isTested) {
        report.circuitBreakerGaps.push({
          service: service.name,
          riskScore: risk.score,
          missing: [
            !hasBreaker && 'circuit-breaker',
            !hasFallback && 'fallback-behaviour', 
            !isTested && 'breaker-test'
          ].filter(Boolean)
        });
      }
    }
  }

  // Fail CI if any high-risk service has gaps
  if (report.circuitBreakerGaps.length > 0) {
    console.error('FAIL: High-risk services without complete circuit breaker coverage:');
    console.error(JSON.stringify(report.circuitBreakerGaps, null, 2));
    process.exit(1);
  }
}
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-01 Async Monolith](ap-01-mycelial-mesh.md) | Async monolith hides sync bridges within the async surface |
| [AP-02 Undeclared Keystone](ap-02-keystone-interface.md) | Keystones are highest-risk cascade nodes |
| [AP-09 SLA Theatre](ap-09-carrying-capacity-monitors.md) | SLAs stay green until cascade — leading indicators would show earlier |

---

*See also: [AP-README](README.md) for the full antipattern index.*
