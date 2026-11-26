#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 The Linux Foundation

# Check that the schemas accept and reject the cases under
# tests/schema-cases/. Each case directory holds a target, a fragment
# of a schema reached by $ref, and documents named valid-*.yaml or
# invalid-*.yaml. Every document runs under both regex dialects that
# check-jsonschema offers, ECMAScript and Python: tools that read the
# declarations use either, and a pattern anchored with '$' matches
# before a trailing newline in Python.
#
# A document counts as rejected when check-jsonschema reports a
# validation error, and not on any other failure, so a broken target
# or an unreadable document fails the check instead of passing it.
#
# Usage: tests/check-schema-cases.sh
# Exit codes: 0 all cases behave as named; 1 a case misbehaved;
#             2 check-jsonschema is missing or a case is malformed.

set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cases="$root/tests/schema-cases"

if ! command -v check-jsonschema > /dev/null 2>&1; then
  echo 'check-jsonschema is not installed' >&2
  exit 2
fi

checks=0
failures=0
for dir in "$cases"/*/; do
  target="$dir/target.yaml"
  if [ ! -f "$target" ]; then
    echo "missing target: $target" >&2
    exit 2
  fi
  for document in "$dir"valid-*.yaml "$dir"invalid-*.yaml; do
    [ -e "$document" ] || continue
    case "$(basename "$document")" in
      valid-*) expected=accept ;;
      *) expected=reject ;;
    esac
    for variant in default python; do
      checks=$((checks + 1))
      if output=$(check-jsonschema --regex-variant "$variant" \
        --schemafile "$target" "$document" 2>&1); then
        actual=accept
      elif [[ "$output" == *'Schema validation errors were encountered'* ]]
      then
        actual=reject
      else
        echo "ERROR ${document#"$root"/} [$variant]:" >&2
        printf '%s\n' "$output" >&2
        exit 2
      fi
      if [ "$actual" != "$expected" ]; then
        failures=$((failures + 1))
        echo "FAIL ${document#"$root"/} [$variant]: expected $expected"
      fi
    done
  done
done

echo "$((checks - failures))/$checks schema case checks passed"
[ "$failures" -eq 0 ]
