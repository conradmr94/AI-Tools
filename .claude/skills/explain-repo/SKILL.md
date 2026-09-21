---
name: explain-repo
description: Generate a living, browsable architecture — interactive HTML documents covering how the product works, how the code works, and (when the repo has one) how the data is modeled — for the current repository. Use when asked to document, diagram, or explain a codebase/product/data model end to end.
---

# explain-repo

Produce self-contained, zero-dependency HTML documents that explain this
repository, and a shared viewer that renders all of them. This is not a
summary — it is meant to replace the 45 minutes a new engineer spends
grepping around before they understand what they're looking at.

## Output contract

Two or three documents (see below), one shared engine, all under `docs/`
(or this repo's existing docs convention):

- `docs/product/` — **how the product works.** For someone who will use,
  sell, integrate with, or make decisions about this thing, and has never
  opened the code. What problem it solves, what its core unit of work is,
  how it connects to the outside world, what it can and cannot do, what a
  real end-to-end operation looks like, what isn't true/finished yet.
- `docs/architecture/` — **how the code works.** For someone about to modify
  it. Module inventory, dependency graph, deployment topology, the literal
  path one request/job/transaction takes through the code, build and test
  pipeline.
- `docs/data-model/` — **how the data is modeled.** For someone about to
  write a query, a migration, or a new field. Entity inventory, relationships
  and cardinality, constraints, and which invariants the database enforces
  versus which ones only the application code does. **Conditional**: only
  generate this document if the repo actually persists structured data it
  owns the schema for (a database, ORM models, migration files, a schema
  DDL/IDL). Skip it for a repo whose only "data" is config, a CLI's
  in-memory state, or a thin client of someone else's API — don't invent a
  data model doc where there's no real schema to describe.
- `docs/viewer/` — the shared rendering engine. Holds **no content.** Each
  document is a folder of data files plus an `index.html` that loads them.

If the repo already has one narrower architecture or schema doc (an ERD, a
`SCHEMA.md`, a dbdiagram export), treat it as prior art to absorb (see
"Cross-link, don't triplicate" below) — don't leave a stale copy sitting
next to the new one.

### Refresh mode — if `docs/product/`, `docs/architecture/`, `docs/data-model/`, or `docs/viewer/` already exist

This means the skill has run here before. The job is a **drift refresh, not
a rebuild** — never regenerate from scratch, and never bail out because the
docs already exist. Work in this order:

1. Read `revision` out of each existing `data/doc.js` — the commit its
   content was last checked against.
2. Run `git log <revision>..HEAD -- . ':!docs/product' ':!docs/architecture'
   ':!docs/data-model' ':!docs/viewer'` (adjust the excludes to this repo's
   doc paths).
3. Read the commit bodies and the diff to the repo's own decision docs,
   specs, and issue tracker **first** — they say what changed in *intent*,
   which a commit subject line alone won't tell you.
4. Only then verify every affected record against source for real — routes,
   migrations, config fields, contract kinds. **Never edit a record from
   memory of the commit message alone.**
5. Preserve ids and structure for anything unchanged, so deep-link hashes
   (`#view=x&node=y`) and any external references keep working.
6. Keep the same viewer engine unless it's missing functionality the update
   needs — it's a shared, versionless asset, not something forked per
   update.
7. Update the gaps pages from the tracker's own open-item list, not from
   memory.
8. Bump `revision` in every descriptor you touched, then run the validator
   and the browser check (Phase 4).
9. If a whole document is missing while the others exist, generate only the
   missing one — including `data-model/`, if the repo has since grown a
   real schema.
10. End with what changed since the last version, not a restated
    description of the current state — that's what a refresh reader
    actually came for.

## Phase 1 — Reconnaissance (don't skip, don't skim)

Before writing anything, actually read the tree. Parallelize broad
exploration (Explore agents / parallel tool calls) across:

- Top-level layout: what are the packages/apps/services/modules, in what
  language(s), and what's the dependency direction between them? Read the
  actual manifest files (Cargo.toml, package.json, pyproject.toml, go.mod,
  build files) — don't infer from folder names.
- The **one thing this system exists to do** — find the central domain
  object or unit of work (a request, a job, an order, a transaction, an
  event) and trace it from entry to exit through real source, not docs.
- Every boundary the system has: what's inside vs. outside, what talks to
  what over a network, what's authenticated how, where secrets/config live,
  what's a separate deployable vs. an in-process module.
- If there's a persisted schema: the actual source of truth for it (migration
  files in order, not just the latest snapshot; ORM model definitions;
  `schema.sql`/`schema.prisma`/equivalent). Read migrations in sequence when
  present — the current shape plus *how it got there* (renames, backfills,
  dropped columns) is often what a "what changed" reader actually needs.
  Note which constraints live in the database (foreign keys, unique
  indexes, check constraints) versus which are only enforced in application
  code (validation logic, ORM hooks) — that gap is usually where bugs live.
