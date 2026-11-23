<!--
SPDX-License-Identifier: Apache-2.0
SPDX-FileCopyrightText: 2026 The Linux Foundation
-->

# 📦 Publishing Action Standard

<!-- prettier-ignore-start -->
<!-- markdownlint-disable-next-line MD013 -->
[![Linux Foundation](https://img.shields.io/badge/Linux-Foundation-blue)](https://linuxfoundation.org/) [![Source Code](https://img.shields.io/badge/GitHub-100000?logo=github&logoColor=white&color=blue)](https://github.com/lfreleng-actions/publishing-action-standard) [![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/lfreleng-actions/publishing-action-standard/badge)](https://scorecard.dev/viewer/?uri=github.com/lfreleng-actions/publishing-action-standard)
<!-- prettier-ignore-end -->

The organisation standard for `lfreleng-actions` actions that publish
artifacts, packages and releases: a contract for their inputs,
outputs and behaviour, the scenarios their tests must cover, and a
record of where each existing action stands.

> [!IMPORTANT]
> This is an **overlay**, not a template. Create a new action from
> [`actions-template`](https://github.com/lfreleng-actions/actions-template),
> then apply this standard to it. Never create a repository from this
> one ([ADR 0001](docs/adr/0001-overlay-not-template.md)).

## Status

Contract version 1 is a **draft** under team review. Rule identifiers
stay stable from the first draft onwards: review can change a rule's
wording, but never renumbers or reuses an identifier. A dropped rule
keeps its number and gains a note marking it as retired.

## Contents

<!-- markdownlint-disable MD013 -->

| Path                                                       | Purpose                                                     |
| ---------------------------------------------------------- | ----------------------------------------------------------- |
| [`spec/contract.md`](spec/contract.md)                     | The rules, with stable identifiers such as `PUB-MODE-02`    |
| [`spec/vocabulary.md`](spec/vocabulary.md)                 | Common input names, outcomes, counts and the results format |
| [`spec/profiles.md`](spec/profiles.md)                     | How rules apply to each kind of publishing                  |
| [`schema/`](schema/)                                       | JSON Schemas for the declaration and the results            |
| [`examples/`](examples/)                                   | Example declarations and results, checked by the hooks      |
| [`tests/`](tests/README.md)                                | Accept and reject cases for the schemas, run by the hooks   |
| [`overlay/apply.md`](overlay/apply.md)                     | How to apply the standard to a new or existing action       |
| [`conformance/scenarios.md`](conformance/scenarios.md)     | The scenarios each action's tests must cover                |
| [`adoption/matrix.md`](adoption/matrix.md)                 | Where each existing action stands, with tracking issues     |
| [`adoption/issue-template.md`](adoption/issue-template.md) | Structure for issues that close a gap                       |
| [`docs/adr/`](docs/adr/)                                   | The decisions behind the standard                           |

<!-- markdownlint-enable MD013 -->

## Using the standard

- **Writing a new publishing action:** follow
  [`overlay/apply.md`](overlay/apply.md) after creating the repository
  from `actions-template`. Point the coding agent at that guide in the
  session that writes the action.
- **Changing an existing publishing action:** check the change against
  the rules its declaration claims, and update
  [`adoption/matrix.md`](adoption/matrix.md) when a gap closes.
- **Reviewing:** cite rule identifiers in review comments, and ask for
  a deviation entry and tracking issue when a change departs from a
  rule.

Each publishing action records the commit of this repository it
follows, in `.github/publishing-contract.yaml` and its `AGENTS.md`. A
new rule reaches an action when that action moves to a newer
commit, in a pull request of its own.

## Open questions

The team should settle these before accepting version 1:

1. Common names for the endpoint, release version and credential
   inputs ([vocabulary](spec/vocabulary.md#not-yet-standardised)).
2. Whether an empty selection should fail by default (PUB-SEL-05),
   given that Nexus and Helm succeed today.
3. Where the reusable conformance harness lives, and which scenarios
   it runs without knowledge of the backend.

## Repository notes

The `action.yaml` and test workflow here still hold the
`actions-template` placeholders. The conformance harness will replace
them in a later change.

## Contributing

Changes follow the organisation
[`AGENTS.md`](https://github.com/lfreleng-actions/.github/blob/main/AGENTS.md)
and this repository's [`AGENTS.md`](AGENTS.md). A change to a MUST
rule needs an ADR in [`docs/adr/`](docs/adr/) and the team's review.
