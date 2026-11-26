<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# Issue Template for Conformance Gaps

Use this structure when filing an issue that brings a publishing
action closer to the [contract](../spec/contract.md). Copy everything
below the line into the issue body and fill it in.

- **Title:** a Conventional Commit subject that can serve as the
  pull request title, for example `Fix: Reject invalid dry-run values`.
- **Type and labels:** `Bug` with `bug` for defects; `Feature` with
  `feature` for interface additions. Add `workflow-edits-ok` when the
  fix needs a change under `.github/workflows/`, such as a new pull
  request test job.

---

```markdown
## Summary

One paragraph: what goes wrong and what the fix achieves.

Rules: PUB-XXX-NN, PUB-XXX-NN
Line numbers are from `<short commit>` on `main`.

## Problem

- `path/to/file` lines N–M: what the code does.
- The trigger, and what happens: how to reproduce it, and what the
  reproduction showed.

## Changes

- What the fix must do, stated as behaviour rather than as code.
- What the change must leave alone, so the scope stays narrow.

## Coordination

Issues or pull requests that touch the same files, and which must
merge first. Write "None" when nothing overlaps.

## Testing

- The scenarios from `conformance/scenarios.md` the tests cover.
- Tests run on pull requests without registry credentials.

## Acceptance criteria

- [ ] Behaviour the fix guarantees
- [ ] Tests that prove it, naming the rule identifiers
- [ ] The README describes the new behaviour
- [ ] Repository hooks pass; Zizmor's `auditor` persona reports no
      findings in changed workflow or action files
```
