# AI-Tools 🛠️

My personal grab bag of [Claude Code](https://claude.com/claude-code) skills — a living collection that grows whenever I build or find something worth keeping around.

## What's in here

| Skill | What it does |
|---|---|
| [`explain-repo`](.claude/skills/explain-repo/SKILL.md) | Turns any codebase into two browsable HTML docs — how the product works, how the code works — so nobody has to spend 45 minutes grepping around to get oriented. |
| [`sprints`](.claude/skills/sprints/SKILL.md) | Sprint planning records in `docs/sprints/` — open and close sprints ad hoc, track tasks with a dated status trail, sort engineering tasks into waves that can run in parallel across multiple agents, log decisions, and write retrospectives. Checks the open sprint before dev work and updates it as tasks finish. |

More to come as I need them.

## Installing

This repo doubles as a Claude Code plugin marketplace. Grab a skill with:

```bash
claude plugin marketplace add conradmr94/AI-Tools
claude plugin install explain-repo@ai-tools
claude plugin install sprints@ai-tools
```

Each skill is its own plugin, so install only the ones you want.

(Repo's currently private — ping me for access.)

## Adding a new skill

1. Drop it in `.claude/skills/<name>/SKILL.md`.
2. Give it its own plugin entry in `.claude-plugin/marketplace.json` (`"source": "./"`, `"strict": false`, `"skills": ["./.claude/skills/<name>"]`) so it installs on its own.
3. Update the table above.

No PR template, no ceremony — just useful skills, kept sharp.
