# P20 — Biodiversity Index

**Category:** In-built Nudges & Behavioural Design | **Build priority:** BUILD FIRST | **Complexity:** Medium
**AC score contribution:** Technical AC (T-AC)

---

## 1. What this pattern is

Biodiversity in an ecosystem is not simply "more is better." A healthy forest has diversity at the right level for its conditions. A mature climax forest looks very different from a pioneer grassland, and both are healthy for their stage.

The Biodiversity Index scores your technology diversity against the Wardley evolution stage of each capability — giving you a single number that tells you whether your diversity choices are calibrated to your context, not just whether you have variety.

---

## 2. The value it brings

- Dangerous technology monocultures are surfaced before conditions change and expose them
- Over-diversification — complexity without benefit — is identified and can be reduced
- Technology decisions are made with a framework, not intuition or vendor relationship
- Vendor risk is quantified and tracked over time

---

## 3. The problem it solves

You know you need this pattern when a single vendor changing their pricing would cause a significant business problem, or when you cannot answer "what would happen if our primary cloud provider went down for four hours?"

The problem is unscored diversity. Most systems have some diversity but it is accidental rather than deliberate — nobody has mapped it against what is actually needed.

---

## 4. Existing pattern equivalents and the gap this fills

| Pattern | Relationship |
|---|---|
| Wardley Mapping | Provides the evolution axis this pattern uses to contextualise diversity |
| Vendor risk assessment | Risk management practice — this pattern automates and continuously monitors it |

---

## 5. What needs to happen

1. List your critical capabilities (5–10 genuinely critical ones)
2. Place each on the Wardley evolution axis: Genesis, Custom, Product, Commodity
3. Score diversity appropriateness using the matrix:

| Stage | 1 option | 2 options | 3+ options |
|---|---|---|---|
| Genesis | 50 pts | 100 pts | 40 pts |
| Custom | 90 pts | 85 pts | 60 pts |
| Product | 60 pts | 100 pts | 75 pts |
| Commodity | 0 pts | 100 pts | 70 pts |

4. Calculate three component scores:
   - *Capability Coverage (40%)* — average appropriateness across capabilities
   - *Vendor Risk (35%)* — concentration of critical systems on a single vendor
   - *Pattern Diversity (25%)* — using the right patterns for different problems

5. Combine: `Biodiversity = (Coverage × 0.4) + (Vendor Risk × 0.35) + (Pattern Diversity × 0.25)`

6. Review quarterly and after significant technology decisions

---

## 6. Antipatterns

**Commodity monoculture:** a single cloud provider, payment processor, or authentication service with no alternative. Invisible until the vendor changes terms.

> **Sign:** your primary cloud provider announces a 40% price increase and you have no credible alternative.

**Ignoring the Wardley context:** scoring diversity without placing capabilities on the evolution axis first. A startup exploring two databases at Genesis stage is not over-diversified.

> **Sign:** your assessment treats startup exploration the same as enterprise commodity lock-in.

---

## 9. Code snippet

```javascript
const SCORES = {
  genesis:   { 1: 50, 2: 100, '3+': 40 },
  custom:    { 1: 90, 2: 85,  '3+': 60 },
  product:   { 1: 60, 2: 100, '3+': 75 },
  commodity: { 1: 0,  2: 100, '3+': 70 }
};

function calculateBiodiversityIndex(capabilities, vendorRisk, patternDiversity) {
  const capCoverage = capabilities.reduce((sum, cap) => {
    const key = cap.optionCount >= 3 ? '3+' : String(cap.optionCount);
    return sum + SCORES[cap.stage][key];
  }, 0) / capabilities.length;

  return Math.round((capCoverage * 0.4) + (vendorRisk * 0.35) + (patternDiversity * 0.25));
}
```

---

## 11. Measuring success

| Metric | Healthy threshold | How to measure |
|---|---|---|
| Biodiversity Index score | > 65 | Quarterly calculation |
| Commodity capabilities with single vendor | 0 | Capability inventory |
| Score trend | Non-decreasing over 12 months | Quarterly history |

---

## 12. What to look out for

Commodity lock-in is the most urgent finding when you first run this. The fix is not necessarily multi-cloud — an abstraction layer that reduces switching cost is often enough. Evolution stages change as markets mature: recalculate when a major new entrant appears in a capability you had treated as Custom. Organisation size does not determine appropriate diversity — the Wardley stage does.
