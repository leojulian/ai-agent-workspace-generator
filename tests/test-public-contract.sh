#!/usr/bin/env bash
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
for file in AGENTS.md AGENTS.local.example.md CLAUDE.md GEMINI.md .env.example .gitignore; do
    [[ -f "$root/$file" ]] || { printf '[FAIL] Missing %s\n' "$file" >&2; exit 1; }
done
grep -Fq 'AGENTS.local.md' "$root/AGENTS.md"
grep -Fq 'AGENTS.md' "$root/CLAUDE.md"
grep -Fq 'AGENTS.md' "$root/GEMINI.md"
printf '[PASS] Public workspace contract\n'
