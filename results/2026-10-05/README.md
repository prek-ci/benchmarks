# 2026-10-05 benchmark run

This run measures the prek 0.5.5 binary wheel installed from PyPI with
`uv tool install --no-build`. The executable reports
`prek 0.5.5 (77cca6719 2026-10-05)`. Both runners use Python 3.14.6 for hook
environments; pre-commit is pinned to 4.6.1 and pre-commit-hooks to v6.0.0.

The fixture generator and timing scripts are unchanged from benchmark commit
[`38dbddb`](https://github.com/prek-ci/benchmarks/tree/38dbddbeccdf6578c7e9c60e67e88fb20360ebdf).
All three generated Git trees match the original 960-file workload. Installation
and network activity finish before timing begins; hook environments and
filesystem caches are warm.

- `framework-forward.json` and `framework-reverse.json`: one and ten generic
  no-op hooks, with runner order reversed between files.
- `runtime-forward.json` and `runtime-reverse.json`: pre-commit, prek without
  the fast path, fast path, priority scheduling, and two projects.
- `git-diff.json`: 30 clean-worktree `git diff` samples.
- `summary.md`: pooled medians calculated from all raw samples.
- `environment.txt`: hardware, software, binary checksum, and sampling details.
- `fixture-trees.txt`: Git tree hashes for the three fixture layouts.

Each command order uses five warmups followed by 15 measured runs. All 300
measured invocations returned exit code zero, and the fixture worktrees remained
clean afterward. No samples were removed. The standalone `git diff` measurement
uses five warmups and 30 measured runs.

Forward and reverse medians differed by up to 14.8%, in the fast-path stage
(114 ms versus 130 ms). The two-project stage differed by 8.9% (79 ms versus
87 ms); the other runtime stages differed by less than 2%. Several commands
had slower outliers. Treat the reported medians and speedups as approximate
measurements of this workload, not a promise for other repositories.

To reproduce the run, follow the root README's setup and benchmark commands.
The OS, package versions, and background load differ from historical runs, so
these measurements are not a controlled comparison of prek releases.
