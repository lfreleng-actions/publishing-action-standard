<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# Conformance Scenarios

Each publishing action's tests cover every scenario here that applies
to its profiles (PUB-TEST-04). Tests name the scenario and rule
identifiers, so reviewers can trace coverage.

## Harness status

The team plans a reusable conformance harness: actions would call it,
pinned by commit, to run the scenarios that need no knowledge of the
backend, such as boolean parsing, output format and summary opt-out.
Until it exists, each action implements these scenarios in its own
test suite.

## Inputs and modes

- **CS-01 Malformed booleans** (PUB-IN-03, PUB-MODE-03, PUB-FAIL-03;
  all profiles). For every boolean input, `true` and `false` pass. The
  empty string, `yes`, `1`, `ttrue` and values with embedded whitespace
  fail before the action fetches credentials, contacts a network
  service, signs anything or changes caller files. The action may write
  to its scratch space, and still writes its outputs and any summary.
  For `dry_run`, assert that no publication request takes place.
- **CS-02 Unknown enumerated values** (PUB-IN-04, PUB-DEST-05; all).
  Unknown values fail, and never select a default destination.
- **CS-03 Alias conflicts** (PUB-COMPAT-01, PUB-COMPAT-02; actions
  with aliases). An alias alone works and logs a deprecation warning;
  alias and canonical input with equal values work; different values
  fail.
- **CS-04 Preview without publication credentials** (PUB-MODE-04,
  PUB-IN-06; all with preview). A preview with no publication
  credential inputs succeeds, and no step fetches publication
  credentials from inputs, vaults or secret stores. A profile whose
  preview reads remote state may use a separate credential that cannot
  publish; the README documents it, and the test supplies one.
- **CS-05 Preview side effects** (PUB-FX-01; all with preview). The
  preview touches the network and files no more than the declaration
  states. With `network: none`, a test blocks network access and the
  preview still succeeds.

## Selection

- **CS-10 Preview and publication agree** (PUB-SEL-01, PUB-MODE-05,
  PUB-DUP-02; all). For the same inputs and destination state, the
  selection in a preview's results matches the selection in a live
  run's results, item for item. The items the live run sends to a
  fixture destination then match its duplicate policy: under
  `skip_identical`, every selected item except those reported
  `already_present`.
- **CS-11 Path escape** (PUB-SEL-02, PUB-SEL-03; profiles with source
  paths). Symbolic links to files and directories outside the source
  root, `..` segments, a literal `~` directory and a directory whose
  name starts with `-` never cause the action to read files outside
  the root. Run the pinned tool itself for this test (PUB-TEST-03).
- **CS-12 Empty selection** (PUB-SEL-05; all). An empty selection
  reports `failed` and fails the step, with `permit_fail` set either
  way. With `allow_empty: true` it reports `empty`.
- **CS-13 Destination collisions** (PUB-SEL-06; actions that publish
  more than one item). Two items that map to one destination, such as
  two files from different source directories that share a name, fail
  before any publication.
- **CS-14 Awkward names** (PUB-SEL-07, PUB-SEL-08, PUB-OUT-07; all).
  Names holding newlines or control characters fail before publication.
  Source paths holding spaces, `#`, `?`, `%` or non-ASCII characters
  publish, and the results, outputs and summary show them intact.
  Destination names that the backend permits reach the destination
  unchanged, percent-encoded where they form part of a URL. A name the
  backend forbids, such as `#` in a crate name, fails before
  publication with reason `invalid_item`.

## Destination and credentials

- **CS-20 Ambient configuration** (PUB-DEST-01, PUB-FX-04; all). With
  a conflicting default already configured, such as a default CLI
  server, a global `.npmrc` or a default signing key, the action still
  publishes to the endpoint and with the identity its inputs name. The
  pre-existing configuration stays unchanged afterwards.
- **CS-21 Insecure endpoints** (PUB-DEST-02; all). Plain `http` to a
  host other than loopback fails.
