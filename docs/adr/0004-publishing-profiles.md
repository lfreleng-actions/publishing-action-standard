<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# ADR 0004: Profiles Rather Than One Model

**Status:** Proposed

## Context

The publishing actions work in different ways. Some upload prebuilt
files, one stages and then releases a bundle, some build from source,
and some upload packages to registries that track versions. Forcing
them into one model would either weaken the rules or make some
actions impossible to build.

## Decision

The contract states core rules that bind every action, and
[`spec/profiles.md`](../../spec/profiles.md) defines four profiles:
`artifact_upload`, `staged_release`, `build_and_publish` and
`package_upload`. A declaration lists the profiles an action matches,
and the profiles page states where a rule's application depends on the
profile. Actions keep outputs for their backend, such as deployment
identifiers and content digests, beside the common ones.

## Consequences

- Callers get the same core guarantees from every action, and can
  rely on the profile for the rest.
- A new kind of publishing calls for a new profile, through a change
  to this repository and the team's review.
