#!/usr/bin/env bash
set -u

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
failed=0

copy_if_missing() {
	local source_name=$1
	local target_name=$2
	if [[ ! -f "$root/$source_name" ]]; then
		printf '[failed] missing template: %s\n' "$source_name" >&2
		failed=1
		return 0
	fi
	if [[ -e "$root/$target_name" ]]; then
		printf '[skipped] %s already exists\n' "$target_name"
		return 0
	fi
	if cp -- "$root/$source_name" "$root/$target_name"; then
		printf '[created] %s\n' "$target_name"
	else
		printf '[failed] could not create: %s\n' "$target_name" >&2
		failed=1
	fi
}

copy_if_missing AGENTS.local.example.md AGENTS.local.md
copy_if_missing .env.example .env
exit "$failed"
