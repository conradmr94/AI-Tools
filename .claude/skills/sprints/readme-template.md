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
| Parallel plan | Which engineering tasks can run at the same time in separate agents, grouped into waves with a merge order, plus the tasks that must run serially or are blocked. |
| Decisions needed | Choices only the owner can make that block a task, with the options and a recommendation. Resolved entries stay, marked resolved. |
| Carry-over | Unfinished tasks from the previous sprint, mapped to their ids here, with why. |
| Retrospective | Filled in when the sprint closes: what shipped, what slipped, what changed mid-sprint, what changes next time. |

## Task format

- **One checkbox per task.** Each has a stable id (`B1`, `E3`), an owner, and a done-when statement someone else could verify. An owner may be split, for example `(Owner, with Claude drafting)` or `(Claude, Owner approves)`.
- **Link the owning document.** Link the document that owns the outcome (a spec gap row, a design, the evidence log) and name its id, so the outcome lands where the project keeps it.
- **Ordering.** Dependencies and ordering are stated in the task, for example "Blocked on D2." or "Only after E11."
- **Touches.** Each engineering task lists the directories, files and shared resources it will edit, for example "Touches: `src/auth/`, `docs/spec.md`." The parallel plan is built from these.
- **Size of a must task.** A must task fits inside the sprint with the people available. If it does not, split it and move the remainder to stretch or a later sprint.
- **Stretch tasks.** Start a stretch task only after every must task is done or blocked on a listed decision.
- **Ids follow dependency order.** Within a track, a task's id is higher than the ids of the tasks it depends on, and one sequence covers Must and Stretch. Ids are set when the sprint is opened and are frozen once work starts: never reused or renumbered.
- **Tasks added mid-sprint.** They are numbered by where they fall in dependency order, not by the next free number. A requirement found while working `E3` that must be done before moving on becomes the sub-task `E3.1` (then `E3.2`; found while working `E3.1` it is `E3.1.1`), listed as an indented bullet under its parent, and begins `Added YYYY-MM-DD while working E3, after <why>. Needed before E4.` The parent stays open until the sub-tasks it depends on are done. A task not found while working another goes directly after the last task it depends on, for example `E2.1`. Only a task that comes after every existing task takes the next whole number.

## Status trail

Progress is appended to the task's own bullet as dated notes, and the plan text above it stays unchanged.

- `Status YYYY-MM-DD: …` records partial progress. The box stays unticked.
- `Done YYYY-MM-DD as <gap id>: …` records completion, with what shipped and any narrowing from the plan. The box is ticked in the same commit as the work.
- `Not done: …, carried in <where>.` names any remainder and the place it now lives.

## Parallel plan

- **Two tasks share a wave only if** neither depends on the other, their `Touches:` do not overlap (shared lockfiles, migrations, schema, generated files, config and document rows count as overlap), and neither's done-when needs the other's output.
- **Waves.** Wave 1 starts together. Later waves start after the earlier wave has merged. Each wave states its merge order. Tasks that cannot share a wave are listed as `Serial` with the reason, and tasks waiting on a decision as `Blocked`.
- **One agent per task, one worktree per agent.** An agent stays inside its task's `Touches:` and does not edit the sprint file. It reports its `Done` note, and whoever merges the wave ticks the box.
- **The plan is a schedule, not a history.** Edit it in place as tasks finish or are added.

## Decisions

- **Open decisions** read `**D1 (blocks E3)**`, followed by the question, the options and a recommendation.
- **Resolved decisions** keep their place and read `**D1 (resolved YYYY-MM-DD by Owner)**`, followed by the resolution, where it is recorded in the owning document, and then "The original text follows." with the original entry.

## Rules

- Sentence-case headings, `-` lists, backticks for commands and filenames. Do not leave placeholder markers in a task.
- Engineering tasks meet the project's engineering guide, including its test, security and documentation requirements. A sprint cannot waive them.
- Business tasks record their evidence in the project's evidence documents, not in the sprint file.
- An unfinished task carries over explicitly under `Carry-over` in the next sprint. It is never dropped silently.
- The retrospective is short, factual and built from the status trail. Lessons that change how the project works move into the owning document.
