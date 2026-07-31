#!/usr/bin/env python3
from __future__ import annotations

import json
import statistics
import sys
from collections import defaultdict
from pathlib import Path


FRAMEWORK_ORDER = (
    "pre-commit: 1 no-op hook",
    "prek: 1 no-op hook",
    "pre-commit: 10 no-op hooks",
    "prek: 10 no-op hooks",
)
RUNTIME_ORDER = (
    "pre-commit",
    "prek: no fast path",
    "prek: fast path",
    "prek: + priority",
    "prek: + 2 projects",
)


def canonical_command(command: str) -> str:
    if command in FRAMEWORK_ORDER or command in RUNTIME_ORDER:
        return command
    if "noop-01" in command and command.startswith("PRE_COMMIT"):
        return "pre-commit: 1 no-op hook"
    if "noop-01" in command and command.startswith("PREK"):
        return "prek: 1 no-op hook"
    if ".framework-benchmark.yaml" in command and command.startswith("PRE_COMMIT"):
        return "pre-commit: 10 no-op hooks"
    if ".framework-benchmark.yaml" in command and command.startswith("PREK"):
        return "prek: 10 no-op hooks"
    return command


def pooled_results(paths: list[Path]) -> dict[str, list[float]]:
    samples: dict[str, list[float]] = defaultdict(list)
    for path in paths:
        data = json.loads(path.read_text())
        for result in data["results"]:
            samples[canonical_command(result["command"])].extend(result["times"])
    return samples


def median_ms(samples: dict[str, list[float]], command: str) -> float:
    try:
        return statistics.median(samples[command]) * 1000
    except KeyError as error:
        raise SystemExit(f"Missing benchmark command: {command}") from error


def format_ms(value: float) -> str:
    return f"{value:,.0f} ms"


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: summarize.py RESULTS_DIR")

    results_dir = Path(sys.argv[1])
    framework = pooled_results(
        [
            results_dir / "framework-forward.json",
            results_dir / "framework-reverse.json",
        ]
    )
    runtime = pooled_results(
        [
            results_dir / "runtime-forward.json",
            results_dir / "runtime-reverse.json",
        ]
    )
    diff = pooled_results([results_dir / "git-diff.json"])

    one_pre_commit = median_ms(framework, "pre-commit: 1 no-op hook")
    one_prek = median_ms(framework, "prek: 1 no-op hook")
    ten_pre_commit = median_ms(framework, "pre-commit: 10 no-op hooks")
    ten_prek = median_ms(framework, "prek: 10 no-op hooks")

    print("# Benchmark summary")
    print()
    print("## Framework")
    print()
    print("| Executed hooks | pre-commit | prek | prek speedup |")
    print("| -- | --: | --: | --: |")
    print(
        f"| 1 no-op hook | {format_ms(one_pre_commit)} | {format_ms(one_prek)} "
        f"| {one_pre_commit / one_prek:.2f}x |"
    )
    print(
        f"| 10 sequential no-op hooks | {format_ms(ten_pre_commit)} "
        f"| {format_ms(ten_prek)} | {ten_pre_commit / ten_prek:.2f}x |"
    )
    print()
    print("## Runtime ladder")
    print()
    print("| Runner and configuration | Pooled median | Samples |")
    print("| -- | --: | --: |")
    for command in RUNTIME_ORDER:
        print(
            f"| {command} | {format_ms(median_ms(runtime, command))} "
            f"| {len(runtime[command])} |"
        )
    print()
    print("## Clean git diff")
    print()
    diff_command = next(iter(diff))
    print(f"Pooled median: {format_ms(median_ms(diff, diff_command))}")


if __name__ == "__main__":
    main()
