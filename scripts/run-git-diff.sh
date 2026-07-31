#!/usr/bin/env bash
set -euo pipefail

WORK_DIR=${PREK_BENCHMARK_WORKDIR:?PREK_BENCHMARK_WORKDIR is required}
RESULTS=${RESULTS_DIR:?RESULTS_DIR is required}
HYPERFINE=${HYPERFINE_BIN:-hyperfine}
WARMUP=${WARMUP:-5}
DIFF_RUNS=${DIFF_RUNS:-30}

cd "$WORK_DIR/sequential"

"$HYPERFINE" \
  --warmup "$WARMUP" \
  --runs "$DIFF_RUNS" \
  --style basic \
  --export-json "$RESULTS/git-diff.json" \
  'git diff --no-ext-diff --no-textconv --ignore-submodules'
