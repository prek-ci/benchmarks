#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

PREK_BIN=${PREK_BIN:-"$ROOT/.tools/cargo-target/profiling/prek"}
PRE_COMMIT_BIN=${PRE_COMMIT_BIN:-"$ROOT/.tools/pre-commit/bin/pre-commit"}
HYPERFINE_BIN=${HYPERFINE_BIN:-hyperfine}
PYTHON_BIN=${PYTHON_BIN:-python3}
WARMUP=${WARMUP:-5}
RUNS=${RUNS:-15}
DIFF_RUNS=${DIFF_RUNS:-30}
KEEP_WORKDIR=${KEEP_WORKDIR:-0}

if [[ ! -x "$PREK_BIN" ]]; then
  echo "prek binary not found at $PREK_BIN" >&2
  echo "Run ./scripts/setup-tools.sh or set PREK_BIN." >&2
  exit 1
fi

if [[ ! -x "$PRE_COMMIT_BIN" ]]; then
  echo "pre-commit binary not found at $PRE_COMMIT_BIN" >&2
  echo "Run ./scripts/setup-tools.sh or set PRE_COMMIT_BIN." >&2
  exit 1
fi

if ! command -v "$HYPERFINE_BIN" >/dev/null 2>&1; then
  echo "hyperfine not found: $HYPERFINE_BIN" >&2
  exit 1
fi

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "Python not found: $PYTHON_BIN" >&2
  exit 1
fi

timestamp=$(date -u +%Y%m%dT%H%M%SZ)
RESULTS_DIR=${RESULTS_DIR:-"$ROOT/results/local-$timestamp"}
case "$RESULTS_DIR" in
  /*) ;;
  *) RESULTS_DIR="$ROOT/$RESULTS_DIR" ;;
esac

if [[ -e "$RESULTS_DIR" ]]; then
  echo "Results directory already exists: $RESULTS_DIR" >&2
  exit 1
fi
mkdir -p "$RESULTS_DIR"

created_temp_workdir=0
if [[ -n "${BENCHMARK_WORKDIR:-}" ]]; then
  case "$BENCHMARK_WORKDIR" in
    /*) ;;
    *) BENCHMARK_WORKDIR="$ROOT/$BENCHMARK_WORKDIR" ;;
  esac
  if [[ -e "$BENCHMARK_WORKDIR" ]]; then
    echo "Benchmark work directory already exists: $BENCHMARK_WORKDIR" >&2
    exit 1
  fi
  mkdir -p "$BENCHMARK_WORKDIR"
else
  BENCHMARK_WORKDIR=$(mktemp -d "${TMPDIR:-/tmp}/prek-benchmarks.XXXXXX")
  created_temp_workdir=1
fi

cleanup() {
  if [[ "$created_temp_workdir" == 1 && "$KEEP_WORKDIR" != 1 ]]; then
    rm -rf -- "$BENCHMARK_WORKDIR"
  elif [[ "$KEEP_WORKDIR" == 1 ]]; then
    echo "Generated fixtures: $BENCHMARK_WORKDIR"
  fi
}
trap cleanup EXIT

export PREK_BIN PRE_COMMIT_BIN HYPERFINE_BIN PYTHON_BIN
export WARMUP RUNS DIFF_RUNS RESULTS_DIR BENCHMARK_WORKDIR
export PREK_HOME="$BENCHMARK_WORKDIR/cache/prek"
export PRE_COMMIT_HOME="$BENCHMARK_WORKDIR/cache/pre-commit"
export PREK_BENCHMARK_ROOT="$ROOT"
export PREK_BENCHMARK_PREK_BIN="$PREK_BIN"
export PREK_BENCHMARK_PRE_COMMIT_BIN="$PRE_COMMIT_BIN"
export PREK_BENCHMARK_WORKDIR="$BENCHMARK_WORKDIR"

mkdir -p "$PREK_HOME" "$PRE_COMMIT_HOME"

"$ROOT/scripts/create-fixtures.sh"
"$ROOT/scripts/prepare-hooks.sh"
"$ROOT/scripts/capture-environment.sh" > "$RESULTS_DIR/environment.txt"
"$ROOT/scripts/run-framework.sh"
"$ROOT/scripts/run-runtime.sh"
"$ROOT/scripts/run-git-diff.sh"
"$PYTHON_BIN" "$ROOT/scripts/summarize.py" "$RESULTS_DIR" > "$RESULTS_DIR/summary.md"

echo "Benchmark complete: $RESULTS_DIR"
echo
cat "$RESULTS_DIR/summary.md"
