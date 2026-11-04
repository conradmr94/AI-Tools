# Spec: Kiro support

- Status: Approved 2026-11-04
- Task: None. Owner asked on 2026-11-04 for Kiro to get the same folders and install steps as Claude and Codex, for every skill.
- Branch: `kiro-support`, cut from `origin/main`

## Goal

Every skill in this repo can be installed and used in Kiro, with install steps in the README and a `.kiro/skills/` folder like `.claude/skills/`. `cross-review` can also use Kiro as a reviewer, through `kiro-cli`.

## Scope

- Touches:
  - `.kiro/skills/<name>` — new: one relative symlink per skill, six in all.
  - `README.md` — Kiro in the intro, a Kiro install section, a step in "Adding a new skill", and the `cross-review` row.
  - `tests/hosts.test.sh` — new: plain shell tests that every skill is wired up for Kiro.
  - `plugins/sprints/skills/sprints/SKILL.md` — says which instructions file Kiro uses.
  - `plugins/ship/skills/ship/SKILL.md` — names `~/.kiro/steering/` among the user's instruction files.
  - `plugins/cross-review/skills/cross-review/SKILL.md` — Kiro as a third reviewer.
  - `plugins/cross-review/evals/` — a `kiro-cli` stub, new fixture variants and new cases.
  - Each changed plugin's `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json`, and `.claude-plugin/marketplace.json` — `cross-review` 1.1.0 with Kiro in its description, `sprints` 1.0.7, `ship` 1.0.3.
- Does not touch:
  - `export-tree.sh`: it already removes `.kiro`.
  - `explain-repo`, `explain-diff` and `spec`: nothing in them is tied to one agent.
  - `.agents/plugins/marketplace.json`: it holds Codex's plugin list and has no version field.
  - Kiro Power manifests (see Q1).
  - `SPEC-2026-11-03-cross-review.md` and `SPEC-2026-11-03-cross-review-isolation.md`: both are Done and frozen.

## What Kiro actually does

Checked on 2026-11-04 with `kiro-cli` 3.0.0, signed in:

- A skill in `.kiro/skills/` loads in `kiro-cli chat`, including through a relative symlink, and its bundled files can be read. `~/.kiro/skills/find-skills`, also a symlink, loads the same way.
- `kiro-cli powers install <folder>` reports success and copies the folder, but the skill never appeared in `kiro-cli chat`, and asking for it failed. Kiro's docs describe CLI support as "IDE-installed Powers". So Powers are not an install route here.
- Kiro has no marketplace command, so there is nothing like `claude plugin install`.
- `AGENTS.md` at the workspace root is read. Global rules live in `~/.kiro/steering/`, according to Kiro's docs.
- Crew reads skills from its own folder, `~/.kiro/crew/skills/`, according to Kiro's docs. Its GitHub import needs a public repo, and this one is private.

## Interfaces

Install, in the README, one line per skill as in the other sections:

```
git clone https://github.com/conradmr94/AI-Tools.git ~/AI-Tools
mkdir -p ~/.kiro/skills
ln -s ~/AI-Tools/plugins/<name>/skills/<name> ~/.kiro/skills/<name>
```

Updating is `git -C ~/AI-Tools pull`. The README also says custom Kiro agents load no skills unless they list them in `resources`.

In the repo: `.kiro/skills/<name>` -> `../../plugins/<name>/skills/<name>`.

`cross-review` gains a third reviewer, `kiro`, available when `kiro-cli` is installed and `kiro-cli whoami` succeeds. It runs in the same export, and the prompt goes on stdin with the diff, because a prompt given as an argument makes Kiro ignore stdin:

```
(cd "$export_dir" && { printf '%s\n\n' "$prompt"; cat "$diff"; } | kiro-cli chat --no-interactive --v3 --trust-tools=read_file,grep_search)
```

- For Kiro, the prompt's first line ends `It follows this prompt.` in place of `It is on standard input.`
- Never pass `--trust-workspace`, `--trust-all-tools`, or any other tool to `--trust-tools`.
- `--v3` is pinned because V2 is still the default.
- `--model <model>` works as it does for the others.
- Kiro's default model is `auto`, which can be a Claude model. The report says so, and when the user is running in Claude the skill mentions that naming another model gives a more independent check.
- The sandbox rule and "whichever you are running in" wording cover all three, and the same-kind note in the report applies to Kiro running inside Kiro.

## Behavior and proof

Written first and committed before the implementation. T1–T5 are plain shell tests and cost nothing. T6–T11 are evals using a `kiro-cli` stub, so no eval calls a real model. The 21 existing `cross-review` evals must stay green. Run: `bash tests/hosts.test.sh`, `bash plugins/cross-review/tests/export-tree.test.sh`, then, with `$OUT` a scratch directory outside the repo, `claude plugin eval plugins/cross-review --scaffold --runs 1 --judge-model sonnet --ablation none --no-publish --trust-plugin --allow-tools Bash Write Edit --concurrency 4 --output-dir $OUT --report $OUT/report.html`.

