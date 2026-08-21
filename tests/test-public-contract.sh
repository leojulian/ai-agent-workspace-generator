#!/usr/bin/env bash
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
required=(
	AGENTS.md CLAUDE.md GEMINI.md README.md README.en.md .gitignore
	set-workspace.bat set-workspace.sh
	templates/common/AGENTS.md templates/common/AGENTS.local.md
	templates/common/CLAUDE.md templates/common/GEMINI.md
	templates/common/env.template templates/windows/set-env.bat templates/bash/set-env.sh
)
for file in "${required[@]}"; do
	[[ -f "$root/$file" ]] || {
		printf '[FAIL] Missing %s\n' "$file" >&2
		exit 1
	}
done
for removed in AGENTS.local.example.md .env.example setup-workspace.bat setup-workspace.sh set-env.bat set-env.sh; do
	[[ ! -e "$root/$removed" ]] || {
		printf '[FAIL] Obsolete root file remains: %s\n' "$removed" >&2
		exit 1
	}
done
grep -Fq 'README.en.md' "$root/README.md"
grep -Fq 'README.md' "$root/README.en.md"
grep -Fq 'AGENTS.local.md' "$root/templates/common/AGENTS.md"
grep -Fq 'AGENTS.md' "$root/templates/common/CLAUDE.md"
grep -Fq 'AGENTS.md' "$root/templates/common/GEMINI.md"
for trackable in templates/common/AGENTS.local.md templates/common/env.template; do
	if git -C "$root" check-ignore -q -- "$trackable"; then
		printf '[FAIL] Template is ignored: %s\n' "$trackable" >&2
		exit 1
	fi
done
printf '[PASS] Public generator contract\n'
