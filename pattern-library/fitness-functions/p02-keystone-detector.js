/**
 * P02 — Keystone Interface: Dependency Detector
 * ─────────────────────────────────────────────────────────────────────────────
 * What it measures:
 *   Identifies which interfaces (APIs, shared libraries, databases) are
 *   "keystones" — the ones that, if they changed or failed, would take down
 *   multiple other services with them. These are the points that need higher
 *   standards: versioning, contract tests, change freezes, elevated alerts.
 *
 *   Think of it as a "blast radius" score for each interface.
 *
 * Data source:
 *   Service dependency manifests (service-manifest.json files per service),
 *   or an auto-discovered dependency graph from your service mesh.
 *
 * Threshold:
 *   Fails build if any interface is depended on by more than 3 services
 *   without a registered contract test suite.
 *
 *   Warns (does not fail) if a keystone interface has no documented owner.
 *
 * Related patterns:
 *   P01 Mycelial Mesh    — async decoupling reduces blast radius of keystones
 *   P05 Niche Partition  — clear domain ownership prevents accidental keystones
 *   P11 Cascade Risk     — monitors runtime behaviour of keystone paths
 *
 * Usage:
 *   node fitness-functions/p02-keystone-detector.js
 *   Or: node fitness-functions/p02-keystone-detector.js --manifest ./service-manifest.json
 * ─────────────────────────────────────────────────────────────────────────────
 */

'use strict';

const fs = require('fs');
const path = require('path');

// ── CONFIG ───────────────────────────────────────────────────────────────────

const CONFIG = {
  // An interface with this many or more dependents is a keystone
  KEYSTONE_THRESHOLD: 3,

  // A keystone without contract tests → build fails
  CONTRACT_TEST_REQUIRED_ABOVE: 3,

  // A keystone without a registered owner → warning only (does not fail)
  OWNER_REQUIRED_ABOVE: 2,

  // Path to the dependency manifest. Override with --manifest flag.
  MANIFEST_PATH: process.argv.includes('--manifest')
    ? process.argv[process.argv.indexOf('--manifest') + 1]
    : path.join(__dirname, '..', 'service-manifest.json'),

  DATA_SOURCE: process.env.DEPENDENCY_SOURCE || 'mock',
};

// ── DATA SOURCES ─────────────────────────────────────────────────────────────

/**
 * Returns the full service dependency graph.
 *
 * In production, this reads from service-manifest.json files committed
 * by each team, or from auto-discovery via your service mesh.
 *
 * Format:
 * {
 *   services: [
 *     {
 *       name: "order-service",
 *       dependsOn: ["payment-api", "inventory-api", "user-service"],
 *       contractTests: ["payment-api"],   // which deps have contract tests
 *       owner: "checkout-team"
 *     }
 *   ],
 *   interfaces: [
 *     {
 *       name: "payment-api",
 *       owner: "payments-team",
 *       hasContractTests: true,
 *       version: "v2"
 *     }
 *   ]
 * }
 */
async function fetchDependencyGraph() {
  if (CONFIG.DATA_SOURCE !== 'mock' && fs.existsSync(CONFIG.MANIFEST_PATH)) {
    const raw = fs.readFileSync(CONFIG.MANIFEST_PATH, 'utf-8');
    return JSON.parse(raw);
  }

  // ── MOCK DATA — replace with real manifest or service mesh discovery ──────
  return {
    services: [
      {
        name: 'order-service',
        dependsOn: ['payment-api', 'inventory-api', 'user-service'],
        contractTests: ['payment-api'],
        owner: 'checkout-team',
      },
      {
        name: 'fulfilment-service',
        dependsOn: ['inventory-api', 'user-service', 'notification-api'],
        contractTests: ['inventory-api'],
        owner: 'fulfilment-team',
      },
      {
        name: 'returns-service',
        dependsOn: ['inventory-api', 'payment-api', 'user-service'],
        contractTests: [],
        owner: 'returns-team',
      },
      {
        name: 'analytics-service',
        dependsOn: ['user-service'],
        contractTests: ['user-service'],
        owner: 'data-team',
      },
    ],
    interfaces: [
      { name: 'payment-api',      owner: 'payments-team',  hasContractTests: true,  version: 'v2' },
      { name: 'inventory-api',    owner: 'inventory-team', hasContractTests: true,  version: 'v1' },
      { name: 'user-service',     owner: null,             hasContractTests: false, version: 'v1' },
      { name: 'notification-api', owner: 'comms-team',     hasContractTests: false, version: 'v1' },
    ],
  };
}

