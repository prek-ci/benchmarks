#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TOOLS_DIR=${TOOLS_DIR:-"$ROOT/.tools"}
PREK_REVISION=${PREK_REVISION:-9cf36ccd239e0f82cb2cd0d4daebacc38c9b5ba0}
RUST_TOOLCHAIN_VERSION=${RUST_TOOLCHAIN_VERSION:-1.97.0}
PRE_COMMIT_VERSION=${PRE_COMMIT_VERSION:-4.6.1}
PRE_COMMIT_PYTHON=${PRE_COMMIT_PYTHON:-3.14.6}
PREK_SOURCE_DIR="$TOOLS_DIR/prek-src"
CARGO_TARGET_DIR=${CARGO_TARGET_DIR:-"$TOOLS_DIR/cargo-target"}
PRE_COMMIT_VENV="$TOOLS_DIR/pre-commit"

for tool in git rustup uv; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Required tool not found: $tool" >&2
    exit 1
  fi
done

mkdir -p "$TOOLS_DIR"

if [[ ! -d "$PREK_SOURCE_DIR/.git" ]]; then
  git clone --filter=blob:none https://github.com/j178/prek.git "$PREK_SOURCE_DIR"
fi

if ! git -C "$PREK_SOURCE_DIR" diff --quiet || \
   ! git -C "$PREK_SOURCE_DIR" diff --cached --quiet; then
  echo "Refusing to change a modified tool checkout: $PREK_SOURCE_DIR" >&2
  exit 1
fi

if [[ -f "$PREK_SOURCE_DIR/.git/shallow" ]]; then
  git -C "$PREK_SOURCE_DIR" fetch --unshallow --tags origin
else
  git -C "$PREK_SOURCE_DIR" fetch --tags origin
fi
git -C "$PREK_SOURCE_DIR" checkout --detach "$PREK_REVISION"
touch "$PREK_SOURCE_DIR/.git/HEAD"

export CARGO_TARGET_DIR
rustup toolchain install "$RUST_TOOLCHAIN_VERSION"
rustup run "$RUST_TOOLCHAIN_VERSION" cargo build \
  --manifest-path "$PREK_SOURCE_DIR/Cargo.toml" \
  -p prek \
  --profile profiling \
  --locked

if [[ ! -x "$PRE_COMMIT_VENV/bin/python" ]]; then
  uv venv --python "$PRE_COMMIT_PYTHON" "$PRE_COMMIT_VENV"
fi
uv pip install \
  --python "$PRE_COMMIT_VENV/bin/python" \
  "pre-commit==$PRE_COMMIT_VERSION"

echo "Pinned tools are ready:"
echo "  prek:       $CARGO_TARGET_DIR/profiling/prek"
echo "  pre-commit: $PRE_COMMIT_VENV/bin/pre-commit"
