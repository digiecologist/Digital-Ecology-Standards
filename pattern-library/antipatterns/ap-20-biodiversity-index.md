# AP-20 — Biodiversity Index Antipatterns

**Pattern this relates to:** [P20 Biodiversity Index](../patterns/p20-biodiversity-index/)
**Category:** Succession and Scale
**TL;DR:** The technology landscape is either dangerously uniform (Monoculture Risk) or dangerously varied (Accidental Zoo). Neither is the result of a strategy; both are the result of the absence of one.

---

## The three ways this goes wrong

---

### AP-20-A: Accidental Zoo

**What it is:** The technology landscape has expanded through local decisions to the point where it contains an unmanageable variety of tools, languages, databases, and platforms — each chosen by a team for a good local reason, with no consideration of the aggregate operational cost.

**Sign:** Your on-call runbooks reference more than eight different database technologies across production services.

**Why it happens:** Each technology addition was individually justified. The team that added it owned the operational burden at the time. Over time, teams changed, the original owners moved on, and the operational cost of the zoo became distributed across everyone.

**The cost:**
```
Technology zoo operational impact:
  
  Languages in production:     7  (Java, Python, Go, TypeScript, Ruby, Scala, Kotlin)
  Database technologies:       9  (PostgreSQL, MySQL, MongoDB, DynamoDB, Redis, 
                                   Cassandra, Elasticsearch, SQLite, CockroachDB)
  Message brokers:             4  (Kafka, RabbitMQ, SQS, Pub/Sub)
  
  On-call engineers who can debug all of these: 0
  Mean time to find the right expert during an incident: 45 minutes
  Training cost for new engineers: 3x industry average
```

**The fix — P20 applied:** Technology choices require a Biodiversity Index justification. Adding a new technology to the landscape requires demonstrating that the capability it provides is not already served by something in the existing landscape, and that the operational cost is accepted by the platform team, not just the adding team. New additions are logged in the technology radar.

**Validated reference:** [Thoughtworks Technology Radar](https://www.thoughtworks.com/radar) as a governance model. Netflix's [Paved Road](https://netflixtechblog.com/how-we-build-code-at-netflix-c5d9bd727f15) — opinionated defaults that teams opt out of with justification.

**SCARS lens:** Simplify — an accidental zoo fails Simplify. Complexity that has no strategic purpose is complexity that should be reduced.

---

### AP-20-B: Monoculture Risk

See [AP-10-A: Monoculture Risk](ap-10-biodiversity-index-checks.md#ap-10-a-monoculture-risk) — this antipattern is shared between P10 and P20. P10 catches it in CI at decision time; P20 surfaces it in the quarterly strategic review.

---

### AP-20-C: Diversity for Diversity's Sake

**What it is:** Diversity targets are set as a goal in themselves, detached from the strategic reason for diversity. "We must have at least two vendors for every capability" becomes a rule that is applied even when one vendor is the clear best option and the switching cost of maintaining two is not justified by the risk reduction.

**Sign:** Teams spend more time managing a second vendor relationship than the first vendor's failure risk justifies.

**The fix — P20 applied:** Diversity decisions are made in reference to the risk they mitigate and the cost of maintaining them. For every diversity requirement, the question is: "What failure mode does this protect against, and is the protection worth the cost?" A Wardley stage-appropriate diversity target (as in AP-10-C) provides a principled answer rather than an arbitrary target.

**Validated reference:** Risk management frameworks — diversity as a risk mitigation strategy with cost/benefit analysis, not as a value in itself.

---

*See also: [AP-README](README.md) for the full antipattern index.*
