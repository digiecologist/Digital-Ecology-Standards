# SCARS Gate Fitness Function

**Category:** Structural Health Check | **Runs:** First in CI/CD pipeline | **Based on:** Ruth Malan's SCARS heuristics

---

## What it does

The SCARS gate is a structural health check that runs **before** all pattern-specific fitness functions. It asks five questions about your architecture:

- **S — Separation:** Does each service do one well-defined thing?
- **C — Cohesion:** Do services that depend on each other stay within the same 1–2 domains?
- **A — Abstraction:** Are implementation details hidden from the public API?
- **R — Responsibilities:** Is system load distributed, or is one service carrying everything?
- **S — Simplify:** Is the dependency graph actually becoming simpler?

If any of the first four checks fail, the build fails. Simplify violations are warnings only.

---

## Pipeline order

Run the SCARS gate **first** in your CI/CD pipeline, before pattern-specific checks:

```
1. scars-gate.js                         ← structural questions first
2. p01-coupling-guard.js                 ← then pattern-specific gates
3. p02-keystone-detector.js
4. p03-schema-drift-check.js
5. [other pattern fitness functions]
6. → Deploy (if all gates pass)
```

---

## How to run it

```bash
node pattern-library/fitness-functions/scars-gate.js
```

With a custom service manifest:

```bash
MANIFEST_PATH=./path/to/service-manifest.json node pattern-library/fitness-functions/scars-gate.js
```

Or with real data source (not mock):

```bash
SCARS_SOURCE=real node pattern-library/fitness-functions/scars-gate.js
```

---

## Configuration

Edit the thresholds in `scars-gate.js` to match your system's acceptable bounds:

```javascript
const CONFIG = {
  MAX_RESPONSIBILITIES_PER_SERVICE: 3,    // Separation threshold
  MAX_DOMAINS_PER_SERVICE: 2,             // Cohesion threshold
  MAX_OPERATION_SHARE: 0.40,              // Responsibilities (40% = fail)
  DEPENDENCY_COUNT_WARNING: 5,            // Simplify warning threshold
};
```

---

## Data source: Service Manifest

The gate reads from `service-manifest.json`. Each service team maintains this file describing their service's structure:

```json
{
  "services": [
    {
      "name": "order-service",
      "domain": "checkout",
      "responsibilities": ["accept orders", "validate cart", "apply promotions"],
      "publicApiPaths": ["/orders", "/orders/:id", "/orders/:id/status"],
      "dependsOn": ["payment-api", "inventory-api", "user-service"],
      "dependencyDomains": ["payments", "inventory"],
      "operationsPerDay": 50000,
      "owner": "checkout-team"
    }
  ]
}
```

### Schema definition

See `docs/service-manifest-schema.json` for the full schema and validation rules.

### Who maintains it?

Each service team is responsible for their own entry in the manifest. The gate reads these entries at deploy time and checks them against the SCARS rules.

---

## Understanding violations

### S — Separation violation

**What it means:** A service is trying to do more than one well-defined thing.

**Example:**
```
Service: god-service
Responsibilities: [process payments, send emails, manage users, generate reports, handle returns]
Threshold: 3
```

**Fix:**
- Split by responsibility domain using [P05 Niche Partitioning](../patterns/p05-niche-partitioning/)
- Move each responsibility to a focused service
- Example: move "send emails" to a dedicated notification service

---

### C — Cohesion violation

**What it means:** A service has dependencies that span multiple unrelated domains, making it fragile to domain changes.

**Example:**
```
Service: order-service
Dependency domains: [payments, inventory, notifications, search, auth]
Threshold: 2
```

**Fix:**
- Use [P01 Mycelial Mesh](../patterns/p01-mycelial-mesh/) to decouple cross-domain calls
- Replace synchronous calls with event flows
- Example: instead of calling `notification-service.send()` directly, publish an `order.placed` event

---

### A — Abstraction violation

**What it means:** Your public API contains words that reveal internal implementation (database, internal, impl, raw, direct, etc.).

