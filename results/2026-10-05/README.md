# 2026-10-05 benchmark run

This run measures the prek 0.5.5 binary wheel installed from PyPI with
`uv tool install --no-build`. The executable reports
`prek 0.5.5 (77cca6719 2026-10-05)`. Both runners use Python 3.14.6 for hook
environments; pre-commit is pinned to 4.6.1 and pre-commit-hooks to v6.0.0.
All three generated Git trees match the original 960-file workload.

The benchmark ran from commit
[`a360462`](https://github.com/prek-ci/benchmarks/tree/a36046203410b0f1d38bc355bbc737b14a46d982)
with unchanged scripts and configuration. It created fresh fixtures and hook
environments, then warmed the caches before timing. Installation and network
activity are excluded from the measurements.

Each command order uses five warmups followed by 15 measured runs. The standalone
`git diff` check uses five warmups and 30 measured runs. All 300 measured
invocations returned exit code zero, and all tracked fixture files remained
unchanged. Every sample is retained, including slow outliers.

## Variation and host load

Forward and reverse medians differed by up to 14.0%, relative to the faster
order. The two-project medians were 86 ms and 76 ms; pre-commit's were
1,880 ms and 2,037 ms, an 8.4% difference. Every other command differed by at
most 5.0%. Several commands had slow outliers.

The host remained on AC power. Snapshots before fixture preparation and after
measurement showed background CPU activity, compressed memory, and swapping;
there was no recorded thermal or performance warning. These snapshots are
included in `host-load.txt`. They do not establish the cause of individual slow
samples, but the machine was not an isolated benchmark host.

Treat the timings and ratios as approximate. The smaller scheduling gains are
close to the observed order-to-order variation. These results are not a
controlled comparison with older prek versions.

## Files and reproduction

- `framework-forward.json` and `framework-reverse.json`: one and ten no-op hooks.
- `runtime-forward.json` and `runtime-reverse.json`: the runtime ladder.
- `git-diff.json`: the standalone clean-worktree diff measurement.
- `summary.md`: the summary generated from all samples.
- `environment.txt`: software, hardware, binary checksum, and sampling details.
- `fixture-trees.txt`: the verified Git trees for all three layouts.
- `host-load.txt`: host snapshots surrounding the complete benchmark invocation.

Follow the root README's setup and benchmark commands to reproduce the workload.
