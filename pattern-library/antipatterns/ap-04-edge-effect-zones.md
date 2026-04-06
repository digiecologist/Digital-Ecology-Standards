# AP-04 — Edge Effect Zone Antipatterns

**Pattern this relates to:** [P04 Edge Effect Zones](../patterns/p04-edge-effect-zones/)
**Category:** Structural / Architectural
**TL;DR:** Domain boundaries either don't exist in code (they're decoration on diagrams), or they're so rigid they create coordination overhead worse than having no boundaries at all.

---

## The three ways this goes wrong

---

### AP-04-A: Cosmetic Boundary

**What it is:** The architecture diagram shows clear domain boundaries. The codebase does not honour them. Services in the "orders" domain call services in the "inventory" domain directly and frequently, bypassing any translation or mediation layer. The boundary is a drawing, not a constraint.

**Sign:** The same business concept is represented by different data structures in different services with no translation layer between them. Changes to a core domain entity require coordinated changes across multiple "separate" domains.

**Why it happens:** Domains are named and drawn during architecture planning. The naming creates the illusion of separation. The implementation detail — what actually enforces the boundary — is deferred and then never addressed. The first cross-domain call is made under time pressure, and the second is made because "well, we already do it for the first one."

**What it looks like:**
```
Orders domain service calling Inventory directly:

  POST /internal/inventory/items/check-stock
  
  // No translation. Orders passes its own Order object.
  // Inventory returns its own InventoryItem object.  
  // Both domains now share an implicit data contract
  // that isn't declared, versioned, or tested.
```

**The fix — P04 applied:** Edge effect zones are explicit translation layers at domain boundaries. The Orders domain does not know the Inventory domain's internal model. It speaks to an Anti-Corruption Layer (ACL) that translates between them. When Inventory changes its internal model, Orders is unaffected — only the ACL changes.

```javascript
// Anti-Corruption Layer at the Orders → Inventory boundary
class InventoryACL {
  async checkStockAvailability(orderLineItems) {
    // Translate Orders domain concept → Inventory domain query
    const inventoryQuery = orderLineItems.map(item => ({
      sku: item.productCode,          // Orders calls it productCode
      requiredQuantity: item.qty      // Orders calls it qty
    }));
    
    const inventoryResult = await inventoryService.checkStock(inventoryQuery);
    
    // Translate Inventory domain response → Orders domain concept
    return inventoryResult.items.map(item => ({
      productCode: item.sku,          // Back to Orders language
      available: item.stockLevel > 0,
      fulfillable: item.stockLevel >= item.requiredQuantity
    }));
  }
}
```

**Validated reference:** Eric Evans, Domain-Driven Design — Anti-Corruption Layer pattern. [DDD Reference](https://www.domainlanguage.com/ddd/reference/). Vaughn Vernon, [Implementing Domain-Driven Design](https://vaughnvernon.com/?page_id=168).

**SCARS lens:** Separation — Cosmetic Boundary is a Separation failure. Concerns that should be separate are entangled at the implementation level despite being separated on the diagram.

---

### AP-04-B: Shared Database Seepage

**What it is:** Two services are in different domains — but they share a database schema, or one reads directly from the other's database tables. The domain boundary exists at the service level but not at the data level. Any schema change in one domain's tables risks breaking the other domain's queries silently.

**Sign:** A database migration requires coordination across teams that are supposed to be independent.

**Why it happens:** Database sharing is often inherited from a monolith decomposition where the data was never split. The services are separated; the data is not. Splitting the data requires a migration effort that is deferred under delivery pressure and then never revisited.

**The hidden coupling:**
```sql
-- Inventory service's own tables
inventory.items (sku, stock_level, warehouse_id, ...)

-- Orders service querying Inventory's tables directly
SELECT i.stock_level 
FROM inventory.items i          -- ← Orders reaching across boundary
WHERE i.sku = $1

-- When Inventory renames stock_level to available_quantity:
-- Orders breaks silently at runtime, not at deploy time
```

**The fix — P04 applied:** Each domain owns its data. Cross-domain data access goes through the domain's API, not its database. This is not about microservices dogma — it is about making the dependency explicit and testable.

**Validated reference:** Sam Newman, [Building Microservices](https://samnewman.io/books/building_microservices_2nd_edition/) — Chapter 4, database decomposition strategies. [Strangler Fig pattern](https://martinfowler.com/bliki/StranglerFigApplication.html) for migrating shared databases incrementally.

**SCARS lens:** Cohesion — a domain whose data is accessed by multiple consumers has low data cohesion. The data and the logic that governs it should live in the same bounded context.

---

### AP-04-C: The Rigid Wall

**What it is:** Domain boundaries exist and are enforced — but so rigidly that legitimate cross-domain collaboration requires extensive ceremony. Teams that need to coordinate must go through a formal API change process, raise architecture review requests, and wait weeks for approval. The boundary creates overhead worse than having no boundary.

**Sign:** Cross-domain features take significantly longer than single-domain features. Engineers work around the process rather than through it.

**Why it happens:** Boundaries are implemented as governance gates rather than as technical translation layers. The intent is to prevent bad coupling; the effect is to slow down all coupling, including the legitimate kind.

**The fix — P04 applied:** The edge effect zone is a *managed* transition — not a wall. It allows controlled cross-domain communication with explicit contracts, not zero cross-domain communication with bureaucratic approval. The ACL makes integration safe and fast, not safe and slow.

**Validated reference:** Team Topologies (Skelton & Pais) — interaction modes. X-as-a-Service and collaboration modes are both valid; the error is applying the wrong one. Architecture for Flow (Susanne Kaiser) — cognitive load and coordination cost.

**SCARS lens:** Simplify — a process that makes engineers work around it has failed at Simplify. The boundary should make good behaviour easy, not make all behaviour slow.

---

## Fitness function

```javascript
// fitness-functions/boundaries/check-acl-coverage.js
// Verifies cross-domain calls go through ACL, not direct service calls

async function checkBoundaryCoverage(serviceGraph, domainMap) {
  const violations = [];
  
  for (const edge of serviceGraph.edges) {
    const sourceDomain = domainMap[edge.source];
    const targetDomain = domainMap[edge.target];
    
    if (sourceDomain !== targetDomain) {
      // Cross-domain call — must go through an ACL
      const hasACL = edge.type === 'acl' || edge.through?.type === 'acl';
      
      if (!hasACL) {
        violations.push({
          source: edge.source,
          target: edge.target,
          issue: 'DIRECT_CROSS_DOMAIN_CALL',
          domains: `${sourceDomain} → ${targetDomain}`,
          action: 'Add Anti-Corruption Layer between these domains'
        });
      }
    }
  }
  
  return violations;
}
```

---

## Related antipatterns

| Antipattern | Connection |
|---|---|
| [AP-05 Niche Overlap](ap-05-niche-partitioning.md) | Cosmetic boundaries allow responsibility to bleed between domains |
| [AP-01 Async Monolith](ap-01-mycelial-mesh.md) | Shared database seepage creates the same coupling as direct sync calls |
| [AP-03 Schema Blindness](ap-03-symbiotic-contracts.md) | Seepage makes schema changes risky because consumers are unknown |

---

*See also: [AP-README](README.md) for the full antipattern index.*
