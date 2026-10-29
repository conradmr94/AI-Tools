---
name: spec
description: Short task specs in docs/specs/ that fix what a code change will do, how it is proven (tests written and approved before any implementation), and the small commits it lands in, so the user can follow every change. Use when the user asks to spec, scope or plan a change or task, says "write a spec", or picks up a sprint engineering task. Also use without being asked - before starting a change likely to need more than one small commit, offer to write a spec first; while working from an approved spec, follow its slices, keep its tests fixed, tick each slice with its commit and record deviations in it.
---

# Spec

A spec is a short record, written before any code, that says what one change will do, how it will be proven to work, and the order of small commits it lands in. Its purpose is that the user understands every change that reaches their code: they agree on the shape before it is built, they approve the tests that define "working" before the code exists, and each commit is small enough to read.

A project keeps one markdown file per spec in `docs/specs/`, named by the date it was written and a short slug: `SPEC-YYYY-MM-DD-<slug>.md`, with `# Spec: <short title>` as its title. Start it from [spec-template.md](spec-template.md). If the project already uses `docs/specs/` for another kind of document (design or package specs, for example), put task specs in `docs/specs/tasks/` instead and tell the user once.

A spec covers one task and one branch. It decides only how that task is built. Product and architecture decisions it relies on stay in the project's owning documents, and the spec links to them.

## When a spec is needed

- **Write one** when the change is likely to need more than one slice (see "Slices"), touches more than a few files, adds or changes an interface, or comes from a sprint engineering task. If the user has not asked, offer it in one line and wait.
- **Skip the file** for a small change (one slice, no interface change): state the tests in chat in the same Given/when/then form, write them first, show them, then make the change. Tests first still applies.
- **Never** let a spec block urgent work the user wants done now. If they say to skip it, skip it.

## Writing the spec

1. **Read first.** Read the task and its owning documents, the project's agent instructions, any `docs/architecture/` or `docs/product/` documents, and the code the change will touch. Work out the scope from the code, not a guess.
2. **Goal.** One or two sentences saying what is true afterwards that is not true now.
3. **Scope.** `Touches:` lists every file or directory the change will edit, each with what changes there. `Does not touch:` names what a reader might expect it to edit and why it stays as it is. Count shared resources: lockfiles, migrations, schema and generated files, shared config, fixtures.
4. **Interfaces.** Every new or changed function, route, type, data shape or config key, written as a signature, so the user sees the contract without reading the code. Write "None. Internal change only." when that is true.
5. **Behavior and proof.** The test list. Each test gets an id (`T1`, `T2`, …), one Given/when/then sentence in plain language with the concrete expected result, its kind (unit, integration, end-to-end), and the file and test name it will have. Cover the main path, each error or refusal case the change introduces, and each edge case a reviewer would ask about. Then list what is **not covered** by an automated test, why, and how it is checked instead, such as a manual step with what to look for. Give the command that runs the tests.
6. **Slices.** The ordered commits (see "Slices"). S1 is always the tests.
7. **Open questions.** Only choices the user must make, each with options and a recommendation. Do not ask what the code or the owning documents already answer.

Keep it short. A spec the user will not read has failed. Prefer one line per item, and leave out anything that is the same for every change.

## The two approvals

The work stops twice for the user, and only twice unless something goes wrong (see "When to stop").

**Approval 1: the spec.** Show the user, in a few lines each: the goal, the scope, the interfaces, every test (id and sentence), what is not covered, the slices, and the open questions. Wait. Update the spec until they approve it, then set `Status: Approved YYYY-MM-DD`. Do not write tests or code before this.

**Approval 2: the tests.** Write S1: the tests exactly as listed, and nothing else. Run them. Each must fail because the behavior does not exist yet (a missing function, a wrong result), not because the test itself is broken (a typo, a bad import of something that already exists, a setup error). A test that already passes means the behavior already exists or the test checks nothing: fix the test or the spec before going on. Then show the user each test id with its test name, the reason it fails, and the test diff. Wait for their OK. Then commit the spec and the tests together as S1.

If the user changes a test at this point, update the test's sentence in the spec in the same edit, so the spec and the tests never disagree.

## Slices

