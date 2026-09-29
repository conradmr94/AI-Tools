---
name: sprints
description: Sprint planning records in docs/sprints/ - a sprint is a work period the user opens and closes ad hoc, holding the loosely grouped tasks they want done in it, with engineering tasks sorted into waves that can run in parallel across multiple agents. Use when the user asks to set up sprints, open or plan a sprint, close a sprint, add a task, record a decision, write a retrospective, or work out which tasks can run in parallel. Also use without being asked - at the start of any dev task, check the open sprint to see if the work maps to a task; when a task finishes, tick it and add its done note; when work turns up a new task, decision or blocker, record it in the open sprint.
---

# Sprints

A sprint is a work period the user defines: it opens when they say so and closes when they say so. It is not a fixed week. It holds the tasks the user wants done in that period, loosely grouped into tracks.

A project keeps one markdown file per sprint in `docs/sprints/`, named by the date the sprint opens: `SPRINT-YYYY-MM-DD.md`, with `# Sprint YYYY-MM-DD` as its title. Sprint files are planning records and decide nothing. Decisions stay in the project's plan, design, spec and TODO documents, and a sprint task links to the record that owns its outcome.

If the project's `docs/sprints/README.md` disagrees with this skill, follow the README for that project and mention the difference to the user once.

## Which sprint is open

- The open sprint is the newest file whose `Retrospective` still reads "Filled in when the sprint closes." (or the older "Filled in at the end of the week.").
- If more than one file is open, the newest is current. Tell the user once that the older one was never closed, and offer to close it.
- If no sprint is open, do not create one unprompted. Tell the user once and offer to open one.

## Setting up sprints in a project

When `docs/sprints/` does not exist and the user asks for sprints:

1. Read the project's planning sources first: `README.md`, `CLAUDE.md`/`AGENTS.md`, any engineering guide, plan, roadmap, TODO, design or spec docs, and the last few weeks of `git log`. Identify the owning documents that tasks will link to, and any gap or issue ids those documents use (such as `ADAPTERS-V1-03`).
2. Pick the tracks. The default is two: a non-engineering track and an Engineering track. Call the first Business for a company with customers, or Product for a solo product (practice, user feedback, content). Ask only if it is genuinely unclear.
3. Write `docs/sprints/README.md` from [readme-template.md](readme-template.md), substituting the track names, owning documents and project rules. Keep links relative and correct.
4. Open the first sprint from [sprint-template.md](sprint-template.md) (see "Opening a sprint").
5. Add this line to the project's `CLAUDE.md`, creating a section if needed, so future sessions pick up sprints unprompted:
   `Sprints: plans live in docs/sprints/ (see its README). Use the sprints skill: check the open sprint before starting work and update it as tasks finish.`
   If the project's engineering guide lists where documents live, add the sprints directory there too.

## Opening a sprint

- **Date:** use today's date unless the user names another. If a file for that date already exists, update it instead of creating a second one.
- **Previous sprint:** if the previous sprint is still open, close it first (see "Closing a sprint"), or ask the user whether it stays open alongside the new one.
- **Goal:** one sentence (it may be long) saying what is true when the sprint closes that was not true when it opened.
- **Dates:** the opening date, a target close date if the user gives one, and the fixed external dates the work is moving toward, each with its source link.
- **Context:** only the facts the tasks rest on, each with a link, commit hash or date. Start with what the previous sprint closed and what the user approved since then.
- **Where tasks come from:** the owning documents (open gap rows, design workstreams, plan stages), recent commits, the user's requests, and the previous sprint's unfinished tasks and retrospective. Do not invent work that no document and no user request supports.
- **Numbering:** write the tasks in dependency order and number each track from 1 in that order, following "Numbering follows dependency order". Decide the order before assigning ids, and check that no task's id is lower than a task it depends on.
- **Must versus stretch:** a must task fits inside the period with the people available. Split a large task and move the remainder to stretch or a later sprint. When the order of the must tasks matters, say so in the task, for example "Ordered last: if the period runs out it carries over rather than compressing E10."
- **Carry-over:** list every unfinished task from the previous sprint (see "Carry-over").
- **Parallel plan:** once the engineering tasks are written, sort them into waves (see "Parallel plan").
- After writing, show the user the goal and the must tasks in a few lines. The plan is a draft for them to change.

## Task format

```
- [ ] **E1** (Owner) What to do, linking the owning doc and naming the gap/workstream id. Touches: `src/auth/`, `docs/spec.md`. Done when: <something another person could verify>.
```

`Touches:` is required on engineering tasks and optional elsewhere. It lists the directories, files and shared resources the task will edit (see "Parallel plan").

