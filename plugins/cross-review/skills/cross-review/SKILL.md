---
name: cross-review
description: Get a code change reviewed by a separate agent on this computer - the user picks Claude or Codex, it runs headless and read-only, and the findings come back in chat. Works on the current branch, uncommitted work, a commit, a range, another branch or one slice of a spec. Changes nothing in the repo. Use when the user asks for a cross-review or a second opinion on a change, asks for another agent to look at their work, or asks to have Codex or Claude review a diff, branch or commit.
---

# Cross-review

Get a change reviewed by a separate agent: a new headless run of Claude or Codex that has no memory of writing it. The user picks the reviewer. The reply is the product: it lives in chat and is never saved to a file.

This skill changes nothing in the repo. Do not fix findings unless the user asks afterwards. Never review the change yourself in place of the reviewer, even when no reviewer can run or the reviewer fails.

## 1. Pick the change

The user names the change in words or as `/cross-review [target] [reviewer]`:

- **Nothing:** the current branch against its merge-base with the default branch, plus uncommitted and untracked work. The default branch is `origin/HEAD` if set, else `main`, else `master`. On the default branch itself, it is just the uncommitted work.
- **A commit:** that commit against its parent.
- **A range** `A..B`: exactly that range.
- **A branch:** that branch against its merge-base with the default branch.
- **`S<n>`:** that slice of the spec in `docs/specs/` that matches the current branch. Its tick in the spec's Slices list names its commit. If the slice is not ticked yet, say it has not landed and stop.

If the change is empty, say there is nothing to review, name what you compared, and stop.

## 2. Pick the reviewer

Find out which reviewers can run: `codex` is available if it is installed and `codex login status` succeeds, and `claude` if it is installed and `claude auth status` succeeds.

- **The user named a reviewer that can run:** use it, without asking.
- **The user named none, and both can run:** ask which to use, offering both, and wait. Do not recommend one by guessing who wrote the change. Whichever you are running in can review too: it is a fresh session, with no memory of the work.
- **Only one can run, or the named one cannot:** say which is unavailable and why, ask whether to use the one that can, and wait.
- **Neither can run:** say so and stop.

Ask this each run; do not carry an answer over from an earlier review.

## 3. Run it

Write the prompt, filling in the exact read-only git commands that show the change (such as `git diff <base> <target>`, plus `git diff HEAD` and `git status --short` for uncommitted and untracked work):

```
Review this code change for correctness bugs. See it with: <git commands>. Read the surrounding code as you need to.
Do not change, create or delete anything.
Reply with one line per finding, as `file:line (high|medium|low) reason`, or exactly `no findings`.
```

If a `SPEC-*.md` in `docs/specs/` (or `docs/specs/tasks/`) names the current branch on its `Branch:` line, add: `The spec for this change is <path>. Also report where the change does not do what the spec says.`

Run one of these from the repo root, with a timeout of ten minutes. If the user named a model, add `--model <model>`.

```
codex exec -s read-only --ephemeral -o "$(mktemp)" "<prompt>" </dev/null
claude -p "<prompt>" --permission-mode dontAsk --allowedTools "Read,Grep,Glob,Bash(git show:*),Bash(git diff:*),Bash(git log:*),Bash(git status:*)" --disallowedTools "Edit,Write" </dev/null
```

Use exactly these read-only flags; never loosen them. Keep `-o` pointing outside the repo. Run the review once.

If you are running inside Codex's sandbox and `claude` cannot reach the network, ask for Codex's normal approval to run that one command outside the sandbox. If that is refused, say so and stop.

**If the reviewer fails:** quote its error, say what would fix it, and stop. A rejected model, for example, is fixed by naming another in the request or correcting the user's config. Do not retry with another model or reviewer unless the user asks, and do not edit any config.

## 4. Report

Start with who reviewed what, then give the findings in the reviewer's words. If the reviewer found nothing, say so in one line.

```
**Reviewed by** <reviewer and model, if known> · <what was compared>
```

When the reviewer is the same kind of agent as the one running this skill, add a line under that saying it was a fresh session but a weaker check than a different model.
