# P16 — Ecological Succession Gates

**Category:** Adaptive & Regenerative | **Build priority:** BUILD SECOND | **Complexity:** Medium
**AC score contribution:** Technical AC (T-AC) + Organisational AC (O-AC)

> **Relationship to P03:** P03 defines what each succession stage looks like. P16 defines how a service earns the right to move between stages.

---

## 1. What this pattern is

In ecological succession, a grassland does not become a forest overnight. It passes through shrub stage first. The transition happens when conditions are right — when the pioneer species have prepared the soil, when the light conditions favour shrubs over grasses, when the biomass can support the next stage. The transition is earned, not declared.

Software services accumulate maturity in the same way. A service that has run in production for six months, maintained a 99.9% SLA, registered all its consumer contracts, and built runbooks for all its failure modes has earned Product stage. A service that was deployed last week has not, regardless of what the team labels it.

Ecological Succession Gates are the checkpoints a service must pass to earn a stage transition. They make service maturity explicit, verifiable, and objective — not a matter of team opinion or organisational politics.

---

## 2. The value it brings

- Service maturity claims are verifiable, not just asserted
- Consumers know the actual maturity of the services they depend on
- Governance overhead is applied correctly — services get stricter gates only when they have earned the stage that warrants them
- Pioneer service graduation (P13) has a formal, agreed pathway
- Technical debt cannot hide behind a claimed maturity level the service has not earned

---

## 3. The problem it solves

You know you need this pattern when services are labelled "production-ready" based on team confidence rather than demonstrated criteria, or when a service carries the same governance requirements as your most critical infrastructure despite having never demonstrated the reliability to warrant it.

The problem is asserted maturity. Without succession gates, service maturity is whatever the team says it is. This leads to two failure modes: services claimed to be stable that are not (creating hidden risk for consumers) and services locked in governance overhead they have not earned (slowing down legitimate experimentation).

---

## 4. Existing pattern equivalents and the gap this fills

| Pattern | Relationship |
|---|---|
| Definition of Done (Agile) | Per-feature completion criteria — succession gates are per-service maturity criteria |
| Production readiness reviews | A manual checkpoint — succession gates automate and formalise this |
| P03 Succession Stage Routing | Defines what governance each stage gets — P16 is how you earn a stage |
| P13 Pioneer Service Incubators | Pioneer services use the Gate 1 criteria to graduate to Custom |

**The gap this fills:** existing maturity models are descriptive — they describe what mature services look like. Succession gates are prescriptive and verifiable — they define what a service must demonstrate before it earns a maturity level.

---

## 5. What needs to happen

1. **Define the gate criteria for each stage transition.** Make them objective and measurable — not "has good test coverage" but "test coverage > 80% verified by CI."

2. **Genesis → Custom gate (converging on what works):**
   - Deployed to production at least once
   - At least one real user or consuming service
   - A documented decision on the technology choice it is validating

3. **Custom → Product gate (ready for wider adoption):**
   - SLA defined and met for 30 consecutive days
   - All consumer contracts registered (P07)
   - Runbooks documented for all P1 failure modes
   - On-call rotation established
   - Health endpoint implemented (P09)
   - Schema registered (P07)
   - No P1 incidents in last 30 days

4. **Product → Commodity gate (safe to treat as infrastructure):**
   - SLA met for 12 consecutive months
   - Zero breaking schema changes in 6 months
   - Consumer contract test coverage at 100%
   - Architecture review of blast radius completed
   - Disaster recovery procedure tested

5. **Automate the gate checks.** Gate criteria should be verifiable from CI/CD data, monitoring, and the service registry — not from a manual checklist.

---

## 6. Antipatterns and unhealthy versions

**The rubber stamp gate:** the gate criteria exist but the review is a formality. Every service that applies passes.

> **Sign:** no service has ever failed a succession gate review.

**The permanent Pioneer:** a service that never attempts to graduate because the team prefers the lower governance overhead of Pioneer/Genesis stage, even though other services are depending on it.

> **Sign:** a service that other teams' services depend on is still classified Genesis two years after deployment.

