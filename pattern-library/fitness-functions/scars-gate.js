/**
 * SCARS Gate — Structural Health Check
 * ─────────────────────────────────────────────────────────────────────────────
 * What it does:
 *   Runs five structural checks before deployment. Based on Ruth Malan's SCARS
 *   heuristics (Separation, Cohesion, Abstraction, Responsibilities, Simplify).
 *   Fails the build if any check detects a structural violation.
 *
 *   This runs FIRST in your CI/CD pipeline, before the pattern-specific
 *   fitness functions (p01-coupling-guard, p02-keystone-detector, etc.)
 *
 * Pipeline order (recommended):
 *   1. scars-gate.js          ← this file
 *   2. p01-coupling-guard.js
 *   3. p02-keystone-detector.js
 *   4. [other pattern fitness functions]
 *   5. Deploy
 *
 * Each check:
 *   S — Separation: does this service do more than one thing?
 *   C — Cohesion: are things that change together, kept together?
 *   A — Abstraction: are implementation details leaking into the API?
 *   R — Responsibilities: is load balanced, or is one service carrying everything?
 *   S — Simplify: is complexity being added where it could be removed?
 *
 * Data source:
 *   service-manifest.json — teams self-report their service metadata.
 *   Replace individual checks with real static analysis / telemetry as needed.
 *
 * Usage:
 *   node pattern-library/fitness-functions/scars-gate.js
 * ─────────────────────────────────────────────────────────────────────────────
 */

'use strict';

const fs = require('fs');
const path = require('path');

// ── CONFIG ───────────────────────────────────────────────────────────────────

const CONFIG = {
  // S — Separation: fail if a service declares more than this many responsibilities
  MAX_RESPONSIBILITIES_PER_SERVICE: 3,

  // C — Cohesion: fail if a service has dependencies in more than this many domains
  MAX_DOMAINS_PER_SERVICE: 2,

  // A — Abstraction: fail if internal implementation terms appear in public API paths
  FORBIDDEN_API_TERMS: ['database', 'db', 'internal', 'impl', 'private', 'raw', 'direct'],

  // R — Responsibilities: fail if one service handles more than this % of system operations
  MAX_OPERATION_SHARE: 0.40, // 40%

  // S — Simplify: warn if a service has more than this many dependencies (not a hard fail by default)
  DEPENDENCY_COUNT_WARNING: 5,

  MANIFEST_PATH: process.env.MANIFEST_PATH ||
    path.join(__dirname, '..', 'service-manifest.json'),

  DATA_SOURCE: process.env.SCARS_SOURCE || 'mock',
};

// ── DATA SOURCES ─────────────────────────────────────────────────────────────

async function fetchServiceManifest() {
  if (CONFIG.DATA_SOURCE !== 'mock' && fs.existsSync(CONFIG.MANIFEST_PATH)) {
    const raw = fs.readFileSync(CONFIG.MANIFEST_PATH, 'utf-8');
    return JSON.parse(raw);
  }

  // ── MOCK DATA — replace with your service-manifest.json ──────────────────
  // Each team maintains this file for their service.
  // Schema is defined in docs/service-manifest-schema.json
  return {
    services: [
      {
        name: 'order-service',
        domain: 'checkout',
        responsibilities: ['accept orders', 'validate cart', 'apply promotions'],
        publicApiPaths: ['/orders', '/orders/:id', '/orders/:id/status'],
        dependsOn: ['payment-api', 'inventory-api', 'user-service'],
        dependencyDomains: ['payments', 'inventory'],
        operationsPerDay: 50000,
        owner: 'checkout-team',
      },
      {
        name: 'god-service',
        domain: 'platform',
        // Deliberately bad example to trigger violations
        responsibilities: [
          'process payments', 'send emails', 'manage users',
          'generate reports', 'handle returns',
        ],
        publicApiPaths: ['/internal/db/query', '/raw/data', '/payments', '/users'],
        dependsOn: ['postgres', 'redis', 'kafka', 'elasticsearch', 's3', 'smtp'],
        dependencyDomains: ['storage', 'messaging', 'search', 'notifications', 'auth'],
        operationsPerDay: 200000,
        owner: 'platform-team',
      },
      {
        name: 'notification-service',
        domain: 'comms',
        responsibilities: ['send email', 'send SMS'],
        publicApiPaths: ['/notifications', '/notifications/preferences'],
        dependsOn: ['user-service', 'template-api'],
        dependencyDomains: ['users'],
        operationsPerDay: 30000,
        owner: 'comms-team',
      },
    ],
  };
}

// ── CHECKS ───────────────────────────────────────────────────────────────────

/**
 * S — Separation of concerns
 * A service that does many unrelated things is hard to change and hard to own.
 * If you can't describe what a service does in one sentence, it's doing too much.
 */
function checkSeparation(services) {
  const violations = services
    .filter(s => s.responsibilities.length > CONFIG.MAX_RESPONSIBILITIES_PER_SERVICE)
    .map(s => ({
      service: s.name,
      responsibilityCount: s.responsibilities.length,
      responsibilities: s.responsibilities,
      threshold: CONFIG.MAX_RESPONSIBILITIES_PER_SERVICE,
      recommendedPattern: 'P05 Niche Partitioning — split by responsibility domain',
    }));

  return { check: 'S — Separation', violations };
}

/**
 * C — Cohesion
 * A service that reaches into many different domains is coupled to all of them.
 * When any one of those domains changes, this service is affected.
 */
