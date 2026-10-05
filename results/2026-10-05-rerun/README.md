# 2026-10-05 benchmark rerun

This is a complete rerun of the [earlier 0.5.5 measurement](../2026-10-05/README.md).
It uses the same prek binary wheel, Python 3.14.6, pre-commit 4.6.1,
pre-commit-hooks v6.0.0, and hook dependency versions. The binary checksum and
all three fixture tree hashes match the earlier run.

The benchmark ran from commit
[`a360462`](https://github.com/prek-ci/benchmarks/tree/a36046203410b0f1d38bc355bbc737b14a46d982)
with unchanged scripts and configuration. It created fresh fixtures and hook
environments, then warmed the caches before timing. Installation and network
activity are excluded from the measurements.

Each command order uses five warmups followed by 15 measured runs. The standalone
`git diff` check uses five warmups and 30 measured runs. All 300 measured
invocations returned exit code zero, and all tracked fixture files remained
unchanged. Every sample is retained, including slow outliers.

## Comparison with the earlier run

Both columns report the pooled median of all 30 samples for each command.
Changes use unrounded medians; negative values mean less elapsed time.

| Command | Earlier run | Rerun | Change |
| -- | -: | -: | -: |
| pre-commit: 1 no-op hook | 231 ms | 228 ms | -1.4% |
| prek: 1 no-op hook | 70 ms | 67 ms | -4.4% |
| pre-commit: 10 no-op hooks | 556 ms | 533 ms | -4.0% |
| prek: 10 no-op hooks | 303 ms | 299 ms | -1.4% |
| pre-commit | 1,945 ms | 1,942 ms | -0.1% |
| prek: no fast path | 1,571 ms | 1,534 ms | -2.4% |
| prek: fast path | 115 ms | 105 ms | -8.5% |
| prek: + priority | 96 ms | 94 ms | -2.0% |
| prek: + 2 projects | 82 ms | 80 ms | -2.6% |
| Clean git diff | 31 ms | 31 ms | +0.1% |

Most medians changed by less than 4.4%; the fast-path median fell by 8.5%.
The rerun therefore largely reproduces the earlier results, while retaining
noticeable variability within individual stages.

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
close to the observed order-to-order variation. Neither this rerun nor the
earlier measurement is a controlled comparison with older prek versions.

## Files and reproduction

- `framework-forward.json` and `framework-reverse.json`: one and ten no-op hooks.
- `runtime-forward.json` and `runtime-reverse.json`: the runtime ladder.
- `git-diff.json`: the standalone clean-worktree diff measurement.
- `summary.md`: the summary generated from all samples.
- `environment.txt`: software, hardware, binary checksum, and sampling details.
- `fixture-trees.txt`: the verified Git trees for all three layouts.
- `host-load.txt`: host snapshots surrounding the complete benchmark invocation.

Follow the root README's setup and benchmark commands to reproduce the workload.
The earlier raw samples remain unchanged in `results/2026-10-05/`.
