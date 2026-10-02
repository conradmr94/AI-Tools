# AI-Tools 🛠️

My personal grab bag of [Claude Code](https://claude.com/claude-code) and [Codex](https://developers.openai.com/codex) skills — a living collection that grows whenever I build or find something worth keeping around.

## What's in here

| Skill | What it does |
|---|---|
| [`explain-repo`](plugins/explain-repo/skills/explain-repo/SKILL.md) | Turns any codebase into two browsable HTML docs — how the product works, how the code works — so nobody has to spend 45 minutes grepping around to get oriented. |
| [`sprints`](plugins/sprints/skills/sprints/SKILL.md) | Sprint planning records in `docs/sprints/` — open and close sprints ad hoc, track tasks with a dated status trail, sort engineering tasks into waves that can run in parallel across multiple agents, log decisions, and write retrospectives. Checks the open sprint before dev work and updates it as tasks finish. |

More to come as I need them.

## Installing

This repo doubles as a plugin marketplace for both Claude Code and Codex. Each skill is its own plugin, so install only the ones you want.

**Claude Code**

```bash
claude plugin marketplace add conradmr94/AI-Tools
claude plugin install explain-repo@ai-tools
claude plugin install sprints@ai-tools
```

**Codex**

```bash
codex plugin marketplace add conradmr94/AI-Tools
codex plugin add explain-repo@ai-tools
codex plugin add sprints@ai-tools
```

(Repo's currently private — ping me for access.)

## Adding a new skill

1. Drop it in `plugins/<name>/skills/<name>/SKILL.md`. Use real files, not symlinks: Codex skips symlinks when it installs a plugin.
2. Symlink it into `.claude/skills/` so it also loads while working in this repo: `ln -s ../../plugins/<name>/skills/<name> .claude/skills/<name>`.
3. Add a Claude Code entry to `.claude-plugin/marketplace.json` (`"source": "./plugins/<name>"`, `"strict": false`, `"skills": ["./skills/<name>"]`).
4. Add a Codex manifest at `plugins/<name>/.codex-plugin/plugin.json` (`"skills": "./skills"`) and an entry in `.agents/plugins/marketplace.json`.
5. Update the table above.

No PR template, no ceremony — just useful skills, kept sharp.
