FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04@sha256:d94c97dd9cacf183d0a6fd12a8e87b526e9e928307674ae9c94139139c0c6eae

# Keep in sync with the TT action SHAs pinned in .github/workflows
ARG TT_SUPPORT_TOOLS_REF=f6bf5c587fba4a4a8abd4c0a03234fccfbf6e61e
ARG TT_GDS_ACTION_REF=3412659307918422f3f0727917cf9b499aaca588
ARG LIBRELANE_VERSION=3.1.0.dev3
ARG KLAYOUT_ARM64_VERSION=0.30.9
ARG IVERILOG_TAG=v13_0
ARG IVERILOG_DEB_SHA256=888bca6b06289ea8b55368d43db38dc88932938319ab40d45a763ce5114e8505
ARG OSS_CAD_SUITE_DATE=2026-09-18
ARG OSS_CAD_SUITE_SHA256_X64=cbd598df0f66326213f3f2cf911906a6aa0644048397b80bf851f34df078a92d
ARG OSS_CAD_SUITE_SHA256_ARM64=fbf5518e46b4f510427e7ded290d8f9a5a124c1d42cd110f96e5c83cf2980bd2
ARG OPAM_REPO_COMMIT=8cdfa3296d9bc7d93273f46eb2438757e4fd5cf0
# Must match hw/.ocamlformat
ARG OCAMLFORMAT_VERSION=0.29.0
ARG OCAML_LSP_VERSION=1.23.1
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential pkg-config m4 unzip bubblewrap opam \
        libgmp-dev libffi-dev zlib1g-dev \
        python3 python3-dev python3-venv python-is-python3 \
        libcairo2 librsvg2-bin pngquant libqhull-dev libpng-dev \
        autoconf gperf flex bison \
    && rm -rf /var/lib/apt/lists/*

# Icarus Verilog 13.0: same .deb as TT's gl_test on amd64, same tag from source elsewhere
RUN set -eux; \
    if [ "$TARGETARCH" = amd64 ]; then \
        curl -fsSL -o /tmp/iverilog.deb https://github.com/TinyTapeout/iverilog/releases/download/v13.0/iverilog_13.0-1_amd64.deb; \
        echo "$IVERILOG_DEB_SHA256  /tmp/iverilog.deb" | sha256sum -c; \
        apt-get update; apt-get install -y /tmp/iverilog.deb; rm -rf /tmp/iverilog.deb /var/lib/apt/lists/*; \
    else \
        git clone -q --depth 1 -b "$IVERILOG_TAG" https://github.com/steveicarus/iverilog /tmp/iverilog; \
        cd /tmp/iverilog; sh autoconf.sh; ./configure --prefix=/usr; make -j"$(nproc)"; make install; \
        cd /; rm -rf /tmp/iverilog; \
    fi; \
    iverilog -V 2>&1 | head -1

# OSS CAD Suite for formal (sby, yosys, solvers); appended to PATH so apt tools win
RUN set -eux; \
    d=$(echo "$OSS_CAD_SUITE_DATE" | tr -d -); \
    case "$TARGETARCH" in \
        amd64) a=x64; sum=$OSS_CAD_SUITE_SHA256_X64 ;; \
        arm64) a=arm64; sum=$OSS_CAD_SUITE_SHA256_ARM64 ;; \
    esac; \
    curl -fsSL -o /tmp/ocs.tgz "https://github.com/YosysHQ/oss-cad-suite-build/releases/download/$OSS_CAD_SUITE_DATE/oss-cad-suite-linux-$a-$d.tgz"; \
    echo "$sum  /tmp/ocs.tgz" | sha256sum -c; \
    tar -xzf /tmp/ocs.tgz -C /opt; rm /tmp/ocs.tgz

# tt-support-tools and the cmos5l PDK, at the revisions TT CI uses
ENV PDK=ihp-sg13cmos5l
ENV PDK_ROOT=/opt/pdk
RUN set -eux; \
    git clone -q https://github.com/TinyTapeout/tt-support-tools /opt/tt-support-tools; \
    git -C /opt/tt-support-tools checkout -q "$TT_SUPPORT_TOOLS_REF"; \
    curl -fsSL "https://raw.githubusercontent.com/TinyTapeout/tt-gds-action/$TT_GDS_ACTION_REF/install_sg13cmos5l.sh" | bash

COPY test/requirements.txt /tmp/test_requirements.txt
# gdstk has no aarch64 wheels and builds from source (hence libqhull-dev/libpng-dev);
# klayout's aarch64 wheels start at 0.30.2, so arm64 takes a newer one than TT CI pins.
RUN set -eux; \
    reqs=/tmp/tt_requirements.txt; \
    cp /opt/tt-support-tools/requirements.txt "$reqs"; \
    if [ "$TARGETARCH" != amd64 ]; then \
        sed -i "s/^klayout==.*/klayout==$KLAYOUT_ARM64_VERSION/" "$reqs"; \
    fi; \
    python -m venv /opt/venv; \
    /opt/venv/bin/pip install --no-cache-dir \
        -r /tmp/test_requirements.txt \
        -r "$reqs" \
        librelane==$LIBRELANE_VERSION; \
    rm /tmp/test_requirements.txt "$reqs"

# OCaml toolchain: compiler and libraries from hw's lock file, fixed opam-repository commit
ENV OPAMROOT=/opt/opam
RUN mkdir -p $OPAMROOT && chown vscode:vscode $OPAMROOT
COPY --chown=vscode hw/protocol_emulator.opam hw/protocol_emulator.opam.locked /tmp/hw/
USER vscode
RUN opam init -y --bare --disable-sandboxing \
        default "git+https://github.com/ocaml/opam-repository#$OPAM_REPO_COMMIT" \
    && opam switch create -y default --empty \
    && opam install -y --deps-only --locked /tmp/hw \
    && opam install -y ocaml-lsp-server.$OCAML_LSP_VERSION ocamlformat.$OCAMLFORMAT_VERSION \
    && opam clean -a -c -s --logs \
    && rm -rf /tmp/hw
USER root

ENV OPAM_SWITCH_PREFIX=$OPAMROOT/default
ENV CAML_LD_LIBRARY_PATH=$OPAM_SWITCH_PREFIX/lib/stublibs:$OPAM_SWITCH_PREFIX/lib/ocaml/stublibs:$OPAM_SWITCH_PREFIX/lib/ocaml
ENV OCAML_TOPLEVEL_PATH=$OPAM_SWITCH_PREFIX/lib/toplevel
ENV PATH=$OPAM_SWITCH_PREFIX/bin:/opt/venv/bin:$PATH:/opt/oss-cad-suite/bin

# CI checks out as a different user than the one running the container
RUN git config --system --add safe.directory '*'