// ── ANALYSIS ─────────────────────────────────────────────────────────────────

/**
 * Builds a dependency count map: interface name → list of dependents
 */
function buildDependencyMap(graph) {
  const map = {};

  for (const service of graph.services) {
    for (const dep of service.dependsOn) {
      if (!map[dep]) map[dep] = [];
      map[dep].push(service.name);
    }
  }

  return map;
}

/**
 * Enriches each interface with its dependent count and keystone status
 */
function scoreInterfaces(graph, dependencyMap) {
  return graph.interfaces.map(iface => {
    const dependents = dependencyMap[iface.name] || [];
    const isKeystone = dependents.length >= CONFIG.KEYSTONE_THRESHOLD;

    // Check which services depending on this interface have contract tests
    const testedBy = graph.services
      .filter(s => s.contractTests.includes(iface.name))
      .map(s => s.name);

    const untestedDependents = dependents.filter(
      d => !graph.services.find(s => s.name === d && s.contractTests.includes(iface.name))
    );

    return {
      ...iface,
      dependents,
      dependentCount: dependents.length,
      isKeystone,
      testedBy,
      untestedDependents,
      needsContractTests: isKeystone && untestedDependents.length > 0,
      needsOwner: dependents.length >= CONFIG.OWNER_REQUIRED_ABOVE && !iface.owner,
    };
  });
}

// ── RUNNER ────────────────────────────────────────────────────────────────────

async function run() {
  console.log('━━━ P02 Keystone Detector ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`Keystone threshold: ≥${CONFIG.KEYSTONE_THRESHOLD} dependents`);
  console.log('');

  let exitCode = 0;
  const warnings = [];

  const graph = await fetchDependencyGraph();
  const dependencyMap = buildDependencyMap(graph);
  const interfaces = scoreInterfaces(graph, dependencyMap);

  // Sort: most-depended-on first
  const sorted = [...interfaces].sort((a, b) => b.dependentCount - a.dependentCount);

  // ── Print the full dependency map ────────────────────────────────────────
  console.log('Interface dependency map:');
  console.log('');

  for (const iface of sorted) {
    const keystoneLabel = iface.isKeystone ? ' [KEYSTONE]' : '';
    const ownerLabel = iface.owner ? `owner: ${iface.owner}` : 'owner: UNREGISTERED';
    console.log(`  ${iface.name}${keystoneLabel}`);
    console.log(`    dependents (${iface.dependentCount}): ${iface.dependents.join(', ') || 'none'}`);
    console.log(`    ${ownerLabel}  |  version: ${iface.version}`);
    console.log(`    contract tests: ${iface.testedBy.length > 0 ? iface.testedBy.join(', ') : 'none'}`);
    console.log('');
  }

  // ── Check: contract tests required for keystones ─────────────────────────
  const contractViolations = interfaces.filter(i => i.needsContractTests);
  if (contractViolations.length > 0) {
    console.error('✗  Contract test violations (keystones with untested dependents):');
    for (const v of contractViolations) {
      console.error(`   ${v.name}: ${v.untestedDependents.length} dependent(s) have no contract tests`);
      console.error(`   Untested: ${v.untestedDependents.join(', ')}`);
      console.error(`   → Add consumer-driven contract tests (Pact recommended)`);
    }
    console.log('');
    exitCode = 1;
  } else {
    console.log('✓  Contract tests: all keystones have coverage');
    console.log('');
  }

  // ── Warn: unowned interfaces with dependents ──────────────────────────────
  const ownerViolations = interfaces.filter(i => i.needsOwner);
  if (ownerViolations.length > 0) {
    console.warn('⚠  Ownership warnings (will not fail build):');
    for (const v of ownerViolations) {
      console.warn(`   ${v.name}: ${v.dependentCount} dependents, no registered owner`);
      console.warn(`   → Register an owner in service-manifest.json`);
    }
    console.log('');
  }

  // ── Summary ───────────────────────────────────────────────────────────────
  const keystones = interfaces.filter(i => i.isKeystone);
  console.log(`Summary: ${keystones.length} keystone interface(s) identified across ${graph.interfaces.length} total`);
  console.log('');

  if (exitCode === 0) {
    console.log('━━━ PASSED ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } else {
    console.error('━━━ FAILED ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.error('Add consumer-driven contract tests to resolve failures.');
    console.error('See: https://docs.pact.io/ for implementation guidance.');
  }

  process.exit(exitCode);
}

run().catch(err => {
  console.error('Keystone detector error:', err.message);
  process.exit(1);
});
