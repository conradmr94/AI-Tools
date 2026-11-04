---
type: llm
focus: trace
---
The diff given to `claude -p` on standard input includes the contents of the uncommitted edit to client.py: `git diff HEAD`, or `git diff <base>` with no second revision. Fail if the only git commands used to build it are `git diff <base> HEAD` (or another diff between two commits) and `git status`, because those show the file's name but not the uncommitted edit.
