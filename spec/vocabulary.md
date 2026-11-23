<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# Vocabulary

The common names, values and formats that the
[contract](contract.md) refers to. Names and enumerated values use
`snake_case` throughout ([ADR 0002](../docs/adr/0002-snake-case-and-aliases.md)).

## Common inputs

An action that offers one of these capabilities uses this name, type,
default and meaning (PUB-IN-02). Each boolean follows PUB-IN-03.

<!-- markdownlint-disable MD013 -->

| Input             | Type    | Default                    | Meaning                                                                                                                                                               |
| ----------------- | ------- | -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `dry_run`         | boolean | `false`                    | Build and check the selection, then stop before the first publication                                                                                                 |
| `permit_fail`     | boolean | `false`                    | Items that fail during publication do not fail the step; `outcome` and the counts still report them. Checks before publication fail the step regardless (PUB-FAIL-06) |
| `fail_fast`       | boolean | `true`                     | With `permit_fail: false`, stop at the first failed item and mark the rest `not_attempted`                                                                            |
| `allow_empty`     | boolean | `false`                    | Report the `empty` outcome instead of failing when the selection holds no items                                                                                       |
| `if_exists`       | enum    | `fail` or `skip_identical` | What to do when an item already exists at the destination; each action picks its default under PUB-DUP-02                                                             |
| `summary`         | boolean | `true`                     | Write a step summary                                                                                                                                                  |
| `upload_attempts` | integer | per action                 | Attempts for each transfer; `1` turns retries off; the README states the bounds                                                                                       |
| `retry_delay`     | integer | per action                 | Seconds before the first retry; each retry doubles it, up to a documented cap                                                                                         |
| `files_path`      | path    | none                       | Directory or file holding prebuilt items                                                                                                                              |
| `file_pattern`    | glob    | `*`                        | Filename pattern that items under `files_path` must match                                                                                                             |
| `upload_path`     | string  | `""`                       | Path prefix inside the destination namespace                                                                                                                          |
| `repository_name` | string  | none                       | Key of the destination repository or namespace                                                                                                                        |
| `path_prefix`     | path    | `.`                        | Project directory, for actions that build or inspect sources                                                                                                          |

<!-- markdownlint-enable MD013 -->

### `if_exists` policies

- `fail`: the item fails with reason `exists_different` or
  `exists_identical`.
- `skip_identical`: an item with identical content counts as
  `already_present`; an item with different content fails with reason
  `exists_different`.
- `overwrite`: the action replaces the existing item. Actions offer
  this policy when the destination allows replacement, and never as
  the default (PUB-DUP-02).

### Not yet standardised

The team has still to choose names for these concepts. Until it does,
actions keep their present names and document them:

- **Endpoint**: `artifactory_url`, `nexus_server`, `registry`,
  `registry_url` and `central-url` all exist today. The proposal is
  `registry_url` for new actions, with present names kept as aliases.
- **Release version**: `publish_version`, `tag`, `release_tag` and
  `version` all exist today.
- **Credentials**: `access_token`, `auth_token`, `password`,
  `nexus_password`, `central-token` and `registry_token` all exist
  today.

## Run outcomes

Every run sets `outcome` to one of these values, including a run that
fails its input checks (PUB-OUT-01):

- `published`: the run published items, and no item failed.
- `already_present`: the destination already held every item, and
  the run published nothing.
- `partial`: some items completed publication, or were there
  already, and others failed or went unattempted.
- `failed`: no item completed publication, and the run hit a failure.
  Part of an item can still have reached the destination, such as a
  payload whose required sidecar failed (PUB-FAIL-04), so a rerun must
  not assume the destination holds nothing. A preview that finds a
  failing item also reports `failed`, as does an empty selection
  without `allow_empty: true` (PUB-SEL-05).
- `previewed`: a preview finished, and no item would fail.
- `empty`: the selection held no items, and the caller set
  `allow_empty: true`.

The action picks the outcome from the item outcomes with the rules
below. The first rule that matches decides, so each run gets one
outcome. A failure that belongs to no single item, such as a rejected
credential, marks every unfinished item `not_attempted` with reason
`run_stopped`, and the rules below then apply.

A live run:

1. `failed` when the run stopped before it finished building the
   selection, for example after a failed input check or build.
2. `empty` when the selection held no items and the caller set
   `allow_empty: true`.
