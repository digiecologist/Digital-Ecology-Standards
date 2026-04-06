# AP-08 — Trophic Decomposition Antipatterns

**Pattern this relates to:** [P08 Trophic Level Decomposition](../patterns/p08-trophic-decomposition/)
**Category:** Flow and Nutrient Cycling
**TL;DR:** Layers in the architecture either bypass each other (going straight to the raw data instead of consuming the enriched form) or they fail to add value on the way through — accumulating complexity without enriching what passes on.

---

## The three ways this goes wrong

---

### AP-08-A: Layer Bypass

**What it is:** A service at a higher level of abstraction reaches past its immediate layer to consume raw data directly from a lower layer, instead of consuming the enriched output that the intermediate layer is responsible for producing. The intermediate layer's work is partially or wholly skipped.

**Sign:** A service in the "application" layer makes direct database queries against tables owned by the "data" layer, rather than going through the service layer.

**Why it happens:** The intermediate layer is too slow, or it doesn't expose the exact data format needed, or it's just quicker to go direct. The bypass is made under time pressure. It becomes a pattern.

**What this creates:**
```
Intended data flow (trophic layers):
  Raw database → Data layer (normalise, validate) → 
  Service layer (business logic) → API layer (format for consumer)

Bypass pattern in practice:
  API layer ──────────────────────────────→ Raw database
                                            (skips data + service layer)
  
Result:
  - Business rules in data layer not applied
  - Validation in data layer not applied  
  - Schema changes in database break API layer directly
  - Two paths to the same data, producing inconsistent results
```

**The fix — P08 applied:** Each layer consumes only from its immediate lower layer. The intermediate layer's value — normalisation, validation, business rule application, caching — is not optional. If the intermediate layer doesn't expose what a higher layer needs, the right fix is to extend the intermediate layer's API, not to bypass it.

**Validated reference:** [Layered Architecture pattern](https://www.oreilly.com/library/view/software-architecture-patterns/9781491971437/ch01.html) (Mark Richards). Clean Architecture (Robert C. Martin) — dependency rules between layers. [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/) (Alistair Cockburn).

**SCARS lens:** Abstraction — Layer Bypass is an Abstraction failure. The intermediate layer exists to hide the complexity below it. Bypassing it exposes that complexity to a layer that should not need to know about it.

---

### AP-08-B: Leaky Abstraction Stack

**What it is:** A layer passes on implementation details that should be hidden. The layer above receives not just the enriched value it needs, but also internal concerns, error formats, database identifiers, or infrastructure artifacts from the layer below. The abstraction leaks — consumers of the upper layer are implicitly coupled to the lower layer's implementation.

**Sign:** Your API responses include database row IDs, internal status codes, or infrastructure-specific error messages that consumers have to interpret.

**Why it happens:** Abstraction is extra work. It is easier to pass through the data structure you received than to translate it into the form the consumer actually needs. Leaks accumulate through convenience.

**What a leaky abstraction looks like:**
```json
// API response leaking internal implementation
{
  "order_id": "ord_ABC123",
  "internal_db_id": 45821,        ← database row ID leaking out
  "status_code": 3,               ← internal status enum leaking out
  "mysql_timestamp": "2024-01-15 10:30:00",  ← database format leaking
  "payment_gateway_ref": "stripe_pi_XYZ",    ← internal vendor leaking
  "error": "SQLSTATE 23000: Duplicate entry"  ← database error leaking
}

// Clean abstraction — consumer gets what they need, nothing else
{
  "orderId": "ord_ABC123",
  "status": "confirmed",
  "confirmedAt": "2024-01-15T10:30:00Z",
  "paymentStatus": "captured"
}
```

**The fix — P08 applied:** Each layer translates before passing on. Translation means: producing the data structure the consumer needs, in the consumer's language, hiding implementation artifacts. The consumer should never need to know what database, what vendor, or what internal system produced the response.

**Validated reference:** Joel Spolsky, [The Law of Leaky Abstractions](https://www.joelonsoftware.com/2002/11/11/the-law-of-leaky-abstractions/) — the principle and why perfect abstraction is impossible, but intentional abstraction is still the goal. DDD Anti-Corruption Layer — the same principle at domain boundaries.

**SCARS lens:** Abstraction — a leaky layer has failed at Abstraction. Complexity from below is visible above when it should not be.

---

### AP-08-C: Enrichment Skipping

**What it is:** A layer receives data from below but adds no value before passing it on. It is a pass-through — present in the architecture, adding overhead, but performing no transformation, validation, enrichment, or business rule application. The layer has a name but not a purpose.

**Sign:** You can trace a request through your layered architecture and the data structure is identical at entry and exit of one or more layers.

**Why it happens:** Layers are added for structural reasons (compliance, future extensibility) but the work they are supposed to do is never defined or implemented. The layer exists as a placeholder.

**Why it matters:**
```
Performance cost of a do-nothing layer:
  Added latency per layer:           ~5–15ms (network + serialisation)
  Added failure points per layer:    1 (additional service that can fail)
  Added complexity:                  additional deployment, monitoring, 
                                     alerting, versioning, contracts
  
Value delivered by an enrichment-skipping layer: 0

Every do-nothing layer is a tax the system pays on every request 
with no return. They accumulate, and the system gets slower and 
more fragile without getting more capable.
```

**The fix — P08 applied:** Every layer in the architecture has a declared enrichment responsibility. Before a new layer is added, the question is answered: what does this layer do to the data that the layer above cannot and should not do itself? If the answer is "nothing yet, but maybe later," the layer should not exist yet.

**Validated reference:** Evolutionary Architecture (Ford, Parsons, Kua) — fitness function: measure value-add per layer. YAGNI principle — layers added for future value that never materialises are a form of premature optimisation.

**SCARS lens:** Simplify — an enrichment-skipping layer is pure complexity with no compensating value. The Simplify check asks: what can be removed? This layer.

---

## Fitness function

```javascript
// fitness-functions/trophic/check-layer-value.js
// Detects potential pass-through layers by comparing 
// input/output schema similarity

async function detectPassThroughLayers(serviceGraph) {
  const suspects = [];
  
  for (const service of serviceGraph.services) {
    const inputSchema = await getServiceInputSchema(service);
    const outputSchema = await getServiceOutputSchema(service);
    
    const similarity = calculateSchemaSimilarity(inputSchema, outputSchema);
    
    if (similarity > 0.95) {  // Input and output are >95% identical
      suspects.push({
        service: service.name,
        similarity: `${Math.round(similarity * 100)}%`,
        warning: 'Possible pass-through layer — verify enrichment responsibility',
        action: 'Document what transformation this service performs, or remove it'
      });
    }
  }
  
  return suspects;  // Warning not failure — requires human judgement
}
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-04 Shared Database Seepage](ap-04-edge-effect-zones.md) | Both are layer boundary violations — seepage goes sideways, bypass goes down |
| [AP-05 God Service](ap-05-niche-partitioning.md) | God services often result from multiple layers' work collapsing into one |
| [AP-07 Black Box API](ap-07-nutrient-flow.md) | Leaky abstractions and black boxes are opposite failures — one reveals too much, one reveals too little |

---

*See also: [AP-README](README.md) for the full antipattern index.*
