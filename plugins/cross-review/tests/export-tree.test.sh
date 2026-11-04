#!/usr/bin/env bash
# Tests for export-tree.sh. Each test builds its own repo in a temp directory.
#
# Run: bash plugins/cross-review/tests/export-tree.test.sh
set -u

script="$(cd "$(dirname "$0")/.." && pwd)/skills/cross-review/scripts/export-tree.sh"
failures=0
failed_here=0

fail() {
    echo "    $1"
    failed_here=1
}

new_repo() {
    repo="$(mktemp -d)"
    cd "$repo" || exit 1
    git init -q -b main .
    git config user.name "Test"
    git config user.email "test@example.invalid"
    git config commit.gpgsign false
}

commit_all() {
    git add -A
    git commit -qm "$1"
}

assert_has() {
    [ -e "$1/$2" ] || fail "missing: $2"
}

assert_absent() {
    [ ! -e "$1/$2" ] && [ ! -L "$1/$2" ] || fail "should be absent: $2"
}

assert_contents() {
    [ "$(cat "$1/$2" 2>/dev/null)" = "$3" ] || fail "$2 should contain: $3"
}

exports_revision() {
    new_repo
    echo old > file.py
    commit_all "old"
    echo new > file.py
    commit_all "new"
    echo dirty > file.py
    out="$(bash "$script" HEAD~1)" || fail "script failed"
    assert_contents "$out" file.py old
}

exports_worktree() {
    new_repo
    echo "*.env" > .gitignore
    echo old > edited.py
    echo gone > deleted.py
    echo secret > ignored.env
    commit_all "base"
    echo now > edited.py
    echo added > untracked.py
    rm deleted.py
    out="$(bash "$script" --worktree)" || fail "script failed"
    assert_contents "$out" edited.py now
    assert_contents "$out" untracked.py added
    assert_absent "$out" deleted.py
    assert_absent "$out" ignored.env
}

strips_agent_config() {
    new_repo
    mkdir -p .claude .codex .kiro/settings .agents sub/.Claude sub/.kiro
    echo keep > keep.py
    echo keep > sub/keep.py
    echo x > .claude/settings.json
    echo x > .codex/config.toml
    echo x > .kiro/settings/mcp.json
    echo x > .agents/thing
    echo x > .mcp.json
    echo x > sub/.Claude/settings.json
    echo x > sub/.kiro/thing
    echo x > sub/.mcp.json
    commit_all "config"
    for arg in HEAD --worktree; do
        out="$(bash "$script" "$arg")" || fail "script failed for $arg"
        for path in .claude .codex .kiro .agents .mcp.json sub/.Claude sub/.kiro sub/.mcp.json; do
            assert_absent "$out" "$path"
        done
        assert_has "$out" keep.py
        assert_has "$out" sub/keep.py
    done
}

strips_symlinks() {
    new_repo
    echo keep > keep.py
    ln -s /etc/hosts outside.txt
    ln -s keep.py inside.txt
    commit_all "links"
    for arg in HEAD --worktree; do
        out="$(bash "$script" "$arg")" || fail "script failed for $arg"
        [ -z "$(find "$out" -type l)" ] || fail "symlink left for $arg"
        assert_has "$out" keep.py
    done
}

has_no_git_dir() {
    new_repo
    echo keep > keep.py
    commit_all "base"
    for arg in HEAD --worktree; do
        out="$(bash "$script" "$arg")" || fail "script failed for $arg"
        assert_absent "$out" .git
    done
}

bad_revision_fails_clean() {
    new_repo
    [ -f "$script" ] || fail "script is missing"
    echo keep > keep.py
    commit_all "base"
    scratch="$(mktemp -d)"
    if out="$(TMPDIR="$scratch" bash "$script" no-such-revision 2>/dev/null)"; then
        fail "should exit non-zero"
    fi
    [ -z "$out" ] || fail "stdout should be empty"
    [ -z "$(find "$scratch" -mindepth 1)" ] || fail "temp directory left behind"
}

refuses_options_and_handles_spaces() {
    new_repo
    mkdir "dir with space"
    echo keep > "dir with space/file.py"
    commit_all "base"
    if bash "$script" --output=x >/dev/null 2>&1; then
        fail "--output=x should be refused"
    fi
    assert_absent . x
    out="$(bash "$script" HEAD)" || fail "script failed"
    assert_has "$out" "dir with space/file.py"
}

for name in exports_revision exports_worktree strips_agent_config strips_symlinks \
    has_no_git_dir bad_revision_fails_clean refuses_options_and_handles_spaces; do
    failed_here=0
    echo "$name"
    "$name"
    if [ "$failed_here" = 1 ]; then
        failures=$((failures + 1))
        echo "  FAIL"
    else
        echo "  ok"
    fi
done

echo "$failures failed"
[ "$failures" = 0 ]
