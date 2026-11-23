<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# ADR 0003: JSON for Structured Outputs

**Status:** Proposed

## Context

Actions report lists today as comma-separated or space-separated
strings, and some outputs switch between a scalar and a JSON object
depending on the run. A comma or space inside a file name makes these
lists ambiguous, and callers need separate parsing code for each
action.

## Decision

Structured results use JSON with a published schema
([`schema/results.schema.json`](../../schema/results.schema.json)). The
action writes the full results to a file named by `results_path`, and
also exposes them as the `results` output while they fit within
GitHub's output limits. Existing list outputs stay as deprecated
aliases.

## Consequences

- Callers parse results with `fromJSON()` or `jq`, the same way for
  every action.
- Results for large batches stay complete, because the file has no
  output size limit.
- Each action needs to write correct JSON from shell, which calls for
  a tool such as `jq` rather than string concatenation.
