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
  --export-json "$RESULTS/framework-forward.json" \
  --command-name 'pre-commit: 1 no-op hook' \
  'PRE_COMMIT_COLOR=never "$PREK_BENCHMARK_PRE_COMMIT_BIN" run noop-01 --all-files --config .framework-benchmark.yaml' \
  --command-name 'prek: 1 no-op hook' \
  'PREK_COLOR=never "$PREK_BENCHMARK_PREK_BIN" -c .framework-benchmark.yaml run noop-01 --all-files' \
  --command-name 'pre-commit: 10 no-op hooks' \
  'PRE_COMMIT_COLOR=never "$PREK_BENCHMARK_PRE_COMMIT_BIN" run --all-files --config .framework-benchmark.yaml' \
  --command-name 'prek: 10 no-op hooks' \
  'PREK_COLOR=never "$PREK_BENCHMARK_PREK_BIN" -c .framework-benchmark.yaml run --all-files'

"$HYPERFINE" \
  --warmup "$WARMUP" \
  --runs "$RUNS" \
  --style basic \
  --export-json "$RESULTS/framework-reverse.json" \
  --command-name 'prek: 10 no-op hooks' \
  'PREK_COLOR=never "$PREK_BENCHMARK_PREK_BIN" -c .framework-benchmark.yaml run --all-files' \
  --command-name 'pre-commit: 10 no-op hooks' \
  'PRE_COMMIT_COLOR=never "$PREK_BENCHMARK_PRE_COMMIT_BIN" run --all-files --config .framework-benchmark.yaml' \
  --command-name 'prek: 1 no-op hook' \
  'PREK_COLOR=never "$PREK_BENCHMARK_PREK_BIN" -c .framework-benchmark.yaml run noop-01 --all-files' \
  --command-name 'pre-commit: 1 no-op hook' \
  'PRE_COMMIT_COLOR=never "$PREK_BENCHMARK_PRE_COMMIT_BIN" run noop-01 --all-files --config .framework-benchmark.yaml'
