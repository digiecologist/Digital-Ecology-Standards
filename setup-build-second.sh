#!/bin/bash
# =============================================================
# Ecological Engineering Standards — BUILD SECOND Patterns
# Adds P03, P07, P10, P15, P16, P18
# Run from inside your cloned repository: bash setup-build-second.sh
# =============================================================
set -e
echo "Adding BUILD SECOND patterns..."

# ── P03 ────────────────────────────────────────────────────────
mkdir -p pattern-library/patterns/p03-symbiotic-contracts/code-examples
mkdir -p pattern-library/patterns/p03-symbiotic-contracts/fitness-functions

cat > pattern-library/patterns/p03-symbiotic-contracts/README.md << 'EOF'
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
EOF

# ── P07 ────────────────────────────────────────────────────────
mkdir -p pattern-library/patterns/p07-nutrient-flow/code-examples
mkdir -p pattern-library/patterns/p07-nutrient-flow/fitness-functions

cat > pattern-library/patterns/p07-nutrient-flow/README.md << 'EOF'
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
EOF

# ── P10 ────────────────────────────────────────────────────────
mkdir -p pattern-library/patterns/p10-biodiversity-index-checks/code-examples
mkdir -p pattern-library/patterns/p10-biodiversity-index-checks/fitness-functions

cat > pattern-library/patterns/p10-biodiversity-index-checks/README.md << 'EOF'
# P10 — Biodiversity Index Checks

**Category:** Warning Signs & Triggers | **Build priority:** BUILD SECOND | **Complexity:** Low
**AC score contribution:** Technical AC (T-AC)

> **Relationship to P20:** P20 (Biodiversity Index) defines the scoring framework and quarterly strategic review. P10 operationalises it as automated CI/CD checks that fire at the moment technology decisions are made.

---

## 1. What this pattern is

A healthy ecosystem maintains diversity at the right level for its conditions. When conditions change — climate, predators, disease — the diversity is what gives the ecosystem options to respond. A monoculture has no options.

Biodiversity Index Checks are the automated layer that surfaces monoculture risk at the moment a technology decision is being made, not six months later in a quarterly review. They run in CI/CD pipelines and in architecture review tooling, flagging when a new dependency would push vendor concentration past a threshold, or when a technology choice would reduce diversity below the level appropriate for that capability's maturity stage.

---

## 2. The value it brings

- Vendor concentration risk is caught before it becomes a commitment, not after
- Technology choices are made with explicit diversity context, not intuition
- The Biodiversity Index (P20) score stays current between quarterly reviews
- Teams get a nudge at decision time rather than a retrospective finding

---

## 3. The problem it solves

You know you need this pattern when technology decisions are made without anyone checking the cumulative vendor concentration effect, or when your quarterly Biodiversity Index review always finds the same drift that nobody noticed accumulating.

The problem is that diversity erosion happens one decision at a time. Each individual "use the same vendor" choice seems locally rational. The cumulative effect — total dependence on a single cloud provider, a single database vendor, a single identity service — is only visible in aggregate. By the time the quarterly review surfaces it, the commitment is already made.

---

## 4. Existing pattern equivalents and the gap this fills

| Pattern | Relationship |
|---|---|
| P20 Biodiversity Index | Strategic scoring framework — P10 is the operational check layer that keeps P20 current in real time |
| Dependency analysis tools | Show what you depend on — P10 adds the risk scoring and threshold alerting on top |
| Architecture decision records (ADRs) | Document decisions after the fact — P10 injects diversity context into the decision process |

---

## 5. What needs to happen

1. **Wire the Biodiversity Index calculator into your ADR process.** When a team creates an ADR that introduces a new technology dependency, the check runs automatically and shows the current vendor concentration score before and after the proposed change.

2. **Add vendor concentration checks to infrastructure-as-code CI.** When a Terraform, CloudFormation, or Helm change is proposed, check whether it increases vendor concentration in a critical capability past a defined threshold.

3. **Define thresholds per capability category:**
   - Commodity capabilities: > 80% single-vendor concentration = fail
   - Product capabilities: > 60% single-vendor = warn
   - Genesis capabilities: no concentration check (exploration is expected)

