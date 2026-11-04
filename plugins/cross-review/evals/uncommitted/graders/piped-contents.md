---
type: llm
focus: trace
---
The commands piped into `claude -p` include the contents of the uncommitted edit to client.py: `git diff HEAD`, or `git diff <base>` with no second revision. Fail if the only git commands piped are `git diff <base> HEAD` (or another diff between two commits) and `git status`, because those show the file's name but not the uncommitted edit.
