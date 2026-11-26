<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# Adoption Matrix

Where each existing publishing action stands against
[contract v1](../spec/contract.md). Each entry records gaps by rule
identifier and links the work that tracks them. Update this page in
the pull request that changes an entry, and cite the evidence.

**Baseline:** an audit on 2026-11-23 of each repository's `main`
branch, and of the Artifactory pull request that added the action.
Rechecked on 2026-11-26 against each repository's `main`. No action
carries a declaration yet, so every action counts as pre-conformance.

<!-- markdownlint-disable MD013 -->

| Action                                     | Profiles                              | Fixed since the audit                                          | Open gaps tracked |
| ------------------------------------------ | ------------------------------------- | -------------------------------------------------------------- | ----------------- |
| [Artifactory](#artifactory-publish-action) | `artifact_upload`                     | [PR #3][art-3] review findings, [#8][art-8]                    | None yet          |
| [Central](#central-publish-action)         | `staged_release`                      | [#108][cen-108], [#110][cen-110]                               | None yet          |
| [Helm](#helm-chart-publish-action)         | `package_upload`                      | [#213][helm-213]                                               | None yet          |
| [Nexus](#nexus-publish-action)             | `artifact_upload`                     | None                                                           | None yet          |
| [Node](#node-publish-action)               | `package_upload`, `build_and_publish` | None                                                           | None yet          |
| [PyPI](#pypi-publish-action)               | `package_upload`                      | [#229][py-229], [#230][py-230], [#232][py-232], [#240][py-240] | None yet          |
| [Rust](#rust-crate-publish-action)         | `build_and_publish`                   | None                                                           | None yet          |

<!-- markdownlint-enable MD013 -->

Each section lists defects first, then interface gaps. Rules without an
entry have not had a review yet: the audit concentrated on behaviour
that can publish the wrong content, and on the common interface.

## artifactory-publish-action

Fixed since the audit, before [PR #3][art-3] merged and released as
`v0.0.1`:

- PUB-DEST-01, PUB-FX-04: uploads now go to a server in a private CLI
  home, never the CLI's default server.
- PUB-SEL-01, PUB-SEL-03: the action rejects symbolic links under
  `files_path`, so the preview and the upload read the same files.
- PUB-SEL-02: the upload runs from inside the resolved source, so the
  CLI cannot expand a `~` or a pattern in its path.
- PUB-OUT-03: counts no longer depend on line counts or `wc` padding.
- PUB-IN-02: the input is `repository_name`, as in Nexus.

Also fixed, by [#8][art-8] in [PR #11][art-11]: outputs after a failed
re-run now agree, and setup writes no JFrog job summary.

Interface gaps: PUB-OUT-01 and PUB-OUT-05 (no `outcome` or results
file), PUB-FAIL-01 (no `permit_fail` or `fail_fast`, by design: the
README explains that a release must not pass with a partial upload),
PUB-DUP-02 (no `if_exists`), PUB-SUM-01 (no `summary`).

## central-publish-action

Fixed since the audit, and released in `v0.2.2`:

- PUB-MODE-02, PUB-MODE-03, PUB-IN-03: the action now checks
  `dry-run` once and every step reads the checked value. Fixed by
  [PR #109][cen-109], which closed [#108][cen-108].
- PUB-DUP-04: publish mode now checks the complete deployment, so
  extra or missing files block publication. Fixed by
  [PR #111][cen-111], which closed [#110][cen-110].

Defects:

- PUB-DEST-03: the action signs with the first secret key in the
  default keyring, not the key it imported. No issue yet.
- PUB-NET-01: the bundle upload has a connect timeout but no total
  time limit. No issue yet.
- PUB-MODE-04, PUB-FX-02: upload-mode previews sign the files, so they
  need the private key and write signatures into the caller's m2repo.
  No issue yet.

Interface gaps: PUB-IN-01 (hyphenated input names), PUB-OUT-01,
PUB-OUT-03 and PUB-OUT-05 (no `outcome`, common counts or results),
PUB-SUM-01 (no `summary`).

## helm-chart-publish-action

Fixed since the audit, and released in `v0.2.2`:

- PUB-FAIL-02, PUB-FAIL-03: a chart whose metadata the action cannot
  read now counts as failed, and the batch continues. Fixed by
  [PR #215][helm-215], which closed [#213][helm-213].
- PUB-TEST-02: the same pull request added a workflow that runs the
  stubbed publication tests on pull requests.

Defects:

- PUB-IN-03: `permit_fail` treats any value other than `true` as
  `false` instead of failing.
- PUB-SEL-07: a file name holding a newline breaks `GITHUB_OUTPUT`.
- The action accepts Helm 3.7, which needs `HELM_EXPERIMENTAL_OCI` for
  OCI support; Helm enables OCI by default from 3.8.

Interface gaps: PUB-MODE-01 (no `dry_run`), PUB-OUT-08 (comma-separated
lists), PUB-OUT-01 and PUB-OUT-05, PUB-SEL-05 (an empty selection
succeeds), PUB-SUM-01.

## nexus-publish-action

Defects:

- PUB-FAIL-04: generated checksum uploads use a different HTTP method
  from the artifact upload, and their failures do not fail the item.
- PUB-SEL-06: recursive raw uploads flatten paths, so two files with
  the same name map to one destination.
- PUB-SEL-08: the action does not encode URL path segments, so a `#`
  in a name changes the destination.
- PUB-DOC-01: `metadata` and `validate_checksum` do not do what their
  descriptions say, and the npm and PyPI formats lack a complete
  upload protocol.

Interface gaps: PUB-SEL-05 (an empty selection succeeds), PUB-OUT-08,
PUB-OUT-01 and PUB-OUT-05, PUB-SUM-01. The action already offers
`dry_run`, `permit_fail`, `fail_fast`, `upload_attempts` and
`retry_delay`.

## node-publish-action

Defects:

- PUB-FX-04, PUB-MODE-05: credential setup replaces the project
  `.npmrc`, so settings such as `access` and `ignore-scripts` apply to
  previews but not to live runs.

Interface gaps: PUB-OUT-06 (`published` holds three values),
PUB-DUP-02 (`skip-if-identical` uses a hyphenated value), PUB-OUT-01,
PUB-OUT-03 and PUB-OUT-05, PUB-SUM-01, and PUB-FX-01 (directory-mode
previews stamp the version into `package.json`, which a declaration
would record as `modifies_sources`). The action already offers a
strict `dry_run` and an `if_exists` policy with digest comparison.

## pypi-publish-action

Fixed since the audit, and released in `v0.2.6`:

- PUB-FX-02: artefact cleanup could delete project files. Fixed by
  [PR #231][py-231], which closed [#229][py-229].
- PUB-DUP-01: the action now checks that the distributions match the
  requested release. Fixed by [PR #235][py-235], which closed
  [#230][py-230].
- PUB-DUP-03, PUB-FAIL-05: a re-run now uploads the files a partial
  release lacks, and no others. Fixed by [PR #236][py-236], which closed
  [#232][py-232].
- PUB-NET-02: a download by name now retries when the artefact service
  lags behind an upload. Fixed by [PR #242][py-242], which closed
  [#240][py-240].

Defects:

- PUB-IN-04, PUB-DEST-05: any `environment` value other than
  `production` selects TestPyPI.
- PUB-MODE-04, PUB-IN-03: `publish_disable` still fetches credentials,
  and invalid values fall through without an error.

Interface gaps: PUB-MODE-06 (`publish_disable` instead of `dry_run`),
PUB-OUT-01, PUB-OUT-03 and PUB-OUT-05 (no outputs), PUB-SUM-01.

## rust-crate-publish-action

Defects:

- PUB-FX-04: a relative `CARGO_HOME` resolves against a different
  directory in each stage.
- PUB-DUP-03: an empty HTTP 200 response from the sparse index counts
  as proof that the crate version does not exist.

Interface gaps: PUB-OUT-01, PUB-OUT-03 and PUB-OUT-05 (outputs report
statuses but no common counts), PUB-FX-01 (version stamping changes
manifests during previews). The action already offers `dry_run`,
`permit_fail` and `summary`.

[art-3]: https://github.com/lfreleng-actions/artifactory-publish-action/pull/3
[art-8]: https://github.com/lfreleng-actions/artifactory-publish-action/issues/8
[art-11]: https://github.com/lfreleng-actions/artifactory-publish-action/pull/11
[cen-108]: https://github.com/lfreleng-actions/central-publish-action/issues/108
[cen-109]: https://github.com/lfreleng-actions/central-publish-action/pull/109
[cen-110]: https://github.com/lfreleng-actions/central-publish-action/issues/110
[cen-111]: https://github.com/lfreleng-actions/central-publish-action/pull/111
[helm-213]: https://github.com/lfreleng-actions/helm-chart-publish-action/issues/213
[helm-215]: https://github.com/lfreleng-actions/helm-chart-publish-action/pull/215
[py-229]: https://github.com/lfreleng-actions/pypi-publish-action/issues/229
[py-230]: https://github.com/lfreleng-actions/pypi-publish-action/issues/230
[py-231]: https://github.com/lfreleng-actions/pypi-publish-action/pull/231
[py-232]: https://github.com/lfreleng-actions/pypi-publish-action/issues/232
[py-235]: https://github.com/lfreleng-actions/pypi-publish-action/pull/235
[py-236]: https://github.com/lfreleng-actions/pypi-publish-action/pull/236
[py-240]: https://github.com/lfreleng-actions/pypi-publish-action/issues/240
[py-242]: https://github.com/lfreleng-actions/pypi-publish-action/pull/242
