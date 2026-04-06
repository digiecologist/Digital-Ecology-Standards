# AP-02 — Keystone Interface Antipatterns

**Pattern this relates to:** [P02 Keystone Interface](../patterns/p02-keystone-interface/)
**Category:** Structural / Architectural
**TL;DR:** The keystones that hold everything else up are either invisible (nobody knows they're critical) or unprotected (everyone knows but nothing is done about it).

---

## The three ways this goes wrong

---

### AP-02-A: Undeclared Keystone

**What it is:** A service accumulates consumers over time until it is effectively load-bearing for the whole system — but this was never declared, designed for, or governed. Its SLA does not reflect its actual criticality. It has no dedicated runbook. It gets the same on-call attention as everything else.

**Sign:** A service goes down and the blast radius is five times larger than anyone expected.

**Why it happens:** Services gain consumers incrementally. Each individual consumer decision seems reasonable. Nobody is tracking aggregate fan-in. The keystone status is discovered in a post-mortem.

**What the SCARS check surfaces:**
```
SCARS Responsibilities check: fan-in threshold violation
Service: payment-gateway
Current consumers: 11
Threshold: 8
Status: FAIL — keystone behaviour without keystone governance

Recommended action: 
  → Review consumers — can any be redirected to P01 mesh events?
  → If keystone status is appropriate, add to keystone registry
  → Upgrade SLA, add enhanced monitoring (P09), add runbook
```

**The fix — P02 applied:** Run the fan-in check from the SCARS diagnostic quarterly. Any service breaching the threshold either gets redesigned (redirect consumers to the mesh) or gets explicitly declared as a keystone with the governance that entails.

**Validated reference:** Ruth Malan's SCARS — Responsibilities check. [Team Topologies](https://teamtopologies.com/) platform team model — platform services that exceed this threshold should be managed as platform capabilities with full SRE treatment.

**SCARS lens:** Responsibilities — undeclared keystones have exceeded their intended responsibility scope without the governance to match.

---

### AP-02-B: Silent Consumer Sprawl

**What it is:** A keystone interface has consumers that nobody has registered. Schema changes break consumers the interface team did not know existed. Consumers are discovered through incident post-mortems, not through design.

**Sign:** Every schema migration requires a "who knows what consumes this?" Slack thread.

**Why it happens:** Consumers are added without notifying or registering with the producer. In a healthy organisation this is fine for low-criticality services; for keystones it is a structural risk.

**What it looks like in practice:**
```
Production incident post-mortem:
  Root cause: payment-gateway schema change (field renamed)
  Affected consumers: 4 registered + 3 unknown
  The 3 unknown consumers were discovered through elevated error rates
  Time to identify all affected consumers: 4.5 hours
```

**The fix — P02 applied:** Consumer registration is mandatory for keystone interfaces. The keystone registry lists every known consumer with their owner, their schema version pin, and their expected migration timeline. New consumers trigger a review. Schema changes require a consumer impact assessment run against the registry.

**Validated reference:** Consumer-Driven Contract testing (Pact). [Pact documentation](https://docs.pact.io/). AsyncAPI consumer registry pattern.

**SCARS lens:** Cohesion — a keystone interface with unknown consumers cannot be evolved cohesively.

---

### AP-02-C: Keystone Without Runbook

**What it is:** A service is known to be critical, it is in the keystone registry, it has an elevated SLA — but when it degrades, the on-call engineer has no playbook for what to do. Every incident is improvised.

**Sign:** Post-mortems for keystone incidents show the same "we weren't sure what to do first" narrative repeatedly. Time-to-mitigate is high and inconsistent.

**Why it happens:** Declaring a keystone is treated as the end of the governance work. The runbook is deferred. Runbook-writing is invisible work that does not appear in sprint tracking.

**The fix — P02 applied:** Keystone registration is incomplete without a tested runbook. The runbook must include: degradation signals and their meaning, isolation procedure, consumer impact assessment steps, escalation contacts, and the specific recovery actions with their expected timelines. Runbooks are tested in game days, not discovered during incidents.

**Validated reference:** Google SRE Book — [Chapter 14: Managing Incidents](https://sre.google/sre-book/managing-incidents/). PagerDuty Runbook Automation. Chaos Engineering practice (Chaos Monkey, Gremlin) for runbook validation.

**SCARS lens:** Abstraction — an unrunbooked keystone has not abstracted its failure modes into actionable knowledge.

---

## Fitness functions for these antipatterns

```javascript
// fitness-functions/keystone/check-keystone-registry.js
// Fails if any service exceeds fan-in threshold without keystone declaration

async function checkKeystoneRegistry(serviceGraph, registry) {
  const violations = [];
  
  for (const service of serviceGraph.services) {
    const fanIn = serviceGraph.getConsumerCount(service.id);
    
    if (fanIn > KEYSTONE_THRESHOLD) {
      const isRegistered = registry.keystones.includes(service.id);
      const hasRunbook = registry.runbooks[service.id]?.tested === true;
      const slaElevated = service.sla?.p99LatencyMs <= KEYSTONE_SLA_THRESHOLD;
      
      if (!isRegistered) {
        violations.push({
          service: service.name,
          issue: 'UNDECLARED_KEYSTONE',
          fanIn,
          action: 'Add to keystone registry or reduce consumer count below threshold'
        });
      } else if (!hasRunbook) {
        violations.push({
          service: service.name, 
          issue: 'KEYSTONE_WITHOUT_RUNBOOK',
          action: 'Add tested runbook to keystone registry entry'
        });
      }
    }
  }
  
  return violations;
}

const KEYSTONE_THRESHOLD = 8;
const KEYSTONE_SLA_THRESHOLD = 200; // ms p99
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-01 Async Monolith](ap-01-mycelial-mesh.md) | Async monoliths hide undeclared keystones |
| [AP-09 SLA Theatre](ap-09-carrying-capacity-monitors.md) | Keystones need more than SLA monitoring |
| [AP-11 Invisible Blast Radius](ap-11-cascade-risk-detectors.md) | Undeclared keystones are the highest-risk blast radius |

---

*See also: [AP-README](README.md) for the full antipattern index.*
