# 2026-07-31 benchmark run

This directory preserves the raw hyperfine output used by the prek benchmark
documentation:

- `framework-forward.json` and `framework-reverse.json`: one and ten generic
  no-op hooks, with runner order reversed between files.
- `runtime-forward.json` and `runtime-reverse.json`: pre-commit, prek without
  the fast path, fast path, priority scheduling, and two projects.
- `git-diff.json`: 30 clean-worktree `git diff` samples.
- `summary.md`: pooled medians calculated from the raw samples.
- `environment.txt`: hardware, software, fixture, and sampling details.
- `fixture-trees.txt`: Git tree hashes for the three generated fixture layouts.

The raw command strings contain paths from the machine that produced the data.
The repository scripts replace those paths with environment variables while
preserving the command semantics.
