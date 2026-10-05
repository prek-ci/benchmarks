# prek benchmarks

This repository contains the fixture generator, pinned configurations,
benchmark commands, and current results used by the prek benchmark documentation.
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

The reproducible setup pins prek `0.5.5`, pre-commit `4.6.1`, Python `3.14.6`,
and pre-commit-hooks `v6.0.0`. The recorded runs use hyperfine `1.20.0`.

Requirements:

- Git
- [uv](https://docs.astral.sh/uv/)
- [hyperfine](https://github.com/sharkdp/hyperfine)
- Python 3

Install the pinned runners, then execute the complete suite:

```console
./scripts/setup-tools.sh
PATH="$PWD/.tools/pre-commit/bin:$PATH" ./benchmark.sh
```

`benchmark.sh` generates fresh repositories, warms both runner caches, performs
five warmups, runs each command 15 times in each order, and writes a
pooled-median summary under `results/local-<timestamp>/`. Local outputs are
ignored by Git; only the current result summary is committed.
Adding the pre-commit environment to `PATH` makes its pinned Python available
to both runners when preparing hook environments.

To use existing binaries instead of the pinned setup:

```console
PREK_BIN=/path/to/prek \
PRE_COMMIT_BIN=/path/to/pre-commit \
./benchmark.sh
```

The main controls are environment variables:

| Variable | Default | Purpose |
| -- | -- | -- |
| `PREK_VERSION` | `0.5.5` | prek wheel to install from PyPI |
| `PYTHON_VERSION` | `3.14.6` | Python used for the isolated tool environments |
| `WARMUP` | `5` | Warmup runs per command and command order |
| `RUNS` | `15` | Measured runs per command and command order |
| `DIFF_RUNS` | `30` | Measured runs for the clean `git diff` check |
| `RESULTS_DIR` | timestamped directory | Local benchmark output directory |
| `KEEP_WORKDIR` | `0` | Set to `1` to retain generated fixtures |

## Repository layout

- `configs/` contains every hook configuration used by the comparisons.
- `scripts/create-fixtures.sh` deterministically creates and validates the
  960-file corpus and its sequential, priority, and two-project layouts. It
  verifies the resulting Git tree hashes against the published workload.
- `scripts/run-*.sh` contain the exact hyperfine command order.
- `scripts/summarize.py` pools the forward and reverse samples by command and
  reports their medians.
- `results/2026-10-05/summary.md` contains the current prek 0.5.5 results.

## Published result

On 2026-10-05, the prek 0.5.5 release wheel produced the following pooled
medians on an Apple M3 Pro with 12 cores and 18 GiB RAM running macOS 27.0:

| Comparison | pre-commit | prek |
| -- | -: | -: |
| 1 no-op hook | 228 ms | 67 ms |
| 10 sequential no-op hooks | 533 ms | 299 ms |

| Runtime stage | Median |
| -- | -: |
| pre-commit reference | 1,942 ms |
| prek, no fast path | 1,534 ms |
| prek, fast path | 105 ms |
| prek, fast path + priority | 94 ms |
| prek, fast path + priority + 2 projects | 80 ms |

Each row pools all 30 samples, including outliers. A separate 30-run clean
`git diff` check had a median of 31 ms. Forward and reverse medians differed by
up to 14%, relative to the faster order, so treat these timings and ratios as
approximate. The smaller scheduling gains are close to that variation. See the
[result summary](results/2026-10-05/summary.md) for speedups and sample counts.