- Existing docs, ADRs, design docs, READMEs — these tell you the *intended*
  architecture and the vocabulary the team already uses. Read them, but
  verify claims against code; note where they've drifted.
- Tests, CI config, and any "how do I run this" instructions — these are
  usually the most honest description of what's actually load-bearing.
- What's unfinished, deferred, or explicitly out of scope. Every real system
  has this list; find it (issue trackers, TODO/FIXME, "not yet implemented",
  version/milestone docs) rather than pretending everything is done.

Take notes as you go on: the central unit of work, the major subsystems and
their one-sentence responsibilities, the trust/deployment boundaries, and
anything that surprised you (that's usually what's worth a diagram).

## Phase 2 — Build the shared viewer (skip if `docs/viewer/` already exists)

Zero dependencies. No CDN, no webfont, no build step, no framework. It must
work opened directly from `file://` — which means classic `<script src>`,
not ES modules (imports and `fetch()` are blocked on `file://`).

- `viewer.js`: a small layout engine (lanes → groups → nodes, positions
  computed, not hand-placed) that renders an SVG diagram from a declarative
  spec, plus a router (URL hash), search, a tabbed detail panel, zoom/pan,
  and light/dark theme via CSS custom properties. Every document that uses
  it supplies a `data/doc.js` descriptor (title, links to the sibling
  document(s) that exist, page labels) so the same engine can serve
  documents with different vocabulary and audiences without forking it.
- `viewer.css`: tokens-based, both themes, mobile-safe (test at ~390px
  width — no horizontal overflow).
- `validate.mjs`: a Node-stdlib-only script that loads each document's data
  files and checks: every cross-reference resolves to a real entry, no
  duplicate ids, every referenced repo path/file actually exists, every
  diagram edge's endpoints exist on that diagram. Also scan the **source
  text** (not just the evaluated object) for a field repeated twice inside
  one record literal — JS silently keeps the last one and drops the first,
  which is invisible after evaluation and easy to introduce by accident
  while editing. Run this after every edit to the data files.

## Phase 3 — Write the content as data, not as prose you hand-lay-out

For each document, three files under `data/`:

