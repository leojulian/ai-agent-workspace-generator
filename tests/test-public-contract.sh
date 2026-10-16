#!/usr/bin/env bash
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
required=(
	AGENTS.md CLAUDE.md GEMINI.md README.md README.en.md .gitignore
	AGENTS.cn.md AGENTS.local.cn.md CLAUDE.cn.md GEMINI.cn.md
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
for removed in AGENTS.local.example.md .env.example setup-workspace.bat setup-workspace.sh set-env.bat set-env.sh templates/common/zh-CN; do
	[[ ! -e "$root/$removed" ]] || {
		printf '[FAIL] Obsolete path remains: %s\n' "$removed" >&2
		exit 1
	}
done
grep -Fq 'README.en.md' "$root/README.md"
grep -Fq 'README.md' "$root/README.en.md"
grep -Fq 'AGENTS.local.md' "$root/templates/common/AGENTS.md"
grep -Fq 'AGENTS.md' "$root/templates/common/CLAUDE.md"
grep -Fq 'AGENTS.md' "$root/templates/common/GEMINI.md"
grep -Fq 'AGENTS.local.md' "$root/AGENTS.cn.md"
grep -Fq 'AGENTS.md' "$root/CLAUDE.cn.md"
grep -Fq 'AGENTS.md' "$root/GEMINI.cn.md"
grep -Fq 'zh-CN' "$root/README.md"
grep -Fq 'zh-CN' "$root/README.en.md"
for language_set in AGENTS.md AGENTS.local.md CLAUDE.md GEMINI.md; do
	en_headings=$(grep -c '^#' "$root/templates/common/$language_set")
	zh_headings=$(grep -c '^#' "$root/${language_set%.md}.cn.md")
	[[ $en_headings == "$zh_headings" ]] || {
		printf '[FAIL] Heading count differs between en and cn: %s (%s vs %s)\n' \
			"$language_set" "$en_headings" "$zh_headings" >&2
		exit 1
	}
done
for trackable in templates/common/AGENTS.local.md templates/common/env.template AGENTS.local.cn.md; do
	if git -C "$root" check-ignore -q -- "$trackable"; then
		printf '[FAIL] Template is ignored: %s\n' "$trackable" >&2
		exit 1
	fi
done
printf '[PASS] Public generator contract\n'
