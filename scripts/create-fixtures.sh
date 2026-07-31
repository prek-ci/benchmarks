#!/usr/bin/env bash
set -euo pipefail

ROOT=${PREK_BENCHMARK_ROOT:?PREK_BENCHMARK_ROOT is required}
WORK_DIR=${PREK_BENCHMARK_WORKDIR:?PREK_BENCHMARK_WORKDIR is required}
PREK=${PREK_BENCHMARK_PREK_BIN:?PREK_BENCHMARK_PREK_BIN is required}

SOURCE_DIR="$WORK_DIR/source"
SEQUENTIAL_DIR="$WORK_DIR/sequential"
PRIORITY_DIR="$WORK_DIR/priority"
PROJECTS_DIR="$WORK_DIR/projects"

init_repo() {
  repo=$1
  git -C "$repo" init -q --initial-branch=main --object-format=sha1
  git -C "$repo" config user.name Benchmark
  git -C "$repo" config user.email bench@prek.dev
  git -C "$repo" add -A
  git -C "$repo" -c core.hooksPath=/dev/null commit -qm "Benchmark fixture"
}

copy_corpus() {
  destination=$1
  mkdir -p "$destination"
  cp -R "$SOURCE_DIR/." "$destination/"
}

mkdir -p "$SOURCE_DIR"

i=1
while [[ $i -le 50 ]]; do
  printf "line with trailing whitespace   \nanother line  " > "$SOURCE_DIR/file$i.txt"
  i=$((i + 1))
done

i=1
while [[ $i -le 30 ]]; do
  printf '{"key": "value", "number": %s}\n' "$i" > "$SOURCE_DIR/file$i.json"
  printf 'key: value\nnumber: %s\n' "$i" > "$SOURCE_DIR/file$i.yaml"
  printf '[section]\nkey = "value%s"\n' "$i" > "$SOURCE_DIR/file$i.toml"
  printf '<?xml version="1.0"?><root><item id="%s">value</item></root>\n' "$i" > "$SOURCE_DIR/file$i.xml"
  i=$((i + 1))
done

i=1
while [[ $i -le 20 ]]; do
  printf 'line1\r\nline2\nline3\r\n' > "$SOURCE_DIR/mixed$i.txt"
  printf '\xef\xbb\xbfContent with BOM' > "$SOURCE_DIR/bom$i.txt"
  i=$((i + 1))
done

i=1
while [[ $i -le 10 ]]; do
  printf '#!/bin/bash\necho hello\n' > "$SOURCE_DIR/script$i.sh"
  chmod +x "$SOURCE_DIR/script$i.sh"
  printf '# This is not a private key\napi_key = fake_key_%s\n' "$i" > "$SOURCE_DIR/config$i.txt"
  ln -s "file$i.txt" "$SOURCE_DIR/link$i.txt"
  i=$((i + 1))
done

mkdir -p "$SEQUENTIAL_DIR"
for project in a b c d; do
  copy_corpus "$SEQUENTIAL_DIR/project-$project"
done
cp "$ROOT/configs/sequential.yaml" "$SEQUENTIAL_DIR/.pre-commit-config.yaml"
init_repo "$SEQUENTIAL_DIR"

set +e
PREK_COLOR=never PREK_QUIET=2 "$PREK" -C "$SEQUENTIAL_DIR" run --all-files >/dev/null
normalize_status=$?
set -e
if [[ $normalize_status -ne 0 && $normalize_status -ne 1 ]]; then
  echo "Failed to normalize the sequential fixture" >&2
  exit "$normalize_status"
fi
git -C "$SEQUENTIAL_DIR" add -A
git -C "$SEQUENTIAL_DIR" -c core.hooksPath=/dev/null commit --amend --no-edit -q
PREK_COLOR=never PREK_QUIET=2 "$PREK" -C "$SEQUENTIAL_DIR" run --all-files

mkdir -p "$PRIORITY_DIR"
for project in a b c d; do
  cp -R "$SEQUENTIAL_DIR/project-$project" "$PRIORITY_DIR/"
done
cp "$ROOT/configs/priority.yaml" "$PRIORITY_DIR/.pre-commit-config.yaml"
init_repo "$PRIORITY_DIR"

mkdir -p "$PROJECTS_DIR/structured" "$PROJECTS_DIR/text"
for project in a b c d; do
  mkdir -p \
    "$PROJECTS_DIR/structured/project-$project" \
    "$PROJECTS_DIR/text/project-$project"
  for file in "$SEQUENTIAL_DIR/project-$project"/*; do
    case "$file" in
      *.json|*.yaml|*.toml|*.xml)
        cp -P "$file" "$PROJECTS_DIR/structured/project-$project/"
        ;;
      *)
        cp -P "$file" "$PROJECTS_DIR/text/project-$project/"
        ;;
    esac
  done
done
cp "$ROOT/configs/projects/root.yaml" "$PROJECTS_DIR/.pre-commit-config.yaml"
cp "$ROOT/configs/projects/structured.yaml" "$PROJECTS_DIR/structured/.pre-commit-config.yaml"
cp "$ROOT/configs/projects/text.yaml" "$PROJECTS_DIR/text/.pre-commit-config.yaml"
init_repo "$PROJECTS_DIR"

cp "$ROOT/configs/framework.yaml" "$SEQUENTIAL_DIR/.framework-benchmark.yaml"

sequential_count=$(git -C "$SEQUENTIAL_DIR" ls-files | wc -l | tr -d ' ')
priority_count=$(git -C "$PRIORITY_DIR" ls-files | wc -l | tr -d ' ')
projects_count=$(git -C "$PROJECTS_DIR" ls-files | wc -l | tr -d ' ')
sequential_tree=$(git -C "$SEQUENTIAL_DIR" rev-parse 'HEAD^{tree}')
priority_tree=$(git -C "$PRIORITY_DIR" rev-parse 'HEAD^{tree}')
projects_tree=$(git -C "$PROJECTS_DIR" rev-parse 'HEAD^{tree}')

if [[ $sequential_count != 961 || $priority_count != 961 || $projects_count != 963 ]]; then
  echo "Unexpected tracked file counts: $sequential_count, $priority_count, $projects_count" >&2
  exit 1
fi

if [[ $sequential_tree != 66938f445ae2865ceea417beb0d7df1d38d1a72d ||
      $priority_tree != 4100bcf9b07463db1e0292ed7966d0124118074e ||
      $projects_tree != fcbccedaa428308d15d968b43cd09fab30812d4e ]]; then
  echo "Generated fixture trees do not match the published workload" >&2
  echo "  sequential: $sequential_tree" >&2
  echo "  priority:   $priority_tree" >&2
  echo "  projects:   $projects_tree" >&2
  exit 1
fi

git -C "$SEQUENTIAL_DIR" diff --quiet
git -C "$PRIORITY_DIR" diff --quiet
git -C "$PROJECTS_DIR" diff --quiet

echo "Generated 960 workload files in sequential, priority, and two-project layouts."
