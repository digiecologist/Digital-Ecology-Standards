# Service Manifest Guide

The `service-manifest.json` file is how your team tells the rest of the system about your service's structure. The SCARS gate reads it. Pattern fitness functions read it. Architecture tools read it.

**One file per repository. Maintained by the owning team.**

---

## Quick start

1. Copy `service-manifest.json` to your repository root
2. Fill in your service details (see field definitions below)
3. Run the SCARS gate: `node pattern-library/fitness-functions/scars-gate.js`
4. Commit the manifest alongside your code
5. Update it when your service changes (domain, dependencies, API paths)

---

## Field definitions

### Service-level fields

**name** (required)
- The name of your service
- Used in logs and error messages
- Example: `order-service`, `notification-api`, `scheduler`

**domain** (required)
- The business domain this service belongs to
- Used by the SCARS gate to check cross-domain coupling
- Examples: `checkout`, `payments`, `identity`, `comms`
- **Guideline:** Keep it to one word. If your service spans multiple domains, you may need to split it (P05)

**owner** (required)
- The team responsible for this service
- Used for escalation and context
- Example: `checkout-team`, `payments-platform`, `infra-team`

**responsibilities** (required)
- A list of what this service does
- **SCARS Separation check:** should have ≤ 3 items
- Keep them small and well-defined
- Examples:
  ```json
  "responsibilities": ["accept orders", "calculate totals"]
  ```
- If you have > 3, that's a signal to split the service (P05 Niche Partitioning)

**publicApiPaths** (required)
- All publicly exposed HTTP paths
- Used by the SCARS Abstraction check to detect leaked implementation details
- **SCARS check:** paths must not contain: `database`, `db`, `internal`, `impl`, `private`, `raw`, `direct`
- Examples:
  ```json
  "publicApiPaths": [
    "/orders",
    "/orders/:id",
    "/orders/:id/status"
  ]
  ```
- DO NOT include:
  ```json
  "publicApiPaths": [
    "/orders/internal/db/query",    // ❌ Contains "internal" and "db"
    "/raw/data",                     // ❌ Contains "raw"
  ]
  ```

**dependsOn** (required, can be empty array)
- Names of services or APIs you call
- Example:
  ```json
  "dependsOn": ["payment-service", "inventory-service", "user-service"]
  ```
- **Used by:** SCARS Simplify check (warns if > 5), P01 coupling guard
- If this list is getting long, consider switching to events (P01 Mycelial Mesh)

**dependencyDomains** (required)
- The domains of the services you depend on
- **SCARS Cohesion check:** should have ≤ 2 items
- Example:
  ```json
  "dependencyDomains": ["payments", "inventory"]
  ```
- If you're coupling to many domains, use events instead (P01)

**contractTests** (optional)
- Services you have Pact or similar contract tests for
- Used to track consumer-driven contract coverage
- Example:
  ```json
  "contractTests": ["payment-service", "inventory-service"]
  ```

**operationsPerDay** (required)
- Estimated number of operations/requests per day
- Used by SCARS Responsibilities check
- **SCARS check:** no single service should exceed 40% of system load
- Example: `50000` for a mid-tier service, `200000` for a core platform service
- If your service is approaching 40% of system load, you may be a bottleneck (P09, P05)

### Interface-level fields

For each API your service exposes, register it:

**name** (required)
- The logical name of the API
- Examples: `order-api`, `notification-api`, `user-auth-api`

**owner** (required)
- The team responsible for this API
- Usually the same as the service owner

**version** (required)
- The current version
- Examples: `v1`, `v2`, `beta`
- Used by P07 Nutrient Flow Contracts for deprecation tracking

**hasContractTests** (required)
- Boolean: whether you have consumer-driven contract tests (Pact) for this API
- `true` if consumers validate their expectations in CI
- `false` if not yet instrumented
- Used by P07 and P02 Keystone Interface checks

---

## Examples

### Minimal valid manifest