4. **Automate the P20 score refresh.** After each merged change, recalculate the Biodiversity Index score so the quarterly review starts from current data, not stale data.

5. **Add diversity nudges to your technology radar or internal catalogue.** When an engineer searches for a technology, surface the current concentration score for that category alongside the results.

---

## 6. Antipatterns and unhealthy versions

**Check without context:** a binary pass/fail with no explanation. Engineers override it because they do not understand why it fired.

> **Sign:** your override rate for biodiversity checks is above 40%.

**Commodity threshold applied everywhere:** Genesis-stage capabilities correctly have high concentration (you are converging on what works). Failing those checks generates noise that drowns out the real commodity-lock-in signals.

> **Sign:** your most active experimental teams have the highest check failure rate, not your most locked-in infrastructure teams.

---

## 7. Architecture diagram

```
ADR CREATION FLOW
──────────────────────────────────────────────────────────
Engineer proposes: "Use AWS Cognito for authentication"
                        │
                        ▼
        BIODIVERSITY CHECK RUNS
        ─────────────────────────────────────────────
        Capability: Authentication
        Current stage: Product
        Current options: 1 (Auth0 only)
        Proposed change: adds AWS Cognito

        Before: 1 option (score: 60 — some vendor risk)
        After:  2 options (score: 100 — strategic diversity)

        ✅ PASS — this change IMPROVES biodiversity
        ─────────────────────────────────────────────

        (If proposal was a second AWS service instead)
        ❌ WARN — AWS concentration in Product capabilities
           now at 75%. Threshold: 60%.
```

---

## 8. Related patterns

| Pattern | Relationship |
|---|---|
| P20 Biodiversity Index | The strategic scoring framework P10 operationalises |
| P18 Diversity Nudge Engine | Surfaces monoculture risk in the UI at decision time — P10 is the CI/CD equivalent |
| P03 Succession Stage Routing | Stage classification determines which nudges are relevant and what thresholds apply |

---

## 9. Code snippet

