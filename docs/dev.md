# Development

All tools live in the dev container. Nothing is installed on the host.

## Setup

Install Docker (on macOS, Docker Desktop for Apple Silicon) and give it at least 8 GB of memory and 60 GB of
disk: the image is about 8 GB and the hardening tools pull another 6.6 GB inside it.

Install the VS Code Dev Containers extension, open the repo, and run "Dev Containers: Reopen in Container".
The first build takes about 15 minutes, or 30 on arm64, where gdstk is compiled from source.

Without VS Code:

    npx @devcontainers/cli up --workspace-folder .
    devcontainer exec --workspace-folder . make test

## Targets

Run these inside the container.

- `make test` - Hardcaml tests and the cocotb simulation
- `make gen` - regenerate `src/` from `hw/`; commit the result
- `make fmt` - format OCaml
- `make harden` - GDS at 6x4, about 40 minutes
- `make test-gl` - gate-level test, after a harden
- `make check-gen check-pins fmt-check` - what CI enforces

## Layout

- `hw/rtl` - the design, in Hardcaml
- `hw/test` - Hardcaml tests
- `test` - cocotb tests
- `src` - generated Verilog, do not edit
- `tt` - Tiny Tapeout tools, copied in when the container starts

Waveforms land in `test/tb.fst`; open them with Surfer. x86 results are the reference for area and timing.
