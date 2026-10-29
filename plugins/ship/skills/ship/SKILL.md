---
name: ship
description: Take a finished feature branch to an open pull request - check it is ready (feature branch, clean tree, spec slices ticked, tests passing, not behind its remote), write the PR title and description from the spec and commits, push the branch and open the PR with gh. Never merges, force-pushes or pushes the default branch; when the work is not ready it says why and stops. Use when the user says "ship this", "ship it", "open a PR", "open a pull request", "make a PR for this branch" or "send this for review".
---

# Ship

Take the current branch from "the work is done" to an open pull request the user can review. Ship always works on the current branch. It checks, writes, pushes and opens, in that order, and stops at the first check that fails.

Ship never merges a pull request or a branch, never force-pushes (`--force`, `--force-with-lease`, `-f`), and never pushes the default branch. The user merges.

If `git` or `gh` fails for a reason outside the repo (a sandbox blocking the system `/usr/bin/git` stub, for example), look for another install on the machine (`which -a git`, `/opt/homebrew/bin/git`, `/usr/local/bin/git`) and use that for every command before deciding you can't ship. Say in the report which binary you used.

## 1. Ready checks

Run these in order. At the first one that fails, stop: say which check failed and what you found, and offer the fix, but do not make it yourself. Do not push or open anything.

1. **On a feature branch.** Find the default branch (`origin/HEAD` if set, else `main`, else `master`). If the current branch is the default branch, say that shipping needs a feature branch and offer to create one from the current commits. Never push the default branch to ship.
2. **Nothing uncommitted.** `git status --short` must be empty. If not, name each file and ask what to do with it: commit it as part of this change, leave it out, or discard it. Do not commit, stash, discard or restore anything yourself.
3. **The spec is finished.** If a `SPEC-*.md` in `docs/specs/` (or `docs/specs/tasks/`) names this branch on its `Branch:` line, every slice in its Slices list must be ticked. If not, name the unticked slices.
4. **Tests pass.** Run the spec's `Run:` command, if there is a spec, and the project's documented test command: the one named in `CLAUDE.md`, `AGENTS.md` or `README.md`, or a `test` script in the package manifest. Never guess a command that is not written down; if there is none, say so in the report. If any test fails, name each failing test (the spec's test id too, when it has one).
5. **Not behind the remote.** If the branch already exists on `origin`, fetch it; if the remote has commits the local branch lacks, stop and say so. Never overwrite them.

If the user tells you to ship despite a failed check, go on, open the PR as a draft (`--draft`), and state the failed check at the top of its body.

## 2. The PR text

Write a short title and a body (see "The PR body"). Follow the user's rules for commits and pull requests in their agent instruction files (`~/.claude/CLAUDE.md`, the project's `CLAUDE.md` or `AGENTS.md`). Pass the body to `gh` on standard input (`--body-file -` with a quoted heredoc), not through a file, so nothing new appears in the working tree and no temp directory is needed.

## 3. Push

`git push -u origin <branch>`. Nothing else: no force flag, no other refspec, never the default branch. If the push is rejected or fails, stop and report the error, with the title and body ready to paste (see "Report"); do not retry with force.

## 4. Open the pull request

- If the branch has no open PR, run:

  ```
  gh pr create --base <default branch> --head <branch> --title "<title>" --body-file - <<'EOF'
  <body>
  EOF
  ```

- If it already has one (`gh pr view <branch>` succeeds), replace its body with `gh pr edit <branch> --body-file -` and the same heredoc, instead of opening a second.
- Always try `gh` first; do not decide in advance that it will fail. If the command fails (`gh` missing, not logged in, the remote not on GitHub), say why in one line and give the user the title and body ready to paste, in a fenced block.

## 5. Report

Reply with:

- the PR link; or, if the push or `gh` failed, the reason in one line and then the title and body in a fenced block, ready to paste once the problem is fixed, so the write-up is never lost
- each check and its result, naming the test commands you ran
- anything left for the user: manual checks from the spec's "Not covered", a draft to mark ready, an uncommitted file they chose to keep out
- when the repo has explain-repo docs (`docs/architecture/`, `docs/product/` or `docs/data-model/` with a `data/doc.js`): how far behind they are, as the number of commits since each doc's `revision` that change files outside the docs (`git log --oneline <revision>..HEAD -- . ':!docs/architecture' ':!docs/product' ':!docs/data-model' ':!docs/viewer'`), and a suggestion to refresh them with explain-repo once this PR is merged. Leave it out when they are up to date. This is a note, never a failed check.

Do not wait for, poll or watch CI after opening the PR.

## The PR body

Keep it short: a reviewer should get the change from it in a minute. Start from what the spec and the commits say, not from a fresh reading of the code. Use these sections, in this order, as `##` headings, and leave out any that would be empty:

- **What** — what the change does, in a few plain sentences: from the spec's Goal when there is a spec, otherwise from the commits.
- **Why** — the reason, from the spec, its task or the commit messages. One or two sentences.
- **Tests** — the commands you ran in the ready checks and their results. With a spec, list every spec test id with its sentence shortened and its result (`- **T1** third call in a second is refused: pass`). Then the spec's "Not covered" items, as what the reviewer should check by hand. Without a spec, name the project's test command and its result.
- **Deviations** — the spec's Deviations section, one line each, plus any changed file the spec's `Touches:` does not cover. Leave out without a spec.
- **Commits** — one line per commit on the branch, oldest first: short hash, subject, and what it changed and why in one sentence. For a sprint task, link the task's entries in the sprint log instead, since they already say this.
- **Merging** — open PRs that change any of the same files (`gh pr list --json number,title,files`), so the reviewer expects the conflict. Leave out when there are none or `gh` cannot tell.

Never add AI attribution: no "Generated with Claude Code" line, no `Co-Authored-By` trailer for an AI, no mention of which agent wrote it. The user's own rules about PR descriptions come first.

The title is the change in a few words, in the imperative, like a good commit subject: `Rate-limit the API client`.
