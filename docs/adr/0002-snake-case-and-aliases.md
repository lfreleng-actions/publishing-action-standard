<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# ADR 0002: `snake_case` Names, With Aliases for the Rest

**Status:** Proposed

## Context

Most `lfreleng-actions` inputs and outputs use `snake_case`. Central
uses hyphenated names, such as `dry-run` and `m2repo-path`, and Node
uses a hyphenated value, `skip-if-identical`. Renaming inputs in place
would break every workflow that calls those actions.

## Decision

Input names, output names and enumerated values use `snake_case`.
Where an action uses another form today, it adds the `snake_case` name
or value alongside the old one. The old form keeps working, logs a
deprecation warning, and goes away in a later major release. Setting
an input and its alias to different values fails the run.

## Consequences

- Callers can move to the new names at their own pace.
- Each action carries alias handling until the next major release.
- The declaration lists every alias, so reviewers and tools can see
  them. A value alias also names the input that accepts it.