- **Ids:** use the track's first letter (`B`, `P`, `E`) and a number. Numbering never carries over between sprints: every sprint numbers each track from 1, in that sprint's own dependency order, whatever the previous sprint's ids were. A carried-over task gets a fresh id like any other task, and a sub-task id such as `E3.1` never continues into the next sprint.
- **Numbering follows dependency order.** Within a track, a task's id is higher than the id of every task it depends on, so working through the ids in order never hits a task before its prerequisites. One sequence covers Must and Stretch together, so a stretch task can sit between must ids, and a task that moves between the two keeps its id. Tasks with no order between them are numbered in the order they would be run (for engineering, by wave and merge order in the Parallel plan).
- **When ids freeze.** While the sprint is still a draft, renumber freely so the ids match the order. Once any task has a status note or a tick, ids are frozen: never reuse or renumber one, and an abandoned task's id stays retired. If a later dependency change leaves unstarted tasks out of order, tell the user and offer to renumber rather than doing it unprompted.
- **Sub-tasks:** work discovered while doing a task, that must be done before moving on, is a sub-task of it, not the next whole number. Its id is the parent's id plus `.n`, the next free `n` under that parent: `E3.1`, then `E3.2`. The parent is the innermost task being worked, so a requirement found while doing `E3.1` becomes `E3.1.1`. Sub-ids sort numerically at each level (`E3.2` before `E3.10`, both before `E4`), so the ids stay increasing in dependency order without renumbering anything. List a sub-task as an indented bullet directly under its parent, in the parent's track and in the parent's Must or Stretch list.
- **Parent and sub-tasks:** the parent stays open until every sub-task it depends on is done. While it waits, append `Status YYYY-MM-DD: paused for E3.1.` to the parent. If a sub-task is a prerequisite of a later task but not of its parent, say so on that later task, for example `Blocked on E3.1.`
- **Owner:** the user's first name, `Claude`, or a split of the work. Use split forms when two parties are involved: `(Owner, with Claude drafting)`, `(Claude, Owner approves)`, `(Owner runs, Claude prepares)`, `(Claude, Owner approves the design)`.
- **Dependencies:** state them in the task: `Blocked on D2.`, `Only after E11, which defines what it must return.`, `Should not start before B2 settles D1.`
- **Done when:** name the artifacts that prove completion: tests passing, a row in the owning doc, a gap-table entry, a recorded run, the user's approval. A task that needs the user's approval is done when they give it, not when the draft exists.
- **Added mid-sprint:** never give it the next whole number just because it is new. Its id is set by where it falls in dependency order:
  - Found while working a task, and needed before moving on: a sub-task of that task (see "Sub-tasks"). Start it with `Added YYYY-MM-DD while working E3, after <what prompted it>. Needed before E4.`
  - Not found while working a task: place it directly after the last task it depends on, as a sub-id of that task (`E2.1`), and start it with `Added YYYY-MM-DD after <what prompted it>.`
  - Comes after every existing task: the next whole number is correct.
  - Put it in must or stretch as the user wants; a sub-task goes in its parent's list.

## Parallel plan

The `## Parallel plan` section sits after the Engineering track and says which engineering tasks can be handed to separate agents at the same time. Business tasks are run by the user and are not planned this way.

**Two tasks can run in parallel only if all of these hold:**

1. Neither depends on the other, directly or through a chain: no `Blocked on`, `Only after` or `Should not start before` links between them, and neither waits on an open decision.
2. Their `Touches:` do not overlap. Count shared resources as overlap, not just shared files: lockfiles and manifests, database migrations, schema and generated files, shared config, route or registry tables, a test fixture, and the same row or section of an owning document.
3. Neither's done-when needs the other's output, such as a test suite or build that only passes once both are in.

**How to build the plan:**

- Get `Touches:` from the code, not a guess: read the directories and files each task will change. If a task's footprint cannot be worked out yet, put it in the serial group and say why.
- Group into waves. Wave 1 is every task with no unmet dependency and no overlap with another wave 1 task. Wave 2 is what unblocks once wave 1 has merged, checked the same way. If two otherwise-independent tasks overlap, put the larger one in the earlier wave and the other in the next, or list them under Serial.
- Anything that cannot share a wave goes under **Serial** with the reason: it changes a shared resource, it touches everything, or its footprint is unknown.
- Give a merge order for each wave, most foundational first, so the merger knows which conflicts to expect.
- Only tasks owned by Claude (including `Claude, Owner approves`) go in waves. Tasks the user runs, and tasks waiting on a decision, are listed as blocked with the decision id.
- Keep waves small enough for the user to supervise. Say so if a wave has more than about four tasks, and suggest splitting it.

**Format:**

```
## Parallel plan

- **Wave 1 (start together):** E1, E2, E4. No dependencies among them; `Touches:` are disjoint. Merge order: E1, E2, E4.
- **Wave 2 (after wave 1 merges):** E3 (needs E1), E5 (needs E2).
- **Serial:** E6 edits `package.json` and the schema, which E1 and E2 also change. Run it alone after wave 2.
- **Blocked:** E7 on D1.
```

**Maintenance:**

- The plan is a schedule, not a history: edit it in place as tasks finish, are added or change footprint. Frozen task ids are still never renumbered.
- A task added mid-sprint is placed in the plan in the same edit that adds it. A sub-task runs ahead of the next task that depends on its parent, so it goes in the wave before that task's, or under Serial if it cannot share one.
- Wave order and id order agree: a lower id is never in a later wave than a higher id it does not depend on unless the plan says why.
- If a task's real footprint grows past its `Touches:`, update `Touches:` and re-check its wave.
- Stretch tasks join the plan only once the must tasks are done or blocked, per the stretch rule.

