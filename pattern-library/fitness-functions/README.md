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

### Example

See [../service-manifest-example.json](../service-manifest-example.json) for a complete example showing four services that pass all SCARS checks.

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

---

# P02 Keystone Detector

**Category:** Pattern-Specific Check | **Prerequisite:** SCARS Gate must pass | **Runs:** After SCARS in CI/CD pipeline

---

## What it does

Identifies **keystone interfaces** — the APIs, databases, and shared libraries that multiple services depend on. If a keystone interface changes or fails, it takes multiple other services with it.

The detector tracks:
- Which interfaces are keystones (≥3 dependents)
- Contract test coverage from all dependents
- Ownership registration

A keystone interface without contract test coverage from all its dependents will **fail the build**. Unowned keystones trigger a **warning only** (does not fail).

---

## Why this matters

Keystone interfaces are critical points of failure. When `user-service` changes its schema and only 1 of 3 dependents has contract tests, you find out about the break at runtime, not at build time.

Contract tests (Pact recommended) catch breaking changes before they reach production.

---

## How to run it

```bash
node pattern-library/fitness-functions/p02-keystone-detector.js
```

With a custom dependency graph:

```bash
DEPENDENCY_SOURCE=manifest node pattern-library/fitness-functions/p02-keystone-detector.js --manifest ./path/to/manifest.json
```

---

## Configuration

Edit thresholds in `p02-keystone-detector.js`:

```javascript
const CONFIG = {
  // An interface with this many or more dependents is a keystone
  KEYSTONE_THRESHOLD: 3,

  // A keystone without contract tests → build fails
  CONTRACT_TEST_REQUIRED_ABOVE: 3,

  // A keystone without a registered owner → warning only
  OWNER_REQUIRED_ABOVE: 2,
};
```

---

## Data source: Dependency Graph

The detector builds a dependency graph from your services:

```json
{
  "services": [
    {
      "name": "order-service",
      "dependsOn": ["payment-api", "inventory-api", "user-service"],
      "contractTests": ["payment-api", "inventory-api", "user-service"],
      "owner": "checkout-team"
    }
  ],
  "interfaces": [
    {
      "name": "payment-api",
      "owner": "payments-team",
      "hasContractTests": true,
      "version": "v2"
    }
  ]
}
```

---

## Understanding violations

### Contract Test Violation

**What it means:** A keystone interface is depended on by multiple services, but not all have consumer-driven contract tests.

**Example:**
```
✗ Contract test violations
  user-service: 3 dependent(s) have no contract tests
  Untested: order-service, fulfilment-service, returns-service
  → Add consumer-driven contract tests (Pact recommended)
```

**Fix:**
- Add contract tests to the untested dependents
- Use [Pact](https://docs.pact.io/), [Prism](https://stoplight.io/prism/), or similar
- For each dependent service, define a consumer contract that `user-service` provider validates against
- Example: `order-service/test/contracts/user-service.pact.json`

### Ownership Warning

**What it means:** A keystone interface has no registered owner, making accountability unclear.

**Example:**
```
⚠  Ownership warnings
  user-service: 4 dependents, no registered owner
  → Register an owner in service-manifest.json
```

**Fix:**
- Identify the team responsible for the interface
- Update the interface definition to include `owner: "team-name"`
- Owner becomes the escalation point for breaking changes

---

## Interpreting results

### PASSED

All keystones have registered owners and full contract test coverage.

```
✓  Contract tests: all keystones have coverage

Summary: 2 keystone interface(s) identified across 4 total

━━━ PASSED ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

→ Build continues to next pattern fitness function.

### FAILED

At least one keystone lacks contract test coverage. Build stops.

```
✗  Contract test violations
  inventory-api: 2 dependent(s) have no contract tests
  Untested: order-service, returns-service

Summary: 2 keystone interface(s) identified across 4 total

━━━ FAILED ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

→ Add contract tests to untested dependents, then retest.

---

## Resolving contract test gaps

**Step 1:** Identify which services need contract tests
The detector shows: `Untested: order-service, returns-service`

**Step 2:** Choose a contract testing framework
- **Pact** (recommended for microservices): Consumer → Provider
- **Spring Cloud Contract**: Provider → Consumer
- **OpenAPI mocks**: Quick validation before full CDC

**Step 3:** Write consumer contract for one untested dependent

Example (Pact):
```javascript
// order-service/test/contracts/user-service.test.js
const { Pact, Matchers } = require('@pact-foundation/pact');

const provider = new Pact({
  consumer: 'order-service',
  provider: 'user-service',
});

describe('user-service API', () => {
  it('returns user details', () => {
    return provider
      .addInteraction({
        state: 'user 123 exists',
        uponReceiving: 'a request for user details',
        withRequest: { method: 'GET', path: '/users/123' },
        willRespondWith: {
          status: 200,
          body: {
            id: Matchers.uuid(),
            email: Matchers.email(),
          },
        },
      })
      .then(() => {
        // Test your order-service consumer code
      });
  });
});
```

**Step 4:** Register contract in manifest

```json
{
  "name": "order-service",
  "contractTests": ["payment-api", "inventory-api", "user-service"],
  "owner": "checkout-team"
}
```

**Step 5:** Re-run keystone detector
Should now pass.

---

## Integration with CI/CD

### Workflow order

The keystone detector runs **after** SCARS gate:

```
1. SCARS Gate             ← structural foundation
2. P02 Keystone Detector  ← dependency contract coverage
3. [other pattern checks]
4. → Deploy
```

### GitHub Actions example

Uncomment this in `.github/workflows/ecological-health.yml`:

```yaml
- name: '[P02] Keystone Detector'
  run: node pattern-library/fitness-functions/p02-keystone-detector.js
```

---

## Related patterns

- **[P01 Mycelial Mesh](../patterns/p01-mycelial-mesh/):** Break synchronous dependencies on keystones using event flows
- **[P05 Niche Partitioning](../patterns/p05-niche-partitioning/):** Clear domain boundaries prevent accidental keystones from forming
- **[P11 Cascade Risk Detectors](../patterns/p11-cascade-risk-detectors/):** Runtime monitoring of keystone failure propagation

---

## Common questions

**Q: Can a service depend on another without a contract test if they're in the same team?**
A: Still add contract tests. Same-team dependencies are actually more dangerous (looser communication) than cross-team. Contract tests are the written agreement.

**Q: What if we have partial contract coverage?**
A: The detector reports untested dependents by name. Add tests for those specific consumers first.

**Q: Should every interface be a keystone?**
A: No. Keystones are interfaces with ≥3 dependents. Most interfaces shouldn't have that many dependents; if they do, consider domain boundaries (P05).

**Q: How do we discover dependencies automatically?**
A: You can extend the detector to read from your service mesh (Istio, Linkerd) or build tool (Gradle, Maven). For now, service teams maintain `contractTests` in their manifest entries.
