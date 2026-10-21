# Sprint YYYY-MM-DD — change log

What changed in the code and why, newest first. One entry per commit or small group of commits, listing every file it touched and why. HH:MM is the commit time from `git log --date=format:%H:%M`, never an estimate. Decisions and progress belong in the plan, not here. Plan: [SPRINT-YYYY-MM-DD.md](./SPRINT-YYYY-MM-DD.md).

Entry format:

```
### HH:MM · <task id> · <commit(s)> · <one-line headline>
- What: the change, in a sentence.
- Why: the reason, in a sentence.
- Files:
  - `path/to/file.ts` — what this commit changed here (naming the function, route or component) and why.
```

## Snapshot

| Task | State | Where |
| --- | --- | --- |
| E1 | Done, merged | `branch` @ abc1234, PR #12 |
| E2 | In progress | `branch` @ def5678, no PR yet |

## Files changed

- `path/to/routes.ts` — E2 — defines `POST /v1/things/:id/answer` and maps its outcomes to status codes.
- `path/to/service.ts` — E1, E2 — `answerThing` looks up who made the request, rejects anyone else, and delivers the answer once.
- `path/to/removed.ts` (deleted) — E1 — the old one-off check, replaced by the shared rule in `service.ts`.

## Entries

### HH:MM · E2 · def5678 · requester-only answer route
- What: added the answer route, which accepts only the person who made the request and claims each answer once.
- Why: the form's answer has to reach the agent once, from the right person.
- Files:
  - `path/to/routes.ts` — new `POST /v1/things/:id/answer` route; maps outcomes to status codes so the client can tell "already answered" (409) from "refused" (422).
  - `path/to/service.ts` — new `answerThing`: looks up who asked, rejects anyone else with `not_requester`, then claims and delivers.
  - `path/to/service.test.ts` — proves a non-requester gets 403 and a double submit is answered once.

### HH:MM · E1 · abc1234, 9876fed · one-line headline
- What: the change, in a sentence.
- Why: the reason, in a sentence.
- Files:
  - `path/to/service.ts` — what changed here and why.
  - `path/to/removed.ts` (deleted) — why it went.