```javascript
// Biodiversity check — runs on infrastructure PRs and ADR creation
async function checkVendorConcentration(proposedChange, registry) {
  const capability = proposedChange.capabilityCategory;
  const stage = registry.getStage(capability);

  // Genesis stage: no concentration check — exploration is correct
  if (stage === 'genesis') {
    console.log(`${capability} is Genesis stage — diversity check skipped (exploration expected)`);
    return { pass: true };
  }

  const currentOptions = registry.getVendorOptions(capability);
  const afterChange = [...new Set([...currentOptions, proposedChange.vendor])];
  const concentration = 1 / afterChange.length;

  const thresholds = { commodity: 0.5, product: 0.6, custom: 0.8 };
  const threshold = thresholds[stage] || 0.7;

  if (concentration > threshold) {
    return {
      pass: false,
      message: `Vendor concentration for ${capability} (${stage} stage) would reach ${Math.round(concentration * 100)}% — threshold: ${Math.round(threshold * 100)}%`,
      recommendation: `Consider adding an alternative vendor or abstraction layer for ${capability}`
    };
  }

  return { pass: true, message: `Vendor concentration within threshold after change` };
}
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Commodity capabilities with > 80% single-vendor concentration | 0 | Biodiversity check registry |
| Check override rate | < 20% | CI/CD override log |
| Biodiversity Index score currency | Updated within 7 days of last infra change | Score timestamp |
| Technology decisions with explicit diversity context documented | > 80% | ADR audit |

---

## 12. What to look out for

The most common failure is applying the same threshold to all capability stages, generating noise at Genesis stage that trains teams to ignore the checks entirely. Stage-aware thresholds are non-negotiable. Start with commodity capabilities only if you want to build trust in the checks before expanding scope. A check with a 20% override rate is providing some value. A check with an 80% override rate is providing negative value — it is training people to ignore warnings.
EOF

# ── P15 ────────────────────────────────────────────────────────
mkdir -p pattern-library/patterns/p15-symbiotic-dependency-design/code-examples
mkdir -p pattern-library/patterns/p15-symbiotic-dependency-design/fitness-functions

cat > pattern-library/patterns/p15-symbiotic-dependency-design/README.md << 'EOF'
# P15 — Symbiotic Dependency Design

**Category:** Adaptive & Regenerative | **Build priority:** BUILD SECOND | **Complexity:** Medium
**AC score contribution:** Technical AC (T-AC) + Organisational AC (O-AC)

> **Prerequisite:** P01 Mycelial Mesh. This pattern audits and designs the relationships between mesh participants — distinguishing the ones that benefit both sides from the ones that drain one side silently.

---

## 1. What this pattern is

In ecology, symbiosis describes organisms living in close association. The most valuable relationships are mutualistic — both parties benefit. A cleaner fish removes parasites from a larger fish; both gain. Mycorrhizal fungi exchange nutrients with tree roots; both gain.

But symbiosis also includes parasitic relationships — one organism benefits at the expense of another. The parasite is often invisible. The host just gradually weakens.

Software services form the same types of relationships. A mutualistic dependency is one where both services benefit from the connection — each provides something the other needs, both are more capable together than apart. A parasitic dependency is one where one service extracts value from another without giving back — it consumes the provider's capacity, schema stability, and engineering attention without contributing anything in return.

Symbiotic Dependency Design makes these relationships explicit: name them, measure them, and systematically eliminate the parasitic ones.

---

## 2. The value it brings

- Parasitic dependencies are identified and eliminated before they become structural debt
- Mutualistic relationships are made explicit and protected
- Teams understand the real cost of their dependencies, not just their functional value
- Dependency refactoring is prioritised based on relationship quality, not just coupling score
- The system evolves toward genuinely cooperative architecture rather than extractive architecture

---

## 3. The problem it solves

You know you need this pattern when one team's service is constantly being called by many others but gets nothing useful back from those calls — their service becomes a support burden without any architectural reciprocity. Or when a consuming service is so deeply integrated with a provider that any change to either requires coordinating both.

The problem is unnamed relationships. Most dependency graphs show connections but not their quality. High fan-in might be a sign of a genuinely valuable shared service (mutualistic) or a sign of a service that has accumulated dependents because it was convenient, not because it is the right home for that capability (parasitic accumulation).

---

## 4. Existing pattern equivalents and the gap this fills

| Pattern | Relationship |
|---|---|
| Dependency inversion principle | A design principle for decoupling — this pattern adds the relationship quality dimension on top |
| P11 Cascade Risk Detectors | Identifies high-risk dependencies by fan-in and depth — this pattern identifies low-quality dependencies by relationship type |
| P02 Keystone Interface | Keystones are high-fan-in services — this pattern helps identify which of those relationships are mutualistic vs parasitic |

**The gap this fills:** existing tools measure dependency quantity (fan-in, fan-out, coupling score). This pattern measures dependency quality — whether the relationship is genuinely mutually beneficial or extractive.

---

## 5. What needs to happen

1. **Map and classify every cross-service dependency.** For each dependency, label it as one of:
   - *Mutualistic:* both services benefit — each provides something the other needs
   - *Commensal:* one benefits, the other is unaffected — acceptable but watch for drift toward parasitic
   - *Parasitic:* one benefits at the expense of the other — the provider carries cost without receiving value

2. **Identify the parasitic dependencies.** Signs of a parasitic relationship: the provider team spends significant support time on this consumer; the consumer uses only a tiny fraction of the provider's capability; the consumer requires the provider to maintain backward compatibility indefinitely for no architectural reason; the connection exists for historical reasons, not current need.

3. **Design toward mutualism.** For each parasitic relationship, identify what would make it mutualistic: could the consuming service provide something back? Could the capability be moved closer to where it is actually used? Could the dependency be eliminated by redesigning the flow?

4. **Add relationship quality to architecture reviews.** Every new cross-service dependency requires a relationship classification at creation time. "What does each side get from this relationship?" should be a standard review question.

5. **Track relationship quality over time.** Mutualistic relationships that drift toward parasitic as services evolve are common. Review classification annually.

---

## 6. Antipatterns and unhealthy versions

**The utility service trap:** a service that was designed as a shared utility gradually accumulates so many consumers with so many different needs that it becomes a mini-monolith. Each consumer relationship started as commensual and drifted parasitic as the utility bent itself to serve each consumer's specific requirements.

> **Sign:** the utility service team spends more time managing consumer requests and backward compatibility than building new capability.

**Mutualism by declaration:** labelling a dependency mutualistic because both teams like each other, not because the architecture is genuinely reciprocal.

> **Sign:** when asked "what does the provider get from this relationship?", the answer is "we appreciate their partnership."

---

## 7. Architecture diagram

```
DEPENDENCY RELATIONSHIP AUDIT

