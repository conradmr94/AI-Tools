<!-- Template for docs/sprints/README.md. Replace the track names, owning documents, gap-id conventions and project rules for the target project, then delete this comment. -->

# Sprints

A sprint is a work period that opens and closes when the team chooses; it is not a fixed week. Each sprint file holds the tasks the project wants done in that period, grouped into two tracks: business (customer discovery, pilot engagement, evidence) and engineering (shipping code and documentation). Each track splits into tasks that must be done and stretch goals. There is one file per sprint, named by the date it opens: `SPRINT-YYYY-MM-DD.md`. The open sprint is the newest file whose retrospective is not yet filled in.

Sprint files are planning records and decide nothing. Product and architecture decisions stay in the owning documents: the plan or design documents, the specifications and the approved designs. A sprint task links to the record that owns its outcome, and closing the task does not change that record's status by itself.

## File layout

Every sprint file has the same sections, in this order.

| Section | Contents |
| --- | --- |
| Goal | One sentence: what is true when the sprint closes that was not true when it opened. |
| Dates | The opening date, an optional target close date, the fixed external dates the work moves toward, and the actual close date once the sprint closes. |
| Context | The facts the tasks rest on, with links to where they were established. Optional. |
| Business track | `Must` and `Stretch` task lists. |
| Engineering track | `Must` and `Stretch` task lists. |
| Decisions needed | Choices only the owner can make that block a task, with the options and a recommendation. Resolved entries stay, marked resolved. |
| Carry-over | Unfinished tasks from the previous sprint, mapped to their ids here, with why. |
| Retrospective | Filled in when the sprint closes: what shipped, what slipped, what changed mid-sprint, what changes next time. |

## Task format

- **One checkbox per task.** Each has a stable id (`B1`, `E3`), an owner, and a done-when statement someone else could verify. An owner may be split, for example `(Owner, with Claude drafting)` or `(Claude, Owner approves)`.
- **Link the owning document.** Link the document that owns the outcome (a spec gap row, a design, the evidence log) and name its id, so the outcome lands where the project keeps it.
- **Ordering.** Dependencies and ordering are stated in the task, for example "Blocked on D2." or "Only after E11."
- **Size of a must task.** A must task fits inside the sprint with the people available. If it does not, split it and move the remainder to stretch or a later sprint.
- **Stretch tasks.** Start a stretch task only after every must task is done or blocked on a listed decision.
- **Tasks added mid-sprint.** They take the next free id and begin `Added YYYY-MM-DD after <why>.` Ids are never reused or renumbered within a sprint.

## Status trail

Progress is appended to the task's own bullet as dated notes, and the plan text above it stays unchanged.

- `Status YYYY-MM-DD: …` records partial progress. The box stays unticked.
- `Done YYYY-MM-DD as <gap id>: …` records completion, with what shipped and any narrowing from the plan. The box is ticked in the same commit as the work.
- `Not done: …, carried in <where>.` names any remainder and the place it now lives.

## Decisions

- **Open decisions** read `**D1 (blocks E3)**`, followed by the question, the options and a recommendation.
- **Resolved decisions** keep their place and read `**D1 (resolved YYYY-MM-DD by Owner)**`, followed by the resolution, where it is recorded in the owning document, and then "The original text follows." with the original entry.

## Rules

- Sentence-case headings, `-` lists, backticks for commands and filenames. Do not leave placeholder markers in a task.
- Engineering tasks meet the project's engineering guide, including its test, security and documentation requirements. A sprint cannot waive them.
- Business tasks record their evidence in the project's evidence documents, not in the sprint file.
- An unfinished task carries over explicitly under `Carry-over` in the next sprint. It is never dropped silently.
- The retrospective is short, factual and built from the status trail. Lessons that change how the project works move into the owning document.