**Example:**
```
Service: legacy-service
Leaky paths: [/internal/db/query, /raw/data, /impl/cache]
```

**Fix:**
- Use [P02 Keystone Interface](../patterns/p02-keystone-interface/) to define intention-revealing contracts
- Replace `/internal/db/query` with `/entities` or similar domain concept
- Version your API; deprecate the leaky versions

---

### R — Responsibilities violation

**What it means:** One service is handling disproportionate load, becoming a bottleneck and single point of failure.

**Example:**
```
Service: payment-gateway
Load share: 71.4% of system operations
Threshold: 40%
```

**Fix:**
- Use [P09 Carrying Capacity Monitors](../patterns/p09-carrying-capacity-monitors/) to track load
- Use [P05 Niche Partitioning](../patterns/p05-niche-partitioning/) to distribute responsibility
- Example: move payment processing to a dedicated queue; payment-gateway becomes a router

---

### S — Simplify warning

**What it means:** A service has many dependencies, making it hard to reason about and test.

**Note:** This is a warning only, not a build failure. But it's a signal to investigate.

**Example:**
```
Service: orchestrator
Dependencies: [postgres, redis, kafka, elasticsearch, s3, smtp]
Threshold (warning): 5
```

**Fix:**
- Review whether each dependency is truly needed
- Can any be replaced with event subscriptions?
- Can any be extracted to a separate service?

---

## Interpreting results

### PASSED

All four hard checks passed (Separation, Cohesion, Abstraction, Responsibilities). Simplify warnings may exist — address them in the next sprint.

```
✓ S — Separation
✓ C — Cohesion
✓ A — Abstraction
✓ R — Responsibilities
⚠ S — Simplify — 1 service(s) to review
```

→ Build continues to pattern-specific fitness functions.

### FAILED

At least one hard check failed. The build stops here. Resolve violations before attempting to deploy.

```
✗ S — Separation — 1 violation
✗ C — Cohesion — 0 violations
✗ A — Abstraction — 1 violation
✗ R — Responsibilities — 0 violations
```

→ Build fails. Fix violations, then re-run.

---

## Integration with your CI/CD

### GitHub Actions

```yaml
name: Structural Health Check
on: [pull_request]
jobs:
  scars-gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: node pattern-library/fitness-functions/scars-gate.js
```

### GitLab CI

```yaml
scars-gate:
  script:
    - node pattern-library/fitness-functions/scars-gate.js
```

### Jenkins

```groovy
stage('SCARS Gate') {
  steps {
    sh 'node pattern-library/fitness-functions/scars-gate.js'
  }
}
```

---

## Updating thresholds

As your system matures, you may need to tighten thresholds:

| Maturity | Separation | Cohesion | Operation Share | Dependencies |
|---|---|---|---|---|
| Early-stage | 5 | 3 | 50% | 8 |
| Growing | 4 | 2 | 45% | 6 |
| Mature | 3 | 2 | 40% | 5 |

Update `CONFIG` in `scars-gate.js` as your architectural standards evolve.

---

## Common questions

**Q: Why does the gate fail on warnings?**
A: Separation, Cohesion, Abstraction, and Responsibilities violations create structural fragility. "Simplify" is a warning because extra dependencies are slower to change but not always wrong.

**Q: Can I override the gate?**
A: Yes, but document why in the PR. The gate is meant to surface decisions, not prevent them. If you need to override, create an issue explaining the trade-off and plan a refactoring window.

**Q: Should we use this gate alone?**
A: No. SCARS is the first check. It identifies structural problems. Pattern-specific fitness functions (P01, P02, etc.) provide detailed guidance on fixing them.

**Q: How often should we tighten thresholds?**
A: Every 6 months, review whether thresholds match your AC (Adaptive Capacity) score. Rising AC score means you can tighten thresholds.

---

## References

- **Ruth Malan's SCARS:** [https://ruthmalan.com](https://ruthmalan.com)
- **SCARS Diagnostic:** [../scars-diagnostic/README.md](../scars-diagnostic/README.md)
- **Patterns this gate connects to:** P01, P02, P05, P09