Service A ──────────────► Service B
  "A calls B for user profile data"

Classification questions:
  Does B benefit from A calling it?
  → B gets no value from serving A's requests — it's pure cost
  → Relationship type: PARASITIC (A benefits, B carries cost)

  What would make this mutualistic?
  → A could share behavioural data B needs for its own analytics
  → Or: move the user profile data A needs into A's own domain
  → Or: formalise B as a platform service with explicit SLA and cost recovery

MUTUALISTIC EXAMPLE:
Service C ◄──────────────► Service D
  "C provides order data to D; D provides fraud scores to C"
  Both services are more capable together than apart.
  Relationship type: MUTUALISTIC ✓
```

---

## 8. Related patterns

| Pattern | Relationship |
|---|---|
| P01 Mycelial Mesh | The mesh reduces parasitic synchronous dependencies by making relationships explicit through events |
| P05 Niche Partitioning | Clear domain ownership reduces accidental parasitic dependencies caused by unclear boundaries |
| P11 Cascade Risk Detectors | High cascade risk often correlates with parasitic dependency accumulation |

---

## 9. Code snippet

```yaml
# dependency-relationships.yml — relationship quality registry
# Maintained alongside the service registry

dependencies:
  - provider: user-service
    consumer: order-service
    type: commensal
    justification: "order-service reads user profile; user-service gets nothing back"
    review-date: 2025-01-15
    action: "Evaluate moving user fields order-service needs into order domain"

  - provider: fraud-service
    consumer: order-service
    type: mutualistic
    justification: "fraud-service provides risk scores; order-service provides transaction data fraud-service needs"
    review-date: 2025-01-15
    action: "Protect this relationship — both sides need it"

  - provider: legacy-config-service
    consumer: twelve-other-services
    type: parasitic
    justification: "config-service carries all backward compatibility cost; consumers get config data cheaply"
    review-date: 2025-01-15
    action: "Migrate config consumers to environment variables over next 2 quarters"
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Classified dependencies | 100% of cross-boundary dependencies | Relationship registry completeness |
| Parasitic dependencies | Decreasing trend | Registry audit quarterly |
| Provider services with > 20% support time from consumer requests | 0 | Team time tracking |
| New dependencies created without relationship classification | 0 | PR review checklist |

---

## 12. What to look out for

Relationship classification requires honesty from both teams involved — the consuming team must admit when they are extracting value without giving back, and the providing team must admit when they are enabling parasitic relationships for political reasons. This is a cultural challenge as much as a technical one. The most effective approach is to make the audit a joint exercise with both teams present, facilitated by someone neutral, with the explicit goal of finding improvements rather than assigning blame.
EOF

# ── P16 ────────────────────────────────────────────────────────
mkdir -p pattern-library/patterns/p16-succession-gates/code-examples
mkdir -p pattern-library/patterns/p16-succession-gates/fitness-functions

cat > pattern-library/patterns/p16-succession-gates/README.md << 'EOF'
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
EOF

# ── P18 ────────────────────────────────────────────────────────
mkdir -p pattern-library/patterns/p18-regenerative-cycles/code-examples
mkdir -p pattern-library/patterns/p18-regenerative-cycles/fitness-functions

cat > pattern-library/patterns/p18-regenerative-cycles/README.md << 'EOF'
# P18 — Diversity Nudge Engine

**Category:** In-built Nudges & Behavioural Design | **Build priority:** BUILD SECOND | **Complexity:** Medium
**AC score contribution:** Technical AC (T-AC)

---

## 1. What this pattern is

In a healthy ecosystem, diversity is maintained not by central enforcement but by the structure of the environment itself — different niches, different conditions, different pressures that naturally sustain variety. No organism decides to maintain diversity. The ecosystem architecture does it automatically.

