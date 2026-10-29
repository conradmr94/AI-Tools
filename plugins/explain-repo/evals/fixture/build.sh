#!/usr/bin/env bash
# Builds a small repo whose explain-repo docs are two commits behind the code, in the current directory.
set -euo pipefail

git init -q -b main .
git config user.name "Fixture"
git config user.email "fixture@example.invalid"
git config commit.gpgsign false

printf 'def greet(name):\n    return "Hello, " + name\n' > app.py
git add -A
git commit -q -m "Greeter"

mkdir -p docs/architecture/data
printf 'window.DOC = { title: "How the code works", revision: "%s" };\n' "$(git rev-parse --short HEAD)" > docs/architecture/data/doc.js
git add -A
git commit -q -m "Architecture docs"

printf '\ndef farewell(name):\n    return "Goodbye, " + name\n' >> app.py
git commit -q -am "Add farewell"
printf '\ndef shout(text):\n    return text.upper()\n' >> app.py
git commit -q -am "Add shout"