- **T1** Given every folder in `plugins/`, then `.kiro/skills/<name>` is a relative symlink that resolves to that skill's `SKILL.md`. Unit. `tests/hosts.test.sh` › `every_skill_linked`.
- **T2** Given every entry in `.kiro/skills/`, then it matches a folder in `plugins/`, so no link is left dangling. Unit. › `no_stray_links`.
- **T3** Given every folder in `plugins/`, then the README's Kiro section has its `ln -s` line. Unit. › `readme_installs_every_skill`.
- **T4** Given the README's "Adding a new skill", then it names `.kiro/skills`. Unit. › `readme_adding_step`.
- **T5** Given `sprints` and `ship`, then `sprints` says Kiro uses `AGENTS.md` and `ship` names `~/.kiro/steering/`. Unit. › `skills_name_kiro_files`.
- **T6** Given a signed-in Kiro, when asked to cross-review with Kiro, then the agent checks `whoami` and runs `kiro-cli chat` from the export with `--no-interactive`, `--v3`, exactly `--trust-tools=read_file,grep_search`, and no `--trust-workspace` or `--trust-all-tools`, and the findings are reported as confirmed or disputed. `evals/named-kiro`.
- **T7** Given all three reviewers can run and none is named, when asked for a cross-review, then the agent offers all three and runs none. `evals/asks-three`.
- **T8** Given Kiro is signed out, when asked to use it, then the agent says why it is unavailable, asks about the others, and runs nothing. `evals/kiro-signed-out`.
- **T9** Given a Kiro review exits with an error, then the agent quotes it, says what would fix it, and does not retry with another reviewer. `evals/kiro-fails`.
- **T10** Given a repo with planted agent config, when reviewed with Kiro, then the stub reports no planted config visible, the prompt and the diff both reach stdin, and the export is removed. `evals/isolated-kiro`.
- **T11** Given the user names a Kiro model, then the command has `--model <model>` and the report names it. `evals/kiro-model`.

Not covered by automated tests:

- The real `kiro-cli` as reviewer. Stubs prove the command, not what Kiro does. Checked by hand before finishing: run the skill's exact command against a planted repo, expecting the off-by-one found, no marker files and an unchanged tree.
- Running the skills inside Kiro. `claude plugin eval` only drives Claude. Checked by hand before finishing: follow the README steps in a throwaway copy, confirm all six skills are listed by `kiro-cli chat`, and run `explain-diff` on a real change. Linking into the real `~/.kiro/skills` is left to Owner.
- `ship` and `sprints` writing to the repo from inside Kiro. Kiro asks for or refuses tools differently, and `--no-interactive` can't show that. Left to Owner as a manual step in an interactive session.
- The Kiro IDE. It is not installed here. Its docs say it shares `~/.kiro/skills`, so the same steps should work. Left to Owner.
- Crew. Checked by hand during S2 (see Q2): link a skill into `~/.kiro/crew/skills/` and confirm Crew lists it.

## Slices

One commit each, on the branch above, in this order. Budget: about 300 changed lines per slice, not counting lockfiles, generated files or snapshots. Each is ticked with its commit once it lands.

- [ ] **S1a Host tests** — this spec and T1–T5. All fail because nothing is wired up yet.
- [ ] **S1b Kiro eval cases** — the `kiro-cli` stub, fixture variants and T6–T11. All red; the existing 21 stay green.
- [ ] **S2 Skills install in Kiro** — `.kiro/skills/`, the README, and the `sprints` and `ship` wording and versions. Turns T1–T5 green.
- [ ] **S3 Kiro as a reviewer** — the `cross-review` skill, its version, description and README row. Turns T6–T11 green; the existing 21 stay green.

## Open questions

All resolved by Owner on 2026-11-04 in chat, as recommended:

- **Q1** No Kiro Power manifests: they did nothing in the CLI, the IDE can't be tested here, and `~/.kiro/skills` already covers the IDE according to its docs. A root `plugin.json` passed `claude plugin validate`, so they can be added later.
- **Q2** Install Crew with `kiro-cli crew` and test it during S2, then add a README line linking skills into `~/.kiro/crew/skills/` only if it works. Crew stays out as a reviewer: it has no documented one-shot command.

## Deviations

- **The login check is `kiro-cli whoami` succeeding, not a non-null `account` in its JSON.** Signed-in JSON has no `account` key, so the approved check would have called a signed-in user signed out. It exits 0 signed in and 1 signed out, the same as the other two reviewers' checks. Behavior is what was approved; the spec's line is corrected. Shown to Owner at approval 2.
