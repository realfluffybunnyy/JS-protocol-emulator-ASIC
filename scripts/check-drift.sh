#!/usr/bin/env bash
# Compare pinned TT revisions with upstream branch heads.
# Prints a markdown list and exits 3 if anything moved.
set -euo pipefail
cd "$(dirname "$0")/.."

TEMPLATE_BASE=b86a2a781484bcab7ba522dc5de540086695a430

arg() { sed -n "s/^ARG $1=//p" .devcontainer/Dockerfile; }
upstream() { git ls-remote --exit-code "https://github.com/$1" "refs/heads/$2" | cut -f1; }

drift=0
check() { # name, repo, branch, pinned
    local now
    now=$(upstream "$2" "$3")
    if [ "$now" != "$4" ]; then
        echo "- $1: pinned \`${4:0:12}\`, \`$3\` is now \`${now:0:12}\` ([compare](https://github.com/$2/compare/$4...$now))"
        drift=1
    fi
}

check template TinyTapeout/ttihp-verilog-template cmos5l "$TEMPLATE_BASE"
check tt-gds-action TinyTapeout/tt-gds-action ihp-cmos5l "$(arg TT_GDS_ACTION_REF)"
check tt-support-tools TinyTapeout/tt-support-tools ihp-sg13cmos5l "$(arg TT_SUPPORT_TOOLS_REF)"

[ $drift = 0 ] || exit 3
