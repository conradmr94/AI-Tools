---
type: llm
focus: trace
---
Find the Retrospective the agent wrote into docs/sprints/SPRINT-2026-10-20.md (in a Write or Edit call). It contains a process summary (a table or list) with one entry per engineering task:

- E1: 3 slices; its largest slice is S2 (commit 783862c or similar) at about 75 changed lines (anything from 70 to 80 counts); 2 deviations; 1 approved test changed after approval (T2).
- E2: shown as having no spec, with no slice, deviation or test-change figures (dashes, "no spec", or n/a).

Fail if the process summary is missing, if E1's figures are wrong, or if E2 is given made-up figures.
