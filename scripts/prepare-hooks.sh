#!/usr/bin/env bash
set -euo pipefail

WORK_DIR=${PREK_BENCHMARK_WORKDIR:?PREK_BENCHMARK_WORKDIR is required}
PREK=${PREK_BENCHMARK_PREK_BIN:?PREK_BENCHMARK_PREK_BIN is required}
PRE_COMMIT=${PREK_BENCHMARK_PRE_COMMIT_BIN:?PREK_BENCHMARK_PRE_COMMIT_BIN is required}

SEQUENTIAL_DIR="$WORK_DIR/sequential"
PRIORITY_DIR="$WORK_DIR/priority"
PROJECTS_DIR="$WORK_DIR/projects"

PREK_NO_FAST_PATH=1 PREK_COLOR=never \
  "$PREK" -C "$SEQUENTIAL_DIR" prepare-hooks
(
  cd "$SEQUENTIAL_DIR"
  PRE_COMMIT_COLOR=never "$PRE_COMMIT" install-hooks
)

(
  cd "$SEQUENTIAL_DIR"
  PRE_COMMIT_COLOR=never "$PRE_COMMIT" run --all-files >/dev/null
  PREK_NO_FAST_PATH=1 PREK_COLOR=never PREK_QUIET=2 \
    "$PREK" run --all-files >/dev/null
  PREK_COLOR=never PREK_QUIET=2 "$PREK" run --all-files >/dev/null
  PRE_COMMIT_COLOR=never "$PRE_COMMIT" \
    run noop-01 --all-files --config .framework-benchmark.yaml >/dev/null
  PREK_COLOR=never "$PREK" -c .framework-benchmark.yaml \
    run noop-01 --all-files >/dev/null
  PRE_COMMIT_COLOR=never "$PRE_COMMIT" \
    run --all-files --config .framework-benchmark.yaml >/dev/null
  PREK_COLOR=never "$PREK" -c .framework-benchmark.yaml \
    run --all-files >/dev/null
)

PREK_COLOR=never PREK_QUIET=2 \
  "$PREK" -C "$PRIORITY_DIR" run --all-files >/dev/null
PREK_COLOR=never PREK_QUIET=2 \
  "$PREK" -C "$PROJECTS_DIR" run --all-files >/dev/null

git -C "$SEQUENTIAL_DIR" diff --quiet
git -C "$PRIORITY_DIR" diff --quiet
git -C "$PROJECTS_DIR" diff --quiet

echo "Hook environments and runner caches are warm."
