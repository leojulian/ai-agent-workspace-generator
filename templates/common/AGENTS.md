# Workspace Agent Instructions

## Rule precedence

1. Follow the user's current instructions first.
2. Follow this workspace file and `AGENTS.local.md` when it exists.
3. Before working in a child project, find and read the nearest project-level `AGENTS.md` and the project's own build and test documentation.
4. A local rule may specialize public workflow rules, but it cannot relax the secret-handling and non-destructive safety boundaries in this file.

## Workspace model

- Treat this directory as a container for independent projects, not as one product repository.
- Before acting, identify the target project root, branch or working-copy scope, version-control type, and applicable rule files.
- A `.git` directory means Git; a `.svn` directory means SVN. Do not initialize version control when neither exists unless the user explicitly asks.
- Do not infer that similarly named project directories or branches are synchronized.

## Local rules and secrets

- Read `AGENTS.local.md` when it exists. It may describe local projects, paths, tools, and organization-specific workflow.
- Never read, search, summarize, copy, hash, print, upload, or otherwise inspect `.env` or `.env.*` files.
- Never add `.env`, `.env.*`, or `AGENTS.local.md` to version control.
- Only the user-invoked `set-env.bat` or `set-env.sh` script in this generated workspace is permitted to read the workspace root `.env` to populate the current shell.

## Safe workflow

1. Lock the target scope and load the nearest rules.
2. Inspect Git or SVN status before modifying files; existing changes belong to the user.
3. Search only the files needed for the task and skip generated outputs unless they are explicit inputs.
4. Make the smallest coherent change and preserve existing encoding and line endings.
5. Run focused build, test, or behavior checks for the affected project.
6. Report exact paths, changes, verification evidence, and remaining risks.

## Version-control safety

- Do not discard, revert, overwrite, clean, or reformat unrelated user changes.
- Do not commit, push, merge, switch branches, or update an entire working copy without explicit authorization.
- Never run any form of `git rebase`.
- Before an authorized commit, review status, every target file, the complete diff, test evidence, and possible secrets. Commit explicit targets only.
- Treat credentials, private keys, personal data, internal addresses, logs, dumps, and machine-specific configuration as non-committable unless their safety and necessity are established.

## Quality and delivery

- Prefer project-native tools and patterns; do not broaden scope for unrelated cleanup.
- Compilation alone is not behavioral verification. Exercise the changed path when practical.
- State clearly when hardware, external services, credentials, or platform constraints prevent a check.
- Default to concise delivery notes containing the target repository, changed files, verification commands and results, and unverified risks.
