# Getting Started with the Service Manifest

The service manifest is how you register your service with the architectural health checks. It takes 5 minutes.

---

## Step 1: Copy the template

```bash
cp service-manifest.json your-service-manifest.json
```

Or if you're setting up at the repository root:

```bash
# Copy the template
cp service-manifest.json .

# Edit it
nano service-manifest.json
```

---

## Step 2: Fill in your service details

Edit the manifest and replace the placeholder service with your actual service:

```json
{
  "services": [
    {
      "name": "order-service",
      "domain": "checkout",
      "responsibilities": ["accept orders", "calculate totals"],
      "publicApiPaths": ["/orders", "/orders/:id"],
      "dependsOn": ["payment-service", "inventory-service"],
      "dependencyDomains": ["payments", "inventory"],
      "contractTests": ["payment-service"],
      "operationsPerDay": 50000,
      "owner": "checkout-team"
    }
  ]
}
```

**Key points:**
- **name**: Your service name (lowercase, hyphens OK)
- **domain**: The business domain (one word, one per service)
- **responsibilities**: What it does (aim for ≤ 3, or split with P05)
- **publicApiPaths**: All HTTP endpoints (no internal/db/impl in paths)
- **dependsOn**: Names of services you call
- **dependencyDomains**: Domains of those services (aim for ≤ 2)
- **operationsPerDay**: Realistic estimate (used to check for bottlenecks)
- **owner**: The team responsible

See [service-manifest-guide.md](service-manifest-guide.md) for full field definitions.

---

## Step 3: Validate

```bash
node docs/validate-manifest.js service-manifest.json
```

Expected output if everything passes:

```
✓ Manifest is valid

Services: 1
  - order-service (checkout domain, 50000 ops/day)

Validation checks:
  4 passed, 0 warnings

Ready for SCARS gate: node pattern-library/fitness-functions/scars-gate.js
```

If you see warnings like:

```
⚠️  order-service: 5 responsibilities (should be ≤ 3)
```

→ See the recommended pattern in the warning message for guidance.

---

## Step 4: Run the SCARS gate (optional, for testing)

```bash
node pattern-library/fitness-functions/scars-gate.js
```

This is the structural health check that runs in CI/CD. Your manifest should pass:

```
✓  S — Separation
✓  C — Cohesion
✓  A — Abstraction
✓  R — Responsibilities
✓  S — Simplify — no complexity warnings

━━━ PASSED ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SCARS gate clear. Proceeding to pattern fitness functions.
```

---

## Step 5: Commit and push

```bash
git add service-manifest.json
git commit -m "Register service manifest for SCARS gate"
git push
```

The manifest will be validated automatically in CI/CD before deployment.

---

## When to update

Update your manifest when:
- You add a new dependency
- You change your public API
- You split into multiple services (P05)
- You move to a different domain
- Your team name changes

The validator and SCARS gate will catch any violations.

---

## Examples

### A simple, well-structured service

```json
{
  "name": "notification-service",
  "domain": "comms",
  "responsibilities": ["send email", "send SMS"],
  "publicApiPaths": [
    "/notifications",
    "/notifications/preferences"
  ],
  "dependsOn": ["user-service"],
  "dependencyDomains": ["identity"],
  "contractTests": [],
  "operationsPerDay": 30000,
  "owner": "comms-team"
}
```

This passes all SCARS checks:
- ✓ 2 responsibilities (≤ 3)
- ✓ 1 dependency domain (≤ 2)
- ✓ No implementation details in API paths
- ✓ Only 1 dependency (< 5 is OK)

### A service that needs refactoring

```json
{
  "name": "god-service",
  "domain": "platform",
  "responsibilities": [
    "process payments",
    "send emails",
    "manage users",
    "generate reports",
    "handle returns"
  ],
  "publicApiPaths": [
    "/internal/db/query",
    "/raw/data",
    "/payments"
  ],
  "dependsOn": ["postgres", "redis", "kafka", "elasticsearch", "s3", "smtp"],
  "dependencyDomains": ["storage", "messaging", "search", "notifications", "auth"],
  "operationsPerDay": 200000,
  "owner": "platform-team"
}
```

This fails multiple SCARS checks:
- ✗ 5 responsibilities (limit: 3) → Use P05 Niche Partitioning
- ✗ 5 dependency domains (limit: 2) → Use P01 Mycelial Mesh
- ✗ Leaky API paths (/internal/db/query, /raw/data) → Use P02 Keystone Interface
- ✗ 40% of system load → Use P09 Carrying Capacity to monitor
- ✗ 6 dependencies → Consider events instead of direct calls

---

## Troubleshooting

**"Manifest is invalid"**
→ Check the error message, fix the syntax, and re-validate

**"Service has 5 responsibilities"**
→ Split the service using P05 Niche Partitioning

**"Depends on 5 domains"**
→ Replace synchronous calls with events using P01 Mycelial Mesh

**"API paths contain implementation details"**
→ Rename paths to be intention-revealing; use P02 Keystone Interface

See [service-manifest-guide.md](service-manifest-guide.md) for full troubleshooting.

---

## Reference

- [service-manifest-guide.md](service-manifest-guide.md) — Field definitions and examples
- [service-manifest-schema.json](service-manifest-schema.json) — JSON Schema
- [../pattern-library/fitness-functions/README.md](../pattern-library/fitness-functions/README.md) — SCARS gate details
- [../pattern-library/scars-diagnostic/README.md](../pattern-library/scars-diagnostic/README.md) — Fix violations
