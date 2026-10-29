#!/usr/bin/env bash
# Builds a repo with an open sprint ready to close, in the current directory.
#
# E1 has a spec (docs/specs/SPEC-2026-10-20-rate-limit.md) and landed in three slices of
# known size: S1 tests (~25 changed lines), S2 limiter (~60), S3 wiring (~15). Its spec
# records two deviations, one of them an approved change to a test. E2 has no spec and
# landed in one commit. Both tasks are done; the sprint's Retrospective is still empty.
set -euo pipefail

git init -q -b main .
git config user.name "Fixture"
git config user.email "fixture@example.invalid"
git config commit.gpgsign false

mkdir -p docs/sprints docs/specs tests
printf '# api-client\n\nRun the tests with `python3 -m unittest`.\n' > README.md
: > tests/__init__.py
git add -A
git commit -q -m "Project skeleton"

# --- E1, slice S1: tests -------------------------------------------------------
cat > tests/test_ratelimit.py <<'EOF'
import unittest

from ratelimit import RateLimited, RateLimiter


class Clock:
    def __init__(self):
        self.now = 0.0

    def __call__(self):
        return self.now


class RateLimiterTest(unittest.TestCase):
    def test_third_call_refused(self):
        limiter = RateLimiter(rate=2, clock=Clock())
        limiter.acquire()
        limiter.acquire()
        with self.assertRaises(RateLimited):
            limiter.acquire()

    def test_refills_after_half_a_second(self):
        clock = Clock()
        limiter = RateLimiter(rate=2, clock=clock)
        limiter.acquire()
        limiter.acquire()
        clock.now = 0.5
        limiter.acquire()
EOF
git add -A
git commit -q -m "E1 S1: rate limiter tests"
s1=$(git rev-parse --short HEAD)

# --- E1, slice S2: the limiter -------------------------------------------------
{
  echo 'import time'
  echo
  echo
  echo 'class RateLimited(Exception):'
  echo '    """Raised when a call would exceed the rate limit."""'
  echo
  echo
  echo 'class RateLimiter:'
  echo '    """Token bucket: refills `rate` tokens per second and holds at most `burst`."""'
  echo
  echo '    def __init__(self, rate, burst=None, clock=time.monotonic):'
  echo '        if rate <= 0:'
  echo '            raise ValueError("rate must be positive")'
  echo '        self.rate = rate'
  echo '        self.burst = rate if burst is None else burst'
  echo '        if self.burst < 1:'
  echo '            raise ValueError("burst must be at least 1")'
  echo '        self.clock = clock'
  echo '        self.tokens = self.burst'
  echo '        self.last = clock()'
  echo
  echo '    def _refill(self):'
  echo '        now = self.clock()'
  echo '        elapsed = max(0.0, now - self.last)'
  echo '        self.tokens = min(self.burst, self.tokens + elapsed * self.rate)'
  echo '        self.last = now'
  echo
  echo '    def available(self):'
  echo '        """How many whole tokens could be taken right now."""'
  echo '        self._refill()'
  echo '        return int(self.tokens)'
  echo
  echo '    def acquire(self):'
  echo '        """Take one token, or raise RateLimited if none is left."""'
  echo '        self._refill()'
  echo '        if self.tokens < 1:'
  echo '            raise RateLimited()'
  echo '        self.tokens -= 1'
  echo
  echo '    def wait_time(self):'
  echo '        """Seconds until the next token is available; 0 if one is available now."""'
  echo '        self._refill()'
  echo '        if self.tokens >= 1:'
  echo '            return 0.0'
  echo '        return (1 - self.tokens) / self.rate'
  for i in $(seq 1 6); do
    echo
    echo
    echo "def preset_$i(clock=time.monotonic):"
    echo "    \"\"\"A limiter allowing $i requests per second.\"\"\""
    echo "    return RateLimiter(rate=$i, clock=clock)"
  done
} > ratelimit.py
git add -A
git commit -q -m "E1 S2: token-bucket limiter"
s2=$(git rev-parse --short HEAD)

# --- E1, slice S3: wiring --------------------------------------------------------
cat > client.py <<'EOF'
class ApiClient:
    """Calls a JSON API through a transport function, one limiter token per call."""

    def __init__(self, base_url, transport, limiter):
        self.base_url = base_url.rstrip("/")
        self.transport = transport
        self.limiter = limiter

    def get(self, path):
        self.limiter.acquire()
        return self.transport(self.base_url + "/" + path.lstrip("/"))
EOF
git add -A
git commit -q -m "E1 S3: wire the limiter into the client"
s3=$(git rev-parse --short HEAD)