- `modules.js` — one record per real thing. In `product/` and
  `architecture/` that's a module / concept / integration role / deployed
  service / reference workflow — whatever taxonomy fits this repo. In
  `data-model/` it's one record per **entity/table**: `id, name,
  kind ('entity'), path (schema/migration file that defines it), status,
  tagline, owns[] (fields, with type and nullability), boundary[]
  (what this entity does *not* guarantee — e.g. "uniqueness is enforced by
  the app, not a DB constraint"), dependsOn[] (foreign-key relationships,
  each noting cardinality and on-delete behavior), key[{f,d}],
  invariants[] (constraints, checks, triggers — and whether the DB or the
  app enforces each one), notes[]`. **Never author the reverse-dependency
  list** — compute "used/referenced by" from `dependsOn` at render time, so
  views can't drift apart.
- `diagrams.js` — each view is lanes of groups of nodes plus edges; layout
  is computed from that declaration, never hand-positioned. A node with a
  `ref` opens that entry's full record on click. In `data-model/`, the
  primary view is the entity-relationship diagram: edges are foreign keys,
  edge labels carry cardinality (`1–many`, `many–many` via join table,
  etc.), and a join table gets its own node rather than being collapsed
  into the edge. **Diagram hygiene**: a group's `title` must fit its column
  width — a wrapped title reads as a bug, not content; a node's `sub` text
  is tokens joined by spaces or `·` (e.g. `identity · network ·
  application`), never a slash-joined list — the text wrapper breaks a long
  slash-joined token mid-word.
- `reference.js` — numbered step-by-step walkthroughs, an invariant/
  guarantee map, a "not true yet" / gaps list, and a glossary. Each step is
  `{ what, refuses, ref }` at minimum: `what` names the mechanism that
  actually runs — a function, a route, a table write — not a paraphrase of
  it; `refuses` is what that step won't do; `ref` links the step into the
  module/entity catalog so a reader can jump straight to the full record.
  Each walkthrough also carries a `controls[]` list — `{ name, enforcedBy,
  stops }` — naming the specific safeguards that walkthrough depends on,
  what enforces each one, and exactly what it stops; this sits apart from
  the step narrative so the safeguards are scannable on their own. In
  `data-model/`, walkthroughs are the write paths worth understanding (how
  a record is created/updated/soft-deleted end to end, what cascades, what
  a migration needs to preserve) rather than product or request flows.

### Record depth

Every record, in every document, carries this floor — nothing here is
optional:

- `owns[]` — what it actually does, as facts, not aspirations.
- `boundary[]` — **mandatory, not a nice-to-have.** What it refuses to do.
  A record with an empty boundary list isn't finished; the refusal is
  usually the more informative half of the pair. ("Consumes a durable
  single-use permit before dispatch" is a fact; "a retry can never
  duplicate an effect on the target" is the guarantee a reader actually
  needed.)
- `key[{f, d}]` — real files, routes, tables, or config keys, each with a
  one-line purpose stated in terms of what it does, not what it's named.
- `invariants[]` — a property that holds, plus the mechanism that enforces
  it (a constraint, a check, a function, an error code) — never the
  property by itself. In `data-model/`, say whether the database or the
  application enforces it.
- `notes[]` — anything a newcomer would trip over that doesn't fit the
  other fields.

Depth to hit, concretely — a record thinner than this isn't done (illustrative
shape, not tied to any one stack):

```js
{
  id: 'checkout-worker', name: 'checkout-worker', kind: 'binary', lang: 'Go',
  path: 'cmd/checkout-worker/main.go', status: 'DONE',
  tagline: 'Consumes queued checkout events and drives an order to a terminal state.',
  owns: [
    'Idempotent consumption from the `checkout.events` queue',
    'Retry with exponential backoff up to 5 attempts, then dead-letter',
    'Writing order state-machine transitions to `orders`',
    'Emitting `order.completed` / `order.failed` events on transition'
  ],
  boundary: [
    'Never charges a payment method directly — delegates to `payments-client` and only records its response',
    'Refuses to transition an order already in a terminal state, even on a replayed event',
    'Does not retry a 4xx from the payment provider — those are dead-lettered immediately',
    'Holds no customer PII beyond an opaque order id'
  ],
  dependsOn: ['payments-client', 'orders-repo', 'event-bus'],
  key: [
    { f: 'internal/consumer.go', d: 'Message loop: at-least-once delivery, deduped by event id against `processed_events`' },
    { f: 'internal/statemachine.go', d: 'The only legal place an order transitions; every other writer is rejected by a DB check constraint' }
  ],
  invariants: [
    'An order transitions at most once per event id — enforced by the unique constraint on `processed_events.event_id`, not application logic alone',
    'A dead-lettered event is never silently dropped — enforced by requiring an explicit `resolved_at` before deletion'
  ],
  notes: [
    'The 5-retry cap is a business decision (see ADR-014), not a technical limit — raising it needs sign-off, not a config change.'
  ]
}
```

Content quality bar — this is what separates a useful doc from a wiki
nobody trusts:

- Every walkthrough step should name what it refuses, not just what it
  does — that's where a system's real design decisions live.
- Write a "not true yet" / gaps page and mean it. Audit it against the
  content you just wrote before you ship: read every claim looking for the
  unstated assumption, and check it against the repo's own issue tracker,
  TODOs, and version/roadmap docs. A document that hides what's unfinished
  is worse than no document. In `data-model/` this includes columns that
  are vestigial, migrations that were never backfilled, and constraints
  the schema implies but nothing actually enforces.
- Prefer naming a mechanism over asserting a number (counts drift). When a
  number is genuinely load-bearing, note what revision/commit it's from.
- Every document should differ from its siblings in **vocabulary and
  altitude**, not just content. Same fact, two altitudes: the product
  document says *"what 'refunded' means to a customer today — money back
  on the original payment method, arriving in 3–5 business days; it does
  not cancel a subscription."* The architecture document says
  *"`refund_worker.go` calls `payments.Refund(orderID, amount)`, writes
  `refunds.status = 'completed'` only after a 2xx, and never touches
  `subscriptions`."* Same claim, verified against the same source — one
  readable by someone who will never open an editor, one precise enough to
  modify the code by.

### Honesty audit before shipping

After writing, grep every document for each capability it claims and check
it against the repo's own tracker / spec status rows and the actual routes
or code — not against what you intended to write. Anything designed but
unwired gets three things, not a passing mention:

1. A `status:` field on its record (e.g. `'Designed; not yet wired'`,
   `'IN PROGRESS'`).
2. A `NOT TRUE YET:` line in its `notes[]` naming the operable alternative,
   if one exists.
3. A gaps entry with an `owner` pointing at whichever doc, spec, or tracker
   item actually made that call.

The diagrams have to reflect it too: a designed-but-unwired capability gets
its own group (e.g. `title: 'Designed, post-V1'`, a neutral tone) — never
mixed into a group that reads as live.

When two records in the repo disagree about the same fact (a README claims
one thing, the tracker says another, the code does a third), the document
**reports both and names the owner of each — it does not pick a winner or
quietly average them.** Reconciling that disagreement isn't this skill's
job.

## Phase 4 — Verify in an actual browser, and click things — not by inspection

Use headless Chromium (Playwright, if available) against the `file://` path
for every document you generated or updated. Hash-only checks are not
enough: a router that pre-sets its internal state before changing the URL
hash will pass every hash-load test and still be broken for a real click,
because a click drives state through a different code path than a page load
does. Verify the click path directly, not just the load path:

