# P07 — Nutrient Flow Contracts

**Category:** Flow & Nutrient Cycling | **Build priority:** BUILD SECOND | **Complexity:** Medium
**AC score contribution:** Technical AC (T-AC)

> **Prerequisite:** P01 Mycelial Mesh. Nutrient Flow Contracts are the governance layer for the event and API flows the mesh carries.

---

## 1. What this pattern is

In an ecosystem, nutrients cycle through a food web in predictable, declared flows. Each participant consumes what it needs and produces what others depend on. When a link in the chain changes, the downstream effects are visible and traceable because the relationships are known.

Nutrient Flow Contracts apply this to APIs and events. Every interface declares not just what it does, but what degrades if it stops. Every consumer declares what it depends on and what it will do if the provider is unavailable. The contract is bilateral — both sides have obligations, and both sides are visible to the system.

This is the governance layer that prevents the Mycelial Mesh from becoming event soup. Events need schemas. Schemas need owners. Owners need to know who depends on them.

---

## 2. The value it brings

- Schema changes cannot break consumers silently — every dependency is declared
- API owners know downstream impact before making changes
- Incident investigation is faster — the contract registry shows who depends on what
- Schema drift is caught at deploy time, not at runtime
- Producers can deprecate safely — contracts show who still needs the old version

---

## 3. The problem it solves

You know you need this pattern when a producer team changes their event schema and three consuming teams find out in error logs an hour later, or when nobody can answer "what breaks if we change this API?"

The problem is invisible flow. Most systems have undeclared dependencies. APIs are consumed without formal registration. Events are subscribed to without the producer knowing. When anything changes, blast radius is unknown until something breaks.

---

## 4. Existing pattern equivalents and the gap this fills

| Pattern | Relationship |
|---|---|
| OpenAPI / AsyncAPI specification | Formats for documenting interfaces — this pattern adds bilateral obligation on top |
| Consumer-Driven Contract Testing (Pact) | Testing practice that enforces contracts — this pattern defines what contracts should cover |
| Schema Registry (Confluent, AWS Glue) | Storage and enforcement mechanism — this pattern defines the governance process around it |
| P02 Keystone Interface | Keystone interfaces need the most rigorous Nutrient Flow Contracts |

**The gap this fills:** existing tools document what an API does. This pattern adds the degradation contract — what happens downstream when it stops or changes.

---

## 5. What needs to happen

1. **Register every API and event schema.** Every interface that crosses a service boundary must be registered. No undeclared schemas in production.

2. **Add the degradation contract.** For each interface, document: what consuming services depend on it, what degrades in each consumer if it is unavailable, and what the acceptable degradation mode is (fail fast, cached fallback, graceful degradation).

3. **Register consumer dependencies.** Each consuming service declares which interfaces it depends on and which fields it actually uses. This is what enables safe schema evolution — if no consumer uses a field, it can be safely removed.

4. **Add schema compatibility checks to CI/CD.** On every deploy, validate that schema changes are compatible with all registered consumers. Breaking changes fail the build.

5. **Define deprecation windows.** When a schema version is deprecated, all registered consumers are notified. The window (minimum 30 days for internal, 90 days for external consumers) is enforced by the registry.

6. **Review the contract registry quarterly.** Dead consumers — services that have been decommissioned but not unregistered — create false obligations. Keep the registry clean.

---

## 6. Antipatterns and unhealthy versions

**The unregistered consumer:** a service consumes an API or event without registering. When the producer changes, it breaks silently.

> **Sign:** an incident post-mortem reveals a consuming service nobody knew existed.

**The stale contract:** a consumer registers its dependencies but never updates them. Over time the contract drifts from reality — fields listed as required have not been used in months.

> **Sign:** a producer wants to remove a field. The contract says a consumer needs it. The consumer team has no idea what field you are talking about.

**Contracts without enforcement:** a beautiful registry that nobody checks in CI. The documentation value is real but the protection value is zero.

> **Sign:** the registry is comprehensive and up to date, but breaking schema changes still reach production.

---

## 7. Architecture diagram

```
CONTRACT REGISTRY
─────────────────────────────────────────────────────────
Provider: order-service
  Event: order.placed (v2)
  Fields consumed by inventory-service: [orderId, items, warehouseId]
  Fields consumed by notifications-service: [orderId, customerId, amount]
  Fields consumed by fraud-service: [orderId, customerId, amount, ipAddress]
  Deprecation window: 30 days internal, 90 days external

ON DEPLOY (order-service changes schema):
  ┌─ Registry check ──────────────────────────────────┐
  │ Proposed change: remove field 'warehouseId'        │
  │ Registered consumers using this field: [inventory] │
  │ RESULT: FAIL — breaking change, migration required │
  └───────────────────────────────────────────────────┘
```

---

## 8. Related patterns

| Pattern | Relationship |
|---|---|
| P01 Mycelial Mesh | The mesh is what the contracts govern — events flowing between services |
| P02 Keystone Interface | Keystone interfaces need the strictest contracts and the longest deprecation windows |
| P03 Succession Stage Routing | The stage determines the compatibility rules enforced by the contract check |
| P11 Cascade Risk Detectors | Contract registry data shows which consumers would be affected by a failure |

---

## 9. Code snippet

```javascript
// Schema compatibility check — runs in CI/CD pipeline
// Reads registered consumer dependencies, fails on breaking changes
async function checkSchemaCompatibility(providerName, proposedSchema) {
  const registry = await loadContractRegistry();
  const contracts = registry.contracts.filter(c => c.provider === providerName);

  const violations = [];

  for (const contract of contracts) {
    for (const field of contract.requiredFields) {
      if (!proposedSchema.fields.includes(field)) {
        violations.push({
          consumer: contract.consumer,
          missingField: field,
          severity: 'BREAKING'
        });
      }
    }
  }

  if (violations.length > 0) {
    console.error('CONTRACT VIOLATION — breaking schema changes detected:');
    violations.forEach(v => {
      console.error(`  ${v.consumer} requires field '${v.missingField}' — cannot remove`);
    });
    console.error('Options: version the schema, or coordinate migration with consuming teams.');
    process.exit(1);
  }

  console.log(`Schema compatibility check passed — ${contracts.length} consumer contracts verified`);
}
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Interfaces with registered contracts | 100% of cross-boundary interfaces | Contract registry completeness |
| Unregistered consumers detected in traces | 0 | Trace data vs registry diff |
| Breaking schema changes reaching production | 0 | Incident post-mortem tags |
| Deprecation windows honoured | 100% | Registry deprecation audit |
| Stale contracts (consumer decommissioned) | 0 | Registry vs active service list |

---

## 12. What to look out for

Start with your highest-traffic interfaces first — the ones where a schema change would cause the most incidents. Getting 100% registry coverage immediately is unrealistic; getting the ten most critical interfaces registered in the first sprint is achievable and valuable. The fitness function value comes from completeness, so track coverage percentage as a metric and drive it toward 100% over time. A registry at 60% coverage still allows 40% of your interfaces to break silently.
