#!/usr/bin/env bash
set -euo pipefail

ROOT=${PREK_BENCHMARK_ROOT:?PREK_BENCHMARK_ROOT is required}
PREK=${PREK_BENCHMARK_PREK_BIN:?PREK_BENCHMARK_PREK_BIN is required}
PRE_COMMIT=${PREK_BENCHMARK_PRE_COMMIT_BIN:?PREK_BENCHMARK_PRE_COMMIT_BIN is required}
HYPERFINE=${HYPERFINE_BIN:-hyperfine}

printf 'benchmark_commit=%s\n' "$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || printf uncommitted)"
printf 'date_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf 'prek=%s\n' "$("$PREK" --version)"
printf 'pre_commit=%s\n' "$("$PRE_COMMIT" --version)"
printf 'hyperfine=%s\n' "$("$HYPERFINE" --version)"
printf 'git=%s\n' "$(git --version)"
printf 'uname=%s\n' "$(uname -a)"

if command -v rustc >/dev/null 2>&1; then
  printf 'rustc=%s\n' "$(rustc --version)"
fi

if command -v sw_vers >/dev/null 2>&1; then
  printf 'os=%s %s\n' "$(sw_vers -productName)" "$(sw_vers -productVersion)"
  printf 'cpu=%s\n' "$(sysctl -n machdep.cpu.brand_string)"
  printf 'memory_bytes=%s\n' "$(sysctl -n hw.memsize)"
elif command -v lscpu >/dev/null 2>&1; then
  printf 'cpu=%s\n' "$(lscpu | awk -F: '/Model name/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}')"
fi

printf 'warmups=%s\n' "${WARMUP:-5}"
printf 'runs_per_order=%s\n' "${RUNS:-15}"
printf 'diff_runs=%s\n' "${DIFF_RUNS:-30}"