The Diversity Nudge Engine applies this principle to technology decisions. Rather than enforcing diversity through periodic audits or centralised governance, it surfaces monoculture risk at the exact moment a decision is being made — in the PR review, in the architecture decision record, in the infrastructure change. The engineer sees the diversity context before they commit, not after.

This pattern is about changing the environment in which decisions are made so that diversity-aware choices become the natural path, not the effortful one.

---

## 2. The value it brings

- Diversity risk is visible at the moment it can still be avoided, not after the commitment is made
- Engineers make technology choices with explicit context about cumulative vendor concentration
- The Biodiversity Index (P20) score does not drift between quarterly reviews because individual decisions are nudged in real time
- Governance moves from retrospective correction to prospective guidance

---

## 3. The problem it solves

You know you need this pattern when your quarterly Biodiversity Index review always surfaces the same vendor concentration drift that nobody noticed accumulating, or when diversity decisions are only made during formal architecture reviews rather than during the individual choices that actually create the concentration.

The problem is that diversity erosion is invisible at the point of individual decisions. Each "use the same vendor" choice seems locally rational. The cumulative effect — total dependence on a single cloud provider, a single database vendor, a single identity service — is only visible in aggregate. By the time the quarterly review surfaces it, the commitment is already made.

---

## 4. Existing pattern equivalents and the gap this fills

| Pattern | Relationship |
|---|---|
| P10 Biodiversity Index Checks | CI/CD checks that enforce thresholds — Diversity Nudge Engine presents context before a decision, not a binary pass/fail after |
| P20 Biodiversity Index | Quarterly strategic review — this pattern keeps the data current and brings it into daily workflows |
| Nudge theory (Thaler & Sunstein) | The behavioural economics framework this pattern applies — change the choice architecture, not the rules |

**The gap this fills:** P10 enforces. P18 informs. The difference is when and how the information arrives — enforcement after the fact generates resistance; information at decision time enables better choices.

---

## 5. What needs to happen

1. **Integrate diversity context into your ADR template.** When an engineer creates an architecture decision record involving a technology choice, automatically populate a "current diversity context" section showing the vendor concentration for the relevant capability category.

2. **Add diversity summaries to PR descriptions for infrastructure changes.** When a Terraform or Helm PR is raised that introduces a new vendor dependency, a bot adds a comment showing the before/after Biodiversity Index score for the affected capability.

3. **Surface diversity context in your internal technology catalogue.** When an engineer searches for a technology in your internal catalogue (Backstage, Confluence, or equivalent), show the current vendor concentration for that category alongside the technology entry.

4. **Create a monoculture risk dashboard.** A simple view showing which capability categories are approaching dangerous concentration levels — visible to architects and engineers without requiring them to run a report.

5. **Add a "diversity consideration" field to your technology decision checklist.** Not a gate — a prompted question: "Does this choice affect vendor concentration in a critical capability? If so, what is the current concentration level?"

---

## 6. Antipatterns and unhealthy versions

**Nudge as mandate:** converting the nudge into a hard block when teams override it. Nudges work because they inform without coercing. The moment a nudge becomes a gate, it generates resistance rather than better decisions.

> **Sign:** teams start working around the nudge by routing changes through paths that do not trigger it.

**Stale nudge data:** the diversity context shown at decision time is weeks or months out of date. Engineers learn to ignore it because it does not reflect current reality.

> **Sign:** the diversity summary in a PR shows a concentration score that does not match what engineers know to be true about the current state.

**Nudge overload:** every technology decision triggers a diversity nudge, regardless of whether it affects a critical capability. Engineers learn to dismiss all nudges because most are irrelevant.

> **Sign:** the average time engineers spend reading diversity nudges is measured in milliseconds.

---

## 7. Architecture diagram

```
DECISION-TIME NUDGE FLOW

Engineer raises PR: "Add Azure Cognitive Services for ML pipeline"
                        │
                        ▼
        DIVERSITY NUDGE TRIGGERED (non-blocking)
        ────────────────────────────────────────────────
        📊 Diversity context for: ML / AI Services
        Current stage: Genesis (exploration expected)

        Current vendors: AWS SageMaker, Google Vertex AI
        After change: + Azure Cognitive Services

        Biodiversity score (ML): 100 → 100 (no change — 3 options, Genesis stage)
        ✅ This change maintains healthy Genesis-stage diversity

        (If capability were Product stage with 2 existing AWS services):
        ⚠️  AWS concentration in Product ML: currently 67%, would reach 75%
            Consider: is there an equivalent non-AWS option?
            Threshold: 60% for Product-stage capabilities
        ────────────────────────────────────────────────
        [Acknowledge] [View full diversity report]
```

