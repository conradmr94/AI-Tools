#!/usr/bin/env bash
# Copies code to a new temp directory for a reviewer to run in, leaving out everything that could
# run or be followed there: agent config, symlinks and .git. Run it from inside the repo.
#
#   export-tree.sh <rev>         exports that revision
#   export-tree.sh --worktree    exports tracked and untracked files as they are now
#
# Prints the export's path on stdout and nothing else.
set -euo pipefail

target="${1:?usage: export-tree.sh <rev>|--worktree}"

# A sandbox can block the system git, so try the usual installs too.
git=""
for candidate in git /opt/homebrew/bin/git /usr/local/bin/git; do
    if root="$("$candidate" rev-parse --show-toplevel 2>/dev/null)"; then
        git="$candidate"
        break
    fi
done
if [ -z "$git" ]; then
    echo "export-tree.sh: no working git, or not in a repo" >&2
    exit 1
fi
cd "$root"

if [ "$target" != --worktree ]; then
    rev="$("$git" rev-parse --verify --quiet --end-of-options "$target^{commit}")" || {
        echo "export-tree.sh: not a revision: $target" >&2
        exit 1
    }
fi

# An explicit template, because a bare mktemp can ignore TMPDIR and fail in a sandbox.
export_dir="$(mktemp -d "${TMPDIR:-/tmp}/cross-review.XXXXXX")"
finished=no
trap '[ "$finished" = yes ] || rm -rf "$export_dir"' EXIT

if [ "$target" = --worktree ]; then
    "$git" ls-files -z --cached --others --exclude-standard |
        while IFS= read -r -d '' path; do
            if [ -e "$path" ] || [ -L "$path" ]; then
                printf '%s\0' "$path"
            fi
        done |
        tar --null -T - -cf - |
        tar -x -C "$export_dir"
else
    "$git" archive "$rev" | tar -x -C "$export_dir"
fi

find "$export_dir" -type l -delete
# -iname because macOS treats .Claude as .claude.
find "$export_dir" -mindepth 1 \( -iname .git -o -iname .claude -o -iname .codex -o -iname .kiro \
    -o -iname .agents -o -iname .mcp.json \) -prune -exec rm -rf {} +

finished=yes
echo "$export_dir"