- Click **every** sidebar nav button and **every** node with a `ref`, and
  assert the page or detail panel actually changed — check the rendered
  heading text or panel content, not just `location.hash`.
- Every detail tab that opens has non-empty content; none render as an
  empty shell.
- Load a hash deep link (`#view=x&node=y`) starting from a **blank tab**
  (navigate straight to the deep-linked URL, don't click your way there
  from the index) — that's the only way to catch state the router assumed
  an earlier click had already set.
- Type into search, press Enter, and confirm results rank sensibly and
  open the right record.
- Every companion-document switch works in both directions (product ↔
  architecture, and either ↔ data-model when it exists).
- Scan for edge labels overlapping node boxes, and screenshot a handful of
  the busiest diagrams and actually look at them. For `data-model/`,
  specifically check that cardinality labels on ER edges stay legible where
  many relationships converge on one entity.
- No horizontal overflow at desktop (~1440px) and mobile (~390px) widths —
  screenshot both.
- No console or page errors anywhere above.

## Phase 5 — Cross-link, don't triplicate

If an existing static architecture or schema doc covered material the new
documents now cover better, don't leave three copies of the truth:

1. Diff its content against what you just built. Anything present only in
   the old doc, migrate in *before* touching it — don't delete first and
   reconstruct from memory.
2. Collapse it to a short pointer: what it used to contain, why it's now a
   pointer, links to both real documents, and — critically — a table of
   what remains **authoritative** (design docs, specs, decision logs) that
   neither browsable document owns or overrides.
3. Fix every other reference to the old doc (READMEs, other docs, nav
   links, in-app fallback text) so nothing dead-ends there.

## House rules (bake these into whatever you generate)

- Every document **describes; it decides nothing.** Where a statement would
  conflict with the repo's actual authoritative docs/specs — or, for
  `data-model/`, with the actual migration history — that source wins and
  the generated doc is wrong until fixed.
- Every module/entity record traces to something real: a file, a config
  key, a route, a table/column — not a paraphrase of a paraphrase.
- No third-party runtime dependency anywhere in the viewer. This has to
  survive being opened on a laptop with no network, five years from now.
- Ship a `README.md` per document (and one for the shared viewer) that
  states the schema, how to extend it, and how to run the validator. The
  viewer's `README.md` additionally carries a **"Keeping it current"**
  section spelling out the refresh procedure (the `git log
  <revision>..HEAD` command, what to read first, what to bump) — so a
  future refresh doesn't have to rediscover it from this skill file.

## When you're done

Run the validator clean, run the browser check clean, and give a one-
paragraph summary of what's in each document plus the exact commands to
open them (`open docs/product/index.html` or equivalent) — noting if
`data-model/` was skipped and why. If this was an update to existing docs,
lead with what changed since the last version instead of re-describing the
whole thing.
