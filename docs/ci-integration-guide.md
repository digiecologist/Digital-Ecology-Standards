# CI/CD Integration Guide

The Ecological Engineering Standards framework includes a GitHub Actions workflow that automatically runs architectural health checks on every push to `main` and every pull request.

## Pipeline Architecture

The CI pipeline enforces a strict ordering:

```
┌─────────────────────────────────────────────────────────────┐
│  Push to main / Pull Request                                 │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
           ┌─────────────────────┐
           │  Checkout & Setup   │
           │  Node.js 20         │
           └──────────┬──────────┘
                      │
                      ▼
           ┌─────────────────────┐
           │ 1. SCARS Gate       │  ← MUST PASS FIRST
           │ (Structural Health) │
           └──────────┬──────────┘
                      │
                      ├─ If FAILS: PR blocked, detailed report
                      │
                      ├─ If PASSES:
                      │
                      ▼
           ┌─────────────────────────────────┐
           │ 2. P01 Coupling Guard           │
           │ (when implemented)               │
           └──────────┬──────────────────────┘
                      │
                      ▼
           ┌─────────────────────────────────┐
           │ 3. P02 Keystone Detector        │
           │ (when implemented)               │
           └──────────┬──────────────────────┘
                      │
                      ├─ Additional patterns...
                      │
                      ▼
           ┌─────────────────────┐
           │ pipeline: SUCCESS   │
           └─────────────────────┘
```

## SCARS Gate (Always First)

The SCARS gate runs **before** any pattern-specific checks because it validates foundational structural health:

- **Separation**: Services have ≤ 3 responsibilities
- **Cohesion**: Services depend on ≤ 2 domains
- **Abstraction**: API paths don't leak implementation terms
- **Responsibilities**: No single service > 40% of system load
- **Simplify**: Dependency count ≤ 5 (warning if > 5)

**Configuration**: Edit `pattern-library/fitness-functions/scars-gate.js` to adjust thresholds.

## Adding Pattern Fitness Functions

When a pattern's fitness function is ready to integrate:

1. **Create the script**: `pattern-library/fitness-functions/pXX-pattern-name.js`
   - Must exit with code 0 on pass, 1 on fail
   - Should log violations clearly
   - Accept environment variables for data sources

2. **Add to workflow**: Uncomment the corresponding step in `.github/workflows/ecological-health.yml`

3. **Test locally first**:
   ```bash
   node pattern-library/fitness-functions/p01-coupling-guard.js
   ```

## Environment Variables

The workflow respects these GitHub Secrets (optional, fallback to 'mock'):

| Variable | Purpose | Default | Example |
|----------|---------|---------|---------|
| `TELEMETRY_SOURCE` | Where to fetch metrics | `mock` | `prometheus`, `datadog` |
| `PROMETHEUS_URL` | Prometheus endpoint | (none) | `https://prometheus.example.com` |
| `DEPENDENCY_SOURCE` | Where to get service deps | `mock` | `manifest`, `gradle` |
| `MANIFEST_PATH` | Path to service manifest | `./service-manifest.json` | `./infra/manifest.json` |
| `SCARS_SOURCE` | Data source for SCARS checks | `mock` | `manifest`, `prometheus` |

**To set secrets**: GitHub repo → Settings → Secrets and variables → Actions → New repository secret

## Local Testing

Before pushing, test the pipeline locally:

```bash
# Test SCARS gate
node pattern-library/fitness-functions/scars-gate.js

# Test with specific manifest
MANIFEST_PATH=./service-manifest.json node pattern-library/fitness-functions/scars-gate.js

# Test P01 when ready
node pattern-library/fitness-functions/p01-coupling-guard.js
```

## Handling Pipeline Failures

When the workflow blocks a PR:

1. **Read the step output**: Click the failed step in GitHub Actions
2. **Check the violation type**: Is it SCARS Gate or a pattern check?
3. **Update `service-manifest.json`** in your PR to fix:
   - Split services with > 3 responsibilities (P05)
   - Reduce dependency domains to ≤ 2
   - Remove implementation terms from API paths
   - Rebalance load if one service > 40%
   - Trim dependencies to ≤ 5

4. **Re-run the workflow**: Push an update and GitHub will retest

### Example Failure: Separation Violation

Workflow output:
```
✗ Separation failed
  Service: order-service
  Responsibilities (4): [order-processing, refund-handling, notification-coordination, analytics-tracking]
  Threshold: 3
  → Split analytics-tracking to dedicated analytics-engine
  → Move notification-coordination to notification-service (P02 keystone)
```

**Fix**: Update `service-manifest.json` to reduce responsibilities, split into new services, then retest.

## Metrics Review

After each successful run, review:

- **Architectural Health Score**: All SCARS checks passed ✓
- **Pattern Adoption**: Which patterns are in use
- **Velocity Impact**: Did refactoring change deployment frequency?

For tracking over time, consider:

```bash
# See workflow run history
gh run list --workflow=ecological-health.yml --limit 10

# Download specific run logs
gh run download <run-id> --dir workflow-logs/
```

## Common Issues

### "node: command not found"
- Workflow uses Node 20. For local testing, ensure `node --version` is 18+.

### SCARS Gate passes locally but fails in CI
- **Likely cause**: `SCARS_SOURCE=mock` in CI but you're using real manifest locally
- **Fix**: Set `MANIFEST_PATH` or `SCARS_SOURCE` in GitHub Secrets

### "Cannot find module..."
- Fitness functions should only import Node.js built-ins (`fs`, `path`, `util`)
- No npm dependencies allowed (keep pipeline lightweight and offline-capable)

## Future: Distributed Checks

As pattern fitness functions expand (P05, P09, P11, etc.), the workflow can parallelize checks:

```yaml
jobs:
  scars-gate:
    runs-on: ubuntu-latest
    steps: [SCARS checks only]
    
  pattern-checks:
    needs: scars-gate  # Only run if SCARS passes
    runs-on: ubuntu-latest
    strategy:
      matrix:
        pattern: [p01, p02, p05, p09, p11]
    steps:
      - run: node pattern-library/fitness-functions/${{ matrix.pattern }}-*.js
```

For now, checks run sequentially to keep logs easy to read and failures clear.

## References

- **SCARS Heuristics**: [Ruth Malan's post](https://www.migrantsworking.com/2018/10/03/on-fit-and-fitness/)
- **Pattern Library**: [pattern-library/README.md](../pattern-library/README.md)
- **Service Manifest**: [docs/service-manifest-quickstart.md](./service-manifest-quickstart.md)
- **GitHub Actions Docs**: [Workflow syntax reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
