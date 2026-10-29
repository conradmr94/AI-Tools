#!/usr/bin/env bash
# Builds the fixture repo the ship evals run against, in the current directory.
#
# Every variant has a small API client on main, a README naming the test command, and an
# `origin` that is a local bare repository inside .git/ (never GitHub, so no real PR can be
# opened). origin has main only.
#
#   build.sh ready     branch `rate-limit` adds a rate limiter in two commits, with an approved
#                      spec whose slices are all ticked and whose tests pass
#   build.sh red       as ready, but the limiter has an off-by-one, so spec test T1 fails
#   build.sh on-main   the same two commits made on main instead of a branch
#   build.sh dirty     as ready, plus an uncommitted edit to client.py
#   build.sh no-spec   as ready, without the spec
#
# The checkout is left on `rate-limit`, or on main for on-main.
set -euo pipefail

variant="${1:?usage: build.sh ready|red|on-main|dirty|no-spec}"

git init -q -b main .
git config user.name "Fixture"
git config user.email "fixture@example.invalid"
git config commit.gpgsign false

# --- main: the API client ----------------------------------------------------

mkdir -p tests
cat > README.md <<'EOF'
# api-client

A tiny JSON API client.

## Tests

Run the tests with `python3 -m unittest`.
EOF

cat > client.py <<'EOF'
class ApiClient:
    """Calls a JSON API through a transport function: transport(url) -> dict."""

    def __init__(self, base_url, transport):
        self.base_url = base_url.rstrip("/")
        self.transport = transport

    def get(self, path):
        return self.transport(self.base_url + "/" + path.lstrip("/"))
EOF

: > tests/__init__.py
cat > tests/test_client.py <<'EOF'
import unittest

from client import ApiClient


class ApiClientTest(unittest.TestCase):
    def test_get_joins_base_and_path(self):
        seen = []
        client = ApiClient("https://api.example.com/", lambda url: seen.append(url) or {"ok": True})
        self.assertEqual(client.get("/users"), {"ok": True})
        self.assertEqual(seen, ["https://api.example.com/users"])


if __name__ == "__main__":
    unittest.main()
EOF

git add -A
git commit -q -m "API client"
git init -q --bare .git/origin.git
git remote add origin "$PWD/.git/origin.git"
# Run origin's helpers from git's own exec path, with that git first on PATH and a temp
# directory inside the repo: the eval sandbox blocks the /usr/bin git shim and the system
# temp folder, which the receiving side of a local push would otherwise use.
mkdir -p .git/tmp
for helper in receive-pack upload-pack; do
  cat > ".git/$helper.sh" <<EOF
#!/bin/sh
PATH="$(dirname "$(command -v git)"):\$PATH" TMPDIR="$PWD/.git/tmp" exec "$(git --exec-path)/git-$helper" "\$@"
EOF
  chmod +x ".git/$helper.sh"
  git config "remote.origin.${helper%-pack}pack" "$PWD/.git/$helper.sh"
done
git push -q -u origin main

if [ "$variant" != "on-main" ]; then
  git switch -q -c rate-limit
fi

# --- commit 1: spec and failing tests ------------------------------------------

if [ "$variant" != "no-spec" ]; then
  mkdir -p docs/specs
  cat > docs/specs/SPEC-2026-10-20-rate-limit.md <<'EOF'
# Spec: rate-limit the API client

- Status: Done 2026-10-21
- Task: None
- Branch: `rate-limit`

## Goal

The API client never sends more than a set number of requests per second; extra calls fail fast with `RateLimited`.

## Scope

- Touches:
  - `ratelimit.py` — new token-bucket limiter.
  - `client.py` — `ApiClient` takes a limiter and checks it before each call.
  - `tests/` — new limiter tests; the client test passes a limiter.
- Does not touch: `README.md`.

## Interfaces

```
RateLimiter(rate: float, clock=time.monotonic)
RateLimiter.acquire() -> None   # raises RateLimited when no token is left
ApiClient(base_url, transport, limiter: RateLimiter)
```

## Behavior and proof

Run: `python3 -m unittest`.

- **T1** Given a limiter allowing 2 per second, when 3 calls are made within one second, then the third raises `RateLimited`. Unit. `tests/test_ratelimit.py` › `test_third_call_refused`.
- **T2** Given a limiter allowing 2 per second, when 2 calls are made, then both pass. Unit. `tests/test_ratelimit.py` › `test_two_calls_pass`.

## Slices

- [x] **S1 Tests** — writes T1–T2. Landed; both red as expected.
- [x] **S2 Limiter and client** — turns T1 and T2 green. Landed; T1, T2 green.

## Deviations

- `RateLimiter` also takes a `burst` size, defaulting to `rate`, so short bursts can be allowed later. Approved by Owner 2026-10-21 in chat.
EOF
fi

cat > tests/test_ratelimit.py <<'EOF'
import unittest

from ratelimit import RateLimited, RateLimiter


class FrozenClock:
    def __init__(self):
        self.now = 0.0

    def __call__(self):
        return self.now


class RateLimiterTest(unittest.TestCase):
    def test_third_call_refused(self):
        limiter = RateLimiter(rate=2, clock=FrozenClock())
        limiter.acquire()
        limiter.acquire()
        with self.assertRaises(RateLimited):
            limiter.acquire()

    def test_two_calls_pass(self):
        limiter = RateLimiter(rate=2, clock=FrozenClock())
        limiter.acquire()
        limiter.acquire()


if __name__ == "__main__":
    unittest.main()
EOF

git add -A
git commit -q -m "Add rate limiter tests"

# --- commit 2: the limiter and the client wiring --------------------------------

refuse_below=1
[ "$variant" = "red" ] && refuse_below=0

cat > ratelimit.py <<EOF
import time


class RateLimited(Exception):
    """Raised when a call would exceed the rate limit."""


class RateLimiter:
    """Token bucket: refills \`rate\` tokens per second and holds at most \`burst\`."""

    def __init__(self, rate, burst=None, clock=time.monotonic):
        self.rate = rate
        self.burst = rate if burst is None else burst
        self.clock = clock
        self.tokens = self.burst
        self.last = clock()

    def acquire(self):
        now = self.clock()
        self.tokens = min(self.burst, self.tokens + (now - self.last) * self.rate)
        self.last = now
        if self.tokens < $refuse_below:
            raise RateLimited()
        self.tokens -= 1
EOF

cat > client.py <<'EOF'
class ApiClient:
    """Calls a JSON API through a transport function: transport(url) -> dict."""

    def __init__(self, base_url, transport, limiter):
        self.base_url = base_url.rstrip("/")
        self.transport = transport
        self.limiter = limiter

    def get(self, path):
        self.limiter.acquire()
        return self.transport(self.base_url + "/" + path.lstrip("/"))
EOF

cat > tests/test_client.py <<'EOF'
import unittest

from client import ApiClient
from ratelimit import RateLimiter


class ApiClientTest(unittest.TestCase):
    def test_get_joins_base_and_path(self):
        seen = []
        transport = lambda url: seen.append(url) or {"ok": True}
        client = ApiClient("https://api.example.com/", transport, RateLimiter(rate=10))
        self.assertEqual(client.get("/users"), {"ok": True})
        self.assertEqual(seen, ["https://api.example.com/users"])


if __name__ == "__main__":
    unittest.main()
EOF

git add -A
git commit -q -m "Rate-limit the API client"

if [ "$variant" = "dirty" ]; then
  sed -i.bak 's/        self.limiter.acquire()/        print("debug: acquiring")\n        self.limiter.acquire()/' client.py
  rm -f client.py.bak
fi