**Retroactive graduation:** a service skips stages because the team insists it is already Commodity-stage. Gates work forward, not backward.

> **Sign:** a service claims Commodity status on first production deployment.

---

## 7. Architecture diagram

```
SUCCESSION GATE JOURNEY

[Pioneer Incubator] ──gate 1──► [Custom] ──gate 2──► [Product] ──gate 3──► [Commodity]
     P13                           P03                   P03                   P03

Gate 1 (Genesis → Custom):        Gate 2 (Custom → Product):
  ✓ Deployed to production          ✓ SLA met 30 consecutive days
  ✓ Real consumer exists            ✓ Consumer contracts registered
  ✓ Technology decision documented  ✓ Runbooks complete
                                    ✓ Health endpoint live
                                    ✓ On-call established
                                    ✓ No P1 incidents in 30 days

Gate 3 (Product → Commodity):
  ✓ SLA met 12 consecutive months
  ✓ Zero breaking schema changes (6 months)
  ✓ 100% consumer contract coverage
  ✓ Disaster recovery tested
```

---

## 8. Related patterns

| Pattern | Relationship |
|---|---|
| P03 Succession Stage Routing | Defines what governance each stage applies — P16 is how you earn a stage |
| P13 Pioneer Service Incubators | Pioneer services use the Gate 1 criteria to graduate to Custom |
| P07 Nutrient Flow Contracts | Consumer contract registration is a Gate 2 requirement |
| P09 Carrying Capacity Monitors | Health endpoint and SLA measurement are Gate 2 and 3 requirements |

---

## 9. Code snippet

```javascript
// Succession gate check — verifies a service meets criteria for stage transition
async function checkSuccessionGate(serviceName, targetStage) {
  const checks = {
    'genesis-to-custom': [
      { name: 'Has production deployment', fn: () => hasProductionDeployment(serviceName) },
      { name: 'Has at least one consumer', fn: () => hasRegisteredConsumer(serviceName) },
      { name: 'Technology decision documented', fn: () => hasADR(serviceName) }
    ],
    'custom-to-product': [
      { name: 'SLA met for 30 days', fn: () => checkSLAHistory(serviceName, 30) },
      { name: 'Consumer contracts registered', fn: () => checkContractRegistry(serviceName) },
      { name: 'Runbooks complete', fn: () => checkRunbooks(serviceName) },
      { name: 'Health endpoint live', fn: () => checkHealthEndpoint(serviceName) },
      { name: 'No P1 incidents in 30 days', fn: () => checkIncidentHistory(serviceName, 30) }
    ]
  };

  const gateKey = `${await getCurrentStage(serviceName)}-to-${targetStage}`;
  const gateChecks = checks[gateKey];
  if (!gateChecks) throw new Error(`Unknown gate: ${gateKey}`);

  const results = await Promise.all(gateChecks.map(async check => ({
    name: check.name,
    passed: await check.fn()
  })));

  const failures = results.filter(r => !r.passed);
  if (failures.length > 0) {
    console.log(`\nSUCCESSION GATE: ${serviceName} (${gateKey})`);
    console.log(`RESULT: FAIL — ${failures.length} criteria not met:`);
    failures.forEach(f => console.log(`  ✗ ${f.name}`));
    return false;
  }

  console.log(`SUCCESSION GATE: ${serviceName} (${gateKey}) — PASS`);
  return true;
}
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Services with stage assigned via gate (not asserted) | 100% | Gate completion log |
| Services depending on Genesis/Custom stage services | Decreasing trend | Registry cross-reference |
| Gate failure rate (services that apply and fail) | 10–30% — some failure means gates have teeth | Gate audit log |
| Time in Genesis before first gate attempt | < 6 months | Registry timestamps |

---

## 12. What to look out for

A gate failure rate of 0% means the gates have no teeth — every service passes trivially. A rate of 10–30% is healthy — it means the criteria are real and services that are not ready are identified before being promoted. The gate criteria for Product stage in particular must include the SLA measurement window (30 days minimum) — teams will try to shortcut this. The SLA history must come from monitoring data, not from team assertion. No exceptions.
