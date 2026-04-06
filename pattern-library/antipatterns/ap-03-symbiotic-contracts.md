# AP-03 — Symbiotic Contracts Antipatterns

**Pattern this relates to:** [P03 Symbiotic Contracts](../patterns/p03-symbiotic-contracts/)
**Category:** Structural / Architectural

---

### AP-03-A: Schema Blindness

**What it is:** Schema changes are made without knowing which consumers will break. Discovery happens in production.

**Sign:** "Deploy and see what breaks" is a real strategy for schema changes.

**The fix:** Consumer-driven contract tests in CI. [Pact](https://docs.pact.io/) — every consumer publishes a contract; the producer verifies against all contracts before deploying.

---

### AP-03-B: Consumer-Driven Contract Washing

**What it is:** Pact tests exist but are not enforced in CI. They run somewhere, occasionally. They fail occasionally. Nobody is blocked.

**Sign:** The Pact broker shows contract failures that have been present for weeks.

**The fix:** Pact verification is a CI gate. Provider can-i-deploy check is required before every production deployment.

---

### AP-03-C: Backwards Compatibility Forever

**What it is:** Every schema change must be backwards compatible forever. No field is ever removed. No version is ever sunset. The schema becomes a museum of every decision ever made.

**Sign:** Schema has fields named `deprecated_field_v1`, `deprecated_field_v2`, `old_customer_id_do_not_use`.

**The fix:** Schema versioning with explicit sunset dates. Consumers have a migration window (typically 2 sprints). After the window, the old version is retired. [Evolutionary Architecture](https://evolutionaryarchitecture.com) — fitness function for maximum active schema versions.

**Validated reference:** Stripe's API versioning strategy. [AsyncAPI](https://www.asyncapi.com/) schema versioning specification.

---

*See also: [AP-README](README.md)*
