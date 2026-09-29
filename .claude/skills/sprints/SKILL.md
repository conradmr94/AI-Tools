---
name: sprints
description: Sprint planning records in docs/sprints/ - a sprint is a work period the user opens and closes ad hoc, holding the loosely grouped tasks they want done in it. Use when the user asks to set up sprints, open or plan a sprint, close a sprint, add a task, record a decision, or write a retrospective. Also use without being asked - at the start of any dev task, check the open sprint to see if the work maps to a task; when a task finishes, tick it and add its done note; when work turns up a new task, decision or blocker, record it in the open sprint.
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
- **Must versus stretch:** a must task fits inside the period with the people available. Split a large task and move the remainder to stretch or a later sprint. When the order of the must tasks matters, say so in the task, for example "Ordered last: if the period runs out it carries over rather than compressing E10."
- **Carry-over:** list every unfinished task from the previous sprint (see "Carry-over").
- After writing, show the user the goal and the must tasks in a few lines. The plan is a draft for them to change.

## Task format

```
- [ ] **E1** (Owner) What to do, linking the owning doc and naming the gap/workstream id. Done when: <something another person could verify>.
```

- **Ids:** use the track's first letter (`B`, `P`, `E`) and number within the sprint. Never reuse or renumber an id within a sprint, even when tasks move between must and stretch. Ids restart at 1 in each new sprint.
- **Owner:** the user's first name, `Claude`, or a split of the work. Use split forms when two parties are involved: `(Owner, with Claude drafting)`, `(Claude, Owner approves)`, `(Owner runs, Claude prepares)`, `(Claude, Owner approves the design)`.
- **Dependencies:** state them in the task: `Blocked on D2.`, `Only after E11, which defines what it must return.`, `Should not start before B2 settles D1.`
- **Done when:** name the artifacts that prove completion: tests passing, a row in the owning doc, a gap-table entry, a recorded run, the user's approval. A task that needs the user's approval is done when they give it, not when the draft exists.
- **Added mid-sprint:** give the task the next free id in its track, put it in must or stretch, and start it with `Added YYYY-MM-DD after <what prompted it>.`

## Recording progress (the status trail)

The task text is the plan. Progress is appended to the end of the same bullet as dated notes, so the plan stays readable and the history stays in place.

- **Partial progress:** leave the box unticked and append `Status YYYY-MM-DD: <what exists now, with links>.` Add further `Status` notes over time rather than rewriting earlier ones.
- **Done:** tick the box and append `Done YYYY-MM-DD as <gap/record id>: <what shipped, concretely>.` If the result differs from the plan, say how in the same note: "with one narrowing: …", "replaced the same day because …".
- **Done with remainder:** if part of the scope did not ship, add `Not done: <what>, carried in <where it now lives>.` The remainder always lands somewhere: a gap row, a later task, or the next sprint.
- **Approval:** when the user approves, record how, for example "Owner approved the record on 2026-09-29 by merging #15. Done."
- Tick the box in the same commit as the work that met the done-when. Never tick a task whose done-when is not actually met.
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

- List every unfinished must task from the previous sprint, and every unfinished stretch task the user still wants, mapped to its new id: `- B3 of sprint 2026-09-28 (the outreach follow-ups) continues as B2 here: <why>.`
- **Conditional carry:** a carry-over may depend on a date: "as B1 here, if it is not on record by 2026-10-04."
- **Unfinished tasks:** never drop one silently. If the user abandons it, say so in Carry-over with the reason.
- **First sprint:** write "None. This is the first sprint."

## Using sprints during normal work (do this without being asked)

- Before a dev task, if `docs/sprints/` exists, read the open sprint. If the work matches a task, mention its id briefly and use its done-when as the finish line.
- When work completes a task, record it per "Recording progress" in the same commit.
- When work reveals a new blocker or user decision, add it to Decisions needed. When it reveals a must-fix defect or new significant work, add a task with an `Added` note. Do this rather than only mentioning it in chat.
- Work that matches no task is fine; do not add every small fix. Add a task only when the user would want to see it on the period's plan.
- When a decision is resolved in conversation, update its entry in the same turn.

## Closing a sprint

When the user asks to close the sprint, or opens a new one while the previous retrospective is empty:

1. Build the retrospective from the file's own status trail and the commits: short, factual bullets. **Shipped:** task ids, with gap ids or commits. **Slipped:** task ids, with why. **Changed mid-sprint:** tasks added and decisions taken. **Changes next time:** what to do differently.
2. Move lessons that change how the project works into the owning document (engineering guide, design, spec), not just the retrospective.
3. Carry unfinished tasks into the new sprint's Carry-over.
4. Add the actual close date under Dates: `- Closed: YYYY-MM-DD.`