- **CS-22 Credential hygiene** (PUB-DEST-04, PUB-SUM-03; all).
  Credentials never appear in logs, outputs, summaries or results, and
  no credential file written by the action remains after the run.

## Identity and duplicates

- **CS-30 Identity mismatch** (PUB-DUP-01, PUB-FAIL-06; actions that
  take a release). An item from another release or project fails the
  run before the action fetches credentials, with `permit_fail` set
  either way.
- **CS-31 Existing identical content** (PUB-DUP-02, PUB-DUP-03; all).
  For each policy the declaration supports: under `skip_identical`,
  identical content reports `already_present`; under `fail`, the item
  fails with `exists_identical`. A policy the declaration does not
  support fails input validation (PUB-IN-04).
- **CS-32 Existing different content** (PUB-DUP-02; all). Under each
  supported policy other than `overwrite`, different content under the
  same name fails with `exists_different`.
- **CS-33 Partial earlier release** (PUB-DUP-03, PUB-FAIL-05; all).
  When the destination holds part of the release, a rerun publishes
  the missing items and reports the rest as `already_present`, or
  fails as documented. A version that exists never counts as a
  complete release.
- **CS-34 Staged set mismatch** (PUB-DUP-04; `staged_release`). A
  staged set with a missing item, an extra item or a changed digest
  does not get released.

## Failures, outputs and summaries

- **CS-40 Partial failure** (PUB-FAIL-01, PUB-FAIL-02; batch actions).
  With failures during publication in the first, middle and last items,
  check `permit_fail` and `fail_fast` in each combination. Assert every
  item outcome and the step result.
- **CS-46 Checks before publication** (PUB-FAIL-06; all). Each check
  that PUB-FAIL-06 lists fails the step with `permit_fail: true` as
  well as `false`, and the action still writes its outputs.
- **CS-41 Outputs on every path** (PUB-OUT-01, PUB-OUT-03,
  PUB-FAIL-03; all). After a failure at each stage, failed input checks
  and failed builds included, the action has written `outcome`, every
  count and `results_path`, and the counts meet the invariant.
- **CS-42 Output format** (PUB-OUT-03, PUB-OUT-05, PUB-OUT-06; all).
  Counts hold plain decimal integers, booleans hold `true` or `false`,
  and the results file validates against
  [`schema/results.schema.json`](../schema/results.schema.json).
- **CS-43 Sidecar failures** (PUB-FAIL-04; actions with sidecars). A
  required sidecar that the destination rejects marks its item
  `failed`.
- **CS-44 Summary opt-out** (PUB-SUM-01; all). With `summary: false`,
  the step summary file stays unchanged, wrapped tools included.
- **CS-45 Honest summaries** (PUB-SUM-02; all). The summary matches
  the outcome, the counts and the preview mode. Previews, and items
  that ended `failed` or `not_attempted`, never appear as published.
  An item the action confirmed as `already_present` may appear as
  published, as PUB-SUM-02 allows, and still counts under
  `already_present_count`.

## Network behaviour

- **CS-50 Timeouts** (PUB-NET-01; all). A fixture that accepts a
  connection and then stalls makes the operation fail within the
  documented limit.
- **CS-51 Retries** (PUB-NET-02, PUB-NET-04; actions that retry).
  Transient failures retry within the documented bounds; other HTTP
  4xx responses fail at once.
- **CS-52 Requests that may have taken effect** (PUB-NET-03; all).
  After an ambiguous failure on a request that creates something, the
  action reads the remote state before it does anything else. When
  that state shows the request took effect, the action carries on
  without sending it again. When the action cannot read the state, it
  fails with `remote_state_unknown`. When the state confirms the earlier
  request had no effect, the action may send it again, provided retries
  are on and attempts remain; otherwise the item fails with
  `transfer_failed`. Tests cover each case, including
  `upload_attempts: 1`, and assert that no case creates a duplicate.

## Caller state

- **CS-60 Caller files** (PUB-FX-02, PUB-FX-03; all). A checksum of
  the workspace before and after a run, preview and live, shows no
  change outside what the declaration records as `modifies_sources`.