3. `failed` when the selection held no items.
4. `published` when at least one item is `published` and none is
   `failed` or `not_attempted`.
5. `already_present` when every item is `already_present`.
6. `partial` when at least one item is `published` or
   `already_present`, and at least one is `failed` or `not_attempted`.
7. `failed` otherwise.

A preview:

1. `failed` when the run stopped before it finished building the
   selection.
2. `empty` when the selection held no items and the caller set
   `allow_empty: true`.
3. `failed` when the selection held no items.
4. `failed` when at least one item is `failed` or `not_attempted`.
5. `previewed` otherwise, including when a preview that reads the
   destination finds some items `already_present`.

An empty selection without `allow_empty: true`, and any other failed
check before publication (PUB-FAIL-06), fails the step whatever
`permit_fail` says. Otherwise, with `permit_fail: false`, the outcomes
`partial` and `failed` also fail the step. Either way, the action
first writes its outputs and any summary.

## Item outcomes

Each item ends with one of these values (PUB-OUT-02):

- `published`: the action wrote the item to the destination.
- `already_present`: the destination already held identical content,
  confirmed by comparison (PUB-DUP-03).
- `previewed`: a preview checked the item and would publish it.
- `failed`: the item did not complete publication, or failed a check.
  Part of it can still have reached the destination.
- `not_attempted`: the run stopped before reaching the item, for
  example under `fail_fast`.

## Count outputs

Every run sets each of these, as plain decimal
integers (PUB-OUT-03):

<!-- markdownlint-disable MD013 -->

| Output                  | Counts items whose outcome is |
| ----------------------- | ----------------------------- |
| `selected_count`        | any outcome                   |
| `publication_count`     | `published`                   |
| `already_present_count` | `already_present`             |
| `dry_run_count`         | `previewed`                   |
| `failed_count`          | `failed`                      |
| `not_attempted_count`   | `not_attempted`               |

<!-- markdownlint-enable MD013 -->

The counts obey this invariant on every exit path:

```text
selected_count = publication_count + already_present_count
               + dry_run_count + failed_count + not_attempted_count
```

A live run reports `dry_run_count=0`; a preview reports
`publication_count=0`. A run that stopped before it finished building
the selection reports `0` for every count and an empty results array.

## Per-item results

`results_path` names a JSON file holding an array with one object per
selected item, in selection order (PUB-OUT-05). `results`, where
present, holds the same JSON on a single line.
[`schema/results.schema.json`](../schema/results.schema.json) defines
the format:

<!-- markdownlint-disable MD013 -->

| Field         | Type           | Meaning                                                           |
| ------------- | -------------- | ----------------------------------------------------------------- |
| `id`          | string         | Stable identifier, such as a relative path or `name@version`      |
| `source`      | string or null | Path relative to the source root, where the item has a source     |
| `destination` | string or null | Repository path, URL or reference that the item maps to           |
| `outcome`     | string         | An item outcome                                                   |
| `digest`      | string or null | Content digest, as `sha256:` followed by 64 lowercase hex digits  |
| `reason`      | string or null | A reason code, when the outcome is not `published` or `previewed` |
| `detail`      | string or null | A short message for people; never a secret                        |

<!-- markdownlint-enable MD013 -->

### Reason codes

- `invalid_item`: the item failed a check before publication.
- `identity_mismatch`: the item does not belong to the requested
  release (PUB-DUP-01).
- `exists_identical`: identical content already exists.
- `exists_different`: different content already exists under the same
  name.
- `transfer_failed`: the transfer failed after any retries.
- `rejected`: the destination refused the item.
- `sidecar_failed`: a required sidecar failed (PUB-FAIL-04).
- `remote_state_unknown`: the action could not read the remote state
  it needed.
- `timeout`: an operation passed its time limit.
- `fail_fast`: the run stopped before this item, under `fail_fast`.
- `run_stopped`: the run stopped before this item, after a failure
  that belongs to no single item, or a check before publication
  (PUB-FAIL-06).

## Units

The declaration names one unit for all counts (PUB-OUT-04):

- `file`: one file in a repository tree, such as a JAR or POM.
- `distribution`: one package file, such as a wheel or sdist.
- `package`: one package version, such as an npm tarball.
- `chart`: one Helm chart archive.
- `crate`: one crate version.
- `component`: one set of coordinates with its attachments, such as a
  Maven component.
- `deployment`: one staged deployment or bundle.
