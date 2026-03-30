# Tools

Workspace-level automation scripts.

- `check_layer_dependencies.dart`: Enforces package boundary rules and prevents cross-package `src/` imports.
- `check_coverage.dart`: Parses all `coverage/lcov.info` files and enforces a minimum overall line coverage.
- `check_impact_policy.dart`: Enforces test-update policy when core packages change in a PR.
- `scaffold_feature.dart`: Creates a new `packages/feature_*` module skeleton with contract/module/route files and a basic contract test.

Common commands:

```bash
melos run verify:deps
melos run verify:impact
melos run test:coverage
melos run verify:coverage
dart run tools/scaffold_feature.dart --name feature_order --description "Order feature module"
```

Current global line coverage baseline is `5%`.
