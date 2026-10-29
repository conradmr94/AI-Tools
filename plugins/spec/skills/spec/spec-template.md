# Spec: <short title>

- Status: Draft
- Task: <sprint task link, such as [E3 of sprint 2026-10-28](../sprints/SPRINT-2026-10-28.md), or "None">
- Branch: `<branch>`

## Goal

One or two sentences: what is true when this is done that is not true now.

## Scope

- Touches:
  - `path/to/file.ts` — what changes here.
- Does not touch: what a reader might expect this change to edit, and why it stays as it is.

## Interfaces

New or changed functions, routes, types, data shapes or config, as signatures:

```
answerThing(id: ThingId, requester: UserId): Result<Answer, "not_requester" | "already_answered">
```

Or "None. Internal change only."

## Behavior and proof

These tests are written first and committed before any implementation. The code is done when they all pass and nothing else broke. Run: `<command>`.

- **T1** Given <state>, when <action>, then <expected result>. Unit. `path/to/test.ts` › `test name`.
- **T2** Given …, when …, then …. Integration. `path/to/test.ts` › `test name`.

Not covered by automated tests:

- <behavior> — why it has no test, and how it is checked instead (a manual step with what to look for), or "accepted risk".

## Slices

One commit each, on the branch above, in this order. Budget: about 300 changed lines per slice, not counting lockfiles, generated files or snapshots.

1. **S1 Tests** — writes T1–T2. Each fails because the behavior does not exist yet.
2. **S2 <outcome>** — what it adds. Turns T1 green.
3. **S3 <outcome>** — what it adds. Turns T2 green.

## Open questions

- **Q1** The question, the options, and a recommendation. Every question is resolved before the spec is approved.

## Deviations

Where the work departed from this spec, and why. Filled in during the work. "None." if there were none.

## Progress

- S1 `abc1234` — tests written; T1 and T2 fail as expected.
