#!/usr/bin/env bash
#
# install-local.sh — install scholia into Typst's local package namespace
# (@local/scholia) without scaffolding a new notes project.
#
# Useful when you just want to `#import "@local/scholia:<version>"` from an
# existing document, or to refresh the local package after editing scholia
# itself.
#
# Usage:
#   ./install-local.sh [-f|--force]

set -euo pipefail

SCHOLIA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    -f | --force) FORCE=1; shift ;;
    -h | --help)
      sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*) echo "error: unknown flag '$1'" >&2; exit 2 ;;
    *) echo "error: unexpected argument '$1'" >&2; exit 2 ;;
  esac
done

# --- read package version from typst.toml -----------------------------------
VERSION="$(sed -n 's/^version *= *"\(.*\)".*/\1/p' "$SCHOLIA_DIR/typst.toml")"
if [ -z "$VERSION" ]; then
  echo "error: could not read version from $SCHOLIA_DIR/typst.toml" >&2
  exit 1
fi

# --- resolve Typst's local package directory (OS-dependent) -----------------
case "$(uname)" in
  Darwin) TYPST_DATA="$HOME/Library/Application Support/typst" ;;
  *) TYPST_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/typst" ;;
esac
LOCAL_PKG="$TYPST_DATA/packages/local/scholia/$VERSION"

# --- install scholia as a local package --------------------------------------
if [ -d "$LOCAL_PKG" ] && [ "$FORCE" -eq 0 ]; then
  echo "• local package @local/scholia:$VERSION already installed (use --force to refresh)"
else
  echo "• installing @local/scholia:$VERSION -> $LOCAL_PKG"
  rm -rf "$LOCAL_PKG"
  mkdir -p "$LOCAL_PKG"
  cp "$SCHOLIA_DIR/lib.typ" "$SCHOLIA_DIR/theorems.typ" "$SCHOLIA_DIR/typst.toml" "$LOCAL_PKG/"
fi

echo
echo "✓ done. Import it with:"
echo "    #import \"@local/scholia:$VERSION\": *"