---

## 8. Related patterns

| Pattern | Relationship |
|---|---|
| P10 Biodiversity Index Checks | The enforcement layer — P18 informs, P10 enforces when thresholds are breached |
| P20 Biodiversity Index | The quarterly strategic review that P18 keeps current in daily workflows |
| P03 Succession Stage Routing | Stage classification determines which nudges are relevant and what thresholds apply |

---

## 9. Code snippet

```javascript
// Diversity nudge generator — creates PR comment with diversity context
async function generateDiversityNudge(proposedChange, registry) {
  const capability = proposedChange.capabilityCategory;
  const stage = registry.getStage(capability);
  const currentVendors = registry.getVendorOptions(capability);
  const afterChange = [...new Set([...currentVendors, proposedChange.vendor])];

  const scoreBefore = calculateDiversityScore(currentVendors, stage);
  const scoreAfter = calculateDiversityScore(afterChange, stage);

  // Genesis stage: show context but no warning threshold
  if (stage === 'genesis') {
    return {
      type: 'info',
      message: `**Diversity context — ${capability} (Genesis stage)**\n` +
               `Current vendors: ${currentVendors.join(', ')}\n` +
               `After change: ${afterChange.join(', ')}\n` +
               `Genesis stage: exploration is expected — no concentration threshold applies.`
    };
  }

  const concentrationAfter = 1 / afterChange.length;
  const thresholds = { commodity: 0.5, product: 0.6, custom: 0.8 };
  const threshold = thresholds[stage];

  const type = concentrationAfter > threshold ? 'warning' : 'info';
  const icon = type === 'warning' ? '⚠️' : '✅';

  return {
    type,
    message: `**${icon} Diversity context — ${capability} (${stage} stage)**\n` +
             `Biodiversity score: ${scoreBefore} → ${scoreAfter}\n` +
             `Vendor concentration after change: ${Math.round(concentrationAfter * 100)}% ` +
             `(threshold: ${Math.round(threshold * 100)}%)\n` +
             (type === 'warning' ? `Consider an alternative or abstraction layer for ${capability}.` : '')
  };
}
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Technology decisions with diversity context surfaced | > 90% | Nudge trigger log |
| Engineers who dismiss nudges without reading (< 3 seconds) | < 20% | Engagement analytics |
| Biodiversity Index score variance between quarterly reviews | < 10 points | Score history comparison |
| Cases where nudge prompted a changed technology decision | Increasing trend | Decision log annotation |

---

## 12. What to look out for

The quality of the nudge depends entirely on the quality of the capability classification and vendor registration data. A nudge built on stale or inaccurate data is worse than no nudge — it erodes trust in the system. Invest in keeping the registry current before investing in sophisticated nudge UI. Start with the simplest possible nudge — a PR comment with a one-line diversity summary — and add sophistication only after engineers find the basic version useful.
EOF

echo ""
echo "Staging and committing..."
git add .
git commit -m "Add BUILD SECOND patterns P03, P07, P10, P15, P16, P18

P03 — Succession Stage Routing: apply right governance to right evolution stage
P07 — Nutrient Flow Contracts: bilateral API/event contracts with degradation clauses
P10 — Biodiversity Index Checks: automated CI/CD checks for vendor concentration
P15 — Symbiotic Dependency Design: classify and eliminate parasitic service relationships
P16 — Ecological Succession Gates: verifiable criteria for service maturity transitions
P18 — Diversity Nudge Engine: surface monoculture risk at the moment of decision

All patterns include: 12-section structure, code snippets, fitness function stubs,
related pattern mappings, antipatterns with observable signs, and measurement tables."

echo ""
echo "Pushing to GitHub..."
git push

echo ""
echo "Done. BUILD SECOND patterns are live."