- A slice is one commit, or a few commits for the same step, on the spec's branch. The work does not make a branch per slice. Use the branch the task is already on; if there is none, or the current branch is the default branch, create one for the spec.
- Each slice has one purpose, says which tests it turns green, and stays within about 300 changed lines, not counting lockfiles, generated files or snapshots. Order slices so each one makes sense on its own and the most foundational lands first: a refactor with no behavior change, then new interfaces, then the implementation, then the wiring.
- Name each slice by its outcome: `S2 Requester-only answer route`. Commit subjects follow the project's conventions; keep them short.
- After each slice, run the spec's tests and the project's existing tests for the area, then tick the slice in place in the Slices list with its commit and the test states: ``- [x] **S2 …** — … Landed in `abc1234`; T1, T2 green, T3 still red as expected.`` The Slices list is the only record in the spec of what landed where; there is no separate progress section. A commit's hash is only known once it exists, so tick each slice in the next slice's commit, and the last one in the finishing commit. Then go on to the next slice without waiting, unless the user asked to step through slice by slice.
- If a slice will go over budget, split it in the Slices list before writing it, and tell the user in one line.
- What each commit changed, file by file, and why is not recorded in the spec. It goes in the sprint log when the task is a sprint task, and in the pull request description otherwise.
- Do not push a branch whose spec tests are still red unless the project's test framework has a strict expected-failure marker (such as `pytest.mark.xfail(strict=True)` or `test.failing`) on them, removed in the slice that turns each test green. Pushing feature branches is otherwise fine where the user allows it.

## The tests are the standard

The approved tests define "working". The code meets them; they are not changed to meet the code.

- Never edit, skip, weaken or delete an approved test to make a slice pass. If a test turns out to be wrong, stop and tell the user what is wrong with it, what you would change, and why. Change it only after they agree, and record it under Deviations.
- New tests that the work shows are needed are added with the next free id, listed in the spec with their sentence, and named in the tick of the slice that adds them. Adding tests needs no approval; changing approved ones does.
- A slice that breaks an existing test outside the spec is not done. Fix the code, or stop and ask if that test's expectation is what has to change.

## When to stop

Stop and ask the user, instead of carrying on, when:

- the work needs to edit a file outside `Touches:`
- an interface has to differ from the one in the spec
- an approved test has to change
- a slice cannot be done within budget and cannot be split cleanly
- the work turns up behavior, a decision or a risk the spec does not cover

For each one, say what you found and what you recommend, then update the spec once they decide. Small departures that change nothing the user approved, such as a helper renamed or a file split in two, are recorded under Deviations and need no stop.

## Deviations

Record every departure from the approved spec in its Deviations section in the same edit as the change: what differs, why, and whether the user approved it (`approved by Owner 2026-10-28 in chat`). The section is how the user sees, at a glance, everything that is not what they agreed to.

## Finishing

The spec is done when every test in it passes, the project's full test suite passes, each not-covered item has been checked or is handed to the user as a named manual step, and every slice is ticked with its commit. Then:

1. Set `Status: Done YYYY-MM-DD`, in the same commit as the last slice's tick.
2. Report to the user: the goal, each test id with its result, the slices with their commits, every deviation, and any manual check still left to them.
3. If the spec came from a sprint task, update the sprint per its own rules (see "Sprints").

A finished spec is kept, frozen: it is the record of what the user agreed to and why the tests are what they are. Do not edit a spec after it is `Done`; later work on the same code gets its own spec. If the work is abandoned, set `Status: Abandoned YYYY-MM-DD: <why>` and keep the file.

## Sprints

When the project has `docs/sprints/` and the spec is for one of its tasks, each fact lives in one place and the other document links to it:

| Fact | Lives in | The other document |
| --- | --- | --- |
| Which tasks, in what order, in which wave | the sprint | the spec's `Task:` line links the task |
| Exact files and interfaces | the spec | the task keeps a directory-level `Touches:` for wave planning |
| What "done" means | the spec's tests | the task's done-when reads `Spec done: [SPEC-…](../specs/SPEC-….md).` |
| Which slice landed in which commit | the spec's Slices list | — |
| What each commit changed, file by file, and why | the sprint log | the log entry names the slice instead of restating the plan |
| Questions about how this task is built | the spec's Open questions | goes to the sprint's Decisions only if it blocks another task |

- When the spec is approved, rewrite the task's done-when to the `Spec done:` link and narrow its `Touches:` to the directories and shared resources the spec's Scope names. Do not copy the file list.
- If the work later reaches a directory or shared resource the task's `Touches:` does not name, update `Touches:` in the same edit as the spec's Scope and re-check the task's wave in the sprint's Parallel plan. A new file inside a directory already named needs no sprint edit.
- **Parallel waves:** before a wave starts, write the spec for every task in it and get approval 1 for all of them in one sitting with the user. Each agent in the wave then gets its task and its approved spec, does approval 2 by reporting its S1 tests to the coordinating session, and edits only its own spec file, which no other agent touches.

## Using specs during normal work (do this without being asked)

- Before a dev task, look in `docs/specs/` (or `docs/specs/tasks/`) for a spec whose status is `Draft` or `Approved` and that matches the work. If one exists, work from it.
- While working from an approved spec, follow its slices, keep its tests fixed, and tick slices and record deviations as you go, in the commit for the slice they describe or the next one.
- When a change grows past one slice while you are doing it without a spec, stop at a clean point and offer to write one for the rest.
