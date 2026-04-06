#!/usr/bin/env node
/**
 * Service Manifest Validator
 * ─────────────────────────────────────────────────────────────────────────────
 * Validates service-manifest.json against the schema.
 *
 * Usage:
 *   node validate-manifest.js                          (validates ./service-manifest.json)
 *   node validate-manifest.js ./path/to/manifest.json  (validates custom path)
 * ─────────────────────────────────────────────────────────────────────────────
 */

'use strict';

const fs = require('fs');
const path = require('path');

// Simple JSON Schema validator (basic implementation)
// For production, use 'ajv' npm package

class SchemaValidator {
  constructor(schema) {
    this.schema = schema;
    this.errors = [];
  }

  validate(data) {
    this.errors = [];
    this._validateAgainstSchema(data, this.schema, '');
    return this.errors.length === 0;
  }

  _validateAgainstSchema(data, schema, path) {
    // Null check
    if (schema.type === 'null' && data !== null) {
      this.errors.push(`${path || 'root'}: expected null, got ${typeof data}`);
      return;
    }

    // Type validation
    if (schema.type && typeof data !== schema.type && schema.type !== 'null') {
      if (schema.type === 'integer' && !Number.isInteger(data)) {
        this.errors.push(`${path || 'root'}: expected integer, got ${typeof data}`);
        return;
      }
      if (schema.type === 'array' && !Array.isArray(data)) {
        this.errors.push(`${path || 'root'}: expected array, got ${typeof data}`);
        return;
      }
      if (schema.type === 'object' && (typeof data !== 'object' || data === null)) {
        this.errors.push(`${path || 'root'}: expected object, got ${typeof data}`);
        return;
      }
    }

    // Required fields
    if (schema.required && typeof data === 'object' && data !== null) {
      for (const field of schema.required) {
        if (!(field in data)) {
          this.errors.push(`${path || 'root'}.${field}: required field missing`);
        }
      }
    }

    // Array validation
    if (Array.isArray(data)) {
      if (schema.minItems !== undefined && data.length < schema.minItems) {
        this.errors.push(`${path || 'root'}: expected at least ${schema.minItems} items`);
      }
      if (schema.maxItems !== undefined && data.length > schema.maxItems) {
        this.errors.push(`${path || 'root'}: expected at most ${schema.maxItems} items`);
      }

      if (schema.items) {
        for (let i = 0; i < data.length; i++) {
          this._validateAgainstSchema(
            data[i],
            schema.items,
            `${path}[${i}]`
          );
        }
      }
    }

    // Object validation
    if (typeof data === 'object' && data !== null && !Array.isArray(data)) {
      if (schema.properties) {
        for (const [key, value] of Object.entries(data)) {
          if (schema.properties[key]) {
            this._validateAgainstSchema(
              value,
              schema.properties[key],
              `${path}.${key}`
            );
          }
        }
      }

      // String validation
      if (schema.type === 'string') {
        if (schema.minLength !== undefined && data.length < schema.minLength) {
          this.errors.push(`${path}: string length must be >= ${schema.minLength}`);
        }
        if (schema.maxLength !== undefined && data.length > schema.maxLength) {
          this.errors.push(`${path}: string length must be <= ${schema.maxLength}`);
        }
        if (schema.pattern) {
          const regex = new RegExp(`^${schema.pattern}$`);
          if (!regex.test(data)) {
            this.errors.push(`${path}: does not match pattern ${schema.pattern}`);
          }
        }
      }

      // Integer validation
      if (schema.type === 'integer') {
        if (schema.minimum !== undefined && data < schema.minimum) {
          this.errors.push(`${path}: must be >= ${schema.minimum}`);
        }
      }
    }
  }
}

// ── MAIN ───────────────────────────────────────────────────────────────────

async function run() {
  const manifestPath = process.argv[2] || './service-manifest.json';
  const schemaPath = path.join(__dirname, '..', 'docs', 'service-manifest-schema.json');

  console.log(`Validating: ${manifestPath}`);
  console.log('');

  let manifest, schema;

  try {
    const manifestRaw = fs.readFileSync(manifestPath, 'utf-8');
    manifest = JSON.parse(manifestRaw);
  } catch (err) {
    console.error(`❌ Cannot read manifest: ${err.message}`);
    process.exit(1);
  }

  try {
    const schemaRaw = fs.readFileSync(schemaPath, 'utf-8');
    schema = JSON.parse(schemaRaw);
  } catch (err) {
    console.error(`❌ Cannot read schema: ${err.message}`);
    process.exit(1);
  }

  const validator = new SchemaValidator(schema);
  const isValid = validator.validate(manifest);

  if (isValid) {
    console.log('✓ Manifest is valid');
    console.log('');

    // Print summary
    const serviceCount = manifest.services ? manifest.services.length : 0;
    const interfaceCount = manifest.interfaces ? manifest.interfaces.length : 0;

    console.log(`Services: ${serviceCount}`);
    if (manifest.services) {
      for (const service of manifest.services) {
        console.log(`  - ${service.name} (${service.domain} domain, ${service.operationsPerDay} ops/day)`);
      }
    }
    console.log('');

    if (interfaceCount > 0) {
      console.log(`Interfaces: ${interfaceCount}`);
      if (manifest.interfaces) {
        for (const iface of manifest.interfaces) {
          const contractStatus = iface.hasContractTests ? '✓' : '✗';
          console.log(`  ${contractStatus} ${iface.name} (v${iface.version})`);
        }
      }
      console.log('');
    }

    // Validation checks
    console.log('Validation checks:');
    let checksPassed = 0;
    let checksFailed = 0;

    if (manifest.services) {
      for (const service of manifest.services) {
        // Separation check
        if (service.responsibilities.length > 3) {
          console.log(`  ⚠️  ${service.name}: ${service.responsibilities.length} responsibilities (should be ≤ 3)`);
          checksFailed++;
        } else {
          checksPassed++;
        }

        // Cohesion check
        if (service.dependencyDomains.length > 2) {
          console.log(`  ⚠️  ${service.name}: depends on ${service.dependencyDomains.length} domains (should be ≤ 2)`);
          checksFailed++;
        } else {
          checksPassed++;
        }

        // Abstraction check
        const forbiddenTerms = ['database', 'db', 'internal', 'impl', 'private', 'raw', 'direct'];
        const leakyPaths = service.publicApiPaths.filter(p =>
          forbiddenTerms.some(t => p.toLowerCase().includes(t))
        );
        if (leakyPaths.length > 0) {
          console.log(`  ⚠️  ${service.name}: API paths contain implementation details: ${leakyPaths.join(', ')}`);
          checksFailed++;
        } else {
          checksPassed++;
        }

        // Simplify check
        if (service.dependsOn.length > 5) {
          console.log(`  ⚠️  ${service.name}: ${service.dependsOn.length} dependencies (consider decoupling with events)`);
          checksFailed++;
        } else {
          checksPassed++;
        }
      }
    }

    console.log(`  ${checksPassed} passed, ${checksFailed} warnings`);
    console.log('');
    console.log('Ready for SCARS gate: node pattern-library/fitness-functions/scars-gate.js');
    process.exit(0);
  } else {
    console.error('❌ Manifest validation failed:');
    console.error('');
    for (const error of validator.errors) {
      console.error(`   ${error}`);
    }
    console.error('');
    console.log('Reference: docs/service-manifest-guide.md');
    process.exit(1);
  }
}

run().catch(err => {
  console.error('Validator error:', err.message);
  process.exit(1);
});
