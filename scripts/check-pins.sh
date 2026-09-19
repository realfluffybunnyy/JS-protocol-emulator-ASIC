#!/usr/bin/env bash
# Fail if the TT revisions pinned in the Dockerfile and the workflows disagree.
set -euo pipefail
cd "$(dirname "$0")/.."

arg() { sed -n "s/^ARG $1=//p" .devcontainer/Dockerfile; }
workflows=(.github/workflows/gds.yaml .github/workflows/docs.yaml)

status=0
expect() { # what, expected, found values...
    local what=$1 want=$2; shift 2
    for got in "$@"; do
        if [ "$got" != "$want" ]; then
            echo "$what: workflows use $got, Dockerfile pins $want"
            status=1
        fi
    done
}

expect tt-gds-action "$(arg TT_GDS_ACTION_REF)" \
    $(grep -hoE 'TinyTapeout/tt-gds-action(/[a-z_]+)?@[^ ]+' "${workflows[@]}" | sed 's/.*@//' | sort -u)
expect tt-support-tools "$(arg TT_SUPPORT_TOOLS_REF)" \
    $(grep -hoE 'tools-ref: [^ ]+' "${workflows[@]}" | sed 's/.* //' | sort -u)
expect librelane "$(arg LIBRELANE_VERSION)" \
    $(grep -hoE 'librelane-version: [^ ]+' "${workflows[@]}" | sed 's/.* //' | sort -u)

exit $status
