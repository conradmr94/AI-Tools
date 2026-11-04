# Spec: cross-review isolation

- Status: Approved 2026-11-03
- Task: None. Follows hand checks on 2026-11-03, which found a repo's own agent config runs during a review.
- Branch: `cross-review-isolation`, cut from `origin/main`

## Goal

A reviewer never runs inside the repo under review. It runs in a temporary export with agent config and symlinks removed, so nothing a repo ships can start during a review. The hint from `9fbd646`, which missed the merge of PR #11, also lands.

## Scope

- Touches:
  - `plugins/cross-review/skills/cross-review/scripts/export-tree.sh` — new: builds the export.
  - `plugins/cross-review/skills/cross-review/SKILL.md` — uses the export, sends both reviewers the diff on stdin, new reviewer commands, the hint.
  - `plugins/cross-review/tests/export-tree.test.sh` — new: plain shell tests for the script.
  - `plugins/cross-review/evals/` — new cases, and harness changes to existing ones (see Slices).
  - `plugins/cross-review/.claude-plugin/plugin.json`, `plugins/cross-review/.codex-plugin/plugin.json`, `.claude-plugin/marketplace.json` — version 1.0.1. `.agents/plugins/marketplace.json` has no version field.
- Does not touch: Kiro support, which is the next spec and reuses this export. `SPEC-2026-11-03-cross-review.md` is Done and stays frozen. User-level config stays as it is.

## Interfaces

```
scripts/export-tree.sh <rev>         # exports that revision
scripts/export-tree.sh --worktree    # exports tracked and untracked files as they are now
```

It prints the export's path on stdout and nothing else. On failure it prints an error on stderr, exits non-zero and leaves no temp directory. The export has no `.git`, no symlinks, and no `.claude`, `.codex`, `.kiro`, `.agents` or `.mcp.json` at any depth, in any letter case, since macOS treats `.Claude` as `.claude`. Ignored files are left out. An argument that is not a real revision, such as `--output=x`, is refused.

Skill step 3 becomes, from the repo root:

1. Work out the git commands for the change, and run them there, writing the diff to a temp file outside the repo.
2. Build the export: `--worktree` when the change includes uncommitted or untracked work, otherwise the target revision.
3. `cd` into the export and run the reviewer, with the diff on stdin:

```
codex exec --skip-git-repo-check -s read-only --ephemeral -o "$(mktemp)" "$prompt" < "$diff"
claude -p "$prompt" --strict-mcp-config --permission-mode dontAsk --allowedTools "Read,Grep,Glob" --disallowedTools "Edit,Write,Bash,NotebookEdit,Agent" < "$diff"
```

4. Remove the export and the diff file. The tree check still runs against the real repo.

The prompt says the change is on standard input for both reviewers, and that the current directory holds the code as of that change, so the warning that the working tree may differ goes. Findings are still `file:line`, relative to the same root. Step 5 is unchanged and reads the real repo or `git show`.

When a model is rejected, the skill suggests updating the CLI first (from `9fbd646`).

## Behavior and proof

Written first and committed before the implementation. T1–T7 are plain shell tests and cost nothing. T8–T11 are evals, with the stub reviewers extended to report whether planted config is visible from where they were run. The original 17 evals must stay green. Run: `bash plugins/cross-review/tests/export-tree.test.sh`, then, with `$OUT` a scratch directory outside the repo, `claude plugin eval plugins/cross-review --scaffold --runs 1 --judge-model sonnet --ablation none --no-publish --trust-plugin --allow-tools Bash Write Edit --concurrency 4 --output-dir $OUT --report $OUT/report.html`.

- **T1** Given a commit and different code in the working tree, when exported by revision, then the export holds that commit's contents. Unit. `tests/export-tree.test.sh` › `exports_revision`.
- **T2** Given a modified file, a new file, a deleted file and an ignored file, when exported with `--worktree`, then the modified and new files are present as they are now, and the deleted and ignored files are absent. Unit. › `exports_worktree`.
- **T3** Given `.claude`, `.Claude`, `.codex`, `.kiro`, `.agents` and `.mcp.json` at the root and in a subfolder, when exported either way, then none remain and other files do. Unit. › `strips_agent_config`.
- **T4** Given a symlink to a file outside the repo, when exported either way, then the export has no symlinks. Unit. › `strips_symlinks`.
- **T5** Given any export, then it has no `.git`. Unit. › `has_no_git_dir`.
- **T6** Given a revision that does not exist, when exported, then it exits non-zero, prints nothing on stdout and leaves no temp directory. Unit. › `bad_revision_fails_clean`.
- **T7** Given the argument `--output=x`, when exported, then it is refused and no file `x` is created. A file name with a space exports correctly. Unit. › `refuses_options_and_handles_spaces`.
- **T8** Given a repo with planted agent config, when reviewed with Codex, then the agent runs `export-tree.sh`, the stub reports no planted config visible, the command has `--skip-git-repo-check` and stdin, and the export is removed. `evals/isolated-codex`.
- **T9** Given the same repo, when reviewed with Claude, then the stub reports no planted config visible and the command has `--strict-mcp-config`. `evals/isolated-claude`.
- **T10** Given uncommitted work, when reviewed, then the export is built with `--worktree`. `evals/export-worktree`.
- **T11** Given a named commit, when reviewed, then the export is built from that commit. `evals/export-revision`.

Not covered by automated tests:

- Real CLIs against planted config. Stubs prove where the reviewer ran, not what a real CLI loads. Checked by hand before finishing: run each reviewer with the skill's exact commands against the planted repo, expecting no marker files, and confirm each still finds the fixture's off-by-one.
- Codex in a folder the user has marked trusted. The export is a new temp path, so it is never trusted. Not tested directly.
- User-level hooks and config still apply. Accepted risk: they are the user's own.
- `CLAUDE.md` and `AGENTS.md` stay in the export, and can try to steer the reviewer, but cannot run anything. Accepted risk: findings are checked against the code (see Q2).
- `export-ignore` in `.gitattributes` can hide a file from a revision export. Accepted risk: the diff still shows every change.

## Slices

One commit each, on the branch above, in this order. Budget: about 300 changed lines per slice, not counting lockfiles, generated files or snapshots. Each is ticked with its commit once it lands.

- [x] **S1a Shell tests** — this spec and T1–T7. Each fails because the script does not exist. Landed in `c3ef60c`; all red.
- [x] **S1b Eval harness and cases** — T8–T11, a `planted` fixture variant, and stubs that report what they can see. Harness changes to approved tests: prompts give stub paths from the repo root so they work after `cd`, and reviewer-command patterns accept a quoted or variable path. T2 and T14 change to match the new commands: Codex gets `--skip-git-repo-check`, and the diff arrives by redirect or pipe. No expected behavior weakens. Landed in `b2e5eb9`; T8–T11 red, the original 17 green.
- [ ] **S2 Export script** — `export-tree.sh`. Turns T1–T7 green.
- [ ] **S3 Reviewers run in the export** — the skill's new step 3, the hint from `9fbd646`, and the version bump. Turns T8–T11 green; the original 17 stay green.

## Open questions

All resolved by Owner on 2026-11-03 in chat, as recommended:

- **Q1** The export is a bundled script, so it runs the same way every time and has real tests.
- **Q2** `CLAUDE.md` and `AGENTS.md` stay in the export: they cannot run code and they help the reviewer.

## Deviations

None.
