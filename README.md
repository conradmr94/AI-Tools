# AI-Tools 🛠️

My personal grab bag of [Claude Code](https://claude.com/claude-code) skills — a living collection that grows whenever I build or find something worth keeping around.

## What's in here

| Skill | What it does |
|---|---|
| [`explain-repo`](.claude/skills/explain-repo/SKILL.md) | Turns any codebase into two browsable HTML docs — how the product works, how the code works — so nobody has to spend 45 minutes grepping around to get oriented. |

More to come as I need them.

## Installing

This repo doubles as a Claude Code plugin marketplace. Grab a skill with:

```bash
claude plugin marketplace add conradmr94/AI-Tools
claude plugin install explain-repo@ai-tools
```

(Repo's currently private — ping me for access.)

## Adding a new skill

1. Drop it in `.claude/skills/<name>/SKILL.md`.
2. Add it to `.claude-plugin/plugin.json`'s `skills` array (or give it its own plugin entry in `.claude-plugin/marketplace.json` if it deserves to stand alone).
3. Update the table above.

No PR template, no ceremony — just useful skills, kept sharp.