**Handing a wave to agents:** when the user asks to run a wave, start one agent per task in a single step, each in its own worktree. Give each agent its task line, the done-when, the owning documents to read and its `Touches:` boundary, and tell it to stay inside that boundary, not to edit the sprint file, and to report its `Done` note. If an agent finds it must change a file outside its `Touches:`, it stops and reports rather than editing it. If it discovers a new requirement, it reports what it is, why, and which task it must precede, and the coordinating session records it as a sub-task of that agent's task; sub-tasks under different parents cannot collide on ids. Do not launch agents unless asked.

## Recording progress (the status trail)

The task text is the plan. Progress is appended to the end of the same bullet as dated notes, so the plan stays readable and the history stays in place.

- **Partial progress:** leave the box unticked and append `Status YYYY-MM-DD: <what exists now, with links>.` Add further `Status` notes over time rather than rewriting earlier ones.
- **Done:** tick the box and append `Done YYYY-MM-DD as <gap/record id>: <what shipped, concretely>.` If the result differs from the plan, say how in the same note: "with one narrowing: …", "replaced the same day because …".
- **Done with remainder:** if part of the scope did not ship, add `Not done: <what>, carried in <where it now lives>.` The remainder always lands somewhere: a gap row, a later task, or the next sprint.
- **Approval:** when the user approves, record how, for example "Owner approved the record on 2026-09-29 by merging #15. Done."
- Tick the box in the same commit as the work that met the done-when. Never tick a task whose done-when is not actually met.
- **Exception, tasks run in a parallel wave:** the agent does not edit the sprint file, because agents editing adjacent bullets of one file conflict on merge. It ends its work with the ready-to-paste `Done` (or `Status`, `Not done`) note in its report or PR description, and whoever merges the wave, or the coordinating session, ticks the box and appends the note once the work has merged.
- Never change an owning document's status just because a task closed. Update the owning document as the task says, then tick.

## Decisions needed

List only choices the user must make that block a task.

- **Open:** `- **D1 (blocks E3)** The question. Options: (a) …; (b) …. Recommendation: (a), because ….`
- **Resolved:** keep the entry in place and rewrite its head. Do not delete the entry or move it elsewhere:
  `- **D1 (resolved YYYY-MM-DD by Owner)** The resolution in one or two sentences, and where it is recorded (for example "PD-3 in the pilot definition amendment"). The original text follows. <original question, options and recommendation>`
- **Resolved another way:** if it was resolved by implementing the recommendation, or as recommended with a refinement, say which. If the resolution is provisional, add "reopen if …".
- **Recording the decision:** decisions that shape the product or architecture must also land in the owning document (a design's decision log, a spec). The sprint entry points to that record.
- **Adding decisions:** add new decisions with the next free `D` id whenever work reveals them, including mid-sprint.

## Carry-over

- List every unfinished must task from the previous sprint, and every unfinished stretch task the user still wants, mapped to its new id: `- B3 of sprint 2026-09-28 (the outreach follow-ups) continues as B2 here: <why>.` Carried tasks, sub-tasks included, do not keep their old ids: they are numbered from 1 in dependency order like any other task in the new sprint. The old id appears only in this Carry-over line, always with its sprint date, and dependencies in the carried task's text use the new ids.
- **Conditional carry:** a carry-over may depend on a date: "as B1 here, if it is not on record by 2026-10-04."
- **Unfinished tasks:** never drop one silently. If the user abandons it, say so in Carry-over with the reason.
- **First sprint:** write "None. This is the first sprint."

## Using sprints during normal work (do this without being asked)

- Before a dev task, if `docs/sprints/` exists, read the open sprint. If the work matches a task, mention its id briefly and use its done-when as the finish line. If the user says the session is one agent of a parallel wave, work only that task, stay inside its `Touches:`, and leave the sprint file to the coordinating session.
- When work completes a task, record it per "Recording progress" in the same commit.
- When work reveals a new blocker or user decision, add it to Decisions needed. When it reveals a must-fix defect or new significant work, add a task with an `Added` note, numbered by dependency order: a sub-task of the task being worked if it must be done before moving on (`E3.1`, not `E11`). Do this rather than only mentioning it in chat.
- Work that matches no task is fine; do not add every small fix. Add a task only when the user would want to see it on the period's plan.
- When a decision is resolved in conversation, update its entry in the same turn.

## Closing a sprint

When the user asks to close the sprint, or opens a new one while the previous retrospective is empty:

1. Build the retrospective from the file's own status trail and the commits: short, factual bullets. **Shipped:** task ids, with gap ids or commits. **Slipped:** task ids, with why. **Changed mid-sprint:** tasks added and decisions taken. **Changes next time:** what to do differently, including any merge conflict a parallel wave hit that a better `Touches:` would have predicted.
2. Move lessons that change how the project works into the owning document (engineering guide, design, spec), not just the retrospective.
3. Carry unfinished tasks into the new sprint's Carry-over.
4. Add the actual close date under Dates: `- Closed: YYYY-MM-DD.`
