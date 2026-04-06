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
