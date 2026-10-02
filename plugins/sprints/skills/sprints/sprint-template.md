# Sprint YYYY-MM-DD

## Goal

One sentence: what is true when this sprint closes that was not true when it opened.

## Dates

- Opened: YYYY-MM-DD. Target close: YYYY-MM-DD (optional).
- YYYY-MM-DD: a fixed external date the work moves toward, with its source link.

## Context

The facts the tasks rest on, each with a link, commit hash or date: what the previous sprint closed, and what the user approved since. Optional.

<!-- Number each track in dependency order: a task's id is higher than the ids of the tasks it depends on. Sub-tasks found mid-sprint are indented under their parent as E1.1, E1.2. Delete this comment. -->

## Business track

### Must

- [ ] **B1** (Owner) Task, linking its owning document. Done when: verifiable outcome.

### Stretch

- [ ] **B2** (Owner) Task. Done when: verifiable outcome.

## Engineering track

### Must

- [ ] **E1** (Agent) Task, linking its owning document and naming its gap or workstream id. Touches: `path/`, `docs/file.md`. Done when: verifiable outcome.
- [ ] **E2** (Agent) Task. Touches: `other-path/`. Done when: verifiable outcome.
- [ ] **E3** (Agent, Owner approves) Task. Blocked on D1. Touches: `path/`. Done when: verifiable outcome.

### Stretch

- [ ] **E4** (Agent) Task. Only after E1. Touches: `path/`. Done when: verifiable outcome.

## Parallel plan

- **Wave 1 (start together):** E1, E2. No dependencies between them; `Touches:` are disjoint. Merge order: E1, E2.
- **Wave 2 (after wave 1 merges):** E4 (needs E1).
- **Serial:** a task that changes a shared resource (lockfile, migration, schema) or whose footprint is unknown, with the reason.
- **Blocked:** E3 on D1.

## Decisions needed

- **D1 (blocks E2)** The question. Options: (a) …; (b) …. Recommendation: (a), because why.

## Carry-over

- Unfinished tasks from the previous sprint, each mapped to its new id, with why. Or: None. This is the first sprint.

## Retrospective

Filled in when the sprint closes.
