<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# Schema Cases

`check-schema-cases.sh` runs each document in `schema-cases/` against
its target, under both the ECMAScript and the Python regex dialects of
`check-jsonschema`, and fails when a schema accepts or rejects a
document against expectations. The `schema-cases` pre-commit hook runs
it whenever a schema or a case changes.

Each directory under `schema-cases/` holds:

- `target.yaml`: a `$ref` to the part of a schema under test, such as
  `#/properties/standard_commit`.
- `valid-*.yaml`: documents the target must accept.
- `invalid-*.yaml`: documents the target must reject. A comment in
  each file says why. Give each one a single error, so that removing
  the rule it targets makes the case fail.

Add cases in the same pull request as any schema change, and include
a rejection case for each pattern anchor.

```bash
tests/check-schema-cases.sh
```
