#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TOOLS_DIR=${TOOLS_DIR:-"$ROOT/.tools"}
PREK_VERSION=${PREK_VERSION:-0.5.5}
PRE_COMMIT_VERSION=${PRE_COMMIT_VERSION:-4.6.1}
PYTHON_VERSION=${PYTHON_VERSION:-3.14.6}
PREK_TOOL_DIR="$TOOLS_DIR/uv-tools"
PREK_BIN_DIR="$TOOLS_DIR/bin"
PRE_COMMIT_VENV="$TOOLS_DIR/pre-commit"

for tool in git uv; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Required tool not found: $tool" >&2
    exit 1
  fi
done

mkdir -p "$TOOLS_DIR" "$PREK_BIN_DIR"

UV_TOOL_DIR="$PREK_TOOL_DIR" \
UV_TOOL_BIN_DIR="$PREK_BIN_DIR" \
uv tool install \
  --force \
  --no-build \
  --python "$PYTHON_VERSION" \
  "prek==$PREK_VERSION"

if [[ ! -x "$PRE_COMMIT_VENV/bin/python" ]]; then
  uv venv --python "$PYTHON_VERSION" "$PRE_COMMIT_VENV"
fi
uv pip install \
  --python "$PRE_COMMIT_VENV/bin/python" \
  "pre-commit==$PRE_COMMIT_VERSION"

echo "Pinned tools are ready:"
echo "  prek:       $PREK_BIN_DIR/prek"
echo "  pre-commit: $PRE_COMMIT_VENV/bin/pre-commit"
