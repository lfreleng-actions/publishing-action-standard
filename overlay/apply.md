<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# Applying the Publishing Standard

This guide tells a person or coding agent how to apply the publishing
action standard to an action repository. The standard sits on top of
[`actions-template`](https://github.com/lfreleng-actions/actions-template):
it never replaces that template, and nobody should create a repository
from this one ([ADR 0001](../docs/adr/0001-overlay-not-template.md)).

The organisation [`AGENTS.md`](https://github.com/lfreleng-actions/.github/blob/main/AGENTS.md)
governs every change described here: commits, hooks, workflow audits
and reviews all follow it.

## What the overlay changes

<!-- markdownlint-disable MD013 -->

| Area                                    | The overlay                                                                 |
| --------------------------------------- | --------------------------------------------------------------------------- |
| `action.yaml`                           | Defines inputs, outputs and steps under the contract                        |
| `scripts/`, `src/`, `tests/`            | Holds the implementation and its tests                                      |
| `README.md`                             | Replaces the template's placeholder sections with the PUB-DOC-01 sections   |
| `AGENTS.md`                             | Fills in "Repository specifics" (see below)                                 |
| `.github/publishing-contract.yaml`      | Adds the declaration (PUB-GEN-01)                                           |
| `.github/workflows/testing.yaml`        | Replaces the placeholder test job with the action's own tests               |

<!-- markdownlint-enable MD013 -->

Leave the template baseline alone: `.gitlint`,
`.pre-commit-config.yaml`, `.github/dependabot.yml`, the security,
release and hooks workflows, `LICENSE`, `LICENSES/` and `SECURITY.md`.
Change those through `actions-template`, so every repository gets the
change. A repository that needs a local addition to its hooks, such as
a hook for its own language, adds it with a comment saying why.

## A new publishing action

1. Create the repository from `actions-template` as usual.
2. Read the [contract](../spec/contract.md), the
   [vocabulary](../spec/vocabulary.md) and the
   [profiles](../spec/profiles.md). Choose the profiles that describe
   how the action publishes.
3. Write `.github/publishing-contract.yaml`, starting from the closest
   file in [`examples/`](../examples/). Set `standard_commit` to the
   full commit SHA of this repository that you follow, and point editors
   at the schema at that commit:

   ```yaml
   # yaml-language-server: $schema=https://raw.githubusercontent.com/lfreleng-actions/publishing-action-standard/<commit>/schema/publishing-contract.schema.json
   ```

4. Replace "Repository specifics" in `AGENTS.md` with:

   ```markdown
   This repository is a publishing action. It follows contract v1 of
   the publishing action standard, at commit `<commit>`:
   <https://github.com/lfreleng-actions/publishing-action-standard/tree/<commit>>.
   Read its `overlay/apply.md` before changing inputs, outputs,
   selection, destination handling or publication behaviour, and keep
   `.github/publishing-contract.yaml` accurate.
   ```

5. Design `action.yaml` from the vocabulary. Use the common input
   names and the common outputs, and keep secret inputs optional where
   a preview can run without them (PUB-IN-06).
6. Build the implementation around these patterns:
   - The first step checks every input and writes canonical values,
     such as `dry_run`, to its outputs. Every later step reads those
     outputs (PUB-IN-05, PUB-MODE-02).
   - One function builds the selection, and the preview, the counts
     and the publication all use its result (PUB-SEL-01).
   - Scratch space comes from a fresh directory under `RUNNER_TEMP`
     (PUB-FX-03).
   - An exit trap or an `if: always()` step writes outputs on every
     path, failed input checks included, and the summary as well when
     `summary` parses as `true` (PUB-FAIL-03).
7. Write the README sections that PUB-DOC-01 lists.
8. Write tests for every scenario in
   [`conformance/scenarios.md`](../conformance/scenarios.md) that
   applies to your profiles. Run them on pull requests without
   credentials (PUB-TEST-02) and name rule identifiers in the test
   names or comments (PUB-TEST-01).

### Shell helpers

These helpers meet PUB-IN-03 and PUB-OUT-07, and work in Bash 3.2 and
later. Copy them into the action's scripts as needed:

```bash
# parse_bool NAME VALUE: print true or false, or fail (PUB-IN-03)
parse_bool() {
  local value="$2"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
  case "$value" in
    true|false) printf '%s\n' "$value" ;;
    *)
      # Never echo the raw value: it could carry workflow commands
      echo "::error::$1 must be true or false" >&2
      return 1
      ;;
  esac
}

# set_output NAME VALUE: write one output that cannot inject others
# (PUB-OUT-07)
set_output() {
  local delimiter="ghadelim_${RANDOM}${RANDOM}${RANDOM}${RANDOM}"
  while [[ "$2" == *"$delimiter"* ]]; do
    delimiter="ghadelim_${RANDOM}${RANDOM}${RANDOM}${RANDOM}"
  done
  printf '%s<<%s\n%s\n%s\n' "$1" "$delimiter" "$2" "$delimiter" \
    >> "$GITHUB_OUTPUT"
}
```

## Aligning an existing action

1. Compare the action with each rule, and record what you find in
   [`adoption/matrix.md`](../adoption/matrix.md) through a pull request
   to this repository.
2. File one issue per gap, or per group of gaps that change the same
   code, using [`adoption/issue-template.md`](../adoption/issue-template.md).
   Fix defects that can publish the wrong content first; interface
   alignment can follow.
3. Add `.github/publishing-contract.yaml` to the action once the team
   agrees the plan, listing every remaining gap under `deviations`
   with its issue. Remove each deviation in the pull request that
   fixes it.
4. Keep interface changes additive (PUB-COMPAT-01 to PUB-COMPAT-04).

### Sequencing automated work

When an automated agent, such as the organisation's code monkey bot,
works these issues, give it one issue per repository at a time. Two
issues that change the same files, worked in parallel, collide and
cost extra rebase rounds. Each issue's "Coordination" section names
the work it must wait for.

## Reviewing a publishing action

Reviewers check a change against the rules the declaration claims,
and cite rule identifiers in review comments. A change that adds a
deviation needs the team's agreement and a tracking issue
(PUB-GEN-03).
