# AP-16 — Succession Gates Antipatterns

**Pattern this relates to:** [P16 Ecological Succession Gates](../patterns/p16-succession-gates/)
**Category:** Succession and Scale
**TL;DR:** Services are either promoted to production maturity before they have earned it, or they stay in an early stage indefinitely because graduation criteria are never defined or enforced.

---

## The three ways this goes wrong

---

### AP-16-A: Premature Graduation

**What it is:** A service is promoted to full production status — with the SLA, on-call coverage, and consumer trust that implies — before it has demonstrated it deserves that status. The first significant traffic event reveals this.

**Sign:** Incidents in services less than six months old involve failures that sustained load testing would have caught. An on-call engineer is paged at 3 AM for a service that never demonstrated it could handle production load.

**Why it happens:** There is pressure to declare something "done" and move on. The graduation decision is made by the team that built the service, on a date that fits the roadmap, not on a date when the criteria are genuinely met. The cost of deferring graduation is local and visible (the team is blocked); the cost of premature graduation is distributed (incidents, on-call burden, customer impact) and invisible until it happens.

**What premature graduation looks like:**

```
Timeline: Payments Service Launch

  Week 0:   Code complete
  Week 2:   "We're ready for production"
  Week 3:   Service marked PRODUCTION in service registry
            SLA declared: p99 < 200ms
            On-call rotation assigned
            Consumers begin integrating
  
  Week 5:   First real traffic spike (customer newsletter)
            p99 latency: 8,200ms (database queries not indexed)
            Alert storm
            On-call team pages for the fifth time that night
            
  Week 8:   Post-mortem: "We didn't load test"
            Root cause: service was presented as production-ready
            without having earned it through demonstrated capability
```

**The fix — P16 applied:** Graduation criteria are defined before a service enters incubation. They are measured, not asserted. Graduation decisions are made by a platform or architecture review function, not by the building team alone. The criteria include: 30-day SLA history from monitoring data, documented runbook, passing cascade risk assessment (P11), load test at 2× expected peak.

```yaml
# Succession gate criteria — defined before service launch
production-readiness-criteria:
  sla-history:
    - Must have 30 consecutive days of >= 99.5% uptime
    - Must demonstrate p99 latency is stable for 30 days
    - Measured from production monitoring, not lab conditions
    
  operational-readiness:
    - Documented runbook with at least two team members trained
    - On-call playbook for top three failure modes
    - Alerts configured for every failure mode in the runbook
    
  architectural-readiness:
    - Cascade risk assessment (P11) completed and passed
    - Dependency weight declared (P07)
    - Monitoring covers the critical path, not just the happy path
    
  load-testing:
    - Load test at 2× expected peak traffic
    - Sustained load test for 1 hour
    - Graceful degradation verified (does not cascade failure on overload)
    
  review:
    - Architecture review team sign-off (not building team alone)
    - Post-launch incident review (if any) documented
    - Decision recorded with clear pass/fail for each criterion
```