cat > docs/specs/SPEC-2026-10-20-rate-limit.md <<EOF
# Spec: rate-limit the API client

- Status: Done 2026-10-22
- Task: [E1 of sprint 2026-10-20](../sprints/SPRINT-2026-10-20.md)
- Branch: \`rate-limit\`

## Goal

The API client never sends more than a set number of requests per second.

## Behavior and proof

Run: \`python3 -m unittest\`.

- **T1** Given 2 per second, when 3 calls are made at once, then the third raises \`RateLimited\`.
- **T2** Given 2 per second and both tokens used, when half a second passes, then one more call succeeds.

## Slices

- [x] **S1 Tests** — writes T1–T2. Landed in \`$s1\`; both red as expected.
- [x] **S2 Limiter** — the token bucket. Turns T1 green. Landed in \`$s2\`; T1 green, T2 red.
- [x] **S3 Wiring** — the client takes a token per call. Turns T2 green. Landed in \`$s3\`; T1, T2 green.

## Deviations

- **T2 changed after approval.** It said "after one second"; at 2 per second a token returns after half a second, so the test now waits 0.5 s. Approved by Owner 2026-10-21 in chat.
- **\`burst\` added to \`RateLimiter\`**, defaulting to \`rate\`, so short bursts can be allowed later. Approved by Owner 2026-10-21 in chat.
EOF
git add -A
git commit -q -m "E1: spec done"

# --- E2, no spec ----------------------------------------------------------------
printf '\n## Rate limits\n\nThe client allows a fixed number of requests per second; see `ratelimit.py`.\n' >> README.md
git add -A
git commit -q -m "E2: document rate limits in the README"
e2=$(git rev-parse --short HEAD)

# --- the sprint and its log -----------------------------------------------------
cat > docs/sprints/SPRINT-2026-10-20.md <<EOF
# Sprint 2026-10-20

## Goal

The API client is rate-limited and the README says so.

## Dates

- Opened: 2026-10-20.

## Context

None.

## Engineering track

### Must

- [x] ~~**E1** (Agent) Rate-limit the API client. Touches: \`ratelimit.py\`, \`client.py\`, \`tests/\`. Done when: Spec done: [SPEC-2026-10-20-rate-limit](../specs/SPEC-2026-10-20-rate-limit.md).~~ Done 2026-10-22: limiter and client wiring shipped in three slices.
- [x] ~~**E2** (Agent) Document rate limits in the README. Touches: \`README.md\`. Done when: the README section exists.~~ Done 2026-10-22: README section added in \`$e2\`.

### Stretch

None.

## Parallel plan

- **Serial:** ~~E1~~, then ~~E2~~.

## Decisions needed

None.

## Carry-over

None. This is the first sprint.

## Retrospective

Filled in when the sprint closes.
EOF

cat > docs/sprints/SPRINT-2026-10-20-LOG.md <<EOF
# Sprint 2026-10-20 — change log

What changed in the code and why, newest first. Plan: [SPRINT-2026-10-20.md](./SPRINT-2026-10-20.md).

## Snapshot

| Task | State | Where |
| --- | --- | --- |
| E1 | Done | \`main\` @ $s3, no PR |
| E2 | Done | \`main\` @ $e2, no PR |

## Files changed

- \`README.md\` — E2 — adds the "Rate limits" section.
- \`client.py\` — E1 — \`ApiClient.get\` takes a limiter token before each call.
- \`ratelimit.py\` — E1 — the \`RateLimiter\` token bucket and its presets.
- \`tests/test_ratelimit.py\` — E1 — proves the third call is refused and a token returns after 0.5 s.

## Entries

### 10:40 · E2 · $e2 · rate limits documented
- What: README section on rate limits.
- Why: users need to know calls can be refused.
- Files:
  - \`README.md\` — new "Rate limits" section.

### 10:20 · E1 S3 · $s3 · client takes a token per call
- What: \`ApiClient\` takes a limiter and calls \`acquire\` before each request.
- Why: S3 of the spec.
- Files:
  - \`client.py\` — new \`limiter\` argument; \`get\` acquires first.

### 10:00 · E1 S2 · $s2 · token bucket
- What: \`RateLimiter\` with refill, \`available\`, \`wait_time\` and presets.
- Why: S2 of the spec.
- Files:
  - \`ratelimit.py\` — new token bucket.

### 09:40 · E1 S1 · $s1 · limiter tests
- What: tests for refusal and refill.
- Why: S1 of the spec.
- Files:
  - \`tests/test_ratelimit.py\` — T1 and T2.
EOF
git add -A
git commit -q -m "Sprint 2026-10-20 records"
