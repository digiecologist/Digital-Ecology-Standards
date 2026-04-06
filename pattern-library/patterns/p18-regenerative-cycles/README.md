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
