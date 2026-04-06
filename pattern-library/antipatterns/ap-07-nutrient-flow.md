# AP-07 — Nutrient Flow Antipatterns

**Pattern this relates to:** [P07 Nutrient Flow](../patterns/p07-nutrient-flow/)
**Category:** Flow and Nutrient Cycling
**TL;DR:** APIs document what they do. They rarely document what degrades — in the business, for the user — if they stop. That missing information makes incident prioritisation guesswork and dependency decisions uninformed.

---

## The three ways this goes wrong

---

### AP-07-A: Undocumented Dependency Weight

**What it is:** An API exists, is called by multiple services, and its documentation covers the happy path. What the documentation does not cover: which downstream business capabilities depend on it, what user journeys fail if it is unavailable, and how quickly a degradation propagates to something a customer notices.

**Sign:** During an incident, the first question is always "who does this affect?" and the answer requires Slack archaeology.

**Why it happens:** API documentation is written by the team that builds the API, from the producer's perspective. The impact on consumers is the consumers' problem. Nobody owns the aggregate picture of "what breaks when this service breaks."

**What is missing from most API docs:**

```markdown
# GET /api/payments/status

Returns the current status of a payment.

Parameters: payment_id (string)
Returns: { status, amount, currency, created_at }
Rate limit: 1000 req/min

---
❌ What's missing — the nutrient flow view:

## Business impact if this endpoint degrades

| Consumer | User journey affected | Degradation type |
|---|---|---|
| checkout-service | Payment confirmation | Hard failure — checkout blocks |
| order-service | Order status page | Soft degradation — shows "pending" |
| notifications-service | Payment receipt email | Delayed — email queued, not blocked |
| finance-service | Daily reconciliation | Non-urgent — batched, retry ok |

Blast radius: HIGH — checkout is in the critical path.
SLA requirement: p99 < 200ms. Alert threshold: p95 > 150ms.
```

**The fix — P07 applied:** Every API that is consumed by more than one service includes a dependency weight declaration: which consumers, which journeys, what the degradation impact is, and how urgent recovery is. This is the information that makes incident prioritisation accurate and dependency decisions informed.

**Validated reference:** [Google SRE Book](https://sre.google/sre-book/) — Chapter 3, Risk and Error Budgets. Dependency documentation as part of service-level objectives. [Backstage TechDocs](https://backstage.io/docs/features/techdocs/) for service catalogue integration.

**SCARS lens:** Responsibilities — an API that does not document its downstream impact has not fully taken responsibility for its position in the ecosystem.

---

### AP-07-B: Black Box API

**What it is:** An API that accepts requests and returns responses, but provides no visibility into what it is doing internally, what its dependencies are, or what state it is in. When it degrades, consumers have no way to distinguish between "it's slow," "it's down," "its database is slow," or "it's throttling my requests."

**Sign:** When the API degrades, the first debugging step is always to contact the owning team and ask them to look at their logs.

**Why it happens:** Internal observability is treated as the API owner's problem. Consumers do not need to know what the API does internally — that's the point of encapsulation. The problem is that consumers do need to know why the API is failing when it fails.

**What a non-black-box API exposes:**
```json
// GET /health — standard for all services (P09)
{
  "status": "degraded",
  "version": "2.3.1",
  "timestamp": "2024-01-15T10:30:00Z",
  "dependencies": {
    "payments-database": { "status": "healthy", "latencyMs": 12 },
    "fraud-api": { "status": "degraded", "latencyMs": 1840, "note": "elevated latency" },
    "stripe": { "status": "healthy", "latencyMs": 89 }
  },
  "selfDiagnosis": "Degraded due to fraud-api latency. Payment status checks unaffected. Fraud screening for new payments delayed."
}
```

**The fix — P07 applied:** Health endpoints that surface the reason for degradation, not just the fact of it. Structured health responses that consumers can act on without contacting the owning team. Where the API's consumers are, what their impact is, and what is causing the current state — all visible without Slack.

**Validated reference:** [Health Check API pattern](https://microservices.io/patterns/observability/health-check-api.html) (microservices.io). [OpenTelemetry](https://opentelemetry.io/) — standardised observability. Richardson's Microservice Patterns — Observability patterns.

**SCARS lens:** Abstraction — a black box API has abstracted away too much. Encapsulation should hide implementation detail; it should not hide operational state.

---

### AP-07-C: Value Flow Opacity

**What it is:** The value that an API delivers — the business outcome it enables — is invisible in its technical contract. The API is documented as a technical interface with no connection to the business capability it enables. When it is proposed for deprecation, there is no business case for keeping it. When it is actually removed, something important breaks.

**Sign:** APIs are deprecated and removed based on traffic metrics alone. Something breaks that nobody expected.

**Why it happens:** APIs are designed and documented by engineers from a technical perspective. The connection between "this endpoint" and "this business outcome" is in product documentation, not in the API contract. The two are never linked.

**The fix — P07 applied:** API documentation includes a business capability declaration: what does this enable, what is the user or business outcome, and what is the cost of removing it? This is not a long document — it is a two-line addition to the API description that makes the dependency relationship explicit.

```yaml
# API capability declaration — added to OpenAPI spec
x-business-capability:
  enables: "Customer payment processing"
  user-journeys:
    - "Online checkout"
    - "Subscription renewal"
  removal-impact: "CRITICAL — blocks revenue"
  owner: "payments-product-team"
  last-reviewed: "2024-01-01"
```

**Validated reference:** [OpenAPI specification extensions](https://swagger.io/docs/specification/openapi-extensions/) — `x-` fields for custom metadata. [AsyncAPI](https://www.asyncapi.com/) — similar extension mechanism for event APIs. Product management practice of linking technical assets to business outcomes.

**SCARS lens:** Cohesion — an API whose technical contract is disconnected from its business purpose has low cohesion between implementation and intent.

---

## Fitness function

```yaml
name: Nutrient Flow Documentation Guard

checks:
  - name: High-traffic APIs have dependency weight declared
    query: |
      apis WHERE request_count_per_day > 1000 
      AND dependency_weight_declared = false
    fail_if: count > 0
    action: Add x-dependency-weight to API spec
    
  - name: Health endpoints expose dependency status
    query: services WHERE health_endpoint_exposes_dependencies = false
    fail_if: count > 0
    
  - name: APIs with multiple consumers have business capability declared
    query: |
      apis WHERE consumer_count > 3 
      AND x-business-capability IS NULL
    warn_if: count > 0
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-02 Keystone Without Runbook](ap-02-keystone-interface.md) | High-impact APIs are undeclared keystones without dependency weight docs |
| [AP-09 SLA Theatre](ap-09-carrying-capacity-monitors.md) | SLA Theatre and Black Box APIs compound — no internal visibility + wrong metrics |
| [AP-11 Invisible Blast Radius](ap-11-cascade-risk-detectors.md) | Undocumented dependency weight is the root cause of invisible blast radius |

---

*See also: [AP-README](README.md) for the full antipattern index.*
