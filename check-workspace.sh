#!/usr/bin/env bash
set -u

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
failed=0
required=(AGENTS.md AGENTS.local.example.md CLAUDE.md GEMINI.md .env.example .gitignore README.md setup-workspace.bat setup-workspace.sh set-env.bat set-env.sh check-workspace.bat check-workspace.sh)

for file in "${required[@]}"; do
	if [[ ! -f "$root/$file" ]]; then
		printf '[failed] missing required file: %s\n' "$file" >&2
		failed=1
	fi
done

if ! git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	printf '[failed] workspace root is not a Git work tree\n' >&2
	exit 1
fi

for path in .env .env.production AGENTS.local.md; do
	if ! git -C "$root" check-ignore -q -- "$path"; then
		printf '[failed] path is not ignored: %s\n' "$path" >&2
		failed=1
	fi
done
trackable_example=
while IFS= read -r candidate; do
	if [[ $candidate == .env.example ]]; then
		trackable_example=$candidate
	fi
done < <(git -C "$root" ls-files --cached --others --exclude-standard -- .env.example)
if [[ $trackable_example != .env.example ]]; then
	printf '[failed] .env.example must remain trackable\n' >&2
	failed=1
fi

while IFS= read -r tracked; do
	if [[ $tracked != .env.example ]]; then
		printf '[failed] private path is tracked: %s\n' "$tracked" >&2
		failed=1
	fi
done < <(git -C "$root" ls-files -- .env '.env.*' AGENTS.local.md)

if ((failed == 0)); then
	printf '[pass] Workspace metadata is safe\n'
fi
exit "$failed"
