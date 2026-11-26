<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# ADR 0001: An Overlay, Not a Template

**Status:** Proposed

## Context

Publishing actions need shared rules for inputs, outputs, previews and
failure handling. `actions-template` already provides each action's
baseline: hooks, commit rules, security workflows, release automation
and the `AGENTS.md` stub. A second starting-point template would copy
that baseline, and each copy would drift from the original.

## Decision

This repository holds an overlay. Authors create a publishing action
from `actions-template` as usual, then apply this standard to the
publishing parts: `action.yaml`, the implementation, its tests, the
README and the declaration file. The repository is not a GitHub
template repository, and holds no copy of the template baseline.

Each action declares which commit of the standard it follows, in
`.github/publishing-contract.yaml` and in its `AGENTS.md`. An agent
working in that repository then finds the standard without relying on
memory.

## Consequences

- Baseline changes go to `actions-template` and reach every action,
  publishing or not.
- The standard can evolve without disturbing the baseline, and each
  action moves to a newer commit of it on purpose.
- The overlay must state which files it may change, so it never edits
  the baseline ([`overlay/apply.md`](../../overlay/apply.md)).
- Shared test code belongs in a harness that actions call by commit,
  not in files copied into each repository.
