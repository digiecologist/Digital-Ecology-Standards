# AP-15 — Symbiotic Dependency Design Antipatterns

**Pattern this relates to:** [P15 Symbiotic Dependency Design](../patterns/p15-symbiotic-dependency-design/)
**Category:** Adaptive and Regenerative
**TL;DR:** Dependencies between services are either unnamed (nobody knows what kind of relationship it is) or parasitic (one side extracts without reciprocating). Both degrade over time.

---

## The three ways this goes wrong

---

### AP-15-A: Unnamed Relationship

**What it is:** Service A depends on Service B. The nature of the dependency — what kind of relationship it is, who benefits, what the obligations are — is not declared. It exists as a call in the code.

**Sign:** You cannot answer the question "is this dependency mutualistic or parasitic?" for your top ten service relationships.

**Why it happens:** Dependency design focuses on the technical contract (what the API does) not the relational contract (what each side owes the other). The relationship type is implicit — everyone assumes it is healthy until an incident reveals it is not.

**The three dependency types to name explicitly:**

| Type | Definition | Sign it is not named |
|---|---|---|
| **Mutualistic** | Both sides benefit — each makes the other better | Neither side knows the other's health constraints |
| **Commensal** | One side benefits; the other is unaffected | The benefiting side has no obligation to the other |
| **Parasitic** | One side benefits; the other degrades | The extracting side has no SLA obligation toward the host |

**What unnamed relationships cost:**

```
Example: Notifications Service ← Orders Service (unnamed)

Orders calls notifications to send order confirmation emails.
But what is the relationship?

  Mutualistic view (notifications team assumed):
    "Both services benefit when customers get emails"
    → SLA obligation: p99 < 100ms
    → Order team should be paged on notification degradation
    
  Parasitic view (orders team assumed):
    "Notifications is a side effect; orders don't require it"
    → SLA obligation: best effort
    → Order team should never be paged for notification failures
    
When notifications degrades, the two teams have different expectations
about who is responsible. The mismatch creates tension.
```

**The fix — P15 applied:** Every critical dependency has a named relationship type in the service manifest. The name makes the obligation explicit and checkable in code review.

```yaml
# service-manifest.yml — name your relationships
service: orders
dependencies:
  - service: payments
    type: mutualistic        # Both sides have SLA obligations
    owned-by-us: payment-acceptance
    owned-by-them: payment-status
    mutual-sla: p99 < 100ms
    
  - service: notifications
    type: commensal          # We benefit; they are unaffected
    benefit-to-us: customer-confirmation
    obligation-to-them: rate limit (max 1000/min)
    
  - service: analytics
    type: parasitic          # We extract; they may degrade
    note: analytics is best-effort; this is not a critical path
```

