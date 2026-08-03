# prek benchmarks

This repository contains the fixture generator, pinned configurations,
benchmark commands, and raw results used by the prek benchmark documentation.
It measures two related questions:

1. How much runner overhead is visible when every hook executes `true`?
2. How does runtime change as prek adds its fast path, priority scheduling, and
   two independently scoped projects?

The generated fixture contains 960 workload files. Every benchmark starts from
a clean tracked worktree, uses warm hook environments and filesystem caches,
and runs commands in both forward and reverse order. Machine-specific timing
will vary; the scripts reproduce the workload and comparison, not an identical
wall-clock result on every host.

## Reproduce the benchmark

The reproducible setup pins prek `0.4.12`, rustc `1.97.0`, pre-commit `4.6.1`,
pre-commit-hooks `v6.0.0`, and hyperfine `1.20.0`.

Requirements:

- Git
- Rustup
- [uv](https://docs.astral.sh/uv/)
- [hyperfine](https://github.com/sharkdp/hyperfine)
- Python 3

Build and install the pinned runners, then execute the complete suite:

```console
./scripts/setup-tools.sh
./benchmark.sh
```

`benchmark.sh` generates fresh repositories, warms both runner caches, performs
five warmups, runs each command 15 times in each order, and writes the raw JSON
plus a pooled-median summary under `results/local-<timestamp>/`.

To use existing binaries instead of the pinned setup:

```console
PREK_BIN=/path/to/prek \
PRE_COMMIT_BIN=/path/to/pre-commit \
./benchmark.sh
```

The main controls are environment variables:

| Variable | Default | Purpose |
| -- | -- | -- |
| `PREK_VERSION` | `0.4.12` | prek release tag to build |
| `WARMUP` | `5` | Warmup runs per command and command order |
| `RUNS` | `15` | Measured runs per command and command order |
| `DIFF_RUNS` | `30` | Measured runs for the clean `git diff` check |
| `RESULTS_DIR` | timestamped directory | Raw JSON and summary destination |
| `KEEP_WORKDIR` | `0` | Set to `1` to retain generated fixtures |

## Repository layout

- `configs/` contains every hook configuration used by the comparisons.
- `scripts/create-fixtures.sh` deterministically creates and validates the
  960-file corpus and its sequential, priority, and two-project layouts. It
  verifies the resulting Git tree hashes against the published workload.
- `scripts/run-*.sh` contain the exact hyperfine command order.
- `scripts/summarize.py` pools the forward and reverse samples by command and
  reports their medians.
- `results/2026-07-31/` preserves the raw data behind the published numbers.

## Published result

On the Apple M3 Pro system described in `results/2026-07-31/environment.txt`,
the pooled medians were:

| Comparison | pre-commit | prek |
| -- | -: | -: |
| 1 no-op hook | 224 ms | 68 ms |
| 10 sequential no-op hooks | 458 ms | 255 ms |

| Runtime stage | Median |
| -- | -: |
| pre-commit reference | 1,737 ms |
| prek, no fast path | 1,438 ms |
| prek, fast path | 213 ms |
| prek, fast path + priority | 172 ms |
| prek, fast path + priority + 2 projects | 135 ms |

See the raw hyperfine samples and generated summary in
`results/2026-07-31/` for the complete data.