function checkCohesion(services) {
  const violations = services
    .filter(s => s.dependencyDomains.length > CONFIG.MAX_DOMAINS_PER_SERVICE)
    .map(s => ({
      service: s.name,
      domainCount: s.dependencyDomains.length,
      domains: s.dependencyDomains,
      threshold: CONFIG.MAX_DOMAINS_PER_SERVICE,
      recommendedPattern: 'P01 Mycelial Mesh — use events to decouple cross-domain calls',
    }));

  return { check: 'C — Cohesion', violations };
}

/**
 * A — Abstraction
 * If your public API paths contain words like "database", "internal", or "impl",
 * your implementation is leaking out. Consumers now depend on your internals.
 */
function checkAbstraction(services) {
  const violations = [];

  for (const service of services) {
    const leakyPaths = service.publicApiPaths.filter(apiPath =>
      CONFIG.FORBIDDEN_API_TERMS.some(term =>
        apiPath.toLowerCase().includes(term)
      )
    );

    if (leakyPaths.length > 0) {
      violations.push({
        service: service.name,
        leakyPaths,
        recommendedPattern: 'P02 Keystone Interface — define stable, intention-revealing API contracts',
      });
    }
  }

  return { check: 'A — Abstraction', violations };
}

/**
 * R — Responsibilities (load distribution)
 * If one service handles a disproportionate share of system operations,
 * it becomes a single point of failure and a bottleneck to independent scaling.
 */
function checkResponsibilities(services) {
  const totalOps = services.reduce((sum, s) => sum + s.operationsPerDay, 0);
  const violations = services
    .filter(s => (s.operationsPerDay / totalOps) > CONFIG.MAX_OPERATION_SHARE)
    .map(s => ({
      service: s.name,
      share: (s.operationsPerDay / totalOps),
      operationsPerDay: s.operationsPerDay,
      totalOps,
      threshold: CONFIG.MAX_OPERATION_SHARE,
      recommendedPattern: 'P09 Carrying Capacity — monitor load; P05 Niche Partitioning — distribute responsibility',
    }));

  return { check: 'R — Responsibilities', violations };
}

/**
 * S — Simplify
 * Services with many dependencies are hard to reason about and test.
 * This is a warning, not a hard fail — but it's a signal to investigate.
 */
function checkSimplify(services) {
  const warnings = services
    .filter(s => s.dependsOn.length > CONFIG.DEPENDENCY_COUNT_WARNING)
    .map(s => ({
      service: s.name,
      dependencyCount: s.dependsOn.length,
      dependencies: s.dependsOn,
      threshold: CONFIG.DEPENDENCY_COUNT_WARNING,
      recommendation: 'Review: can any of these dependencies be removed, merged, or replaced with an event subscription?',
    }));

  return { check: 'S — Simplify', warnings }; // warnings only, not violations
}

// ── RUNNER ────────────────────────────────────────────────────────────────────

async function run() {
  console.log('━━━ SCARS Gate ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('Structural health check — runs before pattern fitness functions');
  console.log('Based on Ruth Malan\'s SCARS heuristics (Bredemeyer Consulting)');
  console.log('');

  let exitCode = 0;

  const manifest = await fetchServiceManifest();
  const { services } = manifest;

  console.log(`Checking ${services.length} service(s)...`);
  console.log('');

  const separationResult    = checkSeparation(services);
  const cohesionResult      = checkCohesion(services);
  const abstractionResult   = checkAbstraction(services);
  const responsibilityResult = checkResponsibilities(services);
  const simplifyResult      = checkSimplify(services);

  // ── Print results ─────────────────────────────────────────────────────────

  const allChecks = [
    separationResult,
    cohesionResult,
    abstractionResult,
    responsibilityResult,
  ];

  for (const result of allChecks) {
    if (result.violations.length === 0) {
      console.log(`✓  ${result.check}`);
    } else {
      console.error(`✗  ${result.check} — ${result.violations.length} violation(s):`);
      for (const v of result.violations) {
        console.error(`   Service: ${v.service}`);
        const detail = v.responsibilities || v.domains || v.leakyPaths || [];
        if (detail.length > 0) {
          console.error(`   Detail: ${detail.join(', ')}`);
        }
        if (v.share) {
          console.error(`   Load share: ${(v.share * 100).toFixed(1)}% (limit: ${v.threshold * 100}%)`);
        }
        console.error(`   Fix: ${v.recommendedPattern}`);
      }
      exitCode = 1;
    }
    console.log('');
  }

  // ── Simplify is warnings only ─────────────────────────────────────────────
  if (simplifyResult.warnings.length > 0) {
    console.warn(`⚠  ${simplifyResult.check} — ${simplifyResult.warnings.length} service(s) to review:`);
    for (const w of simplifyResult.warnings) {
      console.warn(`   ${w.service}: ${w.dependencyCount} dependencies (review above ${w.threshold})`);
      console.warn(`   Dependencies: ${w.dependencies.join(', ')}`);
      console.warn(`   ${w.recommendation}`);
    }
    console.log('');
  } else {
    console.log(`✓  ${simplifyResult.check} — no complexity warnings`);
    console.log('');
  }

  // ── Final result ──────────────────────────────────────────────────────────
  if (exitCode === 0) {
    console.log('━━━ PASSED ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('SCARS gate clear. Proceeding to pattern fitness functions.');
  } else {
    console.error('━━━ FAILED ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.error('Resolve SCARS violations before running pattern fitness functions.');
    console.error('Reference: pattern-library/scars-diagnostic/README.md');
  }

  process.exit(exitCode);
}

run().catch(err => {
  console.error('SCARS gate error:', err.message);
  process.exit(1);
});
