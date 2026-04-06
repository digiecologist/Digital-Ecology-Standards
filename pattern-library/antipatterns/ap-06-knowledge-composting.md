# AP-06 — Knowledge Composting Antipatterns

**Pattern this relates to:** [P06 Knowledge Composting](../patterns/p06-knowledge-composting/)
**Category:** Flow and Nutrient Cycling
**TL;DR:** Dead code, abandoned decisions, and deprecated features stay in the codebase forever — creating drag, confusion, and cognitive load — because removing things feels riskier than leaving them.

---

## The three ways this goes wrong

---

### AP-06-A: Dead Code Hoarding

**What it is:** Code that is no longer executed stays in the codebase indefinitely. Feature flags that were flipped permanently remain as branches. Deprecated APIs still have full implementations. Old database tables have no consumers but are never dropped. The codebase grows in one direction — nothing ever leaves.

**Sign:** Your codebase has feature flags that have been `true` for over a year. The `if (featureEnabled('new_checkout'))` branch is dead; the `else` branch below it executes on 0% of requests and is still maintained.

**Why it happens:** Removing code feels risky. "What if we need it back?" The cost of removal is immediate and visible; the cost of keeping it is diffuse and invisible — cognitive load, confusion, test surface area, maintenance cost. The asymmetry means the default is always to keep.

**The accumulation problem:**
```
Codebase inventory audit (anonymised real example):
  
  Feature flags active in codebase:     47
  Feature flags enabled for 100%+ days: 31
  Feature flags enabled for 365+ days:  19
  
  Dead flag branches (if false / else):  19 blocks of unreachable code
  Estimated lines of dead code:          ~4,200
  
  Engineers who know which flags are dead: 2 (original authors)
  Engineers who are afraid to remove them: 8 (everyone else)
```

**The fix — P06 applied:** Feature flags have an expiry date set at creation. Expired flags are automatically surfaced in CI as a failing check. Dead code removal is celebrated as a contribution, not treated as risky maintenance. The PR that removes 200 lines is as valuable as the PR that adds a feature.

```javascript
// Feature flag with enforced expiry
const flags = {
  new_checkout_flow: {
    enabled: true,
    enabledSince: '2023-11-01',
    expiresAt: '2024-02-01',   // Must be removed by this date
    owner: 'checkout-team',
    removalTicket: 'ENG-4521'
  }
};

// CI check: flag expired → block merge
function checkFlagExpiry(flags) {
  const expired = Object.entries(flags)
    .filter(([_, flag]) => new Date(flag.expiresAt) < new Date());
  
  if (expired.length > 0) {
    throw new Error(`Expired feature flags must be cleaned up: ${expired.map(([k]) => k).join(', ')}`);
  }
}
```