**Validated reference:** [Team Topologies](https://teamtopologies.com/) interaction modes — X-as-a-Service, collaboration, facilitating — are the human-level version of this pattern. DDD context map relationship patterns — Customer/Supplier, Conformist, Partnership (Eric Evans). [Symbiotic Relationships in Ecosystems](https://en.wikipedia.org/wiki/Symbiosis) — the biological model that inspired P15.

**SCARS lens:** Responsibilities — an unnamed relationship has not clarified responsibility. Who is responsible for keeping this relationship healthy?

---

### AP-15-B: Asymmetric Dependency

**What it is:** A dependency that was designed as mutual has become one-sided. One service has invested in the relationship (built tooling, maintained compatibility, invested in the integration) while the other has extracted value without reciprocating. The imbalance is invisible until the invested side hits capacity limits.

**Sign:** One team has raised "we've done all the work on this integration" in more than one retrospective. Or: one team is paged for impacts they don't control.

**Why it happens:** Mutualistic dependencies require ongoing coordination. If one side's investment exceeds the other's, the imbalance accumulates. The investing side bears the cost; the extracting side extracts the benefit. Without an explicit relationship type, this drift goes unnoticed.

**What asymmetry looks like:**
```
Mutualistic dependency (designed):
  Orders ←→ Inventory
  Both teams on-call for incidents affecting the other
  Both teams contribute to schema evolution
  Integration costs shared

Asymmetric dependency (emerged):
  Orders → Inventory (but not bidirectional)
  Orders team on-call for inventory latency
  Inventory team: "not our problem if orders can't handle our queries"
  Orders team bears all integration cost
  
Result: Over two years, Orders team invests heavily; Inventory team 
doesn't. When Orders team considers switching to a different 
inventory provider, there's significant resistance from both sides — 
but for different reasons.
```

**The fix — P15 applied:** Audit dependencies for contribution asymmetry annually. Where asymmetry is found, either rebalance (the extracting side takes on obligations) or reclassify (acknowledge it is commensal and govern accordingly).

**Validated reference:** Organizational dynamics in software systems — the Conway Law (Melvin Conway) extended to dependencies. Team scorecards that measure "integration cost borne by this team" make asymmetry visible.

**SCARS lens:** Cohesion — asymmetric dependencies have low cohesion between the effort required and the benefit received.

---

### AP-15-C: Dependency by Accident

**What it is:** A dependency exists because of a historical reason that no longer applies. The original use case is gone; the dependency is not. Both services pay the maintenance cost of a relationship that neither needs.

**Sign:** When you ask both teams "why does this dependency exist?", neither team can give a current-tense answer. The answer is always history-tense: "we set it up for X, and it's still there."

**Why it happens:** Removing a dependency requires coordination. It is easy to add a dependency (one caller) and hard to remove it (verify all callers are gone). Dependencies accumulate. Occasionally they become obsolete, but the removal cost is higher than the cost of keeping them.

**The cost:**
```
Accidental dependency: Orders → Legacy audit service (built 2018)

Original purpose (2018): Regulatory compliance reporting
Current use: Unknown — nobody checks the logs

Cost of keeping it:
  - Maintenance of audit service (even though it barely changes)
  - Orders team resilience testing must account for audit latency
  - Database query optimization must consider audit queries
  - Incident on-call for Orders must handle audit service failures
  - Schema changes require coordination between teams
  
Benefit: Unclear. If someone asked "does anything depend on the 
audit service's daily reports?", the answer might be "we're not sure".

Removal cost: Two weeks of investigation + coordination
```

**The fix — P15 applied:** Annual dependency audit with a "why does this exist?" question for each. Dependencies that have no current-tense answer are candidates for removal. The evolutionary architecture fitness function: dependencies with no measurable value to either party within 90 days are retired.

**Validated reference:** Evolutionary Architecture (Ford, Parsons, Kua) — fitness functions that surface unused capabilities. Legacy system decomposition strategies — Strangler Fig pattern (Martin Fowler).

**SCARS lens:** Simplify — an accidental dependency is pure complexity. It exists without justification and should be removed.

---

## Fitness functions

```yaml
name: Symbiotic Dependency Design Guard

checks:
  - name: All critical dependencies have relationship type declared
    query: services WHERE dependency_count > 3 AND declared_relationships < 80%
    fail_if: count > 0
    action: Add relationship type to service manifest for high-impact dependencies
    
  - name: Parasitic dependencies have mitigation plan
    query: |
      dependencies WHERE type = parasitic 
      AND consumer_count > 1
      AND mitigation_plan IS NULL
    warn_if: count > 0
    action: Document why this is parasitic and what the limits are
    
  - name: Unused dependencies are removed within 90 days
    query: |
      dependencies WHERE traffic_30day_average = 0 
      AND created_date > 90 days ago
    fail_if: count > 0
    action: Remove dependency or document its continued need
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-02 Undeclared Keystone](ap-02-keystone-interface.md) | Unnamed relationships create undeclared keystones — critical dependencies without acknowledgement |
| [AP-07 Undocumented Dependency Weight](ap-07-nutrient-flow.md) | Both are failures to declare dependency impact |
| [AP-11 Invisible Blast Radius](ap-11-cascade-risk-detectors.md) | Parasitic dependencies are invisible until the host fails |

---

*See also: [AP-README](README.md) for the full antipattern index.*
