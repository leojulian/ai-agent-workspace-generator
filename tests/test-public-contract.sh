#!/usr/bin/env bash
set -euo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
required=(
	AGENTS.md README.md README.en.md .gitignore
	templates/common/AGENTS.cn.md templates/common/AGENTS.local.cn.md
	set-workspace.bat set-workspace.sh
	templates/common/AGENTS.md templates/common/AGENTS.local.md
	templates/common/env.template templates/windows/set-env.bat templates/bash/set-env.sh
)
for file in "${required[@]}"; do
	[[ -f "$root/$file" ]] || {
		printf '[FAIL] Missing %s\n' "$file" >&2
		exit 1
	}
done
for removed in templates/common/CLAUDE.md templates/common/GEMINI.md templates/common/CLAUDE.cn.md templates/common/GEMINI.cn.md AGENTS.cn.md AGENTS.local.cn.md CLAUDE.cn.md GEMINI.cn.md CLAUDE.md GEMINI.md AGENTS.local.example.md .env.example setup-workspace.bat setup-workspace.sh set-env.bat set-env.sh templates/common/zh-CN; do
	[[ ! -e "$root/$removed" ]] || {
		printf '[FAIL] Obsolete path remains: %s\n' "$removed" >&2
		exit 1
	}
done
grep -Fq 'README.en.md' "$root/README.md"
grep -Fq 'README.md' "$root/README.en.md"
grep -Fq 'AGENTS.local.md' "$root/templates/common/AGENTS.md"
grep -Fq 'AGENTS.local.md' "$root/templates/common/AGENTS.cn.md"
grep -Fq 'zh-CN' "$root/README.md"
grep -Fq 'zh-CN' "$root/README.en.md"
for language_set in AGENTS.md AGENTS.local.md; do
	en_headings=$(grep -c '^#' "$root/templates/common/$language_set")
	zh_headings=$(grep -c '^#' "$root/templates/common/${language_set%.md}.cn.md")
	[[ $en_headings == "$zh_headings" ]] || {
		printf '[FAIL] Heading count differs between en and cn: %s (%s vs %s)\n' \
			"$language_set" "$en_headings" "$zh_headings" >&2
		exit 1
	}
done
for trackable in templates/common/AGENTS.local.md templates/common/env.template templates/common/AGENTS.local.cn.md; do
	if git -C "$root" check-ignore -q -- "$trackable"; then
		printf '[FAIL] Template is ignored: %s\n' "$trackable" >&2
		exit 1
	fi
done
printf '[PASS] Public generator contract\n'
