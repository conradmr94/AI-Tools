---
type: llm
focus: trace
---
Find the pull request body the agent wrote: the body passed to `gh pr create` or `gh pr edit` (directly or through a file it wrote), or, if `gh` failed, the body it gave the user to paste. That body has: (1) a What section saying the change rate-limits the API client; (2) a Tests section listing spec tests T1 and T2, each with a result such as pass; (3) a Deviations section mentioning that RateLimiter also takes a burst size; (4) a Commits section with one line for each of the two commits ("Add rate limiter tests" and "Rate-limit the API client"). The body contains no AI attribution, such as "Generated with Claude Code" or a "Co-Authored-By: Claude" line.
