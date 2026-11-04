#!/usr/bin/env bash
# Tests that every skill in plugins/ is wired up for Kiro.
#
# Run: bash tests/hosts.test.sh
set -u

root="$(cd "$(dirname "$0")/.." && pwd)"
failures=0
failed_here=0

fail() {
    echo "    $1"
    failed_here=1
}

skills() {
    find "$root/plugins" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

kiro_section() {
    awk '/^\*\*Kiro\*\*/ { on = 1; next } /^(\*\*|## )/ { on = 0 } on' "$root/README.md"
}

every_skill_linked() {
    for name in $(skills); do
        link="$root/.kiro/skills/$name"
        if [ ! -L "$link" ]; then
            fail "not a symlink: .kiro/skills/$name"
            continue
        fi
        [ "$(readlink "$link")" = "../../plugins/$name/skills/$name" ] || fail "wrong target: $name"
        [ -f "$link/SKILL.md" ] || fail "no SKILL.md through: $name"
    done
}

no_stray_links() {
    [ -d "$root/.kiro/skills" ] || { fail "no .kiro/skills"; return; }
    for link in "$root"/.kiro/skills/*; do
        [ -d "$root/plugins/$(basename "$link")" ] || fail "no such plugin: $(basename "$link")"
    done
}

readme_installs_every_skill() {
    section="$(kiro_section)"
    [ -n "$section" ] || { fail "README has no Kiro section"; return; }
    for name in $(skills); do
        line="ln -s ~/AI-Tools/plugins/$name/skills/$name ~/.kiro/skills/$name"
        case "$section" in
            *"$line"*) ;;
            *) fail "no install line: $name" ;;
        esac
    done
}

readme_adding_step() {
    awk '/^## Adding a new skill/ { on = 1 } on' "$root/README.md" | grep -q '\.kiro/skills' ||
        fail "Adding a new skill does not name .kiro/skills"
}

skills_name_kiro_files() {
    grep -q 'AGENTS.md` for Codex and Kiro' "$root/plugins/sprints/skills/sprints/SKILL.md" ||
        fail "sprints does not say Kiro uses AGENTS.md"
    grep -q '~/.kiro/steering/' "$root/plugins/ship/skills/ship/SKILL.md" ||
        fail "ship does not name ~/.kiro/steering/"
}

for name in every_skill_linked no_stray_links readme_installs_every_skill readme_adding_step \
    skills_name_kiro_files; do
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