```json
{
  "services": [
    {
      "name": "order-service",
      "domain": "checkout",
      "responsibilities": ["accept orders", "validate cart"],
      "publicApiPaths": ["/orders", "/orders/:id"],
      "dependsOn": ["user-service", "payment-service"],
      "dependencyDomains": ["identity", "payments"],
      "contractTests": ["payment-service"],
      "operationsPerDay": 50000,
      "owner": "checkout-team"
    }
  ]
}
```

### With interfaces registered

```json
{
  "services": [
    {
      "name": "notification-service",
      "domain": "comms",
      "responsibilities": ["send email", "send SMS"],
      "publicApiPaths": [
        "/notifications",
        "/notifications/preferences",
        "/notifications/status/:id"
      ],
      "dependsOn": ["user-service", "template-service"],
      "dependencyDomains": ["identity"],
      "contractTests": [],
      "operationsPerDay": 30000,
      "owner": "comms-team"
    }
  ],
  "interfaces": [
    {
      "name": "notification-api",
      "owner": "comms-team",
      "version": "v2",
      "hasContractTests": true
    }
  ]
}
```

---

## Updating the manifest

**When to update:**
- You add a new dependency
- You change your public API
- You move to a different domain
- You split your responsibilities (P05)
- You change your team ownership

**How to update:**
1. Edit `service-manifest.json`
2. The SCARS gate will run on your next deploy
3. Fix any violations before merging
4. Commit the updated manifest with your code

**Who can update:**
- The team that owns the service (no pull request required)
- Architecture team can validate that updates are accurate

---

## How it's used

### SCARS Gate (runs first in CI/CD)

```bash
node pattern-library/fitness-functions/scars-gate.js
```

Checks:
- **name**: Is it set? (validation)
- **responsibilities**: ≤ 3? (Separation check)
- **publicApiPaths**: No leaked implementation terms? (Abstraction check)
- **dependencyDomains**: ≤ 2? (Cohesion check)
- **operationsPerDay**: No single service > 40%? (Responsibilities check)
- **dependsOn**: > 5 dependencies? (Simplify warning)

### Pattern fitness functions

- **P01 Coupling Guard:** Uses `dependsOn` and `dependencyDomains`
- **P02 Keystone Detector:** Uses `publicApiPaths` and dependencies
- **P07 Contract Registry:** Uses `contractTests` and `interfaces`
- **P09 Carrying Capacity:** Uses `operationsPerDay`
- **P11 Cascade Risk:** Uses `dependsOn` (fan-in calculation)

### Architecture tools

- Backstage / internal developer platforms can read this to visualize your topology
- Incident response can use `owner` and `dependsOn` to find blast radius
- Quarterly architecture reviews can track domain evolution

---

## Common mistakes

**Having > 3 responsibilities**
```json
"responsibilities": [
  "process payments",
  "send receipts",
  "generate reports",
  "handle refunds",
  "manage subscriptions"
]
```
❌ Too many. Split into separate services → P05 Niche Partitioning

**Leaking implementation into API paths**
```json
"publicApiPaths": [
  "/api/internal/database/query",
  "/api/raw/events",
  "/api/impl/cache/peek"
]
```
❌ Consumers now depend on your internals. Fix → P02 Keystone Interface

**High cross-domain coupling**
```json
"dependencyDomains": ["payments", "inventory", "notifications", "search", "analytics"]
```
❌ Coupled to 5 different domains. Decouple with events → P01 Mycelial Mesh

**Underestimating operationsPerDay**
```json
"operationsPerDay": 1000
```
This service actually handles 100,000+ operations. Use realistic numbers for SCARS Responsibilities check to trigger if you're becoming a bottleneck.

---

## Template

Copy the template at the repository root:

```bash
cp service-manifest.json your-service-manifest.json
```

Then fill in your service details and run the SCARS gate to validate:

```bash
node pattern-library/fitness-functions/scars-gate.js
```

---

## Questions?

- See [../pattern-library/fitness-functions/README.md](../pattern-library/fitness-functions/README.md) for SCARS gate details
- See [../pattern-library/scars-diagnostic/README.md](../pattern-library/scars-diagnostic/README.md) for how to fix violations
- Reference the patterns: P01, P02, P05, P07, P09, P11
