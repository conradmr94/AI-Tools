---
name: explain-repo
description: Generate a living, browsable architecture — two interactive HTML documents (how the product works, how the code works) for the current repository. Use when asked to document, diagram, or explain a codebase/product end to end.
---

# explain-repo

Produce two self-contained, zero-dependency HTML documents that explain this
repository, and a shared viewer that renders both. This is not a summary —
it is meant to replace the 45 minutes a new engineer spends grepping around
before they understand what they're looking at.

## Output contract

Two documents, one shared engine, all under `docs/` (or this repo's existing
docs convention):

- `docs/product/` — **how the product works.** For someone who will use,
  sell, integrate with, or make decisions about this thing, and has never
  opened the code. What problem it solves, what its core unit of work is,
  how it connects to the outside world, what it can and cannot do, what a
  real end-to-end operation looks like, what isn't true/finished yet.
- `docs/architecture/` — **how the code works.** For someone about to modify
  it. Module inventory, dependency graph, deployment topology, the literal
  path one request/job/transaction takes through the code, build and test
  pipeline.
- `docs/viewer/` — the shared rendering engine. Holds **no content.** Each
  document is a folder of data files plus an `index.html` that loads them.

If the repo already has one narrower architecture doc, treat it as prior art
to absorb (see "Cross-link, don't triplicate" below) — don't leave a stale
copy sitting next to the new one.

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
  it supplies a `data/doc.js` descriptor (title, sibling-document link, page
  labels) so the same engine can serve documents with different vocabulary
  and audiences without forking it.
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

- `modules.js` — one record per real thing (module / concept / integration
  role / deployed service / reference workflow — whatever taxonomy fits
  this repo). Schema: `id, name, kind, path, status, tagline, owns[],
  boundary[], dependsOn[], key[{f,d}], invariants[], notes[]`. **Never
  author the reverse-dependency list** — compute "used by" from `dependsOn`
  at render time, so the two views can't drift apart.
- `diagrams.js` — each view is lanes of groups of nodes plus edges; layout
  is computed from that declaration, never hand-positioned. A node with a
  `ref` opens that entry's full record on click.
- `reference.js` — numbered step-by-step walkthroughs, an invariant/
  guarantee map, a "not true yet" / gaps list, and a glossary.

Content quality bar — this is what separates a useful doc from a wiki
nobody trusts:

- **For every "owns" / "what it does" line, write the matching "boundary" /
  "what it refuses to do" line.** The refusal is usually the more
  informative half. ("Consumes a durable single-use permit before
  dispatch" is a fact; "a retry can never duplicate an effect on the
  target" is the guarantee a reader actually needed.)
- Every walkthrough step should name what it refuses, not just what it
  does — that's where a system's real design decisions live.
- Write a "not true yet" / gaps page and mean it. Audit it against the
  content you just wrote before you ship: read every claim looking for the
  unstated assumption, and check it against the repo's own issue tracker,
  TODOs, and version/roadmap docs. A document that hides what's unfinished
  is worse than no document.
- Prefer naming a mechanism over asserting a number (counts drift). When a
  number is genuinely load-bearing, note what revision/commit it's from.
- The two documents should differ in **vocabulary and altitude**, not just
  content — "how the product works" should be readable by someone who will
  never open an editor.

## Phase 4 — Verify in an actual browser, not by inspection

Use headless Chromium (Playwright, if available) against the `file://` path
for both documents:

- Every view renders with no console/page errors.
- No horizontal overflow at desktop (~1440px) and mobile (~390px) widths.
- Clicking a node opens the right record; every detail tab has content.
- Search returns and ranks sensibly; a hash deep link
  (`#view=x&node=y`) opens directly into the right state.
- The companion-document switch (product ↔ code) works both directions.
- Screenshot a handful of the busiest diagrams and actually look at them —
  check for edge labels overlapping node boxes, which the layout engine
  should avoid but won't catch by construction alone.

## Phase 5 — Cross-link, don't triplicate

If an existing static architecture doc covered material the new documents
now cover better, don't leave three copies of the truth:

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

- Both documents **describe; they decide nothing.** Where a statement would
  conflict with the repo's actual authoritative docs/specs, that source
  wins and the generated doc is wrong until fixed.
- Every module/concept record traces to something real: a file, a config
  key, a route, a table — not a paraphrase of a paraphrase.
- No third-party runtime dependency anywhere in the viewer. This has to
  survive being opened on a laptop with no network, five years from now.
- Ship a `README.md` per document (and one for the shared viewer) that
  states the schema, how to extend it, and how to run the validator.

## When you're done

Run the validator clean, run the browser check clean, and give a one-
paragraph summary of what's in each document plus the exact commands to
open them (`open docs/product/index.html` or equivalent).
