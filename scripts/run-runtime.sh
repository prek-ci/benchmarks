#!/usr/bin/env bash
# shellcheck disable=SC2016 # Variables expand in hyperfine's command shell.
set -euo pipefail

WORK_DIR=${PREK_BENCHMARK_WORKDIR:?PREK_BENCHMARK_WORKDIR is required}
RESULTS=${RESULTS_DIR:?RESULTS_DIR is required}
HYPERFINE=${HYPERFINE_BIN:-hyperfine}
WARMUP=${WARMUP:-5}
RUNS=${RUNS:-15}

cd "$WORK_DIR/sequential"

"$HYPERFINE" \
  --warmup "$WARMUP" \
  --runs "$RUNS" \
  --style basic \
  --export-json "$RESULTS/runtime-forward.json" \
  --command-name 'pre-commit' \
  'PRE_COMMIT_COLOR=never "$PREK_BENCHMARK_PRE_COMMIT_BIN" run --all-files' \
  --command-name 'prek: no fast path' \
  'PREK_NO_FAST_PATH=1 PREK_COLOR=never PREK_QUIET=2 "$PREK_BENCHMARK_PREK_BIN" run --all-files' \
  --command-name 'prek: fast path' \
  'PREK_COLOR=never PREK_QUIET=2 "$PREK_BENCHMARK_PREK_BIN" run --all-files' \
  --command-name 'prek: + priority' \
  'PREK_COLOR=never PREK_QUIET=2 "$PREK_BENCHMARK_PREK_BIN" -C "$PREK_BENCHMARK_WORKDIR/priority" run --all-files' \
  --command-name 'prek: + 2 projects' \
  'PREK_COLOR=never PREK_QUIET=2 "$PREK_BENCHMARK_PREK_BIN" -C "$PREK_BENCHMARK_WORKDIR/projects" run --all-files'

"$HYPERFINE" \
  --warmup "$WARMUP" \
  --runs "$RUNS" \
  --style basic \
  --export-json "$RESULTS/runtime-reverse.json" \
  --command-name 'prek: + 2 projects' \
  'PREK_COLOR=never PREK_QUIET=2 "$PREK_BENCHMARK_PREK_BIN" -C "$PREK_BENCHMARK_WORKDIR/projects" run --all-files' \
  --command-name 'prek: + priority' \
  'PREK_COLOR=never PREK_QUIET=2 "$PREK_BENCHMARK_PREK_BIN" -C "$PREK_BENCHMARK_WORKDIR/priority" run --all-files' \
  --command-name 'prek: fast path' \
  'PREK_COLOR=never PREK_QUIET=2 "$PREK_BENCHMARK_PREK_BIN" run --all-files' \
  --command-name 'prek: no fast path' \
  'PREK_NO_FAST_PATH=1 PREK_COLOR=never PREK_QUIET=2 "$PREK_BENCHMARK_PREK_BIN" run --all-files' \
  --command-name 'pre-commit' \
  'PRE_COMMIT_COLOR=never "$PREK_BENCHMARK_PRE_COMMIT_BIN" run --all-files'