**Validated reference:** Google SRE — production readiness review framework. [Spotify squads model](https://engineering.atspotify.com/2014/03/spotify-engineering-culture-part-1/) — chapter and guild review for new services. Chaos Engineering as a graduation gate (Netflix Chaos Monkey).

**SCARS lens:** Responsibilities — a service promoted before ready has not taken responsibility for its SLA. It makes a promise it has not demonstrated it can keep.

---

### AP-16-B: Gate Without Criteria

**What it is:** A succession gate process exists — services go through an "architecture review" or "production readiness review" before promotion — but the criteria are not written down, change depending on who is reviewing, and are influenced by whether the service team is liked or whether the project is urgent.

**Sign:** Similar services have received different outcomes from the same gate process. Engineers describe the review as "political" or "it depends who you know." One service bypassed the gate entirely because of timeline pressure.

**Why it happens:** Codifying criteria feels like bureaucracy. The architects prefer to evaluate each service in context. The real reason is that written criteria are auditable — it becomes obvious when they are not applied consistently or when they are violated.

**What criteria-free gates produce:**

```
Six services reviewed in the same quarter:

Service A: Load testing deferred because "we'll monitor closely"
          Graduation approved
          
Service B: Load testing required; blocked for 2 months
          Same architectural complexity as Service A
          
Service C: No runbook documented, but urgent for business
          Graduation approved by exception
          
Service D: All criteria met, reviewed by different architect
          Graduation denied — "doesn't feel production-ready"
          
Service E: Graduated on timeline, no incident history
          Later incident reveals it failed the SLA promises
          
Service F: Graduated after review by most-respected architect
          Higher bar applied; still waiting after 6 months
          
Engineers' reaction: "This is not objective. It's who you know."
Architects' reaction: "Each service is different."

Both are right. The lack of written criteria makes judgment 
inconsistent and evaluation feel arbitrary.
```

**The fix — P16 applied:** Codified, measurable criteria — the same ones for every service, reviewed and updated quarterly. If a reviewer wants to add a new criterion, it applies to all future reviews plus all services currently under review, not just to the next service.

**Validated reference:** Lightweight Architecture Decision Records (MADR) — applying the same decision-making framework to graduation gates. [Dora metrics](https://dora.dev/) — quality gates based on measured deployment frequency, lead time, and failure rate.

**SCARS lens:** Cohesion — a gate process without written criteria has low cohesion between the decision made and the justification for it. Outcomes do not align with logic.

---

### AP-16-C: Eternal Candidate

**What it is:** A service has been "in staging" or "in beta" or "in production but not fully graduated" for an extended period — often with real production traffic and real customer impact — because nobody has made the graduation decision. It carries the risk of a production service without the governance.

**Sign:** A service described as "basically production" or "not quite there yet" for more than 90 days. It is serving real traffic but is not on the on-call rotation because it is "still in beta." Dependencies have been added to it by other services ("we're taking the risk because it's useful").

**Why it happens:** Making the graduation decision requires clarity. Does the service meet the criteria? If not, what work is blocking it? If it does, why not graduate? If the criteria are not clear (see AP-16-B), the decision cannot be made. The service enters a limbo state — treated as production by consumers, treated as temporary by owners.

**The cost of eternal candidates:**

```
Payments SDK — "in beta" for 18 months

Month 1:   "We'll graduate it next quarter"
           Three services begin consuming it
           Traffic: ~1% of all payment volume
           
Month 6:   "The architecture review hasn't met, so it's not official"
           Now consuming 15% of payment volume
           Three more services have signed up
           Still no on-call coverage (it's "beta")
           
Month 12:  Incident: Payments SDK gets overloaded, affects 
           three dependent services that are not expecting it
           
           Question: Who is responsible?
           - Payments SDK team: "It's beta, we don't have SLA"
           - Dependent services: "We depend on it, someone should own it"
           - Platform team: "It never finished review, so it's not our problem"
           
           Result: No clear ownership, no on-call rotation,
           no accountability.
           
Month 18:  Graduation decision finally made.
           Only then do they discover the accumulated debt
           and that two of the five dependencies are now critical.
```

**The fix — P16 applied:** Graduation decision dates are set at launch. On the decision date, the service graduates, re-enters incubation with updated criteria, or is retired. "Continue as-is indefinitely" is not a valid outcome.

```yaml
# Service lifecycle — mandatory decision point
service-lifecycle:
  incubation-phase:
    duration: "3-6 months"
    status: "non-production, experimental, limited scope"
    governance: "building team owns all decisions"
    decision-date: "6 months after launch (immovable)"
    
  graduation-decision-outcomes:
    - PROMOTE: Service meets criteria → becomes production
    - EXTEND: Criteria not met, but pathway is clear → 
      extend incubation 90 days with specific work items
    - RETIRE: Service is not viable → deprecate and remove
    
  no-valid-outcome: "Continue in beta indefinitely"
  
  decision-review: "Made by platform/architecture team, not building team"
  decision-appeals: "Building team can appeal; decision reviewed again"
```

**Validated reference:** Product development lifecycle models — stage-gate process (Phase-gate). Kubernetes Kubernetes Enhancement Proposals (KEP) — alpha/beta/stable lifecycle with explicit graduation criteria. The Pragmatic Programmer — "Invest Regularly in Your Knowledge Portfolio" — same principle applied to service maturity.

**SCARS lens:** Simplify — an eternal candidate is not making a decision (keep it beta) or a decision (graduate it). It is complexity in a liminal state. Removing the liminal state simplifies the system.

---

## Fitness functions

```yaml
name: Succession Gates Guard

checks:
  - name: No services older than 90 days in beta
    query: |
      services WHERE status = beta 
      AND created_date < 90 days ago
    fail_if: count > 0
    action: Graduate or retire these services; no indefinite beta
    
  - name: Graduation criteria are written and measurable
    query: graduation_criteria
    fail_if: criteria_undefined OR criteria_subjective
    action: Define criteria using template (load test, SLA history, runbook)
    
  - name: Graduation decisions are consistent across services
    query: |
      graduation_reviews 
      WHERE reviewed_by different architects
      GROUP BY criterion
    warn_if: same_criterion rejected in some reviews, approved in others
    action: Review for consistency; document any exceptions with reasoning
    
  - name: Premature graduates are caught in incident review
    query: |
      incidents WHERE service_age_at_incident < 6_months
      AND incident_class in [load_related, underestimated_scale]
    action: If count > 0, review graduation criteria for adequacy
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-09 SLA Theatre](ap-09-carrying-capacity-monitors.md) | Premature graduation and SLA Theatre compound — services graduate without SLA data, then declare SLAs they don't honour |
| [AP-02 Undeclared Keystone](ap-02-keystone-interface.md) | Eternal candidates often become undeclared keystones — others depend on them without visibility |
| [AP-11 Invisible Blast Radius](ap-11-cascade-risk-detectors.md) | Beta services with real consumers create invisible blast radius — they fail without coordination |

---

*See also: [AP-README](README.md) for the full antipattern index.*
