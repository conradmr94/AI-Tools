# Sprint YYYY-MM-DD

## Goal

One sentence: what is true when this sprint closes that was not true when it opened.

## Dates

- Opened: YYYY-MM-DD. Target close: YYYY-MM-DD (optional).
- YYYY-MM-DD: a fixed external date the work moves toward, with its source link.

## Context

The facts the tasks rest on, each with a link, commit hash or date: what the previous sprint closed, and what the user approved since. Optional.

## Business track

### Must

- [ ] **B1** (Owner) Task, linking its owning document. Done when: verifiable outcome.

### Stretch

- [ ] **B2** (Owner) Task. Done when: verifiable outcome.

## Engineering track

### Must

- [ ] **E1** (Claude) Task, linking its owning document and naming its gap or workstream id. Touches: `path/`, `docs/file.md`. Done when: verifiable outcome.
- [ ] **E2** (Claude, Owner approves) Task. Blocked on D1. Touches: `path/`. Done when: verifiable outcome.
- [ ] **E4** (Claude) Task. Touches: `other-path/`. Done when: verifiable outcome.

### Stretch

- [ ] **E3** (Claude) Task. Only after E1. Touches: `path/`. Done when: verifiable outcome.

## Parallel plan

- **Wave 1 (start together):** E1, E4. No dependencies between them; `Touches:` are disjoint. Merge order: E1, E4.
- **Wave 2 (after wave 1 merges):** E3 (needs E1).
- **Serial:** a task that changes a shared resource (lockfile, migration, schema) or whose footprint is unknown, with the reason.
- **Blocked:** E2 on D1.

## Decisions needed

- **D1 (blocks E2)** The question. Options: (a) …; (b) …. Recommendation: (a), because why.

## Carry-over

- Unfinished tasks from the previous sprint, each mapped to its new id, with why. Or: None. This is the first sprint.

## Retrospective

Filled in when the sprint closes.
