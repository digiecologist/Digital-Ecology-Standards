# P03 — Succession Stage Routing

**Category:** Structural / Architectural | **Build priority:** BUILD SECOND | **Complexity:** Medium
**AC score contribution:** Technical AC (T-AC)

> **Prerequisite:** P01 Mycelial Mesh should be in place. This pattern governs the schemas that flow through the mesh.

---

## 1. What this pattern is

In ecology, succession describes how ecosystems change over time — bare rock becomes pioneer grassland, grassland becomes shrub, shrub becomes forest. Each stage has different species, different rules, different tolerances. What works for a pioneer stage would destroy a climax forest.

Software services go through the same stages. A new service in Genesis — barely proven, changing weekly — needs different governance than a stable Product-stage service that thirty teams depend on. Applying the same deployment rules and schema governance to both is a mistake most systems make by default.

Succession Stage Routing classifies each service on the Wardley evolution axis and routes governance decisions — schema validation strictness, deployment gate requirements, SLA obligations — through that classification.

---

## 2. The value it brings

- Experimental services move fast without mature governance overhead
- Stable services are protected by strictness their dependents require
- Governance overhead is proportional to risk, not uniform across everything
- Teams stop fighting governance designed for a different stage than theirs
- Schema drift is caught earlier because stage-appropriate checks are explicit

---

## 3. The problem it solves

You know you need this pattern when a producer team changes their event schema and three consuming teams find out in error logs an hour later, or when nobody can answer "what breaks if we change this API?"

The problem is uniform governance. Most systems apply the same rules to everything — same PR requirements, same schema validation, same deployment gates. This is either too strict for experimental work or too loose for critical infrastructure. Often both at once in different parts of the system.

---

## 4. Existing pattern equivalents and the gap this fills

| Pattern | Relationship |
|---|---|
| Wardley Mapping | Provides the evolution axis this pattern uses as its routing key |
| API versioning strategies | Governs one dimension of maturity — this pattern governs all dimensions together |
| P16 Ecological Succession Gates | Gates govern how a service *transitions* between stages — this pattern defines what each stage *looks like* |

**The gap this fills:** existing patterns route governance by environment or team. This pattern routes by evolutionary maturity — a more accurate proxy for appropriate strictness.

---

## 5. What needs to happen

1. **Classify every service by Wardley stage.** Maintain a `service-registry.yml` declaring each service's current stage: Genesis, Custom, Product, or Commodity.

2. **Define governance rules per stage:**
   - *Genesis:* free schema changes, automated tests only, no SLA required
   - *Custom:* versioned schemas, peer review, no external SLA
   - *Product:* additive-only schemas, peer review + consumer notice, SLA required
   - *Commodity:* frozen schemas with migration window, architecture review, SLA-backed

3. **Wire the routing into CI/CD.** The pipeline reads the service's declared stage and applies the corresponding rule set. Stage changes require an explicit PR.

4. **Add the schema drift fitness function.** On every deploy, validate schema changes against the stage's rules.

5. **Review stage classifications quarterly.** Services evolve — stale classifications are as harmful as none.

---

## 6. Antipatterns and unhealthy versions

**Stage inflation:** every team claims Genesis to escape governance. Classifications need external review.

> **Sign:** 80% of services are classified Genesis, including one that has run in production for three years.

**Stage freeze:** services never graduate from Genesis because graduation triggers stricter governance.

> **Sign:** a service has been "experimental" for 18 months and other services quietly depend on it.

---

## 7. Architecture diagram

```
SERVICE REGISTRY
────────────────────────────────────────────────────────────
Service           │ Stage     │ Schema rule       │ Deploy gate
──────────────────┼───────────┼───────────────────┼────────────
order-service     │ Product   │ Additive only      │ Peer review
fraud-detector    │ Custom    │ Versioned          │ Auto tests
ml-recommender    │ Genesis   │ Free               │ Auto tests
payment-gateway   │ Commodity │ Frozen/migration   │ Arch review

CI/CD PIPELINE
────────────────────────────────────────────────────
Read stage → Apply rules
  Genesis:   fast path, minimal gates
  Custom:    versioned schemas, peer review
  Product:   additive-only, consumer notice required
  Commodity: migration window, architecture review
```

---

## 8. Related patterns

| Pattern | Relationship |
|---|---|
| P01 Mycelial Mesh | Provides the event flows this pattern governs schema compliance for |
| P02 Keystone Interface | Keystone interfaces are almost always Product or Commodity — the strictest routing |
| P16 Ecological Succession Gates | Governs how a service earns the right to transition between stages |
| P20 Biodiversity Index | Uses stage classifications from the same registry |

---

## 9. Code snippet

```javascript
// Succession stage router — applies governance rules by service stage
const GOVERNANCE_RULES = {
  genesis:   { schemaValidation: 'free',                    deployGate: 'auto-tests' },
  custom:    { schemaValidation: 'versioned',               deployGate: 'peer-review' },
  product:   { schemaValidation: 'additive-only',           deployGate: 'peer-review-plus-notice' },
  commodity: { schemaValidation: 'frozen-migration-window', deployGate: 'architecture-review' }
};

async function applySuccessionGating(serviceName, proposedChanges) {
  const registry = await loadServiceRegistry();
  const service = registry[serviceName];
  if (!service) {
    console.error(`Service ${serviceName} not in registry. Add it before deploying.`);
    process.exit(1);
  }

  const rules = GOVERNANCE_RULES[service.stage];

  if (rules.schemaValidation === 'additive-only') {
    const violations = proposedChanges.schemaChanges.filter(c => c.type !== 'additive');
    if (violations.length > 0) {
      console.error(`STAGE VIOLATION: ${serviceName} is Product stage — only additive schema changes allowed`);
      process.exit(1);
    }
  }

  return rules;
}
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Services without a declared stage | 0 | Service registry completeness |
| Schema violations caused by stage mismatch | 0 | Incident post-mortem tags |
| Stage classifications reviewed in last 90 days | 100% | Registry last-reviewed timestamps |
| Services in Genesis > 6 months without review | 0 | Registry age check |

---

## 12. What to look out for

Stage classification is a governance act — it needs a process, not just a YAML field. Who can change a stage? What triggers a review? Pair with P16 (Succession Gates) which provides the formal graduation ceremony between stages. Without P16, stage classifications drift — everything stays Genesis or teams resist graduation indefinitely.
