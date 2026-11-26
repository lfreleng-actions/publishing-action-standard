<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# Publishing Action Contract

**Contract version:** 1 (draft, under team review)

The key words "MUST", "MUST NOT", "SHOULD", "SHOULD NOT" and "MAY"
follow [BCP 14](https://www.rfc-editor.org/info/bcp14) when they appear
in capitals. Text without those words explains and does not bind.

Each rule carries a stable identifier, for example `PUB-MODE-02`.
Issues, tests, declarations and reviews cite rules by identifier.
Never renumber or reuse an identifier: a rule that the standard drops
keeps its number and gains a note marking it as retired.

[`vocabulary.md`](vocabulary.md) defines the common names and values
these rules refer to. [`profiles.md`](profiles.md) groups actions by
how they publish and states which rules depend on the profile.

## Terms

- **Publishing action**: an `lfreleng-actions` action whose main
  purpose is to write artifacts, packages or releases to a system
  outside the workflow run, such as a registry, repository or portal.
- **Publication**: any write to that outside system, including a
  staging write that a later step promotes.
- **Item**: one thing the action counts and reports, in the unit the
  action declares (PUB-OUT-04).
- **Selection**: the exact list of items a run would publish, built
  from the inputs before any publication.
- **Preview**: a run that performs everything up to the first
  publication and then stops. Callers request a preview with
  `dry_run: true`.
- **Live run**: a run that may publish.
- **Caller state**: files, configuration and credentials that belong
  to the calling workflow rather than to the action.

## 1. Applicability and declaration

- **PUB-GEN-01** Every publishing action MUST carry a declaration at
  `.github/publishing-contract.yaml` that validates against
  [`schema/publishing-contract.schema.json`](../schema/publishing-contract.schema.json).
- **PUB-GEN-02** The repository `AGENTS.md` MUST name this standard and
  the commit of it that the action follows, in its "Repository
  specifics" section (see [`overlay/apply.md`](../overlay/apply.md)).
- **PUB-GEN-03** The declaration MUST list every known departure from
  a rule in its `deviations` field, with the rule identifier, the
  reason and a tracking issue. An undeclared departure counts as a
  defect.
- **PUB-GEN-04** A new publishing action MUST conform before its
  first release, apart from deviations that the team accepts in
  review and that the declaration records.

## 2. Inputs

- **PUB-IN-01** Input names MUST use `snake_case`. Where an existing
  action uses another form, it MUST add a `snake_case` alias under
  PUB-COMPAT-01 and keep the old name working.
- **PUB-IN-02** Where an action offers a capability that
  [`vocabulary.md`](vocabulary.md) names, it MUST use that input name
  with the meaning, type and default given there.
- **PUB-IN-03** Boolean inputs MUST accept `true` and `false`. An
  action MAY first trim surrounding whitespace and fold letter case.
  Any other value, the empty string included, MUST fail the run.
- **PUB-IN-04** Inputs that take a value from a fixed set MUST reject
  values outside that set. An unknown value MUST NOT select a
  default destination, index or mode.
- **PUB-IN-05** An action MUST check every input before it
  retrieves a credential, contacts a network service, signs anything
  or writes outside its own scratch space.
- **PUB-IN-06** Secret inputs MUST stay optional in `action.yaml`
  whenever a preview can run without them, and the action MUST check
  for them at runtime before a live run needs them.

## 3. Mode safety

- **PUB-MODE-01** An action that publishes MUST offer `dry_run`, with
  a default of `false`, unless its profile states why a preview cannot
  exist. A missing preview counts as a deviation (PUB-GEN-03).
- **PUB-MODE-02** The action MUST parse `dry_run` once, in its
  validation step, and every later step MUST read that canonical
  result. No step may compare the raw input itself.
- **PUB-MODE-03** An invalid mode value MUST fail closed: the run
  stops before any publication, and tests MUST show that no
  publication request takes place.
- **PUB-MODE-04** A preview MUST NOT need publication credentials and
  MUST NOT fetch them, from inputs, secret stores or vaults.
- **PUB-MODE-05** A preview MUST run the same validation and build the
  same selection that a live run builds from the same inputs.
- **PUB-MODE-06** New actions MUST NOT add a second name for preview
  behaviour. Existing alternatives, such as `publish_disable`, become
  deprecated aliases of `dry_run` under PUB-COMPAT-01.

## 4. Side effects

- **PUB-FX-01** The declaration and README MUST state what a preview
  touches: whether it uses the network (`none` or `read_only`) and
  where it writes files (`scratch_only` or `modifies_sources`). They
  MUST state where a live run writes files in the same terms. Every
  run writes at least its results file (PUB-OUT-05), so every action
  writes to scratch space.
- **PUB-FX-02** An action MUST NOT delete or change caller files,
  except where a documented input asks for that change and the
  declaration records it as `modifies_sources`.
- **PUB-FX-03** The action MUST create scratch and staging directories
  fresh, below `RUNNER_TEMP` or another private location, and
  MUST NOT reuse a directory that already exists.
- **PUB-FX-04** An action MUST NOT change caller-wide tool
  configuration, such as a default CLI server, a keyring default, an
  `.npmrc` or a credential store, unless it uses a private
  configuration location for the run or puts back the original state
  when it finishes.

## 5. Selection

- **PUB-SEL-01** An action MUST build the selection once. The preview
  listing, every count and the publication MUST all use that one list.
- **PUB-SEL-02** The action MUST resolve source paths to canonical
  form before it validates them, and MUST pass paths to tools in a
  form those tools cannot reinterpret. A leading `~`, a leading `-` or
  a pattern character in a path MUST NOT change which files a tool
  reads.
- **PUB-SEL-03** Every local file the action reads for publication
  MUST resolve to a regular file inside the validated source root. For
  units that group files, such as `component` or `deployment`, the
  rule applies to each file in the group. The action MUST either reject
  symbolic links or resolve them and require their targets to stay
  inside that root, and MUST stop the tools it calls from following
  links on their own.
- **PUB-SEL-04** The README MUST document recursion, filename
  patterns and every built-in exclusion.
- **PUB-SEL-05** An empty selection MUST fail the run, whatever
  `permit_fail` says, unless the caller sets `allow_empty: true`, in
  which case the run reports the `empty` outcome.
- **PUB-SEL-06** When two selected items map to the same destination,
  the action MUST fail before the first publication.
- **PUB-SEL-07** The action MUST reject, before any publication,
  names it cannot represent without ambiguity in outputs, summaries
  or destinations, such as names holding newlines or control
  characters, and names the destination forbids.
- **PUB-SEL-08** When an action builds URLs from names, it MUST
  percent-encode each path segment.

## 6. Destination and credentials

- **PUB-DEST-01** Inputs, or documented defaults, MUST fix the
  endpoint and namespace, and every publication MUST bind to them
  explicitly. An action MUST NOT rely on ambient configuration such as
  a default CLI server, a global `.npmrc` or a default signing key.
- **PUB-DEST-02** Endpoint inputs MUST require `https`. An action MAY
  allow plain `http` to a loopback address for tests.
- **PUB-DEST-03** An action that signs MUST name the signing key by
  fingerprint, from a keyring private to the run.
- **PUB-DEST-04** An action MUST mask credentials, keep them out of
  logs and summaries, hand them to the steps that need them and no
  others, and remove any credential it wrote to disk when it finishes.
- **PUB-DEST-05** The choice between production and test targets MUST
  come from an explicit input value; an unknown value fails
  (PUB-IN-04).

## 7. Outcomes and outputs

- **PUB-OUT-01** Every run MUST set `outcome` to one of the run
  outcomes in [`vocabulary.md`](vocabulary.md), including a run that
  fails its input checks.
- **PUB-OUT-02** Each item MUST end with one of the item outcomes in
  [`vocabulary.md`](vocabulary.md).
- **PUB-OUT-03** The action MUST set the common count outputs on every
  exit path, failures included. Counts MUST appear as
  plain decimal integers without padding, and MUST meet the
  invariants in [`vocabulary.md`](vocabulary.md).
- **PUB-OUT-04** The declaration and README MUST name the unit that
  counts refer to. A count MUST NOT mix units, and the README MUST say
  whether sidecar files, such as signatures or checksums, count as
  items.
- **PUB-OUT-05** The action MUST write the full per-item results as
  JSON to a file and expose its path as `results_path`. It SHOULD also
  expose the same JSON as `results` while the value stays within
  GitHub's output size limits.
- **PUB-OUT-06** Boolean outputs MUST hold `true` or `false` and
  nothing else.
- **PUB-OUT-07** The action MUST write outputs in a way that values
  cannot inject further outputs, for example with a random heredoc
  delimiter, or by first checking that a value holds a single line.
- **PUB-OUT-08** New actions MUST NOT add comma-separated or
  space-separated list outputs. Existing list outputs stay as
  deprecated aliases under PUB-COMPAT-01.
- **PUB-OUT-09** An action MAY add outputs for its backend, such as a
  deployment identifier or a content digest, and MUST document them.

## 8. Partial failure

- **PUB-FAIL-01** An action that publishes more than one item MUST
  offer `permit_fail` and `fail_fast` with the meaning given in
  [`vocabulary.md`](vocabulary.md), or declare a deviation.
- **PUB-FAIL-02** When one item fails during publication, for example
  because the action cannot read the item's metadata, the action MUST
  record that item as `failed` and apply the failure policy. It MUST
  NOT abandon the run in a way that loses the results of items it
  already handled. PUB-FAIL-06 covers checks that run before
  publication.
- **PUB-FAIL-03** The action MUST write outputs on every exit path,
  failed input checks included, and the summary as well when `summary`
  parses as `true` (PUB-SUM-01). An exit trap or an `if: always()`
  step meets this rule.
- **PUB-FAIL-04** When a sidecar that the destination requires fails
  to upload, the item it belongs to counts as `failed`.
- **PUB-FAIL-05** The README MUST state whether publication is atomic,
  and MUST describe what a rerun does after a partial failure.
- **PUB-FAIL-06** `permit_fail` and `fail_fast` govern failures during
  publication, and no others. A failure in a check that runs before
  publication MUST fail the run whatever `permit_fail` says: input
  checks (PUB-IN-03 to PUB-IN-05), mode checks (PUB-MODE-03), path and
  selection checks (PUB-SEL-02, PUB-SEL-03 and PUB-SEL-05 to
  PUB-SEL-07) and release identity checks (PUB-DUP-01). The action
  still writes its outputs, and the summary unless `summary: false`.

## 9. Duplicates and identity

- **PUB-DUP-01** When the caller names a release, for example a
  version, the action MUST check that every selected item belongs to
  that release before it fetches credentials or publishes. A mismatch
  MUST fail the run.
- **PUB-DUP-02** An action MUST apply one of the `if_exists` policies
  from [`vocabulary.md`](vocabulary.md) to items that already exist at
  the destination, and MUST document which policies it supports. The
  default MUST be `fail` or `skip_identical`, never `overwrite`.
- **PUB-DUP-03** An action MUST compare content, for example by digest,
  before it reports an existing item as `already_present`. The
  presence of a version MUST NOT stand in for proof that a release is
  complete or identical.
- **PUB-DUP-04** Before an action releases a staged set, it MUST check
  that the staged set and the expected set hold the same items with
  the same content, with nothing missing and nothing extra.

## 10. Retries and timeouts

- **PUB-NET-01** Every network operation MUST have a connect timeout
  and a total time limit, and the README MUST document both.
- **PUB-NET-02** An action MAY retry transient failures, such as
  connection errors, HTTP 5xx responses and HTTP 429 responses. It
  MUST NOT retry other HTTP 4xx responses.
- **PUB-NET-03** An action MUST NOT repeat a request that may have
  taken effect, such as creating a deployment, unless it first reads
  the remote state and confirms that the earlier request did not take
  effect.
- **PUB-NET-04** Where an action lets callers tune retries, it MUST
  use `upload_attempts` and `retry_delay` with documented bounds and
  backoff.

## 11. Summaries

- **PUB-SUM-01** An action MUST offer `summary`, default `true`. With
  `summary: false` the action MUST NOT write a step summary, and MUST
  turn off the summaries of tools it wraps where those tools allow it.
- **PUB-SUM-02** A summary MUST state the outcome, the counts, the
  destination and whether the run was a preview. It MUST NOT describe
  a release as published unless the action published it, or confirmed
  it as `already_present`.
- **PUB-SUM-03** A summary MUST escape Markdown in values that come
  from inputs or file names, and MUST NOT include secrets.

## 12. Compatibility

- **PUB-COMPAT-01** Changes to the interface MUST add rather than
  remove: a new name or enumerated value works alongside the old one,
  and the old one keeps working, with a `::warning::` that names its
  replacement, until the next major release.
- **PUB-COMPAT-02** When a caller sets both an alias and its canonical
  input to different values, the run MUST fail. Equal values MUST
  work.
- **PUB-COMPAT-03** Removing a deprecated input or output MUST wait
  for a major release, and the release notes MUST name it.
- **PUB-COMPAT-04** A change that makes a passing run fail counts as
  breaking, and its pull request MUST carry the `breaking-change`
  label. A fix that stops an action publishing the wrong content MAY
  ship in a minor release when its release notes describe it.

## 13. Testing

- **PUB-TEST-01** Each rule that applies to an action MUST have at
  least one test that names the rule identifier.
- **PUB-TEST-02** Tests MUST run on pull requests without registry
  credentials, using fixtures or loopback mocks. Tests against real
  registries MAY run in a separate, gated job.
- **PUB-TEST-03** Where an action delegates selection or destination
  handling to a tool, tests for PUB-SEL and PUB-DEST rules MUST run the
  pinned tool itself against a fixture, rather than checking the
  arguments the action passes to it.
- **PUB-TEST-04** The test suite MUST cover every scenario in
  [`conformance/scenarios.md`](../conformance/scenarios.md) that
  applies to the action's profile.

## 14. Documentation

- **PUB-DOC-01** The README MUST cover: inputs, with aliases and
  deprecations; outputs, with units; preview behaviour and side
  effects; selection; the duplicate policy; failure and recovery;
  required credentials and permissions; and the contract version and
  deviations.