**Validated reference:** [Martin Fowler on Feature Flags](https://martinfowler.com/articles/feature-toggles.html) — especially the section on flag lifecycle and technical debt. [LaunchDarkly](https://launchdarkly.com/blog/feature-flag-technical-debt/) on flag debt management.

**SCARS lens:** Simplify — dead code is the purest form of complexity that can be removed. Every line of dead code is cognitive overhead with zero return.

---

### AP-06-B: Decision Amnesia

**What it is:** Architectural decisions are made, implemented, and then forgotten. The codebase reflects the decisions but carries no record of *why*. Six months later, a new engineer sees an unusual pattern and "fixes" it — reintroducing the problem the decision was originally made to solve.

**Sign:** The same architectural mistake is introduced, fixed, and reintroduced in the same area of the codebase within 18 months. Post-mortems reference "we solved this before."

**Why it happens:** Architecture Decision Records (ADRs) are known but not consistently used. Decisions made in Slack threads, in meetings, or informally are never captured. The knowledge lives in the heads of whoever was in the room.

**The cost:**
```
Timeline of a recurring pattern mistake:

  Month 1:  Engineer A discovers performance issue with synchronous 
            notification dispatch. Switches to async queue. 
            Decision made verbally in stand-up.
            
  Month 8:  Engineer A leaves the team.
  
  Month 11: Engineer C sees "unnecessary complexity" in notification 
            dispatch. Simplifies it back to synchronous.
            
  Month 12: Performance issue reappears. Post-mortem references
            "we went through this before."
            
  Time lost re-learning: ~2 weeks. Problem cost: repeated incident.
```

**The fix — P06 applied:** ADRs are written for any decision that took more than 30 minutes to make. The ADR template includes: context (what problem were we solving?), decision (what did we decide?), consequences (what does this constrain?), and alternatives considered. ADRs are stored in the repository, not in Confluence.

```markdown
# ADR-0042: Async notification dispatch

**Status:** Accepted  
**Date:** 2023-11-14  
**Deciders:** checkout-team

## Context
Synchronous notification dispatch was causing p99 checkout latency 
to exceed 800ms during email service degradation.

## Decision
Move all notification dispatch to async via the event mesh (P01).
Notifications are fire-and-forget from the checkout perspective.

## Consequences
- Checkout latency p99 drops below 200ms under notification service degradation
- Notifications may be delayed by up to 60 seconds under queue pressure
- Engineers must NOT revert this to synchronous — see the latency data in #incident-2023-11-08

## Alternatives rejected
- Timeout reduction: still blocks checkout thread, just fails faster
- Caching: doesn't address the fundamental coupling
```

**Validated reference:** [Architectural Decision Records](https://adr.github.io/) — Michael Nygard's original format. [adr-tools](https://github.com/npryce/adr-tools) — CLI for managing ADRs in a repository. [MADR](https://adr.github.io/madr/) — Markdown Any Decision Records.

**SCARS lens:** Abstraction — decision amnesia is a failure to abstract architectural knowledge into durable, accessible form.

---

### AP-06-C: The Undead Feature

**What it is:** A feature is deprecated — communications have been sent, a sunset date announced — but the implementation is never actually removed. The feature continues to run, accumulate bugs, and receive inadvertent maintenance. The "deprecated" label is a legal disclaimer, not a technical state.

**Sign:** Your changelog has features marked deprecated for over two years that are still accepting production traffic.

**Why it happens:** Deprecation is the easy part — send an email, update the docs. Removal is hard — migrate the remaining consumers, handle the edge cases, deal with the complaints. Removal is never as urgent as new feature work. It perpetually loses prioritisation battles.

**The fix — P06 applied:** Deprecation and removal are a single process, not two separate events. When a feature is deprecated, a removal date is set and a migration path is documented. On the removal date, the feature is turned off — not "reviewed for removal." The removal date is a commitment, not a target.

**Validated reference:** Stripe's API versioning and deprecation discipline — explicit sunset dates with enforcement. Google's [API design guide](https://cloud.google.com/apis/design/versioning) on deprecation policy.

**SCARS lens:** Simplify — an undead feature is a running cost with no return. The complexity of maintaining it continues indefinitely unless removal is treated as mandatory, not optional.

---

## Fitness functions

```yaml
name: Knowledge Composting Guard

checks:
  - name: Expired feature flags
    fail_if: any feature flag's expiresAt is in the past
    severity: error
    
  - name: ADR coverage
    warn_if: |
      PR modifies core architectural patterns (event publishing, 
      caching strategy, external API client) without an ADR reference
    severity: warning
    
  - name: Deprecated feature traffic
    metric: requests_to_deprecated_endpoints_per_day
    warn_threshold: "> 0 after sunset date"
    action: Block sunset date if traffic > 0; accelerate migration
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-14 Debt Sprint Cycle](ap-14-regenerative-refactoring.md) | Dead code is technical debt — the same batch-clearance failure applies |
| [AP-17 Fitness Landscape Blindness](ap-17-fitness-landscape.md) | Decision amnesia means the fitness landscape can't be navigated — decisions look arbitrary |
| [AP-12 Boiling Frog](ap-12-phenological-drift-alerts.md) | Undead features accumulate and obscure the real system's health signals |

---

*See also: [AP-README](README.md) for the full antipattern index.*
