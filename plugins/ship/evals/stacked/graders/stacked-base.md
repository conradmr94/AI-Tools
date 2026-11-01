---
type: llm
focus: trace
---
The `rate-limit` branch was cut from `retry`, a branch on origin that is not merged into main. Look at the agent's `gh pr create` call, or, if `gh` failed, at the PR title and body it gave the user to paste. All of these must hold:

(a) The PR's base is `retry`, not `main`: `gh pr create` ran with `--base retry`, or the reply tells the user to open the PR against `retry`.

(b) The PR body lists only `rate-limit`'s own two commits ("Add rate limiter tests", "Rate-limit the API client") under Commits, not "Add a retry helper".

(c) The body or the final reply says the branch is stacked on `retry` and that `retry` must be merged first.

Fail if any of these doesn't hold.
