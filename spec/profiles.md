<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# Profiles

Publishing actions differ in how they publish. A profile groups
actions that publish the same way, so the contract can state where a
rule depends on that difference. A declaration lists one or more
profiles; an action with two modes, such as a package directory mode
and a prebuilt tarball mode, lists both.

Every rule in the [contract](contract.md) applies to every profile,
except where this page says otherwise.

## `artifact_upload`

Uploads prebuilt files to paths in a repository.

- **Examples:** Artifactory, Nexus.
- **Typical unit:** `file`.
- **Selection:** a directory tree or file from `files_path`, with
  `file_pattern` and documented exclusions. PUB-SEL-01 to PUB-SEL-08
  apply in full.
- **Identity:** PUB-DUP-01 applies when the caller names a release
  that the files carry, such as Maven coordinates.
- **Preview:** expected to run offline, with
  `local_writes: scratch_only`.

## `staged_release`

Uploads a set to a staging area, waits for the destination to check
it, and then releases it.

- **Example:** Maven Central.
- **Typical unit:** `deployment`. Per-item results describe
  deployments; an action that reports finer detail, such as component
  or file counts, adds backend outputs for it (PUB-OUT-09).
- **Identity:** PUB-DUP-04 applies to the release step: the action
  releases a staged set when it matches the expected set item for item,
  and at no other time.
- **Network:** PUB-NET-03 applies to staging requests, which the
  destination treats as new each time.
- **Preview:** may read the remote state; declare `network: read_only`.

## `build_and_publish`

Builds or packages from sources, then publishes the result.

- **Examples:** Rust crates; npm packages from a project directory.
- **Typical unit:** `crate` or `package`.
- **Side effects:** builds can write into the project; versioning steps
  can change manifests. The declaration MUST record either effect as
  `modifies_sources` (PUB-FX-01, PUB-FX-02).
- **Selection:** the build output forms the selection. PUB-SEL-01
  applies to that output: the preview and the publication use the same
  built items.

## `package_upload`

Uploads prebuilt package files to a package registry that tracks
names and versions.

- **Examples:** PyPI distributions; npm tarballs; Helm charts in an
  OCI registry.
- **Typical unit:** `distribution`, `package` or `chart`.
- **Identity:** PUB-DUP-01 applies: the package metadata must match
  the requested release.
- **Duplicates:** these registries tend to forbid replacing a version.
  PUB-DUP-03 applies in full: a version that exists does not prove that
  every file of the release exists with the same content.
