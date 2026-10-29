---
type: llm
---
The response has a "Read these" list of locations in reading order, each given as path:line or path:line-range with a one-line reason. Its first entry points at the rate-limiting logic (the RateLimiter in ratelimit.py, or the limiter call in client.py), not at tests, config, the lockfile or the rename.
