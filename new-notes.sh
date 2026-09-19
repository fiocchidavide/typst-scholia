#!/usr/bin/env bash
#
# new-notes.sh — scaffold a fresh, self-contained lecture-notes project from the
# scholia template and initialise a working git repository for it.
#
# Usage:
#   ./new-notes.sh <target-dir> [title]
#
# Examples:
#   ./new-notes.sh ~/Notes/analysis-fs26
#   ./new-notes.sh ~/Notes/analysis-fs26 "Analysis I"
#
# What it does:
#   1. Installs scholia into Typst's local package namespace (@local/scholia),
#      so the new project compiles without the package being published
#      (see install-local.sh, which handles this step).
#   2. Copies the template into <target-dir>.
#   3. Rewrites the template's `@preview/scholia` import to `@local/scholia`.
#   4. Runs `git init` and creates an initial commit.
#
# Flags:
#   -f, --force   Overwrite the local package if it already exists.

set -euo pipefail

# --- locate this repo (the script lives at its root) ------------------------
SCHOLIA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- parse arguments --------------------------------------------------------
FORCE=0
POSITIONAL=()
while [ $# -gt 0 ]; do
  case "$1" in
    -f | --force) FORCE=1; shift ;;
    -h | --help)
      sed -n '2,25p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*) echo "error: unknown flag '$1'" >&2; exit 2 ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

if [ "${#POSITIONAL[@]}" -lt 1 ]; then
  echo "usage: $(basename "$0") <target-dir> [title]" >&2
  exit 2
fi

TARGET="${POSITIONAL[0]}"
TITLE="${POSITIONAL[1]:-}"

# --- read package version from typst.toml -----------------------------------
VERSION="$(sed -n 's/^version *= *"\(.*\)".*/\1/p' "$SCHOLIA_DIR/typst.toml")"
if [ -z "$VERSION" ]; then
  echo "error: could not read version from $SCHOLIA_DIR/typst.toml" >&2
  exit 1
fi

# --- 1. install scholia as a local package ----------------------------------
if [ "$FORCE" -eq 1 ]; then
  "$SCHOLIA_DIR/install-local.sh" --force
else
  "$SCHOLIA_DIR/install-local.sh"
fi

# --- 2. copy the template into the target -----------------------------------
if [ -e "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null || true)" ]; then
  echo "error: target '$TARGET' already exists and is not empty" >&2
  exit 1
fi
echo "• scaffolding project at $TARGET"
mkdir -p "$TARGET"
cp -R "$SCHOLIA_DIR/template/." "$TARGET/"

# --- 3. point the imports at the local package ------------------------------
# Use the running package version rather than whatever is pinned in the template.
find "$TARGET" -name '*.typ' -print0 | while IFS= read -r -d '' f; do
  perl -pi -e "s{\@preview/scholia:[0-9.]+}{\@local/scholia:$VERSION}g" "$f"
done

# --- optional: set the title ------------------------------------------------
if [ -n "$TITLE" ]; then
  perl -pi -e "s/\Q[My Lecture Notes]\E/[$TITLE]/" "$TARGET/main.typ"
fi

# --- add a .gitignore for build artefacts -----------------------------------
cat > "$TARGET/.gitignore" <<'EOF'
*.pdf
.DS_Store
EOF

# --- 4. initialise the git repository ---------------------------------------
echo "• initialising git repository"
git -C "$TARGET" init -q
git -C "$TARGET" add -A
# Fall back to a sensible identity only if git has none configured globally.
if git -C "$TARGET" config user.email >/dev/null 2>&1; then
  git -C "$TARGET" commit -q -m "Initial commit from scholia template"
else
  git -C "$TARGET" \
    -c user.name="Davide" -c user.email="davidefiocchi2@gmail.com" \
    commit -q -m "Initial commit from scholia template"
fi

echo
echo "✓ done. Next steps:"
echo "    cd $TARGET"
echo "    typst watch main.typ    # live preview"
