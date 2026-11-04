---
max_turns: 25
allowed_tools: [Read, Glob, Grep, Bash, Write, Edit, Skill]
---

Use the cross-review skill to cross-review the commit before the last one (HEAD~1) with codex.

The only reviewer CLIs on this machine are `.tools/codex` and `.tools/claude` in this repo's root. Call them by their full paths in place of `codex` and `claude`, and ignore any others on your PATH.
