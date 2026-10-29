---
name: explain-diff
description: Walk the user through a code change as a short guided read in chat - what it does, the lines worth reading in order, what to skim, and the decisions in it that nobody asked for - so they understand it without reading the whole diff cold. Works on the current branch, uncommitted work, a commit, a range, another branch, or one slice of a spec. Use when the user asks to explain, walk through or summarize a diff, branch, commit, PR or change, asks "what changed?" or "what did you do?", or wants to understand a change before merging it. Read-only; writes no files.
---

# explain-diff

Turn a change into a short read that lets the user understand it without going through the whole diff line by line. The reply is the product: it lives in chat and is never saved to a file.

This skill only reads. Do not write, edit or create files, and run only git commands that read (`diff`, `log`, `show`, `status`, `merge-base`, `rev-parse`, `symbolic-ref`, `ls-files`). Never check out, stash, reset, commit or otherwise change the repo to look at a change: read other revisions with `git show <rev>:<path>`. The one other command it runs is a matching spec's test command (see "Against the spec").

## Picking the change

The user names the change in words or as `/explain-diff [target]`:

- **Nothing:** the current branch against its merge-base with the default branch, plus uncommitted and untracked work. The default branch is `origin/HEAD` if set, else `main`, else `master`. On the default branch itself, it is just the uncommitted work.
- **A commit:** that commit against its parent.
- **A range** `A..B`: exactly that range.
- **A branch:** that branch against its merge-base with the default branch.
- **`S<n>`:** that slice of the spec in `docs/specs/` that matches the current branch. Its tick in the spec's Slices list names its commit. If the slice is not ticked yet, say it has not landed and stop.

Name the change you compared at the end of *In short* (see "The reply"), never as a preamble.

## Reading the change

1. Get the shape: `git log --oneline <base>..<target>`, `git diff -M --stat <base> <target>` (plus `git diff -M --stat HEAD` and `git status --short` for uncommitted and untracked work).
2. Sort the files into **signal** (behavior a reader must understand) and **noise**: lockfiles, generated or vendored files, snapshots, pure renames and moves (a rename with an import fix is still a rename), formatting-only and whitespace-only edits, and mechanical updates that follow from another change, such as call sites adjusted to a new signature.
3. Read the full diff of every signal file, and enough of the surrounding code to know what each hunk does. Read noise files only far enough to confirm they are noise.

**Nothing changed:** if the change is empty, say there is nothing to explain, name the base and target you compared, and stop. Never describe existing code as if it were part of a change.

**A large change:** count meaningful lines as the lines added and removed in signal files. Over about 300, the reply's very first line, before *In short*, says so: how big it is, how many commits, and an offer to go through it commit by commit (or slice by slice, when it has a spec). Then give only *In short* and one line per commit, each a single sentence of at most about 20 words, and stop. Do the full walkthrough only if the user asks for the whole change at once.

## The reply

In this order, under these headings. Leave out a section that has nothing in it. The reply starts with the *In short* heading (or, for a large change, the one-line size warning): no preamble before it, and no notes about tools, the shell or the environment unless they stopped you reading part of the change.

### In short

Two to four plain sentences, never more: count them before replying. Say what the change does and why, in terms of behavior, not files. The first sentence is the main change; the rest cover only the side effects that matter most. Anything else goes in the sections below. Someone who reads only this knows what the change is. Join related facts into one sentence rather than adding another, as in this three-sentence example:

```
`ApiClient` now rate-limits itself: every `get` takes a token from a token-bucket `RateLimiter` and raises `RateLimited` at once when none is left. The same commit gives every request a fixed 30-second timeout and turns any transport error into `None`. A separate commit renames `utils.py` to `urls.py`.
```
 End with one short line naming what was compared: `Compared: rate-limit vs main, 2 commits, no uncommitted work.`

### Read these

The lines that matter, in reading order, at most about seven entries. Each is `path:start-end` (line numbers in the new version of the file) and a single sentence of at most about 20 words on what it is and why it matters. Never a second sentence: detail beyond that belongs in the code the entry points to, or in *Decisions*:

```
1. `ratelimit.py:8-24` — the token bucket, where `acquire` holds the whole rate rule.
2. `client.py:15-20` — every request now takes a token before calling the transport.
```

Write the entry as one sentence after the dash, as above. A label followed by a full stop and a second sentence ("the token bucket. `acquire` refills…") is two sentences.

Order for understanding, not by file name: start where the new behavior is decided, then the code it calls, then where it is wired in, then the tests that prove it. Check every line range against the file before giving it.

### Skim or skip

The noise, grouped, one line per group, with enough to trust it is noise: `requirements.lock — 40 hash lines regenerated; no version changes.` or `utils.py → urls.py — renamed; contents unchanged, two imports updated.`

### Against the spec

Only when the change has a spec: a `SPEC-*.md` in `docs/specs/` (or `docs/specs/tasks/`) whose `Branch:` line names the branch being explained, or the spec an `S<n>` target came from. Read the spec at the target revision, then report:

- **Tests:** run the spec's `Run:` command once, unless the user said not to, and give each spec test id with `pass`, `fail` or `not run`, matched by the test name the spec gives it. If the command fails to start, mark them all `not run` and say why in one line. Do not fix failing tests or code; report them.
- **Outside the scope:** every changed file that the spec's `Touches:` does not cover (a directory covers what is inside it), and any changed file its `Does not touch:` names.
- **Interfaces:** every signature, route, type or config key in the change that differs from the spec's Interfaces section, giving both: ``spec: `RateLimiter(max_per_second: int)`; code: `RateLimiter(rate, burst, clock)`.``
- **Unrecorded departures:** which of the above the spec's Deviations section already records, and which it does not. Only the unrecorded ones need the user's attention, so say so plainly.

If the change has no spec, leave this section out.

### Decisions you didn't ask for

Choices the change makes that nothing the user asked for decided. Compare against what you know of the request: this conversation, the commit messages and any task or spec the change belongs to. Look for:

- hard-coded values and defaults (timeouts, limits, sizes, retry counts): give the line where the value is defined, plus where it is used if that is elsewhere
- error handling that hides, swallows or reshapes failures
- new dependencies, or new uses of the network, filesystem or clock
- changed signatures or behavior that existing callers will notice
- removed checks, validation or tests
- anything security- or data-sensitive

Each entry gives the location, what the code does, and what it means for the user: ``client.py:18 — `except Exception: return None` turns every transport error into a `None` result, so callers can no longer tell "not found" from "network down".`` If there are none, leave the section out; do not invent concerns.

### Check your understanding

Two to four questions about what the change does, the kind a reviewer should be able to answer after reading it: what happens in an edge case, why a choice was made, what a caller now has to do differently. Put each answer in a collapsed block:

```
1. What does `ApiClient.get` return when the transport raises?
   <details><summary>Answer</summary>`None`: `client.py:18` catches every exception, so callers can't tell a failure from an empty result.</details>
```

These are for the reader's own benefit. Never say that merging, approving or carrying on depends on answering them, and do not ask the user to answer. Leave the section out of the short reply for a large change.

## Style

- Say what the code does in plain words. Do not paste the diff back; quote a line only when the line itself is the point.
- Be specific: names of functions, routes, files and values, never "updated some logic".
- Keep the whole reply short enough to read in a couple of minutes. The point is that the user does not have to read the diff, not that they read a second, longer version of it.
